module start_check(
    input clk,
    input rst_n,
    input strt_chk_en,
    input sampled_bit,
    output reg strt_glitch
);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        strt_glitch <= 0;
    end
    else if((sampled_bit == 1'b1) && strt_chk_en) begin
        strt_glitch <= 1'b1;
    end
    else begin
        strt_glitch <= 1'b0; 
    end
end
endmodule