# P11a - SCR-05 Giữ ghế và thanh toán (Hold seats and pay) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-005 1.9 (bước 7-11, Dữ liệu ra 2, luồng 7b, 10a, 11a, *a); P09 F7.4, F7.6; P05 GL-52, GL-54; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-05 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-05 |
| UC | UC-005 |
| Bước UC | 8, 9, 10, 11; luồng 7b, 10a, 11a, *a |
| Tác nhân | ACT-01 Khách; ACT-07 Cổng thanh toán (tác nhân phụ, ngoài màn hình) |
| Boundary AC | AC-B-BookTicketsForm (showHeldSeats, requestOnlinePayment, cancelSeatHold, notifyRefusal) |
| DC | DC-BookTicketsView, DC-BookTicketsStore |
| Loại màn hình | Phụ thuộc có dữ liệu (lần giữ ghế) |
| Đến từ | SCR-04 (E-15), SCR-02 (E-32), SCR-06 (E-34) |
| Đi tới | SCR-06 (E-18), SCR-02 (E-19) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Giữ ghế và thanh toán                                        |
| (vùng thông điệp: MSG-15, MSG-26, MSG-27)                    |
| +--------------------------------+ +----------------------+ |
| | Phim A, 2D, Phòng 3            | | Thời gian giữ ghế    | |
| | 15/11/2026 19:30               | | còn lại              | |
| | Ghế    | Loại    |   Giá vé    | |      08:42           | |
| | F7     | Ghế VIP | 120.000 đ   | | Hết hạn lúc 19:02:11 | |
| | F8     | Ghế VIP | 120.000 đ   | +----------------------+ |
| | Tổng tiền (2 vé)   240.000 đ   |                          |
| +--------------------------------+                          |
|                 [ Huỷ giữ ghế ]  [ Thanh toán qua VNPay ]   |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Giữ ghế và thanh toán" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-15, MSG-26, MSG-27 | Dưới tiêu đề | UI-STT 08 |
| Nội dung chính | Suất chiếu; bảng ghế đã giữ (vị trí, loại, giá vé); tổng tiền | Cột trái từ 1024 px | UC-005 Dữ liệu ra 2; UI-STT 44 |
| Vùng phụ | Khối đồng hồ đếm ngược và thời điểm hết hạn | Cột phải từ 1024 px, trên nội dung dưới 1024 px | UI-STT 43 |
| Hành động | Huỷ giữ ghế (nút phụ), Thanh toán qua VNPay (nút chính) | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện suất chiếu, bảng các ghế đã giữ kèm loại ghế và giá vé từng ghế, tổng tiền, đồng hồ đếm ngược tính từ thời điểm hết hạn máy chủ trả về. Khi mở từ dải Tiếp tục thanh toán, từ SCR-06 hoặc sau khi tải lại trang, màn hình tự nạp lần giữ ghế đang chạy từ máy chủ; không có lần giữ ghế thì mở SCR-02 kèm MSG-14. Cài hộp cảnh báo của trình duyệt khi đóng hoặc tải lại trang | UC-005 bước 8, Dữ liệu ra 2 STT 1-3; BR-10; UI-STT 43 |
| 2 | Khối đồng hồ | Vùng hiển thị | Hết thời gian | Mỗi giây giảm một giây (mm:ss); còn 2 phút trở xuống đổi sang nền cảnh báo kèm chữ "Sắp hết thời gian"; trình đọc màn hình được báo ở mốc 5 phút, 2 phút, 1 phút, 30 giây. Về 00:00: vô hiệu hai nút, hiện MSG-14 và mở SCR-02 | UC-005 luồng 7b; BR-10; UI-STT 36, 43; MSG-14 |
| 3 | Nút Thanh toán qua VNPay | Nút chính | Nhấn | Hiện MSG-26 rồi MSG-27, yêu cầu hệ thống tạo giao dịch thanh toán cho tổng tiền đã hiển thị rồi chuyển trình duyệt sang cổng VNPay. Mỗi lần bấm tạo địa chỉ thanh toán mới cho cùng lần giữ ghế (BR-90). Hệ thống lỗi trước lúc chuyển sang cổng: ở lại màn hình, hiện MSG-15, đồng hồ vẫn chạy, nút dùng lại được. Khi thanh toán xong hoặc khách bấm huỷ ở cổng, VNPay đưa trình duyệt về địa chỉ trả về là SCR-06 (E-18). Quá hạn khi bấm: MSG-14, mở SCR-02 | UC-005 bước 9, 10, 11, luồng 10a, 7b; BR-90; NFR-15, NFR-16; MSG-14, MSG-15, MSG-27 |
| 4 | Nút Huỷ giữ ghế | Nút phụ | Nhấn | Mở hộp xác nhận MSG-18. Huỷ giữ ghế: giải phóng ghế, mở SCR-02 kèm MSG-19. Tiếp tục giữ ghế: đóng hộp | UC-005 luồng *a; MSG-18, MSG-19; UI-STT 37 |
| 5 | Mục Trang chủ (menu) | Liên kết | Nhấn | Hiện hộp MSG-77. Rời trang: mở SCR-02, lần giữ ghế vẫn chạy đến hết hạn (BR-04, BR-10). Ở lại: đóng hộp | UC-005 bước 7, BR-04, BR-10; MSG-77; Q-119 |
| 6 | Bảng ghế đã giữ | Bảng | Khởi tạo | Chỉ đọc: vị trí ghế, loại ghế, giá vé căn phải; dòng cuối là tổng tiền | UC-005 Dữ liệu ra 2 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Suất chiếu | - | Chữ | Hiển thị | Phim, định dạng, phòng chiếu, ngày giờ bắt đầu | - | UC-005 Dữ liệu ra 1 STT 1 |
| Ghế đã giữ (vị trí, loại) | - | Chữ | Hiển thị | Mã hàng và số ghế kèm loại ghế, ví dụ F7 (VIP) | - | UC-005 Dữ liệu ra 2 STT 1 |
| Giá vé từng ghế | 15 | Tiền | Hiển thị, căn phải | Số nguyên đồng, phân cách hàng nghìn bằng dấu chấm kèm " đ" | Thiết kế: 15 ký tự đủ cho "999.999.999 đ"; giá đã chốt lúc giữ ghế (BR-65) | UC-005 Dữ liệu ra 2 STT 2; BR-65 |
| Tổng tiền | 15 | Tiền | Hiển thị, căn phải | Tổng giá vé các ghế đã giữ | Thiết kế: 15 ký tự đủ cho tổng 8 ghế; khớp tổng các dòng (240.000 đ = 120.000 x 2) | UC-005 Dữ liệu ra 2 STT 3 |
| Thời điểm hết hạn giữ ghế | 8 | Giờ | Hiển thị | HH:mm:ss, bằng thời điểm giữ thành công cộng 10 phút | Thiết kế: giờ máy chủ đã hiệu chỉnh độ lệch đồng hồ | BR-10; GL-52; UI-STT 43 |
| Thời gian còn lại | 5 | Giờ | Hiển thị, 32 px đậm | mm:ss, từ 10:00 đến 00:00 | Tính ở trình duyệt từ thời điểm hết hạn | BR-10; UI-STT 43 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-05 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Đồng hồ, chữ "Sắp hết thời gian", MSG-26, MSG-27 (UI-STT 43, 27) | - |
| SCR-05 | Nielsen 3 Kiểm soát và tự do | Đạt | Khách tải lại hoặc rời trang vẫn mở lại được lần giữ ghế qua dải Tiếp tục thanh toán (Q-119); không gia hạn được vì BR-10 | - |
| SCR-05 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận huỷ giữ ghế (MSG-18); cảnh báo khi rời trang (MSG-77) | - |
| SCR-05 | WCAG 2.2.1 Giới hạn thời gian | Đạt | Giới hạn 10 phút là quy tắc nghiệp vụ thiết yếu, có cảnh báo ở bốn mốc (UI-STT 36) | - |
| SCR-05 | WCAG 1.4.1 | Đạt | Trạng thái sắp hết hạn có chữ và nền, không chỉ màu | - |
| SCR-05 | Baymard: tóm tắt đơn và tổng tiền ở bước thanh toán | Đạt | Bảng ghế, giá và tổng tiền cạnh nút thanh toán (UI-STT 44) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 27-31, 33-35, 37, 44.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-119.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-B-BookTicketsForm | Chưa có trách nhiệm hiển thị thời điểm hết hạn giữ ghế (showHeldSeats chỉ nêu ghế, giá, tổng tiền) | Thêm thời điểm hết hạn vào dữ liệu hiển thị của showHeldSeats; giao diện cần để vẽ đồng hồ |

## Vấn đề còn mở

Q-119 đã trả lời theo đề xuất, chờ người dùng xác nhận.
