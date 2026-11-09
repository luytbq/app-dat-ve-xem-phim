# P11a - SCR-10 Chọn suất và ghế tại quầy (Select showtime and seats at counter) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.2 |
| Thay đổi 1.2 | Thêm MSG-82 vào nhánh từ chối của nút Xác nhận chọn ghế (RF-17); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | ui-standards.md 1.3; screen-list.md 1.3; screen-transition.md 1.1; P04 UC-005 1.11 (bước 1-7, Dữ liệu vào 1, Dữ liệu ra 1, luồng 2a-2c, 5b, 6a, 7a, 7c, 7d, 7e); P06 NFR-08, NFR-09; P09 F7.5; P08-analysis-model.md 1.4 (F3); P10-design-elements.md 1.4 (F3, F4) |
| Phạm vi | SCR-10 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-10 |
| UC | UC-005 |
| Bước UC | 1, 2, 3, 4, 5, 6, 7; luồng 2a, 2b, 2c, 5b, 6a, 7a, 7c, 7d, 7e |
| Tác nhân | ACT-02 Nhân viên quầy |
| Boundary AC | AC-B-CounterBookTicketsForm (selectShowtime, showSeatMap, confirmSeatSelection, updateSeatMap, notifyRefusal) |
| DC | DC-CounterBookTicketsView, DC-SeatMapSyncClient, DC-SeatMapReducer |
| Loại màn hình | Độc lập |
| Đến từ | SCR-09 (E-21) |
| Đi tới | SCR-11 (E-23), SCR-09 (E-24) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Chọn suất và ghế                                             |
| (vùng thông điệp: MSG-07, MSG-10, MSG-11, MSG-12, MSG-23)    |
| Suất chiếu *  [ Phim A, 2D, Phòng 3, 15/11/2026 19:30   v ]  |
| (o) Đang cập nhật trực tiếp                                   |
|                    ====== MÀN HÌNH ======                     |
|  A  [A1][A2][A3][A4][A5][A6][A7][A8][A9]                       |
|  F  [F1][F2][F3][F4][F5][F6][F7][F8][F9]                       |
|  M  [M1 ========][M2 ========][M3 ========]   ghế đôi        |
| Chú giải: [ ] Trống  [v] Đang chọn  [/L] Đang được giữ  [X] Đã bán |
| Đã chọn: F7, F8 - 2 ghế (tối đa 8)                            |
|                                      [ Xác nhận chọn ghế ]     |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Chọn suất và ghế" | Đầu nội dung | UI-STT 09 |
| Thông điệp | MSG-07, MSG-08, MSG-10, MSG-11, MSG-12, MSG-23 đến MSG-25, MSG-74, MSG-82 | Dưới tiêu đề | UI-STT 08 |
| Chọn suất | Danh sách chọn suất chiếu | Đầu nội dung | UC-005 bước 1 |
| Sơ đồ ghế | Giống SCR-04 (dải kết nối, lưới, chú giải) | Giữa | UI-STT 39-41 |
| Hành động | Đếm ghế, nút chính Xác nhận chọn ghế | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải danh sách suất chiếu của cụm rạp mình; chưa chọn suất thì không hiện sơ đồ. Rỗng: MSG-74 | UC-005 bước 1, BR-02; Q-120; MSG-74 |
| 2 | Danh sách Suất chiếu | Danh sách chọn | Chọn | Gửi suất đã chọn; hệ thống kiểm đã mở bán, chưa bắt đầu, thuộc cụm rạp của nhân viên. Hợp lệ: tải ảnh chụp sơ đồ kèm con trỏ và mở kết nối đẩy (đóng kết nối của suất trước). Chưa mở bán MSG-06, ngoài cụm rạp MSG-07, đã bắt đầu MSG-08: ở lại, đặt lại danh sách | UC-005 bước 1-3, luồng 2a, 2b, 2c; BR-01, BR-02, BR-45; MSG-06, MSG-07, MSG-08 |
| 3 | Sơ đồ ghế | Lưới | Nhận kết quả (sự kiện đổi ghế) | Như SCR-04: áp sự kiện trong 3 giây, ghế đang chọn bị lấy thì bỏ chọn và hiện MSG-23 | UC-005 bước 3, Mục 7 STT 2, 5; NFR-08, NFR-09; MSG-23 |
| 4 | Dải trạng thái kết nối | Vùng hiển thị | Nhận kết quả (mất, nối lại kết nối) | Như SCR-04: MSG-24, MSG-25, tải lại ảnh chụp kèm con trỏ | P09 F7.5; MSG-24, MSG-25 |
| 5 | Ô ghế trống | Nút chọn (trong lưới) | Chọn | Bật hoặc tắt đang chọn; ghế vẫn trống cho tới khi xác nhận | UC-005 bước 4, BR-03 |
| 6 | Ô ghế đang được giữ, đã bán | Nút chọn vô hiệu (trong lưới) | Chọn | Không chọn được | UC-005 bước 3, BR-08 |
| 7 | Nút Xác nhận chọn ghế | Nút chính | Nhấn | Vô hiệu khi chưa chọn ghế. Gửi danh sách ghế, hiện MSG-26. Nhân viên đã đăng nhập (tiền điều kiện) nên không có bước đăng nhập. Từ chối: đang có lần giữ ghế chưa kết thúc MSG-09 --> SCR-09; vượt 8 ghế MSG-10 ở lại; có ghế không còn trống MSG-11 ở lại; ghế đang được trả về trống MSG-82 ở lại; suất chiếu đã đổi MSG-12 ở lại, tải lại danh sách suất chiếu; thiếu giá MSG-13 --> SCR-09. Thành công: mở SCR-11 | UC-005 bước 4-7, luồng 5b, 6a, 7a, 7c, 7d, 7e; BR-04, BR-05, BR-07, BR-09, BR-54, BR-72; MSG-09 đến MSG-13, MSG-26, MSG-82 |
| 8 | Vùng đếm ghế đã chọn | Vùng hiển thị | Chọn | Cập nhật "Đã chọn: ... - n ghế (tối đa 8)"; ghế đôi đếm một ghế | UC-005 Dữ liệu vào 1 STT 1; BR-05, BR-06 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Suất chiếu | - | Lựa chọn | Chọn, bắt buộc | Một suất chiếu đã mở bán, chưa bắt đầu, thuộc cụm rạp của nhân viên quầy | Hiển thị phim, định dạng, phòng chiếu, ngày giờ bắt đầu dd/MM/yyyy HH:mm | UC-005 Dữ liệu ra 1 STT 1; BR-01, BR-02, BR-45 |
| Vị trí ghế | - | Chữ | Hiển thị | Mã hàng và số ghế, ví dụ F7 | - | UC-005 Dữ liệu ra 1 STT 2 |
| Loại ghế | - | Lựa chọn | Hiển thị | Ghế thường, VIP, đôi | - | UC-005 Dữ liệu ra 1 STT 3 |
| Trạng thái ghế | - | Lựa chọn | Hiển thị | Trống, đang được giữ, đã bán | - | UC-005 Dữ liệu ra 1 STT 4 |
| Các ghế đã chọn | - | Lựa chọn | Chọn, bắt buộc | Thuộc sơ đồ ghế; ít nhất 1, không quá 8, ghế đôi tính một | - | UC-005 Dữ liệu vào 1 STT 1; BR-05, BR-06 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Suất chiếu | Chọn | Bắt buộc --> thuộc danh sách trả về --> mở bán, chưa bắt đầu, đúng cụm rạp (hệ thống) | MSG-06; MSG-07; MSG-08 |
| Các ghế đã chọn | Nhấn Xác nhận chọn ghế | Bắt buộc ít nhất 1 ghế --> không quá 8 ghế --> ghế còn trống (hệ thống) | MSG-10; MSG-11 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-10 | Nielsen 7 Linh hoạt và hiệu quả | Đạt | Chọn suất và ghế trên một màn hình cho thao tác lặp tại quầy | - |
| SCR-10 | Nielsen 1 | Đạt | Dải kết nối, đếm ghế, MSG-26 | - |
| SCR-10 | WCAG 1.4.1 | Đạt | Bốn ký hiệu ghế như SCR-04 (UI-STT 39) | - |
| SCR-10 | WCAG 2.1.1 | Đạt | UI-STT 26 | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 27-29, 33-35, 40-42.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-119, Q-120. Q-119: MSG-09 đưa nhân viên về SCR-09, nơi có dải Tiếp tục thanh toán mở SCR-11.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Danh sách suất chiếu cho quầy phụ thuộc Q-120.
