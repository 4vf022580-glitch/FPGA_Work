module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input rst,          // 修正：统一命名为 rst，高电平复位
    input [7:0] data_in,
    input tx_en,
    output reg tx,
    output reg ready
);
    localparam CYCLE = CLK_FREQ / BAUD_RATE;
    reg [15:0] cnt;
    reg [3:0] bit_cnt;
    reg [7:0] data_reg;

    always @(posedge clk or posedge rst) begin // 修正：适配高电平复位
        if (rst) begin
            tx <= 1; cnt <= 0; bit_cnt <= 0; ready <= 1;
        end else if (ready && tx_en) begin
            ready <= 0; data_reg <= data_in; cnt <= 0; bit_cnt <= 0;
        end else if (!ready) begin
            if (cnt == CYCLE - 1) begin
                cnt <= 0;
                if (bit_cnt == 9) ready <= 1;
                else bit_cnt <= bit_cnt + 1;
            end else begin
                cnt <= cnt + 1;
                case (bit_cnt)
                    0: tx <= 0; // 起始位
                    1,2,3,4,5,6,7,8: tx <= data_reg[bit_cnt-1];
                    9: tx <= 1; // 停止位
                    default: tx <= 1;
                endcase
            end
        end
    end
endmodule