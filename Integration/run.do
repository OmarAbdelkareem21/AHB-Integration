vlib work 
vlog -f sourcefile.txt
vsim -voptargs=+accs work.Top_tb
add wave *
run -all