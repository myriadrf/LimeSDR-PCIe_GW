// synthesis VERILOG_INPUT_VERSION VERILOG_2001
//Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030
module sim_rxpipe_8bit_to_32_bit (
      // Input PIPE simulation _ext for simulation only
      input                 sim_pipe8_pclk,
      input                 aclr,

      input                 phystatus0_ext,
      input                 phystatus1_ext,
      input                 phystatus2_ext,
      input                 phystatus3_ext,
      input                 phystatus4_ext,
      input                 phystatus5_ext,
      input                 phystatus6_ext,
      input                 phystatus7_ext,
      input  [7 : 0]        rxdata0_ext,
      input  [7 : 0]        rxdata1_ext,
      input  [7 : 0]        rxdata2_ext,
      input  [7 : 0]        rxdata3_ext,
      input  [7 : 0]        rxdata4_ext,
      input  [7 : 0]        rxdata5_ext,
      input  [7 : 0]        rxdata6_ext,
      input  [7 : 0]        rxdata7_ext,
      input                 rxdatak0_ext,
      input                 rxdatak1_ext,
      input                 rxdatak2_ext,
      input                 rxdatak3_ext,
      input                 rxdatak4_ext,
      input                 rxdatak5_ext,
      input                 rxdatak6_ext,
      input                 rxdatak7_ext,
      input                 rxelecidle0_ext,
      input                 rxelecidle1_ext,
      input                 rxelecidle2_ext,
      input                 rxelecidle3_ext,
      input                 rxelecidle4_ext,
      input                 rxelecidle5_ext,
      input                 rxelecidle6_ext,
      input                 rxelecidle7_ext,
      input                 rxfreqlocked0_ext,
      input                 rxfreqlocked1_ext,
      input                 rxfreqlocked2_ext,
      input                 rxfreqlocked3_ext,
      input                 rxfreqlocked4_ext,
      input                 rxfreqlocked5_ext,
      input                 rxfreqlocked6_ext,
      input                 rxfreqlocked7_ext,
      input  [2 : 0]        rxstatus0_ext,
      input  [2 : 0]        rxstatus1_ext,
      input  [2 : 0]        rxstatus2_ext,
      input  [2 : 0]        rxstatus3_ext,
      input  [2 : 0]        rxstatus4_ext,
      input  [2 : 0]        rxstatus5_ext,
      input  [2 : 0]        rxstatus6_ext,
      input  [2 : 0]        rxstatus7_ext,
      input                 rxdataskip0_ext,
      input                 rxdataskip1_ext,
      input                 rxdataskip2_ext,
      input                 rxdataskip3_ext,
      input                 rxdataskip4_ext,
      input                 rxdataskip5_ext,
      input                 rxdataskip6_ext,
      input                 rxdataskip7_ext,
      input                 rxblkst0_ext,
      input                 rxblkst1_ext,
      input                 rxblkst2_ext,
      input                 rxblkst3_ext,
      input                 rxblkst4_ext,
      input                 rxblkst5_ext,
      input                 rxblkst6_ext,
      input                 rxblkst7_ext,
      input  [1 : 0]        rxsynchd0_ext,
      input  [1 : 0]        rxsynchd1_ext,
      input  [1 : 0]        rxsynchd2_ext,
      input  [1 : 0]        rxsynchd3_ext,
      input  [1 : 0]        rxsynchd4_ext,
      input  [1 : 0]        rxsynchd5_ext,
      input  [1 : 0]        rxsynchd6_ext,
      input  [1 : 0]        rxsynchd7_ext,
      input                 rxvalid0_ext,
      input                 rxvalid1_ext,
      input                 rxvalid2_ext,
      input                 rxvalid3_ext,
      input                 rxvalid4_ext,
      input                 rxvalid5_ext,
      input                 rxvalid6_ext,
      input                 rxvalid7_ext,

      output                    sim_pipe32_pclk,
      output reg                phystatus0_ext32b,
      output reg                phystatus1_ext32b,
      output reg                phystatus2_ext32b,
      output reg                phystatus3_ext32b,
      output reg                phystatus4_ext32b,
      output reg                phystatus5_ext32b,
      output reg                phystatus6_ext32b,
      output reg                phystatus7_ext32b,
      output reg [31 : 0]       rxdata0_ext32b,
      output reg [31 : 0]       rxdata1_ext32b,
      output reg [31 : 0]       rxdata2_ext32b,
      output reg [31 : 0]       rxdata3_ext32b,
      output reg [31 : 0]       rxdata4_ext32b,
      output reg [31 : 0]       rxdata5_ext32b,
      output reg [31 : 0]       rxdata6_ext32b,
      output reg [31 : 0]       rxdata7_ext32b,
      output reg [3  : 0]       rxdatak0_ext32b,
      output reg [3  : 0]       rxdatak1_ext32b,
      output reg [3  : 0]       rxdatak2_ext32b,
      output reg [3  : 0]       rxdatak3_ext32b,
      output reg [3  : 0]       rxdatak4_ext32b,
      output reg [3  : 0]       rxdatak5_ext32b,
      output reg [3  : 0]       rxdatak6_ext32b,
      output reg [3  : 0]       rxdatak7_ext32b,
      output reg                rxelecidle0_ext32b,
      output reg                rxelecidle1_ext32b,
      output reg                rxelecidle2_ext32b,
      output reg                rxelecidle3_ext32b,
      output reg                rxelecidle4_ext32b,
      output reg                rxelecidle5_ext32b,
      output reg                rxelecidle6_ext32b,
      output reg                rxelecidle7_ext32b,
      output reg                rxfreqlocked0_ext32b,
      output reg                rxfreqlocked1_ext32b,
      output reg                rxfreqlocked2_ext32b,
      output reg                rxfreqlocked3_ext32b,
      output reg                rxfreqlocked4_ext32b,
      output reg                rxfreqlocked5_ext32b,
      output reg                rxfreqlocked6_ext32b,
      output reg                rxfreqlocked7_ext32b,
      output reg [2 : 0]        rxstatus0_ext32b,
      output reg [2 : 0]        rxstatus1_ext32b,
      output reg [2 : 0]        rxstatus2_ext32b,
      output reg [2 : 0]        rxstatus3_ext32b,
      output reg [2 : 0]        rxstatus4_ext32b,
      output reg [2 : 0]        rxstatus5_ext32b,
      output reg [2 : 0]        rxstatus6_ext32b,
      output reg [2 : 0]        rxstatus7_ext32b,
      output reg                rxdataskip0_ext32b,
      output reg                rxdataskip1_ext32b,
      output reg                rxdataskip2_ext32b,
      output reg                rxdataskip3_ext32b,
      output reg                rxdataskip4_ext32b,
      output reg                rxdataskip5_ext32b,
      output reg                rxdataskip6_ext32b,
      output reg                rxdataskip7_ext32b,
      output reg                rxblkst0_ext32b,
      output reg                rxblkst1_ext32b,
      output reg                rxblkst2_ext32b,
      output reg                rxblkst3_ext32b,
      output reg                rxblkst4_ext32b,
      output reg                rxblkst5_ext32b,
      output reg                rxblkst6_ext32b,
      output reg                rxblkst7_ext32b,
      output reg [1 : 0]        rxsynchd0_ext32b,
      output reg [1 : 0]        rxsynchd1_ext32b,
      output reg [1 : 0]        rxsynchd2_ext32b,
      output reg [1 : 0]        rxsynchd3_ext32b,
      output reg [1 : 0]        rxsynchd4_ext32b,
      output reg [1 : 0]        rxsynchd5_ext32b,
      output reg [1 : 0]        rxsynchd6_ext32b,
      output reg [1 : 0]        rxsynchd7_ext32b,
      output reg                rxvalid0_ext32b,
      output reg                rxvalid1_ext32b,
      output reg                rxvalid2_ext32b,
      output reg                rxvalid3_ext32b,
      output reg                rxvalid4_ext32b,
      output reg                rxvalid5_ext32b,
      output reg                rxvalid6_ext32b,
      output reg                rxvalid7_ext32b
      );

   reg [1:0] cnt;
   reg [1:0] cnt_rx;
   genvar i;

   reg [23 : 0]       rxdata0_ext_i_32b;
   reg [23 : 0]       rxdata1_ext_i_32b;
   reg [23 : 0]       rxdata2_ext_i_32b;
   reg [23 : 0]       rxdata3_ext_i_32b;
   reg [23 : 0]       rxdata4_ext_i_32b;
   reg [23 : 0]       rxdata5_ext_i_32b;
   reg [23 : 0]       rxdata6_ext_i_32b;
   reg [23 : 0]       rxdata7_ext_i_32b;
   reg [2  : 0]       rxdatak0_ext_i_32b;
   reg [2  : 0]       rxdatak1_ext_i_32b;
   reg [2  : 0]       rxdatak2_ext_i_32b;
   reg [2  : 0]       rxdatak3_ext_i_32b;
   reg [2  : 0]       rxdatak4_ext_i_32b;
   reg [2  : 0]       rxdatak5_ext_i_32b;
   reg [2  : 0]       rxdatak6_ext_i_32b;
   reg [2  : 0]       rxdatak7_ext_i_32b;

   reg                phystatus0_ext_r_32b;
   reg                phystatus1_ext_r_32b;
   reg                phystatus2_ext_r_32b;
   reg                phystatus3_ext_r_32b;
   reg                phystatus4_ext_r_32b;
   reg                phystatus5_ext_r_32b;
   reg                phystatus6_ext_r_32b;
   reg                phystatus7_ext_r_32b;
   reg [31 : 0]       rxdata0_ext_r_32b;
   reg [31 : 0]       rxdata1_ext_r_32b;
   reg [31 : 0]       rxdata2_ext_r_32b;
   reg [31 : 0]       rxdata3_ext_r_32b;
   reg [31 : 0]       rxdata4_ext_r_32b;
   reg [31 : 0]       rxdata5_ext_r_32b;
   reg [31 : 0]       rxdata6_ext_r_32b;
   reg [31 : 0]       rxdata7_ext_r_32b;
   reg [3  : 0]       rxdatak0_ext_r_32b;
   reg [3  : 0]       rxdatak1_ext_r_32b;
   reg [3  : 0]       rxdatak2_ext_r_32b;
   reg [3  : 0]       rxdatak3_ext_r_32b;
   reg [3  : 0]       rxdatak4_ext_r_32b;
   reg [3  : 0]       rxdatak5_ext_r_32b;
   reg [3  : 0]       rxdatak6_ext_r_32b;
   reg [3  : 0]       rxdatak7_ext_r_32b;
   reg                rxelecidle0_ext_r_32b;
   reg                rxelecidle1_ext_r_32b;
   reg                rxelecidle2_ext_r_32b;
   reg                rxelecidle3_ext_r_32b;
   reg                rxelecidle4_ext_r_32b;
   reg                rxelecidle5_ext_r_32b;
   reg                rxelecidle6_ext_r_32b;
   reg                rxelecidle7_ext_r_32b;
   reg                rxfreqlocked0_ext_r_32b;
   reg                rxfreqlocked1_ext_r_32b;
   reg                rxfreqlocked2_ext_r_32b;
   reg                rxfreqlocked3_ext_r_32b;
   reg                rxfreqlocked4_ext_r_32b;
   reg                rxfreqlocked5_ext_r_32b;
   reg                rxfreqlocked6_ext_r_32b;
   reg                rxfreqlocked7_ext_r_32b;
   reg [2 : 0]        rxstatus0_ext_r_32b;
   reg [2 : 0]        rxstatus1_ext_r_32b;
   reg [2 : 0]        rxstatus2_ext_r_32b;
   reg [2 : 0]        rxstatus3_ext_r_32b;
   reg [2 : 0]        rxstatus4_ext_r_32b;
   reg [2 : 0]        rxstatus5_ext_r_32b;
   reg [2 : 0]        rxstatus6_ext_r_32b;
   reg [2 : 0]        rxstatus7_ext_r_32b;
   reg                rxdataskip0_ext_r_32b;
   reg                rxdataskip1_ext_r_32b;
   reg                rxdataskip2_ext_r_32b;
   reg                rxdataskip3_ext_r_32b;
   reg                rxdataskip4_ext_r_32b;
   reg                rxdataskip5_ext_r_32b;
   reg                rxdataskip6_ext_r_32b;
   reg                rxdataskip7_ext_r_32b;
   reg                rxblkst0_ext_r_32b;
   reg                rxblkst1_ext_r_32b;
   reg                rxblkst2_ext_r_32b;
   reg                rxblkst3_ext_r_32b;
   reg                rxblkst4_ext_r_32b;
   reg                rxblkst5_ext_r_32b;
   reg                rxblkst6_ext_r_32b;
   reg                rxblkst7_ext_r_32b;
   reg [1 : 0]        rxsynchd0_ext_r_32b;
   reg [1 : 0]        rxsynchd1_ext_r_32b;
   reg [1 : 0]        rxsynchd2_ext_r_32b;
   reg [1 : 0]        rxsynchd3_ext_r_32b;
   reg [1 : 0]        rxsynchd4_ext_r_32b;
   reg [1 : 0]        rxsynchd5_ext_r_32b;
   reg [1 : 0]        rxsynchd6_ext_r_32b;
   reg [1 : 0]        rxsynchd7_ext_r_32b;
   reg                rxvalid0_ext_r_32b;
   reg                rxvalid1_ext_r_32b;
   reg                rxvalid2_ext_r_32b;
   reg                rxvalid3_ext_r_32b;
   reg                rxvalid4_ext_r_32b;
   reg                rxvalid5_ext_r_32b;
   reg                rxvalid6_ext_r_32b;
   reg                rxvalid7_ext_r_32b;

   assign sim_pipe32_pclk = cnt[1];

   assign rxvalid_ext = rxvalid0_ext;

   always @(posedge sim_pipe32_pclk or negedge aclr) begin
      if (aclr == 1'b0) begin
        phystatus0_ext32b<=          0;
        phystatus1_ext32b<=          0;
        phystatus2_ext32b<=          0;
        phystatus3_ext32b<=          0;
        phystatus4_ext32b<=          0;
        phystatus5_ext32b<=          0;
        phystatus6_ext32b<=          0;
        phystatus7_ext32b<=          0;
        rxdata0_ext32b<=             0;
        rxdata1_ext32b<=             0;
        rxdata2_ext32b<=             0;
        rxdata3_ext32b<=             0;
        rxdata4_ext32b<=             0;
        rxdata5_ext32b<=             0;
        rxdata6_ext32b<=             0;
        rxdata7_ext32b<=             0;
        rxdatak0_ext32b<=            0;
        rxdatak1_ext32b<=            0;
        rxdatak2_ext32b<=            0;
        rxdatak3_ext32b<=            0;
        rxdatak4_ext32b<=            0;
        rxdatak5_ext32b<=            0;
        rxdatak6_ext32b<=            0;
        rxdatak7_ext32b<=            0;
        rxelecidle0_ext32b<=         0;
        rxelecidle1_ext32b<=         0;
        rxelecidle2_ext32b<=         0;
        rxelecidle3_ext32b<=         0;
        rxelecidle4_ext32b<=         0;
        rxelecidle5_ext32b<=         0;
        rxelecidle6_ext32b<=         0;
        rxelecidle7_ext32b<=         0;
        rxfreqlocked0_ext32b<=       0;
        rxfreqlocked1_ext32b<=       0;
        rxfreqlocked2_ext32b<=       0;
        rxfreqlocked3_ext32b<=       0;
        rxfreqlocked4_ext32b<=       0;
        rxfreqlocked5_ext32b<=       0;
        rxfreqlocked6_ext32b<=       0;
        rxfreqlocked7_ext32b<=       0;
        rxstatus0_ext32b<=           0;
        rxstatus1_ext32b<=           0;
        rxstatus2_ext32b<=           0;
        rxstatus3_ext32b<=           0;
        rxstatus4_ext32b<=           0;
        rxstatus5_ext32b<=           0;
        rxstatus6_ext32b<=           0;
        rxstatus7_ext32b<=           0;
        rxdataskip0_ext32b<=         0;
        rxdataskip1_ext32b<=         0;
        rxdataskip2_ext32b<=         0;
        rxdataskip3_ext32b<=         0;
        rxdataskip4_ext32b<=         0;
        rxdataskip5_ext32b<=         0;
        rxdataskip6_ext32b<=         0;
        rxdataskip7_ext32b<=         0;
        rxblkst0_ext32b<=            0;
        rxblkst1_ext32b<=            0;
        rxblkst2_ext32b<=            0;
        rxblkst3_ext32b<=            0;
        rxblkst4_ext32b<=            0;
        rxblkst5_ext32b<=            0;
        rxblkst6_ext32b<=            0;
        rxblkst7_ext32b<=            0;
        rxsynchd0_ext32b<=           0;
        rxsynchd1_ext32b<=           0;
        rxsynchd2_ext32b<=           0;
        rxsynchd3_ext32b<=           0;
        rxsynchd4_ext32b<=           0;
        rxsynchd5_ext32b<=           0;
        rxsynchd6_ext32b<=           0;
        rxsynchd7_ext32b<=           0;
        rxvalid0_ext32b<=            0;
        rxvalid1_ext32b<=            0;
        rxvalid2_ext32b<=            0;
        rxvalid3_ext32b<=            0;
        rxvalid4_ext32b<=            0;
        rxvalid5_ext32b<=            0;
        rxvalid6_ext32b<=            0;
        rxvalid7_ext32b<=            0;
      end
      else begin
        phystatus0_ext32b<=          phystatus0_ext_r_32b;
        phystatus1_ext32b<=          phystatus1_ext_r_32b;
        phystatus2_ext32b<=          phystatus2_ext_r_32b;
        phystatus3_ext32b<=          phystatus3_ext_r_32b;
        phystatus4_ext32b<=          phystatus4_ext_r_32b;
        phystatus5_ext32b<=          phystatus5_ext_r_32b;
        phystatus6_ext32b<=          phystatus6_ext_r_32b;
        phystatus7_ext32b<=          phystatus7_ext_r_32b;
        rxdata0_ext32b<=             rxdata0_ext_r_32b;
        rxdata1_ext32b<=             rxdata1_ext_r_32b;
        rxdata2_ext32b<=             rxdata2_ext_r_32b;
        rxdata3_ext32b<=             rxdata3_ext_r_32b;
        rxdata4_ext32b<=             rxdata4_ext_r_32b;
        rxdata5_ext32b<=             rxdata5_ext_r_32b;
        rxdata6_ext32b<=             rxdata6_ext_r_32b;
        rxdata7_ext32b<=             rxdata7_ext_r_32b;
        rxdatak0_ext32b<=            rxdatak0_ext_r_32b;
        rxdatak1_ext32b<=            rxdatak1_ext_r_32b;
        rxdatak2_ext32b<=            rxdatak2_ext_r_32b;
        rxdatak3_ext32b<=            rxdatak3_ext_r_32b;
        rxdatak4_ext32b<=            rxdatak4_ext_r_32b;
        rxdatak5_ext32b<=            rxdatak5_ext_r_32b;
        rxdatak6_ext32b<=            rxdatak6_ext_r_32b;
        rxdatak7_ext32b<=            rxdatak7_ext_r_32b;
        rxelecidle0_ext32b<=         rxelecidle0_ext_r_32b;
        rxelecidle1_ext32b<=         rxelecidle1_ext_r_32b;
        rxelecidle2_ext32b<=         rxelecidle2_ext_r_32b;
        rxelecidle3_ext32b<=         rxelecidle3_ext_r_32b;
        rxelecidle4_ext32b<=         rxelecidle4_ext_r_32b;
        rxelecidle5_ext32b<=         rxelecidle5_ext_r_32b;
        rxelecidle6_ext32b<=         rxelecidle6_ext_r_32b;
        rxelecidle7_ext32b<=         rxelecidle7_ext_r_32b;
        rxfreqlocked0_ext32b<=       rxfreqlocked0_ext_r_32b;
        rxfreqlocked1_ext32b<=       rxfreqlocked1_ext_r_32b;
        rxfreqlocked2_ext32b<=       rxfreqlocked2_ext_r_32b;
        rxfreqlocked3_ext32b<=       rxfreqlocked3_ext_r_32b;
        rxfreqlocked4_ext32b<=       rxfreqlocked4_ext_r_32b;
        rxfreqlocked5_ext32b<=       rxfreqlocked5_ext_r_32b;
        rxfreqlocked6_ext32b<=       rxfreqlocked6_ext_r_32b;
        rxfreqlocked7_ext32b<=       rxfreqlocked7_ext_r_32b;
        rxstatus0_ext32b<=           rxstatus0_ext_r_32b;
        rxstatus1_ext32b<=           rxstatus1_ext_r_32b;
        rxstatus2_ext32b<=           rxstatus2_ext_r_32b;
        rxstatus3_ext32b<=           rxstatus3_ext_r_32b;
        rxstatus4_ext32b<=           rxstatus4_ext_r_32b;
        rxstatus5_ext32b<=           rxstatus5_ext_r_32b;
        rxstatus6_ext32b<=           rxstatus6_ext_r_32b;
        rxstatus7_ext32b<=           rxstatus7_ext_r_32b;
        rxdataskip0_ext32b<=         rxdataskip0_ext_r_32b;
        rxdataskip1_ext32b<=         rxdataskip1_ext_r_32b;
        rxdataskip2_ext32b<=         rxdataskip2_ext_r_32b;
        rxdataskip3_ext32b<=         rxdataskip3_ext_r_32b;
        rxdataskip4_ext32b<=         rxdataskip4_ext_r_32b;
        rxdataskip5_ext32b<=         rxdataskip5_ext_r_32b;
        rxdataskip6_ext32b<=         rxdataskip6_ext_r_32b;
        rxdataskip7_ext32b<=         rxdataskip7_ext_r_32b;
        rxblkst0_ext32b<=            rxblkst0_ext_r_32b;
        rxblkst1_ext32b<=            rxblkst1_ext_r_32b;
        rxblkst2_ext32b<=            rxblkst2_ext_r_32b;
        rxblkst3_ext32b<=            rxblkst3_ext_r_32b;
        rxblkst4_ext32b<=            rxblkst4_ext_r_32b;
        rxblkst5_ext32b<=            rxblkst5_ext_r_32b;
        rxblkst6_ext32b<=            rxblkst6_ext_r_32b;
        rxblkst7_ext32b<=            rxblkst7_ext_r_32b;
        rxsynchd0_ext32b<=           rxsynchd0_ext_r_32b;
        rxsynchd1_ext32b<=           rxsynchd1_ext_r_32b;
        rxsynchd2_ext32b<=           rxsynchd2_ext_r_32b;
        rxsynchd3_ext32b<=           rxsynchd3_ext_r_32b;
        rxsynchd4_ext32b<=           rxsynchd4_ext_r_32b;
        rxsynchd5_ext32b<=           rxsynchd5_ext_r_32b;
        rxsynchd6_ext32b<=           rxsynchd6_ext_r_32b;
        rxsynchd7_ext32b<=           rxsynchd7_ext_r_32b;
        rxvalid0_ext32b<=            rxvalid0_ext_r_32b;
        rxvalid1_ext32b<=            rxvalid1_ext_r_32b;
        rxvalid2_ext32b<=            rxvalid2_ext_r_32b;
        rxvalid3_ext32b<=            rxvalid3_ext_r_32b;
        rxvalid4_ext32b<=            rxvalid4_ext_r_32b;
        rxvalid5_ext32b<=            rxvalid5_ext_r_32b;
        rxvalid6_ext32b<=            rxvalid6_ext_r_32b;
        rxvalid7_ext32b<=            rxvalid7_ext_r_32b;
      end
   end

   always @(posedge sim_pipe8_pclk or negedge aclr) begin
      if (aclr == 1'b0) begin
         cnt <=4'h0;
         phystatus0_ext_r_32b       <= 0;
         phystatus1_ext_r_32b       <= 0;
         phystatus2_ext_r_32b       <= 0;
         phystatus3_ext_r_32b       <= 0;
         phystatus4_ext_r_32b       <= 0;
         phystatus5_ext_r_32b       <= 0;
         phystatus6_ext_r_32b       <= 0;
         phystatus7_ext_r_32b       <= 0;
         rxelecidle0_ext_r_32b      <= 0;
         rxelecidle1_ext_r_32b      <= 0;
         rxelecidle2_ext_r_32b      <= 0;
         rxelecidle3_ext_r_32b      <= 0;
         rxelecidle4_ext_r_32b      <= 0;
         rxelecidle5_ext_r_32b      <= 0;
         rxelecidle6_ext_r_32b      <= 0;
         rxelecidle7_ext_r_32b      <= 0;
         rxfreqlocked0_ext_r_32b    <= 0;
         rxfreqlocked1_ext_r_32b    <= 0;
         rxfreqlocked2_ext_r_32b    <= 0;
         rxfreqlocked3_ext_r_32b    <= 0;
         rxfreqlocked4_ext_r_32b    <= 0;
         rxfreqlocked5_ext_r_32b    <= 0;
         rxfreqlocked6_ext_r_32b    <= 0;
         rxfreqlocked7_ext_r_32b    <= 0;
         rxstatus0_ext_r_32b        <= 0;
         rxstatus1_ext_r_32b        <= 0;
         rxstatus2_ext_r_32b        <= 0;
         rxstatus3_ext_r_32b        <= 0;
         rxstatus4_ext_r_32b        <= 0;
         rxstatus5_ext_r_32b        <= 0;
         rxstatus6_ext_r_32b        <= 0;
         rxstatus7_ext_r_32b        <= 0;
         rxdataskip0_ext_r_32b      <= 0;
         rxdataskip1_ext_r_32b      <= 0;
         rxdataskip2_ext_r_32b      <= 0;
         rxdataskip3_ext_r_32b      <= 0;
         rxdataskip4_ext_r_32b      <= 0;
         rxdataskip5_ext_r_32b      <= 0;
         rxdataskip6_ext_r_32b      <= 0;
         rxdataskip7_ext_r_32b      <= 0;
         rxblkst0_ext_r_32b         <= 0;
         rxblkst1_ext_r_32b         <= 0;
         rxblkst2_ext_r_32b         <= 0;
         rxblkst3_ext_r_32b         <= 0;
         rxblkst4_ext_r_32b         <= 0;
         rxblkst5_ext_r_32b         <= 0;
         rxblkst6_ext_r_32b         <= 0;
         rxblkst7_ext_r_32b         <= 0;
         rxsynchd0_ext_r_32b        <= 0;
         rxsynchd1_ext_r_32b        <= 0;
         rxsynchd2_ext_r_32b        <= 0;
         rxsynchd3_ext_r_32b        <= 0;
         rxsynchd4_ext_r_32b        <= 0;
         rxsynchd5_ext_r_32b        <= 0;
         rxsynchd6_ext_r_32b        <= 0;
         rxsynchd7_ext_r_32b        <= 0;
         rxvalid0_ext_r_32b         <= 0;
         rxvalid1_ext_r_32b         <= 0;
         rxvalid2_ext_r_32b         <= 0;
         rxvalid3_ext_r_32b         <= 0;
         rxvalid4_ext_r_32b         <= 0;
         rxvalid5_ext_r_32b         <= 0;
         rxvalid6_ext_r_32b         <= 0;
         rxvalid7_ext_r_32b         <= 0;
         {rxdata0_ext_r_32b, rxdatak0_ext_r_32b}<=36'h0;
         {rxdata1_ext_r_32b, rxdatak1_ext_r_32b}<=36'h0;
         {rxdata2_ext_r_32b, rxdatak2_ext_r_32b}<=36'h0;
         {rxdata3_ext_r_32b, rxdatak3_ext_r_32b}<=36'h0;
         {rxdata4_ext_r_32b, rxdatak4_ext_r_32b}<=36'h0;
         {rxdata5_ext_r_32b, rxdatak5_ext_r_32b}<=36'h0;
         {rxdata6_ext_r_32b, rxdatak6_ext_r_32b}<=36'h0;
         {rxdata7_ext_r_32b, rxdatak7_ext_r_32b}<=36'h0;
      end
      else begin
         if (rxvalid_ext==1'b1) begin
               cnt_rx <=cnt_rx+2'h1;
         end
         else begin
               cnt_rx <=2'h0;
         end

         if (cnt_rx==2'b11) begin
            {rxdata0_ext_r_32b, rxdatak0_ext_r_32b}<= (rxvalid0_ext==1'b0)?36'h0:{rxdata0_ext,rxdata0_ext_i_32b[23:0], rxdatak0_ext, rxdatak0_ext_i_32b[2:0]};
            {rxdata1_ext_r_32b, rxdatak1_ext_r_32b}<= (rxvalid1_ext==1'b0)?36'h0:{rxdata1_ext,rxdata1_ext_i_32b[23:0], rxdatak1_ext, rxdatak1_ext_i_32b[2:0]};
            {rxdata2_ext_r_32b, rxdatak2_ext_r_32b}<= (rxvalid2_ext==1'b0)?36'h0:{rxdata2_ext,rxdata2_ext_i_32b[23:0], rxdatak2_ext, rxdatak2_ext_i_32b[2:0]};
            {rxdata3_ext_r_32b, rxdatak3_ext_r_32b}<= (rxvalid3_ext==1'b0)?36'h0:{rxdata3_ext,rxdata3_ext_i_32b[23:0], rxdatak3_ext, rxdatak3_ext_i_32b[2:0]};
            {rxdata4_ext_r_32b, rxdatak4_ext_r_32b}<= (rxvalid4_ext==1'b0)?36'h0:{rxdata4_ext,rxdata4_ext_i_32b[23:0], rxdatak4_ext, rxdatak4_ext_i_32b[2:0]};
            {rxdata5_ext_r_32b, rxdatak5_ext_r_32b}<= (rxvalid5_ext==1'b0)?36'h0:{rxdata5_ext,rxdata5_ext_i_32b[23:0], rxdatak5_ext, rxdatak5_ext_i_32b[2:0]};
            {rxdata6_ext_r_32b, rxdatak6_ext_r_32b}<= (rxvalid6_ext==1'b0)?36'h0:{rxdata6_ext,rxdata6_ext_i_32b[23:0], rxdatak6_ext, rxdatak6_ext_i_32b[2:0]};
            {rxdata7_ext_r_32b, rxdatak7_ext_r_32b}<= (rxvalid7_ext==1'b0)?36'h0:{rxdata7_ext,rxdata7_ext_i_32b[23:0], rxdatak7_ext, rxdatak7_ext_i_32b[2:0]};
         end

         if (1==1) begin
            cnt <=cnt+2'h1;
            phystatus0_ext_r_32b       <= ((phystatus0_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus0_ext:1'b1;
            phystatus1_ext_r_32b       <= ((phystatus1_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus1_ext:1'b1;
            phystatus2_ext_r_32b       <= ((phystatus2_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus2_ext:1'b1;
            phystatus3_ext_r_32b       <= ((phystatus3_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus3_ext:1'b1;
            phystatus4_ext_r_32b       <= ((phystatus4_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus4_ext:1'b1;
            phystatus5_ext_r_32b       <= ((phystatus5_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus5_ext:1'b1;
            phystatus6_ext_r_32b       <= ((phystatus6_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus6_ext:1'b1;
            phystatus7_ext_r_32b       <= ((phystatus7_ext_r_32b==1'b0)||(cnt==2'b11))?phystatus7_ext:1'b1;
            rxelecidle0_ext_r_32b      <= rxelecidle0_ext;
            rxelecidle1_ext_r_32b      <= rxelecidle1_ext;
            rxelecidle2_ext_r_32b      <= rxelecidle2_ext;
            rxelecidle3_ext_r_32b      <= rxelecidle3_ext;
            rxelecidle4_ext_r_32b      <= rxelecidle4_ext;
            rxelecidle5_ext_r_32b      <= rxelecidle5_ext;
            rxelecidle6_ext_r_32b      <= rxelecidle6_ext;
            rxelecidle7_ext_r_32b      <= rxelecidle7_ext;
            rxfreqlocked0_ext_r_32b    <= rxfreqlocked0_ext;
            rxfreqlocked1_ext_r_32b    <= rxfreqlocked1_ext;
            rxfreqlocked2_ext_r_32b    <= rxfreqlocked2_ext;
            rxfreqlocked3_ext_r_32b    <= rxfreqlocked3_ext;
            rxfreqlocked4_ext_r_32b    <= rxfreqlocked4_ext;
            rxfreqlocked5_ext_r_32b    <= rxfreqlocked5_ext;
            rxfreqlocked6_ext_r_32b    <= rxfreqlocked6_ext;
            rxfreqlocked7_ext_r_32b    <= rxfreqlocked7_ext;
            rxstatus0_ext_r_32b        <= ((rxstatus0_ext_r_32b==3'h4)||(rxstatus0_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus0_ext:3'h3;
            rxstatus1_ext_r_32b        <= ((rxstatus1_ext_r_32b==3'h4)||(rxstatus1_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus1_ext:3'h3;
            rxstatus2_ext_r_32b        <= ((rxstatus2_ext_r_32b==3'h4)||(rxstatus2_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus2_ext:3'h3;
            rxstatus3_ext_r_32b        <= ((rxstatus3_ext_r_32b==3'h4)||(rxstatus3_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus3_ext:3'h3;
            rxstatus4_ext_r_32b        <= ((rxstatus4_ext_r_32b==3'h4)||(rxstatus4_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus4_ext:3'h3;
            rxstatus5_ext_r_32b        <= ((rxstatus5_ext_r_32b==3'h4)||(rxstatus5_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus5_ext:3'h3;
            rxstatus6_ext_r_32b        <= ((rxstatus6_ext_r_32b==3'h4)||(rxstatus6_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus6_ext:3'h3;
            rxstatus7_ext_r_32b        <= ((rxstatus7_ext_r_32b==3'h4)||(rxstatus7_ext_r_32b==3'h0)||(cnt==2'b11))?rxstatus7_ext:3'h3;
            rxdataskip0_ext_r_32b      <= rxdataskip0_ext;
            rxdataskip1_ext_r_32b      <= rxdataskip1_ext;
            rxdataskip2_ext_r_32b      <= rxdataskip2_ext;
            rxdataskip3_ext_r_32b      <= rxdataskip3_ext;
            rxdataskip4_ext_r_32b      <= rxdataskip4_ext;
            rxdataskip5_ext_r_32b      <= rxdataskip5_ext;
            rxdataskip6_ext_r_32b      <= rxdataskip6_ext;
            rxdataskip7_ext_r_32b      <= rxdataskip7_ext;
            rxblkst0_ext_r_32b         <= rxblkst0_ext;
            rxblkst1_ext_r_32b         <= rxblkst1_ext;
            rxblkst2_ext_r_32b         <= rxblkst2_ext;
            rxblkst3_ext_r_32b         <= rxblkst3_ext;
            rxblkst4_ext_r_32b         <= rxblkst4_ext;
            rxblkst5_ext_r_32b         <= rxblkst5_ext;
            rxblkst6_ext_r_32b         <= rxblkst6_ext;
            rxblkst7_ext_r_32b         <= rxblkst7_ext;
            rxsynchd0_ext_r_32b        <= rxsynchd0_ext;
            rxsynchd1_ext_r_32b        <= rxsynchd1_ext;
            rxsynchd2_ext_r_32b        <= rxsynchd2_ext;
            rxsynchd3_ext_r_32b        <= rxsynchd3_ext;
            rxsynchd4_ext_r_32b        <= rxsynchd4_ext;
            rxsynchd5_ext_r_32b        <= rxsynchd5_ext;
            rxsynchd6_ext_r_32b        <= rxsynchd6_ext;
            rxsynchd7_ext_r_32b        <= rxsynchd7_ext;
            rxvalid0_ext_r_32b         <= rxvalid0_ext;
            rxvalid1_ext_r_32b         <= rxvalid1_ext;
            rxvalid2_ext_r_32b         <= rxvalid2_ext;
            rxvalid3_ext_r_32b         <= rxvalid3_ext;
            rxvalid4_ext_r_32b         <= rxvalid4_ext;
            rxvalid5_ext_r_32b         <= rxvalid5_ext;
            rxvalid6_ext_r_32b         <= rxvalid6_ext;
            rxvalid7_ext_r_32b         <= rxvalid7_ext;
         end
      end
   end

   generate
      for (i=0;i<3;i=i+1) begin : g_pipe
         always @(posedge sim_pipe8_pclk or negedge aclr) begin
            if (aclr == 1'b0) begin
               rxdata0_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata1_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata2_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata3_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata4_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata5_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata6_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
               rxdata7_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;

               rxdatak0_ext_i_32b[i] <= 1'h0;
               rxdatak1_ext_i_32b[i] <= 1'h0;
               rxdatak2_ext_i_32b[i] <= 1'h0;
               rxdatak3_ext_i_32b[i] <= 1'h0;
               rxdatak4_ext_i_32b[i] <= 1'h0;
               rxdatak5_ext_i_32b[i] <= 1'h0;
               rxdatak6_ext_i_32b[i] <= 1'h0;
               rxdatak7_ext_i_32b[i] <= 1'h0;
            end
            else begin
               if (cnt_rx==i) begin
                  rxdata0_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata0_ext[7:0];
                  rxdata1_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata1_ext[7:0];
                  rxdata2_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata2_ext[7:0];
                  rxdata3_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata3_ext[7:0];
                  rxdata4_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata4_ext[7:0];
                  rxdata5_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata5_ext[7:0];
                  rxdata6_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata6_ext[7:0];
                  rxdata7_ext_i_32b[((i+1)*8)-1:i*8] <= rxdata7_ext[7:0];

                  rxdatak0_ext_i_32b[i] <= rxdatak0_ext;
                  rxdatak1_ext_i_32b[i] <= rxdatak1_ext;
                  rxdatak2_ext_i_32b[i] <= rxdatak2_ext;
                  rxdatak3_ext_i_32b[i] <= rxdatak3_ext;
                  rxdatak4_ext_i_32b[i] <= rxdatak4_ext;
                  rxdatak5_ext_i_32b[i] <= rxdatak5_ext;
                  rxdatak6_ext_i_32b[i] <= rxdatak6_ext;
                  rxdatak7_ext_i_32b[i] <= rxdatak7_ext;
               end
               else if (((cnt_rx==0) && (i>0)) || (cnt_rx==i-1)) begin
                  rxdata0_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata1_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata2_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata3_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata4_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata5_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata6_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;
                  rxdata7_ext_i_32b[((i+1)*8)-1:i*8] <= 8'h0;

                  rxdatak0_ext_i_32b[i] <= 1'h0;
                  rxdatak1_ext_i_32b[i] <= 1'h0;
                  rxdatak2_ext_i_32b[i] <= 1'h0;
                  rxdatak3_ext_i_32b[i] <= 1'h0;
                  rxdatak4_ext_i_32b[i] <= 1'h0;
                  rxdatak5_ext_i_32b[i] <= 1'h0;
                  rxdatak6_ext_i_32b[i] <= 1'h0;
                  rxdatak7_ext_i_32b[i] <= 1'h0;
               end
            end
         end
      end
   endgenerate

endmodule

module sim_txpipe_8bit_to_32_bit (
      input                 sim_pipe8_pclk,
      input                 sim_pipe32_pclk,
      input                 aclr,
      input                 pipe_mode_simu_only,

      input [2 : 0]        eidleinfersel0,
      input [2 : 0]        eidleinfersel1,
      input [2 : 0]        eidleinfersel2,
      input [2 : 0]        eidleinfersel3,
      input [2 : 0]        eidleinfersel4,
      input [2 : 0]        eidleinfersel5,
      input [2 : 0]        eidleinfersel6,
      input [2 : 0]        eidleinfersel7,
      input [1 : 0]        powerdown0,
      input [1 : 0]        powerdown1,
      input [1 : 0]        powerdown2,
      input [1 : 0]        powerdown3,
      input [1 : 0]        powerdown4,
      input [1 : 0]        powerdown5,
      input [1 : 0]        powerdown6,
      input [1 : 0]        powerdown7,
      input                rxpolarity0,
      input                rxpolarity1,
      input                rxpolarity2,
      input                rxpolarity3,
      input                rxpolarity4,
      input                rxpolarity5,
      input                rxpolarity6,
      input                rxpolarity7,
      input                txcompl0,
      input                txcompl1,
      input                txcompl2,
      input                txcompl3,
      input                txcompl4,
      input                txcompl5,
      input                txcompl6,
      input                txcompl7,
      input [31 : 0]       txdata0,
      input [31 : 0]       txdata1,
      input [31 : 0]       txdata2,
      input [31 : 0]       txdata3,
      input [31 : 0]       txdata4,
      input [31 : 0]       txdata5,
      input [31 : 0]       txdata6,
      input [31 : 0]       txdata7,
      input [3 : 0]        txdatak0,
      input [3 : 0]        txdatak1,
      input [3 : 0]        txdatak2,
      input [3 : 0]        txdatak3,
      input [3 : 0]        txdatak4,
      input [3 : 0]        txdatak5,
      input [3 : 0]        txdatak6,
      input [3 : 0]        txdatak7,
      //input                txdatavalid0,
      //input                txdatavalid1,
      //input                txdatavalid2,
      //input                txdatavalid3,
      //input                txdatavalid4,
      //input                txdatavalid5,
      //input                txdatavalid6,
      //input                txdatavalid7,
      input                txdetectrx0,
      input                txdetectrx1,
      input                txdetectrx2,
      input                txdetectrx3,
      input                txdetectrx4,
      input                txdetectrx5,
      input                txdetectrx6,
      input                txdetectrx7,
      input                txelecidle0,
      input                txelecidle1,
      input                txelecidle2,
      input                txelecidle3,
      input                txelecidle4,
      input                txelecidle5,
      input                txelecidle6,
      input                txelecidle7,
      input [2 : 0]        txmargin0,
      input [2 : 0]        txmargin1,
      input [2 : 0]        txmargin2,
      input [2 : 0]        txmargin3,
      input [2 : 0]        txmargin4,
      input [2 : 0]        txmargin5,
      input [2 : 0]        txmargin6,
      input [2 : 0]        txmargin7,
      input                txdeemph0,
      input                txdeemph1,
      input                txdeemph2,
      input                txdeemph3,
      input                txdeemph4,
      input                txdeemph5,
      input                txdeemph6,
      input                txdeemph7,
      input                txblkst0,
      input                txblkst1,
      input                txblkst2,
      input                txblkst3,
      input                txblkst4,
      input                txblkst5,
      input                txblkst6,
      input                txblkst7,
      input [1 : 0]        txsynchd0,
      input [1 : 0]        txsynchd1,
      input [1 : 0]        txsynchd2,
      input [1 : 0]        txsynchd3,
      input [1 : 0]        txsynchd4,
      input [1 : 0]        txsynchd5,
      input [1 : 0]        txsynchd6,
      input [1 : 0]        txsynchd7,
      input [17 : 0]       currentcoeff0,
      input [17 : 0]       currentcoeff1,
      input [17 : 0]       currentcoeff2,
      input [17 : 0]       currentcoeff3,
      input [17 : 0]       currentcoeff4,
      input [17 : 0]       currentcoeff5,
      input [17 : 0]       currentcoeff6,
      input [17 : 0]       currentcoeff7,
      input [2 : 0]        currentrxpreset0,
      input [2 : 0]        currentrxpreset1,
      input [2 : 0]        currentrxpreset2,
      input [2 : 0]        currentrxpreset3,
      input [2 : 0]        currentrxpreset4,
      input [2 : 0]        currentrxpreset5,
      input [2 : 0]        currentrxpreset6,
      input [2 : 0]        currentrxpreset7,

      output [2 : 0]   eidleinfersel0_ext,
      output [2 : 0]   eidleinfersel1_ext,
      output [2 : 0]   eidleinfersel2_ext,
      output [2 : 0]   eidleinfersel3_ext,
      output [2 : 0]   eidleinfersel4_ext,
      output [2 : 0]   eidleinfersel5_ext,
      output [2 : 0]   eidleinfersel6_ext,
      output [2 : 0]   eidleinfersel7_ext,
      output [1 : 0]   powerdown0_ext,
      output [1 : 0]   powerdown1_ext,
      output [1 : 0]   powerdown2_ext,
      output [1 : 0]   powerdown3_ext,
      output [1 : 0]   powerdown4_ext,
      output [1 : 0]   powerdown5_ext,
      output [1 : 0]   powerdown6_ext,
      output [1 : 0]   powerdown7_ext,
      output           rxpolarity0_ext,
      output           rxpolarity1_ext,
      output           rxpolarity2_ext,
      output           rxpolarity3_ext,
      output           rxpolarity4_ext,
      output           rxpolarity5_ext,
      output           rxpolarity6_ext,
      output           rxpolarity7_ext,
      output           txcompl0_ext,
      output           txcompl1_ext,
      output           txcompl2_ext,
      output           txcompl3_ext,
      output           txcompl4_ext,
      output           txcompl5_ext,
      output           txcompl6_ext,
      output           txcompl7_ext,
      output [7 : 0]   txdata0_ext,
      output [7 : 0]   txdata1_ext,
      output [7 : 0]   txdata2_ext,
      output [7 : 0]   txdata3_ext,
      output [7 : 0]   txdata4_ext,
      output [7 : 0]   txdata5_ext,
      output [7 : 0]   txdata6_ext,
      output [7 : 0]   txdata7_ext,
      output           txdatak0_ext,
      output           txdatak1_ext,
      output           txdatak2_ext,
      output           txdatak3_ext,
      output           txdatak4_ext,
      output           txdatak5_ext,
      output           txdatak6_ext,
      output           txdatak7_ext,
      output           txdetectrx0_ext,
      output           txdetectrx1_ext,
      output           txdetectrx2_ext,
      output           txdetectrx3_ext,
      output           txdetectrx4_ext,
      output           txdetectrx5_ext,
      output           txdetectrx6_ext,
      output           txdetectrx7_ext,
      output           txelecidle0_ext,
      output           txelecidle1_ext,
      output           txelecidle2_ext,
      output           txelecidle3_ext,
      output           txelecidle4_ext,
      output           txelecidle5_ext,
      output           txelecidle6_ext,
      output           txelecidle7_ext,
      output [2 : 0]   txmargin0_ext,
      output [2 : 0]   txmargin1_ext,
      output [2 : 0]   txmargin2_ext,
      output [2 : 0]   txmargin3_ext,
      output [2 : 0]   txmargin4_ext,
      output [2 : 0]   txmargin5_ext,
      output [2 : 0]   txmargin6_ext,
      output [2 : 0]   txmargin7_ext,
      output           txdeemph0_ext,
      output           txdeemph1_ext,
      output           txdeemph2_ext,
      output           txdeemph3_ext,
      output           txdeemph4_ext,
      output           txdeemph5_ext,
      output           txdeemph6_ext,
      output           txdeemph7_ext,
      output           txblkst0_ext,
      output           txblkst1_ext,
      output           txblkst2_ext,
      output           txblkst3_ext,
      output           txblkst4_ext,
      output           txblkst5_ext,
      output           txblkst6_ext,
      output           txblkst7_ext,
      output [1 : 0]   txsynchd0_ext,
      output [1 : 0]   txsynchd1_ext,
      output [1 : 0]   txsynchd2_ext,
      output [1 : 0]   txsynchd3_ext,
      output [1 : 0]   txsynchd4_ext,
      output [1 : 0]   txsynchd5_ext,
      output [1 : 0]   txsynchd6_ext,
      output [1 : 0]   txsynchd7_ext,
      output [17 : 0]  currentcoeff0_ext,
      output [17 : 0]  currentcoeff1_ext,
      output [17 : 0]  currentcoeff2_ext,
      output [17 : 0]  currentcoeff3_ext,
      output [17 : 0]  currentcoeff4_ext,
      output [17 : 0]  currentcoeff5_ext,
      output [17 : 0]  currentcoeff6_ext,
      output [17 : 0]  currentcoeff7_ext,
      output [2 : 0]   currentrxpreset0_ext,
      output [2 : 0]   currentrxpreset1_ext,
      output [2 : 0]   currentrxpreset2_ext,
      output [2 : 0]   currentrxpreset3_ext,
      output [2 : 0]   currentrxpreset4_ext,
      output [2 : 0]   currentrxpreset5_ext,
      output [2 : 0]   currentrxpreset6_ext,
      output [2 : 0]   currentrxpreset7_ext

      );

   reg [1:0] cnt_tx;
   wire txelecidle;

   assign txelecidle = txelecidle0&
                       txelecidle1&
                       txelecidle2&
                       txelecidle3&
                       txelecidle4&
                       txelecidle5&
                       txelecidle6&
                       txelecidle7;

   always @(posedge sim_pipe8_pclk or negedge aclr) begin
      if (aclr == 1'b0) begin
         cnt_tx <=2'h0;
      end
      else begin
         if (txelecidle==1'b0) begin
            cnt_tx <=cnt_tx+2'h1;
         end
         else begin
            cnt_tx <=2'h0;
         end
      end
   end

   assign txdata0_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata0[7:0]: (cnt_tx==2'b01)?txdata0[15:8] : (cnt_tx==2'b10)?txdata0[23:16] : txdata0[31:24];
   assign txdata1_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata1[7:0]: (cnt_tx==2'b01)?txdata1[15:8] : (cnt_tx==2'b10)?txdata1[23:16] : txdata1[31:24];
   assign txdata2_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata2[7:0]: (cnt_tx==2'b01)?txdata2[15:8] : (cnt_tx==2'b10)?txdata2[23:16] : txdata2[31:24];
   assign txdata3_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata3[7:0]: (cnt_tx==2'b01)?txdata3[15:8] : (cnt_tx==2'b10)?txdata3[23:16] : txdata3[31:24];
   assign txdata4_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata4[7:0]: (cnt_tx==2'b01)?txdata4[15:8] : (cnt_tx==2'b10)?txdata4[23:16] : txdata4[31:24];
   assign txdata5_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata5[7:0]: (cnt_tx==2'b01)?txdata5[15:8] : (cnt_tx==2'b10)?txdata5[23:16] : txdata5[31:24];
   assign txdata6_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata6[7:0]: (cnt_tx==2'b01)?txdata6[15:8] : (cnt_tx==2'b10)?txdata6[23:16] : txdata6[31:24];
   assign txdata7_ext                    = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdata7[7:0]: (cnt_tx==2'b01)?txdata7[15:8] : (cnt_tx==2'b10)?txdata7[23:16] : txdata7[31:24];
   assign txdatak0_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak0[ 0]: (cnt_tx==2'b01)?txdatak0[  1] : (cnt_tx==2'b10)?txdatak0[   2] : txdatak0[   3];
   assign txdatak1_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak1[ 0]: (cnt_tx==2'b01)?txdatak1[  1] : (cnt_tx==2'b10)?txdatak1[   2] : txdatak1[   3];
   assign txdatak2_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak2[ 0]: (cnt_tx==2'b01)?txdatak2[  1] : (cnt_tx==2'b10)?txdatak2[   2] : txdatak2[   3];
   assign txdatak3_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak3[ 0]: (cnt_tx==2'b01)?txdatak3[  1] : (cnt_tx==2'b10)?txdatak3[   2] : txdatak3[   3];
   assign txdatak4_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak4[ 0]: (cnt_tx==2'b01)?txdatak4[  1] : (cnt_tx==2'b10)?txdatak4[   2] : txdatak4[   3];
   assign txdatak5_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak5[ 0]: (cnt_tx==2'b01)?txdatak5[  1] : (cnt_tx==2'b10)?txdatak5[   2] : txdatak5[   3];
   assign txdatak6_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak6[ 0]: (cnt_tx==2'b01)?txdatak6[  1] : (cnt_tx==2'b10)?txdatak6[   2] : txdatak6[   3];
   assign txdatak7_ext                   = (pipe_mode_simu_only==1'b0)?0:(cnt_tx==2'b00)?txdatak7[ 0]: (cnt_tx==2'b01)?txdatak7[  1] : (cnt_tx==2'b10)?txdatak7[   2] : txdatak7[   3];

   assign eidleinfersel0_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel0                ;
   assign eidleinfersel1_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel1                ;
   assign eidleinfersel2_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel2                ;
   assign eidleinfersel3_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel3                ;
   assign eidleinfersel4_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel4                ;
   assign eidleinfersel5_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel5                ;
   assign eidleinfersel6_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel6                ;
   assign eidleinfersel7_ext             = (pipe_mode_simu_only==1'b0)?0:eidleinfersel7                ;
   assign powerdown0_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown0                    ;
   assign powerdown1_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown1                    ;
   assign powerdown2_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown2                    ;
   assign powerdown3_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown3                    ;
   assign powerdown4_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown4                    ;
   assign powerdown5_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown5                    ;
   assign powerdown6_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown6                    ;
   assign powerdown7_ext                 = (pipe_mode_simu_only==1'b0)?0:powerdown7                    ;
   assign rxpolarity0_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity0                   ;
   assign rxpolarity1_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity1                   ;
   assign rxpolarity2_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity2                   ;
   assign rxpolarity3_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity3                   ;
   assign rxpolarity4_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity4                   ;
   assign rxpolarity5_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity5                   ;
   assign rxpolarity6_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity6                   ;
   assign rxpolarity7_ext                = (pipe_mode_simu_only==1'b0)?0:rxpolarity7                   ;
   assign txcompl0_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl0                      ;
   assign txcompl1_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl1                      ;
   assign txcompl2_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl2                      ;
   assign txcompl3_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl3                      ;
   assign txcompl4_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl4                      ;
   assign txcompl5_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl5                      ;
   assign txcompl6_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl6                      ;
   assign txcompl7_ext                   = (pipe_mode_simu_only==1'b0)?0:txcompl7                      ;

   assign txdetectrx0_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx0                   ;
   assign txdetectrx1_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx1                   ;
   assign txdetectrx2_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx2                   ;
   assign txdetectrx3_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx3                   ;
   assign txdetectrx4_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx4                   ;
   assign txdetectrx5_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx5                   ;
   assign txdetectrx6_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx6                   ;
   assign txdetectrx7_ext                = (pipe_mode_simu_only==1'b0)?0:txdetectrx7                   ;
   assign txelecidle0_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle0                   ;
   assign txelecidle1_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle1                   ;
   assign txelecidle2_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle2                   ;
   assign txelecidle3_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle3                   ;
   assign txelecidle4_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle4                   ;
   assign txelecidle5_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle5                   ;
   assign txelecidle6_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle6                   ;
   assign txelecidle7_ext                = (pipe_mode_simu_only==1'b0)?0:txelecidle7                   ;
   assign txmargin0_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin0                     ;
   assign txmargin1_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin1                     ;
   assign txmargin2_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin2                     ;
   assign txmargin3_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin3                     ;
   assign txmargin4_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin4                     ;
   assign txmargin5_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin5                     ;
   assign txmargin6_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin6                     ;
   assign txmargin7_ext                  = (pipe_mode_simu_only==1'b0)?0:txmargin7                     ;
   assign txdeemph0_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph0                     ;
   assign txdeemph1_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph1                     ;
   assign txdeemph2_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph2                     ;
   assign txdeemph3_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph3                     ;
   assign txdeemph4_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph4                     ;
   assign txdeemph5_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph5                     ;
   assign txdeemph6_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph6                     ;
   assign txdeemph7_ext                  = (pipe_mode_simu_only==1'b0)?0:txdeemph7                     ;
   assign txblkst0_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst0                      ;
   assign txblkst1_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst1                      ;
   assign txblkst2_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst2                      ;
   assign txblkst3_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst3                      ;
   assign txblkst4_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst4                      ;
   assign txblkst5_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst5                      ;
   assign txblkst6_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst6                      ;
   assign txblkst7_ext                   = (pipe_mode_simu_only==1'b0)?0:txblkst7                      ;
   assign txsynchd0_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd0                     ;
   assign txsynchd1_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd1                     ;
   assign txsynchd2_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd2                     ;
   assign txsynchd3_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd3                     ;
   assign txsynchd4_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd4                     ;
   assign txsynchd5_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd5                     ;
   assign txsynchd6_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd6                     ;
   assign txsynchd7_ext                  = (pipe_mode_simu_only==1'b0)?0:txsynchd7                     ;
   assign currentcoeff0_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff0                 ;
   assign currentcoeff1_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff1                 ;
   assign currentcoeff2_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff2                 ;
   assign currentcoeff3_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff3                 ;
   assign currentcoeff4_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff4                 ;
   assign currentcoeff5_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff5                 ;
   assign currentcoeff6_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff6                 ;
   assign currentcoeff7_ext              = (pipe_mode_simu_only==1'b0)?0:currentcoeff7                 ;
   assign currentrxpreset0_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset0              ;
   assign currentrxpreset1_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset1              ;
   assign currentrxpreset2_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset2              ;
   assign currentrxpreset3_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset3              ;
   assign currentrxpreset4_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset4              ;
   assign currentrxpreset5_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset5              ;
   assign currentrxpreset6_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset6              ;
   assign currentrxpreset7_ext           = (pipe_mode_simu_only==1'b0)?0:currentrxpreset7              ;

endmodule



module altpcie_hip_256_pipen1b # (

      parameter ACDS_V10=1,
      parameter MEM_CHECK=0,
      parameter USE_INTERNAL_250MHZ_PLL = 1,
      parameter pll_refclk_freq = "100 MHz", //legal value = "100 MHz", "125 MHz"

      parameter enable_slot_register = "false",
      parameter pcie_mode = "shared_mode",
      parameter bypass_cdc = "false",
      parameter enable_rx_buffer_checking = "false",
      parameter single_rx_detect = 4'b0,
      parameter use_crc_forwarding = "false",
      parameter gen123_lane_rate_mode = "gen1",
      parameter lane_mask = "x4",
      parameter disable_link_x2_support = "false",
      parameter hip_hard_reset = "disable",
      parameter dis_paritychk = "enable",
      parameter wrong_device_id = "disable",
      parameter data_pack_rx = "disable",
      parameter ast_width = "rx_tx_64",
      parameter rx_sop_ctrl = "boundary_64",
      parameter rx_ast_parity = "disable",
      parameter tx_ast_parity = "disable",
      parameter ltssm_1ms_timeout = "disable",
      parameter ltssm_freqlocked_check = "disable",
      parameter deskew_comma = "skp_eieos_deskw",
      parameter port_link_number = 8'b1,
      parameter device_number = 5'b0,
      parameter bypass_clk_switch = "TRUE",
      parameter pipex1_debug_sel = "disable",
      parameter pclk_out_sel = "pclk",
      parameter vendor_id = 16'b1000101110010,
      parameter device_id = 16'b1,
      parameter revision_id = 8'b1,
      parameter class_code = 24'b111111110000000000000000,
      parameter subsystem_vendor_id = 16'b1000101110010,
      parameter subsystem_device_id = 16'b1,
      parameter no_soft_reset = "false",
      parameter maximum_current = 3'b0,
      parameter d1_support = "false",
      parameter d2_support = "false",
      parameter d0_pme = "false",
      parameter d1_pme = "false",
      parameter d2_pme = "false",
      parameter d3_hot_pme = "false",
      parameter d3_cold_pme = "false",
      parameter use_aer = "false",
      parameter low_priority_vc = "single_vc",
      parameter disable_snoop_packet = "false",
      parameter max_payload_size = "payload_512",
      parameter surprise_down_error_support = "false",
      parameter dll_active_report_support = "false",
      parameter extend_tag_field = "false",
      parameter endpoint_l0_latency = 3'b0,
      parameter endpoint_l1_latency = 3'b0,
      parameter indicator = 3'b111,
      parameter slot_power_scale = 2'b0,
      parameter max_link_width = "x4",
      parameter enable_l1_aspm = "false",
      parameter l1_exit_latency_sameclock = 3'b0,
      parameter l1_exit_latency_diffclock = 3'b0,
      parameter hot_plug_support = 7'b0,
      parameter slot_power_limit = 8'b0,
      parameter slot_number = 13'b0,
      parameter diffclock_nfts_count = 8'b0,
      parameter sameclock_nfts_count = 8'b0,
      parameter completion_timeout = "abcd",
      parameter enable_completion_timeout_disable = "true",
      parameter extended_tag_reset = "false",
      parameter ecrc_check_capable = "true",
      parameter ecrc_gen_capable = "true",
      parameter no_command_completed = "true",
      parameter msi_multi_message_capable = "count_4",
      parameter msi_64bit_addressing_capable = "true",
      parameter msi_masking_capable = "false",
      parameter msi_support = "true",
      parameter interrupt_pin = "inta",
      parameter enable_function_msix_support = "true",
      parameter msix_table_size = 11'b0,
      parameter msix_table_bir = 3'b0,
      parameter msix_table_offset = 29'b0,
      parameter msix_pba_bir = 3'b0,
      parameter msix_pba_offset = 29'b0,
      parameter bridge_port_vga_enable = "false",
      parameter bridge_port_ssid_support = "false",
      parameter ssvid = 16'b0,
      parameter ssid = 16'b0,
      parameter eie_before_nfts_count = 4'b100,
      parameter gen2_diffclock_nfts_count = 8'b11111111,
      parameter gen2_sameclock_nfts_count = 8'b11111111,
      parameter deemphasis_enable = "false",
      parameter pcie_spec_version = "v2",
      parameter l0_exit_latency_sameclock = 3'b110,
      parameter l0_exit_latency_diffclock = 3'b110,
      parameter rx_ei_l0s = "disable",
      parameter l2_async_logic = "enable",
      parameter aspm_config_management = "true",
      parameter atomic_op_routing = "false",
      parameter atomic_op_completer_32bit = "false",
      parameter atomic_op_completer_64bit = "false",
      parameter cas_completer_128bit = "false",
      parameter ltr_mechanism = "false",
      parameter tph_completer = "false",
      parameter extended_format_field = "true",
      parameter atomic_malformed = "false",
      parameter flr_capability = "true",
      parameter enable_adapter_half_rate_mode = "false",
      parameter vc0_clk_enable = "true",
      parameter register_pipe_signals = "false",
      parameter bar0_io_space = "false",
      parameter bar0_64bit_mem_space = "true",
      parameter bar0_prefetchable = "true",
      parameter bar0_size_mask = 28'b1111111111111111111111111111,
      parameter bar1_io_space = "false",
      parameter bar1_64bit_mem_space = "false",
      parameter bar1_prefetchable = "false",
      parameter bar1_size_mask = 28'b0,
      parameter bar2_io_space = "false",
      parameter bar2_64bit_mem_space = "false",
      parameter bar2_prefetchable = "false",
      parameter bar2_size_mask = 28'b0,
      parameter bar3_io_space = "false",
      parameter bar3_64bit_mem_space = "false",
      parameter bar3_prefetchable = "false",
      parameter bar3_size_mask = 28'b0,
      parameter bar4_io_space = "false",
      parameter bar4_64bit_mem_space = "false",
      parameter bar4_prefetchable = "false",
      parameter bar4_size_mask = 28'b0,
      parameter bar5_io_space = "false",
      parameter bar5_64bit_mem_space = "false",
      parameter bar5_prefetchable = "false",
      parameter bar5_size_mask = 28'b0,
      parameter expansion_base_address_register = 32'b0,
      parameter io_window_addr_width = "window_32_bit",
      parameter prefetchable_mem_window_addr_width = "prefetch_32",
      parameter skp_os_gen3_count = 11'b0,
      parameter tx_cdc_almost_empty = 4'b101,
      parameter rx_cdc_almost_full = 4'b1100,
      parameter tx_cdc_almost_full = 4'b1100,
      parameter rx_l0s_count_idl = 8'b0,
      parameter cdc_dummy_insert_limit = 4'b1011,
      parameter ei_delay_powerdown_count = 8'b1010,
      parameter millisecond_cycle_count = 20'b0,
      parameter skp_os_schedule_count = 11'b0,
      parameter fc_init_timer = 11'b10000000000,
      parameter l01_entry_latency = 5'b11111,
      parameter flow_control_update_count = 5'b11110,
      parameter flow_control_timeout_count = 8'b11001000,
      parameter vc0_rx_flow_ctrl_posted_header = 8'b110010,
      parameter vc0_rx_flow_ctrl_posted_data = 12'b101101000,
      parameter vc0_rx_flow_ctrl_nonposted_header = 8'b110110,
      parameter vc0_rx_flow_ctrl_nonposted_data = 8'b0,
      parameter vc0_rx_flow_ctrl_compl_header = 8'b1110000,
      parameter vc0_rx_flow_ctrl_compl_data = 12'b111000000,
      parameter rx_ptr0_posted_dpram_min = 11'b0,
      parameter rx_ptr0_posted_dpram_max = 11'b0,
      parameter rx_ptr0_nonposted_dpram_min = 11'b0,
      parameter rx_ptr0_nonposted_dpram_max = 11'b0,
      parameter retry_buffer_last_active_address = 11'b11111111111,
      parameter retry_buffer_memory_settings = 30'b0,
      parameter vc0_rx_buffer_memory_settings = 30'b0,
      parameter bist_memory_settings = 75'b0,
      parameter credit_buffer_allocation_aux = "balanced",
      parameter iei_enable_settings = "gen2_infei_infsd_gen1_infei_sd",
      parameter vsec_id = 16'b1000101110010,
      parameter cvp_rate_sel = "full_rate",
      parameter hard_reset_bypass = "true",
      parameter cvp_data_compressed = "false",
      parameter cvp_data_encrypted = "false",
      parameter cvp_mode_reset = "false",
      parameter cvp_clk_reset = "false",
      parameter in_cvp_mode = "not_cvp_mode",
      parameter vsec_cap = 4'b0,
      parameter jtag_id = 32'b0,
      parameter user_id = 16'b0,
      parameter cseb_extend_pci = "false",
      parameter cseb_extend_pcie = "false",
      parameter cseb_cpl_status_during_cvp = "config_retry_status",
      parameter cseb_route_to_avl_rx_st = "cseb",
      parameter cseb_config_bypass = "disable",
      parameter cseb_cpl_tag_checking = "enable",
      parameter cseb_bar_match_checking = "enable",
      parameter cseb_min_error_checking = "false",
      parameter cseb_temp_busy_crs = "completer_abort",
      parameter gen3_diffclock_nfts_count = 8'b10000000,
      parameter gen3_sameclock_nfts_count = 8'b10000000,
      parameter gen3_coeff_errchk = "enable",
      parameter gen3_paritychk = "enable",
      parameter gen3_coeff_delay_count = 7'b1111101,
      parameter gen3_coeff_1 = 18'b0,
      parameter gen3_coeff_1_sel = "coeff_1",
      parameter gen3_coeff_1_preset_hint = 3'b0,
      parameter gen3_coeff_1_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_1_nxtber_more = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_1_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_1_nxtber_less = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_1_reqber = 5'b0,
      parameter gen3_coeff_1_ber_meas = 6'b0,
      parameter gen3_coeff_2 = 18'b0,
      parameter gen3_coeff_2_sel = "coeff_2",
      parameter gen3_coeff_2_preset_hint = 3'b0,
      parameter gen3_coeff_2_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_2_nxtber_more = "g3_coeff_2_nxtber_more",
      parameter gen3_coeff_2_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_2_nxtber_less = "g3_coeff_2_nxtber_less",
      parameter gen3_coeff_2_reqber = 5'b0,
      parameter gen3_coeff_2_ber_meas = 6'b0,
      parameter gen3_coeff_3 = 18'b0,
      parameter gen3_coeff_3_sel = "coeff_3",
      parameter gen3_coeff_3_preset_hint = 3'b0,
      parameter gen3_coeff_3_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_3_nxtber_more = "g3_coeff_3_nxtber_more",
      parameter gen3_coeff_3_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_3_nxtber_less = "g3_coeff_3_nxtber_less",
      parameter gen3_coeff_3_reqber = 5'b0,
      parameter gen3_coeff_3_ber_meas = 6'b0,
      parameter gen3_coeff_4 = 18'b0,
      parameter gen3_coeff_4_sel = "coeff_4",
      parameter gen3_coeff_4_preset_hint = 3'b0,
      parameter gen3_coeff_4_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_4_nxtber_more = "g3_coeff_4_nxtber_more",
      parameter gen3_coeff_4_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_4_nxtber_less = "g3_coeff_4_nxtber_less",
      parameter gen3_coeff_4_reqber = 5'b0,
      parameter gen3_coeff_4_ber_meas = 6'b0,
      parameter gen3_coeff_5 = 18'b0,
      parameter gen3_coeff_5_sel = "coeff_5",
      parameter gen3_coeff_5_preset_hint = 3'b0,
      parameter gen3_coeff_5_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_5_nxtber_more = "g3_coeff_5_nxtber_more",
      parameter gen3_coeff_5_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_5_nxtber_less = "g3_coeff_5_nxtber_less",
      parameter gen3_coeff_5_reqber = 5'b0,
      parameter gen3_coeff_5_ber_meas = 6'b0,
      parameter gen3_coeff_6 = 18'b0,
      parameter gen3_coeff_6_sel = "coeff_6",
      parameter gen3_coeff_6_preset_hint = 3'b0,
      parameter gen3_coeff_6_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_6_nxtber_more = "g3_coeff_6_nxtber_more",
      parameter gen3_coeff_6_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_6_nxtber_less = "g3_coeff_6_nxtber_less",
      parameter gen3_coeff_6_reqber = 5'b0,
      parameter gen3_coeff_6_ber_meas = 6'b0,
      parameter gen3_coeff_7 = 18'b0,
      parameter gen3_coeff_7_sel = "coeff_7",
      parameter gen3_coeff_7_preset_hint = 3'b0,
      parameter gen3_coeff_7_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_7_nxtber_more = "g3_coeff_7_nxtber_more",
      parameter gen3_coeff_7_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_7_nxtber_less = "g3_coeff_7_nxtber_less",
      parameter gen3_coeff_7_reqber = 5'b0,
      parameter gen3_coeff_7_ber_meas = 6'b0,
      parameter gen3_coeff_8 = 18'b0,
      parameter gen3_coeff_8_sel = "coeff_8",
      parameter gen3_coeff_8_preset_hint = 3'b0,
      parameter gen3_coeff_8_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_8_nxtber_more = "g3_coeff_8_nxtber_more",
      parameter gen3_coeff_8_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_8_nxtber_less = "g3_coeff_8_nxtber_less",
      parameter gen3_coeff_8_reqber = 5'b0,
      parameter gen3_coeff_8_ber_meas = 6'b0,
      parameter gen3_coeff_9 = 18'b0,
      parameter gen3_coeff_9_sel = "coeff_9",
      parameter gen3_coeff_9_preset_hint = 3'b0,
      parameter gen3_coeff_9_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_9_nxtber_more = "g3_coeff_9_nxtber_more",
      parameter gen3_coeff_9_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_9_nxtber_less = "g3_coeff_9_nxtber_less",
      parameter gen3_coeff_9_reqber = 5'b0,
      parameter gen3_coeff_9_ber_meas = 6'b0,
      parameter gen3_coeff_10 = 18'b0,
      parameter gen3_coeff_10_sel = "coeff_10",
      parameter gen3_coeff_10_preset_hint = 3'b0,
      parameter gen3_coeff_10_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_10_nxtber_more = "g3_coeff_10_nxtber_more",
      parameter gen3_coeff_10_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_10_nxtber_less = "g3_coeff_10_nxtber_less",
      parameter gen3_coeff_10_reqber = 5'b0,
      parameter gen3_coeff_10_ber_meas = 6'b0,
      parameter gen3_coeff_11 = 18'b0,
      parameter gen3_coeff_11_sel = "coeff_11",
      parameter gen3_coeff_11_preset_hint = 3'b0,
      parameter gen3_coeff_11_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_11_nxtber_more = "g3_coeff_11_nxtber_more",
      parameter gen3_coeff_11_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_11_nxtber_less = "g3_coeff_11_nxtber_less",
      parameter gen3_coeff_11_reqber = 5'b0,
      parameter gen3_coeff_11_ber_meas = 6'b0,
      parameter gen3_coeff_12 = 18'b0,
      parameter gen3_coeff_12_sel = "coeff_12",
      parameter gen3_coeff_12_preset_hint = 3'b0,
      parameter gen3_coeff_12_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_12_nxtber_more = "g3_coeff_12_nxtber_more",
      parameter gen3_coeff_12_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_12_nxtber_less = "g3_coeff_12_nxtber_less",
      parameter gen3_coeff_12_reqber = 5'b0,
      parameter gen3_coeff_12_ber_meas = 6'b0,
      parameter gen3_coeff_13 = 18'b0,
      parameter gen3_coeff_13_sel = "coeff_13",
      parameter gen3_coeff_13_preset_hint = 3'b0,
      parameter gen3_coeff_13_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_13_nxtber_more = "g3_coeff_13_nxtber_more",
      parameter gen3_coeff_13_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_13_nxtber_less = "g3_coeff_13_nxtber_less",
      parameter gen3_coeff_13_reqber = 5'b0,
      parameter gen3_coeff_13_ber_meas = 6'b0,
      parameter gen3_coeff_14 = 18'b0,
      parameter gen3_coeff_14_sel = "coeff_14",
      parameter gen3_coeff_14_preset_hint = 3'b0,
      parameter gen3_coeff_14_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_14_nxtber_more = "g3_coeff_14_nxtber_more",
      parameter gen3_coeff_14_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_14_nxtber_less = "g3_coeff_14_nxtber_less",
      parameter gen3_coeff_14_reqber = 5'b0,
      parameter gen3_coeff_14_ber_meas = 6'b0,
      parameter gen3_coeff_15 = 18'b0,
      parameter gen3_coeff_15_sel = "coeff_15",
      parameter gen3_coeff_15_preset_hint = 3'b0,
      parameter gen3_coeff_15_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_15_nxtber_more = "g3_coeff_15_nxtber_more",
      parameter gen3_coeff_15_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_15_nxtber_less = "g3_coeff_15_nxtber_less",
      parameter gen3_coeff_15_reqber = 5'b0,
      parameter gen3_coeff_15_ber_meas = 6'b0,
      parameter gen3_coeff_16 = 18'b0,
      parameter gen3_coeff_16_sel = "coeff_16",
      parameter gen3_coeff_16_preset_hint = 3'b0,
      parameter gen3_coeff_16_nxtber_more_ptr = 4'b0,
      parameter gen3_coeff_16_nxtber_more = "g3_coeff_16_nxtber_more",
      parameter gen3_coeff_16_nxtber_less_ptr = 4'b0,
      parameter gen3_coeff_16_nxtber_less = "g3_coeff_16_nxtber_less",
      parameter gen3_coeff_16_reqber = 5'b0,
      parameter gen3_coeff_16_ber_meas = 6'b0,
      parameter gen3_preset_coeff_1 = 18'b0,
      parameter gen3_preset_coeff_2 = 18'b0,
      parameter gen3_preset_coeff_3 = 18'b0,
      parameter gen3_preset_coeff_4 = 18'b0,
      parameter gen3_preset_coeff_5 = 18'b0,
      parameter gen3_preset_coeff_6 = 18'b0,
      parameter gen3_preset_coeff_7 = 18'b0,
      parameter gen3_preset_coeff_8 = 18'b0,
      parameter gen3_preset_coeff_9 = 18'b0,
      parameter gen3_preset_coeff_10 = 18'b0,
      parameter gen3_rxfreqlock_counter = 20'b0


      //Serdes related parameters
) (
      // Reset signals
      input                 simu_mode,
      input                 pipe_mode,
      input                 crst,
      input                 srst,
      input                 hiphardreset,
      input                 npor,
      output                reset_status,

      // Clock
      input                 pld_clk,
      input                 pclk_in,
      output                clk250_out,
      output                clk500_out,
      output                rc_pll_locked,

      // Serdes related
      input                 cal_blk_clk,
      input                 refclk,

      // HIP control signals
      input  [1 : 0]        mode,
      input  [4 : 0]        hpg_ctrler,
      input  [1 : 0]        swctmod,
      input  [2 : 0]        swdn_in,
      input  [6 : 0]        swup_in,
      input  [31 : 0]       test_in,

      // Input PIPE simulation _ext for simulation only
      input                 phystatus0_ext,
      input                 phystatus1_ext,
      input                 phystatus2_ext,
      input                 phystatus3_ext,
      input                 phystatus4_ext,
      input                 phystatus5_ext,
      input                 phystatus6_ext,
      input                 phystatus7_ext,
      input  [7 : 0]        rxdata0_ext,
      input  [7 : 0]        rxdata1_ext,
      input  [7 : 0]        rxdata2_ext,
      input  [7 : 0]        rxdata3_ext,
      input  [7 : 0]        rxdata4_ext,
      input  [7 : 0]        rxdata5_ext,
      input  [7 : 0]        rxdata6_ext,
      input  [7 : 0]        rxdata7_ext,
      input                 rxdatak0_ext,
      input                 rxdatak1_ext,
      input                 rxdatak2_ext,
      input                 rxdatak3_ext,
      input                 rxdatak4_ext,
      input                 rxdatak5_ext,
      input                 rxdatak6_ext,
      input                 rxdatak7_ext,
      input                 rxelecidle0_ext,
      input                 rxelecidle1_ext,
      input                 rxelecidle2_ext,
      input                 rxelecidle3_ext,
      input                 rxelecidle4_ext,
      input                 rxelecidle5_ext,
      input                 rxelecidle6_ext,
      input                 rxelecidle7_ext,
      input                 rxfreqlocked0_ext,
      input                 rxfreqlocked1_ext,
      input                 rxfreqlocked2_ext,
      input                 rxfreqlocked3_ext,
      input                 rxfreqlocked4_ext,
      input                 rxfreqlocked5_ext,
      input                 rxfreqlocked6_ext,
      input                 rxfreqlocked7_ext,
      input  [2 : 0]        rxstatus0_ext,
      input  [2 : 0]        rxstatus1_ext,
      input  [2 : 0]        rxstatus2_ext,
      input  [2 : 0]        rxstatus3_ext,
      input  [2 : 0]        rxstatus4_ext,
      input  [2 : 0]        rxstatus5_ext,
      input  [2 : 0]        rxstatus6_ext,
      input  [2 : 0]        rxstatus7_ext,
      input                 rxdataskip0_ext,
      input                 rxdataskip1_ext,
      input                 rxdataskip2_ext,
      input                 rxdataskip3_ext,
      input                 rxdataskip4_ext,
      input                 rxdataskip5_ext,
      input                 rxdataskip6_ext,
      input                 rxdataskip7_ext,
      input                 rxblkst0_ext,
      input                 rxblkst1_ext,
      input                 rxblkst2_ext,
      input                 rxblkst3_ext,
      input                 rxblkst4_ext,
      input                 rxblkst5_ext,
      input                 rxblkst6_ext,
      input                 rxblkst7_ext,
      input  [1 : 0]        rxsynchd0_ext,
      input  [1 : 0]        rxsynchd1_ext,
      input  [1 : 0]        rxsynchd2_ext,
      input  [1 : 0]        rxsynchd3_ext,
      input  [1 : 0]        rxsynchd4_ext,
      input  [1 : 0]        rxsynchd5_ext,
      input  [1 : 0]        rxsynchd6_ext,
      input  [1 : 0]        rxsynchd7_ext,
      input                 rxvalid0_ext,
      input                 rxvalid1_ext,
      input                 rxvalid2_ext,
      input                 rxvalid3_ext,
      input                 rxvalid4_ext,
      input                 rxvalid5_ext,
      input                 rxvalid6_ext,
      input                 rxvalid7_ext,

      // Application signals inputs
      input  [4 : 0]        aer_msi_num,
      input                 app_int_sts,
      input  [4 : 0]        app_msi_num,
      input                 app_msi_req,
      input  [2 : 0]        app_msi_tc,
      input  [4 : 0]        pex_msi_num,
      input  [11 : 0]       lmi_addr,
      input  [31 : 0]       lmi_din,
      input                 lmi_rden,
      input                 lmi_wren,
      input                 pm_auxpwr,
      input  [9 : 0]        pm_data,
      input                 pme_to_cr,
      input                 pm_event,
      input                 rx_st_mask,
      input                 rx_st_ready,
      input  [255 : 0]      tx_st_data,
      input  [1 :0]        tx_st_empty,
      input  [3 :0]        tx_st_eop,
      input  [3 :0]        tx_st_err,
      input  [31:0]        tx_st_parity,
      input  [3 :0]        tx_st_sop,
      input                tx_st_valid,
      input  [12:0]        cfglink2csrpld,
      input  [6 :0]        cpl_err,
      input                cpl_pending,
      input                tl_slotclk_cfg,

      // Input for internal test port (PE/TE)
      input                 entest,
      input                 frzlogic,
      input                 frzreg,
      input  [7 : 0]        idrcv,
      input  [7 : 0]        idrpl,
      input                 bistenrcv,
      input                 bistenrpl,
      input                 bistscanen,
      input                 bistscanin,
      input                 bisttesten,
      input                 memhiptestenable,
      input                 memredenscan,
      input                 memredscen,
      input                 memredscin,
      input                 memredsclk,
      input                 memredscrst,
      input                 memredscsel,
      input                 memregscanen,
      input                 memregscanin,
      input                 scanmoden,
      input                 usermode,
      input                 scanshiftn,
      input                 nfrzdrv,
      input                 plniotri,

      // Input for past QII 10.0 support
      input  [31 : 0]       csebrddata,
      input  [3 : 0]        csebrddataparity,
      input  [2 : 0]        csebrdresponse,
      input                 csebwaitrequest,
      input  [2 : 0]        csebwrresponse,
      input                 csebwrrespvalid,
      input  [43 : 0]       dbgpipex1rx,


      // Output Pipe interface
      output [2 : 0]        eidleinfersel0_ext,
      output [2 : 0]        eidleinfersel1_ext,
      output [2 : 0]        eidleinfersel2_ext,
      output [2 : 0]        eidleinfersel3_ext,
      output [2 : 0]        eidleinfersel4_ext,
      output [2 : 0]        eidleinfersel5_ext,
      output [2 : 0]        eidleinfersel6_ext,
      output [2 : 0]        eidleinfersel7_ext,
      output [1 : 0]        powerdown0_ext,
      output [1 : 0]        powerdown1_ext,
      output [1 : 0]        powerdown2_ext,
      output [1 : 0]        powerdown3_ext,
      output [1 : 0]        powerdown4_ext,
      output [1 : 0]        powerdown5_ext,
      output [1 : 0]        powerdown6_ext,
      output [1 : 0]        powerdown7_ext,
      output                rxpolarity0_ext,
      output                rxpolarity1_ext,
      output                rxpolarity2_ext,
      output                rxpolarity3_ext,
      output                rxpolarity4_ext,
      output                rxpolarity5_ext,
      output                rxpolarity6_ext,
      output                rxpolarity7_ext,
      output                txcompl0_ext,
      output                txcompl1_ext,
      output                txcompl2_ext,
      output                txcompl3_ext,
      output                txcompl4_ext,
      output                txcompl5_ext,
      output                txcompl6_ext,
      output                txcompl7_ext,
      output [7 : 0]        txdata0_ext,
      output [7 : 0]        txdata1_ext,
      output [7 : 0]        txdata2_ext,
      output [7 : 0]        txdata3_ext,
      output [7 : 0]        txdata4_ext,
      output [7 : 0]        txdata5_ext,
      output [7 : 0]        txdata6_ext,
      output [7 : 0]        txdata7_ext,
      output                txdatak0_ext,
      output                txdatak1_ext,
      output                txdatak2_ext,
      output                txdatak3_ext,
      output                txdatak4_ext,
      output                txdatak5_ext,
      output                txdatak6_ext,
      output                txdatak7_ext,
      output                txdatavalid0_ext,
      output                txdatavalid1_ext,
      output                txdatavalid2_ext,
      output                txdatavalid3_ext,
      output                txdatavalid4_ext,
      output                txdatavalid5_ext,
      output                txdatavalid6_ext,
      output                txdatavalid7_ext,
      output                txdetectrx0_ext,
      output                txdetectrx1_ext,
      output                txdetectrx2_ext,
      output                txdetectrx3_ext,
      output                txdetectrx4_ext,
      output                txdetectrx5_ext,
      output                txdetectrx6_ext,
      output                txdetectrx7_ext,
      output                txelecidle0_ext,
      output                txelecidle1_ext,
      output                txelecidle2_ext,
      output                txelecidle3_ext,
      output                txelecidle4_ext,
      output                txelecidle5_ext,
      output                txelecidle6_ext,
      output                txelecidle7_ext,
      output [2 : 0]        txmargin0_ext,
      output [2 : 0]        txmargin1_ext,
      output [2 : 0]        txmargin2_ext,
      output [2 : 0]        txmargin3_ext,
      output [2 : 0]        txmargin4_ext,
      output [2 : 0]        txmargin5_ext,
      output [2 : 0]        txmargin6_ext,
      output [2 : 0]        txmargin7_ext,
      output                txdeemph0_ext,
      output                txdeemph1_ext,
      output                txdeemph2_ext,
      output                txdeemph3_ext,
      output                txdeemph4_ext,
      output                txdeemph5_ext,
      output                txdeemph6_ext,
      output                txdeemph7_ext,
      output                txblkst0_ext,
      output                txblkst1_ext,
      output                txblkst2_ext,
      output                txblkst3_ext,
      output                txblkst4_ext,
      output                txblkst5_ext,
      output                txblkst6_ext,
      output                txblkst7_ext,
      output [1 : 0]        txsynchd0_ext,
      output [1 : 0]        txsynchd1_ext,
      output [1 : 0]        txsynchd2_ext,
      output [1 : 0]        txsynchd3_ext,
      output [1 : 0]        txsynchd4_ext,
      output [1 : 0]        txsynchd5_ext,
      output [1 : 0]        txsynchd6_ext,
      output [1 : 0]        txsynchd7_ext,
      output [17 : 0]       currentcoeff0_ext,
      output [17 : 0]       currentcoeff1_ext,
      output [17 : 0]       currentcoeff2_ext,
      output [17 : 0]       currentcoeff3_ext,
      output [17 : 0]       currentcoeff4_ext,
      output [17 : 0]       currentcoeff5_ext,
      output [17 : 0]       currentcoeff6_ext,
      output [17 : 0]       currentcoeff7_ext,
      output [2 : 0]        currentrxpreset0_ext,
      output [2 : 0]        currentrxpreset1_ext,
      output [2 : 0]        currentrxpreset2_ext,
      output [2 : 0]        currentrxpreset3_ext,
      output [2 : 0]        currentrxpreset4_ext,
      output [2 : 0]        currentrxpreset5_ext,
      output [2 : 0]        currentrxpreset6_ext,
      output [2 : 0]        currentrxpreset7_ext,


      // Output HIP Status signals
      output                coreclkout,
      output [1 : 0]        currentspeed,
      output                derr_cor_ext_rcv,
      output                derr_cor_ext_rcv1,
      output                derr_cor_ext_rpl,
      output                derr_rpl,
      output                dlup,
      output                dlup_exit,
      output                resetstatus,
      output                ratetiedtognd,
      output                ev128ns,
      output                ev1us,
      output                hotrst_exit,
      output [3 : 0]        int_status,
      output                l2_exit,
      output [3 : 0]        lane_act,
      output [4 : 0]        ltssmstate,
      output [1 : 0]        rate,
      output [127 : 0]      test_out,

      // Output Application interface
      output                app_int_ack,
      output                app_msi_ack,
      output                lmi_ack,
      output [31 : 0]       lmi_dout,
      output                pme_to_sr,
      output [7 : 0]        rx_st_bardec1,
      output [7 : 0]        rx_st_bardec2,
      output [31 : 0]       rx_st_be,
      output [255 : 0]      rx_st_data,
      output [1 : 0]        rx_st_empty,
      output [3 : 0]        rx_st_eop,
      output [3 : 0]        rx_st_err,
      output [31 : 0]       rx_st_parity,
      output [3 : 0]        rx_st_sop,
      output [3 : 0]        rx_st_valid,
      output                serr_out,
      output [6 : 0]        swdnout,
      output [2 : 0]        swupout,
      output [3 : 0]        tl_cfg_add,
      output [31 : 0]       tl_cfg_ctl,
      output [52 : 0]       tl_cfg_sts,
      output [11 : 0]       tx_cred_datafccp,
      output [11 : 0]       tx_cred_datafcnp,
      output [11 : 0]       tx_cred_datafcp,
      output [5 : 0]        tx_cred_fchipcons,
      output [5 : 0]        tx_cred_fcinfinite,
      output [7 : 0]        tx_cred_hdrfccp,
      output [7 : 0]        tx_cred_hdrfcnp,
      output [7 : 0]        tx_cred_hdrfcp,
      output                tx_st_ready,

      // serial interface
      input    rx_in0,
      input    rx_in1,
      input    rx_in2,
      input    rx_in3,
      input    rx_in4,
      input    rx_in5,
      input    rx_in6,
      input    rx_in7,

      output   tx_out0,
      output   tx_out1,
      output   tx_out2,
      output   tx_out3,
      output   tx_out4,
      output   tx_out5,
      output   tx_out6,
      output   tx_out7,

      // Output for past QII 10.0 support
      output [32 : 0]       csebaddr,
      output [4 : 0]        csebaddrparity,
      output [3 : 0]        csebbe,
      output                csebisshadow,
      output                csebrden,
      output [31 : 0]       csebwrdata,
      output [3 : 0]        csebwrdataparity,
      output                csebwren,
      output                csebwrrespreq,

      // Output for internal test port (PE/TE)
      output                bistdonearcv,
      output                bistdonearcv1,
      output                bistdonearpl,
      output                bistdonebrcv,
      output                bistdonebrcv1,
      output                bistdonebrpl,
      output                bistpassrcv,
      output                bistpassrcv1,
      output                bistpassrpl,
      output                bistscanoutrcv,
      output                bistscanoutrcv1,
      output                bistscanoutrpl,
      output                memredscout,
      output                memregscanout,
      output                wakeoen
      );

   function [8*25:1] low_str;
   // Convert parameter strings to lower case
      input [8*25:1] input_string;
      reg [8*25:1] return_string;
      reg [8*25:1] reg_string;
      reg [8:1] tmp;
      reg [8:1] conv_char;
      integer byte_count;
      begin
         reg_string = input_string;
         for (byte_count = 25; byte_count >= 1; byte_count = byte_count - 1) begin
            tmp = reg_string[8*25:(8*(25-1)+1)];
            reg_string = reg_string << 8;
            if ((tmp >= 65) && (tmp <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
               begin
               conv_char = tmp + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
               return_string = {return_string, conv_char};
               end
            else
               return_string = {return_string, tmp};
         end
      low_str = return_string;
      end
   endfunction

   function [8*25:1] get_core_clk_divider_param;
      input [8*25:1] l_ast_width;
      input [8*25:1] l_gen123_lane_rate_mode;
      input [8*25:1] l_lane_mask;
      begin
         if      ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x1"))  get_core_clk_divider_param="div_4"; // Gen1 : pllfixedclk = 250MHz
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x2"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x4"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x8"))  get_core_clk_divider_param="div_1";
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x1"))  get_core_clk_divider_param="div_8"; // Gen2 : pllfixedclk = 500MHz
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x2"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x4"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x8"))  get_core_clk_divider_param="div_1"; //NA

         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x1"))  get_core_clk_divider_param="div_4"; // Gen1 : pllfixedclk = 250MHz
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x2"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x4"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x8"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x1"))  get_core_clk_divider_param="div_8"; // Gen2 : pllfixedclk = 500MHz
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x2"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x4"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x8"))  get_core_clk_divider_param="div_2";

         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x1"))  get_core_clk_divider_param="div_4"; // Gen1 : pllfixedclk = 250MHz
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x2"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x4"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1"     ) && (low_str(l_lane_mask)=="x8"))  get_core_clk_divider_param="div_2";
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x1"))  get_core_clk_divider_param="div_8"; // Gen2 : pllfixedclk = 500MHz
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x2"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x4"))  get_core_clk_divider_param="div_4";
         else if ((low_str(l_ast_width)=="rx_tx_256") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x8"))  get_core_clk_divider_param="div_4";
         else                                                                                                                              get_core_clk_divider_param="div_1";
      end
   endfunction

   function integer is_pld_clk_250MHz;
      input [8*25:1] l_ast_width;
      input [8*25:1] l_gen123_lane_rate_mode;
      input [8*25:1] l_lane_mask;
      begin
              if ((low_str(l_ast_width)=="rx_tx_64" ) && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x4"))  is_pld_clk_250MHz=USE_INTERNAL_250MHZ_PLL;
         else if ((low_str(l_ast_width)=="rx_tx_128") && (low_str(l_gen123_lane_rate_mode)=="gen1_gen2") && (low_str(l_lane_mask)=="x8"))  is_pld_clk_250MHz=USE_INTERNAL_250MHZ_PLL;
         else                                                                                                                              is_pld_clk_250MHz=0;
      end
   endfunction
   localparam PLD_CLK_IS_250MHZ = is_pld_clk_250MHz(ast_width, gen123_lane_rate_mode, lane_mask);

   // Convert parameter strings to lower case
   genvar i;

   localparam ST_DATA_WIDTH=(low_str(ast_width)=="rx_tx_256")?256:(low_str(ast_width)=="rx_tx_128")?128:64;
   localparam ST_BE_WIDTH  =(low_str(ast_width)=="rx_tx_256")? 32:(low_str(ast_width)=="rx_tx_128")? 16: 8;
   localparam ST_CTRL_WIDTH=(low_str(ast_width)=="rx_tx_256")?  4:(low_str(ast_width)=="rx_tx_128")?  2: 1;

   localparam lanes                = (low_str(lane_mask)=="x1")?1:(low_str(lane_mask)=="x2")?2:(low_str(lane_mask)=="x4")?4:8; //legal value: 1+
   localparam enable_ch0_pclk_out  = (lanes==8)?"false":"true";
   localparam enable_ch01_pclk_out = ((lanes==2)||(lanes==4))?"pclk_ch1":"pclk_ch0";

   localparam national_inst_thru_enhance   = "false";
   localparam vc_enable                    = "single_vc" ;
   localparam bypass_tl                    = "false";
   localparam vc1_clk_enable               = "false";
   localparam vc_arbitration               = "single_vc";
   localparam enable_rx_reordering         = "false";

   localparam starting_channel_number = 0; //legal value: 0+
   localparam protocol_version = (low_str(gen123_lane_rate_mode)=="gen1")?"Gen 1":
                                 (low_str(gen123_lane_rate_mode)=="gen1_gen2")?"Gen 2":"<invalid>"; //legal value: "gen1", "gen2"

   localparam core_clk_sel      = "pld_clk";
   localparam core_clk_out_sel  = "div_1";
   localparam core_clk_source   = "pll_fixed_clk";
   localparam core_clk_divider  = get_core_clk_divider_param(ast_width, gen123_lane_rate_mode, lane_mask);
   localparam deser_factor = 32;
   localparam hip_enable = "true";

   localparam [127:0] ONES  = 128'HFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
   localparam [127:0] ZEROS = 128'H0000_0000_0000_0000_0000_0000_0000_0000;

// SERDES
//
   //input from reset controller
   wire  [lanes-1:0]                   serdes_gxb_powerdown;  // TODO Confirm with PCS team
   wire                                serdes_pll_powerdown;
   wire                                serdes_fixedclk;
   wire                                open_locked;
   wire                                open_fbclkout;
   wire                                fboutclk_fixedclk;
   wire                                open_fbclk_serdes;
   wire  [lanes-1:0]                   serdes_tx_digitalreset;
   wire  [lanes-1:0]                   serdes_rx_analogreset; // for rx pma
   wire  [lanes-1:0]                   serdes_rx_digitalreset; //for rx pcs


   //clk signal

   //pipe interface ports
   wire  [lanes * deser_factor - 1:0]        serdes_pipe_txdata;
   wire  [((lanes * deser_factor)/8) - 1:0]  serdes_pipe_txdatak;
   wire  [lanes - 1:0]                       serdes_pipe_txdetectrx_loopback;
   wire  [lanes - 1:0]                       serdes_pipe_txcompliance;
   wire  [lanes - 1:0]                       serdes_pipe_txelecidle;
   wire  [lanes - 1:0]                       serdes_pipe_txdeemph;
   wire  [lanes*3 - 1:0]                     serdes_pipe_txmargin;
   wire  [lanes*2 - 1:0]                     serdes_pipe_rate;
   wire  [lanes*2 - 1:0]                     serdes_pipe_powerdown;

   wire  [lanes * deser_factor - 1:0]        serdes_pipe_rxdata;
   wire  [((lanes * deser_factor)/8) - 1:0]  serdes_pipe_rxdatak;
   wire  [lanes - 1:0]                       serdes_pipe_rxvalid;
   wire  [lanes - 1:0]                       serdes_pipe_rxpolarity;
   wire  [lanes - 1:0]                       serdes_pipe_rxelecidle;
   wire  [lanes - 1:0]                       serdes_pipe_phystatus;
   wire  [lanes*3 - 1:0]                     serdes_pipe_rxstatus;

   //non-PIPE ports
   //MM ports
   wire  [lanes*3-1:0]                 serdes_rx_eidleinfersel;
   wire  [lanes-1:0]                   serdes_rx_set_locktodata;
   wire  [lanes-1:0]                   serdes_rx_set_locktoref;
   wire  [lanes-1:0]                   serdes_tx_invpolarity;
   wire  [lanes*2-1:0]                 serdes_rx_errdetect;
   wire  [lanes*2-1:0]                 serdes_rx_disperr;
   wire  [lanes*2-1:0]                 serdes_rx_patterndetect;
   wire  [lanes*2-1:0]                 serdes_rx_syncstatus;
   wire  [lanes-1:0]                   serdes_rx_phase_comp_fifo_error;
   wire  [lanes-1:0]                   serdes_tx_phase_comp_fifo_error;
   wire  [lanes-1:0]                   serdes_rx_is_lockedtoref;
   wire  [lanes-1:0]                   serdes_rx_signaldetect;
   wire  [lanes-1:0]                   serdes_rx_is_lockedtodata;
   wire                                serdes_pll_locked;
   wire                                serdes_cal_blk_powerdown;
   wire                                serdes_cal_blk_clk;

   //non-MM ports
   wire  [lanes-1:0]                   serdes_rx_serial_data;
   wire  [lanes-1:0]                   serdes_tx_serial_data;
   wire                                serdes_pipe_pclk;
   wire                                serdes_pipe_pclkch1      ;
   wire                                serdes_pllfixedclkch0;
   wire                                serdes_pllfixedclkch1;
   wire                                serdes_pipe_pclkcentral  ;
   wire                                serdes_pllfixedclkcentral;

   wire                                mserdes_pipe_pclk;
   wire                                mserdes_pipe_pclkch1      ;
   wire                                mserdes_pllfixedclkch0;
   wire                                mserdes_pllfixedclkch1;
   wire                                mserdes_pipe_pclkcentral  ;
   wire                                mserdes_pllfixedclkcentral;

   wire                                sim_pipe32_pclk;

   // reset controller signal
   wire rst_ctrl_rx_pll_locked  ; //TODO connect to something
   wire rst_ctrl_rxanalogreset  ;
   wire rst_ctrl_rxdigitalreset ;
   wire rst_ctrl_gxb_powerdown  ;
   wire rst_ctrl_txdigitalreset ;

   tri0 pipe_mode_simu_only;// When 1 indicates HIP Pipe simulation only (without Serdes)

   // Pull to known values
   wire unconnected_wire = 1'b0;
   wire [512:0] unconnected_bus = {512{1'b0}};

   ////////////////////////////////////////////////////////////////////////////////////
   //
   // Application AST interface
   //
   wire  [255 : 0]      txstdata;
   wire  [1 : 0]        txstempty;
   wire  [3 : 0]        txsteop;
   wire  [3 : 0]        txsterr;
   wire  [31 : 0]       txstparity;
   wire  [3 : 0]        txstsop;
   wire                 txstvalid;
   wire                 txstready;

   wire                 rxstmask;
   wire                 rxstready;
   wire  [7 : 0]        rxstbardec1;
   wire  [7 : 0]        rxstbardec2;
   wire  [31 : 0]       rxstbe;
   wire  [255 : 0]      rxstdata;
   wire  [1 : 0]        rxstempty;
   wire  [3 : 0]        rxsteop;
   wire  [3 : 0]        rxsterr;
   wire  [31 : 0]       rxstparity;
   wire  [3 : 0]        rxstsop;
   wire  [3 : 0]        rxstvalid;

   assign  ratetiedtognd = 1'b0;
   assign  txstdata   =  (ST_DATA_WIDTH==256)?tx_st_data  [ST_DATA_WIDTH-1 :0]:(ST_DATA_WIDTH==128)?{128'h0,tx_st_data  [ST_DATA_WIDTH-1 :0]}:{192'h0,tx_st_data  [ST_DATA_WIDTH-1 :0]};
   assign  txsteop    =  (ST_DATA_WIDTH==256)?tx_st_eop   [ST_CTRL_WIDTH-1 :0]:(ST_DATA_WIDTH==128)?{2'h0  ,tx_st_eop   [ST_CTRL_WIDTH-1 :0]}:{3'h0  ,tx_st_eop   [ST_CTRL_WIDTH-1 :0]};
   assign  txsterr    =  (ST_DATA_WIDTH==256)?tx_st_err   [ST_CTRL_WIDTH-1 :0]:(ST_DATA_WIDTH==128)?{2'h0  ,tx_st_err   [ST_CTRL_WIDTH-1 :0]}:{3'h0  ,tx_st_err   [ST_CTRL_WIDTH-1 :0]};
   assign  txstparity =  (ST_DATA_WIDTH==256)?tx_st_parity[ST_BE_WIDTH-1   :0]:(ST_DATA_WIDTH==128)?{16'h0 ,tx_st_parity[ST_BE_WIDTH-1   :0]}:{24'h0 ,tx_st_parity[ST_BE_WIDTH-1   :0]};
   assign  txstsop    =  (ST_DATA_WIDTH==256)?tx_st_sop   [ST_CTRL_WIDTH-1 :0]:(ST_DATA_WIDTH==128)?{2'h0  ,tx_st_sop   [ST_CTRL_WIDTH-1 :0]}:{3'h0  ,tx_st_sop   [ST_CTRL_WIDTH-1 :0]};
   assign  txstvalid  =  tx_st_valid                     ;
   assign  txstempty  =  tx_st_empty [1               :0];
   assign  tx_st_ready=  txstready   ;

   assign  rxstmask                         = rx_st_mask ;
   assign  rxstready                        = rx_st_ready;
   assign  rx_st_bardec1[7              :0] = rxstbardec1[7              :0];
   assign  rx_st_bardec2[7              :0] = rxstbardec2[7              :0];
   assign  rx_st_be     [ST_BE_WIDTH-1  :0] = rxstbe     [ST_BE_WIDTH-1  :0];
   assign  rx_st_data   [ST_DATA_WIDTH-1:0] = rxstdata   [ST_DATA_WIDTH-1:0];
   assign  rx_st_empty  [1              :0] = rxstempty  [1              :0];
   assign  rx_st_eop    [ST_CTRL_WIDTH-1:0] = rxsteop    [ST_CTRL_WIDTH-1:0];
   assign  rx_st_err    [ST_CTRL_WIDTH-1:0] = rxsterr    [ST_CTRL_WIDTH-1:0];
   assign  rx_st_parity [ST_BE_WIDTH-1  :0] = rxstparity [ST_BE_WIDTH-1  :0];
   assign  rx_st_sop    [ST_CTRL_WIDTH-1:0] = rxstsop    [ST_CTRL_WIDTH-1:0];
   assign  rx_st_valid  [ST_CTRL_WIDTH-1:0] = rxstvalid  [ST_CTRL_WIDTH-1:0];

   ////////////////////////////////////////////////////////////////////////////////////
   //
   // PIPE signals interface
   //
   wire                phystatus0     ;// HIP input
   wire                phystatus1     ;// HIP input
   wire                phystatus2     ;// HIP input
   wire                phystatus3     ;// HIP input
   wire                phystatus4     ;// HIP input
   wire                phystatus5     ;// HIP input
   wire                phystatus6     ;// HIP input
   wire                phystatus7     ;// HIP input
   wire                rxblkst0       = 1'b0;// HIP input
   wire                rxblkst1       = 1'b0;// HIP input
   wire                rxblkst2       = 1'b0;// HIP input
   wire                rxblkst3       = 1'b0;// HIP input
   wire                rxblkst4       = 1'b0;// HIP input
   wire                rxblkst5       = 1'b0;// HIP input
   wire                rxblkst6       = 1'b0;// HIP input
   wire                rxblkst7       = 1'b0;// HIP input
   wire [31 : 0]       rxdata0        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata1        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata2        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata3        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata4        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata5        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata6        ;// HIP input  [31 : 0]
   wire [31 : 0]       rxdata7        ;// HIP input  [31 : 0]
   wire [3 : 0]        rxdatak0       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak1       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak2       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak3       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak4       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak5       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak6       ;// HIP input  [3 : 0]
   wire [3 : 0]        rxdatak7       ;// HIP input  [3 : 0]
   wire                rxdataskip0    = 1'b0;// HIP input
   wire                rxdataskip1    = 1'b0;// HIP input
   wire                rxdataskip2    = 1'b0;// HIP input
   wire                rxdataskip3    = 1'b0;// HIP input
   wire                rxdataskip4    = 1'b0;// HIP input
   wire                rxdataskip5    = 1'b0;// HIP input
   wire                rxdataskip6    = 1'b0;// HIP input
   wire                rxdataskip7    = 1'b0;// HIP input
   wire                rxelecidle0    ;// HIP input
   wire                rxelecidle1    ;// HIP input
   wire                rxelecidle2    ;// HIP input
   wire                rxelecidle3    ;// HIP input
   wire                rxelecidle4    ;// HIP input
   wire                rxelecidle5    ;// HIP input
   wire                rxelecidle6    ;// HIP input
   wire                rxelecidle7    ;// HIP input
   wire                rxfreqlocked0  = 1'b0;// HIP input
   wire                rxfreqlocked1  = 1'b0;// HIP input
   wire                rxfreqlocked2  = 1'b0;// HIP input
   wire                rxfreqlocked3  = 1'b0;// HIP input
   wire                rxfreqlocked4  = 1'b0;// HIP input
   wire                rxfreqlocked5  = 1'b0;// HIP input
   wire                rxfreqlocked6  = 1'b0;// HIP input
   wire                rxfreqlocked7  = 1'b0;// HIP input
   wire [2 : 0]        rxstatus0      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus1      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus2      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus3      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus4      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus5      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus6      ;// HIP input  [2 : 0]
   wire [2 : 0]        rxstatus7      ;// HIP input  [2 : 0]
   wire [1 : 0]        rxsynchd0      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd1      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd2      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd3      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd4      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd5      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd6      = 2'b00;// HIP input  [1 : 0]
   wire [1 : 0]        rxsynchd7      = 2'b00;// HIP input  [1 : 0]
   wire                rxvalid0       ;// HIP input
   wire                rxvalid1       ;// HIP input
   wire                rxvalid2       ;// HIP input
   wire                rxvalid3       ;// HIP input
   wire                rxvalid4       ;// HIP input
   wire                rxvalid5       ;// HIP input
   wire                rxvalid6       ;// HIP input
   wire                rxvalid7       ;// HIP input
   wire [17 : 0]       currentcoeff0             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff1             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff2             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff3             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff4             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff5             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff6             ;// HIP output [17 : 0]
   wire [17 : 0]       currentcoeff7             ;// HIP output [17 : 0]
   wire [2 : 0]        currentrxpreset0          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset1          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset2          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset3          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset4          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset5          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset6          ;// HIP output [2 : 0]
   wire [2 : 0]        currentrxpreset7          ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel0            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel1            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel2            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel3            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel4            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel5            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel6            ;// HIP output [2 : 0]
   wire [2 : 0]        eidleinfersel7            ;// HIP output [2 : 0]
   wire [1 : 0]        powerdown0                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown1                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown2                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown3                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown4                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown5                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown6                ;// HIP output [1 : 0]
   wire [1 : 0]        powerdown7                ;// HIP output [1 : 0]
   wire                rxpolarity0               ;// HIP output
   wire                rxpolarity1               ;// HIP output
   wire                rxpolarity2               ;// HIP output
   wire                rxpolarity3               ;// HIP output
   wire                rxpolarity4               ;// HIP output
   wire                rxpolarity5               ;// HIP output
   wire                rxpolarity6               ;// HIP output
   wire                rxpolarity7               ;// HIP output
   wire                txblkst0                  ;// HIP output
   wire                txblkst1                  ;// HIP output
   wire                txblkst2                  ;// HIP output
   wire                txblkst3                  ;// HIP output
   wire                txblkst4                  ;// HIP output
   wire                txblkst5                  ;// HIP output
   wire                txblkst6                  ;// HIP output
   wire                txblkst7                  ;// HIP output
   wire                txcompl0                  ;// HIP output
   wire                txcompl1                  ;// HIP output
   wire                txcompl2                  ;// HIP output
   wire                txcompl3                  ;// HIP output
   wire                txcompl4                  ;// HIP output
   wire                txcompl5                  ;// HIP output
   wire                txcompl6                  ;// HIP output
   wire                txcompl7                  ;// HIP output
   wire [31 : 0]       txdata0                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata1                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata2                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata3                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata4                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata5                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata6                   ;// HIP output [31 : 0]
   wire [31 : 0]       txdata7                   ;// HIP output [31 : 0]
   wire [3 : 0]        txdatak0                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak1                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak2                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak3                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak4                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak5                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak6                  ;// HIP output [3 : 0]
   wire [3 : 0]        txdatak7                  ;// HIP output [3 : 0]
   wire                txdatavalid0              ;// Going nowhere to remove
   wire                txdatavalid1              ;// Going nowhere to remove
   wire                txdatavalid2              ;// Going nowhere to remove
   wire                txdatavalid3              ;// Going nowhere to remove
   wire                txdatavalid4              ;// Going nowhere to remove
   wire                txdatavalid5              ;// Going nowhere to remove
   wire                txdatavalid6              ;// Going nowhere to remove
   wire                txdatavalid7              ;// Going nowhere to remove
   wire                txdeemph0                 ;// HIP output
   wire                txdeemph1                 ;// HIP output
   wire                txdeemph2                 ;// HIP output
   wire                txdeemph3                 ;// HIP output
   wire                txdeemph4                 ;// HIP output
   wire                txdeemph5                 ;// HIP output
   wire                txdeemph6                 ;// HIP output
   wire                txdeemph7                 ;// HIP output
   wire                txdetectrx0               ;// HIP output
   wire                txdetectrx1               ;// HIP output
   wire                txdetectrx2               ;// HIP output
   wire                txdetectrx3               ;// HIP output
   wire                txdetectrx4               ;// HIP output
   wire                txdetectrx5               ;// HIP output
   wire                txdetectrx6               ;// HIP output
   wire                txdetectrx7               ;// HIP output
   wire                txelecidle0               ;// HIP output
   wire                txelecidle1               ;// HIP output
   wire                txelecidle2               ;// HIP output
   wire                txelecidle3               ;// HIP output
   wire                txelecidle4               ;// HIP output
   wire                txelecidle5               ;// HIP output
   wire                txelecidle6               ;// HIP output
   wire                txelecidle7               ;// HIP output
   wire [2 : 0]        txmargin0                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin1                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin2                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin3                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin4                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin5                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin6                 ;// HIP output [2 : 0]
   wire [2 : 0]        txmargin7                 ;// HIP output [2 : 0]
   wire [1 : 0]        txsynchd0                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd1                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd2                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd3                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd4                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd5                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd6                 ;// HIP output [1 : 0]
   wire [1 : 0]        txsynchd7                 ;// HIP output [1 : 0]

   wire [ 1:0 ]        rate0;
   wire [ 1:0 ]        rate1;
   wire [ 1:0 ]        rate2;
   wire [ 1:0 ]        rate3;
   wire [ 1:0 ]        rate4;
   wire [ 1:0 ]        rate5;
   wire [ 1:0 ]        rate6;
   wire [ 1:0 ]        rate7;

   wire                phystatus0_ext32b;
   wire                phystatus1_ext32b;
   wire                phystatus2_ext32b;
   wire                phystatus3_ext32b;
   wire                phystatus4_ext32b;
   wire                phystatus5_ext32b;
   wire                phystatus6_ext32b;
   wire                phystatus7_ext32b;
   wire [31 : 0]       rxdata0_ext32b;
   wire [31 : 0]       rxdata1_ext32b;
   wire [31 : 0]       rxdata2_ext32b;
   wire [31 : 0]       rxdata3_ext32b;
   wire [31 : 0]       rxdata4_ext32b;
   wire [31 : 0]       rxdata5_ext32b;
   wire [31 : 0]       rxdata6_ext32b;
   wire [31 : 0]       rxdata7_ext32b;
   wire [3  : 0]       rxdatak0_ext32b;
   wire [3  : 0]       rxdatak1_ext32b;
   wire [3  : 0]       rxdatak2_ext32b;
   wire [3  : 0]       rxdatak3_ext32b;
   wire [3  : 0]       rxdatak4_ext32b;
   wire [3  : 0]       rxdatak5_ext32b;
   wire [3  : 0]       rxdatak6_ext32b;
   wire [3  : 0]       rxdatak7_ext32b;
   wire                rxelecidle0_ext32b;
   wire                rxelecidle1_ext32b;
   wire                rxelecidle2_ext32b;
   wire                rxelecidle3_ext32b;
   wire                rxelecidle4_ext32b;
   wire                rxelecidle5_ext32b;
   wire                rxelecidle6_ext32b;
   wire                rxelecidle7_ext32b;
   wire                rxfreqlocked0_ext32b;
   wire                rxfreqlocked1_ext32b;
   wire                rxfreqlocked2_ext32b;
   wire                rxfreqlocked3_ext32b;
   wire                rxfreqlocked4_ext32b;
   wire                rxfreqlocked5_ext32b;
   wire                rxfreqlocked6_ext32b;
   wire                rxfreqlocked7_ext32b;
   wire [2 : 0]        rxstatus0_ext32b;
   wire [2 : 0]        rxstatus1_ext32b;
   wire [2 : 0]        rxstatus2_ext32b;
   wire [2 : 0]        rxstatus3_ext32b;
   wire [2 : 0]        rxstatus4_ext32b;
   wire [2 : 0]        rxstatus5_ext32b;
   wire [2 : 0]        rxstatus6_ext32b;
   wire [2 : 0]        rxstatus7_ext32b;
   wire                rxdataskip0_ext32b;
   wire                rxdataskip1_ext32b;
   wire                rxdataskip2_ext32b;
   wire                rxdataskip3_ext32b;
   wire                rxdataskip4_ext32b;
   wire                rxdataskip5_ext32b;
   wire                rxdataskip6_ext32b;
   wire                rxdataskip7_ext32b;
   wire                rxblkst0_ext32b;
   wire                rxblkst1_ext32b;
   wire                rxblkst2_ext32b;
   wire                rxblkst3_ext32b;
   wire                rxblkst4_ext32b;
   wire                rxblkst5_ext32b;
   wire                rxblkst6_ext32b;
   wire                rxblkst7_ext32b;
   wire [1 : 0]        rxsynchd0_ext32b;
   wire [1 : 0]        rxsynchd1_ext32b;
   wire [1 : 0]        rxsynchd2_ext32b;
   wire [1 : 0]        rxsynchd3_ext32b;
   wire [1 : 0]        rxsynchd4_ext32b;
   wire [1 : 0]        rxsynchd5_ext32b;
   wire [1 : 0]        rxsynchd6_ext32b;
   wire [1 : 0]        rxsynchd7_ext32b;
   wire                rxvalid0_ext32b;
   wire                rxvalid1_ext32b;
   wire                rxvalid2_ext32b;
   wire                rxvalid3_ext32b;
   wire                rxvalid4_ext32b;
   wire                rxvalid5_ext32b;
   wire                rxvalid6_ext32b;
   wire                rxvalid7_ext32b;

   // PLD Application clocks core_clkout
   wire                coreclkout_hip;
   wire                pld_clk_hip;
   wire                pll_250_locked;
   wire                pll_250_pld_clk;

   // serial assignment


   alt5gxb_reset_controller alt5gxb_reset_controller0
   (
      .async_reset         (pipe_mode|~npor),                                   // I
      .test_sim            (test_in[0]),                                         // I
      .fifo_err            (1'b0),                                              // I
      .inclk               (pld_clk_hip),                                           // I
      .inclk_eq_125mhz     (1'b0),                                              // I
      .pll_locked          (serdes_pll_locked),                                 // I
      .rx_pll_locked       (rc_pll_locked),                                     // I //???

      .rxanalogreset       (rst_ctrl_rxanalogreset  ),                          // O
      .rxdigitalreset      (rst_ctrl_rxdigitalreset ),                          // O
      .gxb_powerdown       (rst_ctrl_gxb_powerdown  ),                          // O
      .txdigitalreset      (rst_ctrl_txdigitalreset )                           // O
   );

   generate
      begin : serdes_rst
         for (i=0;i<lanes;i=i+1) begin : g_serdes_rst
            assign serdes_gxb_powerdown  [i] = rst_ctrl_gxb_powerdown;
            assign serdes_tx_digitalreset[i] = rst_ctrl_txdigitalreset;
            assign serdes_rx_analogreset [i] = rst_ctrl_rxanalogreset;
            assign serdes_rx_digitalreset[i] = rst_ctrl_rxdigitalreset;
         end
      end
   endgenerate


   generate begin : hip_wysiwyg
      if (lanes==1) begin
         // TX

         assign serdes_pipe_rate[1:0]         = rate0[1:0];   // Currently only Gen2 rate0[1] is unconnected

         assign serdes_pipe_txdata[31 :0  ]   = txdata0;

         assign serdes_pipe_txdatak[ 3: 0]    = txdatak0;

         assign serdes_pipe_txcompliance[0]   = txcompl0;

         assign serdes_pipe_txelecidle[0]     = txelecidle0;

         assign serdes_pipe_txdeemph[0]       = txdeemph0;

         assign serdes_pipe_txmargin[ 2: 0]   = txmargin0;

         assign serdes_pipe_powerdown[ 1 : 0] = powerdown0;

         assign  serdes_pipe_rxpolarity[0]    = rxpolarity0 ;

         assign serdes_pipe_txdetectrx_loopback[0] = txdetectrx0;

         assign     tx_out0                = serdes_tx_serial_data[0];

         //RX
         //
         assign  serdes_rx_serial_data[0]=rx_in0;

         assign  serdes_rx_eidleinfersel[2:0] = eidleinfersel0;

         assign  rxdata0      = (pipe_mode_simu_only==1'b1)?rxdata0_ext32b    :serdes_pipe_rxdata[31 :0  ];

         assign  rxdatak0     = (pipe_mode_simu_only==1'b1)?rxdatak0_ext32b   :serdes_pipe_rxdatak[ 3: 0] ;

         assign  rxvalid0     = (pipe_mode_simu_only==1'b1)?rxvalid0_ext32b   :serdes_pipe_rxvalid[0] ;

         assign  rxelecidle0  = (pipe_mode_simu_only==1'b1)?rxelecidle0_ext32b:serdes_pipe_rxelecidle[0] ;

         assign  phystatus0   = (pipe_mode_simu_only==1'b1)?phystatus0_ext32b :serdes_pipe_phystatus[0] ;

         assign  rxstatus0    = (pipe_mode_simu_only==1'b1)?rxstatus0_ext32b  :serdes_pipe_rxstatus[ 2: 0];

         assign mserdes_pipe_pclk         = serdes_pipe_pclk;
         assign mserdes_pipe_pclkch1      = unconnected_wire;
         assign mserdes_pllfixedclkch0    = serdes_pllfixedclkch0;
         assign mserdes_pllfixedclkch1    = unconnected_wire;
         assign mserdes_pipe_pclkcentral  = unconnected_wire;
         assign mserdes_pllfixedclkcentral= unconnected_wire;

         assign  rxdata1      = (pipe_mode_simu_only==1'b1)?rxdata1_ext32b    :unconnected_bus[31:0];
         assign  rxdata2      = (pipe_mode_simu_only==1'b1)?rxdata2_ext32b    :unconnected_bus[31:0];
         assign  rxdata3      = (pipe_mode_simu_only==1'b1)?rxdata3_ext32b    :unconnected_bus[31:0];
         assign  rxdata4      = (pipe_mode_simu_only==1'b1)?rxdata4_ext32b    :unconnected_bus[31:0];
         assign  rxdata5      = (pipe_mode_simu_only==1'b1)?rxdata5_ext32b    :unconnected_bus[31:0];
         assign  rxdata6      = (pipe_mode_simu_only==1'b1)?rxdata6_ext32b    :unconnected_bus[31:0];
         assign  rxdata7      = (pipe_mode_simu_only==1'b1)?rxdata7_ext32b    :unconnected_bus[31:0];

         assign  rxdatak1     = (pipe_mode_simu_only==1'b1)?rxdatak1_ext32b   :unconnected_bus[3:0] ;
         assign  rxdatak2     = (pipe_mode_simu_only==1'b1)?rxdatak2_ext32b   :unconnected_bus[3:0] ;
         assign  rxdatak3     = (pipe_mode_simu_only==1'b1)?rxdatak3_ext32b   :unconnected_bus[3:0] ;
         assign  rxdatak4     = (pipe_mode_simu_only==1'b1)?rxdatak4_ext32b   :unconnected_bus[3:0] ;
         assign  rxdatak5     = (pipe_mode_simu_only==1'b1)?rxdatak5_ext32b   :unconnected_bus[3:0] ;
         assign  rxdatak6     = (pipe_mode_simu_only==1'b1)?rxdatak6_ext32b   :unconnected_bus[3:0] ;
         assign  rxdatak7     = (pipe_mode_simu_only==1'b1)?rxdatak7_ext32b   :unconnected_bus[3:0] ;

         assign  rxvalid1     = (pipe_mode_simu_only==1'b1)?rxvalid1_ext32b   :unconnected_wire;
         assign  rxvalid2     = (pipe_mode_simu_only==1'b1)?rxvalid2_ext32b   :unconnected_wire;
         assign  rxvalid3     = (pipe_mode_simu_only==1'b1)?rxvalid3_ext32b   :unconnected_wire;
         assign  rxvalid4     = (pipe_mode_simu_only==1'b1)?rxvalid4_ext32b   :unconnected_wire;
         assign  rxvalid5     = (pipe_mode_simu_only==1'b1)?rxvalid5_ext32b   :unconnected_wire;
         assign  rxvalid6     = (pipe_mode_simu_only==1'b1)?rxvalid6_ext32b   :unconnected_wire;
         assign  rxvalid7     = (pipe_mode_simu_only==1'b1)?rxvalid7_ext32b   :unconnected_wire;

         assign  rxelecidle1  = (pipe_mode_simu_only==1'b1)?rxelecidle1_ext32b:unconnected_wire;
         assign  rxelecidle2  = (pipe_mode_simu_only==1'b1)?rxelecidle2_ext32b:unconnected_wire;
         assign  rxelecidle3  = (pipe_mode_simu_only==1'b1)?rxelecidle3_ext32b:unconnected_wire;
         assign  rxelecidle4  = (pipe_mode_simu_only==1'b1)?rxelecidle4_ext32b:unconnected_wire;
         assign  rxelecidle5  = (pipe_mode_simu_only==1'b1)?rxelecidle5_ext32b:unconnected_wire;
         assign  rxelecidle6  = (pipe_mode_simu_only==1'b1)?rxelecidle6_ext32b:unconnected_wire;
         assign  rxelecidle7  = (pipe_mode_simu_only==1'b1)?rxelecidle7_ext32b:unconnected_wire;

         assign  phystatus1   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;
         assign  phystatus2   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;
         assign  phystatus3   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;
         assign  phystatus4   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;
         assign  phystatus5   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;
         assign  phystatus6   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;
         assign  phystatus7   = (pipe_mode_simu_only==1'b1)?1'b0              :unconnected_wire;

         assign  rxstatus1    = (pipe_mode_simu_only==1'b1)?rxstatus1_ext32b  :unconnected_bus[2:0];
         assign  rxstatus2    = (pipe_mode_simu_only==1'b1)?rxstatus2_ext32b  :unconnected_bus[2:0];
         assign  rxstatus3    = (pipe_mode_simu_only==1'b1)?rxstatus3_ext32b  :unconnected_bus[2:0];
         assign  rxstatus4    = (pipe_mode_simu_only==1'b1)?rxstatus4_ext32b  :unconnected_bus[2:0];
         assign  rxstatus5    = (pipe_mode_simu_only==1'b1)?rxstatus5_ext32b  :unconnected_bus[2:0];
         assign  rxstatus6    = (pipe_mode_simu_only==1'b1)?rxstatus6_ext32b  :unconnected_bus[2:0];
         assign  rxstatus7    = (pipe_mode_simu_only==1'b1)?rxstatus7_ext32b  :unconnected_bus[2:0];

      end
      else if (lanes==2) begin
         // TX

         assign serdes_pipe_rate[1:0]         = rate0[1:0];
         assign serdes_pipe_rate[3:2]         = rate1[1:0];

         assign serdes_pipe_txdata[31 :0  ]   = txdata0;
         assign serdes_pipe_txdata[63 :32 ]   = txdata1;

         assign serdes_pipe_txdatak[ 3: 0]    = txdatak0;
         assign serdes_pipe_txdatak[ 7: 4]    = txdatak1;

         assign serdes_pipe_txcompliance[0]   = txcompl0;
         assign serdes_pipe_txcompliance[1]   = txcompl1;

         assign serdes_pipe_txelecidle[0]     = txelecidle0;
         assign serdes_pipe_txelecidle[1]     = txelecidle1;

         assign serdes_pipe_txdeemph[0]       = txdeemph0;
         assign serdes_pipe_txdeemph[1]       = txdeemph1;

         assign serdes_pipe_txmargin[ 2: 0]   = txmargin0;
         assign serdes_pipe_txmargin[ 5: 3]   = txmargin1;

         assign serdes_pipe_powerdown[ 1 : 0] = powerdown0;
         assign serdes_pipe_powerdown[ 3 : 2] = powerdown1;

         assign  serdes_pipe_rxpolarity[0]    = rxpolarity0 ;
         assign  serdes_pipe_rxpolarity[1]    = rxpolarity1 ;

         assign serdes_pipe_txdetectrx_loopback[0] = txdetectrx0;
         assign serdes_pipe_txdetectrx_loopback[1] = txdetectrx1;

         assign     tx_out0                = serdes_tx_serial_data[0];
         assign     tx_out1                = serdes_tx_serial_data[1];

         //RX
         //
         assign  serdes_rx_serial_data[0]=rx_in0;
         assign  serdes_rx_serial_data[1]=rx_in1;

         assign  serdes_rx_eidleinfersel[2:0] = eidleinfersel0;
         assign  serdes_rx_eidleinfersel[5:3] = eidleinfersel1;

         assign  rxdata0      = (pipe_mode_simu_only==1'b1)?rxdata0_ext32b    :serdes_pipe_rxdata[31 :0  ];
         assign  rxdata1      = (pipe_mode_simu_only==1'b1)?rxdata1_ext32b    :serdes_pipe_rxdata[63 :32 ];

         assign  rxdatak0     = (pipe_mode_simu_only==1'b1)?rxdatak0_ext32b   :serdes_pipe_rxdatak[ 3: 0] ;
         assign  rxdatak1     = (pipe_mode_simu_only==1'b1)?rxdatak1_ext32b   :serdes_pipe_rxdatak[ 7: 4] ;

         assign  rxvalid0     = (pipe_mode_simu_only==1'b1)?rxvalid0_ext32b   :serdes_pipe_rxvalid[0] ;
         assign  rxvalid1     = (pipe_mode_simu_only==1'b1)?rxvalid1_ext32b   :serdes_pipe_rxvalid[1] ;

         assign  rxelecidle0  = (pipe_mode_simu_only==1'b1)?rxelecidle0_ext32b:serdes_pipe_rxelecidle[0] ;
         assign  rxelecidle1  = (pipe_mode_simu_only==1'b1)?rxelecidle1_ext32b:serdes_pipe_rxelecidle[1] ;

         assign  phystatus0   = (pipe_mode_simu_only==1'b1)?phystatus0_ext32b :serdes_pipe_phystatus[0] ;
         assign  phystatus1   = (pipe_mode_simu_only==1'b1)?phystatus1_ext32b :serdes_pipe_phystatus[1] ;

         assign  rxstatus0    = (pipe_mode_simu_only==1'b1)?rxstatus0_ext32b  :serdes_pipe_rxstatus[ 2: 0];
         assign  rxstatus1    = (pipe_mode_simu_only==1'b1)?rxstatus1_ext32b  :serdes_pipe_rxstatus[ 5: 3];

         assign mserdes_pipe_pclk         = unconnected_wire;
         assign mserdes_pipe_pclkch1      = serdes_pipe_pclkch1;
         assign mserdes_pllfixedclkch0    = unconnected_wire;
         assign mserdes_pllfixedclkch1    = serdes_pllfixedclkch1 ;
         assign mserdes_pipe_pclkcentral  = unconnected_wire;
         assign mserdes_pllfixedclkcentral= unconnected_wire;

         assign  phystatus2   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus3   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus4   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus5   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus6   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus7   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;

      end
      else if (lanes==4) begin
         // TX
         assign serdes_pipe_rate[1:0]         = rate0[1:0];
         assign serdes_pipe_rate[3:2]         = rate1[1:0];
         assign serdes_pipe_rate[5:4]         = rate2[1:0];
         assign serdes_pipe_rate[7:6]         = rate3[1:0];

         assign serdes_pipe_txdata[31 :0  ]   = txdata0;
         assign serdes_pipe_txdata[63 :32 ]   = txdata1;
         assign serdes_pipe_txdata[95 :64 ]   = txdata2;
         assign serdes_pipe_txdata[127:96 ]   = txdata3;

         assign serdes_pipe_txdatak[ 3: 0]    = txdatak0;
         assign serdes_pipe_txdatak[ 7: 4]    = txdatak1;
         assign serdes_pipe_txdatak[11: 8]    = txdatak2;
         assign serdes_pipe_txdatak[15:12]    = txdatak3;

         assign serdes_pipe_txcompliance[0]   = txcompl0;
         assign serdes_pipe_txcompliance[1]   = txcompl1;
         assign serdes_pipe_txcompliance[2]   = txcompl2;
         assign serdes_pipe_txcompliance[3]   = txcompl3;

         assign serdes_pipe_txelecidle[0]     = txelecidle0;
         assign serdes_pipe_txelecidle[1]     = txelecidle1;
         assign serdes_pipe_txelecidle[2]     = txelecidle2;
         assign serdes_pipe_txelecidle[3]     = txelecidle3;

         assign serdes_pipe_txdeemph[0]       = txdeemph0;
         assign serdes_pipe_txdeemph[1]       = txdeemph1;
         assign serdes_pipe_txdeemph[2]       = txdeemph2;
         assign serdes_pipe_txdeemph[3]       = txdeemph3;

         assign serdes_pipe_txmargin[ 2: 0]   = txmargin0;
         assign serdes_pipe_txmargin[ 5: 3]   = txmargin1;
         assign serdes_pipe_txmargin[ 8: 6]   = txmargin2;
         assign serdes_pipe_txmargin[11: 9]   = txmargin3;

         assign serdes_pipe_powerdown[ 1 : 0] = powerdown0;
         assign serdes_pipe_powerdown[ 3 : 2] = powerdown1;
         assign serdes_pipe_powerdown[ 5 : 4] = powerdown2;
         assign serdes_pipe_powerdown[ 7 : 6] = powerdown3;

         assign serdes_pipe_rxpolarity[0]    = rxpolarity0 ;
         assign serdes_pipe_rxpolarity[1]    = rxpolarity1 ;
         assign serdes_pipe_rxpolarity[2]    = rxpolarity2 ;
         assign serdes_pipe_rxpolarity[3]    = rxpolarity3 ;

         assign serdes_pipe_txdetectrx_loopback[0] = txdetectrx0;
         assign serdes_pipe_txdetectrx_loopback[1] = txdetectrx1;
         assign serdes_pipe_txdetectrx_loopback[2] = txdetectrx2;
         assign serdes_pipe_txdetectrx_loopback[3] = txdetectrx3;

         assign     tx_out0                = serdes_tx_serial_data[0];
         assign     tx_out1                = serdes_tx_serial_data[1];
         assign     tx_out2                = serdes_tx_serial_data[2];
         assign     tx_out3                = serdes_tx_serial_data[3];

         //RX
         //
         assign  serdes_rx_serial_data[0]=rx_in0;
         assign  serdes_rx_serial_data[1]=rx_in1;
         assign  serdes_rx_serial_data[2]=rx_in2;
         assign  serdes_rx_serial_data[3]=rx_in3;

         assign  serdes_rx_eidleinfersel[2:0] = eidleinfersel0;
         assign  serdes_rx_eidleinfersel[5:3] = eidleinfersel1;
         assign  serdes_rx_eidleinfersel[8:6] = eidleinfersel2;
         assign  serdes_rx_eidleinfersel[11:9]= eidleinfersel3;

         assign  rxdata0      = (pipe_mode_simu_only==1'b1)?rxdata0_ext32b    :serdes_pipe_rxdata[31 :0  ];
         assign  rxdata1      = (pipe_mode_simu_only==1'b1)?rxdata1_ext32b    :serdes_pipe_rxdata[63 :32 ];
         assign  rxdata2      = (pipe_mode_simu_only==1'b1)?rxdata2_ext32b    :serdes_pipe_rxdata[95 :64 ];
         assign  rxdata3      = (pipe_mode_simu_only==1'b1)?rxdata3_ext32b    :serdes_pipe_rxdata[127:96 ];

         assign  rxdatak0     = (pipe_mode_simu_only==1'b1)?rxdatak0_ext32b   :serdes_pipe_rxdatak[ 3: 0] ;
         assign  rxdatak1     = (pipe_mode_simu_only==1'b1)?rxdatak1_ext32b   :serdes_pipe_rxdatak[ 7: 4] ;
         assign  rxdatak2     = (pipe_mode_simu_only==1'b1)?rxdatak2_ext32b   :serdes_pipe_rxdatak[11: 8] ;
         assign  rxdatak3     = (pipe_mode_simu_only==1'b1)?rxdatak3_ext32b   :serdes_pipe_rxdatak[15:12] ;

         assign  rxvalid0     = (pipe_mode_simu_only==1'b1)?rxvalid0_ext32b   :serdes_pipe_rxvalid[0] ;
         assign  rxvalid1     = (pipe_mode_simu_only==1'b1)?rxvalid1_ext32b   :serdes_pipe_rxvalid[1] ;
         assign  rxvalid2     = (pipe_mode_simu_only==1'b1)?rxvalid2_ext32b   :serdes_pipe_rxvalid[2] ;
         assign  rxvalid3     = (pipe_mode_simu_only==1'b1)?rxvalid3_ext32b   :serdes_pipe_rxvalid[3] ;

         assign  rxelecidle0  = (pipe_mode_simu_only==1'b1)?rxelecidle0_ext32b:serdes_pipe_rxelecidle[0] ;
         assign  rxelecidle1  = (pipe_mode_simu_only==1'b1)?rxelecidle1_ext32b:serdes_pipe_rxelecidle[1] ;
         assign  rxelecidle2  = (pipe_mode_simu_only==1'b1)?rxelecidle2_ext32b:serdes_pipe_rxelecidle[2] ;
         assign  rxelecidle3  = (pipe_mode_simu_only==1'b1)?rxelecidle3_ext32b:serdes_pipe_rxelecidle[3] ;

         assign  phystatus0   = (pipe_mode_simu_only==1'b1)?phystatus0_ext32b :serdes_pipe_phystatus[0] ;
         assign  phystatus1   = (pipe_mode_simu_only==1'b1)?phystatus1_ext32b :serdes_pipe_phystatus[1] ;
         assign  phystatus2   = (pipe_mode_simu_only==1'b1)?phystatus2_ext32b :serdes_pipe_phystatus[2] ;
         assign  phystatus3   = (pipe_mode_simu_only==1'b1)?phystatus3_ext32b :serdes_pipe_phystatus[3] ;

         assign  rxstatus0    = (pipe_mode_simu_only==1'b1)?rxstatus0_ext32b  :serdes_pipe_rxstatus[ 2: 0];
         assign  rxstatus1    = (pipe_mode_simu_only==1'b1)?rxstatus1_ext32b  :serdes_pipe_rxstatus[ 5: 3];
         assign  rxstatus2    = (pipe_mode_simu_only==1'b1)?rxstatus2_ext32b  :serdes_pipe_rxstatus[ 8: 6];
         assign  rxstatus3    = (pipe_mode_simu_only==1'b1)?rxstatus3_ext32b  :serdes_pipe_rxstatus[11: 9];

         assign mserdes_pipe_pclk         = unconnected_wire;
         assign mserdes_pipe_pclkch1      = serdes_pipe_pclkch1;
         assign mserdes_pllfixedclkch0    = unconnected_wire;
         assign mserdes_pllfixedclkch1    = serdes_pllfixedclkch1;
         assign mserdes_pipe_pclkcentral  = unconnected_wire;
         assign mserdes_pllfixedclkcentral= unconnected_wire;

         assign  phystatus4   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus5   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus6   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;
         assign  phystatus7   = (pipe_mode_simu_only==1'b1)?1'b0 :unconnected_wire ;

      end
      else begin // x8
         // TX
         assign serdes_pipe_rate[1 : 0]       = rate0[1:0];
         assign serdes_pipe_rate[3 : 2]       = rate1[1:0];
         assign serdes_pipe_rate[5 : 4]       = rate2[1:0];
         assign serdes_pipe_rate[7 : 6]       = rate3[1:0];
         assign serdes_pipe_rate[9 : 8]       = rate4[1:0];
         assign serdes_pipe_rate[11:10]       = rate5[1:0];
         assign serdes_pipe_rate[13:12]       = rate6[1:0];
         assign serdes_pipe_rate[15:14]       = rate7[1:0];

         assign serdes_pipe_txdata[31 :0  ]   = txdata0;
         assign serdes_pipe_txdata[63 :32 ]   = txdata1;
         assign serdes_pipe_txdata[95 :64 ]   = txdata2;
         assign serdes_pipe_txdata[127:96 ]   = txdata3;
         assign serdes_pipe_txdata[159:128]   = txdata4;
         assign serdes_pipe_txdata[191:160]   = txdata5;
         assign serdes_pipe_txdata[223:192]   = txdata6;
         assign serdes_pipe_txdata[255:224]   = txdata7;

         assign serdes_pipe_txdatak[ 3: 0]    = txdatak0;
         assign serdes_pipe_txdatak[ 7: 4]    = txdatak1;
         assign serdes_pipe_txdatak[11: 8]    = txdatak2;
         assign serdes_pipe_txdatak[15:12]    = txdatak3;
         assign serdes_pipe_txdatak[19:16]    = txdatak4;
         assign serdes_pipe_txdatak[23:20]    = txdatak5;
         assign serdes_pipe_txdatak[27:24]    = txdatak6;
         assign serdes_pipe_txdatak[31:28]    = txdatak7;

         assign serdes_pipe_txcompliance[0]   = txcompl0;
         assign serdes_pipe_txcompliance[1]   = txcompl1;
         assign serdes_pipe_txcompliance[2]   = txcompl2;
         assign serdes_pipe_txcompliance[3]   = txcompl3;
         assign serdes_pipe_txcompliance[4]   = txcompl4;
         assign serdes_pipe_txcompliance[5]   = txcompl5;
         assign serdes_pipe_txcompliance[6]   = txcompl6;
         assign serdes_pipe_txcompliance[7]   = txcompl7;

         assign serdes_pipe_txelecidle[0]     = txelecidle0;
         assign serdes_pipe_txelecidle[1]     = txelecidle1;
         assign serdes_pipe_txelecidle[2]     = txelecidle2;
         assign serdes_pipe_txelecidle[3]     = txelecidle3;
         assign serdes_pipe_txelecidle[4]     = txelecidle4;
         assign serdes_pipe_txelecidle[5]     = txelecidle5;
         assign serdes_pipe_txelecidle[6]     = txelecidle6;
         assign serdes_pipe_txelecidle[7]     = txelecidle7;

         assign serdes_pipe_txdeemph[0]       = txdeemph0;
         assign serdes_pipe_txdeemph[1]       = txdeemph1;
         assign serdes_pipe_txdeemph[2]       = txdeemph2;
         assign serdes_pipe_txdeemph[3]       = txdeemph3;
         assign serdes_pipe_txdeemph[4]       = txdeemph4;
         assign serdes_pipe_txdeemph[5]       = txdeemph5;
         assign serdes_pipe_txdeemph[6]       = txdeemph6;
         assign serdes_pipe_txdeemph[7]       = txdeemph7;

         assign serdes_pipe_txmargin[ 2: 0]   = txmargin0;
         assign serdes_pipe_txmargin[ 5: 3]   = txmargin1;
         assign serdes_pipe_txmargin[ 8: 6]   = txmargin2;
         assign serdes_pipe_txmargin[11: 9]   = txmargin3;
         assign serdes_pipe_txmargin[14:12]   = txmargin4;
         assign serdes_pipe_txmargin[17:15]   = txmargin5;
         assign serdes_pipe_txmargin[20:18]   = txmargin6;
         assign serdes_pipe_txmargin[23:21]   = txmargin7;

         assign serdes_pipe_powerdown[ 1 : 0] = powerdown0;
         assign serdes_pipe_powerdown[ 3 : 2] = powerdown1;
         assign serdes_pipe_powerdown[ 5 : 4] = powerdown2;
         assign serdes_pipe_powerdown[ 7 : 6] = powerdown3;
         assign serdes_pipe_powerdown[ 9 : 8] = powerdown4;
         assign serdes_pipe_powerdown[11 :10] = powerdown5;
         assign serdes_pipe_powerdown[13 :12] = powerdown6;
         assign serdes_pipe_powerdown[15 :14] = powerdown7;

         assign  serdes_pipe_rxpolarity[0]    = rxpolarity0 ;
         assign  serdes_pipe_rxpolarity[1]    = rxpolarity1 ;
         assign  serdes_pipe_rxpolarity[2]    = rxpolarity2 ;
         assign  serdes_pipe_rxpolarity[3]    = rxpolarity3 ;
         assign  serdes_pipe_rxpolarity[4]    = rxpolarity4 ;
         assign  serdes_pipe_rxpolarity[5]    = rxpolarity5 ;
         assign  serdes_pipe_rxpolarity[6]    = rxpolarity6 ;
         assign  serdes_pipe_rxpolarity[7]    = rxpolarity7 ;

         assign serdes_pipe_txdetectrx_loopback[0] = txdetectrx0;
         assign serdes_pipe_txdetectrx_loopback[1] = txdetectrx1;
         assign serdes_pipe_txdetectrx_loopback[2] = txdetectrx2;
         assign serdes_pipe_txdetectrx_loopback[3] = txdetectrx3;
         assign serdes_pipe_txdetectrx_loopback[4] = txdetectrx4;
         assign serdes_pipe_txdetectrx_loopback[5] = txdetectrx5;
         assign serdes_pipe_txdetectrx_loopback[6] = txdetectrx6;
         assign serdes_pipe_txdetectrx_loopback[7] = txdetectrx7;

         assign tx_out0                            = serdes_tx_serial_data[0];
         assign tx_out1                            = serdes_tx_serial_data[1];
         assign tx_out2                            = serdes_tx_serial_data[2];
         assign tx_out3                            = serdes_tx_serial_data[3];
         assign tx_out4                            = serdes_tx_serial_data[4];
         assign tx_out5                            = serdes_tx_serial_data[5];
         assign tx_out6                            = serdes_tx_serial_data[6];
         assign tx_out7                            = serdes_tx_serial_data[7];

         //RX
         //
         assign  serdes_rx_serial_data[0]=rx_in0;
         assign  serdes_rx_serial_data[1]=rx_in1;
         assign  serdes_rx_serial_data[2]=rx_in2;
         assign  serdes_rx_serial_data[3]=rx_in3;
         assign  serdes_rx_serial_data[4]=rx_in4;
         assign  serdes_rx_serial_data[5]=rx_in5;
         assign  serdes_rx_serial_data[6]=rx_in6;
         assign  serdes_rx_serial_data[7]=rx_in7;

         assign  serdes_rx_eidleinfersel[2:0]   = eidleinfersel0;
         assign  serdes_rx_eidleinfersel[5:3]   = eidleinfersel1;
         assign  serdes_rx_eidleinfersel[8:6]   = eidleinfersel2;
         assign  serdes_rx_eidleinfersel[11:9]  = eidleinfersel3;
         assign  serdes_rx_eidleinfersel[14:12] = eidleinfersel4;
         assign  serdes_rx_eidleinfersel[17:15] = eidleinfersel5;
         assign  serdes_rx_eidleinfersel[20:18] = eidleinfersel6;
         assign  serdes_rx_eidleinfersel[23:21] = eidleinfersel7;

         assign  rxdata0      = (pipe_mode_simu_only==1'b1)?rxdata0_ext32b    :serdes_pipe_rxdata[31 :0  ];
         assign  rxdata1      = (pipe_mode_simu_only==1'b1)?rxdata1_ext32b    :serdes_pipe_rxdata[63 :32 ];
         assign  rxdata2      = (pipe_mode_simu_only==1'b1)?rxdata2_ext32b    :serdes_pipe_rxdata[95 :64 ];
         assign  rxdata3      = (pipe_mode_simu_only==1'b1)?rxdata3_ext32b    :serdes_pipe_rxdata[127:96 ];
         assign  rxdata4      = (pipe_mode_simu_only==1'b1)?rxdata4_ext32b    :serdes_pipe_rxdata[159:128];
         assign  rxdata5      = (pipe_mode_simu_only==1'b1)?rxdata5_ext32b    :serdes_pipe_rxdata[191:160];
         assign  rxdata6      = (pipe_mode_simu_only==1'b1)?rxdata6_ext32b    :serdes_pipe_rxdata[223:192];
         assign  rxdata7      = (pipe_mode_simu_only==1'b1)?rxdata7_ext32b    :serdes_pipe_rxdata[255:224];

         assign  rxdatak0     = (pipe_mode_simu_only==1'b1)?rxdatak0_ext32b   :serdes_pipe_rxdatak[ 3: 0] ;
         assign  rxdatak1     = (pipe_mode_simu_only==1'b1)?rxdatak1_ext32b   :serdes_pipe_rxdatak[ 7: 4] ;
         assign  rxdatak2     = (pipe_mode_simu_only==1'b1)?rxdatak2_ext32b   :serdes_pipe_rxdatak[11: 8] ;
         assign  rxdatak3     = (pipe_mode_simu_only==1'b1)?rxdatak3_ext32b   :serdes_pipe_rxdatak[15:12] ;
         assign  rxdatak4     = (pipe_mode_simu_only==1'b1)?rxdatak4_ext32b   :serdes_pipe_rxdatak[19:16] ;
         assign  rxdatak5     = (pipe_mode_simu_only==1'b1)?rxdatak5_ext32b   :serdes_pipe_rxdatak[23:20] ;
         assign  rxdatak6     = (pipe_mode_simu_only==1'b1)?rxdatak6_ext32b   :serdes_pipe_rxdatak[27:24] ;
         assign  rxdatak7     = (pipe_mode_simu_only==1'b1)?rxdatak7_ext32b   :serdes_pipe_rxdatak[31:28] ;

         assign  rxvalid0     = (pipe_mode_simu_only==1'b1)?rxvalid0_ext32b   :serdes_pipe_rxvalid[0] ;
         assign  rxvalid1     = (pipe_mode_simu_only==1'b1)?rxvalid1_ext32b   :serdes_pipe_rxvalid[1] ;
         assign  rxvalid2     = (pipe_mode_simu_only==1'b1)?rxvalid2_ext32b   :serdes_pipe_rxvalid[2] ;
         assign  rxvalid3     = (pipe_mode_simu_only==1'b1)?rxvalid3_ext32b   :serdes_pipe_rxvalid[3] ;
         assign  rxvalid4     = (pipe_mode_simu_only==1'b1)?rxvalid4_ext32b   :serdes_pipe_rxvalid[4] ;
         assign  rxvalid5     = (pipe_mode_simu_only==1'b1)?rxvalid5_ext32b   :serdes_pipe_rxvalid[5] ;
         assign  rxvalid6     = (pipe_mode_simu_only==1'b1)?rxvalid6_ext32b   :serdes_pipe_rxvalid[6] ;
         assign  rxvalid7     = (pipe_mode_simu_only==1'b1)?rxvalid7_ext32b   :serdes_pipe_rxvalid[7] ;

         assign  rxelecidle0  = (pipe_mode_simu_only==1'b1)?rxelecidle0_ext32b:serdes_pipe_rxelecidle[0] ;
         assign  rxelecidle1  = (pipe_mode_simu_only==1'b1)?rxelecidle1_ext32b:serdes_pipe_rxelecidle[1] ;
         assign  rxelecidle2  = (pipe_mode_simu_only==1'b1)?rxelecidle2_ext32b:serdes_pipe_rxelecidle[2] ;
         assign  rxelecidle3  = (pipe_mode_simu_only==1'b1)?rxelecidle3_ext32b:serdes_pipe_rxelecidle[3] ;
         assign  rxelecidle4  = (pipe_mode_simu_only==1'b1)?rxelecidle4_ext32b:serdes_pipe_rxelecidle[4] ;
         assign  rxelecidle5  = (pipe_mode_simu_only==1'b1)?rxelecidle5_ext32b:serdes_pipe_rxelecidle[5] ;
         assign  rxelecidle6  = (pipe_mode_simu_only==1'b1)?rxelecidle6_ext32b:serdes_pipe_rxelecidle[6] ;
         assign  rxelecidle7  = (pipe_mode_simu_only==1'b1)?rxelecidle7_ext32b:serdes_pipe_rxelecidle[7] ;

         assign  phystatus0   = (pipe_mode_simu_only==1'b1)?phystatus0_ext32b :serdes_pipe_phystatus[0] ;
         assign  phystatus1   = (pipe_mode_simu_only==1'b1)?phystatus1_ext32b :serdes_pipe_phystatus[1] ;
         assign  phystatus2   = (pipe_mode_simu_only==1'b1)?phystatus2_ext32b :serdes_pipe_phystatus[2] ;
         assign  phystatus3   = (pipe_mode_simu_only==1'b1)?phystatus3_ext32b :serdes_pipe_phystatus[3] ;
         assign  phystatus4   = (pipe_mode_simu_only==1'b1)?phystatus4_ext32b :serdes_pipe_phystatus[4] ;
         assign  phystatus5   = (pipe_mode_simu_only==1'b1)?phystatus5_ext32b :serdes_pipe_phystatus[5] ;
         assign  phystatus6   = (pipe_mode_simu_only==1'b1)?phystatus6_ext32b :serdes_pipe_phystatus[6] ;
         assign  phystatus7   = (pipe_mode_simu_only==1'b1)?phystatus7_ext32b :serdes_pipe_phystatus[7] ;

         assign  rxstatus0    = (pipe_mode_simu_only==1'b1)?rxstatus0_ext32b  :serdes_pipe_rxstatus[ 2: 0];
         assign  rxstatus1    = (pipe_mode_simu_only==1'b1)?rxstatus1_ext32b  :serdes_pipe_rxstatus[ 5: 3];
         assign  rxstatus2    = (pipe_mode_simu_only==1'b1)?rxstatus2_ext32b  :serdes_pipe_rxstatus[ 8: 6];
         assign  rxstatus3    = (pipe_mode_simu_only==1'b1)?rxstatus3_ext32b  :serdes_pipe_rxstatus[11: 9];
         assign  rxstatus4    = (pipe_mode_simu_only==1'b1)?rxstatus4_ext32b  :serdes_pipe_rxstatus[14:12];
         assign  rxstatus5    = (pipe_mode_simu_only==1'b1)?rxstatus5_ext32b  :serdes_pipe_rxstatus[17:15];
         assign  rxstatus6    = (pipe_mode_simu_only==1'b1)?rxstatus6_ext32b  :serdes_pipe_rxstatus[20:18];
         assign  rxstatus7    = (pipe_mode_simu_only==1'b1)?rxstatus7_ext32b  :serdes_pipe_rxstatus[23:21];

         assign mserdes_pipe_pclk         = unconnected_wire;
         assign mserdes_pipe_pclkch1      = unconnected_wire;
         assign mserdes_pllfixedclkch0    = unconnected_wire;
         assign mserdes_pllfixedclkch1    = unconnected_wire;
         assign mserdes_pipe_pclkcentral  = serdes_pipe_pclkcentral;
         assign mserdes_pllfixedclkcentral= serdes_pllfixedclkcentral;
      end
   end
   endgenerate

   assign rate          = (pipe_mode_simu_only==1'b1)?rate0:2'b00;
   assign rc_pll_locked = (pipe_mode_simu_only==1)?1'b1    :(PLD_CLK_IS_250MHZ==0)?serdes_pll_locked:pll_250_locked;

   generate begin : g_hip_coreclkout_gclk
      if (PLD_CLK_IS_250MHZ==0) begin
         global u_global_buffer_coreclkout (.in(coreclkout_hip), .out(coreclkout));
         assign pld_clk_hip = pld_clk;
         assign pll_250_locked = 1'b1;

      end
      else begin
         wire fbclkout;
         wire open_locked;
         wire open_fbclkout;

         assign pld_clk_hip   = pll_250_pld_clk;

         generic_pll #        ( .reference_clock_frequency("250.0 MHz"), .output_clock_frequency("250.0 MHz") )
            u_pll_coreclkout  ( .refclk(coreclkout_hip), .outclk(coreclkout),     .locked(pll_250_locked), .fboutclk(fbclkout),      .rst((pipe_mode_simu_only==1)?1'b0:~serdes_pll_locked), .fbclk(fbclkout));

         generic_pll #        ( .reference_clock_frequency("250.0 MHz"), .output_clock_frequency("250.0 MHz") )
            u_pll_pldclk      ( .refclk(coreclkout_hip), .outclk(pll_250_pld_clk), .locked(open_locked),    .fboutclk(open_fbclkout), .rst((pipe_mode_simu_only==1)?1'b0:~serdes_pll_locked), .fbclk(fbclkout));
      end
   end
   endgenerate

   stratixv_hssi_gen3_pcie_hip  # (
         .func_mode("enable"),
         .bonding_mode(((low_str(gen123_lane_rate_mode)=="gen1_gen2_gen3")&&(low_str(lane_mask)=="x8"))?"x8_g3"  :
                                                                   (low_str(lane_mask)=="x8")?"x8_g1g2":
                                                                   (low_str(lane_mask)=="x4")?"x4"     :
                                                                   (low_str(lane_mask)=="x2")?"x2"     :"x1"),
         .prot_mode((low_str(gen123_lane_rate_mode)=="gen1_gen2_gen3")?"pipe_g3":
                    (low_str(gen123_lane_rate_mode)=="gen1_gen2")?"pipe_g2":"pipe_g1"),
         .vc_enable(vc_enable),
         .enable_slot_register(enable_slot_register),
         .pcie_mode(pcie_mode),
         .bypass_cdc(bypass_cdc),
         .enable_rx_reordering(enable_rx_reordering),
         .enable_rx_buffer_checking(enable_rx_buffer_checking),
         .single_rx_detect_data(single_rx_detect),
         .use_crc_forwarding(use_crc_forwarding),
         .bypass_tl(bypass_tl),
         .gen123_lane_rate_mode(gen123_lane_rate_mode),
         .lane_mask(lane_mask),
         .disable_link_x2_support(disable_link_x2_support),
         .national_inst_thru_enhance(national_inst_thru_enhance),
         .hip_hard_reset(hip_hard_reset),
         .dis_paritychk(dis_paritychk),
         .wrong_device_id(wrong_device_id),
         .data_pack_rx(data_pack_rx),
         .ast_width(ast_width),
         .rx_sop_ctrl((low_str(ast_width)=="rx_tx_256")? "boundary_256":rx_sop_ctrl),
         .rx_ast_parity(rx_ast_parity),
         .tx_ast_parity(tx_ast_parity),
         .ltssm_1ms_timeout(ltssm_1ms_timeout),
         .ltssm_freqlocked_check(ltssm_freqlocked_check),
         .deskew_comma(deskew_comma),
         .port_link_number_data(port_link_number),
         .device_number_data(device_number),
         .bypass_clk_switch(bypass_clk_switch),
         .core_clk_out_sel(core_clk_out_sel),
         .core_clk_divider(core_clk_divider),
         .core_clk_source(core_clk_source),
         .core_clk_sel(core_clk_sel),
         .enable_ch0_pclk_out(enable_ch0_pclk_out),
         .enable_ch01_pclk_out(enable_ch01_pclk_out),
         .pipex1_debug_sel(pipex1_debug_sel),
         .pclk_out_sel(pclk_out_sel),
         .vendor_id_data(vendor_id),
         .device_id_data(device_id),
         .revision_id_data(revision_id),
         .class_code_data(class_code),
         .subsystem_vendor_id_data(subsystem_vendor_id),
         .subsystem_device_id_data(subsystem_device_id),
         .no_soft_reset(no_soft_reset),
         .maximum_current_data(maximum_current),
         .d1_support(d1_support),
         .d2_support(d2_support),
         .d0_pme(d0_pme),
         .d1_pme(d1_pme),
         .d2_pme(d2_pme),
         .d3_hot_pme(d3_hot_pme),
         .d3_cold_pme(d3_cold_pme),
         .use_aer(use_aer),
         .low_priority_vc(low_priority_vc),
         .vc_arbitration(vc_arbitration),
         .disable_snoop_packet(disable_snoop_packet),
         .max_payload_size(max_payload_size),
         .surprise_down_error_support(surprise_down_error_support),
         .dll_active_report_support(dll_active_report_support),
         .extend_tag_field(extend_tag_field),
         .endpoint_l0_latency_data(endpoint_l0_latency),
         .endpoint_l1_latency_data(endpoint_l1_latency),
         .indicator_data(indicator),
         .slot_power_scale_data(slot_power_scale),
         .max_link_width(lane_mask),
         .enable_l1_aspm(enable_l1_aspm),
         .l1_exit_latency_sameclock_data(l1_exit_latency_sameclock),
         .l1_exit_latency_diffclock_data(l1_exit_latency_diffclock),
         .hot_plug_support_data(hot_plug_support),
         .slot_power_limit_data(slot_power_limit),
         .slot_number_data(slot_number),
         .diffclock_nfts_count_data(diffclock_nfts_count),
         .sameclock_nfts_count_data(sameclock_nfts_count),
         .completion_timeout(completion_timeout),
         .enable_completion_timeout_disable(enable_completion_timeout_disable),
               .extended_tag_reset(extended_tag_reset),
               .ecrc_check_capable(ecrc_check_capable),
               .ecrc_gen_capable(ecrc_gen_capable),
               .no_command_completed(no_command_completed),
               .msi_multi_message_capable(msi_multi_message_capable),
               .msi_64bit_addressing_capable(msi_64bit_addressing_capable),
               .msi_masking_capable(msi_masking_capable),
               .msi_support(msi_support),
               .interrupt_pin(interrupt_pin),
               .enable_function_msix_support(enable_function_msix_support),
               .msix_table_size_data(msix_table_size),
               .msix_table_bir_data(msix_table_bir),
               .msix_table_offset_data(msix_table_offset),
               .msix_pba_bir_data(msix_pba_bir),
               .msix_pba_offset_data(msix_pba_offset),
               .bridge_port_vga_enable(bridge_port_vga_enable),
               .bridge_port_ssid_support(bridge_port_ssid_support),
               .ssvid_data(ssvid),
               .ssid_data(ssid),
               .eie_before_nfts_count_data(eie_before_nfts_count),
               .gen2_diffclock_nfts_count_data(gen2_diffclock_nfts_count),
               .gen2_sameclock_nfts_count_data(gen2_sameclock_nfts_count),
               .deemphasis_enable(deemphasis_enable),
               .pcie_spec_version(pcie_spec_version),
               .l0_exit_latency_sameclock_data(l0_exit_latency_sameclock),
               .l0_exit_latency_diffclock_data(l0_exit_latency_diffclock),
               .rx_ei_l0s(rx_ei_l0s),
               .l2_async_logic(l2_async_logic),
               .aspm_config_management(aspm_config_management),
               .atomic_op_routing(atomic_op_routing),
               .atomic_op_completer_32bit(atomic_op_completer_32bit),
               .atomic_op_completer_64bit(atomic_op_completer_64bit),
               .cas_completer_128bit(cas_completer_128bit),
               .ltr_mechanism(ltr_mechanism),
               .tph_completer(tph_completer),
               .extended_format_field(extended_format_field),
               .atomic_malformed(atomic_malformed),
               .flr_capability(flr_capability),
               .enable_adapter_half_rate_mode(enable_adapter_half_rate_mode),
               .vc0_clk_enable(vc0_clk_enable),
               .vc1_clk_enable(vc1_clk_enable),
               .register_pipe_signals(register_pipe_signals),
               .bar0_io_space(bar0_io_space),
               .bar0_64bit_mem_space(bar0_64bit_mem_space),
               .bar0_prefetchable(bar0_prefetchable),
               .bar0_size_mask_data(bar0_size_mask),
               .bar1_io_space(bar1_io_space),
               .bar1_64bit_mem_space(bar1_64bit_mem_space),
               .bar1_prefetchable(bar1_prefetchable),
               .bar1_size_mask_data(bar1_size_mask),
               .bar2_io_space(bar2_io_space),
               .bar2_64bit_mem_space(bar2_64bit_mem_space),
               .bar2_prefetchable(bar2_prefetchable),
               .bar2_size_mask_data(bar2_size_mask),
               .bar3_io_space(bar3_io_space),
               .bar3_64bit_mem_space(bar3_64bit_mem_space),
               .bar3_prefetchable(bar3_prefetchable),
               .bar3_size_mask_data(bar3_size_mask),
               .bar4_io_space(bar4_io_space),
               .bar4_64bit_mem_space(bar4_64bit_mem_space),
               .bar4_prefetchable(bar4_prefetchable),
               .bar4_size_mask_data(bar4_size_mask),
               .bar5_io_space(bar5_io_space),
               .bar5_64bit_mem_space(bar5_64bit_mem_space),
               .bar5_prefetchable(bar5_prefetchable),
               .bar5_size_mask_data(bar5_size_mask),
               .expansion_base_address_register_data(expansion_base_address_register),
               .io_window_addr_width(io_window_addr_width),
               .prefetchable_mem_window_addr_width(prefetchable_mem_window_addr_width),
               .skp_os_gen3_count_data(skp_os_gen3_count),
               .tx_cdc_almost_empty_data(tx_cdc_almost_empty),
               .rx_cdc_almost_full_data(rx_cdc_almost_full),
               .tx_cdc_almost_full_data(tx_cdc_almost_full),
               .rx_l0s_count_idl_data(rx_l0s_count_idl),
               .cdc_dummy_insert_limit_data(cdc_dummy_insert_limit),
               .ei_delay_powerdown_count_data(ei_delay_powerdown_count),
               .millisecond_cycle_count_data(millisecond_cycle_count),
               .skp_os_schedule_count_data(skp_os_schedule_count),
               .fc_init_timer_data(fc_init_timer),
               .l01_entry_latency_data(l01_entry_latency),
               .flow_control_update_count_data(flow_control_update_count),
               .flow_control_timeout_count_data(flow_control_timeout_count),
               .vc0_rx_flow_ctrl_posted_header_data(vc0_rx_flow_ctrl_posted_header),
               .vc0_rx_flow_ctrl_posted_data_data(vc0_rx_flow_ctrl_posted_data),
               .vc0_rx_flow_ctrl_nonposted_header_data(vc0_rx_flow_ctrl_nonposted_header),
               .vc0_rx_flow_ctrl_nonposted_data_data(vc0_rx_flow_ctrl_nonposted_data),
               .vc0_rx_flow_ctrl_compl_header_data(vc0_rx_flow_ctrl_compl_header),
               .vc0_rx_flow_ctrl_compl_data_data(vc0_rx_flow_ctrl_compl_data),
               .rx_ptr0_posted_dpram_min_data(rx_ptr0_posted_dpram_min),
               .rx_ptr0_posted_dpram_max_data(rx_ptr0_posted_dpram_max),
               .rx_ptr0_nonposted_dpram_min_data(rx_ptr0_nonposted_dpram_min),
               .rx_ptr0_nonposted_dpram_max_data(rx_ptr0_nonposted_dpram_max),
               .retry_buffer_last_active_address_data(retry_buffer_last_active_address),
               .retry_buffer_memory_settings_data(retry_buffer_memory_settings),
               .vc0_rx_buffer_memory_settings_data(vc0_rx_buffer_memory_settings),
               .bist_memory_settings_data(bist_memory_settings),
               .credit_buffer_allocation_aux(credit_buffer_allocation_aux),
               .iei_enable_settings(iei_enable_settings),
               .vsec_id_data(vsec_id),
               .cvp_rate_sel(cvp_rate_sel),
               .hard_reset_bypass(hard_reset_bypass),
               .cvp_data_compressed(cvp_data_compressed),
               .cvp_data_encrypted(cvp_data_encrypted),
               .cvp_mode_reset(cvp_mode_reset),
               .cvp_clk_reset(cvp_clk_reset),
               .in_cvp_mode(in_cvp_mode),
               .vsec_cap_data(vsec_cap),
               .jtag_id_data(jtag_id),
               .user_id_data(user_id),
               .cseb_extend_pci(cseb_extend_pci),
               .cseb_extend_pcie(cseb_extend_pcie),
               .cseb_cpl_status_during_cvp(cseb_cpl_status_during_cvp),
               .cseb_route_to_avl_rx_st(cseb_route_to_avl_rx_st),
               .cseb_config_bypass(cseb_config_bypass),
               .cseb_cpl_tag_checking(cseb_cpl_tag_checking),
               .cseb_bar_match_checking(cseb_bar_match_checking),
               .cseb_min_error_checking(cseb_min_error_checking),
               .cseb_temp_busy_crs(cseb_temp_busy_crs),
               .gen3_diffclock_nfts_count_data(gen3_diffclock_nfts_count),
               .gen3_sameclock_nfts_count_data(gen3_sameclock_nfts_count),
               .gen3_coeff_errchk(gen3_coeff_errchk),
               .gen3_paritychk(gen3_paritychk),
               .gen3_coeff_delay_count_data(gen3_coeff_delay_count),
               .gen3_coeff_1_data(gen3_coeff_1),
               .gen3_coeff_1_sel(gen3_coeff_1_sel),
               .gen3_coeff_1_preset_hint_data(gen3_coeff_1_preset_hint),
               .gen3_coeff_1_nxtber_more_ptr(gen3_coeff_1_nxtber_more_ptr),
               .gen3_coeff_1_nxtber_more(gen3_coeff_1_nxtber_more),
               .gen3_coeff_1_nxtber_less_ptr(gen3_coeff_1_nxtber_less_ptr),
               .gen3_coeff_1_nxtber_less(gen3_coeff_1_nxtber_less),
               .gen3_coeff_1_reqber_data(gen3_coeff_1_reqber),
               .gen3_coeff_1_ber_meas_data(gen3_coeff_1_ber_meas),
               .gen3_coeff_2_data(gen3_coeff_2),
               .gen3_coeff_2_sel(gen3_coeff_2_sel),
               .gen3_coeff_2_preset_hint_data(gen3_coeff_2_preset_hint),
               .gen3_coeff_2_nxtber_more_ptr(gen3_coeff_2_nxtber_more_ptr),
               .gen3_coeff_2_nxtber_more(gen3_coeff_2_nxtber_more),
               .gen3_coeff_2_nxtber_less_ptr(gen3_coeff_2_nxtber_less_ptr),
               .gen3_coeff_2_nxtber_less(gen3_coeff_2_nxtber_less),
               .gen3_coeff_2_reqber_data(gen3_coeff_2_reqber),
               .gen3_coeff_2_ber_meas_data(gen3_coeff_2_ber_meas),
               .gen3_coeff_3_data(gen3_coeff_3),
               .gen3_coeff_3_sel(gen3_coeff_3_sel),
               .gen3_coeff_3_preset_hint_data(gen3_coeff_3_preset_hint),
               .gen3_coeff_3_nxtber_more_ptr(gen3_coeff_3_nxtber_more_ptr),
               .gen3_coeff_3_nxtber_more(gen3_coeff_3_nxtber_more),
               .gen3_coeff_3_nxtber_less_ptr(gen3_coeff_3_nxtber_less_ptr),
               .gen3_coeff_3_nxtber_less(gen3_coeff_3_nxtber_less),
               .gen3_coeff_3_reqber_data(gen3_coeff_3_reqber),
               .gen3_coeff_3_ber_meas_data(gen3_coeff_3_ber_meas),
               .gen3_coeff_4_data(gen3_coeff_4),
               .gen3_coeff_4_sel(gen3_coeff_4_sel),
               .gen3_coeff_4_preset_hint_data(gen3_coeff_4_preset_hint),
               .gen3_coeff_4_nxtber_more_ptr(gen3_coeff_4_nxtber_more_ptr),
               .gen3_coeff_4_nxtber_more(gen3_coeff_4_nxtber_more),
               .gen3_coeff_4_nxtber_less_ptr(gen3_coeff_4_nxtber_less_ptr),
               .gen3_coeff_4_nxtber_less(gen3_coeff_4_nxtber_less),
               .gen3_coeff_4_reqber_data(gen3_coeff_4_reqber),
               .gen3_coeff_4_ber_meas_data(gen3_coeff_4_ber_meas),
               .gen3_coeff_5_data(gen3_coeff_5),
               .gen3_coeff_5_sel(gen3_coeff_5_sel),
               .gen3_coeff_5_preset_hint_data(gen3_coeff_5_preset_hint),
               .gen3_coeff_5_nxtber_more_ptr(gen3_coeff_5_nxtber_more_ptr),
               .gen3_coeff_5_nxtber_more(gen3_coeff_5_nxtber_more),
               .gen3_coeff_5_nxtber_less_ptr(gen3_coeff_5_nxtber_less_ptr),
               .gen3_coeff_5_nxtber_less(gen3_coeff_5_nxtber_less),
               .gen3_coeff_5_reqber_data(gen3_coeff_5_reqber),
               .gen3_coeff_5_ber_meas_data(gen3_coeff_5_ber_meas),
               .gen3_coeff_6_data(gen3_coeff_6),
               .gen3_coeff_6_sel(gen3_coeff_6_sel),
               .gen3_coeff_6_preset_hint_data(gen3_coeff_6_preset_hint),
               .gen3_coeff_6_nxtber_more_ptr(gen3_coeff_6_nxtber_more_ptr),
               .gen3_coeff_6_nxtber_more(gen3_coeff_6_nxtber_more),
               .gen3_coeff_6_nxtber_less_ptr(gen3_coeff_6_nxtber_less_ptr),
               .gen3_coeff_6_nxtber_less(gen3_coeff_6_nxtber_less),
               .gen3_coeff_6_reqber_data(gen3_coeff_6_reqber),
               .gen3_coeff_6_ber_meas_data(gen3_coeff_6_ber_meas),
               .gen3_coeff_7_data(gen3_coeff_7),
               .gen3_coeff_7_sel(gen3_coeff_7_sel),
               .gen3_coeff_7_preset_hint_data(gen3_coeff_7_preset_hint),
               .gen3_coeff_7_nxtber_more_ptr(gen3_coeff_7_nxtber_more_ptr),
               .gen3_coeff_7_nxtber_more(gen3_coeff_7_nxtber_more),
               .gen3_coeff_7_nxtber_less_ptr(gen3_coeff_7_nxtber_less_ptr),
               .gen3_coeff_7_nxtber_less(gen3_coeff_7_nxtber_less),
               .gen3_coeff_7_reqber_data(gen3_coeff_7_reqber),
               .gen3_coeff_7_ber_meas_data(gen3_coeff_7_ber_meas),
               .gen3_coeff_8_data(gen3_coeff_8),
               .gen3_coeff_8_sel(gen3_coeff_8_sel),
               .gen3_coeff_8_preset_hint_data(gen3_coeff_8_preset_hint),
               .gen3_coeff_8_nxtber_more_ptr(gen3_coeff_8_nxtber_more_ptr),
               .gen3_coeff_8_nxtber_more(gen3_coeff_8_nxtber_more),
               .gen3_coeff_8_nxtber_less_ptr(gen3_coeff_8_nxtber_less_ptr),
               .gen3_coeff_8_nxtber_less(gen3_coeff_8_nxtber_less),
               .gen3_coeff_8_reqber_data(gen3_coeff_8_reqber),
               .gen3_coeff_8_ber_meas_data(gen3_coeff_8_ber_meas),
               .gen3_coeff_9_data(gen3_coeff_9),
               .gen3_coeff_9_sel(gen3_coeff_9_sel),
               .gen3_coeff_9_preset_hint_data(gen3_coeff_9_preset_hint),
               .gen3_coeff_9_nxtber_more_ptr(gen3_coeff_9_nxtber_more_ptr),
               .gen3_coeff_9_nxtber_more(gen3_coeff_9_nxtber_more),
               .gen3_coeff_9_nxtber_less_ptr(gen3_coeff_9_nxtber_less_ptr),
               .gen3_coeff_9_nxtber_less(gen3_coeff_9_nxtber_less),
               .gen3_coeff_9_reqber_data(gen3_coeff_9_reqber),
               .gen3_coeff_9_ber_meas_data(gen3_coeff_9_ber_meas),
               .gen3_coeff_10_data(gen3_coeff_10),
               .gen3_coeff_10_sel(gen3_coeff_10_sel),
               .gen3_coeff_10_preset_hint_data(gen3_coeff_10_preset_hint),
               .gen3_coeff_10_nxtber_more_ptr(gen3_coeff_10_nxtber_more_ptr),
               .gen3_coeff_10_nxtber_more(gen3_coeff_10_nxtber_more),
               .gen3_coeff_10_nxtber_less_ptr(gen3_coeff_10_nxtber_less_ptr),
               .gen3_coeff_10_nxtber_less(gen3_coeff_10_nxtber_less),
               .gen3_coeff_10_reqber_data(gen3_coeff_10_reqber),
               .gen3_coeff_10_ber_meas_data(gen3_coeff_10_ber_meas),
               .gen3_coeff_11_data(gen3_coeff_11),
               .gen3_coeff_11_sel(gen3_coeff_11_sel),
               .gen3_coeff_11_preset_hint_data(gen3_coeff_11_preset_hint),
               .gen3_coeff_11_nxtber_more_ptr(gen3_coeff_11_nxtber_more_ptr),
               .gen3_coeff_11_nxtber_more(gen3_coeff_11_nxtber_more),
               .gen3_coeff_11_nxtber_less_ptr(gen3_coeff_11_nxtber_less_ptr),
               .gen3_coeff_11_nxtber_less(gen3_coeff_11_nxtber_less),
               .gen3_coeff_11_reqber_data(gen3_coeff_11_reqber),
               .gen3_coeff_11_ber_meas_data(gen3_coeff_11_ber_meas),
               .gen3_coeff_12_data(gen3_coeff_12),
               .gen3_coeff_12_sel(gen3_coeff_12_sel),
               .gen3_coeff_12_preset_hint_data(gen3_coeff_12_preset_hint),
               .gen3_coeff_12_nxtber_more_ptr(gen3_coeff_12_nxtber_more_ptr),
               .gen3_coeff_12_nxtber_more(gen3_coeff_12_nxtber_more),
               .gen3_coeff_12_nxtber_less_ptr(gen3_coeff_12_nxtber_less_ptr),
               .gen3_coeff_12_nxtber_less(gen3_coeff_12_nxtber_less),
               .gen3_coeff_12_reqber_data(gen3_coeff_12_reqber),
               .gen3_coeff_12_ber_meas_data(gen3_coeff_12_ber_meas),
               .gen3_coeff_13_data(gen3_coeff_13),
               .gen3_coeff_13_sel(gen3_coeff_13_sel),
               .gen3_coeff_13_preset_hint_data(gen3_coeff_13_preset_hint),
               .gen3_coeff_13_nxtber_more_ptr(gen3_coeff_13_nxtber_more_ptr),
               .gen3_coeff_13_nxtber_more(gen3_coeff_13_nxtber_more),
               .gen3_coeff_13_nxtber_less_ptr(gen3_coeff_13_nxtber_less_ptr),
               .gen3_coeff_13_nxtber_less(gen3_coeff_13_nxtber_less),
               .gen3_coeff_13_reqber_data(gen3_coeff_13_reqber),
               .gen3_coeff_13_ber_meas_data(gen3_coeff_13_ber_meas),
               .gen3_coeff_14_data(gen3_coeff_14),
               .gen3_coeff_14_sel(gen3_coeff_14_sel),
               .gen3_coeff_14_preset_hint_data(gen3_coeff_14_preset_hint),
               .gen3_coeff_14_nxtber_more_ptr(gen3_coeff_14_nxtber_more_ptr),
               .gen3_coeff_14_nxtber_more(gen3_coeff_14_nxtber_more),
               .gen3_coeff_14_nxtber_less_ptr(gen3_coeff_14_nxtber_less_ptr),
               .gen3_coeff_14_nxtber_less(gen3_coeff_14_nxtber_less),
               .gen3_coeff_14_reqber_data(gen3_coeff_14_reqber),
               .gen3_coeff_14_ber_meas_data(gen3_coeff_14_ber_meas),
               .gen3_coeff_15_data(gen3_coeff_15),
               .gen3_coeff_15_sel(gen3_coeff_15_sel),
               .gen3_coeff_15_preset_hint_data(gen3_coeff_15_preset_hint),
               .gen3_coeff_15_nxtber_more_ptr(gen3_coeff_15_nxtber_more_ptr),
               .gen3_coeff_15_nxtber_more(gen3_coeff_15_nxtber_more),
               .gen3_coeff_15_nxtber_less_ptr(gen3_coeff_15_nxtber_less_ptr),
               .gen3_coeff_15_nxtber_less(gen3_coeff_15_nxtber_less),
               .gen3_coeff_15_reqber_data(gen3_coeff_15_reqber),
               .gen3_coeff_15_ber_meas_data(gen3_coeff_15_ber_meas),
               .gen3_coeff_16_data(gen3_coeff_16),
               .gen3_coeff_16_sel(gen3_coeff_16_sel),
               .gen3_coeff_16_preset_hint_data(gen3_coeff_16_preset_hint),
               .gen3_coeff_16_nxtber_more_ptr(gen3_coeff_16_nxtber_more_ptr),
               .gen3_coeff_16_nxtber_more(gen3_coeff_16_nxtber_more),
               .gen3_coeff_16_nxtber_less_ptr(gen3_coeff_16_nxtber_less_ptr),
               .gen3_coeff_16_nxtber_less(gen3_coeff_16_nxtber_less),
               .gen3_coeff_16_reqber_data(gen3_coeff_16_reqber),
               .gen3_coeff_16_ber_meas_data(gen3_coeff_16_ber_meas),
               .gen3_preset_coeff_1_data(gen3_preset_coeff_1),
               .gen3_preset_coeff_2_data(gen3_preset_coeff_2),
               .gen3_preset_coeff_3_data(gen3_preset_coeff_3),
               .gen3_preset_coeff_4_data(gen3_preset_coeff_4),
               .gen3_preset_coeff_5_data(gen3_preset_coeff_5),
               .gen3_preset_coeff_6_data(gen3_preset_coeff_6),
               .gen3_preset_coeff_7_data(gen3_preset_coeff_7),
               .gen3_preset_coeff_8_data(gen3_preset_coeff_8),
               .gen3_preset_coeff_9_data(gen3_preset_coeff_9),
               .gen3_preset_coeff_10_data(gen3_preset_coeff_10),
               .gen3_rxfreqlock_counter_data(gen3_rxfreqlock_counter)
         ) stratixv_hssi_gen3_pcie_hip  (
               .aermsinum                  (aer_msi_num                                    ),
               .appintasts                 (app_int_sts                                    ),
               .appmsinum                  (app_msi_num                                    ),
               .appmsireq                  (app_msi_req                                    ),
               .appmsitc                   (app_msi_tc                                     ),
               .bistenrcv                  (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:bistenrcv ),
               .bistenrpl                  (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:bistenrpl ),
               .bistscanen                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:bistscanen),
               .bistscanin                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:bistscanin),
               .bisttesten                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:bisttesten),
               .cfglink2csrpld             (cfglink2csrpld                                 ), //??
               .coreclkin                  (pld_clk_hip                          ),//
               .corecrst                   (crst                                 ),//
               .corepor                    (~npor                                ),//
               .corerst                    (~npor                                ),//
               .coresrst                   (srst                                 ),//

               .cplerr                     (cpl_err                               ),//
               .cplpending                 (cpl_pending                           ),//

               .csebrddata                 ((ACDS_V10==1)?32'h0 :csebrddata      ),//
               .csebrddataparity           ((ACDS_V10==1)?4'h0  :csebrddataparity),//
               .csebrdresponse             ((ACDS_V10==1)?3'h0  :csebrdresponse  ),//
               .csebwaitrequest            ((ACDS_V10==1)?1'b0  :csebwaitrequest ),//
               .csebwrresponse             ((ACDS_V10==1)?3'h0  :csebwrresponse  ),//
               .csebwrrespvalid            ((ACDS_V10==1)?1'b0  :csebwrrespvalid ),//
               .dbgpipex1rx                ((ACDS_V10==1)?44'h0 :dbgpipex1rx     ),//
               .entest                     ((ACDS_V10==1)?1'b0  :entest          ),
               .frzlogic                   (frzlogic                             ),
               .frzreg                     (frzreg                               ),
               .hpgctrler                  (hpg_ctrler                            ),
               .idrcv                      (idrcv                                ),
               .idrpl                      (idrpl                                ),
               .lmiaddr                    (lmi_addr                              ),//
               .lmidin                     (lmi_din                               ),//
               .lmirden                    (lmi_rden                              ),//
               .lmiwren                    (lmi_wren                              ),//
               .memhiptestenable           (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:memhiptestenable           ),
               .memredenscan               (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:memredenscan               ),
               .memredscen                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:memredscen                 ),
               .memredscin                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:memredscin                 ),
               .memredsclk                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:memredsclk                 ),
               .memredscrst                (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:memredscrst                ),
               .memredscsel                (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:memredscsel                ),
               .memregscanen               (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:memregscanen               ),
               .memregscanin               (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:memregscanin               ),
               .mode                       (mode                       ),
               .nfrzdrv                    (((ACDS_V10==1)||(MEM_CHECK==0))?1'b0:nfrzdrv                    ),
               .npor                       (npor                       ),
               .pclkcentral                ((pipe_mode_simu_only==1'b1)? sim_pipe32_pclk: mserdes_pipe_pclkcentral), //TODO check rules for pclk for central vs cho
               .pclkch0                    ((pipe_mode_simu_only==1'b1)? sim_pipe32_pclk: mserdes_pipe_pclk),
               .pclkch1                    ((pipe_mode_simu_only==1'b1)? sim_pipe32_pclk: mserdes_pipe_pclkch1),//TODO  FIX SIMULATION MODEL which misses this port add this ports
               .pexmsinum                  (pex_msi_num                  ),
               .phyrst                     (~npor                      ), //
               .physrst                    (srst                       ), //
               .phystatus0                 (phystatus0                 ),
               .phystatus1                 (phystatus1                 ),
               .phystatus2                 (phystatus2                 ),
               .phystatus3                 (phystatus3                 ),
               .phystatus4                 (phystatus4                 ),
               .phystatus5                 (phystatus5                 ),
               .phystatus6                 (phystatus6                 ),
               .phystatus7                 (phystatus7                 ),
               .pldclk                     (pld_clk_hip                ),  //
               .pldrst                     (~npor                      ),  // Removed IO connected to ~npor
               .pldsrst                    (srst                       ),   // Removed IO connected to ~npor,
               .pllfixedclkcentral         ((pipe_mode_simu_only==1'b0)? mserdes_pllfixedclkcentral:(low_str(gen123_lane_rate_mode)=="gen1_gen2")?clk500_out:clk250_out),  //TODO add this ports
               .pllfixedclkch0             ((pipe_mode_simu_only==1'b0)? mserdes_pllfixedclkch0    :(low_str(gen123_lane_rate_mode)=="gen1_gen2")?clk500_out:clk250_out),  //TODO add this ports
               .pllfixedclkch1             ((pipe_mode_simu_only==1'b0)? mserdes_pllfixedclkch1    :(low_str(gen123_lane_rate_mode)=="gen1_gen2")?clk500_out:clk250_out),  //TODO FIX SIM MODEL which misses this port add this ports
               .plniotri                   (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:plniotri),
               .pmauxpwr                   (pm_auxpwr                   ),
               .pmdata                     (pm_data                     ),
               .pmetocr                    (pme_to_cr                    ),
               .pmevent                    (pm_event                    ),
               //.rxblkst0                   (rxblkst0                   ),//TODO Gen3
               //.rxblkst1                   (rxblkst1                   ),//TODO Gen3
               //.rxblkst2                   (rxblkst2                   ),//TODO Gen3
               //.rxblkst3                   (rxblkst3                   ),//TODO Gen3
               //.rxblkst4                   (rxblkst4                   ),//TODO Gen3
               //.rxblkst5                   (rxblkst5                   ),//TODO Gen3
               //.rxblkst6                   (rxblkst6                   ),//TODO Gen3
               //.rxblkst7                   (rxblkst7                   ),//TODO Gen3
               .rxdata0                    (rxdata0                    ),
               .rxdata1                    (rxdata1                    ),
               .rxdata2                    (rxdata2                    ),
               .rxdata3                    (rxdata3                    ),
               .rxdata4                    (rxdata4                    ),
               .rxdata5                    (rxdata5                    ),
               .rxdata6                    (rxdata6                    ),
               .rxdata7                    (rxdata7                    ),
               .rxdatak0                   (rxdatak0                   ),
               .rxdatak1                   (rxdatak1                   ),
               .rxdatak2                   (rxdatak2                   ),
               .rxdatak3                   (rxdatak3                   ),
               .rxdatak4                   (rxdatak4                   ),
               .rxdatak5                   (rxdatak5                   ),
               .rxdatak6                   (rxdatak6                   ),
               .rxdatak7                   (rxdatak7                   ),
               .rxdataskip0                (rxdataskip0                ),//TODO Gen3
               .rxdataskip1                (rxdataskip1                ),//TODO Gen3
               .rxdataskip2                (rxdataskip2                ),//TODO Gen3
               .rxdataskip3                (rxdataskip3                ),//TODO Gen3
               .rxdataskip4                (rxdataskip4                ),//TODO Gen3
               .rxdataskip5                (rxdataskip5                ),//TODO Gen3
               .rxdataskip6                (rxdataskip6                ),//TODO Gen3
               .rxdataskip7                (rxdataskip7                ),//TODO Gen3
               .rxelecidle0                (rxelecidle0                ),
               .rxelecidle1                (rxelecidle1                ),
               .rxelecidle2                (rxelecidle2                ),
               .rxelecidle3                (rxelecidle3                ),
               .rxelecidle4                (rxelecidle4                ),
               .rxelecidle5                (rxelecidle5                ),
               .rxelecidle6                (rxelecidle6                ),
               .rxelecidle7                (rxelecidle7                ),
               .rxfreqlocked0              (rxfreqlocked0              ),//TODO Gen3
               .rxfreqlocked1              (rxfreqlocked1              ),//TODO Gen3
               .rxfreqlocked2              (rxfreqlocked2              ),//TODO Gen3
               .rxfreqlocked3              (rxfreqlocked3              ),//TODO Gen3
               .rxfreqlocked4              (rxfreqlocked4              ),//TODO Gen3
               .rxfreqlocked5              (rxfreqlocked5              ),//TODO Gen3
               .rxfreqlocked6              (rxfreqlocked6              ),//TODO Gen3
               .rxfreqlocked7              (rxfreqlocked7              ),//TODO Gen3
               .rxstatus0                  (rxstatus0                  ),
               .rxstatus1                  (rxstatus1                  ),
               .rxstatus2                  (rxstatus2                  ),
               .rxstatus3                  (rxstatus3                  ),
               .rxstatus4                  (rxstatus4                  ),
               .rxstatus5                  (rxstatus5                  ),
               .rxstatus6                  (rxstatus6                  ),
               .rxstatus7                  (rxstatus7                  ),
               .rxstmask                   (rxstmask                   ),//
               .rxstready                  (rxstready                  ),//
               .rxsynchd0                  (rxsynchd0                  ),//TODO Gen3
               .rxsynchd1                  (rxsynchd1                  ),//TODO Gen3
               .rxsynchd2                  (rxsynchd2                  ),//TODO Gen3
               .rxsynchd3                  (rxsynchd3                  ),//TODO Gen3
               .rxsynchd4                  (rxsynchd4                  ),//TODO Gen3
               .rxsynchd5                  (rxsynchd5                  ),//TODO Gen3
               .rxsynchd6                  (rxsynchd6                  ),//TODO Gen3
               .rxsynchd7                  (rxsynchd7                  ),//TODO Gen3
               .rxvalid0                   (rxvalid0                   ),
               .rxvalid1                   (rxvalid1                   ),
               .rxvalid2                   (rxvalid2                   ),
               .rxvalid3                   (rxvalid3                   ),
               .rxvalid4                   (rxvalid4                   ),
               .rxvalid5                   (rxvalid5                   ),
               .rxvalid6                   (rxvalid6                   ),
               .rxvalid7                   (rxvalid7                   ),
               .scanmoden                  (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:scanmoden),
               .scanshiftn                 (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:scanshiftn),
               .slotclkcfg                 (tl_slotclk_cfg               ),
               .swctmod                    (swctmod                    ),
// should be tied down at var_core.v
//               .swdnin                     (swdn_in                    ),
//               .swupin                     (swup_in                    ),
               .swdnin                     (3'b000                    ),
               .swupin                     (7'b0000000                    ),
               .testinhip                  (test_in                    ),
               .txstdata                   (txstdata                   ),//
               .txstempty                  (txstempty                  ),//
               .txsteop                    (txsteop                    ),//
               .txsterr                    (txsterr                    ),//
               .txstparity                 (txstparity                 ),//
               .txstsop                    (txstsop                    ),//
               .txstvalid                  (txstvalid                  ),//
               .usermode                   (((ACDS_V10==1)||(MEM_CHECK==0))?1'b1:usermode),
               .hiphardreset               (hiphardreset),

               .appintaack                 (app_int_ack                 ),
               .appmsiack                  (app_msi_ack                  ),
               .bistdonearcv               (bistdonearcv                ),
               .bistdonearcv1              (bistdonearcv1               ),
               .bistdonearpl               (bistdonearpl                ),
               .bistdonebrcv               (bistdonebrcv                ),
               .bistdonebrcv1              (bistdonebrcv1               ),
               .bistdonebrpl               (bistdonebrpl                ),
               .bistpassrcv                (bistpassrcv                 ),
               .bistpassrcv1               (bistpassrcv1                ),
               .bistpassrpl                (bistpassrpl                 ),
               .bistscanoutrcv             (bistscanoutrcv              ),
               .bistscanoutrcv1            (bistscanoutrcv1             ),
               .bistscanoutrpl             (bistscanoutrpl              ),
               .coreclkout                 (coreclkout_hip             ),
               .csebaddr                   (csebaddr                   ),
               .csebaddrparity             (csebaddrparity             ),
               .csebbe                     (csebbe                     ),
               .csebisshadow               (csebisshadow               ),
               .csebrden                   (csebrden                   ),
               .csebwrdata                 (csebwrdata                 ),
               .csebwrdataparity           (csebwrdataparity           ),
               .csebwren                   (csebwren                   ),
               .csebwrrespreq              (csebwrrespreq              ),
               .currentcoeff0              (currentcoeff0              ),
               .currentcoeff1              (currentcoeff1              ),
               .currentcoeff2              (currentcoeff2              ),
               .currentcoeff3              (currentcoeff3              ),
               .currentcoeff4              (currentcoeff4              ),
               .currentcoeff5              (currentcoeff5              ),
               .currentcoeff6              (currentcoeff6              ),
               .currentcoeff7              (currentcoeff7              ),
               .currentrxpreset0           (currentrxpreset0           ),
               .currentrxpreset1           (currentrxpreset1           ),
               .currentrxpreset2           (currentrxpreset2           ),
               .currentrxpreset3           (currentrxpreset3           ),
               .currentrxpreset4           (currentrxpreset4           ),
               .currentrxpreset5           (currentrxpreset5           ),
               .currentrxpreset6           (currentrxpreset6           ),
               .currentrxpreset7           (currentrxpreset7           ),
               .currentspeed               (currentspeed               ),
               .derrcorextrcv              (derr_cor_ext_rcv           ),
               .derrcorextrcv1             (derr_cor_ext_rcv1          ),
               .derrcorextrpl              (derr_cor_ext_rpl           ),
               .derrrpl                    (derr_rpl                   ),
               .dlup                       (dlup                       ),
               .dlupexit                   (dlup_exit                  ),
               .eidleinfersel0             (eidleinfersel0             ),
               .eidleinfersel1             (eidleinfersel1             ),
               .eidleinfersel2             (eidleinfersel2             ),
               .eidleinfersel3             (eidleinfersel3             ),
               .eidleinfersel4             (eidleinfersel4             ),
               .eidleinfersel5             (eidleinfersel5             ),
               .eidleinfersel6             (eidleinfersel6             ),
               .eidleinfersel7             (eidleinfersel7             ),
               .ev128ns                    (ev128ns                    ),
               .ev1us                      (ev1us                      ),
               .hotrstexit                 (hotrst_exit                ),
               .intstatus                  (int_status                 ),
               .l2exit                     (l2_exit                    ),
               .laneact                    (lane_act                   ),
               .lmiack                     (lmi_ack                    ),
               .lmidout                    (lmi_dout                   ),
               .ltssmstate                 (ltssmstate                 ),
               .memredscout                (memredscout                ),
               .memregscanout              (memregscanout              ),
               .pmetosr                    (pme_to_sr                  ),
               .powerdown0                 (powerdown0                 ),
               .powerdown1                 (powerdown1                 ),
               .powerdown2                 (powerdown2                 ),
               .powerdown3                 (powerdown3                 ),
               .powerdown4                 (powerdown4                 ),
               .powerdown5                 (powerdown5                 ),
               .powerdown6                 (powerdown6                 ),
               .powerdown7                 (powerdown7                 ),
               .rate0                      (rate0                      ),
               .rate1                      (rate1                      ),
               .rate2                      (rate2                      ),
               .rate3                      (rate3                      ),
               .rate4                      (rate4                      ),
               .rate5                      (rate5                      ),
               .rate6                      (rate6                      ),
               .rate7                      (rate7                      ),
               .resetstatus                (resetstatus                ),
               .rxpolarity0                (rxpolarity0                ),
               .rxpolarity1                (rxpolarity1                ),
               .rxpolarity2                (rxpolarity2                ),
               .rxpolarity3                (rxpolarity3                ),
               .rxpolarity4                (rxpolarity4                ),
               .rxpolarity5                (rxpolarity5                ),
               .rxpolarity6                (rxpolarity6                ),
               .rxpolarity7                (rxpolarity7                ),
               .rxstbardec1                (rxstbardec1                ),//
               .rxstbardec2                (rxstbardec2                ),//
               .rxstbe                     (rxstbe                     ),//
               .rxstdata                   (rxstdata                   ),//
               .rxstempty                  (rxstempty                  ),//
               .rxsteop                    (rxsteop                    ),//
               .rxsterr                    (rxsterr                    ),//
               .rxstparity                 (rxstparity                 ),//
               .rxstsop                    (rxstsop                    ),//
               .rxstvalid                  (rxstvalid                  ),//
               .serrout                    (serr_out                   ),
               .swdnout                    (swdnout                    ),
               .swupout                    (swupout                    ),
               .testouthip                 (test_out                   ),
               .tlcfgadd                   (tl_cfg_add                 ),
               .tlcfgctl                   (tl_cfg_ctl                 ),
               .tlcfgsts                   (tl_cfg_sts                 ),
               .txblkst0                   (txblkst0                   ),
               .txblkst1                   (txblkst1                   ),
               .txblkst2                   (txblkst2                   ),
               .txblkst3                   (txblkst3                   ),
               .txblkst4                   (txblkst4                   ),
               .txblkst5                   (txblkst5                   ),
               .txblkst6                   (txblkst6                   ),
               .txblkst7                   (txblkst7                   ),
               .txcompl0                   (txcompl0                   ),
               .txcompl1                   (txcompl1                   ),
               .txcompl2                   (txcompl2                   ),
               .txcompl3                   (txcompl3                   ),
               .txcompl4                   (txcompl4                   ),
               .txcompl5                   (txcompl5                   ),
               .txcompl6                   (txcompl6                   ),
               .txcompl7                   (txcompl7                   ),
               .txcreddatafccp             (tx_cred_datafccp           ),
               .txcreddatafcnp             (tx_cred_datafcnp           ),
               .txcreddatafcp              (tx_cred_datafcp            ),
               .txcredfchipcons            (tx_cred_fchipcons          ),
               .txcredfcinfinite           (tx_cred_fcinfinite         ),
               .txcredhdrfccp              (tx_cred_hdrfccp            ),
               .txcredhdrfcnp              (tx_cred_hdrfcnp            ),
               .txcredhdrfcp               (tx_cred_hdrfcp             ),
               .txdata0                    (txdata0                    ),
               .txdata1                    (txdata1                    ),
               .txdata2                    (txdata2                    ),
               .txdata3                    (txdata3                    ),
               .txdata4                    (txdata4                    ),
               .txdata5                    (txdata5                    ),
               .txdata6                    (txdata6                    ),
               .txdata7                    (txdata7                    ),
               .txdatak0                   (txdatak0                   ),
               .txdatak1                   (txdatak1                   ),
               .txdatak2                   (txdatak2                   ),
               .txdatak3                   (txdatak3                   ),
               .txdatak4                   (txdatak4                   ),
               .txdatak5                   (txdatak5                   ),
               .txdatak6                   (txdatak6                   ),
               .txdatak7                   (txdatak7                   ),
               .txdeemph0                  (txdeemph0                  ),
               .txdeemph1                  (txdeemph1                  ),
               .txdeemph2                  (txdeemph2                  ),
               .txdeemph3                  (txdeemph3                  ),
               .txdeemph4                  (txdeemph4                  ),
               .txdeemph5                  (txdeemph5                  ),
               .txdeemph6                  (txdeemph6                  ),
               .txdeemph7                  (txdeemph7                  ),
               .txdetectrx0                (txdetectrx0                ),
               .txdetectrx1                (txdetectrx1                ),
               .txdetectrx2                (txdetectrx2                ),
               .txdetectrx3                (txdetectrx3                ),
               .txdetectrx4                (txdetectrx4                ),
               .txdetectrx5                (txdetectrx5                ),
               .txdetectrx6                (txdetectrx6                ),
               .txdetectrx7                (txdetectrx7                ),
               .txelecidle0                (txelecidle0                ),
               .txelecidle1                (txelecidle1                ),
               .txelecidle2                (txelecidle2                ),
               .txelecidle3                (txelecidle3                ),
               .txelecidle4                (txelecidle4                ),
               .txelecidle5                (txelecidle5                ),
               .txelecidle6                (txelecidle6                ),
               .txelecidle7                (txelecidle7                ),
               .txmargin0                  (txmargin0                  ),
               .txmargin1                  (txmargin1                  ),
               .txmargin2                  (txmargin2                  ),
               .txmargin3                  (txmargin3                  ),
               .txmargin4                  (txmargin4                  ),
               .txmargin5                  (txmargin5                  ),
               .txmargin6                  (txmargin6                  ),
               .txmargin7                  (txmargin7                  ),
               .txstready                  (txstready                  ),
               .txsynchd0                  (txsynchd0                  ),
               .txsynchd1                  (txsynchd1                  ),
               .txsynchd2                  (txsynchd2                  ),
               .txsynchd3                  (txsynchd3                  ),
               .txsynchd4                  (txsynchd4                  ),
               .txsynchd5                  (txsynchd5                  ),
               .txsynchd6                  (txsynchd6                  ),
               .txsynchd7                  (txsynchd7                  ),
               .wakeoen                    (wakeoen                    )
            );


   //TODO promote serdes_fixedclk as an input 125Mhz clock to the variant
   generic_pll #        ( .reference_clock_frequency("100.0 MHz"), .output_clock_frequency("125.0 MHz") )
      u_pll_serdes_fixedclk  ( .refclk(refclk), .outclk(serdes_fixedclk),     .locked(locked_serdes), .fboutclk(fboutclk_fixedclk),      .rst((pipe_mode_simu_only==1)?1'b1:~npor), .fbclk(fboutclk_fixedclk));

   assign serdes_pll_powerdown               = rst_ctrl_gxb_powerdown;
   assign serdes_cal_blk_powerdown           = 1'b0;
   assign serdes_cal_blk_clk                 = 1'b0;
   assign serdes_rx_set_locktodata[lanes-1:0]= {lanes{1'b0}};
   assign serdes_rx_set_locktoref [lanes-1:0]= {lanes{1'b0}};
   assign serdes_tx_invpolarity   [lanes-1:0]= {lanes{1'b0}};

   sv_xcvr_pipe_native #(
         .lanes                              (lanes                             ), //legal value: 1+
         .starting_channel_number            (starting_channel_number           ), //legal value: 0+
         .protocol_version                   (protocol_version                  ), //legal value: "gen1", "gen2"
         .deser_factor                       (deser_factor                      ),
         .pll_refclk_freq                    (pll_refclk_freq                   ), //legal value = "100 MHz", "125 MHz"
         .hip_enable                         (hip_enable                        )
      ) sv_xcvr_pipe_native     (
         .pll_powerdown                      ((pipe_mode_simu_only==1'b1)?1'b0           :serdes_pll_powerdown           ), //
         .tx_digitalreset                    ((pipe_mode_simu_only==1'b1)?ONES[lanes-1:0]:serdes_tx_digitalreset [lanes-1:0]), //
         .rx_analogreset                     ((pipe_mode_simu_only==1'b1)?ONES[lanes-1:0]:serdes_rx_analogreset  [lanes-1:0]), //
         .tx_analogreset                     (ZEROS[lanes-1:0]), //
         .rx_digitalreset                    ((pipe_mode_simu_only==1'b1)?ONES[lanes-1:0]:serdes_rx_digitalreset [lanes-1:0]), //

         //clk signal
         .pll_ref_clk                        ((pipe_mode_simu_only==1'b1)?1'b0:refclk), //
         .fixedclk                           ((pipe_mode_simu_only==1'b1)?1'b0:serdes_fixedclk), //

         //pipe interface ports
         .pipe_txdata                        (serdes_pipe_txdata             [lanes * deser_factor - 1:0]), //
         .pipe_txdatak                       (serdes_pipe_txdatak            [((lanes * deser_factor)/8) - 1:0] ), //
         .pipe_txdetectrx_loopback           (serdes_pipe_txdetectrx_loopback[lanes - 1:0]    ), //?
         .pipe_txcompliance                  (serdes_pipe_txcompliance       [lanes - 1:0]    ), //
         .pipe_txelecidle                    (serdes_pipe_txelecidle         [lanes - 1:0]    ), //
         .pipe_txdeemph                      (serdes_pipe_txdeemph           [lanes - 1:0]    ), //
         .pipe_txmargin                      (serdes_pipe_txmargin           [lanes * 3 - 1:0]  ), //
         .pipe_rate                          (serdes_pipe_rate               [lanes * 2 - 1:0]    ),
         .pipe_powerdown                     (serdes_pipe_powerdown          [lanes * 2 - 1:0]), //

         .pipe_rxdata                        (serdes_pipe_rxdata             [lanes * deser_factor - 1:0]      ), //
         .pipe_rxdatak                       (serdes_pipe_rxdatak            [((lanes * deser_factor)/8) - 1:0]), //
         .pipe_rxvalid                       (serdes_pipe_rxvalid            [lanes - 1:0]                     ), //
         .pipe_rxpolarity                    (serdes_pipe_rxpolarity         [lanes - 1:0]                     ), //
         .pipe_rxelecidle                    (serdes_pipe_rxelecidle         [lanes - 1:0]                     ), //
         .pipe_phystatus                     (serdes_pipe_phystatus          [lanes - 1:0]                     ), //
         .pipe_rxstatus                      (serdes_pipe_rxstatus           [lanes * 3 - 1:0]                 ), //

         //non-PIPE ports
         .rx_eidleinfersel                   (serdes_rx_eidleinfersel        [lanes*3  -1:0]),
         .rx_set_locktodata                  (serdes_rx_set_locktodata       [lanes-1:0]  ),
         .rx_set_locktoref                   (serdes_rx_set_locktoref        [lanes-1:0]  ),
         .tx_invpolarity                     (serdes_tx_invpolarity          [lanes-1:0]  ),
         .rx_errdetect                       (serdes_rx_errdetect            [lanes*2-1:0]),
         .rx_disperr                         (serdes_rx_disperr              [lanes*2-1:0]),
         .rx_patterndetect                   (serdes_rx_patterndetect        [lanes*2-1:0]  ),
         .rx_syncstatus                      (serdes_rx_syncstatus           [lanes*2-1:0]  ),
         .rx_phase_comp_fifo_error           (serdes_rx_phase_comp_fifo_error[lanes-1:0]  ),
         .tx_phase_comp_fifo_error           (serdes_tx_phase_comp_fifo_error[lanes-1:0]  ),
         .rx_is_lockedtoref                  (serdes_rx_is_lockedtoref       [lanes-1:0]  ),
         .rx_signaldetect                    (serdes_rx_signaldetect         [lanes-1:0]  ),
         .rx_is_lockedtodata                 (serdes_rx_is_lockedtodata      [lanes-1:0]  ),
         .pll_locked                         (serdes_pll_locked                           ),
         //.cal_blk_powerdown                  (serdes_cal_blk_powerdown                    ),

         //non-MM ports
         .rx_serial_data                     (serdes_rx_serial_data[lanes-1:0]            ),
         .tx_serial_data                     (serdes_tx_serial_data[lanes-1:0]            ),

         .pllfixedclkcentral                 (serdes_pllfixedclkcentral                   ),
         .pllfixedclkch0                     (serdes_pllfixedclkch0                       ),
         .pllfixedclkch1                     (serdes_pllfixedclkch1                       ),
         .pipe_pclk                          (serdes_pipe_pclk                            ),
         .pipe_pclkch1                       (serdes_pipe_pclkch1                         ),
         .pipe_pclkcentral                   (serdes_pipe_pclkcentral                     )
         //.cal_blk_clk                        ((pipe_mode_simu_only==1'b1)?1'b0:serdes_cal_blk_clk)
         );


////////////////////////////////////////////////////////////////////////////
// Simulation only

// synthesis translate_off

  assign pipe_mode_simu_only = pipe_mode;

  altpcie_pll_100_250 refclk_to_250mhz
    (
      .areset (1'b0),
      .c0 (clk250_out),
      .inclk0 (refclk)
    );


  altpcie_pll_125_250 pll_250mhz_to_500mhz (
      .areset (1'b0),
      .c0 (clk500_out),
      .inclk0 (clk250_out)
  );

 sim_txpipe_8bit_to_32_bit sim_txpipe_8bit_to_32_bit (
      .sim_pipe8_pclk         (pclk_in),
      .sim_pipe32_pclk        (sim_pipe32_pclk),
      .aclr                   (npor),
      .pipe_mode_simu_only    (pipe_mode_simu_only),

      .eidleinfersel0                     (eidleinfersel0          ),
      .eidleinfersel1                     (eidleinfersel1          ),
      .eidleinfersel2                     (eidleinfersel2          ),
      .eidleinfersel3                     (eidleinfersel3          ),
      .eidleinfersel4                     (eidleinfersel4          ),
      .eidleinfersel5                     (eidleinfersel5          ),
      .eidleinfersel6                     (eidleinfersel6          ),
      .eidleinfersel7                     (eidleinfersel7          ),
      .powerdown0                         (powerdown0              ),
      .powerdown1                         (powerdown1              ),
      .powerdown2                         (powerdown2              ),
      .powerdown3                         (powerdown3              ),
      .powerdown4                         (powerdown4              ),
      .powerdown5                         (powerdown5              ),
      .powerdown6                         (powerdown6              ),
      .powerdown7                         (powerdown7              ),
      .rxpolarity0                        (rxpolarity0             ),
      .rxpolarity1                        (rxpolarity1             ),
      .rxpolarity2                        (rxpolarity2             ),
      .rxpolarity3                        (rxpolarity3             ),
      .rxpolarity4                        (rxpolarity4             ),
      .rxpolarity5                        (rxpolarity5             ),
      .rxpolarity6                        (rxpolarity6             ),
      .rxpolarity7                        (rxpolarity7             ),
      .txcompl0                           (txcompl0                ),
      .txcompl1                           (txcompl1                ),
      .txcompl2                           (txcompl2                ),
      .txcompl3                           (txcompl3                ),
      .txcompl4                           (txcompl4                ),
      .txcompl5                           (txcompl5                ),
      .txcompl6                           (txcompl6                ),
      .txcompl7                           (txcompl7                ),
      .txdata0                            (txdata0                 ),
      .txdata1                            (txdata1                 ),
      .txdata2                            (txdata2                 ),
      .txdata3                            (txdata3                 ),
      .txdata4                            (txdata4                 ),
      .txdata5                            (txdata5                 ),
      .txdata6                            (txdata6                 ),
      .txdata7                            (txdata7                 ),
      .txdatak0                           (txdatak0                ),
      .txdatak1                           (txdatak1                ),
      .txdatak2                           (txdatak2                ),
      .txdatak3                           (txdatak3                ),
      .txdatak4                           (txdatak4                ),
      .txdatak5                           (txdatak5                ),
      .txdatak6                           (txdatak6                ),
      .txdatak7                           (txdatak7                ),
      //.txdatavalid0                       (txdatavalid0            ),
      //.txdatavalid1                       (txdatavalid1            ),
      //.txdatavalid2                       (txdatavalid2            ),
      //.txdatavalid3                       (txdatavalid3            ),
      //.txdatavalid4                       (txdatavalid4            ),
      //.txdatavalid5                       (txdatavalid5            ),
      //.txdatavalid6                       (txdatavalid6            ),
      //.txdatavalid7                       (txdatavalid7            ),
      .txdetectrx0                        (txdetectrx0             ),
      .txdetectrx1                        (txdetectrx1             ),
      .txdetectrx2                        (txdetectrx2             ),
      .txdetectrx3                        (txdetectrx3             ),
      .txdetectrx4                        (txdetectrx4             ),
      .txdetectrx5                        (txdetectrx5             ),
      .txdetectrx6                        (txdetectrx6             ),
      .txdetectrx7                        (txdetectrx7             ),
      .txelecidle0                        (txelecidle0             ),
      .txelecidle1                        (txelecidle1             ),
      .txelecidle2                        (txelecidle2             ),
      .txelecidle3                        (txelecidle3             ),
      .txelecidle4                        (txelecidle4             ),
      .txelecidle5                        (txelecidle5             ),
      .txelecidle6                        (txelecidle6             ),
      .txelecidle7                        (txelecidle7             ),
      .txmargin0                          (txmargin0               ),
      .txmargin1                          (txmargin1               ),
      .txmargin2                          (txmargin2               ),
      .txmargin3                          (txmargin3               ),
      .txmargin4                          (txmargin4               ),
      .txmargin5                          (txmargin5               ),
      .txmargin6                          (txmargin6               ),
      .txmargin7                          (txmargin7               ),
      .txdeemph0                          (txdeemph0               ),
      .txdeemph1                          (txdeemph1               ),
      .txdeemph2                          (txdeemph2               ),
      .txdeemph3                          (txdeemph3               ),
      .txdeemph4                          (txdeemph4               ),
      .txdeemph5                          (txdeemph5               ),
      .txdeemph6                          (txdeemph6               ),
      .txdeemph7                          (txdeemph7               ),
      .txblkst0                           (txblkst0                ),
      .txblkst1                           (txblkst1                ),
      .txblkst2                           (txblkst2                ),
      .txblkst3                           (txblkst3                ),
      .txblkst4                           (txblkst4                ),
      .txblkst5                           (txblkst5                ),
      .txblkst6                           (txblkst6                ),
      .txblkst7                           (txblkst7                ),
      .txsynchd0                          (txsynchd0               ),
      .txsynchd1                          (txsynchd1               ),
      .txsynchd2                          (txsynchd2               ),
      .txsynchd3                          (txsynchd3               ),
      .txsynchd4                          (txsynchd4               ),
      .txsynchd5                          (txsynchd5               ),
      .txsynchd6                          (txsynchd6               ),
      .txsynchd7                          (txsynchd7               ),
      .currentcoeff0                      (currentcoeff0           ),
      .currentcoeff1                      (currentcoeff1           ),
      .currentcoeff2                      (currentcoeff2           ),
      .currentcoeff3                      (currentcoeff3           ),
      .currentcoeff4                      (currentcoeff4           ),
      .currentcoeff5                      (currentcoeff5           ),
      .currentcoeff6                      (currentcoeff6           ),
      .currentcoeff7                      (currentcoeff7           ),
      .currentrxpreset0                   (currentrxpreset0        ),
      .currentrxpreset1                   (currentrxpreset1        ),
      .currentrxpreset2                   (currentrxpreset2        ),
      .currentrxpreset3                   (currentrxpreset3        ),
      .currentrxpreset4                   (currentrxpreset4        ),
      .currentrxpreset5                   (currentrxpreset5        ),
      .currentrxpreset6                   (currentrxpreset6        ),
      .currentrxpreset7                   (currentrxpreset7        ),

      .eidleinfersel0_ext                 (eidleinfersel0_ext      ),
      .eidleinfersel1_ext                 (eidleinfersel1_ext      ),
      .eidleinfersel2_ext                 (eidleinfersel2_ext      ),
      .eidleinfersel3_ext                 (eidleinfersel3_ext      ),
      .eidleinfersel4_ext                 (eidleinfersel4_ext      ),
      .eidleinfersel5_ext                 (eidleinfersel5_ext      ),
      .eidleinfersel6_ext                 (eidleinfersel6_ext      ),
      .eidleinfersel7_ext                 (eidleinfersel7_ext      ),
      .powerdown0_ext                     (powerdown0_ext          ),
      .powerdown1_ext                     (powerdown1_ext          ),
      .powerdown2_ext                     (powerdown2_ext          ),
      .powerdown3_ext                     (powerdown3_ext          ),
      .powerdown4_ext                     (powerdown4_ext          ),
      .powerdown5_ext                     (powerdown5_ext          ),
      .powerdown6_ext                     (powerdown6_ext          ),
      .powerdown7_ext                     (powerdown7_ext          ),
      .rxpolarity0_ext                    (rxpolarity0_ext         ),
      .rxpolarity1_ext                    (rxpolarity1_ext         ),
      .rxpolarity2_ext                    (rxpolarity2_ext         ),
      .rxpolarity3_ext                    (rxpolarity3_ext         ),
      .rxpolarity4_ext                    (rxpolarity4_ext         ),
      .rxpolarity5_ext                    (rxpolarity5_ext         ),
      .rxpolarity6_ext                    (rxpolarity6_ext         ),
      .rxpolarity7_ext                    (rxpolarity7_ext         ),
      .txcompl0_ext                       (txcompl0_ext            ),
      .txcompl1_ext                       (txcompl1_ext            ),
      .txcompl2_ext                       (txcompl2_ext            ),
      .txcompl3_ext                       (txcompl3_ext            ),
      .txcompl4_ext                       (txcompl4_ext            ),
      .txcompl5_ext                       (txcompl5_ext            ),
      .txcompl6_ext                       (txcompl6_ext            ),
      .txcompl7_ext                       (txcompl7_ext            ),
      .txdata0_ext                        (txdata0_ext             ),
      .txdata1_ext                        (txdata1_ext             ),
      .txdata2_ext                        (txdata2_ext             ),
      .txdata3_ext                        (txdata3_ext             ),
      .txdata4_ext                        (txdata4_ext             ),
      .txdata5_ext                        (txdata5_ext             ),
      .txdata6_ext                        (txdata6_ext             ),
      .txdata7_ext                        (txdata7_ext             ),
      .txdatak0_ext                       (txdatak0_ext            ),
      .txdatak1_ext                       (txdatak1_ext            ),
      .txdatak2_ext                       (txdatak2_ext            ),
      .txdatak3_ext                       (txdatak3_ext            ),
      .txdatak4_ext                       (txdatak4_ext            ),
      .txdatak5_ext                       (txdatak5_ext            ),
      .txdatak6_ext                       (txdatak6_ext            ),
      .txdatak7_ext                       (txdatak7_ext            ),
      //.txdatavalid0_ext                   (txdatavalid0_ext        ),
      //.txdatavalid1_ext                   (txdatavalid1_ext        ),
      //.txdatavalid2_ext                   (txdatavalid2_ext        ),
      //.txdatavalid3_ext                   (txdatavalid3_ext        ),
      //.txdatavalid4_ext                   (txdatavalid4_ext        ),
      //.txdatavalid5_ext                   (txdatavalid5_ext        ),
      //.txdatavalid6_ext                   (txdatavalid6_ext        ),
      //.txdatavalid7_ext                   (txdatavalid7_ext        ),
      .txdetectrx0_ext                    (txdetectrx0_ext         ),
      .txdetectrx1_ext                    (txdetectrx1_ext         ),
      .txdetectrx2_ext                    (txdetectrx2_ext         ),
      .txdetectrx3_ext                    (txdetectrx3_ext         ),
      .txdetectrx4_ext                    (txdetectrx4_ext         ),
      .txdetectrx5_ext                    (txdetectrx5_ext         ),
      .txdetectrx6_ext                    (txdetectrx6_ext         ),
      .txdetectrx7_ext                    (txdetectrx7_ext         ),
      .txelecidle0_ext                    (txelecidle0_ext         ),
      .txelecidle1_ext                    (txelecidle1_ext         ),
      .txelecidle2_ext                    (txelecidle2_ext         ),
      .txelecidle3_ext                    (txelecidle3_ext         ),
      .txelecidle4_ext                    (txelecidle4_ext         ),
      .txelecidle5_ext                    (txelecidle5_ext         ),
      .txelecidle6_ext                    (txelecidle6_ext         ),
      .txelecidle7_ext                    (txelecidle7_ext         ),
      .txmargin0_ext                      (txmargin0_ext           ),
      .txmargin1_ext                      (txmargin1_ext           ),
      .txmargin2_ext                      (txmargin2_ext           ),
      .txmargin3_ext                      (txmargin3_ext           ),
      .txmargin4_ext                      (txmargin4_ext           ),
      .txmargin5_ext                      (txmargin5_ext           ),
      .txmargin6_ext                      (txmargin6_ext           ),
      .txmargin7_ext                      (txmargin7_ext           ),
      .txdeemph0_ext                      (txdeemph0_ext           ),
      .txdeemph1_ext                      (txdeemph1_ext           ),
      .txdeemph2_ext                      (txdeemph2_ext           ),
      .txdeemph3_ext                      (txdeemph3_ext           ),
      .txdeemph4_ext                      (txdeemph4_ext           ),
      .txdeemph5_ext                      (txdeemph5_ext           ),
      .txdeemph6_ext                      (txdeemph6_ext           ),
      .txdeemph7_ext                      (txdeemph7_ext           ),
      .txblkst0_ext                       (txblkst0_ext            ),
      .txblkst1_ext                       (txblkst1_ext            ),
      .txblkst2_ext                       (txblkst2_ext            ),
      .txblkst3_ext                       (txblkst3_ext            ),
      .txblkst4_ext                       (txblkst4_ext            ),
      .txblkst5_ext                       (txblkst5_ext            ),
      .txblkst6_ext                       (txblkst6_ext            ),
      .txblkst7_ext                       (txblkst7_ext            ),
      .txsynchd0_ext                      (txsynchd0_ext           ),
      .txsynchd1_ext                      (txsynchd1_ext           ),
      .txsynchd2_ext                      (txsynchd2_ext           ),
      .txsynchd3_ext                      (txsynchd3_ext           ),
      .txsynchd4_ext                      (txsynchd4_ext           ),
      .txsynchd5_ext                      (txsynchd5_ext           ),
      .txsynchd6_ext                      (txsynchd6_ext           ),
      .txsynchd7_ext                      (txsynchd7_ext           ),
      .currentcoeff0_ext                  (currentcoeff0_ext       ),
      .currentcoeff1_ext                  (currentcoeff1_ext       ),
      .currentcoeff2_ext                  (currentcoeff2_ext       ),
      .currentcoeff3_ext                  (currentcoeff3_ext       ),
      .currentcoeff4_ext                  (currentcoeff4_ext       ),
      .currentcoeff5_ext                  (currentcoeff5_ext       ),
      .currentcoeff6_ext                  (currentcoeff6_ext       ),
      .currentcoeff7_ext                  (currentcoeff7_ext       ),
      .currentrxpreset0_ext               (currentrxpreset0_ext    ),
      .currentrxpreset1_ext               (currentrxpreset1_ext    ),
      .currentrxpreset2_ext               (currentrxpreset2_ext    ),
      .currentrxpreset3_ext               (currentrxpreset3_ext    ),
      .currentrxpreset4_ext               (currentrxpreset4_ext    ),
      .currentrxpreset5_ext               (currentrxpreset5_ext    ),
      .currentrxpreset6_ext               (currentrxpreset6_ext    ),
      .currentrxpreset7_ext               (currentrxpreset7_ext    )

      );


   sim_rxpipe_8bit_to_32_bit sim_rxpipe_8bit_to_32_bit (
      // Input PIPE simulation _ext for simulation only
      .sim_pipe8_pclk                  (pclk_in),
      .aclr                            (npor),

      .phystatus0_ext                   (phystatus0_ext                   ),
      .phystatus1_ext                   (phystatus1_ext                   ),
      .phystatus2_ext                   (phystatus2_ext                   ),
      .phystatus3_ext                   (phystatus3_ext                   ),
      .phystatus4_ext                   (phystatus4_ext                   ),
      .phystatus5_ext                   (phystatus5_ext                   ),
      .phystatus6_ext                   (phystatus6_ext                   ),
      .phystatus7_ext                   (phystatus7_ext                   ),
      .rxdata0_ext                      (rxdata0_ext                      ),
      .rxdata1_ext                      (rxdata1_ext                      ),
      .rxdata2_ext                      (rxdata2_ext                      ),
      .rxdata3_ext                      (rxdata3_ext                      ),
      .rxdata4_ext                      (rxdata4_ext                      ),
      .rxdata5_ext                      (rxdata5_ext                      ),
      .rxdata6_ext                      (rxdata6_ext                      ),
      .rxdata7_ext                      (rxdata7_ext                      ),
      .rxdatak0_ext                     (rxdatak0_ext                     ),
      .rxdatak1_ext                     (rxdatak1_ext                     ),
      .rxdatak2_ext                     (rxdatak2_ext                     ),
      .rxdatak3_ext                     (rxdatak3_ext                     ),
      .rxdatak4_ext                     (rxdatak4_ext                     ),
      .rxdatak5_ext                     (rxdatak5_ext                     ),
      .rxdatak6_ext                     (rxdatak6_ext                     ),
      .rxdatak7_ext                     (rxdatak7_ext                     ),
      .rxelecidle0_ext                  (rxelecidle0_ext                  ),
      .rxelecidle1_ext                  (rxelecidle1_ext                  ),
      .rxelecidle2_ext                  (rxelecidle2_ext                  ),
      .rxelecidle3_ext                  (rxelecidle3_ext                  ),
      .rxelecidle4_ext                  (rxelecidle4_ext                  ),
      .rxelecidle5_ext                  (rxelecidle5_ext                  ),
      .rxelecidle6_ext                  (rxelecidle6_ext                  ),
      .rxelecidle7_ext                  (rxelecidle7_ext                  ),
      .rxfreqlocked0_ext                (rxfreqlocked0_ext                ),
      .rxfreqlocked1_ext                (rxfreqlocked1_ext                ),
      .rxfreqlocked2_ext                (rxfreqlocked2_ext                ),
      .rxfreqlocked3_ext                (rxfreqlocked3_ext                ),
      .rxfreqlocked4_ext                (rxfreqlocked4_ext                ),
      .rxfreqlocked5_ext                (rxfreqlocked5_ext                ),
      .rxfreqlocked6_ext                (rxfreqlocked6_ext                ),
      .rxfreqlocked7_ext                (rxfreqlocked7_ext                ),
      .rxstatus0_ext                    (rxstatus0_ext                    ),
      .rxstatus1_ext                    (rxstatus1_ext                    ),
      .rxstatus2_ext                    (rxstatus2_ext                    ),
      .rxstatus3_ext                    (rxstatus3_ext                    ),
      .rxstatus4_ext                    (rxstatus4_ext                    ),
      .rxstatus5_ext                    (rxstatus5_ext                    ),
      .rxstatus6_ext                    (rxstatus6_ext                    ),
      .rxstatus7_ext                    (rxstatus7_ext                    ),
      .rxdataskip0_ext                  (rxdataskip0_ext                  ),
      .rxdataskip1_ext                  (rxdataskip1_ext                  ),
      .rxdataskip2_ext                  (rxdataskip2_ext                  ),
      .rxdataskip3_ext                  (rxdataskip3_ext                  ),
      .rxdataskip4_ext                  (rxdataskip4_ext                  ),
      .rxdataskip5_ext                  (rxdataskip5_ext                  ),
      .rxdataskip6_ext                  (rxdataskip6_ext                  ),
      .rxdataskip7_ext                  (rxdataskip7_ext                  ),
      .rxblkst0_ext                     (rxblkst0_ext                     ),
      .rxblkst1_ext                     (rxblkst1_ext                     ),
      .rxblkst2_ext                     (rxblkst2_ext                     ),
      .rxblkst3_ext                     (rxblkst3_ext                     ),
      .rxblkst4_ext                     (rxblkst4_ext                     ),
      .rxblkst5_ext                     (rxblkst5_ext                     ),
      .rxblkst6_ext                     (rxblkst6_ext                     ),
      .rxblkst7_ext                     (rxblkst7_ext                     ),
      .rxsynchd0_ext                    (rxsynchd0_ext                    ),
      .rxsynchd1_ext                    (rxsynchd1_ext                    ),
      .rxsynchd2_ext                    (rxsynchd2_ext                    ),
      .rxsynchd3_ext                    (rxsynchd3_ext                    ),
      .rxsynchd4_ext                    (rxsynchd4_ext                    ),
      .rxsynchd5_ext                    (rxsynchd5_ext                    ),
      .rxsynchd6_ext                    (rxsynchd6_ext                    ),
      .rxsynchd7_ext                    (rxsynchd7_ext                    ),
      .rxvalid0_ext                     (rxvalid0_ext                     ),
      .rxvalid1_ext                     (rxvalid1_ext                     ),
      .rxvalid2_ext                     (rxvalid2_ext                     ),
      .rxvalid3_ext                     (rxvalid3_ext                     ),
      .rxvalid4_ext                     (rxvalid4_ext                     ),
      .rxvalid5_ext                     (rxvalid5_ext                     ),
      .rxvalid6_ext                     (rxvalid6_ext                     ),
      .rxvalid7_ext                     (rxvalid7_ext                     ),

      .sim_pipe32_pclk                  (sim_pipe32_pclk                  ),
      .phystatus0_ext32b                (phystatus0_ext32b                ),
      .phystatus1_ext32b                (phystatus1_ext32b                ),
      .phystatus2_ext32b                (phystatus2_ext32b                ),
      .phystatus3_ext32b                (phystatus3_ext32b                ),
      .phystatus4_ext32b                (phystatus4_ext32b                ),
      .phystatus5_ext32b                (phystatus5_ext32b                ),
      .phystatus6_ext32b                (phystatus6_ext32b                ),
      .phystatus7_ext32b                (phystatus7_ext32b                ),
      .rxdata0_ext32b                   (rxdata0_ext32b                   ),
      .rxdata1_ext32b                   (rxdata1_ext32b                   ),
      .rxdata2_ext32b                   (rxdata2_ext32b                   ),
      .rxdata3_ext32b                   (rxdata3_ext32b                   ),
      .rxdata4_ext32b                   (rxdata4_ext32b                   ),
      .rxdata5_ext32b                   (rxdata5_ext32b                   ),
      .rxdata6_ext32b                   (rxdata6_ext32b                   ),
      .rxdata7_ext32b                   (rxdata7_ext32b                   ),
      .rxdatak0_ext32b                  (rxdatak0_ext32b                  ),
      .rxdatak1_ext32b                  (rxdatak1_ext32b                  ),
      .rxdatak2_ext32b                  (rxdatak2_ext32b                  ),
      .rxdatak3_ext32b                  (rxdatak3_ext32b                  ),
      .rxdatak4_ext32b                  (rxdatak4_ext32b                  ),
      .rxdatak5_ext32b                  (rxdatak5_ext32b                  ),
      .rxdatak6_ext32b                  (rxdatak6_ext32b                  ),
      .rxdatak7_ext32b                  (rxdatak7_ext32b                  ),
      .rxelecidle0_ext32b               (rxelecidle0_ext32b               ),
      .rxelecidle1_ext32b               (rxelecidle1_ext32b               ),
      .rxelecidle2_ext32b               (rxelecidle2_ext32b               ),
      .rxelecidle3_ext32b               (rxelecidle3_ext32b               ),
      .rxelecidle4_ext32b               (rxelecidle4_ext32b               ),
      .rxelecidle5_ext32b               (rxelecidle5_ext32b               ),
      .rxelecidle6_ext32b               (rxelecidle6_ext32b               ),
      .rxelecidle7_ext32b               (rxelecidle7_ext32b               ),
      .rxfreqlocked0_ext32b             (rxfreqlocked0_ext32b             ),
      .rxfreqlocked1_ext32b             (rxfreqlocked1_ext32b             ),
      .rxfreqlocked2_ext32b             (rxfreqlocked2_ext32b             ),
      .rxfreqlocked3_ext32b             (rxfreqlocked3_ext32b             ),
      .rxfreqlocked4_ext32b             (rxfreqlocked4_ext32b             ),
      .rxfreqlocked5_ext32b             (rxfreqlocked5_ext32b             ),
      .rxfreqlocked6_ext32b             (rxfreqlocked6_ext32b             ),
      .rxfreqlocked7_ext32b             (rxfreqlocked7_ext32b             ),
      .rxstatus0_ext32b                 (rxstatus0_ext32b                 ),
      .rxstatus1_ext32b                 (rxstatus1_ext32b                 ),
      .rxstatus2_ext32b                 (rxstatus2_ext32b                 ),
      .rxstatus3_ext32b                 (rxstatus3_ext32b                 ),
      .rxstatus4_ext32b                 (rxstatus4_ext32b                 ),
      .rxstatus5_ext32b                 (rxstatus5_ext32b                 ),
      .rxstatus6_ext32b                 (rxstatus6_ext32b                 ),
      .rxstatus7_ext32b                 (rxstatus7_ext32b                 ),
      .rxdataskip0_ext32b               (rxdataskip0_ext32b               ),
      .rxdataskip1_ext32b               (rxdataskip1_ext32b               ),
      .rxdataskip2_ext32b               (rxdataskip2_ext32b               ),
      .rxdataskip3_ext32b               (rxdataskip3_ext32b               ),
      .rxdataskip4_ext32b               (rxdataskip4_ext32b               ),
      .rxdataskip5_ext32b               (rxdataskip5_ext32b               ),
      .rxdataskip6_ext32b               (rxdataskip6_ext32b               ),
      .rxdataskip7_ext32b               (rxdataskip7_ext32b               ),
      .rxblkst0_ext32b                  (rxblkst0_ext32b                  ),
      .rxblkst1_ext32b                  (rxblkst1_ext32b                  ),
      .rxblkst2_ext32b                  (rxblkst2_ext32b                  ),
      .rxblkst3_ext32b                  (rxblkst3_ext32b                  ),
      .rxblkst4_ext32b                  (rxblkst4_ext32b                  ),
      .rxblkst5_ext32b                  (rxblkst5_ext32b                  ),
      .rxblkst6_ext32b                  (rxblkst6_ext32b                  ),
      .rxblkst7_ext32b                  (rxblkst7_ext32b                  ),
      .rxsynchd0_ext32b                 (rxsynchd0_ext32b                 ),
      .rxsynchd1_ext32b                 (rxsynchd1_ext32b                 ),
      .rxsynchd2_ext32b                 (rxsynchd2_ext32b                 ),
      .rxsynchd3_ext32b                 (rxsynchd3_ext32b                 ),
      .rxsynchd4_ext32b                 (rxsynchd4_ext32b                 ),
      .rxsynchd5_ext32b                 (rxsynchd5_ext32b                 ),
      .rxsynchd6_ext32b                 (rxsynchd6_ext32b                 ),
      .rxsynchd7_ext32b                 (rxsynchd7_ext32b                 ),
      .rxvalid0_ext32b                  (rxvalid0_ext32b                  ),
      .rxvalid1_ext32b                  (rxvalid1_ext32b                  ),
      .rxvalid2_ext32b                  (rxvalid2_ext32b                  ),
      .rxvalid3_ext32b                  (rxvalid3_ext32b                  ),
      .rxvalid4_ext32b                  (rxvalid4_ext32b                  ),
      .rxvalid5_ext32b                  (rxvalid5_ext32b                  ),
      .rxvalid6_ext32b                  (rxvalid6_ext32b                  ),
      .rxvalid7_ext32b                  (rxvalid7_ext32b                  )
      );

// synthesis translate_on


endmodule


// synthesis VERILOG_INPUT_VERSION VERILOG_2001
//////////////////////////////////////////////////////////////////////////////////////////////
//
// Ve// rilog file generated by X-HDL - Revision 3.2.54  Aug. 8         <=; 2005
// Fri Nov  4 10:07:57 2005
//
//      Input file         : D:/cvs_build/projects/pci_express_r1/altera/src/vhdl/top/alt4gxb_reset_controller.vhd
//      Design name        : alt4gxb_reset_controller
//      Author             :
//      Company            :
//
//      Description        :
//
//
//////////////////////////////////////////////////////////////////////////////////////////////
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//      Logic Core:  PCI Express Megacore Function
//         Company:  Altera Corporation.
//                       www.altera.com
//          Author:  IPBU SIO Group
//
//     Description:  Altera PCI Express MegaCore Reset controller for Alt2gxb
//
// Copyright (c) 2005 Altera Corporation. All rights reserved.  This source code
// is highly confidential and proprietary information of Altera and is being
// provided in accordance with and subject to the protections of a
// Non-Disclosure Agreement which governs its use and disclosure.  Altera
// products and services are protected under numerous U.S. and foreign patents,
// maskwork rights, copyrights and other intellectual property laws.  Altera
// assumes no responsibility or liability arising out of the application or use
// of this source code.
//
// For Best Viewing Set tab stops to 4 spaces.
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Reset Controller for the ALT2GXB
//
//
module alt5gxb_reset_controller
  (input inclk,
   input async_reset,
   input test_sim,
   input pll_locked,
   input rx_pll_locked,
   input fifo_err,
   input inclk_eq_125mhz,
   output gxb_powerdown,
   output txdigitalreset,
   output rxanalogreset,
   output rxdigitalreset
) ;

   localparam [19:0] WS_SIM = 20'h00020;
   localparam [19:0] WS_1MS_10000 = 20'h186a0;
   localparam [19:0] WS_1MS_12500 = 20'h1e848;
   localparam [19:0] WS_1MS_15625 = 20'h2625a;
   localparam [19:0] WS_1MS_25000 = 20'h3d090;
   localparam [1:0] idle = 0;
   localparam [1:0] strobe_txpll_locked = 1;
   localparam [1:0] stable_tx_pll = 2;
   localparam [1:0] wait_state = 3;
// Suppressing R102 here because gxb_powredown takes out the whole alt2gxb and no clock
// will be running
   reg  [1:0] rst_ctrl_sm /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
   reg [19:0] waitstate_timer /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;

   reg txdigitalreset_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
   reg rxanalogreset_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
   reg rxdigitalreset_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
   reg ws_tmr_eq_0 /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
   reg ld_ws_tmr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
   reg ld_ws_tmr_short /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
reg    [2:0] rx_pll_locked_cnt /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;
reg        rx_pll_locked_r /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL =R102" */ ;

   assign gxb_powerdown  = async_reset ;
   assign txdigitalreset = txdigitalreset_r ;
   assign rxanalogreset  = rxanalogreset_r ;
   assign rxdigitalreset = rxdigitalreset_r ;

   always @(posedge inclk or posedge async_reset)
   begin
      if (async_reset == 1'b1)
      begin
         txdigitalreset_r <= 1'b1 ;
         rxanalogreset_r  <= 1'b1 ;
         rxdigitalreset_r <= 1'b1 ;
         waitstate_timer  <= 20'hFFFFF ;
         rst_ctrl_sm      <= strobe_txpll_locked ;
         ws_tmr_eq_0      <= 1'b0 ;
         ld_ws_tmr        <= 1'b1 ;
         ld_ws_tmr_short  <= 1'b0 ;
      rx_pll_locked_cnt <= 3'h0;
      rx_pll_locked_r <= 1'b0;
      end
      else
   begin
   // add hysterisis for losing lock
   if (rx_pll_locked == 1'b1)
     rx_pll_locked_cnt <= 3'h7;
   else if (rx_pll_locked_cnt == 3'h0)
     rx_pll_locked_cnt <= 3'h0;
   else if (rx_pll_locked == 1'b0)
     rx_pll_locked_cnt <= rx_pll_locked_cnt - 1;

   rx_pll_locked_r <= (rx_pll_locked_cnt != 3'h0);

         if (ld_ws_tmr == 1'b1)
         begin
            if (test_sim == 1'b1)
            begin
               waitstate_timer <= WS_SIM ;
            end
            else if (inclk_eq_125mhz == 1'b1)
         begin
              waitstate_timer <= WS_1MS_12500 ;
         end
       else
              begin
              waitstate_timer <= WS_1MS_25000 ;
              end
         end
         else if (ld_ws_tmr_short == 1'b1)
      waitstate_timer <= WS_SIM ;
         else if (waitstate_timer != 20'h00000)
         begin
            waitstate_timer <= waitstate_timer - 1 ;
         end
         if (ld_ws_tmr == 1'b1 | ld_ws_tmr_short)
         begin
            ws_tmr_eq_0 <= 1'b0 ;
         end
         else if (waitstate_timer == 20'h00000)
         begin
            ws_tmr_eq_0 <= 1'b1 ;
         end
         else
         begin
            ws_tmr_eq_0 <= 1'b0 ;
         end
         case (rst_ctrl_sm)
            idle :
                     begin
                        if (rx_pll_locked_r == 1'b1)
                          begin
           if (fifo_err == 1'b1)
                            rst_ctrl_sm <= stable_tx_pll ;
           else
                           rst_ctrl_sm <= idle ;
                          end
                        else
                        begin
                           rst_ctrl_sm <= strobe_txpll_locked ;
                           ld_ws_tmr   <= 1'b1 ;
                        end
                     end
            strobe_txpll_locked :
                     begin
                        ld_ws_tmr <= 1'b0 ;
                        if (pll_locked == 1'b1 & ws_tmr_eq_0 == 1'b1)
                        begin
                           rst_ctrl_sm      <= stable_tx_pll ;
                           txdigitalreset_r <= 1'b0 ;
                           rxanalogreset_r  <= 1'b0 ;
                           rxdigitalreset_r <= 1'b1 ;
                        end
                        else
                        begin
                           rst_ctrl_sm      <= strobe_txpll_locked ;
                           txdigitalreset_r <= 1'b1 ;
                           rxanalogreset_r  <= 1'b1 ;
                           rxdigitalreset_r <= 1'b1 ;
                        end
                     end
            stable_tx_pll :
                     begin
                        if (rx_pll_locked_r == 1'b1)
                        begin
                           rst_ctrl_sm      <= wait_state ;
                           txdigitalreset_r <= 1'b0 ;
                           rxanalogreset_r  <= 1'b0 ;
                           rxdigitalreset_r <= 1'b1 ;
                           ld_ws_tmr_short  <= 1'b1 ;
                        end
                        else
                        begin
                           rst_ctrl_sm      <= stable_tx_pll ;
                           txdigitalreset_r <= 1'b0 ;
                           rxanalogreset_r  <= 1'b0 ;
                           rxdigitalreset_r <= 1'b1 ;
                        end
                     end
            wait_state :
                     begin
                        if (rx_pll_locked_r == 1'b1)
                        begin
                           ld_ws_tmr_short <= 1'b0 ;
                           if (ld_ws_tmr_short == 1'b0 & ws_tmr_eq_0 == 1'b1)
                           begin
                              rst_ctrl_sm      <= idle ;
                              txdigitalreset_r <= 1'b0 ;
                              rxanalogreset_r  <= 1'b0 ;
                              rxdigitalreset_r <= 1'b0 ;
                           end
                           else
                           begin
                              rst_ctrl_sm      <= wait_state ;
                              txdigitalreset_r <= 1'b0 ;
                              rxanalogreset_r  <= 1'b0 ;
                              rxdigitalreset_r <= 1'b1 ;
                           end
                        end
                        else
                        begin
                           rst_ctrl_sm      <= stable_tx_pll ;
                           txdigitalreset_r <= 1'b0 ;
                           rxanalogreset_r  <= 1'b0 ;
                           rxdigitalreset_r <= 1'b1 ;
                        end
                     end
            default :
                     begin
                        rst_ctrl_sm     <= idle ;
                        waitstate_timer <= 20'hFFFFF ;
                     end
         endcase
      end
   end
endmodule




// synthesis translate_off
`timescale 1ns / 1ps
// For Mentor cosim
`ifdef ALTPCIETB_COSIM_MENTOR

module global (in, out);
    input in;
    output out;

    assign out = in;
endmodule

`endif
// synthesis translate_on

