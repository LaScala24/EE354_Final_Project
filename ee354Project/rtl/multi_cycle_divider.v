`timescale 1ns / 1ps
    // FSM: Restoring Division, brother told me about algo
    // STATE_IDLE -> STATE_DIV -> STATE_DONE -> STATE_IDLE
    // IDLE: Wait for start, initialize registers, check for divide-by-zero
    // DIV: Loop WIDTH_QUOTIENT times, compute one quotient bit per cycle
    // DONE: Signal result ready, return to IDLE

module multi_cycle_divider #(
    parameter integer WIDTH_DIVIDEND = 12,
    parameter integer WIDTH_DIVISOR = 12,
    parameter integer WIDTH_QUOTIENT = 4
) (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [WIDTH_DIVIDEND-1:0] dividend,
    input  wire [WIDTH_DIVISOR-1:0]  divisor,
    output reg  [WIDTH_QUOTIENT-1:0] quotient,
    output reg  done
);

    localparam [1:0] STATE_IDLE = 2'b00;
    localparam [1:0] STATE_DIV = 2'b01;
    localparam [1:0] STATE_DONE = 2'b10;
    localparam integer COUNT_WIDTH = $clog2(WIDTH_QUOTIENT+ 1) + 1;

    reg [1:0] state;
    reg [1:0] state_next;
    // fsm to do divison
    reg [WIDTH_DIVIDEND-1:0] dividend_shift;
    reg [WIDTH_DIVIDEND-1:0] dividend_shift_next;

    reg [WIDTH_DIVISOR-1:0] divisor_reg;
    reg [WIDTH_DIVISOR-1:0] divisor_next;

    reg [WIDTH_QUOTIENT-1:0] quot;
    reg [WIDTH_QUOTIENT-1:0] quot_next;

    reg [WIDTH_DIVISOR:0] rem;
    reg [WIDTH_DIVISOR:0] rem_next;

    reg [COUNT_WIDTH-1:0] bit_count;
    reg [COUNT_WIDTH-1:0] bit_count_next;

    reg done_next;
    reg [WIDTH_QUOTIENT-1:0] quot_out_next;

    //shift remainder and bring in next bit from dividend
    wire [WIDTH_DIVISOR:0] rem_shifted = {rem[WIDTH_DIVISOR-1:0], dividend_shift[WIDTH_DIVIDEND-1]};
    //try subtracting divisor
    wire [WIDTH_DIVISOR:0] rem_after_sub = rem_shifted -{1'b0, divisor_reg};

    wire sub_ok = (rem_after_sub[WIDTH_DIVISOR] == 1'b0);

    function [WIDTH_QUOTIENT-1:0] shift_in_bit;// to bit shitf by a newbut amount
        input [WIDTH_QUOTIENT-1:0] current;
        input                      new_bit;
        begin
            if (WIDTH_QUOTIENT == 1) 
                begin
                shift_in_bit = {new_bit};
                end 
            else 
                begin
                shift_in_bit = {current[WIDTH_QUOTIENT-2:0], new_bit};
                end
        end
    endfunction

    wire [WIDTH_QUOTIENT-1:0] quot_new = shift_in_bit(quot, sub_ok);

    always @(*) 
        begin
        
        state_next = state;

        dividend_shift_next = dividend_shift;
        divisor_next = divisor_reg;
        quot_next = quot;
        rem_next = rem;

        bit_count_next = bit_count;
        done_next = 1'b0;
        quot_out_next = quotient;

        case (state)
            STATE_IDLE: 
                begin
                if (start) 
                    begin
                    if (divisor == 0) 
                        begin
                        quot_out_next = {WIDTH_QUOTIENT{1'b0}};
                        state_next = STATE_DONE;
                        end 
                    else 
                        begin
                        
                        dividend_shift_next = dividend;
                        divisor_next = divisor;

                        quot_next = {WIDTH_QUOTIENT{1'b0}};
                        rem_next = {(WIDTH_DIVISOR + 1){1'b0}};
                        bit_count_next = WIDTH_QUOTIENT - 1;
                        state_next = STATE_DIV;

                        end
                    end
                end

            STATE_DIV: 
                begin
                //division algorithm step - subtract if possible
                rem_next = sub_ok ? rem_after_sub : rem_shifted;
                quot_next = quot_new;
                //shift dividend left
                dividend_shift_next = {dividend_shift[WIDTH_DIVIDEND-2:0], 1'b0};

                if (bit_count == 0) 
                    begin
                    quot_out_next = quot_new;
                    state_next = STATE_DONE;
                    end
 
                    else 
                        begin
                        bit_count_next = bit_count -1'b1;
                    end

                end

            STATE_DONE: 
                begin
                done_next = 1'b1;
                state_next = STATE_IDLE;
                end
        endcase
        end

    always @(posedge clk) 
        begin
        if (reset) 
            begin

            state <= STATE_IDLE;

            dividend_shift <= {WIDTH_DIVIDEND{1'b0}};
            divisor_reg <= {WIDTH_DIVISOR{1'b0}};

            quot <= {WIDTH_QUOTIENT{1'b0}};
            rem <= {(WIDTH_DIVISOR + 1){1'b0}};

            bit_count <= { COUNT_WIDTH{1'b0}};
            quotient <= {WIDTH_QUOTIENT{1'b0}};
            done <= 1'b0;
            end 
        else 
            begin

            state <= state_next;

            dividend_shift <= dividend_shift_next;
            divisor_reg <= divisor_next;

            quot <= quot_next;
            rem <= rem_next;

            bit_count <= bit_count_next;
            quotient <= quot_out_next;
            done <= done_next;

            end
        end

endmodule
