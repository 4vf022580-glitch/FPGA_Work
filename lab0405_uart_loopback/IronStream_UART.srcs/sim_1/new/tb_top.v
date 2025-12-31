`timescale 1ns / 1ps

module tb_top();
    reg clk;
    reg rst_n;
    reg rx_line;
    wire tx_line;

    // 1. 实例化你的顶层设计
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(rx_line),
        .uart_tx(tx_line)
    );

    // 2. 产生时钟 (50MHz -> 周期 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 3. 定义波特率参数 (必须与 top 模块一致)
    localparam BIT_PERIOD = 1000000000 / 115200; // 这里的单位是 ns

    // 4. 定义一个发送字节的任务 (模拟电脑发数据)
    task send_byte(input [7:0] data);
        integer i;
        begin
            // 起始位 (拉低)
            rx_line = 0;
            #(BIT_PERIOD);
            
            // 8位数据位 (低位先发)
            for (i=0; i<8; i=i+1) begin
                rx_line = data[i];
                #(BIT_PERIOD);
            end
            
            // 停止位 (拉高)
            rx_line = 1;
            #(BIT_PERIOD);
        end
    endtask

    // 5. 主测试流程
    initial begin
        // 初始化
        rst_n = 0; rx_line = 1; // 串口空闲时是高电平
        #200;
        rst_n = 1; // 释放复位
        #200;

        // 发送数据 0x55 (二进制 01010101)
        send_byte(8'h55);

        // 等待足够长的时间让 TX 发回来
        #200000; 
        
        $stop;
    end

endmodule