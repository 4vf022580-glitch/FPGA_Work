//================================================================================
// Module Name:    dff
// Description:    4-bit D 触发器 (D Flip-Flop)
//                 基本时序逻辑单元，用于数据打拍或状态存储。
//
// Key Feature:    同步复位 (Synchronous Reset)
//                 复位操作仅在时钟上升沿生效，可防止复位信号毛刺(Glitch)误触发。
//================================================================================

module dff(
    input  wire       clk,  // 系统时钟
    input  wire       rst,  // 同步复位 (Active High)
    input  wire [3:0] d,    // 数据输入 (Next State)
    output reg  [3:0] q     // 数据输出 (Current State)
);

    //============================================================================
    // 时序逻辑 (Sequential Logic)
    //============================================================================
    // 注意：敏感列表中只有 clk，没有 rst。
    // 这意味着复位行为必须等待时钟上升沿到来才能执行 (同步复位)。
    always @(posedge clk) begin
        if (rst) begin
            q <= 4'b0000; // 复位清零
        end
        else begin
            q <= d;       // 数据锁存 (Latch Data)
        end
    end

endmodule