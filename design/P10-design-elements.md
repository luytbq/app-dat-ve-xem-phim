# P10 - Phần tử thiết kế - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P10 |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Chạy lại theo P08 2.0 và P09 2.0 (16 use case, 55 lớp phân tích, EX-01 đến EX-22, 14 hạng khoá 0 đến 13): ánh xạ đủ 55 lớp (thêm 10 cặp View và Store, 10 lớp dịch vụ, DC-Staff, DC-ReportPeriod, DC-ReportGroup); thêm PKG-30 ChainManagement, PKG-31 SessionClient của P09 và hai package mới PKG-32 StaffAccounts, PKG-33 ReportModel; IF-28 IReportRepository mới; IF-15 chuyển từ PKG-27 sang PKG-32; DC-LoginView chuyển từ PKG-05 sang PKG-31; IF-08 thêm khoá theo giá trị (LockValue, DC-ValueLockKind); kiểm phiên theo mốc ở DC-AccessCheckService (PKG-19); F3a thêm EX-16 đến EX-22, sửa EX-01, EX-13, EX-15 và thêm các thao tác không là EX; giữ DC-Showtime, DC-Auditorium một lớp và giữ ba lớp con của Staff (Vấn đề còn mở 9, 10); Q-265 đến Q-270 đóng theo đề xuất; Q-271 |
| Thay đổi 1.5 | Đồng bộ X3 lần 2 (design/_sync-log.md): thêm DC-HoldSettlement, IF-26, IF-27 ở PKG-28 (X1 RV-01, RV-06; P12 1.6); EX-01 đến EX-08, EX-13, EX-14 ghi lớp và interface sau khi gom và tách; câu cam kết đổi cổng khớp Q-141 |
| Thay đổi 1.4 | EX-10 chỉ khoá RefundRequest X, email hoàn chỉ với hoàn toàn bộ (RF-03, RF-09); TxOptions có hạn tổng (RF-05); lý do BEING_RELEASED (RF-17); đóng Vấn đề còn mở 1 (RF-15); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M6); project-profile.md (mục 3, CONG_NGHE đã chốt theo P09 F11); P01-actors.md 1.2 (Mục 1, 2); P02-usecases.md 1.9 (Mục 4); P03-usecase-model.md 1.2 (bảng quan hệ, không có dòng extend); P05-glossary.md 1.2 (tra tên thuật ngữ); P06-supplementary-spec.md 1.4 (NFR về thay thế, bảo mật, giao tiếp ngoài); P08-analysis-model.md 2.0 (F3, F4, F4b, Câu hỏi mở gồm Q-265, Q-266 đã trả lời theo đề xuất, Đề xuất sửa artifact trước, Vấn đề còn mở); P09-architecture.md 2.0 (F3 đến F8, F7.3, F7.11, F7.12, F11, Câu hỏi mở gồm Q-267 đến Q-270 đã trả lời theo đề xuất, Đề xuất sửa artifact trước, Vấn đề còn mở 8); design/_sync-log.md (mục Đầu vào cho lần chạy lại P08-P13, các dòng P10) |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-271 (Q-265 đến Q-270 đã trả lời theo đề xuất, không cấp lại); không có ASM (NGHIEM_NGAT) |

Trọng tâm: giữ nguyên ngữ nghĩa 22 đơn vị loại trừ EX-01 đến EX-22 và thứ tự khoá 14 hạng (0 đến 13) của P08 F4b khi chuyển sang phần tử thiết kế. Bốn điểm chốt: (1) lớp dịch vụ ở Application là nơi duy nhất mở giao dịch (qua IF-08) và lấy khoá theo hạng, mọi khoá đi qua interface kho dữ liệu hoặc IF-08 (khoá theo giá trị) và bị DC-LockOrderGuard kiểm thứ tự; mỗi EX có đúng một lớp dịch vụ mở giao dịch (F3a); (2) công việc dọn hết hạn, giải phóng ghế, gửi hoàn tiền, gửi email là các lớp hiện thực IF-06 do subsystem Scheduler SS-04 gọi, không có bộ đếm giờ trong bộ nhớ; (3) cập nhật sơ đồ ghế đi qua subsystem SeatEventHub SS-03 đọc bảng seat_event, còn tiếp nhận IPN của cổng thanh toán đi qua điểm vào PKG-12 và subsystem SS-01; (4) khoá theo giá trị (tên cụm rạp, email khách, số điện thoại khách, email nhân viên) là khoá tư vấn lấy qua IF-08, còn kiểm phiên của nhân viên theo mốc truy cập (BR-101) nằm ở một nơi duy nhất, DC-AuthFilter gọi DC-AccessCheckService, không khoá. Công nghệ theo P09 F11: Go (net/http, pgx), React SPA, PostgreSQL 15 trở lên, VNPay sandbox, SMTP. Thiết kế chi tiết operation thuộc P11b (IF-01 đến IF-07) và P12 (IF-08 trở đi, lớp thiết kế).

Kết quả: 219 phần tử thiết kế gồm 5 subsystem, 26 interface (28 mã IF-01 đến IF-28, IF-09 và IF-10 trạng thái Loại) và 188 lớp thiết kế (kể cả kiểu giá trị, enumeration và ngoại lệ; 9 lớp trạng thái Gộp hoặc Loại ở mục "Phần tử bị gộp hoặc loại" không tính) trong 29 package (PKG-05 đến PKG-31 của P09, PKG-32 và PKG-33 mới); 55 lớp phân tích có đúng một dòng ánh xạ.

## F1. Subsystem ứng viên và quyết định

| Lớp phân tích (AC) | Tiêu chí thoả | Quyết định | Lý do |
|---|---|---|---|
| AC-B-PaymentGateway | Hệ thống ngoài; Giao tiếp với cổng (NFR-15 đến NFR-17), đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14 (Q-141); Bảo mật (chữ ký, số tiền) | Subsystem | SS-01. Che giao thức ký URL, kiểm chữ ký thông báo, máy khách hoàn tiền, định dạng thông báo gửi từ cổng (mã trả lời RspCode do PKG-12 dịch). Interface tách hai vai trò (IF-01 gọi ra, IF-02 nhận thông báo). Nếu không là subsystem thì DC-PaymentReportService và DC-RefundService phụ thuộc trực tiếp vào giao thức của VNPay |
| AC-B-EmailService | Hệ thống ngoài; Có thể thay thế (đổi nhà cung cấp SMTP, NFR-18) | Subsystem | SS-02. Dù chỉ gửi một chiều, việc gửi có thời gian chờ 30 giây, thử lại, Message-ID chống lặp (P09 F7.7, BR-89) nên không phải "một thông điệp một chiều rất đơn giản" |
| - (PKG-24 của P09) | Dịch vụ phức tạp dùng chung (đọc seat_event định kỳ, cửa sổ chồng 10 giây, phát lại từ con trỏ, hàng đợi từng kết nối); Che giấu được bên trong | Subsystem | SS-03. Phục vụ UC-005 (đã có P07, trách nhiệm updateSeatMap của hai boundary đặt vé) và UC-008 (ghế trả về trống). Interface chỉ gồm đăng ký, huỷ đăng ký, chuyển sự kiện nên Application không biết cơ chế bảng sự kiện |
| - (PKG-25 của P09) | Dịch vụ phức tạp dùng chung (chạy định kỳ, chống chạy chồng, ngân sách thời gian, pool riêng); Che giấu được bên trong | Subsystem | SS-04. Phục vụ UC-005 (hết hạn, giải phóng ghế) và UC-006, UC-008 (hoàn tiền), đều đã có P07. Thoả A1: package hạ tầng không có lớp phân tích nguồn và có use case đã có P07 |
| - (PKG-26 của P09) | Bảo mật (giới hạn truy cập); Dịch vụ dùng chung | Subsystem | SS-05. UC-005 đã có P07 và dùng checkCustomerLoggedIn, authenticateCustomer; UC-001, UC-017 băm mật khẩu khi đăng ký, tạo và đặt lại mật khẩu; kiểm chữ ký và hạn mã phiên của mọi yêu cầu (BR-101, P09 F7.11). Băm mật khẩu và mã phiên (NFR-01 đến NFR-03, NFR-10) cần che sau một interface duy nhất |
| - (PKG-21 của P09) | Không | Không | A1: phần hiện thực interface kho dữ liệu không thành subsystem; ghi ở bảng phần tử thiết kế mới do cơ chế (F3). Interface kho nằm ở Domain (P09 F5) |
| 17 lớp boundary giao diện người dùng (AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm, AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm, AC-B-CheckTicketForm, AC-B-ManagePriceListForm, AC-B-ScheduleShowtimesForm, AC-B-BrowseMoviesForm, AC-B-BrowseShowtimesForm, AC-B-RegisterAccountForm, AC-B-ViewBookingHistoryForm, AC-B-ManageAuditoriumsForm, AC-B-ViewCinemaReportForm, AC-B-ManageMoviesForm, AC-B-ManageCinemasForm, AC-B-ViewChainReportForm, AC-B-ManageStaffAccountsForm) | Không (boundary giao diện người dùng) | Không | Thành View và Store ở package theo tác nhân (F3). Camera đọc mã QR là kênh nhập của PKG-07 (P09 F5), không là subsystem. Phần giữ mã phiên và màn đăng nhập ở trình duyệt (PKG-31) không là hệ thống ngoài hay thiết bị nên không là subsystem |
| 16 lớp control (AC-C-BookTicketsController, AC-C-PaymentReportController, AC-C-CancelTicketController, AC-C-CheckTicketController, AC-C-ManagePriceListController, AC-C-ScheduleShowtimesController, AC-C-BrowseMoviesController, AC-C-BrowseShowtimesController, AC-C-ManageAuditoriumsController, AC-C-ManageCinemasController, AC-C-ManageMoviesController, AC-C-ManageStaffAccountsController, AC-C-RegisterAccountController, AC-C-ViewBookingHistoryController, AC-C-ViewChainReportController, AC-C-ViewCinemaReportController) | Không | Không | Lỗi thường gặp: biến control thành subsystem vì "có nhiều bước". Control thành lớp dịch vụ ở Application, không che giấu được gì mà Application cần che |
| 20 lớp entity (AC-E-*) | Không | Không | Lớp miền ở Domain, không có tiêu chí subsystem. AC-E-ReportPeriod, AC-E-ReportGroup không lưu và không có interface kho dữ liệu của riêng chúng |

Không có boundary giao diện thiết bị trong P08: máy in là chức năng in của trình duyệt (P01 Mục 1) và camera là kênh nhập của giao diện soát vé. Subsystem SS-03, SS-04, SS-05 không có lớp phân tích nguồn tương ứng một-một; chúng được xét theo A1 vì phục vụ use case đã có P07. Cả 16 use case đã có P07 nên không còn package giữ chỗ: PKG-09, PKG-10, PKG-17, PKG-18, PKG-19 đã có phần tử thiết kế, PKG-30 và PKG-31 của P09 không cần subsystem (lớp dịch vụ thường và phần tử chạy trong trình duyệt).

## F2. Bảng subsystem

| SS | Tên | Interface (IF) | Trách nhiệm | Che giấu phần tử nào | AC nguồn | ACT liên quan | PKG chứa |
|---|---|---|---|---|---|---|---|
| SS-01 | PaymentGateway | IF-01 IPaymentGateway<br>IF-02 IPaymentReportReceiver | // createPaymentTransaction: ký URL thanh toán chứa mã giao dịch và mã tham chiếu lần giữ ghế, không gọi mạng (UC-005)<br>// requestRefund: gửi hoàn tiền kèm khoá chống hoàn trùng, chờ 30 giây (UC-006, UC-008, BR-43, NFR-17)<br>// findRefund: tra cứu giao dịch hoàn trước khi gửi lại (cơ chế P09 F7.7); không tra cứu được kết quả hoàn thì bên gọi chuyển Cần xử lý thủ công, không gửi lại tự động (Q-118)<br>// reportTransactionResult: kiểm chữ ký, giải mã số tiền của thông báo, dịch thành kết quả; DC-PaymentReportService so số tiền với bản ghi (UC-005, UC-006, NFR-16) | Bộ ký URL thanh toán theo chuẩn của cổng; bộ kiểm chữ ký thông báo; máy khách REST hoàn tiền và tra cứu giao dịch hoàn có thời gian chờ 30 giây; bộ dịch mã kết quả; cấu hình môi trường sandbox | AC-B-PaymentGateway | ACT-07 | PKG-22 |
| SS-02 | EmailGateway | IF-03 IEmailSender | // sendEmail: gửi một thư đã dựng sẵn (email chứa vé của UC-005, email thông báo hoàn tiền của UC-006); nội dung thư do DC-EmailOutboxJob dựng; Message-ID lấy từ khoá chống lặp (P09 F7.7) | Máy khách SMTP; bộ dựng thư MIME; cấu hình TLS; thời gian chờ 30 giây | AC-B-EmailService | ACT-08 | PKG-23 |
| SS-03 | SeatEventHub | IF-04 ISeatEventSubscription | // subscribe: đăng ký nhận sự kiện đổi ghế của một suất chiếu từ một con trỏ, trả luồng sự kiện phát lại rồi trực tiếp; bên gọi đọc luồng (mô hình kéo, P09 F7.5, REQ-119, NFR-08, NFR-09)<br>// unsubscribe: huỷ đăng ký khi kết nối đóng | Bộ đọc seat_event mỗi 500 ms qua IF-22; tập mã đã phát 20 giây gần nhất; mốc W với cửa sổ chồng 10 giây; bộ phát lại từ con trỏ; danh sách kết nối theo suất chiếu; hàng đợi 256 sự kiện mỗi kết nối, đầy thì đóng kết nối | Cơ chế: P09 F7.5; updateSeatMap của AC-B-BookTicketsForm và AC-B-CounterBookTicketsForm thành luồng sự kiện do IF-04 trả, DC-SeatMapStreamController ghi ra kết nối, DC-SeatMapReducer áp dụng phía trình duyệt | ACT-01, ACT-02 | PKG-24 |
| SS-04 | Scheduler | IF-05 IJobScheduler | // registerJob: đăng ký công việc và chu kỳ (hàm khởi động chương trình gọi)<br>// start: bắt đầu chạy định kỳ trên mọi bản backend<br>// stop: dừng khi tắt chương trình; mỗi công việc không chạy chồng và có ngân sách 8 giây mỗi lượt (P09 F7.4) | Vòng lặp chu kỳ; cờ đang chạy của từng công việc; bộ ngắt công việc theo ngân sách 8 giây mỗi lượt (pool kết nối nền 5 kết nối thuộc DC-ConnectionPools ở PKG-21, Scheduler không dùng trực tiếp) | Cơ chế: P09 F7.4, F7.7; AC-C-BookTicketsController.startWaitingForHoldExpiry | ACT-01, ACT-02, ACT-07, ACT-08 (gián tiếp) | PKG-25 |
| SS-05 | Security | IF-07 IAuthenticator | // hashPassword, verifyPassword: băm và kiểm mật khẩu (AC-E-Customer.authenticateCustomer, đăng ký khách UC-001, tạo và đặt lại mật khẩu nhân viên UC-017, NFR-01 đến NFR-03)<br>// issueSession, verifySession: cấp và kiểm mã phiên tự kiểm chứng được, mang mã chủ thể, vai trò, cụm rạp, loại chủ thể (khách hoặc nhân viên) và với nhân viên là mốc truy cập access_changed_at đã đọc lúc đăng nhập (AC-C-BookTicketsController.checkCustomerLoggedIn, P09 F7.8, F7.11, Q-267); việc so mốc với dòng Staff không thuộc SS-05 mà do DC-AccessCheckService (PKG-19) làm<br>// checkRole: kiểm vai trò được phép (P09 F4) | Bộ băm mật khẩu; bộ ký và kiểm mã phiên; bảng vai trò theo tác nhân | Cơ chế: P09 F4 (PKG-26), F7.11; NFR-10 | ACT-01 đến ACT-06 | PKG-26 |

Interface gọi ngược:

| IF | Tên | Định nghĩa tại PKG | Subsystem gọi | Lớp hiện thực (DC, PKG) | Trách nhiệm | Nguồn (P09 A5, UC) |
|---|---|---|---|---|---|---|
| IF-06 | IScheduledJob | PKG-25 | SS-04 Scheduler | DC-HoldExpiryJob (kèm dọn seat_event), DC-SeatReleaseJob (PKG-13)<br>DC-RefundOutboxJob (PKG-14)<br>DC-EmailOutboxJob (PKG-20) | // runDue: chạy một lượt công việc đến hạn, trả khi hết việc hoặc hết ngân sách thời gian; chạy lặp an toàn (EX-04, EX-05 theo lô, claim hàng đợi) | P09 A5, F4, F7.4, F7.7; UC-005 luồng 7b, 11a; UC-006 bước 4 đến 7; UC-008 bước 5, 6; NFR-07 |

IF-06 là interface gọi ngược duy nhất: Scheduler ở Services gọi lên Application, nên interface do Scheduler định nghĩa và Application hiện thực (realization đi xuống). Việc đăng ký các lớp hiện thực vào SS-04 qua IF-05 làm ở hàm khởi động chương trình, ngoài mô hình package (P09 F4). SS-01 và SS-02 không đẩy lời gọi ngược lên: kết quả hoàn tiền và gửi email trả về đồng bộ cho công việc nền đang gọi. Đường vào của hệ thống ngoài đẩy sự kiện vào hệ thống như sau.

| Hệ thống ngoài | Điểm vào | Đường đi | Cần interface gọi ngược |
|---|---|---|---|
| ACT-07 Cổng thanh toán (IPN) | DC-PaymentCallbackController (PKG-12) | Cổng --> DC-PaymentCallbackController --> DC-PaymentReportService (PKG-14), trong đó gọi IF-02 để kiểm chữ ký; DC-IpnAnswer trả ngược lên điểm vào, DC-PaymentCallbackController dịch sang câu trả lời của cổng | Không: mọi lời gọi đi xuống (Presentation --> Application --> Services); SS-01 không tự gọi lên |
| Trình duyệt (kết nối đẩy sơ đồ ghế) | DC-SeatMapStreamController (PKG-11) | Trình duyệt --> DC-SeatMapStreamController --> DC-SeatMapService --> IF-04; IF-04 trả luồng DC-SeatChangeEvent cho DC-SeatMapService, DC-SeatMapService dịch thành khung SSE dạng văn bản (id sự kiện, dữ liệu) rồi trả luồng khung lên; DC-SeatMapStreamController chỉ đọc khung và ghi ra kết nối, không chạm kiểu của Domain | Không: bên gọi giữ luồng, không có đăng ký bộ nhận ở layer cao hơn |


## F3. Bảng ánh xạ lớp phân tích sang phần tử thiết kế

