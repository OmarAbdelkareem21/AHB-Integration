module MasterAHB #(parameter AddresseWidth = 32 , parameter DataWidth = 32 , parameter InWidth = 32  , parameter ControlWidth = 16) (
	
	// Transfer Response 
	input wire HREADY,
	input wire HRESP,
	
	// Addresse and Control Bus
	// input wire [AddresseWidth -1 : 0] InAddresse,
	// Write Data Bus
	input wire [InWidth -1 : 0] InWData,
	input wire [AddresseWidth -1 : 0] Instruction ,
	// Control Bus 
	// input wire [ControlWidth - 1 : 0] InCotrol,
	// OutData
	output reg [DataWidth - 1 : 0] OutRData,
	output reg Write,
	output reg Read ,
		
	

	
	// Global Signals
	input wire HRESETn,
	input wire HCLK,
	
	//Data
	input wire [DataWidth - 1 : 0] HRDATA,
	
	output reg [AddresseWidth - 1 : 0] HADDR,
	output reg HWRITE,
	output reg [2 : 0] HSIZE,
	output reg [2 : 0] HBURST,
	//output reg [3 : 0] HPORT,
	output reg [1 : 0] HTRANS,
	output reg [DataWidth -1 : 0] HWDATA
	// Master Lock isn't Covered 
	//output reg HMASTLOCK,	

);

reg [3 : 0] CurrentState , NextState;
reg ReadWrite ;
reg OverLap ;
reg MasterOn ;
reg DataOut ; 
reg StayInc ;
wire SimpleINCR ;
wire BusySignal ;
wire [ControlWidth - 1 : 0] InCotrol;
wire [AddresseWidth -1 : 0] InAddresse;
reg W;

assign InCotrol = Instruction [15 : 0];

