-------------------------------------------------------------------------------
-- Title         : PCI Express PIPE PHY connector
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_pipe_phy.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This function interconnects two PIPE MAC interfaces for a single lane.
-- For now this uses a common PCLK for both interfaces, an enhancement woudl be
-- to support separate PCLK's for each interface with the requisite elastic
-- buffer. 
-------------------------------------------------------------------------------
-- Copyright (c) 2005 Altera Corporation. All rights reserved.  Altera products are
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

entity altpcietb_pipe_phy is
  
  generic (
    APIPE_WIDTH     : natural := 16 ;
    BPIPE_WIDTH     : natural := 16 ;
    LANE_NUM        : natural := 0 ;
    A_MAC_NAME      : string  := "EP" ;
    B_MAC_NAME      : string  := "RP" ;
    LATENCY         : natural := 23
    );

  port (
    -- always make the datak to be 2 bit to work aroound europa optimization issue
    -- Common pclk and reset
    pclk_a        : in  std_logic;
    pclk_b        : in  std_logic;    
    resetn        : in  std_logic;
    pipe_mode     : in  std_logic;
    -- Indicate if lane connected 
    A_lane_conn   : in  std_logic;
    B_lane_conn   : in  std_logic;
    -- Gen 2 Rate
    A_rate   : in  std_logic;
    B_rate   : in  std_logic;    
    -- "A" side interface, connect A_ signals to the like named
    -- signals on the A MAC
    A_txdata      : in  std_logic_vector(APIPE_WIDTH-1 downto 0);
    A_txdatak     : in  std_logic_vector((APIPE_WIDTH/8)-1 downto 0);
    A_txdetectrx  : in  std_logic;
    A_txelecidle  : in  std_logic;
    A_txcompl     : in  std_logic;
    A_rxpolarity  : in  std_logic;
    A_powerdown   : in  std_logic_vector(1 downto 0);
    A_rxdata      : out std_logic_vector(APIPE_WIDTH-1 downto 0);
    A_rxdatak     : out std_logic_vector((APIPE_WIDTH/8)-1 downto 0);
    A_rxvalid     : out std_logic;
    A_phystatus   : out std_logic;
    A_rxelecidle  : out std_logic;
    A_rxstatus    : out std_logic_vector(2 downto 0);
    -- "B" side interface, connect B_ signals to the like named
    -- signals on the B MAC
    B_txdata      : in  std_logic_vector(BPIPE_WIDTH-1 downto 0);
    B_txdatak     : in  std_logic_vector((BPIPE_WIDTH/8)-1 downto 0);
    B_txdetectrx  : in  std_logic;
    B_txelecidle  : in  std_logic;
    B_txcompl     : in  std_logic;
    B_rxpolarity  : in  std_logic;
    B_powerdown   : in  std_logic_vector(1 downto 0);
    B_rxdata      : out std_logic_vector(BPIPE_WIDTH-1 downto 0);
    B_rxdatak     : out std_logic_vector((BPIPE_WIDTH/8)-1 downto 0);
    B_rxvalid     : out std_logic;
    B_phystatus   : out std_logic;
    B_rxelecidle  : out std_logic;
    B_rxstatus    : out std_logic_vector(2 downto 0)
    );

end altpcietb_pipe_phy;

