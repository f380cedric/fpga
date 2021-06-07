`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.03.2021 17:02:32
// Design Name:
// Module Name: peak_detector
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


module my_peak_detector(
    input clk,
    input rst,
    input strobe_in,
    input [31:0] power,
    input [31:0] corrSq,
    output reg trigger
    );

    localparam LOWER_BOUND = 9'd318;
    localparam UPPER_BOUND = 9'd322;
    localparam HALF_BAND = 161;

    reg [8:0] last_peak;
    reg [7:0] current_peak;
    reg [31:0] ram_corrSq [1:0];
    reg [31:0] local_metric;
    reg enable;
    wire peak_stb = enable & ((ram_corrSq[1] > ram_corrSq[0]) && (ram_corrSq[1] > corrSq));

    always @(posedge clk) begin
        trigger <= 0;
        if (rst) begin
            last_peak <= 0;
            current_peak <= 0;
            ram_corrSq[0] <= 0;
            ram_corrSq[1] <= 0;
            local_metric <= 0;
            trigger <= 0;
            enable <= 0;
        end else if (strobe_in) begin
            enable <= (corrSq > ((power+8) <<8));
            ram_corrSq[0] <= ram_corrSq[1];
            ram_corrSq[1] <= corrSq;
            if (last_peak > 0) begin
                last_peak <= last_peak + 1;
            end
            if (current_peak > 0) begin
                current_peak <= current_peak + 1;
            end
            if (peak_stb & (last_peak > LOWER_BOUND) & (last_peak < UPPER_BOUND)) begin
                trigger <= 1;
                last_peak <= 0;
                current_peak <= 0;
                local_metric <= 0;
            end else if (peak_stb && ram_corrSq[1] > local_metric) begin
                current_peak <= 1;
                local_metric <= ram_corrSq[1];
            end else if (current_peak >= HALF_BAND) begin
                current_peak <= 0;
                local_metric <= 0;
                last_peak <= current_peak + 1;
            end else if (last_peak >= UPPER_BOUND) begin
                last_peak <= 0;
            end
        end
    end
endmodule
