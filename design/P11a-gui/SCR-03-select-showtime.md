# P11a - SCR-03 Chọn suất chiếu (Select showtime) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-005 1.9 (bước 1, 2, Dữ liệu ra 1, luồng 2a, 2c); P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-03 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-03 |
| UC | UC-005 |
| Bước UC | 1, 2; luồng 2a, 2c |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BookTicketsForm (selectShowtime) |
| DC | DC-BookTicketsView |
| Loại màn hình | Độc lập |
| Đến từ | SCR-02 (E-10); SCR-04 (E-17, luồng 7d) |
| Đi tới | SCR-04 (E-13) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                                   |
|------------------------------------------------------|
| Chọn suất chiếu                                        |
| (vùng thông điệp: MSG-06, MSG-08, MSG-12, MSG-74)      |
| Phim      | Định dạng | Phòng chiếu       | Bắt đầu    |
|-----------+-----------+-------------------+------------|
| Phim A    | 2D        | CineBook Cầu Giấy | 15/11/2026 |
|           |           | - Phòng 3         | 19:30  [Chọn]|
| Phim B    | 3D        | CineBook Cầu Giấy | 15/11/2026 |
|           |           | - Phòng 5         | 20:15  [Chọn]|
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Chọn suất chiếu" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-06, MSG-08, MSG-12, MSG-74 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng suất chiếu (thẻ khi dưới 600 px), mỗi hàng một nút Chọn | Giữa | UI-STT 18 |
| Hành động | Không có nút chung; nút Chọn nằm trên từng hàng | - | Một nút chính mỗi hàng, UI-STT 07 áp theo hàng |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiển thị danh sách suất chiếu có thể chọn (Dữ liệu ra 1 STT 1). Danh sách rỗng: MSG-74 | UC-005 bước 1; Q-120; MSG-74 |
| 2 | Bảng suất chiếu | Bảng | Khởi tạo | Mỗi hàng gồm phim, định dạng, phòng chiếu (kèm tên cụm rạp), ngày giờ bắt đầu theo dd/MM/yyyy HH:mm | UC-005 Dữ liệu ra 1 STT 1 |
| 3 | Nút Chọn (mỗi hàng) | Nút chính của hàng | Nhấn | Gửi suất chiếu đã chọn. Hệ thống kiểm đã mở bán và chưa bắt đầu. Hợp lệ: mở SCR-04 với suất chiếu đã chọn. Chưa mở bán: MSG-06, ở lại, tải lại danh sách. Đã bắt đầu: MSG-08, ở lại, tải lại danh sách | UC-005 bước 1, 2, luồng 2a, 2c; BR-01, BR-45; MSG-06, MSG-08 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Phim | - | Chữ | Hiển thị | Tên phim của suất chiếu | Hiển thị nguyên văn | UC-005 Dữ liệu ra 1 STT 1 |
| Định dạng | - | Lựa chọn | Hiển thị | 2D hoặc 3D | - | UC-005 Dữ liệu ra 1 STT 1; GL-05 |
| Phòng chiếu | - | Chữ | Hiển thị | Tên phòng chiếu, ghép sau tên cụm rạp | Cụm rạp để khách phân biệt (Q-120) | UC-005 Dữ liệu ra 1 STT 1; Q-120 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị, căn trái | Định dạng dd/MM/yyyy HH:mm | - | UC-005 Dữ liệu ra 1 STT 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-03 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở | Không có lọc, tìm kiếm danh sách suất chiếu (thuộc UC-004 chưa đặc tả) | Chờ Q-120 |
| SCR-03 | Nielsen 3 Kiểm soát và tự do | Đạt | Từ chối ở lại danh sách theo UI-STT 29(2), không đẩy khách khỏi màn hình | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21-24, 28-29, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-120.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Danh sách, bộ lọc và thông tin cụm rạp phụ thuộc Q-120.
