`timescale 1ns/1ns

module rx_fsm(
    input logic clk,
    input logic rst_n,
    input logic tick_16x,
    input logic rx,

    output logic [7:0] rx_data,
    output logic rx_ready
);

    always_ff @ (posedge clk or negedge rst_n) begin

    end

endmodule