# P11a - SCR-04 Chọn ghế (Select seats) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | ui-standards.md 1.1; screen-list.md 1.1; screen-transition.md 1.1; P04 UC-005 1.9 (bước 3-7, Dữ liệu vào 1, Dữ liệu ra 1, luồng 5a, 5b, 6a, 7a, 7c, 7d, 7e, Mục 7); P06 NFR-08, NFR-09; P09 F7.5; P08-analysis-model.md 1.1 (F3); P10-design-elements.md 1.1 (F3, F4) |
| Phạm vi | SCR-04 |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-04 |
| UC | UC-005 |
| Bước UC | 3, 4, 5, 6, 7; luồng 5a, 5b, 6a, 7a, 7c, 7d, 7e |
| Tác nhân | ACT-01 Khách |
| Boundary AC | AC-B-BookTicketsForm (showSeatMap, confirmSeatSelection, updateSeatMap, notifyRefusal, requestLogin) |
| DC | DC-BookTicketsView, DC-SeatMapSyncClient, DC-SeatMapReducer |
| Loại màn hình | Phụ thuộc có dữ liệu (suất chiếu đã chọn) |
| Đến từ | SCR-03 (E-13) |
| Đi tới | SCR-01 pop-up (E-14), SCR-05 (E-15), SCR-02 (E-16), SCR-03 (E-17) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                                         |
|------------------------------------------------------------|
| Chọn ghế                                                     |
| Phim A, 2D, Phòng 3, 15/11/2026 19:30                        |
| (!) Ghế F7, F8 vừa có người khác giữ hoặc mua ... (MSG-11)    |
| (o) Đang cập nhật trực tiếp                                   |
|                    ====== MÀN HÌNH ======                     |
|  A  [A1][A2][A3][A4][A5][A6][A7][A8][A9]                       |
|  F  [F1][F2][F3][F4][F5][F6][#F7][#F8][F9]   #=viền đỏ       |
|  M  [M1 ========][M2 ========][M3 ========]   ghế đôi        |
| Chú giải: [ ] Trống  [v] Đang chọn  [/L] Đang được giữ  [X] Đã bán |
| Đã chọn: A3, A4 - 2 ghế (tối đa 8)                            |
|                                      [ Xác nhận chọn ghế ]     |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Tiêu đề | h1 "Chọn ghế"; dòng thông tin suất chiếu | Đầu nội dung | UC-005 Dữ liệu ra 1 STT 1 |
| Thông điệp | MSG-10, MSG-11, MSG-12, MSG-23, MSG-24, MSG-25 | Dưới tiêu đề | UI-STT 08, 40, 41 |
| Trạng thái kết nối | Dải "Đang cập nhật trực tiếp" hoặc MSG-24 | Trên sơ đồ | UI-STT 41 |
| Sơ đồ ghế | Lưới ghế theo hàng và số ghế, thanh MÀN HÌNH | Giữa | UI-STT 39; cuộn ngang dưới 600 px |
| Chú giải | Bốn ký hiệu trạng thái | Dưới sơ đồ | UI-STT 39 |
| Hành động | Đếm ghế đã chọn, nút chính Xác nhận chọn ghế | Cuối, căn phải | UI-STT 06 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Tải ảnh chụp sơ đồ ghế của suất chiếu kèm con trỏ sự kiện, vẽ lưới, rồi mở kết nối đẩy với con trỏ đó (UI-STT 41). Hiện thông tin suất chiếu, vị trí, loại và trạng thái từng ghế | UC-005 bước 3, Dữ liệu ra 1 STT 1-4; P09 F7.5 |
| 2 | Sơ đồ ghế | Lưới | Nhận kết quả (sự kiện đổi ghế) | Áp sự kiện lên đúng ô ghế (trống, đang được giữ, đã bán) trong vòng 3 giây kể từ khi ghế đổi, kể cả ghế trở về trống do hết hạn, huỷ giữ ghế, thanh toán thất bại, huỷ vé. Ô vừa đổi nháy viền 1 lần (UI-STT 40) | UC-005 bước 3, Mục 7 STT 2, 5; REQ-19, REQ-119; NFR-08, NFR-09 |
| 3 | Sơ đồ ghế | Lưới | Nhận kết quả (ghế đang chọn bị lấy) | Ghế khách đang chọn mà đổi sang đang được giữ hoặc đã bán: bỏ chọn ghế đó, cập nhật đếm ghế, hiện MSG-23 | UC-005 bước 3, BR-03, BR-08; MSG-23 |
| 4 | Dải trạng thái kết nối | Vùng hiển thị | Nhận kết quả (mất, nối lại kết nối) | Mất kết nối: hiện MSG-24 kèm nút Tải lại sơ đồ. Nối lại được: tải lại ảnh chụp kèm con trỏ, hiện MSG-25. Máy chủ yêu cầu tải lại: tải lại ảnh chụp sau độ trễ ngẫu nhiên 0 đến 3 giây | P09 F7.5; Q-114; MSG-24, MSG-25 |
| 5 | Ô ghế trống | Nút chọn (trong lưới) | Chọn | Bật hoặc tắt trạng thái đang chọn; ghế vẫn trống trên hệ thống cho tới khi xác nhận. Cập nhật đếm ghế đã chọn | UC-005 bước 4, BR-03; Dữ liệu vào 1 STT 1 |
| 6 | Ô ghế đang được giữ, đã bán | Nút chọn vô hiệu (trong lưới) | Chọn | Không chọn được; trình đọc màn hình đọc trạng thái ghế | UC-005 bước 3, BR-08; WCAG 1.1.1 |
| 7 | Nút Xác nhận chọn ghế | Nút chính | Nhấn | Vô hiệu khi chưa chọn ghế nào (chú thích "Chọn ít nhất 1 ghế"). Gửi danh sách ghế; hiện MSG-26. Chưa đăng nhập: mở SCR-01 pop-up (MSG-01); đăng nhập xong tự gửi lại. Đã đăng nhập, hệ thống từ chối: đang có lần giữ ghế chưa kết thúc MSG-09 --> SCR-02; vượt 8 ghế MSG-10 ở lại, giữ ghế đã chọn; có ghế không còn trống MSG-11 ở lại, sơ đồ mới nhất, ghế bị lấy viền đỏ; suất chiếu đã đổi hoặc không còn MSG-12 --> SCR-03; thiếu giá MSG-13 --> SCR-02. Thành công: mở SCR-05 với lần giữ ghế | UC-005 bước 4-7, luồng 5a, 5b, 6a, 7a, 7c, 7d, 7e; BR-04, BR-05, BR-07, BR-09, BR-54, BR-72; MSG-01, MSG-09 đến MSG-13, MSG-26 |
| 8 | Vùng đếm ghế đã chọn | Vùng hiển thị | Chọn | Cập nhật "Đã chọn: ... - n ghế (tối đa 8)"; ghế đôi đếm là một ghế | UC-005 Dữ liệu vào 1 STT 1; BR-05, BR-06 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Suất chiếu | - | Chữ | Hiển thị | Phim, định dạng, phòng chiếu, ngày giờ bắt đầu dd/MM/yyyy HH:mm | - | UC-005 Dữ liệu ra 1 STT 1 |
| Vị trí ghế | - | Chữ | Hiển thị | Mã hàng và số ghế, ví dụ F7 | Hiển thị trên ô ghế | UC-005 Dữ liệu ra 1 STT 2 |
| Loại ghế | - | Lựa chọn | Hiển thị | Ghế thường, ghế VIP hoặc ghế đôi | Ghế đôi rộng hai ô | UC-005 Dữ liệu ra 1 STT 3; BR-06 |
| Trạng thái ghế | - | Lựa chọn | Hiển thị | Trống, đang được giữ, đã bán | Bốn ký hiệu của UI-STT 39 | UC-005 Dữ liệu ra 1 STT 4 |
| Các ghế đã chọn | - | Lựa chọn | Chọn, bắt buộc | Thuộc sơ đồ ghế của phòng chiếu; ít nhất 1 ghế; không quá 8 ghế, ghế đôi tính một ghế | Số ghế tối đa 8 do hệ thống kiểm | UC-005 Dữ liệu vào 1 STT 1; BR-05, BR-06 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Các ghế đã chọn | Nhấn Xác nhận chọn ghế | Bắt buộc ít nhất 1 ghế (nút vô hiệu khi chưa chọn) --> ghế thuộc sơ đồ (ô chọn chỉ sinh từ sơ đồ) --> không quá 8 ghế (hệ thống) --> ghế còn trống (hệ thống) | MSG-10; MSG-11 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-04 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Dải trạng thái kết nối, MSG-26, đếm ghế đã chọn (UI-STT 40, 41) | - |
| SCR-04 | Nielsen 5 Ngăn lỗi | Đạt | Ghế đang giữ, đã bán không chọn được; nút vô hiệu khi chưa chọn ghế | - |
| SCR-04 | WCAG 1.4.1 Không dùng màu làm tín hiệu duy nhất | Đạt | Bốn trạng thái ghế khác nhau cả biểu tượng, hoạ tiết, chữ (UI-STT 39) | - |
| SCR-04 | WCAG 1.4.10 Reflow | Không áp dụng | Sơ đồ ghế là nội dung hai chiều, cuộn ngang trong khung | Ghi ở UI-STT 39 |
| SCR-04 | WCAG 2.1.1 Bàn phím | Đạt | Lưới ghế dùng phím mũi tên và Space (UI-STT 26) | - |
| SCR-04 | WCAG 4.1.3 Thông điệp trạng thái | Đạt | Thay đổi ghế được gộp thành thông báo role=status (UI-STT 40) | - |
| SCR-04 | Baymard / Nielsen 6 | Đạt | Giữ lựa chọn khi đăng nhập và khi bị từ chối ở 6a, 7a | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-15, 21, 27-29, 33-35.

## h) Thông điệp mới

Không có.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có. Câu hỏi liên quan đã ghi ở ui-standards.md: Q-119, Q-123. Q-119: MSG-09 đưa khách về SCR-02, nơi có dải Tiếp tục thanh toán mở SCR-05.

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-B-BookTicketsForm | updateSeatMap chỉ nêu cập nhật sơ đồ; chưa có trách nhiệm hiển thị trạng thái mất kết nối và tải lại | Ghi trách nhiệm hiển thị trạng thái kết nối trong ghi chú của updateSeatMap (chi tiết ở DC-SeatMapSyncClient của P10) |

## Vấn đề còn mở

Ngưỡng 3 giây phụ thuộc kết quả đo T1 đến T5 của P09 (không thuộc giao diện).
