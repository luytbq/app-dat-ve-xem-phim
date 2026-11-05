# P11a - SCR-20 Lập hoặc sửa suất chiếu (Create or edit showtime) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-014 1.3 (bước 2-9, luồng 1a4, 4a-6c, 8a-8e, *a, Dữ liệu vào 1, Dữ liệu ra 1, 2); P05 GL-14, GL-15, GL-53; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-20 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-20 |
| UC | UC-014 |
| Bước UC | 2, 3, 4, 5, 6, 7, 8, 9; luồng 1a4, 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a-8e, *a |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-ScheduleShowtimesForm (showAuditoriumsAndMovies, submitShowtimeInfo, showShowtimeForEdit, showSavedShowtime, notifyRefusal, cancelRequest, showRequestCancelled) |
| DC | DC-ScheduleShowtimesView |
| Loại màn hình | Con phụ thuộc (pop-up modal) |
| Đến từ | SCR-19 (E-31) |
| Đi tới | Đóng ngầm định về SCR-19 |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------+
| Lập suất chiếu mới                          [ Đóng ]    |
|------------------------------------------------------|
| (vùng thông điệp: MSG-58 đến MSG-65, MSG-66 đến MSG-69, MSG-79) |
| Phim *                  [ Phim A (2D, 3D, 120 phút)   v ] |
|   Chiếu từ 01/11/2026 đến 30/11/2026                    |
| Định dạng *             [ 3D v ]                        |
| Phòng chiếu *           [ Phòng 3 - thường - 2D, 3D   v ]|
| Ngày giờ bắt đầu *      [ 15/11/2026 19:30 ] dd/MM/yyyy HH:mm |
| Thời điểm mở bán *      [ 10/11/2026 08:00 ] dd/MM/yyyy HH:mm |
| Giờ kết thúc (hệ thống tính) 15/11/2026 21:30  (sau khi lưu)|
|                      [ Huỷ yêu cầu ]  [ Lưu suất chiếu ] |
+------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h2 trong hộp: "Lập suất chiếu mới" hoặc "Sửa suất chiếu"; nút Đóng | Đầu hộp | UI-STT 09, 21 |
| Thông điệp | MSG-58 đến MSG-69, MSG-79 | Dưới tiêu đề hộp | UI-STT 08 |
| Nội dung | Năm trường nhập, dòng khoảng chiếu của phim, dòng giờ kết thúc | Giữa hộp | UC-014 Dữ liệu vào 1 |
| Hành động | Huỷ yêu cầu, Lưu suất chiếu | Cuối hộp, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện hộp modal. Lập mới: các trường trống. Sửa: các trường mang thông tin hiện tại của suất chiếu. Tải danh sách phòng chiếu của cụm rạp (tên, loại phòng, định dạng chiếu được) và danh sách phim (tên, định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu) | UC-014 bước 2, luồng 1a4, Dữ liệu ra 1 |
| 2 | Danh sách Phim | Danh sách chọn | Chọn | Chọn phim; hiện dòng "Chiếu từ ... đến ..." của phim | UC-014 bước 3, Dữ liệu vào 1 STT 1; Dữ liệu ra 1 STT 2 |
| 3 | Danh sách Định dạng | Danh sách chọn | Chọn | Chọn 2D hoặc 3D | UC-014 Dữ liệu vào 1 STT 2 |
| 4 | Danh sách Phòng chiếu | Danh sách chọn | Chọn | Chọn phòng chiếu của cụm rạp | UC-014 Dữ liệu vào 1 STT 3; BR-46 |
| 5 | Ô Ngày giờ bắt đầu, Thời điểm mở bán | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03), rồi định dạng dd/MM/yyyy HH:mm (MSG-79) | UC-014 Dữ liệu vào 1 STT 4, 5; MSG-03, MSG-79 |
| 6 | Nút Lưu suất chiếu | Nút chính | Nhấn | Kiểm các trường theo UI-STT 19, gửi. Hệ thống từ chối ở lại hộp, giữ dữ liệu: phòng không thuộc cụm MSG-58; định dạng không phải định dạng phát hành MSG-59; phòng không chiếu được định dạng MSG-60; bảng giá thiếu giá MSG-61; ngoài khoảng chiếu MSG-62; giờ bắt đầu không sau hiện tại MSG-63; mở bán không trước giờ bắt đầu MSG-64; cách suất khác dưới 15 phút MSG-65. Khi sửa: có ghế giữ hoặc vé MSG-66, đã tới giờ MSG-67, suất đã đổi hoặc không còn MSG-68 rồi đóng hộp. Thành công: MSG-69, hiện suất đã lưu kèm giờ kết thúc, đóng hộp, làm mới SCR-19 | UC-014 bước 4-9, luồng 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a-8e; BR-46 đến BR-57, BR-60, BR-69; MSG-58 đến MSG-69 |
| 7 | Nút Huỷ yêu cầu | Nút phụ | Nhấn | Đóng hộp không lưu, về SCR-19 và hiện MSG-57 | UC-014 luồng *a; MSG-57 |
| 8 | Nút Đóng | Nút phụ | Nhấn | Như Huỷ yêu cầu | UC-014 luồng *a |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Phim | - | Lựa chọn | Chọn, bắt buộc | Một phim trong danh sách phim của chuỗi; ngày chiếu nằm trong khoảng chiếu của phim (BR-49) | Hiển thị tên, định dạng phát hành, thời lượng (phút), ngày khởi chiếu, ngày kết thúc chiếu dd/MM/yyyy | UC-014 Dữ liệu vào 1 STT 1, Dữ liệu ra 1 STT 2 |
| Định dạng | - | Lựa chọn | Chọn, bắt buộc | 2D hoặc 3D; là định dạng phát hành của phim (BR-47); phòng chiếu được định dạng này (BR-48); bảng giá có giá (BR-69) | - | UC-014 Dữ liệu vào 1 STT 2 |
| Phòng chiếu | - | Lựa chọn | Chọn, bắt buộc | Phòng chiếu thuộc cụm rạp của quản lý (BR-46) | Hiển thị tên phòng, loại phòng, các định dạng chiếu được | UC-014 Dữ liệu vào 1 STT 3, Dữ liệu ra 1 STT 1 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Nhập, bắt buộc, căn trái | dd/MM/yyyy HH:mm; ngày chiếu thuộc khoảng chiếu của phim (BR-49); sau thời điểm kiểm tra (BR-56); cách suất khác trong phòng ít nhất 15 phút (BR-51) | Gợi ý định dạng dưới nhãn | UC-014 Dữ liệu vào 1 STT 4 |
| Thời điểm mở bán | 16 | Ngày giờ | Nhập, bắt buộc, căn trái | dd/MM/yyyy HH:mm; trước ngày giờ bắt đầu (BR-55) | Gợi ý định dạng dưới nhãn | UC-014 Dữ liệu vào 1 STT 5; BR-55 |
| Giờ kết thúc | 16 | Ngày giờ | Hiển thị | dd/MM/yyyy HH:mm, hệ thống tính từ giờ bắt đầu và thời lượng phim (BR-50) | Chỉ hiện sau khi lưu | UC-014 Dữ liệu ra 2 STT 1; BR-50 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Phim, Định dạng, Phòng chiếu | Rời trường; nhấn Lưu | Bắt buộc có giá trị --> định dạng phát hành, phòng chiếu được định dạng, phòng thuộc cụm, bảng giá đủ (hệ thống) | MSG-03; MSG-59; MSG-60; MSG-58; MSG-61 |
| Ngày giờ bắt đầu | Rời trường; nhấn Lưu | Bắt buộc --> định dạng dd/MM/yyyy HH:mm --> trong khoảng chiếu của phim --> sau hiện tại --> cách suất khác 15 phút (hệ thống) | MSG-03; MSG-79; MSG-62; MSG-63; MSG-65 |
| Thời điểm mở bán | Rời trường; nhấn Lưu | Bắt buộc --> định dạng --> trước giờ bắt đầu | MSG-03; MSG-79; MSG-64 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-20 | Nielsen 5 Ngăn lỗi | Đạt | Danh sách chọn cho phim, định dạng, phòng chiếu; hiện khoảng chiếu của phim ngay dưới ô (UI-STT 32) | - |
| SCR-20 | Nielsen 9 | Đạt | Mỗi từ chối có thông điệp riêng nêu cách khắc phục (MSG-58 đến MSG-65) | - |
| SCR-20 | Baymard: một cột, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-20 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21) | - |
| SCR-20 | WCAG 3.3.2 | Đạt | Gợi ý định dạng ngày giờ dưới nhãn, không dùng placeholder thay nhãn | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 17-21, 25, 27-31, 33-35.

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
