`include "config.v"

module MEM_WB (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //MEM
    input  wire [`RegAddrBus] mem_rd,
    input  wire [`RegBus] mem_vd,
    input  wire mem_w_enable,

    input  wire [`StallBus] stall_ctrler,
    
    //WB
    output reg [`RegAddrBus] wb_rd,
    output reg [`RegBus] wb_vd,
    output reg wb_w_enable
);
always @(posedge clk) begin
    if(rst==`Enable)begin
        wb_rd<=`ZeroWord;
        wb_vd<=`ZeroWord;
        wb_w_enable<=`Disable;
    end else if(rdy==`Enable)begin
        if(stall_ctrler[3]==`Disable) begin
            wb_rd<=mem_rd;
            wb_vd<=mem_vd;
            wb_w_enable<=mem_w_enable;
        end else if(stall_ctrler[4]==`Disable) begin
            wb_rd<=`ZeroWord;
            wb_vd<=`ZeroWord;
            wb_w_enable<=`Disable;
        end
    end
end
endmodule //mem_wb