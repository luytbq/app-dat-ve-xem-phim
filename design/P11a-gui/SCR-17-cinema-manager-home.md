# P11a - SCR-17 Trang chủ quản lý cụm rạp (Cinema manager home) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P01-actors.md; P02-usecases.md; P04 UC-013 1.2, UC-014 1.3; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-17 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-17 |
| UC | UC-013, UC-014 (lối vào); UC-012, UC-015 (chưa có màn hình đích) |
| Bước UC | UC-013 bước 1; UC-014 bước 1 |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | Điều hướng (mở UC-013, UC-014) |
| DC | Chưa có (điều hướng) |
| Loại màn hình | Độc lập |
| Đến từ | SCR-01 (E-09); menu của mọi màn hình quản lý cụm rạp |
| Đi tới | SCR-18 (E-29), SCR-19 (E-30) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                                   |
|------------------------------------------------------|
| Trang chủ quản lý cụm rạp                              |
|                                                        |
| +--------------------+  +--------------------+         |
| | Quản lý bảng giá   |  | Lập lịch suất chiếu|         |
| | Đặt giá, bỏ giá    |  | Lập, sửa, xoá      |         |
| | của cụm rạp        |  | suất chiếu         |         |
| +--------------------+  +--------------------+         |
| Chưa có: Quản lý phòng chiếu, Xem báo cáo cụm rạp      |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ (đang chọn) | Trên cùng | UI-STT 22 |
| Thông điệp | Vùng thông điệp (không có thông điệp use case nào kết thúc về đây) | Dưới tiêu đề | UI-STT 47 |
| Nội dung | Hai thẻ hoạt động và hai thẻ vô hiệu | Giữa | UI-STT 47 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện các thẻ lối vào. Các use case của quản lý cụm rạp đều giữ lại ở màn hình thao tác khi bị từ chối (UI-STT 29) nên không có thông điệp use case hiện ở đây | UC-013, UC-014 Mục 3; UI-STT 29 |
| 2 | Thẻ Quản lý bảng giá | Liên kết | Nhấn | Mở SCR-18 | UC-013 bước 1 |
| 3 | Thẻ Lập lịch suất chiếu | Liên kết | Nhấn | Mở SCR-19 | UC-014 bước 1 |
| 4 | Thẻ Quản lý phòng chiếu, Xem báo cáo cụm rạp | Liên kết vô hiệu | Nhấn | Chưa có màn hình đích (UC-012, UC-015); thẻ hiện chữ "Chưa có" | P02; UI-STT 47 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên lối vào use case | - | Chữ | Hiển thị, theo P02 | Quản lý bảng giá, Lập lịch suất chiếu | - | P02 Mục 4; UC-013, UC-014 Mục 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-17 | Nielsen 1 Hiển thị trạng thái hệ thống | Vi phạm còn mở (do phạm vi) | Hai lối vào UC-012, UC-015 chưa có màn hình đích | Chấp nhận, cập nhật khi use case được đặc tả |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28, 33-35, 47.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-123.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F4 (PKG-08) | Chưa có View điều hướng cho quản lý cụm rạp | Thêm DC-CinemaAdminHomeView vào PKG-08 |

## Vấn đề còn mở

Không có.
