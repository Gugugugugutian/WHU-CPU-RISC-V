//`include "xgriscv_defines.v"

module imem(input  [31:0]   a,
            output [31:0]  rd);

  reg  [31:0] RAM[127:0];

  assign rd = RAM[a[8:2]]; // instruction size aligned
endmodule


module dmem(input                     clk, we,
            input  [31:0]        a, wd,
            input  [31:0]   pc,
            output [31:0]        rd);

  reg  [31:0] RAM[127:0];

  always @(negedge clk) begin
    if (we) begin
        RAM[a[8:2]] <= wd;          	  // sw

        $display("pc = %h: dataaddr = %h, memdata = %h", pc, {a[31:2],2'b00}, wd);
  	  end
    end
      
  assign rd = RAM[a[8:2]]; // word aligned (read word)

endmodule