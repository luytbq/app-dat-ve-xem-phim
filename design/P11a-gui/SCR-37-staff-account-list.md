# P11a - SCR-37 Danh sách tài khoản nhân viên (Staff account list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-017 1.2 (luồng 1a1-1a3, 1b1-1b4, 1c1-1c4, 1d1, 1e1, Dữ liệu vào 2, Dữ liệu ra 2, 3, BR-96, BR-97, BR-100, BR-101, BR-102); P05 GL-34, GL-43; P07 UC-017; P08-analysis-model.md 2.0 (F3); P09-architecture.md 2.0 (F7.11); P10-design-elements.md 2.0 (F3, F4, Q-271). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-37 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-37 |
| UC | UC-017 |
| Bước UC | 1a1, 1a2, 1a3; 1b1, 1b2, 1b3, 1b3a, 1b3b, 1b4; 1c1, 1c2, 1c3, 1c3a, 1c3b, 1c4; 1d1; 1e1; luồng 5b |
| Tác nhân | ACT-06 Quản trị viên |
| Boundary AC | AC-B-ManageStaffAccountsForm (requestCreateStaff, requestUpdateStaff, requestLockStaff, requestUnlockStaff, requestRenameStaff, requestResetStaffPassword, selectStaff, showStaffList, notifyStaffStatusUnchanged, notifyStaffChanged, showSavedStaffAccount) |
| DC | DC-ManageStaffAccountsView, DC-ManageStaffAccountsStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-21 (E-38); SCR-38, SCR-39, SCR-40 (đóng pop-up ngầm định); menu của mọi màn hình quản trị viên |
| Đi tới | SCR-38 (E-60, pop-up), SCR-39 (E-61, pop-up), SCR-40 (E-62, pop-up) |

## c) Hình ảnh màn hình

