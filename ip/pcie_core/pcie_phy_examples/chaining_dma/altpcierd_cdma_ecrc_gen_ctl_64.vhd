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
--  * the chaining DMA design example. It could be used by the software 
--  * application (Root Port) to retrieve the DMA Performance counter values 
--  * and performs single DWORD read and write to the Endpoint memory by 
--  * bypassing the DMA engines.
--  */
-- synthesis translate_on
-- 
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
-- packet header bits  
-- 34 
-- 2
ENTITY altpcierd_cdma_ecrc_gen_ctl_64 IS
   PORT (
      
      clk              : IN STD_LOGIC;
      rstn             : IN STD_LOGIC;
      
      -- user data (avalon-st formatted) 
      user_rd_req      : OUT STD_LOGIC;     -- request for next user_data
      user_sop         : IN STD_LOGIC;      -- means this cycle contains the start of a packet
      user_eop         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);       -- means this cycle contains the end of a packet
      user_data        : IN STD_LOGIC_VECTOR(127 DOWNTO 0);     -- avalon streaming packet data
      user_valid       : IN STD_LOGIC;      -- means user_sop, user_eop, user_data are valid
      
      -- to CRC module (packed)
      crc_empty        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);      -- indicates which DWs in crc_data are valid (1'b0) -- indicates where end of pkt is
      crc_sop          : OUT STD_LOGIC;     -- means this cycle contains the start of a packet
      crc_eop          : OUT STD_LOGIC;     -- means this cycle contains the end of a packet
      crc_data         : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);        -- packet data formatted for the CRC module
      crc_valid        : OUT STD_LOGIC;     -- means crc_sop, crc_eop, crc_data, crc_empty are valid
      
      -- main datapath (avalon-st formatted)
      tx_sop           : OUT STD_LOGIC;     -- start of pkt flag for transmission 
      tx_eop           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);      -- end of pkt flag for transmission
      tx_data          : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);        -- avalon-ST packet data for transmission
      tx_valid         : OUT STD_LOGIC;     -- means tx_sop, tx_eop, tx_data are valid
      tx_crc_location  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);      -- indicates which DW to insert the CRC field
      tx_shift         : OUT STD_LOGIC;
      
      av_st_ready      : IN STD_LOGIC       -- avalon-st ready input - throttles datapath
   );
