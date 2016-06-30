library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_load is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(0 to 31);
    sot_in         : in    std_ulogic;
    dat_w_o          : out    w_input
    
    );
end sha1_load;

architecture RTL of sha1_load is
    
    signal w: w_input;
    signal w_temp: w_input;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            for i in 1 to 15 loop
                w(i) <= w_temp(i - 1);
            end loop;
        end if;
    end process;
    dat_w_o <= w_temp;
    
    w_temp(0) <= dat_i;
    w_temp(1) <= w(1);
    w_temp(2) <= w(2);
    w_temp(3) <= w(3);
    w_temp(4) <= w(4);
    w_temp(5) <= w(5);
    w_temp(6) <= w(6);
    w_temp(7) <= w(7);
    w_temp(8) <= w(8);
    w_temp(9) <= w(9);
    w_temp(10) <= w(10);
    w_temp(11) <= w(11);
    w_temp(12) <= w(12);
    w_temp(13) <= w(13);
    w_temp(14) <= w(14);
    w_temp(15) <= w(15);

end RTL; 