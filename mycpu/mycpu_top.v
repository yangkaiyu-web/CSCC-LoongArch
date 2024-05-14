module mycpu_top (
    ext_int     ,   //high active

    aclk        ,
    aresetn     ,   //low active

    arid        ,
    araddr      ,
    arlen       ,
    arsize      ,
    arburst     ,
    arlock      ,
    arcache     ,
    arprot      ,
    arvalid     ,
    arready     ,
               
    rid         ,
    rdata       ,
    rresp       ,
    rlast       ,
    rvalid      ,
    rready      ,

    awid        ,
    awaddr      ,
    awlen       ,
    awsize      ,
    awburst     ,
    awlock      ,
    awcache     ,
    awprot      ,
    awvalid     ,
    awready     ,
    wid         ,
    wdata       ,
    wstrb       ,
    wlast       ,
    wvalid      ,
    wready      ,
    bid         ,
    bresp       ,
    bvalid      ,
    bready      ,
    //debug interface
    debug_wb_pc         ,
    debug_wb_rf_wen     ,
    debug_wb_rf_wnum    ,
    debug_wb_rf_wdata 
);     
    //axi时钟与复位信号
    input aclk;
    input aresetn;
    
    input [5:0] ext_int;
    //读请求通道（以ar开头）
    output [3:0] arid;
    output [31:0] araddr;
    output [3:0] arlen;
    output [2:0] arsize;
    output [1:0] arburst;
    output [1:0] arlock;
    output [3:0] arcache;
    output [2:0] arprot;
    output arvalid;
    input arready;
    //读响应通道（以r开头）
    input [3:0] rid;
    input [31:0] rdata;
    input [1:0] rresp;
    input rlast;
    input rvalid;
    output rready;
    //写请求通道（以aw开头）
    output [3:0] awid; 
    output [31:0] awaddr;
    output [3:0] awlen;
    output [2:0] awsize;
    output [1:0] awburst;
    output [1:0] awlock;
    output [3:0] awcache;
    output [2:0] awprot;
    output awvalid;
    input awready;
    //写数据通道（以w开头）
    output [3:0] wid;
    output [31:0] wdata;
    output [3:0] wstrb;
    output wlast;
    output wvalid;
    input wready;
    //写响应通道（以b开头）
    input [3:0] bid;
    input [1:0] bresp;
    input bvalid;
    output bready;

    //debug
    output [31:0] debug_wb_pc;
    output [3:0] debug_wb_rf_wen;
    output [4:0] debug_wb_rf_wnum;
    output [31:0] debug_wb_rf_wdata;

    //
    wire [1:0] awid_t,wid_t,arid_t;
    
    assign awid = {2'b10,awid_t};
    assign wid = {2'b10,wid_t};
    assign arid = {2'b10,arid_t};

    //cache - cpu
    wire icache_valid;
    wire dcache_valid;
    wire uncache_valid;
    wire dcache_op;
    wire uncache_op;
    wire [6:0] icache_index;
    wire [7:0] dcache_index;
    wire [7:0] uncache_index;
    wire [19:0] icache_tag;
    wire [19:0] dcache_tag;
    wire [19:0] uncache_tag;
    wire [4:0] icache_offset;
    wire [3:0] dcache_offset;
    wire [3:0] uncache_offset;
    wire [3:0] dcache_wstrb;
    wire [3:0] uncache_wstrb;
    wire [31:0] dcache_wdata_cpu;
    wire [31:0] uncache_wdata_cpu;
    wire dcache_addr_ok;
    wire uncache_addr_ok;
    wire icache_data_ok;
    wire dcache_data_ok;
    wire uncache_data_ok;
    wire [31:0] icache_rdata_cpu;
    wire [31:0] dcache_rdata_cpu;
    wire [31:0] uncache_rdata_cpu;

    wire [2:0]  uncache_awsize_cpu;
    wire [2:0]  uncache_arsize_cpu;
    //cache - crossbar
    wire [31:0] icache_rdata,   dcache_rdata,   uncache_rdata;    
    wire [31:0] icache_araddr,  dcache_araddr,  uncache_araddr;//读请求起始地址
    wire [31:0]                 dcache_awaddr,  uncache_awaddr;

    wire [2:0]  uncache_axi_awsize,uncache_axi_arsize;

    //cache interface
    wire        icache_rd_rdy,      dcache_rd_rdy,  uncache_rd_rdy;
    wire        icache_rd_req,      dcache_rd_req,  uncache_rd_req;
    wire                            dcache_wr_rdy,  uncache_wr_rdy;
    wire                            dcache_wr_req,  uncache_wr_req;
    wire [127:0]                    dcache_wr_data;
    wire [31:0]                                     uncache_wr_data;
    wire        icache_ret_valid,   dcache_ret_valid,uncache_ret_valid;
    wire        icache_ret_last,    dcache_ret_last,uncache_ret_last;
    //interface crossbar
    wire                        dcache_awvalid, uncache_awvalid;
    wire        icache_awready, dcache_awready, uncache_awready;
    wire                        dcache_wvalid,  uncache_wvalid;
    wire                        dcache_wlast,   uncache_wlast;
    wire        icache_wready,  dcache_wready,  uncache_wready;
    wire        icache_arvalid, dcache_arvalid, uncache_arvalid;
    wire        icache_arready, dcache_arready, uncache_arready;
    wire        icache_rlast,   dcache_rlast,   uncache_rlast;
    wire        icache_rvalid,  dcache_rvalid,  uncache_rvalid;
    wire        icache_rready,  dcache_rready,  uncache_rready;
    wire [31:0]                 dcache_wdata,   uncache_wdata;
    wire [1:0]  icache_bresp,   dcache_bresp,   uncache_bresp;
    wire        icache_bvalid,  dcache_bvalid,  uncache_bvalid;
    wire                        dcache_bready,  uncache_bready;
   
    //暂时没用
    wire [1:0]  icache_bid,         dcache_bid,     uncache_bid;
    wire [1:0]  icache_rid,         dcache_rid,     uncache_rid;
    wire [3:0]                                      uncache_axi_wstrb;
    wire [1:0]  icache_rresp,       dcache_rresp,   uncache_rresp;


    mycpu_to_cache U_mycpu_to_cache(
        .clk(aclk), .resetn(aresetn), .ext_int(ext_int), 
        .icache_valid(icache_valid), .icache_index(icache_index), .icache_tag(icache_tag), .icache_offset(icache_offset), 
        .icache_data_ok(icache_data_ok), .icache_rdata(icache_rdata_cpu),
        
        .dcache_valid(dcache_valid), .dcache_op(dcache_op), .dcache_index(dcache_index), .dcache_tag(dcache_tag), .dcache_offset(dcache_offset), 
        .dcache_wstrb(dcache_wstrb), .dcache_wdata(dcache_wdata_cpu), 
        .dcache_addr_ok(dcache_addr_ok), .dcache_data_ok(dcache_data_ok), .dcache_rdata(dcache_rdata_cpu),
        
        .uncache_valid(uncache_valid), .uncache_op(uncache_op), .uncache_index(uncache_index), .uncache_tag(uncache_tag), .uncache_offset(uncache_offset), 
        .uncache_wstrb(uncache_wstrb), .uncache_wdata(uncache_wdata_cpu), 
        .uncache_addr_ok(uncache_addr_ok), .uncache_data_ok(uncache_data_ok), .uncache_rdata(uncache_rdata_cpu),
        .uncache_arsize(uncache_arsize_cpu), .uncache_awsize(uncache_awsize_cpu),
        //debug
        .debug_wb_pc(debug_wb_pc), .debug_wb_rf_wen(debug_wb_rf_wen), .debug_wb_rf_wnum(debug_wb_rf_wnum), .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    ICache U_ICache(
        .clk(aclk), .rst(~aresetn),
        .cpu_valid(icache_valid), 
        .rd_req(icache_rd_req), 
        .rd_rdy(icache_rd_rdy), 
        .rd_addr(icache_araddr),
        .ret_data(icache_rdata),
        .ret_valid(icache_ret_valid),
        .ret_last(icache_ret_last),
        .data_ok(icache_data_ok),
        .index(icache_index), 
        .tag(icache_tag[16:0]), 
        .offset(icache_offset[4:2]), 
        .rdata(icache_rdata_cpu)
    );
/*
clk, rst, cpu_valid, rd_req, rd_rdy, rd_addr, ret_data, ret_valid, ret_last, 
data_ok, index, tag, offset,
rdata
*/
    icache_axi_interface Icache_interface(
        .clk(aclk), .resetn(aresetn),
        //cache
        //input
        .rd_req(icache_rd_req), //cache->interface
        //ouput
        .rd_rdy(icache_rd_rdy), //interface->cache
        .ret_valid(icache_ret_valid), //interface->cache
        .ret_last(icache_ret_last), //interface->cache

        //axi
        //input
        .arready(icache_arready), //axi->interface，读请求地址握手信号,axi准备好接收地址传输
        .rlast(icache_rlast) ,//axi->interface
        .rvalid(icache_rvalid), //axi->interface,读请求数据握手信号，读请求数据有效
        //output
        .arvalid(icache_arvalid), //interface->axi,读请求地址握手信号,读请求地址有效
        .rready(icache_rready) //interface->axi,rready是cache是否准备好接收数据信号
    );

    DCache U_DCache(
        .clk(aclk), .rst(~aresetn), 
        .cpu_valid(dcache_valid), 
        .op(dcache_op), 
        .rd_req(dcache_rd_req),         
        .rd_rdy(dcache_rd_rdy), 
        .rd_addr(dcache_araddr), 
        .ret_data(dcache_rdata), 
        .ret_valid(dcache_ret_valid), 
        .ret_last(dcache_ret_last), 
        .wr_rdy(dcache_wr_rdy),
        .wr_req(dcache_wr_req), 
        .wr_data(dcache_wr_data), 
        .data_ok(dcache_data_ok), 
        .index(dcache_index), 
        .tag(dcache_tag[16:0]), 
        .offset(dcache_offset[3:2]), 
        .cpu_wstrb(dcache_wstrb), 
        .from_cpu_wdata(dcache_wdata_cpu), 
        .rdata(dcache_rdata_cpu),
        .addr_ok(dcache_addr_ok), 
        .wr_addr(dcache_awaddr)
    );

    dcache_axi_interface Dcache_interface(
        .clk(aclk), .resetn(aresetn),
        //cache
        //input
        .rd_req(dcache_rd_req), //cache->interface
        .wr_req(dcache_wr_req), //cache->interface
        .wr_data_cache(dcache_wr_data), //cache->interface
        //output
        .rd_rdy(dcache_rd_rdy), //interface->cache
        .wr_rdy(dcache_wr_rdy), //interface->cache
        .ret_valid(dcache_ret_valid), //interface->cache
        .ret_last(dcache_ret_last), //interface->cache

        //axi
        //input
        .awready(dcache_awready), //axi->interface，写请求地址握手信号,axi准备好接收地址传输
        .arready(dcache_arready), //axi->interface，读请求地址握手信号,axi准备好接收地址传输
        .wready(dcache_wready), //axi->interface,写请求地址握手信号,axi准备好接收数据传输
        .rlast(dcache_rlast) , //axi->interface
        .bresp(dcache_bresp), //axi->interface
        .bvalid(dcache_bvalid), //axi->interface,写请求响应握手信号，写请求响应有效
        .rvalid(dcache_rvalid), //axi->interface,读请求数据握手信号，读请求数据有效
        //output
        .awvalid(dcache_awvalid), //interface->axi,写请求地址握手信号,写请求地址有效
        .arvalid(dcache_arvalid), //interface->axi,读请求地址握手信号,读请求地址有效
        .wvalid(dcache_wvalid), //interface->axi,写请求数据握手信号,写请求数据有效
        .wlast(dcache_wlast), //interface->axi
        .rready(dcache_rready), //interface->axi,rready是cache是否准备好接收数据信号
        .bready(dcache_bready), //interface->axi,cache准备好接受写响应
        .wdata(dcache_wdata) //interface->axi
    );

    Uncache U_Uncache(
        .clk(aclk),.rst(~aresetn), 
        .cpu_valid(uncache_valid), 
        .op(uncache_op), 
        .addr({uncache_tag,uncache_index,uncache_offset}), 
        .cpu_wstrb(uncache_wstrb), 
        .arsize(uncache_arsize_cpu),
        .awsize(uncache_awsize_cpu),
        .wdata(uncache_wdata_cpu), 
        .addr_ok(uncache_addr_ok), 
        .data_ok(uncache_data_ok), 
        .rdata(uncache_rdata_cpu),
        .rd_rdy(uncache_rd_rdy), 
        .ret_valid(uncache_ret_valid), 
        .ret_data(uncache_rdata), 
        .rd_req(uncache_rd_req), 
        .rd_addr(uncache_araddr), 
        .wr_req(uncache_wr_req), 
        .wr_addr(uncache_awaddr),
        .axi_wstrb(uncache_axi_wstrb), 
        .wr_data(uncache_wr_data), 
        .wr_rdy(uncache_wr_rdy),
        .axi_awsize(uncache_axi_awsize),
        .axi_arsize(uncache_axi_arsize)
    );

    uncache_axi_interface D_uncache_interface(
        .clk(aclk), .resetn(aresetn),
        //cache
        //input
        .rd_req(uncache_rd_req), //cache->interface
        .wr_req(uncache_wr_req), //cache->interface
        .wr_data_cache(uncache_wr_data), //cache->interface
        //output
        .rd_rdy(uncache_rd_rdy), //interface->cache
        .wr_rdy(uncache_wr_rdy), //interface->cache
        .ret_valid(uncache_ret_valid), //interface->cache
        .ret_last(uncache_ret_last), //interface->cache

        //axi
        //input
        .awready(uncache_awready), //axi->interface,写请求地址握手信号,axi准备好接收地址传输
        .arready(uncache_arready), //axi->interface,读请求地址握手信号,axi准备好接收地址传输
        .wready(uncache_wready), //axi->interface,写请求地址握手信号,axi准备好接收数据传输
        .rlast(uncache_rlast) , //axi->interface
        .bresp(uncache_bresp), 
        .bvalid(uncache_bvalid), //axi->interface,写请求响应握手信号，写请求响应有效
        .rvalid(uncache_rvalid), //axi->interface,读请求数据握手信号，读请求数据有效
        //output
        .awvalid(uncache_awvalid), //interface->axi,写请求地址握手信号,写请求地址有效
        .arvalid(uncache_arvalid), //interface->axi,读请求地址握手信号,读请求地址有效
        .wvalid(uncache_wvalid), //interface->axi,写请求数据握手信号,写请求数据有效
        .wlast(uncache_wlast), //interface->axi
        .rready(uncache_rready), //interface->axi,rready是cache是否准备好接收数据信号
        .bready(uncache_bready), //interface->axi,cache准备好接受写响应
        .wdata(uncache_wdata) //interface->axi
    );
    /*
    ldblx DCache_axi_transfer(
        .reset(~aresetn), .clk(aclk),
        .wr_data(dcache_wr_data), .ready(dcache_wr_req&dcache_wready), .dcache_wdata(dcache_axi_wdata),.dcache_axi_last(dcache_axi_wlast), .wr_rdy(dcache_wr_rdy)
    );
    */
    axi_crossbar_0 U_axi_crossbar_0(
        .aclk(aclk), .aresetn(aresetn),
        .s_axi_awid(6'b00_00_00), 
        .s_axi_awaddr({32'b0,dcache_awaddr,uncache_awaddr}), 
        .s_axi_awlen(12'b0111_0011_0000), //突发式写的长度。此长度决定突发式写所传输的数据的个数
        //awlen每次传输数据个数4=3+1(011)
        .s_axi_awsize({6'b010_010,uncache_axi_awsize}),//一拍传输2^2Byte(010)32位
        .s_axi_awburst(6'b01_01_01), 
        .s_axi_awlock(6'b00_00_00), 
        .s_axi_awcache(12'b0), 
        .s_axi_awprot(9'b0), 
        .s_axi_awqos(12'b0), 
        .s_axi_awvalid({1'b0,dcache_awvalid,uncache_awvalid}),//interface->axi
        .s_axi_awready({icache_awready,dcache_awready,uncache_awready}),//axi->interface
        .s_axi_wid(6'b00_00_00), 
        .s_axi_wdata({32'b0,dcache_wdata,uncache_wdata}), //interface->axi
        .s_axi_wstrb({4'b1111,4'b1111,uncache_axi_wstrb}), 
        .s_axi_wlast({1'b0,dcache_wlast,uncache_wlast}), //interface->axi
        .s_axi_wvalid({1'b0,dcache_wvalid,uncache_wvalid}), //interface->axi
        .s_axi_wready({icache_wready,dcache_wready,uncache_wready}), //axi->interface
        .s_axi_bid({icache_bid,dcache_bid,uncache_bid}), //写请求的ID号，同一请求的bid wid awid应一致（可忽略）
        .s_axi_bresp({icache_bresp,dcache_bresp,uncache_bresp}), //写请求控制信号，本次写请求是否成功完成（可忽略）
        .s_axi_bvalid({icache_bvalid,dcache_bvalid,uncache_bvalid}), //axi->interface 写请求响应握手信号，写请求响应有效
        //bvalid只能在wlast有效之后才能有效 
        .s_axi_bready({1'b1,dcache_bready,uncache_bready}),//interface->axi,cache准备好接受写响应

        .s_axi_arid(6'b00_00_00), 
        .s_axi_araddr({icache_araddr,dcache_araddr,uncache_araddr}), 
        .s_axi_arlen(12'b0111_0011_0000), 
        .s_axi_arsize({6'b010_010,uncache_axi_arsize}),//此接口不确定！！，四字节对应2^2，16字节对应2^4
        .s_axi_arburst(6'b01_01_01), 
        .s_axi_arlock(6'b00_00_00), 
        .s_axi_arcache(12'b0), 
        .s_axi_arprot(9'b0), 
        .s_axi_arqos(12'b0), 
        .s_axi_arvalid({icache_arvalid,dcache_arvalid,uncache_arvalid}), //interface->axi,读请求地址握手信号,读请求地址有效
        .s_axi_arready({icache_arready,dcache_arready,uncache_arready}), ////axi->interface,读请求地址握手信号,axi准备好接收地址传输
        .s_axi_rid({icache_rid,dcache_rid,uncache_rid}), //可忽略
        .s_axi_rdata({icache_rdata,dcache_rdata,uncache_rdata}), //axi->cache,读请求的返回数据
        .s_axi_rresp({icache_rresp,dcache_rresp,uncache_rresp}), //可忽略
        .s_axi_rlast({icache_rlast,dcache_rlast,uncache_rlast}), //axi->interface,本次读请求的最后一拍数据的指示信号
        .s_axi_rvalid({icache_rvalid,dcache_rvalid,uncache_rvalid}), //axi->interface,写请求响应握手信号，写请求响应有效
        .s_axi_rready({icache_rready,dcache_rready,uncache_rready}),//interface->axi,rready是cache是否准备好接收数据信号

        .m_axi_awid       ( awid_t),
        .m_axi_awaddr     ( awaddr),
        .m_axi_awlen      ( awlen),
        .m_axi_awsize     ( awsize),
        .m_axi_awburst    ( awburst),
        .m_axi_awlock     ( awlock),
        .m_axi_awcache    ( awcache),
        .m_axi_awprot     ( awprot),
        .m_axi_awqos      (                            ),
        .m_axi_awvalid    ( awvalid),
        .m_axi_awready    ( awready),
        .m_axi_wid        ( wid_t),
        .m_axi_wdata      ( wdata),
        .m_axi_wstrb      ( wstrb),
        .m_axi_wlast      ( wlast),
        .m_axi_wvalid     ( wvalid),
        .m_axi_wready     ( wready),
        .m_axi_bid        ( bid[1:0]),
        .m_axi_bresp      ( bresp),
        .m_axi_bvalid     ( bvalid),
        .m_axi_bready     ( bready),
        .m_axi_arid       ( arid_t),
        .m_axi_araddr     ( araddr),
        .m_axi_arlen      ( arlen),
        .m_axi_arsize     ( arsize),
        .m_axi_arburst    ( arburst),
        .m_axi_arlock     ( arlock),
        .m_axi_arcache    ( arcache),
        .m_axi_arprot     ( arprot),
        .m_axi_arqos      (                            ),
        .m_axi_arvalid    ( arvalid),
        .m_axi_arready    ( arready),
        .m_axi_rid        ( rid[1:0]),
        .m_axi_rdata      ( rdata),
        .m_axi_rresp      ( rresp),
        .m_axi_rlast      ( rlast),
        .m_axi_rvalid     ( rvalid ),
        .m_axi_rready     ( rready)  
    );


endmodule