# P11a - SCR-24 Thông tin phim (Movie details) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-003 1.1 (bước 4, 5, Dữ liệu ra 2, Mục 8); P05 GL-37; P07 UC-003; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-24 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-24 |
| UC | UC-003 |
| Bước UC | 4, 5 |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BrowseMoviesForm (selectMovie, showMovieDetails) |
| DC | DC-BrowseMoviesView, DC-BrowseMoviesStore |
| Loại màn hình | Phụ thuộc có dữ liệu (phim đã chọn) |
| Đến từ | SCR-23 (E-45) |
| Đi tới | SCR-23 (E-46) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| CineBook   Trang chủ                       [ Đăng nhập ] |
|------------------------------------------------------|
| Thông tin phim                                         |
| (vùng thông điệp: MSG-72, MSG-73)                      |
| Phim A                                                 |
| Thể loại         Hành động                             |
| Thời lượng       125 phút                              |
| Độ tuổi được xem T13                                   |
| Mô tả            Một đội đặc nhiệm phải ngăn chặn      |
|                  một cuộc tấn công.                    |
| Trailer          [ Xem trailer ] (mở tab mới)          |
|                          [ Quay lại danh sách phim ]    |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng nhập khi chưa có phiên | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Thông tin phim", tên phim ở dòng đầu nội dung | Dưới đầu trang | UI-STT 09 |
| Nội dung | Sáu thông tin của phim theo cặp nhãn và giá trị | Giữa | UC-003 Dữ liệu ra 2 |
| Hành động | Nút phụ Quay lại danh sách phim | Cuối, căn phải | UI-STT 06, 51 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer của phim đã chọn. Giá trị rỗng hiện "Chưa có". Không đổi dữ liệu | UC-003 bước 5, Dữ liệu ra 2 |
| 2 | Liên kết Xem trailer | Liên kết | Nhấn | Mở đường dẫn trailer trong tab mới (rel noopener). Phim chưa có trailer: hiện chữ "Chưa có", không có liên kết | UC-003 Dữ liệu ra 2 STT 6, Mục 8 (cách xem trailer thuộc thiết kế); UC-010 Dữ liệu vào 1 STT 6 |
| 3 | Nút Quay lại danh sách phim | Nút phụ | Nhấn | Mở SCR-23 | UI-STT 51 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên | - | Chữ | Hiển thị | Nguyên văn tên phim | - | UC-003 Dữ liệu ra 2 STT 1 |
| Thể loại | - | Chữ | Hiển thị | Văn bản; rỗng hiện "Chưa có" | - | UC-003 Dữ liệu ra 2 STT 2 |
| Thời lượng | 8 | Số | Hiển thị, căn trái | Số nguyên phút kèm "phút" | - | UC-003 Dữ liệu ra 2 STT 3; GL-37 |
| Độ tuổi được xem | - | Lựa chọn | Hiển thị | Nhãn P, K, T13, T16, T18 hoặc C; rỗng hiện "Chưa có" | - | UC-003 Dữ liệu ra 2 STT 4 |
| Mô tả | - | Chữ | Hiển thị, xuống dòng tự động | Văn bản; rỗng hiện "Chưa có" | Không cắt chữ (UI-STT 35) | UC-003 Dữ liệu ra 2 STT 5 |
| Trailer | - | Chữ | Hiển thị dạng liên kết | Đường dẫn văn bản tới video đặt ngoài hệ thống | Thiết kế: mở bằng liên kết ở tab mới | UC-003 Dữ liệu ra 2 STT 6, Mục 8; UC-010 Q-199 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-24 | Nielsen 3 Kiểm soát và tự do | Đạt | Nút Quay lại danh sách phim để xem phim khác (UI-STT 51) | - |
| SCR-24 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lối từ thông tin phim sang lịch chiếu của phim (đặc tả không nêu) | Chấp nhận theo Q-272; khách dùng SCR-25 |
| SCR-24 | WCAG 2.4.4 Mục đích của liên kết (ngữ cảnh) | Đạt | Liên kết Xem trailer có chữ rõ nghĩa, báo mở tab mới | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21-24, 28, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-272.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
