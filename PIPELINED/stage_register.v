// stage register of pipelined CPU
`define str_len 32
// store at most 7 datas in one register
module StageR (
    input clk, rst, flush,
    input [`str_len-1:0] in1, in2, in3, in4, in5, in6, in7,

    output reg [`str_len-1:0] out1, out2, out3, out4, out5, out6, out7
);

// update register logic
always @(posedge clk or posedge rst) 
begin
        if (rst | flush) begin
            out1 = 0;
            out2 = 0;
            out3 = 0;
            out4 = 0;
            out5 = 0;
            out6 = 0;
            out7 = 0;
        end
        
        else begin
            out1 = in1;
            out2 = in2;
            out3 = in3;
            out4 = in4;
            out5 = in5;
            out6 = in6;
            out7 = in7;
        end
end
       
endmodule 