----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:53:11 03/27/2015 
-- Design Name: 
-- Module Name:    crc - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CRC is
    Port ( Di : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Do : out  STD_LOGIC_VECTOR (31 downto 0);
           Valid : out  STD_LOGIC
			 );
end CRC;

architecture Behavioral of CRC is

 component SHA1
    port(
			Di : in  STD_LOGIC_VECTOR (31 downto 0);
         CLK : in  STD_LOGIC;
         RST : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (31 downto 0);
         Valid : out  STD_LOGIC
        );
    end component;
	 
	 
	signal data: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	signal DataLength: integer := 0;
	signal CheckSum: integer := 0;
	
	
begin

--	process
--	begin
--		wait until rising_edge(RST);
--		
--		DataLength <= 0;
--		CheckSum <= 0;
--		
--	end process;
	
		
	
	process
	begin
		wait until CLK'event and CLK='1';
		DataLength <= DataLength + 1;	
		if (RST = '1') then
			CheckSum <= CheckSum + 1;	
		end if;
		if (DataLength = 16) then
			data <= std_logic_vector(to_unsigned(CheckSum, data'length));	
			DataLength <= 0;
			CheckSum <= 0;
		else
			data <= Di;
		end if;
		
	end process;
	

   sha: SHA1 PORT MAP (
          data,
          CLK,
          RST,
          Do,
          Valid
        );

end Behavioral;

