/*******************************************************************************************/
/***** 240x240 ST7789 mini display project, Arduino IDE sketch  Ver.2024-12-20a        *****/
/***** Copyright (c) 2024 Archlab. Science Tokyo                                       *****/
/***** Released under the MIT license https://opensource.org/licenses/mit              *****/
/*******************************************************************************************/
#include <SPI.h>

/** pin locations for XIAO ESP32C3 board **/
//#define TFT_BLK       // BLK pin of ST7789 LCD -> open (connect nothing) 
#define TFT_DC  D5      // DC  pin of ST7798 LCD -> D5 
#define TFT_RES D4      // RES pin of ST7789 LCD -> D4 
//#define TFT_SDA       // SDA pin of ST7789 LCD -> D10 (SPI MOSI)
//#define TFT_SCL       // SCL pin of ST7789 LCD -> D8  (SPI CLK)
//#define TFT_VCC       // VCC pin of ST7789 LCD -> 3V3 of XIAO ESP32C3 board
//#define TFT_GND       // GND pin of ST7789 LCD -> GND of XIAO ESP32C3 board

/* Hardware SPI, MSB_FIRST and SPI_MODE3 */
/*******************************************************************************************/
void spi_send(int mode, uint8_t data){
    digitalWrite(TFT_DC,  mode);
    SPI.transfer(data);
}

/*******************************************************************************************/
void init_position() {
    spi_send(LOW,  0x2A); // set the column address
    spi_send(HIGH, 0x00); // data1
    spi_send(HIGH, 0x00); // data2
    spi_send(HIGH, 0x00); // data3
    spi_send(HIGH,  239); // data4
    spi_send(LOW,  0x2B); // set the row address
    spi_send(HIGH, 0x00); // data1
    spi_send(HIGH, 0x00); // data2
    spi_send(HIGH, 0x00); // data3
    spi_send(HIGH,  239); // data4
    spi_send(LOW,  0x2C); // write to RAM
    digitalWrite(TFT_DC,  HIGH);
}

/*******************************************************************************************/
inline void draw_pixel(int color)
{
    SPI.transfer((color >> 8) & 0xFF);
    SPI.transfer((color     ) & 0xFF);
}

/*******************************************************************************************/
int ITER_MAX = 256; //
int X_PIX  = 240;   // display width
int Y_PIX  = 240;   // display height

float x_min = 0.270851;
float x_max = 0.270900;
float y_min = 0.004641;
float y_max = 0.004713;
int iter = 0;

/*******************************************************************************************/
void mandelbrot()
{
    float dx = (x_max - x_min) / X_PIX;
    float dy = (y_max - y_min) / Y_PIX;

    for (int j = 1; j <= Y_PIX; j++) {
        float y = y_min + j * dy;
        for(int i = 1; i <= X_PIX; i++) {
            int k;
            float u  = 0.0;
            float v  = 0.0;
            float u2 = 0.0;
            float v2 = 0.0;
            float x = x_min + i * dx;
            for (k = 1; k < ITER_MAX; k++) {
                v = 2 * u * v + y;
                u = u2 - v2 + x;
                u2 = u * u;
                v2 = v * v;
                if (u2 + v2 >= 4.0) break;
            };
            int color = ((k & 0x7f) << 11) ^ ((k & 0x7f) << 7) ^ (k & 0x7f);
            if(iter&1) color = color ^ 0xFF;
            draw_pixel(color);
        }
    }
}

/*******************************************************************************************/
void setup() {
    pinMode(TFT_DC,  OUTPUT);
    pinMode(TFT_RES, OUTPUT);
    SPI.begin();
    SPI.beginTransaction(SPISettings(80000000, MSBFIRST, SPI_MODE3)); // 80MHz 

    digitalWrite(TFT_RES, LOW);     // reset
    digitalWrite(TFT_RES, HIGH); delay(120);

    spi_send(LOW,  0x11); delay(120); // Sleep Out, wait 120msec
    spi_send(LOW,  0x3A);             // Interface Pixel Format
    spi_send(HIGH, 0x55);             // [65K RGB, 16bit/pixel]
    spi_send(LOW,  0x36);             // Memory Data Accell Control
    spi_send(HIGH, 0x00);             // [000000]
    spi_send(LOW,  0x21);             // Display Inversion On
    spi_send(LOW,  0x13);             // Normal Display Mode On
    spi_send(LOW,  0x29);             // Display On

    init_position();
    for (int i = 1; i <= X_PIX * Y_PIX; i++) {
        draw_pixel(0xf);
    }
}

/*******************************************************************************************/
void loop() {
    init_position();
    mandelbrot();
    y_min += 0.000010;
    x_min += 0.000010;
    iter++;
}
/*******************************************************************************************/
