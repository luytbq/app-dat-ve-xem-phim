# P11a - SCR-16 Soát vé (Check ticket) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-009 (bước 1-7, Dữ liệu vào 1, 2, Dữ liệu ra 1-3, luồng 4a-4e); P06 NFR-11, NFR-13, NFR-14; P05 GL-48, GL-62; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-16 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-16 |
| UC | UC-009 |
| Bước UC | 1, 2, 3, 4, 5, 6, 7; luồng 4a, 4b, 4c, 4d, 4e |
| Tác nhân | ACT-03 Nhân viên soát vé |
| Boundary AC | AC-B-CheckTicketForm (selectCheckingShowtime, showCheckingShowtime, scanTicketQr, showValidTicket, rejectTicket) |
| DC | DC-CheckTicketView, DC-CheckTicketStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-01 (E-08) |
| Đi tới | Không có cạnh đi; màn hình kết thúc (nhân viên soát vé chỉ có UC-009), vòng lặp quét ở ngay màn hình |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook                                                     |
|------------------------------------------------------------|
| Soát vé                                                      |
| (vùng thông điệp: MSG-50, MSG-74)                            |
| Suất chiếu đang soát *  [ Phim A, 2D, Phòng 3, 15/11 19:30 v ]|
| Đang soát: Phim A, 2D, Phòng 3, 15/11/2026 19:30             |
| +----------------------------------+                         |
| |                                  |   Hướng camera vào mã QR |
| |        [ vùng camera 4:3 ]       |   trên vé của khách      |
| |                                  |                         |
| +----------------------------------+                         |
| +----------------------------------------------------------+ |
| | VÉ HỢP LỆ - Mời khách vào phòng chiếu (MSG-44)            | |
| | CB0001234 | Phim A, 2D | CineBook Cầu Giấy | Phòng 3 (IMAX)| |
| | 15/11/2026 19:30 | F7 | Ghế VIP | 120.000 đ               | |
| +----------------------------------------------------------+ |
| (hoặc) TỪ CHỐI: vé đã sử dụng. (MSG-48)                      |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Soát vé" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-50, MSG-74 | Dưới tiêu đề | UI-STT 08 |
| Chọn suất | Danh sách Suất chiếu đang soát, dòng thông tin suất đang soát | Trên camera | UC-009 bước 1, 2 |
| Camera | Khung hình camera 4:3, hướng dẫn | Giữa | UI-STT 45 |
| Kết quả quét | Khối kết quả lớn của lần quét gần nhất (hợp lệ hoặc từ chối kèm lý do) | Dưới camera | UC-009 bước 6, luồng 4a-4e |
| Hành động | Không có nút; quét liên tục | - | Không có cách nhập tay mã QR (NFR-13) |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Khôi phục suất chiếu đang soát đã chọn trong phiên (nếu có) và hiện thông tin suất; xin quyền dùng camera. Không có suất chiếu nào: MSG-74. Không mở được camera: MSG-50 | UC-009 bước 1, 2; P08 Q-97; NFR-11, NFR-13; MSG-50, MSG-74 |
| 2 | Danh sách Suất chiếu đang soát | Danh sách chọn | Chọn | Chọn một suất chiếu của cụm rạp mình; hệ thống ghi nhận là suất đang soát và hiện thông tin suất (phim, định dạng, phòng chiếu, ngày giờ bắt đầu). Chọn lại thì đổi suất cho các lần quét sau và xoá khối kết quả cũ | UC-009 bước 1, 2, Dữ liệu vào 1, Dữ liệu ra 1; BR-34 |
| 3 | Vùng camera | Vùng hiển thị | Quét (thiết bị đưa dữ liệu vào) | Đọc mã QR trên vé; chỉ hoạt động khi đã chọn suất chiếu. Mỗi mã đọc được gửi lên hệ thống một lần, cùng mã đó không được đọc lại trong 3 giây | UC-009 bước 3, Dữ liệu vào 2 STT 1; REQ-126; UI-STT 45 |
| 4 | Khối kết quả quét | Vùng hiển thị | Nhận kết quả | Vé hợp lệ: hiện MSG-44 và nội dung vé (mã đặt vé, phim, định dạng, cụm rạp, phòng và loại phòng, ngày giờ, ghế, loại ghế, giá vé; không hiện mã QR). Vé không hợp lệ: hiện một lý do duy nhất MSG-45 (mã QR không tương ứng vé), MSG-46 (cụm rạp khác), MSG-47 (suất chiếu khác), MSG-48 (đã sử dụng) hoặc MSG-49 (đã huỷ). Khối kết quả giữ tới lần quét kế tiếp | UC-009 bước 4-7, luồng 4a-4e, Dữ liệu ra 2, 3; BR-22 đến BR-25, BR-33; MSG-44 đến MSG-49 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Suất chiếu đang soát | - | Lựa chọn | Chọn, bắt buộc | Một suất chiếu của cụm rạp của nhân viên soát vé; chọn một lần, dùng cho các vé quét liên tiếp | Hiển thị phim, định dạng, phòng chiếu, ngày giờ bắt đầu dd/MM/yyyy HH:mm | UC-009 Dữ liệu vào 1 STT 1, Dữ liệu ra 1 STT 1; BR-34 |
| Mã QR của vé | - | Chữ | Quét bằng camera, bắt buộc | Tương ứng một vé của hệ thống; nội dung và định dạng không quy định; không có nhập tay | Giao diện chỉ chuyển nguyên chuỗi đọc được | UC-009 Dữ liệu vào 2 STT 1; REQ-126, REQ-128 |
| Mã đặt vé, tên phim, định dạng, tên cụm rạp, tên phòng và loại phòng | - | Chữ | Hiển thị | Như nội dung vé | - | UC-009 Dữ liệu ra 2 STT 1-5 |
| Ngày giờ bắt đầu suất chiếu | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm | - | UC-009 Dữ liệu ra 2 STT 6 |
| Vị trí ghế, loại ghế | - | Chữ | Hiển thị | Mã hàng và số ghế; ghế thường, VIP hoặc đôi | - | UC-009 Dữ liệu ra 2 STT 7-8 |
| Giá vé | 15 (Thiết kế: đủ cho 999.999.999 đ) | Tiền | Hiển thị, căn phải | Số nguyên đồng, dấu chấm hàng nghìn, " đ" | - | UC-009 Dữ liệu ra 2 STT 9 |
| Lý do vé không hợp lệ | - | Lựa chọn | Hiển thị | Một lý do duy nhất theo thứ tự: không tương ứng vé, cụm rạp khác, suất chiếu khác, đã sử dụng, đã huỷ | - | UC-009 Dữ liệu ra 3 STT 1; BR-33 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Suất chiếu đang soát | Chọn | Bắt buộc phải chọn trước khi quét --> thuộc danh sách của cụm rạp mình | - |
| Mã QR của vé | Quét (hệ thống) | Tương ứng một vé --> cụm rạp --> suất chiếu --> chưa sử dụng --> chưa huỷ | MSG-45; MSG-46; MSG-47; MSG-48; MSG-49 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-16 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Khối kết quả lớn có chữ, biểu tượng và màu; giữ tới lần quét kế (UI-STT 45) | - |
| SCR-16 | Nielsen 5 Ngăn lỗi | Đạt | Chống đọc lại cùng mã trong 3 giây để không sinh thêm kết quả đã sử dụng giả | - |
| SCR-16 | WCAG 1.4.1 | Đạt | Hợp lệ và từ chối khác nhau cả chữ, biểu tượng, màu | - |
| SCR-16 | WCAG 2.1.1 Bàn phím | Vi phạm còn mở | Việc quét bằng camera không có thao tác bàn phím thay thế; đặc tả cấm nhập tay mã QR (NFR-13) | Chấp nhận do ràng buộc thiết kế NFR-13; chọn suất chiếu và mọi điều khiển khác dùng được bằng bàn phím |
| SCR-16 | WCAG 4.1.3 | Đạt | Kết quả quét thông báo qua vùng role=alert/status | - |
| SCR-16 | Nielsen 7 | Đạt | Chọn suất một lần, quét liên tục không thao tác thêm | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 28, 33-35, 45.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-120, Q-123.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có màn hình điều hướng cho nhân viên soát vé vì chỉ có UC-009; menu chỉ có tên ứng dụng (UI-STT 22).
