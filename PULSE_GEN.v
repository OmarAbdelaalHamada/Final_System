module pulse_gen(
    input clk,
    input rst_n,
    input lvl_sig,
    output pulse_sig
);

reg lvl_sig_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lvl_sig_reg <= 1'b0;
    end else begin
        lvl_sig_reg <= lvl_sig;
    end 
end

assign pulse_sig = lvl_sig & !lvl_sig_reg;

endmodule