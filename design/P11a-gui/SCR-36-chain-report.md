# P11a - SCR-36 Báo cáo toàn chuỗi (Chain report) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-016 1.2 (bước 1-6, luồng 1a, 2a, Dữ liệu vào 1, Dữ liệu ra 1, 2, BR-77, BR-88, BR-115 đến BR-119); P05 GL-04, GL-55, GL-66; P07 UC-016; P08-analysis-model.md 2.0 (F3); P09-architecture.md 2.0 (Q-268, Q-269); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-36 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-36 |
| UC | UC-016 |
| Bước UC | 1, 2, 3, 4, 5, 6; luồng 1a, 2a |
| Tác nhân | ACT-05 Quản lý chuỗi |
| Boundary AC | AC-B-ViewChainReportForm (requestChainReport, notifyInvalidPeriod, notifyNoShowtimes, showChainReport) |
| DC | DC-ViewChainReportView, DC-ViewChainReportStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-31 (E-59) |
| Đi tới | Không có (màn hình kết thúc, thoát bằng menu tới SCR-31) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------------+
| CineBook   Trang chủ                                 [ Đăng xuất ] |
|------------------------------------------------------------------|
| Báo cáo toàn chuỗi                                                 |
| (vùng thông điệp: MSG-114, MSG-117, MSG-134, MSG-72, MSG-73)       |
| * là bắt buộc                                                      |
| Cách xem *  ( ) Theo ngày  (x) Theo phim  ( ) Theo suất chiếu       |
| Từ ngày *  [ 01/11/2026 ]   Đến ngày *  [ 30/11/2026 ]             |
|              dd/MM/yyyy                  [ Xem báo cáo ]            |
| Kỳ báo cáo: 01/11/2026 đến 30/11/2026, theo phim                    |
| Toàn chuỗi                                                          |
| Phim   | Doanh thu     | Tỉ lệ lấp đầy                              |
| Phim A | 24.500.000 đ  | 60,0%                                      |
| Phim B | 11.500.000 đ  | 33,3%                                      |
| So sánh giữa các cụm rạp                                            |
| Phim A | Cụm rạp           | Doanh thu     | Tỉ lệ lấp đầy          |
|        | CineBook Cầu Giấy |  14.700.000 đ | 64,0%                  |
|        | CineBook Bà Triệu |   9.800.000 đ | 55,0%                  |
|        | CineBook Thủ Đức  |           0 đ | không áp dụng          |
| Phim B | CineBook Cầu Giấy |   8.200.000 đ | 40,0%                  |
|        | CineBook Bà Triệu |   3.300.000 đ | 25,0%                  |
|        | CineBook Thủ Đức  |           0 đ | không áp dụng          |
+------------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Báo cáo toàn chuỗi" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-114, MSG-117, MSG-134, MSG-72, MSG-73 | Dưới tiêu đề | UI-STT 08 |
| Điều kiện xem | Cách xem, Từ ngày, Đến ngày, nút Xem báo cáo | Đầu nội dung | UC-016 Dữ liệu vào 1 |
| Kết quả toàn chuỗi | Bảng nhóm, doanh thu toàn chuỗi, tỉ lệ lấp đầy toàn chuỗi | Dưới điều kiện xem | UC-016 Dữ liệu ra 1; UI-STT 53 |
| Kết quả so sánh | Với mỗi nhóm, mọi cụm rạp cạnh nhau: doanh thu, tỉ lệ lấp đầy | Dưới kết quả toàn chuỗi | UC-016 Dữ liệu ra 2; UI-STT 53 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện biểu mẫu, chưa có kết quả; các trường để trống (đặc tả không có kỳ mặc định) | UC-016 bước 1 |
| 2 | Nút chọn Cách xem | Nút chọn | Chọn | Chọn Theo ngày, Theo phim hoặc Theo suất chiếu | UC-016 Dữ liệu vào 1 STT 1 |
| 3 | Ô Từ ngày, ô Đến ngày | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) rồi định dạng dd/MM/yyyy (MSG-97). Hai ngày đều thuộc kỳ | UC-016 Dữ liệu vào 1 STT 2, 3; GL-66; MSG-97 |
| 4 | Nút Xem báo cáo | Nút chính | Nhấn | Kiểm các trường (UI-STT 19); Từ ngày sau Đến ngày: MSG-114 ở lại. Gửi lên hệ thống, nút đổi thành MSG-134 trong lúc tính (UI-STT 27). Hệ thống từ chối kỳ không hợp lệ: MSG-114. Không có suất chiếu nào của chuỗi trong kỳ, kể cả suất đã xoá: MSG-117, không hiện bảng. Có: hiện hai bảng | UC-016 bước 1-6, luồng 1a, 2a; Q-181, Q-236; MSG-114, MSG-117, MSG-134 |
| 5 | Bảng Toàn chuỗi | Bảng | Khởi tạo | Mỗi hàng một nhóm theo cách xem: nhóm báo cáo, doanh thu toàn chuỗi, tỉ lệ lấp đầy toàn chuỗi. Nhóm là suất chiếu thì ghi cả tên cụm rạp | UC-016 Dữ liệu ra 1 STT 1-3 |
| 6 | Bảng So sánh giữa các cụm rạp | Bảng | Khởi tạo | Với mỗi nhóm, liệt kê mọi cụm rạp của chuỗi cạnh nhau với doanh thu và tỉ lệ lấp đầy của nhóm tại cụm rạp. Cụm rạp không có số liệu trong nhóm hiện 0 đ và "không áp dụng". Không xếp hạng, không tính chênh lệch, không có chọn tập con cụm rạp | UC-016 bước 5, Dữ liệu ra 2; Q-185, Q-237 |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Cách xem báo cáo | - | Lựa chọn | Chọn, bắt buộc | Theo ngày, theo phim hoặc theo suất chiếu | - | UC-016 Dữ liệu vào 1 STT 1 |
| Từ ngày | 10 | Ngày | Nhập, bắt buộc, căn trái | dd/MM/yyyy; không sau Đến ngày | Gợi ý định dạng dưới nhãn | UC-016 Dữ liệu vào 1 STT 2; Q-181 |
| Đến ngày | 10 | Ngày | Nhập, bắt buộc, căn trái | dd/MM/yyyy; không trước Từ ngày | Gợi ý định dạng dưới nhãn | UC-016 Dữ liệu vào 1 STT 3; Q-181 |
| Nhóm báo cáo | - | Chữ | Hiển thị, căn trái | Ngày dd/MM/yyyy; tên phim; hoặc tên phim, tên cụm rạp, tên phòng chiếu, dd/MM/yyyy HH:mm | - | UC-016 Dữ liệu ra 1 STT 1 |
| Doanh thu toàn chuỗi | 15 | Tiền | Hiển thị, căn phải | Số nguyên đồng, phân cách hàng nghìn bằng dấu chấm, kèm " đ"; bằng tổng doanh thu của các cụm rạp trong nhóm | Hệ thống tính (BR-77) | UC-016 Dữ liệu ra 1 STT 2; BR-77, BR-115, BR-119 |
| Tỉ lệ lấp đầy toàn chuỗi | 8 | Số | Hiển thị, căn phải | Phần trăm một chữ số thập phân, dấu phẩy; nhóm có sức chứa bằng 0 hiện "không áp dụng" | Thiết kế: UI-STT 53 | UC-016 Dữ liệu ra 1 STT 3; Q-235; BR-88 |
| Tên cụm rạp | - | Chữ | Hiển thị, căn trái | Mọi cụm rạp của chuỗi | - | UC-016 Dữ liệu ra 2 STT 1 |
| Doanh thu của cụm rạp | 15 | Tiền | Hiển thị, căn phải | Như doanh thu toàn chuỗi; 0 đ khi cụm rạp không có số liệu | - | UC-016 Dữ liệu ra 2 STT 2; Q-237 |
| Tỉ lệ lấp đầy của cụm rạp | 15 | Số | Hiển thị, căn phải | Như tỉ lệ lấp đầy toàn chuỗi; "không áp dụng" khi cụm rạp không có số liệu | - | UC-016 Dữ liệu ra 2 STT 3; Q-237 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Cách xem báo cáo | Nhấn Xem báo cáo | Bắt buộc | MSG-03 |
| Từ ngày, Đến ngày | Rời trường; nhấn Xem báo cáo | Bắt buộc --> định dạng dd/MM/yyyy --> Từ ngày không sau Đến ngày (cả ở hệ thống) | MSG-03; MSG-97; MSG-114 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-36 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-134 trong lúc tính; MSG-117 khi kỳ không có suất chiếu; dòng kỳ báo cáo nhắc điều kiện đang xem | - |
| SCR-36 | Nielsen 8 Thẩm mỹ, tối giản | Đạt | Hai bảng có tiêu đề rõ; không thêm xếp hạng hay biểu đồ ngoài đặc tả | - |
| SCR-36 | WCAG 1.3.1 Thông tin và quan hệ | Đạt | Bảng có hàng tiêu đề; mỗi hàng so sánh ghi tên nhóm (UI-STT 18, 53) | - |
| SCR-36 | WCAG 1.4.4, 1.4.10 | Đạt | Dưới 600 px mỗi hàng thành thẻ có nhãn trường (UI-STT 18) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-21, 27-28, 31, 33-35, 49.

## h) Thông điệp mới

Không có. MSG-114, MSG-117, MSG-134 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Ngưỡng thời gian hiện báo cáo (10 giây cho kỳ 31 ngày, Q-269) do P09 quản lý; màn hình chỉ hiện chỉ báo bận theo UI-STT 27.
