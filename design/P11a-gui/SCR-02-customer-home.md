# P11a - SCR-02 Trang chủ khách (Customer home) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P01-actors.md; P02-usecases.md; P04 UC-005 1.8, UC-008 1.4; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-02 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-02 |
| UC | UC-005, UC-008 (lối vào); UC-001, UC-003, UC-004, UC-007 (chưa có màn hình đích) |
| Bước UC | UC-005 bước 1; UC-008 bước 1; thông điệp kết thúc, từ chối của UC-005 |
| Tác nhân | ACT-01 Khách |
| Boundary AC | Điều hướng (mở UC-005, UC-008) |
| DC | Chưa có (điều hướng) |
| Loại màn hình | Độc lập |
| Đến từ | START-ACT-01 (E-01), SCR-01 (E-06), SCR-04 (E-16), SCR-05 (E-19); menu của mọi màn hình khách |
| Đi tới | SCR-03 (E-10), SCR-07 (E-11), SCR-01 (E-12) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                       [ Đăng nhập ] |
|------------------------------------------------------|
| Trang chủ                                              |
| [!] Đã hết thời gian giữ ghế. ...  (vùng thông điệp)   |
|                                                        |
| +--------------------+  +--------------------+         |
| | Đặt vé             |  | Huỷ vé             |         |
| | Chọn suất chiếu,   |  | Huỷ vé đã mua      |         |
| | ghế và thanh toán  |  | trực tuyến         |         |
| +--------------------+  +--------------------+         |
| Chưa có: Đăng ký tài khoản, Tra cứu phim,              |
|          Tra cứu lịch chiếu, Xem lịch sử đặt vé        |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ (đang chọn), Đăng nhập khi chưa có phiên | Trên cùng | UI-STT 22 |
| Thông điệp | Kết quả use case vừa kết thúc hoặc bị từ chối | Dưới tiêu đề | UI-STT 29, 47 |
| Nội dung | Thẻ lối vào use case; thẻ vô hiệu cho use case chưa có màn hình | Giữa | UI-STT 47 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiển thị các thẻ lối vào. Nếu vừa chuyển từ màn hình khác do use case kết thúc thì hiện thông điệp tương ứng trong vùng thông điệp: MSG-09, MSG-13 (từ SCR-04), MSG-14, MSG-19 (từ SCR-05) | UC-005 luồng 5b, 7b, 7c, 7e, *a; MSG-09, MSG-13, MSG-14, MSG-19 |
| 2 | Thẻ Đặt vé | Liên kết | Nhấn | Mở SCR-03 Chọn suất chiếu | UC-005 bước 1 |
| 3 | Thẻ Huỷ vé | Liên kết | Nhấn | Khách đã có phiên: mở SCR-07. Chưa có phiên: mở SCR-01 dạng trang; đăng nhập xong về SCR-02, khách chọn lại Huỷ vé | UC-008 tiền điều kiện (REQ-12) |
| 4 | Thẻ Đăng ký tài khoản, Tra cứu phim, Tra cứu lịch chiếu, Xem lịch sử đặt vé | Liên kết vô hiệu | Nhấn | Chưa có màn hình đích (UC-001, UC-003, UC-004, UC-007); thẻ hiện chữ "Chưa có" và không nhận tiêu điểm hoạt động | P02; UI-STT 47 |
| 5 | Mục Đăng nhập (đầu trang) | Liên kết | Nhấn | Chỉ hiện khi chưa có phiên; mở SCR-01 dạng trang | UC-008 tiền điều kiện; Q-123 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên lối vào use case | - | Chữ | Hiển thị, theo P02 | Tên use case theo P02 (Đặt vé, Huỷ vé) | Một dòng mô tả ngắn lấy từ Mô tả ngắn P04 | P02 Mục 4; UC-005, UC-008 Mục 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-02 | Nielsen 1 Hiển thị trạng thái hệ thống | Vi phạm còn mở (do phạm vi) | Bốn lối vào UC-001, UC-003, UC-004, UC-007 chưa có màn hình đích | Chấp nhận, cập nhật khi các use case được đặc tả |
| SCR-02 | Nielsen 8 Thẩm mỹ, tối giản | Đạt | Hai thẻ hoạt động, bốn thẻ vô hiệu gom một dòng | - |

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
| P10 | F4 (PKG-05) | Chưa có View điều hướng cho khách | Thêm DC-CustomerHomeView vào PKG-05 |

## Vấn đề còn mở

Q-119: khi có lần giữ ghế đang chạy, chưa có lối quay lại SCR-05 từ màn hình này.
