module axi_stream_insert_header #(
    parameter DATA_WD = 32,                  // Data width
    parameter DATA_BYTE_WD = DATA_WD / 8,    // Data byte width
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) 
(
    input clk,
    input rst_n,
    
    // AXI Stream input original data
    input valid_in,
    input [DATA_WD-1:0] data_in,
    input [DATA_BYTE_WD-1:0] keep_in,
    input last_in,
    output ready_in,
    
    // AXI Stream output with header inserted
    output valid_out,
    output [DATA_WD-1:0] data_out,
    output [DATA_BYTE_WD-1:0] keep_out,
    output last_out,
    input ready_out,
    
    // Header to be inserted to AXI Stream input
    input valid_insert,
    input [DATA_WD-1:0] data_insert,
    input [DATA_BYTE_WD-1:0] keep_insert,
    input [BYTE_CNT_WD-1:0] byte_insert_cnt,
    output ready_insert
);

    // Internal signals
    reg valid_out_reg, ready_in_reg, ready_insert_reg, last_out_reg;
    reg [DATA_WD-1:0] data_out_reg;
    reg [DATA_BYTE_WD-1:0] keep_out_reg;

    // FIFO-like behavior with state tracking
    reg header_in_progress;

    // Signal assignments
    assign valid_out = valid_out_reg;
    assign data_out = data_out_reg;
    assign keep_out = keep_out_reg;
    assign last_out = last_out_reg;
    assign ready_in = ready_in_reg;
    assign ready_insert = ready_insert_reg;

    // Logic to manage header insertion and AXI handshake
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out_reg    <= 0;
            ready_in_reg     <= 0;
            ready_insert_reg <= 0;
            last_out_reg     <= 0;
            header_in_progress <= 0;
        end else begin
            if (valid_insert && ready_insert) begin
                // Header insertion
                valid_out_reg   <= 1;
                data_out_reg    <= data_insert;
                keep_out_reg    <= keep_insert;
                last_out_reg    <= 0;  // Continue inserting header
            end else if (valid_in && ready_in) begin
                // Data transfer (after header insertion)
                valid_out_reg   <= 1;
                data_out_reg    <= data_in;
                keep_out_reg    <= keep_in;
                last_out_reg    <= last_in; // Forward the last signal
            end else begin
                valid_out_reg   <= 0;  // No data to forward
            end
        end
    end

    // Logic to handle ready signals
    always @(*) begin
        ready_insert_reg = (valid_insert && !header_in_progress);
        ready_in_reg = (valid_in && !header_in_progress);
    end

endmodule
