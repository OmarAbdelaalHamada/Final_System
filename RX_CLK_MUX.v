module RX_CLK_MUX(
    input [5:0] Prescale,
    output reg [3:0] RX_div_ratio
);

always @(*) begin
    case (Prescale)
        6'b100000: RX_div_ratio = 1;
        6'b010000: RX_div_ratio = 2;
        6'b001000: RX_div_ratio = 4;
        6'b000100: RX_div_ratio = 8;
        default: RX_div_ratio = 1;
    endcase
end
endmodule