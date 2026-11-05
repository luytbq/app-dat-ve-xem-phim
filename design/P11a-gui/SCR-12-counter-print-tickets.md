# P11a - SCR-12 In vé tại quầy (Print tickets at counter) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-005 1.9 (luồng 9a2-9a5, Dữ liệu ra 3); P01-actors.md (máy in nối qua máy tính tại quầy); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-12 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-12 |
| UC | UC-005 |
| Bước UC | 9a3, 9a4, 9a5 |
| Tác nhân | ACT-02 Nhân viên quầy |
| Boundary AC | AC-B-CounterBookTicketsForm (showTicketsForPrint, printTickets) |
| DC | DC-CounterBookTicketsView |
| Loại màn hình | Phụ thuộc có dữ liệu (mã đặt vé và vé vừa tạo) |
| Đến từ | SCR-11 (E-25) |
| Đi tới | Không có cạnh đi; màn hình kết thúc, thoát bằng menu tới SCR-09 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| In vé                                                        |
| [v] Đã bán vé. Mã đặt vé là CB0001234. Vui lòng in vé cho khách. |
| +---------------------------+ +---------------------------+ |
| | Mã đặt vé CB0001234       | | Mã đặt vé CB0001234       | |
| | Phim A, 2D, Phòng 3 (IMAX)| | Phim A, 2D, Phòng 3 (IMAX)| |
| | 15/11/2026 19:30          | | 15/11/2026 19:30          | |
| | Ghế F7, Ghế VIP, 120.000 đ| | Ghế F8, Ghế VIP, 120.000 đ| |
| | [ Mã QR ]                 | | [ Mã QR ]                 | |
| +---------------------------+ +---------------------------+ |
|                                            [ In vé ]         |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "In vé" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-21 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Thẻ vé của từng ghế | Giữa | UC-005 Dữ liệu ra 3 |
| Hành động | Nút chính In vé | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện MSG-21, mã đặt vé và các vé để in (mỗi ghế một thẻ, đủ nội dung vé gồm mã QR) | UC-005 luồng 9a3, 9a4, Dữ liệu ra 3; MSG-21 |
| 2 | Nút In vé | Nút chính | Nhấn | Mở hộp thoại in của trình duyệt cho các thẻ vé (mỗi vé một khối, máy in thông thường nối với máy tính tại quầy). Hệ thống không nhận kết quả in | UC-005 luồng 9a5; P01 máy in thông thường |
| 3 | Nút In vé | Nút chính | Nhấn đúp | Hai lần nhấn liên tiếp chỉ mở một hộp thoại in (nút bận trong lúc hộp mở) | UI-STT 27 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Mã đặt vé | 20 | Chữ | Hiển thị | Duy nhất toàn hệ thống | Thiết kế: dự phòng độ dài như SCR-06 | UC-005 Dữ liệu ra 3 STT 1 |
| Nội dung vé (phim, định dạng, cụm rạp, phòng và loại phòng, ngày giờ bắt đầu, vị trí và loại ghế) | - | Chữ | Hiển thị | Như SCR-06 | - | UC-005 Dữ liệu ra 3 STT 2 |
| Giá vé | 15 (Thiết kế: đủ cho 999.999.999 đ) | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | - | UC-005 Dữ liệu ra 3 STT 2 |
| Mã QR | - | Chữ | Hiển thị (ảnh) | Mã QR riêng của vé | Có alt như SCR-06 | UC-005 Dữ liệu ra 3 STT 2 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-12 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-21 báo đã bán vé và việc cần làm tiếp | - |
| SCR-12 | WCAG 1.1.1 | Đạt | Mã QR có văn bản thay thế (UI-STT 34) | - |

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

Khổ giấy và bố cục in không có trong đặc tả; dùng mặc định của hộp thoại in trình duyệt (không có giá trị nghiệp vụ).
