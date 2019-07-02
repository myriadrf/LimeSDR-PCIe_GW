-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Package of basic constants 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_constants.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This package provides a set of constants that are used globally in other
-- packages and modules.
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

package altpcietb_bfm_constants is

  -- Root Port Primary Side Bus Number and Device Number
  constant RP_PRI_BUS_NUM  : natural := 0 ;
  constant RP_PRI_DEV_NUM  : natural := 0 ;
  -- Root Port Requester ID
  constant RP_REQ_ID : std_logic_vector(15 downto 0) :=
    std_logic_vector(to_unsigned(RP_PRI_BUS_NUM,8)) &
    std_logic_vector(to_unsigned(RP_PRI_DEV_NUM,5)) &
    "000" ; -- used in the Requests sent out

  -- 2MB of memory
  constant SHMEM_ADDR_WIDTH : natural := 21 ;
  subtype shmem_addr_type is std_logic_vector(SHMEM_ADDR_WIDTH-1 downto 0);

  -- The first section of the PCI Express I/O Space will be reserved for
  -- addressing the Root Port's Shared Memory. PCI Express I/O Initiators
  -- would use an I/O address in this range to access the shared memory.
  -- Likewise the first section of the PCI Express Memory Space will be
  -- reserved for accessing the Root Port's Shared Memory. PCI Express
  -- Memory Initiators will use this range to access this memory.
  -- These values here set the range that can be used to assign the
  -- EP BARs to. 
  constant EBFM_BAR_IO_MIN  : unsigned(31 downto 0) := to_unsigned((2**SHMEM_ADDR_WIDTH),32) ;
  constant EBFM_BAR_IO_MAX  : unsigned(31 downto 0) := (others => '1');
  constant EBFM_BAR_M32_MIN : unsigned(31 downto 0) := to_unsigned((2**SHMEM_ADDR_WIDTH),32) ;
  constant EBFM_BAR_M32_MAX : unsigned(31 downto 0) := (others => '1');
  constant EBFM_BAR_M64_MIN : unsigned(63 downto 0) := (32 => '1', others => '0');
  constant EBFM_BAR_M64_MAX : unsigned(63 downto 0) := (others => '1');

  constant EBFM_NUM_VC : natural := 4;    -- Number of VC's implemented in the Root Port BFM
  constant EBFM_NUM_TAG : natural := 32;  -- Number of TAG's used by Root Port BFM
 

end altpcietb_bfm_constants;
