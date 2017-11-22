module pulsegen(clk1hz,clk,start,mode,pulse);
input clk,start,clk1hz;
input [1:0] mode;
output reg pulse;
reg pulsecontrol;
reg hybridtimer;
reg [22:0]counter;  //used to count for "pulse clocks"
reg [22:0]pulsevalue;

initial begin
hybridtimer<=0;     //hybrid timer is used to increment the hybrid mode step count based on the time 
pulse<=0;           //pulse when 1
pulsevalue<=23'b00000000000000000000000;
counter<=23'b00000000000000000000000;
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
                pulsevalue<=23'b00101111101011110000100; //walk: counter=1,562,500    32 pulses per second
             end
      2'b01: begin
                pulsecontrol<=1;
                pulsevalue<=23'b00010111110101111000010; //jog:  counter=  781,250    64 pulses per second
             end
      2'b10: begin
                pulsecontrol<=1;
                pulsevalue<=23'b00001011111010111100001; //run:  counter=  390,625    128 pulses per second
             end
      2'b11: begin
                if(hybridtimer==1)                                    //20 pulses per second: counter=2,500,000
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b01001100010010110100000;
                    end
                else if((hybridtimer==2)||(hybridtimer==9))           //33 pulses per second: counter=1,515,151
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00101110001111010001111;
                    end
                else if(hybridtimer==3)                               //66 pulses per second: counter=757,575
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00010111000111101000111;
                    end
                else if(hybridtimer==4)                               //27 pulses per second: counter=1,851,851
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00111000100000111001011;
                    end
                else if(hybridtimer==5)                               //70 pulses per second: counter=714,285
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00010101110011000101101;
                    end
                else if((hybridtimer==6)||(hybridtimer==8))           //30 pulses per second: counter=1,666,666
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00110010110111001101010;
                    end
                else if (hybridtimer==7)                              //19 pulses per second: counter=2,631,578
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b01010000010011110011010;
                    end
                else if((hybridtimer>=10)&&(hybridtimer<=73))         //69 pulses per second: counter=724,637
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00010110000111010011101;
                    end
                else if((hybridtimer>=74)&&(hybridtimer<=79))         //34 pulses per second: counter=1,470,588
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00101100111000001111100;
                    end
                else if((hybridtimer>=80)&&(hybridtimer<=144))        //124 pulses per second: counter=403,225
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00001100010011100011001;
                    end
                else 
                    begin
                        pulsecontrol<=0;
                        pulsevalue<=23'b00000000000000000000000;
                    end
             end
       endcase
    end
else
  begin
   pulsecontrol<=0;
   pulsevalue=23'b00000000000000000000000;
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
        counter<=23'b00000000000000000000000;
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
            counter<=23'b00000000000000000000000;  //we will reset counter if it is out of bounds or one pulse "clock" cycle
        end
    end

end

endmodule
