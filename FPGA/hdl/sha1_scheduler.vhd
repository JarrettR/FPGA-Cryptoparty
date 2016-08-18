library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity sha1_scheduler is

port(
    clk_i                       : in    std_ulogic;
    load_i                      : in    std_ulogic;
    rst_i                       : in    std_ulogic;
    dat_i                       : in    std_ulogic_vector(0 to 31);
    sot_in                      : in    std_ulogic;
    dat_1_o                     : out    std_ulogic_vector(0 to 31);
    dat_2_o                     : out    std_ulogic_vector(0 to 31);
    dat_3_o                     : out    std_ulogic_vector(0 to 31);
    test_sha1_process_input_o   : out    std_ulogic_vector(0 to 31);
    test_sha1_process_buffer0_o   : out    std_ulogic_vector(0 to 31);
    test_sha1_process_buffer_o   : out    std_ulogic_vector(0 to 31);
    test_sha1_load_o            : out    std_ulogic_vector(0 to 31)
    
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
        new_i          : in    std_ulogic;
        dat_w_o        : out    w_output;
        valid_o        : out    std_ulogic
    );
    end component;
   
    signal w_load: w_input;
    
    signal w_processed_input1: w_full;
    signal w_processed_input2: w_full;
    signal w_processed_input3: w_full;
    signal w_processed_input4: w_full;
    signal w_processed_input5: w_full;
    
    signal w_processed_new: std_ulogic;
    
    signal w_processed_buffer: w_output;
    signal w_processed_buffer1: w_output;
    signal w_processed_buffer2: w_output;
    signal w_processed_buffer3: w_output;
    signal w_processed_buffer4: w_output;
    signal w_processed_buffer5: w_output;
    
    signal w_buffer_valid1: std_ulogic;
    signal w_buffer_valid2: std_ulogic;
    signal w_buffer_valid3: std_ulogic;
    signal w_buffer_valid4: std_ulogic;
    signal w_buffer_valid5: std_ulogic;
    signal w_pinput: w_input;
    signal latch_pinput: std_ulogic_vector(0 to 4);
    signal w_processed_valid: std_ulogic_vector(0 to 4);
    signal i : integer range 0 to 16;
    
    signal i_mux : integer range 0 to 4;

begin

    LOAD1: sha1_load port map (clk_i,rst_i,dat_i,sot_in,w_load);
    
    PINPUT1: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(0),w_processed_input1,w_processed_valid(0));
    PBUFFER1: sha1_process_buffer port map (clk_i,rst_i,w_processed_input1,w_processed_valid(0),w_processed_valid(0),w_processed_buffer1,w_buffer_valid1);
    
    PINPUT2: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(1),w_processed_input2,w_processed_valid(1));
    PBUFFER2: sha1_process_buffer port map (clk_i,rst_i,w_processed_input2,w_processed_valid(1),w_processed_valid(1),w_processed_buffer2,w_buffer_valid2);
    
    PINPUT3: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(2),w_processed_input3,w_processed_valid(2));
    PBUFFER3: sha1_process_buffer port map (clk_i,rst_i,w_processed_input3,w_processed_valid(2),w_processed_valid(2),w_processed_buffer3,w_buffer_valid3);
    
    PINPUT4: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(3),w_processed_input4,w_processed_valid(3));
    PBUFFER4: sha1_process_buffer port map (clk_i,rst_i,w_processed_input4,w_processed_valid(3),w_processed_valid(3),w_processed_buffer4,w_buffer_valid4);
    
    PINPUT5: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(4),w_processed_input5,w_processed_valid(4));
    PBUFFER5: sha1_process_buffer port map (clk_i,rst_i,w_processed_input5,w_processed_valid(4),w_processed_valid(4),w_processed_buffer5,w_buffer_valid5);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                latch_pinput <= "00000";
                i <= 0;
                --Todo: start from 0 after testing
                i_mux <= 0;
                for x in 0 to 15 loop
                    w_pinput(x) <= "00000000000000000000000000000000";
                end loop;
            else
                if i = 15 then
                    case i_mux is
                        when 0 => latch_pinput <= "10000";
                        when 1 => latch_pinput <= "01000";
                        when 2 => latch_pinput <= "00100";
                        when 3 => latch_pinput <= "00010";
                        when 4 => latch_pinput <= "00001";
                    end case;
                    w_pinput <= w_load;
                    i <= 0;
                    --i <= i + 1;
                    if i_mux = 4 then
                        i_mux <= 0;
                    else
                        i_mux <= i_mux + 1;
                    end if;
                else
                    latch_pinput <= "00000";
                    i <= i + 1;
                end if;
            end if;
            --Todo: fix this for multi-cycle SHA1 inputs
            if w_processed_valid(0) = '1' then
                w_processed_buffer <= w_processed_buffer1;
            elsif w_processed_valid(1) = '1' then
                w_processed_buffer <= w_processed_buffer2;
            elsif w_processed_valid(2) = '1' then
                w_processed_buffer <= w_processed_buffer3;
            elsif w_processed_valid(3) = '1' then
                w_processed_buffer <= w_processed_buffer4;
            elsif w_processed_valid(4) = '1' then
                w_processed_buffer <= w_processed_buffer5;
            end if;
        end if;
    end process;
    
    dat_1_o <= w_pinput(15);
    test_sha1_process_input_o <= w_processed_input1(16);
    test_sha1_process_buffer0_o <= w_processed_buffer1(0);
    test_sha1_process_buffer_o <= w_processed_buffer(0);
    test_sha1_load_o <= w_load(15);

end RTL; 