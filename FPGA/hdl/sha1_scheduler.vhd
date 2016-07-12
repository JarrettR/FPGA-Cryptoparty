library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_scheduler is

port(
    clk_i          : in    std_ulogic;
    load_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(0 to 31);
    sot_in         : in    std_ulogic;
    dat_1_o          : out    std_ulogic_vector(0 to 31);
    dat_2_o          : out    std_ulogic_vector(0 to 31);
    dat_3_o          : out    std_ulogic_vector(0 to 31);
    test_sha1_process_input_o   : out    std_ulogic_vector(0 to 31);
    test_sha1_load_o      : out    std_ulogic_vector(0 to 31)
    
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
    component sha1_process_input
      port (
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        dat_i          : in    w_input;
        load_i         : in    std_ulogic;
        dat_w_o        : out    w_full;
        test_word          : out    std_ulogic_vector(0 to 31)
    );
    end component;
   
    signal w_load: w_input;
    signal w_processed_input: w_full;
    signal w_temp: w_input;
    signal w_tst: std_ulogic_vector(0 to 31);
    signal latch_pinput: std_ulogic;
    signal i : integer range 0 to 80;

begin

    LOAD1: sha1_load port map (clk_i,rst_i,dat_i,sot_in,w_load);
    PINPUT1: sha1_process_input port map (clk_i,rst_i,w_temp,latch_pinput,w_processed_input,w_tst);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                latch_pinput <= '0';
                i <= 0;
                for x in 0 to 15 loop
                    w_temp(x) <= "00000000000000000000000000000000";
                end loop;
            else
                if i = 80 then
                    i <= 0;
                --elsif i = 0 then
                --    latch_pinput <= '1';
                --    i <= i + 1;
                elsif i = 16 then
                    latch_pinput <= '1';
                    w_temp <= w_load;
                    --i <= 0;
                    i <= i + 1;
                --elsif i = 17 then
                  --  latch_pinput <= '1';
                    --i <= i + 1;
                --elsif i = 2 then
                --    latch_pbuffer <= '1';
                --    i <= i + 1;
                else
                    latch_pinput <= '0';
                    i <= i + 1;
                end if;
            end if;
        end if;
    end process;
    
    dat_1_o <= w_temp(15);
    test_sha1_process_input_o <= w_processed_input(16);
    test_sha1_load_o <= w_load(15);
    --w_temp <= w_load;
    

end RTL; 