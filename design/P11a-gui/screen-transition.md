# P11a - Sơ đồ dịch chuyển màn hình - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (Toàn bộ: giai đoạn 1 và giai đoạn 2) |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | screen-list.md 1.0; ui-standards.md 1.0; P04 UC-005 1.8, UC-008 1.4, UC-009, UC-013 1.2, UC-014 1.3; P07 UC-005, UC-008 (message giữa tác nhân và boundary); 00-Conventions.md C7 |
| Phạm vi | Toàn hệ thống (20 màn hình, một trang sơ đồ) |
| Mã Q, ASM cuối đã cấp | Q-125; không có ASM (NGHIEM_NGAT) |

Sơ đồ: diagrams/P11a-screen-transition.drawio. Sơ đồ có 20 màn hình nên giữ một trang; chia partition theo tác nhân, thêm một partition dùng chung cho màn hình đăng nhập.

## Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (tác nhân) | Ghi chú |
|---|---|---|---|---|---|
| START-ACT-01 | Start | Bắt đầu | - | ACT-01 Khách | Mở ứng dụng hoặc chọn Đăng nhập (Q-123). Mọi màn hình có menu tới SCR-02, mẫu 1. Use case trước phiên (UC-001 Đăng ký tài khoản): chưa có boundary giao diện ở P08, P10 nên chưa có màn hình (Đề xuất sửa P08, P10; Q-123) |
| START-ACT-02 | Start | Bắt đầu | - | ACT-02 Nhân viên quầy | Sau khi có phiên làm việc (Q-123). Mọi màn hình có menu tới SCR-09, mẫu 1 |
| START-ACT-03 | Start | Bắt đầu | - | ACT-03 Nhân viên soát vé | Sau khi có phiên làm việc (Q-123). Không có màn hình điều hướng |
| START-ACT-04 | Start | Bắt đầu | - | ACT-04 Quản lý cụm rạp | Sau khi có phiên làm việc (Q-123). Mọi màn hình có menu tới SCR-17, mẫu 1 |
| P-ACT-00 | Partition | Dùng chung (ACT-01 đến ACT-04) | - | Dùng chung (ACT-01 đến ACT-04) | - |
| P-ACT-01 | Partition | ACT-01 Khách | - | ACT-01 Khách | - |
| P-ACT-02 | Partition | ACT-02 Nhân viên quầy | - | ACT-02 Nhân viên quầy | - |
| P-ACT-03 | Partition | ACT-03 Nhân viên soát vé | - | ACT-03 Nhân viên soát vé | - |
| P-ACT-04 | Partition | ACT-04 Quản lý cụm rạp | - | ACT-04 Quản lý cụm rạp | - |
| SCR-01 | Screen | Đăng nhập (Log in) | Độc lập | Dùng chung (ACT-01 đến ACT-04) | Đích của cạnh từ mọi Start (tiền điều kiện đã đăng nhập, căn cứ NFR-01 đến NFR-03). Mở dạng pop-up từ SCR-04 qua cạnh mẫu 2 |
| SCR-02 | Screen | Trang chủ khách (Customer home) | Độc lập | ACT-01 Khách | Màn hình điều hướng. Lối vào UC-001, UC-003, UC-004, UC-007: Chưa có màn hình đích (UC-001, UC-003, UC-004, UC-007), không tính là lối ra |
| SCR-03 | Screen | Chọn suất chiếu (Select showtime) | Độc lập | ACT-01 Khách | - |
| SCR-04 | Screen | Chọn ghế (Select seats) | Phụ thuộc có dữ liệu | ACT-01 Khách | Không vẽ cạnh đóng pop-up SCR-01; SCR-04 tự gửi lại xác nhận chọn ghế sau khi đăng nhập |
| SCR-05 | Screen | Giữ ghế và thanh toán (Hold seats and pay) | Phụ thuộc có dữ liệu | ACT-01 Khách | Rời màn hình qua menu hỏi MSG-77, lần giữ ghế vẫn chạy |
| SCR-06 | Screen | Kết quả đặt vé (Booking result) | Phụ thuộc có dữ liệu | ACT-01 Khách | Màn hình kết thúc, thoát bằng menu hoặc nút Về trang chủ tới SCR-02 |
| SCR-07 | Screen | Chọn vé cần huỷ (Select ticket to cancel) | Độc lập | ACT-01 Khách | - |
| SCR-08 | Screen | Kết quả huỷ vé (Cancellation result) | Phụ thuộc có dữ liệu | ACT-01 Khách | Màn hình kết thúc, thoát bằng menu hoặc nút Về trang chủ tới SCR-02 |
| SCR-09 | Screen | Trang chủ quầy (Counter home) | Độc lập | ACT-02 Nhân viên quầy | Màn hình điều hướng |
| SCR-10 | Screen | Chọn suất và ghế tại quầy (Select showtime and seats at counter) | Độc lập | ACT-02 Nhân viên quầy | - |
| SCR-11 | Screen | Giữ ghế và thu tiền mặt (Hold seats and collect cash) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | Rời màn hình qua menu hỏi MSG-77, lần giữ ghế vẫn chạy |
| SCR-12 | Screen | In vé tại quầy (Print tickets at counter) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | Màn hình kết thúc, thoát bằng menu tới SCR-09 |
| SCR-13 | Screen | Tìm vé theo mã đặt vé (Find tickets by booking code) | Độc lập | ACT-02 Nhân viên quầy | - |
| SCR-14 | Screen | Hoàn tiền mặt (Cash refund) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | - |
| SCR-15 | Screen | Kết quả huỷ vé tại quầy (Counter cancellation result) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | Màn hình kết thúc, thoát bằng menu tới SCR-09 |
| SCR-16 | Screen | Soát vé (Check ticket) | Độc lập | ACT-03 Nhân viên soát vé | Màn hình kết thúc: nhân viên soát vé chỉ có UC-009, vòng lặp quét nằm trong màn hình |
| SCR-17 | Screen | Trang chủ quản lý cụm rạp (Cinema manager home) | Độc lập | ACT-04 Quản lý cụm rạp | Màn hình điều hướng. Lối vào UC-012, UC-015: Chưa có màn hình đích (UC-012, UC-015), không tính là lối ra |
| SCR-18 | Screen | Bảng giá cụm rạp (Cinema price list) | Độc lập | ACT-04 Quản lý cụm rạp | Màn hình kết thúc, thoát bằng menu tới SCR-17 |
| SCR-19 | Screen | Danh sách suất chiếu (Showtime list) | Độc lập | ACT-04 Quản lý cụm rạp | - |
| SCR-20 | Screen | Lập hoặc sửa suất chiếu (Create or edit showtime) | Con phụ thuộc | ACT-04 Quản lý cụm rạp | Pop-up đóng ngầm định về SCR-19, không vẽ cạnh đóng |

