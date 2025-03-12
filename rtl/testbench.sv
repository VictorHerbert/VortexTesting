`timescale 1ps / 1ps

module Testbench;

    localparam CLK_PERIOD = 10;
    localparam CLK_HALF_PERIOD = CLK_PERIOD / 2;
    localparam RUNTIME = CLK_PERIOD*1e6;

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

    int counter = 0;

    initial forever #CLK_HALF_PERIOD clk = ~clk;

    initial forever #(RUNTIME/100) $display("%d %%", counter++);
    initial #(RUNTIME) $finish;

    task await_ticks(int ticks);
        repeat(ticks) @(posedge clk);
    endtask

    initial begin
        reset = 1;
        await_ticks(3);
        reset = 0;
    end

    task automatic mem_random_write();
        begin
            mem_rsp_valid = 1;
            mem_rsp_data = $random;
            mem_rsp_tag = $random;
            await_ticks(1);
            mem_rsp_valid = 0;
        end
    endtask

    task automatic dcr_random_write();
        begin
            dcr_wr_valid = 1;
            dcr_wr_addr = $random;
            dcr_wr_data = $random;
            await_ticks(1);
            dcr_wr_valid = 0;
        end
    endtask

    initial begin
        mem_req_ready = 0;
        mem_rsp_valid = 0;
        mem_rsp_data = 0;
        mem_rsp_tag = 0;
        dcr_wr_valid = 0;
        dcr_wr_addr = 0;
        dcr_wr_data = 0;
        
        await_ticks(5);
        
        fork
            begin
                forever begin
                    mem_req_ready = 1;
                    await_ticks(2);
                    mem_req_ready = 0;
                    await_ticks(2);
                end
            end


            begin
                forever begin
                    mem_random_write();
                    await_ticks(5);
                end
            end

            begin
                forever begin
                    dcr_random_write();
                    await_ticks(7);
                end
            end
        join

    end

endmodule
