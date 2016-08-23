library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity hmac_main is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    dat_bi_i        : in    w_input;
    dat_bo_i        : in    w_input;
    value_i         : in    std_ulogic_vector(0 to 31);
    value_load_i    : in    std_ulogic;
    dat_bi_o        : out    w_input;
    dat_bo_o        : out    w_input;
    valid_o         : out    std_ulogic
    
    );
end hmac_main;

architecture RTL of hmac_main is
    
    signal bi: w_input;
    signal bo: w_input;
    signal i : integer range 0 to 15;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                for x in 0 to 15 loop
                    bi(x) <= X"36363636";
                    bo(x) <= X"5c5c5c5c";
                end loop;
                i <= 0;
            --else
                --if secret_load_i = '1' then
                --    bi
            end if;
        end if;
    end process;
    --dat_w_o <= w_temp;
    
    --w_temp(0) <= dat_i;
    --w_temp(1) <= w(1);
    --w_temp(2) <= w(2);
    --w_temp(3) <= w(3);
    --w_temp(4) <= w(4);
    --w_temp(5) <= w(5);
    --w-_temp(6) <= w(6);
    --w_temp(7) <= w(7);
    --w_temp(8) <= w(8);
    --w_temp(9) <= w(9);
   -- w_temp(10) <= w(10);
    ---w_temp(11) <= w(11);
    --w_temp(12) <= w(12);
    --w_temp(13) <= w(13);
    --w_temp(14) <= w(14);
    --w_temp(15) <= w(15);

end RTL; 