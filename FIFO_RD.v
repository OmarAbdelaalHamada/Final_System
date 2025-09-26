module FIFO_RD#(parameter FIFO_DEPTH = 8,
                parameter ADDR_WIDTH = $clog2(FIFO_DEPTH))(
    input clk,
    input rst_n,
    input rinc,
    input  [ADDR_WIDTH:0] rq2_wptr,
    output [ADDR_WIDTH:0] rptr,
    output reg [ADDR_WIDTH-1:0] raddr,
    output rempty
);
reg [ADDR_WIDTH:0] rptr_not_gray;
//Write pointer binary to gray conversion
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rptr_not_gray <= 0;
        raddr <= 0;
    end else begin
        if (rinc && !rempty) begin
            rptr_not_gray <= rptr_not_gray + 1;
            raddr <= raddr + 1;
        end
    end
end
assign rptr = (rptr_not_gray[ADDR_WIDTH:0] ^ (rptr_not_gray[ADDR_WIDTH:0] >> 1));
assign rempty = (rptr == rq2_wptr);

endmodule