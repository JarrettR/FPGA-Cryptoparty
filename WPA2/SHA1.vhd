----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jarrett Rainier
-- 
-- Create Date:    18:15:27 04/09/2014 
-- Design Name: 	SHA1 Sequential Implementation
-- Module Name:    main - SHA 
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
-- what
-- 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity SHA1 is
    port (
		Di : in STD_LOGIC_VECTOR (31 downto 0);
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		Do : out STD_LOGIC_VECTOR (31 downto 0);
		Valid : out STD_LOGIC
    );
end SHA1;

architecture Behavioral of SHA1 is
	
	
	constant K0: STD_LOGIC_VECTOR (31 downto 0) := X"5A827999";
	constant K1: STD_LOGIC_VECTOR (31 downto 0) := X"6ED9EBA1";
	constant K2: STD_LOGIC_VECTOR (31 downto 0) := X"8F1BBCDC";
	constant K3: STD_LOGIC_VECTOR (31 downto 0) := X"CA62C1D6";
	
	constant H0i: STD_LOGIC_VECTOR (31 downto 0) := X"67452301";
	constant H1i: STD_LOGIC_VECTOR (31 downto 0) := X"EFCDAB89";
	constant H2i: STD_LOGIC_VECTOR (31 downto 0) := X"98BADCFE";
	constant H3i: STD_LOGIC_VECTOR (31 downto 0) := X"10325476";
	constant H4i: STD_LOGIC_VECTOR (31 downto 0) := X"C3D2E1F0";


	--signal count: integer := 0;

begin

	process
	type BUFF is array (0 to 79) of STD_LOGIC_VECTOR (31 downto 0); 
	variable W: BUFF;
	
	variable TEMP: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	
	variable A: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	variable B: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	variable C: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	variable D: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	variable E: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	
	variable F: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
	
	begin
		wait until CLK'event and CLK='1';
		--Start main
		A := H0i;
		B := H1i;
		C := H2i;
		D := H3i;
		E := H4i;
		
		
		for t in 1 to 15 loop
		--	TEMP := Di ((511-(t * 32)) downto (480 -(t * 32)));
			W(t) := W(t - 1);
		end loop;
		
		W(0) := Di;
		
		for t in 16 to 79 loop
			TEMP := W(t-3) xor W(t-8) xor W(t-14) xor W(t-16);
			W(t) := TEMP(30 downto 0) & TEMP(31);
		end loop;
		
		for t in 0 to 19 loop
			F := (B and C) or ((not B) and D);
			
			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K0));

         E := D;
			D := C;
			C := B(1 downto 0) & B(31 downto 2);
			B := A;
			A := TEMP;
		end loop;
		
		for t in 20 to 39 loop
			F := B xor C xor D;
			
			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K1));

         E := D;
			D := C;
			C := B(1 downto 0) & B(31 downto 2);
			B := A;
			A := TEMP;
		end loop;
		
		for t in 40 to 59 loop
			F := (B and C) or (B and D) or (C and D);
			
			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K2));

         E := D;
			D := C;
			C := B(1 downto 0) & B(31 downto 2);
			B := A;
			A := TEMP;
		end loop;
		
		for t in 60 to 79 loop
			F := B xor C xor D;
			
			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K3));

         E := D;
			D := C;
			C := B(1 downto 0) & B(31 downto 2);
			B := A;
			A := TEMP;
		end loop;
		
		
		Do <= E;
		
	end process;
	


end Behavioral;

