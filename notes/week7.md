# Week7 Procedure Call

### Reference

##### R- format Instruction

| opcode | rs  | rt  | rd  | shamt | funct |
| ------ | --- | --- | --- | ----- | ----- |
| 6      | 5   | 5   | 5   | 5     | 6     |

##### I- type format Instruction

| opcode | rs  | rt  | immediate |
| ------ | --- | --- | --------- |
| 6      | 5   | 5   | 16        |

### 重點

- $ra return 回去的地方 誰存 ? caller
- 平常 addi 的那個單位是 byte
- 一個 word 在 32 位元電腦 = 32 bit ^wfyrz6v
- 一個 byte = 8 個 bit = 0000 0000 = FF
- 一個 instruction 花了 32 bit 4 byte 1 word

- bne 是 `I - format` 最後面只有 16 bit 地址要 +4 再加 x \* 4 (word address) 並且加上自己現在的位址
- j / jal 則是 j format, 有 26 bit 可以用 因此 26 word address = 30 再從最高位

A function (i.e. callee) must preserve $s0-$s7, the global pointer $gp, the stack pointer $sp, and the frame pointer $fp

callee 會把 s 系列、global pointer、 stack pointer 、 frame pointer 回覆，所以 caller 自己要去記好其他的，但是像是 ra caller 可以把它存到其他地方，不一定要回覆在 ra 上

### 概要

caller :

1. 把參數放到 register 讓 callee 去用
2. 把控制權轉給 callee 把 program counter 的值改變變成 callee 的，跳到 callee
3. 從 `$v0`拿東西

callee :

1. 在 memory 裡面拿到 storage 給他放資料，叫做 activation record
2. 執行 procedure's operations
3. 把結果放在 register `$v0`
4. 控制權轉回 caller

### Procedure Call instruction

#### jal : jump and link (procedure call)

會自己跳回來 : jump and link 會把 next address 放到 $ra
為什麼不用兩個 instruction ? 而要特製一個 ? 因為他非常長發生 make common case fast

```assem
jal procedureLabel
```

我把我下一行程式碼的位址放到 return address $ra (之後回來可以執行)
跳去目標位址

#### jr : (prodecure return)

jr $ra , copies ra to program counter

```assem
jr $ra
```

會直接跳去寄存器 e.g. $ra 存放的地方

#### j : jump unconditionally (unconditoinal branch)

### Procedure, Stack, Activation Record

![[Pasted image 20211025133917.png]]

因為我們 caller, calle 分別會有一些運算需要把資料放到 register, 但是我們要共用同一組 register, 因此要把資料存到 memory 並且做復原

透過一個 `stack pointer` 來記錄現在 stack 跑到什麼地方，stack 會存高位址一路往下長，callee 退出時要恢復原狀

- $s callee 要恢復好 caller 可以開心用
- $t callee 可以開心用

### Leaf Procedure

主程式只叫一次 procedure，完成之後就回到主程式

```c
sum = leaf_example(a , b, c, d)

int leaf_example(int g, h, i, j){
	int f;
	f = (g+h) -(i+j);
	return f;
}
```

return address : $ra (執行完畢要回到哪裡)
Procedure address : Label (code 在哪裏)
arguments : 固定存在 a0 a1 a2 a3..
return value : v0 v1
local variables : s0 s2 s2
注意撰寫的 convention

![[Pasted image 20211016180723.png]]

#### Caller code

```c
sum = leaf_example(a,b,c,d)

//假設 a,b,c,d,sum in $s0, $s1, $s2, $s3, $s4
//要先把資料存進去

add $a0, $0, $s0
add $a1, $0, $s1
add $a2, $0, $s2
add $a3, $0, $s3
jal leafeaxmple
add $s4, 0, $v0   //put return value to sum
```

#### Callee code

```c
int leaf_example(int g, h, i, j){
	int f;
	f = (g+h)-(i+j)
	return f;
}
```

