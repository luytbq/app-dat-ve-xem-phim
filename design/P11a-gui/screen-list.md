# P11a - Danh sách màn hình - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11a (Toàn bộ: giai đoạn 1 và giai đoạn 2) |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Mở rộng cho đủ 16 use case của P10 2.0: thêm SCR-21 đến SCR-40 (đăng nhập nhân viên, UC-001, UC-003, UC-004, UC-007, UC-010, UC-011, UC-012, UC-015, UC-016, UC-017, trang chủ quản lý chuỗi); SCR-01 chỉ còn đăng nhập khách (Q-267); SCR-02 và SCR-17 thêm lối vào; cập nhật bảng F7 và đề xuất sửa artifact trước |
| Thay đổi 1.3 | Cập nhật dải MSG đã cấp đến MSG-83 và dải luồng 8a-8f của SCR-20; đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md (C10); project-profile.md; P01-actors.md 1.2; P02-usecases.md 1.9; P04-uc-specs UC-001 1.2, UC-003 1.1, UC-004 1.2, UC-005 1.15, UC-007 1.2, UC-008 1.10, UC-009 1.7, UC-010 1.2, UC-011 1.2, UC-012 1.2, UC-013 1.5, UC-014 1.7, UC-015 1.2, UC-016 1.2, UC-017 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P07-uc-analysis (16 use case); P08-analysis-model.md 2.0 (F3, Đề xuất sửa artifact trước); P09-architecture.md 2.0 (F5, F7.11, Đề xuất sửa artifact trước); P10-design-elements.md 2.0 (F3, F4, Đề xuất sửa artifact trước); design/_sync-log.md (Đầu vào cho lần chạy lại P08-P13, các dòng P11a); ui-standards.md 2.0; screen-transition.md 2.0; SCR-01 đến SCR-40. Dải Q của phiên: Q-272 đến Q-281 (C10) |
| Phạm vi | Toàn hệ thống: mọi use case có tác nhân người (UC-001, UC-003, UC-004, UC-005, UC-007 đến UC-017) và hai màn hình đăng nhập. UC-006 không có màn hình (tác nhân chính là cổng thanh toán) |
| Mã Q, ASM cuối đã cấp | Q-276 (dải Q-272 đến Q-281 của phiên, Q-277 đến Q-281 để trống); không có ASM (NGHIEM_NGAT). MSG đã cấp: MSG-01 đến MSG-134 |

Mức hợp lý: 40 màn hình; mỗi use case của một tác nhân chính có 1 đến 4 màn hình (UC-001 1: SCR-22; UC-003 2: SCR-23, SCR-24; UC-004 1: SCR-25; UC-005 khách 4: SCR-03 đến SCR-06; UC-005 quầy 3: SCR-10 đến SCR-12; UC-007 2: SCR-26, SCR-27; UC-008 khách 2: SCR-07, SCR-08; UC-008 quầy 3: SCR-13 đến SCR-15; UC-009 1: SCR-16; UC-010 2: SCR-32, SCR-33; UC-011 2: SCR-34, SCR-35; UC-012 2: SCR-28, SCR-29; UC-013 1: SCR-18; UC-014 2: SCR-19, SCR-20; UC-015 1: SCR-30; UC-016 1: SCR-36; UC-017 4: SCR-37 đến SCR-40). Hai màn hình đăng nhập: SCR-01 (khách), SCR-21 (nhân viên, quản trị viên). Boundary BookTicketsForm và CounterBookTicketsForm (một View mỗi boundary ở P10) sinh nhiều màn hình, ghi ở Đề xuất sửa artifact trước.

## Danh sách màn hình

