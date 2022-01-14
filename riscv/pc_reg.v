`include "config.v"

module pc_reg (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`StallBus] stall, 

    //EX
    input  wire jump_enable_i,
    input  wire [`AddrBus] jump_dist,
    input  wire is_branch,
    input  wire branch_taken,
    input  wire [`AddrBus] branch_pc_i,
    input  wire [`AddrBus] branch_dist,
    
    //IF
    input  wire icache_hit,
    input  wire inst_finished,
    output reg [`AddrBus] pc_o,
    output reg jump_enable_o
);

reg global_BHT;
reg [`AddrBus] BTB[`PredBus];
reg [`PredTagBus] BHT[`PredBus];

wire [6:0] index=branch_pc_i[8:2];

always @(*) begin
    if(rst==`Enable) begin
        jump_enable_o=`Disable;
    end else if(jump_enable_i==`Enable&&(icache_hit==`Enable||(icache_hit==`Disable&&inst_finished==`Disable))) begin //
        jump_enable_o=`Enable;
    end else begin
        jump_enable_o=`Disable;
    end
end

integer i;
always @(posedge clk) begin
    if(rst==`Enable) begin
        pc_o<=`ZeroWord;
    end else if(rdy==`Enable) begin
        if(jump_enable_i==`Enable&&icache_hit==`Enable) begin
            pc_o<=jump_dist;
        end else if(jump_enable_i==`Enable&&icache_hit==`Disable&&inst_finished==`Disable) begin
            pc_o<=jump_dist;
        end else if(stall==`NoStall&&(icache_hit==`Enable||inst_finished==`Enable)) begin
            if(BHT[pc_o[8:2]][12:4]==pc_o[17:9]&&((global_BHT==1'b0&&BHT[pc_o[8:2]][1]==1'b1)||(global_BHT==1'b1&&BHT[pc_o[8:2]][3]==1'b1))) begin
                pc_o<=BTB[pc_o[8:2]];
            end else begin
                pc_o<=pc_o+4;
            end
        end 
    end
end

always @(posedge clk) begin
    if(rst==`Enable) begin
        global_BHT<=1'b0;
        for(i=0;i<`PredSize;i=i+1) begin
            BHT[i][12]<=1'b1;
            BHT[i][3:0]<=4'b0101;
        end
    end else if(rdy==`Enable) begin
        if(is_branch==`Enable) begin
            BTB[index]<=branch_dist;
            BHT[index][12:4]<=branch_pc_i[17:9];
            //local
            if(global_BHT == 1'b0) begin
                if(branch_taken==`Enable&&BHT[index][1:0]<2'b11)
                    BHT[index][1:0]<=BHT[index][1:0]+1;
                else if(branch_taken==`Disable&&BHT[index][1:0]>2'b00)
                    BHT[index][1:0]<=BHT[index][1:0]-1;
            end else begin
                if(branch_taken==`Enable&&BHT[index][3:2]<2'b11)
                    BHT[index][3:2]<=BHT[index][3:2]+1;
                else if(branch_taken==`Disable&&BHT[index][3:2]>2'b00)
                    BHT[index][3:2]<=BHT[index][3:2]-1;
            end
            //global
            global_BHT<=branch_taken;
        end
    end
end

endmodule //pc_reg