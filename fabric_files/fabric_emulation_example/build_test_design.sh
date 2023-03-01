#!/usr/bin/env bash

SYNTH_TCL=../../fabric_cad/synth/synth_fabulous.tcl
BIT_GEN=../../fabric_cad/bit_gen.py

if [[ -z "${DESIGN}" ]]; then
	DESIGN=blinky
fi

set -ex
yosys -qp "synth_fabulous -carry ha -top top_wrapper -json test_design/${DESIGN}.json" test_design/${DESIGN}.v test_design/top_wrapper.v

FAB_ROOT=../../fabric_generator nextpnr-generic --seed 20 --uarch fabulous --json test_design/${DESIGN}.json -o fasm=test_design/${DESIGN}_des.fasm
python3 ${BIT_GEN} -genBitstream test_design/${DESIGN}_des.fasm ../../fabric_generator/npnroutput/meta_data.txt test_design/${DESIGN}.bin
