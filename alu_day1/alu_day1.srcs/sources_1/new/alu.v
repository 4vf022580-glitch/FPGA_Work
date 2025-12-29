`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/27 16:23:46
// Design Name: 
// Module Name: alu
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


module alu(
  input [3:0] a,
  input [3:0] b,
  input [1:0] op,
  output reg [7:0] res
    );
    
    always @(*) begin
      case(op)
        2'b00: res = a + b;
        
        2'b01: res = a - b;
        
        2'b10: res = {{4{a[3]}}, a};
        
        2'b11: res = {4'b0, a[0], a[1], a[2], a[3]};
        
        default: res = 8'b0;
      endcase
    end
    
endmodule
