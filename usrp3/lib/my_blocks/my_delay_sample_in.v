`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 15.03.2021 00:37:05
// Design Name:
// Module Name: delay_sample_in
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


module my_delay_sample_in(
    input clk,
    input rst,
    input strobe_in,
    input [31:0] sample_in,
    output [31:0] sample_out
    );

    wire reset;
    my_reset_for_srl #(
       .SIZE(1645)
    ) reset_srl_1645(
       .clk(clk),
       .rst(rst),
       .strobe_in(strobe_in),
       .reset_srl(reset)
    );

    wire [31:0] tmp;
    my_shift_1088 delay_sample0 (
        .D(sample_in),        // input wire [30 : 0] D
        .CLK(clk),    // input wire CLK
        .CE(strobe_in),      // input wire CE
        .SCLR(),  // input wire SCLR
        .Q(tmp)        // output wire [30 : 0] Q
    );

    my_shift_537 delay_sample1 (
            .D(tmp),        // input wire [30 : 0] D
            .CLK(clk),    // input wire CLK
            .CE(strobe_in),      // input wire CE
            .SCLR(reset),  // input wire SCLR
            .Q(sample_out)        // output wire [30 : 0] Q
        );

endmodule
