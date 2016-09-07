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
    dat_bi_i        : in    w_input;
    dat_bo_i        : in    w_input;
    value_i         : in    std_ulogic_vector(0 to 31);
    value_load_i    : in    std_ulogic;
    dat_bi_o        : out    w_input;
    dat_bo_o        : out    w_input;
    valid_o         : out    std_ulogic
    
    );
end hmac_main;

architecture RTL of hmac_main is
    
     
    -- synthesis translate_off
    signal test_hmac1_o   : std_ulogic_vector(0 to 31);
    signal test_hmac2_o   : std_ulogic_vector(0 to 31);
    signal test_hmac3_o   : std_ulogic_vector(0 to 31);
    signal test_hmac4_o   : std_ulogic_vector(0 to 31);
    -- synthesis translate_on

begin

    LOAD1: hmac_load port map (clk_i,rst_i,dat_i,w_pad_bi,sot_in,w_load);
    LOAD2: hmac_load port map (clk_i,rst_i,dat_i,w_pad_bo,sot_in,w_load);
    
    --Alt: Use a generate statement
    --Inner HMAC
    PINPUT_I1: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(0),w_processed_input1,w_processed_valid(0));
    PBUFFER_I1: sha1_process_buffer port map (clk_i,rst_i,w_processed_input1,w_processed_valid(0),w_processed_valid(0),w_processed_buffer1,w_buffer_valid1);
    
    --Inner HMAC
    PINPUT_I1: sha1_process_input port map (clk_i,rst_i,w_pinput,latch_pinput(0),w_processed_input1,w_processed_valid(0));
    PBUFFER_I1: sha1_process_buffer port map (clk_i,rst_i,w_processed_input1,w_processed_valid(0),w_processed_valid(0),w_processed_buffer1,w_buffer_valid1);
    
    
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                for x in 0 to 15 loop
                    bi(x) <= X"36363636";
                    bo(x) <= X"5c5c5c5c";
                end loop;
                i <= 0;
            --else
                --if secret_load_i = '1' then
                --    bi
            end if;
        end if;
    end process;
    --dat_w_o <= w_temp;
    
    --w_temp(0) <= dat_i;
    --w_temp(1) <= w(1);
    --w_temp(2) <= w(2);
    --w_temp(3) <= w(3);
    --w_temp(4) <= w(4);
    --w_temp(5) <= w(5);
    --w-_temp(6) <= w(6);
    --w_temp(7) <= w(7);
    --w_temp(8) <= w(8);
    --w_temp(9) <= w(9);
   -- w_temp(10) <= w(10);
    ---w_temp(11) <= w(11);
    --w_temp(12) <= w(12);
    --w_temp(13) <= w(13);
    --w_temp(14) <= w(14);
    --w_temp(15) <= w(15);

end RTL; 