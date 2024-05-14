module icache_axi_interface(
    clk,resetn,
    rd_rdy,rd_req,ret_valid,ret_last,
    arvalid,arready,rlast,rvalid,rready
);
    input       clk;
    input       resetn;
//cache
    output      rd_rdy;
    input       rd_req;
    output      ret_valid;
    output      ret_last;
//axi
    output reg  arvalid;
    input       arready;
    input       rlast;
    input       rvalid;
    output      rready;
   
    reg reading;

//cache read axi
    assign rd_rdy = !reading;  
    assign ret_valid = rvalid;
    assign ret_last = rlast; 

    always @(posedge clk or negedge resetn)
    begin
        if(~resetn)
            reading <= 0;
        else if(~reading & rd_req)
            reading <= 1;
        else if(rvalid & rlast)
            reading <= 0;
        else
            reading <= reading;
    end

    //address
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            arvalid <= 0;
        else if(arvalid & arready)//握手成功
            arvalid <= 0;
        else if(~reading & rd_req)
            arvalid <= 1;
        else
            arvalid <= arvalid;
    end

    //data
    assign rready = 1;
endmodule






module dcache_axi_interface(
    clk,resetn,
    rd_rdy,rd_req,wr_rdy,wr_req,ret_valid,ret_last,
    wr_data_cache,
    awvalid,awready,wvalid,wlast,wready,arvalid,arready,rlast,rvalid,rready,
    wdata,
    bresp,bvalid,bready
);
    input       clk;
    input       resetn;
//cache
    output      rd_rdy;
    input       rd_req;
    output      wr_rdy;
    input       wr_req;
    output      ret_valid;
    output      ret_last;
    input [127:0] wr_data_cache;
//axi
    output reg  awvalid;
    input       awready;
    output      wlast;
    output reg  wvalid;
    input       wready;
    output[31:0]wdata;
    output reg  arvalid;
    input       arready;
    input       rlast;
    input       rvalid;
    output      rready;
    input [1:0] bresp;
    input       bvalid;
    output      bready;
    
    reg writing,reading;
    reg [1:0]   num;
    reg [127:0] Write_buff;

    assign bready = writing;

//cache write axi
    assign wr_rdy = !writing;   

    always @(posedge clk or negedge resetn)
    begin
        if(~resetn)
            writing <= 0;
        else if(~writing & wr_req)
            writing <= 1;
        else if(writing & bvalid & ~bresp[1])
            writing <= 0;
        else
            writing <= writing;
    end

    //address
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            awvalid <= 0;
        else if(awvalid & awready)//握手成功
            awvalid <= 0;
        else if(!writing & wr_req)
            awvalid <= 1;
        else
            awvalid <= awvalid;
    end

    //data
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            wvalid <= 0;
        else if(awvalid & awready)
            wvalid <= 1;
        else if(wlast & wready)
            wvalid <= 0;
        else
            wvalid <= wvalid;
    end

    always @(posedge clk)
    begin
        if(~resetn)
            Write_buff <= 128'b0;
        else if(!writing & wr_req)
            Write_buff <= wr_data_cache;
    end

    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            num <= 0;
        else if(|num & wready)//num != 0 ,正在传输
            num <= num + 1;
        else if(wvalid & wready)//握手成功
            num <= 2'b01;
    end    

    assign wlast = &num;//num = 2'b11,last data

    assign wdata = Write_buff[(num*32+31) -: 32];

//cache read axi
    assign rd_rdy = !reading;  
    assign ret_valid = rvalid;
    assign ret_last = rlast; 

    always @(posedge clk or negedge resetn)
    begin
        if(~resetn)
            reading <= 0;
        else if(~reading & rd_req)
            reading <= 1;
        else if(rvalid & rlast)
            reading <= 0;
        else
            reading <= reading;
    end

    //address
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            arvalid <= 0;
        else if(arvalid & arready)//握手成功
            arvalid <= 0;
        else if(~reading & rd_req)
            arvalid <= 1;
        else
            arvalid <= arvalid;
    end

    //data
    assign rready = 1;
endmodule

module uncache_axi_interface(
    clk,resetn,
    rd_rdy,rd_req,wr_rdy,wr_req,ret_valid,ret_last,
    wr_data_cache,
    awvalid,awready,wvalid,wlast,wready,arvalid,arready,rlast,rvalid,rready,
    wdata,
    bresp,bvalid,bready
);
    input       clk;
    input       resetn;
//cache
    output      rd_rdy;
    input       rd_req;
    output      wr_rdy;
    input       wr_req;
    output      ret_valid;
    output      ret_last;
    input [31:0] wr_data_cache;
//axi
    output reg  awvalid;
    input       awready;
    output      wlast;
    output reg  wvalid;
    input       wready;
    output[31:0]wdata;
    output reg  arvalid;
    input       arready;
    input       rlast;
    input       rvalid;
    output      rready;
    input [1:0] bresp;
    input       bvalid;
    output      bready;
    
    reg writing,reading;
    reg [31:0] Write_buff;

    assign bready = writing;
    assign wlast = 1;

//cache write axi
    assign wr_rdy = !(writing | reading);   

    always @(posedge clk or negedge resetn)
    begin
        if(~resetn)
            writing <= 0;
        else if(~writing & wr_req)
            writing <= 1;
        else if(writing & bvalid & ~bresp[1])
            writing <= 0;
        else
            writing <= writing;
    end

    //address
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            awvalid <= 0;
        else if(awvalid & awready)//握手成功
            awvalid <= 0;
        else if(!writing & wr_req)
            awvalid <= 1;
        else
            awvalid <= awvalid;
    end

    //data
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            wvalid <= 0;
        else if(awvalid & awready)
            wvalid <= 1;
        else if(wvalid & wready)
            wvalid <= 0;
        else
            wvalid <= wvalid;
    end

    always @(posedge clk)
    begin
        if(~resetn)
            Write_buff <= 32'b0;
        else if(!writing & wr_req)
            Write_buff <= wr_data_cache;
    end

    assign wdata = Write_buff;

//cache read axi
    assign rd_rdy = !(writing | reading);  
    assign ret_valid = rvalid;
    assign ret_last = rlast; 

    always @(posedge clk or negedge resetn)
    begin
        if(~resetn)
            reading <= 0;
        else if(~reading & rd_req & ~wr_req)
            reading <= 1;
        else if(rvalid & rlast)
            reading <= 0;
        else
            reading <= reading;
    end

    //address
    always @(posedge clk or negedge resetn) 
    begin
        if(~resetn)
            arvalid <= 0;
        else if(arvalid & arready)//握手成功
            arvalid <= 0;
        else if(~reading & rd_req & ~wr_req)
            arvalid <= 1;
        else
            arvalid <= arvalid;
    end

    //data
    assign rready = 1;
endmodule