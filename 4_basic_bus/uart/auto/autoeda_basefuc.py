import re
import os


class autoeda_module_analysis(object):
    """docstring for autoeda_basefuc"""

    def __init__(self):
        super(autoeda_module_analysis, self).__init__()
        self.file_content = None
        self.module_head = None
        self.module_name = None
        self.port_list = None
        self.params_dict = None

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

    def gen_doc(self):
        doc_list = [self._gen_doc_headcomment()]
        doc_list.append(self._gen_doc_headline(
            "report of %s" % self.module_name, 1))
        doc_list.append(self._gen_doc_headline("Abstract", 2))
        doc_list.append("- module name:%s" % self.module_name)
        doc_list.append(self._gen_doc_headline("Ports", 2))
        doc_list.append(self._gen_doc_porttable())
        doc_list.append(self._gen_doc_headline("Parameters", 2))
        doc_list.append(self._gen_doc_paramstable())
        # print(doc_list)
        print("generate the report of %s" % self.module_name)
        return "\n".join(doc_list)

    def _gen_doc_headcomment(self):
        return "---\nreport generated by autoeda_basefuc\n---"

    def _gen_doc_headline(self, content, h_step):
        headline = ["#" for _ in range(h_step)]
        headline.append(" %s" % content)
        return "".join(headline)

    def _gen_doc_paramstable(self):
        param_doc = ["| name | default data | description |",
                     "| ---- | ------------ | ----------- |"]
        for keys in self.params_dict:
            param_doc.append("| %s | %s |   |" %
                             (keys, self.params_dict[keys]))
        return "\n".join(param_doc)

    def _gen_doc_porttable(self):
        port_table = [
            "| name | type | default width | width expression | description |",
            "| ---- | ---- | --------- | ----------- | ------- |"]
        for port_info in self.port_list:
            port_table.append("| %s | %s | %s |  %s  |   |" % (
                port_info["name"],
                self._port_type_handle(port_info["type"]),
                port_info["width"],
                self._gen_doc_width_source(port_info["width_source"])))
        return "\n".join(port_table)

    def _gen_doc_width_source(self, x):
        if len(x) == 0:
            return "constant 1"
        x = x[1:-1].split(":")
        if x[-1].strip() == "0":
            if re.search(r"\s*\-\s*1\s*", x[0]) is not None:
                # print(x)
                return re.sub(r"\s*\-\s*1\s*", "", x[0])
            else:
                return "".join([x[0], " + 1"])
        else:
            return " ".join([x[0], "-", x[1], "+ 1"])

    def _port_type_handle(self, x):
        if "reg" in x:
            return "output"
        else:
            return x

    def __call__(self, file_path, doc_path="."):
        self.__init__()
        self.bfuc_read_file(file_path)
        self.bfuc_get_ports()
        self.bfuc_get_module_name()
        self.bfuc_write_file(os.path.join(
            doc_path, "report_%s.md" % self.module_name), self.gen_doc())

if __name__ == '__main__':
    test = autoeda_module_analysis()
    # test.bfuc_read_file("./spi_config.v")
    # test.bfuc_get_ports()
    # for x in test.port_list:
    #     print(x)
    # print(test.params_dict)
    # print("".join(test.file_content))
    # print(test.bfuc_get_module_name())
    test("./spi_config.v")
