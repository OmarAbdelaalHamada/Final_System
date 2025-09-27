onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sys_tb/DUT/UART_CLK
add wave -noupdate /sys_tb/DUT/RST
add wave -noupdate /sys_tb/DUT/RX_IN
add wave -noupdate /sys_tb/DUT/TX_OUT
add wave -noupdate /sys_tb/DUT/par_err
add wave -noupdate /sys_tb/DUT/stp_err
add wave -noupdate /sys_tb/DUT/strt_glitch
add wave -noupdate /sys_tb/DUT/rst_ref_domain
add wave -noupdate /sys_tb/DUT/RX_CLK
add wave -noupdate /sys_tb/DUT/TX_CLK
add wave -noupdate /sys_tb/DUT/TX_IN_V
add wave -noupdate /sys_tb/DUT/rst_uart_domain
add wave -noupdate /sys_tb/DUT/rinc
add wave -noupdate /sys_tb/DUT/RX_div_ratio
add wave -noupdate /sys_tb/DUT/busy
add wave -noupdate /sys_tb/DUT/WrEn
add wave -noupdate /sys_tb/DUT/RdEn
add wave -noupdate /sys_tb/DUT/RF_ADDR
add wave -noupdate /sys_tb/DUT/WrData
add wave -noupdate /sys_tb/DUT/RX_Out_to_Ctrl
add wave -noupdate /sys_tb/DUT/Reg0
add wave -noupdate /sys_tb/DUT/Reg1
add wave -noupdate /sys_tb/DUT/Reg2
add wave -noupdate /sys_tb/DUT/Reg3
add wave -noupdate /sys_tb/DUT/Sys_crtl_inst/current_state
add wave -noupdate /sys_tb/DUT/Sys_crtl_inst/next_state
add wave -noupdate /sys_tb/DUT/ALU_EN
add wave -noupdate /sys_tb/DUT/RdData
add wave -noupdate /sys_tb/DUT/TX_IN_from_fifo
add wave -noupdate /sys_tb/DUT/RdData_Valid
add wave -noupdate /sys_tb/DUT/ALU_FUNC
add wave -noupdate /sys_tb/DUT/ALU_OUT
add wave -noupdate /sys_tb/DUT/ALU_CLK
add wave -noupdate /sys_tb/DUT/OUT_VALID
add wave -noupdate /sys_tb/DUT/CLK_EN_GATE
add wave -noupdate /sys_tb/DUT/clk_div_en
add wave -noupdate /sys_tb/DUT/RX_P_VLD
add wave -noupdate /sys_tb/DUT/FIFO_FULL
add wave -noupdate /sys_tb/DUT/FIFO_EMPTY
add wave -noupdate /sys_tb/DUT/CLK
add wave -noupdate /sys_tb/DUT/RX_P_DATA
add wave -noupdate /sys_tb/DUT/WR_INC
add wave -noupdate /sys_tb/DUT/RX_Valid_to_Ctrl
add wave -noupdate /sys_tb/DUT/FIFO_inst/fifo_mem_inst/fifo_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16416057 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {104220913 ps}
