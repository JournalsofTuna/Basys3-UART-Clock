`timescale 1ns / 1ps

module uart_rx(
    input clk,       // 100 MHz Sistem Saati
    input rx,        // USB'den gelen veri hattı
    output reg [7:0] data_out, // Alınan 8 bitlik veri (ASCII)
    output reg new_data        // Veri geldiğinde 1 olur
    );

    // 9600 Baud Rate için parametreler
    // 100.000.000 / 9600 = 10416
    parameter CLKS_PER_BIT = 10416;

    parameter IDLE = 0;
    parameter START = 1;
    parameter DATA = 2;
    parameter STOP = 3;
    parameter CLEANUP = 4;

    reg [2:0] state = 0;
    reg [13:0] clk_count = 0;
    reg [2:0] bit_index = 0;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                new_data <= 0;
                clk_count <= 0;
                bit_index <= 0;
                if (rx == 0) state <= START; // Start bit (0) algılandı
            end

            START: begin
                if (clk_count == (CLKS_PER_BIT-1)/2) begin
                    if (rx == 0) begin
                        clk_count <= 0;
                        state <= DATA;
                    end else state <= IDLE;
                end else clk_count <= clk_count + 1;
            end

            DATA: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    data_out[bit_index] <= rx;
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= STOP;
                    end
                end
            end

            STOP: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    new_data <= 1; // Veri hazır!
                    clk_count <= 0;
                    state <= CLEANUP;
                end
            end

            CLEANUP: begin
                state <= IDLE;
                new_data <= 0;
            end
        endcase
    end
endmodule
