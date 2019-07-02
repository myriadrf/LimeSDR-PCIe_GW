-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Package for Request Interface 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_req_intf.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This package provides the interface for passing the requests between the
-- Read/Write Request package and ultimately the user's driver and the VC
-- Interface Entitites
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
use std.textio.all;
use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;

package altpcietb_bfm_req_intf is
  
  -- purpose: Sets the Max Payload size variables
  procedure req_intf_set_max_payload (
    constant max_payload_size : in natural;
    constant ep_max_rd_req    : in natural := 0;  -- 0 means use max_payload_size    
    constant rp_max_rd_req    : in natural := 0   -- 0 means use max_payload_size    
    ) ;

  -- purpose: Returns the stored max payload size
  impure function req_intf_max_payload_size
    return natural;
  
  -- purpose: Returns the stored end point max read request size
  impure function req_intf_ep_max_rd_req_size
    return natural;
  
  -- purpose: Returns the stored root port max read request size
  impure function req_intf_rp_max_rd_req_size
    return natural;
  
  -- purpose: procedure to wait until the root port is done being reset
  procedure req_intf_wait_reset_end;
  
  -- purpose: procedure to get a free tag from the pool. Waits for one
  -- to be free if none available initially
  procedure req_intf_get_tag (
    variable tag : out natural;
    constant need_handle : in std_logic := '0';
    constant lcl_addr : in integer := -1) ;

    -- purpose: makes a request pending for the appropriate VC interface
  procedure req_intf_vc_req (
    constant info_v : in std_logic_vector(192 downto 0) ) ;

  -- purpose: Releases a reserved handle
  procedure req_intf_release_handle (
    constant handle : in natural) ;

  -- purpose: Wait for completion on the specified handle
  procedure req_intf_wait_compl (
    constant handle       : in  integer;
    variable compl_status : out std_logic_vector(2 downto 0);
    constant keep_handle  : in std_logic := '0') ;
  
    -- purpose: This gets the pending request (if any) for the specified VC
  procedure vc_intf_get_req (
    constant vc_num    : in  natural;
    variable req_valid : out std_logic;
    variable req_desc  : out std_logic_vector(127 downto 0);
    variable lcladdr : out natural;
    variable imm_valid : out std_logic;
    variable imm_data : out  std_logic_vector(31 downto 0)) ;

  -- purpose: This sets the acknowledgement for a pending request
  procedure vc_intf_set_ack (
    constant vc_num : in natural) ;
  
  -- purpose: This conditionally clears the acknowledgement for a pending request
  --          It only clears the ack if the req valid has been cleared.
  --          Returns '1' if the Ack was cleared, else returns '0'.
  impure function vc_intf_clr_ack (
    constant vc_num : natural)
    return std_logic ;

  -- purpose: This routine is to record the completion of a previous non-posted request
  procedure vc_intf_rpt_compl (
    constant tag    : in natural;
    constant status : in std_logic_vector(2 downto 0)) ;

  -- purpose: This allows the value of the rstn to be reflected in the shared
  -- memory so that these routines can tell if there is a reset in progress.
  procedure vc_intf_reset_flag (
    constant rstn : in std_logic);

  impure function vc_intf_get_lcl_addr (
    constant tag : natural)
    return natural ;

  -- Functions to do the performance sampling
  impure function vc_intf_sample_perf (
    constant vc_num : natural)
    return std_logic;

  procedure vc_intf_set_perf (
    constant vc_num    : in natural;
    constant tx_pkts   : in natural;
    constant tx_qwords : in natural;
    constant rx_pkts   : in natural;
    constant rx_qwords : in natural);

  procedure vc_intf_clr_perf (
    constant vc_num : natural) ;

  procedure req_intf_start_perf_sample ;

  procedure req_intf_disp_perf_sample (
    variable tx_mbit_ps        : out real;
    variable rx_mbit_ps        : out real;
    variable bytes_transmitted : out natural
  ) ; 
  
end altpcietb_bfm_req_intf;

