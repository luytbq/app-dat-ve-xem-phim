# P11a - SCR-02 Trang chủ khách (Customer home) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Bốn lối vào UC-001, UC-003, UC-004, UC-007 có màn hình đích (SCR-22, SCR-23, SCR-25, SCR-26); thẻ Đăng ký chỉ hiện khi chưa có phiên; DC là DC-CustomerHomeView (P10 2.0) |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P01-actors.md 1.2; P02-usecases.md 1.9; P04 UC-001 1.2, UC-003 1.1, UC-004 1.2, UC-005 1.15, UC-007 1.2, UC-008 1.10; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-02 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-02 |
| UC | UC-005, UC-008, UC-001, UC-003, UC-004, UC-007 (lối vào) |
| Bước UC | UC-005 bước 1; UC-008 bước 1; UC-001, UC-003, UC-004, UC-007 bước 1; thông điệp kết thúc, từ chối của UC-005; MSG-57 của UC-001 |
| Tác nhân | ACT-01 Khách |
| Boundary AC | Điều hướng (mở UC-005, UC-008, UC-001, UC-003, UC-004, UC-007) |
| DC | DC-CustomerHomeView |
| Loại màn hình | Độc lập |
| Đến từ | START-ACT-01 (E-01), SCR-01 (E-06), SCR-04 (E-16), SCR-05 (E-19), SCR-22 (E-43); menu của mọi màn hình khách |
| Đi tới | SCR-03 (E-10), SCR-07 (E-11), SCR-01 (E-12, E-49), SCR-05 (E-32), SCR-22 (E-41), SCR-23 (E-44), SCR-25 (E-47), SCR-26 (E-48) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                       [ Đăng nhập ] |
|------------------------------------------------------|
| Trang chủ                                              |
| [!] Đã hết thời gian giữ ghế. ...  (vùng thông điệp)   |
| (i) Bạn đang giữ ghế cho Phim A lúc 19:30 ngày 15/11,   |
|     còn 08:42            [ Tiếp tục thanh toán ]       |
| +--------------------+  +--------------------+         |
| | Đặt vé             |  | Huỷ vé             |         |
| | Chọn suất chiếu,   |  | Huỷ vé đã mua      |         |
| | ghế và thanh toán  |  | trực tuyến         |         |
| +--------------------+  +--------------------+         |
| +--------------------+  +--------------------+         |
| | Xem phim           |  | Tra cứu lịch chiếu |         |
| | Đang chiếu,        |  | Theo phim hoặc     |         |
| | sắp chiếu          |  | theo cụm rạp       |         |
| +--------------------+  +--------------------+         |
| +--------------------+  +--------------------+         |
| | Lịch sử đặt vé     |  | Đăng ký tài khoản  |         |
| | Các lần đã đặt     |  | (chỉ khi chưa      |         |
| |                    |  |  đăng nhập)        |         |
| +--------------------+  +--------------------+         |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ (đang chọn), Đăng nhập khi chưa có phiên | Trên cùng | UI-STT 22 |
| Thông điệp | Kết quả use case vừa kết thúc hoặc bị từ chối | Dưới tiêu đề | UI-STT 29, 47 |
| Dải giữ ghế | MSG-80 kèm đồng hồ còn lại và nút Tiếp tục thanh toán; chỉ hiện khi có lần giữ ghế đang chạy | Dưới vùng thông điệp | UI-STT 47; Q-119 |
| Nội dung | Sáu thẻ lối vào use case (Đăng ký chỉ khi chưa có phiên) | Giữa | UI-STT 47 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiển thị các thẻ lối vào. Nếu vừa chuyển từ màn hình khác do use case kết thúc thì hiện thông điệp tương ứng trong vùng thông điệp: MSG-09, MSG-13 (từ SCR-04), MSG-14, MSG-19 (từ SCR-05), MSG-57 (từ SCR-22) | UC-005 luồng 5b, 7b, 7c, 7e, *a; UC-001 luồng *a; MSG-09, MSG-13, MSG-14, MSG-19, MSG-57 |
| 2 | Thẻ Đặt vé | Liên kết | Nhấn | Mở SCR-03 Chọn suất chiếu | UC-005 bước 1 |
| 3 | Thẻ Huỷ vé | Liên kết | Nhấn | Khách đã có phiên: mở SCR-07. Chưa có phiên: mở SCR-01 dạng trang; đăng nhập xong về SCR-02, khách chọn lại Huỷ vé | UC-008 tiền điều kiện (REQ-12) |
| 4 | Thẻ Xem phim | Liên kết | Nhấn | Mở SCR-23; không cần phiên | UC-003 bước 1; UI-STT 47 |
| 5 | Thẻ Tra cứu lịch chiếu | Liên kết | Nhấn | Mở SCR-25; không cần phiên | UC-004 bước 1 |
| 6 | Thẻ Lịch sử đặt vé | Liên kết | Nhấn | Khách đã có phiên: mở SCR-26. Chưa có phiên: mở SCR-01 dạng trang; đăng nhập xong về SCR-02, khách chọn lại Lịch sử đặt vé | UC-007 bước 1, tiền điều kiện (REQ-12) |
| 7 | Thẻ Đăng ký tài khoản | Liên kết | Nhấn | Chỉ hiện khi chưa có phiên (UC-001 là use case trước phiên); mở SCR-22 | UC-001 bước 1; UI-STT 47 |
| 8 | Mục Đăng nhập (đầu trang) | Liên kết | Nhấn | Chỉ hiện khi chưa có phiên; mở SCR-01 dạng trang | UC-008 tiền điều kiện; Q-123 |
| 9 | Dải giữ ghế | Dải thông tin | Khởi tạo | Hỏi máy chủ khách có lần giữ ghế đang chạy không (BR-04). Có: hiện MSG-80 kèm đồng hồ còn lại tính từ thời điểm hết hạn máy chủ trả về; về 00:00 thì dải biến mất và hiện MSG-14. Không có: không hiện dải | UC-005 luồng 5b, 7b, 7c; BR-04, BR-10; UI-STT 47; Q-119 |
| 10 | Nút Tiếp tục thanh toán (trong dải) | Nút chính | Nhấn | Mở SCR-05, màn hình tự nạp lần giữ ghế đang chạy từ máy chủ | UC-005 bước 8; UI-STT 47; Q-119 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên lối vào use case | - | Chữ | Hiển thị, theo P02 | Tên use case theo P02 (Đặt vé, Huỷ vé, Xem phim, Tra cứu lịch chiếu, Lịch sử đặt vé, Đăng ký tài khoản) | Một dòng mô tả ngắn lấy từ Mô tả ngắn P04 | P02 Mục 4; UC-001, UC-003, UC-004, UC-005, UC-007, UC-008 Mục 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-02 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Sáu lối vào đều có màn hình đích | Đã sửa khi UC-001, UC-003, UC-004, UC-007 được đặc tả |
| SCR-02 | Nielsen 3 Kiểm soát và tự do | Đạt | Dải Tiếp tục thanh toán cho khách mở lại lần giữ ghế đang chạy (Q-119) | - |
| SCR-02 | Nielsen 8 Thẩm mỹ, tối giản | Đạt | Thẻ Đăng ký tài khoản chỉ hiện khi chưa có phiên, không hiện cho khách đã đăng nhập | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28-29, 33-35, 47.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-119, Q-123.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F4 (PKG-05) | View điều hướng cho khách | Đã áp dụng: P10 2.0 có DC-CustomerHomeView |

## Vấn đề còn mở

Q-119 đã trả lời theo đề xuất, chờ người dùng xác nhận.
