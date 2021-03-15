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

    reg [8:0] cnt;
    wire reset = rst | (cnt != 349);

    my_shift_349 delay_sample (
        .D(sample_in),        // input wire [30 : 0] D
        .CLK(clk),    // input wire CLK
        .CE(strobe_in),      // input wire CE
        .SCLR(rst),  // input wire SCLR
        .Q(sample_out)        // output wire [30 : 0] Q
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
