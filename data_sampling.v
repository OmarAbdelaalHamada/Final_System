module data_sampling(
    input clk,
    input rst_n,
    input RX_in,
    input dat_samp_en,
    input [5:0] prescale,
    input [5:0] edge_cnt,
    output sampled_bit
);
//Internal signals
reg [2:0] buffered_samples;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        buffered_samples <= 0;
    end
    else if(dat_samp_en) begin
        if(edge_cnt == ((prescale >> 1)-1)) begin
            buffered_samples[0] <= RX_in; // Sample the data input on the fourth edge
        end
        else if (edge_cnt == (prescale >> 1)) begin
            buffered_samples[1] <= RX_in; // Sample the data input on the fifth edge
        end
        else if (edge_cnt == ((prescale >> 1)+1)) begin
            buffered_samples[2] <= RX_in; // Sample the data input on the sixth edge
        end
    end
end 

assign sampled_bit = ((buffered_samples == 3'h3) | (buffered_samples == 3'h5) | (buffered_samples == 3'h6) | (buffered_samples == 3'h7));   
endmodule 