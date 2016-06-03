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
entity pct_transfer is
  generic(fifo_wsize        : integer:=12;
          fifo_rsize        : integer:=14;
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
        pctin_data : in std_logic_vector(15 downto 0);
        pctin_fifo_wusedw : out std_logic_vector(fifo_wsize-1 downto 0);
        
        pctout_rdy : in std_logic;        
        --output ports 
        pctout_wr  : out std_logic;
        pctout_data: out std_logic_vector(15 downto 0)
        
        );
end pct_transfer;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pct_transfer is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0);

--fifo signals
signal f_aclr     : std_logic;
signal f_data, f_data_reg     : std_logic_vector(63 downto 0);
signal f_rdreq    : std_logic;
signal f_wrreq    : std_logic;
signal f_q        : std_logic_vector(15 downto 0);
signal f_rdempty  : std_logic;
signal f_rdusedw  : std_logic_vector(fifo_rsize-1 downto 0);
signal f_wrfull   : std_logic;
signal f_wrusedw  : std_logic_vector(fifo_wsize-1 downto 0);
signal f_word_cnt : unsigned(1 downto 0);

signal wr_cnt     : unsigned(15 downto 0);
signal indata_valid : std_logic;
signal pctin_data_r0, pctin_data_r1, pctin_data_r2, pctin_data_r3 : std_logic_vector(15 downto 0);
signal fifo_rdcnt : unsigned(15 downto 0);
signal wait_cnt   : unsigned(15 downto 0);

type state_type is (idle, capture_data, capture_data_inc, inc_cnt, wr_packet);
signal state : state_type;

type rdstate_type is (idle, rd, wait_next);
signal current_rdstate, next_rdstate : rdstate_type;



component pct_trnsf_fifo IS
	PORT
	(
		aclr		    : IN STD_LOGIC  := '0';
		data		    : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
		rdclk		   : IN STD_LOGIC ;
		rdreq		   : IN STD_LOGIC ;
		wrclk		   : IN STD_LOGIC ;
		wrreq		   : IN STD_LOGIC ;
		q		      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty		 : OUT STD_LOGIC ;
		rdusedw		 : OUT STD_LOGIC_VECTOR (fifo_rsize-1 downto 0);
		wrfull		  : OUT STD_LOGIC ;
		wrusedw		 : OUT STD_LOGIC_VECTOR (fifo_wsize-1 downto 0)
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
 	        if wr_cnt<pct_size/2-1 then 
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
-- pct in data registers to delay data
-- ----------------------------------------------------------------------------  
  process(wreset_n, wclk)
    begin
      if wreset_n='0' then
        pctin_data_r0<=(others=>'0');
        pctin_data_r1<=(others=>'0');
        pctin_data_r2<=(others=>'0');
        pctin_data_r3<=(others=>'0');
 	    elsif (wclk'event and wclk = '1') then
 	      if pctin_wr='1' then 
          pctin_data_r0<=pctin_data;
          pctin_data_r1<=pctin_data_r0;
          pctin_data_r2<=pctin_data_r1;
          pctin_data_r3<=pctin_data_r2;
        else
          pctin_data_r0<=pctin_data_r0;
          pctin_data_r1<=pctin_data_r1;
          pctin_data_r2<=pctin_data_r2;
          pctin_data_r3<=pctin_data_r3;
        end if; 
 	    end if;
    end process;
    
 -- ----------------------------------------------------------------------------
-- pct in data registers to delay data
-- ----------------------------------------------------------------------------  
  process(wreset_n, wclk)
    begin
      if wreset_n='0' then
        f_data_reg<=(others=>'0');
        f_data<=(others=>'0');
        state<=idle;
 	    elsif (wclk'event and wclk = '1') then
 	      f_data<=pctin_data_r0 & pctin_data_r1 & pctin_data_r2 & pctin_data_r3;
 	      
        case state is 
          
          when idle =>
            f_data_reg<=(others=>'0');
            if f_word_cnt=3 and  wr_cnt=7 and pctin_wr='1' then 
               state<=capture_data_inc;
            elsif f_word_cnt=3  and pctin_wr='1' then 
              state<=capture_data;
            else
               state<=idle;
            end if;
            
          when capture_data_inc=>
            state<=inc_cnt;
            f_data_reg<=(others=>'0');
            
          when inc_cnt=>
            f_data_reg<=std_logic_vector(unsigned(f_data)+900);
            state<=wr_packet; 
               
          when capture_data=>
            f_data_reg<=pctin_data_r0 & pctin_data_r1 & pctin_data_r2 & pctin_data_r3;
            state<=wr_packet;
            
          when wr_packet=>  
            state<=idle;
            f_data_reg<=f_data_reg;     
        end case;
 	    end if;
    end process;
    
   f_wrreq<='1' when state=wr_packet else '0';
   
   
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
		  if fifo_rdcnt<trnsf_size/2-1 then 
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
		  if wait_cnt<delay_rd/2-1 then 
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
        if pctout_rdy='1' and unsigned(f_rdusedw)>=trnsf_size/2 then 
          next_rdstate<=rd;
        else
           next_rdstate<=idle;
        end if;

    when rd =>
      if fifo_rdcnt=trnsf_size/2-1 then 
        next_rdstate<=wait_next;
      else
        next_rdstate<=rd;
      end if;
      
    when wait_next=>
        if wait_cnt<delay_rd/2-1 then 
          next_rdstate<=wait_next;
        else 
          next_rdstate<=idle;
        end if;

    when others =>
  end case;
end process;  


f_rdreq<='1' when  current_rdstate=rd else '0'; 
    
           
    
    
 
    
 --fifo instantiation       
 fifo_inst  : pct_trnsf_fifo   
    	port map
	(
		aclr		    => f_aclr,
		data		    => f_data_reg, 
		rdclk		   => rclk,
		rdreq		   => f_rdreq,
		wrclk		   => wclk,
		wrreq		   => f_wrreq,
		q		      => f_q, 
		rdempty		 => open, --f_rdempty, 
		rdusedw		 => f_rdusedw, 
		wrfull		  => open, --f_wrfull,
		wrusedw		 => f_wrusedw
	);
	
	pctin_fifo_wusedw<=f_wrusedw;
	pctout_data<=f_q;
  
end arch;   




