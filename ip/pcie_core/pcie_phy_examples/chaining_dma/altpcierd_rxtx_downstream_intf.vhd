LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in  
--  * the chaining DMA design example. It contains the descriptor header 
--  * table registers which get programmed by the software application.
--  */
-- synthesis translate_off 
-- synthesis translate_on
-- synthesis verilog_input_version verilog_2001 

-------------------------------------------------------------------------------
-- Title         : altpcierd_rxtx_intf
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_control_status.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
--
--  Description:  This module contains Chaining DMA control and status  
--                registers accessible by the root port on BAR 2/3.
--                
--
-------------------------------------------------------------------------------
-- Copyright  2008 Altera Corporation. All rights reserved.  Altera products are
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

ENTITY altpcierd_rxtx_downstream_intf IS
   GENERIC (
      AVALON_ST_128            : INTEGER := 0;
      AVALON_WDATA             : INTEGER := 64;
      AVALON_BE_WIDTH          : INTEGER := 8;
      MEM_ADDR_WIDTH           : INTEGER := 10 
      
      -- register read data   output reg                    mem_wr_ena,         // pulse.  register write enable
      -- pulse.  register read enable
      -- register address (BAR 2/3 is 128 bytes max)
      -- register data to be written 
      
      -- register address (BAR 2/3 is 128 bytes max)  
      
     -- AVALON_WDATA_WIDTHU      : INTEGER := 7 WHEN (AVALON_WDATA = 128) ELSE 6;
      

   );
   PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      cfg_busdev               : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      rx_req                   : IN STD_LOGIC;
      rx_desc                  : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                  : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      rx_be                    : IN STD_LOGIC_VECTOR(AVALON_BE_WIDTH - 1 DOWNTO 0);
      rx_dv                    : IN STD_LOGIC;
      rx_dfr                   : IN STD_LOGIC;
      rx_ack                   : OUT STD_LOGIC;
      rx_ws                    : OUT STD_LOGIC;
      tx_ws                    : IN STD_LOGIC;
      tx_ack                   : IN STD_LOGIC;
      tx_sel                   : IN STD_LOGIC;
      tx_desc                  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_data                  : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      tx_dfr                   : OUT STD_LOGIC;
      tx_dv                    : OUT STD_LOGIC;
      tx_req                   : OUT STD_LOGIC;
      tx_ready                 : OUT STD_LOGIC;
      tx_busy                  : OUT STD_LOGIC;
      sel_epmem                : OUT STD_LOGIC;
      sel_ctl_sts              : OUT STD_LOGIC;
      mem_rd_data_valid        : IN STD_LOGIC;
      mem_rd_addr              : OUT STD_LOGIC_VECTOR(MEM_ADDR_WIDTH - 1 DOWNTO 0);
      mem_rd_data              : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      mem_rd_ena               : OUT STD_LOGIC;
      mem_wr_ena               : OUT STD_LOGIC;
      mem_wr_addr              : OUT STD_LOGIC_VECTOR(MEM_ADDR_WIDTH - 1 DOWNTO 0);
      mem_wr_data              : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      mem_wr_be                : OUT STD_LOGIC_VECTOR(AVALON_BE_WIDTH - 1 DOWNTO 0);
      reg_rd_data              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      reg_rd_data_valid        : IN STD_LOGIC;
      reg_wr_addr              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_rd_addr              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_wr_data              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
   );
END altpcierd_rxtx_downstream_intf;

