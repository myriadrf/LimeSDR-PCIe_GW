-- ----------------------------------------------------------------------------	
-- FILE: 	onboard_led.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity onboard_led is
  port (
        --input ports 
        LED1_in   : in std_logic;
        LED2_in   : in std_logic;
		  LED3_in   : in std_logic;
        LED4_in   : in std_logic;
		  LED1_ctrl : in std_logic_vector(2 downto 0);
        LED2_ctrl : in std_logic_vector(2 downto 0);
		  LED3_ctrl : in std_logic_vector(2 downto 0);
        LED4_ctrl : in std_logic_vector(2 downto 0);
		  LED1_out  : out std_logic;
        LED2_out  : out std_logic;
		  LED3_out  : out std_logic;
        LED4_out  : out std_logic
       
        );
end onboard_led;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of onboard_led is
--declare signals,  components here


  
begin

LED1_out <= LED1_in when LED1_ctrl(0)='0' else LED1_ctrl(2);
LED2_out <= LED2_in when LED2_ctrl(0)='0' else LED2_ctrl(2);
LED3_out <= LED3_in when LED3_ctrl(0)='0' else LED3_ctrl(2);
LED4_out <= LED4_in when LED4_ctrl(0)='0' else LED4_ctrl(2);
  
end arch;





