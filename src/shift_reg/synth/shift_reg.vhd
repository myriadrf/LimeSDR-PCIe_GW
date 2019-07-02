-- ----------------------------------------------------------------------------
-- FILE:          shift_reg.vhd
-- DESCRIPTION:   Shift register with enable
-- DATE:          01:43 PM Wednesday, June 19, 2019
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
entity shift_reg is
   generic(
      g_IN_WIDTH   : integer := 512;
      g_OUT_WIDTH  : integer := 32
   );
   port (
      clk      : in  std_logic;
      reset_n  : in  std_logic;
      ld       : in  std_logic;     -- Load, only rising edge is detected
      d        : in  std_logic_vector(g_IN_WIDTH-1 downto 0); -- Input data
      ready    : in  std_logic;     -- Ready to accept data
      valid    : out std_logic;     -- Output word valid
      q        : out std_logic_vector(g_OUT_WIDTH-1 downto 0) -- Output word
   );
end shift_reg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of shift_reg is
--declare signals,  components here
constant c_N_TAPS : integer := g_IN_WIDTH / g_OUT_WIDTH;

signal ld_reg        : std_logic;
signal shift_reg     : std_logic_vector(g_IN_WIDTH-1 downto 0);
signal shift_cnt     : unsigned(7 downto 0);

  
begin
 
-- ----------------------------------------------------------------------------
-- Input register
-- ----------------------------------------------------------------------------
   in_reg : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         ld_reg <= '0';
      elsif (clk'event AND clk='1') then 
         ld_reg <= ld;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Shift counter 
-- ----------------------------------------------------------------------------
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         shift_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if ld='1' AND ld_reg = '0' AND shift_cnt = 0  then  
            shift_cnt <= to_unsigned(g_IN_WIDTH/g_OUT_WIDTH, 8);
         else
            if shift_cnt > 0 AND ready = '1' then 
               shift_cnt <= shift_cnt - 1;
            else 
               shift_cnt <= shift_cnt;
            end if;
         end if;
      end if;
   end process;

-- ----------------------------------------------------------------------------
-- Shift register
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         shift_reg <= (others=>'0');  
      elsif (clk'event and clk = '1') then
         if ld='1' AND ld_reg = '0' AND shift_cnt = 0 then -- reg is loaded on rising edge 
            shift_reg <= d;
         else 
            if ready = '1' then 
               shift_reg <= shift_reg(g_IN_WIDTH-g_OUT_WIDTH-1 downto g_IN_WIDTH-g_OUT_WIDTH*c_N_TAPS) & std_logic_vector(to_unsigned(0,g_OUT_WIDTH));
            end if; 
         end if;
      end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   valid <= '1' when shift_cnt > 0 AND ready = '1' else '0';  
   q     <= shift_reg(g_IN_WIDTH-1 downto g_IN_WIDTH-g_OUT_WIDTH);
  
end arch;   


