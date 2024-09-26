module InsMem  #(parameter Width = 32) (

	input wire HCLK ,
	input wire HRESETn,
	
	input wire WriteIn , 
	
	input wire [Width - 1 : 0] InInstruction ,
	
	output reg [Width - 1 : 0] Instruction
	
	);
	
	reg [Width - 1 : 0] RegFileMem [0 : 31] ;
	reg ValidW [0 : 7];
	wire ReadDone;
	reg [4 : 0] Counter; 
	integer i ;
	
always @(posedge HCLK or negedge HRESETn)
begin
	if (!HRESETn)
		begin
			for (i = 0 ; i < 32 ; i = i + 1 )
				begin
					if (i == 0)
						begin
							RegFileMem [i] <= {16'h0001,1'd0,3'b010,1'd0,3'b000,8'hAA};
							ValidW [i] <= 'd1;
						end
					else if (i == 1)
						begin
							RegFileMem [i] <= {16'h0000,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					else if (i == 2)
						begin
							RegFileMem [i] <= {16'h0002,1'd0,3'b010,1'd0,3'b000,8'hAA};
							ValidW [i] <= 'd1;
						end
					else if (i == 3)
						begin
							RegFileMem [i] <= {16'h0003,1'd0,3'b010,1'd0,3'b000,8'hAA};
							ValidW [i] <= 'd1;
						end
					else if (i == 4)
						begin
							RegFileMem [i] <= {16'h0003,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					else if (i == 5)
						begin
							RegFileMem [i] <= {16'h0001,1'd0,3'b010,1'd0,3'b000,8'hBB};
							ValidW [i] <= 'd1;
						end
					else if (i == 6)
						begin
							RegFileMem [i] <= {16'h0003,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					else if (i == 7)
						begin
							RegFileMem [i] <= {16'h0003,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					else if (i == 8)
						begin
							RegFileMem [i] <= {16'h4001,1'd0,3'b010,1'd0,3'b000,8'hAA};
							ValidW [i] <= 'd1;
						end
					else if (i == 9)
						begin
							RegFileMem [i] <= {16'h4000,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					else if (i == 10)
						begin
							RegFileMem [i] <= {16'h4002,1'd0,3'b010,1'd0,3'b000,8'hAA};
							ValidW [i] <= 'd1;
						end
					else if (i == 11)
						begin
							RegFileMem [i] <= {16'h4003,1'd0,3'b010,1'd0,3'b000,8'hAA};
							ValidW [i] <= 'd1;
						end
					else if (i == 12)
						begin
							RegFileMem [i] <= {16'h4003,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					else if (i == 13)
						begin
							RegFileMem [i] <= {16'h4001,1'd0,3'b010,1'd0,3'b000,8'hBB};
							ValidW [i] <= 'd1;
						end
					else if (i == 14)
						begin
							RegFileMem [i] <= {16'h4003,1'd0,3'b010,1'd0,3'b000,8'h00};
							ValidW [i] <= 'd1;
						end
					
					else
						begin
							RegFileMem [i] <= 'd0;
							ValidW [i] <= 'd0;
						end
				end
			
			Counter <= 'd0;
			Instruction <= 'd0;
			
		end
	else
		begin
			Instruction <= RegFileMem [Counter] ;
			Counter <= Counter != 'd31 ? Counter + 'd1 : 'd0;
			
			if (WriteIn)
				begin
					RegFileMem [Counter] <= InInstruction ; 
					Counter <= Counter != 'd31 ? Counter + 'd1 : 'd0;
				end
		
		end
end



	
endmodule