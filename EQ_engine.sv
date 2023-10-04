`default_nettype none
module	EQ_engine (clk,rst_n,VOLUME,POT_LP,POT_B1,POT_B2,POT_B3,POT_HP,
			      aud_in_lft,aud_out_lft,aud_in_rht,aud_out_rht,
			      vld,seq_low);

	  
	input logic [15:0] aud_in_lft, aud_in_rht;
	input logic vld;
	input logic clk,rst_n;
	input logic [11:0] POT_B1,POT_B2,POT_B3,POT_HP,POT_LP,VOLUME;
	
	output logic [15:0] aud_out_lft, aud_out_rht;
	output logic seq_low;

	logic sequencing_low_freq,sequencing_high_freq;
	
	logic [15:0] aud_out_high_queue_rht, aud_out_high_queue_lft;
	logic [15:0] aud_out_low_queue_rht, aud_out_low_queue_lft;
	
	logic [15:0] aud_out_FIR_LP_rght,aud_out_FIR_LP_lft;
	logic [15:0] aud_out_FIR_B1_rght,aud_out_FIR_B1_lft;
	logic [15:0] aud_out_FIR_B2_rght,aud_out_FIR_B2_lft;
	logic [15:0] aud_out_FIR_B3_rght,aud_out_FIR_B3_lft;
	logic [15:0] aud_out_FIR_HP_rght,aud_out_FIR_HP_lft;
	
	/////////////////////////////////////
	// Instantiate high_freq_queue //
	///////////////////////////////////
	high_freq_queue HF_queue(.clk(clk),.rst_n(rst_n),.lft_smpl(aud_in_lft[15:0]),.rght_smpl(aud_in_rht[15:0]),
						 .lft_out(aud_out_high_queue_lft),.rght_out(aud_out_high_queue_rht),
							.sequencing(sequencing_high_freq),.wrt_smpl(vld));
	
	/////////////////////////////////////
	// Instantiate low_frequency_queue //
	///////////////////////////////////
	low_freq_queue low_freq_queue(.clk(clk), .rst_n(rst_n),.lft_smpl(aud_in_lft[15:0]),
									.rght_smpl(aud_in_rht[15:0]),.vld_int(vld),.lft_out(aud_out_low_queue_lft),
										.rght_out(aud_out_low_queue_rht),.sequencing(sequencing_low_freq));
	/////////////////////////////////////////
	// Instantiate high frequency FIR Filters //
	///////////////////////////////////////////
	
	/////////////////////////////////////
	// FIR_B2//////////////////////////
	///////////////////////////////////
	FIR_B2 FIR_B2(.clk(clk), .rst_n(rst_n),.lft_in(aud_out_high_queue_lft),.rght_in(aud_out_high_queue_rht)
					,.sequencing(sequencing_high_freq),.rght_out(aud_out_FIR_B2_rght),.lft_out(aud_out_FIR_B2_lft));
	/////////////////////////////////////
	// FIR_B3//////////////////////////
	///////////////////////////////////
	FIR_B3 FIR_B3(.clk(clk), .rst_n(rst_n),.lft_in(aud_out_high_queue_lft),.rght_in(aud_out_high_queue_rht)
					,.sequencing(sequencing_high_freq),.rght_out(aud_out_FIR_B3_rght),.lft_out(aud_out_FIR_B3_lft));
			  
	/////////////////////////////////////
	// FIR_HP//////////////////////////
	///////////////////////////////////
	FIR_HP FIR_HP(.clk(clk), .rst_n(rst_n),.lft_in(aud_out_high_queue_lft),.rght_in(aud_out_high_queue_rht)
					,.sequencing(sequencing_high_freq),.rght_out(aud_out_FIR_HP_rght),.lft_out(aud_out_FIR_HP_lft));			  
	
	
	/////////////////////////////////////////
	// Instantiate low frequency FIR Filters //
	///////////////////////////////////////////
	
	/////////////////////////////////////
	// Instantiate FIR_B1 /////////// //
	///////////////////////////////////
	FIR_B1 FIR_B1(.clk(clk), .rst_n(rst_n),.lft_in(aud_out_low_queue_lft),.rght_in(aud_out_low_queue_rht),
					.sequencing(sequencing_low_freq),.rght_out(aud_out_FIR_B1_rght),.lft_out(aud_out_FIR_B1_lft));
	/////////////////////////////////////
	// Instantiate FIR_LP /////////// //
	///////////////////////////////////
	FIR_LP FIR_LP(.clk(clk), .rst_n(rst_n),.lft_in(aud_out_low_queue_lft),.rght_in(aud_out_low_queue_rht),
					.sequencing(sequencing_low_freq),.rght_out(aud_out_FIR_LP_rght),.lft_out(aud_out_FIR_LP_lft));
					

	
	/////////////////////////////////////
	// Instantiate 2 bandscales for//////
	// Left and Right LP   //////////////
	///////////////////////////////////
	logic [15:0] band_scale_LP_lft_out,band_scale_LP_rght_out;
	band_scale band_scale_LP_lft(.POT(POT_LP),.audio(aud_out_FIR_LP_lft),.scaled(band_scale_LP_lft_out));
	band_scale band_scale_LP_rght(.POT(POT_LP),.audio(aud_out_FIR_LP_rght),.scaled(band_scale_LP_rght_out));
	//
	/////////////////////////////////////
	// Instantiate 2 bandscales for//////
	// Left and Right HP   //////////////
	///////////////////////////////////
	logic [15:0] band_scale_HP_lft_out,band_scale_HP_rght_out;
	band_scale band_scale_HP_lft(.POT(POT_HP),.audio(aud_out_FIR_HP_lft),.scaled(band_scale_HP_lft_out));
	
	band_scale band_scale_HP_rght(.POT(POT_HP),.audio(aud_out_FIR_HP_rght),.scaled(band_scale_HP_rght_out));
	
	////////////////////////////////////
	// Instantiate 2 bandscales for//////
	// Left and Right B3   //////////////
	///////////////////////////////////
	logic [15:0] band_scale_B3_lft_out,band_scale_B3_rght_out;
	band_scale band_scale_B3_lft(.POT(POT_LP),.audio(aud_out_FIR_B3_lft),.scaled(band_scale_B3_lft_out));
	
	band_scale band_scale_B3_rght(.POT(POT_B3),.audio(aud_out_FIR_B3_rght),.scaled(band_scale_B3_rght_out));
	
	/////////////////////////////////////
	// Instantiate 2 bandscales for//////
	// Left and Right B2   //////////////
	///////////////////////////////////
	logic [15:0] band_scale_B2_lft_out,band_scale_B2_rght_out;
	band_scale band_scale_B2_lft(.POT(POT_LP),.audio(aud_out_FIR_B2_lft),.scaled(band_scale_B2_lft_out));
	
	band_scale band_scale_B2_rght(.POT(POT_B2),.audio(aud_out_FIR_B2_rght),.scaled(band_scale_B2_rght_out));
	
	/////////////////////////////////////
	// Instantiate 2 bandscales for//////
	// Left and Right B1   //////////////
	///////////////////////////////////
	logic [15:0] band_scale_B1_lft_out,band_scale_B1_rght_out;
	band_scale band_scale_B1_lft(.POT(POT_B1),.audio(aud_out_FIR_B1_lft),.scaled(band_scale_B1_lft_out));
	
	band_scale band_scale_B1_rght(.POT(POT_B1),.audio(aud_out_FIR_B1_rght),.scaled(band_scale_B1_rght_out));
	
	/////////////////////////////////////
	// logic to sum outputs from FIR ///
	///////////////////////////////////
	
	logic [16:0] sum_fir_lft,sum_fir_rght;
	
	assign sum_fir_lft = band_scale_B1_lft_out+band_scale_B1_lft_out+band_scale_B3_lft_out
							+band_scale_HP_lft_out+band_scale_LP_lft_out;

	assign sum_fir_rght = band_scale_B1_rght_out+ band_scale_B2_rght_out+ band_scale_B3_rght_out+
							band_scale_HP_rght_out+band_scale_LP_rght_out;
							
	logic [31:0] audio_out_left, audio_out_rght;
	
	
	assign audio_out_left = {1'b0,VOLUME} * sum_fir_lft;
	assign audio_out_rght = {1'b0,VOLUME} * sum_fir_rght;
	
	
	assign aud_out_lft= {audio_out_left[27:12]};
	assign aud_out_rht= {audio_out_rght[27:12]};
	
	
	always_ff @(posedge clk,negedge rst_n) begin
		if(!rst_n) begin
			seq_low<=1'b0;
		end else if(!sequencing_low_freq) begin
			seq_low<=1'b1;
		end
	end
endmodule
`default_nettype wire
