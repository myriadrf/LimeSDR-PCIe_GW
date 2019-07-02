-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Package of Configuration Routines
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_configure.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This packeage provides routines to setup the configuration spaces of the
-- Root Port and End Point sections of the testbench.
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
use std.textio.all;
use ieee.numeric_std.all;
use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;
use work.altpcietb_bfm_req_intf.all;
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_rdwr.all;

package altpcietb_bfm_configure is

  -- purpose: Performs all of the steps neccesary to configure the
  -- root port and the endpoint on the link
  procedure ebfm_cfg_rp_ep (
    constant bar_table          : in natural;
    constant ep_bus_num         : in natural := RP_PRI_BUS_NUM+1 ;
    constant ep_dev_num         : in natural := 1 ;
    constant rp_max_rd_req_size : in natural := 512 ;
    -- Constant Display the Config Space of the EP after config setup
    constant display_ep_config  : in natural := 0;
    constant addr_map_4GB_limit : in natural := 0
    ) ;

  -- purpose: returns whether specified BAR is memory or I/O and the size
  procedure ebfm_cfg_decode_bar (
    constant bar_table    : in  natural;              -- Pointer to BAR info
    constant bar_num      : in  natural;              -- bar number to check
    variable log2_size    : out natural;              -- Log base 2 of the Size
    variable is_mem       : out std_logic;            -- Is memory (not I/O)
    variable is_pref      : out std_logic;            -- Is prefetchable
    variable is_64b       : out std_logic             -- Is 64bit
    );

end altpcietb_bfm_configure;

