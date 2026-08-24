`timescale 1ns/1ns

module tx_fsm (
  input logic clk,
  input logic rst_n,
  input logic tick_16x,
  input logic [7:0] tx_data,
  input logic tx_start,

  output logic tx,
  output logic tx_busy
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START_BIT = 2'b01,
        DATA_BITS = 2'b10,
        STOP_BIT = 2'b11
    } tx_state;

    logic [7:0] tx_shift_reg;
    logic [3:0] bit_count;
    logic [3:0] tick_count;
    tx_state current_state;
    logic tx_tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || current_state == IDLE) begin
            tick_count <= 4'b0;
            tx_tick <= 0;
        end else if (tick_16x) begin
            if (tick_count < 4'd15) begin
                tick_count <= tick_count + 4'd1;
                tx_tick <= 1'b0;
            end else begin
                tick_count <= 4'b0;
                tx_tick <= 1'b1;
            end
        end else begin
            tx_tick <= 0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            tx_shift_reg <= 8'b0;
            bit_count <= 4'b0;
            tx_busy <= 1'b0;
        end else begin
            if (current_state == IDLE) begin
                if (tx_start) begin
                    current_state <= START_BIT;
                    tx_shift_reg <= tx_data;
                    bit_count <= 4'b0;
                    tx_busy <= 1'b1;
                end
            end else if (tx_tick) begin
                unique case (current_state)
                    START_BIT: begin
                        current_state <= DATA_BITS;
                    end

                    DATA_BITS: begin
                        bit_count <= bit_count + 1;
                        if (bit_count == 4'd7) begin
                            current_state <= STOP_BIT;
                        end
                    end

                    STOP_BIT: begin
                        current_state <= IDLE;
                        tx_busy <= 1'b0;
                    end

                    default: current_state <= IDLE;
                endcase
            end
        end
    end

    always_comb begin
        case (current_state)
            IDLE:       tx = 1'b1;
            START_BIT:  tx = 1'b0;
            DATA_BITS:  tx = tx_shift_reg[bit_count];
            STOP_BIT:   tx = 1'b1;
            default:    tx = 1'b1;
        endcase
    end

endmodule