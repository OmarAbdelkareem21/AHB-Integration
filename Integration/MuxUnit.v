module MuxUnit #(parameter AddresseWidth = 32 , parameter DataWidth = 32 ) (

	input wire [DataWidth - 1 : 0] HRDATAOne,
	input wire [DataWidth - 1 : 0] HRDATATwo,
	
	input wire HRESPOne,
	input wire HRESPTwo,
	
	input wire HREADYOUTOne,
	input wire HREADYOUTwo,
	
	input wire HCLK, 
	input wire HRESETn,
	
	input reg HSELOne,
	input reg HSELTwo,
	
	output reg [DataWidth - 1 : 0] HRDATA,
	output reg HRESP,
	output reg HREADY
	

);

reg SelOne , SelTwo;

always @(posedge HCLK or negedge HRESETn)
begin
	if (!HRESETn)
		begin
			SelOne <= 1'd1;
			SelTwo <= 1'd0;
		end
	else
		begin
			SelOne <= HSELOne;
			SelTwo <= HSELTwo;
		end
end



// Address Mux
always @(*)
begin
	if (SelOne)
		begin
			HRDATA = HRDATAOne ;
			HRESP = HRESPOne;
			HREADY = HREADYOUTOne;
		end
	else if (SelTwo)
		begin
			HRDATA = HRDATATwo ;
			HRESP = HRESPTwo ;
			HREADY = HREADYOUTwo;
		end
	else
		begin
			HRDATA = HRDATAOne ;
			HRESP = HRESPOne;
			HREADY = HREADYOUTOne;
		end
end


endmodule