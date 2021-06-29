module grid #(
    parameter C_CELL_WIDTH  = 5,
    parameter C_CELL_HEIGHT = 5
)(
    input [4:0] irx,
    input [4:0] iry,
    output odata_en,
    output [2:0] odata
);
    assign odata = 3'b001;
    assign odata_en = (irx == 0) || (iry == 0);
endmodule