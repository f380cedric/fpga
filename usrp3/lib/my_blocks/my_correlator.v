`timescale 1ns / 1ps

module my_correlator(
    input clk,
    input rst,
    input strobe_in,
    input [31:0] sample_in,
    output [31:0] corr_out
    );

    wire [31:0] in_tdata;
    wire in_tready, in_tvalid;
    wire rstn;
    assign rstn = ~rst;

    my_axis_data_fifo my_fifo (
      .s_axis_aresetn(rstn),          // input wire s_axis_aresetn
      .s_axis_aclk(clk),                // input wire s_axis_aclk
      .s_axis_tvalid(strobe_in),            // input wire s_axis_tvalid
      .s_axis_tready(),            // output wire s_axis_tready
      .s_axis_tdata(sample_in),              // input wire [31 : 0] s_axis_tdata
      .m_axis_tvalid(in_tvalid),            // output wire m_axis_tvalid
      .m_axis_tready(in_tready),            // input wire m_axis_tready
      .m_axis_tdata(in_tdata),              // output wire [31 : 0] m_axis_tdata
      .axis_data_count(),        // output wire [31 : 0] axis_data_count
      .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
      .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
    );

    wire in_fir_tvalid0, in_fir_tvalid1, in_fir_tready0, in_fir_tready1;
    wire ou_fir_tvalid0, ou_fir_tvalid1, ou_fir_tready0, ou_fir_tready1;

    wire [31:0] in_fir_tdata0, in_fir_tdata1;
    wire [63:0] ou_fir_tdata0, ou_fir_tdata1;

    my_axis_broadcaster my_broad (
      .aclk(clk),                    // input wire aclk
      .aresetn(rstn),              // input wire aresetn
      .s_axis_tvalid(in_tvalid),  // input wire s_axis_tvalid
      .s_axis_tready(in_tready),  // output wire s_axis_tready
      .s_axis_tdata(in_tdata),    // input wire [31 : 0] s_axis_tdata
      .m_axis_tvalid({in_fir_tvalid0, in_fir_tvalid1}),  // output wire [1 : 0] m_axis_tvalid
      .m_axis_tready({in_fir_tready0, in_fir_tready1}),  // input wire [1 : 0] m_axis_tready
      .m_axis_tdata({in_fir_tdata0, in_fir_tdata1})    // output wire [63 : 0] m_axis_tdata
    );

    my_fir_compiler_i my_firi (
      .aclk(clk),                                  // input wire aclk
      .aresetn(rstn),                           // input wire aclk
      .s_axis_data_tvalid(in_fir_tvalid0),      // input wire s_axis_data_tvalid
      .s_axis_data_tready(in_fir_tready0),      // output wire s_axis_data_tready
      .s_axis_data_tdata(in_fir_tdata0),        // input wire [31 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(ou_fir_tvalid0),      // output wire m_axis_data_tvalid
      .m_axis_data_tready(ou_fir_tready0),
      .m_axis_data_tdata(ou_fir_tdata0)        // output wire [39 : 0] m_axis_data_tdata
    );

    my_fir_compiler_q my_firq (
      .aclk(clk),       // input wire aclk
      .aresetn(rstn),
      .s_axis_data_tvalid(in_fir_tvalid1),      // input wire s_axis_data_tvalid
      .s_axis_data_tready(in_fir_tready1),      // output wire s_axis_data_tready
      .s_axis_data_tdata(in_fir_tdata1),        // input wire [31 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(ou_fir_tvalid1),      // output wire m_axis_data_tvalid
      .m_axis_data_tready(ou_fir_tready1),
      .m_axis_data_tdata(ou_fir_tdata1)        // output wire [39 : 0] m_axis_data_tdata
    );

    wire signed [31:0] corr_out_i, corr_out_q;
    wire signed [31:0] corr_ii_out, corr_qq_out, corr_iq_out, corr_qi_out;

    assign {corr_ii_out, corr_qi_out} = ou_fir_tdata0;
    assign {corr_iq_out, corr_qq_out} = ou_fir_tdata1;
    assign corr_out_i = corr_ii_out - corr_qq_out;
    assign corr_out_q = corr_iq_out + corr_qi_out;

    wire [31:0] corr_out_int;
    wire fifo_out_tready;
    wire strobe_comb;

    my_axis_combiner my_comb (
      .aclk(clk),                    // input wire aclk
      .aresetn(rstn),              // input wire aresetn
      .s_axis_tvalid({ou_fir_tvalid0, ou_fir_tvalid1}),  // input wire [1 : 0] s_axis_tvalid
      .s_axis_tready({ou_fir_tready0, ou_fir_tready1}),  // output wire [1 : 0] s_axis_tready
      //.s_axis_tdata({corr_out_i[31:16], corr_out_q[31:16]}),    // input wire [63 : 0] s_axis_tdata
      .s_axis_tdata({corr_out_i[30:15], corr_out_q[30:15]}),    // input wire [63 : 0] s_axis_tdata
      .m_axis_tvalid(strobe_comb),  // output wire m_axis_tvalid
      .m_axis_tready(fifo_out_tready),  // input wire m_axis_tready
      .m_axis_tdata(corr_out_int)    // output wire [63 : 0] m_axis_tdata
    );

    my_axis_data_fifo my_fifo_out (
      .s_axis_aresetn(rstn),          // input wire s_axis_aresetn
      .s_axis_aclk(clk),                // input wire s_axis_aclk
      .s_axis_tvalid(strobe_comb),            // input wire s_axis_tvalid
      .s_axis_tready(fifo_out_tready),            // output wire s_axis_tready
      .s_axis_tdata(corr_out_int),              // input wire [31 : 0] s_axis_tdata
      .m_axis_tvalid(),            // output wire m_axis_tvalid
      .m_axis_tready(strobe_in),            // input wire m_axis_tready
      .m_axis_tdata(corr_out),              // output wire [31 : 0] m_axis_tdata
      .axis_data_count(),        // output wire [31 : 0] axis_data_count
      .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
      .axis_rd_data_count()  // output wire [31 : 0] axis_rd_data_count
    );

endmodule