剛剛呼叫的 argument 已經放到 register a0, a1, a2, a3...
assume f in $s0
t1, t2 拿來放 g + h i+j 的運算結果 (有講過 t 是隨意用 temporary)
回傳資料在 v0
直接 jr caller 存在 $ra 的地方
![[Pasted image 20211016182020.png]]
-12 是因為 stack address 是從高位到低位，因此用減的

### Non - Leaf Procedure

多重呼叫 a 呼叫 b b 呼叫 c c 呼叫 d 比較複雜

recursive call
For nested call, caller needs to save on the stack :

- return address 要存起來不然會被之後的呼叫蓋掉 ( 我爸給我的回去的地址 $ra，我要先存起來再給兒子)
- any arguments and temporaries needed after the call (because callee 不會做儲存，)
- restore from stack

#### non-leaf example

```c
int fact(int n){
	if (n < 1) return 1;
	else return n * fact(n-1);
}
```

- argument in a0
- result in v0

![[Pasted image 20211016183011.png]]

1. 先把 sp 移動 8 個...byte
2. 把 ra 等等要回去的地方存到 stack 上
3. 把 argument 存到 stack 上

### Memory Layout

![[Pasted image 20211022141139.png]]
reserverd 是不會用的
text 放 code
static data 不會變動的數值
剩下 stack ()跟 dynamic data (malloc in c new in java)

## Communicate with People

### Character Data / Operations

- Byte encoded character
  以一個 byte 來表示資料

- unicode
  以四個 byte

- load
  我只拿一個 byte 但是 register 是 4 個 byte
  如果是 sign 的話`lb rt, offset(rs)`就是 signed extenion

如果是 unsigned 就補零
![[Pasted image 20211025141228.png]]

- store

## Addressing for 32 bit

### 放很大的 constant

```
lui rt, constant
```

![[Pasted image 20211025141353.png]]

### Branch Addressing (beq/bne)

I - format
![[Pasted image 20211025141607.png]]

- PC relative addressing

我們用 immediate 要描述要去的地方，但是 immediate 只有 16 bit 無法描述 32bit，我們又發現 loops 常常去不遠的地方，那就用 program counter +4 + (x \* 4) word address 表示--因為 instruction 一個都固定是 32 bit 1 word

PC 因為硬體的關係會立刻 + 4 (注意這邊沒有乘以四)

總之呢 pc 幫你跳一個、一行 instruciton，剩下的 instruciton 數量就描述在 Immediate

### Jump Addressing (j/jal)

剛剛說 branch 不會跳得很遠，但我們希望 jump 可以滿地跳，但是 memory address 32 bit 我們 instruction 也是 32 bit

![[Pasted image 20211022144329.png]]

op code 6 個 bit 我們剩下 26 個 bit，但因為這邊是 word address 因此 26 可以描述 28 bit 的地址
剩下的 4 個 bit 從 PC 的最高位拿，大部分的時間因為沒有跳太遠因此最高位的 bit 會一樣 (整個 memory 的 1/16)

如果一定要完整的表示也可以用 `jr $sa`

### 例子

![[Pasted image 20211022144921.png]]

### 再複習一下投影片寫的 mips addressing overview

![[Pasted image 20211025150735.png]]
![[Pasted image 20211025150752.png]]

- immediate addressing : immeadite 本身就是資料， I-type `addi $s0, $s0, 1`
- Register addressing : R-type `add $s0, $s0, $s1`
- Base addressing : I-type `lw $s0, $sp, 0` ( lw, $s0, $sp(0))
- PC addressing : I - type `bne $s0, 1, Loop` PC + 4 + (immedate \* 4)
- Pseudo dirrect : addressing :
  問老師 :
  寫 assembly 的時候 s type t type 通常會怎麼做使用呢?

- temporary 要放 t ，要用的就放在 s

之前好像很愛問 xxi 是否是 r type 上次問答？

bne 可以跟 register 比較? imeediate 也行?
