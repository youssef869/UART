# **UART overview**
A universal asynchronous receiver transmitter (UART) is a peripheral device for asynchronous serial communication in which the data format and transmission speeds are configurable. It sends data bits one by one, from the least significant to the most significant, framed by start and stop bits so the communication channel handles that precise timing.
UART transmitted data is organized into packets. Each packet contains 1 start bit, 5 to 9 data bits (depending on the UART), an optional parity bit, and 1 or 2 stop bits.

![image](https://github.com/user-attachments/assets/ade5a336-0b78-4ae4-b552-59b4a749d59b)

# **Procedure**
![image](https://github.com/user-attachments/assets/4fb2ea91-b7ca-472e-bb6b-70b4d4cb844e)
# **Block diagram**
![image](https://github.com/user-attachments/assets/cc327090-6e9d-46d0-834f-e6acf5c85619)
# **Implementation details**
## Baud rate generator 
For UART and most serial communications, the baud rate needs to be set the same on both the transmitting and receiving device. The baud rate is the rate at which information is transferred to a communication channel. In the serial port context, the set baud rate will serve as the maximum number of bits per second to be transferred. It will be a counter/timer that ticks whenever its final value is reached.

![image](https://github.com/user-attachments/assets/e07adcf4-20d1-46fe-bdec-44091db1df18)
![image](https://github.com/user-attachments/assets/1fc6f43d-3b51-4a81-927c-50408f1895ae)

_Note that the 16 in equations is due to oversampling which means that the receiver continues polling the received value at a frequency = 16 * BaudRate_
## Reciever ASMD
![image](https://github.com/user-attachments/assets/a85433b1-45a3-4b67-a7ee-2866672d7ab8)

where
- s_tick: done signal coming from baud rate generator
- s     : number of ticks counted till now
- n     : number of bits counter till now
## Transmitter ASMD 
![image](https://github.com/user-attachments/assets/a5d92779-37c7-4af6-96d4-98765043009a)

where 
- b: shift register inside the transmitter








