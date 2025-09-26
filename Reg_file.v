module Reg_file#(parameter DATA_WIDTH = 8,
                 parameter REG_FILE_DEPTH = 16,
                 parameter ADDR_WIDTH = $clog2(REG_FILE_DEPTH))(
    input CLK,
    input RST_n,
    input WrEn,
    input RdEn,
    input [ADDR_WIDTH-1:0] Address,
    input [DATA_WIDTH-1:0] WrData,
    output reg [DATA_WIDTH-1:0] RdData,
    output reg RdData_valid,
    output [DATA_WIDTH-1:0] Reg0 // Output for register 0
    output [DATA_WIDTH-1:0] Reg1 // Output for register 1
    output [DATA_WIDTH-1:0] Reg2 // Output for register 2
    output [DATA_WIDTH-1:0] Reg3 // Output for register 3
);
integer i = 0;
reg [DATA_WIDTH-1:0] registers [0:REG_FILE_DEPTH-1]; // 16 registers of 8 bits each

always @(posedge CLK or negedge RST_n) begin
    RdData <= 0;
    if (!RST_n) begin
        // Reset all registers to 0
        registers[0] <= 16'b0;
        for (i = 0; i < REG_FILE_DEPTH; i = i + 1) begin
            if(i == 2) begin
                registers[i] <= 8'b10000001; // Initialize register 2
            end else if(i == 3) begin
                registers[i] <= 8'b00100000; // Initialize register 3
            end else begin
                registers[i] <= 0;
            end
        end
        RdData_valid <= 1'b0;
        RdData <= 0;
    end 
    else begin
        if (WrEn && !RdEn) begin
            registers[Address] <= WrData; // Write data to the specified register
        end 
        if (RdEn && !WrEn) begin 
            RdData <= registers[Address]; // Read data from the specified register
            RdData_valid <= 1'b1;
        end
        else begin
            RdData_valid <= 1'b0;
        end
    end
end

assign Reg0 = registers[0];
assign Reg1 = registers[1];
assign Reg2 = registers[2];
assign Reg3 = registers[3];

endmodule