| SCR | Tên | Boundary AC nguồn | UC | Tác nhân | Loại | Lớp thiết kế (DC) | Mục đích | Bước UC phục vụ |
|---|---|---|---|---|---|---|---|---|
| SCR-01 | Đăng nhập khách (Log in as customer) | Chưa có (đăng nhập không là use case); AC-B-BookTicketsForm có requestLogin, provideCredentials cho luồng 5a | Tiền điều kiện UC-007, UC-008 (kênh khách); luồng 5a của UC-005 | ACT-01 Khách | Độc lập (pop-up Con phụ thuộc khi mở từ SCR-04) | DC-LoginView | Nhập email hoặc số điện thoại và mật khẩu để có phiên làm việc của khách | UC-005 luồng 5a1, 5a2; tiền điều kiện UC-007, UC-008 |
| SCR-02 | Trang chủ khách (Customer home) | Điều hướng: SCR-03, SCR-07, SCR-22, SCR-23, SCR-25, SCR-26 | UC-005, UC-008, UC-001, UC-003, UC-004, UC-007 (lối vào) | ACT-01 Khách | Độc lập | DC-CustomerHomeView | Chọn lối vào Đặt vé, Huỷ vé, Đăng ký, Xem phim, Tra cứu lịch chiếu hoặc Lịch sử đặt vé; xem kết quả use case vừa kết thúc | UC-005 bước 1; UC-008 bước 1; UC-001, UC-003, UC-004, UC-007 bước 1; thông điệp kết thúc, từ chối của UC-005; MSG-57 của UC-001 |
| SCR-03 | Chọn suất chiếu (Select showtime) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Độc lập | DC-BookTicketsView | Chọn suất chiếu muốn mua vé | 1, 2; luồng 2a, 2c |
| SCR-04 | Chọn ghế (Select seats) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BookTicketsView | Xem sơ đồ ghế real-time và chọn ghế | 3, 4, 5, 6, 7; luồng 5a, 5b, 6a, 7a, 7c, 7d, 7e |
| SCR-05 | Giữ ghế và thanh toán (Hold seats and pay) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BookTicketsView | Xem ghế đã giữ, tổng tiền, đồng hồ 10 phút, huỷ giữ ghế hoặc thanh toán qua VNPay | 8, 9, 10, 11; luồng 7b, 10a, 11a, *a |
| SCR-06 | Kết quả đặt vé (Booking result) | AC-B-BookTicketsForm | UC-005 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BookTicketsView | Xem kết quả thanh toán, mã đặt vé và các vé | 11, 12, 13, 14, 15; luồng 7b, 11a |
| SCR-07 | Chọn vé cần huỷ (Select ticket to cancel) | AC-B-CancelTicketForm | UC-008 | ACT-01 Khách | Độc lập | DC-CancelTicketView | Chọn vé mua trực tuyến cần huỷ và xác nhận | 1, 2, 3, 4, 5, 6, 7; luồng 2a, 3a, 4a, 4b |
| SCR-08 | Kết quả huỷ vé (Cancellation result) | AC-B-CancelTicketForm | UC-008 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-CancelTicketView | Xem kết quả huỷ vé và khoản hoàn | 7, 8; luồng 5c, 6b |
| SCR-09 | Trang chủ quầy (Counter home) | Điều hướng: SCR-10, SCR-13 | UC-005, UC-008 (lối vào) | ACT-02 Nhân viên quầy | Độc lập | DC-CounterHomeView | Chọn lối vào Bán vé hoặc Huỷ vé tại quầy | UC-005 bước 1; UC-008 bước 1a; thông điệp kết thúc, từ chối của UC-005 tại quầy |
| SCR-10 | Chọn suất và ghế tại quầy (Select showtime and seats at counter) | AC-B-CounterBookTicketsForm | UC-005 | ACT-02 Nhân viên quầy | Độc lập | DC-CounterBookTicketsView | Chọn suất chiếu và ghế khách muốn mua tại quầy | 1, 2, 3, 4, 5, 6, 7; luồng 2a, 2b, 2c, 5b, 6a, 7a, 7c, 7d, 7e |
| SCR-11 | Giữ ghế và thu tiền mặt (Hold seats and collect cash) | AC-B-CounterBookTicketsForm | UC-005 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterBookTicketsView | Xem ghế đã giữ, đồng hồ 10 phút, xác nhận đã thu tiền mặt hoặc huỷ giữ ghế | 8, 9a1, 9a2; luồng 9a1a, 7b, *a |
| SCR-12 | In vé tại quầy (Print tickets at counter) | AC-B-CounterBookTicketsForm | UC-005 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterBookTicketsView | Xem mã đặt vé và vé, in vé | 9a3, 9a4, 9a5 |
| SCR-13 | Tìm vé theo mã đặt vé (Find tickets by booking code) | AC-B-CounterCancelTicketForm | UC-008 | ACT-02 Nhân viên quầy | Độc lập | DC-CounterCancelTicketView | Nhập mã đặt vé, chọn vé mua tại quầy cần huỷ | 1a1, 1a1a, 1a2, 1a3, 2, 3, 4; luồng 2b, 2c, 3a, 4a, 4b |
| SCR-14 | Hoàn tiền mặt (Cash refund) | AC-B-CounterCancelTicketForm | UC-008 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterCancelTicketView | Xem số tiền mặt cần hoàn và xác nhận đã hoàn | 5a1, 5a2, 7 |
| SCR-15 | Kết quả huỷ vé tại quầy (Counter cancellation result) | AC-B-CounterCancelTicketForm | UC-008 | ACT-02 Nhân viên quầy | Phụ thuộc có dữ liệu | DC-CounterCancelTicketView | Xem kết quả huỷ vé tại quầy | 7, 8 |
| SCR-16 | Soát vé (Check ticket) | AC-B-CheckTicketForm | UC-009 | ACT-03 Nhân viên soát vé | Độc lập | DC-CheckTicketView | Chọn suất chiếu đang soát, quét mã QR, xem kết quả hợp lệ hoặc lý do từ chối | 1, 2, 3, 4, 5, 6, 7; luồng 4a, 4b, 4c, 4d, 4e |
| SCR-17 | Trang chủ quản lý cụm rạp (Cinema manager home) | Điều hướng: SCR-18, SCR-19, SCR-28, SCR-30 | UC-012, UC-013, UC-014, UC-015 (lối vào) | ACT-04 Quản lý cụm rạp | Độc lập | DC-CinemaAdminHomeView | Chọn lối vào Quản lý phòng chiếu, Quản lý bảng giá, Lập lịch suất chiếu hoặc Xem báo cáo cụm rạp | UC-012, UC-013, UC-014, UC-015 bước 1 |
| SCR-18 | Bảng giá cụm rạp (Cinema price list) | AC-B-ManagePriceListForm | UC-013 | ACT-04 Quản lý cụm rạp | Độc lập | DC-ManagePriceListView | Xem bảng giá, đặt giá, bỏ giá | 1, 2, 3, 4, 5, 6; luồng 1a, 1a1-1a4, 4a, 5a, *a |
| SCR-19 | Danh sách suất chiếu (Showtime list) | AC-B-ScheduleShowtimesForm | UC-014 | ACT-04 Quản lý cụm rạp | Độc lập | DC-ScheduleShowtimesView | Xem danh sách suất chiếu, chọn lập, sửa, xoá | 1, 1a1-1a3, 1b1-1b4; luồng 1a3a, 1a3b, 1b3a, 1b3b, 1b3c |
| SCR-20 | Lập hoặc sửa suất chiếu (Create or edit showtime) | AC-B-ScheduleShowtimesForm | UC-014 | ACT-04 Quản lý cụm rạp | Con phụ thuộc | DC-ScheduleShowtimesView | Nhập thông tin suất chiếu để lập hoặc sửa | 2, 3, 4, 5, 6, 7, 8, 9; luồng 1a4, 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a-8f, *a |
| SCR-21 | Đăng nhập nhân viên (Staff login) | Chưa có (đăng nhập không là use case) | Tiền điều kiện UC-005, UC-008 (kênh quầy), UC-009, UC-010 đến UC-017 | ACT-02 Nhân viên quầy, ACT-03 Nhân viên soát vé, ACT-04 Quản lý cụm rạp, ACT-05 Quản lý chuỗi, ACT-06 Quản trị viên | Độc lập | DC-LoginView | Nhập email và mật khẩu để có phiên làm việc của nhân viên hoặc quản trị viên | Tiền điều kiện các use case của nhân viên và quản trị viên |
| SCR-22 | Đăng ký tài khoản (Register account) | AC-B-RegisterAccountForm | UC-001 | ACT-01 Khách | Độc lập | DC-RegisterAccountView | Nhập email, số điện thoại, mật khẩu để tạo tài khoản khách | 1-8; luồng 4a, 5a, 6a, 7a, *a |
| SCR-23 | Danh sách phim (Movie list) | AC-B-BrowseMoviesForm | UC-003 | ACT-01 Khách | Độc lập | DC-BrowseMoviesView | Xem phim đang chiếu, sắp chiếu và chọn một phim | 1-4; luồng 2a |
| SCR-24 | Thông tin phim (Movie details) | AC-B-BrowseMoviesForm | UC-003 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-BrowseMoviesView | Xem thông tin của phim đã chọn | 4, 5 |
| SCR-25 | Tra cứu lịch chiếu (Browse showtimes) | AC-B-BrowseShowtimesForm | UC-004 | ACT-01 Khách | Độc lập | DC-BrowseShowtimesView | Chọn phim hoặc cụm rạp, lọc và xem lịch chiếu | 1-5; luồng 1a1-1a5, 1a4a, 4a |
| SCR-26 | Lịch sử đặt vé (Booking history) | AC-B-ViewBookingHistoryForm | UC-007 | ACT-01 Khách | Độc lập | DC-ViewBookingHistoryView | Xem các lần đặt vé của mình và chọn một lần đặt | 1-4; luồng 2a, 4a |
| SCR-27 | Vé của lần đặt (Booking tickets) | AC-B-ViewBookingHistoryForm | UC-007 | ACT-01 Khách | Phụ thuộc có dữ liệu | DC-ViewBookingHistoryView | Xem các vé của lần đặt đã chọn | 5 |
| SCR-28 | Danh sách phòng chiếu (Auditorium list) | AC-B-ManageAuditoriumsForm | UC-012 | ACT-04 Quản lý cụm rạp | Độc lập | DC-ManageAuditoriumsView | Xem phòng chiếu của cụm rạp, chọn thêm, sửa, xoá | 1, 2, 6; 1a1-1a3, 1a2a, 1b1-1b4, 1b2a, 1b3a; luồng 5c |
| SCR-29 | Lập hoặc sửa phòng chiếu (Create or edit auditorium) | AC-B-ManageAuditoriumsForm | UC-012 | ACT-04 Quản lý cụm rạp | Con phụ thuộc | DC-ManageAuditoriumsView | Nhập thông tin và sơ đồ ghế để thêm hoặc sửa phòng chiếu | 3-6; luồng 1a3, 4a, 4b, 4d, 5a, 5b, 5c, *a |
| SCR-30 | Báo cáo cụm rạp (Cinema report) | AC-B-ViewCinemaReportForm | UC-015 | ACT-04 Quản lý cụm rạp | Độc lập | DC-ViewCinemaReportView | Chọn cách xem và kỳ báo cáo, xem doanh thu và tỉ lệ lấp đầy của cụm rạp | 1-5; luồng 1a, 2a |
| SCR-31 | Trang chủ quản lý chuỗi (Chain manager home) | Điều hướng: SCR-32, SCR-34, SCR-36 | UC-010, UC-011, UC-016 (lối vào) | ACT-05 Quản lý chuỗi | Độc lập | Chưa có (điều hướng) | Chọn lối vào Quản lý phim, Quản lý cụm rạp hoặc Báo cáo toàn chuỗi | UC-010, UC-011, UC-016 bước 1 |
| SCR-32 | Danh sách phim của chuỗi (Chain movie list) | AC-B-ManageMoviesForm | UC-010 | ACT-05 Quản lý chuỗi | Độc lập | DC-ManageMoviesView | Xem phim của chuỗi, chọn thêm hoặc sửa | 1, 2, 6; 1a1-1a3; luồng 5a |
| SCR-33 | Thêm hoặc sửa phim (Create or edit movie) | AC-B-ManageMoviesForm | UC-010 | ACT-05 Quản lý chuỗi | Con phụ thuộc | DC-ManageMoviesView | Nhập thông tin phim, định dạng phát hành, ngày khởi chiếu và kết thúc chiếu | 3-6; luồng 1a3, 4a, 5a, *a |
| SCR-34 | Danh sách cụm rạp (Cinema list) | AC-B-ManageCinemasForm | UC-011 | ACT-05 Quản lý chuỗi | Độc lập | DC-ManageCinemasView | Xem cụm rạp của chuỗi, chọn thêm hoặc sửa | 1, 2, 6; 1a1-1a3; luồng 5a |
| SCR-35 | Thêm hoặc sửa cụm rạp (Create or edit cinema) | AC-B-ManageCinemasForm | UC-011 | ACT-05 Quản lý chuỗi | Con phụ thuộc | DC-ManageCinemasView | Nhập tên, tỉnh hoặc thành phố, địa chỉ của cụm rạp | 3-6; luồng 1a3, 4a, 5a, 5b, *a |
| SCR-36 | Báo cáo toàn chuỗi (Chain report) | AC-B-ViewChainReportForm | UC-016 | ACT-05 Quản lý chuỗi | Độc lập | DC-ViewChainReportView | Chọn cách xem và kỳ báo cáo, xem số liệu toàn chuỗi và so sánh giữa các cụm rạp | 1-6; luồng 1a, 2a |
| SCR-37 | Danh sách tài khoản nhân viên (Staff account list) | AC-B-ManageStaffAccountsForm | UC-017 | ACT-06 Quản trị viên | Độc lập | DC-ManageStaffAccountsView | Xem tài khoản nhân viên; chọn tạo, đổi vai trò và cụm rạp, sửa họ tên, đặt lại mật khẩu, khoá, mở khoá | 1a1-1a3, 1b1-1b4, 1c1-1c4, 1d1, 1e1; luồng 5b |
| SCR-38 | Tạo hoặc cập nhật tài khoản nhân viên (Create or update staff account) | AC-B-ManageStaffAccountsForm | UC-017 | ACT-06 Quản trị viên | Con phụ thuộc | DC-ManageStaffAccountsView | Nhập email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp để tạo; hoặc đổi vai trò và cụm rạp | 3-6; luồng 1a3, 4a-4d, 5a, 5b, *a |
| SCR-39 | Sửa họ tên nhân viên (Edit staff full name) | AC-B-ManageStaffAccountsForm | UC-017 | ACT-06 Quản trị viên | Con phụ thuộc | DC-ManageStaffAccountsView | Nhập họ tên mới của nhân viên | 1d2-1d5; luồng 1d4a, 1d4b, *a |
| SCR-40 | Đặt lại mật khẩu nhân viên (Reset staff password) | AC-B-ManageStaffAccountsForm | UC-017 | ACT-06 Quản trị viên | Con phụ thuộc | DC-ManageStaffAccountsView | Nhập mật khẩu mới của nhân viên | 1e2-1e5; luồng 1e4a, *a |

