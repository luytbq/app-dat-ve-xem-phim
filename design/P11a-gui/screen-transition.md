# P11a - Sơ đồ dịch chuyển màn hình - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (Toàn bộ: giai đoạn 1 và giai đoạn 2) |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Mở rộng cho đủ 16 use case: thêm SCR-21 đến SCR-40, hai node Start và hai partition của ACT-05, ACT-06, cạnh E-35 đến E-63; E-03 đến E-05 và E-07 đến E-09 chuyển sang SCR-21 (hai điểm đăng nhập, Q-267); E-17 thêm điều kiện chưa mở bán; sơ đồ tách mỗi tác nhân một trang vì quá 20 màn hình |
| Đầu vào đã dùng | screen-list.md 2.0; ui-standards.md 2.0; P02-usecases.md 1.9; P04 UC-001 1.2, UC-003 1.1, UC-004 1.2, UC-005 1.15, UC-007 1.2, UC-008 1.10, UC-009 1.7, UC-010 1.2, UC-011 1.2, UC-012 1.2, UC-013 1.5, UC-014 1.7, UC-015 1.2, UC-016 1.2, UC-017 1.2; P07 (message giữa tác nhân và boundary của 16 use case); P09-architecture.md 2.0 (F7.11, Q-267); P10-design-elements.md 2.0 (F3, F4, Q-271); 00-Conventions.md C7. Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | Toàn hệ thống (40 màn hình, sáu trang sơ đồ, mỗi tác nhân một trang) |
| Mã Q, ASM cuối đã cấp | Q-276 (dải Q-272 đến Q-281 của phiên); không có ASM (NGHIEM_NGAT) |

Sơ đồ: diagrams/P11a-screen-transition.drawio, sáu trang P11a-ACT-01 đến P11a-ACT-06. Sơ đồ có 40 màn hình nên mỗi tác nhân một trang; mỗi trang có partition đăng nhập dùng chung (SCR-21, trang ACT-01 còn có SCR-01) và partition của tác nhân. Cạnh nào có cả hai đầu trong một trang thì vẽ trên trang đó.

## Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (tác nhân) | Ghi chú |
|---|---|---|---|---|---|
| START-ACT-01 | Start | Bắt đầu | - | ACT-01 Khách | Mở ứng dụng hoặc chọn Đăng nhập (Q-123). Mọi màn hình có menu tới SCR-02, mẫu 1 |
| START-ACT-02 | Start | Bắt đầu | - | ACT-02 Nhân viên quầy | Mở ứng dụng vào đăng nhập nhân viên (Q-123). Mọi màn hình có menu tới SCR-09, mẫu 1 |
| START-ACT-03 | Start | Bắt đầu | - | ACT-03 Nhân viên soát vé | Mở ứng dụng vào đăng nhập nhân viên (Q-123). Không có màn hình điều hướng |
| START-ACT-04 | Start | Bắt đầu | - | ACT-04 Quản lý cụm rạp | Mở ứng dụng vào đăng nhập nhân viên (Q-123). Mọi màn hình có menu tới SCR-17, mẫu 1 |
| START-ACT-05 | Start | Bắt đầu | - | ACT-05 Quản lý chuỗi | Mở ứng dụng vào đăng nhập nhân viên (Q-275). Mọi màn hình có menu tới SCR-31, mẫu 1 |
| START-ACT-06 | Start | Bắt đầu | - | ACT-06 Quản trị viên | Mở ứng dụng vào đăng nhập nhân viên (Q-275). Mọi màn hình có menu tới SCR-37, mẫu 1. Không có màn hình điều hướng vì quản trị viên chỉ có UC-017 |
| P-ACT-00 | Partition | Đăng nhập (ACT-01 đến ACT-06) | - | Đăng nhập (ACT-01 đến ACT-06) | - |
| P-ACT-01 | Partition | ACT-01 Khách | - | ACT-01 Khách | - |
| P-ACT-02 | Partition | ACT-02 Nhân viên quầy | - | ACT-02 Nhân viên quầy | - |
| P-ACT-03 | Partition | ACT-03 Nhân viên soát vé | - | ACT-03 Nhân viên soát vé | - |
| P-ACT-04 | Partition | ACT-04 Quản lý cụm rạp | - | ACT-04 Quản lý cụm rạp | - |
| P-ACT-05 | Partition | ACT-05 Quản lý chuỗi | - | ACT-05 Quản lý chuỗi | - |
| P-ACT-06 | Partition | ACT-06 Quản trị viên | - | ACT-06 Quản trị viên | - |
| SCR-01 | Screen | Đăng nhập khách (Log in as customer) | Độc lập | Đăng nhập (ACT-01 đến ACT-06) | Đích của cạnh từ START-ACT-01 khi chọn Đăng nhập (Q-123), từ SCR-02 khi chưa có phiên (E-12, E-49) và từ SCR-22 sau khi đăng ký thành công (E-42). Mở dạng pop-up từ SCR-04 qua cạnh mẫu 2 (E-14). Dạng trang có liên kết tới SCR-22 và SCR-21 (E-63, E-39). Phiên khách không còn hiệu lực đưa về SCR-01 kèm MSG-85, không vẽ cạnh |
| SCR-02 | Screen | Trang chủ khách (Customer home) | Độc lập | ACT-01 Khách | Màn hình điều hướng; dải giữ ghế mở lại SCR-05 (E-32). Lối vào UC-001, UC-003, UC-004, UC-007 mở SCR-22, SCR-23, SCR-25, SCR-26 |
| SCR-03 | Screen | Chọn suất chiếu (Select showtime) | Độc lập | ACT-01 Khách | - |
| SCR-04 | Screen | Chọn ghế (Select seats) | Phụ thuộc có dữ liệu | ACT-01 Khách | Không vẽ cạnh đóng pop-up SCR-01; SCR-04 tự gửi lại xác nhận chọn ghế sau khi đăng nhập. Từ chối vì suất chiếu đã đổi, không còn hoặc chưa mở bán (MSG-12, MSG-84) mở lại SCR-03 (E-17) |
| SCR-05 | Screen | Giữ ghế và thanh toán (Hold seats and pay) | Phụ thuộc có dữ liệu | ACT-01 Khách | Rời màn hình qua menu hỏi MSG-77, lần giữ ghế vẫn chạy và mở lại được từ SCR-02 (E-32) hoặc SCR-06 (E-34) |
| SCR-06 | Screen | Kết quả đặt vé (Booking result) | Phụ thuộc có dữ liệu | ACT-01 Khách | Địa chỉ trả về của VNPay. Lần giữ ghế còn Đang giữ thì có cạnh quay lại SCR-05 (E-34); ngược lại thoát bằng menu hoặc nút Về trang chủ tới SCR-02 |
| SCR-07 | Screen | Chọn vé cần huỷ (Select ticket to cancel) | Độc lập | ACT-01 Khách | - |
| SCR-08 | Screen | Kết quả huỷ vé (Cancellation result) | Phụ thuộc có dữ liệu | ACT-01 Khách | Màn hình kết thúc, thoát bằng menu hoặc nút Về trang chủ tới SCR-02 |
| SCR-09 | Screen | Trang chủ quầy (Counter home) | Độc lập | ACT-02 Nhân viên quầy | Màn hình điều hướng. Dải giữ ghế mở lại SCR-11 (E-33) |
| SCR-10 | Screen | Chọn suất và ghế tại quầy (Select showtime and seats at counter) | Độc lập | ACT-02 Nhân viên quầy | - |
| SCR-11 | Screen | Giữ ghế và thu tiền mặt (Hold seats and collect cash) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | Rời màn hình qua menu hỏi MSG-77, lần giữ ghế vẫn chạy |
| SCR-12 | Screen | In vé tại quầy (Print tickets at counter) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | Màn hình kết thúc, thoát bằng menu tới SCR-09 |
| SCR-13 | Screen | Tìm vé theo mã đặt vé (Find tickets by booking code) | Độc lập | ACT-02 Nhân viên quầy | - |
| SCR-14 | Screen | Hoàn tiền mặt (Cash refund) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | - |
| SCR-15 | Screen | Kết quả huỷ vé tại quầy (Counter cancellation result) | Phụ thuộc có dữ liệu | ACT-02 Nhân viên quầy | Màn hình kết thúc, thoát bằng menu tới SCR-09 |
| SCR-16 | Screen | Soát vé (Check ticket) | Độc lập | ACT-03 Nhân viên soát vé | Màn hình kết thúc: nhân viên soát vé chỉ có UC-009, vòng lặp quét nằm trong màn hình |
| SCR-17 | Screen | Trang chủ quản lý cụm rạp (Cinema manager home) | Độc lập | ACT-04 Quản lý cụm rạp | Màn hình điều hướng; mở SCR-18, SCR-19, SCR-28, SCR-30 |
| SCR-18 | Screen | Bảng giá cụm rạp (Cinema price list) | Độc lập | ACT-04 Quản lý cụm rạp | Màn hình kết thúc, thoát bằng menu tới SCR-17 |
| SCR-19 | Screen | Danh sách suất chiếu (Showtime list) | Độc lập | ACT-04 Quản lý cụm rạp | - |
| SCR-20 | Screen | Lập hoặc sửa suất chiếu (Create or edit showtime) | Con phụ thuộc | ACT-04 Quản lý cụm rạp | Pop-up đóng ngầm định về SCR-19, không vẽ cạnh đóng |
| SCR-21 | Screen | Đăng nhập nhân viên (Staff login) | Độc lập | Đăng nhập (ACT-01 đến ACT-06) | Đích của cạnh từ START-ACT-02 đến START-ACT-06 (tiền điều kiện đã đăng nhập, căn cứ NFR-02, NFR-03, Q-267). Phiên nhân viên không còn hiệu lực đưa mọi màn hình nhân viên về SCR-21 kèm MSG-85 (UI-STT 48), không vẽ cạnh |
| SCR-22 | Screen | Đăng ký tài khoản (Register account) | Độc lập | ACT-01 Khách | Màn hình trước phiên (UC-001); thành công mở SCR-01, huỷ yêu cầu về SCR-02 |
| SCR-23 | Screen | Danh sách phim (Movie list) | Độc lập | ACT-01 Khách | - |
| SCR-24 | Screen | Thông tin phim (Movie details) | Phụ thuộc có dữ liệu | ACT-01 Khách | Thoát bằng nút Quay lại danh sách phim (E-46) hoặc menu |
| SCR-25 | Screen | Tra cứu lịch chiếu (Browse showtimes) | Độc lập | ACT-01 Khách | Màn hình kết thúc, thoát bằng menu tới SCR-02; không có lối sang đặt vé (Q-272) |
| SCR-26 | Screen | Lịch sử đặt vé (Booking history) | Độc lập | ACT-01 Khách | - |
| SCR-27 | Screen | Vé của lần đặt (Booking tickets) | Phụ thuộc có dữ liệu | ACT-01 Khách | Thoát bằng nút Quay lại danh sách lịch sử (E-51) hoặc menu |
| SCR-28 | Screen | Danh sách phòng chiếu (Auditorium list) | Độc lập | ACT-04 Quản lý cụm rạp | - |
| SCR-29 | Screen | Lập hoặc sửa phòng chiếu (Create or edit auditorium) | Con phụ thuộc | ACT-04 Quản lý cụm rạp | Pop-up đóng ngầm định về SCR-28, không vẽ cạnh đóng |
| SCR-30 | Screen | Báo cáo cụm rạp (Cinema report) | Độc lập | ACT-04 Quản lý cụm rạp | Màn hình kết thúc, thoát bằng menu tới SCR-17 |
| SCR-31 | Screen | Trang chủ quản lý chuỗi (Chain manager home) | Độc lập | ACT-05 Quản lý chuỗi | Màn hình điều hướng; mở SCR-32, SCR-34, SCR-36 |
| SCR-32 | Screen | Danh sách phim của chuỗi (Chain movie list) | Độc lập | ACT-05 Quản lý chuỗi | - |
| SCR-33 | Screen | Thêm hoặc sửa phim (Create or edit movie) | Con phụ thuộc | ACT-05 Quản lý chuỗi | Pop-up đóng ngầm định về SCR-32, không vẽ cạnh đóng |
| SCR-34 | Screen | Danh sách cụm rạp (Cinema list) | Độc lập | ACT-05 Quản lý chuỗi | - |
| SCR-35 | Screen | Thêm hoặc sửa cụm rạp (Create or edit cinema) | Con phụ thuộc | ACT-05 Quản lý chuỗi | Pop-up đóng ngầm định về SCR-34, không vẽ cạnh đóng |
| SCR-36 | Screen | Báo cáo toàn chuỗi (Chain report) | Độc lập | ACT-05 Quản lý chuỗi | Màn hình kết thúc, thoát bằng menu tới SCR-31 |
| SCR-37 | Screen | Danh sách tài khoản nhân viên (Staff account list) | Độc lập | ACT-06 Quản trị viên | Màn hình đầu của quản trị viên, không có màn hình điều hướng |
| SCR-38 | Screen | Tạo hoặc cập nhật tài khoản nhân viên (Create or update staff account) | Con phụ thuộc | ACT-06 Quản trị viên | Pop-up đóng ngầm định về SCR-37, không vẽ cạnh đóng |
| SCR-39 | Screen | Sửa họ tên nhân viên (Edit staff full name) | Con phụ thuộc | ACT-06 Quản trị viên | Pop-up đóng ngầm định về SCR-37, không vẽ cạnh đóng |
| SCR-40 | Screen | Đặt lại mật khẩu nhân viên (Reset staff password) | Con phụ thuộc | ACT-06 Quản trị viên | Pop-up đóng ngầm định về SCR-37, không vẽ cạnh đóng |

