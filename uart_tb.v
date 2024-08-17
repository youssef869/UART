`timescale 1us/1ns
module uart_tb();

localparam DATA_BITS = 8;
localparam STOP_BITS = 16;

reg clk_tb;
reg reset_n_tb;

reg  [DATA_BITS-1: 0] wr_data_tb;
reg  wr_uart_tb;
wire tx_full_tb;
wire tx_tb;

reg rd_uart_tb;
wire rx_tb;
wire [DATA_BITS-1: 0] rd_data_tb;
wire rx_empty_tb;

reg  [10:0] final_value_tb; 

uart #(.DATA_BITS(DATA_BITS), .STOP_BITS(STOP_BITS)) DUT(
.clk(clk_tb),
.reset_n(reset_n_tb),

.wr_data(wr_data_tb),
.wr_uart(wr_uart_tb),
.tx_full(tx_full_tb),
.tx(tx_tb),

.rd_uart(rd_uart_tb),
.rx(rx_tb),
.rd_data(rd_data_tb),
.rx_empty(rx_empty_tb),

.final_value(final_value_tb)    
);

always #0.5 clk_tb = ~clk_tb;

initial 
 begin
 	clk_tb = 1'b0;
 	final_value_tb = 5;

 	reset_n_tb = 1'b0;
 	@(negedge clk_tb);
 	reset_n_tb = 1'b1;
    
    wr_uart_tb = 1'b1;
    wr_data_tb = 8'b0110_1101;
    #961.5;
    wr_uart_tb = 0;
    rd_uart_tb = 1;
    #1000;
    rd_uart_tb = 0;
    $stop;

     
 end

assign rx_tb = tx_tb;

endmodule