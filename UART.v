module UART(
    input TX_CLK,
    input RX_CLK,
    input rst_n,
    input PAR_EN,
    input PAR_TYP,
    input [7:0] TX_IN_P,
    input TX_IN_V,
    input [5:0] Prescale,
    input RX_IN_S,
    output TX_OUT_S,
    output TX_OUT_V,
    output [7:0] RX_OUT_P,
    output par_err,
    output stp_err,
    output strt_glitch,
    output RX_OUT_V
);


//TX instantiation:
UART_TX u_UART_TX(
    .clk(TX_CLK),
    .rst_n(rst_n),
    .PAR_EN(PAR_EN),
    .data_valid(TX_IN_V),
    .P_DATA(TX_IN_P),
    .PAR_TYP(PAR_TYP),
    .TX_out(TX_OUT_S),
    .busy(TX_OUT_V)
);

UART_RX u_UART_RX(
    .clk(RX_CLK),
    .rst_n(rst_n),
    .RX_IN(RX_IN_S),
    .P_DATA(RX_OUT_P),
    .par_err(par_err),
    .stp_err(stp_err),
    .strt_glitch(strt_glitch),
    .data_valid(RX_OUT_V)
);

endmodule