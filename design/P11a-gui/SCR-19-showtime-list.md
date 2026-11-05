# P11a - SCR-19 Danh sách suất chiếu (Showtime list) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-014 1.3 (luồng 1, 1a, 1b, Dữ liệu ra 3); P05 GL-47, GL-49; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-19 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-19 |
| UC | UC-014 |
| Bước UC | 1, 1a1-1a3, 1b1-1b4; luồng 1a3a, 1a3b, 1b3a, 1b3b, 1b3c |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-ScheduleShowtimesForm (requestNewShowtime, requestEditShowtime, requestDeleteShowtime, showShowtimes, selectShowtimeToEdit, selectShowtimeToDelete, notifyDeleted, notifyRefusal) |
| DC | DC-ScheduleShowtimesView, DC-ScheduleShowtimesStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-17 (E-30) |
| Đi tới | SCR-20 (E-31, pop-up) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Danh sách suất chiếu                       [ Lập suất chiếu mới ] |
| (vùng thông điệp: MSG-66, MSG-67, MSG-68, MSG-69, MSG-70, MSG-57) |
| Phim   | Định dạng | Phòng   | Bắt đầu          | Kết thúc         | Mở bán           |
|--------+-----------+---------+------------------+------------------+------------------|
| Phim A | 3D        | Phòng 3 | 15/11/2026 19:30 | 15/11/2026 21:30 | 10/11/2026 08:00 |
|        |           |         |                  |   [ Sửa ] [ Xoá ]                   |
+------------------------------------------------------------+
Hộp xác nhận (MSG-71): Xoá suất chiếu Phim A, Phòng 3, 15/11/2026 19:30? ... [ Giữ lại ] [ Xoá suất chiếu ]
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Danh sách suất chiếu"; nút chính Lập suất chiếu mới | Đầu nội dung, căn phải | UI-STT 06 |
| Thông điệp | MSG-57, MSG-66, MSG-67, MSG-68, MSG-69, MSG-70, MSG-74 | Dưới tiêu đề | UI-STT 08 |
| Nội dung | Bảng suất chiếu của các phòng thuộc cụm rạp, mỗi hàng có Sửa và Xoá | Giữa | UC-014 Dữ liệu ra 3 |
| Hộp thoại | Hộp xác nhận MSG-71 (modal) | Giữa màn hình | UI-STT 37 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải và hiện các suất chiếu đã lập của các phòng chiếu thuộc cụm rạp, ghi nhận mốc hiển thị của từng suất. Rỗng: MSG-74 | UC-014 luồng 1a1, 1b1; BR-46, BR-60; MSG-74 |
| 2 | Bảng suất chiếu | Bảng | Khởi tạo | Mỗi hàng: phim, định dạng, phòng chiếu, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán | UC-014 Dữ liệu ra 3 STT 1 |
| 3 | Nút Lập suất chiếu mới | Nút chính | Nhấn | Mở SCR-20 dạng pop-up modal ở chế độ lập mới | UC-014 bước 1, 2 |
| 4 | Nút Sửa (mỗi hàng) | Nút phụ | Nhấn | Hệ thống kiểm suất chiếu chưa tới giờ bắt đầu, không có ghế đang giữ hoặc vé chưa huỷ. Đạt: mở SCR-20 chế độ sửa với thông tin hiện tại. Đã tới giờ bắt đầu: MSG-67. Có ghế giữ hoặc vé chưa huỷ: MSG-66. Ở lại danh sách | UC-014 luồng 1a2, 1a3, 1a3a, 1a3b, 1a4; BR-53, BR-57; MSG-66, MSG-67 |
| 5 | Nút Xoá (mỗi hàng) | Nút phụ | Nhấn | Mở hộp xác nhận MSG-71 | UC-014 luồng 1b2; MSG-71; UI-STT 37 |
| 6 | Nút Xoá suất chiếu (hộp xác nhận) | Nút chính phá huỷ | Nhấn | Gửi yêu cầu xoá. Thành công: MSG-70 và bỏ hàng khỏi bảng. Suất đã bị đổi hoặc xoá: MSG-68 và tải lại danh sách. Đã tới giờ bắt đầu: MSG-67. Có ghế giữ hoặc vé chưa huỷ: MSG-66 | UC-014 luồng 1b3, 1b3a, 1b3b, 1b3c, 1b4; BR-53, BR-57, BR-58, BR-60; MSG-66 đến MSG-68, MSG-70 |
| 7 | Nút Giữ lại (hộp xác nhận) | Nút phụ | Nhấn | Đóng hộp, không xoá | UI-STT 37 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Phim | - | Chữ | Hiển thị | Tên phim | - | UC-014 Dữ liệu ra 3 STT 1 |
| Định dạng | - | Lựa chọn | Hiển thị | 2D hoặc 3D | - | UC-014 Dữ liệu ra 3 STT 1 |
| Phòng chiếu | - | Chữ | Hiển thị | Phòng chiếu của cụm rạp | - | UC-014 Dữ liệu ra 3 STT 1; BR-46 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm | - | UC-014 Dữ liệu ra 3 STT 1 |
| Giờ kết thúc | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm, tính từ giờ bắt đầu và thời lượng phim (BR-50) | - | UC-014 Dữ liệu ra 3 STT 1; BR-50 |
| Thời điểm mở bán | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm | - | UC-014 Dữ liệu ra 3 STT 1 |
| Suất chiếu cần sửa hoặc xoá | - | Lựa chọn | Chọn, bắt buộc | Một suất chiếu của phòng thuộc cụm rạp mình, chưa tới giờ bắt đầu, không có ghế giữ, vé chưa huỷ | - | UC-014 Dữ liệu vào 2 STT 1; BR-46, BR-53, BR-57 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Suất chiếu cần sửa hoặc xoá | Nhấn Sửa, Xoá (hệ thống) | Thuộc cụm rạp --> chưa đổi hoặc xoá kể từ lúc hiển thị --> chưa tới giờ bắt đầu --> không có ghế giữ, vé chưa huỷ | MSG-68; MSG-67; MSG-66 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-19 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận xoá nêu hậu quả (MSG-71) | - |
| SCR-19 | Nielsen 3 | Đạt | Từ chối ở lại danh sách, không đẩy người dùng ra màn hình khác (UI-STT 29(2)) | - |
| SCR-19 | WCAG 2.4.3 | Đạt | Đóng pop-up SCR-20 trả tiêu điểm về nút đã mở (UI-STT 21) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 18, 21, 27-31, 33-35, 37.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Không có.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Không có.
