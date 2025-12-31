module top(
    input clk,
    input rst_n,    // 低电平复位
    input uart_rx,  // 外部数据进来
    output uart_tx  // 数据原样发回去
);

    wire [7:0] data_loop; // 内部数据线：把 RX 的嘴连到 TX 的耳朵
    wire rx_done_sig;     // 内部控制线：RX 说"收到了"，TX 就"开始发"

    // 1. 实例化接收模块 (耳朵)
    uart_rx #(
        .CLK_FREQ(50_000_000), // 如果你的时钟不是50M，请在这里改
        .BAUD_RATE(115200)
    ) u_rx (
        .clk(clk), 
        .rst_n(rst_n), 
        .rx(uart_rx),
        .data_out(data_loop), // 吐出数据
        .done(rx_done_sig)    // 吐出"完成"信号
    );

    // 2. 实例化发送模块 (嘴巴)
    uart_tx #(
        .CLK_FREQ(50_000_000), 
        .BAUD_RATE(115200)
    ) u_tx (
        .clk(clk), 
        .rst_n(rst_n), 
        .tx(uart_tx),
        .data_in(data_loop),  // 吃进刚才吐出的数据
        .tx_en(rx_done_sig),  // 一旦 RX 收完，TX 立刻发
        .ready()              // 悬空不接，不管它忙不忙
    );

endmodule