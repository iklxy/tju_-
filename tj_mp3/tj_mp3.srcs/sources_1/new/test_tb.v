`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/25 22:11:22
// Design Name: 
// Module Name: test_tb
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


`timescale 1ns / 1ps

module tb_system_integration();

    // ==========================================
    // 1. 定义仿真所需的信号
    // ==========================================
    reg CLK;            // 模拟 100MHz 时钟
    reg RST;            // 模拟复位信号
    
    // 内部连线 (Wire)
    wire [15:0] current_time; // 连接 timeCounter 的输出 和 display7 的输入
    
    // 观察输出端口
    wire [6:0] SEG;     // 数码管段选
    wire [7:0] SHIFT;   // 数码管位选
    wire DOT;           // 小数点

    // ==========================================
    // 2. 生成模拟时钟 (100MHz)
    // ==========================================
    initial begin
        CLK = 0;
        // 每 5ns 翻转一次 = 周期 10ns = 100MHz
        forever #5 CLK = ~CLK; 
    end

    // ==========================================
    // 3. 例化并连接模块 (搭建系统)
    // ==========================================
    
    // 实例 1: 计时器 (负责产生时间数据)
    timeCounter u_timeCounter(
        .CLK(CLK),
        .RST(RST),        // 连接复位信号
        .Time(current_time) // 输出时间给中间连线
    );

    // 实例 2: 显示控制器 (负责显示时间数据)
    display7 u_display7(
        .CLK(CLK),
        .Data(current_time), // 输入数据来自 timer
        .SEG(SEG),
        .SHIFT(SHIFT),
        .DOT(DOT)
    );

    // ==========================================
    // 4. 激励逻辑 (模拟上电过程)
    // ==========================================
    initial begin
        // --- 阶段 1: 初始化与复位 ---
        RST = 0;       // 按下复位键 (低电平有效)
        #100;          // 保持复位 100ns
        
        // --- 阶段 2: 释放复位，系统开始运行 ---
        RST = 1;       // 松开复位键 (变为高电平)
        
        // --- 阶段 3: 观察波形 ---
        // 只要你修改了上面提到的参数 N，这里跑 5000ns 就能看到所有变化
        // 你会看到 current_time 快速增加，同时 SHIFT 快速移位
        #10000; 
        
        // 结束仿真
        $stop;
    end

endmodule
