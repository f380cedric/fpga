`timescale 1ns / 1ps

module my_moving_sum(
    input clk,
    input rst,
    input strobe_in,
    input [15:0] in,
    output reg [31:0] out
    );

    wire [31:0] sum;
    wire [15:0] din;
    reg [31:0] sum_reg [4:0];
    reg [2:0] index;
    reg [8:0] cnt;

    wire reset = rst | (cnt != 320);


    my_shift_320 shift_320 (
    .D(in),        // input wire [15 : 0] D
    .CLK(clk),    // input wire CLK
    .SCLR(reset),  // input wire SCLR
    .CE(strobe_in),  // input wire SSET
    .Q(din)        // output wire [15 : 0] Q
    );

    assign sum = sum_reg[index] + in - din;

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            cnt <= 1;
            index <= 0;
            out <= 0;
            for(i=0; i<5; i=i+1) begin
                sum_reg[i] <= 0;
            end
        end else if (strobe_in) begin
            if (reset) begin
                cnt <= cnt + 1;
            end
            index <= (index + 1)%5;
            sum_reg[index] <= sum;
            out <= sum;
        end
    end

endmodule

