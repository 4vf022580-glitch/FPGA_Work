`timescale 1ns / 1ps

//=============================================================================
// Module:      alu
// Description: Standard Arithmetic Logic Unit
//              Performs Add, Sub, And, Or, etc. based on ALU_Control
//=============================================================================

module alu(
    input  [31:0] A,          // 输入操作数 A (根据需要改成 4位 或 1位)
    input  [31:0] B,          // 输入操作数 B
    input  [3:0]  ALU_Control,// 控制信号
    output reg [31:0] Result, // 计算结果
    output        Zero        // 零标志位 (Result == 0 时为 1)
);

    always @(*) begin
        case (ALU_Control)
            4'b0000: Result = A & B;       // AND
            4'b0001: Result = A | B;       // OR
            4'b0010: Result = A + B;       // ADD
            4'b0110: Result = A - B;       // SUB
            4'b0111: Result = A < B ? 1 : 0; // SLT (Set Less Than)
            default: Result = 32'b0;
        endcase
    end

    assign Zero = (Result == 0);

endmodule