module top(input wire clk, input wire [27:0] io_in, output wire [27:0] io_out, io_oeb);
wire rst = io_in[0];

wire [15:0] results;

genvar ii;
generate
for (ii = 0; ii < 16; ii = ii + 1'b1) begin
    reg [15:0] counter;
    always @ (posedge clk)
    begin
        if (rst)
            begin
                counter <= ii;
            end
        else 
            begin
                counter <= counter + 10000 * ii;
            end
    end
    assign results[ii] = counter[15];
end
endgenerate

assign io_oeb = 28'b1;
assign io_out = {results, 1'b0};

endmodule