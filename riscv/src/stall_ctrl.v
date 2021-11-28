`include "config.v"

module stall_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire if_stall,
    input  wire id_stall,
    // input  wire ex_stall,
    input  wire mem_stall,
    // input  wire wb_stall,

    output reg [`StallBus] stall_ctrler
);

always @(*) begin
    if(rst==`Enable) begin
        stall_ctrler=`NoStall;
    end else if(rdy==`Enable) begin
        // if(wb_stall==`Enable) begin
            // stall_ctrler=`AllStall;
        // end else 
        if(mem_stall==`Enable) begin
            stall_ctrler=`MemStall;
        // end else if(ex_stall==`Enable) begin
            // stall_ctrler=`ExStall;
        end else if(id_stall==`Enable) begin
            stall_ctrler=`IdStall;
        end else if(if_stall==`Enable) begin
            stall_ctrler=`IfStall;
        end
    end else begin
        stall_ctrler=`AllStall;
    end
end

endmodule //stall_ctrl