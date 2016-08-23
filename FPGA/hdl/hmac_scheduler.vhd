library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity hmac_scheduler is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    secret_i       : in    std_ulogic_vector(0 to 31);
    load_secret_i  : in    std_ulogic;
    value_i        : in    std_ulogic_vector(0 to 31);
    load_value_i   : in    std_ulogic;
    dat_o          : out    std_ulogic_vector(0 to 31)    
    );
end hmac_scheduler;

architecture RTL of hmac_scheduler is
    component hmac_cache
        port(
            clk_i           : in    std_ulogic;
            rst_i           : in    std_ulogic;
            secret_i        : in    std_ulogic_vector(0 to 31);
            load_i          : in    std_ulogic;
            dat_bi_o        : out    w_input;
            dat_bo_o        : out    w_input;
            valid_o         : out    std_ulogic
            );
    end component;
   
    signal w_bi_1: w_input;
    signal w_bo_1: w_input;
    signal w_bi_temp: w_input;
    signal w_bo_temp: w_input;
    signal w_cached_valid: std_ulogic;
    signal i : integer range 0 to 15;
    
    signal i_mux : integer range 0 to 4;

begin

    CACHE1: hmac_cache port map (clk_i,rst_i,secret_i,load_secret_i,w_bi_1,w_bo_1,w_cached_valid);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                --Todo: start from 0 after testing
                i_mux <= 0;
                for x in 0 to 15 loop
                    w_bi_temp(x) <= "00000000000000000000000000000000";
                    w_bo_temp(x) <= "00000000000000000000000000000000";
                end loop;
            else
                if i = 15 then
                    i <= 0;
                 else
                    i <= i + 1;
                end if;
            end if;
        end if;
    end process;

end RTL; 