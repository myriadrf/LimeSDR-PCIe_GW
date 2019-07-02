-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Root Port Driver 
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_common.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This entity is driver for the Root Port BFM. It processes the list of
-- functions to perform and passes them off to the VC specific interfaces
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

entity altpcietb_bfm_log_common is

  port (
    dummy_out            : out  std_logic    
    );

end altpcietb_bfm_log_common;

architecture rtl of altpcietb_bfm_log_common is
  begin
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity altpcietb_bfm_shmem_common is

  port (
    dummy_out            : out  std_logic    
    );

end altpcietb_bfm_shmem_common;

architecture rtl of altpcietb_bfm_shmem_common is
  begin
end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity altpcietb_bfm_req_intf_common is

  port (
    dummy_out            : out  std_logic    
    );

end altpcietb_bfm_req_intf_common;

architecture rtl of altpcietb_bfm_req_intf_common is
  begin
  end rtl;
