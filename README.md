# Infix Postfix Prefix Conversion
ĐỒ ÁN POLISH NOTATION
KIẾN TRÚC MÁY TÍNH VÀ HỢP NGỮ

Ý TƯỞNG THỰC HIỆN 
VÀ MÔI TRƯỜNG LẬP TRÌNH

1.	Ý tưởng thực hiện

a.	Các bước giải quyết bài toán

Bước 1: Đọc từ file input  ra buffer, từ buffer tách thành từng dòng.

Bước 2: Phân tích mỗi dòng thành 2 mảng: 1 mảng data[] chứa các toán tử và toán hạng và 1 mảng isOP[] có các phần tử mang giá trị 1 nếu vị trí tương trong data[] là toán từ, mang giá trị 0 nếu vị trí tương trong data[] là toán hạng.

Bước 3: Từ kết quả phân tích ở bước 2 tiến hành đọc và chuyển sang dạng hậu tố (postfix) và tiền tố (prefix).

Bước 4: Ghi kết quả ra file.

b.	Thuật toán sử dụng

-	Thuật toán chuyển từ dạng trung tố sang hậu tố:

❖ Khởi động stack rỗng (Stack chứa toán tử)

❖ While (không có lỗi và chưa hết biểu thức)

o Đọc Token (Token = hằng/biến/toán tử số học /ngoặc trái/

o Nếu Token là

➢ Ngoặc trái:Push vào stack.

➢ Ngoặc phải: Pop và hiển thị các phần tử của stack đến khi gặp ngoặc trái (pop ngoặc trái nhưng không hiển thị ngoặc trái). 

➢ Toán tử : Nếu stack rỗng hay Token được ưu tiên hơn phần tử ở đỉnh stack thì Push vào Stack .Ngược lại (ưu tiên bằng hoặc ít ưu tiên hơn) pop và hiển thị 1 phần tử ở đỉnh stack .Lặp lại việc so sánh Token với 1 phần tử ở đỉnh stack. 

➢ Toán hạng : hiển thị nó.

❖ Khi hết biểu thức trung tố Pop và hiển thị toàn bộ stack còn lại.

-	Thuật toán chuyển từ dạng trung tố sang tiền tố:

Bước 1 : Đảo ngược biểu thức trung tố . Lưu ý : trong khi đảo ngược thì dấu ngoặc trái ‘(‘ sẽ thành ngoặc phải ‘)’ và ngược lại .

Bước 2 : Sử dụng lại thuật toán trung tố sang hậu tố ( với biểu thức trung tố là biểu thức ở bước 1 ) và tìm được biểu thức hậu tố .

Bước 3 : Đảo ngược lại biểu thức hậu tố tìm được ta sẽ có biểu thức tiền tố.


-	Thuật toán tính giá trị biểu thức hậu tố:

❖ Khởi động stack rỗng.

❖ Lặp lại các bước sau đến khi hết biểu thức:

o Đọc Token (Hằng ,biến , toán tử)

o Nếu Token là : 4*12/3+1-> 4 12 * 3 / 1

➢ Toán hạng: Push vào stack

➢ Toán tử:

• Pop 2 giá trị

• Áp dụng toán tử cho 2 giá trị lấy ra.

• Push kết quả vào stack.

Lặp đến hết biểu thức, giá trị ở đỉnh stack là giá trị của biểu thức.

-	Độ ưu tiên của các toán tử: ‘(’ < {‘+’,’-‘} < {‘*’,’/’}


2.	Môi trường lập trình

a.	Ngôn ngữ lập trình: MIPS

b.	IDE: Mars 4.5
