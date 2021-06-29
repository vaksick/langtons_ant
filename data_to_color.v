module data_to_color(
    input               enable,
    input [2:0]         icolor8,
    output reg [17:0]   RGB
);
//  assign RGB = enable ? {{6{icolor8[0]}},{6{icolor8[1]}},{6{icolor8[2]}}} : 0;
    always @(icolor8) begin
        RGB <= 18'd0;
        if(enable) begin
            case (icolor8)
                3'b000: RGB <= 18'b111111_111111_111111; //cell
                3'b001: RGB <= 18'b100000_100000_100000; //grid
                3'b100: RGB <= 18'b111111_000000_000000; //body
                
                3'b111:  RGB <= 18'b000000_000000_000000;
                default: RGB <= 18'b000000_000000_000000;
            endcase
        end
    end
endmodule