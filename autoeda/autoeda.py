import sys
import getopt
from autoeda_utils import generate_template_option, package_template_option
from autoeda_module_analysis import autoeda_module_analysis
from autoeda_template import autoeda_component_template_generator
from autoeda_testbench import autoeda_testbench_generator
from autoeda_sdc import autoeda_sdc_template_generator

help_message = """autoeda created by qiankun
python3 autoeda.py mode options target_path
mode:
    -a generate doc(markdown)
    -m generate template
    -b generate testbench
    -c generate sdc template
    -h print help message
options:
    -s/--source= source_file_path
    -t/--target= target_file_path
    -o/--other= other parameter
"""

mode, _ = getopt.getopt(
    sys.argv[1:], "ambchs:t:o:", [
        "a", "m", "b", "c", "h", "source=", "target=", "other="])
# file_message, _ = getopt.getopt(sys.argv[1:], "", )

source_path = None
target_path = None
other_parameter = None
for name, value in mode:
    if name in ("-s", "--source"):
        source_path = value
    elif name in ("-t", "--target"):
        target_path = value
    elif name in ("-o", "--other"):
        other_parameter = value

for name, value in mode:
    if name == "-a":
        order = autoeda_module_analysis()
        order(source_path, target_path)
    elif name == "-m":
        order = autoeda_component_template_generator()
        if other_parameter is not None:
            param_dict = generate_template_option(other_parameter)
        else:
            param_dict = package_template_option(source_path)
        order(param_dict, target_path)
    elif name == "-b":
        order = autoeda_testbench_generator()
        if other_parameter is None:
            order(source_path, target_path)
        else:
            if "fsdb" in other_parameter:
                fsdb = True
            else:
                fsdb = False
            if "vcd" in other_parameter:
                vcd = True
            else:
                vcd = False
            order(source_path, target_path, fsdb=fsdb, vcd=vcd)
    elif name == "-c":
        order = autoeda_sdc_template_generator()
        if other_parameter is None:
            order(source_path, sdc_path=target_path)
        else:
            order(source_path, generate_template_option(
                other_parameter), target_path)
    elif name == "-h":
        print(help_message)
    # else:
        # print("undefine order %s" % name)
