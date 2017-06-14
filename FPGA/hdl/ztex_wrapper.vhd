library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.sha1_pkg.all;

entity ztex_wrapper is
    port(
        fd      : inout std_logic_vector(15 downto 0);
        CS      : in std_logic;
        IFCLK     : in std_logic;
        --FXCLK     : in std_logic;
        --sck_i     : in std_logic;
        SLOE     : out std_logic;
        SLRD     : out std_logic;
        SLWR     : out std_logic;
        FIFOADR : out std_logic_vector(1 downto 0);
        FLAGA    : in std_logic;  --PF
        FLAGB    : in std_logic;  --Full
        FLAGC    : in std_logic; --Empty
        PKTEND    : out std_logic;
        RESET     : in std_logic;
        CONT     : in std_logic

--      SCL     : in std_logic;
--      SDA     : in std_logic
   );
end ztex_wrapper;


architecture RTL of ztex_wrapper is

    signal fd_buf : std_logic_vector(15 downto 0);
    signal fd_conc : std_logic_vector(15 downto 0);
    signal sloe_buf: std_ulogic;
    signal slrd_buf: std_ulogic;
    signal slwr_buf: std_ulogic;
    signal pktend_buf: std_ulogic;
    signal fifoadr_buf: std_logic_vector(1 downto 0);
    signal count: integer range 0 to (MK_SIZE * 2) + 1;

    signal direction: std_ulogic;

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

begin
    SLOE <= sloe_buf when CS = '1' else 'Z';
    SLRD <= slrd_buf when CS = '1' else 'Z';
    SLWR <= slwr_buf when CS = '1' else 'Z';
    FIFOADR <= fifoadr_buf when CS = '1' else "ZZ";
    PKTEND <= pktend_buf when CS = '1' else 'Z';            --Unused
    fd <= fd_buf when CS = '1' and direction = '0' else (others => 'Z');
    fifoadr_buf <= "10" when direction = '1' else "00";

    sloe_buf <= '0' when direction = '1' else '1';
    slrd_buf <= '0' when direction = '1' and FLAGC = '1' else '1'; --Input and FX2 not empty
    slwr_buf <= '0' when direction = '0' else '1';

    fd_conc <= fd_buf;
    
    ztex_comm: process(IFCLK, RESET)
    begin
        if RESET = '1' then
            --slwr_buf <= '1';
            --slrd_buf <= '1';
            --sloe_buf <= '1';
            fd_buf <= X"ce5d";
            pktend_buf <= '1';
            direction <= '0';
            state <= STATE_READ_PROGRESS;
        elsif IFCLK'event and IFCLK = '1' then

            if state = STATE_READY then
                direction <= '1';
                if fd = X"3232" then
                    state <= STATE_READ_INPUT;
                    fd_buf <= X"3837";
                elsif CONT = '1' then
                    fd_buf(7 downto 0) <= fd(7 downto 0) - 1;
                end if;
            elsif state = STATE_READ_INPUT then
                state <= STATE_READY;
                direction <= '0';
            elsif state = STATE_READ_PROGRESS then
                fd_buf(7 downto 0) <= fd_conc(7 downto 0) + 1;
                direction <= '0';
            end if;
        end if;
    end process ztex_comm;

end RTL;
