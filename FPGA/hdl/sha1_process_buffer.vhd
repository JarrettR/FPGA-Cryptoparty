library ieee;
use ieee.std_logic_1164.all;
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
    
    --Algorithm variables
	constant h0i : std_logic_vector(0 to 31) := X"67452301";  -- H0 (a)
	constant h1i : std_logic_vector(0 to 31) := X"EFCDAB89";  -- H1 (b)
	constant h2i : std_logic_vector(0 to 31) := X"98BADCFE";  -- H2 (c)
	constant h3i : std_logic_vector(0 to 31) := X"10325476";  -- H3 (d)
	constant h4i : std_logic_vector(0 to 31) := X"C3D2E1F0";  -- H4 (e)
	
	constant k0 : std_logic_vector(0 to 31) := X"5A827999";  -- ( 0 <= t <= 19)
	constant k1 : std_logic_vector(0 to 31) := X"6ED9EBA1";  -- (20 <= t <= 39)
	constant k2 : std_logic_vector(0 to 31) := X"8F1BBCDC";  -- (40 <= t <= 59)
	constant k3 : std_logic_vector(0 to 31) := X"CA62C1D6";  -- (60 <= t <= 79)
    
	signal h0         : std_logic_vector(0 to 31) := h0i;
	signal h1         : std_logic_vector(0 to 31) := h1i;
	signal h2         : std_logic_vector(0 to 31) := h2i;
	signal h3         : std_logic_vector(0 to 31) := h3i;
	signal h4         : std_logic_vector(0 to 31) := h4i;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                --Todo: Add reset, if needed
                --for x in 0 to 79 loop
                --    w_hold(x) <= "00000000000000000000000000000000";
                --end loop;
            else
                if load_i = '1' then
                    for x in 0 to 79 loop
                        w(x) <= w_hold(x);
                    end loop;
                    i <= 0;
                    valid_o <= '0';
                else
                    --TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
                    --E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
                    case i is
                       --f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)
                        when 0 to 19 => w(i) <= w_con(i);
                        --f(t;B,C,D) = B XOR C XOR D
                        when 20 to 39 => w(i) <= w_con(i);
                        --f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)
                        when 40 to 59 => w(i) <= w_con(i);
                        --f(t;B,C,D) = B XOR C XOR D
                        when 60 to 79 => w(i) <= w_con(i);
                    end case;
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
    test_word_1 <= w_con(16);
    test_word_2 <= w_con(20);
    test_word_3 <= w_con(60);
    test_word_4 <= w_con(78);
    test_word_5 <= w_con(79);


end RTL; 