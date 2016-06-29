library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_scheduler is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(0 to 31);
    sot_in         : in    std_ulogic;
    dat_1_o          : out    std_ulogic_vector(0 to 31);
    dat_2_o          : out    std_ulogic_vector(0 to 31);
    dat_3_o          : out    std_ulogic_vector(0 to 31);
    dat_4_o          : out    std_ulogic_vector(0 to 31);
    dat_5_o          : out    std_ulogic_vector(0 to 31)
    
    );
end sha1_scheduler;

architecture RTL of sha1_scheduler is
    component sha1_load
      port (
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        dat_i          : in    w_input;
        sot_in         : in    std_ulogic;
        dat_1_o          : out    std_ulogic_vector(0 to 31);
        dat_2_o          : out    std_ulogic_vector(0 to 31);
        dat_3_o          : out    std_ulogic_vector(0 to 31);
        dat_4_o          : out    std_ulogic_vector(0 to 31);
        dat_5_o          : out    std_ulogic_vector(0 to 31)
    );
    end component;
    
    --type w_type is array(0 to 79) of std_ulogic_vector(0 to 31);
    signal w: w_type;
    signal w_temp: w_type;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            for i in 1 to 79 loop
                if i < 16 then
                    w(i) <= w_temp(i - 1);
                else
                    --These are all one register behind where you'd expect, because they haven't been shifted yet
                    --w(i) <= "11111111111111111111111111111111";
                    w(i) <= w_temp(i);
                    --w(i) <= (w(i - 3)(1 to 31) & w(i - 3)(0)) XOR
                    --    (w(i - 8)(1 to 31) & w(i - 8)(0)) XOR
                    --    (w(i - 14)(1 to 31) & w(i - 14)(0)) XOR
                    --    (w(i - 16)(1 to 31) & w(i - 16)(0));
                end if;
            end loop;
            --w <= w_temp;
        end if;
    end process;
    dat_1_o <= w_temp(15);
    dat_2_o <= w_temp(16);
    dat_3_o <= w_temp(17);	
    dat_4_o <= w_temp(18);	
    dat_5_o <= w_temp(19);	
    
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
    w_temp(16) <= w(16);
    w_temp(17) <= w(17);
    w_temp(18) <= w(18);
    w_temp(19) <= w(19);
    
    --dat_o <= "00110011001100110011001100110011" XOR "11001100110011001100110011001100" XOR "11001100110011001100110011001100" XOR "00110011001100110011001100110011";
    --dat_o <= w(16 - 3) XOR w(16 - 8) XOR w(16 - 14) XOR w(16 - 16);
    --dat_o <= w(15)(3 to 31) & w(15)(0 to 2); --w(15); 
    --dat_o <= w(20); 

end RTL; 