-- /**
--  * This VHDL file is used for simulation in
--  * the chaining DMA design example.
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

package altpcie_chained_dma is

    CONSTANT SCR_MEM           : natural := 2 ** 11;  -- Share memory base address used by DMA
    CONSTANT SCR_MEMSLAVE          : natural := 64;     -- Share memory base address used by RC Slave module
    CONSTANT SCR_MEM_DOWNSTREAM_WR : natural := SCR_MEMSLAVE;
    CONSTANT SCR_MEM_DOWNSTREAM_RD : natural := SCR_MEMSLAVE+2048;
    CONSTANT MAX_RCPAYLOAD         : natural := 128;
    CONSTANT RCSLAVE_MAXLEN        : natural := 10;  -- maximum number of read/write
    CONSTANT RCLAST_DESCRIPTOR : natural := 3;        --3;
    CONSTANT DESCRIPTOR_SIZE   : natural := 3;        --3;
    CONSTANT TIMEOUT_POLLING    : natural := 2048;    -- number of clock' for timout

   -- rc_slave section
    CONSTANT pOP_CODE    : natural := 16#20#;            -- ADDRESS of OP_CODE 0x20
    CONSTANT OP_CODE_CLR : natural := 16#70000000#; -- Set OpCode to mode 0;
    CONSTANT pRC_MRD    : natural  := 16#24#;            -- ADDRESS of RC_MRD  0x24

   -- Descriptor Table Parameters address offsets on the EP Side
    CONSTANT EP_ADDR_DW0 : natural := 16#0#;
    CONSTANT EP_ADDR_DW1 : natural := 16#4#;
    CONSTANT EP_ADDR_DW2 : natural := 16#8#;
    CONSTANT EP_ADDR_DW3 : natural := 16#C#;

   -- Descriptor Table Parameters address offsets on the BFM Shared memeory side
    CONSTANT RC_ADDR_DW0 : natural := 16#0#;
    CONSTANT RC_ADDR_DW1 : natural := 16#4#;
    CONSTANT RC_ADDR_DW2 : natural := 16#8#;
    CONSTANT RC_ADDR_DW3 : natural := 16#C#; -- This the location where EP MWr
                                             -- EP_LAST
   -- Write DMA DESCRIPTOR TABLE Content
    CONSTANT WR_DIRECTION        : natural := 1; -- 4 DWORDS
    CONSTANT WR_EP_OFFSET        : natural := 0;

    CONSTANT WR_DESCRIPTOR_DEPTH : natural := 4; -- 4 DWORDS
    CONSTANT WR_BDT_LSB          : natural := SCR_MEM;
    CONSTANT WR_BDT_MSB          : natural := 0;

    CONSTANT WR_FIRST_DESCRIPTOR : natural := WR_BDT_LSB+16;

    CONSTANT WR_DESC0_CTL_MSI    : natural := 0;
    CONSTANT WR_DESC0_CTL_EPLAST : natural := 1;  -- send EPLast update when done with this descriptor
    CONSTANT WR_DESC0_LENGTH     : natural := 82;
    CONSTANT WR_DESC0_EPADDR     : natural := 3;
    CONSTANT WR_DESC0_RCADDR_MSB : natural := 0;
    CONSTANT WR_DESC0_RCADDR_LSB : natural := WR_BDT_LSB+ 4096;
    CONSTANT WR_DESC0_INIT_BFM_MEM : std_logic_vector(63 downto 0) := x"0000_0000_1515_0001";

    CONSTANT WR_DESC1_CTL_MSI    : natural := 0;
    CONSTANT WR_DESC1_CTL_EPLAST : natural := 0;
    CONSTANT WR_DESC1_LENGTH     : natural := 1024;
    CONSTANT WR_DESC1_EPADDR     : natural := 0;
    CONSTANT WR_DESC1_RCADDR_MSB : natural := 0;
    CONSTANT WR_DESC1_RCADDR_LSB : natural := WR_BDT_LSB+ 8192;
    CONSTANT WR_DESC1_INIT_BFM_MEM : std_logic_vector(63 downto 0) := x"0000_0000_2525_0001";

    CONSTANT WR_DESC2_CTL_MSI    : natural := 1;  -- send MSI when done with this descriptor
    CONSTANT WR_DESC2_CTL_EPLAST : natural := 1;  -- send EPLast update when done with this descriptor
    CONSTANT WR_DESC2_LENGTH     : natural := 644;
    CONSTANT WR_DESC2_EPADDR     : natural := 0;
    CONSTANT WR_DESC2_RCADDR_MSB : natural := 0;
    CONSTANT WR_DESC2_RCADDR_LSB : natural := WR_BDT_LSB+ 20384;
    CONSTANT WR_DESC2_INIT_BFM_MEM : std_logic_vector(63 downto 0) := x"0000_0000_3535_0001";

   -- READ DMA DESCRIPTOR TABLE Content
    CONSTANT RD_DIRECTION        : natural := 0;
    CONSTANT RD_EP_OFFSET        : natural := 16;

    CONSTANT RD_DESCRIPTOR_DEPTH : natural := 4;
    CONSTANT RD_BDT_LSB          : natural := SCR_MEM+256;
    CONSTANT RD_BDT_MSB          : natural := 0;

    CONSTANT RD_FIRST_DESCRIPTOR : natural := RD_BDT_LSB+16;

    CONSTANT RD_DESC0_CTL_MSI    : natural := WR_DESC0_CTL_MSI;
    CONSTANT RD_DESC0_CTL_EPLAST : natural := WR_DESC0_CTL_EPLAST;
    CONSTANT RD_DESC0_LENGTH     : natural := 82;
    CONSTANT RD_DESC0_EPADDR     : natural := 3;
    CONSTANT RD_DESC0_RCADDR_MSB : natural := 0;
    CONSTANT RD_DESC0_RCADDR_LSB : natural := RD_BDT_LSB+34032;
    CONSTANT RD_DESC0_INIT_BFM_MEM : std_logic_vector(63 downto 0) := x"0000_0000_AAA0_0001";

    CONSTANT RD_DESC1_CTL_MSI    : natural := WR_DESC1_CTL_MSI;
    CONSTANT RD_DESC1_CTL_EPLAST : natural := WR_DESC1_CTL_EPLAST;
    CONSTANT RD_DESC1_LENGTH     : natural := 1024;
    CONSTANT RD_DESC1_EPADDR     : natural := 0;
    CONSTANT RD_DESC1_RCADDR_MSB : natural := 10;
    CONSTANT RD_DESC1_RCADDR_LSB : natural := RD_BDT_LSB+65536;
    CONSTANT RD_DESC1_INIT_BFM_MEM : std_logic_vector(63 downto 0) := x"0000_0000_BBBB_0001";

    CONSTANT RD_DESC2_CTL_MSI    : natural := WR_DESC2_CTL_MSI;
    CONSTANT RD_DESC2_CTL_EPLAST : natural := WR_DESC2_CTL_EPLAST;
    CONSTANT RD_DESC2_LENGTH     : natural := 644;
    CONSTANT RD_DESC2_EPADDR     : natural := 0;
    CONSTANT RD_DESC2_RCADDR_MSB : natural := 0;
    CONSTANT RD_DESC2_RCADDR_LSB : natural := RD_BDT_LSB+ 132592;
    CONSTANT RD_DESC2_INIT_BFM_MEM : std_logic_vector(63 downto 0) := x"0000_0000_CCCC_0001";

   -- Information used by driver for polling Chaining DMA status for completion.
   -- These must correspond to the _DESCx_CTL_MSI and _DESCx_CTL_EPLAST parameters above.
   CONSTANT EPLAST_DONE_VALUE   : natural := 2;                                                               -- The EPLast Number that the driver expects to receive from each DMA after all data transfers have completed
   CONSTANT NUM_EPLAST_EXPECTED : natural := WR_DESC0_CTL_EPLAST + WR_DESC1_CTL_EPLAST + WR_DESC2_CTL_EPLAST; -- Number of Descriptors programmed to send EPLAST status update to root port
   CONSTANT NUM_MSI_EXPECTED    : natural := WR_DESC0_CTL_MSI + WR_DESC1_CTL_MSI + WR_DESC2_CTL_MSI;          -- Number of MSI's that the driver expects to receive from each DMA after all data transfers have completed


    CONSTANT DISPLAY_ALL         : natural := 0;

    CONSTANT STR_SEP  : string  :=
                "---------";

     -- Chained DMA function
    impure function find_mem_bar (
       constant bar_table : natural ;
       constant allowed_bars    : std_logic_vector(5 downto 0);
       constant min_log2_size   : natural
       ) return natural;

   function TO_DWORD (constant val : in natural)
         return std_logic_vector;

   function TO_QWORD (constant val : in natural)
         return std_logic_vector;

   procedure dma_set_wr_desc_data (
         constant bar_table  : in natural;
         constant setup_bar  : in natural);

   procedure dma_set_rd_desc_data (
         constant bar_table  : in natural;
         constant setup_bar  : in natural);

    procedure ebfm_display_verb (
     constant msg_type : in natural;
     constant message  : in string);

end altpcie_chained_dma ;

package body altpcie_chained_dma is

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

   ------------------------------------------------------------------------/
   --
   -- Procedure: dma_set_wr_desc_data :
   --
   --  write 'write descriptor table in the RC Memory
   --
   --
   -- input arguments
   --   bar_table : Pointer to the BAR sizing and
   --   setup_bar : BAR to be used for setting up
   --
   procedure dma_set_wr_desc_data (
         constant bar_table  : in natural;
         constant setup_bar  : in natural
      ) is

   variable descriptor_addr  :  natural;
   variable loop_control_field : natural;

   begin

      --program BFM share memeory
      ebfm_display(EBFM_MSG_INFO, STR_SEP);
      ebfm_display(EBFM_MSG_INFO, "Procedure :dma_set_wr_desc_data");

      -- Descriptor 0
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Initializing data for descriptor 0");
      ebfm_display_verb(EBFM_MSG_INFO, "  WR_DESC0_RCADDR_LSB= 0x" &
                                                 himage(WR_DESC0_RCADDR_LSB));
      ebfm_display_verb(EBFM_MSG_INFO, "  WR_DESC0_LENGTH= 0x" &
                                                 himage(WR_DESC0_LENGTH));
      descriptor_addr := WR_FIRST_DESCRIPTOR;
      loop_control_field := ((2**17) * WR_DESC0_CTL_EPLAST) + ((2**16) * WR_DESC0_CTL_MSI);   -- Assemble Descriptor Control Field
      shmem_write(descriptor_addr  ,  TO_DWORD(loop_control_field + WR_DESC0_LENGTH    ),4);
      shmem_write(descriptor_addr+4,  TO_DWORD(WR_DESC0_EPADDR    ),4);
      shmem_write(descriptor_addr+8,  TO_DWORD(WR_DESC0_RCADDR_MSB),4);
      shmem_write(descriptor_addr+12, TO_DWORD(WR_DESC0_RCADDR_LSB),4);
      shmem_fill(WR_DESC0_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 WR_DESC0_LENGTH*4, WR_DESC0_INIT_BFM_MEM);

      if (DISPLAY_ALL=1) then
         shmem_display(WR_DESC0_RCADDR_LSB,WR_DESC0_LENGTH*4,4,
                              WR_DESC0_RCADDR_LSB+(WR_DESC0_LENGTH*4),
                              EBFM_MSG_INFO);
      end if;

      -- Descriptor 1
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Initializing data for descriptor 1");
      ebfm_display_verb(EBFM_MSG_INFO, "  WR_DESC1_RCADDR_LSB= 0x" &
                                            himage(WR_DESC1_RCADDR_LSB));
      ebfm_display_verb(EBFM_MSG_INFO, "  WR_DESC1_LENGTH= 0x"&
                                                 himage(WR_DESC1_LENGTH) );
      descriptor_addr := WR_FIRST_DESCRIPTOR+16;
      loop_control_field := ((2**17) * WR_DESC1_CTL_EPLAST) + ((2**16) * WR_DESC1_CTL_MSI);   -- Assemble Descriptor Control Field
      shmem_write(descriptor_addr   , TO_DWORD(loop_control_field + WR_DESC1_LENGTH    ), 4);
      shmem_write(descriptor_addr+4 , TO_DWORD(WR_DESC1_EPADDR    ), 4);
      shmem_write(descriptor_addr+8 , TO_DWORD(WR_DESC1_RCADDR_MSB), 4);
      shmem_write(descriptor_addr+12, TO_DWORD(WR_DESC1_RCADDR_LSB), 4);
      shmem_fill(WR_DESC1_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                   WR_DESC1_LENGTH*4, WR_DESC1_INIT_BFM_MEM);

      if (DISPLAY_ALL=1) then
         shmem_display(WR_DESC1_RCADDR_LSB,
                              WR_DESC1_LENGTH*4,
                              4,
                              WR_DESC1_RCADDR_LSB+(WR_DESC1_LENGTH*4),
                              EBFM_MSG_INFO);
      end if;

      -- Descriptor 2
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Initializing data for descriptor 2");
      ebfm_display_verb(EBFM_MSG_INFO, "  WR_DESC2_RCADDR_LSB= 0x" &
                                            himage(WR_DESC2_RCADDR_LSB));
      ebfm_display_verb(EBFM_MSG_INFO, "  WR_DESC2_LENGTH= 0x" &
                                                 himage(WR_DESC2_LENGTH));
      descriptor_addr := WR_FIRST_DESCRIPTOR+32;
      loop_control_field := ((2**17) * WR_DESC2_CTL_EPLAST) + ((2**16) * WR_DESC2_CTL_MSI);   -- Assemble Descriptor Control Field
      shmem_write(descriptor_addr   , TO_DWORD(loop_control_field + WR_DESC2_LENGTH    ), 4);
      shmem_write(descriptor_addr+4 , TO_DWORD(WR_DESC2_EPADDR    ), 4);
      shmem_write(descriptor_addr+8 , TO_DWORD(WR_DESC2_RCADDR_MSB), 4);
      shmem_write(descriptor_addr+12, TO_DWORD(WR_DESC2_RCADDR_LSB), 4);
      shmem_fill(WR_DESC2_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 WR_DESC2_LENGTH*4, WR_DESC2_INIT_BFM_MEM);
      if (DISPLAY_ALL=1) then
         shmem_display(WR_DESC2_RCADDR_LSB,WR_DESC2_LENGTH*4,4,
                         WR_DESC2_RCADDR_LSB+(WR_DESC2_LENGTH*4),EBFM_MSG_INFO);
      end if;

      -- Display descriptor table of DMA Write
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "  Write Header Descriptor table");
      if (DISPLAY_ALL=1) then
         shmem_display(WR_BDT_LSB+WR_BDT_MSB,
                            (DESCRIPTOR_SIZE+1)*WR_DESCRIPTOR_DEPTH*4,
                            4,2**22,EBFM_MSG_INFO);
      end if;

   end dma_set_wr_desc_data;

--------------------------------------
--
-- Procedure: dma_set_rd_desc_data :
--
--  write 'read descriptor table in the RC Memory
-- input arguments
--   bar_table : Pointer to the BAR sizing and
--   setup_bar : BAR to be used for setting up
--
   procedure dma_set_rd_desc_data (
         constant bar_table  : in natural;
         constant setup_bar  : in natural
      ) is

   variable descriptor_addr  :  natural;
   variable loop_control_field : natural;

   begin

      --program BFM share memeory
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Procedure :dma_set_rd_desc_data");

      -- Descriptor 0
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Initializing data for descriptor 0");
      ebfm_display_verb(EBFM_MSG_INFO, "  RD_DESC0_RCADDR_LSB= 0x" &
                                                 himage(RD_DESC0_RCADDR_LSB));
      ebfm_display_verb(EBFM_MSG_INFO, "  RD_DESC0_LENGTH= 0x" &
                                                 himage(RD_DESC0_LENGTH));
      descriptor_addr := RD_FIRST_DESCRIPTOR;
      loop_control_field := ((2**17) * RD_DESC0_CTL_EPLAST) + ((2**16) * RD_DESC0_CTL_MSI);   -- Assemble Descriptor Control Field
      shmem_write(descriptor_addr  ,  TO_DWORD(loop_control_field + RD_DESC0_LENGTH    ),4);
      shmem_write(descriptor_addr+4,  TO_DWORD(RD_DESC0_EPADDR    ),4);
      shmem_write(descriptor_addr+8,  TO_DWORD(RD_DESC0_RCADDR_MSB),4);
      shmem_write(descriptor_addr+12, TO_DWORD(RD_DESC0_RCADDR_LSB),4);
      shmem_fill(RD_DESC0_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 RD_DESC0_LENGTH*4, RD_DESC0_INIT_BFM_MEM);

      if (DISPLAY_ALL=1) then
         shmem_display(RD_DESC0_RCADDR_LSB,RD_DESC0_LENGTH*4,4,
                              RD_DESC0_RCADDR_LSB+(RD_DESC0_LENGTH*4),
                              EBFM_MSG_INFO);
      end if;

      -- Descriptor 1
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Initializing data for descriptor 1");
      ebfm_display_verb(EBFM_MSG_INFO, "  RD_DESC1_RCADDR_LSB= 0x" &
                                            himage(RD_DESC1_RCADDR_LSB));
      ebfm_display_verb(EBFM_MSG_INFO, "  RD_DESC1_LENGTH= 0x"&
                                                 himage(RD_DESC1_LENGTH) );
      descriptor_addr := RD_FIRST_DESCRIPTOR+16;
      loop_control_field := ((2**17) * RD_DESC1_CTL_EPLAST) + ((2**16) * RD_DESC1_CTL_MSI);   -- Assemble Descriptor Control Field
      shmem_write(descriptor_addr   , TO_DWORD(loop_control_field + RD_DESC1_LENGTH    ), 4);
      shmem_write(descriptor_addr+4 , TO_DWORD(RD_DESC1_EPADDR    ), 4);
      shmem_write(descriptor_addr+8 , TO_DWORD(RD_DESC1_RCADDR_MSB), 4);
      shmem_write(descriptor_addr+12, TO_DWORD(RD_DESC1_RCADDR_LSB), 4);
      shmem_fill(RD_DESC1_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                   RD_DESC1_LENGTH*4, RD_DESC1_INIT_BFM_MEM);
      if (DISPLAY_ALL=1) then
         shmem_display(RD_DESC1_RCADDR_LSB,
                              RD_DESC1_LENGTH*4,
                              4,
                              RD_DESC1_RCADDR_LSB+(RD_DESC1_LENGTH*4),
                              EBFM_MSG_INFO);
      end if;

      -- Descriptor 2
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "Initializing data for descriptor 2");
      ebfm_display_verb(EBFM_MSG_INFO, "  RD_DESC2_RCADDR_LSB= 0x" &
                                            himage(RD_DESC2_RCADDR_LSB));
      ebfm_display_verb(EBFM_MSG_INFO, "  RD_DESC2_LENGTH= 0x" &
                                                 himage(RD_DESC2_LENGTH));
      descriptor_addr := RD_FIRST_DESCRIPTOR+32;
      loop_control_field := ((2**17) * RD_DESC2_CTL_EPLAST) + ((2**16) * RD_DESC2_CTL_MSI);   -- Assemble Descriptor Control Field
      shmem_write(descriptor_addr   , TO_DWORD(loop_control_field + RD_DESC2_LENGTH    ), 4);
      shmem_write(descriptor_addr+4 , TO_DWORD(RD_DESC2_EPADDR    ), 4);
      shmem_write(descriptor_addr+8 , TO_DWORD(RD_DESC2_RCADDR_MSB), 4);
      shmem_write(descriptor_addr+12, TO_DWORD(RD_DESC2_RCADDR_LSB), 4);
      shmem_fill(RD_DESC2_RCADDR_LSB,SHMEM_FILL_DWORD_INC,
                 RD_DESC2_LENGTH*4, RD_DESC2_INIT_BFM_MEM);
      if (DISPLAY_ALL=1) then
         shmem_display(RD_DESC2_RCADDR_LSB,RD_DESC2_LENGTH*4,4,
                         RD_DESC2_RCADDR_LSB+(RD_DESC2_LENGTH*4),EBFM_MSG_INFO);
      end if;

      -- Display descriptor table of DMA Write
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      ebfm_display_verb(EBFM_MSG_INFO, "  Read Header Descriptor table");
      if (DISPLAY_ALL=1) then
         shmem_display(RD_BDT_LSB+WR_BDT_MSB,
                            (DESCRIPTOR_SIZE+1)*RD_DESCRIPTOR_DEPTH*4,
                            4,2**22,EBFM_MSG_INFO);
      end if;

   end dma_set_rd_desc_data;

end altpcie_chained_dma;

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
use work.altpcie_chained_dma.all;

entity altpcietb_bfm_driver_chaining is
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


   ------------------------------------------------------------------------/
   --
   -- procedure: rcmem_poll
   --
   -- Polling routine waiting for rc_data at location rc_addr
   --
   procedure rcmem_poll(
      constant rc_addr : in natural;
      constant rc_data : in natural;
      constant rc_data_mask : in std_logic_vector(31 downto 0)
      ) is

      variable rc_current : std_logic_vector(31 downto 0);
      variable rc_last : std_logic_vector(31 downto 0);
      variable pol_timer  : natural:=0;
      variable do_loop    : natural:=1;

      begin

        -- ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
        -- ebfm_display_verb(EBFM_MSG_INFO, "procedure : rcmem_poll");

         rc_current := shmem_read (rc_addr, 4);

         ebfm_display_verb(EBFM_MSG_INFO,
               "TASK:rcmem_poll   Polling BFM shared memory address:"   & himage(rc_addr)    &
               "   current data ("        & himage(rc_current) &
               ")  expected data ("       & himage(rc_data)    & ")");

         while (do_loop=1) loop
            for i in 1 to 50 loop
               wait until (clk_in'event and clk_in = '1');
            end loop;

            pol_timer := pol_timer + 1;

            rc_current := (shmem_read (rc_addr, 4)) AND rc_data_mask;

            if (rc_current = TO_DWORD(rc_data)) then
               ebfm_display_verb(EBFM_MSG_INFO,
                    "TASK:rcmem_poll ---> Received expected Data: Addre:"&himage(rc_addr)&
                    " contains " & himage(rc_current));
               do_loop:=0;
            end if;

            if (NOT(rc_current = rc_last)) then
                  ebfm_display(EBFM_MSG_INFO, "TASK:rcmem_poll   Polling RC Address:"  & himage(rc_addr) &
                         "   current data (" & himage(rc_current) & ")  expected data (" & himage(rc_data) & ")");
                  pol_timer := 0;
            end if;


            rc_last := rc_current;

            if (pol_timer >= TIMEOUT_POLLING) then
               ebfm_display(EBFM_MSG_INFO,
                    "   ---> Procedure:rcmem_poll timeout occured");
               ebfm_display(EBFM_MSG_ERROR_FATAL,
                    "   ---> Test Fails: RC Address:"&himage(rc_addr)&
                    " contains " & himage(rc_current));
               exit;
            end if;
         end loop;
   end rcmem_poll;




   -----------------------------------------------------------------------------
   --
   -- TASK:dma_set_rclast :
   --
   -- RC issues MWr to write Descriptor table header DW3,
   -- Start DMA Engine
   --
   procedure dma_set_rclast (
      constant bar_table    : in natural;
      constant setup_bar    : in natural;
      constant dt_direction : in natural;
      constant dt_rclast    : in natural
      ) is

      variable dt_dw4    : std_logic_vector(31 downto 0);
      variable ep_offset : natural;

      begin

         -- DMA Write ep_offset /BAR = 0;
         -- DMA Read ep_offset  /BAR = 16 (4 DWORDs);
         if (dt_direction= WR_DIRECTION) then
            ep_offset := WR_EP_OFFSET;
         else
            ep_offset := RD_EP_OFFSET;
         end if;
         dt_dw4    := TO_DWORD(dt_rclast);

         -- display section
         ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
         ebfm_display_verb(EBFM_MSG_INFO, "Procedure :dma_set_rclast");

         if (dt_direction=RD_DIRECTION) then
            ebfm_display_verb(EBFM_MSG_INFO,
                         "   Start READ DMA : RC issues MWr (RCLast="&
                         himage(dt_rclast)&")");
         else
            ebfm_display_verb(EBFM_MSG_INFO,
                         "   Start WRITE DMA : RC issues MWr (RCLast="&
                         himage(dt_rclast)& ")");
        end if;

         -- RC writes EP DMA register DW3
         ebfm_barwr_imm(bar_table, setup_bar, EP_ADDR_DW3+ep_offset, dt_dw4, 4, 0);

   end dma_set_rclast ;

   -----------------------------------------------------------------------------
   --
   -- TASK:dma_set_header :
   --
   -- RC issues MWr to write Descriptor table header DW0, DW1, DW2
   -- RC initializaed RC shared memory with MSI_DATA, DW0, DW1, DW2
   --
   procedure dma_set_header (
      constant bar_table    : in natural; -- Pointer to the BAR sizing and
      constant setup_bar    : in natural; -- BAR to be used for setting up
      constant dt_size      : in natural; -- number of descriptor in the descriptor
      constant dt_direction : in natural; -- Read or write
      constant dt_msi       : in natural; -- status bit for DMA MSI
      constant dt_eplast    : in natural; -- status bit to write back ep_counter info
      constant dt_bdt_msb   : in natural; -- RC upper 32 bits base address of the dt
      constant dt_bdt_lsb   : in natural; -- RC lower 32 bits base address of the dt
      constant msi_number           : in std_logic_vector (4 downto 0); -- MSI
      constant msi_traffic_class    : in std_logic_vector (2 downto 0); -- MSI
      constant multi_message_enable : in std_logic_vector (2 downto 0)  -- MSI
      ) is

      variable dt_dw0, dt_dw1, dt_dw2 : std_logic_vector(31 downto 0);
      variable ep_offset : natural;

   begin

      -- Constructing header descriptor table DWORDS DW0

      -- set length (number of descriptor) to DW0
         dt_dw0(15 downto 0)  := std_logic_vector(to_unsigned(dt_size,16));

         dt_dw0(16):= '0';

         -- set MSI bit to DW0
         if (dt_msi=0)    then
            dt_dw0(17) :='0';
         else
            dt_dw0(17) :='1';
         end if;

         -- set EPLAST bit to DW0
         if (dt_eplast=0)  then
            dt_dw0(18) :='0';
         else
            dt_dw0(18) :='1';
         end if;

         -- set MSI Capabilities bit to DW0
            dt_dw0(19) := '0';
            dt_dw0(24 downto 20) := msi_number(4 downto 0);
            dt_dw0(27 downto 25) := "000";
            dt_dw0(30 downto 28) := msi_traffic_class;


         -- Reserved bit
         dt_dw0(31)    := '0';

      -- Constructing header dsecriptor table DWORDS DW1
         dt_dw1 := TO_DWORD(dt_bdt_msb);

      -- Constructing header dsecriptor table DWORDS DW2
         dt_dw2 := TO_DWORD(dt_bdt_lsb);

      if (dt_direction=WR_DIRECTION) then
         ep_offset := WR_EP_OFFSET;
      else
         ep_offset := RD_EP_OFFSET;
      end if;

     -- display section
     ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
     if (dt_direction=RD_DIRECTION) then
        ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_header READ");
     else
        ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_header WRITE");
     end if;

     ebfm_display_verb(EBFM_MSG_INFO, "Writting Descriptor header");

     -- RC writes EP DMA register (for module altpcie_dma_prg_reg)
     ebfm_barwr_imm(bar_table, setup_bar, EP_ADDR_DW0+ep_offset, dt_dw0, 4, 0);
     ebfm_barwr_imm(bar_table, setup_bar, EP_ADDR_DW1+ep_offset, dt_dw1, 4, 0);
     ebfm_barwr_imm(bar_table, setup_bar, EP_ADDR_DW2+ep_offset, dt_dw2, 4, 0);

     -- RC writes RC Memory
     shmem_write(dt_bdt_lsb   , dt_dw0              ,4 );
     shmem_write(dt_bdt_lsb+4 , dt_dw1              ,4 );
     shmem_write(dt_bdt_lsb+8 , dt_dw2              ,4 );
     shmem_write(dt_bdt_lsb+12, x"CAFE_FADE",4 );

     ebfm_display_verb(EBFM_MSG_INFO, "data content of the DT header");
     if (DISPLAY_ALL=1) then
        shmem_display(dt_bdt_lsb, 4*4, 4, dt_bdt_lsb+(4*4),EBFM_MSG_INFO);
     end if;

   end dma_set_header;



------------------------------------------------------------------------/
--
-- TASK:dma_set_msi:
--
-- Setup native PCIe MSI for DMA read and DMA write.
-- Retrieve MSI capabilities of EP, program EP MSI cfg register
-- with msi_address and msi_data
--
-- input argument:
--        bar_table    : Pointer to the BAR sizing and
--        setup_bar    : BAR to be used for setting up
--        bus_num      : default 1
--        dev_num      : default 0
--        fnc_num      : default 0
--        dt_direction : Read or write
--        msi_address  : RC Mem MSI address
--        msi_data     : MSI cgf data
--
-- returns:
--       msi_number (default : 1 for write , 0 for read)
--       msi_traffic_class MSI traffic class (default 0)
--       msi_expected Expected data written by MSI to RC Host memory
--
procedure dma_set_msi (
      constant bar_table    : in natural; -- Pointer to the BAR sizing and
      constant setup_bar    : in natural; -- BAR to be used for setting up
      constant bus_num    : in natural;
      constant dev_num    : in natural;
      constant fnc_num    : in natural;
      constant dt_direction    : in natural;
      constant msi_address    : in natural;
      constant msi_data    : in natural;

    variable msi_number      : out std_logic_vector(4 downto 0);
    variable msi_traffic_class : out std_logic_vector(2 downto 0);
    variable multi_message_enable : out std_logic_vector(2 downto 0);
    variable msi_expected : out std_logic_vector(31 downto 0)

   ) is

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

   CONSTANT msi_capabilities  : natural := 80;
   -- The Root Complex BFM has 2MB of address space
   CONSTANT msi_upper_address : natural := 0;

   variable        msi_control_register :  std_logic_vector (15 downto 0):=(others=>'0');
   variable        msi_64b_capable  :  std_logic_vector (0 downto 0);
   variable        multi_message_capable :  std_logic_vector (2 downto 0):=(others=>'0');
   variable        multi_message_enable_int :  std_logic_vector (2 downto 0):=(others=>'0');
   variable        msi_enable  :  std_logic;
   variable        compl_status :  std_logic_vector (2 downto 0);
   variable        do  :  std_logic := '0';
   variable        msi_data_stdlog : std_logic_vector (15 downto 0) := TO_STDLOGICVECTOR(msi_data, 16);
   variable        msi_number_int : std_logic_vector(4 downto 0);
   variable        msi_expected_int : std_logic_vector(31 downto 0);
   variable        msi_traffic_class_int : std_logic_vector(2 downto 0);

   begin

      -- MSI
      ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
      if (dt_direction=RD_DIRECTION) then
         ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_msi READ");
      else
         ebfm_display_verb(EBFM_MSG_INFO, "TASK:dma_set_msi WRITE");
      end if;

      ebfm_display_verb(EBFM_MSG_INFO,
                        " Message Signaled Interrupt Configuration");
      -- Read the contents of the MSI Control register

      msi_traffic_class_int := "000"; --TODO make it an input argument
      msi_traffic_class := msi_traffic_class_int;

      ebfm_display(EBFM_MSG_INFO, "  msi_address (RC memory)= 0x" & himage(msi_address));

      -- RC Reading MSI capabilities of the EP
      -- to get msi_control_register
      ebfm_cfgrd_wait(
                      bus_num => bus_num,
                      dev_num => dev_num,
                      fnc_num => fnc_num,
                      regb_ad => msi_capabilities,
                      regb_ln => 4,
                      lcladdr => msi_address,
                      compl_status => compl_status
      );

      msi_control_register  := shmem_read(msi_address+2, 2);

      ebfm_display_verb(EBFM_MSG_INFO, "  msi_control_register = 0x" &
                                             himage(msi_control_register));

      -- Program the MSI Message Control register for testing
      msi_64b_capable       := msi_control_register(7 downto 7);
      -- Enable the MSI with Maximum Number of Supported Messages
      multi_message_capable := msi_control_register(3 downto 1);

      multi_message_enable  := multi_message_capable;
      multi_message_enable_int := multi_message_capable;
      msi_enable           := '1';
      ebfm_cfgwr_imm_wait(bus_num => bus_num,
                          dev_num => dev_num,
                          fnc_num => fnc_num,
                          regb_ad => msi_capabilities,
                          regb_ln => 4,
                          imm_data => (x"00" & msi_64b_capable &
                                       multi_message_enable_int &
                                       multi_message_capable &
                                       msi_enable & x"0000"),
                          compl_status => compl_status);

      if (dt_direction = 0) then
          msi_number(4 downto 0) := "00001";
          msi_number_int         := "00001";
      else
          msi_number(4 downto 0) := "00000";
          msi_number_int         := "00000";
      end if;

      -- Retrieve msi_expected


      if (multi_message_enable_int = "000") then

            ebfm_display(EBFM_MSG_WARNING, "The chained DMA example design required at least 2 MSI ");
            ebfm_log_stop_sim(1);

      else

            if (multi_message_enable_int = "000") then
                msi_expected_int := x"0000" & msi_data_stdlog(15 downto 0);
            elsif (multi_message_enable_int = "001") then
                msi_expected_int := x"0000" & msi_data_stdlog(15 downto 1) & msi_number_int(0 downto 0);
            elsif (multi_message_enable_int = "010") then
                msi_expected_int := x"0000" & msi_data_stdlog(15 downto 2) & msi_number_int(1 downto 0);
            elsif (multi_message_enable_int = "011") then
                msi_expected_int := x"0000" & msi_data_stdlog(15 downto 3) & msi_number_int(2 downto 0);
            elsif (multi_message_enable_int = "100") then
                msi_expected_int := x"0000" & msi_data_stdlog(15 downto 4) & msi_number_int(3 downto 0);
            elsif (multi_message_enable_int = "101") then
                msi_expected_int := x"0000" & msi_data_stdlog(15 downto 5) & msi_number_int(4 downto 0);
            else
                ebfm_display(EBFM_MSG_ERROR_FATAL,
             "Illegal multi_message_enable value detected. MSI test fails.");
            end if;

     end if;

     msi_expected :=  msi_expected_int;

      -- Write the rest of the MSI Capabilities Structure:
      --            Address and Data Fields
     if (msi_64b_capable="1") then -- 64-bit Addressing

            -- Specify the RC lower Address where the MSI need to be written
            -- when EP issues MSI (msi_address= dt_bdt_lsb-16)
            -- 4 DWORD bellow the descriptor table
            ebfm_cfgwr_imm_wait(bus_num => bus_num,
                                dev_num => dev_num,
                                fnc_num => fnc_num,
                                regb_ad => (msi_capabilities + 4),
                                regb_ln => 4,
                                imm_data => TO_STDLOGICVECTOR(msi_address, 32),
                                compl_status => compl_status);
            -- Specify the RC Upper Address where the MSI need to be written
            -- when EP issues MSI
            ebfm_cfgwr_imm_wait(bus_num => bus_num,
                                dev_num => dev_num,
                                fnc_num => fnc_num,
                                regb_ad => msi_capabilities + 8,
                                regb_ln => 4,
                                imm_data => TO_STDLOGICVECTOR(msi_upper_address, 32),
                                compl_status => compl_status);
            -- Specify the data to be written in the RC Memeoryr MSI location
            -- when EP issues MSI
            -- (msi_data = 16'hb0fe)
            ebfm_cfgwr_imm_wait(bus_num => bus_num,
                                dev_num => dev_num,
                                fnc_num => fnc_num,
                                regb_ad => msi_capabilities + 12,
                                regb_ln => 4,
                                imm_data => TO_STDLOGICVECTOR(msi_data, 32),
                                compl_status => compl_status);

      else -- 32-bit Addressing

            -- Specify the RC lower Address where the MSI need to be written
            -- when EP issues MSI (msi_address= dt_bdt_lsb-16)
            -- 4 DWORD bellow the descriptor table
            ebfm_cfgwr_imm_wait(bus_num => bus_num,
                                dev_num => dev_num,
                                fnc_num => fnc_num,
                                regb_ad => msi_capabilities + 4,
                                regb_ln => 4,
                                imm_data => TO_STDLOGICVECTOR(msi_address, 32),
                                compl_status => compl_status);
            -- Specify the data to be written in the RC Memeoryr MSI location
            -- when EP issues MSI
            -- (msi_data = 16'hb0fe)
            ebfm_cfgwr_imm_wait(bus_num => bus_num,
                                dev_num => dev_num,
                                fnc_num => fnc_num,
                                regb_ad => msi_capabilities + 8,
                                regb_ln => 4,
                                imm_data => TO_STDLOGICVECTOR(msi_data, 32),
                                compl_status => compl_status);

      end if;

   -- Clear RC memory MSI Location
   shmem_write(msi_address, x"1111_FADE",4);

   ebfm_display_verb(EBFM_MSG_INFO, "  msi_expected = 0x" & himage(msi_expected_int));

   ebfm_display_verb(EBFM_MSG_INFO, "  msi_capabilities address = 0x" & himage(msi_capabilities));

   ebfm_display_verb(EBFM_MSG_INFO, "  multi_message_enable = 0x  & himage(multi_message_enable_int)");

   ebfm_display_verb(EBFM_MSG_INFO, "  msi_number =  & himage(msi_number_int)");

   ebfm_display_verb(EBFM_MSG_INFO, "  msi_traffic_class =   & himage(msi_traffic_class_int)");



end dma_set_msi;

------------------------------------------------------------------------
--
-- TASK:msi_poll
--   Polling process to track in shared memeory received MSI from EP
--
-- input argument
--    max_number_of_msi  : Total Number of MSI to track
--    msi_address        : MSI Address in shared memeory
--    msi_expected_dmawr : Expected MSI when dma_write is set
--    msi_expected_dmard : Expected MSI when dma_read is set
--    dma_write          : Set dma_write
--    dma_read           : set dma_read
procedure msi_poll(
   constant  max_number_of_msi : in natural;
   constant  msi_address : in natural;
   constant  msi_expected_dmawr : in std_logic_vector(31 downto 0);
   constant  msi_expected_dmard : in std_logic_vector(31 downto 0);
   constant  dma_write : in natural;
   constant  dma_read : in natural
   )  is

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

   variable msi_received : std_logic_vector(15 downto 0);
   variable msi_count : natural:=0;
   variable pol_timer  : natural:=0;
   variable do_loop    : natural:=1;
   variable msi_received_last : std_logic_vector(15 downto 0);

   begin
    --  ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
    --  ebfm_display_verb(EBFM_MSG_INFO, "TASK: msi_poll");


      for msi_count in 0 to max_number_of_msi-1 loop

         ebfm_display(EBFM_MSG_INFO, "TASK:msi_poll   Polling MSI Address:" & himage(msi_address) & "---> Data:" & himage(msi_received) & "......");
         do_loop := 1;

         -- Set timeout failure if expected MSI is not received
         while (do_loop=1) loop
           -- for i in 1 to 2 loop
            wait until (clk_in'event and clk_in = '1');
           -- end loop;

            pol_timer := pol_timer + 1;

            msi_received := shmem_read (msi_address, 2);
            msi_received_last := msi_received;

            -- Polling memory for expected MSI data value
             -- at the assigned MSI address location
            if ((msi_received = msi_expected_dmawr(15 downto 0)) AND (dma_write=1)) then
               ebfm_display(EBFM_MSG_INFO, "TASK:msi_poll    Received Expected DMA Write MSI(" & himage(msi_count) &  ") : " & himage(msi_received));
               shmem_write( msi_address , x"1111_FADE", 4);
               do_loop:=0;
            end if;

            if ((msi_received = msi_expected_dmard(15 downto 0)) AND (dma_read=1)) then
               ebfm_display(EBFM_MSG_INFO, "TASK:msi_poll    Received Expected DMA Read MSI(" & himage(msi_count) & ") : " &  himage(msi_received));
               shmem_write( msi_address , x"1111_FADE", 4);
           --    if (DISPLAY_ALL=1) then
           --        shmem_display(SCR_MEM+256,  4*4, 4, SCR_MEM+256+(4*4), EBFM_MSG_INFO);
           --    end if;
               do_loop:=0;
            end if;

            if (pol_timer >= (50 * TIMEOUT_POLLING)) then
               ebfm_display(EBFM_MSG_ERROR_FATAL, "MSI timeout occured, MSI never received, Test Fails" & himage(msi_count));
               exit;
            end if;

         end loop;

      end loop;

end msi_poll;


   ------------------------------------------------------------------------
   --
   -- TASK:dma_rd_test
   --
   --    Main task to run the chained DMA read/Write
   --
   -- Input argument
   --     bar_table :  Pointer to the BAR sizing and
   --     setup_bar :  BAR to be used for setting up
   --     use_msi   :  When set, RC uses MSI polling to detect completion
   --     use_eplast:  When set, RC uses EPLAst polling to detect completion
   --
   procedure dma_rd_test (
      constant bar_table  : in natural;
      constant setup_bar  : in natural;
      constant use_global_msi    : in natural;
      constant use_global_eplast : in natural
   ) is

   variable msi_number           : std_logic_vector (4 downto 0):=(others=>'0');
   variable msi_traffic_class    : std_logic_vector (2 downto 0):=(others=>'0');
   variable multi_message_enable : std_logic_vector (2 downto 0):=(others=>'0');
   variable msi_expected_dmard   :  std_logic_vector (31 downto 0);

   variable use_msi              : std_logic;
   variable use_eplast           : std_logic;

   variable msi_number_int           : std_logic_vector (4 downto 0):=(others=>'0');
   variable msi_traffic_class_int    : std_logic_vector (2 downto 0):=(others=>'0');
   variable multi_message_enable_int : std_logic_vector (2 downto 0):=(others=>'0');
   variable msi_expected_dmard_int   :  std_logic_vector (31 downto 0);

   CONSTANT MSI_ADDRESS : natural := SCR_MEM-16;
   CONSTANT MSI_DATA    : natural := 45310;  -- 32'hb0fe

   begin

      ebfm_display(EBFM_MSG_INFO, "procedure:dma_rd_test");


      -- Initialize BFM shared memory for DMA Read
      dma_set_rd_desc_data(bar_table, setup_bar);

      IF ((use_global_msi=1) OR (NUM_MSI_EXPECTED > 0)) THEN
          use_msi := '1';
      ELSE
          use_msi := '0';
      END IF;

      IF ((use_global_eplast=1) OR (NUM_EPLAST_EXPECTED > 0)) THEN
          use_eplast := '1';
      ELSE
          use_eplast := '0';
      END IF;

      if (use_msi='1') then
         dma_set_msi(bar_table,  -- Pointer to the BAR sizing and
                        setup_bar,  -- BAR to be used for setting up
                        1,          -- bus_num
                        1,          -- dev_num
                        0,          -- fnc_num
                        RD_DIRECTION,          -- Direction
                        MSI_ADDRESS,-- MSI RC memeory address
                        MSI_DATA,   -- MSI Cfg data value
                        msi_number,        -- msi_number
                        msi_traffic_class, --msi traffic class
                        multi_message_enable,-- number of msi
                        msi_expected_dmard -- expexted MSI data value
                     );
      end if;

      IF (use_msi = '1') THEN
          msi_number_int           :=  msi_number;
          msi_traffic_class_int    :=  msi_traffic_class;
          multi_message_enable_int :=  multi_message_enable;
      ELSE
          msi_number_int           :=  (others => '0');
          msi_traffic_class_int    :=  (others => '0');
          multi_message_enable_int :=  (others => '0');
      END IF;

      -- Initialize EP DMA Read with DW0, DW1, DW2
      dma_set_header( bar_table, setup_bar, DESCRIPTOR_SIZE, RD_DIRECTION,
                     use_global_msi, use_global_eplast, RD_BDT_MSB, RD_BDT_LSB,
                     msi_number_int, msi_traffic_class_int, multi_message_enable_int);

      -- Set DW3 for EP DMA Read
      dma_set_rclast( bar_table, setup_bar, RD_DIRECTION, DESCRIPTOR_SIZE-1);



      -- Completion polling
      if (use_msi='1') then
          if (use_global_msi=1) then
              msi_poll(DESCRIPTOR_SIZE,MSI_ADDRESS,x"00000000", msi_expected_dmard,0,1);
          else
              msi_poll(NUM_MSI_EXPECTED,MSI_ADDRESS,x"00000000", msi_expected_dmard,0,1);
          end if;
      end if;

      if (use_eplast='1') then
         if (use_global_eplast=1) then
             rcmem_poll(RD_BDT_LSB+RC_ADDR_DW3, DESCRIPTOR_SIZE-1, TO_DWORD(16#FFFF#));
         else
             rcmem_poll(RD_BDT_LSB+RC_ADDR_DW3,EPLAST_DONE_VALUE, TO_DWORD(16#FFFF#));
         end if;
      end if;





      ebfm_barwr_imm(bar_table, setup_bar, 16, x"0000_FFFF", 4, 0);

   end dma_rd_test;


   ------------------------------------------------------------------------
   --
   -- procedure:dma_wr_test
   --
   --    Main task to run the chained DMA read/Write
   --
   -- Input argument
   --     bar_table :  Pointer to the BAR sizing and
   --     setup_bar :  BAR to be used for setting up
   --     use_msi   :  When set, RC uses MSI polling to detect completion
   --     use_eplast:  When set, RC uses EPLAst polling to detect completion
   --
   procedure dma_wr_test (
      constant bar_table  : in natural;
      constant setup_bar  : in natural;
      constant use_global_msi    : in natural;
      constant use_global_eplast : in natural
   ) is

   variable msi_number           : std_logic_vector (4 downto 0):=(others=>'0');
   variable msi_traffic_class    : std_logic_vector (2 downto 0):=(others=>'0');
   variable multi_message_enable : std_logic_vector (2 downto 0):=(others=>'0');
   variable msi_expected_dmawr   :  std_logic_vector (31 downto 0);

   variable msi_number_int           : std_logic_vector (4 downto 0):=(others=>'0');
   variable msi_traffic_class_int    : std_logic_vector (2 downto 0):=(others=>'0');
   variable multi_message_enable_int : std_logic_vector (2 downto 0):=(others=>'0');
   variable msi_expected_dmard_int   :  std_logic_vector (31 downto 0);

   variable use_msi              : std_logic;
   variable use_eplast           : std_logic;

   CONSTANT MSI_ADDRESS : natural := SCR_MEM-16;
   CONSTANT MSI_DATA    : natural := 45310;  -- 32'hb0fe;

   begin
      ebfm_display(EBFM_MSG_INFO, "procedure:dma_wr_test");

      -- Initialize BFM shared memory for DMA Write
      dma_set_wr_desc_data(bar_table, setup_bar);

      IF ((use_global_msi=1) OR (NUM_MSI_EXPECTED > 0)) THEN
          use_msi := '1';
      ELSE
          use_msi := '0';
      END IF;

      IF ((use_global_eplast=1) OR (NUM_EPLAST_EXPECTED > 0)) THEN
          use_eplast := '1';
      ELSE
          use_eplast := '0';
      END IF;

      if (use_msi='1') then
         dma_set_msi(bar_table,  -- Pointer to the BAR sizing and
                        setup_bar,  -- BAR to be used for setting up
                        1,          -- bus_num
                        1,          -- dev_num
                        0,          -- fnc_num
                        WR_DIRECTION,          -- Direction
                        MSI_ADDRESS,-- MSI RC memeory address
                        MSI_DATA,   -- MSI Cfg data value
                        msi_number,        -- msi_number
                        msi_traffic_class, --msi traffic class
                        multi_message_enable,-- number of msi
                        msi_expected_dmawr -- expexted MSI data value
                     );
      end if;

      IF (use_msi = '1') THEN
          msi_number_int           :=  msi_number;
          msi_traffic_class_int    :=  msi_traffic_class;
          multi_message_enable_int :=  multi_message_enable;
      ELSE
          msi_number_int           :=  (others => '0');
          msi_traffic_class_int    :=  (others => '0');
          multi_message_enable_int :=  (others => '0');
      END IF;


      -- Initialize EP DMA Write with DW0, DW1, DW2
      dma_set_header( bar_table, setup_bar, DESCRIPTOR_SIZE, WR_DIRECTION,
                     use_global_msi, use_global_eplast, WR_BDT_MSB, WR_BDT_LSB,
                     msi_number_int, msi_traffic_class_int, multi_message_enable_int);



      -- Set DW3 for EP DMA Write
      dma_set_rclast( bar_table, setup_bar, WR_DIRECTION, DESCRIPTOR_SIZE-1);


      -- Completion polling

      if (use_msi='1') then
          if (use_global_msi=1) then
               msi_poll(DESCRIPTOR_SIZE, MSI_ADDRESS, msi_expected_dmawr,x"00000000",1,0);
          else
               msi_poll(NUM_MSI_EXPECTED, MSI_ADDRESS, msi_expected_dmawr,x"00000000",1,0);
          end if;
      end if;

      if (use_eplast='1') then
         if (use_global_eplast=1) then
             rcmem_poll(WR_BDT_LSB+RC_ADDR_DW3, DESCRIPTOR_SIZE-1, TO_DWORD(16#FFFF#));
         else
             rcmem_poll(WR_BDT_LSB+RC_ADDR_DW3,EPLAST_DONE_VALUE, TO_DWORD(16#FFFF#));
         end if;
      end if;


      ebfm_barwr_imm(bar_table, setup_bar, 0, x"0000_FFFF", 4, 0);

   end dma_wr_test;

   ------------------------------------------------------------------------/
   --
   -- Procedure:dma_rd_test
   --
   --    Main Procedure to run the chained DMA read/Write
   --
   -- Input argument
   --     bar_table :  Pointer to the BAR sizing and
   --     setup_bar :  BAR to be used for setting up
   --     use_msi   :  When set, RC uses MSI polling to detect completion
   --     use_eplast:  When set, RC uses EPLAst polling to detect completion
   --     direction :  0 read,
   --                  1 write,
   --                  2 Read then Write
   --                  3 Write then Read
   --
   procedure chained_dma_test (
      constant bar_table  : in natural;
      constant setup_bar  : in natural;
      constant direction  : in natural;
      constant use_global_msi    : in natural;
      constant use_global_eplast : in natural
   ) is
   begin
      ebfm_display(EBFM_MSG_INFO, "procedure:chained_dma_test");
      if (direction=0) then
         ebfm_display(EBFM_MSG_INFO,"   DMA: Read");
         dma_rd_test(bar_table, setup_bar, use_global_msi, use_global_eplast);
      elsif (direction=1) then
         ebfm_display(EBFM_MSG_INFO,"   DMA: write");
         dma_wr_test(bar_table, setup_bar, use_global_msi, use_global_eplast);
      elsif (direction=2) then
         ebfm_display(EBFM_MSG_INFO,"   DMA: Read");
         dma_rd_test(bar_table, setup_bar, use_global_msi, use_global_eplast);
         ebfm_display(EBFM_MSG_INFO,"   DMA: write");
         dma_wr_test(bar_table, setup_bar, use_global_msi, use_global_eplast);
      elsif (direction=3) then
         ebfm_display(EBFM_MSG_INFO,"   DMA: write");
         dma_wr_test(bar_table, setup_bar, use_global_msi, use_global_eplast);
         ebfm_display(EBFM_MSG_INFO,"   DMA: Read ");
         dma_rd_test(bar_table, setup_bar, use_global_msi, use_global_eplast);
      end if;
   end chained_dma_test;



-- memory content checking - check data transferred for specified descriptor
procedure check_dma_data (

   constant  wr_desc_length     : in natural;
   constant  rd_desc_length     : in natural;
   constant  wr_desc_rcaddr_lsb : in natural;
   constant  rd_desc_rcaddr_lsb : in natural
   ) is

   variable do             : natural:=0;
   variable i              : natural:=0;
   variable dmaread_data   :  std_logic_vector(31 downto 0);
   variable dmawrite_data  :  std_logic_vector(31 downto 0);
   variable dmaread_addr   :  natural;
   variable dmawrite_addr  :  natural;

   begin
      if ((wr_desc_length = rd_desc_length ) or (wr_desc_length < rd_desc_length ))  then
         ebfm_display_verb(EBFM_MSG_INFO, STR_SEP);
         ebfm_display(EBFM_MSG_INFO, "procedure:check_dma_data");
         for i in 0 to wr_desc_length-1 loop
            dmaread_addr  := rd_desc_rcaddr_lsb+4*i;
            dmaread_data  := shmem_read(dmaread_addr,4);
            dmawrite_addr := wr_desc_rcaddr_lsb+4*i;
            dmawrite_data := shmem_read(dmawrite_addr,4);
            if (NOT(dmaread_data = dmawrite_data)) then
               if (DISPLAY_ALL>0) then
                  ebfm_display_verb(EBFM_MSG_INFO,  " DMA read BFM memory");
                  shmem_display    (rd_desc_rcaddr_lsb, rd_desc_length*4,4, rd_desc_rcaddr_lsb+(rd_desc_length*4), EBFM_MSG_INFO);
                  ebfm_display_verb(EBFM_MSG_INFO,  " DMA write BFM memory");
                  shmem_display    (wr_desc_rcaddr_lsb,wr_desc_length*4,4, wr_desc_rcaddr_lsb+(wr_desc_length*4),EBFM_MSG_INFO);
               end if;
               ebfm_display(EBFM_MSG_ERROR_FATAL,
                        " DMA Read : Address ("  & himage(dmaread_addr) &
                         ") Data ("   & himage(dmaread_data) &
                         ") -------> DMA Write : Address (" & himage(dmawrite_addr) &
                         ") Data (" & himage(dmawrite_data) & ")");
            end if;
         end loop;
         ebfm_display(EBFM_MSG_INFO, "  Passed : 0x" & himage(wr_desc_length) &
                            " identical dwords.");
      end if;
end check_dma_data;

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



end altpcietb_bfm_driver_chaining;

architecture behavioral of altpcietb_bfm_driver_chaining is

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
    variable rc_slave_bar : natural := 4;
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

     -- Find a memory BAR to use to setup the DMA channel
     -- The reference design implements the DMA channel registers on BAR 2 or 3
     -- We need one at least 256 B big
     dma_bar := find_mem_bar(bar_table,"001100",8) ;

     if (dma_bar < 6) then
        chained_dma_test(bar_table, dma_bar, RD_DIRECTION , 0, 0); --DMA Read with EPLast
        chained_dma_test(bar_table, dma_bar, WR_DIRECTION , 0, 0); --DMA Write with EPLast
        check_dma_data ( WR_DESC2_LENGTH,
                         RD_DESC2_LENGTH,
                         WR_DESC2_RCADDR_LSB,
                         RD_DESC2_RCADDR_LSB);


     else
       ebfm_display(EBFM_MSG_WARNING,
      "Unable to find a 256B BAR to setup the chaining DMA DUT; skipping test.");
     end if;


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

