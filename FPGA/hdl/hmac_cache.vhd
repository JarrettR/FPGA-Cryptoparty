library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity hmac_cache is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    secret_i        : in    std_ulogic_vector(0 to 31);
    load_i          : in    std_ulogic;
    dat_bi_o        : out    w_input;
    dat_bo_o        : out    w_input;
    valid_o         : out    std_ulogic  
    );
end hmac_cache;

architecture RTL of hmac_cache is
    
    signal bi: w_input;
    signal bo: w_input;
    signal i : integer range 0 to 15;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                valid_o <= '0';
            else
                if load_i = '1' then
                    bi(i) <= X"36363636" xor secret_i;
                    bo(i) <= X"5c5c5c5c" xor secret_i;
                end if;
                if i = 15 then
                    valid_o <= '1';
                 else
                    i <= i + 1;
                    valid_o <= '0';
                end if;
            end if;
        end if;
    end process;
    
    dat_bi_o <= bi;
    dat_bo_o <= bo;

end RTL; 