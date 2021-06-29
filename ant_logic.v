`define bit_size(x, y)  ($clog2((x+y)/2)-1)
`define bit_cells       `bit_size(C_NUM_OF_CELLS_X, C_NUM_OF_CELLS_Y)
`define bit_rxy         `bit_size(C_CELL_WIDTH, C_CELL_HEIGHT)


module ant_logic #(
    parameter C_NUM_OF_CELLS_X  = 5,
    parameter C_NUM_OF_CELLS_Y  = 5
)(
    input                   iclk,
    input                   istep,
    input [`bit_cells:0]    line,
    input [`bit_cells:0]    column,
    input                   istart,

    output [2:0]            odata,

    output [`bit_cells:0]   cur_pos_x,
    output [`bit_cells:0]   cur_pos_y,
    output [1:0]            odirection
);
    wire [15:0] logic_fsm_oaddr_wr;
    wire        logic_fsm_owr_en;
    wire [0:0]  logic_fsm_owr_data;

    wire [15:0] logic_fsm_oaddr_rd;
    wire [0:0]  logic_fsm_ird_data;
    wire        logic_fsm_ird_data_valide;

    wire [0:0]  field_ord_data;

    logic_fsm #(
        .C_NUM_OF_CELLS_X(C_NUM_OF_CELLS_X),
        .C_NUM_OF_CELLS_Y(C_NUM_OF_CELLS_Y)
    ) inst_logic_fsm(
        .iclk(iclk),
        .istep(istep),
        .line(line),
        .column(column),
        .istart(istart),
        .oaddr_wr(logic_fsm_oaddr_wr),
        .owr_en(logic_fsm_owr_en),
        .owr_data(logic_fsm_owr_data),
        .oaddr_rd(logic_fsm_oaddr_rd),
        .ird_data(field_ord_data),
        .cur_pos_x(cur_pos_x),
        .cur_pos_y(cur_pos_y),
        .odirection(odirection)
    );

    field #(
        .WIDTH(C_NUM_OF_CELLS_X * C_NUM_OF_CELLS_Y)
    ) inst_field(
            .iclk(iclk),
            .iaddr_wr(logic_fsm_oaddr_wr),
            .iwr_en(logic_fsm_owr_en),
            .iwr_data(logic_fsm_owr_data),
            .iaddr_rd(logic_fsm_oaddr_rd),
            .ord_data(field_ord_data)
    );

    assign odata = {3{field_ord_data}}; 
endmodule