# 1. Clear previous simulation work
vlib work
vlib msim
vlib msim/work

# 2. Compile Design and Testbench Files
vlog  ../rtl/program_counter.v
vlog  ../rtl/instruction_mem.v
vlog  ../rtl/data_mem.v
vlog  ../rtl/reg_file.v
vlog  ../rtl/alu.v
vlog  ../rtl/adder.v
vlog  ../rtl/alu_decoder.v
vlog  ../rtl/main_decoder.v
vlog  ../rtl/control.v
vlog  ../rtl/extend.v
vlog  ../rtl/riscv_single.v
vlog  ../tb/tb_riscv_single.v

# 3. Start Simulation
vsim -voptargs=+acc work.tb_riscv_single

# 4. Add Waves to Wave Window
add wave -position insertpoint sim:/tb_riscv_single/dut/*

# 5. Run Simulation
run -all
