--------------------------------------------------------------------------------
--                        wpa2_main.vhd
--    Master file, starting PBKDF2 and cascading down
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


entity wpa2_main is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    dat_ssid_i      : in    std_ulogic_vector(0 to 31);
    valid_ssid_i    : in    std_ulogic;
    dat_mk_i        : in    std_ulogic_vector(0 to 31);
    valid_mk_i      : in    std_ulogic;
    dat_pmk_o       : out   w_output;
    valid_pmk_o     : out   std_ulogic
    );
end wpa2_main;

architecture RTL of wpa2_main is
    
    signal w: w_input;
    signal w_temp: w_input;
    
    signal mk: w_input;
    -- Max length of WPA2 will never go over two frames
    signal i : integer range 0 to 127;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
            else
                if i = 127 then
                    i <= 0;
                --elsif
                --    w_input <= 
                --    i <= i + 1;
                else
                    i <= i + 1;
                end if;
            end if;
        end if;
    end process;
    
    --Alt: Use a generate statement
    w_temp(0) <= dat_i;
    w_temp(1) <= w(1);
    w_temp(2) <= w(2);
    w_temp(3) <= w(3);
    w_temp(4) <= w(4);
    w_temp(5) <= w(5);
    w_temp(6) <= w(6);
    w_temp(7) <= w(7);
    w_temp(8) <= w(8);
    w_temp(9) <= w(9);
    w_temp(10) <= w(10);
    w_temp(11) <= w(11);
    w_temp(12) <= w(12);
    w_temp(13) <= w(13);
    w_temp(14) <= w(14);
    w_temp(15) <= w(15);

end RTL; 