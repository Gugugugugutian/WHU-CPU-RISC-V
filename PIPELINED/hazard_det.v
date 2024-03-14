module hazard_det(
    input id_ex_memread,
    input [4:0] id_ex_rd, if_id_rs1, if_id_rs2, 
   // input [4:0] 

    output reg stall
);

always @* begin
    if (id_ex_memread) begin
        if ((id_ex_rd != 5'b00000) && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            // stall the pipeline 
            stall = 1'b1;
        end
    end
    else begin
        // not stall the pipeline
        stall = 1'b0;
    end
end

endmodule