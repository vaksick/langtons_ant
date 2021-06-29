`define bit_size(x, y)  ($clog2((x+y)/2)-1)
`define bit_cells       `bit_size(C_NUM_OF_CELLS_X, C_NUM_OF_CELLS_Y)
`define bit_rxy         `bit_size(C_CELL_WIDTH, C_CELL_HEIGHT)

module  logic_fsm #(
    parameter C_NUM_OF_CELLS_X  = 5,
    parameter C_NUM_OF_CELLS_Y  = 5
)(
    input                   iclk,

    input                   istep,
    input [`bit_cells:0]    line,
    input [`bit_cells:0]    column,
    input                   istart,
    output reg [15:0]       oaddr_wr,
    output reg              owr_en,
    output reg [0:0]        owr_data,


    output reg [15:0]       oaddr_rd,
    input      [0:0]        ird_data,

    output reg [`bit_cells:0]   cur_pos_x,
    output reg [`bit_cells:0]   cur_pos_y,
    output [1:0]                odirection
);

    typedef enum bit[1:0] {up, down, left, right} direction_t;
    typedef enum bit[0:0] {white, black} color_t;

    enum bit[3:0] {s0, s1, s2, s3, s4, s5, s6, s7, s8, s9} state;
    
    reg [`bit_cells:0] next_pos_x;
    reg [`bit_cells:0] next_pos_y;
    direction_t direction, rotation;
    color_t     cell_color;
    
    assign odirection = direction;

    always @(posedge iclk) begin
        owr_en <= 0;
        case (state)
            s0: begin
                    cur_pos_x   <= C_NUM_OF_CELLS_X / 2;
                    cur_pos_y   <= C_NUM_OF_CELLS_Y / 2;
                    direction   <= left;
                    rotation    <= right;
                    cell_color  <= white;
                    state       <= s1; // wait
                end
            s1: if(istart == 1)
                    state       <= s2; // start
            s2: if(istep == 1)
                    state       <= s3;
                else
                    oaddr_rd    <= line * C_NUM_OF_CELLS_X + column;
            s3: begin
                    oaddr_rd    <= cur_pos_y * C_NUM_OF_CELLS_X + cur_pos_x;
                    state       <= s4;
                end
            s4: begin
                    if(ird_data == 1) begin
                        cell_color  <= black;
                        rotation    <= left;
                    end else begin
                        cell_color  <= white;
                        rotation    <= right;
                    end
                    state <= s5;
                end
            s5: begin
                    if(rotation == right) begin
                        case (direction)
                            up: begin
                                next_pos_x  <= cur_pos_x + 1;
                                next_pos_y  <= cur_pos_y;
                                direction   <= right;
                            end
                            down: begin
                                next_pos_x  <= cur_pos_x - 1;
                                next_pos_y  <= cur_pos_y;
                                direction   <= left;
                            end
                            left: begin
                                next_pos_x  <= cur_pos_x;
                                next_pos_y  <= cur_pos_y - 1;
                                direction   <= up;
                            end
                            right: begin
                                next_pos_x  <= cur_pos_x;
                                next_pos_y  <= cur_pos_y + 1;
                                direction   <= down;
                            end
                        endcase
                    end
                    if(rotation == left) begin
                        case (direction)
                            up: begin
                                next_pos_x  <= cur_pos_x - 1;
                                next_pos_y  <= cur_pos_y;
                                direction   <= left;
                            end
                            down: begin
                                next_pos_x  <= cur_pos_x + 1;
                                next_pos_y  <= cur_pos_y;
                                direction   <= right;
                            end
                            left: begin
                                next_pos_x  <= cur_pos_x;
                                next_pos_y  <= cur_pos_y + 1;
                                direction   <= down;
                            end
                            right: begin
                                next_pos_x  <= cur_pos_x;
                                next_pos_y  <= cur_pos_y - 1;
                                direction   <= up;
                            end
                        endcase
                    end
                    if(cell_color == white) begin
                        cell_color  <= black;
                        owr_data    <= 1;
                    end else begin 
                        cell_color  <= white;
                        owr_data    <= 0;
                    end
                    state <= s6;
                end
            s6: begin
                    oaddr_wr    <= cur_pos_y * C_NUM_OF_CELLS_X + cur_pos_x;
                    owr_en      <= 1;
                    state       <= s7;
                end
            s7: begin
                    cur_pos_x   <= next_pos_x;
                    cur_pos_y   <= next_pos_y;
                    state       <= s8;
                end
            s8: if(istep == 0)
                    state   <= s2;
            default:
                state       <= s0;
        endcase
    end
endmodule