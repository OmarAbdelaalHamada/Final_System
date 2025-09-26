module ALU #(parameter DATA_WIDTH = 8,
              parameter FUNC_WIDTH = 4)(
    input CLK,
    input RST,
    input Enable,
    input [DATA_WIDTH-1:0] A,
    input [DATA_WIDTH-1:0] B,
    input [FUNC_WIDTH-1:0] ALU_FUN,
    output reg[2*DATA_WIDTH-1:0] ALU_OUT,
    output reg OUT_VALID
);
    
// Internal signal for ALU_OUT_COMB
    reg [2*DATA_WIDTH-1:0] ALU_OUT_COMB;
    reg OUT_VALID_COMB;

always @(*) begin
    if(!Enable) begin
        ALU_OUT_COMB = 0;
        OUT_VALID_COMB = 1'b0;
    end
    else begin
        OUT_VALID_COMB = 1'b1;
        case (ALU_FUN)
        4'b0000: begin // ADD
               ALU_OUT_COMB = A + B;
            end

            4'b0001: begin // SUB
                ALU_OUT_COMB = A - B;
            end

            4'b0010: begin // MULT
                ALU_OUT_COMB = A * B;
            end

            4'b0011: begin // DIV
                ALU_OUT_COMB = A / B;
            end

            4'b0100: begin // AND
                ALU_OUT_COMB = A & B;
            end

            4'b0101: begin // OR
                ALU_OUT_COMB = A | B;
            end

            4'b0110: begin // NAND
                ALU_OUT_COMB = ~(A & B);
            end

            4'b0111: begin // NOR
                ALU_OUT_COMB = ~(A | B);
            end
            4'b1000: begin // XOR
                ALU_OUT_COMB = A ^ B;
            end

            4'b1001: begin // XNOR
                ALU_OUT_COMB = ~(A ^ B);
            end

            4'b1010: begin // CMP EQ
                ALU_OUT_COMB = (A == B);
            end

            4'b1011: begin // CMP GREAT
                ALU_OUT_COMB = (A > B)?2:0;
            end

            4'b1100: begin // CMP SMALL
                ALU_OUT_COMB = (A < B)?3:0;
            end

            4'b1101: begin // SHIFT RIGHT
                ALU_OUT_COMB = (A>>1);
            end

            4'b1110: begin // SHIFT LEFT
                ALU_OUT_COMB = (A<<1);
            end
            default: begin
                ALU_OUT_COMB = 16'b0; // Default case, output zero
            end
        endcase
    end
end

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        ALU_OUT <= 0;
        OUT_VALID <= 1'b0;
    end else begin
        ALU_OUT <= ALU_OUT_COMB; // Update output on clock edge
        OUT_VALID <= OUT_VALID_COMB;
    end
end
endmodule