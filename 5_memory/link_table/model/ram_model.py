from node_data import node_data


class ram_model(object):
    """docstring for ram_model"""

    def __init__(self, cap):
        super(ram_model, self).__init__()
        self.data = [node_data(0) for _ in range(2 ** cap)]

    def read(self, addr):
        return self.data[addr]

    def write(self, addr, data):
        self.data[addr] = data

    def read_addr(self, addr):
        return self.data[addr].next_node

    def write_addr(self, addr, data):
        self.data[addr].next_node = data
