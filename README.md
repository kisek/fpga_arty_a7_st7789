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

