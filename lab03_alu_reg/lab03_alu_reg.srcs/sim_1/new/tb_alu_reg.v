`timescale 1ns / 1ps
//面对测试还是不会编程，借助ai进行填空
module tb_alu_reg(); // Testbench 不需要端口

    // 1. 变量定义
    // 发给芯片的信号 (你需要控制它 -> reg)
    reg clk;
    reg rst;
    reg [3:0] a;
    reg [3:0] b;
    reg [1:0] op;

    // 芯片吐出来的信号 (你只负责看 -> wire)
    wire [3:0] out;

    // 2. 实例化 (把 alu_reg 接进来)
    alu_reg u_dut (
        .clk ( clk ),
        .rst ( rst ),
        .a   ( a   ),
        .b   ( b   ),
        .op  ( op  ),
        .out ( out )
    );

    // 3. 造时钟 (心脏起搏器)
    initial begin
        clk = 0;             // 初始为 0
        forever begin
            #5 clk = ~clk;   // 每隔 5ns 翻转一次 (周期 10ns)
        end
    end

    // 4. 导演剧本 (Stimulus)
    initial begin
        // --- 第一幕：初始化与复位 ---
        rst = 1;  // 按下复位
        a   = 0;
        b   = 0;
        op  = 0;
        #20;      // 保持复位 20ns
        
        rst = 0;  // 松开复位 (电路开始工作)

        // --- 第二幕：做加法 (2 + 3) ---
        #10;      // 等一会儿
        a  = 4'd2;
        b  = 4'd3;
        op = 2'b00; // 设置为加法
        // 此时去观察波形：out 会立刻变吗？还是等下一个时钟上升沿？

        // --- 第三幕：做减法 (5 - 1) ---
        #20;
        a  = 5; // 【填空】 把 a 改成 5
        b  = 1; // 【填空】 把 b 改成 1
        op = 2'b01;   // 设置为减法

        // --- 第四幕：什么都不做，观察保持 ---
        #20;
        // 这里不改变输入，看看 out 还会不会乱跳？

        // --- 剧终 ---
        #20;
        $finish;  // 停止仿真
    end

endmodule