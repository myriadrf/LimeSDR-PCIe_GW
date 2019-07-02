LIBRARY ieee;                          
use IEEE.std_logic_1164.all;           
use IEEE.std_logic_arith.all;          
use IEEE.std_logic_unsigned.all;       
                                       
LIBRARY altera_mf;                     
USE altera_mf.altera_mf_components.all;
                                       
LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;

-- /**
--  * This Verilog HDL file is used for simulation and synthesis in  
--  * the chaining DMA design example. It could be used by the software 
--  * application (Root Port) to retrieve the DMA Performance counter values 
--  * and performs read and write to the Endpoint memory by 
--  * bypassing the DMA engines.
--  */
-- synthesis translate_off

-- synthesis translate_on
-- synthesis verilog_input_version verilog_2001 

-- Copyright  2008 Altera Corporation. All rights reserved.  Altera products are
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
ENTITY altpcierd_rc_slave IS
   GENERIC (
      AVALON_WDATA             : INTEGER := 128;
      AVALON_WADDR             : INTEGER := 12;
      AVALON_ST_128            : INTEGER := 0;
      AVALON_BYTE_WIDTH        : INTEGER := 16
   );
   PORT (
      
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      dma_rd_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_wr_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_prg_addr             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dma_prg_wrdata           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      dma_wr_prg_wrena         : OUT STD_LOGIC;
      dma_rd_prg_wrena         : OUT STD_LOGIC;
      
      mem_wr_ena               : OUT STD_LOGIC;     -- rename this to write_downstream
      mem_rd_ena               : OUT STD_LOGIC;
      
      rx_ecrc_bad_cnt          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      read_dma_status          : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      write_dma_status         : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      cfg_busdev               : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      rx_req                   : IN STD_LOGIC;
      rx_desc                  : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                  : IN STD_LOGIC_VECTOR(AVALON_WDATA-1 DOWNTO 0);
      rx_be                    : IN STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH-1 DOWNTO 0);
      rx_dv                    : IN STD_LOGIC;
      rx_dfr                   : IN STD_LOGIC;
      rx_ack                   : OUT STD_LOGIC;
      rx_ws                    : OUT STD_LOGIC;
      tx_ws                    : IN STD_LOGIC;
      tx_ack                   : IN STD_LOGIC;
      tx_data                  : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      tx_desc                  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_dfr                   : OUT STD_LOGIC;
      tx_dv                    : OUT STD_LOGIC;
      tx_req                   : OUT STD_LOGIC;
      tx_busy                  : OUT STD_LOGIC;
      tx_ready                 : OUT STD_LOGIC;
      tx_sel                   : IN STD_LOGIC;
      mem_rd_data_valid        : IN STD_LOGIC;
      mem_rd_addr              : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      mem_rd_data              : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      mem_wr_addr              : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      mem_wr_data              : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      sel_epmem                : OUT STD_LOGIC;
      mem_wr_be                : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0)
   );
END altpcierd_rc_slave;

