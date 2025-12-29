`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/29 20:57:51
// Design Name: 
// Module Name: alu_reg
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


module alu_reg(
input clk,
input rst,
input [3:0] a,
input [3:0] b,
input [1:0] op,
output [3:0] out
    );
    
wire [3:0] alu_res;

alu u_alu(
.a(a),
.b(b),
.op(op),
.res(alu_res)
);

dff u_dff(
.d(alu_res),
.q(out),
.clk(clk),
.rst(rst)
);
endmodule
