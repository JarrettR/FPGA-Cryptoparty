library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.sha1_pkg.all;

entity ztex_wrapper is
    port(
        pc_i      : in std_logic_vector(7 downto 0);
        pb_o      : out std_logic_vector(7 downto 0);
        CS      : in std_logic;
        IFCLK     : in std_logic;
        --FXCLK     : in std_logic;
        --sck_i     : in std_logic;
        SLOE     : out std_logic;
        SLRD     : out std_logic;
        SLWR     : out std_logic;
        FIFOADR : out std_logic_vector(1 downto 0);
        FLAGB    : in std_logic;  --Full
        FLAGC    : in std_logic; --Empty
        rst_i     : in std_logic

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
    signal out_buf : std_logic_vector(7 downto 0);
    signal in_buf : std_logic_vector(7 downto 0);
    signal load: std_ulogic;
    signal sloe_buf: std_ulogic;
    signal slrd_buf: std_ulogic;
    signal slwr_buf: std_ulogic;
    signal fifoadr_buf: std_logic_vector(1 downto 0);
    signal count: integer range 0 to (MK_SIZE * 2) + 1;
    --constant rst : unsigned(7 downto 0) := X"30";  -- Reset

    
    --fifo signals
    signal start: std_ulogic;
    signal wr_en: std_ulogic;
    signal out_wr: std_ulogic;
    --signal rd_en: std_ulogic;
    signal full_i: std_ulogic;
    signal full_o: std_ulogic;
    signal empty_i: std_ulogic;
    --signal empty_o: std_ulogic;
    signal in_wr_en: std_ulogic;
    signal in_full: std_ulogic;
    signal in_empty: std_ulogic;
    signal out_empty: std_ulogic;
    signal in_rd_en: std_ulogic;
    signal out_rd: std_ulogic;
	
begin
    pb_o <= pb_buf when CS = '1' else (others => 'Z');
    SLOE <= sloe_buf when CS = '1' and in_full = '0' else
            '1' when CS = '1' and in_full = '0' else
            'Z';
    SLRD <= slrd_buf when CS = '1' else 'Z';
    SLWR <= slwr_buf when CS = '1' else 'Z';
    FIFOADR <= fifoadr_buf when CS = '1' else "ZZ";
    in_wr_en <= not sloe_buf when CS = '1' and in_full = '0' else '0';
    in_rd_en <= not in_empty;
    empty_i <= FLAGC when CS = '1' else '0';
    full_i <= FLAGB when CS = '1' else '0';
    --out_rd <= std_logic_vector( sck_i ) when CS = '1' else (others => 'Z');
    
    in_fifo : fx2_fifo
	  port map (
		 rst => rst_i,
		 wr_clk => slrd_buf,
		 rd_clk => IFCLK,
		 din => pc_i,
		 wr_en => in_wr_en,
		 rd_en => in_rd_en,
		 dout => in_buf,
		 full => in_full,
		 empty => in_empty
	  );
    out_fifo : fx2_fifo
	  port map (
		 rst => rst_i,
		 wr_clk => IFCLK,
		 rd_clk => IFCLK,
		 din => out_buf,
		 wr_en => out_wr,
		 rd_en => full_i,
		 dout => pb_buf,
		 full => full_o,
		 empty => out_empty
	  );
      
      
    ztex_comm: process(IFCLK)
    begin
        if IFCLK'event and IFCLK = '1' then
            if rst_i = '1' then
                start <= '0';
                load <= '0';
                fifoadr_buf <= "01";
                out_buf <= x"35";
                slwr_buf <= '1';
                slrd_buf <= '1';
                sloe_buf <= '1';
            else
                sloe_buf <= '0';
                if ( empty_i = '1' ) then
                    if ( start = '0' ) then
                        start <= '1';
                    else
                        slrd_buf <= not slrd_buf;
                    end if;
                else
                    slrd_buf <= '1';
                end if;
            end if;
        end if;
    end process ztex_comm;
    
end RTL;
