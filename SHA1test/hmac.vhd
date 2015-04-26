library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity hmac is
end entity hmac;

architecture behavioural of hmac is
	-- constants
	
	-- components
	component sha1
		port(
			clk        : in  std_logic;
			rst        : in  std_logic;
			start      : in  std_logic;
			load       : in  std_logic;
			cont       : in  std_logic;
			last_word  : in  std_logic;
			last_bytes : in  std_logic_vector(1 downto 0);
			ack        : out std_logic;
			msg        : in  std_logic_vector( 31 downto 0);
			hash       : out std_logic_vector(159 downto 0);
			ready      : out std_logic
		);
	end component;

	-- types
	type chunk is array (0 to 18) of std_logic_vector(31 downto 0); 
	
	-- signals
	signal s_clk        : std_logic := '0';
	signal s_rst        : std_logic := '0';
	
	-- bi
	signal bi_start      : std_logic := '0';
	signal bi_load       : std_logic := '0';
	signal bi_last_word  : std_logic := '0';
	signal bi_last_bytes : std_logic_vector(1 downto 0) := (others => '0');
	signal bi_msg        : std_logic_vector(31 downto 0) := (others => '0');
	signal bi_hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal bi_ack        : std_logic := '0';
	signal bi_ready      : std_logic := '0';
	
	signal bi_chunk      : chunk := (others => (others => '0'));
	signal bi_count      : natural := 0;
	
	-- bo
	signal bo_start      : std_logic := '0';
	signal bo_load       : std_logic := '0';
	signal bo_last_word  : std_logic := '0';
	signal bo_last_bytes : std_logic_vector(1 downto 0) := (others => '0');
	signal bo_msg        : std_logic_vector(31 downto 0) := (others => '0');
	signal bo_hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal bo_ack        : std_logic := '0';
	signal bo_ready      : std_logic := '0';
	
	signal bo_chunk      : chunk := (others => (others => '0'));
	signal bo_count      : natural := 0;
	signal cont  : std_logic := '0';

