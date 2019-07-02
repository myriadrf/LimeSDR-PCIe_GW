-------------------------------------------------------------------------------
-- Title         : PCI Express Reference Design Example Application
-- Project       : PCI Express MegaCore function
-------------------------------------------------------------------------------
-- File          : altpcierd_ast256_downstream.v
-- Author        : Altera Corporation
-------------------------------------------------------------------------------
-- Description :
-- This is the complete example application for the PCI Express Reference
-- Design. This has all of the application logic for the example.
-------------------------------------------------------------------------------
-- Copyright (c) 2010 Altera Corporation. All rights reserved.  Altera products are
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

ENTITY altpcierd_ast256_downstream IS
   GENERIC (
      AVALON_WADDR           : INTEGER := 12;
      AVALON_WDATA           : INTEGER := 256;
      MAX_NUMTAG             : INTEGER := 64;
      MAX_PAYLOAD_SIZE_BYTE  : INTEGER := 512;
      BOARD_DEMO             : INTEGER := 1;
      USE_RCSLAVE            : INTEGER := 0;
      TL_SELECTION           : INTEGER := 0;
      CLK_250_APP            : INTEGER := 0;
      ECRC_FORWARD_CHECK     : INTEGER := 0;
      ECRC_FORWARD_GENER     : INTEGER := 0;
      CHECK_BUS_MASTER_ENA   : INTEGER := 0;
      CHECK_RX_BUFFER_CPL    : INTEGER := 0;
      AVALON_ST_128          : INTEGER := 0;
      USE_CREDIT_CTRL        : INTEGER := 0;
      RC_64BITS_ADDR         : INTEGER := 0;
      USE_MSI                : INTEGER := 1
   );
   PORT (

      rx_st_bardec0          : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      rx_st_be0              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      rx_st_data0            : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
      rx_st_empty0           : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      rx_st_eop0             : IN STD_LOGIC;
      rx_st_err0             : IN STD_LOGIC;
      rx_st_sop0             : IN STD_LOGIC;
      rx_st_valid0           : IN STD_LOGIC;
      rx_st_mask0            : OUT STD_LOGIC;
      rx_st_ready0           : OUT STD_LOGIC;

      tx_st_ready0           : IN STD_LOGIC;
      tx_st_data0            : OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
      tx_st_empty0           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      tx_st_eop0             : OUT STD_LOGIC;
      tx_st_err0             : OUT STD_LOGIC;
      tx_st_parity0          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      tx_st_sop0             : OUT STD_LOGIC;
      tx_st_valid0           : OUT STD_LOGIC;

      -- Credit
      tx_cred_datafccp       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      tx_cred_datafcnp       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      tx_cred_datafcp        : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      tx_cred_fchipcons      : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      tx_cred_fcinfinite     : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      tx_cred_hdrfccp        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      tx_cred_hdrfcnp        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      tx_cred_hdrfcp         : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

      -- MSI Interrupt
      -- Avalon ST Interface only
      aer_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      pex_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
      app_msi_req            : OUT STD_LOGIC;
      app_msi_ack            : IN STD_LOGIC;
      app_msi_tc             : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      app_msi_num            : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);

      -- Legacy Interrupt
      app_int_sts            : OUT STD_LOGIC;
      app_int_ack            : IN STD_LOGIC;

      -- Configuration info signals
      -- Desc/Data Interface + Avalon ST Interface
      cfg_busdev             : IN STD_LOGIC_VECTOR(12 DOWNTO 0);     -- Bus device number captured by the core
      cfg_devcsr             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);     -- Configuration dev control status register of
      -- PCIe capability structure (address 0x88)
      cfg_prmcsr             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);     -- Control and status of the PCI configuration space (address 0x4)
      cfg_tcvcmap            : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
      cfg_linkcsr            : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      cfg_msicsr             : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      cpl_pending            : OUT STD_LOGIC;
      cpl_err                : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      err_desc               : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);

      ko_cpl_spc_vc0         : IN STD_LOGIC_VECTOR(19 DOWNTO 0);

      pm_data                : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
      test_sim               : IN STD_LOGIC;

      clk_in                 : IN STD_LOGIC;

      rstn                   : IN STD_LOGIC
   );
END ENTITY altpcierd_ast256_downstream;

