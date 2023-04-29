# FPU-SP Single Precision #

This floating point unit is conform to IEEE 754-2008 standards. Supported operations are **compare**, **min-max**, **conversions**, **addition**, **subtruction**, **multiplication**, **fused multiply add**, **square root** and **division** in single precisions. Except **square root** and **division** all operations are pipelined.

This unit uses canonical **nan** (not a number) form, if it generates any **nan** as output. E.g. 0x7FC00000. Therefore extra conditions are added in order compare outputs with testfloat data correctly by **nan** generation.

**Square root** and **division** calculations are using same subunit but different path (algorithm). This subunit has a generic variable **_performance_**. For functional iterations which are fast please use **1** and fixed point iterations which are slow use **0**. This unit has also own multiplier.

## DESIGN ##

This floating point unit transform the single precision to the pseudo extended precision. The main benefit of this implementation is that the design needs few resources because we do not implement extension in pipeline to handle subnormal numbers. It means that all floating numbers are normalized thanks to pseudo extended precision.

|        | sign | exponent | mantissa |
|:------:|:----:|:--------:|:--------:|
| single | 1    | 8        | 23       |
| pseudo | 1    | 9        | 23       |

## LATENCY ##

| comp | max | conv | add | sub | mul | fma |
|:----:|:---:|:----:|:---:|:---:|:---:|:---:|
| 1    | 1   | 1    | 3   | 3   | 3   | 3   |

|performance| division | square root |
|:---------:|:--------:|:-----------:|
| 0         | 29       | 28          |
| 1         | 12       | 14          |

## TOOLS ##

The installation scripts of necessary tools are located in directory **tools**. These scripts need **root** permission in order to install packages and tools for simulation and testcase generation. Please run these scripts in directory **tools** locally.

## GENERATE ##

To generate test cases you could use following command:

```console
make generate
```

## SIMULATION ##

To simulate the design together with generated test cases you could run following command:

```console
make simulate
```

This command require two options **LANGUAGE** and **DESIGN**. The possible settings of these options can be found in the makefile.

An example execution of this command looks like as follows:

```console
make simulate LANGUAGE=verilog DESIGN=fpu
```

