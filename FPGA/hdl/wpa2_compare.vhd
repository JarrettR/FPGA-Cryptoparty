--------------------------------------------------------------------------------
--                        wpa2_compare.vhd
--    Calculates PRF with pairwise key expansion to compare against given MIC
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


entity wpa2_compare is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    cont_i          : in    std_ulogic;
    pmk_dat_i       : in    w_input;
    data_dat_i      : in    w_input;
    pke_dat_i       : in    w_input;
    mic_dat_i       : in    w_input;
    pmk_dat_o       : out   w_output;
    pmk_valid_o     : out   std_ulogic
    );
end wpa2_compare;

architecture RTL of wpa2_compare is
    
    signal w: w_input;
    signal w_temp: w_input;
    
    signal mk: w_input;
    signal pmk: w_input;
    signal ptk: w_input;
    
    signal mic: w_input;
    
    signal i : integer range 0 to 4;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                pmk_valid_o <= '0';
                i <= 0;
            else
                if cont_i = '1' then
                    if i < 4 then
                        --PKE -> PTK
                        --r = r . HMAC_SHA1(PMK, a . "\0" . b . chr(i));
                        i <= i + 1;
                    else
                        --PTK -> MIC
                        --mic = HMAC_SHA1(ptk[0:16], data[60:121]);
                        i <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;
    


end RTL; 