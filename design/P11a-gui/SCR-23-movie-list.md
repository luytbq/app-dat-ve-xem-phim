# P11a - SCR-23 Danh sách phim (Movie list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-003 1.1 (bước 1-4, luồng 2a, Dữ liệu ra 1, BR-76, Q-175); P05 GL-37; P07 UC-003; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-23 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-23 |
| UC | UC-003 |
| Bước UC | 1, 2, 3, 4; luồng 2a |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BrowseMoviesForm (requestMovieList, showMovieList, notifyNoMovies, selectMovie) |
| DC | DC-BrowseMoviesView, DC-BrowseMoviesStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-02 (E-44); SCR-24 (E-46) |
| Đi tới | SCR-24 (E-45) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                         [ Đăng nhập ]  |
|------------------------------------------------------------|
| Danh sách phim                                               |
| (vùng thông điệp: MSG-91, MSG-72, MSG-73)                    |
| Phim đang chiếu                                              |
| Tên phim | Thể loại   | Thời lượng | Độ tuổi |               |
|----------+------------+------------+---------+---------------|
| Phim A   | Hành động  | 125 phút   | T13     | [ Xem phim ]  |
| Phim sắp chiếu                                               |
| Tên phim | Thể loại   | Thời lượng | Độ tuổi | Khởi chiếu    |
|----------+------------+------------+---------+---------------|
| Mai      | Tâm lý     | 131 phút   | T18     | 15/12/2026    |
|          |            |            |         | [ Xem phim ]  |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng nhập khi chưa có phiên | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Danh sách phim" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-91, MSG-72, MSG-73 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng Phim đang chiếu, bảng Phim sắp chiếu; mỗi hàng có nút Xem phim | Giữa | UC-003 Dữ liệu ra 1; UI-STT 18 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Yêu cầu hệ thống danh sách phim, hiện hai nhóm theo ngày hiện tại của hệ thống. Nhóm không có phim thì không hiện bảng của nhóm đó. Cả hai nhóm rỗng: hiện MSG-91. Khách không cần đăng nhập | UC-003 bước 1-3, luồng 2a; BR-76; MSG-91 |
| 2 | Bảng Phim đang chiếu | Bảng | Khởi tạo | Mỗi hàng: tên phim, thể loại, thời lượng, độ tuổi được xem. Sắp theo ngày khởi chiếu mới nhất trước | UC-003 Dữ liệu ra 1 STT 1-5; Thiết kế: thứ tự trình bày |
| 3 | Bảng Phim sắp chiếu | Bảng | Khởi tạo | Như bảng Phim đang chiếu, thêm cột Ngày khởi chiếu; sắp theo ngày khởi chiếu gần nhất trước | UC-003 Dữ liệu ra 1 STT 6 |
| 4 | Nút Xem phim (mỗi hàng) | Nút phụ | Nhấn | Mở SCR-24 với phim đã chọn | UC-003 bước 4 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Nhóm phim | - | Lựa chọn | Hiển thị | Đang chiếu hoặc sắp chiếu; mỗi phim đúng một nhóm | Hiện làm tiêu đề bảng | UC-003 Dữ liệu ra 1 STT 1; BR-76 |
| Tên phim | - | Chữ | Hiển thị, căn trái | Nguyên văn tên phim | - | UC-003 Dữ liệu ra 1 STT 2 |
| Thể loại | - | Chữ | Hiển thị, căn trái | Văn bản; rỗng hiện "Chưa có" | Thể loại không bắt buộc ở UC-010 | UC-003 Dữ liệu ra 1 STT 3; UC-010 Dữ liệu vào 1 STT 2 |
| Thời lượng | 8 | Số | Hiển thị, căn phải | Số nguyên phút kèm chữ "phút" (125 phút) | - | UC-003 Dữ liệu ra 1 STT 4 |
| Độ tuổi được xem | - | Lựa chọn | Hiển thị | Nhãn P, K, T13, T16, T18 hoặc C; rỗng hiện "Chưa có" | Hiện nguyên nhãn (Q-198 của UC-010) | UC-003 Dữ liệu ra 1 STT 5; UC-010 Dữ liệu vào 1 STT 4 |
| Ngày khởi chiếu | 10 | Ngày | Hiển thị, căn phải, chỉ ở phim sắp chiếu | dd/MM/yyyy | - | UC-003 Dữ liệu ra 1 STT 6 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-23 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Danh sách rỗng hiện MSG-91 thay vì màn hình trống (UI-STT 18) | - |
| SCR-23 | Nielsen 6 Nhận biết thay vì nhớ lại | Đạt | Hai nhóm có tiêu đề và cột ngày khởi chiếu riêng cho phim sắp chiếu | - |
| SCR-23 | WCAG 1.3.1 Thông tin và quan hệ | Đạt | Bảng có hàng tiêu đề, dưới 600 px hàng thành thẻ có nhãn trường (UI-STT 18) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21-24, 28, 33-35.

## h) Thông điệp mới

Không có. MSG-91 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-272.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
