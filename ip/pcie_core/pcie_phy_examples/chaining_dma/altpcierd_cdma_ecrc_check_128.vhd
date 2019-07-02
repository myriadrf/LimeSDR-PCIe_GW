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
-- File          : altpcierd_cdma_ecrc_check_128.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module performs the PCIE ECRC check on the 128-bit Avalon-ST RX data stream.
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
ENTITY altpcierd_cdma_ecrc_check_128 IS
   GENERIC (
      
      RAM_DATA_WIDTH         : INTEGER := 140;
      RAM_ADDR_WIDTH         : INTEGER := 8;
      PIPELINE_DEPTH         : INTEGER := 4;
      
      -- Bits in rxdata
      SOP_BIT                : INTEGER := 139;
      EOP_BIT                : INTEGER := 136;
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
END ENTITY altpcierd_cdma_ecrc_check_128;
ARCHITECTURE altpcie OF altpcierd_cdma_ecrc_check_128 IS


                                                
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
   
    COMPONENT altpcierd_rx_ecrc_128
    PORT (
        clk : IN STD_LOGIC;
        data    : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
        datavalid   : IN STD_LOGIC;
        empty   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        endofpacket : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;
        startofpacket   : IN STD_LOGIC;
        crcbad  : OUT STD_LOGIC;
        crcvalid    : OUT STD_LOGIC
    );

    END COMPONENT;    

   SIGNAL rx_sop                           : STD_LOGIC;
   SIGNAL rx_sop_crc_in                    : STD_LOGIC;
   
   SIGNAL rx_eop                           : STD_LOGIC;
   SIGNAL rx_eop_reg                       : STD_LOGIC;
   SIGNAL rx_eop_crc_in                    : STD_LOGIC;
   
   SIGNAL rx_empty                         : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL crc_32                           : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL crcbad                           : STD_LOGIC;
   SIGNAL crcvalid                         : STD_LOGIC;
   
   -- Set TLP length 
   SIGNAL ctrlrx_cnt_len_dw                : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL ctrlrx_cnt_len_dw_reg            : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
   -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_payload                   : STD_LOGIC;
   SIGNAL ctrlrx_payload_reg               : STD_LOGIC;
   
   -- Set when TLP is 3 DW header 
   SIGNAL ctrlrx_3dw                       : STD_LOGIC;
   SIGNAL ctrlrx_3dw_reg                   : STD_LOGIC;
   
   -- Set when TLP are qword aligned
   SIGNAL ctrlrx_qword_aligned             : STD_LOGIC;
   SIGNAL ctrlrx_qword_aligned_reg         : STD_LOGIC;
   
   -- Set when the TD digest bit is set in the descriptor
   SIGNAL ctrlrx_digest                    : STD_LOGIC;
   SIGNAL ctrlrx_digest_reg                : STD_LOGIC;
   SIGNAL ctrlrx_digest_pipe               : STD_LOGIC_VECTOR(PIPELINE_DEPTH - 1 DOWNTO 0);
   
   SIGNAL rxdata_pipeline                  : type_xhdl2;
   SIGNAL rxdata_be_pipeline               : type_xhdl3;
   SIGNAL rx_stream_valid_pipeline         : STD_LOGIC_VECTOR(PIPELINE_DEPTH - 1 DOWNTO 0);
   
   SIGNAL ctrlrx_3dw_aligned               : STD_LOGIC;
   SIGNAL ctrlrx_3dw_aligned_reg           : STD_LOGIC;
   
   SIGNAL ctrlrx_3dw_nonaligned            : STD_LOGIC;
   SIGNAL ctrlrx_3dw_nonaligned_reg        : STD_LOGIC;
   
   SIGNAL ctrlrx_4dw_non_aligned           : STD_LOGIC;
   SIGNAL ctrlrx_4dw_non_aligned_reg       : STD_LOGIC;
   
   SIGNAL ctrlrx_4dw_aligned               : STD_LOGIC;
   SIGNAL ctrlrx_4dw_aligned_reg           : STD_LOGIC;
   
   SIGNAL ctrlrx_single_cycle_reg          : STD_LOGIC;
   
   SIGNAL i                                : INTEGER;
   
   SIGNAL rxdata_crc_reg                   : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL rx_valid_crc_in                  : STD_LOGIC;
   
   SIGNAL rxdata_byte_swap                 : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL rxdata_crc_in                    : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL ctrlrx_single_cycle              : STD_LOGIC;
   
   SIGNAL rx_payld_remain_dw               : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL rx_payld_len                     : STD_LOGIC_VECTOR(10 DOWNTO 0);
   
   SIGNAL rx_valid_crc_pending             : STD_LOGIC;
   SIGNAL single_crc_cyc                   : STD_LOGIC;
   SIGNAL send_rx_eop_crc_early            : STD_LOGIC;
   
   SIGNAL debug_ctrlrx_4dw_offset0         : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_offset1         : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_offset2         : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_offset3         : STD_LOGIC;
   
   SIGNAL debug_ctrlrx_3dw_offset0         : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_offset1         : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_offset2         : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_offset3         : STD_LOGIC;
   
   SIGNAL debug_ctrlrx_4dw_offset0_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_offset1_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_offset2_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_4dw_offset3_nopayld : STD_LOGIC;
   
   SIGNAL debug_ctrlrx_3dw_offset0_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_offset1_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_offset2_nopayld : STD_LOGIC;
   SIGNAL debug_ctrlrx_3dw_offset3_nopayld : STD_LOGIC;
   
   SIGNAL zeros12                          : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL zeros8                           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL zeros4                           : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   SIGNAL rxdata_be_15_12                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rxdata_be_15_8                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL rxdata_be_15_4                   : STD_LOGIC_VECTOR(15 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl4 : STD_LOGIC;
   SIGNAL xhdl5 : STD_LOGIC_VECTOR(10 DOWNTO 0);
   SIGNAL xhdl6 : STD_LOGIC;
   SIGNAL xhdl7 : STD_LOGIC;
   SIGNAL xhdl8 : STD_LOGIC;
   SIGNAL xhdl9 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL rx_ecrc_check_valid_xhdl1        : STD_LOGIC;
   SIGNAL ecrc_bad_cnt_xhdl0               : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   rx_ecrc_check_valid <= rx_ecrc_check_valid_xhdl1;
   ecrc_bad_cnt <= ecrc_bad_cnt_xhdl0;
   zeros12 <= "000000000000";
   zeros8 <= "00000000";
   zeros4 <= "0000";
   rxdata_be_15_12 <= (rxdata_be(15 DOWNTO 12) & zeros12);
   rxdata_be_15_8 <= (rxdata_be(15 DOWNTO 8) & zeros8);
   rxdata_be_15_4 <= (rxdata_be(15 DOWNTO 4) & zeros4);
   
   --//////////////////////////////////////////////////////////////////////////
   --
   --  Drop ECRC field from the data stream/rx_be. 
   --  Regenerate rx_st_eop.
   --  Set TD bit to 0.
   -- 
   
   rx_payld_len <= "10000000000" WHEN (rxdata(105 DOWNTO 96) = "0000000000") ELSE       -- account for 1024DW
                   ('0' & rxdata(105 DOWNTO 96));
   
   -- default
   --///////////////////////
   -- TLP has Digest 
   -- 
   -- Load the # of payld DWs remaining in next cycles
   -- if there is payload
   -- 3DW aligned, or 4DW nonaligned
   -- Add 1 DW to account for empty field
   --((ctrlrx_3dw==1'b1) & (ctrlrx_qword_aligned==1'b1)) |
   xhdl4 <= '1' WHEN (rx_payld_remain_dw > "00000000000") ELSE
                   '0';
   
   -- Decrement payld count as payld is received
   xhdl5 <= "00000000000" WHEN (rx_payld_remain_dw < "00000000100") ELSE
                   rx_payld_remain_dw - "00000000100";
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rxdata_ecrc <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            rxdata_be_ecrc <= "0000000000000000";
            rx_payld_remain_dw <= "00000000000";
            rx_stream_valid0_ecrc <= '0';
         ELSE
            rxdata_ecrc(138) <= '0';
            rx_stream_valid0_ecrc <= '0';
            IF (ctrlrx_digest = '1') THEN
               IF (rx_sop = '1') THEN
                  rxdata_ecrc(111) <= '0';
                  rxdata_ecrc(135 DOWNTO 112) <= rxdata(135 DOWNTO 112);
                  rxdata_ecrc(110 DOWNTO 0) <= rxdata(110 DOWNTO 0);
                  rxdata_ecrc(SOP_BIT) <= '1';
                  rxdata_ecrc(EOP_BIT) <= to_stdlogic((rxdata(126) = '0') OR ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0') AND (rxdata(105 DOWNTO 96) = "0000000001")));
                  rxdata_ecrc(EMPTY_BIT) <= '0';
                  rxdata_be_ecrc <= rxdata_be;
                  rx_stream_valid0_ecrc <= '1';
                  IF (rxdata(126) = '1') THEN
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
                  rxdata_ecrc(135 DOWNTO 0) <= rxdata(135 DOWNTO 0);
                  CASE rx_payld_remain_dw IS
                     WHEN "00000000001" =>
                        rxdata_ecrc(EOP_BIT) <= '1';
                        rxdata_ecrc(EMPTY_BIT) <= '1';
                        rxdata_be_ecrc <= rxdata_be_15_12;
                     WHEN "00000000010" =>
                        rxdata_ecrc(EOP_BIT) <= '1';
                        rxdata_ecrc(EMPTY_BIT) <= '1';
                        rxdata_be_ecrc <= rxdata_be_15_8;
                     WHEN "00000000011" =>
                        rxdata_ecrc(EOP_BIT) <= '1';
                        rxdata_ecrc(EMPTY_BIT) <= '0';
                        rxdata_be_ecrc <= rxdata_be_15_4;
                     WHEN "00000000100" =>
                        rxdata_ecrc(EOP_BIT) <= '1';
                        rxdata_ecrc(EMPTY_BIT) <= '0';
                        rxdata_be_ecrc <= rxdata_be(15 DOWNTO 0);
                     WHEN OTHERS =>
                        rxdata_ecrc(EOP_BIT) <= '0';
                        rxdata_ecrc(EMPTY_BIT) <= '0';
                        rxdata_be_ecrc <= rxdata_be(15 DOWNTO 0);
                  END CASE;
                  rx_stream_valid0_ecrc <= xhdl4;
                  rx_payld_remain_dw <= xhdl5;
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
   
   
   xhdl6 <= NOT(srst);
   xhdl7 <= ctrlrx_digest_reg AND rx_valid_crc_in;      -- use registered version of ctrlrx_digest since crc_in is delayed 1 cycle from input
   rx_ecrc_128 : altpcierd_rx_ecrc_128
      PORT MAP (
         reset_n        => xhdl6,
         clk            => clk_in,
         data           => rxdata_crc_in(127 DOWNTO 0),
         datavalid      => xhdl7,
         startofpacket  => rx_sop_crc_in,
         endofpacket    => rx_eop_crc_in,
         empty          => rx_empty,
         crcbad         => crcbad,
         crcvalid       => crcvalid
      );
   
   rx_valid_crc_in <= (rx_sop_crc_in AND (ctrlrx_single_cycle OR rx_stream_valid0)) OR (rx_valid_crc_pending AND rx_stream_valid0) OR (rx_eop_crc_in AND NOT(send_rx_eop_crc_early));
   
   -- Inputs to the MegaCore
   
   
   -- no addr offset
   -- 1DW addr offset
   -- 2DW addr offset
   -- 3DW addr offset 
   
   -- no addr offset
   -- 1DW addr offset
   -- 2DW addr offset
   -- 3DW addr offset
   
   -- no addr offset
   -- 1DW addr offset
   -- 2DW addr offset
   -- 3DW addr offset 
   
   -- no addr offset
   -- 1DW addr offset
   -- 2DW addr offset
   -- 3DW addr offset
   
   -- Pack ECRC into single cycle
   -- multicycle
   -- eop is sent 1 cycle early when the payld is a multiple
   -- of 4DWs, and the TLP is 3DW Header aligned
   -- end crc data early 
   xhdl8 <= '0' WHEN ((ctrlrx_cnt_len_dw = "0000000000") AND (rx_stream_valid0 = '1')) ELSE
                      '1';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            rx_valid_crc_pending <= '0';
            rx_sop_crc_in <= '0';
            rx_eop_crc_in <= '0';
            rx_empty <= "0000";
            send_rx_eop_crc_early <= '0';
            ctrlrx_3dw_aligned_reg <= '0';
            ctrlrx_3dw_nonaligned_reg <= '0';
            ctrlrx_4dw_non_aligned_reg <= '0';
            ctrlrx_4dw_aligned_reg <= '0';
            debug_ctrlrx_4dw_offset0 <= '0';
            debug_ctrlrx_4dw_offset1 <= '0';
            debug_ctrlrx_4dw_offset2 <= '0';
            debug_ctrlrx_4dw_offset3 <= '0';
            debug_ctrlrx_3dw_offset0 <= '0';
            debug_ctrlrx_3dw_offset1 <= '0';
            debug_ctrlrx_3dw_offset2 <= '0';
            debug_ctrlrx_3dw_offset3 <= '0';
            debug_ctrlrx_4dw_offset0_nopayld <= '0';
            debug_ctrlrx_4dw_offset1_nopayld <= '0';
            debug_ctrlrx_4dw_offset2_nopayld <= '0';
            debug_ctrlrx_4dw_offset3_nopayld <= '0';
            debug_ctrlrx_3dw_offset0_nopayld <= '0';
            debug_ctrlrx_3dw_offset1_nopayld <= '0';
            debug_ctrlrx_3dw_offset2_nopayld <= '0';
            debug_ctrlrx_3dw_offset3_nopayld <= '0';
         ELSE
            IF ((rx_sop = '1') AND (rx_stream_valid0 = '1') AND (ctrlrx_digest = '1')) THEN
               rx_sop_crc_in <= '1';
            ELSIF ((rx_sop_crc_in = '1') AND (rx_valid_crc_in = '1')) THEN
               rx_sop_crc_in <= '0';
            END IF;
            ctrlrx_3dw_aligned_reg <= ctrlrx_3dw_aligned;
            ctrlrx_3dw_nonaligned_reg <= ctrlrx_3dw_nonaligned;
            ctrlrx_4dw_non_aligned_reg <= ctrlrx_4dw_non_aligned;
            ctrlrx_4dw_aligned_reg <= ctrlrx_4dw_aligned;
            IF ((rx_stream_valid0 = '1') AND (rx_sop = '1')) THEN
               debug_ctrlrx_4dw_offset0 <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '1') AND (rxdata(3 DOWNTO 0) = "0000"));
               debug_ctrlrx_4dw_offset1 <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '1') AND (rxdata(3 DOWNTO 0) = "0100"));
               debug_ctrlrx_4dw_offset2 <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '1') AND (rxdata(3 DOWNTO 0) = "1000"));
               debug_ctrlrx_4dw_offset3 <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '1') AND (rxdata(3 DOWNTO 0) = "1100"));
               debug_ctrlrx_3dw_offset0 <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '1') AND (rxdata(35 DOWNTO 32) = "0000"));
               debug_ctrlrx_3dw_offset1 <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '1') AND (rxdata(35 DOWNTO 32) = "0100"));
               debug_ctrlrx_3dw_offset2 <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '1') AND (rxdata(35 DOWNTO 32) = "1000"));
               debug_ctrlrx_3dw_offset3 <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '1') AND (rxdata(35 DOWNTO 32) = "1100"));
               debug_ctrlrx_4dw_offset0_nopayld <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '0') AND (rxdata(3 DOWNTO 0) = "0000"));
               debug_ctrlrx_4dw_offset1_nopayld <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '0') AND (rxdata(3 DOWNTO 0) = "0100"));
               debug_ctrlrx_4dw_offset2_nopayld <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '0') AND (rxdata(3 DOWNTO 0) = "1000"));
               debug_ctrlrx_4dw_offset3_nopayld <= to_stdlogic((ctrlrx_3dw = '0') AND (rxdata(126) = '0') AND (rxdata(3 DOWNTO 0) = "1100"));
               debug_ctrlrx_3dw_offset0_nopayld <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '0') AND (rxdata(35 DOWNTO 32) = "0000"));
               debug_ctrlrx_3dw_offset1_nopayld <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '0') AND (rxdata(35 DOWNTO 32) = "0100"));
               debug_ctrlrx_3dw_offset2_nopayld <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '0') AND (rxdata(35 DOWNTO 32) = "1000"));
               debug_ctrlrx_3dw_offset3_nopayld <= to_stdlogic((ctrlrx_3dw = '1') AND (rxdata(126) = '0') AND (rxdata(35 DOWNTO 32) = "1100"));
            END IF;
            IF ((rx_sop = '1') AND (rx_stream_valid0 = '1') AND (ctrlrx_digest = '1')) THEN
               IF ((ctrlrx_3dw = '1') AND (ctrlrx_payload = '0')) THEN
                  rx_eop_crc_in <= '1';
                  rx_empty <= "0000";
                  rx_valid_crc_pending <= '0';
               ELSE
                  rx_eop_crc_in <= '0';
                  rx_empty <= "0000";
                  rx_valid_crc_pending <= '1';
                  send_rx_eop_crc_early <= to_stdlogic((ctrlrx_3dw_aligned = '1') AND (ctrlrx_payload = '1') AND (rxdata(97 DOWNTO 96) = "00"));
               END IF;
            ELSIF (rx_valid_crc_pending = '1') THEN
               IF (send_rx_eop_crc_early = '1') THEN
                  rx_valid_crc_pending <= xhdl8;
                  IF ((ctrlrx_cnt_len_dw = "0000000100") AND (rx_stream_valid0 = '1')) THEN
                     rx_eop_crc_in <= '1';
                     rx_empty <= "0000";
                  END IF;
               ELSE
                  -- end on eop
                  -- rx_valid_crc_pending <= (rx_eop_crc_in==1'b1) ? 1'b0 : rx_valid_crc_pending;
                  IF ((rx_eop = '1') AND (rx_stream_valid0 = '1')) THEN
                     rx_eop_crc_in <= '1';
                     rx_valid_crc_pending <= '0';
                     CASE ctrlrx_cnt_len_dw IS
                        WHEN "0000000001" =>
                           rx_empty <= "1100";
                        WHEN "0000000010" =>
                           rx_empty <= "1000";
                        WHEN "0000000011" =>
                           rx_empty <= "0100";
                        WHEN OTHERS =>
                           rx_empty <= "0000";
                     END CASE;
                  END IF;
               END IF;
            ELSE
               rx_eop_crc_in <= '0';
               rx_empty <= "0000";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
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
         IF (rx_stream_valid0 = '1') THEN
            IF (ctrlrx_3dw_aligned = '1') THEN
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSE
                  --D1
                  -- D2
                  -- D0
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24) & rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120));      -- D3
               END IF;
            ELSIF (ctrlrx_4dw_non_aligned = '1') THEN
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSE
                  --D1
                  -- D2
                  -- D0         
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24) & rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120));      -- D3
               END IF;
            ELSIF (ctrlrx_4dw_aligned = '1') THEN
               IF (rx_sop = '1') THEN
                  rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
                  rxdata_crc_reg(120) <= '1';
                  rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
                  rxdata_crc_reg(110) <= '1';
                  rxdata_crc_reg(109 DOWNTO 0) <= rxdata(109 DOWNTO 0);
               ELSE
                  -- D0  
                  --D1
                  -- D2
                  rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120) & rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24));      -- D3
               END IF;
            -- 3DW nonaligned
            ELSIF (rx_sop = '1') THEN
               rxdata_crc_reg(127 DOWNTO 121) <= rxdata(127 DOWNTO 121);
               rxdata_crc_reg(120) <= '1';
               rxdata_crc_reg(119 DOWNTO 111) <= rxdata(119 DOWNTO 111);
               rxdata_crc_reg(110) <= '1';
               rxdata_crc_reg(109 DOWNTO 32) <= rxdata(109 DOWNTO 32);
               IF (ctrlrx_3dw = '1') THEN
                  -- 3 DWORD Header with payload byte swapping the first data D0 
                  rxdata_crc_reg(31 DOWNTO 24) <= rxdata(7 DOWNTO 0);
                  rxdata_crc_reg(23 DOWNTO 16) <= rxdata(15 DOWNTO 8);
                  rxdata_crc_reg(15 DOWNTO 8) <= rxdata(23 DOWNTO 16);
                  rxdata_crc_reg(7 DOWNTO 0) <= rxdata(31 DOWNTO 24);
               ELSE
                  -- 4 DWORD Header no need to swap bytes
                  rxdata_crc_reg(31 DOWNTO 0) <= rxdata(31 DOWNTO 0);
               END IF;
            ELSE
               rxdata_crc_reg(127 DOWNTO 0) <= (rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120) & rxdata(71 DOWNTO 64) & rxdata(79 DOWNTO 72) & rxdata(87 DOWNTO 80) & rxdata(95 DOWNTO 88) & rxdata(39 DOWNTO 32) & rxdata(47 DOWNTO 40) & rxdata(55 DOWNTO 48) & rxdata(63 DOWNTO 56) & rxdata(7 DOWNTO 0) & rxdata(15 DOWNTO 8) & rxdata(23 DOWNTO 16) & rxdata(31 DOWNTO 24));
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- previous 3DW
   -- previous 3DW
   -- current DW (byte flipped)
   rxdata_crc_in(127 DOWNTO 0) <= (rxdata_crc_reg(127 DOWNTO 32) & rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120)) WHEN (ctrlrx_3dw_aligned_reg = '1') ELSE       -- current DW (byte flipped)
                                  (rxdata_crc_reg(127 DOWNTO 32) & rxdata(103 DOWNTO 96) & rxdata(111 DOWNTO 104) & rxdata(119 DOWNTO 112) & rxdata(127 DOWNTO 120)) WHEN ((ctrlrx_4dw_non_aligned_reg = '1') AND (rx_sop_crc_in = '0')) ELSE
                                  rxdata_crc_reg(127 DOWNTO 0);
   
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
   rx_sop <= '1' WHEN ((rxdata(139) = '1') AND (rx_stream_valid0 = '1')) ELSE
             '0';
   rx_eop <= '1' WHEN ((rxdata(136) = '1') AND (rx_stream_valid0 = '1')) ELSE
             '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            ctrlrx_3dw_reg <= '0';
            ctrlrx_qword_aligned_reg <= '0';
            ctrlrx_digest_reg <= '0';
            ctrlrx_single_cycle_reg <= '0';
            ctrlrx_payload_reg <= '0';
         ELSE
            ctrlrx_3dw_reg <= ctrlrx_3dw;
            ctrlrx_qword_aligned_reg <= ctrlrx_qword_aligned;
            ctrlrx_digest_reg <= ctrlrx_digest;
            ctrlrx_single_cycle_reg <= ctrlrx_single_cycle;
            ctrlrx_payload_reg <= ctrlrx_payload;
         END IF;
      END IF;
   END PROCESS;
   
   ctrlrx_single_cycle <= ctrlrx_single_cycle_reg WHEN (rx_sop = '0') ELSE '1' WHEN (rx_eop = '1') ELSE '0' ;
   
   -- ctrlrx_payload is set when the TLP has payload  
   ctrlrx_payload <= ctrlrx_payload_reg WHEN (rx_sop = '0') ELSE '1' WHEN (rxdata(126) = '1') ELSE  '0' ;
   
   -- ctrlrx_3dw is set when the TLP has 3 DWORD header  
   ctrlrx_3dw <= ctrlrx_3dw_reg when (rx_sop = '0') ELSE '1' WHEN (rxdata(125) = '0') ELSE '0';
   
   -- ctrlrx_qword_aligned is set when the data are address aligned 
   
   ctrlrx_qword_aligned <= ctrlrx_qword_aligned_reg WHEN (rx_sop = '0') ELSE
                          '1' WHEN (((ctrlrx_3dw = '1') AND (rxdata(34 DOWNTO 32) = "000")) OR ((ctrlrx_3dw = '0') AND (rxdata(2 DOWNTO 0) = "000"))) ELSE
                           '0' ;
   
   ctrlrx_digest <= rxdata(111) WHEN (rx_sop = '1') ELSE
                    ctrlrx_digest_reg;
   
   ctrlrx_3dw_aligned <= '1' WHEN ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '1')) ELSE
                         '0';
   
   ctrlrx_3dw_nonaligned <= '1' WHEN ((ctrlrx_3dw = '1') AND (ctrlrx_qword_aligned = '0')) ELSE
                            '0';
   
   ctrlrx_4dw_non_aligned <= '1' WHEN ((ctrlrx_3dw = '0') AND (ctrlrx_qword_aligned = '0')) ELSE
                             '0';
   
   ctrlrx_4dw_aligned <= '1' WHEN ((ctrlrx_3dw = '0') AND (ctrlrx_qword_aligned = '1')) ELSE
                         '0';
   
   -- ctrlrx_cnt_len_dw counts the number remaining
   -- number of DWORD in rxdata_crc_reg
   xhdl9 <= ctrlrx_cnt_len_dw WHEN (rx_stream_valid0 = '1') ELSE
                         ctrlrx_cnt_len_dw_reg;
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         ctrlrx_cnt_len_dw_reg <= xhdl9;
         IF (srst = '1') THEN
            ctrlrx_cnt_len_dw <= "0000000000";
         ELSIF (rx_sop = '1') THEN
            -- default
            single_crc_cyc <= '0';      -- No payload
            IF (rxdata(126) = '0') THEN
               IF (ctrlrx_3dw = '1') THEN
                  ctrlrx_cnt_len_dw <= "0000000000";        -- 1DW ECRC, subtract 1 since ECRC is packed with descriptor.
                  single_crc_cyc <= '1';
               ELSE
                  ctrlrx_cnt_len_dw <= "0000000001";
               END IF;
            ELSIF (ctrlrx_3dw = '0') THEN
               ctrlrx_cnt_len_dw <= rxdata(105 DOWNTO 96) + "0000000001";       --  Add ECRC field.
            ELSE
               ctrlrx_cnt_len_dw <= rxdata(105 DOWNTO 96);      --  Add ECRC field.
            END IF;
         ELSIF (rx_stream_valid0 = '1') THEN
            IF (ctrlrx_cnt_len_dw > "0000000011") THEN
               ctrlrx_cnt_len_dw <= ctrlrx_cnt_len_dw - "0000000100";
            ELSIF (ctrlrx_cnt_len_dw > "0000000010") THEN
               ctrlrx_cnt_len_dw <= ctrlrx_cnt_len_dw - "0000000011";
            ELSIF (ctrlrx_cnt_len_dw > "0000000001") THEN
               ctrlrx_cnt_len_dw <= ctrlrx_cnt_len_dw - "0000000010";
            ELSIF (ctrlrx_cnt_len_dw > "0000000000") THEN
               ctrlrx_cnt_len_dw <= ctrlrx_cnt_len_dw - "0000000001";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   -- for internal monitoring 
   crc_32 <= "00000000000000000000000000000000" WHEN (rx_eop_crc_in = '0') ELSE
             rxdata_crc_in(127 DOWNTO 96) WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "00") ELSE
             rxdata_crc_in(95 DOWNTO 64) WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "01") ELSE
             rxdata_crc_in(63 DOWNTO 32) WHEN (ctrlrx_cnt_len_dw_reg(1 DOWNTO 0) = "10") ELSE
             rxdata_crc_in(31 DOWNTO 0);
   
END ARCHITECTURE altpcie;
