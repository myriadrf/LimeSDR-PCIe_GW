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
-- File          : altpcierd_cpld_rx_buffer.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module monitors the rxbuffer space for read completion and calculate the number 
-- of allocated/freed credit for header and data.
--  Parameters 
--       MAX_NUMTAG        : Specify the maximum number of TAGs
--       CPLD_64K_BOUNDARY : When 1 , assume that the RP system issues completion limited
--                           to 64 byte length
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
ENTITY altpcierd_cpld_rx_buffer IS
   GENERIC (
      MAX_NUMTAG                 : INTEGER := 32;
      CHECK_RX_BUFFER_CPL        : INTEGER := 1;
      CPLD_64K_BOUNDARY          : INTEGER := 1
   );
   PORT (
      clk_in                     : IN STD_LOGIC;
      srst                       : IN STD_LOGIC;
      rx_ack0                    : IN STD_LOGIC;
      rx_req0                    : IN STD_LOGIC;
      rx_desc0                   : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      tx_req0                    : IN STD_LOGIC;
      tx_ack0                    : IN STD_LOGIC;
      tx_desc0                   : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      ko_cpl_spc_vc0             : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
      rx_buffer_cpl_max_dw       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      cpld_rx_buffer_ready       : OUT STD_LOGIC
   );
END ENTITY altpcierd_cpld_rx_buffer;
ARCHITECTURE altpcie OF altpcierd_cpld_rx_buffer IS


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
                                                
   
         
   CONSTANT TAGRAM_WIDTH_ADDR          : INTEGER := ceil_log2(MAX_NUMTAG);
   CONSTANT MAX_RAM_NUMWORDS           : INTEGER := get_numwords(TAGRAM_WIDTH_ADDR);
   CONSTANT TAGRAM_WIDTH               : INTEGER := 10;
   CONSTANT ONE_INTEGER                : INTEGER := 1;
   CONSTANT MAX_HEADER_CREDIT_PER_MRD  : INTEGER := 4 ;
   
   

   SIGNAL cst_one                               : STD_LOGIC;
   SIGNAL cst_zero                              : STD_LOGIC;
   SIGNAL cst_std_logic_vector_type_one         : STD_LOGIC_VECTOR(63 DOWNTO 0);
   
   SIGNAL tagram_wren_a                         : STD_LOGIC;
   SIGNAL tagram_data_a                         : STD_LOGIC_VECTOR(TAGRAM_WIDTH - 1 DOWNTO 0);
   SIGNAL tagram_address_a                      : STD_LOGIC_VECTOR(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0);
   
   SIGNAL tagram_wren_b                         : STD_LOGIC;
   SIGNAL tagram_data_b                         : STD_LOGIC_VECTOR(TAGRAM_WIDTH - 1 DOWNTO 0);
   SIGNAL tagram_address_b                      : STD_LOGIC_VECTOR(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0);
   SIGNAL tagram_q_b                            : STD_LOGIC_VECTOR(TAGRAM_WIDTH - 1 DOWNTO 0);
   
   SIGNAL estimated_header_credits              : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL lim_cplh_cred                         : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_mrd_header_credit                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL rx_cpl_header_credit                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   
   SIGNAL estimated_data_credits                : STD_LOGIC_VECTOR(13 DOWNTO 0);
   SIGNAL lim_cpld_cred                         : STD_LOGIC_VECTOR(13 DOWNTO 0);
   SIGNAL tx_mrd_data_credit                    : STD_LOGIC_VECTOR(13 DOWNTO 0);
   SIGNAL rx_cpl_data_credit                    : STD_LOGIC_VECTOR(13 DOWNTO 0);
   
   SIGNAL estimated_header_credits_64           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL estimated_rx_buffer_cpl_header_max_dw : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL estimated_rx_buffer_cpl_data_max_dw   : STD_LOGIC_VECTOR(15 DOWNTO 0);
   
   SIGNAL tx_tag                                : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL tx_length_dw                          : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_fmt_type                           : STD_LOGIC_VECTOR(6 DOWNTO 0);
   
   SIGNAL rx_tag                                : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL rx_length_dw                          : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL rx_length_dw_byte                     : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL rx_byte_count                         : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL rx_fmt_type                           : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL read_tagram                           : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL rx_ack_reg                            : STD_LOGIC;

   --------------------------------------------------------------
   --    XHDL signal for translation 
   --------------------------------------------------------------
   SIGNAL xhdl_zero_byte          : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_zero_word          : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_zero_dword         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_zero_qword         : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_zero_dqword        : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_one_byte           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_one_word           : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL xhdl_one_dword          : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl_one_qword          : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL xhdl_one_dqword         : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_open_dqword        : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL xhdl_two_bytes          : STD_LOGIC_VECTOR(7 DOWNTO 0);
   
   SIGNAL xhdl_tagram_q_b_byte                  : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_tx_mrd_header_credit             : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL xhdl_tx_mrd_header_credit_13_0        : STD_LOGIC_VECTOR(13 DOWNTO 0);
   SIGNAL xhdl_rx_cpl_data_credit               : STD_LOGIC_VECTOR(13 DOWNTO 0);
   SIGNAL xhdl_ko_cpl_spc_vc0_13_ext            : STD_LOGIC_VECTOR(13 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl1 : STD_LOGIC;
BEGIN

   xhdl_zero_byte    <= (others=>'0'); 
   xhdl_zero_word    <= (others=>'0'); 
   xhdl_zero_dword   <= (others=>'0'); 
   xhdl_zero_qword   <= (others=>'0'); 
   xhdl_zero_dqword  <= (others=>'0'); 
   xhdl_one_byte     <= xhdl_zero_byte   (7 downto 1)   & '1'; 
   xhdl_one_word     <= xhdl_zero_word   (15 downto 1)  & '1'; 
   xhdl_one_dword    <= xhdl_zero_dword  (31 downto 1)  & '1'; 
   xhdl_one_qword    <= xhdl_zero_qword  (63 downto 1)  & '1'; 
   xhdl_one_dqword   <= xhdl_zero_dqword (127 downto 1) & '1'; 
   xhdl_two_bytes    <= "00000010";
   
   cst_one <= '1';
   cst_zero <= '0';
   cst_std_logic_vector_type_one(0 DOWNTO 0) <= "1";
   
   -- TX
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_req0 = '1') THEN
            tx_fmt_type <= tx_desc0(126 DOWNTO 120);
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_req0 = '1') THEN
            tx_tag <= tx_desc0(79 DOWNTO 72);
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (tx_req0 = '1') THEN
            tx_length_dw <= tx_desc0(105 DOWNTO 96);
         END IF;
      END IF;
   END PROCESS;
   
   --RX
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_ack0 = '1') THEN
            rx_fmt_type <= rx_desc0(126 DOWNTO 120);
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_ack0 = '1') THEN
            rx_tag <= rx_desc0(47 DOWNTO 40);
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_ack0 = '1') THEN
            rx_length_dw <= rx_desc0(105 DOWNTO 96);
         END IF;
      END IF;
   END PROCESS;
   
   rx_length_dw_byte(1 DOWNTO 0) <= "00";
   rx_length_dw_byte(11 DOWNTO 2) <= rx_length_dw(9 DOWNTO 0);
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         rx_ack_reg <= rx_ack0;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (rx_ack0 = '1') THEN
            rx_byte_count <= rx_desc0(75 DOWNTO 64);
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF ((srst = '1') OR (ko_cpl_spc_vc0 = "11111111111111111111") OR (CHECK_RX_BUFFER_CPL = 0)) THEN
            cpld_rx_buffer_ready <= '1';
         ELSIF (estimated_header_credits = "00000000") THEN
            cpld_rx_buffer_ready <= '0';
         ELSIF (estimated_data_credits = "00000000000000") THEN
            cpld_rx_buffer_ready <= '0';
         ELSIF ((tagram_wren_a = '1') AND (read_tagram(4) = '0') AND ((estimated_header_credits <= tx_mrd_header_credit) OR (estimated_data_credits <= tx_mrd_data_credit))) THEN
            cpld_rx_buffer_ready <= '0';
         ELSE
            cpld_rx_buffer_ready <= '1';
         END IF;
      END IF;
   END PROCESS;
   
   --/////////////////////////////////////////////////////////////////////////////////////// 
   -- Update available rx buffer header credit counter (estimated_header_credits)
   -- When transmitting MRd, assume worst case that it consumes 4 credit in RX Buffer 
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (CPLD_64K_BOUNDARY = 0) THEN
            lim_cplh_cred <= ko_cpl_spc_vc0(7 downto 0) - xhdl_two_bytes;
         ELSIF (read_tagram(3) = '1') THEN
            IF (ko_cpl_spc_vc0 > ("000000000000" & rx_cpl_header_credit)) THEN
               lim_cplh_cred(7 DOWNTO 0) <= ko_cpl_spc_vc0(7 DOWNTO 0) - rx_cpl_header_credit;
            ELSE
               lim_cplh_cred(7 DOWNTO 0) <= "00000001";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   xhdl_tagram_q_b_byte(7 DOWNTO 6) <= "00";
   xhdl_tagram_q_b_byte(5 DOWNTO 0) <= tagram_q_b(9 DOWNTO 4);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         -- Compute the number of freed header credit (rx_cpl_header_credit) 
         -- required when tx issues MRD
         -- divide by 16 DWORDs (or 64 bytes) and add 1 for potential 4k completion boundary
         IF (CPLD_64K_BOUNDARY = 1) THEN
            IF (read_tagram(2) = '1') THEN
               rx_cpl_header_credit(7 DOWNTO 0) <= xhdl_tagram_q_b_byte + xhdl_one_byte;
            END IF;
         ELSE
            rx_cpl_header_credit(7 DOWNTO 0) <= xhdl_two_bytes;
         END IF;
      END IF;
   END PROCESS;
   
   xhdl_tx_mrd_header_credit(7 DOWNTO 6) <= "00";
   xhdl_tx_mrd_header_credit(5 DOWNTO 0) <= tx_length_dw(9 DOWNTO 4);
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         -- Compute the number of allocated header credit (tx_mrd_header_credit) 
         -- required when tx issues MRD
         -- divide by 16 DWORDs (or 64 bytes) and add 1 for potential 4k completion boundary
         IF (CPLD_64K_BOUNDARY = 1) THEN
            tx_mrd_header_credit(7 DOWNTO 0) <= xhdl_tx_mrd_header_credit + xhdl_one_byte;
         ELSE
            tx_mrd_header_credit(7 DOWNTO 0) <= xhdl_two_bytes;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            estimated_header_credits(7 DOWNTO 0) <= ko_cpl_spc_vc0(7 DOWNTO 0);
         ELSIF ((tagram_wren_a = '1') AND (read_tagram(4) = '0')) THEN
            IF (estimated_header_credits <= tx_mrd_header_credit) THEN
               estimated_header_credits <= "00000000";
            ELSE
               estimated_header_credits <= estimated_header_credits - tx_mrd_header_credit;
            END IF;
         ELSIF ((read_tagram(4) = '1') AND (tagram_wren_a = '0')) THEN
            IF (estimated_header_credits > lim_cplh_cred) THEN
               estimated_header_credits <= ko_cpl_spc_vc0(7 DOWNTO 0);
            ELSE
               estimated_header_credits <= estimated_header_credits + rx_cpl_header_credit;
            END IF;
         ELSIF ((read_tagram(4) = '1') AND (tagram_wren_a = '1')) THEN
            --TODO corner case when simultaneous RX TX
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (estimated_header_credits > "00000000") THEN
            estimated_header_credits_64 <= estimated_header_credits - "00000001";
         ELSE
            estimated_header_credits_64 <= "00000000";
         END IF;
      END IF;
   END PROCESS;
   estimated_rx_buffer_cpl_header_max_dw(3 DOWNTO 0) <= "0000";
   estimated_rx_buffer_cpl_header_max_dw(11 DOWNTO 4) <= estimated_header_credits_64(7 DOWNTO 0);
   estimated_rx_buffer_cpl_header_max_dw(15 DOWNTO 12) <= "0000";
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (CHECK_RX_BUFFER_CPL = 0) THEN
            rx_buffer_cpl_max_dw <= "1111111111111111";
         ELSIF (estimated_rx_buffer_cpl_data_max_dw > estimated_rx_buffer_cpl_header_max_dw) THEN
            rx_buffer_cpl_max_dw <= estimated_rx_buffer_cpl_header_max_dw;
         ELSE
            rx_buffer_cpl_max_dw <= estimated_rx_buffer_cpl_data_max_dw;
         END IF;
      END IF;
   END PROCESS;
   
   --/////////////////////////////////////////////////////////////////////////////////////// 
   -- Update available RX Buffer credit for data counter (estimated_data_credits)
   -- When transmitting MRd, assume worst case that it consumes 4 credit in RX Buffer 
   xhdl_tx_mrd_header_credit_13_0(13 DOWNTO 8) <= "000000";
   xhdl_tx_mrd_header_credit_13_0(7 DOWNTO 0) <= tx_length_dw(9 DOWNTO 2);
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         -- Compute the number of allocated data credit (tx_mrd_header_credit) 
         -- required when tx issues MRD
         -- take the tx_length in DWORD and divide by 4 and ceiled 
         IF (tx_length_dw(1 DOWNTO 0) = "00") THEN
            tx_mrd_data_credit(13 DOWNTO 0) <= xhdl_tx_mrd_header_credit_13_0;
         ELSE
            tx_mrd_data_credit(13 DOWNTO 0) <= xhdl_tx_mrd_header_credit_13_0 + "00000000000001";
         END IF;
      END IF;
   END PROCESS;
   
   xhdl_rx_cpl_data_credit(13 DOWNTO 8) <= "000000";
   xhdl_rx_cpl_data_credit(7 DOWNTO 0) <= tagram_q_b(9 DOWNTO 2);
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         -- Compute the number of freed header credit (rx_cpl_header_credit) 
         -- required when tx issues MRD
         -- divide by 16 DWORDs (or 64 bytes) and add 1 for potential 4k completion boundary
         IF (read_tagram(2) = '1') THEN
            IF (tagram_q_b(1 DOWNTO 0) = "00") THEN
               rx_cpl_data_credit(13 DOWNTO 0) <= xhdl_rx_cpl_data_credit;
            ELSE
               rx_cpl_data_credit(13 DOWNTO 0) <= xhdl_rx_cpl_data_credit + "00000000000001";
            END IF;
         END IF;
      END IF;
   END PROCESS;
   
   xhdl_ko_cpl_spc_vc0_13_ext(11 DOWNTO 0) <= ko_cpl_spc_vc0(19 DOWNTO 8);
   xhdl_ko_cpl_spc_vc0_13_ext(13 DOWNTO 12) <= "00";
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (read_tagram(3) = '1') THEN
            lim_cpld_cred(13 DOWNTO 0) <= xhdl_ko_cpl_spc_vc0_13_ext - rx_cpl_data_credit;
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            estimated_data_credits(13 DOWNTO 0) <= xhdl_ko_cpl_spc_vc0_13_ext;
         ELSIF ((tagram_wren_a = '1') AND (read_tagram(4) = '0')) THEN
            IF (estimated_data_credits <= tx_mrd_data_credit) THEN
               estimated_data_credits <= "00000000000000";
            ELSE
               estimated_data_credits <= estimated_data_credits - tx_mrd_data_credit;
            END IF;
         ELSIF ((read_tagram(4) = '1') AND (tagram_wren_a = '0')) THEN
            IF (estimated_data_credits > lim_cpld_cred) THEN
               estimated_data_credits <= xhdl_ko_cpl_spc_vc0_13_ext;
            ELSE
               estimated_data_credits <= estimated_data_credits + rx_cpl_data_credit;
            END IF;
         ELSIF ((read_tagram(4) = '1') AND (tagram_wren_a = '1')) THEN
            --TODO corner case when simultaneous RX TX
         END IF;
      END IF;
   END PROCESS;
   
   estimated_rx_buffer_cpl_data_max_dw(1 DOWNTO 0) <= "00";
   estimated_rx_buffer_cpl_data_max_dw(15 DOWNTO 2) <= estimated_data_credits(13 DOWNTO 0);
   
   xhdl0 : IF (CHECK_RX_BUFFER_CPL = 1) GENERATE
      
      -- The TAG RAM store the number of credit required for a given Mrd
      -- It uses converted tx_length in DWORD to credits 
      
      
      rx_buffer_cpl_tagram : altsyncram
         GENERIC MAP (
            address_reg_b                       => "CLOCK0",
            indata_reg_b                        => "CLOCK0",
            wrcontrol_wraddress_reg_b           => "CLOCK0",
            intended_device_family              => "Stratix II",
            numwords_a                          => MAX_RAM_NUMWORDS,
            numwords_b                          => MAX_RAM_NUMWORDS,
            operation_mode                      => "BIDIR_DUAL_PORT",
            outdata_aclr_a                      => "NONE",
            outdata_aclr_b                      => "NONE",
            outdata_reg_a                       => "CLOCK0",
            outdata_reg_b                       => "CLOCK0",
            power_up_uninitialized              => "FALSE",
            read_during_write_mode_mixed_ports  => "DONT_CARE",
            widthad_a                           => TAGRAM_WIDTH_ADDR,
            widthad_b                           => TAGRAM_WIDTH_ADDR,
            width_a                             => TAGRAM_WIDTH,
            width_b                             => TAGRAM_WIDTH,
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
            byteena_a       => cst_std_logic_vector_type_one(0 DOWNTO 0),
            byteena_b       => cst_std_logic_vector_type_one(0 DOWNTO 0),
            clock1          => cst_one,
            clocken0        => cst_one,
            clocken1        => cst_one,
            q_a             => xhdl_open_dqword(TAGRAM_WIDTH-1 downto 0)
         );
   END GENERATE;
   
   -- TAGRAM port A      
   xhdl1 <= '1' WHEN ((tx_ack0 = '1') AND (tx_fmt_type(4 DOWNTO 0) = "00000") AND (tx_fmt_type(6) = '0')) ELSE
                                                       '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         tagram_address_a(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0) <= tx_tag(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0);
         tagram_data_a(TAGRAM_WIDTH - 1 DOWNTO 0) <= tx_length_dw;
         tagram_wren_a <= xhdl1;
      END IF;
   END PROCESS;
   -- TAGRAM port B
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            tagram_address_b(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0) <= (others =>'0');
         ELSIF (rx_ack_reg = '1') THEN
            tagram_address_b(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0) <= rx_tag(TAGRAM_WIDTH_ADDR - 1 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;
   
   tagram_data_b <= "0000000000";
   tagram_wren_b <= '0';
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (srst = '1') THEN
            read_tagram(0) <= '0';
         ELSIF ((rx_length_dw_byte >= rx_byte_count) AND (rx_fmt_type(6 DOWNTO 1) = "100101") AND (rx_ack_reg = '1')) THEN
            read_tagram(0) <= '1';
         ELSE
            read_tagram(0) <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         read_tagram(1) <= read_tagram(0);
         read_tagram(2) <= read_tagram(1);
         read_tagram(3) <= read_tagram(2);
         read_tagram(4) <= read_tagram(3);
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
