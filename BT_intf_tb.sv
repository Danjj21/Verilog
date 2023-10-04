module BT_intf_tb();
///////////////////////////////////////////////////////////////////////////////
// This module tests BT_intf.sv with a model RN52 module to tests
// if audio is properly processed
///////////////////////////////////////////////////////////////////////////////

/// Declare test signals ///
reg clk, rst_n;
reg next_n;
reg prev_n;

reg [23:0] lft_smpled, rght_smpled;

/// wires to connect BT_intf, RN52, and I2S_Serf modules ///
wire cmd_n, TX, RX, I2S_sclk, I2S_ws, I2S_data, vld;
wire [23:0] rght_chnnl, lft_chnnl;

/// Instantiate RN52 Module ///
RN52 RN52(.clk(clk),.RST_n(rst_n),.cmd_n(cmd_n),.RX(TX),.TX(RX),.I2S_sclk(I2S_sclk),
		  .I2S_ws(I2S_ws),.I2S_data(I2S_data));
		  
/// Instantiate I2S_Serf ///
I2S_Serf I2S_Serf(.clk(clk),.rst_n(rst_n),.I2S_sclk(I2S_sclk),.I2S_ws(I2S_ws),
	.I2S_data(I2S_data),.vld(vld),.rght_chnnl(rght_chnnl),.lft_chnnl(lft_chnnl));

/// Instantiate DUT ///
BT_intf iDUT(.clk(clk),.rst_n(rst_n),.next_n(next_n),.prev_n(prev_n),.cmd_n(cmd_n),
			 .TX(TX),.RX(RX));
			 
			 
/// Infer channel sampling flops ///
always_ff @(posedge clk, negedge rst_n) begin
  if (vld) begin
	lft_smpled <= lft_chnnl;
	rght_smpled <= rght_chnnl;
  end
end

initial begin
  // init test inputs
  clk = 0;
  rst_n = 0;
  next_n = 1;
  prev_n = 1;
  // assert reset
  @(negedge clk) rst_n = 1;
  // deassert next_n to get to next song
  @(negedge clk) next_n = 0;
  @(negedge clk) next_n = 1;
  repeat (500) @(posedge vld);
  // deassert next_n to get to next song
  repeat (200000) @(negedge clk) next_n = 0;
  @(negedge clk) next_n = 1;
  repeat (200) @(posedge vld);
  // deassert prev_n to get to next song
  @(negedge clk) prev_n = 0;
  @(negedge clk) prev_n = 1;
  repeat (200) @(posedge vld);
  $stop();

end



always #5 clk = ~clk;

endmodule