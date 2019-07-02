LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
-- synthesis translate_off
-- synthesis translate_on
-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_cplerr_lmi.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module drives the cpl_err/err_desc signalling from the application
-- to the PCIe Hard IP via the LMI interface.
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
ENTITY altpcierd_cplerr_lmi IS

   PORT (
      -- TLP descriptor corresponding to cpl_err bits.  Written to AER header log when cpl_err[6] is asserted.
      -- cpl_err bits from application.  edge sensitive inputs.
      -- lmi read/write request acknowledge from core
      
      -- lmi write data to core
      -- lmi address to core
      -- lmi write request to core
      -- cpl_err signal to core
      -- lmi read request to core
      -- 1'b1 means this module is busy writing cpl_err/err_desc  to the core.  
      -- transitions on cpl_err while this signal is high are ignored.
      clk_in              : IN STD_LOGIC;
      rstn                : IN STD_LOGIC;
      err_desc            : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      cpl_err_in          : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
      lmi_ack             : IN STD_LOGIC;
      lmi_din             : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      lmi_addr            : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      lmi_wren            : OUT STD_LOGIC;
      cpl_err_out         : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      lmi_rden            : OUT STD_LOGIC;
      cplerr_lmi_busy     : OUT STD_LOGIC
   );
END ENTITY altpcierd_cplerr_lmi;
ARCHITECTURE altpcie OF altpcierd_cplerr_lmi IS


                                                
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
                                                                       
                                                                       
   

   -- CONSTANT IDLE_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(IDLE,3);
   -- CONSTANT WAIT_LMI_WR_AER81C_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(WAIT_LMI_WR_AER81C,3);
   -- CONSTANT DRIVE_CPL_ERR_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(DRIVE_CPL_ERR,3);
   -- CONSTANT WAIT_LMI_WR_AER820_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(WAIT_LMI_WR_AER820,3);
   -- CONSTANT WAIT_LMI_WR_AER824_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(WAIT_LMI_WR_AER824,3);
   -- CONSTANT WAIT_LMI_WR_AER828_3 : std_logic_vector(3-1 downto 0):=to_stdlogicvector(WAIT_LMI_WR_AER828,3);

      
      -- cplerr_lmi_sm State Machine 
      CONSTANT IDLE                : INTEGER := 0;
      CONSTANT WAIT_LMI_WR_AER81C  : INTEGER := 1;
      CONSTANT WAIT_LMI_WR_AER820  : INTEGER := 2;
      CONSTANT WAIT_LMI_WR_AER824  : INTEGER := 3;
      CONSTANT WAIT_LMI_WR_AER828  : INTEGER := 4;
      CONSTANT DRIVE_CPL_ERR       : INTEGER := 5;
      
      
   CONSTANT IDLE_3               : std_logic_vector(3-1 downto 0):= "000";
   CONSTANT WAIT_LMI_WR_AER81C_3 : std_logic_vector(3-1 downto 0):= "001"; 
   CONSTANT WAIT_LMI_WR_AER820_3 : std_logic_vector(3-1 downto 0):= "010";
   CONSTANT WAIT_LMI_WR_AER824_3 : std_logic_vector(3-1 downto 0):= "011";
   CONSTANT WAIT_LMI_WR_AER828_3 : std_logic_vector(3-1 downto 0):= "100";
   CONSTANT DRIVE_CPL_ERR_3      : std_logic_vector(3-1 downto 0):= "101";
   
   SIGNAL cplerr_lmi_sm     : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL cpl_err_reg       : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL err_desc_reg      : STD_LOGIC_VECTOR(127 DOWNTO 0);
   
   SIGNAL lmi_ack_reg       : STD_LOGIC;        -- boundary register
   
   -- not used
   
   SIGNAL cpl_err_in_assert : STD_LOGIC_VECTOR(6 DOWNTO 0);
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL lmi_din_xhdl1     : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL lmi_addr_xhdl0    : STD_LOGIC_VECTOR(11 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   lmi_din <= lmi_din_xhdl1;
   lmi_addr <= lmi_addr_xhdl0;
   lmi_rden <= '0';
   
   cpl_err_in_assert <= NOT(cpl_err_reg) AND cpl_err_in;
   
   PROCESS (clk_in, rstn)
   BEGIN
      IF (rstn = '0') THEN
         cplerr_lmi_sm <= IDLE_3 ;
         cpl_err_reg <= "0000000";
         lmi_din_xhdl1 <= "00000000000000000000000000000000";
         lmi_addr_xhdl0 <= "000000000000";
         lmi_wren <= '0';
         cpl_err_out <= "0000000";
         err_desc_reg <= "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
         cplerr_lmi_busy <= '0';
         lmi_ack_reg <= '0';
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         
         -- This State Machine controls LMI/cpl_err signalling to core.
         -- When cpl_err[6] asserts, the err_desc is written to the 
         -- core's configuration space AER register via the LMI.   
         -- And then cpl_err is driven to the core.    
         lmi_ack_reg <= lmi_ack;
         CASE cplerr_lmi_sm IS
            -- level sensitive
            -- log header via LMI
            -- in 1DW accesses
            -- cpl_err to core 
            -- without logging header
            WHEN IDLE_3  =>
               lmi_addr_xhdl0 <= "100000011100";
               lmi_din_xhdl1 <= err_desc(127 DOWNTO 96);
               cpl_err_reg <= cpl_err_in;
               err_desc_reg <= err_desc;
               cpl_err_out <= "0000000";
               IF (cpl_err_in_assert(6) = '1') THEN
                  cplerr_lmi_sm <= WAIT_LMI_WR_AER81C_3 ;
                  lmi_wren <= '1';
                  cplerr_lmi_busy <= '1';
               ELSIF (cpl_err_in_assert /= "0000000") THEN
                  cplerr_lmi_sm <= DRIVE_CPL_ERR_3 ;
                  lmi_wren <= '0';
                  cplerr_lmi_busy <= '1';
               ELSE
                  cplerr_lmi_sm <= cplerr_lmi_sm;
                  lmi_wren <= '0';
                  cplerr_lmi_busy <= '0';
               END IF;
            -- wait for core to accept last LMI write
            -- before writing 2nd DWord of err_desc
            WHEN WAIT_LMI_WR_AER81C_3  =>
               IF (lmi_ack_reg = '1') THEN
                  cplerr_lmi_sm <= WAIT_LMI_WR_AER820_3 ;
                  lmi_addr_xhdl0 <= "100000100000";
                  lmi_din_xhdl1 <= err_desc_reg(95 DOWNTO 64);
                  lmi_wren <= '1';
               ELSE
                  cplerr_lmi_sm <= cplerr_lmi_sm;
                  lmi_addr_xhdl0 <= lmi_addr_xhdl0;
                  lmi_din_xhdl1 <= lmi_din_xhdl1;
                  lmi_wren <= '0';
               END IF;
            -- wait for core to accept last LMI write
            -- before writing 3rd DWord of err_desc
            WHEN WAIT_LMI_WR_AER820_3  =>
               IF (lmi_ack_reg = '1') THEN
                  cplerr_lmi_sm <= WAIT_LMI_WR_AER824_3 ;
                  lmi_addr_xhdl0 <= "100000100100";
                  lmi_din_xhdl1 <= err_desc_reg(63 DOWNTO 32);
                  lmi_wren <= '1';
               ELSE
                  cplerr_lmi_sm <= cplerr_lmi_sm;
                  lmi_addr_xhdl0 <= lmi_addr_xhdl0;
                  lmi_din_xhdl1 <= lmi_din_xhdl1;
                  lmi_wren <= '0';
               END IF;
            -- wait for core to accept last LMI write
            -- before writing 4th DWord of err_desc
            WHEN WAIT_LMI_WR_AER824_3  =>
               IF (lmi_ack_reg = '1') THEN
                  cplerr_lmi_sm <= WAIT_LMI_WR_AER828_3 ;
                  lmi_addr_xhdl0 <= "100000101000";
                  lmi_din_xhdl1 <= err_desc_reg(31 DOWNTO 0);
                  lmi_wren <= '1';
               ELSE
                  cplerr_lmi_sm <= cplerr_lmi_sm;
                  lmi_addr_xhdl0 <= lmi_addr_xhdl0;
                  lmi_din_xhdl1 <= lmi_din_xhdl1;
                  lmi_wren <= '0';
               END IF;
            -- wait for core to accept last LMI write
            -- before driving cpl_err bits
            WHEN WAIT_LMI_WR_AER828_3  =>
               lmi_addr_xhdl0 <= lmi_addr_xhdl0;
               lmi_din_xhdl1 <= lmi_din_xhdl1;
               lmi_wren <= '0';
               IF (lmi_ack_reg = '1') THEN
                  cplerr_lmi_sm <= DRIVE_CPL_ERR_3 ;
               ELSE
                  cplerr_lmi_sm <= cplerr_lmi_sm;
               END IF;
            -- drive cpl_err bits to core
            WHEN DRIVE_CPL_ERR_3  =>
               cpl_err_out <= cpl_err_reg;
               cplerr_lmi_sm <= IDLE_3 ;
               cplerr_lmi_busy <= '0';
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS;
   
END ARCHITECTURE altpcie;
