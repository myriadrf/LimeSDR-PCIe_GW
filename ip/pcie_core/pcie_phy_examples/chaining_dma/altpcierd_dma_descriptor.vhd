LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in
--  * the chaining DMA design example. It retrieves DMA read or write
--  * descriptor from the root port memory, and store it in a descriptor FIFO.
--  */
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : DMA Descriptor module (altpcierd_dma_descriptor)
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_dma_descriptor.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Each Descriptor uses 2 QWORD such as
--       if (cstate==DT_FIFO_RD_QW0)
--   QW0      ep_addr <= dt_fifo_q[63:32]; length <= dt_fifo_q[63:32];
--   QW1      RC_MSB  <= dt_fifo_q[31:0];  RC_LSB <= dt_fifo_q[63:32];
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
ENTITY altpcierd_dma_descriptor IS
   GENERIC (
      RC_64BITS_ADDR         : INTEGER := 0;
      MAX_NUMTAG             : INTEGER := 32;
      DIRECTION              : INTEGER := 1;
      FIFO_DEPTH             : INTEGER := 256;
      FIFO_WIDTHU            : INTEGER := 8;
      FIFO_WIDTH             : INTEGER := 64;
      TXCRED_WIDTH           : INTEGER := 22;
      AVALON_ST_128          : INTEGER := 0;
      USE_CREDIT_CTRL        : INTEGER := 1;
      CDMA_AST_RXWS_LATENCY  : INTEGER := 2

   );
   PORT (
      dt_rc_last             : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      dt_rc_last_sync        : IN STD_LOGIC;
      dt_size                : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      dt_base_rc             : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      dt_3dw_rcadd           : IN STD_LOGIC;
      dt_fifo_rdreq          : IN STD_LOGIC;
      dt_fifo_empty          : OUT STD_LOGIC;
      dt_fifo_q              : OUT STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
      dt_fifo_q_4K_bound     : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
      cfg_maxrdreq_dw        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      tx_sel                 : IN STD_LOGIC;
      tx_ready               : OUT STD_LOGIC;
      tx_busy                : OUT STD_LOGIC;
      tx_cred                : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      tx_req                 : OUT STD_LOGIC;
      tx_ack                 : IN STD_LOGIC;
      tx_desc                : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_ws                  : IN STD_LOGIC;
      rx_buffer_cpl_max_dw   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_req                 : IN STD_LOGIC;
      rx_ack                 : OUT STD_LOGIC;
      rx_desc                : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      rx_dv                  : IN STD_LOGIC;
      rx_dfr                 : IN STD_LOGIC;
      init                   : IN STD_LOGIC;
      descriptor_mrd_cycle   : OUT STD_LOGIC;
      dma_sm                 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cpl_pending            : OUT STD_LOGIC;
      clk_in                 : IN STD_LOGIC;
      rstn                   : IN STD_LOGIC
   );
