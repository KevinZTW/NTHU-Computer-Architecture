# Virtual Memory

- [geek for geeks 可以練習的題目](https://www.geeksforgeeks.org/gate-gate-cs-2001-question-46/?ref=lbp)

Ch6-5-2 Virtual memory - Issues in virtual memory (13:44) (page 81-90)  
Ch6-5-3 Virtual memory - Handling huge page table and TLB (11:20) (page 91-100) Ch6-5-4 Virtual memory - TLB and cache (9:37) (page 101-105)  
Ch6-6 A common framwork for memory hierarchy (11:27) (page 106-114)

[[OS Process]]
[[OS Virtual-Memory Managment]]

這邊是用 **fully associative** 因為搬進搬出 penalty 太高了，盡量不要讓我被踢出去，mapping 則是靠 page table

- 在 cache 的時候都是 hardware translate 的
  因為程式常常在 IO 我們想要 multiprogramming => 每個程式都需要 memory => virtual memory => 總之就是要個 translation, software approach

## Issue in virtual memory

- size of data block 要大一點，因為一次搬需要很多 IO 時間，搬太小划不來
- placement : 我們用的是 fully associate 的方式，因為 page fault 要花很多時間，有位置的話就還是把它留著不要踢掉
- page fault : 才會從 disk

- huge miss penalty (在 disk 但沒有在 main memory)

page table 從哪裡放起? 會有一個 base like 3300 加上新的 offset

**virtual page number -> physical page number ??!不是對應到 frame 喔？**

### Page Tables

- 一但 Page fault 發生都是 OS 處理 (trap)，不像是 cache 是 hardware 處理 (huge miss penalty)不能繼續霸佔著 CPU (context swithcing would happen)，等他處理好再來重新讀取一遍 （注意之前 cache 是霸著 stall)

- Process
  - pick the page to discard
  - load the page in from disk
  - update the page table
  - resume to program
- 什麼時候會 fetch missing item

### Page replacement

- 實際實現 LRU 很困難，因此用一個近似的方式，用一個 reference bit (use bit) 一陣子就會清成零，有用到就設成 1

### Huge Page table

即便我們放在 cache 我們還是會需要拿到實際地址才有辦法查，

- address 沒有一次要全部用到，給兩個 bound register (one for stack, one for heap)
- using hash => page table same size as physical pages
- 多層式的，紀錄第一組有沒有打開，打開的話我再展開....

## TLB 很重要

- 因為 Page size 很大(4kb) 我就算是程式執行左右跳一段都還在同一個 page，因此 locality 會比 cache 大很多 => 會一直用到同一筆 entry

- 擺在 CPU 裏面 (by the way cache 都在 CPU 裏面)

## TLB (Translation Lookaside buffer) and Cache

要注意 TLB 只是

為什麼 TLB 跟 page table 都要 toggle dirty bit ?

write back policy 的時候，他會在 page table 裡面找到一個很久沒用的這時候
所以這時候 page replacement 要檢查是否 dirty 要寫回要先到 TLB 再去 page table 茶嗎

老師說當 資料被 swap 掉的時候，cache 裡面的資料都要 invalidate 掉

## Cache block vs virtual page

![[Pasted image 20220109172422.png]]

![[Pasted image 20220109172541.png]]

## 提一提而已

### finite state machine for cache

##

Please choose which are false?

- Fetching missing items from disk only on page fault is called demand load policy =>true
- Page table which sotres palcement information is in disk. wrong on main memory
- Hardware must detect page fault and it can also handle the faults => wrong, page fault handle by OS
- Pages write policy use write-through to write data =>wrong write back, 因為時間會太長是 IO 動作
- there are twice memory accesses for each address translation => yes only if we not considered TLB

Consider TLB hit ratio is 80%, 20ns for TLB lookup, 100ns for memory access, and hold page table is on memory (Effective Access Time can seem as average access time please don't care about cache in this question).
Hint : TLB is high-speed hardware which can be part of the instruction pipeline, adding no performance penalty

1. What is effective access time?

80% (20+100) + 20% (20+100+100) = 96 + 44 = 140

2. if we want effective access time down to 125ns, what TLB hit ratio hwould be
   120x +220(1-x) = 125
   => 95 = 100x x = 95%

which following statements is false?

- Becasue miss panalty is huge, pages should be fairly large => yes
- we use direct mapped placement in memory to locate pages. => wrong, should be fully associate
- page table is stored in main memmory => yes
- page table store the translation data of virtual address to physical address.

in a virtual memory system, size of virtual address is 32-bit, size of physical address is 30-bit, page size is 4 Kbyte and size of each page table entry is 32-bit. The main memory is byte addressable. What is the maximum number of bits that can be used for storing protection and other information in each page table entry?

#### **page table 不用存 offset!!!**

- Page size = Frame size
- 不要記錯成 page number = frame number
  老師說用這個比較好
  page size 4kb = 2^12 byte, 因此需要 12 bit for offset
  Virtual address 32 = 20 + 12
  Physical address 30 = 18 + 12

因此 32 -18 = 14

6. Which of the following about TLB is true?

- TLB's miss rate is relatively high compare to cache => wrong low, since page size is big, TLB locality is also bigger
- TLB is used for fast translation from virtual page number to physical memory => yes
- TLB misses could only be handled by hardware =>wrong both hardware and software could
- It is possible that TLB is a hit but page table is a miss => wrong, TLB is the subset of the page table
- 補充 cache miss handle by hardware
