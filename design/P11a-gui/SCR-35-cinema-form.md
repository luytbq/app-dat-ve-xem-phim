# P11a - SCR-35 Thêm hoặc sửa cụm rạp (Create or edit cinema) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-011 1.2 (bước 3-6, luồng 1a3, 4a, 5a, 5b, *a, Dữ liệu vào 1, Dữ liệu ra 2, 3, BR-141, BR-142); P05-glossary.md 1.2; P07 UC-011; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-35 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-35 |
| UC | UC-011 |
| Bước UC | 3, 4, 5, 6; luồng 1a3, 4a, 5a, 5b, *a |
| Tác nhân | ACT-05 Quản lý chuỗi |
| Boundary AC | AC-B-ManageCinemasForm (enterCinemaInfo, showCinemaForEdit, showSavedCinema, notifyRefusal, cancelRequest) |
| DC | DC-ManageCinemasView |
| Loại màn hình | Con phụ thuộc (pop-up modal) |
| Đến từ | SCR-34 (E-58) |
| Đi tới | Đóng ngầm định về SCR-34 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| Thêm cụm rạp                                [ Đóng ]    |
|------------------------------------------------------|
| (vùng thông điệp: MSG-03, MSG-101, MSG-102)            |
| * là bắt buộc                                          |
| Tên cụm rạp *         [ CineBook Vincom Bà Triệu    ]  |
| Tỉnh, thành phố *     [ Hà Nội                      ]  |
| Địa chỉ (không bắt buộc) [ 191 Bà Triệu, Hai Bà Trưng ] |
|                     [ Huỷ yêu cầu ]  [ Lưu cụm rạp ]    |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp: "Thêm cụm rạp" hoặc "Sửa cụm rạp"; nút Đóng | Đầu hộp | UI-STT 09, 21, 50 |
| Thông điệp | MSG-03, MSG-101, MSG-102, MSG-72, MSG-73 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Ba trường nhập | Giữa hộp | UC-011 Dữ liệu vào 1 |
| Hành động | Huỷ yêu cầu, Lưu cụm rạp | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal. Thêm mới: các trường trống. Sửa: các trường mang thông tin hiện tại của cụm rạp | UC-011 bước 3, luồng 1a3, Dữ liệu ra 3 |
| 2 | Ô Tên cụm rạp | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) | UC-011 Dữ liệu vào 1 STT 1 |
| 3 | Ô Tỉnh, thành phố | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03). Giá trị dùng làm căn cứ khách lọc lịch chiếu | UC-011 Dữ liệu vào 1 STT 2; Q-204 |
| 4 | Ô Địa chỉ | Ô nhập | Rời trường | Không bắt buộc, không kiểm | UC-011 Dữ liệu vào 1 STT 3 |
| 5 | Nút Lưu cụm rạp | Nút chính | Nhấn | Kiểm các trường theo UI-STT 19, gửi (nút bận theo UI-STT 27). Tên trùng cụm rạp khác: MSG-101 ở lại hộp, giữ dữ liệu. Khi sửa mà cụm rạp đã bị người khác sửa: MSG-102 rồi đóng hộp, tải lại SCR-34. Thành công: MSG-103, đóng hộp, làm mới SCR-34 kèm cụm rạp đã lưu | UC-011 bước 4-6, luồng 4a, 5a, 5b; BR-141, BR-142; MSG-101 đến MSG-103 |
| 6 | Nút Huỷ yêu cầu, nút Đóng | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-34 và hiện MSG-57 | UC-011 luồng *a; MSG-57 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên cụm rạp | 100 | Chữ | Nhập, bắt buộc, căn trái | Không để trống; không trùng tên cụm rạp khác trong chuỗi (BR-141) | Độ dài theo Q-273 | UC-011 Dữ liệu vào 1 STT 1; BR-141 |
| Tỉnh, thành phố | 50 | Chữ | Nhập, bắt buộc, căn trái | Văn bản không để trống | Độ dài theo Q-273 | UC-011 Dữ liệu vào 1 STT 2; Q-204 |
| Địa chỉ | 255 | Chữ | Nhập, không bắt buộc, căn trái | Văn bản | Độ dài theo Q-273 | UC-011 Dữ liệu vào 1 STT 3 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Tên cụm rạp | Rời trường; nhấn Lưu | Bắt buộc --> không trùng cụm rạp khác (hệ thống) | MSG-03; MSG-101 |
| Tỉnh, thành phố | Rời trường; nhấn Lưu | Bắt buộc | MSG-03 |
| Cụm rạp đang sửa | Nhấn Lưu (hệ thống) | Chưa bị yêu cầu khác sửa kể từ lúc hiển thị | MSG-102 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-35 | Baymard: một cột, nhãn trên ô, đánh dấu bắt buộc và tuỳ chọn, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20; chỉ ba trường đúng đặc tả | - |
| SCR-35 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-101 nêu tên đã dùng và việc cần làm | - |
| SCR-35 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21, 50) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35.

## h) Thông điệp mới

Không có. MSG-101 đến MSG-103 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
