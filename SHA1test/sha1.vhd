library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


--The base of this code is from
-- https://github.com/accpnt/sha1crack/blob/master/modules/u_sha1/
-- Will soon be replacing it with custom SHA1 stuff that does
-- exactly what I need with no wasted clocks or slices

entity sha1 is
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;  -- asynchronous reset
		start      : in  std_logic;
		load       : in  std_logic;
		last_word  : in  std_logic;
		last_bytes : in  std_logic_vector(1 downto 0);
		ack        : out std_logic;
		msg        : in  std_logic_vector( 31 downto 0);
		hash       : out std_logic_vector(159 downto 0);
		ready      : out std_logic
	);
end entity sha1;

-- iterative
architecture sha1_arch of sha1 is
	-- components
	component sha1_chunk_prep is
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;  -- asynchronous reset
			load       : in  std_logic;
			last_word  : in  std_logic;
			last_bytes : in  std_logic_vector(1 downto 0);
			ack        : out std_logic;
			din        : in  std_logic_vector(31 downto 0) := (others => '0');  -- input message
			dout       : out std_logic_vector(31 downto 0);                         -- output message
			ready      : out std_logic
		);
	end component sha1_chunk_prep;
	
	component sha1_chunk is
		port(
			clk   : in  std_logic;
			rst   : in  std_logic;  -- asynchronous reset
			h     : in std_logic_vector(159 downto 0);	--For multiple blocks
			cont  : in std_logic;
			load  : in  std_logic;
			ack   : out std_logic;
			msg   : in  std_logic_vector( 31 downto 0);
			hash  : out std_logic_vector(159 downto 0);
			ready : out std_logic
		);
	end component sha1_chunk;
	
	-- constants

	-- types
	type state_type is (C_IDLE, C_PREPROCESS_MSG, C_PROCESS_WORD, C_WAIT_FOR_HASH);
	
	-- signals
	signal load_prep   : std_logic := '0';
	signal ack_prep    : std_logic := '0';
	signal ready_prep  : std_logic := '0';
	signal msg_prep    : std_logic_vector(31 downto 0) := (others => '0');
	signal load_chunk  : std_logic := '0';
	signal ack_chunk   : std_logic := '0';
	signal ready_chunk : std_logic := '0';
	signal state       : state_type := C_IDLE;
	
	signal h     : std_logic_vector(159 downto 0);
	signal hashin     : std_logic_vector(159 downto 0);
	signal cont  : std_logic := '0';
	
begin

	sha1_chunk_prep_object : sha1_chunk_prep
		port map(
			clk        => clk,
			rst        => rst,
			load       => load_prep,
			last_word  => last_word,
			last_bytes => last_bytes,
			ack        => ack_prep,
			din        => msg,
			dout       => msg_prep,
			ready      => ready_prep
		);
		
	sha1_chunk_object : sha1_chunk
		port map(
			clk   => clk,
			rst   => rst,
			h   => h,
			cont   => cont,
			load  => load_chunk,
			ack   => ack_chunk,
			msg   => msg_prep,
			hash  => hashin,
			ready => ready_chunk
		);

	-- combinatorial
	ack <= ack_chunk;
	hash <= hashin; 
		
	sha1_process : process(clk, rst)
	begin
		if rst = '0' then
			ready <= '1';
		elsif rising_edge(clk) then
			load_prep <= load;  -- not combinatorial
			h <= hashin; 

			case state is
			when C_IDLE =>
				ready <= '1';
				if start = '1' and ready_prep = '1' and ready_chunk = '1' then 
					state <= C_PREPROCESS_MSG;
					ready <= '0';
				else 
					state <= C_IDLE;
				end if;
			when C_PREPROCESS_MSG => 
				ready <= '0';
				load_chunk <= '0';
				if ack_prep = '1' and ready_prep = '0' then 
					load_chunk <= '1';
					state <= C_PROCESS_WORD;
				elsif ack_prep = '1' and ready_prep = '1' then 
					state <= C_WAIT_FOR_HASH;
				else
					state <= C_PREPROCESS_MSG;
				end if;
			when C_PROCESS_WORD =>
				ready <= '0';
				load_chunk <= '0';
				if ack_chunk = '1' then 
					load_chunk <= '0';
					if ready_prep = '0' then 
						-- preprocessing is not over
						state <= C_PREPROCESS_MSG;
					else
						state <= C_WAIT_FOR_HASH;
					end if;
				end if;
				
				-- if last_word is high we won't receive pulses
				-- from the input, so we need to emulate the 
				-- load pulse 
				if last_word = '1' and ack_chunk = '1' then 
					load_prep <= '1';
				end if;
			when C_WAIT_FOR_HASH =>
				ready <= '0';
				load_chunk <= '0';
				if ready_chunk = '1' then 
					-- preprocessing is over 
					state <= C_IDLE;
					ready <= '1';
					load_chunk <= '0';
				else
					state <= C_WAIT_FOR_HASH;
				end if;
			when others =>  
			end case;
		end if;
	end process sha1_process;
end sha1_arch;