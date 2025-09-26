module serializer(
    input clk,
    input rst_n,
    input data_valid,
    input busy,
    input [7:0] data_in,
    input ser_en,
    output reg ser_done,
    output reg ser_data
);

reg [3:0] bit_count; // Counter for bits to serialize
reg [7:0] shift_reg; // Shift register to hold data

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ser_done <= 1'b0;
        ser_data <= 1'b0;
        bit_count <= 4'h0;
        shift_reg <= 8'h00; // Reset shift register
    end 
    else begin
        if(data_valid && !busy) begin
            shift_reg <= data_in; // Load data into shift register when enabled
        end
        ser_done <= 1'b0; // Reset done signal on each clock cycle
        if (ser_en) begin
            // Serialization logic here
            if (bit_count < 7) begin
                ser_data <= shift_reg[bit_count]; // Send MSB first
                bit_count <= bit_count + 1;
            end 
            else if (bit_count == 7) begin
                ser_data <= shift_reg[bit_count];
                ser_done <= 1'b1; // Serialization complete
                bit_count <= 0; // Reset counter for next serialization
            end
            else begin
                ser_done <= 1'b1; // Serialization complete
                bit_count <= 0; // Reset counter for next serialization
            end
        end
        else begin
            ser_data <= 1'b0; // Ensure ser_data is low when not enabled
            bit_count <= 0; // Reset bit count if serialization is not enabled
        end
    end
    
end 
 
endmodule