class ROMGenerator(object):
    """docstring for ROMGenerator"""

    def __init__(self, Width):
        super(ROMGenerator, self).__init__()
        self.Width = Width

    def GeneratorROM(self, FileName):
        RomContent = ["""
module ROM_%s (
    input [%s:0]addr,
    output reg [%s:0]dout
);

always @(*) begin
    case(addr)\
""" % (self.Width, self.Width * 2 - 1, self.Width * 2 - 1)]
        for i in range(2 ** self.Width):
            for j in range(2 ** self.Width):
                RomContent.append(
                    "\t\t%s\'d%s:dout = %s\'d%s;" %
                    (2 * self.Width, i * (2 ** self.Width) + j,
                        2 * self.Width, i * j))
        RomContent.append("""\t\tdefault:dout = \'b0;
    endcase
end
endmodule
""")
        with open("./%s.v" % FileName, "w") as filepoint:
            filepoint.write("\n".join(RomContent))
        return "\n".join(RomContent)

if __name__ == '__main__':
    test = ROMGenerator(4)
    print(test.GeneratorROM("ROM_4"))
