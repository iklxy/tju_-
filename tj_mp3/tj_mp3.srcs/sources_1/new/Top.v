`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/25 22:39:39
// Design Name: 
// Module Name: Top
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


module system_top(
    input CLK,          // 板载时钟 E3
    input RST,          // 复位按钮 (你需要绑定到一个按钮，如 C12)
    output [6:0] SEG,   // 数码管段选
    output [7:0] SHIFT, // 数码管位选
    output  DOT,          // 小数点
    
    input BTNL,          // 左键：上一首
    input BTNR,             // 右键：下一首
    input BTNU,             // 上键：音量 +
    input BTND,             // 下键：音量 -
    input BTNC            // 中键：暂停/播放
);
    reg [2:0] current_reg;      // 歌曲号 (0-7)
    reg [3:0] vol_level;        // 音量等级 (0-10, 0为静音, 10为最大)
    reg is_paused;              // 暂停状态 (0:播放, 1:暂停)
    reg [25:0] btn_cnt;         // 消抖计数器
    parameter BTN_DELAY = 20000000; // 0.2秒 冷却时间 (100MHz下)
    reg [15:0] mp3_vol_value;   // 转换后送给 MP3 芯片的 16位 音量码
    reg timer_clr; // 用于给计时器发清零命令
    
    always @(posedge CLK) begin
            timer_clr <= 0;
            if(!RST) begin
                // 复位初始状态
                current_reg <= 0;   // 默认第0首
                vol_level   <= 5;   // 默认音量 5 (中间值)
                is_paused   <= 0;   // 默认播放
                btn_cnt     <= 0;
                timer_clr <= 0;
            end
            else begin
                // 倒计时消抖
                if(btn_cnt > 0) 
                    btn_cnt <= btn_cnt - 1;
                
                else begin
                    // 只有计数器归零时才响应按键
                    
                    // --- 歌曲切换逻辑 (0-7 循环) ---
                    if(BTNR) begin // 下一首
                        current_reg <= (current_reg == 7) ? 0 : current_reg + 1;
                        btn_cnt <= BTN_DELAY;
                        timer_clr <= 1;
                    end
                    else if(BTNL) begin // 上一首
                        current_reg <= (current_reg == 0) ? 7 : current_reg - 1;
                        btn_cnt <= BTN_DELAY;
                        timer_clr <= 1;
                    end
                    
                    // --- 音量调节逻辑 (0-10 循环) ---
                    else if(BTNU) begin // 音量 +
                        vol_level <= (vol_level == 10) ? 0 : vol_level + 1;
                        btn_cnt <= BTN_DELAY;
                    end
                    else if(BTND) begin // 音量 -
                        vol_level <= (vol_level == 0) ? 10 : vol_level - 1;
                        btn_cnt <= BTN_DELAY;
                    end
                    
                    // --- 暂停逻辑 ---
                    else if(BTNC) begin // 暂停/继续
                        is_paused <= ~is_paused; // 状态取反
                        btn_cnt <= BTN_DELAY;
                    end
                end
            end
        end
    
        // ==========================================================
        // 3. 音量映射逻辑 (等级 0-10 -> MP3 十六进制指令)
        // ==========================================================
        // VS1003B: 高8位是左声道，低8位是右声道。00是最大声，FE是静音。
        always @(*) begin
            case(vol_level)
                0:  mp3_vol_value = 16'hFEFE; // 静音 (Level 0)
                1:  mp3_vol_value = 16'h9090; // 很小声
                2:  mp3_vol_value = 16'h8080;
                3:  mp3_vol_value = 16'h7070;
                4:  mp3_vol_value = 16'h6060;
                5:  mp3_vol_value = 16'h5050; // 中等 (Level 5)
                6:  mp3_vol_value = 16'h4040;
                7:  mp3_vol_value = 16'h3030;
                8:  mp3_vol_value = 16'h2020;
                9:  mp3_vol_value = 16'h1010;
                10: mp3_vol_value = 16'h0000; // 最大声 (Level 10)
                default: mp3_vol_value = 16'h5050;
            endcase
        end
        
    wire [15:0] internal_data; // 内部连线，代替原来的外部 Data 接口
    
    // 实例化计时器
    timeCounter tc (
        .CLK(CLK),
        .RST(RST),
        .pause(is_paused),
        .clear(timer_clr),
        .Time(internal_data) // 产出的时间送给内部连线
    );
    
    // 实例化显示模块
    display7 d7 (
        .CLK(CLK),
        .Data(internal_data), // 输入数据来自内部连线，不需要引脚约束
        .current(current_reg), // 显示歌曲号
        .vol(mp3_vol_value),   // 显示音量 (注意这里会显示十六进制，如 50)
        .SEG(SEG),
        .SHIFT(SHIFT),
        .DOT(DOT)
    );
    
endmodule
