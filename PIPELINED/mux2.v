module mux2(
    input sig,
    input [31:0] d0, d1,

    output reg[31:0] do
);

always @* begin
    case (sig) 
        2'b0: do=d0;
        2'b1: do=d1;
        default: do=d0;
    endcase
end
endmodule

module mux4(
    input [1:0] signal,
    input [31:0] d0, d1, d2, d3, 

    output reg [31:0] do 
);

always @* begin
    case (signal) 
        2'b00: do=d0;
        2'b01: do=d1;
        2'b10: do=d2;
        2'b11: do=d3;
        default: do=d0;
    endcase
end
endmodule