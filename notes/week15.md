# Week15 Basic of cache

### Random Access

給定一個地址，拿資料的時間都是常數時間，disk 就不是啦要看他當下讀寫頭的位址

- SRAM :
  - 很貴、跟 register 的設計很像
  - 面積大 (density small)、速度快
  - Use for cache
  - static, content would last
- DRAM (Dynamic Random Access Memory)
  - 是一個電容去存他，有點像水桶慢慢會漏水因此一陣子就要 refresh
  - Address in 2 havles ( memory as a 2D matrix)

### 想要又快又大又便宜 Memory Hierarchy

- An illusion to cheap, fast, large memory
- 靠近 cpu 的是 upper level
- 一定是兩個鄰近 level 之間做搬移

### Why hierarchy Works?

- 為什麼可以用這樣的方式呢? => Principle of Locality
- spacial locality
  - instruction 執行
  - array data 讀取
- temporal locality
  - loop

### 階層關係

- Register 到 Cache(Memory) 工程師寫軟體的時候決定什麼時候要搬到 memory, 或是交給 compiler 優化
- Cache 到 Memory 由 hardware **cache contorller** 決定什麼要搬進去，寫程式的時候不知道的
  - blocks
- Memory 到 Disk 是 OS 在處理，中間需要 hardware 協助 (MMU...)
  - pages
- Disk 到 Tape
  - files

### 幾個問題

- Block Placement : 底下階層要放到高階層的哪裡
- Block Finding : 要怎麼很快找到放進去的資料
- Block Replacement : 空間不夠的話要丟掉誰?
- Write Strategy : 寫入要怎麼處理?
  - data inconsistent : two copy on write, need policy to handle this

## Direct-Mapped cache

- hardware mapping! (vs virtual page is software mapping)
- 一點要先算出 block number (因為進出是一群/block 的!)
- 我在 block 的哪裡是看餘數
- 沒有 cache 的話， DRAM 進步的速度(9%/y) 遠落後於 CPU(60%/y)
- cache (SRAM) 是在 CPU 裏面，可能會有每個 core 各自有一個

- **以 block 為單位搬進搬出**

- Block Placement :

  - 以 block address 為基準點 (如果 block size :8 後面三個 bit 不要理他, 底下是 offset)

- Block Finding : 要怎麼很快找到放進去的資料
  - 取 mod 就可以找到我的位置，但要有一個 tag 才能確定真的是我的資料，因為多筆資料會對應到 upper level 同一個地方
- Block Replacement : 要放的時候已經有人的話?
  - 直接換掉
- Write Strategy : 寫入要怎麼處理?
  - miss :
  - hit :
    - write through / write back

## Memory Address Sub-division

**老師說研究所超愛考，因為考卷很好改**

**先換算成 block address 再去找是第幾個**

- 一個 block 1 個 word => 2 bit 不用理他
- 一個 block 4 個 word 後面幾個 bit 不用理他？
  - 4 個 word => 16 byte => 4 個 bit 不用理他

先把 block address 算出來再去取 mod

### example

e.g. block size 1 word, 16 blocks, 1200 (byte address)
-> 300 (block address) ->300%16 = 12(block number)

- 64 blocks, 16 bytes/block
- To what block number does address 1200 map?
- Block address = ⎣1200/16⎦ = 75
- Block number = 75 modulo 64 = 11

```
22		 6		 4
Tag    Index  Offset
```

假設今天變成 128 block, 16 bytes/block

```
21		 7		 4
Tag    Index  Offset
```

256 blocks x 16words/block
index : 8 個 bit

### Block Size Consideration

- 更大的 block $\rightarrow$ miss rate 降低 (due to spatial locality)
- 但如果總 block size 不變，如果 block size 變大就有更多人對應到同一個位置，導致 miss rate 上升
- 更大的 block size $\rightarrow$ 資料改動的時候，block 裏面任何一個 byte 被改動，整個 block 都要做更新寫回去 (pollution)
  - early restart : resume execution 一但 block 裏面的 word return, 而不是等待整個 block (work good for instruciton)
  - critical word first : 請求的 word 優先傳輸，接下來才是附近的 word ，最後作為 block 包成一包

