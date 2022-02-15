# Week9

## MIPS 乘法

- 因為 `mult rs,rt` `multu rs rt` 32 bit 乘以 32 會有 64 bit 會放不下，因此會用兩個 register 去記他
  - 要高位就 `mfhi rd`
  - 低位就`mflo rd`

### Unsigned 乘法第一版

![[Pasted image 20211109231936.png | 600]]
![[Pasted image 20211109231822.png | 600]]

- `被除數` `除數`都要 shift
- 除數看最右邊一位，是 1 就把被除數加進 product，右移
- 被除數左移 (因為除數右移)
- 發現有很多的浪費，`multiplicand` 有一半都是 0

### Unsigned 乘法第二版

- 原本是要動 motificant 改成 shift partial product

![[Pasted image 20211108133707.png | 600]]
![[Pasted image 20211108132830.png | 600]]
紅色放完之後會 right shift ，接下來綠色

- 0101 \* 0011
  ![[Pasted image 20211109232715.png |600]]|

- 其實跟第一版概念一樣，會被一位一位判定跟丟掉的是除數 `Multiplier`

### Signed Multiply

- 方法 1 : 兩個都當成 unsigned (這次只做 31 次操作) 做完再來依照正負設置 signed bit
- 方法 2 : 透過 2's complement 的定義 - Rule 1 : `Multiplicand sign extended` - Rule 2 : 0 => 0 x multiplicand 1 => -1 x multiplicand
  why rule 2 ? - x = sxn-2 xn-3.... - value(x) = -1 x s x 2^n-1 + .....
  ![[Pasted image 20211109233751.png]]

