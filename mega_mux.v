module mega_mux(
    input iclk,
    
    input ihs,
    input ivs,
    input ipix_active,
    
    input iant_data_en,
    input [2:0] iant_data,

    input igrid_data_en,
    input [2:0] igrid_data,
    

    input iant_body_data_en,
    input [2:0] iant_body_data,

    output ohs,
    output ovs,
    output [17:0] odata //RGB
);
    reg [2:0] color = 3'b000;
    
    always @(posedge iclk) begin
        if(iant_body_data_en) begin
            color <= iant_body_data;
        end else if(igrid_data_en) begin
            color <= igrid_data;
        end else  begin
            color <= iant_data;
        end
    end

    data_to_color inst_data_to_color(.enable(ipix_active), .icolor8(color), .RGB(odata));
    assign ohs = ihs;
    assign ovs = ivs;
endmodule