END ENTITY altpcierd_cdma_ecrc_gen_ctl_64;
ARCHITECTURE altpcie OF altpcierd_cdma_ecrc_gen_ctl_64 IS


                                                
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
                                                                       


   SIGNAL tx_insert_crc_cyc         : STD_LOGIC;
   SIGNAL send_to_crc_appended      : STD_LOGIC;        -- send data to CRC with 1DW from next cycle inserted into last DW of this cycle
   SIGNAL send_to_crc_as_is         : STD_LOGIC;        -- send data to CRC unmodified
   SIGNAL send_to_crc_shifted       : STD_LOGIC;        -- send data to CRC with the 3DW's of this cycle shifted up 1DW, and 1DW from
   SIGNAL tx_rem_length             : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
   SIGNAL state                     : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL user_data_masked_del      : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL user_data_masked          : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL user_data_length          : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL need_insert_crc_cyc       : STD_LOGIC;
   SIGNAL user_data_masked_swizzled : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL crc_rem_length            : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL deferred_valid            : STD_LOGIC;
   SIGNAL inhibit_read              : STD_LOGIC;
   
   SIGNAL debug_is_aligned          : STD_LOGIC;
   SIGNAL debug_is_3dw              : STD_LOGIC;
   SIGNAL user_last_was_sop         : STD_LOGIC;
   SIGNAL user_is_4dw               : STD_LOGIC;
   SIGNAL user_is_3dW_nonaligned    : STD_LOGIC;
   SIGNAL user_has_payld            : STD_LOGIC;
   SIGNAL tx_digest                 : STD_LOGIC;
   SIGNAL tx_digest_reg             : STD_LOGIC;
   SIGNAL insert_ecrc_in_hi         : STD_LOGIC;
   
   -- assign user_data_length = user_data[`LENGTH];
   
   -- state machine states
   CONSTANT WAIT_SOP                : INTEGER := 0;     -- wait for the start of a pkt
   CONSTANT WAIT_SOP2               : INTEGER := 1;
   CONSTANT SEND_PACKED_DATA        : INTEGER := 2;     -- header and data DWs are noncontiguous (3DW Hdr Aligned, or 4DW Hdr NonAligned).. need to shift data
   CONSTANT SEND_DATA               : INTEGER := 3;     -- header and data are noncontiguous -- send data thru as-is
   CONSTANT EXTRA_CRC_CYC           : INTEGER := 4;
   
                                                                       
   

   -- CONSTANT EXTRA_CRC_CYC_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(EXTRA_CRC_CYC,3);
   -- CONSTANT WAIT_SOP_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(WAIT_SOP,3);
   -- CONSTANT WAIT_SOP2_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(WAIT_SOP2,3);
   -- CONSTANT SEND_PACKED_DATA_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SEND_PACKED_DATA,3);
   -- CONSTANT SEND_DATA_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(SEND_DATA,3);   
   
   
   CONSTANT WAIT_SOP_3         : std_logic_vector(3-1 downto 0):= "000";
   CONSTANT WAIT_SOP2_3        : std_logic_vector(3-1 downto 0):= "001";
   CONSTANT SEND_PACKED_DATA_3 : std_logic_vector(3-1 downto 0):= "010";
   CONSTANT SEND_DATA_3        : std_logic_vector(3-1 downto 0):= "011";   
   CONSTANT EXTRA_CRC_CYC_3    : std_logic_vector(3-1 downto 0):= "100";
   
   -- X-HDL generated signals
   SIGNAL xhdl1 : STD_LOGIC;
   SIGNAL xhdl2 : STD_LOGIC;
   SIGNAL xhdl3 : STD_LOGIC;
   SIGNAL xhdl4 : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL xhdl5 : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL xhdl6 : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL xhdl7 : STD_LOGIC;
   SIGNAL xhdl8 : STD_LOGIC;
   SIGNAL xhdl9 : STD_LOGIC;
   SIGNAL xhdl10 : STD_LOGIC;
   SIGNAL xhdl11 : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL xhdl12 : STD_LOGIC;
   SIGNAL xhdl13 : STD_LOGIC;
   SIGNAL xhdl14 : STD_LOGIC;
   SIGNAL xhdl15 : STD_LOGIC;
   SIGNAL xhdl16 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL xhdl17 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL xhdl18 : STD_LOGIC;
   SIGNAL xhdl19 : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_eop_xhdl0              : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   tx_eop <= tx_eop_xhdl0;
   
   --////////////////////////////////////////////////////////////////////
   -- Main Datapath
   --
   
   -- Append digest to all packets except CFG0
   tx_digest <= to_stdlogic((user_data(122 DOWNTO 120) /= "100")) WHEN ((user_sop = '1') AND (tx_insert_crc_cyc = '0')) ELSE
                tx_digest_reg;
   
   xhdl1 <= '1' WHEN (user_sop = '1') ELSE
                '0';
   xhdl2 <= (xhdl1) WHEN (user_valid = '1') ELSE
                '0';
   xhdl3 <= '0' WHEN (tx_insert_crc_cyc = '1') ELSE
                (xhdl2);
   xhdl4 <= "01" WHEN (user_eop(1) = '1') ELSE
                "00";
   xhdl5 <= (xhdl4) WHEN (user_valid = '1') ELSE
                "00";
   xhdl6 <= "00" WHEN (tx_insert_crc_cyc = '1') ELSE
                (xhdl5);
   xhdl7 <= '1' WHEN (user_data(111) = '1') ELSE        -- set the digest bit
                '0';
   xhdl8 <= '1' WHEN (user_sop = '1') ELSE
                (xhdl7);
   xhdl9 <= '1' WHEN (user_sop = '1') ELSE
                '0';
   xhdl10 <= (xhdl9) WHEN (user_valid = '1') ELSE
                '0';
   xhdl11 <= user_eop WHEN (user_valid = '1') ELSE
                tx_eop_xhdl0;
   xhdl12 <= '1' WHEN (av_st_ready = '1') ELSE
                '0';
   xhdl13 <= '1' WHEN ((av_st_ready = '1') AND (user_valid = '1')) ELSE
                '0';
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         tx_sop <= '0';
         tx_eop_xhdl0 <= "00";
         tx_data <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
         tx_valid <= '0';
         tx_shift <= '0';
         tx_digest_reg <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         tx_digest_reg <= tx_digest;
         IF (tx_digest = '1') THEN
            tx_sop <= xhdl3;
            tx_eop_xhdl0 <= xhdl6;
            tx_data(127 DOWNTO 111 + 1) <= user_data(127 DOWNTO 111 + 1);
            tx_data(111) <= xhdl8;
            tx_data(111 - 1 DOWNTO 0) <= user_data(111 - 1 DOWNTO 0);
            tx_shift <= to_stdlogic((av_st_ready = '1'));
            tx_valid <= to_stdlogic((av_st_ready = '1') AND ((user_valid = '1') OR (tx_insert_crc_cyc = '1')));
         ELSE
            tx_sop <= xhdl10;
            tx_eop_xhdl0 <= xhdl11;
            tx_data <= user_data;
            tx_shift <= xhdl12;
            tx_valid <= xhdl13;
         END IF;
      END IF;
   END PROCESS;
   
   --////////////////////////////////////////////////////////////////////
   -- Input Data stream throttle control. 
   --    Throttle when:
   --         - Avalon-ST throttles
   --         - Need to insert a cycle to account for CRC insertion
   
   user_rd_req <= to_stdlogic((av_st_ready = '1') AND (inhibit_read = '0'));
   
   --////////////////////////////////////////////////////////////////////
   -- CRC Data Mux
   -- The user_data input stream can contain DW gaps depending 
   -- on the Header type (3DW/4DW), and the address alignment.
   -- This mux reformats the data so that there are no gaps because
   -- the CRC module requires contiguous DWs.
   --     This mux selects between:
   --         - Unmodified data format
   --         - Append DW from next data cycle, Without shifting current data
   --         - Append DW from next data cycle, And shift current data up 1DW
   
   user_data_masked(127 DOWNTO 121) <= user_data(127 DOWNTO 121);
   user_data_masked(120) <= '1' WHEN (user_sop = '1') ELSE      -- TYP[0]
                            user_data(120);
   user_data_masked(119 DOWNTO 112) <= user_data(119 DOWNTO 112);
   user_data_masked(111) <= '1' WHEN (user_sop = '1') ELSE      -- TD
                            user_data(111);
   user_data_masked(110) <= '1' WHEN (user_sop = '1') ELSE      -- EP
                            user_data(110);
   user_data_masked(109 DOWNTO 0) <= user_data(109 DOWNTO 0);
   
   user_is_3dW_nonaligned <= to_stdlogic((user_is_4dw = '0') AND (user_data(98) = '1'));
   
   -- reformat the data-phase portion of the input data to reverse the byte ordering.  
   -- left-most byte is first on line.
   -- 3DW Hdr Nonaligned - User data contains Header and Data phases
   user_data_masked_swizzled(127 DOWNTO 64) <= user_data_masked(127 DOWNTO 64) WHEN (user_sop = '1') ELSE       -- First 64 bits of descriptor phase
                                               (user_data_masked(127 DOWNTO 96) & user_data_masked(71 DOWNTO 64) & user_data_masked(79 DOWNTO 72) & user_data_masked(87 DOWNTO 80) & user_data_masked(95 DOWNTO 88)) WHEN ((user_last_was_sop = '1') AND (user_is_3dW_nonaligned = '1')) ELSE       -- User data contains only Data phase
                                               user_data_masked(127 DOWNTO 64) WHEN (user_last_was_sop = '1') ELSE
                                               (user_data_masked(103 DOWNTO 96) & user_data_masked(111 DOWNTO 104) & user_data_masked(119 DOWNTO 112) & user_data_masked(127 DOWNTO 120) & user_data_masked(71 DOWNTO 64) & user_data_masked(79 DOWNTO 72) & user_data_masked(87 DOWNTO 80) & user_data_masked(95 DOWNTO 88));
   
   user_data_masked_swizzled(63 DOWNTO 0) <= "0000000000000000000000000000000000000000000000000000000000000000";
   
   PROCESS (clk)
   BEGIN
      IF (clk'EVENT AND clk = '1') THEN
         IF (user_valid = '1') THEN
            user_data_masked_del <= user_data_masked_swizzled;
         END IF;
      END IF;
   END PROCESS;
   
   crc_data(127 DOWNTO 64) <= (user_data_masked_del(127 DOWNTO 96) & user_data_masked_swizzled(127 DOWNTO 96)) WHEN (send_to_crc_appended = '1') ELSE
                              (user_data_masked_del(95 DOWNTO 64) & user_data_masked_swizzled(127 DOWNTO 96)) WHEN (send_to_crc_shifted = '1') ELSE
                              user_data_masked_del(127 DOWNTO 64);
   
   crc_data(63 DOWNTO 0) <= "0000000000000000000000000000000000000000000000000000000000000000";
   
   --//////////////////////////////////////////////
   -- CRC Control
   -- Generates 
   --      - CRC Avalon-ST control signals 
   --      - CRC Data Mux select controls
   
   -- default  
   
   -- default
   -- default
   -- default 
   -- default
   -- default
   -- default
   -- default
   -- default
   -- default 
   -- default
   
   xhdl14 <= to_stdlogic((user_data(98) = '0')) WHEN (user_is_4dw = '0') ELSE
                            to_stdlogic((user_data(66) = '0'));
   -- 4DW HEADER   
   -- this is a single-cycle pkt
   xhdl15 <= '1' WHEN (user_data(66) = '1') ELSE        -- nonaligned/aligned addr
                            '0';
   -- this is a multi-cycle pkt                
   -- NonAligned Address -- will need to shift data phases
   -- tx_data is 128bit aligned
   -- account for empty DW from non-alignment
   -- Aligned Address -- send data phases without shifting                     
   -- 3DW HEADER  
   -- this is a single-cycle pkt 
   -- no payld
   -- non-aligned
   -- Aligned address
   -- 1DW payld, Non-Aligned
   -- this is a multi-cycle pkt 
   -- NonAligned address
   -- Aligned address
   -- special case:  3DW header, 1DW payload .. This will be the last CRC cycle 
   -- no data on this txdata cycle (3DW aligned)
   -- end 3DW Header
   -- end sop   
   -- default
   -- default
   -- should separate the crc and tx equations.  
   -- this is the last cycle
   xhdl16 <= EXTRA_CRC_CYC_3  WHEN (tx_rem_length(2 DOWNTO 0) = "010") ELSE
                            WAIT_SOP_3 ;
   -- default
   -- default
   -- should separate the crc and tx equations.  
   -- this is the last cycle
   xhdl17 <= EXTRA_CRC_CYC_3  WHEN (tx_rem_length(2 DOWNTO 0) = "010") ELSE
                            WAIT_SOP_3 ;
   xhdl18 <= '1' WHEN (user_valid = '1') ELSE
                            deferred_valid;
   xhdl19 <= "0010" WHEN (insert_ecrc_in_hi = '1') ELSE
                            "0001";
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         state <= WAIT_SOP_3 ;
         crc_sop <= '0';
         crc_eop <= '0';
         crc_valid <= '0';
         tx_insert_crc_cyc <= '0';
         send_to_crc_appended <= '0';
         send_to_crc_as_is <= '0';
         send_to_crc_shifted <= '0';
         tx_rem_length <= "0000000000";
         crc_rem_length <= "0000000000";
         crc_empty <= "0000";
         tx_crc_location <= "0000";
         insert_ecrc_in_hi <= '0';
         deferred_valid <= '0';
         inhibit_read <= '0';
         debug_is_aligned <= '0';
         debug_is_3dw <= '0';
         user_last_was_sop <= '0';
         user_is_4dw <= '0';
         user_data_length <= "0000000000";
         user_has_payld <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         crc_valid <= '0';
         IF (av_st_ready = '1') THEN
            user_last_was_sop <= to_stdlogic((user_sop = '1') AND (user_valid = '1'));
            crc_empty <= "0000";
            crc_eop <= '0';
            crc_sop <= '0';
            CASE state IS
               WHEN WAIT_SOP_3  =>
                  crc_valid <= '0';
                  tx_crc_location <= "0000";
                  crc_empty <= "0000";
                  crc_eop <= '0';
                  crc_sop <= '0';
                  tx_insert_crc_cyc <= '0';
                  tx_crc_location <= "0000";
                  insert_ecrc_in_hi <= '0';
                  debug_is_3dw <= to_stdlogic((user_data(125) = '0'));
                  IF ((user_sop = '1') AND (user_valid = '1')) THEN
                     crc_sop <= '1';
                     crc_valid <= '1';
                     deferred_valid <= '0';
                     user_is_4dw <= to_stdlogic((user_data(125) = '1'));
                     user_data_length <= user_data(105 DOWNTO 96);
                     user_has_payld <= user_data(126);
                     send_to_crc_as_is <= '1';
                     send_to_crc_appended <= '0';
                     send_to_crc_shifted <= '0';
                     state <= WAIT_SOP2_3 ;
                  END IF;
               WHEN WAIT_SOP2_3  =>
                  IF (user_valid = '1') THEN
                     crc_valid <= '1';
                     debug_is_aligned <= xhdl14;
                     IF (user_is_4dw = '1') THEN
                        crc_empty <= "0000";
                        tx_crc_location <= "0000";
                        send_to_crc_as_is <= '1';
                        send_to_crc_appended <= '0';
                        send_to_crc_shifted <= '0';
                        IF (user_eop(1) = '1') THEN
                           tx_insert_crc_cyc <= '1';
                           inhibit_read <= '1';
                           state <= EXTRA_CRC_CYC_3 ;
                           crc_eop <= '1';
                           insert_ecrc_in_hi <= xhdl15;
                        ELSE
                           IF (user_data(66) = '1') THEN
                              need_insert_crc_cyc <= to_stdlogic((user_data_length(3 DOWNTO 2) = "11"));
                              state <= SEND_PACKED_DATA_3 ;
                              tx_rem_length <= user_data_length + "0000000001";
                              crc_rem_length <= user_data_length;
                           ELSE
                              state <= SEND_DATA_3 ;
                              tx_rem_length <= user_data_length;
                              crc_rem_length <= user_data_length;
                           END IF;
                        END IF;
                     ELSIF (user_is_4dw = '0') THEN
                        IF (user_eop(1) = '1') THEN
                           send_to_crc_as_is <= '1';
                           send_to_crc_appended <= '0';
                           send_to_crc_shifted <= '0';
                           crc_eop <= '1';
                           IF (user_has_payld = '0') THEN
                              IF (user_data(98) = '1') THEN
                                 crc_empty <= "0100";
                                 tx_crc_location <= "0010";
                                 tx_insert_crc_cyc <= '0';
                                 state <= WAIT_SOP_3 ;
                              ELSE
                                 crc_empty <= "0100";
                                 tx_crc_location <= "0000";
                                 tx_insert_crc_cyc <= '1';
                                 inhibit_read <= '1';
                                 state <= EXTRA_CRC_CYC_3 ;
                              END IF;
                           ELSE
                              crc_empty <= "0000";
                              tx_crc_location <= "0000";
                              tx_insert_crc_cyc <= '1';
                              inhibit_read <= '1';
                              state <= EXTRA_CRC_CYC_3 ;
                           END IF;
                        ELSE
                           crc_empty <= "0000";
                           tx_crc_location <= "0000";
                           IF (user_data(98) = '1') THEN
                              state <= SEND_DATA_3 ;
                              send_to_crc_as_is <= '1';
                              send_to_crc_appended <= '0';
                              send_to_crc_shifted <= '0';
                              tx_rem_length <= user_data_length - "0000000001";
                              crc_rem_length <= user_data_length - "0000000001";
                           ELSE
                              send_to_crc_as_is <= '0';
                              send_to_crc_appended <= '1';
                              send_to_crc_shifted <= '0';
                              crc_eop <= to_stdlogic((user_data_length = "0000000001"));
                              state <= SEND_PACKED_DATA_3 ;
                              tx_rem_length <= user_data_length;
                              crc_rem_length <= user_data_length - "0000000001";
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               WHEN SEND_PACKED_DATA_3  =>
                  send_to_crc_as_is <= '0';
                  send_to_crc_appended <= '0';
                  send_to_crc_shifted <= '1';
                  tx_crc_location <= "0000";
                  crc_empty <= "0000";
                  crc_valid <= to_stdlogic((user_valid = '1') AND (crc_rem_length(9 DOWNTO 0) /= "0000000000"));
                  IF (user_valid = '1') THEN
                     IF (user_eop(1) = '0') THEN
                        tx_rem_length <= tx_rem_length - "0000000010";
                        crc_rem_length <= crc_rem_length - "0000000010";
                        state <= state;
                        crc_empty <= "0000";
                        tx_crc_location <= "0000";
                        crc_eop <= to_stdlogic((crc_rem_length < "0000000011"));
                     ELSE
                        tx_insert_crc_cyc <= to_stdlogic((tx_rem_length(2 DOWNTO 0) = "010"));
                        inhibit_read <= to_stdlogic((tx_rem_length(2 DOWNTO 0) = "010"));
                        state <= xhdl16;
                        crc_eop <= to_stdlogic((crc_rem_length(2 DOWNTO 0) /= "000"));
                        CASE crc_rem_length(2 DOWNTO 0) IS
                           WHEN "010" =>
                              crc_empty <= "0000";
                           WHEN "001" =>
                              crc_empty <= "0100";
                           WHEN OTHERS =>
                              crc_empty <= "0000";
                        END CASE;
                        CASE tx_rem_length(2 DOWNTO 0) IS
                           WHEN "010" =>
                              tx_crc_location <= "0000";
                           WHEN "001" =>
                              tx_crc_location <= "0010";
                           WHEN OTHERS =>
                              tx_crc_location <= "0000";
                        END CASE;
                     END IF;
                  END IF;
               WHEN SEND_DATA_3  =>
                  send_to_crc_as_is <= '1';
                  send_to_crc_appended <= '0';
                  send_to_crc_shifted <= '0';
                  tx_crc_location <= "0000";
                  crc_empty <= "0000";
                  crc_valid <= to_stdlogic((user_valid = '1') AND (crc_rem_length(9 DOWNTO 0) /= "0000000000"));
                  IF (user_valid = '1') THEN
                     IF (user_eop(1) = '0') THEN
                        tx_rem_length <= tx_rem_length - "0000000010";
                        crc_rem_length <= crc_rem_length - "0000000010";
                        state <= state;
                        crc_empty <= "0000";
                        tx_crc_location <= "0000";
                        crc_eop <= to_stdlogic((crc_rem_length < "0000000011"));
                     ELSE
                        tx_insert_crc_cyc <= to_stdlogic((tx_rem_length(2 DOWNTO 0) = "010"));
                        inhibit_read <= to_stdlogic((tx_rem_length(2 DOWNTO 0) = "010"));
                        state <= xhdl17;
                        crc_eop <= to_stdlogic((crc_rem_length(2 DOWNTO 0) /= "000"));
                        CASE crc_rem_length(2 DOWNTO 0) IS
                           WHEN "010" =>
                              crc_empty <= "0000";
                           WHEN "001" =>
                              crc_empty <= "0100";
                           WHEN OTHERS =>
                              crc_empty <= "0000";
                        END CASE;
                        CASE tx_rem_length(2 DOWNTO 0) IS
                           WHEN "010" =>
                              tx_crc_location <= "0000";
                           WHEN "001" =>
                              tx_crc_location <= "0010";
                           WHEN OTHERS =>
                              tx_crc_location <= "0000";
                        END CASE;
                     END IF;
                  END IF;
               WHEN EXTRA_CRC_CYC_3  =>
                  deferred_valid <= xhdl18;
                  IF (av_st_ready = '1') THEN
                     inhibit_read <= '0';
                     tx_insert_crc_cyc <= '0';
                     state <= WAIT_SOP_3 ;
                     tx_crc_location <= xhdl19;
                  END IF;
               WHEN OTHERS =>
                  state <= WAIT_SOP_3 ;
            END CASE;
         END IF;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
