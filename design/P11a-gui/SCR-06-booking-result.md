# P11a - SCR-06 Kết quả đặt vé (Booking result) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-005 1.9 (bước 11-15, Dữ liệu ra 3, luồng 7b, 11a); P09 F7.6; P05 GL-17, GL-51; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-06 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-06 |
| UC | UC-005 (và kết cục của UC-006 qua email) |
| Bước UC | 11, 12, 13, 14, 15; luồng 7b, 11a |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BookTicketsForm (showBookingSuccess, notifyRefusal) |
| DC | DC-BookTicketsView |
| Loại màn hình | Phụ thuộc có dữ liệu (giao dịch thanh toán) |
| Đến từ | Cổng VNPay quay về địa chỉ trả về (E-18) |
| Đi tới | SCR-05 (E-34) khi lần giữ ghế còn Đang giữ; thoát bằng nút Về trang chủ hoặc menu tới SCR-02 |

## c) Hình ảnh màn hình

```text
Trạng thái 1 - Thành công:
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Kết quả đặt vé                                               |
| [v] Đặt vé thành công. Mã đặt vé của bạn là CB0001234.       |
|     Hệ thống đang gửi vé qua email cho bạn.                  |
| +---------------------------+ +---------------------------+ |
| | Mã đặt vé CB0001234       | | Mã đặt vé CB0001234       | |
| | Phim A, 2D                | | Phim A, 2D                | |
| | CineBook Cầu Giấy         | | CineBook Cầu Giấy         | |
| | Phòng 3 (IMAX)            | | Phòng 3 (IMAX)            | |
| | 15/11/2026 19:30          | | 15/11/2026 19:30          | |
| | Ghế F7, Ghế VIP, 120.000 đ| | Ghế F8, Ghế VIP, 120.000 đ| |
| | [ Mã QR ]                 | | [ Mã QR ]                 | |
| +---------------------------+ +---------------------------+ |
|                                       [ Về trang chủ ]       |
+------------------------------------------------------------+
```

Các trạng thái còn lại của cùng màn hình:

```text
Trạng thái 2 - Đang xác nhận (MSG-28), trạng thái 3 - Thất bại (MSG-16), trạng thái 4 - Hết hạn (MSG-14), trạng thái 5 - Chưa nhận được kết quả (MSG-30 hoặc, khi lần giữ ghế còn Đang giữ, MSG-81 kèm nút Quay lại thanh toán):
+------------------------------------------------------------+
| Kết quả đặt vé                                               |
| (o) Đang xác nhận kết quả thanh toán. Vui lòng không đóng    |
|     trang này.                      (hoặc MSG-16 / 14 / 30)   |
|           [ Quay lại thanh toán ] [ Về trang chủ ]            |
+------------------------------------------------------------+
```

