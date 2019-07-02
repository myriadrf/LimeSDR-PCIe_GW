LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
USE altera_mf.altera_mf_components.all;

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
-- synthesis translate_off
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_cdma_ast_tx.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module construct of the Avalon Streaming transmit port for the
-- chaining DMA application DATA/Descriptor signals.
-------------------------------------------------------------------------------
-- Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
-- protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
-- other intellectual property laws.
--
-- This reference design file, and your use thereof, is subject to and governed by
-- the terms and conditions of the applicable Altera Reference Design License Agreement.
-- By using this reference design file, you indicate your acceptance of such terms and
-- conditions between you and Altera Corporation.  In the event that you do not agree with
-- such terms and conditions, you may not use the reference design file. Please promptly
-- destroy any copies you have made.
--
-- This reference design file being provided on an "as-is" basis and as an accommodation
-- and therefore all warranties, representations or guarantees of any kind
-- (whether express, implied or statutory) including, without limitation, warranties of
-- merchantability, non-infringement, or fitness for a particular purpose, are
-- specifically disclaimed.  By making this reference design file available, Altera
-- expressly does not recommend, suggest or require that this reference design file be
-- used in combination with any other product not provided by Altera.
-------------------------------------------------------------------------------


ENTITY altpcierd_cdma_ast_tx_128 IS
   GENERIC (
      ECRC_FORWARD_GENER  : INTEGER := 0
   );
   PORT (
      clk_in              : IN STD_LOGIC;
      srst                : IN STD_LOGIC;
      tx_stream_ready0    : IN STD_LOGIC;
      txdata              : OUT STD_LOGIC_VECTOR(132 DOWNTO 0);
      tx_stream_valid0    : OUT STD_LOGIC;
      tx_req0             : IN STD_LOGIC;
      tx_ack0             : OUT STD_LOGIC;
      tx_desc0            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_ws0              : OUT STD_LOGIC;
      tx_err0             : IN STD_LOGIC;
      tx_dv0              : IN STD_LOGIC;
      tx_dfr0             : IN STD_LOGIC;
      tx_data0            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_fifo_empty       : OUT STD_LOGIC
   );
END ENTITY altpcierd_cdma_ast_tx_128;

