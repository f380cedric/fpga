`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 18.03.2021 19:00:24
// Design Name:
// Module Name: reset_for_srl
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


module my_reset_for_srl#(
    parameter SIZE = 320
    )(
    input clk,
    input rst,
    input strobe_in,
    output reset_srl
    );

    reg [$clog2(SIZE)-1:0] cnt;
    assign reset_srl = rst | (cnt != (SIZE-1));

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
        end else if (strobe_in & reset_srl) begin
            cnt <= cnt + 1;
        end
    end
endmodule
