module Sys_top#()(
    // Parameters
    parameter FRAME_WIDTH = 8,
    parameter ALU_DATA_WIDTH = 16,
    parameter ALU_FUNC_WIDTH = 4,
    parameter REG_FILE_DEPTH = 16,
    parameter REG_FILE_ADDR_WIDTH = $clog2(REG_FILE_DEPTH)
)(
    // Inputs
    input CLK,
    input UART_CLK,
    input RST,
    input RX_IN,

    // Outputs
    output TX_OUT,
    output par_err,
    output stp_err,
    output strt_glitch
);

// Internal Signals
    wire rst_ref_domain;
    wire TX_IN_V;
    wire rst_uart_domain;
    wire rinc;
    wire [3:0] RX_div_ratio;
    wire busy;
    wire RX_CLK;
    wire TX_CLK;
    wire WrEn;
    wire RdEn;
    wire [REG_FILE_ADDR_WIDTH-1:0] RF_ADDR;
    wire [FRAME_WIDTH-1:0] WrData;
    wire [FRAME_WIDTH-1:0] RdData;
    wire [FRAME_WIDTH-1:0] TX_IN_from_fifo;
    wire RdData_Valid;
    wire [ALU_DATA_WIDTH-1:0] ALU_OUT;
    wire OUT_VALID;
    wire [ALU_FUNC_WIDTH-1:0] ALU_FUNC;
    wire ALU_EN;
    wire CLK_EN_GATE;
    wire clk_div_en;
    wire WR_INC;
    wire RX_P_VLD;
    wire [FRAME_WIDTH-1:0] RX_P_DATA;
    wire FIFO_FULL;
    wire FIFO_EMPTY;
    wire ALU_CLK;
    wire Reg0;
    wire Reg1;
    wire Reg2;
    wire Reg3;
    wire [FRAME_WIDTH-1:0] RX_Out_to_Ctrl;
    wire RX_Valid_to_Ctrl;

    assign TX_IN_V = (!FIFO_EMPTY);