| AC | Kết quả (Lớp thiết kế DC / Subsystem SS / Package / Tách thành nhiều lớp) | Phần tử thiết kế | PKG | Lý do |
|---|---|---|---|---|
| AC-B-BookTicketsForm | Tách thành nhiều lớp | DC-BookTicketsView<br>DC-BookTicketsStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); cập nhật sơ đồ ghế (updateSeatMap) do PKG-29 và SS-03 đảm nhận |
| AC-B-CounterBookTicketsForm | Tách thành nhiều lớp | DC-CounterBookTicketsView<br>DC-CounterBookTicketsStore | PKG-06 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); cập nhật sơ đồ ghế do PKG-29; in vé là chức năng in của trình duyệt (P01: máy in nối qua máy tính tại quầy) |
| AC-B-PaymentGateway | Subsystem (SS) | SS-01<br>IF-01<br>IF-02 | PKG-22 | Hệ thống ngoài (F1; đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14, Q-141); IF-01 cho chiều hệ thống --> cổng, IF-02 cho chiều cổng --> hệ thống (kiểm chữ ký, dịch kết quả) |
| AC-B-EmailService | Subsystem (SS) | SS-02<br>IF-03 | PKG-23 | Hệ thống ngoài, có thể thay thế (F1) |
| AC-B-CancelTicketForm | Tách thành nhiều lớp | DC-CancelTicketView<br>DC-CancelTicketStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-CounterCancelTicketForm | Tách thành nhiều lớp | DC-CounterCancelTicketView<br>DC-CounterCancelTicketStore | PKG-06 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-CheckTicketForm | Tách thành nhiều lớp | DC-CheckTicketView<br>DC-CheckTicketStore | PKG-07 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); camera đọc mã QR dùng thư viện đọc QR có sẵn gọi từ DC-CheckTicketView, không thành lớp thiết kế (DC-QrCameraScanner trạng thái Loại) |
| AC-B-ManagePriceListForm | Tách thành nhiều lớp | DC-ManagePriceListView<br>DC-ManagePriceListStore | PKG-08 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-ScheduleShowtimesForm | Tách thành nhiều lớp | DC-ScheduleShowtimesView<br>DC-ScheduleShowtimesStore | PKG-08 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-BrowseMoviesForm | Tách thành nhiều lớp | DC-BrowseMoviesView<br>DC-BrowseMoviesStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-CatalogController (UC-003) |
| AC-B-BrowseShowtimesForm | Tách thành nhiều lớp | DC-BrowseShowtimesView<br>DC-BrowseShowtimesStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-CatalogController (UC-004) |
| AC-B-RegisterAccountForm | Tách thành nhiều lớp | DC-RegisterAccountView<br>DC-RegisterAccountStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-AccountController (UC-001) |
| AC-B-ViewBookingHistoryForm | Tách thành nhiều lớp | DC-ViewBookingHistoryView<br>DC-ViewBookingHistoryStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-TicketController (UC-007) |
| AC-B-ManageAuditoriumsForm | Tách thành nhiều lớp | DC-ManageAuditoriumsView<br>DC-ManageAuditoriumsStore | PKG-08 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-PricingScheduleController (UC-012; tên giữ nguyên vì cùng nhóm cấu hình cụm rạp) |
| AC-B-ViewCinemaReportForm | Tách thành nhiều lớp | DC-ViewCinemaReportView<br>DC-ViewCinemaReportStore | PKG-08 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-ReportController (UC-015) |
| AC-B-ManageMoviesForm | Tách thành nhiều lớp | DC-ManageMoviesView<br>DC-ManageMoviesStore | PKG-09 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-ChainController (UC-010) |
| AC-B-ManageCinemasForm | Tách thành nhiều lớp | DC-ManageCinemasView<br>DC-ManageCinemasStore | PKG-09 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-ChainController (UC-011) |
| AC-B-ViewChainReportForm | Tách thành nhiều lớp | DC-ViewChainReportView<br>DC-ViewChainReportStore | PKG-09 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-ReportController (UC-016) |
| AC-B-ManageStaffAccountsForm | Tách thành nhiều lớp | DC-ManageStaffAccountsView<br>DC-ManageStaffAccountsStore | PKG-10 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); REST controller là DC-AccountController (UC-017). 20 trách nhiệm là sáu thao tác của một use case và chỉ giao tiếp với tác nhân (P08 Vấn đề còn mở 2) nên giữ một View và một Store, không tách thêm |
| AC-C-BookTicketsController | Tách thành nhiều lớp | DC-BookTicketsService<br>DC-HoldExpiryJob | PKG-13 | Control thành lớp dịch vụ ứng dụng (P09 F5), đổi tên Controller thành Service vì Controller đã là REST controller ở PKG-11. Ba trách nhiệm chờ hết hạn (startWaitingForHoldExpiry, stopWaitingForHoldExpiry, handleHoldExpired) không giữ bộ đếm giờ trong control (P09 A7, F7.4): hết hạn là cột expiry_time và công việc nền DC-HoldExpiryJob quét theo lô; cùng lượt chạy, DC-HoldExpiryJob xoá seat_event cũ hơn 10 phút theo lô (P09 F7.5 điểm 6, gộp từ DC-SeatEventCleanupJob) |
| AC-C-PaymentReportController | Tách thành nhiều lớp | DC-PaymentReportService<br>DC-RefundService<br>DC-RefundOutboxJob | PKG-14 | Đổi tên Controller thành Service như trên. handlePaymentReport và logUnrecognizedTransaction (EX-02) thuộc DC-PaymentReportService. Bốn trách nhiệm hoàn tiền (startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure) lặp với AC-C-CancelTicketController nên gom vào DC-RefundService theo Q-106; việc chờ 30 giây và thử lại chạy qua hàng đợi gửi do DC-RefundOutboxJob (P09 F7.7). DC-PaymentReportService cũng đọc trạng thái giao dịch cho địa chỉ trả về và trang kết quả (ResolveReturnedPayment, QueryPaymentStatus), không đổi dữ liệu |
| AC-C-CancelTicketController | Tách thành nhiều lớp | DC-CancelTicketService<br>DC-RefundService | PKG-15; PKG-14 | Đổi tên Controller thành Service. Bốn trách nhiệm hoàn tiền chuyển sang DC-RefundService dùng chung (Q-106, ở dòng trên); phần còn lại (requestCancellation, findBookingTickets, confirmCashRefund) ở DC-CancelTicketService |
| AC-C-CheckTicketController | Lớp thiết kế (DC) | DC-CheckTicketService | PKG-15 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller) |
| AC-C-ManagePriceListController | Lớp thiết kế (DC) | DC-ManagePriceListService | PKG-16 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller) |
| AC-C-ScheduleShowtimesController | Lớp thiết kế (DC) | DC-ScheduleShowtimesService | PKG-16 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Điều phối cả kiểm lần giữ ghế đang hiệu lực, kiểm vé chưa huỷ và tạo, giải phóng SeatStatus của EX-13, EX-14 (Q-117); kiểm lại phim hiện hành (hạng 10, IF-14) và phòng còn tồn tại trong cùng thao tác (UC-014 luồng 8g, 8h) |
| AC-C-BrowseMoviesController | Lớp thiết kế (DC) | DC-BrowseMoviesService | PKG-17 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Chỉ đọc, không là EX: đọc không khoá qua IF-14 (UC-003) |
| AC-C-BrowseShowtimesController | Lớp thiết kế (DC) | DC-BrowseShowtimesService | PKG-17 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Chỉ đọc, không là EX: đọc không khoá qua IF-11, IF-13, IF-14; lọc theo phim, cụm rạp, ngày chiếu theo múi giờ nghiệp vụ (UC-004, Q-268) |
| AC-C-ManageAuditoriumsController | Lớp thiết kế (DC) | DC-ManageAuditoriumsService | PKG-16 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Lớp mở giao dịch của EX-15, EX-18, EX-19 (P08 Đề xuất sửa artifact trước, P09 Đề xuất sửa artifact trước). Điều phối cả việc tạo, bỏ SeatStatus của suất chiếu chưa mở bán qua IF-18 trong chuỗi khoá của EX-15 (Q-117, Q-249): DC-Showtime.adoptSeatMap chỉ tính phần ghế thêm và ghế bỏ vì PKG-27 không gọi PKG-28 |
| AC-C-ManageCinemasController | Lớp thiết kế (DC) | DC-ManageCinemasService | PKG-30 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Lớp mở giao dịch của EX-17; thêm cụm rạp tạo kèm bảng giá rỗng qua IF-13, IF-12 trong cùng giao dịch (P08 F2c) |
| AC-C-ManageMoviesController | Lớp thiết kế (DC) | DC-ManageMoviesService | PKG-30 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Lớp mở giao dịch của EX-16; thêm phim không là EX (tên được trùng, P08 F4b EX-16) |
| AC-C-ManageStaffAccountsController | Lớp thiết kế (DC) | DC-ManageStaffAccountsService | PKG-19 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Lớp mở giao dịch của EX-21 (băm mật khẩu ban đầu qua IF-07 xong trước khi mở giao dịch) và EX-22 |
| AC-C-RegisterAccountController | Lớp thiết kế (DC) | DC-RegisterAccountService | PKG-19 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Lớp mở giao dịch của EX-20; băm mật khẩu qua IF-07 xong trước khi mở giao dịch (băm chậm, không giữ khoá lúc băm) |
| AC-C-ViewBookingHistoryController | Lớp thiết kế (DC) | DC-ViewBookingHistoryService | PKG-15 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Chỉ đọc, không là EX: đọc không khoá lịch sử của khách đã đăng nhập qua IF-20 (UC-007) |
| AC-C-ViewChainReportController | Lớp thiết kế (DC) | DC-ViewChainReportService | PKG-18 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Không là EX (P08 F4b mục 6): giao dịch chỉ đọc REPEATABLE READ READ ONLY ở pool báo cáo, không giữ khoá; số liệu gộp lấy qua IF-28 (P09 F7.12) |
| AC-C-ViewCinemaReportController | Lớp thiết kế (DC) | DC-ViewCinemaReportService | PKG-18 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Như DC-ViewChainReportService; cụm rạp của báo cáo lấy từ dòng Staff hiện hành của phiên, không tin tham số của trình duyệt (P09 F7.12) |
| AC-E-Staff | Lớp thiết kế (DC) | DC-Staff | PKG-32 | Lớp cha của DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager (Q-228); giữ vai trò, trạng thái, cụm rạp (0..1) và mốc truy cập access_changed_at; quản lý chuỗi là giá trị vai trò, không có lớp con (P08 F2a STT 41). Đặt ở PKG-32 thay vì PKG-27 của P09 F8 vì Staff đổi theo UC-017 còn PKG-27 đổi theo cấu hình rạp (CCP) và để PKG-27 không vượt 15 phần tử (Vấn đề còn mở 11) |
| AC-E-Customer | Lớp thiết kế (DC) | DC-Customer | PKG-28 | Lớp đơn giản, một trừu tượng. authenticateCustomer chỉ giữ dữ liệu đăng nhập; kiểm mật khẩu do IF-07 (SS-05) qua DC-LoginService, mã phiên kiểm ở PKG-11. checkRegistrationData, saveCustomer của EX-20 do DC-RegisterAccountService gọi dưới khoá giá trị email và số điện thoại (hạng 11, 12); checkHasBookings, provideBookingHistory, checkOwnsBooking phục vụ DC-ViewBookingHistoryService |
| AC-E-BoxOfficeClerk | Lớp thiết kế (DC) | DC-BoxOfficeClerk | PKG-28 | Lớp đơn giản, một trừu tượng; kế thừa DC-Staff (PKG-28 --> PKG-32); đặt cùng PKG-28 với SeatHold vì cùng kiểm BR-04 (P09 F4) |
| AC-E-TicketChecker | Lớp thiết kế (DC) | DC-TicketChecker | PKG-32 | Lớp con của DC-Staff, chỉ kế thừa // provideCinema, không có trách nhiệm riêng; giữ làm lớp con vì GL-36 là thuật ngữ riêng và đó là cách ít đổi nhất (Vấn đề còn mở 9) |
| AC-E-CinemaManager | Lớp thiết kế (DC) | DC-CinemaManager | PKG-32 | Lớp con của DC-Staff, chỉ kế thừa // provideCinema, không có trách nhiệm riêng; giữ làm lớp con vì GL-42 là thuật ngữ riêng và đó là cách ít đổi nhất (Vấn đề còn mở 9) |
| AC-E-Cinema | Lớp thiết kế (DC) | DC-Cinema | PKG-27 | Lớp đơn giản, một trừu tượng. Thêm cụm rạp tạo kèm bảng giá rỗng (EX-17, P08 F2c) do DC-ManageCinemasService gọi IF-13 và IF-12 trong cùng giao dịch; checkNameTaken kiểm dưới khoá giá trị tên cụm rạp (hạng 0) |
| AC-E-Auditorium | Lớp thiết kế (DC) | DC-Auditorium | PKG-27 | Lớp đơn giản, một trừu tượng, giữ 20 trách nhiệm trong một lớp (Vấn đề còn mở 10). saveShowtime chỉ kiểm khoảng cách phòng (checkRoomGap); kiểm SeatHold, vé và tạo, giải phóng SeatStatus do DC-ScheduleShowtimesService điều phối (Q-117, EX-13); applyChanges của EX-15 chỉ tính sơ đồ ghế mới, SeatStatus của suất chiếu do DC-ManageAuditoriumsService cập nhật qua IF-18 nên PKG-27 không phụ thuộc PKG-28 |
| AC-E-Seat | Lớp thiết kế (DC) | DC-Seat | PKG-27 | Lớp đơn giản, một trừu tượng. Ghế bỏ khỏi sơ đồ chỉ đánh dấu (retireFromSeatMap, inSeatMap), không xoá, vì SeatStatus của suất chiếu đã kết thúc hoặc đã xoá vẫn tham chiếu (BR-118) |
| AC-E-Movie | Lớp thiết kế (DC) | DC-Movie | PKG-27 | Lớp đơn giản, một trừu tượng. Lưu phim sửa là EX-16 do DC-ManageMoviesService; EX-13 đọc phim ở hạng 10 (S) để kiểm lại phim hiện hành |
| AC-E-Showtime | Lớp thiết kế (DC) | DC-Showtime | PKG-27 | Lớp đơn giản, một trừu tượng, giữ 25 trách nhiệm trong một lớp (Vấn đề còn mở 10). Phần kiểm tra và chốt giá của holdSeats ở DC-Showtime; việc tạo SeatHold và đổi SeatStatus do DC-BookTicketsService gọi DC-SeatHold, DC-SeatStatus trong cùng giao dịch và cùng chuỗi khoá (Q-117). checkNoActiveHoldOrSoldTicket và tạo trạng thái ghế (Q-109) do DC-ScheduleShowtimesService điều phối qua IF-17, IF-18, IF-27, cùng nguyên tắc Q-117. provideReportFigures không gọi theo từng suất chiếu: số liệu báo cáo gộp ở IF-28 (P09 F7.12). adoptSeatMap của EX-15 chỉ tính ghế thêm, ghế bỏ; DC-ManageAuditoriumsService cập nhật SeatStatus qua IF-18 (Q-249) |
| AC-E-PriceList | Lớp thiết kế (DC) | DC-PriceList | PKG-27 | Lớp đơn giản, một trừu tượng. Bảng giá rỗng tạo cùng cụm rạp (EX-17); checkCoversShowtime phục vụ EX-13, EX-15 |
| AC-E-PriceEntry | Lớp thiết kế (DC) | DC-PriceEntry | PKG-27 | Lớp đơn giản, một trừu tượng |
| AC-E-SeatStatus | Lớp thiết kế (DC) | DC-SeatStatus | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-SeatHold | Lớp thiết kế (DC) | DC-SeatHold | PKG-28 | Lớp đơn giản, một trừu tượng. releaseHeldSeats do DC-SeatReleaseJob và các service gọi (bảng cơ chế) |
| AC-E-PaymentTransaction | Lớp thiết kế (DC) | DC-PaymentTransaction | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-RefundRequest | Lớp thiết kế (DC) | DC-RefundRequest | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-Booking | Lớp thiết kế (DC) | DC-Booking | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-Ticket | Lớp thiết kế (DC) | DC-Ticket | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-ReportGroup | Lớp thiết kế (DC) | DC-ReportGroup | PKG-33 | Không lưu; addShowtimeFigures nhận số liệu đã gộp của IF-28 (DC-ReportFigures) thay vì duyệt từng suất chiếu; tính tỉ lệ lấp đầy, sức chứa bằng 0 thì không áp dụng (P09 F7.12) |
| AC-E-ReportPeriod | Lớp thiết kế (DC) | DC-ReportPeriod | PKG-33 | Không lưu, chỉ sống trong một yêu cầu báo cáo; kiểm từ ngày không sau đến ngày (GL-66) và đổi thành khoảng thời điểm theo múi giờ nghiệp vụ (P09 F7.12, Q-268). Đặt ở PKG-33 (Vấn đề còn mở 11) |

Tỷ lệ tách: 20 trên 55 lớp là "Tách thành nhiều lớp" (36%, gồm 17 boundary người dùng thành View và Store, ba control BookTickets, PaymentReport, CancelTicket), 2 lớp là Subsystem, 33 lớp ánh xạ 1-1. Mọi lớp trong P08 F3 (55 lớp Hoạt động) có đúng một dòng; không lớp nào có trạng thái "Gộp vào" hay "Tạm".

Phần tử thiết kế mới do cơ chế kiến trúc (không từ một dòng ở bảng trên; mọi phần tử đều truy được về P09 hoặc lớp phân tích):

