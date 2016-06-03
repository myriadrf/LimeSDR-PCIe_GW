-- ----------------------------------------------------------------------------	
-- FILE: 	pct_transfer.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pct_transfer_v2 is
  generic(fifo_wsize        : integer:=12;
          fifo_rsize        : integer:=13;
          pct_size          : integer:=4096;
          trnsf_size        : integer:=4096;
          delay_rd          : integer:=4096);
  port (
        --input ports 
        wclk       : in std_logic;
        wreset_n   : in std_logic;
        rclk       : in std_logic;        
        rreset_n   : in std_logic;
        
        pctin_wr   : in std_logic;
        pctin_data : in std_logic_vector(63 downto 0);
        pctin_fifo_wusedw : out std_logic_vector(fifo_wsize-1 downto 0);
        
        pctout_rdy : in std_logic;        
        --output ports 
        pctout_wr  : out std_logic;
        pctout_data: out std_logic_vector(31 downto 0)
        
        );
end pct_transfer_v2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pct_transfer_v2 is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0);

--fifo signals
signal f_aclr     : std_logic;
signal f_data		: std_logic_vector(63 downto 0);
signal f_rdreq    : std_logic;
signal f_wrreq    : std_logic;
signal f_q        : std_logic_vector(31 downto 0);
signal f_rdempty  : std_logic;
signal f_rdusedw  : std_logic_vector(fifo_rsize-1 downto 0);
signal f_wrfull   : std_logic;
signal f_wrusedw  : std_logic_vector(fifo_wsize-1 downto 0);
signal f_word_cnt : unsigned(1 downto 0);

signal wr_cnt     	: unsigned(15 downto 0);
signal indata_valid 	: std_logic;
signal pctin_data_r0, pctin_data_r1, pctin_data_r2, pctin_data_r3 : std_logic_vector(15 downto 0);
signal fifo_rdcnt 	: unsigned(15 downto 0);
signal wait_cnt   	: unsigned(15 downto 0);

type state_type is (idle, capture_data, capture_data_inc, inc_cnt, wr_packet);
signal state : state_type;

type rdstate_type is (idle, rd, wait_next);
signal current_rdstate, next_rdstate : rdstate_type;

signal pctin_data_u	: unsigned (63 downto 0);


component fpga_outfifo IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (fifo_rsize-1 DOWNTO 0);
		wrfull	: OUT STD_LOGIC ;
		wrusedw	: OUT STD_LOGIC_VECTOR (fifo_wsize-1 DOWNTO 0)
	);
END component;

  
begin
  
  f_aclr<= not wreset_n;
  
