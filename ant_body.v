`define bit_size(x, y)  ($clog2((x+y)/2)-1)
`define bit_cells       `bit_size(C_NUM_OF_CELLS_X, C_NUM_OF_CELLS_Y)
`define bit_rxy         `bit_size(C_CELL_WIDTH, C_CELL_HEIGHT)
`define bit_csize        (C_CELL_WIDTH * C_CELL_HEIGHT - 1)

module ant_body #(
    parameter C_CELL_WIDTH      = 5,
    parameter C_CELL_HEIGHT     = 5,
    parameter C_NUM_OF_CELLS_X  = 5,
    parameter C_NUM_OF_CELLS_Y  = 5
)(
    input                   iclk,
    input [`bit_cells:0]    line,
    input [`bit_cells:0]    column,

    input [`bit_rxy:0]      irx,
    input [`bit_rxy:0]      iry,
    
    input [`bit_cells:0]    cur_pos_x,
    input [`bit_cells:0]    cur_pos_y,
    input [1:0]             direction,
    
    output reg              odata_en,
    output [2:0]            odata
);
    localparam [0:`bit_csize] ant_up    = {
        8'bzzzzzzzz,
        8'bz0000000,
        8'bz0001000,
        8'bz0011100,
        8'bz0111110,
        8'bz0001000,
        8'bz0001000,
        8'bz0001000,
        8'bz0000000,
        8'bz0000000,
    };
    localparam [0:`bit_csize] ant_down  = {
        8'bzzzzzzzz,
        8'bz0000000,
        8'bz0000000,
        8'bz0001000,
        8'bz0001000,
        8'bz0001000,
        8'bz0111110,
        8'bz0011100,
        8'bz0001000,
        8'bz0000000,
    };
    localparam [0:`bit_csize] ant_laft  = {
        8'bzzzzzzzz,
        8'bz0000000,
        8'bz0000000,
        8'bz0010000,
        8'bz0110000,
        8'bz1111100,
        8'bz0110000,
        8'bz0010000,
        8'bz0000000,
        8'bz0000000,
    };
    localparam [0:`bit_csize] ant_right = {
        8'bzzzzzzzz,
        8'bz0000000,
        8'bz0000000,
        8'bz0000100,
        8'bz0000110,
        8'bz0011111,
        8'bz0000110,
        8'bz0000100,
        8'bz0000000,
        8'bz0000000,
    };
    assign odata = 3'b100;
    
    always @(iclk) begin
        odata_en <= 0;
        if((cur_pos_x == column) && (cur_pos_y == line)) begin
            case(direction)
                0: odata_en <= ant_up[iry*C_CELL_WIDTH + irx];
                1: odata_en <= ant_down[iry*C_CELL_WIDTH + irx];
                2: odata_en <= ant_laft[iry*C_CELL_WIDTH + irx];
                3: odata_en <= ant_right[iry*C_CELL_WIDTH + irx];
            endcase
        end
    end
endmodule