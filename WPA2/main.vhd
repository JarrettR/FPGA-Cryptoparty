----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:44:10 03/02/2015 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
    port(
			Di : in  STD_LOGIC_VECTOR (31 downto 0);
         CLK : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (31 downto 0)
        );
end main;

architecture Behavioral of main is

 component HMAC
    port(
			Di : in  STD_LOGIC_VECTOR (31 downto 0);
         CLK : in  STD_LOGIC;
         Do : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
    
   --Inputs
   --signal Di : std_logic_vector(31 downto 0);-- := (others => '0');
   --signal CLK  : std_logic := '0';
   --signal LOAD : std_logic_vector(31 downto 0);

 	--Outputs
   --signal Do : std_logic_vector(31 downto 0);
	
	
begin
   hmac: HMAC PORT MAP (
          Di => Di,
          CLK => CLK,
          Do => Do
        );


end Behavioral;

