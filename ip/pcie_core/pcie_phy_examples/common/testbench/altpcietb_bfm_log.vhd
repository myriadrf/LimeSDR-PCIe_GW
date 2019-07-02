-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Message Logging Package 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_log.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This packeage provides routines to log various information to the standard
-- output 
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
use ieee.std_logic_textio.all;

package altpcietb_bfm_log is

  constant EBFM_MSG_DEBUG               : natural := 0;
  constant EBFM_MSG_INFO                : natural := 1;
  constant EBFM_MSG_WARNING             : natural := 2;
  constant EBFM_MSG_ERROR_INFO          : natural := 3; -- Preliminary Error
                                                        -- Info Message 
  constant EBFM_MSG_ERROR_CONTINUE      : natural := 4;
  -- Fatal Error Messages always stop the simulation
  constant EBFM_MSG_ERROR_FATAL         : natural := 101;
  constant EBFM_MSG_ERROR_FATAL_TB_ERR  : natural := 102;
  
  subtype EBFM_MSG_MASK is
    std_logic_vector(EBFM_MSG_ERROR_CONTINUE downto EBFM_MSG_DEBUG);

  -- purpose: This displays a message of the specified type
  procedure ebfm_display (
    constant msg_type : in natural;
    constant message  : in string) ;

  -- purpose: stops the simulation, with flag to indicate success or not
  procedure ebfm_log_stop_sim (
    constant success : in natural := 0);
  
  -- purpose: sets the suppressed_msg_mask
  procedure ebfm_log_set_suppressed_msg_mask (
    constant msg_mask : in EBFM_MSG_MASK) ;
  
  -- purpose: sets the stop_on_msg_mask
  procedure ebfm_log_set_stop_on_msg_mask (
    constant msg_mask : in EBFM_MSG_MASK) ;
  
  -- purpose: Opens the Log File with the specified name
  procedure ebfm_log_open (
    constant fn : in string) ;         -- Log File Name

  -- purpose: Opens the Log File with the specified name
  procedure ebfm_log_close ;

  -- purpose: produce hexadecimal string from a std_logic_vector
  function himage (
    constant vec : in std_logic_vector) return string ;

  -- purpose: produce hexadecimal string from an integer
  function himage (
    constant num : integer ;
    constant hlen : natural := 8 ) return string ;

end altpcietb_bfm_log;

package body altpcietb_bfm_log is

  file log_file : text ;       

  shared variable log_file_open : boolean := FALSE;

  shared variable suppressed_msg_mask : EBFM_MSG_MASK :=
    (EBFM_MSG_DEBUG => '1',
     others => '0');

  shared variable stop_on_msg_mask : EBFM_MSG_MASK := (others => '0');

  -- purpose: sets the suppressed_msg_mask
  procedure ebfm_log_set_suppressed_msg_mask (
    constant msg_mask : in EBFM_MSG_MASK) is
  begin  -- ebfm_log_set_suppressed_msg_mask
    suppressed_msg_mask := msg_mask ;
  end ebfm_log_set_suppressed_msg_mask;
  
  -- purpose: sets the stop_on_msg_mask
  procedure ebfm_log_set_stop_on_msg_mask (
    constant msg_mask : in EBFM_MSG_MASK) is
  begin  -- ebfm_log_set_stop_on_msg_mask
    stop_on_msg_mask := msg_mask ;
  end ebfm_log_set_stop_on_msg_mask;
  
  -- purpose: Opens the Log File with the specified name
  procedure ebfm_log_open (
    constant fn : in string) is         -- Log File Name
  begin  -- ebfm_log_open
    file_open(log_file,fn,WRITE_MODE) ;
    log_file_open := TRUE ;
  end ebfm_log_open;

  -- purpose: Opens the Log File with the specified name
  procedure ebfm_log_close  is    
  begin  -- ebfm_log_close
    file_close(log_file) ;
    log_file_open := FALSE ;
  end ebfm_log_close;

  -- purpose: stops the simulation, with flag to indicate success or not
  procedure ebfm_log_stop_sim (
    constant success : in natural := 0) is
  begin
    if (success = 1) then
      assert FALSE report "SUCCESS: Simulation stopped due to successful completion!" severity FAILURE;
    else
      assert FALSE report "FAILURE: Simulation stopped due to error!" severity FAILURE;
    end if;
  end ebfm_log_stop_sim ;

  -- purpose: This displays a message of the specified type
  procedure ebfm_display (
    constant msg_type : in natural;
    constant message  : in string) is
    variable lmsg : line;
    variable amsg : line;               -- amsg
    variable sup : std_logic := '1' ;
    variable stp : std_logic := '0' ;
  begin  -- ebfm_display
    if (msg_type > EBFM_MSG_MASK'high) then
      sup := '0' ;
      stp := '1' ;
      case msg_type is
        when EBFM_MSG_ERROR_FATAL => 
          write(amsg,string'("FAILURE: Simulation stopped due to Fatal error!")) ;
          write(lmsg,string'("FATAL: "),left,9) ;
        when EBFM_MSG_ERROR_FATAL_TB_ERR => 
          write(amsg,string'("FAILURE: Simulation stopped due error in Testbench/BFM design!")) ;
          write(lmsg,string'("FATAL: "),left,9) ;
        when others =>
          write(amsg,string'("FAILURE: Simulation stopped due to unknown message type!")) ;
          write(lmsg,string'("FATAL: "),left,9) ;
      end case;
    else
      sup := suppressed_msg_mask(msg_type) ;
      stp := stop_on_msg_mask(msg_type) ;
      if (stp = '1') then
          write(amsg,string'("FAILURE: Simulation stopped due to enabled error!")) ;        
      end if;
      if (msg_type < EBFM_MSG_INFO) then
        write(lmsg,string'("DEBUG: "),left,9);
      else
        if (msg_type < EBFM_MSG_WARNING) then
          write(lmsg,string'("INFO: "),left,9);
        else
          if (msg_type > EBFM_MSG_WARNING) then
            write(lmsg,string'("ERROR: "),left,9);
          else
            write(lmsg,string'("WARNING: "),left,9); 
          end if;
        end if;
      end if;
    end if;

    -- Display the message if not suppressed
    if (sup /= '1') then
      write(lmsg,now,right,10,ns) ;
      write(lmsg,string'(" ")) ;
      write(lmsg,message) ;
      if (log_file_open) then
        writeline(log_file,lmsg) ;
      end if;
      writeline(output,lmsg) ;
    end if;

    -- Stop if requested
    if (stp = '1') then
      if (log_file_open) then
        writeline(log_file,amsg) ;
      end if;
      writeline(output,amsg) ;
      ebfm_log_stop_sim(0) ;      
    end if;
  end ebfm_display;
  
  -- purpose: produce hexadecimal string from a std_logic_vector
  function himage (
    constant vec : in std_logic_vector) return string is
    variable l : line;
  begin  -- himage
    hwrite(l,vec) ;
    return l.all;
  end himage;

  -- purpose: produce hexadecimal string from an integer
  function himage (
    constant num  : integer ;
    constant hlen : natural := 8 )     
    return string is
  begin  -- himage
    return himage(std_logic_vector(to_signed(num,(4*hlen)))) ;
  end himage;
  
end altpcietb_bfm_log;
