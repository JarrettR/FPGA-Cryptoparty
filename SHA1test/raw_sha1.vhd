--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:34:53 04/26/2015
-- Design Name:   
-- Module Name:   C:/Users/User/Documents/GitHub/FPGA-Cryptoparty/SHA1test/raw_sha1.vhd
-- Project Name:  SHA1test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: sha1_chunk
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY raw_sha1 IS
END raw_sha1;
 
ARCHITECTURE behavioural OF raw_sha1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT sha1_chunk
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         h : IN  std_logic_vector(159 downto 0);
         cont : IN  std_logic;
         load : IN  std_logic;
         ack : OUT  std_logic;
         msg : IN  std_logic_vector(31 downto 0);
         hash : OUT  std_logic_vector(159 downto 0);
         ready : OUT  std_logic
        );
    END COMPONENT;
    
	-- types
	type chunk is array (0 to 31) of std_logic_vector(31 downto 0);
	type state_type is (STATE_IDLE, STATE_LOAD, STATE_PROCESS); 
	
	-- signals
	signal s_clk        : std_logic := '0';
	signal s_rst        : std_logic := '0';
	
	-- bi
--	signal bi_start      : std_logic := '0';
--	signal bi_load       : std_logic := '0';
--	signal bi_msg        : std_logic_vector(31 downto 0) := (others => '0');
--	signal bi_hash       : std_logic_vector(159 downto 0) := (others => '0');
--	signal bi_ack        : std_logic := '0';
--	signal bi_ready      : std_logic := '0';
--	
--	signal bi_chunk      : chunk := (others => (others => '0'));
	
	-- bo
	signal bo_start      : std_logic := '0';
	signal bo_load       : std_logic := '0';
	signal bo_msg        : std_logic_vector(31 downto 0) := (others => '0');
	signal bo_hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal bo_ack        : std_logic := '0';
	signal bo_ready      : std_logic := '0';
	
	signal bo_chunk      : chunk := (others => (others => '0'));
	signal cont  : std_logic := '0';
	signal state : state_type := STATE_IDLE;

begin
--	sha1_bi : sha1_chunk 
--		port map (
--			s_clk, s_rst, bi_hash, cont, bi_load, bi_ack, bi_msg, bi_hash, bi_ready
--		);
	sha1_bo : sha1_chunk 
		port map (
			s_clk, s_rst, bo_hash, cont, bo_load, bo_ack, bo_msg, bo_hash, bo_ready
		);

	rst_process: process
	begin
		s_rst <= '0';
		wait for 10 ns;
		s_rst <= '1';
		wait;
	end process rst_process;
  
	clk_process: process
	begin
		s_clk <= '0'; 
		wait for 5 ns;
		s_clk <= '1';
		wait for 5 ns;
	end process clk_process;
	
	
	testcase: process
		variable i : natural := 0;
	begin
		wait until rising_edge(s_clk);
		bo_load <= '0';
		
		case state is
		when STATE_IDLE =>
			if bo_ready = '1' and bo_start = '1' then
				i := 0;
				bo_msg <= bo_chunk(0);
				bo_load <= '1';
				state <= STATE_LOAD;
			end if;
		when STATE_LOAD =>
			if bo_ready = '1' or bo_ack = '1' then
				if i < 16 then	--First half
					if cont <= '0' then
						bo_msg <= bo_chunk(i);
					else
						bo_msg <= bo_chunk(i + 16);
					end if;
					i := i + 1;
				else	--second half
					wait until bo_ready = '1';
					i := 0;
					if cont <= '0' then
						cont <= '1';
					end if;
				end if;
				bo_load <= '1';
			end if;
					
		when others =>
		end case;
		
	end process testcase;



	
