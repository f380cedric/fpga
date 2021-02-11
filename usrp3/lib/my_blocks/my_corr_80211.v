`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/01/2020 11:09:10 AM
// Design Name:
// Module Name: my_corr_80211
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


module my_corr_80211(
    input radio_clk,
    input radio_rst,
    input strobe_in,
    input [31:0] sample_in,
    output reg [31:0] sample_out,
    output reg [31:0] corr_out
    );

    // Inputs
    wire signed [15:0] sample_in_i, sample_in_q;
    assign sample_in_i = sample_in[31:16];
    assign sample_in_q = sample_in[15:0];

    // Outputs
    wire signed [31:0] corr_ii_out, corr_iq_out, corr_qi_out, corr_qq_out;

    // Define 4 real correlators (II, IQ, QI and QQ multiplication terms)
    my_corr_real #(.LF_IORQ(0)) my_corr_ii(
        .radio_clk(radio_clk),
        .radio_rst(radio_rst),
        .strobe_in(strobe_in),
        .sample_real_in(sample_in_i),
        .corr_real_out(corr_ii_out)
        );
    my_corr_real #(.LF_IORQ(1)) my_corr_iq(
        .radio_clk(radio_clk),
        .radio_rst(radio_rst),
        .strobe_in(strobe_in),
        .sample_real_in(sample_in_i),
        .corr_real_out(corr_iq_out)
        );
    my_corr_real #(.LF_IORQ(0)) my_corr_qi(
        .radio_clk(radio_clk),
        .radio_rst(radio_rst),
        .strobe_in(strobe_in),
        .sample_real_in(sample_in_q),
        .corr_real_out(corr_qi_out)
        );
    my_corr_real #(.LF_IORQ(1)) my_corr_qq(
        .radio_clk(radio_clk),
        .radio_rst(radio_rst),
        .strobe_in(strobe_in),
        .sample_real_in(sample_in_q),
        .corr_real_out(corr_qq_out)
        );


    // SHIFT REGISTERS TO STORE SAMPLES
    // -- correlators introduce K samples delay
    parameter [8:0] K = 15;
    reg [8:0] i,j;
    reg signed [31:0] reg_in[319+K:0];
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<319+K+1; i=i+1) begin
                reg_in[i]=0;
            end
        end
        else begin
            if(strobe_in) begin
                for(j=319+K; j>0; j=j-1) begin
                    reg_in[j]=reg_in[j-1];
                end
                reg_in[0] = sample_in;
            end
        end
    end

    // Define output
    wire signed [31:0] corr_out_i, corr_out_q;
    // WATCH OUT FOR SIGNS. IS IT LF OR CONJ(LF) THAT IS USED ?
    assign corr_out_i = corr_ii_out - corr_qq_out;
    assign corr_out_q = corr_iq_out + corr_qi_out;
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            sample_out  <= 0;
            corr_out    <= 0;
        end
        else begin
            if(strobe_in) begin
                corr_out = {corr_out_i[30:15],corr_out_q[30:15]};
                sample_out = reg_in[319+K];
            end
        end
    end


endmodule
