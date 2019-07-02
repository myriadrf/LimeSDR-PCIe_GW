LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- synthesis translate_off
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_cdma_ast_tx_64.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module construct of the Avalon Streaming transmit port for the
-- chaining DMA application DATA/Descriptor signals.
-------------------------------------------------------------------------------
-- Copyright (c) 2009 Altera Corporation. All rights reserved.  Altera products are
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
ENTITY altpcierd_cdma_ast_tx_64 IS
   GENERIC (
      ECRC_FORWARD_GENER  : INTEGER := 0

      --transmit section channel 0

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
END ENTITY altpcierd_cdma_ast_tx_64;
ARCHITECTURE altpcie OF altpcierd_cdma_ast_tx_64 IS



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

    FUNCTION to_integer (
      val      : std_logic_vector) RETURN integer IS

      CONSTANT vec      : std_logic_vector(val'high-val'low DOWNTO 0) := val;
      VARIABLE rtn      : integer := 0;
   BEGIN
      FOR index IN vec'RANGE LOOP
         IF (vec(index) = '1') THEN
            rtn := rtn + (2**index);
         END IF;
      END LOOP;
      RETURN(rtn);
   END to_integer;
   COMPONENT altpcierd_cdma_ecrc_gen IS
      GENERIC (
         XHDL_STR            : STRING := "XHDL_STR";
         AVALON_ST_128       : INTEGER := 0
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


   CONSTANT       TXFIFO_WIDTH        : INTEGER := 133;
   CONSTANT       TXFIFO_DEPTH        : INTEGER := 32;
   CONSTANT       TXFIFO_WIDTHU       : INTEGER := 5;
   CONSTANT       ZERO_INTEGER        : INTEGER := 0;
   CONSTANT       ONE_INTEGER         : INTEGER := 1;
   CONSTANT       TXFIFO_DEPTH_HALF   : INTEGER := TXFIFO_DEPTH / 2;

   CONSTANT TXFIFO_DEPTH_HALF_5 : std_logic_vector(5-1 downto 0):=to_stdlogicvector(TXFIFO_DEPTH_HALF,5);


   SIGNAL txdata_int                    : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txdata_ecrc                   : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txfifo_rdreq_int              : STD_LOGIC;
   SIGNAL txfifo_rdreq_ecrc             : STD_LOGIC;
   SIGNAL tx_stream_valid0_int          : STD_LOGIC;
   SIGNAL tx_stream_valid0_ecrc         : STD_LOGIC;
   SIGNAL tx_req_p0                     : STD_LOGIC;
   SIGNAL tx_req_next                   : STD_LOGIC;
   SIGNAL txdata_with_payload           : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_err                        : STD_LOGIC;
   SIGNAL tx_sop_0                      : STD_LOGIC;
   SIGNAL tx_empty                      : STD_LOGIC;
   SIGNAL tx_sop_1                      : STD_LOGIC;
   SIGNAL tx_eop_1                      : STD_LOGIC;
   SIGNAL tx_eop_3dwh_1dwp_nonaligned   : STD_LOGIC;
   SIGNAL tx_eop_ndword                 : STD_LOGIC;
   SIGNAL txfifo_d                      : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txfifo_wrreq                  : STD_LOGIC;
   SIGNAL txfifo_q                      : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL txfifo_empty                  : STD_LOGIC;
   SIGNAL txfifo_full                   : STD_LOGIC;
   SIGNAL txfifo_rdreq                  : STD_LOGIC;
   SIGNAL txfifo_usedw                  : STD_LOGIC_VECTOR(TXFIFO_WIDTHU - 1 DOWNTO 0);

   SIGNAL txfifo_wrreq_with_payload     : STD_LOGIC;
   SIGNAL ctrltx_nopayload              : STD_LOGIC;
   SIGNAL ctrltx_nopayload_reg          : STD_LOGIC;
   SIGNAL ctrltx_3dw                    : STD_LOGIC;
   SIGNAL ctrltx_3dw_reg                : STD_LOGIC;
   SIGNAL ctrltx_qword_aligned          : STD_LOGIC;
   SIGNAL ctrltx_qword_aligned_reg      : STD_LOGIC;
   SIGNAL ctrltx_tx_length              : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrltx_tx_length_reg          : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL txfifo_almostfull             : STD_LOGIC;
   SIGNAL tx_req_int                    : STD_LOGIC;
   SIGNAL ctrltx_4dw_or_aligned_reg     : STD_LOGIC;
   SIGNAL ctrltx_3dw_and_nonaligned_reg : STD_LOGIC;

   -- ECRC
   SIGNAL user_sop                      : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL user_eop                      : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL user_data                     : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL user_rd_req                   : STD_LOGIC;
   SIGNAL user_valid                    : STD_LOGIC;
   SIGNAL ecrc_stream_data0_0           : STD_LOGIC_VECTOR(75 DOWNTO 0);
   SIGNAL ecrc_stream_data0_1           : STD_LOGIC_VECTOR(75 DOWNTO 0);

   SIGNAL debug_3dw_aligned_dataless    : STD_LOGIC;
   SIGNAL debug_3dw_nonaligned_dataless : STD_LOGIC;
   SIGNAL debug_4dw_aligned_dataless    : STD_LOGIC;
   SIGNAL debug_4dw_nonaligned_dataless : STD_LOGIC;
   SIGNAL debug_3dw_aligned_withdata    : STD_LOGIC;
   SIGNAL debug_3dw_nonaligned_withdata : STD_LOGIC;
   SIGNAL debug_4dw_aligned_withdata    : STD_LOGIC;
   SIGNAL debug_4dw_nonaligned_withdata : STD_LOGIC;

   SIGNAL txfifo_q_pipe                 : STD_LOGIC_VECTOR(132 DOWNTO 0);
   SIGNAL output_stage_full             : STD_LOGIC;

   -- X-HDL generated signals
   SIGNAL xhdl3 : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_ack0_xhdl0                 : STD_LOGIC;
   SIGNAL tx_ws0_xhdl1                  : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   tx_ack0 <= tx_ack0_xhdl0;
   tx_ws0 <= tx_ws0_xhdl1;

   -----------------------------------
   -- debug monitors

   debug_3dw_aligned_dataless <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "00") AND (tx_desc0(34) = '0'));
   debug_3dw_nonaligned_dataless <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "00") AND (tx_desc0(34) = '1'));
   debug_3dw_aligned_withdata <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "10") AND (tx_desc0(34) = '0'));
   debug_3dw_nonaligned_withdata <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "10") AND (tx_desc0(34) = '1'));
   debug_4dw_aligned_dataless <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "01") AND (tx_desc0(2) = '0'));
   debug_4dw_nonaligned_dataless <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "01") AND (tx_desc0(2) = '1'));
   debug_4dw_aligned_withdata <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "11") AND (tx_desc0(2) = '0'));
   debug_4dw_nonaligned_withdata <= to_stdlogic((tx_ack0_xhdl0 = '1') AND (tx_desc0(126 DOWNTO 125) = "11") AND (tx_desc0(2) = '1'));
   -------------------------------------

   tx_fifo_empty <= txfifo_empty;

   tx_ack0_xhdl0 <= tx_req_int WHEN (txfifo_almostfull = '0') ELSE
                    '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_req_int <= '0';
            txfifo_almostfull <= '0';
         ELSE
            IF (tx_ack0_xhdl0 = '1') THEN
               tx_req_int <= '0';
            ELSIF (tx_req0 = '1') THEN
               tx_req_int <= '1';
            ELSE

               tx_req_int <= tx_req_int;
            END IF;
            IF ((txfifo_usedw > TXFIFO_DEPTH_HALF_5 ) AND (txfifo_empty = '0')) THEN
               txfifo_almostfull <= '1';
            ELSE
               txfifo_almostfull <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrltx_4dw_or_aligned_reg <= '0';
            ctrltx_3dw_and_nonaligned_reg <= '0';
         ELSE
            -- becomes valid on 2nd phase of tx_req
            ctrltx_4dw_or_aligned_reg <= to_stdlogic(((ctrltx_3dw = '0') OR (ctrltx_qword_aligned = '1')));     -- becomes valid on 2nd phase of tx_req
            ctrltx_3dw_and_nonaligned_reg <= to_stdlogic(((ctrltx_3dw = '1') AND (ctrltx_qword_aligned = '0')));
         END IF;
      END IF;
   END PROCESS;

   PROCESS (txfifo_almostfull, tx_req_int, ctrltx_4dw_or_aligned_reg)
   BEGIN
      IF ((txfifo_almostfull = '1') OR ((tx_req_int = '1') AND (ctrltx_4dw_or_aligned_reg = '1'))) THEN     -- hold off on accepting data until desc is written, if header is 4DW or address is QWaligned

         tx_ws0_xhdl1 <= '1';
      ELSE

         tx_ws0_xhdl1 <= '0';
      END IF;
   END PROCESS;

   --////////////////////////////////////////////////////////////////////
   -- tx_fifo



   tx_data_fifo_128 : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => TXFIFO_DEPTH,
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
         data   => txfifo_d,
         wrreq  => txfifo_wrreq,

         -- TX pop TAGs from TAG_FIFO
         rdreq  => txfifo_rdreq,
         q      => txfifo_q,

         empty  => txfifo_empty,
         full   => txfifo_full,
         usedw  => txfifo_usedw
      );

   --///////////////////////////////////////////////////////////
   -- TX Streaming ECRC mux
   -- Selects between sending output tx Stream with ECRC or
   -- an output tx Stream without ECRC

   -- Streaming output - ECRC mux
   txdata <= txdata_ecrc WHEN (ECRC_FORWARD_GENER = 1) ELSE
             txdata_int;
   tx_stream_valid0 <= tx_stream_valid0_ecrc WHEN (ECRC_FORWARD_GENER = 1) ELSE
                       tx_stream_valid0_int;

   -- Data Fifo read control - ECRC mux
   txfifo_rdreq <= txfifo_rdreq_ecrc WHEN (ECRC_FORWARD_GENER = 1) ELSE
                   txfifo_rdreq_int;

   --/////////////////////////////////////////////////////
   -- Streaming output data & Fifo rd control without ECRC

   txdata_int(132 DOWNTO 0) <= txfifo_q_pipe (132 DOWNTO 0);
   txfifo_rdreq_int <= '1' WHEN ((tx_stream_ready0 = '1') AND (txfifo_empty = '0')) ELSE
                       '0';

   --  tx_stream_valid output signal used when ECRC forwarding is NOT enabled

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
            output_stage_full <= NOT(txfifo_empty);
            IF (output_stage_full = '1') THEN
               tx_stream_valid0_int <= '1';
            ELSE
               tx_stream_valid0_int <= '0';
            END IF;
         END IF;
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
               user_valid <= user_valid;        -- hold valid until 'acked' by rdreq
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

   xhdl2 : IF (ECRC_FORWARD_GENER = 1) GENERATE


      xhdl3 <= NOT(srst);
      cdma_ecrc_gen : altpcierd_cdma_ecrc_gen
         GENERIC MAP (
            AVALON_ST_128  => ZERO_INTEGER,
            XHDL_STR       => "XHDL_STR"
         )
         PORT MAP (
            clk                => clk_in,
            rstn               => xhdl3,
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
   ctrltx_nopayload <=  ctrltx_nopayload_reg when (tx_req_p0='0') else
                        '1' WHEN (tx_dfr0 = '0') else '0';

   ctrltx_3dw <= ctrltx_3dw_reg when (tx_req_p0 = '0') ELSE
                  '1' WHEN (tx_desc0(125) = '0') ELSE '0' ;

   ctrltx_tx_length <= ctrltx_tx_length_reg when (tx_req_p0='0') else tx_desc0(105 DOWNTO 96) WHEN (tx_desc0(126) = '1') ELSE
                       (others=>'0')  ;
   ctrltx_qword_aligned <= ctrltx_qword_aligned_reg when (tx_req_p0='0') else
                          '1' when (((ctrltx_3dw = '1') AND (tx_desc0(34 DOWNTO 32) = "000"))
                                     OR ((ctrltx_3dw = '0') AND (tx_desc0(2 DOWNTO 0) = "000"))) else '0' ;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tx_req_next <= '0';
            ctrltx_nopayload_reg <= '0';
            ctrltx_3dw_reg <= '0';
            ctrltx_qword_aligned_reg <= '0';
            ctrltx_tx_length_reg <= "0000000000";
         ELSE
            tx_req_next <= tx_req0;
            ctrltx_nopayload_reg <= ctrltx_nopayload;
            ctrltx_3dw_reg <= ctrltx_3dw;
            ctrltx_qword_aligned_reg <= ctrltx_qword_aligned;
            ctrltx_tx_length_reg <= ctrltx_tx_length;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN

         tx_err <= tx_err0;
      END IF;
   END PROCESS;

   -- TX FIFO inputs - pipelined
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         txfifo_d <= (tx_err & tx_sop_0 & tx_empty & tx_sop_1 & tx_eop_1 & txdata_with_payload);
         txfifo_wrreq <= txfifo_wrreq_with_payload;
         tx_sop_1 <= '0';
      END IF;
   END PROCESS;

   txfifo_wrreq_with_payload <= '1' WHEN ((tx_req_p0 = '1') OR (tx_ack0_xhdl0 = '1') OR (tx_eop_1 = '1') OR ((tx_dv0 = '1') AND (tx_ws0_xhdl1 = '0'))) ELSE     -- 2 descriptor phases
                                '0';

   tx_sop_0 <= to_stdlogic((tx_req_p0 = '1'));      -- first cycle of descriptor

   -- (ctrltx_3dw==1'b1)&&(ctrltx_qword_aligned==1'b0)&&
   tx_eop_3dwh_1dwp_nonaligned <= '1' WHEN ((tx_ack0_xhdl0 = '1') AND (ctrltx_3dw_and_nonaligned_reg = '1') AND (ctrltx_tx_length = "0000000001")) ELSE     -- use registered version for performance.  only evaluated on tx_ack0 cycle (i.e. 2nd phase of tx_req)
                                  '0';

   tx_eop_1 <= '1' WHEN ((tx_eop_3dwh_1dwp_nonaligned = '1') OR ((ctrltx_nopayload_reg = '1') AND (tx_ack0_xhdl0 = '1')) OR (tx_eop_ndword = '1')) ELSE     --  account for 4DW dataless
               '0';

   -- Streaming EOP
   PROCESS (tx_dfr0, tx_dv0, tx_ws0_xhdl1, ctrltx_qword_aligned, ctrltx_3dw, ctrltx_tx_length)
   BEGIN
      IF ((tx_dfr0 = '0') AND (tx_dv0 = '1') AND (tx_ws0_xhdl1 = '0')) THEN     -- assert eop when last data phase is accepted
         IF ((ctrltx_qword_aligned = '1') OR (ctrltx_3dw = '0')) THEN       -- if aligned, or 4DW header, data is always deferred to cycle after descriptor phase 2
            tx_eop_ndword <= '1';       -- if not aligned adn 3DW header, and there were atleast 2 DWs
         ELSIF (ctrltx_tx_length > "0000000001") THEN
            tx_eop_ndword <= '1';
         ELSE

            tx_eop_ndword <= '0';       -- if not aligned, and there was only 1 word, or 0 words, eop was already asserted
         END IF;
      ELSE
         tx_eop_ndword <= '0';
      END IF;
   END PROCESS;

   tx_empty <= '1';

   -- Streaming Data Field
   -- ((tx_req_int==1'b1) && (ctrltx_3dw==1'b1) && (ctrltx_qword_aligned==1'b0)) ? {tx_desc0[63:32], tx_data0[63:32]} :
   txdata_with_payload(127 DOWNTO 64) <= tx_desc0(127 DOWNTO 64) WHEN (tx_req_p0 = '1') ELSE
                                         (tx_desc0(63 DOWNTO 32) & tx_data0(63 DOWNTO 32)) WHEN ((tx_req_int = '1') AND (ctrltx_3dw_and_nonaligned_reg = '1')) ELSE
                                         tx_desc0(63 DOWNTO 0) WHEN (tx_req_int = '1') ELSE
                                         (tx_data0(31 DOWNTO 0) & tx_data0(63 DOWNTO 32));

   txdata_with_payload(63 DOWNTO 0) <= "0000000000000000000000000000000000000000000000000000000000000000";

END ARCHITECTURE altpcie;
