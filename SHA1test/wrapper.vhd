----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:44:51 04/15/2015 
-- Design Name: 
-- Module Name:    wrapper - Behavioral 
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

entity wrapper is
    Port ( pc : in  STD_LOGIC_VECTOR (7 downto 0);
           pb : out  STD_LOGIC_VECTOR (7 downto 0);
			  CS : in std_logic;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end wrapper;

architecture Behavioral of wrapper is



	-- types
	type state_type is (STATE_IDLE, STATE_SSID, STATE_MK, STATE_OUT);
	--signal declaration
	signal pb_buf : unsigned(7 downto 0);
	signal ssid : unsigned(255 downto 0);
	signal mk : unsigned(511 downto 0);
	signal pmk : unsigned(511 downto 0);


	signal state       : state_type := STATE_IDLE;
	signal i          : natural := 0;

begin
	pb <= std_logic_vector( pb_buf ) when CS = '1' else (others => 'Z');

	dpUCECHO: process(CLK)
	begin
		if CLK' event and CLK = '1' then
			case state is
			when STATE_IDLE =>
				i <= 63;
				if unsigned(pc) > 0 then
					state <= STATE_SSID;
					ssid(7 downto 0) <= unsigned(pc);
				end if;
			when STATE_SSID =>
				if unsigned(pc) > 0 then
					ssid(255 downto 8) <= ssid(247 downto 0);
					ssid(7 downto 0) <= unsigned(pc);
				else
					state <= STATE_MK;
				end if;
			when STATE_MK =>
				if unsigned(pc) > 0 then
					mk(511 downto 8) <= mk(503 downto 0);
					mk(7 downto 0) <= unsigned(pc);
				else
					state <= STATE_OUT;
				end if;
			when STATE_OUT =>
				if i > 0 then
					if ( mk(7 downto 0) >= 97 ) and ( mk(7 downto 0) <= 122) then
						pb_buf <= mk(7 downto 0) - 32;
					else
						pb_buf <= mk(7 downto 0);
					end if;
					mk(503 downto 0) <= mk(511 downto 8);
					i <= i - 1;
				else
					state <= STATE_IDLE;
				end if;
			when others => 
			end case;
				

		end if;
	end process dpUCECHO;


end Behavioral;

