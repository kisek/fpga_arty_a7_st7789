/*************************************************************************************************/
/***** 240x240 ST7789 mini display project, Arduino sketch  Ver.2024-11-30a                  *****/
/***** Copyright (c) 2024 Archlab. Science Tokyo                                             *****/
/***** Released under the MIT license https://opensource.org/licenses/mit                    *****/
/*************************************************************************************************/
/** pin locations for XIAO ESP32C3 board **/
#define TFT_DC   D10   // Data/Command
#define TFT_RES  D9    // ST7789 Reset
#define TFT_SDA  D8    // Software SPI
#define TFT_SCL  D7    // Software SPI

/*************************************************************************************************/
#define ST7789_WIDTH   240
#define ST7789_HEIGHT  240

/* Software SPI, MSB_FIRST and SPI_MODE2 */
/*************************************************************************************************/
void spi_send(int mode, uint8_t data){
  int i;
  digitalWrite(TFT_DC,  mode);

  for (i=7; i>=0; i--) {
    digitalWrite(TFT_SDA, ((data >> i) & 1));
    digitalWrite(TFT_SCL, LOW);
    digitalWrite(TFT_SCL, HIGH); 
  }
}

/*************************************************************************************************/
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
}

/*************************************************************************************************/
void sys_init() {
  pinMode(TFT_DC,  OUTPUT);
  pinMode(TFT_RES, OUTPUT);
  pinMode(TFT_SDA, OUTPUT);
  pinMode(TFT_SCL, OUTPUT);

  digitalWrite(TFT_SCL, HIGH);
  digitalWrite(TFT_RES, LOW);     // reset
  digitalWrite(TFT_RES, HIGH); delay(120);

  spi_send(LOW,  0x01); delay(120); // Software Reset, wait 120msec
  spi_send(LOW,  0x11); delay(120); // Sleep Out, wait 120msec
  spi_send(LOW,  0x3A);             // Interface Pixel Format
  spi_send(HIGH, 0x55);             // [65K RGB, 16bit/pixel]
  spi_send(LOW,  0x36);             // Memory Data Accell Control
  spi_send(HIGH, 0x00);             // [000000]
  spi_send(LOW,  0x21);             // Display Inversion On
  spi_send(LOW,  0x13);             // Normal Display Mode On
  spi_send(LOW,  0x29);             // Display On
}

/*************************************************************************************************/
void setup() {
  sys_init();
}

/*************************************************************************************************/
double x_min = 0.270851;
double x_max = 0.270900;

double y_min = 0.004641;
double y_max = 0.004713;

int    iter_max = 256; //
int    x_pix  = 240;   // display width
int    y_pic  = 240;   // display height

/********************************************************************************/
void draw_pixel(int x, int y, int color)
{
    int addr = ((x << 8) & 0xFF00) | (y & 0xFF);
  //  printf("@D%d_%d\n", addr,  color);
  //  fflush(stdout);
  spi_send(HIGH, (color >> 8) & 0xFF);
  spi_send(HIGH, (color     ) & 0xFF);
}

/********************************************************************************/
void mandelbrot()
{
    double x, y;
    int i, j, k;
    double dx = (x_max - x_min) / x_pix;
    double dy = (y_max - y_min) / y_pic;

    y = y_min;
    for (j = 1; j <= y_pic; j++) {
        y += dy;
        x = x_min;
        for(i = 1; i <= x_pix; i++) {
            double u  = 0.0;
            double v  = 0.0;
            double u2 = 0.0;
            double v2 = 0.0;
            x += dx;
            for (k = 1; k < iter_max && (u2 + v2 < 4.0); k++) {
                v = 2 * u * v + y;
                u = u2 - v2 + x;
                u2 = u * u;
                v2 = v * v;
            };
            int color = ((k & 0x7f) << 11) ^ ((k & 0x7f) << 7) ^ (k & 0x7f);
            draw_pixel(i, j, color);
        }
    }
}

/*************************************************************************************************/
void loop() {
  init_position();
  mandelbrot();
}
/*************************************************************************************************/
