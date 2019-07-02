-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcie_phasefifo.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This module allows data to pass between two clock domains where the 
-- frequency is identical but with different phase offset
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity altpcie_phasefifo is
  generic (
    DATA_SIZE : integer := 20;
    DDR_MODE : integer := 0
    );
  port (

    npor   : in  std_logic;
    wclk   : in  std_logic;
    wdata  : in  std_logic_vector(DATA_SIZE-1 downto 0);
    rclk   : in  std_logic;
    rdata  : out std_logic_vector(DATA_SIZE-1 downto 0)
    );

end altpcie_phasefifo;

architecture rtl of altpcie_phasefifo is

  component altsyncram
    generic(
      intended_device_family : string;
      operation_mode         : string;
      width_a                : natural;
      widthad_a              : natural;
      numwords_a             : natural;
      width_b                : natural;
      widthad_b              : natural;
      numwords_b             : natural;
      lpm_type               : string;
      width_byteena_a        : natural;
      outdata_reg_b          : string;
      indata_aclr_a          : string;
      wrcontrol_aclr_a       : string;
      address_aclr_a         : string;
      address_reg_b          : string;
      address_aclr_b         : string;
      outdata_aclr_b         : string;
      ram_block_type         : string
      );
    port(
      wren_a         : in  std_logic;
      wren_b         : in  std_logic                                  := '0';
      rden_b         : in  std_logic                                  := '1';
      data_a         : in  std_logic_vector (DATA_SIZE-1 downto 0);
      data_b         : in  std_logic_vector ((DATA_SIZE / (DDR_MODE+1))-1 downto 0) := (others => '1');
      address_a      : in  std_logic_vector (3-DDR_MODE downto 0);
      address_b      : in  std_logic_vector (3 downto 0);
      clock0         : in  std_logic;
      clock1         : in  std_logic;
      clocken0       : in  std_logic                                  := '1';
      clocken1       : in  std_logic                                  := '1';
      aclr0          : in  std_logic                                  := '0';
      aclr1          : in  std_logic                                  := '0';
      addressstall_a : in  std_logic                                  := '0';
      addressstall_b : in  std_logic                                  := '0';
      byteena_a      : in  std_logic_vector (0 downto 0)              := (others => '1');
      byteena_b      : in  std_logic_vector (0 downto 0)              := (others => '1');
      q_a            : out std_logic_vector (DATA_SIZE-1 downto 0);  -- Port A output
      q_b            : out std_logic_vector (DATA_SIZE / (DDR_MODE+1)-1 downto 0)
      );
  end component;


  signal waddr               : std_logic_vector(3-DDR_MODE downto 0);
  signal raddr               : std_logic_vector(3 downto 0);
  signal strobe_r : std_logic;
  signal strobe_rr : std_logic;
  signal rerror : std_logic;        
        


begin

  altsyncram_component : altsyncram
    generic map(
      intended_device_family => "Stratix GX",
      operation_mode         => "DUAL_PORT",
      width_a                => DATA_SIZE,
      widthad_a              => 4-DDR_MODE,
      numwords_a             => 2**(4-DDR_MODE),
      width_b                => DATA_SIZE / (DDR_MODE + 1),
      widthad_b              => 4,
      numwords_b             => 16,
      lpm_type               => "altsyncram",
      width_byteena_a        => 1,
      outdata_reg_b          => "CLOCK1",
      indata_aclr_a          => "NONE",
      wrcontrol_aclr_a       => "NONE",
      address_aclr_a         => "NONE",
      address_reg_b          => "CLOCK1",
      address_aclr_b         => "NONE",
      outdata_aclr_b         => "NONE",
      ram_block_type         => "AUTO"
      )
    port map(
      wren_a         => '1',
      wren_b         => '0',
      rden_b         => '1',
      data_a         => wdata,
      data_b         => (others => '1'),
      address_a      => waddr,
      address_b      => raddr,
      clock0         => wclk,
      clock1         => rclk,
      clocken0       => '1',
      clocken1       => '1',
      aclr0          => '0',
      aclr1          => '0',
      addressstall_a => '0',
      addressstall_b => '0',
      byteena_a      => (others => '1'),
      byteena_b      => (others => '1'),
      q_a            => open,
      q_b            => rdata(DATA_SIZE / (DDR_MODE+1)-1 downto 0)
      );


  ------------------------------------------------------------
  -- Read and Write address pointer keeps incrementing
  -- When write pointer is at "8", bit 3 of the address bus is
  -- propogated to the read side like a strobe.
  -- On the rising edge of this strobe, it should line up with read
  -- address pointer = 0x5 if the two clocks are the exact frequency
  ------------------------------------------------------------

  -- Read clock domain
  process (npor, rclk)
  begin
    if npor = '0' then
      raddr     <= (others => '0');
      strobe_r  <= '0';
      strobe_rr <= '0';
      rerror <= '0';
    elsif rising_edge (rclk) then
    if DDR_MODE = 0 then
      strobe_r  <= waddr(3);
    else
      strobe_r  <= waddr(2);
    end if;

      strobe_rr <= strobe_r;
      raddr     <= raddr + '1';

      if strobe_r = '1' and strobe_rr = '0' and
        (unsigned(raddr) > x"9") then
        rerror <= '1';
      end if;

      assert rerror = '0' report "PhaseFIFO Frequency mismatch Error!" severity failure;
           
    end if;   
  end process;

  -- Write clock domain
  process (npor, wclk)
  begin
    if npor = '0' then
      if (DDR_MODE = 0) then
        waddr <= "0100";
      else
        waddr <= "010";
      end if;
    elsif rising_edge (wclk) then
        waddr <= waddr + 1;          
    end if;
  end process;
  
  
end rtl;
