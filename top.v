`define bit_size(x, y)  ($clog2((x+y)/2)-1)
`define bit_cells       `bit_size(C_NUM_OF_CELLS_X, C_NUM_OF_CELLS_Y)
`define bit_rxy         `bit_size(C_CELL_WIDTH, C_CELL_HEIGHT)

module top(
    input isys_clk,

    input key_start,

    output ovga_hs,
    output ovga_vs,

    output [5:0] R,
    output [5:0] G,
    output [5:0] B
);

    wire clk;
    wire vga_hs;
    wire vga_vs;
    wire mega_mux_hs;
    wire mega_mux_vs;
    wire vga_active;
    wire [9:0] vga_x;
    wire [9:0] vga_y;

    wire start;

    wire [`bit_cells:0] cell_line;
    wire [`bit_cells:0] cell_column;
    wire [`bit_rxy:0]   cell_rx;
    wire [`bit_rxy:0]   cell_ry;
    
    wire [2:0] ant_logic_odata;
    
    wire [7:0] ant_logic_cur_pos_x;
    wire [7:0] ant_logic_cur_pos_y;
    wire [1:0] ant_logic_direction;
    
    wire grid_odata_en;
    wire [2:0] grid_odata;
    
    wire ant_odata_en;
    wire [2:0] ant_odata;

    clk_wiz inst_clk_wiz(.isys_clk(isys_clk), .oclk(clk));

    debounce inst_debounce_start(.clk(clk), .ibutton(key_start), .obutton(start));
    
    localparam C_CELL_WIDTH     = 8;
    localparam C_CELL_HEIGHT    = 10;
    localparam C_SCREEN_SIZE_H  = 1024;
    localparam C_SCREEN_SIZE_V  = 768;
    localparam C_NUM_OF_CELLS_X = C_SCREEN_SIZE_H / (C_CELL_WIDTH);
    localparam C_NUM_OF_CELLS_Y = C_SCREEN_SIZE_V / (C_CELL_HEIGHT);

    vga_sync #(
        .WIDTH      (C_SCREEN_SIZE_H),
        .HEIGHT     (C_SCREEN_SIZE_V),
        .H_FRONT    (   24),
        .H_SYNC     (  136),
        .H_BACK     (  160),
        .V_FRONT    (    3),
        .V_SYNC     (    6),
        .V_BACK     (   29)
    ) inst_vga(
        .clk        (clk),
        .hsync      (vga_hs),
        .vsync      (vga_vs), 
        .xpos       (vga_x), 
        .ypos       (vga_y), 
        .opix_en    (vga_active)
    );
    
    cell_math #(
        .C_CELL_WIDTH        (C_CELL_WIDTH),
        .C_CELL_HEIGHT       (C_CELL_HEIGHT),
        .C_NUM_OF_CELLS_X    (C_NUM_OF_CELLS_X),
        .C_NUM_OF_CELLS_Y    (C_NUM_OF_CELLS_Y)
    ) inst_cell_math(
        .ivga_x     (vga_x),
        .ivga_y     (vga_y),
        .line       (cell_line),
        .column     (cell_column),
        .rx         (cell_rx),
        .ry         (cell_ry)    
    );
    
    ant_logic #(
        .C_NUM_OF_CELLS_X(C_NUM_OF_CELLS_X),
        .C_NUM_OF_CELLS_Y(C_NUM_OF_CELLS_Y)
    ) inst_ant_logic(
        .iclk       (clk),
        .istep      (vga_vs == 0),
        .line       (cell_line),
        .column     (cell_column),
        .istart     (start),

        .odata      (ant_logic_odata),
        
        .cur_pos_x  (ant_logic_cur_pos_x),
        .cur_pos_y  (ant_logic_cur_pos_y),
        .odirection (ant_logic_direction)
    );
    
    grid #(
        .C_CELL_WIDTH(C_CELL_WIDTH),
        .C_CELL_HEIGHT(C_CELL_HEIGHT)
    ) inst_grid(
        .irx        (cell_rx),
        .iry        (cell_ry),
        .odata_en   (grid_odata_en),
        .odata      (grid_odata)
    );
    
    ant_body #(
        .C_CELL_WIDTH       (C_CELL_WIDTH),
        .C_CELL_HEIGHT      (C_CELL_HEIGHT),
        .C_NUM_OF_CELLS_X   (C_NUM_OF_CELLS_X),
        .C_NUM_OF_CELLS_Y   (C_NUM_OF_CELLS_Y)
    ) inst_ant_body(
        .iclk       (clk),
        .line       (cell_line),
        .column     (cell_column),
        .irx        (cell_rx),
        .iry        (cell_ry),
        
        .cur_pos_x  (ant_logic_cur_pos_x),
        .cur_pos_y  (ant_logic_cur_pos_y),
        .direction  (ant_logic_direction),
        .odata_en   (ant_odata_en),
        .odata      (ant_odata)
    );
    
    mega_mux inst_mega_mux(
        .iclk           (clk),
        .ihs            (vga_hs), 
        .ivs            (vga_vs),
        .ipix_active    (vga_active),
        .iant_data_en   (1),
        .iant_data      (ant_logic_odata),
        
 
        .igrid_data_en  (grid_odata_en),
        .igrid_data     (grid_odata),
        
        .iant_body_data_en(ant_odata_en),
        .iant_body_data (ant_odata),

        .ohs            (mega_mux_hs),
        .ovs            (mega_mux_vs), 
        .odata          ({R,G,B})
    );
    
    
    assign ovga_hs  = mega_mux_hs;
    assign ovga_vs  = mega_mux_vs;
endmodule