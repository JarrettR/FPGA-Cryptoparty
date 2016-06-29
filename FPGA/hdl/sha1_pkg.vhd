library ieee;
use ieee.std_logic_1164.all;


package sha1_pkg is
  type w_type is array(0 to 79) of std_ulogic_vector(0 to 31);
end package sha1_pkg;