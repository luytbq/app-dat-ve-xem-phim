# P11a - SCR-01 Đăng nhập khách (Log in as customer) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Chỉ còn đăng nhập của khách; nhân viên và quản trị viên đăng nhập ở SCR-21 (hai điểm đăng nhập, Q-267); thêm hiển thị MSG-88 sau khi đăng ký, MSG-85 khi phiên không còn hiệu lực, liên kết tới SCR-22 và SCR-21; DC là DC-LoginView (P10 2.0) |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-005 1.15 (luồng 5a, Dữ liệu vào 2), UC-001 1.2 (bước 8), UC-007 1.2, UC-008 1.10 (tiền điều kiện); P06 NFR-01, NFR-03; P08-analysis-model.md 2.0 (F3); P09-architecture.md 2.0 (F7.11, Q-267); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-01 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-01 |
| UC | Tiền điều kiện của UC-007 và UC-008 (kênh khách); luồng 5a của UC-005; sau UC-001 |
| Bước UC | UC-005 luồng 5a1, 5a2; tiền điều kiện UC-007, UC-008; UC-001 bước 8 (khách đăng nhập riêng) |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BookTicketsForm (requestLogin, provideCredentials); đăng nhập không là use case nên không có boundary riêng |
| DC | DC-LoginView, DC-SessionStore (PKG-31) |
| Loại màn hình | Độc lập; mở dạng pop-up Con phụ thuộc từ SCR-04 |
| Đến từ | START-ACT-01 (E-02); SCR-02 (E-12, E-49); SCR-04 (E-14, pop-up); SCR-21 (E-40); SCR-22 (E-42); mọi màn hình khách khi máy chủ trả "phiên không còn hiệu lực" (UI-STT 48) |
| Đi tới | SCR-02 (E-06); SCR-21 (E-39); SCR-22 (E-63); pop-up đóng ngầm định về SCR-04 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook                                  [ Đăng nhập ] |
|------------------------------------------------------|
| Đăng nhập                                              |
| [i] Vui lòng đăng nhập để tiếp tục đặt vé. ...         |
| (vùng thông điệp: MSG-01, MSG-02, MSG-85, MSG-88)      |
| * là bắt buộc                                          |
| Email hoặc số điện thoại *                             |
| [ an.nguyen@example.com                            ]   |
| Mật khẩu *                                             |
| [ ************************     ] [ Hiện mật khẩu ]      |
|                       [ Huỷ ]       [ Đăng nhập ]       |
| Chưa có tài khoản? Đăng ký tài khoản                   |
| Bạn là nhân viên? Đăng nhập dành cho nhân viên         |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, mục Đăng nhập (đang chọn) | Trên cùng | Menu theo UI-STT 22 |
| Tiêu đề | h1 "Đăng nhập" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-01 (khi mở từ SCR-04), MSG-02, MSG-85 (khi phiên không còn hiệu lực), MSG-88 (sau khi đăng ký), lỗi trường | Dưới tiêu đề | UI-STT 08, 48 |
| Nội dung | Hai ô nhập, nút Hiện mật khẩu | Giữa | Form một cột, UI-STT 16 |
| Hành động | Nút Huỷ (chỉ khi mở dạng pop-up), nút chính Đăng nhập | Cuối, căn phải | UI-STT 06 |
| Liên kết | Đăng ký tài khoản, Đăng nhập dành cho nhân viên (chỉ dạng trang) | Dưới hành động | UI-STT 46 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiển thị biểu mẫu. Mở từ SCR-04: dạng pop-up modal, hiện MSG-01, không làm mất các ghế đang chọn ở SCR-04, không có hai liên kết. Mở từ SCR-22: dạng trang, hiện MSG-88, tiêu điểm vào ô định danh. Mở do phiên không còn hiệu lực: dạng trang, hiện MSG-85. Mở từ START hoặc SCR-02: dạng trang, không có nút Huỷ | UC-005 luồng 5a1; UC-001 bước 8; MSG-01, MSG-85, MSG-88; UI-STT 48 |
| 2 | Ô Email hoặc số điện thoại | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03). Giá trị có ký tự @ thì kiểm định dạng email (MSG-04), ngược lại kiểm số điện thoại 10 chữ số bắt đầu bằng 0 (MSG-05) | UC-005 Dữ liệu vào 2 STT 1; BR-81, BR-82 |
| 3 | Ô Mật khẩu | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) | UC-005 Dữ liệu vào 2 STT 2 |
| 4 | Nút Hiện mật khẩu | Nút | Nhấn | Bật tắt hiển thị ký tự trong ô mật khẩu, nhãn đổi giữa "Hiện mật khẩu" và "Ẩn mật khẩu" | UI-STT 16; WCAG 3.3.8 |
| 5 | Nút Đăng nhập | Nút chính | Nhấn | Kiểm lại hai ô theo thứ tự UI-STT 19, rồi gửi lên hệ thống (nút bận theo UI-STT 27). Đúng, dạng trang: mở SCR-02. Đúng, dạng pop-up: đóng pop-up, SCR-04 tự gửi lại việc xác nhận chọn ghế với các ghế đã chọn (quay lại bước 5). Sai: MSG-02, giữ định danh, xoá mật khẩu | UC-005 luồng 5a2; NFR-01; MSG-02 |
| 6 | Nút Huỷ | Nút phụ (chỉ pop-up) | Nhấn | Đóng pop-up, về SCR-04, các ghế đang chọn vẫn chọn, chưa giữ ghế | UC-005 luồng 5a1, BR-03 |
| 7 | Liên kết Đăng ký tài khoản | Liên kết (chỉ dạng trang) | Nhấn | Mở SCR-22 | UC-001 bước 1; UI-STT 46 |
| 8 | Liên kết Đăng nhập dành cho nhân viên | Liên kết (chỉ dạng trang) | Nhấn | Mở SCR-21 | P09 Q-267; UI-STT 46 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Email hoặc số điện thoại | 254 | Chữ | Nhập, bắt buộc, căn trái | Email theo định dạng chuẩn (BR-81) hoặc số điện thoại Việt Nam 10 chữ số bắt đầu bằng 0 (BR-82); trùng định danh một tài khoản khách (kiểm ở hệ thống) | Độ dài 254 là Thiết kế: độ dài tối đa địa chỉ email theo RFC 5321 | UC-005 Dữ liệu vào 2 STT 1; BR-81, BR-82 |
| Mật khẩu | 64 | Chữ | Nhập, bắt buộc, ẩn ký tự, căn trái | Khớp mật khẩu của tài khoản (kiểm ở hệ thống) | Không hiển thị mật khẩu khi chưa bấm Hiện mật khẩu. Thiết kế: tối đa 64 ký tự (Q-124); mật khẩu tối thiểu 8 ký tự (BR-99) chỉ kiểm khi đăng ký, không kiểm khi đăng nhập | UC-005 Dữ liệu vào 2 STT 2; Q-124; BR-99 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Email hoặc số điện thoại | Rời trường; nhấn Đăng nhập | Bắt buộc --> định dạng email hoặc số điện thoại | MSG-03; MSG-04; MSG-05 |
| Mật khẩu | Rời trường; nhấn Đăng nhập | Bắt buộc | MSG-03 |
| Cặp định danh và mật khẩu | Nhấn Đăng nhập (hệ thống) | Khớp tài khoản khách | MSG-02 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-01 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-02 nêu việc cần làm và không cho biết trường nào sai | - |
| SCR-01 | WCAG 3.3.7 Không bắt nhập lại | Đạt | Dạng pop-up giữ nguyên ghế đã chọn và tự gửi lại việc xác nhận | - |
| SCR-01 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Cho phép trình duyệt điền tự động, có Hiện mật khẩu (UI-STT 46) | - |
| SCR-01 | Baymard: nhãn trên ô nhập, giữ dữ liệu | Đạt | UI-STT 16, 20 | - |
| SCR-01 | Nielsen 7 Linh hoạt và hiệu quả | Đạt | Liên kết tới đăng ký và đăng nhập nhân viên giúp khách và nhân viên vào đúng điểm đăng nhập mà không phải quay lại màn hình trước | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 19-21, 27-28, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-122, Q-123, Q-124.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
