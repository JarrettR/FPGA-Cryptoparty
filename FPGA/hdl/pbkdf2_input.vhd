--------------------------------------------------------------------------------
--  Scheduler for running 5 concurrent SHA1 calcs and outputting sequentially
--    Copyright (C) 2016  Jarrett Rainier
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.sha1_pkg.all;


entity pbkdf2_input is

port(
    clk_i               : in    std_ulogic;
    load_i              : in    std_ulogic;
    rst_i               : in    std_ulogic;
    secret_i            : in    std_ulogic_vector(0 to 31);
    secret_cache_o      : out    w_output;
    x1_o                : out    std_ulogic_vector(0 to 31);
    x2_o                : out    std_ulogic_vector(0 to 31)    
    );
end pbkdf2_input;

architecture RTL of pbkdf2_input is
    component hmac_cache
    port(
        clk_i           : in    std_ulogic;
        rst_i           : in    std_ulogic;
        secret_i        : in    std_ulogic_vector(0 to 31);
        load_i          : in    std_ulogic;
        dat_bi_o        : out    w_input;
        dat_h_o         : out    w_output;
        valid_o         : out    std_ulogic  
        );
    end component;
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
        dat_w_i        : in    w_output;
        dat_w_o        : out    w_output;
        valid_o        : out    std_ulogic
    );
    end component;
   
    signal w_load: w_input;
    
    signal w_processed_input: w_full;
    
    signal w_processed_new: std_ulogic;
    
    signal w_processed_buffer: w_output;
    signal w_processed_buffer1: w_output;
    
    signal w_buffer_valid: std_ulogic;
    signal w_pinput: w_input;
    signal latch_pinput: std_ulogic_vector(0 to 4);
    signal w_processed_valid: std_ulogic;
    signal i : integer range 0 to 16;
    
    signal i_mux : integer range 0 to 4;
    
    -- synthesis translate_off
    signal test_sha1_process_input_o     : std_ulogic_vector(0 to 31);
    signal test_sha1_process_buffer0_o   : std_ulogic_vector(0 to 31);
    signal test_sha1_process_buffer_o    : std_ulogic_vector(0 to 31);
    signal test_sha1_load_o              : std_ulogic_vector(0 to 31);
    -- synthesis translate_on

begin

    LOAD: sha1_load port map (clk_i,rst_i,dat_i,sot_in,w_load);
    
    PINPUT: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(0),w_processed_input,w_processed_valid);
    PBUFFER: sha1_process_buffer port map (clk_i,rst_i,w_processed_input,w_processed_valid,w_processed_valid,w_processed_buffer1,w_processed_buffer1,w_buffer_valid);
    
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
            --Alt: Consider other conditionals
            if w_processed_valid = '1' then
                w_processed_buffer <= w_processed_buffer1;
            end if;
        end if;
    end process;
    
    dat_1_o <= w_pinput(15);
    
    -- synthesis translate_off
    test_sha1_process_input_o <= w_processed_input(16);
    test_sha1_process_buffer0_o <= w_processed_buffer1(0);
    test_sha1_process_buffer_o <= w_processed_buffer(0);
    test_sha1_load_o <= w_load(15);
    -- synthesis translate_on

end RTL; 