----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:08:05 05/13/2014 
-- Design Name: 
-- Module Name:    stage1 - Behavioral 
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

entity stage1 is
    Port ( Di : in  STD_LOGIC_VECTOR (511 downto 0);
           CLK : in  STD_LOGIC;
           Do : out  STD_LOGIC_VECTOR (140 downto 0));
end stage1;

architecture Behavioral of stage1 is

	signal Wo: STD_LOGIC_VECTOR (511 downto 0);

begin

	process(CLK)
	begin
		Wo(511 downto 479) <= Di(511 downto 479);
		for i in 1 to 79 loop
			Wo((511 - (i * 32)) downto (479 - (i * 32))) <= Wo((511 - ((i - 1) * 32)) downto (479 - ((i - 1) * 32)));
		end loop;
	end process;

	Do <= Wo(140 downto 0);

end Behavioral;

