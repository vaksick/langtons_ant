module field#(
    parameter WIDTH = 640*480
)(
    input           iclk,
    input  [15:0]   iaddr_wr,
    input           iwr_en,
    input  [0:0]    iwr_data,

    input  [15:0]   iaddr_rd,
    output [0:0]    ord_data
);
    reg [0:0]   ram[1:WIDTH];

    always @(posedge iclk) begin
        if(iwr_en == 1) begin
            ram[iaddr_wr] <= iwr_data;
        end
    end
    assign ord_data = ram[iaddr_rd];
endmodule