vlib work 
vlog -f list.txt
vsim -voptargs=+acc work.sys_tb
do wave.do
run -all