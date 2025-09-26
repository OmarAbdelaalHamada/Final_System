module UART_RX(
    input clk,
    input rst_n,
    input RX_IN,
    input PAR_EN,
    input PAR_TYP,
    input [5:0] prescale,

    output [7:0] P_DATA,
    output par_err,
    output stp_err,
    output strt_glitch,
    output data_valid
);
    // Internal wires:
    wire [3:0] bit_cnt;
    wire [5:0] edge_cnt;
    wire enable;
    wire par_chk_en;
    wire strt_chk_en;
    wire stp_chk_en;
    wire dat_samp_en;
    wire deser_en;
    wire sampled_bit;
    
    edge_bit_counter u_edge_bit_counter (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .PAR_EN(PAR_EN),
        .prescale(prescale),
        .edge_cnt(edge_cnt),
        .bit_cnt(bit_cnt)
    );
    
    FSM_RX u_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .RX_IN(RX_IN),
        .PAR_EN(PAR_EN),
        .bit_cnt(bit_cnt),
        .edge_cnt(edge_cnt),
        .prescale(prescale),
        .par_err(par_err),
        .stp_err(stp_err),
        .strt_glitch(strt_glitch),
        .enable(enable),
        .par_chk_en(par_chk_en),
        .strt_chk_en(strt_chk_en),
        .stp_chk_en(stp_chk_en),
        .dat_samp_en(dat_samp_en),
        .deser_en(deser_en),
        .data_valid(data_valid)
    );
    
    data_sampling u_data_sampling (
        .clk(clk),
        .rst_n(rst_n),
        .RX_in(RX_IN),
        .dat_samp_en(dat_samp_en),
        .prescale(prescale),
        .edge_cnt(edge_cnt),
        .sampled_bit(sampled_bit)
    );
    
    deserializer u_deserializer (
        .clk(clk),
        .rst_n(rst_n),
        .deser_en(deser_en),
        .sampled_bit(sampled_bit),
        .P_DATA(P_DATA)
    );
    
    parity_check u_parity_check (
        .clk(clk),
        .rst_n(rst_n),
        .par_chk_en(par_chk_en),
        .PAR_TYP(PAR_TYP),
        .data_in(P_DATA), // Pass the deserialized data to parity check
        .sampled_bit(sampled_bit),
        .par_err(par_err)
    );
    
    start_check u_start_check (
        .clk(clk),
        .rst_n(rst_n),
        .strt_chk_en(strt_chk_en),
        .sampled_bit(sampled_bit),
        .strt_glitch(strt_glitch)
    );
    
    stop_check u_stop_check (
        .clk(clk),
        .rst_n(rst_n),
        .stp_chk_en(stp_chk_en),
        .sampled_bit(sampled_bit),
        .stp_err(stp_err)
    );

endmodule