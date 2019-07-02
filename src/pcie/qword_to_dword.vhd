-- ----------------------------------------------------------------------------
-- FILE:          qword_to_dword.vhd
-- DESCRIPTION:   Realigns QWORD aligned PCIe TLP packets to DWORD alligned
-- DATE:          04:36 PM Monday, May 27, 2019
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity qword_to_dword is
	port (
		av_st_sink_data            : in  std_logic_vector(63 downto 0) := (others => '0'); --   av_st_sink.data
		av_st_sink_endofpacket     : in  std_logic                     := '0';             --             .endofpacket
		av_st_sink_startofpacket   : in  std_logic                     := '0';             --             .startofpacket
		av_st_sink_ready           : out std_logic;                                        --             .ready
		av_st_sink_valid           : in  std_logic                     := '0';             --             .valid
		av_st_sink_error           : in  std_logic                     := '0';             --             .error
		av_st_source_data          : out std_logic_vector(63 downto 0);                    -- av_st_source.data
		av_st_source_endofpacket   : out std_logic;                                        --             .endofpacket
		av_st_source_startofpacket : out std_logic;                                        --             .startofpacket
		av_st_source_error         : out std_logic;                                        --             .error
		av_st_source_ready         : in  std_logic                     := '0';             --             .ready
		av_st_source_valid         : out std_logic;                                        --             .valid
		clock_sink_clk             : in  std_logic                     := '0';             --   clock_sink.clk
		reset_sink_reset           : in  std_logic                     := '0';             --   reset_sink.reset
		clock_source_clk           : out std_logic;                                        -- clock_source.clk
		reset_source_reset_req     : out std_logic                                         -- reset_source.reset_req
	);
