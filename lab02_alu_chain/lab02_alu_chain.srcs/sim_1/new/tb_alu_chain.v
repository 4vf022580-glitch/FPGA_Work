`timescale 1ns / 1ps

module tb_alu_chain(); // 没有端口，自己玩

    // 1. 声明信号：输入用 reg (我们要控制它)，输出用 wire (我们要观察它)
    reg [3:0] head_data;
    reg [3:0] d1, d2, d3, d4;
    reg [1:0] op;
    wire [3:0] final_result;

    // 2. 召唤你的工厂 (UUT: Unit Under Test)
    alu_chain uut (
        .head_data(head_data),
        .d1(d1), .d2(d2), .d3(d3), .d4(d4),
        .op(op),
        .final_result(final_result)
    );

    // 3. 编写剧本 (Initial Block)
    initial begin
        // --- 场景 A：全加法测试 ---
        head_data = 0;
        d1 = 1; d2 = 1; d3 = 1; d4 = 1; // 既然是4级流水，加4次1
        op = 2'b00; // 加法指令
        
        #100; // 等待 100ns 让子弹飞一会儿
        
        // --- 场景 B：全按位与测试 ---
        head_data = 4'b1111;
        d1 = 4'b0101; d2 = 4'b1111; d3 = 4'b1111; d4 = 4'b1111;
        op = 2'b10; // AND 指令
        
        #100;
        
        $stop; // 停机
    end

endmodule