module Top #(parameter Width = 32) (

	// 	Master external interface
	//input wire [Width -1 : 0] InWData,
	input wire WriteIn , 
	
	input wire [Width - 1 : 0] InInstruction ,
	
	//output wire [Width - 1 : 0] OutRData,
	
	// Global Signals
	input wire HRESETn,
	input wire HCLK
	
	// Slave external interface
	
);

wire [Width -1 : 0] InWData ;
wire [Width -1 : 0] OutRData ;  
wire [Width -1 : 0] HWDATA ; 
wire [Width -1 : 0] HRDATA ; 
wire [Width -1 : 0] HADDR ; 
wire [Width -1 : 0] Instruction ;
wire HREADY ;
wire HRESP ;
wire HWRITE ;
wire [2 : 0] HSIZE ;
wire [2 : 0] HBURST ;
wire [1 : 0] HTRANS ;
wire HSELOne;
wire HSELTwo;
wire [Width -1 : 0] HRDATAOne ;
wire [Width -1 : 0] HRDATATwo ;
wire HRESPOne;
wire HRESPTwo;
wire HREADYOUTOne;
wire HREADYOUTwo;
wire Read ;
wire Write ;



	MasterAHB MooTop (
	
		.Instruction (Instruction),
		.InWData(InWData),
		.OutRData(OutRData),
		.HREADY(HREADY),
		.Write(Write),
		.Read(Read),
		.HRESP(HRESP),
		.HRESETn(HRESETn),
		.HCLK(HCLK),
		.HRDATA(HRDATA),
		.HADDR(HADDR),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HTRANS(HTRANS),
		.HWDATA(HWDATA)
	
	);
	
	DecoderUnit DCUnit (
	
		.HADDR(HADDR),
		.HSELOne(HSELOne),
		.HSELTwo(HSELTwo)
	);
	
	MuxUnit MXUnit (
		
		.HRDATAOne(HRDATAOne),
		.HRDATATwo(HRDATATwo),
		
		.HRESPOne(HRESPOne),
		.HRESPTwo(HRESPTwo),
		
		.HREADYOUTOne(HREADYOUTOne),
		.HREADYOUTwo(HREADYOUTwo),
		
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		
		.HSELOne(HSELOne),
		.HSELTwo(HSELTwo),
		
		.HRDATA(HRDATA),
		.HRESP(HRESP),
		.HREADY(HREADY)
	);
	
	Slave SlaveUnitOne (
	
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		.HWDATA(HWDATA),
		.HADDR(HADDR),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HTRANS(HTRANS),
		.HREADY(HREADY),
		.HSELx(HSELOne),
		.HREADYOUT(HREADYOUTOne),
		.HRESP(HRESPOne),
		.HRDATA(HRDATAOne)
	);
	
	Slave SlaveUnitTwoo (
	
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		.HWDATA(HWDATA),
		.HADDR(HADDR),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HTRANS(HTRANS),
		.HREADY(HREADY),
		.HSELx(HSELTwo),
		.HREADYOUT(HREADYOUTwo),
		.HRESP(HRESPTwo),
		.HRDATA(HRDATATwo)
	);
	
	DataMem DMUnit (
	
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		
		.Write(Write),
		.Read(Read),
		
		.InWData(InWData),
		.OutRData(OutRData)
	);
	
	InsMem InsMemUnit (
	
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		
		.WriteIn(WriteIn),
		.InInstruction(InInstruction),
		.Instruction(Instruction)
		
	);
	

endmodule 