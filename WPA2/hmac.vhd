----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:58 03/09/2015 
-- Design Name: 
-- Module Name:    HMAC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HMAC is
    Port ( Ds : in  STD_LOGIC_VECTOR (511 downto 0);
           Dv : in  STD_LOGIC_VECTOR (511 downto 0);
           CLK : in  STD_LOGIC);
           RST : in  STD_LOGIC);
           Do : out  STD_LOGIC_VECTOR (31 downto 0)
			  );
end HMAC;

architecture Behavioral of HMAC is

 component SHA1
    port(
			Di : in  STD_LOGIC_VECTOR (31 downto 0);
         CLK : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
	 
	 signal Bi: std_logic_vector(511 downto 0) := (others => '0');
	 signal Bo: std_logic_vector(511 downto 0) := (others => '0');
	 signal DSHA: std_logic_vector(31 downto 0) := (others => '0');
	 signal CLKo: std_logic;
	 
   constant CLK_period : time := 5 ns;
	 
begin

  hash: SHA1 PORT MAP (
          DSHA => Di,
          CLKo => CLK,
          Do => Do
        );
		  
	process
	count: integer := 0;
		
	begin
		wait until CLK'event and CLK='1';
		
		
		
		Bi := Bi or Ds;
		Bo := Bo or Ds;
		
		Bi := Bi xor X"36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636";
		Bo := Bo xor X"5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C5C";
		
		for t in 0 to 31 loop
			CLKo <= 0;
			DSHA := Bi((511 - t * 32) downto (511 - (t + 1) * 32));
			wait for CLK_period/2;
			CLKo <= 1;
			wait for CLK_period/2;
		end loop;
		for t in 0 to 31 loop
			CLKo <= 0;
			DSHA := Bo((511 - t * 32) downto (511 - (t + 1) * 32));
			wait for CLK_period/2;
			CLKo <= 1;
			wait for CLK_period/2;
		end loop;
		
		for t in 0 to 4 loop --Do
			CLKo <= 0;
			wait for CLK_period/2;
			DSHA := Do;
			CLKo <= 1;
			wait for CLK_period/2;
		end loop;
			
		
		
		
	end process;


end Behavioral;

