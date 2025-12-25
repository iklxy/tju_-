`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/25 22:07:37
// Design Name: 
// Module Name: timeCounter
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


module timeCounter(
	input CLK,
	input RST, 
	input pause,
	input clear,
	output reg [15: 0] Time
);
    integer counter=0;
    always @ (posedge CLK)
    begin
		if(!RST) begin 
			Time <= 0;
			counter <= 0;
		end
		else if(clear) begin
		       Time <= 0;
               counter <= 0;
        end
		else if(pause) begin
		//啥都不干就是暂停
		end
        else if((counter+1)==100000000)
        begin
            counter <= 0;
            Time <= Time+1;
        end
        else
            counter <= counter+1;
    end
endmodule
