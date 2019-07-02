LIBRARY ieee;
   USE ieee.std_logic_1164.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in  
--  * the chaining DMA design example. It contains the descriptor header 
--  * table registers which get programmed by the software application.
--  */
-- synthesis translate_off

-- synthesis translate_on
-- synthesis verilog_input_version verilog_2001 

-------------------------------------------------------------------------------
-- Title         : altpcierd_ctl_sts_regs
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_ctl_sts_regs.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
--
--  Description:  This module contains the Address decoding for BAR2/3 
--                address space. 
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

ENTITY altpcierd_reg_access IS

   PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      sel_ep_reg               : IN STD_LOGIC;
      reg_wr_ena               : IN STD_LOGIC;
      reg_rd_ena               : IN STD_LOGIC;
      reg_rd_addr              : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_wr_addr              : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_wr_data              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_rd_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_wr_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      rx_ecrc_bad_cnt          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      read_dma_status          : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      write_dma_status         : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      reg_rd_data              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      reg_rd_data_valid        : OUT STD_LOGIC;
      dma_prg_wrdata           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_prg_addr             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_rd_prg_wrena         : OUT STD_LOGIC;
      dma_wr_prg_wrena         : OUT STD_LOGIC
   );
END altpcierd_reg_access;

ARCHITECTURE trans OF altpcierd_reg_access IS
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

      -- Module Address Decode - 2 MSB's
      
   CONSTANT DMA_WRITE_PRG : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
   CONSTANT DMA_READ_PRG  : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
   CONSTANT MISC          : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
   CONSTANT ERR_STATUS    : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
      
      -- MISC address space
   CONSTANT WRITE_DMA_STATUS_REG_HI : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0000";
   CONSTANT WRITE_DMA_STATUS_REG_LO : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0100";
   CONSTANT READ_DMA_STATUS_REG_HI  : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "1000";
   CONSTANT READ_DMA_STATUS_REG_LO  : STD_LOGIC_VECTOR(3 DOWNTO 0)  := "1100";
   
   SIGNAL err_status_reg        : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL read_dma_status_reg   : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL write_dma_status_reg  : STD_LOGIC_VECTOR(63 DOWNTO 0);
   SIGNAL dma_rd_prg_rddata_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dma_wr_prg_rddata_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
   
   SIGNAL reg_wr_ena_reg        : STD_LOGIC;
   SIGNAL reg_rd_ena_reg        : STD_LOGIC;
   SIGNAL reg_rd_addr_reg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL reg_wr_addr_reg       : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL reg_wr_data_reg       : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL sel_ep_reg_reg        : STD_LOGIC;
   SIGNAL reg_rd_ena_reg2       : STD_LOGIC;
   SIGNAL reg_rd_ena_reg3       : STD_LOGIC;
   -- X-HDL generated signals

   SIGNAL xhdl0 : STD_LOGIC;
   SIGNAL xhdl1 : STD_LOGIC;
BEGIN
   
   -- Pipeline input data for performance 
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         err_status_reg <= "00000000000000000000000000000000";
         read_dma_status_reg <= "0000000000000000000000000000000000000000000000000000000000000000";
         write_dma_status_reg <= "0000000000000000000000000000000000000000000000000000000000000000";
         reg_wr_ena_reg <= '0';
         reg_rd_ena_reg <= '0';
         reg_rd_ena_reg2 <= '0';
         reg_rd_ena_reg3 <= '0';
         reg_rd_addr_reg <= "00000000";
         reg_wr_addr_reg <= "00000000";
         reg_wr_data_reg <= "00000000000000000000000000000000";
         sel_ep_reg_reg <= '0';
         dma_rd_prg_rddata_reg <= "00000000000000000000000000000000";
         dma_wr_prg_rddata_reg <= "00000000000000000000000000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         err_status_reg <= ("0000000000000000" & rx_ecrc_bad_cnt);
         read_dma_status_reg <= read_dma_status;
         write_dma_status_reg <= write_dma_status;
         reg_wr_ena_reg <= reg_wr_ena AND sel_ep_reg;
         reg_rd_ena_reg <= reg_rd_ena AND sel_ep_reg;
         reg_rd_ena_reg2 <= reg_rd_ena_reg;
         reg_rd_ena_reg3 <= reg_rd_ena_reg2;
         reg_rd_addr_reg <= reg_rd_addr;
         reg_wr_addr_reg <= reg_wr_addr;
         reg_wr_data_reg <= reg_wr_data;
         dma_rd_prg_rddata_reg <= dma_rd_prg_rddata;
         dma_wr_prg_rddata_reg <= dma_wr_prg_rddata;
      END IF;
   END PROCESS;
   
   -- Register Access
   --////////
   -- WRITE 
   
   xhdl0 <= '1' WHEN ((reg_wr_ena_reg = '1') AND (reg_wr_addr_reg(7 DOWNTO 4) = DMA_READ_PRG)) ELSE
                            '0';
   xhdl1 <= '1' WHEN ((reg_wr_ena_reg = '1') AND (reg_wr_addr_reg(7 DOWNTO 4) = DMA_WRITE_PRG)) ELSE
                            '0';
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         reg_rd_data <= "00000000000000000000000000000000";
         reg_rd_data_valid <= '0';
         dma_prg_wrdata <= "00000000000000000000000000000000";
         dma_prg_addr <= "0000";
         dma_rd_prg_wrena <= '0';
         dma_wr_prg_wrena <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         dma_prg_wrdata <= reg_wr_data_reg;
         dma_prg_addr <= reg_wr_addr_reg(3 DOWNTO 0);
         dma_rd_prg_wrena <= xhdl0;
         
         --////////
         -- READ 
         
         dma_wr_prg_wrena <= xhdl1;

    CASE reg_rd_addr_reg(7 DOWNTO 0) IS
            WHEN ("00100000") =>
               reg_rd_data <= write_dma_status_reg(63 DOWNTO 32);
            WHEN ("00100100") =>
               reg_rd_data <= write_dma_status_reg(31 DOWNTO 0);
            WHEN ("00101000") =>
               reg_rd_data <= read_dma_status_reg(63 DOWNTO 32);
            WHEN ("00101100") =>
               reg_rd_data <= read_dma_status_reg(31 DOWNTO 0);
            WHEN ("00110000") =>
               reg_rd_data <= err_status_reg;
            WHEN ("00000000") | ("00000100") | ("00001000") | 
                                     ("00001100") =>
               reg_rd_data <= dma_wr_prg_rddata_reg;
            WHEN ("00010000") | ("00010100") | ("00011000") | 
                                    ("00011100") =>
               reg_rd_data <= dma_rd_prg_rddata_reg;
            WHEN OTHERS =>
               reg_rd_data <= "00000000000000000000000000000000";

         END CASE;

         CASE reg_rd_addr_reg(7 DOWNTO 4) IS
            WHEN ("0000") =>
               reg_rd_data_valid <= reg_rd_ena_reg3;
            WHEN ("0001") =>
               reg_rd_data_valid <= reg_rd_ena_reg3;
            WHEN OTHERS =>
               reg_rd_data_valid <= reg_rd_ena_reg;
         END CASE;

               

    END IF;
   END PROCESS;
   
END trans;