## Boundary không có màn hình

| AC | Loại boundary | Ánh xạ ở P10 (SS, DC) | Lý do |
|---|---|---|---|
| AC-B-PaymentGateway | Hệ thống ngoài (cổng thanh toán) | SS-01, IF-01, IF-02 | P10 ánh xạ sang subsystem; tác nhân là hệ thống ngoài ACT-07. Khách chỉ thấy kết quả qua SCR-05 (chuyển sang VNPay) và SCR-06 (trang kết quả) |
| AC-B-EmailService | Kênh thông báo (email) | SS-02, IF-03 | Kênh thông báo, không cần màn hình; khách thấy kết quả gửi vé trong MSG-17 của SCR-06 |

UC-006 Hoàn tiền thanh toán trễ: tác nhân chính ACT-07 Cổng thanh toán, tác nhân phụ ACT-08 Dịch vụ email, không có tác nhân người nên không có màn hình; khách nhận kết quả hoàn tiền qua email (GL-06).

## Bảng tổng hợp đánh giá chuẩn (F7)

| SCR | Tiêu chí | Kết quả | Bằng chứng | Cách xử lý |
|---|---|---|---|---|
| SCR-01 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-02 nêu việc cần làm và không cho biết trường nào sai | - |
| SCR-01 | WCAG 3.3.7 Không bắt nhập lại | Đạt | Dạng pop-up giữ nguyên ghế đã chọn và tự gửi lại việc xác nhận | - |
| SCR-01 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Cho phép trình duyệt điền tự động, có Hiện mật khẩu (UI-STT 46) | - |
| SCR-01 | Baymard: nhãn trên ô nhập, giữ dữ liệu | Đạt | UI-STT 16, 20 | - |
| SCR-02 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Sáu lối vào đều có màn hình đích (SCR-03, SCR-07, SCR-22, SCR-23, SCR-25, SCR-26) | Đã sửa khi UC-001, UC-003, UC-004, UC-007 được đặc tả |
| SCR-02 | Nielsen 8 Thẩm mỹ, tối giản | Đạt | Thẻ Đăng ký tài khoản chỉ hiện khi chưa có phiên (UI-STT 47) | - |
| SCR-03 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm danh sách suất chiếu (UC-005 bước 1 không có; lọc thuộc UC-004 ở SCR-25) | Chấp nhận theo Q-120, Q-272: SCR-25 lọc lịch chiếu nhưng không nối sang SCR-03 |
| SCR-03 | Nielsen 3 Kiểm soát và tự do | Đạt | Từ chối ở lại danh sách theo UI-STT 29(2), không đẩy khách khỏi màn hình | - |
| SCR-04 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Dải trạng thái kết nối, MSG-26, đếm ghế đã chọn (UI-STT 40, 41) | - |
| SCR-04 | Nielsen 5 Ngăn lỗi | Đạt | Ghế đang giữ, đã bán không chọn được; nút vô hiệu khi chưa chọn ghế | - |
| SCR-04 | WCAG 1.4.1 Không dùng màu làm tín hiệu duy nhất | Đạt | Bốn trạng thái ghế khác nhau cả biểu tượng, hoạ tiết, chữ (UI-STT 39) | - |
| SCR-04 | WCAG 1.4.10 Reflow | Không áp dụng | Sơ đồ ghế là nội dung hai chiều, cuộn ngang trong khung | Ghi ở UI-STT 39 |
| SCR-04 | WCAG 2.1.1 Bàn phím | Đạt | Lưới ghế dùng phím mũi tên và Space (UI-STT 26) | - |
| SCR-04 | WCAG 4.1.3 Thông điệp trạng thái | Đạt | Thay đổi ghế được gộp thành thông báo role=status (UI-STT 40) | - |
| SCR-04 | Baymard / Nielsen 6 | Đạt | Giữ lựa chọn khi đăng nhập và khi bị từ chối ở 6a, 7a | - |
| SCR-05 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Đồng hồ, chữ "Sắp hết thời gian", MSG-26, MSG-27 (UI-STT 43, 27) | - |
| SCR-05 | Nielsen 3 Kiểm soát và tự do | Đạt | Khách tải lại hoặc rời trang vẫn mở lại được lần giữ ghế qua dải Tiếp tục thanh toán (Q-119); không gia hạn được vì BR-10 | Đã sửa theo Q-119 |
| SCR-05 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận huỷ giữ ghế (MSG-18); cảnh báo khi rời trang (MSG-77) | - |
| SCR-05 | WCAG 2.2.1 Giới hạn thời gian | Đạt | Giới hạn 10 phút là quy tắc nghiệp vụ thiết yếu, có cảnh báo ở bốn mốc (UI-STT 36) | - |
| SCR-05 | WCAG 1.4.1 | Đạt | Trạng thái sắp hết hạn có chữ và nền, không chỉ màu | - |
| SCR-05 | Baymard: tóm tắt đơn và tổng tiền ở bước thanh toán | Đạt | Bảng ghế, giá và tổng tiền cạnh nút thanh toán (UI-STT 44) | - |
| SCR-06 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Khách đóng tab ở VNPay hoặc tải lại thì thấy dải Tiếp tục thanh toán ở SCR-02 khi lần giữ ghế còn chạy (Q-119); kết quả đặt vé sau đó xem qua email hoặc ở SCR-26 | Đã sửa theo Q-119 |
| SCR-06 | Nielsen 9 | Đạt | MSG-14, MSG-16, MSG-30 nêu kết quả và việc tiếp theo (hoàn tiền, kiểm tra email) | - |
| SCR-06 | WCAG 1.1.1 Nội dung không phải chữ | Đạt | Mã QR có văn bản thay thế nêu ghế và mã đặt vé (UI-STT 34) | - |
| SCR-06 | WCAG 4.1.3 | Đạt | Kết quả đổi từ MSG-28 sang kết quả cuối qua vùng role=status | - |
| SCR-07 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền hoàn và không hoàn tác (UI-STT 37) | - |
| SCR-07 | Nielsen 1 | Đạt | MSG-78 trong lúc hoàn tiền kéo dài (UI-STT 27) | - |
| SCR-07 | WCAG 3.3.4 Ngăn lỗi tài chính | Đạt | Xác nhận trước khi huỷ vé và hoàn tiền | - |
| SCR-07 | Nielsen 7 | Vi phạm còn mở (do phạm vi) | Không có lọc theo mã đặt vé hoặc suất chiếu (UC-008 bước 1 không có; UC-007 ở SCR-26 cũng không có lọc) | Chấp nhận theo Q-121, không thêm chức năng ngoài đặc tả |
| SCR-08 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Tình trạng hoàn tiền hiện rõ cả khi chưa hoàn được (MSG-41) | - |
| SCR-08 | Nielsen 9 | Đạt | MSG-41 nêu khoản hoàn được xử lý thủ công | - |
| SCR-09 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục thẻ với SCR-02 và SCR-17 (UI-STT 47) | - |
| SCR-10 | Nielsen 7 Linh hoạt và hiệu quả | Đạt | Chọn suất và ghế trên một màn hình cho thao tác lặp tại quầy | - |
| SCR-10 | Nielsen 1 | Đạt | Dải kết nối, đếm ghế, MSG-26 | - |
| SCR-10 | WCAG 1.4.1 | Đạt | Bốn ký hiệu ghế như SCR-04 (UI-STT 39) | - |
| SCR-10 | WCAG 2.1.1 | Đạt | UI-STT 26 | - |
| SCR-11 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận thu tiền nêu số tiền (MSG-22) và xử lý xác nhận trễ bằng MSG-20 | - |
| SCR-11 | WCAG 3.3.4 Ngăn lỗi tài chính | Đạt | Xác nhận trước khi chuyển ghế sang đã bán | - |
| SCR-11 | WCAG 2.2.1 | Đạt | UI-STT 36, 43 | - |
| SCR-11 | Nielsen 3 | Đạt | Rời trang vẫn mở lại được lần giữ ghế qua dải Tiếp tục thanh toán ở SCR-09 (Q-119); không gia hạn vì BR-10 | Đã sửa theo Q-119 |
| SCR-12 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-21 báo đã bán vé và việc cần làm tiếp | - |
| SCR-12 | WCAG 1.1.1 | Đạt | Mã QR có văn bản thay thế (UI-STT 34) | - |
| SCR-13 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền mặt hoàn và không hoàn tác (UI-STT 37) | - |
| SCR-13 | Nielsen 9 | Đạt | MSG-31 nêu việc cần làm tiếp và giữ mã đã nhập | - |
| SCR-13 | Baymard: giữ dữ liệu đã nhập | Đạt | Mã đặt vé còn nguyên sau MSG-31 (UI-STT 20) | - |
| SCR-13 | WCAG 3.3.4 | Đạt | Xác nhận trước khi huỷ vé | - |
| SCR-14 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận nêu số tiền (MSG-42) | - |
| SCR-14 | Nielsen 3 Kiểm soát và tự do | Đạt | Huỷ vé và hoàn tiền mặt là một thao tác; rời màn hình trước khi xác nhận thì vé chưa bị huỷ (Q-125) | Đã sửa theo Q-125 |
| SCR-14 | WCAG 3.3.4 | Đạt | Xác nhận tài chính trước khi ghi nhận hoàn tiền | - |
| SCR-15 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-43 và tình trạng hoàn tiền hiện ngay sau xác nhận | - |
| SCR-16 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Khối kết quả lớn có chữ, biểu tượng và màu; giữ tới lần quét kế (UI-STT 45) | - |
| SCR-16 | Nielsen 5 Ngăn lỗi | Đạt | Chống đọc lại cùng mã trong 3 giây để không sinh thêm kết quả đã sử dụng giả | - |
| SCR-16 | WCAG 1.4.1 | Đạt | Hợp lệ và từ chối khác nhau cả chữ, biểu tượng, màu | - |
| SCR-16 | WCAG 2.1.1 Bàn phím | Vi phạm còn mở | Việc quét bằng camera không có thao tác bàn phím thay thế; đặc tả cấm nhập tay mã QR (NFR-13) | Chấp nhận do ràng buộc thiết kế NFR-13; chọn suất chiếu và mọi điều khiển khác dùng được bằng bàn phím |
| SCR-16 | WCAG 4.1.3 | Đạt | Kết quả quét thông báo qua vùng role=alert/status | - |
| SCR-16 | Nielsen 7 | Đạt | Chọn suất một lần, quét liên tục không thao tác thêm | - |
| SCR-17 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Bốn lối vào đều có màn hình đích (SCR-18, SCR-19, SCR-28, SCR-30) | Đã sửa khi UC-012, UC-015 được đặc tả |
| SCR-18 | Nielsen 5 Ngăn lỗi | Đạt | Xác nhận trước khi bỏ giá (MSG-56); danh sách chọn thay ô gõ cho bốn yếu tố tổ hợp | - |
| SCR-18 | Nielsen 4 Nhất quán | Đạt | Bố cục bảng và biểu mẫu thống nhất với SCR-19 | - |
| SCR-18 | Baymard: một cột, nhãn trên ô, bắt buộc có dấu * | Đạt | UI-STT 16 áp dụng cho biểu mẫu Đặt giá | - |
| SCR-18 | WCAG 1.4.1 | Đạt | Hàng vừa lưu có viền trái và biểu tượng, không chỉ màu (UI-STT 18) | - |
| SCR-19 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận xoá nêu hậu quả (MSG-71) | - |
| SCR-19 | Nielsen 3 | Đạt | Từ chối ở lại danh sách, không đẩy người dùng ra màn hình khác (UI-STT 29(2)) | - |
| SCR-19 | WCAG 2.4.3 | Đạt | Đóng pop-up SCR-20 trả tiêu điểm về nút đã mở (UI-STT 21) | - |
| SCR-20 | Nielsen 5 Ngăn lỗi | Đạt | Danh sách chọn cho phim, định dạng, phòng chiếu; hiện khoảng chiếu của phim ngay dưới ô (UI-STT 32) | - |
| SCR-20 | Nielsen 9 | Đạt | Mỗi từ chối có thông điệp riêng nêu cách khắc phục (MSG-58 đến MSG-65) | - |
| SCR-20 | Baymard: một cột, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-20 | WCAG 2.4.3, 2.4.11 | Đạt | Tiêu điểm bị giữ trong hộp và trả về khi đóng (UI-STT 21) | - |
| SCR-20 | WCAG 3.3.2 | Đạt | Gợi ý định dạng ngày giờ dưới nhãn, không dùng placeholder thay nhãn | - |
| SCR-21 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-86, MSG-87 nêu việc cần làm; MSG-85 giải thích vì sao bị đưa về đăng nhập (UI-STT 48) | - |
| SCR-21 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Hiện mật khẩu, tự động điền (UI-STT 46) | - |
| SCR-22 | Baymard: nhãn trên ô, gợi ý định dạng, chấp nhận nhiều định dạng nhập | Đạt | UI-STT 16, 32; khoảng trắng trong số điện thoại được bỏ trước khi kiểm | - |
| SCR-22 | Nielsen 9 Nhận biết, chẩn đoán, khắc phục lỗi | Đạt | MSG-04, MSG-05, MSG-89, MSG-90 nêu quy tắc và việc cần làm | - |
| SCR-23 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | Danh sách rỗng hiện MSG-91 (UI-STT 18) | - |
| SCR-24 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lối từ thông tin phim sang lịch chiếu (UC-003 Mục 8) | Chấp nhận theo Q-272 |
| SCR-24 | Nielsen 3 Kiểm soát và tự do | Đạt | Nút Quay lại danh sách phim (UI-STT 51) | - |
| SCR-25 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lối từ suất chiếu trong kết quả sang đặt vé (UC-004 Mục 8) | Chấp nhận theo Q-272; khách đặt vé từ SCR-03 |
| SCR-25 | Nielsen 1 Hiển thị trạng thái hệ thống | Đạt | MSG-92 khi không có suất chiếu; chữ Chưa mở bán cho suất chiếu chưa bán được vé | - |
| SCR-26 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm trong lịch sử đặt vé (UC-007 không nêu) | Chấp nhận, không thêm chức năng ngoài đặc tả |
| SCR-26 | Nielsen 3 | Đạt | Từ chối MSG-94 ở lại danh sách (UI-STT 29(2)) | - |
| SCR-27 | WCAG 1.1.1, 1.4.1 | Đạt | Mã QR có văn bản thay thế; trạng thái vé có chữ và biểu tượng (UI-STT 34, 13) | - |
| SCR-28 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận xoá phòng chiếu (MSG-110) | - |
| SCR-28 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục với SCR-19 (UI-STT 51) | - |
| SCR-29 | Nielsen 5 Ngăn lỗi | Đạt | Dòng sức chứa cập nhật ngay và nêu khoảng 50-400 (UI-STT 52) | - |
| SCR-29 | WCAG 2.1.1, 1.4.1, 2.5.8 | Đạt | Phím mũi tên, ba loại ghế khác biểu tượng và chữ, ô 44 px (UI-STT 52) | - |
| SCR-29 | WCAG 1.4.10 Reflow | Không áp dụng | Lưới ghế là nội dung hai chiều, cuộn trong hộp | Ghi ở UI-STT 52 |
| SCR-30 | Nielsen 2 Khớp thế giới thực | Đạt | Nhóm không có sức chứa hiện "không áp dụng" (UI-STT 53) | - |
| SCR-30 | Nielsen 1 | Đạt | MSG-134 trong lúc tính, MSG-116 khi kỳ không có suất chiếu | - |
| SCR-31 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục thẻ với SCR-02, SCR-09, SCR-17 (UI-STT 47) | - |
| SCR-32 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm phim (đặc tả không nêu) | Chấp nhận, không thêm chức năng ngoài đặc tả |
| SCR-33 | Nielsen 9 | Đạt | Mỗi điều kiện vi phạm có thông điệp riêng cạnh trường (MSG-95 đến MSG-98) | - |
| SCR-33 | Baymard: một cột, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-34 | Nielsen 4 Nhất quán | Đạt | Cùng bố cục với SCR-32, SCR-28 (UI-STT 51) | - |
| SCR-35 | Nielsen 9 | Đạt | MSG-101 nêu tên đã dùng và việc cần làm | - |
| SCR-36 | Nielsen 8 Thẩm mỹ, tối giản | Đạt | Hai bảng, không xếp hạng hay biểu đồ ngoài đặc tả (UI-STT 53) | - |
| SCR-36 | Nielsen 1 | Đạt | MSG-134, MSG-117 | - |
| SCR-37 | Nielsen 5 Ngăn lỗi | Đạt | Hộp xác nhận khoá, mở khoá nêu hậu quả (MSG-122, MSG-125) | - |
| SCR-37 | Nielsen 7 Linh hoạt và hiệu quả | Vi phạm còn mở (do phạm vi) | Không có lọc, tìm kiếm tài khoản (đặc tả không nêu) | Chấp nhận, không thêm chức năng ngoài đặc tả |
| SCR-38 | Nielsen 5 Ngăn lỗi | Đạt | Danh sách chọn cho vai trò, cụm rạp; cụm rạp bị vô hiệu với quản lý chuỗi | - |
| SCR-39 | Baymard: nhãn trên ô, giữ dữ liệu khi lỗi | Đạt | UI-STT 16, 20 | - |
| SCR-40 | WCAG 3.3.8 Xác thực dễ tiếp cận | Đạt | Hiện mật khẩu, không chặn dán (UI-STT 16, 46) | - |