- 下排除數最右邊一位是 1 所以 1001 左邊 signed extension 補滿 1
- 接下來的操作都一樣，需要 signed extension
- 最後一行用減去的 (因為 2's complement 最後一位是-1?)
- https://www.youtube.com/watch?v=xjVZqtWm_ts&ab_channel=KarthikVippala

#### Both multiply

我放棄

### Faster Multiplier

剛剛提到的做法都是 `squencial circuit` 因為一個 bit 操作完之後都要把東西加到 register.. 判斷..再做下一個 bit 因此要 32 個 clock cycle 才做完

#### Combinational Multiplier

![[Pasted image 20211108134037.png | 600]]
希望在`一個 clock cycle` 同一個時間把每一個一起加起來，中間不希望再有暫存

#### Wallace Tree Multiply

要用一個 `carry save adder`
![[Pasted image 20211108134316.png | 600]]

8 - bit wallace tree multiplier
log n 的高度
![[Pasted image 20211108134408.png | 600]]

## MIPS 的除法

### 第一版

- 不夠減補 0 的時候是把被除數剩下的部分 right shift!

![[Pasted image 20211104113254.png| 600]]

![[Pasted image 20211108123723.png | 600]]

1. dividend 被除術放到 remainder
2. remainder - divisor
3. \> 0 表示夠減，quot 左移 quot 第一個 bit 設成 1
4. < 0 表示不夠減，把 divisor 加回去回覆， quot 左移 quot 第一個 bit 設成 0
5. divisor 往右 shift 一位
6. 完成 32 次操作

### 第二版

remainder 高位是什麼？低位是什麼?

一開始 remainder 先左移一次，之後 remainder 左移

![[Pasted image 20211108122709.png]]
(左移空出位置給 quotient)

1. dividend 被除術放到 remainder (一樣)
2. remainder 左移一位
3. remainder 左邊的部分減去 divisor

![[Pasted image 20211108123625.png]]

### 剛剛的假設

剛剛的操作都是基於 `兩者都是正數` 所以在負數的情況都先轉成正數

1. dividend 被除數跟 remainder 餘數會被射成同樣的符號
2. dividend, divisor 不同號時 quotient 就要設成負數

## Floating point 的表示

1.x (two)/\* 2^y(two)

- s 表示正負數 sign
- expoent 表示 y's
- signigicand 表示 x

- single Precision
  ![[Pasted image 20211108124147.png]]

- Double Precision
  ![[Pasted image 20211108124456.png]]

更多的 bit 放在 signigicant 表示我們在意的是精確度

### IEEE 754 規格

#### exponent

- 想要讓我們可以用 integer 來讓我們很快就可以比較大小 (我理解為 unsigned 方法)，因此要用 `biased notation`
  ![[Pasted image 20211108124932.png|100]]

#### Deciaml to FP

![[Pasted image 20211108140412.png]]

整數 >1 是用除的 <1 是用乘的

老師問 分數怎麼做？
![[Pasted image 20211108140443.png]]

### single precision range

- exponent 的部分因為 `000000` 和 `11111`都被保留了，因此最小是 `00000001` => 1- 127 = -126 (significand `00000000` 剩下 hidden one) 得到 `1.0 x 2^-126` 大略等於 2.2 x 10^-38 但是這個是 normalized 的最小

- de-normalized 最小是

```
0/1 00000000 00000000000000000001
1		8			24
= 2^-24 x 2^-126
```

### Special Numbers

![[Pasted image 20211108130448.png|500]]
![[Pasted image 20211108130708.png|400]]

#### zero

```
S 00000000 00000000000000000000 (all zero)
```

#### Gradual Underflow 表示很小的數字

```
0 00000000 00000000000000000001
1		8			24
= 2^-24 x 2^-126
```

本來有 hidden one 的，但這個情況就不去加上 hidden one，看到 exponent `0000 0000` 就作為 2^-126

#### 無限大

```
S 11111111 00000000000000000000 (all zero)
```

#### NAN 協助 debug

```
S 11111111 00000000000100000000 (non zero)
```

## Floating Point 操作

### Floating Point 加法

1. 要先 right shift smaller number 對其小數點再相加 ( 比較小的 2^-100 去對其別人)
2. mantissa 相加
3. normalization & check for overflow

```
1.000(two) x 2^-1
- 1.110(two) x 2^-2 (0.5 + -0.4375)

//algin number with smaller
1.000(two) x 2^-1
- 0.111(two) x 2^-1

//add mantissa
1.000 x 2^-1 + - 0.111 x 2^-1 = 0.001 x 2^-1

//normalzied result 1.000 x 2^-4

```

![[Pasted image 20211110152722.png | 500]]

- 很複雜需要很多個 cycle 才做得完

### Floating Point 乘法

```
//0.5 + -0.4375
1.000(two) x 2^-1
- 1.110(two) x 2^-2

//exponent 部分相加，但要再減去一個 Bias 不然會減去兩次
-1 => (-1+127) = 126
-2 => (-2+127) = 125
-3 =>  (-1+127)+(-2+127) -127 = -3 + 127

//mantissa 相乘
1.000(two)x1.110(two) = 1.1102(two) => 1.110(two) x 2^-3

//Normalize

//Round and renormalize
//Determine sign
-1.110(two) x 2^-3
```

```
0001 = 1 - 7 = -6
0010 = 2 - 7 = -5
兩個直接相加
0011 = 3 - 7 = -4 (但其實應該要是 -11)

```

### Floating Point 架構

![[Pasted image 20211108141952.png | 500]]
不再 CPU 裏面是在一個 coprocessor 裏面

### MIPS Floaring 指令

- 會有獨立的指令給 floating point `add.s` `sub.s` `mul.d`

- separate load and store `lwc1` `swc1`

## 問題

Under the IEEE 754 Standard, please convert two following binary to the decimal floating point.
Hint : The IEEE 754 floating point number representation would use 8 bits for the exponent

1. 11000001110100000000000000000000
2. 00111111001100000000000000000000

Ans
1): -26.0 1. the first 1 means negative 2. 1000 0011 = , 131 -127 (for bias adjustment) = 4 3. 101000... = 1 (hidden one) + 2^-1 + 2^-3 = 1.625
-1 x 1.625 x 2^4 = -26.0

2): 0.6875 1. the first 0 means positive 2. 0111 1110 = , 126 -127 (for bias adjustment) = -1 3. 0110000... = 1 (hidden one) + 2^-2 + 2^-3 = 1.375
1 x 1.375 x 2^-1 = 0.6875

## 實際操作

### 乘法
