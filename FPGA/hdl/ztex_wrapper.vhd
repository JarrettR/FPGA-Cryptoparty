library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity ztex_wrapper is

port(
    fxclk_i               : in    std_ulogic;
    select_i              : in    std_ulogic;
    reset_i               : in    std_ulogic;
    clk_reset_i           : in    std_ulogic;
    pll_stop_i            : in    std_ulogic;
    dcm_progclk_i         : in    std_ulogic;
    dcm_progdata_i        : in    std_ulogic;
    dcm_progen_i          : in    std_ulogic;
    rd_clk_i              : in    std_ulogic;
    wr_clk_i              : in    std_ulogic;
    wr_start_i            : in    std_ulogic;
    read_i                : out    std_ulogic_vector(0 to 7);
    write_o               : out    std_ulogic_vector(0 to 7)
    
    );
end ztex_wrapper;

architecture RTL of ztex_wrapper is
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
        valid_o        : out    std_ulogic
    );
    end component;
    component sha1_process_buffer
      port (
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        dat_i          : in    w_full;
        load_i         : in    std_ulogic;
        new_i          : in    std_ulogic;
        dat_w_o        : out    w_output;
        valid_o        : out    std_ulogic
    );
    end component;
   
    signal w_load: w_input;


begin

    LOAD1: sha1_load port map (clk_i,rst_i,dat_i,sot_in,w_load);
    
    process(fxclk_i)   
    begin
        if (fxclk_i'event and fxclk_i = '1') then
            --- 
        end if;
    end process;
    
    ---

end RTL; 