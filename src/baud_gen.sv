`timescale 1ns/1ns

module baud_gen#(
    parameter DIVISOR_WIDTH = 16
) (
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic [DIVISOR_WIDTH-1:0] dvsr,

    output logic baud_out
);
    logic [DIVISOR_WIDTH-1:0] counter;

    always_ff @ (posedge clk or negedge rst_n) begin
        if (!rst_n || !enable) begin
            counter <= 0;
            baud_out <= 0;
        end else if (counter == dvsr - 1) begin
            counter <= 0;
            baud_out <= 1;
        end else begin
            counter <= counter + 1;
            baud_out <= 0;
        end
    end

endmodule