`timescale 1ns/1ns

module rd_bin;

parameter v_size = 1080;
parameter h_size = 1920;
integer i, fp;


reg [7:0] miage_buffer [v_size * h_size *3 - 1: 0];

reg [23:0] rgb;
reg [7:0] Y;
reg [7:0] Co;
reg [7:0] Cg; 

initial begin 
   $readmemh("D:/Matlab/figureRGB", miage_buffer);

   i=0;
   
//    fp=$fopen("D:/Matlab/figureRGB3", "w");
//    for(i=0;i<(v_size * h_size);i=i+1)
//    begin 
//       rgb = {miage_buffer[3*i + 0], miage_buffer[3*i + 1], miage_buffer[3*i + 2]};
//       $fdisplay(fp,"%02h", rgb/ 16'hffff);
//       $fdisplay(fp,"%02h", rgb/ 16'hffff);
//       $fdisplay(fp,"%02h", rgb/ 16'hffff);
//   end
//   $fclose(fp);
//---------------------------------------------------------
   fp=$fopen("D:/Matlab/figureRGB3", "w");
   for(i=0;i<(v_size * h_size);i=i+1)
   begin 
      Y = miage_buffer[3*i + 0][7:2] + miage_buffer[3*i + 1][7:2] + miage_buffer[3*i + 2][7:2];
      $fdisplay(fp,"%02h", Y);
//      $display("Y: pixel:%d %02h\n", i, miage_buffer[3*i + 0][7:2] + miage_buffer[3*i + 1][7:2] + miage_buffer[3*i + 2][7:2]);
      Co = miage_buffer[3*i + 0] - miage_buffer[3*i + 2] + 64;
      $fdisplay(fp,"%02h", Co);
//      $display("Co: pixel:%d %02h\n", i, miage_buffer[3*i + 0] - miage_buffer[3*i + 2] + 64);
      Cg = miage_buffer[3*i + 1] - miage_buffer[3*i + 2][7:1] - miage_buffer[3*i + 0][7:1] + 64;
      $fdisplay(fp,"%02h", Cg);
//      $display("Cg: pixel:%d %02h\n", i, miage_buffer[3*i + 1] - miage_buffer[3*i + 2][7:1] - miage_buffer[3*i + 0][7:1] + 64);
   end
   $fclose(fp);
//----------------------------------------------------------------
end 








endmodule 