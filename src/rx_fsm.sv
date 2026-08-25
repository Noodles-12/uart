`timescale 1ns/1ns

module rx_fsm(
    input logic clk,
    input logic rst_n,
    input logic tick_16x,
    input logic rx,

    output logic [7:0] rx_data,
    output logic rx_ready
);
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START_BIT = 2'b01,
        DATA_BITS = 2'b10,
        STOP_BIT = 2'b11
    } rx_state;

    rx_state current_state;

    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= IDLE;
        end else begin

        end
    end

endmodule