| DC, SS hoặc IF | Tên | PKG | Cơ chế (Persistence, Logging, Bảo mật...) | Nguồn (P09 mục, NFR) |
|---|---|---|---|---|
| DC-SeatMapSyncClient | SeatMapSyncClient | PKG-29 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 (SSE, tải ảnh chụp, nối lại, nhịp tim 20 giây, tải lại có độ trễ ngẫu nhiên); AC-B-BookTicketsForm.updateSeatMap, AC-B-CounterBookTicketsForm.updateSeatMap, NFR-08, NFR-09 |
| DC-SeatMapReducer | SeatMapReducer | PKG-29 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 điểm 5 (chỉ áp sự kiện khi mã sự kiện lớn hơn event_seq của ghế); NFR-08 |
| DC-AuthFilter | AuthFilter | PKG-11 | Bảo mật | Cơ chế: P09 F5, F6, F7.11 (kiểm chữ ký và hạn của mã phiên qua IF-07; với nhân viên hỏi DC-AccessCheckService (PKG-19) mốc truy cập hiện hành một lần mỗi yêu cầu, trả 401 khi phiên không còn hiệu lực); AC-C-BookTicketsController.checkCustomerLoggedIn; NFR-01 đến NFR-03; BR-101 |
| DC-BookingController | BookingController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5 (REST controller); AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm, AC-B-CancelTicketForm (UC-005) |
| DC-SeatMapStreamController | SeatMapStreamController | PKG-11 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 (SSE, nhịp tim 15 giây, giới hạn 10 kết nối mỗi IP, id sự kiện); NFR-08, NFR-09 |
| DC-TicketController | TicketController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm, AC-B-CheckTicketForm, AC-B-ViewBookingHistoryForm (UC-007, UC-008, UC-009) |
| DC-PricingScheduleController | PricingScheduleController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-ManagePriceListForm, AC-B-ScheduleShowtimesForm, AC-B-ManageAuditoriumsForm (UC-012, UC-013, UC-014) |
| DC-CatalogController | CatalogController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-BrowseMoviesForm, AC-B-BrowseShowtimesForm (UC-003, UC-004; đọc, không đăng nhập) |
| DC-AccountController | AccountController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-RegisterAccountForm, AC-B-ManageStaffAccountsForm (UC-001, UC-017) và hai điểm đăng nhập riêng của khách và nhân viên (Q-267) |
| DC-ReportController | ReportController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-ViewCinemaReportForm, AC-B-ViewChainReportForm (UC-015, UC-016) |
| DC-ChainController | ChainController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-ManageMoviesForm, AC-B-ManageCinemasForm (UC-010, UC-011) |
| DC-PaymentCallbackController | PaymentCallbackController | PKG-12 | Giao tiếp ngoài (cổng thanh toán) | Cơ chế: P09 F7.1, F7.6 (ba đường vào công khai, không đăng nhập: HandleIpn nhận IPN, HandleReturn nhận khách quay về từ cổng chỉ để đọc trạng thái, HandlePaymentStatus cho trang kết quả hỏi lại trạng thái, Q-126); AC-B-PaymentGateway.reportTransactionResult dùng để kiểm chữ ký tham số của địa chỉ trả về; NFR-16 |
| DC-SeatMapService | SeatMapService | PKG-13 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 điểm 4 (ảnh chụp kèm con trỏ, đăng ký nhận cập nhật); AC-E-Showtime.provideSeatMap; REQ-119. Dịch DC-SeatChangeEvent từ IF-04 thành khung SSE dạng văn bản trước khi trả cho PKG-11 |
| DC-SeatReleaseJob | SeatReleaseJob | PKG-13 | Công việc nền (hẹn giờ) | AC-E-SeatHold.releaseHeldSeats; P09 F7.4 bước 2; EX-05; NFR-07 |
| DC-IpnAnswer | IpnAnswer | PKG-14 | Giao tiếp ngoài (cổng thanh toán) | Cơ chế: P09 F7.6 (kết quả xử lý thông báo do DC-PaymentReportService trả cho PKG-12, không nêu mã HTTP; DC-PaymentCallbackController dịch kết quả sang câu trả lời của cổng, cùng chỗ với phần dịch mã trả lời; gộp từ DC-ReportReply) |
| DC-EmailOutboxJob | EmailOutboxJob | PKG-20 | Giao tiếp ngoài (email, hàng đợi gửi) | Cơ chế: P09 F7.7 (hàng đợi email, thử lại 1, 5, 15 phút); AC-B-EmailService; BR-89, BR-41; dựng cả nội dung email vé và email hoàn tiền (gộp từ DC-EmailComposer; REQ-105, REQ-116) |
| DC-PgUnitOfWork | PgUnitOfWork | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Cơ chế: P09 F7.2, F7.3 (READ COMMITTED, lock_timeout 1 giây, giao dịch ghi ghế tối đa 4 giây, thử lại 2 lần với 40P01 và 55P03, thời điểm CSDL một lần mỗi giao dịch; 55P03 do NOWAIT của ghế ở EX-01 không thử lại); hiện thực LockValue bằng khoá tư vấn mức giao dịch (hạng 0, 11 đến 13); giao dịch chỉ đọc REPEATABLE READ READ ONLY của báo cáo và giao dịch đọc ngắn của kiểm phiên (F7.11, F7.12) |
| DC-LockOrderGuard | LockOrderGuard | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Cơ chế: P08 F4b (thứ tự khoá 14 hạng, 0 đến 13), P09 F7.3; quy tắc kiểm ở F3a, gồm cả khoá theo giá trị |
| DC-ConnectionPools | ConnectionPools | PKG-21 | Persistence | Cơ chế: P09 F7.2, F7.3, F7.4, F7.12 (pool 20 cho yêu cầu người dùng, pool 5 cho công việc nền, pool 3 cho báo cáo) |
| DC-PgCinemaOperationsStore | PgCinemaOperationsStore | PKG-21 | Persistence | Cơ chế: P09 F5 (entity phần lưu trữ), F7.3 |
| DC-PgTicketingStore | PgTicketingStore | PKG-21 | Persistence | Cơ chế: P09 F5 (entity phần lưu trữ), F7.3, F7.6 |
| DC-PgSeatEventStore | PgSeatEventStore | PKG-21 | Persistence | Cơ chế: P09 F7.5 (bảng seat_event, đọc theo con trỏ, ảnh chụp một câu SQL) |
| DC-PgOutboxStore | PgOutboxStore | PKG-21 | Persistence (hàng đợi gửi) | Cơ chế: P09 F7.7 (hàng đợi gửi, claim SKIP LOCKED, claim_token) |
| DC-PgReportStore | PgReportStore | PKG-21 | Persistence (báo cáo) | Cơ chế: P09 F7.12 (hiện thực IF-28 bằng SELECT gộp GROUP BY trong giao dịch REPEATABLE READ READ ONLY ở pool báo cáo, statement_timeout theo Q-269; không khoá) |
| DC-SeatEventWriter | SeatEventWriter | PKG-21 | Persistence | Cơ chế: P09 F7.5 điểm 1 (INSERT seat_event trong giao dịch đổi ghế, ghi event_seq); chỉ các Pg Store gọi, bên trong cùng thao tác cập nhật SeatStatus |
| IF-22 | ISeatEventStore | PKG-21 | Persistence | Cơ chế: P09 F7.5 (đọc sự kiện sau con trỏ, ảnh chụp, xoá cũ); Đề xuất sửa P09 1, Q-116 |
| IF-23 | IOutboxStore | PKG-21 | Persistence (hàng đợi gửi) | Cơ chế: P09 F7.7 (xếp hàng cùng giao dịch, claim, ghi kết quả có điều kiện claim_token) |
| DC-LoginService | LoginService | PKG-19 | Bảo mật | Cơ chế: P09 F4, F7.11 (đăng nhập khách bằng email hoặc số điện thoại, nhân viên bằng email, hai điểm đăng nhập riêng theo Q-267; kiểm mật khẩu và cấp phiên qua IF-07; tài khoản nhân viên Bị khoá thì từ chối, BR-97; phiên nhân viên mang access_changed_at vừa đọc); AC-E-Customer.authenticateCustomer; hồ sơ dự án mục 4 (đăng nhập không là use case nên không có AC nguồn); tài khoản quản trị viên theo Q-271 |
| DC-AccessCheckService | AccessCheckService | PKG-19 | Bảo mật | Cơ chế: P09 F4, F7.11 (kiểm phiên theo mốc truy cập, một nơi duy nhất cho mọi use case của nhân viên: một lần đọc dòng Staff theo khoá chính không khoá qua IF-15 trong giao dịch chỉ đọc mở bằng IF-08, so trạng thái và access_changed_at với mốc trong phiên, trả vai trò và cụm rạp hiện hành cho PKG-11); BR-101, Q-270. P09 F4 ghi việc đọc qua IF-08; P10 đặt qua IF-15 vì IF-08 chỉ mở giao dịch và lấy khoá (Đề xuất sửa artifact trước) |
| IF-28 | IReportRepository | PKG-33 | Persistence (báo cáo) | Cơ chế: P09 F7.12 (số liệu đã gộp theo nhóm và kỳ: doanh thu ròng theo ngày chiếu, số vé, sức chứa của suất chiếu chưa xoá; báo cáo toàn chuỗi dựng từ danh sách cụm rạp); AC-E-Showtime.provideReportFigures, AC-E-Ticket.calculateNetRevenue, AC-E-ReportGroup; BR-115 đến BR-119. Đặt ở Domain để PKG-21 hiện thực không đi lên Application |
| DC-ReportFigures | ReportFigures | PKG-33 | Persistence (báo cáo) | Kiểu giá trị của IF-28 (khoá nhóm, doanh thu ròng, số vé đã bán, sức chứa); P12 chi tiết |
| DC-PaymentReport | PaymentReport | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Kiểu giá trị của IF-02 (NFR-16: mã giao dịch, mã tham chiếu lần giữ ghế, số tiền, kết quả) |
| DC-RefundOutcome | RefundOutcome | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Kiểu giá trị của IF-01 (BR-41: thành công, bị từ chối, không rõ kết quả) |
| DC-EmailMessage | EmailMessage | PKG-23 | Giao tiếp ngoài (email, hàng đợi gửi) | Kiểu giá trị của IF-03 (người nhận, tiêu đề, nội dung, khoá chống lặp làm Message-ID, P09 F7.7) |
| SS-03 | SeatEventHub | PKG-24 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5; luồng sự kiện thay updateSeatMap của AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm |
| IF-04 | ISeatEventSubscription | PKG-24 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 |
| SS-04 | Scheduler | PKG-25 | Công việc nền (hẹn giờ) | Cơ chế: P09 F7.4, F7.7; NFR-07; AC-C-BookTicketsController.startWaitingForHoldExpiry |
| IF-05 | IJobScheduler | PKG-25 | Công việc nền (hẹn giờ) | Cơ chế: P09 F4 (Scheduler nhận đăng ký công việc ở hàm khởi động) |
| IF-06 | IScheduledJob | PKG-25 | Công việc nền (hẹn giờ) | Cơ chế: P09 A5, F4 (công việc nền gọi ngược lên Application) |
| SS-05 | Security | PKG-26 | Bảo mật | Cơ chế: P09 F4 (PKG-26); NFR-01 đến NFR-03, NFR-10; AC-E-Customer.authenticateCustomer |
| IF-07 | IAuthenticator | PKG-26 | Bảo mật | Cơ chế: P09 F4, F6 (ngoại lệ PKG-11 kiểm tra mã phiên) |
| IF-08 | IUnitOfWork | PKG-27 | Đồng thời (giao dịch, khoá theo hạng) | Cơ chế: P09 F5 (Application lấy hạng khoá), F7.3 (giao dịch); thêm LockValue(DC-ValueLockKind, giá trị thô) lấy khoá tư vấn mức giao dịch cho hạng 0, 11, 12, 13 (P09 F4, F7.3); mở giao dịch chỉ đọc cho báo cáo và kiểm phiên (DC-TxOptions) |
| IF-11 | IShowtimeRepository | PKG-27 | Persistence | Cơ chế: P09 F5 (entity phần lưu trữ): DC-Showtime |
| IF-12 | IPriceListRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-PriceList, DC-PriceEntry |
| IF-13 | ICinemaRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-Cinema, DC-Auditorium, DC-Seat (hạng khoá 0 và 2 cho EX-15, EX-17 đến EX-19; thêm, xoá phòng và ghế) |
| IF-14 | IMovieRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-Movie (hạng khoá 10: X cho EX-16, S cho EX-13) |
| IF-15 | IStaffRepository | PKG-32 | Persistence | Cơ chế: P09 F5: DC-Staff, DC-CinemaManager, DC-TicketChecker (hạng khoá 4 cho EX-22; thêm tài khoản cho EX-21; đọc dòng theo khoá chính không khoá để kiểm phiên, F7.11; đọc theo email chuẩn hoá để đăng nhập); chuyển từ PKG-27 vì trả DC-Staff ở PKG-32 |
| IF-16 | IHolderRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-Customer, DC-BoxOfficeClerk (hạng khoá 4; thêm tài khoản khách cho EX-20) |
| IF-17 | ISeatHoldRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-SeatHold (hạng khoá 5) |
| IF-18 | ISeatStatusRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-SeatStatus (hạng khoá 6) |
| IF-19 | IPaymentTransactionRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-PaymentTransaction (hạng khoá 7) |
| IF-20 | IBookingRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-Booking, DC-Ticket (thêm và đọc lần đặt; khoá vé tách sang IF-27, hạng khoá 8) |
| IF-21 | IRefundRequestRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-RefundRequest (hạng khoá 9) |
| DC-SeatChangeEvent | SeatChangeEvent | PKG-28 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F4 (kiểu sự kiện đổi ghế do IF-04 trả cho DC-SeatMapService, không ra khỏi Application; PKG-11 chỉ nhận khung SSE dạng văn bản); P09 F7.5 |
| DC-LoginView | LoginView | PKG-31 | Giao diện người dùng (React) | Thiết kế: SCR-01 Đăng nhập (P11a): tiền điều kiện của UC-005, UC-008, UC-009, UC-013, UC-014 và mọi use case của nhân viên; dùng chung cho các vai trò nên đặt ở PKG-31 (P09 F5), phục vụ hai điểm đăng nhập riêng của khách và của nhân viên (Q-267); chỉ điều hướng, không có trách nhiệm AC |
| DC-SessionStore | SessionStore | PKG-31 | Giao diện người dùng (React) | Cơ chế: P09 F5, F7.11 (giữ mã phiên của người dùng trên trình duyệt, đính vào mọi yêu cầu, nhận 401 "phiên không còn hiệu lực" thì xoá mã phiên và đưa về DC-LoginView); NFR-01 đến NFR-03; BR-97, BR-101 |
| DC-CustomerHomeView | CustomerHomeView | PKG-05 | Giao diện người dùng (React) | Thiết kế: SCR-02 Trang chủ khách (P11a): lối vào Đặt vé và Huỷ vé; chỉ điều hướng, không có trách nhiệm AC |
| DC-CounterHomeView | CounterHomeView | PKG-06 | Giao diện người dùng (React) | Thiết kế: SCR-09 Trang chủ quầy (P11a): lối vào Bán vé và Huỷ vé tại quầy; chỉ điều hướng, không có trách nhiệm AC |
| DC-CinemaAdminHomeView | CinemaAdminHomeView | PKG-08 | Giao diện người dùng (React) | Thiết kế: SCR-17 Trang chủ quản lý cụm rạp (P11a): lối vào Bảng giá và Suất chiếu; chỉ điều hướng, không có trách nhiệm AC |
| DC-HoldSeatsRequest | HoldSeatsRequest | PKG-13 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): showtimeId, seatIds ([]SeatId), holder (HolderRef), requestId (string, UUID của trình duyệt), displayedAt (time.Time, lastChangedAt lúc hiển thị sơ đồ ghế) |
| DC-HoldResult | HoldResult | PKG-13 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): holdId, holdRef, expiryTime, seats (seatId, label, seatType, price), total (Money), replayed (bool: true khi trả lại lần giữ ghế cùng requestId) |
| DC-PaymentStart | PaymentStart | PKG-13 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): transactionCode (string), paymentUrl (string) |
| DC-SseFrame | SseFrame | PKG-13 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): id (string, mã sự kiện), event (string: seat, reload), data (string JSON); PKG-11 chỉ ghi ra kết nối |
| DC-SseStream | SseStream | PKG-13 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): frames (<-chan SseFrame), close (func()); đóng thì gọi IF-04.Unsubscribe |
| DC-IpnOutcome | IpnOutcome | PKG-14 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): PROCESSED, DUPLICATE, INVALID_SIGNATURE, AMOUNT_MISMATCH, UNKNOWN_TRANSACTION, TEMPORARY_FAILURE, MALFORMED (thay DC-ReportHandlingResult của P11b) |
| DC-PaymentStatusView | PaymentStatusView | PKG-14 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): holdRef, holdStatus (HoldStatus), paymentStatus (PaymentStatus của giao dịch mới nhất, rỗng nếu chưa có), bookingCode (rỗng nếu chưa có vé) |
| DC-CancelResult | CancelResult | PKG-15 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): ticketId, refundAmount (Money), refundType (TICKET_GATEWAY hoặc TICKET_CASH), refundStatus (RefundStatus lúc trả lời) |
| DC-AdmitResult | AdmitResult | PKG-15 | Kiểu dữ liệu của lớp dịch vụ (Application) | Thiết kế (P12 F1b): outcome (AdmitOutcome), bookingCode, seatLabel, seatType (rỗng nếu không ADMITTED) |
| DC-PgTx | PgTx | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b): Giữ giao dịch pgx đang mở, bộ kiểm thứ tự khoá và thời điểm CSDL đã lấy của một giao dịch |
| DC-LockRank | LockRank | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b, mở rộng theo P08 F4b 2.0): CINEMA=0, PRICE_LIST=1, AUDITORIUM=2, SHOWTIME=3, HOLDER=4 (Customer hoặc Staff), SEAT_HOLD=5, SEAT_STATUS=6, PAYMENT_TRANSACTION=7, TICKET=8, REFUND_REQUEST=9, MOVIE=10; hạng 0, 11, 12, 13 còn có khoá theo giá trị (DC-ValueLockKind); P12 cập nhật |
| DC-LockKey | LockKey | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b): major (int64), minor (int64): khoá một dòng; SeatStatus dùng (mã suất chiếu, mã ghế), các hạng khác dùng (mã, 0) |
| DC-LockOrderViolationError | LockOrderViolationError | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b): Lời gọi khoá có hạng nhỏ hơn hạng lớn nhất đã lấy, hoặc cùng hạng mã nhỏ hơn; lỗi lập trình, không thử lại, giao dịch rollback |
| DC-OutboxKind | OutboxKind | PKG-21 | Persistence (hàng đợi gửi) | Thiết kế (P12 F1b): REFUND_GATEWAY, EMAIL_TICKET, EMAIL_REFUND |
| DC-OutboxStatus | OutboxStatus | PKG-21 | Persistence (hàng đợi gửi) | Thiết kế (P12 F1b): PENDING (chờ), SUCCEEDED (thành công), EXHAUSTED (hết lần thử) |
| DC-OutboxEntry | OutboxEntry | PKG-21 | Persistence (hàng đợi gửi) | Thiết kế (P12 F1b): id, kind, sourceId (mã bản ghi nguồn), status, attemptCount, nextAttemptAt, claimToken, claimedUntil, idempotencyKey, lastError (P09 F7.7) |
| DC-ClaimLostError | ClaimLostError | PKG-21 | Persistence (hàng đợi gửi) | Thiết kế (P12 F1b): claim_token không còn là của bên ghi kết quả (claim hết hạn và bị bản backend khác nhận) |
| DC-RefundLookup | RefundLookup | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Thiết kế (P12 F1b): status (REFUNDED, NOT_REFUNDED, NOT_SUPPORTED, UNREACHABLE), refundedAmount (int64, đồng) (P11b F5) |
| DC-InvalidGatewayRequestError | InvalidGatewayRequestError | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Thiết kế (P12 F1b): Tham số của bên gọi vi phạm tiền điều kiện (P11b F5) |
| DC-GatewayConfigurationError | GatewayConfigurationError | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Thiết kế (P12 F1b): Thiếu hoặc sai cấu hình bắt buộc của cổng (P11b F5) |
| DC-InvalidSignatureError | InvalidSignatureError | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Thiết kế (P12 F1b): Chữ ký của thông báo không khớp (P11b F5) |
| DC-MalformedReportError | MalformedReportError | PKG-22 | Giao tiếp ngoài (cổng thanh toán) | Thiết kế (P12 F1b): Thông báo thiếu tham số bắt buộc hoặc số tiền không là số (P11b F5) |
| DC-EmailAttachment | EmailAttachment | PKG-23 | Giao tiếp ngoài (email, hàng đợi gửi) | P11b SS-02 F5: Phần đính kèm của thư: name, mimeType, content, inline (true cho ảnh mã QR trong thân thư); dùng trong DC-EmailMessage |
| DC-EmailSendResult | EmailSendResult | PKG-23 | Giao tiếp ngoài (email, hàng đợi gửi) | P11b SS-02 F5: status (Accepted / Rejected / TemporaryFailure), maybeDelivered, detail (mô tả ngắn cho log); dùng trong chữ ký IF-03 |
| DC-InvalidEmailMessageError | InvalidEmailMessageError | PKG-23 | Giao tiếp ngoài (email, hàng đợi gửi) | P11b SS-02 F5: Địa chỉ nhận sai định dạng, tiêu đề hoặc khoá chống lặp rỗng; dùng trong chữ ký IF-03 |
| DC-SeatEventSubscription | SeatEventSubscription | PKG-24 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Thiết kế (P12 F1b): subscriptionId (string), items (<-chan SeatStreamItem, bên gọi đọc) (P11b F5) |
| DC-SeatStreamItem | SeatStreamItem | PKG-24 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Thiết kế (P12 F1b): kind (EVENT, RELOAD_REQUIRED, CLOSED), event (SeatChangeEvent, có khi EVENT), closeReason (SLOW_CONSUMER, UNSUBSCRIBED, SHUTDOWN, có khi CLOSED) (P11b F5) |
| DC-SeatHubUnavailableError | SeatHubUnavailableError | PKG-24 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Thiết kế (P12 F1b): Bộ phát chưa chạy, đang tắt hoặc đọc phát lại lỗi (P11b F5) |
| DC-JobRunResult | JobRunResult | PKG-25 | Công việc nền (hẹn giờ) | Thiết kế (P12 F1b): processedCount (int), hasMore (bool: còn việc đến hạn khi hết ngân sách) (P11b F5) |
| DC-SchedulerStateError | SchedulerStateError | PKG-25 | Công việc nền (hẹn giờ) | Thiết kế (P12 F1b): Đăng ký sau Start, Start hai lần, tên công việc trùng hoặc chu kỳ không dương (P11b F5) |
| DC-Role | Role | PKG-26 | Bảo mật | Thiết kế (P12 F1b): CUSTOMER, BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER, ADMINISTRATOR (P11b SS-05 F5) |
| DC-SessionClaims | SessionClaims | PKG-26 | Bảo mật | Thiết kế (P12 F1b): subjectId (string), role (Role), cinemaId (string, rỗng với khách, quản lý chuỗi, quản trị viên), expiresAt (time.Time) (P11b SS-05 F5); tầng gọi dựng DC-ActorContext từ giá trị này; F7.11 thêm loại chủ thể và accessChangedAt của nhân viên (P11b, P12 cập nhật) |
| DC-IssuedSession | IssuedSession | PKG-26 | Bảo mật | Thiết kế (P12 F1b): token (string), expiresAt (time.Time) (P11b SS-05 F5) |
| DC-SessionInvalidError | SessionInvalidError | PKG-26 | Bảo mật | P11b SS-05 F5: Token sai chữ ký hoặc sai định dạng; dùng trong chữ ký IF-07 |
| DC-SessionExpiredError | SessionExpiredError | PKG-26 | Bảo mật | P11b SS-05 F5: Token đúng chữ ký nhưng quá hạn; dùng trong chữ ký IF-07 |
| DC-MalformedHashError | MalformedHashError | PKG-26 | Bảo mật | P11b SS-05 F5: Mã băm lưu trữ sai định dạng; dùng trong chữ ký IF-07 |
| DC-InvalidAuthRequestError | InvalidAuthRequestError | PKG-26 | Bảo mật | P11b SS-05 F5: subjectId rỗng hoặc role không hợp lệ khi cấp phiên; dùng trong chữ ký IF-07 |
| IF-24 | ICodeGenerator | PKG-27 | Sinh mã tham chiếu | Thiết kế (P12 F1b): Sinh mã tham chiếu cho lần giữ ghế, giao dịch, lần đặt và vé |
| IF-25 | Tx | PKG-27 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b): Đại diện một giao dịch đang mở, truyền vào mọi operation của interface kho để chúng dùng cùng một kết nối |
| DC-RandomCodeGenerator | RandomCodeGenerator | PKG-27 | Sinh mã tham chiếu | Thiết kế (P12 F1b): Sinh mã ngẫu nhiên bằng crypto/rand cho các mã tham chiếu |
| DC-HoldSettlement | HoldSettlement | PKG-28 | Đồng thời (trình tự kết thúc lần giữ ghế và bán ghế) | Thiết kế (X1 RV-01, P12 F1): Gom dãy Expire, Cancel, FailPayment, Complete, ReleaseHold, NewBooking, MarkSold lặp ở EX-01 đến EX-04; lớp miền không trạng thái, không I/O, không khoá |
| IF-26 | IHoldSweepRepository | PKG-28 | Persistence | Thiết kế (X1 RV-06, P12 F1): Khoá theo lô lần giữ ghế cần hết hạn hoặc cần trả ghế và ghế của lô cho DC-HoldExpiryJob, DC-SeatReleaseJob (hạng khoá 5 và 6) |
| IF-27 | ITicketLockRepository | PKG-28 | Persistence | Thiết kế (X1 RV-06, P12 F1): Khoá và cập nhật trạng thái vé (hạng khoá 8) cho EX-06 đến EX-08, EX-14 |
| DC-Money | Money | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): int64 đồng (VND), không âm. Operation: Add, Sub, Percent(p int) làm tròn xuống đồng (BR-31), GreaterThan; đổi sang int64(m) khi gọi IF-01, IF-02 (PKG-22 không phụ thuộc Domain) |
| DC-CinemaIds | CinemaIds | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): Nhóm kiểu định danh int64: ShowtimeId, AuditoriumId, SeatId, CinemaId (Thiết kế: kiểu số để khoá theo thứ tự số tăng dần, P09 F7.3) |
| DC-ShowtimeStatus | ShowtimeStatus | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): IN_SCHEDULE (Trong lịch chiếu), DELETED (Đã xoá) |
| DC-PriceQuery | PriceQuery | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): auditoriumType, movieFormat, startTime, seatType (khoá tra mục giá, BR-11, BR-12) |
| DC-ShowtimeRouting | ShowtimeRouting | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): auditoriumId, cinemaId: mã cần khoá trước khi khoá suất chiếu, đọc không khoá (P08 F4b quy tắc 7) |
| DC-ShowtimeInfo | ShowtimeInfo | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): movieTitle, movieFormat, cinemaName, auditoriumName, startTime, endTime (dữ liệu hiển thị, đọc join) |
| DC-TxOptions | TxOptions | PKG-27 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b): name, pool (USER / BACKGROUND, thêm REPORT cho báo cáo), lockTimeout, maxDuration, deadline (hạn tổng tuyệt đối, có thể rỗng); hàm dựng UserTx(name), BackgroundTx(name), WithDeadline(t) (Thiết kế: lockTimeout 1 giây, maxDuration 4 giây, P09 F7.3; HoldSeats có hạn tổng 1,8 giây); báo cáo thêm chỉ đọc, REPEATABLE READ và statement_timeout (P09 F7.12); P12 chi tiết |
| DC-ValueLockKind | ValueLockKind | PKG-27 | Đồng thời (khoá theo giá trị) | Cơ chế: P08 F4b hạng 0, 11, 12, 13; P09 F7.3 (CINEMA_NAME hạng 0, CUSTOMER_EMAIL hạng 11, CUSTOMER_PHONE hạng 12, STAFF_EMAIL hạng 13); tham số của IF-08.LockValue, mỗi loại có hạng cố định nên DC-LockOrderGuard kiểm được thứ tự; EX-17, EX-20, EX-21 |
| DC-NotFoundError | NotFoundError | PKG-27 | Persistence | Thiết kế (P12 F1b): Không tìm thấy dòng theo khoá |
| DC-SystemBusyError | SystemBusyError | PKG-27 | Đồng thời (giao dịch, khoá theo hạng) | Thiết kế (P12 F1b): Hết thời gian chờ khoá hoặc deadlock sau 2 lần thử lại (hệ thống bận) |
| DC-ShowtimeNotOpenError | ShowtimeNotOpenError | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): Chưa tới thời điểm mở bán hoặc đã tới giờ bắt đầu, hoặc suất chiếu Đã xoá (BR-01, BR-45) |
| DC-ShowtimeChangedError | ShowtimeChangedError | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): Suất chiếu đã sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế (BR-54) |
| DC-SeatSelectionError | SeatSelectionError | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): reason: EMPTY, TOO_MANY (quá 8 ghế, BR-05), NOT_IN_AUDITORIUM, DUPLICATE |
| DC-CancelDeadlineError | CancelDeadlineError | PKG-27 | Kiểu dữ liệu và ngoại lệ của miền (cụm rạp) | Thiết kế (P12 F1b): Thời điểm kiểm tra cách giờ bắt đầu chưa tới 2 tiếng (BR-18, BR-32) |
| DC-TicketingIds | TicketingIds | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Nhóm kiểu định danh int64: SeatHoldId, BookingId, TicketId, PaymentTransactionId, RefundRequestId, CustomerId, BoxOfficeClerkId, EventId (mã seat_event). Gán khi lưu |
| DC-HolderKind | HolderKind | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): CUSTOMER, CLERK (khách, nhân viên quầy: người giữ ghế) |
| DC-HolderRef | HolderRef | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): kind (HolderKind), id (int64); so sánh bằng theo cả hai trường; hiện thực {xor} của R-48, R-49 |
| DC-ActorKind | ActorKind | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): CUSTOMER, CLERK, CHECKER (khách, nhân viên quầy, nhân viên soát vé) |
| DC-ActorContext | ActorContext | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): kind (ActorKind), id (int64), cinemaId (CinemaId, 0 với khách); lấy từ SessionClaims của IF-07 do tầng gọi dựng. Hàm AsHolder() trả HolderRef khi kind là CUSTOMER hoặc CLERK |
| DC-SeatKey | SeatKey | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): showtimeId (ShowtimeId), seatId (SeatId): định danh ghép của SeatStatus và khoá khoá dòng hạng 6 |
| DC-SeatState | SeatState | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): AVAILABLE (Trống), HELD (Đang được giữ), SOLD (Đã bán) |
| DC-HoldStatus | HoldStatus | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): ACTIVE (Đang giữ), COMPLETED (Đã hoàn tất), EXPIRED (Hết hạn), CANCELLED (Đã huỷ), PAYMENT_FAILED (Thanh toán thất bại) |
| DC-TicketStatus | TicketStatus | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): UNUSED (Chưa sử dụng), USED (Đã sử dụng), CANCELLED (Đã huỷ) |
| DC-PaymentStatus | PaymentStatus | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): PENDING (Chưa xử lý), FAILED (thất bại đã ghi nhận), TICKETED (Đã tạo vé), LATE_PAYMENT (Đã ghi nhận thanh toán trễ) |
| DC-RefundStatus | RefundStatus | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): NEW (Mới), IN_FLIGHT (Đang chờ kết quả), WAITING_RETRY (Chờ gửi lại), REFUNDED (Đã hoàn), MANUAL_REQUIRED (Cần xử lý thủ công) |
| DC-RefundType | RefundType | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): FULL (hoàn toàn bộ), TICKET_GATEWAY (hoàn một vé qua cổng), TICKET_CASH (hoàn một vé bằng tiền mặt) |
| DC-AttemptResult | AttemptResult | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): SUCCEEDED, REJECTED, UNKNOWN: kết quả một lần gửi hoàn tiền, kiểu của Domain để DC-RefundRequest không phụ thuộc DC-RefundOutcome ở PKG-22 |
| DC-AdmitOutcome | AdmitOutcome | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): ADMITTED, WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, CANCELLED (đúng thứ tự BR-33) |
| DC-SeatSnapshot | SeatSnapshot | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): showtimeId, showtimeChangedAt (lastChangedAt của suất chiếu, để quay lại gửi displayedAt ở BR-54), cursor (EventId lớn nhất đã thấy), cursorCreatedAt, seats (danh sách seatId, state, eventSeq của ghế) |
| DC-BookingView | BookingView | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): bookingCode, tickets (ticketCode, seatLabel, seatType, price, status, refundAmount, refundStatus) dùng hiển thị và gửi |
| DC-HolderBusyError | HolderBusyError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Người giữ ghế còn lần giữ ghế chưa kết thúc (BR-04) |
| DC-SeatUnavailableError | SeatUnavailableError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): reason: NOT_AVAILABLE (ghế không Trống), LOCKED_BY_OTHER (55P03 của NOWAIT, ghế vừa có người chọn), BEING_RELEASED (55P03 nhưng ghế đang được trả về trống), NOT_FOUND |
| DC-HoldNotActiveError | HoldNotActiveError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Lần giữ ghế không còn Đang giữ hoặc đã quá hạn; mang status hiện tại (BR-86) |
| DC-LinkMismatchError | LinkMismatchError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Liên kết hiện tại của ghế không khớp lần giữ ghế hoặc vé đang xử lý (R-63, R-64) |
| DC-TicketStateError | TicketStateError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Vé không ở trạng thái cho phép thao tác (đã huỷ, đã sử dụng); mang status (BR-21, BR-30) |
| DC-ChannelMismatchError | ChannelMismatchError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Tác nhân huỷ không phải bên đã mua theo kênh (BR-17) |
| DC-PaymentStateError | PaymentStateError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Giao dịch thanh toán không ở trạng thái cho phép chuyển (lỗi lập trình nếu xảy ra dưới khoá) |
| DC-RefundLimitError | RefundLimitError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Tổng hoàn vượt số tiền đã thanh toán (BR-26) |
| DC-RefundStateError | RefundStateError | PKG-28 | Kiểu dữ liệu và ngoại lệ của miền (đặt vé) | Thiết kế (P12 F1b): Yêu cầu hoàn không ở trạng thái cho phép chuyển |

