# P11a - SCR-09 Trang chủ quầy (Counter home) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P01-actors.md; P02-usecases.md; P04 UC-005 1.8, UC-008 1.4; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-09 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-09 |
| UC | UC-005, UC-008 (lối vào) |
| Bước UC | UC-005 bước 1; UC-008 bước 1a; thông điệp kết thúc, từ chối của UC-005 tại quầy |
| Tác nhân | ACT-02 Nhân viên quầy |
| Boundary AC | Điều hướng (mở UC-005, UC-008) |
| DC | Chưa có (điều hướng) |
| Loại màn hình | Độc lập |
| Đến từ | SCR-01 (E-07); SCR-10 (E-24); SCR-11 (E-26); menu của mọi màn hình quầy |
| Đi tới | SCR-10 (E-21), SCR-13 (E-22) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                                   |
|------------------------------------------------------|
| Trang chủ quầy                                         |
| [!] Bạn đang có một lần giữ ghế chưa kết thúc. ...     |
|                                                        |
| +--------------------+  +--------------------+         |
| | Bán vé             |  | Huỷ vé             |         |
| | Chọn suất, ghế,    |  | Huỷ vé mua tại     |         |
| | thu tiền mặt, in vé|  | quầy theo mã đặt vé|         |
| +--------------------+  +--------------------+         |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ (đang chọn) | Trên cùng | UI-STT 22 |
| Thông điệp | Kết quả use case vừa kết thúc hoặc bị từ chối | Dưới tiêu đề | UI-STT 29, 47 |
| Nội dung | Hai thẻ lối vào | Giữa | UI-STT 47 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hai thẻ lối vào. Nếu use case vừa kết thúc hoặc bị từ chối thì hiện thông điệp: MSG-09, MSG-13 (từ SCR-10), MSG-19, MSG-20, MSG-29 (từ SCR-11) | UC-005 luồng 5b, 7b, 7c, 7e, 9a1a, *a; MSG-09, MSG-13, MSG-19, MSG-20, MSG-29 |
| 2 | Thẻ Bán vé | Liên kết | Nhấn | Mở SCR-10 | UC-005 bước 1 |
| 3 | Thẻ Huỷ vé | Liên kết | Nhấn | Mở SCR-13 | UC-008 luồng 1a |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên lối vào use case | - | Chữ | Hiển thị, theo P02 | Bán vé (UC-005 kênh quầy), Huỷ vé (UC-008 kênh quầy) | - | P02 Mục 4; UC-005 luồng 9a; UC-008 luồng 1a |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-09 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục thẻ với SCR-02 và SCR-17 (UI-STT 47) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28-29, 33-35, 47.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-123.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F4 (PKG-06) | Chưa có View điều hướng cho nhân viên quầy | Thêm DC-CounterHomeView vào PKG-06 |

## Vấn đề còn mở

Không có.
