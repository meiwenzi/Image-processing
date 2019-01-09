`timescale 1ns/1ns

module rd_bin;

parameter v_size = 50;
parameter h_size = 50;
integer i, fp;

reg [7:0] miage_buffer [v_size * h_size *3- 1: 0];

reg reset;
reg clk;
wire done;

reg pixel_val;
reg [23:0] pixel_in;

wire wr_pixel;
wire rd_pixel;
wire [v_size * h_size - 1: 0] addr_pixel;
wire [23:0] pixel_out;

reg [23:0] cnt;

initial begin 
   cnt = 0;
   reset = 1;
   clk = 0;
   $readmemh("../figureRGB", miage_buffer);
   fp=$fopen("../figureRGB3", "w");
   #1000;
   reset = 0;

end 

always #1 clk = ~clk;


always @(posedge clk, posedge reset) begin 
   if(reset == 1'd1) begin 
      pixel_val <= 1'd0;
      pixel_in <= 24'd0;
   end 
   else begin 
      if(rd_pixel) begin 
         pixel_in[23:16] <= miage_buffer[addr_pixel * 3 + 0];
         pixel_in[15:8]  <= miage_buffer[addr_pixel * 3 + 1];
         pixel_in[7:0]   <= miage_buffer[addr_pixel * 3 + 2];
         pixel_val <= 1'd1;
      end 
      else begin 
         pixel_val <= 1'd0;
      end 
      
      if(done == 1'd0) begin 
         if(wr_pixel) begin 
            $fdisplay(fp,"%02h", pixel_out[23:16]);
            $fdisplay(fp,"%02h", pixel_out[15:8]);
            $fdisplay(fp,"%02h", pixel_out[7:0]);
            $display("# pixel: %d R: %d G: %d B: %d", cnt, pixel_out[23:16], pixel_out[15:8], pixel_out[7:0]);
            cnt <= cnt + 1;
         end 
      end
      else begin 
         $fclose(fp);
         $stop;
      end 
      
   end 
end 

//--------------------------------------------------------------
// 灰度化
//gray #(
//   .V_SIZE(v_size),
//   .H_SIZE(h_size)
//)gray_ins(
//   .clk        (clk),
//   .reset      (reset),
//   
//   .rd_pixel   (rd_pixel),
//   .addr_pixel (addr_pixel),
//   
//   .pixel_val  (pixel_val),
//   .pixel_in   (pixel_in),
//   
//   .wr_pixel   (wr_pixel),
//   .pixel_out  (pixel_out),
//   
//   .done       (done)
//);

//----------------------------------------------------------------
// 二值化
//binarization #(
//   .V_SIZE(v_size),
//   .H_SIZE(h_size)
//)binarization_ins(
//   .clk        (clk),
//   .reset      (reset),
//   
//   .rd_pixel   (rd_pixel),
//   .addr_pixel (addr_pixel),
//   
//   .threshold  (24'h800000),
//   .color_0    (24'hFF_00_00),
//   .color_1    (24'h00_00_FF),
//   
//   .pixel_val  (pixel_val),
//   .pixel_in   (pixel_in),
//   
//   .wr_pixel   (wr_pixel),
//   .pixel_out  (pixel_out),
//   
//   .done       (done)
//);

//---------------------------------------------------------------------
// 灰度直方图
histogram #(
   .V_SIZE(v_size),
   .H_SIZE(h_size)
)histogram_ins(
   .clk        (clk),
   .reset      (reset),
   
   .rd_pixel   (rd_pixel),
   .addr_pixel (addr_pixel),
   
   .pixel_val  (pixel_val),
   .pixel_in   (pixel_in),
   
   //.hist       (),
   
   .done       (done)
);






endmodule 