LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
--
-- synthesis verilog_version verilog_2001
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_icm_tx.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This is the complete example application for the PCI Express Reference
-- Design. This has all of the application logic for the example.
-------------------------------------------------------------------------------
-- Copyright (c) 2006 Altera Corporation. All rights reserved.  Altera products are
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
-- first cycle of transfer. always descriptor_hi cycle.
-- last cycle of transfer
-- muxed be/bar bus. valid when data phase
-- muxed be/bar bus. valid when descriptor phase 
-- muxed data/descriptor bus
ENTITY altpcierd_icm_tx IS
   GENERIC (
      TXCRED_WIDTH                   :  integer := 22);    
   PORT (
      clk                     : IN std_logic;   
      rstn                    : IN std_logic;   
      tx_req                  : OUT std_logic;   --  to core.  TX request
      tx_ack                  : IN std_logic;   --  from core.  TX request ack
      tx_desc                 : OUT std_logic_vector(127 DOWNTO 0);   --  to core.  TX pkt descriptor
      tx_data                 : OUT std_logic_vector(63 DOWNTO 0);   --  to core.  TX pkt payload data
      tx_ws                   : IN std_logic;   --  from core.  TX dataphase throttle
      tx_dv                   : OUT std_logic;   --  to core.  TX dv contol
      tx_dfr                  : OUT std_logic;   --  to core.  TX dfr contol
      tx_be                   : OUT std_logic_vector(7 DOWNTO 0);   --  to core.  TX byte enabel -- not used
      tx_err                  : OUT std_logic;   --  to core.  TX error status
      tx_cpl_pending          : OUT std_logic;   --  to core.  TX completion pending status
      tx_cred_int             : IN std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0);   --  from core.
      tx_npcredh              : IN std_logic_vector(7 DOWNTO 0);   --  from core.
      tx_npcredd              : IN std_logic_vector(11 DOWNTO 0);   --  from core.
      tx_npcredh_infinite     : IN std_logic;   --  from core.
      tx_npcredd_infinite     : IN std_logic;   --  from core.
      app_msi_ack             : IN std_logic;   --  from core.  MSI request ack
      app_msi_req             : OUT std_logic;   --  to core.  MSI request.
      app_msi_num             : OUT std_logic_vector(4 DOWNTO 0);   --  to core.  MSI msi num bits.
      app_msi_tc              : OUT std_logic_vector(2 DOWNTO 0);   --  to core.  MSI TC bits.
      stream_ready            : OUT std_logic;   --  throttles data on TX streaming interface  
      stream_valid            : IN std_logic;   --  indicates stream_data_in is valid
      stream_data_in          : IN std_logic_vector(107 DOWNTO 0);   --  data from TX streaming interface   
      stream_msi_ready        : OUT std_logic;   --  throttles data on MSI streaming interface   
      stream_msi_valid        : IN std_logic;   --  indicates msi_data_in is valid
      stream_msi_data_in      : IN std_logic_vector(7 DOWNTO 0);   --  data from MSI streaming interface  
      tx_mask                 : OUT std_logic;   --  to app.  masks nonposted requests
      tx_cred                 : OUT std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0));   --  to app.
