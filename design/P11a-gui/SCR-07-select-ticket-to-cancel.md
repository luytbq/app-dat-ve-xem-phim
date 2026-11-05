# P11a - SCR-07 Chọn vé cần huỷ (Select ticket to cancel) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-008 1.5 (bước 1-5, Dữ liệu vào 1, Dữ liệu ra 1, luồng 2a, 3a, 4a, 4b); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-07 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-07 |
| UC | UC-008 |
| Bước UC | 1, 2, 3, 4, 5, 6, 7; luồng 2a, 3a, 4a, 4b |
| Tác nhân | ACT-01 Khách; ACT-07 Cổng thanh toán (phụ) |
| Boundary AC | AC-B-CancelTicketForm (selectTicketToCancel, notifyRefusal) |
| DC | DC-CancelTicketView, DC-CancelTicketStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-02 (E-11) |
| Đi tới | SCR-08 (E-20) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Chọn vé cần huỷ                                              |
| (vùng thông điệp: MSG-32, MSG-35, MSG-36, MSG-37, MSG-78)    |
| Mã đặt vé | Phim, cụm rạp, phòng | Bắt đầu    | Ghế | Giá vé | Trạng thái |
|-----------+----------------------+------------+-----+--------+----------|
| CB0001234 | Phim A, CineBook     | 15/11/2026 | F7  |120.000 đ| Chưa sử dụng |
|           | Cầu Giấy, Phòng 3    | 19:30      |     |        | [ Huỷ vé ]  |
| CB0001234 | (như trên)           |            | F8  |120.000 đ| Đã huỷ      |
+------------------------------------------------------------+
Hộp xác nhận (MSG-38): Huỷ vé ghế F7, Phim A, 15/11/2026 19:30? Bạn được hoàn 84.000 đ (70% giá vé 120.000 đ) ...  [ Giữ lại vé ] [ Huỷ vé ]
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Chọn vé cần huỷ" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-32, MSG-35, MSG-36, MSG-37, MSG-75, MSG-78 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng vé khách đã mua trực tuyến, mỗi hàng một nút Huỷ vé | Giữa | UI-STT 18 |
| Hộp thoại | Hộp xác nhận MSG-38 (modal) | Giữa màn hình | UI-STT 37 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiển thị các vé khách đã mua trực tuyến. Rỗng: MSG-75 | UC-008 bước 1; Q-121; MSG-75 |
| 2 | Bảng vé | Bảng | Khởi tạo | Mỗi hàng: mã đặt vé, phim, cụm rạp, phòng chiếu, ngày giờ bắt đầu, vị trí ghế, giá vé, trạng thái vé (chưa sử dụng, đã huỷ, đã sử dụng) | UC-008 Dữ liệu ra 1 STT 1-2, Dữ liệu ra 2 STT 1 |
| 3 | Nút Huỷ vé (mỗi hàng) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-38 nêu vé, số tiền hoàn 70% giá vé (làm tròn xuống đồng) và cảnh báo không hoàn tác | UC-008 bước 1; BR-19, BR-31; MSG-38; UI-STT 37 |
| 4 | Nút Huỷ vé (hộp xác nhận) | Nút chính phá huỷ | Nhấn | Gửi yêu cầu huỷ, hiện MSG-78. Từ chối: vé không phải của khách MSG-32; quá hạn huỷ MSG-35; vé đã huỷ MSG-36; vé đã sử dụng MSG-37, ở lại danh sách và tải lại. Thành công: mở SCR-08 với vé đã huỷ | UC-008 bước 2-8, luồng 2a, 3a, 4a, 4b; BR-17, BR-18, BR-21, BR-30; MSG-32, MSG-35 đến MSG-37, MSG-78 |
| 5 | Nút Giữ lại vé (hộp xác nhận) | Nút phụ | Nhấn | Đóng hộp, không thay đổi vé | UI-STT 37 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Mã đặt vé | 20 | Chữ | Hiển thị | Mã của lần đặt chứa vé | Cùng mã nhóm các hàng | UC-008 Dữ liệu ra 1 STT 1 |
| Phim, cụm rạp, phòng chiếu | - | Chữ | Hiển thị | Theo dữ liệu vé | - | UC-008 Dữ liệu ra 1 STT 1 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm | Cơ sở của hạn huỷ vé (BR-18) | UC-008 Dữ liệu ra 1 STT 1 |
| Vị trí ghế | - | Chữ | Hiển thị | Mã hàng và số ghế | - | UC-008 Dữ liệu ra 1 STT 1, Dữ liệu ra 2 STT 1 |
| Giá vé | 15 (Thiết kế: đủ cho 999.999.999 đ) | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | - | UC-008 Dữ liệu ra 1 STT 2 |
| Trạng thái vé | - | Lựa chọn | Hiển thị | Chưa sử dụng, đã huỷ, đã sử dụng | Có chữ và biểu tượng, không chỉ màu | UC-008 Dữ liệu ra 2 STT 1; GL-60, GL-61, GL-65 |
| Vé cần huỷ | - | Lựa chọn | Chọn, bắt buộc | Một vé trong các vé khách đã mua trực tuyến | - | UC-008 Dữ liệu vào 1 STT 2; BR-17 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Vé cần huỷ | Nhấn Huỷ vé (hộp xác nhận) | Bắt buộc (mỗi lần một vé) --> thuộc vé khách đã mua trực tuyến (hệ thống) --> chưa quá hạn huỷ, chưa huỷ, chưa sử dụng (hệ thống) | MSG-32; MSG-35; MSG-36; MSG-37 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-07 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền hoàn và không hoàn tác (UI-STT 37) | - |
| SCR-07 | Nielsen 1 | Đạt | MSG-78 trong lúc hoàn tiền kéo dài (UI-STT 27) | - |
| SCR-07 | WCAG 3.3.4 Ngăn lỗi tài chính | Đạt | Xác nhận trước khi huỷ vé và hoàn tiền | - |
| SCR-07 | Nielsen 7 | Vi phạm còn mở | Không có lọc theo mã đặt vé hoặc suất chiếu (chưa có trong đặc tả) | Chờ Q-121 |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21, 27-31, 33-35, 37.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-121, Q-124.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Phạm vi danh sách vé phụ thuộc Q-121.