## Cache hit and miss

read / write
hit / miss

#### read

- read hit : good
- read miss :
  - **Stall the CPU pipeline**
  - fetch block from next level (memory
  - restart instruction fetch or data access

#### write hit

- write through : 要改 cache 同時也改 memory 才往下繼續

  - 可以用 write buffer 改進，先寫到 buffer CPU 就繼續執行下去但如果 frequency > buffer size 一樣滿出來要等

- write back :
  - **On data-write hit**, just update the block in cache
  - 只有在 replacement 的時候，檢查他的 dirty bit 判斷是否

#### write Miss :

- write through :

  - allocate on miss : 寫到底層之後也 fetch 上來
  - write around : 只寫到底層不把資料搬上來

- write back : 一定會搬上來 (解決了我之前的疑問 - 會不會有不 dirty 但不存在底層的資料)

1. The following bits of the address are used to access a direct-mapped cache design with 32-bit address. (1 word = 4 bytes) Tag Index Offset : - A 31-10 9-4 3-0

   - B 31-12 11-5 4-0

   1. What is the cache block size represented in words? (for A and B respectively)

      - a. 2^4 / 4 = 4 ( 0-3 表示 4 bits => 可以表示 0 - 16 表示一個 Block 16 byte => 4 words)
      - b. 2^5 / 4 = 8 ()

   1. How many entries does the cache have? (for A and B respectively) 各有幾個 entries(blocks)
      - 2^6 = 64 ( 9-4 有 6 個 bit, 可以表示 2^6 表示全部有 64 個 blocks/entries)
      - 2^7 = 128

2. Design a 128KB direct-mapped data cash that uses a 32-bit address and 16 bytes per block. Calculate the following:
   1. How many bits are used for the `byte offset` ? 16byte per block => 4bit to represent 1 to 16
   2. How many bits are used for the index field? 2^7 x 2^10 (kb to byte) / 2^4 = 2^13
   3. How many bits are used for the tag? 32 - 17 = 15

![[Pasted image 20211220152133.png]] 如果是這個的話最右邊的是只在一個 word 裏面 byte ofset 只有 1, 2, 3, 4 所以 2 bit, 但他說一個 block 大小是 16 words 所以需要 4 bits 來表示是第幾個 word 後面 2 bit 表示 word 裏面第幾個 byte, total 還是 6 bits (算法也可以想成 一個 block 16 words => 64 bytes 因此 6 個 bit 可以表示 0 - 63)

0 - 4 : 2 bit
0 - 8 : 3
0 - 16 : 4

5. Which of the following statements are true about cache write?
   (a) On write hit, write back policy will only update the data in cache, while write through policy will only update the data in memory.
   (b) On write hit, write through policy typically use a write buffer which is a LIFO with 4 entries. wrong, FIFO
   (c) On write hit, CPU might get stalled even if there is a write buffer in write through policy. true, if the buffer is full
   (d) On write hit, in write back policy, the data in cache will write back to memory only if the dirty block is replaced.
   (e) On write miss, write through policy will always fetch the block, while write back policy will always not fetch the block. 在 write through 有兩個可能性

重要! cache miss 之後補資料還需要再一次 cache hit

6. Which of the following statements are true about the memory？
   (a) SRAM is slower but cheaper than DRAM.
   (b) When accessing the magnetic disk, the accessing time of all the location are the same.
   (c) Loop is an example of spatial locality. (d) The unit of swaping data between memory and disk is page, and is managed by compiler. (e) When we increase the block sizes, the hit rate should reduce due to spatial locality (f) DRAM should be refreshed periodically.

SRAM 比較貴比較快
**loop 是 temrpoal locality example** instruction sequenctila
block sizes 增加 miss rate 有時候會減少 (due to spacial locality)
DRAM need to be refresh
