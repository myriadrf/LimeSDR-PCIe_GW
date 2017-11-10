-- ----------------------------------------------------------------------------	
-- FILE: 	rxiq_check.vhd
-- DESCRIPTION:	rxiq_data checking module
-- DATE:	Jan 27, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rxiq_check is
   generic(
      diq_width   : integer := 12
   );
   port (
      clk                     : in std_logic;
      reset_n                 : in std_logic;
		fidm					      : in std_logic; -- frame start ID
      data_in_h               : in std_logic_vector(diq_width downto 0);
      data_in_l               : in std_logic_vector(diq_width downto 0);
      fidm_error              : out std_logic;
      ch_AI_ptrn              : in std_logic_vector(diq_width-1 downto 0);
      ch_AI_error             : out std_logic;
      ch_AQ_ptrn       	      : in std_logic_vector(diq_width-1 downto 0);
      ch_AQ_error             : out std_logic;
		ch_BI_ptrn              : in std_logic_vector(diq_width-1 downto 0);
      ch_BI_error             : out std_logic;
      ch_BQ_ptrn              : in std_logic_vector(diq_width-1 downto 0);
		ch_BQ_error             : out std_logic;
      ch_A_error              : out std_logic;
      ch_A_AND_IQSEL_error    : out std_logic;
      ch_B_error              : out std_logic;
      ch_B_AND_IQSEL_error    : out std_logic;
      ch_AB_error             : out std_logic;
      ch_AB_AND_IQSEL_error   : out std_logic
      
        );

end rxiq_check;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of rxiq_check is
--declare signals,  components here

signal ch_AI_ptrn_sync 	            : std_logic_vector(diq_width-1 downto 0);
signal ch_AQ_ptrn_sync 	            : std_logic_vector(diq_width-1 downto 0);
signal ch_BI_ptrn_sync 	            : std_logic_vector(diq_width-1 downto 0);
signal ch_BQ_ptrn_sync 	            : std_logic_vector(diq_width-1 downto 0);
            
signal fidm_sync			            : std_logic;
            
signal iqsel_reg			            : std_logic;
signal data_in_h_reg		            : std_logic_vector(diq_width downto 0);
signal data_in_l_reg		            : std_logic_vector(diq_width downto 0);
            
signal ch_AI_error_int              : std_logic;
signal ch_AQ_error_int              : std_logic;
signal ch_BI_error_int              : std_logic;
signal ch_BQ_error_int              : std_logic;

signal fidm_error_int               : std_logic;
signal ch_A_error_int               : std_logic;
signal ch_A_AND_IQSEL_error_int     : std_logic;
signal ch_B_error_int               : std_logic;
signal ch_B_AND_IQSEL_error_int     : std_logic;
signal ch_AB_error_int              : std_logic;
signal ch_AB_AND_IQSEL_error_int    : std_logic;


--inst0 
signal inst0_ch_A_valid	: std_logic;
signal inst0_ch_AI		: std_logic_vector(diq_width-1 downto 0);
signal inst0_ch_AQ		: std_logic_vector(diq_width-1 downto 0);
signal inst0_ch_B_valid	: std_logic;
signal inst0_ch_BI		: std_logic_vector(diq_width-1 downto 0);
signal inst0_ch_BQ	   : std_logic_vector(diq_width-1 downto 0);

begin


 bus_sync_reg0 : entity work.bus_sync_reg
 generic map (12) 
 port map(clk, '1', ch_AI_ptrn, ch_AI_ptrn_sync);
 
  bus_sync_reg1 : entity work.bus_sync_reg
 generic map (12) 
 port map(clk, '1', ch_AQ_ptrn, ch_AQ_ptrn_sync);
 
  bus_sync_reg2 : entity work.bus_sync_reg
 generic map (12) 
 port map(clk, '1', ch_BI_ptrn, ch_BI_ptrn_sync);
 
  bus_sync_reg3 : entity work.bus_sync_reg
 generic map (12) 
 port map(clk, '1', ch_BQ_ptrn, ch_BQ_ptrn_sync);
 
 
 sync_reg0 : entity work.sync_reg 
 port map(clk, '1', fidm, fidm_sync);

