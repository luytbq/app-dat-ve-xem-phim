# P11a - SCR-28 Danh sách phòng chiếu (Auditorium list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-012 1.2 (bước 1, 2, 6, luồng 1a1-1a3, 1a2a, 1b1-1b4, 1b2a, 1b3a, 5c, Dữ liệu vào 2, Dữ liệu ra 1, 2, BR-135, BR-146, BR-147); P05 GL-40, GL-50; P07 UC-012; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-28 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-28 |
| UC | UC-012 |
| Bước UC | 1, 2, 6; 1a1, 1a2, 1a2a, 1a3; 1b1, 1b2, 1b2a, 1b3, 1b3a, 1b4; luồng 5c |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-ManageAuditoriumsForm (requestAuditoriumAddition, showAuditoriumList, requestAuditoriumEdit, selectAuditoriumToEdit, requestAuditoriumRemoval, selectAuditoriumToRemove, showRemovalSuccess, showSavedAuditorium, notifyRefusal) |
| DC | DC-ManageAuditoriumsView, DC-ManageAuditoriumsStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-17 (E-52); SCR-29 (đóng pop-up ngầm định) |
| Đi tới | SCR-29 (E-53, pop-up) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                         [ Đăng xuất ]   |
|------------------------------------------------------------|
| Danh sách phòng chiếu                    [ Thêm phòng chiếu ] |
| (vùng thông điệp: MSG-108, MSG-109, MSG-111, MSG-112, MSG-113, MSG-130) |
| Phòng    | Loại phòng | Định dạng | Sức chứa                 |
|----------+------------+-----------+--------------------------|
| Phòng 01 | Thường     | 2D        | 120 ghế                   |
|          |            |           | [ Sửa ] [ Xoá ]           |
| Phòng 05 | IMAX       | 2D, 3D    | 320 ghế                   |
|          |            |           | [ Sửa ] [ Xoá ]           |
+------------------------------------------------------------+
Hộp xác nhận (MSG-110): Xoá phòng chiếu Phòng 05? ... [ Giữ lại ] [ Xoá phòng chiếu ]
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Danh sách phòng chiếu"; nút chính Thêm phòng chiếu | Đầu nội dung, căn phải | UI-STT 06 |
| Thông điệp | MSG-108, MSG-109, MSG-111, MSG-112, MSG-113, MSG-130 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng phòng chiếu của cụm rạp, mỗi hàng có Sửa và Xoá | Giữa | UC-012 Dữ liệu ra 1; UI-STT 51 |
| Hộp thoại | Hộp xác nhận MSG-110 (modal) | Giữa màn hình | UI-STT 37 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiện các phòng chiếu của cụm rạp mà quản lý thuộc về, ghi nhận mốc hiển thị của từng phòng. Rỗng: MSG-130 | UC-012 bước 2, luồng 1a1, 1b1; BR-135, BR-146; MSG-130 |
| 2 | Bảng phòng chiếu | Bảng | Khởi tạo | Mỗi hàng: tên phòng, loại phòng, các định dạng chiếu được, sức chứa kèm "ghế" | UC-012 Dữ liệu ra 1 STT 1 |
| 3 | Nút Thêm phòng chiếu | Nút chính | Nhấn | Mở SCR-29 dạng pop-up modal ở chế độ thêm mới | UC-012 bước 1, 2, 3 |
| 4 | Nút Sửa (mỗi hàng) | Nút phụ | Nhấn | Gửi phòng đã chọn. Phòng thuộc cụm rạp: mở SCR-29 chế độ sửa với thông tin hiện tại gồm từng ghế. Không thuộc cụm rạp: MSG-113, ở lại danh sách | UC-012 luồng 1a2, 1a2a, 1a3; BR-135; MSG-113 |
| 5 | Nút Xoá (mỗi hàng) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-110 | UC-012 luồng 1b2; MSG-110; UI-STT 37 |
| 6 | Nút Xoá phòng chiếu (hộp xác nhận) | Nút chính phá huỷ | Nhấn | Gửi yêu cầu xoá (nút bận theo UI-STT 27). Thành công: MSG-111 và bỏ hàng khỏi bảng. Phòng đã từng có suất chiếu, kể cả suất đã xoá: MSG-112. Phòng không thuộc cụm rạp: MSG-113. Ở lại danh sách | UC-012 luồng 1b2a, 1b3, 1b3a, 1b4; BR-135, BR-147; MSG-111 đến MSG-113 |
| 7 | Nút Giữ lại (hộp xác nhận) | Nút phụ | Nhấn | Đóng hộp, không xoá | UC-012 luồng *a; UI-STT 37 |
| 8 | Thông điệp sau khi lưu | Vùng hiển thị | Nhận kết quả | Khi SCR-29 lưu thành công: hiện MSG-109, tải lại bảng và đánh dấu hàng phòng vừa lưu (UI-STT 18). Khi SCR-29 báo phòng đã bị người khác sửa: hiện MSG-108 và tải lại bảng | UC-012 bước 6, luồng 5c; BR-146; MSG-108, MSG-109 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên phòng chiếu | 50 | Chữ | Hiển thị, căn trái | Duy nhất trong cụm rạp (BR-145) | Độ dài theo Q-273 | UC-012 Dữ liệu ra 1 STT 1; BR-145 |
| Loại phòng | - | Lựa chọn | Hiển thị | Thường, 4DX hoặc IMAX | - | UC-012 Dữ liệu ra 1 STT 1; REQ-02 |
| Định dạng chiếu được | - | Lựa chọn | Hiển thị | 2D, 3D hoặc cả hai, cách nhau bằng dấu phẩy | - | UC-012 Dữ liệu ra 1 STT 1; REQ-55 |
| Sức chứa | 3 | Số | Hiển thị, căn phải | Số nguyên 50-400 kèm "ghế"; ghế đôi tính một ghế | Hệ thống tính từ sơ đồ ghế | UC-012 Dữ liệu ra 1 STT 1; BR-06, BR-144 |
| Phòng chiếu cần sửa hoặc xoá | - | Lựa chọn | Chọn, bắt buộc | Một phòng thuộc cụm rạp của quản lý (BR-135) | - | UC-012 Dữ liệu vào 2 STT 1; BR-135 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Phòng chiếu cần sửa hoặc xoá | Nhấn Sửa, Xoá (hệ thống) | Thuộc cụm rạp --> (xoá) chưa từng có suất chiếu | MSG-113; MSG-112 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-28 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận xoá nêu hậu quả (MSG-110) | - |
| SCR-28 | Nielsen 3 Kiểm soát và tự do | Đạt | Từ chối ở lại danh sách, không đẩy người dùng ra màn hình khác (UI-STT 29(2)) | - |
| SCR-28 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục bảng, nút Sửa và Xoá và hộp xác nhận với SCR-19 (UI-STT 51) | - |
| SCR-28 | WCAG 2.4.3 Thứ tự tiêu điểm | Đạt | Đóng pop-up SCR-29 trả tiêu điểm về nút đã mở (UI-STT 21) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21, 27-31, 33-35, 37.

## h) Thông điệp mới

Không có. MSG-108 đến MSG-113, MSG-130 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