Tổng hợp Shneiderman: nhất quán --> Đạt (UI-STT 05-09, 22, 47, 51); khả dụng cho mọi người dùng --> Đạt (UI-STT 15, 33-36, 52); phản hồi đầy đủ --> Đạt (UI-STT 27, 28, 40, 41, 43, 48); hội thoại có điểm kết thúc rõ --> Đạt (SCR-06, SCR-08, SCR-12, SCR-15, MSG-100, MSG-103, MSG-109, MSG-121); ngăn lỗi --> Đạt (UI-STT 19, 37, 52); hoàn tác dễ dàng --> Vi phạm còn mở (đặc tả không có hoàn tác); người dùng làm chủ --> Đạt (UI-STT 47, 50, Q-119); giảm tải trí nhớ ngắn hạn --> Đạt (UI-STT 39, 43, 44, 53).

Số dòng Vi phạm còn mở: 8; Vi phạm đã sửa: 4. Còn mở do phạm vi đặc tả: SCR-03, SCR-07, SCR-24, SCR-25, SCR-26, SCR-32, SCR-37; do ràng buộc NFR-13: SCR-16. Đã sửa: SCR-05, SCR-06, SCR-11 (Q-119), SCR-14 (Q-125). SCR-02 và SCR-17 hết vi phạm khi UC-001, UC-003, UC-004, UC-007, UC-012, UC-015 có màn hình.

