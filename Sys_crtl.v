module Sys_crtl #(
    parameter FRAME_WIDTH = 8,
    parameter ALU_DATA_WIDTH = 16,
    parameter ALU_FUNC_WIDTH = 4,
    parameter REG_FILE_DEPTH = 16,
    parameter REG_FILE_ADDR_WIDTH = $clog2(REG_FILE_DEPTH)
)(
    // Inputs
    input CLK,
    input RST,
    input [ALU_DATA_WIDTH-1:0] ALU_OUT,
    input OUT_VALID,
    input [FRAME_WIDTH-1:0] RdData,
    input RdData_Valid,
    input [FRAME_WIDTH-1:0] RX_P_DATA,
    input RX_P_VLD,
    input FIFO_FULL,

    // Outputs
    output reg [ALU_FUNC_WIDTH-1:0] ALU_FUNC,
    output reg ALU_EN, 
    output reg CLK_EN,
    output reg [REG_FILE_ADDR_WIDTH-1:0] RF_ADDR,
    output reg WrEn,
    output reg RdEn,
    output reg [FRAME_WIDTH-1:0] WrData,
    output reg TX_P_VLD,
    output reg [FRAME_WIDTH-1:0] TX_P_DATA,
    output reg clk_div_en,
    output reg WR_INC
);

// State Encoding
    
    localparam IDLE         = 4'b0000;
    localparam Rd_Addr      = 4'b0001;
    localparam Rd_Data      = 4'b0011;
    localparam RD_to_FIFO   = 4'b0010;
    localparam Wr_Addr      = 4'b0110;
    localparam Wr_Data      = 4'b0111;
    localparam Wr_to_RF     = 4'b0101;
    localparam ALU_OP       = 4'b0100;
    localparam ALU_OP_A     = 4'b1100;
    localparam ALU_OP_B     = 4'b1101;
    localparam ALU_OP_FUNC  = 4'b1111;
    localparam OUT_to_FIFO  = 4'b1110;
    localparam ALU_NOP      = 4'b1010;
    localparam ALU_NOP_FUNC = 4'b1011;

// Internal Signals
    reg [3:0] current_state, next_state;
    reg [FRAME_WIDTH-1:0] OP_A_reg;
    reg [FRAME_WIDTH-1:0] OP_B_reg;
    reg [ALU_FUNC_WIDTH-1:0] ALU_FUNC_reg;
    reg [ALU_DATA_WIDTH-1:0] ALU_OUT_reg;
    reg [REG_FILE_ADDR_WIDTH-1:0] RF_ADDR_reg;
    reg [FRAME_WIDTH-1:0] WrData_reg;
    reg [FRAME_WIDTH-1:0] RdData_reg;



// State Transition
always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end  
end

// Next State Logic
always @(*) begin
    case (current_state)
        IDLE: begin
           if (RX_P_VLD) begin
                if(RX_P_DATA == 8'hAA) begin 
                    next_state = Wr_Addr;
                end 
                else if(RX_P_DATA == 8'hBB) begin 
                    next_state = Rd_Addr; 
                end
                else if (RX_P_DATA == 8'hCC) begin 
                    next_state = ALU_OP; 
                end
                else if (RX_P_DATA == 8'hDD) begin
                    next_state = ALU_NOP; 
                end
                else begin
                    next_state = IDLE;
                end
            end 
            else begin
                next_state = IDLE;
            end
        end
        Rd_Addr: begin
            next_state = Rd_Data;
        end
        Rd_Data: begin
            next_state = RD_to_FIFO;
        end
        RD_to_FIFO: begin
           next_state = IDLE;
        end
        Wr_Addr: begin
            next_state = Wr_Data;
        end
        Wr_Data: begin
            next_state = Wr_to_RF;
        end
        Wr_to_RF: begin
            next_state = IDLE;
        end
        ALU_OP: begin
            next_state = ALU_OP_A;
        end
        ALU_OP_A: begin
            next_state = ALU_OP_B;
        end
        ALU_OP_B: begin
            next_state = ALU_OP_FUNC;
        end
        ALU_OP_FUNC: begin
            next_state = OUT_to_FIFO;
        end
        OUT_to_FIFO: begin
            next_state = IDLE;
        end
        ALU_NOP: begin
            next_state = ALU_NOP_FUNC;
        end
        ALU_NOP_FUNC: begin
            next_state = OUT_to_FIFO;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

// Output Logic
always @(*) begin
    ALU_FUNC   = 0;
    ALU_EN     = 0; 
    CLK_EN     = 0;
    RF_ADDR    = 0; 
    WrEn       = 0; 
    RdEn       = 0;
    WrData     = 0; 
    TX_P_VLD   = 0;
    TX_P_DATA  = 0;  
    clk_div_en = 0; 
    case (current_state)
        IDLE: begin
            ALU_FUNC   = 0;
            ALU_EN     = 0; 
            CLK_EN     = 0;
            RF_ADDR    = 0; 
            WrEn       = 0; 
            RdEn       = 0;
            WrData     = 0; 
            TX_P_VLD   = 0;
            TX_P_DATA  = 0;  
            clk_div_en = 0;
        end
        Rd_Addr: begin
            RF_ADDR = RX_P_DATA;
        end
        Rd_Data: begin
            RdEn    = 1;
            RdData_reg = RdData;
        end
        RD_to_FIFO: begin
           if(!FIFO_FULL) begin
                WrData = RdData_reg;
                WR_INC = WR_INC + 1;
           end
        end
        Wr_Addr: begin
            RF_ADDR_reg = RX_P_DATA;
        end
        Wr_Data: begin
            RF_ADDR = RF_ADDR_reg;
            WrData_reg = RX_P_DATA;
        end
        Wr_to_RF: begin
            
        end
        ALU_OP: begin
            
        end
        ALU_OP_A: begin
            
        end
        ALU_OP_B: begin
            
        end
        ALU_OP_FUNC: begin
            
        end
        OUT_to_FIFO: begin
            
        end
        ALU_NOP: begin
            
        end
        ALU_NOP_FUNC: begin
            
        end
        default: begin
            
        end
    endcase
end

endmodule