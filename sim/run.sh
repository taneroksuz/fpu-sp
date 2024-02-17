#!/bin/bash
set -e

if [ "${VERILOG}" == "1" ]
then

  . ${BASEDIR}/sim/test_fpu_verilog.sh

fi

if [ "${VHDL}" == "1" ]
then

  . ${BASEDIR}/sim/test_fpu_vhdl.sh

fi