# P11a - SCR-14 Hoàn tiền mặt (Cash refund) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-008 1.5 (bước 4, 5a1, 5a2, 7, Dữ liệu ra 1); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-14 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-14 |
| UC | UC-008 |
| Bước UC | 5a1, 5a2, 7 |
| Tác nhân | ACT-02 Nhân viên quầy |
| Boundary AC | AC-B-CounterCancelTicketForm (showCashRefund, confirmCashRefunded) |
| DC | DC-CounterCancelTicketView |
| Loại màn hình | Phụ thuộc có dữ liệu (vé cần huỷ) |
| Đến từ | SCR-13 (E-27) |
| Đi tới | SCR-15 (E-28) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Hoàn tiền mặt                                                |
| (vùng thông điệp: MSG-78)                                    |
| Vé cần huỷ     CB0001234, Phim A, CineBook Cầu Giấy,        |
|                Phòng 3, 15/11/2026 19:30, ghế F7             |
| Giá vé         120.000 đ                                     |
| Số tiền mặt cần hoàn cho khách   84.000 đ (70% x 120.000 đ)  |
| Hình thức hoàn tiền   Tiền mặt tại quầy                      |
|                          [ Xác nhận đã hoàn tiền mặt ]       |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Hoàn tiền mặt" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-78, MSG-72, MSG-73 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Vé cần huỷ, giá vé, số tiền mặt cần hoàn, hình thức hoàn tiền | Giữa | UC-008 Dữ liệu ra 1 |
| Hành động | Nút chính Xác nhận đã hoàn tiền mặt | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện vé cần huỷ, giá vé, số tiền mặt cần hoàn (70% giá vé, làm tròn xuống đồng) và hình thức hoàn tiền "Tiền mặt tại quầy" | UC-008 bước 5a1, Dữ liệu ra 1 STT 1-4; BR-19, BR-20, BR-31 |
| 2 | Nút Xác nhận đã hoàn tiền mặt | Nút chính | Nhấn | Mở hộp xác nhận MSG-42 nêu số tiền. Xác nhận: hệ thống huỷ vé, ghi nhận khoản hoàn tiền mặt (tình trạng đã hoàn) và trả ghế về trống trong cùng một thao tác, rồi mở SCR-15. Không có trạng thái vé đã huỷ mà chưa xác nhận hoàn tiền mặt (Q-125). Lỗi hệ thống: MSG-72 hoặc MSG-73, nút Thử lại | UC-008 bước 4, 5a2, 7; MSG-42, MSG-72, MSG-73; Q-125 |
| 3 | Mục Trang chủ (menu) | Liên kết | Nhấn | Rời màn hình khi chưa xác nhận: mở màn hình đích, vé chưa bị huỷ và không có khoản hoàn nào được ghi nhận; nhân viên nhập lại mã đặt vé ở SCR-13 nếu muốn huỷ tiếp | UC-008 bước 4, 5a2, 7; Q-125 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Vé cần huỷ | - | Chữ | Hiển thị | Mã đặt vé, phim, cụm rạp, phòng chiếu, ngày giờ bắt đầu, vị trí ghế | - | UC-008 Dữ liệu ra 1 STT 1 |
| Giá vé | 15 (Thiết kế: đủ cho 999.999.999 đ) | Tiền | Hiển thị, căn phải | Giá ghi trên vé | - | UC-008 Dữ liệu ra 1 STT 2 |
| Số tiền mặt cần hoàn | 15 (Thiết kế: đủ cho 999.999.999 đ) | Tiền | Hiển thị, căn phải | 70% giá vé, làm tròn xuống đồng (BR-19, BR-31) | 84.000 đ = 70% x 120.000 đ | UC-008 Dữ liệu ra 1 STT 3 |
| Hình thức hoàn tiền | - | Lựa chọn | Hiển thị | Bằng tiền mặt tại quầy (BR-20) | - | UC-008 Dữ liệu ra 1 STT 4 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-14 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền (MSG-42) | - |
| SCR-14 | Nielsen 3 Kiểm soát và tự do | Đạt | Huỷ vé và hoàn tiền mặt là một thao tác; rời màn hình trước khi xác nhận thì vé chưa bị huỷ (Q-125) | - |
| SCR-14 | WCAG 3.3.4 | Đạt | Xác nhận tài chính trước khi ghi nhận hoàn tiền | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 27-31, 33-35, 37.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-125 (đã trả lời).

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có. Q-125 đã trả lời: huỷ vé và hoàn tiền mặt là một thao tác.
