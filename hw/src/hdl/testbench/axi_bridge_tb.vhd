library ieee;
use ieee.std_logic_1164.all;

entity axi_bridge_tb is
end entity;

architecture behav of axi_bridge_tb is

    constant CLK_PERIOD : time := 10 ns;

    constant AXI_DATA_WIDTH : integer := 32;
    constant AXI_ADDR_WIDTH : integer := 8;

    signal clk, resetn : std_logic := '0';

    signal axi_awaddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) := (others =>'0');
    signal axi_awprot : std_logic_vector(2 downto 0) := (others =>'0');
    signal axi_awvalid : std_logic:= '0';
    signal axi_awready : std_logic:= '0';

    signal axi_wdata  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others =>'0');
    signal axi_wstrb  : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0) := (others =>'0');
    signal axi_wvalid : std_logic := '0';
    signal axi_wready : std_logic := '0';

    signal axi_bresp  : std_logic_vector(1 downto 0) := (others =>'0');
    signal axi_bvalid : std_logic := '0';
    signal axi_bready : std_logic := '0';

    signal axi_araddr  : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal axi_arprot  : std_logic_vector(2 downto 0) := (others => '0');
    signal axi_arvalid : std_logic := '0';
    signal axi_arready : std_logic := '0';

    signal axi_rdata  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal axi_rresp  : std_logic_vector(1 downto 0) := (others => '0');
    signal axi_rvalid : std_logic := '0';
    signal axi_rready : std_logic := '0';

    signal version : std_logic_vector(31 downto 0) := x"00001234";
    signal sw      : std_logic_vector(1 downto 0)  := "10";
    signal btn     : std_logic_vector(3 downto 0)  := "1010";
    signal led     : std_logic_vector(3 downto 0)  := (others => '0');
    signal led_bgr : std_logic_vector(5 downto 0)  := (others => '0');

begin

    dut: entity work.axi_bridge
        generic map (
            AXI_DATA_WIDTH => AXI_DATA_WIDTH,
            AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
        )
        port map (
            clk    => clk,
            resetn => resetn,

            s_axi_awaddr  => axi_awaddr,
            s_axi_awprot  => axi_awprot,
            s_axi_awvalid => axi_awvalid,
            s_axi_awready => axi_awready,

            s_axi_wdata	  => axi_wdata,
            s_axi_wstrb	  => axi_wstrb,
            s_axi_wvalid  => axi_wvalid,
            s_axi_wready  => axi_wready,

            s_axi_bresp	  => axi_bresp,
            s_axi_bvalid  => axi_bvalid,
            s_axi_bready  => axi_bready,

            s_axi_araddr  => axi_araddr,
            s_axi_arprot  => axi_arprot,
            s_axi_arvalid => axi_arvalid,
            s_axi_arready => axi_arready,

            s_axi_rdata	 => axi_rdata,
            s_axi_rresp	 => axi_rresp,
            s_axi_rvalid => axi_rvalid,
            s_axi_rready => axi_rready,

            version => version,

            sw      => sw,
            btn     => btn,
            led     => led,
            led_bgr => led_bgr
        );

    clk_proc: process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;

    stim_proc: process
    begin
        resetn <= '0';
        wait for CLK_PERIOD;

        resetn <= '1';
        wait for CLK_PERIOD;

        -- Read register 32
        axi_araddr  <= x"80";
        axi_arvalid <= '1';
        axi_rready  <= '1';
        wait for CLK_PERIOD;

        axi_arvalid <='0';
        wait for CLK_PERIOD;

        axi_rready <= '0';
        wait for CLK_PERIOD*2;

        -- Read register 33
        axi_araddr  <= x"84";
        axi_arvalid <= '1';
        axi_rready  <= '1';
        wait for CLK_PERIOD;

        axi_arvalid <='0';
        wait for CLK_PERIOD;

        axi_rready <= '0';
        wait for CLK_PERIOD*2;

        -- Write register 0
        axi_awaddr <= x"00";
        axi_awvalid <= '1';

        axi_wdata <= x"0000" & b"000000" & b"1111111111";
        axi_wstrb <= b"1111";
        axi_wvalid <= '1';

        axi_bready <= '1';
        wait for CLK_PERIOD;

        axi_awvalid <= '0';
        axi_wvalid <= '0';
        wait for CLK_PERIOD*3;

        axi_bready <= '0';
        wait for CLK_PERIOD;

        -- Write register 0 (First addr, then data)
        axi_awaddr <= x"00";
        axi_awvalid <= '1';

        axi_bready <= '1';
        wait for CLK_PERIOD*1;

        axi_awvalid <= '0';
        wait for CLK_PERIOD;

        axi_wdata <= x"0000" & b"000000" & b"0101011100";
        axi_wstrb <= b"1111";
        axi_wvalid <= '1';
        wait for CLK_PERIOD;

        axi_wvalid <= '0';
        wait for CLK_PERIOD*3;

        axi_bready <= '0';
        wait for CLK_PERIOD;

        -- Write register 0 (First data, then addr)
        axi_wdata <= x"0000" & b"000000" & b"1010100011";
        axi_wstrb <= b"1111";
        axi_wvalid <= '1';

        axi_bready <= '1';
        wait for CLK_PERIOD*1;

        axi_wvalid <= '0';
        wait for CLK_PERIOD;

        axi_awaddr <= x"00";
        axi_awvalid <= '1';

        wait for CLK_PERIOD;

        axi_awvalid <= '0';
        wait for CLK_PERIOD*3;

        axi_bready <= '0';
        wait for CLK_PERIOD;

        wait;

        end process;

end architecture;