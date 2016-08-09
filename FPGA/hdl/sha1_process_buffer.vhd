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
    signal w_con: w_full;
    signal w_hold: w_full;
    signal running: std_ulogic;
    signal test_word_1: std_ulogic_vector(0 to 31);
    signal test_word_2: std_ulogic_vector(0 to 31);
    signal test_word_3: std_ulogic_vector(0 to 31);
    signal test_word_4: std_ulogic_vector(0 to 31);
    signal test_word_5: std_ulogic_vector(0 to 31);
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
    
	signal h0out         : std_ulogic_vector(0 to 31) := h0i;
	signal h1out         : std_ulogic_vector(0 to 31) := h1i;
	signal h2out         : std_ulogic_vector(0 to 31) := h2i;
	signal h3out         : std_ulogic_vector(0 to 31) := h3i;
	signal h4out         : std_ulogic_vector(0 to 31) := h4i;

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
                        
                        a <= unsigned(h0i);
                        b <= unsigned(h1i);
                        c <= unsigned(h2i);
                        d <= unsigned(h3i);
                        e <= unsigned(h4i);
                        
                        -- a <=  unsigned((h1i and h2i) or ((not h1i) and h3i)) +
                            -- rotate_left(unsigned(h0i), 5) +
                            -- unsigned(h4i) +
                            -- unsigned(w_hold(0)) +
                            -- unsigned(k0);  
                        -- b <= unsigned(h0i);
                        -- c <= rotate_left(unsigned(h1i), 30);
                        -- d <= unsigned(h2i);
                        -- e <= unsigned(h3i);
                        
                    --elsif i = 0 and new_i = '0' then
                    --    h0 <= std_ulogic_vector(unsigned(h0) + unsigned(a));
                    --    h1 <= std_ulogic_vector(unsigned(h1) + unsigned(b));
                    --    h2 <= std_ulogic_vector(unsigned(h2) + unsigned(c));
                    --    h3 <= std_ulogic_vector(unsigned(h3) + unsigned(d));
                    --    h4 <= std_ulogic_vector(unsigned(h4) + unsigned(e));
                    end if;
                    
                    for x in 0 to 79 loop
                        w(x) <= w_hold(x);
                    end loop;
                    i <= 0;
                    --valid_o <= '0';
                    --running <= '1';
                else
                    --TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
                    --Alt: gotta be better way!
                    case i is
                       --f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)
                        --when 0 => a <= "00000000000000000000000000000000";
                        when 0 to 19 => a <= unsigned((b_con and c_con) or ((not b_con) and d_con)) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i)) +
                                            unsigned(k0);                                            
                        --f(t;B,C,D) = B XOR C XOR D
                        --when 20 => a <= "00000000000000000000000000000000";
                        when 20 to 39 => a <= unsigned(b_con xor c_con xor d_con) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i)) +
                                            unsigned(k1);        
                        --f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)
                        when 40 to 59 => a <= unsigned((b_con and c_con) or (b_con and d_con) or (c_con and d_con)) +
                                            rotate_left(unsigned(a_con), 5) +
                                            unsigned(e_con) +
                                            unsigned(w(i)) +
                                            unsigned(k2);        
                        --f(t;B,C,D) = B XOR C XOR D
                        when 60 to 79 => a <= unsigned(b_con xor c_con xor d_con) +
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
                    --a <= temp;
                    
                    if i = 79 then
                        i <= 0;
                        --Todo: AND 'running' signal with i = 79 to stop incorrect 'valid_o' outputs
                        valid_o <= '1';
                        --h0 <= std_ulogic_vector(unsigned(h0) + unsigned(b xor c xor d));
                        --h1 <= std_ulogic_vector(unsigned(h1) + unsigned(a_con));
                        --h2 <= std_ulogic_vector(unsigned(h2) + unsigned(b_con));
                        --h3 <= std_ulogic_vector(unsigned(h3) + unsigned(c_con));
                        --h4 <= std_ulogic_vector(unsigned(h4) + unsigned(d_con));
                        h0out <= std_ulogic_vector(b xor c xor d);
                        h1out <= a_con;
                        h2out <= b_con;
                        h3out <= c_con;
                        h4out <= d_con;
                    else
                        i <= i + 1;
                        valid_o <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    dat_w_o(0) <= h0;
    dat_w_o(1) <= h1;
    dat_w_o(2) <= h2;
    dat_w_o(3) <= h3;
    dat_w_o(4) <= h4;
    w_hold <= dat_i;
    
    w_con <= w;
    a_con <= std_ulogic_vector(a);
    b_con <= std_ulogic_vector(b);
    c_con <= std_ulogic_vector(c);
    d_con <= std_ulogic_vector(d);
    e_con <= std_ulogic_vector(e);
    
    test_word_1 <= w(78);
    test_word_2 <= std_ulogic_vector(a);
    test_word_3 <= std_ulogic_vector(b);
    test_word_4 <= h0out;
    test_word_5 <= h1out;

end RTL; 