architecture structural of altpcietb_pipe_phy is

  component altpcietb_pipe_xtx2yrx 

    generic (
      XPIPE_WIDTH : natural := 16 ;
      YPIPE_WIDTH : natural := 16 ;
      LANE_NUM    : natural := 0 ;
      X_MAC_NAME  : string  := "EP"  );

    port (
      -- Indicate if lane is connected
      X_lane_conn  : in  std_logic;
      Y_lane_conn  : in  std_logic;
      X_rate  : in  std_logic;
      -- MAC Interface signals 
      pclk         : in  std_logic;
      resetn       : in  std_logic;
      pipe_mode    : in  std_logic;
      X_txdata     : in  std_logic_vector(XPIPE_WIDTH-1 downto 0);
      X_txdatak    : in  std_logic_vector((XPIPE_WIDTH/8)-1 downto 0);
      X_txdetectrx : in  std_logic;
      X_txelecidle : in  std_logic;
      X_txcompl    : in  std_logic;
      X_rxpolarity : in  std_logic;
      X_powerdown  : in  std_logic_vector(1 downto 0);
      X_rxdata     : out std_logic_vector(XPIPE_WIDTH-1 downto 0);
      X_rxdatak    : out std_logic_vector((XPIPE_WIDTH/8)-1 downto 0);
      X_rxvalid    : out std_logic;
      X_phystatus  : out std_logic;
      X_rxelecidle : out std_logic;
      X_rxstatus   : out std_logic_vector(2 downto 0);
      X2Y_data     : out std_logic_vector(YPIPE_WIDTH-1 downto 0);
      X2Y_datak    : out std_logic_vector((YPIPE_WIDTH/8)-1 downto 0);
      X2Y_elecidle : out std_logic;
      Y2X_data     : in  std_logic_vector(YPIPE_WIDTH-1 downto 0);
      Y2X_datak    : in  std_logic_vector((YPIPE_WIDTH/8)-1 downto 0);
      Y2X_elecidle : in  std_logic
      ) ;
  end component altpcietb_pipe_xtx2yrx ;

  signal B_rxdata_i  : std_logic_vector(BPIPE_WIDTH-1 downto 0);
  signal B_rxdatak_i : std_logic_vector((BPIPE_WIDTH/8)-1 downto 0);
  signal B_rxvalid_i : std_logic;

  signal A2B_data     : std_logic_vector(APIPE_WIDTH-1 downto 0);
  signal A2B_datak    : std_logic_vector((APIPE_WIDTH/8)-1 downto 0);
  signal A2B_elecidle : std_logic;
  signal B2A_data     : std_logic_vector(APIPE_WIDTH-1 downto 0);
  signal B2A_datak    : std_logic_vector((APIPE_WIDTH/8)-1 downto 0);
  signal B2A_elecidle : std_logic;


  -- For a 250MHz 8-Bit PIPE the fifo needs to be 2x the length for the same latency
  -- Add latency on B side only because it is interface to RP which has a known
  -- interface of 250Mhz SDR 8 bit
  constant FIFO_LENGTH      : natural := LATENCY * (16/APIPE_WIDTH);
  signal   B_rxdata_shift   : std_logic_vector(FIFO_LENGTH * BPIPE_WIDTH - 1 downto 0);
  signal   B_rxdatak_shift  : std_logic_vector(FIFO_LENGTH * (BPIPE_WIDTH / 8) - 1 downto 0);
  signal   B_rxvalid_shift  : std_logic_vector(FIFO_LENGTH - 1 downto 0);
  signal   B_txdata_shift   : std_logic_vector(FIFO_LENGTH * BPIPE_WIDTH - 1 downto 0);
  signal   B_txdatak_shift  : std_logic_vector(FIFO_LENGTH * (BPIPE_WIDTH / 8) - 1 downto 0);
  signal   B_txelecidle_shift : std_logic_vector(FIFO_LENGTH - 1 downto 0);

