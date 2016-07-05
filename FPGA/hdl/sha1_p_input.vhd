library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_p_input is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    w_input;
    load_i         : in    std_ulogic;
    dat_w_o          : out    w_full
    );
end sha1_p_input;

architecture RTL of sha1_p_input is
    
    signal w: w_full;
    signal w_hold: w_input;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if (load_i = '1') then
                w_hold <= dat_i;
            end if;
            for i in 0 to 79 loop
                if i <= 15 then
                    w(i) <= w_hold(i);
                else
                    w(i) <= (w(i - 3)(1 to 31) & w(i - 3)(0)) XOR
                        (w(i - 8)(1 to 31) & w(i - 8)(0)) XOR
                        (w(i - 14)(1 to 31) & w(i - 14)(0)) XOR
                        (w(i - 16)(1 to 31) & w(i - 16)(0));
                end if;
            end loop;
            --w <= w_temp;
        end if;
    end process;

    dat_w_o <= w;
    --dat_o <= "00110011001100110011001100110011" XOR "11001100110011001100110011001100" XOR "11001100110011001100110011001100" XOR "00110011001100110011001100110011";
    --dat_o <= w(16 - 3) XOR w(16 - 8) XOR w(16 - 14) XOR w(16 - 16);
    --dat_o <= w(15)(3 to 31) & w(15)(0 to 2); --w(15); 
    --dat_o <= w(20); 

end RTL; 