library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha1_test is

port(
    a : in  unsigned(31 downto 0);
    b : in  unsigned(31 downto 0);
    
    clk_i          : in    std_ulogic;
    rst_i          : in    std_ulogic;
    dat_i          : in    std_ulogic_vector(31 downto 0);
    sot_in         : in    std_ulogic;
    
    x : out unsigned(31 downto 0)
    );
end sha1_test;

architecture RTL of sha1_test is
begin

    process(a, b)   
    begin
	  x <= resize(a, x'length) + b; 
    end process;	

end RTL; 