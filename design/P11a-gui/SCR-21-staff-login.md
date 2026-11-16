# P11a - SCR-21 Đăng nhập nhân viên (Staff login) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P02-usecases.md 1.9; P04 UC-017 1.2 (Dữ liệu vào 1 STT 1, BR-95, BR-97, BR-101), tiền điều kiện của UC-005, UC-008, UC-009, UC-010 đến UC-017; P06 NFR-02, NFR-03, NFR-12; P08-analysis-model.md 2.0 (F3); P09-architecture.md 2.0 (F7.11, Q-267); P10-design-elements.md 2.0 (F3, F4, Q-271). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-21 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-21 |
| UC | Tiền điều kiện của UC-005 và UC-008 (kênh quầy), UC-009, UC-010 đến UC-017 |
| Bước UC | Tiền điều kiện các use case của nhân viên và quản trị viên (REQ-102, REQ-104) |
| Tác nhân | ACT-02 Nhân viên quầy, ACT-03 Nhân viên soát vé, ACT-04 Quản lý cụm rạp, ACT-05 Quản lý chuỗi, ACT-06 Quản trị viên |
| Boundary AC | Chưa có (đăng nhập không là use case, hồ sơ dự án mục 4) |
| DC | DC-LoginView, DC-SessionStore (PKG-31) |
| Loại màn hình | Độc lập |
| Đến từ | START-ACT-02 đến START-ACT-06 (E-03, E-04, E-05, E-35, E-36); SCR-01 (E-39); mọi màn hình nhân viên khi máy chủ trả "phiên không còn hiệu lực" (UI-STT 48) |
| Đi tới | SCR-09 (E-07), SCR-16 (E-08), SCR-17 (E-09), SCR-31 (E-37), SCR-37 (E-38), SCR-01 (E-40) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook                                               |
|------------------------------------------------------|
| Đăng nhập nhân viên                                    |
| [!] Phiên làm việc của bạn không còn hiệu lực. ...     |
| (vùng thông điệp: MSG-85, MSG-86, MSG-87)              |
| * là bắt buộc                                          |
| Email *                                                |
| [ quan.tran@cinebook.example                       ]   |
| Mật khẩu *                                             |
| [ ************************     ] [ Hiện mật khẩu ]      |
|                                        [ Đăng nhập ]   |
| Bạn là khách? Đăng nhập khách                          |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng CineBook, không có mục Trang chủ vì chưa biết vai trò | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Đăng nhập nhân viên" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-85 khi bị đưa về do phiên không còn hiệu lực; MSG-86, MSG-87; lỗi trường | Dưới tiêu đề | UI-STT 08, 48 |
| Nội dung | Hai ô nhập, nút Hiện mật khẩu, liên kết Đăng nhập khách | Giữa | Form một cột, UI-STT 16 |
| Hành động | Nút chính Đăng nhập | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiển thị biểu mẫu. Mở do phiên không còn hiệu lực thì hiện MSG-85 trong vùng thông điệp; dữ liệu chưa lưu ở màn hình trước không còn | BR-101; P09 F7.11; UI-STT 48; MSG-85 |
| 2 | Ô Email | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03), rồi định dạng email (MSG-04) | UC-017 Dữ liệu vào 1 STT 1; NFR-02 |
| 3 | Ô Mật khẩu | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03). Không kiểm độ dài tối thiểu khi đăng nhập | NFR-02; Q-274 |
| 4 | Nút Hiện mật khẩu | Nút | Nhấn | Bật tắt hiển thị ký tự trong ô mật khẩu, nhãn đổi giữa "Hiện mật khẩu" và "Ẩn mật khẩu" | UI-STT 16; WCAG 3.3.8 |
| 5 | Nút Đăng nhập | Nút chính | Nhấn | Kiểm lại hai ô theo UI-STT 19, rồi gửi lên hệ thống (nút bận theo UI-STT 27). Đúng: mở màn hình theo vai trò (nhân viên quầy SCR-09; nhân viên soát vé SCR-16; quản lý cụm rạp SCR-17; quản lý chuỗi SCR-31; quản trị viên SCR-37). Sai email hoặc mật khẩu: MSG-86, giữ email, xoá mật khẩu. Đúng email và mật khẩu nhưng tài khoản bị khoá: MSG-87, không có phiên | NFR-02, NFR-03; BR-97; MSG-86, MSG-87; Q-276 |
| 6 | Liên kết Đăng nhập khách | Liên kết | Nhấn | Mở SCR-01 dạng trang | P09 Q-267 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email | 254 | Chữ | Nhập, bắt buộc, căn trái | Email theo định dạng chuẩn; khớp một tài khoản nhân viên hoặc tài khoản quản trị viên (kiểm ở hệ thống) | Độ dài 254 là Thiết kế: độ dài tối đa địa chỉ email theo RFC 5321. Quản trị viên đăng nhập cùng màn hình (Q-271) | UC-017 Dữ liệu vào 1 STT 1; NFR-02, NFR-03 |
| Mật khẩu | 64 | Chữ | Nhập, bắt buộc, ẩn ký tự, căn trái | Khớp mật khẩu của tài khoản (kiểm ở hệ thống) | Thiết kế: tối đa 64 ký tự như SCR-01 (Q-124) | UC-017 Dữ liệu vào 1 STT 3; Q-124 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Email | Rời trường; nhấn Đăng nhập | Bắt buộc --> định dạng email | MSG-03; MSG-04 |
| Mật khẩu | Rời trường; nhấn Đăng nhập | Bắt buộc | MSG-03 |
| Cặp email và mật khẩu | Nhấn Đăng nhập (hệ thống) | Khớp tài khoản --> tài khoản không bị khoá | MSG-86; MSG-87 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-21 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-86 nêu việc cần làm và không cho biết trường nào sai; MSG-87 nêu việc cần làm khi bị khoá | - |
| SCR-21 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-85 giải thích vì sao người dùng bị đưa về màn hình đăng nhập (UI-STT 48) | - |
| SCR-21 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Cho phép trình duyệt điền tự động, có Hiện mật khẩu (UI-STT 46) | - |
| SCR-21 | Baymard: nhãn trên ô nhập, giữ dữ liệu | Đạt | UI-STT 16, 20 | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 19-21, 27-28, 33-35.

## h) Thông điệp mới

Không có. MSG-85, MSG-86, MSG-87 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-122, Q-124, Q-274, Q-276.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
