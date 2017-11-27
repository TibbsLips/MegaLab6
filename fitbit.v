//This module will take in the pulse and clk and use them to update the required settings information
//It will also output what type of data is to be displayed in a case statement
module fitbit(pulse,clk,totalsteps,distancecovered,stepover32,highactivity,currentinfo); //pulse will come from pulsegen
input pulse,clk;
output reg [17:0]totalsteps;      //This will hold total steps over 100,000 just in case
output reg [11:0]distancecovered; //This will hold distance covered over 1,000
output reg [4:0]stepover32;       //This will show how many of the first 9 seconds had steps over 32 will need to hold values up to 9
output reg [17:0]highactivity;    //activity>64 steps per second
output reg [1:0]currentinfo;      //will cycle through which info we should display
reg[27:0]seccounter;              //Will be used to determine pulses per second, 100,000,000 clocks=1 second
reg [5:0]pulsepersecond;          //This will hold the pulses per second      
reg [9:0]secondselapsed;          //This will determine how much time has passed to be used for stepover32, currently holds 300 seconds:5mins
reg [17:0]tempsteps;              //this will increment the steps and clear when we have the information we need: stepover32
reg secondsflag;                  //will let us know when a second has passed, and it will be used to clear tempsteps

initial
begin
totalsteps<=18'b000000000000000000;
tempsteps<=18'b000000000000000000;            
distancecovered<=12'b000000000000;
stepover32<=5'b00000;
highactivity<=18'b000000000000000000;
currentinfo<=2'b00;
seccounter<=28'b0000000000000000000000000000;
pulsepersecond<=6'b000000;
secondselapsed<=10'b0000000000;
secondsflag<=0;   
end

////This will use the clock to determine when a second has passed and increment the second counter
//It will also manipulate the seconds flag to clear the tempsteps and reset the pulsepersecond
always@(posedge clk)
begin
    secondsflag<=0;
    seccounter=seccounter+1;
    if(seccounter==28'b0101111101011110000100000000) //when secclk= 100,000,000 one second will have passed
        begin
             secondselapsed=secondselapsed+1;
             seccounter<=28'b0000000000000000000000000000;
             secondsflag<=1;
        end
end

//This will determine stepover32 and highactivity by triggering on each second and pulsepersecond (second pulse is redundant since the 
//pulsepersecond only goes high when a second has passed
always@(secondselapsed,pulsepersecond)
begin
    if((secondselapsed<=9)&&(pulsepersecond>=32))
        begin
            stepover32=stepover32+1;
            highactivity=highactivity;
        end  
    if (pulsepersecond>=64)
        begin
            stepover32=stepover32;
            highactivity=highactivity+1;
        end     
end

////Increment steps
always@(posedge pulse,posedge secondsflag)
begin
if(secondsflag==0)
    begin
        totalsteps=totalsteps+1;          //increase totalsteps with each pulse
        tempsteps<=tempsteps+1;           //possible race condition with one second clock above
        pulsepersecond<=0;
    end                                        ///////////////////////*********************************************/88888888888888888
else                                        //CAPS/////could do the entire above always block inside of this else statement!!!!!!!!!!!!!!!!!!
    begin
        pulsepersecond<=tempsteps;
        totalsteps=totalsteps;
        tempsteps=0;                    //was <=0, want a delay so that we can load oldtempsteps
    end    
end

////Distance Covered
always@(totalsteps)
begin
    distancecovered=totalsteps/1024;  //totalsteps/1024 will give us how many half miles we have traveled
end
endmodule
