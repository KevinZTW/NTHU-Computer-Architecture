# Week 16 Memory Support

# Memory Design

![[Pasted image 20211225130729.png | 700]]

- One word wide : bus 一次就一個 word
- Wide : 把 memory 跟 bus 都加大，但硬體 cost 比較大因為一次就要固定讀到更多資料
- Interleaved : 利用讀完之後還要等 cycle time 的特性，我在等 cycle time (回復 DRAM 的時間) 一筆一筆送資料，這樣 bus 不用做到跟 wide 一樣大但是速度可以接近

### Access time 跟 Cycle time 的關係

![[Pasted image 20211225130955.png |400]]
access time : access 進去 data ready 的時間
cycle time : 一個 access 之後到下一筆 access 之間的時間
為什麼中間有一個間格？是因為 DRAM 的設計我讀出來之後還要寫回去

- One word / Wide 第一筆結束之後才能下一筆，紅色的部分是 transfer time
- Interleaving : 因為還是 sequential transfer, 1 2 3 4 一一 transfer 完畢才能開始下一組

### Miss penalty

假設 :

- 1 memeory clock 送地址
- 15 for each DRAM access initiated
- 1 for send word data
- cache block = 4 words

- One word wide bank : **1 + 4x15** + 4x1 = 65
- Four word wide bank (表示一次可以 access 4 word): 因為一次 `15` 可以 access 4 word `(+1)` 因為 4 個 word 可以同時 transfer
- Four-bank one word wide **bus** = `1` + `1x15` (因為一次 4 個 bank 各自讀一個 word) `+4x1` 因為要 sequential 傳輸

### Access DRAM

![[Pasted image 20211225132333.png]]
DRAM sub devided
先走上面，用 11 bit row address 把整個 row 讀下來，再用 11 bit column address 讀我要的

因此寫程式就要遵循這種 **row major** 特性

### Measuring Cache Performance

Below two would use memory

- Instruction fetch
- lw, sw

**Cache Miss 的時候不會把 CPU 交給別人! 因為 Penalty 沒那麼大交出去 overhead 不合算**

- Cache Miss = Base CPI + (miss rate \* miss penalty)

- Average memory access time (AMAT) = Hit time + Miss rate × Miss penalty

每一個 access 都有 hit 這件事情! miss 的時候我是把資料帶上來然後重新去讀一次

# Cache Improvemet

## Associate Cache

- 一個家兩個三個四個......房間，叫做一個 set

- direct map <-> fullay assoicate <-> n-way set associate
- each set has n entries
- Block number determines with set (block number module numbers of sets)
- search all entries in the given set

![[Pasted image 20211225134003.png]]

### 重點是一個 Set 裏面可以擺幾個 block

- 1 個的話就是 direct map

![[Pasted image 20211225151805.png]]

- direct map 有 0, 1, 2, 3 四個 cache
- Block address 透過 mod 換算成 cache index(第幾個 cache)
- 0, 4, 8, 16 都會 map 到第 0 個

### 2- way

![[Pasted image 20211225151911.png]]

- 跟剛剛一樣有 4 個 cache 但現在改成分兩組，所以編號只有 0, 1
  - 0, 2, 4, 8 都會 map 到 index 0
  - 剩下會到 index 1

### fully associative

- 變成不用 mod 全部都可以放
- 要靠一大堆 hardware **同一個時間點**一次性全部讀出來，全部比 tag

### How much assoicative?

**隨著上升，好處會遞減，因為當總大小固定隨著一個 Set 大小增加會到那個 set 的成員也越來越多**

### example - 4 way

![[Pasted image 20211225152224.png]]

- 四個 tag 都要讀出來，看是 hit 還是 miss
- 當 cache 大小固定， assiciative 數量上升，index 就會減少讓 tag 可以增加
  - 是因為 set 會下降

### Comparing Data Available Time

- Direct mapped cache
  - Cahce 可以先拿來用反正一定是他(如果沒 miss 的話)
- n-way
  - 不行

Direct mapped cache
Cache block is available BEFORE Hit/Miss:
Possible to assume a hit and continue, recover later if miss

N-way set-associative cache
Data comes AFTER Hit/Miss decision
Extra MUX delay for the data

### Data Replacement Policy

Direct map 沒有 replacement 的問題，他就直接換掉了
n-way, fully 會有

- Random
- LRU
  - pseudo LRU

## Multiple level cache

**只要講到 cache 就一定是在 processor 裏面** 記憶體越小越快

- L1, L2

## Advanced Out-of-order CPU

更難預測，因為 out of order CPU

## Interaction with Software

老師說非常重要

Radix Sort (n) 因為 cache miss 很大，因此

基數排序法 (Radix Sort) data 的 locality
quicksort locality 比較好

1. 時間序
   助教說這邊應該是 3 way 不是 3 cache set

老師說用 3 當作 set number 好不好? 不好因為我們實際 hardware 在運作的時候是去取 binary 中間的幾個 bit 這樣是 2 進位的，如果是要對到 3 ....

2.  A. To improvement cache performance we decrease the miss ratio miss penalty and reduce the itme to hit tinthe cahce = > True
    B. True, LRU in hardware is costly due to the high hardware complexity
    C. 錯的 not specified cache location
    D. False, in direct mapped cache, before hit/miss cache block is available (老師說如果是 direct mapped 只有一筆反正只有 miss / hit 他就可以先拿去做，只要之後再來決定是否寫入就好了)

3.  which of following statement are true?
    a. The number of virtual pages is always smaller or equal to the number of physical pages **老師說這兩者關西沒有一定!**
    b. Page is the basic unit of virtual memory =>yes
    c. Traslation `miss` in virtual memory is called a page fault
    d. Virtual memory maps cache to memory
    e. the state goes from ready to waiting when IO interrupt

4.  There are two computers with the same CPUs but different caches. One's cache is three levels with L-1 miss rate to L-2 = 5%, L-2 miss rate to L-3 = 2%, and L-3 miss rate to main memory = 0.5%. The other's cache is two levels with L-1 miss rate to L-2 = 3%, and L-2 miss rate to main memory = 1% and. Assume that CPU base CP| = 1, clock rate = 4GHz and both caches has same level access time L-2 access time = 5ns, L-3 access time = 20ns, main memory access time = 120ns. Which one's performance is better? Please explain it.

4GHz => 1 second 4 \* 10^9 => 0.25 ns?

1. CPI + L1 miss (5%) _ 5ns + L2 miss(2%) _ 20ns + L3 miss(0.5) \* 120ns
2. CPI + L1 miss(3%) + L2 miss(1%)

3. The Average Memory Access Time equation (AMAT) has three components: hit time, miss rate, and miss penalty. For each of the following cache optimizations, indicate which component of the AMAT equation is improved.

(A). Using a second-level cache : 主要是 miss rate (L1, L2..)
(B). Using a direct-mapped cache : hit time
(C). Using a 4-way set-associative cache : miss rate
(D). Using a non-blocking cache (While handling the cache miss, CPU can choose the right instruction to execute in no hazard by using Out-of-order CPU) : miss penalty
(E). Using larger blocks : miss rate

1 memory bus

1 + 10 x 8 + 1 x 8 = 89
1 + 10 x 2 + 1 x 2 = 23
1 + 10 x 2 + 1 x 4() = 29
