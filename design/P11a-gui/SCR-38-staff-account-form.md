# P11a - SCR-38 Tạo hoặc cập nhật tài khoản nhân viên (Create or update staff account) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-017 1.2 (bước 3-6, luồng 1a3, 4a, 4b, 4c, 4d, 5a, 5b, *a, Dữ liệu vào 1, Dữ liệu ra 1, 2, BR-78, BR-79, BR-95, BR-100, BR-101, BR-102); P05 GL-34; P07 UC-017; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-38 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-38 |
| UC | UC-017 |
| Bước UC | 3, 4, 5, 6; luồng 1a3, 4a, 4b, 4c, 4d, 5a, 5b, *a |
| Tác nhân | ACT-06 Quản trị viên |
| Boundary AC | AC-B-ManageStaffAccountsForm (showStaffAccountChoices, submitStaffData, submitRoleAndCinema, showStaffForUpdate, rejectStaffAccount, showSavedStaffAccount, cancelStaffRequest, showStaffRequestCancelled) |
| DC | DC-ManageStaffAccountsView |
| Loại màn hình | Con phụ thuộc (pop-up modal) |
| Đến từ | SCR-37 (E-60) |
| Đi tới | Đóng ngầm định về SCR-37 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| Tạo tài khoản nhân viên                     [ Đóng ]    |
|------------------------------------------------------|
| (vùng thông điệp: MSG-03, MSG-04, MSG-118, MSG-119, MSG-120) |
| * là bắt buộc                                          |
| Email *               [ quan.tran@cinebook.example  ]  |
| Họ tên *              [ Trần Văn Quân               ]  |
| Mật khẩu ban đầu *    [ ***************  ] [ Hiện mật khẩu ] |
|   Giao mật khẩu cho nhân viên ngoài hệ thống            |
| Vai trò *             [ Nhân viên soát vé v ]          |
| Cụm rạp *             [ CineBook Cầu Giấy v ]          |
|   Quản lý chuỗi không thuộc cụm rạp nào                 |
|                  [ Huỷ yêu cầu ]  [ Lưu tài khoản ]     |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp: "Tạo tài khoản nhân viên" hoặc "Đổi vai trò, cụm rạp"; nút Đóng | Đầu hộp | UI-STT 09, 21, 50 |
| Thông điệp | MSG-03, MSG-04, MSG-118 đến MSG-120, MSG-72, MSG-73 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Tạo mới: năm trường. Cập nhật: email, họ tên chỉ hiển thị; chỉ vai trò và cụm rạp nhập được | Giữa hộp | UC-017 Dữ liệu vào 1 |
| Hành động | Huỷ yêu cầu, Lưu tài khoản | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal cùng danh sách cụm rạp của chuỗi và bốn vai trò để chọn. Tạo mới: các trường trống. Cập nhật: email và họ tên hiện tại chỉ để xem, vai trò và cụm rạp mang giá trị hiện tại | UC-017 bước 2, luồng 1a3, Dữ liệu ra 1, 2 |
| 2 | Ô Email | Ô nhập | Rời trường | Chỉ ở chế độ tạo mới. Kiểm bắt buộc (MSG-03), rồi định dạng email (MSG-04). Không sửa được sau khi tạo | UC-017 Dữ liệu vào 1 STT 1; Q-163, Q-162 |
| 3 | Ô Họ tên | Ô nhập | Rời trường | Chỉ ở chế độ tạo mới. Kiểm bắt buộc, không rỗng (MSG-03) | UC-017 Dữ liệu vào 1 STT 2; Q-163 |
| 4 | Ô Mật khẩu ban đầu | Ô nhập | Rời trường | Chỉ ở chế độ tạo mới. Kiểm bắt buộc (MSG-03); không có điều kiện độ dài khác | UC-017 Dữ liệu vào 1 STT 3; Q-161, Q-274 |
| 5 | Nút Hiện mật khẩu | Nút | Nhấn | Bật tắt hiển thị ký tự trong ô mật khẩu | UI-STT 16 |
| 6 | Danh sách Vai trò | Danh sách chọn | Chọn | Chọn đúng một trong Nhân viên quầy, Nhân viên soát vé, Quản lý cụm rạp, Quản lý chuỗi. Chọn Quản lý chuỗi: danh sách Cụm rạp bị vô hiệu và bỏ giá trị | UC-017 Dữ liệu vào 1 STT 4; BR-78, BR-79 |
| 7 | Danh sách Cụm rạp | Danh sách chọn | Chọn | Chọn đúng một cụm rạp của chuỗi; bắt buộc khi vai trò khác Quản lý chuỗi | UC-017 Dữ liệu vào 1 STT 5; BR-78 |
| 8 | Nút Lưu tài khoản | Nút chính | Nhấn | Kiểm theo thứ tự email, họ tên, vai trò, cụm rạp (UI-STT 19), gửi (nút bận theo UI-STT 27). Hệ thống từ chối ở lại hộp, giữ dữ liệu: vai trò và cụm rạp không phù hợp MSG-118; email đã thuộc tài khoản nhân viên khác MSG-119. Khi cập nhật mà tài khoản vừa bị thay đổi: MSG-120 rồi đóng hộp, tải lại SCR-37. Thành công: MSG-121, đóng hộp, làm mới SCR-37 kèm tài khoản đã lưu. Cập nhật vai trò hoặc cụm rạp có hiệu lực ngay với phiên đang mở của nhân viên; lần giữ ghế đang chạy giữ nguyên | UC-017 bước 4-6, luồng 4a-4d, 5a, 5b; BR-78, BR-79, BR-95, BR-100, BR-101, BR-102; MSG-118 đến MSG-121 |
| 9 | Nút Huỷ yêu cầu, nút Đóng | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-37 và hiện MSG-57 | UC-017 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email | 254 | Chữ | Nhập (tạo mới), bắt buộc, căn trái; Hiển thị (cập nhật) | Định dạng email chuẩn (Q-163); duy nhất giữa tài khoản nhân viên (BR-95); không sửa sau khi tạo | Thiết kế: 254 theo RFC 5321 | UC-017 Dữ liệu vào 1 STT 1; BR-95; Q-162, Q-163 |
| Họ tên | 100 | Chữ | Nhập (tạo mới), bắt buộc, căn trái; Hiển thị (cập nhật) | Không rỗng (Q-163) | Độ dài theo Q-273 | UC-017 Dữ liệu vào 1 STT 2; Q-163 |
| Mật khẩu ban đầu | 64 | Chữ | Nhập (tạo mới), bắt buộc, ẩn ký tự, căn trái | Không có điều kiện riêng ngoài bắt buộc nhập | Thiết kế: tối đa 64 ký tự như SCR-01 (Q-124); quản trị viên giao cho nhân viên ngoài hệ thống (Q-161) | UC-017 Dữ liệu vào 1 STT 3; Q-161, Q-274 |
| Vai trò | - | Lựa chọn | Chọn, bắt buộc | Đúng một trong bốn vai trò (BR-79) | - | UC-017 Dữ liệu vào 1 STT 4; BR-79 |
| Cụm rạp | - | Lựa chọn | Chọn, bắt buộc khi vai trò khác Quản lý chuỗi; vô hiệu khi Quản lý chuỗi | Đúng một cụm rạp của chuỗi; Quản lý chuỗi không có cụm rạp (BR-78) | - | UC-017 Dữ liệu vào 1 STT 5; BR-78 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Email | Rời trường; nhấn Lưu | Bắt buộc --> định dạng email --> chưa thuộc tài khoản nhân viên khác (hệ thống) | MSG-03; MSG-04; MSG-119 |
| Họ tên | Rời trường; nhấn Lưu | Bắt buộc | MSG-03 |
| Mật khẩu ban đầu | Rời trường; nhấn Lưu | Bắt buộc | MSG-03 |
| Vai trò | Nhấn Lưu | Bắt buộc có giá trị | MSG-03 |
| Cụm rạp | Nhấn Lưu | Phù hợp vai trò (hệ thống): bắt buộc với ba vai trò đầu, không có với Quản lý chuỗi | MSG-03; MSG-118 |
| Tài khoản đang cập nhật | Nhấn Lưu (hệ thống) | Chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị | MSG-120 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-38 | Nielsen 5 Ngăn lỗi | Đạt | Danh sách chọn cho vai trò và cụm rạp; cụm rạp bị vô hiệu với Quản lý chuỗi nên không phát sinh MSG-118 từ giao diện | - |
| SCR-38 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Ô mật khẩu có Hiện mật khẩu, không chặn dán (UI-STT 16, 46) | - |
| SCR-38 | Baymard: một cột, nhãn trên ô, đánh dấu bắt buộc, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-38 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21, 50) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35.

## h) Thông điệp mới

Không có. MSG-118 đến MSG-121 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273, Q-274.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
