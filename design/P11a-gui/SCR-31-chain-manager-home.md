# P11a - SCR-31 Trang chủ quản lý chuỗi (Chain manager home) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P01-actors.md 1.2; P02-usecases.md 1.9; P04 UC-010 1.2, UC-011 1.2, UC-016 1.2; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-31 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-31 |
| UC | UC-010, UC-011, UC-016 (lối vào) |
| Bước UC | UC-010 bước 1; UC-011 bước 1; UC-016 bước 1 |
| Tác nhân | ACT-05 Quản lý chuỗi |
| Boundary AC | Điều hướng (mở UC-010, UC-011, UC-016) |
| DC | Chưa có (điều hướng) |
| Loại màn hình | Độc lập |
| Đến từ | SCR-21 (E-37); menu của mọi màn hình quản lý chuỗi |
| Đi tới | SCR-32 (E-55), SCR-34 (E-57), SCR-36 (E-59) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                     [ Đăng xuất ] |
|------------------------------------------------------|
| Trang chủ quản lý chuỗi                                |
|                                                        |
| +--------------------+  +--------------------+         |
| | Quản lý phim       |  | Quản lý cụm rạp    |         |
| | Thêm, sửa phim     |  | Thêm, sửa cụm rạp  |         |
| | của chuỗi          |  | của chuỗi          |         |
| +--------------------+  +--------------------+         |
| +--------------------+                                 |
| | Báo cáo toàn chuỗi |                                 |
| | Doanh thu, tỉ lệ   |                                 |
| | lấp đầy, so sánh   |                                 |
| +--------------------+                                 |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ (đang chọn), Đăng xuất | Trên cùng | UI-STT 22 |
| Thông điệp | Vùng thông điệp (không có thông điệp use case nào kết thúc về đây) | Dưới tiêu đề | UI-STT 47 |
| Nội dung | Ba thẻ lối vào | Giữa | UI-STT 47 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện ba thẻ lối vào. Các use case của quản lý chuỗi đều giữ lại ở màn hình thao tác khi bị từ chối (UI-STT 29) nên không có thông điệp use case hiện ở đây | UC-010, UC-011, UC-016 Mục 3; UI-STT 29 |
| 2 | Thẻ Quản lý phim | Liên kết | Nhấn | Mở SCR-32 | UC-010 bước 1 |
| 3 | Thẻ Quản lý cụm rạp | Liên kết | Nhấn | Mở SCR-34 | UC-011 bước 1 |
| 4 | Thẻ Báo cáo toàn chuỗi | Liên kết | Nhấn | Mở SCR-36 | UC-016 bước 1 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên lối vào use case | - | Chữ | Hiển thị, theo P02 | Quản lý phim, Quản lý cụm rạp, Báo cáo toàn chuỗi | Một dòng mô tả ngắn lấy từ Mô tả ngắn P04 | P02 Mục 4; UC-010, UC-011, UC-016 Mục 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-31 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục thẻ với SCR-02, SCR-09, SCR-17 (UI-STT 47) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28, 33-35, 47.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-275.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F4 (PKG-09) | Chưa có View điều hướng cho quản lý chuỗi | Thêm DC-ChainAdminHomeView vào PKG-09 (như DC-CinemaAdminHomeView ở PKG-08) |

## Vấn đề còn mở

Không có.
