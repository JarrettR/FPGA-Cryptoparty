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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity crc is
    Port ( Di : in  STD_LOGIC_VECTOR (31 downto 0);
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Do : out  STD_LOGIC_VECTOR (31 downto 0);
           Valid : out  STD_LOGIC);
end crc;

architecture Behavioral of crc is

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
	signal checksum: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	
	
begin

	process
	variable DataLength: integer := 0;
	begin
		wait until CLK'event and CLK='1';
		
		if (RST = '0') then
			if (DataLength > 0) then
				checksum <= std_logic_vector(to_unsigned(DataLength, checksum'length));;
				DataLength := 0;			
			end if;
		else
			DataLength := DataLength + 1;	
		end if;
		
	end process;
	
	process
	variable count: integer := 0;
	begin
		wait until CLK'event and CLK='1';
		
		if (count = 0) then
			data <= checksum;
		else
			data <= Di;
		end if;
	end process;
	
   sha: SHA1 PORT MAP (
          Data => Di,
          CLK => CLK,
          RST => RST,
          Do => Do,
          Valid => Valid
        );

end Behavioral;

