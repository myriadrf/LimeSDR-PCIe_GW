-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Package of Read/Write Routines
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_rdwr.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This packeage provides all of the PCI Express BFM Read, Write and Utility
-- Routines.
-------------------------------------------------------------------------------
-- Copyright (c) 2009 Altera Corporation. All rights reserved.  Altera products are
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
use work.altpcietb_bfm_req_intf.all;
use work.altpcietb_bfm_shmem.all;

package altpcietb_bfm_rdwr is

  -- purpose: write BFM memory data to endpoint BAR offset
  procedure ebfm_barwr (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) ;

  -- purpose: write immediate data to endpoint BAR offset
  procedure ebfm_barwr_imm (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant imm_data  : in std_logic_vector(31 downto 0);
    constant byte_len  : in natural := 4;
    constant tclass : in natural := 0
    ) ;

  -- purpose: Read data from endpoint BAR offset to BFM Memory,
  --          Wait for completion
  procedure ebfm_barrd_wait (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) ;

  -- purpose: Read data from endpoint BAR offset to BFM Memory,
  --          Do not wait for completion
  procedure ebfm_barrd_nowt (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) ;

  -- purpose: Configuration Read that waits for completion
  procedure ebfm_cfgrd_wait (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant lcladdr : in natural;
    variable compl_status : out std_logic_vector(2 downto 0)
    ) ;

  -- purpose: Configuration Read that does not wait
  --          Need to assume completes okay and is known to be done by the
  --          time a subsequent read completes.
  procedure ebfm_cfgrd_nowt (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant lcladdr : in natural
    ) ;

  -- purpose: Configuration Write, Immediate Data, that waits for completion automatically
  procedure ebfm_cfgwr_imm_wait (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant imm_data : in std_logic_vector(31 downto 0) := (others => '0');
    variable compl_status : out std_logic_vector(2 downto 0)
    ) ;

  -- purpose: Configuration Write, Immediate Data, no wait, no handle
  procedure ebfm_cfgwr_imm_nowt (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant imm_data : in std_logic_vector(31 downto 0) := (others => '0')
    )  ;

  procedure rdwr_start_perf_sample;

  procedure rdwr_disp_perf_sample (
    variable tx_mbit_ps : out real;
    variable rx_mbit_ps : out real;
    variable bytes_transmitted: out natural
    ) ;

end altpcietb_bfm_rdwr;