## Bảng Edge

| ID | Nguồn | Đích | Mẫu dịch chuyển | Sự kiện kích hoạt | Điều kiện | Dữ liệu truyền | UC bước |
|---|---|---|---|---|---|---|---|
| E-01 | START-ACT-01 | SCR-02 | 1 Đơn giản | Mở ứng dụng | Khách chưa hoặc đã đăng nhập | - | UC-005 bước 1 |
| E-02 | START-ACT-01 | SCR-01 | 1 Đơn giản | Chọn Đăng nhập | Chưa có phiên | - | UC-007, UC-008 tiền điều kiện |
| E-03 | START-ACT-02 | SCR-21 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-005 tiền điều kiện (REQ-102) |
| E-04 | START-ACT-03 | SCR-21 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-009 tiền điều kiện (REQ-102) |
| E-05 | START-ACT-04 | SCR-21 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-013, UC-014 tiền điều kiện (REQ-102) |
| E-06 | SCR-01 | SCR-02 | 1 Đơn giản | Đăng nhập thành công | Vai trò khách | - | UC-005 luồng 5a2; NFR-01 |
| E-07 | SCR-21 | SCR-09 | 1 Đơn giản | Đăng nhập thành công | Vai trò nhân viên quầy | - | NFR-02 |
| E-08 | SCR-21 | SCR-16 | 1 Đơn giản | Đăng nhập thành công | Vai trò nhân viên soát vé | - | NFR-02 |
| E-09 | SCR-21 | SCR-17 | 1 Đơn giản | Đăng nhập thành công | Vai trò quản lý cụm rạp | - | NFR-02 |
| E-10 | SCR-02 | SCR-03 | 1 Đơn giản | Chọn thẻ Đặt vé | - | - | UC-005 bước 1 |
| E-11 | SCR-02 | SCR-07 | 1 Đơn giản | Chọn thẻ Huỷ vé | Đã có phiên | - | UC-008 bước 1 |
| E-12 | SCR-02 | SCR-01 | 1 Đơn giản | Chọn thẻ Huỷ vé | Chưa có phiên | - | UC-008 tiền điều kiện |
| E-13 | SCR-03 | SCR-04 | 4 Phụ thuộc có dữ liệu | Chọn suất chiếu | Suất đã mở bán, chưa bắt đầu | Suất chiếu đã chọn | UC-005 bước 1, 2 |
| E-14 | SCR-04 | SCR-01 | 2 Con phụ thuộc | Xác nhận chọn ghế | Chưa đăng nhập | - | UC-005 luồng 5a1 |
| E-15 | SCR-04 | SCR-05 | 4 Phụ thuộc có dữ liệu | Xác nhận chọn ghế | Giữ được cả nhóm ghế | Lần giữ ghế (ghế, giá vé, tổng tiền, thời điểm hết hạn) | UC-005 bước 5-8 |
| E-16 | SCR-04 | SCR-02 | 1 Đơn giản | Xác nhận chọn ghế | Bị từ chối ở 5b, 7c, 7e | - | UC-005 luồng 5b, 7c, 7e |
| E-17 | SCR-04 | SCR-03 | 1 Đơn giản | Xác nhận chọn ghế | Suất đã đổi hoặc không còn (7d), hoặc chưa mở bán lúc giữ ghế (BR-01) | - | UC-005 luồng 7d, 2a |
| E-18 | SCR-05 | SCR-06 | 4 Phụ thuộc có dữ liệu | Trình duyệt quay về địa chỉ trả về từ cổng VNPay (thanh toán xong hoặc khách bấm huỷ ở cổng) | Trước thời điểm hết hạn hoặc sau | Giao dịch thanh toán (trạng thái đọc từ hệ thống) | UC-005 bước 9-11, 15 |
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
| E-32 | SCR-02 | SCR-05 | 4 Phụ thuộc có dữ liệu | Chọn nút Tiếp tục thanh toán trong dải giữ ghế | Có lần giữ ghế đang chạy (BR-04) | Lần giữ ghế đang chạy (nạp từ máy chủ) | UC-005 bước 8; luồng 5b, 7c |
| E-33 | SCR-09 | SCR-11 | 4 Phụ thuộc có dữ liệu | Chọn nút Tiếp tục thanh toán trong dải giữ ghế | Có lần giữ ghế đang chạy (BR-04) | Lần giữ ghế đang chạy (nạp từ máy chủ) | UC-005 bước 8, 9a1; luồng 5b, 7c |
| E-34 | SCR-06 | SCR-05 | 4 Phụ thuộc có dữ liệu | Chọn nút Quay lại thanh toán | Lần giữ ghế còn Đang giữ, chưa có kết quả | Lần giữ ghế đang chạy (nạp từ máy chủ) | UC-005 bước 10, 11; luồng 7b; BR-90 |
| E-35 | START-ACT-05 | SCR-21 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-010, UC-011, UC-016 tiền điều kiện (REQ-102) |
| E-36 | START-ACT-06 | SCR-21 | 1 Đơn giản | Mở ứng dụng | Chưa có phiên | - | UC-017 tiền điều kiện (REQ-104) |
| E-37 | SCR-21 | SCR-31 | 1 Đơn giản | Đăng nhập thành công | Vai trò quản lý chuỗi | - | NFR-02 |
| E-38 | SCR-21 | SCR-37 | 1 Đơn giản | Đăng nhập thành công | Tài khoản quản trị viên | - | NFR-03 |
| E-39 | SCR-01 | SCR-21 | 1 Đơn giản | Chọn liên kết Đăng nhập dành cho nhân viên | Dạng trang | - | P09 Q-267 |
| E-40 | SCR-21 | SCR-01 | 1 Đơn giản | Chọn liên kết Đăng nhập khách | - | - | P09 Q-267 |
| E-41 | SCR-02 | SCR-22 | 1 Đơn giản | Chọn thẻ Đăng ký tài khoản | Chưa có phiên | - | UC-001 bước 1 |
| E-42 | SCR-22 | SCR-01 | 1 Đơn giản | Đăng ký thành công | - | - | UC-001 bước 8; Q-158 |
| E-43 | SCR-22 | SCR-02 | 1 Đơn giản | Huỷ yêu cầu | - | - | UC-001 luồng *a |
| E-44 | SCR-02 | SCR-23 | 1 Đơn giản | Chọn thẻ Xem phim | - | - | UC-003 bước 1 |
| E-45 | SCR-23 | SCR-24 | 4 Phụ thuộc có dữ liệu | Chọn nút Xem phim | Danh sách có phim | Phim đã chọn | UC-003 bước 4, 5 |
| E-46 | SCR-24 | SCR-23 | 1 Đơn giản | Chọn nút Quay lại danh sách phim | - | - | UI-STT 51 |
| E-47 | SCR-02 | SCR-25 | 1 Đơn giản | Chọn thẻ Tra cứu lịch chiếu | - | - | UC-004 bước 1 |
| E-48 | SCR-02 | SCR-26 | 1 Đơn giản | Chọn thẻ Lịch sử đặt vé | Đã có phiên | - | UC-007 bước 1 |
| E-49 | SCR-02 | SCR-01 | 1 Đơn giản | Chọn thẻ Lịch sử đặt vé | Chưa có phiên | - | UC-007 tiền điều kiện |
| E-50 | SCR-26 | SCR-27 | 4 Phụ thuộc có dữ liệu | Chọn nút Xem vé | Lần đặt thuộc khách (BR-94) | Lần đặt đã chọn | UC-007 bước 3-5 |
| E-51 | SCR-27 | SCR-26 | 1 Đơn giản | Chọn nút Quay lại danh sách lịch sử | - | - | UI-STT 51 |
| E-52 | SCR-17 | SCR-28 | 1 Đơn giản | Chọn thẻ Quản lý phòng chiếu | - | - | UC-012 bước 1 |
| E-53 | SCR-28 | SCR-29 | 2 Con phụ thuộc | Thêm phòng chiếu hoặc Sửa | Khi sửa: phòng thuộc cụm rạp (BR-135) | Phòng chiếu cần sửa (khi sửa) | UC-012 bước 1, luồng 1a |
| E-54 | SCR-17 | SCR-30 | 1 Đơn giản | Chọn thẻ Báo cáo cụm rạp | - | - | UC-015 bước 1 |
| E-55 | SCR-31 | SCR-32 | 1 Đơn giản | Chọn thẻ Quản lý phim | - | - | UC-010 bước 1 |
| E-56 | SCR-32 | SCR-33 | 2 Con phụ thuộc | Thêm phim hoặc Sửa | - | Phim cần sửa (khi sửa) | UC-010 bước 1, luồng 1a |
| E-57 | SCR-31 | SCR-34 | 1 Đơn giản | Chọn thẻ Quản lý cụm rạp | - | - | UC-011 bước 1 |
| E-58 | SCR-34 | SCR-35 | 2 Con phụ thuộc | Thêm cụm rạp hoặc Sửa | - | Cụm rạp cần sửa (khi sửa) | UC-011 bước 1, luồng 1a |
| E-59 | SCR-31 | SCR-36 | 1 Đơn giản | Chọn thẻ Báo cáo toàn chuỗi | - | - | UC-016 bước 1 |
| E-60 | SCR-37 | SCR-38 | 2 Con phụ thuộc | Tạo tài khoản hoặc Đổi vai trò, cụm rạp | - | Tài khoản cần cập nhật (khi cập nhật) | UC-017 bước 1, luồng 1a |
| E-61 | SCR-37 | SCR-39 | 2 Con phụ thuộc | Chọn nút Sửa họ tên | - | Tài khoản đã chọn | UC-017 luồng 1d |
| E-62 | SCR-37 | SCR-40 | 2 Con phụ thuộc | Chọn nút Đặt lại mật khẩu | - | Tài khoản đã chọn | UC-017 luồng 1e |
| E-63 | SCR-01 | SCR-22 | 1 Đơn giản | Chọn liên kết Đăng ký tài khoản | Dạng trang, chưa có phiên | - | UC-001 bước 1 |