```text
+----------------------------------------------------------------------------+
| CineBook   Trang chủ                                          [ Đăng xuất ] |
|----------------------------------------------------------------------------|
| Danh sách tài khoản nhân viên                         [ Tạo tài khoản ]      |
| (vùng thông điệp: MSG-120, MSG-121, MSG-123, MSG-124, MSG-126 đến MSG-129, MSG-133) |
| Email                        | Họ tên        | Vai trò        | Cụm rạp           | Trạng thái     |
|------------------------------+---------------+----------------+-------------------+----------------|
| quan.tran@cinebook.example   | Trần Văn Quân | Nhân viên soát vé | CineBook Cầu Giấy | Đang hoạt động |
|  [ Đổi vai trò, cụm rạp ] [ Sửa họ tên ] [ Đặt lại mật khẩu ] [ Khoá ]      |
| lan.pham@cinebook.example    | Phạm Thị Lan  | Quản lý chuỗi  | Không có          | Bị khoá        |
|  [ Đổi vai trò, cụm rạp ] [ Sửa họ tên ] [ Đặt lại mật khẩu ] [ Mở khoá ]   |
+----------------------------------------------------------------------------+
Hộp xác nhận (MSG-122): Khoá tài khoản quan.tran@cinebook.example? ... [ Giữ nguyên ] [ Khoá tài khoản ]
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Danh sách tài khoản nhân viên"; nút chính Tạo tài khoản | Đầu nội dung, căn phải | UI-STT 06 |
| Thông điệp | MSG-120, MSG-121, MSG-123, MSG-124, MSG-126 đến MSG-129, MSG-133 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng tài khoản nhân viên, mỗi hàng có các nút thao tác | Giữa | UC-017 Dữ liệu ra 3; UI-STT 51 |
| Hộp thoại | Hộp xác nhận MSG-122 hoặc MSG-125 (modal) | Giữa màn hình | UI-STT 37 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiện danh sách tài khoản nhân viên (không gồm quản trị viên), ghi nhận mốc thay đổi của từng tài khoản lúc hiển thị. Rỗng: MSG-133 | UC-017 luồng 1a1, 1b1, 1c1, 1d1, 1e1, Dữ liệu ra 3; BR-102; MSG-133 |
| 2 | Bảng tài khoản | Bảng | Khởi tạo | Mỗi hàng: email, họ tên, vai trò, cụm rạp ("Không có" với quản lý chuỗi), trạng thái. Sắp theo email. Trạng thái Bị khoá có biểu tượng và chữ | UC-017 Dữ liệu ra 3 STT 1-5; UI-STT 13 |
| 3 | Nút Tạo tài khoản | Nút chính | Nhấn | Mở SCR-38 dạng pop-up modal ở chế độ tạo mới | UC-017 bước 1, 2, 3 |
| 4 | Nút Đổi vai trò, cụm rạp (mỗi hàng) | Nút phụ | Nhấn | Mở SCR-38 chế độ cập nhật với thông tin hiện tại của tài khoản | UC-017 luồng 1a2, 1a3 |
| 5 | Nút Sửa họ tên (mỗi hàng) | Nút phụ | Nhấn | Mở SCR-39 dạng pop-up modal cho tài khoản đã chọn | UC-017 luồng 1d2, 1d3 |
| 6 | Nút Đặt lại mật khẩu (mỗi hàng) | Nút phụ | Nhấn | Mở SCR-40 dạng pop-up modal cho tài khoản đã chọn | UC-017 luồng 1e2, 1e3 |
| 7 | Nút Khoá (hàng đang hoạt động) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-122 | UC-017 luồng 1b2; MSG-122; UI-STT 37 |
| 8 | Nút Khoá tài khoản (hộp xác nhận) | Nút chính phá huỷ | Nhấn | Gửi yêu cầu khoá (nút bận theo UI-STT 27). Thành công: MSG-123, đánh dấu hàng, trạng thái Bị khoá. Tài khoản đã bị khoá: MSG-124 và tải lại bảng. Tài khoản vừa bị người khác thay đổi: MSG-120 và tải lại bảng. Ở lại danh sách | UC-017 luồng 1b3, 1b3a, 1b3b, 1b4; BR-96, BR-97, BR-100, BR-101, BR-102; MSG-120, MSG-123, MSG-124 |
| 9 | Nút Mở khoá (hàng bị khoá) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-125 | UC-017 luồng 1c2; MSG-125; UI-STT 37 |
| 10 | Nút Mở khoá tài khoản (hộp xác nhận) | Nút chính | Nhấn | Gửi yêu cầu mở khoá. Thành công: MSG-126, đánh dấu hàng, trạng thái Đang hoạt động. Tài khoản đang hoạt động: MSG-127 và tải lại bảng. Tài khoản vừa bị thay đổi: MSG-120 và tải lại bảng | UC-017 luồng 1c3, 1c3a, 1c3b, 1c4; BR-102; MSG-120, MSG-126, MSG-127 |
| 11 | Nút Giữ nguyên (hộp xác nhận) | Nút phụ | Nhấn | Đóng hộp, không khoá hoặc mở khoá | UC-017 luồng *a; UI-STT 37 |
| 12 | Thông điệp sau khi lưu ở pop-up | Vùng hiển thị | Nhận kết quả | SCR-38 lưu thành công: MSG-121; SCR-39: MSG-128; SCR-40: MSG-129; hàng vừa lưu được đánh dấu (UI-STT 18). Pop-up báo tài khoản vừa bị thay đổi: MSG-120 và tải lại bảng | UC-017 bước 6, luồng 1d5, 1e5, 5b, 1d4b, 1e4a; MSG-120, MSG-121, MSG-128, MSG-129 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email | 254 | Chữ | Hiển thị, căn trái | Duy nhất giữa các tài khoản nhân viên (BR-95) | Thiết kế: 254 theo RFC 5321 | UC-017 Dữ liệu ra 3 STT 1 |
| Họ tên | 100 | Chữ | Hiển thị, căn trái | Không rỗng | Độ dài theo Q-273 | UC-017 Dữ liệu ra 3 STT 2 |
| Vai trò | - | Lựa chọn | Hiển thị | Nhân viên quầy, Nhân viên soát vé, Quản lý cụm rạp hoặc Quản lý chuỗi | - | UC-017 Dữ liệu ra 3 STT 3; BR-79 |
| Cụm rạp | - | Chữ | Hiển thị, căn trái | Tên cụm rạp, hoặc "Không có" với quản lý chuỗi | - | UC-017 Dữ liệu ra 3 STT 4; BR-78 |
| Trạng thái tài khoản | - | Lựa chọn | Hiển thị | Đang hoạt động hoặc Bị khoá | Biểu tượng và chữ | UC-017 Dữ liệu ra 3 STT 5; BR-96 |
| Tài khoản nhân viên được chọn | - | Lựa chọn | Chọn, bắt buộc | Một tài khoản trong bảng | - | UC-017 Dữ liệu vào 2 STT 1 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Tài khoản nhân viên được chọn | Nhấn Khoá tài khoản, Mở khoá tài khoản (hệ thống) | Chưa bị thay đổi kể từ lúc hiển thị --> đúng trạng thái (đang hoạt động khi khoá, bị khoá khi mở khoá) | MSG-120; MSG-124; MSG-127 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-37 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận khoá và mở khoá nêu hậu quả (MSG-122, MSG-125); nút xác nhận đặt tên theo hành động | - |
| SCR-37 | Nielsen 3 Kiểm soát và tự do | Đạt | Khoá là thao tác đảo được bằng Mở khoá (BR-96); từ chối ở lại danh sách (UI-STT 29(2)) | - |
| SCR-37 | WCAG 1.4.1 Không dùng màu làm tín hiệu duy nhất | Đạt | Trạng thái Bị khoá có biểu tượng và chữ | - |
| SCR-37 | WCAG 2.5.8 Vùng bấm tối thiểu | Đạt | Năm nút mỗi hàng cao 44 px, cách nhau 4 px, dưới 600 px xếp dọc trong thẻ (UI-STT 15, 18) | - |
| SCR-37 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm tài khoản; chuỗi nhiều nhân viên phải cuộn (đặc tả không nêu) | Chấp nhận, không thêm chức năng ngoài đặc tả |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21, 27-31, 33-35, 37, 51.

## h) Thông điệp mới

Không có. MSG-120 đến MSG-129, MSG-133 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273, Q-275.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Khoá và mở khoá dùng hộp xác nhận dù UC-017 không yêu cầu; quyết định trình bày theo UI-STT 37 vì khoá có hiệu lực ngay với phiên đang mở của nhân viên (BR-101).
