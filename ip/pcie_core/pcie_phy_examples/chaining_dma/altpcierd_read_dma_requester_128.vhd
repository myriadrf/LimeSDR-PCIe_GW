LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in
--  * the chaining DMA design example. It manages DMA read data transfer from
--  * the Root Complex memory to the End Point memory.
--  */
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : DMA Read requestor module (altpcierd_read_dma_requester_128)
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_read_dma_requester.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
--
-- - Retrieve descriptor info from the dt_fifo (module read descriptor)
--       states : cstate_tx = DT_FIFO_RD_QW0, DT_FIFO_RD_QW1
--       cdt_length_dw_tx : number of DWORDs to transfer
-- - For each descriptor:
--       - Send multiple Mrd request for a max payload
--            tx_length=< cdt_length_dw_tx
--       - Each Tx MRd has TAG starting from 2--> MAX_NUMTAG.
--            A counter issue the TAG up to MAX_NUMTAG; When MAX_NUMTAG
--            the TAG are pop-ed from the TAG FIFO.
--            when Rx received packet (CPLD), the TAG is recycled (pushed)
--            into the TAG_FIFO if the completion of tx_length in TAG RAM
--
-- - RAM : tag_dpram  :
--      hash table which tracks TAG information
--      Port A : is used by the TX code section
--        data_a    = {tx_length_dw[9:1], tx_tag_addr_offset_qw[AVALON_WADDR-1:0]};
--      Port B : is used by the RX code section
--        data_b    = {rx_length_dw[9:1], tx_tag_addr_offset_qw[AVALON_WADDR-1:0]};
--        q         =
-- - FIFO : tag_scfifo  :
--      contains the list of TAG which can be re-used by the TX code section
--      The RX code section updates this FIFO by writting recycled TAG upon
--      completion
--
-- - FIFO : rx_data_fifo  :
--      is used by the RX code section to eliminates RX_WS and increase
--      DMA read throughput.
--
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
ENTITY altpcierd_read_dma_requester_128 IS
   GENERIC (
      MAX_NUMTAG                                                  : INTEGER := 32;
      USE_RCSLAVE                                                 : INTEGER := 1;
      RC_SLAVE_USETAG                                             : INTEGER := 0;
      FIFO_WIDTH                                                  : INTEGER := 128;
      TXCRED_WIDTH                                                : INTEGER := 36;
      AVALON_WADDR                                                : INTEGER := 12;
      AVALON_WDATA                                                : INTEGER := 128;
      BOARD_DEMO                                                  : INTEGER := 0;
      USE_MSI                                                     : INTEGER := 1;
      USE_CREDIT_CTRL                                             : INTEGER := 1;
      RC_64BITS_ADDR                                              : INTEGER := 0;
      AVALON_BYTE_WIDTH                                           : INTEGER := 16;
      DT_EP_ADDR_SPEC                                             : INTEGER := 2;
      CDMA_AST_RXWS_LATENCY                                       : INTEGER := 2

      -- Descriptor control signals

      --PCIe transmit

      --PCIe receive

      -- MSI

      --avalon slave port

      -- RC Slave control signals

      -- VHDL translation_on
      --
      -- VHDL translation_off

   );
   PORT (
      dt_fifo_rdreq                                               : OUT STD_LOGIC;
      dt_fifo_empty                                               : IN STD_LOGIC;
      dt_fifo_q                                                   : IN STD_LOGIC_VECTOR(FIFO_WIDTH - 1 DOWNTO 0);
      cfg_maxrdreq_dw                                             : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cfg_maxrdreq                                                : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      cfg_link_negociated                                         : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      dt_base_rc                                                  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      dt_3dw_rcadd                                                : IN STD_LOGIC;
      dt_eplast_ena                                               : IN STD_LOGIC;
      dt_msi                                                      : IN STD_LOGIC;
      dt_size                                                     : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      tx_ready                                                    : OUT STD_LOGIC;
      tx_busy                                                     : OUT STD_LOGIC;
      tx_sel                                                      : IN STD_LOGIC;
      tx_cred                                                     : IN STD_LOGIC_VECTOR(TXCRED_WIDTH - 1 DOWNTO 0);
      tx_ack                                                      : IN STD_LOGIC;
      tx_ws                                                       : IN STD_LOGIC;
      tx_req                                                      : OUT STD_LOGIC;
      tx_dv                                                       : OUT STD_LOGIC;
      tx_dfr                                                      : OUT STD_LOGIC;
      tx_desc                                                     : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_data                                                     : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      rx_buffer_cpl_max_dw                                        : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_req                                                      : IN STD_LOGIC;
      rx_ack                                                      : OUT STD_LOGIC;
      rx_desc                                                     : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                                                     : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      rx_be                                                       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_dv                                                       : IN STD_LOGIC;
      rx_dfr                                                      : IN STD_LOGIC;
      rx_ws                                                       : OUT STD_LOGIC;
      app_msi_ack                                                 : IN STD_LOGIC;
      app_msi_req                                                 : OUT STD_LOGIC;
      msi_sel                                                     : IN STD_LOGIC;
      msi_ready                                                   : OUT STD_LOGIC;
      msi_busy                                                    : OUT STD_LOGIC;
      writedata                                                   : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      address                                                     : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      write                                                       : OUT STD_LOGIC;
      waitrequest                                                 : OUT STD_LOGIC;
      write_byteena                                               : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
      descriptor_mrd_cycle                                        : IN STD_LOGIC;
      requester_mrdmwr_cycle                                      : OUT STD_LOGIC;
      dma_sm_tx                                                   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_sm_rx                                                   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      dma_sm_rx_data                                              : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      dma_status                                                  : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      cpl_pending                                                 : OUT STD_LOGIC;
      init                                                        : IN STD_LOGIC;
      clk_in                                                      : IN STD_LOGIC;
      rstn                                                        : IN STD_LOGIC
   );
END ENTITY altpcierd_read_dma_requester_128;
ARCHITECTURE altpcie OF altpcierd_read_dma_requester_128 IS


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



   FUNCTION get_numwords (
      val      : integer) RETURN integer IS

      VARIABLE rtn      : integer:=1;
   BEGIN
        rtn:=1    ;
        FOR i IN 1 TO val LOOP
            rtn := 2*rtn;
        END loop;
        RETURN rtn;
   END get_numwords;



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

   CONSTANT       DT_FIFO                                                     : INTEGER := 0;       -- Ready for next Descriptor FIFO (DT)

   CONSTANT       CPLD_IDLE                                                   : INTEGER := 0;
   CONSTANT       CPLD_REQ                                                    : INTEGER := 1;
   CONSTANT       CPLD_ACK                                                    : INTEGER := 2;
   CONSTANT       CPLD_DV                                                     : INTEGER := 3;
   CONSTANT       CPLD_LAST                                                   : INTEGER := 4;


   CONSTANT       SM_RX_DATA_FIFO_IDLE                                        : INTEGER := 0;
   CONSTANT       SM_RX_DATA_FIFO_READ_TAGRAM_1                               : INTEGER := 1;
   CONSTANT       SM_RX_DATA_FIFO_READ_TAGRAM_2                               : INTEGER := 2;
   CONSTANT       SM_RX_DATA_FIFO_RREQ                                        : INTEGER := 3;
   CONSTANT       SM_RX_DATA_FIFO_SINGLE_QWORD                                : INTEGER := 4;
   CONSTANT       SM_RX_DATA_FIFO_TAGRAM_UPD                                  : INTEGER := 5;

   CONSTANT       IDLE_MSI                                                    : INTEGER := 0;       -- MSI Stand by
   CONSTANT       START_MSI                                                   : INTEGER := 1;
   CONSTANT       MWR_REQ_MSI                                                 : INTEGER := 2;
   CONSTANT       DATA_WIDTH_DWORD                                            : INTEGER := AVALON_WDATA / 32;
   CONSTANT       ZERO_INTEGER                                                : INTEGER := 0;
   CONSTANT       ONE_INTEGER                                                 : INTEGER := 1;
   CONSTANT       TWO_INTEGER                                                 : INTEGER := 2;
   CONSTANT       SIXTYFOUR_INTEGER                                           : INTEGER := 64;
   CONSTANT       MAX_NUMTAG_VAL                                              : INTEGER := MAX_NUMTAG - 1;
   CONSTANT       MAX_NUMTAG_VAL_SETVHDLWIDTH_MAX_TAG_WIDTH                   : INTEGER := MAX_NUMTAG_VAL;
   CONSTANT       FIRST_DMARD_TAG                                             : INTEGER := 2 + RC_SLAVE_USETAG;
   CONSTANT       FIRST_DMARD_TAG_SETVHDLWIDTH_MAX_TAG_WIDTH                  : INTEGER := FIRST_DMARD_TAG;
   CONSTANT       FIRST_DMARD_TAG_SEC_DESCRIPTOR                              : INTEGER := ((MAX_NUMTAG - FIRST_DMARD_TAG) / 2) + FIRST_DMARD_TAG;
   CONSTANT       FIRST_DMARD_TAG_SEC_DESCRIPTOR_SETVHDLWIDTH_MAX_TAG_WIDTH   : INTEGER := FIRST_DMARD_TAG_SEC_DESCRIPTOR;
   CONSTANT       MAX_NUMTAG_VAL_FIRST_DESCRIPTOR                             : INTEGER := FIRST_DMARD_TAG_SEC_DESCRIPTOR - 1;
   CONSTANT       MAX_NUMTAG_VAL_FIRST_DESCRIPTOR_SETVHDLWIDTH_MAX_TAG_WIDTH  : INTEGER := MAX_NUMTAG_VAL_FIRST_DESCRIPTOR;
   CONSTANT       TAG_TRACK_WIDTH                                             : INTEGER := MAX_NUMTAG - 2 - RC_SLAVE_USETAG;
   CONSTANT       TAG_TRACK_HALF_WIDTH                                        : INTEGER := TAG_TRACK_WIDTH / 2;
   CONSTANT       TAG_FIFO_DEPTH                                              : INTEGER := MAX_NUMTAG - 2;
   CONSTANT       MAX_TAG_WIDTH                                               : INTEGER :=  ceil_log2(MAX_NUMTAG);
   CONSTANT       MAX_TAG_WIDTHU                                              : INTEGER :=  ceil_log2(TAG_FIFO_DEPTH);
   CONSTANT       LENGTH_DW_WIDTH                                             : INTEGER := 10;
   CONSTANT       LENGTH_QW_WIDTH                                             : INTEGER := 9;
   CONSTANT       TAG_EP_ADDR_WIDTH                                           : INTEGER := (AVALON_WADDR + 4);
   CONSTANT       TAG_RAM_WIDTH                                               : INTEGER := LENGTH_DW_WIDTH + TAG_EP_ADDR_WIDTH;
   CONSTANT       TAG_RAM_WIDTHAD                                             : INTEGER := MAX_TAG_WIDTH;
   CONSTANT       TAG_RAM_NUMWORDS                                            : INTEGER := get_numwords(TAG_RAM_WIDTHAD);
   CONSTANT       RX_DATA_FIFO_NUMWORDS                                       : INTEGER := 64;
   CONSTANT       RX_DATA_FIFO_WIDTHU                                         : INTEGER := 6;
   CONSTANT       RX_DATA_FIFO_ALMST_FULL_LIM                                 : INTEGER := RX_DATA_FIFO_NUMWORDS - 6;
   CONSTANT       RX_DATA_FIFO_WIDTH                                          : INTEGER := AVALON_WDATA + 2 + MAX_TAG_WIDTH + 16;

type CSTATE_TX_TYPE is (DT_FIFO_4, DT_FIFO_RD_QW0_4, DT_FIFO_RD_QW1_4, MAX_RREQ_UPD_4, TX_LENGTH_4, START_TX_4, MRD_REQ_4, MRD_ACK_4, GET_TAG_4, CPLD_4, DONE_4, START_TX_UPD_DT_4, MWR_REQ_UPD_DT_4, MWR_ACK_UPD_DT_4);


type CSTATE_RX_TYPE is   (DT_FIFO_3,CPLD_IDLE_3,CPLD_REQ_3,CPLD_ACK_3,CPLD_DV_3,CPLD_LAST_3);


