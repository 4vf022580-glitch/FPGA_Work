module uart_rx #(
    // 参数化设计：方便以后修改主频和波特率
    parameter CLK_FREQ = 100_000_000, 
    parameter BAUD_RATE = 115200
)(
    input  clk,
    input  rst,         // 高电平复位
    input  rx,          // 外部串口输入 (异步信号)
    output reg [7:0] data_out,
    output reg done     // 接收完成标志
);
    // 计算传输一位需要计数多少个周期
    localparam CYCLE = CLK_FREQ / BAUD_RATE;
    
    reg [15:0] cnt;      // 波特率计数器
    reg [3:0]  bit_cnt;  // 记录接收到了第几位
    reg rx_d1, rx_d2;    // 同步寄存器
    reg active;          // 状态：是否正在接收
    wire start_bit; 

    // --- 信号同步 (关键步骤) ---
    // 外部信号 rx 相对于系统时钟是异步的，直接使用可能导致错误。
    // 使用两级寄存器打拍，是为了消除“亚稳态 (Metastability)”的影响。
    always @(posedge clk) begin
        {rx_d2, rx_d1} <= {rx_d1, rx};
    end

    // 检测下降沿：识别起始位 (Start Bit)
    // 逻辑：上一拍是高电平，当前拍是低电平
    assign start_bit = (rx_d2 == 1 && rx_d1 == 0); 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 0; 
            bit_cnt <= 0; 
            done <= 0; 
            active <= 0;
            data_out <= 0;
        end else begin
            done <= 0; 
            
            // 状态机：空闲 -> 检测到起始位
            if (!active && start_bit) begin
                active <= 1;    // 启动接收
                cnt <= 0;       // 计数器清零，准备对齐
                bit_cnt <= 0;
            end 
            // 状态机：接收数据中
            else if (active) begin
                if (cnt == CYCLE - 1) begin
                    cnt <= 0;
                    // 判断是否接收完 8 个数据位
                    if (bit_cnt == 8) begin
                        active <= 0; // 接收结束
                        done <= 1;   // 产生完成脉冲
                    end else begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end else begin
                    cnt <= cnt + 1;
                    
                    // --- 中心采样逻辑 ---
                    // 在波特率周期的中间点 (50%处) 读取数据。
                    // 这样可以避开信号边沿可能的抖动，读数最稳定。
                    
                    if (cnt == CYCLE / 2 && bit_cnt > 0 && bit_cnt <= 8) begin
                        data_out[bit_cnt-1] <= rx_d2; // 移位保存数据 (LSB先行)
                    end
                end
            end
        end
    end
endmodule