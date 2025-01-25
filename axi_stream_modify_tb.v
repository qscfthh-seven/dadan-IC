`timescale 1 ns / 1 ps
module axi_stream_insert_header_tb();

    reg clk;
    reg rst_n;
    
    // Input signals
    reg valid_in;
    reg [31:0] data_in;
    reg [3:0] keep_in;
    reg last_in;
    wire ready_in;
    
    // Header insertion signals
    reg valid_insert;
    reg [31:0] data_insert;
    reg [3:0] keep_insert;
    reg [2:0] byte_insert_cnt;
    wire ready_insert;
    
    // Output signals
    wire valid_out;
    wire [31:0] data_out;
    wire [3:0] keep_out;
    wire last_out;
    reg ready_out;

    // Instantiate the module
    axi_stream_insert_header axi (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .data_in(data_in),
        .keep_in(keep_in),
        .last_in(last_in),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .data_out(data_out),
        .keep_out(keep_out),
        .last_out(last_out),
        .ready_out(ready_out),
        .valid_insert(valid_insert),
        .data_insert(data_insert),
        .keep_insert(keep_insert),
        .byte_insert_cnt(byte_insert_cnt),
        .ready_insert(ready_insert)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Random stimulus generation
    initial begin
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        data_in = 32'b0;
        keep_in = 4'b1111;
        last_in = 0;
        valid_insert = 0;
        data_insert = 32'b0;
        keep_insert = 4'b1111;
        byte_insert_cnt = 3'b0;
        ready_out = 0;

        // Apply reset
        #10;
        rst_n = 1;

        // Test case 1: Simple data transfer with valid_in
        #10;
        valid_in = 1;
        data_in = 32'hA5A5A5A5;
        keep_in = 4'b1111;
        last_in = 0;

        // Test case 2: Insert header and then data
        #10;
        valid_insert = 1;
        data_insert = 32'h12345678;
        keep_insert = 4'b1111;
        byte_insert_cnt = 3'b100;

        // Simulate end of transmission and reset
        #20;
        valid_insert = 0;
        valid_in = 1;
        last_in = 1;
        
        #20;
        rst_n = 0;
        #10;
        rst_n = 1;
        valid_in = 0;
        valid_insert = 0;

	#10;
        valid_in = $random % 2; // Random valid_in (0 or 1)
        data_in = $random; // Random data_in
        keep_in = $random; // Random keep_in (4-bit)
        last_in = $random % 2; // Random last_in (0 or 1)

        // Test case 2: Random header insertion and data
        #10;
        valid_insert = $random % 2; // Random valid_insert (0 or 1)
        data_insert = $random; // Random data_insert
        keep_insert = $random; // Random keep_insert (4-bit)
        byte_insert_cnt = $random % 8; // Random byte_insert_cnt (0-7)

        // Simulate random transmission and reset
        #20;
        valid_insert = 0;
        valid_in = $random % 2; // Random valid_in (0 or 1)
        last_in = $random % 2; // Random last_in (0 or 1)
        
        #20;
        rst_n = 0;
        #10;
        rst_n = 1;
        valid_in = $random % 2; // Random valid_in (0 or 1)
        valid_insert = $random % 2; // Random valid_insert (0 or 1)

        // Additional random checks can be added if needed
        #10;
        $finish;
    end
    
endmodule