CONSTANT BOARD_DEMO_7 : std_logic_vector(7-1 downto 0):=to_stdlogicvector(BOARD_DEMO,7);
   CONSTANT MAX_NUMTAG_8 : std_logic_vector(8-1 downto 0):=to_stdlogicvector(MAX_NUMTAG,8);

   CONSTANT FIRST_DMARD_TAG_8 : std_logic_vector(8-1 downto 0):=to_stdlogicvector(FIRST_DMARD_TAG,8);
   CONSTANT SM_RX_DATA_FIFO_READ_TAGRAM_2_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SM_RX_DATA_FIFO_READ_TAGRAM_2,3);
   CONSTANT RX_DATA_FIFO_ALMST_FULL_LIM_6 : std_logic_vector(6-1 downto 0):=to_stdlogicvector(RX_DATA_FIFO_ALMST_FULL_LIM,6);
   CONSTANT SM_RX_DATA_FIFO_READ_TAGRAM_1_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SM_RX_DATA_FIFO_READ_TAGRAM_1,3);
   CONSTANT SM_RX_DATA_FIFO_RREQ_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SM_RX_DATA_FIFO_RREQ,3);
   CONSTANT SM_RX_DATA_FIFO_SINGLE_QWORD_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SM_RX_DATA_FIFO_SINGLE_QWORD,3);
   CONSTANT DATA_WIDTH_DWORD_10 : std_logic_vector(10-1 downto 0):=to_stdlogicvector(DATA_WIDTH_DWORD,10);
   CONSTANT SM_RX_DATA_FIFO_IDLE_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SM_RX_DATA_FIFO_IDLE,3);
   CONSTANT SM_RX_DATA_FIFO_TAGRAM_UPD_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SM_RX_DATA_FIFO_TAGRAM_UPD,3);
   CONSTANT MWR_REQ_MSI_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(MWR_REQ_MSI,3);
   CONSTANT START_MSI_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(START_MSI,3);
   CONSTANT IDLE_MSI_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(IDLE_MSI,3);
   CONSTANT FIRST_DMARD_TAG_MAX_TAG_WIDTH : std_logic_vector(MAX_TAG_WIDTH-1 downto 0):=to_stdlogicvector(FIRST_DMARD_TAG,MAX_TAG_WIDTH);
   CONSTANT MAX_NUMTAG_VAL_FIRST_DESCRIPTOR_MAX_TAG_WIDTH : std_logic_vector(MAX_TAG_WIDTH-1 downto 0):=to_stdlogicvector(MAX_NUMTAG_VAL_FIRST_DESCRIPTOR,MAX_TAG_WIDTH);
   CONSTANT FIRST_DMARD_TAG_SEC_DESCRIPTOR_MAX_TAG_WIDTH : std_logic_vector(MAX_TAG_WIDTH-1 downto 0):=to_stdlogicvector(FIRST_DMARD_TAG_SEC_DESCRIPTOR,MAX_TAG_WIDTH);
   CONSTANT MAX_NUMTAG_VAL_MAX_TAG_WIDTH : std_logic_vector(MAX_TAG_WIDTH-1 downto 0):=to_stdlogicvector(MAX_NUMTAG_VAL,MAX_TAG_WIDTH);


   COMPONENT add_sub_dmard128_cst
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
   END COMPONENT;

   COMPONENT add_sub_dmard128
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        datab       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
   END COMPONENT;

   SIGNAL i                                  : INTEGER;

   -- State machine registers for transmit MRd MWr (tx)
   SIGNAL cstate_tx                          : CSTATE_TX_TYPE;
   SIGNAL nstate_tx                          : CSTATE_TX_TYPE;
   SIGNAL tx_mrd_cycle                       : STD_LOGIC;

   -- State machine registers for Receive CPLD (rx)
   SIGNAL cstate_rx                          : CSTATE_RX_TYPE;
   SIGNAL nstate_rx                          : CSTATE_RX_TYPE;

   --
   SIGNAL cstate_rx_data_fifo                : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL nstate_rx_data_fifo                : STD_LOGIC_VECTOR(2 DOWNTO 0);

   -- MSI State machine registers
   -- MSI could be send in parallel to EPLast
   SIGNAL cstate_msi                         : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL nstate_msi                         : STD_LOGIC_VECTOR(2 DOWNTO 0);

   -- control bits : set when ep_lastup transmit
   SIGNAL ep_lastupd_cycle                   : STD_LOGIC;

   SIGNAL rx_ws_ast                          : STD_LOGIC_VECTOR(2 DOWNTO 0);        --rx_ws from Avalon ST
   SIGNAL rx_ast_data_valid                  : STD_LOGIC;       --rx_ws from Avalon ST
   -- Control counter for payload and dma length

   SIGNAL cdt_length_dw_tx                   : STD_LOGIC_VECTOR(15 DOWNTO 0);       -- cdt : length of the transfer (in DWORD)
   -- for the current descriptor. This counter
   -- is used for tx (Mrd)

   SIGNAL cfg_maxrdreq_byte                  : STD_LOGIC_VECTOR(12 DOWNTO 0);       -- Max read request in bytes
   SIGNAL calc_4kbnd_mrd_ack_byte            : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL calc_4kbnd_dt_fifo_byte            : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL calc_4kbnd_mrd_ack_dw              : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL calc_4kbnd_dt_fifo_dw              : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL tx_desc_addr_4k                    : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL dt_fifo_q_addr_4k                  : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL maxrdreq_dw                        : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL tx_length_dw                       : STD_LOGIC_VECTOR(9 DOWNTO 0);        -- length of tx_PCIE transfer in DWORD
   -- tx_desc[105:96] = tx_length_dw when tx_req

   SIGNAL tx_length_byte                     : STD_LOGIC_VECTOR(11 DOWNTO 0);       -- length of tx_PCIE transfer in BYTE
   -- tx_desc[105:96] = tx_length_dw when tx_req
   SIGNAL tx_length_byte_32ext               : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_length_byte_64ext               : STD_LOGIC_VECTOR(63 DOWNTO 0);

   -- control bits : check 32 bit vs 64 bit address
   SIGNAL txadd_3dw                          : STD_LOGIC;

   -- control bits : generate tx_dfr & tx_dv
   SIGNAL tx_req_reg                         : STD_LOGIC;
   SIGNAL tx_req_delay                       : STD_LOGIC;

   -- DMA registers
   SIGNAL cdt_msi                            : STD_LOGIC;       -- When set, send MSI to RC host
   SIGNAL cdt_eplast_ena                     : STD_LOGIC;       -- When set, update RC Host memory with dt_ep_last
   SIGNAL dt_ep_last                         : STD_LOGIC_VECTOR(15 DOWNTO 0);       -- Number of descriptors completed

   -- PCIe Signals RC address
   SIGNAL tx_tag_wire_mux_first_descriptor   : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tx_tag_wire_mux_second_descriptor  : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tx_get_tag_from_fifo               : STD_LOGIC;
   SIGNAL tx_tag_tx_desc                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_desc_addr                       : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL addrval_32b                        : STD_LOGIC; -- Indicates that a 64-bit address has upper dword equal to zero
   SIGNAL tx_desc_addr_pipe                  : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_desc_addr_3dw_pipe              : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_addr_eplast                     : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_addr_eplast_pipe                : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_32addr_eplast                   : STD_LOGIC;
   SIGNAL tx_data_eplast                     : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL tx_lbe_d                           : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL tx_fbe_d                           : STD_LOGIC_VECTOR(3 DOWNTO 0);

   -- tx_credit controls
   SIGNAL tx_cred_non_posted_header_valid    : STD_LOGIC;
   SIGNAL tx_cred_non_posted_header_valid_x8 : STD_LOGIC;
   SIGNAL tx_cred_posted_data_valid_8x       : STD_LOGIC;
   SIGNAL tx_cred_posted_data_valid_4x       : STD_LOGIC;
   SIGNAL tx_cred_posted_data_valid          : STD_LOGIC;
   SIGNAL rx_buffer_cpl_ready                : STD_LOGIC;
   SIGNAL rx_tag_is_sec_desc                 : STD_LOGIC;

   SIGNAL dt_ep_last_eq_dt_size : STD_LOGIC;

   --
   -- TAG management overview:
   --
   --     TAG 8'h00            : Descriptor read
   --     TAG 8'h01            : Descriptor write
   --     TAG 8'h02 -> MAX TAG : Requester read
   --
   --     TX issues MRd, with TAG "xyz" and length "tx_length" dword data
   --     RX ack CPLD with TAG "xyz", and length "rx_length" dword daata
   --
   --     The TX state machine write a new TAG for every MRd on port A of
   --     tag_dpram
   --     The RX state machine uses the port B of tag_dpram
   --        When cstate_rx==CPLD_REQ --> Read tag_dpram word with "tx_length"
   --        info.
   --        When (cstate_rx==CPLD_DV)||(cstate_rx==CPLD_LAST) write tag_dpram
   --        to reflect the number of dword read for a given TAG
   --     If  "tx_length" == "rx_length" the TAG is recycled in the tag_scfifo

   SIGNAL tx_tag_cnt_first_descriptor        : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tx_tag_cnt_second_descriptor       : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL rx_tag                             : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);

   SIGNAL tx_tag_mux_first_descriptor        : STD_LOGIC;
   SIGNAL tx_tag_mux_second_descriptor       : STD_LOGIC;

   -- tag_scfifo:
   --    The tx_state machine read data
   --    The rx_statemachine pushes data
   SIGNAL tag_fifo_sclr                      : STD_LOGIC;
   SIGNAL rx_second_descriptor_tag           : STD_LOGIC;
   SIGNAL rx_fifo_wrreq_first_descriptor     : STD_LOGIC;
   SIGNAL rx_fifo_wrreq_second_descriptor    : STD_LOGIC;
   SIGNAL tagram_wren_b_mrd_ack              : STD_LOGIC;
   SIGNAL tx_fifo_rdreq_first_descriptor     : STD_LOGIC;
   SIGNAL tx_fifo_rdreq_second_descriptor    : STD_LOGIC;
   SIGNAL tx_tag_fifo_first_descriptor       : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tx_tag_fifo_second_descriptor      : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tag_fifo_empty_first_descriptor    : STD_LOGIC;
   SIGNAL tag_fifo_empty_second_descriptor   : STD_LOGIC;
   SIGNAL tag_fifo_full_first_descriptor     : STD_LOGIC;
   SIGNAL tag_fifo_full_second_descriptor    : STD_LOGIC;

   SIGNAL rx_dmard_tag                       : STD_LOGIC;       --set when rx_desc tag >FIRST_DMARD_TAG
   SIGNAL rx_dmard_cpld                      : STD_LOGIC;
   SIGNAL valid_rx_dmard_cpld_next           : STD_LOGIC;
   SIGNAL valid_rx_dv_for_dmard              : STD_LOGIC;
   SIGNAL valid_rx_dmard_cpld                : STD_LOGIC;       --set when
   --  -- the second phase of rx_req,
   --  + Valid tag
   --  + Valid first phase of rx_req (CPLD and rx_dfr)

   -- Constant used for VHDL translation
   SIGNAL cst_one                            : STD_LOGIC;
   SIGNAL cst_zero                           : STD_LOGIC;

   -- tag_dpram:
   --    data : tx_length_dw[9:1]      :QWORD LENGTH to know when recycle TAG
   --          tx_tag_addr_offset_qw[AVALON_WADDR-1:0]:EP Address offset (where PCIE write to)
   --          {tx_length_dw[9:1], tx_tag_addr_offset_qw[AVALON_WADDR-1:0]}
   --    Address : TAG
   SIGNAL tagram_wren_a                      : STD_LOGIC;
   SIGNAL tagram_data_a                      : STD_LOGIC_VECTOR(TAG_RAM_WIDTH - 1 DOWNTO 0);
   SIGNAL tagram_address_a                   : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);

   SIGNAL tagram_wren_b                      : STD_LOGIC;
   SIGNAL tagram_wren_b_reg_init             : STD_LOGIC;
   SIGNAL tagram_data_b                      : STD_LOGIC_VECTOR(TAG_RAM_WIDTH - 1 DOWNTO 0);
   SIGNAL tagram_address_b                   : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tagram_address_b_mrd_ack           : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);
   SIGNAL tagram_q_b                         : STD_LOGIC_VECTOR(TAG_RAM_WIDTH - 1 DOWNTO 0);

   SIGNAL rx_tag_length_dw                   : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL rx_tag_addr_offset                 : STD_LOGIC_VECTOR(TAG_EP_ADDR_WIDTH - 1 DOWNTO 0);
   SIGNAL rx_tag_length_dw_next              : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL rx_tag_addr_offset_next            : STD_LOGIC_VECTOR(TAG_EP_ADDR_WIDTH - 1 DOWNTO 0);

   SIGNAL tx_first_descriptor_cycle          : STD_LOGIC;
   SIGNAL eplast_upd_first_descriptor        : STD_LOGIC;
   SIGNAL next_is_second                     : STD_LOGIC;
   SIGNAL eplast_upd_second_descriptor       : STD_LOGIC;
   SIGNAL tx_cpld_first_descriptor           : STD_LOGIC;
   SIGNAL tx_cpld_second_descriptor          : STD_LOGIC;
   SIGNAL tag_track_one_hot                  : STD_LOGIC_VECTOR(TAG_TRACK_WIDTH - 1 DOWNTO 0);

   -- Avalon address
   SIGNAL ep_addr                            : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);     -- Base address of the EP memory
   SIGNAL tx_tag_addr_offset                 : STD_LOGIC_VECTOR(TAG_EP_ADDR_WIDTH - 1 DOWNTO 0);        -- max 15:0 dword
   -- If multiple are needed, this track the
   -- EP adress offset for each tag in the TAGRAM
   -- Receive signals section
   SIGNAL rx_fmt                             : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL rx_type                            : STD_LOGIC_VECTOR(4 DOWNTO 0);

   -- RX Data fifo signals
   SIGNAL rx_data_fifo_data                  : STD_LOGIC_VECTOR(RX_DATA_FIFO_WIDTH + 10 DOWNTO 0);
   SIGNAL rx_data_fifo_q                     : STD_LOGIC_VECTOR(RX_DATA_FIFO_WIDTH + 10 DOWNTO 0);
   SIGNAL rx_data_fifo_sclr                  : STD_LOGIC;
   SIGNAL rx_data_fifo_wrreq                 : STD_LOGIC;
   SIGNAL rx_data_fifo_rdreq                 : STD_LOGIC;
   SIGNAL rx_data_fifo_full                  : STD_LOGIC;
   SIGNAL rx_data_fifo_usedw                 : STD_LOGIC_VECTOR(RX_DATA_FIFO_WIDTHU - 1 DOWNTO 0);
   SIGNAL rx_data_fifo_almost_full           : STD_LOGIC;
   SIGNAL rx_data_fifo_empty                 : STD_LOGIC;

   SIGNAL rx_dv_pulse_reg                    : STD_LOGIC;
   SIGNAL rx_dv_start_pulse                  : STD_LOGIC;
   SIGNAL rx_dv_end_pulse                    : STD_LOGIC;
   SIGNAL rx_dv_end_pulse_reg                : STD_LOGIC;
   SIGNAL rx_data_fifo_rx_tag                : STD_LOGIC_VECTOR(MAX_TAG_WIDTH - 1 DOWNTO 0);

   SIGNAL tagram_data_rd_cycle               : STD_LOGIC;

   SIGNAL performance_counter                : STD_LOGIC_VECTOR(23 DOWNTO 0);

   SIGNAL rx_req_reg                         : STD_LOGIC;
   SIGNAL rx_req_p1                          : STD_LOGIC;
   SIGNAL rx_req_p0                          : STD_LOGIC;

   SIGNAL dt_fifo_ep_addr_byte               : STD_LOGIC_VECTOR(63 DOWNTO 0);

   --//////////////////////////////////////////////
   --
   -- xhdl translation to vhdl constant
   --
   SIGNAL xhdl_zero_byte                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_zero_word                     : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_zero_dword                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_zero_qword                    : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_zero_dqword                   : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_zero_qqword                   : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL xhdl_one_byte                      : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_one_word                      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_one_dword                     : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_one_qword                     : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_one_dqword                    : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_open_dqword                   : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_other_one                     : STD_LOGIC_VECTOR(127 DOWNTO 0);

   SIGNAL xhdl_tx_tag_addr_offset_add        : STD_LOGIC_VECTOR(TAG_EP_ADDR_WIDTH - 1 DOWNTO 0);

   -- Constant carrying width type for VHDL translation

   -- PCIe 4K byte boundary off-set

   -- calc maxrdreq_dw after DT_FIFO_RD_QW1

   -- calc maxrdreq_dw after MRD_REQ

   -- DWORD handling

   -- DWORD count management

   -- Credit and flow control signaling

   --
   -- Transmit sinal section tx_desc, tx_dv, tx_req...
   --

   SIGNAL tx_desc_fmt_32                     : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL tx_desc_fmt_64                     : STD_LOGIC_VECTOR(1 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl16 : STD_LOGIC;
   SIGNAL xhdl17 : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_req_xhdl5                       : STD_LOGIC;
   SIGNAL tx_dv_xhdl4                        : STD_LOGIC;
   SIGNAL tx_dfr_xhdl3                       : STD_LOGIC;
   SIGNAL rx_ws_xhdl2                        : STD_LOGIC;
   SIGNAL address_xhdl0                      : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL write_xhdl6                        : STD_LOGIC;
   SIGNAL requester_mrdmwr_cycle_xhdl1       : STD_LOGIC;

   SIGNAL msi_ready_int                      : STD_LOGIC;
   SIGNAL msi_busy_int                       : STD_LOGIC;

   SIGNAL tagram_address_b_reg                 : STD_LOGIC_VECTOR(MAX_TAG_WIDTH-1 DOWNTO 0);
   SIGNAL rx_fifo_wrreq_first_descriptor_reg   : STD_LOGIC;
   SIGNAL rx_fifo_wrreq_second_descriptor_reg  : STD_LOGIC;


   SIGNAL   cdt_msi_first_descriptor     : STD_LOGIC;
   SIGNAL   cdt_msi_second_descriptor    : STD_LOGIC;
   SIGNAL   cdt_eplast_first_descriptor  : STD_LOGIC;
   SIGNAL   cdt_eplast_second_descriptor : STD_LOGIC;

   SIGNAL   rx_length_hold               : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL   rx_data_fifo_length_hold     : STD_LOGIC_VECTOR(9 DOWNTO 0);

   SIGNAL  got_all_cpl_for_tag           : STD_LOGIC;
   SIGNAL  rcving_last_cpl_for_tag_n     : STD_LOGIC;
   SIGNAL  rcving_last_cpl_for_tag       : STD_LOGIC;
   SIGNAL  transferring_data             : STD_LOGIC;
   SIGNAL  transferring_data_n           : STD_LOGIC;
   SIGNAL  tag_remaining_length          : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
   -- Drive referenced outputs
   tx_req <= tx_req_xhdl5;
   tx_dv <= tx_dv_xhdl4;
   tx_dfr <= tx_dfr_xhdl3;
   rx_ws <= rx_ws_xhdl2;
   address <= address_xhdl0;
   write <= write_xhdl6;
   requester_mrdmwr_cycle <= requester_mrdmwr_cycle_xhdl1;
   waitrequest <= '0';
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
   msi_ready <= msi_ready_int;
   msi_busy  <= msi_busy_int;

   dma_status <= tx_data_eplast;

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         rx_req_reg <= '1';
         rx_req_p1 <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         rx_req_reg <= rx_req;
         rx_req_p1 <= rx_req_p0;
      END IF;
   END PROCESS;
   rx_req_p0 <= rx_req AND NOT(rx_req_reg);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_dv_pulse_reg <= '0';
         ELSE
            rx_dv_pulse_reg <= rx_dv;
         END IF;
      END IF;
   END PROCESS;
   rx_dv_start_pulse <= '1' WHEN ((rx_dv = '1') AND (rx_dv_pulse_reg = '0')) ELSE
                        '0';
   rx_dv_end_pulse <= '1' WHEN ((rx_dfr = '0') AND (rx_dv = '1') AND (rx_ast_data_valid = '1')) ELSE
                      '0';
   dma_sm_tx <= to_stdlogicvector(CSTATE_TX_TYPE'POS(cstate_tx),4);
   dma_sm_rx <= to_stdlogicvector(CSTATE_RX_TYPE'POS(cstate_rx),3);

   dma_sm_rx_data <= cstate_rx_data_fifo;
   cst_one <= '1';
   cst_zero <= '0';
   dt_fifo_ep_addr_byte(63 DOWNTO 32) <= xhdl_zero_dword;
   xhdl7 : IF (DT_EP_ADDR_SPEC = 0) GENERATE
      dt_fifo_ep_addr_byte(31 DOWNTO 0) <= dt_fifo_q(63 DOWNTO 32);
   END GENERATE;
   xhdl8 : IF (NOT(DT_EP_ADDR_SPEC = 0)) GENERATE
      xhdl9 : IF (DT_EP_ADDR_SPEC = 1) GENERATE
         dt_fifo_ep_addr_byte(31 DOWNTO 1) <= dt_fifo_q(62 DOWNTO 32);
         dt_fifo_ep_addr_byte(0) <= '0';
      END GENERATE;
      xhdl10 : IF (NOT(DT_EP_ADDR_SPEC = 1)) GENERATE
         xhdl11 : IF (DT_EP_ADDR_SPEC = 2) GENERATE
            dt_fifo_ep_addr_byte(31 DOWNTO 2) <= dt_fifo_q(61 DOWNTO 32);
            dt_fifo_ep_addr_byte(1 DOWNTO 0) <= "00";
         END GENERATE;
         xhdl12 : IF (NOT(DT_EP_ADDR_SPEC = 2)) GENERATE
            xhdl13 : IF (DT_EP_ADDR_SPEC = 3) GENERATE
               dt_fifo_ep_addr_byte(31 DOWNTO 3) <= dt_fifo_q(60 DOWNTO 32);
               dt_fifo_ep_addr_byte(2 DOWNTO 0) <= "000";
            END GENERATE;
         END GENERATE;
      END GENERATE;
   END GENERATE;
   xhdl_tx_tag_addr_offset_add(1 DOWNTO 0) <= "00";
   xhdl_tx_tag_addr_offset_add(11 DOWNTO 2) <= tx_length_dw(9 DOWNTO 0);
   xhdl14 : IF (TAG_EP_ADDR_WIDTH > 12) GENERATE
      xhdl_tx_tag_addr_offset_add(TAG_EP_ADDR_WIDTH - 1 DOWNTO 12) <= "0000";
   END GENERATE;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_tag_addr_offset <= "0000000000000000";
         ELSIF (cstate_tx = DT_FIFO_RD_QW0_4 ) THEN
            tx_tag_addr_offset <= dt_fifo_ep_addr_byte(15 DOWNTO 0);
         ELSIF (cstate_tx = MRD_ACK_4 ) THEN
            tx_tag_addr_offset <= tx_tag_addr_offset + xhdl_tx_tag_addr_offset_add;
         END IF;
      END IF;
   END PROCESS;
   cfg_maxrdreq_byte(1 DOWNTO 0) <= "00";
   cfg_maxrdreq_byte(12 DOWNTO 2) <= cfg_maxrdreq_dw(10 DOWNTO 0);
   dt_fifo_q_addr_4k(12) <= '0';
   dt_fifo_q_addr_4k(11 DOWNTO 0) <= dt_fifo_q(43 + 64 DOWNTO 32 + 64);

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            calc_4kbnd_dt_fifo_byte <= cfg_maxrdreq_byte;
         ELSIF (cstate_tx = DT_FIFO_RD_QW1_4 ) THEN
            calc_4kbnd_dt_fifo_byte <= "1000000000000" - dt_fifo_q_addr_4k;
         END IF;
      END IF;
   END PROCESS;
   calc_4kbnd_dt_fifo_dw(15 DOWNTO 11) <= "00000";
   calc_4kbnd_dt_fifo_dw(10 DOWNTO 0) <= calc_4kbnd_dt_fifo_byte(12 DOWNTO 2);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            calc_4kbnd_mrd_ack_byte <= cfg_maxrdreq_byte;
         ELSIF ((cstate_tx = MRD_REQ_4 ) AND (tx_ack = '1')) THEN
            calc_4kbnd_mrd_ack_byte <= "1000000000000" - tx_desc_addr_4k;
         END IF;
      END IF;
   END PROCESS;
   calc_4kbnd_mrd_ack_dw(15 DOWNTO 11) <= "00000";
   calc_4kbnd_mrd_ack_dw(10 DOWNTO 0) <= calc_4kbnd_mrd_ack_byte(12 DOWNTO 2);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_desc_addr_4k <= "0000000000000";
         ELSIF ((cstate_tx = MRD_REQ_4 ) AND (tx_ack = '0')) THEN
            IF ((txadd_3dw = '1') OR (RC_64BITS_ADDR = 0)) THEN
               tx_desc_addr_4k(11 DOWNTO 0) <= tx_desc_addr(43 DOWNTO 32) + tx_length_byte;
            ELSE
               tx_desc_addr_4k(11 DOWNTO 0) <= tx_desc_addr(11 DOWNTO 0) + tx_length_byte;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            maxrdreq_dw <= cfg_maxrdreq_dw;
         ELSIF (cstate_tx = MRD_ACK_4 ) THEN
            IF (cfg_maxrdreq_byte > calc_4kbnd_mrd_ack_byte) THEN
               maxrdreq_dw <= calc_4kbnd_mrd_ack_dw;
            ELSE
               maxrdreq_dw <= cfg_maxrdreq_dw;
            END IF;
         ELSIF (cstate_tx = MAX_RREQ_UPD_4 ) THEN
            IF (cfg_maxrdreq_byte > calc_4kbnd_dt_fifo_byte) THEN
               maxrdreq_dw <= calc_4kbnd_dt_fifo_dw;
            ELSE
               maxrdreq_dw <= cfg_maxrdreq_dw;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            cdt_length_dw_tx <= "0000000000000000";
         ELSE
            IF (cstate_tx = DT_FIFO_RD_QW0_4 ) THEN
               cdt_length_dw_tx <= dt_fifo_q(15 DOWNTO 0);
            ELSIF (cstate_tx = TX_LENGTH_4 ) THEN
               IF (cdt_length_dw_tx < maxrdreq_dw) THEN
                  cdt_length_dw_tx <= "0000000000000000";
               ELSE
                  cdt_length_dw_tx <= cdt_length_dw_tx - maxrdreq_dw;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate_tx = DT_FIFO_4 ) OR (cstate_tx = MRD_ACK_4 )) THEN
            tx_length_dw <= "0000000000";
         ELSE
            IF (cstate_tx = TX_LENGTH_4 ) THEN
               IF (cdt_length_dw_tx < maxrdreq_dw) THEN
                  tx_length_dw <= cdt_length_dw_tx(9 DOWNTO 0);
               ELSE
                  tx_length_dw <= maxrdreq_dw(9 DOWNTO 0);
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate_tx = DT_FIFO_4 ) THEN
            rx_buffer_cpl_ready <= '1';
         ELSIF ((cstate_tx = TX_LENGTH_4 ) OR (cstate_tx = START_TX_4 )) THEN
            IF (cdt_length_dw_tx < maxrdreq_dw) THEN
               IF (rx_buffer_cpl_max_dw < cdt_length_dw_tx) THEN
                  rx_buffer_cpl_ready <= '0';
               ELSE
                  rx_buffer_cpl_ready <= '1';
               END IF;
            ELSE
               IF (rx_buffer_cpl_max_dw < maxrdreq_dw) THEN
                  rx_buffer_cpl_ready <= '0';
               ELSE
                  rx_buffer_cpl_ready <= '1';
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   tx_length_byte(11 DOWNTO 2) <= tx_length_dw(9 DOWNTO 0);
   tx_length_byte(1 DOWNTO 0) <= "00";
   tx_length_byte_32ext(11 DOWNTO 0) <= tx_length_byte(11 DOWNTO 0);
   tx_length_byte_32ext(31 DOWNTO 12) <= "00000000000000000000";
   tx_length_byte_64ext(11 DOWNTO 0) <= tx_length_byte(11 DOWNTO 0);
   tx_length_byte_64ext(63 DOWNTO 12) <= "0000000000000000000000000000000000000000000000000000";
   xhdl15 : IF (TXCRED_WIDTH > 36) GENERATE
      PROCESS (clk_in)
      BEGIN
         IF (clk_in'EVENT AND clk_in = '1') THEN
            IF (init = '1') THEN
               tx_cred_non_posted_header_valid_x8 <= '0';
            ELSE
               IF ((tx_cred(27 DOWNTO 20) > "00000000") OR (tx_cred(62) = '1')) THEN
                  tx_cred_non_posted_header_valid_x8 <= '1';
               ELSE
                  tx_cred_non_posted_header_valid_x8 <= '0';
               END IF;
            END IF;
         END IF;
      END PROCESS;
   END GENERATE;
   tx_cred_non_posted_header_valid <= '1' WHEN (USE_CREDIT_CTRL = 0) ELSE
                                      tx_cred_non_posted_header_valid_x8 WHEN (TXCRED_WIDTH = 66) ELSE
                                      tx_cred(10);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_cred_posted_data_valid_8x <= '0';
         ELSE
            IF (((tx_cred(7 DOWNTO 0) > "00000000") OR (tx_cred(TXCRED_WIDTH - 6) = '1')) AND ((tx_cred(19 DOWNTO 8) > "000000000000") OR (tx_cred(TXCRED_WIDTH - 5) = '1'))) THEN
               tx_cred_posted_data_valid_8x <= '1';
            ELSE
               tx_cred_posted_data_valid_8x <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   tx_cred_posted_data_valid_4x <= '1' WHEN ((tx_cred(0) = '1') AND (tx_cred(9 DOWNTO 1) > "000000000")) ELSE
                                   '0';
   tx_cred_posted_data_valid <= '1' WHEN (USE_CREDIT_CTRL = 0) ELSE
                                tx_cred_posted_data_valid_8x WHEN (TXCRED_WIDTH = 66) ELSE
                                tx_cred_posted_data_valid_4x;
   tx_ready <= '1' WHEN (((cstate_tx = START_TX_4 ) AND (tx_cred_non_posted_header_valid = '1') AND (rx_buffer_cpl_ready = '1') ) OR ((cstate_tx = START_TX_UPD_DT_4 ) AND (tx_cred_posted_data_valid = '1'))) ELSE
               '0';
   tx_busy <= '1' WHEN ((cstate_tx = MRD_REQ_4 ) OR (tx_dv_xhdl4 = '1') OR (tx_dfr_xhdl3 = '1') OR (cstate_tx = MWR_REQ_UPD_DT_4 )) ELSE
              '0';
   tx_req_xhdl5 <= '1' WHEN (((cstate_tx = MRD_REQ_4 ) OR (cstate_tx = MWR_REQ_UPD_DT_4 )) AND (tx_ack = '0')) ELSE
                   '0';
   tx_lbe_d <= "0000" WHEN (tx_length_dw(9 DOWNTO 0) = "0000000001") ELSE
               "1111";
   tx_fbe_d <= "1111";
   tx_desc(127) <= '0';

   tx_desc_fmt_32 <= "10" WHEN (ep_lastupd_cycle = '1') ELSE
                     "00";
   tx_desc_fmt_64 <= "10" WHEN ((ep_lastupd_cycle = '1') AND (dt_3dw_rcadd = '1')) ELSE
                     "11" WHEN ((ep_lastupd_cycle = '1') AND (dt_3dw_rcadd = '0')) ELSE
                     "01";
   tx_desc(126 DOWNTO 125) <= tx_desc_fmt_32 WHEN (RC_64BITS_ADDR = 0) ELSE
                              tx_desc_fmt_64;
   tx_desc(124 DOWNTO 120) <= "00000" WHEN (ep_lastupd_cycle = '1') ELSE
                              "00000";
   tx_desc(119) <= '0';
   tx_desc(118 DOWNTO 116) <= "000";
   tx_desc(115 DOWNTO 112) <= "0000";
   tx_desc(111) <= '0';
   tx_desc(110) <= '0';
   tx_desc(109 DOWNTO 108) <= "00";
   tx_desc(107 DOWNTO 106) <= "00";
   tx_desc(105 DOWNTO 96) <= "0000000010" WHEN (ep_lastupd_cycle = '1') ELSE
                             tx_length_dw(9 DOWNTO 0);
   tx_desc(95 DOWNTO 80) <= xhdl_zero_word;
   tx_desc(79 DOWNTO 72) <= "00000000" WHEN (ep_lastupd_cycle = '1') ELSE
                            tx_tag_tx_desc;
   tx_desc(71 DOWNTO 68) <= tx_lbe_d;
   tx_desc(67 DOWNTO 64) <= tx_fbe_d;
   tx_desc(63 DOWNTO 0) <= tx_addr_eplast WHEN (ep_lastupd_cycle = '1') ELSE
                           tx_desc_addr WHEN (addrval_32b='0') ELSE
                           tx_desc_addr(31 DOWNTO 0)&xhdl_zero_dword;

   -- Hardware performance counter
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            performance_counter <= "000000000000000000000000";
         ELSIF ((dt_ep_last_eq_dt_size = '1') AND (cstate_tx = MWR_ACK_UPD_DT_4 )) THEN
            performance_counter <= "000000000000000000000000";
         ELSE
            IF ((requester_mrdmwr_cycle_xhdl1 = '1') OR (descriptor_mrd_cycle = '1')) THEN
               performance_counter <= performance_counter + "000000000000000000000001";
            ELSIF (tx_ws = '0') THEN
               performance_counter <= "000000000000000000000000";
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            requester_mrdmwr_cycle_xhdl1 <= '0';
         ELSIF ((dt_fifo_empty = '0') AND (cstate_tx = DT_FIFO_4 )) THEN
            requester_mrdmwr_cycle_xhdl1 <= '1';
         ELSIF ((dt_fifo_empty = '1') AND (cstate_tx = DT_FIFO_4 ) AND (tx_ws = '0') AND (eplast_upd_first_descriptor = '0') AND (eplast_upd_second_descriptor = '0')) THEN
            requester_mrdmwr_cycle_xhdl1 <= '0';
         END IF;
      END IF;
   END PROCESS;

   -- 63:57 Indicates which board is being used
   --    0 - Altera Stratix II GX  x1
   --    1 - Altera Stratix II GX  x4
   --    2 - Altera Stratix II GX  x8
   --    3 - Cyclone II            x1
   --    4 - Arria GX              x1
   --    5 - Arria GX              x4
   --    6 - Custom PHY            x1
   --    7 - Custom PHY            x4
   -- When bit 56 set, indicates x8 configuration 256 Mhz back-end
   -- 55:53  maxpayload for MWr
   -- 52:48  number of lanes negocatied
   -- 47:32 indicates the number of the last processed descriptor
   -- 31:24 Number of tags
   -- When 52:48  number of lanes negocatied
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_data_eplast(63 DOWNTO 57) <= BOARD_DEMO_7 ;
         IF (TXCRED_WIDTH > 36) THEN
            tx_data_eplast(56) <= '1';
         ELSE
            tx_data_eplast(56) <= '0';
         END IF;
         tx_data_eplast(55 DOWNTO 53) <= cfg_maxrdreq;
         tx_data_eplast(52 DOWNTO 49) <= cfg_link_negociated(3 DOWNTO 0);
         tx_data_eplast(48) <= dt_fifo_empty;
         tx_data_eplast(47 DOWNTO 32) <= dt_ep_last;
         tx_data_eplast(31 DOWNTO 24) <= MAX_NUMTAG_8 ;
         tx_data_eplast(23 DOWNTO 0) <= performance_counter;
      END IF;
   END PROCESS;

   tx_data <= (tx_data_eplast(63 DOWNTO 0) & tx_data_eplast(63 DOWNTO 0));      -- assumes dt_rc_base is a QWord address

   -- Generation of tx_dfr signal
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate_tx = START_TX_UPD_DT_4 ) OR (cstate_tx = DT_FIFO_4 )) THEN
            tx_req_reg <= '0';
         ELSIF (cstate_tx = MWR_REQ_UPD_DT_4 ) THEN
            tx_req_reg <= '1';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_req_delay <= '0';
         ELSE
            tx_req_delay <= tx_req_xhdl5;
         END IF;
      END IF;
   END PROCESS;

   tx_dfr_xhdl3 <= tx_req_xhdl5 AND NOT(tx_req_reg) AND ep_lastupd_cycle;

   -- Generation of tx_dv signal
   xhdl16 <= '0' WHEN (tx_ws = '0') ELSE        -- Hold tx_dv until accepted
                   tx_dv_xhdl4;
   xhdl17 <= '1' WHEN (tx_dfr_xhdl3 = '1') ELSE
                   xhdl16;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate_tx = DT_FIFO_4 ) THEN
            tx_dv_xhdl4 <= '0';
         ELSIF (ep_lastupd_cycle = '1') THEN
            tx_dv_xhdl4 <= xhdl17;
         END IF;
      END IF;
   END PROCESS;

   -- DT_FIFO signaling
   dt_fifo_rdreq <= '1' WHEN ((dt_fifo_empty = '0') AND (cstate_tx = DT_FIFO_4 )) ELSE
                    '0';

   -- DMA Write control signal msi, ep_lastena
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate_tx = DT_FIFO_RD_QW0_4 ) THEN
            cdt_msi <= dt_msi OR dt_fifo_q(16);
            cdt_eplast_ena <= dt_eplast_ena OR dt_fifo_q(17);
            IF (tx_first_descriptor_cycle='1') THEN
                IF ((dt_msi='1') OR (dt_fifo_q(16)='1')) THEN
                    cdt_msi_first_descriptor <= '1';
                ELSE
                    cdt_msi_first_descriptor <= '0';
                END IF;
                IF ((dt_eplast_ena='1') OR (dt_fifo_q(17)='1')) THEN
                    cdt_eplast_first_descriptor  <= '1';
                ELSE
                    cdt_eplast_first_descriptor  <= '0';
                END IF;
                cdt_msi_second_descriptor    <= cdt_msi_second_descriptor;
                cdt_eplast_second_descriptor <= cdt_eplast_second_descriptor;
            ELSE
                cdt_msi_first_descriptor     <= cdt_msi_first_descriptor;
                cdt_eplast_first_descriptor  <= cdt_eplast_first_descriptor;
                IF ((dt_msi='1') OR (dt_fifo_q(16)='1')) THEN
                    cdt_msi_second_descriptor <= '1';
                ELSE
                    cdt_msi_second_descriptor <= '0';
                END IF;
                IF ((dt_eplast_ena='1') OR (dt_fifo_q(17)='1')) THEN
                    cdt_eplast_second_descriptor  <= '1';
                ELSE
                    cdt_eplast_second_descriptor  <= '0';
                END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;

   --Section related to EPLAST rewrite
   -- Upadting RC memory register dt_ep_last

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate_tx = START_TX_UPD_DT_4 ) OR (cstate_tx = MWR_REQ_UPD_DT_4 )) THEN
            ep_lastupd_cycle <= '1';
         ELSE
            ep_lastupd_cycle <= '0';
         END IF;
      END IF;
   END PROCESS;

   --
   -- EP Last counter dt_ep_last : track the number of descriptor processed
   --
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            dt_ep_last <= "0000000000000000";
            dt_ep_last_eq_dt_size <= '0';
         ELSE
             IF (dt_ep_last = dt_size) THEN
                 dt_ep_last_eq_dt_size <= '1';
             ELSE
                 dt_ep_last_eq_dt_size <= '0';
             END IF;

             IF (cstate_tx = MWR_ACK_UPD_DT_4 ) THEN
                IF (dt_ep_last_eq_dt_size = '1') THEN
                   dt_ep_last <= "0000000000000000";
                ELSE
                   dt_ep_last <= dt_ep_last + "0000000000000001";
                END IF;
             END IF;
          END IF;
      END IF;
   END PROCESS;

   -- TX_Address Generation section : tx_desc_addr, tx_addr_eplast
   -- check static parameter for 64 bit vs 32 bits RC : RC_64BITS_ADDR

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tx_desc_addr_3dw_pipe(31 DOWNTO 0) <= tx_desc_addr(63 DOWNTO 32) + tx_length_byte_32ext;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate_tx = DT_FIFO_4 ) THEN
            tx_desc_addr <= "0000000000000000000000000000000000000000000000000000000000000000";
            txadd_3dw <= '1';
            addrval_32b <='0';
         ELSIF (RC_64BITS_ADDR = 0) THEN
            txadd_3dw <= '1';
            addrval_32b <='0';

            -- generate tx_desc_addr
            tx_desc_addr(31 DOWNTO 0) <= xhdl_zero_dword;
            IF (cstate_tx = DT_FIFO_RD_QW1_4 ) THEN
               tx_desc_addr(63 DOWNTO 32) <= dt_fifo_q(63 + 64 DOWNTO 32 + 64);
            ELSIF (cstate_tx = MRD_ACK_4 ) THEN
               -- TO DO assume double word
               tx_desc_addr(63 DOWNTO 32) <= tx_desc_addr_3dw_pipe(31 DOWNTO 0);
            END IF;
         ELSE
            IF (cstate_tx = DT_FIFO_RD_QW1_4 ) THEN
               -- RC ADDR MSB if qword aligned
               addrval_32b <='0';
               IF (dt_fifo_q(31 + 64 DOWNTO 0 + 64) = xhdl_zero_dword) THEN
                  txadd_3dw <= '1';
                  tx_desc_addr(63 DOWNTO 32) <= dt_fifo_q(63 + 64 DOWNTO 32 + 64);
                  tx_desc_addr(31 DOWNTO 0) <= xhdl_zero_dword;
               ELSE
                  txadd_3dw <= '0';
                  tx_desc_addr(31 DOWNTO 0) <= dt_fifo_q(63 + 64 DOWNTO 32 + 64);
                  tx_desc_addr(63 DOWNTO 32) <= dt_fifo_q(31 + 64 DOWNTO 0 + 64);
               END IF;
            ELSIF (cstate_tx = MRD_ACK_4 ) THEN
               -- TO DO assume double word
               IF (txadd_3dw = '1') THEN
                  tx_desc_addr(63 DOWNTO 32) <= tx_desc_addr(63 DOWNTO 32) + tx_length_byte_32ext;
                  addrval_32b <='0';
               ELSE
                  --tx_desc_addr <= tx_desc_addr+tx_length_byte_64ext;
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



   addr64_add : add_sub_dmard128
      PORT MAP (
         dataa   => tx_desc_addr,
         datab   => tx_length_byte_64ext,
         clock   => clk_in,
         result  => tx_desc_addr_pipe
      );
   -- Generation of address of tx_addr_eplast and
   -- tx_32addr_eplast bit which indicates that this is a 32 bit address
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (RC_64BITS_ADDR = 0) THEN
            tx_32addr_eplast <= '1';

            -- generate tx_addr_eplast
            tx_addr_eplast(31 DOWNTO 0) <= xhdl_zero_dword;
            IF (init = '1') THEN
               tx_addr_eplast(63 DOWNTO 32) <= xhdl_zero_dword;
            ELSIF (cstate_tx = DT_FIFO_RD_QW0_4 ) THEN
               tx_addr_eplast(63 DOWNTO 32) <= dt_base_rc(31 DOWNTO 0) + "00000000000000000000000000001000";
            END IF;
         ELSE
            IF (init = '1') THEN
               tx_32addr_eplast <= '1';
               tx_addr_eplast <= xhdl_zero_qword;
            ELSIF (cstate_tx = DT_FIFO_RD_QW0_4 ) THEN
               IF (dt_3dw_rcadd = '1') THEN
                  tx_32addr_eplast <= '1';
                  tx_addr_eplast(63 DOWNTO 32) <= dt_base_rc(31 DOWNTO 0) + "00000000000000000000000000001000";
                  tx_addr_eplast(31 DOWNTO 0) <= xhdl_zero_dword;
               ELSE
                  tx_32addr_eplast <= '0';
                  tx_addr_eplast <= tx_addr_eplast_pipe;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;



   addr128_add_eplast : add_sub_dmard128_cst
      PORT MAP (
         dataa   => dt_base_rc,
         clock   => clk_in,
         result  => tx_addr_eplast_pipe
      );

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_mrd_cycle <= '0';
         ELSE
            IF (cstate_tx = DT_FIFO_RD_QW0_4 ) THEN
               tx_mrd_cycle <= '1';
            ELSIF (cstate_tx = CPLD_4 ) THEN
               tx_mrd_cycle <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   tx_get_tag_from_fifo <= '1' WHEN (((tx_tag_mux_first_descriptor = '1') AND (tx_first_descriptor_cycle = '1')) OR ((tx_tag_mux_second_descriptor = '1') AND (tx_first_descriptor_cycle = '0'))) ELSE
                           '0';

   -- Requester Read state machine (Transmit)
   --    Combinatorial state transition (case state)
   PROCESS (msi_busy_int, msi_ready_int, cstate_tx, init, dt_fifo_empty, eplast_upd_first_descriptor, tx_cpld_first_descriptor, eplast_upd_second_descriptor, tx_cpld_second_descriptor, tx_get_tag_from_fifo, tx_length_dw, tx_sel, tx_ack, cdt_length_dw_tx, tag_fifo_empty_first_descriptor, tx_first_descriptor_cycle, tag_fifo_empty_second_descriptor, cdt_eplast_ena, cdt_msi,
            cdt_eplast_first_descriptor, cdt_eplast_second_descriptor, cstate_msi)
   BEGIN
      CASE cstate_tx IS
         -- Descriptor FIFO - ready to read the next descriptor 4 DWORDS

         WHEN DT_FIFO_4  =>
            IF (init = '1') THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSIF (dt_fifo_empty = '0') THEN
               nstate_tx <= DT_FIFO_RD_QW0_4 ;
            ELSIF ((eplast_upd_first_descriptor = '1') AND (tx_cpld_first_descriptor = '1')) THEN
               nstate_tx <= DONE_4 ;
            ELSIF ((eplast_upd_second_descriptor = '1') AND (tx_cpld_second_descriptor = '1')) THEN
               nstate_tx <= DONE_4 ;
            ELSE
               nstate_tx <= DT_FIFO_4 ;
            END IF;
         -- set dt_fifo_rd_req for DW0

         WHEN DT_FIFO_RD_QW0_4  =>
            nstate_tx <= DT_FIFO_RD_QW1_4 ;
         -- set dt_fifo_rd_req for DW1

         WHEN DT_FIFO_RD_QW1_4  =>
            IF (cstate_msi=IDLE_MSI_3) THEN
                nstate_tx <= MAX_RREQ_UPD_4 ;
            ELSE
               nstate_tx <= DT_FIFO_RD_QW1_4 ;
            END IF;

         WHEN MAX_RREQ_UPD_4  =>
            IF (tx_get_tag_from_fifo = '1') THEN
               nstate_tx <= GET_TAG_4 ;
            ELSE
               nstate_tx <= TX_LENGTH_4 ;
            END IF;

         WHEN TX_LENGTH_4  =>
            nstate_tx <= START_TX_4 ;
         -- Waiting for Top level arbitration (tx_sel) prior to tx MEM64_WR

         WHEN START_TX_4  =>      -- Read Request Assert tx_req
            IF ((init = '1') OR (tx_length_dw = "0000000000")) THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSE
               IF (tx_sel = '1') THEN
                  nstate_tx <= MRD_REQ_4 ;
               ELSE
                  nstate_tx <= START_TX_4 ;
               END IF;
            END IF;
         -- Set tx_req, Waiting for tx_ack

         WHEN MRD_REQ_4  =>       -- Read Request Ack. tx_ack
            IF (init = '1') THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSIF (tx_ack = '1') THEN
               nstate_tx <= MRD_ACK_4 ;
            ELSE
               nstate_tx <= MRD_REQ_4 ;
            END IF;
         -- Received tx_ack, clear tx_req, MRd next data chunk

         WHEN MRD_ACK_4  =>
            IF (cdt_length_dw_tx = "0000000000000000") THEN
               nstate_tx <= CPLD_4 ;
            ELSIF (tx_get_tag_from_fifo = '1') THEN
               nstate_tx <= GET_TAG_4 ;
            ELSE
               nstate_tx <= TX_LENGTH_4 ;
            END IF;
         -- Retrieve a TAG from the TAG FIFO
         -- Waiting for a new TAG from the TAG FIFO

         WHEN GET_TAG_4  =>
            IF (init = '1') THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSIF ((tag_fifo_empty_first_descriptor = '0') AND (tx_first_descriptor_cycle = '1')) THEN
               nstate_tx <= TX_LENGTH_4 ;
            ELSIF ((tag_fifo_empty_second_descriptor = '0') AND (tx_first_descriptor_cycle = '0')) THEN
               nstate_tx <= TX_LENGTH_4 ;
            ELSE
               nstate_tx <= GET_TAG_4 ;
            END IF;
         -- Waiting for completion for RX state machine (CPLD)
         -- 2 descriptor are being processed, waiting
         -- for the completion of at least one descriptor

         WHEN CPLD_4  =>
            IF (init = '1') THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSE
               IF (tx_cpld_first_descriptor = '0') THEN
                  IF (tx_cpld_second_descriptor = '1') THEN
                     IF (eplast_upd_second_descriptor = '1') THEN
                        nstate_tx <= DONE_4 ;
                     ELSE
                        nstate_tx <= DT_FIFO_4 ;
                     END IF;
                  ELSE
                     nstate_tx <= CPLD_4 ;
                  END IF;
               ELSE
                  IF (eplast_upd_first_descriptor = '1') THEN
                     nstate_tx <= DONE_4 ;
                  ELSE
                     nstate_tx <= DT_FIFO_4 ;
                  END IF;
               END IF;
            END IF;

         -- Update RC Memory for polling info with the last
         -- processed/completed descriptor

         WHEN DONE_4  =>
              IF (((msi_ready_int='0') AND (msi_busy_int='0')) OR (cdt_msi='0')) THEN   -- if MSI is enabled, wait in DONE state until msi_req can be issued by MSI sm
                 IF ( ((cdt_eplast_first_descriptor = '1') AND (eplast_upd_first_descriptor= '1') AND (tx_cpld_first_descriptor='1')) OR
                       ((cdt_eplast_second_descriptor = '1') AND (eplast_upd_second_descriptor= '1') AND (tx_cpld_second_descriptor='1')) ) THEN
                       nstate_tx <= START_TX_UPD_DT_4 ;
                   ELSE
                       nstate_tx <= MWR_ACK_UPD_DT_4 ;
                   END IF;
              ELSE
                  nstate_tx <= DONE_4;
              END IF;
         -- Waiting for Top level arbitration (tx_sel) prior to tx MEM64_WR

         WHEN START_TX_UPD_DT_4  =>
            IF (init = '1') THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSE
               IF (tx_sel = '1') THEN
                  nstate_tx <= MWR_REQ_UPD_DT_4 ;
               ELSE
                  nstate_tx <= START_TX_UPD_DT_4 ;
               END IF;
            END IF;
         -- Set tx_req, Waiting for tx_ack

         WHEN MWR_REQ_UPD_DT_4  =>
            IF (init = '1') THEN
               nstate_tx <= DT_FIFO_4 ;
            ELSIF (tx_ack = '1') THEN
               nstate_tx <= MWR_ACK_UPD_DT_4 ;
            ELSE
               nstate_tx <= MWR_REQ_UPD_DT_4 ;
            END IF;
         -- Received tx_ack, clear tx_req

         WHEN MWR_ACK_UPD_DT_4  =>
            nstate_tx <= DT_FIFO_4 ;

         WHEN OTHERS =>
            nstate_tx <= DT_FIFO_4 ;
      END CASE;
   END PROCESS;

   -- Requester Read TX machine
   --    Registered state state transition
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate_tx <= DT_FIFO_4 ;
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate_tx <= nstate_tx;
      END IF;
   END PROCESS;

   --//////////////////////////////////////////////////////////////
   --
   -- RX TLP Receive section
   --

   rx_fmt <= rx_desc(126 DOWNTO 125);
   rx_type <= rx_desc(124 DOWNTO 120);
   rx_dmard_tag <= '1' WHEN (rx_desc(47 DOWNTO 40) >= FIRST_DMARD_TAG_8 ) ELSE
                   '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_req_p0 = '0') THEN
            rx_dmard_cpld <= '0';
         ELSIF ((rx_dfr = '1') AND (rx_fmt = "10") AND (rx_type = "01010")) THEN
            rx_dmard_cpld <= '1';
         END IF;
      END IF;
   END PROCESS;

   -- Set/Clear rx_ack
   rx_ack <= '1' WHEN (nstate_rx = CPLD_ACK_3 ) ELSE
             '0';

   -- Avalon streaming back pressure control
   -- 4 cycles response : 1 cc registered rx_ws +
   --                     3 cc tx_stream_ready -> tx_stream_valid
   rx_ws_xhdl2 <= '1' WHEN ((rx_data_fifo_almost_full = '1') AND ((cstate_rx = CPLD_IDLE_3 ) OR (cstate_rx = CPLD_DV_3 ) OR (cstate_rx = CPLD_LAST_3 ))) ELSE
                  '0';

   PROCESS (clk_in, rstn)
   BEGIN
      IF (rstn = '0') THEN
         rx_ast_data_valid <= '0';
         rx_ws_ast <= "000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         rx_ws_ast(0) <= rx_ws_xhdl2;
         rx_ws_ast(1) <= rx_ws_ast(0);
         rx_ws_ast(2) <= rx_ws_ast(1);
         rx_ast_data_valid <= NOT(rx_ws_ast(0));
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_tag(MAX_TAG_WIDTH - 1 DOWNTO 0) <= xhdl_zero_qqword(MAX_TAG_WIDTH - 1 DOWNTO 0);
         ELSIF (valid_rx_dmard_cpld = '1') THEN
            rx_tag <= rx_desc(MAX_TAG_WIDTH + 39 DOWNTO 40);
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_tag_is_sec_desc <= '0';
         ELSIF (valid_rx_dmard_cpld = '1') THEN
            IF ((rx_desc(MAX_TAG_WIDTH + 39 DOWNTO 40) > MAX_NUMTAG_VAL_FIRST_DESCRIPTOR)) THEN
                rx_tag_is_sec_desc <=  '1';
            ELSE
                rx_tag_is_sec_desc <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_dv_start_pulse = '1') THEN
            rx_length_hold <= rx_desc(105 DOWNTO 96);
         ELSE
            rx_length_hold <= rx_length_hold;
         END IF;
      END IF;
   END PROCESS;


   --////////////////////////////////////////////////////////
   --
   -- DATA FIFO RX_DATA side management  (DATA_FIFO Write)
   --
   rx_data_fifo_data(AVALON_WDATA - 1 DOWNTO 0) <= rx_data(AVALON_WDATA - 1 DOWNTO 0);
   rx_data_fifo_data(AVALON_WDATA + 15 DOWNTO AVALON_WDATA) <= rx_be;
   rx_data_fifo_data(RX_DATA_FIFO_WIDTH - 3 DOWNTO AVALON_WDATA + 16) <= rx_tag WHEN (rx_dv_start_pulse = '0') ELSE
                                                                     rx_desc(MAX_TAG_WIDTH + 39 DOWNTO 40);
   rx_data_fifo_data(RX_DATA_FIFO_WIDTH - 2) <= rx_dv_start_pulse;
   rx_data_fifo_data(RX_DATA_FIFO_WIDTH - 1) <= rx_dv_end_pulse;
   rx_data_fifo_data(RX_DATA_FIFO_WIDTH) <= rx_tag_is_sec_desc WHEN (rx_dv_start_pulse = '0') ELSE
                                                      '1' WHEN ((rx_desc(MAX_TAG_WIDTH + 39 DOWNTO 40) > MAX_NUMTAG_VAL_FIRST_DESCRIPTOR)) ELSE '0';

   rx_data_fifo_data(RX_DATA_FIFO_WIDTH + 10 DOWNTO RX_DATA_FIFO_WIDTH + 1) <=  rx_length_hold WHEN (rx_dv_start_pulse = '0') ELSE rx_desc(105 DOWNTO 96);


   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((rx_dfr = '0') OR (init = '1')) THEN
            valid_rx_dmard_cpld_next <= '0';
         ELSE
            IF ((rx_req_p1 = '1') AND (rx_dmard_tag = '1') AND (rx_dmard_cpld = '1')) THEN
               valid_rx_dmard_cpld_next <= '1';
            ELSIF (rx_req = '0') THEN
               valid_rx_dmard_cpld_next <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   valid_rx_dmard_cpld <= '1' WHEN ((rx_req = '1') AND (((rx_req_p1 = '1') AND (rx_dmard_tag = '1') AND (rx_dmard_cpld = '1')) OR (valid_rx_dmard_cpld_next = '1'))) ELSE
                          '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_dv_end_pulse_reg <= rx_dv_end_pulse;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            valid_rx_dv_for_dmard <= '0';
         ELSIF (rx_dv_end_pulse_reg = '1') THEN
            valid_rx_dv_for_dmard <= '0';
         ELSIF (valid_rx_dmard_cpld_next = '1') THEN
            valid_rx_dv_for_dmard <= '1';
         END IF;
      END IF;
   END PROCESS;

   rx_data_fifo_sclr <= '1' WHEN (init = '1') ELSE
                        '0';
   rx_data_fifo_wrreq <= '1' WHEN (((valid_rx_dmard_cpld = '1') OR (valid_rx_dmard_cpld_next = '1') OR (valid_rx_dv_for_dmard = '1')) AND (rx_ast_data_valid = '1') AND (rx_dv = '1')) ELSE     --TODO optimize valid_rx_dv_for_dmard
                         '0';

   --////////////////////////////////////////////////////////
   --
   -- DATA FIFO Avalon side management   (DATA_FIFO Read)
   --

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (cstate_rx_data_fifo = SM_RX_DATA_FIFO_READ_TAGRAM_2_3 ) THEN
            tagram_data_rd_cycle <= '1';
         ELSE
            tagram_data_rd_cycle <= '0';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((rx_data_fifo_empty = '1') OR (init = '1')) THEN
            rx_data_fifo_almost_full <= '0';
         ELSE
            IF (rx_data_fifo_usedw > RX_DATA_FIFO_ALMST_FULL_LIM_6 ) THEN
               rx_data_fifo_almost_full <= '1';
            ELSE
               rx_data_fifo_almost_full <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            rx_data_fifo_rx_tag(MAX_TAG_WIDTH - 1 DOWNTO 0) <= xhdl_zero_qqword(MAX_TAG_WIDTH - 1 DOWNTO 0);
         ELSIF (cstate_rx_data_fifo = SM_RX_DATA_FIFO_READ_TAGRAM_1_3 ) THEN
            rx_data_fifo_rx_tag <= rx_data_fifo_q(RX_DATA_FIFO_WIDTH - 3 DOWNTO 144);
         END IF;
      END IF;

   END PROCESS;

   --////////////////////////////////////////////////////////
   --
   --  TAGRAM Update (port b) from the CPLD section
   --

   tagram_address_b <= rx_data_fifo_q(RX_DATA_FIFO_WIDTH - 3 DOWNTO 144) WHEN (cstate_rx_data_fifo = SM_RX_DATA_FIFO_READ_TAGRAM_1_3 ) ELSE
                       rx_data_fifo_rx_tag;


   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
        IF (init = '1') THEN
           tagram_wren_b <= '0';
        ELSE
           tagram_wren_b <= tagram_data_rd_cycle;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (((cstate_rx_data_fifo = SM_RX_DATA_FIFO_RREQ_3 ) AND (rx_data_fifo_q(RX_DATA_FIFO_WIDTH - 1) = '1')) OR (cstate_rx_data_fifo = SM_RX_DATA_FIFO_SINGLE_QWORD_3 )) THEN
            tagram_wren_b_reg_init <= '1';
         ELSE
            tagram_wren_b_reg_init <= '0';
         END IF;
      END IF;
   END PROCESS;

   --  base tagram entries on descriptor info

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
          IF (rx_data_fifo_q(RX_DATA_FIFO_WIDTH-2) =  '1') THEN
          rx_data_fifo_length_hold <= rx_data_fifo_q(RX_DATA_FIFO_WIDTH + 10 DOWNTO RX_DATA_FIFO_WIDTH + 1);
          END IF;
      END IF;
   END PROCESS;

   rx_tag_length_dw_next   <= "0000000000" WHEN (tagram_q_b(TAG_EP_ADDR_WIDTH+9 DOWNTO TAG_EP_ADDR_WIDTH) < 5) ELSE tagram_q_b(TAG_EP_ADDR_WIDTH+9 DOWNTO TAG_EP_ADDR_WIDTH) - rx_data_fifo_length_hold;
   rx_tag_addr_offset_next <= tagram_q_b(TAG_EP_ADDR_WIDTH-1 DOWNTO 0) + (rx_data_fifo_length_hold & "00");  -- length is in DWords, tagram address uses byte addressing



   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
        rcving_last_cpl_for_tag <= rcving_last_cpl_for_tag_n;
         IF (init = '1') THEN
            rx_tag_length_dw <= "0000000000";
            rx_tag_addr_offset <= "0000000000000000";
            tagram_data_b        <= (others => '0');
          tag_remaining_length <= (others => '0');
         ELSIF (tagram_data_rd_cycle = '1') THEN
            rx_tag_length_dw(9 DOWNTO 0) <= tagram_q_b(TAG_RAM_WIDTH - 1 DOWNTO TAG_RAM_WIDTH - 10);
            rx_tag_addr_offset <= tagram_q_b(TAG_EP_ADDR_WIDTH - 1 DOWNTO 0);
            tagram_data_b        <= (rx_tag_length_dw_next(9 DOWNTO 0) & rx_tag_addr_offset_next(TAG_EP_ADDR_WIDTH-1 DOWNTO 0));
          tag_remaining_length <= tagram_q_b(TAG_EP_ADDR_WIDTH+9 DOWNTO TAG_EP_ADDR_WIDTH);

         ELSE
          tag_remaining_length <= tag_remaining_length;
         tagram_data_b <= tagram_data_b;
            rx_tag_addr_offset <= rx_tag_addr_offset + "0000000000010000";      -- rx_tag_addr_offset is in bytes, but mem access is in 128-bits so increment every access by 16 bytes.
            IF (rx_tag_length_dw > "0000000000") THEN
               IF ((rx_tag_length_dw < DATA_WIDTH_DWORD_10 ) AND (rx_tag_length_dw > "0000000000")) THEN
                  rx_tag_length_dw <= "0000000000";
               ELSE
                  rx_tag_length_dw <= rx_tag_length_dw - DATA_WIDTH_DWORD_10 ;
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   --////////////////////////////////////////////////////////
   --
   --  Avalon memory write
   --

   rx_data_fifo_rdreq <= '1' WHEN ((cstate_rx_data_fifo = SM_RX_DATA_FIFO_IDLE_3 ) OR ((rx_data_fifo_empty = '0') AND  ((cstate_rx_data_fifo = SM_RX_DATA_FIFO_RREQ_3 ) or ( cstate_rx_data_fifo = SM_RX_DATA_FIFO_SINGLE_QWORD_3 )))) ELSE
                         '0';

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         writedata <= rx_data_fifo_q(127 DOWNTO 0);
         write_byteena <= rx_data_fifo_q(143 DOWNTO 128);
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate_rx_data_fifo = SM_RX_DATA_FIFO_RREQ_3 ) OR (cstate_rx_data_fifo = SM_RX_DATA_FIFO_SINGLE_QWORD_3 )) THEN
            write_xhdl6 <= '1';
         ELSE
            write_xhdl6 <= '0';
         END IF;
      END IF;
   END PROCESS;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            address_xhdl0 <= "000000000000";
         ELSE
            IF (tagram_data_rd_cycle = '1') THEN
               address_xhdl0 <= tagram_q_b(TAG_EP_ADDR_WIDTH - 1 DOWNTO 4);     -- tagram stores byte address.  Convert to QW address.
            ELSIF (write_xhdl6 = '1') THEN
               address_xhdl0 <= address_xhdl0 + "000000000001";
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- Requester Read state machine (Receive)
   --    Combinatorial state transition (case state)
   PROCESS (cstate_rx, init, valid_rx_dmard_cpld, rx_dfr, rx_dv)
   BEGIN
      CASE cstate_rx IS
         -- Reflects the beginning of a new descriptor

         WHEN CPLD_IDLE_3  =>     -- rx_ack upon rx_req and CPLD, and DMA Read tag
            IF (init = '0') THEN
               nstate_rx <= CPLD_REQ_3 ;
            ELSE
               nstate_rx <= CPLD_IDLE_3 ;
            END IF;

         WHEN CPLD_REQ_3  =>      -- set rx_ack
            IF (init = '1') THEN
               nstate_rx <= CPLD_IDLE_3 ;
            ELSIF (valid_rx_dmard_cpld = '1') THEN
               nstate_rx <= CPLD_ACK_3 ;
            ELSE
               nstate_rx <= CPLD_REQ_3 ;
            END IF;

         WHEN CPLD_ACK_3  =>      -- collect data for a given tag
            nstate_rx <= CPLD_DV_3 ;

         WHEN CPLD_DV_3  =>
            IF (rx_dfr = '0') THEN
               nstate_rx <= CPLD_LAST_3 ;
            ELSE
               nstate_rx <= CPLD_DV_3 ;
            END IF;
         -- Last data (rx_dfr ==0) :

         WHEN CPLD_LAST_3  =>
            IF (rx_dv = '0') THEN
               nstate_rx <= CPLD_REQ_3 ;
            ELSE
               nstate_rx <= CPLD_LAST_3 ;
            END IF;

         WHEN OTHERS =>
            nstate_rx <= CPLD_IDLE_3 ;
      END CASE;
   END PROCESS;

   -- Requester Read RX machine
   --    Registered state state transition
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate_rx <= DT_FIFO_3 ;
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate_rx <= nstate_rx;
      END IF;
   END PROCESS;

   PROCESS (cstate_rx_data_fifo, rx_data_fifo_empty, rx_data_fifo_q, transferring_data)
   BEGIN
      transferring_data_n <= transferring_data;
      CASE cstate_rx_data_fifo IS

         WHEN "000"  =>
         --WHEN SM_RX_DATA_FIFO_IDLE_3  =>
            IF (rx_data_fifo_empty = '0') THEN
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_READ_TAGRAM_1_3 ;
            ELSE
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_IDLE_3 ;
            END IF;

         WHEN "001"  =>
         --WHEN SM_RX_DATA_FIFO_READ_TAGRAM_1_3  =>
            IF (rx_data_fifo_q(RX_DATA_FIFO_WIDTH - 2) = '0') THEN
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_IDLE_3 ;
            ELSE
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_READ_TAGRAM_2_3 ;
            END IF;

         WHEN "010"  =>
         --WHEN SM_RX_DATA_FIFO_READ_TAGRAM_2_3  =>
          transferring_data_n <= '1';
            IF (rx_data_fifo_q(RX_DATA_FIFO_WIDTH - 1) = '0') THEN
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_RREQ_3 ;
            ELSE
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_SINGLE_QWORD_3 ;
            END IF;

         WHEN "011"  =>
         --WHEN SM_RX_DATA_FIFO_RREQ_3  =>
            IF (rx_data_fifo_q(RX_DATA_FIFO_WIDTH - 1) = '1') THEN
            IF (rx_data_fifo_empty = '0') THEN
                nstate_rx_data_fifo <= SM_RX_DATA_FIFO_READ_TAGRAM_1_3;
            ELSE
                nstate_rx_data_fifo <= SM_RX_DATA_FIFO_IDLE_3;
            END IF;
            transferring_data_n <= '0';
            ELSE
               nstate_rx_data_fifo <= SM_RX_DATA_FIFO_RREQ_3 ;
            END IF;

         WHEN "100"  =>
         --WHEN SM_RX_DATA_FIFO_SINGLE_QWORD_3  =>
              IF (rx_data_fifo_empty = '0') THEN
                nstate_rx_data_fifo <=  SM_RX_DATA_FIFO_READ_TAGRAM_1_3;
            ELSE
                nstate_rx_data_fifo <=  SM_RX_DATA_FIFO_IDLE_3;
            END IF;
              transferring_data_n <= '0';

         WHEN "101"  =>
         --WHEN SM_RX_DATA_FIFO_TAGRAM_UPD_3  =>
            nstate_rx_data_fifo <= SM_RX_DATA_FIFO_IDLE_3 ;

         WHEN OTHERS =>
            nstate_rx_data_fifo <= SM_RX_DATA_FIFO_IDLE_3 ;
      END CASE;
   END PROCESS;

   -- RX data fifo state machine
   --    Registered state state transition
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate_rx_data_fifo <= SM_RX_DATA_FIFO_IDLE_3 ;
       transferring_data   <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate_rx_data_fifo <= nstate_rx_data_fifo;
       transferring_data   <= transferring_data_n;
      END IF;
   END PROCESS;
   --/////////////////////////////////////////////////////////////////////////
   --
   -- MSI section :  if (USE_MSI>0)
   --
   app_msi_req <= '0' WHEN (USE_MSI = 0) ELSE
                  '1' WHEN (cstate_msi = MWR_REQ_MSI_3 ) ELSE
                  '0';
   msi_ready_int <= '0' WHEN (USE_MSI = 0) ELSE
                '1' WHEN (cstate_msi = START_MSI_3 ) ELSE
                '0';
   msi_busy_int <= '0' WHEN (USE_MSI = 0) ELSE
               '1' WHEN (cstate_msi = MWR_REQ_MSI_3 ) ELSE
               '0';
   PROCESS (cstate_msi, cstate_tx, cdt_msi, msi_sel, app_msi_ack, tx_ws,
            cdt_msi_first_descriptor, cdt_msi_second_descriptor, tx_cpld_first_descriptor, tx_cpld_second_descriptor)
   BEGIN
      CASE cstate_msi IS

         WHEN "000"  =>
         --WHEN IDLE_MSI_3  =>
            IF ((cstate_tx = DONE_4 ) AND  --(cdt_msi = '1')) THEN
                (((cdt_msi_first_descriptor = '1') AND (tx_cpld_first_descriptor='1')) OR
                 ((cdt_msi_second_descriptor = '1') AND (tx_cpld_second_descriptor='1')) ) ) THEN
               nstate_msi <= START_MSI_3 ;
            ELSE
               nstate_msi <= IDLE_MSI_3 ;
            END IF;
         -- Waiting for Top level arbitration (tx_sel) prior to tx MEM64_WR

         WHEN "001"  =>
         --WHEN START_MSI_3  =>
            IF (msi_sel = '1') AND (tx_ws ='0') THEN
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

   --///////////////////////////////////////////////////////////////////
   --
   -- TAG Section

   -- Write in TAG RAM the offset of EP memory
   -- The TAG RAM content {tx_length_dw[9:1], tx_tag_addr_offset[AVALON_WADDR-1:0]}
   -- tx_length_dw[9:1]       : QWORD LENGTH to know when recycle TAG
   -- tx_tag_addr_offset[AVALON_WADDR-1:0] : EP Address offset (where PCIE write to)
   tagram_wren_a <= '1' WHEN ((cstate_tx = MRD_REQ_4 ) AND (tx_req_xhdl5 = '1') AND (tx_req_delay = '0')) ELSE
                    '0';
   tagram_data_a <= (tx_length_dw(9 DOWNTO 0) & tx_tag_addr_offset(TAG_EP_ADDR_WIDTH - 1 DOWNTO 0));        -- tx_tag_addr_offset is in Bytes
   tagram_address_a(MAX_TAG_WIDTH - 1 DOWNTO 0) <= tx_tag_tx_desc(MAX_TAG_WIDTH - 1 DOWNTO 0);

   -- TX TAG Signaling FIFO TAG
   -- There are 2 FIFO TAGs :
   --    tag_scfifo_first_descriptor
   --    tag_scfifo_second_descriptor
   -- The FIFO TAG are used to recycle TAGS
   -- The read requester module issues MRD for
   -- two consecutive descriptors (first_descriptor, second descriptor)
   -- The TAG assignment is such
   --        MAX_NUMTAG : Maximum number of TAG available from the core
   --        TAG_TRACK_WIDTH : Number of tag for both descritpor
   --        TAG_TRACK_HALF_WIDTH : Number of tag for each descriptor
   -- The one hot register tag_track_one_hot tracks the TAG which has been
   -- recycled accross both descriptors
   tag_fifo_sclr <= init;

   PROCESS (tagram_q_b, rx_data_fifo_length_hold, tagram_data_rd_cycle, rcving_last_cpl_for_tag) BEGIN
       IF (tagram_data_rd_cycle = '1') THEN
           IF (tagram_q_b(TAG_EP_ADDR_WIDTH+9 DOWNTO TAG_EP_ADDR_WIDTH) > rx_data_fifo_length_hold) THEN
               rcving_last_cpl_for_tag_n <= '0';
           ELSE
               rcving_last_cpl_for_tag_n <= '1';
           END IF;
       ELSE
           rcving_last_cpl_for_tag_n <= rcving_last_cpl_for_tag;
       END IF;

   END PROCESS;

   PROCESS (rcving_last_cpl_for_tag_n, transferring_data, rx_data_fifo_q) BEGIN
       IF ( (transferring_data = '1' ) AND
             (rcving_last_cpl_for_tag_n = '1') AND (rx_data_fifo_q(RX_DATA_FIFO_WIDTH-1) = '1')) THEN
            got_all_cpl_for_tag <= '1';  --release tag when dv_end is received, and this is the end of the last cpl expected for the tag
       ELSE
            got_all_cpl_for_tag <= '0';
       END IF;
   END PROCESS;



   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tag_track_one_hot(TAG_TRACK_WIDTH - 1 DOWNTO 0) <= xhdl_zero_qqword(TAG_TRACK_WIDTH - 1 DOWNTO 0);
         ELSIF (cstate_tx = MRD_ACK_4 ) THEN
            FOR i IN 2 + RC_SLAVE_USETAG TO  MAX_NUMTAG - 1 LOOP
               IF (tx_tag_tx_desc = to_stdlogicvector(i, 8) ) THEN
                  tag_track_one_hot(i - 2) <= '1';
               END IF;
            END LOOP;
         ELSIF (got_all_cpl_for_tag = '1') THEN
            FOR i IN 2 + RC_SLAVE_USETAG TO  MAX_NUMTAG - 1 LOOP
               IF (tagram_address_b = to_stdlogicvector(i, MAX_TAG_WIDTH) ) THEN
                  tag_track_one_hot(i - 2) <= '0';
               END IF;
            END LOOP;
         ELSIF (tagram_wren_b_mrd_ack = '1') THEN
            FOR i IN 2 + RC_SLAVE_USETAG TO  MAX_NUMTAG - 1 LOOP
               IF (tagram_address_b_mrd_ack = to_stdlogicvector(i, MAX_TAG_WIDTH) ) THEN
                  tag_track_one_hot(i - 2) <= '0';
               END IF;
            END LOOP;
         END IF;
      END IF;
   END PROCESS;


   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cpl_pending <= '0' ;
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tag_track_one_hot(TAG_TRACK_WIDTH - 1 DOWNTO 0) = xhdl_zero_qqword(TAG_TRACK_WIDTH - 1 DOWNTO 0)) THEN
            cpl_pending <= '0';
         ELSE
            cpl_pending <= '1';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
        IF ((cstate_tx = MRD_ACK_4) AND (got_all_cpl_for_tag = '1'))  THEN
          tagram_wren_b_mrd_ack <= '1';
         ELSE
            tagram_wren_b_mrd_ack <= '0';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((cstate_tx = MRD_ACK_4) AND (got_all_cpl_for_tag = '1'))  THEN
            tagram_address_b_mrd_ack <= tagram_address_b;
         ELSE
            tagram_address_b_mrd_ack(MAX_TAG_WIDTH - 1 DOWNTO 0) <= xhdl_zero_qqword(MAX_TAG_WIDTH - 1 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;

   tx_cpld_first_descriptor <= NOT(tag_track_one_hot(0)) WHEN (MAX_NUMTAG = 4) ELSE
                               '1' WHEN (tag_track_one_hot(TAG_TRACK_HALF_WIDTH - 1 DOWNTO 0) = "000000000000000") ELSE
                               '0';

   tx_cpld_second_descriptor <= NOT(tag_track_one_hot(1)) WHEN (MAX_NUMTAG = 4) ELSE
                                '1' WHEN (tag_track_one_hot(TAG_TRACK_WIDTH - 1 DOWNTO TAG_TRACK_HALF_WIDTH) = "000000000000000") ELSE
                                '0';

   tx_fifo_rdreq_first_descriptor <= '1' WHEN ((tx_first_descriptor_cycle = '1') AND (cstate_tx = GET_TAG_4 )) ELSE
                                     '0';
   tx_fifo_rdreq_second_descriptor <= '1' WHEN ((tx_first_descriptor_cycle = '0') AND (cstate_tx = GET_TAG_4 )) ELSE
                                      '0';

   -- TX TAG counter first descriptor
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_tag_cnt_first_descriptor <= FIRST_DMARD_TAG_MAX_TAG_WIDTH ;
         ELSIF ((cstate_tx = MRD_REQ_4 ) AND (tx_ack = '1') AND (tx_first_descriptor_cycle = '1')) THEN
            IF (tx_tag_cnt_first_descriptor /= MAX_NUMTAG_VAL_FIRST_DESCRIPTOR_MAX_TAG_WIDTH ) THEN
               tx_tag_cnt_first_descriptor <= tx_tag_cnt_first_descriptor + "01";
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_tag_mux_first_descriptor <= '0';
         ELSIF ((tx_tag_cnt_first_descriptor = MAX_NUMTAG_VAL_FIRST_DESCRIPTOR_MAX_TAG_WIDTH ) AND (cstate_tx = MRD_REQ_4 ) AND (tx_ack = '1')) THEN
            tx_tag_mux_first_descriptor <= '1';
         END IF;
      END IF;
   END PROCESS;

   tx_tag_wire_mux_first_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0) <= tx_tag_cnt_first_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0) WHEN (tx_tag_mux_first_descriptor = '0') ELSE
                                                                   tx_tag_fifo_first_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0);

   -- TX TAG counter second descriptor
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_tag_cnt_second_descriptor <= FIRST_DMARD_TAG_SEC_DESCRIPTOR_MAX_TAG_WIDTH ;
         ELSIF ((tx_ack = '1') AND (cstate_tx = MRD_REQ_4 ) AND (tx_first_descriptor_cycle = '0')) THEN
            IF (tx_tag_cnt_second_descriptor /= MAX_NUMTAG_VAL_MAX_TAG_WIDTH ) THEN
               tx_tag_cnt_second_descriptor <= tx_tag_cnt_second_descriptor + "01";
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_tag_mux_second_descriptor <= '0';
         ELSIF ((tx_tag_cnt_second_descriptor = MAX_NUMTAG_VAL_MAX_TAG_WIDTH ) AND (tx_ack = '1') AND (cstate_tx = MRD_REQ_4 ) AND (tx_first_descriptor_cycle = '0')) THEN
            tx_tag_mux_second_descriptor <= '1';
         END IF;
      END IF;
   END PROCESS;

   tx_tag_wire_mux_second_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0) <= tx_tag_cnt_second_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0) WHEN (tx_tag_mux_second_descriptor = '0') ELSE
                                                                    tx_tag_fifo_second_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_tag_tx_desc <= "00000000";
         ELSIF ((cstate_tx = TX_LENGTH_4 ) AND (tx_first_descriptor_cycle = '1')) THEN
            tx_tag_tx_desc(MAX_TAG_WIDTH - 1 DOWNTO 0) <= tx_tag_wire_mux_first_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0);
         ELSIF ((cstate_tx = TX_LENGTH_4 ) AND (tx_first_descriptor_cycle = '0')) THEN
            tx_tag_tx_desc(MAX_TAG_WIDTH - 1 DOWNTO 0) <= tx_tag_wire_mux_second_descriptor(MAX_TAG_WIDTH - 1 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;

   rx_second_descriptor_tag <= '1' WHEN (rx_data_fifo_q(RX_DATA_FIFO_WIDTH)='1') ELSE
                               '0';
   rx_fifo_wrreq_first_descriptor <= '1' WHEN ( (got_all_cpl_for_tag = '1') AND (rx_second_descriptor_tag = '0')) ELSE
                                     '0';
   rx_fifo_wrreq_second_descriptor <= '1' WHEN ((got_all_cpl_for_tag = '1') AND (rx_second_descriptor_tag = '1')) ELSE
                                      '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            tx_first_descriptor_cycle <= '1';
         ELSIF ((cstate_tx = MRD_ACK_4 ) AND (cdt_length_dw_tx = "0000000000000000")) THEN
            tx_first_descriptor_cycle <= NOT(tx_first_descriptor_cycle);
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            next_is_second <= '0';
         ELSIF (cstate_tx = MWR_ACK_UPD_DT_4 ) THEN
            IF ((eplast_upd_first_descriptor = '1') AND (eplast_upd_second_descriptor = '1') AND (next_is_second = '0')) THEN
               next_is_second <= '1';
            ELSE
               next_is_second <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            eplast_upd_first_descriptor <= '0';
         ELSIF ((cstate_tx = MRD_ACK_4 ) AND (cdt_length_dw_tx = "0000000000000000") AND (tx_first_descriptor_cycle = '1')) THEN
            eplast_upd_first_descriptor <= '1';
         ELSIF ((cstate_tx = MWR_ACK_UPD_DT_4 ) AND (tx_cpld_first_descriptor = '1')) THEN
            IF (eplast_upd_second_descriptor = '0') THEN
               eplast_upd_first_descriptor <= '0';
            ELSIF (next_is_second = '0') THEN
               eplast_upd_first_descriptor <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (init = '1') THEN
            eplast_upd_second_descriptor <= '0';
         ELSIF ((cstate_tx = MRD_ACK_4 ) AND (cdt_length_dw_tx = "0000000000000000") AND (tx_first_descriptor_cycle = '0')) THEN
            eplast_upd_second_descriptor <= '1';
         ELSIF ((cstate_tx = MWR_ACK_UPD_DT_4 ) AND (tx_cpld_second_descriptor = '1')) THEN
            IF (eplast_upd_first_descriptor = '0') THEN
               eplast_upd_second_descriptor <= '0';
            ELSIF (next_is_second = '1') THEN
               eplast_upd_second_descriptor <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;

   -- Pipe the TAG FIFO write inputs for performance
     PROCESS (clk_in)
     BEGIN
        IF (clk_in'EVENT AND clk_in = '1') THEN
         tagram_address_b_reg <= tagram_address_b;
           IF (init = '1') THEN
            rx_fifo_wrreq_first_descriptor_reg  <= '0';
           rx_fifo_wrreq_second_descriptor_reg <= '0';
           ELSE
          rx_fifo_wrreq_first_descriptor_reg  <= rx_fifo_wrreq_first_descriptor;
           rx_fifo_wrreq_second_descriptor_reg <= rx_fifo_wrreq_second_descriptor;
           END IF;
        END IF;
   END PROCESS;


   -- TAG FIFO
   --


   tag_scfifo_first_descriptor : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => TAG_FIFO_DEPTH,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => MAX_TAG_WIDTH,
         lpm_widthu               => MAX_TAG_WIDTHU,
         overflow_checking        => "ON",
         underflow_checking       => "ON",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => tag_fifo_sclr,

         -- RX push TAGs into TAG_FIFO
         data   => tagram_address_b_reg,
         wrreq  => rx_fifo_wrreq_first_descriptor_reg,

         -- TX pop TAGs from TAG_FIFO
         rdreq  => tx_fifo_rdreq_first_descriptor,
         q      => tx_tag_fifo_first_descriptor,

         empty  => tag_fifo_empty_first_descriptor,
         full   => tag_fifo_full_first_descriptor
      );



   tag_scfifo_second_descriptor : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => TAG_FIFO_DEPTH,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => MAX_TAG_WIDTH,
         lpm_widthu               => MAX_TAG_WIDTHU,
         overflow_checking        => "ON",
         underflow_checking       => "ON",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => tag_fifo_sclr,

         -- RX push TAGs into TAG_FIFO
         data   => tagram_address_b_reg,
         wrreq  => rx_fifo_wrreq_second_descriptor_reg,

         -- TX pop TAGs from TAG_FIFO
         rdreq  => tx_fifo_rdreq_second_descriptor,
         q      => tx_tag_fifo_second_descriptor,

         empty  => tag_fifo_empty_second_descriptor,
         full   => tag_fifo_full_second_descriptor
      );



   tag_dpram : altsyncram
      GENERIC MAP (
         address_reg_b                       => "CLOCK0",
         indata_reg_b                        => "CLOCK0",
         wrcontrol_wraddress_reg_b           => "CLOCK0",
         intended_device_family              => "Stratix II",
         numwords_a                          => TAG_RAM_NUMWORDS,
         numwords_b                          => TAG_RAM_NUMWORDS,
         operation_mode                      => "BIDIR_DUAL_PORT",
         outdata_aclr_a                      => "NONE",
         outdata_aclr_b                      => "NONE",
         outdata_reg_a                       => "CLOCK0",
         outdata_reg_b                       => "CLOCK0",
         power_up_uninitialized              => "FALSE",
         read_during_write_mode_mixed_ports  => "DONT_CARE",
         widthad_a                           => TAG_RAM_WIDTHAD,
         widthad_b                           => TAG_RAM_WIDTHAD,
         width_a                             => TAG_RAM_WIDTH,
         width_b                             => TAG_RAM_WIDTH,
         width_byteena_a                     => ONE_INTEGER,
         width_byteena_b                     => ONE_INTEGER,
         lpm_type                            => "altsyncram"
      )
      PORT MAP (
         clock0          => clk_in,

         -- Port B is used by TX module to update the TAG
         data_a          => tagram_data_a,
         wren_a          => tagram_wren_a,
         address_a       => tagram_address_a,

         -- Port B is used by RX module to update the TAG
         data_b          => tagram_data_b,
         wren_b          => tagram_wren_b,
         address_b       => tagram_address_b,
         q_b             => tagram_q_b,

         rden_b          => cst_one,
         aclr0           => cst_zero,
         aclr1           => cst_zero,
         addressstall_a  => cst_zero,
         addressstall_b  => cst_zero,
         byteena_a       => xhdl_other_one(0 DOWNTO 0),
         byteena_b       => xhdl_other_one(0 DOWNTO 0),
         clock1          => cst_one,
         clocken0        => cst_one,
         clocken1        => cst_one,
         q_a             => xhdl_open_dqword(TAG_RAM_WIDTH - 1 DOWNTO 0)
      );



   rx_data_fifo : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => RX_DATA_FIFO_NUMWORDS,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => RX_DATA_FIFO_WIDTH + 11,
         lpm_widthu               => RX_DATA_FIFO_WIDTHU,
         overflow_checking        => "ON",
         underflow_checking       => "ON",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock  => clk_in,
         sclr   => rx_data_fifo_sclr,

         -- RX push TAGs into TAG_FIFO
         data   => rx_data_fifo_data,
         wrreq  => rx_data_fifo_wrreq,

         -- TX pop TAGs from TAG_FIFO
         rdreq  => rx_data_fifo_rdreq,
         q      => rx_data_fifo_q,

         empty  => rx_data_fifo_empty,
         full   => rx_data_fifo_full,
         usedw  => rx_data_fifo_usedw
      );

END ARCHITECTURE altpcie;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY add_sub_dmard128 IS
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        datab       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
END add_sub_dmard128;


ARCHITECTURE SYN OF add_sub_dmard128 IS

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

--///////////////////////////////////////////////////////////////////////////
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.all;

ENTITY add_sub_dmard128_cst IS
    PORT
    (
        clock       : IN STD_LOGIC ;
        dataa       : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        result      : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
    );
END add_sub_dmard128_cst;


ARCHITECTURE SYN OF add_sub_dmard128_cst IS

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
