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
    input strobe_in,
    input enable,
    input [31:0] in,
    output [31:0] out
    );

    reg [15:0] cnt;
    wire do_op = (cnt < 320);
    assign out = (do_op ? in : 0);

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 320;
        end else if (enable) begin
            cnt <= 0;
        end else if (strobe_in & do_op) begin
            cnt <= cnt + 1;
        end
    end

endmodule
