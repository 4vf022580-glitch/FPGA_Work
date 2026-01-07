module uart_rx #(
    parameter CLK_FREQ = 100_000_000, 
    parameter BAUD_RATE = 115200
)(
    input clk,
    input rst,          // 修正：统一命名为 rst，高电平复位
    input rx,
    output reg [7:0] data_out,
    output reg done
);
    localparam CYCLE = CLK_FREQ / BAUD_RATE;
    
    reg [15:0] cnt;
    reg [3:0] bit_cnt;
    reg rx_d1, rx_d2;
    reg active;
    wire start_bit; 

    // 逻辑审计：UART 起始位是下降沿 (1 -> 0)
    assign start_bit = (rx_d2 == 1 && rx_d1 == 0); 

    // 1. 同步异步信号，防止亚稳态
    always @(posedge clk) begin
        {rx_d2, rx_d1} <= {rx_d1, rx};
    end

    // 2. 接收状态机逻辑
    always @(posedge clk or posedge rst) begin // 修正：适配高电平复位
        if (rst) begin
            cnt <= 0; 
            bit_cnt <= 0; 
            done <= 0; 
            active <= 0;
            data_out <= 0;
        end else begin
            done <= 0; 
            if (!active && start_bit) begin
                active <= 1; 
                cnt <= 0; 
                bit_cnt <= 0;
            end else if (active) begin
                if (cnt == CYCLE - 1) begin
                    cnt <= 0;
                    if (bit_cnt == 8) begin // 停止位结束
                        active <= 0; 
                        done <= 1;
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end else begin
                    cnt <= cnt + 1;
                    // 在比特位中间采样 (数据位 1-8)
                    if (cnt == CYCLE / 2 && bit_cnt > 0 && bit_cnt <= 8) begin
                        data_out[bit_cnt-1] <= rx_d2;
                    end
                end
            end
        end
    end
endmodule