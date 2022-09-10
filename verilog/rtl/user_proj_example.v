// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    
     input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,
    
    //inout [`MPRJ_IO_PADS-10:0] analog_io,

    
     output [2:0] irq

);
    wire clkin;
    wire en;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [3:0]n;
    wire clkout;
    wire [24:0]in1;
    
    assign clkin=wb_clk_i;
    assign io_oeb=0;
    
    assign {en,n,in1}=io_in[`MPRJ_IO_PADS-2:0];
    assign io_out={clkout,37'b0};

   iiitb_freqdiv uut(en,clkin,n,clkout);

endmodule


module iiitb_freqdiv(en,clkin,n,clkout);

input clkin;
input [3:0]n;
input en;
reg [3:0]pc;
reg [3:0]nc;
output clkout;

always@(posedge clkin)
begin
if(en==1)
begin
  if(pc<(n-1))
	pc<=pc+1;
  else
	pc<=0;
end
else
 pc<=0;
end

always@(negedge clkin)
begin
if(en==1)
begin
  if(nc<(n-1))
	nc<=nc+1;
  else
	nc<=0;
end
else
  nc<=0;
end

assign clkout=(n%2==0)?(pc<n/2):((pc<(n/2)+1)&&(nc<(n/2)+1));
endmodule
`default_nettype wire
