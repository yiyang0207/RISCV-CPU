`include "config.v"

module EX_MEM (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //EX
    input  wire [`OptBus] ex_inst,
    input  wire [`RegAddrBus] ex_rd,
    input  wire [`RegBus] ex_vd,
    input  wire ex_w_enable,
    input  wire [`AddrBus] ex_memctrl_addr,

    input  wire [`StallBus] stall_ctrler,

    //MEM
    output reg [`OptBus] mem_inst,
    output reg [`RegAddrBus] mem_rd,
    output reg [`RegBus] mem_vd,
    output reg mem_w_enable,
    output reg [`AddrBus] mem_memctrl_addr
);

always @(posedge clk) begin
    if(rst==`Enable) begin
        mem_inst<=`ZeroOpt;
        mem_rd<=`ZeroRegAddr;
        mem_vd<=`ZeroWord;
        mem_w_enable<=`Disable;
        mem_memctrl_addr<=`ZeroWord;
    end else if(rdy==`Enable) begin
        if(stall_ctrler[3]==`Enable) begin
            
        end else if(stall_ctrler[2]==`Disable) begin
            mem_inst<=ex_inst;
            mem_rd<=ex_rd;
            mem_vd<=ex_vd;
            mem_w_enable<=ex_w_enable;
            mem_memctrl_addr<=ex_memctrl_addr;
        end else begin
            mem_inst<=`ZeroOpt;
            mem_rd<=`ZeroRegAddr;
            mem_vd<=`ZeroWord;
            mem_w_enable<=`Disable;
            mem_memctrl_addr<=`ZeroWord;
        end
    end
end

endmodule //ex_mem