module RegFile (
  input  clk, 
  input  rst,
  // read enable. In this CPU it doesn't work and always shows 1. 
  // input wire read_en_1,
  // input wire read_en_2,
  input  write_en,
  input  [4:0] read_addr_1,
  input  [4:0] read_addr_2,
  input  [4:0] write_addr,
  input  [31:0] write_data,
  output  reg [31:0] read_data_1,
  output  reg [31:0] read_data_2,

  input [31:0] pc
);

//   wire read_en_1 = 1;
//   wire read_en_2 = 1;
  reg [31:0] RegFile[31:0];
  integer i=0;

  always @(posedge clk, posedge rst)
    if (rst) begin
      for (i=1; i<32; i=i+1)
        RegFile[i] <= 0;
    end

    else  begin
      if (write_en) begin
        RegFile[write_addr] <= write_data;
        if (write_addr != 0) begin
          $display("pc = %h: x%d = %h", pc, write_addr, write_data);
        end end
    end
  
 always @(negedge clk) begin
   if (read_addr_1 !=0) read_data_1 = (read_addr_1 != write_addr)? RegFile[read_addr_1]: write_data; 
   else read_data_1 = 0;
   if (read_addr_2 !=0) read_data_2 = (read_addr_2 != write_addr)? RegFile[read_addr_2]: write_data; 
   else read_data_2 = 0;
   end
//  end
// assign read_data_1 = (read_addr_1 != 0) ? RegFile[read_addr_1]: 0;
// assign read_data_2 = (read_addr_2 != 0) ? RegFile[read_addr_2]: 0;


// // read logic
//   always @(negedge clk) begin
//       if (read_en_1) begin
//         read_data_1 = RegFile[read_addr_1];
//         if (read_addr_1 == write_addr) read_data_1 = write_data;
//       end //read data 1

//       if (read_en_2) begin
//         read_data_2 = RegFile[read_addr_2];
//         if (read_addr_2 == write_addr) read_data_2 = write_data;
//         end
//        //read data 2
//   end

// // write logic
//   always @(posedge clk) begin

//     if (rst) begin
//       for (i=0; i<32; i=i+1) begin
//         RegFile[i] <= 0;
//       end // clear all registers when rst=1
//       read_data_1 <= 0;
//       read_data_2 <= 0;
//     end //clear when rst=1

//     else begin
//       if (write_en) begin
//         // if ((read_addr_1 == write_addr)) begin //when read and write at the same register
//         //     read_data_1 = write_data;
//         // //     // if (write_addr != 0) begin
//         // //     // $display("x%d = %h", write_addr, write_data);
//         // //     // end
//         //     end
//         // if ((read_addr_2 == write_addr)) begin //when read and write at the same register
//         //     read_data_2 = write_data;
//         // //     // if (write_addr != 0) begin
//         // //     // $display("x%d = %h", write_addr, write_data);
//         // //     // end
//         //     end
//         //else 
//         begin
//           RegFile[write_addr] = write_data;
//         end

//         if (write_addr != 0) begin
//             $display("pc = %h: x%d = %h", pc, write_addr, write_data);
//             // write print
//             end
//           RegFile[0] = 0;  //cannot write to no.0 register.
//       end //write data
//       end
//     end


endmodule