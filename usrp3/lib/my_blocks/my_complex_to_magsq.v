`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12.03.2021 19:06:15
// Design Name:
// Module Name: complex_to_magsq
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


module my_complex_to_magsq(
    input clk,
    input rst,
    input [31:0] in,
    input strobe_in,
    output reg [31:0] out
    );

    reg signed [15:0] in_i, in_q;


    // Inputs and outputs multipliers
    wire [31:0] inSq_i, inSq_q;
    my_mult mult_in_i(.CLK(clk),.SCLR(rst),.A(in_i),.B(in_i),.P(inSq_i));
    my_mult mult_in_q(.CLK(clk),.SCLR(rst),.A(in_q),.B(in_q),.P(inSq_q));

    always @(posedge clk) begin
        if(rst) begin
            out <= 0;
            in_i <= 0;
            in_q <= 0;
        end else if (strobe_in) begin
            in_i <= in[31:16];
            in_q <= in[15:0];
            out <= inSq_i + inSq_q;
        end
    end
endmodule
