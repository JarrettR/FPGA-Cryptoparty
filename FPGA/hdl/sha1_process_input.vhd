library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_process_input is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    w_input;
    load_i         : in    std_ulogic;
    dat_w_o          : out    w_full;
    valid_o          : out    std_ulogic;
    test_word          : out    std_ulogic_vector(0 to 31)
    );
end sha1_process_input;

architecture RTL of sha1_process_input is
    
    signal w: w_full;
    signal w_con: w_full;
    signal w_hold: w_input;
    signal test_word_1: std_ulogic_vector(0 to 31);
    signal test_word_2: std_ulogic_vector(0 to 31);
    signal test_word_3: std_ulogic_vector(0 to 31);
    signal test_word_4: std_ulogic_vector(0 to 31);
    signal test_word_5: std_ulogic_vector(0 to 31);
    signal i : integer range 15 to 80;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 15;
                --for x in 0 to 15 loop
                --    w_hold(x) <= "00000000000000000000000000000000";
                --end loop;
            else
                if load_i = '1' then
                    for x in 0 to 15 loop
                        w(x) <= w_hold(x);
                    end loop;
                    i <= 16; --i + 1;
                    valid_o <= '0';
                elsif i = 80 then
                    i <= 15;
                    valid_o <= '1';
                    --Output signal here
                elsif i < 16 then
                    --w(i) <= w_hold(i);
                    i <= i + 1;
                    valid_o <= '0';
                else
                    --w(i) <= w_con(15)(1 to 31) & w_con(15)(0);
                    w(i) <= (w_con(i - 3)(1 to 31) & w_con(i - 3)(0)) XOR
                        (w_con(i - 8)(1 to 31) & w_con(i - 8)(0)) XOR
                        (w_con(i - 14)(1 to 31) & w_con(i - 14)(0)) XOR
                        (w_con(i - 16)(1 to 31) & w_con(i - 16)(0));
                    i <= i + 1;
                    valid_o <= '0';
                end if;
                --w <= w_temp;
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
    --dat_o <= "00110011001100110011001100110011" XOR "11001100110011001100110011001100" XOR "11001100110011001100110011001100" XOR "00110011001100110011001100110011";
    --dat_w_o <= w(16 - 3) XOR w(16 - 8) XOR w(16 - 14) XOR w(16 - 16);
    --dat_w_o <= w(15)(3 to 31) & w(15)(0 to 2); --w(15); 
    --dat_o <= w(20); 

end RTL; 