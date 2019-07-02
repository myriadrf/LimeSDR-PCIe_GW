-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Root Shared Memory Package
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcie_bfm_shmem.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This entity provides the Root Port BFM shared memory which can be used for
-- the following functions
-- * Source of data for transmitted write operations
-- * Source of data for received read operations
-- * Receipient of data for received write operations
-- * Receipient of data for received completions
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

package altpcietb_bfm_shmem is

  procedure shmem_write (
    constant addr : in natural;
    constant data : in std_logic_vector;
    constant leng : in natural := 0) ;   

  impure function shmem_read (
    constant addr : natural;
    constant leng : natural := 8 )
    return std_logic_vector ;

  -- purpose: display shared memory data
  procedure shmem_display (
    constant addr      : in natural;
    constant leng      : in natural;
    constant word_size : in natural := 4;
    constant flag_addr : in natural := natural'high;
    constant msg_type  : in natural := EBFM_MSG_INFO
    );

  constant SHMEM_FILL_ZERO      : natural := 0;
  constant SHMEM_FILL_BYTE_INC  : natural := 1;
  constant SHMEM_FILL_WORD_INC  : natural := 2;
  constant SHMEM_FILL_DWORD_INC : natural := 4;
  constant SHMEM_FILL_QWORD_INC : natural := 8;
  constant SHMEM_FILL_ONE       : natural := 15;
  constant SHMEM_SIZE           : natural := 2**SHMEM_ADDR_WIDTH;  
  constant BAR_TABLE_SIZE       : natural := 64;
  constant BAR_TABLE_POINTER    : natural := SHMEM_SIZE - BAR_TABLE_SIZE;  
  constant SCR_SIZE             : natural := 64;
  constant CFG_SCRATCH_SPACE    : natural := SHMEM_SIZE - BAR_TABLE_SIZE - SCR_SIZE;  

  shared variable protect_bfm_shmem : natural := 1;

  procedure shmem_fill (
    constant addr : in natural;
    constant mode : in natural;
    constant leng : in natural := 128;  -- Length to fill in bytes
    constant init : in std_logic_vector(63 downto 0) := (others => '0')
    ) ;

  impure function shmem_chk_ok (
    constant addr : in natural;
    constant mode : in natural;
    constant leng : in natural := 128;  -- Length to fill in bytes
    constant init : in std_logic_vector(63 downto 0) := (others => '0');
    constant display_error : in natural := 1
    ) return boolean ;

end altpcietb_bfm_shmem;

