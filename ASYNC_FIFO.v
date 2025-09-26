module ASYNC_FIFO#(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8,
    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
)(
    input w_clk,
    input w_rst_n,
    input winc,
    input r_clk,
    input r_rst_n,
    input rinc,
    input [DATA_WIDTH-1:0] WR_data,
    output [DATA_WIDTH-1:0] RD_data,
    output full,
    output empty
);
//Internal wires:
wire wclken_wire;
wire [ADDR_WIDTH-1:0] waddr;
wire [ADDR_WIDTH-1:0] raddr;
wire [ADDR_WIDTH:0] wptr;
wire [ADDR_WIDTH:0] rptr;
wire [ADDR_WIDTH:0] rq2_wptr;
wire [ADDR_WIDTH:0] wq2_rptr;

assign wclken_wire = winc & ~full;
//Dual Port Memory
FIFO_MEM #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH)
) fifo_mem_inst (
    .clk(w_clk),
    .rst_n(w_rst_n),
    .wclken(wclken_wire),
    .wadder(waddr),
    .raddr(raddr),
    .wdata(WR_data),
    .rdata(RD_data)
);

//Write Control Logic
FIFO_WR #(
    .FIFO_DEPTH(FIFO_DEPTH)
) fifo_wr_inst (
    .clk(w_clk),
    .rst_n(w_rst_n),
    .winc(winc),
    .wq2_rptr(wq2_rptr),
    .wptr(wptr),
    .waddr(waddr),
    .wfull(full)
);

//Read Control Logic
FIFO_RD #(
    .FIFO_DEPTH(FIFO_DEPTH)
) fifo_rd_inst (
    .clk(r_clk),
    .rst_n(r_rst_n),
    .rinc(rinc),
    .rq2_wptr(rq2_wptr),
    .rptr(rptr),
    .raddr(raddr),
    .rempty(empty)
);

//wptr Synchronizer
DF_sync #(
    .FIFO_DEPTH(FIFO_DEPTH)
) wr2rd (
    .clk(r_clk),
    .rst_n(r_rst_n),
    .data_in(wptr),
    .data_out(rq2_wptr)
);

//rptr Synchronizer
DF_sync #(
    .FIFO_DEPTH(FIFO_DEPTH)
) rd2wr (
    .clk(w_clk),
    .rst_n(w_rst_n),
    .data_in(rptr),
    .data_out(wq2_rptr)
);

endmodule