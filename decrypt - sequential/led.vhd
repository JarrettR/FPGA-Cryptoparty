----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:14:32 05/24/2014 
-- Design Name: 
-- Module Name:    led - basys2 
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

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity led is
    Port ( Di : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           SEG : out  STD_LOGIC_VECTOR (7 downto 0);
           AN : out  STD_LOGIC_VECTOR (3 downto 0));
end led;

architecture basys2 of led is

    component wrapper
    port(
			Di : in  STD_LOGIC_VECTOR (31 downto 0);
         CLK : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
	 
	 signal Wi: STD_LOGIC_VECTOR (31 downto 0);
	 signal Wo: STD_LOGIC_VECTOR (31 downto 0);
	 
  signal cntDiv: std_logic_vector(40 downto 0); -- general clock div/cnt
  --alias cntDisp: std_logic_vector(3 downto 0) is cntDiv(28 downto 25);
  
  
  
  signal currDisp: std_logic_vector(3 downto 0);
  
  signal currDisp1: std_logic_vector(3 downto 0);
  signal currDisp2: std_logic_vector(3 downto 0);
  signal currDisp3: std_logic_vector(3 downto 0);
  signal currDisp4: std_logic_vector(3 downto 0);
  
  --signal currNum:  std_logic_vector(15 downto 0) := X"0000";
  -- four bits of the main counter
	 
begin

   guts: wrapper port map (
          Wi, cntDiv(12), Wo
        );
		  

	ckDivider: process(CLK)
	begin
		if CLK'event and CLK='1' then
			cntDiv <= cntDiv + '1';
			
			currDisp1 <= Wo(15 downto 12);
			currDisp2 <= Wo(11 downto 8);
			currDisp3 <= Wo(7 downto 4);
			currDisp4 <= Wo(3 downto 0);
--			
--			currDisp1 <= cntDiv(37 downto 34);
--			currDisp2 <= cntDiv(33 downto 30);
--			currDisp3 <= cntDiv(29 downto 26);
--			currDisp4 <= cntDiv(25 downto 22);
			
			case cntDiv(16 downto 15) is
				when "00" => currDisp <= currDisp4;
				when "01" => currDisp <= currDisp3;
				when "10" => currDisp <= currDisp2;
				when others => currDisp <= currDisp1;
			end case;
			
			
			case cntDiv(16 downto 15) is
				when "00" => an <= "1110";
				when "01" => an <= "1101";
				when "10" => an <= "1011";
				when others => an <= "0111";
			end case;
								
		end if;
	end process;
	
	nibble: process(cntDiv(26))
	begin

	--if cntDisp'event and cntDisp(3)='0' then
			Wi <= Di & Di & Di & Di;
		--end if;
	end process;



	with currDisp select
		seg<= "01111001" when "0001",   --1
				"00100100" when "0010",   --2
				"00110000" when "0011",   --3
				"00011001" when "0100",   --4
				"00010010" when "0101",   --5
				"00000010" when "0110",   --6
				"01111000" when "0111",   --7
				"00000000" when "1000",   --8
				"00010000" when "1001",   --9
				"00001000" when "1010",   --A
				"00000011" when "1011",   --b
				"01000110" when "1100",   --C
				"00100001" when "1101",   --d
				"00000110" when "1110",   --E
				"00001110" when "1111",   --F
				"01000000" when others;   --0
				
	--an <= cntDisp;
end basys2;

