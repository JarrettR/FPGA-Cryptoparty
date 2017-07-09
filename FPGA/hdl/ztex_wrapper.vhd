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
        RUN     : in std_logic

--      SCL     : in std_logic;
--      SDA     : in std_logic
   );
end ztex_wrapper;


architecture RTL of ztex_wrapper is

    COMPONENT fx2_fifo
      PORT (
        rst : IN STD_LOGIC;
        wr_clk : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC;
        almost_empty : OUT STD_LOGIC
      );
    END COMPONENT;

    signal fd_buf : std_logic_vector(15 downto 0);
    signal fd_in : std_logic_vector(15 downto 0);
    signal fd_out : std_logic_vector(15 downto 0);
    signal sloe_buf: std_ulogic;
    signal slrd_buf: std_ulogic;
    signal slwr_buf: std_ulogic;
    signal pktend_buf: std_ulogic;
    signal fifoadr_buf: std_logic_vector(1 downto 0);


    --FIFOS
    signal in_fifo_wr_en: std_ulogic;
    signal in_fifo_rd_en: std_ulogic;
    signal in_fifo_full: std_ulogic;
    signal in_fifo_empty: std_ulogic;
    signal in_fifo_almost_empty: std_ulogic;
    signal out_fifo_wr_en: std_ulogic;
    signal out_fifo_rd_en: std_ulogic;
    signal out_fifo_full: std_ulogic;
    signal out_fifo_empty: std_ulogic;
    signal out_fifo_almost_empty: std_ulogic;


    signal direction: std_ulogic;
    --Data
    signal datablock: ssid_data;


    type state_type is (STATE_ERROR,
                        STATE_READY,
                        STATE_INPUT,
                        STATE_READ_INPUT,
                        STATE_READ_PROGRESS,
                        STATE_WORKING,
                        STATE_FINISH_FAIL,
                        STATE_FINISH_SUCCEED
                        );

    type cmd_type is (CMD_WAIT, --00
                    CMD_WRITE,  --01
                    CMD_READ,    --10
                    CMD_ERROR    --11
                    );

    type data_type is (DATA_NULL, --00
                    DATA_SSID,    --01
                    DATA_MK,      --10
                    DATA_ERROR    --11
                    );

    signal state          : state_type := STATE_ERROR;
    signal command        : cmd_type;
    signal datatype       : data_type;
    signal dataaddr       : integer range 0 to 35;
    signal data           : std_logic_vector(7 downto 0);

begin
    SLOE <= sloe_buf when CS = '1' else 'Z';
    SLRD <= slrd_buf when CS = '1' else 'Z';
    SLWR <= slwr_buf when CS = '1' else 'Z';
    FIFOADR <= fifoadr_buf when CS = '1' else "ZZ";
    PKTEND <= pktend_buf when CS = '1' else 'Z';            --Unused
    fd <= fd_out when CS = '1' and direction = '0' else (others => 'Z');
    fifoadr_buf <= "10" when direction = '1' else "00";

    sloe_buf <= '0' when direction = '1' else '1';
    slrd_buf <= '0' when direction = '1' and FLAGC = '1' else '1'; --Input and FX2 not empty
    --slwr_buf <= '0' when direction = '0' else '1';

    --FX2 Flow control
    direction <= '0' when
        out_fifo_empty = '0' and
        FLAGB = '1' else
        '1';
    pktend_buf <= '0' when
        out_fifo_almost_empty = '1' and
        out_fifo_rd_en = '1' else
        '1';
    in_fifo_wr_en <= '1' when
        direction = '1' and
        CS = '1' and
        flagc = '1' else
        '0';
    slwr_buf <= '0' when
        out_fifo_rd_en = '1' and
        flagb = '1' else
        '1';

    in_fifo : fx2_fifo port map (
		 rst    => RESET,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din    => fd,
		 wr_en  => in_fifo_wr_en,
		 rd_en  => in_fifo_rd_en,
		 dout   => fd_in,
		 full   => in_fifo_full,
		 empty  => in_fifo_empty,
		 almost_empty  => in_fifo_almost_empty
	  );

    out_fifo : fx2_fifo port map (
		 rst    => RESET,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din    => fd_buf,
		 wr_en  => out_fifo_wr_en,
		 rd_en  => out_fifo_rd_en,
		 dout   => fd_out,
		 full   => out_fifo_full,
		 empty  => out_fifo_empty,
		 almost_empty  => out_fifo_almost_empty
	  );

    ztex_comm: process(IFCLK, RESET)
    begin
        if RESET = '1' then
            fd_buf         <= X"ce5d";
            in_fifo_rd_en  <= '1';
            out_fifo_rd_en <= '0';
            state          <= STATE_READY;
        elsif IFCLK'event and IFCLK = '1' then

            if in_fifo_empty = '0' then
                if fd_in(15 downto 14) = "00" then
                    command <= CMD_WAIT;
                elsif fd_in(15 downto 14) = "01" then
                    command <= CMD_WRITE;
                elsif fd_in(15 downto 14) = "10" then
                    command <= CMD_READ;
                else
                    command <= CMD_ERROR;
                end if;

                if fd_in(13 downto 12) = "00" then
                    datatype <= DATA_NULL;
                elsif fd_in(13 downto 12) = "01" then
                    datatype <= DATA_SSID;
                elsif fd_in(13 downto 12) = "10" then
                    datatype <= DATA_MK;
                else
                    datatype <= DATA_ERROR;
                end if;

                dataaddr <= to_integer(unsigned(fd_in(11 downto 8)));
                data <= fd_in(7 downto 0);
            else
                command <= CMD_WAIT;
            end if;

            if state = STATE_READY then
                out_fifo_wr_en <= '0';
                if command = CMD_WRITE then
                    datablock(dataaddr) <= unsigned(data);
                elsif command = CMD_READ then
                    out_fifo_wr_en <= '1';
                    fd_buf <= fd_in(15 downto 8) & std_logic_vector(datablock(dataaddr));
                end if;
            elsif state = STATE_READ_INPUT then
                state <= STATE_READY;
            end if;

            --Todo fix for multiple clock domains
            if direction = '0' then
                out_fifo_rd_en <= not out_fifo_rd_en;
            end if;

        end if;
    end process ztex_comm;

end RTL;
