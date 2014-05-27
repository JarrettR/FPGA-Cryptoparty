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
	  Di : in STD_LOGIC_VECTOR (511 downto 0);
	  
	  CLK  : in STD_LOGIC;
	  
	  D0o : out STD_LOGIC_VECTOR (31 downto 0);
	  D1o : out STD_LOGIC_VECTOR (31 downto 0);
	  D2o : out STD_LOGIC_VECTOR (31 downto 0);
	  D3o : out STD_LOGIC_VECTOR (31 downto 0);
	  D4o : out STD_LOGIC_VECTOR (31 downto 0);
	  
	  Wo	: out STD_LOGIC_VECTOR (511 downto 0)
	
	
         );
end main;

architecture SHA of main is

	type BUFF is array (0 to 79) of STD_LOGIC_VECTOR (31 downto 0); 
	signal W: BUFF;
	signal A: BUFF;
	signal B: BUFF;
	signal C: BUFF;
	signal D: BUFF;
	signal E: BUFF;
	
	
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
	D0o <= std_logic_vector(unsigned(H0i) + unsigned(A(79)));
	D1o <= std_logic_vector(unsigned(H1i) + unsigned(B(79)));
	D2o <= std_logic_vector(unsigned(H2i) + unsigned(C(79)));
	D3o <= std_logic_vector(unsigned(H3i) + unsigned(D(79)));
	D4o <= std_logic_vector(unsigned(H4i) + unsigned(E(79)));

--	assign: for t in 1 to 79 generate
--	begin
--		W(t) <= WTEMP(t);
--		E(t) <= DTEMP(t - 1);
--		D(t) <= CTEMP(t - 1);
--		C(t) <= BTEMP(t - 1)(1 downto 0) & BTEMP(t - 1)(31 downto 2);
--		B(t) <= ATEMP(t - 1);
--		A(t) <= TEMP(t);
--	end generate;
--		


	init: process(CLK)
	variable WTEMP: STD_LOGIC_VECTOR (31 downto 0);
	variable F: STD_LOGIC_VECTOR (31 downto 0);
	variable TEMP: STD_LOGIC_VECTOR (31 downto 0);
	begin
		if CLK'event and CLK = '1' then
			for t in 0 to 79 loop
				case t is
					when 0 =>
						WTEMP := Di(511 downto 480);
						W(t) <= WTEMP;
						E(0) <= H3i;
						D(0) <= H2i;
						C(0) <= H1i(1 downto 0) & H1i(31 downto 2);
						B(0) <= H0i;
						A(0) <= std_logic_vector((unsigned(H0i) rol 5) +
							unsigned((H1i and H2i) or ((not H1i) and H3i)) +
							unsigned(H4i) + unsigned(WTEMP) + unsigned(K0));
					when 1 to 15 =>
						WTEMP := Di((511 - (t * 32)) downto (480 - (t * 32)));
						W(t) <= WTEMP;
						
						F := (B(t - 1) and C(t - 1)) or ((not B(t - 1)) and D(t - 1));
						TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(WTEMP) + unsigned(K0));

						E(t) <= D(t - 1);
						D(t) <= C(t - 1);
						C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
						B(t) <= A(t - 1);
						A(t) <= TEMP;
								
					when 16 to 19 =>
						WTEMP := std_logic_vector(unsigned(W(t-3) xor W(t-8) xor W(t-14) xor W(t-16)) rol 1);
						W(t) <= WTEMP;						
						
						F := (B(t - 1) and C(t - 1)) or ((not B(t - 1)) and D(t - 1));
						TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(WTEMP) + unsigned(K0));

						E(t) <= D(t - 1);
						D(t) <= C(t - 1);
						C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
						B(t) <= A(t - 1);
						A(t) <= TEMP;
								
					when 20 to 39 =>
						WTEMP := std_logic_vector(unsigned(W(t-3) xor W(t-8) xor W(t-14) xor W(t-16)) rol 1);
						W(t) <= WTEMP;						
						
						F := B(t - 1) XOR C(t - 1) XOR D(t - 1);
						TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(WTEMP) + unsigned(K1));

						E(t) <= D(t - 1);
						D(t) <= C(t - 1);
						C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
						B(t) <= A(t - 1);
						A(t) <= TEMP;
								
					when 40 to 59 =>
						WTEMP := std_logic_vector(unsigned(W(t-3) xor W(t-8) xor W(t-14) xor W(t-16)) rol 1);
						W(t) <= WTEMP;						
						
						F := (B(t - 1) AND C(t - 1)) OR (B(t - 1) AND D(t - 1)) OR (C(t - 1) AND D(t - 1));
						TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(WTEMP) + unsigned(K2));

						E(t) <= D(t - 1);
						D(t) <= C(t - 1);
						C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
						B(t) <= A(t - 1);
						A(t) <= TEMP;
								
					when 60 to 79 =>
						WTEMP := std_logic_vector(unsigned(W(t-3) xor W(t-8) xor W(t-14) xor W(t-16)) rol 1);
						W(t) <= WTEMP;						
						
						F := B(t - 1) XOR C(t - 1) XOR D(t - 1);
						TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(WTEMP) + unsigned(K3));

						E(t) <= D(t - 1);
						D(t) <= C(t - 1);
						C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
						B(t) <= A(t - 1);
						A(t) <= TEMP;
				end case;
			end loop;
			
				
		end if;
		
			
	end process;
	
