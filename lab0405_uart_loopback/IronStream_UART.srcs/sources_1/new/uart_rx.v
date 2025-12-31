module uart_rx #(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input clk,
    input rst_n,
    input rx,
    output reg [7:0] data_out,
    output reg done
);
    localparam CYCLE = CLK_FREQ / BAUD_RATE;
    reg [15:0] cnt;
    reg [3:0] bit_cnt;
    reg rx_d1, rx_d2;
    reg active;

wire start_bit = rx_d2 == 0 && rx_d1 == 1; // 检测下降沿
    // 异步信号同步，防止亚稳态
    always @(posedge clk) {rx_d2, rx_d1} <= {rx_d1, rx};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0; bit_cnt <= 0; done <= 0; active <= 0;
        end else if (!active && start_bit) begin
            active <= 1; cnt <= 0; bit_cnt <= 0;
        end else if (active) begin
            if (cnt == CYCLE - 1) begin
                cnt <= 0;
                if (bit_cnt == 8) begin // 停止位
                    active <= 0; done <= 1;
                end else bit_cnt <= bit_cnt + 1;
            end else begin
                cnt <= cnt + 1;
                done <= 0;
                if (cnt == CYCLE / 2) // 在比特中间采样
                    if (bit_cnt > 0 && bit_cnt <= 8) data_out[bit_cnt-1] <= rx_d2;
            end
        end else done <= 0;
    end
endmodule