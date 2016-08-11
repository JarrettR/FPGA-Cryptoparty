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
    valid_o          : out    std_ulogic
    );
end sha1_process_input;

architecture RTL of sha1_process_input is
    
    signal w: w_full;
    signal w_con: w_full;
    signal w_hold: w_input;
    
    -- synthesis translate_off
    signal test_word_1: std_ulogic_vector(0 to 31);
    signal test_word_2: std_ulogic_vector(0 to 31);
    signal test_word_3: std_ulogic_vector(0 to 31);
    signal test_word_4: std_ulogic_vector(0 to 31);
    signal test_word_5: std_ulogic_vector(0 to 31);
    -- synthesis translate_on
    
    signal i : integer range 0 to 79;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                --Todo: decide if reset is even wanted
                --for x in 0 to 15 loop
                --    w_hold(x) <= "00000000000000000000000000000000";
                --end loop;
            else
                if load_i = '1' then
                    --Alt: Type-casting instead of using loop
                    for x in 0 to 15 loop
                        w(x) <= w_hold(x);
                    end loop;
                    i <= 16; --i + 1;
                    valid_o <= '0';
                elsif i < 16 then
                    i <= i + 1;
                    valid_o <= '0';
                else
                    w(i) <= (w_con(i - 3)(1 to 31) & w_con(i - 3)(0)) XOR
                        (w_con(i - 8)(1 to 31) & w_con(i - 8)(0)) XOR
                        (w_con(i - 14)(1 to 31) & w_con(i - 14)(0)) XOR
                        (w_con(i - 16)(1 to 31) & w_con(i - 16)(0));
                    if i = 79 then
                        i <= 0;
                        --valid_o <= '1';
                    elsif i = 16 then
                        i <= i + 1;
                        valid_o <= '1';
                    else
                        i <= i + 1;
                        valid_o <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    --Alt: merge functions of dat_w_o and w_con using inout port
    dat_w_o <= w;
    w_hold <= dat_i;
    w_con <= w;
    
    -- synthesis translate_off
    test_word_1 <= w_con(16);
    test_word_2 <= w_con(17);
    test_word_3 <= w_con(18);
    test_word_4 <= w_con(78);
    test_word_5 <= w_con(79);
    -- synthesis translate_on


end RTL; 