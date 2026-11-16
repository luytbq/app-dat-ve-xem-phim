# P11a - SCR-39 Sửa họ tên nhân viên (Edit staff full name) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-017 1.2 (luồng 1d2-1d5, 1d4a, 1d4b, *a, Dữ liệu vào 3, BR-102); P05 GL-34; P07 UC-017; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-39 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-39 |
| UC | UC-017 |
| Bước UC | 1d2, 1d3, 1d4, 1d5; luồng 1d4a, 1d4b, *a |
| Tác nhân | ACT-06 Quản trị viên |
| Boundary AC | AC-B-ManageStaffAccountsForm (selectStaff, submitNewFullName, rejectStaffAccount, notifyStaffChanged, cancelStaffRequest, showStaffRequestCancelled) |
| DC | DC-ManageStaffAccountsView |
| Loại màn hình | Con phụ thuộc (pop-up modal) |
| Đến từ | SCR-37 (E-61) |
| Đi tới | Đóng ngầm định về SCR-37 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| Sửa họ tên nhân viên                        [ Đóng ]    |
|------------------------------------------------------|
| (vùng thông điệp: MSG-03, MSG-120)                     |
| Tài khoản: quan.tran@cinebook.example                  |
| * là bắt buộc                                          |
| Họ tên mới *          [ Trần Văn Quân               ]  |
|                  [ Huỷ yêu cầu ]  [ Lưu họ tên ]        |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp "Sửa họ tên nhân viên"; nút Đóng | Đầu hộp | UI-STT 09, 21, 50 |
| Thông điệp | MSG-03, MSG-120, MSG-72, MSG-73 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Email của tài khoản đã chọn (chỉ xem), ô Họ tên mới | Giữa hộp | UC-017 Dữ liệu vào 3 |
| Hành động | Huỷ yêu cầu, Lưu họ tên | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal với email của tài khoản đã chọn; ô Họ tên mới mang họ tên hiện tại | UC-017 luồng 1d2, 1d3 |
| 2 | Ô Họ tên mới | Ô nhập | Rời trường | Kiểm bắt buộc, không rỗng (MSG-03) | UC-017 Dữ liệu vào 3 STT 1; Q-163 |
| 3 | Nút Lưu họ tên | Nút chính | Nhấn | Kiểm ô theo UI-STT 19, gửi (nút bận theo UI-STT 27). Rỗng: MSG-03 ở lại hộp. Tài khoản vừa bị người khác thay đổi: MSG-120 rồi đóng hộp, tải lại SCR-37. Thành công: MSG-128, đóng hộp, làm mới SCR-37 | UC-017 luồng 1d4, 1d4a, 1d4b, 1d5; BR-102; MSG-03, MSG-120, MSG-128 |
| 4 | Nút Huỷ yêu cầu, nút Đóng | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-37 và hiện MSG-57 | UC-017 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email của tài khoản | 254 | Chữ | Hiển thị | Tài khoản đã chọn; không sửa được | - | UC-017 Dữ liệu vào 2 STT 1; Q-162 |
| Họ tên mới | 100 | Chữ | Nhập, bắt buộc, căn trái | Không rỗng (Q-163) | Độ dài theo Q-273 | UC-017 Dữ liệu vào 3 STT 1; Q-163 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Họ tên mới | Rời trường; nhấn Lưu | Bắt buộc | MSG-03 |
| Tài khoản | Nhấn Lưu (hệ thống) | Chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị | MSG-120 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-39 | Nielsen 6 Nhận biết thay vì nhớ lại | Đạt | Hộp nêu email của tài khoản đang sửa | - |
| SCR-39 | Baymard: nhãn trên ô, đánh dấu bắt buộc, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-39 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21, 50) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35.

## h) Thông điệp mới

Không có. MSG-120, MSG-128 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
