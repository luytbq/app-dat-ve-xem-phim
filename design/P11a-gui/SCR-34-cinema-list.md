# P11a - SCR-34 Danh sách cụm rạp (Cinema list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-011 1.2 (bước 1, 2, 6, luồng 1a1-1a3, 5a, Dữ liệu vào 2, Dữ liệu ra 1, 2, BR-142); P05-glossary.md 1.2; P07 UC-011; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-34 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-34 |
| UC | UC-011 |
| Bước UC | 1, 2, 6; 1a1, 1a2, 1a3; luồng 5a |
| Tác nhân | ACT-05 Quản lý chuỗi |
| Boundary AC | AC-B-ManageCinemasForm (requestCinemaAddition, showCinemaList, requestCinemaEdit, selectCinemaToEdit, showSavedCinema, notifyRefusal) |
| DC | DC-ManageCinemasView, DC-ManageCinemasStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-31 (E-57); SCR-35 (đóng pop-up ngầm định) |
| Đi tới | SCR-35 (E-58, pop-up) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                         [ Đăng xuất ]   |
|------------------------------------------------------------|
| Danh sách cụm rạp                          [ Thêm cụm rạp ]  |
| (vùng thông điệp: MSG-102, MSG-103, MSG-132)                  |
| Tên cụm rạp              | Tỉnh, thành phố | Địa chỉ          |
|--------------------------+-----------------+------------------|
| CineBook Vincom Bà Triệu | Hà Nội          | 191 Bà Triệu, Hai Bà Trưng |
|                          |                 |  [ Sửa ]         |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Danh sách cụm rạp"; nút chính Thêm cụm rạp | Đầu nội dung, căn phải | UI-STT 06 |
| Thông điệp | MSG-102, MSG-103, MSG-132 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng cụm rạp của chuỗi, mỗi hàng có nút Sửa | Giữa | UC-011 Dữ liệu ra 1; UI-STT 51 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiện danh sách cụm rạp của chuỗi, ghi nhận mốc hiển thị của từng cụm rạp. Rỗng: MSG-132 | UC-011 bước 2, luồng 1a1; BR-142; MSG-132 |
| 2 | Bảng cụm rạp | Bảng | Khởi tạo | Mỗi hàng: tên cụm rạp, tỉnh hoặc thành phố, địa chỉ (rỗng hiện "Chưa có"). Sắp theo tên cụm rạp | UC-011 Dữ liệu ra 1 STT 1 |
| 3 | Nút Thêm cụm rạp | Nút chính | Nhấn | Mở SCR-35 dạng pop-up modal ở chế độ thêm mới | UC-011 bước 1, 2, 3 |
| 4 | Nút Sửa (mỗi hàng) | Nút phụ | Nhấn | Mở SCR-35 chế độ sửa với thông tin hiện tại của cụm rạp đã chọn | UC-011 luồng 1a2, 1a3, Dữ liệu ra 3 |
| 5 | Thông điệp sau khi lưu | Vùng hiển thị | Nhận kết quả | Khi SCR-35 lưu thành công: hiện MSG-103, tải lại bảng, đánh dấu hàng vừa lưu (UI-STT 18). Khi SCR-35 báo cụm rạp đã bị người khác sửa: hiện MSG-102 và tải lại bảng | UC-011 bước 6, luồng 5a; BR-142; MSG-102, MSG-103 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên cụm rạp | 100 | Chữ | Hiển thị, căn trái | Không trùng cụm rạp khác (BR-141) | Độ dài theo Q-273 | UC-011 Dữ liệu ra 1 STT 1; BR-141 |
| Tỉnh, thành phố | 50 | Chữ | Hiển thị, căn trái | Văn bản | Độ dài theo Q-273 | UC-011 Dữ liệu ra 1 STT 1 |
| Địa chỉ | 255 | Chữ | Hiển thị, căn trái | Văn bản; rỗng hiện "Chưa có" | Độ dài theo Q-273 | UC-011 Dữ liệu ra 1 STT 1 |
| Cụm rạp cần sửa | - | Lựa chọn | Chọn, bắt buộc | Một cụm rạp trong danh sách của chuỗi | - | UC-011 Dữ liệu vào 2 STT 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-34 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục với SCR-32, SCR-28 (UI-STT 51) | - |
| SCR-34 | WCAG 2.4.3 Thứ tự tiêu điểm | Đạt | Đóng pop-up SCR-35 trả tiêu điểm về nút đã mở (UI-STT 21) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21, 28-31, 33-35.

## h) Thông điệp mới

Không có. MSG-102, MSG-103, MSG-132 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
