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

    localparam UR_THRESHOLD = 8'd252;
    localparam DEFAULT_THRESHOLD = 32'd1000;

    reg [15:0] addr1, addr2;
    reg [31:0] ram_corrSq [1:0];
    reg [31:0] local_metric;
    reg enable;

    always @(posedge clk) begin
        trigger <= 0;
        if (rst) begin
            addr1 <= 1;
            addr2 <= 1;
            ram_corrSq[0] <= 0;
            ram_corrSq[1] <= 0;
            local_metric <= 0;
            trigger <= 0;
            enable <= 0;
        end else if (strobe_in) begin
            enable <= ((power > DEFAULT_THRESHOLD) & (corrSq > (power <<6)));
            ram_corrSq[0] <= ram_corrSq[1];
            ram_corrSq[1] <= corrSq;
            if (enable & ((ram_corrSq[1] > ram_corrSq[0]) && (ram_corrSq[1] > corrSq))) begin
                if ((addr2 > 318) && (addr2 < 322) && (addr1 > 638) && (addr1 < 642)) begin
                    trigger <= 1;
                    addr1 <= 1;
                    addr2 <= 1;
                // Avoid small glithes in the vicinity of the peak
                end else if (addr2 >= 16) begin
                    addr1 <= addr2 + 1;
                    addr2 <= 1;
                    local_metric <= ram_corrSq[1];
                // Accept in vicinity iif peak higher
                end else if  (ram_corrSq[1] > local_metric) begin
                    addr1 <= addr2 + 1;
                    addr2 <= 1;
                    local_metric <= ram_corrSq[1];
                end
            end else begin
                addr1 <= addr1 + 1;
                addr2 <= addr2 + 1;
            end
        end
    end
endmodule