--	init: process(LOAD)
--	begin
--		if LOAD'event and LOAD = '1' then
--			for t in 0 to 15 loop
--				W(t) <= Di((511 - (t * 32)) downto (480 - (t * 32)));
--			end loop;
--			
--			E(0) <= H3i;
--			D(0) <= H2i;
--			C(0) <= H1i(1 downto 0) & H1i(31 downto 2);
--			B(0) <= H0i;
--			A(0) <= std_logic_vector((unsigned(H0i) rol 5) +
--				unsigned((H1i and H2i) or ((not H1i) and H3i)) +
--				unsigned(H4i) + unsigned(Di(511 downto 480)) + unsigned(K0));
--				
--				
--		end if;
--		
--			
--	end process;
--	Q <= std_logic_vector(unsigned(Di((511 - 416) downto (480 - 416)) xor Di((511 - 256) downto (480 - 256)) xor Di((511 - 64) downto (480 - 64)) xor Di(511 downto 480)) rol 1);
--	D0o <= Q;

--	populate: for t in 0 to 63 generate
--		W(t + 16) <= std_logic_vector(unsigned(W(t + 13) xor W(t + 8) xor W(t + 2) xor W(t)) rol 1);
--	end generate;
--	
--	fill: process(CLK, W, Di)
--	begin
--		--TODO: analyse timing - (downto & bit) faster?
--		if CLK'event and CLK = '1' then
--			--W(t + 16) <= std_logic_vector(unsigned(W(t + 13) xor W(t + 8) xor W(t + 2) xor W(t)) rol 1);
--			W(16) <= Di(511 downto 480);--W(3);--std_logic_vector(unsigned(W(3) xor W(8) xor W(14) xor W(0)) rol 1);
--		end if;
--		
--	end process;
	--end generate;