--	bi_process : process
--	begin
--		wait for 25 ns;
--	   
--		-- SHA1("61...") = 9b47122a88a9a7f65ce5540c1fc5954567c48404
--
--
--		--
--		bi_chunk(0)   <= X"61626364";
--		bi_chunk(1)   <= X"65666768";
--		bi_chunk(2)   <= X"696a6b6c";
--		bi_chunk(3)   <= X"6d6e6f70";
--		bi_chunk(4)   <= X"71727374";
--		bi_chunk(5)   <= X"75767778";
--		bi_chunk(6)   <= X"797a3031";
--		bi_chunk(7)   <= X"41424344";
--		bi_chunk(8)   <= X"45464748";
--		bi_chunk(9)   <= X"494a4b4c";
--		bi_chunk(10)   <= X"80000000";
--		bi_chunk(11)   <= X"00000000";
--		bi_chunk(12)   <= X"00000000";
--		bi_chunk(13)   <= X"00000000";
--		bi_chunk(14)   <= X"00000000"; --Size 1
--		bi_chunk(15)   <= X"00000140"; --Size 2
--		
--		bi_start      <= '1';
--		wait until bi_ready = '1'; 
--		bi_start      <= '0';
--		wait until s_clk = '1';
--
--		wait;
--		
--	end process bi_process;
	
	
	bo_process : process
	begin
		wait for 20 ns;
	   


--		-- SHA1("61...") = 9b47122a88a9a7f65ce5540c1fc5954567c48404
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
		bo_chunk(10)   <= X"80000000";
		bo_chunk(11)   <= X"00000000";
		bo_chunk(12)   <= X"00000000";
		bo_chunk(13)   <= X"00000000";
		bo_chunk(14)   <= X"00000000"; --Size 1
		bo_chunk(15)   <= X"00000140"; --Size 2

--6162636465666768696a6b6c6d6e6f707172737
--475767778797a30314142434445464748494a4b
--4c4d4e4f505152535455565758595a30313233343535363738717273747576777841424344

		--First a5909...
		--Final d717e22e 1659305f ad6ef088 64923db6 4aba9c08
--		bo_chunk(0)   <= X"61626364";
--		bo_chunk(1)   <= X"65666768";
--		bo_chunk(2)   <= X"696a6b6c";
--		bo_chunk(3)   <= X"6d6e6f70";
--		bo_chunk(4)   <= X"71727374";
--		bo_chunk(5)   <= X"75767778";
--		bo_chunk(6)   <= X"797a3031";
--		bo_chunk(7)   <= X"41424344";
--		bo_chunk(8)   <= X"45464748";
--		bo_chunk(9)   <= X"494a4b4c";
--		bo_chunk(10)   <= X"4d4e4f50";
--		bo_chunk(11)   <= X"51525354";
--		bo_chunk(12)   <= X"55565758";
--		bo_chunk(13)   <= X"595a3031";
--		bo_chunk(14)   <= X"32333435";
--		bo_chunk(15)   <= X"35363738";

		bo_chunk(16)   <= X"71727374";
		bo_chunk(17)   <= X"75767778";
		bo_chunk(18)   <= X"41424344";
		bo_chunk(19)   <= X"80000000";
		bo_chunk(20)   <= X"00000000";
		bo_chunk(21)   <= X"00000000";
		bo_chunk(22)   <= X"00000000";
		bo_chunk(23)   <= X"00000000";
		bo_chunk(24)   <= X"00000000";
		bo_chunk(25)   <= X"00000000";
		bo_chunk(26)   <= X"00000000";
		bo_chunk(27)   <= X"00000000";
		bo_chunk(28)   <= X"00000000";
		bo_chunk(29)   <= X"00000000";
		bo_chunk(30)   <= X"00000000";
		bo_chunk(31)   <= X"00000260";
		
		--cont <= '1';
		bo_start      <= '1';
		wait for 5 ns;
		wait until bo_ready = '1'; 
		bo_start      <= '0';
		wait until s_clk = '1';
		


		
	end process bo_process;
end behavioural;