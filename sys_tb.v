`timescale 1ns / 1ps
module sys_tb();

    // Parameters
    parameter FRAME_WIDTH = 8;
    parameter ALU_DATA_WIDTH = 16;
    parameter ALU_FUNC_WIDTH = 4;
    parameter REG_FILE_DEPTH = 16;
    parameter REG_FILE_ADDR_WIDTH = $clog2(REG_FILE_DEPTH);
    parameter REF_CLK_PERIOD = 10;
    parameter UART_CLK_PERIOD = 10; 

    //TB Signals
    reg CLK;
    reg UART_CLK;
    reg RST;
    reg RX_IN;
    wire TX_OUT;
    wire par_err;
    wire stp_err;
    wire strt_glitch;


    // Instantiate the Sys_top module
    Sys_top #(
        .FRAME_WIDTH(FRAME_WIDTH),
        .ALU_DATA_WIDTH(ALU_DATA_WIDTH),
        .ALU_FUNC_WIDTH(ALU_FUNC_WIDTH),
        .REG_FILE_DEPTH(REG_FILE_DEPTH),
        .REG_FILE_ADDR_WIDTH(REG_FILE_ADDR_WIDTH)
    ) DUT (
        .CLK(CLK),
        .UART_CLK(UART_CLK),
        .RST(RST),
        .RX_IN(RX_IN),
        .TX_OUT(TX_OUT),
        .par_err(par_err),
        .stp_err(stp_err),
        .strt_glitch(strt_glitch)
    );

    //System Functions:
    initial begin
        $dumpfile("sys_tb.vcd");
        $dumpvars;
    end

    // Main Initial Block
    initial begin
        Initial_values();
        apply_reset();
        // Add stimulus here as needed
        feed_input(8'hAA); // write operation
        feed_input(8'h00); // addr 0x00 => Reg0 => OP_A
        feed_input(8'h02); // We write value 2 in Reg0
        feed_input(8'hAA); // write operation
        feed_input(8'h01); // addr 0x00 => Reg1 => OP_B
        feed_input(8'h03); // We write value 3 in Reg1
        feed_input(8'hBB); // Read operation
        feed_input(8'h00); // addr 0x00 => Reg0 => OP_A
        check_TX_out_parity(8'h02);
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));

        feed_input(8'hCC); // ALU operation with operand 
        feed_input(8'h04); // ALU_OP_A
        feed_input(8'h03); // ALU_OP_B
        feed_input(8'h01); // ALU_FUNC => SUB
        #(2*REF_CLK_PERIOD); // for to write operations in FIFO
        check_TX_out_parity(8'h01);
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));

        feed_input(8'hDD); // ALU operation without operand 
        feed_input(8'h00); // ALU_FUNC => SUB
        #(2*REF_CLK_PERIOD); // for to write operations in FIFO
        check_TX_out_parity(8'h07);
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
        $finish;
    end



//====================================Tasks=======================================//
    task apply_reset;
        begin
            RST = 0;
            #(REF_CLK_PERIOD);
            RST = 1;
            #(REF_CLK_PERIOD);
        end
    endtask

    task Initial_values;
        begin
            RST = 1;
            RX_IN = 1; // Idle state for UART RX line
        end
    endtask

    //feeding input tasks:
    task feed_input;
        integer i;
        input [7:0] data;
        begin
            RX_IN = 0;// start bit
            #(UART_CLK_PERIOD*32);

            for (i = 0; i < 8; i = i + 1) begin
                RX_IN = data[i];
                #(UART_CLK_PERIOD*32);
            end
            if((DUT.Reg_file_inst.registers[2][0])) begin
                if(DUT.Reg_file_inst.registers[2][1]) begin
                    RX_IN = ~^data; // Odd parity bit
                    #(UART_CLK_PERIOD*32);
                end 
                else begin
                    RX_IN = ^data; // Even parity bit
                    #(UART_CLK_PERIOD*32);
                end
            end
            RX_IN = 1; // Stop bit
            #(UART_CLK_PERIOD*32);
        end
    endtask



    // Task to check TX_out serialization and parity
    task check_TX_out_parity;
        integer i;
        input [7:0] P_DATA; //FIFO Output
        reg [10:0] expected_data;
        reg [10:0] test_data; // Test data for serialization
        begin
            // Wait for start bit (assume idle is high, start is low)
            //wait (TX_out_tb == 0);
            // Sample all 11 bits (start, 8 data, parity, stop)
            for (i = 0; i < 11; i = i + 1) begin
                test_data[i] = TX_OUT;
                #(UART_CLK_PERIOD*(DUT.Reg_file_inst.registers[2][7:2]));
            end
            // Build expected data: {stop, parity, data, start}
            expected_data = {1'b1, ((DUT.Reg_file_inst.registers[2][0]) ? (DUT.UART_inst.u_UART_TX.parity_calc_inst.parity_bit) : 1'bx), P_DATA, 1'b0};
            if (DUT.Reg_file_inst.registers[2][0]) begin
                if (test_data !== expected_data) begin
                    $display("TX_out mismatch: expected %b, got %b", expected_data, test_data);
                end else begin
                    $display("TX_out matches expected data with parity.");
                end
            end 
            else begin
                // If parity is disabled, ignore parity bit in comparison
                if ({test_data[9:0]} !== {1'b1, P_DATA, 1'b0}) begin
                    $display("TX_out mismatch (no parity): expected %b, got %b", {1'b1, P_DATA, 1'b0}, {test_data[9:0]});
                end else begin
                    $display("TX_out matches expected data (no parity).");
                end
            end
        end
    endtask
//=========================================Clock Generation=======================================//
    // Ref Clock Generation
    initial begin
        CLK = 0;
        forever #(REF_CLK_PERIOD / 2) CLK = ~CLK;
    end

    // UART Clock Generation
    initial begin
        UART_CLK = 0;
        forever #(UART_CLK_PERIOD / 2) UART_CLK = ~UART_CLK;
    end

endmodule