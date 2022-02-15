# Chapter 1

## 重點複習

CPU time = instruction count x CPI / clock rate

A 是 B n times faster = B exec time /A exec time = A performance / B perform = n

> Computer C’s performance is 4 times as fast as the performance of computer B, which runs a given application in 28 seconds. How long will computer C take to run that application?

performance = 1 / execution time

clock cycle time = 1 / clock rate
一個 cycle 10 秒 (sec / cycle) = 0.1 個 cycle 一秒 (cycle /sec)
2GHz 是 clock rate = 2x10^9 個 cycle 每秒

重要 : CPU time = clock cycles x cycle time = clock cycles x clock rate

重要 : CPU clock cycles = Instructions for program x average clock cycles per instruction

> Using the Performance Equation p .36
> Suppose we have two implementations of the same instruction set architecture. Computer A has a clock cycle time of 250 ps and a CPI of 2.0 for some program, and computer B has a clock cycle time of 500 ps and a CPI of 1.2 for the same program. Which computer is faster for this program and by how much?

### The Classic CPU Performance Equation

CPU time = Instruction count x CPI Clock x cycle time

CPU time = Instruction count x CPI / Clock rate

## History

二戰的關西 1943 年開發了電腦
電腦元件突破是 IC

80 年代 IC 進入 VLSI

### 摩爾定律

科技的趨勢 : 微處理器的 capacity 隨著時間，4004 8080 pentium...

- 每過 18 個月，一個 single chip 上面的 transistor 可以 double
- 指的是 line width/feature size 的縮短 (下圖 n 到 n 的距離)
  ![[Pasted image 20210927134108.png]]

### CISC / RISC

RISC : ARM /MIPS....
CISC : x86

### 電腦分類

- desktop 一班用途
- server computers
  - network based
  - 高容量 capacity、效能、穩定性
- Embedded computers
  - 通常是系統中的元件

也可以用一般用途 vs embedded 用途來分

- 一般用途 : 軟體相容性是最重要的要素
- Embedded : 嵌入式電腦用在電視手機照相幾....
  - 沒有浮點運算跟 MMU
  - 相容性不是什麼問題因此新的 ISA 容易進入
  - 大用量、低價格
  - 可以自己出一套 ISA 指令集，自己放在自己搭載的 embeded computers 裡面 因為我的豆漿機沒有其他人的軟體要跑
  - 4-bit, 8 bit 的指令都可以活到現在

後 PC 時代
cloud computing, 靠著 amazon, microsoft 就可以了

### 電腦之下

- application software
- system software 系統軟體
  - POSIX: UNIX = kernel + system software - 張立民
  - compiler
- hardware

### 不同層次的 program

- high level
- assembly
- hardware representation
  - binary digits
  - encoded instructions and data

CPU 裡面除了運算的東西還有 datapath control 跟 cache

==cpu 裡面的 cache ==

register 是運算玩立刻要放進去的！
memory 太遠了，所以在 cpu 裡面也有自己的 cache, 叫做 SRAM 跟 register 很像

容量要大就要大電容就大，就慢

## Performance

![[Pasted image 20210927142724.png]]

- cpu cycle time 是永遠不變的
- 老師說如果 instruction set 有一種設計的很複雜，就會連帶影響到 clock rate
  - 要用不同的角度來看 RISV 一個 instruction 是一個 clock cycle

### 衡量運算時間

增加多個處理器可以增加 throughput 但是不一定增加 reponse time

- response time : how long it takes to do a task 主要的衡量標準
- throughput : total work done per unit time 單位時間

- 要衡量 execution time 有兩種方式 :

  - elapsed time (決定系統效能) : total response time, including all aspects : 運算 + IO + OS overhead + idle
  - cpu time (我們主要計算這項) 是 把 IO, other jobs 時間扣除

- 定義效能 performance = 1 / execution time
  - 一個工作 a 10s b 15s => Pa = 1/10 Pb = 1/15 => Pa 是 Pb 的 1.5 倍 (快)
- 剛剛是用秒，改用 CPU clocking 比較讚

#### Clock

- clock 是 cpu 裡面的電位差變化 high low high low.....
  ![[Pasted image 20210927141145.png]]
- 一個 clock period 可以做一件事情，並且暫存，下個 clock 繼續 : duration of a clock cycle
- clock frequency 時脈 cycles per second e.g. 4.0GHz
- CPU Time = CPU clock cycles x Clock cycle time = CPU clock cycles / clock rate
- 效能提升來自 :

  - 減少 clock cycles 數量
  - 增加 clock rate 跟前者相衝突 (當 clock rate 增加表示每秒的 clock number 變多 隱含著每個 clcok 做的事情變少)