package body altpcietb_bfm_configure is

  -- This is where the PCI Express Capability is for the MegaCore Function
  constant PCIE_CAP_PTR : natural := 128;

  procedure cfg_wr_bars (
    constant bnm : in natural;
    constant dev : in natural;
    constant fnc : in natural;
    constant bar_base : in natural;
    constant typ1 : in std_logic := '0') is
    variable maxbar : natural := 9;
    variable rombar : natural := 12;
    variable compl_status : std_logic_vector(2 downto 0);
   begin
    if (typ1 = '1') then
      maxbar := 5 ;
      rombar := 14 ;
    end if;
    for i in 4 to maxbar loop
      ebfm_cfgwr_imm_nowt(bnm,dev,fnc,(i*4),4,
                          shmem_read(bar_base+((i-4)*4),4)) ;
    end loop;  -- i
    ebfm_cfgwr_imm_wait(bnm,dev,fnc,(rombar*4),4,
                        shmem_read(bar_base+24,4),compl_status) ;

  end procedure cfg_wr_bars ;

  procedure cfg_rd_bars (
    constant bnm : in natural;
    constant dev : in natural;
    constant fnc : in natural;
    constant bar_base : in natural;
    constant typ1 : in std_logic := '0') is
    variable maxbar : natural := 9;
    variable rombar : natural := 12;
    variable compl_status : std_logic_vector(2 downto 0);
  begin
    if (typ1 = '1') then
      maxbar := 5 ;
      rombar := 14 ;
    end if;
    for i in 4 to maxbar loop
      ebfm_cfgrd_nowt(bnm,dev,fnc,(i*4),4,bar_base+((i-4)*4)) ;
    end loop;  -- i
    ebfm_cfgrd_wait(bnm,dev,fnc,(rombar*4),4,bar_base+24,compl_status) ;

  end procedure cfg_rd_bars ;

  procedure cfg_display_reg (
    constant prefix : in string;
    constant reg    : in natural;
    constant data   : in string ) is
    variable reg_l : line;
  begin
    write(reg_l,reg,right,5) ;
    write(reg_l,string'(himage((reg*4),4)),right,5) ;

    ebfm_display(EBFM_MSG_INFO,
                 prefix & reg_l.all & " " & data) ;
  end procedure cfg_display_reg ;

  -- purpose: Configures the Address Window Registers in the Root Port
  procedure ebfm_cfg_rp_addr (
    -- Prefetchable Base and Limits  must be supplied
    constant pci_pref_base  : in unsigned(63 downto 0);
    constant pci_pref_limit : in unsigned(63 downto 0);
    -- Non-Prefetchable Space Base and Limits are optional
    constant pci_nonp_base  : in unsigned(31 downto 0) := (others => '0') ;
    constant pci_nonp_limit : in unsigned(31 downto 0) := (others => '0') ;
    -- IO Space Base and Limits are optional
    constant pci_io_base    : in unsigned(31 downto 0) := (others => '0') ;
    constant pci_io_limit   : in unsigned(31 downto 0) := (others => '0')
    ) is
    constant bnm : natural := RP_PRI_BUS_NUM ;
    constant dev : natural := RP_PRI_DEV_NUM ;
  begin  -- ebfm_cfg_rp_addr

    -- Configure the I/O Base and Limit Registers
    ebfm_cfgwr_imm_nowt(bnm,dev,0,28,4,X"0000" &
                        std_logic_vector(pci_io_limit(15 downto 12)) & X"0" &
                        std_logic_vector(pci_io_base(15 downto 12))  & X"0" ) ;

    -- Configure the Non-Prefetchable Base & Limit Registers
    ebfm_cfgwr_imm_nowt(bnm,dev,0,32,4,
                        std_logic_vector(pci_nonp_limit(31 downto 20)) & X"0" &
                        std_logic_vector(pci_nonp_base(31 downto 20))  & X"0" ) ;

    -- Configure the Prefetchable Base & Limit Registers
    ebfm_cfgwr_imm_nowt(bnm,dev,0,36,4,
                        std_logic_vector(pci_pref_limit(31 downto 20)) & X"0" &
                        std_logic_vector(pci_pref_base(31 downto 20))  & X"0" ) ;

    -- Configure the Upper Prefetchable Base Register
    ebfm_cfgwr_imm_nowt(bnm,dev,0,40,4,
                        std_logic_vector(pci_pref_base(63 downto 32)) ) ;

    -- Configure the Upper Prefetchable Limit Register
    ebfm_cfgwr_imm_nowt(bnm,dev,0,44,4,
                        std_logic_vector(pci_pref_limit(63 downto 32)) ) ;

    -- Configure the Upper I/O Base and Limit Registers
    ebfm_cfgwr_imm_nowt(bnm,dev,0,48,4,
                        std_logic_vector(pci_io_limit(31 downto 16)) &
                        std_logic_vector(pci_io_base(31 downto 16)) ) ;

  end ebfm_cfg_rp_addr;

  procedure ebfm_cfg_rp_basic (
    -- The Secondary Side Bus Number Defaults to 1 more than the Primary
    constant sec_bnm_offset : in natural := 1 ;  -- Secondary Side Bus Number
                                                 -- Offset from Primary
    -- The number of subordinate busses defaults to 1
    constant num_sub_bus : in natural := 1   -- Number of Subordinate Busses
    ) is
    variable tmp_slv : std_logic_vector(31 downto 0) := (others => '0');
    constant bnm : natural := RP_PRI_BUS_NUM ;
    constant dev : natural := RP_PRI_DEV_NUM ;
  begin  -- ebfm_cfg_rp_basic

    -- Configure the command register
    ebfm_cfgwr_imm_nowt(bnm,dev,0,4,4,X"00000006") ;

    -- Configure the Bus number Registers
    -- Primary BUS
    tmp_slv( 7 downto  0) := std_logic_vector(to_unsigned(bnm,8)) ;
    -- Secondary BUS (primary + offset)
    tmp_slv(15 downto  8) := std_logic_vector(to_unsigned((bnm + sec_bnm_offset),8)) ;
    -- Maximum Subordinate BUS (primary + offset + num - 1)
    tmp_slv(23 downto 16) :=
      std_logic_vector(to_unsigned((bnm + sec_bnm_offset + num_sub_bus - 1),8)) ;
    ebfm_cfgwr_imm_nowt(bnm,dev,0,24,4,tmp_slv) ;


  end ebfm_cfg_rp_basic;

  procedure assign_bar (
    variable bar  : inout std_logic_vector(63 downto 0);
    variable amin : inout unsigned(63 downto 0);
    constant amax : in unsigned(63 downto 0)
    ) is
    variable tbar : unsigned(63 downto 0);
    variable bsiz : unsigned(63 downto 0);
  begin
    tbar := unsigned(bar(63 downto 4) & "0000") ;
    bsiz := (not tbar) + 1 ;
    -- See if amin already on the boundary
    if ((amin and not tbar) = 0) then
      tbar := tbar and amin ;              -- Lowest assignment
    else
      -- The lower bits were not 0, then we have to round up to the
      -- next boundary
      tbar := unsigned(std_logic_vector(unsigned(amin + bsiz)) and std_logic_vector(tbar))  ;
    end if;
    if ((tbar + bsiz - 1) > amax) then
      -- We cant make the assignement
      bar(63 downto 4) := (others => 'X') ;
    else
      bar(63 downto 4) := std_logic_vector(tbar(63 downto 4)) ;
      amin := tbar + bsiz ;
    end if;
  end procedure assign_bar ;

  procedure assign_bar_from_top (
    variable bar  : inout std_logic_vector(63 downto 0);
    constant amin : in unsigned(63 downto 0);
    variable amax : inout unsigned(63 downto 0)
    ) is
    variable tbar : unsigned(63 downto 0);
    variable bsiz : unsigned(63 downto 0);
  begin
    bsiz := (not unsigned(bar(63 downto 4) & "0000") ) + 1 ;

    tbar := amax - bsiz + 1;                -- Highest Assignment
    tbar := unsigned(std_logic_vector(tbar) and bar(63 downto 0)) ;  -- Round Down

    if (tbar < amin) then
      -- We cant make the assignment
      bar(63 downto 4) := (others => 'X') ;
    else
      bar(63 downto 4)  := std_logic_vector(tbar(63 downto 4)) ;
      amax := tbar - 1 ;
    end if;
  end procedure assign_bar_from_top ;

  -- purpose: Describes the attributes of the BAR and the assigned address
  procedure describe_bar (
    constant bar_num : in natural;
    constant bar_lsb : in natural;
    constant bar     : in std_logic_vector(63 downto 0)) is
    variable bar_num_str : string(6 downto 1);
    variable bar_size_str : string(10 downto 1);
    variable bar_type_str : string(16 downto 1);
    variable bar_enabled : boolean := TRUE;
    variable addr_str : string(17 downto 1);
  begin  -- describe_bar
    case bar_lsb is
      when  4 => bar_size_str := " 16 Bytes ";
      when  5 => bar_size_str := " 32 Bytes ";
      when  6 => bar_size_str := " 64 Bytes ";
      when  7 => bar_size_str := "128 Bytes ";
      when  8 => bar_size_str := "256 Bytes ";
      when  9 => bar_size_str := "512 Bytes ";
      when 10 => bar_size_str := "  1 KBytes";
      when 11 => bar_size_str := "  2 KBytes";
      when 12 => bar_size_str := "  4 KBytes";
      when 13 => bar_size_str := "  8 KBytes";
      when 14 => bar_size_str := " 16 KBytes";
      when 15 => bar_size_str := " 32 KBytes";
      when 16 => bar_size_str := " 64 KBytes";
      when 17 => bar_size_str := "128 KBytes";
      when 18 => bar_size_str := "256 KBytes";
      when 19 => bar_size_str := "512 KBytes";
      when 20 => bar_size_str := "  1 MBytes";
      when 21 => bar_size_str := "  2 MBytes";
      when 22 => bar_size_str := "  4 MBytes";
      when 23 => bar_size_str := "  8 MBytes";
      when 24 => bar_size_str := " 16 MBytes";
      when 25 => bar_size_str := " 32 MBytes";
      when 26 => bar_size_str := " 64 MBytes";
      when 27 => bar_size_str := "128 MBytes";
      when 28 => bar_size_str := "256 MBytes";
      when 29 => bar_size_str := "512 MBytes";
      when 30 => bar_size_str := "  1 GBytes";
      when 31 => bar_size_str := "  2 GBytes";
      when 32 => bar_size_str := "  4 GBytes";
      when 33 => bar_size_str := "  8 GBytes";
      when 34 => bar_size_str := " 16 GBytes";
      when 35 => bar_size_str := " 32 GBytes";
      when 36 => bar_size_str := " 64 GBytes";
      when 37 => bar_size_str := "128 GBytes";
      when 38 => bar_size_str := "256 GBytes";
      when 39 => bar_size_str := "512 GBytes";
      when 40 => bar_size_str := "  1 TBytes";
      when 41 => bar_size_str := "  2 TBytes";
      when 42 => bar_size_str := "  4 TBytes";
      when 43 => bar_size_str := "  8 TBytes";
      when 44 => bar_size_str := " 16 TBytes";
      when 45 => bar_size_str := " 32 TBytes";
      when 46 => bar_size_str := " 64 TBytes";
      when 47 => bar_size_str := "128 TBytes";
      when 48 => bar_size_str := "256 TBytes";
      when 49 => bar_size_str := "512 TBytes";
      when 50 => bar_size_str := "  1 PBytes";
      when 51 => bar_size_str := "  2 PBytes";
      when 52 => bar_size_str := "  4 PBytes";
      when 53 => bar_size_str := "  8 PBytes";
      when 54 => bar_size_str := " 16 PBytes";
      when 55 => bar_size_str := " 32 PBytes";
      when 56 => bar_size_str := " 64 PBytes";
      when 57 => bar_size_str := "128 PBytes";
      when 58 => bar_size_str := "256 PBytes";
      when 59 => bar_size_str := "512 PBytes";
      when 60 => bar_size_str := "  1 EBytes";
      when 61 => bar_size_str := "  2 EBytes";
      when 62 => bar_size_str := "  4 EBytes";
      when 63 => bar_size_str := "  8 EBytes";
      when others =>
        bar_size_str := "Disabled  ";
        bar_enabled := FALSE ;
    end case;
    if (bar_num = 6) then
      bar_num_str := "ExpROM" ;
    else
      bar_num_str := "BAR" & integer'image(bar_num) & "  " ;
    end if;
    if bar_enabled then
      if (bar(2) = '1') then
        bar_num_str := "BAR" & integer'image(bar_num+1) & ":" & integer'image(bar_num) ;
      end if;
      if (bar(32) /= 'X') then
        if (bar(2) = '1') then
          addr_str(17 downto 10) := himage(bar(63 downto 32)) ;
        else
          addr_str(17 downto 10) := "        " ;
        end if;
        addr_str(9) := ' ' ;
        addr_str(8 downto 1) := himage(bar(31 downto 4)) & "0" ;
      else
        addr_str := "Unassigned!!!    " ;
      end if;
      if (bar(0) = '1') then
        bar_type_str := "IO Space        " ;
      else
        if (bar(3) = '1') then
          bar_type_str := "Prefetchable    " ;
        else
          bar_type_str := "Non-Prefetchable" ;
        end if;
      end if;
      ebfm_display(EBFM_MSG_INFO,bar_num_str & " " & bar_size_str & " " &
                   addr_str & " " & bar_type_str ) ;
    else
      ebfm_display(EBFM_MSG_INFO,bar_num_str & " " & bar_size_str) ;
    end if;

  end describe_bar;

  -- purpose: configure a set of bars
  procedure ebfm_cfg_bars (
    constant bnm : in natural;          -- Bus Number
    constant dev : in natural;          -- Device Number
    constant fnc : in natural;          -- Function Number
    constant bar_table : in natural;     -- Base Address in Shared Memory to
                                        -- store programmed value of BARs
    variable bar_ok : out std_logic;
    variable io_min : inout unsigned(31 downto 0);
    variable io_max : inout unsigned(31 downto 0);
    variable m32min : inout unsigned(63 downto 0);
    variable m32max : inout unsigned(63 downto 0);
    variable m64min : inout unsigned(63 downto 0);
    variable m64max : inout unsigned(63 downto 0);
    constant display : in natural := 0;
    constant addr_map_4GB_limit : in natural := 0
    ) is
    variable io_min_v : unsigned(63 downto 0) := X"00000000" & io_min;
    variable io_max_v : unsigned(63 downto 0) := X"00000000" & io_max;
    variable m32min_v : unsigned(63 downto 0) := m32min;
    variable m32max_v : unsigned(63 downto 0) := m32max;
    variable m64min_v : unsigned(63 downto 0) := m64min;
    variable m64max_v : unsigned(63 downto 0) := m64max;
    variable typ1 : std_logic;
    variable compl_status : std_logic_vector(2 downto 0);
    variable nbar : natural;
    type bar_array is array (0 to 6) of std_logic_vector(63 downto 0);
    variable bars : bar_array := (others => (others => '0')) ;
    type bar_ptr_array is array (0 to 6) of natural;
    variable sm_bar : bar_ptr_array := (0,1,2,3,4,5,6) ;
    variable bar_lsb : bar_ptr_array ;
  begin  -- ebfm_cfg_bars
    bar_ok := '1' ;
    shmem_fill(bar_table,SHMEM_FILL_ONE,32) ;
    -- Clear the last bit of the ROMBAR which is the enable bit...
    shmem_write(bar_table + 24, "11111110", 1) ;

    -- Read Header Type Field into last DWORD
    ebfm_cfgrd_wait(bnm,dev,fnc,12,4,bar_table+28,compl_status) ;

    if (shmem_read(bar_table+30,1)(6 downto 0) = "0000001") then
      typ1 := '1' ;
    else
      typ1 := '0' ;
    end if;
    cfg_wr_bars(bnm,dev,fnc,bar_table,typ1);

    shmem_fill(bar_table,SHMEM_FILL_ZERO,28) ;
    shmem_fill(bar_table+32,SHMEM_FILL_ZERO,32) ;

    cfg_rd_bars(bnm,dev,fnc,bar_table+32,typ1);

    -- Load each BAR into the local BAR array
    -- Find the Least Significant Writable bit in each BAR
    nbar := 0 ;
    while (nbar < 7) loop

      bars(nbar) := shmem_read((bar_table+32+(nbar*4)),8) ;
      if (bars(nbar)(2) = '0') then     -- 32 bit
        if  (bars(nbar)(31) = '1') then
          -- if valid
          bars(nbar)(63 downto 32) := (others => '1') ;
        else
          -- if invalid
          bars(nbar)(63 downto 32) := (others => '0') ;
        end if;
      else
        -- 64 bit BAR mark the next one invalid
        bar_lsb(nbar+1) := 64 ;
      end if;
      if (unsigned(bars(nbar)(63 downto 4)) = 0) then
        bar_lsb(nbar) := 64 ;
      else
        lsb_loop: for j in 4 to 63 loop
          if (bars(nbar)(j) = '1') then
            bar_lsb(nbar) := j ;
            exit lsb_loop;
          end if;
        end loop lsb_loop;  -- j
      end if;
      if (bars(nbar)(2) = '0') then
        nbar := nbar + 1 ;
      else
        nbar := nbar + 2 ;
      end if;
    end loop;  -- i

    -- Sort the BARs in order smallest to largest
    for i in 0 to 5 loop
      for j in i+1 to 6 loop
        if (bar_lsb(sm_bar(j)) < bar_lsb(sm_bar(i))) then
          nbar := sm_bar(i) ;
          sm_bar(i) := sm_bar(j) ;
          sm_bar(j) := nbar ;
        end if;
      end loop;  -- j
    end loop;  -- i

    -- Fill all of the I/O BARs First, Smallest to Largest
    for i in 0 to 6 loop
      if (bar_lsb(sm_bar(i)) < 64) then
        if (bars(sm_bar(i))(0) = '1') then
          assign_bar(bars(sm_bar(i)),io_min_v,io_max_v) ;
        end if;
      end if;
    end loop;  -- i

    -- Now fill all of the 32-bit Non-Prefetchable BARs, Smallest to Largest
    for i in 0 to 6 loop
      if (bar_lsb(sm_bar(i)) < 64) then
        if (bars(sm_bar(i))(3 downto 0) = "0000") then
          assign_bar(bars(sm_bar(i)),m32min_v,m32max_v) ;
        end if;
      end if ;
    end loop;  -- i

    -- Now fill all of the 32-bit Prefetchable BARs (and 64-bit Prefecthable BARs if addr_map_4GB_limit is set),
    -- Largest to Smallest. From the top of memory
    for i in 6 downto 0 loop
      if (bar_lsb(sm_bar(i)) < 64) then
        if bars(sm_bar(i))(3 downto 0) = "1000" or
      (bars(sm_bar(i))(3 downto 0) = "1100" and
      addr_map_4GB_limit = 1) then
          assign_bar_from_top(bars(sm_bar(i)),m32min_v,m32max_v) ;
        end if ;
      end if;
    end loop;  -- i

    -- Now fill all of the 64-bit Prefetchable BARs, Smallest to Largest, if addr_map_4GB_limit is not set.
    if (addr_map_4GB_limit = 0) then
      for i in 0 to 6 loop
        if (bar_lsb(sm_bar(i)) < 64) then
          if (bars(sm_bar(i))(3 downto 0) = "1100") then
            assign_bar(bars(sm_bar(i)),m64min_v,m64max_v) ;
          end if;
        end if;
      end loop;  -- i
    end if;

    -- Now put all of the BARs back in memory
    nbar := 0 ;
    if (display = 1) then
      ebfm_display(EBFM_MSG_INFO,"") ;
      ebfm_display(EBFM_MSG_INFO,"BAR Address Assignments:") ;
      ebfm_display(EBFM_MSG_INFO,"BAR   " & " " & "Size      " & " " &
                   "Assigned Address " & " " & "Type" ) ;
      ebfm_display(EBFM_MSG_INFO,"---   " & " " & "----      " & " " &
                   "---------------- " & " " & "----" ) ;
    end if;
    while (nbar < 7) loop
      if (display = 1) then
        -- Show the user what we have done
        describe_bar(nbar,bar_lsb(nbar),bars(nbar)) ;
      end if;
      -- Check and see if the BAR was unabled to be assigned!!
      if (bars(nbar)(32) = 'X') then
        bar_ok := '0' ;
      end if;
      if (bars(nbar)(2) /= '1') then
        shmem_write(bar_table+(nbar*4),bars(nbar)(31 downto 0),4) ;
        nbar := nbar + 1 ;
      else
        shmem_write(bar_table+(nbar*4),bars(nbar)(63 downto 0),8) ;
        nbar := nbar + 2 ;
      end if;
    end loop;

    -- Temporarily turn on the lowest bit of the ExpROM BAR so it is enabled
    shmem_write(bar_table + 24, "00000001", 1) ;
    cfg_wr_bars(bnm,dev,fnc,bar_table,typ1);
    -- Turn off the lowest bit of the ExpROM BAR so rest of the BFM knows it is a memory BAR
    shmem_write(bar_table + 24, "00000000", 1) ;

    if (display = 1) then
      ebfm_display(EBFM_MSG_INFO,"") ;
    end if ;

    m64max := m64max_v ;
    m64min := m64min_v ;
    m32max := m32max_v ;
    m32min := m32min_v ;
    io_max := io_max_v(31 downto 0) ;
    io_min := io_min_v(31 downto 0) ;

  end ebfm_cfg_bars ;

  procedure ebfm_display_link_status_reg (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable link_sts : std_logic_vector(15 downto 0);
    variable link_ctrl : std_logic_vector(15 downto 0);
    variable link_cap : std_logic_vector(15 downto 0);
  begin
    ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+16,4,CFG_SCRATCH_SPACE,compl_status) ;
    link_sts := shmem_read(CFG_SCRATCH_SPACE+2,2) ;
    link_ctrl := shmem_read(CFG_SCRATCH_SPACE,2) ;
    ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+12,4,CFG_SCRATCH_SPACE,compl_status) ;
    link_cap := shmem_read(CFG_SCRATCH_SPACE,2) ;
    ebfm_display(EBFM_MSG_INFO,"") ;
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Link Status Register (" & himage(link_sts) & "):" ) ;
    ebfm_display(EBFM_MSG_INFO,"    Negotiated Link Width: x" & integer'image(to_integer(unsigned(link_sts(9 downto 4))))) ;
    if (link_sts(12) = '1') then
      ebfm_display(EBFM_MSG_INFO,"        Slot Clock Config: System Reference Clock Used") ;
    -- Setting common clk cfg bit
      link_ctrl := X"0040" or link_ctrl;
      ebfm_cfgwr_imm_wait(bnm,dev,fnc,144,2, (X"0000" & link_ctrl), compl_status);
      -- retrain the link
      ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,144,2, X"00000020", compl_status);
    else
      ebfm_display(EBFM_MSG_INFO,"        Slot Clock Config: Local Clock Used") ;
    end if;

    -- check link speed
    ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+16,4,CFG_SCRATCH_SPACE,compl_status) ;
    link_sts := shmem_read(CFG_SCRATCH_SPACE+2,2) ;
    if link_sts(3 downto 0) = x"1" then
      ebfm_display(EBFM_MSG_INFO,"       Current Link Speed: 2.5GT/s") ;
    elsif link_sts(3 downto 0) = x"2" then
      ebfm_display(EBFM_MSG_INFO,"       Current Link Speed: 5.0GT/s") ;
    else
      ebfm_display(EBFM_MSG_ERROR_FATAL,"       Current Link Speed is Unsupported") ;
    end if;

    if link_sts(3 downto 0) /= link_cap(3 downto 0) then  -- link not at full speed
      ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,144,2, X"00000020", compl_status);
      ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
      -- Make sure the config Rd is not sent before the retraining starts
      ebfm_cfgrd_wait(bnm, dev, fnc, PCIE_CAP_PTR + 16, 4, CFG_SCRATCH_SPACE, compl_status);
      link_sts  := shmem_read(CFG_SCRATCH_SPACE + 2, 2);

      if link_sts(3 downto 0) = x"1" then
        ebfm_display(EBFM_MSG_INFO,"           New Link Speed: 2.5GT/s") ;
      elsif link_sts(3 downto 0) = x"2" then
        ebfm_display(EBFM_MSG_INFO,"           New Link Speed: 5.0GT/s") ;
      else
        ebfm_display(EBFM_MSG_ERROR_FATAL,"           New Link Speed is Unsupported") ;
      end if;

    end if;

  end procedure ebfm_display_link_status_reg ;


  procedure ebfm_display_link_control_reg (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable link_ctrl : std_logic_vector(15 downto 0);
  begin
    ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+16,4,CFG_SCRATCH_SPACE,compl_status) ;
    link_ctrl := shmem_read(CFG_SCRATCH_SPACE,2) ;
    ebfm_display(EBFM_MSG_INFO,"") ;
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Link Control Register (" & himage(link_ctrl) & "):" ) ;
    if (link_ctrl(6) = '1') then
      ebfm_display(EBFM_MSG_INFO,"      Common Clock Config: System Reference Clock Used") ;
    else
      ebfm_display(EBFM_MSG_INFO,"      Common Clock Config: Local Clock Used") ;
    end if;
  end procedure ebfm_display_link_control_reg ;


  procedure ebfm_display_dev_control_status_reg (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable dev_cs : std_logic_vector(31 downto 0);
  begin
    ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+8,4,CFG_SCRATCH_SPACE,compl_status) ;
    dev_cs := shmem_read(CFG_SCRATCH_SPACE,4) ;
    ebfm_display(EBFM_MSG_INFO,"");
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Device Control Register (" & himage(dev_cs(15 downto 0)) & "):") ;
    ebfm_display(EBFM_MSG_INFO,"  Error Reporting Enables: " & himage(dev_cs(3 downto 0)) & "h") ;
    if (dev_cs(4) = '1') then
      ebfm_display(EBFM_MSG_INFO,"         Relaxed Ordering: Enabled") ;
    else
      ebfm_display(EBFM_MSG_INFO,"         Relaxed Ordering: Disabled") ;
    end if;
    case dev_cs(7 downto 5) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"              Max Payload: 128 Bytes") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"              Max Payload: 256 Bytes") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"              Max Payload: 512 Bytes") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"              Max Payload: 1KBytes") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"              Max Payload: 2KBytes") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"              Max Payload: 4KBytes") ;
      when others => ebfm_display(EBFM_MSG_INFO,"              Max Payload: Unknown" & himage(dev_cs(2 downto 0))) ;
    end case;
    if (dev_cs(8) = '1') then
      ebfm_display(EBFM_MSG_INFO,"             Extended Tag: Enabled") ;
    else
      ebfm_display(EBFM_MSG_INFO,"             Extended Tag: Disabled") ;
    end if;
    case dev_cs(14 downto 12) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: 128 Bytes") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: 256 Bytes") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: 512 Bytes") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: 1KBytes") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: 2KBytes") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: 4KBytes") ;
      when others => ebfm_display(EBFM_MSG_INFO,"         Max Read Request: Unknown" & himage(dev_cs(2 downto 0))) ;
    end case;

    ebfm_display(EBFM_MSG_INFO,"");
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Device Status Register (" & himage(dev_cs(31 downto 16)) & "):") ;

  end procedure ebfm_display_dev_control_status_reg ;

  -- purpose: display PCI Express Capability Info
  procedure display_pcie_cap (
    constant pcie_cap : in std_logic_vector(31 downto 0);
    constant dev_cap  : in std_logic_vector(31 downto 0);
    constant link_cap : in std_logic_vector(31 downto 0);
    constant dev_cap2 : in std_logic_vector(31 downto 0)
  ) is
    variable pwr_limit : natural;
    variable l : line;
  begin  -- display_pcie_cap
    ebfm_display(EBFM_MSG_INFO,"") ;
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Capabilities Register (" & himage(pcie_cap(31 downto 16)) & "):") ;
    ebfm_display(EBFM_MSG_INFO,"       Capability Version: " & himage(pcie_cap(19 downto 16)) & "h") ;
    case pcie_cap(23 downto 20) is
      when "0000" => ebfm_display(EBFM_MSG_INFO,"                Port Type: Native Endpoint") ;
      when "0001" => ebfm_display(EBFM_MSG_INFO,"                Port Type: Legacy Endpoint") ;
      when "0100" => ebfm_display(EBFM_MSG_INFO,"                Port Type: Root port") ;
      when "0101" => ebfm_display(EBFM_MSG_INFO,"                Port Type: Switch Upstream port") ;
      when "0110" => ebfm_display(EBFM_MSG_INFO,"                Port Type: Switch Downstream port") ;
      when "0111" => ebfm_display(EBFM_MSG_INFO,"                Port Type: Express-to-PCI bridge") ;
      when "1000" => ebfm_display(EBFM_MSG_INFO,"                Port Type: PCI-to-Express bridge") ;
      when others => ebfm_display(EBFM_MSG_INFO,"                Port Type: UNKNOWN" & himage(pcie_cap(23 downto 20)));
    end case;
    ebfm_display(EBFM_MSG_INFO,"") ;
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Device Capabilities Register (" & himage(dev_cap) & "):") ;
    case dev_cap(2 downto 0) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: 128 Bytes") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: 256 Bytes") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: 512 Bytes") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: 1KBytes") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: 2KBytes") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: 4KBytes") ;
      when others => ebfm_display(EBFM_MSG_INFO,"    Max Payload Supported: Unknown" & himage(dev_cap(2 downto 0))) ;
    end case;
    if (dev_cap(5) = '1') then
      ebfm_display(EBFM_MSG_INFO,"             Extended Tag: Supported") ;
    else
      ebfm_display(EBFM_MSG_INFO,"             Extended Tag: Not Supported") ;
    end if;
    case dev_cap(8 downto 6) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: Less Than 64 ns") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: 64 ns to 128 ns") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: 128 ns to 256 ns") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: 256 ns to 512 ns") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: 512 ns to 1 us") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: 1 us to 2 us") ;
      when "110" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: 2 us to 4 us") ;
      when "111" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L0s Latency: More than 4 us") ;
      when others => null ;
    end case;
    case dev_cap(11 downto 9) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: Less Than 1 us") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: 1 us to 2 us") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: 2 us to 4 us") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: 4 us to 8 us") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: 8 us to 16 us") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: 16 us to 32 us") ;
      when "110" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: 32 us to 64 us") ;
      when "111" => ebfm_display(EBFM_MSG_INFO,"   Acceptable L1  Latency: More than 64 us") ;
      when others => null ;
    end case;
    if (dev_cap(12) = '1') then
      ebfm_display(EBFM_MSG_INFO,"         Attention Button: Present") ;
    else
      ebfm_display(EBFM_MSG_INFO,"         Attention Button: Not Present") ;
    end if;
    if (dev_cap(13) = '1') then
      ebfm_display(EBFM_MSG_INFO,"      Attention Indicator: Present") ;
    else
      ebfm_display(EBFM_MSG_INFO,"      Attention Indicator: Not Present") ;
    end if;
    if (dev_cap(14) = '1') then
      ebfm_display(EBFM_MSG_INFO,"          Power Indicator: Present") ;
    else
      ebfm_display(EBFM_MSG_INFO,"          Power Indicator: Not Present") ;
    end if;
    case dev_cap(27 downto 26) is
      when "00" => pwr_limit := 1000 * to_integer(unsigned(dev_cap(25 downto 18))) ;
      when "01" => pwr_limit := 100 * to_integer(unsigned(dev_cap(25 downto 18))) ;
      when "10" => pwr_limit := 10 * to_integer(unsigned(dev_cap(25 downto 18))) ;
      when "11" => pwr_limit := to_integer(unsigned(dev_cap(25 downto 18))) ;
      when others => null;
    end case;
    ebfm_display(EBFM_MSG_INFO,"") ;
    ebfm_display(EBFM_MSG_INFO,"  PCI Express Link Capabilities Register (" & himage(link_cap) & "):") ;
    ebfm_display(EBFM_MSG_INFO,"       Maximum Link Width: x" & integer'image(to_integer(unsigned(link_cap(9 downto 4))))) ;
    ebfm_display(EBFM_MSG_INFO,"     Supported Link Speed: Gen" & integer'image(to_integer(unsigned(link_cap(3 downto 0))))) ;

    if link_cap(3 downto 0) = x"1" then
      ebfm_display(EBFM_MSG_INFO,"     Supported Link Speed: 2.5GT/s") ;
    elsif link_cap(3 downto 0) = x"2" then
      ebfm_display(EBFM_MSG_INFO,"     Supported Link Speed: 5.0GT/s or 2.5GT/s") ;
    else
      ebfm_display(EBFM_MSG_ERROR_FATAL,"     Supported Link Speed: Undefined") ;
    end if;


    if (link_cap(10) = '1') then
      ebfm_display(EBFM_MSG_INFO,"                L0s Entry: Supported") ;
    else
      ebfm_display(EBFM_MSG_INFO,"                L0s Entry: Not Supported") ;
    end if;
    if (link_cap(11) = '1') then
      ebfm_display(EBFM_MSG_INFO,"                L1  Entry: Supported") ;
    else
      ebfm_display(EBFM_MSG_INFO,"                L1  Entry: Not Supported") ;
    end if;
    case link_cap(14 downto 12) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: Less Than 64 ns") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: 64 ns to 128 ns") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: 128 ns to 256 ns") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: 256 ns to 512 ns") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: 512 ns to 1 us") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: 1 us to 2 us") ;
      when "110" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: 2 us to 4 us") ;
      when "111" => ebfm_display(EBFM_MSG_INFO,"         L0s Exit Latency: More than 4 us") ;
      when others => null ;
    end case;
    case link_cap(17 downto 15) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: Less Than 1 us") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: 1 us to 2 us") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: 2 us to 4 us") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: 4 us to 8 us") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: 8 us to 16 us") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: 16 us to 32 us") ;
      when "110" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: 32 us to 64 us") ;
      when "111" => ebfm_display(EBFM_MSG_INFO,"         L1  Exit Latency: More than 64 us") ;
      when others => null ;
    end case;
    ebfm_display(EBFM_MSG_INFO,"              Port Number: " & himage(link_cap(31 downto 24))) ;

    -- Spec 2.0 Cap
    if pcie_cap(19 downto 16) = x"2" then
        if link_cap(19) = '1' then
          ebfm_display(EBFM_MSG_INFO,"  Surprise Dwn Err Report: Supported") ;
        else
          ebfm_display(EBFM_MSG_INFO,"  Surprise Dwn Err Report: Not Supported") ;
        end if;

        if link_cap(20) = '1' then
          ebfm_display(EBFM_MSG_INFO,"   DLL Link Active Report: Supported") ;
        else
          ebfm_display(EBFM_MSG_INFO,"   DLL Link Active Report: Not Supported") ;
        end if;


        ebfm_display(EBFM_MSG_INFO,"") ;
        ebfm_display(EBFM_MSG_INFO,"  PCI Express Device Capabilities 2 Register (" & himage(dev_cap2) & "):") ;

        if dev_cap2(4) = '1' then
          case dev_cap2(3 downto 0) is
            when x"0" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: Not Supported") ;
            when x"1" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: A (50us to 10ms)") ;
            when x"2" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: B (10ms to 250ms)") ;
            when x"3" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: AB (50us to 250ms)") ;
            when x"6" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: BC (10ms to 4s)") ;
            when x"7" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: ABC (50us to 4s)") ;
            when x"E" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: BCD (10ms to 64s)") ;
            when x"F" => ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: ABCD (50us to 64s)") ;
            when others => null ;
          end case;
          else
            ebfm_display(EBFM_MSG_INFO,"  Completion Timeout Rnge: Not Supported") ;
        end if;

    end if;

  end display_pcie_cap;


  -- purpose: Display the Virtual Channel Capabilities
  procedure ebfm_display_vc (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable port_vc_cap_r : std_logic_vector(15 downto 0);
    variable low_vc : unsigned(2 downto 0) ;

  begin  -- ebfm_display_vc
    ebfm_cfgrd_wait(bnm,dev,fnc,260,4,CFG_SCRATCH_SPACE, compl_status);

    port_vc_cap_r := shmem_read(CFG_SCRATCH_SPACE,2) ;
    -- Low priority VC = 0 means there is no Low priority VC
    -- Low priority VC = 1 means there are 2 Low priority VCs etc
    if (port_vc_cap_r(6 downto 4) = "000") then
      low_vc := (others => '0');
    else
      low_vc := unsigned(port_vc_cap_r(6 downto 4)) + 1;
    end if;

    ebfm_display(EBFM_MSG_INFO,"  PCI Express Virtual Channel Capability:") ;
    ebfm_display(EBFM_MSG_INFO,"          Virtual Channel: " & integer'image(to_integer(unsigned(port_vc_cap_r(2 downto 0)) + 1))) ;
    ebfm_display(EBFM_MSG_INFO,"          Low Priority VC: "  & integer'image(to_integer(low_vc))) ;
    ebfm_display(EBFM_MSG_INFO,"") ;
  end ebfm_display_vc;


  -- purpose: configure the PCI Express Capabilities
  procedure ebfm_cfg_pcie_cap (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural;
    constant CFG_SCRATCH_SPACE : in natural;
    constant rp_max_rd_req_size : in natural := 512;
    constant display : in natural := 0) is
    variable compl_status : std_logic_vector(2 downto 0);
    constant EP_PCIE_CAP : natural := CFG_SCRATCH_SPACE + 0;
    constant EP_DEV_CAP  : natural := CFG_SCRATCH_SPACE + 4;
    constant EP_LINK_CAP : natural := CFG_SCRATCH_SPACE + 8;
    constant RP_PCIE_CAP : natural := CFG_SCRATCH_SPACE + 16;
    constant RP_DEV_CAP  : natural := CFG_SCRATCH_SPACE + 20;
    constant EP_DEV_CAP2  : natural := CFG_SCRATCH_SPACE + 24;
    variable ep_pcie_cap_r : std_logic_vector(31 downto 0);
    variable rp_pcie_cap_r : std_logic_vector(31 downto 0);
    variable ep_dev_cap_r : std_logic_vector(31 downto 0);
    variable rp_dev_cap_r : std_logic_vector(31 downto 0);
    variable ep_dev_control : std_logic_vector(15 downto 0) := (others => '0') ;
    variable rp_dev_control : std_logic_vector(15 downto 0) := (others => '0') ;
    variable max_size  : natural := 128;
  begin  -- ebfm_cfg_pcie_cap
    -- Read the EP PCI Express Capabilities (at a known address in the MegaCore
    -- function)
    if (display = 1) then
      ebfm_display_link_status_reg(bnm,dev,fnc,CFG_SCRATCH_SPACE+32) ;
      ebfm_display_link_control_reg(bnm,dev,fnc,CFG_SCRATCH_SPACE+32) ;
    end if ;


    ebfm_cfgrd_nowt(bnm,dev,fnc,PCIE_CAP_PTR,4,EP_PCIE_CAP) ;
    ebfm_cfgrd_nowt(bnm,dev,fnc,PCIE_CAP_PTR+4,4,EP_DEV_CAP) ;
    ebfm_cfgrd_nowt(bnm,dev,fnc,PCIE_CAP_PTR+36,4,EP_DEV_CAP2) ;
    ebfm_cfgrd_wait(bnm,dev,fnc,PCIE_CAP_PTR+12,4,EP_LINK_CAP,compl_status) ;
    ebfm_cfgrd_nowt(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,128,4,RP_PCIE_CAP) ;
    ebfm_cfgrd_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,132,4,RP_DEV_CAP,compl_status) ;
    ep_pcie_cap_r := shmem_read(EP_PCIE_CAP,4) ;
    rp_pcie_cap_r := shmem_read(RP_PCIE_CAP,4) ;
    ep_dev_cap_r := shmem_read(EP_DEV_CAP,4) ;
    rp_dev_cap_r := shmem_read(RP_DEV_CAP,4) ;

    if (ep_pcie_cap_r(7 downto 0) /= X"10") then
      ebfm_display(EBFM_MSG_ERROR_FATAL,"PCI Express Capabilities not at expected Endpoint config address") ;
    end if;
    if (rp_pcie_cap_r(7 downto 0) /= X"10") then
      ebfm_display(EBFM_MSG_ERROR_FATAL_TB_ERR,"PCI Express Capabilities not at expected Root Port config address") ;
    end if;

    if (display = 1) then
      display_pcie_cap(ep_pcie_cap_r,
                       ep_dev_cap_r,
                       shmem_read(EP_LINK_CAP,4),
                       shmem_read(EP_DEV_CAP2,4)) ;
    end if;


    -- Error Reporting Enables (RP BFM does not handle for now)
    ep_dev_control(3 downto 0) := (others => '0') ;
    rp_dev_control(3 downto 0) := (others => '0') ;
    -- Enable Relaxed Ordering
    ep_dev_control(4) := '1' ;
    rp_dev_control(4) := '1' ;
    -- Enable Extended Tag if requested for EP
    ep_dev_control(8) := ep_dev_cap_r(5) ;
    if (EBFM_NUM_TAG > 32) then
      rp_dev_control(8) := '1' ;
    else
      rp_dev_control(8) := '0' ;
    end if;
    -- Disable Phantom Functions
    ep_dev_control(9) := '0' ;
    rp_dev_control(9) := '0' ;
    -- Disable Aux Power PM Enable
    ep_dev_control(10) := '0' ;
    rp_dev_control(10) := '0' ;
    -- Disable No Snoop
    ep_dev_control(11) := '0' ;
    rp_dev_control(11) := '0' ;
    if (unsigned(ep_dev_cap_r(2 downto 0)) < unsigned(rp_dev_cap_r(2 downto 0))) then
      -- Max Payload Size
      ep_dev_control(7 downto 5) := ep_dev_cap_r(2 downto 0) ;
      rp_dev_control(7 downto 5) := ep_dev_cap_r(2 downto 0) ;
      -- Max Read Request Size
      -- Note the reference design can break up the read requests into smaller
      -- completion packets, so we can go for the full 4096 bytes. But the
      -- root port BFM can't create multiple completions, so tell the endpoint
      -- to be restricted to the max payload size
      ep_dev_control(14 downto 12) := ep_dev_cap_r(2 downto 0) ;
      rp_dev_control(14 downto 12) := "101" ;
    else
      -- Max Payload Size
      ep_dev_control(7 downto 5) := rp_dev_cap_r(2 downto 0) ;
      rp_dev_control(7 downto 5) := rp_dev_cap_r(2 downto 0) ;
      -- Max Read Request Size
      -- Note the reference design can break up the read requests into smaller
      -- completion packets, so we can go for the full 4096 bytes. But the
      -- root port BFM can't create multiple completions, so tell the endpoint
      -- to be restricted to the max payload size
      ep_dev_control(14 downto 12) := rp_dev_cap_r(2 downto 0) ;
      rp_dev_control(14 downto 12) := "101" ;
    end if;

    case ep_dev_control(7 downto 5) is
      when "000" => max_size := 128 ;
      when "001" => max_size := 256 ;
      when "010" => max_size := 512 ;
      when "011" => max_size := 1024 ;
      when "100" => max_size := 2048 ;
      when "101" => max_size := 4096 ;
      when others => max_size := 128;
    end case;

    -- Tell the BFM what the limits are...
    req_intf_set_max_payload(max_size,max_size,rp_max_rd_req_size) ;

    ebfm_cfgwr_imm_nowt(bnm,dev,fnc,PCIE_CAP_PTR+8,4,X"0000" & ep_dev_control) ;
    ebfm_cfgwr_imm_nowt(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,0,PCIE_CAP_PTR+8,4,X"0000" & rp_dev_control) ;

    if (display = 1) then
      ebfm_display_dev_control_status_reg(bnm,dev,fnc,CFG_SCRATCH_SPACE+32) ;
      ebfm_display_vc(bnm,dev,fnc,CFG_SCRATCH_SPACE+32) ;
    end if ;

  end procedure ebfm_cfg_pcie_cap ;

  -- purpose: Display the "critical" BARs
  procedure ebfm_display_read_only (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable int_pin_reg: std_logic_vector(7 downto 0);

  begin  -- ebfm_display_read_only
    ebfm_cfgrd_nowt(bnm, dev, fnc,  0, 4, CFG_SCRATCH_SPACE     ) ;
    ebfm_cfgrd_nowt(bnm, dev, fnc,  8, 4, CFG_SCRATCH_SPACE +  8) ;
    ebfm_cfgrd_nowt(bnm, dev, fnc, 44, 4, CFG_SCRATCH_SPACE +  4) ;
    ebfm_cfgrd_nowt(bnm, dev, fnc, 60, 4, CFG_SCRATCH_SPACE + 16) ;
    ebfm_cfgrd_wait(bnm, dev, fnc, 12, 4, CFG_SCRATCH_SPACE + 12, compl_status) ;
    ebfm_display(EBFM_MSG_INFO,"") ;
    ebfm_display(EBFM_MSG_INFO,
                 "Configuring Bus " & integer'image(bnm) &
                 ", Device " & integer'image(dev) &
                 ", Function " & integer'image(fnc)) ;
    ebfm_display(EBFM_MSG_INFO,"  Read Only Configuration Registers:") ;
    ebfm_display(EBFM_MSG_INFO,"                Vendor ID: " & himage(shmem_read(CFG_SCRATCH_SPACE,2))) ;
    ebfm_display(EBFM_MSG_INFO,"                Device ID: " & himage(shmem_read(CFG_SCRATCH_SPACE+2,2))) ;
    ebfm_display(EBFM_MSG_INFO,"              Revision ID: " & himage(shmem_read(CFG_SCRATCH_SPACE+8,1))) ;
    ebfm_display(EBFM_MSG_INFO,"               Class Code: " & himage(shmem_read(CFG_SCRATCH_SPACE+9,3))) ;
    if (shmem_read(CFG_SCRATCH_SPACE+14,1) = X"00") then
      ebfm_display(EBFM_MSG_INFO,"      Subsystem Vendor ID: " & himage(shmem_read(CFG_SCRATCH_SPACE+4,2))) ;
      ebfm_display(EBFM_MSG_INFO,"             Subsystem ID: " & himage(shmem_read(CFG_SCRATCH_SPACE+6,2))) ;
    end if;

    int_pin_reg := shmem_read(CFG_SCRATCH_SPACE + 17,1);
    case int_pin_reg is
       when "00000000" => ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: No INTx# pin ");
       when "00000001" => ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTA# used ");
       when "00000010" => ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTB# used ");
       when "00000011" => ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTC# used ");
       when "00000100" => ebfm_display(EBFM_MSG_INFO,"            Interrupt Pin: INTD# used ");
       when others => ebfm_display(EBFM_MSG_ERROR_FATAL,"            Interrupt Pin: Interrupt Pin Register has Illegal Value.");
    end case;

    ebfm_display(EBFM_MSG_INFO,"") ;
  end ebfm_display_read_only;

  -- purpose: Display the MSI information
  procedure ebfm_display_msi (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable message_control_r : std_logic_vector(15 downto 0);

  begin  -- ebfm_display_msi
    ebfm_cfgrd_wait(bnm,dev,fnc,80,4,CFG_SCRATCH_SPACE, compl_status);

    ebfm_display(EBFM_MSG_INFO,"");
    ebfm_display(EBFM_MSG_INFO,"  PCI MSI Capability Register:") ;
    message_control_r := shmem_read(CFG_SCRATCH_SPACE+2,2) ;
    if (message_control_r(7) = '1') then
      ebfm_display(EBFM_MSG_INFO,"   64-Bit Address Capable: Supported");
    else
      ebfm_display(EBFM_MSG_INFO,"   64-Bit Address Capable: Not Supported");
    end if;
    case message_control_r(3 downto 1) is
      when "000" => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 1") ;
      when "001" => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 2") ;
      when "010" => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 4") ;
      when "011" => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 8") ;
      when "100" => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 16") ;
      when "101" => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: 32") ;
      when others => ebfm_display(EBFM_MSG_INFO,"       Messages Requested: Reserved") ;
    end case;
    ebfm_display(EBFM_MSG_INFO,"") ;
  end ebfm_display_msi;

  -- purpose: Display the MSI-X information
  procedure ebfm_display_msix (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable dword : std_logic_vector(31 downto 0);

  begin  -- ebfm_display_msix
    ebfm_cfgwr_imm_wait(bnm,dev,fnc,104,4, X"80000000", compl_status);
    ebfm_cfgrd_wait(bnm,dev,fnc,104,4,CFG_SCRATCH_SPACE, compl_status);
    dword := shmem_read(CFG_SCRATCH_SPACE,4) ;

    if dword(31) = '1' then             -- check for implementation
      ebfm_display(EBFM_MSG_INFO,"");
      ebfm_display(EBFM_MSG_INFO,"  PCI MSI-X Capability Register:") ;
      ebfm_display(EBFM_MSG_INFO,"               Table Size: " & himage("00000" & dword(26 downto 16)));
      ebfm_cfgrd_wait(bnm,dev,fnc,108,4,CFG_SCRATCH_SPACE, compl_status);
      dword := shmem_read(CFG_SCRATCH_SPACE,4) ;
      ebfm_display(EBFM_MSG_INFO, "                Table BIR: " & himage("0" & dword(2 downto 0)));
      ebfm_display(EBFM_MSG_INFO, "             Table Offset: " & himage("000" & dword(31 downto 3)));
      ebfm_cfgrd_wait(bnm,dev,fnc,112,4,CFG_SCRATCH_SPACE, compl_status);
      dword := shmem_read(CFG_SCRATCH_SPACE,4) ;
      ebfm_display(EBFM_MSG_INFO, "                  PBA BIR: " & himage("0" & dword(2 downto 0)));
      ebfm_display(EBFM_MSG_INFO, "               PBA Offset: " & himage("000" & dword(31 downto 3)));
      ebfm_display(EBFM_MSG_INFO,"");

      -- disable MSIX
      ebfm_cfgwr_imm_wait(bnm,dev,fnc,104,4, X"00000000", compl_status);
    end if;

  end ebfm_display_msix;

   -- purpose: Display the Advance Error Reporting Information
  procedure ebfm_display_aer (
    constant bnm : in natural ;
    constant dev : in natural ;
    constant fnc : in natural ;
    constant CFG_SCRATCH_SPACE : in natural) is
    variable compl_status : std_logic_vector(2 downto 0);
    variable dword : std_logic_vector(31 downto 0);

  begin  -- ebfm_display_msix
    ebfm_cfgrd_wait(bnm,dev,fnc,2048,4,CFG_SCRATCH_SPACE, compl_status);
    dword := shmem_read(CFG_SCRATCH_SPACE,4) ;


    if dword(15 downto 0) = X"0001" then             -- check for implementation
      ebfm_display(EBFM_MSG_INFO,"  PCI Express AER Capability Register:") ;
      -- turn on check and generation on RP side
      ebfm_cfgwr_imm_wait(RP_PRI_BUS_NUM,RP_PRI_DEV_NUM,fnc,2072,2, X"00000140", compl_status);

      ebfm_cfgrd_wait(bnm,dev,fnc,2072,4,CFG_SCRATCH_SPACE, compl_status);
      dword := shmem_read(CFG_SCRATCH_SPACE,4) ;

      ebfm_cfgwr_imm_wait(bnm,dev,fnc,2072,2, X"0000" & dword(14 downto 0) & '0', compl_status);

      if dword(7) = '1' then
        ebfm_display(EBFM_MSG_INFO,"       ECRC Check Capable: Supported");
      else
        ebfm_display(EBFM_MSG_INFO,"       ECRC Check Capable: Not Supported");
      end if;

      if dword(5) = '1' then
        ebfm_display(EBFM_MSG_INFO,"  ECRC Generation Capable: Supported");
      else
        ebfm_display(EBFM_MSG_INFO,"  ECRC Generation Capable: Not Supported");
      end if;

      ebfm_display(EBFM_MSG_INFO,"");

    end if;

  end ebfm_display_aer;

  -- purpose: Performs all of the steps neccesary to configure the
  -- root port and the endpoint on the link
  procedure ebfm_cfg_rp_ep (
    constant bar_table         : in natural;
    constant ep_bus_num        : in natural := RP_PRI_BUS_NUM+1 ;
    constant ep_dev_num        : in natural := 1 ;
    -- Constant Display the Config Spaces of the EP after config setup
    constant rp_max_rd_req_size : in natural := 512 ;
    constant display_ep_config : in natural := 0; -- 1 to display
    constant addr_map_4GB_limit : in natural := 0
    ) is
    variable io_min_v : unsigned(31 downto 0) := EBFM_BAR_IO_MIN;
    variable io_max_v : unsigned(31 downto 0) := EBFM_BAR_IO_MAX;
    variable m32min_v : unsigned(63 downto 0) := X"00000000" & EBFM_BAR_M32_MIN;
    variable m32max_v : unsigned(63 downto 0) := X"00000000" & EBFM_BAR_M32_MAX;
    variable m64min_v : unsigned(63 downto 0) := EBFM_BAR_M64_MIN;
    variable m64max_v : unsigned(63 downto 0) := EBFM_BAR_M64_MAX;

    variable compl_status : std_logic_vector(2 downto 0);

    variable bar_ok : std_logic;

  begin  -- ebfm_cfg_rp_ep

     ebfm_display(EBFM_MSG_INFO,"Calling req_intf_wait_reset_end");
    -- Wait until the Root Port is done being reset before proceeding further
    wait for 10 ns;
    req_intf_wait_reset_end ;
     ebfm_display(EBFM_MSG_INFO,"Returned from req_intf_wait_reset_end");

    -- Unlock the bfm shared memory for initialization
    protect_bfm_shmem := 0;

    -- Perform the basic configuration of the Root Port
    ebfm_cfg_rp_basic((ep_bus_num - RP_PRI_BUS_NUM),1) ;

    if (display_ep_config = 1) then
      ebfm_display(EBFM_MSG_INFO,"Completed initial configuration of Root Port.") ;
      ebfm_display_read_only((ep_bus_num - RP_PRI_BUS_NUM),1,0,CFG_SCRATCH_SPACE) ;
      ebfm_display_msi(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
      ebfm_display_msix(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
      ebfm_display_aer(ep_bus_num,1,0,CFG_SCRATCH_SPACE) ;
    end if;

    ebfm_cfg_pcie_cap((ep_bus_num - RP_PRI_BUS_NUM),1,0,
                      CFG_SCRATCH_SPACE,rp_max_rd_req_size,display_ep_config) ;

    -- Configure BARs (Throw away the updated min/max addresses)
    ebfm_cfg_bars(ep_bus_num,ep_dev_num,0,
                  bar_table,
                  bar_ok,
                  io_min_v,io_max_v,
                  m32min_v,m32max_v,
                  m64min_v,m64max_v,
                  display_ep_config,
                  addr_map_4GB_limit) ;

    if (bar_ok = '1') then
      if (display_ep_config = 1) then
        ebfm_display(EBFM_MSG_INFO,"Completed configuration of Endpoint BARs.") ;
      end if;
    else
      ebfm_display(EBFM_MSG_ERROR_FATAL,"Unable to assign all of the Endpoint BARs.") ;
    end if;

    -- Configure Root Port Address Windows
    ebfm_cfg_rp_addr(
      pci_pref_base => (m32max_v+1),    -- Pref32 grew down
      pci_pref_limit => (m64min_v-1),   -- Pref64 grew up
      pci_nonp_base => (EBFM_BAR_M32_MIN),  -- NonP started here
      pci_nonp_limit => (m32min_v(31 downto 0)-1),   -- NonP ended here
      pci_io_base => (EBFM_BAR_IO_MIN),  -- I/O Started Here
      pci_io_limit => (io_min_v-1)      -- I/O ended Here
      ) ;

    ebfm_cfgwr_imm_wait(ep_bus_num,ep_dev_num,0,4,4,X"00000007",compl_status);

    -- Protect the bar table from being accidentally overwritten.
    protect_bfm_shmem := 1;

  end ebfm_cfg_rp_ep;

  -- purpose: returns whether specified BAR is memory or I/O and the size
  procedure ebfm_cfg_decode_bar (
    constant bar_table    : in  natural;              -- Pointer to BAR info
    constant bar_num      : in  natural;              -- bar number to check
    variable log2_size    : out natural;              -- Log base 2 of the Size
    variable is_mem       : out std_logic;            -- Is memory (not I/O)
    variable is_pref      : out std_logic;            -- Is prefetchable
    variable is_64b       : out std_logic             -- Is 64bit
    ) is
    variable bar64 : std_logic_vector(63 downto 0);
    constant ZERO32  : std_logic_vector(31 downto 0) := (others => '0');
    variable maxlsb : natural;
  begin
    bar64 := shmem_read((bar_table+32+(bar_num*4)),8) ;

    if (bar64(31 downto 0) = ZERO32) then
      log2_size :=  0  ;
      is_mem    := '0' ;
      is_pref   := '0' ;
      is_64b    := '0' ;
    else
      is_mem  := not bar64(0) ;
      is_pref := (not bar64(0)) and bar64(3) ;
      is_64b  := (not bar64(0)) and bar64(2) ;
      if ( (bar64(0) = '1') or (bar64(2) = '0') )  then
        maxlsb := 31 ;
      else
        maxlsb := 63 ;
      end if;
      check_loop : for i in 4 to maxlsb loop
        if bar64(i) = '1' then
          log2_size := i ;
          exit check_loop;
        end if;
      end loop check_loop;  -- i in 4 to maxlsb
    end if;
  end procedure ebfm_cfg_decode_bar ;

end altpcietb_bfm_configure;
