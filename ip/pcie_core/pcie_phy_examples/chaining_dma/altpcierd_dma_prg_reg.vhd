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
-- Title         : DMA register setting (altpcierd_dma_prg_reg)
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_dma_prg_reg.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
--
-- DMA Write register DIRECTION = "write"
-- EP Addr           |                |                  
-- rx_desc_addr[4:0] |                |                
---------------------|----------------|----------------
-- 0h  0b00000       | DW0 (size)     | rx_data[31:0]
-- 04h 0b00100       | DW1 (BDT Msb)  | rx_data[63:32]
-- 08h 0b01000       | DW2 (BDT Lsb)  | rx_data[31:0]
-- 0ch 0b01100       | DW3 RCLast     | rx_data[63:32]
--
-- DMA Read register DIRECTION = "read"
-- EP Addr           |                |
-- rx_desc_addr[4:0] |                |
---------------------|----------------|----------------
-- 1h  0b10000       | DW0 (size)     | rx_data[31:0]
-- 14h 0b10100       | DW1 (BDT Msb)  | rx_data[63:32]
-- 18h 0b11000       | DW2 (BDT Lsb)  | rx_data[31:0]
-- 1ch 0b11100       | DW3 RCLast     | rx_data[63:32]
--
-- Key signals:
--       - init : reset all other DMA module
--               writing 0xFFFF in DW0 set init
--               writing valid DW3 clear init (e.g RCLast <size)
--       |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16|15 .................0
--   ----|---------------------------------------------------------------------
--       | R|        |         |              |  | E|M| D |                    
--   DW0 | E| MSI    |         |              |  | P|S| I |
--       | R|TRAFFIC |         |              |  | L|I| R |
--       | U|CLASS   | RESERVED|  MSI         |1 | A| | E |      SIZE:Number
--       | N|        |         |  NUMBER      |  | S| | C |   of DMA descriptor
--       | D|        |         |              |  | T| | T |
--       | M|        |         |              |  |  | | I |
--       | A|        |         |              |  |  | | O |
--       |  |        |         |              |  |  | | N | 
--   ----|---------------------------------------------------------------------
--   DW1 |                     BDT_MSB
--   ----|---------------------------------------------------------------------
--   DW2 |                   DT_LSB
--   ----|---------------------------------------------------------------------
--   DW3 |                                                | RC Last
--   ----|---------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////////////
--
-- NOTE:
--      1- This module always issues RX_ACK when RX TLP = Message Request 
--         (TYPE[4:3] == 2'b10)
-------------------------------------------------------------------------------
-- Copyright 2008 Altera Corporation. All rights reserved.  Altera products are
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
ENTITY altpcierd_dma_prg_reg IS
   GENERIC (
      RC_64BITS_ADDR           : INTEGER := 0;
      AVALON_ST_128            : INTEGER := 0 
      
      -- last value of the descriptor written by the rc 
      -- Toggling sync bit to indicate to re-run DMA 
      -- When 1 the DMA restart from the first descriptor
      -- When 0 the DMA stops 
      -- Descriptor table size (the number of descriptor) 
      -- Descriptor table base address in the RC site 
      -- Status bit to update the eplast ister in the rc memeory 
      -- Status bit to reflect use of MSI 
      -- Return 1 if dt_base_rc[63:32] == 0 
      -- MSI TC and MSI Number
      -- high when reset state or before any transaction 
       
   );
   PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      dma_prg_wrena            : IN STD_LOGIC;
      dma_prg_wrdata           : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_prg_addr             : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_prg_rddata           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dt_rc_last               : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      dt_rc_last_sync          : OUT STD_LOGIC;
      dt_size                  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      dt_base_rc               : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
      dt_eplast_ena            : OUT STD_LOGIC;
      dt_msi                   : OUT STD_LOGIC;
      dt_3dw_rcadd             : OUT STD_LOGIC;
      app_msi_num              : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      app_msi_tc               : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      init                     : OUT STD_LOGIC
   );
END altpcierd_dma_prg_reg;

ARCHITECTURE trans OF altpcierd_dma_prg_reg IS

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
 
   -- soft_dma_reset : DMA reset controlled by software
   SIGNAL soft_dma_reset         : STD_LOGIC;
   SIGNAL init_shift             : STD_LOGIC;
   SIGNAL prg_reg_DW0            : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL prg_reg_DW1            : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL prg_reg_DW2            : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL prg_reg_DW3            : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL prg_reg_DW1_is_zero    : STD_LOGIC;
   
   SIGNAL dma_prg_wrena_reg      : STD_LOGIC;
   SIGNAL dma_prg_wrdata_reg     : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dma_prg_addr_reg       : STD_LOGIC_VECTOR(3 DOWNTO 0);
   -- X-HDL generated signals

   SIGNAL xhdl0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL xhdl4 : STD_LOGIC;

   -- Register Address Decode   
   
   CONSTANT EP_ADDR_DW0 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
   CONSTANT EP_ADDR_DW1 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
   CONSTANT EP_ADDR_DW2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
   CONSTANT EP_ADDR_DW3 : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
