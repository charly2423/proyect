/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns/1ps

module tt_um_proyect #(
  //parameter WIDTH = 1       // ancho de bits
  parameter T_GAIN = 3.5     // constante de integración (T)
)(
  input rst,
  input clk,
  input signed [31:0] deltaD,   
  output signed [31:0] ffy,     
  output signed [31:0] fry,     
  output reg signed [31:0] vy,  
  output reg signed [31:0] wz,  
  output signed [31:0] alphaf,  
  output signed [31:0] alphar   
);

  
  // CONSTANTES (multiplicadas por 2^13 = 8192)
  localparam signed [31:0] VX       = -28      * 8192;  // -229376
  localparam signed [31:0] VX_POS   =  28      * 8192;  // 229376
  localparam signed [31:0] MASA     =  4000    * 8192;  // 32,768,000
  localparam signed [31:0] INV_MASA =  0.00025 * 8192;  // 2.048
  localparam signed [31:0] INV_VX   =  0.035714* 8192;  // 293.7 ≈ 294
  localparam signed [31:0] CONT     =  0.00037 * 8192;  // 3.03 ≈ 3
  localparam signed [31:0] CONT1    = -0.00042 * 8192;  // -3.44 ≈ -3
  localparam signed [31:0] LF       =  1.30    * 8192;  // 10649
  localparam signed [31:0] LR       =  1.48    * 8192;  // 12125
  localparam signed [31:0] CF       =  88921.68;      
  localparam signed [31:0] CR       =  103408.8;     
  
  // Señales internas
  reg signed [31:0] vy_d;
  reg signed [31:0] wz_d;

  // BLOQUE 1: Dinámica lateral
  // vy' = vx*wz + (ffy+fry)/masa  -> sin división
  wire signed [31:0] sumF = ffy + fry;
  wire signed [31:0] term1 = (VX * wz) >>> 13;
  wire signed [31:0] term2 = (sumF * INV_MASA) >>> 13;
  assign vy_d = term1 + term2;

  // wz' = (ffy*cont) - (fry*cont1)
  wire signed [31:0] term3 = (ffy * CONT)  >>> 13;
  wire signed [31:0] term4 = (fry * CONT1) >>> 13;
  assign wz_d = term3 - term4;

  // Integradores discretos
  always @(posedge clk or posedge rst) begin
    if (rst)
      vy <= 32'd0;
    else
      vy <= vy + (vy_d * T_GAIN);
  end

  always @(posedge clk or posedge rst) begin
    if (rst)
      wz <= 32'd0;
    else
      wz <= wz + (wz_d * T_GAIN);
  end
  
  // BLOQUE 2: Cálculo de ángulos de deriva (alphaf, alphar)
  wire signed [31:0] tmpf = (((LF * wz) >>> 13) + vy);
  wire signed [31:0] tmpr = (((LR * wz) >>> 13) - vy);

  assign alphaf = (deltaD <<< 13) - ((tmpf * INV_VX) >>> 13);
  assign alphar = ((tmpr * INV_VX) >>> 13);

  
  // BLOQUE 3: Fuerzas laterales
  assign ffy = (CF * alphaf) >>> 13;
  assign fry = (CR * alphar) >>> 13;
endmodule

