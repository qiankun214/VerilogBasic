from autoeda_template import autoeda_component_template_generator
import json


class autoeda_component_link(autoeda_component_template_generator):
    """docstring for autoeda_component_link"""

    def __init__(self):
        super(autoeda_component_link, self).__init__()

    def __call__(self, source_path_dict,
                 module_name="<module>",
                 target_path="./template.v",
                 simple_signal_tuple=("clk", "rst_n"),
                 ignore_signal_tuple=(),
                 extra_signal_tuple=(),
                 connection_dict={},
                 config_json=None
                 ):
        self._init_linker(simple_signal_tuple, ignore_signal_tuple,
                          extra_signal_tuple, connection_dict, config_json)
        content = []
        for key in source_path_dict:
            content.append(self.link_component_gen(
                key, **source_path_dict[key]))
        content = [self.link_wire_define()] + content
        content = [self.link_add_module_head(
            module_name)] + content + ["endmodule\n"]
        self.bfuc_write_file(target_path, "\n\n".join(content))

    def _init_linker(self, simple_signal_tuple, ignore_signal_tuple,
                     extra_signal_tuple, connection_dict, config=None):
        if config is None:
            self.simple_signal_tuple = simple_signal_tuple
            self.ignore_signal_tuple = ignore_signal_tuple
            self.extra_signal_tuple = extra_signal_tuple
            self.connection_dict = connection_dict
        else:
            with open(config, "r") as f:
                config_dict = json.load(f)
            self.simple_signal_tuple = config_dict['simple_signal_tuple']
            self.ignore_signal_tuple = config_dict['ignore_signal_tuple']
            self.extra_signal_tuple = config_dict['extra_signal_tuple']
            self.connection_dict = config_dict['connection_dict']
        self.input_signal_dict = dict()
        self.output_signal_dict = dict()
        self.inout_signal_dict = dict()
        self.param_signal_dict = dict()

    def link_component_gen(self, name, path, num=0):
        self.__init__()
        self.bfuc_read_file(path)
        self.bfuc_get_module_name()
        self.bfuc_get_ports()
        self.get_wire_dict(num)
        self._collect_param()
        return "\n".join([self.tp_module_instances(
            port_connection_mode=self._port_signal_gen(i),
            param_connection_mode=None,
            instance_name="u_%s_%s" % (name, i)) for i in range(num)])

    def get_wire_dict(self, num):
        for port in self.port_list:
            if "input" in port["type"]:
                for i in range(num):
                    self.input_signal_dict[self._port_signal_gen(i)(
                        port["name"])] = port["width_source"]
            elif "output" in port["type"]:
                for i in range(num):
                    self.output_signal_dict[self._port_signal_gen(i)(
                        port["name"])] = port["width_source"]
            else:
                for i in range(num):
                    self.inout_signal_dict[self._port_signal_gen(i)(
                        port["name"])] = port["width_source"]

    def _collect_param(self):
        for param in self.params_dict:
            self.param_signal_dict[param] = self.params_dict[param]

    def _port_signal_gen(self, num):
        def add_num_after_signalname(x):
            if num == 0 or x in self.simple_signal_tuple:
                return x
            else:
                return "%s_%s" % (x, num)
        return add_num_after_signalname

    def link_wire_define(self):
        wire_define_list = []
        connected_signal_list = []
        for key in list(self.input_signal_dict.keys()):
            connection_signal, signal_type = self._is_connection_inside(key)
            if key == connection_signal:
                wire_define_list.append(
                    self._define_wire(
                        connection_signal, "input", connected_signal_list))
                connected_signal_list.append(connection_signal)
                self._delete_wire(key)
            elif connection_signal is not None:
                wire_define_list.append(
                    self._assign_wire(
                        key, connection_signal,
                        signal_type, tuple(connected_signal_list)))
                connected_signal_list.append(connection_signal)
                self._delete_wire(key)
        wire_define_list.append(self._handle_ignore_signal())
        self._delete_connected_signal(
            connected_signal_list + list(self.ignore_signal_tuple))
        return "\n".join(wire_define_list)

    def _is_connection_inside(self, signal_name):
        connection_name = self._get_connection_name(signal_name)
        if connection_name in self.ignore_signal_tuple:
            return None, None
        elif self.output_signal_dict.get(connection_name) is not None:
            return connection_name, "output"
        elif self.inout_signal_dict.get(connection_name) is not None:
            return connection_name, "inout"
        else:
            return None, None

    def _define_wire(self, port_name, signal_type, connected_signal_list=()):
        if port_name not in self.extra_signal_tuple and \
                port_name not in connected_signal_list:
            if signal_type == "output":
                return "wire %s%s;" % (
                    self.output_signal_dict[port_name], port_name)
            elif signal_type == "inout":
                return "wire %s%s;" % (
                    self.inout_signal_dict[port_name], port_name)
            else:
                return "wire %s%s;" % (
                    self.input_signal_dict[port_name], port_name)
        else:
            return "// needn'd to define %s" % port_name

    def _assign_wire(self, signal_name1, signal_name2, signal_type,
                     connected_signal_list=()):
        return "\n".join([
            "\n// need to connect %s with %s" % (signal_name1, signal_name2),
            self._define_wire(signal_name1, "input", connected_signal_list),
            self._define_wire(signal_name2, signal_type,
                              connected_signal_list),
            "assign %s = %s%s;\n" % (signal_name1, signal_name2,
                                     self.input_signal_dict[signal_name1])])

    def _delete_wire(self, key):
        if key not in self.extra_signal_tuple:
            del self.input_signal_dict[key]

    def _get_connection_name(self, signal_name):
        if self.connection_dict.get(signal_name) is not None:
            return self.connection_dict[signal_name]
        else:
            return signal_name

    def _handle_ignore_signal(self):
        ignore_signal_define = []
        for signal in self.ignore_signal_tuple:
            print("ignore signal:", signal)
            if self.input_signal_dict.get(signal) is not None:
                ignore_signal_define.append("error:ignore input signal")
                ignore_signal_define.append(self._define_wire(signal, "input"))
            elif self.output_signal_dict.get(signal) is not None:
                ignore_signal_define.append(
                    self._define_wire(signal, "output"))
            elif self.inout_signal_dict.get(signal) is not None:
                ignore_signal_define.append(self._define_wire(signal, "inout"))
        return "\n".join(ignore_signal_define)

    def _delete_connected_signal(self, connected_signal_list):
        for signal in connected_signal_list:
            if signal not in self.extra_signal_tuple:
                if self.output_signal_dict.get(signal) is not None:
                    del self.output_signal_dict[signal]
                elif self.inout_signal_dict.get(signal) is not None:
                    del self.inout_signal_dict[signal]

    def link_add_module_head(self, module_name):
        if len(self.param_signal_dict) != 0:
            head_data = ["module %s #(" % module_name]
            head_data.append(self.link_parameter_define())
            head_data.append(") (")
        else:
            head_data = ["module %s (" % module_name]
        head_data.append(self.link_module_port_define())
        head_data.append(");")
        return "\n".join(head_data)

    def link_parameter_define(self):
        return ",\n".join(
            ["\tparameter %s = %s" % (x, self.param_signal_dict[x])
             for x in self.param_signal_dict])

    def _type_handle(self, x):
        if "output" in x:
            return "output"
        else:
            return x

    def link_module_port_define(self):
        port_define_list = ["\tinput %s%s" % (
            self.input_signal_dict[i], i) for i in self.input_signal_dict]
        port_define_list += ["\toutput %s%s" % (
            self.output_signal_dict[i], i) for i in self.output_signal_dict]
        port_define_list += ["\tinout %s%s" % (
            self.inout_signal_dict[i], i) for i in self.inout_signal_dict]
        return ",\n".join(port_define_list)
