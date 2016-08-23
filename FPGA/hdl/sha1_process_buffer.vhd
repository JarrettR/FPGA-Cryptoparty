--------------------------------------------------------------------------------
--  Final stage of SHA1 algorithm - process existing buffer and calc outputs
--    Copyright (C) 2016  Jarrett Rainier
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sha1_pkg.all;


entity sha1_process_buffer is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    w_full;
    load_i         : in    std_ulogic;
    new_i         : in    std_ulogic;
    dat_w_o        : out    w_output;
    valid_o        : out    std_ulogic
    );
end sha1_process_buffer;

architecture RTL of sha1_process_buffer is
    
    signal w: w_full;
    --signal w_con: w_full;
    signal w_hold: w_full;
    signal running: std_ulogic;
    -- synthesis translate_off
    signal test_word_1: std_ulogic_vector(0 to 31);
    signal test_word_2: std_ulogic_vector(0 to 31);
    signal test_word_3: std_ulogic_vector(0 to 31);
    signal test_word_4: std_ulogic_vector(0 to 31);
    signal test_word_5: std_ulogic_vector(0 to 31);
    -- synthesis translate_on
    signal i : integer range 0 to 79;
    
    signal a: unsigned(0 to 31);
    signal b: unsigned(0 to 31);
    signal c: unsigned(0 to 31);
    signal d: unsigned(0 to 31);
    signal e: unsigned(0 to 31);
    signal a_con: std_ulogic_vector(0 to 31);
    signal b_con: std_ulogic_vector(0 to 31);
    signal c_con: std_ulogic_vector(0 to 31);
    signal d_con: std_ulogic_vector(0 to 31);
    signal e_con: std_ulogic_vector(0 to 31);
    
    --Algorithm variables
	constant h0i : std_ulogic_vector(0 to 31) := X"67452301";  -- H0 (a)
	constant h1i : std_ulogic_vector(0 to 31) := X"EFCDAB89";  -- H1 (b)
	constant h2i : std_ulogic_vector(0 to 31) := X"98BADCFE";  -- H2 (c)
	constant h3i : std_ulogic_vector(0 to 31) := X"10325476";  -- H3 (d)
	constant h4i : std_ulogic_vector(0 to 31) := X"C3D2E1F0";  -- H4 (e)
	
	constant k0 : std_ulogic_vector(0 to 31) := X"5A827999";  -- ( 0 <= t <= 19)
	constant k1 : std_ulogic_vector(0 to 31) := X"6ED9EBA1";  -- (20 <= t <= 39)
	constant k2 : std_ulogic_vector(0 to 31) := X"8F1BBCDC";  -- (40 <= t <= 59)
	constant k3 : std_ulogic_vector(0 to 31) := X"CA62C1D6";  -- (60 <= t <= 79)
    
	signal h0         : std_ulogic_vector(0 to 31) := h0i;
	signal h1         : std_ulogic_vector(0 to 31) := h1i;
	signal h2         : std_ulogic_vector(0 to 31) := h2i;
	signal h3         : std_ulogic_vector(0 to 31) := h3i;
	signal h4         : std_ulogic_vector(0 to 31) := h4i;
    
	signal h0out         : unsigned(0 to 31);
	signal h1out         : unsigned(0 to 31);
	signal h2out         : unsigned(0 to 31);
	signal h3out         : unsigned(0 to 31);
	signal h4out         : unsigned(0 to 31);

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                --running <= '0';
                --Todo: Reset input too, if needed
                --for x in 0 to 79 loop
                --    w_hold(x) <= "00000000000000000000000000000000";
                --end loop;
                h0 <= h0i;
                h1 <= h1i;
                h2 <= h2i;
                h3 <= h3i;
                h4 <= h4i;
            else
                if load_i = '1' then
                    if new_i = '1' then
                        h0 <= h0i;
                        h1 <= h1i;
                        h2 <= h2i;
                        h3 <= h3i;
                        h4 <= h4i;

                        a <=  unsigned((h1i and h2i) or ((not h1i) and h3i)) +
                            rotate_left(unsigned(h0i), 5) +
                            unsigned(h4i) +
                            unsigned(dat_i(0)) +
                            unsigned(k0);  
                        b <= unsigned(h0i);
                        c <= rotate_left(unsigned(h1i), 30);
                        d <= unsigned(h2i);
                        e <= unsigned(h3i);

                    end if;
                    

                    i <= 0;
                else
                    --TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
                    --Alt: gotta be better way!
                    case i is
                       --f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)
                        when 0 to 18 => a <= unsigned((b_con and c_con) or ((not b_con) and d_con)) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i + 1)) +
                                            unsigned(k0);                                            
                        --f(t;B,C,D) = B XOR C XOR D
                        when 19 to 38 => a <= unsigned(b_con xor c_con xor d_con) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i + 1)) +
                                            unsigned(k1);        
                        --f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)
                        when 39 to 58 => a <= unsigned((b_con and c_con) or (b_con and d_con) or (c_con and d_con)) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i + 1)) +
                                            unsigned(k2);        
                        --f(t;B,C,D) = B XOR C XOR D
                        when 59 to 78 => a <= unsigned(b_con xor c_con xor d_con) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i + 1)) +
                                            unsigned(k3);     
                        when 79 => a <= unsigned(b_con xor c_con xor d_con) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i)) +
                                            unsigned(k3);        
                    end case;
                    --E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
                    e <= unsigned(d_con);
                    d <= unsigned(c_con);
                    c <= rotate_left(unsigned(b_con), 30);
                    b <= unsigned(a_con);
                    
                    i <= i + 1;
                end if;
                
                if i = 79 then
                    --i <= 0;
                    --Todo: AND 'running' signal with i = 79 to stop incorrect 'valid_o' outputs
                    valid_o <= '1';
                    h0out <= unsigned(h0) + a;
                    h1out <= unsigned(h1) + b;
                    h2out <= unsigned(h2) + c;
                    h3out <= unsigned(h3) + d;
                    h4out <= unsigned(h4) + e;
                else
                    valid_o <= '0';
                end if;
            end if;
        end if;
    end process;

    dat_w_o(0) <= std_ulogic_vector(h0out);
    dat_w_o(1) <= std_ulogic_vector(h1out);
    dat_w_o(2) <= std_ulogic_vector(h2out);
    dat_w_o(3) <= std_ulogic_vector(h3out);
    dat_w_o(4) <= std_ulogic_vector(h4out);
    w <= dat_i;
    
    --w_con <= w;
    a_con <= std_ulogic_vector(a);
    b_con <= std_ulogic_vector(b);
    c_con <= std_ulogic_vector(c);
    d_con <= std_ulogic_vector(d);
    e_con <= std_ulogic_vector(e);
    
    -- synthesis translate_off
    test_word_1 <= w(0);
    test_word_2 <= w(79);
    test_word_3 <= h0;
    test_word_4 <= std_ulogic_vector(h0out);
    test_word_5 <= std_ulogic_vector(h1out);
    -- synthesis translate_on

end RTL; 