END ENTITY altpcierd_icm_tx;
ARCHITECTURE translated OF altpcierd_icm_tx IS
   COMPONENT altpcierd_icm_fifo_lkahd
      GENERIC (
           RAMTYPE               :  string  := "RAM_BLOCK_TYPE=M512";    
           USEEAB                :  string  := "ON");
      PORT (
         aclr                    : IN  std_logic;
         clock                   : IN  std_logic;
         data                    : IN  std_logic_vector(107 DOWNTO 0);
         rdreq                   : IN  std_logic;
         wrreq                   : IN  std_logic;
         almost_empty            : OUT std_logic;
         almost_full             : OUT std_logic;
         empty                   : OUT std_logic;
         full                    : OUT std_logic;
         q                       : OUT std_logic_vector(107 DOWNTO 0);
         usedw                   : OUT std_logic_vector(3 DOWNTO 0));
   END COMPONENT;
   COMPONENT altpcierd_icm_msibridge
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         data_valid              : IN  std_logic;
         data_in                 : IN  std_logic_vector(107 DOWNTO 0);
         data_ack                : OUT std_logic;
         msi_ack                 : IN  std_logic;
         msi_req                 : OUT std_logic;
         msi_num                 : OUT std_logic_vector(4 DOWNTO 0);
         msi_tc                  : OUT std_logic_vector(2 DOWNTO 0));
   END COMPONENT;
   COMPONENT altpcierd_icm_txbridge_withbypass
      GENERIC (
          TXCRED_WIDTH                   :  integer := 22);    
      PORT (
         clk                     : IN  std_logic;
         rstn                    : IN  std_logic;
         tx_req                  : OUT std_logic;
         tx_ack                  : IN  std_logic;
         tx_desc                 : OUT std_logic_vector(127 DOWNTO 0);
         tx_data                 : OUT std_logic_vector(63 DOWNTO 0);
         tx_ws                   : IN  std_logic;
         tx_dv                   : OUT std_logic;
         tx_dfr                  : OUT std_logic;
         tx_be                   : OUT std_logic_vector(7 DOWNTO 0);
         tx_err                  : OUT std_logic;
         tx_cpl_pending          : OUT std_logic;
         tx_cred                 : IN  std_logic_vector(65 DOWNTO 0);
         tx_npcredh              : IN  std_logic_vector(7 DOWNTO 0);
         tx_npcredd              : IN  std_logic_vector(11 DOWNTO 0);
         tx_npcredh_infinite     : IN  std_logic;
         tx_npcredd_infinite     : IN  std_logic;
         data_ack                : OUT std_logic;
         data_valid              : IN  std_logic;
         data_in                 : IN  std_logic_vector(107 DOWNTO 0);
         tx_bridge_idle          : OUT std_logic;
		 msi_busy                : IN  std_logic;
		 tx_fifo_rd              : IN std_logic;
         tx_mask                 : OUT std_logic);
   END COMPONENT;
   SIGNAL stream_data_in_del       :  std_logic_vector(107 DOWNTO 0);   --  input boundary reg
   SIGNAL stream_valid_del         :  std_logic;   --  input boundary reg
   SIGNAL stream_msi_valid_del     :  std_logic;   --  input boundary reg
   -- Fifo 
   SIGNAL fifo_empty               :  std_logic;   --  indicates fifo is full
   SIGNAL tx_fifo_almostfull       :  std_logic;   --  indicates fifo is almost full.  
   SIGNAL msi_fifo_almostfull      :  std_logic;   --  indicates fifo is almost full. 
   SIGNAL fifo_wr                  :  std_logic;   --  fifo write control
   SIGNAL fifo_rd                  :  std_logic;   --  fifo read control
   SIGNAL fifo_wrdata              :  std_logic_vector(107 DOWNTO 0);   --  fifo write data
   SIGNAL fifo_rddata              :  std_logic_vector(107 DOWNTO 0);   --  fifo read data
   SIGNAL msi_data_ack             :  std_logic;   --  Fifo throttle control from MSI bridge
   SIGNAL tx_data_ack              :  std_logic;   --  Fifo throttle control from TX bridge  
   SIGNAL tx_bridge_idle           :  std_logic;   --  indicates that there is no TX port packet in progress. for TX/MSI throttle arbitration. 
   SIGNAL stream_npreq_flag        :  std_logic;   --  flag indicating that the current pkt is a non-posted req
   SIGNAL stream_npwrreq_flag      :  std_logic;   --  flag indicating that the current pkt is a non-posted write req
   SIGNAL stream_npreq_flag_r      :  std_logic;   
   SIGNAL stream_npwrreq_flag_r    :  std_logic;   
   SIGNAL stream_npreq_sop_flag    :  std_logic;   
   SIGNAL stream_type_is_np        :  std_logic;   
   SIGNAL stream_type_is_npwr      :  std_logic;   
   SIGNAL tx_fifo_rddata           :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL msi_fifo_rddata          :  std_logic_vector(107 DOWNTO 0);   
   SIGNAL fifo_data_valid          :  std_logic;   
   SIGNAL throttle                 :  std_logic;   
   SIGNAL stream_dataindel_84_to_0 :  std_logic_vector(84 DOWNTO 0);   
   SIGNAL unused_vec               :  std_logic_vector(65 DOWNTO 0);   
   -- Generate NP decoding flags
   -- IO, ConfigType0, ConfigType1
   SIGNAL temp_xhdl16              :  std_logic;   --  MemRead, MemReadLocked
   SIGNAL temp_xhdl17              :  std_logic;   
   SIGNAL temp_xhdl18              :  std_logic;   
   SIGNAL temp_xhdl19              :  std_logic;   
   -- IO, ConfigType0, ConfigType1
   SIGNAL temp_xhdl20              :  std_logic;   
   SIGNAL xhdl_21                  :  std_logic;   
   SIGNAL port_xhdl22              :  std_logic;   
   SIGNAL tx_req_xhdl1             :  std_logic;   
   SIGNAL tx_desc_xhdl2            :  std_logic_vector(127 DOWNTO 0);   
   SIGNAL tx_data_xhdl3            :  std_logic_vector(63 DOWNTO 0);   
   SIGNAL tx_dv_xhdl4              :  std_logic;   
   SIGNAL tx_dfr_xhdl5             :  std_logic;   
   SIGNAL tx_be_xhdl6              :  std_logic_vector(7 DOWNTO 0);   
   SIGNAL tx_cpl_pending_xhdl7     :  std_logic;   
   SIGNAL tx_err_xhdl8             :  std_logic;   
   SIGNAL tx_cred_xhdl9            :  std_logic_vector(TXCRED_WIDTH - 1 DOWNTO 0);   
   SIGNAL app_msi_req_xhdl10       :  std_logic;   
   SIGNAL app_msi_num_xhdl11       :  std_logic_vector(4 DOWNTO 0);   
   SIGNAL app_msi_tc_xhdl12        :  std_logic_vector(2 DOWNTO 0);   
   SIGNAL stream_ready_xhdl13      :  std_logic;   
   SIGNAL tx_mask_xhdl14           :  std_logic;   
   SIGNAL stream_msi_ready_xhdl15  :  std_logic;   
   
   SIGNAL msi_busy             :  std_logic;  
   SIGNAL msi_data_valid       :  std_logic;  
   SIGNAL fifo_empty_or_rd_del :  std_logic;  
   SIGNAL fifo_rd_del          :  std_logic;  
   SIGNAL fifo_wrdata_masked   :  std_logic_vector(107 DOWNTO 0);  


