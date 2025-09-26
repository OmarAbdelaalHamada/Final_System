module Int_clk_div(
    input I_ref_clk,
    input I_rst_n,
    input I_clk_en,
    input [7:0] I_div_ratio,
    output o_div_clk
);

//internal signals
wire ClK_DIV_EN;
reg div_clk_reg;
reg [7:0] counter;
//ClK_DIV_EN logic
assign ClK_DIV_EN = I_clk_en && (I_div_ratio != 0) && (I_div_ratio != 1);

//counter logic
always @(posedge I_ref_clk or negedge I_rst_n) begin
    if (!I_rst_n) begin
        counter <= 0;
        div_clk_reg = 0;
    end 
    else if (ClK_DIV_EN) begin
        if ((counter >= (I_div_ratio - 1))) begin // to make sure that counter will be reseted if the div ratio changed
            counter <= 0;
        end 
        else begin
            counter <= counter + 1;
        end
        if (I_div_ratio[0] == 0) begin
            div_clk_reg <= (counter < (I_div_ratio >> 1));
        end
        else begin
            div_clk_reg <= (counter < ((I_div_ratio - 1) >> 1));
        end
    end
end

//o_div_clk logic
assign o_div_clk = (!I_rst_n || !ClK_DIV_EN) ? I_ref_clk : div_clk_reg;

endmodule