ARCHITECTURE trans OF altpcierd_ast256_downstream IS
   COMPONENT onchip_256xram IS
      PORT (
         clock                  : IN STD_LOGIC;
         data                   : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
         rdaddress              : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
         rden                   : IN STD_LOGIC;
         wraddress              : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
         wren                   : IN STD_LOGIC;
         q                      : OUT STD_LOGIC_VECTOR(255 DOWNTO 0)
      );
   END COMPONENT;


   SIGNAL ZERO                   : STD_LOGIC_VECTOR(255 DOWNTO 0);

   CONSTANT ST_TX_IDLE             : STD_LOGIC_VECTOR(2 DOWNTO 0):= "000";
   CONSTANT ST_RD_DATA             : STD_LOGIC_VECTOR(2 DOWNTO 0):= "001";
   CONSTANT ST_TX_SOP_CPLD         : STD_LOGIC_VECTOR(2 DOWNTO 0):= "010";
   CONSTANT ST_TX_MOP_CPLD         : STD_LOGIC_VECTOR(2 DOWNTO 0):= "011";

   SIGNAL cstate_tx              : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL nstate_tx              : STD_LOGIC_VECTOR(2 DOWNTO 0);

   SIGNAL wrdata                 : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL byteena_a              : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL byteena_b              : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rdaddress              : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL wren                   : STD_LOGIC;
   SIGNAL rddata                 : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL wraddress              : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL wraddress_r            : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL rden                   : STD_LOGIC;
   SIGNAL tlp_read               : STD_LOGIC;
   SIGNAL tlp_write              : STD_LOGIC;
   SIGNAL tlp_rx_len             : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tlp_3dw_header         : STD_LOGIC;
   SIGNAL tlp_sop                : STD_LOGIC;

   SIGNAL tlp_addr_qwaligned     : STD_LOGIC;
   SIGNAL bar_downstream         : STD_LOGIC;
   SIGNAL bar_upstream           : STD_LOGIC;

   SIGNAL tx_st_data_dw0         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw1         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw2         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw3         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw4         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw5         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw6         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_st_data_dw7         : STD_LOGIC_VECTOR(31 DOWNTO 0);

   SIGNAL rx_st_data_dw0         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw1         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw2         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw3         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw4         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw5         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw6         : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_st_data_dw7         : STD_LOGIC_VECTOR(31 DOWNTO 0);

   SIGNAL rx_st_fmt              : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL rx_st_type             : STD_LOGIC_VECTOR(4 DOWNTO 0);
   SIGNAL rx_st_len              : STD_LOGIC_VECTOR(9 DOWNTO 0);

   SIGNAL rx_h0                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_h1                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_h2                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL rx_h3                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL payload_h              : STD_LOGIC_VECTOR(159 DOWNTO 0);

   SIGNAL tx_h0                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_h1                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL tx_h2                  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL reqid_tag              : STD_LOGIC_VECTOR(23 DOWNTO 0);
   SIGNAL addr_len_cnt           : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_h0_len              : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_len_cnt             : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL tx_h2_lower_add        : STD_LOGIC_VECTOR(6 DOWNTO 0);
   SIGNAL rd_data                : STD_LOGIC_VECTOR(127 DOWNTO 0);
   -- X-HDL generated signals

   SIGNAL altr_wire1 : STD_LOGIC;
   SIGNAL altr_wire2 : STD_LOGIC;
   SIGNAL altr_wire3 : STD_LOGIC;
   SIGNAL altr_wire4 : STD_LOGIC;
   SIGNAL altr_wire5 : STD_LOGIC;
   SIGNAL altr_wire6 : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL altr_wire7 : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL altr_wire8 : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL altr_wire9 : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL altr_wire10 : STD_LOGIC;
   SIGNAL altr_wire11 : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL altr_wire12 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL altr_wire13 : STD_LOGIC;
   SIGNAL altr_wire14 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL altr_wire15 : STD_LOGIC;
   SIGNAL altr_wire16 : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL altr_wire17 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL altr_wire18 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL altr_wire19 : STD_LOGIC_VECTOR(2 DOWNTO 0);
   SIGNAL altr_wire20 : STD_LOGIC;
   SIGNAL altr_wire21 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL altr_wire22 : STD_LOGIC;
   SIGNAL altr_wire23 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL altr_wire24 : STD_LOGIC;
   SIGNAL altr_wire25 : STD_LOGIC_VECTOR(255 DOWNTO 0);
   SIGNAL altr_wire26 : STD_LOGIC;
   SIGNAL altr_wire27 : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL altr_wire28 : STD_LOGIC;

   -- Declare intermediate signals for referenced outputs
   SIGNAL tx_st_data0_altr_wire0 : STD_LOGIC_VECTOR(255 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   tx_st_data0 <= tx_st_data0_altr_wire0;

   rx_st_mask0 <= '0';
   rx_st_ready0 <= '1' WHEN (cstate_tx = ST_TX_IDLE) ELSE
                   '0';
   aer_msi_num <= ZERO(4 DOWNTO 0);
   pex_msi_num <= ZERO(4 DOWNTO 0);
   app_msi_req <= '0';
   app_msi_tc <= ZERO(2 DOWNTO 0);
   app_msi_num <= ZERO(4 DOWNTO 0);
   app_int_sts <= '0';
   cpl_pending <= '0';
   cpl_err <= ZERO(6 DOWNTO 0);
   err_desc <= ZERO(127 DOWNTO 0);
   pm_data <= ZERO(9 DOWNTO 0);

   ZERO <= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";


   rx_st_data_dw7 <= rx_st_data0(255 downto 224);
   rx_st_data_dw6 <= rx_st_data0(223 downto 192);
   rx_st_data_dw5 <= rx_st_data0(191 downto 160);
   rx_st_data_dw4 <= rx_st_data0(159 downto 128);
   rx_st_data_dw3 <= rx_st_data0(127 downto 96 );
   rx_st_data_dw2 <= rx_st_data0(95  downto 64 );
   rx_st_data_dw1 <= rx_st_data0(63  downto 32 );
   rx_st_data_dw0 <= rx_st_data0(31  downto 0  );


   bar_downstream <= rx_st_bardec0(0) OR rx_st_bardec0(1) OR rx_st_bardec0(4) OR rx_st_bardec0(5);
   bar_upstream <= rx_st_bardec0(2) OR rx_st_bardec0(3);
   rx_st_fmt <= rx_st_data_dw0(30 DOWNTO 29);
   rx_st_type <= rx_st_data_dw0(28 DOWNTO 24);
   rx_st_len <= rx_st_data_dw0(9 DOWNTO 0);

   altr_wire1 <= '1' WHEN ((rx_st_valid0 = '1') AND (rx_st_sop0 = '1')) ELSE '0';
   altr_wire2 <= '1' WHEN (rx_st_data_dw3(2 DOWNTO 0) = "000") ELSE '0';
   altr_wire3 <= '1' WHEN (rx_st_data_dw2(2 DOWNTO 0) = "000") ELSE '0';
   altr_wire4 <= '1' WHEN ((rx_st_fmt(1) = '0') AND (rx_st_type = "00000")) ELSE '0';
   altr_wire5 <= '1' WHEN ((rx_st_fmt(1) = '1') AND (rx_st_type = "00000")) ELSE '0';
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         rx_h0 <= "00000000000000000000000000000000";
         rx_h1 <= "00000000000000000000000000000000";
         rx_h2 <= "00000000000000000000000000000000";
         rx_h3 <= "00000000000000000000000000000000";
         tlp_read <= '0';
         tlp_sop <= '0';
         tlp_write <= '0';
         tlp_3dw_header <= '0';
         tlp_addr_qwaligned <= '0';
         reqid_tag <= "000000000000000000000000";
         tx_h2_lower_add <= "0000000";
         tx_h0_len <= "0000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         tlp_sop <= altr_wire1;
         IF ((rx_st_valid0 = '1') AND (rx_st_sop0 = '1')) THEN
            rx_h0 <= rx_st_data_dw0;
            rx_h1 <= rx_st_data_dw1;
            rx_h2 <= rx_st_data_dw2;
            reqid_tag <= rx_st_data_dw1(31 DOWNTO 8);
            tx_h0_len <= rx_st_data_dw0(9 DOWNTO 0);
            IF (rx_st_fmt(0) = '1') THEN
               rx_h3 <= rx_st_data_dw3;
               tlp_3dw_header <= '0';
               tlp_addr_qwaligned <= altr_wire2;
               tx_h2_lower_add <= rx_st_data_dw3(6 DOWNTO 0);
            ELSE
               tlp_3dw_header <= '1';
               tlp_addr_qwaligned <= altr_wire3;
               tx_h2_lower_add <= rx_st_data_dw2(6 DOWNTO 0);
            END IF;
            tlp_read <= altr_wire4;
            tlp_write <= altr_wire5;
         ELSIF (rx_st_valid0 = '0') THEN
            tlp_read <= '0';
            tlp_write <= '0';
         END IF;
      END IF;
   END PROCESS;

   -- Mem Write
   -- 4DW header
   altr_wire6 <= (rx_st_data0(127 DOWNTO 0) & payload_h(159 DOWNTO 32)) WHEN (tlp_addr_qwaligned = '1') ELSE
                (rx_st_data0(159 DOWNTO 0) & payload_h(159 DOWNTO 64));
   altr_wire7 <= rx_h3(11 DOWNTO 0) WHEN (tlp_sop = '1') ELSE
                wraddress_r;
   -- 3DW header
   altr_wire8 <= (rx_st_data0(127 DOWNTO 0) & payload_h(159 DOWNTO 32)) WHEN (tlp_addr_qwaligned = '1') ELSE
                (rx_st_data0(95 DOWNTO 0) & payload_h(159 DOWNTO 0));
   altr_wire9 <= rx_h2(11 DOWNTO 0) WHEN (tlp_sop = '1') ELSE
                wraddress_r;
   altr_wire10 <= '1' WHEN (tlp_rx_len > "0000000000") ELSE
                '0';
   PROCESS (tlp_rx_len, tlp_3dw_header, tlp_addr_qwaligned, rx_st_data0, payload_h, tlp_sop, rx_h3, wraddress_r, rx_h2, tlp_write, altr_wire10, altr_wire9, altr_wire7, altr_wire6)
   BEGIN
      CASE tlp_rx_len IS
         WHEN "0000000001" =>
            byteena_a(31 DOWNTO 0) <= "00000000000000000000000000001111";
         WHEN "0000000010" =>
            byteena_a(31 DOWNTO 0) <= "00000000000000000000000011111111";
         WHEN "0000000011" =>
            byteena_a(31 DOWNTO 0) <= "00000000000000000000111111111111";
         WHEN "0000000100" =>
            byteena_a(31 DOWNTO 0) <= "00000000000000001111111111111111";
         WHEN "0000000101" =>
            byteena_a(31 DOWNTO 0) <= "00000000000011111111111111111111";
         WHEN "0000000110" =>
            byteena_a(31 DOWNTO 0) <= "00000000111111111111111111111111";
         WHEN "0000000111" =>
            byteena_a(31 DOWNTO 0) <= "00001111111111111111111111111111";
         WHEN OTHERS =>
            byteena_a(31 DOWNTO 0) <= "11111111111111111111111111111111";
      END CASE;
      IF (tlp_3dw_header = '0') THEN
         wrdata <= altr_wire6;
         wraddress(11 DOWNTO 0) <= altr_wire7;
      ELSE
         wrdata <= altr_wire8;
         wraddress(11 DOWNTO 0) <= altr_wire9;
      END IF;
      IF (tlp_write = '1') THEN
         wren <= altr_wire10;
      ELSE
         wren <= '0';
      END IF;
   END PROCESS;

   altr_wire11 <= wraddress + "000000000001" WHEN (tlp_sop = '1') ELSE wraddress_r + "000000000001";
   altr_wire12 <= tlp_rx_len - "0000001000" WHEN (tlp_rx_len > "0000001000") ELSE "0000000000";
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         payload_h <= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
         tlp_rx_len <= "0000000000";
         wraddress_r(11 DOWNTO 0) <= "000000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         payload_h <= (rx_st_data_dw7 & rx_st_data_dw6 & rx_st_data_dw5 & rx_st_data_dw4 & rx_st_data_dw3);
         IF (rx_st_valid0 = '1') THEN
            wraddress_r <= altr_wire11;
         END IF;
         IF ((rx_st_valid0 = '1') AND (rx_st_sop0 = '1')) THEN
            tlp_rx_len <= rx_st_len;
         ELSIF (tlp_write = '1') THEN
            tlp_rx_len <= altr_wire12;
         ELSE
            tlp_rx_len <= "0000000000";
         END IF;
      END IF;
   END PROCESS;

   -- MEM read
   altr_wire13 <= '1' WHEN (addr_len_cnt > "0000000000") ELSE '0';
   altr_wire14 <= addr_len_cnt - "0000001000" WHEN (addr_len_cnt > "0000001000") ELSE "0000000000";
   altr_wire15 <= '1' WHEN (addr_len_cnt > "0000001000") ELSE '0';
   altr_wire16 <= rx_h3(11 DOWNTO 0) WHEN (tlp_3dw_header = '0') ELSE rx_h2(11 DOWNTO 0);
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         rdaddress <= ZERO(11 DOWNTO 0);
         rden <= ZERO(0);
         byteena_b(31 DOWNTO 0) <= "11111111111111111111111111111111";
         addr_len_cnt <= "0000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         rd_data <= rddata(255 DOWNTO 128);
         rden <= altr_wire13;
         IF ((rx_st_valid0 = '1') AND (rx_st_sop0 = '1') AND (rx_st_fmt(1) = '0') AND (rx_st_type = "00000")) THEN
            addr_len_cnt <= rx_st_len;
            rden <= '1';
         ELSIF (tx_st_ready0 = '1') THEN
            addr_len_cnt <= altr_wire14;
            rden <= altr_wire15;
         END IF;
         IF ((tlp_sop = '1') AND (tlp_read = '1')) THEN
            rdaddress(11 DOWNTO 0) <= altr_wire16;
         ELSIF (addr_len_cnt > "0000000000") THEN
            -- 3DW header
            rdaddress(11 DOWNTO 0) <= rdaddress + "000000000001";
         END IF;
      END IF;
   END PROCESS;



   onchip_ram : onchip_256xram
      PORT MAP (
         clock      => clk_in,
         data       => wrdata,
         rdaddress  => rdaddress,
         wraddress  => wraddress,
         wren       => wren,
         rden       => rden,
         q          => rddata
      );

   -- Reflects the beginning of a new descriptor
   altr_wire17 <= ST_RD_DATA WHEN (rden = '1') ELSE
                             ST_TX_IDLE;

   --
   -- rx_ack upon rx_req and CPLD, and DMA Read tag
   altr_wire18 <= ST_RD_DATA WHEN (rden = '1') ELSE
                             ST_TX_IDLE;
   --
   altr_wire19 <= ST_RD_DATA WHEN (rden = '1') ELSE
                             ST_TX_IDLE;
   PROCESS (cstate_tx,  rden, tx_st_ready0, tx_len_cnt, altr_wire17, altr_wire18 , altr_wire19)
   BEGIN
      CASE cstate_tx IS
         WHEN ST_TX_IDLE =>
            nstate_tx <= altr_wire17;
         WHEN ST_RD_DATA =>
            nstate_tx <= ST_TX_SOP_CPLD;
         WHEN ST_TX_SOP_CPLD =>
            IF (tx_st_ready0 = '1') THEN
               IF (tx_len_cnt = "0000000000") THEN
                  nstate_tx <= altr_wire18;
               ELSIF (tx_len_cnt > "0000001000") THEN
                  nstate_tx <= ST_TX_MOP_CPLD;
               ELSE
                  nstate_tx <= ST_TX_SOP_CPLD;
               END IF;
            ELSE
               nstate_tx <= ST_TX_SOP_CPLD;
            END IF;
         WHEN ST_TX_MOP_CPLD =>
            IF (tx_st_ready0 = '0') THEN
               nstate_tx <= ST_TX_MOP_CPLD;
            ELSIF (tx_len_cnt = "0000000000") THEN
               nstate_tx <= altr_wire19;
            ELSE
               nstate_tx <= ST_TX_MOP_CPLD;
            END IF;

         WHEN OTHERS =>
            nstate_tx <= ST_TX_IDLE;
      END CASE;
   END PROCESS;

   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         cstate_tx <= ST_TX_IDLE;
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         cstate_tx <= nstate_tx;
      END IF;
   END PROCESS;

   altr_wire20 <= '1' WHEN (tx_h0_len < "0000000101") ELSE
                '0';
   altr_wire21 <= "0000000000" WHEN (tx_h0_len < "0000000101") ELSE
                tx_h0_len - "0000000101";
   altr_wire22 <= '1' WHEN (tx_h0_len < "0000000110") ELSE
                '0';
   altr_wire23 <= "0000000000" WHEN (tx_h0_len < "0000000110") ELSE
                tx_h0_len - "0000000110";
   altr_wire24 <= '1' WHEN (tx_st_ready0 = '1') ELSE
                '0';
   altr_wire25 <= (rddata(127 DOWNTO 0) & rd_data(127 DOWNTO 0)) WHEN (tx_h2_lower_add(2 DOWNTO 0) = "000") ELSE
                (rddata(159 DOWNTO 0) & rd_data(95 DOWNTO 0));
   altr_wire26 <= '1' WHEN (tx_len_cnt < "0000001000") ELSE
                '0';
   altr_wire27 <= "0000000000" WHEN (tx_len_cnt < "0000001000") ELSE
                tx_h0_len - "0000001000";
   altr_wire28 <= '1' WHEN (tx_st_ready0 = '1') ELSE
                '0';
   PROCESS (rstn, clk_in)
   BEGIN
      IF (rstn = '0') THEN
         tx_st_data0_altr_wire0 <= "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
         tx_st_empty0 <= "00";
         tx_st_eop0 <= '0';
         tx_st_err0 <= '0';
         tx_st_parity0 <= "00000000000000000000000000000000";
         tx_st_sop0 <= '0';
         tx_st_valid0 <= '0';
         tx_len_cnt <= "0000000000";
      ELSIF (clk_in'EVENT AND clk_in = '1') THEN
         tx_st_parity0 <= "00000000000000000000000000000000";
         tx_st_err0 <= '0';
         IF (cstate_tx = ST_TX_SOP_CPLD) THEN
            tx_st_sop0 <= '1';
            IF (tx_h2_lower_add(2 DOWNTO 0) = "000") THEN
               tx_st_data0_altr_wire0 <= (rddata(127 DOWNTO 0) & "00000000000000000000000000000000" & tx_h2 & tx_h1 & tx_h0);
               tx_st_eop0 <= altr_wire20;
               tx_len_cnt <= altr_wire21;
               CASE tx_h0_len IS
                  WHEN "0000000001" =>
                     tx_st_empty0 <= "01";
                  WHEN "0000000010" =>
                     tx_st_empty0 <= "01";
                  WHEN OTHERS =>
                     tx_st_empty0 <= "00";
               END CASE;
            ELSE
               tx_st_data0_altr_wire0 <= (rddata(159 DOWNTO 0) & tx_h2 & tx_h1 & tx_h0);
               tx_st_eop0 <= altr_wire22;
               tx_len_cnt <= altr_wire23;
               CASE tx_h0_len IS
                  WHEN "0000000001" =>
                     tx_st_empty0 <= "10";
                  WHEN "0000000010" =>
                     tx_st_empty0 <= "01";
                  WHEN "0000000011" =>
                     tx_st_empty0 <= "01";
                  WHEN OTHERS =>
                     tx_st_empty0 <= "00";
               END CASE;
            END IF;
            tx_st_valid0 <= altr_wire24;
         ELSIF (cstate_tx = ST_TX_MOP_CPLD) THEN
            tx_st_sop0 <= '0';
            tx_st_data0_altr_wire0 <= altr_wire25;
            tx_st_eop0 <= altr_wire26;
            tx_len_cnt <= altr_wire27;
            CASE tx_len_cnt IS
               WHEN "0000000001" =>
                  tx_st_empty0 <= "11";
               WHEN "0000000010" =>
                  tx_st_empty0 <= "10";
               WHEN "0000000011" =>
                  tx_st_empty0 <= "10";
               WHEN "0000000100" =>
                  tx_st_empty0 <= "01";
               WHEN "0000000101" =>
                  tx_st_empty0 <= "01";
               WHEN OTHERS =>
                  tx_st_empty0 <= "00";
            END CASE;
            tx_st_valid0 <= altr_wire28;
         ELSE
            tx_st_valid0 <= '0';
            tx_st_sop0 <= '0';
            tx_st_eop0 <= '0';
            tx_st_empty0 <= "00";
         END IF;
      END IF;
   END PROCESS;

   -- TX TLP Header
   tx_h0(9 DOWNTO 0) <= tx_h0_len(9 DOWNTO 0);
   tx_h0(15 DOWNTO 10) <= "000000";
   tx_h0(23 DOWNTO 16) <= "00000000";
   tx_h0(28 DOWNTO 24) <= "01010";     -- FMT CPLD
   tx_h0(31 DOWNTO 29) <= "010";    -- CPLD with data

   tx_h1(11 DOWNTO 0) <= (tx_h0_len & "00");    -- Byte count
   tx_h1(15 DOWNTO 12) <= "0000";
   tx_h1(31 DOWNTO 16) <= (cfg_busdev(12 DOWNTO 0) & "000");      -- Bus /Dev /Function=0

   tx_h2(6 DOWNTO 0) <= tx_h2_lower_add(6 DOWNTO 0);
   tx_h2(7) <= '0';
   tx_h2(31 DOWNTO 8) <= reqid_tag(23 DOWNTO 0);

   -- For debug
   tx_st_data_dw0 <= tx_st_data0_altr_wire0(31 DOWNTO 0);
   tx_st_data_dw1 <= tx_st_data0_altr_wire0(63 DOWNTO 32);
   tx_st_data_dw2 <= tx_st_data0_altr_wire0(95 DOWNTO 64);
   tx_st_data_dw3 <= tx_st_data0_altr_wire0(127 DOWNTO 96);
   tx_st_data_dw4 <= tx_st_data0_altr_wire0(159 DOWNTO 128);
   tx_st_data_dw5 <= tx_st_data0_altr_wire0(191 DOWNTO 160);
   tx_st_data_dw6 <= tx_st_data0_altr_wire0(223 DOWNTO 192);
   tx_st_data_dw7 <= tx_st_data0_altr_wire0(255 DOWNTO 224);

END ARCHITECTURE trans;




LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY onchip_256xram IS
   PORT
   (
      clock    : IN STD_LOGIC  := '1';
      data     : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
      rdaddress      : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
      rden     : IN STD_LOGIC  := '1';
      wraddress      : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
      wren     : IN STD_LOGIC  := '0';
      q     : OUT STD_LOGIC_VECTOR (255 DOWNTO 0)
   );
END onchip_256xram;


ARCHITECTURE SYN OF onchip_256xram IS

   SIGNAL sub_wire0  : STD_LOGIC_VECTOR (255 DOWNTO 0);



   COMPONENT altsyncram
   GENERIC (
      address_aclr_b    : STRING;
      address_reg_b     : STRING;
      clock_enable_input_a    : STRING;
      clock_enable_input_b    : STRING;
      clock_enable_output_b      : STRING;
      intended_device_family     : STRING;
      lpm_type    : STRING;
      numwords_a     : NATURAL;
      numwords_b     : NATURAL;
      operation_mode    : STRING;
      outdata_aclr_b    : STRING;
      outdata_reg_b     : STRING;
      power_up_uninitialized     : STRING;
      rdcontrol_reg_b      : STRING;
      read_during_write_mode_mixed_ports     : STRING;
      widthad_a      : NATURAL;
      widthad_b      : NATURAL;
      width_a     : NATURAL;
      width_b     : NATURAL;
      width_byteena_a      : NATURAL
   );
   PORT (
         address_a   : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
         clock0   : IN STD_LOGIC ;
         data_a   : IN STD_LOGIC_VECTOR (255 DOWNTO 0);
         q_b   : OUT STD_LOGIC_VECTOR (255 DOWNTO 0);
         rden_b   : IN STD_LOGIC ;
         wren_a   : IN STD_LOGIC ;
         address_b   : IN STD_LOGIC_VECTOR (11 DOWNTO 0)
   );
   END COMPONENT;

BEGIN
   q    <= sub_wire0(255 DOWNTO 0);

   altsyncram_component : altsyncram
   GENERIC MAP (
      address_aclr_b => "NONE",
      address_reg_b => "CLOCK0",
      clock_enable_input_a => "BYPASS",
      clock_enable_input_b => "BYPASS",
      clock_enable_output_b => "BYPASS",
      intended_device_family => "Stratix IV",
      lpm_type => "altsyncram",
      numwords_a => 4096,
      numwords_b => 4096,
      operation_mode => "DUAL_PORT",
      outdata_aclr_b => "NONE",
      outdata_reg_b => "CLOCK0",
      power_up_uninitialized => "FALSE",
      rdcontrol_reg_b => "CLOCK0",
      read_during_write_mode_mixed_ports => "DONT_CARE",
      widthad_a => 12,
      widthad_b => 12,
      width_a => 256,
      width_b => 256,
      width_byteena_a => 1
   )
   PORT MAP (
      address_a => wraddress,
      clock0 => clock,
      data_a => data,
      rden_b => rden,
      wren_a => wren,
      address_b => rdaddress,
      q_b => sub_wire0
   );



END SYN;

