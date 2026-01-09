`timescale 1ns / 1ps

//=============================================================================
// 模块名称：top
// 项目名称：FPGA UART Loopback with XOR Encryption
// 硬件平台：Digilent Basys3 (Artix-7)
// 功能描述：
//    1. 接收 PC 端通过 UART 发送的 8 位数据。
//    2. 使用 LFSR 生成的伪随机数作为密钥，对数据进行异或 (XOR) 加密。
//    3. 通过拨动开关 (sw_encrypt) 选择发送“原始数据”或“加密数据”回 PC。
//    4. 数码管实时显示接收到的数据 (高2位) 和当前的密钥 (低2位)。
//=============================================================================

module top #(
    parameter CLK_FREQ  = 100_000_000, // 系统时钟频率
    parameter BAUD_RATE = 115200       // UART 通信波特率
)
(
    //-------------------------------------------------------------------------
    // 物理接口定义 (Physical Interface)
    //-------------------------------------------------------------------------
    input        clk,        // 系统时钟 (Pin W5)
    input        rst,        // 全局复位 (Pin U18, High Active)
    input        rx_line,    // UART 接收端 (Pin B18, 来自 USB-TTL)
    input        sw_encrypt, // 加密模式控制开关 (Pin V17, 1=Encrypt, 0=Bypass)
    
    output       tx_line,    // UART 发送端 (Pin A18, 去往 USB-TTL)
    output [3:0] an,         // 数码管位选信号
    output [6:0] seg         // 数码管段选信号
);

    //-------------------------------------------------------------------------
    // 内部信号声明 (Internal Signals)
    //-------------------------------------------------------------------------
    wire [7:0] rx_data;       // 接收到的 8-bit 数据
    wire       rx_done;       // 接收完成脉冲信号 (Pulse)
    wire [7:0] key_byte;      // LFSR 生成的 8-bit 密钥
    wire [7:0] cipher_data;   // 加密后的数据 (XOR 结果)
    wire [7:0] tx_data_final; // 最终送入 TX 模块的数据 (经过 MUX 选择)

    //=========================================================================
    // 1. UART 接收模块 (Receiver Instance)
    //=========================================================================
    // 负责将串行信号解串为并行数据 rx_data，并产生 rx_done 脉冲
    uart_rx #( 
        .CLK_FREQ(CLK_FREQ), 
        .BAUD_RATE(BAUD_RATE) 
    ) u_uart_rx (
        .clk      (clk), 
        .rst      (rst), 
        .rx       (rx_line), 
        .data_out (rx_data), 
        .done     (rx_done)
    );

    //=========================================================================
    // 2. 密钥生成与加密逻辑 (Encryption Core)
    //=========================================================================
    // 实例化 LFSR 模块：仅在接收到新数据时 (rx_done) 更新密钥，实现流密码流转
    lfsr u_lfsr (
        .clk      (clk), 
        .rst      (rst), 
        .en       (rx_done),  // 使能信号：每收到一个字节，密钥更新一次
        .data_out (key_byte)
    );

    // 组合逻辑加密：利用异或门 (XOR) 特性进行对称加密
    // Logic: Cipher = PlainText ^ Key
    assign cipher_data = rx_data ^ key_byte;

    // 数据选择器 (Multiplexer)：根据开关状态决定回传内容
    // sw_encrypt = 1: 回传密文; sw_encrypt = 0: 回传明文 (Loopback Test)
    assign tx_data_final = sw_encrypt ? cipher_data : rx_data;

    //=========================================================================
    // 3. UART 发送模块 (Transmitter Instance)
    //=========================================================================
    // 当接收完成 (rx_done) 时，立即触发发送逻辑，将处理后的数据发回 PC
    uart_tx #( 
        .CLK_FREQ(CLK_FREQ), 
        .BAUD_RATE(BAUD_RATE) 
    ) u_uart_tx (
        .clk      (clk), 
        .rst      (rst), 
        .tx_en    (rx_done),       // 握手信号：利用接收完成信号触发发送
        .data_in  (tx_data_final), 
        .tx       (tx_line), 
        .ready    ()               // 环回模式下忽略 ready 信号
    );

    //=========================================================================
    // 4. 状态显示模块 (Visual Debugging)
    //=========================================================================
    // 数码管显示内容拼接：高 8 位显示接收数据，低 8 位显示当前密钥
    // Display Format: [ RX_DATA_H | RX_DATA_L | KEY_H | KEY_L ]
    seven_seg_drive u_display (
        .clk      (clk),
        .rst      (rst),
        .data_in  ( {rx_data, key_byte} ), // 拼接 16 位数据用于显示
        .an       (an),
        .seg      (seg)
    );

endmodule