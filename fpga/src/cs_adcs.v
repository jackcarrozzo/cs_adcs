`define IQMSB 7 
//`define RDIV 26
`define RDIV 26

module modulator (
	dacval, // out: the value written to the dac
	loclk,  // out: local osc for mixer
	synthclk, // out: clk to the dac
	pll_locked, //out
	usb_rd_, // out: ftdi 
	usb_wr,  // out: ftdi
	status,  //out: status lights
	clk,    // in
	usb_bus, // in from ftdi: databus
	usb_txe_, // ftdi ready to transmid
	usb_rxf_ // ftdi ready for read 
);

output [9:0] 	dacval;
output 				synthclk;
output 				loclk;
output 				pll_locked;
output 				usb_rd_;
output 				usb_wr;
output [7:0]  status;

input		 		clk;
input [7:0] usb_bus;
input 			usb_txe_;
input				usb_rxf_;

reg [`IQMSB:0]   i;
reg [`IQMSB:0]   q;

wire [7:0]		usbval;
reg [7:0] 	status;

reg					pllena;
reg      		areset;

wire [7:0] 	usb_bus;
wire 				usb_rd_;
wire 				usb_wr;
wire 				usb_txe_;
wire 				usb_rxf_;

reg [7:0] regdiv;
reg synthclk;
wire regclk_in;

iqcalc iq0(dacval,i,q,synthclk);
thepll pll0(areset,clk,pllena,regclk_in,loclk,pll_locked);
ft245r_fifo ftdi0(usbval,usb_rd_,usb_wr,usb_bus,usb_txe_,usb_rxf_,clk);

initial begin
	i=255;
	q=127;

	status=8'hff;

	pllena=1;
	areset=0;

	regdiv=`RDIV;
	synthclk=0;
	state=0;
end

always @(posedge regclk_in)
	begin
  	regdiv=regdiv-1;
    if (0==regdiv)
      begin
        regdiv=`RDIV;
        synthclk=~synthclk;
      end
	end

`define mag_h 160
`define mag_l 127
`define pause2  384615
`define pause5  961538
`define pause8  1923077
`define pause10 1923077

reg [31:0] c;
reg [2:0] state;
always @(posedge synthclk) 
	begin
		c=c+1;
		//c=0;
		//i=127;
		q=127;

		if (0==state) // 1 sec of full
			if (c>`pause10) 
				begin
					c=0;
					state=1;
					status=~status;
					i=`mag_l; // set low
				end

		if (1==state) // mark, low 0.8s 
			if (c>`pause8) 
				begin
					c=0;
					state=2;
					status=~status;
					i=`mag_h; // set high
				end

		if (2==state) // end of mark, high 0.2s
			if (c>`pause2) 
				begin
					c=0;
					state=3;
					status=~status;
					i=`mag_l; // set low
				end

		if (3==state) // set, low 0.5s
      if (c>`pause5) 
        begin
          c=0;
          state=4;
          status=~status;
          i=`mag_h; // set high
        end

		if (4==state) // end of set, high 0.5s
      if (c>`pause5)
        begin
          c=0;
          state=5;
          status=~status;
          i=`mag_l; // set low
        end

		if (5==state) // unset, low 0.2s
      if (c>`pause2)
        begin
          c=0;
          state=6;
          status=~status;
          i=`mag_h; // set high
        end
			
		if (6==state) // end of unset, high 0.8s
      if (c>`pause8)
        begin
          c=0;
          state=0;
          status=~status;
          i=`mag_l; // set low for next
        end
	end

endmodule

