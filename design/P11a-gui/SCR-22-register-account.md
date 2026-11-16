# P11a - SCR-22 Đăng ký tài khoản (Register account) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-001 1.2 (bước 1-8, luồng 4a-7a, *a, Dữ liệu vào 1, BR-81, BR-82, BR-98, BR-99); P05-glossary.md 1.2; P07 UC-001; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-22 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-22 |
| UC | UC-001 |
| Bước UC | 1, 2, 3, 4, 5, 6, 7, 8; luồng 4a, 5a, 6a, 7a, *a |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-RegisterAccountForm (requestRegistration, showRegistrationRequest, submitRegistrationData, rejectRegistration, showRegistrationSuccess, cancelRegistration, showRegistrationCancelled) |
| DC | DC-RegisterAccountView, DC-RegisterAccountStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-02 (E-41) |
| Đi tới | SCR-01 (E-42, đăng ký thành công); SCR-02 (E-43, huỷ yêu cầu) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                       [ Đăng nhập ] |
|------------------------------------------------------|
| Đăng ký tài khoản                                      |
| (vùng thông điệp: MSG-72, MSG-73)                      |
| * là bắt buộc                                          |
| Email *                                                |
| [ khach.nguyen@example.com                         ]   |
| Số điện thoại *                                        |
|   10 chữ số, bắt đầu bằng 0. Ví dụ: 0912345678         |
| [ 0912345678                                       ]   |
| Mật khẩu *                                             |
|   Ít nhất 8 ký tự                                      |
| [ ************************     ] [ Hiện mật khẩu ]      |
|                       [ Huỷ ]       [ Đăng ký ]         |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng nhập | Trên cùng | UI-STT 22; không mục nào được đánh dấu (UI-STT 23) |
| Tiêu đề | h1 "Đăng ký tài khoản" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-72, MSG-73; lỗi tại trường | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Ba ô nhập, nút Hiện mật khẩu, gợi ý định dạng dưới nhãn | Giữa | Form một cột, UI-STT 16 |
| Hành động | Nút phụ Huỷ, nút chính Đăng ký | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện biểu mẫu ba trường để trống, yêu cầu khách cung cấp email, số điện thoại và mật khẩu | UC-001 bước 1, 2 |
| 2 | Ô Email | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03), rồi định dạng email (MSG-04) | UC-001 Dữ liệu vào 1 STT 1; BR-81 |
| 3 | Ô Số điện thoại | Ô nhập | Rời trường | Bỏ khoảng trắng, kiểm bắt buộc (MSG-03), rồi 10 chữ số bắt đầu bằng 0 (MSG-05) | UC-001 Dữ liệu vào 1 STT 2; BR-82 |
| 4 | Ô Mật khẩu | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03), rồi tối thiểu 8 ký tự (MSG-89) | UC-001 Dữ liệu vào 1 STT 3; BR-99 |
| 5 | Nút Hiện mật khẩu | Nút | Nhấn | Bật tắt hiển thị ký tự trong ô mật khẩu | UI-STT 16 |
| 6 | Nút Đăng ký | Nút chính | Nhấn | Kiểm lại ba ô theo thứ tự email, số điện thoại, mật khẩu (UI-STT 19), gửi lên hệ thống (nút bận theo UI-STT 27). Hệ thống từ chối vì email hoặc số điện thoại đã thuộc tài khoản khách khác: MSG-90, ở lại màn hình, giữ email và số điện thoại. Thành công: mở SCR-01 và hiện MSG-88; khách chưa có phiên nên phải đăng nhập | UC-001 bước 3-8, luồng 4a, 5a, 6a, 7a; BR-98; MSG-88, MSG-90 |
| 7 | Nút Huỷ | Nút phụ | Nhấn | Huỷ yêu cầu, không tạo tài khoản; về SCR-02 và hiện MSG-57 | UC-001 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email | 254 | Chữ | Nhập, bắt buộc, căn trái | Định dạng email chuẩn (BR-81); duy nhất giữa các tài khoản khách (BR-98, kiểm ở hệ thống) | Thiết kế: 254 là độ dài tối đa địa chỉ email theo RFC 5321 | UC-001 Dữ liệu vào 1 STT 1; BR-81, BR-98 |
| Số điện thoại | 10 | Chữ | Nhập, bắt buộc, căn trái | Số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0 (BR-82); duy nhất giữa các tài khoản khách (BR-98, kiểm ở hệ thống) | Khoảng trắng người dùng gõ bị bỏ trước khi kiểm (Baymard); độ dài theo BR-82 | UC-001 Dữ liệu vào 1 STT 2; BR-82, BR-98 |
| Mật khẩu | 64 | Chữ | Nhập, bắt buộc, ẩn ký tự, căn trái | Ít nhất 8 ký tự, không quy định thêm về độ phức tạp (BR-99) | Thiết kế: tối đa 64 ký tự như SCR-01 (Q-124) | UC-001 Dữ liệu vào 1 STT 3; BR-99; Q-124 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Email | Rời trường; nhấn Đăng ký | Bắt buộc --> định dạng email | MSG-03; MSG-04 |
| Số điện thoại | Rời trường; nhấn Đăng ký | Bắt buộc --> 10 chữ số bắt đầu bằng 0 | MSG-03; MSG-05 |
| Mật khẩu | Rời trường; nhấn Đăng ký | Bắt buộc --> tối thiểu 8 ký tự | MSG-03; MSG-89 |
| Email, số điện thoại | Nhấn Đăng ký (hệ thống) | Chưa thuộc tài khoản khách nào khác | MSG-90 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-22 | Baymard: nhãn trên ô nhập, đánh dấu bắt buộc, gợi ý định dạng | Đạt | UI-STT 16, 32; gợi ý dưới nhãn của số điện thoại và mật khẩu | - |
| SCR-22 | Baymard: chấp nhận nhiều định dạng nhập | Đạt | Khoảng trắng trong số điện thoại được bỏ trước khi kiểm | - |
| SCR-22 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-04, MSG-05, MSG-89 nêu quy tắc và ví dụ; MSG-90 nêu việc cần làm | - |
| SCR-22 | Nielsen 5 Ngăn lỗi | Đạt | Kiểm ngay khi rời trường (UI-STT 19), gợi ý định dạng trước khi nhập | - |
| SCR-22 | WCAG 3.3.7 Không bắt nhập lại | Đạt | MSG-90 giữ nguyên email, số điện thoại; mật khẩu phải nhập lại theo UI-STT 20 | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 19-21, 27-28, 33-35.

## h) Thông điệp mới

Không có. MSG-88, MSG-89, MSG-90 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-124, Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

MSG-90 không nói rõ email hay số điện thoại bị trùng vì BR-98 nêu một quy tắc chung cho cả hai; thông điệp nêu cả hai để khách tự đối chiếu.
