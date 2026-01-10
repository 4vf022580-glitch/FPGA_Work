//================================================================================
// Module Name:    uart_rx
// Description:    通用异步收发传输器 - 接收端 (Universal Asynchronous Receiver)
//                 负责将串行输入解调为并行数据。
//
// Key Logic:      1. 下降沿检测 (Falling Edge Detect) 识别 Start Bit。
//                 2. 中心对齐采样 (Center Sampling) 确保数据准确。
//                 3. 双级同步 (Double Flop) 消除亚稳态。
//================================================================================

module uart_rx #(
    parameter CLK_FREQ  = 50_000_000, 
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,    // 低电平复位
    input  wire       rx,       // 串行数据输入
    output reg  [7:0] data_out,
    output reg        done      // 接收完成标志
);

    //----------------------------------------------------------------------------
    // 参数计算 (Parameter Calculation)
    //----------------------------------------------------------------------------
    localparam CYCLE = CLK_FREQ / BAUD_RATE;

    //----------------------------------------------------------------------------
    // 内部寄存器 (Internal Registers)
    //----------------------------------------------------------------------------
    reg [15:0] cnt;          // 波特率计数器
    reg [3:0]  bit_cnt;      // 比特索引 (0-8)
    reg        rx_d1, rx_d2; // 同步寄存器
    reg        active;       // 状态标志
    wire       start_bit;

    //============================================================================
    // 1. 信号同步 (Synchronization)
    //============================================================================
    // 外部异步信号 rx 必须打两拍，防止亚稳态 (Metastability) 传播进核心逻辑。
    always @(posedge clk) begin
        {rx_d2, rx_d1} <= {rx_d1, rx};
    end

    //============================================================================
    // 2. 边沿检测 (Edge Detection) - [CRITICAL FIX]
    //============================================================================
    // UART 协议规定：空闲(1) -> 起始(0)。
    // 必须检测下降沿 (Falling Edge): Old(1) -> New(0)
    assign start_bit = (rx_d2 == 1 && rx_d1 == 0); 

    //============================================================================
    // 3. 主状态机 (Main FSM)
    //============================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 异步复位 (Active Low)
            cnt      <= 0; 
            bit_cnt  <= 0; 
            done     <= 0; 
            active   <= 0;
            data_out <= 0;
        end 
        // IDLE -> START: 检测到下降沿
        else if (!active && start_bit) begin
            active  <= 1;
            cnt     <= 0;   // 立即对齐时序
            bit_cnt <= 0;
        end 
        // RECEIVING: 接收数据中
        else if (active) begin
            if (cnt == CYCLE - 1) begin
                cnt <= 0;
                // 接收完 8 位数据 (位索引达到 8)
                if (bit_cnt == 8) begin
                    active <= 0; // 返回 IDLE
                    done   <= 1; // 产生完成脉冲
                end else begin
                    bit_cnt <= bit_cnt + 1;
                end
            end else begin
                cnt <= cnt + 1;
                done <= 0; // 维持 done 为单周期脉冲
                
                // --- 中心采样 (Center Sampling) ---
                // 在波形周期的 50% 处采样，避开边沿噪声。
                
                if (cnt == CYCLE / 2) begin
                    if (bit_cnt > 0 && bit_cnt <= 8) begin
                        data_out[bit_cnt-1] <= rx_d2;
                    end
                end
            end
        end 
        else begin
            done <= 0;
        end
    end
endmodule