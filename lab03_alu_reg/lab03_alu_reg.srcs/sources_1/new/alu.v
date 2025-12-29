// synthesis verilog_input_version verilog_2001
module alu (
    input [3:0] a,
    input [3:0] b,
    input [1:0] op,
    output reg [3:0] res
);

    always @(*) begin
        res = 4'b0000;
        
        case(op)
            2'b00: res = a + b;    
            2'b01: res = a - b;        
            2'b10: res = a & b;       
            2'b11: res = a | b;    
            default: res = 4'b0000;   
        endcase
    end

endmodule