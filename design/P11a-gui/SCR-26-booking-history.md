# P11a - SCR-26 Lịch sử đặt vé (Booking history) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-007 1.2 (bước 1-4, luồng 2a, 4a, Dữ liệu vào 1, Dữ liệu ra 1, BR-94); P05 GL-18; P07 UC-007; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-26 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-26 |
| UC | UC-007 |
| Bước UC | 1, 2, 3, 4; luồng 2a, 4a |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-ViewBookingHistoryForm (requestBookingHistory, showNoBooking, showBookingHistory, selectBooking, rejectBookingView) |
| DC | DC-ViewBookingHistoryView, DC-ViewBookingHistoryStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-02 (E-48) |
| Đi tới | SCR-27 (E-50) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------------+
| CineBook   Trang chủ                                 [ Đăng xuất ] |
|------------------------------------------------------------------|
| Lịch sử đặt vé                                                     |
| (vùng thông điệp: MSG-93, MSG-94, MSG-72, MSG-73)                  |
| Mã đặt vé | Phim   | Cụm rạp           | Bắt đầu          | Số vé |
|-----------+--------+-------------------+------------------+-------|
| CB0001234 | Phim A | CineBook Cầu Giấy | 15/11/2026 19:30 | 2     |
|           |        |                   |  [ Xem vé ]              |
| CB0001198 | Mai    | CineBook Bà Triệu | 02/11/2026 20:00 | 1     |
|           |        |                   |  [ Xem vé ]              |
+------------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Lịch sử đặt vé" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-93, MSG-94, MSG-72, MSG-73 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng các lần đặt vé của khách, lần đặt gần nhất trước, mỗi hàng có nút Xem vé | Giữa | UC-007 Dữ liệu ra 1; UI-STT 18 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Yêu cầu hệ thống các lần đặt vé của chính khách đang đăng nhập, xếp lần đặt gần nhất (theo thời điểm đặt vé) trước. Chưa có lần đặt nào: hiện MSG-93, không hiện bảng | UC-007 bước 1, 2, luồng 2a; BR-94; MSG-93 |
| 2 | Bảng Các lần đặt vé | Bảng | Khởi tạo | Mỗi hàng: mã đặt vé, tên phim, tên cụm rạp, ngày giờ bắt đầu suất chiếu, số vé. Thời điểm đặt vé chỉ dùng để xếp, không hiện | UC-007 Dữ liệu ra 1 STT 1-5 |
| 3 | Nút Xem vé (mỗi hàng) | Nút phụ | Nhấn | Gửi mã đặt vé đã chọn. Lần đặt thuộc khách: mở SCR-27. Không thuộc khách: MSG-94, ở lại danh sách | UC-007 bước 3-5, luồng 4a; BR-94; MSG-94 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Mã đặt vé | 20 | Chữ | Hiển thị, căn trái | Mã duy nhất toàn hệ thống do hệ thống cấp | Thiết kế: 20 ký tự như SCR-13 (Q-124) | UC-007 Dữ liệu ra 1 STT 1; REQ-106 |
| Tên phim | - | Chữ | Hiển thị, căn trái | Giữ nguyên tên lúc bán (BR-140) | - | UC-007 Dữ liệu ra 1 STT 2; BR-140 |
| Tên cụm rạp | - | Chữ | Hiển thị, căn trái | Giữ nguyên tên lúc bán (BR-140) | - | UC-007 Dữ liệu ra 1 STT 3 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị, căn phải | dd/MM/yyyy HH:mm | - | UC-007 Dữ liệu ra 1 STT 4 |
| Số vé | 2 | Số | Hiển thị, căn phải | Số nguyên của lần đặt | Một lần đặt tối đa 8 vé (BR-05) | UC-007 Dữ liệu ra 1 STT 5; BR-05 |
| Lần đặt cần xem | - | Lựa chọn | Chọn, bắt buộc | Một lần đặt trong bảng và thuộc về khách (BR-94) | - | UC-007 Dữ liệu vào 1 STT 1; BR-94 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Lần đặt cần xem | Nhấn Xem vé (hệ thống) | Lần đặt thuộc về khách | MSG-94 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-26 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Danh sách rỗng hiện MSG-93 (UI-STT 18) | - |
| SCR-26 | Nielsen 3 Kiểm soát và tự do | Đạt | Từ chối ở lại danh sách (UI-STT 29(2)) | - |
| SCR-26 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm trong lịch sử (đặc tả không nêu) | Chấp nhận, không thêm chức năng ngoài đặc tả |
| SCR-26 | WCAG 1.3.1 Thông tin và quan hệ | Đạt | Bảng có hàng tiêu đề, dưới 600 px thành thẻ (UI-STT 18) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28-29, 33-35.

## h) Thông điệp mới

Không có. MSG-93, MSG-94 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-121.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
