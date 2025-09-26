module UART_TX(
    input clk,
    input rst_n,
    input PAR_EN,
    input data_valid,
    input [7:0] P_DATA,
    input PAR_TYP,
    output TX_out,
    output busy
);
    wire ser_data;
    wire ser_done;
    wire [1:0] mux_sel;
    wire parity_bit;
    wire ser_en;

    // Instantiate the FSM
    FSM_TX fsm_inst(
        .clk(clk),
        .rst_n(rst_n),
        .PAR_EN(PAR_EN),
        .ser_done(ser_done),
        .data_valid(data_valid),
        .ser_en(ser_en),
        .mux_sel(mux_sel),
        .busy(busy)
    );

    // Instantiate the parity calculator
    parity_calc parity_calc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .data_in(P_DATA),
        .PAR_TYP(PAR_TYP),
        .busy(busy),
        .data_valid(data_valid),
        .parity_bit(parity_bit)
    );

    // Instantiate the serializer
    serializer serializer_inst( 
        .clk(clk),
        .rst_n(rst_n),
        .ser_en(ser_en),
        .data_in(P_DATA),
        .data_valid(data_valid),
        .busy(busy),
        .ser_data(ser_data),
        .ser_done(ser_done)
    );

    // Instantiate the MUX
    MUX mux_inst(
        .ser_data(ser_data),
        .par_bit(parity_bit),
        .PAR_EN(PAR_EN),
        .mux_sel(mux_sel),
        .TX_out(TX_out)
    );

endmodule