`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 15.03.2021 00:37:05
// Design Name:
// Module Name: delay_power_block
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


module my_delay_power_block(
    input clk,
    input rst,
    input strobe_in,
    input [31:0] power_in,
    output [31:0] power_out
    );

    wire reset;
    my_reset_for_srl #(
        .SIZE(25)
    ) reset_srl_25(
        .clk(clk),
        .rst(rst),
        .strobe_in(strobe_in),
        .reset_srl(reset)
    );

    my_shift_25 delay_power (
        .D(power_in),        // input wire [30 : 0] D
        .CLK(clk),    // input wire CLK
        .CE(strobe_in),      // input wire CE
        .SCLR(reset),  // input wire SCLR
        .Q(power_out)        // output wire [30 : 0] Q
    );

endmodule
