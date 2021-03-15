`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 15.03.2021 00:42:35
// Design Name:
// Module Name: window
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


module my_window(
    input clk,
    input rst,
    input enable,
    input [31:0] in,
    output [31:0] out
    );

    assign out = (enable ? in : 0);
endmodule