ARCHITECTURE trans OF altpcierd_cdma_ast_tx_128 IS




   FUNCTION to_stdlogic (
   val      : IN integer) RETURN std_logic IS
   BEGIN
      IF (val=1) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;
   FUNCTION to_stdlogic (
   val      : IN boolean) RETURN std_logic IS
   BEGIN
      IF (val) THEN
         RETURN('1');
      ELSE
         RETURN('0');
      END IF;
   END to_stdlogic;


   FUNCTION TO_STDLOGICVECTOR (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS

      VARIABLE rtn : std_logic_vector(len-1 DOWNTO 0):=(OTHERS => '0');
      VARIABLE num : integer := val;
      VARIABLE r   : integer;
   BEGIN
      FOR index IN 0 TO len-1 LOOP
         r := num rem 2;
         num := num/2;
         IF (r = 1) THEN
            rtn(index) := '1';
         ELSE
            rtn(index) := '0';
         END IF;
      END LOOP;
      RETURN(rtn);
   END TO_STDLOGICVECTOR;


   CONSTANT       TXFIFO_WIDTH        : INTEGER := 133;
   CONSTANT       TXFIFO_DEPTH        : INTEGER := 64;
   CONSTANT       ZERO_INTEGER        : INTEGER := 0;
   CONSTANT       ONE_INTEGER         : INTEGER := 1;
   CONSTANT       TXFIFO_ALMOST_FULLP : INTEGER := 32;
   CONSTANT       TXFIFO_WIDTHU       : INTEGER := 6;

COMPONENT altpcierd_cdma_ecrc_gen IS
   GENERIC (
      AVALON_ST_128       : INTEGER;
      XHDL_STR            : STRING
   );
   PORT (
      clk                 : IN STD_LOGIC;
      rstn                : IN STD_LOGIC;
      user_rd_req         : OUT STD_LOGIC;
      user_sop            : IN STD_LOGIC;
      user_eop            : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      user_data           : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      user_valid          : IN STD_LOGIC;
      tx_stream_ready0    : IN STD_LOGIC;
      tx_stream_data0_0   : OUT STD_LOGIC_VECTOR(75 DOWNTO 0);
      tx_stream_data0_1   : OUT STD_LOGIC_VECTOR(75 DOWNTO 0);
      tx_stream_valid0    : OUT STD_LOGIC
   );
END COMPONENT;


   SIGNAL txdata_int                       : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txdata_ecrc                      : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txfifo_rdreq_int                 : STD_LOGIC;
   SIGNAL txfifo_rdreq_ecrc                : STD_LOGIC;
   SIGNAL tx_stream_valid0_int             : STD_LOGIC;
   SIGNAL tx_stream_valid0_ecrc            : STD_LOGIC;
   SIGNAL tx_req_p0                        : STD_LOGIC;
   SIGNAL tx_req_next                      : STD_LOGIC;
   SIGNAL tx_req_p1                        : STD_LOGIC;
   SIGNAL tx_data_reg                      : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL txdata_with_payload              : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL ctrltx_address                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL ctrltx_address_n                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_err                           : STD_LOGIC;
   SIGNAL tx_sop_0                         : STD_LOGIC;
   SIGNAL tx_empty                         : STD_LOGIC;
   SIGNAL tx_empty_0                       : STD_LOGIC;
   SIGNAL tx_sop_1                         : STD_LOGIC;
   SIGNAL tx_eop_1                         : STD_LOGIC;
   SIGNAL tx_eop_3dwh_1dwp_nonaligned      : STD_LOGIC;
   SIGNAL tx_eop_ndword                    : STD_LOGIC;
   SIGNAL txfifo_d                         : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txfifo_wrreq                     : STD_LOGIC;
   SIGNAL txfifo_q                         : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txfifoq_r_eop1                    : STD_LOGIC;
   SIGNAL txfifo_empty                     : STD_LOGIC;
   SIGNAL txfifo_full                      : STD_LOGIC;
   SIGNAL txfifo_almost_full               : STD_LOGIC;
   SIGNAL txfifo_rdreq                     : STD_LOGIC;
   SIGNAL txfifo_usedw                     : STD_LOGIC_VECTOR(TXFIFO_WIDTHU - 1 DOWNTO 0);

   SIGNAL txfifo_wrreq_with_payload        : STD_LOGIC;
   SIGNAL ctrltx_nopayload                 : STD_LOGIC;
   SIGNAL ctrltx_nopayload_reg             : STD_LOGIC;
   SIGNAL ctrltx_3dw                       : STD_LOGIC;
   SIGNAL ctrltx_3dw_reg                   : STD_LOGIC;
   SIGNAL ctrltx_qword_aligned             : STD_LOGIC;
   SIGNAL ctrltx_qword_aligned_reg         : STD_LOGIC;
   SIGNAL ctrltx_tx_length                 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrltx_tx_length_reg             : STD_LOGIC_VECTOR(9 DOWNTO 0);

   SIGNAL ctrltx_nopayload_r2              : STD_LOGIC;
   SIGNAL ctrltx_3dw_r2                    : STD_LOGIC;
   SIGNAL ctrltx_qword_aligned_r2          : STD_LOGIC;
   SIGNAL ctrltx_tx_length_r2              : STD_LOGIC_VECTOR(1 DOWNTO 0);

   -- ECRC
   SIGNAL user_sop                         : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL user_eop                         : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL user_data                        : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL user_rd_req                      : STD_LOGIC;
   SIGNAL user_valid                       : STD_LOGIC;
   SIGNAL ecrc_stream_data0_0              : STD_LOGIC_VECTOR(75 DOWNTO 0);
   SIGNAL ecrc_stream_data0_1              : STD_LOGIC_VECTOR(75 DOWNTO 0);

   SIGNAL txfifo_q_pipe                 : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL output_stage_full             : STD_LOGIC;

   SIGNAL tx_req_int                       : STD_LOGIC;
   SIGNAL tx_stream_data_dw_count          : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL tx_stream_data_dw_count_reg      : STD_LOGIC_VECTOR(10 DOWNTO 0);

   SIGNAL txfifo_wrreq_n                   : STD_LOGIC;
   SIGNAL tx_stream_data_dw_count_gt_4     : STD_LOGIC;
   SIGNAL tx_stream_data_dw_count_gt_4_reg : STD_LOGIC;
   SIGNAL tx_stream_data_dw_count_gt_4_n   : STD_LOGIC;

   -- xhdl
   SIGNAL zeros_32                         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL zero                             : STD_LOGIC;
   SIGNAL ctrltx_tx_length_ext             : STD_LOGIC_VECTOR(10 DOWNTO 0);
   -- X-HDL generated signals

   SIGNAL xhdl2 : STD_LOGIC;
   SIGNAL xhdl3 : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL xhdl4 : STD_LOGIC;
   SIGNAL xhdl5 : STD_LOGIC;
   SIGNAL xhdl6 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl7 : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL xhdl8 : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_ack0_xhdl0                    : STD_LOGIC;
   SIGNAL tx_ws0_xhdl1                     : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   tx_ack0 <= tx_ack0_xhdl0;
   tx_ws0 <= tx_ws0_xhdl1;
   zeros_32 <= "00000000000000000000000000000000";
   zero <= '0';
   ctrltx_tx_length_ext <= (zero & ctrltx_tx_length);

   tx_fifo_empty <= txfifo_empty;
   tx_ack0_xhdl0 <= tx_req_int WHEN (tx_ws0_xhdl1 = '0') ELSE
                    '0';

   --tx_ws0     <=((txfifo_usedw>TXFIFO_ALMOST_EMPTY) && (txfifo_empty==1'b0)) ? 1'b1 : 1'b0;
   xhdl2 <= '1' WHEN (txfifo_almost_full = '1') ELSE
                    '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_req_int <= '0';
            tx_ws0_xhdl1 <= '0';
         ELSE

            tx_ws0_xhdl1 <= xhdl2;
            IF (tx_ack0_xhdl0 = '1') THEN
               tx_req_int <= '0';
            ELSE
               tx_req_int <= tx_req0;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   --////////////////////////////////////////////////////////////////////
   -- tx_fifo



  tx_empty_0 <= tx_empty when (txfifo_d(131) = '0') else '0';

   -- RX push TAGs into TAG_FIFO
   xhdl3 <= (txfifo_d(132 DOWNTO 131) & tx_empty_0 & txfifo_d(129 DOWNTO 0));
   tx_data_fifo_128 : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => TXFIFO_DEPTH,
         almost_full_value        => TXFIFO_ALMOST_FULLP,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => TXFIFO_WIDTH,
         lpm_widthu               => TXFIFO_WIDTHU,
         overflow_checking        => "ON",
         underflow_checking       => "ON",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => srst,

         -- RX push TAGs into TAG_FIFO
         data   => xhdl3,
         wrreq  => txfifo_wrreq,

         -- TX pop TAGs from TAG_FIFO
         rdreq  => txfifo_rdreq,
         q      => txfifo_q,

         empty  => txfifo_empty,
         full   => txfifo_full,
         almost_full   => txfifo_almost_full
      );


   --///////////////////////////////////////////////////////////
   -- TX Streaming ECRC mux
   -- Selects between sending output tx Stream with ECRC or
   -- an output tx Stream without ECRC

   -- Streaming output - ECRC mux
   txdata <= txdata_ecrc WHEN (ECRC_FORWARD_GENER = 1) ELSE
             txdata_int;

   tx_stream_valid0 <= tx_stream_valid0_ecrc WHEN (ECRC_FORWARD_GENER = 1) ELSE '0' WHEN ((txfifoq_r_eop1='1') AND (txdata_int(131)='0')) ELSE
                       tx_stream_valid0_int;

   -- Data Fifo read control - ECRC mux
   txfifo_rdreq <= txfifo_rdreq_ecrc WHEN (ECRC_FORWARD_GENER = 1) ELSE
                   txfifo_rdreq_int;

   --/////////////////////////////////////////////////////
   -- Streaming output data & Fifo rd control without ECRC

   txdata_int(132 DOWNTO 0) <= txfifo_q_pipe (132 DOWNTO 0);
   txfifo_rdreq_int <= '1' WHEN ((tx_stream_ready0 = '1') AND (txfifo_empty = '0')) ELSE
                       '0';

   --  tx_stream_valid output signal
   --  used when ECRC forwarding is NOT enabled

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_stream_valid0_int <= '0';
            output_stage_full    <= '0';
         ELSIF (tx_stream_ready0 = '0') THEN
            tx_stream_valid0_int <= '0';
            output_stage_full    <= output_stage_full;
         ELSE
            output_stage_full <= NOT txfifo_empty;
            IF (output_stage_full = '1') THEN
               tx_stream_valid0_int <= '1';
            ELSE
               tx_stream_valid0_int <= '0';
            END IF;
         END IF;
       txfifoq_r_eop1 <= txdata_int(128);
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
          IF (tx_stream_ready0 = '1') THEN
              txfifo_q_pipe <= txfifo_q;
         ELSE
              txfifo_q_pipe <= txfifo_q_pipe;
         END IF;
      END IF;
   END PROCESS;

   --//////////////////////////////////////////////////////////////////////
   --  ECRC Generator
   --  Appends ECRC field to end of txdata pulled from tx_data_fifo_128

   user_sop(0) <= txfifo_q(131);
   user_sop(1) <= '0';
   user_eop(0) <= txfifo_q(130);
   user_eop(1) <= txfifo_q(128);
   user_data <= txfifo_q(127 DOWNTO 0);

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            user_valid <= '0';
         ELSE
            IF ((user_rd_req = '1') AND (txfifo_empty = '0')) THEN
               user_valid <= '1';
            ELSIF (user_rd_req = '1') THEN
               user_valid <= '0';
            ELSE
               user_valid <= user_valid;     -- hold valid until 'acked' by rdreq
            END IF;
         END IF;
      END IF;
   END PROCESS;

   txdata_ecrc(127 DOWNTO 64) <= ecrc_stream_data0_0(63 DOWNTO 0);
   txdata_ecrc(130) <= ecrc_stream_data0_0(73);
   txdata_ecrc(131) <= ecrc_stream_data0_0(72);
   txdata_ecrc(132) <= '0';
   txdata_ecrc(128) <= ecrc_stream_data0_1(73);
   txdata_ecrc(129) <= ecrc_stream_data0_1(72);
   txdata_ecrc(63 DOWNTO 0) <= ecrc_stream_data0_1(63 DOWNTO 0);

   txfifo_rdreq_ecrc <= '1' WHEN ((user_rd_req = '1') AND (txfifo_empty = '0')) ELSE
                        '0';

   G:IF (ECRC_FORWARD_GENER = 1) GENERATE

     xhdl4 <= NOT(srst);
      cdma_ecrc_gen : altpcierd_cdma_ecrc_gen
         GENERIC MAP (
            avalon_st_128  => 1,
            xhdl_str       => "XHDL_STR"
         )
         PORT MAP (
            clk                => clk_in,
            rstn               => xhdl4,
            user_rd_req        => user_rd_req,
            user_sop           => user_sop(0),
            user_eop           => user_eop,
            user_data          => user_data,
            user_valid         => user_valid,
            tx_stream_ready0   => tx_stream_ready0,
            tx_stream_data0_0  => ecrc_stream_data0_0,
            tx_stream_data0_1  => ecrc_stream_data0_1,
            tx_stream_valid0   => tx_stream_valid0_ecrc
         );

   END GENERATE;
   --/////////////////////////////////////////
   --------------------------------------------------------------
   --    Constructing TSDATA from Desc/ Data, tx_dv, tx_dfr
   --------------------------------------------------------------
   -- txdata[132]     tx_err0
   -- txdata[131]     tx_sop0
   -- txdata[130]     tx_eop0
   -- txdata[129]     tx_sop1
   -- txdata[128]     tx_eop1
   --
   --                  Header |  Aligned |        Un-aligned
   --                         |          | 3 Dwords    | 4 Dwords
   -- txdata[127:96]    H0    |   D0     |  -  -> D1   |     -> D3
   -- txdata[95:64 ]    H1    |   D1     |  -  -> D2   |  D0 -> D4
   -- txdata[63:32 ]    H2    |   D2     |  -  -> D3   |  D1 -> D5
   -- txdata[31:0  ]    H4    |   D3     |  D0 -> D4   |  D2 -> D6

   tx_req_p0 <= '1' WHEN ((tx_req0 = '1') AND (tx_req_next = '0')) ELSE
                '0';

   ctrltx_nopayload <= ctrltx_nopayload_reg WHEN (tx_req_p0 = '0') ELSE
                       '1' WHEN (tx_desc0(126) = '0') ELSE
                       '0';
   ctrltx_3dw <= ctrltx_3dw_reg WHEN (tx_req_p0 = '0') ELSE
                 '1' WHEN (tx_desc0(125) = '0') ELSE
                 '0' ;
   ctrltx_tx_length <= ctrltx_tx_length_reg WHEN (tx_req_p0 = '0') ELSE
                       tx_desc0(105 DOWNTO 96) WHEN (tx_desc0(126) = '1') ELSE      --   Length only applies if there is a payld
                       "0000000000" ;
   ctrltx_address_n <= ctrltx_address WHEN (tx_req_p0 = '0') ELSE
                       tx_desc0(63 DOWNTO 32) WHEN (tx_desc0(125) = '0') ELSE
                       tx_desc0(31 DOWNTO 0) ;

   ctrltx_qword_aligned <= to_stdlogic((((ctrltx_3dw = '1') AND (tx_desc0(34 DOWNTO 32) = "000")) OR ((ctrltx_3dw = '0') AND (tx_desc0(2 DOWNTO 0) = "000")))) WHEN (tx_req_p1 = '1') ELSE
                           ctrltx_qword_aligned_reg;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_req_next <= '0';
            tx_req_p1 <= '0';
            ctrltx_nopayload_reg <= '0';
            ctrltx_3dw_reg <= '0';
            ctrltx_qword_aligned_reg <= '0';
            tx_stream_data_dw_count_reg <= "00000000000";
            tx_stream_data_dw_count_gt_4_reg <= '0';
            ctrltx_tx_length_reg <= "0000000000";
            ctrltx_address <= "00000000000000000000000000000000";
         ELSE
            tx_req_next <= tx_req0;
            tx_req_p1 <= tx_req_p0;
            ctrltx_nopayload_reg <= ctrltx_nopayload;
            ctrltx_3dw_reg <= ctrltx_3dw;
            ctrltx_qword_aligned_reg <= ctrltx_qword_aligned;
            tx_stream_data_dw_count_reg <= tx_stream_data_dw_count;
            tx_stream_data_dw_count_gt_4_reg <= tx_stream_data_dw_count_gt_4_n;
            ctrltx_tx_length_reg <= ctrltx_tx_length;
            ctrltx_address <= ctrltx_address_n;
         END IF;
      END IF;
   END PROCESS;

   tx_stream_data_dw_count_gt_4_n <= to_stdlogic((tx_stream_data_dw_count > "00000000100"));

   xhdl6 <= tx_data0 WHEN ((tx_ws0_xhdl1 = '0') OR (tx_ack0_xhdl0 = '1')) ELSE
                                     tx_data_reg;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_data_reg <= xhdl6;
         tx_err <= tx_err0;
      END IF;
   END PROCESS;

   tx_eop_3dwh_1dwp_nonaligned <= '1' WHEN ((tx_ack0_xhdl0 = '1') AND (ctrltx_3dw = '1') AND (ctrltx_qword_aligned = '0') AND (ctrltx_tx_length = "0000000001")) ELSE
                                  '0';

   txfifo_wrreq_with_payload <= '1' WHEN ((tx_sop_0 = '1') OR (tx_eop_1 = '1') OR ((tx_dv0 = '1') AND (tx_ws0_xhdl1 = '0'))) ELSE
                                '0';

   tx_sop_0 <= tx_ack0_xhdl0;
   -- ensures that back-to-back pkts are okay even if prev pkt requires extra cycle for eop
   tx_eop_1 <= '1' WHEN ((tx_eop_3dwh_1dwp_nonaligned = '1') OR ((ctrltx_tx_length = "0000000000") AND (tx_req_p1 = '1')) OR (tx_eop_ndword = '1')) ELSE    --  account for 4DW dataless
               '0';

   txfifo_wrreq_n <= '1' WHEN ((tx_req_p1 = '1') AND (ctrltx_nopayload = '1')) ELSE
                     txfifo_wrreq_with_payload;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN

         ctrltx_nopayload_r2 <= ctrltx_nopayload;
         ctrltx_qword_aligned_r2 <= ctrltx_qword_aligned;
         ctrltx_tx_length_r2 <= ctrltx_tx_length(1 DOWNTO 0);

         ctrltx_3dw_r2 <= ctrltx_3dw;
         IF ((tx_eop_1 = '1') AND (ctrltx_nopayload_r2 = '0')) THEN
            IF (ctrltx_qword_aligned_r2 = '1') THEN
               IF ((ctrltx_tx_length_r2 = "01") OR (ctrltx_tx_length_r2 = "10")) THEN
                  tx_empty <= '1';
               ELSE
                  tx_empty <= '0';
               END IF;
            ELSIF (ctrltx_qword_aligned_r2 = '0') THEN
               IF ((ctrltx_3dw_r2 = '1') AND ((ctrltx_tx_length_r2 = "10") OR (ctrltx_tx_length_r2 = "11"))) THEN
                  tx_empty <= '1';
               ELSIF ((ctrltx_3dw_r2 = '0') AND ((ctrltx_tx_length_r2 = "01") OR (ctrltx_tx_length_r2 = "00"))) THEN
                  tx_empty <= '1';
               ELSE
                  tx_empty <= '0';
               END IF;
            ELSE
               tx_empty <= '1';
            END IF;
         ELSE
            tx_empty <= '0';
         END IF;
      END IF;
   END PROCESS;

   -- TX FIFO WRITE - pipelined
   xhdl7 <= (tx_err0 & '1' & '0' & '0' & '1' & tx_desc0(127 DOWNTO 0)) WHEN ((tx_ack0_xhdl0 = '1') AND (ctrltx_nopayload = '1')) ELSE
               (tx_err & tx_sop_0 & tx_empty & tx_sop_1 & tx_eop_1 & txdata_with_payload);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         txfifo_wrreq <= txfifo_wrreq_n;
         tx_sop_1 <= '0';
         txfifo_d <= xhdl7;
      END IF;
   END PROCESS;

   --  Streaming EOP
   xhdl8 <= '0' WHEN ((ctrltx_3dw = '1') AND (ctrltx_qword_aligned = '0') AND (ctrltx_tx_length = "0000000001")) ELSE
               '1';
   PROCESS (xhdl8,tx_stream_data_dw_count_gt_4_n, tx_stream_data_dw_count_gt_4_reg)
   BEGIN
      IF ((ctrltx_nopayload = '0') AND (tx_stream_data_dw_count_gt_4_n = '0') AND (tx_stream_data_dw_count_gt_4_reg = '1')) THEN
         tx_eop_ndword <= xhdl8;
      ELSE
         tx_eop_ndword <= '0';
      END IF;
   END PROCESS;

   -- Generate Streaming interface Data field
   PROCESS (tx_ack0_xhdl0, ctrltx_3dw, ctrltx_address, tx_desc0, zeros_32, tx_data0, tx_data_reg)
   BEGIN
      -- descriptor phase
      IF (tx_ack0_xhdl0 = '1') THEN
         IF (ctrltx_3dw = '1') THEN
            CASE ctrltx_address(3 DOWNTO 2) IS
               WHEN "00" =>
                  txdata_with_payload <= (tx_desc0(127 DOWNTO 32) & zeros_32);
               WHEN "01" =>
                  txdata_with_payload <= (tx_desc0(127 DOWNTO 32) & tx_data0(63 DOWNTO 32));
               WHEN "10" =>
                  txdata_with_payload <= (tx_desc0(127 DOWNTO 32) & zeros_32);
               WHEN "11" =>
                  txdata_with_payload <= (tx_desc0(127 DOWNTO 32) & tx_data0(127 DOWNTO 96));
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSE
            txdata_with_payload <= tx_desc0;
         END IF;
      ELSE
         -- data phase
         -- convert 128-bit address alignement to 64-bit address alignment
         IF (ctrltx_3dw = '1') THEN
            CASE ctrltx_address(3 DOWNTO 2) IS
               WHEN "00" =>
                  txdata_with_payload <= (tx_data_reg(31 DOWNTO 0) & tx_data_reg(63 DOWNTO 32) & tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96));
               WHEN "01" =>
                  txdata_with_payload <= (tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96) & tx_data0(31 DOWNTO 0) & tx_data0(63 DOWNTO 32));
               WHEN "10" =>
                  txdata_with_payload <= (tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96) & tx_data0(31 DOWNTO 0) & tx_data0(63 DOWNTO 32));
               WHEN "11" =>
                  txdata_with_payload <= (tx_data0(31 DOWNTO 0) & tx_data0(63 DOWNTO 32) & tx_data0(95 DOWNTO 64) & tx_data0(127 DOWNTO 96));
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSE
            CASE ctrltx_address(3 DOWNTO 2) IS
               WHEN "00" =>
                  txdata_with_payload <= (tx_data_reg(31 DOWNTO 0) & tx_data_reg(63 DOWNTO 32) & tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96));
               WHEN "01" =>
                  txdata_with_payload <= (tx_data_reg(31 DOWNTO 0) & tx_data_reg(63 DOWNTO 32) & tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96));
               WHEN "10" =>
                  txdata_with_payload <= (tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96) & tx_data0(31 DOWNTO 0) & tx_data0(63 DOWNTO 32));

               WHEN "11" =>
                  txdata_with_payload <= (tx_data_reg(95 DOWNTO 64) & tx_data_reg(127 DOWNTO 96) & tx_data0(31 DOWNTO 0) & tx_data0(63 DOWNTO 32));
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END IF;
      END IF;
   END PROCESS;

   -- Calculate number of DWs to be transferred on streaming interface
   -- Including Descriptor DWs and empty (non-aligned) DWs
   PROCESS (tx_req_p1, tx_desc0, ctrltx_address_n, ctrltx_tx_length_ext, txfifo_wrreq, tx_stream_data_dw_count_reg)
   BEGIN
      -- initialize
      IF ((tx_req_p1 = '1') AND (tx_desc0(126) = '1')) THEN
         IF (tx_desc0(125) = '0') THEN    -- 3DW header pkt
            CASE ctrltx_address_n(3 DOWNTO 2) IS      -- - 4;     // add desc DW's (3DW header + 1 empty DW in header)
               WHEN "00" =>      --  - 4;     // add desc DW's (3DW header)
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000100";
               WHEN "01" =>      --  - 4;     // add desc DW's (3DW header + 1 empty DW in header)
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000011";
               WHEN "10" =>      --   - 4;    // add desc DW's (3DW header)
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000100";
               WHEN "11" =>
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000011";
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSE
            -- 4DW header pkt
            CASE ctrltx_address_n(3 DOWNTO 2) IS      --  + 1  - 4;    // add desc DW's (4DW header) + 1 empty data DW
               WHEN "01" =>      --  - 4;         // add desc DW's (4DW header)
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000101";
               WHEN "00" =>      --  + 3 - 4;     // add desc DW's (4DW header) + 1 empty data DW
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000100";
               WHEN "11" =>      --  + 2 - 4;     // add desc DW's (4DW header) + 2 empty data DWs
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000101";
               WHEN "10" =>
                  tx_stream_data_dw_count <= ctrltx_tx_length_ext + "00000000100";
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END IF;
      -- decrement
      ELSIF (txfifo_wrreq = '1') THEN     -- decrement whenever stream data is written to FIFO

         IF (tx_stream_data_dw_count_reg > "00000000011") THEN
            tx_stream_data_dw_count <= tx_stream_data_dw_count_reg - "00000000100";    -- 4 DWs transferred to stream
         ELSE
            tx_stream_data_dw_count <= "00000000000";
         END IF;
      ELSE
         tx_stream_data_dw_count <= tx_stream_data_dw_count_reg;     -- default
      END IF;
   END PROCESS;

END ARCHITECTURE trans;




