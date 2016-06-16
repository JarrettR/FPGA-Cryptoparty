library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha1_chunk is
	port(
        clk                     : in    std_ulogic;
        reset_n                 : in    std_ulogic;
        stream_in_data          : in    std_ulogic_vector(31 downto 0);
		h     : in std_logic_vector(159 downto 0);
		load  : in  std_logic;
		ack   : out std_logic;
		msg   : in  std_logic_vector( 31 downto 0);
		hash  : out std_logic_vector(159 downto 0);
		ready : out std_logic
	);
end entity sha1_chunk;

-- iterative
architecture sha1_chunk_arch of sha1_chunk is
	-- components
	
	-- constants
	constant h0i : std_logic_vector(31 downto 0) := X"67452301";  -- H0 (a)
	constant h1i : std_logic_vector(31 downto 0) := X"EFCDAB89";  -- H1 (b)
	constant h2i : std_logic_vector(31 downto 0) := X"98BADCFE";  -- H2 (c)
	constant h3i : std_logic_vector(31 downto 0) := X"10325476";  -- H3 (d)
	constant h4i : std_logic_vector(31 downto 0) := X"C3D2E1F0";  -- H4 (e)
	
	constant k0 : std_logic_vector(31 downto 0) := X"5A827999";  -- round  0 .. 19
	constant k1 : std_logic_vector(31 downto 0) := X"6ED9EBA1";  -- round 20 .. 39
	constant k2 : std_logic_vector(31 downto 0) := X"8F1BBCDC";  -- round 40 .. 59
	constant k3 : std_logic_vector(31 downto 0) := X"CA62C1D6";  -- round 60 .. 79
	
	-- types
	type state_type is (C_IDLE, C_EXTEND_CHUNK, C_PROCESS_WORD, C_NEXT_ROUND);
	
	-- signals
	
--	signal h0i         : std_logic_vector(31 downto 0) := h(159 downto 128);
--	signal h1i         : std_logic_vector(31 downto 0) := h(127 downto 96);
--	signal h2i         : std_logic_vector(31 downto 0) := h(95 downto 64);
--	signal h3i         : std_logic_vector(31 downto 0) := h(63 downto 32);
--	signal h4i         : std_logic_vector(31 downto 0) := h(31 downto 0);
	signal h0         : std_logic_vector(31 downto 0) := h0i;
	signal h1         : std_logic_vector(31 downto 0) := h1i;
	signal h2         : std_logic_vector(31 downto 0) := h2i;
	signal h3         : std_logic_vector(31 downto 0) := h3i;
	signal h4         : std_logic_vector(31 downto 0) := h4i;
	
	signal round        : natural := 0;
	signal w_round      : std_logic_vector( 31 downto 0) := (others => '0');
	signal w_round_temp : std_logic_vector( 31 downto 0) := (others => '0');
	signal w            : std_logic_vector(511 downto 0) := (others => '0');
	signal hash_round   : std_logic_vector(159 downto 0) := h0 & h1 & h2 & h3 & h4;
	
	signal a         : std_logic_vector(31 downto 0) := (others => '0');
	signal b         : std_logic_vector(31 downto 0) := (others => '0');
	signal c         : std_logic_vector(31 downto 0) := (others => '0');
	signal d         : std_logic_vector(31 downto 0) := (others => '0');
	signal e         : std_logic_vector(31 downto 0) := (others => '0');
	signal a_rol     : std_logic_vector(31 downto 0) := (others => '0');
	signal f         : std_logic_vector(31 downto 0) := (others => '0');
	signal k         : std_logic_vector(31 downto 0) := (others => '0');
	signal t         : std_logic_vector(31 downto 0) := (others => '0');
	
	signal ready_extend   : std_logic := '0';
	signal ready_round    : std_logic := '0';
	signal ready_round_q1 : std_logic := '0';
	signal load_pulse     : std_logic := '0';
	signal load_q         : std_logic := '0';
	
	signal state : state_type := C_IDLE;
