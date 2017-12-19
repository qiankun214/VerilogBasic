import numpy as np
from node_data import node_data
from addr_manager import addr_manager
from ram_model import ram_model


class hardware_link_model(object):
    """docstring for hardware_link_model"""

    def __init__(self, ram_cap=8):
        super(hardware_link_model, self).__init__()
        self.ram = ram_model(ram_cap)
        self.data_addr_manager = addr_manager(start=0, final=0)
        self.empty_addr_manager = addr_manager(start=0, final=2 ** ram_cap - 1)
        self.ram_cap = 2 ** ram_cap

    def initializer(self):
        for i in range(self.ram_cap - 1):
            self.ram.write(i, node_data(i + 1))
        self.ram.write(self.ram_cap - 1, node_data(self.ram_cap - 1))

    def write(self, din):
        # Apply for empty node A from empty FIFO
        node_addr = self.empty_addr_manager.start_addr

        # Read next node address of the node A
        next_node_addr = self.ram.read_addr(node_addr)
        self.empty_addr_manager.update_start(next_node_addr)

        # Write data in the node A
        node = node_data(node_addr)
        node.data = din
        self.ram.write(node_addr, node)

        # Append node A to data FIFO
        last_final_addr = self.data_addr_manager.final_addr
        self.ram.write_addr(last_final_addr, node_addr)
        self.data_addr_manager.update_final(node_addr)

    def read(self):
        # Apply for data node A from empty FIFO
        node_addr = self.data_addr_manager.start_addr

        # Read next node address of the node A
        next_node_addr = self.ram.read_addr(node_addr)
        self.data_addr_manager.update_start(next_node_addr)

        # Write next node addr of node A
        self.ram.write_addr(node_addr, node_addr)

        # Read data in the node A
        node = self.ram.read(node_addr)

        # Append node A to empty FIFO
        last_final_addr = self.empty_addr_manager.final_addr
        self.ram.write_addr(last_final_addr, node_addr)
        self.empty_addr_manager.update_final(node_addr)

        return node.data
