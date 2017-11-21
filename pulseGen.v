module pulsegen(clk,start,mode,pulse);
input clk,start;
input [1:0] mode;
output reg pulse;

reg [21:0]counter;

initial begin
pulse=0;
end

always@(start)
if(start==1)
begin
  case(mode)
  2'b00: begin

         end
  2'b01: begin

         end
  2'b10: begin

         end
  2'b11: begin

         end
  counter<=0;
  endcase
end

else
  begin
    pulse<=0;
  end


  reg [17:0] counter;
  assign clk1k=counter[17];
  initial begin
      counter=0;
      end

     always@(posedge clk)
     begin
      counter<=counter+1;
      end





end


endmodule
