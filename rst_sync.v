module rst_sync #(parameter NUM_STAGES = 2)(
    input clk,
    input rst_n,
    output rst_sync
);

    reg [NUM_STAGES-1:0] sync_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg <= 0;
        end else begin
            sync_reg <= {sync_reg[NUM_STAGES-2:0], 1'b1};
        end
    end

    assign rst_sync = sync_reg[NUM_STAGES-1];

endmodule