--	
--	process(E, D, C, B, A)
--	variable F: STD_LOGIC_VECTOR (31 downto 0);
--	variable TEMP: STD_LOGIC_VECTOR (31 downto 0);
--	begin
--				
--		round1: for t in 1 to 19 loop
--			F := (B(t - 1) and C(t - 1)) or ((not B(t - 1)) and D(t - 1));
--			
--			TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(W(t)) + unsigned(K0));
--
--			E(t) <= D(t - 1);
--			D(t) <= C(t - 1);
--			C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
--			B(t) <= A(t - 1);
--			A(t) <= TEMP;
--		end loop;
--				
--		round2: for t in 20 to 39 loop
--			F := (B(t - 1) and C(t - 1)) or ((not B(t - 1)) and D(t - 1));
--			
--			TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(W(t)) + unsigned(K1));
--
--			E(t) <= D(t - 1);
--			D(t) <= C(t - 1);
--			C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
--			B(t) <= A(t - 1);
--			A(t) <= TEMP;
--		end loop;
--				
--		round3: for t in 30 to 59 loop
--			F := (B(t - 1) and C(t - 1)) or ((not B(t - 1)) and D(t - 1));
--			
--			TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(W(t)) + unsigned(K2));
--
--			E(t) <= D(t - 1);
--			D(t) <= C(t - 1);
--			C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
--			B(t) <= A(t - 1);
--			A(t) <= TEMP;
--		end loop;
--				
--		round4: for t in 60 to 79 loop
--			F := (B(t - 1) and C(t - 1)) or ((not B(t - 1)) and D(t - 1));
--			
--			TEMP := std_logic_vector((unsigned(A(t - 1)) rol 5) + unsigned(F) + unsigned(E(t - 1)) + unsigned(W(t)) + unsigned(K3));
--
--			E(t) <= D(t - 1);
--			D(t) <= C(t - 1);
--			C(t) <= B(t - 1)(1 downto 0) & B(t - 1)(31 downto 2);
--			B(t) <= A(t - 1);
--			A(t) <= TEMP;
--		end loop;
--	Wo <= W(0)
--		& W(1)
--		& W(2)
--		& W(3)
--		& W(4)
--		& W(5)
--		& W(6)
--		& W(7)
--		& W(8)
--		& W(9)
--		& W(10)
--		& W(11)
--		& W(12)
--		& W(13)
--		& W(14)
--		& W(15);
--	end process;
--
--		
--	D0o := W(16);
--	D1o <= W(17);
--	D2o <= W(18);
--	D3o <= W(19);
--	D4o <= W(20);
	
	

--	
--	process (Di)
--	type BUFF is array (0 to 79) of STD_LOGIC_VECTOR (31 downto 0); 
--	variable Q: BUFF;
--	
--	variable TEMP: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	
--	variable A: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	variable B: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	variable C: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	variable D: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	variable E: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	
--	variable F: STD_LOGIC_VECTOR (31 downto 0) := X"00000000";
--	
--	begin
--		--Start main
--		A := H0i;
--		B := H1i;
--		C := H2i;
--		D := H3i;
--		E := H4i;
--		
--		
--		for t in 0 to 15 loop
--			Q(t) := Di;
--		end loop;
--		
--		for t in 16 to 79 loop
--			TEMP := W(t-3) xor W(t-8) xor W(t-14) xor W(t-16);
--			Q(t) := TEMP(30 downto 0) & TEMP(31);
--		end loop;
--		
--		
--		for t in 0 to 19 loop
--			F := (B and C) or ((not B) and D);
--			
--			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K0));
--
--         E := D;
--			D := C;
--			C := B(1 downto 0) & B(31 downto 2);
--			B := A;
--			A := TEMP;
--		end loop;
--		
--		for t in 20 to 39 loop
--			F := B xor C xor D;
--			
--			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K1));
--
--         E := D;
--			D := C;
--			C := B(1 downto 0) & B(31 downto 2);
--			B := A;
--			A := TEMP;
--		end loop;
--		
--		for t in 40 to 59 loop
--			F := (B and C) or (B and D) or (C and D);
--			
--			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K2));
--
--         E := D;
--			D := C;
--			C := B(1 downto 0) & B(31 downto 2);
--			B := A;
--			A := TEMP;
--		end loop;
--		
--		for t in 60 to 79 loop
--			F := B xor C xor D;
--			
--			TEMP := std_logic_vector((unsigned(A) rol 5) + unsigned(F) + unsigned(E) + unsigned(W(t)) + unsigned(K3));
--
--         E := D;
--			D := C;
--			C := B(1 downto 0) & B(31 downto 2);
--			B := A;
--			A := TEMP;
--		end loop;
--		
--		
--		D0o <= std_logic_vector(unsigned(H0i) + unsigned(A));
--		D1o <= std_logic_vector(unsigned(H1i) + unsigned(B));
--		D2o <= std_logic_vector(unsigned(H2i) + unsigned(C));
--		D3o <= std_logic_vector(unsigned(H3i) + unsigned(D));
--		D4o <= std_logic_vector(unsigned(H4i) + unsigned(E));
--		
--	end process;
	


end SHA;

