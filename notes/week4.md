# Week4 MIPS

### Computer Architecture

Computer Architecture = `instruction set architecture` +`machine organization`

- 也就是我們從 assembly language 來看電腦的時候所看到的特性
- 同一組 ISA 所建構的 CPU 彼此是 compatible 的

### ISA component

- 儲存空間的組織架構
  - 有幾個 register
  - 有哪些 多少 memory
  - 要如何作取址 addreessing
- Data types and data structure : 如何表示...整數 浮點數 一樣一堆 010101010 不同的 instruction 下 代表的數字也不同
- instruction 格式
- 有哪些 instruction 可以做 可以乘法？

### MIPS

- 一次操作一個 `word` 4 byte 32 bits
- 有指令像是 : load/store, computational, jump
- 32 個 register
- instruction `32bits`
- syntax 維持簡單來達到 simplicity

register 是放在 cpu 裡面跟她在同一個 IC 上

- 比 memory 快
- easier for compiler to use (在 assembly 可以方便拿來暫存資料)
- 減少要去 memory 的流量
- improve code density (因為要描述記憶體位址 32 位元電腦就需要 32 bit 去描述地址，但是 register 可能只需要 5 個 bit 去描述)

### MIPS Registers

- 32 registers, each is 32 bits wide - 為什麼不大一點？因為小的時候面積小因此電容小充放電快 - groups of 32 bits called a `word` in MIPS - registers are 標號從 0 - 31 (00000- 11111)
  $t0 - $t 7 -> $8 - $15 (temporary)
  $16 - $22 -> s0 - s7 ()

![[Pasted image 20211003222316.png | 600]]

- arithmetic unit 在做加減運算
- mutiply devide 做成除
- coprocessor 處理浮點運算
- coprocessor 0 在處理 exception 的時候

### memory operand

大資料放在 memory，那怎麼拿過來運算? 運算只能用 register
以 processor 為中心

- load 從 memory 搬過來 load word(32bit) `lw`
- store 搬到 memory `sw`
- 如何描述地址? MIPS 32 bits 我的 instruction 也是 32 bits 都拿來描述就飽了所以要間接
  - 間接方式 透過 pointer + offset 因此我可以用一個 register 整整 32 bits 來存放地址作為 pointer
    - 8($t0) => t0 裡面是 32 bit 的 address

Example :

```assemb
lw $t0, 12($s0)

A[12] = h + A[8] 假設這邊 A 是 int array 一個單位 4 bytes
轉換成以下 ( A address is on $s3)
lw $t0, 32($s3)
add $t0, $s2, $to
sw $t0, 48($s3)
```

- lw means load a word 所以一次搬 32bits
- 從 s0 + 12 的地方來取 32 bits
- s0 is called the base register, 12 offset

### memory versus word

- Memory 可以看作是一個 `byte`array
- byte address
- byte = 8 bit word = 4 byte
- 因此 memory[0] 是第一個 word, memory[4] 是第二個 word
  也因此 lw, sw 是用 `byte`為單位做 offset

### Aligment

- MIPS request that all words start from addresses mutiples of 4 bytes
- 一個 word 4 個 byte 為單位 read write 要以 4 bytes 0, 4, 8 為地址來擺放

### register vs memory

register 描述容易 在 MIPS 可以 read 2 registers

## Immediant Operand

### Constants

we could specified these const data in the instruction

```i
addi $29, $29, 4
slti $8, $18, 10
```

for substration, use

```
addi $2, $4, -1
```

- 在 c 常常寫 a = a+5 ... 50% of operands
- principle 3 : make common case fast
- 特定的 constant 後面加個 i 來處理 constant
  - f = g + 10
  - addi $s0, $s1, 10

把 constant 嵌入在這個 instruction 裡面

- 因為 constant 可以是負數因此可以透過 add 做到剪的動作
- MIPS ($zero) hardware 內建 register 來儲存 0
- 可以透過 add 0 來達到 move 效果
- signed unsigned 要自己研讀 邏輯設計教過
