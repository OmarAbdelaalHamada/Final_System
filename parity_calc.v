module parity_calc(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input PAR_TYP,
    input data_valid,
    input busy,
    output reg parity_bit
);
reg [7:0]data_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_reg <= 8'h00;
    end
    else if (data_valid && !busy) begin
        data_reg <= data_in;
    end
end
always @(*) begin
    if(PAR_TYP == 0) begin//even parity
            parity_bit = ^data_reg; // Calculate parity bit
    end
    else begin//odd parity
            parity_bit = ~^data_reg; // Calculate parity bit
    end
end

endmodule