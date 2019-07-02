LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
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
-- File          : altpcierd_cdma_ecrc_check_64.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module performs PCIE Ecrc checking on the 64 bit Avalon-ST RX data stream
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
ENTITY altpcierd_cdma_ecrc_check_64 IS
   GENERIC (
      
      RAM_DATA_WIDTH         : INTEGER := 140;
      RAM_ADDR_WIDTH         : INTEGER := 8;
      PIPELINE_DEPTH         : INTEGER := 4;
      
      -- Bits in rxdata
      SOP_BIT                : INTEGER := 139;
      EOP_BIT                : INTEGER := 138;
      EMPTY_BIT              : INTEGER := 137
   );
   PORT (
      clk_in                 : IN STD_LOGIC;
      srst                   : IN STD_LOGIC;
      rxdata                 : IN STD_LOGIC_VECTOR(139 DOWNTO 0);
      rxdata_be              : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_stream_valid0       : IN STD_LOGIC;
      rx_stream_ready0_ecrc  : OUT STD_LOGIC;
      rxdata_ecrc            : OUT STD_LOGIC_VECTOR(139 DOWNTO 0);
      rxdata_be_ecrc         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_stream_valid0_ecrc  : OUT STD_LOGIC;
      rx_stream_ready0       : IN STD_LOGIC;
      rx_ecrc_check_valid    : OUT STD_LOGIC;
      ecrc_bad_cnt           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END ENTITY altpcierd_cdma_ecrc_check_64;
ARCHITECTURE altpcie OF altpcierd_cdma_ecrc_check_64 IS

    COMPONENT altpcierd_rx_ecrc_64
    PORT (
        clk : IN STD_LOGIC;
        data    : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
        datavalid   : IN STD_LOGIC;
        empty   : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        endofpacket : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;
        startofpacket   : IN STD_LOGIC;
        crcbad  : OUT STD_LOGIC;
        crcvalid    : OUT STD_LOGIC
    );

    END COMPONENT;
                                                
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
                                                
   TYPE type_xhdl2 IS ARRAY (PIPELINE_DEPTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(139 DOWNTO 0);
   TYPE type_xhdl3 IS ARRAY (PIPELINE_DEPTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
   
   

   SIGNAL rx_sop                               : STD_LOGIC;
   SIGNAL rx_sop_crc_in                        : STD_LOGIC;
   SIGNAL rx_sop_last                          : STD_LOGIC;
   SIGNAL rx_eop_last                          : STD_LOGIC;
   
   SIGNAL rx_eop                               : STD_LOGIC;
   SIGNAL rx_eop_reg                           : STD_LOGIC;
   SIGNAL rx_eop_crc_in                        : STD_LOGIC;
   
   SIGNAL rx_empty                             : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL crc_32                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL crcbad                               : STD_LOGIC;
   SIGNAL crcvalid                             : STD_LOGIC;
   
   -- Set TLP length 
   SIGNAL ctrlrx_cnt_len_dw                    : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_cnt_len_dw_reg                : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
   -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_payload                       : STD_LOGIC;
   SIGNAL ctrlrx_payload_reg                   : STD_LOGIC;
   
   -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_3dw                           : STD_LOGIC;
   SIGNAL ctrlrx_3dw_reg                       : STD_LOGIC;
   
   -- Set when TLP are qword aligned
   SIGNAL ctrlrx_qword_aligned                 : STD_LOGIC;
   SIGNAL ctrlrx_qword_aligned_reg             : STD_LOGIC;
   
   -- Set when the TD digest bit is set in the descriptor
   SIGNAL ctrlrx_digest                        : STD_LOGIC;
   SIGNAL ctrlrx_digest_reg                    : STD_LOGIC;
   SIGNAL ctrlrx_digest_pipe                   : STD_LOGIC_VECTOR(PIPELINE_DEPTH - 1 DOWNTO 0);
   
   SIGNAL rxdata_pipeline                      : type_xhdl2;
   SIGNAL rxdata_be_pipeline                   : type_xhdl3;
   SIGNAL rx_stream_valid_pipeline             : STD_LOGIC_VECTOR(PIPELINE_DEPTH - 1 DOWNTO 0);
   
   SIGNAL ctrlrx_3dw_aligned                   : STD_LOGIC;
   SIGNAL ctrlrx_3dw_aligned_reg               : STD_LOGIC;
   
   SIGNAL ctrlrx_4dw_non_aligned               : STD_LOGIC;
   SIGNAL ctrlrx_4dw_aligned                   : STD_LOGIC;
   SIGNAL ctrlrx_4dw_nopayload                 : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nopayload                 : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nonaligned                : STD_LOGIC;
   SIGNAL ctrlrx_4dw_non_aligned_reg           : STD_LOGIC;
   SIGNAL ctrlrx_4dw_aligned_reg               : STD_LOGIC;
   SIGNAL ctrlrx_4dw_nopayload_reg             : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nopayload_reg             : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nonaligned_reg            : STD_LOGIC;
   
   SIGNAL i                                    : INTEGER;
   
   SIGNAL rxdata_crc_reg                       : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL rx_valid_crc_in                      : STD_LOGIC;
   
   SIGNAL rxdata_byte_swap                     : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL rxdata_crc_in                        : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL rx_sop_crc_in_last                   : STD_LOGIC;
   SIGNAL rx_eop_crc_in_last                   : STD_LOGIC;
   SIGNAL rx_valid_crc_pending                 : STD_LOGIC;
   
   -- xhdl
   SIGNAL zeros_32                             : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL ctrlrx_single_cycle                  : STD_LOGIC;
   
   SIGNAL rx_payld_remain_dw                   : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL rx_payld_len                         : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL has_payld                            : STD_LOGIC;
   
   SIGNAL debug_ctrlrx_4dw_aligned             : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_non_aligned         : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_aligned             : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_nonaligned          : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_aligned_nopayld     : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_non_aligned_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_aligned_nopayld     : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_nonaligned_nopayld  : STD_LOGIC;
   
   SIGNAL zeros12                              : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL zeros8                               : STD_LOGIC_VECTOR(7 DOWNTO 0);
   
   SIGNAL rxdata_be_15_12                      : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rxdata_be_15_8                       : STD_LOGIC_VECTOR(15 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl4 : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL xhdl5 : STD_LOGIC;
   SIGNAL xhdl6 : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL xhdl7 : STD_LOGIC;
   SIGNAL xhdl8 : STD_LOGIC;
   SIGNAL xhdl9 : STD_LOGIC;
   SIGNAL xhdl10 : STD_LOGIC;
   SIGNAL xhdl11 : STD_LOGIC;
   SIGNAL xhdl12 : STD_LOGIC;
   SIGNAL xhdl13 : STD_LOGIC;
   SIGNAL xhdl14 : STD_LOGIC;
   SIGNAL xhdl15 : STD_LOGIC;
   SIGNAL xhdl16 : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL rx_ecrc_check_valid_xhdl1            : STD_LOGIC;
   SIGNAL ecrc_bad_cnt_xhdl0                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   rx_ecrc_check_valid <= rx_ecrc_check_valid_xhdl1;
   ecrc_bad_cnt <= ecrc_bad_cnt_xhdl0;
   zeros_32 <= "00000000000000000000000000000000";
   zeros12 <= "000000000000";
   zeros8 <= "00000000";
   rxdata_be_15_12 <= (rxdata_be(15 DOWNTO 12) & zeros12);
   rxdata_be_15_8 <= (rxdata_be(15 DOWNTO 8) & zeros8);
   
   --//////////////////////////////////////////////////////////////////////////
   --
   --  Drop ECRC field from the data stream/rx_be. 
   --  Regenerate rx_st_eop.
   --  Set TD bit to 0.
   -- 
   
   -- default
   --///////////////////////
   -- TLP has Digest 
   -- 
   -- 1st phase of descriptor
   xhdl4 <= "10000000000" WHEN (rxdata(105 DOWNTO 96) = "0000000000") ELSE      -- account for 1024DW
                     ('0' & rxdata(105 DOWNTO 96));
   -- 2nd phase of descriptor
   -- Load the # of payld DWs remaining in next cycles
   -- if there is payload
   xhdl5 <= '1' WHEN (rx_payld_remain_dw > "00000000000") ELSE
                     '0';
   
   -- Decrement payld count as payld is received
   xhdl6 <= "00000000000" WHEN (rx_payld_remain_dw < "00000000010") ELSE
                     rx_payld_remain_dw - "00000000010";
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rxdata_ecrc <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            rxdata_be_ecrc <= "0000000000000000";
            rx_payld_remain_dw <= "00000000000";
            rx_stream_valid0_ecrc <= '0';
            rx_payld_len <= "00000000000";
            has_payld <= '0';
         ELSE
            rxdata_ecrc(138) <= '0';
            rx_stream_valid0_ecrc <= '0';
            IF (ctrlrx_digest = '1') THEN
               IF ((rx_sop = '1') AND (rx_stream_valid0 = '1')) THEN
                  rxdata_ecrc(111) <= '0';
                  rxdata_ecrc(135 DOWNTO 112) <= rxdata(135 DOWNTO 112);
                  rxdata_ecrc(110 DOWNTO 0) <= rxdata(110 DOWNTO 0);
                  rxdata_ecrc(SOP_BIT) <= '1';
                  rxdata_ecrc(EOP_BIT) <= '0';
                  rxdata_ecrc(EMPTY_BIT) <= '0';
                  rxdata_be_ecrc <= rxdata_be;
                  has_payld <= rxdata(126);
                  IF (rxdata(126) = '1') THEN
                     rx_payld_len <= xhdl4;
                  ELSE
                     rx_payld_len <= "00000000000";
                  END IF;
                  rx_stream_valid0_ecrc <= '1';
               ELSIF ((rx_sop_last = '1') AND (rx_stream_valid0 = '1')) THEN
                  rxdata_ecrc(127 DOWNTO 0) <= rxdata(127 DOWNTO 0);
                  rxdata_ecrc(SOP_BIT) <= '0';
                  rxdata_ecrc(EOP_BIT) <= to_stdlogic((has_payld = '0') OR ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0') AND (rx_payld_len = "00000000001")));
                  rxdata_ecrc(EMPTY_BIT) <= '0';
                  rxdata_be_ecrc <= rxdata_be;
                  rx_stream_valid0_ecrc <= '1';
                  IF (has_payld = '1') THEN
                     IF ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0')) THEN
                        rx_payld_remain_dw <= rx_payld_len - "00000000001";
                     ELSIF ((ctrlrx_3dw = '0') AND (ctrlrx_qword_aligned = '0')) THEN
                        rx_payld_remain_dw <= rx_payld_len + "00000000001";
                     ELSE
                        rx_payld_remain_dw <= rx_payld_len;
                     END IF;
                  ELSE
                     rx_payld_remain_dw <= "00000000000";
                  END IF;
               ELSIF (rx_stream_valid0 = '1') THEN
                  rxdata_ecrc(SOP_BIT) <= '0';
                  rxdata_ecrc(EMPTY_BIT) <= '0';
                  rxdata_ecrc(127 DOWNTO 0) <= rxdata(127 DOWNTO 0);
                  CASE rx_payld_remain_dw IS
                     WHEN "00000000001" =>
                        rxdata_ecrc(EOP_BIT) <= '1';
                        rxdata_be_ecrc <= rxdata_be_15_12;
                     WHEN "00000000010" =>
                        rxdata_ecrc(EOP_BIT) <= '1';
                        rxdata_be_ecrc <= rxdata_be_15_8;
                     WHEN OTHERS =>
                        rxdata_ecrc(EOP_BIT) <= '0';
                        rxdata_be_ecrc <= rxdata_be(15 DOWNTO 0);
                  END CASE;
                  rx_stream_valid0_ecrc <= xhdl5;
                  rx_payld_remain_dw <= xhdl6;
               END IF;
            ELSE
               --/////////////
               -- No Digest 
               --
               rxdata_ecrc <= rxdata;
               rxdata_be_ecrc <= rxdata_be;
               rx_stream_valid0_ecrc <= rx_stream_valid0;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --//////////////////////////////////////////////////////////////////////////
   --
   -- RX Avalon-ST input delayed of PIPELINE_DEPTH to RX Avalon-ST output
   --
   rx_stream_ready0_ecrc <= rx_stream_ready0;
   
   --//////////////////////////////////////////////////////////////////////////
   --
   -- CRC MegaCore instanciation
   --  
   
   
   xhdl7 <= NOT(srst);
   -- .datavalid     ( ((rx_sop_crc_in | rx_valid_crc_pending) & rx_stream_valid0) | (rx_valid_crc_pending&rx_eop_crc_in)),
   xhdl8 <= ctrlrx_digest_reg AND (((rx_sop_crc_in OR rx_valid_crc_pending) AND rx_stream_valid0) OR (rx_valid_crc_pending AND rx_eop_crc_in));
   rx_ecrc_64 : altpcierd_rx_ecrc_64
      PORT MAP (
         reset_n        => xhdl7,
         clk            => clk_in,
         data           => rxdata_crc_in(127 DOWNTO 64),
         datavalid      => xhdl8,
         startofpacket  => rx_sop_crc_in,
         endofpacket    => rx_eop_crc_in,
         empty          => rx_empty,
         crcbad         => crcbad,
         crcvalid       => crcvalid
      );
   
   -- Inputs to the MegaCore
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (ctrlrx_digest = '0') THEN
            rx_valid_crc_in <= '0';
         ELSIF ((rx_sop_crc_in = '0') AND (rx_sop_crc_in_last = '0') AND (rx_eop = '1') AND (ctrlrx_cnt_len_dw_reg < "0000000010")) THEN        -- rxdata is only 1 DW of payld -- CRC appended
            rx_valid_crc_in <= '0';
         ELSE
            
            rx_valid_crc_in <= rx_stream_valid0;
         END IF;
         IF ((rx_sop_crc_in AND rx_stream_valid0) = '1') THEN
            rx_valid_crc_pending <= '1';
         ELSIF (rx_eop_crc_in = '1') THEN
            
            rx_valid_crc_pending <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   
   xhdl9 <= ctrlrx_4dw_aligned WHEN (rx_sop = '1') ELSE
                           debug_ctrlrx_4dw_aligned;
   xhdl10 <= ctrlrx_4dw_non_aligned WHEN (rx_sop = '1') ELSE
                           debug_ctrlrx_4dw_non_aligned;
   xhdl11 <= ctrlrx_3dw_aligned WHEN (rx_sop = '1') ELSE
                           debug_ctrlrx_3dw_aligned;
   xhdl12 <= ctrlrx_3dw_nonaligned WHEN (rx_sop = '1') ELSE
                           debug_ctrlrx_3dw_nonaligned;
   
   xhdl13 <= ctrlrx_4dw_aligned WHEN ((rx_sop = '1') AND (rxdata(126) = '0')) ELSE
                           debug_ctrlrx_4dw_aligned_nopayld;
   xhdl14 <= ctrlrx_4dw_non_aligned WHEN ((rx_sop = '1') AND (rxdata(126) = '0')) ELSE
                           debug_ctrlrx_4dw_non_aligned_nopayld;
   xhdl15 <= ctrlrx_3dw_aligned WHEN ((rx_sop = '1') AND (rxdata(126) = '0')) ELSE
                           debug_ctrlrx_3dw_aligned_nopayld;
   xhdl16 <= ctrlrx_3dw_nonaligned WHEN ((rx_sop = '1') AND (rxdata(126) = '0')) ELSE
                           debug_ctrlrx_3dw_nonaligned_nopayld;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            debug_ctrlrx_4dw_aligned <= '0';
            debug_ctrlrx_4dw_non_aligned <= '0';
            debug_ctrlrx_3dw_aligned <= '0';
            debug_ctrlrx_3dw_nonaligned <= '0';
            debug_ctrlrx_4dw_aligned_nopayld <= '0';
            debug_ctrlrx_4dw_non_aligned_nopayld <= '0';
            debug_ctrlrx_3dw_aligned_nopayld <= '0';
            debug_ctrlrx_3dw_nonaligned_nopayld <= '0';
         ELSE
            IF (rx_stream_valid0 = '1') THEN
               debug_ctrlrx_4dw_aligned <= xhdl9;
               debug_ctrlrx_4dw_non_aligned <= xhdl10;
               debug_ctrlrx_3dw_aligned <= xhdl11;
               debug_ctrlrx_3dw_nonaligned <= xhdl12;
               debug_ctrlrx_4dw_aligned_nopayld <= xhdl13;
               debug_ctrlrx_4dw_non_aligned_nopayld <= xhdl14;
               debug_ctrlrx_3dw_aligned_nopayld <= xhdl15;
               debug_ctrlrx_3dw_nonaligned_nopayld <= xhdl16;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_sop_crc_in <= '0';
            rx_sop_crc_in_last <= '0';
            rx_eop_crc_in_last <= '0';
            ctrlrx_3dw_aligned_reg <= '0';
            rx_eop_reg <= '0';
         ELSIF (rx_stream_valid0 = '1') THEN
            rx_sop_crc_in <= rx_sop;
            rx_sop_crc_in_last <= rx_sop_last;
            rx_eop_crc_in_last <= rx_eop_crc_in;
            ctrlrx_3dw_aligned_reg <= ctrlrx_3dw_aligned;
            IF ((rx_sop_crc_in = '0') AND (rx_sop_crc_in_last = '0') AND (rx_eop = '1') AND (ctrlrx_cnt_len_dw_reg < "0000000010")) THEN        -- rxdata is only 1 DW of payld -- CRC appended
               rx_eop_reg <= '0';
            ELSE
               rx_eop_reg <= rx_eop;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   rx_eop_crc_in <= '1' WHEN (((rx_sop_crc_in = '0') AND (rx_sop_crc_in_last = '0') AND (rx_eop = '1') AND (rx_stream_valid0 = '1') AND (ctrlrx_cnt_len_dw_reg < "0000000010")) OR ((rx_sop_crc_in_last = '1') AND (rx_eop = '1') AND (ctrlrx_3dw_nopayload_reg = '1'))) ELSE
                    rx_eop_reg;
   
   -- rxdata_byte_swap is :
   --     - Set variant bit to 1 The EP field is variant 
   --     - Byte swap the data and not the header
   --     - The header is already byte order ready for the CRC (lower byte first) such as :
   --                     | H0 byte 0,1,2,3
   --       rxdata[127:0] | H1 byte 4,5,6,7
   --                     | H2 byte 8,9,10,11
   --                     | H3 byte 12,13,14,15
   --     - The Data requires byte swaping 
   --       rxdata
   --
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_sop_last <= rx_sop;
            rx_eop_last <= rx_eop;
         ELSIF (rx_stream_valid0 = '1') THEN
            rx_sop_last <= rx_sop;
            rx_eop_last <= rx_eop;
         END IF;
         
         --////////////////////////////////////////////////////////
         -- Reformat the incoming data so that 
         --  - the left-most byte corresponds to the first
         --    byte on the PCIE line.  
         --  - 'gaps' between the Avalon-ST desc/data boundaries are removed
         --     so that all bytes going into the CRC checker are contiguous 
         --    (e.g. for 3DW aligned, 4DW non-aligned packets).
         --  - EP and Type[0] bits are set to '1' for ECRC calc
         --
         -- Headers are already formatted.  Data needs to be byte flipped
         -- within each DW.
         
         IF (rx_stream_valid0 = '1') THEN
            IF (ctrlrx_3dw_aligned = '1') THEN      -- 3DW aligned
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSIF (rx_sop_last = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 0) <= rxdata(127 DOWNTO 0);     -- 2nd descriptor phase
               ELSE
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24) & zeros_32);
               END IF;
            ELSIF (ctrlrx_3dw_nonaligned = '1') THEN        -- 3DW non-aligned 
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSIF (rx_sop_last = '1') THEN       -- 2nd descriptor phase  
                  -- descriptor bits
                  rxdata_crc_reg(127 DOWNTO 96) <= rxdata(127 DOWNTO 96);       -- data bits
                  rxdata_crc_reg(95 DOWNTO 64) <= (rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88));
               ELSE
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120) & rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24));
               END IF;
            ELSIF (ctrlrx_4dw_non_aligned = '1') THEN       -- 4DW non-aligned
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSIF (rx_sop_last = '1') THEN       -- 2nd descriptor phase  
                  rxdata_crc_reg(127 DOWNTO 64) <= rxdata(127 DOWNTO 64);
               ELSE
                  -- data phase
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24) & zeros_32);
               END IF;
            ELSE
               -- 4DW Aligned 
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSIF (rx_sop_last = '1') THEN       -- 2nd descriptor phase  
                  rxdata_crc_reg(127 DOWNTO 64) <= rxdata(127 DOWNTO 64);
               ELSE
                  -- data phase
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120) & rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24));
               END IF;
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- 3DW aligned, 4DW non-aligned
   rxdata_crc_in(127 DOWNTO 64) <= rxdata_crc_reg(127 DOWNTO 64) WHEN ((ctrlrx_3dw_nonaligned_reg = '1') OR (ctrlrx_4dw_aligned_reg = '1') OR (rx_sop_crc_in = '1') OR ((rx_sop_crc_in_last = '1') AND (ctrlrx_4dw_non_aligned_reg = '1'))) ELSE        -- SOP, or all data for 3DW non-aligned, 4DW aligned,
                                   (rxdata_crc_reg(127 DOWNTO 96) & rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120));
   
   --////////////////////////////////////////////////////////////////////////
   --
   -- BAD ECRC Counter output (ecrc_bad_cnt
   -- 
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_ecrc_check_valid_xhdl1 <= '1';
            ecrc_bad_cnt_xhdl0 <= "0000000000000000";
         ELSIF ((crcvalid = '1') AND (crcbad = '1')) THEN
            IF (ecrc_bad_cnt_xhdl0 < "1111111111111111") THEN
               ecrc_bad_cnt_xhdl0 <= ecrc_bad_cnt_xhdl0 + "0000000000000001";
            END IF;
            IF (rx_ecrc_check_valid_xhdl1 = '1') THEN
               rx_ecrc_check_valid_xhdl1 <= '0';
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   --//////////////////////////////////////////////////////////////////////////
   --
   -- Misc. Avalon-ST control signals
   --
   rx_sop <= '1' WHEN (rxdata(139) = '1') ELSE
             '0' WHEN (rx_stream_valid0 = '1') ELSE
             rx_sop_last;
   rx_eop <= '1' WHEN (rxdata(138) = '1') ELSE
             '0' WHEN (rx_stream_valid0 = '1') ELSE
             rx_eop_last;
   ctrlrx_single_cycle <= '1' WHEN ((rx_sop = '1') AND (rx_eop = '1')) ELSE  '0';
   
   -- ctrlrx_payload is set when the TLP has payload 
   ctrlrx_payload <= ctrlrx_payload_reg WHEN (rx_sop = '0') ELSE '1'  WHEN (rxdata(126) = '1') ELSE '0' ;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_payload_reg <= '0';
         ELSE
            ctrlrx_payload_reg <= ctrlrx_payload;
         END IF;
      END IF;
   END PROCESS;
   
   -- ctrlrx_3dw is set when the TLP has 3 DWORD header 
   ctrlrx_3dw <= ctrlrx_3dw_reg WHEN (rx_sop = '0') ELSE '1' WHEN (rxdata(125) = '0') ELSE '0' ;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_3dw_reg <= '0';
         ELSE
            ctrlrx_3dw_reg <= ctrlrx_3dw;
         END IF;
      END IF;
   END PROCESS;
   
   -- ctrlrx_qword_aligned is set when the data are address aligned 
   ctrlrx_qword_aligned <= ctrlrx_qword_aligned_reg WHEN (rx_sop_last = '0') ELSE '1' WHEN (((ctrlrx_3dw = '1') AND (rxdata(98) = '0')) OR ((ctrlrx_3dw = '0') AND (rxdata(66) = '0'))) ELSE
                           '0' ;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_qword_aligned_reg <= '0';
         ELSE
            ctrlrx_qword_aligned_reg <= ctrlrx_qword_aligned;
         END IF;
      END IF;
   END PROCESS;
   
   ctrlrx_digest <= ctrlrx_digest_reg WHEN (rx_sop = '0') ELSE '1' WHEN (rxdata(111) = '1') ELSE '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_digest_reg <= '0';
         ELSE
            ctrlrx_digest_reg <= ctrlrx_digest;
         END IF;
      END IF;
   END PROCESS;
   
   --(ctrlrx_payload==1'b1) && 
   ctrlrx_3dw_aligned <= '1' WHEN ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '1')) ELSE
                         '0';
   
   --(ctrlrx_payload==1'b1) && 
   ctrlrx_3dw_nonaligned <= '1' WHEN ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0')) ELSE
                            '0';
   
   --(ctrlrx_payload==1'b1) && 
   ctrlrx_4dw_non_aligned <= '1' WHEN ((ctrlrx_3dw = '0') AND (ctrlrx_qword_aligned = '0')) ELSE
                             '0';
   
   --(ctrlrx_payload==1'b1) && 
   ctrlrx_4dw_aligned <= '1' WHEN ((ctrlrx_3dw = '0') AND (ctrlrx_qword_aligned = '1')) ELSE
                         '0';
   
   ctrlrx_4dw_nopayload <= to_stdlogic((ctrlrx_payload = '0') AND (ctrlrx_3dw = '0'));
   
   ctrlrx_3dw_nopayload <= to_stdlogic((ctrlrx_payload = '0') AND (ctrlrx_3dw = '1'));
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_4dw_non_aligned_reg <= '0';
            ctrlrx_4dw_aligned_reg <= '0';
            ctrlrx_4dw_nopayload_reg <= '0';
            ctrlrx_3dw_nopayload_reg <= '0';
            ctrlrx_3dw_nonaligned_reg <= '0';
         ELSIF (rx_stream_valid0 = '1') THEN
            ctrlrx_4dw_non_aligned_reg <= ctrlrx_4dw_non_aligned;
            ctrlrx_4dw_aligned_reg <= ctrlrx_4dw_aligned;
            ctrlrx_4dw_nopayload_reg <= ctrlrx_4dw_nopayload;
            ctrlrx_3dw_nopayload_reg <= ctrlrx_3dw_nopayload;
            ctrlrx_3dw_nonaligned_reg <= ctrlrx_3dw_nonaligned;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         -- ctrlrx_cnt_len_dw counts the number remaining
         -- number of DWORD in rxdata_crc_reg
         IF (rx_stream_valid0 = '1') THEN
            IF (ctrlrx_payload = '1') THEN
               ctrlrx_cnt_len_dw_reg <= ctrlrx_cnt_len_dw;
            ELSE
               ctrlrx_cnt_len_dw_reg <= "0000000000";       -- no payload
            END IF;
         END IF;
         
         IF (srst = '1') THEN
            ctrlrx_cnt_len_dw <= "0000000000";
         ELSIF ((rx_sop = '1') AND (rx_stream_valid0 = '1')) THEN
            IF (ctrlrx_3dw = '0') THEN
               ctrlrx_cnt_len_dw <= rxdata(105 DOWNTO 96);
            ELSE
               ctrlrx_cnt_len_dw <= rxdata(105 DOWNTO 96) - "0000000001";
            END IF;
         ELSIF ((rx_sop_last = '0') AND (rx_stream_valid0 = '1')) THEN      -- decrement in data phase
            IF (ctrlrx_cnt_len_dw > "0000000001") THEN
               ctrlrx_cnt_len_dw <= ctrlrx_cnt_len_dw - "0000000010";
            ELSIF (ctrlrx_cnt_len_dw > "0000000000") THEN
               ctrlrx_cnt_len_dw <= ctrlrx_cnt_len_dw - "0000000001";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- ECRC appended to 3DW header (3DW dataless)
   -- sending ECRC field only (4 bytes)
   -- sending 1 DW payld + ECRC (8 bytes)
   rx_empty <= "000" WHEN (rx_eop_crc_in = '0') ELSE        -- sending 2 DW (8 bytes) paylod + ECRC (4 bytes)
               "000" WHEN (ctrlrx_3dw_nopayload_reg = '1') ELSE
               "100" WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "00") ELSE
               "000" WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "01") ELSE
               "000" WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "10") ELSE
               "000";
   
   -- for internal monitoring 
   crc_32 <= "00000000000000000000000000000000" WHEN (rx_eop_crc_in = '0') ELSE
             rxdata_crc_in(127 DOWNTO 96) WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "00") ELSE
             rxdata_crc_in(95 DOWNTO 64) WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "01") ELSE
             rxdata_crc_in(63 DOWNTO 32) WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "10") ELSE
             rxdata_crc_in(31 DOWNTO 0);
   
END ARCHITECTURE altpcie;
