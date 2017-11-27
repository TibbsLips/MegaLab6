module binToBCD(timer,digit1,digit2,digit3,digit4);
	input [15:0]timer;
	output reg [3:0]digit1;
	output reg [3:0]digit2;
	output reg [3:0]digit3;
	output reg [3:0]digit4;

	integer i;

	////value rolls over when 10-> 10= 1010->goes up to 1001
	always@(timer)
	begin
        digit4=0; //thousands place
        digit3=0; //hundreds place
        digit2=0; //tens place
        digit1=0; //ones place

        for(i=15; i>=0; i=i-1)	begin
            if(digit4 >=5)
                digit4=digit4+3;
            else
                digit4=digit4;

            if(digit3>=5)
                digit3=digit3+3;
            else
                digit3=digit3;

            if(digit2>=5)
                digit2=digit2+3;
            else
                digit2=digit2;

            if(digit1>=5)
                digit1=digit1+3;
            else
                digit1=digit1;

            digit4={digit4[2:0], digit3[3]};
            digit3={digit3[2:0], digit2[3]};
            digit2={digit2[2:0], digit1[3]};
            digit1={digit1[2:0], timer[i]};
        end
	end

endmodule
