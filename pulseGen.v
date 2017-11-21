module pulsegen(clk1hz,clk,start,mode,pulse);
input clk,start,clk1hz;
input [1:0] mode;
output reg pulse;
reg pulsecontrol;
reg [21:0]counter;  //used to count for "pulse clocks"
reg [21:0]pulsevalue;

initial begin
pulse<=0;            //pulse when 1
pulsevalue<=0;
counter<=0;
pulsecontrol<=0;    //when pulsecontrol is 0, we will not use the "clock" always block to generate pulses 
end

//Always block will determine the activity mode 00= walk, 01=jog, 10=run, 11=hybrid
//It will use a counter to determine when pulses need to be set
//walk: counter=1,562,500
//jog:  counter=  781,250
//run:  counter=  390,625
//hybrid:
always@(start)
begin
if(start==1)
    begin
      case(mode)
      2'b00: begin
                pulsecontrol<=1;
                pulsevalue<=22'b0101111101011110000100; //walk: counter=1,562,500
             end
      2'b01: begin
                pulsecontrol<=1;
                pulsevalue<=22'b0010111110101111000010; //jog:  counter=  781,250
             end
      2'b10: begin
                pulsecontrol<=1;
                pulsevalue<=22'b0001011111010111100001; //run:  counter=  390,625
             end
      2'b11: begin
                pulsecontrol<=1;
                //pulsevalue<=22'b  This needs to vary based on what time it is
             end
       endcase
    end
else
  begin
   pulsecontrol<=0;
   pulsevalue=22'b0000000000000000000000;
  end
end

//This will use the clock to generate frequencies for the pulses
//If pulsecontrol==0, we will reset the counter and the pulse
//If pulsecontrol==1, we need to use different pulse values which are updated above
always@(posedge clk)
begin
if(pulsecontrol==0)
    begin
        pulse<=0;
        counter<=0;
    end
else
    begin
        counter=counter+1;
        if(counter<=pulsevalue)            //our pulse will be high until the pulsevalue count then low for the next pulsevalue count, like a clock
        begin
            pulse<=1;
            counter=counter;
        end
        
        else if((counter>pulsevalue)&&(counter <= (pulsevalue*2)))//will be low for the next pulsevalue count
        begin
            pulse<=0;
            counter=counter;
        end
        
        else
        begin
            pulse=pulse;
            counter<=0;                   //we will reset counter if it is out of bounds or one pulse "clock" cycle
        end
    end

end

endmodule
