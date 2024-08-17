module uart_baud_gen #(parameter BITS = 16)
(	input clk,
	input enable,
	input [BITS-1: 0] final_value,
	input reset_n,
	output done
);

reg [BITS-1 : 0] cs,ns;

assign done = (cs == final_value);

//state memory
always @(posedge clk or negedge reset_n) begin
	if(~reset_n)
		cs <= 0;
	else if(enable)
		cs <= ns;
end

//next state logic
always @(*) begin
	ns = done ? 0 : cs + 1;
end

endmodule