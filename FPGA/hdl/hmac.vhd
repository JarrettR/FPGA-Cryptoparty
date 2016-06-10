--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:34:53 04/26/2015
-- Design Name:   
-- Module Name:   C:/Users/User/Documents/GitHub/FPGA-Cryptoparty/SHA1test/hmac.vhd
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
 
ENTITY hmac IS
	port(
		clk   : in  std_logic;
		rst   : in  std_logic;
		secret     : in std_logic_vector(511 downto 0);
		value     : in std_logic_vector(160 downto 0);
		load  : in  std_logic;
		ack   : out std_logic;
		hash  : out std_logic_vector(159 downto 0);
		ready : out std_logic
		);
END hmac;
 
ARCHITECTURE behavioural OF hmac IS 
 
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
	
	-- bi
	signal bi_start      : std_logic := '0';
	signal bi_load       : std_logic := '0';
	signal bi_msg        : std_logic_vector(31 downto 0) := (others => '0');
	signal bi_hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal bi_ack        : std_logic := '0';
	signal bi_ready      : std_logic := '0';
	
	signal bi_chunk      : chunk := (others => (others => '0'));
	signal bi_cont  : std_logic := '0';
	
	-- bo
	signal bo_start      : std_logic := '0';
	signal bo_load       : std_logic := '0';
	signal bo_msg        : std_logic_vector(31 downto 0) := (others => '0');
	signal bo_hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal bo_ack        : std_logic := '0';
	signal bo_ready      : std_logic := '0';
	
	signal bo_chunk      : chunk := (others => (others => '0'));
	signal bo_cont  : std_logic := '0';
	signal state : state_type := STATE_IDLE;

