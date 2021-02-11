`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/03/2020 11:42:44 AM
// Design Name:
// Module Name: my_corr_real
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


module my_corr_real
    #(parameter LF_IORQ=0)
    (
    input radio_clk,
    input radio_rst,
    input strobe_in,
    input [15:0] sample_real_in,
    output reg [31:0] corr_real_out
    );


    // Real part of LF
    reg signed [15:0] LF_i[63:0] = {497, -16, 126, 308, 67, 190, -366, -122, 310, 170, 3, -435, 78, 187, -72, 379, 199, 117, -182, -418, 262, 221, -192, -180, -111, -388, -405, 239, -9, -292, 292, 39, -497, 39, 292, -292, -9, 239, -405, -388, -111, -180, -192, 221, 262, -418, -182, 117, 199, 379, -72, 187, 78, -435, 3, 170, 310, -122, -366, 190, 67, 308, 126, -16 };
    reg signed [15:0] LF_q[63:0] = {0, -383, -354, 263, 89, -279, -176, -338, -82, 13, -366, -151, -186, -48, 511, -13, -199, 313, 125, 207, 294, 45, 259, -69, -480, -53, -65, -235, 171, 366, 337, 310, 0, -310, -337, -366, -171, 235, 65, 53, 480, 69, -259, -45, -294, -207, -125, -313, 199, 13, -511, 48, 186, 151, 366, -13, 82, 338, 176, 279, -89, -263, 354, 383 };
    //reg signed [15:0] LF_i[63:0] = {256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256,256};
    //reg signed [15:0] LF_q[63:0] = {512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512};

    // Counters
    reg [8:0] i,j;

    // SHIFT REGISTERS
    reg signed [15:0] reg_in[319:0];
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<320; i=i+1) begin
                reg_in[i]=0;
            end
        end
        else begin
            if(strobe_in) begin
                for(j=0; j<319; j=j+1) begin
                    reg_in[j]=reg_in[j+1];
                end
                reg_in[319] = sample_real_in;
            end
        end
    end

    // DSP48 multipliers for real multiplications
    reg sclr, ce;
    reg signed [15:0] mult_in_1[63:0];
    reg signed [15:0] mult_in_2[63:0];
    wire signed [31:0] mult_out[63:0];
    genvar k;
    generate
        for (k = 0; k < 64; k = k + 1) begin
            my_mult my_mult_inst(
                .CLK(radio_clk),    // input wire CLK
                .CE(ce),      // input wire CE
                .SCLR(sclr),  // input wire SCLR
                .A(mult_in_1[k]),        // input wire [15 : 0] A
                .B(mult_in_2[k]),        // input wire [15 : 0] B
                .P(mult_out[k])        // output wire [31 : 0] P
                );
		end
	endgenerate
    // Define multiplication inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<64; i=i+1) begin
                mult_in_1[i]  <= 0;
                mult_in_2[i]  <= 0;
            end
            ce          <= 0;
            sclr        <= 1;
        end
        else begin
            ce          <= 1;
            sclr        <= 0;
            if(strobe_in) begin
                for(i=0; i<64; i=i+1) begin
                    mult_in_1[i]  <= reg_in[5*i];
                    if (LF_IORQ == 0) begin
                        mult_in_2[i]  <= LF_i[i];
                    end
                    else if (LF_IORQ == 1) begin
                        mult_in_2[i]  <= LF_q[i];
                    end
                end
            end
        end
    end

    // adders level 1 (L1) for real additions
    reg sclr_L1, ce_L1;
    reg signed [31:0] add_L1_in_1[31:0];
    reg signed [31:0] add_L1_in_2[31:0];
    wire signed [31:0] add_L1_out[31:0];
    genvar l;
    generate
        for (l = 0; l < 32; l = l + 1) begin
            my_adder my_adder_L1(
                  .A(add_L1_in_1[l]),        // input wire [31 : 0] A
                  .B(add_L1_in_2[l]),        // input wire [31 : 0] B
                  .CLK(radio_clk),    // input wire CLK
                  .CE(ce_L1),      // input wire CE
                  .SCLR(sclr_L1),  // input wire SCLR
                  .S(add_L1_out[l])        // output wire [31 : 0] S
                );
		end
	endgenerate
    // Define adders L1 inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<32; i=i+1) begin
                add_L1_in_1[i]  <= 0;
                add_L1_in_2[i]  <= 0;
            end
            ce_L1       <= 0;
            sclr_L1     <= 1;
        end
        else begin
            ce_L1          <= 1;
            sclr_L1        <= 0;
            if(strobe_in) begin
                for(i=0; i<32; i=i+1) begin
                    add_L1_in_1[i]  <= mult_out[i*2];
                    add_L1_in_2[i]  <= mult_out[i*2+1];
                end
            end
        end
    end

    // adders level 2 (L2) for real additions
    reg sclr_L2, ce_L2;
    reg signed [31:0] add_L2_in_1[15:0];
    reg signed [31:0] add_L2_in_2[15:0];
    wire signed [31:0] add_L2_out[15:0];
    //genvar l;
    generate
        for (l = 0; l < 16; l = l + 1) begin
            my_adder my_adder_L2(
                  .A(add_L2_in_1[l]),        // input wire [31 : 0] A
                  .B(add_L2_in_2[l]),        // input wire [31 : 0] B
                  .CLK(radio_clk),    // input wire CLK
                  .CE(ce_L2),      // input wire CE
                  .SCLR(sclr_L2),  // input wire SCLR
                  .S(add_L2_out[l])        // output wire [31 : 0] S
                );
		end
	endgenerate
    // Define adders L2 inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<16; i=i+1) begin
                add_L2_in_1[i]  <= 0;
                add_L2_in_2[i]  <= 0;
            end
            ce_L2       <= 0;
            sclr_L2     <= 1;
        end
        else begin
            ce_L2          <= 1;
            sclr_L2        <= 0;
            if(strobe_in) begin
                for(i=0; i<16; i=i+1) begin
                    add_L2_in_1[i]  <= add_L1_out[i*2];
                    add_L2_in_2[i]  <= add_L1_out[i*2+1];
                end
            end
        end
    end

    // adders level 3 (L3) for real additions
    reg sclr_L3, ce_L3;
    reg signed [31:0] add_L3_in_1[7:0];
    reg signed [31:0] add_L3_in_2[7:0];
    wire signed [31:0] add_L3_out[7:0];
    //genvar l;
    generate
        for (l = 0; l < 8; l = l + 1) begin
            my_adder my_adder_L3(
                  .A(add_L3_in_1[l]),        // input wire [31 : 0] A
                  .B(add_L3_in_2[l]),        // input wire [31 : 0] B
                  .CLK(radio_clk),    // input wire CLK
                  .CE(ce_L3),      // input wire CE
                  .SCLR(sclr_L3),  // input wire SCLR
                  .S(add_L3_out[l])        // output wire [31 : 0] S
                );
		end
	endgenerate
    // Define adders L3 inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<8; i=i+1) begin
                add_L3_in_1[i]  <= 0;
                add_L3_in_2[i]  <= 0;
            end
            ce_L3       <= 0;
            sclr_L3     <= 1;
        end
        else begin
            ce_L3          <= 1;
            sclr_L3        <= 0;
            if(strobe_in) begin
                for(i=0; i<8; i=i+1) begin
                    add_L3_in_1[i]  <= add_L2_out[i*2];
                    add_L3_in_2[i]  <= add_L2_out[i*2+1];
                end
            end
        end
    end

    // adders level 4 (L4) for real additions
    reg sclr_L4, ce_L4;
    reg signed [31:0] add_L4_in_1[3:0];
    reg signed [31:0] add_L4_in_2[3:0];
    wire signed [31:0] add_L4_out[3:0];
    //genvar l;
    generate
        for (l = 0; l < 4; l = l + 1) begin
            my_adder my_adder_L4(
                  .A(add_L4_in_1[l]),        // input wire [31 : 0] A
                  .B(add_L4_in_2[l]),        // input wire [31 : 0] B
                  .CLK(radio_clk),    // input wire CLK
                  .CE(ce_L4),      // input wire CE
                  .SCLR(sclr_L4),  // input wire SCLR
                  .S(add_L4_out[l])        // output wire [31 : 0] S
                );
		end
	endgenerate
    // Define adders L4 inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<4; i=i+1) begin
                add_L4_in_1[i]  <= 0;
                add_L4_in_2[i]  <= 0;
            end
            ce_L4       <= 0;
            sclr_L4     <= 1;
        end
        else begin
            ce_L4          <= 1;
            sclr_L4        <= 0;
            if(strobe_in) begin
                for(i=0; i<4; i=i+1) begin
                    add_L4_in_1[i]  <= add_L3_out[i*2];
                    add_L4_in_2[i]  <= add_L3_out[i*2+1];
                end
            end
        end
    end

    // adders level 5 (L5) for real additions
    reg sclr_L5, ce_L5;
    reg signed [31:0] add_L5_in_1[1:0];
    reg signed [31:0] add_L5_in_2[1:0];
    wire signed [31:0] add_L5_out[1:0];
    //genvar l;
    generate
        for (l = 0; l < 2; l = l + 1) begin
            my_adder my_adder_L5(
                  .A(add_L5_in_1[l]),        // input wire [31 : 0] A
                  .B(add_L5_in_2[l]),        // input wire [31 : 0] B
                  .CLK(radio_clk),    // input wire CLK
                  .CE(ce_L5),      // input wire CE
                  .SCLR(sclr_L5),  // input wire SCLR
                  .S(add_L5_out[l])        // output wire [31 : 0] S
                );
		end
	endgenerate
    // Define adders L5 inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            for(i=0; i<2; i=i+1) begin
                add_L5_in_1[i]  <= 0;
                add_L5_in_2[i]  <= 0;
            end
            ce_L5       <= 0;
            sclr_L5     <= 1;
        end
        else begin
            ce_L5          <= 1;
            sclr_L5        <= 0;
            if(strobe_in) begin
                for(i=0; i<2; i=i+1) begin
                    add_L5_in_1[i]  <= add_L4_out[i*2];
                    add_L5_in_2[i]  <= add_L4_out[i*2+1];
                end
            end
        end
    end

    // adders level 6 (L6) for real additions
    reg sclr_L6, ce_L6;
    reg signed [31:0] add_L6_in_1;
    reg signed [31:0] add_L6_in_2;
    wire signed [31:0] add_L6_out;
    my_adder my_adder_L6(
          .A(add_L6_in_1),        // input wire [31 : 0] A
          .B(add_L6_in_2),        // input wire [31 : 0] B
          .CLK(radio_clk),    // input wire CLK
          .CE(ce_L6),      // input wire CE
          .SCLR(sclr_L6),  // input wire SCLR
          .S(add_L6_out)        // output wire [31 : 0] S
        );
    // Define adders L6 inputs
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            add_L6_in_1  <= 0;
            add_L6_in_2  <= 0;
            ce_L6       <= 0;
            sclr_L6     <= 1;
        end
        else begin
            ce_L6          <= 1;
            sclr_L6        <= 0;
            if(strobe_in) begin
                add_L6_in_1  <= add_L5_out[0];
                add_L6_in_2  <= add_L5_out[1];
            end
        end
    end

    // Define output
    always @(posedge radio_clk) begin
        if(radio_rst) begin
            corr_real_out    <= 0;
        end
        else begin
            if(strobe_in) begin
                corr_real_out = add_L6_out;
            end
        end
    end


endmodule
