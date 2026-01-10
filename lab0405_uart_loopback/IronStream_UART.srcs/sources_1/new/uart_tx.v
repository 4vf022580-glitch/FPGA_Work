//================================================================================
// Module Name:    uart_tx
// Description:    UART 发送模块 (Parallel to Serial)
//                 负责将 8位并行数据 转换为符合 UART 协议的 串行比特流。
//
// Key Features:   1. 参数化设计 (支持 50MHz/115200 等任意组合)
//                 2. 数据锁存机制 (防止发送过程中输入突变)
//                 3. 握手信号 (Ready/Valid) 机制
//================================================================================

module uart_tx #(
    // 参数化配置：方便移植到不同频率的开发板
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,   // 低电平复位 (Active Low)
    input  wire [7:0] data_in, // 待发送数据 (并行)
    input  wire       tx_en,   // 发送使能脉冲
    output reg        tx,      // 串行发送线 (Idle High)
    output reg        ready    // 状态标志: 1=空闲(可发), 0=忙(正在发)
);

    // 计算传输一位需要计数多少个时钟周期
    localparam CYCLE = CLK_FREQ / BAUD_RATE;

    reg [15:0] cnt;       // 波特率计数器
    reg [3:0]  bit_cnt;   // 当前发送到了第几位 (0-9)
    reg [7:0]  data_reg;  // 内部数据缓存 (Data Buffer)

    always @(posedge clk or negedge rst_n) begin
        // --- 异步复位 ---
        if (!rst_n) begin
            tx      <= 1; // 关键：复位时必须拉高 TX (保持空闲态)
            cnt     <= 0; 
            bit_cnt <= 0; 
            ready   <= 1; // 复位后默认是空闲的，允许接收请求
        end 
        
        // --- 握手启动 (Handshake Start) ---
        // 条件：模块空闲 (ready) 且 收到发送请求 (tx_en)
        else if (ready && tx_en) begin
            ready    <= 0;       // 拉低标志，告诉外界“我很忙”
            data_reg <= data_in; // 关键：锁存数据 (Latch Data)
                                 // 即使 data_in 后面变了，也不影响本次发送
            cnt      <= 0; 
            bit_cnt  <= 0;
        end 
        
        // --- 串行化过程 (Serialization) ---
        else if (!ready) begin
            // 波特率计时控制
            if (cnt == CYCLE - 1) begin
                cnt <= 0;
                // 判断是否发完停止位 (第9位)
                if (bit_cnt == 9) begin
                    ready <= 1; // 发送结束，恢复空闲
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end else begin
                cnt <= cnt + 1;
                
                // --- 比特流输出逻辑 ---
                // 根据当前进度 (bit_cnt) 控制 TX 电平
                
                case (bit_cnt)
                    0: tx <= 0; // 起始位 (Start Bit): 拉低总线
                    
                    // 数据位 (Data Bits): LSB First (低位先发)
                    // bit_cnt=1 对应 data_reg[0], 以此类推
                    1,2,3,4,5,6,7,8: tx <= data_reg[bit_cnt-1];
                    
                    9: tx <= 1; // 停止位 (Stop Bit): 拉高总线表示结束
                    
                    default: tx <= 1; // 默认保护：维持高电平
                endcase
            end
        end
    end
endmodule