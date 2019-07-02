-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Root Port VC Interface
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_vc_intf.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This entity interfaces between the root port transaction list processor
-- and the root port module single VC interface. It handles the following basic
-- functions:
-- * Formating Tx Descriptors 
-- * Retrieving Tx Data as needed from the shared memory
-- * Decoding Rx Descriptors 
-- * Storing Rx Data as needed to the shared memory
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
use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_req_intf.all;

entity altpcietb_bfm_vc_intf is

  generic (
    VC_NUM : natural;
    DISABLE_RX_BE_CHECK: natural := 1);
  
  port (
    -- Interface signals with Root Port Model
    -- General 
    clk_in        : in  std_logic;
    rstn          : in  std_logic;
    -- Rx Interface
    rx_req        : in  std_logic;
    rx_ack        : out std_logic;
    rx_abort      : out std_logic;
    rx_retry      : out std_logic;
    rx_mask       : out std_logic;
    rx_desc       : in  std_logic_vector(135 downto 0);
    rx_ws         : out std_logic;
    rx_data       : in  std_logic_vector(63 downto 0);
    rx_be         : in  std_logic_vector(7 downto 0);
    rx_dv         : in  std_logic;
    rx_dfr        : in  std_logic;
    -- Tx Interface
    tx_cred       : in  std_logic_vector(21 downto 0);
    tx_req        : out std_logic;
    tx_desc       : out std_logic_vector(127 downto 0);
    tx_ack        : in  std_logic;
    tx_dfr        : out std_logic;
    tx_data       : out std_logic_vector(63 downto 0);
    tx_dv         : out std_logic;
    tx_err        : out std_logic;
    tx_ws         : in  std_logic;
    -- Config space interface
    cfg_io_bas    : in  std_logic_vector(19 downto 0);
    cfg_np_bas    : in  std_logic_vector(11 downto 0);
    cfg_pr_bas    : in  std_logic_vector(43 downto 0)
    );

