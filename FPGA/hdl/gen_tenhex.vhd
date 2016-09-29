--------------------------------------------------------------------------------
--                        gen_tenhex.vhd
--    Test 10-digit hex sample PMK generator, because the ZTEX interface is slow
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
    start_val_i     : in    std_ulogic; --Todo: make this work
    complete_o      : out    std_ulogic;
    dat_mk_o        : out    mk_data
    );
end gen_tenhex;

architecture RTL of gen_tenhex is

    signal w: w_input;
    signal w_temp: w_input;
    
    --Ten digit, hex (16^10)
    type mk_int_data is array(0 to 9) of unsigned(0 to 3);
    signal mk :  mk_int_data;
    
    signal mk_dat_test :  unsigned(0 to 7);
    
    signal mk_test0 :  unsigned(0 to 3);
    signal mk_test1 :  unsigned(0 to 3);
    signal mk_test2 :  unsigned(0 to 3);
    signal mk_test3 :  unsigned(0 to 3);
    signal mk_test4 :  unsigned(0 to 3);
    signal mk_test5 :  unsigned(0 to 3);
    signal mk_test6 :  unsigned(0 to 3);
    signal mk_test7 :  unsigned(0 to 3);
    signal mk_test8 :  unsigned(0 to 3);
    signal mk_test9 :  unsigned(0 to 3);

begin
    process(clk_i)   
    variable carry: std_ulogic;
    begin
        if (clk_i'event and clk_i = '1') then
            if rst_i = '1' then
                --mk <= 0;
                complete_o <= '0';
                carry := '0';
                -- Todo: fix this, this is terrible
                mk(0) <= "0000";
                mk(1) <= "0000";
                mk(2) <= "0000";
                mk(3) <= "0000";
                mk(4) <= "0000";
                mk(5) <= "0000";
                mk(6) <= "0000";
                mk(7) <= "0000";
                mk(8) <= "0000";
                mk(9) <= "0000";
            else
                for i in 0 to 10 loop
                    if i = 0 then
                        if mk(0) = "1111" then
                            mk(0) <= "0000";
                            carry := '1';
                        else
                            mk(0) <= mk(0) + 1;
                            carry := '0';
                        end if;
                    elsif i = 10 and carry = '1' then
                        complete_o <= '1';
                    elsif carry = '1' then
                        if mk(i) = "1111" then
                            mk(i) <= "0000";
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
    
    -- Int to ascii
    gen_mk: for i in 0 to 9 generate
    begin
        dat_mk_o(i) <= mk(i) + X"57" when mk(i) > 9 else mk(i) + X"30";
    end generate gen_mk;
    

    mk_dat_test <= mk(0) + X"57" when mk(0) > 9 else mk(0) + X"30";
    
    
    mk_test0 <= mk(0);
    mk_test1 <= mk(1);
    mk_test2 <= mk(2);
    mk_test3 <= mk(3);
    mk_test4 <= mk(4);
    mk_test5 <= mk(5);
    mk_test6 <= mk(6);
    mk_test7 <= mk(7);
    mk_test8 <= mk(8);
    mk_test9 <= mk(9);

end RTL; 