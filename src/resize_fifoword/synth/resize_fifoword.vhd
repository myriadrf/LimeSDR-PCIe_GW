-- ----------------------------------------------------------------------------
-- FILE:          resize_fifoword.vhd
-- DESCRIPTION:   Reads data word from FIFO and forms biger word
-- DATE:          10:32 AM Thursday, June 20, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity resize_fifoword is
   generic(
      g_IN_WORD_WIDTH   : integer := 32;
      g_OUT_WORD_WIDTH  : integer := 512
   );
   port (
      clk         : in  std_logic;
      reset_n     : in  std_logic;
      in_rdempty  : in  std_logic;
      in_rdreq    : out std_logic;
      in_data     : in  std_logic_vector(g_IN_WORD_WIDTH-1 downto 0);
      out_wrfull  : in  std_logic;
      out_wrreq   : out std_logic;
      out_data    : out std_logic_vector(g_OUT_WORD_WIDTH-1 downto 0)
   );
end resize_fifoword;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of resize_fifoword is
--declare signals,  components here
constant c_RD_MAX    : integer := g_OUT_WORD_WIDTH/g_IN_WORD_WIDTH;

signal rd_req        : std_logic;
signal valid         : std_logic;
signal rd_cnt        : unsigned(7 downto 0);
signal valid_cnt     : unsigned(7 downto 0);

signal shift_reg     : std_logic_vector(g_OUT_WORD_WIDTH-1 downto 0);

  
begin
 
-- ----------------------------------------------------------------------------
-- FIFO read request logic
-- ----------------------------------------------------------------------------
   rd_req <= '1' when in_rdempty = '0' AND out_wrfull = '0' else '0';

   process(reset_n, clk)
   begin
      if reset_n='0' then
         rd_cnt <= (others=>'0');
      elsif (clk'event and clk = '1') then
         if rd_req = '1' then 
            if rd_cnt < c_RD_MAX-1 then 
               rd_cnt <= rd_cnt + 1;
            else 
               rd_cnt <= (others=>'0');
            end if;
         else 
            rd_cnt <= rd_cnt;
         end if;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Shift register and control logic
-- ----------------------------------------------------------------------------    
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         valid <= '0';
      elsif (clk'event AND clk='1') then 
         valid <= rd_req;
      end if;
   end process;
   
   shift_reg_proc : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         shift_reg <= (others=> '0');
         valid_cnt <= (others=> '0');
      elsif (clk'event AND clk='1') then
         
         if valid = '1' then 
            shift_reg <= shift_reg(g_OUT_WORD_WIDTH-g_IN_WORD_WIDTH-1 downto 0) & in_data;
         end if;
         
         if valid = '1' then
            if valid_cnt < c_RD_MAX - 1 then 
               valid_cnt <= valid_cnt + 1;
            else 
               valid_cnt <= (others=>'0');
            end if;
         else 
            valid_cnt <= valid_cnt;
         end if;
      end if;
   end process;
    
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   out_reg : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         out_wrreq <= '0';
      elsif (clk'event AND clk='1') then 
         if valid_cnt = c_RD_MAX - 1 AND valid = '1' then 
            out_wrreq <= '1';
         else 
            out_wrreq <= '0';
         end if;
      end if;
   end process;
   
   in_rdreq <= rd_req;
   out_data <= shift_reg;
  
end arch;   


