# P11a - SCR-01 Đăng nhập (Log in) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 1.0; screen-list.md 1.0; screen-transition.md 1.0; P04 UC-005 1.8 (luồng 5a, Dữ liệu vào 2), UC-008, UC-009, UC-013, UC-014 (tiền điều kiện); P06 NFR-01, NFR-02, NFR-03; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-01 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-01 |
| UC | Tiền điều kiện của UC-005, UC-008, UC-009, UC-013, UC-014; luồng 5a của UC-005 |
| Bước UC | UC-005 luồng 5a1, 5a2; tiền điều kiện các UC còn lại |
| Tác nhân | ACT-01 Khách, ACT-02 Nhân viên quầy, ACT-03 Nhân viên soát vé, ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-BookTicketsForm (requestLogin, provideCredentials) cho khách; nhân viên chưa có boundary (xem Đề xuất sửa) |
| DC | Chưa có (xem Đề xuất sửa P10) |
| Loại màn hình | Độc lập; mở dạng pop-up Con phụ thuộc từ SCR-04 |
| Đến từ | START-ACT-01, START-ACT-02, START-ACT-03, START-ACT-04 (E-02 đến E-05); SCR-02 (E-12); SCR-04 (E-14, pop-up) |
| Đi tới | SCR-02 (E-06), SCR-09 (E-07), SCR-16 (E-08), SCR-17 (E-09); pop-up đóng ngầm định về SCR-04 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook                                  [ Đăng nhập ] |
|------------------------------------------------------|
| Đăng nhập                                              |
| [i] Vui lòng đăng nhập để tiếp tục đặt vé. ...         |
| (vùng thông điệp: MSG-01 hoặc MSG-02)                  |
|                                                        |
| Email hoặc số điện thoại *                             |
| [ an.nguyen@example.com                            ]   |
| Mật khẩu *                                             |
| [ ************************     ] [ Hiện mật khẩu ]      |
|                                                        |
|                       [ Huỷ ]       [ Đăng nhập ]       |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, mục Đăng nhập (đang chọn) | Trên cùng | Menu theo UI-STT 22 |
| Tiêu đề | h1 "Đăng nhập" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-01 (khi mở từ SCR-04), MSG-02, lỗi trường | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Hai ô nhập, nút Hiện mật khẩu | Giữa | Form một cột, UI-STT 16 |
| Hành động | Nút Huỷ (chỉ khi mở dạng pop-up), nút chính Đăng nhập | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiển thị biểu mẫu. Mở từ SCR-04: dạng pop-up modal, hiện MSG-01, không làm mất các ghế đang chọn ở SCR-04. Mở từ START hoặc SCR-02: dạng trang, không có nút Huỷ | UC-005 luồng 5a1; MSG-01 |
| 2 | Ô Email hoặc số điện thoại | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03). Giá trị có ký tự @ thì kiểm định dạng email (MSG-04), ngược lại kiểm số điện thoại 10 chữ số bắt đầu bằng 0 (MSG-05) | UC-005 Dữ liệu vào 2 STT 1; BR-81, BR-82 |
| 3 | Ô Mật khẩu | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) | UC-005 Dữ liệu vào 2 STT 2 |
| 4 | Nút Hiện mật khẩu | Nút | Nhấn | Bật tắt hiển thị ký tự trong ô mật khẩu, nhãn đổi giữa "Hiện mật khẩu" và "Ẩn mật khẩu" | UI-STT 16; WCAG 3.3.8 |
| 5 | Nút Đăng nhập | Nút chính | Nhấn | Kiểm lại hai ô theo thứ tự UI-STT 19, rồi gửi lên hệ thống (nút bận theo UI-STT 27). Đúng, dạng trang: mở màn hình điều hướng theo vai trò (SCR-02 khách, SCR-09 nhân viên quầy, SCR-16 nhân viên soát vé, SCR-17 quản lý cụm rạp). Đúng, dạng pop-up: đóng pop-up, SCR-04 tự gửi lại việc xác nhận chọn ghế với các ghế đã chọn (quay lại bước 5). Sai: MSG-02, giữ định danh, xoá mật khẩu | UC-005 luồng 5a2; NFR-01, NFR-02, NFR-03; MSG-02 |
| 6 | Nút Huỷ | Nút phụ (chỉ pop-up) | Nhấn | Đóng pop-up, về SCR-04, các ghế đang chọn vẫn chọn, chưa giữ ghế | UC-005 luồng 5a1, BR-03 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email hoặc số điện thoại | 254 | Chữ | Nhập, bắt buộc, căn trái | Email theo định dạng chuẩn (BR-81) hoặc số điện thoại Việt Nam 10 chữ số bắt đầu bằng 0 (BR-82); trùng định danh một tài khoản (kiểm ở hệ thống) | Độ dài 254 là Thiết kế: độ dài tối đa địa chỉ email theo RFC 5321. Định danh của nhân viên: Q-122 | UC-005 Dữ liệu vào 2 STT 1; BR-81, BR-82; Q-122 |
| Mật khẩu | Q-124 | Chữ | Nhập, bắt buộc, ẩn ký tự, căn trái | Khớp mật khẩu của tài khoản (kiểm ở hệ thống) | Không hiển thị mật khẩu khi chưa bấm Hiện mật khẩu | UC-005 Dữ liệu vào 2 STT 2; Q-124 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Email hoặc số điện thoại | Rời trường; nhấn Đăng nhập | Bắt buộc --> định dạng email hoặc số điện thoại | MSG-03; MSG-04; MSG-05 |
| Mật khẩu | Rời trường; nhấn Đăng nhập | Bắt buộc | MSG-03 |
| Cặp định danh và mật khẩu | Nhấn Đăng nhập (hệ thống) | Khớp tài khoản | MSG-02 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-01 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-02 nêu việc cần làm và không cho biết trường nào sai | - |
| SCR-01 | WCAG 3.3.7 Không bắt nhập lại | Đạt | Dạng pop-up giữ nguyên ghế đã chọn và tự gửi lại việc xác nhận | - |
| SCR-01 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Cho phép trình duyệt điền tự động, có Hiện mật khẩu (UI-STT 46) | - |
| SCR-01 | Baymard: nhãn trên ô nhập, giữ dữ liệu | Đạt | UI-STT 16, 20 | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 19-21, 27-28, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-122, Q-123, Q-124.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F3, F4 (PKG-05) | Chưa có View cho màn hình đăng nhập dùng chung | Đã ghi ở ui-standards.md: thêm DC-LoginView |
| P08 | F3 | Chưa có boundary đăng nhập cho nhân viên (ACT-02, ACT-03, ACT-04); AC-B-BookTicketsForm chỉ có requestLogin, provideCredentials cho khách | Thêm boundary hoặc trách nhiệm đăng nhập dùng chung cho mọi vai trò |

## Vấn đề còn mở

Định danh của nhân viên và độ dài mật khẩu chưa có nguồn (Q-122, Q-124).