begin  -- behavioral

  -- Shift register to add latency between the pipe to pipe connection.
  -- Length of the shift registers scales with the length of the desired latency
  B_rxdata  <= B_rxdata_shift((FIFO_LENGTH * BPIPE_WIDTH - 1) downto ((FIFO_LENGTH - 1) * BPIPE_WIDTH));
  B_rxdatak <= B_rxdatak_shift((FIFO_LENGTH * (BPIPE_WIDTH/8) - 1) downto (FIFO_LENGTH -1) * (BPIPE_WIDTH/8));
  B_rxvalid <= B_rxvalid_shift(FIFO_LENGTH-1);

  Latency_pipe : process (pclk_b)
  begin
    if resetn = '0' then
      B_rxdata_shift     <= (others => '0');
      B_rxdatak_shift    <= (others => '0');
      B_rxvalid_shift    <= (others => '0');
      B_txdata_shift     <= (others => '0');
      B_txdatak_shift    <= (others => '0');
      B_txelecidle_shift <= (others => '0');
    elsif rising_edge(pclk_b) then
      B_rxdata_shift     <= B_rxdata_shift(((FIFO_LENGTH - 1) * BPIPE_WIDTH - 1) downto 0) & B_rxdata_i;
      B_rxdatak_shift    <= B_rxdatak_shift(((FIFO_LENGTH - 1) * (BPIPE_WIDTH/8) - 1) downto 0) & B_rxdatak_i;
      B_rxvalid_shift    <= B_rxvalid_shift((FIFO_LENGTH - 1) - 1 downto 0) & B_rxvalid_i;
      B_txdata_shift     <= B_txdata_shift(((FIFO_LENGTH - 1) * BPIPE_WIDTH - 1) downto 0) & B_txdata;
      B_txdatak_shift    <= B_txdatak_shift(((FIFO_LENGTH - 1) * (BPIPE_WIDTH/8) - 1) downto 0) & B_txdatak;
      B_txelecidle_shift <= B_txelecidle_shift((FIFO_LENGTH - 1) - 1 downto 0) & B_txelecidle;
      
    end if;
  end process Latency_pipe;
  
  A2B : altpcietb_pipe_xtx2yrx
    generic map (
      XPIPE_WIDTH => APIPE_WIDTH ,
      YPIPE_WIDTH => APIPE_WIDTH ,      
      LANE_NUM    => LANE_NUM ,
      X_MAC_NAME  => A_MAC_NAME)
    
    port map (
      X_lane_conn  => A_lane_conn,
      Y_lane_conn  => B_lane_conn,
      X_rate  => A_rate,
      pclk         => pclk_a,
      resetn       => resetn,
      pipe_mode    => pipe_mode,
      X_txdata     => A_txdata,
      X_txdatak    => A_txdatak,
      X_txdetectrx => A_txdetectrx,
      X_txelecidle => A_txelecidle,
      X_txcompl    => A_txcompl,
      X_rxpolarity => A_rxpolarity,
      X_powerdown  => A_powerdown,
      X_rxdata     => A_rxdata,
      X_rxdatak    => A_rxdatak,
      X_rxvalid    => A_rxvalid,
      X_phystatus  => A_phystatus,
      X_rxelecidle => A_rxelecidle,
      X_rxstatus   => A_rxstatus,
      X2Y_data     => A2B_data,
      X2Y_datak    => A2B_datak,
      X2Y_elecidle => A2B_elecidle,
      Y2X_data     => B2A_data,
      Y2X_datak    => B2A_datak,
      Y2X_elecidle => B2A_elecidle
    ) ; 

  B2A : altpcietb_pipe_xtx2yrx
    generic map (
      XPIPE_WIDTH => BPIPE_WIDTH ,
      YPIPE_WIDTH => APIPE_WIDTH ,      
      LANE_NUM    => LANE_NUM ,
      X_MAC_NAME  => B_MAC_NAME )
    
    port map (
      X_lane_conn  => B_lane_conn,
      Y_lane_conn  => A_lane_conn,
      X_rate  => B_rate,
      pclk         => pclk_b,
      resetn       => resetn,
      pipe_mode    => pipe_mode,
      X_txdata     => B_txdata_shift((FIFO_LENGTH * BPIPE_WIDTH - 1) downto ((FIFO_LENGTH - 1) * BPIPE_WIDTH)),
      X_txdatak    => B_txdatak_shift((FIFO_LENGTH * (BPIPE_WIDTH/8) - 1) downto (FIFO_LENGTH -1) * (BPIPE_WIDTH/8)),
      X_txdetectrx => B_txdetectrx,
      X_txelecidle => B_txelecidle_shift((FIFO_LENGTH - 1)),
      X_txcompl    => B_txcompl,
      X_rxpolarity => B_rxpolarity,
      X_powerdown  => B_powerdown,
      X_rxdata     => B_rxdata_i,
      X_rxdatak    => B_rxdatak_i,
      X_rxvalid    => B_rxvalid_i,
      X_phystatus  => B_phystatus,
      X_rxelecidle => B_rxelecidle,
      X_rxstatus   => B_rxstatus,
      X2Y_data     => B2A_data,
      X2Y_datak    => B2A_datak,
      X2Y_elecidle => B2A_elecidle,
      Y2X_data     => A2B_data,
      Y2X_datak    => A2B_datak,
      Y2X_elecidle => A2B_elecidle
    ) ; 

end structural;
