module MUX(
    input ser_data,
    input par_bit,
    input PAR_EN,
    input [1:0] mux_sel,
    output reg TX_out
);

always @(*) begin
    TX_out = 1'b1; // Default to high (idle state)
    case(mux_sel)
        2'b00: TX_out = 1'b0; // Start bit
        2'b01: TX_out = ser_data;  // Serial data
        2'b10: TX_out = par_bit;   // Parity bit
        2'b11: TX_out = 1'b1;  // Stop bit
        default: TX_out = 1'b1;     // Default case
    endcase
    
end

endmodule