begin
	sha1_bi : sha1_chunk 
		port map (
			clk, rst, bi_hash, bi_cont, bi_load, bi_ack, bi_msg, bi_hash, bi_ready
		);
	sha1_bo : sha1_chunk 
		port map (
			clk, rst, bo_hash, bo_cont, bo_load, bo_ack, bo_msg, bo_hash, bo_ready
		);
		
		hash <= bo_hash;

	bo_sha: process
		variable i : natural := 0;
	begin
		wait until rising_edge(clk);
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
					if bo_cont <= '0' then
						bo_msg <= bo_chunk(i);
					else
						bo_msg <= bo_chunk(i + 16);
					end if;
					i := i + 1;
				else	--second half
					wait until bo_ready = '1';
					i := 0;
					bo_msg <= bo_chunk(16);
					if bo_cont <= '0' then
						bo_cont <= '1';
					--else
					--	s_rst <= '0';
					end if;
				end if;
				bo_load <= '1';
			end if;
					
		when others =>
		end case;
		
	end process bo_sha;



	
	bi_process : process
	begin
		wait for 25 ns;
	   
		-- SHA1("61...") = 9b47122a88a9a7f65ce5540c1fc5954567c48404


		--
		bi_chunk(0)   <= secret(511 downto 480) xor X"36363636";
		bi_chunk(1)   <= secret(479 downto 448) xor X"36363636";
		bi_chunk(2)   <= secret(447 downto 416) xor X"36363636";
		bi_chunk(3)   <= secret(415 downto 384) xor X"36363636";
		bi_chunk(4)   <= secret(383 downto 352) xor X"36363636";
		bi_chunk(5)   <= secret(351 downto 320) xor X"36363636";
		bi_chunk(6)   <= secret(319 downto 288) xor X"36363636";
		bi_chunk(7)   <= secret(287 downto 256) xor X"36363636";
		bi_chunk(8)   <= secret(255 downto 224) xor X"36363636";
		bi_chunk(9)   <= secret(223 downto 192) xor X"36363636";
		bi_chunk(10)   <= secret(191 downto 160) xor X"36363636";
		bi_chunk(11)   <= secret(159 downto 128) xor X"36363636";
		bi_chunk(12)   <= secret(127 downto 96) xor X"36363636";
		bi_chunk(13)   <= secret(95 downto 64) xor X"36363636";
		bi_chunk(14)   <= secret(63 downto 32) xor X"36363636";
		bi_chunk(15)   <= secret(31 downto 0) xor X"36363636";
		
		bi_chunk(16)   <= X"80000000";
		bi_chunk(17)   <= X"00000000";
		bi_chunk(18)   <= X"00000000";
		bi_chunk(19)   <= X"00000000";
		bi_chunk(20)   <= X"00000000";
		bi_chunk(21)   <= X"00000000";
		bi_chunk(12)   <= X"00000000";
		bi_chunk(13)   <= X"00000000";
		bi_chunk(14)   <= X"00000000";
		bi_chunk(15)   <= X"00000000";
		bi_chunk(26)   <= X"00000000";
		bi_chunk(27)   <= X"00000000";
		bi_chunk(28)   <= X"00000000";
		bi_chunk(29)   <= X"00000000";
		bi_chunk(30)   <= X"00000000";
		bi_chunk(31)   <= X"00000200";
		
		bi_start      <= '1';
		wait until bi_ready = '1'; 
		bi_start      <= '0';
		wait until clk = '1';

	end process bi_process;
	
	
	bo_process : process
	begin
		wait until bi_cont = '1'; 
		wait until bi_ready = '1'; 
	   


		bo_chunk(0)   <= secret(511 downto 480) xor X"5C5C5C5C";
		bo_chunk(1)   <= secret(479 downto 448) xor X"5C5C5C5C";
		bo_chunk(2)   <= secret(447 downto 416) xor X"5C5C5C5C";
		bo_chunk(3)   <= secret(415 downto 384) xor X"5C5C5C5C";
		bo_chunk(4)   <= secret(383 downto 352) xor X"5C5C5C5C";
		bo_chunk(5)   <= secret(351 downto 320) xor X"5C5C5C5C";
		bo_chunk(6)   <= secret(319 downto 288) xor X"5C5C5C5C";
		bo_chunk(7)   <= secret(287 downto 256) xor X"5C5C5C5C";
		bo_chunk(8)   <= secret(255 downto 224) xor X"5C5C5C5C";
		bo_chunk(9)   <= secret(223 downto 192) xor X"5C5C5C5C";
		bo_chunk(10)   <= secret(191 downto 160) xor X"5C5C5C5C";
		bo_chunk(11)   <= secret(159 downto 128) xor X"5C5C5C5C";
		bo_chunk(12)   <= secret(127 downto 96) xor X"5C5C5C5C";
		bo_chunk(13)   <= secret(95 downto 64) xor X"5C5C5C5C";
		bo_chunk(14)   <= secret(63 downto 32) xor X"5C5C5C5C";
		bo_chunk(15)   <= secret(31 downto 0) xor X"5C5C5C5C";

		bo_chunk(16)   <= bi_hash(159 downto 128);
		bo_chunk(17)   <= bi_hash(127 downto 96);
		bo_chunk(18)   <= bi_hash(95 downto 64);
		bo_chunk(19)   <= bi_hash(63 downto 32);
		bo_chunk(20)   <= bi_hash(31 downto 0);
		bo_chunk(21)   <= X"80000000";
		bo_chunk(22)   <= X"00000000";
		bo_chunk(23)   <= X"00000000";
		bo_chunk(24)   <= X"00000000";
		bo_chunk(25)   <= X"00000000";
		bo_chunk(26)   <= X"00000000";
		bo_chunk(27)   <= X"00000000";
		bo_chunk(28)   <= X"00000000";
		bo_chunk(29)   <= X"00000000";
		bo_chunk(30)   <= X"00000000"; --Size 1
		bo_chunk(31)   <= X"00000270"; --Size 2
		
		--cont <= '1';
		bo_start      <= '1';
		wait for 5 ns;
		wait until bo_ready = '1'; 
		bo_start      <= '0';
		wait until clk = '1';
		
		wait;


		
	end process bo_process;
end behavioural;