// Module Instantiations

    //reference clock domain: 

    Sys_crtl Sys_crtl_inst #(
        .FRAME_WIDTH(FRAME_WIDTH),
        .ALU_DATA_WIDTH(ALU_DATA_WIDTH),
        .ALU_FUNC_WIDTH(ALU_FUNC_WIDTH),
        .REG_FILE_DEPTH(REG_FILE_DEPTH),
        .REG_FILE_ADDR_WIDTH(REG_FILE_ADDR_WIDTH)
    )(
        .CLK(CLK),
        .RST(rst_ref_domain),
        .ALU_OUT(ALU_OUT),
        .OUT_VALID(OUT_VALID),
        .RdData(RdData),
        .RdData_Valid(RdData_Valid),
        .RX_P_DATA(RX_Out_to_Ctrl),
        .RX_P_VLD(RX_Valid_to_Ctrl),
        .FIFO_FULL(FIFO_FULL),
        .ALU_FUNC(ALU_FUNC),
        .ALU_EN(ALU_EN), 
        .CLK_EN(CLK_EN_GATE),
        .RF_ADDR(RF_ADDR),
        .WrEn(WrEn),
        .RdEn(RdEn),
        .WrData(WrData),
        .clk_div_en(clk_div_en),
        .WR_INC(WR_INC)
    );

    Reg_file #(
        .DATA_WIDTH(FRAME_WIDTH),
        .REG_FILE_DEPTH(REG_FILE_DEPTH)
    ) Reg_file_inst (
        .CLK(CLK),
        .RST_n(rst_ref_domain),
        .WrEn(WrEn),
        .RdEn(RdEn),
        .Address(RF_ADDR),
        .WrData(WrData),
        .RdData(RdData),
        .RdData_valid(RdData_Valid),
        .Reg0(Reg0), // Unused
        .Reg1(Reg1), // Unused
        .Reg2(Reg2), // Unused
        .Reg3(Reg3)  // Unused
    );

    ALU #(
        .DATA_WIDTH(ALU_DATA_WIDTH),
        .FUNC_WIDTH(ALU_FUNC_WIDTH)
    ) ALU_inst (
        .CLK(ALU_CLK),
        .RST(rst_ref_domain),
        .Enable(ALU_EN),
        .A(Reg0), // Zero-extend to 16 bits
        .B(Reg1), // Zero-extend to 16 bits
        .ALU_FUN(ALU_FUNC),
        .ALU_OUT(ALU_OUT),
        .OUT_VALID(OUT_VALID)
    );

    CLK_GATE clk_gate_inst (
        .CLK_IN(CLK),
        .EN(CLK_EN_GATE),
        .CLK_OUT(ALU_CLK)
    );

    rst_sync #(
        .NUM_STAGES(2)
    ) rst_sync_ref_domain (
        .clk(CLK),
        .rst_n(RST),
        .rst_sync(rst_ref_domain)
    );

    //UART clock domain:

    RX_CLK_MUX RX_CLK_MUX_inst (
        .Prescale(Reg2[7:2]),
        .RX_div_ratio(RX_div_ratio)
    );

    clk_div clk_div_RX (
        .I_ref_clk(UART_CLK),
        .I_rst_n(rst_uart_domain),
        .I_clk_en(clk_div_en), // Always enable TX clock
        .I_div_ratio(RX_div_ratio), // Unused
        .o_div_clk(RX_CLK)
    );

    clk_div clk_div_TX (
        .I_ref_clk(UART_CLK),
        .I_rst_n(rst_uart_domain),
        .I_clk_en(clk_div_en), // Always enable TX clock
        .I_div_ratio(Reg3), // Unused
        .o_div_clk(TX_CLK)
    );

    UART UART_inst (
        .TX_CLK(TX_CLK),
        .RX_CLK(RX_CLK),
        .rst_n(rst_uart_domain),
        .PAR_EN(Reg2[0]),
        .PAR_TYP(Reg2[1]),
        .TX_IN_P(TX_IN_from_fifo),
        .TX_IN_V(TX_IN_V),
        .Prescale(Reg3[7:2]),
        .RX_IN_S(RX_IN),
        .TX_OUT_S(TX_OUT),
        .TX_OUT_V(busy), 
        .RX_OUT_P(RX_P_DATA),
        .par_err(par_err), 
        .stp_err(stp_err),
        .strt_glitch(strt_glitch), 
        .RX_OUT_V(RX_P_VLD)
    );

    pulse_gen pulse_gen_inst (
        .clk(TX_CLK),
        .rst_n(rst_uart_domain),
        .in_signal(busy),
        .out_pulse(rinc)
    );


    ASYNC_FIFO#(
        parameter DATA_WIDTH = 8,
        parameter FIFO_DEPTH = 8,
        parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
    ) FIFO_inst (
        .w_clk(CLK),
        .w_rst_n(rst_ref_domain),
        .winc(WR_INC),
        .r_clk(TX_CLK),
        .r_rst_n(rst_uart_domain),
        .rinc(rinc),
        .WR_data(WrData),
        .RD_data(TX_IN_from_fifo),
        .full(FIFO_FULL),
        .empty(FIFO_EMPTY)
    );
    

    data_sync#(
        parameter BUS_WIDTH = FRAME_WIDTH,
        parameter NUM_STAGES = 2
    ) Data_sync_inst (
        .clk(CLK),
        .rst_n(rst_ref_domain),
        .bus_enable(RX_P_VLD),
        .Unsync_bus(RX_P_DATA),
        .sync_bus(RX_Out_to_Ctrl),
        .enable_pulse(RX_Valid_to_Ctrl)
    );




    rst_sync #(
        .NUM_STAGES(2)
    ) rst_sync_uart_domain (
        .clk(UART_CLK),
        .rst_n(RST),
        .rst_sync(rst_uart_domain)
    );

endmodule