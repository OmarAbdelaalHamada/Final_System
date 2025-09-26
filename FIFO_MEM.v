module FIFO_MEM#(parameter DATA_WIDTH = 8,
                 parameter FIFO_DEPTH = 8,
                 parameter ADDR_WIDTH = $clog2(FIFO_DEPTH))
(
    input clk,
    input rst_n,
    input wclken,
    input [ADDR_WIDTH-1:0] wadder,
    input [ADDR_WIDTH-1:0] raddr,
    input [DATA_WIDTH-1:0] wdata,
    output [DATA_WIDTH-1:0] rdata
);
integer  i;

reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

assign rdata = fifo_mem[raddr];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
       for (i = 0;i<FIFO_DEPTH ;i = i + 1) begin
           fifo_mem[i] <= 0;
       end
    end else begin
        if (wclken) begin
            fifo_mem[wadder] <= wdata;
        end
    end
end

endmodule