### Phần tử bị gộp hoặc loại

Mã giữ nguyên theo quy ước, không cấp lại. Không phần tử nào trong số này phục vụ chuỗi khoá, DC-LockOrderGuard hay cập nhật sơ đồ ghế.

| Mã | Trạng thái | Gộp vào hoặc thay bằng | Lý do |
|---|---|---|---|
| DC-EmailComposer | Gộp | DC-EmailOutboxJob | Chỉ dựng nội dung cho đúng một bên gọi |
| DC-SeatEventCleanupJob | Gộp | DC-HoldExpiryJob | Cùng chu kỳ 10 giây, cùng bảng seat_event; dọn là bước cuối của lượt chạy |
| DC-PaymentLinkRequest | Loại | Tham số thường của IF-01 createPaymentTransaction | Kiểu giá trị chỉ có ba trường |
| DC-RefundCommand | Loại | Tham số thường của IF-01 requestRefund | Kiểu giá trị chỉ có ba trường |
| DC-ReportReply | Gộp | DC-IpnAnswer (PKG-14) | IF-02 không dựng câu trả lời cho cổng; kết quả xử lý thông báo đi qua DC-IpnAnswer để PKG-12 không phải phụ thuộc PKG-22 |
| DC-ReportHandlingResult | Gộp | DC-IpnOutcome (PKG-14) | IF-02 không còn replyToReport; kết quả xử lý thông báo là DC-IpnOutcome, PKG-12 dịch sang câu trả lời của cổng (P12 F1b) |
| DC-QrCameraScanner | Loại | Thư viện đọc QR có sẵn, gọi từ DC-CheckTicketView | Không có hành vi riêng cần thiết kế |
| IF-09 ISeatOccupancyGuard | Loại | DC-ScheduleShowtimesService gọi IF-17, IF-20 | Q-117 áp cho EX-13, EX-14: dịch vụ điều phối, thứ tự khoá hiện trong một lớp |
| IF-10 ISeatStatusInitializer | Loại | DC-ScheduleShowtimesService gọi IF-18 | Như trên |
| DC-SeatOccupancyChecker | Loại | Như IF-09 | Không còn interface để hiện thực |
| DC-SeatStatusInitializer | Loại | Như IF-10 | Không còn interface để hiện thực |

### F3a. Truy vết EX-01 đến EX-22 sang phần tử thiết kế

Mỗi dòng nêu lớp dịch vụ mở giao dịch (qua IF-08) và chuỗi khoá theo hạng của P08 F4b (14 hạng, 0 đến 13); mọi khoá đi qua interface kho dữ liệu hoặc IF-08.LockValue nên DC-LockOrderGuard kiểm được thứ tự. S là SELECT FOR SHARE, X là FOR NO KEY UPDATE (P09 F7.3); khoá giá trị là khoá tư vấn mức giao dịch. Tên operation do P12 đặt. Mỗi EX có đúng một lớp dịch vụ mở giao dịch ở cột thứ hai (EX-06, EX-07, EX-09 chung giao dịch của DC-CancelTicketService, Q-133).

| EX | Lớp mở giao dịch (IF-08) | Chuỗi khoá (hạng, interface, chế độ) | Phần tử thực hiện phần kiểm và ghi | Ngữ nghĩa giữ nguyên |
|---|---|---|---|---|
| EX-01 | DC-BookTicketsService | 1 IF-12 PriceList S --> 2 IF-13 Auditorium S --> 3 IF-11 Showtime S (S theo P09 Vấn đề còn mở 3; P08 F4b ghi X) --> 4 IF-16 người giữ ghế X (Customer, hoặc dòng Staff của nhân viên quầy) --> 5 IF-17 SeatHold cũ X (nếu có) --> 6 IF-18 SeatStatus X NOWAIT, ORDER BY (mã suất chiếu, mã ghế), không lọc trạng thái | DC-Showtime (mở bán, suất chiếu chưa đổi, giới hạn ghế, chốt giá qua DC-PriceList); DC-Customer hoặc DC-BoxOfficeClerk (BR-04; với nhân viên quầy kiểm trạng thái hoạt động và access_changed_at của dòng vừa khoá với mốc của phiên, BR-100, BR-101); DC-SeatHold (tạo, expiry_time = thời điểm CSDL + 10 phút, mã yêu cầu); DC-SeatStatus (giữ ghế, current_hold_id, event_seq); DC-HoldSettlement.End chuyển Hết hạn lần giữ ghế cũ của chính người giữ ghế ở bước 5 và trả (ReleaseHold) ghế còn trỏ tới nó, trong cùng giao dịch (Q-134) | Tất cả hoặc không ghế nào; kiểm đã mở bán (BR-01) và các điều kiện chỉ phụ thuộc dòng đã khoá đứng trước khoá ghế; nhân viên quầy đã bị khoá hoặc đổi quyền trước lúc khoá dòng Staff thì từ chối và không tạo lần giữ ghế, sau đó thì lần giữ ghế được giữ nguyên (X-33); ghế đang bị khoá thì từ chối ngay (55P03 do NOWAIT, DC-PgUnitOfWork không thử lại); mã yêu cầu làm xác nhận lặp an toàn; không NOTIFY; ghế của lần giữ ghế cũ vừa hết hạn được trả và giữ lại trong cùng giao dịch, không phải chờ DC-SeatReleaseJob |
| EX-02 | DC-PaymentReportService | Tra không khoá mã SeatHold --> 5 IF-17 SeatHold X --> 6 IF-18 SeatStatus của lần giữ ghế X --> 7 IF-19 PaymentTransaction X; tạo mới Booking, Ticket (IF-20), RefundRequest (IF-21), dòng hàng đợi (IF-23) | DC-HoldSettlement (End, Sell, FinishSale), DC-SeatHold, DC-PaymentTransaction, DC-Booking, DC-Ticket, DC-RefundService ở chế độ (a): lập yêu cầu hoàn của thanh toán trễ trong giao dịch đang mở của DC-PaymentReportService, không mở giao dịch mới; DC-HoldSettlement.End (gọi ReleaseHold từng ghế đã khoá hạng 6) khi báo thất bại (lần giữ ghế Đang giữ, giao dịch báo là giao dịch tạo sau cùng) và khi lần giữ ghế chuyển Hết hạn ở nhánh thanh toán trễ, trong cùng giao dịch (Q-134) | Báo trùng, báo muộn, báo song song tuần tự hoá theo khoá SeatHold; thời điểm CSDL lấy một lần sau khoá; câu trả lời cho cổng do IF-02 dựng; báo thất bại của giao dịch cũ khi đã có giao dịch mới hơn chỉ ghi nhận, không đổi lần giữ ghế; ghế liên kết vỡ lúc bán thì xử lý như thanh toán trễ (Q-84) |
| EX-03 | DC-BookTicketsService | 5 IF-17 SeatHold X --> 6 IF-18 SeatStatus X; tạo Booking, Ticket (IF-20) | DC-HoldSettlement (End khi quá hạn, Q-134; Sell, FinishSale), DC-SeatHold, DC-SeatStatus, DC-Booking, DC-Ticket | Xác nhận thu tiền mặt đến sau hết hạn bị từ chối (BR-44) và ghế được trả ngay trong cùng giao dịch; không xếp email vé vì người giữ ghế là nhân viên quầy (P04 UC-005 luồng 9a) |
| EX-04 | DC-BookTicketsService (huỷ giữ ghế, gộp EX-05 trong một giao dịch, Q-134); DC-HoldExpiryJob (quét theo lô); DC-PaymentReportService (báo thất bại, trong giao dịch EX-02) | Huỷ giữ ghế: 5 IF-17 SeatHold X --> 6 IF-18 SeatStatus X; quét: 5 IF-26 SeatHold X, SKIP LOCKED, lô 200 (UpdateStatus qua IF-17) | DC-SeatHold (một trạng thái cuối; quá expiry_time thì chuyển Hết hạn trước); huỷ giữ ghế gọi DC-HoldSettlement.End (Cancel và ReleaseHold) trong cùng giao dịch | Hết hạn là sự thật tính theo thời điểm CSDL, công việc nền chỉ quyết định khi nào ghế trống (P09 F7.4) |
| EX-05 | DC-SeatReleaseJob (quét theo lô, lưới an toàn cho ghế còn sót) | 5 IF-26 SeatHold X SKIP LOCKED, khoá cả lô, mã tăng dần --> 6 IF-26 SeatStatus X của cả lô ORDER BY (mã suất chiếu, mã ghế), rồi UPDATE theo khoá chính đã khoá | DC-SeatHold, DC-SeatStatus (điều kiện current_hold_id) | Chạy lặp an toàn, không trả nhầm ghế đã giữ lại hoặc đã bán (R-63, X-18). Ghế của lần giữ ghế kết thúc trong giao dịch người dùng (EX-01 đến EX-04: hết hạn do thao tác, huỷ giữ ghế, báo thất bại) đã được trả ngay trong giao dịch đó (Q-134); DC-SeatReleaseJob chỉ trả ghế còn sót, chủ yếu của lần giữ ghế do DC-HoldExpiryJob chuyển Hết hạn và của tiến trình chết giữa chừng, chậm nhất 1 phút sau hết hạn (NFR-07) |
| EX-06 | DC-CancelTicketService: một giao dịch gộp EX-06, EX-07, EX-09 (Q-133) | 6 IF-18 SeatStatus X --> 7 IF-19 PaymentTransaction X (bỏ với vé mua tại quầy) --> 8 IF-27 Ticket X; rồi tạo RefundRequest (IF-21, hạng 9, dòng mới) và dòng hàng đợi hoàn tiền (IF-23) | DC-SeatStatus (điều kiện current_ticket_id), DC-Ticket, DC-Booking, DC-RefundService (chế độ b) | Ghi nhận huỷ, trả ghế và tạo yêu cầu hoàn cùng một commit; huỷ tại quầy gộp EX-06, EX-07 và ghi khoản hoàn tiền mặt đã hoàn; chạy được trên suất chiếu Đã xoá; chỉ cuộc gọi cổng (EX-10) nằm ngoài giao dịch |
| EX-07 | DC-CancelTicketService (thuộc giao dịch gộp của EX-06) | 8 IF-27 Ticket X | DC-Ticket | Một lần huỷ (X-14, X-15) |
| EX-08 | DC-CheckTicketService | 8 IF-27 Ticket X | DC-Ticket, DC-Showtime (thứ tự kiểm BR-33) | Một lần soát thành công |
| EX-09 | DC-RefundService: chế độ (b) dùng giao dịch đang mở của DC-CancelTicketService (UC-008, Q-133); chế độ (a) dùng giao dịch đang mở của DC-PaymentReportService khi gọi từ EX-02 (UC-006); không chế độ nào mở giao dịch mới | 7 IF-19 PaymentTransaction X; tạo RefundRequest (IF-21); dòng hàng đợi hoàn tiền (IF-23) | DC-PaymentTransaction (cộng refunded_total trong câu UPDATE), DC-RefundRequest | Tổng đã hoàn không mất cập nhật, không vượt số đã thanh toán (X-16) |
| EX-10 | DC-RefundService (ba giao dịch ngắn), do DC-RefundOutboxJob gọi | 9 IF-21 RefundRequest X; sau đó dòng hàng đợi IF-23 (không thuộc 9 hạng): ghi kết quả có điều kiện claim_token | DC-RefundRequest; IF-01 gọi cổng ngoài giao dịch, chờ 30 giây, cùng khoá chống hoàn trùng | Không giữ khoá khi chờ cổng; hết lần thử, hoặc không tra cứu được kết quả hoàn qua findRefund (Q-118), thì Cần xử lý thủ công; email hoàn chỉ xếp hàng sau hoàn thành công và chỉ với hoàn toàn bộ (FULL) |
| EX-11 | DC-ManagePriceListService | 1 IF-12 PriceList X | DC-PriceList, DC-PriceEntry | Bên sau thấy mốc đã đổi và bị từ chối (X-05) |
| EX-12 | DC-ManagePriceListService | 1 IF-12 PriceList X --> 2 IF-13 Auditorium S tăng dần --> 3 IF-11 Showtime S | DC-PriceList (qua IF-11 kiểm suất chiếu đang dùng mục giá) | PriceList X chặn mọi EX-01, EX-13 trong lúc kiểm |
| EX-13 | DC-ScheduleShowtimesService | 1 IF-12 PriceList S --> 2 IF-13 Auditorium X (tăng dần) --> 3 IF-11 Showtime X --> 5 IF-17 SeatHold S (kiểm lần giữ ghế đang hiệu lực) --> 6 IF-18 SeatStatus X (tạo trạng thái ghế, hoặc giải phóng ghế còn dở khi sửa sang phòng khác, BR-53) --> 8 IF-27 Ticket S (kiểm vé chưa huỷ) --> 10 IF-14 Movie S (kiểm lại phim hiện hành) | DC-Auditorium (saveShowtime, checkRoomGap), DC-Showtime, DC-SeatStatus (tạo, giải phóng ghế), DC-Movie (định dạng còn phát hành, còn trong thời gian chiếu); DC-ScheduleShowtimesService điều phối các lời gọi IF-17, IF-18, IF-27, IF-14 đúng thứ tự trên (Q-117, Q-109) | Showtime X loại trừ mọi EX-01 cùng suất chiếu (X-03); kiểm lại phim hiện hành và phòng còn tồn tại trong cùng thao tác (UC-014 luồng 8g, 8h); lưu phim (EX-16) loại trừ qua Movie (X-25); EXCLUDE và unique từng phần là lưới an toàn ở CSDL |
| EX-14 | DC-ScheduleShowtimesService | 3 IF-11 Showtime X --> 5 IF-17 SeatHold S --> 8 IF-27 Ticket S | DC-Showtime; DC-ScheduleShowtimesService điều phối kiểm qua IF-17, IF-27 | Đánh dấu Đã xoá, giữ dữ liệu để EX-05, EX-06 vẫn chạy |
| EX-15 | DC-ManageAuditoriumsService (PKG-16) | 0 IF-13 Cinema X --> 1 IF-12 PriceList S --> 2 IF-13 Auditorium X --> 3 IF-11 Showtime S --> 6 IF-18 SeatStatus X của các suất chiếu chưa mở bán của phòng, ORDER BY (mã suất chiếu, mã ghế) | DC-Auditorium (checkEditAllowed, checkSeatMapChanged, applyChanges), DC-Seat (retireFromSeatMap), DC-Showtime (checkBlocksSeatMapEdit, checkStaysPriced, adoptSeatMap chỉ tính ghế thêm, ghế bỏ), DC-PriceList (checkCoversShowtime); DC-ManageAuditoriumsService điều phối tạo, bỏ SeatStatus qua IF-18 trong cùng chuỗi (Q-117, Q-249) | Thứ tự kiểm 5c (phòng chưa bị sửa kể từ lúc hiển thị), 4d (tên phòng chưa thuộc phòng khác), 5a (không có suất chiếu đã mở bán mà chưa kết thúc), 5b (suất chiếu chưa tới giờ bắt đầu vẫn đủ giá); mọi mốc thời gian so với một giá trị lấy một lần sau khoá; suất chiếu đã xoá không tính ở 5a, 5b; suất chiếu đã kết thúc hoặc đã xoá giữ sơ đồ ghế lúc mở bán (BR-118) |
| EX-16 | DC-ManageMoviesService (PKG-30) | 10 IF-14 Movie X | DC-Movie (checkUnchangedSinceDisplayed, saveMovieChanges) | Bên sau thấy mốc đã đổi và bị từ chối, không ghi đè (BR-138); suất chiếu đã lập không đổi (BR-84); thêm phim không là EX vì tên được trùng (Q-200) |
| EX-17 | DC-ManageCinemasService (PKG-30) | 0 IF-08.LockValue(CINEMA_NAME) khoá tư vấn --> 0 IF-13 Cinema X (khi sửa); khi thêm tạo Cinema (IF-13) và PriceList rỗng (IF-12) trong cùng giao dịch | DC-Cinema (checkNameTaken, checkUnchangedSinceDisplayed, saveCinemaChanges, addToCinemaList), DC-PriceList (bảng giá rỗng) | Kiểm tên trước (5b, BR-141) rồi mốc (5a, BR-142); khoá giá trị đứng trước khoá Cinema nên hai cụm rạp đổi tên cho nhau không tạo chu trình chờ; cụm rạp và bảng giá rỗng cùng commit; chỉ mục unique theo tên đã chuẩn hoá là lưới an toàn |
| EX-18 | DC-ManageAuditoriumsService (PKG-16) | 0 IF-13 Cinema X; tạo Auditorium và Seat (IF-13) | DC-Cinema (checkAuditoriumNameAvailable, addAuditorium), DC-Auditorium (createAuditorium, checkAuditoriumInfoValid, calculateCapacity, checkCapacityInRange), DC-Seat (createSeat, checkSeatValid) | Tên phòng kiểm dưới Cinema X nên không cần khoá giá trị tên phòng (BR-145); sức chứa 50 đến 400 (BR-144); phòng và các ghế cùng commit |
| EX-19 | DC-ManageAuditoriumsService (PKG-16) | 0 IF-13 Cinema X --> 2 IF-13 Auditorium X (xoá thật nên lấy FOR UPDATE ngay từ đầu, P09 F7.3) | DC-Cinema (removeAuditorium), DC-Auditorium (checkStillExists, checkNeverScheduled), DC-Seat | Phòng chưa từng có suất chiếu, kể cả đã xoá (BR-147); Auditorium X chặn EX-13 tạo suất chiếu mới của phòng nên không cần khoá Showtime (X-28, X-29); phòng và các ghế cùng commit; khoá ngoại không CASCADE là lưới an toàn |
| EX-20 | DC-RegisterAccountService (PKG-19) | 11 IF-08.LockValue(CUSTOMER_EMAIL) --> 12 IF-08.LockValue(CUSTOMER_PHONE); tạo Customer qua IF-16 | DC-Customer (checkRegistrationData, saveCustomer); băm mật khẩu qua IF-07 trước khi mở giao dịch | Hai đăng ký cùng email hoặc cùng số điện thoại tuần tự hoá, bên sau trả đã trùng (BR-98, X-30); email chuẩn hoá theo Q-265; chỉ mục unique là lưới an toàn |
| EX-21 | DC-ManageStaffAccountsService (PKG-19) | 13 IF-08.LockValue(STAFF_EMAIL); tạo Staff qua IF-15 | DC-Staff (checkStaffData, saveStaff); băm mật khẩu ban đầu qua IF-07 trước khi mở giao dịch | Email duy nhất xuyên mọi vai trò nên một khoá giá trị chung (BR-95); email khách là tập độc lập nên không chung khoá (hạng 11) |
| EX-22 | DC-ManageStaffAccountsService (PKG-19) | 4 IF-15 Staff X | DC-Staff (saveStaffChanges, lockStaff, unlockStaff, renameStaff, resetStaffPassword) | Kiểm tài khoản chưa bị yêu cầu khác đổi kể từ lúc hiển thị (BR-102); khoá, đổi vai trò, đổi cụm rạp ghi access_changed_at để phiên đang mở bị từ chối (BR-101); loại trừ EX-01 của nhân viên quầy qua dòng Staff (X-33); lần giữ ghế đã tạo giữ nguyên (BR-100) |

Quy tắc áp dụng cho P12:

- Lớp dịch vụ ở Application mở giao dịch bằng IF-08, lấy một lần thời điểm hiện tại của CSDL sau khi có khoá, và không lấy khoá ở nơi nào khác. Hạng khoá do lớp dịch vụ gọi theo bảng trên; interface kho chỉ thực hiện SQL khoá một hạng. Lớp dịch vụ là nơi duy nhất thấy cả chuỗi: không phần tử miền nào tự gọi kho để khoá (Q-117).
- DC-LockOrderGuard nhớ hạng lớn nhất và mã dòng đã lấy trong giao dịch, kiểm theo bốn điểm:
  - Hạng gắn cố định với từng phương thức khoá của interface kho (mỗi phương thức khai báo đúng một hạng, kể cả interface ghép như IF-13, IF-16, IF-20), lớp dịch vụ không truyền hạng; hạng của khoá giá trị gắn với loại khoá.
  - Từ chối lời gọi có hạng nhỏ hơn hạng lớn nhất đã lấy, hoặc cùng hạng mà mã nhỏ hơn mã đã lấy (SeatStatus theo mã suất chiếu rồi mã ghế). Khoá lại cùng dòng hoặc nâng S lên X (cùng hạng, cùng mã) được phép, không tính là đi lùi.
  - Vi phạm trả error kiểu lỗi lập trình và đánh dấu giao dịch phải rollback, không ném panic và không thử lại. Ca đo T4, T6 của P09 F7.9 khẳng định không có 40P01.
  - Tính cả lời gọi khoá dòng (kể cả NOWAIT, SKIP LOCKED) và IF-08.LockValue. Khoá giá trị có hạng cố định theo DC-ValueLockKind (0 cho tên cụm rạp, 11, 12, 13); trong cùng hạng đi theo (loại, mã băm của giá trị chuẩn hoá) tăng dần, và ở hạng 0 khoá giá trị đứng trước khoá Cinema. Khoá tư vấn mức giao dịch nhả cùng lúc với khoá dòng. P12 chi tiết hoá.
