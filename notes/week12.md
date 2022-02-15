# Week 12

# Pipeline

- Doesn’t help latency of single task, but throughput of entire
- Pipeline rate limited by slowest stage
- Potential speedup = Number pipe stages
- Unbalanced stage length; time to “fill” & “drain” the pipeline reduce speedup
- Stall for dependences

## 練習

[[week12_class_sheet - ans.pdf]]

先想成是 pipeline CPU clock rate 變大 因為以前一個 instruction 需要的時間是一個 cycle ，現在變成 instruction 一個 stage 就是一 cycle

### Designing a Pipelined Processor

- Examine the datapath and control diagram
  - Starting with single cycle datapath
  - Single cycle control?
- Partition datapath into stages:
  - IF (instruction fetch), ID (instruction decode and register file read), EX (execution or address calculation), MEM (data memory access), WB (write back)
- Associate resources with stages
- Ensure that flows do not conflict, or figure out how to resolve
- Assert control in appropriate stage

### pipeline register

Use registers between stages to carry data and control

Ifetch Reg/Dec Exec Mem Wr

5 functional units in the pipeline datapath are:
Instruction Memory for the Ifetch stage
Register File’s Read ports (busA and busB) for the Reg/Dec stage
ALU for the Exec stage
Data Memory for the MEM stage
Register File’s Write port (busW) for the WB stage

- 看了原文書的新觀念 : 在每一個小 cycle (IF, Reg/Dec...) 裏面就已經把資料從 pipeline register 取出**並且將需要保存的資料存進 pipeline register**

#### 以 lw 為栗子

![[Pasted image 20220105135030.png]]

1.  Instruction fetch:
    instruction 被讀出來，放進 pipeline register
    The top portion of Figure 4.36 shows the instruction being read from memory using the address in the PC and then **being placed in the IF/ID pipeline register**. The PC address is incremented by 4 and then written back into the PC to be ready for the next clock cycle. This incremented address is also saved in the IF/ID pipeline register in case it is needed later for an instruction, such as beq. The computer cannot know which type of instruction is being fetched, so it must prepare for any instruction, passing potentially needed information down the pipeline.

![[Pasted image 20220105135147.png]]

2.  Instruction decode and register file read: the instruction portion of the IF/ID pipeline register supplying the 16-bit immediate field, which is sign-extended to 32 bits, and the register numbers to read the two registers. All three values **are stored in the ID/EX pipeline register**, along with the incremented PC address. We again transfer everything that might be needed by any instruction during a later clock cycle.

![[Pasted image 20220105135711.png]] 3. Execute or address calculation: Figure 4.37 shows that the load instruction reads the contents of register 1 and the sign-extended immediate from the ID/EX pipeline register and adds them using the ALU. That sum is placed in the EX/MEM pipeline register.

![[Pasted image 20220105140056.png]] 4. Memory access: The top portion of Figure 4.38 shows the load instruction reading the data memory using the address from the EX/MEM pipeline register and loading the data into the MEM/WB pipeline register.

![[Pasted image 20220105140106.png]]

5.  Write-back: The bottom portion of Figure 4.38 shows the final step: reading the data from the MEM/WB pipeline register and writing it into the register file in the middle of the figure.

### Structural Hazard

### Data Path control

![[Pasted image 20220106151007.png]]
老師說了一個我覺得很重要的，在 decode 這個階段我們還不知道他是 R type / I type 因此我們會先把 rt, rd 都先存起來以便 wrtie back stage 用作地址

### Data Forwarding

![[Pasted image 20220106150617.png]]
