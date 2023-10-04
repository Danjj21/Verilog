module low_freq_queue(clk, rst_n, lft_smpl, rght_smpl, vld_int, lft_out, rght_out, sequencing);
	
	localparam mem_size = 1024;
	localparam queue_size = 1021;
	typedef enum logic [1:0] {WAIT_FOR_FULL, READ_OUT} state_t;
	state_t state, nxt_state;
	
	input logic clk, rst_n, vld_int;
	input logic [15:0] lft_smpl, rght_smpl;
	output logic sequencing;
	output logic [15:0] lft_out, rght_out;

	logic seen_one_vld, seen_one_vld_1, seen_one_vld_2, 
		is_full, en_new_ptr, en_old_ptr, seq_low, seq_high, wrt_smpl;
	logic [9:0] old_ptr, new_ptr, rd_ptr, end_ptr;
	
	// Instantiate dual-port memory
	dualPort1024x16 dpmem_left(.clk(clk), .we(wrt_smpl), .waddr(new_ptr), .raddr(rd_ptr), .wdata(lft_smpl), .rdata(lft_out));
	dualPort1024x16 dpmem_right(.clk(clk), .we(wrt_smpl), .waddr(new_ptr), .raddr(rd_ptr), .wdata(rght_smpl), .rdata(rght_out));
	
	// Flags for SM behavior
	assign is_full = (new_ptr == (queue_size - 1));
	
	// Wrapping flags
	assign wrap_new = (new_ptr == (mem_size - 1));
	assign wrap_old = (old_ptr == (mem_size - 1));
	assign wrap_rd = (rd_ptr == (mem_size - 1));
	
	// New ptr flop
	always_ff @(posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			new_ptr <= '0;
		end else if (wrap_new & en_new_ptr) begin
			new_ptr <= '0;
		end else if (en_new_ptr) begin
			new_ptr <= new_ptr + 1'b1;
		end
	end
	
	// Old ptr flop
	always_ff @(posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			old_ptr <= '0;
		end else if (wrap_old & en_old_ptr) begin
			old_ptr <= '0;
		end else if (en_old_ptr) begin
			old_ptr <= old_ptr + 1'b1;
		end
	end
	
	// Read ptr flop
	always_ff @(posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			rd_ptr <= '0;
		end else if (seq_high) begin
			rd_ptr <= old_ptr;
		end else if (wrap_rd & sequencing) begin
			rd_ptr <= '0;
		end else if (sequencing) begin
			rd_ptr <= rd_ptr + 1'b1;
		end
	end
	
	// End ptr logic
	assign end_ptr = ((old_ptr + 1020) > (mem_size - 1)) ? 
		// Account for overflow
		((old_ptr + 1020) - mem_size) : 
		// No overflow
		(old_ptr + 1020);
		
	assign seq_low = (rd_ptr == end_ptr);
	
	// Sequencing flop
	always_ff @(posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			sequencing <= 1'b0;
		end else if (seq_high) begin
			sequencing <= 1'b1;
		end else if (seq_low) begin
			sequencing <= 1'b0;
		end
	end
	
	// seen_one_vld posedge detection
	assign seen_one_vld = seen_one_vld_2 & ~seen_one_vld_1;
	
	// seen_one_vld flops - track valid parity
	always_ff @(posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			seen_one_vld_1 <= 1'b0;
			seen_one_vld_2 <= 1'b0;
		end else if (vld_int) begin
			seen_one_vld_2 <= ~seen_one_vld_2;
		end
		else begin
		seen_one_vld_1 <= seen_one_vld_2;
		end
		
	end

	// State flop
	always_ff @ (posedge clk, negedge rst_n) begin
		if (~rst_n) begin 
			state <= WAIT_FOR_FULL;
		end else begin
			state <= nxt_state;
		end
	end
	
	always_comb begin
	
		nxt_state = state;
		wrt_smpl = 1'b0;
		en_old_ptr = 1'b0;
		en_new_ptr = 1'b0;
		seq_high = 1'b0;
		
		case(state)
		
			default: begin //WAIT_FOR_FULL behavior	
				if (seen_one_vld) begin
					wrt_smpl = 1'b1;
					en_new_ptr = 1'b1;
				end
				if (is_full) begin
					nxt_state = READ_OUT;
				end
			end
			
			READ_OUT: begin
				if (seen_one_vld) begin
					wrt_smpl = 1'b1;
					en_old_ptr = 1'b1;
					en_new_ptr = 1'b1;
					seq_high = 1'b1;
				end
			end
			
		endcase
	end
endmodule
