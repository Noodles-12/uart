`timescale 1ns/1ns

module rx_fsm(
    input logic clk,
    input logic rst_n,
    input logic tick_16x,
    input logic rx,

    output logic [7:0] rx_data,
    output logic rx_ready,
    output logic frame_err
);
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START_BIT = 2'b01,
        DATA_BITS = 2'b10,
        STOP_BIT = 2'b11
    } rx_state;

    rx_state current_state;
    logic [3:0] tick_count;
    logic [3:0] bit_count;
    logic [7:0] temp_reg;
    logic [1:0] vote_count;
    logic fall_edge;
    
    logic rx_ff1, rx_sync, rx_sync_prev;

    assign fall_edge = ~rx_sync & rx_sync_prev;

    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= IDLE;
            tick_count <= 4'b0;
            bit_count <= 4'b0;
            vote_count <= 2'b0;
            temp_reg <= 8'b0;
            rx_data <= 8'b0;
            rx_ready <= 1'b0;
            frame_err <= 1'b0;
        end else begin
            rx_ready <= 1'b0;

            if(current_state == IDLE) begin
                if(fall_edge) begin
                    current_state <= START_BIT;
                    tick_count <= 4'b0;
                end
            end else if(tick_16x) begin
                tick_count <= tick_count + 1;

                unique case(current_state)
                    START_BIT: begin
                        if(tick_count == 4'd8) begin
                            if(~rx_sync) begin
                                current_state <= DATA_BITS;
                                tick_count <= 4'b0;
                                bit_count <= 4'b0;
                                vote_count <= 2'b0;
                            end else begin
                                current_state <= IDLE;
                            end
                        end
                    end

                    DATA_BITS: begin
                        if(tick_count == 4'd7 || tick_count == 4'd8 || tick_count == 4'd9) begin
                            vote_count <= vote_count + rx_sync;
                        end

                       if(tick_count == 4'd15) begin
                            vote_count <= 4'b0;
                            temp_reg <= {vote_count >= 2'd2, temp_reg[7:1]};

                            if(bit_count == 4'd7) begin
                                current_state <= STOP_BIT;
                            end else begin
                                bit_count <= bit_count + 1;
                            end
                        end
                    end

                    STOP_BIT: begin
                        if(tick_count == 4'd7 || tick_count == 4'd8 || tick_count == 4'd9) begin
                            vote_count <= vote_count + rx_sync;
                        end

                         if(tick_count == 4'd15) begin
                            vote_count <= 2'b0;
                            rx_data <= temp_reg;
                            rx_ready <= 1'b1;
                            frame_err <= (vote_count < 2'd2);
                            current_state <= IDLE;
                        end
                    end
                endcase
            end
        end
    end

    always_ff @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rx_ff1 <= 0;
            rx_sync <= 0;
            rx_sync_prev <= 0;
        end else begin
            rx_ff1 <= rx;
            rx_sync <= rx_ff1;
            rx_sync_prev <= rx_sync;
        end
    end

endmodule