begin
	sha1_bi : sha1 
		port map (
			s_clk, s_rst, bi_start, bi_load, cont, bi_last_word, bi_last_bytes, bi_ack, bi_msg, bi_hash, bi_ready
		);
	sha1_bo : sha1 
		port map (
			s_clk, s_rst, bo_start, bo_load, cont, bo_last_word, bo_last_bytes, bo_ack, bo_msg, bo_hash, bo_ready
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

	load_bi : process(s_clk)
		variable i : natural := 0;
	begin
		if rising_edge(s_clk) then
			bi_load <= '0';
			if bi_start = '1' then
				if bi_ack = '1' or bi_ready = '1' then
					if 0 <= i and i < bi_count - 1 then
						bi_load      <= '1';
						bi_last_word <= '0';
						bi_msg       <= bi_chunk(i);
						i           := i + 1;
					elsif i = bi_count - 1 then 
						bi_load      <= '1';
                  bi_last_word <= '1';
						bi_msg       <= bi_chunk(i);
						i           := i + 1;
					else
						bi_last_word <= '1';
						bi_load <= '0';
					end if;
				else
					bi_load <= '0';
				end if;
			else 
				bi_load <= '0';
				i      := 0;
			end if;
		end if;
	end process load_bi;

	load_bo : process(s_clk)
		variable i : natural := 0;
	begin
		if rising_edge(s_clk) then
			bo_load <= '0';
			if bo_start = '1' then
				if i > 16 then
					cont <= '1';
				end if;	
				if bo_ack = '1' or bo_ready = '1' then
					if 0 <= i and i < bo_count - 1 then
						bo_load      <= '1';
						bo_last_word <= '0';
						bo_msg       <= bo_chunk(i);
						i           := i + 1;
					elsif i = bo_count - 1 then 
						bo_load      <= '1';
                  bo_last_word <= '1';
						bo_msg       <= bo_chunk(i);
						i           := i + 1;
					else
						bo_last_word <= '1';
						bo_load <= '0';
					end if;
				else
					bo_load <= '0';
				end if;
			else 
				bo_load <= '0';
				i      := 0;
			end if;
		end if;
	end process load_bo;
	
	bi_process : process
	begin
		wait for 5 ns;
	   
		-- SHA1("abcdefghijklmnopqrstuvwx") = d717e22e 1659305f ad6ef088 64923db6 4aba9c08
		--bi_chunk(0)   <= X"61626364";
		--bi_chunk(1)   <= X"65666768";
		
		--ABCDE, 12345678
		bi_chunk(0)   <= X"61626364" xor X"36363636";
		bi_chunk(1)   <= X"65000000" xor X"36363636";
		bi_chunk(2)   <= X"00000000" xor X"36363636";
		bi_chunk(3)   <= X"00000000" xor X"36363636";
		bi_chunk(4)   <= X"00000000" xor X"36363636";
		bi_chunk(5)   <= X"00000000" xor X"36363636";
		bi_chunk(6)   <= X"00000000" xor X"36363636";
		bi_chunk(7)   <= X"00000000" xor X"36363636";
		bi_chunk(8)   <= X"00000000" xor X"36363636";
		bi_chunk(9)   <= X"00000000" xor X"36363636";
		bi_chunk(10)   <= X"00000000" xor X"36363636";
		bi_chunk(11)   <= X"00000000" xor X"36363636";
		bi_chunk(12)   <= X"00000000" xor X"36363636";
		bi_chunk(13)   <= X"00000000" xor X"36363636";
		--bi_chunk(14)   <= X"00000000" xor X"36363636";
		--bi_chunk(15)   <= X"00000000" xor X"36363636";
		bi_count      <= 1;
		bi_last_bytes <= "00";
		bi_start      <= '1';
		wait until bi_ready = '1'; 
		bi_start      <= '0';
		wait until s_clk = '1';

		wait;
		
	end process bi_process;
	
	
	bo_process : process
	begin
		wait for 20 ns;
		wait until bi_ready='1';
	   
		-- SHA1("abcdefghijklmnopqrstuvwx") = d717e22e 1659305f ad6ef088 64923db6 4aba9c08
--		bo_chunk(0)   <= X"61626364" xor X"5C5C5C5C";
--		bo_chunk(1)   <= X"65000000" xor X"5C5C5C5C";
--		bo_chunk(2)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(3)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(4)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(5)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(6)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(7)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(8)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(9)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(10)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(11)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(12)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(13)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(14)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(15)   <= X"00000000" xor X"5C5C5C5C";
--		bo_chunk(16)   <= X"31323334";
--		bo_chunk(17)   <= X"35363738";
--		bo_chunk(18)   <= bi_hash(159 downto 128);
--		bo_chunk(19)   <= bi_hash(127 downto 96);
--		bo_chunk(20)   <= bi_hash(95 downto 64);
--		bo_chunk(21)   <= bi_hash(63 downto 32);
--		bo_chunk(22)   <= bi_hash(31 downto 0);
		bo_chunk(0)   <= X"61626364";
		bo_chunk(1)   <= X"65666768";
		bo_chunk(2)   <= X"696a6b6c";
		bo_chunk(3)   <= X"6d6e6f70";
		bo_chunk(4)   <= X"71727374";
		bo_chunk(5)   <= X"75767778";
		bo_chunk(6)   <= X"797a3031";
		bo_chunk(7)   <= X"41424344";
		bo_chunk(8)   <= X"45464748";
		bo_chunk(9)   <= X"494a4b4c";
		bo_chunk(10)   <= X"4d4e4f50";
		bo_chunk(11)   <= X"51525354";
		bo_chunk(12)   <= X"55565758";
		bo_chunk(13)   <= X"595a3031";
		bo_chunk(14)   <= X"32333435";
		bo_chunk(15)   <= X"35363738";
		bo_chunk(16)   <= X"71727374";
		bo_chunk(17)   <= X"75767778";
		bo_chunk(18)   <= X"41424344";
		bo_count      <= 19;
		bo_last_bytes <= "00";
		--cont <= '1';
		bo_start      <= '1';
		wait for 5 ns;
		wait until bo_ready = '1'; 
		bo_start      <= '0';
		wait until s_clk = '1';
		
		
		wait for 30 ns;
		bo_start      <= '1';
		wait for 5 ns;
		wait until bo_ready = '1'; 
		bo_start      <= '0';
		wait until s_clk = '1';

		
	end process bo_process;
end behavioural;