`default_nettype none
`timescale 1ns/1ps

module testbench;
  reg clk;
  reg rst;
  reg signed [31:0] deltaD;   
  wire signed [31:0] ffy;
  wire signed [31:0] fry;
  wire signed [31:0] vy;
  wire signed [31:0] wz;
  wire signed [31:0] alphaf;
  wire signed [31:0] alphar;

  proyect uut(
    .rst(rst),
    .clk(clk),
    .deltaD(deltaD),
    .ffy(ffy),
    .fry(fry),
    .vy(vy),
    .wz(wz),
    .alphaf(alphaf),
    .alphar(alphar)
  );

  // Generación de reloj 100 MHz → periodo 10 ns
  always #1 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,testbench);
  end
  
    initial begin
      // Inicialización
      clk = 0;
      rst = 1;
      deltaD = 0;
      
      #20 rst = 0;

      // Aplicar escalón de 0.043 rad en Q19.13
      #6000 deltaD = 32'sd352;

    // Finalizar simulación
 	#3000 $finish;
  end
  
  always @(posedge clk) begin
    $display("%0t %.4f %.4f %.4f ",  //t  delta vy  wz
      $time,
      $itor(deltaD)/8192.0,
      $itor(vy)/8192.0,
      $itor(wz)/8192.0,
    );
  end
endmodule
