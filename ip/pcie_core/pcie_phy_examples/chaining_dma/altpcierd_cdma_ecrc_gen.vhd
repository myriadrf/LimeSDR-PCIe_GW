LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
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
ENTITY altpcierd_cdma_ecrc_gen IS
   GENERIC (
      XHDL_STR           : STRING := "XHDL_STR";
      AVALON_ST_128      : INTEGER := 0
      
      -- user data (avalon-st formatted) 
      -- request for next user_data
      -- means this cycle contains the start of a packet
      -- means this cycle contains the end of a packet
      -- avalon streaming packet data
      -- means user_sop, user_eop, user_data are valid
      
   );
   PORT (
      clk                : IN STD_LOGIC;
      rstn               : IN STD_LOGIC;
      user_rd_req        : OUT STD_LOGIC;
      user_sop           : IN STD_LOGIC;
      user_eop           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      user_data          : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      user_valid         : IN STD_LOGIC;
      tx_stream_ready0   : IN STD_LOGIC;
      tx_stream_data0_0  : OUT STD_LOGIC_VECTOR(75 DOWNTO 0);
      tx_stream_data0_1  : OUT STD_LOGIC_VECTOR(75 DOWNTO 0);
      tx_stream_valid0   : OUT STD_LOGIC
   );
END ENTITY altpcierd_cdma_ecrc_gen;
ARCHITECTURE altpcie OF altpcierd_cdma_ecrc_gen IS


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
   FUNCTION or_br (                                        
        val : std_logic_vector) RETURN std_logic IS        
                                                           
        VARIABLE rtn : std_logic := '0';                   
     BEGIN                                                 
        FOR index IN val'RANGE LOOP                        
           rtn := rtn OR val(index);                       
        END LOOP;                                          
        RETURN(rtn);                                       
     END or_br;                                            
                                                           
                                                
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
                                                
   COMPONENT altpcierd_cdma_ecrc_gen_calc IS
      GENERIC (
         XHDL_STR           : STRING := "XHDL_STR";
         AVALON_ST_128      : INTEGER := 0
      );
      PORT (
         clk                : IN STD_LOGIC;
         rstn               : IN STD_LOGIC;
         crc_data           : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
         crc_valid          : IN STD_LOGIC;
         crc_empty          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         crc_eop            : IN STD_LOGIC;
         crc_sop            : IN STD_LOGIC;
         ecrc               : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         crc_ack            : IN STD_LOGIC
      );
   END COMPONENT;
   
   COMPONENT altpcierd_cdma_ecrc_gen_ctl_128 IS
      PORT (
         clk                : IN STD_LOGIC;
         rstn               : IN STD_LOGIC;
         user_rd_req        : OUT STD_LOGIC;
         user_sop           : IN STD_LOGIC;
         user_eop           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         user_data          : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
         user_valid         : IN STD_LOGIC;
         crc_empty          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         crc_sop            : OUT STD_LOGIC;
         crc_eop            : OUT STD_LOGIC;
         crc_data           : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         crc_valid          : OUT STD_LOGIC;
         tx_sop             : OUT STD_LOGIC;
         tx_eop             : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
         tx_data            : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
         tx_valid           : OUT STD_LOGIC;
         tx_crc_location    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         tx_shift           : OUT STD_LOGIC;
         av_st_ready        : IN STD_LOGIC
      );
   END COMPONENT;
   
   
   CONSTANT       ZERO_INTEGER       : INTEGER := 0;
   CONSTANT       ONE_INTEGER        : INTEGER := 1;


COMPONENT altpcierd_cdma_ecrc_gen_ctl_64 IS
   PORT (
      clk                : IN STD_LOGIC;
      rstn               : IN STD_LOGIC;
      user_rd_req        : OUT STD_LOGIC;
      user_sop           : IN STD_LOGIC;
      user_eop           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      user_data          : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      user_valid         : IN STD_LOGIC;
      crc_empty          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      crc_sop            : OUT STD_LOGIC;
      crc_eop            : OUT STD_LOGIC;
      crc_data           : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      crc_valid          : OUT STD_LOGIC;
      tx_sop             : OUT STD_LOGIC;
      tx_eop             : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      tx_data            : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_valid           : OUT STD_LOGIC;
      tx_crc_location    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      tx_shift           : OUT STD_LOGIC;
      av_st_ready        : IN STD_LOGIC
   );