ARCHITECTURE trans OF altpcierd_rxtx_downstream_intf IS
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

   -- cstate_rx states 
   -- CONSTANT RX_IDLE                  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";      -- Wait for PciE Request
   -- CONSTANT RX_DESC2_ACK             : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";      -- Acking PciE Request in this cycle (2nd Descriptor cycle)
   -- CONSTANT RX_START_CPL             : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";      -- If Request is a READ, then wait for Completion to start
   -- CONSTANT RX_WAIT_END_CPL          : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";      -- Wait for Completion to end
   -- CONSTANT RX_DV_PAYLD              : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";      -- Write payload to memory
      
    -- cstate_tx states 
    -- CONSTANT TX_IDLE                  : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";      -- Wait for cstate_rx to request a Completion
    -- CONSTANT TX_SEND_REQ              : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";      -- Send Completion TLP to PciE
    -- CONSTANT TX_SEND_DV_WAIT_ACK      : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010";      -- Drive tx_dv on PciE Desc/Data interface
    -- CONSTANT TX_DV_PAYLD              : STD_LOGIC_VECTOR(2 DOWNTO 0) := "011";      -- Wait for PciE Desc/Data interface to accept data phase
    -- CONSTANT TX_WAIT_ARB              : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100"       -- Wait for external arbiter to give this module access to the TX interface
      
   type CSTATE_TX_TYPE is (RX_DV_PAYLD, RX_WAIT_END_CPL, RX_START_CPL, RX_DESC2_ACK, RX_IDLE); 
   type CSTATE_RX_TYPE is (TX_WAIT_ARB, TX_DV_PAYLD, TX_SEND_DV_WAIT_ACK, TX_SEND_REQ, TX_IDLE);
    
    
   SIGNAL cstate_rx                 : CSTATE_TX_TYPE;
   SIGNAL cstate_tx                 : CSTATE_RX_TYPE;
   SIGNAL rx_bar_hit_n              : STD_LOGIC;
   SIGNAL rx_is_rdreq               : STD_LOGIC;
   SIGNAL rx_is_wrreq               : STD_LOGIC;
   SIGNAL cfg_busdev_reg            : STD_LOGIC_VECTOR(12 DOWNTO 0);
   SIGNAL rx_hold_tag               : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL rx_hold_reqid             : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rx_hold_addr              : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL rx_hold_length            : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL tx_desc_tag               : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_desc_req_id            : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL tx_desc_addr              : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL tx_desc_lbe               : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL tx_desc_length            : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL rx_start_write            : STD_LOGIC;
   SIGNAL num_dw_to_read            : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL mem_num_to_read           : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL mem_num_to_read_minus_one : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL fifo_rd_count             : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL mem_read_count            : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL rx_start_read             : STD_LOGIC;
   SIGNAL tx_ready_del              : STD_LOGIC;
   SIGNAL tx_arb_granted            : STD_LOGIC;
   SIGNAL rx_sel_epmem              : STD_LOGIC;
   SIGNAL start_tx                  : STD_LOGIC;
   SIGNAL fifo_rd                   : STD_LOGIC;
   -- wire       fifo_wr; 
   SIGNAL fifo_almost_full          : STD_LOGIC;
   SIGNAL fifo_empty                : STD_LOGIC;
   SIGNAL rx_is_downstream_req_n    : STD_LOGIC;
   SIGNAL rx_is_rdreq_n             : STD_LOGIC;
   SIGNAL rx_is_wrreq_n             : STD_LOGIC;
   SIGNAL rx_is_msg_n               : STD_LOGIC;
   SIGNAL fifo_prefetch             : STD_LOGIC;
   SIGNAL rx_do_cpl                 : STD_LOGIC;
   SIGNAL rx_mem_bar_hit            : STD_LOGIC;
   SIGNAL rx_reg_bar_hit            : STD_LOGIC;
   --  wire[AVALON_WDATA-1:0] fifo_data_in;
   SIGNAL fifo_data_out             : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);


    
   --/////////////////////////////////////////
   -- RX state machine - Receives requests
   -- This is the main request controller
   --////////////////////////////////////////
   
   -- this module responds to BAR0/1/4/5 downstream requests
   -- assign rx_bar_hit_n  = (rx_desc[133] | rx_desc[132] | rx_desc[129] | rx_desc[128]) ? 1'b1 : 1'b0;   
   -- service all downstream requests   
   
   -- wait for a downstream request addressed to BAR 2/3
   
   -- bar 2/3
   -- bar 0/1, 4/5
   
   -- 4DW header
   -- Address is 1 DW offset
   -- Address is 2 DW offset
   -- Address is 3 DW offset
   -- Address is 0 DW offset                          
   -- 3DW header
   -- Address is 1 DW offset
   -- Address is 2 DW offset
   -- Address is 3 DW offset
   -- Address is 0 DW offset                            
   
   -- hold rx_desc fields for use in cpl
   
   -- If request is READ, then send a
   -- request to TX SM to send cpl.
   -- Else, wait for another request
   -- last data cycle
   -- Wait for TX side to service the cpl request  
   -- Wait for TX side to finish sending the CPL
   
   --//////////////////////////////////////////////////////////////
   -- TX state machine - sends Completions
   -- This module is a slave to the RX state machine cstate_rx
   --////////////////////////////////////////////////////////////// 
   
   --//////////////////
   -- tx_desc fields
   
   --////////////////////////
   -- tx_req, tx_dfr, tx_dv
   
   -- wait for a request for CPL
   -- request access to PciE TX desc/data interface
   -- start transmission on PciE TX desc/data interface
   
   -- Format/Type = CplD
   -- Completor ID bus, dev #
   -- Completor ID function #
   -- Successful completion
   -- Read request is limited to Max payload size
   
   --//////////////////////////////////////////////////////////////////////////////////
   -- Translate PCIE WRITE Requests to Memory WRITE Ctl and Datapath 
   --////////////////////////////////////////////////////////////////////////////////// 
   
   -- pipeline this datapath
   -- delay along with control signals.
   --////////////////////////////
   -- MEMORY WRITE ENA, ADDRESS 
   
   -- 128-bit interface 
   -- 64-bit interface  
   -- 3DW header
   -- 128-bit interface 
   -- 64-bit interface  
   
   --////////////////////////////////  
   -- MEMORY WRITE DATAPATH
   -- data is written on mem_wr_ena 
   
   --//////////////////////////////////////////////////////////////////////////////////
   -- Translate PCIE READ Requests to Memory READ Ctl and Datapath 
   --////////////////////////////////////////////////////////////////////////////////// 
   
   -- pipeline this datapath
   --///////////////////////////
   -- MEMORY READ ADDR/CONTROL
   
   --///////////////////////////
   -- MEMORY READ DATAPATH 
   
   SIGNAL fifo_wr                   : STD_LOGIC;
   SIGNAL fifo_data_in              : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   -- X-HDL generated signals

   SIGNAL xhdl6 : STD_LOGIC;
   SIGNAL xhdl7 : STD_LOGIC;
   SIGNAL xhdl8 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl9 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl10 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl11 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl12 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl13 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL xhdl14 : STD_LOGIC;
   SIGNAL xhdl15 : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl16 : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH - 1 DOWNTO 0);
   SIGNAL xhdl17 : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH - 1 DOWNTO 0);
   SIGNAL xhdl18 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl19 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl20 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl21 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl22 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL xhdl23 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl24 : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl25 : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_dfr_xhdl2              : STD_LOGIC;
   SIGNAL tx_dv_xhdl3               : STD_LOGIC;
   SIGNAL tx_req_xhdl5              : STD_LOGIC;
   SIGNAL tx_ready_xhdl4            : STD_LOGIC;
   SIGNAL mem_rd_addr_xhdl0         : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH - 1 DOWNTO 0);
   SIGNAL mem_wr_addr_xhdl1         : STD_LOGIC_VECTOR(MEM_ADDR_WIDTH - 1 DOWNTO 0);
   
   SIGNAL zeros_64  : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL zeros_128 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL zeros_8   : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL zeros_16  : STD_LOGIC_VECTOR(15 DOWNTO 0);
 
   SIGNAL open_almost_empty : STD_LOGIC;
   SIGNAL open_full : STD_LOGIC;
   SIGNAL gnd_sclr : STD_LOGIC;
   SIGNAL open_usedw : STD_LOGIC_VECTOR(3 DOWNTO 0);
  
