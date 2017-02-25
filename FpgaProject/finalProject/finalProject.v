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
reg [23:0] led = 24'h000800;
reg [23:0] leds = 0;
//States
localparam PAUSE = 0, LRUNNING = 1, RRUNNING = 2;
reg [1:0] state = PAUSE;

reg [0:0] lastState = 0;
wire s_start;
debouncer d1(.CLK (CLK), .switch_input (start), .trans_dn (s_start));

assign LED = leds;// (SEL | led);
always @(posedge CLK)
begin
leds <= (SEL | led);

	case (state)
		PAUSE : begin
			//led <= 1;
			if(s_start)
			begin
				if(lastState)
				begin
					state <= RRUNNING;
				end
				else
				begin
					state <= LRUNNING;
				end
			end
		end
		LRUNNING : begin		
			prescaler <= prescaler + 1;
			if(prescaler == 26'd4999999)
			begin
				prescaler <= 0;
				if(led==24'h800000)
				begin
					state <= RRUNNING;
				end
				else 
				begin
					if((led<<1) & leds)
					begin
						state <= RRUNNING;				
					end	
					else
					begin
						led <= led<<1;
					end
				end
			end
			
			if(s_start)
			begin
				lastState <= 0;
				state <= PAUSE;
			end
		end
		RRUNNING : begin		
			prescaler <= prescaler + 1;
			if(prescaler == 26'd4999999)
			begin
				prescaler <= 0;
				if(led==24'h000001)
				begin
					state <= LRUNNING;
				end
				else 
				begin
					if((led>>1) & leds)
					begin
						state <= LRUNNING;				
					end	
					else
					begin
						led <= led>>1;
					end
				end
			end
			
			if(s_start)
			begin
				lastState <= 1;
				state <= PAUSE;
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
