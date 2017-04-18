library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.sha1_pkg.all;

entity ztex_wrapper is
   port(
      pc      : in std_logic_vector(7 downto 0);
      pb      : out std_logic_vector(7 downto 0);
      CS      : in std_logic;
      CLK     : in std_logic;
      sck_i     : in std_logic;
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
	 component fx2_fifo
	 port (
		 rst    : in std_logic;
		 wr_clk : in std_logic;
		 rd_clk : in std_logic;
		 din    : in std_logic_vector(7 downto 0);
		 wr_en  : in std_logic;
		 rd_en  : in std_logic;
		 dout   : out std_logic_vector(7 downto 0);
		 full   : out std_logic;
		 empty  : out std_logic
	);
	end component;

	--signal declaration
	signal dat_in : std_logic_vector(7 downto 0);
	signal pb_buf : std_logic_vector(7 downto 0);
   signal start: std_ulogic := '0';
   signal wr_en: std_ulogic := '0';
   signal rd_en: std_ulogic := '0';
   signal full: std_ulogic := '0';
   signal empty: std_ulogic := '0';
   signal count: integer range 0 to 4;
	--constant rst : unsigned(7 downto 0) := X"30";  -- Reset
	
	type in_type is array (0 to 4) of unsigned(7 downto 0);
   signal input: in_type;
	
   type state_type is (STATE_ERROR,
                        STATE_READY,
                        STATE_INPUT,
                        STATE_WORKING,
                        STATE_FINISH_FAIL,
                        STATE_FINISH_SUCCEED
							);
   
   signal state          : state_type := STATE_ERROR;
   type command_type is (CMD_ERROR,
                      CMD_INPUT,
					  		 CMD_STATUS,
							 CMD_ABORT,
							 CMD_OUTPUT
							 );
   
   signal command          : command_type := CMD_ERROR;

begin
    pb <= std_logic_vector( pb_buf ) when CS = '1' else (others => 'Z');
	 
	 --gen1: gen_tenhex port map (CLK,rst_i,load_gen,start_gen,mk_initial,mk_end,gen_complete,mk);
	 input_fifo : fx2_fifo
	  port map (
		 rst => rst_i,
		 wr_clk => sck_i,
		 rd_clk => CLK,
		 din => pc,
		 wr_en => wr_en,
		 rd_en => rd_en,
		 dout => dat_in,
		 full => full,
		 empty => empty
	  );
	  
	  
    dpUCECHO: process(CLK)
    begin
        if CLK' event and CLK = '1' then
            if rst_i = '0' then
                start <= '1';
                wr_en <= '1';
                pb_buf <= x"30";
					 count <= 0;
					 state <= STATE_READY; 
					 for i in 0 to 4 loop
                    input(i) <= "00000000";
                end loop;
					 state <= STATE_READY;
            elsif ( empty = '0') then
                pb_buf <= dat_in - 32;
					 state <= STATE_READY;
            elsif ( unsigned(dat_in) >= 97 ) and ( unsigned(dat_in) <= 122) then
                pb_buf <= dat_in - 32;
					 state <= STATE_READY;
            else
                if state = STATE_READY then
                    if pc = X"31" then
                        pb_buf <= x"3E"; -- >
                        state <= STATE_INPUT;
                        count <= 0;
						  else
                        pb_buf <= x"3F"; -- ?
                    end if;
                elsif state = STATE_INPUT then
                    input(count) <= unsigned(pc);
                    pb_buf <= x"2E"; -- .
                    if count < 4 then
                        count <= count + 1;
                    else
                        count <= 0;
                        state <= STATE_WORKING;
                    end if;
                elsif state = STATE_WORKING then
                    pb_buf <= X"6F";
                    if count < 4 then
                        count <= count + 1;
                    else
                        count <= 0;
                        state <= STATE_FINISH_SUCCEED;
                    end if;
                elsif state = STATE_FINISH_FAIL then
                    pb_buf <= X"58";
                elsif state = STATE_FINISH_SUCCEED then
                    pb_buf <= X"58";-- <= input(count);
                    --if count < 4 then
                    --    count <= count + 1;
                    --else
                     --   count <= 0;
                    --    state <= STATE_FINISH_SUCCEED;
                    --end if;
                else
                    pb_buf <= dat_in;-- <= input(count);
						  state <= STATE_READY;
                    case pc is
                      when X"31" =>   command <= CMD_INPUT;
                      when X"32" =>   command <= CMD_STATUS;
                      when X"33" =>   command <= CMD_ABORT;
                      when X"34" =>   command <= CMD_OUTPUT;
                      when others => command <= CMD_ERROR;
                    end case;
                end if;
                --case pc is
                --  when X"31" =>   state <= STATE_READY;
                --  when X"32" =>   state <= STATE_WORKING;
                --  when others => state <= STATE_ERROR;
                --end case;
                --case state is
                --  when STATE_READY =>     pb_buf <= x"35";
                --  when STATE_WORKING =>   pb_buf <= x"36";
                --  when others => pb_buf <= x"32";
                --end case;
            end if;
				
				--count <= count + '1';
        end if;
    end process dpUCECHO;
    
end RTL;