-- ----------------------------------------------------------------------------
-- input registers
-- ----------------------------------------------------------------------------
process(clk, reset_n) 
begin 
	if reset_n = '0' then
		data_in_h_reg <= (others=>'0');
		data_in_l_reg <= (others=>'0');
      iqsel_reg<='0';
	elsif (clk'event AND clk='1') then
      iqsel_reg      <= data_in_h(diq_width) AND data_in_l(diq_width);
		data_in_h_reg  <= data_in_h(diq_width downto 0);
		data_in_l_reg  <= data_in_l(diq_width downto 0);
	end if;
end process;


-- ----------------------------------------------------------------------------
-- deinterleaved data
-- ----------------------------------------------------------------------------
deinterleave_ch_inst0 : entity work.deinterleave_ch
   generic map(
      diq_width   => diq_width
   )
   port map(
      clk               => clk,
      reset_n           => reset_n,
		fidm					=> fidm_sync,
      iqsel   				=> iqsel_reg,
      data_in_h         => data_in_h_reg(diq_width-1 downto 0),
      data_in_l         => data_in_l_reg(diq_width-1 downto 0),
		ch_A_valid			=> inst0_ch_A_valid,
      ch_AI        		=> inst0_ch_AI,
      ch_AQ       		=> inst0_ch_AQ,
		ch_B_valid			=> inst0_ch_B_valid,
		ch_BI        		=> inst0_ch_BI,
      ch_BQ        		=> inst0_ch_BQ     
        );

-- ----------------------------------------------------------------------------
-- IQSEL check
-- ----------------------------------------------------------------------------
process(clk, reset_n) 
begin 
	if reset_n = '0' then
      fidm_error_int <= '0';
	elsif (clk'event AND clk='1') then
      if (data_in_h(diq_width) = data_in_l(diq_width)) AND (data_in_h_reg(diq_width) = data_in_l_reg(diq_width)) then
         if (data_in_h(diq_width) /= data_in_h_reg(diq_width)) AND (data_in_l(diq_width) /= data_in_l_reg(diq_width)) then 
            fidm_error_int <= '0';
         else 
            fidm_error_int <= '1';
         end if;
      else 
         fidm_error_int <= '1';
      end if;
	end if;
end process;

fidm_error <= fidm_error_int;

-- ----------------------------------------------------------------------------
-- AI check
-- ----------------------------------------------------------------------------
process(clk, reset_n) 
begin 
	if reset_n = '0' then
      ch_AI_error_int <= '0';
	elsif (clk'event AND clk='1') then
      if (inst0_ch_A_valid='1') then
         if inst0_ch_AI = ch_AI_ptrn_sync then 
            ch_AI_error_int <= '0';
         else 
            ch_AI_error_int <= '1';
         end if;
      else 
         ch_AI_error_int <= ch_AI_error_int;
      end if;
	end if;
end process;

ch_AI_error <= ch_AI_error_int;

-- ----------------------------------------------------------------------------
-- AQ check
-- ----------------------------------------------------------------------------
process(clk, reset_n) 
begin 
	if reset_n = '0' then
      ch_AQ_error_int <= '0';
	elsif (clk'event AND clk='1') then
      if (inst0_ch_A_valid='1') then
         if inst0_ch_AQ = ch_AQ_ptrn_sync then 
            ch_AQ_error_int <= '0';
         else 
            ch_AQ_error_int <= '1';
         end if;
      else 
         ch_AQ_error_int <= ch_AQ_error_int;
      end if;
	end if;
end process;

ch_AQ_error <= ch_AQ_error_int;


-- ----------------------------------------------------------------------------
-- BI check
-- ----------------------------------------------------------------------------
process(clk, reset_n) 
begin 
	if reset_n = '0' then
      ch_BI_error_int <= '0';
	elsif (clk'event AND clk='1') then
      if (inst0_ch_B_valid='1') then
         if inst0_ch_BI = ch_BI_ptrn_sync then 
            ch_BI_error_int <= '0';
         else 
            ch_BI_error_int <= '1';
         end if;
      else 
         ch_BI_error_int <= ch_BI_error_int;
      end if;
	end if;
end process;

ch_BI_error <= ch_BI_error_int;

-- ----------------------------------------------------------------------------
-- BQ check
-- ----------------------------------------------------------------------------
process(clk, reset_n) 
begin 
	if reset_n = '0' then
      ch_BQ_error_int <= '0';
	elsif (clk'event AND clk='1') then
      if (inst0_ch_B_valid='1') then
         if inst0_ch_BQ = ch_BQ_ptrn_sync then 
            ch_BQ_error_int <= '0';
         else 
            ch_BQ_error_int <= '1';
         end if;
      else 
         ch_BQ_error_int <= ch_BQ_error_int;
      end if;
	end if;
end process;

ch_BQ_error <= ch_BQ_error_int;


process(clk, reset_n) 
begin 
	if reset_n = '0' then
      ch_A_error_int       <= '0';
      ch_B_error_int       <= '0';
      ch_AB_error_int      <= '0';
      ch_A_AND_IQSEL_error <= '0';
      ch_B_AND_IQSEL_error <= '0';
      ch_AB_AND_IQSEL_error <= '0';
	elsif (clk'event AND clk='1') then

      --CH A data error
      if (ch_AI_error_int='1' OR ch_AQ_error_int='1') then
         ch_A_error_int <= '1';
      else 
         ch_A_error_int <= '0';
      end if;

      --CH B data error
      if (ch_BI_error_int='1' OR ch_BQ_error_int='1') then
         ch_B_error_int <= '1';
      else 
         ch_B_error_int <= '0';
      end if;

      --CH AB data error
      if (ch_A_error_int='1' OR ch_B_error_int='1') then
         ch_AB_error_int <= '1';
      else 
         ch_AB_error_int <= '0';
      end if;


       --CH A data+iqsel error
      if (ch_A_error_int='1' OR fidm_error_int='1') then
         ch_A_AND_IQSEL_error <= '1';
      else 
         ch_A_AND_IQSEL_error <= '0';
      end if;

      --CH B data+iqsel error
      if (ch_B_error_int='1' OR fidm_error_int='1') then
         ch_B_AND_IQSEL_error <= '1';
      else 
         ch_B_AND_IQSEL_error <= '0';
      end if;

      --CH AB data+iqsel error
      if (ch_AB_error_int='1' OR fidm_error_int='1') then
         ch_AB_AND_IQSEL_error <= '1';
      else 
         ch_AB_AND_IQSEL_error <= '0';
      end if;

	end if;
end process;

ch_A_error <= ch_A_error_int;             

ch_B_error <= ch_B_error_int;          

ch_AB_error <= ch_AB_error_int;           
 
end arch;