module Top_tb #(parameter Width = 32) ();

	// 	Master external interface
	
	reg [Width -1 : 0] InInstruction;
	reg WriteIn ;
	
	
	
	// Global Signals
	reg HRESETn;
	reg HCLK;
	
	
	Top TopUnit (
	
	
		.InInstruction(InInstruction),
		.WriteIn(WriteIn),
		
		.HRESETn(HRESETn),
		.HCLK(HCLK)
	
	);
	
	integer clock = 5 ;
	
	always #clock HCLK = !HCLK ;
	
	reg [2 : 0] WoedSize ;
	reg [2 : 0] SingleBurst ;
	reg [2 : 0] INCRBurst ;
	reg [7 : 0] WriteOp ;
	reg [7 : 0] ReadOp  ;
	reg StopINCR ;
	
	task initialze ;
	begin
		InInstruction = 'd0;
	    WriteIn = 1'D0;
		HCLK = 'd0;
		WoedSize = 3'b010;
		SingleBurst = 3'b000;
		INCRBurst = 3'b001;
		WriteOp = 8'hAA;
		ReadOp =  8'hBB ;
		StopINCR = 1'd0;
	end
	endtask
	
	task reset ;
	begin
		HRESETn = 'd1;
		#2
		HRESETn = 'd0;
		#2
		#1
		HRESETn = 'd1;
		#5;
	end
	endtask
	
	
	
	task TestCase1 ;
	begin
		#200;
	end
	endtask
	
	initial 
	begin
		initialze ();
		reset () ;
		
		TestCase1();
		
		$stop;
	
	end
	
	
	
	endmodule
	
		
