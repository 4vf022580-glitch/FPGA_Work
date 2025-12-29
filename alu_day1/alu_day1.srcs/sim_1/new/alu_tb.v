`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/27 17:29:45
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module alu_tb(); // 测试台没有输入输出，因为它自己就是个封闭的实验室

    // 1. 声明"虚拟开关" (reg 类型，因为我们要给它赋值)
    reg [3:0] a;
    reg [3:0] b;
    reg [1:0] op;

    // 2. 声明"虚拟 LED" (wire 类型，负责观察输出)
    wire [7:0] res;

    // 3. 把你的 ALU 模块"搬"进来，插上虚拟线
    // 这里的 .a(a) 意思是：把模块的端口 a 接到我的变量 a 上
    alu uut (
        .a(a), 
        .b(b), 
        .op(op), 
        .res(res)
    );

    // 4. 开始测试剧本
    initial begin
        // 剧本第一幕：加法测试 (3 + 2)
        a = 3; b = 2; op = 2'b00;
        #10; // 等待 10ns，让电路反应一下
        
        // 剧本第二幕：减法测试 (3 - 2)
        a = 3; b = 2; op = 2'b01;
        #10;
        
        // 剧本第三幕：符号扩展 (输入 -1 即 4'b1111)
        a = 4'b1111; b = 0; op = 2'b10;
        #10;
        
        // 剧本第四幕：位反转 (输入 4'b1010)
        a = 4'b1010; b = 0; op = 2'b11;
        #10;
        
        // 剧本结束
        $finish;
    end

endmodule
