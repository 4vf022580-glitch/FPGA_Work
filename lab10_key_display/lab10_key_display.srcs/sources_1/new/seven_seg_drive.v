`timescale 1ns / 1ps

module seven_seg_drive(
    input             clk,      // 100MHz 系统时钟
    input             rst,      // 高电平复位
    input      [15:0] data_in,  // 要显示的16位数据 (例如: 16'h00BE)
    output reg [3:0]  an,       // 4位位选信号 (控制哪一个数码管亮)
    output reg [6:0]  seg       // 7位段选信号 (控制显示什么字符 g~a)
);

    //==================================================
    // 1. 分频器：产生扫描时钟
    //==================================================
    // 我们需要约 1kHz 的刷新率。100MHz / 100000 = 1kHz
    // 计数器计数到 100,000 需要约 17 位 (2^17 = 131072)
    
    reg [19:0] refresh_counter; // 20位足以覆盖
    wire [1:0] scan_idx;        // 用于选择当前点亮第几个数码管 (0-3)

    always @(posedge clk or posedge rst) begin
        if (rst) 
            refresh_counter <= 0;
        else 
            refresh_counter <= refresh_counter + 1;
    end

    // 取高 2 位作为扫描索引，这样切换速度刚好人眼看着舒适
    // refresh_counter[19:18] 大约每 2.6ms 切换一次
    assign scan_idx = refresh_counter[19:18];


    //==================================================
    // 2. 动态扫描：位选控制 (Active Low)
    //==================================================
    reg [3:0] hex_digit; // 当前要显示的那个十六进制数字 (0-F)

    always @(*) begin
        case (scan_idx)
            2'b00: begin
                an = 4'b1110;           // 激活最右边的数码管 (Digit 0)
                hex_digit = data_in[3:0];
            end
            2'b01: begin
                an = 4'b1101;           // 激活 Digit 1
                hex_digit = data_in[7:4];
            end
            2'b10: begin
                an = 4'b1011;           // 激活 Digit 2
                hex_digit = data_in[11:8];
            end
            2'b11: begin
                an = 4'b0111;           // 激活最左边的数码管 (Digit 3)
                hex_digit = data_in[15:12];
            end
            default: begin
                an = 4'b1111;           // 全部熄灭
                hex_digit = 4'b0000;
            end
        endcase
    end


    //==================================================
    // 3. 段码译码：Hex to 7-Segment (Active Low)
    //==================================================
    // Basys3 是共阳极：0 是亮，1 是灭
    // 顺序对应: {g, f, e, d, c, b, a}
    
    always @(*) begin
        case (hex_digit)
            4'h0: seg = 7'b1000000; // 显示 0
            4'h1: seg = 7'b1111001; // 显示 1
            4'h2: seg = 7'b0100100; // 显示 2
            4'h3: seg = 7'b0110000; // 显示 3
            4'h4: seg = 7'b0011001; // 显示 4
            4'h5: seg = 7'b0010010; // 显示 5
            4'h6: seg = 7'b0000010; // 显示 6
            4'h7: seg = 7'b1111000; // 显示 7
            4'h8: seg = 7'b0000000; // 显示 8
            4'h9: seg = 7'b0010000; // 显示 9
            4'hA: seg = 7'b0001000; // 显示 A
            4'hB: seg = 7'b0000011; // 显示 b (小写以区别 8)
            4'hC: seg = 7'b1000110; // 显示 C
            4'hD: seg = 7'b0100001; // 显示 d (小写以区别 0)
            4'hE: seg = 7'b0000110; // 显示 E
            4'hF: seg = 7'b0001110; // 显示 F
            default: seg = 7'b1111111; // 全灭
        endcase
    end

endmodule