library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sha1_pkg.all;

entity ztex_wrapper is
   port(
      pc      : in unsigned(7 downto 0);
      pb      : out std_logic_vector(7 downto 0);
      CS      : in std_logic;
      CLK     : in std_logic;
      rst_i     : in std_logic

--      SCL     : in std_logic;
--      SDA     : in std_logic
   );
end ztex_wrapper;


architecture RTL of ztex_wrapper is
    component gen_tenhex
    port(
        clk_i          : in    std_ulogic;
        rst_i          : in    std_ulogic;
        load_i          : in    std_ulogic;
        start_i          : in    std_ulogic;
        start_val_i    : in    mk_data;
        end_val_i    : in    mk_data;
        complete_o     : out    std_ulogic;
        dat_mk_o       : out    mk_data
    );
    end component;

	--signal declaration
	signal pb_buf : unsigned(7 downto 0);
   signal start: std_ulogic := '0';
	constant rst : unsigned(7 downto 0) := X"30";  -- Reset

begin
    pb <= std_logic_vector( pb_buf ) when CS = '1' else (others => 'Z');
	 
	 --gen1: gen_tenhex port map (CLK,rst_i,load_gen,start_gen,mk_initial,mk_end,gen_complete,mk);

    dpUCECHO: process(CLK)
    begin
        if CLK' event and CLK = '1' then
            if pc = rst then
                start <= '1';
            elsif ( pc >= 97 ) and ( pc <= 122) then
                pb_buf <= pc - 32;
            else
					if start = '1' then
						 pb_buf <= x"31";
						 start <= '0';
					else
						 pb_buf <= x"30";
					end if;
            end if;
        end if;
    end process dpUCECHO;
    
end RTL;
