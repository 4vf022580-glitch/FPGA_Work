module alu(
    input [3:0] a,
    input [3:0] b,
    input [1:0] op,
    output reg [3:0] out // 在 always 块里赋值必须定义为 reg
);

    always @(*) begin
        case(op)
            2'b00: out = a + b; // 加法
            2'b01: out = a - b; // 减法
            2'b10: out = a & b; // 按位与
            2'b11: out = a | b; // 按位或
            default: out = 4'b0000;
        endcase
    end

endmodule