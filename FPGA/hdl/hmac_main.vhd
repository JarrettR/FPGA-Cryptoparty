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
    dat_o           : out    w_output;
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
                        STATE_BO1_LOAD_ON, STATE_BO1_LOAD_OFF,
                        STATE_BO1_PROCESS,
                        STATE_BO2_LOAD_ON, STATE_BO2_LOAD_OFF,
                        STATE_BO2_PROCESS,
                        STATE_FINISHED);
    
    signal state           : state_type := STATE_IDLE;
        
    --signal dat_bi                   :    w_input;
    signal bi_buffer_dat        :    w_output;
    
    signal process_in                   :    w_input;
    signal processed_input_load    :    std_ulogic;
    signal processed_input        :    w_full;
    signal processed_valid        :    std_ulogic;
    signal processed_new        :    std_ulogic;
    signal buffer_in        :    w_output;
    signal buffer_dat        :    w_output;
    signal buffer_valid        :    std_ulogic;
     
    signal i: integer range 0 to 65535;

begin

    PINPUT: sha1_process_input port map (clk_i,rst_i,process_in,processed_input_load,processed_input,processed_valid);
    PBUFFER: sha1_process_buffer port map (clk_i,rst_i,processed_input,processed_valid,processed_new,buffer_in,buffer_dat,buffer_valid);

    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                state <= STATE_IDLE;
                processed_input_load <= '0';
                processed_new <= '1';
                valid_o <= '0';
            elsif load_i = '1' and state = STATE_IDLE then
                processed_new <= '1';
                for x in 0 to 15 loop
                    process_in(x) <= X"36363636" xor secret_i(x);
                end loop;
                state <= STATE_BI1_LOAD_ON;
            elsif state = STATE_BI1_LOAD_ON then
                processed_input_load <= '1';
                state <= STATE_BI1_LOAD_OFF;
            elsif state = STATE_BI1_LOAD_OFF then
                processed_input_load <= '0';
                state <= STATE_BI1_PROCESS;
            elsif buffer_valid = '1' and state = STATE_BI1_PROCESS then
                processed_new <= '0';
                buffer_in <= buffer_dat;
                for x in 0 to 13 loop
                    process_in(x) <= value_i(x);
                end loop;
                --Todo:
                --This is needs the 0x80 frame end flag
                process_in(14) <= value_len_i(0 to 31);
                process_in(15) <= value_len_i(32 to 63);
                state <= STATE_BI2_LOAD_ON;
            elsif state = STATE_BI2_LOAD_ON then
                processed_input_load <= '1';
                state <= STATE_BI2_LOAD_OFF;
            elsif state = STATE_BI2_LOAD_OFF then
                processed_input_load <= '0';
                state <= STATE_BI2_PROCESS;
                
                --Inner done
            elsif buffer_valid = '1' and state = STATE_BI2_PROCESS then
                processed_input_load <= '0';
                processed_new <= '1';
                
                bi_buffer_dat <= buffer_dat;
                
                for x in 0 to 15 loop
                    process_in(x) <= X"5c5c5c5c" xor secret_i(x);
                end loop;
                state <= STATE_BO1_LOAD_ON;
            elsif state = STATE_BO1_LOAD_ON then
                processed_input_load <= '1';
                state <= STATE_BO1_LOAD_OFF;
            elsif state = STATE_BO1_LOAD_OFF then
                processed_input_load <= '0';
                state <= STATE_BO1_PROCESS;
            elsif buffer_valid = '1' and state = STATE_BO1_PROCESS then
                processed_new <= '0';
                buffer_in <= buffer_dat;
                for x in 0 to 4 loop
                    process_in(x) <= bi_buffer_dat(x);
                end loop;
                --0x80 frame end flag is always the same here
                process_in(5) <= X"80000000";
                for x in 6 to 14 loop
                    process_in(x) <= X"00000000";
                end loop;
                process_in(15) <= X"000002A0";
                
                state <= STATE_BO2_LOAD_ON;
            elsif state = STATE_BO2_LOAD_ON then
                processed_input_load <= '1';
                state <= STATE_BO2_LOAD_OFF;
            elsif state = STATE_BO2_LOAD_OFF then
                processed_input_load <= '0';
                state <= STATE_BO2_PROCESS;
            elsif buffer_valid = '1' and state = STATE_BO2_PROCESS then
                processed_input_load <= '0';
                
                dat_o <= buffer_dat;
                valid_o <= '1';
                state <= STATE_FINISHED;
            elsif state = STATE_FINISHED then
                valid_o <= '0';
                state <= STATE_IDLE;
            --else
            --    i <= i + 1;
            end if;
            i <= i + 1;
        end if;
    end process;

end RTL; 