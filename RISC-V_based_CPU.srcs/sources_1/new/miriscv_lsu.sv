module miriscv_lsu (
    input clk_i,  // sync

    // core protocol
    input [`WORD_LEN-1:0] lsu_addr_i,  // adress works with
    input lsu_we_i,  // 1 - for WRITE
    input [$clog(LDST_SIZE_TYPES_NUM)-1:0] lsu_size_i,  // handling data size
    input [`WORD_LEN-1:0] lsu_data_i,  // data to WRITE in RAM
    input lsu_req_i,  // 1 - for request RAM
    output lsu_stall_req_o,  // using as !enable pc
    output [`WORD_LEN-1:0] lsu_data_o,  // data read from RAM

    // memory protocol
    input [`WORD_LEN-1:0] data_rdata_i,  // LOADED data from RAM
    output data_req_o,  // 1 - request to RAM
    output data_we_o,  // 1 - request for WRITE
    output [(`WORD_LEN / `BYTE_WIDTH) - 1:0] data_be_o,  // choose bytes from RAM to WRITE
    output [`WORD_LEN-1:0] data_addr_o,  // address of request
    output [`WORD_LEN-1:0] data_wdata_o  // data to WRITE
);

  parameter ADDR_SHIFT_LEN = $clog2(`WORD_LEN / `BYTE_WIDTH);
  assign data_addr_o = (lsu_addr_i >> ADDR_SHIFT_LEN);  // RAM is WORD addressable and lsu_addr_i is BYTE addressable
  logic byte_offset;
  assign byte_offset = (lsu_addr_i % SHIFT_LEN);


  assign data_we_o   = lsu_we_i;

  always_ff @(posedge clk_i) begin
    if (lsu_req_i) begin
      if (lsu_we_i) begin  // WRITE
        if (lsu_stall_req_o) begin
          data_wdata_o <= lsu_data_i;

          lsu_stall_req_o <= 1'b0;
          data_req_o <= 1'b0;
        end else begin

          lsu_stall_req_o <= 1'b1;
          data_req_o <= 1'b1;
        end

      end else begin  // LOAD

        if (lsu_stall_req_o) begin

          case (lsu_size_i)  // read data from RAM
            `LDST_B: begin
              lsu_data_o = {
                {(`WORD_LEN - `BYTE_WIDTH) {data_rdata_i[(byte_offset*`BYTE_WIDTH)+`BYTE_WIDTH-1]}},
                data_rdata_i[(byte_offset*`BYTE_WIDTH)+:`BYTE_WIDTH]
              };
            end

            `LDST_H: begin
              lsu_data_o = {
                {(`WORD_LEN / 2) {data_rdata_i[(byte_offset*`BYTE_WIDTH)+`WORD_LEN/2-1]}},
                data_rdata_i[(byte_offset*`BYTE_WIDTH)+:`WORD_LEN/2]
              };
            end

            `LDST_W: begin
              lsu_data_o = data_rdata_i;
            end

            `LDST_BU: begin
              lsu_data_o = {
                {(`WORD_LEN - `BYTE_WIDTH) {1'b0}},
                data_rdata_i[(byte_offset*`BYTE_WIDTH)+:`BYTE_WIDTH]
              };
            end

            `LDST_HU: begin
              lsu_data_o = {
                {(`WORD_LEN / 2) {1'b0}}, data_rdata_i[(byte_offset*`BYTE_WIDTH)+:`WORD_LEN/2]
              };
            end

            default: begin
              lsu_data_o = {`WORD_LEN{1'b0}};
            end
          endcase

          data_req_o <= 0'b1;
          lsu_stall_req_o <= 1'b0;

        end else begin
          data_req_o <= 1'b1;
          lsu_stall_req_o <= 1'b1;  // stop counting PC for load data from RAM
        end

      end
    end
  end

endmodule
