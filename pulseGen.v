module pulsegen(clk,start,mode,pulse);
input clk,start;
input [1:0] mode;
output reg pulse;
reg pulsecontrol;
reg [8:0]hybridtimer;       //will hold values up to 511 (wont need them all)
reg [22:0]counter;          //used to count for "pulse clocks"
reg [22:0]pulsevalue;       //loads the value that the counter will count to before pulsing
reg [27:0]secclk;           //used to act as a clock divider to increment seconds
reg hybridlock;             //this will lock the timer for hybrid and will reset the timer (to increment through step numbers)
                            //hybridlock=0: do not use the timer, no hybrid mode     hybrid lock=1:use the hybrid timer
initial begin
secclk<=28'b0000000000000000000000000000;
hybridlock<=0;
hybridtimer<=9'b000000000;  //hybrid timer is used to increment the hybrid mode step count based on the time 
pulse<=0;                   //pulse when 1
pulsevalue<=23'b00000000000000000000000;
counter<=23'b00000000000000000000000;
pulsecontrol<=0;            //when pulsecontrol is 0, we will not use the "clock" always block to generate pulses 
end

//Always block will determine the activity mode 00= walk, 01=jog, 10=run, 11=hybrid
//It will use a counter to determine when pulses need to be set
//walk: counter=1,562,500
//jog:  counter=  781,250
//run:  counter=  390,625
//hybrid: various
//This will be used to control the output of pulse and hybrid mode
always@(start,hybridtimer)                               //needs to turn on with hybridtimer because it will use that value during hybrid mode
begin
if(start==1)
    begin
      case(mode)
      2'b00: begin
                hybridlock<=0;
                pulsecontrol<=1;
                pulsevalue<=23'b00101111101011110000100; //walk: counter=1,562,500    32 pulses per second
             end
      2'b01: begin
                hybridlock<=0;
                pulsecontrol<=1;
                pulsevalue<=23'b00010111110101111000010; //jog:  counter=  781,250    64 pulses per second
             end
      2'b10: begin
                hybridlock<=0;
                pulsecontrol<=1;
                pulsevalue<=23'b00001011111010111100001; //run:  counter=  390,625    128 pulses per second
             end
      2'b11: begin
                hybridlock<=1;                                                            //turn on hybridtimer which increments in seconds
                if(hybridtimer==9'b000000001)                                             //20 pulses per second: counter=2,500,000
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b01001100010010110100000;
                    end
                else if((hybridtimer==9'b000000010)||(hybridtimer==9'b000001001))         //33 pulses per second: counter=1,515,151
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00101110001111010001111;
                    end
                else if(hybridtimer==9'b000000011)                                        //66 pulses per second: counter=757,575
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00010111000111101000111;
                    end
                else if(hybridtimer==9'b000000100)                                        //27 pulses per second: counter=1,851,851
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00111000100000111001011;
                    end
                else if(hybridtimer==9'b000000101)                                        //70 pulses per second: counter=714,285
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00010101110011000101101;
                    end
                else if((hybridtimer==9'b000000110)||(hybridtimer==9'b000001000))         //30 pulses per second: counter=1,666,666
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00110010110111001101010;
                    end
                else if (hybridtimer==9'b000000111)                                       //19 pulses per second: counter=2,631,578
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b01010000010011110011010;
                    end
                else if((hybridtimer>=9'b000001010)&&(hybridtimer<=9'b001001001))         //69 pulses per second: counter=724,637
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00010110000111010011101;
                    end
                else if((hybridtimer>=9'b001001010)&&(hybridtimer<=9'b001001111))         //34 pulses per second: counter=1,470,588
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00101100111000001111100;
                    end
                else if((hybridtimer>=9'b001010000)&&(hybridtimer<=9'b010010000))        //124 pulses per second: counter=403,225
                    begin
                        pulsecontrol<=1;
                        pulsevalue<=23'b00001100010011100011001;
                    end
                else 
                    begin
                        hybridlock<=0;
                        pulsecontrol<=0;
                        pulsevalue<=23'b00000000000000000000000;
                    end
             end
       endcase
    end
else
  begin
   hybridlock<=0;
   pulsecontrol<=0;
   pulsevalue=23'b00000000000000000000000;
  end
end

//This will use the clock to generate pulses
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
        if(counter<=pulsevalue)                                    //our pulse will be high until the pulsevalue count then low for the next pulsevalue count, like a clock
        begin
            pulse<=1;
            counter=counter;
        end
        
        else if((counter>pulsevalue)&&(counter <= (pulsevalue*2))) //will be low for the next pulsevalue count
        begin
            pulse<=0;
            counter=counter;
        end
        
        else
        begin
            pulse=pulse;
            counter<=23'b00000000000000000000000;                  //we will reset counter if it is out of bounds or one pulse "clock" cycle
        end
    end
    
//This will use a 1hz signal to increment a "hybridtimer" counter for hybrid mode
//It will turn on when hybridlock is 1, and will run until hybridlock is cleared  
//cycles the clk 100,000,000 times to pulse a second
if(hybridlock==0)
    begin
        hybridtimer<=0;                                        //needs to be a range of values not binary
    end    
else
    begin
        secclk=secclk+1;
        if(secclk==28'b0101111101011110000100000000)            //when secclk= 100,000,000 one second will have passed
            begin                                               //so we increment hybrid timer, reset secclk, and check to see if we should pulse
               secclk=28'b0000000000000000000000000000;         //in hybrid so that we wont pulse past 145 seconds
               hybridtimer=hybridtimer+1;
               if(hybridtimer>=145)
                   begin                                               
                       hybridtimer<=150;                        //this will lock the hybrid timer, reset it using the last else in the last case statement
                   end                                          //which will cause it to clear hybridtimer, hybridlock, and pulsecontrol 
            end    
    end        
end

endmodule
