module data_sync#(parameter BUS_WIDTH = 8,
                  parameter NUM_STAGES = 8
                )(
    input clk,
    input rst_n,
    input bus_enable,

    input [BUS_WIDTH-1:0] Unsync_bus,
    output reg [BUS_WIDTH-1:0] sync_bus,
    output reg enable_pulse
);

//internal signals
reg [NUM_STAGES-1:0] multi_FF;
reg enable_pulse_reg;
wire enable_pulse_comb;
wire [BUS_WIDTH-1:0] sync_bus_comb;
integer i;
integer j;

//Multi flip flops:
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < NUM_STAGES ; i = i + 1) begin
            multi_FF[i] <= 0;
        end
    end
    else begin
        multi_FF[0] <= bus_enable;
        for (j = 1; j < NUM_STAGES ; j = j + 1) begin
            multi_FF[j] <= multi_FF[j-1];
        end
    end
end

//pulse generation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enable_pulse_reg <= 0;
    end
    else begin
        enable_pulse_reg <= multi_FF[NUM_STAGES-1];
    end
end

assign enable_pulse_comb = multi_FF[NUM_STAGES-1] & (!enable_pulse_reg);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        enable_pulse <= 0;
    end
    else begin
        enable_pulse <= enable_pulse_comb;
    end
end

//sync_bus logic:

assign sync_bus_comb = (enable_pulse_comb)? Unsync_bus : sync_bus;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync_bus <= 0;
    end
    else begin
        sync_bus <= sync_bus_comb;
    end
end


endmodule