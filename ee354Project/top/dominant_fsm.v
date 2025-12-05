`timescale 1ns / 1ps

module dominant_fsm (
    input wire clk,
    input wire reset,
    input wire start,
    input wire mul_done,
    input wire scale_done,
    input wire diff_done,
    input wire [3:0] max_d_in,
    input wire [2:0] epsilon,
    output reg load_v_old,
    output reg load_y,
    output reg load_max_d,
    output reg start_mult,
    output reg start_scale,
    output reg start_diff,
    output reg done,
    output wire [7:0] state_out
);

    localparam [7:0] IDLE = 8'b0000_0001;
    localparam [7:0] LOAD = 8'b0000_0010;
    localparam [7:0] MULT = 8'b0000_0100;
    localparam [7:0] WAIT_MAX = 8'b0000_1000;
    localparam [7:0] SCALE =8'b0001_0000;
    localparam [7:0] DIFF = 8'b0010_0000;
    localparam [7:0] CHECK =8'b0100_0000;
    localparam [7:0] DONE_ST = 8'b1000_0000;

    localparam [3:0] MIN_ITERATIONS = 4'd3;

    //need at least 3 iter before checking if converged
    reg [7:0] state_reg;
    reg [7:0] state_n;
    reg [7:0] temp_state_val;

    reg [1:0] wait_max;
    reg [1:0] wait_max_next;

    reg [3:0] iter;
    reg [3:0] iter_next;

    reg mult_busy;
    reg mult_busy_next;

    reg scale_busy;
    reg scale_busy_next;

    reg diff_busy;
    reg diff_busy_next;

    //edge detect for start signal
    reg start_prev;

    wire [3:0] eps_thresh = {1'b0, epsilon};
    //check if difference small enough
    wire start_pulse = start &~start_prev;
    wire iter_ok = (iter >=MIN_ITERATIONS);
    wire eps_ok = (max_d_in <=eps_thresh);

    wire temp_state = state_reg;
    wire state_temp2 = temp_state;
    assign state_out = state_temp2;

    always @(*) begin
        temp_state_val = state_reg;
        state_n = temp_state_val;
        wait_max_next = wait_max;
        iter_next = iter;
        mult_busy_next = mult_busy;
        scale_busy_next = scale_busy;
        diff_busy_next = diff_busy;

        load_v_old = 1'b0;
        load_y = 1'b0;
        load_max_d = 1'b0;
        start_mult = 1'b0;
        start_scale = 1'b0;
        start_diff = 1'b0;
        done = 1'b0;

        case (state_reg)
            IDLE: begin
                //wait for start
                iter_next = 4'd0;
                wait_max_next = 2'd0;
                mult_busy_next = 1'b0;
                scale_busy_next = 1'b0;
                diff_busy_next = 1'b0;
                if (start_pulse == 1'b1) begin
                    state_n = LOAD;
                end
            end

            LOAD: begin

                //load old vec into reg
                load_v_old = 1'b1;
                state_n = MULT;
            end

            MULT: begin
                //start mat vec mult
                if (mult_busy == 1'b0) begin
                    start_mult = 1'b1;
                    mult_busy_next = 1'b1;
                end
                if (mul_done == 1'b1) begin
                    load_y = 1'b1;
                    wait_max_next = 2'd2;
                    mult_busy_next = 1'b0;
                    state_n = WAIT_MAX;
                end
            end

            WAIT_MAX: begin
                //wait a few cycles for max to be ready
                if (wait_max != 2'd0) begin
                    wait_max_next = wait_max -1'b1;
                end else begin
                    state_n = SCALE;
                end
            end

            SCALE: begin
                //scale the result
                if (scale_busy == 1'b0) begin
                    start_scale = 1'b1;
                    scale_busy_next = 1'b1;
                end
                if (scale_done == 1'b1) begin
                    scale_busy_next = 1'b0;
                    state_n = DIFF;
                end
            end

            DIFF: begin
                //calc difference between old and new vec
                if (diff_busy == 1'b0) begin
                    start_diff = 1'b1;
                    diff_busy_next = 1'b1;
                end
                if (diff_done == 1'b1) begin
                    diff_busy_next = 1'b0;
                    load_max_d = 1'b1;
                    //increment iteration count
                    if (iter != 4'd15) begin
                        iter_next = iter + 1'b1;
                    end
                    state_n = CHECK;
                end
            end

            CHECK: begin
                //check converged or need more iters
                if (iter_ok == 1'b0) begin
                    state_n = LOAD;
                end else if (eps_ok == 1'b1) begin
                    state_n = DONE_ST;
                end else begin
                    state_n = LOAD;
                end
            end

            DONE_ST: begin
                done = 1'b1;
                if (start_pulse == 1'b1) begin
                    state_n = LOAD;
                    iter_next = 4'd0;
                end
            end

            default: begin
                state_n = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin

        if (reset == 1'b1) 
        begin
            state_reg <= IDLE;
            wait_max <= 2'd0;
            iter <= 4'd0;
            mult_busy <= 1'b0;
            scale_busy <= 1'b0;
            diff_busy <= 1'b0;
            start_prev <= 1'b0;
        end 
        else 
        begin
            state_reg <= state_n;
            wait_max <= wait_max_next;
            iter <= iter_next;
            mult_busy <= mult_busy_next;
            scale_busy <= scale_busy_next;
            diff_busy <= diff_busy_next;
            start_prev <= start;
        end
    end

endmodule
