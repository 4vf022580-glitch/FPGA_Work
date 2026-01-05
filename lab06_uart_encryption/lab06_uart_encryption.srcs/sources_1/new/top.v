module top #(
    parameter CLK_FREQ  = 100_000_000, 
    parameter BAUD_RATE = 115200
)
(
    input  clk,         // 物理引脚: W5
    input  rst,         // 物理引脚: U18 (高电平复位：按下为1，松开为0)
    input  rx_line,     // 物理引脚: B18
    input  sw_encrypt,  // 物理引脚: V17
    output tx_line      // 物理引脚: A18
);

    wire [7:0] rx_data;
    wire       rx_done;
    wire [7:0] key_byte;
    wire [7:0] cipher_data;
    wire [7:0] tx_data_final;

    // 1. 串口接收：必须确保子模块内部是 always @(posedge clk or posedge rst)
    uart_rx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) ) u_uart_rx (
        .clk(clk), .rst(rst), .rx(rx_line), .data_out(rx_data), .done(rx_done)
    );

    // 2. LFSR 加密
    lfsr u_lfsr (
        .clk(clk), .rst(rst), .en(rx_done), .data_out(key_byte)
    );

    assign cipher_data = rx_data ^ key_byte;
    assign tx_data_final = sw_encrypt ? cipher_data : rx_data;

    // 3. 串口发送
    uart_tx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) ) u_uart_tx (
        .clk(clk), .rst(rst), .tx_en(rx_done), .data_in(tx_data_final), .tx(tx_line), .ready()
    );

endmodule