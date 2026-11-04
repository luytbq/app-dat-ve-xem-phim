# P11a - SCR-15 Kết quả huỷ vé tại quầy (Counter cancellation result) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P04 UC-008 1.4 (bước 7, 8, Dữ liệu ra 1); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-15 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-15 |
| UC | UC-008 |
| Bước UC | 7, 8 |
| Tác nhân | ACT-02 Nhân viên quầy |
| Boundary AC | AC-B-CounterCancelTicketForm (showCancellationResult) |
| DC | DC-CounterCancelTicketView |
| Loại màn hình | Phụ thuộc có dữ liệu (vé đã huỷ) |
| Đến từ | SCR-14 (E-28) |
| Đi tới | Không có cạnh đi; màn hình kết thúc, thoát bằng nút Về trang chủ hoặc menu tới SCR-09 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Kết quả huỷ vé tại quầy                                      |
| [v] Đã huỷ vé và ghi nhận hoàn 84.000 đ tiền mặt.            |
| Vé đã huỷ            CB0001234, Phim A, Phòng 3,             |
|                      15/11/2026 19:30, ghế F7                |
| Giá vé               120.000 đ                               |
| Số tiền hoàn         84.000 đ                                |
| Hình thức hoàn tiền  Tiền mặt tại quầy                       |
| Tình trạng hoàn tiền Đã hoàn                                 |
|                                       [ Về trang chủ ]       |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Kết quả huỷ vé tại quầy" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-43 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Vé đã huỷ, giá vé, số tiền hoàn, hình thức, tình trạng hoàn tiền | Giữa | UC-008 Dữ liệu ra 1 |
| Hành động | Nút Về trang chủ | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện MSG-43 và vé đã huỷ, giá vé, số tiền hoàn, hình thức hoàn tiền, tình trạng hoàn tiền (đã hoàn) | UC-008 bước 7, 8, Dữ liệu ra 1; MSG-43 |
| 2 | Nút Về trang chủ | Nút chính | Nhấn | Mở SCR-09 | UC-008 bước 8; UI-STT 22 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Vé đã huỷ | - | Chữ | Hiển thị | Mã đặt vé, phim, cụm rạp, phòng chiếu, ngày giờ bắt đầu, vị trí ghế | - | UC-008 Dữ liệu ra 1 STT 1 |
| Giá vé | Q-124 | Tiền | Hiển thị, căn phải | Giá ghi trên vé | - | UC-008 Dữ liệu ra 1 STT 2 |
| Số tiền hoàn | Q-124 | Tiền | Hiển thị, căn phải | 70% giá vé, làm tròn xuống đồng | - | UC-008 Dữ liệu ra 1 STT 3 |
| Hình thức hoàn tiền | - | Lựa chọn | Hiển thị | Tiền mặt tại quầy | - | UC-008 Dữ liệu ra 1 STT 4 |
| Tình trạng hoàn tiền | - | Lựa chọn | Hiển thị | Đã hoàn | - | UC-008 Dữ liệu ra 1 STT 5 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-15 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-43 và tình trạng hoàn tiền hiện ngay sau xác nhận | - |

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
