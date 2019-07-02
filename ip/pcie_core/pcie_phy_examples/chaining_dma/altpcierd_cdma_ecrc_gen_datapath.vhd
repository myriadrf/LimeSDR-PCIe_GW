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
ENTITY altpcierd_cdma_ecrc_gen_datapath IS
   PORT (
      
      clk             : IN STD_LOGIC;
      rstn            : IN STD_LOGIC;
      data_in         : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      data_valid      : IN STD_LOGIC;
      rdreq           : IN STD_LOGIC;
      
      data_out        : OUT STD_LOGIC_VECTOR(135 DOWNTO 0);
      data_out_valid  : OUT STD_LOGIC;
      full            : OUT STD_LOGIC
   );
END ENTITY altpcierd_cdma_ecrc_gen_datapath;
ARCHITECTURE altpcie OF altpcierd_cdma_ecrc_gen_datapath IS

   COMPONENT altpcierd_tx_ecrc_data_fifo IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (135 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (135 DOWNTO 0)
	);
   END COMPONENT;
   
    COMPONENT altpcierd_tx_ecrc_ctl_fifo IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		almost_full		: OUT STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
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
                                                
   

   SIGNAL empty                      : STD_LOGIC;
   SIGNAL ctl_shift_reg              : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL rdreq_int                  : STD_LOGIC;
   SIGNAL open_data_fifo_empty       : STD_LOGIC;
   SIGNAL open_data_fifo_almost_full : STD_LOGIC;
   SIGNAL open_data_fifo_full        : STD_LOGIC;
   SIGNAL open_ctl_fifo_full         : STD_LOGIC;
   SIGNAL open_ctl_fifo_data         : STD_LOGIC_VECTOR(0 DOWNTO 0);
   SIGNAL data_bit                   : STD_LOGIC_VECTOR(0 DOWNTO 0);
   -- X-HDL generated signals
   SIGNAL xhdl2 : STD_LOGIC;
   SIGNAL xhdl3 : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL data_out_xhdl0             : STD_LOGIC_VECTOR(135 DOWNTO 0);
   SIGNAL full_xhdl1                 : STD_LOGIC;
BEGIN
   -- Drive referenced outputs
   data_out <= data_out_xhdl0;
   full <= full_xhdl1;
   data_bit <= "1";
   
   -- lookahead   
   
   
   xhdl2 <= NOT(rstn);
   tx_ecrc_data_fifo : altpcierd_tx_ecrc_data_fifo
      PORT MAP (
         aclr         => xhdl2,
         clock        => clk,
         data         => data_in,
         rdreq        => rdreq_int,
         wrreq        => data_valid,
         almost_full  => open_data_fifo_almost_full,
         empty        => open_data_fifo_empty,
         full         => open_data_fifo_full,
         q            => data_out_xhdl0
      );
   
   -- push data_valid thru a shift register to
   -- wait a minimum time before allowing data fifo
   -- to be popped.  when shifted data_valid is put
   -- into the control fifo, it is okay to pop data
   -- fifo whenever avalon ST is ready
   
   PROCESS (clk, rstn)
   BEGIN
      IF (rstn = '0') THEN
         ctl_shift_reg <= "0000000";
      ELSIF (clk'EVENT AND clk = '1') THEN
         ctl_shift_reg <= (data_valid & ctl_shift_reg(6 DOWNTO 1));		-- always shifting.  no throttling because crc module is not throttled.
      END IF;
   END PROCESS;
   
   rdreq_int <= to_stdlogic((rdreq = '1') AND (empty = '0'));
   data_out_valid <= to_stdlogic((rdreq = '1') AND (empty = '0'));
   
   -- this fifo only serves as an up/down counter for number of
   -- tx_data_fifo entries which have met the minimum
   -- required delay time before being popped
   -- lookahead
   
   
   xhdl3 <= NOT(rstn);
   tx_ecrc_ctl_fifo : altpcierd_tx_ecrc_ctl_fifo
      PORT MAP (
         aclr         => xhdl3,
         clock        => clk,
         data         => data_bit,		-- data does not matter
         rdreq        => rdreq_int,
         wrreq        => ctl_shift_reg(0),
         almost_full  => full_xhdl1,
         empty        => empty,
         full         => open_ctl_fifo_full,
         q            => open_ctl_fifo_data
      );
   
END ARCHITECTURE altpcie;