-- ----------------------------------------------------------------------------
-- PCT wr cnt
-- ----------------------------------------------------------------------------  
  process(wreset_n, wclk)
    begin
      if wreset_n='0' then
        wr_cnt<=(others=>'0');  
 	    elsif (wclk'event and wclk = '1') then
 	      if pctin_wr='1' then 
 	        if wr_cnt<pct_size/8-1 then 
 	          wr_cnt<=wr_cnt+1;
 	        else 
 	          wr_cnt<=(others=>'0');
 	        end if;
 	      else
 	        wr_cnt<=wr_cnt;
 	      end if;     
 	    end if;
    end process;
-- ----------------------------------------------------------------------------
-- fifo word cnt
-- ----------------------------------------------------------------------------  
  process(wreset_n, wclk)
    begin
      if wreset_n='0' then
        f_word_cnt<=(others=>'0');
 	    elsif (wclk'event and wclk = '1') then
 	      if pctin_wr='1' then 
            f_word_cnt<=f_word_cnt+1;
 	      else
 	        f_word_cnt<=f_word_cnt;
 	      end if;     
 	    end if;
    end process; 
    
-- ----------------------------------------------------------------------------
-- to incremment counter in packets
-- ----------------------------------------------------------------------------  
  process(wreset_n, wclk)
    begin
      if wreset_n='0' then
			f_wrreq<='0';
			pctin_data_u<=(others=>'0');
 	    elsif (wclk'event and wclk = '1') then 			f_wrreq<=pctin_wr;
			if wr_cnt=1 then 
				pctin_data_u<=unsigned(pctin_data)+1800; --packet delay depends on frequency 
			else 
				pctin_data_u<=unsigned(pctin_data);
			end if;				
 	    end if;
    end process;
    
   
   
-------------------------------------------------------------------------------
--fifo rd cnt
-------------------------------------------------------------------------------
process(rclk, rreset_n) begin
	if(rreset_n = '0')then
		fifo_rdcnt<=(others=>'0');
		pctout_wr<='0';
	elsif(rclk'event and rclk = '1')then
	   pctout_wr<=f_rdreq;
		if current_rdstate=rd then
		  if fifo_rdcnt<trnsf_size/4-1 then 
		   fifo_rdcnt<=fifo_rdcnt+1;
		  else
		   fifo_rdcnt<=(others=>'0');
		  end if;
		else 
		  fifo_rdcnt<=fifo_rdcnt;
		end if;
	end if;	
end process; 



-------------------------------------------------------------------------------
--wait_cnt
-------------------------------------------------------------------------------
process(rclk, rreset_n) begin
	if(rreset_n = '0')then
		wait_cnt<=(others=>'0');
	elsif(rclk'event and rclk = '1')then
		if current_rdstate=wait_next then
		  if wait_cnt<delay_rd/4-1 then 
		   wait_cnt<=wait_cnt+1;
		  else
		   wait_cnt<=(others=>'0');
		  end if;
		else 
		  wait_cnt<=wait_cnt;
		end if;
	end if;	
end process;
   
    
   
   
-------------------------------------------------------------------------------
--main packet formation state machine
-------------------------------------------------------------------------------
fsm_f : process(rclk, rreset_n) begin
	if(rreset_n = '0')then
		current_rdstate <= idle;
	elsif(rclk'event and rclk = '1')then 
		current_rdstate <= next_rdstate;
	end if;	
end process;

-------------------------------------------------------------------------------
--main state machine combo
-------------------------------------------------------------------------------
fsm : process(current_rdstate, f_rdusedw, pctout_rdy, fifo_rdcnt, wait_cnt) begin
  next_rdstate <= current_rdstate;

  case current_rdstate is    
    when idle =>
        if pctout_rdy='1' and unsigned(f_rdusedw)>=trnsf_size/4 then 
          next_rdstate<=rd;
        else
           next_rdstate<=idle;
        end if;

    when rd =>
      if fifo_rdcnt=trnsf_size/4-1 then 
        next_rdstate<=wait_next;
      else
        next_rdstate<=rd;
      end if;
      
    when wait_next=>
        if wait_cnt<delay_rd/4-1 then 
          next_rdstate<=wait_next;
        else 
          next_rdstate<=idle;
        end if;

    when others =>
  end case;
end process;  

    
 process(current_rdstate) begin
	if (current_rdstate=rd) then
			f_rdreq <= '1'; 
	else
		  f_rdreq<='0';
	end if;	
end process;          
    
    
f_data<=std_logic_vector(pctin_data_u);
    
 --fifo instantiation       
 fifo_inst  : fpga_outfifo   
    	port map
	(
		aclr		=> f_aclr,
		data		=> f_data, 
		rdclk		=> rclk,
		rdreq		=> f_rdreq,
		wrclk		=> wclk,
		wrreq		=> f_wrreq,
		q		   => f_q, 
		rdempty	=> open, --f_rdempty, 
		rdusedw	=> f_rdusedw,
		wrfull	=> open, --f_wrfull,
		wrusedw	=> f_wrusedw
	);
	
	pctin_fifo_wusedw<=f_wrusedw;
	pctout_data<=f_q;
  
end arch;   