assign InAddresse = {16'b0, Instruction [31 : 16]};

assign BusySignal = InCotrol [11];
assign SimpleINCR = (InCotrol [10 : 8] == 3'b000) ? 1'd1 : 1'd0;
// Single -> 1 
// INCCR -> 0

wire Stop ;
assign Stop = InCotrol [15];

localparam [3 : 0] Start = 'd0,
				   Addresse = 'd1,
				   Data = 'd2,
				   DataSeq = 'd3,
				   AddresseINCR = 'd4,
				   BUSYSTATE = 'd5;
				   
localparam [1 : 0] IDLE = 2'b00,
				   BUSY = 2'b01,
				   NONSEQ = 2'b10,
				   SEQ = 2'b11;

always @(posedge HCLK or negedge HRESETn)
begin 
	if (!HRESETn)
		begin
			CurrentState <= Start ;
			// Default is Word 
			HSIZE <= 3'b010;
			// Default single Burst
			HBURST <= 3'b000;
			//HADDR <= 'D0;
		end
	else
		begin
			CurrentState <= NextState ;
			
			if (CurrentState == Start)
				begin
					HBURST <= InCotrol [10 : 8];
					HSIZE <= InCotrol [14 : 12];
				end
		end
	end
	
always @(posedge HCLK or negedge HRESETn)
begin 
	if (!HRESETn)
		begin
			HADDR <= 'D0;
			HTRANS <= IDLE ;
			HWRITE <= 'D0;
			// Read <= 'd0 ;
			W <= 'd0;
		end
	else
		begin
			if ( OverLap | MasterOn )
				begin
					HADDR <= InAddresse;
					HTRANS <= NONSEQ ;
					HWRITE <= ReadWrite;
					// Read <= ReadWrite;
					W <= !ReadWrite ;
				end
			else if ((StayInc) & !Stop)
				begin
					HADDR <= HADDR + (1<<HSIZE);
					HTRANS <= SEQ ;
				end
			else
				begin
					if (HREADY)
						begin
							HTRANS <= IDLE ;
							HWRITE <= 'D0;
							// Read <= 'd0;
							W <= 'D0;
						end
				end
		end
	end
	
	always @(posedge HCLK or negedge HRESETn)
	begin
		if (!HRESETn)
			begin
				Write <= 'd0;
			end
		else
			begin
				Write <= W;
			end
	end

always @(posedge HCLK or negedge HRESETn)
begin 
	if (!HRESETn)
		begin
			HWDATA <= 'D0;
		end
	else
		begin
			if ( DataOut)
				begin
					HWDATA <= InWData;
				end
		end
	end
	
always @(*)
begin
OutRData = HRDATA;
end
	
	
	

always @(*)
begin
NextState = CurrentState ;
OverLap = 1'd0;
DataOut = 1'd0;
StayInc = 1'd0 ;

	case (CurrentState)
			Start :
				begin
					StayInc = 1'd0 ;
					OverLap = 1'd0;
					DataOut = 1'd0;
					if (MasterOn)
						begin
							if (SimpleINCR)
								begin
									NextState = Addresse;
								end
							else
								begin
									NextState = AddresseINCR;
								end
						end
					else
						begin
							NextState = Start;
						end
				end
				
			Addresse : 
				begin
				if (HREADY)
					begin
							NextState = Data ;
							DataOut = 1'd1;
							StayInc = 1'd0 ;
							
							if (MasterOn)
								begin
									OverLap = 1'd1; 
								end
							else
								begin
									OverLap = 1'd0;
								end
					end
				else
					begin
						NextState = !HRESP ? Addresse : IDLE ;
						DataOut = 1'd0;
						StayInc = 1'd0 ;
						OverLap = 1'd0;
					end
				end
				
			Data :
				begin
				if (HREADY)
					begin
							StayInc = 1'd0 ;
							
							if (MasterOn)
								begin
									OverLap = 1'd1;
									NextState = Data ;
									DataOut = 1'd1;
								end
							else
								begin
									OverLap = 1'd0;
									NextState = Start ;
									DataOut = 1'd1;
								end
					end
				else
					begin
						NextState = !HRESP ? Data : IDLE ;
						StayInc = 1'd0;
						OverLap = 1'd0;
						DataOut = 1'd0;
					end
				end
			DataSeq :
				begin
					if (!BusySignal)
						begin
							if (HREADY)
								begin
									if (!Stop)
										begin
											StayInc = 1'd1;
											NextState = DataSeq ;
											DataOut = 1'd1;
											OverLap = 1'd0; 
										end
									else if (Stop & MasterOn)
										begin
											OverLap = 1'd1; 
											NextState = DataSeq ;
											StayInc = 1'd0 ;
											DataOut = 1'd1;
										end
									else
										begin
											StayInc = 1'd0;
											OverLap = 1'd0; 
											NextState = Start ;
											DataOut = 1'd1;
										end
								end
							else
								begin
									StayInc = 1'd0;
									OverLap = 1'd0; 
									NextState = !HRESP ? DataSeq : IDLE ;
									DataOut = 1'd0;
								end
						end
					else
						begin
							StayInc = 1'd1;
							OverLap = 1'd0; 
							NextState = BUSYSTATE ;
							DataOut = 1'd1;
						end
				end
				
			AddresseINCR :
				begin
					if (!BusySignal)
						begin
							if (HREADY)
								begin
									NextState = DataSeq ;
									DataOut = 1'd1;
									
									if (!Stop)
										begin
											OverLap = 1'd0; 
											StayInc = 1'd1 ;
										end
									else if (Stop & MasterOn)
										begin
											OverLap = 1'd1; 
											StayInc = 1'd0 ;
										end
									else
										begin
											OverLap = 1'd0;
											StayInc = 1'd0 ;
										end
								end
							else
								begin
									StayInc = 1'd0;
									OverLap = 1'd0; 
									NextState = !HRESP ? AddresseINCR : IDLE ;
									DataOut = 1'd0;
								end
						end
					else
						begin
							StayInc = 1'd1;
							OverLap = 1'd0; 
							NextState = BUSYSTATE ;
							DataOut = 1'd1;
						end
				end
				
			BUSYSTATE :
				begin
					
					if (MasterOn)
						begin
					StayInc = 1'd0 ;
					OverLap = 1'd0;
					DataOut = 1'd0;
							if (SimpleINCR)
								begin
									NextState = Addresse;
								end
							else
								begin
									NextState = AddresseINCR;
								end
						end
					else
						begin
						// Continue SEQ State
							if (InCotrol [7 : 0]== 'hCC)
								begin
									NextState = DataSeq ;
									DataOut = 1'd0;
									
									if (!Stop)
										begin
											OverLap = 1'd0; 
											StayInc = 1'd0 ;
										end
									else if (Stop & MasterOn)
										begin
											OverLap = 1'd1; 
											StayInc = 1'd0 ;
										end
									else
										begin
											OverLap = 1'd0;
											StayInc = 1'd0 ;
										end
								end
							else
								begin
									NextState = Start ;
								end
						end
				end
		
		
			default :
				begin
					NextState = Start;
					OverLap = 1'd0;
					DataOut = 1'd0;
					StayInc = 1'd0 ;
				end
		
		
	endcase
end


// Internal Decoder
always@(*)
	begin
	
		ReadWrite = 1'd0;
		MasterOn = 1'd0;
	
		// Write
		if (InCotrol [7 : 0]== 'hAA)
			begin
				ReadWrite = 1'd1;
				MasterOn = 1'd1;
				Read = 1'd1;
			end
		// Read
		else if (InCotrol [7 : 0]== 'hBB)
			begin
				ReadWrite = 1'd0;
				MasterOn = 1'd1;
				Read = 1'd0;
			end
		// Other Operations
		else
			begin
				ReadWrite = 1'd0;
				MasterOn = 1'd0;
				Read = 1'd0;
			end
			
	end
	

	
	
endmodule
