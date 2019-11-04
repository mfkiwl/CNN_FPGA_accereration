
`timescale 1 ps / 1 ps

module top
   (
    DDR_0_addr,
    DDR_0_ba,
    DDR_0_cas_n,
    DDR_0_ck_n,
    DDR_0_ck_p,
    DDR_0_cke,
    DDR_0_cs_n,
    DDR_0_dm,
    DDR_0_dq,
    DDR_0_dqs_n,
    DDR_0_dqs_p,
    DDR_0_odt,
    DDR_0_ras_n,
    DDR_0_reset_n,
    DDR_0_we_n,
    FIXED_IO_0_ddr_vrn,
    FIXED_IO_0_ddr_vrp,
    FIXED_IO_0_mio,
    FIXED_IO_0_ps_clk,
    FIXED_IO_0_ps_porb,
    FIXED_IO_0_ps_srstb,
    UART0_rxd,
    UART0_txd
   );
    //led,
    //push_n);
 
    inout [14:0]DDR_0_addr;
    inout [2:0]DDR_0_ba;
    inout DDR_0_cas_n;
    inout DDR_0_ck_n;
    inout DDR_0_ck_p;
    inout DDR_0_cke;
    inout DDR_0_cs_n;
    inout [3:0]DDR_0_dm;
    inout [31:0]DDR_0_dq;
    inout [3:0]DDR_0_dqs_n;
    inout [3:0]DDR_0_dqs_p;
    inout DDR_0_odt;
    inout DDR_0_ras_n;
    inout DDR_0_reset_n;
    inout DDR_0_we_n;
    inout FIXED_IO_0_ddr_vrn;
    inout FIXED_IO_0_ddr_vrp;
    inout [53:0]FIXED_IO_0_mio;
    inout FIXED_IO_0_ps_clk;
    inout FIXED_IO_0_ps_porb;
    inout FIXED_IO_0_ps_srstb;
    input UART0_rxd;
    output UART0_txd;
   
      
    
        wire [14:0]DDR_0_addr;
        wire [2:0]DDR_0_ba;
        wire DDR_0_cas_n;
        wire DDR_0_ck_n;
        wire DDR_0_ck_p;
        wire DDR_0_cke;
        wire DDR_0_cs_n;
        wire [3:0]DDR_0_dm;
        wire [31:0]DDR_0_dq;
        wire [3:0]DDR_0_dqs_n;
        wire [3:0]DDR_0_dqs_p;
        wire DDR_0_odt;
        wire DDR_0_ras_n;
        wire DDR_0_reset_n;
        wire DDR_0_we_n;
        wire FIXED_IO_0_ddr_vrn;
        wire FIXED_IO_0_ddr_vrp;
        wire [53:0]FIXED_IO_0_mio;
        wire FIXED_IO_0_ps_clk;
        wire FIXED_IO_0_ps_porb;
        wire FIXED_IO_0_ps_srstb;
        wire UART0_rxd;
        wire UART0_txd;
        wire clk;
        wire [0:0]reset;
      
     
      
    
      wire [31:0]AHB_INTERFACE_0_hrdata;
      wire AHB_INTERFACE_0_hready_out;
      wire AHB_INTERFACE_0_hresp;
    
      
      wire [31:0]AHB_INTERFACE_0_haddr_B;
      wire [2:0]AHB_INTERFACE_0_hburst_B;
      wire [3:0]AHB_INTERFACE_0_hprot_B;
      wire AHB_INTERFACE_0_hready_in_B;
      wire [2:0]AHB_INTERFACE_0_hsize_B;
      wire [1:0]AHB_INTERFACE_0_htrans_B;
      wire [31:0]AHB_INTERFACE_0_hwdata_B;
      wire AHB_INTERFACE_0_hwrite_B;
      wire AHB_INTERFACE_0_sel_B;
      
      wire [31:0]AHB_INTERFACE_0_haddr_startA;
      wire [2:0]AHB_INTERFACE_0_hburst_startA;
      wire [3:0]AHB_INTERFACE_0_hprot_startA;
      wire AHB_INTERFACE_0_hready_in_startA;
      wire [2:0]AHB_INTERFACE_0_hsize_startA;
      wire [1:0]AHB_INTERFACE_0_htrans_startA;
      wire [31:0]AHB_INTERFACE_0_hwdata_startA;
      wire AHB_INTERFACE_0_hwrite_startA;
      wire AHB_INTERFACE_0_sel_startA;
      
      wire [31:0]AHB_INTERFACE_0_haddr;
      wire [2:0]AHB_INTERFACE_0_hburst;
      wire [3:0]AHB_INTERFACE_0_hprot;
      wire AHB_INTERFACE_0_hready_in;
      wire [2:0]AHB_INTERFACE_0_hsize;
      wire [1:0]AHB_INTERFACE_0_htrans;
      wire [31:0]AHB_INTERFACE_0_hwdata;
      wire AHB_INTERFACE_0_hwrite;
      wire AHB_INTERFACE_0_sel;
      
      assign AHB_INTERFACE_0_haddr = AHB_INTERFACE_0_haddr_B | AHB_INTERFACE_0_haddr_startA;
      assign AHB_INTERFACE_0_hburst = AHB_INTERFACE_0_hburst_B | AHB_INTERFACE_0_hburst_startA;
      assign AHB_INTERFACE_0_hprot = AHB_INTERFACE_0_hprot_B | AHB_INTERFACE_0_hprot_startA;
      assign AHB_INTERFACE_0_hready_in = AHB_INTERFACE_0_hready_in_B | AHB_INTERFACE_0_hready_in_startA;
      assign AHB_INTERFACE_0_hsize = AHB_INTERFACE_0_hsize_B | AHB_INTERFACE_0_hsize_startA;
      assign AHB_INTERFACE_0_htrans = AHB_INTERFACE_0_htrans_B | AHB_INTERFACE_0_htrans_startA;
      assign AHB_INTERFACE_0_hwdata = AHB_INTERFACE_0_hwdata_B | AHB_INTERFACE_0_hwdata_startA;
      assign AHB_INTERFACE_0_hwrite = AHB_INTERFACE_0_hwrite_B | AHB_INTERFACE_0_hwrite_startA;
      assign AHB_INTERFACE_0_sel = AHB_INTERFACE_0_sel_B | AHB_INTERFACE_0_sel_startA;
      
 
      wire start;
      wire finish;
      
      
        
        moduleB moduleB (
            .ADDR(AHB_INTERFACE_0_haddr_B),
            .BURST(AHB_INTERFACE_0_hburst_B),
            .PROT(AHB_INTERFACE_0_hprot_B),
            .RDATA(AHB_INTERFACE_0_hrdata),//
            .READY_in(AHB_INTERFACE_0_hready_in_B),
            .READY_out(AHB_INTERFACE_0_hready_out),//
            .RESP(AHB_INTERFACE_0_hresp),//
            .hsize(AHB_INTERFACE_0_hsize_B),
            .TRANS(AHB_INTERFACE_0_htrans_B),
            .WDATA(AHB_INTERFACE_0_hwdata_B),
            .HWRITE(AHB_INTERFACE_0_hwrite_B),
            .SEL(AHB_INTERFACE_0_sel_B),
            .start(start),
            .finish(finish),
            .clk(clk),
            .reset(reset)

                            
        );
    
        moduleA moduleA (
            .ADDR(AHB_INTERFACE_0_haddr_startA),
            .BURST(AHB_INTERFACE_0_hburst_startA),
            .PROT(AHB_INTERFACE_0_hprot_startA),
            .RDATA(AHB_INTERFACE_0_hrdata),//
            .READY_in(AHB_INTERFACE_0_hready_in_startA),
            .READY_out(AHB_INTERFACE_0_hready_out),//
            .RESP(AHB_INTERFACE_0_hresp),//
            .hsize(AHB_INTERFACE_0_hsize_startA),
            .TRANS(AHB_INTERFACE_0_htrans_startA),
            .WDATA(AHB_INTERFACE_0_hwdata_startA),
            .HWRITE(AHB_INTERFACE_0_hwrite_startA),
            .SEL(AHB_INTERFACE_0_sel_startA),
            .start(start),
            .finish(finish),
            .clk(clk),
            .reset(reset)
        );


  design_1 design_1_i
       (.AHB_INTERFACE_0_haddr(AHB_INTERFACE_0_haddr),
        .AHB_INTERFACE_0_hburst(AHB_INTERFACE_0_hburst),
        .AHB_INTERFACE_0_hprot(AHB_INTERFACE_0_hprot),
        .AHB_INTERFACE_0_hrdata(AHB_INTERFACE_0_hrdata),
        .AHB_INTERFACE_0_hready_in(AHB_INTERFACE_0_hready_in),
        .AHB_INTERFACE_0_hready_out(AHB_INTERFACE_0_hready_out),
        .AHB_INTERFACE_0_hresp(AHB_INTERFACE_0_hresp),
        .AHB_INTERFACE_0_hsize(AHB_INTERFACE_0_hsize),
        .AHB_INTERFACE_0_htrans(AHB_INTERFACE_0_htrans),
        .AHB_INTERFACE_0_hwdata(AHB_INTERFACE_0_hwdata),
        .AHB_INTERFACE_0_hwrite(AHB_INTERFACE_0_hwrite),
        .AHB_INTERFACE_0_sel(AHB_INTERFACE_0_sel),
        .DDR_0_addr(DDR_0_addr),
        .DDR_0_ba(DDR_0_ba),
        .DDR_0_cas_n(DDR_0_cas_n),
        .DDR_0_ck_n(DDR_0_ck_n),
        .DDR_0_ck_p(DDR_0_ck_p),
        .DDR_0_cke(DDR_0_cke),
        .DDR_0_cs_n(DDR_0_cs_n),
        .DDR_0_dm(DDR_0_dm),
        .DDR_0_dq(DDR_0_dq),
        .DDR_0_dqs_n(DDR_0_dqs_n),
        .DDR_0_dqs_p(DDR_0_dqs_p),
        .DDR_0_odt(DDR_0_odt),
        .DDR_0_ras_n(DDR_0_ras_n),
        .DDR_0_reset_n(DDR_0_reset_n),
        .DDR_0_we_n(DDR_0_we_n),
        .FIXED_IO_0_ddr_vrn(FIXED_IO_0_ddr_vrn),
        .FIXED_IO_0_ddr_vrp(FIXED_IO_0_ddr_vrp),
        .FIXED_IO_0_mio(FIXED_IO_0_mio),
        .FIXED_IO_0_ps_clk(FIXED_IO_0_ps_clk), // clock_250mhz
        .FIXED_IO_0_ps_porb(FIXED_IO_0_ps_porb),
        .FIXED_IO_0_ps_srstb(FIXED_IO_0_ps_srstb),
        .UART0_rxd(UART0_rxd),
        .UART0_txd(UART0_txd),
        .clk(clk),
        .reset(reset));
endmodule
