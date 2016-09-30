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
use ieee.numeric_std.all;
use work.sha1_pkg.all;


entity wpa2_compare is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    mk_dat_i        : in    mk_data;
    data_dat_i      : in    w_input;
    pke_dat_i       : in    w_input;
    mic_dat_i       : in    w_input;
    pmk_dat_o       : out   pmk_data;
    pmk_valid_o     : out   std_ulogic
    );
end wpa2_compare;

architecture RTL of wpa2_compare is
    
    signal mk: mk_data;
    signal pmk: w_input;
    signal ptk: w_input;
    
    signal mic: w_input;
    
    signal pmk_found: std_ulogic;
    
    signal i : integer range 0 to 4;

--We're gonna use this for benchmarking the host software for now
begin
    process(clk_i)   
    variable pmk_found_var: std_ulogic;
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                pmk_found <= '0';
                pmk_found_var := '0';
                i <= 0;
                mk(0) <= "00110000"; --0x30, char 0
                mk(1) <= "00110110"; --0x33, char 3
                mk(2) <= "00000000";
                mk(3) <= "00000000";
                mk(4) <= "00000000";
                mk(5) <= "00000000";
                mk(6) <= "00000000";
                mk(7) <= "00000000";
                mk(8) <= "00000000";
                mk(9) <= "00000000";
            else
                if pmk_found = '0' then
                    pmk_found_var := '1';
                    for i in 0 to 9 loop
                        if mk(i) /= mk_dat_i(i) then
                            pmk_found_var := '0';
                        end if;
                    end loop;
                    
                    if pmk_found_var = '1' then
                        pmk_found <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    

    pmk_valid_o <= pmk_found;

end RTL; 

--The real meat
-- begin
    -- process(clk_i)   
    -- begin
        -- if (clk_i'event and clk_i = '1') then
            -- if rst_i = '1' then
                -- pmk_valid_o <= '0';
                -- i <= 0;
            -- else
                -- if cont_i = '1' then
                    -- if i < 4 then
                        -- --PKE -> PTK
                        -- --r = r . HMAC_SHA1(PMK, a . "\0" . b . chr(i));
                        -- i <= i + 1;
                    -- else
                        -- --PTK -> MIC
                        -- --mic = HMAC_SHA1(ptk[0:16], data[60:121]);
                        -- i <= 0;
                    -- end if;
                -- end if;
            -- end if;
        -- end if;
    -- end process;
    


-- end RTL; 