module uart_tx #(
    // 参数化设计：根据时钟频率和波特率自动计算参数
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  clk,
    input  rst,         // 高电平复位
    input  [7:0] data_in, // 要发送的 8 位并行数据
    input  tx_en,       // 发送使能信号 (脉冲)
    output reg tx,      // 串口发送线 (平时维持高电平)
    output reg ready    // 握手信号：1=空闲(可以发送)，0=忙(正在发送)
);
    // 计算传输一位需要多少个时钟周期
    localparam CYCLE = CLK_FREQ / BAUD_RATE;

    reg [15:0] cnt;      // 波特率计数器
    reg [3:0]  bit_cnt;  // 当前发送到了第几位 (0-9)
    reg [7:0]  data_reg; // 内部数据缓存 (防止发送途中 data_in 变化)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 复位时，UART 协议规定 TX 线必须拉高 (空闲态)
            tx <= 1; 
            cnt <= 0; 
            bit_cnt <= 0; 
            ready <= 1; // 复位后默认是空闲的
        end 
        // --- 启动发送 (Handshake) ---
        // 如果当前是空闲状态 (ready)，并且收到了发送指令 (tx_en)
        else if (ready && tx_en) begin
            ready <= 0;          // 拉低 ready，告诉外部“我很忙，别打扰”
            data_reg <= data_in; // 锁存数据 (Latch)，防止外部数据突变
            cnt <= 0; 
            bit_cnt <= 0;
        end 
        // --- 发送过程中 (Serialization) ---
        else if (!ready) begin
            if (cnt == CYCLE - 1) begin
                cnt <= 0;
                // 如果发完了停止位 (第9位)
                if (bit_cnt == 9) begin
                    ready <= 1; // 恢复空闲状态
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end else begin
                cnt <= cnt + 1;
                
                // --- 并转串输出逻辑 ---
                // 根据当前发送的进度 (bit_cnt) 决定 TX 线的高低电平
                
                case (bit_cnt)
                    0: tx <= 0; // 起始位 (Start Bit)：强制拉低
                    
                    // 数据位：依次发送 bit 0 到 bit 7 (LSB First)
                    // 注意：bit_cnt 是 1~8，对应 data_reg 的 0~7
                    1,2,3,4,5,6,7,8: tx <= data_reg[bit_cnt-1];
                    
                    9: tx <= 1; // 停止位 (Stop Bit)：强制拉高
                    
                    default: tx <= 1; // 默认维持高电平保护
                endcase
            end
        end
    end
endmodule