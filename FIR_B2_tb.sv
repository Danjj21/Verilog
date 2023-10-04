module FIR_B2_tb();
///////////////////////////////////////////////////////////////////////////////
// This module tests Band2 FIR implementation
// working with our high frequency circular queue
///////////////////////////////////////////////////////////////////////////////

/// Define Test Signals ///
reg cmd_n;		// RN52 input, will be fed a constant 1'b1
reg RX;		// RN52 input, will be fed a constant 1'b1
reg clk, rst_n;

/// Signals to connect our modules ///
wire I2S_sclk, I2S_data, I2S_ws;		// connects RN52 and I2S
wire [23:0] lft_chnnl, rght_chnnl;		// data from I2S to queue
reg [23:0] lft_chnnl_uf, rght_chnnl_uf;	// lft rght data before queue & filter
wire [15:0] lft_out, rght_out;			// data from queue to FIR
wire sequencing;
wire wrt_smpl;							// also vld output from I2S
wire [15:0] lft_out_w, rght_out_w;
reg [15:0] lft_out_f, rght_out_f;			// lft rght data filtered

/// Module Intantiation ///

// Instantiate RN52 //
RN52 rn52(.clk,.RST_n(rst_n), .cmd_n, .RX,.TX(),.I2S_sclk,.I2S_data,.I2S_ws);

// Instantiate I2S_Serf //
I2S_Serf i2s_serf(.clk,.rst_n,.I2S_sclk,.I2S_data,.I2S_ws,.lft_chnnl,.rght_chnnl,
				  .vld(wrt_smpl));

// Instantiate HF queue //
high_freq_queue HF_queue(.clk,.rst_n,.lft_smpl(lft_chnnl[23:8]),.rght_smpl(rght_chnnl[23:8]),
						 .lft_out,.rght_out,.sequencing,.wrt_smpl);

// Instantiate FIR_HP //
FIR_B2 fir_B2(.clk,.rst_n,.lft_in(lft_out),.rght_in(rght_out),.sequencing,
			  .rght_out(rght_out_w),.lft_out(lft_out_w));
			  
// Infer lft & rght channel filtered and unfilterd flops from serf //
always_ff @(posedge clk) begin
  if (wrt_smpl) begin
	lft_chnnl_uf <= lft_chnnl;
	rght_chnnl_uf <= rght_chnnl;
	lft_out_f <= lft_out_w;
	rght_out_f <= rght_out_w;
  end
end

initial begin
  // init inputs //
  clk = 0;
  rst_n = 0;
  cmd_n = 1'b1;
  RX = 1'b1;
  // deassert reset on negedge clk //
  @(negedge clk) rst_n = 1;
  // run for 2.1 million clocks 
  repeat (4200000) @(posedge clk); 
  $display("End of test");
  $stop();
end

always #5 clk = ~clk;

endmodule
