# P11a - SCR-32 Danh sách phim của chuỗi (Chain movie list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-010 1.2 (bước 1, 2, 6, luồng 1a1-1a3, 5a, Dữ liệu vào 2, Dữ liệu ra 1, 2, BR-138); P05 GL-37; P07 UC-010; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-32 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-32 |
| UC | UC-010 |
| Bước UC | 1, 2, 6; 1a1, 1a2, 1a3; luồng 5a |
| Tác nhân | ACT-05 Quản lý chuỗi |
| Boundary AC | AC-B-ManageMoviesForm (requestMovieAddition, showMovieList, requestMovieEdit, selectMovieToEdit, showSavedMovie, notifyRefusal) |
| DC | DC-ManageMoviesView, DC-ManageMoviesStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-31 (E-55); SCR-33 (đóng pop-up ngầm định) |
| Đi tới | SCR-33 (E-56, pop-up) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------------------+
| CineBook   Trang chủ                                     [ Đăng xuất ]   |
|------------------------------------------------------------------------|
| Danh sách phim của chuỗi                                [ Thêm phim ]    |
| (vùng thông điệp: MSG-99, MSG-100, MSG-131)                             |
| Tên phim | Thể loại | Thời lượng | Độ tuổi | Định dạng | Khởi chiếu | Kết thúc |
|----------+----------+------------+---------+-----------+------------+----------|
| Mai      | Tâm lý   | 131 phút   | T18     | 2D        | 15/12/2026 | 31/12/2026 |
|          |          |            |         |           |   [ Sửa ]              |
+------------------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Danh sách phim của chuỗi"; nút chính Thêm phim | Đầu nội dung, căn phải | UI-STT 06 |
| Thông điệp | MSG-99, MSG-100, MSG-131 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng phim của chuỗi, mỗi hàng có nút Sửa | Giữa | UC-010 Dữ liệu ra 1; UI-STT 51 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiện danh sách phim của chuỗi, ghi nhận mốc hiển thị của từng phim. Rỗng: MSG-131 | UC-010 bước 2, luồng 1a1; BR-138; MSG-131 |
| 2 | Bảng phim | Bảng | Khởi tạo | Mỗi hàng: tên phim, thể loại, thời lượng, độ tuổi được xem, các định dạng phát hành, ngày khởi chiếu, ngày kết thúc chiếu. Sắp theo ngày khởi chiếu mới nhất trước | UC-010 Dữ liệu ra 1 STT 1 |
| 3 | Nút Thêm phim | Nút chính | Nhấn | Mở SCR-33 dạng pop-up modal ở chế độ thêm mới | UC-010 bước 1, 2, 3 |
| 4 | Nút Sửa (mỗi hàng) | Nút phụ | Nhấn | Mở SCR-33 chế độ sửa với thông tin hiện tại của phim đã chọn | UC-010 luồng 1a2, 1a3, Dữ liệu ra 3 |
| 5 | Thông điệp sau khi lưu | Vùng hiển thị | Nhận kết quả | Khi SCR-33 lưu thành công: hiện MSG-100, tải lại bảng, đánh dấu hàng phim vừa lưu (UI-STT 18). Khi SCR-33 báo phim đã bị người khác sửa: hiện MSG-99 và tải lại bảng | UC-010 bước 6, luồng 5a; BR-138; MSG-99, MSG-100 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Tên phim | 200 | Chữ | Hiển thị, căn trái | Được trùng tên phim khác (Q-200) | Độ dài theo Q-273 | UC-010 Dữ liệu ra 1 STT 1; Q-200 |
| Thể loại | 50 | Chữ | Hiển thị, căn trái | Văn bản; rỗng hiện "Chưa có" | - | UC-010 Dữ liệu ra 1 STT 1 |
| Thời lượng | 8 | Số | Hiển thị, căn phải | Số nguyên phút kèm "phút" | - | UC-010 Dữ liệu ra 1 STT 1 |
| Độ tuổi được xem | - | Lựa chọn | Hiển thị | Nhãn P, K, T13, T16, T18 hoặc C; rỗng hiện "Chưa có" | - | UC-010 Dữ liệu ra 1 STT 1; Q-198 |
| Định dạng phát hành | - | Lựa chọn | Hiển thị | 2D, 3D hoặc cả hai, cách nhau bằng dấu phẩy | - | UC-010 Dữ liệu ra 1 STT 1; BR-134 |
| Ngày khởi chiếu | 10 | Ngày | Hiển thị, căn phải | dd/MM/yyyy | - | UC-010 Dữ liệu ra 1 STT 1 |
| Ngày kết thúc chiếu | 10 | Ngày | Hiển thị, căn phải | dd/MM/yyyy | - | UC-010 Dữ liệu ra 1 STT 1 |
| Phim cần sửa | - | Lựa chọn | Chọn, bắt buộc | Một phim trong danh sách của chuỗi | - | UC-010 Dữ liệu vào 2 STT 1 |

## f) Kiểm tra dữ liệu nhập

Không có trường nhập dữ liệu nghiệp vụ.

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-32 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục bảng và nút Sửa với SCR-19, SCR-28 (UI-STT 51) | - |
| SCR-32 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm phim; chuỗi có nhiều phim sẽ phải cuộn (đặc tả không nêu) | Chấp nhận, không thêm chức năng ngoài đặc tả |
| SCR-32 | WCAG 2.4.3 Thứ tự tiêu điểm | Đạt | Đóng pop-up SCR-33 trả tiêu điểm về nút đã mở (UI-STT 21) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21, 28-31, 33-35.

## h) Thông điệp mới

Không có. MSG-99, MSG-100, MSG-131 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-273.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
