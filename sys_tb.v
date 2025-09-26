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