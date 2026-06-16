library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity zgp_top is
    generic (
		AXI_DATA_WIDTH : integer := 32;
		AXI_ADDR_WIDTH : integer := 8
    );
    port (
        -- DDR
        ddr_addr    : inout std_logic_vector (14 downto 0);
        ddr_ba      : inout std_logic_vector (2 downto 0);
        ddr_cas_n   : inout std_logic;
        ddr_ck_n    : inout std_logic;
        ddr_ck_p    : inout std_logic;
        ddr_cke     : inout std_logic;
        ddr_cs_n    : inout std_logic;
        ddr_dm      : inout std_logic_vector (3 downto 0);
        ddr_dq      : inout std_logic_vector (31 downto 0);
        ddr_dqs_n   : inout std_logic_vector (3 downto 0);
        ddr_dqs_p   : inout std_logic_vector (3 downto 0);
        ddr_odt     : inout std_logic;
        ddr_ras_n   : inout std_logic;
        ddr_reset_n : inout std_logic;
        ddr_we_n    : inout std_logic;
        -- Fixed IO
        fixed_io_ddr_vrn  : inout std_logic;
        fixed_io_ddr_vrp  : inout std_logic;
        fixed_io_mio      : inout std_logic_vector (53 downto 0);
        fixed_io_ps_clk   : inout std_logic;
        fixed_io_ps_porb  : inout std_logic;
        fixed_io_ps_srstb : inout std_logic;
        -- Custom physical pins
        sw      : in  std_logic_vector(1 downto 0);
        btn     : in  std_logic_vector(3 downto 0);
        led     : out std_logic_vector(3 downto 0);
        led_bgr : out std_logic_vector(5 downto 0)
    );
end zgp_top;

architecture Structure of zgp_top is

    signal clk    : std_logic;
    signal resetn : std_logic_vector(0 downto 0);

    signal axi_awaddr  : std_logic_vector(31 downto 0);
    signal axi_awprot  : std_logic_vector(2 downto 0);
    signal axi_awvalid : std_logic;
    signal axi_awready : std_logic;

    signal axi_wdata  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_wstrb  : std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
    signal axi_wvalid : std_logic;
    signal axi_wready : std_logic;

    signal axi_bresp  : std_logic_vector(1 downto 0);
    signal axi_bready : std_logic;
    signal axi_bvalid : std_logic;

    signal axi_araddr  : std_logic_vector(31 downto 0);
    signal axi_arprot  : std_logic_vector(2 downto 0);
    signal axi_arvalid : std_logic;
    signal axi_arready : std_logic;

    signal axi_rdata  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
    signal axi_rresp  : std_logic_vector(1 downto 0);
    signal axi_rvalid : std_logic;
    signal axi_rready : std_logic;

    signal fixed_version : std_logic_vector(31 downto 0) := x"76" & x"01" & x"00" & x"00"; -- v1.0.0

begin

    zynq_ps_wrapper_inst: entity work.zynq_ps_wrapper
        port map (
            clk => clk,

            ddr_addr    => ddr_addr,
            ddr_ba      => ddr_ba,
            ddr_cas_n   => ddr_cas_n,
            ddr_ck_n    => ddr_ck_n,
            ddr_ck_p    => ddr_ck_p,
            ddr_cke     => ddr_cke,
            ddr_cs_n    => ddr_cs_n,
            ddr_dm      => ddr_dm,
            ddr_dq      => ddr_dq,
            ddr_dqs_n   => ddr_dqs_n,
            ddr_dqs_p   => ddr_dqs_p,
            ddr_odt     => ddr_odt,
            ddr_ras_n   => ddr_ras_n,
            ddr_reset_n => ddr_reset_n,
            ddr_we_n    => ddr_we_n,

            fixed_io_ddr_vrn  => fixed_io_ddr_vrn,
            fixed_io_ddr_vrp  => fixed_io_ddr_vrp,
            fixed_io_mio      => fixed_io_mio,
            fixed_io_ps_clk   => fixed_io_ps_clk,
            fixed_io_ps_porb  => fixed_io_ps_porb,
            fixed_io_ps_srstb => fixed_io_ps_srstb,

            m_axi_araddr  => axi_araddr,
            m_axi_arprot  => axi_arprot,
            m_axi_arready => axi_arready,
            m_axi_arvalid => axi_arvalid,

            m_axi_awaddr  => axi_awaddr,
            m_axi_awprot  => axi_awprot,
            m_axi_awready => axi_awready,
            m_axi_awvalid => axi_awvalid,

            m_axi_bready => axi_bready,
            m_axi_bresp  => axi_bresp,
            m_axi_bvalid => axi_bvalid,

            m_axi_rdata  => axi_rdata,
            m_axi_rready => axi_rready,
            m_axi_rresp  => axi_rresp,
            m_axi_rvalid => axi_rvalid,

            m_axi_wdata  => axi_wdata,
            m_axi_wready => axi_wready,
            m_axi_wstrb  => axi_wstrb,
            m_axi_wvalid => axi_wvalid,

            resetn => resetn
        );

    axi_bridge_inst: entity work.axi_bridge
        generic map (
            AXI_DATA_WIDTH => AXI_DATA_WIDTH,
            AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
        )
        port map (
            clk    => clk,
            resetn => resetn(0),

            s_axi_awaddr  => axi_awaddr(AXI_ADDR_WIDTH-1 downto 0),
            s_axi_awprot  => axi_awprot,
		    s_axi_awvalid => axi_awvalid,
		    s_axi_awready => axi_awready,

		    s_axi_wdata  => axi_wdata,
		    s_axi_wstrb  => axi_wstrb,
		    s_axi_wvalid => axi_wvalid,
		    s_axi_wready => axi_wready,

		    s_axi_bresp  => axi_bresp,
		    s_axi_bvalid => axi_bvalid,
		    s_axi_bready => axi_bready,

		    s_axi_araddr  => axi_araddr(AXI_ADDR_WIDTH-1 downto 0),
		    s_axi_arprot  => axi_arprot,
		    s_axi_arvalid => axi_arvalid,
		    s_axi_arready => axi_arready,

		    s_axi_rdata  => axi_rdata,
		    s_axi_rresp  => axi_rresp,
		    s_axi_rvalid => axi_rvalid,
		    s_axi_rready => axi_rready,

            version => fixed_version,

            sw      => sw,
            btn     => btn,
            led     => led,
            led_bgr => led_bgr
        );

end architecture;
