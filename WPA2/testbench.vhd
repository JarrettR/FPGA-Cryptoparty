--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:51:42 04/11/2014
-- Design Name:   
-- Module Name:   C:/Users/User/Documents/Projects/FPGA/decrypt/testbench.vhd
-- Project Name:  decrypt
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
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
USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 

 
    COMPONENT main
    PORT(
			Di : in  STD_LOGIC_VECTOR (31 downto 0);
         CLK : in  STD_LOGIC;
         RST : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (31 downto 0);
         Valid : out  STD_LOGIC
        );
    END COMPONENT;
    

   --Inputs
   --signal Di : std_logic_vector(511 downto 0) := (others => '0');
   signal CLK  : std_logic := '0';
   signal RST  : std_logic := '0';
   signal LOAD : std_logic_vector(31 downto 0);

 	--Outputs
   signal Do : std_logic_vector(31 downto 0);
   signal Valid : std_logic;
   --signal Di: std_logic_vector(31 downto 0);
   signal Di: std_logic_vector(31 downto 0) := X"0a000028";
	
	constant W1 : std_logic_vector(511 downto 0) := X"31323334" & X"35800000" & X"00000000" & X"00000000"
			 & X"00000000" & X"00000000" & X"00000000" & X"00000000"
			 & X"00000000" & X"00000000" & X"00000000" & X"00000000"
			 & X"00000000" & X"00000000" & X"00000000" & X"00000028";
	
	constant W2 : std_logic_vector(511 downto 0) := X"61626364" & X"65800000" & X"00000000" & X"00000000"
			 & X"00000000" & X"00000000" & X"00000000" & X"00000000"
			 & X"00000000" & X"00000000" & X"00000000" & X"00000000"
			 & X"00000000" & X"00000000" & X"00000000" & X"00000028";

   -- Clock period definitions
   constant CLK_period : time := 5 ns;
	
	signal count: integer range 0 to 31;
 
BEGIN
 

   uut: main PORT MAP (
          Di, CLK, RST, Do, Valid
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	--variable input: unsigned (31 downto 0) := X"0b000028";
   begin		
      -- hold reset state for 100 ns.
--      LOAD <=  '1' after 5 ns,
--					'0' after 15 ns;
		if count < 16 then
			Di <= W1((511 - (count * 32)) downto (480 - (count * 32)));
			count <= count + 1;
		elsif count < 31 then 
			Di <= W2((511 - ((count - 16) * 32)) downto (480 - ((count - 16) * 32)));
			count <= count + 1;
		else 
			Di <= W2((511 - ((count - 16) * 32)) downto (480 - ((count - 16) * 32)));
			count <= 0;
		end if; 
		
		
		wait until CLK'event and CLK='1';
		--Di <= std_logic_vector(input);
--		Di <= X"00000000",
--			X"00000028" after 20 ns,
--			X"00000000" after 25 ns,
--			X"00000000" after 30 ns,
--			X"00000000" after 35 ns,
--			
--			X"00000000" after 40 ns,
--			X"00000000" after 45 ns,
--			X"00000000" after 50 ns,
--			X"00000000" after 55 ns,
--		
--			X"00000000" after 60 ns,
--			X"00000000" after 65 ns,
--			X"00000000" after 70 ns,
--			X"00000000" after 75 ns,
--			
--			X"00000000" after 80 ns,
--			X"00000000" after 85 ns,
--			X"65800000" after 90 ns,
--			X"61626364" after 95 ns;


   end process;

END;
