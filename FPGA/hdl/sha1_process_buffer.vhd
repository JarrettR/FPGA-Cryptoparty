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
    dat_w_o        : out    w_full;
    valid_o        : out    std_ulogic
    );
end sha1_process_buffer;

architecture RTL of sha1_process_buffer is
    
    signal w: w_full;
    signal w_con: w_full;
    signal w_hold: w_full;
    signal test_word_1: std_ulogic_vector(0 to 31);
    signal test_word_2: std_ulogic_vector(0 to 31);
    signal test_word_3: std_ulogic_vector(0 to 31);
    signal test_word_4: std_ulogic_vector(0 to 31);
    signal test_word_5: std_ulogic_vector(0 to 31);
    signal i : integer range 0 to 79;
    
    signal a: std_ulogic_vector(0 to 31);
    signal b: std_ulogic_vector(0 to 31);
    signal c: std_ulogic_vector(0 to 31);
    signal d: std_ulogic_vector(0 to 31);
    signal e: std_ulogic_vector(0 to 31);
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

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
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
                if i = 0 then
                    h0 <= std_ulogic_vector(unsigned(h0) + unsigned(a));
                    h1 <= std_ulogic_vector(unsigned(h1) + unsigned(b));
                    h2 <= std_ulogic_vector(unsigned(h2) + unsigned(c));
                    h3 <= std_ulogic_vector(unsigned(h3) + unsigned(d));
                    h4 <= std_ulogic_vector(unsigned(h4) + unsigned(e));
                end if;
                if load_i = '1' then
                    for x in 0 to 79 loop
                        w(x) <= w_hold(x);
                    end loop;
                    i <= 0;
                    valid_o <= '0';
                    a <= h0;
                    b <= h1;
                    c <= h2;
                    b <= h3;
                    e <= h4;
                else
                    --TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
                    --E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
                    case i is
                       --f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)
                        when 0 to 19 => a <= (b and c) or ((not b) and d);
                        --f(t;B,C,D) = B XOR C XOR D
                        when 20 to 39 => a <= b xor c xor d;
                        --f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)
                        when 40 to 59 => a <= (b and c) or (b and d) or (c and d);
                        --f(t;B,C,D) = B XOR C XOR D
                        when 60 to 79 => a <= b xor c xor d;
                    end case;
                    --E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
                    e <= d_con;
                    d <= c_con;
                    c <= b_con(30 to 31) & b_con(0 to 29);
                    b <= a_con;
                    --a <= temp;
                    
                    if i = 79 then
                        i <= 0;
                        valid_o <= '1';
                    else
                        i <= i + 1;
                        valid_o <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    dat_w_o <= w;
    w_hold <= dat_i;
    w_con <= w;
    a_con <= a;
    b_con <= b;
    c_con <= c;
    d_con <= d;
    e_con <= e;
    
    test_word_1 <= a;
    test_word_2 <= b;
    test_word_3 <= c;
    test_word_4 <= h0;
    test_word_5 <= h1;


end RTL; 