## Câu hỏi mở

Xem ui-standards.md: Q-119 đến Q-125 (đã trả lời; Q-119 chờ người dùng xác nhận) và Q-272 đến Q-276 (mới, chờ xác nhận). Liên quan danh sách màn hình: Q-272 (lối từ tra cứu sang đặt vé), Q-273 (độ dài trường), Q-274 (mật khẩu nhân viên), Q-275 (điểm khởi đầu ACT-05, ACT-06), Q-276 (thông điệp tài khoản bị khoá).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F4 (PKG-05, PKG-06, PKG-08, PKG-31) | Màn hình đăng nhập và điều hướng của khách, nhân viên quầy, quản lý cụm rạp | Đã áp dụng: P10 2.0 có DC-LoginView (PKG-31), DC-CustomerHomeView, DC-CounterHomeView, DC-CinemaAdminHomeView |
| P10 | F4 (PKG-09) | Quản lý chuỗi có màn hình điều hướng SCR-31 nhưng PKG-09 chưa có View điều hướng | Thêm DC-ChainAdminHomeView vào PKG-09 |
| P10 | F3 (AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm), PKG-31 DC-LoginView | Mỗi boundary một View nhưng sinh nhiều màn hình (SCR-03 đến SCR-06, SCR-10 đến SCR-12); DC-LoginView phục vụ hai màn hình SCR-01, SCR-21 | Ghi ở P12: tách View thành các component trang; một component đăng nhập nhận tham số loại tài khoản (không có nội dung để sửa ở P10) |
| P04 | UC-004 Dữ liệu ra, Dữ liệu vào 1 STT 2 | Bộ lọc tỉnh, thành phố không có dữ liệu ra cấp danh sách giá trị | Thêm dữ liệu ra các tỉnh, thành phố có cụm rạp, hoặc ghi rõ khách nhập tự do |
| P04 | UC-005 luồng 7 | P09 EX-01 kiểm "đã mở bán" ở bước 7 nhưng không có luồng thay thế cho suất chiếu chưa mở bán ở bước 7 | Thêm luồng từ chối giữ ghế vì suất chiếu chưa mở bán (BR-01); màn hình dùng MSG-84 |
| P08 | AC-B-BookTicketsForm | Chưa có trách nhiệm đọc lần giữ ghế đang chạy của người dùng (dải Tiếp tục thanh toán) | Thêm loadRunningHold cho boundary đặt vé khách và quầy |

## Vấn đề còn mở

1. Chưa lập mockup HTML (XUAT_HTML = Không).
2. Các vi phạm còn mở trong bảng F7 do phạm vi đặc tả (SCR-03, SCR-07, SCR-24, SCR-25, SCR-26, SCR-32, SCR-37) hoặc ràng buộc NFR-13 (SCR-16).
3. Thông điệp của mọi SCR đã nằm trong danh mục MSG của ui-standards.md (mục h của mọi SCR ghi Không có), mọi ngoại lệ đã đưa vào quy định gốc; không có dòng nào để gom thêm.