package body altpcietb_bfm_shmem is

  subtype byte_type is bit_vector(7 downto 0); -- BIT_VECTOR saves sim memory?

  type shmem_type is array (0 to SHMEM_SIZE-1) of byte_type;

  shared variable shmem : shmem_type := (others => "00000000") ;

  procedure shmem_write (
    constant addr : in natural;
    constant data : in std_logic_vector;
    constant leng : in natural := 0) is 
    variable rleng : natural := leng ;
    constant bv_data : bit_vector(data'length-1 downto 0) := To_BitVector(data);
  begin 
    if ( addr < BAR_TABLE_POINTER + BAR_TABLE_SIZE and addr >= CFG_SCRATCH_SPACE and protect_bfm_shmem = 1 ) then
      ebfm_display(EBFM_MSG_ERROR_INFO, "Task SHMEM_WRITE attempted to overwrite the write protected area of the shared memory") ;
      ebfm_display(EBFM_MSG_ERROR_INFO, "This protected area contains the following data critical to the operation of the BFM:") ;
      ebfm_display(EBFM_MSG_ERROR_INFO, "The BFM internal memory area, 64B located at " & himage(CFG_SCRATCH_SPACE)) ;
      ebfm_display(EBFM_MSG_ERROR_INFO, "The BAR Table, 64B located at " & himage(BAR_TABLE_POINTER)) ;
      ebfm_display(EBFM_MSG_ERROR_INFO, "Please change your SHMEM_WRITE call to a different memory location") ;
      ebfm_display(EBFM_MSG_ERROR_FATAL, "Halting Simulation") ;
    end if;
    if ( (leng = 0) or (leng > (data'length/8)) ) then
      rleng := (data'LENGTH/8) ;
    end if;
    for i in 0 to (rleng-1) loop
      shmem(addr + i) := bv_data((i*8)+7 downto (i*8)) ;
    end loop;  -- i
  end procedure shmem_write ;

  impure function shmem_read (
    constant addr : natural;
    constant leng : natural := 8 )
    return std_logic_vector is
    variable rdata : bit_vector((leng*8)-1 downto 0) := (others => '0');
  begin
    for i in 0 to (leng-1) loop
      rdata((i*8)+7 downto (i*8)) := shmem(addr + i) ;
    end loop;  -- i
    return(To_StdLogicVector(rdata)) ;
  end function shmem_read ;

  -- purpose: display shared memory data
  procedure shmem_display (
    constant addr      : in natural;
    constant leng      : in natural;
    constant word_size : in natural := 4;
    constant flag_addr : in natural := natural'high;
    constant msg_type  : in natural := EBFM_MSG_INFO
    ) is
    variable incr      :    natural := 16;
    variable iaddr     :    natural := addr;
    variable l         :    line;
  begin  -- shmem_display

    -- Backup address to beginning of word if needed
    if (iaddr mod word_size > 0) then
      iaddr := iaddr - (iaddr mod word_size) ;
    end if;
    
    ebfm_display(msg_type, "") ;
    ebfm_display(msg_type, "Shared Memory Data Display:") ;
    ebfm_display(msg_type, "Address  Data") ;
    ebfm_display(msg_type, "-------  ----") ;
    
    while (iaddr < (addr + leng)) loop
      write(l,himage(iaddr)) ;
      write(l,' ') ;
      one_line : for i in 0 to ((incr/word_size)-1) loop
        exit one_line when ((iaddr + (word_size * i)) >= (addr + leng));
        write(l,himage(shmem_read(iaddr+(i*word_size),word_size))) ;
        write(l,' ') ;
      end loop one_line ;  -- i
      if (flag_addr >= iaddr) and (flag_addr < (iaddr+incr)) then
        write(l,string'("<===")) ;
      end if;
      ebfm_display(msg_type,l.all) ;
      deallocate(l) ;
      iaddr := iaddr + incr ;
    end loop;
  end shmem_display;

  procedure shmem_fill (
    constant addr : in natural;
    constant mode : in natural;
    constant leng : in natural := 128;  -- Length to fill in bytes
    constant init : in std_logic_vector(63 downto 0) := (others => '0')
    ) is
    variable rembytes : natural := leng;
    variable data : std_logic_vector(63 downto 0) := init;
    variable uaddr : natural := addr;
    constant ZDATA : std_logic_vector(7 downto 0) := (others => '0');
    constant ODATA : std_logic_vector(7 downto 0) := (others => '1');
  begin
    while (rembytes > 0) loop
      case mode is
        when SHMEM_FILL_ZERO      =>
          shmem_write(uaddr,ZDATA) ;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_BYTE_INC  =>          
          shmem_write(uaddr,data(7 downto 0)) ;
          data(7 downto 0) := std_logic_vector(unsigned(data(7 downto 0)) + 1) ;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_WORD_INC  =>
          for i in 0 to 1 loop
            if (rembytes > 0) then
              shmem_write(uaddr,data(((i*8)+7) downto (i*8))) ;
              rembytes := rembytes - 1 ;
              uaddr := uaddr + 1 ;
            end if;
          end loop;  -- i
          data(15 downto 0) := std_logic_vector(unsigned(data(15 downto 0)) + 1) ;
        when SHMEM_FILL_DWORD_INC =>
          for i in 0 to 3 loop
            if (rembytes > 0) then
              shmem_write(uaddr,data(((i*8)+7) downto (i*8))) ;
              rembytes := rembytes - 1 ;
              uaddr := uaddr + 1 ;
            end if;
          end loop;  -- i
          data(31 downto 0) := std_logic_vector(unsigned(data(31 downto 0)) + 1) ;
        when SHMEM_FILL_QWORD_INC =>
          for i in 0 to 7 loop
            if (rembytes > 0) then
              shmem_write(uaddr,data(((i*8)+7) downto (i*8))) ;
              rembytes := rembytes - 1 ;
              uaddr := uaddr + 1 ;
            end if;
          end loop;  -- i
          data(63 downto 0) := std_logic_vector(unsigned(data(63 downto 0)) + 1) ;
        when SHMEM_FILL_ONE       =>
          shmem_write(uaddr,ODATA) ;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when others => null;
      end case;
    end loop;
  end procedure shmem_fill ;

  -- Returns -1 if okay, else returns address of the miscompare 
  impure function shmem_chk_ok (
    constant addr : in natural;
    constant mode : in natural;
    constant leng : in natural := 128;  -- Length to fill in bytes
    constant init : in std_logic_vector(63 downto 0) := (others => '0');
    constant display_error : in natural := 1
    ) return boolean is
    variable rembytes : natural := leng;
    variable data : std_logic_vector(63 downto 0) := init;
    variable actual : std_logic_vector(63 downto 0) := init;
    variable uaddr : natural := addr;
    variable daddr : integer;
    variable dlen  : natural;
    variable incr_count : natural := 0;
    constant ZDATA : std_logic_vector(7 downto 0) := (others => '0');
    constant ODATA : std_logic_vector(7 downto 0) := (others => '1');
    variable actline : line;
    variable expline : line;
    variable word_size : natural  := 1;
  begin
    case mode is
      when SHMEM_FILL_WORD_INC  => word_size := 2 ;
      when SHMEM_FILL_DWORD_INC => word_size := 4 ;
      when SHMEM_FILL_QWORD_INC => word_size := 8 ;
      when others => word_size := 1 ;
    end case;
    compare_loop :while (rembytes > 0) loop
      case mode is
        when SHMEM_FILL_ZERO      =>
          actual(7 downto 0) := shmem_read(uaddr,1) ;
          if (actual(7 downto 0) /= ZDATA) then
            write(expline,string'("    Expected Data: ")) ;
            write(expline,himage(ZDATA(7 downto 0))) ;
            write(actline,string'("      Actual Data: ")) ;
            write(actline,himage(actual(7 downto 0))) ;
            exit compare_loop;
          end if;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_BYTE_INC  =>          
          actual(7 downto 0) := shmem_read(uaddr,1) ;
          if (actual(7 downto 0) /= data(7 downto 0)) then
            write(expline,string'("    Expected Data: ")) ;
            write(expline,himage(data(7 downto 0))) ;
            write(actline,string'("      Actual Data: ")) ;
            write(actline,himage(actual(7 downto 0))) ;
            exit compare_loop;
          end if;
          data(7 downto 0) := std_logic_vector(unsigned(data(7 downto 0)) + 1) ;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_WORD_INC  =>
          actual(7 downto 0) := shmem_read(uaddr,1) ;
          if (actual(7 downto 0) /= data(((incr_count*8)+7) downto (incr_count*8))) then
            write(expline,string'("    Expected Data: ")) ;
            write(expline,himage(data(((incr_count*8)+7) downto (incr_count*8)))) ;
            write(actline,string'("      Actual Data: ")) ;
            write(actline,himage(actual(7 downto 0))) ;
            exit compare_loop;
          end if;
          if (incr_count = 1) then
            data(15 downto 0) := std_logic_vector(unsigned(data(15 downto 0)) + 1) ;
            incr_count := 0 ;
          else
            incr_count := incr_count + 1 ;
          end if;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_DWORD_INC =>
          actual(7 downto 0) := shmem_read(uaddr,1) ;
          if (actual(7 downto 0) /= data(((incr_count*8)+7) downto (incr_count*8))) then
            write(expline,string'("    Expected Data: ")) ;
            write(expline,himage(data(((incr_count*8)+7) downto (incr_count*8)))) ;
            write(actline,string'("      Actual Data: ")) ;
            write(actline,himage(actual(7 downto 0))) ;
            exit compare_loop;
          end if;
          if (incr_count = 3) then
            data(31 downto 0) := std_logic_vector(unsigned(data(31 downto 0)) + 1) ;
            incr_count := 0 ;
          else
            incr_count := incr_count + 1 ;
          end if;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_QWORD_INC =>
          actual(7 downto 0) := shmem_read(uaddr,1) ;
          if (actual(7 downto 0) /= data(((incr_count*8)+7) downto (incr_count*8))) then
            write(expline,string'("    Expected Data: ")) ;
            write(expline,himage(data(((incr_count*8)+7) downto (incr_count*8)))) ;
            write(actline,string'("      Actual Data: ")) ;
            write(actline,himage(actual(7 downto 0))) ;
            exit compare_loop;
          end if;
          if (incr_count = 7) then
            data(63 downto 0) := std_logic_vector(unsigned(data(63 downto 0)) + 1) ;
            incr_count := 0 ;
          else
            incr_count := incr_count + 1 ;
          end if;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when SHMEM_FILL_ONE       =>
          actual(7 downto 0) := shmem_read(uaddr,1) ;
          if (actual(7 downto 0) /= ODATA) then
            write(expline,string'("    Expected Data: ")) ;
            write(expline,himage(ODATA(7 downto 0))) ;
            write(actline,string'("      Actual Data: ")) ;
            write(actline,himage(actual(7 downto 0))) ;
            exit compare_loop;
          end if;
          rembytes := rembytes - 1 ;
          uaddr := uaddr + 1 ;
        when others => null;
      end case;
    end loop compare_loop;
    if (rembytes > 0)  then
      -- There was a miscompare, display an error message
      if (display_error = 1) then
        ebfm_display(EBFM_MSG_ERROR_INFO,"") ;
        ebfm_display(EBFM_MSG_ERROR_INFO,"Shared memory data miscompare at address: " & himage(uaddr)) ;
        ebfm_display(EBFM_MSG_ERROR_INFO,expline.all) ;
        ebfm_display(EBFM_MSG_ERROR_INFO,actline.all) ;
        -- Backup and display a little before the miscompare
        -- Figure amount to backup
        daddr := uaddr mod 32 ;  -- Back up no more than 32 bytes
        if (daddr < 16) then -- But at least 16
          daddr := daddr + 16 ;
        end if;
        -- Backed up display address 
        daddr := uaddr - daddr ;
        -- Don't backup more than start of compare 
        if (daddr < addr)  then
          daddr := addr ; 
        end if;
        -- Try to display 64 bytes 
        dlen := 64 ;
        -- But don't display beyond the end of the compare
        if (daddr + dlen > addr + leng) then
          dlen := (addr + leng) - daddr ;
        end if;
        shmem_display(daddr,dlen,word_size,uaddr,EBFM_MSG_ERROR_INFO) ;
      end if;
      return FALSE;
    else
      return TRUE;
    end if;
  end function shmem_chk_ok ;

end altpcietb_bfm_shmem;
