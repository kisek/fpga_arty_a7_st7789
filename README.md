# fpga_arty_a7_st7789

This is a sample project of ST7789 TFT LCD display module (240x240 pixels) for Arty A7-35T FPGA board. 
Please connect the display module to the **Pmod JC** connector on the Arty A7 as shown in the following image.
Arty A7-35T has four Pmod ports named JA, JB, JC, and JD.

![arty_st7789](https://github.com/user-attachments/assets/3a54b025-9869-4ea1-940a-8fc95e305e4c)

The recommented version is **Vivado 2024.1**. 
When creating a Vivado project, please select **xc7a35ticsg324-1L** as an FPGA. 
Please add **main.v** and **main.xdc** to your Vivado project. 

Once the FPGA configuration is complete, you will see the green, blue, and white image shown above.

## RTL Simulation

You can simulate this module in a Linux GUI environment.
Please see the Makefile for instructions on how to compile and run the simulation.

For the compilation, you may require the Cairo 2D graphics library.
Please install it by **apt install libcairo-dev** for the Ubuntu environment.

![Screenshot 2024-11-04 105130](https://github.com/user-attachments/assets/0a0e261f-817b-4a9a-9a51-19ba3de40040)


## ST7789 Diaplay module of Pmod connector

The display module used in this project is not commercially available and may need to create the module by yourself. 
Please purchase (1) and (2) below.

(1) [Pin header (male L-type) 2×40 (80P) or similar one](https://akizukidenshi.com/catalog/g/g100148/).

(2) The LCD display available [here](https://www.amazon.co.jp/s?k=st7789+240x240+tft).
Please use the display with seven holes named GND, VCC, SCL, SDA, RES, DC, and BLK. 

![image](https://github.com/user-attachments/assets/005c1d02-e99e-40f3-ad2d-eb1535585c2b)

Firstly, please cut the pin header (1) of 2x40 (80 pins) to 2x6 (12 pins) for the Pmod. 
Secondly, please cut the unused six pins (5, 6, 7, 8, 9, and 10 pins) of the 2x6 (12 pins) header. 
Thirdly, please modify two pins so that pin 11 is connected to the pin 6 location and pin 12 is connected to the pin 5 location. 
Because the GND and VCC positions of the LCD module are reversed to the Pmod positions.
Finally, please solder the pin header you created to the display (2).
The display has seven holes named GND, VCC, SCL, SDA, RES, DC, and BLK. Please solder the first six holes exclude BLK. 

**Please use a tester to ensure that GND and VCC are not connected (the resistance of these pins is not 0 ohms).**

![image](https://github.com/user-attachments/assets/3c481cfa-6eb2-4fd7-bd67-6d717e461a35)


The file of main.ino is an Arduino sketch. 
The following is a photo running this sketch on an XIAO ESP32C3 board.
The I/O logic level of this board is 3.3V, so no resistors need to be connected.

![main](https://github.com/user-attachments/assets/013c5f13-6268-46b7-83e9-10a17982e1b8)

