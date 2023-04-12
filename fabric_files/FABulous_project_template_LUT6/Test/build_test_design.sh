#!/usr/bin/env bash
SYNTH_TCL=../../fabric_cad/synth/synth_fabulous.tcl
BIT_GEN=../../fabric_cad/bit_gen.py

DESIGN=counter

set -ex
yosys -qp "synth_fabulous -lut 6 -top top_wrapper -json test_design/${DESIGN}.json" test_design/${DESIGN}.v test_design/top_wrapper.v

FAB_ROOT=.. nextpnr-generic --uarch fabulous --json test_design/${DESIGN}.json -o fasm=test_design/${DESIGN}_des.fasm -o lut_k=6
python3 ${BIT_GEN} -genBitstream test_design/${DESIGN}_des.fasm ../.FABulous/bitStreamSpec.bin test_design/${DESIGN}.bin
