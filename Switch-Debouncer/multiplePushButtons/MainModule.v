`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:42:07 12/14/2022 
// Design Name: 
// Module Name:    MainModule 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MainModule(CLK,RST,BTN,BTN1,BTN2,EN,anodeSelect,sevenSegOut);

input CLK,RST,BTN,BTN1,BTN2,EN;

output [6:0] sevenSegOut;
output [3:0] anodeSelect;

wire FourMsCLK;
wire [13:0] count9999;
wire [3:0] unit,ten,hundred,thousand,bcdOut,anodeSelect;
wire [2:0] muxSelect;

wire Td;
reg Ct,y;
reg [1:0] currentState,nextState;

parameter Zero = 2'b00,
          One  = 2'b10,
          Two  = 2'b11,
			 Three = 2'b00;
			 
always @(posedge CLK, posedge RST)
begin
 if(RST==1) begin
 currentState <= Zero;
 end
 else
 currentState <= nextState;
end 

always @(currentState)
begin
 case(currentState)
 Zero: begin
       if((BTN|BTN1|BTN2))
		  nextState = One;
		 else
		  nextState = Zero;
		 end
 One:  begin
       if(((BTN|BTN1|BTN2)==1) && (Td==1))
		  nextState = Two;
		 if(((BTN|BTN1|BTN2)==1) && (Td==0))
		  nextState = One;
		 if((BTN|BTN1|BTN2)==0)
		  nextState = Zero;
		 end
 Two:  begin
       if((BTN|BTN1|BTN2))
		  nextState = Two;
		 if((BTN|BTN1|BTN2)==0)
		  nextState = Three;
		 end
 Three: begin
        if((BTN|BTN1|BTN2))
		   nextState = Two;
		  if(((BTN|BTN1|BTN2)==0) && (Td==0))
		   nextState = Three;
		  if(((BTN|BTN1|BTN2)==0) && (Td==1))
		   nextState = Zero;
		  end
 default: 
         nextState = Zero;
 endcase
end
always @(currentState) begin
case(currentState)
Zero:    begin Ct=1; y = 0; end
One:     begin Ct=0; y = 0; end
Two:     begin Ct=1; y = 1; end
Three:   begin Ct=0; y = 1; end
default: begin Ct=1; y = 0; end
endcase
end

Up_Down_Counter #(18,200000)  Counter1(EN,RST,CLK,1'b0,,FourMsCLK);               //4ms CLOCK
Up_Down_Counter #(14,9999)    Counter2(Td,RST,y,1'b0,count9999,);                //counter to count with btn
Up_Down_Counter #(3,4)        Counter3(EN,RST,FourMsCLK,1'b0,muxSelect);          //counter for mux
Up_Down_Counter #(20,1000000) Counter4(EN,Ct,CLK,1'b0,,Td);                  //20ms CLOCK

binarycoddeddecimal BCD1(count9999,thousand,hundred,ten,unit);                    //Bin to BCD

mux m1(unit,ten,hundred,thousand,muxSelect[1],muxSelect[0],bcdOut);               //mux for bcd 
mux m2(4'b0111,4'b1011,4'b1101,4'b1110,muxSelect[1],muxSelect[0],anodeSelect);    //mux for anodes

bcd_to_seg ssg1(bcdOut,sevenSegOut);                                              //BCD to 7 seg

endmodule
