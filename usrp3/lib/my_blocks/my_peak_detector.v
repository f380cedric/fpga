`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/15/2020 08:57:24 AM
// Design Name:
// Module Name: my_peak_detector
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
    input radio_clk,
    input radio_rst,
    input strobe_in,
    input [31:0] sample_in,
    input [31:0] corrSq_in,
    input [31:0] power_in,
    input set_stb, input [7:0] set_addr, input [31:0] set_data,
    output reg [31:0] sample_out
    );

    localparam UR_THRESHOLD = 8'd252;
    localparam DEFAULT_THRESHOLD = 32'd1000;

    integer i,j;
    reg freeze_ram;
    reg [31:0] ram_corrSq_in[2:0];
    wire [31:0] abs_threshold;
    reg [31:0] threshold;
    reg [15:0] cpt_spls;
    reg [15:0] cpt_spls_since_last_peak, cpt_spls_since_last_peak_2;
    reg [31:0] ram_sample_in[319:0];

    setting_reg #(.my_addr(UR_THRESHOLD), .width(32), .at_reset(DEFAULT_THRESHOLD)) set_threshold
            (.clk(radio_clk), .rst(radio_rst), .strobe(set_stb), .addr(set_addr),
             .in(set_data), .out(abs_threshold), .changed());

    always @(posedge radio_clk) begin
        if(radio_rst) begin
            sample_out      = 32'h0000_0000;
            freeze_ram       = 1'b0;
            ram_corrSq_in[0] = 0;
            ram_corrSq_in[1] = 0;
            ram_corrSq_in[2] = 0;
            //abs_threshold   = 1000;
            threshold       = 0;
            cpt_spls        = 0;
            cpt_spls_since_last_peak = 0;
            cpt_spls_since_last_peak_2 = 0;
            for(i=0; i<319+1; i=i+1) begin
                ram_sample_in[i]=0;
            end
        end
        else begin
            if (strobe_in) begin
                // ***************************************
                // If a peak was not detected previously
                cpt_spls_since_last_peak = cpt_spls_since_last_peak+1;
                cpt_spls_since_last_peak_2 = cpt_spls_since_last_peak_2+1;
                if (!(freeze_ram)) begin
                    // Recording input in RAM memory
                    ram_corrSq_in[0] = ram_corrSq_in[1];
                    ram_corrSq_in[1] = ram_corrSq_in[2];
                    ram_corrSq_in[2] = corrSq_in;
                    for(j=0; j<319; j=j+1) begin
                        ram_sample_in[j]=ram_sample_in[j+1];
                    end
                    ram_sample_in[319] = sample_in;
                    // --------------------------------
                    // Check for peak
                    threshold = (power_in<<7);
                    if (power_in > abs_threshold) begin
                        if (ram_corrSq_in[1] > threshold) begin
                            if ((ram_corrSq_in[1]>=ram_corrSq_in[0])&&(ram_corrSq_in[1]>=ram_corrSq_in[2])) begin // if local maxima
                                if ((cpt_spls_since_last_peak == 320) && (cpt_spls_since_last_peak_2 == 640)) begin // If peak detected 64*5=320 samples earlier
                                    freeze_ram  = 1'b1;
                                    cpt_spls    = 0;
                                end
                                cpt_spls_since_last_peak_2 = cpt_spls_since_last_peak;
                                cpt_spls_since_last_peak = 0;
                            end
                        end
                    end
                    // --------------------------------
                    // Output samples
                    sample_out = 32'h0000_0000;
                end
                // ***************************************
                // /!\ If a peak was detected /!\
                else begin
                    // Outputting the RAM memory
                    sample_out = ram_sample_in[cpt_spls];
                    cpt_spls = cpt_spls+1;
                    if (cpt_spls > 319) begin
                        freeze_ram  = 1'b0;
                    end
                end
                // ***************************************
            end
        end
    end

endmodule
