`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/22 23:39:09
// Design Name: 
// Module Name: Divider
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

module Divider #(
    parameter N = 20  // 使用 parameter 便于复用
)(
    input I_CLK,
    input rst,        // 保留复位信号
    output reg O_CLK  // 直接输出 reg
);
    reg [31:0] cnt; 

    always @(posedge I_CLK) begin
        if (rst) begin
            cnt <= 0;
            O_CLK <= 0;
        end
        else begin
            if (cnt == (N/2 - 1)) begin
                cnt <= 0;
                O_CLK <= ~O_CLK; 
            end
            else begin
                cnt <= cnt + 1;
            end
        end
    end

endmodule
