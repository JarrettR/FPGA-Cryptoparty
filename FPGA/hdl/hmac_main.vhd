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
    value_len_i     : in    std_ulogic_vector(0 to 63);
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
    
    type state_type is (STATE_IDLE,
                        STATE_BI1_LOAD_ON, STATE_BI1_LOAD_OFF,
                        STATE_BI1_PROCESS,
                        STATE_BI2_LOAD_ON, STATE_BI2_LOAD_OFF,
                        STATE_BI2_PROCESS,
                        STATE_WHAT);
    
    signal state           : state_type := STATE_IDLE;
        
    signal dat_bi                   :    w_input;
    signal bi_processed_input_load    :    std_ulogic;
    signal bi_processed_input        :    w_full;
    signal bi_processed_valid        :    std_ulogic;
    signal bi_processed_new        :    std_ulogic;
    signal bi_buffer_in        :    w_output;
    signal bi_buffer_dat        :    w_output;
    signal bi_buffer_valid        :    std_ulogic;
    
    signal dat_bo                   :    w_input;
    signal bo_processed_input_load    :    std_ulogic;
    signal bo_processed_input        :    w_full;
    signal bo_processed_valid        :    std_ulogic;
    signal bo_processed_new        :    std_ulogic;
    signal bo_buffer_in        :    w_output;
    signal bo_buffer_dat        :    w_output;
    signal bo_buffer_valid        :    std_ulogic;
    
     
    signal i: integer range 0 to 65535;

begin

    --LOAD1: hmac_load port map (clk_i,rst_i,dat_i,w_pad_bi,sot_in,w_load);
    --LOAD2: hmac_load port map (clk_i,rst_i,dat_i,w_pad_bo,sot_in,w_load);
    
    --Alt: Use a generate statement
    --Inner HMAC
    PINPUT_I1: sha1_process_input port map (clk_i,rst_i,dat_bi,bi_processed_input_load,bi_processed_input,bi_processed_valid);
    PBUFFER_I1: sha1_process_buffer port map (clk_i,rst_i,bi_processed_input,bi_processed_valid,bi_processed_new,bi_buffer_in,bi_buffer_dat,bi_buffer_valid);
    
    --Outer HMAC
    --PINPUT_O1: sha1_process_input port map (clk_i,rst_i,dat_bo,bo_processed_input_load,bo_processed_input,bo_processed_valid);
    --PBUFFER_O1: sha1_process_buffer port map (clk_i,rst_i,bo_processed_input,bo_processed_valid,bo_processed_new,bo_buffer_in,bo_buffer_dat,bo_buffer_valid);
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                state <= STATE_IDLE;
                bi_processed_input_load <= '0';
                bi_processed_new <= '1';
                valid_o <= '0';
            elsif load_i = '1' then
                for x in 0 to 15 loop
                    dat_bi(x) <= X"36363636" xor secret_i(x);
                    dat_bo(x) <= X"5c5c5c5c" xor secret_i(x);
                end loop;
                state <= STATE_BI1_LOAD_ON;
            elsif state = STATE_BI1_LOAD_ON then
                bi_processed_input_load <= '1';
                state <= STATE_BI1_LOAD_OFF;
            elsif state = STATE_BI1_LOAD_OFF then
                bi_processed_input_load <= '0';
                state <= STATE_BI1_PROCESS;
            elsif bi_buffer_valid = '1' and state = STATE_BI1_PROCESS then
                bi_processed_new <= '0';
                bi_buffer_in <= bi_buffer_dat;
                for x in 0 to 13 loop
                    dat_bi(x) <= value_i(x);
                end loop;
                --Todo:
                --This is needs the 0x80 frame end flag
                dat_bi(14) <= value_len_i(0 to 31);
                dat_bi(15) <= value_len_i(32 to 63);
                state <= STATE_BI2_LOAD_ON;
            elsif state = STATE_BI2_LOAD_ON then
                bi_processed_input_load <= '1';
                state <= STATE_BI2_LOAD_OFF;
            elsif state = STATE_BI2_LOAD_OFF then
                bi_processed_input_load <= '0';
                state <= STATE_BI2_PROCESS;
                
                --Inner done
            elsif bi_buffer_valid = '1' and state = STATE_BI2_PROCESS then
                bo_processed_input_load <= '0';
                bo_processed_new <= '1';
                state <= STATE_BO1_LOAD_ON;
            elsif state = STATE_BO1_LOAD_ON then
                bo_processed_input_load <= '1';
                state <= STATE_BI1_LOAD_OFF;
            elsif state = STATE_BO1_LOAD_OFF then
                bi_processed_input_load <= '0';
            state <= STATE_BI1_PROCESS;
                state <= STATE_WHAT;
            --else
            --    i <= i + 1;
            end if;
            i <= i + 1;
        end if;
    end process;

end RTL; 