BEGIN
   tx_req <= tx_req_xhdl1;
   tx_desc <= tx_desc_xhdl2;
   tx_data <= tx_data_xhdl3;
   tx_dv <= tx_dv_xhdl4;
   tx_dfr <= tx_dfr_xhdl5;
   tx_be <= tx_be_xhdl6;
   tx_cpl_pending <= tx_cpl_pending_xhdl7;
   tx_err <= tx_err_xhdl8;
   tx_cred <= tx_cred_xhdl9;
   app_msi_req <= app_msi_req_xhdl10;
   app_msi_num <= app_msi_num_xhdl11;
   app_msi_tc <= app_msi_tc_xhdl12;
   stream_ready <= stream_ready_xhdl13;
   tx_mask <= tx_mask_xhdl14;
   stream_msi_ready <= stream_msi_ready_xhdl15;
   unused_vec <= "000000000000000000000000000000000000000000000000000000000000000000" ;
   tx_cred_xhdl9 <= tx_cred_int ;
   -------------------------------------------------------------
   -- Streaming Interface input pipe stage
   -- NOTE:  This is an incremental compile register boundary.  
   --        No combinational logic is allowed on the input
   --        to these registers.
   -------------------------------------------------------------- 
   
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         stream_data_in_del <= "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";    
         stream_valid_del <= '0';    
         stream_msi_valid_del <= '0';    
         stream_npreq_flag_r <= '0';    
         stream_npwrreq_flag_r <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         stream_data_in_del(107 DOWNTO 85) <= "00000000000000000000000";    
         stream_data_in_del(75 DOWNTO 0) <= stream_data_in(75 DOWNTO 0);    
         stream_data_in_del(84 DOWNTO 80) <= stream_msi_data_in(4 DOWNTO 0);    
         stream_data_in_del(79 DOWNTO 77) <= stream_msi_data_in(7 DOWNTO 5);    
         stream_data_in_del(76) <= stream_msi_valid;    --  indicate when there is a valid msi data
         stream_valid_del <= stream_valid;    
         stream_msi_valid_del <= stream_msi_valid;    --  write whenever there is data on the tx chan or on the msi chan
         stream_npreq_flag_r <= stream_npreq_flag;    
         stream_npwrreq_flag_r <= stream_npwrreq_flag;    
      END IF;
   END PROCESS;
   temp_xhdl16 <= '1' WHEN ((stream_data_in_del(60 DOWNTO 59) = "00") AND (((stream_data_in_del(58 DOWNTO 56) = "010") OR (stream_data_in_del(58 DOWNTO 56) = "100") OR (stream_data_in_del(58 DOWNTO 56) = "101")) OR ((stream_data_in_del(58 DOWNTO 57) = "00") AND (stream_data_in_del(62) = '0')))) ELSE '0';
   stream_type_is_np <= temp_xhdl16 ;
   temp_xhdl17 <= stream_type_is_np WHEN (stream_data_in_del(73) AND stream_valid_del) = '1' ELSE stream_npreq_flag_r;
   stream_npreq_flag <= temp_xhdl17 ;
   temp_xhdl18 <= '1' WHEN (((stream_data_in_del(60 DOWNTO 59) = "00") AND (stream_data_in_del(62) = '1')) AND ((stream_data_in_del(58 DOWNTO 56) = "010") OR (stream_data_in_del(58 DOWNTO 56) = "100") OR (stream_data_in_del(58 DOWNTO 56) = "101"))) ELSE '0';
   stream_type_is_npwr <= temp_xhdl18 ;
   temp_xhdl19 <= stream_type_is_npwr WHEN (stream_data_in_del(73) AND stream_valid_del) = '1' ELSE stream_npwrreq_flag_r;
   stream_npwrreq_flag <= temp_xhdl19 ;
   temp_xhdl20 <= '1' WHEN (((stream_data_in_del(73) = '1') AND (stream_valid_del = '1')) AND ((stream_data_in_del(60 DOWNTO 59) = "00") AND (((stream_data_in_del(58 DOWNTO 56) = "010") OR (stream_data_in_del(58 DOWNTO 56) = "100") OR (stream_data_in_del(58 DOWNTO 56) = "101")) OR ((stream_data_in_del(58 DOWNTO 57) = "00") AND (stream_data_in_del(62) = '0'))))) ELSE '0';
   stream_npreq_sop_flag <= temp_xhdl20 ;
   ---------------------------------------------------
   -- Streaming Interface output pipe stage
   ---------------------------------------------------
   
   PROCESS (clk, rstn)
   BEGIN
      IF (NOT rstn = '1') THEN
         stream_ready_xhdl13 <= '0';    
         stream_msi_ready_xhdl15 <= '0';    
      ELSIF (clk'EVENT AND clk = '1') THEN
         stream_ready_xhdl13 <= NOT tx_fifo_almostfull;    
         stream_msi_ready_xhdl15 <= NOT msi_fifo_almostfull;    
      END IF;
   END PROCESS;
   ----------------------------------------------------
   -- Avalon Sink Fifo
   -- Buffers the data from the Streaming Interface
   -- Data from TX and MSI Streaming interfaces are
   -- held in the same FIFO in order to maintain 
   -- pkt ordering between these ports.
   ----------------------------------------------------
   stream_dataindel_84_to_0 <= stream_data_in_del(84 DOWNTO 0) ;
   fifo_wrdata <= "00000000000000000000" & stream_npreq_flag & stream_npwrreq_flag & stream_npreq_sop_flag & stream_dataindel_84_to_0 ;
   
   fifo_wrdata_masked(75 DOWNTO 0)   <= fifo_wrdata(75 DOWNTO 0)  WHEN (stream_valid_del = '1')     ELSE (OTHERS =>'0'); 
   fifo_wrdata_masked(84 DOWNTO 76)  <= fifo_wrdata(84 DOWNTO 76) WHEN (stream_msi_valid_del = '1') ELSE (OTHERS =>'0'); 
   fifo_wrdata_masked(87 DOWNTO 85)  <= fifo_wrdata(87 DOWNTO 85) WHEN (stream_valid_del = '1')     ELSE (OTHERS =>'0'); 
   fifo_wrdata_masked(107 DOWNTO 88) <= (OTHERS =>'0'); 
   
   xhdl_21 <= stream_valid_del OR stream_msi_valid_del;
   port_xhdl22 <= NOT rstn;
   tx_fifo_131x4 : altpcierd_icm_fifo_lkahd 
      GENERIC MAP (
         RAMTYPE => "RAM_BLOCK_TYPE=AUTO")
      PORT MAP (
         clock => clk,
         aclr => port_xhdl22,
         data => fifo_wrdata_masked,
         wrreq => xhdl_21,
         rdreq => fifo_rd,
         q => tx_fifo_rddata,
         full => open,
         almost_full => tx_fifo_almostfull,
         almost_empty => open,
         empty => fifo_empty);   
   
   -- 
   --  defparam tx_fifo_131x4.RAMTYPE = "RAM_BLOCK_TYPE=AUTO";
   --    altpcierd_icm_fifo_lkahd msi_fifo_131x4( 
   --                            .clock        (clk),
   --                            .aclr         (~rstn),
   --                            .data         (stream_data_in_del),
   -- 						   .wrreq        (stream_valid_del | stream_msi_valid_del),
   -- 						   .rdreq        (fifo_rd),
   -- 						   .q            (msi_fifo_rddata),
   -- 						   .full         ( ),
   -- 						   .almost_full  (msi_fifo_almostfull),
   -- 						   .almost_empty ( ), 
   -- 						   .empty        ( ));
   -- 
   msi_fifo_almostfull <= tx_fifo_almostfull ;
   msi_fifo_rddata <= tx_fifo_rddata ;
   ---------------------------------------------------
   -- Core Interface
   -- Data from streaming interface goes to 
   -- Core's TX Data Port and Core's MSI interface
   -- Both interfaces throttle the FIFO data.
   ---------------------------------------------------
   fifo_data_valid <= NOT fifo_empty ;
   -- FIFO read controls.
   -- tx channel throttling is allowed to override msi channel throttle. 
   -- since an entire msi transaction fits in one clock cycle,
   -- tx channel will not inadvertantly interrupt an msi in progress.
   -- however, since tx channel pkts require multiple fifo entries, 
   -- msi is only allowed to throttle the fifo if no tx pkt is in progress.  
   -- assign fifo_rd = tx_data_ack & (msi_data_ack | ~tx_bridge_idle);   
   throttle <= NOT tx_data_ack OR (NOT msi_data_ack AND tx_bridge_idle) ;
   fifo_rd <= NOT throttle AND NOT fifo_empty ;
   
   msi_busy <= NOT(msi_data_ack);
   

	  
   PROCESS (clk, rstn)
      BEGIN
         IF ((NOT(rstn)) = '1') THEN
            fifo_empty_or_rd_del <= '1';
            fifo_rd_del          <= '0';
         ELSIF (clk'EVENT AND clk = '1') THEN
            fifo_empty_or_rd_del <= fifo_empty OR fifo_rd;
            fifo_rd_del          <= fifo_rd;
         END IF;
   END PROCESS;
      
   msi_data_valid <= NOT(fifo_empty) AND fifo_empty_or_rd_del;
   
   
   altpcierd_icm_txbridge_withbypass_xhdl43 : altpcierd_icm_txbridge_withbypass 
      GENERIC MAP (
         TXCRED_WIDTH => TXCRED_WIDTH)
      PORT MAP (
         clk => clk,
         rstn => rstn,
         tx_req => tx_req_xhdl1,
         tx_ack => tx_ack,
         tx_desc => tx_desc_xhdl2,
         tx_data => tx_data_xhdl3,
         tx_ws => tx_ws,
         tx_dv => tx_dv_xhdl4,
         tx_dfr => tx_dfr_xhdl5,
         tx_be => tx_be_xhdl6,
         tx_err => tx_err_xhdl8,
         tx_cpl_pending => tx_cpl_pending_xhdl7,
         tx_cred => unused_vec,
         tx_npcredh => tx_npcredh,
         tx_npcredd => tx_npcredd,
         tx_npcredh_infinite => tx_npcredh_infinite,
         tx_npcredd_infinite => tx_npcredd_infinite,
         data_ack => tx_data_ack,
         data_valid => fifo_data_valid,
         data_in => tx_fifo_rddata,
         tx_bridge_idle => tx_bridge_idle,
         tx_mask => tx_mask_xhdl14,
		 msi_busy => msi_busy,
		 tx_fifo_rd => fifo_rd);   
   
   
   -- Bridge to the Core MSI Interface  
   -- NOTE:  The msibridge may not support multiple MSI requests if they
   --        all coincide with a single TLP request
   altpcierd_icm_msibridge_xhdl46 : altpcierd_icm_msibridge 
      PORT MAP (
         clk => clk,
         rstn => rstn,
         data_valid => msi_data_valid,
         data_in => msi_fifo_rddata,
         data_ack => msi_data_ack,
         msi_ack => app_msi_ack,
         msi_req => app_msi_req_xhdl10,
         msi_num => app_msi_num_xhdl11,
         msi_tc => app_msi_tc_xhdl12);   
   
END ARCHITECTURE translated;
