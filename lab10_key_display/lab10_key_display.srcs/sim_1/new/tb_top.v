`timescale 1ns / 1ps

module tb_top;

    // --- 信号定义 ---
    reg clk;
    reg rst;            // Active High Reset (匹配 Basys3 按钮逻辑)
    reg rx_line;        // 模拟 UART RX 输入
    reg sw_encrypt;     // 加密模式控制开关
    wire tx_line;       // 观测 UART TX 输出

    // UART 参数定义: 100MHz Clock / 115200 Baudrate
    localparam BIT_PERIOD = 8680; // approx 8680.5ns

    // --- DUT (Device Under Test) 实例化 ---
    top uut (
        .clk(clk),
        .rst(rst),
        .rx_line(rx_line),
        .sw_encrypt(sw_encrypt),
        .tx_line(tx_line)
    );

    // --- 100MHz 时钟生成 ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Period = 10ns
    end

    // --- UART Byte 发送任务模型 ---
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start Bit (Low)
            rx_line = 0; #(BIT_PERIOD); 
            // Data Bits (LSB First)
            for (i = 0; i < 8; i = i + 1) begin
                rx_line = data[i]; #(BIT_PERIOD); 
            end
            // Stop Bit (High)
            rx_line = 1; #(BIT_PERIOD); 
        end
    endtask

    // --- 主测试激励流程 ---
    initial begin
        // 1. 系统初始化
        rst = 1;        // 复位状态
        rx_line = 1;    // UART 空闲状态为高电平
        sw_encrypt = 1; // 默认开启加密
        
        // 2. 释放复位
        #200;
        rst = 0;        // 系统启动
        #2000;

        // 3. Case 1: 加密模式数据测试
        $display("[Test] Sending 0x55 in Encrypt Mode...");
        send_byte(8'h55);
        
        // 等待处理与发送完成 (Estimate: 10 bits * 8.68us + Latency)
        #200000; 
        
        // 4. Case 2: 直通模式 (Bypass) 测试
        sw_encrypt = 0; 
        #1000;
        $display("[Test] Sending 0x55 in Bypass Mode...");
        send_byte(8'h55);
        
        #200000;
        $display("[Test] Simulation Finished Successfully.");
        $stop;
    end

endmodule