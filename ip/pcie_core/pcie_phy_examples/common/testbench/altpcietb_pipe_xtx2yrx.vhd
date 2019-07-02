-------------------------------------------------------------------------------
-- Title         : PCI Express PIPE PHY single direction connector
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_pipe_xtx2yrx.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This function provides a single direction connection from the "X" side
-- transmitter to the "Y" side receiver.
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
use ieee.numeric_std.all;
use work.altpcietb_bfm_log.all;
entity  altpcietb_pipe_xtx2yrx is

  generic (
    XPIPE_WIDTH     : natural := 16 ;
    YPIPE_WIDTH     : natural := 16 ;
    LANE_NUM       : natural := 0 ;
    X_MAC_NAME     : string := "EP" );

  port (
    -- Indicate if lane is connected
    X_lane_conn  : in  std_logic;
    Y_lane_conn  : in  std_logic;
    X_rate       : in  std_logic;
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
end altpcietb_pipe_xtx2yrx ;

architecture behavioral of altpcietb_pipe_xtx2yrx is

  type phy_states is ( P0, P0_ENT, P0s, P0s_ENT, P1, P1_DET, P1_ENT, P2, P2_ENT, NOT_IN_USE ) ;
  signal phy_state : phy_states := P1;

  signal resetn_q1  : std_logic := '0';
  signal resetn_q2  : std_logic := '1';
  signal count  : std_logic := '0';
  signal sync  : std_logic := '0';
  signal X_txdata_y  : std_logic_vector(YPIPE_WIDTH-1 downto 0) := (others => '0');
  signal X_txdatak_y  : std_logic_vector((YPIPE_WIDTH/8)-1 downto 0) := (others => '0');
  signal X_rxdata_y_tmp  : std_logic_vector(YPIPE_WIDTH-1 downto 0);
  signal X_rxdata_y  : std_logic_vector(YPIPE_WIDTH-1 downto 0);
  signal X_rxdatak_y  : std_logic_vector((YPIPE_WIDTH/8)-1 downto 0);
  signal X_txdata_tmp  : std_logic_vector(7 downto 0);
  signal X_txdatak_tmp : std_logic;
  signal detect_cnt  : unsigned(3 downto 0);
  signal X_rate_r : std_logic;



begin  -- behavioral


  convert_16to8 : if XPIPE_WIDTH > YPIPE_WIDTH generate  -- X (16) => Y (8)
  -----------------------------------------------------------------------------
  -- not supported
  -----------------------------------------------------------------------------
  end generate convert_16to8;

  convert_8to16 : if (XPIPE_WIDTH < YPIPE_WIDTH) generate -- X(8) => Y (16)
    conversion: process (pclk)
    begin
      if pclk'event and pclk = '1' then     -- rising clock edge
        X_rxdata_y_tmp <= X_rxdata_y;
        -----------------------------------------------------------------------
        -- The assumption of the logic below is that pclk will run 2x the speed
        -- of the incoming data. The count signal needs to be 0 on the 1st
        -- cycle and 1 on the 2nd cycle
        -- Hdata16         BB  BB  DD  DD
        -- Ldata16         AA  AA  CC  CC
        -- count            0   1   0   1
        -- data8                AA  BB  CC etc..
        -----------------------------------------------------------------------

        if sync = '1' then
          count <= not count;
        elsif sync = '0' and (X_rxdata_y = X_rxdata_y_tmp) and
        (X_rxdatak_y(0) = '1' or X_rxdatak_y(1) = '1') then
          count <= '0';
          sync <= '1';
        end if;

        if count = '0' then
          X_txdata_tmp <= X_txdata;
          X_txdatak_tmp <= X_txdatak(0);
          X_rxdata <= X_rxdata_y(7 downto 0);
          X_rxdatak <= X_rxdatak_y(0 downto 0);
        else
          X_txdata_y <= X_txdata & X_txdata_tmp;
          X_txdatak_y <= X_txdatak(0 downto 0) & X_txdatak_tmp;
          X_rxdata <= X_rxdata_y(15 downto 8);
          X_rxdatak <= X_rxdatak_y(1 downto 1);
        end if;
      end if;
    end process conversion;
  end generate convert_8to16;

  convert_directmap : if (XPIPE_WIDTH = YPIPE_WIDTH) generate -- direct map
    X_txdata_y <= X_txdata;
    X_txdatak_y <= X_txdatak;
    X_rxdata <= X_rxdata_y;
    X_rxdatak <= X_rxdatak_y;
  end generate convert_directmap;


  reset_pipeline: process (pclk)
  begin  -- process pipeline
    if pclk'event and pclk = '1' then     -- rising clock edge
      resetn_q2 <= resetn_q1 ;
      resetn_q1 <= resetn ;
    end if;
  end process reset_pipeline;


  main_ctrl: process (pclk)
  begin  -- process main
    if pclk'event and pclk = '1' then     -- rising clock edge
      -- Give the MAC a chance to come out of reset
      if ( (resetn = '0') or (resetn_q1 = '0') or (resetn_q2 = '0') or (X_lane_conn = '0') ) then
        -- Only check these errors if all 3 cycles asserted
        if ( (resetn = '0') and (resetn_q1 = '0') and (resetn_q2 = '0') and (X_lane_conn = '1') and (pipe_mode = '1') ) then
          if (X_txdetectrx = '1') then
            ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         "TxDetectRx/Loopback not deasserted while reset asserted, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME ) ;
          end if;
          if (X_txdetectrx = '1') then
            ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         "TxDetectRx/Loopback not deasserted while reset asserted, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME ) ;
          end if;
          if (X_txelecidle = '0') then
            ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         "TxElecIdle not asserted while reset asserted, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME ) ;
          end if;
          if (X_txcompl = '1') then
            ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         "TxCompliance not deasserted while reset asserted, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME ) ;
          end if;
          if (X_rxpolarity = '1') then
            ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         "RxPolarity not deasserted while reset asserted, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME ) ;
          end if;
          if ( (X_powerdown = "00") or
               (X_powerdown = "01") or
               (X_powerdown = "11") ) then
            ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                         "Powerdown not P1 while reset asserted, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME ) ;
          end if;
        end if;
        if (pipe_mode = '1') then
          phy_state <= P1_ENT ;
        else
          phy_state <= NOT_IN_USE ;
        end if;
        if (X_lane_conn = '1') then
          X_phystatus <= '1' ;
        else
          X_phystatus <= X_txdetectrx ;
        end if;
        X_rxvalid <= '0' ;
        X_rxelecidle <= '1' ;
        X_rxstatus <= "100" ;
        X2Y_elecidle <= '1' ;
        X_rate_r <= '0';
      else
        X_rate_r <= X_rate;
        case phy_state is
          when P0 | P0_ENT =>
            X2Y_elecidle <= X_txelecidle ;
            if (phy_state = P0_ENT) then
              X_phystatus <= '1' ;
            elsif X_rate /= X_rate_r then
              X_phystatus <= '1' ;
            else
              X_phystatus <= '0' ;
            end if;
            case X_powerdown is
              when "00" =>
                phy_state <= P0 ;
              when "01" =>
                phy_state <= P0s_ENT ;
              when "10" =>
                phy_state <= P1_ENT ;
              when "11" =>
                phy_state <= P2_ENT ;
              when others =>
                ebfm_display(EBFM_MSG_ERROR_CONTINUE,"Illegal value of powerdown in P0 state, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME) ;
            end case;
            X_rxelecidle <= Y2X_elecidle ;
            if (Y2X_elecidle = '1') then
              X_rxstatus <= "100" ;
              X_rxvalid  <= '0' ;
            else
              X_rxstatus <= "000" ;
              X_rxvalid  <= '1' ;
            end if;
          when P0s | P0s_ENT =>
            X2Y_elecidle <= '1' ;
            if (X_txelecidle /= '1') then
              ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                           "Txelecidle not asserted in P0s state, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME);
            end if ;
            if (phy_state = P0s_ENT) then
              X_phystatus <= '1' ;
            else
              X_phystatus <= '0' ;
            end if;
            case X_powerdown is
              when "00" =>
                phy_state <= P0 ;
              when "01" =>
                phy_state <= P0s ;
              when others =>
                ebfm_display(EBFM_MSG_ERROR_CONTINUE,"Illegal value of powerdown in P0 state, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME) ;
            end case;
            X_rxelecidle <= Y2X_elecidle ;
            if (Y2X_elecidle = '1') then
              X_rxstatus <= "100" ;
              X_rxvalid  <= '0' ;
            else
              X_rxstatus <= "000" ;
              X_rxvalid  <= '1' ;
            end if;
          when P1 | P1_ENT =>
            X2Y_elecidle <= '1' ;
            if (X_txelecidle /= '1') then
              ebfm_display(EBFM_MSG_ERROR_CONTINUE,
                           "Txelecidle not asserted in P1 state, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME) ;
            end if ;
            if (phy_state = P1_ENT) then
              X_phystatus <= '1' ;
            else
              X_phystatus <= '0' ;
            end if;
            case X_powerdown is
              when "00" =>
                phy_state <= P0_ENT ;
              when "10" =>
                if (X_txdetectrx = '1') then
                  phy_state <= P1_DET ;
                  detect_cnt <= x"4";
                else
                  phy_state <= P1 ;
                end if;
              when others =>
                ebfm_display(EBFM_MSG_ERROR_CONTINUE,"Illegal value of powerdown in P1 state, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME) ;
            end case;
            X_rxelecidle <= Y2X_elecidle ;
            if (Y2X_elecidle = '1') then
              X_rxstatus <= "100" ;
              X_rxvalid  <= '0' ;
            else
              X_rxstatus <= "000" ;
              X_rxvalid  <= '1' ;
            end if;
          when P1_DET =>
            if (X_powerdown /= "10") then
              ebfm_display(EBFM_MSG_WARNING,
                           "WARNING: Tried to move out of P1 state in middle of Rx Detect, ignoring, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME) ;
            end if ;
            if detect_cnt /= x"0" then
              detect_cnt <= detect_cnt - 1;
            end if;

            if (detect_cnt = x"1") then
                X_phystatus <= '1' ;
                if (Y_lane_conn = '1') then
                  X_rxstatus <= "011" ;
                else
                  if (Y2X_elecidle = '1') then
                    X_rxstatus <= "100" ;
                  else
                    X_rxstatus <= "000" ;
                  end if;
                end if;
            else
                X_phystatus <= '0' ;
                X_rxstatus <= "000" ;
            end if;

            if (X_txdetectrx = '0') then
              phy_state <= P1;
            end if;

            X_rxelecidle <= Y2X_elecidle ;
            if (Y2X_elecidle = '1') then
              X_rxvalid  <= '0' ;
            else
              X_rxvalid  <= '1' ;
            end if;
          when P2 | P2_ENT =>
            -- Treat this synchronously for now
            if (phy_state = P2_ENT) then
              X_phystatus <= '1' ;
            else
              X_phystatus <= '0' ;
            end if;
            X_rxvalid <= '0' ;
            X_rxstatus <= "100" ;
            X_rxelecidle <= Y2X_elecidle ;
            X2Y_elecidle <= X_txelecidle ;
            case X_powerdown is
              when "11" =>
                phy_state <= P2 ;
              when "10" =>
                phy_state <= P1_ENT ;
              when others =>
                ebfm_display(EBFM_MSG_ERROR_CONTINUE,"Illegal value of powerdown in P2 state, Lane: " & integer'image(lane_num) & ", MAC: " & X_MAC_NAME) ;
            end case;
          when NOT_IN_USE =>
            X_phystatus <= '0' ;
            X_rxvalid <= '0' ;
            X_rxstatus <= "100" ;
            X_rxelecidle <= Y2X_elecidle ;
            X2Y_elecidle <= X_txelecidle ;
            phy_state <= NOT_IN_USE ;
        end case;
      end if;
    end if;
  end process main_ctrl;

  main_data: process (pclk)
  begin  -- process main
    if pclk'event then     -- rising or falling clock edge
      -- Give the MAC a chance to come out of reset
      if ( (resetn = '0') or (resetn_q1 = '0') or (resetn_q2 = '0') or (X_lane_conn = '0') ) then
        -- Only check these errors if all 3 cycles asserted
        X_rxdata_y <= (others => 'Z') ;
        X_rxdatak_y <= (others => 'Z') ;
        X2Y_data <= (others => 'Z') ;
        X2Y_datak <= (others => 'Z') ;
      else
        case phy_state is
          when P0 | P0_ENT =>
            if (X_txelecidle = '0') then
              if (X_txdetectrx = '1') then
                -- Loopback case
                X2Y_data <= Y2X_data ;
                X2Y_datak <= Y2X_datak ;
              else
                -- Non-Loopback
                X2Y_data <= X_txdata_y ;
                X2Y_datak <= X_txdatak_y ;
              end if;
            else
              -- Electrical Idle
              X2Y_data <= (others => 'Z') ;
              X2Y_datak <= (others => 'Z') ;
            end if;
            if (Y2X_elecidle = '1') then
              X_rxdatak_y  <= (others => 'Z') ;
              X_rxdata_y   <= (others => 'Z') ;
            else
              X_rxdatak_y  <= Y2X_datak ;
              X_rxdata_y   <= Y2X_data ;
            end if;
          when P0s | P0s_ENT =>
            X2Y_data <= (others => 'Z') ;
            X2Y_datak <= (others => 'Z') ;
            if (Y2X_elecidle = '1') then
              X_rxdatak_y  <= (others => 'Z') ;
              X_rxdata_y   <= (others => 'Z') ;
            else
              X_rxdatak_y  <= Y2X_datak ;
              X_rxdata_y   <= Y2X_data ;
            end if;
          when P1 | P1_ENT =>
            X2Y_data <= (others => 'Z') ;
            X2Y_datak <= (others => 'Z') ;
            if (Y2X_elecidle = '1') then
              X_rxdatak_y  <= (others => 'Z') ;
              X_rxdata_y   <= (others => 'Z') ;
            else
              X_rxdatak_y  <= Y2X_datak ;
              X_rxdata_y   <= Y2X_data ;
            end if;
          when P1_DET =>
            if (Y2X_elecidle = '1') then
              X_rxdatak_y  <= (others => 'Z') ;
              X_rxdata_y   <= (others => 'Z') ;
            else
              X_rxdatak_y  <= Y2X_datak ;
              X_rxdata_y   <= Y2X_data ;
            end if;
          when P2 | P2_ENT =>
            X_rxdata_y <= (others => 'Z') ;
            X_rxdatak_y <= (others => 'Z') ;
            X2Y_datak <= (others => 'Z') ;
            X2Y_data <= (others => 'Z') ;
          when NOT_IN_USE =>
            X_rxdata_y <= (others => 'Z') ;
            X_rxdatak_y <= (others => 'Z') ;
            X2Y_datak <= (others => 'Z') ;
            X2Y_data <= (others => 'Z') ;
        end case;
      end if;
    end if;
  end process main_data;

end behavioral;