- Mọi giao dịch đổi trạng thái ghế ghi seat_event trong cùng giao dịch, sau khi đã khoá ghế; không gọi NOTIFY. Việc ghi do các Pg Store gọi DC-SeatEventWriter bên trong cùng thao tác cập nhật SeatStatus, lớp dịch vụ không gọi trực tiếp.
- Lời gọi ra ngoài (IF-01, IF-03) nằm ngoài giao dịch và không giữ khoá; dòng hàng đợi (IF-23) được claim bằng giao dịch riêng, commit ngay.
- EX-06, EX-07, EX-09 là một giao dịch của UC-008 (Q-133, khoá hạng 6, 7, 8 rồi chèn hạng 9); chỉ EX-10 (gọi cổng) nằm ngoài giao dịch qua hàng đợi, nên quy tắc "không lồng" của P08 F4b không còn áp dụng cho chuỗi này. EX-01 đến EX-04 trả ghế ngay trong giao dịch kết thúc lần giữ ghế (Q-134); EX-05 chỉ là job quét theo lô. DC-RefundService có hai chế độ: (a) UC-006 trong EX-02, nhận giao dịch đang mở của DC-PaymentReportService; (b) UC-008, nhận giao dịch đang mở của DC-CancelTicketService; cả hai không mở giao dịch mới.
- Quét theo lô (EX-04 của job hết hạn, EX-05): một giao dịch mỗi lô (P09 F7.4). Khoá toàn bộ SeatHold của lô trước (SKIP LOCKED, mã tăng dần), rồi toàn bộ SeatStatus của lô theo (mã suất chiếu, mã ghế) tăng dần; không xử lý từng lần giữ ghế xen kẽ hạng 5 và hạng 6.
- Thứ tự gọi bắt buộc trong EX-13: kiểm SeatHold (IF-17, hạng 5) --> tạo hoặc giải phóng SeatStatus (IF-18, hạng 6) --> kiểm Ticket (IF-27, hạng 8). Kiểm từ chối thì rollback cả giao dịch.
- Thứ tự gọi bắt buộc trong EX-15: kiểm tên và mốc (4d, 5c) sau khoá Cinema và Auditorium, kiểm 5a, 5b sau khoá Showtime, rồi tạo hoặc bỏ SeatStatus (IF-18, hạng 6). EX-13 kết thúc bằng khoá Movie (IF-14, hạng 10): lưu phim (EX-16) chỉ lấy một khoá nên không giữ Movie rồi chờ hạng nhỏ hơn.
- Hai cụm rạp đổi tên chéo nhau (A thành tên của B, B thành tên của A): mỗi giao dịch lấy khoá giá trị của tên mới ở hạng 0 trước khi khoá Cinema nên không có chu trình chờ (P09 F7.3).

Thao tác không là đơn vị loại trừ (P08 F4b mục 6, P09 F7.11, F7.12):

| Thao tác | Lớp thực hiện | Cách làm | Nguồn |
|---|---|---|---|
| Kiểm phiên của nhân viên mỗi yêu cầu | DC-AuthFilter (PKG-11) gọi IF-07 rồi DC-AccessCheckService (PKG-19) | IF-07 kiểm chữ ký và hạn; DC-AccessCheckService mở giao dịch đọc ngắn qua IF-08 (pool người dùng), đọc dòng Staff theo khoá chính không khoá qua IF-15, so trạng thái và access_changed_at với mốc trong phiên; khác thì 401. Không khoá, không hạng. Vai trò và cụm rạp của dòng vừa đọc là danh tính hiện hành chuyển cho Application. Ngoại lệ: EX-01 của nhân viên quầy kiểm lại dưới khoá Staff (F3a, EX-01) | P09 F7.11; BR-101; Q-270 |
| Đăng nhập khách, nhân viên | DC-LoginService (PKG-19) | Đọc không khoá theo email hoặc số điện thoại chuẩn hoá (IF-16 với khách, IF-15 với nhân viên), kiểm mật khẩu và cấp phiên qua IF-07; nhân viên Bị khoá thì từ chối | P09 F7.11; BR-97; Q-267 |
| Báo cáo cụm rạp, báo cáo toàn chuỗi | DC-ViewCinemaReportService, DC-ViewChainReportService (PKG-18) | Một giao dịch chỉ đọc REPEATABLE READ READ ONLY ở pool báo cáo mở bằng IF-08 (DC-TxOptions pool REPORT, statement_timeout), không khoá; DC-ReportPeriod kiểm kỳ; số liệu gộp lấy qua IF-28, DC-ReportGroup tính tỉ lệ lấp đầy | P09 F7.12; BR-115 đến BR-119; Q-269 |
| Tra cứu phim, lịch chiếu, lịch sử đặt vé | DC-BrowseMoviesService, DC-BrowseShowtimesService (PKG-17), DC-ViewBookingHistoryService (PKG-15) | Đọc không khoá ở READ COMMITTED qua IF-14, IF-11, IF-13, IF-20; không là EX | P08 F4b mục 6; UC-003, UC-004, UC-007 |

## F4. Bảng package

Bảng tiếp nối P09 F4 (PKG-05 đến PKG-31) và thêm PKG-32, PKG-33. Layer PKG-01 đến PKG-04 giữ nguyên; PKG-04 chứa thêm PKG-32, PKG-33. Mã PKG tiếp theo cho bước sau: PKG-34.

| PKG | Tên | Layer (PKG) | Trách nhiệm | Phần tử chứa (DC, SS, IF) | Tiêu chí nhóm | Phụ thuộc vào (PKG) |
|---|---|---|---|---|---|---|
| PKG-05 | CustomerWeb | PKG-01 | Giao diện React của khách: tra cứu phim, lịch chiếu, đăng ký, đặt vé, huỷ vé, lịch sử đặt vé (kho trạng thái và component) | DC-BookTicketsView<br>DC-BookTicketsStore<br>DC-CancelTicketView<br>DC-CancelTicketStore<br>DC-CustomerHomeView<br>DC-BrowseMoviesView<br>DC-BrowseMoviesStore<br>DC-BrowseShowtimesView<br>DC-BrowseShowtimesStore<br>DC-RegisterAccountView<br>DC-RegisterAccountStore<br>DC-ViewBookingHistoryView<br>DC-ViewBookingHistoryStore | Cùng tác nhân ACT-01; View trình bày SeatStatus, SeatHold, Ticket, Movie, Showtime, Booking của khách; hai form đặt vé và huỷ vé dùng chung boundary (R-19) | PKG-29, PKG-31 |
| PKG-06 | CounterWeb | PKG-01 | Giao diện React của nhân viên quầy: bán vé, huỷ vé tại quầy | DC-CounterBookTicketsView<br>DC-CounterBookTicketsStore<br>DC-CounterCancelTicketView<br>DC-CounterCancelTicketStore<br>DC-CounterHomeView | Cùng tác nhân ACT-02; tách khỏi PKG-05 theo quy tắc tác nhân (A3) | PKG-29, PKG-31 |
| PKG-07 | CheckInWeb | PKG-01 | Giao diện React soát vé, đọc mã QR bằng camera | DC-CheckTicketView<br>DC-CheckTicketStore | Cùng tác nhân ACT-03; camera là kênh nhập của giao diện này, đọc mã QR bằng thư viện có sẵn (P09 F5) | PKG-31 |
| PKG-08 | CinemaAdminWeb | PKG-01 | Giao diện React của quản lý cụm rạp: bảng giá, lịch suất chiếu, phòng chiếu, báo cáo cụm rạp | DC-ManagePriceListView<br>DC-ManagePriceListStore<br>DC-ScheduleShowtimesView<br>DC-ScheduleShowtimesStore<br>DC-CinemaAdminHomeView<br>DC-ManageAuditoriumsView<br>DC-ManageAuditoriumsStore<br>DC-ViewCinemaReportView<br>DC-ViewCinemaReportStore | Cùng tác nhân ACT-04; các form cùng chỉnh dữ liệu cấu hình của cụm rạp (PriceList, Showtime, Auditorium) hoặc xem số liệu của chính cụm rạp đó | PKG-31 |
| PKG-09 | ChainAdminWeb | PKG-01 | Giao diện React của quản lý chuỗi: phim, cụm rạp, báo cáo toàn chuỗi | DC-ManageMoviesView<br>DC-ManageMoviesStore<br>DC-ManageCinemasView<br>DC-ManageCinemasStore<br>DC-ViewChainReportView<br>DC-ViewChainReportStore | Cùng tác nhân ACT-05; View trình bày Movie, Cinema và số liệu toàn chuỗi | PKG-31 |
| PKG-10 | AccountAdminWeb | PKG-01 | Giao diện React của quản trị viên: tài khoản nhân viên, cụm rạp, vai trò | DC-ManageStaffAccountsView<br>DC-ManageStaffAccountsStore | Cùng tác nhân ACT-06; View trình bày Staff; một boundary 20 trách nhiệm của sáu thao tác một use case, không tách (F3) | PKG-31 |
| PKG-11 | HttpApi | PKG-01 | REST controller, kết nối đẩy sơ đồ ghế, bộ lọc kiểm tra mã phiên và mốc truy cập của nhân viên | DC-AuthFilter<br>DC-BookingController<br>DC-SeatMapStreamController<br>DC-TicketController<br>DC-PricingScheduleController<br>DC-CatalogController<br>DC-AccountController<br>DC-ReportController<br>DC-ChainController | Phần tiếp nhận yêu cầu theo nhóm chức năng (P09 F5); chung một lý do thay đổi là hợp đồng REST với trình duyệt | PKG-13, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-26, PKG-30 |
| PKG-12 | PaymentCallbackApi | PKG-01 | Điểm vào công khai của cổng thanh toán: IPN, địa chỉ trả về của khách, hỏi lại trạng thái thanh toán | DC-PaymentCallbackController | Tách khỏi PKG-11 vì không đăng nhập, xác thực bằng chữ ký cổng và đổi theo định dạng callback của cổng (lý do thay đổi riêng); đường hỏi trạng thái đặt ở đây để không thêm cạnh PKG-11 --> PKG-14 | PKG-14 |
| PKG-29 | SeatMapClient | PKG-01 | Đồng bộ sơ đồ ghế phía trình duyệt: kết nối SSE, tải lại ảnh chụp, áp sự kiện theo từng ghế | DC-SeatMapSyncClient<br>DC-SeatMapReducer | Dùng chung bởi PKG-05 và PKG-06 (hai tác nhân) nên không đặt vào một trong hai (A3); cùng một quy tắc áp sự kiện (CCP) | - |
| PKG-31 | SessionClient | PKG-01 | Đăng nhập, giữ mã phiên của người dùng trên trình duyệt và đưa về màn đăng nhập khi máy chủ từ chối phiên | DC-LoginView<br>DC-SessionStore | Dùng chung cho mọi tác nhân đăng nhập nên không thuộc package giao diện của một tác nhân (A3); cùng một lý do thay đổi là cách giữ phiên (P09 F7.11) | - |
| PKG-13 | SeatBooking | PKG-02 | Giữ ghế, huỷ giữ ghế, xác nhận thu tiền mặt, bắt đầu thanh toán, giải phóng ghế, sơ đồ ghế, công việc hết hạn (kèm dọn seat_event) | DC-BookTicketsService<br>DC-SeatMapService<br>DC-HoldExpiryJob<br>DC-SeatReleaseJob<br>DC-HoldSeatsRequest<br>DC-HoldResult<br>DC-PaymentStart<br>DC-SseFrame<br>DC-SseStream | Cùng UC-005 và cùng chuỗi trạng thái SeatHold/SeatStatus; thay đổi cơ chế hết hạn kéo theo cả giữ ghế và giải phóng | PKG-21, PKG-22, PKG-24, PKG-25, PKG-27, PKG-28 |
| PKG-14 | PaymentRefund | PKG-02 | Xử lý IPN (kể cả thanh toán trễ), đọc trạng thái giao dịch cho trang kết quả và vòng đời hoàn tiền | DC-PaymentReportService<br>DC-IpnAnswer<br>DC-RefundService<br>DC-RefundOutboxJob<br>DC-IpnOutcome<br>DC-PaymentStatusView | Cùng giao dịch PaymentTransaction và RefundRequest (UC-005, UC-006, UC-008); hoàn tiền dùng chung (Q-106) | PKG-21, PKG-22, PKG-25, PKG-27, PKG-28 |
| PKG-15 | TicketService | PKG-02 | Huỷ vé, soát vé, lịch sử đặt vé của khách | DC-CancelTicketService<br>DC-CheckTicketService<br>DC-ViewBookingHistoryService<br>DC-CancelResult<br>DC-AdmitResult | Cùng thực thể Ticket và Booking (UC-007, UC-008, UC-009); cùng khoá hạng 8 (EX-06 đến EX-08) | PKG-14, PKG-21, PKG-27, PKG-28 |
| PKG-16 | ScheduleAndPricing | PKG-02 | Quản lý bảng giá, lịch suất chiếu, phòng chiếu và sơ đồ ghế | DC-ManagePriceListService<br>DC-ScheduleShowtimesService<br>DC-ManageAuditoriumsService | Cùng tác nhân ACT-04; cùng khoá Cinema, PriceList, Auditorium, Showtime, SeatStatus (EX-11 đến EX-15, EX-18, EX-19) | PKG-21, PKG-27, PKG-28 |
| PKG-17 | Catalog | PKG-02 | Tra cứu phim đang chiếu, sắp chiếu và lịch chiếu cho khách (chỉ đọc) | DC-BrowseMoviesService<br>DC-BrowseShowtimesService | Cùng tác nhân ACT-01 và cùng việc đọc danh mục Movie, Showtime (UC-003, UC-004); không có khoá | PKG-21, PKG-27 |
| PKG-18 | Reporting | PKG-02 | Báo cáo doanh thu và tỉ lệ lấp đầy của cụm rạp và toàn chuỗi trong một kỳ (chỉ đọc, F7.12) | DC-ViewCinemaReportService<br>DC-ViewChainReportService | Cùng khái niệm kỳ báo cáo và nhóm số liệu (UC-015, UC-016); cùng giao dịch chỉ đọc ở pool báo cáo; BR-115 đến BR-119 | PKG-21, PKG-27, PKG-28, PKG-33 |
| PKG-19 | AccountManagement | PKG-02 | Đăng ký khách, quản lý tài khoản nhân viên, đăng nhập và kiểm quyền truy cập theo mốc (F7.11) | DC-RegisterAccountService<br>DC-ManageStaffAccountsService<br>DC-LoginService<br>DC-AccessCheckService | Cùng dữ liệu tài khoản (Customer, Staff) và cùng khoá giá trị email (EX-20 đến EX-22); đăng nhập và kiểm mốc đọc cùng dòng Staff mà EX-22 ghi | PKG-21, PKG-26, PKG-27, PKG-28, PKG-32 |
| PKG-20 | Notification | PKG-02 | Lấy dòng hàng đợi email, dựng nội dung email vé và email hoàn tiền, gửi qua IF-03 | DC-EmailOutboxJob | Cùng một việc: hàng đợi email (BR-89, NFR-18) | PKG-21, PKG-23, PKG-25, PKG-27, PKG-28 |
| PKG-30 | ChainManagement | PKG-02 | Lưu phim và cụm rạp do quản lý chuỗi thêm hoặc sửa, kèm kiểm tên và mốc thay đổi (EX-16, EX-17) | DC-ManageMoviesService<br>DC-ManageCinemasService | Cùng tác nhân ACT-05 và cùng khoá hạng 0, 10; BR-138, BR-141, BR-142 | PKG-21, PKG-27 |
| PKG-21 | Persistence | PKG-03 | Giao dịch, khoá dòng theo hạng, SQL, seat_event, hàng đợi gửi | DC-PgUnitOfWork<br>DC-LockOrderGuard<br>DC-ConnectionPools<br>DC-PgCinemaOperationsStore<br>DC-PgTicketingStore<br>DC-PgSeatEventStore<br>DC-PgOutboxStore<br>DC-PgReportStore<br>DC-SeatEventWriter<br>IF-22<br>IF-23<br>DC-PgTx<br>DC-LockRank<br>DC-LockKey<br>DC-LockOrderViolationError<br>DC-OutboxKind<br>DC-OutboxStatus<br>DC-OutboxEntry<br>DC-ClaimLostError | Một công nghệ PostgreSQL; cùng lý do thay đổi là lược đồ và SQL; chỉ liệt kê phần tử, chi tiết P12 | PKG-27, PKG-28, PKG-32, PKG-33 |
| PKG-22 | PaymentGatewayClient | PKG-03 | Subsystem cổng thanh toán SS-01 | SS-01<br>IF-01<br>IF-02<br>DC-PaymentReport<br>DC-RefundOutcome<br>DC-RefundLookup<br>DC-InvalidGatewayRequestError<br>DC-GatewayConfigurationError<br>DC-InvalidSignatureError<br>DC-MalformedReportError | Một subsystem, đổi cổng sửa gói này, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14 (Q-141) | - |
| PKG-23 | EmailGatewayClient | PKG-03 | Subsystem dịch vụ email SS-02 | SS-02<br>IF-03<br>DC-EmailMessage<br>DC-EmailAttachment<br>DC-EmailSendResult<br>DC-InvalidEmailMessageError | Một subsystem (NFR-18) | - |
| PKG-24 | SeatEventHub | PKG-03 | Subsystem phát sự kiện đổi ghế SS-03 | SS-03<br>IF-04<br>DC-SeatEventSubscription<br>DC-SeatStreamItem<br>DC-SeatHubUnavailableError | Một subsystem (NFR-08, NFR-09) | PKG-21, PKG-27, PKG-28 |
| PKG-25 | Scheduler | PKG-03 | Subsystem hẹn giờ SS-04 và interface công việc IF-06 | SS-04<br>IF-05<br>IF-06<br>DC-JobRunResult<br>DC-SchedulerStateError | Một subsystem (NFR-07) | - |
| PKG-26 | Security | PKG-03 | Subsystem bảo mật SS-05 | SS-05<br>IF-07<br>DC-Role<br>DC-SessionClaims<br>DC-IssuedSession<br>DC-SessionInvalidError<br>DC-SessionExpiredError<br>DC-MalformedHashError<br>DC-InvalidAuthRequestError | Một subsystem (NFR-01 đến NFR-03, NFR-10) | - |
| PKG-27 | CinemaOperations | PKG-04 | Lớp miền cụm rạp, phòng chiếu, ghế, phim, suất chiếu, bảng giá; interface kho; interface giao dịch và khoá theo giá trị | DC-Cinema<br>DC-Auditorium<br>DC-Seat<br>DC-Movie<br>DC-Showtime<br>DC-PriceList<br>DC-PriceEntry<br>IF-08<br>IF-11<br>IF-12<br>IF-13<br>IF-14<br>IF-24<br>IF-25<br>DC-RandomCodeGenerator<br>DC-Money<br>DC-CinemaIds<br>DC-ShowtimeStatus<br>DC-PriceQuery<br>DC-ShowtimeRouting<br>DC-ShowtimeInfo<br>DC-TxOptions<br>DC-ValueLockKind<br>DC-NotFoundError<br>DC-SystemBusyError<br>DC-ShowtimeNotOpenError<br>DC-ShowtimeChangedError<br>DC-SeatSelectionError<br>DC-CancelDeadlineError | Quan hệ giữa các lớp (R-38 đến R-43, R-60 đến R-62) và cùng khoá PriceList, Auditorium, Showtime | - |
| PKG-28 | Ticketing | PKG-04 | Lớp miền khách, nhân viên quầy (lớp con của Staff), giữ ghế, thanh toán, hoàn tiền, đặt vé, vé; interface kho; kiểu sự kiện đổi ghế | DC-Customer<br>DC-BoxOfficeClerk<br>DC-SeatStatus<br>DC-SeatHold<br>DC-PaymentTransaction<br>DC-RefundRequest<br>DC-Booking<br>DC-Ticket<br>DC-HoldSettlement<br>IF-16<br>IF-17<br>IF-18<br>IF-19<br>IF-20<br>IF-21<br>IF-26<br>IF-27<br>DC-SeatChangeEvent<br>DC-TicketingIds<br>DC-HolderKind<br>DC-HolderRef<br>DC-ActorKind<br>DC-ActorContext<br>DC-SeatKey<br>DC-SeatState<br>DC-HoldStatus<br>DC-TicketStatus<br>DC-PaymentStatus<br>DC-RefundStatus<br>DC-RefundType<br>DC-AttemptResult<br>DC-AdmitOutcome<br>DC-SeatSnapshot<br>DC-BookingView<br>DC-HolderBusyError<br>DC-SeatUnavailableError<br>DC-HoldNotActiveError<br>DC-LinkMismatchError<br>DC-TicketStateError<br>DC-ChannelMismatchError<br>DC-PaymentStateError<br>DC-RefundLimitError<br>DC-RefundStateError | Quan hệ giữa các lớp (R-46 đến R-56, R-63, R-64) và cùng khoá hạng 4 đến 9 | PKG-27, PKG-32 |
| PKG-32 | StaffAccounts | PKG-04 | Lớp miền tài khoản nhân viên: lớp cha Staff, quản lý cụm rạp, nhân viên soát vé; interface kho nhân viên | DC-Staff<br>DC-CinemaManager<br>DC-TicketChecker<br>IF-15 | Quan hệ kế thừa (R-66 đến R-69) và cùng khoá hạng 4 của EX-22; đổi theo UC-017, không theo cấu hình rạp (CCP); đưa ra khỏi PKG-27 để PKG-27 không vượt 15 phần tử | PKG-27 |
| PKG-33 | ReportModel | PKG-04 | Lớp miền không lưu của báo cáo: kỳ, nhóm số liệu; interface truy vấn số liệu gộp | DC-ReportPeriod<br>DC-ReportGroup<br>IF-28<br>DC-ReportFigures | Cùng một yêu cầu báo cáo (UC-015, UC-016), đổi theo BR-115 đến BR-119; interface truy vấn ở Domain để PKG-21 hiện thực không đi lên Application | PKG-27 |

Chia nhỏ bên trong PKG-27 và PKG-28 (P09 F4 yêu cầu P10 chia nhỏ): PKG-27 giảm còn 15 phần tử có hành vi (7 lớp miền, 7 interface IF-08, IF-11 đến IF-14, IF-24, IF-25 và DC-RandomCodeGenerator) nhờ tách nhóm nhân viên sang PKG-32 và nhóm báo cáo sang PKG-33, mỗi nhóm có lý do thay đổi riêng và chỉ thêm một cạnh một chiều tới PKG-27. PKG-28 giữ 18 phần tử (8 lớp miền, DC-HoldSettlement, IF-16 đến IF-21, IF-26, IF-27, DC-SeatChangeEvent), vượt mức 15 (Vấn đề còn mở 2): tách interface kho khỏi lớp miền làm thêm cạnh phụ thuộc cho mọi package Application mà không giảm coupling giữa hai package miền.


## F5. Visibility

