## 移位相减除法器

### 基本算法

与使用移位相加实现加法一样，移位减法可以实现除法，基本算法如下描述

1. 将除数向左移位直到比被除数大
2. 使用移位后的除数与被除数比较，若除数大，则商向左移位1位后末尾补0；若除数小，则被除数累减除数，商向左移位1位后末尾补1
3. 除数向右移位1位，重复2，知道除数小于原除数

### RTL代码

移位相减算法比较简单，一个Verilog模块即可描述

```verilog
module shiftsub_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [2 * WIDTH - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	input din_valid,

	output reg [2 * WIDTH - 1:0]dout,
	output reg [2 * WIDTH - 1:0]remainder
);
```

定义端口，其中`remainder`前`WIDTH`位均为0，可以不连接

```verilog
reg [3 * WIDTH - 1:0]divisor_lock;
reg [WIDTH - 1:0]divisor_ref;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{divisor_lock,divisor_ref} <= 'b0;
	end else if(din_valid == 1'b1) begin
		divisor_lock[3 * WIDTH - 1:2 * WIDTH] <= divisor;
		divisor_lock[WIDTH - 1:0] <= 'b0;
		divisor_ref <= divisor;
	end else if(divisor_lock >= '{divisor_ref}) begin
		divisor_lock <= divisor_lock >> 1;
		divisor_ref <= divisor_ref;
	end else begin
		divisor_lock <= divisor_lock;
		divisor_ref <= divisor_ref;
	end
end
```

`divisor_lock`为移位后的除数，宽度为`3 * WIDTH`是为了确保移位后的除数比被除数大。`divisor_ref`保存最初始除数的值，`divisor_lock >= '{divisor_ref}`为终止条件

```verilog
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		{remainder,dout} <= 'b0;
	end else if(din_valid == 1'b1) begin
		remainder <= dividend;
		dout <= 'b0;
	end else if((dout == 'b0) && (remainder < divisor_lock)) begin
		remainder <= remainder;
		dout <= dout;
	end else if(divisor_lock >= '{divisor_ref})begin
		if(remainder >= divisor_lock) begin
			remainder <= remainder - divisor_lock;
			dout <= {dout[2 * WIDTH - 2:0],1'b1};
		end else begin
			remainder <= remainder;
			dout <= {dout[2 * WIDTH - 2:0],1'b0};
		end
	end else begin
		{remainder,dout} <= {remainder,dout};
	end
end

endmodule
```

执行移位相减，其中`(dout == 'b0) && (remainder < divisor_lock)`是为了从除数恰好小于被除数时开始运算

### 测试

测试方法为随机产生数据，再使用Verilog自带的`/`和`%`运算符获取期待值后再与真实结果比较

```verilog
module tb_divider (
);

parameter WIDTH = 4;

logic clk;    // Clock
logic rst_n;  // Asynchronous reset active low
logic [2 * WIDTH - 1:0]dividend;
logic [WIDTH - 1:0]divisor;

logic din_valid;

logic [2 * WIDTH - 1:0]dout;
logic [2 * WIDTH - 1:0]remainder;

shiftsub_divider #(
	.WIDTH(WIDTH)
) dut (
	.clk(clk),    // Clock
	.rst_n(rst_n),  // Asynchronous reset active low

	.dividend(dividend),
	.divisor(divisor),

	.din_valid(din_valid),

	.dout(dout),
	.remainder(remainder)
);

//产生时钟信号
initial begin
	clk = 'b0;
	forever begin
		#50 clk = ~clk;
	end
end

//产生复位信号
initial begin
	rst_n = 1'b1;
	# 5 rst_n = 'b0;
	#10 rst_n = 1'b1;
end

logic [2 * WIDTH - 1:0]dout_exp;
logic [WIDTH - 1:0]remainder_exp;
initial begin
  	//初始化
	{dividend,divisor,din_valid} = 'b0;
	forever begin
		@(negedge clk);
      	//产生随机输入并启动
		dividend = (2 * WIDTH)'($urandom_range(0,2 ** (2 * WIDTH)));
		divisor = (WIDTH)'($urandom_range(1,2 ** WIDTH - 1));
		din_valid = 1'b1;
		
      	//计算期待结果
		remainder_exp = dividend % divisor;
		dout_exp = (dividend - remainder_exp) / divisor;

      	//等待运算结果
		repeat(4 * WIDTH) begin
			@(negedge clk);
			din_valid = 'b0;
		end
      
      	//期待结果与真实结果比较
		if((remainder == remainder_exp) && (dout_exp == dout)) begin
			$display("successfully");
		end else begin
			$display("failed");
		end
	end
end

endmodule
```

