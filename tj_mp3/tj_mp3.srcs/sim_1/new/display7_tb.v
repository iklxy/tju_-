`timescale 1ns / 1ps

module tb_display7();

    // 1. 定义仿真所需的信号
    reg CLK;            // 模拟时钟
    reg [15:0] Data;    // 模拟输入数据（秒数）
    
    // 观察输出信号
    wire [6:0] SEG;
    wire [7:0] SHIFT;
    wire DOT;

    // 2. 例化被测模块 (Unit Under Test - UUT)
    display7 uut (
        .CLK(CLK), 
        .Data(Data), 
        .SEG(SEG), 
        .SHIFT(SHIFT), 
        .DOT(DOT)
    );

    // 3. 生成时钟信号
    // 假设板载时钟为 100MHz (周期 10ns)
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 每5ns翻转一次，周期10ns
    end

    // 4. 激励测试逻辑
    initial begin
        // --- 初始化 ---
        Data = 0;
        
        // --- 测试用例 1: 输入 125秒 (对应时间 02:05) ---
        // 预期：数码管应该扫描显示 0, 2, 0, 5
        #100; // 等待一点时间
        Data = 16'd125; 
        
        // 保持这个状态足够长的时间，以便观察数码管扫描了一整轮
        // 如果你把分频系数改小了(例如10)，这里运行 5000ns 就足够看全了
        // 如果你没改分频系数，这里可能需要运行几秒钟的仿真时间
        #10000; 

        // --- 测试用例 2: 输入 3661秒 (对应时间 01:01:01 -> 但你的逻辑只显示分秒) ---
        // 3661 / 60 = 61分. 61分在你的逻辑里怎么处理？
        // Time[15:12] = Data/600 = 3661/600 = 6. 
        // 你的逻辑似乎是用来显示 MM:SS 的
        Data = 16'd3661;
        #10000;

        // 结束仿真
        $stop;
    end

endmodule