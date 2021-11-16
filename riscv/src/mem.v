`include "config.v"

module MEM (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`AddrBus] pc_i,
    input  wire [`OptBus] inst_i,
    input  wire [`RegAddrBus] rd,
    input  wire [`RegBus] vd,

    output reg [`AddrBus] pc_o,
    output reg [`OptBus] inst_o
);

always @(*) begin
    if(rst==`Enable||rdy==`Disable) begin
        pc_o=`ZeroWord;
        inst_o=`ZeroWord;
    end else begin
        pc_o=pc_i;
        inst_o=inst_i;

        case (inst_i)
            `LB:begin
                
            end
            `LH:begin
                
            end
            `LW:begin
                
            end
            `LBU:begin
                
            end
            `LHU:begin
                
            end
            `SB:begin
                
            end
            `SH:begin
                
            end
            `SW:begin
                
            end
            default:begin
                
            end
        endcase
    end
end

endmodule //mem