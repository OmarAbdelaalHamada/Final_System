module FIFO_WR#(parameter FIFO_DEPTH = 8,
                parameter ADDR_WIDTH = $clog2(FIFO_DEPTH))(
    input clk,
    input rst_n,
    input winc,
    input  [ADDR_WIDTH:0] wq2_rptr,
    output [ADDR_WIDTH:0] wptr,
    output reg [ADDR_WIDTH-1:0] waddr,
    output wfull
);
reg [ADDR_WIDTH:0]wptr_not_gray;
//Write pointer binary to gray conversion
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wptr_not_gray <= 0;
        waddr <= 0;
    end else begin
        if (winc && !wfull) begin
            wptr_not_gray <= wptr_not_gray + 1;
            waddr <= waddr + 1;
        end
    end
end
assign wptr = (wptr_not_gray[ADDR_WIDTH:0] ^ (wptr_not_gray[ADDR_WIDTH:0] >> 1));
assign wfull = ((wptr[ADDR_WIDTH] != wq2_rptr[ADDR_WIDTH]) && (wptr[ADDR_WIDTH-1] != wq2_rptr[ADDR_WIDTH-1]) && (wptr[ADDR_WIDTH-2:0] == wq2_rptr[ADDR_WIDTH-2:0]));

endmodule