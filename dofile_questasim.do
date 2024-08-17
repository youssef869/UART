vlib work
vlog uart_baud_gen.v uart_tx.v uart_rx.v uart.v uart_tb.v
vsim -voptargs=+acc work.uart_tb
add wave *
run -all
#quit -sim