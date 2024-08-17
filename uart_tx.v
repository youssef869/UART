module uart_tx #(parameter DATA_BITS = 4'd8, parameter STOP_BITS = 4'd16)(
input  wire                  s_tick,
input  wire [DATA_BITS-1: 0] tx_data,
input  wire                  clk,
input  wire                  reset_n,
input  wire                  tx_start,
output reg                   tx_done,
output reg                   tx

);

localparam BIT_COUNTER_SIZE = $clog2(DATA_BITS);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] cs,ns;

reg [DATA_BITS-1: 0] shift_reg;
reg                  reg_shift;
reg                  reg_load;

reg [BIT_COUNTER_SIZE-1: 0] bit_counter;
reg                         bit_counter_rst,bit_counter_en;

reg [3:0] tick_counter;
reg       tick_counter_rst,tick_counter_en;

//state memory
always @(posedge clk or negedge reset_n)
 begin
 	if(~reset_n)
 	 begin
      cs <= IDLE;
 	 end 
 	else  
 	 begin
 	  cs <= ns;
 	 end 
 end


//next state logic
always @(*)
 begin
   tx_done          = 1'b0;
   tick_counter_en  = 1'b0;
   bit_counter_en   = 1'b0;
   tick_counter_rst = 1'b0;
   bit_counter_rst  = 1'b0;
   reg_shift        = 1'b0;
   reg_load         = 1'b0;

   case(cs) 
     IDLE: 
      begin
       tx = 1'b1;
       if(tx_start)
       begin
         ns = START;
         tick_counter_rst = 1'b1;
       end 
       else  
       begin
        ns = IDLE;
       end 

      end 

     START:  
      begin
       tx = 1'b0;
       if(!s_tick)
        begin
         ns = START;
        end
       else if(tick_counter == 4'd15)
       begin
        tick_counter_rst = 1'b1;
        bit_counter_rst = 1'b1;
        reg_load        = 1'b1;
        ns = DATA;
       end  
       else
        begin
         tick_counter_en  = 1'b1;
         tick_counter_rst = 1'b0;
         ns = START;
        end 
      end 
    
    DATA:
     begin
      tx = shift_reg[0];
      if(!s_tick)
       begin
        ns = DATA;
       end
      else if(tick_counter == 4'd15)
      begin
       tick_counter_rst = 1'b1;
       reg_shift = 1'b1;
       reg_load = 1'b0;
       if(bit_counter == DATA_BITS-1)
        begin
         ns = STOP;
        end 
       else
        begin
         bit_counter_en = 1'b1;
         bit_counter_rst = 1'b0;
         ns = DATA;
        end 
      end
      else 
       begin
        tick_counter_en  = 1'b1;
        tick_counter_rst = 1'b0;
        ns = DATA;
       end       
     end 

     STOP:
      begin
       tx = 1'b1;
       if(!s_tick)
        begin
         ns = STOP;
        end 
       else if(tick_counter == STOP_BITS-1)
        begin
         tx_done = 1'b1;
         ns = IDLE;
        end 
       else
        begin
         tick_counter_en  = 1'b1;
         tick_counter_rst = 1'b0;
         ns = STOP;
        end 
      end 
   endcase 
 end 


//tick counter logic
always @(posedge clk)
 begin
  if(tick_counter_rst)
   tick_counter <= 0;
  else if(tick_counter_en)
   tick_counter <= tick_counter + 1;
 end 

//bit counter logic
always @(posedge clk)
 begin
  if(bit_counter_rst)
   bit_counter <= 0;
  else if(bit_counter_en)
   bit_counter <= bit_counter + 1;
 end 


//shift register logic
always @(posedge clk) 
 begin
 if(reg_load)
  shift_reg <= tx_data;
 else if(reg_shift)
  shift_reg <= shift_reg >> 1;
 end 



endmodule