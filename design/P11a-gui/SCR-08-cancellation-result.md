# P11a - SCR-08 Kết quả huỷ vé (Cancellation result) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P04 UC-008 1.4 (bước 7, 8, Dữ liệu ra 1, luồng 5c, 6b); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-08 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-08 |
| UC | UC-008 |
| Bước UC | 7, 8; luồng 5c, 6b |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-CancelTicketForm (showCancellationResult) |
| DC | DC-CancelTicketView |
| Loại màn hình | Phụ thuộc có dữ liệu (vé đã huỷ) |
| Đến từ | SCR-07 (E-20) |
| Đi tới | Không có cạnh đi; màn hình kết thúc, thoát bằng nút Về trang chủ hoặc menu tới SCR-02 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Kết quả huỷ vé                                               |
| [v] Đã huỷ vé. Bạn được hoàn 84.000 đ qua cổng thanh toán.   |
| Vé đã huỷ          CB0001234, Phim A, CineBook Cầu Giấy,     |
|                    Phòng 3, 15/11/2026 19:30, ghế F7         |
| Giá vé             120.000 đ                                 |
| Số tiền hoàn       84.000 đ (70% x 120.000 đ)                |
| Hình thức hoàn tiền Qua cổng thanh toán                      |
| Tình trạng hoàn tiền Đã hoàn                                 |
|                                       [ Về trang chủ ]       |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Kết quả huỷ vé" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-40 hoặc MSG-41 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Danh sách nhãn và giá trị của vé đã huỷ, giá vé, số tiền hoàn, hình thức, tình trạng hoàn tiền | Giữa | UC-008 Dữ liệu ra 1 |
| Hành động | Nút Về trang chủ | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện kết quả: MSG-40 khi đã hoàn, MSG-41 khi chưa hoàn được và đã ghi để xử lý thủ công; kèm vé đã huỷ, giá vé, số tiền hoàn, hình thức và tình trạng hoàn tiền | UC-008 bước 8, luồng 5c, 6b; MSG-40, MSG-41 |
| 2 | Nút Về trang chủ | Nút chính | Nhấn | Mở SCR-02 | UC-008 bước 8; UI-STT 22 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Vé đã huỷ | - | Chữ | Hiển thị | Mã đặt vé, phim, cụm rạp, phòng chiếu, ngày giờ bắt đầu dd/MM/yyyy HH:mm, vị trí ghế | - | UC-008 Dữ liệu ra 1 STT 1 |
| Giá vé | Q-124 | Tiền | Hiển thị, căn phải | Giá ghi trên vé | - | UC-008 Dữ liệu ra 1 STT 2 |
| Số tiền hoàn | Q-124 | Tiền | Hiển thị, căn phải | 70% giá vé, làm tròn xuống đồng (BR-19, BR-31) | Ví dụ 84.000 đ = 70% x 120.000 đ | UC-008 Dữ liệu ra 1 STT 3 |
| Hình thức hoàn tiền | - | Lựa chọn | Hiển thị | Qua cổng thanh toán (vé mua trực tuyến) | - | UC-008 Dữ liệu ra 1 STT 4; BR-20 |
| Tình trạng hoàn tiền | - | Lựa chọn | Hiển thị | Đã hoàn, hoặc chưa hoàn được và xử lý thủ công (BR-41) | Có biểu tượng và chữ | UC-008 Dữ liệu ra 1 STT 5; GL-56 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-08 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Tình trạng hoàn tiền hiện rõ cả khi chưa hoàn được (MSG-41) | - |
| SCR-08 | Nielsen 9 | Đạt | MSG-41 nêu khoản hoàn được xử lý thủ công | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 28, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Không có.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
