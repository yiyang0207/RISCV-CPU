`include "config.v"

module IF_ID (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //IF
    input  wire [`AddrBus] if_pc,
    input  wire [`InstBus] if_inst,

    input  wire jump_enable,
    input  wire [`StallBus] stall_ctrler,

    //ID
    output reg [`AddrBus] id_pc,
    output reg [`InstBus] id_inst
);

always @(posedge clk) begin
    if(rst==`Enable)begin
        id_pc<=`ZeroWord;
        id_inst<=`ZeroWord;
    end else if(rdy==`Enable)begin
        if(stall_ctrler[0]==`Disable&&jump_enable==`Disable) begin
            id_pc<=if_pc;
            id_inst<=if_inst;
        end else if(jump_enable==`Enable||stall_ctrler[1]==`Disable) begin
            id_pc<=`ZeroWord;
            id_inst<=`ZeroWord;
        end
    end
end

endmodule //if_id