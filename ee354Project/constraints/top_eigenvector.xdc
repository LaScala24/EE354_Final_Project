set_property PACKAGE_PIN E3 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name clk -period 10.00 [get_ports clk]

set_property PACKAGE_PIN C12 [get_ports reset]				
	set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN J15 [get_ports {sw0}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw0}]

set_property PACKAGE_PIN L16 [get_ports {sw1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw1}]

set_property PACKAGE_PIN M13 [get_ports {sw_eps[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_eps[0]}]

set_property PACKAGE_PIN R15 [get_ports {sw_eps[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_eps[1]}]

set_property PACKAGE_PIN R17 [get_ports {sw_eps[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_eps[2]}]

set_property PACKAGE_PIN H17 [get_ports {led[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN K15 [get_ports {led[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN J13 [get_ports {led[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN N14 [get_ports {led[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN R18 [get_ports {led[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN V17 [get_ports {led[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN U17 [get_ports {led[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN U16 [get_ports {led[7]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

set_property PACKAGE_PIN T10 [get_ports {ca}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {ca}]

set_property PACKAGE_PIN R10 [get_ports {cb}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cb}]

set_property PACKAGE_PIN K16 [get_ports {cc}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cc}]

set_property PACKAGE_PIN K13 [get_ports {cd}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cd}]

set_property PACKAGE_PIN P15 [get_ports {ce}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {ce}]

set_property PACKAGE_PIN T11 [get_ports {cf}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cf}]

set_property PACKAGE_PIN L18 [get_ports {cg}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {cg}]

set_property PACKAGE_PIN H15 [get_ports dp]							
	set_property IOSTANDARD LVCMOS33 [get_ports dp]

set_property PACKAGE_PIN J17 [get_ports an0]
	set_property IOSTANDARD LVCMOS33 [get_ports an0]

set_property PACKAGE_PIN J18 [get_ports an1]
	set_property IOSTANDARD LVCMOS33 [get_ports an1]

set_property PACKAGE_PIN T9 [get_ports an2]
	set_property IOSTANDARD LVCMOS33 [get_ports an2]

set_property PACKAGE_PIN J14 [get_ports an3]
	set_property IOSTANDARD LVCMOS33 [get_ports an3]

set_property PACKAGE_PIN P14 [get_ports an4]
	set_property IOSTANDARD LVCMOS33 [get_ports an4]

set_property PACKAGE_PIN T14 [get_ports an5]
	set_property IOSTANDARD LVCMOS33 [get_ports an5]

set_property PACKAGE_PIN K2 [get_ports an6]
	set_property IOSTANDARD LVCMOS33 [get_ports an6]

set_property PACKAGE_PIN U13 [get_ports an7]
	set_property IOSTANDARD LVCMOS33 [get_ports an7]

set_property PACKAGE_PIN N17 [get_ports btnc]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnc]

set_property PACKAGE_PIN M18 [get_ports btnu]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnu]

set_property PACKAGE_PIN P17 [get_ports btnl]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnl]

set_property PACKAGE_PIN M17 [get_ports btnr]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnr]

set_property PACKAGE_PIN P18 [get_ports btnd]						
	set_property IOSTANDARD LVCMOS33 [get_ports btnd]

set_property PACKAGE_PIN A3 [get_ports {vga_red[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[0]}]

set_property PACKAGE_PIN B4 [get_ports {vga_red[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[1]}]

set_property PACKAGE_PIN C5 [get_ports {vga_red[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[2]}]

set_property PACKAGE_PIN A4 [get_ports {vga_red[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[3]}]

set_property PACKAGE_PIN B7 [get_ports {vga_blue[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[0]}]

set_property PACKAGE_PIN C7 [get_ports {vga_blue[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[1]}]

set_property PACKAGE_PIN D7 [get_ports {vga_blue[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[2]}]

set_property PACKAGE_PIN D8 [get_ports {vga_blue[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[3]}]

set_property PACKAGE_PIN C6 [get_ports {vga_green[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[0]}]

set_property PACKAGE_PIN A5 [get_ports {vga_green[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[1]}]

set_property PACKAGE_PIN B6 [get_ports {vga_green[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[2]}]

set_property PACKAGE_PIN A6 [get_ports {vga_green[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[3]}]

set_property PACKAGE_PIN B11 [get_ports vga_hsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]

set_property PACKAGE_PIN B12 [get_ports vga_vsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]
