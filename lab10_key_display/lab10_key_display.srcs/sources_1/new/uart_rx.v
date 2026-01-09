module uart_rx #(
    // 参数化设计：允许灵活修改系统主频和波特率
    // Parameterized for different clock speeds and baud rates
    parameter CLK_FREQ = 100_000_000, 
    parameter BAUD_RATE = 115200
)(
    input  clk,
    input  rst,
    input  rx,          // 外部串口输入信号 (异步)
    output reg [7:0] data_out, // 接收到的 8 位数据
    output reg done     // 接收完成标志 (一个时钟周期的脉冲)
);
    // 计算传输一位需要计数多少个时钟周期
    // Calculate clock cycles per bit
    localparam CYCLE = CLK_FREQ / BAUD_RATE;
    
    reg [15:0] cnt;      // 波特率计数器
    reg [3:0]  bit_cnt;  // 当前接收到的比特位索引 (0-8)
    reg rx_d1, rx_d2;    // 同步寄存器
    reg active;          // 状态标志：1 = 正在接收, 0 = 空闲
    wire start_bit; 

    // --- 信号同步逻辑 (Synchronization) ---
    // 外部输入的 rx 信号相对于系统时钟是异步的。
    // 使用双级寄存器打拍，防止亚稳态 (Metastability) 导致系统不稳定。
    
    always @(posedge clk) begin
        {rx_d2, rx_d1} <= {rx_d1, rx};
    end

    // --- 下降沿检测 (Edge Detection) ---
    // 检测起始位 (Start Bit)：信号从高电平变为低电平
    assign start_bit = (rx_d2 == 1 && rx_d1 == 0); 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 复位所有状态
            cnt <= 0; 
            bit_cnt <= 0; 
            done <= 0; 
            active <= 0;
            data_out <= 0;
        end else begin
            done <= 0; // 默认拉低，确保 done 信号只持续一个周期
            
            // 状态：空闲 -> 检测到起始位
            if (!active && start_bit) begin
                active <= 1;    // 进入接收状态
                cnt <= 0;       // 清零计数器，准备对齐时间轴
                bit_cnt <= 0;
            end 
            // 状态：正在接收数据
            else if (active) begin
                // 一个波特率周期结束
                if (cnt == CYCLE - 1) begin
                    cnt <= 0;
                    // 判断是否接收完 8 位数据
                    if (bit_cnt == 8) begin
                        active <= 0; // 回到空闲状态
                        done <= 1;   // 输出完成脉冲
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end else begin
                    cnt <= cnt + 1;
                    
                    // --- 中心采样逻辑 (Center Sampling) ---
                    // 在波特率周期的中间点 (50%) 进行采样。
                    // 这样可以避开信号边沿的抖动，读取的数据最稳定。
                    
                    if (cnt == CYCLE / 2 && bit_cnt > 0 && bit_cnt <= 8) begin
                        // 将串行数据移位存入寄存器 (LSB 先行)
                        data_out[bit_cnt-1] <= rx_d2;
                    end
                end
            end
        end
    end
endmodule