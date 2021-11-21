`include "config.v"

module pc_reg (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire jump_enable,
    input  wire [`AddrBus] jump_dist,
    input  wire [`StallBus] stall, 
    
    output reg [`AddrBus] pc
);

always @(posedge clk) begin
    if(rst==`Enable) begin
        pc<=`ZeroWord;
    end else if(rdy==`Enable) begin
        if(jump_enable==`Enable) begin
            pc<=jump_dist;
        end else if(stall==`NoStall) begin
            pc<=pc+4;
        end
    end
end

endmodule //pc_reg