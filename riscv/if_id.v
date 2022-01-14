`include "config.v"

module IF_ID (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //IF
    input  wire [`AddrBus] if_pc,
    input  wire [`InstBus] if_inst,

    //EX
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
        if(jump_enable==`Enable) begin
            id_pc<=`ZeroWord;
            id_inst<=`ZeroWord;
        end else if(stall_ctrler[1]==`Enable) begin
            
        end else if(stall_ctrler[0]==`Disable) begin
            id_pc<=if_pc;
            id_inst<=if_inst;
        end else begin
            id_pc<=`ZeroWord;
            id_inst<=`ZeroWord;
        end
    end
end

endmodule //if_id