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

entity wrapper is
    Port ( Di : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK : in  STD_LOGIC;
           Do : out  STD_LOGIC_VECTOR (31 downto 0));
end wrapper;

architecture Behavioral of wrapper is

    component main
    port(
			Di : in  STD_LOGIC_VECTOR (511 downto 0);
			CLK : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (159 downto 0)
        );
    end component;

	signal Wi: STD_LOGIC_VECTOR (511 downto 0);
	signal Wo: STD_LOGIC_VECTOR (159 downto 0);
	signal CLKo: STD_LOGIC;
	signal count: integer range 0 to 15;

begin

	process
	begin
		wait until CLK'event and CLK='1';
		CLKo <= '0';
		if count = 0 then
			Wi(511 downto 480) <= Di;
			count <= count + 1;
		else
			Wi((511 - (count * 32)) downto (480 - (count * 32))) <=  Di;
			if count > 11 then
				Do(31 downto 0) <=  Wo((159 - ((count - 11) * 32)) downto (128 - ((count - 11) * 32)));
			end if;
			if count < 15 then
				count <= count + 1;
			else 
				count <= 0;
				CLKo <= '1';
			end if;
		end if;
		--end loop;
	end process;

   unwrapped: main port map (
          Wi, CLKo, Wo
        );

-- dbgcount: process (count)
--            variable my_line : LINE;
--          begin
--            write(my_line, string'("xxx="));
--            write(my_line, count);
--            write(my_line, string'(",  at="));
--            write(my_line, now);
--            writeline(output, my_line);
--          end process prtxxx;

end Behavioral;

