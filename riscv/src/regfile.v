`include "config.v"

module regfile (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire r1_enable,
    input  wire [`RegAddrBus] r1_addr,
    output reg [`RegBus] r1_data,

    input  wire r2_enable,
    input  wire [`RegAddrBus] r2_addr,
    output reg [`RegBus] r2_data,

    input  wire w_enable,
    input  wire [`RegAddrBus] w_addr,
    input  wire [`RegBus] w_data
);

reg[`RegBus] regs[0:31];

integer fd;

integer i;
initial begin
    for (i=0;i<32;i=i+1) begin
        regs[i]=0;
    end
    fd=$fopen("./a.txt","w+");
end

always @(posedge clk) begin //write
    if(rst==`Enable) begin
        for(i=0;i<32;i=i+1) begin
            regs[i]<=`ZeroWord;
        end
    end else if(rdy==`Enable&&w_enable==`Enable) begin
        if(w_addr!=`ZeroRegAddr) begin
            $fdisplay(fd,"%h %h",w_addr,w_data);
            regs[w_addr]<=w_data;
        end
    end
end

always @(*) begin //read1
    if(rst==`Disable&&rdy==`Enable&&r1_enable==`Enable) begin
        if(r1_addr==`ZeroRegAddr) begin
            r1_data=`ZeroWord;
        end else if(r1_addr==w_addr&&w_enable==`Enable) begin //forwarding
            r1_data=w_data;
        end else begin
            r1_data=regs[r1_addr];
        end
    end else begin
        r1_data=`ZeroWord;
    end
end

always @(*) begin //read2
    if(rst==`Disable&&rdy==`Enable&&r2_enable==`Enable) begin
        if(r2_addr==`ZeroRegAddr) begin
            r2_data=`ZeroWord;
        end else if(r2_addr==w_addr&&w_enable==`Enable) begin //forwarding
            r2_data=w_data;
        end else begin
            r2_data=regs[r2_addr];
        end
    end else begin
        r2_data=`ZeroWord;
    end
end

endmodule //regfile