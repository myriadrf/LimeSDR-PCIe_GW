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
-- Copyright (c) 2007 Altera Corporation. All rights reserved.  Altera products are
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
ENTITY altpcierd_cdma_ecrc_gen_calc IS
   GENERIC (
      XHDL_STR       : STRING := "XHDL_STR";
      AVALON_ST_128  : INTEGER := 0
      
   );
   PORT (
      clk            : IN STD_LOGIC;
      rstn           : IN STD_LOGIC;
      crc_data       : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      crc_valid      : IN STD_LOGIC;
      crc_empty      : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      crc_eop        : IN STD_LOGIC;
      crc_sop        : IN STD_LOGIC;
      ecrc           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      crc_ack        : IN STD_LOGIC
   );
END ENTITY altpcierd_cdma_ecrc_gen_calc;
ARCHITECTURE altpcie OF altpcierd_cdma_ecrc_gen_calc IS
   
   CONSTANT       ZERO_INTEGER   : INTEGER := 0;
   CONSTANT       ONE_INTEGER    : INTEGER := 1;


COMPONENT altpcierd_tx_ecrc_128 IS
PORT (
	clk	: IN STD_LOGIC;
	data	: IN STD_LOGIC_VECTOR (127 DOWNTO 0);
	datavalid	: IN STD_LOGIC;
	empty	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	endofpacket	: IN STD_LOGIC;
	reset_n	: IN STD_LOGIC;
	startofpacket	: IN STD_LOGIC;
	checksum	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	crcvalid	: OUT STD_LOGIC
);
END COMPONENT;

 COMPONENT altpcierd_tx_ecrc_64 IS
PORT (
	clk	: IN STD_LOGIC;
	data	: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
	datavalid	: IN STD_LOGIC;
	empty	: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	endofpacket	: IN STD_LOGIC;
	reset_n	: IN STD_LOGIC;
	startofpacket	: IN STD_LOGIC;
	checksum	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	crcvalid	: OUT STD_LOGIC
);
END COMPONENT;  

 COMPONENT altpcierd_tx_ecrc_fifo IS
PORT
(
	aclr		: IN STD_LOGIC ;
	clock		: IN STD_LOGIC ;
	data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	rdreq		: IN STD_LOGIC ;
	wrreq		: IN STD_LOGIC ;
	empty		: OUT STD_LOGIC ;
	full		: OUT STD_LOGIC ;
	q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
);
END COMPONENT;     

   SIGNAL crc_int       : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL crc_valid_int : STD_LOGIC;
   SIGNAL open_empty    : STD_LOGIC;
   SIGNAL open_full     : STD_LOGIC;
   -- X-HDL generated signals
   SIGNAL xhdl3 : STD_LOGIC;
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL ecrc_xhdl0    : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   ecrc <= ecrc_xhdl0;
   
   xhdl1 : IF (AVALON_ST_128 = ONE_INTEGER) GENERATE
      
      
      tx_ecrc_128 : altpcierd_tx_ecrc_128
         PORT MAP (
            clk            => clk,
            reset_n        => rstn,
            data           => crc_data,
            datavalid      => crc_valid,
            empty          => crc_empty,
            endofpacket    => crc_eop,
            startofpacket  => crc_sop,
            checksum       => crc_int,
            crcvalid       => crc_valid_int
         );
   END GENERATE;
   
   xhdl2 : IF (AVALON_ST_128 = ZERO_INTEGER) GENERATE
      
      
      tx_ecrc_64 : altpcierd_tx_ecrc_64
         PORT MAP (
            clk            => clk,
            reset_n        => rstn,
            data           => crc_data(127 DOWNTO 64),
            datavalid      => crc_valid,
            empty          => crc_empty(2 DOWNTO 0),
            endofpacket    => crc_eop,
            startofpacket  => crc_sop,
            checksum       => crc_int,
            crcvalid       => crc_valid_int
         );
   END GENERATE;
   
   
   
   xhdl3 <= NOT(rstn);
   tx_ecrc_fifo : altpcierd_tx_ecrc_fifo
      PORT MAP (
         aclr   => xhdl3,
         clock  => clk,
         data   => crc_int,
         rdreq  => crc_ack,
         wrreq  => crc_valid_int,
         empty  => open_empty,
         full   => open_full,
         q      => ecrc_xhdl0
      );
   
END ARCHITECTURE altpcie;
