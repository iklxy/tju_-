`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/25 10:56:12
// Design Name: 
// Module Name: display7
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//这里的CLK代表时钟信号 将被送入Divider模块进行分频
//Data代表输入的数据信号
//SEG代表段选信号 因为一个数字由7段灯管组成
//SHIFT代表移位信号 因为开发板上有8个数码管
//DOT用于输出小数点
module display7(
    input CLK,
    input [15:0] Data,
    input [2:0] current,   // 新增：当前歌曲号 (来自 top 里的控制逻辑)
    input [15:0] vol,      // 新增：当前音量 (来自 top 里的控制逻辑)
    output reg [6:0] SEG,
    output reg [7:0] SHIFT,
    output reg DOT
    );
    wire REAL_CLK;//真实使用的时钟信号
    Divider #(.N(200000)) CLKDIV (
        .I_CLK(CLK), 
        .rst(1'b0),     // 必须给复位信号一个低电平，否则cnt可能是红线(未知态)
        .O_CLK(REAL_CLK) 
    );//送入时钟进行分频
    reg [31:0] Time;//时间
    reg [4:0] cnt;
    initial begin
        SHIFT = 8'b01111111;//点亮低电平位
        cnt=0;
        Time=0;
     end
     
    always @ (posedge REAL_CLK) begin 
            SHIFT <= {SHIFT[6:0], SHIFT[7]};
            cnt <= cnt+4;
            // flash the DOT
            if(SHIFT[1]==0) DOT <= 0;//如果轮到第二位数码管亮灯 则让小数点也亮灯
            else DOT <= 1;//否则把Dot位拉高 让小数点熄灭
            // time format 
            Time[3: 0] <= Data%10;
            Time[7: 4] <= (Data/10)%6;
            Time[11: 8] <= (Data/60)%10;
            Time[15: 12] <= Data/600;
            //数码管8 (最左边): 歌曲号 (为了符合习惯，我们让它显示 1-4 而不是 0-3)
             Time[31: 28] <= {1'b0, current} + 1; 
                    
             // 数码管7: 横杠 "-" (我们定义 4'd10 代表横杠)
              Time[27: 24] <= 4'd10; 
                    
              // 数码管6: 音量高位 (取 vol 的高8位中的高4位)
              Time[23: 20] <= vol[15:12]; 
                    
              // 数码管5: 音量低位
              Time[19: 16] <= vol[11:8];
              
            case ({Time[cnt+3], Time[cnt+2], Time[cnt+1], Time[cnt]}) 
                4'b0000: begin
                    SEG<=7'b1000000;
                end
                4'b0001: begin
                    SEG<=7'b1111001;
                end
                4'b0010: begin
                    SEG<=7'b0100100;
                end
                4'b0011: begin
                    SEG<=7'b0110000;
                end
                4'b0100: begin
                    SEG<=7'b0011001;
                end
                4'b0101: begin
                    SEG<=7'b0010010;
                end
                4'b0110: begin
                    SEG<=7'b0000010;
                end
                4'b0111: begin
                    SEG<=7'b1111000;
                end
                4'b1000: begin
                    SEG<=7'b0000000;
                end
                4'b1001: begin
                    SEG<=7'b0010000;
                end
                4'b1101: begin 
                    SEG<=7'b0101011;
                end
                4'b1110: begin 
                    SEG<=7'b0011101;
                end
                4'd10: begin 
                    SEG<=7'b0111111;
                end
                default: begin
                    SEG<=7'b1111111;
                end
            endcase
        end
endmodule