Ba nhãn đặc biệt: "chỉ vỏ ứng dụng React", "chỉ hàm khởi động chương trình đăng ký đường dẫn" và "chỉ hàm khởi động chương trình" chỉ nơi dùng nằm ngoài mô hình package (vỏ SPA, hàm khởi động chương trình Go dựng các lớp và nối IF-05, IF-08, IF-22, IF-23); các phần tử đó vẫn không bị package khác trong mô hình tham chiếu.

| PKG | Phần tử | Visibility (public / package-private) | Được dùng bởi (PKG) |
|---|---|---|---|
| PKG-05 | DC-BookTicketsView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-BookTicketsStore | package-private | - |
| PKG-05 | DC-CancelTicketView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-CancelTicketStore | package-private | - |
| PKG-05 | DC-CustomerHomeView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-BrowseMoviesView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-BrowseMoviesStore | package-private | - |
| PKG-05 | DC-BrowseShowtimesView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-BrowseShowtimesStore | package-private | - |
| PKG-05 | DC-RegisterAccountView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-RegisterAccountStore | package-private | - |
| PKG-05 | DC-ViewBookingHistoryView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-ViewBookingHistoryStore | package-private | - |
| PKG-06 | DC-CounterBookTicketsView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-06 | DC-CounterBookTicketsStore | package-private | - |
| PKG-06 | DC-CounterCancelTicketView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-06 | DC-CounterCancelTicketStore | package-private | - |
| PKG-06 | DC-CounterHomeView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-07 | DC-CheckTicketView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-07 | DC-CheckTicketStore | package-private | - |
| PKG-08 | DC-ManagePriceListView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ManagePriceListStore | package-private | - |
| PKG-08 | DC-ScheduleShowtimesView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ScheduleShowtimesStore | package-private | - |
| PKG-08 | DC-CinemaAdminHomeView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ManageAuditoriumsView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ManageAuditoriumsStore | package-private | - |
| PKG-08 | DC-ViewCinemaReportView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ViewCinemaReportStore | package-private | - |
| PKG-09 | DC-ManageMoviesView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-09 | DC-ManageMoviesStore | package-private | - |
| PKG-09 | DC-ManageCinemasView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-09 | DC-ManageCinemasStore | package-private | - |
| PKG-09 | DC-ViewChainReportView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-09 | DC-ViewChainReportStore | package-private | - |
| PKG-10 | DC-ManageStaffAccountsView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-10 | DC-ManageStaffAccountsStore | package-private | - |
| PKG-11 | DC-AuthFilter | package-private | - |
| PKG-11 | DC-BookingController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-SeatMapStreamController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-TicketController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-PricingScheduleController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-CatalogController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-AccountController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-ReportController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-ChainController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-12 | DC-PaymentCallbackController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-29 | DC-SeatMapSyncClient | public | PKG-05, PKG-06 |
| PKG-29 | DC-SeatMapReducer | public | PKG-05, PKG-06 |
| PKG-31 | DC-LoginView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-31 | DC-SessionStore | public | PKG-05, PKG-06, PKG-07, PKG-08, PKG-09, PKG-10 |
| PKG-13 | DC-BookTicketsService | public | PKG-11 |
| PKG-13 | DC-SeatMapService | public | PKG-11 |
| PKG-13 | DC-HoldExpiryJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-13 | DC-SeatReleaseJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-13 | DC-HoldSeatsRequest | public | - |
| PKG-13 | DC-HoldResult | public | - |
| PKG-13 | DC-PaymentStart | public | - |
| PKG-13 | DC-SseFrame | public | - |
| PKG-13 | DC-SseStream | public | - |
| PKG-14 | DC-PaymentReportService | public | PKG-12 |
| PKG-14 | DC-IpnAnswer | public | PKG-12 |
| PKG-14 | DC-RefundService | public | PKG-15 |
| PKG-14 | DC-RefundOutboxJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-14 | DC-IpnOutcome | public | - |
| PKG-14 | DC-PaymentStatusView | public | - |
| PKG-15 | DC-CancelTicketService | public | PKG-11 |
| PKG-15 | DC-CheckTicketService | public | PKG-11 |
| PKG-15 | DC-CancelResult | public | - |
| PKG-15 | DC-AdmitResult | public | - |
| PKG-15 | DC-ViewBookingHistoryService | public | PKG-11 |
| PKG-16 | DC-ManagePriceListService | public | PKG-11 |
| PKG-16 | DC-ScheduleShowtimesService | public | PKG-11 |
| PKG-16 | DC-ManageAuditoriumsService | public | PKG-11 |
| PKG-17 | DC-BrowseMoviesService | public | PKG-11 |
| PKG-17 | DC-BrowseShowtimesService | public | PKG-11 |
| PKG-18 | DC-ViewCinemaReportService | public | PKG-11 |
| PKG-18 | DC-ViewChainReportService | public | PKG-11 |
| PKG-19 | DC-RegisterAccountService | public | PKG-11 |
| PKG-19 | DC-ManageStaffAccountsService | public | PKG-11 |
| PKG-19 | DC-LoginService | public | PKG-11 |
| PKG-19 | DC-AccessCheckService | public | PKG-11 |
| PKG-20 | DC-EmailOutboxJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-30 | DC-ManageMoviesService | public | PKG-11 |
| PKG-30 | DC-ManageCinemasService | public | PKG-11 |
| PKG-21 | DC-PgUnitOfWork | public (chỉ hàm khởi động chương trình) | - |
| PKG-21 | DC-LockOrderGuard | package-private | - |
| PKG-21 | DC-ConnectionPools | public (chỉ hàm khởi động chương trình) | - |
| PKG-21 | DC-PgCinemaOperationsStore | public (chỉ hàm khởi động chương trình) | - |
| PKG-21 | DC-PgTicketingStore | public (chỉ hàm khởi động chương trình) | - |
| PKG-21 | DC-PgSeatEventStore | public (chỉ hàm khởi động chương trình) | - |
| PKG-21 | DC-PgOutboxStore | public (chỉ hàm khởi động chương trình) | - |
| PKG-21 | DC-SeatEventWriter | package-private | - |
| PKG-21 | IF-22 | public | PKG-13, PKG-24 |
| PKG-21 | IF-23 | public | PKG-13, PKG-14, PKG-20 |
| PKG-21 | DC-PgTx | package-private | - |
| PKG-21 | DC-LockRank | package-private | - |
| PKG-21 | DC-LockKey | package-private | - |
| PKG-21 | DC-LockOrderViolationError | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-19 |
| PKG-21 | DC-OutboxKind | public | PKG-13, PKG-14, PKG-20 |
| PKG-21 | DC-OutboxStatus | public | - |
| PKG-21 | DC-OutboxEntry | public | PKG-13, PKG-14, PKG-20 |
| PKG-21 | DC-ClaimLostError | public | PKG-13, PKG-14, PKG-20 |
| PKG-21 | DC-PgReportStore | public (chỉ hàm khởi động chương trình) | - |
| PKG-22 | SS-01 | package-private (chỉ interface của subsystem là public) | - |
| PKG-22 | IF-01 | public | PKG-13, PKG-14 |
| PKG-22 | IF-02 | public | PKG-14 |
| PKG-22 | DC-PaymentReport | public | PKG-14 |
| PKG-22 | DC-RefundOutcome | public | PKG-14 |
| PKG-22 | DC-RefundLookup | public | PKG-13, PKG-14 |
| PKG-22 | DC-InvalidGatewayRequestError | public | PKG-13, PKG-14 |
| PKG-22 | DC-GatewayConfigurationError | public | PKG-13, PKG-14 |
| PKG-22 | DC-InvalidSignatureError | public | PKG-14 |
| PKG-22 | DC-MalformedReportError | public | PKG-14 |
| PKG-23 | SS-02 | package-private (chỉ interface của subsystem là public) | - |
| PKG-23 | IF-03 | public | PKG-20 |
| PKG-23 | DC-EmailMessage | public | PKG-20 |
| PKG-23 | DC-EmailAttachment | public | theo P12 F1b |
| PKG-23 | DC-EmailSendResult | public | theo P12 F1b |
| PKG-23 | DC-InvalidEmailMessageError | public | theo P12 F1b |
| PKG-24 | SS-03 | package-private (chỉ interface của subsystem là public) | - |
| PKG-24 | IF-04 | public | PKG-13 |
| PKG-24 | DC-SeatEventSubscription | public | PKG-13 |
| PKG-24 | DC-SeatStreamItem | public | PKG-13 |
| PKG-24 | DC-SeatHubUnavailableError | public | PKG-13 |
| PKG-25 | SS-04 | package-private (chỉ interface của subsystem là public) | - |
| PKG-25 | IF-05 | public (chỉ hàm khởi động chương trình) | - |
| PKG-25 | IF-06 | public | PKG-13, PKG-14, PKG-20 |
| PKG-25 | DC-JobRunResult | public | PKG-13, PKG-14, PKG-20 |
| PKG-25 | DC-SchedulerStateError | public | - |
| PKG-26 | SS-05 | package-private (chỉ interface của subsystem là public) | - |
| PKG-26 | IF-07 | public | PKG-11, PKG-19 |
| PKG-26 | DC-Role | public | PKG-11, PKG-19 |
| PKG-26 | DC-SessionClaims | public | PKG-11, PKG-19 |
| PKG-26 | DC-IssuedSession | public | PKG-11, PKG-19 |
| PKG-26 | DC-SessionInvalidError | public | theo P12 F1b |
| PKG-26 | DC-SessionExpiredError | public | theo P12 F1b |
| PKG-26 | DC-MalformedHashError | public | theo P12 F1b |
| PKG-26 | DC-InvalidAuthRequestError | public | theo P12 F1b |
| PKG-27 | DC-Cinema | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28, PKG-30 |
| PKG-27 | DC-Auditorium | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-Seat | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-Movie | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28, PKG-30 |
| PKG-27 | DC-Showtime | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-PriceList | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28, PKG-30 |
| PKG-27 | DC-PriceEntry | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-08 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-19, PKG-21, PKG-17, PKG-18, PKG-30 |
| PKG-27 | IF-11 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-12 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28, PKG-30 |
| PKG-27 | IF-13 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28, PKG-30 |
| PKG-27 | IF-14 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28, PKG-30 |
| PKG-27 | IF-24 | public | theo P12 F1b |
| PKG-27 | IF-25 | public | theo P12 F1b |
| PKG-27 | DC-RandomCodeGenerator | public (chỉ hàm khởi động chương trình) | - |
| PKG-27 | DC-Money | public | PKG-13, PKG-14, PKG-28, PKG-33 |
| PKG-27 | DC-CinemaIds | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-24, PKG-28, PKG-30, PKG-32, PKG-33 |
| PKG-27 | DC-ShowtimeStatus | public | - |
| PKG-27 | DC-PriceQuery | public | - |
| PKG-27 | DC-ShowtimeRouting | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-ShowtimeInfo | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-TxOptions | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-19, PKG-21, PKG-17, PKG-18, PKG-30 |
| PKG-27 | DC-NotFoundError | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-SystemBusyError | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-19, PKG-21, PKG-17, PKG-18, PKG-30 |
| PKG-27 | DC-ShowtimeNotOpenError | public | - |
| PKG-27 | DC-ShowtimeChangedError | public | - |
| PKG-27 | DC-SeatSelectionError | public | - |
| PKG-27 | DC-CancelDeadlineError | public | - |
| PKG-27 | DC-ValueLockKind | public | PKG-19, PKG-21, PKG-30 |
| PKG-28 | DC-Customer | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-BoxOfficeClerk | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-SeatStatus | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-SeatHold | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-PaymentTransaction | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-RefundRequest | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-Booking | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-Ticket | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-HoldSettlement | public | PKG-13, PKG-14 |
| PKG-28 | IF-16 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-17 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-18 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-19 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-20 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-21 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-26 | public | PKG-13, PKG-21 |
| PKG-28 | IF-27 | public | PKG-15, PKG-16, PKG-21 |
| PKG-28 | DC-SeatChangeEvent | public | PKG-13, PKG-21, PKG-24 |
| PKG-28 | DC-TicketingIds | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21, PKG-24 |
| PKG-28 | DC-HolderKind | public | - |
| PKG-28 | DC-HolderRef | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-ActorKind | public | - |
| PKG-28 | DC-ActorContext | public | PKG-15 |
| PKG-28 | DC-SeatKey | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-SeatState | public | - |
| PKG-28 | DC-HoldStatus | public | - |
| PKG-28 | DC-TicketStatus | public | - |
| PKG-28 | DC-PaymentStatus | public | - |
| PKG-28 | DC-RefundStatus | public | - |
| PKG-28 | DC-RefundType | public | - |
| PKG-28 | DC-AttemptResult | public | - |
| PKG-28 | DC-AdmitOutcome | public | - |
| PKG-28 | DC-SeatSnapshot | public | PKG-13, PKG-21, PKG-24 |
| PKG-28 | DC-BookingView | public | PKG-13, PKG-15 |
| PKG-28 | DC-HolderBusyError | public | - |
| PKG-28 | DC-SeatUnavailableError | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-HoldNotActiveError | public | - |
| PKG-28 | DC-LinkMismatchError | public | - |
| PKG-28 | DC-TicketStateError | public | - |
| PKG-28 | DC-ChannelMismatchError | public | - |
| PKG-28 | DC-PaymentStateError | public | - |
| PKG-28 | DC-RefundLimitError | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-RefundStateError | public | - |
| PKG-32 | DC-Staff | public | PKG-19, PKG-21, PKG-28 |
| PKG-32 | DC-CinemaManager | public | PKG-19, PKG-21 |
| PKG-32 | DC-TicketChecker | public | PKG-19, PKG-21 |
| PKG-32 | IF-15 | public | PKG-19, PKG-21 |
| PKG-33 | DC-ReportPeriod | public | PKG-18 |
| PKG-33 | DC-ReportGroup | public | PKG-18 |
| PKG-33 | IF-28 | public | PKG-18, PKG-21 |
| PKG-33 | DC-ReportFigures | public | PKG-18, PKG-21 |


## F6. Kiểm tra coupling giữa package

P09 chọn layered nới lỏng nên cột Nhảy layer ghi "Không áp dụng". Phụ thuộc tới subsystem đều đi qua interface của nó (cột Phụ thuộc ghi "qua IF-nn"). Đã kiểm bằng chương trình: không có cặp phụ thuộc hai chiều, không có vòng (cả đồ thị 29 package lẫn đồ thị sau khi gộp thành 10 package Go ở Phụ lục), không có cạnh đi từ layer dưới lên layer trên.

| Phụ thuộc (PKG --> PKG) | Suy ra từ (quan hệ lớp, message) | Cross-coupled | Lower --> Upper | Nhảy layer | Vòng | Kết luận và cách sửa |
|---|---|---|---|---|---|---|
| PKG-05 --> PKG-29 | DC-BookTicketsStore, DC-CancelTicketStore dùng DC-SeatMapSyncClient, DC-SeatMapReducer | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-06 --> PKG-29 | DC-CounterBookTicketsStore, DC-CounterCancelTicketStore dùng DC-SeatMapSyncClient, DC-SeatMapReducer | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-05 --> PKG-31 | DC-BookTicketsStore, DC-CancelTicketStore, DC-BrowseMoviesStore, DC-BrowseShowtimesStore, DC-RegisterAccountStore, DC-ViewBookingHistoryStore dùng DC-SessionStore (mã phiên, 401) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-06 --> PKG-31 | DC-CounterBookTicketsStore, DC-CounterCancelTicketStore dùng DC-SessionStore | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-07 --> PKG-31 | DC-CheckTicketStore dùng DC-SessionStore | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-08 --> PKG-31 | DC-ManagePriceListStore, DC-ScheduleShowtimesStore, DC-ManageAuditoriumsStore, DC-ViewCinemaReportStore dùng DC-SessionStore | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-09 --> PKG-31 | DC-ManageMoviesStore, DC-ManageCinemasStore, DC-ViewChainReportStore dùng DC-SessionStore | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-10 --> PKG-31 | DC-ManageStaffAccountsStore dùng DC-SessionStore | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-13 | DC-BookingController gọi DC-BookTicketsService; DC-SeatMapStreamController gọi DC-SeatMapService và chỉ nhận khung SSE dạng văn bản, không chạm kiểu sự kiện của Domain (P07 UC-005) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-15 | DC-TicketController gọi DC-CancelTicketService, DC-CheckTicketService, DC-ViewBookingHistoryService (P07 UC-007, UC-008, UC-009) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-16 | DC-PricingScheduleController gọi DC-ManagePriceListService, DC-ScheduleShowtimesService, DC-ManageAuditoriumsService (P07 UC-012, UC-013, UC-014) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-17 | DC-CatalogController gọi DC-BrowseMoviesService, DC-BrowseShowtimesService (P07 UC-003, UC-004) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-18 | DC-ReportController gọi DC-ViewCinemaReportService, DC-ViewChainReportService (P07 UC-015, UC-016) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-19 | DC-AccountController gọi DC-RegisterAccountService, DC-ManageStaffAccountsService, DC-LoginService (P07 UC-001, UC-017); DC-AuthFilter gọi DC-AccessCheckService để kiểm mốc truy cập (P09 F7.11) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-30 | DC-ChainController gọi DC-ManageMoviesService, DC-ManageCinemasService (P07 UC-010, UC-011) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-26 (qua IF-07) | DC-AuthFilter gọi IF-07 (ngoại lệ cho phép của P09 F6) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-12 --> PKG-14 | DC-PaymentCallbackController gọi DC-PaymentReportService (HandleIpn nhận DC-IpnAnswer, ResolveReturnedPayment, QueryPaymentStatus; P07 UC-005 bước 11, UC-006 bước 2) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-22 (qua IF-01) | DC-BookTicketsService gọi IF-01 để ký URL thanh toán (P07 UC-005 bước 10) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-24 (qua IF-04) | DC-SeatMapService gọi IF-04 để đăng ký nhận cập nhật | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-21 | Mở giao dịch qua IF-08, đọc ảnh chụp và dọn sự kiện qua IF-22 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-27 | Dùng DC-Showtime, DC-PriceList, IF-11, IF-12, IF-13 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-28 | Dùng DC-HoldSettlement, DC-SeatHold, DC-SeatStatus, IF-16, IF-17, IF-18, IF-20, IF-26 (EX-01, EX-03, EX-04, EX-05); DC-SeatMapService dịch DC-SeatChangeEvent | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-25 (qua IF-06) | DC-HoldExpiryJob, DC-SeatReleaseJob hiện thực IF-06 (realization đi xuống) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-22 (qua IF-01, IF-02) | DC-PaymentReportService gọi IF-02; DC-RefundService gọi IF-01 (P07 UC-006 bước 3, 5) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-21 | Mở giao dịch qua IF-08; hàng đợi gửi qua IF-23 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-27 | EX-02 tạo DC-Booking, DC-Ticket tham chiếu DC-Showtime, DC-Seat (P09 F6) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-28 | Dùng DC-HoldSettlement, DC-PaymentTransaction, DC-RefundRequest, DC-SeatHold, DC-SeatStatus, IF-17 đến IF-21 (EX-02, EX-09, EX-10) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-25 (qua IF-06) | DC-RefundOutboxJob hiện thực IF-06 (realization đi xuống) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-14 | DC-CancelTicketService gọi DC-RefundService (P07 UC-008 bước 5); PKG-14 không phụ thuộc PKG-15 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-21 | Mở giao dịch qua IF-08 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-27 | DC-CancelTicketService, DC-CheckTicketService đọc DC-Showtime (BR-33, hạn huỷ); DC-ViewBookingHistoryService đọc thông tin suất chiếu (UC-007) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-28 | Dùng DC-Ticket, DC-Booking, IF-18, IF-19, IF-20, IF-21, IF-27 (EX-06, EX-07, EX-08); DC-ViewBookingHistoryService đọc lịch sử qua IF-20 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-16 --> PKG-21 | Mở giao dịch qua IF-08 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-16 --> PKG-27 | Dùng DC-PriceList, DC-Showtime, DC-Auditorium, DC-Cinema, DC-Seat, IF-11, IF-12, IF-13, IF-14 (EX-11 đến EX-15, EX-18, EX-19) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-16 --> PKG-28 | EX-13, EX-14, EX-15 khoá IF-17, IF-18, IF-27 (SeatHold S, SeatStatus X, Ticket S); DC-ManageAuditoriumsService tạo, bỏ SeatStatus qua IF-18 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-17 --> PKG-21 | Mở giao dịch đọc qua IF-08 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-17 --> PKG-27 | DC-BrowseMoviesService, DC-BrowseShowtimesService đọc DC-Movie, DC-Showtime, DC-Cinema, DC-Auditorium qua IF-11, IF-13, IF-14 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-21 | Mở giao dịch chỉ đọc ở pool báo cáo qua IF-08 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-27 | Danh sách cụm rạp của báo cáo toàn chuỗi qua IF-13; DC-CinemaIds, DC-Money | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-28 | Giữ cạnh của P09 F6: định nghĩa doanh thu ròng theo vé và khoản hoàn (DC-Ticket.calculateNetRevenue, DC-RefundRequest, BR-115, BR-119); số liệu gộp lấy qua IF-28 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-33 | DC-ViewCinemaReportService, DC-ViewChainReportService dùng DC-ReportPeriod, DC-ReportGroup, IF-28, DC-ReportFigures (P07 UC-015, UC-016) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-21 | Mở giao dịch qua IF-08 (EX-20 đến EX-22, LockValue); giao dịch đọc ngắn của kiểm phiên và đăng nhập | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-26 (qua IF-07) | DC-LoginService, DC-RegisterAccountService, DC-ManageStaffAccountsService gọi IF-07 (băm, kiểm mật khẩu, cấp phiên) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-27 | DC-ManageStaffAccountsService kiểm cụm rạp tồn tại qua IF-13; dùng IF-08, DC-ValueLockKind, DC-TxOptions, DC-CinemaIds | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-28 | DC-RegisterAccountService tạo DC-Customer qua IF-16; DC-LoginService đọc khách qua IF-16 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-32 | DC-ManageStaffAccountsService, DC-LoginService, DC-AccessCheckService dùng DC-Staff, IF-15 (EX-21, EX-22, đăng nhập, kiểm mốc) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-21 | DC-EmailOutboxJob dùng IF-23 (claim, ghi kết quả) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-23 (qua IF-03) | DC-EmailOutboxJob gọi IF-03 (P07 UC-005 bước 14, UC-006 bước 7) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-27 | DC-EmailOutboxJob dựng nội dung email từ DC-Showtime, DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie (cạnh P09 F6 còn thiếu, xem Đề xuất sửa) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-28 | DC-EmailOutboxJob đọc DC-Booking, DC-Ticket qua IF-20 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-25 (qua IF-06) | DC-EmailOutboxJob hiện thực IF-06 (realization đi xuống) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-30 --> PKG-21 | Mở giao dịch qua IF-08; DC-ManageCinemasService lấy khoá giá trị tên qua IF-08.LockValue (EX-16, EX-17) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-30 --> PKG-27 | Dùng DC-Movie, DC-Cinema, DC-PriceList, IF-12, IF-13, IF-14, DC-ValueLockKind (EX-16, EX-17) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-21 --> PKG-27 | DC-PgUnitOfWork hiện thực IF-08; DC-PgCinemaOperationsStore hiện thực IF-11 đến IF-15 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-21 --> PKG-28 | DC-PgTicketingStore hiện thực IF-16 đến IF-21, IF-26, IF-27; DC-SeatEventWriter dùng DC-SeatChangeEvent | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-21 --> PKG-32 | DC-PgCinemaOperationsStore hiện thực IF-15 (Services --> Domain) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-21 --> PKG-33 | DC-PgReportStore hiện thực IF-28 (Services --> Domain) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-24 --> PKG-21 | Hub đọc seat_event qua IF-22 (cùng layer, một chiều; PKG-21 không phụ thuộc PKG-24) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-24 --> PKG-28 | Hub phát DC-SeatChangeEvent | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-24 --> PKG-27 | IF-04 và DC-SeatChangeEvent dùng kiểu ShowtimeId của DC-CinemaIds (cùng layer Services --> Domain, hợp lệ theo P09 F6) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-28 --> PKG-27 | DC-SeatStatus, DC-Ticket tham chiếu DC-Showtime, DC-Seat (cùng layer, một chiều; PKG-27 không phụ thuộc PKG-28) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-28 --> PKG-32 | DC-BoxOfficeClerk kế thừa DC-Staff (cùng layer, một chiều; PKG-32 không phụ thuộc PKG-28) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-32 --> PKG-27 | DC-Staff giữ mã cụm rạp (DC-CinemaIds) (cùng layer, một chiều; PKG-27 không phụ thuộc PKG-32) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-33 --> PKG-27 | DC-ReportFigures, IF-28 dùng DC-CinemaIds, DC-Money (cùng layer, một chiều; PKG-27 không phụ thuộc PKG-33) | Không | Không | Không áp dụng | Không | Hợp lệ |

