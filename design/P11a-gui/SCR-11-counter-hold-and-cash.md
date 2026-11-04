# P11a - SCR-11 Giữ ghế và thu tiền mặt (Hold seats and collect cash) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P04 UC-005 1.8 (bước 8, luồng 9a, 9a1, 9a1a, 9a2, 7b, *a, Dữ liệu ra 2); P05 GL-52; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-11 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-11 |
| UC | UC-005 |
| Bước UC | 8, 9a1, 9a2; luồng 9a1a, 7b, *a |
| Tác nhân | ACT-02 Nhân viên quầy |
| Boundary AC | AC-B-CounterBookTicketsForm (showHeldSeats, confirmCashReceived, notifyRefusal) |
| DC | DC-CounterBookTicketsView, DC-CounterBookTicketsStore |
| Loại màn hình | Phụ thuộc có dữ liệu (lần giữ ghế) |
| Đến từ | SCR-10 (E-23) |
| Đi tới | SCR-12 (E-25), SCR-09 (E-26) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Giữ ghế và thu tiền mặt                                      |
| (vùng thông điệp: MSG-20, MSG-26)                            |
| +--------------------------------+ +----------------------+ |
| | Phim A, 2D, Phòng 3            | | Thời gian giữ ghế    | |
| | 15/11/2026 19:30               | | còn lại              | |
| | Ghế    | Loại    |   Giá vé    | |      07:15           | |
| | F7     | Ghế VIP | 120.000 đ   | | Hết hạn lúc 19:02:11 | |
| | F8     | Ghế VIP | 120.000 đ   | +----------------------+ |
| | Tổng tiền cần thu  240.000 đ   |                          |
| +--------------------------------+                          |
|          [ Huỷ giữ ghế ]  [ Xác nhận đã thu tiền mặt ]      |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Giữ ghế và thu tiền mặt" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-20, MSG-26 | Dưới tiêu đề | UI-STT 08 |
| Nội dung chính | Suất chiếu, bảng ghế đã giữ, tổng tiền cần thu | Cột trái từ 1024 px | UC-005 Dữ liệu ra 2 |
| Vùng phụ | Khối đồng hồ đếm ngược | Cột phải từ 1024 px | UI-STT 43 |
| Hành động | Huỷ giữ ghế (nút phụ), Xác nhận đã thu tiền mặt (nút chính) | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện suất chiếu, bảng ghế đã giữ (vị trí, loại, giá vé), tổng tiền cần thu, đồng hồ đếm ngược. Cài hộp cảnh báo của trình duyệt khi đóng hoặc tải lại trang | UC-005 bước 8, Dữ liệu ra 2; BR-10, BR-13 |
| 2 | Khối đồng hồ | Vùng hiển thị | Hết thời gian | Như SCR-05. Về 00:00: vô hiệu hai nút, hiện MSG-29 và mở SCR-09 | UC-005 luồng 7b; BR-10; MSG-29 |
| 3 | Nút Xác nhận đã thu tiền mặt | Nút chính | Nhấn | Mở hộp xác nhận MSG-22 nêu tổng tiền. Xác nhận: gửi xác nhận, hiện MSG-26. Tới trước hạn: mở SCR-12 với mã đặt vé và vé. Tới sau hạn: hiện MSG-20 và mở SCR-09, nhân viên trả lại tiền mặt cho khách | UC-005 bước 9a1, 9a2, luồng 9a1a; BR-13, BR-44; MSG-20, MSG-22 |
| 4 | Nút Huỷ giữ ghế | Nút phụ | Nhấn | Mở hộp xác nhận MSG-18. Huỷ giữ ghế: giải phóng ghế, mở SCR-09 kèm MSG-19 | UC-005 luồng *a; MSG-18, MSG-19 |
| 5 | Mục Trang chủ (menu) | Liên kết | Nhấn | Hiện hộp MSG-77; Rời trang mở SCR-09 và lần giữ ghế vẫn chạy đến hết hạn | UC-005 bước 7, BR-04, BR-10; MSG-77; Q-119 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Suất chiếu | - | Chữ | Hiển thị | Phim, định dạng, phòng chiếu, ngày giờ bắt đầu | - | UC-005 Dữ liệu ra 1 STT 1 |
| Ghế đã giữ (vị trí, loại) | - | Chữ | Hiển thị | Mã hàng, số ghế, loại ghế | - | UC-005 Dữ liệu ra 2 STT 1 |
| Giá vé từng ghế | Q-124 | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | - | UC-005 Dữ liệu ra 2 STT 2 |
| Tổng tiền cần thu | Q-124 | Tiền | Hiển thị, căn phải | Tổng giá vé các ghế đã giữ | Khớp tổng các dòng | UC-005 Dữ liệu ra 2 STT 3; BR-13 |
| Thời điểm hết hạn giữ ghế | 8 | Giờ | Hiển thị | HH:mm:ss | Thiết kế: giờ máy chủ đã hiệu chỉnh độ lệch | BR-10; GL-52 |
| Thời gian còn lại | 5 | Giờ | Hiển thị, 32 px đậm | mm:ss từ 10:00 đến 00:00 | - | BR-10 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-11 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận thu tiền nêu số tiền (MSG-22) và xử lý xác nhận trễ bằng MSG-20 | - |
| SCR-11 | WCAG 3.3.4 Ngăn lỗi tài chính | Đạt | Xác nhận trước khi chuyển ghế sang đã bán | - |
| SCR-11 | WCAG 2.2.1 | Đạt | UI-STT 36, 43 | - |
| SCR-11 | Nielsen 3 | Vi phạm còn mở | Rời trang thì không có lối quay lại lần giữ ghế (Q-119); không gia hạn vì BR-10 | Chờ Q-119 |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 27-31, 33-35, 37, 43.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-119, Q-124.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-B-CounterBookTicketsForm | showHeldSeats chưa nêu thời điểm hết hạn giữ ghế để vẽ đồng hồ | Thêm thời điểm hết hạn vào dữ liệu hiển thị |

## Vấn đề còn mở

Q-119 ảnh hưởng cả kênh quầy.
