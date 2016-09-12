--------------------------------------------------------------------------------
--                        gen_ssid.vhd
--    SSID generator for hardcoded benchmarking, because ZTEX interface is slow
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
use ieee.numeric_std.all;
use work.sha1_pkg.all;


entity gen_ssid is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    complete_o      : out    std_ulogic;
    dat_mk_o       : out    mk_data
    );
end gen_ssid;

architecture RTL of gen_ssid is

    signal w: w_input;
    signal w_temp: w_input;
    signal carry: std_ulogic;
    
    signal pmk : integer range 0 to 50; --Ten digit, hex (16^10)

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                pmk <= 0;
                complete_o <= '0';
            else
                if pmk = 50 then
                    pmk <= 0;
                    complete_o <= '1';
                else
                    pmk <= pmk + 1;
                    complete_o <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- Alt: generate statement
    dat_mk_o(0) <= to_unsigned(pmk,8);
    dat_mk_o(1) <= to_unsigned(pmk,16) sll 8;
 

end RTL; 