ARCHITECTURE trans OF altpcierd_rc_slave IS
   FUNCTION to_stdlogic (                        
   val      : IN integer) RETURN std_logic IS    
   BEGIN                                         
      IF (val=1) THEN                            
         RETURN('1');                            
      ELSE                                       
         RETURN('0');                            
      END IF;                                    
   END to_stdlogic;                              
   FUNCTION to_stdlogic (                        
   val      : IN boolean) RETURN std_logic IS    
   BEGIN                                         
      IF (val) THEN                              
         RETURN('1');                            
      ELSE                                       
         RETURN('0');                            
      END IF;                                    
   END to_stdlogic;                              
                                                
                                              
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

   COMPONENT altpcierd_reg_access IS
      PORT (
         clk_in                   : IN STD_LOGIC;
         rstn                     : IN STD_LOGIC;
         sel_ep_reg               : IN STD_LOGIC;
         reg_wr_ena               : IN STD_LOGIC;
         reg_rd_ena               : IN STD_LOGIC;
         reg_rd_addr              : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         reg_wr_addr              : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         reg_wr_data              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         dma_rd_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         dma_wr_prg_rddata        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         rx_ecrc_bad_cnt          : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
         read_dma_status          : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         write_dma_status         : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
         reg_rd_data              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         reg_rd_data_valid        : OUT STD_LOGIC;
         dma_prg_wrdata           : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         dma_prg_addr             : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         dma_rd_prg_wrena         : OUT STD_LOGIC;
         dma_wr_prg_wrena         : OUT STD_LOGIC
      );
   END COMPONENT;
   
   COMPONENT altpcierd_rxtx_downstream_intf IS
      GENERIC (
         avalon_st_128            : INTEGER := 1;
         avalon_wdata             : INTEGER := 128;
         avalon_be_width          : INTEGER := 16;
         mem_addr_width           : INTEGER := 12
      );
      PORT (
      clk_in                   : IN STD_LOGIC;
      rstn                     : IN STD_LOGIC;
      cfg_busdev               : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
      rx_req                   : IN STD_LOGIC;
      rx_desc                  : IN STD_LOGIC_VECTOR(135 DOWNTO 0);
      rx_data                  : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      rx_be                    : IN STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
      rx_dv                    : IN STD_LOGIC;
      rx_dfr                   : IN STD_LOGIC;
      rx_ack                   : OUT STD_LOGIC;
      rx_ws                    : OUT STD_LOGIC;
      tx_ws                    : IN STD_LOGIC;
      tx_ack                   : IN STD_LOGIC;
      tx_sel                   : IN STD_LOGIC;
      tx_desc                  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      tx_data                  : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      tx_dfr                   : OUT STD_LOGIC;
      tx_dv                    : OUT STD_LOGIC;
      tx_req                   : OUT STD_LOGIC;
      tx_ready                 : OUT STD_LOGIC;
      tx_busy                  : OUT STD_LOGIC;
      sel_epmem                : OUT STD_LOGIC;
      sel_ctl_sts              : OUT STD_LOGIC;
      mem_rd_data_valid        : IN STD_LOGIC;
      mem_rd_addr              : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      mem_rd_data              : IN STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      mem_rd_ena               : OUT STD_LOGIC;
      mem_wr_ena               : OUT STD_LOGIC;
      mem_wr_addr              : OUT STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
      mem_wr_data              : OUT STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
      mem_wr_be                : OUT STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
      reg_rd_data              : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      reg_rd_data_valid        : IN STD_LOGIC;
      reg_wr_addr              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_rd_addr              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      reg_wr_data              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
   END COMPONENT;
   
   SIGNAL sel_ep_reg             : STD_LOGIC;
   SIGNAL reg_rd_data            : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL reg_rd_data_valid      : STD_LOGIC;
   SIGNAL reg_rd_addr            : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL reg_wr_addr            : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL reg_wr_data            : STD_LOGIC_VECTOR(31 DOWNTO 0);
   
   -- Declare intermediate signals for referenced outputs
   SIGNAL dma_prg_addr_xhdl0     : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL dma_prg_wrdata_xhdl1   : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL dma_wr_prg_wrena_xhdl3 : STD_LOGIC;
   SIGNAL dma_rd_prg_wrena_xhdl2 : STD_LOGIC;
   SIGNAL mem_wr_ena_xhdl9       : STD_LOGIC;
   SIGNAL mem_rd_ena_xhdl5       : STD_LOGIC;
   SIGNAL rx_ack_xhdl10          : STD_LOGIC;
   SIGNAL rx_ws_xhdl11           : STD_LOGIC;
   SIGNAL tx_data_xhdl14         : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL tx_desc_xhdl15         : STD_LOGIC_VECTOR(127 DOWNTO 0);
   SIGNAL tx_dfr_xhdl16          : STD_LOGIC;
   SIGNAL tx_dv_xhdl17           : STD_LOGIC;
   SIGNAL tx_req_xhdl19          : STD_LOGIC;
   SIGNAL tx_busy_xhdl13         : STD_LOGIC;
   SIGNAL tx_ready_xhdl18        : STD_LOGIC;
   SIGNAL mem_rd_addr_xhdl4      : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL mem_wr_addr_xhdl6      : STD_LOGIC_VECTOR(AVALON_WADDR - 1 DOWNTO 0);
   SIGNAL mem_wr_data_xhdl8      : STD_LOGIC_VECTOR(AVALON_WDATA - 1 DOWNTO 0);
   SIGNAL sel_epmem_xhdl12       : STD_LOGIC;
   SIGNAL mem_wr_be_xhdl7        : STD_LOGIC_VECTOR(AVALON_BYTE_WIDTH - 1 DOWNTO 0);
BEGIN
   -- Drive referenced outputs
   dma_prg_addr <= dma_prg_addr_xhdl0;
   dma_prg_wrdata <= dma_prg_wrdata_xhdl1;
   dma_wr_prg_wrena <= dma_wr_prg_wrena_xhdl3;
   dma_rd_prg_wrena <= dma_rd_prg_wrena_xhdl2;
   mem_wr_ena <= mem_wr_ena_xhdl9;
   mem_rd_ena <= mem_rd_ena_xhdl5;
   rx_ack <= rx_ack_xhdl10;
   rx_ws <= rx_ws_xhdl11;
   tx_data <= tx_data_xhdl14;
   tx_desc <= tx_desc_xhdl15;
   tx_dfr <= tx_dfr_xhdl16;
   tx_dv <= tx_dv_xhdl17;
   tx_req <= tx_req_xhdl19;
   tx_busy <= tx_busy_xhdl13;
   tx_ready <= tx_ready_xhdl18;
   mem_rd_addr <= mem_rd_addr_xhdl4;
   mem_wr_addr <= mem_wr_addr_xhdl6;
   mem_wr_data <= mem_wr_data_xhdl8;
   sel_epmem <= sel_epmem_xhdl12;
   mem_wr_be <= mem_wr_be_xhdl7;
   
   
   
   altpcierd_rxtx_mem_intf : altpcierd_rxtx_downstream_intf
      GENERIC MAP (
         avalon_st_128    => AVALON_ST_128,
         avalon_wdata     => AVALON_WDATA,
         avalon_be_width  => AVALON_BYTE_WIDTH,
         mem_addr_width   => AVALON_WADDR
      )
      PORT MAP (
         clk_in             => clk_in,
         rstn               => rstn,
         cfg_busdev         => cfg_busdev,
         
         rx_req             => rx_req,
         rx_desc            => rx_desc,
         rx_data            => rx_data(AVALON_WDATA - 1 DOWNTO 0),
         rx_be              => rx_be(AVALON_BYTE_WIDTH - 1 DOWNTO 0),
         rx_dv              => rx_dv,
         rx_dfr             => rx_dfr,
         rx_ack             => rx_ack_xhdl10,
         rx_ws              => rx_ws_xhdl11,
         
         tx_ws              => tx_ws,
         tx_ack             => tx_ack,
         tx_desc            => tx_desc_xhdl15,
         tx_data            => tx_data_xhdl14(AVALON_WDATA - 1 DOWNTO 0),
         tx_dfr             => tx_dfr_xhdl16,
         tx_dv              => tx_dv_xhdl17,
         tx_req             => tx_req_xhdl19,
         tx_busy            => tx_busy_xhdl13,
         tx_ready           => tx_ready_xhdl18,
         tx_sel             => tx_sel,
         
         mem_rd_data_valid  => mem_rd_data_valid,
         mem_rd_addr        => mem_rd_addr_xhdl4,
         mem_rd_data        => mem_rd_data,
         mem_rd_ena         => mem_rd_ena_xhdl5,
         mem_wr_ena         => mem_wr_ena_xhdl9,
         mem_wr_addr        => mem_wr_addr_xhdl6,
         mem_wr_data        => mem_wr_data_xhdl8,
         mem_wr_be          => mem_wr_be_xhdl7,
         sel_epmem          => sel_epmem_xhdl12,
         
         sel_ctl_sts        => sel_ep_reg,
         reg_rd_data        => reg_rd_data,
         reg_rd_data_valid  => reg_rd_data_valid,
         reg_wr_addr        => reg_wr_addr,
         reg_rd_addr        => reg_rd_addr,
         reg_wr_data        => reg_wr_data
      );
   
   
   
   altpcierd_reg_access_1 : altpcierd_reg_access
      PORT MAP (
         clk_in             => clk_in,
         rstn               => rstn,
         dma_rd_prg_rddata  => dma_rd_prg_rddata,
         dma_wr_prg_rddata  => dma_wr_prg_rddata,
         dma_prg_wrdata     => dma_prg_wrdata_xhdl1,
         dma_prg_addr       => dma_prg_addr_xhdl0,
         dma_rd_prg_wrena   => dma_rd_prg_wrena_xhdl2,
         dma_wr_prg_wrena   => dma_wr_prg_wrena_xhdl3,
         
         sel_ep_reg         => sel_ep_reg,
         reg_rd_data        => reg_rd_data,
         reg_rd_data_valid  => reg_rd_data_valid,
         reg_wr_ena         => mem_wr_ena_xhdl9,
         reg_rd_ena         => mem_rd_ena_xhdl5,
         reg_rd_addr        => reg_rd_addr,
         reg_wr_addr        => reg_wr_addr,
         reg_wr_data        => reg_wr_data,
         
         rx_ecrc_bad_cnt    => rx_ecrc_bad_cnt,
         read_dma_status    => read_dma_status,
         write_dma_status   => write_dma_status
      );
   
END trans;




