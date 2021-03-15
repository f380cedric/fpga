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
    input set_stb, input [7:0] set_addr, input [31:0] set_data,
    output reg trigger
    );

    localparam UR_THRESHOLD = 8'd252;
    localparam DEFAULT_THRESHOLD = 32'd1000;

    wire [31:0] abs_threshold;
    wire [31:0] threshold;

    setting_reg #(
        .my_addr(UR_THRESHOLD),
        .width(32),
        .at_reset(DEFAULT_THRESHOLD)
    ) set_threshold(
        .clk(clk),
        .rst(rst),
        .strobe(set_stb),
        .addr(set_addr),
        .in(set_data),
        .out(abs_threshold),
        .changed()
    );

    reg [15:0] addr1, addr2;
    reg [31:0] ram_corrSq [1:0];
    reg [15:0] cnt;
    reg enable;

    always @(posedge clk) begin
        if (rst) begin
            addr1 <= 1;
            addr2 <= 1;
            ram_corrSq[0] <= 0;
            ram_corrSq[1] <= 0;
            trigger <= 0;
            cnt <= 1 ;
        end else if (strobe_in) begin
            enable <= ((power > abs_threshold) & (corrSq > (power <<7)));
            ram_corrSq[0] <= ram_corrSq[1];
            ram_corrSq[1] <= corrSq;
            if (enable & ((ram_corrSq[1] > ram_corrSq[0]) && (ram_corrSq[1] > corrSq))) begin
                if ((addr2 > 318) && (addr2 < 322) && (addr1 > 638) && (addr1 < 642)) begin
                    trigger <= 1;
                    addr1 <= 0;
                    addr2 <= 0;
                end else begin
                    addr1 <= addr2 + 1;
                    addr2 <= 1;
                end
            end else begin
                addr1 <= addr1 + 1;
                addr2 <= addr2 + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (strobe_in & trigger) begin
            if (cnt == 320) begin
                trigger <= 0;
                cnt <= 1;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule
