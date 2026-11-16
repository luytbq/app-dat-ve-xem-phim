# P11a - SCR-30 Báo cáo cụm rạp (Cinema report) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | ui-standards.md 2.0; screen-list.md 2.0; screen-transition.md 2.0; P04 UC-015 1.2 (bước 1-5, luồng 1a, 2a, Dữ liệu vào 1, Dữ liệu ra 1, BR-77, BR-88, BR-114 đến BR-119); P05 GL-04, GL-55, GL-66; P07 UC-015; P08-analysis-model.md 2.0 (F3); P09-architecture.md 2.0 (Q-268, Q-269); P10-design-elements.md 2.0 (F3, F4). Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | SCR-30 |
| Mã Q, ASM cuối đã cấp | Q-276; không có ASM (NGHIEM_NGAT) |

## b) Thông tin chung

| Mục | Giá trị |
|---|---|
| SCR | SCR-30 |
| UC | UC-015 |
| Bước UC | 1, 2, 3, 4, 5; luồng 1a, 2a |
| Tác nhân | ACT-04 Quản lý cụm rạp |
| Boundary AC | AC-B-ViewCinemaReportForm (requestCinemaReport, notifyInvalidPeriod, notifyNoShowtimes, showReport) |
| DC | DC-ViewCinemaReportView, DC-ViewCinemaReportStore |
| Loại màn hình | Độc lập |
| Đến từ | SCR-17 (E-54) |
| Đi tới | Không có (màn hình kết thúc, thoát bằng menu tới SCR-17) |

## c) Hình ảnh màn hình

```text
+------------------------------------------------------------+
| CineBook   Trang chủ                         [ Đăng xuất ]   |
|------------------------------------------------------------|
| Báo cáo cụm rạp                                              |
| (vùng thông điệp: MSG-114, MSG-116, MSG-134, MSG-72, MSG-73) |
| * là bắt buộc                                                |
| Cách xem *  (x) Theo ngày  ( ) Theo phim  ( ) Theo suất chiếu |
| Từ ngày *  [ 01/11/2026 ]   Đến ngày *  [ 30/11/2026 ]       |
|              dd/MM/yyyy                  [ Xem báo cáo ]      |
| Kỳ báo cáo: 01/11/2026 đến 30/11/2026, theo phim              |
| Phim   | Doanh thu     | Tỉ lệ lấp đầy                        |
|--------+---------------+--------------                        |
| Phim A | 14.700.000 đ  | 64,0%                                |
| Phim B |  8.200.000 đ  | 40,0%                                |
+------------------------------------------------------------+
```

| Vùng | Nội dung | Vị trí | Ghi chú |
|---|---|---|---|
| Đầu trang | Tên ứng dụng, Trang chủ, Đăng xuất | Trên cùng | UI-STT 22 |
| Tiêu đề | h1 "Báo cáo cụm rạp" | Dưới đầu trang | UI-STT 09 |
| Thông điệp | MSG-114, MSG-116, MSG-134, MSG-72, MSG-73 | Dưới tiêu đề | UI-STT 08 |
| Điều kiện xem | Cách xem, Từ ngày, Đến ngày, nút Xem báo cáo | Đầu nội dung | UC-015 Dữ liệu vào 1 |
| Kết quả | Dòng kỳ báo cáo và cách xem; bảng nhóm, doanh thu, tỉ lệ lấp đầy | Dưới điều kiện xem | UC-015 Dữ liệu ra 1; UI-STT 53 |

Mockup HTML: Không có (XUAT_HTML = Không).

## d) Danh sách chức năng

| STT | Điều khiển (Control) | Loại | Thao tác (Operation) | Chức năng (Function) | Nguồn |
|---|---|---|---|---|---|
| 1 | Màn hình | Vùng hiển thị | Khởi tạo | Hiện biểu mẫu, chưa có kết quả; các trường để trống (đặc tả không có kỳ mặc định). Báo cáo là của cụm rạp mà quản lý thuộc về | UC-015 bước 1; BR-114 |
| 2 | Nút chọn Cách xem | Nút chọn | Chọn | Chọn Theo ngày, Theo phim hoặc Theo suất chiếu | UC-015 Dữ liệu vào 1 STT 1 |
| 3 | Ô Từ ngày, ô Đến ngày | Ô nhập | Rời trường | Kiểm bắt buộc (MSG-03) rồi định dạng dd/MM/yyyy (MSG-97). Hai ngày đều thuộc kỳ | UC-015 Dữ liệu vào 1 STT 2, 3; GL-66; MSG-97 |
| 4 | Nút Xem báo cáo | Nút chính | Nhấn | Kiểm các trường (UI-STT 19); Từ ngày sau Đến ngày: MSG-114 ở lại. Gửi lên hệ thống, nút đổi thành MSG-134 trong lúc tính (UI-STT 27). Hệ thống từ chối kỳ không hợp lệ: MSG-114. Không có suất chiếu nào của cụm rạp trong kỳ, kể cả suất đã xoá: MSG-116, không hiện bảng. Có: hiện bảng | UC-015 bước 1-5, luồng 1a, 2a; Q-181, Q-236; MSG-114, MSG-116, MSG-134 |
| 5 | Bảng Báo cáo | Bảng | Khởi tạo | Mỗi hàng một nhóm theo cách xem: ngày (dd/MM/yyyy), phim (tên phim) hoặc suất chiếu (tên phim, tên phòng chiếu, ngày giờ bắt đầu). Cột Doanh thu và Tỉ lệ lấp đầy. Sắp theo ngày hoặc giờ bắt đầu tăng dần; theo phim sắp theo tên phim | UC-015 Dữ liệu ra 1; Thiết kế: thứ tự trình bày |

