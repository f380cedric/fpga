`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/04/2020 03:43:17 PM
// Design Name:
// Module Name: my_power_calc
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


module my_power_calc(
    input radio_clk,
    input radio_rst,
    input strobe_in,
    input [31:0] sample_in,
    input [31:0] corr_in,
    output reg [31:0] sample_out,
    output reg [31:0] corrSq_out,
    output reg [31:0] power_out
    );

    integer i,j;

    wire signed [15:0] in_i, in_q;
    wire signed [15:0] corr_i, corr_q;
    assign in_i = sample_in[31:16];
    assign in_q = sample_in[15:0];
    assign corr_i = corr_in[31:16];
    assign corr_q = corr_in[15:0];

    // Inputs and outputs multipliers
    reg sclr, ce;
    reg signed [15:0] in_i_reg, in_q_reg, corr_i_reg, corr_q_reg;
    wire signed [31:0] inSq_i, inSq_q, corrSq_i, corrSq_q;
    my_mult mult_in_i(.CLK(radio_clk),.CE(ce),.SCLR(sclr),.A(in_i_reg),.B(in_i_reg),.P(inSq_i));
    my_mult mult_in_q(.CLK(radio_clk),.CE(ce),.SCLR(sclr),.A(in_q_reg),.B(in_q_reg),.P(inSq_q));
    my_mult mult_corr_i(.CLK(radio_clk),.CE(ce),.SCLR(sclr),.A(corr_i_reg),.B(corr_i_reg),.P(corrSq_i));
    my_mult mult_corr_q(.CLK(radio_clk),.CE(ce),.SCLR(sclr),.A(corr_q_reg),.B(corr_q_reg),.P(corrSq_q));

    reg signed [7:0] cpt_cycle;
    reg signed [31:0] ram_rss[319:0];
    reg signed [31:0] sum_rss[4:0];
    wire signed [31:0] rss, corrSq;
    assign rss = (inSq_i + inSq_q)>>16; // right-shift to avoid overflow
    assign corrSq = corrSq_i + corrSq_q;

    // Define multiplication inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            ce          <= 0;
            sclr        <= 1;
            in_i_reg    <= 0;
            in_q_reg    <= 0;
            corr_i_reg  <= 0;
            corr_q_reg  <= 0;
            for(i=0; i<319+1; i=i+1) begin
                ram_rss[i] <=0;
            end
            for(i=0; i<4+1; i=i+1) begin
                sum_rss[i] <= 0;
            end
            cpt_cycle   <= 0;
        end
        else begin
            ce          <= 1;
            sclr        <= 0;
            if(strobe_in) begin
                in_i_reg    <= in_i;
                in_q_reg    <= in_q;
                corr_i_reg  <= corr_i;
                corr_q_reg  <= corr_q;

                for(j=1; j<319+1; j=j+1) begin
                    ram_rss[j] <= ram_rss[j-1];
                end
                ram_rss[0] <= rss;

                sum_rss[cpt_cycle] = sum_rss[cpt_cycle]-ram_rss[319];
                sum_rss[(cpt_cycle+4)%5] <= sum_rss[(cpt_cycle+4)%5]+ram_rss[0];
                cpt_cycle <= (cpt_cycle+1)%5;

            end
        end
    end

    // SHIFT REGISTERS TO STORE SAMPLES
    // -- multipliers and adders introduce K samples delay
    parameter [8:0] K = 5;
    reg signed [31:0] reg_sample[K:0];
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<K+1; i=i+1) begin
                reg_sample[i]=0;
            end
        end
        else begin
            if(strobe_in) begin
                for(j=K; j>0; j=j-1) begin
                    reg_sample[j]=reg_sample[j-1];
                end
                reg_sample[0] <= sample_in;

            end
        end
    end

    // SHIFT REGISTERS TO STORE CORRELATOR SQUARE OUTPUT
    // -- multipliers and adders introduce L samples delay
    parameter [8:0] L = 2;
    reg signed [31:0] reg_CorrSq[L:0];
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<L+1; i=i+1) begin
                reg_CorrSq[i]=0;
            end
        end
        else begin
            if(strobe_in) begin
                for(j=L; j>0; j=j-1) begin
                    reg_CorrSq[j]=reg_CorrSq[j-1];
                end
                reg_CorrSq[0] <= corrSq;
            end
        end
    end

    // Define outputs
    wire signed [31:0] corr_out_i, corr_out_q;
    // WATCH OUT FOR SIGNS. IS IT LF OR CONJ(LF) THAT IS USED ?
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            sample_out  <= 0;
            corrSq_out  <= 0;
            power_out   <= 0;
        end
        else begin
            if(strobe_in) begin
                sample_out <= reg_sample[K];
                corrSq_out <= reg_CorrSq[L];
                power_out <= sum_rss[(cpt_cycle+3)%5];
            end
        end
    end

endmodule
