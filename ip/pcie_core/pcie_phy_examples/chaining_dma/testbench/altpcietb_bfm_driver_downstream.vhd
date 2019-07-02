-- /**
--  * This VHDL file is used for simulation in
--  * the downstream design example.
--  */
-------------------------------------------------------------------------------
-- Title         : PCI Express BFM Root Port Driver for the chained DMA
--                 design example
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcietb_bfm_driver.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description : This module is driver for the Root Port BFM for the chained DMA
--               design example.
--     The main process (begin : main) operates in two stages:
--        - EP configuration using the task ebfm_cfg_rp_ep
--        - Run a chained DMA transfer with the task chained_dma_test
--
--    Chained DMA operation:
--       The chained DMA consist of a DMA Write and a DMA Read sub-module
--       Each DMA use a separate descriptor table mapped in the share memeory
--       The descriptor table contains a header with 3 DWORDs (DW0, DW1, DW2)
--
--       |31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16|15 .................0
--   ----|---------------------------------------------------------------------
--       | R|        |         |              |  | E|M| D |
--   DW0 | E| MSI    |         |              |  | P|S| I |
--       | S|TRAFFIC |         |              |  | L|I| R |
--       | E|CLASS   | RESERVED|  MSI         |1 | A| | E |      SIZE:Number
--       | R|        |         |  NUMBER      |  | S| | C |   of DMA descriptor
--       | V|        |         |              |  | T| | T |
--       | E|        |         |              |  |  | | I |
--       | D|        |         |              |  |  | | O |
--       |  |        |         |              |  |  | | N |
--   ----|---------------------------------------------------------------------
--   DW1 |                                       BDT_MSB
--   ----|---------------------------------------------------------------------
--   DW2 |                                       BDT_LSB
--   ----|---------------------------------------------------------------------
--
-- RC memory map Overview - Descriptor section
--
--   RC memory  : 2Mbyte 0h -> 200000h
--   BRC+00000h : Descriptor table write
--   BRC+00100h : Descriptor table read
--   BRC+01000h : Data for write
--   BRC+05000h : Data for read
--
-------------------------------------------------------------------------------
--
-- Abreviation:
--     EP      : End Point
--     RC      : Root complex
--     DT      : Descriptor Table
--     MWr     : Memory write
--     MRd     : Memory read
--     CPLD    : Completion with data
--     MSI     : PCIe Message Signaled Interrupt
--     BDT     : Base address of the descriptor header table in RC memory
--     BDT_LSB : Base address of the descriptor header table in RC memory
--     BDT_MSB : Base address of the descriptor header table in RC memory
--     BRC     : [BDT_MSB:BDT_LSB]
--     DW0     : First DWORD of the descriptor table header
--     DW1     : Second DWORD of the descriptor table header
--     DW2     : Third DWORD of the descriptor table header
--     RCLAST  : RC MWr RCLAST in EP memeory to reflects the number
--               of DMA transfers ready to start
--     EPLAST  : EP MWr EPLAST in shared memeory to reflects the number
--               of completed DMA transfers
-------------------------------------------------------------------------------
-- Copyright ??? 2006 Altera Corporation. All rights reserved.  Altera products are
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
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_rdwr.all;
use work.altpcietb_bfm_configure.all;

package altpcietb_downstream is

    CONSTANT SCR_MEM           : natural := 2 ** 11;  -- Share memory base address used by DMA
    CONSTANT SCR_MEMSLAVE          : natural := 64;     -- Share memory base address used by RC Slave module
    CONSTANT SCR_MEM_DOWNSTREAM_WR : natural := SCR_MEMSLAVE;
    CONSTANT SCR_MEM_DOWNSTREAM_RD : natural := SCR_MEMSLAVE+2048;
    CONSTANT MAX_RCPAYLOAD         : natural := 128;
    CONSTANT RCSLAVE_MAXLEN        : natural := 10;  -- maximum number of read/write
    CONSTANT RCLAST_DESCRIPTOR : natural := 3;        --3;
    CONSTANT DESCRIPTOR_SIZE   : natural := 3;        --3;
    CONSTANT TIMEOUT_POLLING    : natural := 2048;    -- number of clock' for timout

                                             -- EP_LAST
    CONSTANT DISPLAY_ALL         : natural := 0;

    CONSTANT STR_SEP  : string  :=
                "---------";

    impure function find_mem_bar (
       constant bar_table : natural ;
       constant allowed_bars    : std_logic_vector(5 downto 0);
       constant min_log2_size   : natural
       ) return natural;

   function TO_DWORD (constant val : in natural)
         return std_logic_vector;

   function TO_QWORD (constant val : in natural)
         return std_logic_vector;

    procedure ebfm_display_verb (
     constant msg_type : in natural;
     constant message  : in string);

