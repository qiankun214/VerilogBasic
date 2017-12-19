import numpy as np


class node_data(object):
    """docstring for node_data"""

    def __init__(self, next_node, page_capacity_width=4):
        super(node_data, self).__init__()
        page_capacity = 2 ** page_capacity_width - 2
        self.data = np.zeros(page_capacity)
        self.next_node = next_node

    def __str__(self):
        return "next_node:%s" % self.next_node
