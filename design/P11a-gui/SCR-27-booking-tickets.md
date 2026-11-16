# P11a - SCR-27 Vé của lần đặt (Booking tickets) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-007 1.2 (bước 5, Dữ liệu ra 2, BR-94, BR-140); P05 GL-18, GL-32; P07 UC-007; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-27 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-27 |
| UC | UC-007 |
| Bước UC | 5 |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-ViewBookingHistoryForm (showBookingTickets) |
| DC | DC-ViewBookingHistoryView, DC-ViewBookingHistoryStore |
| Loại màn hình | Phụ thuộc có dữ liệu (lần đặt đã chọn) |
| Đến từ | SCR-26 (E-50) |
| Đi tới | SCR-26 (E-51) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------------+
| CineBook   Trang chủ                                 [ Đăng xuất ] |
|------------------------------------------------------------------|
| Vé của lần đặt CB0001234                                           |
| (vùng thông điệp: MSG-72, MSG-73)                                  |
| Phim A (2D) - CineBook Cầu Giấy - Phòng 3 (IMAX) - 15/11/2026 19:30|
| +--------------------------------------------+                     |
| | Ghế F7, ghế VIP        120.000 đ           |  [ Mã QR ]          |
| | Trạng thái: Chưa sử dụng                   |                     |
| +--------------------------------------------+                     |
| | Ghế F8, ghế VIP        120.000 đ           |  [ Mã QR ]          |
| | Trạng thái: Chưa sử dụng                   |                     |
| +--------------------------------------------+                     |
|                               [ Quay lại danh sách lịch sử ]        |
+------------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Vé của lần đặt" kèm mã đặt vé | Dưới đầu trang | UI-STT 09 |
| Thông tin suất chiếu | Phim, định dạng, cụm rạp, phòng chiếu và loại phòng, ngày giờ bắt đầu | Đầu nội dung | UC-007 Dữ liệu ra 2 STT 2-6 |
| Nội dung | Một thẻ cho mỗi vé: ghế, loại ghế, giá vé, mã QR, trạng thái | Giữa | UC-007 Dữ liệu ra 2 STT 7-11 |
| Hành động | Nút phụ Quay lại danh sách lịch sử | Cuối, căn phải | UI-STT 06, 51 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện các vé của lần đặt đã chọn (mỗi ghế một vé); dữ liệu lần đặt và vé không đổi. Nội dung vé giữ tên phim, cụm rạp, phòng chiếu, loại phòng lúc bán dù thông tin gốc đã sửa | UC-007 bước 5, Dữ liệu ra 2; REQ-30, REQ-105; BR-140 |
| 2 | Thẻ vé | Vùng hiển thị | Khởi tạo | Mỗi thẻ: vị trí ghế, loại ghế, giá vé, mã QR, trạng thái vé (Chưa sử dụng, Đã sử dụng, Đã huỷ). Trạng thái có biểu tượng và chữ, không chỉ màu | UC-007 Dữ liệu ra 2 STT 7-11; Q-159; UI-STT 13 |
| 3 | Hình Mã QR | Hình | Khởi tạo | Hiện mã QR riêng của vé, có văn bản thay thế "Mã QR của vé ghế F7, mã đặt vé CB0001234" | UC-007 Dữ liệu ra 2 STT 10; UI-STT 34 |
| 4 | Nút Quay lại danh sách lịch sử | Nút phụ | Nhấn | Mở SCR-26 | UI-STT 51 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Mã đặt vé | 20 | Chữ | Hiển thị | Mã của lần đặt chứa vé | - | UC-007 Dữ liệu ra 2 STT 1 |
| Tên phim | - | Chữ | Hiển thị | Tên lúc bán | - | UC-007 Dữ liệu ra 2 STT 2; BR-140 |
| Định dạng phim | - | Lựa chọn | Hiển thị | 2D hoặc 3D | - | UC-007 Dữ liệu ra 2 STT 3 |
| Tên cụm rạp | - | Chữ | Hiển thị | Tên lúc bán | - | UC-007 Dữ liệu ra 2 STT 4; BR-140 |
| Tên phòng chiếu và loại phòng | - | Chữ | Hiển thị | Phòng 3 (IMAX); loại phòng Thường, 4DX hoặc IMAX | - | UC-007 Dữ liệu ra 2 STT 5 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm | - | UC-007 Dữ liệu ra 2 STT 6 |
| Vị trí ghế | 6 | Chữ | Hiển thị | Mã hàng in hoa liền số ghế (F7) | - | UC-007 Dữ liệu ra 2 STT 7; UI-STT 10 |
| Loại ghế | - | Lựa chọn | Hiển thị | Ghế thường, ghế VIP hoặc ghế đôi | - | UC-007 Dữ liệu ra 2 STT 8 |
| Giá vé | 12 | Tiền | Hiển thị, căn phải | Số nguyên đồng, phân cách hàng nghìn bằng dấu chấm, kèm " đ" (120.000 đ); giá đã ghi trên vé | - | UC-007 Dữ liệu ra 2 STT 9; UI-STT 10 |
| Mã QR của vé | - | Hình | Hiển thị | Hình mã QR của vé | Có văn bản thay thế | UC-007 Dữ liệu ra 2 STT 10 |
| Trạng thái vé | - | Lựa chọn | Hiển thị | Chưa sử dụng, Đã sử dụng hoặc Đã huỷ | Biểu tượng và chữ | UC-007 Dữ liệu ra 2 STT 11; Q-159 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-27 | WCAG 1.1.1 Nội dung không phải chữ | Đạt | Mã QR có văn bản thay thế nêu ghế và mã đặt vé (UI-STT 34) | - |
| SCR-27 | WCAG 1.4.1 Không dùng màu làm tín hiệu duy nhất | Đạt | Trạng thái vé có chữ và biểu tượng (UI-STT 13) | - |
| SCR-27 | Nielsen 3 Kiểm soát và tự do | Đạt | Nút Quay lại danh sách lịch sử (UI-STT 51) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-121.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
