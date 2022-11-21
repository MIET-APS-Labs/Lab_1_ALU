module miriscv_lsu (
    input clk_i,  // sync

    // core protocol
    input [`WORD_LEN-1:0] lsu_addr_i,  // BYTE adress works with
    input lsu_we_i,  // 1 - for STORE
    input [$clog2(`LDST_SIZE_TYPES_NUM)-1:0] lsu_size_i,  // handling data size
    input [`WORD_LEN-1:0] lsu_data_i,  // data to STORE in RAM
    input lsu_req_i,  // 1 - for request RAM
    output logic lsu_stall_req_o,  // using as !enable pc
    output logic [`WORD_LEN-1:0] lsu_data_o,  // data LOAD from RAM

    // memory protocol
    input [`WORD_LEN-1:0] data_rdata_i,  // LOADED data from RAM
    output logic data_req_o,  // 1 - request to RAM
    output data_we_o,  // 1 - request for STORE
    output logic [(`WORD_LEN / `BYTE_WIDTH) - 1:0] data_be_o,  // choose bytes from RAM to LAOD
    output [`WORD_LEN-1:0] data_addr_o,  // address of request
    output logic [`WORD_LEN-1:0] data_wdata_o  // data to LOAD
);

  assign data_addr_o = lsu_addr_i;
  assign data_we_o   = (lsu_we_i & data_req_o);
  assign data_req_o  = lsu_stall_req_o;

  parameter ADDR_SHIFT_LEN = $clog2(`WORD_LEN / `BYTE_WIDTH);
  logic [ADDR_SHIFT_LEN-1:0] byte_offset;
  assign byte_offset = lsu_addr_i[0+:ADDR_SHIFT_LEN];

  logic illegal_offset_size;

  always_comb begin
    illegal_offset_size <= 1'b0;
    case (byte_offset)
      2'b00: begin
        if ((lsu_size_i == `LDST_B) || (lsu_size_i == `LDST_BU)) begin
          data_be_o <= 4'b1;
        end else if ((lsu_size_i == `LDST_H) || (lsu_size_i == `LDST_HU)) begin
          data_be_o <= 4'b11;
        end else if (lsu_size_i == `LDST_W) begin
          data_be_o <= 4'b1111;
        end
      end
      2'b01: begin
        if ((lsu_size_i == `LDST_B) || (lsu_size_i == `LDST_BU)) begin
          data_be_o <= 4'b10;
        end else if ((lsu_size_i == `LDST_H) || (lsu_size_i == `LDST_HU)) begin
          data_be_o <= 4'b110;
        end else if (lsu_size_i == `LDST_W) begin
          illegal_offset_size <= 1'b1;
        end
      end
      2'b10: begin
        if ((lsu_size_i == `LDST_B) || (lsu_size_i == `LDST_BU)) begin
          data_be_o <= 4'b100;
        end else if ((lsu_size_i == `LDST_H) || (lsu_size_i == `LDST_HU)) begin
          data_be_o <= 4'b1100;
        end else if (lsu_size_i == `LDST_W) begin
          illegal_offset_size <= 1'b1;
        end
      end
      2'b11: begin
        if ((lsu_size_i == `LDST_B) || (lsu_size_i == `LDST_BU)) begin
          data_be_o <= 4'b1000;
        end else begin
          illegal_offset_size <= 1'b1;
        end
      end
      default: begin
        illegal_offset_size <= 1'b1;
      end
    endcase
  end

  logic toggle_stall;
  always_ff @(posedge clk_i) begin
    if (lsu_req_i) begin
      toggle_stall <= ~toggle_stall;
    end else begin
      toggle_stall <= 1'b0;
    end
  end
  assign lsu_stall_req_o = lsu_req_i ^ toggle_stall;

  always_comb begin
    if (lsu_req_i) begin

      if (lsu_we_i) begin  // STORE
        if (lsu_stall_req_o) begin
          data_wdata_o <= (lsu_data_i << (byte_offset * `BYTE_WIDTH));
        end else begin
          data_wdata_o <= {`WORD_LEN{1'b0}};
        end

      end else begin  // LOAD
        if (!lsu_stall_req_o) begin
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
        end
      end
    end
  end
endmodule
