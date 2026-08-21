`timescale 1ps/1ps

module reset_gen(
    input logic clk,
    input logic async_rst_n,

    output logic rst_n
);
    logic rst_ff1;

    always_ff @ (posedge clk or negedge async_rst_n) begin
        if(!async_rst_n) begin
            rst_ff1 <= 0;
            rst_n <= 0;
        end else begin
            rst_ff1 <= 1;
            rst_n <= rst_ff1;
        end
    end
endmodule