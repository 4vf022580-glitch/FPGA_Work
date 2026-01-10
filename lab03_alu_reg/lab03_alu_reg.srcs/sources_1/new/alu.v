module alu(
    input [3:0] a,
    input [3:0] b,
    input [1:0] op,
    output reg [3:0] out // 正确：组合逻辑 always 块中必须用 reg
);

    always @(*) begin
        case(op)
            2'b00: out = a + b; // 加法
            2'b01: out = a - b; // 减法
            2'b10: out = a & b; // 与
            2'b11: out = a | b; // 或
            default: out = 4'b0000; // 正确：防止产生 Latch 的默认赋值
        endcase
    end

endmodule