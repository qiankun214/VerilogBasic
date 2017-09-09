## 恢复余数除法器

### 算法描述

恢复余数除法器是一种常用的除法器，过程与手算除法的方法很类似，过程为

1. 将除数向左位移直到比被除数大
2. 执行被除数减除数操作，得余数，并将商向左移位1位，空位补1
3. 若余数大于0，除数向右移位1位。如余数小于0，余数加当前除数，商最后一位置0，除数向右移位1位
4. 重复到2，只到除数比最初的除数小

### RTL代码

RTL代码就是使用了大量的`if`语句完成了以上的算法描述，其中

- 为了使移位后的除数确保大于被除数，直接将除数放到一个位宽WIDTH*3的寄存器的前WIDTH位
- `divisor_move >= '{divisor_lock}`用于当移位除数小于原除数时停止
- `(divisor_move > '{remainder_r}) && (dout == 'b0)`用于当出现第一个1时才开始保存结果

```verilog
module restore_divider #(
	parameter WIDTH = 4
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	input [WIDTH * 2 - 1:0]dividend,
	input [WIDTH - 1:0]divisor,

	input din_valid,

	output reg [2 * WIDTH - 1:0]dout,
	output [WIDTH - 1:0]remainder
);

reg [2 * WIDTH:0]remainder_r;
reg [3 * WIDTH - 1:0]divisor_move;
reg [WIDTH - 1:0]divisor_lock;
always @ (posedge clk or negedge rst_n) begin
	if(~rst_n) begin
      	//初始化
		{remainder_r,divisor_lock,divisor_move,dout} <= 'b0;
	end else begin
		if(din_valid == 1'b1) begin	
          	//锁存输入，3倍WIDTH的宽度用于保证移位后的除数大于被除数
			remainder_r[WIDTH * 2 - 1:0] <= dividend;
			remainder_r[2 * WIDTH] <= 'b0;
			divisor_move[3 * WIDTH - 1:2 * WIDTH] <= divisor;
			divisor_move[2 * WIDTH - 1:0] <= 'b0;
			divisor_lock <= divisor;
			dout <= 'b0;
		end else if((divisor_move > '{remainder_r}) && (dout == 'b0)) begin
			//开始条件
          	 remainder_r <= remainder_r;
			dout <= 'b0;
			divisor_move <= divisor_move >> 1;
			divisor_lock <= divisor_lock;
		end else if(divisor_move >= '{divisor_lock}) begin
          	if(remainder_r[2 * WIDTH] == 1'b0) begin //执行减法
				remainder_r <= remainder_r - divisor_move;
				dout <= {dout[2 * WIDTH - 2:0],1'b1};
				// divisor_move <= divisor_move >> 1;
				divisor_lock <= divisor_lock;
				if(remainder_r >= divisor_move) begin
					divisor_move <= divisor_move >> 1;
				end else begin
					divisor_move <= divisor_move;
				end
			end else begin	//恢复余数
				remainder_r <= remainder_r + divisor_move;
				dout <= {dout[2 * WIDTH - 1:1],1'b0};
				divisor_move <= divisor_move >> 1;
				divisor_lock <= divisor_lock;
			end
		end else begin
			remainder_r <= remainder_r;
			divisor_lock <= divisor_lock;
			divisor_move <= divisor_move;
			dout <= dout;
		end
	end
end

assign remainder = remainder_r[WIDTH - 1:0];

endmodule
```

### 测试平台

测试平台复用了shiftsub除法器的平台，增加了“遇错停止”的功能

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
logic [WIDTH - 1:0]remainder;

restore_divider #(
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

initial begin
	clk = 'b0;
	forever begin
		#50 clk = ~clk;
	end
end

initial begin
	rst_n = 1'b1;
	# 5 rst_n = 'b0;
	#10 rst_n = 1'b1;
end

logic [2 * WIDTH - 1:0]dout_exp;
logic [WIDTH - 1:0]remainder_exp;
initial begin
	{dividend,divisor,din_valid} = 'b0;
	forever begin
		@(negedge clk);
		dividend = (2 * WIDTH)'($urandom_range(0,2 ** (2 * WIDTH)));
		divisor = (WIDTH)'($urandom_range(1,2 ** WIDTH - 1));
		din_valid = 1'b1;

		remainder_exp = dividend % divisor;
		dout_exp = (dividend - remainder_exp) / divisor;

		repeat(5 * WIDTH) begin
			@(negedge clk);
			din_valid = 'b0;
		end
		if((remainder == remainder_exp) && (dout_exp == dout)) begin
			$display("successfully");
		end else begin
			$display("failed");
			$stop;
		end
	end
end

endmodule
```

