# CPU design

- intro to designing a processor
- analyzing the instruciton set (step 1)
- building the datapath
- a single cycle implementation
- control for the single cycle CPU
  - control of CPU operations
  - ALU controller
  - Main controller
- Adding jump

### critical data path

1. unconditional PC-relative branch. What would the cycle time be for this datapath?

- Instr mem + sign extend + left shift + alu + mux

2. **lw** critical path?

- 眾說紛紜 我目前的想法是
- Intr-Mem + Reg + mux + ALU + Data Mem + mux
  - base on 老師的投影片，register 是在最後切上去的時候寫入
  - 埃及大學的題目支持這個說法 The longest-latency path for lw is through I-Mem, Regs, Mux (to select ALU input), ALU, D-Dem, and Mux (to select what is written to register). T

3. **BEQ** critical path

- intr-Mem + Reg + mux + ALU + mux

4. **AND**

- intr-Mem + Reg + mux + ALU + mux

## Intro to design CPU

藉由 PC 位址知道要去 memory 的哪例哪裡拿 instruction
fetch instruction => decode =>

### 數位邏輯

- Edge-triggered: update when Clk changes from 0 to 1 (我記得是 negative edge -trigger)
- positive edge trigger 只有在 0->1 的時候放資料
  加個圈是 1->0 的瞬間才可以放進去

Low voltage = 0, High voltage = 1
One wire per bit

- add gate, adder, Multiplexer(Mux), ALU

### Sequential Element

**Sequential Components for Datapath is the register**

- 應該就是指 PC, Memory, Register file
  每個 clock period 只做一件事情，資料的寫入(to register)利用 clock signal 來決定何時 update，`edge trigger` 0 換到 1 的時候更新，且 write 需為 1

邏輯設計有提到有兩種作法，level sensetive (0 不寫 1 都寫)或是 edge trigger 0 換到 1 寫入

### Clock methdology

計算的時間要小於 clock period 不然已經要寫資料了我都還沒算好，因此要比最長的 critical path 還要大

## 解讀 instruction

MIPS 很棒都是 32 bits instruction
![[Pasted image 20220106130221.png]]

## Build the data path

### Datapath Components

1. Combination component
2. Sequencial Component : PC, register
   1. Similar to D Flip Flop execpt N bit input and output , write enable input

#### register file

```
    	WE RA 5 RA 5 RB 5
	    	|   |     |
     	--------------
	    |             |  -> BUS A (RA)
     	| 32bit       |  -> BUS B (RB)
    	| register    |
	    --------------
```

1. 每一個 cycle 開始可以讀兩個 data 出來 ( RA/RB 各五個 bit) 因為兩個 Operand
   1. add $s1(RW) $s1(RA) $s1
2. cycle 結束要寫資料要有一個 WA
3. 還要有一個 Write Enable

#### Memory

```
    	WE Address
	    |	|
     	--------------
	    |             |
Data  ->| 32bit       |  -> data out
In 32  	| register    |
	    --------------
```

### BEQ

![[Pasted image 20220106131245.png]]

## Single cycle implementation

記得老師在這邊主要是在講解各種 instruction 路線圖

這邊又重新提了 clock 的事情，看來我不用擔心寫入完成前 input 訊號改變，這邊只有提到

- input signal 要在 clock edge (1->0) 來之前穩定
- 一個 register 可以在一個 cycle 內讀出資料，更改之後再寫入 all in same cycle

![[Pasted image 20220106124144.png]]

這邊提到 lw 的 critical path 最後一步是 **setup time for the rigster file...** 我猜是 control signal `RegWr` 的設置? 他通常會很早就完成了!

The time it takes to execute the load instruction are the sum of:
(a) The PC clock-to-Q time.
(b) The instruction memory access time.
(c) The time it takes to read the register file.
(d) The ALU delay in calculating the Data Memory Address.
(e) The time it takes to read the Data Memory.
(f) And finally, the setup time for the register file and clock skew.

![[Pasted image 20220106132218.png]]

一些詳細的流程，我大致都理解了

This timing diagram shows the worst case timing of our single cycle datapath which occurs at the load instruction.
Clock to Q time after the clock tick, PC will present its new value to the Instruction memory.
After a delay of instruction access time, the instruction bus (Rs, Rt, ...) becomes valid.
Then three things happens in parallel:
(a) First the Control generates the control signals (Delay through Control Logic).
(b) Secondly, the regiser file is access to put Rs onto busA.
(c) And we have to sign extended the immediate field to get the second operand (busB).
Here I asuume register file access takes longer time than doing the sign extension so we have to wait until busA valid before the ALU can start the address calculation (ALU delay).

- **With the address ready, we access the data memory and after a delay of the Data Memory Access time, busW will be valid.**

- And by this time, the control unit whould have set the RegWr signal to one **so at the next clock tick, we will write the new data coming from memory** (busW) into the register file.

## Control for Single Cycle

![[Pasted image 20220106132553.png]]

- RegDst :
  - 0 選擇 rd - R type
  - 1 選擇 rt 因為 I type 沒有 rd
- PCSrc
  - 0 選擇 PC + 4 (前面有 adder)
  - 1 選擇 PC + 4 + sign.ext(immeditate 16) || 00 (left shift) **Beq**

...

### 投影片 p.41 42 切換動畫不錯

### beq

![[Pasted image 20220106133611.png]]

- ALU 計算完，zero signal 是 1 的話 + branch 有一個 and gate **PCsrc**

![[Pasted image 20220107172800.png]]
注意 op 編號是反過來的!!
