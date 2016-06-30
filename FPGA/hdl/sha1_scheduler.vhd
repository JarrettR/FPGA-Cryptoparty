library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_scheduler is

port(
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(0 to 31);
    sot_in         : in    std_ulogic;
    dat_1_o          : out    w_type;
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
        dat_i          : in    std_ulogic_vector(0 to 31);
        sot_in         : in    std_ulogic;
        dat_w_o        : out    w_input
    );
    end component;
    component sha1_p_input
      port (
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        dat_i          : in    w_input;
        sot_in         : in    std_ulogic;
        dat_w_o        : out    w_type
    );
    end component;
    
    signal w: w_type;
    signal w_temp: w_input;
    signal i : integer range 0 to 15;

begin

    LOAD1: sha1_load port map (clk_i,rst_i,dat_i,sot_in,w_temp);
    PINPUT1: sha1_p_input port map (clk_i,rst_i,w_temp,sot_in,w);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if i = 15 or sot_in = '1' then
                i <= 0;
            else
                i <= i + 1;
            end if;
        end if;
    end process;
    
    dat_5_o <= w_temp(15);
    

end RTL; 