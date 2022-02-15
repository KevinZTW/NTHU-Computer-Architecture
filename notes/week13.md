# Week 13 Pipeline Hazard

## Recap

之前提到用 single cycle 會被 Load 指令拖到很慢

兩個原則 :

- pipe line register
- 不能用到同一個 resource

- response time 沒有影響，增加 throguhput
- 最長的 stage 來決定 clock period
- 三種 hazard, data 又有三種，MIPS 只存在 RAW
- 如何處理? 三種方式 software noop, hardware data forward, stall
- 單純 noop 只要等到 WB 跟 ID/Reg 在同一 cycle 就可以 (還是沒搞懂啊)
- data forward for R type, 可以把 Exec 算好的資料傳給他下一個 & 下下個要 Eexc 的 instruction
- stall 大家都停下來 for lw,

---

## Hazards

There are three types of pipeline hazards, structural hazards, data hazards, and control hazards. For data hazards, it could be divided into three types in detail

i1 -> i2

1.  read after write (RAW), i1 write, and i2 want to read the data i1 going to write, but it's not ready
2.  write after read (WAR), an _anti-dependency_, i1 read the data, but i2 write modified it before i1 read
3.  write after write (WAW), an _output dependency_,

### NoOp (Software, compiler)

蠻怪的不過老師投影片還有 rice 都支持，沒有 data forwarding 的時候當地一個在 WB stage 寫進去另一個同時在 ID 讀出來是可以的！！！
[CS61C](https://www.youtube.com/watch?v=v7115x80jk0&list=PLkFD6_40KJIxaAvX0p_ZnB7915Ua-ggU0&index=9&ab_channel=CALESG-EECS) 也這樣說，(because read in the end of the cycle)
![[Pasted image 20220106154113.png]]

### Data Forward (R type)

![[Pasted image 20220106160234.png]]
看老師的講解，看來只要我要做 EXE 的前一回合已經算好了就 ok
可以傳兩個階段(上圖有叉叉)不過再下一個也沒影響了 (剛剛說的同一 cycle WB+Reg)
![[Pasted image 20220106155927.png]]

### Stall (hardware)

![[Pasted image 20220106160519.png]]
這邊老師說，在第四個 cycle memory 才會把資料讀出來**並且 ready** 但是這時下一個 instruction 也是在第四個 cycle 想要拿來做計算，這樣就真的沒辦法，只能 Stall 整個停下來或是 noop

我們會希望越早越好發現 **lw used hazard** => instruction decode 是最早的 stage

會有一個 hazrd detection unit, 怎麼偵測?

- ID/Exe 的 MemRead 是 1 且
- ID/Exe 的 rt 等於前一個 IF/ID 的 rt 或是 rs

要注意跟我原本理解的差一個 cycle (上述的事情是等到 lw 進到 EXE, add 進到 ID 才會執行)

如何停下來?

- PC 跟 IF/ID 都不要改變，這樣下一階段 IF 跟 ID 就會重新執行一樣的
- insert an NOP by changing EX, MEM, WB control fields of ID/EX pipeline register to 0

要停多久?

- **一個 cycle 足以**，因為有 Data forwarding, 當 lw 資料讀完進到下一個 WB 的時候，要用資料的同時可以進到 EXE! (比本來差一的再多差一個 stage 而已！)
  ![[Pasted image 20220107140346.png]]

## Branch Hazrd

- 都先採取不跳，繼續把 PC+4, PC+8 塞進來
- 基本的做法看下圖會發現，比較做完之後的結果跟地址會存到 EXE/MEM，MEM **stage 4** 才會 made decision，因此需要清掉前**兩個** latch (IF/ID, ID/EXE)，後面**三個**進來的 instruction 都沒用了(後面**三個 noop**)
  ![[Pasted image 20220107141514.png]]
  ![[Pasted image 20220107141605.png]]

- 這樣太多，因此我們可以改成在 **stage 2 ID** 就做決定，這樣就 flush 掉**一個** instruciton 就好了(後面**一個 noop**)

- 如果像是 loop 回圈跑一百次，每次都會 beq 要清掉，難道還是每次都 predict not taken 嗎? 改成 **Dynamic branch prediction**
  - 用一個歷史的 table indexed by recent branch instruciton address
  - 如果預測錯了
  - In deeper and superscalar pipelines, branch penalty is more significant
  - Even with predictor, still need to calculate the target address **1-cycle penalty** for a taken branch

底下的圖是 **Predict-not-taken + branch decision at ID** 所以一定還是會有一個 cycle penalty 是空著不做事的，但如果我們可以找個不管怎樣一定要執行的塞那個洞那就沒有 penalty 了
![[Pasted image 20220107142445.png]]

## Superscalar and dynamic pipelining

- Instruction-Level Parallelism (ILP)

  - Deeper pipeline
  - Less work per stage ⇒ shorter clock cycle

- Multiple issue
  - Replicate pipeline stages ⇒ multiple pipelines
  - CPI < 1, so use Instructions Per Cycle (IPC)

### Multiple Issue

In which stage should the hazard detection unit be placed?

- A.IF
- B.ID
- C.EX
- D.MEM
- E.WB
  A: B

What types of data hazards would not appear in MIPS?

(多選題)

- A.WAW
- B.RAW
- C.WAR
  A: A, C

Which of the following statements is correct ?

- A.We have to forward if the destination register is $0.
- B.The stall method for solving data hazard can be used for r-type instructions.
- C.There are 1 types of data hazards that could happen in MIPS.
- D.There are 3 ways to solve data hazards: Compiler inserts NOP, Forward and Stall, three of them are all hardware solutions.

A: B, C
