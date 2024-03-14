//`include "xgriscv_defines.v"

module imem(input  [31:0]   a,
            output [31:0]  rd);

  reg  [31:0] RAM[1024:0];

  assign rd = RAM[a[10:2]]; // instruction size aligned
endmodule


module dmem(input                     clk, we,
            input  [31:0]        a, wd,
            input  [31:0]   pc,
            input [2:0] type,

            output reg [31:0]   rd
            
            );

  reg  [31:0] RAM[127:0];
  //wire [31:0] data = RAM[a[8:2]];
  wire [1:0] byte_offset = a[1:0];

  always @(posedge clk) begin
    if (we) begin
      //write to memory
        case (type)
        // dm_word 3'b000
        // dm_halfword 3'b001
        // dm_halfword_unsigned 3'b010
        // dm_byte 3'b011
        // dm_byte_unsigned 3'b100
          3'b000: RAM[a[8:2]] <= wd;          	  // sw
          3'b001, 3'b010: // sh
            case (byte_offset[1])
              2'b0: RAM[a[8:2]][15:0] <= wd[15:0];       
              2'b1: RAM[a[8:2]][31:16] <= wd[15:0];      
            endcase
          3'b011, 3'b100:  // sb
            case (byte_offset)
              2'b00:RAM[a[8:2]][7:0] <= wd[7:0];
              2'b01:RAM[a[8:2]][15:8] <= wd[7:0];
              2'b10:RAM[a[8:2]][23:16] <= wd[7:0];
              2'b11:RAM[a[8:2]][31:24] <= wd[7:0];
            endcase
        endcase
        $display("pc = %h: dataaddr = %h, write to memdata = %h", pc, a, wd);
  	  end
    end

  always @(*) begin
    // read from memory
    case (type)
        3'b000: rd = RAM[a[8:2]];          	  // lw
        3'b001: // lh
          case (byte_offset[1])
            0: rd = {{16{RAM[a[8:2]][15]}}, RAM[a[8:2]][15:0]};
            1: rd = {{16{RAM[a[8:2]][31]}}, RAM[a[8:2]][31:16]};
          endcase
        3'b010: // lhu
          case (byte_offset[1])
            0: rd = {16'b0, RAM[a[8:2]][15:0]};
            1: rd = {16'b0, RAM[a[8:2]][31:16]};
          endcase
        3'b011: // lb
          case (byte_offset)
            0: rd = {{24{RAM[a[8:2]][7]}}, RAM[a[8:2]][7:0]};
            1: rd = {{24{RAM[a[8:2]][15]}}, RAM[a[8:2]][15:8]};
            2: rd = {{24{RAM[a[8:2]][23]}}, RAM[a[8:2]][23:16]};
            3: rd = {{24{RAM[a[8:2]][31]}}, RAM[a[8:2]][31:24]};
          endcase
        3'b100: // lbu
          case (byte_offset)
            0: rd = {24'b0, RAM[a[8:2]][7:0]};
            1: rd = {24'b0, RAM[a[8:2]][15:8]};
            2: rd = {24'b0, RAM[a[8:2]][23:16]};
            3: rd = {24'b0, RAM[a[8:2]][31:24]};
          endcase
    endcase
  end

endmodule