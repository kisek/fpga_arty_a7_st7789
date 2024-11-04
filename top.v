/*********************************************************************************************/
/* 240x240 ST7789 mini display project               Ver.2024-11-03a, ArchLab, Science Tokyo */
/*********************************************************************************************/
`default_nettype none
`define MAX_CYCLES 40000000

/*********************************************************************************************/
module top();
    reg r_clk = 1'b0; always  #10  r_clk <= !r_clk;
    wire [3:0] w_button; //
    wire [3:0] w_led;    //
    wire st7789_SDA;     //
    wire st7789_SCL;     //
    wire st7789_DC;      //
    wire st7789_RES;     //
    m_main main1 (r_clk, w_button, w_led, st7789_SDA, st7789_SCL, st7789_DC, st7789_RES);

    reg [31:0] r_tc = 0;
    always @(posedge r_clk) r_tc <= r_tc + 1;
      
    always @(posedge r_clk) if (r_tc>=`MAX_CYCLES) begin
        $write("@Dfin\n");
        $write("\nSimulation time out specified by MAX_CYCLES(%0d)\n\n", r_tc);
        $finish();
    end
endmodule
/*********************************************************************************************/
