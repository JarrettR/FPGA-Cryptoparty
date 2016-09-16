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
    ssid_dat_i      : in    w_input;
    ssid_load_i     : in    std_ulogic;
    ssid_length_i   : in    integer range 0 to 63;
    mk_dat_i        : in    mk_data;
    mk_load_i       : in    std_ulogic;
    mk_length_i     : in    integer range 0 to 63;
    pmk_dat_o       : out   w_output;
    pmk_valid_o     : out   std_ulogic
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
    


end RTL; 