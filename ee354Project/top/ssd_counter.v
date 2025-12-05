`timescale 1ns / 1ps
// difrent way of ssd scanning, by conv binary to bcd to display the number
module ssd_counter 
(
    input wire clk,
    input wire [15:0] displayNumberLow,
    input wire [15:0] displayNumberHigh,
    output reg [7:0] anode,
    output reg [6:0] ssdOut
);

    reg [20:0] refresh;
    reg [3:0] active_digit;
    wire [2:0] scan_idx = refresh[20:18];

    //splt into digits
    reg [3:0] digit_low3;
    reg [3:0] digit_low2;
    reg [3:0] digit_low1;
    reg [3:0] digit_low0;

    reg [3:0] digit_high3;
    reg [3:0] digit_high2;
    reg [3:0] digit_high1;
    reg [3:0] digit_high0;

    reg [19:0] low_bcd;
    reg [19:0] high_bcd;

    //convert bin to bcd
    function [19:0] bin16_to_bcd;
        input [15:0] value;
        integer idx;
        reg [35:0] shift_reg;
        begin
            shift_reg = 36'd0;
            shift_reg[15:0] = value;
            for (idx = 0; idx < 16; idx = idx+ 1) begin
                if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16]+ 3;
                if (shift_reg[23:20] >=5) shift_reg[23 :20] = shift_reg[23:20] +3;
                if (shift_reg[27:24] >=5) shift_reg[27:24] = shift_reg[27:24] + 3;
                if (shift_reg[31:28] >= 5) shift_reg[31:28] = shift_reg[31:28] + 3;
                shift_reg = shift_reg << 1;
            end
            bin16_to_bcd = shift_reg[35:16];
        end
    endfunction

    //counter for scanning digits
    always @(posedge clk) 
    begin
        refresh <= refresh + 21'd1;
    end

    always @(posedge clk) 
    begin
        //update bcd and extract digits
        low_bcd <= bin16_to_bcd( displayNumberLow);
        high_bcd <= bin16_to_bcd(displayNumberHigh);

        digit_low3 <= low_bcd[15:12];
        digit_low2 <= low_bcd[11:8];
        digit_low1 <= low_bcd[7:4];
        digit_low0 <= low_bcd[3:0];

        digit_high3 <= high_bcd[15:12];
        digit_high2 <=high_bcd[11:8];
        digit_high1 <=high_bcd[7:4];
        digit_high0 <= high_bcd[3:0];
    end

    always @(posedge clk) begin
        //scan through digits
        case (scan_idx)
            3'd0: 
            begin
                anode <= 8'b0111_1111;
                active_digit <= digit_high3;
            end

            3'd1: 
            begin
                anode <= 8'b1011_1111;
                active_digit <= digit_high2;
            end

            3'd2: 
            begin
                anode <= 8'b1101_1111;
                active_digit <= digit_high1;
            end

            3'd3: 
            begin
                anode <= 8'b1110_1111;
                active_digit <= digit_high0;
            end

            3'd4: 
            begin
                anode <= 8'b1111_0111;
                active_digit <= digit_low3;
            end

            3'd5: 
            begin
                anode <= 8'b1111_1011;
                active_digit <=digit_low2;
            end

            3'd6: 
            begin
                anode <= 8'b1111_1101;
                active_digit <= digit_low1;
            end

            default: 
            begin
                anode <= 8'b1111_1110;
                active_digit <= digit_low0;
            end

        endcase

    end

    always @(posedge clk) 
    begin
        //7 seg decoder
        case (active_digit)
            4'b0000: ssdOut <= 7'b0000001;
            4'b0001: ssdOut <= 7'b1001111;
            4'b0010: ssdOut <= 7'b0010010;
            4'b0011: ssdOut <= 7'b0000110;
            4'b0100: ssdOut <= 7'b1001100;
            4'b0101: ssdOut <= 7'b0100100;
            4'b0110: ssdOut <= 7'b0100000;
            4'b0111: ssdOut <= 7'b0001111;
            4'b1000: ssdOut <= 7'b0000000;
            4'b1001: ssdOut <= 7'b0000100;
            default: ssdOut <= 7'b0000001;
        endcase
    end

endmodule

