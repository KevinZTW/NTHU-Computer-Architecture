# Week8 ALU

## ALU

![[Pasted image 20211101132533.png]]

### `ALUop` 是 control signal

- 後面兩個 bit 是 mux 的 select input ( 00: 0 `and`, 01:1 `or`, 11:2 `add` )
- 前面兩個是 a invert, b invert

- 0000 and
- 0001 or
- 0010 add
- 0110 subtract
- 0111
- 1100

r type 最後面的 6bit function code 會剛好對應到上面一饃一樣的 control signal

### 1Bit ALU

#### Add 0010

![[Pasted image 20211101132639.png]]
`full adder `兩個 input 會產生 2 個 output sum + carry out

- mux 是 logcic design 學到的，他會根據 `select input 0, 1, 2` 來決定放哪一個過去
  - input 5 個 select input 要三個 ....bit?

#### subtraction 0110

![[Pasted image 20211101133226.png]]

- 2's complement 要顛倒之後 + 1 所以 B negate (0`1`10)
- 加一哪裡來? 就是額外給他一個 carry in,

#### nor 1100

![[Pasted image 20211101133435.png]]
透過一個 2 to 1 的 mux 來決定 a negate, b negate

#### set on less than 0111

- 11 = 圖中的 3
- B 要 negate 所以前面是 01

![[Pasted image 20211101133624.png]]

![[Pasted image 20211101133658.png]]

1-31 output bit 一定都是 0
第 0 個 bit (signed bit) 負數的話是 1 這個數字來自 第 31 個 signed bit 的運算

![[Pasted image 20211101133834.png]]

### overflow

在以下的情境 overflow 有機會發生

- add : different sign 不會，same 會
- sub : same 不會 different 會 -1 -2 or 3- (-3)

1. 2 positive become negative
2. 2 negative become positive

![[Pasted image 20211101133959.png]]
相加的時候可以看到當 MSB carry in 跟 MSB carry out 不同的時候表示 overflow 發生了

![[Pasted image 20211101134045.png]]
因此在 signed bit 的 carry in carry out 做一個 xor 互斥運算 就可以 detect 的到

c 會忽視 overflow, f 其他

### zero detection

0 的話表示每個結果都是零，因此用一個大的 nor gate (not a or b or )

## Add

### ripple carry adder

![[Pasted image 20211101134317.png]]
會有很長的 delay 時間

### 改良 1 carry lookahead adder

cin1= cout0 = (cin0 ∧ A0) ∨ (cin0 ∧ B0) ∨ (B0 ∧ A0)
cin2 = cout1 = (cin1 ∧ A1) ∨ (cin1 ∧ B1) ∨ (B1 ∧ A1)
= (((cin0 ∧ A0) ∨ (cin0 ∧ B0) ∨ (B0 ∧ A0) ) ∧ A1) ∨
(((cin0 ∧ A0) ∨ (cin0 ∧ B0) ∨ (B0 ∧ A0) ) ∧ B1) ∨
(B1 ∧ A1)

![[Pasted image 20211101134414.png]]
carry out = (b ^ carry in ) or (b ^ carry in ) or (b ^ a) 其中一個是 1 配上 carry 1 或兩個都 1

#### generate term

a 跟 b 兩個都是 1 我不用看別人眼色，自己就一定會有 carry out
**gi : ai ^ bi**

#### propagate term

決定 cin 是否可以傳遞下去，如果 a b 任一是 1 就一定會在產生一個 carry out 兩者都 0 才會吃掉不傳下去
**pi : ai xor bi**

cin 4 = `g3` + `g2`_p3 _ + `g1` *p2*p3 + `g0` * p1p2p3 + `c0` *p0 p1 p2 p3
![[Pasted image 20211101134813.png]]
![[Pasted image 20211101134822.png]]

柿子跟硬體設計都會變很複雜因此 A common practice is to build smaller N-bit carry lookahead adders and then connect them together to form a bigger adder.

### cascaded carry lookahead adder

目前理解是，剛剛提到的 carry lookahead 的方式可以讓 不管幾個 bit 的相加都在 2 gate delay 之間搞定但硬體很複雜，所以只有個個 unit 是 carry lookahead (計算 小 i 小 j 1 gate delay) carry lookahead 計算 2 gate
![[Pasted image 20211101135315.png]]

![[Pasted image 20211101135411.png]]
第一個算完 delay 下一個 c8 等前面算完.....

stage dealy 算法似乎是 all bits / 一組 然後要再 \* 2(adder mux delay)

step 1 : pi gi 先花 1 個 gate delay time
step 2 :所以第一個 gate 花費時間是 1 + 2, 第二個 gate 等他完成後再花 2 兩個 第三個完成後再花 2 個 第四也是 所以是 3 +2 +2 +2 = 9 (gate dealy) 如果是 stage 的話是 4 stage delay

為什麼 carry lookahead gate delay 是 2 呢? 老師舉了兩種水管圖作為栗子

我的理解搭配網路文章的講法，2 指的應該是下圖中的第二第三層的 gate 而下圖中第一層則是老師說可以第一時間同時算，出題時有時候會說可以立即拿到的 小 gi pi

- ![[Pasted image 20211101162120.png]]

### multiple level carry look ahead adder

想要 c8 c16 c24 先知道
產生 super pi gi 把一個 block 看成一個 bit ，下面的圖第一張比較好理解，總之呢假設是 `4` bit ，那 1~4 算出來的丟到第二層給 5~6 用 5~6 在同時也會丟到第二層....
然後再把剛剛丟上去的加回來揪搞定了 (我自己的理解)

要算延遲幾次(stage delay) 是....
假設 64 bit 一組 4 bit 那就是三層，老師上課中有說這樣應該是三個 stage delay ...但後來有點模糊，不過在計算 gate delay 時確定是

1. 計算第一層 小 gipi (1) 注意題目是否說可忽略
2. 計算第一層 大 GP (2)
3. 計算第二層大 GP (2)
4. 計算第三層大 GP(2)
5. 結果加回第二層 (2)
6. 結果加回第一層 (2)

什麼是大 P? 全部 propgaget po p1 p2 p3 都過，表示這個 bit 會 propgagte
什麼事 大 g? 第一個 g 後面都 pro 第二個 g 後面 p

![[Pasted image 20211101135807.png]]

![[Pasted image 20211101135821.png]]

![[Pasted image 20211101135857.png]]
先算....
![[Pasted image 20211101135908.png]]

4 個 bit 一個 block
16 bit 2 levle
64 ...? => 64/ 4 = 16 16/4 = 4 4/4 =1 三層

### carry select adder

先算出兩種情況，再看看 out 是 0 或是 1 來選是那一種結果
![[Pasted image 20211101140200.png]]

32 => 16 16 delay 因此是 16 bit 的 dealy 加上 mux 2 to 1 的 delay

### gate / stage delay

gate delay 是邏輯們

multilevel 如果兩層: 題目問 c13.... 15

- carry lookahead 一組是 2 個 gate delay

1. 先算 小 p 小 g (通常不用算)
2. 算出第一層每一組的 大 p 大 g
3. 到第二層算出第二層的 大 p 大 g

## 問題

- 8bit unit/ 32 bit total / cascade C15 ?
  - c15 是 A15 B15 計算結果，而這個會需要
    - 小 g i (1)
    - 計算出大 GI (2)
    - 上一層計算出 C8, 16, 24, 32 (2)
    - 用 C8 AB8~15 unit 計算得到 C15 (2)