## Bảng Edge

| ID | Nguồn | Đích | Mẫu dịch chuyển | Sự kiện kích hoạt | Điều kiện | Dữ liệu truyền | UC bước |
|---|---|---|---|---|---|---|---|
| E-01 | START-ACT-01 | SCR-02 | 1 Đơn giản | Mở ứng dụng | Khách chưa hoặc đã đăng nhập | - | UC-005 bước 1 |
| E-02 | START-ACT-01 | SCR-01 | 1 Đơn giản | Chọn Đăng nhập | Chưa có phiên | - | UC-008 tiền điều kiện |
| E-03 | START-ACT-02 | SCR-01 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-005 tiền điều kiện (REQ-102) |
| E-04 | START-ACT-03 | SCR-01 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-009 tiền điều kiện (REQ-102) |
| E-05 | START-ACT-04 | SCR-01 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-013, UC-014 tiền điều kiện (REQ-102) |
| E-06 | SCR-01 | SCR-02 | 1 Đơn giản | Đăng nhập thành công | Vai trò khách | - | UC-005 luồng 5a2; NFR-01 |
| E-07 | SCR-01 | SCR-09 | 1 Đơn giản | Đăng nhập thành công | Vai trò nhân viên quầy | - | NFR-02 |
| E-08 | SCR-01 | SCR-16 | 1 Đơn giản | Đăng nhập thành công | Vai trò nhân viên soát vé | - | NFR-02 |
| E-09 | SCR-01 | SCR-17 | 1 Đơn giản | Đăng nhập thành công | Vai trò quản lý cụm rạp | - | NFR-02 |
| E-10 | SCR-02 | SCR-03 | 1 Đơn giản | Chọn thẻ Đặt vé | - | - | UC-005 bước 1 |
| E-11 | SCR-02 | SCR-07 | 1 Đơn giản | Chọn thẻ Huỷ vé | Đã có phiên | - | UC-008 bước 1 |
| E-12 | SCR-02 | SCR-01 | 1 Đơn giản | Chọn thẻ Huỷ vé | Chưa có phiên | - | UC-008 tiền điều kiện |
| E-13 | SCR-03 | SCR-04 | 4 Phụ thuộc có dữ liệu | Chọn suất chiếu | Suất đã mở bán, chưa bắt đầu | Suất chiếu đã chọn | UC-005 bước 1, 2 |
| E-14 | SCR-04 | SCR-01 | 2 Con phụ thuộc | Xác nhận chọn ghế | Chưa đăng nhập | - | UC-005 luồng 5a1 |
| E-15 | SCR-04 | SCR-05 | 4 Phụ thuộc có dữ liệu | Xác nhận chọn ghế | Giữ được cả nhóm ghế | Lần giữ ghế (ghế, giá vé, tổng tiền, thời điểm hết hạn) | UC-005 bước 5-8 |
| E-16 | SCR-04 | SCR-02 | 1 Đơn giản | Xác nhận chọn ghế | Bị từ chối ở 5b, 7c, 7e | - | UC-005 luồng 5b, 7c, 7e |
| E-17 | SCR-04 | SCR-03 | 1 Đơn giản | Xác nhận chọn ghế | Suất đã đổi hoặc không còn (7d) | - | UC-005 luồng 7d |
| E-18 | SCR-05 | SCR-06 | 4 Phụ thuộc có dữ liệu | Thanh toán qua VNPay xong, trình duyệt quay về | Trước thời điểm hết hạn hoặc sau | Giao dịch thanh toán (trạng thái đọc từ hệ thống) | UC-005 bước 9-11, 15 |
| E-19 | SCR-05 | SCR-02 | 1 Đơn giản | Huỷ giữ ghế hoặc hết thời gian giữ ghế | Xác nhận huỷ, hoặc đồng hồ về 00:00 | - | UC-005 luồng *a, 7b |
| E-20 | SCR-07 | SCR-08 | 4 Phụ thuộc có dữ liệu | Xác nhận huỷ vé | Vé hợp lệ để huỷ | Vé đã huỷ | UC-008 bước 1-8 |
| E-21 | SCR-09 | SCR-10 | 1 Đơn giản | Chọn thẻ Bán vé | - | - | UC-005 bước 1 |
| E-22 | SCR-09 | SCR-13 | 1 Đơn giản | Chọn thẻ Huỷ vé | - | - | UC-008 luồng 1a |
| E-23 | SCR-10 | SCR-11 | 4 Phụ thuộc có dữ liệu | Xác nhận chọn ghế | Giữ được cả nhóm ghế | Lần giữ ghế (ghế, giá vé, tổng tiền, thời điểm hết hạn) | UC-005 bước 5-8 |
| E-24 | SCR-10 | SCR-09 | 1 Đơn giản | Xác nhận chọn ghế | Bị từ chối ở 5b, 7c, 7e | - | UC-005 luồng 5b, 7c, 7e |
| E-25 | SCR-11 | SCR-12 | 4 Phụ thuộc có dữ liệu | Xác nhận đã thu tiền mặt | Xác nhận tới trước hạn | Mã đặt vé và các vé | UC-005 luồng 9a1-9a4 |
| E-26 | SCR-11 | SCR-09 | 1 Đơn giản | Huỷ giữ ghế, hết thời gian hoặc xác nhận trễ | Xác nhận huỷ, đồng hồ về 00:00, hoặc 9a1a | - | UC-005 luồng *a, 7b, 9a1a |
| E-27 | SCR-13 | SCR-14 | 4 Phụ thuộc có dữ liệu | Xác nhận huỷ vé | Vé mua tại quầy của cụm mình, hợp lệ để huỷ | Vé đã huỷ | UC-008 bước 1a3, 2-4, 5a1 |
| E-28 | SCR-14 | SCR-15 | 4 Phụ thuộc có dữ liệu | Xác nhận đã hoàn tiền mặt | - | Khoản hoàn tiền mặt của vé | UC-008 bước 5a2, 7, 8 |
| E-29 | SCR-17 | SCR-18 | 1 Đơn giản | Chọn thẻ Quản lý bảng giá | - | - | UC-013 bước 1 |
| E-30 | SCR-17 | SCR-19 | 1 Đơn giản | Chọn thẻ Lập lịch suất chiếu | - | - | UC-014 bước 1 |
| E-31 | SCR-19 | SCR-20 | 2 Con phụ thuộc | Lập mới hoặc Sửa | Khi sửa: suất đạt kiểm 1a3 | Suất chiếu cần sửa (khi sửa) | UC-014 bước 1, luồng 1a |

