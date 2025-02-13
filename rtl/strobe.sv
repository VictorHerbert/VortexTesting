// ZOIX MODULE FOR FAULT INJECTION AND STROBING

module strobe;


// Inject faults
initial begin
        $display("ZOIX INJECTION");
        //$fs_inject;       // by default

        $fs_delete;			// CHECK THIS
        $fs_add(Vortex);		// CHECK THIS
end


// Strobe point
initial begin

        //#`START_TIME;
        #59000; //equivalent to strobe_offset tmax
        forever begin

        //OUTPUTS
                $fs_strobe(Vortex.mem_req_ready);
                $fs_strobe(Vortex.mem_rsp_valid);
                $fs_strobe(Vortex.mem_rsp_data);
                $fs_strobe(Vortex.mem_rsp_tag);
                $fs_strobe(Vortex.dcr_wr_valid);
                $fs_strobe(Vortex.dcr_wr_addr);
                $fs_strobe(Vortex.dcr_wr_data);
                $fs_strobe(Vortex.mem_req_valid);
                $fs_strobe(Vortex.mem_req_rw);
                $fs_strobe(Vortex.mem_req_byteen);
                $fs_strobe(Vortex.mem_req_addr);
                $fs_strobe(Vortex.mem_req_data);
                $fs_strobe(Vortex.mem_req_tag);
                $fs_strobe(Vortex.mem_rsp_ready);
                $fs_strobe(Vortex.busy);
                #10000; // TMAX Strobe period
        end

end



endmodule