END ENTITY altpcierd_dma_descriptor;
ARCHITECTURE altpcie OF altpcierd_dma_descriptor IS



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

   COMPONENT add_sub_descriptor
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        datab       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
   END COMPONENT;

   CONSTANT       IDLE_ST                : INTEGER := 0;
   CONSTANT       IDLE_NEW_RCLAST        : INTEGER := 1;
   CONSTANT       TX_LENGTH              : INTEGER := 2;
   CONSTANT       IS_TX_READY            : INTEGER := 3;
   CONSTANT       START_TX               : INTEGER := 4;
   CONSTANT       MRD_TX_REQ             : INTEGER := 5;
   CONSTANT       MRD_TX_ACK             : INTEGER := 6;
   CONSTANT       WAIT_FOR_CPLD          : INTEGER := 7;
   CONSTANT       CPLD_ACK               : INTEGER := 8;
   CONSTANT       CPLD_DATA              : INTEGER := 9;
   CONSTANT       DONE_ST                : INTEGER := 10;

   CONSTANT       FIFO_WIDTH_DWORD       : INTEGER := 2 * AVALON_ST_128 + 2;
   CONSTANT       FIFO_NUMDW             : INTEGER := FIFO_WIDTH_DWORD * FIFO_DEPTH;
   CONSTANT       LPM_ADD_SUB_PIPELINE   : INTEGER := 2;
   CONSTANT       LPM_ADD_SUB_WIDTH      : INTEGER := 64;
   CONSTANT       ZERO_INTEGER           : INTEGER := 0;
   CONSTANT       ONE_INTEGER            : INTEGER := 1;
   CONSTANT       TWO_INTEGER            : INTEGER := 2;

   CONSTANT FIFO_DEPTH_16 : std_logic_vector(16-1 downto 0):=to_stdlogicvector(FIFO_DEPTH,16);
   CONSTANT IS_TX_READY_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(IS_TX_READY,4);
   CONSTANT FIFO_NUMDW_10 : std_logic_vector(10-1 downto 0):=to_stdlogicvector(FIFO_NUMDW,10);
   CONSTANT MRD_TX_REQ_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(MRD_TX_REQ,4);
   CONSTANT START_TX_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(START_TX,4);
   CONSTANT IDLE_ST_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(IDLE_ST,4);
   CONSTANT CPLD_DATA_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(CPLD_DATA,4);
   CONSTANT MRD_TX_ACK_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(MRD_TX_ACK,4);
   CONSTANT FIFO_WIDTH_DWORD_10 : std_logic_vector(10-1 downto 0):=to_stdlogicvector(FIFO_WIDTH_DWORD,10);
   CONSTANT DONE_ST_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(DONE_ST,4);
   CONSTANT TX_LENGTH_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(TX_LENGTH,4);
   CONSTANT CPLD_ACK_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(CPLD_ACK,4);
   CONSTANT WAIT_FOR_CPLD_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(WAIT_FOR_CPLD,4);
   CONSTANT IDLE_NEW_RCLAST_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(IDLE_NEW_RCLAST,4);


   SIGNAL cstate                          : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL nstate                          : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL descr_tag                       : STD_LOGIC;

   --//////////////////////////////////////////////
   --
   -- xhdl translation to vhdl constant
   --
   SIGNAL xhdl_zero_byte                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_zero_word                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_zero_dword                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_zero_qword                 : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_zero_dqword                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_zero_qqword                : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL xhdl_one_byte                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_one_word                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_one_dword                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_one_qword                  : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_one_dqword                 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_open_dqword                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_other_one                  : STD_LOGIC_VECTOR(127 DOWNTO 0);

   -- Register which contains the value of the last completed DMA transfer
   SIGNAL dt_addr_offset                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL dt_addr_offset_dw_ext           : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dt_addr_offset_qw_ext           : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_desc_addr_pipe               : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL addrval_32b                     : STD_LOGIC; -- Indicates that a 64-bit address has upper dword equal to zero
   SIGNAL dt_fifo_q_int                   : STD_LOGIC_VECTOR(FIFO_WIDTH + 12 DOWNTO 0);
   SIGNAL dt_fifo_data_int                : STD_LOGIC_VECTOR(FIFO_WIDTH + 12 DOWNTO 0);
   SIGNAL dt_rc_last_size_dw_gt_cfg_maxrdreq_dw_fifo_size    : STD_LOGIC;
   SIGNAL dt_rc_last_size_dw_minus_cfg_maxrdreq_dw_fifo_size : STD_LOGIC_VECTOR(15 DOWNTO 0);

   SIGNAL dt_fifo_sclr                    : STD_LOGIC;
   SIGNAL dt_fifo_full                    : STD_LOGIC;
   SIGNAL dt_fifo_tx_ready                : STD_LOGIC;
   SIGNAL rx_buffer_cpl_ready             : STD_LOGIC;
   SIGNAL scfifo_empty                    : STD_LOGIC;
   SIGNAL dt_fifo_usedw                   : STD_LOGIC_VECTOR(FIFO_WIDTHU - 1 DOWNTO 0);
   SIGNAL dt_fifo_data                    : STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
   SIGNAL dt_fifo_wrreq                   : STD_LOGIC;

   SIGNAL tx_lbe_d                        : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL tx_fbe_d                        : STD_LOGIC_VECTOR(3 DOWNTO 0);

   SIGNAL tlp_rx_type                     : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL tlp_rx_fmt                      : STD_LOGIC_VECTOR(1 DOWNTO 0);

   SIGNAL tx_tag_descriptor_wire          : STD_LOGIC_VECTOR(7 DOWNTO 0);

   SIGNAL tx_cred_non_posted_header_valid : STD_LOGIC;

   SIGNAL tx_desc_3DW                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_desc_4DW                     : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_desc_addr                    : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_desc_addr_3dw_pipe           : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dt_fifo_cnt                     : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL dt_fifo_cnt_eq_zero             : STD_LOGIC;
   SIGNAL tx_length_dw                    : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_length_dw_ext16              : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL tx_length_dw_md                 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_length_dw_max                : STD_LOGIC_VECTOR(9 DOWNTO 0);

   SIGNAL tx_length_byte                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL cfg_maxrdreq_dw_fifo_size       : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL dt_rc_last_size_dw              : STD_LOGIC_VECTOR(15 DOWNTO 0);      -- total number of descriptor for a given RC LAst
   SIGNAL loop_dma                        : STD_LOGIC;

   -- control signals used for pipelined configuration
   SIGNAL rx_ack_descrpt_ena              : STD_LOGIC;      -- Set when valid descriptor rx_desc , tag OK and TLP=CLPD
   SIGNAL rx_ack_descrpt_ena_p0           : STD_LOGIC;      -- same as rx_ack_descrpt_ena, but valid on rx_req_p0 and not rx_req_p1
   SIGNAL valid_rx_dv_descriptor_cpld     : STD_LOGIC;      -- Set when valid descriptor rx_desc , tag OK and TLP=CLPD
   SIGNAL rx_ack_pipe                     : STD_LOGIC;
   SIGNAL rx_cpld_data_on_rx_req_p0       : STD_LOGIC;
   SIGNAL rx_req_reg                      : STD_LOGIC;
   SIGNAL rx_req_p1                       : STD_LOGIC;
   SIGNAL rx_req_p0                       : STD_LOGIC;
   SIGNAL descr_tag_reg                   : STD_LOGIC;
   -- X-HDL generated signals
   SIGNAL xhdl5 : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL dt_fifo_empty_xhdl0             : STD_LOGIC;
   SIGNAL dt_fifo_q_xhdl1                 : STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
   SIGNAL rx_ack_xhdl2                    : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   dt_fifo_empty <= dt_fifo_empty_xhdl0;
   dt_fifo_q <= dt_fifo_q_xhdl1;
   rx_ack <= rx_ack_xhdl2;
   xhdl_zero_byte <= "00000000";
   xhdl_zero_word <= (xhdl_zero_byte & xhdl_zero_byte);
   xhdl_zero_dword <= (xhdl_zero_word & xhdl_zero_word);
   xhdl_zero_qword <= (xhdl_zero_dword & xhdl_zero_dword);
   xhdl_zero_dqword <= (xhdl_zero_qword & xhdl_zero_qword);
   xhdl_zero_qqword <= (xhdl_zero_dqword & xhdl_zero_dqword);
   xhdl_one_byte <= (xhdl_zero_byte(7 DOWNTO 1) & '1');
   xhdl_one_word <= (xhdl_zero_word(15 DOWNTO 1) & '1');
   xhdl_one_dword <= (xhdl_zero_dword(31 DOWNTO 1) & '1');
   xhdl_one_qword <= (xhdl_zero_qword(63 DOWNTO 1) & '1');
   xhdl_one_dqword <= (xhdl_zero_dqword(127 DOWNTO 1) & '1');
   xhdl_other_one <= "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_req_reg <= '0';
            rx_req_p1 <= '0';
         ELSE
            rx_req_reg <= rx_req;
            rx_req_p1 <= rx_req_p0;
         END IF;
      END IF;
   END PROCESS;
   rx_req_p0 <= rx_req AND NOT(rx_req_reg);

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cfg_maxrdreq_dw > FIFO_DEPTH_16 ) THEN
            cfg_maxrdreq_dw_fifo_size <= FIFO_DEPTH_16 ;
         ELSE
            cfg_maxrdreq_dw_fifo_size <= cfg_maxrdreq_dw;
         END IF;
      END IF;
   END PROCESS;

   -- RX assignments
   tlp_rx_fmt <= rx_desc(126 DOWNTO 125);
   tlp_rx_type <= rx_desc(124 DOWNTO 120);
   dma_sm <= cstate;

   tx_tag_descriptor_wire <= "00000001" WHEN (DIRECTION = 1) ELSE
                             "00000000";
   descr_tag <= '1' WHEN (rx_desc(47 DOWNTO 40) = tx_tag_descriptor_wire) ELSE
                '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         descr_tag_reg <= descr_tag;        -- rx_desc is valid on rx_req_p0, used on rx_req_p1
      END IF;
   END PROCESS;

   -- Check if credits are available for Non-Posted Header (MRd)
   -- if (USE_CREDIT_CTRL==0)

   -- Check for non posted header credit
   xhdl3 : IF (TXCRED_WIDTH > 36) GENERATE
      PROCESS (clk_in)
      BEGIN
         IF (clk_in'EVENT AND clk_in = '1') THEN
            IF ((init = '1') OR (USE_CREDIT_CTRL = 0)) THEN
               tx_cred_non_posted_header_valid <= '1';
            ELSIF (cstate = IS_TX_READY_4 ) THEN
               IF ((tx_cred(27 DOWNTO 20) > "00000000") OR (tx_cred(62) = '1')) THEN
                  tx_cred_non_posted_header_valid <= '1';
               ELSE
                  tx_cred_non_posted_header_valid <= '0';
               END IF;
            END IF;
         END IF;
      END PROCESS;
   END GENERATE;

   xhdl4 : IF (TXCRED_WIDTH < 37) GENERATE
      PROCESS (clk_in)
      BEGIN
         IF (clk_in'EVENT AND clk_in = '1') THEN
            IF ((init = '1') OR (USE_CREDIT_CTRL = 0)) THEN
               tx_cred_non_posted_header_valid <= '1';
            ELSIF (cstate = IS_TX_READY_4 ) THEN
               tx_cred_non_posted_header_valid <= tx_cred(10);
            END IF;
         END IF;
      END PROCESS;
   END GENERATE;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            dt_fifo_tx_ready <= '0';
         ELSIF (cstate = IS_TX_READY_4 ) THEN
            IF (dt_fifo_cnt + tx_length_dw < FIFO_NUMDW_10 ) THEN
               dt_fifo_tx_ready <= '1';
            ELSE
               dt_fifo_tx_ready <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   tx_length_dw_ext16(9 DOWNTO 0) <= tx_length_dw;
   tx_length_dw_ext16(15 DOWNTO 10) <= "000000";

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_buffer_cpl_ready <= '0';
         ELSIF (cstate = IS_TX_READY_4 ) THEN
            IF (tx_length_dw_ext16 > rx_buffer_cpl_max_dw) THEN
               rx_buffer_cpl_ready <= '0';
            ELSE
               rx_buffer_cpl_ready <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- TX assignments
   tx_req <= '1' WHEN (cstate = MRD_TX_REQ_4 ) ELSE
             '0';

   -- TX descriptor arbitration
   tx_busy <= '1' WHEN (cstate = MRD_TX_REQ_4 ) ELSE
              '0';
   tx_ready <= '1' WHEN ((cstate = START_TX_4 ) AND (dt_fifo_tx_ready = '1') AND (rx_buffer_cpl_ready = '1') AND (tx_cred_non_posted_header_valid = '1')) ELSE
               '0';

   tx_lbe_d <= "1111";
   tx_fbe_d <= "1111";

   tx_desc(127) <= '0';     --Set at top level readability
   -- 64 vs 32 bits tx_desc[126:125] cmd

   tx_desc(126 DOWNTO 125) <= "00" WHEN ((RC_64BITS_ADDR = 0) OR (dt_3dw_rcadd = '1') OR (addrval_32b = '1')) ELSE
                              "01";
   tx_desc(124 DOWNTO 120) <= "00000";
   tx_desc(119) <= '0';
   tx_desc(118 DOWNTO 116) <= "000";
   tx_desc(115 DOWNTO 112) <= "0000";
   tx_desc(111) <= '0';
   tx_desc(110) <= '0';
   tx_desc(109 DOWNTO 108) <= "00";
   tx_desc(107 DOWNTO 106) <= "00";
   tx_desc(105 DOWNTO 96) <= tx_length_dw;
   tx_desc(95 DOWNTO 80) <= "0000000000000000";     --Requester ID set at top level
   tx_desc(79 DOWNTO 72) <= tx_tag_descriptor_wire;
   tx_desc(71 DOWNTO 64) <= (tx_lbe_d & tx_fbe_d);
   tx_desc(63 DOWNTO 0) <= tx_desc_addr WHEN ((RC_64BITS_ADDR = 0) OR (dt_3dw_rcadd = '1') OR (addrval_32b = '0')) ELSE tx_desc_addr(31 downto 0)&xhdl_zero_dword ;

   -- Each descriptor uses 4 DWORD
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((dt_fifo_empty_xhdl0 = '1') AND (dt_rc_last_sync = '1')) THEN
            loop_dma <= '1';
         ELSE
            loop_dma <= '0';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         dt_rc_last_size_dw_gt_cfg_maxrdreq_dw_fifo_size <= to_stdlogic(dt_rc_last_size_dw > cfg_maxrdreq_dw_fifo_size);
         dt_rc_last_size_dw_minus_cfg_maxrdreq_dw_fifo_size <= dt_rc_last_size_dw - cfg_maxrdreq_dw_fifo_size;

         IF (cstate = IDLE_ST_4 ) THEN
            dt_rc_last_size_dw(1 DOWNTO 0) <= "00";
            dt_rc_last_size_dw(15 DOWNTO 2) <= dt_rc_last(13 DOWNTO 0) + "00000000000001";
         ELSE
            IF ((cstate = CPLD_DATA_4 ) AND (tx_length_dw = "0000000000") AND (rx_dv = '0')) THEN
               IF (dt_rc_last_size_dw_gt_cfg_maxrdreq_dw_fifo_size = '1')  THEN
                  dt_rc_last_size_dw <= dt_rc_last_size_dw_minus_cfg_maxrdreq_dw_fifo_size;
               ELSE
                  dt_rc_last_size_dw <= "0000000000000000";
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            dt_fifo_cnt <= "0000000000";
         ELSIF ((dt_fifo_rdreq = '1') AND (dt_fifo_cnt_eq_zero = '0') AND (scfifo_empty = '0')) THEN
            IF (cstate = MRD_TX_ACK_4 ) THEN
               dt_fifo_cnt <= dt_fifo_cnt + tx_length_dw_md;
            ELSE
               dt_fifo_cnt <= dt_fifo_cnt - FIFO_WIDTH_DWORD_10 ;
            END IF;
         ELSIF (cstate = MRD_TX_ACK_4 ) THEN
            dt_fifo_cnt <= dt_fifo_cnt + tx_length_dw;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            dt_fifo_cnt_eq_zero <= '1';
         ELSIF ((dt_fifo_rdreq = '1') AND (dt_fifo_cnt_eq_zero = '0') AND (scfifo_empty = '0')) THEN
            IF (cstate = MRD_TX_ACK_4 ) THEN
               IF (dt_fifo_cnt + tx_length_dw_md > "0000000000") THEN
                  dt_fifo_cnt_eq_zero <= '0';
               ELSE
                  dt_fifo_cnt_eq_zero <= '1';
               END IF;
            ELSE
               IF (dt_fifo_cnt - FIFO_WIDTH_DWORD_10  > "0000000000") THEN
                  dt_fifo_cnt_eq_zero <= '0';
               ELSE
                  dt_fifo_cnt_eq_zero <= '1';
               END IF;
            END IF;
         ELSIF (cstate = MRD_TX_ACK_4 ) THEN
            IF (dt_fifo_cnt + tx_length_dw > "0000000000") THEN
               dt_fifo_cnt_eq_zero <= '0';
            ELSE
               dt_fifo_cnt_eq_zero <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = IDLE_ST_4 ) OR (cstate = DONE_ST_4 )) THEN
            tx_length_dw <= "0000000000";
         ELSE
            IF (cstate = TX_LENGTH_4 ) THEN
               IF (dt_rc_last_size_dw > cfg_maxrdreq_dw_fifo_size) THEN
                  tx_length_dw(9 DOWNTO 0) <= cfg_maxrdreq_dw_fifo_size(9 DOWNTO 0);
               ELSE
                  tx_length_dw(9 DOWNTO 0) <= dt_rc_last_size_dw(9 DOWNTO 0);
               END IF;
            ELSIF (((cstate = CPLD_ACK_4 ) OR (cstate = CPLD_DATA_4 ) OR ((cstate = WAIT_FOR_CPLD_4 ) AND (rx_ack_descrpt_ena = '1'))) AND (rx_dv = '1') AND (tx_length_dw > "0000000000")) THEN
               IF (tx_length_dw = "0000000001") THEN
                  tx_length_dw <= "0000000000";
               ELSE
                  tx_length_dw <= tx_length_dw - FIFO_WIDTH_DWORD_10 ;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   tx_length_dw_max(9 DOWNTO 0) <= cfg_maxrdreq_dw_fifo_size(9 DOWNTO 0) WHEN (dt_rc_last_size_dw > cfg_maxrdreq_dw_fifo_size) ELSE
                                   dt_rc_last_size_dw(9 DOWNTO 0);

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = IDLE_ST_4 ) OR (cstate = DONE_ST_4 )) THEN
            tx_length_dw_md <= "0000000000";
         ELSE
            IF (cstate = TX_LENGTH_4 ) THEN
               tx_length_dw_md <= tx_length_dw_max - FIFO_WIDTH_DWORD_10 ;
            ELSIF (((cstate = CPLD_ACK_4 ) OR (cstate = CPLD_DATA_4 ) OR ((cstate = WAIT_FOR_CPLD_4 ) AND (rx_ack_descrpt_ena = '1'))) AND (rx_dv = '1') AND (tx_length_dw_md > "0000000000")) THEN
               IF (tx_length_dw_md = "0000000001") THEN
                  tx_length_dw_md <= "0000000000";
               ELSE
                  tx_length_dw_md <= tx_length_dw_md - FIFO_WIDTH_DWORD_10 ;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_length_byte <= "0000000000000000";
         ELSIF (cstate = MRD_TX_ACK_4 ) THEN
            tx_length_byte(1 DOWNTO 0) <= "00";
            tx_length_byte(11 DOWNTO 2) <= tx_length_dw(9 DOWNTO 0);
            tx_length_byte(15 DOWNTO 12) <= "0000";
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = IDLE_ST_4 ) THEN
            dt_addr_offset(15 DOWNTO 0) <= "0000000000010000";
         ELSIF (cstate = DONE_ST_4 ) THEN
            dt_addr_offset <= dt_addr_offset + tx_length_byte;
         END IF;
      END IF;
   END PROCESS;

   dt_addr_offset_dw_ext(15 DOWNTO 0) <= dt_addr_offset(15 DOWNTO 0);
   dt_addr_offset_dw_ext(31 DOWNTO 16) <= "0000000000000000";

   dt_addr_offset_qw_ext(31 DOWNTO 0) <= dt_addr_offset_dw_ext;
   dt_addr_offset_qw_ext(63 DOWNTO 32) <= "00000000000000000000000000000000";
   -- Generate tx_desc_addr  upon 32 vs 64 bits RC
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_desc_addr_3dw_pipe(31 DOWNTO 0) <= dt_base_rc(31 DOWNTO 0) + dt_addr_offset_dw_ext;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = IDLE_ST_4 ) THEN
            tx_desc_addr <= "0000000000000000000000000000000000000000000000000000000000000000";
            addrval_32b  <= '0';
         ELSIF (RC_64BITS_ADDR = 0) THEN
            tx_desc_addr(31 DOWNTO 0) <= "00000000000000000000000000000000";
            addrval_32b  <= '0';
            IF ((cstate = START_TX_4 ) AND (tx_sel = '1')) THEN
               --tx_desc_addr[63:32] <= dt_base_rc[31:0]+dt_addr_offset_dw_ext;
               tx_desc_addr(63 DOWNTO 32) <= tx_desc_addr_3dw_pipe(31 DOWNTO 0);
            END IF;
         ELSE
            IF ((cstate = START_TX_4 ) AND (tx_sel = '1')) THEN
               IF (dt_3dw_rcadd = '1') THEN
                  addrval_32b  <= '0';
                  tx_desc_addr(63 DOWNTO 32) <= dt_base_rc(31 DOWNTO 0) + dt_addr_offset_dw_ext;
                  tx_desc_addr(31 DOWNTO 0) <= "00000000000000000000000000000000";
               ELSE
                  -- tx_desc_addr <= dt_base_rc+dt_addr_offset_qw_ext;
                  tx_desc_addr <= tx_desc_addr_pipe;
                  IF (tx_desc_addr_pipe(63 DOWNTO 32) = xhdl_zero_dword) THEN
                     addrval_32b  <= '1';
                  ELSE
                     addrval_32b  <= '0';
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;



   addr64_add : add_sub_descriptor
      PORT MAP (
         dataa   => dt_addr_offset_qw_ext,
         datab   => dt_base_rc,
         clock   => clk_in,
         result  => tx_desc_addr_pipe
      );

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_req_p0 = '0') THEN
            rx_cpld_data_on_rx_req_p0 <= '0';
         ELSE
            IF ((tlp_rx_fmt = "10") AND (tlp_rx_type = "01010") AND (rx_dfr = '1')) THEN
               rx_cpld_data_on_rx_req_p0 <= '1';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = IDLE_ST_4 ) OR (cstate = IDLE_NEW_RCLAST_4 )) THEN
            descriptor_mrd_cycle <= '0';
         ELSE
            descriptor_mrd_cycle <= '1';
         END IF;
      END IF;
   END PROCESS;
   -- Descriptor state machine
   --    Combinatorial state transition (case state)
   PROCESS (cstate, init, loop_dma, tx_cred_non_posted_header_valid, rx_buffer_cpl_ready, dt_fifo_tx_ready, tx_sel, tx_ack, rx_ack_descrpt_ena, rx_dv, tx_length_dw, dt_rc_last_size_dw)
   BEGIN

      CASE cstate IS

         WHEN "0000"  =>
         --WHEN IDLE_ST_4  =>
            IF (init = '0') THEN
               nstate <= TX_LENGTH_4 ;
            ELSE
               nstate <= IDLE_ST_4 ;
            END IF;
         WHEN "0001"  =>
         --WHEN IDLE_NEW_RCLAST_4  =>
            IF ((loop_dma = '1') OR (init = '1')) THEN
               nstate <= IDLE_ST_4 ;
            ELSE
               nstate <= IDLE_NEW_RCLAST_4 ;
            END IF;

         WHEN "0010"  =>
         --WHEN TX_LENGTH_4  =>
            nstate <= IS_TX_READY_4 ;

         WHEN "0011"  =>
         --WHEN IS_TX_READY_4  =>
            IF ((tx_cred_non_posted_header_valid = '1') AND (rx_buffer_cpl_ready = '1') AND (dt_fifo_tx_ready = '1')) THEN
               nstate <= START_TX_4 ;
            ELSE
               nstate <= IS_TX_READY_4 ;
            END IF;
         -- Wait for top level arbitration (tx_sel)
         -- Form tx_desc
         --      Calculate tx_desc_addr
         --      Calculate tx_length

         WHEN "0100"  =>
         --WHEN START_TX_4  =>
            IF (init = '1') THEN
               nstate <= IDLE_ST_4 ;
            ELSE
               IF ((dt_fifo_tx_ready = '0') OR (rx_buffer_cpl_ready = '0') OR (tx_cred_non_posted_header_valid = '0')) THEN
                  nstate <= IS_TX_READY_4 ;
               ELSIF (tx_sel = '1') THEN
                  nstate <= MRD_TX_REQ_4 ;
               ELSE
                  nstate <= START_TX_4 ;
               END IF;
            END IF;

         WHEN "0101"  =>
         --WHEN MRD_TX_REQ_4  =>
            IF (tx_ack = '1') THEN
               nstate <= MRD_TX_ACK_4 ;
            ELSE
               nstate <= MRD_TX_REQ_4 ;
            END IF;

         WHEN "0110"  =>
         --WHEN MRD_TX_ACK_4  =>
            nstate <= WAIT_FOR_CPLD_4 ;

         WHEN "0111"  =>
         --WHEN WAIT_FOR_CPLD_4  =>
            IF (init = '1') THEN
               nstate <= IDLE_ST_4 ;
            ELSE
               IF (rx_ack_descrpt_ena = '1') THEN
                  nstate <= CPLD_ACK_4 ;
               ELSE
                  nstate <= WAIT_FOR_CPLD_4 ;
               END IF;
            END IF;

         WHEN "1000"  =>
         --WHEN CPLD_ACK_4  =>
            nstate <= CPLD_DATA_4 ;

         WHEN "1001"  =>
         --WHEN CPLD_DATA_4  =>
            IF (rx_dv = '0') THEN
               IF (tx_length_dw = "0000000000") THEN
                  nstate <= DONE_ST_4 ;
               ELSE
                  nstate <= WAIT_FOR_CPLD_4 ;
               END IF;
            ELSE
               nstate <= CPLD_DATA_4 ;
            END IF;

         WHEN "1010"  =>
         --WHEN DONE_ST_4  =>
            IF (dt_rc_last_size_dw > "0000000000000000") THEN
               nstate <= TX_LENGTH_4 ;
            ELSE
               nstate <= IDLE_NEW_RCLAST_4 ;
            END IF;
         WHEN OTHERS =>
            nstate <= IDLE_ST_4 ;
      END CASE;
   END PROCESS;

   -- Requester state machine
   --    Registered state state transition
   xhdl5 <= '1' WHEN ((nstate = WAIT_FOR_CPLD_4 ) AND (init = '0') AND (rx_ack_descrpt_ena_p0 = '1')) ELSE
             '0';
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate <= IDLE_ST_4 ;
         rx_ack_xhdl2 <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate <= nstate;
         rx_ack_xhdl2 <= xhdl5;
      END IF;
   END PROCESS;

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cpl_pending <= '0' ;
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = MRD_TX_ACK_4) THEN
            cpl_pending <= '1';
         ELSIF (cstate = DONE_ST_4) THEN
            cpl_pending <= '0';
         END IF;
      END IF;
   END PROCESS;

   -- Descriptor FIFO which contain the table of descriptors
   -- dt_fifo assignments

   rx_ack_descrpt_ena <= '1' WHEN ((rx_req_p1 = '1') AND (descr_tag_reg = '1') AND (rx_cpld_data_on_rx_req_p0 = '1')) ELSE
                         '0';

   rx_ack_descrpt_ena_p0 <= '1' WHEN ((rx_req_p0 = '1') AND (descr_tag = '1') AND ((tlp_rx_fmt = "10") AND (tlp_rx_type = "01010") AND (rx_dfr = '1'))) ELSE
                            '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((init = '1') OR (cstate = START_TX_4 )) THEN
            valid_rx_dv_descriptor_cpld <= '0';
         ELSE
            IF ((rx_req_p1 = '1') AND (descr_tag = '1') AND (rx_cpld_data_on_rx_req_p0 = '1')) THEN
               valid_rx_dv_descriptor_cpld <= '1';
            ELSIF (rx_dv = '0') THEN
               valid_rx_dv_descriptor_cpld <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_ack_pipe <= '0';
         ELSE
            rx_ack_pipe <= rx_ack_xhdl2;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            dt_fifo_empty_xhdl0 <= '1';
         ELSIF ((dt_fifo_usedw > "00000000") AND (AVALON_ST_128 = 1)) THEN
            dt_fifo_empty_xhdl0 <= '0';
         ELSIF ((dt_fifo_usedw > "00000001") AND (AVALON_ST_128 = 0)) THEN
            dt_fifo_empty_xhdl0 <= '0';
         ELSE
            dt_fifo_empty_xhdl0 <= '1';
         END IF;
      END IF;
   END PROCESS;

   dt_fifo_sclr <= init;
   dt_fifo_data <= rx_data(FIFO_WIDTH - 1 DOWNTO 0);
   dt_fifo_wrreq <= '1' WHEN ((rx_dv = '1') AND ((valid_rx_dv_descriptor_cpld = '1') OR (rx_ack_descrpt_ena = '1'))) ELSE
                    '0';

   dt_fifo_data_int <= (("1000000000000" - ('0' & rx_data(43 DOWNTO 32))) & rx_data(FIFO_WIDTH - 1 DOWNTO 0)) WHEN (AVALON_ST_128=0) ELSE
                       (("1000000000000" - ('0' & rx_data(107 DOWNTO 96))) & rx_data(FIFO_WIDTH - 1 DOWNTO 0));

   dt_scfifo : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => FIFO_DEPTH,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => FIFO_WIDTH + 13,
         lpm_widthu               => FIFO_WIDTHU,
         overflow_checking        => "ON",
         underflow_checking       => "ON",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => dt_fifo_sclr,
         wrreq  => dt_fifo_wrreq,
         rdreq  => dt_fifo_rdreq,
         data   => dt_fifo_data_int,
         q      => dt_fifo_q_int,
         empty  => scfifo_empty,
         full   => dt_fifo_full,

         usedw  => dt_fifo_usedw
      );

      dt_fifo_q_xhdl1 <= dt_fifo_q_int(FIFO_WIDTH - 1 DOWNTO 0);
      dt_fifo_q_4K_bound <= dt_fifo_q_int(FIFO_WIDTH + 12 DOWNTO FIFO_WIDTH);

END ARCHITECTURE altpcie;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY add_sub_descriptor IS
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        datab       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
END add_sub_descriptor;


ARCHITECTURE SYN OF add_sub_descriptor IS

    SIGNAL sub_wire0    : STD_LOGIC_VECTOR (63 DOWNTO 0);



    COMPONENT lpm_add_sub
    GENERIC (
        lpm_direction       : STRING;
        lpm_hint        : STRING;
        lpm_pipeline        : NATURAL;
        lpm_representation      : STRING;
        lpm_type        : STRING;
        lpm_width       : NATURAL
    );
    PORT (
            dataa   : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            datab   : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            clock   : IN STD_LOGIC ;
            result  : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
    END COMPONENT;

BEGIN
    result    <= sub_wire0(63 DOWNTO 0);

    lpm_add_sub_component : lpm_add_sub
    GENERIC MAP (
        lpm_direction => "ADD",
        lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
        lpm_pipeline => 2,
        lpm_representation => "UNSIGNED",
        lpm_type => "LPM_ADD_SUB",
        lpm_width => 64
    )
    PORT MAP (
        dataa => dataa,
        datab => datab,
        clock => clock,
        result => sub_wire0
    );



END SYN;

