# Verilog
Code from ECE 352(verilog fundamentals and fpga prototyping) and ECE 551(digital system design)

EQUALIZER Project description(ECE 551 digital system design)
  ![image](https://github.com/Danjj21/Verilog/assets/104698571/ad4f160f-6f01-424f-a084-750ecb3e25ee)
  
  The audio processing will be done in the digital domain. The incoming audio stream will come from a 
  Bluetooth module on the I2S protocol. The stream broken into 5 bands via DSP FIR filters. Each 
  band will have a different gain term (as read via an A2D from a slide potentiometer) applied, and the 
  resulting modified digital bands will be summed to form a new left/right audio signal. That resulting 
  audio signal will be converted to PDM bits streams that will in turn go to low pass filters and then a 
  class D amps to drive the speakers. Volume control is also performed by multiplying the summed 
  audio signal for left/right channel by a gain number controlled by a sixth slide potentiometer. Finally
  there are two buttons on the board that can be used to skip to the next song, or repeat the previous 
  song.
  An audio equalizer divides the music into different frequency bands, and then allows each of these bands to 
  be gained/attenuated with individual controls. The resulting modified bands are then summed together to 
  form the output audio signal. 