package body altpcietb_bfm_req_intf is

  subtype REQ_INFO_VECTOR is std_logic_vector(192 downto 0);
  type REQ_INFO_ARRAY is array (0 to EBFM_NUM_VC-1) of REQ_INFO_VECTOR;

  shared variable req_info : REQ_INFO_ARRAY := (others => (others => '0'));
  shared variable req_info_valid : std_logic_vector(0 to EBFM_NUM_VC-1) := (others => '0');
  shared variable req_info_ack : std_logic_vector(0 to EBFM_NUM_VC-1) := (others => '0');

  shared variable perf_req : std_logic_vector(0 to EBFM_NUM_VC-1) := (others => '0');
  shared variable perf_ack : std_logic_vector(0 to EBFM_NUM_VC-1) := (others => '0');

  type PERF_INFO_ARRAY is array (0 to EBFM_NUM_VC-1) of natural;
  shared variable perf_tx_pkts : PERF_INFO_ARRAY := (others => 0); 
  shared variable perf_tx_qwords : PERF_INFO_ARRAY := (others => 0); 
  shared variable perf_rx_pkts : PERF_INFO_ARRAY := (others => 0); 
  shared variable perf_rx_qwords : PERF_INFO_ARRAY := (others => 0); 

  shared variable last_perf_timestamp : time := 0 ns ;
  
  type status_array is array (EBFM_NUM_TAG-1 downto 0) of std_logic_vector(2 downto 0);
  type compl_addr_array is array (EBFM_NUM_TAG-1 downto 0) of integer;
  shared variable tag_busy   : std_logic_vector(EBFM_NUM_TAG-1 downto 0) := (others => '0') ;
  shared variable tag_status : status_array := (others => (others => '0'));
  shared variable hnd_busy : std_logic_vector(EBFM_NUM_TAG-1 downto 0) := (others => '0');
  shared variable tag_lcl_addr : compl_addr_array := (others => -1) ; 

  shared variable reset_in_progress : std_logic := '0';
  shared variable num_ps_to_wait : natural := 8000;

  shared variable bfm_max_payload_size : natural := 128;
  shared variable bfm_ep_max_rd_req : natural := 128;
  shared variable bfm_rp_max_rd_req : natural := 128;

  -- This variable holds the TC to VC mapping
  type tc2vc_table is array (0 to 7) of natural;
  shared variable tc2vc_map : tc2vc_table := (others => 0);

  -- purpose: Sets the Max Payload size variables
  procedure req_intf_set_max_payload (
    constant max_payload_size : in natural;
    constant ep_max_rd_req    : in natural := 0;  -- 0 means use max_payload_size    
    constant rp_max_rd_req    : in natural := 0   -- 0 means use max_payload_size    
    ) is
  begin  -- set_max_payload
    bfm_max_payload_size := max_payload_size ;
    if (ep_max_rd_req > 0) then
      bfm_ep_max_rd_req := ep_max_rd_req ;
    else
      bfm_ep_max_rd_req := max_payload_size ;      
    end if;
    if (rp_max_rd_req > 0) then
      bfm_rp_max_rd_req := rp_max_rd_req ;
    else
      bfm_rp_max_rd_req := max_payload_size ;      
    end if;
  end req_intf_set_max_payload;
  
  -- purpose: Returns the stored max payload size
  impure function req_intf_max_payload_size
    return natural is
  begin
    return bfm_max_payload_size;
  end function req_intf_max_payload_size ;
  
  -- purpose: Returns the stored end point max read request size
  impure function req_intf_ep_max_rd_req_size
    return natural is
  begin 
    return bfm_ep_max_rd_req;
  end function req_intf_ep_max_rd_req_size ;
  
  -- purpose: Returns the stored root port max read request size
  impure function req_intf_rp_max_rd_req_size
    return natural is
  begin 
    return bfm_rp_max_rd_req;
  end function req_intf_rp_max_rd_req_size ;
  
  -- purpose: procedure to wait until the root port is done being reset
  procedure req_intf_wait_reset_end is
  begin
    while (reset_in_progress = '1') loop
      wait for num_ps_to_wait * 1 ps;
    end loop;
  end procedure req_intf_wait_reset_end ;

  -- purpose: procedure to get a free tag from the pool. Waits for one
  -- to be free if none available initially
  procedure req_intf_get_tag (
    variable tag : out natural;
    constant need_handle : in std_logic := '0';
    constant lcl_addr : in integer := -1) is
    variable tag_v : natural := EBFM_NUM_TAG ;
  begin  -- req_intf_get_tag
    -- Find a tag to use
    main_tloop : while ( (tag_v > EBFM_NUM_TAG-1) and (reset_in_progress = '0') ) loop
      sub_tloop : for i in 0 to EBFM_NUM_TAG-1 loop
        if ( (tag_busy(i) = '0') and (hnd_busy(i) = '0') ) then
          tag_busy(i) := '1' ;
          hnd_busy(i) := need_handle ;
          tag_lcl_addr(i) := lcl_addr ;
          tag_v := i ;
          exit main_tloop;
        end if;
      end loop;  -- i
      wait for (num_ps_to_wait * 1 ps) ;
    end loop;
    if (reset_in_progress = '1') then
      tag := EBFM_NUM_TAG ;
    else
      tag := tag_v ;      
    end if;

  end req_intf_get_tag;

  -- purpose: makes a request pending for the appropriate VC interface
  procedure req_intf_vc_req (
    constant info_v : in std_logic_vector(192 downto 0) ) is
    variable vcnum : natural;
  begin
    -- Get the Virtual Channel Number from the Traffic Class Number
    vcnum := tc2vc_map(TO_INTEGER(UNSIGNED(info_v(118 downto 116)))) ;
    if (vcnum >= EBFM_NUM_VC) then
      ebfm_display
        (EBFM_MSG_ERROR_FATAL,"Attempt to transmit Packet with TC mapped to unsupported VC." &
         "TC: " & integer'image(TO_INTEGER(UNSIGNED(info_v(118 downto 116)))) &
         ",VC: " & integer'image(vcnum)) ;
    end if;
    
    -- Make sure the ACK from any previous requests are cleared
    while ( (req_info_ack(vcnum) = '1') and (reset_in_progress = '0') ) loop
      wait for (num_ps_to_wait * 1 ps);
    end loop;
    if (reset_in_progress = '1') then
      return;
    end if;

    -- Make the Request
    req_info(vcnum) := info_v ;
    req_info_valid(vcnum) := '1' ;

    -- Now wait for it to be acknowledged
    while ( (req_info_ack(vcnum) = '0')  and (reset_in_progress = '0') ) loop
      wait for (num_ps_to_wait * 1 ps);
    end loop;

    -- Clear the request
    req_info(vcnum) := (others => '0') ;
    req_info_valid(vcnum) := '0' ;

  end procedure req_intf_vc_req ;   

  -- purpose: Releases a reserved handle
  procedure req_intf_release_handle (
    constant handle : in natural) is
  begin  -- req_intf_release_handle
    if (hnd_busy(handle) /= '1') then
      ebfm_display
        (EBFM_MSG_ERROR_FATAL,"Attempt to release Handle " &
         integer'image(handle) & "that is not reserved.") ;
    end if;
    hnd_busy(handle) := '0' ;
  end req_intf_release_handle;

  -- purpose: Wait for completion on the specified handle
  procedure req_intf_wait_compl (
    constant handle       : in  integer;
    variable compl_status : out std_logic_vector(2 downto 0);
    constant keep_handle  : in std_logic := '0') is
  begin
    if (hnd_busy(handle) /= '1') then
      ebfm_display
        (EBFM_MSG_ERROR_FATAL,"Attempt to wait for completion on Handle " &
         integer'image(handle) & "that is not reserved.") ;
    end if;
    while ( (reset_in_progress = '0') and (tag_busy(handle) = '1') )  loop
      wait for (num_ps_to_wait * 1 ps);
    end loop;

    if (tag_busy(handle) = '0') then
      compl_status := tag_status(handle) ;
    else
      compl_status := "UUU" ;
    end if;

    if (keep_handle /= '1') then
      req_intf_release_handle(handle) ;
    end if;
    
  end req_intf_wait_compl ;

  
  -- purpose: This gets the pending request (if any) for the specified VC
  procedure vc_intf_get_req (
    constant vc_num    : in  natural;
    variable req_valid : out std_logic;
    variable req_desc  : out std_logic_vector(127 downto 0);
    variable lcladdr : out natural;
    variable imm_valid : out std_logic;
    variable imm_data : out  std_logic_vector(31 downto 0)) is
  begin  -- vc_intf_get_req
    req_desc := req_info(vc_num)(127 downto 0) ;
    lcladdr  := to_integer(unsigned(req_info(vc_num)(159 downto 128))) ;
    imm_data := req_info(vc_num)(191 downto 160) ;
    imm_valid := req_info(vc_num)(192) ;
    req_valid := req_info_valid(vc_num) ;
  end vc_intf_get_req;

  -- purpose: This sets the acknowledgement for a pending request
  procedure vc_intf_set_ack (
    constant vc_num : in natural) is
  begin
    if (req_info_valid(vc_num) /= '1') then
      ebfm_display
        (EBFM_MSG_ERROR_FATAL,"VC Interface " & integer'image(vc_num) &
         " tried to ACK a request that is not there.") ; 
    end if ;
    if (req_info_ack(vc_num) /= '0') then
      ebfm_display
        (EBFM_MSG_ERROR_FATAL,"VC Interface " & integer'image(vc_num) &
         " tried to ACK a request a second time.") ;       
    end if;
    req_info_ack(vc_num) := '1' ;
  end vc_intf_set_ack ;

  -- purpose: This conditionally clears the acknowledgement for a pending request
  --          It only clears the ack if the req valid has been cleared.
  --          Returns '1' if the Ack was cleared, else returns '0'.
  impure function vc_intf_clr_ack (
    constant vc_num : natural)
    return std_logic is
  begin
    if (req_info_valid(vc_num) = '0') then
      req_info_ack(vc_num) := '0' ;
      return '1';
    else
      return '0';
    end if;
  end vc_intf_clr_ack ;

  -- purpose: This routine is to record the completion of a previous non-posted request
  procedure vc_intf_rpt_compl (
    constant tag    : in natural;
    constant status : in std_logic_vector(2 downto 0)) is
  begin  -- vc_intf_rpt_compl
    tag_status(tag) := status ;
    if (tag_busy(tag) /= '1') then
      ebfm_display(EBFM_MSG_ERROR_FATAL,"Tried to clear a tag that was not busy. Tag: " &
                   integer'image(tag)) ;
    end if ;  
    tag_busy(tag) := '0' ;
  end vc_intf_rpt_compl;
  
  procedure vc_intf_reset_flag (
    constant rstn : in std_logic) is
  begin
    reset_in_progress := not rstn ;
  end procedure vc_intf_reset_flag ;

  impure function vc_intf_get_lcl_addr (
    constant tag : natural)
    return natural is
  begin  -- vc_intf_get_lcl_addr
    if ( (tag_lcl_addr(tag) /= -1) and
         ( (tag_busy(tag) = '1') or
           (hnd_busy(tag) = '1') ) ) then
      return tag_lcl_addr(tag) ;
    else
      ebfm_display(EBFM_MSG_ERROR_FATAL,"Attempt to access invalid local address for Tag: " &
                   integer'image(tag)) ;
      return natural'high ;
    end if;
  end vc_intf_get_lcl_addr;
  
  impure function vc_intf_sample_perf (
    constant vc_num : natural)
    return std_logic is
  begin
   return perf_req(vc_num);
  end vc_intf_sample_perf ;

  procedure vc_intf_set_perf (
    constant vc_num    : in natural;
    constant tx_pkts   : in natural;
    constant tx_qwords : in natural;
    constant rx_pkts   : in natural;
    constant rx_qwords : in natural) is
  begin
    perf_tx_pkts(vc_num)   := tx_pkts ;
    perf_tx_qwords(vc_num) := tx_qwords ;
    perf_rx_pkts(vc_num)   := rx_pkts ;
    perf_rx_qwords(vc_num) := rx_qwords ;
    perf_ack(vc_num)       := '1' ;
  end vc_intf_set_perf ;

  procedure vc_intf_clr_perf (
    constant vc_num : natural) is
  begin
    perf_ack(vc_num) := '0' ;
  end vc_intf_clr_perf ;

  procedure req_intf_start_perf_sample is
  begin  -- req_intf_start_perf_sample
    perf_req := (others => '1') ;
    last_perf_timestamp := now;
    while (perf_req /= "0000") loop
      wait for num_ps_to_wait * 1 ps;
      for i in 0 to EBFM_NUM_VC-1 loop
        if (perf_ack(i) = '1') then
          perf_req(i) := '0' ;
        end if;
      end loop;  -- i
    end loop;
  end req_intf_start_perf_sample;

  procedure req_intf_disp_perf_sample (
    variable tx_mbit_ps        : out real;
    variable rx_mbit_ps        : out real;
    variable bytes_transmitted : out natural
  ) is
    variable total_tx_qwords : natural := 0;
    variable total_tx_pkts   : natural := 0;
    variable total_rx_qwords : natural := 0;
    variable total_rx_pkts   : natural := 0;
    variable tx_mbyte_ps     : real;
    variable rx_mbyte_ps     : real;
    variable tx_mbit_ps_v    : real;
    variable rx_mbit_ps_v    : real;
    variable delta_time      : time;
    variable delta_ns        : integer;
  begin  -- req_intf_disp_perf_sample
    delta_time := now - last_perf_timestamp ;
    delta_ns   := delta_time / 1 ns ;
    req_intf_start_perf_sample ;
    for i in 0 to EBFM_NUM_VC-1 loop
      total_tx_qwords := total_tx_qwords + perf_tx_qwords(i) ;
      total_tx_pkts   := total_tx_pkts   + perf_tx_pkts(i) ;
      total_rx_qwords := total_rx_qwords + perf_rx_qwords(i) ;
      total_rx_pkts   := total_rx_pkts   + perf_rx_pkts(i) ;
    end loop;  -- i

    tx_mbyte_ps := real(total_tx_qwords * 8) / (real(delta_ns) / 1000.0) ;
    rx_mbyte_ps := real(total_rx_qwords * 8) / (real(delta_ns) / 1000.0) ;
    tx_mbit_ps_v  := tx_mbyte_ps * 8.0 ;
    rx_mbit_ps_v  := rx_mbyte_ps * 8.0 ;
    bytes_transmitted := total_tx_qwords*8;
    
    ebfm_display(EBFM_MSG_INFO,
                 "PERF: Sample Duration: " &
                 integer'image(delta_ns) &
                 " ns") ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:      Tx Packets: " &
                 integer'image(total_tx_pkts)) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:        Tx Bytes: " &
                 integer'image(total_tx_qwords * 8)) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:    Tx MByte/sec: " &
                 integer'image(integer(tx_mbyte_ps))) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:     Tx Mbit/sec: " &
                 integer'image(integer(tx_mbit_ps_v))) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:      Rx Packets: " &
                 integer'image(total_rx_pkts)) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:        Rx Bytes: " &
                 integer'image(total_rx_qwords * 8)) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:    Rx MByte/sec: " &
                 integer'image(integer(rx_mbyte_ps))) ;
    ebfm_display(EBFM_MSG_INFO,
                 "PERF:     Rx Mbit/sec: " &
                 integer'image(integer(rx_mbit_ps_v))) ;
    
    tx_mbit_ps := tx_mbit_ps_v ;  
    rx_mbit_ps := rx_mbit_ps_v ;  
    
  end req_intf_disp_perf_sample;
  
end altpcietb_bfm_req_intf;
