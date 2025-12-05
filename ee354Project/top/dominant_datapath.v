`timescale 1ns / 1ps

module dominant_datapath #(
    parameter integer Y_WIDTH = 12,
    parameter integer SCALE_OUT = 4
) (
    input wire clk,
    input wire reset,
    input wire load_v_old,
    input wire load_y,
    input wire load_max_d,
    input wire start_mult,
    input wire start_scale,
    input wire start_diff,
    input wire [4*4-1:0] v_init,
    input wire [3:0] A00, A01, A02, A03,
    input wire [3:0] A10, A11, A12, A13,
    input wire [3:0] A20, A21, A22, A23,
    input wire [3:0] A30, A31, A32, A33,
    output wire mul_done,
    output wire scale_done,
    output wire diff_done,
    output wire [3:0] max_d_out,
    output wire [3:0] v0,
    output wire [3:0] v1,
    output wire [3:0] v2,
    output wire [3:0] v3,
    output wire [3:0] v_old0,
    output wire [3:0] v_old1,
    output wire [3:0] v_old2,
    output wire [3:0] v_old3,
    output wire v_new_valid_out,
    output wire [4*Y_WIDTH-1:0] y_out,
    output wire [Y_WIDTH-1:0] max_out,
    output wire [4*SCALE_OUT-1:0] v_new_out
);

    localparam integer LANE_WIDTH = 4;
    localparam integer VECTOR_WIDTH = 4 * LANE_WIDTH;
    localparam integer MATRIX_WIDTH = 16 * LANE_WIDTH;
    localparam integer MAX_WIDTH = Y_WIDTH;

    //pack matrix into bus
    wire [MATRIX_WIDTH-1:0] matrix_bus = {
        A33, A32, A31, A30,
        A23, A22, A21, A20,
        A13, A12, A11, A10,
        A03, A02, A01, A00
    };

    reg first_iter;
    reg first_iter_next;
    reg [4*Y_WIDTH-1:0] y;
    reg [4*Y_WIDTH-1:0] y_next;
    reg [3:0] max_diff;
    reg [3:0] max_diff_next;

    reg [1:0] scale_state;
    reg [1:0] scale_state_next;
    reg max_start;
    reg max_start_next;
    reg scale_start;
    reg scale_start_next;
    reg scale_done_reg;
    reg scale_done_next;
    reg [4*SCALE_OUT-1:0] v_new;
    reg [4*SCALE_OUT-1:0] v_new_next;
    reg v_new_valid;
    reg v_new_valid_next;

    localparam [1:0] SCALE_IDLE = 2'd0;
    localparam [1:0] SCALE_MAX = 2'd1;
    localparam [1:0] SCALE_DIV = 2'd2;

    wire [VECTOR_WIDTH-1:0] v_old_bus;
    //use seed first time, then feedback
    wire [VECTOR_WIDTH-1:0] seed =v_init;
    wire [VECTOR_WIDTH-1:0] feedback = v_new[VECTOR_WIDTH-1:0];
    wire [VECTOR_WIDTH-1:0] v_reg_in = first_iter ? seed :feedback ;

    //reg to hold old vec
    vector_register vreg_old (
        .clk(clk),
        .reset(reset),
        .load(load_v_old),
        .vec_in(v_reg_in),
        .vec_out(v_old_bus)
    );

    wire [4*Y_WIDTH-1:0] y_result;

    //multiply matrix by vector
    matrix_vector_mult #(.OUT_WIDTH(Y_WIDTH)) matmul (
        .clk(clk),
        .reset(reset),
        .start(start_mult),
        .A(matrix_bus),
        .V(v_old_bus),
        .Y(y_result),
        .done(mul_done)
    );

    wire [MAX_WIDTH-1:0] max_value;
    wire max_done;

    //find maxx in y vec
    vector_max #(
        .WIDTH(Y_WIDTH)
    ) vmax (
        .clk(clk),
        .reset(reset),
        .start(max_start),
        .vec_in(y),
        .max_out(max_value),
        .done(max_done)
    );

    wire [4*SCALE_OUT-1:0] scaled_vector;
    wire scale_div_done;

    vector_scale #(
        .IN_WIDTH(Y_WIDTH),
        .OUT_WIDTH(SCALE_OUT),
        .MAX_WIDTH(MAX_WIDTH)
    ) vscale (
        .clk(clk),
        .reset(reset),
        .start(scale_start),
        .V_in(y),
        .max_value(max_value),
        .V_out(scaled_vector),
        .done(scale_div_done)
    );

    wire [3:0] max_diff_raw;

    vector_diff #(.WIDTH(LANE_WIDTH)) vdiff (
        .clk(clk),
        .reset(reset),
        .start(start_diff),
        .vec_new(v_new[VECTOR_WIDTH-1:0]),
        .vec_old(v_old_bus),
        .max_diff(max_diff_raw),
        .done(diff_done)
    );

    always @(*) begin
        //update regs based on ctrl signals
        first_iter_next = first_iter;
        y_next = y;
        max_diff_next = max_diff;

        if (load_v_old ) begin
            first_iter_next =1'b0;
        end

        if (load_y) begin
            y_next =y_result;
        end

        if (load_max_d) begin
            max_diff_next =max_diff_raw;
        end
    end

    always @(*) begin
        //state machine for scaling
        scale_state_next = scale_state;
        max_start_next = 1'b0;
        scale_start_next = 1'b0;
        scale_done_next = 1'b0;
        v_new_next = v_new;
        v_new_valid_next = v_new_valid;

        case (scale_state)
            SCALE_IDLE: begin
                v_new_valid_next = 1'b0;
                if (start_scale ) begin
                    max_start_next = 1'b1;
                    scale_state_next = SCALE_MAX;
                end
            end

            SCALE_MAX: begin
                //wait for max to finish
                if (max_done) begin
                    scale_start_next = 1'b1;
                    scale_state_next = SCALE_DIV;
                end
            end

            SCALE_DIV: begin
                //scaling done, save result
                if (scale_div_done ) begin
                    v_new_next = scaled_vector;
                    v_new_valid_next = 1'b1;
                    scale_done_next = 1'b1;
                    scale_state_next = SCALE_IDLE;
                end
            end

            default: begin
                scale_state_next = SCALE_IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            first_iter <= 1'b1;
            y <= {(4*Y_WIDTH){1'b0}};
            max_diff <= 4'd0;
            scale_state <= SCALE_IDLE;
            max_start <= 1'b0;
            scale_start <= 1'b0;
            scale_done_reg <= 1'b0;
            v_new <= {(4*SCALE_OUT){1'b0}};
            v_new_valid <= 1'b0;
        end else begin
            first_iter <= first_iter_next;
            y <= y_next;
            max_diff <= max_diff_next;
            scale_state <= scale_state_next;
            max_start <= max_start_next;
            scale_start <= scale_start_next;
            scale_done_reg <= scale_done_next;
            v_new <= v_new_next;
            v_new_valid <= v_new_valid_next;
        end
    end

    assign scale_done = scale_done_reg;
    assign max_d_out = max_diff;
    assign v_new_valid_out = v_new_valid;
    assign y_out = y;
    assign max_out = max_value;
    assign v_new_out = v_new;
    assign {v3, v2, v1, v0} = v_new[VECTOR_WIDTH-1:0];
    assign {v_old3, v_old2, v_old1, v_old0} = v_old_bus;

endmodule
