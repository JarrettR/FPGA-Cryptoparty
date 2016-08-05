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
        valid_o        : out    std_ulogic
    );
    end component;
    component sha1_process_buffer
      port (
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        dat_i          : in    w_full;
        load_i         : in    std_ulogic;
        new_i         : in    std_ulogic;
        dat_w_o        : out    w_output;
        valid_o        : out    std_ulogic
    );
    end component;
   
    signal w_load: w_input;
    signal w_processed_input1: w_full;
    signal w_processed_valid1: std_ulogic;
    signal w_processed_new: std_ulogic;
    signal w_processed_buffer: w_output;
    signal w_buffer_valid: std_ulogic;
    signal w_pinput1: w_input;
    signal latch_pinput1: std_ulogic;
    signal latch_pinput2: std_ulogic;
    signal latch_pinput3: std_ulogic;
    signal i : integer range 0 to 80;
    
    signal i_mux : integer range 0 to 2;

begin

    LOAD1: sha1_load port map (clk_i,rst_i,dat_i,sot_in,w_load);
    PINPUT1: sha1_process_input port map (clk_i,rst_i,w_pinput1,latch_pinput1,w_processed_input1,w_processed_valid1);
    PBUFFER1: sha1_process_buffer port map (clk_i,rst_i,w_processed_input1,w_processed_valid1,w_processed_valid1,w_processed_buffer,w_buffer_valid);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                latch_pinput1 <= '0';
                latch_pinput2 <= '0';
                latch_pinput3 <= '0';
                i <= 0;
                i_mux <= 0;
                for x in 0 to 15 loop
                    w_pinput1(x) <= "00000000000000000000000000000000";
                end loop;
            else
                if i = 80 then
                    i <= 0;
                --elsif i = 0 then
                --    latch_pinput <= '1';
                --    i <= i + 1;
                elsif i = 16 then
                    if i_mux = 2 then
                        i_mux <= 0;
                    else
                        i_mux <= i_mux + 1;
                    end if;
                    case i_mux is
                        when 0 => latch_pinput1 <= '1';
                        when 1 => latch_pinput2 <= '1';
                        when 2 => latch_pinput3 <= '1';
                    end case;
                    w_pinput1 <= w_load;
                    --i <= 0;
                    i <= i + 1;
                else
                    latch_pinput1 <= '0';
                    latch_pinput2 <= '0';
                    latch_pinput3 <= '0';
                    i <= i + 1;
                end if;
            end if;
            --Todo: fix this for multi-cycle SHA1 inputs
            if w_processed_valid1 = '1' then
                w_processed_new <= '1';
            else
                w_processed_new <= '0';
            end if;
        end if;
    end process;
    
    dat_1_o <= w_pinput1(15);
    test_sha1_process_input_o <= w_processed_input1(16);
    test_sha1_load_o <= w_load(15);

end RTL; 