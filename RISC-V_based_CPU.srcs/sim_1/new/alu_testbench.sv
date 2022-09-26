`timescale 1ns / 1ps

`define WORD_LEN 32

`define ALU_OP_LEN 5

`define ADD 5'b00000
`define SUB 5'b01000
`define SLL 5'b00001
`define SLT 5'b00010
`define SLTU 5'b00011
`define XOR 5'b00100
`define SRL 5'b00101
`define SRA 5'b01101
`define OR 5'b00110
`define AND 5'b00111
`define BEQ 5'b11000
`define BNE 5'b11001
`define BLT 5'b11100
`define BGE 5'b11101
`define BLTU 5'b11110
`define BGEU 5'b11111

// Max tests num = 999
`define TESTS_NUM 12

module alu_testbench ();

  reg [`WORD_LEN-1:0] A, B, B_sub;
  reg  [          4:0] cmd;
  
  wire                 flag;
  wire [`WORD_LEN-1:0] res;

  my_alu #(`WORD_LEN, `ALU_OP_LEN) dut (
      .A(A),
      .B(B),
      .ALUOp(cmd),

      .Flag  (flag),
      .Result(res)
  );

  reg [`WORD_LEN-1:0] sign_compar_buff;

  initial begin

    $display("\nTesting ADD");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = 1000 - i * (2 + i % 2) * 10;
      B   = i + 100 + i % 2 * 10 + i % 2;
      cmd = `ADD;
      #100;
      if (res == (A + B)) begin
        $display("%3d) PASSED %3d + %3d = %3d", i, A, B, res);
      end else begin
        $display("%3d) FAILED %3d + %3d = %3d", i, A, B, res);
      end
    end

    $display("\nTesting SUB");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = 1000 - i * (2 + i % 2) * 10;
      B   = i + 100 + i % 2 * 10 + i % 2;
      cmd = `SUB;
      #100;
      if (res == (A - B)) begin
        $display("%3d) PASSED %3d - %3d = %3d", i, A, B, res);
      end else begin
        $display("%3d) FAILED %3d - %3d = %3d", i, A, B, res);
      end
    end

    $display("\nTesting SLL");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = i * 2 + 1;
      cmd = `SLL;
      #100;
      if (res == (A << B)) begin
        $display("%3d) PASSED %32b << %3d = %32b", i, A, B, res);
      end else begin
        $display("%3d) FAILED %32b << %3d = %32b", i, A, B, res);
      end
    end

    $display("\nTesting SLT");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = (i % 2) ? i : ((`TESTS_NUM - i) + `TESTS_NUM / 2 * -1);
      B   = (!(i % 2)) ? i : ((`TESTS_NUM - i) + `TESTS_NUM / 2 * -1);
      cmd = `SLT;
      #100;
      sign_compar_buff = A - B;
      if (res == sign_compar_buff[`WORD_LEN-1]) begin
        $display("%3d) PASSED %3d < %3d = %1d", i, $signed(A), $signed(B), res);
      end else begin
        $display("%3d) FAILED %3d < %3d = %1d", i, $signed(A), $signed(B), res);
      end
    end

    $display("\nTesting SLTU");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = (i % 2) ? (i - 1) : (`TESTS_NUM - i);
      cmd = `SLTU;
      #100;
      if (res == (A < B)) begin
        $display("%3d) PASSED %3d < %3d = %1d", i, A, B, res);
      end else begin
        $display("%3d) FAILED %3d < %3d = %1d", i, A, B, res);
      end
    end

    $display("\nTesting XOR");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = `TESTS_NUM - i;
      cmd = `XOR;
      #100;
      if (res == (A ^ B)) begin
        $display("%3d) PASSED %32b XOR %32b = %32b", i, A, B, res);
      end else begin
        $display("%3d) FAILED %32b XOR %32b = %32b", i, A, B, res);
      end
    end

    $display("\nTesting SRL");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = i * 2 + 1;
      cmd = `SRL;
      #100;
      if (res == (A >> B)) begin
        $display("%3d) PASSED %32b >> %3d = %32b", i, A, B, res);
      end else begin
        $display("%3d) FAILED %32b >> %3d = %32b", i, A, B, res);
      end
    end

    $display("\nTesting SRA");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = i * 2 + 1;
      cmd = `SRA;
      #100;
      if (res == ($signed(A) >>> B)) begin
        $display("%3d) PASSED %32b >>> %3d = %32b", i, A, B, res);
      end else begin
        $display("%3d) FAILED %32b - %3d = %32b", i, A, B, res);
      end
    end

    $display("\nTesting OR");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = `TESTS_NUM - i;
      cmd = `OR;
      #100;
      if (res == (A | B)) begin
        $display("%3d) PASSED %32b OR %32b = %32b", i, A, B, res);
      end else begin
        $display("%3d) FAILED %32b OR %32b = %32b", i, A, B, res);
      end
    end

    $display("\nTesting AND");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = `TESTS_NUM - i;
      cmd = `AND;
      #100;
      if (res == (A & B)) begin
        $display("%3d) PASSED %32b AND %32b = %32b", i, A, B, res);
      end else begin
        $display("%3d) FAILED %32b AND %32b = %32b", i, A, B, res);
      end
    end

    $display("\nTesting BEQ");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = i + i % 2;
      cmd = `BEQ;
      #100;
      if (flag == (A == B)) begin
        $display("%3d) PASSED (%3d = %3d) = %1d", i, A, B, flag);
      end else begin
        $display("%3d) FAILED (%3d = %3d) = %1d", i, A, B, flag);
      end
    end

    $display("\nTesting BNE");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = i + i % 2;
      cmd = `BNE;
      #100;
      if (flag == (A != B)) begin
        $display("%3d) PASSED (%3d != %3d) = %1d", i, A, B, flag);
      end else begin
        $display("%3d) FAILED (%3d != %3d) = %1d", i, A, B, flag);
      end
    end

    $display("\nTesting BLT");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = (i % 2) ? i : ((`TESTS_NUM - i) + `TESTS_NUM / 2 * -1);
      B   = (!(i % 2)) ? i : ((`TESTS_NUM - i) + `TESTS_NUM / 2 * -1);
      cmd = `BLT;
      #100;
      if (flag == $signed(A < B)) begin
        $display("%3d) PASSED %3d < %3d = %1d", i, $signed(A), $signed(B), flag);
      end else begin
        $display("%3d) FAILED %3d < %3d = %1d", i, $signed(A), $signed(B), flag);
      end
    end

    $display("\nTesting BGE");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = (i % 2) ? i : ((`TESTS_NUM - i) + `TESTS_NUM / 2 * -1);
      B   = (!(i % 2)) ? i : ((`TESTS_NUM - i) + `TESTS_NUM / 2 * -1);
      cmd = `BGE;
      #100;
      if (flag == $signed(A >= B)) begin
        $display("%3d) PASSED %3d >= %3d = %1d", i, $signed(A), $signed(B), flag);
      end else begin
        $display("%3d) FAILED %3d >= %3d = %1d", i, $signed(A), $signed(B), flag);
      end
    end

    $display("\nTesting BLTU");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = (i % 2) ? (i - 1) : (`TESTS_NUM - i);
      cmd = `BLTU;
      #100;
      if (flag == (A < B)) begin
        $display("%3d) PASSED %3d < %3d = %1d", i, A, B, flag);
      end else begin
        $display("%3d) FAILED %3d < %3d = %1d", i, A, B, flag);
      end
    end

    $display("\nTesting BGEU");
    for (int i = 0; i < `TESTS_NUM; i++) begin
      A   = i;
      B   = (i % 2) ? (i - 1) : (`TESTS_NUM - i);
      cmd = `BGEU;
      #100;
      if (flag == (A >= B)) begin
        $display("%3d) PASSED %3d >= %3d = %3d", i, A, B, flag);
      end else begin
        $display("%3d) FAILED %3d >= %3d = %3d", i, A, B, flag);
      end
    end

    #10;
    $finish;
  end

endmodule
