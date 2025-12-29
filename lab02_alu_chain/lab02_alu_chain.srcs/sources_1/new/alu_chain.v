`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/29 14:53:03
// Design Name: 
// Module Name: alu_chain
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


module alu_chain(
input [3:0] head_data,
input [3:0] d1,
input [3:0] d2,
input [3:0] d3,
input [3:0] d4,
input [1:0] op,
output [3:0] final_result
    );
    wire [3:0] link_1;
    wire [3:0] link_2;
    wire [3:0] link_3;
    
    alu alu_1(
    .a (head_data),
    .b (d1),
    .op (op),
    .out (link_1)
    );
    
    alu alu_2(
    .a (link_1),
    .b (d2),
    .op (op),
    .out (link_2)
    );
    
    alu alu_3(
    .a (link_2),
    .b (d3),
    .op (op),
    .out (link_3)
    );
    
    alu alu_4(
    .a (link_3),
    .b (d4),
    .op (op),
    .out (final_result)
    );
endmodule
