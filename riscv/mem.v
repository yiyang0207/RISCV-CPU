`include "config.v"

module MEM (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //EX_MEM
    input  wire [`OptBus] inst_i,
    input  wire [`RegAddrBus] rd_i,
    input  wire [`RegBus] vd_i,
    input  wire w_enable_i,
    input  wire [`AddrBus] memctrl_addr_i,

    //MEM_WB
    output reg [`RegAddrBus] rd_o, //also output to id
    output reg [`RegBus] vd_o, //also output to id
    output reg w_enable_o, 

    //ID
    output reg r_finished,

    //mem_ctrl
    input  wire mem_ctrl_finished,
    input  wire [`RegBus] mem_ctrl_data_i,
    input  wire mem_ctrl_if_busy,
    input  wire mem_ctrl_mem_busy,
    output reg mem_ctrl_enable,
    output reg [`AddrBus] mem_ctrl_addr_o,
    output reg [2:0] mem_ctrl_data_len,
    output reg [`RegBus] mem_ctrl_data_o, 
    output reg mem_ctrl_rw_sel,

    output reg mem_stall
);

reg [`RegBus] dcache[`DcacheBus];
reg valid[`DcacheBus];
reg [`DcacheTag] tag[`DcacheBus];
reg [`RegBus] cache_data;
reg [`InstBus] cache_addr;
reg cache_modified;
reg cache_finished;

wire [`DcacheIndex] index;
wire [`DcacheTag] cache_tag;
wire [`DcacheTag] supposed_tag;
wire cache_valid;
wire [`RegBus] data;
assign index=memctrl_addr_i[`DcacheIndexBus];
assign cache_tag=memctrl_addr_i[`DcacheTagBus];
assign supposed_tag=tag[index];
assign cache_valid=valid[index];
assign data=dcache[index];

always @(*) begin
    if(rst==`Enable) begin
        r_finished=`Disable;
        mem_ctrl_enable=`Disable;
        mem_ctrl_addr_o=`ZeroWord;
        mem_ctrl_data_len=`ZeroDataLen;
        mem_ctrl_data_o=`ZeroWord;
        mem_ctrl_rw_sel=`Disable;
        mem_stall=`Disable;
        cache_data=`ZeroWord;
        cache_addr=`ZeroWord;
        cache_finished=`Disable;
        cache_modified=`Disable;
    end else begin
        case (inst_i)
            `LB,`LH,`LW,`LBU,`LHU:begin //load
                if(cache_valid==`Enable&&cache_tag==supposed_tag) begin
                    cache_finished=`Enable;
                    cache_modified=`Disable;
                    cache_addr=memctrl_addr_i;
                    cache_data=`ZeroWord;
                    case (inst_i)
                        `LB,`LBU:begin
                            case (memctrl_addr_i[1:0])
                                2'b00:cache_data={24'b0,data[7:0]};
                                2'b01:cache_data={24'b0,data[15:8]};
                                2'b10:cache_data={24'b0,data[23:16]};
                                2'b11:cache_data={24'b0,data[31:24]};
                            endcase
                        end
                        `LH,`LHU:begin
                            case (memctrl_addr_i[1:0])
                                2'b00:cache_data={16'b0,data[15:0]};
                                2'b10:cache_data={16'b0,data[31:16]};
                            endcase
                        end
                        `LW:begin
                            cache_data=data;
                        end
                    endcase
                    mem_ctrl_enable=`Disable;
                    mem_ctrl_rw_sel=1'b0;
                    mem_ctrl_addr_o=`ZeroWord;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_data_len=`ZeroDataLen;
                    mem_stall=`Disable;
                    r_finished=`Enable;
                end else if(mem_ctrl_finished==`Enable) begin
                    r_finished=`Enable;
                    mem_ctrl_enable=`Disable;
                    mem_ctrl_rw_sel=1'b0;
                    mem_ctrl_addr_o=`ZeroWord;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_data_len=`ZeroDataLen;
                    mem_stall=`Disable;
                    cache_finished=`Enable;
                    cache_addr=memctrl_addr_i;
                    cache_data=mem_ctrl_data_i;
                    case (inst_i)
                        `LW:cache_modified=`Enable; 
                        default:cache_modified=`Disable;
                    endcase
                end else begin
                    r_finished=`Disable;
                    if(mem_ctrl_if_busy==`Disable) begin
                        mem_ctrl_enable=`Enable;
                        mem_ctrl_rw_sel=1'b0;
                        mem_ctrl_addr_o=memctrl_addr_i;
                    end else if(mem_ctrl_if_busy==`Enable) begin
                        mem_ctrl_enable=`Disable;
                        mem_ctrl_rw_sel=1'b0;
                        mem_ctrl_addr_o=`ZeroWord;
                    end
                    case (inst_i)
                        `LB,`LBU:mem_ctrl_data_len=3'b001;
                        `LH,`LHU:mem_ctrl_data_len=3'b010;
                        `LW:mem_ctrl_data_len=3'b100;
                    endcase
                    mem_ctrl_data_o=`ZeroWord;
                    mem_stall=`Enable;
                    cache_finished=`Disable;
                    cache_modified=`Disable;
                    cache_addr=`ZeroWord;
                    cache_data=`ZeroWord;
                end
            end //end load

            `SB,`SH,`SW:begin //store
                if(mem_ctrl_finished==`Enable) begin
                    r_finished=`Disable;
                    mem_ctrl_enable=`Disable;
                    mem_ctrl_rw_sel=1'b0;
                    mem_stall=`Disable;
                    mem_ctrl_addr_o=`ZeroWord;
                    mem_ctrl_data_o=`ZeroWord;
                    cache_finished=`Enable;
                    cache_addr=memctrl_addr_i;
                    cache_data=vd_i;
                    case (inst_i)
                        `SW:cache_modified=`Enable; 
                        default:cache_modified=`Disable;
                    endcase
                end else begin
                    if(mem_ctrl_if_busy==`Disable) begin
                        mem_ctrl_enable=`Enable;
                        mem_ctrl_rw_sel=1'b1;
                        mem_ctrl_addr_o=memctrl_addr_i;
                    end else if(mem_ctrl_if_busy==`Enable) begin
                        mem_ctrl_enable=`Disable;
                        mem_ctrl_rw_sel=1'b0;
                        mem_ctrl_addr_o=`ZeroWord;
                    end
                    case (inst_i)
                        `SB:begin
                            mem_ctrl_data_len=3'b000;
                            mem_ctrl_data_o=vd_i[7:0];   
                        end
                        `SH:begin
                            mem_ctrl_data_len=3'b001;
                            mem_ctrl_data_o=vd_i[15:0];    
                        end
                        `SW:begin
                            mem_ctrl_data_len=3'b011;
                            mem_ctrl_data_o=vd_i;
                        end
                    endcase
                    mem_stall=`Enable;                    
                    r_finished=`Disable;
                    cache_finished=`Disable;
                    cache_modified=`Disable;
                    cache_addr=`ZeroWord;
                    cache_data=`ZeroWord;
                end
            end //end store
            default:begin
                r_finished=`Enable;
                mem_ctrl_enable=`Disable;
                mem_ctrl_rw_sel=1'b0;
                mem_ctrl_addr_o=`ZeroWord;
                mem_ctrl_data_o=`ZeroWord;
                mem_ctrl_data_len=`ZeroDataLen;
                mem_stall=`Disable;
                cache_finished=`Disable;
                cache_modified=`Disable;
                cache_addr=`ZeroWord;
                cache_data=`ZeroWord;
            end
        endcase
    end
end

always @(*) begin
    if(rst==`Enable) begin
        rd_o=`ZeroRegAddr;
        vd_o=`ZeroWord;
        w_enable_o=`Disable;
    end else if(cache_finished==`Enable) begin
        rd_o=rd_i;
        w_enable_o=w_enable_i;
        case (inst_i)
            `LB:vd_o={{24{cache_data[7]}},cache_data[7:0]};
            `LH:vd_o={{16{cache_data[15]}},cache_data[15:0]};
            `LW:vd_o=cache_data;
            `LBU:vd_o=cache_data[7:0];
            `LHU:vd_o=cache_data[15:0];
            default:vd_o=`ZeroWord;
        endcase
    end else if(mem_ctrl_enable==`Enable) begin
        rd_o=`ZeroRegAddr;
        vd_o=`ZeroWord;
        w_enable_o=`Disable;
    end else begin
        rd_o=rd_i;
        vd_o=vd_i;
        w_enable_o=w_enable_i;
    end
end

integer i;
always @(posedge clk) begin
    if(rst==`Enable) begin
        for(i=0;i<`DcacheSize;i=i+1) begin
            valid[i]=`ZeroBit;
        end
    end else if(cache_modified==`Enable) begin
        dcache[cache_addr[`DcacheIndexBus]]=cache_data;
        tag[cache_addr[`DcacheIndexBus]]=cache_addr[`DcacheTagBus];
        valid[cache_addr[`DcacheIndexBus]]=1;
    end
end

endmodule //mem