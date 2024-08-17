//oversampling = 16 * baud_rate

module uart #(parameter DATA_BITS = 4'd8, parameter STOP_BITS = 4'd16) (
input wire                 clk,
input wire                 reset_n,

input  wire [DATA_BITS-1: 0]  wr_data,
input  wire                wr_uart,
output wire                tx_full,
output wire                tx,

input  wire                rd_uart,
input  wire                rx,
output wire [DATA_BITS-1: 0]  rd_data,
output wire                rx_empty,

input  wire [10:0]         final_value    
);


wire baud_done;
uart_baud_gen #(.BITS(11)) baud_generator(
 .final_value(final_value),
 .reset_n(reset_n),
 .done(baud_done),
 .enable(1'b1),
 .clk(clk)
);


wire rx_done;
wire [DATA_BITS-1:0] rx_data;
uart_rx #(.DATA_BITS(DATA_BITS), .STOP_BITS(STOP_BITS)) reciever(
 .s_tick(baud_done),
 .rx(rx),
 .clk(clk),
 .reset_n(reset_n),
 .rx_data(rx_data),
 .rx_done(rx_done)
);

fifo_generator_0 rx_fifo (
  .clk(clk),      // input wire clk
  .srst(~reset_n),    // input wire srst
  .din(rx_data),      // input wire [7 : 0] din
  .wr_en(rx_done),  // input wire wr_en
  .rd_en(rd_uart),  // input wire rd_en
  .dout(rd_data),    // output wire [7 : 0] dout
  .full(),    // output wire full
  .empty(rx_empty)  // output wire empty
);


wire [DATA_BITS-1:0] tx_data;
wire tx_start;
wire tx_empty;
wire tx_done;
uart_tx #(.DATA_BITS(DATA_BITS), .STOP_BITS(STOP_BITS)) transmitter(
 .s_tick(baud_done),
 .tx(tx),
 .clk(clk),
 .reset_n(reset_n),
 .tx_data(tx_data),
 .tx_done(tx_done),
 .tx_start(~tx_empty)
);
fifo_generator_0 tx_fifo (
  .clk(clk),      // input wire clk
  .srst(~reset_n),    // input wire srst
  .din(wr_data),      // input wire [7 : 0] din
  .wr_en(wr_uart),  // input wire wr_en
  .rd_en(tx_done),  // input wire rd_en
  .dout(tx_data),    // output wire [7 : 0] dout
  .full(tx_full),    // output wire full
  .empty(tx_empty)  // output wire empty
);





endmodule