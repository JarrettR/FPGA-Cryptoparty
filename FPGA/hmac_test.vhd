--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:43:00 04/28/2015
-- Design Name:   
-- Module Name:   C:/Users/User/Documents/GitHub/FPGA-Cryptoparty/FPGA/hmac_test.vhd
-- Project Name:  SHA1test
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: hmac
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
 
ENTITY hmac_test IS
END hmac_test;
 
ARCHITECTURE behavior OF hmac_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hmac
    PORT(
		clk   : in  std_logic;
		rst   : in  std_logic;
		secret     : in std_logic_vector(511 downto 0);
		value     : in std_logic_vector(160 downto 0);
		load  : in  std_logic;
		ack   : out std_logic;
		hash  : out std_logic_vector(159 downto 0);
		ready : out std_logic
        );
    END COMPONENT;
     
	-- types
	type chunk is array (0 to 31) of std_logic_vector(31 downto 0);
	type state_type is (STATE_IDLE, STATE_LOAD, STATE_PROCESS); 
	
	-- signals
	signal clk        : std_logic := '0';
	signal rst        : std_logic := '0';
	

	signal start      : std_logic := '0';
	signal load       : std_logic := '0';
	signal secret        : std_logic_vector(511 downto 0) := (others => '0');
	signal value       : std_logic_vector(160 downto 0) := (others => '0');
	signal hash       : std_logic_vector(159 downto 0) := (others => '0');
	signal ack        : std_logic := '0';
	signal ready      : std_logic := '0';
	
	signal chunk      : chunk := (others => (others => '0'));
	signal cont  : std_logic := '0';
	signal state : state_type := STATE_IDLE;

begin

	hmac_x1 : hmac 
		port map (
			clk, rst, secret, value, load, ack, hash, ready
		);

	rst_process: process
	begin
		rst <= '0';
		wait for 10 ns;
		rst <= '1';
		wait;
	end process rst_process;
  
	clk_process: process
	begin
		clk <= '0'; 
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process clk_process;
	
	
--	testcase: process
--		variable i : natural := 0;
--	begin
--		wait until rising_edge(s_clk);
--		bo_load <= '0';
--		
--
--	end process testcase;


	bo_process : process
	begin
		wait for 20 ns;
	   


--		-- SHA1("61...") = 9b47122a88a9a7f65ce5540c1fc5954567c48404
		bo_chunk(0)   <= X"61626364";

		--cont <= '1';
		bo_start      <= '1';
		wait for 5 ns;
		wait until bo_ready = '1'; 
		bo_start      <= '0';
		wait until s_clk = '1';
		
		wait;


		
	end process bo_process;
end behavioural;