# from softe_model import soft_model
import numpy as np
import serial
import time

class uart_driver(object):
    """docstring for uart_driver"""

    def __init__(self, com, baud):
        super(uart_driver, self).__init__()
        self.port = serial.Serial(com, baud)

    def write(self, data):
        print("sending", [hex(i) for i in data])
        for i in data:
            self.port.write([i])
            # self.port.flushOutput()

    def read(self, num):
        return self.port.read(num)


class vector_apply(object):
    """docstring for vector_apply"""

    def __init__(self, driver):
        super(vector_apply, self).__init__()
        self.driver = driver
        self.bit = 6

    def compute(self, step):
        self.driver.write(self._order_pkg(step))
        # print(self._order_pkg(step))
        result = self.driver.read(4)
        return self._result_unpkg(result)

    def _result_unpkg(self,data):
        # print(data)
        result = sum([data[i] * (2 ** (i * 8)) for i in range(4)])
        # print(result)
        if result > 2 ** 31:
            return (result - 2 ** 32) / 2 ** (2 * self.bit)
        else:
            return result / 2 ** (2 * self.bit)

    def _data_pkg(self, data, start):
        data_send = [0, start % 256, start // 256, data.shape[0] // 4]
        for i in data:
            data_send.append(self._data_bit_pkg(i))
        return data_send

    def _data_bit_pkg(self,data):
        return data

    def set_data(self,indata):
        # weight = self._data_pkg(weight, 128)
        indata = self._data_pkg(indata, 0)
        # self.driver.write(weight)
        self.driver.write(indata)

    def _order_pkg(self, length=4):
        return [0x0f, length // 4 - 1]

if __name__ == '__main__':
    driver = uart_driver("COM7", 9600)
    test = vector_apply(driver)
    # a = np.arange(64) * 0.01
    a = np.arange(4)
    # b = -a * 0.5
    for i in range(40):
        test.set_data(a)
        # time.sleep(0.1)
        print([x for x in test.driver.read(4)])
        print(i)
        # temp = test.compute(8)
        # print(temp)
        # print((temp[2] * (2**16) + temp[1] * (2 ** 8) + temp[0]) / 2 ** 12)
        # time.sleep(1)
