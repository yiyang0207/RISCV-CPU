`include "config.v"

module regfile (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire w_enable,
    input  wire [`RegAddrBus] w_addr,
    input  wire [`RegBus] w_data,

    input  wire r1_enable,
    input  wire [`RegAddrBus] r1_addr,
    output reg [`RegBus] r1_data,

    input  wire r2_enable,
    input  wire [`RegAddrBus] r2_addr,
    output reg [`RegBus] r2_data
);

reg[`RegBus] regs[0:31];

integer i;
always @(posedge clk) begin //write
    if(rst==`Enable) begin
        for(i=0;i<32;i=i+1) begin
            regs[i]<=`ZeroWord; //= or <=
        end
    end else if(rdy==`Enable&&w_enable==`Enable) begin
        if(w_addr!=5'h0) begin
            regs[w_addr]<=w_data;
        end
    end
end

always @(*) begin //read1
    if(rst==`Enable||rdy==`Disable) begin
        r1_data=`ZeroWord;
    end else if(r1_enable==`Enable) begin
        if(r1_addr==5'h0) begin
            r1_data=`ZeroWord;
        end else if(r1_addr==w_addr&&w_enable==`Enable) begin
            r1_data=w_data;
        end else begin
            r1_data=regs[r1_addr];
        end
    end else begin
        r1_data=`ZeroWord;
    end
end

always @(*) begin //read2
    if(rst==`Enable||rdy==`Disable) begin
        r2_data=`ZeroWord;
    end else if(r1_enable==`Enable) begin
        if(r2_addr==5'h0) begin
            r2_data=`ZeroWord;
        end else if(r2_addr==w_addr&&w_enable==`Enable) begin
            r2_data=w_data;
        end else begin
            r2_data=regs[r2_addr];
        end
    end else begin
        r2_data=`ZeroWord;
    end
end

endmodule //regfile