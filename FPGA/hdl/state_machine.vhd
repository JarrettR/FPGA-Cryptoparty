library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.sha1_pkg.all;

entity state_machine is
    port(
        IFCLK     : in std_logic;
        rst_i     : in std_logic;
        enable_i  : in std_logic;
        dat_i     : in std_logic_vector(7 downto 0);
        state_o    : out integer range 0 to 5;
        ssid_o    : out std_logic_vector(7 downto 0);
        dat_mk_o  : out    mk_data;
        valid_o   : out std_ulogic
   );
end state_machine;


architecture RTL of state_machine is
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
    signal state_buff    : integer range 0 to 5;
    signal cmd_buff    : std_logic_vector(7 downto 0);
    signal count    : integer range 0 to 9;
    constant count_max    : integer := 9;

    --gen_tenhex helpers
    signal load_gen: std_ulogic;
    signal start_gen: std_ulogic;
    signal gen_complete: std_ulogic;
    signal mk_initial: mk_data;
    signal mk_end: mk_data;
    signal mk: mk_data;
    signal mk_read: mk_data;

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
                          CMD_NULL,
                          CMD_INPUT,
                          CMD_READ_INPUT,
                          CMD_STATUS,
                          CMD_ABORT,
                          CMD_OUTPUT
                          );

    signal command          : command_type := CMD_ERROR;

begin
    command <= CMD_INPUT when dat_i = X"01" and state = STATE_READY else
               CMD_READ_INPUT when dat_i = X"02" and state = STATE_READY else
               CMD_NULL when not (state = STATE_READY) else
               CMD_ERROR; 

    
    ztex_state_machine: process(IFCLK)
    begin
        if IFCLK'event and IFCLK = '1' then
            if rst_i = '1' then
                state <= STATE_READY; 
--                for i in 0 to ((MK_SIZE * 2) + 1) loop
--                    input(i) <= "00000000";
--                end loop;
            elsif ( enable_i = '1' ) then
                if ( state = STATE_READY ) then             --STATE_READY
                    if ( command = CMD_INPUT ) then
                        state <= STATE_INPUT;
                        count <= 0;
                    elsif ( command = CMD_READ_INPUT ) then
                        state <= STATE_READ_INPUT;
                    end if;
                elsif ( state = STATE_INPUT ) then          --STATE_INPUT
                    if ( count < count_max ) then
                        mk_initial(count) <= unsigned(dat_i);
                        count <= count + 1;
                    else
                        mk_initial(count) <= unsigned(dat_i);
                        count <= 0;
                        state <= STATE_READY;
                    end if;
                elsif ( state = STATE_READ_INPUT ) then     --STATE_READ_INPUT
                    if ( dat_i = X"01" ) then
                        state <= STATE_INPUT;
                    elsif ( dat_i = X"02" ) then
                        state <= STATE_READ_INPUT;
                    end if;
                --else
				
                end if;
            end if;
            --count <= count + '1';
        end if;
    end process ztex_state_machine;
    
end RTL;
