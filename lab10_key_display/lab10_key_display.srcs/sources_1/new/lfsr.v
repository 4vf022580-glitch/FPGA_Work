module lfsr (
    input  wire clk,
    input  wire rst,
    input  wire en,          // 使能信号 (通常接串口接收完成信号 done)
    output wire [7:0] data_out
);
    reg [7:0] r_lfsr;
    wire feedback;

    // --- 核心算法：反馈逻辑 ---
    // 依据数学上的“本原多项式”选取抽头：x^8 + x^6 + x^5 + x^4 + 1
    // 选取第 7, 5, 4, 3 位进行异或运算。
    // 目的：保证产生的随机数序列最长，周期能达到 255 (即遍历除0以外的所有数)。
    
    assign feedback = r_lfsr[7] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // --- 复位逻辑 (防死锁) ---
            // 警告：这里绝不能复位为 0！
            // 如果初始值是 0x00，那么 0 异或 0 永远是 0，系统会彻底卡死 (死锁状态)。
            // 所以必须给一个非零的“种子” (Seed)，比如 0xFF。
            r_lfsr <= 8'hFF;
        end
        else if (en) begin
            // --- 移位更新 ---
            // 整体向左移动一位，丢弃最高位，
            // 然后把算出来的 feedback (反馈值) 填补到最低位。
            r_lfsr <= {r_lfsr[6:0], feedback};
        end
    end

    // 将内部寄存器的值输出，作为加密用的密钥
    assign data_out = r_lfsr;

endmodule