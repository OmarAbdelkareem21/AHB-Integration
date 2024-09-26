module DecoderUnit #(parameter AddresseWidth = 32) (

	input wire [AddresseWidth - 1 : 0] HADDR,
	
	output reg HSELOne,
	output reg HSELTwo

);

always @(*)
begin
	case (HADDR [15:14])
	
	2'd0 :
		begin
			HSELOne = 1'd1;
			HSELTwo = 1'd0;
		end
	
	2'd1 :
		begin
			HSELOne = 1'd0;
			HSELTwo = 1'd1;
		end
	
	default :
		begin
			HSELOne = 1'd1;
			HSELTwo = 1'd0;
		end
	endcase 
end
endmodule