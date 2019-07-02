-- /**
--  * This VDHL file is used for simulation and synthesis in
--  * the chaining DMA design example.
--  */
-------------------------------------------------------------------------------
-- File          : altpcierd_pcie_reconfig.vhd
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
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
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

ENTITY altpcierd_pcie_reconfig_initiator IS
   PORT (
      avs_pcie_reconfig_address        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      avs_pcie_reconfig_chipselect     : OUT STD_LOGIC;
      avs_pcie_reconfig_write          : OUT STD_LOGIC;
      avs_pcie_reconfig_writedata      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      avs_pcie_reconfig_waitrequest    : IN STD_LOGIC;
      avs_pcie_reconfig_read           : OUT STD_LOGIC;
      avs_pcie_reconfig_readdata       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      avs_pcie_reconfig_readdatavalid  : IN STD_LOGIC;
      avs_pcie_reconfig_clk            : OUT STD_LOGIC;
      avs_pcie_reconfig_rstn           : OUT STD_LOGIC;
      pcie_rstn                        : IN STD_LOGIC;
      set_pcie_reconfig                : IN STD_LOGIC;
      pcie_reconfig_clk                : IN STD_LOGIC;
      pcie_reconfig_busy               : OUT STD_LOGIC
   );
END ENTITY altpcierd_pcie_reconfig_initiator;

ARCHITECTURE trans OF altpcierd_pcie_reconfig_initiator IS

   CONSTANT IDLE_ST                          : std_logic_vector(2 downto 0) := "000";
   CONSTANT ENABLE_PCIE_RECONFIG_ST          : std_logic_vector(2 downto 0) := "001";
   CONSTANT READ_VENDOR_ID_ST                : std_logic_vector(2 downto 0) := "010";
   CONSTANT VENDOR_ID_UPD_ST                 : std_logic_vector(2 downto 0) := "011";
   CONSTANT WRITE_VENDOR_ID_ST               : std_logic_vector(2 downto 0) := "100";
   CONSTANT PCIE_RECONFIG_DONE_ST            : std_logic_vector(2 downto 0) := "101";
   SIGNAL cstate         : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL nstate         : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL pcie_rstn_sync : STD_LOGIC_VECTOR(2 DOWNTO 0);

attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of pcie_rstn_sync : signal is "SUPPRESS_DA_RULE_INTERNAL=R102 ; SUPPRESS_DA_RULE_INTERNAL=R101";

