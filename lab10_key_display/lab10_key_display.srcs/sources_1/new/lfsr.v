module lfsr (
    input clk,
    input rst,          // 修正：统一命名为 rst，高电平复位
    input en,           // 由顶层的 rx_done 驱动
    output [7:0] data_out
);
    reg [7:0] r_lfsr;
    wire feedback;
    
    // 8位 LFSR 的标准多项式反馈逻辑
    assign feedback = r_lfsr[7] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3];

    always @(posedge clk or posedge rst) begin // 修正：适配高电平复位
        if (rst) begin
            r_lfsr <= 8'hFF; // 初始种子，禁止为全0
        end
        else if (en) begin  // 只有在接收到一个完整字节（rx_done）时才更新密钥
            r_lfsr <= {r_lfsr[6:0], feedback};
        end
    end
    assign data_out = r_lfsr;
endmodule