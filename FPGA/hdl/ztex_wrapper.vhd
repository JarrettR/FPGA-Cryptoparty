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
      SLRD     : in std_logic;
      SLWR     : in std_logic;
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
    COMPONENT fx2_fifo
      PORT (
        rst : IN STD_LOGIC;
        wr_clk : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
      );
    END COMPONENT;

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
    
    --fifo signals
    signal start: std_ulogic := '0';
    --signal wr_en: std_ulogic := '0';
    --signal rd_en: std_ulogic := '0';
    signal full: std_ulogic := '0';
    signal empty: std_ulogic := '0';

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
    in_fifo : fx2_fifo
	  port map (
		 rst => rst_i,
		 wr_clk => sck_i,
		 rd_clk => load,
		 din => pc,
		 wr_en => SLWR,
		 rd_en => rd_en,
		 dout => in_buf,
		 full => full,
		 empty => empty
	  );
	  
    dpUCECHO: process(CLK)
    begin
        if CLK'event and CLK = '1' then
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
            elsif ( empty = '1') then
                pb_buf <= x"32";
                --load <= '1';
                --in_buf <= pc;
            elsif ( empty = '0') then
                if ( load = '0') then
                    load <= '1';
                else
                    load <= '0';
                    if state = STATE_READY then    --STATE_READY
                        if in_buf = X"69" then         --i, input
                            pb_buf <= x"3E";       -- >
                            state <= STATE_INPUT;
                            count <= 0;
                        elsif in_buf = X"73" then      --s, status
                            pb_buf <= x"00";       -- null
                        elsif in_buf = X"62" then      --b, begin
                            pb_buf <= x"78";       -- x
                            state <= STATE_WORKING;
                            start_gen <= '1';
                        elsif in_buf = X"72" then      --r, read
                            pb_buf <= x"3C";       -- <
                            state <= STATE_READ_INPUT;
                        else
                            pb_buf <= x"3F";       -- ?
                        end if;
                    elsif state = STATE_INPUT then --STATE_INPUT
                        input(count) <= unsigned(in_buf);
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
                        if in_buf = X"73" then               --s, status
                            if gen_complete = '1' then
                                pb_buf <= x"3B";         -- ;
                                state <= STATE_READY;
                            else
                                pb_buf <= x"2E";         -- .
                            end if;
                        elsif in_buf = X"72" then           --r, read
                            pb_buf <= x"00";            -- null
                            mk_read <= mk;
                            state <= STATE_READ_PROGRESS;
                         else
                            pb_buf <= x"58";         -- X
                        end if;
                    else --Error?
                    
                        state <= STATE_READY;
                    end if;
                else
				--Waiting
                --pb_buf <= x"35";
				
                end if;
            end if;
            --count <= count + '1';
        end if;
    end process dpUCECHO;
    
end RTL;
