`include "config.v"

module IF (
    input  wire clk,
    input  wire rst,
    input  wire rdy, 

    // input  wire [`AddrBus] pc_i,
    input  wire [`InstBus] inst_i,

    output reg [`AddrBus] pc,
    output reg [`InstBus] inst_o,

    output reg stall
);

always @(posedge clk) begin
    if(rst==`Enable||rdy==`Disable)  begin
        pc=`ZeroWord;
        inst_o=`ZeroWord;
    end else begin
        pc=pc+4'h4;
        inst_o=inst_i;
    end 
end

endmodule //if