package body altpcietb_bfm_rdwr is

  function ebfm_calc_firstbe (
    constant byte_address : natural;
    constant byte_length  : natural)
    return std_logic_vector is
  begin
    case (byte_address mod 4) is
      when 0 =>
        case (byte_length) is
          when 0 => return "0000";
          when 1 => return "0001";
          when 2 => return "0011";
          when 3 => return "0111";
          when others => return "1111";
        end case;
      when 1 =>
        case (byte_length) is
          when 0 => return "0000";
          when 1 => return "0010";
          when 2 => return "0110";
          when others => return "1110";
        end case;
      when 2 =>
        case (byte_length) is
          when 0 => return "0000";
          when 1 => return "0100";
          when others => return "1100";
        end case;
      when 3 =>
        case (byte_length) is
          when 0 => return "0000";
          when others => return "1000";
        end case;
      when others => return "0000";
    end case;
  end function ebfm_calc_firstbe ;

  function ebfm_calc_lastbe (
    constant byte_address : natural;
    constant byte_length  : natural)
    return std_logic_vector is
  begin
    if ( (byte_address mod 4) + byte_length > 4) then
      case ((byte_address + byte_length) mod 4) is
        when 0 => return "1111" ;
        when 3 => return "0111" ;
        when 2 => return "0011" ;
        when 1 => return "0001" ;
        when others => return "XXXX";
      end case;
    else
      return "0000";
    end if;
  end function ebfm_calc_lastbe ;

  -- purpose: This is the full featured configuration read that has all
  -- optional behavior via the arguments
  procedure ebfm_cfgrd (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant lcladdr : in natural;
    constant compl_wait : in std_logic := '0';
    constant need_handle : in std_logic := '0';
    variable compl_status : out std_logic_vector(2 downto 0);
    variable handle  : out integer) is
    variable info_v : std_logic_vector(192 downto 0) := (others => '0');
    variable tag_v  : natural := 9999 ;
    variable i_need_handle : std_logic ;
  begin
    -- Get a TAG
    i_need_handle := compl_wait or need_handle ;
    req_intf_get_tag(tag_v,i_need_handle,lcladdr) ;

    -- Assemble the request
    if ( (bus_num = RP_PRI_BUS_NUM) and (dev_num = RP_PRI_DEV_NUM) ) then
      info_v(127 downto 120) := X"04" ;  -- CfgRd0
    else
      info_v(127 downto 120) := X"05" ;  -- CfgRd1
    end if;
    info_v(119 downto 112) := X"00" ;   -- R, TC, RRRR fields all 0
    info_v(111 downto 104) := X"00" ;   -- TD, EP, Attr, RR, LL all 0
    info_v(103 downto 96)  := X"01" ;   -- Length 1 DW
    info_v(95  downto 80)  := RP_REQ_ID ;  -- Requester ID
    info_v(79  downto 72)  := std_logic_vector(to_unsigned(tag_v,8)) ;
    info_v(71  downto 68)  := X"0" ;    -- Last DW BE
    info_v(67  downto 64)  := ebfm_calc_firstbe(regb_ad,regb_ln) ;
    info_v(63  downto 56)  := std_logic_vector(to_unsigned(bus_num,8)) ;
    info_v(55  downto 51)  := std_logic_vector(to_unsigned(dev_num,5)) ;
    info_v(50  downto 48)  := std_logic_vector(to_unsigned(fnc_num,3)) ;
    info_v(47  downto 44)  := X"0" ;    -- RRRR
    info_v(43  downto 34)  := std_logic_vector(to_unsigned(regb_ad/4,10)) ;
    info_v(33  downto 32)  := "00" ;    -- RR

    -- Make the request
    req_intf_vc_req(info_v) ;

    -- Wait for completion if specified to do so
    if (compl_wait = '1') then
      req_intf_wait_compl(tag_v,compl_status,need_handle) ;
    else
      compl_status := "UUU" ;
    end if;

    -- Return the handle
    if (need_handle = '0') then
      handle := -1 ;
    else
      handle := tag_v ;
    end if;


  end procedure ebfm_cfgrd ;

  -- purpose: Configuration Read that waits for completion automatically
  procedure ebfm_cfgrd_wait (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant lcladdr : in natural;
    variable compl_status : out std_logic_vector(2 downto 0)
    ) is
    variable dum_hnd : integer;
  begin
    ebfm_cfgrd(bus_num,dev_num,fnc_num,regb_ad,regb_ln,lcladdr,
                  '1','0',compl_status,dum_hnd) ;
  end procedure ebfm_cfgrd_wait ;

  -- purpose: Configuration Read that does not wait, does not return handle
  --          Need to assume completes okay and is known to be done by the
  --          time a subsequent read completes.
  procedure ebfm_cfgrd_nowt (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant lcladdr : in natural
    ) is
    variable dum_hnd : integer;
    variable dum_sts : std_logic_vector(2 downto 0) ;
  begin
    ebfm_cfgrd(bus_num,dev_num,fnc_num,regb_ad,regb_ln,lcladdr,
                  '0','0',dum_sts,dum_hnd) ;
  end procedure ebfm_cfgrd_nowt ;

  -- purpose: This is the full featured configuration write that has all
  -- optional behavior via the arguments
  procedure ebfm_cfgwr (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant lcladdr : in natural;
    constant imm_valid : in std_logic := '0';
    constant imm_data : in std_logic_vector(31 downto 0) := (others => '0');
    constant compl_wait : in std_logic := '0';
    constant need_handle : in std_logic := '0';
    variable compl_status : out std_logic_vector(2 downto 0);
    variable handle  : out integer
    ) is
    variable info_v : std_logic_vector(192 downto 0) := (others => '0');
    variable tag_v  : natural := 9999 ;
    variable i_need_handle : std_logic ;
  begin
    -- Get a TAG
    i_need_handle := compl_wait or need_handle ;
    req_intf_get_tag(tag_v,i_need_handle,-1) ;

    -- Assemble the request
    info_v(192) := imm_valid ;
    info_v(191 downto 160) := imm_data ;
    info_v(159 downto 128) := std_logic_vector(to_unsigned(lcladdr,32)) ;
    if ( (bus_num = RP_PRI_BUS_NUM) and (dev_num = RP_PRI_DEV_NUM) ) then
      info_v(127 downto 120) := X"44" ;  -- CfgWr0
    else
      info_v(127 downto 120) := X"45" ;  -- CfgWr1
    end if;
    info_v(119 downto 112) := X"00" ;   -- R, TC, RRRR fields all 0
    info_v(111 downto 104) := X"00" ;   -- TD, EP, Attr, RR, LL all 0
    info_v(103 downto 96)  := X"01" ;   -- Length 1 DW
    info_v(95  downto 80)  := RP_REQ_ID ;  -- Requester ID
    info_v(79  downto 72)  := std_logic_vector(to_unsigned(tag_v,8)) ;
    info_v(71  downto 68)  := X"0" ;    -- Last DW BE
    info_v(67  downto 64)  := ebfm_calc_firstbe(regb_ad,regb_ln) ;
    info_v(63  downto 56)  := std_logic_vector(to_unsigned(bus_num,8)) ;
    info_v(55  downto 51)  := std_logic_vector(to_unsigned(dev_num,5)) ;
    info_v(50  downto 48)  := std_logic_vector(to_unsigned(fnc_num,3)) ;
    info_v(47  downto 44)  := X"0" ;    -- RRRR
    info_v(43  downto 34)  := std_logic_vector(to_unsigned(regb_ad/4,10)) ;
    info_v(33  downto 32)  := "00" ;    -- RR

    -- Make the request
    req_intf_vc_req(info_v) ;

    -- Wait for completion if specified to do so
    if (compl_wait = '1') then
      req_intf_wait_compl(tag_v,compl_status,need_handle) ;
    else
      compl_status := "UUU" ;
    end if;

    -- Return the handle
    if (need_handle = '0') then
      handle := -1 ;
    else
      handle := tag_v ;
    end if;
  end procedure ebfm_cfgwr ;

  -- purpose: Configuration Write, Immediate Data, that waits for completion automatically
  procedure ebfm_cfgwr_imm_wait (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant imm_data : in std_logic_vector(31 downto 0) := (others => '0');
    variable compl_status : out std_logic_vector(2 downto 0)
    ) is
    variable dum_hnd : integer;
  begin
    ebfm_cfgwr(bus_num,dev_num,fnc_num,regb_ad,regb_ln,0,'1',imm_data,
                  '1','0',compl_status,dum_hnd) ;
  end procedure ebfm_cfgwr_imm_wait ;

  -- purpose: Configuration Write, Immediate Data, no wait, no handle
  procedure ebfm_cfgwr_imm_nowt (
    constant bus_num : in natural;
    constant dev_num : in natural;
    constant fnc_num : in natural;
    constant regb_ad : in natural;
    constant regb_ln : in natural;
    constant imm_data : in std_logic_vector(31 downto 0) := (others => '0')
    ) is
    variable dum_sts : std_logic_vector(2 downto 0);
    variable dum_hnd : integer;
  begin
    ebfm_cfgwr(bus_num,dev_num,fnc_num,regb_ad,regb_ln,0,'1',imm_data,
                  '0','0',dum_sts,dum_hnd) ;
  end procedure ebfm_cfgwr_imm_nowt ;

  function calc_dw_len (
    constant byte_adr : in natural;
    constant byte_len : in natural
    ) return std_logic_vector is
    variable adr_len : natural;
    variable dw_len : unsigned(9 downto 0);
  begin  -- calc_dw_len
    adr_len := byte_len + (byte_adr mod 4) ;
    if (adr_len mod 4 = 0) then
      dw_len := to_unsigned((adr_len/4),dw_len'length) ;
    else
      dw_len := to_unsigned(((adr_len/4)+1),dw_len'length) ;
    end if;
    return std_logic_vector(dw_len);
  end function calc_dw_len ;

  procedure ebfm_memwr (
    constant pcie_addr : in std_logic_vector(63 downto 0);
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) is
    variable info_v : std_logic_vector(192 downto 0) := (others => '0');
    variable baddr_v : natural ;
  begin  -- ebfm_memwr
    baddr_v := to_integer(unsigned(pcie_addr(11 downto 0))) ;

    -- Assemble the request
    info_v(159 downto 128) := std_logic_vector(to_unsigned(lcladdr,32)) ;
    if (pcie_addr(63 downto 32) = X"00000000") then
      info_v(127 downto 120) := X"40" ;  -- 3DW Header w/Data MemWr
      info_v(63 downto 34) := pcie_addr(31 downto 2) ;
      info_v(31 downto 0)  := (others => '0') ;
    else
      info_v(127 downto 120) := X"60" ;  -- 4DW Header w/Data MemWr
      info_v(63 downto 2) := pcie_addr(63 downto 2) ;
    end if;
    info_v(119)            := '0' ;     -- Reserved bit
    info_v(118 downto 116) := std_logic_vector(to_unsigned(tclass,3)) ;
    info_v(115 downto 112) := X"0" ;    -- Reserved bits all 0
    info_v(111 downto 106) := "000000" ; -- TD, EP, Attr, RR all 0
    info_v(105 downto 96)  := calc_dw_len(baddr_v,byte_len) ;
    info_v(95  downto 80)  := RP_REQ_ID ;  -- Requester ID
    info_v(79  downto 72)  := std_logic_vector(to_unsigned(0,8)) ;
    info_v(71  downto 68)  := ebfm_calc_lastbe(baddr_v,byte_len) ;
    info_v(67  downto 64)  := ebfm_calc_firstbe(baddr_v,byte_len) ;

    -- Make the request
    req_intf_vc_req(info_v) ;

  end ebfm_memwr;

  procedure ebfm_memwr_imm (
    constant pcie_addr : in std_logic_vector(63 downto 0);
    constant imm_data : in std_logic_vector(31 downto 0);
    constant byte_len  : in natural := 4;
    constant tclass : in natural := 0
    ) is
    variable info_v : std_logic_vector(192 downto 0) := (others => '0');
    variable baddr_v : natural ;
  begin  -- ebfm_memwr_imm
    baddr_v := to_integer(unsigned(pcie_addr(11 downto 0))) ;

    -- Assemble the request
    info_v(192) := '1' ;
    info_v(191 downto 160) := imm_data ;
    if (pcie_addr(63 downto 32) = X"00000000") then
      info_v(127 downto 120) := X"40" ;  -- 3DW Header w/Data MemWr
      info_v(63 downto 34) := pcie_addr(31 downto 2) ;
      info_v(31 downto 0)  := (others => '0') ;
    else
      info_v(127 downto 120) := X"60" ;  -- 4DW Header w/Data MemWr
      info_v(63 downto 2) := pcie_addr(63 downto 2) ;
    end if;
    info_v(119)            := '0' ;     -- Reserved bit
    info_v(118 downto 116) := std_logic_vector(to_unsigned(tclass,3)) ;
    info_v(115 downto 112) := X"0" ;    -- Reserved bits all 0
    info_v(111 downto 106) := "000000" ;   -- TD, EP, Attr, RR all 0
    info_v(105 downto 96)  := calc_dw_len(baddr_v,byte_len) ;
    info_v(95  downto 80)  := RP_REQ_ID ;  -- Requester ID
    info_v(79  downto 72)  := std_logic_vector(to_unsigned(0,8)) ;
    info_v(71  downto 68)  := ebfm_calc_lastbe(baddr_v,byte_len) ;
    info_v(67  downto 64)  := ebfm_calc_firstbe(baddr_v,byte_len) ;

    -- Make the request
    req_intf_vc_req(info_v) ;

  end ebfm_memwr_imm;

  -- purpose: This is the full featured memory read that has all
  -- optional behavior via the arguments
  procedure ebfm_memrd (
    constant pcie_addr : in std_logic_vector(63 downto 0);
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass    : in natural := 0;
    constant compl_wait : in std_logic := '0';
    constant need_handle : in std_logic := '0';
    variable compl_status : out std_logic_vector(2 downto 0);
    variable handle  : out integer) is
    variable info_v : std_logic_vector(192 downto 0) := (others => '0');
    variable tag_v  : natural := 9999 ;
    variable i_need_handle : std_logic ;
    variable baddr_v : natural ;
  begin
    -- Get a TAG
    i_need_handle := compl_wait or need_handle ;
    req_intf_get_tag(tag_v,i_need_handle,lcladdr) ;

    baddr_v := to_integer(unsigned(pcie_addr(11 downto 0))) ;

    -- Assemble the request
    info_v(159 downto 128) := std_logic_vector(to_unsigned(lcladdr,32)) ;
    if (pcie_addr(63 downto 32) = X"00000000") then
      info_v(127 downto 120) := X"00" ;  -- 3DW Header w/o Data MemWr
      info_v(63 downto 34) := pcie_addr(31 downto 2) ;
      info_v(31 downto 0)  := (others => '0') ;
    else
      info_v(127 downto 120) := X"20" ;  -- 4DW Header w/o Data MemWr
      info_v(63 downto 2) := pcie_addr(63 downto 2) ;
    end if;
    info_v(119)            := '0' ;     -- Reserved bit
    info_v(118 downto 116) := std_logic_vector(to_unsigned(tclass,3)) ;
    info_v(115 downto 112) := X"0" ;    -- Reserved bits all 0
    info_v(111 downto 106) := "000000" ;   -- TD, EP, Attr, RR all 0
    info_v(105 downto 96)  := calc_dw_len(baddr_v,byte_len) ;
    info_v(95  downto 80)  := RP_REQ_ID ;  -- Requester ID
    info_v(79  downto 72)  := std_logic_vector(to_unsigned(tag_v,8)) ;
    info_v(71  downto 68)  := ebfm_calc_lastbe(baddr_v,byte_len) ;
    info_v(67  downto 64)  := ebfm_calc_firstbe(baddr_v,byte_len) ;

    -- Make the request
    req_intf_vc_req(info_v) ;

    -- Wait for completion if specified to do so
    if (compl_wait = '1') then
      req_intf_wait_compl(tag_v,compl_status,need_handle) ;
    else
      compl_status := "UUU" ;
    end if;

    -- Return the handle
    if (need_handle = '0') then
      handle := -1 ;
    else
      handle := tag_v ;
    end if;

  end procedure ebfm_memrd ;

  procedure ebfm_barwr (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) is
    variable cbar : unsigned(63 downto 0) ;
    variable rem_len : natural := byte_len ;
    variable offset : natural := 0;
    variable cur_len : natural;
    variable paddr : unsigned(63 downto 0) ;
  begin
    cbar := unsigned(shmem_read(bar_table+(bar_num*4),8)) ;
    if ( (cbar(0) = '1') or (cbar(2) = '0') ) then
      cbar(63 downto 32) := (others => '0') ;
    end if;
    paddr := (cbar(63 downto 4) & "0000") + pcie_offset ;
    while (rem_len > 0) loop
      if (cbar(0) = '1') then
        ebfm_display(EBFM_MSG_ERROR_FATAL,"Accessing I/O or ROM BAR is unsupported") ;
      else
        cur_len := req_intf_max_payload_size - to_integer(paddr(1 downto 0)) ;
        if (cur_len > rem_len) then
          cur_len := rem_len ;
        end if;
        if (((paddr mod 4096) + cur_len) > 4096) then
          cur_len := 4096 - to_integer(paddr mod 4096) ;
        end if;
        ebfm_memwr(std_logic_vector(paddr),lcladdr+offset,cur_len,tclass) ;
      end if;
      offset := offset + cur_len ;
      rem_len := rem_len - cur_len ;
      paddr := paddr + cur_len ;
    end loop;

  end procedure ebfm_barwr ;

  procedure ebfm_barwr_imm (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant imm_data  : in std_logic_vector(31 downto 0);
    constant byte_len  : in natural := 4;
    constant tclass : in natural := 0
    ) is
    variable cbar : unsigned(63 downto 0) ;
  begin
    cbar := unsigned(shmem_read(bar_table+(bar_num*4),8)) ;
    if ( (cbar(0) = '1') or (cbar(2) = '0') ) then
      cbar(63 downto 32) := (others => '0') ;
    end if;
    if (cbar(0) = '1') then
      ebfm_display(EBFM_MSG_ERROR_FATAL,"Accessing I/O or ROM BAR is unsupported") ;
    else
      cbar(3 downto 0) := "0000" ;
      cbar := cbar + pcie_offset ;
      ebfm_memwr_imm(std_logic_vector(cbar),imm_data,byte_len,tclass) ;
    end if;

  end procedure ebfm_barwr_imm ;

  procedure ebfm_barrd (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0;
    constant compl_wait : in std_logic := '0';
    constant need_handle : in std_logic := '0';
    variable compl_status : out std_logic_vector(2 downto 0);
    variable handle  : out integer    ) is
    variable dum_status : std_logic_vector(2 downto 0);
    variable dum_handle  : integer ;
    variable cbar : unsigned(63 downto 0) ;
    variable rem_len : natural := byte_len ;
    variable offset : natural := 0;
    variable cur_len : natural;
    variable paddr : unsigned(63 downto 0) ;
  begin  -- ebfm_barrd
    cbar := unsigned(shmem_read(bar_table+(bar_num*4),8)) ;
    if ( (cbar(0) = '1') or (cbar(2) = '0') ) then
      cbar(63 downto 32) := (others => '0') ;
    end if;
    paddr := (cbar(63 downto 4) & "0000") + pcie_offset ;
    while (rem_len > 0) loop
      if (cbar(0) = '1') then
        ebfm_display(EBFM_MSG_ERROR_FATAL,"Accessing I/O or ROM BAR is unsupported") ;
      else
        -- Need to make sure we don't cross a DW boundary
        cur_len := req_intf_rp_max_rd_req_size  - to_integer(paddr(1 downto 0)) ;
        if (cur_len > rem_len) then
          cur_len := rem_len ;
        end if;
        if (((paddr mod 4096) + cur_len) > 4096) then
          cur_len := 4096 - to_integer(paddr mod 4096) ;
        end if;
        if (rem_len = cur_len) then
          -- If it is the last one use the passed in compl/handle parms
          ebfm_memrd(std_logic_vector(paddr),lcladdr+offset,cur_len,tclass,compl_wait,need_handle,compl_status,handle) ;
        else
          -- Otherwise no wait, assume it all completes and the final one
          -- pushes ahead
          ebfm_memrd(std_logic_vector(paddr),lcladdr+offset,cur_len,tclass,'0','0',dum_status,dum_handle) ;
        end if;
      end if;
      offset := offset + cur_len ;
      rem_len := rem_len - cur_len ;
      paddr := paddr + cur_len ;
    end loop ;
  end procedure ebfm_barrd ;

  procedure ebfm_barrd_wait (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) is
    variable dum_status : std_logic_vector(2 downto 0) ;
    variable dum_handle : integer;
  begin  -- ebfm_barrd_wait
    ebfm_barrd(bar_table,bar_num,pcie_offset,lcladdr,byte_len,tclass,'1','0',dum_status,dum_handle) ;
  end ebfm_barrd_wait;

  procedure ebfm_barrd_nowt (
    constant bar_table : in natural;
    constant bar_num   : in natural;
    constant pcie_offset : in natural;
    constant lcladdr   : in natural;
    constant byte_len  : in natural;
    constant tclass : in natural := 0
    ) is
    variable dum_status : std_logic_vector(2 downto 0) ;
    variable dum_handle : integer;
  begin  -- ebfm_barrd_nowt
    ebfm_barrd(bar_table,bar_num,pcie_offset,lcladdr,byte_len,tclass,'0','0',dum_status,dum_handle) ;
  end ebfm_barrd_nowt;

  procedure rdwr_start_perf_sample is
  begin
   req_intf_start_perf_sample;
  end rdwr_start_perf_sample;

  procedure rdwr_disp_perf_sample (
    variable tx_mbit_ps : out real;
    variable rx_mbit_ps : out real;
    variable bytes_transmitted: out natural
  ) is
  begin
    req_intf_disp_perf_sample(tx_mbit_ps, rx_mbit_ps, bytes_transmitted);
  end rdwr_disp_perf_sample;

end altpcietb_bfm_rdwr;

