from autoeda_basefuc import autoeda_file_handle, autoeda_base_analysis


class autoeda_component_template_generator(autoeda_file_handle,
                                           autoeda_base_analysis):
    """docstring for autoeda_component_template_generator"""

    def __init__(self):
        super(autoeda_component_template_generator, self).__init__()

    def __call__(self, source_path_dict,  template_path="./template.v",
                 port_connection_mode=None, param_connection_mode=None,):
        template_content = []
        for key in source_path_dict:
            self.__init__()
            self.bfuc_read_file(source_path_dict[key])
            self.bfuc_get_module_name()
            self.bfuc_get_ports()
            template_content.append(
                self.tp_module_instances(
                    port_connection_mode=port_connection_mode,
                    param_connection_mode=param_connection_mode,
                    instance_name="u_%s" % key))
        self.bfuc_write_file(template_path, "\n\n".join(template_content))

    def tp_module_instances(self, modult_info=None, instance_name="dut",
                            param_connection_mode=None,
                            port_connection_mode=None, indent=""):
        if modult_info is None:
            module_name, params_dict, port_list = \
                self.module_name, self.params_dict, self.port_list
        else:
            module_name, params_dict, port_list = modult_info
        if len(params_dict) == 0:
            module_content = ["%s%s %s (" % (
                module_name, indent, instance_name)]
        else:
            module_content = ["%s%s #(" % (module_name, indent)]
            module_content.append(self.tp_param_instances(
                params_dict, connection_mode=param_connection_mode,
                indent=indent + "\t"))
            module_content.append("%s) %s (" % (indent, instance_name))
        module_content.append(self.tp_port_instances(
            port_list, connection_mode=port_connection_mode,
            indent="\t" + indent))
        module_content.append("%s);" % indent)
        return "\n".join(module_content)

    def tp_param_instances(self, params_dict=None,
                           connection_mode=None, indent="\t"):
        if params_dict is None:
            params_dict = self.params_dict
        if connection_mode is None:
            connection_mode = self._same_name_connection
        param_list = []
        longist = self._get_longest_string([x for x in params_dict])
        for param in params_dict:
            param_list.append("%s.%s(%s)," %
                              (indent, param.ljust(longist),
                               connection_mode(param)))
        return "\n".join(param_list)[:-1]

    def tp_port_instances(self, port_list=None,
                          connection_mode=None, indent="\t"):
        if port_list is None:
            port_list = self.port_list
        if connection_mode is None:
            connection_mode = self._same_name_connection
        port_instance_list = []
        longist = self._get_longest_string([x["name"] for x in port_list])
        for port in port_list:
            port_instance_list.append("%s.%s(%s)," % (
                indent, port["name"].ljust(longist),
                connection_mode(port["name"])))
        return "\n".join(port_instance_list)[:-1]

    def _get_longest_string(self, str_list):
        return max([len(x) for x in str_list])

    def _same_name_connection(self, x):
        return x

if __name__ == '__main__':
    test = autoeda_component_template_generator()
    test_dict = {"config": "./test/spi_config.v",
                 "config_2": "./test/spi_config.v"}
    test(test_dict, port_connection_mode=lambda x: "<connection %s>" % x)