## Kiểm tra

- Mọi màn hình đến được từ một Start: SCR-02 từ START-ACT-01 (E-01); SCR-01 từ START-ACT-01 (E-02), SCR-02 (E-12, E-49), SCR-22 (E-42); SCR-21 từ START-ACT-02 đến START-ACT-06 (E-03, E-04, E-05, E-35, E-36); SCR-09, SCR-16, SCR-17, SCR-31, SCR-37 từ SCR-21 (E-07, E-08, E-09, E-37, E-38); SCR-03 đến SCR-08, SCR-22, SCR-23, SCR-25, SCR-26 từ SCR-02; SCR-24 từ SCR-23; SCR-27 từ SCR-26; SCR-10 đến SCR-15 từ SCR-09; SCR-18, SCR-19, SCR-28, SCR-30 từ SCR-17; SCR-20 từ SCR-19; SCR-29 từ SCR-28; SCR-32, SCR-34, SCR-36 từ SCR-31; SCR-33 từ SCR-32; SCR-35 từ SCR-34; SCR-38, SCR-39, SCR-40 từ SCR-37.
- Mọi màn hình có lối ra: có cạnh đi (SCR-01 đến SCR-07, SCR-09 đến SCR-11, SCR-13, SCR-14, SCR-17, SCR-19, SCR-21 đến SCR-24, SCR-26 đến SCR-28, SCR-31, SCR-32, SCR-34, SCR-37), là pop-up đóng về cha (SCR-20, SCR-29, SCR-33, SCR-35, SCR-38, SCR-39, SCR-40), hoặc là màn hình kết thúc đã ghi ở Ghi chú (SCR-08, SCR-12, SCR-15, SCR-16, SCR-18, SCR-25, SCR-30, SCR-36).
- Không có cạnh đóng pop-up: SCR-01 mở dạng pop-up từ SCR-04 (E-14), SCR-20 từ SCR-19 (E-31), SCR-29 từ SCR-28 (E-53), SCR-33 từ SCR-32 (E-56), SCR-35 từ SCR-34 (E-58), SCR-38, SCR-39, SCR-40 từ SCR-37 (E-60, E-61, E-62); việc đóng là ngầm định.
- Thông điệp ngắn (lỗi, xác nhận có hoặc không) dùng hộp thông điệp chuẩn của ui-standards.md, không thành màn hình.
- Từ chối ở màn hình danh sách (SCR-03, SCR-07, SCR-13, SCR-18, SCR-19, SCR-26, SCR-28, SCR-32, SCR-34, SCR-37) ở lại màn hình theo UI-STT 29(2) nên không có cạnh; từ chối ở pop-up form ở lại pop-up theo UI-STT 29(5).
- Phiên không còn hiệu lực (UI-STT 48) đưa mọi màn hình nhân viên về SCR-21 và màn hình khách về SCR-01, kèm MSG-85; là hành vi chung của mọi màn hình nên ghi ở Ghi chú của SCR-01, SCR-21 và không vẽ cạnh.
- Mọi use case có tác nhân người đều có màn hình đích từ màn hình điều hướng hoặc từ màn hình đầu của tác nhân; UC-006 không có tác nhân người nên không có màn hình.

## Câu hỏi mở

Xem ui-standards.md: Q-119 đến Q-125 và Q-272 đến Q-276. Liên quan sơ đồ này: Q-123 (điểm khởi đầu ACT-01 đến ACT-04, đã trả lời), Q-275 (điểm khởi đầu ACT-05, ACT-06, chờ xác nhận), Q-272 (không có cạnh từ SCR-24, SCR-25 sang đặt vé, chờ xác nhận), Q-119 (cạnh E-32, E-33, E-34 quay lại lần giữ ghế đang chạy, chờ người dùng xác nhận).

## Đề xuất sửa artifact trước

Xem screen-list.md: P10 (View điều hướng quản lý chuỗi), P04 (UC-004 danh sách tỉnh, thành phố; UC-005 luồng giữ ghế suất chiếu chưa mở bán).

## Vấn đề còn mở

1. Điểm khởi đầu theo Q-123 và Q-275; cạnh E-01, E-02 phản ánh hai lối vào của khách (mở ứng dụng, chọn Đăng nhập). Mục Đăng xuất trong menu (UI-STT 22) xoá phiên rồi mở SCR-21 (nhân viên, quản trị viên) hoặc SCR-02 (khách), thuộc mẫu 1 như các mục menu khác nên không vẽ cạnh.
2. Cạnh E-18 đi qua cổng VNPay (ngoài hệ thống): trình duyệt rời ứng dụng, thanh toán hoặc huỷ ở cổng, rồi quay về địa chỉ trả về là SCR-06. Nguồn của cạnh là cổng VNPay, không phải một nút của SCR-05.
3. Cạnh E-39, E-40, E-63 là liên kết điều hướng giữa các màn hình đăng nhập và đăng ký (UI-STT 46), không thuộc luồng sự kiện của use case nào.