## Kiểm tra

- Mọi màn hình đến được từ một Start: SCR-02 từ START-ACT-01 (E-01); SCR-01 từ bốn Start; SCR-09, SCR-16, SCR-17 từ SCR-01 (E-07 đến E-09); SCR-03 đến SCR-08 từ SCR-02; SCR-10 đến SCR-15 từ SCR-09; SCR-18 đến SCR-20 từ SCR-17.
- Mọi màn hình có lối ra: có cạnh đi (SCR-01 đến SCR-05, SCR-07, SCR-09 đến SCR-11, SCR-13, SCR-14, SCR-17, SCR-19), là pop-up đóng về cha (SCR-20), hoặc là màn hình kết thúc đã ghi ở Ghi chú (SCR-06, SCR-08, SCR-12, SCR-15, SCR-16, SCR-18).
- Không có cạnh đóng pop-up: SCR-01 mở dạng pop-up từ SCR-04 (E-14) và SCR-20 mở từ SCR-19 (E-31), việc đóng là ngầm định.
- Thông điệp ngắn (lỗi, xác nhận có hoặc không) dùng hộp thông điệp chuẩn của ui-standards.md, không thành màn hình.
- Từ chối ở màn hình danh sách (SCR-03, SCR-07, SCR-13, SCR-18, SCR-19) ở lại màn hình theo UI-STT 29(2) nên không có cạnh.
- Lối vào chưa có màn hình đích nằm ở Ghi chú của SCR-02 và SCR-17 (UC-001, UC-003, UC-004, UC-007; UC-012, UC-015).

## Câu hỏi mở

Xem ui-standards.md: Q-119 đến Q-125 (mã tạm). Liên quan sơ đồ này: Q-123 (điểm khởi đầu của từng tác nhân), Q-119 (không có cạnh quay lại lần giữ ghế đang chạy).

## Đề xuất sửa artifact trước

Xem screen-list.md: P10 (View đăng nhập và điều hướng), P08 và P10 (boundary UC-001).

## Vấn đề còn mở

1. Điểm khởi đầu chờ Q-123; cạnh E-01, E-02 phản ánh hai lối vào của khách (mở ứng dụng, chọn Đăng nhập).
2. Cạnh E-18 đi qua cổng VNPay (ngoài hệ thống): trình duyệt rời ứng dụng, thanh toán, rồi quay về địa chỉ trả về là SCR-06.
