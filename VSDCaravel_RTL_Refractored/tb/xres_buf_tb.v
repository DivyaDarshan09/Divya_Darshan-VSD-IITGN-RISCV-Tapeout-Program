`timescale 1ns/1ps

module xres_buf_tb;

    // TB-side driver
    reg  X_drv;

    wire X;      // actual inout wire
    wire A;

    // Drive the inout via continuous assignment
    assign X = X_drv;

    // Instantiate DUT
    xres_buf dut (
        .X(X),
        .A(A)
    );

    initial begin

	  $dumpfile("xres_buf.vcd");
          $dumpvars(0, xres_buf_tb);

        $display("=== xres_buf Testbench Start ===");

        // Initial
        X_drv = 1'b0;
        #10;
        if (A !== 1'b0)
            $error("FAIL: A should be 0 when X is 0");
        else
            $display("PASS: X=0 -> A=0");

        // Drive high
        X_drv = 1'b1;
        #10;
        if (A !== 1'b1)
            $error("FAIL: A should be 1 when X is 1");
        else
            $display("PASS: X=1 -> A=1");

        // Toggle
        repeat (5) begin
            X_drv = ~X_drv;
            #5;
            if (A !== X_drv)
                $error("FAIL: A does not follow X");
        end

        $display("PASS: A correctly follows X");
        $display("=== xres_buf Testbench End ===");
        $finish;
    end

endmodule

