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
    load_i           : in    std_ulogic;
    start_i           : in    std_ulogic;
    start_val_i     : in    mk_data;
    end_val_i       : in    mk_data;
    complete_o      : out    std_ulogic := '0';
    dat_mk_o        : out    mk_data
    );
end gen_tenhex;

architecture RTL of gen_tenhex is

    signal w: w_input;
    signal w_temp: w_input;
    
    signal complete: std_ulogic := '0';
    signal running: std_ulogic := '0';
    
    signal carry: unsigned(0 to 10) := "00000000001";

    --Ten digit, hex (16^10)
    signal mk :  mk_data := (others => "00000000");
    signal mk_end :  mk_data := (others => "00000000");
    
    signal mk_next :  mk_data := (others => "00000000");
    
begin
    process(clk_i)   
    variable continue_carry: std_ulogic;
    variable complete_v: std_ulogic;
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                complete <= '0';
                running <= '0';
            elsif load_i = '1' then
                for i in 0 to 9 loop
                    --Todo: fix to start_val_i and end_val_i
                    mk(i) <= start_val_i(i);
                    mk_end(i) <= end_val_i(i);
                    --mk(i) <= start_val(i);
                    --mk_end(i) <= end_val(i);
                end loop;
            elsif start_i = '1' then
                running <= '1';
            elsif running = '1' then
                complete_v := '1';
                for i in 9 downto 0 loop
                    if mk(i) /= mk_end(i) then
                        complete_v := '0';
                    end if;
                end loop;
                if complete_v = '0' then
                    for i in 9 downto 0 loop
                        if carry(i + 1) = '1' and continue_carry = '1' then
                            mk(i) <= mk_next(i);
                        else
                            continue_carry := '0';
                        end if;
                    end loop;
                    continue_carry := '1';
                end if;
                complete <= complete_v;
                running <= not complete_v;
            end if;
        end if;
    end process;
    
    dat_mk_o <= mk;
    complete_o <= complete;
    
    mk_inc: for i in 9 downto 0 generate
    begin
        with mk(i) select mk_next(i) <=
                     X"61" when X"39",
                     X"30" when X"66",
                     mk(i) + 1 when others;
        with mk(i) select carry(i) <=
                     '1' when X"66",
                     '0' when others;
    end generate mk_inc;

end RTL; 