BEGIN
   
   -- Generate DMA resets
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         soft_dma_reset <= '1';
         init_shift <= '1';
         init <= '1';
         dma_prg_wrena_reg <= '0';
         dma_prg_wrdata_reg <= "00000000000000000000000000000000";
         dma_prg_addr_reg <= "0000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         init <= init_shift;
         dma_prg_wrena_reg <= dma_prg_wrena;
         dma_prg_wrdata_reg <= dma_prg_wrdata;
         
         -- write 1's to Address 0 to clear all regs
         dma_prg_addr_reg <= dma_prg_addr;
         
         -- assert init on a reset
         -- deassert init when the last (3rd) Prg Reg is written 
         soft_dma_reset <= to_stdlogic((dma_prg_wrena_reg = '1') AND (dma_prg_addr_reg(3 DOWNTO 2) = EP_ADDR_DW0) AND (dma_prg_wrdata_reg(15 DOWNTO 0) = "1111111111111111"));
         IF (soft_dma_reset = '1') THEN
            init_shift <= '1';
         ELSIF ((dma_prg_wrena_reg = '1') AND (dma_prg_addr_reg(3 DOWNTO 2) = EP_ADDR_DW3)) THEN
            init_shift <= '0';
         END IF;
      END IF;
   END PROCESS;
   
   -- DMA Programming Register Write               
   -- Registers
   xhdl0 <= dma_prg_wrdata_reg WHEN ((dma_prg_wrena_reg = '1') AND (dma_prg_addr_reg(3 DOWNTO 2) = EP_ADDR_DW0)) ELSE     -- Header register DW0
                 prg_reg_DW0;
   xhdl1 <= dma_prg_wrdata_reg WHEN ((dma_prg_wrena_reg = '1') AND (dma_prg_addr_reg(3 DOWNTO 2) = EP_ADDR_DW1)) ELSE     -- Header register DW1
                 prg_reg_DW1;
   xhdl2 <= dma_prg_wrdata_reg WHEN ((dma_prg_wrena_reg = '1') AND (dma_prg_addr_reg(3 DOWNTO 2) = EP_ADDR_DW2)) ELSE     -- Header register DW2
                 prg_reg_DW2;
   xhdl3 <= dma_prg_wrdata_reg WHEN ((dma_prg_wrena_reg = '1') AND (dma_prg_addr_reg(3 DOWNTO 2) = EP_ADDR_DW3)) ELSE     -- Header register DW3
                 prg_reg_DW3;
   
   -- outputs 
   xhdl4 <= '1' WHEN (prg_reg_DW1 = "00000000000000000000000000000000") ELSE
                 '0';
   PROCESS (clk_in)
   BEGIN
      IF (clk_in'EVENT AND clk_in = '1') THEN
         IF (soft_dma_reset = '1') THEN
            prg_reg_DW0 <= "00000000000000000000000000000000";
            prg_reg_DW1 <= "00000000000000000000000000000000";
            prg_reg_DW2 <= "00000000000000000000000000000000";
            prg_reg_DW3 <= "00000000000000000000000000000000";
            prg_reg_DW1_is_zero <= '1';
            dt_size <= "0000000000000000";
            dt_msi <= '0';
            dt_eplast_ena <= '0';
            app_msi_num <= "00000";
            app_msi_tc <= "000";
            dt_rc_last_sync <= '0';
            dt_base_rc <= "0000000000000000000000000000000000000000000000000000000000000000";
            dt_3dw_rcadd <= '0';
            dt_rc_last(15 DOWNTO 0) <= "0000000000000000";
            dma_prg_rddata <= "00000000000000000000000000000000";
         ELSE
            prg_reg_DW0 <= xhdl0;
            prg_reg_DW1 <= xhdl1;
            prg_reg_DW2 <= xhdl2;
            prg_reg_DW3 <= xhdl3;
            CASE dma_prg_addr_reg(3 DOWNTO 2) IS
               WHEN EP_ADDR_DW0 =>
                  dma_prg_rddata <= prg_reg_DW0;
               WHEN EP_ADDR_DW1 =>
                  dma_prg_rddata <= prg_reg_DW1;
               WHEN EP_ADDR_DW2 =>
                  dma_prg_rddata <= prg_reg_DW2;
               WHEN EP_ADDR_DW3 =>
                  dma_prg_rddata <= prg_reg_DW3;
               WHEN OTHERS =>
                  dma_prg_rddata <= "00000000000000000000000000000000";
            END CASE;
            dt_size <= prg_reg_DW0(15 DOWNTO 0) - "0000000000000001";
            dt_msi <= prg_reg_DW0(17);
            dt_eplast_ena <= prg_reg_DW0(18);
            app_msi_num <= prg_reg_DW0(24 DOWNTO 20);
            app_msi_tc <= prg_reg_DW0(30 DOWNTO 28);
            dt_rc_last_sync <= prg_reg_DW0(31);
            dt_base_rc(63 DOWNTO 32) <= prg_reg_DW1;
            dt_3dw_rcadd <= xhdl4;
            dt_base_rc(31 DOWNTO 0) <= prg_reg_DW2;
            dt_rc_last(15 DOWNTO 0) <= prg_reg_DW3(15 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;
   
END trans;



