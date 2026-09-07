`timescale 1ns/1ns

module uart_top #(
    parameter DIVISOR_WIDTH = 16
) (
    input logic clk,
    input logic async_rst_n,

    input  logic [DIVISOR_WIDTH-1:0] dvsr,

    input  logic rx,
    output logic tx,

    input  logic [7:0] tx_data,
    input  logic       tx_start,
    output logic       tx_busy,

    output logic [7:0] rx_data,
    output logic       rx_ready,
    output logic       frame_err
);
    logic rst_n;
    logic tick_16x;

    reset_gen u_reset_gen (
        .clk(clk),
        .async_rst_n(async_rst_n),
        .rst_n(rst_n)
    );

    baud_gen #(
        .DIVISOR_WIDTH (DIVISOR_WIDTH)
    ) u_baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .enable(1'b1),
        .dvsr(dvsr),
        .baud_out(tick_16x)
    );

    tx_fsm u_tx_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .tick_16x(tick_16x),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    rx_fsm u_rx_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .tick_16x(tick_16x),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .frame_err(frame_err)
    );

endmodule
