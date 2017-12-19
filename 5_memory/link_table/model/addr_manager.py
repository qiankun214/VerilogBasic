class addr_manager(object):
    """docstring for addr_manager"""

    def __init__(self, start, final):
        super(addr_manager, self).__init__()
        self.start_addr = start
        self.final_addr = final

    def update_start(self, data):
        self.start_addr = data

    def update_final(self, data):
        self.final_addr = data
