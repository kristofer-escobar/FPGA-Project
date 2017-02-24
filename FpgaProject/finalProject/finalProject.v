`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:31:08 02/24/2017 
// Design Name: 
// Module Name:    finalProject 
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
module finalProject(
	 input CLK,
    input [23:0] SEL,
	 input start,
	 output [23:0] LED
    );

reg [25:0] prescaler = 0;
reg [23:0] led = 24'h000001;

//States
localparam RESET = 0, RUNNING = 1;
reg [0:0] state = RESET;

wire s_start;
debouncer d1(.CLK (CLK), .switch_input (start), .trans_dn (s_start));

always @(posedge CLK)
begin
LED <= (SEL & led);
	case (state)
		RESET : begin
			led <= 1;
			if(s_start)
			begin
				state <= RUNNING;
			end
		end
		RUNNING : begin		
			prescaler <= prescaler + 1;
			if(prescaler == 26'd49999999)
			begin
				prescaler <= 0;
				led <= led<<1;
			end
			
			if(s_start)
			begin
				state <= RESET;
			end
		end
	endcase
end

endmodule

module debouncer(
	 input CLK,
	 input switch_input,
	 output reg state,
	 output trans_up,
	 output trans_dn
	 );
	 
reg sync_0, sync_1;
always @(posedge CLK)
begin
	sync_0 = switch_input;
end

always @(posedge CLK)
begin
	sync_1 = sync_0;
end

reg [16:0] count;
wire idle = (state == sync_1);
wire finished = &count;

always @(posedge CLK)
begin
	if (idle)
	begin
		count <= 0;
	end
	else
	begin
		count <= count + 1;
		if (finished)
		begin
			state <= ~state;
		end
	end
end

assign trans_dn = ~idle & finished & ~state;
assign trans_up = ~idle & finished & state;

endmodule
