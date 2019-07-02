LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
--  * This Verilog HDL file is used for simulation and synthesis in
--  * the chaining DMA design example. It manages DMA write data transfer
--  * from the End Point memory to the Root Complex memory.
--  */
-- synthesis translate_off
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : DMA Write requestor module (altpcierd_write_dma_requester)
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_write_dma_requester.v
-- Author        : Altera Corporation
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
ENTITY altpcierd_write_dma_requester_128 IS
   GENERIC (
      MAX_PAYLOAD             : INTEGER := 256;
      MAX_NUMTAG              : INTEGER := 32;
      USE_RCSLAVE             : INTEGER := 0;
      FIFO_WIDTH              : INTEGER := 128;
      AVALON_WADDR            : INTEGER := 12;
      AVALON_WDATA            : INTEGER := 128;
      BOARD_DEMO              : INTEGER := 0;
      USE_MSI                 : INTEGER := 1;
      TXCRED_WIDTH            : INTEGER := 22;
      DMA_QWORD_ALIGN         : INTEGER := 0;
      RC_64BITS_ADDR          : INTEGER := 0;
      TL_SELECTION            : INTEGER := 0;
      USE_CREDIT_CTRL         : INTEGER := 1;
      DT_EP_ADDR_SPEC         : INTEGER := 2

      -- Descriptor control signals

      --PCIe transmit

      -- MSI signal

      --Avalon slave port

      -- Control signals for RC Slave module

   );
   PORT (
      dt_fifo_rdreq           : OUT STD_LOGIC;
      dt_fifo_empty           : IN STD_LOGIC;
      dt_fifo_q               : IN STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
      cfg_maxpload_dw         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_maxpload            : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_link_negociated     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      dt_base_rc              : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      dt_3dw_rcadd            : IN STD_LOGIC;
      dt_eplast_ena           : IN STD_LOGIC;
      dt_msi                  : IN STD_LOGIC;
      dt_size                 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      dt_fifo_q_4K_bound      : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      tx_ready_dmard          : IN STD_LOGIC;
      tx_ready                : OUT STD_LOGIC;
      tx_busy                 : OUT STD_LOGIC;
      tx_sel                  : IN STD_LOGIC;
      tx_cred                 : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      tx_req                  : OUT STD_LOGIC;
      tx_dv                   : OUT STD_LOGIC;
      tx_dfr                  : OUT STD_LOGIC;
      tx_ack                  : IN STD_LOGIC;
      tx_desc                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_data                 : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_ws                   : IN STD_LOGIC;
      app_msi_ack             : IN STD_LOGIC;
      app_msi_req             : OUT STD_LOGIC;
      msi_sel                 : IN STD_LOGIC;
      msi_ready               : OUT STD_LOGIC;
      msi_busy                : OUT STD_LOGIC;
      address                 : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      waitrequest             : OUT STD_LOGIC;
      read                    : OUT STD_LOGIC;
      readdata                : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      descriptor_mrd_cycle    : IN STD_LOGIC;
      requester_mrdmwr_cycle  : OUT STD_LOGIC;
      dma_sm                  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_status              : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      init                    : IN STD_LOGIC;
      clk_in                  : IN STD_LOGIC;
      rstn                    : IN STD_LOGIC
   );
