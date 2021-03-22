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
    output [31:0] out
    );

    wire signed [15:0] in_i, in_q;
    assign {in_i, in_q} = in;
    reg signed [15:0] in_q_reg;
    wire [47:0] in_sq;

    my_mult_ii my_mult_ii1(
      .CLK(clk),            // input wire CLK
      .CE(1'b1),              // input wire CE
      .SCLR(rst),          // input wire SCLR
      .A(in_i),                // input wire [15 : 0] A
      .B(in_i),                // input wire [15 : 0] B
      .C(16'b0),
      .PCOUT(in_sq)        // output wire [47 : 0] PCOUT
    );

    my_mult_ii_qq my_mult_ii_qq1 (
      .CLK(clk),            // input wire CLK
      .CE(1'b1),              // input wire CE
      .SCLR(rst),          // input wire SCLR
      .A(in_q_reg),                // input wire [15 : 0] A
      .B(in_q_reg),                // input wire [15 : 0] B
      .PCIN(in_sq),          // input wire [47 : 0] PCIN
      .P(out)
    );

    always @(posedge clk) begin
        if (rst) begin
            in_q_reg <= 0;
        end else begin
            in_q_reg <= in_q;

        end
    end

endmodule
