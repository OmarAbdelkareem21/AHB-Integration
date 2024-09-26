module Slave #(parameter AddresseWidth = 32 , parameter DataWidth = 32 , parameter InWidth = 32  , parameter ControlWidth = 16) ( 

	// Global Interface
	input wire HCLK, 
	input wire HRESETn,
	
	// Data 
	
	input wire [DataWidth - 1 : 0] HWDATA,
	
	// Address & ControlWidth
	input wire [AddresseWidth - 1 : 0] HADDR,
	input wire HWRITE,
	input wire [2 : 0] HSIZE,
	input wire [2 : 0] HBURST,
	//output reg [3 : 0] HPORT,
	input wire [1 : 0] HTRANS,
	//output reg HMASTLOCK,	
	input wire HREADY,
	
	// Select
	input wire HSELx,
	
	// Transfer Response 
	output reg HREADYOUT,
	output reg HRESP,
	
	output reg [DataWidth - 1 : 0] HRDATA


);

reg [DataWidth - 1 : 0] RegFileMem [0 : 7] ;
reg [AddresseWidth - 1 : 0] AddressOUT;
reg Write;
reg Read;

localparam [1 : 0] IDLE = 2'b00,
				   BUSY = 2'b01,
				   NONSEQ = 2'b10,
				   SEQ = 2'b11;
integer i ;

reg MemOn;
				   
				   
always @(posedge HCLK or negedge HRESETn)
begin
	if (!HRESETn)
		begin
			Write <= 'd0 ;
			Read <= 'd0 ;
			AddressOUT <= 'd0 ;
			
		end
	else
		begin
			if (HSELx)
				begin
					case (HTRANS)
						
						NONSEQ :
							begin
								Write <= HWRITE ;
								Read <= !HWRITE ;
								AddressOUT <= HADDR ;
							end
								
					
						SEQ :
							begin
								Write <= HWRITE ;
								Read <= !HWRITE ;
								AddressOUT <= HADDR ;
							end
						default :
							begin
								Write <= 'd0 ;
								Read <= 'd0 ;
							end
				
					endcase
				end
		end
end


always @(posedge HCLK or negedge HRESETn)
begin
	if (!HRESETn)
		begin
			for (i = 0 ; i < 8 ; i = i + 1 )
				begin
					
						begin
							RegFileMem [i] <= 'd0;
						end
				end
			
		end
	else
		begin
			if (Write && !Read)
				begin
					RegFileMem [AddressOUT[2:0]] <= HWDATA ; 
				end
		end
end


always @(*)
begin
	if (!Write && Read)
		begin
			HRDATA = RegFileMem [AddressOUT[9:0]];
			HREADYOUT = 1'd1;
			HRESP = 1'd0;
		end
	else 
		HRDATA = 'd0;
		HREADYOUT = 1'd1;
		HRESP = 1'd0;
end




endmodule