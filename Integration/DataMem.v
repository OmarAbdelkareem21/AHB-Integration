module DataMem #(parameter Width = 32) (
	
	input wire HCLK ,
	input wire HRESETn,
	
	input wire Write , 
	input wire Read ,
	
	input wire [Width - 1 : 0] OutRData ,
	
	output reg [Width - 1 : 0] InWData

);

reg [Width - 1 : 0] RegFileMem [0 : 7] ;
reg ValidW [0 : 7];
wire ReadDone;
reg [2 : 0] Counter; 
integer i ;

always @(posedge HCLK or negedge HRESETn)
begin
	if (!HRESETn)
		begin
			for (i = 0 ; i < 8 ; i = i + 1 )
				begin
					if (i == 0)
						begin
							RegFileMem [i] <= 'HAABB;
							ValidW [i] <= 'd1;
						end
					else if (i == 1)
						begin
							RegFileMem [i] <= 'H77cc;
							ValidW [i] <= 'd1;
						end
					else if (i == 2)
						begin
							RegFileMem [i] <= 'H86cc;
							ValidW [i] <= 'd1;
						end
					else if (i == 4)
						begin
							RegFileMem [i] <= 'HDDcc;
							ValidW [i] <= 'd1;
						end
					else if (i == 5)
						begin
							RegFileMem [i] <= 'H8622;
							ValidW [i] <= 'd1;
						end
					else if (i == 6)
						begin
							RegFileMem [i] <= 'H3333;
							ValidW [i] <= 'd1;
						end
					
					else
						begin
							RegFileMem [i] <= 'd0;
							ValidW [i] <= 'd0;
						end
				end
			
			Counter <= 'd0;
			InWData <= 'd0;
			
		end
	else
		begin
			if (Write && !Read)
				begin
					RegFileMem [Counter] <= OutRData ; 
					Counter <= Counter != 'd7 ? Counter + 'd1 : 'd0;
				end
			else if (!Write && Read)
				begin 
					InWData <= RegFileMem [Counter] ;
					Counter <= Counter != 'd7 ? Counter + 'd1 : 'd0;
				end
		end
end

endmodule 