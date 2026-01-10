`timescale 1ns / 1ps

//=============================================================================
// Module:      alu
// Description: 4-bit Arithmetic Logic Unit (ALU).
//              Performs basic arithmetic and logic operations based on op code.
//=============================================================================

module alu (
    input  wire [3:0] a,    // Operand A
    input  wire [3:0] b,    // Operand B
    input  wire [1:0] op,   // Operation Selection Code
    output reg  [3:0] res   // Result Output
);

    //=========================================================================
    // ALU Logic Description
    //=========================================================================
    // Operation Table:
    // 2'b00: ADD (A + B)
    // 2'b01: SUB (A - B)
    // 2'b10: AND (A & B)
    // 2'b11: OR  (A | B)

    always @(*) begin
        // Initialize result to default value to prevent latch generation
        res = 4'b0000; 
        
        case(op)
            2'b00: res = a + b;     // Arithmetic Addition (Note: Carry bit is truncated)
            2'b01: res = a - b;     // Arithmetic Subtraction
            2'b10: res = a & b;     // Bitwise AND
            2'b11: res = a | b;     // Bitwise OR
            default: res = 4'b0000; // Safety fallback
        endcase
    end

endmodule