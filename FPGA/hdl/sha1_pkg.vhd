--------------------------------------------------------------------------------
--                           sha1_pkg.vhd
--    Package containing custom types used in this project
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


package sha1_pkg is
  type w_full is array(0 to 79) of std_ulogic_vector(0 to 31);
  type w_input is array(0 to 15) of std_ulogic_vector(0 to 31);
  type w_output is array(0 to 4) of std_ulogic_vector(0 to 31);
  
  ---This may be temporary for benchmarking (enforces a pretty arbitrary input)
  type mk_data is array(0 to 9) of unsigned(0 to 3);
  type pmk_data is array(0 to 9) of unsigned(0 to 7);
end package sha1_pkg;