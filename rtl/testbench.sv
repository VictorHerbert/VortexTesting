`timescale 1ps / 1ps

module Testbench;

    // Local parameters
    localparam CLK_PERIOD = 10;
    localparam CLK_HALF_PERIOD = CLK_PERIOD / 2;

    // Testbench signals
    logic clk = 1, reset = 0;
    logic mem_req_ready;
    logic mem_rsp_valid;
    logic [511:0] mem_rsp_data;
    logic [6:0] mem_rsp_tag;
    logic dcr_wr_valid;
    logic [11:0] dcr_wr_addr;
    logic [31:0] dcr_wr_data;
    wire mem_req_valid;
    wire mem_req_rw;
    wire [63:0] mem_req_byteen;
    wire [25:0] mem_req_addr;
    wire [511:0] mem_req_data;
    wire [6:0] mem_req_tag;
    wire mem_rsp_ready;
    wire busy;
    
    // Instantiate the DUT (Device Under Test)
    Vortex vortex (
        .clk(clk),
        .reset(reset),
        .mem_req_valid(mem_req_valid),
        .mem_req_rw(mem_req_rw),
        .mem_req_byteen(mem_req_byteen),
        .mem_req_addr(mem_req_addr),
        .mem_req_data(mem_req_data),
        .mem_req_tag(mem_req_tag),
        .mem_req_ready(mem_req_ready),
        .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_data(mem_rsp_data),
        .mem_rsp_tag(mem_rsp_tag),
        .mem_rsp_ready(mem_rsp_ready),
        .dcr_wr_valid(dcr_wr_valid),
        .dcr_wr_addr(dcr_wr_addr),
        .dcr_wr_data(dcr_wr_data),
        .busy(busy)
    );

    // Clock generation
    initial forever #CLK_HALF_PERIOD clk = ~clk;
    
    // Reset sequence
    initial begin
        reset = 1;
        #(3 * CLK_PERIOD);
        reset = 0;
    end

    // Task to generate a random memory response
    task automatic generate_mem_rsp();
        begin
            mem_rsp_valid = 1;
            mem_rsp_data = $random;
            mem_rsp_tag = $random;
            #CLK_PERIOD;
            mem_rsp_valid = 0;
        end
    endtask

    // Task to perform a DCR write
    task automatic dcr_write(input [11:0] addr, input [31:0] data);
        begin
            dcr_wr_valid = 1;
            dcr_wr_addr = addr;
            dcr_wr_data = data;
            #CLK_PERIOD;
            dcr_wr_valid = 0;
        end
    endtask

    initial begin
        $dumpfile("vortex_tb.vcd");
        $dumpvars(0, vortex);
    end

    // Test stimulus
    initial begin
        // Initialize signals
        mem_req_ready = 0;
        mem_rsp_valid = 0;
        mem_rsp_data = 0;
        mem_rsp_tag = 0;
        dcr_wr_valid = 0;
        dcr_wr_addr = 0;
        dcr_wr_data = 0;
        
        // Wait for reset deassertion
        #(4 * CLK_PERIOD);
        
        // Randomized memory request handling
        repeat (5) begin
            #($random % 20 + 10);
            mem_req_ready = $random;
        end
        
        // Generate memory response
        #30;
        generate_mem_rsp();
        
        // Perform a DCR write
        #20;
        dcr_write(12'h00A, 32'hDEADBEEF);
        
        // Wait and finish
        #100;
        $finish;
    end

endmodule
