module uart_rx #(parameter DATA_BITS = 4'd8, parameter STOP_BITS = 4'd16)(
input  wire                  s_tick,
input  wire                  rx,
input  wire                  clk,
input  wire                  reset_n,
output reg                   rx_done,
output wire [DATA_BITS-1: 0] rx_data
);

localparam BIT_COUNTER_SIZE = $clog2(DATA_BITS);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] cs,ns;

reg [DATA_BITS-1: 0] shift_reg;
reg                  shift_en;

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
   rx_done          = 1'b0;
   tick_counter_en  = 1'b0;
   bit_counter_en   = 1'b0;
   tick_counter_rst = 1'b0;
   bit_counter_rst  = 1'b0;
   shift_en         = 1'b0;
   case(cs) 

     IDLE: 
      begin
       if(!rx)
        begin
         tick_counter_rst = 1'b1;
         tick_counter_en  = 1'b0;
         ns               = START;
        end 
       else
        begin
          ns = IDLE;
        end 
      end 

     START:  
      begin
       if(!s_tick)
        begin
         ns = START; 
        end 
       else if(tick_counter == 4'd7)
         begin
          bit_counter_rst      = 1'b1;
          tick_counter_rst     = 1'b1;
          ns = DATA;
         end 
        
        else 
         begin
          tick_counter_rst = 0;
          tick_counter_en  = 1;
          ns = START;
         end 
      end 
    
    DATA:
     begin
       if(!s_tick)
        begin
         ns = DATA; 
        end 
       else if(tick_counter == 4'd15)
         begin
          tick_counter_rst = 1'b1;
          shift_en         = 1'b1;

          if(bit_counter == DATA_BITS-1)
           begin
            ns = STOP;
           end
          else 
           begin
           	bit_counter_en  = 1'b1;
           	bit_counter_rst = 1'b0;
           	ns = DATA;
           end 
         end 
        
        else 
         begin
          tick_counter_rst = 1'b0;
          tick_counter_en  = 1'b1;
          ns = DATA;
         end       
     end 

     STOP:
      begin
       if(!s_tick)
        begin
         ns = STOP;
        end 
       else if(tick_counter == STOP_BITS-1)
        begin
         rx_done = 1'b1;
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
 if(shift_en)
  shift_reg <= {rx,shift_reg[DATA_BITS-1:1]};
 end 

assign rx_data = shift_reg;


endmodule