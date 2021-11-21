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
    output reg [`RegAddrBus] rd_o,
    output reg [`RegBus] vd_o,
    output reg w_enable_o, //also output to id

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

always @(*) begin
    if(rst==`Enable||rdy==`Disable) begin
        rd_o=`ZeroRegAddr;
        vd_o=`ZeroWord;
        w_enable_o=`Disable;
        mem_ctrl_enable=`Disable;
        mem_ctrl_addr_o=`ZeroWord;
        mem_ctrl_data_len=`ZeroDataLen;
        mem_ctrl_data_o=`ZeroWord;
        mem_ctrl_rw_sel=`Disable;
        mem_stall=`Disable;
    end else begin
        rd_o=rd_i;
        vd_o=vd_i;
        w_enable_o=w_enable_i;
        mem_ctrl_enable=`Disable;
        mem_ctrl_addr_o=`ZeroWord;
        mem_ctrl_data_len=`ZeroDataLen;
        mem_ctrl_data_o=`ZeroWord;
        mem_ctrl_rw_sel=`Disable;
        mem_stall=`Disable;
        case (inst_i)
            `LB:begin 
                if(mem_ctrl_finished==`Enable) begin
                    vd_o={{24{mem_ctrl_data_i[7]}},mem_ctrl_data_i[7:0]};
                    mem_ctrl_enable=`Disable;
                    w_enable_o=`Enable;
                    mem_stall=`Disable;
                end else begin
                    vd_o=`ZeroWord;
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i;
                    mem_ctrl_data_len=3'b001;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_rw_sel=1'b0;
                    w_enable_o=`Disable;
                    mem_stall=`Enable;
                end
            end
            `LH:begin
                if(mem_ctrl_finished==`Enable) begin
                    vd_o={{16{mem_ctrl_data_i[15]}},mem_ctrl_data_i[15:0]};
                    mem_ctrl_enable=`Disable;
                    w_enable_o=`Enable;
                    mem_stall=`Disable;
                end else begin
                    vd_o=`ZeroWord;
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i;
                    mem_ctrl_data_len=3'b010;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_rw_sel=1'b0;
                    w_enable_o=`Disable;
                    mem_stall=`Enable;
                end
            end
            `LW:begin
                 if(mem_ctrl_finished==`Enable) begin
                    vd_o=mem_ctrl_data_i;
                    mem_ctrl_enable=`Disable;
                    w_enable_o=`Enable;
                    mem_stall=`Disable;
                end else begin
                    vd_o=`ZeroWord;
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i;
                    mem_ctrl_data_len=3'b100;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_rw_sel=1'b0;
                    w_enable_o=`Disable;
                    mem_stall=`Enable;
                end
            end
            `LBU:begin
                if(mem_ctrl_finished==`Enable) begin
                    vd_o=mem_ctrl_data_i[7:0];
                    mem_ctrl_enable=`Disable;
                    w_enable_o=`Enable;
                    mem_stall=`Disable;
                end else begin
                    vd_o=`ZeroWord;
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i;
                    mem_ctrl_data_len=3'b001;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_rw_sel=1'b0;
                    w_enable_o=`Disable;
                    mem_stall=`Enable;
                end
            end
            `LHU:begin
                if(mem_ctrl_finished==`Enable) begin
                    vd_o=mem_ctrl_data_i[15:0];
                    mem_ctrl_enable=`Disable;
                    w_enable_o=`Enable;
                    mem_stall=`Disable;
                end else begin
                    vd_o=`ZeroWord;
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i;
                    mem_ctrl_data_len=3'b010;
                    mem_ctrl_data_o=`ZeroWord;
                    mem_ctrl_rw_sel=1'b0;
                    w_enable_o=`Disable;
                    mem_stall=`Enable;
                end
            end
            `SB:begin
                if(mem_ctrl_finished==`Enable) begin
                    mem_ctrl_enable=`Disable;
                    mem_stall=`Disable;
                end else begin
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i[7:0];
                    mem_ctrl_data_len=3'b001;
                    mem_ctrl_data_o=vd_i;
                    mem_ctrl_rw_sel=1'b1;
                    mem_stall=`Enable;
                    rd_o=`ZeroRegAddr;
                    vd_o=`ZeroWord;
                end
            end
            `SH:begin
                if(mem_ctrl_finished==`Enable) begin
                    mem_ctrl_enable=`Disable;
                    mem_stall=`Disable;
                end else begin
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i[15:0];
                    mem_ctrl_data_len=3'b001;
                    mem_ctrl_data_o=vd_i;
                    mem_ctrl_rw_sel=1'b1;
                    mem_stall=`Enable;
                    rd_o=`ZeroRegAddr;
                    vd_o=`ZeroWord;
                end
            end
            `SW:begin
                if(mem_ctrl_finished==`Enable) begin
                    mem_ctrl_enable=`Disable;
                    mem_stall=`Disable;
                end else begin
                    mem_ctrl_enable=`Enable;
                    mem_ctrl_addr_o=memctrl_addr_i;
                    mem_ctrl_data_len=3'b001;
                    mem_ctrl_data_o=vd_i;
                    mem_ctrl_rw_sel=1'b1;
                    mem_stall=`Enable;
                    rd_o=`ZeroRegAddr;
                    vd_o=`ZeroWord;
                end
            end
        endcase
    end
end

endmodule //mem