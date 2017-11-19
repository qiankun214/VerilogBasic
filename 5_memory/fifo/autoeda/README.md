# AutoEDA：python in EDA

## Abstract

autoeda is a bunch of python scripts which can complete  “physical work” automatically，the "physical work" include:

- analysis ports and the parameter of Verilog file and generate the document
- generate the template of component instantiation
- generate the template of sdc file of Design Compiler
- generate testbench which can instantiate dut and generate the clock, reset signal automatically



## How to use it

### generate the document of a Veriog file

```shell
python3 autoeda.py -a -s <source.v> -t <target.md>
```

### generate the instantiation template

```shell
python3 autoeda.py -m -s <source.v> -t <target.v> (-o <source.json>)
```

If you just want to generate the template for a file, you can use "-s \<source.v\>".But if you need to generate templates for many files, you should use "-o \<source.json\>" and the "-s " would be ignored.What is in JSON file is a Dict of "instantiation name: file path"(without test).

### generate the testbench

```shell
python3 autoeda.py -b <source.v> -t <target.sv> (-o <option>)
```

If you want to add the code dumping fsdb or vcd file in your testbench,you can include "fsdb" or "vcd" in \<option\>.For example,"-o fsdbvcd" makes the testbench can generate dump fsdb and vcd 

### generate the sdc template

```shell
python3 autoeda.py -c <source.v> -t <target.sdc> (-o <option.json>)
```

You need not use "-o \<option\>" if your design is a single-clock circuit. If you want to generate an sdc for a multi-clock design, you need a JSON file like {"\<clock name\>":"\<port list\>"} to point out the relationship of the ports and clock.