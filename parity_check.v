module parity_check(
    input clk,
    input rst_n,
    input par_chk_en,
    input PAR_TYP,
    input [7:0] data_in,
    input sampled_bit,
    output reg par_err
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        par_err <= 0;
    end
    else if(par_chk_en) begin
        if(PAR_TYP == 1'b1) begin // Odd parity check
            par_err <= (sampled_bit == ^data_in);
        end 
        else begin // Even parity check
            par_err <= (sampled_bit == ~^data_in);
        end
    end
end
endmodule