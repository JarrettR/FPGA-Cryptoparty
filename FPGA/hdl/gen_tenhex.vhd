--------------------------------------------------------------------------------
--                        gen_tenhex.vhd
--    Test 10-digit hex sample PMK generator, because the ZTEX comm bus is slow
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


entity gen_tenhex is

port(
    clk_i           : in    std_ulogic;
    rst_i           : in    std_ulogic;
    start_val_i     : in    mk_data;
    init_load_i     : in    std_ulogic;
    complete_o      : out    std_ulogic;
    dat_mk_o        : out    mk_data
    );
end gen_tenhex;

architecture RTL of gen_tenhex is

    signal w: w_input;
    signal w_temp: w_input;
    
    --Ten digit, hex (16^10)
    signal mk :  mk_data := (others => "00000000");
    
begin
    process(clk_i)   
    variable carry: std_ulogic;
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                complete_o <= '0';
                carry := '0';
                if init_load_i = '1' then
                    for i in 0 to 9 loop
                        mk(i) <= start_val_i(i);
                    end loop;
                else
                    for i in 0 to 9 loop
                        mk(i) <= X"30";
                    end loop;
                end if;
                
                -- mk(0) <= "0000";
                -- mk(1) <= "0000";
                -- mk(2) <= "0000";
                -- mk(3) <= "0000";
                -- mk(4) <= "0000";
                -- mk(5) <= "0000";
                -- mk(6) <= "0000";
                -- mk(7) <= "0000";
                -- mk(8) <= "0000";
                -- mk(9) <= "0000";
            else
                for i in 9 downto 0 loop
                    if carry = '1' or i = 9 then
                        if mk(i) = X"39" then
                            mk(i) <= X"61";
                            carry := '0';
                        elsif mk(i) = X"66" then
                            mk(i) <= X"30";
                            carry := '1';
                        else
                            mk(i) <= mk(i) + 1;
                            carry := '0';
                        end if;
                    end if;
                end loop;
            end if;
        end if;
    end process;
    
    dat_mk_o <= mk;
    -- Int to ascii
    --gen_mk: for i in 0 to 9 generate
    --begin
    --    dat_mk_o(i) <= mk(i) + X"57" when mk(i) > 9 else
    --                  mk(i) + X"30" when mk(i) <= 9 else
    --                   X"30";
    --end generate gen_mk;

end RTL; 