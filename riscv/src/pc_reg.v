`include "src/config.v"

module pc_reg (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`StallBus] stall, 
    input  wire jump_enable_i,
    input  wire [`AddrBus] jump_dist,

    // input  wire is_branch,
    // input  wire taken_i,
    // input  wire [`AddrBus] branch_dist,
    
    output reg [`AddrBus] pc,
    output wire jump_enable_o
);

// reg [`AddrBus] BTB[0:127];
// reg [`TagBus] tag[0:127];
//reg BHT[]

always @(posedge clk) begin
    if(rst==`Enable) begin
        pc<=`ZeroWord;
    end else if(rdy==`Enable) begin
        if(jump_enable_i==`Enable) begin
            pc<=jump_dist;
        end else if(stall==`NoStall) begin
            pc<=pc+4;
        end
    end
end

endmodule //pc_reg