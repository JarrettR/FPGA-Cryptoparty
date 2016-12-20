--------------------------------------------------------------------------------
--  This is the main HMAC algorithm body
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


entity hmac_main is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    secret_i        : in    w_input;
    value_i         : in    w_input;
    load_i          : in    std_ulogic;
    dat_o           : out    w_input;
    valid_o         : out    std_ulogic
    );
end hmac_main;

architecture RTL of hmac_main is 

   component sha1_process_input
    port(
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        dat_i          : in    w_input;
        load_i         : in    std_ulogic;
        dat_w_o          : out    w_full;
        valid_o          : out    std_ulogic
        );
    end component;
    
   component sha1_process_buffer
    port(
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
    
    signal dat_bi                   :    w_input;
    signal bi_processed_input_load    :    std_ulogic;
    signal bi_processed_input        :    w_full;
    signal bi_processed_valid        :    std_ulogic;
    signal bi_processed_new        :    std_ulogic;
    signal bi_buffer_dat        :    w_output;
    signal bi_buffer_valid        :    std_ulogic;
    
     
    signal dat_bo                   :    w_input;
        signal i: integer range 0 to 65535;

begin

    --LOAD1: hmac_load port map (clk_i,rst_i,dat_i,w_pad_bi,sot_in,w_load);
    --LOAD2: hmac_load port map (clk_i,rst_i,dat_i,w_pad_bo,sot_in,w_load);
    
    --Alt: Use a generate statement
    --Inner HMAC
    PINPUT_I1: sha1_process_input port map (clk_i,rst_i,dat_bi,bi_processed_input_load,bi_processed_input,bi_processed_valid);
    PBUFFER_I1: sha1_process_buffer port map (clk_i,rst_i,bi_processed_input,bi_processed_valid,bi_processed_new,bi_buffer_dat,bi_buffer_valid);
    
    --Outer HMAC
    --PINPUT_O1: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(0),w_processed_input1,w_processed_valid(0));
    --PBUFFER_O1: sha1_process_buffer port map (clk_i,rst_i,w_processed_input1,w_processed_valid(0),w_processed_valid(0),w_processed_buffer1,w_buffer_valid1);
    
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                bi_process_input_load <= 0;
                bi_processed_new <= 1;
            elsif load_i = '1' then
                for x in 0 to 15 loop
                    dat_bi(x) <= X"36363636" xor secret_i(x);
                    dat_bo(x) <= X"5c5c5c5c" xor secret_i(x);
                end loop;
                i <= 1;
            elsif i = 1 then
                bi_process_input_load <= 1;
                i <= 2;
            elsif i = 2 then
                bi_process_input_load <= 0;
                i <= 3;
            elsif bi_buffer_valid = '1' and i = 3 then
                bi_process_input_load <= 0;
                bi_processed_new <= 0;
                for x in 0 to 12 loop
                    dat_bi(x) <= value_i(x);
                end loop;
                dat_bi(13) <= X"80000000";
                dat_bi(14) <= X"00000000";
                dat_bi(15) <= X"00000140"; --This is definitely wrong atm
                i <= 4;
            elsif i = 4 then
                bi_process_input_load <= 1;
                i <= 5;
            elsif i = 5 then
                bi_process_input_load <= 0;
                i <= 6;
            --else
            --    i <= i + 1;
            end if;
        end if;
    end process;

end RTL; 