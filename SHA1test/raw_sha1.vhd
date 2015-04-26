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
 
ARCHITECTURE behavior OF raw_sha1 IS 
 
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
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal h : std_logic_vector(159 downto 0) := (others => '0');
   signal cont : std_logic := '0';
   signal load : std_logic := '0';
   signal msg : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal ack : std_logic;
   signal hash : std_logic_vector(159 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: sha1_chunk PORT MAP (
          clk => clk,
          rst => rst,
          h => h,
          cont => cont,
          load => load,
          ack => ack,
          msg => msg,
          hash => hash,
          ready => ready
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
