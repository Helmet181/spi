`timescale 1ns / 1ps

module simmm;

    reg        clk   = 0;
    reg        rst_n = 0;
    always #10 clk = ~clk;            // 50 MHz

    reg        spi_start = 0;
    reg  [7:0] datain    = 8'h0;

    wire       cs, sck, mosi, spi_done;

    // ---------------- DUT ----------------
    spi_lite_slave dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .spi_start(spi_start),
        .datain   (datain),
        .cs       (cs),
        .sck      (sck),
        .mosi     (mosi),
        .spi_done (spi_done)
    );

    initial begin
        rst_n = 0;
        #100;
        rst_n = 1;
        datain    <= 8'h5C;
        spi_start <= 1'b1;
        @(posedge clk);
        spi_start <= 1'b0;
        wait (spi_done);
        datain <= 8'h0;
        $finish;
    end

endmodule
