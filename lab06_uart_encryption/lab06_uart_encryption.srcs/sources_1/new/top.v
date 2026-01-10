module top #(
    // 参数化设计：统一管理系统时钟和波特率
    parameter CLK_FREQ  = 100_000_000, 
    parameter BAUD_RATE = 115200
)
(
    input  clk,
    input  rst,         // 高电平复位 (Active High)
    input  rx_line,     // 串口接收引脚 (来自 PC)
    input  sw_encrypt,  // 模式开关: 1=加密模式, 0=透传回环
    output tx_line      // 串口发送引脚 (发往 PC)
);

    // --- 内部信号定义 (Internal Signals) ---
    wire [7:0] rx_data;       // 接收到的原始数据 (Plaintext)
    wire       rx_done;       // 接收完成脉冲 (同步信号)
    wire [7:0] key_byte;      // LFSR 生成的伪随机密钥 (Key)
    wire [7:0] cipher_data;   // 加密后的密文 (Ciphertext)
    wire [7:0] tx_data_final; // 最终要发送的数据

    // 1. 串口接收前端
    // 负责把串行信号解调成 8 位并行数据
    uart_rx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) ) u_uart_rx (
        .clk(clk), .rst(rst), .rx(rx_line), .data_out(rx_data), .done(rx_done)
    );

    // 2. 加密内核 (LFSR)
    // 关键逻辑：用 rx_done 作为使能信号 (Enable)。
    // 只有当收到了一个新数据时，密钥才更新一次，保证“同步加密”。
    lfsr u_lfsr (
        .clk(clk), .rst(rst), .en(rx_done), .data_out(key_byte)
    );

    // --- 数据处理通路 ---
    
    // 加密算法：异或运算 (Stream Cipher Logic)
    // 原理：A ^ B = C (加密), C ^ B = A (解密)
    assign cipher_data = rx_data ^ key_byte;
    
    // 旁路模式选择 (Bypass Mux)
    // sw_encrypt = 1: 发送密文
    // sw_encrypt = 0: 直接把收到的数据发回去 (用于测试通信是否正常)
    assign tx_data_final = sw_encrypt ? cipher_data : rx_data;

    // 3. 串口发送后端
    // 收到 rx_done 信号后，立刻启动发送
    uart_tx #( .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE) ) u_uart_tx (
        .clk(clk), .rst(rst), .tx_en(rx_done), .data_in(tx_data_final), .tx(tx_line), .ready()
    );

endmodule