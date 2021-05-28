`timescale 1ns/10ps

module sram_array_64_32
(	input	[64-1 : 0]	rwl	// read word line
,	input	[64-1 : 0]	wwl	// write word line
,	input	[32-1 : 0]	wbl	// write bit line - to reset SRAM cell (active low)
,	input	[32-1 : 0]	wblb	// write bit line bar (inverted) - to set SRAM cell (active low)
,	output	[32-1 : 0]	rbl	// read bit line
);
	// 64 x 32 SRAM array
	
	reg	[32-1 : 0]	ram_data	[64-1 : 0]; // array of vector

	// initialize ram data
	initial
	begin
		$display("sram_array is initialized. This message must be printed only once."); // This code is for counting the number of sram arrays you use. 
		$readmemb("ram_data2.txt", ram_data);
		ram_data[63][31:16] = 16'd0;	// no data stored at mem[254], mem[255] (reserved for output)
	end
	
	// SRAM array
	generate
		genvar i;
		genvar j;
		
		for (i = 0; i < 64; i = i + 1)
		begin
			wire	wwl_delayed;
			buf #(0.5, 0) wwl_del (wwl_delayed, wwl[i]); // to remove pulses narrower than 0.5ns

			for (j = 0; j < 32; j = j + 1)
			begin
				// SRAM cell
				// CAUTION: This implementation is just for describing SRAM cell behavior and NOT used in practice.
				
				bufif1 #0.5 readout (rbl[j], ram_data[i][j], rwl[i]); // inertial delay - maintain at least 0.5ns pulse width
				//assign rbl[j] = 0;
				always @*
				begin
				//$display("%10d: wwl always", $time);
					if (wwl_delayed)
						case ({ wbl[j], wblb[j] })
							2'b10: ram_data[i][j] = 1'b1;
							2'b01: ram_data[i][j] = 1'b0;
							2'b11: ; // no change
							default: ram_data[i][j] = 1'bX; // 1'b00 or X/Zs
						endcase
				end
			end
			
			if (i == 63)
			begin
				always @(negedge wwl_delayed)	// after write
				begin
					if (ram_data[i][16 +: 8] != 0) // written at mem[254]
					begin
						$write("%3d(%3d)", ram_data[i][16 +: 8], $signed(ram_data[i][16 +: 8])); // number output
						ram_data[i][16 +: 8] = 8'd0;	// no data stored at this address
					end
					if (ram_data[i][24 +: 8] != 0) // written at mem[255]
					begin
						if (ram_data[i][24 +: 8] == 8'd7) // output beep character to halt
						begin
							$display("\n--------------------------");
							$display("%10d: Halt by beep", $time);
							$stop;
						end
						$write("%c", ram_data[i][24 +: 8]); // character output
						ram_data[i][24 +: 8] = 8'd0;	// no data stored at this address
					end
				end
			end
		end
	endgenerate

endmodule: sram_array_64_32
