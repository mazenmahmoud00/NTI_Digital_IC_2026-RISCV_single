vlib work
vlib msim
vlib msim/work

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

vsim -voptargs=+acc work.tb_riscv_single

add wave -position insertpoint sim:/tb_riscv_single/dut/*

run -all
