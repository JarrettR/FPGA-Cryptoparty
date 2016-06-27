library ieee ;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;


entity sha1_load is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(0 to 31);
    sot_in         : in    std_ulogic;
    dat_o          : out    std_ulogic_vector(0 to 31)
    
    );
end sha1_load;

architecture RTL of sha1_load is
    type AA is array(0 to 79) of std_ulogic_vector(0 to 31);
    signal w: AA;

begin

    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            --w <= dat_i & w(0 to 511-32);
            
            w(0) <= dat_i;
            --w(1) <= w(0);
            --w(2) <= w(1);
            for i in 1 to 15 loop
                w(i) <= w(i - 1);
            end loop;
            
        end if;
    end process;	
    dat_o <= w(15); 

end RTL; 