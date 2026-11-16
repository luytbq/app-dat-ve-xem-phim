# P11a - SCR-40 Đặt lại mật khẩu nhân viên (Reset staff password) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-017 1.2 (luồng 1e2-1e5, 1e4a, *a, Dữ liệu vào 4, BR-102); P05 GL-34; P07 UC-017; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-40 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-40 |
| UC | UC-017 |
| Bước UC | 1e2, 1e3, 1e4, 1e5; luồng 1e4a, *a |
| Tác nhân | ACT-06 Quản trị viên |
| Boundary AC | AC-B-ManageStaffAccountsForm (selectStaff, submitNewPassword, rejectStaffAccount, notifyStaffChanged, cancelStaffRequest, showStaffRequestCancelled) |
| DC | DC-ManageStaffAccountsView |
| Loại màn hình | Con phụ thuộc (pop-up modal) |
| Đến từ | SCR-37 (E-62) |
| Đi tới | Đóng ngầm định về SCR-37 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| Đặt lại mật khẩu nhân viên                  [ Đóng ]    |
|------------------------------------------------------|
| (vùng thông điệp: MSG-03, MSG-120)                     |
| Tài khoản: quan.tran@cinebook.example                  |
| * là bắt buộc                                          |
| Mật khẩu mới *        [ ***************  ] [ Hiện mật khẩu ] |
|   Giao mật khẩu mới cho nhân viên ngoài hệ thống        |
|                  [ Huỷ yêu cầu ]  [ Đặt lại mật khẩu ]  |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp "Đặt lại mật khẩu nhân viên"; nút Đóng | Đầu hộp | UI-STT 09, 21, 50 |
| Thông điệp | MSG-03, MSG-120, MSG-72, MSG-73 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Email của tài khoản đã chọn (chỉ xem), ô Mật khẩu mới, nút Hiện mật khẩu | Giữa hộp | UC-017 Dữ liệu vào 4 |
| Hành động | Huỷ yêu cầu, Đặt lại mật khẩu | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal với email của tài khoản đã chọn; ô mật khẩu để trống | UC-017 luồng 1e2, 1e3 |
| 2 | Ô Mật khẩu mới | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03); không có điều kiện độ dài khác | UC-017 Dữ liệu vào 4 STT 1; Q-274 |
| 3 | Nút Hiện mật khẩu | Nút | Nhấn | Bật tắt hiển thị ký tự trong ô mật khẩu | UI-STT 16 |
| 4 | Nút Đặt lại mật khẩu | Nút chính | Nhấn | Kiểm ô theo UI-STT 19, gửi (nút bận theo UI-STT 27). Rỗng: MSG-03 ở lại hộp. Tài khoản vừa bị người khác thay đổi: MSG-120 rồi đóng hộp, tải lại SCR-37. Thành công: MSG-129, đóng hộp, làm mới SCR-37. Hệ thống không gửi mật khẩu cho nhân viên | UC-017 luồng 1e3, 1e4, 1e4a, 1e5; BR-102; Q-161; MSG-03, MSG-120, MSG-129 |
| 5 | Nút Huỷ yêu cầu, nút Đóng | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-37 và hiện MSG-57 | UC-017 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email của tài khoản | 254 | Chữ | Hiển thị | Tài khoản đã chọn | - | UC-017 Dữ liệu vào 2 STT 1 |
| Mật khẩu mới | 64 | Chữ | Nhập, bắt buộc, ẩn ký tự, căn trái | Không có điều kiện riêng ngoài bắt buộc nhập | Thiết kế: tối đa 64 ký tự như SCR-01 (Q-124) | UC-017 Dữ liệu vào 4 STT 1; Q-161, Q-162, Q-274 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Mật khẩu mới | Rời trường; nhấn Đặt lại mật khẩu | Bắt buộc | MSG-03 |
| Tài khoản | Nhấn Đặt lại mật khẩu (hệ thống) | Chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị | MSG-120 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-40 | Nielsen 6 Nhận biết thay vì nhớ lại | Đạt | Hộp nêu email của tài khoản đang đặt lại mật khẩu | - |
| SCR-40 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Có Hiện mật khẩu, không chặn dán (UI-STT 16, 46) | - |
| SCR-40 | Baymard: nhãn trên ô, đánh dấu bắt buộc | Đạt | UI-STT 16 | - |
| SCR-40 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21, 50) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35.

## h) Thông điệp mới

Không có. MSG-120, MSG-129 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-274.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