END ENTITY altpcierd_write_dma_requester_128;
ARCHITECTURE altpcie OF altpcierd_write_dma_requester_128 IS


   FUNCTION ceil_log2(value: INTEGER) RETURN INTEGER IS
   -- return the number of bit necessary to code the positive value-1
   VARIABLE inc: INTEGER ;
   VARIABLE tmp: INTEGER ;
   BEGIN
       tmp := value-1;
       inc := 0;
       IF (tmp>0) THEN
           FOR i IN 0 to value+1 LOOP
               if (tmp > 0 )  THEN
                   tmp := tmp / 2;
                   inc := inc +1;
               end if ;
           END LOOP ;
       ELSE
           inc :=0;
       END IF ;
       RETURN inc;
   END ceil_log2;




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



   --///////////////////////////////////////////////////////
   -- Local signals
   --

   -- Control counter for payload and dma length
   CONSTANT       CDMA_VERSION            : INTEGER := 0;
   CONSTANT       TL_MODE                 : INTEGER := 2;
   CONSTANT       IDLE_MSI                : INTEGER := 0;       -- MSI Stand by
   CONSTANT       START_MSI               : INTEGER := 1;
   CONSTANT       MWR_REQ_MSI             : INTEGER := 2;
   CONSTANT       WR_FIFO_NUMWORDS        : INTEGER := 32;
 --  CONSTANT       WR_FIFO_NUMWORDS        : INTEGER := MAX_PAYLOAD / 2;
   CONSTANT       WR_FIFO_ALMST_FULL      : INTEGER := WR_FIFO_NUMWORDS - 8;
   CONSTANT       WR_FIFO_WIDTHU          : INTEGER := ceil_log2(WR_FIFO_NUMWORDS);
   CONSTANT       ZERO_INTEGER            : INTEGER := 0;
   CONSTANT       ONE_INTEGER             : INTEGER := 1;
   CONSTANT       TWO_INTEGER             : INTEGER := 2;
   CONSTANT       SIXTYFOUR_INTEGER       : INTEGER := 64;

   CONSTANT CDMA_VERSION_4 : std_logic_vector(4-1 downto 0):=to_stdlogicvector(CDMA_VERSION,4);
   CONSTANT TL_MODE_2 : std_logic_vector(2-1 downto 0):=to_stdlogicvector(TL_MODE,2);
   CONSTANT AVALON_WADDR_8 : std_logic_vector(8-1 downto 0):=to_stdlogicvector(AVALON_WADDR,8);
   CONSTANT WR_FIFO_ALMST_FULL_2 : std_logic_vector(4 downto 0):=to_stdlogicvector(WR_FIFO_ALMST_FULL,5);
   CONSTANT MWR_REQ_MSI_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(MWR_REQ_MSI,3);
   CONSTANT START_MSI_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(START_MSI,3);
   CONSTANT IDLE_MSI_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(IDLE_MSI,3);

   type CSTATE_TYPE is (DT_FIFO_4,DT_FIFO_RD_QW0_4,DT_FIFO_RD_QW1_4,TX_LENGTH_4,
                        START_TX_4,MWR_REQ_4,MWR_DV_4,DONE_4,TX_DONE_WS_4,START_TX_UPD_DT_4,
                        MWR_REQ_UPD_DT_4,MWR_DV_UPD_DT_4) ;

   component add_sub_128_write_req
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
   end component;

   SIGNAL tx_length_dw                     : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_length_ow                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_length_ow_minus_one           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_length_ow_minus_one_reg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_length_load_cycle_next        : STD_LOGIC;
   -- pre-decode tx_length values

   SIGNAL tx_length_byte                   : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL tx_length_byte_32ext             : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_length_byte_64ext             : STD_LOGIC_VECTOR(63 DOWNTO 0);

   SIGNAL cfg_maxpayload_dw_ext_10         : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL cfg_maxpload_dw_plus_two         : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL cdt_length_dw                    : STD_LOGIC_VECTOR(15 DOWNTO 0);     -- cdt : current descriptor //
   SIGNAL cdt_length_byte                  : STD_LOGIC_VECTOR(31 DOWNTO 0);     -- cdt : current descriptor //

   SIGNAL cfg_maxpload_byte                : STD_LOGIC_VECTOR(12 DOWNTO 0);     -- Max read request in bytes
   SIGNAL tx_desc_addr_4k                  : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL tx_desc_addr_4k_3dw              : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL tx_desc_addr_4k_4dw              : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL dt_fifo_q_addr_4k                : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL calc_4kbnd_done_byte             : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL calc_4kbnd_dt_fifo_byte          : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL calc_4kbnd_done_dw               : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL calc_4kbnd_dt_fifo_dw            : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL maxpload_dw                      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   -- pre-decode cdt_length_dw values

   -- TX State machine registers
   SIGNAL cstate                                     : CSTATE_TYPE;
   SIGNAL nstate                                     : CSTATE_TYPE;
   SIGNAL cstate_last                                : CSTATE_TYPE;

   -- MSI State machine registers
   -- MSI could be send in parallel to EPLast
   SIGNAL cstate_msi                       : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL nstate_msi                       : STD_LOGIC_VECTOR(2 DOWNTO 0);

   SIGNAL msi_busy_sg                      : STD_LOGIC;
   SIGNAL msi_ready_sg                     : STD_LOGIC;

   -- DMA registers
   SIGNAL cdt_msi                          : STD_LOGIC;     -- When set, send MSI to RC host
   SIGNAL cdt_eplast_ena                   : STD_LOGIC;     -- When set, update RC Host memory with dt_ep_last
   SIGNAL dt_ep_last                       : STD_LOGIC_VECTOR(15 DOWNTO 0);     -- Number of descriptors completed

   SIGNAL read_int                         : STD_LOGIC;
   SIGNAL address_reg                      : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL epmem_read_cycle                 : STD_LOGIC;

   SIGNAL wr_fifo_sclr                     : STD_LOGIC;
   SIGNAL wr_fifo_data                     : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL wr_fifo_wrreq                    : STD_LOGIC;
   SIGNAL wr_fifo_ready_to_read            : STD_LOGIC;
   SIGNAL wrreq_d                          : STD_LOGIC_VECTOR(5 DOWNTO 0);

   SIGNAL wr_fifo_rdreq                    : STD_LOGIC;
   SIGNAL wr_fifo_q                        : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL wr_fifo_usedw                    : STD_LOGIC_VECTOR(WR_FIFO_WIDTHU - 1 DOWNTO 0);
   SIGNAL wr_fifo_almost_full_level        : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL wr_fifo_almost_full              : STD_LOGIC;
   SIGNAL wr_fifo_empty                    : STD_LOGIC;
   SIGNAL wr_fifo_full                     : STD_LOGIC;

   SIGNAL tx_dfr_complete                  : STD_LOGIC;
   SIGNAL tx_dfr_complete_pipe             : STD_LOGIC;
   SIGNAL tx_dfr_p0                        : STD_LOGIC;
   SIGNAL tx_dfr_p1                        : STD_LOGIC;
   SIGNAL tx_dfr_add                       : STD_LOGIC;
   SIGNAL tx_dv_ws_wait                    : STD_LOGIC;
   SIGNAL tx_dv_gone                       : STD_LOGIC;
   SIGNAL tx_ws_val                        : STD_LOGIC;
   SIGNAL tx_dfr_non_qword_aligned_addr    : STD_LOGIC;

   SIGNAL tx_dfr_ow_counter                : STD_LOGIC_VECTOR(7 DOWNTO 0);      -- o --> octo-word = double dqword

   -- PCIe Signals RC address
   SIGNAL tx_desc_addr                     : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL addrval_32b                      : STD_LOGIC; -- Indicates that a 64-bit address has upper dword equal to zero
   SIGNAL tx_desc_addr_pipe                : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_max_addr                      : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_rc_addr_gt_tx_max_addr        : STD_LOGIC;
   SIGNAL tx_addr_eplast                   : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_addr_eplast_pipe              : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_32addr_eplast                 : STD_LOGIC;     --address 32 bits a
   SIGNAL tx_data_eplast                   : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_data_avalon                   : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL readdata_m                       : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL readdata_m_next                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_data_dw0_msb                  : STD_LOGIC;
   SIGNAL tx_tag                           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_lbe_d                         : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL tx_fbe_d                         : STD_LOGIC_VECTOR(3 DOWNTO 0);

   -- tx_credit control
   SIGNAL tx_cred_posted_header_valid_x8   : STD_LOGIC;
   SIGNAL tx_cred_posted_header_valid      : STD_LOGIC;
   SIGNAL tx_cred_posted_data_valid        : STD_LOGIC;
   SIGNAL tx_cred_posted_data              : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL tx_cred_posted_data_inf          : STD_LOGIC;

   -- For VHDl translation

   -- control bits : check 32 bit vs 64 bit address
   SIGNAL txadd_3dw                        : STD_LOGIC;

   -- control bits : generate tx_dfr & tx_dv
   SIGNAL tx_req_reg                       : STD_LOGIC;
   SIGNAL tx_req_pulse                     : STD_LOGIC;
   SIGNAL tx_req_delay                     : STD_LOGIC;
   SIGNAL tx_req_p0                        : STD_LOGIC;
   SIGNAL tx_req_p1                        : STD_LOGIC;

   -- control bits : set when ep_lastup transmit
   SIGNAL ep_lastupd_cycle                 : STD_LOGIC;
   SIGNAL performance_counter              : STD_LOGIC_VECTOR(23 DOWNTO 0);

   SIGNAL dt_fifo_ep_addr_byte             : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL inhibit_fifo_rd                  : STD_LOGIC;
   SIGNAL inhibit_fifo_rd_n                : STD_LOGIC;
   SIGNAL addr_ends_on128bit_bound         : STD_LOGIC;
   SIGNAL last_addr_ended_on128bit_bound   : STD_LOGIC;
   SIGNAL addr_end                         : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL tx_start_addr                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_start_addr_n                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_desc_addr_n                   : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_desc_addr_n_reg               : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL txadd_3dw_n                      : STD_LOGIC;
   SIGNAL txadd_3dw_n_reg                  : STD_LOGIC;
   SIGNAL tx_desc_addr_plus_tx_length_byte_32ext     : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dt_ep_last_eq_dt_size                      : STD_LOGIC;



   --//////////////////////////////////////////////
   --
   -- xhdl translation to vhdl constant
   --
   SIGNAL xhdl_zero_byte                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_zero_word                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_zero_dword                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_zero_qword                  : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_zero_dqword                 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_zero_qqword                 : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL xhdl_one_byte                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_one_word                    : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_one_dword                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_one_qword                   : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_one_dqword                  : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_open_dqword                 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_other_one                   : STD_LOGIC_VECTOR(127 DOWNTO 0);

   SIGNAL xhdl_two_byte                    : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_tx_length_dwext_word        : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_tx_desc_addr_plus_tx_length : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_tx_dv                       : STD_LOGIC;
   -- X-HDL generated signals
   SIGNAL xhdl10 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL xhdl11 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL xhdl12 : STD_LOGIC;
   SIGNAL xhdl13 : STD_LOGIC;
   SIGNAL xhdl14 : STD_LOGIC;
   SIGNAL xhdl15 : STD_LOGIC;
   SIGNAL xhdl16 : STD_LOGIC;
   SIGNAL xhdl17 : STD_LOGIC;
   SIGNAL xhdl18 : STD_LOGIC;
   SIGNAL xhdl19 : STD_LOGIC;
   SIGNAL xhdl20 : STD_LOGIC;
   SIGNAL xhdl21 : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_req_xhdl2                     : STD_LOGIC;
   SIGNAL tx_dfr_xhdl1                     : STD_LOGIC;
   SIGNAL requester_mrdmwr_cycle_xhdl0     : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   tx_req <= tx_req_xhdl2;
   tx_dfr <= tx_dfr_xhdl1;
   requester_mrdmwr_cycle <= requester_mrdmwr_cycle_xhdl0;
   dma_sm <= to_stdlogicvector(CSTATE_TYPE'POS(cstate),4);
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

   xhdl_two_byte <= "00000010";
   xhdl_tx_length_dwext_word(15 DOWNTO 10) <= "000000";
   xhdl_tx_length_dwext_word(9 DOWNTO 0) <= tx_length_dw(9 DOWNTO 0);
   tx_dv <= xhdl_tx_dv;

   tx_start_addr <= tx_desc_addr(63 DOWNTO 32) WHEN (txadd_3dw = '1') ELSE
                    tx_desc_addr(31 DOWNTO 0);
   tx_start_addr_n <= tx_desc_addr_n(63 DOWNTO 32) WHEN (txadd_3dw_n = '1') ELSE
                      tx_desc_addr_n(31 DOWNTO 0);

   dma_status <= tx_data_eplast;

   dt_fifo_ep_addr_byte(63 DOWNTO 32) <= "00000000000000000000000000000000";
   xhdl3 : IF (DT_EP_ADDR_SPEC = 0) GENERATE
      dt_fifo_ep_addr_byte(31 DOWNTO 0) <= dt_fifo_q(63 DOWNTO 32);
   END GENERATE;
   xhdl4 : IF (NOT(DT_EP_ADDR_SPEC = 0)) GENERATE
      xhdl5 : IF (DT_EP_ADDR_SPEC = 1) GENERATE
         dt_fifo_ep_addr_byte(31 DOWNTO 1) <= dt_fifo_q(62 DOWNTO 32);
         dt_fifo_ep_addr_byte(0) <= '0';
      END GENERATE;
      xhdl6 : IF (NOT(DT_EP_ADDR_SPEC = 1)) GENERATE
         xhdl7 : IF (DT_EP_ADDR_SPEC = 2) GENERATE
            dt_fifo_ep_addr_byte(31 DOWNTO 2) <= dt_fifo_q(61 DOWNTO 32);
            dt_fifo_ep_addr_byte(1 DOWNTO 0) <= "00";
         END GENERATE;
         xhdl8 : IF (NOT(DT_EP_ADDR_SPEC = 2)) GENERATE
            xhdl9 : IF (DT_EP_ADDR_SPEC = 3) GENERATE
               dt_fifo_ep_addr_byte(31 DOWNTO 3) <= dt_fifo_q(60 DOWNTO 32);
               dt_fifo_ep_addr_byte(2 DOWNTO 0) <= "000";
            END GENERATE;
         END GENERATE;
      END GENERATE;
   END GENERATE;

   -- if (USE_CREDIT_CTRL==0)
   -- 9:1   .. 0: No credits available
   --       .. 1-256: number of credits available
   --       .. 257-511: reserved
   -- Posted data: 9 bits permit advertisement of 256 credits,
   -- which corresponds to 4KBytes, the maximum payload size
   -- which translates into 1 credit == 4 DWORDS
   -- Credit and flow control signaling

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_cred_posted_header_valid_x8 <= '0';
         ELSE
            IF ((tx_cred(7 DOWNTO 0) > "00000000") OR (tx_cred(TXCRED_WIDTH - 6) = '1')) THEN
               tx_cred_posted_header_valid_x8 <= '1';
            ELSE
               tx_cred_posted_header_valid_x8 <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   tx_cred_posted_header_valid <= '1' WHEN (USE_CREDIT_CTRL = 0) ELSE
                                  tx_cred_posted_header_valid_x8 WHEN (TXCRED_WIDTH = 66) ELSE
                                  tx_cred(0);
   tx_cred_posted_data(10 DOWNTO 2) <= tx_cred(16 DOWNTO 8) WHEN (TXCRED_WIDTH = 66) ELSE
                                       tx_cred(9 DOWNTO 1);
   tx_cred_posted_data(1 DOWNTO 0) <= "00";
   tx_cred_posted_data_inf <= tx_cred(TXCRED_WIDTH - 5) WHEN (TXCRED_WIDTH = 66) ELSE
                              '0';
   cfg_maxpayload_dw_ext_10 <= cfg_maxpload_dw(10 DOWNTO 0);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (USE_CREDIT_CTRL = 0) THEN
            tx_cred_posted_data_valid <= '1';
         ELSE
            IF ((init = '1') OR (tx_cred_posted_header_valid = '0')) THEN
               tx_cred_posted_data_valid <= '0';
            ELSE
               IF (tx_cred_posted_data_inf = '1') THEN
                  tx_cred_posted_data_valid <= '1';
               ELSE
                  IF (cdt_length_dw > cfg_maxpload_dw) THEN
                     IF (tx_cred_posted_data >= cfg_maxpayload_dw_ext_10) THEN
                        tx_cred_posted_data_valid <= '1';
                     ELSE
                        tx_cred_posted_data_valid <= '0';
                     END IF;
                  ELSE
                     tx_cred_posted_data_valid <= '0';
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   wr_fifo_ready_to_read <= '1' WHEN (wr_fifo_empty = '0') ELSE
                            '1' WHEN (wr_fifo_wrreq = '1') ELSE
                            '0';

   tx_ready <= '1' WHEN ((cstate = START_TX_4 ) AND (wr_fifo_ready_to_read = '1') AND (tx_ready_dmard = '0')) ELSE
               '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((nstate=MWR_REQ_4) OR (nstate=MWR_DV_4) OR (nstate=DONE_4) OR
           (nstate=TX_DONE_WS_4) OR (nstate=MWR_REQ_UPD_DT_4) OR
            (nstate=START_TX_UPD_DT_4) OR (nstate=MWR_DV_UPD_DT_4)) THEN
            tx_busy <= '1';
         ELSIF ((nstate=START_TX_4) AND (cstate=DONE_4)) THEN
            tx_busy <= '1';
         ELSE
            tx_busy <= '0';
         END IF;
      END IF;
   END PROCESS;

   dt_fifo_rdreq <= '1' WHEN ((dt_fifo_empty = '0') AND (cstate = DT_FIFO_4 )) ELSE
                    '0';

   -- Updating RC memory register dt_ep_last
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            ep_lastupd_cycle <= '0';
         ELSE
            IF ((cstate = START_TX_UPD_DT_4 ) OR (cstate = MWR_REQ_UPD_DT_4 ) OR (cstate = MWR_DV_UPD_DT_4 )) THEN
               ep_lastupd_cycle <= '1';
            ELSE
               ep_lastupd_cycle <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- Register containing EPLast descriptor processed
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         cstate_last <= cstate;
         IF (init = '1') THEN
            dt_ep_last <= "0000000000000000";
            dt_ep_last_eq_dt_size <= '0';
         ELSE
             IF (dt_ep_last = dt_size) THEN
                 dt_ep_last_eq_dt_size <= '1';
             ELSE
                 dt_ep_last_eq_dt_size <= '0';
             END IF;

             IF ((cstate = DT_FIFO_4 ) AND ((cstate_last = MWR_DV_UPD_DT_4 ) OR (cstate_last=DONE_4))) THEN
                IF (dt_ep_last_eq_dt_size = '1') THEN
                   dt_ep_last <= "0000000000000000";
                ELSE
                   dt_ep_last <= dt_ep_last + 1;
                END IF;
             ELSE
                dt_ep_last <= dt_ep_last;
             END IF;
         END IF;
      END IF;
   END PROCESS;

   -- tx signals
   tx_tag <= xhdl_zero_byte;
   tx_lbe_d <= "0000" WHEN ((ep_lastupd_cycle = '0') AND (tx_length_dw = "0000000001")) ELSE
               "1111";
   tx_fbe_d <= "1111";

   tx_req_xhdl2 <= '1' WHEN (((cstate = MWR_REQ_4 ) OR (cstate = MWR_REQ_UPD_DT_4 )) AND (tx_ack = '0')) ELSE
                   '0';

   -- tx_desc construction
   tx_desc(127) <= '0';
   tx_desc(126 DOWNTO 125) <= "10" WHEN (RC_64BITS_ADDR = 0) ELSE
                              "10" WHEN (((ep_lastupd_cycle = '0') AND (txadd_3dw = '1')) OR ((ep_lastupd_cycle = '1') AND (dt_3dw_rcadd = '1'))) ELSE
                              "11" WHEN (addrval_32b = '0') ELSE
                              "10";
   tx_desc(124 DOWNTO 120) <= "00000";
   tx_desc(119) <= '0';
   tx_desc(118 DOWNTO 116) <= "000";
   tx_desc(115 DOWNTO 112) <= "0000";
   tx_desc(111) <= '0';
   tx_desc(110) <= '0';
   tx_desc(109 DOWNTO 108) <= "00";
   tx_desc(107 DOWNTO 106) <= "00";
   tx_desc(105 DOWNTO 96) <= "0000000010" WHEN (ep_lastupd_cycle = '1') ELSE
                             tx_length_dw;
   tx_desc(95 DOWNTO 80) <= xhdl_zero_word;
   tx_desc(79 DOWNTO 72) <= tx_tag;
   tx_desc(71 DOWNTO 64) <= (tx_lbe_d & tx_fbe_d);
   tx_desc(63 DOWNTO 0) <= tx_addr_eplast WHEN (ep_lastupd_cycle = '1') ELSE
                           tx_desc_addr   WHEN (addrval_32b='0') ELSE
                           tx_desc_addr(31 DOWNTO 0)&xhdl_zero_dword;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         cfg_maxpload_dw_plus_two <= cfg_maxpload_dw + "0000000000000010";
      END IF;
   END PROCESS;

   -- tx_ws_val_pipe ignores tx_ws on the first pulse
   -- of tx_dfr and on the first pulse of tx_dv
   tx_ws_val <= '0' WHEN ((tx_req_p0 = '1') OR (tx_ws = '0')) ELSE
                '1';
   --assign tx_ws_val = tx_ws;

   -- cdt_length_dw counter
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = DT_FIFO_4 ) THEN
            cdt_length_dw <= "0000000000000000";
         ELSE
            IF (cstate = DT_FIFO_RD_QW0_4 ) THEN
               -- DW count is decremented by 4 DWs after every mem access.
               -- When starting address is offset in memory, add offset to
               -- the total # of DWs to be accessed from memory to account for
               -- unused DWs in the first memory access.
               cdt_length_dw <= dt_fifo_q(15 DOWNTO 0);
            ELSIF (tx_req_p0 = '1') THEN
               cdt_length_dw <= cdt_length_dw - xhdl_tx_length_dwext_word;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- PCIe 4K byte boundary off-set
   cfg_maxpload_byte(1 DOWNTO 0) <= "00";
   cfg_maxpload_byte(12 DOWNTO 2) <= cfg_maxpload_dw(10 DOWNTO 0);

   tx_desc_addr_4k(12) <= '0';
   tx_desc_addr_4k(11 DOWNTO 0) <= tx_desc_addr_4k_3dw WHEN (txadd_3dw = '1') ELSE
                                   tx_desc_addr_4k_4dw;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_desc_addr_4k_3dw <= "000000000000";
            tx_desc_addr_4k_4dw <= "000000000000";
         ELSIF (tx_req_p0 = '1') THEN
            tx_desc_addr_4k_3dw <= tx_desc_addr(43 DOWNTO 32) + tx_length_byte;
            tx_desc_addr_4k_4dw <= tx_desc_addr(11 DOWNTO 0) + tx_length_byte;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            calc_4kbnd_done_byte <= cfg_maxpload_byte;
         ELSIF ((cstate = MWR_REQ_4 ) AND (tx_ack = '1')) THEN
            calc_4kbnd_done_byte <= "1000000000000" - tx_desc_addr_4k;
         END IF;
      END IF;
   END PROCESS;

   calc_4kbnd_done_dw(15 DOWNTO 11) <= "00000";
   calc_4kbnd_done_dw(10 DOWNTO 0) <= calc_4kbnd_done_byte(12 DOWNTO 2);

   dt_fifo_q_addr_4k(12) <= '0';
   dt_fifo_q_addr_4k(11 DOWNTO 0) <= dt_fifo_q(43 + 64 DOWNTO 32 + 64) WHEN (RC_64BITS_ADDR = 0) ELSE
                                     dt_fifo_q(43 + 64 DOWNTO 32 + 64);
   calc_4kbnd_dt_fifo_byte <= dt_fifo_q_4K_bound;
   calc_4kbnd_dt_fifo_dw(15 DOWNTO 11) <= "00000";
   calc_4kbnd_dt_fifo_dw(10 DOWNTO 0) <= "00000000001" WHEN ((calc_4kbnd_dt_fifo_byte(12 DOWNTO 2) = "00000000000") AND (calc_4kbnd_dt_fifo_byte(1 DOWNTO 0) > "00")) ELSE
                                         calc_4kbnd_dt_fifo_byte(12 DOWNTO 2);

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            maxpload_dw <= cfg_maxpload_dw;
         ELSIF (cstate = MWR_DV_4 ) THEN
            IF (cfg_maxpload_byte > calc_4kbnd_done_byte) THEN
               maxpload_dw <= calc_4kbnd_done_dw;
            ELSE
               maxpload_dw <= cfg_maxpload_dw;
            END IF;
         ELSIF (cstate = DT_FIFO_RD_QW1_4 ) THEN
            IF (cfg_maxpload_byte > calc_4kbnd_dt_fifo_byte) THEN
               maxpload_dw <= calc_4kbnd_dt_fifo_dw;
            ELSE
               maxpload_dw <= cfg_maxpload_dw;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         --  tx_dma_length_dw : length of data to tx
         IF (cstate = DT_FIFO_4 ) THEN
            tx_length_dw <= "0000000000";
         ELSE
            IF ((cstate = TX_LENGTH_4 ) OR (cstate = DONE_4 )) THEN
               IF (cdt_length_dw > maxpload_dw) THEN
                  tx_length_dw <= maxpload_dw(9 DOWNTO 0);
               ELSE
                  tx_length_dw <= cdt_length_dw(9 DOWNTO 0);
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   --   if ((cstate==TX_LENGTH)||(cstate==DONE)) begin
   -- tx_length_ow is the # of tx_data cycles required to transfer tx_length_dw payload.
   -- if payld length is fraction of oct-word, then round up.
   xhdl10 <= tx_start_addr_n(3 DOWNTO 2) & maxpload_dw(1 DOWNTO 0);

   -- tx_length_ow is the # of tx_data cycles required to transfer tx_length_dw payload.
   -- if payld length is fraction of oct-word, then round up.
   xhdl11 <= tx_start_addr_n(3 DOWNTO 2) & cdt_length_dw(1 DOWNTO 0);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cdt_length_dw > maxpload_dw) THEN
            CASE xhdl10 IS
               WHEN "0000" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2);
               WHEN "0001" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0010" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0011" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0100" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0101" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0110" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0111" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1000" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1001" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1010" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1011" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_two_byte;
               WHEN "1100" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1101" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1110" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_two_byte;
               WHEN "1111" =>
                  tx_length_ow(7 DOWNTO 0) <= maxpload_dw(9 DOWNTO 2) + xhdl_two_byte;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         ELSE
            CASE xhdl11 IS
               WHEN "0000" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2);
               WHEN "0001" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0010" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;

               WHEN "0011" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0100" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0101" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "0110" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;

               WHEN "0111" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1000" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1001" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1010" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;

               WHEN "1011" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_two_byte;
               WHEN "1100" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1101" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_one_byte;
               WHEN "1110" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_two_byte;
               WHEN "1111" =>
                  tx_length_ow(7 DOWNTO 0) <= cdt_length_dw(9 DOWNTO 2) + xhdl_two_byte;
               WHEN OTHERS =>
                  NULL;
            END CASE;
         END IF;
      END IF;
   END PROCESS;

   --   end

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = TX_LENGTH_4 ) OR (cstate = DONE_4 )) THEN
            tx_length_load_cycle_next <= '1';
         ELSE
            tx_length_load_cycle_next <= '0';
         END IF;
      END IF;
   END PROCESS;

   tx_length_ow_minus_one <= tx_length_ow - "00000001" WHEN (tx_length_load_cycle_next = '1') ELSE      -- Needed for tx_dv_gone
                             tx_length_ow_minus_one_reg;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_length_ow_minus_one_reg <= "00000000";
         END IF;
         IF (tx_length_load_cycle_next = '1') THEN
            tx_length_ow_minus_one_reg <= tx_length_ow - "00000001";
         END IF;
      END IF;
   END PROCESS;

   tx_length_byte(11 DOWNTO 2) <= tx_length_dw(9 DOWNTO 0);
   tx_length_byte(1 DOWNTO 0) <= "00";
   tx_length_byte_32ext(11 DOWNTO 0) <= tx_length_byte(11 DOWNTO 0);
   tx_length_byte_32ext(31 DOWNTO 12) <= "00000000000000000000";
   tx_length_byte_64ext(11 DOWNTO 0) <= tx_length_byte(11 DOWNTO 0);
   tx_length_byte_64ext(63 DOWNTO 12) <= "0000000000000000000000000000000000000000000000000000";

   cdt_length_byte(17 DOWNTO 2) <= cdt_length_dw(15 DOWNTO 0);
   cdt_length_byte(1 DOWNTO 0) <= "00";
   cdt_length_byte(31 DOWNTO 18) <= "00000000000000";

   -- Generation of tx_dfr signal
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = TX_LENGTH_4 ) OR (cstate = START_TX_UPD_DT_4 ) OR (cstate = MWR_DV_4 )) THEN
            tx_req_reg <= '0';
         ELSIF (tx_req_xhdl2 = '1') THEN
            tx_req_reg <= '1';
         END IF;
      END IF;
   END PROCESS;

   -- tx_req_pulse ensures that tx_dfr is set when tx_req is set
   tx_req_pulse <= tx_req_xhdl2 AND NOT(tx_req_reg);

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_req_delay <= tx_req_xhdl2;
         tx_req_p1 <= tx_req_p0;
      END IF;
   END PROCESS;
   tx_req_p0 <= tx_req_xhdl2 AND NOT(tx_req_delay);

   tx_dfr_add <= '1' WHEN ((tx_dfr_non_qword_aligned_addr = '1') AND (tx_dfr_complete = '0')) ELSE
                 '0';
   -- Generation of tx_dfr signal might be extended of one cycle for the
   -- pipelined implementation

   -- extend tx_dfr of 1 cycle if the tx_adr is not qword aligned (tx_data_dw0_msb)
   tx_dfr_non_qword_aligned_addr <= '1' WHEN ((tx_data_dw0_msb = '1') AND (tx_dfr_complete_pipe = '1')) ELSE
                                    '0';

   tx_dfr_xhdl1 <= '1' WHEN ((tx_dfr_p0 = '1') OR (tx_dfr_complete = '1')) ELSE
                   '0';

   tx_dfr_p0 <= tx_req_pulse;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((tx_dfr_xhdl1 = '1') AND (xhdl_tx_dv = '0')) THEN
            tx_dfr_p1 <= '1';
         ELSE
            tx_dfr_p1 <= '0';
         END IF;
      END IF;
   END PROCESS;

   xhdl12 <= '0' WHEN (tx_ws = '0') ELSE
                tx_dfr_complete_pipe;
   xhdl13 <= '1' WHEN (tx_dfr_complete = '1') ELSE
                (xhdl12);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_dfr_complete_pipe <= xhdl13;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = MWR_REQ_4 ) OR (cstate = MWR_DV_4 )) THEN
            IF (tx_dfr_ow_counter < tx_length_ow_minus_one) THEN
               tx_dfr_complete <= '1';
            ELSIF (tx_ws = '0') THEN
               tx_dfr_complete <= '0';
            END IF;
         ELSE
            tx_dfr_complete <= '0';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = MWR_REQ_4 ) OR (cstate = MWR_DV_4 )) THEN
            IF ((tx_ws_val = '0') AND (tx_dfr_ow_counter < tx_length_ow_minus_one)) THEN
               tx_dfr_ow_counter <= tx_dfr_ow_counter + "00000001";
            END IF;
         ELSE
            tx_dfr_ow_counter <= "00000000";
         END IF;
      END IF;
   END PROCESS;

   -- Generation of tx_dv signal
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            xhdl_tx_dv <= '0';
         ELSIF ((xhdl_tx_dv = '0') OR (tx_ws = '0')) THEN
            xhdl_tx_dv <= tx_dfr_xhdl1;
         END IF;
      END IF;
   END PROCESS;

   tx_dv_ws_wait <= xhdl_tx_dv;

   tx_data <= tx_data_avalon WHEN (ep_lastupd_cycle = '0') ELSE
              (tx_data_eplast(63 DOWNTO 0) & tx_data_eplast(63 DOWNTO 0));
   --  QW1  , QW0

   -- TX_Address Generation section : tx_desc_addr, tx_addr_eplast
   -- check static parameter for 64 bit vs 32 bits RC : RC_64BITS_ADDR
   -- contain the 64 bits RC destination address
   -- Header in RC memory
   -- BRC+10h   | DW0: length
   -- BRC+14h   | DW1: EP ADDR
   -- BRC+18h   | DW2: RC ADDR MSB
   -- BRC+1ch   | DW3: RC ADDR LSB
   -- on PCIe backend when request 4 DWORDS
   -- rx_data {DW1, DW0} QWORD1, {DW3, DW2} QWORD2
   --
   -- 32 static parameter
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_desc_addr_plus_tx_length_byte_32ext <= tx_desc_addr(63 DOWNTO 32)+tx_length_byte_32ext;

         IF ((cstate = DT_FIFO_4 ) OR (init = '1')) THEN
            tx_32addr_eplast <= '0';
            tx_addr_eplast <= xhdl_zero_qword;
            tx_desc_addr <= xhdl_zero_qword;
            addrval_32b  <='0';
         ELSIF (RC_64BITS_ADDR = 0) THEN
            tx_32addr_eplast <= '1';
            addrval_32b  <='0';
            -- generate tx_addr_eplast
            tx_addr_eplast(31 DOWNTO 0) <= xhdl_zero_dword;
            IF (cstate = DT_FIFO_RD_QW0_4 ) THEN

               -- generate tx_desc_addr
               tx_addr_eplast(63 DOWNTO 32) <= dt_base_rc(31 DOWNTO 0) + "00000000000000000000000000001000";
            END IF;
            txadd_3dw <= '1';
            tx_desc_addr(31 DOWNTO 0) <= xhdl_zero_dword;
            IF (cstate = DT_FIFO_RD_QW1_4 ) THEN
               tx_desc_addr(63 DOWNTO 32) <= dt_fifo_q(63 + 64 DOWNTO 32 + 64);
            ELSIF (cstate = DONE_4 ) THEN
               tx_desc_addr(63 DOWNTO 32) <= tx_desc_addr_plus_tx_length_byte_32ext;
            END IF;
         ELSE
            IF (cstate = DT_FIFO_RD_QW0_4 ) THEN
               IF (dt_3dw_rcadd = '1') THEN
                  tx_addr_eplast(63 DOWNTO 32) <= dt_base_rc(31 DOWNTO 0) + "00000000000000000000000000001000";
                  tx_addr_eplast(31 DOWNTO 0) <= xhdl_zero_dword;
                  tx_32addr_eplast <= '1';
               ELSE
                  --tx_addr_eplast <= dt_base_rc+64'h8;
                  tx_addr_eplast <= tx_addr_eplast_pipe;
                  tx_32addr_eplast <= '0';
               END IF;
            END IF;

            -- Assigning tx_desc_addr
            IF (cstate = DT_FIFO_RD_QW1_4 ) THEN
               -- RC ADDR MSB if qword aligned
               addrval_32b  <='0';
               IF (dt_fifo_q(95 DOWNTO 64) = xhdl_zero_dword) THEN
                  txadd_3dw <= '1';
                  tx_desc_addr(63 DOWNTO 32) <= dt_fifo_q(127 DOWNTO 96);
                  tx_desc_addr(31 DOWNTO 0) <= xhdl_zero_dword;
               ELSE
                  txadd_3dw <= '0';
                  tx_desc_addr(63 DOWNTO 32) <= dt_fifo_q(31 + 64 DOWNTO 0 + 64);
                  tx_desc_addr(31 DOWNTO 0) <= dt_fifo_q(63 + 64 DOWNTO 32 + 64);
               END IF;

            ELSIF (cstate = DONE_4 ) THEN
               -- TO DO assume double word
               IF (txadd_3dw = '1') THEN
                  addrval_32b  <='0';
                  tx_desc_addr(63 DOWNTO 32) <= tx_desc_addr(63 DOWNTO 32) + tx_length_byte_32ext;
               ELSE
                  -- 32 bit addition assuming no overflow on bit 31->32
                  tx_desc_addr <= tx_desc_addr_pipe;
                  IF (tx_desc_addr_pipe(63 DOWNTO 32) = xhdl_zero_dword ) THEN
                     addrval_32b <= '1';
                  ELSE
                     addrval_32b <= '0';
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   xhdl_tx_desc_addr_plus_tx_length <= tx_desc_addr(63 DOWNTO 32) + tx_length_byte_32ext(31 DOWNTO 0);
   tx_desc_addr_n <= xhdl_zero_qword WHEN (init = '1') ELSE
                     (dt_fifo_q(127 DOWNTO 96) & xhdl_zero_dword) WHEN ((RC_64BITS_ADDR = 0) AND (cstate = DT_FIFO_RD_QW1_4 )) ELSE
                     (xhdl_tx_desc_addr_plus_tx_length & xhdl_zero_dword) WHEN ((RC_64BITS_ADDR = 0) AND (cstate = DONE_4 )) ELSE
                     (dt_fifo_q(127 DOWNTO 96) & xhdl_zero_dword) WHEN ((RC_64BITS_ADDR = 1) AND (cstate = DT_FIFO_RD_QW1_4 ) AND (dt_fifo_q(95 DOWNTO 64) = xhdl_zero_dword)) ELSE
                     (dt_fifo_q(95 DOWNTO 64) & dt_fifo_q(127 DOWNTO 96)) WHEN ((RC_64BITS_ADDR = 1) AND (cstate = DT_FIFO_RD_QW1_4 ) AND (dt_fifo_q(95 DOWNTO 64) /= xhdl_zero_dword)) ELSE
                     (xhdl_tx_desc_addr_plus_tx_length & xhdl_zero_dword) WHEN ((RC_64BITS_ADDR = 1) AND (cstate = DONE_4 ) AND (txadd_3dw = '1')) ELSE
                     tx_desc_addr_pipe WHEN ((RC_64BITS_ADDR = 1) AND (cstate = DONE_4 ) AND (txadd_3dw = '0')) ELSE
                     tx_desc_addr_n_reg;
   txadd_3dw_n <= '1' WHEN (RC_64BITS_ADDR = 0) ELSE
                  '1' WHEN ((cstate = DT_FIFO_RD_QW1_4 ) AND (dt_fifo_q(95 DOWNTO 64) = xhdl_zero_dword)) ELSE
                  '0' WHEN ((cstate = DT_FIFO_RD_QW1_4 ) AND (dt_fifo_q(95 DOWNTO 64) /= xhdl_zero_dword)) ELSE
                  txadd_3dw_n_reg;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = DT_FIFO_4 ) OR (init = '1')) THEN
            tx_desc_addr_n_reg <= xhdl_zero_qword;
            txadd_3dw_n_reg <= '1';
         ELSE
            tx_desc_addr_n_reg <= tx_desc_addr_n;
            txadd_3dw_n_reg <= txadd_3dw_n;
         END IF;
      END IF;
   END PROCESS;

   addr64_add : add_sub_128_write_req
      PORT MAP (
         dataa   => tx_desc_addr,
         clock   => clk_in,
         result  => tx_desc_addr_pipe
      );

   addr64_add_eplast : add_sub_128_write_req
      PORT MAP (
         dataa   => dt_base_rc,
         clock   => clk_in,
         result  => tx_addr_eplast_pipe
      );

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = DT_FIFO_4 ) THEN
            tx_max_addr <= xhdl_zero_qword;
         ELSE
            tx_max_addr(31 DOWNTO 0) <= xhdl_zero_dword;
            IF (cstate = DT_FIFO_RD_QW1_4 ) THEN
               tx_max_addr(63 DOWNTO 32) <= dt_fifo_q(127 DOWNTO 96) + cdt_length_byte;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (RC_64BITS_ADDR = 0) THEN
            IF (cstate = DT_FIFO_4 ) THEN
               tx_rc_addr_gt_tx_max_addr <= '0';
            ELSIF (cstate = TX_LENGTH_4 ) THEN
               IF (tx_desc_addr(63 DOWNTO 32) > tx_max_addr(31 DOWNTO 0)) THEN
                  tx_rc_addr_gt_tx_max_addr <= '1';
               ELSE
                  tx_rc_addr_gt_tx_max_addr <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- DMA Write control signal msi, ep_lastena
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = DT_FIFO_RD_QW0_4 ) THEN
            cdt_msi <= dt_msi OR dt_fifo_q(16);
            cdt_eplast_ena <= dt_eplast_ena OR dt_fifo_q(17);
         END IF;
      END IF;
   END PROCESS;

   --DMA Write performance counter
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            performance_counter <= "000000000000000000000000";
         ELSIF ((dt_ep_last_eq_dt_size = '1') AND (cstate = MWR_DV_UPD_DT_4 )) THEN
            performance_counter <= "000000000000000000000000";
         ELSE
            IF ((requester_mrdmwr_cycle_xhdl0 = '1') OR (descriptor_mrd_cycle = '1')) THEN
               performance_counter <= performance_counter + "000000000000000000000001";
            ELSIF (tx_ws = '0') THEN
               performance_counter <= "000000000000000000000000";
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- tx_data_eplast
   -- Assume RC addr is Qword aligned
   -- 63:60 Design example version
   -- 59:58 Transaction layer mode
   -- When bit 57 set, indicates that the RC Slave module is being used
   -- 56     UNUSED
   -- 55:53  maxpayload for MWr
   -- 52:48  UNUSED
   -- 47:32 indicates the number of the last processed descriptor
   -- 31:24 Avalon width
   -- When 52:48  number of lanes negocatied
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_data_eplast(63 DOWNTO 60) <= CDMA_VERSION_4 ;
         tx_data_eplast(59 DOWNTO 58) <= TL_MODE_2 ;
         IF (USE_RCSLAVE = 0) THEN
            tx_data_eplast(57) <= '0';
         ELSE
            tx_data_eplast(57) <= '1';
         END IF;
         tx_data_eplast(56) <= '0';
         tx_data_eplast(55 DOWNTO 53) <= cfg_maxpload;
         tx_data_eplast(52 DOWNTO 49) <= "0000";
         tx_data_eplast(48) <= dt_fifo_empty;
         tx_data_eplast(47 DOWNTO 32) <= dt_ep_last;
         tx_data_eplast(31 DOWNTO 24) <= AVALON_WADDR_8 ;
         tx_data_eplast(23 DOWNTO 0) <= performance_counter;
      END IF;
   END PROCESS;

   -- tx_data_avalon
   -- Reevaluate address alignment at the start of every pkt for the programmed burst.  4Kboundary can re-align it.
   -- Address is non-128bit aligned
   -- start address is 128-bit address aligned
   xhdl14 <= '1' WHEN (tx_length_byte(3 DOWNTO 2) = "00") ELSE
                                  '0';
   -- start address is 1DW offset from 128-bit address, and payload is multiple of 128-bits
   xhdl15 <= '1' WHEN ((tx_length_byte(3 DOWNTO 2) = "00") OR (tx_length_byte(3 DOWNTO 2) = "11")) ELSE
                                  '0';
   -- start address is 2DW offset from 128-bit address, and payload is multiple of 128-bits, or odd by 3DW
   xhdl16 <= '1' WHEN ((tx_length_byte(3 DOWNTO 2) = "00") OR (tx_length_byte(3 DOWNTO 2) = "10") OR (tx_length_byte(3 DOWNTO 2) = "11")) ELSE
                                  '0';
   -- start address is 3DW offset from 128-bit address, and payload is multiple of 128-bits or odd by 3DW or odd by 2DW
   -- start address is 128-bit address aligned
   xhdl17 <= '1' WHEN (tx_length_byte(3 DOWNTO 2) = "00") ELSE
                                  '0';
   -- start address is 1DW offset from 128-bit address, and payload is multiple of 128-bits
   xhdl18 <= '1' WHEN ((tx_length_byte(3 DOWNTO 2) = "00") OR (tx_length_byte(3 DOWNTO 2) = "11")) ELSE
                                  '0';
   -- start address is 2DW offset from 128-bit address, and payload is multiple of 128-bits, or odd by 3DW
   xhdl19 <= '1' WHEN ((tx_length_byte(3 DOWNTO 2) = "00") OR (tx_length_byte(3 DOWNTO 2) = "10") OR (tx_length_byte(3 DOWNTO 2) = "11")) ELSE
                                  '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (DMA_QWORD_ALIGN = 1) THEN
            tx_data_dw0_msb <= '0';
         ELSE
            IF (cstate = DT_FIFO_4 ) THEN
               tx_data_dw0_msb <= '0';
            ELSE
               IF (cstate = MWR_REQ_4 ) THEN
                  IF (txadd_3dw = '1') THEN
                     CASE tx_desc_addr(35 DOWNTO 34) IS
                        WHEN "00" =>
                           tx_data_dw0_msb <= '0';
                        WHEN "01" =>
                           tx_data_dw0_msb <= xhdl14;
                        WHEN "10" =>
                           tx_data_dw0_msb <= xhdl15;
                        WHEN "11" =>
                           tx_data_dw0_msb <= xhdl16;
                        WHEN OTHERS =>
                           NULL;
                     END CASE;
                  ELSIF (txadd_3dw = '0') THEN
                     CASE tx_desc_addr(3 DOWNTO 2) IS
                        WHEN "00" =>
                           tx_data_dw0_msb <= '0';
                        WHEN "01" =>
                           tx_data_dw0_msb <= xhdl17;
                        WHEN "10" =>
                           tx_data_dw0_msb <= xhdl18;
                        -- start address is 3DW offset from 128-bit address, and payload is multiple of 128-bits or odd by 3DW or odd by 2DW
                        WHEN "11" =>
                           tx_data_dw0_msb <= xhdl19;
                        WHEN OTHERS =>
                           NULL;
                     END CASE;
                  ELSE
                     -- QWORD aligned
                     tx_data_dw0_msb <= '0';
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   tx_data_avalon <= readdata_m;

   readdata_m <= wr_fifo_q;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((xhdl_tx_dv = '0') OR (tx_data_dw0_msb = '0')) THEN
            readdata_m_next <= xhdl_zero_dword;
         ELSE
            readdata_m_next(31 DOWNTO 0) <= readdata_m(63 DOWNTO 32);
         END IF;
      END IF;
   END PROCESS;

   -- Avalon backend signaling to Avalon memory read
   --assign read    = ~max_wr_fifo_cnt;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate = DT_FIFO_4 ) OR (init = '1')) THEN
            epmem_read_cycle <= '0';
         ELSE
            IF (cstate = DT_FIFO_RD_QW1_4 ) THEN
               epmem_read_cycle <= '1';
            ELSIF (cstate = START_TX_UPD_DT_4 ) THEN
               epmem_read_cycle <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   wr_fifo_almost_full_level <= WR_FIFO_ALMST_FULL_2;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((init = '1') OR (wr_fifo_sclr = '1') OR (wr_fifo_empty = '1')) THEN
            wr_fifo_almost_full <= '0';
         ELSE
            IF (wr_fifo_usedw > wr_fifo_almost_full_level ) THEN
               wr_fifo_almost_full <= '1';
            ELSE
               wr_fifo_almost_full <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   read <= '1';
   read_int <= '1' WHEN (((cstate = DT_FIFO_RD_QW1_4 ) OR (epmem_read_cycle = '1')) AND (wr_fifo_almost_full = '0')) ELSE
               '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            address_reg <= "000000000000";
         ELSIF (cstate = DT_FIFO_RD_QW0_4 ) THEN
            -- Convert byte address to 128-bit address
            address_reg(AVALON_WADDR - 1 DOWNTO 0) <= dt_fifo_ep_addr_byte(AVALON_WADDR + 3 DOWNTO 4);
         ELSIF ((wr_fifo_full = '0') AND (read_int = '1')) THEN
            address_reg(AVALON_WADDR - 1 DOWNTO 0) <= address_reg(AVALON_WADDR - 1 DOWNTO 0) + "000000000001";
         END IF;
      END IF;
   END PROCESS;
   address <= address_reg;

   waitrequest <= '0';
   wr_fifo_data <= readdata;
   wr_fifo_sclr <= '1' WHEN ((init = '1') OR (cstate = DT_FIFO_4 )) ELSE
                   '0';
   wr_fifo_rdreq <= '1' WHEN ((tx_dfr_xhdl1 = '1') AND (tx_ws_val = '0') AND (inhibit_fifo_rd = '0') AND (wr_fifo_empty = '0') AND (ep_lastupd_cycle = '0')) ELSE
                    '0';

   wr_fifo_wrreq <= wrreq_d(2);
   -- wrreq_d is a delay on th write fifo buffer which reflects the
   -- memory latency
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((init = '1') OR (cstate = DT_FIFO_4 )) THEN
            wrreq_d <= "000000";
         ELSE
            wrreq_d(5) <= wrreq_d(4);
            wrreq_d(4) <= wrreq_d(3);
            wrreq_d(3) <= wrreq_d(2);
            wrreq_d(2) <= wrreq_d(1);
            wrreq_d(1) <= wrreq_d(0);
            wrreq_d(0) <= read_int;
         END IF;
      END IF;
   END PROCESS;

   addr_end(1 DOWNTO 0) <= (tx_desc_addr(35 DOWNTO 34) + tx_length_dw(1 DOWNTO 0)) WHEN (txadd_3dw = '1') ELSE
                           (tx_desc_addr(3 DOWNTO 2) + tx_length_dw(1 DOWNTO 0));


   xhdl20 <= '1' WHEN (addr_end(1 DOWNTO 0) = "00") ELSE        --
                           '0';
   xhdl21 <= addr_ends_on128bit_bound WHEN (cstate = DONE_4 ) ELSE
                           last_addr_ended_on128bit_bound;
   PROCESS (clk_in, rstn)
   BEGIN
      IF (rstn = '0') THEN
         addr_ends_on128bit_bound <= '1';
         last_addr_ended_on128bit_bound <= '1';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         addr_ends_on128bit_bound <= xhdl20;
         last_addr_ended_on128bit_bound <= xhdl21;
      END IF;
   END PROCESS;

   -- requester_mrdmwr_cycle signal is used to enable the
   -- performance counter
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            requester_mrdmwr_cycle_xhdl0 <= '0';
         ELSE
            IF ((dt_fifo_empty = '0') AND (cstate = DT_FIFO_4 )) THEN
               requester_mrdmwr_cycle_xhdl0 <= '1';
            ELSE
               IF ((dt_fifo_empty = '1') AND (cstate = MWR_REQ_UPD_DT_4 ) AND (tx_ws = '0')) THEN
                  requester_mrdmwr_cycle_xhdl0 <= '0';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate = MWR_REQ_4 ) THEN
            IF ((tx_dfr_ow_counter = tx_length_ow_minus_one) AND (tx_ws = '0')) THEN
               tx_dv_gone <= '1';
            END IF;
         ELSE
            tx_dv_gone <= '0';
         END IF;
      END IF;
   END PROCESS;

   inhibit_fifo_rd_n <= '0' WHEN ((cstate = DONE_4 ) AND (xhdl_tx_dv = '0') AND (cdt_length_dw /= "0000000000000000") AND (addr_ends_on128bit_bound = '1')) ELSE
                        '1' WHEN ((cstate = DONE_4 ) AND (xhdl_tx_dv = '0') AND (cdt_length_dw /= "0000000000000000") AND (addr_ends_on128bit_bound = '0')) ELSE
                        '0' WHEN ((cstate = TX_DONE_WS_4 ) AND (init = '0') AND (tx_dv_ws_wait = '0') AND (cdt_length_dw /= "0000000000000000") AND (last_addr_ended_on128bit_bound = '1')) ELSE
                        '1' WHEN ((cstate = TX_DONE_WS_4 ) AND (init = '0') AND (tx_dv_ws_wait = '0') AND (cdt_length_dw /= "0000000000000000") AND (last_addr_ended_on128bit_bound = '0')) ELSE
                        '0' WHEN ((tx_dfr_xhdl1 = '1') AND (tx_ws_val = '0')) ELSE
                        inhibit_fifo_rd;

   -- Requester state machine
   --    Combinatorial state transition (case state)
   PROCESS (cstate, cstate_msi, dt_fifo_empty, init, cdt_length_dw, tx_sel, wr_fifo_ready_to_read, tx_ready_dmard, tx_ack, tx_dv_gone, tx_dfr_ow_counter, tx_length_ow_minus_one, tx_ws, xhdl_tx_dv, cdt_eplast_ena, tx_dv_ws_wait)
   BEGIN
      CASE cstate IS

         WHEN DT_FIFO_4  =>
            IF ((dt_fifo_empty = '0') AND (init = '0')) THEN
               nstate <= DT_FIFO_RD_QW0_4 ;
            ELSE
               nstate <= DT_FIFO_4 ;
            END IF;

         WHEN DT_FIFO_RD_QW0_4  =>
            IF (dt_fifo_empty = '0') THEN
               nstate <= DT_FIFO_RD_QW1_4 ;
            ELSE
               nstate <= DT_FIFO_RD_QW0_4 ;
            END IF;

         WHEN DT_FIFO_RD_QW1_4  =>
            IF (cstate_msi=IDLE_MSI_3) THEN
                nstate <= TX_LENGTH_4 ;
            ELSE
               nstate <= DT_FIFO_RD_QW1_4 ;
            END IF;

         WHEN TX_LENGTH_4  =>
            IF (cdt_length_dw = "0000000000000000") THEN
               nstate <= DT_FIFO_4 ;
            ELSE
               nstate <= START_TX_4 ;
            END IF;
         -- Waiting for Top level arbitration (tx_sel) prior to tx MEM64_WR

         WHEN START_TX_4  =>      -- Read Request Assert tx_req
            IF (init = '1') THEN
               nstate <= DT_FIFO_4 ;
            ELSIF ((tx_sel = '1') AND (wr_fifo_ready_to_read = '1') AND (tx_ready_dmard = '0')) THEN
               nstate <= MWR_REQ_4 ;
            ELSE
               nstate <= START_TX_4 ;
            END IF;
         -- Set tx_req, Waiting for tx_ack

         WHEN MWR_REQ_4  =>       -- Read Request Ack. tx_ack
            IF (init = '1') THEN
               nstate <= DT_FIFO_4 ;
            ELSIF (tx_ack = '1') THEN
               nstate <= MWR_DV_4 ;
            ELSE
               nstate <= MWR_REQ_4 ;
            END IF;
         -- Received tx_ack, clear tx_req, completing data phase

         WHEN MWR_DV_4  =>
            IF (tx_dv_gone = '1') THEN
               nstate <= DONE_4 ;
            ELSIF ((tx_dfr_ow_counter = tx_length_ow_minus_one) AND (tx_ws = '0')) THEN
               nstate <= DONE_4 ;
            ELSE
               nstate <= MWR_DV_4 ;
            END IF;

         WHEN DONE_4  =>
            IF ((xhdl_tx_dv = '1') AND (tx_ws = '1')) THEN
               nstate <= TX_DONE_WS_4 ;
            ELSE
               IF (cdt_length_dw = "0000000000000000") THEN
                  IF (cdt_eplast_ena = '1') THEN
                     nstate <= START_TX_UPD_DT_4 ;
                  ELSE
                     nstate <= DT_FIFO_4 ;
                  END IF;
               ELSE
                  IF (tx_ready_dmard = '0') THEN
                     nstate <= MWR_REQ_4 ;
                  ELSE
                     nstate <= START_TX_4 ;
                  END IF;
               END IF;
            END IF;
         -- Update RC Memory for polling info

         WHEN TX_DONE_WS_4  =>
            IF (init = '1') THEN
               nstate <= DT_FIFO_4 ;
            ELSIF (tx_dv_ws_wait = '1') THEN
               nstate <= TX_DONE_WS_4 ;
            ELSE
               IF (cdt_length_dw = "0000000000000000") THEN
                  IF (cdt_eplast_ena = '1') THEN
                     nstate <= START_TX_UPD_DT_4 ;
                  ELSE
                     nstate <= MWR_DV_UPD_DT_4 ;
                  END IF;
               ELSE
                  IF (tx_ready_dmard = '0') THEN
                     nstate <= MWR_REQ_4 ;
                  ELSE
                     nstate <= START_TX_4 ;
                  END IF;
               END IF;
            END IF;
         -- Waiting for Top level arbitration (tx_sel) prior to tx MEM64_WR

         WHEN START_TX_UPD_DT_4  =>
            IF (init = '1') THEN
               nstate <= DT_FIFO_4 ;
            ELSE
               nstate <= MWR_REQ_UPD_DT_4 ;
            END IF;
         -- Set tx_req, Waiting for tx_ack

         WHEN MWR_REQ_UPD_DT_4  =>
            IF (init = '1') THEN
               nstate <= DT_FIFO_4 ;
            ELSIF (tx_ack = '1') THEN
               nstate <= MWR_DV_UPD_DT_4 ;
            ELSE
               nstate <= MWR_REQ_UPD_DT_4 ;
            END IF;
         -- Received tx_ack, clear tx_req

         WHEN MWR_DV_UPD_DT_4  =>
            IF ((tx_ws = '0') OR (xhdl_tx_dv = '0')) THEN
                nstate <= DT_FIFO_4 ;
            ELSE
                nstate <= MWR_DV_UPD_DT_4;
            END IF;
         WHEN OTHERS =>
            nstate <= DT_FIFO_4 ;
      END CASE;
   END PROCESS;

   -- Requester state machine
   --    Registered state state transition
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate <= DT_FIFO_4 ;
         inhibit_fifo_rd <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate <= nstate;
         inhibit_fifo_rd <= inhibit_fifo_rd_n;
      END IF;
   END PROCESS;

   --
   -- write_scfifo is used as a buffer between the EP memory and tx_data
   --


   write_scfifo : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => WR_FIFO_NUMWORDS,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => AVALON_WDATA,
         lpm_widthu               => WR_FIFO_WIDTHU,
         overflow_checking        => "OFF",
         underflow_checking       => "OFF",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => wr_fifo_sclr,
         data   => wr_fifo_data,
         wrreq  => wr_fifo_wrreq,
         rdreq  => wr_fifo_rdreq,
         q      => wr_fifo_q,
         usedw  => wr_fifo_usedw,
         empty  => wr_fifo_empty,
         full   => wr_fifo_full
      );

   --/////////////////////////////////////////////////////////////////////////
   --
   -- MSI section
   --
   app_msi_req <= '0' WHEN (USE_MSI = 0) ELSE
                  '1' WHEN (cstate_msi = MWR_REQ_MSI_3 ) ELSE
                  '0';
   msi_ready_sg <= '0' WHEN (USE_MSI = 0) ELSE
                '1' WHEN (cstate_msi = START_MSI_3 ) ELSE
                '0';
   msi_busy_sg <= '0' WHEN (USE_MSI = 0) ELSE
               '1' WHEN (cstate_msi = MWR_REQ_MSI_3 ) ELSE
               '0';
   msi_busy    <= msi_busy_sg;
   msi_ready   <= msi_ready_sg;

   PROCESS (cstate_msi, cstate, cdt_length_dw, cdt_msi, msi_sel, app_msi_ack, tx_ws)
   BEGIN
      CASE cstate_msi IS

         WHEN "000"  =>
         --WHEN IDLE_MSI_3  =>
            IF ((cstate = DONE_4 ) AND (cdt_length_dw = "0000000000000000") AND (cdt_msi = '1')) THEN
               nstate_msi <= START_MSI_3 ;
            ELSE
               nstate_msi <= IDLE_MSI_3 ;
            END IF;
         -- Waiting for Top level arbitration (tx_sel) prior to tx MEM64_WR

         WHEN "001"  =>
         --WHEN START_MSI_3  =>
            IF (msi_sel = '1') AND (tx_ws = '0') THEN
               nstate_msi <= MWR_REQ_MSI_3 ;
            ELSE
               nstate_msi <= START_MSI_3 ;
            END IF;
         -- Set tx_req, Waiting for tx_ack

         WHEN "010"  =>
         --WHEN MWR_REQ_MSI_3  =>
            IF (app_msi_ack = '1') THEN
               nstate_msi <= IDLE_MSI_3 ;
            ELSE
               nstate_msi <= MWR_REQ_MSI_3 ;
            END IF;
         WHEN OTHERS =>
            nstate_msi <= IDLE_MSI_3 ;
      END CASE;
   END PROCESS;

   -- MSI state machine
   --    Registered state state transition
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate_msi <= IDLE_MSI_3 ;
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate_msi <= nstate_msi;
      END IF;
   END PROCESS;