end entity qword_to_dword;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture rtl of qword_to_dword is
   constant C_INST0_WRWIDTH         : integer := 66;
   constant C_INST0_WRUSEDW_WITDTH  : integer := 8;
   constant C_INST0_RDWIDTH         : integer := 66;
   constant C_INST0_RDUSEDW_WIDTH   : integer := 8;
   
   --isnt0
   signal inst0_wrusedw    : std_logic_vector(C_INST0_WRUSEDW_WITDTH-1 downto 0);
   signal inst0_rdreq      : std_logic;
   signal inst0_q          : std_logic_vector(C_INST0_RDWIDTH-1 downto 0);
   signal inst0_q_reg      : std_logic_vector(C_INST0_RDWIDTH-1 downto 0);
   signal inst0_rdempty    : std_logic;
   signal inst0_rdusedw    : std_logic_vector(C_INST0_RDUSEDW_WIDTH-1 downto 0);
   signal inst0_q_valid    : std_logic;
   
   signal rdy_to_read      : std_logic;
   
   signal tlp_fmt          : std_logic_vector(2 downto 0);
   signal tlp_type         : std_logic_vector(4 downto 0);
   
   alias tlp_buf_data      : std_logic_vector(63 downto 0) is inst0_q(64 downto 1);
   alias tlp_buf_sop       : std_logic is inst0_q(inst0_q'left);
   alias tlp_buf_eop       : std_logic is inst0_q(inst0_q'right);
   
   signal tlp_buf_data_reg : std_logic_vector(63 downto 0);
   
   type state_type is ( idle, rd_first_word, first_word, second_word, wait_first_payload_w, 
                        rd_first_payload_w, first_payload_w, rd_payload, payload_words, 
                        wait_payload, wait_second_word, rd_second_word, non_qword_rd, 
                        non_qword, wait_non_qword_rd, eof);
   
   signal current_state, next_state : state_type;
   
begin
   
----------------------------------------------------------------------------
--FIFO buffer for temporary storing TLP packets
----------------------------------------------------------------------------
   -- FIFO data word is combined with startofpacket and endofpacket signals
   fifo_inst0 : entity work.fifo_inst
   generic map (
      dev_family     => "Cyclone V",
      wrwidth        => C_INST0_WRWIDTH,
      wrusedw_witdth => C_INST0_WRUSEDW_WITDTH, -- 8 = 256 words
      rdwidth        => C_INST0_RDWIDTH,
      rdusedw_width  => C_INST0_RDUSEDW_WIDTH,
      show_ahead     => "OFF"
   ) 
   port map(
      reset_n       => reset_sink_reset,
      wrclk         => clock_sink_clk,
      wrreq         => av_st_sink_valid,
      data          => av_st_sink_startofpacket & av_st_sink_data & av_st_sink_endofpacket,
      wrfull        => open,
      wrempty		  => open,
      wrusedw       => inst0_wrusedw,
      rdclk 	     => clock_sink_clk,
      rdreq         => inst0_rdreq,
      q             => inst0_q,
      rdempty       => inst0_rdempty,
      rdusedw       => inst0_rdusedw 
   );
   
   -- FIFO read request signal controled from FSM 
   process(current_state, rdy_to_read, tlp_buf_eop)
   begin
      if current_state = rd_first_word OR current_state = non_qword_rd OR 
         current_state = rd_first_payload_w OR current_state = rd_payload OR 
         current_state = rd_second_word then 
         inst0_rdreq <= '1';
      elsif rdy_to_read = '1' then
         if (current_state = non_qword OR current_state = payload_words) AND tlp_buf_eop = '0' then 
            inst0_rdreq <= '1';
         elsif current_state = first_word OR current_state = second_word or current_state = second_word OR current_state = first_payload_w then 
            inst0_rdreq <= '1';
         else
            inst0_rdreq <= '0';
         end if;
      else
         inst0_rdreq <= '0';
      end if;
   end process;
   
   -- Aditional FIFO output register stage for realigning payload
   process(clock_sink_clk, reset_sink_reset)
   begin
      if reset_sink_reset = '0' then 
         tlp_buf_data_reg    <= (others=>'0');
         inst0_q_valid  <= '0';
      elsif (clock_sink_clk'event AND clock_sink_clk='1') then 
         if inst0_q_valid = '1' then 
            tlp_buf_data_reg <= tlp_buf_data;
         end if;
         inst0_q_valid <= inst0_rdreq;
      end if;
   end process;
   
 
----------------------------------------------------------------------------
-- TLP fields
----------------------------------------------------------------------------
   tlp_fmt  <= tlp_buf_data(31 downto 29);
   tlp_type <= tlp_buf_data(28 downto 24);

----------------------------------------------------------------------------
-- State machine
----------------------------------------------------------------------------
   fsm_f : process(clock_sink_clk, reset_sink_reset)begin
      if(reset_sink_reset = '0')then
         current_state <= idle;
      elsif(clock_sink_clk'event and clock_sink_clk = '1')then 
         current_state <= next_state;
      end if;	
   end process;

----------------------------------------------------------------------------
--state machine combo
----------------------------------------------------------------------------
   fsm : process(current_state, av_st_sink_startofpacket, inst0_rdusedw, tlp_buf_sop, 
                  tlp_buf_eop, rdy_to_read, tlp_fmt, tlp_type, av_st_source_ready) begin
      next_state <= current_state;
      case current_state is
   
         when idle => --idle state
            if rdy_to_read = '1' then 
               next_state <= rd_first_word;
            else 
               next_state <= idle;
            end if;
         
         when rd_first_word =>
            next_state <= first_word;
   
         when first_word =>
            if rdy_to_read = '1' then 
               -- Checking if this is start of packet 
               if tlp_buf_sop = '1' then
                  if tlp_fmt = "010" AND tlp_type = "01010"  then -- "Completion with data" TLP 
                     next_state <= second_word;
                  else 
                     next_state <= non_qword;
                  end if;
               else 
                  next_state <= idle;
               end if;
            else
               if tlp_fmt = "010" AND tlp_type = "01010"  then
                  next_state <= wait_second_word;
               else 
                  next_state <= wait_non_qword_rd;
               end if;
            end if;
                    
         when wait_non_qword_rd =>
            if rdy_to_read = '1' then 
               next_state <= non_qword_rd;
            else 
               next_state <= wait_non_qword_rd;
            end if;            

         when non_qword_rd => 
            next_state <= non_qword;
            
         when non_qword => 
            if tlp_buf_eop = '1' then
               next_state <= idle;
            else 
               if rdy_to_read = '1' then 
                  next_state <= non_qword;
               else 
                  next_state <= wait_non_qword_rd;
               end if;
            end if;   
            
            
            
            
            
         when wait_second_word => 
            if rdy_to_read = '1' then 
               next_state <= rd_second_word;
            else 
               next_state <= wait_second_word;
            end if;
            
         when rd_second_word => 
            next_state <= second_word;
      
         when second_word =>
            if tlp_buf_eop = '1' then
               if rdy_to_read = '1' then 
                  next_state <= first_word;
               else 
                  next_state <= idle;
               end if;
            else
               if rdy_to_read = '1' then 
                  next_state <= first_payload_w;
               else 
                  next_state <= wait_first_payload_w;
               end if;
            end if;
         
         when wait_first_payload_w => 
               if rdy_to_read = '1' then 
                  next_state <= rd_first_payload_w;
               else 
                  next_state <= wait_first_payload_w;
               end if;
            
         when rd_first_payload_w =>
            next_state <= first_payload_w;
            
         when first_payload_w => 
            if tlp_buf_eop = '1' then
               next_state <= eof;
            else 
               if rdy_to_read = '1' then 
                  next_state <= payload_words;
               else 
               next_state <= wait_payload;
               end if;
            end if;
            
         when rd_payload => 
            next_state <= payload_words;
      
         when payload_words => 
            if rdy_to_read = '1' then
               if tlp_buf_eop = '0' then
                  next_state <= payload_words;
               else 
                  next_state <= eof;
               end if;
            else 
               next_state <= wait_payload;
            end if;
            
         when wait_payload => 
            if tlp_buf_eop = '1' then            
               if av_st_source_ready = '1' then
                  next_state <= eof;
               else 
                  next_state <= wait_payload;
               end if;
            else 
               if rdy_to_read = '1' then 
                  next_state <= rd_payload;
               else 
                  next_state <= wait_payload;
               end if;
            end if;

         when eof => 
            next_state <= idle;
                           
         when others => 
            next_state <= idle;
      end case;
   end process;
   
   
   rdy_to_read <= not inst0_rdempty AND av_st_source_ready;
   
----------------------------------------------------------------------------
-- Outputs 
----------------------------------------------------------------------------  
   
   -- ! Change constant value to calculated value!
   process(inst0_wrusedw)
   begin 
      if unsigned(inst0_wrusedw) > 64 then 
         av_st_sink_ready <= '0';
      else 
         av_st_sink_ready <= '1';
      end if;
   end process;
   
   process(current_state, tlp_buf_sop)
   begin 
      if current_state = first_word AND tlp_buf_sop = '1' then 
         av_st_source_startofpacket <= '1';
      else 
         av_st_source_startofpacket <= '0';
      end if;
   end process;
   
   process(current_state, tlp_buf_eop)
   begin 
      if current_state = non_qword AND tlp_buf_eop = '1' then 
         av_st_source_endofpacket <= '1';
      elsif current_state = eof then 
         av_st_source_endofpacket <= '1';
      else 
         av_st_source_endofpacket <= '0';
      end if;
   end process;
   
   process(current_state, tlp_buf_sop)
   begin 
      if current_state = first_word AND tlp_buf_sop = '1' then 
         av_st_source_valid <= '1';
      elsif current_state = non_qword OR current_state = first_payload_w OR 
            current_state = payload_words OR current_state = eof then 
         av_st_source_valid <= '1';
      else 
         av_st_source_valid <= '0';
      end if;
   end process;
   
   process(current_state, tlp_buf_data, tlp_buf_data_reg)
   begin
      if current_state = first_payload_w then 
         av_st_source_data <= tlp_buf_data(31 downto 0) & tlp_buf_data_reg(31 downto 0);
      elsif current_state = payload_words then 
         av_st_source_data <= tlp_buf_data(31 downto 0) & tlp_buf_data_reg(63 downto 32);
      elsif current_state = eof then 
         av_st_source_data <= x"00000000" & tlp_buf_data(63 downto 32);
      else 
         av_st_source_data <= tlp_buf_data;
      end if;
   end process;
   
   av_st_source_error <= av_st_sink_error;
     

end architecture rtl; -- of new_component
