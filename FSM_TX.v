module FSM_TX(
    input clk,
    input rst_n,
    input PAR_EN,
    input ser_done,
    input data_valid,
    output reg ser_en,
    output reg [1:0] mux_sel,
    output busy
);

// State encoding
localparam IDLE   = 2'b00;
localparam START  = 2'b01;
localparam DATA   = 2'b11;
localparam PARITY = 2'b10;

reg [1:0] current_state, next_state, delayed_current_state;



always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        delayed_current_state <= IDLE;
    end else begin
        delayed_current_state <= current_state; // Delay the current state by one clock cycle
    end
end

assign busy = ((current_state | delayed_current_state) != IDLE); // Busy signal when not in IDLE state

// State transition logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        IDLE: begin
            if (data_valid) begin
                next_state = START;
            end 
            else begin
                next_state = IDLE;
            end
        end
        
        START: begin
            next_state = DATA; // Move to DATA state after START
        end
        
        DATA: begin
            if (ser_done) begin
                if (PAR_EN) begin
                    next_state = PARITY; // Move to PARITY state if parity is enabled
                end 
                else begin
                    next_state = IDLE; // Go back to IDLE if no parity
                end
            end 
            else begin
                next_state = DATA; // Stay in DATA state until done
            end
        end
        
        PARITY: begin
            next_state = IDLE; // Go back to IDLE after parity processing
        end
        
        default: begin
            next_state = IDLE; // Default case to handle unexpected states
        end
        
    endcase

end

// Output logic
always @(*) begin
    case (current_state)
        IDLE: begin
            ser_en = 1'b0;
            mux_sel = 2'b11; // Select idle bit
        end
        
        START: begin
            ser_en = 1'b1; // Enable serialization
            mux_sel = 2'b00; // Select start bit
        end
        
        DATA: begin
            ser_en = 1'b1; // Enable serialization
            mux_sel = 2'b01; // Select data bit
        end
        
        PARITY: begin
            ser_en = 1'b0; // Enable serialization
            mux_sel = 2'b10; // Select parity bit
        end
        
        default: begin
            ser_en = 1'b0; 
            mux_sel = 2'b11; // Select idle bit
        end
        
    endcase
end
endmodule