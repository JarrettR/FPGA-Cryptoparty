library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sha1_chunk_prep is
	port(
		clk        : in  std_logic;
		rst        : in  std_logic;  -- asynchronous reset
		load       : in  std_logic;
		cont  		: in std_logic;
		last_word  : in  std_logic;  
		last_bytes : in  std_logic_vector(1 downto 0);  -- number of bytes that need to be loaded
		ack        : out std_logic;
		din        : in  std_logic_vector(31 downto 0) := (others => '0');  -- input message
		dout       : out std_logic_vector(31 downto 0);                     -- output message
		ready      : out std_logic
	);
end entity sha1_chunk_prep;

architecture sha1_chunk_prep_arch of sha1_chunk_prep is
	-- types
	type state_type is (C_IDLE, C_SEND_WORD, C_EXTEND_WORD, C_ZERO_FILL, C_SIZE_FILL);

	-- signals
	signal size       : std_logic_vector(63 downto 0) := (others => '0');
	signal load_q     : std_logic := '0';
	signal load_pulse : std_logic := '0';
	signal state      : state_type := C_IDLE;
	signal i          : natural := 0;  -- counts the number of preprocessing steps
	signal bits       : natural := 0;  -- counts the number of bits received
begin
	-- combinatorial
	load_pulse <= load and (not load_q);

	-- preprocessing process : loads the input message as 
	-- long as load_pulse reaches 1 then appends the bit '1' 
	-- to the chunk
	-- a bit counter is used to produce the 2 final words of 
	-- the chunk
	sha1_chunk_prep_process : process(clk, rst)
	begin
		if rst = '0' then
			dout    <= (others => '0');
			ready   <= '1';
			ack     <= '0';
			i       <= 0;
			bits    <= 0;
		elsif rising_edge(clk) then
			-- we want ack to be a pulse
			ack   <= '0';
			
			-- pulse detector delay : we need it because 
			-- we don't want the preprocessing to end up 
			-- too early if the load signal lasts more 
			-- than one clock cycle
			load_q <= load;
			
			case state is
			when C_IDLE =>
				i       <= 0;
				bits    <= 0;
				ready   <= '1';
				if load_pulse = '1' then 
					if last_word = '0' then 
						dout  <= din;
						ack   <= '1';
						bits  <= bits + 32;
						state <= C_SEND_WORD;
					else
						case last_bytes is 
						when "01" =>  -- 1 byte to load
							dout <= din(7 downto 0) & "100000000000000000000000";
							bits <= bits + 8;
						when "10" =>  -- 2 bytes to load
							dout <= din(15 downto 0) & "1000000000000000";
							bits <= bits + 16;
						when "11" =>  -- 3 bytes to load
							dout <= din(23 downto 0) & "10000000";
							bits <= bits + 24;
						when others => 
							-- empty message
							dout <= X"80000000";
						end case;
						ack   <= '1';
						state <= C_ZERO_FILL;
					end if;
					ready <= '0';
				else
					state <= C_IDLE;
				end if;
			when C_SEND_WORD =>
				ready <= '0';
				if load_pulse = '1' then 
					if last_word = '0' then 
						--if 0 <= i and i < 13 then 
							dout <= din;
							bits <= bits + 32;
						--end if;
						state <= C_SEND_WORD;
					else
						case last_bytes is 
						when "01" =>  -- 1 byte to load
							dout  <= din(7 downto 0) & "100000000000000000000000";
							bits  <= bits + 8;
							state <= C_ZERO_FILL;
						when "10" =>  -- 2 bytes to load
							dout  <= din(15 downto 0) & "1000000000000000";
							bits  <= bits + 16;
							state <= C_ZERO_FILL;
						when "11" =>  -- 3 bytes to load
							dout  <= din(23 downto 0) & "10000000";
							bits  <= bits + 24;
							state <= C_ZERO_FILL;
						when others =>
							dout  <= din;
							bits  <= bits + 32;
							state <= C_EXTEND_WORD;
						end case;

					end if;
					i   <= i + 1;
					ack <= '1';
				else
					state <= C_SEND_WORD;
				end if;
			when C_EXTEND_WORD =>
				ready <= '0';
				-- special case : last_word signal  
				-- detected and no bytes to be loaded
				if load_pulse = '1' then 
					dout  <= X"80000000";
					state <= C_ZERO_FILL;
					i     <= i + 1;
					ack   <= '1';
				else
					state <= C_EXTEND_WORD;
				end if;
			when C_ZERO_FILL =>
				ready <= '0';
				if load_pulse = '1' then 
					if 0 <= i and i < 13 then 
						dout  <= (others => '0');
						i     <= i + 1;
						state <= C_ZERO_FILL;
					elsif cont = '1' and i < 29 then
						dout  <= (others => '0');
						i     <= i + 1;
						state <= C_ZERO_FILL;
					else
						size  <= std_logic_vector(to_unsigned(bits, 64));
						dout  <= size(63 downto 32); 
						i     <= i + 1;
						state <= C_SIZE_FILL;
					end if;
					ack <= '1';
				end if;
			when C_SIZE_FILL =>
				ready <= '0';
				if load_pulse = '1' then 
					if i = 14 and cont = '0' then 
						-- here we generate 2 words for the complete 
						-- message size (number of bits received)
						dout  <= size(31 downto 0);
						state <= C_SIZE_FILL;
						ack   <= '1';
						i     <= i + 1;
					elsif i = 15 and cont = '0' then 
						-- last word : go idle
						dout  <= size(31 downto 0);
						ack   <= '1';
						state <= C_IDLE;
						ready <= '1';
						i     <= 0;
					elsif i = 30 then 
						-- here we generate 2 words for the complete 
						-- message size (number of bits received)
						dout  <= size(31 downto 0);
						state <= C_SIZE_FILL;
						ack   <= '1';
						i     <= i + 1;
					elsif i = 31 then 
						-- last word : go idle
						dout  <= size(31 downto 0);
						ack   <= '1';
						state <= C_IDLE;
						ready <= '1';
						i     <= 0;
					else
						state <= C_IDLE;
					end if;
				end if;
			when others =>
				i    <= 0;
				bits <= 0;
			end case;
		end if;	
	end process sha1_chunk_prep_process;
	
end sha1_chunk_prep_arch;