BEGIN

   zeros_64  <= "0000000000000000000000000000000000000000000000000000000000000000";
   zeros_128 <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";                      
   zeros_8   <= "00000000";   
   zeros_16  <= "0000000000000000";   
   
   gnd_sclr <= '0';
   
   -- Drive referenced outputs
   tx_dfr <= tx_dfr_xhdl2;
   tx_dv <= tx_dv_xhdl3;
   tx_req <= tx_req_xhdl5;
   tx_ready <= tx_ready_xhdl4;
   mem_rd_addr <= mem_rd_addr_xhdl0;
   mem_wr_addr <= mem_wr_addr_xhdl1;
   rx_ws <= '0';
   rx_bar_hit_n <= '1';
   rx_is_rdreq_n <= '1' WHEN ((rx_desc(126) = '0') AND (rx_desc(124 DOWNTO 120) = "00000")) ELSE
                    '0';
   rx_is_wrreq_n <= '1' WHEN ((rx_desc(126) = '1') AND (rx_desc(124 DOWNTO 120) = "00000")) ELSE
                    '0';
                    
                    
   rx_is_msg_n <=   '1' WHEN (rx_desc(125 DOWNTO 123) = "110") ELSE '0';
                    
   rx_is_downstream_req_n <= '1' WHEN ((rx_is_rdreq_n = '1') OR (rx_is_wrreq_n = '1') OR (rx_is_msg_n = '1') ) ELSE
                             '0';
   xhdl6 <= '1' WHEN ((rx_desc(131) OR rx_desc(130)) = '1') ELSE
                             '0';
   xhdl7 <= '1' WHEN ((rx_desc(134) OR rx_desc(133) OR rx_desc(132) OR rx_desc(129) OR rx_desc(128)) = '1') ELSE
                             '0';
   xhdl8 <= (rx_desc(105 DOWNTO 96) + "0000000010") WHEN (AVALON_ST_128 = 1) ELSE
                             (rx_desc(105 DOWNTO 96) + "0000000000");
   xhdl9 <= (rx_desc(105 DOWNTO 96) + "0000000011") WHEN (AVALON_ST_128 = 1) ELSE
                             (rx_desc(105 DOWNTO 96) + "0000000001");
   xhdl10 <= (rx_desc(105 DOWNTO 96) + "0000000010") WHEN (AVALON_ST_128 = 1) ELSE
                             (rx_desc(105 DOWNTO 96) + "0000000000");
   xhdl11 <= (rx_desc(105 DOWNTO 96) + "0000000011") WHEN (AVALON_ST_128 = 1) ELSE
                             (rx_desc(105 DOWNTO 96) + "0000000001");
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         rx_ack <= '0';
         cstate_rx <= RX_IDLE;
         rx_is_rdreq <= '0';
         rx_is_wrreq <= '0';
         rx_start_read <= '0';
         rx_hold_tag <= "00000000";
         rx_hold_reqid <= "0000000000000000";
         rx_hold_addr <= "0000000000000000000000000000000000000000000000000000000000000000";
         rx_hold_length <= "00000000000";
         rx_start_write <= '0';
         rx_sel_epmem <= '0';
         sel_ctl_sts <= '0';
         rx_do_cpl <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         CASE cstate_rx IS
            WHEN RX_IDLE =>
               rx_start_write <= '0';
               IF ((rx_req = '1') AND (rx_bar_hit_n = '1') AND (rx_is_downstream_req_n = '1')) THEN
                  cstate_rx <= RX_DESC2_ACK;
                  rx_ack <= '1';
                  rx_is_rdreq <= rx_is_rdreq_n;
                  rx_is_wrreq <= rx_is_wrreq_n;
                  rx_do_cpl <= rx_is_rdreq_n;
                  rx_start_write <= rx_is_wrreq_n;
                  rx_hold_length <= ('0' & rx_desc(105 DOWNTO 96));
                  sel_ctl_sts <= xhdl6;
                  rx_sel_epmem <= xhdl7;
               ELSE
                  rx_sel_epmem <= '0';
                  sel_ctl_sts <= '0';
                  rx_is_rdreq <= '0';
                  rx_is_wrreq <= '0';
                  rx_do_cpl <= '0';
                  cstate_rx <= cstate_rx;
               END IF;
            WHEN RX_DESC2_ACK =>
               rx_ack <= '0';
               rx_start_write <= '0';
               IF (rx_desc(125) = '1') THEN
                  CASE rx_desc(3 DOWNTO 2) IS
                     WHEN "01" =>
                        num_dw_to_read <= rx_desc(105 DOWNTO 96) + "0000000001";
                     WHEN "10" =>
                        num_dw_to_read <= xhdl8;
                     WHEN "11" =>
                        num_dw_to_read <= xhdl9;
                     WHEN OTHERS =>
                        num_dw_to_read <= rx_desc(105 DOWNTO 96) + "0000000000";
                  END CASE;
                  rx_hold_addr <= rx_desc(63 DOWNTO 0);
               ELSE
                  CASE rx_desc(35 DOWNTO 34) IS
                     WHEN "01" =>
                        num_dw_to_read <= rx_desc(105 DOWNTO 96) + "0000000001";
                     WHEN "10" =>
                        num_dw_to_read <= xhdl10;
                     WHEN "11" =>
                        num_dw_to_read <= xhdl11;
                     WHEN OTHERS =>
                        num_dw_to_read <= rx_desc(105 DOWNTO 96) + "0000000000";
                  END CASE;
                  rx_hold_addr(63 DOWNTO 32) <= "00000000000000000000000000000000";
                  rx_hold_addr(31 DOWNTO 0) <= rx_desc(63 DOWNTO 32);
               END IF;
               rx_hold_tag <= rx_desc(79 DOWNTO 72);
               rx_hold_reqid <= rx_desc(95 DOWNTO 80);
               IF (rx_is_rdreq = '1') THEN
                  rx_start_read <= '1';
                  cstate_rx <= RX_START_CPL;
               ELSIF (rx_is_wrreq = '1') THEN
                  IF (rx_dfr = '1') THEN
                     cstate_rx <= RX_DV_PAYLD;
                  ELSE
                     cstate_rx <= RX_IDLE;
                  END IF;
               ELSE
                  cstate_rx <= RX_IDLE;
               END IF;
            WHEN RX_DV_PAYLD =>
               rx_start_write <= '0';
               IF (rx_dfr = '0') THEN
                  cstate_rx <= RX_IDLE;
               ELSE
                  cstate_rx <= cstate_rx;
               END IF;
            WHEN RX_START_CPL =>
               rx_start_read <= '0';
               IF (cstate_tx /= TX_IDLE) THEN
                  cstate_rx <= RX_WAIT_END_CPL;
               ELSE
                  cstate_rx <= cstate_rx;
               END IF;
            WHEN RX_WAIT_END_CPL =>
               IF (cstate_tx = TX_IDLE) THEN
                  cstate_rx <= RX_IDLE;
               ELSE
                  cstate_rx <= cstate_rx;
               END IF;
            WHEN OTHERS =>
                  cstate_rx <= cstate_rx;
         END CASE;
      END IF;
   END PROCESS;
   tx_arb_granted <= to_stdlogic((tx_ready_del = '1') AND (tx_sel = '1'));
   start_tx <= to_stdlogic((tx_arb_granted = '1') AND (fifo_empty = '0'));
   tx_data <= fifo_data_out;
   xhdl12 <= fifo_rd_count + "0000000001" WHEN (fifo_rd = '1') ELSE
              fifo_rd_count;
   xhdl13 <= "0000" WHEN (rx_hold_length(9 DOWNTO 0) = "0000000001") ELSE
              "1111";
   xhdl14 <= '1' WHEN (rx_do_cpl = '1') ELSE
              tx_ready_xhdl4;
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate_tx <= TX_IDLE;
         tx_req_xhdl5 <= '0';
         tx_dfr_xhdl2 <= '0';
         tx_dv_xhdl3 <= '0';
         cfg_busdev_reg <= "0000000000000";
         tx_ready_xhdl4 <= '0';
         tx_ready_del <= '0';
         tx_busy <= '0';
         fifo_rd_count <= "0000000000";
         tx_desc_length <= "0000000000";
         tx_desc_lbe <= "0000";
         fifo_prefetch <= '0';
         tx_desc_addr   <= (OTHERS => '0'); 
         tx_desc_req_id <= (OTHERS => '0');
         tx_desc_tag    <= (OTHERS => '0');
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         tx_ready_del <= tx_ready_xhdl4;
         IF (cstate_tx = TX_IDLE) THEN
            fifo_rd_count <= "0000000000";
         ELSE
            fifo_rd_count <= xhdl12;
         END IF;
         cfg_busdev_reg <= cfg_busdev;
         tx_desc_addr <= rx_hold_addr(6 DOWNTO 0);
         tx_desc_tag <= rx_hold_tag;
         tx_desc_req_id <= rx_hold_reqid;
         tx_desc_lbe <= xhdl13;
         tx_desc_length <= rx_hold_length(9 DOWNTO 0);
         CASE cstate_tx IS
            WHEN TX_IDLE =>
               tx_dv_xhdl3 <= '0';
               tx_ready_xhdl4 <= xhdl14;
               IF ((tx_arb_granted = '1') AND (fifo_empty = '0')) THEN
                  cstate_tx <= TX_SEND_DV_WAIT_ACK;
                  tx_req_xhdl5 <= '1';
                  tx_dfr_xhdl2 <= '1';
                  tx_busy <= '1';
                  fifo_prefetch <= '1';
               ELSE
                  cstate_tx <= cstate_tx;
                  tx_busy <= '0';
               END IF;
            WHEN TX_SEND_DV_WAIT_ACK =>
               fifo_prefetch <= '0';
               tx_ready_xhdl4 <= '0';
               tx_dv_xhdl3 <= '1';
               IF ((mem_num_to_read = "0000000001") OR ((fifo_rd_count = mem_num_to_read_minus_one) AND (tx_dv_xhdl3 = '1') AND (tx_ws = '0'))) THEN
                  tx_dfr_xhdl2 <= '0';
               ELSE
                  tx_dfr_xhdl2 <= tx_dfr_xhdl2;
               END IF;
               IF (tx_ack = '1') THEN
                  tx_req_xhdl5 <= '0';
                  IF ((tx_ws = '0') AND (mem_num_to_read = "0000000001")) THEN
                     cstate_tx <= TX_IDLE;
                  ELSE
                     cstate_tx <= TX_DV_PAYLD;
                  END IF;
               ELSE
                  cstate_tx <= cstate_tx;
                  tx_req_xhdl5 <= tx_req_xhdl5;
               END IF;
            WHEN TX_DV_PAYLD =>
               IF (tx_ws = '0') THEN
                  IF (fifo_rd_count = mem_num_to_read_minus_one) THEN
                     tx_dfr_xhdl2 <= '0';
                  ELSE
                     tx_dfr_xhdl2 <= tx_dfr_xhdl2;
                  END IF;
                  IF (tx_dfr_xhdl2 = '0') THEN
                     cstate_tx <= TX_IDLE;
                     tx_dv_xhdl3 <= '0';
                  END IF;
               ELSE
                  cstate_tx <= cstate_tx;
                  tx_dv_xhdl3 <= tx_dv_xhdl3;
               END IF;
            WHEN OTHERS =>
                  cstate_tx <= cstate_tx;
         END CASE;
      END IF;
   END PROCESS;
   tx_desc(127) <= '0';
   tx_desc(126 DOWNTO 120) <= "1001010";
   tx_desc(119) <= '0';
   tx_desc(118 DOWNTO 116) <= "000";
   tx_desc(115 DOWNTO 112) <= "0000";
   tx_desc(111) <= '0';
   tx_desc(110) <= '0';
   tx_desc(109 DOWNTO 108) <= "00";
   tx_desc(107 DOWNTO 106) <= "00";
   tx_desc(105 DOWNTO 96) <= tx_desc_length;
   tx_desc(95 DOWNTO 83) <= cfg_busdev_reg;
   tx_desc(82 DOWNTO 80) <= "000";
   tx_desc(79 DOWNTO 76) <= "0000";
   tx_desc(75 DOWNTO 64) <= (tx_desc_length(9 DOWNTO 0) & "00");
   tx_desc(63 DOWNTO 48) <= tx_desc_req_id;
   tx_desc(47 DOWNTO 40) <= tx_desc_tag;
   tx_desc(39) <= '0';
   tx_desc(38 DOWNTO 32) <= tx_desc_addr;
   tx_desc(31 DOWNTO 0) <= "00000000000000000000000000000000";
   xhdl15 <= rx_desc(7 DOWNTO 0) WHEN (rx_desc(125) = '1') ELSE
                           rx_desc(39 DOWNTO 32);
   xhdl16 <= rx_desc(MEM_ADDR_WIDTH - 1 + 4 DOWNTO 4) WHEN (rx_desc(125) = '1') ELSE
                           rx_desc(MEM_ADDR_WIDTH - 1 + 36 DOWNTO 36);
   xhdl17 <= rx_desc(MEM_ADDR_WIDTH - 1 + 3 DOWNTO 3) WHEN (rx_desc(125) = '1') ELSE
                           rx_desc(MEM_ADDR_WIDTH - 1 + 35 DOWNTO 35);
                  
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         mem_wr_data <= TO_STDLOGICVECTOR (0, AVALON_WDATA);
         mem_wr_be   <= TO_STDLOGICVECTOR (0, AVALON_BE_WIDTH);
         mem_wr_ena <= '0';
         sel_epmem <= '0';
         mem_wr_addr_xhdl1 <= TO_STDLOGICVECTOR (0, MEM_ADDR_WIDTH);
         reg_wr_addr <= "00000000";
         reg_wr_data <= "00000000000000000000000000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         sel_epmem <= rx_sel_epmem;
         reg_wr_addr <= xhdl15;
         IF (rx_desc(125) = '1') THEN
            IF (AVALON_ST_128 = 1) THEN
               CASE rx_desc(3 DOWNTO 2) IS
                  WHEN "00" =>
                     reg_wr_data <= rx_data(31 DOWNTO 0);
                  WHEN "01" =>
                     reg_wr_data <= rx_data(63 DOWNTO 32);
                  WHEN "10" =>
                     reg_wr_data <= rx_data(AVALON_WDATA - 33 DOWNTO AVALON_WDATA - 64);
                  WHEN "11" =>
                     reg_wr_data <= rx_data(AVALON_WDATA - 1 DOWNTO AVALON_WDATA - 32);
                  WHEN OTHERS =>
                     reg_wr_data <= "00000000000000000000000000000000";
               END CASE;
            ELSE
               CASE rx_desc(2) IS
                  WHEN '0' =>
                     reg_wr_data <= rx_data(31 DOWNTO 0);
                  WHEN OTHERS =>
                     reg_wr_data <= rx_data(63 DOWNTO 32);
               END CASE;
            END IF;
         ELSE
            IF (AVALON_ST_128 = 1) THEN
               CASE rx_desc(35 DOWNTO 34) IS
                  WHEN "00" =>
                     reg_wr_data <= rx_data(31 DOWNTO 0);
                  WHEN "01" =>
                     reg_wr_data <= rx_data(63 DOWNTO 32);
                  WHEN "10" =>
                     reg_wr_data <= rx_data(AVALON_WDATA - 33 DOWNTO AVALON_WDATA - 64);
                  WHEN "11" =>
                     reg_wr_data <= rx_data(AVALON_WDATA - 1 DOWNTO AVALON_WDATA - 32);
                  WHEN OTHERS =>
                     reg_wr_data <= "00000000000000000000000000000000";
               END CASE;
            ELSE
               CASE rx_desc(34) IS
                  WHEN '0' =>
                     reg_wr_data <= rx_data(31 DOWNTO 0);
                  WHEN OTHERS =>
                     reg_wr_data <= rx_data(63 DOWNTO 32);
               END CASE;
            END IF;
         END IF;
         IF (rx_start_write = '1') THEN
            mem_wr_ena <= '1';
            IF (AVALON_ST_128 = 1) THEN
               mem_wr_addr_xhdl1 <= xhdl16;
            ELSE
               mem_wr_addr_xhdl1 <= xhdl17;
            END IF;
         ELSIF (rx_dv = '1') THEN
            mem_wr_ena <= '1';
            mem_wr_addr_xhdl1 <= mem_wr_addr_xhdl1 + "0000000001";
         ELSE
            mem_wr_ena <= '0';
            mem_wr_addr_xhdl1 <= mem_wr_addr_xhdl1;
         END IF;
         mem_wr_data <= rx_data;
         mem_wr_be <= rx_be;
      END IF;
   END PROCESS;
   xhdl18 <= mem_num_to_read - "0000000001" WHEN (mem_num_to_read(9 DOWNTO 1) > "000000000" ) ELSE
                "0000000000";
   xhdl19 <= ("00" & (num_dw_to_read(9 DOWNTO 2) + "00000001")) WHEN (num_dw_to_read(1 DOWNTO 0) > "00") ELSE
                ("00" & num_dw_to_read(9 DOWNTO 2));
   xhdl20 <= ("00" & num_dw_to_read(9 DOWNTO 2)) WHEN (num_dw_to_read(1 DOWNTO 0) > "00") ELSE
                ("00" & num_dw_to_read(9 DOWNTO 2) - "00000001");
   xhdl21 <= ('0' & (num_dw_to_read(9 DOWNTO 1) + "000000001")) WHEN (num_dw_to_read(0) = '1') ELSE
                ('0' & num_dw_to_read(9 DOWNTO 1));
   xhdl22 <= ('0' & (num_dw_to_read(9 DOWNTO 1))) WHEN (num_dw_to_read(0) = '1') ELSE
                ('0' & num_dw_to_read(9 DOWNTO 1) - "000000001");
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         mem_rd_ena <= '0';
         mem_rd_addr_xhdl0 <= TO_STDLOGICVECTOR (0, MEM_ADDR_WIDTH);
         mem_num_to_read <= "0000000000";
         mem_read_count <= "0000000000";
         mem_num_to_read_minus_one <= "0000000000";
         reg_rd_addr <= ("00000000" );
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         mem_num_to_read_minus_one <= xhdl18;
         reg_rd_addr <= rx_hold_addr(7 DOWNTO 0);
         IF (rx_start_read = '1') THEN
            IF (AVALON_ST_128 = 1) THEN
               mem_rd_addr_xhdl0 <= rx_hold_addr(MEM_ADDR_WIDTH - 1 + 4 DOWNTO 4);
               mem_num_to_read <= xhdl19;
               mem_read_count <= xhdl20;
            ELSE
               mem_rd_addr_xhdl0 <= rx_hold_addr(MEM_ADDR_WIDTH - 1 + 3 DOWNTO 3);
               mem_num_to_read <= xhdl21;
               mem_read_count <= xhdl22;
            END IF;
            mem_rd_ena <= '1';
         ELSIF ((mem_read_count /= "0000000000") AND (fifo_almost_full = '0')) THEN
            mem_rd_ena <= '1';
            mem_rd_addr_xhdl0 <= mem_rd_addr_xhdl0 + "0000000001";
            mem_read_count <= mem_read_count - "0000000001";
         ELSE
            mem_rd_ena <= '0';
            mem_rd_addr_xhdl0 <= mem_rd_addr_xhdl0;
            mem_read_count <= mem_read_count;
         END IF;
      END IF;
   END PROCESS;
   fifo_rd <= to_stdlogic(((fifo_prefetch = '1') OR ((tx_dv_xhdl3 = '1') AND (tx_ws = '0'))) AND (fifo_empty = '0'));
   
   xhdl23 <= (reg_rd_data & reg_rd_data & reg_rd_data & reg_rd_data) WHEN  (reg_rd_data_valid = '1')  ELSE 
              mem_rd_data WHEN (AVALON_ST_128 = 1) ELSE
              ("0000000000000000000000000000000000000000000000000000000000000000" & mem_rd_data);
              
 
   PROCESS (clk_in, rstn)
   BEGIN
      IF (rstn = '0') THEN
         fifo_wr <= '0';
         fifo_data_in <= TO_STDLOGICVECTOR ( 0, AVALON_WDATA);
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         fifo_wr <= mem_rd_data_valid OR reg_rd_data_valid;
         IF (AVALON_ST_128 = 1) THEN
            fifo_data_in <= xhdl23;
         ELSE
            fifo_data_in <= xhdl23(63 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;
   
   -- rate matching FIFO -
   -- interfaces high latency RAM reads to 
   -- single-cycle turnaround desc/data interface
   
   
   
   xhdl25 <= NOT(rstn);
   tx_data_fifo : scfifo
      GENERIC MAP (
         add_ram_output_register  => "ON",
         intended_device_family   => "Stratix II GX",
         lpm_numwords             => 16,
         lpm_showahead            => "OFF",
         lpm_type                 => "scfifo",
         lpm_width                => AVALON_WDATA,
         lpm_widthu               => 4,
         almost_full_value        => 10,
         overflow_checking        => "OFF",
         underflow_checking       => "OFF",
         use_eab                  => "ON"
      )
      PORT MAP (
         clock         => clk_in,
         aclr          => xhdl25,
         data          => fifo_data_in,
         wrreq         => fifo_wr,
         rdreq         => fifo_rd,
         q             => fifo_data_out,
         empty         => fifo_empty,
         almost_full   => fifo_almost_full,
         usedw         => open_usedw,
         sclr          => gnd_sclr,
         full          => open_full,
         almost_empty  => open_almost_empty
      );
   
END trans;




-- synopsys translate_off
-- synopsys translate_on            
