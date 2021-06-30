module debounce(
    input       clk,
    input       ibutton,
    output reg  obutton
);
    parameter WIDTH = 32;
    
    reg [WIDTH-1:0] ctx = 0;
    
    always @(posedge clk)
        ctx[WIDTH-1:0] <= {ctx[WIDTH-2:0], ~ibutton};
    
    always @(posedge clk) begin
        case(ctx)
            32'h00000000: obutton <= 0;
            32'hFFFFFFFF: obutton <= 1;
            default:;
        endcase
    end
endmodule