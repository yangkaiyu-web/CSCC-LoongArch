module ICache(
clk, rst, cpu_valid, rd_req, rd_rdy, rd_addr, ret_data, ret_valid, ret_last, 
data_ok, index, tag, offset,
rdata
);

input clk,rst;

//cpu->cache握手信号
input cpu_valid;
//

//请求读axi时的握手信号
output rd_req;
input rd_rdy; //读请求能否被接收的握手信�???
//

output [31:0] rd_addr; //axi->cache读请求起始地�???
input [31:0] ret_data; //读返回数�???

//axi数据返回cache时的信号
input ret_valid; //返回数据有效
input ret_last;

//cache->cpu握手信号
output data_ok;       //在读返回数据以及写完成时�???1

//读写地址
input [6:0] index;
input [16:0] tag;
input [2:0] offset;

output [31:0] rdata;

wire [6:0] index_1;
wire [16:0] tag_1,ram0_tag,ram1_tag;
wire [2:0] offset_1;
wire ram_en;
wire Write_en0,Write_en1;
wire ram0_v,ram1_v;
wire real_last;
wire replace_way;
wire cache_hit;
wire way0_hit,way1_hit;
wire [255:0] way0_data,way1_data;
wire [255:0] axi_return_data;
wire Miss_Stall;

assign rd_addr = {3'b0,tag_1,index_1,5'b0};

Pipeline_reg U_Pipeline_reg(
.clk(clk),.rst(rst),.MISS_StaLL(Miss_Stall),.index(index),.tag(tag),.offset(offset),.ret_last(ret_last),.ret_valid(ret_valid),.cpu_valid(cpu_valid),
.index_1(index_1),.tag_1(tag_1),.offset_1(offset_1)
);

Signal_Select U_Signal_Select(
.ram_en(ram_en),.ret_last(ret_last),.ret_valid(ret_valid),.replace_way(replace_way),.Write_en0(Write_en0),.Write_en1(Write_en1)
);

Tag_Compare U_Tag_Compare(
.ram0_v(ram0_v),.ram1_v(ram1_v),.ram0_tag(ram0_tag),.ram1_tag(ram1_tag),.tag_1(tag_1),
.cache_hit(cache_hit),.way0_hit(way0_hit),.way1_hit(way1_hit)
);

Data_Select U_Data_Select(
.offset_1(offset_1),.way0_data(way0_data),.way1_data(way1_data),.way1_hit(way1_hit),.way0_hit(way0_hit),.axi_return_data(axi_return_data),.real_last(real_last),
.rdata(rdata),.data_ok(data_ok)
);

Miss_Buffer U_Miss_Buffer(
.clk(clk),.rst(rst),.ret_data(ret_data),.ret_last(ret_last),.ret_valid(ret_valid),.cpu_valid(cpu_valid),
.real_last(real_last),.axi_return_data(axi_return_data)
);

LRU U_LRU(
.clk(clk),.rst(rst),.index_1(index_1),.way0_hit(way0_hit),.way1_hit(way1_hit),
.replace_way(replace_way)
);

Cache_FSM_Master U_Cache_FSM_Master(
.clk(clk),.rst(rst),.cpu_valid(cpu_valid),.cache_hit(cache_hit),.rd_rdy(rd_rdy),.ret_last(ret_last),.ret_valid(ret_valid),
.ram_en(ram_en),.Miss_Stall(Miss_Stall),.rd_req(rd_req)
);

//两路页表
Way_TagV U_I_Way0TagV(
.clka(clk),.addra(index_1),.dina({tag_1,1'b1}),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb({ram0_tag,ram0_v}),.enb(ram_en)
);

Way_Bank U_I_Way0Bank0(
.clka(clk),.addra(index_1),.dina(axi_return_data[31:0]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[31:0]),.enb(ram_en)
);

Way_Bank U_I_Way0Bank1(
.clka(clk),.addra(index_1),.dina(axi_return_data[63:32]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[63:32]),.enb(ram_en)
);

Way_Bank U_I_Way0Bank2(
.clka(clk),.addra(index_1),.dina(axi_return_data[95:64]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[95:64]),.enb(ram_en) 
);

Way_Bank U_I_Way0Bank3(
.clka(clk),.addra(index_1),.dina(axi_return_data[127:96]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[127:96]),.enb(ram_en)
);

Way_Bank U_I_Way0Bank4(
.clka(clk),.addra(index_1),.dina(axi_return_data[159:128]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[159:128]),.enb(ram_en)
);

Way_Bank U_I_Way0Bank5(
.clka(clk),.addra(index_1),.dina(axi_return_data[191:160]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[191:160]),.enb(ram_en)
);

Way_Bank U_I_Way0Bank6(
.clka(clk),.addra(index_1),.dina(axi_return_data[223:192]),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[223:192]),.enb(ram_en) 
);

Way_Bank U_I_Way0Bank7(
.clka(clk),.addra(index_1),.dina(ret_data),.ena(Write_en0),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data[255:224]),.enb(ram_en)
);

