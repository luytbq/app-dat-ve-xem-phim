# P11a - SCR-13 Tìm vé theo mã đặt vé (Find tickets by booking code) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P04 UC-008 1.4 (luồng 1a, 1a1-1a3, 2b, 2c, 3a, 4a, 4b, Dữ liệu vào 1, Dữ liệu ra 2); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-13 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-13 |
| UC | UC-008 |
| Bước UC | 1a1, 1a1a, 1a2, 1a3, 2, 3, 4; luồng 2b, 2c, 3a, 4a, 4b |
| Tác nhân | ACT-02 Nhân viên quầy; ACT-07 Cổng thanh toán (không dùng với vé quầy) |
| Boundary AC | AC-B-CounterCancelTicketForm (enterBookingCode, showBookingTickets, selectTicketToCancel, notifyRefusal) |
| DC | DC-CounterCancelTicketView, DC-CounterCancelTicketStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-09 (E-22) |
| Đi tới | SCR-14 (E-27) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Tìm vé theo mã đặt vé                                        |
| (vùng thông điệp: MSG-31, MSG-33, MSG-34, MSG-35 đến MSG-37, MSG-78) |
| Mã đặt vé *   [ CB0001234              ] [ Xem vé của mã đặt vé ] |
| Ghế | Giá vé     | Trạng thái     |                           |
|-----+------------+----------------+--------------------------|
| F7  | 120.000 đ  | Chưa sử dụng   | [ Huỷ vé ]                |
| F8  | 120.000 đ  | Đã huỷ         |                           |
+------------------------------------------------------------+
Hộp xác nhận (MSG-39): Huỷ vé ghế F7, mã đặt vé CB0001234? ... [ Giữ lại vé ] [ Huỷ vé ]
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Tìm vé theo mã đặt vé" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-31, MSG-33, MSG-34, MSG-35, MSG-36, MSG-37, MSG-75, MSG-78 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Ô mã đặt vé, nút Xem vé của mã đặt vé, bảng vé của lần đặt | Giữa | UC-008 luồng 1a1, 1a2 |
| Hộp thoại | Hộp xác nhận MSG-39 | Giữa màn hình | UI-STT 37 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện ô mã đặt vé trống, tiêu điểm vào ô | UC-008 luồng 1a1 |
| 2 | Ô Mã đặt vé | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) | UC-008 Dữ liệu vào 1 STT 1 |
| 3 | Nút Xem vé của mã đặt vé | Nút chính | Nhấn | Kiểm ô theo UI-STT 19, gửi mã. Không có mã: MSG-31, giữ mã đã nhập để sửa (quay lại bước 1a1). Có mã: hiện bảng các vé của lần đặt (vị trí ghế, giá vé, trạng thái vé) | UC-008 luồng 1a1, 1a1a, 1a2; MSG-03, MSG-31 |
| 4 | Bảng vé của lần đặt | Bảng | Khởi tạo | Mỗi hàng: vị trí ghế, giá vé, trạng thái vé (chưa sử dụng, đã huỷ, đã sử dụng); hàng chưa huỷ có nút Huỷ vé | UC-008 Dữ liệu ra 2 STT 1 |
| 5 | Nút Huỷ vé (mỗi hàng) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-39 nêu số tiền mặt hoàn 70% giá vé | UC-008 luồng 1a3; BR-19, BR-20, BR-31; MSG-39 |
| 6 | Nút Huỷ vé (hộp xác nhận) | Nút chính phá huỷ | Nhấn | Gửi yêu cầu huỷ, hiện MSG-78. Từ chối ở lại, tải lại bảng vé: vé mua trực tuyến MSG-33; vé của cụm rạp khác MSG-34; quá hạn huỷ MSG-35; vé đã huỷ MSG-36; vé đã sử dụng MSG-37. Thành công: mở SCR-14 với vé đã huỷ và số tiền mặt cần hoàn | UC-008 bước 2-4, 5a1, luồng 2b, 2c, 3a, 4a, 4b; BR-17, BR-18, BR-21, BR-30; MSG-33 đến MSG-37, MSG-78 |
| 7 | Nút Giữ lại vé (hộp xác nhận) | Nút phụ | Nhấn | Đóng hộp, không thay đổi vé | UI-STT 37 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Mã đặt vé | Q-124 | Chữ | Nhập, bắt buộc, căn trái | Trùng mã đặt vé của một lần đặt; duy nhất toàn hệ thống (BR-80) | Mã in trên vé; ví dụ CB0001234. Có thể gõ khoảng trắng đầu cuối, bỏ khi gửi | UC-008 Dữ liệu vào 1 STT 1; BR-80; Q-124 |
| Vị trí ghế | - | Chữ | Hiển thị | Mã hàng và số ghế | - | UC-008 Dữ liệu ra 2 STT 1 |
| Giá vé | Q-124 | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | - | UC-008 Dữ liệu ra 2 STT 1 |
| Trạng thái vé | - | Lựa chọn | Hiển thị | Chưa sử dụng, đã huỷ, đã sử dụng | Có chữ và biểu tượng | UC-008 Dữ liệu ra 2 STT 1 |
| Vé cần huỷ | - | Lựa chọn | Chọn, bắt buộc | Một vé trong lần đặt, mua tại quầy của cụm rạp mình | - | UC-008 Dữ liệu vào 1 STT 2; BR-17 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Mã đặt vé | Rời trường; nhấn Xem vé | Bắt buộc --> trùng mã của một lần đặt (hệ thống) | MSG-03; MSG-31 |
| Vé cần huỷ | Nhấn Huỷ vé (hộp xác nhận) | Bắt buộc một vé --> vé mua tại quầy của cụm rạp mình, chưa quá hạn, chưa huỷ, chưa sử dụng (hệ thống) | MSG-33; MSG-34; MSG-35; MSG-36; MSG-37 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-13 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền mặt hoàn và không hoàn tác (UI-STT 37) | - |
| SCR-13 | Nielsen 9 | Đạt | MSG-31 nêu việc cần làm tiếp và giữ mã đã nhập | - |
| SCR-13 | Baymard: giữ dữ liệu đã nhập | Đạt | Mã đặt vé còn nguyên sau MSG-31 (UI-STT 20) | - |
| SCR-13 | WCAG 3.3.4 | Đạt | Xác nhận trước khi huỷ vé | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-21, 27-31, 33-35, 37.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-124, Q-125.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Độ dài mã đặt vé: Q-124.
