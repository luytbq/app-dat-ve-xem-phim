# P11a - SCR-17 Trang chủ quản lý cụm rạp (Cinema manager home) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Lối vào UC-012, UC-015 có màn hình đích (SCR-28, SCR-30); đăng nhập từ SCR-21; DC là DC-CinemaAdminHomeView (P10 2.0) |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P01-actors.md 1.2; P02-usecases.md 1.9; P04 UC-012 1.2, UC-013 1.5, UC-014 1.7, UC-015 1.2; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-17 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-17 |
| UC | UC-012, UC-013, UC-014, UC-015 (lối vào) |
| Bước UC | UC-012, UC-013, UC-014, UC-015 bước 1 |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | Điều hướng (mở UC-012, UC-013, UC-014, UC-015) |
| DC | DC-CinemaAdminHomeView |
| Loại màn hình | Độc lập |
| Đến từ | SCR-21 (E-09); menu của mọi màn hình quản lý cụm rạp |
| Đi tới | SCR-18 (E-29), SCR-19 (E-30), SCR-28 (E-52), SCR-30 (E-54) |

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
| +--------------------+  +--------------------+         |
| | Quản lý phòng chiếu|  | Báo cáo cụm rạp    |         |
| | Thêm, sửa, xoá     |  | Doanh thu, tỉ lệ   |         |
| | phòng chiếu        |  | lấp đầy            |         |
| +--------------------+  +--------------------+         |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ (đang chọn) | Trên cùng | UI-STT 22 |
| Thông điệp | Vùng thông điệp (không có thông điệp use case nào kết thúc về đây) | Dưới tiêu đề | UI-STT 47 |
| Nội dung | Bốn thẻ lối vào | Giữa | UI-STT 47 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện các thẻ lối vào. Các use case của quản lý cụm rạp đều giữ lại ở màn hình thao tác khi bị từ chối (UI-STT 29) nên không có thông điệp use case hiện ở đây | UC-012 đến UC-015 Mục 3; UI-STT 29 |
| 2 | Thẻ Quản lý bảng giá | Liên kết | Nhấn | Mở SCR-18 | UC-013 bước 1 |
| 3 | Thẻ Lập lịch suất chiếu | Liên kết | Nhấn | Mở SCR-19 | UC-014 bước 1 |
| 4 | Thẻ Quản lý phòng chiếu | Liên kết | Nhấn | Mở SCR-28 | UC-012 bước 1 |
| 5 | Thẻ Báo cáo cụm rạp | Liên kết | Nhấn | Mở SCR-30 | UC-015 bước 1 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên lối vào use case | - | Chữ | Hiển thị, theo P02 | Quản lý phòng chiếu, Quản lý bảng giá, Lập lịch suất chiếu, Báo cáo cụm rạp | Một dòng mô tả ngắn lấy từ Mô tả ngắn P04 | P02 Mục 4; UC-012 đến UC-015 Mục 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-17 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Bốn lối vào đều có màn hình đích | Đã sửa khi UC-012, UC-015 được đặc tả |

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
| P10 | F4 (PKG-08) | View điều hướng cho quản lý cụm rạp | Đã áp dụng: P10 2.0 có DC-CinemaAdminHomeView |

## Vấn đề còn mở

Không có.
