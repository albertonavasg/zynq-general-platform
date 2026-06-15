library ieee;
use ieee.std_logic_1164.all;

entity axi_bridge_tb is
end entity;

architecture behav of axi_bridge_tb is

    constant CLK_PERIOD : time := 10 ns;

    constant AXI_DATA_WIDTH : integer := 32;
    constant AXI_ADDR_WIDTH : integer := 8;

    signal clk, resetn : std_logic := '0';

    signal axi_araddr : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal axi_arprot : std_logic_vector(2 downto 0) := (others => '0');
    signal axi_arvalid: std_logic := '0';
    signal axi_arready: std_logic := '0';

    signal axi_rdata  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');
    signal axi_rresp  : std_logic_vector(1 downto 0) := (others => '0');
    signal axi_rvalid : std_logic := '0';
    signal axi_rready : std_logic := '0';

    signal version : std_logic_vector(31 downto 0) := x"AABBCCDD";
    signal sw      : std_logic_vector(1 downto 0)  := "11";
    signal btn     : std_logic_vector(3 downto 0)  := "1111";
    signal led     : std_logic_vector(3 downto 0)  := (others => '0');
    signal led_bgr : std_logic_vector(5 downto 0)  := (others => '0');

begin

    dut: entity work.axi_bridge
        generic map (
            C_S_AXI_DATA_WIDTH => AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
        )
        port map (
            S_AXI_ACLK    => clk,
            S_AXI_ARESETN => resetn,

            S_AXI_AWADDR  => (others => '0'),
            S_AXI_AWPROT  => (others => '0'),
            S_AXI_AWVALID => '0',
            S_AXI_AWREADY => open,

            S_AXI_WDATA	  => (others => '0'),
            S_AXI_WSTRB	  => (others => '0'),
            S_AXI_WVALID  => '0',
            S_AXI_WREADY  => open,

            S_AXI_BRESP	  => open,
            S_AXI_BVALID  => open,
            S_AXI_BREADY  => '0',

            S_AXI_ARADDR  => axi_araddr,
            S_AXI_ARPROT  => axi_arprot,
            S_AXI_ARVALID => axi_arvalid,
            S_AXI_ARREADY => axi_arready,

            S_AXI_RDATA	 => axi_rdata,
            S_AXI_RRESP	 => axi_rresp,
            S_AXI_RVALID => axi_rvalid,
            S_AXI_RREADY => axi_rready,

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

        axi_araddr  <= x"80"; -- Register 32
        axi_arvalid <= '1';
        axi_rready  <= '1';
        wait for CLK_PERIOD;

        axi_arvalid <='0';
        wait until axi_rvalid = '1';

        axi_araddr <= (others => '0');
        axi_rready <= '0';
        wait;

        end process;

end architecture;