end altpcietb_bfm_vc_intf;
architecture behavioral of altpcietb_bfm_vc_intf is


  type rx_states is (RXST_IDLE, RXST_DESC_ACK, RXST_DATA_WRITE, RXST_DATA_NONP_WRITE, RXST_DATA_COMPL, RXST_NONP_REQ);

  type tx_states is (TXST_IDLE, TXST_DESC, TXST_DATA);

  type tx_data_array is array (0 to 511) of std_logic_vector(63 downto 0);

  signal rx_state : rx_states;
  signal tx_state : tx_states;

  -- Communication signals between main Tx State Machine and main Rx State Machine
  -- to indicate when completions are expected
  signal exp_compl_tag : integer;
  signal exp_compl_bcount : natural;

  -- Communication signals between Rx State Machine and Tx State Machine
  -- for requesting completions
  signal rx_tx_req : std_logic;
  signal rx_tx_desc : std_logic_vector(127 downto 0);
  signal rx_tx_shmem_addr : natural;
  signal rx_tx_bcount : natural;
  signal rx_tx_byte_enb : std_logic_vector(7 downto 0);
  signal tx_rx_ack : std_logic;

  -- Communication Signals for PErf Monitoring
  signal tx_dv_last  : std_logic;
  signal tx_req_int : std_logic;
  signal rx_ws_int : std_logic;
  signal rx_ack_int  : std_logic;
  
  impure function is_request (
    constant rx_desc : std_logic_vector(135 downto 0))
    return boolean is
  begin
    case rx_desc(124 downto 120) is 
      when "00000" => return TRUE;       -- Memory Read or Write
      when "00010" => return TRUE;       -- I/O Read or Write
      when "01010" => return FALSE;      -- Completion
      when others =>
        -- "00001" Memory Read Locked
        -- "00100" Config Type 0 Read or Write
        -- "00101" Config Type 1 Read or Write
        -- "10rrr" Message (w/Data)
        -- "01011" Completion Locked
        ebfm_display(EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                     " Recevied unsupported TLP, Fmt/Type: " & himage(rx_desc(127 downto 120))) ;
        return FALSE ;
    end case;
  end function is_request ;

  function is_non_posted (
    constant desc : std_logic_vector(127 downto 0))
    return boolean is
  begin
    case desc(124 downto 120) is 
      when "00000" =>                    -- Memory Read or Write
        if (desc(126) = '0') then
          -- No Data, Must be non-posted read
          return TRUE;
        else
          return FALSE;
        end if;
      when "00100" => return TRUE;       -- Config Type 0 Read or Write
      when "00101" => return TRUE;       -- Config Type 1 Read or Write
      when "00010" => return TRUE;       -- I/O Read or Write
      when "01010" => return FALSE;      -- Completion
      when others =>
        -- "00001" Memory Read Locked
        -- "10rrr" Message (w/Data)
        -- "01011" Completion Locked
        return FALSE;
    end case;
  end function is_non_posted ;

  
  function has_data (
    constant desc : std_logic_vector(127 downto 0))
    return boolean is
  begin
    if (desc(126) = '1') then
      return TRUE;
    else
      return FALSE;
    end if;
  end function has_data ;

  function calc_byte_count (
    constant desc : std_logic_vector(127 downto 0))
    return natural is
    variable bcount : natural;
  begin
    -- Number of DWords * 4 gives bytes
    bcount := to_integer(unsigned(desc(105 downto 96))) * 4 ;
    -- If more than 1 DW
    if (bcount > 4) then
      -- Adjust if the last Dword is not full
      if (desc(71) = '0') then
        bcount := bcount - 1 ;
        if (desc(70) = '0') then
          bcount := bcount - 1 ;
          if (desc(69) = '0') then
            bcount := bcount - 1 ;
            if (desc(68) = '0') then
              -- Handle the case of no bytes in last DW
              bcount := bcount - 1 ;
            end if;
          end if;
        end if;
      end if;
      -- Now adjust if the first Dword is not full
      if (desc(64) = '0') then
        bcount := bcount - 1 ;
        if (desc(65) = '0') then
          bcount := bcount - 1 ;
          if (desc(66) = '0') then
            bcount := bcount - 1 ;
            if (desc(67) = '0') then
              -- Handle the case of no bytes in first DW
              bcount := bcount - 1 ;
            end if;
          end if;
        end if;
      end if;
    else
      -- Only one DW, need to adjust based on
      -- First Byte Enables could be any subset
      if (desc(64) = '0') then
        bcount := bcount - 1 ;
      end if ;
      if (desc(65) = '0') then
        bcount := bcount - 1 ;
      end if ;  
      if (desc(66) = '0') then
        bcount := bcount - 1 ;
      end if ;  
      if (desc(67) = '0') then
        bcount := bcount - 1 ;
      end if;
    end if;
    return bcount;
  end function calc_byte_count ;

  function calc_first_byte_enb (
    constant desc : std_logic_vector(127 downto 0))
    return std_logic_vector is
    variable byte_enb : std_logic_vector(7 downto 0) := (others => '0') ;
  begin  -- calc_first_byte_enb
    if ( ( (desc(125) = '1') and (desc(2) = '1') ) or
         ( (desc(125) = '0') and (desc(34) = '1') ) ) then
      byte_enb := desc(67 downto 64) & "0000" ;
    else
      byte_enb := "1111" & desc(67 downto 64) ;
    end if;
    return byte_enb;
  end calc_first_byte_enb;
  
  function calc_lcl_addr (
    constant rx_desc : std_logic_vector(135 downto 0))
    return natural is
    variable req_addr : std_logic_vector(63 downto 0) := (others => '0') ;      
  begin
    -- We just use the lower bits of the address to for the memory address 
    if (rx_desc(125) = '1') then
      -- 4 DW Header
      req_addr(63 downto 2) := rx_desc(63 downto 2) ;
    else
      -- 3 DW Header
      req_addr(31 downto 2) := rx_desc(63 downto 34) ;
    end if;
    -- Calculate Byte Address from Byte Enables
    if (rx_desc(64) = '1') then
      req_addr(1 downto 0) := "00" ;
    else
      if (rx_desc(65) = '1') then
        req_addr(1 downto 0) := "01" ;
      else
        if (rx_desc(66) = '1') then
          req_addr(1 downto 0) := "10" ;
        else
          -- Last Byte should be enabled (or we are not accessing anything so
          -- it is a don't care)
          req_addr(1 downto 0) := "11" ;
        end if ;
      end if ;
    end if;
    return to_integer(unsigned(req_addr(SHMEM_ADDR_WIDTH-1 downto 0))) ;
  end function calc_lcl_addr ;
  
  procedure rx_write_req_setup (
    constant rx_desc : in std_logic_vector(135 downto 0) ;
    variable addr : out natural;
    variable byte_enb : out std_logic_vector(7 downto 0);
    variable bcount : out natural
    ) is
  begin
    addr := calc_lcl_addr(rx_desc) ;
    byte_enb := calc_first_byte_enb(rx_desc(127 downto 0)) ;
    bcount := calc_byte_count(rx_desc(127 downto 0)) ;
  end procedure rx_write_req_setup ;

  procedure rx_compl_setup (
    constant rx_desc : std_logic_vector(135 downto 0);
    variable base_addr : out natural;
    variable byte_enb : out std_logic_vector(7 downto 0);
    variable bcount : out natural;
    variable tag : out integer;
    variable status : out std_logic_vector(2 downto 0)
    ) is
    variable tagi : natural ;
    variable bcounti : natural;
  begin  -- lcl_compl_addr
    tagi  := To_Integer(unsigned(rx_desc(47 downto 40))) ;
    if (rx_desc(126) = '1') then
      base_addr := vc_intf_get_lcl_addr(tagi) ;
    else
      base_addr := 2**SHMEM_ADDR_WIDTH ;
    end if;
    tag := tagi ;

    -- Calculate the byte-count from Length field
    bcounti := to_integer(unsigned(rx_desc(105 downto 96))) * 4 ;
    
    -- Calculate the byte-enables from the Lower Address field
    -- Also modify the byte count 
    case rx_desc(34 downto 32) is
      when "111" =>
        byte_enb := "10000000" ;
        bcounti := bcounti - 3 ;
      when "110" =>
        byte_enb := "11000000" ;
        bcounti := bcounti - 2 ;
      when "101" =>
        byte_enb := "11100000" ;
        bcounti := bcounti - 1 ;
      when "100" =>
        byte_enb := "11110000" ;
        bcounti := bcounti - 0 ;
      when "011" =>
        byte_enb := "11111000" ;
        bcounti := bcounti - 3 ;
      when "010" =>
        byte_enb := "11111100" ;
        bcounti := bcounti - 2 ;
      when "001" =>
        byte_enb := "11111110" ;
        bcounti := bcounti - 1 ;
      when others =>
        byte_enb := (others => '1') ;
        bcounti := bcounti - 0 ;
    end case;

    -- Now if the remaining byte-count from the header is less than that
    -- calculated above, that means there are some last data phase
    -- byte enables that are not on, update bcounti to reflect that
    if (unsigned(rx_desc(75 downto 64)) < bcounti) then
      bcounti := to_integer(unsigned(rx_desc(75 downto 64))) ;
    end if;

    bcount := bcounti ;
    
    status := rx_desc(79 downto 77) ;
    
  end procedure rx_compl_setup;

  -- Setup the Completion Info for the received request
  procedure rx_nonp_req_setup_compl (
    constant rx_desc : in std_logic_vector(135 downto 0);
    variable rx_tx_desc : out std_logic_vector(127 downto 0);
    variable rx_tx_shmem_addr : out natural;
    variable rx_tx_byte_enb : out std_logic_vector(7 downto 0);
    variable rx_tx_bcount : out natural
    ) is
    variable temp_bcount : natural ;
    variable temp_shmem_addr : natural;
  begin
    temp_shmem_addr := calc_lcl_addr(rx_desc(135 downto 0)) ;
    rx_tx_shmem_addr := temp_shmem_addr ;
    rx_tx_byte_enb := calc_first_byte_enb(rx_desc(127 downto 0)) ;
    temp_bcount := calc_byte_count(rx_desc(127 downto 0)) ;
    rx_tx_bcount := temp_bcount ;
    rx_tx_desc := (others => '0') ;
    rx_tx_desc(126) := not rx_desc(126) ;  -- Completion Data is opposite of Request
    rx_tx_desc(125) := '0' ;            -- FMT bit 0 always 0
    rx_tx_desc(124 downto 120) := "01010" ;  -- Completion
    -- TC,TD,EP,Attr,Length (and reserved bits) same as request:
    rx_tx_desc(119 downto 96)  := rx_desc(119 downto 96) ;
    rx_tx_desc(95 downto 80) := RP_REQ_ID ;  -- Completer ID
    rx_tx_desc(79 downto 77) := "000" ;  -- Completion Status
    rx_tx_desc(76) := '0' ;             -- Byte Count Modified
    rx_tx_desc(75 downto 64) := std_logic_vector(to_unsigned(temp_bcount,12)) ;
    rx_tx_desc(63 downto 48) := rx_desc(95 downto 80) ;  -- Requester ID
    rx_tx_desc(47 downto 40) := rx_desc(79 downto 72) ;  -- Tag
    -- Lower Address: 
    rx_tx_desc(38 downto 32) := std_logic_vector(to_unsigned(temp_shmem_addr,7)) ; 
  end procedure rx_nonp_req_setup_compl ;
    
  function tx_fc_check (
    constant desc : std_logic_vector(127 downto 0);
    constant cred : std_logic_vector(21 downto 0))
    return boolean is
    variable data_cred : natural ;
  begin  -- tx_fc_check
    case desc(126 downto 120) is
      when  "1000100" |                 -- Config Write Type 0
            "0000100" =>                -- Config Read Type 0
        -- Type 0 Config issued to RP get handled internally,
        -- so we can issue even if no Credits
        return TRUE;
      when  "0000000" | "0100000" |     -- Memory Read (3DW, 4DW)
            "0000010" |                 -- IO Read
            "0000101" =>                -- Config Read Type 1
        -- Non-Posted Request without Data 
        if (cred(10) = '1') then
          return TRUE;
        else
          return FALSE;
        end if;
      when  "1000010" |                 -- IO Write
            "1000101" =>                -- Config Write Type 1
        -- Non-Posted Request with Data 
        if ((cred(10) = '1') and (cred(11) = '1')) then
          return TRUE;
        else
          return FALSE;
        end if;
      when "1000000" | "1100000" =>     -- Memory Read (3DW, 4DW)
        -- Posted Request with Data
        if (cred(0) = '1') then
          data_cred := To_Integer(unsigned(desc(105 downto 98))) ;
          if desc(97 downto 96) /= "00" then
            data_cred := data_cred + 1 ;
          end if;
          if data_cred <= unsigned(cred(9 downto 1)) then
            return TRUE;
          else
            return FALSE;
          end if;
        else
          return FALSE;
        end if;
      when others =>
        return FALSE;
    end case;
  end tx_fc_check;

  procedure tx_setup_data (
    constant lcl_addr  : in  natural;
    constant bcount    : in  natural;
    constant byte_enb  : in  std_logic_vector(7 downto 0);
    variable data_pkt  : out tx_data_array;
    variable dphases   : out natural;
    constant imm_valid : in  std_logic := '0';
    constant imm_data  : in  std_logic_vector(31 downto 0) := (others => '0') ) is

    variable dphasesi : natural := 0;
    variable bcount_v : natural;
    variable lcl_addr_v : natural;
    variable nb : natural;
    variable fb : natural;
  
  begin  -- tx_setup_data
    if (imm_valid = '1') then
      lcl_addr_v := 0 ;
    else
      lcl_addr_v := lcl_addr ;      
    end if;
    bcount_v := bcount ;
    
    -- Setup the first data phase, find the first byte
    byte_loop : for i in 0 to 7 loop
      if (byte_enb(i) = '1') then
        fb := i ;
        exit byte_loop;
      end if ;
    end loop byte_loop ;

    -- first data phase figure out number of bytes
    nb := 8 - fb ;
    if (nb > bcount_v) then
      nb := bcount_v ;
    end if;

    -- first data phase get bytes
    data_pkt(dphasesi) := (others => '0') ;
    if (imm_valid = '1') then
      data_pkt(dphasesi)(((fb+nb)*8)-1 downto (fb*8)) := imm_data((nb*8)-1 downto 0) ;
    else
      data_pkt(dphasesi)(((fb+nb)*8)-1 downto (fb*8)) := shmem_read(lcl_addr_v,nb) ;
    end if;
    bcount_v := bcount_v - nb ;
    lcl_addr_v := lcl_addr_v + nb ;

    dphasesi := dphasesi + 1 ;

    -- Setup the remaining data phases
    while (bcount_v > 0) loop
      data_pkt(dphasesi) := (others => '0') ;
      if (bcount_v < 8) then
        nb := bcount_v ;
      else
        nb := 8 ;
      end if;
      if (imm_valid = '1') then
        data_pkt(dphasesi)((nb*8)-1 downto 0) := imm_data((lcl_addr_v+(nb*8)-1) downto lcl_addr_v) ;
      else
        data_pkt(dphasesi)((nb*8)-1 downto 0) := shmem_read(lcl_addr_v,nb) ;
      end if;
      bcount_v := bcount_v - nb ;
      lcl_addr_v := lcl_addr_v + nb ;
      dphasesi := dphasesi + 1 ;
    end loop;
    dphases := dphasesi ;
  end tx_setup_data;
  
  procedure tx_setup_req (
    constant req_desc  : in  std_logic_vector(127 downto 0);
    constant lcl_addr  : in natural;
    constant imm_valid : in  std_logic;
    constant imm_data  : in  std_logic_vector(31 downto 0);
    variable data_pkt  : out tx_data_array;
    variable dphases   : out natural) is

    variable bcount_v : natural;
    variable byte_enb_v : std_logic_vector(7 downto 0);

  begin  -- tx_setup_req
    if has_data(req_desc) then
      bcount_v := calc_byte_count(req_desc) ;
      byte_enb_v := calc_first_byte_enb(req_desc) ;
      tx_setup_data(lcl_addr,bcount_v,byte_enb_v,data_pkt,dphases,imm_valid,imm_data) ;
    else
      dphases := 0 ;
    end if;
  end tx_setup_req;
    
begin  -- behavioral

  
  main_rx_state: process (clk_in)
    type compl_byte_array is array (0 to EBFM_NUM_TAG-1) of integer;
    variable compl_received_v : compl_byte_array := (others => -1);
    variable compl_expected_v : compl_byte_array := (others => -1);
    variable rx_state_v       : rx_states ;
    variable rx_ack_v         : std_logic ;
    variable rx_ws_v          : std_logic ;
    variable rx_abort_v       : std_logic ;
    variable rx_retry_v       : std_logic ;
    variable shmem_addr_v     : natural;
    variable rx_compl_tag_v   : integer;
    variable rx_compl_baddr_v : shmem_addr_type;
    variable rx_compl_sts_v : std_logic_vector(2 downto 0);
    variable byte_enb_v        : std_logic_vector(7 downto 0);
    variable bcount_v : natural;
    variable rx_tx_req_v : std_logic;
    variable rx_tx_desc_v : std_logic_vector(127 downto 0);
    variable rx_tx_shmem_addr_v : natural;
    variable rx_tx_bcount_v : natural;
    variable rx_tx_byte_enb_v : std_logic_vector(7 downto 0);
    -- Note rx_mask will be controlled by tx_process
  begin  -- process main_rx_state
    if (clk_in'event and clk_in = '1') then
      if (rstn /= '1') then
        rx_state_v := RXST_IDLE ; 
        rx_ack_v := '0' ;
        rx_ws_v := '0' ;
        rx_abort_v := '0' ;
        rx_retry_v := '0' ;
        rx_compl_tag_v    := -1 ;
        rx_compl_sts_v := (others => '1') ;
        rx_tx_req_v       := '0' ;
        rx_tx_desc_v      := (others => '0');
        rx_tx_shmem_addr_v := 0 ;
        rx_tx_bcount_v := 0 ;
        rx_tx_bcount_v := 0 ;
        compl_expected_v  := (others => -1) ;
        compl_received_v  := (others => -1) ;
     else
       -- See if the Transmit side is transmitting a Non-Posted Request
       -- that we need to expect a completion for and if so record it
       if (exp_compl_tag > -1) then
         compl_expected_v(exp_compl_tag) := exp_compl_bcount ;
         compl_received_v(exp_compl_tag) := 0 ;
       end if;
        rx_state_v := rx_state ;
        rx_ack_v := '0' ;
        rx_ws_v := '0' ;
        rx_abort_v := '0' ;
        rx_retry_v := '0' ;
        rx_tx_req_v       := '0' ;
        case (rx_state) is
          when RXST_IDLE =>
            if (rx_req = '1') then
              rx_ack_v := '1' ;
              rx_state_v := RXST_DESC_ACK ;
            else
              rx_ack_v := '0' ;
              rx_state_v := RXST_IDLE ;
            end if ;
          when RXST_DESC_ACK | RXST_DATA_COMPL | RXST_DATA_WRITE | RXST_DATA_NONP_WRITE =>
            -- All of these states are handled together since they can all
            -- involve data transfer and we need to share that code.
            --
            -- If this is the cycle where the descriptor is being ack'ed we
            -- need to complete the descriptor decode first so that we can
            -- be prepared for the Data Transfer that might happen in the same
            -- cycle. 
            if rx_state = RXST_DESC_ACK then
              -- Begin Lengthy decode and checking of the Rx Descriptor
              -- First Determine if it is a completion or a request
              if (is_request(rx_desc)) then
                -- Request
                if is_non_posted(rx_desc(127 downto 0)) then
                  -- Non-Posted Request
                  rx_nonp_req_setup_compl(rx_desc,rx_tx_desc_v,rx_tx_shmem_addr_v,
                                          rx_tx_byte_enb_v,rx_tx_bcount_v) ; 
                  if (has_data(rx_desc(127 downto 0))) then
                    -- Non-Posted Write Request
                    rx_write_req_setup(rx_desc,shmem_addr_v,byte_enb_v,bcount_v) ;
                    rx_state_v := RXST_DATA_NONP_WRITE ;
                  else
                    -- Non-Posted Read Request
                    rx_state_v := RXST_NONP_REQ ;
                  end if ;
                else
                  -- Posted Request
                  rx_tx_desc_v := (others => '0') ;
                  rx_tx_shmem_addr_v := 0 ;
                  rx_tx_byte_enb_v := (others => '0') ;
                  rx_tx_bcount_v := 0 ;
                  if (has_data(rx_desc(127 downto 0))) then
                    -- Posted Write Request
                    rx_write_req_setup(rx_desc,shmem_addr_v,byte_enb_v,bcount_v) ;
                    rx_state_v := RXST_DATA_WRITE ;
                  else
                    -- Posted Message without Data (Note we don't have the rest
                    -- of the logic to handle this yet) 
                    rx_state_v := RXST_IDLE ;
                  end if;
                end if;
              else
                -- Completion
                rx_compl_setup(rx_desc,shmem_addr_v,byte_enb_v,bcount_v,
                                rx_compl_tag_v,rx_compl_sts_v) ;
                if (compl_expected_v(rx_compl_tag_v) < 0) then
                  ebfm_display
                    (EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                     " Recevied unexpected completion TLP, Fmt/Type: " &
                     himage(rx_desc(127 downto 120)) & " Tag: " & himage(rx_desc(47 downto 40)) ) ;
                end if;
                if (has_data(rx_desc(127 downto 0))) then
                  rx_state_v := RXST_DATA_COMPL ;  
                  -- Increment for already received data phases
                  shmem_addr_v := shmem_addr_v + compl_received_v(rx_compl_tag_v) ;
                else
                  rx_state_v := RXST_IDLE ;
                  if ( (compl_received_v(rx_compl_tag_v) < compl_expected_v(rx_compl_tag_v)) and
                       (rx_compl_sts_v = "000") ) then
                    ebfm_display
                      (EBFM_MSG_ERROR_CONTINUE,"Root Port VC" & integer'image(VC_NUM) &
                       " Did not receive all expected completion data. Expected: " &
                       integer'image(compl_expected_v(rx_compl_tag_v)) & " Received: " &
                       integer'image(compl_received_v(rx_compl_tag_v)) ) ;
                  end if;
                  -- Report that it is complete to the Driver
                  vc_intf_rpt_compl(rx_compl_tag_v,rx_compl_sts_v) ;
                  -- Clear out that we expect anymore
                  compl_received_v(rx_compl_tag_v) := -1 ;
                  compl_expected_v(rx_compl_tag_v) := -1 ;
                  rx_compl_tag_v := -1 ;
                end if;
              end if;
            end if;
            -- Now Handle the case if we are receiving data in this cycle
            if (rx_dv = '1') then
              for i in 0 to 7 loop
                -- Byte Enables only valid on first data phase, bcount_v covers
                -- the last data phase
                if ( (byte_enb_v(i) = '1') and (bcount_v > 0) ) then
                  shmem_write(shmem_addr_v,rx_data((i*8)+7 downto (i*8)),1) ;
                  shmem_addr_v := shmem_addr_v + 1 ;
                  bcount_v := bcount_v - 1 ;
                  if ( (bcount_v = 0) and (i < 7) )  then
                    for j in i+1 to 7 loop
                      byte_enb_v(j) := '0' ;
                    end loop;  -- j
                  end if;
                  if (rx_state_v = RXST_DATA_COMPL) then
                    compl_received_v(rx_compl_tag_v) := compl_received_v(rx_compl_tag_v) + 1 ;
                  end if;
                  if ( (rx_be(i) /= '1') and (DISABLE_RX_BE_CHECK = 0) ) then
                    ebfm_display
                      (EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                       " rx_be field: " & himage(rx_be) & " Mismatch. Expected: " &
                       himage(byte_enb_v)) ;
                  end if;
                else
                  if ( (rx_be(i) /= '0') and (DISABLE_RX_BE_CHECK = 0) ) then
                    ebfm_display
                      (EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                       " rx_be field: " & himage(rx_be) & " Mismatch. Expected: " &
                       himage(byte_enb_v)) ;
                  end if;
                end if;
              end loop;  -- i
              -- Enable all bytes in subsequent data phases
              byte_enb_v := (others => '1') ;
              if (rx_dfr = '0') then
                if (bcount_v > 0) then
                  ebfm_display
                    (EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                     " Rx Byte Count did not go to zero in last data phase. Remaining Bytes: " &
                     integer'image(bcount_v) ) ;
                end if;
                if (rx_state_v = RXST_DATA_COMPL) then
                  rx_state_v := RXST_IDLE ;
                  -- If we have received all of the data (or more) 
                  if (compl_received_v(rx_compl_tag_v) >= compl_expected_v(rx_compl_tag_v)) then
                    -- Error if more than expected
                    if (compl_received_v(rx_compl_tag_v) > compl_expected_v(rx_compl_tag_v)) then
                      ebfm_display
                        (EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                         " Received more completion data than expected. Expected: " &
                         integer'image(compl_expected_v(rx_compl_tag_v)) & " Received: " &
                         integer'image(compl_received_v(rx_compl_tag_v)) ) ;
                    end if ;
                    -- Report that it is complete to the Driver
                    vc_intf_rpt_compl(rx_compl_tag_v,rx_compl_sts_v) ;
                    -- Clear out that we expect anymore
                    compl_received_v(rx_compl_tag_v) := -1 ;
                    compl_expected_v(rx_compl_tag_v) := -1 ;                    
                    rx_compl_tag_v := -1 ;
                  else
                    -- Have not received all of the data yet, but if the
                    -- completion status is not Successful Completion then we
                    -- need to treat as done
                    if (rx_compl_sts_v /= "000") then
                      -- Report that it is complete to the Driver
                      vc_intf_rpt_compl(rx_compl_tag_v,rx_compl_sts_v) ;
                      -- Clear out that we expect anymore
                      compl_received_v(rx_compl_tag_v) := -1 ;
                      compl_expected_v(rx_compl_tag_v) := -1 ;
                      rx_compl_tag_v := -1 ;
                    end if;
                    -- Otherwise keep going and wait for more data in another completion
                  end if ;
                else
                  if (rx_state_v = RXST_DATA_NONP_WRITE) then
                    rx_state_v := RXST_NONP_REQ ;
                  else
                    rx_state_v := RXST_IDLE ;
                  end if;
                end if;
              else
                if (bcount_v = 0) then
                  ebfm_display
                    (EBFM_MSG_ERROR_FATAL,"Root Port VC" & integer'image(VC_NUM) &
                     " Rx Byte Count went to zero before last data phase." ) ;
                end if;
              end if;
            end if;
          when RXST_NONP_REQ =>
            if (tx_rx_ack = '1') then
              rx_state_v := RXST_IDLE ;
              rx_tx_req_v := '0' ;
            else
              rx_tx_req_v := '1' ;
              rx_state_v := RXST_NONP_REQ ;
            end if;
            rx_ws_v := '1' ; 
          when others => null;
        end case;
      end if ;  
      rx_state <= rx_state_v ;
      rx_ack <= rx_ack_v ;
      rx_ack_int <= rx_ack_v ;
      rx_ws <= rx_ws_v ;
      rx_ws_int <= rx_ws_v ;
      rx_abort <= rx_abort_v ;
      rx_retry <= rx_retry_v  ;
      rx_tx_req <= rx_tx_req_v ;
      rx_tx_desc <= rx_tx_desc_v ;
      rx_tx_shmem_addr <= rx_tx_shmem_addr_v ;
      rx_tx_bcount <= rx_tx_bcount_v ;
      rx_tx_byte_enb <= rx_tx_byte_enb_v ;
    end if;
  end process main_rx_state;

  main_tx_state: process (clk_in)
    variable data_pkt_v : tx_data_array;
    variable dphases_v : natural;
    variable dptr_v : natural;
    variable tx_state_v : tx_states;
    variable rx_mask_v : std_logic;
    variable tx_req_v : std_logic ;
    variable tx_desc_v : std_logic_vector(127 downto 0);
    variable tx_dfr_v : std_logic;
    variable tx_data_v : std_logic_vector(63 downto 0);
    variable tx_dv_v : std_logic;
    variable tx_dv_last_v : std_logic;
    variable tx_err_v : std_logic;
    variable tx_rx_ack_v : std_logic;
    variable lcladdr_v : natural ;
    variable req_ack_cleared_v : std_logic := '1';
    variable req_desc_v : std_logic_vector(127 downto 0);
    variable req_valid_v : std_logic;
    variable imm_data_v : std_logic_vector(31 downto 0);
    variable imm_valid_v : std_logic;
    variable exp_compl_tag_v : integer;
    variable exp_compl_bcount_v : natural;
  Begin  -- process main_tx_state
    if clk_in'event and clk_in = '1' then    -- rising clock edge
      exp_compl_tag_v := -1 ;
      exp_compl_bcount_v := 0 ;
      if rstn = '0' then                -- synchronous reset (active low)
        tx_state_v := TXST_IDLE ;
        rx_mask_v  := '1' ;
        tx_req_v   := '0' ;
        tx_desc_v  := (others => '0') ;
        tx_dfr_v   := '0' ;
        tx_data_v  := (others => '0') ;
        tx_dv_v    := '0' ;
        tx_dv_last_v    := '0' ;
        tx_err_v   := '0' ;
        tx_rx_ack_v := '0' ;
      else
        -- Clear any previous acknowledgement if needed
        if (req_ack_cleared_v = '0') then
          req_ack_cleared_v := vc_intf_clr_ack(VC_NUM) ;
        end if;
        tx_state_v := tx_state ;
        rx_mask_v  := '1' ;             -- This is on in most states
        tx_req_v   := '0' ;
        tx_dfr_v   := '0' ;
        tx_dv_last_v := tx_dv_v ; 
        tx_dv_v    := '0' ;
        tx_rx_ack_v := '0' ;
        case tx_state_v is
          when TXST_IDLE =>
            if (tx_ws = '0') then
              -- Assumes we are getting infinite credits!!!!!
              if (rx_tx_req = '1') then
                rx_mask_v := '0' ;
                tx_state_v := TXST_DESC ;
                tx_desc_v  := rx_tx_desc ;
                tx_req_v   := '1' ;
                tx_rx_ack_v := '1' ;
                if (rx_tx_bcount > 0) then
                  tx_setup_data(rx_tx_shmem_addr,rx_tx_bcount,rx_tx_byte_enb,
                                data_pkt_v,dphases_v) ;
                  dptr_v := 0 ;
                  tx_data_v := (others => '0') ;
                  tx_dv_v := '0' ;
                  tx_dfr_v := '1' ;
                else
                  tx_dv_v := '0' ;
                  tx_dfr_v := '0' ;
                  dphases_v := 0 ;
                end if;
              else
                vc_intf_get_req(VC_NUM,req_valid_v,req_desc_v,lcladdr_v,imm_valid_v,imm_data_v) ;
                if ( (tx_fc_check(req_desc_v,tx_cred)) and
                     (req_valid_v = '1') and
                     (req_ack_cleared_v = '1') ) then
                  vc_intf_set_ack(VC_NUM) ;
                  req_ack_cleared_v := vc_intf_clr_ack(VC_NUM) ;

                  tx_setup_req(req_desc_v,lcladdr_v,imm_valid_v,imm_data_v,data_pkt_v,dphases_v) ;

                  tx_state_v := TXST_DESC ;
                  tx_desc_v  := req_desc_v ;
                  tx_req_v   := '1' ; 

                  if (dphases_v > 0) then
                    dptr_v := 0 ;
                    tx_data_v := (others => '0') ;
                    tx_dv_v := '0' ;
                    tx_dfr_v := '1' ;
                  else
                    tx_dv_v := '0' ;
                    tx_dfr_v := '0' ;
                  end if;
                  if (is_non_posted(req_desc_v)) then
                    exp_compl_tag_v := to_integer(unsigned(req_desc_v(79 downto 72))) ;
                    if (has_data(req_desc_v)) then
                      exp_compl_bcount_v := 0 ;
                    else
                      exp_compl_bcount_v := calc_byte_count(req_desc_v) ;
                    end if;
                  end if;
                else
                  tx_state_v := TXST_IDLE ;
                  rx_mask_v := '0' ;  
                end if;
              end if;
            end if ;
          when  TXST_DESC | TXST_DATA  =>
            -- Handle the Tx Data Signals 
            if ( (dphases_v > 0) and (tx_ws = '0') and (tx_dv_last_v = '1') ) then
              dphases_v := dphases_v - 1 ;
              dptr_v := dptr_v + 1 ;
            end if;
            if (dphases_v > 0) then
              tx_data_v := data_pkt_v(dptr_v) ;
              tx_dv_v := '1' ;
              if (dphases_v > 1)  then
                tx_dfr_v := '1' ;
              else
                tx_dfr_v := '0' ;
              end if;
            else
              tx_data_v := (others => '0') ;
              tx_dv_v   := '0' ;
              tx_dfr_v  := '0' ;
            end if;

            if (tx_state_v = TXST_DESC) then
              if (tx_ack = '1') then
                tx_req_v := '0' ;
                tx_desc_v := (others => '0') ;
                if (dphases_v > 0)  then
                  tx_state_v := TXST_DATA ;
                else
                  tx_state_v := TXST_IDLE ;
                end if;
              else
                tx_req_v := '1' ;
                tx_state_v := TXST_DESC ;
              end if;
            else
              if (dphases_v > 0) then
                tx_state_v := TXST_DATA ;
              else
                tx_state_v := TXST_IDLE ;
              end if;
            end if;
            
          when others => null;
        end case;
      end if;
      tx_state <= tx_state_v ;
      rx_mask  <= rx_mask_v  ;
      tx_req <= tx_req_v  ;
      tx_req_int <= tx_req_v  ;
      tx_desc <= tx_desc_v ;
      tx_dfr <= tx_dfr_v;
      tx_data <= tx_data_v ;
      tx_dv <= tx_dv_v ;
      tx_dv_last <= tx_dv_last_v ;
      tx_err <= tx_err_v ;
      tx_rx_ack <= tx_rx_ack_v;
      exp_compl_tag <= exp_compl_tag_v;
      exp_compl_bcount <= exp_compl_bcount_v  ;
    end if;
  end process main_tx_state; 

  -- purpose: This reflects the reset value in shared variables
  reset_flag: process 
  begin  -- process reset_flag
    if (VC_NUM > 0) then
      wait;                             -- Only one VC needs to do this
    else
      vc_intf_reset_flag(rstn) ;
    end if;
    wait on rstn;
  end process reset_flag;

  perf_monitor: process (clk_in)
    variable tx_pkts   : natural := 0 ;
    variable tx_qwords : natural := 0 ;
    variable rx_pkts   : natural := 0 ;
    variable rx_qwords : natural := 0 ;
    variable rx_dv_last : std_logic  := '0' ;
    variable clr_pndg  : boolean := FALSE ;
  begin  -- process
    if clk_in'event and clk_in = '1' then     -- rising clock edge
      if (vc_intf_sample_perf(VC_NUM) = '1') then
        if not clr_pndg then
          vc_intf_set_perf(VC_NUM,tx_pkts,tx_qwords,rx_pkts,rx_qwords) ;
          tx_pkts := 0 ;
          tx_qwords := 0 ;
          rx_pkts := 0 ;
          rx_qwords := 0 ;
          clr_pndg := TRUE ;
        end if;
      else
        if clr_pndg then
          vc_intf_clr_perf(VC_NUM) ;
          clr_pndg := FALSE ;
        end if; 
      end if;
      if (tx_dv_last = '1') and (tx_ws = '0') then
        tx_qwords := tx_qwords + 1 ; 
      end if;
      if (tx_req_int = '1') and (tx_ack = '1') then
        tx_pkts := tx_pkts + 1 ;
      end if;
      if (rx_dv_last = '1') and (rx_ws_int = '0')  then
        rx_qwords := rx_qwords + 1 ;
      end if;
      if (rx_req = '1') and (rx_ack_int = '1')  then
        rx_pkts := rx_pkts + 1 ; 
      end if;
      rx_dv_last := rx_dv ; 
    end if;
  end process perf_monitor ;
  
end behavioral;