END ARCHITECTURE altpcie;
--
-- END MSI section
--
--///////////////////////////////////////////////////////////////////////////
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY add_sub_128_write_req IS
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
END add_sub_128_write_req;


ARCHITECTURE SYN OF add_sub_128_write_req IS

    SIGNAL sub_wire0    : STD_LOGIC_VECTOR (63 DOWNTO 0);
    SIGNAL sub_wire1_bv : BIT_VECTOR (63 DOWNTO 0);
    SIGNAL sub_wire1    : STD_LOGIC_VECTOR (63 DOWNTO 0);



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
    sub_wire1_bv(63 DOWNTO 0) <= "0000000000000000000000000000000000000000000000000000000000001000";
    sub_wire1    <= To_stdlogicvector(sub_wire1_bv);
    result    <= sub_wire0(63 DOWNTO 0);

    lpm_add_sub_component : lpm_add_sub
    GENERIC MAP (
        lpm_direction => "ADD",
        lpm_hint => "ONE_INPUT_IS_CONSTANT=YES,CIN_USED=NO",
        lpm_pipeline => 2,
        lpm_representation => "UNSIGNED",
        lpm_type => "LPM_ADD_SUB",
        lpm_width => 64
    )
    PORT MAP (
        dataa => dataa,
        datab => sub_wire1,
        clock => clock,
        result => sub_wire0
    );



END SYN;

