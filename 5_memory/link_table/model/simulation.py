from hardware_link_model import hardware_link_model
import numpy as np


def fifo_debug(model, addr):
    print("this:", addr, model.ram.data[addr])
    if model.ram.read_addr(addr) != addr:
        fifo_debug(model, model.ram.read_addr(addr))
    else:
        return


def ramdom_write(model):
    din = np.random.randn(2**4 - 2)
    model.write(din)

model = hardware_link_model()
model.initializer()

ramdom_write(model)
ramdom_write(model)
ramdom_write(model)
ramdom_write(model)

print(model.read())

print("empty_fifo")
fifo_debug(model, model.empty_addr_manager.start_addr)
print("data fifo")
fifo_debug(model, model.data_addr_manager.start_addr)
