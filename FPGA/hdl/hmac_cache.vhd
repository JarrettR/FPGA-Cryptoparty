--------------------------------------------------------------------------------
--                               hmac_cache.vhd
--    Calculates and caches initial SHA1 H0-H5 vars for HMAC algorithm
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


entity hmac_cache is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    secret_i        : in    std_ulogic_vector(0 to 31);
    load_i          : in    std_ulogic;
    dat_bi_o        : out    w_input;
    dat_h_o         : out    w_output;
    valid_o         : out    std_ulogic  
    );
end hmac_cache;

architecture RTL of hmac_cache is
    
    signal bi: w_input;
    signal bo: w_output;
    signal i : integer range 0 to 15;

begin
    process(clk_i)   
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                i <= 0;
                valid_o <= '0';
            else
                if load_i = '1' then
                    bi(i) <= X"36363636" xor secret_i;
                    bo(i) <= X"5c5c5c5c" xor secret_i;
                end if;
                if i = 15 then
                    valid_o <= '1';
                 else
                    i <= i + 1;
                    valid_o <= '0';
                end if;
            end if;
        end if;
    end process;
    
    dat_bi_o <= bi;

end RTL; 