So với P09 F6, P10 thêm PKG-20 --> PKG-27, PKG-24 --> PKG-27 và các cạnh của hai package mới (PKG-28 --> PKG-32, PKG-32 --> PKG-27, PKG-33 --> PKG-27, PKG-19 --> PKG-32, PKG-21 --> PKG-32, PKG-21 --> PKG-33, PKG-18 --> PKG-33), đổi cạnh tới PKG-22, PKG-23, PKG-24, PKG-26 thành phụ thuộc interface; không cạnh P09 nào bị bỏ. Các phụ thuộc kiểu "cùng layer, một chiều" gồm PKG-15 --> PKG-14, PKG-24 --> PKG-21, PKG-24 --> PKG-27, PKG-28 --> PKG-27, PKG-28 --> PKG-32, PKG-32 --> PKG-27, PKG-33 --> PKG-27, PKG-05 --> PKG-29, PKG-06 --> PKG-29 và PKG-05 đến PKG-10 --> PKG-31 đều không có chiều ngược.


## F7. Package diagram thiết kế

File diagrams/P10-package-design.drawio. Chỉ vẽ interface của subsystem (IF-01 đến IF-07) và các lớp hiện thực interface gọi ngược. Interface kho dữ liệu, IF-08, IF-22, IF-23, IF-28 không vẽ: phụ thuộc tới chúng thể hiện ở cạnh giữa các package (các cạnh tới PKG-21, PKG-27, PKG-28, ví dụ D-13, D-14, D-15, D-45, D-46, D-47, D-72, D-73), tên interface ở F3 và F6. Interface vẽ dạng rút gọn (lollipop).

a) Bảng Node

| ID (PKG, SS, IF, DC) | Loại (Layer / Package / Subsystem / Interface / Class) | Nhãn | Stereotype («layer», «subsystem», «interface») | Thuộc về | Ghi chú (visibility) |
|---|---|---|---|---|---|
| PKG-01 | Layer | Presentation | «layer» | - | Chứa các package con |
| PKG-02 | Layer | Application | «layer» | - | Chứa các package con |
| PKG-03 | Layer | Services | «layer» | - | Chứa các package con |
| PKG-04 | Layer | Domain | «layer» | - | Chứa các package con |
| PKG-05 | Package | CustomerWeb | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-06 | Package | CounterWeb | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-07 | Package | CheckInWeb | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-08 | Package | CinemaAdminWeb | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-09 | Package | ChainAdminWeb | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-10 | Package | AccountAdminWeb | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-11 | Package | HttpApi | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-12 | Package | PaymentCallbackApi | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-29 | Package | SeatMapClient | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-31 | Package | SessionClient | - | PKG-01 | Không vẽ phần tử bên trong |
| PKG-13 | Package | SeatBooking | - | PKG-02 | Phần tử vẽ: DC-HoldExpiryJob, DC-SeatReleaseJob |
| PKG-14 | Package | PaymentRefund | - | PKG-02 | Phần tử vẽ: DC-RefundOutboxJob |
| PKG-15 | Package | TicketService | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-16 | Package | ScheduleAndPricing | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-17 | Package | Catalog | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-18 | Package | Reporting | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-19 | Package | AccountManagement | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-20 | Package | Notification | - | PKG-02 | Phần tử vẽ: DC-EmailOutboxJob |
| PKG-30 | Package | ChainManagement | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-21 | Package | Persistence | - | PKG-03 | Không vẽ phần tử bên trong |
| PKG-22 | Package | PaymentGatewayClient | - | PKG-03 | Phần tử vẽ: SS-01, IF-01, IF-02 |
| PKG-23 | Package | EmailGatewayClient | - | PKG-03 | Phần tử vẽ: SS-02, IF-03 |
| PKG-24 | Package | SeatEventHub | - | PKG-03 | Phần tử vẽ: SS-03, IF-04 |
| PKG-25 | Package | Scheduler | - | PKG-03 | Phần tử vẽ: SS-04, IF-05, IF-06 |
| PKG-26 | Package | Security | - | PKG-03 | Phần tử vẽ: SS-05, IF-07 |
| PKG-27 | Package | CinemaOperations | - | PKG-04 | Không vẽ phần tử bên trong |
| PKG-28 | Package | Ticketing | - | PKG-04 | Không vẽ phần tử bên trong |
| PKG-32 | Package | StaffAccounts | - | PKG-04 | Không vẽ phần tử bên trong |
| PKG-33 | Package | ReportModel | - | PKG-04 | Không vẽ phần tử bên trong |
| DC-HoldExpiryJob | Class | HoldExpiryJob | - | PKG-13 | Lớp hiện thực interface; package-private |
| DC-SeatReleaseJob | Class | SeatReleaseJob | - | PKG-13 | Lớp hiện thực interface; package-private |
| DC-RefundOutboxJob | Class | RefundOutboxJob | - | PKG-14 | Lớp hiện thực interface; package-private |
| DC-EmailOutboxJob | Class | EmailOutboxJob | - | PKG-20 | Lớp hiện thực interface; package-private |
| SS-01 | Subsystem | PaymentGateway | «subsystem» | PKG-22 | Chỉ interface public |
| IF-01 | Interface | IPaymentGateway | «interface» | PKG-22 | Dạng rút gọn (lollipop) |
| IF-02 | Interface | IPaymentReportReceiver | «interface» | PKG-22 | Dạng rút gọn (lollipop) |
| SS-02 | Subsystem | EmailGateway | «subsystem» | PKG-23 | Chỉ interface public |
| IF-03 | Interface | IEmailSender | «interface» | PKG-23 | Dạng rút gọn (lollipop) |
| SS-03 | Subsystem | SeatEventHub | «subsystem» | PKG-24 | Chỉ interface public |
| IF-04 | Interface | ISeatEventSubscription | «interface» | PKG-24 | Dạng rút gọn (lollipop) |
| SS-04 | Subsystem | Scheduler | «subsystem» | PKG-25 | Chỉ interface public |
| IF-05 | Interface | IJobScheduler | «interface» | PKG-25 | Dạng rút gọn (lollipop) |
| IF-06 | Interface | IScheduledJob | «interface» | PKG-25 | Dạng rút gọn (lollipop) |
| SS-05 | Subsystem | Security | «subsystem» | PKG-26 | Chỉ interface public |
| IF-07 | Interface | IAuthenticator | «interface» | PKG-26 | Dạng rút gọn (lollipop) |

b) Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ (Dependency / Realization) | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| D-01 | PKG-05 | PKG-29 | Dependency | - | Đồng bộ sơ đồ ghế |
| D-02 | PKG-06 | PKG-29 | Dependency | - | Đồng bộ sơ đồ ghế |
| D-03 | PKG-11 | PKG-13 | Dependency | - | UC-005 |
| D-04 | PKG-11 | PKG-15 | Dependency | - | UC-007, UC-008, UC-009 |
| D-05 | PKG-11 | PKG-16 | Dependency | - | UC-012, UC-013, UC-014 |
| D-06 | PKG-11 | PKG-17 | Dependency | - | UC-003, UC-004 |
| D-07 | PKG-11 | PKG-18 | Dependency | - | UC-015, UC-016 |
| D-08 | PKG-11 | PKG-19 | Dependency | - | UC-001, UC-017; kiểm mốc truy cập (F7.11) |
| D-09 | PKG-11 | IF-07 | Dependency | - | Kiểm tra mã phiên (ngoại lệ P09 F6) |
| D-10 | PKG-12 | PKG-14 | Dependency | - | Chuyển IPN |
| D-11 | PKG-13 | IF-01 | Dependency | - | Ký URL thanh toán |
| D-12 | PKG-13 | IF-04 | Dependency | - | Đăng ký nhận cập nhật |
| D-13 | PKG-13 | PKG-21 | Dependency | - | Giao dịch, kho, seat_event |
| D-14 | PKG-13 | PKG-27 | Dependency | - | - |
| D-15 | PKG-13 | PKG-28 | Dependency | - | - |
| D-16 | DC-HoldExpiryJob | IF-06 | Realization | «realize» | Công việc hết hạn |
| D-17 | DC-SeatReleaseJob | IF-06 | Realization | «realize» | Công việc giải phóng ghế |
| D-19 | PKG-14 | IF-01 | Dependency | - | Hoàn tiền, tra cứu hoàn |
| D-20 | PKG-14 | IF-02 | Dependency | - | Kiểm chữ ký, dịch kết quả |
| D-21 | PKG-14 | PKG-21 | Dependency | - | Giao dịch, kho, hàng đợi |
| D-22 | PKG-14 | PKG-27 | Dependency | - | - |
| D-23 | PKG-14 | PKG-28 | Dependency | - | - |
| D-24 | DC-RefundOutboxJob | IF-06 | Realization | «realize» | Công việc gửi hoàn tiền |
| D-25 | PKG-15 | PKG-14 | Dependency | - | Huỷ vé gọi hoàn tiền; PKG-14 không phụ thuộc PKG-15 |
| D-26 | PKG-15 | PKG-21 | Dependency | - | - |
| D-27 | PKG-15 | PKG-27 | Dependency | - | - |
| D-28 | PKG-15 | PKG-28 | Dependency | - | - |
| D-29 | PKG-16 | PKG-21 | Dependency | - | - |
| D-30 | PKG-16 | PKG-27 | Dependency | - | - |
| D-31 | PKG-16 | PKG-28 | Dependency | - | - |
| D-32 | PKG-17 | PKG-21 | Dependency | - | Đọc danh mục |
| D-33 | PKG-17 | PKG-27 | Dependency | - | Đọc danh mục |
| D-34 | PKG-18 | PKG-21 | Dependency | - | Giao dịch chỉ đọc, pool báo cáo |
| D-35 | PKG-18 | PKG-27 | Dependency | - | Danh sách cụm rạp |
| D-36 | PKG-18 | PKG-28 | Dependency | - | Cạnh của P09 F6 |
| D-37 | PKG-19 | PKG-21 | Dependency | - | Giao dịch, khoá giá trị, đọc phiên |
| D-38 | PKG-19 | IF-07 | Dependency | - | Băm, kiểm mật khẩu, cấp phiên |
| D-39 | PKG-19 | PKG-27 | Dependency | - | Cụm rạp của nhân viên |
| D-40 | PKG-19 | PKG-28 | Dependency | - | Khách |
| D-41 | PKG-20 | PKG-21 | Dependency | - | Hàng đợi email |
| D-42 | PKG-20 | IF-03 | Dependency | - | Gửi email |
| D-43 | PKG-20 | PKG-28 | Dependency | - | Đọc lần đặt, vé |
| D-44 | DC-EmailOutboxJob | IF-06 | Realization | «realize» | Công việc gửi email |
| D-45 | PKG-21 | PKG-27 | Dependency | - | Hiện thực IF-08, IF-11 đến IF-14 |
| D-46 | PKG-21 | PKG-28 | Dependency | - | Hiện thực IF-16 đến IF-21 |
| D-47 | PKG-24 | PKG-21 | Dependency | - | Đọc seat_event qua IF-22; cùng layer, một chiều |
| D-48 | PKG-24 | PKG-28 | Dependency | - | Kiểu sự kiện đổi ghế |
| D-49 | PKG-28 | PKG-27 | Dependency | - | Cùng layer, một chiều |
| D-52 | SS-01 | IF-01 | Realization | «realize» | - |
| D-53 | SS-01 | IF-02 | Realization | «realize» | - |
| D-54 | SS-02 | IF-03 | Realization | «realize» | - |
| D-55 | SS-03 | IF-04 | Realization | «realize» | - |
| D-56 | SS-04 | IF-05 | Realization | «realize» | - |
| D-57 | SS-05 | IF-07 | Realization | «realize» | - |
| D-58 | SS-04 | IF-06 | Dependency | - | Gọi công việc đến hạn |
| D-59 | PKG-20 | PKG-27 | Dependency | - | Dựng nội dung email từ suất chiếu, phòng, phim |
| D-60 | PKG-24 | PKG-27 | Dependency | - | Kiểu ShowtimeId trong chữ ký IF-04 và DC-SeatChangeEvent |
| D-61 | PKG-05 | PKG-31 | Dependency | - | Phiên đăng nhập |
| D-62 | PKG-06 | PKG-31 | Dependency | - | Phiên đăng nhập |
| D-63 | PKG-07 | PKG-31 | Dependency | - | Phiên đăng nhập |
| D-64 | PKG-08 | PKG-31 | Dependency | - | Phiên đăng nhập |
| D-65 | PKG-09 | PKG-31 | Dependency | - | Phiên đăng nhập |
| D-66 | PKG-10 | PKG-31 | Dependency | - | Phiên đăng nhập |
| D-67 | PKG-11 | PKG-30 | Dependency | - | UC-010, UC-011 |
| D-68 | PKG-30 | PKG-21 | Dependency | - | Giao dịch, khoá giá trị tên |
| D-69 | PKG-30 | PKG-27 | Dependency | - | Phim, cụm rạp, bảng giá |
| D-70 | PKG-18 | PKG-33 | Dependency | - | Kỳ, nhóm số liệu, truy vấn gộp |
| D-71 | PKG-19 | PKG-32 | Dependency | - | Nhân viên, kiểm mốc |
| D-72 | PKG-21 | PKG-32 | Dependency | - | Hiện thực IF-15 |
| D-73 | PKG-21 | PKG-33 | Dependency | - | Hiện thực IF-28 |
| D-74 | PKG-28 | PKG-32 | Dependency | - | Cùng layer, một chiều (DC-BoxOfficeClerk kế thừa DC-Staff) |
| D-75 | PKG-32 | PKG-27 | Dependency | - | Cùng layer, một chiều |
| D-76 | PKG-33 | PKG-27 | Dependency | - | Cùng layer, một chiều |

Không có cạnh đi lên. Cạnh có đích là IF-nn (D-09, D-11, D-12, D-19, D-20, D-38, D-42) thể hiện phụ thuộc vào interface của subsystem, không vào subsystem. Cạnh D-16, D-17, D-24, D-44 là realization đi xuống từ lớp ở Application tới IF-06; D-52 đến D-57 là realization của subsystem tới interface của nó; D-58 là phụ thuộc của SS-04 vào IF-06 (Scheduler gọi công việc đến hạn). Mã D-18, D-50, D-51 không dùng lại (phần tử đã gộp hoặc loại).

## F8. Subsystem context diagram

File diagrams/P10-subsystem-context.drawio, mỗi subsystem một trang (5 trang). Interface vẽ dạng canonical với trách nhiệm "// ..."; operation chi tiết do P11b làm.

Trang SS-01 PaymentGateway

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| SS-01 | Subsystem | «subsystem»<br>PaymentGateway | «subsystem» | - | Chỉ interface là public |
| DC-BookTicketsService | Class | BookTicketsService | - | - | Lớp thiết kế PKG-13 |
| DC-RefundService | Class | RefundService | - | - | Lớp thiết kế PKG-14 |
| DC-PaymentReportService | Class | PaymentReportService | - | - | Lớp thiết kế PKG-14 |
| IF-01 | Interface | «interface»<br>IPaymentGateway | «interface» | - | Trách nhiệm: // createPaymentTransaction: ký URL thanh toán có mã giao dịch và mã tham chiếu lần giữ ghế, không gọi mạng; // requestRefund: gửi hoàn tiền kèm khoá chống hoàn trùng, chờ 30 giây; // findRefund: tra cứu giao dịch hoàn trước khi gửi lại; không tra cứu được thì bên gọi chuyển Cần xử lý thủ công |
| IF-02 | Interface | «interface»<br>IPaymentReportReceiver | «interface» | - | Trách nhiệm: // reportTransactionResult: kiểm chữ ký, giải mã số tiền, dịch thông báo của cổng thành kết quả; DC-PaymentReportService so số tiền với bản ghi |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| C01-01 | SS-01 | IF-01 | Realization | «realize» | - |
| C01-02 | SS-01 | IF-02 | Realization | «realize» | - |
| C01-03 | DC-BookTicketsService | IF-01 | Dependency | - | - |
| C01-04 | DC-RefundService | IF-01 | Dependency | - | - |
| C01-05 | DC-PaymentReportService | IF-02 | Dependency | - | - |

Trang SS-02 EmailGateway

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| SS-02 | Subsystem | «subsystem»<br>EmailGateway | «subsystem» | - | Chỉ interface là public |
| DC-EmailOutboxJob | Class | EmailOutboxJob | - | - | Lớp thiết kế PKG-20 |
| IF-03 | Interface | «interface»<br>IEmailSender | «interface» | - | Trách nhiệm: // sendEmail: gửi một thư đã dựng sẵn; nội dung thư do DC-EmailOutboxJob dựng |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| C02-01 | SS-02 | IF-03 | Realization | «realize» | - |
| C02-02 | DC-EmailOutboxJob | IF-03 | Dependency | - | - |

Trang SS-03 SeatEventHub

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| SS-03 | Subsystem | «subsystem»<br>SeatEventHub | «subsystem» | - | Chỉ interface là public |
| DC-SeatMapService | Class | SeatMapService | - | - | Lớp thiết kế PKG-13 |
| IF-04 | Interface | «interface»<br>ISeatEventSubscription | «interface» | - | Trách nhiệm: // subscribe: đăng ký nhận sự kiện đổi ghế của một suất chiếu từ một con trỏ, trả luồng sự kiện phát lại rồi trực tiếp, bên gọi đọc luồng; // unsubscribe: huỷ đăng ký khi kết nối đóng |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| C03-01 | SS-03 | IF-04 | Realization | «realize» | - |
| C03-02 | DC-SeatMapService | IF-04 | Dependency | - | - |

Trang SS-04 Scheduler

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| SS-04 | Subsystem | «subsystem»<br>Scheduler | «subsystem» | - | Chỉ interface là public |
| DC-HoldExpiryJob | Class | HoldExpiryJob | - | - | Lớp thiết kế PKG-13 |
| DC-SeatReleaseJob | Class | SeatReleaseJob | - | - | Lớp thiết kế PKG-13 |
| DC-RefundOutboxJob | Class | RefundOutboxJob | - | - | Lớp thiết kế PKG-14 |
| DC-EmailOutboxJob | Class | EmailOutboxJob | - | - | Lớp thiết kế PKG-20 |
| N-BOOT | Note | Hàm khởi động chương trình | - | - | Ngoài mô hình package (P09 F4) |
| IF-06 | Interface | «interface»<br>IScheduledJob | «interface» | - | Trách nhiệm: // runDue: chạy một lượt công việc đến hạn, kết thúc khi hết việc hoặc hết ngân sách thời gian |
| IF-05 | Interface | «interface»<br>IJobScheduler | «interface» | - | Trách nhiệm: // registerJob: đăng ký công việc và chu kỳ; // start: bắt đầu chạy định kỳ; // stop: dừng khi tắt chương trình |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| C04-01 | SS-04 | IF-05 | Realization | «realize» | - |
| C04-02 | SS-04 | IF-06 | Dependency | - | - |
| C04-03 | DC-HoldExpiryJob | IF-06 | Realization | «realize» | - |
| C04-04 | DC-SeatReleaseJob | IF-06 | Realization | «realize» | - |
| C04-06 | DC-RefundOutboxJob | IF-06 | Realization | «realize» | - |
| C04-07 | DC-EmailOutboxJob | IF-06 | Realization | «realize» | - |
| C04-08 | N-BOOT | IF-05 | Dependency | - | - |

Trang SS-05 Security

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| SS-05 | Subsystem | «subsystem»<br>Security | «subsystem» | - | Chỉ interface là public |
| DC-AuthFilter | Class | AuthFilter | - | - | Lớp thiết kế PKG-11 |
| DC-LoginService | Class | LoginService | - | - | Lớp thiết kế PKG-19 |
| DC-RegisterAccountService | Class | RegisterAccountService | - | - | Lớp thiết kế PKG-19 |
| DC-ManageStaffAccountsService | Class | ManageStaffAccountsService | - | - | Lớp thiết kế PKG-19 |
| IF-07 | Interface | «interface»<br>IAuthenticator | «interface» | - | Trách nhiệm: // hashPassword: băm mật khẩu; // verifyPassword: kiểm mật khẩu khi đăng nhập; // issueSession: cấp mã phiên mang loại chủ thể và, với nhân viên, mốc truy cập đã đọc lúc đăng nhập; // verifySession: kiểm chữ ký, hạn của mã phiên và trả chủ thể, vai trò, mốc; // checkRole: kiểm vai trò được phép |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| C05-01 | SS-05 | IF-07 | Realization | «realize» | - |
| C05-02 | DC-AuthFilter | IF-07 | Dependency | - | - |
| C05-03 | DC-LoginService | IF-07 | Dependency | - | - |
| C05-04 | DC-RegisterAccountService | IF-07 | Dependency | - | - |
| C05-05 | DC-ManageStaffAccountsService | IF-07 | Dependency | - | - |

## Phụ lục. Ánh xạ sang 10 package Go khi viết mã (P09 Vấn đề còn mở 8)

