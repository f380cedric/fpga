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

    reg [8:0] cnt;
    wire reset = rst | (cnt != 340);

    my_shift_340 delay_power (
        .D(power_in),        // input wire [30 : 0] D
        .CLK(clk),    // input wire CLK
        .CE(strobe_in),      // input wire CE
        .SCLR(rst),  // input wire SCLR
        .Q(power_out)        // output wire [30 : 0] Q
    );

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 1;
        end else if (strobe_in) begin
            if (reset) begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule
