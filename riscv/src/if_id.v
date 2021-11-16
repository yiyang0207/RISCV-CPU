`include "config.v"

module IF_ID (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`AddrBus] if_pc,
    input  wire [`InstBus] if_inst,

    input  wire jump_enable_i,
    input  wire [`StallBus] stall,

    output reg [`AddrBus] id_pc,
    output reg [`InstBus] id_inst,
    output reg id_jump_enable
);

always @(posedge clk) begin
    if(rst==`Enable)begin
        id_pc<=`ZeroWord;
        id_inst<=`ZeroWord;
        id_jump_enable<=`Disable;
    end else if(rdy==`Enable)begin
        if(jump_enable_i==`Enable)begin
            //TODO            
        end else begin
            id_pc<=if_pc;
            id_inst<=if_inst;
        end
    end
end

endmodule //if_id