- Clock Cycles = instruct. Count x Cycles per Instruct (CPI)
- CPU Time = instruct Count x CPI x Clock Cycle Time

同樣的指令集，一條指令不同的 CPU 還是要不同的 clock number 來執行 ( CPI 不同)

#### instruciton count

- Insturciont count for a program :
  - determined by program, ISA and compiler
    - program : 我用的演算法很爛
    - ISA : 有些沒有乘法指令 就要一直加
    - compiler : 有些優化的不錯 2 的平方會直接用 shift
- average cycles per instruciton

- determined by cpu hardware : 有些 hardware 同樣的家法指令 需要的 instruciton count 不一樣 邏輯設計有教？

- if different instructions have different CPI
  - average CPI affected by instruction mix

## Power trends :

- Power = Capacitive load x Voltage^2 x Frequency
- clock rate 提升功率也跟著成長 (提升 frquency 降低 voltage)

- 但是現在遇到瓶頸了
  - multicore microprocessors
  - require explicitly parallel programming

## Bench Mark

- 用三個 forloop 來衡量？
- 如何 measure? 先想我們會用到的 workload
  - compile
  - drawing program
- benchmark programs

  - Standard performance evaluation corporation SPEC
    - CPU performance
    - high performance computing
    - client server models....

- SPEC Benchmark
  首先要先把

## Cost

yield : 好的 dies 的比率

- die cost
- testing cost
- packaging cost

## Amdahl's Law 效能改進只有應用在會用到的部分

- 乘法運算快五倍，但是乘法運算只佔了 80%.....

## 作業

1. 1. A designer wants to improve the overall performance of a given machine with respect to a target benchmark suite and is considering an enhancement X that applies to 50% of the original dynamicallyexecuted instructions, and speeds each of them up by a factor of 3. The designer’s manager has some concerns about the complexity and the cost effectiveness of X and suggests that the designer should consider an alternative enhancement Y. Enhancement Y, if applied only to some (as yet unknown) fraction of the original dynamically-executed instructions, would make them only 75% faster. Determine what percentage of all dynamically-executed instructions should be optimized using enhancement Y in order to achieve the same overall speedup as obtained using enhancement X

原本執行時間 1
X: ( 可應用於原本的 50%) (提升 factory of 3, 3 倍)
0.5 _ 0.3333 + 0.5 = r _ 1/1.75 + (1-r )

2.

3.

4.  For a calculator, which one of these two following changes will be more efficient? (1) Accelerate multiplication operation for 5 times, and this operation occupies 30% of the whole execution time. (2) Accelerate other operations for 1.5 times, and these operations occupy 60% of the whole execution time. (Assume the costs of these two changes are the same and they are mutually exclusive.)

原本運算時間是 x

0.3 x * 0.2 (5 times) + 0.7 *x = 0.76 x
0.6x _ 1/1.5 (1.5 times) + 0.4 _ x = 0.6x \* 0.67 + 0.4x = 0.4 + 0.4x = 0.8 x

Ans : first would be more efficient

出題組別是計算成 提升的倍率

5. Throughput and Response Time: Do the following changes to a computer system increase throughput, decrease response time, or both? 1. Replacing the processor in a computer with a faster version 2. Adding additional processors to a system that uses multiple processors for separate tasks—for example, searching the web a.) 1. Throughput and response time are improved. 2. Only throughput is improved. b.) 1. Throughput and response time are improved. 2. Only response time is improved. c.) 1. Only throughput is improved. 2. Only response time is improved. d.) 1. Only response time is improved. 2. Only throughput is improved.

6.

1 (時間) / 比率 \* 提升倍率 + 比率 \* 提升倍率

## 對抗賽

## 問答

下列哪些方式會同時影響到 CPI 及 clock rate ?

A : 小王在同一台電腦上把原本 C 語言的程式用 php 重構
B : 小雨過年升級電腦把 cpu 從 intel 換成香噴噴的 AMD ryzen 7 運行同一個程式
C : 小明從上一代的 x86 macbook 升級到最新一代 Arm 架構 m1 運行 VSCode

答案 : C 應只有 B C 更換 CPU 會影響影響 clock rate, CPI 的部分 A 程式不同 instruction count 亦不同，C Instruction set 不同也會影響 CPI
