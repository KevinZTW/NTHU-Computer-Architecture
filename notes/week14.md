# Week 14

It's a prediction mechanism which make the decision base on history record that indexed by the instruction address

## Exception

### Handling Exception

1. 把 PC 記下來
2. 把發生的原因記錄下來 (MIPS : 0 for undefined opcode, 1 for overflow)
3. Jump to handler at 800000

跳到 OS 之後.....

1. 讀取成因、跳到相對應的 handler
2. 決定處理方式
3. 如果可以 restartable
   1. 修正、跳回 program
4. 否則 terminate 並且 report

### 那當 exception 發生在 pipeline

因為要跳轉因此等同於 `control hazard`

- 不能讓當下指令完成
- 他之前的指令必須讓他們完成
- 把現在這個指令以及他之後的 flush 掉
  - 我們有 EX flush /ID flush/IF flush 可以把該階段的 register 設定成 0
- 設定 Cause 以及 EPC 設定好
- 跳轉到 handler
