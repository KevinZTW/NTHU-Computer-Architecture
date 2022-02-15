# Lecture 0 介紹

- 為什麼電腦不用十進位用二進位？
  signal : two state

## Transitor 電子開關

- 有 p type 跟 n type 的 transistor ?
- 整個結構叫做 transistor
- n type transistor
- 他會把電子吸引到 gate 下面， 形成 electron channel 在 source 跟 drain 之間，就導通了
- 當 gate 中的 voltage 移除，electron 不再受吸引
  (以上的細節會在超大型積體電路設計教授)

## 有了開關就可以做邏輯閘

1 不導通
邏輯設計學過的話有了 NAND gate 就可以把全部的 gate 都都出來

## 有了邏輯閘就可以做邏輯電路

可以做加法器，可以做記憶元件
這部分的學問叫做數位邏輯設計 decoder, mocks 要快點看一看

## 基本的組織

![[Pasted image 20210913133540.png]]

- control 發號指令叫 data path 做事
- data path 實際做事的地方

### 什麼是 computer architecture?

computer architecture = instruciton set architecture + machine organization

- computer organization 只是單單包含上面介紹的單元，敘述怎麼連結的情況下會怎麼走
- computer architecture 包含了硬體 (Machine Organization) 以及軟硬之間的 interface (Instruction Set Architecture)

### instruction set architecture (ISA)

通常 instruction set 會先訂出來，然後硬體軟體才會分頭開始動工

### MIPS R3000 ISA

- load/store
- computational
- jump and branch

### 現有的 ISA

- intel
- ARM 手機、蘋果
- RISC-V