begin
	-- combinatorial
	-- w[i]  = (w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]) leftrotate 1
	w_round_temp <= w( 95 downto  64) xor w(255 downto 224) xor w(447 downto 416) xor w(511 downto 480);
	load_pulse   <= load and (not load_q);
	
	-- control process
	sha1_chunk_process : process(clk)
	begin
		if reset_n = '1' then
			h0 <= h(159 downto 128);
			h1 <= h(127 downto 96);
			h2 <= h(95 downto 64);
			h3 <= h(63 downto 32);
			h4 <= h(31 downto 0);
		else
			h0 <= h0i;
			h1 <= h1i;
			h2 <= h2i;
			h3 <= h3i;
			h4 <= h4i;
		end if;
		
		if rising_edge(clk) then
			-- pulse detector delay
			load_q <= load;
		
			-- state machine
			case state is
			when C_IDLE =>
				ready <= '1'; 
				ack <= '0';
				a <= h0; 
				b <= h1;
				c <= h2;
				d <= h3;
				e <= h4;
				if load_pulse = '1' then
					state <= C_PROCESS_WORD;
					round <= 0;
					ready <= '0';
					w_round <= stream_in_data;
					w(511 downto 0) <= w(479 downto   0) & stream_in_data;
				end if;
			when C_EXTEND_CHUNK =>  -- extend takes 1 clk to be processed
				ready <= '0';
				ack <= '0';
				if 0 <= round and round < 16 then
					if load_pulse = '1' then
						-- if we're still loading the message
						w_round <= stream_in_data;
						w(511 downto 0) <= w(479 downto   0) & stream_in_data;
						state <= C_PROCESS_WORD;
					else
						state <= C_EXTEND_CHUNK;
					end if;
				elsif 16 <= round and round <= 79 then
					-- message has been loaded
					w_round <= w_round_temp(30 downto 0) & w_round_temp(31);
					w(511 downto 0) <= w(479 downto   0) & w_round_temp(30 downto 0) & w_round_temp( 31);
					state <= C_PROCESS_WORD;
				end if;
			when C_PROCESS_WORD =>  -- round process takes 2 clk to be processed
				ack <= '0';
				if 0 <= round and round <= 19 then
					k <= k0;
					f <= (b and c) or ((not b) and d);  -- Ch
				elsif 20 <= round and round <= 39 then
					k <= k1;
					f <= b xor c xor d;  -- Parity
				elsif 40 <= round and round <= 59 then
					k <= k2;
					f <= (b and c) or (b and d) or (c and d);  -- Maj
				elsif 60 <= round and round <= 79 then
					k <= k3;
					f <= b xor c xor d;  -- Parity
				end if;
			
				a_rol <= a(26 downto 0) & a(31 downto 27);  -- a leftrotate 5
				t     <= std_logic_vector(unsigned(a_rol) + ((unsigned(f) + unsigned(k)) + (unsigned(e) + unsigned(w_round))));
					
				hash_round(159 downto 128) <= t;  -- a
				hash_round(127 downto  96) <= a;  -- b
				hash_round( 95 downto  64) <= b(1 downto 0) & b(31 downto 2);  -- b leftrotate 30
				hash_round( 63 downto  32) <= c;
				hash_round( 31 downto   0) <= d;
				
				ready_round_q1 <= '1';
				ready_round <= ready_round_q1;
				if ready_round = '1' then 
					state <= C_NEXT_ROUND;
					if 0 <= round and round < 16 then 
						ack <= '1';
					elsif reset_n = '1' and round < 32 then 
						ack <= '1';
					end if;
				else 
					state <= C_PROCESS_WORD;
				end if;
			when C_NEXT_ROUND => 
				ready          <= '0';
				ready_round    <= '0';
				ready_round_q1 <= '0';
				ack            <= '0';
				
				if 0 <= round and round < 79 then
					a <= hash_round(159 downto 128);
					b <= hash_round(127 downto  96);
					c <= hash_round( 95 downto  64);
					d <= hash_round( 63 downto  32);
					e <= hash_round( 31 downto   0);
					round  <= round + 1;
					state  <= C_EXTEND_CHUNK;
				elsif round = 79 then
					hash(159 downto 128) <= std_logic_vector(unsigned(hash_round(159 downto 128)) + unsigned(h0));  -- a
					hash(127 downto  96) <= std_logic_vector(unsigned(hash_round(127 downto  96)) + unsigned(h1));  -- b
					hash( 95 downto  64) <= std_logic_vector(unsigned(hash_round( 95 downto  64)) + unsigned(h2));  -- c
					hash( 63 downto  32) <= std_logic_vector(unsigned(hash_round( 63 downto  32)) + unsigned(h3));  -- d
					hash( 31 downto   0) <= std_logic_vector(unsigned(hash_round( 31 downto   0)) + unsigned(h4));  -- e
					if reset_n = '0' then
						ready  <= '1';  -- end of operations
					end if;
					state  <= C_IDLE;
				end if;
			when others =>  
				ready <= '0';
			end case;
		end if;
	end process sha1_chunk_process;
end sha1_chunk_arch;