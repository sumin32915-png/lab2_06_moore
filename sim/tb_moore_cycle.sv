`timescale 1ns/1ps

module tb_moore_cycle;

reg clk = 0, rst = 1;
integer checks = 0;

always #5 clk = ~clk;

task step; begin @(posedge clk); #1; end endtask

task check(input condition, input [8*100-1:0] description);
begin
    checks = checks + 1;
    if (condition !== 1'b1) begin
        $display("LAB2_FAIL %0s time=%0t", description, $time);
        $fatal(1, "check failed");
    end
end
endtask

task finish;
begin
    $display("LAB2_PASS moore_cycle checks=%0d", checks);
    $finish;
end
endtask

initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb_moore_cycle); end
initial begin #100000; $fatal(1, "watchdog timeout"); end

reg enable = 0, advance = 0;
wire [1:0] value;
integer round;

moore_cycle dut (clk, rst, enable, advance, value);

initial begin
    step; check(value === 2'b00, "reset"); rst = 0; enable = 1;
    advance = 1; #1; check(value === 2'b00, "input alone cannot change output");

    for (round = 0; round < 4; round = round + 1) begin
        step; check(value === 2'b01, "S0 to S1");
        advance = 0; step; check(value === 2'b01, "advance zero holds");
        advance = 1; enable = 0; step; check(value === 2'b01, "disabled holds");
        enable = 1; step; check(value === 2'b10, "S1 to S2");
        step; check(value === 2'b00, "S2 to S0");
    end

    step; rst = 1; step; check(value === 2'b00, "reset from nonzero"); finish;
end

endmodule