END COMPONENT;

COMPONENT altpcierd_cdma_ecrc_gen_datapath IS
   PORT (
      clk                : IN STD_LOGIC;
      rstn               : IN STD_LOGIC;
      data_in            : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      data_valid         : IN STD_LOGIC;
      rdreq              : IN STD_LOGIC;
      data_out           : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
      data_out_valid     : OUT STD_LOGIC;
      full               : OUT STD_LOGIC
   );
END COMPONENT;

   SIGNAL crc_data               : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL crc_sop                : STD_LOGIC;
   SIGNAL crc_eop                : STD_LOGIC;
   SIGNAL crc_valid              : STD_LOGIC;
   SIGNAL crc_empty              : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   SIGNAL tx_data                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_sop                 : STD_LOGIC;
   SIGNAL tx_eop                 : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL tx_valid               : STD_LOGIC;
   SIGNAL tx_shift               : STD_LOGIC;
   SIGNAL tx_crc_location        : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
   SIGNAL ecrc                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL ecrc_reversed          : STD_LOGIC_VECTOR(31 DOWNTO 0);
   
   SIGNAL tx_data_vec            : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL tx_data_vec_del        : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL tx_data_output         : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_sop_output          : STD_LOGIC;
   SIGNAL tx_eop_output          : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL tx_crc_location_output : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL ecrc_rev_hold          : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL crc_ack                : STD_LOGIC;
   SIGNAL tx_data_vec_del_valid  : STD_LOGIC; 
   SIGNAL tx_datapath_full       : STD_LOGIC;
   -- X-HDL generated signals
   SIGNAL xhdl2 : STD_LOGIC;
   SIGNAL xhdl4 : STD_LOGIC;
   SIGNAL xhdl5 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl6 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl7 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl8 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL user_rd_req_xhdl0      : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   user_rd_req <= user_rd_req_xhdl0;
   
   xhdl1 : IF (AVALON_ST_128 = ONE_INTEGER) GENERATE
      
      
      xhdl2 <= NOT(tx_datapath_full);
      ecrc_gen_ctl_128 : altpcierd_cdma_ecrc_gen_ctl_128
         PORT MAP (
            clk              => clk,
            rstn             => rstn,
            user_rd_req      => user_rd_req_xhdl0,
            user_sop         => user_sop,
            user_eop         => user_eop,
            user_data        => user_data,
            user_valid       => user_valid,
            crc_empty        => crc_empty,
            crc_sop          => crc_sop,
            crc_eop          => crc_eop,
            crc_data         => crc_data,
            crc_valid        => crc_valid,
            tx_sop           => tx_sop,
            tx_eop           => tx_eop,
            tx_data          => tx_data,
            tx_valid         => tx_valid,
            tx_crc_location  => tx_crc_location,
            tx_shift         => tx_shift,
            av_st_ready      => xhdl2
         );
   END GENERATE;
   
   xhdl3 : IF (AVALON_ST_128 = ZERO_INTEGER) GENERATE
      
      
      xhdl4 <= NOT(tx_datapath_full);
      ecrc_gen_ctl_64 : altpcierd_cdma_ecrc_gen_ctl_64
         PORT MAP (
            clk              => clk,
            rstn             => rstn,
            user_rd_req      => user_rd_req_xhdl0,
            user_sop         => user_sop,
            user_eop         => user_eop,
            user_data        => user_data,
            user_valid       => user_valid,
            crc_empty        => crc_empty,
            crc_sop          => crc_sop,
            crc_eop          => crc_eop,
            crc_data         => crc_data,
            crc_valid        => crc_valid,
            tx_sop           => tx_sop,
            tx_eop           => tx_eop,
            tx_data          => tx_data,
            tx_valid         => tx_valid,
            tx_crc_location  => tx_crc_location,
            tx_shift         => tx_shift,
            av_st_ready      => xhdl4
         );
   END GENERATE;
   
   
   
   ecrc_gen_calc : altpcierd_cdma_ecrc_gen_calc
      GENERIC MAP (
         AVALON_ST_128  => AVALON_ST_128,
         XHDL_STR       => "XHDL_STR"
      )
      PORT MAP (
         clk        => clk,
         rstn       => rstn,
         crc_data   => crc_data,
         crc_valid  => crc_valid,
         crc_empty  => crc_empty,
         crc_eop    => crc_eop,
         crc_sop    => crc_sop,
         ecrc       => ecrc,
         crc_ack    => crc_ack
      );
   
   -- input to tx_datapath delay_stage
   tx_data_vec <= (tx_valid & tx_crc_location & tx_sop & tx_eop & tx_data);
   
   
   
   ecrc_gen_datapath : altpcierd_cdma_ecrc_gen_datapath
      PORT MAP (
         clk             => clk,
         rstn            => rstn,
         data_in         => tx_data_vec,
         data_valid      => tx_valid,
         rdreq           => tx_stream_ready0,
         data_out        => tx_data_vec_del,
         data_out_valid  => tx_data_vec_del_valid,
         full            => tx_datapath_full
      );
   
   -- output from tx_datapath delay_stage  
   
   tx_crc_location_output <= tx_data_vec_del(134 DOWNTO 131);
   tx_sop_output <= tx_data_vec_del(130);
   tx_data_output <= tx_data_vec_del(127 DOWNTO 0);
   crc_ack <= OR_BR(tx_data_vec_del(134 DOWNTO 131)) AND tx_data_vec_del_valid;     -- OPTIMIZE THIS LATER 
   
   ecrc_reversed <= (ecrc(0) & ecrc(1) & ecrc(2) & ecrc(3) & ecrc(4) & ecrc(5) & ecrc(6) & ecrc(7) & ecrc(8) & ecrc(9) & ecrc(10) & ecrc(11) & ecrc(12) & ecrc(13) & ecrc(14) & ecrc(15) & ecrc(16) & ecrc(17) & ecrc(18) & ecrc(19) & ecrc(20) & ecrc(21) & ecrc(22) & ecrc(23) & ecrc(24) & ecrc(25) & ecrc(26) & ecrc(27) & ecrc(28) & ecrc(29) & ecrc(30) & ecrc(31));
   
   
 
   xhdl5 <= ecrc_reversed WHEN (tx_crc_location_output(3) = '1') ELSE
                    tx_data_output(31 DOWNTO 0);
   xhdl6 <= ecrc_reversed WHEN (tx_crc_location_output(2) = '1') ELSE
                    tx_data_output(63 DOWNTO 32);
   xhdl7 <= ecrc_reversed WHEN (tx_crc_location_output(1) = '1') ELSE
                    tx_data_output(95 DOWNTO 64);
   xhdl8 <= ecrc_reversed WHEN (tx_crc_location_output(0) = '1') ELSE
                    tx_data_output(127 DOWNTO 96);
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         tx_stream_data0_0 <= "0000000000000000000000000000000000000000000000000000000000000000000000000000";
         tx_stream_data0_1 <= "0000000000000000000000000000000000000000000000000000000000000000000000000000";
         tx_stream_valid0 <= '0'; 
      ELSIF (clk'EVENT AND clk = '1') THEN 
         tx_stream_data0_0(75 DOWNTO 74) <= "00";
         tx_stream_data0_0(71 DOWNTO 64) <= "00000000";
         tx_stream_data0_1(75 DOWNTO 74) <= "00";
         tx_stream_data0_1(71 DOWNTO 64) <= "00000000";
         tx_stream_data0_1(31 DOWNTO 0) <= xhdl5;
         tx_stream_data0_1(63 DOWNTO 32) <= xhdl6;
         tx_stream_data0_0(31 DOWNTO 0) <= xhdl7;
         tx_stream_data0_0(63 DOWNTO 32) <= xhdl8;      -- eop occurs in this cycle
         tx_stream_data0_1(73) <= to_stdlogic((tx_crc_location_output(3 DOWNTO 0) /= "0000"));      -- sop
         tx_stream_data0_1(72) <= tx_sop_output;        -- sop
         tx_stream_data0_0(72) <= tx_sop_output;        -- lower half is empty when crc is in the first 2 locations
         --  end
         
         tx_stream_data0_0(73) <= to_stdlogic((tx_crc_location_output(1 DOWNTO 0) /= "00"));
         tx_stream_valid0 <= tx_data_vec_del_valid;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
