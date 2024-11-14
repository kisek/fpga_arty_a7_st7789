/*********************************************************************************************/
/* 240x240 ST7789 mini display project               Ver.2024-11-14a, ArchLab, Science Tokyo */
/*********************************************************************************************/
`default_nettype none

`ifdef SYNTHESIS  
`define WAIT_CNT 100
`else
`define WAIT_CNT 10
`endif
  
/*********************************************************************************************/
module m_main(
    input  wire w_clk,          // main clock signal (100MHz)
    input  wire [3:0] w_button, //
    output wire [3:0] w_led,    //
    inout  wire st7789_SDA,     //
    output wire st7789_SCL,     //
    output wire st7789_DC,      //
    output wire st7789_RES      //
);
    reg [31:0] r_cnt = 0;
    always @(posedge w_clk) r_cnt <= r_cnt + 1;
    assign w_led = r_cnt[30:27];
    
    reg [7:0] r_x = 0;
    reg [7:0] r_y = 0;
    reg [7:0] r_d = 0;
    reg [7:0] r_wait = 1;
    always @(posedge w_clk) begin
        r_x <= (r_x==239) ? 0 : r_x + 1;
        r_y <= (r_y==239 && r_x==239) ? 0 : (r_x==239) ? r_y + 1 : r_y;
        if(r_y==0 && r_x==0) begin
            r_wait <= (r_wait>=`WAIT_CNT) ? 1 : r_wait + 1;
            if(r_wait==1) r_d <= r_d + 1;
        end
    end
    
    reg [15:0] r_st_wadr  = 0;
    reg        r_st_we    = 0;
    reg [15:0] r_st_wdata = 0;
    always @(posedge w_clk) r_st_wadr  <= {r_y, r_x};
    always @(posedge w_clk) r_st_we    <= 1; 
    always @(posedge w_clk) r_st_wdata <= (r_x<r_d && r_y<r_d) ? 16'hffff : 
                                          (r_x<r_y) ? 16'b11111100000 : 16'b11111;
  
    wire [15:0] w_raddr;    
    reg  [15:0] r_rdata = 0;
    reg  [15:0] r_raddr = 0;
    reg  [15:0] vmem [0:65535]; // video memory, 256 x 256 (65,536) x 16bit color
    always @(posedge w_clk) begin
        if(r_st_we) vmem[r_st_wadr] <= r_st_wdata;
        r_rdata <= vmem[r_raddr];
        r_raddr <= w_raddr;
    end
    
`ifndef SYNTHESIS  
    reg [15:0] r_adr_p = 0;
    reg [15:0] r_dat_p = 0;
    always @(posedge w_clk) if(r_st_we) begin
        if(vmem[r_st_wadr]!=r_st_wdata) begin
            r_adr_p <= r_st_wadr;
            r_dat_p <= r_st_wdata;
            $write("@D%0d_%0d\n", r_st_wadr ^ r_adr_p, r_st_wdata ^ r_dat_p);
            $fflush();
        end
    end
`endif

    wire [1:0]  w_mode = w_button[0] + w_button[1] + w_button[2] + w_button[3];
    m_st7789_disp disp0 (w_clk, st7789_SDA, st7789_SCL, st7789_DC, st7789_RES,
                         w_raddr, r_rdata, w_mode);
endmodule

/*********************************************************************************************/
module m_st7789_disp(
    input  wire w_clk, // main clock signal (100MHz)
    inout  wire st7789_SDA,
    output wire st7789_SCL,
    output wire st7789_DC,
    output wire st7789_RES,
    output wire [15:0] w_raddr,
    input  wire [15:0] w_rdata,
    input  wire [1:0]  w_mode
);
    reg [31:0] r_cnt=1;
    always @(posedge w_clk) r_cnt <= (r_cnt==0) ? 0 : r_cnt + 1;
    reg r_RES = 1;
    always @(posedge w_clk) begin
        if      (r_cnt==10_000) r_RES <= 0;
        else if (r_cnt==20_000) r_RES <= 1;
    end
    assign st7789_RES = r_RES;    
       
    wire busy; 
    reg r_en = 0;
    reg init_done = 0;
    reg [4:0]  r_state  = 0;   
    reg [19:0] r_state2 = 0;   
 
    reg [8:0] r_dat = 0;

    reg [15:0] r_c = 16'hf800;
    reg [15:0] r_pagecnt = 0;
   
    always @(posedge w_clk) if(!init_done) begin
        r_en <= (r_cnt>30_000 && !busy && r_cnt[10:0]==0); 
    end else begin
        r_en <= (!busy);
    end
    
    always @(posedge w_clk) if(r_en && !init_done) r_state  <= r_state  + 1;
    
    always @(posedge w_clk) if(r_en &&  init_done) begin
        r_state2 <= (r_state2==115210) ? 0 : r_state2 + 1; // 11 + 240x240*2 = 11 + 115200 = 115211
        if(r_state2==115210) r_pagecnt <= r_pagecnt + 1;
    end

    reg [7:0] r_x = 0;
    reg [7:0] r_y = 0;
    always @(posedge w_clk) if(r_en &&  init_done && r_state2[0]==1) begin
       r_x <= (r_state2<=10 || r_x==239) ? 0 : r_x + 1;
       r_y <= (r_state2<=10) ? 0 : (r_x==239) ? r_y + 1 : r_y;
    end
    
    wire [7:0] w_nx = 239-r_x;
    wire [7:0] w_ny = 239-r_y; 
    assign w_raddr = (w_mode==0) ? {r_y, r_x} :  // default
                     (w_mode==1) ? {r_x, w_ny} : // 90 degree rotation
                     (w_mode==2) ? {w_ny, w_nx} : {w_nx, r_y} ; //180 degree, 240 degree rotation
    
    reg  [15:0] r_color = 0;
    always @(posedge w_clk) r_color <= w_rdata;  
 
    always @(posedge w_clk) begin
        case (r_state2) /////
            0:  r_dat<={1'b0, 8'h2A};     //
            1:  r_dat<={1'b1, 8'h00};     //
            2:  r_dat<={1'b1, 8'h00};     //
            3:  r_dat<={1'b1, 8'h00};     //
            4:  r_dat<={1'b1, 8'd239};    //
            5:  r_dat<={1'b0, 8'h2B};     //
            6:  r_dat<={1'b1, 8'h00};     //
            7:  r_dat<={1'b1, 8'h00};     //
            8:  r_dat<={1'b1, 8'h00};     //
            9:  r_dat<={1'b1, 8'd239};    //
            10: r_dat<={1'b0, 8'h2C};     //  
            default: r_dat <= (r_state2[0]) ? {1'b1, r_color[15:8]} :{ 1'b1, r_color[7:0]}; 
        endcase
    end
    
    reg [8:0] r_init = 0;
    always @(posedge w_clk) begin
        case (r_state) /////
            0:  r_init<={1'b0, 8'h01};  //
            1:  r_init<={1'b0, 8'h11};  //
            2:  r_init<={1'b0, 8'h3A};  //
            3:  r_init<={1'b1, 8'h55};  //
            4:  r_init<={1'b0, 8'h36};  //
            5:  r_init<={1'b1, 8'h00};  //
            6:  r_init<={1'b0, 8'h2A};  //
            7:  r_init<={1'b1, 8'h00};  //
            8:  r_init<={1'b1, 8'h00};  //
            9:  r_init<={1'b1, 8'h00};  //
            10: r_init<={1'b1, 8'd240}; //
            11: r_init<={1'b0, 8'h2B};  //
            12: r_init<={1'b1, 8'h00};  //
            13: r_init<={1'b1, 8'h00};  //
            14: r_init<={1'b1, 8'h00};  //
            15: r_init<={1'b1, 8'd240}; //
            16: r_init<={1'b0, 8'h21};  //
            17: r_init<={1'b0, 8'h13};  //
            18: r_init<={1'b0, 8'h29};  //
            19: init_done <= 1;
        endcase
    end

    wire [8:0] w_data = (init_done) ? r_dat : r_init;
    m_spi spi0 (w_clk, r_en, w_data, st7789_SDA, st7789_SCL, st7789_DC, busy);
endmodule

/****** SPI send module,  SPI_MODE_2, MSBFIRST                                           *****/
/*********************************************************************************************/
module m_spi(
    input  wire w_clk,       // 100KHz input clock !!
    input  wire en,          // enable
    input  wire [8:0] d_in,  //
    inout  wire SDA,         // 
    output wire SCL,         // 
    output wire DC,          // 
    output wire busy         // busy
);
    reg [5:0] r_state=0;  //
    reg [7:0] r_cnt=0;    //
    reg r_SCL = 1;        //
    reg r_SDA = 1;        //
    reg r_DC  = 0;        // Data/Control
    reg [7:0] r_data = 0; //

    always @(posedge w_clk) begin
        if(en && r_state==0) begin
            r_state <= 1;
            r_data  <= d_in[7:0];
            r_DC    <= d_in[8];
            r_SDA   <= 0;
            r_cnt   <= 0;
        end
        else begin
            r_cnt <= (r_state==0) ? 0 : r_cnt + 1;
            if(r_state!=0 && r_cnt==18) r_state <= 0;
            if(r_cnt>0 && r_cnt[0]==0) r_data <= {r_data[6:0], 1'b0};
        end
    end

    always @(posedge w_clk) if(r_state!=0 && (r_cnt>=1) && (r_cnt<=16)) r_SCL <= ~r_SCL;

    assign SDA = r_data[7];
    assign SCL = r_SCL;
    assign DC  = r_DC;
    assign busy = (r_state!=0 || en);
endmodule
/*********************************************************************************************/
