
-- ----------------------------------------------------------------------------	
-- FILE: 	test_data.vhd
-- DESCRIPTION:	generates test data in mimo and siso modes
-- DATE:	Oct 23, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity test_data is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
        mimo_en   : in std_logic;
        --output ports 
        diq_h     : out std_logic_vector(12 downto 0);
        diq_l     : out std_logic_vector(12 downto 0)


        
        );
end test_data;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of test_data is
--declare signals,  components here
	signal iq_reg_l, iq_next_l: std_logic_vector(11 downto 0);
	signal iq_reg_h, iq_next_h: std_logic_vector(11 downto 0);
	signal iq_sel_reg, iq_sel_next: std_logic;
	signal mimo_en_reg0, mimo_en_reg1 : std_logic;
	signal cnt	: unsigned(10 downto 0);
	
	signal i_smpl    : unsigned(11 downto 0);
	signal q_smpl    : unsigned(11 downto 0);
	signal iq_select : std_logic;
	
	
		type cmds is (Idle, PhaseA0, PhaseB0, PhaseA1, PhaseB1,
	                    PhaseA2, PhaseB2, PhaseA3, PhaseB3);
	signal state, next_state : cmds;

  
begin


--=============================================
-- Next state
--=============================================
	NextStateReg01: process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			state <= PhaseA3;
			iq_reg_l <= "000000000000"; --(others => '0');
			iq_reg_h <= "000000000000";
			iq_sel_reg <= '1';
			mimo_en_reg0<='1';
			mimo_en_reg1<='1';
			cnt<=(others=>'0');
			i_smpl<=(others=>'0');
			q_smpl<=(0=>'1', others=>'0');
			iq_select<='0';
		elsif (clk'event and clk = '1') then
		    iq_select<=not iq_select;
		  	 i_smpl<=i_smpl+2;
			  q_smpl<=q_smpl+2;
				state <= next_state;
				iq_reg_l <= iq_next_l;
				iq_reg_h <= iq_next_h;
				iq_sel_reg <= iq_sel_next;
				mimo_en_reg0<=mimo_en;
				mimo_en_reg1<=mimo_en_reg0;
				cnt<=cnt+1;
		end if;
	end process NextStateReg01;
	
--=============================================
-- Next state logic
--=============================================
	nxt_state_decoder : process (state, mimo_en_reg1, cnt)
	begin

			iq_next_l <= "000000000000";
			iq_next_h <= "000000000000";
			iq_sel_next <= '1';
			
			case (state) is
			  
			  
			  when PhaseA0 =>
			    if mimo_en_reg1='1' then
--		       iq_next_l <= "011111111111"; --17FF AI0 MIMO
--		   	 iq_next_h <= "000000000000"; --1000 AQ0 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO
			    else 
			       iq_next_l <= "011111111111"; --17FF AI0 SISO
			   	   iq_next_h <= "011111111111"; --17FF AI0 SISO
			   	end if;
				  iq_sel_next <= '1';
				  next_state <= PhaseB0;

			  when PhaseB0 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "011111111111"; --07FF BI0 MIMO
--			   	 iq_next_h <= "000000000000"; --0000 BQ0 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO					
			    else 
			       iq_next_l <= "000000000001"; --0001 BQ0 SISO
			   	   iq_next_h <= "000000000001"; --0001 BQ0 SISO
			   	end if;
				  iq_sel_next <= '0';
				  next_state <= PhaseA1;
				  
				 when PhaseA1 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "000000000000"; --1000 AI1 MIMO
--			   	   iq_next_h <= "011111111111"; --17FF AQ1 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO
			    else 
			       iq_next_l <= "000000000010"; --1000 AI1 SISO
					 iq_next_h <= "000000000010"; --1000 AI1 SISO
			   	end if;
				  iq_sel_next <= '1';
				  next_state <= PhaseB1;
				  
			  when PhaseB1 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "000000000000"; --0000 BI1 MIMO
--			   	   iq_next_h <= "011111111111"; --07FF BQ1 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO
			    else 
			       iq_next_l <= "011111111111"; --07FF BQ0 SISO
			   	   iq_next_h <= "011111111111"; --07FF BQ0 SISO
			   	end if;
				  iq_sel_next <= '0';
				  next_state <= PhaseA2;
				  
				 when PhaseA2 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "100000000000"; --1800 AI2 MIMO
--			   	 iq_next_h <= "000000000000"; --1000 AQ2 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO						
			    else 
			       iq_next_l <= "100000000000"; --1800 AI2 SISO
			   	   iq_next_h <= "100000000000"; --1800 AI2 SISO
			   	end if;
				  iq_sel_next <= '1';
				  next_state <= PhaseB2;
				  
			  when PhaseB2 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "100000000000"; --0800 BI2 MIMO
--			   	   iq_next_h <= "000000000000"; --0000 BQ2 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO	
			    else 
			       iq_next_l <= "000000000000"; --0000 BQ0 SISO
			   	   iq_next_h <= "000000000000"; --0000 BQ0 SISO
			   	end if;
				  iq_sel_next <= '0';
				  next_state <= PhaseA3;
  
				 when PhaseA3 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "000000000000"; --1000 AI3 MIMO
--			   	   iq_next_h <= "100000000000"; --1800 AQ3 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO
			    else 
			       iq_next_l <= "000000000000"; --1000 AI3 SISO
			   	   iq_next_h <= "000000000000"; --1000 AI3 SISO
			   	end if;
				  iq_sel_next <= '1';
				  next_state <= PhaseB3;
				  
			  when PhaseB3 =>
			    if mimo_en_reg1='1' then
--			       iq_next_l <= "000000000000"; --0000 BI3 MIMO
--			   	  iq_next_h <= "100000000000"; --0800 BQ3 MIMO
					 iq_next_l <= '0' & std_logic_vector(cnt); --17FF AI0 MIMO
			   	 iq_next_h <= '0' & std_logic_vector(1+cnt); --1000 AQ0 MIMO
			    else 
			       iq_next_l <= "100000000000"; --0800 BQ3 SISO
			   	   iq_next_h <= "100000000000"; --0800 BQ3 SISO
			   	end if;
				  iq_sel_next <= '0';
				  next_state <= PhaseA0;				  
			
			--	
			when others =>
				next_state <= PhaseA3;

		end case;
	end process nxt_state_decoder;
	
	
	--diq_h <= iq_sel_reg & iq_reg_h;
	--diq_l <= iq_sel_reg & iq_reg_l;
	diq_h <= iq_select & std_logic_vector(q_smpl);
	diq_l <= iq_select & std_logic_vector(i_smpl);	
  
end arch;   




