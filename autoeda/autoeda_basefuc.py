import re
# import os


class autoeda_file_handle(object):
    """docstring for autoeda_file_handle"""

    def __init__(self):
        super(autoeda_file_handle, self).__init__()

    def bfuc_read_file(self, file_path):
        """read the file and return list"""
        with open(file_path, 'r') as file_point:
            print("reading the file...successfully")
            self.file_content = self.bfuc_remove_comments(
                file_point.readlines())
            return self.file_content

    def bfuc_write_file(self, file_path, content):
        """write the file"""
        with open(file_path, 'w') as file_point:
            file_point.write("".join(content))
            print("write the file %s successfully" % file_path)

    def bfuc_remove_comments(self, source):
        tmp_content, remove_flag = [], 0
        for row in source:
            if "/*" in row:
                remove_flag = 1
            elif remove_flag == 0:
                row = re.sub(r"\s*//.*", "", row)
                if len(row) != 0 and row != "\n":
                    tmp_content.append(row)
            elif "*/" in row:
                remove_flag = 0
        return tmp_content


class autoeda_base_analysis(object):
    """docstring for autoeda_base_analysis"""

    def __init__(self):
        super(autoeda_base_analysis, self).__init__()
        self.file_content = None
        self.module_head = None
        self.module_name = None
        self.port_list = None
        self.params_dict = None

    def bfuc_get_module_head(self, force_refresh=False):
        if force_refresh is False and self.module_head is not None:
            return self.module_head
        flag, head_list = 0, []
        for file_row in self.file_content:
            if re.match(r"\bmodule\b", file_row) is not None:
                flag = 1
                head_list.append(file_row.replace("\n", ""))
            elif re.match(r"\);", file_row) is not None and flag == 1:
                self.module_head = head_list
                return self.module_head
            elif flag == 1:
                head_list.append(file_row.replace("\n", ""))

    def bfuc_get_params(self, force_refresh=False):
        if self.params_dict is not None and force_refresh is False:
            return self.params_dict
        else:
            self.params_dict = {}
            self._check_head_exsist()
        for head_row in self.module_head:
            param_line = re.match(
                r"\s*parameter\s+(\w+)\s*=\s*([\w\']+)", head_row)
            if param_line is not None:
                self.params_dict[param_line.group(1)] = \
                    self._verilog_str2int(param_line.group(2))
                # print(param_line.groups(), head_row)
        return self.params_dict

    def bfuc_get_ports(self, force_refresh=False):
        if self.port_list is not None and force_refresh is False:
            return self.port_list
        else:
            self.port_list = []
        self._check_head_exsist()
        self._check_params_exsist()
        for head_row in self.module_head:
            port = re.match(
                r"\s*(input|output reg|inout|output)\s*(\[.*?\])*\s*([\w,]+)",
                head_row)
            if port is not None:
                self._port_handle(port.groups())
                # print(port.groups())
        return self.port_list

    def bfuc_get_module_name(self, force_refresh=False):
        if force_refresh is False and self.module_name is not None:
            return self.module_name
        self._check_head_exsist()
        name = re.match(r"\s*module\s+(\w+)", self.module_head[0])
        self.module_name = name.group(1)
        return self.module_name

    def _verilog_str2int(self, x):  # not finish
        if x.isdigit() is True:
            return int(x)
        else:
            x = re.match(r"\w*\'([dbho])(\w+)", x)
            int_dict = {"d": 10, "h": 16, "o": 8, "b": 2}
            print(x.groups())
            return int(x.group(2), int_dict[x.group(1)])

    def _port_handle(self, port_info):
        # new_type = re.sub(r"\s*reg", "", port_info[0])
        for port_name in port_info[-1].strip().split(","):
            port_name = port_name.strip()
            if len(port_name) != 0:
                self.port_list.append(
                    {'name': port_name,
                     'type': port_info[0],
                     'width': self._width_compute(port_info[1]),
                     'width_source': self._width_source_gen(port_info[1])})
                print("find %sbit %s port:%s" %
                      (self.port_list[-1]["width"], port_info[0], port_name))

    def _check_head_exsist(self):
        if self.module_head is None:
            print("head_list not happend,auto do it")
            self.bfuc_get_module_head()

    def _check_params_exsist(self):
        if self.params_dict is None:
            print("params_dict not happend,auto do it")
            self.bfuc_get_params()

    def _width_compute(self, width_info):
        if width_info is None:
            return 1
        for keys in self.params_dict:
            locals()[keys] = self.params_dict[keys]
        return eval(width_info[1:-1].replace(":", "-")) + 1

    def _width_source_gen(self, width_info):
        if width_info is not None:
            return width_info
        else:
            return ""
