module DF_sync#(parameter FIFO_DEPTH = 8,
                parameter ADDR_WIDTH = $clog2(FIFO_DEPTH))(
    input clk,
    input rst_n,
    input [ADDR_WIDTH:0] data_in,
    output [ADDR_WIDTH:0] data_out
);

reg [ADDR_WIDTH:0] data_reg [1:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_reg[0] <= 0;
        data_reg[1] <= 0;
    end else begin
        data_reg[0] <= data_in;
        data_reg[1] <= data_reg[0];
    end
end
assign data_out = data_reg[1];
endmodule