Way_TagV U_I_Way1TagV(
.clka(clk),.addra(index_1),.dina({tag_1,1'b1}),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb({ram1_tag,ram1_v}),.enb(ram_en)
);

Way_Bank U_I_Way1Bank0(
.clka(clk),.addra(index_1),.dina(axi_return_data[31:0]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[31:0]),.enb(ram_en) 
);

Way_Bank U_I_Way1Bank1(
.clka(clk),.addra(index_1),.dina(axi_return_data[63:32]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[63:32]),.enb(ram_en) 
);

Way_Bank U_I_Way1Bank2(
.clka(clk),.addra(index_1),.dina(axi_return_data[95:64]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[95:64]),.enb(ram_en)  
);

Way_Bank U_I_Way1Bank3(
.clka(clk),.addra(index_1),.dina(axi_return_data[127:96]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[127:96]),.enb(ram_en) 
);

Way_Bank U_I_Way1Bank4(
.clka(clk),.addra(index_1),.dina(axi_return_data[159:128]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[159:128]),.enb(ram_en) 
);

Way_Bank U_I_Way1Bank5(
.clka(clk),.addra(index_1),.dina(axi_return_data[191:160]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[191:160]),.enb(ram_en) 
);

Way_Bank U_I_Way1Bank6(
.clka(clk),.addra(index_1),.dina(axi_return_data[223:192]),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[223:192]),.enb(ram_en)  
);

Way_Bank U_I_Way1Bank7(
.clka(clk),.addra(index_1),.dina(ret_data),.ena(Write_en1),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data[255:224]),.enb(ram_en) 
);

endmodule


module Pipeline_reg(
clk,rst,index,tag,offset,cpu_valid,MISS_StaLL,ret_last,ret_valid,
index_1,tag_1,offset_1
);
input clk,rst;
input [6:0] index;
input [16:0] tag;
input [2:0] offset;
input cpu_valid;
input MISS_StaLL;
input ret_last,ret_valid;
output reg [6:0] index_1;
output reg [16:0] tag_1;
output reg [2:0] offset_1;

always@(posedge clk)
begin
    if(!MISS_StaLL && !(ret_valid & ret_last) && cpu_valid)
    begin
        index_1 <= index;
        tag_1 <= tag;
        offset_1 <= offset;
    end
end

endmodule


module Signal_Select(
ram_en,ret_last,ret_valid,replace_way,Write_en0,Write_en1
);
input ram_en;
input ret_last,ret_valid;
input replace_way;
output Write_en0,Write_en1;

assign Write_en0 = ret_last && ret_valid && !replace_way ;
assign Write_en1 = ret_last && ret_valid &&  replace_way ;

endmodule


module Tag_Compare(
ram0_v,ram1_v,ram0_tag,ram1_tag,tag_1,
cache_hit,way0_hit,way1_hit
);

input ram0_v,ram1_v;
input [16:0] ram0_tag,ram1_tag,tag_1;
output cache_hit;
output way0_hit,way1_hit;

assign way0_hit = ram0_v && ( ram0_tag == tag_1 );
assign way1_hit = ram1_v && ( ram1_tag == tag_1 );
assign cache_hit = way0_hit || way1_hit;

endmodule

//可修改
module Data_Select(
way0_data,way1_data,offset_1,way1_hit,axi_return_data,real_last,way0_hit,
rdata,data_ok
);
input [2:0] offset_1;
input way0_hit,way1_hit;
input [255:0] way0_data,way1_data;
input [255:0] axi_return_data;
input real_last;
output [31:0] rdata;
output data_ok;

wire [31:0] way0_load_word;
wire [31:0] way1_load_word;
wire [31:0] rdata_temp;

//变量[结束地址 -: 数据位宽] <–等价于�???> 变量[结束地址�???(结束地址-数据位宽+1)]
assign way0_load_word = way0_data[ (offset_1*32+31) -: 32 ];
assign way1_load_word = way1_data[ (offset_1*32+31) -: 32 ];
assign rdata_temp = way0_hit ? way0_load_word : way1_load_word;
assign rdata = real_last ? axi_return_data[(offset_1*32+31) -: 32] : rdata_temp;
assign data_ok = real_last || way0_hit || way1_hit ;

endmodule


module Miss_Buffer(
clk,rst,ret_data,ret_last,ret_valid,cpu_valid,
real_last,axi_return_data
);
input clk,rst;
input ret_last;
input ret_valid;
input [31:0] ret_data;
input cpu_valid;
output reg real_last;
output reg [255:0] axi_return_data;

reg [2:0] num;

always@(posedge clk)
begin
    if(ret_valid & ret_last)
        real_last <= 1;

    else if(cpu_valid)
        real_last <= 0;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        num <= 0;
    else if(ret_valid & ret_last)
        num <= 0;
    else if(ret_valid)
        num <= num + 1;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        axi_return_data <= 0;
    else if(ret_valid)
        axi_return_data[(num*32+31) -: 32] <= ret_data;
end

endmodule


module LRU(
clk,rst,index_1,way0_hit,way1_hit,
replace_way
);
input clk,rst;
input way0_hit,way1_hit;
input [6:0] index_1;
output replace_way;

reg [127:0] flag0;   //记录�???近使用过的一�???

always@(posedge clk or posedge rst)
begin
    if(rst)
        flag0[127:0] = {128{1'b1}};

    else if(way0_hit)
        flag0[index_1] = 1;

    else if(way1_hit)
        flag0[index_1] = 0;
end

assign replace_way = flag0[index_1] ;

endmodule