if __name__ == '__main__':
    test = autoeda_component_link()
    # test_dict = {"uart": {"path": "../src/uart_interface.v", "num": 1},
    #              "ram": {"path": "../src/pkg_simple_ram.v", "num": 1},
    #              "pro": {"path": "../src/test_pro.v", "num": 1},
    #              "regs_group": {"path": "../src/regs_group.v", "num": 1}
    #              }
    test_dict = {
        # "dataflow": {"path": "../src/dataflow.v", "num": 1},
        # "controller": {"path": "../src/processor_controller.v", "num": 1}
        "low_to_high":{"path":'low_to_high.v',"num":1},
        "high_to_low":{"path":"high_to_low.v","num":1}
    }
    ignore_signal_tuple = (
        "send_busy",
    )
    extra_signal_tuple = (
        # "order",
    )
    connection_dict = {
        "send_data": "regs_read_data1",
        "ram_addr": "regs_read_data1",
        "ram_data": "regs_read_data2",
        "ram_to_regs": "ram_q",
        "uart_to_regs": "order"
    }
    test(
        test_dict,
        module_name="bus_decode",
        target_path="bus_decode.v",
        # ignore_signal_tuple=ignore_signal_tuple,
        # extra_signal_tuple=extra_signal_tuple,
        # connection_dict=connection_dict
    )
    # print(test.input_signal_dict)
    # print(test.output_signal_dict)
