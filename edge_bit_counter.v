module edge_bit_counter(
    input clk,
    input rst_n,
    input enable,
    input PAR_EN,
    input [5:0] prescale,
    output reg [3:0] bit_cnt,
    output reg [5:0] edge_cnt
);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bit_cnt <= 4'b0;
        edge_cnt <= 5'b0;
    end
    else if(enable) begin
        edge_cnt <= edge_cnt + 1; // Increment edge count on each clock cycle
        if(edge_cnt == prescale - 1) begin
            if(PAR_EN) begin
                if(bit_cnt <  4'ha) begin
                    bit_cnt <= bit_cnt + 1; // Increment bit count when edge count reaches prescale
                end
                else begin
                    bit_cnt <= 4'b0;
                end
            end 
            else begin
                if(bit_cnt <  4'h9) begin
                    bit_cnt <= bit_cnt + 1; // Increment bit count when edge count reaches prescale
                end
                else begin
                    bit_cnt <= 4'b0;
                end
            end
            edge_cnt <= 5'b0; // Reset edge count
        end
    end
end
endmodule   
 