## e) Định nghĩa thuộc tính trường

| Mục (Item name) | Số ký tự tối đa | Kiểu | Thuộc tính trường | Ràng buộc dữ liệu | Ghi chú | Nguồn |
|---|---|---|---|---|---|---|
| Cách xem báo cáo | - | Lựa chọn | Chọn, bắt buộc | Theo ngày, theo phim hoặc theo suất chiếu | - | UC-015 Dữ liệu vào 1 STT 1 |
| Từ ngày | 10 | Ngày | Nhập, bắt buộc, căn trái | dd/MM/yyyy; không sau Đến ngày | Gợi ý định dạng dưới nhãn | UC-015 Dữ liệu vào 1 STT 2; Q-181 |
| Đến ngày | 10 | Ngày | Nhập, bắt buộc, căn trái | dd/MM/yyyy; không trước Từ ngày | Gợi ý định dạng dưới nhãn | UC-015 Dữ liệu vào 1 STT 3; Q-181 |
| Nhóm báo cáo | - | Chữ | Hiển thị, căn trái | Ngày dd/MM/yyyy; tên phim; hoặc tên phim, tên phòng chiếu, dd/MM/yyyy HH:mm | - | UC-015 Dữ liệu ra 1 STT 1 |
| Doanh thu | 15 | Tiền | Hiển thị, căn phải | Số nguyên đồng, phân cách hàng nghìn bằng dấu chấm, kèm " đ" (12.450.000 đ); tiền vé đã bán trừ phần đã hoàn | Hệ thống tính (BR-77) | UC-015 Dữ liệu ra 1 STT 2; BR-77, BR-115, BR-119 |
| Tỉ lệ lấp đầy | 8 | Số | Hiển thị, căn phải | Phần trăm một chữ số thập phân, dấu phẩy (62,5%); nhóm có sức chứa bằng 0 hiện "không áp dụng" | Số chữ số thập phân là Thiết kế (UI-STT 53) | UC-015 Dữ liệu ra 1 STT 3; Q-235; BR-88 |

## f) Kiểm tra dữ liệu nhập

| Trường | Thời điểm kiểm tra | Kiểm tra | MSG khi lỗi |
|---|---|---|---|
| Cách xem báo cáo | Nhấn Xem báo cáo | Bắt buộc | MSG-03 |
| Từ ngày, Đến ngày | Rời trường; nhấn Xem báo cáo | Bắt buộc --> định dạng dd/MM/yyyy --> Từ ngày không sau Đến ngày (cả ở hệ thống) | MSG-03; MSG-97; MSG-114 |

## g) Đánh giá chuẩn

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-30 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-134 trong lúc tính; MSG-116 khi kỳ không có suất chiếu; dòng kỳ báo cáo nhắc điều kiện đang xem | - |
| SCR-30 | Nielsen 2 Khớp thế giới thực | Đạt | Nhóm không có sức chứa hiện "không áp dụng" thay vì 0% hoặc lỗi chia cho 0 (UI-STT 53) | - |
| SCR-30 | Nielsen 6 Nhận biết thay vì nhớ lại | Đạt | Điều kiện xem vẫn hiện trên bảng kết quả | - |
| SCR-30 | WCAG 1.3.1 Thông tin và quan hệ | Đạt | Bảng có hàng tiêu đề; cột số căn phải (UI-STT 18, 53) | - |
| SCR-30 | WCAG 3.3.2 Nhãn hoặc hướng dẫn | Đạt | Gợi ý dd/MM/yyyy dưới nhãn hai ngày (UI-STT 49) | - |

Các tiêu chí còn lại: Đạt theo ui-standards.md STT 05-09, 12-21, 27-28, 31, 33-35.

## h) Thông điệp mới

Không có. MSG-114, MSG-116, MSG-134 cấp ở ui-standards.md.

## i) Ngoại lệ của quy định chuẩn

Không có.

## Câu hỏi mở

Không có.

## Đề xuất sửa artifact trước

Không có.

## Vấn đề còn mở

Ngưỡng thời gian hiện báo cáo (5 giây cho kỳ 31 ngày, Q-269) do P09 quản lý; màn hình chỉ hiện chỉ báo bận theo UI-STT 27.