Nút Quay lại thanh toán chỉ hiện ở trạng thái 2 và 5 khi lần giữ ghế còn Đang giữ.

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Kết quả đặt vé" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-17 (thành công), MSG-28, MSG-16, MSG-14, MSG-30, MSG-81 | Dưới tiêu đề | UI-STT 08, 44 |
| Nội dung | Danh sách vé, mỗi vé một thẻ gồm mã đặt vé, thông tin suất chiếu, ghế, giá vé, mã QR | Giữa, hai cột từ 1024 px | UC-005 Dữ liệu ra 3 |
| Hành động | Nút Quay lại thanh toán (phụ, có điều kiện), nút Về trang chủ (chính) | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Màn hình là địa chỉ trả về của VNPay, chỉ đọc kết quả từ máy chủ. Đòi phiên đăng nhập hợp lệ: mất phiên thì mở SCR-01 rồi quay lại cùng địa chỉ. Máy chủ chỉ trả vé cho đúng chủ giao dịch. Hiện MSG-28 và hỏi trạng thái giao dịch mỗi 2 giây, tối đa 60 giây (Q-126) | UC-005 bước 11; P09 F7.6; UI-STT 44; MSG-28; Q-126 |
| 2 | Vùng kết quả | Vùng hiển thị | Nhận kết quả | Thanh toán thành công, đã có vé: hiện MSG-17, mã đặt vé và các vé (bước 15). Cổng báo thất bại bằng IPN (ghế đã được trả): MSG-16. Lần giữ ghế đã hết hạn hoặc đã huỷ nên giao dịch được hoàn toàn bộ: MSG-14. Quá 60 giây chưa có kết quả: lần giữ ghế còn Đang giữ thì MSG-81, ngược lại MSG-30. Khách bấm huỷ ở trang cổng mà chưa có IPN không là thất bại: lần giữ ghế còn Đang giữ thì như quá 60 giây | UC-005 bước 11-15, luồng 7b, 11a; UC-006 BR-14, BR-15; MSG-14, MSG-16, MSG-17, MSG-30 |
| 3 | Thẻ vé (mỗi ghế) | Vùng hiển thị | Khởi tạo | Hiện mã đặt vé, tên phim, định dạng, cụm rạp, phòng chiếu và loại phòng, ngày giờ bắt đầu, vị trí ghế, loại ghế, giá vé, mã QR riêng | UC-005 Dữ liệu ra 3 STT 1-2; REQ-105 |
| 4 | Nút Về trang chủ | Nút chính | Nhấn | Mở SCR-02 (giống mục Trang chủ trong menu) | UC-005 bước 15; UI-STT 22 |
| 5 | Nút Quay lại thanh toán | Nút phụ | Nhấn | Chỉ hiện khi lần giữ ghế còn Đang giữ và chưa có kết quả. Mở SCR-05 nạp lần giữ ghế đang chạy; bấm Thanh toán qua VNPay ở đó tạo địa chỉ mới cho cùng lần giữ ghế (BR-90), tới hết hạn | UC-005 luồng 7b, 10a; BR-90; UI-STT 44; MSG-81 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Mã đặt vé | 20 | Chữ | Hiển thị | Duy nhất toàn hệ thống; định dạng không quy định | Thiết kế: dự phòng độ dài, ví dụ CB0001234 dài 9 ký tự | UC-005 Dữ liệu ra 3 STT 1; BR-80 |
| Tên phim | - | Chữ | Hiển thị | Theo dữ liệu vé | - | UC-005 Dữ liệu ra 3 STT 2 |
| Định dạng phim | - | Lựa chọn | Hiển thị | 2D hoặc 3D | - | UC-005 Dữ liệu ra 3 STT 2 |
| Tên cụm rạp | - | Chữ | Hiển thị | Theo dữ liệu vé | - | UC-005 Dữ liệu ra 3 STT 2 |
| Phòng chiếu và loại phòng | - | Chữ | Hiển thị | Tên phòng và loại (thường, 4DX, IMAX) | Ví dụ Phòng 3 (IMAX) | UC-005 Dữ liệu ra 3 STT 2 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm | - | UC-005 Dữ liệu ra 3 STT 2 |
| Vị trí ghế, loại ghế | - | Chữ | Hiển thị | Mã hàng và số ghế; ghế thường, VIP hoặc đôi | - | UC-005 Dữ liệu ra 3 STT 2 |
| Giá vé | 15 | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | Thiết kế: 15 ký tự đủ cho "999.999.999 đ" | UC-005 Dữ liệu ra 3 STT 2 |
| Mã QR | - | Chữ | Hiển thị (ảnh) | Mã QR riêng của vé, alt "Mã QR của vé ghế F7, mã đặt vé CB0001234" | Nội dung mã không quy định (REQ-128) | UC-005 Dữ liệu ra 3 STT 2; NFR-14 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-06 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Khách đóng tab ở VNPay hoặc tải lại thì thấy dải Tiếp tục thanh toán ở SCR-02 khi lần giữ ghế còn chạy (Q-119); kết quả đặt vé sau đó xem qua email | - |
| SCR-06 | Nielsen 9 | Đạt | MSG-14, MSG-16, MSG-30 nêu kết quả và việc tiếp theo (hoàn tiền, kiểm tra email) | - |
| SCR-06 | WCAG 1.1.1 Nội dung không phải chữ | Đạt | Mã QR có văn bản thay thế nêu ghế và mã đặt vé (UI-STT 34) | - |
| SCR-06 | WCAG 4.1.3 | Đạt | Kết quả đổi từ MSG-28 sang kết quả cuối qua vùng role=status | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 28-29, 33-35, 44.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-119, Q-126.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Q-119 đã trả lời theo đề xuất, chờ người dùng xác nhận. Màn hình mới (địa chỉ trả về) chưa có trong P08; trách nhiệm đọc trạng thái giao dịch ghi ở Đề xuất sửa P08 của ui-standards.md (showPaymentOutcome).
