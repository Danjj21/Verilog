`default_nettype none
module high_freq_queue_tb();

reg clk; //register for clock signal



logic rst_n;

logic Flt_n;

logic sht_dwn,sequencing;
wire cmd_n, TX, RX, I2S_sclk, I2S_ws, I2S_data, vld;
logic [15:0] lftsmpl_lowfreq [0:4095];//memory Instantiated for expected values

logic [15:0] rghtsmpl_lowfreq[0:4095];//memory Instantiated for stimulus values

reg [23:0] lft_smpled, rght_smpled;

/// wires to connect BT_intf, RN52, and I2S_Serf modules ///

wire [23:0] rght_chnnl, lft_chnnl;
wire [15:0] rght_out, lft_out;
////// Instantiate DUT ////////
high_freq_queue high_freq_queue1(.clk(clk), .rst_n(rst_n),.lft_smpl(lft_chnnl[23:8]),
					.rght_smpl(rght_chnnl[23:8]),.wrt_smpl(vld),.lft_out(lft_out),
						.rght_out(rght_out),.sequencing(sequencing));


reg next_n;
reg prev_n;



/// Instantiate RN52 Module ///
RN52 RN52(.clk(clk),.RST_n(rst_n),.cmd_n(cmd_n),.RX(RX),.TX(TX),.I2S_sclk(I2S_sclk),
		  .I2S_ws(I2S_ws),.I2S_data(I2S_data));
		  
/// Instantiate I2S_Serf ///
I2S_Serf I2S_Serf(.clk(clk),.rst_n(rst_n),.I2S_sclk(I2S_sclk),.I2S_ws(I2S_ws),
	.I2S_data(I2S_data),.vld(vld),.rght_chnnl(rght_chnnl),.lft_chnnl(lft_chnnl));

/// Instantiate DUT ///
BT_intf iDUT(.clk(clk),.rst_n(rst_n),.next_n(next_n),.prev_n(prev_n),.cmd_n(cmd_n),
			 .TX(RX),.RX(TX));
			 
			 
/// Infer channel sampling flops ///
always_ff @(posedge clk, negedge rst_n) begin
  if (vld) begin
	lft_smpled <= lft_chnnl;
	rght_smpled <= rght_chnnl;
  end
end
initial begin

	
	rst_n=1'b0;
	clk=1'b0;
	
    next_n = 1;
    prev_n = 1;
  // assert reset
    @(negedge clk) rst_n = 1;
	
	@(posedge high_freq_queue1.is_full);
	
	@(posedge high_freq_queue1.wrt_smpl);
	if (lft_out !== 16'h0000) begin
		$display("ERROR 1 %h",lft_out);
		$stop();
	end
	
	@(posedge high_freq_queue1.wrt_smpl);
	repeat(3) @(posedge clk);
	if (lft_out !== 16'h01ED) begin
		$display("ERROR 2 %h",lft_out);
		$stop();
	end
	
	@(posedge high_freq_queue1.wrt_smpl);
	repeat(3) @(posedge clk);
	if (lft_out !== 16'h03D6) begin
		$display("ERROR 3 %h",lft_out);
		$stop();
	end
	
	
	
	if(sequencing!=1'b0) begin
		$display("should be high");
		//$stop();
	end
	
	//read memory hex function into lftsmpl values array from given txt file
	//$readmemh("tone_hex_lft.txt",lftsmpl);
	//read memory hex function into rghtsmpl values array from given txt file
	//$readmemh("tone_hex_rght.txt",rghtsmpl);
	
	//for(int i=0;i<1021;i++) begin
	//	lft_smpl=lftsmpl[i];
	//	rght_smpl=rghtsmpl[i];		
	//end

	
	/*foreach(lftsmpl[i+1020]) begin
		
		if(lft_out!= lftsmpl[i]) begin
		$display("should be high");
		$stop();
		
	end
	foreach(rghtsmpl[i+1020]) begin
		
		if(rght_out!= rghtsmpl[i]) begin
		$display("should be high");
		$stop();
		
	end
	*/
	
	
	
	
	$display("All tests passed");
	$stop();
end

//always block to toggle clk signal
always begin

 #5 clk= ~clk;

end

endmodule
`default_nettype wire