BEGIN

   pcie_reconfig_busy <= '0' WHEN (cstate = PCIE_RECONFIG_DONE_ST) ELSE
                         '1';
   avs_pcie_reconfig_rstn <= pcie_rstn_sync(2);
   avs_pcie_reconfig_clk <= pcie_reconfig_clk;

   PROCESS (cstate, set_pcie_reconfig, pcie_rstn_sync, avs_pcie_reconfig_waitrequest )
   BEGIN
      CASE cstate IS

         WHEN IDLE_ST =>
            IF (set_pcie_reconfig = '1') THEN
               IF (pcie_rstn_sync(2) = '1') THEN
                  nstate <= ENABLE_PCIE_RECONFIG_ST;
               ELSE
                  nstate <= IDLE_ST;
               END IF;
            ELSE
               nstate <= PCIE_RECONFIG_DONE_ST;
            END IF;

         WHEN ENABLE_PCIE_RECONFIG_ST =>
            IF (avs_pcie_reconfig_waitrequest = '0') THEN
               nstate <= READ_VENDOR_ID_ST;
            ELSE
               nstate <= ENABLE_PCIE_RECONFIG_ST;
            END IF;

         WHEN READ_VENDOR_ID_ST =>
            IF (avs_pcie_reconfig_waitrequest = '0') THEN
               nstate <= VENDOR_ID_UPD_ST;
            ELSE
               nstate <= READ_VENDOR_ID_ST;
            END IF;

         WHEN VENDOR_ID_UPD_ST =>
            nstate <= WRITE_VENDOR_ID_ST;

         WHEN WRITE_VENDOR_ID_ST =>
            IF (avs_pcie_reconfig_waitrequest = '0') THEN
               nstate <= PCIE_RECONFIG_DONE_ST;
            ELSE
               nstate <= WRITE_VENDOR_ID_ST;
            END IF;

         WHEN PCIE_RECONFIG_DONE_ST =>
            nstate <= PCIE_RECONFIG_DONE_ST;

         WHEN OTHERS =>
            nstate <= IDLE_ST;
      END CASE;
   END PROCESS;

   PROCESS (pcie_rstn_sync(2), pcie_reconfig_clk)
   BEGIN
      IF (pcie_rstn_sync(2) = '0') THEN
         avs_pcie_reconfig_address <= "00000000";
         avs_pcie_reconfig_chipselect <= '0';
         avs_pcie_reconfig_write <= '0';
         avs_pcie_reconfig_writedata <= "0000000000000000";
         avs_pcie_reconfig_read <= '0';
      ELSIF (pcie_reconfig_clk'EVENT AND pcie_reconfig_clk = '1') THEN
         IF (cstate = ENABLE_PCIE_RECONFIG_ST) THEN
            avs_pcie_reconfig_address <= "00000000";
         ELSE

            avs_pcie_reconfig_address <= ('1' & "0001001");    --Vendor ID
         END IF;
         IF ((cstate = ENABLE_PCIE_RECONFIG_ST) AND (set_pcie_reconfig = '1')) THEN
            avs_pcie_reconfig_writedata <= "0000000000000000";
         ELSIF ((cstate = ENABLE_PCIE_RECONFIG_ST) AND (set_pcie_reconfig = '0')) THEN
            avs_pcie_reconfig_writedata <= "0000000000000001";
         ELSIF (avs_pcie_reconfig_readdatavalid = '1') THEN
            avs_pcie_reconfig_writedata <= avs_pcie_reconfig_readdata + "0000000000000001";
         END IF;
         IF (cstate = READ_VENDOR_ID_ST) THEN
            IF (avs_pcie_reconfig_waitrequest = '1') THEN
               avs_pcie_reconfig_chipselect <= '1';
               avs_pcie_reconfig_read <= '1';
            ELSE
               avs_pcie_reconfig_chipselect <= '0';
               avs_pcie_reconfig_read <= '0';
            END IF;
            avs_pcie_reconfig_write <= '0';
         ELSIF ((cstate = WRITE_VENDOR_ID_ST) OR (cstate = ENABLE_PCIE_RECONFIG_ST)) THEN
            IF (avs_pcie_reconfig_waitrequest = '1') THEN
               avs_pcie_reconfig_chipselect <= '1';
               avs_pcie_reconfig_write <= '1';
            ELSE
               avs_pcie_reconfig_chipselect <= '0';
               avs_pcie_reconfig_write <= '0';
            END IF;
            avs_pcie_reconfig_read <= '0';
         ELSE
            avs_pcie_reconfig_chipselect <= '0';
            avs_pcie_reconfig_write <= '0';
            avs_pcie_reconfig_read <= '0';
         END IF;
      END IF;
   END PROCESS;

   PROCESS (pcie_rstn_sync(2), pcie_reconfig_clk)
   BEGIN
      IF (pcie_rstn_sync(2) = '0') THEN
         cstate <= IDLE_ST;
      ELSIF (pcie_reconfig_clk'EVENT AND pcie_reconfig_clk = '1') THEN
         cstate <= nstate;
      END IF;
   END PROCESS;

   PROCESS (pcie_rstn, pcie_reconfig_clk)
   BEGIN
      IF (pcie_rstn = '0') THEN
         pcie_rstn_sync <= "000";
      ELSIF (pcie_reconfig_clk'EVENT AND pcie_reconfig_clk = '1') THEN
         pcie_rstn_sync(0) <= '1';
         pcie_rstn_sync(1) <= pcie_rstn_sync(0);
         pcie_rstn_sync(2) <= pcie_rstn_sync(1);
      END IF;
   END PROCESS;

END ARCHITECTURE trans;


