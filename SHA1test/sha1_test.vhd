library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sha1_test is
end entity sha1_test;

architecture sha1_test_arch of sha1_test is
	-- constants
	
	-- components
	component sha1
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			start      : in  std_logic;
			load       : in  std_logic;
			last_word  : in  std_logic;
			last_bytes : in  std_logic_vector(1 downto 0);
			ack        : out std_logic;
			msg        : in  std_logic_vector( 31 downto 0);
			hash       : out std_logic_vector(159 downto 0);
			ready      : out std_logic
		);
	end component;

	-- types
	type chunk is array (0 to 15) of std_logic_vector(31 downto 0); 
	
	-- signals
	signal s_clk        : std_logic := '0';
	signal s_rst        : std_logic := '0';
	signal s_start      : std_logic := '0';
	signal s_load       : std_logic := '0';
	signal s_last_word  : std_logic := '0';
	signal s_last_bytes : std_logic_vector(1 downto 0) := (others => '0');
	signal s_msg        : std_logic_vector(31 downto 0) := (others => '0');
	signal s_hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal s_ack        : std_logic := '0';
	signal s_ready      : std_logic := '0';
	
	signal s_chunk      : chunk := (others => (others => '0'));
	signal s_count      : natural := 0;

begin
	sha1_object : sha1 
		port map (
			s_clk, s_rst, s_start, s_load, s_last_word, s_last_bytes, s_ack, s_msg, s_hash, s_ready
		);

	rst_process :process
	begin
		s_rst <= '0';
		wait for 10 ns;
		s_rst <= '1';
		wait;
	end process rst_process;
  
	clk_process : process
	begin
		s_clk <= '0'; 
		wait for 5 ns;
		s_clk <= '1';
		wait for 5 ns;
	end process clk_process;

	load_process : process(s_clk)
		variable i : natural := 0;
	begin
		if rising_edge(s_clk) then
			s_load <= '0';
			if s_start = '1' then
				if s_ack = '1' or s_ready = '1' then
					if 0 <= i and i < s_count - 1 then
						s_load      <= '1';
						s_last_word <= '0';
						s_msg       <= s_chunk(i);
						i           := i + 1;
					elsif i = s_count - 1 then 
						s_load      <= '1';
                        s_last_word <= '1';
						s_msg       <= s_chunk(i);
						i           := i + 1;
					else
						s_last_word <= '1';
						s_load <= '0';
					end if;
				else
					s_load <= '0';
				end if;
			else 
				s_load <= '0';
				i      := 0;
			end if;
		end if;
	end process load_process;
	
	sim_process : process
	begin
		wait for 200 ns;
	   
		-- SHA1("abcdefghijklmnopqrstuvwx") = d717e22e 1659305f ad6ef088 64923db6 4aba9c08
		s_chunk(0)   <= X"61626364";
		s_chunk(1)   <= X"65666768";
		s_chunk(2)   <= X"696a6b6c";
		s_chunk(3)   <= X"6d6e6f70";
		s_chunk(4)   <= X"71727374";
		s_chunk(5)   <= X"75767778";
		s_count      <= 6;
		s_last_bytes <= "00";
		s_start      <= '1';
		wait until s_ready = '1'; 
		s_start      <= '0';
		wait until s_clk = '1';
	   
		-- SHA1("abcdefghijklmnopqrstuvwxyz") = 32d10c7b 8cf96570 ca04ce37 f2a19d84 240d3a89
		s_chunk(0)   <= X"61626364";
		s_chunk(1)   <= X"65666768";
		s_chunk(2)   <= X"696a6b6c";
		s_chunk(3)   <= X"6d6e6f70";
		s_chunk(4)   <= X"71727374";
		s_chunk(5)   <= X"75767778";
		s_chunk(6)   <= X"0000797a";
		s_count      <= 7;
		s_last_bytes <= "10";
		s_start      <= '1';
		wait until s_ready = '1'; 
		s_start      <= '0';
		wait until s_clk = '1';
		
		-- SHA1("abc") = A9993E36 4706816A BA3E2571 7850C26C 9CD0D89D 
		s_chunk(0)   <= X"00616263";      -- W[0]
		s_count      <= 1;
		s_last_bytes <= "11";
		s_start      <= '1';
		wait until s_ready = '1'; 
		s_start      <= '0';
		wait until s_clk = '1';
		
		-- SHA1("ABCDEFGHIJKLMNOPQRSTUVWXYZ") = 80256f39 a9d30865 0ac90d9b e9a72a95 62454574
		s_chunk(0)   <= X"41424344";
		s_chunk(1)   <= X"45464748";
		s_chunk(2)   <= X"494a4b4c";
		s_chunk(3)   <= X"4d4e4f50";
		s_chunk(4)   <= X"51525354";
		s_chunk(5)   <= X"55565758";
		s_chunk(6)   <= X"0000595a";
		s_count      <= 7;
		s_last_bytes <= "10";
		s_start      <= '1';
		wait until s_ready = '1'; 
		s_start      <= '0';
		wait until s_clk = '1';
	   
		-- SHA1(AA:AA:AA:00:00:00:01:BB:BB:BB) = 03a5c47 30bc7137 4c4d26dd2 d247093a d08b779c
		s_chunk(0)   <= X"AAAAAA00";
		s_chunk(1)   <= X"000001BB";
		s_chunk(2)   <= X"0000BBBB";
		s_count      <= 3;
		s_last_bytes <= "10";
		s_start      <= '1';
		wait until s_ready = '1'; 
		s_start      <= '0';
		wait until s_clk = '1';

		wait;
		
	end process sim_process;
end sha1_test_arch;