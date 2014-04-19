`define CLKSPERSYM 50000000 // set i+q after this many clock cycles

module ft245r_fifo (
	lastbyte,	// out
	rd_,			// out: read strobe (latches the value on the ft)
	wr,				// out: write strobe
	usbdata,	// in: the data bus from the ft245r
	txe_,   	// in: tx enable (when high, dont write)
	rxf_,			// in: read ready (when high, dont read)
	clk     	// in
);

output [7:0] lastbyte;
output rd_;
output wr;

input [7:0] usbdata;
input txe_;
input rxf_;
input clk;

reg [31:0] counter=0;
reg [2:0] state=0;
reg [7:0] lastbyte=0;

reg rd_=1;
reg wr =0;

always @(negedge clk) 
	begin
		counter=counter+1;

		// http://www.mouser.com/ds/2/163/DS_FT245R-19492.pdf
		// pg 13			
		case (state)
			0: begin // start. if !rxf (theres data to read), clear rd_
				if (0==rxf_) begin
					rd_=0;
					state=1;
				end
			end
			1: begin // wait for clk (TODO: is this still needed?)
				state=2;
			end
			2: begin // fetch value
				lastbyte=usbdata;
				state=3;
			end
			3: begin // set rd_
				rd_=1;
				state=4;
			end
			4: begin // wait for next counter event
				if (counter>=`CLKSPERSYM)
					begin
						counter=0; // reset counter
						state=0;   // start read sequence on next clock
					end
			end
		endcase
	end
endmodule

