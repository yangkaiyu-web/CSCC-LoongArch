module DM_EXT(Addr_Last,Din,LenthLoad,Sign,Dout);
    input [1:0] Addr_Last;
    input [1:0] LenthLoad;
    input [31:0] Din;
    input Sign;
    output reg [31:0] Dout;

    always@(Din or Sign or Addr_Last or LenthLoad)
	case(LenthLoad)
		2'b11:Dout = Din[31:0];	//lw
		2'b01:begin	//lh(u)
            if(Addr_Last[1])
                Dout = {{16{Din[31]&Sign}},Din[31:16]};
            else
                Dout = {{16{Din[15]&Sign}},Din[15:0]};
		end
		2'b00:begin	//lb(u)
            case (Addr_Last)
                2'b11: Dout = {{24{Din[31]&Sign}},Din[31:24]};
                2'b10: Dout = {{24{Din[23]&Sign}},Din[23:16]};
                2'b01: Dout = {{24{Din[15]&Sign}},Din[15:8]};
                default: Dout = {{24{Din[7]&Sign}},Din[7:0]};
            endcase
		end
        default:Dout = Din[31:0];
	endcase


endmodule