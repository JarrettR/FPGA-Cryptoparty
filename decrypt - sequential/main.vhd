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
-- This here is completely sequential
--  That is totally not ideal, not cool, and not permanent
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity main is
    port (
	 --Probably going to have to use a shift reg wrapper to use this
	  Di : in STD_LOGIC_VECTOR (511 downto 0);
	  
	  D0o : out STD_LOGIC_VECTOR (31 downto 0);
	  D1o : out STD_LOGIC_VECTOR (31 downto 0);
	  D2o : out STD_LOGIC_VECTOR (31 downto 0);
	  D3o : out STD_LOGIC_VECTOR (31 downto 0);
	  D4o : out STD_LOGIC_VECTOR (31 downto 0)
         );
end main;

architecture SHA of main is
	
	
	constant K0: STD_LOGIC_VECTOR (31 downto 0) := X"5A827999";
	constant K1: STD_LOGIC_VECTOR (31 downto 0) := X"6ED9EBA1";
	constant K2: STD_LOGIC_VECTOR (31 downto 0) := X"8F1BBCDC";
	constant K3: STD_LOGIC_VECTOR (31 downto 0) := X"CA62C1D6";
	
	constant H0i: STD_LOGIC_VECTOR (31 downto 0) := X"67452301";
	constant H1i: STD_LOGIC_VECTOR (31 downto 0) := X"EFCDAB89";
	constant H2i: STD_LOGIC_VECTOR (31 downto 0) := X"98BADCFE";
	constant H3i: STD_LOGIC_VECTOR (31 downto 0) := X"10325476";
	constant H4i: STD_LOGIC_VECTOR (31 downto 0) := X"C3D2E1F0";


begin

	process (Di)
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
		--Start main
		A := H0i;
		B := H1i;
		C := H2i;
		D := H3i;
		E := H4i;
		
		
		for t in 0 to 15 loop
			TEMP := Di ((511-(t * 32)) downto (480 -(t * 32)));
			W(t) := TEMP;
		end loop;
		
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
		
		
		D0o <= std_logic_vector(unsigned(H0i) + unsigned(A));
		D1o <= std_logic_vector(unsigned(H1i) + unsigned(B));
		D2o <= std_logic_vector(unsigned(H2i) + unsigned(C));
		D3o <= std_logic_vector(unsigned(H3i) + unsigned(D));
		D4o <= std_logic_vector(unsigned(H4i) + unsigned(E));
		
	end process;
	


end SHA;

