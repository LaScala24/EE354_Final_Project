`timescale 1ns / 1ps
// does all the work or display
module display_controller (
    input  wire clk,
    input  wire bright,
    input  wire [9:0] hCount,
    input  wire [9:0] vCount,
    input  wire [1:0] edit_row,
    input  wire [1:0] edit_col,
    input  wire cell_locked,
    input  wire sw0,
    input  wire sw1,
    input  wire [2:0] sw_eps,// unused because we hardcoded it(kamsi)
    input  wire [63:0] matrix_a,
    input  wire [15:0] vector_v,
    input  wire [7:0] fsm_state,
    input  wire fsm_done,
    input  wire [7:0] iteration_count,
    input  wire [15:0] v_old,
    input  wire [15:0] v_new,
    output reg  [11:0] rgb
);
// is not used, did manual instead
    function [19:0] bin16_to_bcd;
        input [15:0] value;
        //conver bin to bcd
        integer index_0_vga;
        reg [35:0] shift_reg_vga;
        begin
            shift_reg_vga = 36'd0;
            shift_reg_vga[15:0] = value;
            for (index_0_vga = 0; index_0_vga < 16; index_0_vga = index_0_vga + 1) begin
                if (shift_reg_vga[19:16] >= 5) shift_reg_vga[19:16] = shift_reg_vga[19:16] + 3;
                if (shift_reg_vga[23:20] >= 5) shift_reg_vga[23:20] = shift_reg_vga[23:20] + 3;
                if (shift_reg_vga[27:24] >= 5) shift_reg_vga[27:24] = shift_reg_vga[27:24] + 3;
                if (shift_reg_vga[31:28] >= 5) shift_reg_vga[31:28] = shift_reg_vga[31:28] + 3;
                if (shift_reg_vga[35:32] >= 5) shift_reg_vga[35:32] = shift_reg_vga[35:32] + 3;
                shift_reg_vga = shift_reg_vga << 1;
            end
            bin16_to_bcd = shift_reg_vga[35:16];
        end
    endfunction

    function font_bit;
        input [3:0] digit;
        input [2:0] x;
        input [2:0] y;
        //font bitmap lookup
        reg [4:0] row_bits_vga_vga;
        begin
            row_bits_vga_vga = 5'b00000;
            case (digit)
                4'd0: case (y)
                    0: row_bits_vga = 5'b01110;
                    1: row_bits_vga = 5'b10001;
                    2: row_bits_vga = 5'b10011;
                    3: row_bits_vga = 5'b10101;
                    4: row_bits_vga = 5'b11001;
                    5: row_bits_vga = 5'b10001;
                    6: row_bits_vga = 5'b01110;
                endcase
                4'd1: case (y)
                    0: row_bits_vga = 5'b00100;
                    1: row_bits_vga = 5'b01100;
                    2: row_bits_vga = 5'b00100;
                    3: row_bits_vga = 5'b00100;
                    4: row_bits_vga = 5'b00100;
                    5: row_bits_vga = 5'b00100;
                    6: row_bits_vga = 5'b01110;
                endcase
                4'd2: case (y)
                    0: row_bits_vga = 5'b01110;
                    1: row_bits_vga = 5'b10001;
                    2: row_bits_vga = 5'b00001;
                    3: row_bits_vga = 5'b00110;
                    4: row_bits_vga = 5'b01000;
                    5: row_bits_vga = 5'b10000;
                    6: row_bits_vga = 5'b11111;
                endcase
                4'd3: case (y)
                    0: row_bits_vga = 5'b11110;
                    1: row_bits_vga = 5'b00001;
                    2: row_bits_vga = 5'b00001;
                    3: row_bits_vga = 5'b01110;
                    4: row_bits_vga = 5'b00001;
                    5: row_bits_vga = 5'b00001;
                    6: row_bits_vga = 5'b11110;
                endcase
                4'd4: case (y)
                    0: row_bits_vga = 5'b00010;
                    1: row_bits_vga = 5'b00110;
                    2: row_bits_vga = 5'b01010;
                    3: row_bits_vga = 5'b10010;
                    4: row_bits_vga = 5'b11111;
                    5: row_bits_vga = 5'b00010;
                    6: row_bits_vga = 5'b00010;
                endcase
                4'd5: case (y)
                    0: row_bits_vga = 5'b11111;
                    1: row_bits_vga = 5'b10000;
                    2: row_bits_vga = 5'b11110;
                    3: row_bits_vga = 5'b00001;
                    4: row_bits_vga = 5'b00001;
                    5: row_bits_vga = 5'b10001;
                    6: row_bits_vga = 5'b01110;
                endcase
                4'd6: case (y)
                    0: row_bits_vga = 5'b01110;
                    1: row_bits_vga = 5'b10000;
                    2: row_bits_vga = 5'b11110;
                    3: row_bits_vga = 5'b10001;
                    4: row_bits_vga = 5'b10001;
                    5: row_bits_vga = 5'b10001;
                    6: row_bits_vga = 5'b01110;
                endcase
                4'd7: case (y)
                    0: row_bits_vga = 5'b11111;
                    1: row_bits_vga = 5'b00001;
                    2: row_bits_vga = 5'b00010;
                    3: row_bits_vga = 5'b00100;
                    4: row_bits_vga = 5'b01000;
                    5: row_bits_vga = 5'b10000;
                    6: row_bits_vga = 5'b10000;
                endcase
                4'd8: case (y)
                    0: row_bits_vga = 5'b01110;
                    1: row_bits_vga = 5'b10001;
                    2: row_bits_vga = 5'b10001;
                    3: row_bits_vga = 5'b01110;
                    4: row_bits_vga = 5'b10001;
                    5: row_bits_vga = 5'b10001;
                    6: row_bits_vga = 5'b01110;
                endcase
                4'd9: case (y)
                    0: row_bits_vga = 5'b01110;
                    1: row_bits_vga = 5'b10001;
                    2: row_bits_vga = 5'b10001;
                    3: row_bits_vga = 5'b01111;
                    4: row_bits_vga = 5'b00001;
                    5: row_bits_vga = 5'b00001;
                    6: row_bits_vga = 5'b01110;
                endcase// depending on digit displays numbera
                default: row_bits_vga = 5'b00000;
            endcase
            if ((x < FONT_BASE_W) && (y < FONT_BASE_H))
                font_bit = row_bits_vga[FONT_BASE_W-1 - x];
            else
                font_bit = 1'b0;
        end
    endfunction

    function digit_bitmap_pixel;
        input [3:0] digit;
        input [9:0] local_x;
        input [9:0] local_y;
        input [1:0] scale_shift;
        reg [2:0] glyph_x_vga;
        reg [2:0] glyph_y_vga;
        begin
            if ((local_x < (FONT_BASE_W << scale_shift)) &&
                (local_y < (FONT_BASE_H << scale_shift))) begin
                glyph_x_vga = local_x >> scale_shift;
                glyph_y_vga = local_y >> scale_shift;
                digit_bitmap_pixel = font_bit(digit, glyph_x_vga, glyph_y_vga);
            end else begin
                digit_bitmap_pixel = 1'b0;
            end
        end
    endfunction

    parameter BLACK = 12'b0000_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
    parameter YELLOW = 12'b1111_1111_0000;
    parameter CYAN = 12'b0000_1111_1111;
    parameter GREEN =12'b0000_1111_0000;
    parameter RED = 12'b1111_0000_0000;
    parameter MAGENTA = 12'b1111_0000_1111;
    parameter GRAY =12'b0100_0100_0100;
    parameter BLUE = 12'b0011_0011_1111;
    parameter ORANGE = 12'b1111_1000_0000;//colors

    //display layout params
    localparam integer FONT_BASE_W = 5;
    localparam integer FONT_BASE_H = 7;
    localparam integer DIGIT_COUNT = 5;

    parameter VEC_V_X0 = 20;
    parameter VEC_V_X1 = 120;
    parameter VEC_V_Y0 = 30;
    parameter VEC_V_Y1 = 220;
    parameter VEC_V_CELL_H = 45;
    
    parameter CHART_X0 = 160;
    parameter CHART_X1 = 620;
    parameter CHART_Y0 = 30;
    parameter CHART_Y1 = 220;
    parameter BAR_WIDTH = 45;
    parameter BAR_SPACING =10;
    parameter BAR_MAX_HEIGHT = 160;
    
    parameter MATRIX_X0 = 10;
    parameter MATRIX_X1 = 190;
    parameter MATRIX_Y0 = 250;
    parameter MATRIX_Y1 = 470;
    parameter MATRIX_CELL_SIZE =42;
    
    parameter VEC_NEW_X0 = 220;
    parameter VEC_NEW_X1 = 540;
    parameter VEC_NEW_Y0 = 320;
    parameter VEC_NEW_Y1 = 390;
    parameter VEC_NEW_CELL_W = 75;
    
    parameter ITER_X0 = 560;
    parameter ITER_Y0 = 340;

    wire [9:0] px_vga = hCount - 10'd144;
    wire [9:0] py_vga = vCount - 10'd35;
    
    //unpack matrix
    wire [3:0] A [0:3][0:3];
    assign A[0][0] = matrix_a[3:0];
    assign A[0][1] = matrix_a[7:4];
    assign A[0][2] = matrix_a[11:8];
    assign A[0][3] = matrix_a[15:12];
    assign A[1][0] = matrix_a[19:16];
    assign A[1][1] = matrix_a[23:20];
    assign A[1][2] = matrix_a[27:24];
    assign A[1][3] = matrix_a[31:28];
    assign A[2][0] = matrix_a[35:32];
    assign A[2][1] = matrix_a[39:36];
    assign A[2][2] = matrix_a[43:40];
    assign A[2][3] = matrix_a[47:44];
    assign A[3][0] = matrix_a[51:48];
    assign A[3][1] = matrix_a[55:52];
    assign A[3][2] = matrix_a[59:56];
    assign A[3][3] = matrix_a[63:60];
    
    wire [3:0] v [0:3];
    assign v[0] = vector_v[3:0];
    assign v[1] = vector_v[7:4];
    assign v[2] = vector_v[11:8];
    assign v[3] = vector_v[15:12];
    
    wire [3:0] vo [0:3];
    assign vo[0] = v_old[3:0];
    assign vo[1] = v_old[7:4];
    assign vo[2] = v_old[11:8];
    assign vo[3] = v_old[15:12];
    
    wire [3:0] vn [0:3];
    assign vn[0] = v_new[3:0];
    assign vn[1] = v_new[7:4];
    assign vn[2] = v_new[11:8];
    assign vn[3] = v_new[15:12];
    
    localparam IDLE = 7'b0000001;
    wire state_edit = (sw0 == 1'b0);

    //split into tens and ones
    reg [3:0] mat_digit_tens [0:3][0:3];
    reg [3:0] mat_digit_ones [0:3][0:3];

    reg [3:0] vec_digit_tens [0:3];
    reg [3:0] vec_digit_ones [0:3];

    reg [3:0] vnew_digit_tens [0:3];
    reg [3:0] vnew_digit_ones [0:3];

    integer i_0_vga, j_0_vga;

    //split numbers into digits for display
    always @(*) begin
        for (i_0_vga = 0; i_0_vga < 4; i_0_vga = i_0_vga + 1) begin
            vec_digit_tens[i_0_vga] = v[i_0_vga] / 10;
            vec_digit_ones[i_0_vga] = v[i_0_vga] % 10;
        end

        for (i_0_vga = 0; i_0_vga < 4; i_0_vga = i_0_vga + 1) begin
            vnew_digit_tens[i_0_vga] = vn[i_0_vga] / 10;
            vnew_digit_ones[i_0_vga] = vn[i_0_vga] % 10;
        end

        for (i_0_vga = 0; i_0_vga < 4; i_0_vga = i_0_vga + 1) begin
            for (j_0_vga = 0; j_0_vga < 4; j_0_vga = j_0_vga + 1) begin
                mat_digit_tens[i_0_vga][j_0_vga] = A[i_0_vga][j_0_vga] / 10;
                mat_digit_ones[i_0_vga][j_0_vga] = A[i_0_vga][j_0_vga] % 10;
            end
        end
    end

    function [3:0] get_vec_digit;
        input [1:0] row;
        input [1:0] slot;
        begin
            case (slot)
                2'd0: get_vec_digit = vec_digit_tens[row];
                2'd1: get_vec_digit = vec_digit_ones[row];
                default: get_vec_digit = 4'd0;
            endcase
        end
    endfunction

    function [3:0] get_vnew_digit;
        input [1:0] row;
        input [1:0] slot;
        begin
            case (slot)
                2'd0: get_vnew_digit = vnew_digit_tens[row];
                2'd1: get_vnew_digit = vnew_digit_ones[row];
                default: get_vnew_digit = 4'd0;
            endcase
        end
    endfunction

    function [3:0] get_mat_digit;
        input [1:0] row;
        input [1:0] col;
        input [1:0] slot;
        begin
            case (slot)
                2'd0: get_mat_digit = mat_digit_tens[row][col];
                2'd1: get_mat_digit = mat_digit_ones[row][col];
                default: get_mat_digit = 4'd0;
            endcase
        end
    endfunction

    wire in_vec_v_region = (px_vga >= VEC_V_X0) && (px_vga < VEC_V_X1) &&
                           (py_vga >= VEC_V_Y0) && (py_vga < VEC_V_Y1);
    
    //check which region
    wire in_chart_region = (px_vga >= CHART_X0) && (px_vga < CHART_X1) &&
                           (py_vga >= CHART_Y0) && (py_vga < CHART_Y1);
    
    wire in_matrix_region = (px_vga >= MATRIX_X0) && (px_vga < MATRIX_X1) &&
                            (py_vga >= MATRIX_Y0) && (py_vga < MATRIX_Y1);
    
    wire in_vec_new_region = (px_vga >= VEC_NEW_X0) && (px_vga < VEC_NEW_X1) &&
                             (py_vga >= VEC_NEW_Y0) && (py_vga < VEC_NEW_Y1);
    
    wire in_iter_region = (px_vga >= ITER_X0) && (px_vga < ITER_X0 + 70) &&
                          (py_vga >= ITER_Y0) && (py_vga < ITER_Y0 + 30);
    
    wire [9:0] vec_v_local_x = px_vga - VEC_V_X0;// local vs global is vga vs top
    wire [9:0] vec_v_local_y = py_vga - VEC_V_Y0;
    wire [1:0] vec_v_idx = vec_v_local_y / VEC_V_CELL_H;
    wire [9:0] vec_v_cell_y = vec_v_local_y - (vec_v_idx * VEC_V_CELL_H);
    wire vec_v_valid_idx = (vec_v_idx < 4) && (vec_v_local_y < 4 * VEC_V_CELL_H);
    
    wire [9:0] vec_v_width = VEC_V_X1 - VEC_V_X0;
    wire [9:0] vec_v_height = 4 * VEC_V_CELL_H;
    wire vec_v_left_bracket = in_vec_v_region && (vec_v_local_x < 8) && vec_v_valid_idx &&
                              ((vec_v_local_y < 4) || (vec_v_local_y >= vec_v_height - 4) || (vec_v_local_x < 3));
    wire vec_v_right_bracket = in_vec_v_region && (vec_v_local_x >= vec_v_width - 8) && vec_v_valid_idx &&
                               ((vec_v_local_y < 4) || (vec_v_local_y >= vec_v_height - 4) || (vec_v_local_x >= vec_v_width - 3));
    
    localparam integer VEC_DIGIT_SCALE = 1;
    localparam integer VEC_DIGIT_WIDTH = FONT_BASE_W << VEC_DIGIT_SCALE;
    localparam integer VEC_DIGIT_HEIGHT = FONT_BASE_H << VEC_DIGIT_SCALE;
    localparam integer VEC_DIGIT_SPACING = 3;
    localparam integer VEC_DIGIT_X_START = 18;
    localparam integer VEC_DIGIT_Y_OFF = 10;
    
    wire vec_digit_band = in_vec_v_region && vec_v_valid_idx &&
                          (vec_v_cell_y >= VEC_DIGIT_Y_OFF) && (vec_v_cell_y < VEC_DIGIT_Y_OFF + VEC_DIGIT_HEIGHT);
    wire [9:0] vec_digit_local_y = vec_v_cell_y - VEC_DIGIT_Y_OFF;
    
    wire vec_digit0_pix = vec_digit_band &&
                      (vec_v_local_x >= VEC_DIGIT_X_START) &&
                      (vec_v_local_x < VEC_DIGIT_X_START + VEC_DIGIT_WIDTH) &&
                      digit_bitmap_pixel(get_vec_digit(vec_v_idx, 2'd0),
                                         vec_v_local_x - VEC_DIGIT_X_START,
                                         vec_digit_local_y,
                                         VEC_DIGIT_SCALE);
    wire vec_digit1_pix = vec_digit_band &&
                      (vec_v_local_x >= VEC_DIGIT_X_START + (VEC_DIGIT_WIDTH + VEC_DIGIT_SPACING)) &&
                      (vec_v_local_x < VEC_DIGIT_X_START + (VEC_DIGIT_WIDTH + VEC_DIGIT_SPACING) + VEC_DIGIT_WIDTH) &&
                      digit_bitmap_pixel(get_vec_digit(vec_v_idx, 2'd1),
                                         vec_v_local_x - (VEC_DIGIT_X_START + (VEC_DIGIT_WIDTH + VEC_DIGIT_SPACING)),
                                         vec_digit_local_y,
                                         VEC_DIGIT_SCALE);
    
    wire vec_digits_on = vec_digit0_pix | vec_digit1_pix;
    
    wire vec_v_cursor = state_edit && (sw1 == 1'b1) && (vec_v_idx == edit_row) && vec_v_valid_idx;
    wire vec_v_cursor_border = vec_v_cursor && in_vec_v_region &&
                               ((vec_v_cell_y < 5) || (vec_v_cell_y >= VEC_V_CELL_H - 5) ||
                                (vec_v_local_x < 13) || (vec_v_local_x >= vec_v_width - 13));

    wire [9:0] chart_local_x = px_vga - CHART_X0;
    wire [9:0] chart_local_y = py_vga - CHART_Y0;
    wire [9:0] chart_width = CHART_X1 - CHART_X0;
    wire [9:0] chart_height = CHART_Y1 - CHART_Y0;
    wire [9:0] bar_bottom = chart_height - 15;
    
    wire [9:0] half_width = chart_width / 2;
    wire in_left_chart = in_chart_region && (chart_local_x < half_width);
    wire in_right_chart = in_chart_region && (chart_local_x >= half_width);
    
    wire [9:0] left_bar_base_x = 25;
    wire [9:0] right_bar_base_x = half_width + 25;
    
    wire [9:0] left_bar_offset = chart_local_x - left_bar_base_x;
    wire [9:0] right_bar_offset = chart_local_x - right_bar_base_x;
    wire [2:0] left_bar_idx = left_bar_offset / (BAR_WIDTH + BAR_SPACING);
    wire [2:0] right_bar_idx = right_bar_offset / (BAR_WIDTH + BAR_SPACING);
    wire [9:0] left_bar_local_x = left_bar_offset - (left_bar_idx * (BAR_WIDTH + BAR_SPACING));
    wire [9:0] right_bar_local_x = right_bar_offset - (right_bar_idx * (BAR_WIDTH + BAR_SPACING));
    
    localparam integer BAR_SCALE = 10;
    wire [9:0] vo_bar_h [0:3];
    wire [9:0] vn_bar_h [0:3];
    //scal vec val for bars
    wire [9:0] vo_scaled [0:3];
    wire [9:0] vn_scaled [0:3];
    assign vo_scaled[0] = vo[0] * BAR_SCALE;
    assign vo_scaled[1] = vo[1] * BAR_SCALE;
    assign vo_scaled[2] = vo[2] * BAR_SCALE;
    assign vo_scaled[3] = vo[3] * BAR_SCALE;
    assign vn_scaled[0] = vn[0] * BAR_SCALE;
    assign vn_scaled[1] = vn[1] * BAR_SCALE;
    assign vn_scaled[2] = vn[2] * BAR_SCALE;
    assign vn_scaled[3] = vn[3] * BAR_SCALE;
    //clamp bar heights to max
    assign vo_bar_h[0] = (vo_scaled[0] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vo_scaled[0];
    assign vo_bar_h[1] = (vo_scaled[1] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vo_scaled[1];
    assign vo_bar_h[2] = (vo_scaled[2] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vo_scaled[2];
    assign vo_bar_h[3] = (vo_scaled[3] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vo_scaled[3];//old
    assign vn_bar_h[0] = (vn_scaled[0] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vn_scaled[0];
    assign vn_bar_h[1] = (vn_scaled[1] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vn_scaled[1];
    assign vn_bar_h[2] = (vn_scaled[2] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vn_scaled[2];
    assign vn_bar_h[3] = (vn_scaled[3] > BAR_MAX_HEIGHT) ? BAR_MAX_HEIGHT : vn_scaled[3];//new
    
    //check if pixel is in old vector bar
    reg in_vo_bar;
    always @(*) begin
        in_vo_bar = 1'b0;
        if (in_left_chart && (left_bar_local_x < BAR_WIDTH) && (left_bar_idx < 4)) begin
            case (left_bar_idx[1:0])
                2'd0: in_vo_bar = (chart_local_y >= bar_bottom - vo_bar_h[0]) && (chart_local_y < bar_bottom);
                2'd1: in_vo_bar = (chart_local_y >= bar_bottom - vo_bar_h[1]) && (chart_local_y < bar_bottom);
                2'd2: in_vo_bar = (chart_local_y >= bar_bottom - vo_bar_h[2]) && (chart_local_y < bar_bottom);
                2'd3: in_vo_bar = (chart_local_y >= bar_bottom - vo_bar_h[3]) && (chart_local_y < bar_bottom);
                    endcase
                end
    end
    
    //check if pixel is in new vector bar
    reg in_vn_bar;
    always @(*) begin
        in_vn_bar = 1'b0;
        if (in_right_chart && (right_bar_local_x < BAR_WIDTH) && (right_bar_idx < 4)) begin
            case (right_bar_idx[1:0])
                2'd0: in_vn_bar = (chart_local_y >= bar_bottom - vn_bar_h[0]) && (chart_local_y < bar_bottom);
                2'd1: in_vn_bar = (chart_local_y >= bar_bottom - vn_bar_h[1]) && (chart_local_y < bar_bottom);
                2'd2: in_vn_bar = (chart_local_y >= bar_bottom - vn_bar_h[2]) && (chart_local_y < bar_bottom);
                2'd3: in_vn_bar = (chart_local_y >= bar_bottom - vn_bar_h[3]) && (chart_local_y < bar_bottom);
                    endcase
                end
    end
    
    wire chart_border = in_chart_region && 
                        ((chart_local_x < 2) || (chart_local_x >= chart_width - 2) ||
                         (chart_local_y < 2) || (chart_local_y >= chart_height - 2));
    wire chart_divider = in_chart_region && (chart_local_x >= half_width - 1) && (chart_local_x < half_width + 1);
    wire chart_baseline = in_chart_region && (chart_local_y >= bar_bottom) && (chart_local_y < bar_bottom + 2);

    wire [9:0] mat_local_x = px_vga - MATRIX_X0;
    wire [9:0] mat_local_y = py_vga - MATRIX_Y0;
    wire [9:0] mat_width = MATRIX_X1 - MATRIX_X0;
    wire [9:0] mat_height = MATRIX_Y1 - MATRIX_Y0;
    
    parameter MAT_BRACKET_W = 10;
    wire [9:0] mat_grid_x0 = MAT_BRACKET_W;
    wire [9:0] mat_grid_y0 = 20;
    wire [9:0] mat_grid_w = 4 * MATRIX_CELL_SIZE;
    wire [9:0] mat_grid_h = 4 * MATRIX_CELL_SIZE;
    
    wire in_mat_grid = in_matrix_region && 
                       (mat_local_x >= mat_grid_x0) && (mat_local_x < mat_grid_x0 + mat_grid_w) &&
                       (mat_local_y >= mat_grid_y0) && (mat_local_y < mat_grid_y0 + mat_grid_h);
    
    wire [9:0] mat_grid_rel_x = mat_local_x - mat_grid_x0;
    wire [9:0] mat_grid_rel_y = mat_local_y - mat_grid_y0;
    wire [1:0] mat_row = mat_grid_rel_y / MATRIX_CELL_SIZE;
    wire [1:0] mat_col = mat_grid_rel_x / MATRIX_CELL_SIZE;
    wire [9:0] mat_cell_x = mat_grid_rel_x - (mat_col * MATRIX_CELL_SIZE);
    wire [9:0] mat_cell_y = mat_grid_rel_y - (mat_row * MATRIX_CELL_SIZE);
    
    wire mat_left_bracket = in_matrix_region && (mat_local_x < MAT_BRACKET_W) &&
                            (mat_local_y >= mat_grid_y0) && (mat_local_y < mat_grid_y0 + mat_grid_h) &&
                            ((mat_local_y < mat_grid_y0 + 4) || 
                             (mat_local_y >= mat_grid_y0 + mat_grid_h - 4) || 
                             (mat_local_x < 3));
    wire mat_right_bracket = in_matrix_region && (mat_local_x >= mat_grid_x0 + mat_grid_w) &&
                             (mat_local_y >= mat_grid_y0) && (mat_local_y < mat_grid_y0 + mat_grid_h) &&
                             ((mat_local_y < mat_grid_y0 + 4) || 
                              (mat_local_y >= mat_grid_y0 + mat_grid_h - 4) || 
                              (mat_local_x >= mat_grid_x0 + mat_grid_w + MAT_BRACKET_W - 3));
    
    localparam integer MAT_DIGIT_SCALE = 0;
    localparam integer MAT_DIGIT_WIDTH = FONT_BASE_W << MAT_DIGIT_SCALE;
    localparam integer MAT_DIGIT_HEIGHT = FONT_BASE_H << MAT_DIGIT_SCALE;
    localparam integer MAT_DIGIT_SPACING = 1;
    localparam integer MAT_DIGIT_X_START = 4;
    localparam integer MAT_DIGIT_Y_OFF = 10;
    
    wire mat_digit_band = in_mat_grid &&
                          (mat_cell_y >= MAT_DIGIT_Y_OFF) && (mat_cell_y < MAT_DIGIT_Y_OFF + MAT_DIGIT_HEIGHT);
    wire [9:0] mat_digit_local_y = mat_cell_y - MAT_DIGIT_Y_OFF;
    
    wire mat_digit0_pix = mat_digit_band &&
                      (mat_cell_x >= MAT_DIGIT_X_START) &&
                      (mat_cell_x < MAT_DIGIT_X_START + MAT_DIGIT_WIDTH) &&
                      digit_bitmap_pixel(get_mat_digit(mat_row, mat_col, 2'd0),
                                         mat_cell_x - MAT_DIGIT_X_START,
                                         mat_digit_local_y,
                                         MAT_DIGIT_SCALE);
    wire mat_digit1_pix = mat_digit_band &&
                      (mat_cell_x >= MAT_DIGIT_X_START + (MAT_DIGIT_WIDTH + MAT_DIGIT_SPACING)) &&
                      (mat_cell_x < MAT_DIGIT_X_START + (MAT_DIGIT_WIDTH + MAT_DIGIT_SPACING) + MAT_DIGIT_WIDTH) &&
                      digit_bitmap_pixel(get_mat_digit(mat_row, mat_col, 2'd1),
                                         mat_cell_x - (MAT_DIGIT_X_START + (MAT_DIGIT_WIDTH + MAT_DIGIT_SPACING)),
                                         mat_digit_local_y,
                                         MAT_DIGIT_SCALE);
    
    wire mat_digits_on = mat_digit0_pix | mat_digit1_pix;
    
    wire mat_cell_border = in_mat_grid && 
                           ((mat_cell_x < 1) || (mat_cell_x >= MATRIX_CELL_SIZE - 1) ||
                            (mat_cell_y < 1) || (mat_cell_y >= MATRIX_CELL_SIZE - 1));
    
    //cursor highlight for matrix editing
    wire mat_cursor = state_edit && (sw1 == 1'b0) && in_mat_grid &&
                      (mat_row == edit_row) && (mat_col == edit_col);
    wire mat_cursor_border = mat_cursor &&
                             ((mat_cell_x < 5) || (mat_cell_x >= MATRIX_CELL_SIZE - 5) ||
                              (mat_cell_y < 5) || (mat_cell_y >= MATRIX_CELL_SIZE - 5));

    wire [9:0] vnew_local_x = px_vga - VEC_NEW_X0;
    wire [9:0] vnew_local_y = py_vga - VEC_NEW_Y0;
    wire [9:0] vnew_width = VEC_NEW_X1 - VEC_NEW_X0;
    wire [9:0] vnew_height = VEC_NEW_Y1 - VEC_NEW_Y0;
    
    wire [9:0] vnew_grid_x0 = 15;
    wire [2:0] vnew_idx = (vnew_local_x - vnew_grid_x0) / VEC_NEW_CELL_W;
    wire [9:0] vnew_cell_x = (vnew_local_x - vnew_grid_x0) - (vnew_idx * VEC_NEW_CELL_W);
    wire vnew_valid = (vnew_local_x >= vnew_grid_x0) && (vnew_idx < 4);
    
    wire vnew_left_bracket = in_vec_new_region && (vnew_local_x < 12) &&
                             ((vnew_local_y < 5) || (vnew_local_y >= vnew_height - 5) || (vnew_local_x < 3));
    wire vnew_right_bracket = in_vec_new_region && (vnew_local_x >= vnew_width - 12) &&
                              ((vnew_local_y < 5) || (vnew_local_y >= vnew_height - 5) || (vnew_local_x >= vnew_width - 3));
    
    localparam integer VNEW_DIGIT_SCALE = 1;
    localparam integer VNEW_DIGIT_WIDTH = FONT_BASE_W << VNEW_DIGIT_SCALE;
    localparam integer VNEW_DIGIT_HEIGHT = FONT_BASE_H << VNEW_DIGIT_SCALE;
    localparam integer VNEW_DIGIT_SPACING = 3;
    localparam integer VNEW_DIGIT_X_START = 18;
    localparam integer VNEW_DIGIT_Y_OFF = 18;
    
    wire vnew_digit_band = in_vec_new_region && vnew_valid &&
                           (vnew_local_y >= VNEW_DIGIT_Y_OFF) && (vnew_local_y < VNEW_DIGIT_Y_OFF + VNEW_DIGIT_HEIGHT);
    wire [9:0] vnew_digit_local_y = vnew_local_y - VNEW_DIGIT_Y_OFF;
    
    wire vnew_digit0_pix = vnew_digit_band &&
                       (vnew_cell_x >= VNEW_DIGIT_X_START) &&
                       (vnew_cell_x < VNEW_DIGIT_X_START + VNEW_DIGIT_WIDTH) &&
                       digit_bitmap_pixel(get_vnew_digit(vnew_idx[1:0], 2'd0),
                                          vnew_cell_x - VNEW_DIGIT_X_START,
                                          vnew_digit_local_y,
                                          VNEW_DIGIT_SCALE);
    wire vnew_digit1_pix = vnew_digit_band &&
                       (vnew_cell_x >= VNEW_DIGIT_X_START + (VNEW_DIGIT_WIDTH + VNEW_DIGIT_SPACING)) &&
                       (vnew_cell_x < VNEW_DIGIT_X_START + (VNEW_DIGIT_WIDTH + VNEW_DIGIT_SPACING) + VNEW_DIGIT_WIDTH) &&
                       digit_bitmap_pixel(get_vnew_digit(vnew_idx[1:0], 2'd1),
                                          vnew_cell_x - (VNEW_DIGIT_X_START + (VNEW_DIGIT_WIDTH + VNEW_DIGIT_SPACING)),
                                          vnew_digit_local_y,
                                          VNEW_DIGIT_SCALE);
    
    wire vnew_digits_on = vnew_digit0_pix | vnew_digit1_pix;
    
    wire vnew_border = in_vec_new_region &&
                       ((vnew_local_x < 2) || (vnew_local_x >= vnew_width - 2) ||
                        (vnew_local_y < 2) || (vnew_local_y >= vnew_height - 2));
    
    //split iteration count into digits
    wire [3:0] iter_tens = iteration_count / 10;
    wire [3:0] iter_ones = iteration_count % 10;
    
    wire [9:0] iter_local_x = px_vga - ITER_X0;
    wire [9:0] iter_local_y = py_vga - ITER_Y0;
    
    wire in_iter_tens = in_iter_region && (iter_local_x >= 5) && (iter_local_x < 30);
    wire in_iter_ones = in_iter_region && (iter_local_x >= 35) && (iter_local_x < 60);
    
    wire [9:0] iter_dig_x = in_iter_tens ? (iter_local_x - 5) : (iter_local_x - 35);
    wire [9:0] iter_dig_y = iter_local_y - 5;
    wire in_iter_digit_area = (in_iter_tens || in_iter_ones) && (iter_dig_y < 22);
    
    wire iter_seg_a = in_iter_digit_area && (iter_dig_y < 3) && (iter_dig_x >= 3) && (iter_dig_x < 20);
    wire iter_seg_b = in_iter_digit_area && (iter_dig_x >= 20) && (iter_dig_y >= 1) && (iter_dig_y < 10);
    wire iter_seg_c = in_iter_digit_area && (iter_dig_x >= 20) && (iter_dig_y >= 12) && (iter_dig_y < 21);
    wire iter_seg_d = in_iter_digit_area && (iter_dig_y >= 19) && (iter_dig_x >= 3) && (iter_dig_x < 20);
    wire iter_seg_e = in_iter_digit_area && (iter_dig_x < 3) && (iter_dig_y >= 12) && (iter_dig_y < 21);
    wire iter_seg_f = in_iter_digit_area && (iter_dig_x < 3) && (iter_dig_y >= 1) && (iter_dig_y < 10);
    wire iter_seg_g = in_iter_digit_area && (iter_dig_y >= 9) && (iter_dig_y < 13) && (iter_dig_x >= 3) && (iter_dig_x < 20);
    
    //7 seg display for iteration count
    wire [3:0] iter_curr_digit = in_iter_tens ? iter_tens : iter_ones;
    reg [6:0] iter_seg_en;
    always @(*) begin
        case (iter_curr_digit)
            4'd0: iter_seg_en = 7'b1111110;
            4'd1: iter_seg_en = 7'b0110000;
            4'd2: iter_seg_en = 7'b1101101;
            4'd3: iter_seg_en = 7'b1111001;
            4'd4: iter_seg_en = 7'b0110011;
            4'd5: iter_seg_en = 7'b1011011;
            4'd6: iter_seg_en = 7'b1011111;
            4'd7: iter_seg_en = 7'b1110000;
            4'd8: iter_seg_en = 7'b1111111;
            4'd9: iter_seg_en = 7'b1111011;
            default: iter_seg_en = 7'b0000000;
        endcase
    end
    
    wire iter_digit_pixel = (iter_seg_en[6] && iter_seg_a) || (iter_seg_en[5] && iter_seg_b) ||
                            (iter_seg_en[4] && iter_seg_c) || (iter_seg_en[3] && iter_seg_d) ||
                            (iter_seg_en[2] && iter_seg_e) || (iter_seg_en[1] && iter_seg_f) ||
                            (iter_seg_en[0] && iter_seg_g);

    wire in_v_label = (px_vga >= VEC_V_X0 + 35) && (px_vga < VEC_V_X0 + 65) &&
                      (py_vga >= VEC_V_Y0 - 18) && (py_vga < VEC_V_Y0 - 5);
    
    wire in_A_label = (px_vga >= MATRIX_X0 + 80) && (px_vga < MATRIX_X0 + 110) &&
                      (py_vga >= MATRIX_Y0 - 18) && (py_vga < MATRIX_Y0 - 5);
    
    wire in_vo_label = (px_vga >= CHART_X0 + 70) && (px_vga < CHART_X0 + 150) &&
                       (py_vga >= CHART_Y0 - 18) && (py_vga < CHART_Y0 - 5);
    wire in_vn_chart_label = (px_vga >= CHART_X0 + half_width + 70) && (px_vga < CHART_X0 + half_width + 150) &&
                             (py_vga >= CHART_Y0 - 18) && (py_vga < CHART_Y0 - 5);
    
    wire in_result_label = (px_vga >= VEC_NEW_X0 + 100) && (px_vga < VEC_NEW_X0 + 200) &&
                           (py_vga >= VEC_NEW_Y0 - 18) && (py_vga < VEC_NEW_Y0 - 5);
    
    wire in_iter_label = (px_vga >= ITER_X0) && (px_vga < ITER_X0 + 50) &&
                         (py_vga >= ITER_Y0 - 18) && (py_vga < ITER_Y0 - 5);
    
    wire in_mode_area = (px_vga >= 550) && (px_vga < 630) && (py_vga >= 5) && (py_vga < 22);

    wire edit_pos_indicator = state_edit && (
        ((px_vga >= 2) && (px_vga < 6) && (py_vga >= 240 + edit_row * 10) && (py_vga < 248 + edit_row * 10)) ||
        ((sw1 == 1'b0) && (px_vga >= 200 + edit_col * 10) && (px_vga < 208 + edit_col * 10) && (py_vga >= 240) && (py_vga < 244))
    );
    
    wire sw0_indicator = (px_vga >= 10) && (px_vga < 60) && (py_vga >= 5) && (py_vga < 20);
    wire sw1_indicator = (px_vga >= 70) && (px_vga < 120) && (py_vga >= 5) && (py_vga < 20);
    
    wire row0_bar = (px_vga >= 3) && (px_vga < 8) && (py_vga >= 60) && (py_vga < 80) && (edit_row == 2'd0);
    wire row1_bar = (px_vga >= 3) && (px_vga < 8) && (py_vga >= 90) && (py_vga < 110) && (edit_row == 2'd1);
    wire row2_bar = (px_vga >= 3) && (px_vga < 8) && (py_vga >= 120) && (py_vga < 140) && (edit_row == 2'd2);
    wire row3_bar = (px_vga >= 3) && (px_vga < 8) && (py_vga >= 150) && (py_vga < 170) && (edit_row == 2'd3);
    wire row_indicator = row0_bar || row1_bar || row2_bar || row3_bar;
    
    wire col0_bar = (px_vga >= 200) && (px_vga < 220) && (py_vga >= 235) && (py_vga < 240) && (edit_col == 2'd0);
    wire col1_bar = (px_vga >= 230) && (px_vga < 250) && (py_vga >= 235) && (py_vga < 240) && (edit_col == 2'd1);
    wire col2_bar = (px_vga >= 260) && (px_vga < 280) && (py_vga >= 235) && (py_vga < 240) && (edit_col == 2'd2);
    wire col3_bar = (px_vga >= 290) && (px_vga < 310) && (py_vga >= 235) && (py_vga < 240) && (edit_col == 2'd3);
    wire col_indicator = col0_bar || col1_bar || col2_bar || col3_bar;
    
    wire vec_v_cursor_fill = vec_v_cursor && in_vec_v_region;
    wire mat_cursor_fill = mat_cursor && in_mat_grid;
    
    reg [24:0] blink_counter;
    wire cursor_blink;
    wire fast_blink;
    
    always @(posedge clk) begin
        blink_counter <= blink_counter + 1'b1;
    end
    
    assign cursor_blink = blink_counter[24];
    assign fast_blink = blink_counter[23];

    wire blink_indicator = (px_vga >= 630) && (px_vga < 638) && (py_vga >= 2) && (py_vga < 10);

    wire test_cursor_pos = (px_vga >= MATRIX_X0 + 5) && (px_vga < MATRIX_X0 + 15) &&
                           (py_vga >= MATRIX_Y0 + 5) && (py_vga < MATRIX_Y0 + 15);
    
    wire edit_row_debug = (py_vga >= 430) && (py_vga < 440) && (px_vga >= 10 + edit_row * 20) && (px_vga < 18 + edit_row * 20);
    wire edit_col_debug = (py_vga >= 450) && (py_vga < 460) && (px_vga >= 10 + edit_col * 20) && (px_vga < 18 + edit_col * 20);
    
    always @(posedge clk) begin
        //main color output
        if (~bright) begin
            rgb <= BLACK;
        end
        else if (blink_indicator && fast_blink) begin
            rgb <= RED;
        end
        else if (test_cursor_pos) begin
            rgb <= BLUE;
        end
        else if (edit_row_debug) begin
            rgb <= CYAN;
        end
        else if (edit_col_debug) begin
            rgb <= MAGENTA;
        end
        else if (sw0_indicator) begin
            rgb <= sw0 ? GREEN : RED;
        end
        else if (sw1_indicator) begin
            rgb <= sw1 ? CYAN : MAGENTA;
        end
        else if (row_indicator) begin
            rgb <= YELLOW;
        end
        else if (col_indicator) begin
            rgb <= YELLOW;
        end
        else if ((vec_v_cursor_fill || mat_cursor_fill) && cell_locked) begin
            rgb <= GREEN;
        end
        else if ((vec_v_cursor_fill || mat_cursor_fill) && cursor_blink) begin
            rgb <= YELLOW;
        end
        else if (vec_v_cursor_border || mat_cursor_border) begin
            rgb <= cell_locked ? GREEN : ORANGE;
        end
        else if (edit_pos_indicator) begin
            rgb <= ORANGE;
        end
        else if (in_vo_bar) begin
            rgb <= CYAN;
        end
        else if (in_vn_bar) begin
            rgb <= GREEN;
        end
        else if (chart_border || chart_divider || chart_baseline) begin
            rgb <= GRAY;
        end
        else if (vec_v_left_bracket || vec_v_right_bracket) begin
            rgb <= WHITE;
        end
        else if (mat_left_bracket || mat_right_bracket) begin
            rgb <= WHITE;
        end
        else if (vnew_left_bracket || vnew_right_bracket) begin
            rgb <= WHITE;
        end
        else if (mat_cell_border) begin
            rgb <= GRAY;
        end
        else if (vnew_border) begin
            rgb <= GRAY;
        end
        else if (vec_digits_on) begin
            rgb <= CYAN;
        end
        else if (mat_digits_on) begin
            rgb <= WHITE;
        end
        else if (vnew_digits_on) begin
            rgb <= GREEN;
        end
        else if (iter_digit_pixel) begin
            rgb <= MAGENTA;
        end
        else if (in_v_label || in_A_label || in_vo_label || in_vn_chart_label || in_result_label || in_iter_label) 
        begin
            rgb <= GRAY;
        end
        else if (in_mode_area) begin
            rgb <= state_edit ? ORANGE : (fsm_done ? GREEN : RED);
        end
        else begin
            rgb <= BLACK;
        end
    end

endmodule