end altpcietb_downstream ;

package body altpcietb_downstream is

   function TO_DWORD (constant val : in natural) return std_logic_vector is
   -- convert natural to 32 bit std_logic_vector
   begin
      return std_logic_vector(to_unsigned(val,32));
   end TO_DWORD;

   function TO_QWORD (constant val : in natural) return std_logic_vector is
   -- convert natural to 64 bit std_logic_vector
   begin
      return std_logic_vector(to_unsigned(val,64));
   end TO_QWORD;


   FUNCTION TO_STDLOGICVECTOR (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS

      VARIABLE rtn : std_logic_vector(len-1 DOWNTO 0):=(OTHERS => '0');
      VARIABLE num : integer := val;
      VARIABLE r   : integer;
   BEGIN
      FOR index IN 0 TO len-1 LOOP
         r := num rem 2;
         num := num/2;
         IF (r = 1) THEN
            rtn(index) := '1';
         ELSE
            rtn(index) := '0';
         END IF;
      END LOOP;
      RETURN(rtn);
   END TO_STDLOGICVECTOR;

   ------------------------------------------------------------------------/
   --
   -- Procedure: find_mem_bar :
   --
   -- purpose: Use Reads and Writes to test the target memory
   --          The starting offset in the target memory and the
   --          length can be specified
   -- purpose: Examine the DUT's BAR setup and pick a reasonable BAR to use
   impure function find_mem_bar (
    constant bar_table : natural ;
    constant allowed_bars    : std_logic_vector(5 downto 0);
    constant min_log2_size   : natural
    ) return natural is
    variable cur_bar : natural := 0;
    variable bar32 : std_logic_vector(31 downto 0) ;
    variable log2_size : natural;
    variable is_mem : std_logic ;
    variable is_pref : std_logic ;
    variable is_64b : std_logic ;
   begin  -- find_mem_bar
    chk_loop : while (cur_bar < 6) loop
      ebfm_cfg_decode_bar(bar_table,cur_bar,log2_size,is_mem,is_pref,is_64b) ;
      if ( (is_mem = '1') and
           (log2_size >= min_log2_size) and
           (allowed_bars(cur_bar) = '1') ) then
        return cur_bar;
      end if;
      if (is_64b = '1') then
        cur_bar := cur_bar + 2 ;
      else
        cur_bar := cur_bar + 1 ;
      end if;
    end loop chk_loop;
    return natural'high; -- Invalid BAR if we get this far...
   end find_mem_bar;

   procedure ebfm_display_verb (
      constant msg_type : in natural;
      constant message  : in string) is
   begin
      if (DISPLAY_ALL=1) then
         ebfm_display(msg_type, message);
      end if;
   end ebfm_display_verb;

end altpcietb_downstream;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.altpcietb_bfm_constants.all;
use work.altpcietb_bfm_log.all;
use work.altpcietb_bfm_shmem.all;
use work.altpcietb_bfm_rdwr.all;
use work.altpcietb_bfm_configure.all;
use work.altpcietb_downstream.all;

entity altpcietb_bfm_driver_downstream is
  generic (
    -- TEST_LEVEL is a parameter passed in from the top level test bench that
    -- could control the amount of testing done. It is not currently used.
    TEST_LEVEL : natural := 1
    );
  port (
    -- The clk_in and rstn signals are provided for possible use in controlling
    -- the transactions issued, they are not currently used.
    clk_in    : in  std_logic;
    rstn      : in  std_logic;
    INTA      : in  std_logic;
    INTB      : in  std_logic;
    INTC      : in  std_logic;
    INTD      : in  std_logic;
    dummy_out : out  std_logic
    );


--
--TASK:downstream_write
-- Prior to run DMA test, this task clears the performance counters
--
procedure downstream_write(
   constant bar_table   : in natural;    -- Pointer to the BAR sizing and
   constant setup_bar   : in natural;    -- Pointer to the BAR sizing and
   constant address     : in natural;    -- Downstream EP memeory address in byte
   constant data        : in std_logic_vector(63 DOWNTO 0);
   constant byte_length : in natural     -- BAR to be used for setting up

 ) is

   begin
      -- Write a data
      shmem_fill(SCR_MEM_DOWNSTREAM_WR,SHMEM_FILL_QWORD_INC,byte_length,data);
      ebfm_barwr(bar_table,setup_bar,address,SCR_MEM_DOWNSTREAM_WR,byte_length,0);

end downstream_write;

--
--
-- TASK:downstream_read
-- Prior to run DMA test, this task clears the performance counters
--
procedure downstream_read(
   constant bar_table   : in natural;    -- Pointer to the BAR sizing and
   constant setup_bar   : in natural;    -- Pointer to the BAR sizing and
   constant address     : in natural;    -- Downstream EP memeory address in byte
   constant byte_length : in natural     -- BAR to be used for setting up
) is

   begin
      -- read a data
      shmem_fill(SCR_MEM_DOWNSTREAM_RD,SHMEM_FILL_QWORD_INC,byte_length,x"FADE_FADE_FADE_FADE");
      ebfm_barrd_wait(bar_table,setup_bar,address,SCR_MEM_DOWNSTREAM_RD,byte_length,0);

end downstream_read;

procedure scr_memory_compare(
   constant byte_length : in natural;    -- downstream wr/rd length in byte
   constant scr_memorya : in natural;
   constant scr_memoryb : in natural
  ) is

   variable i : natural;
   variable bytea : std_logic_vector(7 DOWNTO 0);
   variable byteb : std_logic_vector(7 DOWNTO 0);
   variable addra : natural;
   variable addrb : natural;

   begin

      addra := scr_memorya;
      addrb := scr_memoryb;

      for i in 1 to byte_length+ 1 loop

         bytea := shmem_read(addra,1);
         byteb := shmem_read(addrb,1);
         addra := addra+1;
         addrb := addrb+1;
         IF (NOT (bytea=byteb)) THEN

            ebfm_display(EBFM_MSG_INFO, "Content of the RC memory A");
            shmem_display(scr_memorya, byte_length, 4, scr_memorya + byte_length, EBFM_MSG_INFO);
            ebfm_display(EBFM_MSG_INFO, "Content of the RC memory B");
            shmem_display(scr_memoryb, byte_length, 4, scr_memoryb + byte_length, EBFM_MSG_INFO);

            ebfm_display(EBFM_MSG_INFO, (" A: 0x" & himage(addra) &  ": " & himage(bytea)));
            ebfm_display(EBFM_MSG_INFO, (" B: 0x" & himage(addrb) &  ": " & himage(byteb)));
            ebfm_display(EBFM_MSG_ERROR_FATAL, ("Different memory content for " & himage(byte_length) & " bytes test"));
         END IF;

      end loop;

      ebfm_display(EBFM_MSG_INFO, ("Passed: " & himage(byte_length) &
                             " same bytes in BFM mem addr 0x" &  himage(scr_memorya) &
                             " and 0x" &  himage(scr_memoryb)));


end scr_memory_compare;

   FUNCTION TO_STDLOGICVECTOR (
      val      : IN integer;
      len      : IN integer) RETURN std_logic_vector IS

      VARIABLE rtn : std_logic_vector(len-1 DOWNTO 0):=(OTHERS => '0');
      VARIABLE num : integer := val;
      VARIABLE r   : integer;
   BEGIN
      FOR index IN 0 TO len-1 LOOP
         r := num rem 2;
         num := num/2;
         IF (r = 1) THEN
            rtn(index) := '1';
         ELSE
            rtn(index) := '0';
         END IF;
      END LOOP;
      RETURN(rtn);
   END TO_STDLOGICVECTOR;

procedure downstream_loop(
   constant bar_table     : in natural;  -- Pointer to the BAR sizing and
   constant setup_bar     : in natural;  -- Pointer to the BAR sizing and
   constant loop_count    : in natural;  -- Number of Write/read iteration
   constant byte_length   : in natural;  -- downstream wr/rd length in byte
   constant epmem_address : in natural;  -- Downstream EP memory address in byte
   constant start_val     : in std_logic_vector(63 DOWNTO 0)   -- Starting write data value
   ) is


   variable Istart_val_vector : std_logic_vector(63 DOWNTO 0) := (others => '0');
   variable Iepmem_address    : natural:=0;
   variable i                 : natural:=0;
   variable Ibyte_length      : natural:=0;
   variable cfg_reg           : natural;
   variable cfg_maxpload_byte : natural;

   begin
      ebfm_display(EBFM_MSG_INFO, STR_SEP);
      ebfm_display(EBFM_MSG_INFO, "TASK:downstream_loop ");

      cfg_reg           := 0;
      cfg_maxpload_byte := 0;


      IF (cfg_reg < 128) THEN
          cfg_maxpload_byte := 1 * 128;
      ELSIF (cfg_reg < 256) THEN
          cfg_maxpload_byte := 2 * 128;
      ELSIF (cfg_reg < 512) THEN
          cfg_maxpload_byte := 4 * 128;
      ELSIF (cfg_reg < 1024) THEN
          cfg_maxpload_byte := 8 * 128;
      ELSIF (cfg_reg < 2048) THEN
          cfg_maxpload_byte := 16 * 128;
      ELSE
          cfg_maxpload_byte := 32 * 128;
      END IF;

      IF ((byte_length > cfg_maxpload_byte) OR (byte_length < 4)) THEN
          Ibyte_length := 4;
      ELSE
          Ibyte_length := byte_length;
      END IF;

      Istart_val_vector := start_val;

      for i in 1 to loop_count + 1 loop
         --TODO extend to more than 1 single DWORD
         Ibyte_length := 4;
         downstream_write( bar_table,
                           setup_bar,
                           epmem_address,
                           Istart_val_vector,
                           Ibyte_length);
         downstream_read ( bar_table,
                           setup_bar,
                           epmem_address,
                           Ibyte_length);
         scr_memory_compare(Ibyte_length,
                            SCR_MEM_DOWNSTREAM_WR,
                            SCR_MEM_DOWNSTREAM_RD);

         Istart_val_vector := Istart_val_vector(62 DOWNTO 0) + (x"00000000" & TO_STDLOGICVECTOR(cfg_maxpload_byte, 32));

         IF ((Ibyte_length>cfg_maxpload_byte-4) OR (Ibyte_length<4)) THEN
             Ibyte_length := 4;
         ELSE
             Ibyte_length := Ibyte_length+4;
         END IF;

      end loop;

end downstream_loop;



end altpcietb_bfm_driver_downstream;

architecture behavioral of altpcietb_bfm_driver_downstream is

  signal activity_toggle : std_logic := '0';

begin  -- behavioral

  main: process

    -- This constant defines where we save the sizes and programmed addresses
    -- of the Endpoint Device Under Test BARs
    constant bar_table : natural := BAR_TABLE_POINTER;  -- 64 bytes

    -- tgt_bar indicates which bar to use for testing the target memory of the
    -- reference design.
    variable tgt_bar      : natural := 0;
    variable dma_bar      : natural := 4;
    variable rc_slave_bar : natural := 0;
    variable rcslave_bar  : natural := 4;
    variable addr_map_4GB_limit : natural := 0;

  begin  -- process main

     -- Setup the Root Port and Endpoint Configuration Spaces
     ebfm_cfg_rp_ep(
       bar_table => bar_table,                  -- BAR Size/Address info for Endpoint
       ep_bus_num => 1,                         -- Bus Number for Endpoint Under Test
       ep_dev_num => 1,                         -- Device Number for Endpoint Under Test
       rp_max_rd_req_size => 512,               -- Maximum Read Request Size for Root Port
       display_ep_config => 1,                  -- Display EP Config Space after setup
       addr_map_4GB_limit => addr_map_4GB_limit -- Limit the BAR assignments to 4GB address map
       ) ;

     activity_toggle <= not activity_toggle ;
      --
      -- Test downstream access to the Chaining DMA Memory


      rc_slave_bar := find_mem_bar(bar_table,"110011",8) ;

      if (rc_slave_bar<6) then
            downstream_loop(
               bar_table,                -- Pointer to the BAR sizing and
               rc_slave_bar,             -- Pointer to the BAR sizing and
               RCSLAVE_MAXLEN,           -- Number of Write/read iteration
               4,                        -- downstream wr/rd length in byte
               0,                        -- Downstream EP memory address in byte
                                         -- (need to be qword aligned)
               x"BABA_0000_BEBE_0000"); -- Starting write data value
      else
         ebfm_display(EBFM_MSG_WARNING,
            "Unable to find a 256B BAR to setup the RC Slave module ; skipping test.");
     end if;


     -- Stop the simulator and indicate successful completion

     ebfm_log_stop_sim(1) ;

     wait;

  end process main;

  -- purpose: this is a watchdog timer, if it sees no activity on the activity
  -- toggle signal for 2000 us it ends the simulation
  watchdog: process
  begin  -- process watchdog
    wait on activity_toggle for 2000 us ;
    if (not activity_toggle'event) then
      ebfm_display(EBFM_MSG_ERROR_FATAL,"Simulation stopped due to inactivity!") ;
    end if;
  end process watchdog;


end behavioral;

