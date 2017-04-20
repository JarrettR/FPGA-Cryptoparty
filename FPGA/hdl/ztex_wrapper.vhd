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
        load_i         : in    std_ulogic;
        start_i        : in    std_ulogic;
        start_val_i    : in    mk_data;
        end_val_i      : in    mk_data;
        complete_o     : out    std_ulogic;
        dat_mk_o       : out    mk_data
    );
    end component;

	--signal declaration
    signal pb_buf : std_logic_vector(7 downto 0);
    signal in_buf : std_logic_vector(7 downto 0);
    signal load: std_ulogic := '0';
    signal count: integer range 0 to (MK_SIZE * 2) + 1;
    --constant rst : unsigned(7 downto 0) := X"30";  -- Reset

    --gen_tenhex helpers
    signal load_gen: std_ulogic := '0';
    signal start_gen: std_ulogic := '0';
    signal gen_complete: std_ulogic := '0';
    signal mk_initial: mk_data;
    signal mk_end: mk_data;
    signal mk: mk_data;
    signal mk_read: mk_data;

    type in_type is array (0 to (MK_SIZE * 2) + 1) of unsigned(7 downto 0);
    signal input: in_type;
	
    type state_type is (STATE_ERROR,
                        STATE_READY,
                        STATE_INPUT,
                        STATE_READ_INPUT,
                        STATE_READ_PROGRESS,
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
    mk_initial <= mk_data(input(0 to MK_SIZE));
    mk_end <= mk_data(input(MK_SIZE + 1 to (MK_SIZE * 2) + 1));
    
    
    
    gen1: gen_tenhex port map (CLK,rst_i,load_gen,start_gen,mk_initial,mk_end,gen_complete,mk);
	  
    dpUCECHO: process(CLK)
    begin
        if CLK' event and CLK = '1' then
            if rst_i = '1' then
                load <= '0';
                load_gen <= '0';
                start_gen <= '0';
                pb_buf <= x"31";
					 count <= 0;
					 state <= STATE_READY; 
					 for i in 0 to 4 loop
                    input(i) <= "00000000";
                end loop;
					 state <= STATE_READY;
            elsif ( sck_i = '1') then
                pb_buf <= x"32";
                load <= '1';
					 in_buf <= pc;
            elsif ( load = '1') then
                load <= '0';
                if state = STATE_READY then    --STATE_READY
                    if pc = X"69" then         --i, input
                        pb_buf <= x"3E";       -- >
                        state <= STATE_INPUT;
                        count <= 0;
                    elsif pc = X"73" then      --s, status
                        pb_buf <= x"2D";       -- -
                    elsif pc = X"62" then      --b, begin
                        pb_buf <= x"78";       -- x
                        state <= STATE_WORKING;
                        start_gen <= '1';
                    elsif pc = X"72" then      --r, read
                        pb_buf <= x"3C";       -- <
                        state <= STATE_READ_INPUT;
                    else
                        pb_buf <= x"3F";       -- ?
                    end if;
                elsif state = STATE_INPUT then --STATE_INPUT
                    input(count) <= unsigned(pc);
                    pb_buf <= x"2E";           -- .
                    if count < (MK_SIZE * 2) + 1 then
                        count <= count + 1;
                    else
                        count <= 0;
                        state <= STATE_READY;
                    end if;
                elsif state = STATE_READ_INPUT then  --STATE_READ_INPUT
                    pb_buf <= std_logic_vector(input(count));
                    if count < (MK_SIZE * 2) + 1 then
                        count <= count + 1;
                        load_gen <= '1';
                    else
                        count <= 0;
                        state <= STATE_READY;
                        load_gen <= '0';
                    end if;
                elsif state = STATE_READ_PROGRESS then  --STATE_READ_PROGRESS
                    pb_buf <= std_logic_vector(mk_read(count));
                    if count < (MK_SIZE * 2) + 1 then
                        count <= count + 1;
                    else
                        count <= 0;
                        state <= STATE_WORKING;
                    end if;
                elsif state = STATE_WORKING then     --STATE_WORKING
                    start_gen <= '0';
                    if pc = X"73" then               --s, status
                        if gen_complete = '1' then
                            pb_buf <= x"3B";         -- ;
                            state <= STATE_READY;
                        else
                            pb_buf <= x"2E";         -- .
                        end if;
                    elsif pc = X"72" then           --r, read
                        pb_buf <= x"00";            -- null
                        mk_read <= mk;
                        state <= STATE_READ_PROGRESS;
                     else
                        pb_buf <= x"58";         -- X
                    end if;
                else --Error?
                    state <= STATE_READY;
				  end if;
--            elsif ( empty = '0') then
--                pb_buf <= dat_in - 32;
--					 state <= STATE_READY;
            else
					 --Waiting
                --pb_buf <= x"35";
				
            end if;
				
				--count <= count + '1';
        end if;
    end process dpUCECHO;
    
end RTL;
