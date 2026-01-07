`timescale 1ns / 1ps

module tb_top;

    // 1. 信号定义：对齐硬件逻辑极性
    reg clk;
    reg rst;            // 高电平复位信号
    reg rx_line;        // 模拟串口输入 (PC -> FPGA)
    reg sw_encrypt;     // 加密开关
    wire tx_line;       // 观测串口输出 (FPGA -> PC)

    // 位周期计算：100,000,000 / 115200 ≈ 8680 ns
    localparam BIT_PERIOD = 8680; 

    // 2. 模块实例化：对齐修正后的端口名
    top uut (
        .clk(clk),
        .rst(rst),          // 修正：对齐 top.v 的 input rst
        .rx_line(rx_line),
        .sw_encrypt(sw_encrypt),
        .tx_line(tx_line)
    );

    // 3. 时钟生成：修正为 100MHz (周期 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 半周期 5ns -> 100MHz
    end

    // 4. 发送任务 (UART Send Task)
    task send_byte(input [7:0] data);
        integer i;
        begin
            rx_line = 0; #(BIT_PERIOD); // 起始位
            for (i = 0; i < 8; i = i + 1) begin
                rx_line = data[i]; #(BIT_PERIOD); // 数据位
            end
            rx_line = 1; #(BIT_PERIOD); // 停止位
        end
    endtask

    // 5. 主测试流程
    initial begin
        // --- 初始化状态 ---
        rst = 1;        // 开始复位 (Basys3 按钮按下状态)
        rx_line = 1;    // 串口空闲位为 1
        sw_encrypt = 1; // 开启加密模式
        
        // --- 释放复位 ---
        #200;
        rst = 0;        // 释放复位 (Basys3 按钮松开，逻辑启动)
        #2000;

        // --- 测试用例 1: 加密模式发送 ---
        $display("Sending 0x55 in Encrypt Mode...");
        send_byte(8'h55);
        
        // 等待接收完成（115200波特率下至少需100us以上）
        #200000; 
        
        // --- 测试用例 2: 直通模式发送 ---
        sw_encrypt = 0; 
        #1000;
        $display("Sending 0x55 in Bypass Mode...");
        send_byte(8'h55);
        
        #200000;
        $display("Simulation Finished.");
        $stop;
    end

endmodule