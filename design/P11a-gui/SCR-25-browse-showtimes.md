# P11a - SCR-25 Tra cứu lịch chiếu (Browse showtimes) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-004 1.2 (bước 1-5, luồng 1a, 4a, Dữ liệu vào 1, 2, Dữ liệu ra 1, 2, 3, Mục 8, BR-45, BR-58, BR-76); P05 GL-47; P07 UC-004; P08-analysis-model.md 2.0 (F3); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-25 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-25 |
| UC | UC-004 |
| Bước UC | 1, 2, 3, 4, 5; luồng 1a1-1a5, 1a4a, 4a |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BrowseShowtimesForm (requestShowtimesByMovie, showMovieList, selectMovieAndCriteria, showShowtimes, notifyNoShowtimes, requestShowtimesByCinema, showCinemaList, selectCinemaAndCriteria) |
| DC | DC-BrowseShowtimesView, DC-BrowseShowtimesStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-02 (E-47) |
| Đi tới | Không có (màn hình kết thúc, thoát bằng menu tới SCR-02) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------------------+
| CineBook   Trang chủ                                      [ Đăng nhập ]  |
|------------------------------------------------------------------------|
| Tra cứu lịch chiếu                                                       |
| (vùng thông điệp: MSG-92, MSG-97, MSG-72, MSG-73)                        |
| Xem lịch chiếu:  (x) Theo phim   ( ) Theo cụm rạp                        |
| Phim *               [ Phim A                          v ]               |
| Tỉnh, thành phố (không bắt buộc)  [ Tất cả             v ]               |
| Ngày (không bắt buộc) [ 15/11/2026 ]  dd/MM/yyyy                         |
| Loại phòng (không bắt buộc)  [ Tất cả v ]  Định dạng [ Tất cả v ]        |
|                                              [ Xem lịch chiếu ]          |
| Cụm rạp | Phòng   | Loại  | Định | Bắt đầu          | Mở bán           |
|---------+---------+-------+------+------------------+------------------|
| CineBook Cầu Giấy (Hà Nội) | Phòng 3 | IMAX | 2D | 15/11/2026 19:30 | 10/11/2026 08:00 |
| CineBook Bà Triệu (Hà Nội) | Phòng 1 | Thường | 2D | 16/11/2026 20:00 | 11/11/2026 08:00 Chưa mở bán |
+------------------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng nhập khi chưa có phiên | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Tra cứu lịch chiếu" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-92, MSG-97, MSG-72, MSG-73 | Dưới tiêu đề | UI-STT 08 |
| Điều kiện xem | Nút chọn Theo phim hoặc Theo cụm rạp, danh sách chọn phim hoặc cụm rạp, bốn bộ lọc tuỳ chọn, nút Xem lịch chiếu | Đầu nội dung | UC-004 Dữ liệu vào 1, 2 |
| Kết quả | Bảng suất chiếu thoả mọi tiêu chí | Dưới điều kiện xem | UC-004 Dữ liệu ra 2; UI-STT 18 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Mặc định chế độ Theo phim. Yêu cầu và hiện danh sách tên phim đang chiếu, sắp chiếu để chọn. Khách không cần đăng nhập | UC-004 bước 1, 2; BR-76 |
| 2 | Nút chọn Theo phim, Theo cụm rạp | Nút chọn | Chọn | Theo cụm rạp: yêu cầu và hiện danh sách tên cụm rạp để chọn thay cho danh sách phim; các bộ lọc giữ nguyên giá trị đã nhập. Theo phim: quay về danh sách phim | UC-004 luồng 1a1, 1a2; Dữ liệu ra 1, 3 |
| 3 | Danh sách Phim hoặc Cụm rạp | Danh sách chọn | Chọn | Chọn một phim (chế độ Theo phim) hoặc một cụm rạp (Theo cụm rạp); bắt buộc | UC-004 bước 3, luồng 1a3; Dữ liệu vào 1 STT 1, Dữ liệu vào 2 STT 1 |
| 4 | Danh sách Tỉnh, thành phố | Danh sách chọn | Chọn | Tuỳ chọn "Tất cả" hoặc một tỉnh, thành phố có cụm rạp của chuỗi | UC-004 Dữ liệu vào 1 STT 2, Dữ liệu vào 2 STT 2; REQ-10 |
| 5 | Ô Ngày | Ô nhập | Rời trường | Không bắt buộc. Có nhập: kiểm định dạng dd/MM/yyyy (MSG-97). Một ngày duy nhất, so với ngày của giờ bắt đầu suất chiếu | UC-004 Dữ liệu vào 1 STT 3; Q-179; MSG-97 |
| 6 | Danh sách Loại phòng, Định dạng | Danh sách chọn | Chọn | Tuỳ chọn "Tất cả" hoặc một trong Thường, 4DX, IMAX; một trong 2D, 3D | UC-004 Dữ liệu vào 1 STT 4, 5; REQ-02, REQ-55 |
| 7 | Nút Xem lịch chiếu | Nút chính | Nhấn | Kiểm bắt buộc của phim hoặc cụm rạp (MSG-03) và định dạng ngày (MSG-97), gửi lên hệ thống (nút bận theo UI-STT 27). Có suất chiếu: hiện bảng kết quả bên dưới, giữ nguyên điều kiện. Không có suất chiếu thoả mọi tiêu chí: hiện MSG-92, không hiện bảng | UC-004 bước 3-5, luồng 1a3-1a5, 1a4a, 4a; MSG-92 |
| 8 | Bảng Lịch chiếu | Bảng | Khởi tạo | Mỗi hàng một suất chiếu chưa tới giờ bắt đầu, sắp theo giờ bắt đầu sớm nhất trước. Hàng có thời điểm mở bán sau giờ máy chủ hiện thêm chữ "Chưa mở bán". Không có số ghế trống và giá vé | UC-004 bước 4, 5, Dữ liệu ra 2, Mục 8; BR-45, BR-58; Q-176, Q-177, Q-178 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Phim | - | Lựa chọn | Chọn, bắt buộc ở chế độ Theo phim | Thuộc danh sách phim đã hiện | Danh sách gồm phim đang chiếu, sắp chiếu | UC-004 Dữ liệu vào 1 STT 1, Dữ liệu ra 1 STT 1 |
| Cụm rạp | - | Lựa chọn | Chọn, bắt buộc ở chế độ Theo cụm rạp | Thuộc danh sách cụm rạp đã hiện | - | UC-004 Dữ liệu vào 2 STT 1, Dữ liệu ra 3 STT 1 |
| Tỉnh, thành phố | - | Lựa chọn | Chọn, không bắt buộc, mặc định Tất cả | Một tỉnh, thành phố có cụm rạp của chuỗi | Danh sách giá trị do hệ thống cấp (Đề xuất sửa P04) | UC-004 Dữ liệu vào 1 STT 2; REQ-10 |
| Ngày | 10 | Ngày | Nhập, không bắt buộc, căn trái | dd/MM/yyyy; một ngày duy nhất | Gợi ý định dạng dưới nhãn | UC-004 Dữ liệu vào 1 STT 3; Q-179 |
| Loại phòng | - | Lựa chọn | Chọn, không bắt buộc, mặc định Tất cả | Thường, 4DX hoặc IMAX | - | UC-004 Dữ liệu vào 1 STT 4; REQ-02 |
| Định dạng phim | - | Lựa chọn | Chọn, không bắt buộc, mặc định Tất cả | 2D hoặc 3D | - | UC-004 Dữ liệu vào 1 STT 5; REQ-55 |
| Phim (kết quả) | - | Chữ | Hiển thị | Tên phim của suất chiếu; ẩn cột khi đã chọn Theo phim | - | UC-004 Dữ liệu ra 2 STT 1 |
| Định dạng (kết quả) | - | Lựa chọn | Hiển thị | 2D hoặc 3D | - | UC-004 Dữ liệu ra 2 STT 2 |
| Cụm rạp (kết quả) | - | Chữ | Hiển thị | Tên cụm rạp, kèm tỉnh, thành phố trong ngoặc | Ẩn tên cụm rạp khi đã chọn Theo cụm rạp | UC-004 Dữ liệu ra 2 STT 3, 7 |
| Phòng chiếu | - | Chữ | Hiển thị | Tên phòng chiếu | - | UC-004 Dữ liệu ra 2 STT 4 |
| Ngày giờ bắt đầu | 16 | Ngày giờ | Hiển thị, căn phải | dd/MM/yyyy HH:mm | - | UC-004 Dữ liệu ra 2 STT 5 |
| Loại phòng (kết quả) | - | Lựa chọn | Hiển thị | Thường, 4DX hoặc IMAX | - | UC-004 Dữ liệu ra 2 STT 6 |
| Thời điểm mở bán | 16 | Ngày giờ | Hiển thị, căn phải | dd/MM/yyyy HH:mm; kèm chữ Chưa mở bán khi chưa tới | Chữ Chưa mở bán là trình bày, tính từ giờ máy chủ | UC-004 Dữ liệu ra 2 STT 8; Q-176 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Phim hoặc Cụm rạp | Nhấn Xem lịch chiếu | Bắt buộc | MSG-03 |
| Ngày | Rời trường; nhấn Xem lịch chiếu | Định dạng dd/MM/yyyy | MSG-97 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-25 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-92 khi không có suất chiếu; chữ Chưa mở bán cho suất chiếu chưa bán được vé | - |
| SCR-25 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lối từ một suất chiếu trong kết quả sang đặt vé (đặc tả không nêu, UC-004 Mục 8) | Chấp nhận theo Q-272; khách đặt vé từ SCR-03 |
| SCR-25 | Nielsen 6 Nhận biết thay vì nhớ lại | Đạt | Điều kiện đã chọn vẫn hiện trên kết quả; đổi chế độ giữ giá trị bộ lọc | - |
| SCR-25 | WCAG 3.3.2 Nhãn hoặc hướng dẫn | Đạt | Gợi ý dd/MM/yyyy dưới nhãn Ngày; trường tuỳ chọn ghi "(không bắt buộc)" (UI-STT 16) | - |
| SCR-25 | WCAG 4.1.3 Thông điệp trạng thái | Đạt | Kết quả và MSG-92 báo qua vùng role=status (UI-STT 28) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-21, 27-28, 31, 33-35, 49.

## h) Thông điệp mới

Không có. MSG-92, MSG-97 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-272.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-004 Dữ liệu ra, Dữ liệu vào 1 STT 2 | Bộ lọc Tỉnh, thành phố chỉ nhận giá trị "có cụm rạp của chuỗi" nhưng không có dữ liệu ra nào cấp danh sách tỉnh, thành phố cho khách chọn | Thêm một dữ liệu ra nêu các tỉnh, thành phố có cụm rạp (hoặc ghi rõ khách nhập tự do) |

## Vấn đề còn mở

Không có.
