/*************************************************************************************************/
/***** 240x240 ST7789 mini display project, Arduino sketch  Ver.2024-11-26a                  *****/
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

#define COLOR_RED   0xF800
#define COLOR_GREEN 0x07E0
#define COLOR_BLUE  0x001F
/*************************************************************************************************/
void setup() {
  sys_init();
}

/*************************************************************************************************/
void loop() {
  uint16_t c = COLOR_RED;
  while (1) {
    init_position();
    for (int y = 0; y < ST7789_HEIGHT; y++) {
      for (int x = 0; x < ST7789_WIDTH; x++) {
        spi_send(HIGH, c >> 8);
        spi_send(HIGH, c & 0xFF);
      }
    }
    c = (c==COLOR_RED) ? COLOR_GREEN : (c==COLOR_GREEN) ? COLOR_BLUE : COLOR_RED;
  }
}
/*************************************************************************************************/