Không đổi P09. Gộp theo gợi ý của P09; PKG-12 (điểm vào IPN) đi cùng nhóm payment vì chỉ gọi PKG-14; PKG-30 vào catalog theo P09; PKG-32, PKG-33 vào domain. Đồ thị phụ thuộc sau khi gộp không có vòng (đã kiểm bằng chương trình). Phần giao diện React (PKG-05 đến PKG-10, PKG-29, PKG-31) là một ứng dụng web riêng.

| Package Go | PKG gộp | Ghi chú |
|---|---|---|
| api | PKG-11 | REST controller, SSE, bộ lọc mã phiên; chỉ gọi seatbooking, ticket, catalog, account |
| seatbooking | PKG-13, PKG-24 | Giữ ghế, sơ đồ ghế, công việc hết hạn, hub sự kiện; gọi payment qua IF-01 nên phụ thuộc payment, payment không phụ thuộc ngược |
| payment | PKG-14, PKG-22, PKG-12 | IPN, hoàn tiền, subsystem cổng thanh toán; không import seatbooking |
| ticket | PKG-15 | Huỷ vé, soát vé; gọi payment |
| catalog | PKG-16, PKG-17, PKG-18, PKG-30 | Bảng giá, lịch chiếu, danh mục, báo cáo, quản lý phim và cụm rạp |
| account | PKG-19, PKG-26 | Tài khoản, đăng nhập, kiểm phiên và subsystem bảo mật |
| notify | PKG-20, PKG-23 | Hàng đợi email và subsystem email |
| store | PKG-21 | Persistence |
| jobs | PKG-25 | Subsystem hẹn giờ và IF-06 |
| domain | PKG-27, PKG-28, PKG-32, PKG-33 | Lớp miền và interface kho |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-116 | Interface đọc và dọn bảng seat_event (IF-22) do package nào định nghĩa: PKG-21 Persistence hay PKG-24 SeatEventHub? | IF-22, PKG-21, PKG-24, D-47, P09 F4, F6 | P09 F4 ("chỉ lộ ra ngoài qua interface do PKG-24 ... định nghĩa") khác P09 F6 ("PKG-21 không phụ thuộc PKG-24") | Nhóm dự án | Đã trả lời: PKG-21 định nghĩa IF-22 (PKG-24 gọi xuống PKG-21 cùng layer một chiều; nếu PKG-24 định nghĩa thì PKG-21 hiện thực nó và tạo vòng PKG-21 --> PKG-24 --> PKG-21). Sửa câu trong P09 F4 (Đề xuất sửa artifact trước) |
| Q-117 | Showtime là lớp chủ của EX-01 (holdSeats) nhưng việc ghi SeatHold, SeatStatus thuộc PKG-28; để PKG-27 không phụ thuộc PKG-28: (a) DC-Showtime chỉ kiểm tra và chốt giá, lớp dịch vụ gọi DC-SeatHold, DC-SeatStatus trong cùng giao dịch; hay (b) thêm interface ISeatHolder ở PKG-27? | DC-Showtime, DC-SeatHold, DC-SeatStatus, DC-BookTicketsService, DC-ScheduleShowtimesService, EX-01, EX-13, EX-14, P12 | P08 F4b EX-01 (lớp chủ Showtime) và P08 F3 AC-E-Showtime.holdSeats; P09 F4 ghi chú Domain chỉ nêu interface cho EX-13, EX-14 | Nhóm dự án | Đã trả lời: phương án (a), áp dụng cùng nguyên tắc cho EX-13, EX-14 (bỏ IF-09, IF-10 và hai lớp hiện thực). BR-04 và điều kiện mở bán vẫn nằm trong DC-Showtime, DC-Customer, DC-BoxOfficeClerk |
| Q-118 | Khi tài liệu VNPay sandbox không có tra cứu giao dịch hoàn hoặc chống hoàn trùng (P09 Vấn đề còn mở 6), lần gửi lại hoàn tiền sau lỗi không rõ kết quả nên tự động gửi lại hay chuyển RefundRequest sang Cần xử lý thủ công? | IF-01 (findRefund), DC-RefundService, DC-RefundOutboxJob, EX-10 | P09 F7.7 và Vấn đề còn mở 6; BR-41, BR-43 | Nhóm dự án | Đã trả lời: chuyển Cần xử lý thủ công khi không tra cứu được kết quả hoàn (gửi lại tự động có thể hoàn tiền hai lần). Khi viết mã kiểm tài liệu VNPay: nếu có khoá chống hoàn trùng hoặc tra cứu hoàn thì dùng findRefund và giữ gửi lại tự động |
| Q-271 | Tài khoản quản trị viên (ACT-06) không thuộc bốn vai trò của BR-79 nên không là Staff (P09 F7.11), nhưng DC-LoginService phải đọc nó khi quản trị viên đăng nhập qua điểm đăng nhập của nhân viên. Tài khoản này lưu ở đâu? (Bảng riêng một dòng do cài đặt tạo, đọc qua một thao tác riêng của IF-15 / Cấu hình triển khai, không có bảng) | DC-LoginService, IF-15, SS-05, P12, P13 (bảng hoặc cấu hình) | NFR-12 ("tài khoản có sẵn khi cài đặt"); P09 F7.11 ("nơi lưu do P13 chọn"); P08 không có lớp phân tích cho quản trị viên | Nhóm dự án | Bảng riêng một dòng do cài đặt tạo (mật khẩu băm cùng cách với nhân viên), đọc qua thao tác riêng của IF-15 để DC-LoginService dùng một đường đọc dữ liệu đăng nhập; chưa có thao tác đổi mật khẩu quản trị vì UC-017 không áp dụng cho tài khoản này. Nội dung artifact này không dựa vào đề xuất cho tới khi nhóm xác nhận |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P09 | F4 (đoạn "Các thực thể kỹ thuật"), F6 (PKG-24 --> PKG-21, E-44) | F4 viết interface đọc sự kiện do PKG-24 định nghĩa, nhưng nếu PKG-21 hiện thực nó thì PKG-21 phụ thuộc PKG-24, tạo vòng với E-44 (Q-116) | Ghi interface đọc, dọn seat_event do PKG-21 định nghĩa (IF-22 ISeatEventStore), PKG-24 gọi qua E-44; kiểu sự kiện đổi ghế ở PKG-28 (Đã áp dụng: P09 1.2) |
| P09 | F4, F9 (bảng package, bảng Node, bảng Edge) | Chưa có package dùng chung cho đồng bộ sơ đồ ghế phía trình duyệt; hai package khách và quầy cùng cần, không được gộp vào một package (quy tắc tác nhân) | Thêm PKG-29 SeatMapClient (layer Presentation) và hai cạnh PKG-05 --> PKG-29, PKG-06 --> PKG-29; mã PKG tiếp theo là PKG-30 (Đã áp dụng: P09 1.2) |
| P09 | F4 (ghi chú về Domain), PKG-27 | Ghi chú chỉ nêu interface kiểm ghế đang giữ hoặc vé chưa huỷ và tạo trạng thái ghế; thiếu interface giao dịch cho Application | Chỉ thêm IF-08 IUnitOfWork vào PKG-27; không cần IF-09, IF-10 vì EX-13, EX-14 do lớp dịch vụ điều phối (Q-117) (Đã áp dụng: P09 1.2) |
| P09 | F4 (PKG-13), F7.5 điểm 6 | Công việc xoá seat_event cũ hơn 10 phút chưa có package sở hữu | Ghi vào PKG-13 (DC-HoldExpiryJob kèm bước xoá seat_event, hiện thực IF-06, gọi IF-22) (Đã áp dụng: P09 1.2) |
| P08 | F4b EX-01, F3 AC-E-Showtime.holdSeats | Showtime gọi SeatHold, SeatStatus tạo phụ thuộc PKG-27 --> PKG-28, vòng với E-43 (Q-117) | Q-117 chọn (a): ghi ở EX-01 rằng bước tạo SeatHold và giữ SeatStatus do control điều phối trong cùng thao tác, Showtime giữ phần kiểm tra và chốt giá; ghi tương tự ở EX-13, EX-14 và AC-E-Showtime.saveShowtime, checkNoActiveHoldOrSoldTicket (control ScheduleShowtimes điều phối kiểm SeatHold, vé và tạo, giải phóng SeatStatus); không đổi hạng khoá (Đã áp dụng: P08 1.2) |
| P09 | F6 (PKG-20), F4 PKG-24 | PKG-20 dựng nội dung email từ DC-Showtime, DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie nhưng P09 F6 chỉ có PKG-20 --> PKG-28; IF-04 chưa nêu mô hình | Thêm cạnh PKG-20 --> PKG-27; ghi IF-04 theo mô hình kéo (subscribe trả luồng, unsubscribe), không có operation đẩy tới kết nối; Scheduler không dùng pool nền trực tiếp (pool thuộc PKG-21) (Đã áp dụng: P09 1.2) |
| P08 | F4b EX-15, AC-E-Showtime.adoptSeatMap | P08 ghi Showtime.adoptSeatMap "tự cập nhật SeatStatus của chính nó" (Q-249) nhưng PKG-27 không gọi PKG-28 (Q-117) | Ghi như EX-13: DC-ManageAuditoriumsService điều phối tạo, bỏ SeatStatus trong chuỗi khoá của EX-15; Showtime.adoptSeatMap chỉ tính phần ghế thêm, ghế bỏ; hạng khoá không đổi |
| P09 | F4 (PKG-04, PKG-27, ghi chú Domain), F6, F8, F9 | PKG-27 có 22 phần tử có hành vi nếu giữ Staff, hai lớp con, ReportPeriod, ReportGroup và interface kho của chúng (P09 F8 đặt cả hai nhóm ở PKG-27), vượt mức 15 | Thêm PKG-32 StaffAccounts (DC-Staff, DC-CinemaManager, DC-TicketChecker, IF-15) và PKG-33 ReportModel (DC-ReportPeriod, DC-ReportGroup, IF-28 IReportRepository, DC-ReportFigures) ở Domain; cạnh PKG-28 --> PKG-32, PKG-32 --> PKG-27, PKG-33 --> PKG-27, PKG-19 --> PKG-32, PKG-21 --> PKG-32, PKG-21 --> PKG-33, PKG-18 --> PKG-33; F8 ghi ba lớp nhân viên ở PKG-32, hai lớp báo cáo ở PKG-33; mã PKG tiếp theo là PKG-34 |
| P09 | F4 (ghi chú Domain), F7.11 | Ghi IF-08 thêm việc đọc dòng Staff theo mã, trong khi IF-08 chỉ mở giao dịch và lấy khoá | Đọc dòng Staff để kiểm mốc qua IF-15 trong giao dịch chỉ đọc mở bằng IF-08; IF-08 chỉ thêm LockValue; việc kiểm do DC-AccessCheckService (PKG-19) làm, DC-AuthFilter gọi |
| P11a | Màn hình của UC-001, UC-003, UC-004, UC-007, UC-010, UC-011, UC-012, UC-015, UC-016, UC-017; màn đăng nhập | P11a mới có SCR-01 đến SCR-20 cho sáu use case; P10 thêm View và Store cho mười boundary mới (PKG-05, PKG-08, PKG-09, PKG-10) và DC-LoginView, DC-SessionStore ở PKG-31 | Thêm màn hình cho DC-BrowseMoviesView, DC-BrowseShowtimesView, DC-RegisterAccountView, DC-ViewBookingHistoryView, DC-ManageAuditoriumsView, DC-ViewCinemaReportView, DC-ManageMoviesView, DC-ManageCinemasView, DC-ViewChainReportView, DC-ManageStaffAccountsView; PKG-09, PKG-10 chưa có View điều hướng (như DC-CinemaAdminHomeView); DC-LoginView phục vụ hai điểm đăng nhập (Q-267); thông báo "phiên không còn hiệu lực" do DC-SessionStore chuyển về màn đăng nhập |
| P11b | IF-07 (SS-05) | P09 F7.11: mã phiên mang loại chủ thể và mốc truy cập của nhân viên; băm mật khẩu còn dùng cho đăng ký khách (UC-001), tạo và đặt lại mật khẩu nhân viên (UC-017) | Chạy lại P11b cho SS-05: issueSession nhận loại chủ thể và mốc truy cập, verifySession trả hai giá trị đó, DC-SessionClaims thêm hai trường; SS-01 đến SS-04 không đổi |
| P12 | F1, F3, F6; lớp dịch vụ, interface và kiểu mới | Chưa có lớp thiết kế cho 55 lớp phân tích nối với 10 use case thêm và cho cơ chế khoá giá trị, kiểm phiên, báo cáo | Thêm DC-ManageMoviesService, DC-ManageCinemasService, DC-ManageAuditoriumsService, DC-RegisterAccountService, DC-ManageStaffAccountsService, DC-LoginService, DC-AccessCheckService, DC-BrowseMoviesService, DC-BrowseShowtimesService, DC-ViewBookingHistoryService, DC-ViewCinemaReportService, DC-ViewChainReportService; DC-Staff (PKG-32), DC-ReportPeriod, DC-ReportGroup (PKG-33); IF-08.LockValue và DC-ValueLockKind; DC-TxOptions pool REPORT, chỉ đọc, statement_timeout; thao tác đọc mốc và đọc theo email của IF-15; IF-28 và DC-ReportFigures; DC-LockRank 14 hạng và DC-LockOrderGuard tính khoá giá trị; DC-ActorKind, DC-ActorContext, DC-SessionClaims mở rộng; chọn cách biểu diễn ba lớp con của Staff (nhúng DC-Staff hoặc giá trị DC-Role) mà không đổi mã DC; nhóm operation của DC-Showtime, DC-Auditorium theo nhóm chức năng; F3 ghi ranh giới giao dịch của EX-15 đến EX-22 (M7) |
| P13 | Tài khoản quản trị viên (Q-271) | DC-LoginService cần nơi đọc tài khoản quản trị viên | Khi Q-271 được trả lời: thêm bảng một dòng hoặc ghi cấu hình; IF-15 đọc dữ liệu nhân viên trên bảng nhân viên chung (P09 đề xuất P13) |
| X1, X2 | M6; F3a EX-15 đến EX-22; kiểm phiên | Mỗi EX có đúng một lớp mở giao dịch; chuỗi khoá 14 hạng có khoá giá trị | X1 đối chiếu F3a với P12 F3 từng operation; X2 thêm ca thử thứ tự khoá giá trị của EX-17, EX-20, EX-21 và ca kiểm phiên (khoá, đổi vai trò, đổi cụm rạp rồi gọi thao tác kế tiếp, EX-01 sau EX-22) |

## Vấn đề còn mở

1. Đã đóng: project-profile.md mục 3 đã cập nhật theo P09 F11 (mục giữ số thứ tự để các tham chiếu tới Vấn đề còn mở 2 trở đi không lệch). Q-111 đến Q-115 giữ trạng thái đã trả lời ghi ở P09 và không chặn việc chọn công nghệ.
2. Kích thước package: PKG-27 có 15 phần tử có hành vi (đúng mức hợp lý) sau khi tách nhóm nhân viên sang PKG-32 và nhóm báo cáo sang PKG-33; PKG-28 có 18 (8 lớp miền, DC-HoldSettlement, IF-16 đến IF-21, IF-26, IF-27, DC-SeatChangeEvent), vượt mức 15 nhưng giữ vì tách interface kho khỏi lớp miền làm thêm cạnh phụ thuộc cho mọi package Application mà không giảm coupling giữa hai package miền; PKG-05 có 13, PKG-21 có 11. Presentation có 10 package (PKG-05 đến PKG-12, PKG-29, PKG-31), vượt ngưỡng 8 của mức hợp lý; P09 Vấn đề còn mở 1 đã giữ vì gộp giao diện hai tác nhân là lỗi A4 và PKG-29, PKG-31 được nhiều giao diện dùng chung. P10 xét gộp PKG-12 vào PKG-11 theo gợi ý của P09 và giữ riêng: PKG-12 không đăng nhập, xác thực bằng chữ ký cổng và đổi theo định dạng callback của cổng (lý do thay đổi riêng), là package một phần tử duy nhất. Con số 15 tính phần tử có hành vi; kiểu giá trị, enumeration và ngoại lệ thêm theo P12 và P11b (F3) không tính vào mức này.
3. Đã đóng: cả 16 use case đã có P07 nên không còn package giữ chỗ (trước đây PKG-09, PKG-10, PKG-17, PKG-18, PKG-19); chưa tạo subsystem mới cho chúng vì không có hệ thống ngoài hay thiết bị mới (F1).
4. Đã đóng: không còn lớp Tạm; Q-108 đã trả lời bằng Q-228 của UC-017 (P08 2.0): có lớp cha Staff, ánh xạ ở mục 9.
5. Đã đóng: EX-15 có lớp dịch vụ sở hữu là DC-ManageAuditoriumsService (PKG-16); chuỗi khoá ở F3a.
6. IF-08 đến IF-28 không phải interface của subsystem nên P11b không thiết kế; operation do P12 thiết kế, P12 cấp IF mới nối tiếp IF-28. IF-28 IReportRepository do P10 cấp ở bản 2.0 (truy vấn báo cáo gộp, Domain, PKG-33). Nhóm interface ghép (IF-12, IF-13, IF-16) theo đơn vị khoá; IF-20 đã được P12 1.6 tách thành IF-20 và IF-27, IF-17 và IF-18 tách thêm IF-26; IF-15 chuyển sang PKG-32.
7. Phần lớn tên và ngưỡng của SS-03, SS-04 (500 ms, 5 giây, 10 giây, 256, 8 giây) là quyết định thiết kế đã chốt ở P09 F7 (C1.7); P10 không thêm tham số mới. Việc có đạt NFR-05 đến NFR-09 vẫn cần các ca đo T1 đến T7 (P09 Vấn đề còn mở 2).
8. Các lớp hiện thực nối ở hàm khởi động chương trình (DC-Pg..., DC-ConnectionPools, bốn công việc nền) mang nhãn visibility riêng ở F5 vì hàm khởi động nằm ngoài mô hình package.
9. Quyết định về lớp con của Staff. P08 đề nghị cân nhắc bỏ ba lớp con và dùng thuộc tính vai trò. Quyết: giữ DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager làm lớp con của DC-Staff (ánh xạ 1-1 với AC), không thêm lớp con cho quản lý chuỗi (là giá trị vai trò). Lý do (ít đổi nhất): (a) ba mã DC đã cấp và đang được P11b, P12, X2 dùng, bỏ chúng là đổi mã và đổi P12; (b) P08 giữ ba lớp vì GL-35, GL-36, GL-42 là thuật ngữ riêng và các use case gọi theo vai trò; (c) DC-BoxOfficeClerk có trách nhiệm riêng (checkNoActiveSeatHold, cùng BR-04) nên không thể bỏ, hai lớp còn lại chỉ kế thừa nên không tốn thêm thiết kế. Rủi ro: một tài khoản đổi vai trò (UC-017 luồng 1a) không được đổi lớp; P12 chọn cách biểu diễn (nhúng DC-Staff hoặc giá trị DC-Role) để đổi vai trò chỉ đổi giá trị (Đề xuất sửa artifact trước, P12).
10. Quyết định về DC-Showtime và DC-Auditorium. P08 đề nghị tách Showtime (25 trách nhiệm: bán vé, tra cứu, lập lịch, sơ đồ ghế, báo cáo) và Auditorium (20: sơ đồ ghế, lập lịch). Quyết: giữ mỗi lớp một lớp thiết kế (ánh xạ 1-1). Lý do: (a) mọi trách nhiệm gắn cùng dữ liệu (thời điểm bắt đầu, phòng, phim, trạng thái) và P08 F4b đã chọn hai lớp này làm lớp chủ của EX-01, EX-13 đến EX-15; tách thì chuỗi khoá F3a và các dòng của P12 phải đổi; (b) các nhóm trách nhiệm cắt ngang cùng bất biến (BR-87, BR-54), tách thành lớp riêng buộc chia sẻ trạng thái và mất gắn kết; (c) gánh của Showtime đã giảm ở thiết kế: provideReportFigures chuyển sang IF-28, việc tạo, kiểm SeatHold, vé, SeatStatus nằm ở lớp dịch vụ (Q-117), phần việc của Auditorium ở EX-15 cũng vậy. Rủi ro: lớp lớn nhất mô hình; P12 nhóm operation theo nhóm chức năng và chia tệp nguồn, không tách kiểu (Đề xuất sửa artifact trước, P12).
11. Quyết định về nơi đặt Staff, ReportPeriod, ReportGroup. P09 F8 đặt cả ba ở PKG-27 và cho P10 xét chuyển ReportPeriod, ReportGroup vào PKG-18. Quyết: Staff cùng hai lớp con và IF-15 sang PKG-32; ReportPeriod, ReportGroup cùng IF-28 sang PKG-33; cả hai ở Domain. Lý do: giữ ở PKG-27 thì PKG-27 vượt mức 15 (22 phần tử); chuyển vào PKG-18 thì IF-28 (do PKG-21 hiện thực) phải đặt ở Application, tạo phụ thuộc đi lên, và quy tắc BR-115 đến BR-119 là quy tắc miền; hai nhóm có lý do thay đổi riêng (UC-017; UC-015, UC-016). Chi phí: hai package và các cạnh một chiều ở F6; Đề xuất sửa artifact trước (P09).
12. Đề xuất ghi P10 của P08 2.0 (Staff, ReportPeriod, ReportGroup, Showtime, Auditorium; lớp mở giao dịch EX-16 đến EX-22) và của P09 2.0 (PKG-30, PKG-31, PKG-27, mã PKG từ PKG-32; lớp mở giao dịch EX-16 đến EX-22, IF-08 thêm LockValue và đọc Staff; EX-13 lấy Movie S sau Ticket S; gói việc theo lô) đã xử lý: lớp mở giao dịch ở F3a; ReportPeriod, ReportGroup ở PKG-33 (mục 11); việc đọc Staff đặt ở IF-15 thay vì IF-08 (F3, Đề xuất sửa artifact trước); EX-13 kết thúc bằng Movie S; không có thao tác theo lô mới, hai lô EX-04, EX-05 giữ thứ tự cũ. Q-265, Q-266 (P08) và Q-267 đến Q-270 (P09) đóng theo đề xuất, nội dung chốt ghi ở nơi cấp: email chuẩn hoá không phân biệt chữ hoa thường và bỏ khoảng trắng đầu cuối, tên cụm rạp và tên phòng thêm gộp khoảng trắng; hai điểm đăng nhập riêng; múi giờ Asia/Ho_Chi_Minh; thời gian xem báo cáo 5 và 10 giây; thao tác đã qua kiểm phiên trước lúc EX-22 commit vẫn hoàn tất. Câu trả lời P08 cũ vẫn áp dụng: Q-106 (một lớp DC-RefundService dùng chung), Q-109 (tạo trạng thái ghế do DC-ScheduleShowtimesService điều phối qua IF-18), Q-110 (không đổi ánh xạ).
13. Q-271 (nơi lưu tài khoản quản trị viên) còn mở: DC-LoginService đọc tài khoản này qua IF-15 theo đề xuất nhưng nội dung chưa dựa vào đó. P09 giả định tài khoản này ngoài bảng nhân viên và không có lớp P08 nên không có phần tử miền tương ứng.
