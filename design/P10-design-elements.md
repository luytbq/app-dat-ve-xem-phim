# P10 - Phần tử thiết kế - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P10 |
| Phiên bản | 1.2 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3, vẫn ghi CONG_NGHE "Chưa chốt", xem Vấn đề còn mở 1); P01-actors.md 1.1 (Mục 1, 2); P02-usecases.md 1.8 (Mục 4); P03-usecase-model.md (bảng quan hệ, không có dòng extend); P05-glossary.md 1.1 (tra tên thuật ngữ); P06-supplementary-spec.md 1.1 (NFR về thay thế, bảo mật, giao tiếp ngoài); P08-analysis-model.md 1.1 (F3, F4, F4b, Câu hỏi mở, Giả định); P09-architecture.md 1.1 (F3 đến F8, F11, Câu hỏi mở, Vấn đề còn mở 8) |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-118 (Q-116 đến Q-118 đã trả lời theo đề xuất review, không cấp Q mới); không có ASM (NGHIEM_NGAT) |

Trọng tâm: giữ nguyên ngữ nghĩa 15 đơn vị loại trừ EX-01 đến EX-15 và thứ tự khoá 9 hạng của P08 F4b khi chuyển sang phần tử thiết kế. Ba điểm chốt: (1) lớp dịch vụ ở Application là nơi duy nhất mở giao dịch (qua IF-08) và lấy khoá theo hạng, mọi khoá đi qua interface kho dữ liệu và bị DC-LockOrderGuard kiểm thứ tự; (2) công việc dọn hết hạn, giải phóng ghế, gửi hoàn tiền, gửi email là các lớp hiện thực IF-06 do subsystem Scheduler SS-04 gọi, không có bộ đếm giờ trong bộ nhớ; (3) cập nhật sơ đồ ghế đi qua subsystem SeatEventHub SS-03 đọc bảng seat_event, còn tiếp nhận IPN của cổng thanh toán đi qua điểm vào PKG-12 và subsystem SS-01. Công nghệ theo P09 F11: Go (net/http, pgx), React SPA, PostgreSQL 15 trở lên, VNPay sandbox, SMTP. Thiết kế chi tiết operation thuộc P11b (IF-01 đến IF-07) và P12 (IF-08 đến IF-23, lớp thiết kế).

Kết quả: 90 phần tử thiết kế gồm 5 subsystem, 21 interface (IF-09, IF-10 trạng thái Loại) và 64 lớp thiết kế (kể cả kiểu giá trị; 8 lớp trạng thái Gộp hoặc Loại, xem mục "Phần tử bị gộp hoặc loại") trong 25 package (PKG-05 đến PKG-28 của P09 và PKG-29 mới); 32 lớp phân tích có đúng một dòng ánh xạ.

## F1. Subsystem ứng viên và quyết định

| Lớp phân tích (AC) | Tiêu chí thoả | Quyết định | Lý do |
|---|---|---|---|
| AC-B-PaymentGateway | Hệ thống ngoài; Có thể thay thế (đổi cổng thanh toán, NFR-15 đến NFR-17); Bảo mật (chữ ký, số tiền) | Subsystem | SS-01. Che giao thức ký URL, kiểm chữ ký thông báo, máy khách hoàn tiền, định dạng trả lời của cổng. Interface tách hai vai trò (IF-01 gọi ra, IF-02 nhận thông báo). Nếu không là subsystem thì DC-PaymentReportService và DC-RefundService phụ thuộc trực tiếp vào giao thức của VNPay |
| AC-B-EmailService | Hệ thống ngoài; Có thể thay thế (đổi nhà cung cấp SMTP, NFR-18) | Subsystem | SS-02. Dù chỉ gửi một chiều, việc gửi có thời gian chờ 30 giây, thử lại, Message-ID chống lặp (P09 F7.7, BR-89) nên không phải "một thông điệp một chiều rất đơn giản" |
| - (PKG-24 của P09) | Dịch vụ phức tạp dùng chung (đọc seat_event định kỳ, cửa sổ chồng 5 giây, phát lại từ con trỏ, hàng đợi từng kết nối); Che giấu được bên trong | Subsystem | SS-03. Phục vụ UC-005 (đã có P07, trách nhiệm updateSeatMap của hai boundary đặt vé) và UC-008 (ghế trả về trống). Interface chỉ gồm đăng ký, huỷ đăng ký, chuyển sự kiện nên Application không biết cơ chế bảng sự kiện |
| - (PKG-25 của P09) | Dịch vụ phức tạp dùng chung (chạy định kỳ, chống chạy chồng, ngân sách thời gian, pool riêng); Che giấu được bên trong | Subsystem | SS-04. Phục vụ UC-005 (hết hạn, giải phóng ghế) và UC-006, UC-008 (hoàn tiền), đều đã có P07. Thoả A1: package hạ tầng không có lớp phân tích nguồn và có use case đã có P07 |
| - (PKG-26 của P09) | Bảo mật (giới hạn truy cập); Dịch vụ dùng chung | Subsystem | SS-05. UC-005 đã có P07 và dùng checkCustomerLoggedIn, authenticateCustomer; băm mật khẩu và mã phiên (NFR-01 đến NFR-03, NFR-10) cần che sau một interface duy nhất |
| - (PKG-21 của P09) | Không | Không | A1: phần hiện thực interface kho dữ liệu không thành subsystem; ghi ở bảng phần tử thiết kế mới do cơ chế (F3). Interface kho nằm ở Domain (P09 F5) |
| AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm, AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm, AC-B-CheckTicketForm, AC-B-ManagePriceListForm, AC-B-ScheduleShowtimesForm | Không (boundary giao diện người dùng) | Không | Thành View và Store ở package theo tác nhân (F3). Camera đọc mã QR là kênh nhập của PKG-07 (P09 F5), không là subsystem |
| AC-C-BookTicketsController, AC-C-PaymentReportController, AC-C-CancelTicketController, AC-C-CheckTicketController, AC-C-ManagePriceListController, AC-C-ScheduleShowtimesController | Không | Không | Lỗi thường gặp: biến control thành subsystem vì "có nhiều bước". Control thành lớp dịch vụ ở Application, không che giấu được gì mà Application cần che |
| 17 lớp entity (AC-E-*) | Không | Không | Lớp miền ở Domain, không có tiêu chí subsystem |

Không có boundary giao diện thiết bị trong P08: máy in là chức năng in của trình duyệt (P01 Mục 1) và camera là kênh nhập của giao diện soát vé. Subsystem SS-03, SS-04, SS-05 không có lớp phân tích nguồn tương ứng một-một; chúng được xét theo A1 vì phục vụ use case đã có P07. PKG-09, PKG-10, PKG-17, PKG-18, PKG-19 của P09 chỉ phục vụ use case chưa có P07 (không có lớp hoạt động nào trong P08) nên giữ chỗ ở F4, chưa tạo subsystem (Vấn đề còn mở 3).

## F2. Bảng subsystem

| SS | Tên | Interface (IF) | Trách nhiệm | Che giấu phần tử nào | AC nguồn | ACT liên quan | PKG chứa |
|---|---|---|---|---|---|---|---|
| SS-01 | PaymentGateway | IF-01 IPaymentGateway<br>IF-02 IPaymentReportReceiver | // createPaymentTransaction: ký URL thanh toán chứa mã giao dịch và mã tham chiếu lần giữ ghế, không gọi mạng (UC-005)<br>// requestRefund: gửi hoàn tiền kèm khoá chống hoàn trùng, chờ 30 giây (UC-006, UC-008, BR-43, NFR-17)<br>// findRefund: tra cứu giao dịch hoàn trước khi gửi lại (cơ chế P09 F7.7); không tra cứu được kết quả hoàn thì bên gọi chuyển Cần xử lý thủ công, không gửi lại tự động (Q-118)<br>// reportTransactionResult: kiểm chữ ký, giải mã số tiền của thông báo, dịch thành kết quả; DC-PaymentReportService so số tiền với bản ghi (UC-005, UC-006, NFR-16) | Bộ ký URL thanh toán theo chuẩn của cổng; bộ kiểm chữ ký thông báo; máy khách REST hoàn tiền và tra cứu giao dịch hoàn có thời gian chờ 30 giây; bộ dịch mã kết quả; cấu hình môi trường sandbox | AC-B-PaymentGateway | ACT-07 | PKG-22 |
| SS-02 | EmailGateway | IF-03 IEmailSender | // sendEmail: gửi một thư đã dựng sẵn (email chứa vé của UC-005, email thông báo hoàn tiền của UC-006); nội dung thư do DC-EmailOutboxJob dựng; Message-ID lấy từ khoá chống lặp (P09 F7.7) | Máy khách SMTP; bộ dựng thư MIME; cấu hình TLS; thời gian chờ 30 giây | AC-B-EmailService | ACT-08 | PKG-23 |
| SS-03 | SeatEventHub | IF-04 ISeatEventSubscription | // subscribe: đăng ký nhận sự kiện đổi ghế của một suất chiếu từ một con trỏ, trả luồng sự kiện phát lại rồi trực tiếp; bên gọi đọc luồng (mô hình kéo, P09 F7.5, REQ-119, NFR-08, NFR-09)<br>// unsubscribe: huỷ đăng ký khi kết nối đóng | Bộ đọc seat_event mỗi 500 ms qua IF-22; tập mã đã phát 10 giây gần nhất; mốc W với cửa sổ chồng 5 giây; bộ phát lại từ con trỏ; danh sách kết nối theo suất chiếu; hàng đợi 256 sự kiện mỗi kết nối, đầy thì đóng kết nối | Cơ chế: P09 F7.5; updateSeatMap của AC-B-BookTicketsForm và AC-B-CounterBookTicketsForm thành luồng sự kiện do IF-04 trả, DC-SeatMapStreamController ghi ra kết nối, DC-SeatMapReducer áp dụng phía trình duyệt | ACT-01, ACT-02 | PKG-24 |
| SS-04 | Scheduler | IF-05 IJobScheduler | // registerJob: đăng ký công việc và chu kỳ (hàm khởi động chương trình gọi)<br>// start: bắt đầu chạy định kỳ trên mọi bản backend<br>// stop: dừng khi tắt chương trình; mỗi công việc không chạy chồng và có ngân sách 8 giây mỗi lượt (P09 F7.4) | Vòng lặp chu kỳ; cờ đang chạy của từng công việc; bộ ngắt công việc theo ngân sách 8 giây mỗi lượt (pool kết nối nền 5 kết nối thuộc DC-ConnectionPools ở PKG-21, Scheduler không dùng trực tiếp) | Cơ chế: P09 F7.4, F7.7; AC-C-BookTicketsController.startWaitingForHoldExpiry | ACT-01, ACT-02, ACT-07, ACT-08 (gián tiếp) | PKG-25 |
| SS-05 | Security | IF-07 IAuthenticator | // hashPassword, verifyPassword: băm và kiểm mật khẩu (AC-E-Customer.authenticateCustomer, NFR-01 đến NFR-03)<br>// issueSession, verifySession: cấp và kiểm mã phiên tự kiểm chứng được (AC-C-BookTicketsController.checkCustomerLoggedIn, P09 F7.8)<br>// checkRole: kiểm vai trò được phép (P09 F4) | Bộ băm mật khẩu; bộ ký và kiểm mã phiên; bảng vai trò theo tác nhân | Cơ chế: P09 F4 (PKG-26); NFR-10 | ACT-01 đến ACT-06 | PKG-26 |

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
| AC-B-PaymentGateway | Subsystem (SS) | SS-01<br>IF-01<br>IF-02 | PKG-22 | Hệ thống ngoài, có thể thay thế (F1); IF-01 cho chiều hệ thống --> cổng, IF-02 cho chiều cổng --> hệ thống (kiểm chữ ký, dịch kết quả) |
| AC-B-EmailService | Subsystem (SS) | SS-02<br>IF-03 | PKG-23 | Hệ thống ngoài, có thể thay thế (F1) |
| AC-B-CancelTicketForm | Tách thành nhiều lớp | DC-CancelTicketView<br>DC-CancelTicketStore | PKG-05 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-CounterCancelTicketForm | Tách thành nhiều lớp | DC-CounterCancelTicketView<br>DC-CounterCancelTicketStore | PKG-06 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-CheckTicketForm | Tách thành nhiều lớp | DC-CheckTicketView<br>DC-CheckTicketStore | PKG-07 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế); camera đọc mã QR dùng thư viện đọc QR có sẵn gọi từ DC-CheckTicketView, không thành lớp thiết kế (DC-QrCameraScanner trạng thái Loại) |
| AC-B-ManagePriceListForm | Tách thành nhiều lớp | DC-ManagePriceListView<br>DC-ManagePriceListStore | PKG-08 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-B-ScheduleShowtimesForm | Tách thành nhiều lớp | DC-ScheduleShowtimesView<br>DC-ScheduleShowtimesStore | PKG-08 | Bảng ánh xạ P09 F5: boundary người dùng thành component React (View) và kho trạng thái Flux (Store); phần tiếp nhận yêu cầu là REST controller ở PKG-11 (xem bảng cơ chế) |
| AC-C-BookTicketsController | Tách thành nhiều lớp | DC-BookTicketsService<br>DC-HoldExpiryJob | PKG-13 | Control thành lớp dịch vụ ứng dụng (P09 F5), đổi tên Controller thành Service vì Controller đã là REST controller ở PKG-11. Ba trách nhiệm chờ hết hạn (startWaitingForHoldExpiry, stopWaitingForHoldExpiry, handleHoldExpired) không giữ bộ đếm giờ trong control (P09 A7, F7.4): hết hạn là cột expiry_time và công việc nền DC-HoldExpiryJob quét theo lô; cùng lượt chạy, DC-HoldExpiryJob xoá seat_event cũ hơn 10 phút theo lô (P09 F7.5 điểm 6, gộp từ DC-SeatEventCleanupJob) |
| AC-C-PaymentReportController | Tách thành nhiều lớp | DC-PaymentReportService<br>DC-RefundService<br>DC-RefundOutboxJob | PKG-14 | Đổi tên Controller thành Service như trên. handlePaymentReport và logUnrecognizedTransaction (EX-02) thuộc DC-PaymentReportService. Bốn trách nhiệm hoàn tiền (startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure) lặp với AC-C-CancelTicketController nên gom vào DC-RefundService theo Q-106; việc chờ 30 giây và thử lại chạy qua hàng đợi gửi do DC-RefundOutboxJob (P09 F7.7) |
| AC-C-CancelTicketController | Tách thành nhiều lớp | DC-CancelTicketService<br>DC-RefundService | PKG-15; PKG-14 | Đổi tên Controller thành Service. Bốn trách nhiệm hoàn tiền chuyển sang DC-RefundService dùng chung (Q-106, ở dòng trên); phần còn lại (requestCancellation, findBookingTickets, confirmCashRefund) ở DC-CancelTicketService |
| AC-C-CheckTicketController | Lớp thiết kế (DC) | DC-CheckTicketService | PKG-15 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller) |
| AC-C-ManagePriceListController | Lớp thiết kế (DC) | DC-ManagePriceListService | PKG-16 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller) |
| AC-C-ScheduleShowtimesController | Lớp thiết kế (DC) | DC-ScheduleShowtimesService | PKG-16 | Một trừu tượng; đổi tên Controller thành Service (tránh trùng REST controller). Điều phối cả kiểm lần giữ ghế đang hiệu lực, kiểm vé chưa huỷ và tạo, giải phóng SeatStatus của EX-13, EX-14 (Q-117) |
| AC-E-Customer | Lớp thiết kế (DC) | DC-Customer | PKG-28 | Tạm, chờ P07 của UC-001. Lớp đơn giản, một trừu tượng. authenticateCustomer chỉ giữ dữ liệu đăng nhập; kiểm mật khẩu do IF-07 (SS-05) đảm nhận, mã phiên kiểm ở PKG-11 |
| AC-E-BoxOfficeClerk | Lớp thiết kế (DC) | DC-BoxOfficeClerk | PKG-28 | Tạm, chờ P07 của UC-017. Lớp đơn giản, một trừu tượng; đặt cùng PKG-28 với SeatHold vì cùng kiểm BR-04 (P09 F4) |
| AC-E-TicketChecker | Lớp thiết kế (DC) | DC-TicketChecker | PKG-27 | Tạm, chờ P07 của UC-017. Lớp đơn giản, một trừu tượng |
| AC-E-CinemaManager | Lớp thiết kế (DC) | DC-CinemaManager | PKG-27 | Tạm, chờ P07 của UC-017. Lớp đơn giản, một trừu tượng |
| AC-E-Cinema | Lớp thiết kế (DC) | DC-Cinema | PKG-27 | Tạm, chờ P07 của UC-011. Lớp đơn giản, một trừu tượng |
| AC-E-Auditorium | Lớp thiết kế (DC) | DC-Auditorium | PKG-27 | Tạm, chờ P07 của UC-012. Lớp đơn giản, một trừu tượng. saveShowtime chỉ kiểm khoảng cách phòng (checkRoomGap); kiểm SeatHold, vé và tạo, giải phóng SeatStatus do DC-ScheduleShowtimesService điều phối (Q-117, EX-13) nên PKG-27 không phụ thuộc PKG-28 |
| AC-E-Seat | Lớp thiết kế (DC) | DC-Seat | PKG-27 | Tạm, chờ P07 của UC-012. Lớp đơn giản, một trừu tượng |
| AC-E-Movie | Lớp thiết kế (DC) | DC-Movie | PKG-27 | Tạm, chờ P07 của UC-010. Lớp đơn giản, một trừu tượng |
| AC-E-Showtime | Lớp thiết kế (DC) | DC-Showtime | PKG-27 | Lớp đơn giản, một trừu tượng. Phần kiểm tra và chốt giá của holdSeats ở DC-Showtime; việc tạo SeatHold và đổi SeatStatus do DC-BookTicketsService gọi DC-SeatHold, DC-SeatStatus trong cùng giao dịch và cùng chuỗi khoá (Q-117). checkNoActiveHoldOrSoldTicket và tạo trạng thái ghế (Q-109) do DC-ScheduleShowtimesService điều phối qua IF-17, IF-18, IF-20, cùng nguyên tắc Q-117 |
| AC-E-PriceList | Lớp thiết kế (DC) | DC-PriceList | PKG-27 | Lớp đơn giản, một trừu tượng |
| AC-E-PriceEntry | Lớp thiết kế (DC) | DC-PriceEntry | PKG-27 | Lớp đơn giản, một trừu tượng |
| AC-E-SeatStatus | Lớp thiết kế (DC) | DC-SeatStatus | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-SeatHold | Lớp thiết kế (DC) | DC-SeatHold | PKG-28 | Lớp đơn giản, một trừu tượng. releaseHeldSeats do DC-SeatReleaseJob và các service gọi (bảng cơ chế) |
| AC-E-PaymentTransaction | Lớp thiết kế (DC) | DC-PaymentTransaction | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-RefundRequest | Lớp thiết kế (DC) | DC-RefundRequest | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-Booking | Lớp thiết kế (DC) | DC-Booking | PKG-28 | Lớp đơn giản, một trừu tượng |
| AC-E-Ticket | Lớp thiết kế (DC) | DC-Ticket | PKG-28 | Lớp đơn giản, một trừu tượng |

Tỷ lệ tách: 10 trên 32 lớp là "Tách thành nhiều lớp" (31%), 2 lớp là Subsystem, 20 lớp ánh xạ 1-1. Mọi lớp trong P08 F3 (24 lớp Hoạt động, 8 lớp Tạm) có đúng một dòng; không lớp nào có trạng thái "Gộp vào".

Phần tử thiết kế mới do cơ chế kiến trúc (không từ một dòng ở bảng trên; mọi phần tử đều truy được về P09 hoặc lớp phân tích):

| DC, SS hoặc IF | Tên | PKG | Cơ chế (Persistence, Logging, Bảo mật...) | Nguồn (P09 mục, NFR) |
|---|---|---|---|---|
| DC-SeatMapSyncClient | SeatMapSyncClient | PKG-29 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 (SSE, tải ảnh chụp, nối lại, nhịp tim 20 giây, tải lại có độ trễ ngẫu nhiên); AC-B-BookTicketsForm.updateSeatMap, AC-B-CounterBookTicketsForm.updateSeatMap, NFR-08, NFR-09 |
| DC-SeatMapReducer | SeatMapReducer | PKG-29 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 điểm 5 (chỉ áp sự kiện khi mã sự kiện lớn hơn event_seq của ghế); NFR-08 |
| DC-AuthFilter | AuthFilter | PKG-11 | Bảo mật | Cơ chế: P09 F5, F6 (kiểm tra mã phiên và vai trò); AC-C-BookTicketsController.checkCustomerLoggedIn; NFR-01 đến NFR-03 |
| DC-BookingController | BookingController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5 (REST controller); AC-B-BookTicketsForm, AC-B-CounterBookTicketsForm, AC-B-CancelTicketForm (UC-005) |
| DC-SeatMapStreamController | SeatMapStreamController | PKG-11 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 (SSE, nhịp tim 15 giây, giới hạn 10 kết nối mỗi IP, id sự kiện); NFR-08, NFR-09 |
| DC-TicketController | TicketController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-CancelTicketForm, AC-B-CounterCancelTicketForm, AC-B-CheckTicketForm (UC-008, UC-009) |
| DC-PricingScheduleController | PricingScheduleController | PKG-11 | Giao diện REST (Presentation phía máy chủ) | Cơ chế: P09 F5; AC-B-ManagePriceListForm, AC-B-ScheduleShowtimesForm (UC-013, UC-014) |
| DC-PaymentCallbackController | PaymentCallbackController | PKG-12 | Giao tiếp ngoài (cổng thanh toán) | Cơ chế: P09 F7.1, F7.6 (điểm vào IPN, không đăng nhập); AC-B-PaymentGateway.reportTransactionResult; NFR-16 |
| DC-SeatMapService | SeatMapService | PKG-13 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F7.5 điểm 4 (ảnh chụp kèm con trỏ, đăng ký nhận cập nhật); AC-E-Showtime.provideSeatMap; REQ-119. Dịch DC-SeatChangeEvent từ IF-04 thành khung SSE dạng văn bản trước khi trả cho PKG-11 |
| DC-SeatReleaseJob | SeatReleaseJob | PKG-13 | Công việc nền (hẹn giờ) | AC-E-SeatHold.releaseHeldSeats; P09 F7.4 bước 2; EX-05; NFR-07 |
| DC-IpnAnswer | IpnAnswer | PKG-14 | Giao tiếp ngoài (cổng thanh toán) | Cơ chế: P09 F7.6 (kết quả xử lý thông báo do DC-PaymentReportService trả cho PKG-12, không nêu mã HTTP; DC-PaymentCallbackController dịch kết quả sang câu trả lời của cổng, cùng chỗ với phần dịch mã trả lời; gộp từ DC-ReportReply) |
| DC-EmailOutboxJob | EmailOutboxJob | PKG-20 | Giao tiếp ngoài (email, hàng đợi gửi) | Cơ chế: P09 F7.7 (hàng đợi email, thử lại 1, 5, 15 phút); AC-B-EmailService; BR-89, BR-41; dựng cả nội dung email vé và email hoàn tiền (gộp từ DC-EmailComposer; REQ-105, REQ-116) |
| DC-PgUnitOfWork | PgUnitOfWork | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Cơ chế: P09 F7.2, F7.3 (READ COMMITTED, lock_timeout 1 giây, giao dịch ghi ghế tối đa 4 giây, thử lại 2 lần với 40P01 và 55P03, thời điểm CSDL một lần mỗi giao dịch; 55P03 do NOWAIT của ghế ở EX-01 không thử lại) |
| DC-LockOrderGuard | LockOrderGuard | PKG-21 | Đồng thời (giao dịch, khoá theo hạng) | Cơ chế: P08 F4b (thứ tự khoá 9 hạng), P09 F7.3; quy tắc kiểm ở F3a |
| DC-ConnectionPools | ConnectionPools | PKG-21 | Persistence | Cơ chế: P09 F7.3, F7.4 (pool 20 cho yêu cầu người dùng, pool 5 cho công việc nền) |
| DC-PgCinemaOperationsStore | PgCinemaOperationsStore | PKG-21 | Persistence | Cơ chế: P09 F5 (entity phần lưu trữ), F7.3 |
| DC-PgTicketingStore | PgTicketingStore | PKG-21 | Persistence | Cơ chế: P09 F5 (entity phần lưu trữ), F7.3, F7.6 |
| DC-PgSeatEventStore | PgSeatEventStore | PKG-21 | Persistence | Cơ chế: P09 F7.5 (bảng seat_event, đọc theo con trỏ, ảnh chụp một câu SQL) |
| DC-PgOutboxStore | PgOutboxStore | PKG-21 | Persistence (hàng đợi gửi) | Cơ chế: P09 F7.7 (hàng đợi gửi, claim SKIP LOCKED, claim_token) |
| DC-SeatEventWriter | SeatEventWriter | PKG-21 | Persistence | Cơ chế: P09 F7.5 điểm 1 (INSERT seat_event trong giao dịch đổi ghế, ghi event_seq); chỉ các Pg Store gọi, bên trong cùng thao tác cập nhật SeatStatus |
| IF-22 | ISeatEventStore | PKG-21 | Persistence | Cơ chế: P09 F7.5 (đọc sự kiện sau con trỏ, ảnh chụp, xoá cũ); Đề xuất sửa P09 1, Q-116 |
| IF-23 | IOutboxStore | PKG-21 | Persistence (hàng đợi gửi) | Cơ chế: P09 F7.7 (xếp hàng cùng giao dịch, claim, ghi kết quả có điều kiện claim_token) |
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
| IF-08 | IUnitOfWork | PKG-27 | Đồng thời (giao dịch, khoá theo hạng) | Cơ chế: P09 F5 (Application lấy hạng khoá), F7.3 (giao dịch) |
| IF-11 | IShowtimeRepository | PKG-27 | Persistence | Cơ chế: P09 F5 (entity phần lưu trữ): DC-Showtime |
| IF-12 | IPriceListRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-PriceList, DC-PriceEntry |
| IF-13 | ICinemaRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-Cinema, DC-Auditorium, DC-Seat |
| IF-14 | IMovieRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-Movie |
| IF-15 | IStaffRepository | PKG-27 | Persistence | Cơ chế: P09 F5: DC-CinemaManager, DC-TicketChecker |
| IF-16 | IHolderRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-Customer, DC-BoxOfficeClerk (hạng khoá 4) |
| IF-17 | ISeatHoldRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-SeatHold (hạng khoá 5) |
| IF-18 | ISeatStatusRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-SeatStatus (hạng khoá 6) |
| IF-19 | IPaymentTransactionRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-PaymentTransaction (hạng khoá 7) |
| IF-20 | IBookingRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-Booking, DC-Ticket (hạng khoá 8) |
| IF-21 | IRefundRequestRepository | PKG-28 | Persistence | Cơ chế: P09 F5: DC-RefundRequest (hạng khoá 9) |
| DC-SeatChangeEvent | SeatChangeEvent | PKG-28 | Cập nhật sơ đồ ghế thời gian thực (SSE) | Cơ chế: P09 F4 (kiểu sự kiện đổi ghế do IF-04 trả cho DC-SeatMapService, không ra khỏi Application; PKG-11 chỉ nhận khung SSE dạng văn bản); P09 F7.5 |

### Phần tử bị gộp hoặc loại

Mã giữ nguyên theo quy ước, không cấp lại. Không phần tử nào trong số này phục vụ chuỗi khoá, DC-LockOrderGuard hay cập nhật sơ đồ ghế.

| Mã | Trạng thái | Gộp vào hoặc thay bằng | Lý do |
|---|---|---|---|
| DC-EmailComposer | Gộp | DC-EmailOutboxJob | Chỉ dựng nội dung cho đúng một bên gọi |
| DC-SeatEventCleanupJob | Gộp | DC-HoldExpiryJob | Cùng chu kỳ 10 giây, cùng bảng seat_event; dọn là bước cuối của lượt chạy |
| DC-PaymentLinkRequest | Loại | Tham số thường của IF-01 createPaymentTransaction | Kiểu giá trị chỉ có ba trường |
| DC-RefundCommand | Loại | Tham số thường của IF-01 requestRefund | Kiểu giá trị chỉ có ba trường |
| DC-ReportReply | Gộp | DC-IpnAnswer (PKG-14) | IF-02 không dựng câu trả lời cho cổng; kết quả xử lý thông báo đi qua DC-IpnAnswer để PKG-12 không phải phụ thuộc PKG-22 |
| DC-QrCameraScanner | Loại | Thư viện đọc QR có sẵn, gọi từ DC-CheckTicketView | Không có hành vi riêng cần thiết kế |
| IF-09 ISeatOccupancyGuard | Loại | DC-ScheduleShowtimesService gọi IF-17, IF-20 | Q-117 áp cho EX-13, EX-14: dịch vụ điều phối, thứ tự khoá hiện trong một lớp |
| IF-10 ISeatStatusInitializer | Loại | DC-ScheduleShowtimesService gọi IF-18 | Như trên |
| DC-SeatOccupancyChecker | Loại | Như IF-09 | Không còn interface để hiện thực |
| DC-SeatStatusInitializer | Loại | Như IF-10 | Không còn interface để hiện thực |

### F3a. Truy vết EX-01 đến EX-15 sang phần tử thiết kế

Mỗi dòng nêu lớp dịch vụ mở giao dịch (qua IF-08) và chuỗi khoá theo hạng của P08 F4b; mọi khoá đi qua interface kho dữ liệu nên DC-LockOrderGuard kiểm được thứ tự. S là SELECT FOR SHARE, X là FOR NO KEY UPDATE (P09 F7.3). Tên operation do P12 đặt.

| EX | Lớp mở giao dịch (IF-08) | Chuỗi khoá (hạng, interface, chế độ) | Phần tử thực hiện phần kiểm và ghi | Ngữ nghĩa giữ nguyên |
|---|---|---|---|---|
| EX-01 | DC-BookTicketsService | 1 IF-12 PriceList S --> 2 IF-13 Auditorium S --> 3 IF-11 Showtime S (S theo P09 Vấn đề còn mở 3; P08 F4b ghi X) --> 4 IF-16 người giữ ghế X --> 5 IF-17 SeatHold cũ X (nếu có) --> 6 IF-18 SeatStatus X NOWAIT, ORDER BY (mã suất chiếu, mã ghế), không lọc trạng thái | DC-Showtime (mở bán, suất chiếu chưa đổi, giới hạn ghế, chốt giá qua DC-PriceList); DC-Customer hoặc DC-BoxOfficeClerk (BR-04); DC-SeatHold (tạo, expiry_time = thời điểm CSDL + 10 phút, mã yêu cầu); DC-SeatStatus (giữ ghế, current_hold_id, event_seq) | Tất cả hoặc không ghế nào; ghế đang bị khoá thì từ chối ngay (55P03 do NOWAIT, DC-PgUnitOfWork không thử lại); mã yêu cầu làm xác nhận lặp an toàn; không NOTIFY |
| EX-02 | DC-PaymentReportService | Tra không khoá mã SeatHold --> 5 IF-17 SeatHold X --> 6 IF-18 SeatStatus của lần giữ ghế X --> 7 IF-19 PaymentTransaction X; tạo mới Booking, Ticket (IF-20), RefundRequest (IF-21), dòng hàng đợi (IF-23) | DC-SeatHold, DC-PaymentTransaction, DC-Booking, DC-Ticket, DC-RefundService ở chế độ (a): lập yêu cầu hoàn của thanh toán trễ trong giao dịch đang mở của DC-PaymentReportService, không mở giao dịch mới | Báo trùng, báo muộn, báo song song tuần tự hoá theo khoá SeatHold; thời điểm CSDL lấy một lần sau khoá; câu trả lời cho cổng do IF-02 dựng |
| EX-03 | DC-BookTicketsService | 5 IF-17 SeatHold X --> 6 IF-18 SeatStatus X; tạo Booking, Ticket (IF-20); dòng hàng đợi email vé (IF-23) | DC-SeatHold, DC-SeatStatus, DC-Booking, DC-Ticket | Xác nhận thu tiền mặt đến sau hết hạn bị từ chối (BR-44) |
| EX-04 | DC-BookTicketsService (huỷ giữ ghế); DC-HoldExpiryJob (quét theo lô); DC-PaymentReportService (báo thất bại, trong giao dịch EX-02) | 5 IF-17 SeatHold X; quét: SKIP LOCKED, lô 200 | DC-SeatHold (một trạng thái cuối; quá expiry_time thì chuyển Hết hạn trước) | Hết hạn là sự thật tính theo thời điểm CSDL, công việc nền chỉ quyết định khi nào ghế trống (P09 F7.4) |
| EX-05 | DC-SeatReleaseJob (quét theo lô); DC-BookTicketsService (huỷ giữ ghế, giao dịch riêng sau EX-04) | 5 IF-17 SeatHold S (quét: X SKIP LOCKED, khoá cả lô, mã tăng dần) --> 6 IF-18 SeatStatus X của cả lô ORDER BY (mã suất chiếu, mã ghế), rồi UPDATE theo khoá chính đã khoá | DC-SeatHold, DC-SeatStatus (điều kiện current_hold_id) | Chạy lặp an toàn, không trả nhầm ghế đã giữ lại hoặc đã bán (R-63, X-18). Giao dịch thanh toán thất bại (EX-04 trong EX-02) do DC-SeatReleaseJob giải phóng ghế ở lượt quét kế tiếp, DC-PaymentReportService không gọi giải phóng nên không có cạnh PKG-14 --> PKG-13; NFR-07 chỉ đòi chậm nhất 1 phút sau hết hạn |
| EX-06 | DC-CancelTicketService (giao dịch riêng) | 6 IF-18 SeatStatus X --> 8 IF-20 Ticket S | DC-SeatStatus (điều kiện current_ticket_id) | Không lồng EX-07, EX-09 (quy tắc 4); chạy được trên suất chiếu Đã xoá |
| EX-07 | DC-CancelTicketService | 8 IF-20 Ticket X | DC-Ticket | Một lần huỷ (X-14, X-15) |
| EX-08 | DC-CheckTicketService | 8 IF-20 Ticket X | DC-Ticket, DC-Showtime (thứ tự kiểm BR-33) | Một lần soát thành công |
| EX-09 | DC-RefundService: chế độ (b) mở giao dịch riêng khi do DC-CancelTicketService gọi (UC-008); chế độ (a) dùng giao dịch đang mở của DC-PaymentReportService khi gọi từ EX-02 (UC-006) | 7 IF-19 PaymentTransaction X; tạo RefundRequest (IF-21); dòng hàng đợi hoàn tiền (IF-23) | DC-PaymentTransaction (cộng refunded_total trong câu UPDATE), DC-RefundRequest | Tổng đã hoàn không mất cập nhật, không vượt số đã thanh toán (X-16) |
| EX-10 | DC-RefundService (ba giao dịch ngắn), do DC-RefundOutboxJob gọi | 8 IF-20 Ticket S (chỉ hoàn tiền mặt) --> 9 IF-21 RefundRequest X; sau đó dòng hàng đợi IF-23 (không thuộc 9 hạng): ghi kết quả có điều kiện claim_token | DC-RefundRequest; IF-01 gọi cổng ngoài giao dịch, chờ 30 giây, cùng khoá chống hoàn trùng | Không giữ khoá khi chờ cổng; hết lần thử, hoặc không tra cứu được kết quả hoàn qua findRefund (Q-118), thì Cần xử lý thủ công; email hoàn chỉ xếp hàng sau hoàn thành công |
| EX-11 | DC-ManagePriceListService | 1 IF-12 PriceList X | DC-PriceList, DC-PriceEntry | Bên sau thấy mốc đã đổi và bị từ chối (X-05) |
| EX-12 | DC-ManagePriceListService | 1 IF-12 PriceList X --> 2 IF-13 Auditorium S tăng dần --> 3 IF-11 Showtime S | DC-PriceList (qua IF-11 kiểm suất chiếu đang dùng mục giá) | PriceList X chặn mọi EX-01, EX-13 trong lúc kiểm |
| EX-13 | DC-ScheduleShowtimesService | 1 IF-12 PriceList S --> 2 IF-13 Auditorium X (tăng dần) --> 3 IF-11 Showtime X --> 5 IF-17 SeatHold S (kiểm lần giữ ghế đang hiệu lực) --> 6 IF-18 SeatStatus X (tạo trạng thái ghế, hoặc giải phóng ghế còn dở khi sửa sang phòng khác, BR-53) --> 8 IF-20 Ticket S (kiểm vé chưa huỷ) | DC-Auditorium (saveShowtime, checkRoomGap), DC-Showtime, DC-SeatStatus (tạo, giải phóng ghế); DC-ScheduleShowtimesService điều phối ba lời gọi IF-17, IF-18, IF-20 đúng thứ tự trên (Q-117, Q-109) | Showtime X loại trừ mọi EX-01 cùng suất chiếu (X-03); EXCLUDE và unique từng phần là lưới an toàn ở CSDL |
| EX-14 | DC-ScheduleShowtimesService | 3 IF-11 Showtime X --> 5 IF-17 SeatHold S --> 8 IF-20 Ticket S | DC-Showtime; DC-ScheduleShowtimesService điều phối kiểm qua IF-17, IF-20 | Đánh dấu Đã xoá, giữ dữ liệu để EX-05, EX-06 vẫn chạy |
| EX-15 | Chưa có lớp dịch vụ (UC-012 chưa có P07): giữ chỗ ở PKG-16 | 1 IF-12 PriceList S --> 2 IF-13 Auditorium X --> 3 IF-11 Showtime S --> 6 IF-18 SeatStatus X | DC-Auditorium, DC-Seat (khung chờ) | Giữ nguyên chuỗi khoá khi UC-012 có P07 (Vấn đề còn mở 5) |

Quy tắc áp dụng cho P12:

- Lớp dịch vụ ở Application mở giao dịch bằng IF-08, lấy một lần thời điểm hiện tại của CSDL sau khi có khoá, và không lấy khoá ở nơi nào khác. Hạng khoá do lớp dịch vụ gọi theo bảng trên; interface kho chỉ thực hiện SQL khoá một hạng. Lớp dịch vụ là nơi duy nhất thấy cả chuỗi: không phần tử miền nào tự gọi kho để khoá (Q-117).
- DC-LockOrderGuard nhớ hạng lớn nhất và mã dòng đã lấy trong giao dịch, kiểm theo bốn điểm:
  - Hạng gắn cố định với từng phương thức khoá của interface kho (mỗi phương thức khai báo đúng một hạng, kể cả interface ghép như IF-13, IF-16, IF-20), lớp dịch vụ không truyền hạng.
  - Từ chối lời gọi có hạng nhỏ hơn hạng lớn nhất đã lấy, hoặc cùng hạng mà mã nhỏ hơn mã đã lấy (SeatStatus theo mã suất chiếu rồi mã ghế). Khoá lại cùng dòng hoặc nâng S lên X (cùng hạng, cùng mã) được phép, không tính là đi lùi.
  - Vi phạm trả error kiểu lỗi lập trình và đánh dấu giao dịch phải rollback, không ném panic và không thử lại. Ca đo T4 của P09 F7.9 khẳng định không có 40P01.
  - Chỉ tính các lời gọi khoá dòng (kể cả NOWAIT, SKIP LOCKED); thiết kế không dùng khoá tư vấn. P12 chi tiết hoá.
- Mọi giao dịch đổi trạng thái ghế ghi seat_event trong cùng giao dịch, sau khi đã khoá ghế; không gọi NOTIFY. Việc ghi do các Pg Store gọi DC-SeatEventWriter bên trong cùng thao tác cập nhật SeatStatus, lớp dịch vụ không gọi trực tiếp.
- Lời gọi ra ngoài (IF-01, IF-03) nằm ngoài giao dịch và không giữ khoá; dòng hàng đợi (IF-23) được claim bằng giao dịch riêng, commit ngay.
- EX-06, EX-07, EX-09, EX-10 là bốn giao dịch độc lập của UC-008, DC-CancelTicketService không lồng chúng (P08 F4b quy tắc 4); EX-05 sau EX-04 là giao dịch riêng. DC-RefundService có hai chế độ: (a) UC-006 trong EX-02, nhận giao dịch đang mở của DC-PaymentReportService và không mở giao dịch mới; (b) UC-008, DC-CancelTicketService gọi và DC-RefundService mở giao dịch riêng (EX-09).
- Quét theo lô (EX-04, EX-05): một giao dịch mỗi lô (P09 F7.4). Khoá toàn bộ SeatHold của lô trước (SKIP LOCKED, mã tăng dần), rồi toàn bộ SeatStatus của lô theo (mã suất chiếu, mã ghế) tăng dần; không xử lý từng lần giữ ghế xen kẽ hạng 5 và hạng 6.
- Thứ tự gọi bắt buộc trong EX-13: kiểm SeatHold (IF-17, hạng 5) --> tạo hoặc giải phóng SeatStatus (IF-18, hạng 6) --> kiểm Ticket (IF-20, hạng 8). Kiểm từ chối thì rollback cả giao dịch.

## F4. Bảng package

Bảng tiếp nối P09 F4 (PKG-05 đến PKG-28) và thêm PKG-29. Layer PKG-01 đến PKG-04 giữ nguyên. Mã PKG tiếp theo cho bước sau: PKG-30.

| PKG | Tên | Layer (PKG) | Trách nhiệm | Phần tử chứa (DC, SS, IF) | Tiêu chí nhóm | Phụ thuộc vào (PKG) |
|---|---|---|---|---|---|---|
| PKG-05 | CustomerWeb | PKG-01 | Giao diện React của khách: đặt vé, huỷ vé (kho trạng thái và component) | DC-BookTicketsView<br>DC-BookTicketsStore<br>DC-CancelTicketView<br>DC-CancelTicketStore | Cùng tác nhân ACT-01; View trình bày SeatStatus, SeatHold, Ticket của khách; hai form dùng chung boundary (R-19) | PKG-29 |
| PKG-06 | CounterWeb | PKG-01 | Giao diện React của nhân viên quầy: bán vé, huỷ vé tại quầy | DC-CounterBookTicketsView<br>DC-CounterBookTicketsStore<br>DC-CounterCancelTicketView<br>DC-CounterCancelTicketStore | Cùng tác nhân ACT-02; tách khỏi PKG-05 theo quy tắc tác nhân (A3) | PKG-29 |
| PKG-07 | CheckInWeb | PKG-01 | Giao diện React soát vé, đọc mã QR bằng camera | DC-CheckTicketView<br>DC-CheckTicketStore | Cùng tác nhân ACT-03; camera là kênh nhập của giao diện này, đọc mã QR bằng thư viện có sẵn (P09 F5) | - |
| PKG-08 | CinemaAdminWeb | PKG-01 | Giao diện React của quản lý cụm rạp: bảng giá, lịch suất chiếu | DC-ManagePriceListView<br>DC-ManagePriceListStore<br>DC-ScheduleShowtimesView<br>DC-ScheduleShowtimesStore | Cùng tác nhân ACT-04; hai form cùng chỉnh dữ liệu cấu hình của cụm rạp (PriceList, Showtime) | - |
| PKG-09 | ChainAdminWeb | PKG-01 | Giữ chỗ cho giao diện quản lý chuỗi (UC-010, UC-011, UC-016 chưa có lớp P08) | (giữ chỗ, chưa có phần tử) | Cùng tác nhân ACT-05; giữ chỗ theo F1 | - |
| PKG-10 | AccountAdminWeb | PKG-01 | Giữ chỗ cho giao diện quản trị viên (UC-017 chưa có lớp P08) | (giữ chỗ, chưa có phần tử) | Cùng tác nhân ACT-06; giữ chỗ theo F1 | - |
| PKG-11 | HttpApi | PKG-01 | REST controller, kết nối đẩy sơ đồ ghế, bộ lọc kiểm tra mã phiên và vai trò | DC-AuthFilter<br>DC-BookingController<br>DC-SeatMapStreamController<br>DC-TicketController<br>DC-PricingScheduleController | Phần tiếp nhận yêu cầu theo nhóm chức năng (P09 F5); chung một lý do thay đổi là hợp đồng REST với trình duyệt | PKG-13, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-26 |
| PKG-12 | PaymentCallbackApi | PKG-01 | Điểm vào IPN của cổng thanh toán | DC-PaymentCallbackController | Tách khỏi PKG-11 vì không đăng nhập, xác thực bằng chữ ký cổng và đổi theo định dạng callback của cổng (lý do thay đổi riêng) | PKG-14 |
| PKG-29 | SeatMapClient | PKG-01 | Đồng bộ sơ đồ ghế phía trình duyệt: kết nối SSE, tải lại ảnh chụp, áp sự kiện theo từng ghế | DC-SeatMapSyncClient<br>DC-SeatMapReducer | Dùng chung bởi PKG-05 và PKG-06 (hai tác nhân) nên không đặt vào một trong hai (A3); cùng một quy tắc áp sự kiện (CCP) | - |
| PKG-13 | SeatBooking | PKG-02 | Giữ ghế, huỷ giữ ghế, xác nhận thu tiền mặt, bắt đầu thanh toán, giải phóng ghế, sơ đồ ghế, công việc hết hạn (kèm dọn seat_event) | DC-BookTicketsService<br>DC-SeatMapService<br>DC-HoldExpiryJob<br>DC-SeatReleaseJob | Cùng UC-005 và cùng chuỗi trạng thái SeatHold/SeatStatus; thay đổi cơ chế hết hạn kéo theo cả giữ ghế và giải phóng | PKG-21, PKG-22, PKG-24, PKG-25, PKG-27, PKG-28 |
| PKG-14 | PaymentRefund | PKG-02 | Xử lý IPN (kể cả thanh toán trễ) và vòng đời hoàn tiền | DC-PaymentReportService<br>DC-IpnAnswer<br>DC-RefundService<br>DC-RefundOutboxJob | Cùng giao dịch PaymentTransaction và RefundRequest (UC-005, UC-006, UC-008); hoàn tiền dùng chung (Q-106) | PKG-21, PKG-22, PKG-25, PKG-27, PKG-28 |
| PKG-15 | TicketService | PKG-02 | Huỷ vé, soát vé | DC-CancelTicketService<br>DC-CheckTicketService | Cùng thực thể Ticket (UC-008, UC-009); cùng khoá hạng 8 | PKG-14, PKG-21, PKG-27, PKG-28 |
| PKG-16 | ScheduleAndPricing | PKG-02 | Quản lý bảng giá và lịch suất chiếu | DC-ManagePriceListService<br>DC-ScheduleShowtimesService | Cùng tác nhân ACT-04; cùng khoá PriceList, Auditorium, Showtime (EX-11 đến EX-15) | PKG-21, PKG-27, PKG-28 |
| PKG-17 | Catalog | PKG-02 | Giữ chỗ cho tra cứu và quản lý phim, cụm rạp, lịch chiếu | (giữ chỗ, chưa có phần tử) | Giữ chỗ theo F1 (UC-003, UC-004, UC-010, UC-011 chưa có lớp P08) | PKG-21, PKG-27 |
| PKG-18 | Reporting | PKG-02 | Giữ chỗ cho báo cáo doanh thu và tỉ lệ lấp đầy | (giữ chỗ, chưa có phần tử) | Giữ chỗ theo F1 (UC-015, UC-016 chưa có lớp P08) | PKG-21, PKG-27, PKG-28 |
| PKG-19 | AccountManagement | PKG-02 | Giữ chỗ cho đăng ký khách và quản lý tài khoản nhân viên | (giữ chỗ, chưa có phần tử) | Giữ chỗ theo F1 (UC-001, UC-017 chưa có lớp P08) | PKG-21, PKG-26, PKG-27, PKG-28 |
| PKG-20 | Notification | PKG-02 | Lấy dòng hàng đợi email, dựng nội dung email vé và email hoàn tiền, gửi qua IF-03 | DC-EmailOutboxJob | Cùng một việc: hàng đợi email (BR-89, NFR-18) | PKG-21, PKG-23, PKG-25, PKG-27, PKG-28 |
| PKG-21 | Persistence | PKG-03 | Giao dịch, khoá dòng theo hạng, SQL, seat_event, hàng đợi gửi | DC-PgUnitOfWork<br>DC-LockOrderGuard<br>DC-ConnectionPools<br>DC-PgCinemaOperationsStore<br>DC-PgTicketingStore<br>DC-PgSeatEventStore<br>DC-PgOutboxStore<br>DC-SeatEventWriter<br>IF-22<br>IF-23 | Một công nghệ PostgreSQL; cùng lý do thay đổi là lược đồ và SQL; chỉ liệt kê phần tử, chi tiết P12 | PKG-27, PKG-28 |
| PKG-22 | PaymentGatewayClient | PKG-03 | Subsystem cổng thanh toán SS-01 | SS-01<br>IF-01<br>IF-02<br>DC-PaymentReport<br>DC-RefundOutcome | Một subsystem, thay cổng chỉ đổi gói này (NFR-15 đến NFR-17) | - |
| PKG-23 | EmailGatewayClient | PKG-03 | Subsystem dịch vụ email SS-02 | SS-02<br>IF-03<br>DC-EmailMessage | Một subsystem (NFR-18) | - |
| PKG-24 | SeatEventHub | PKG-03 | Subsystem phát sự kiện đổi ghế SS-03 | SS-03<br>IF-04 | Một subsystem (NFR-08, NFR-09) | PKG-21, PKG-28 |
| PKG-25 | Scheduler | PKG-03 | Subsystem hẹn giờ SS-04 và interface công việc IF-06 | SS-04<br>IF-05<br>IF-06 | Một subsystem (NFR-07) | - |
| PKG-26 | Security | PKG-03 | Subsystem bảo mật SS-05 | SS-05<br>IF-07 | Một subsystem (NFR-01 đến NFR-03, NFR-10) | - |
| PKG-27 | CinemaOperations | PKG-04 | Lớp miền cụm rạp, phòng chiếu, suất chiếu, bảng giá; interface kho; interface giao dịch | DC-Cinema<br>DC-Auditorium<br>DC-Seat<br>DC-Movie<br>DC-Showtime<br>DC-PriceList<br>DC-PriceEntry<br>DC-CinemaManager<br>DC-TicketChecker<br>IF-08<br>IF-11<br>IF-12<br>IF-13<br>IF-14<br>IF-15 | Quan hệ giữa các lớp (R-38 đến R-43, R-60 đến R-62) và cùng khoá PriceList, Auditorium, Showtime | - |
| PKG-28 | Ticketing | PKG-04 | Lớp miền giữ ghế, thanh toán, hoàn tiền, đặt vé, vé; interface kho; kiểu sự kiện đổi ghế | DC-Customer<br>DC-BoxOfficeClerk<br>DC-SeatStatus<br>DC-SeatHold<br>DC-PaymentTransaction<br>DC-RefundRequest<br>DC-Booking<br>DC-Ticket<br>IF-16<br>IF-17<br>IF-18<br>IF-19<br>IF-20<br>IF-21<br>DC-SeatChangeEvent | Quan hệ giữa các lớp (R-46 đến R-56, R-63, R-64) và cùng khoá hạng 4 đến 9 | PKG-27 |

Chia nhỏ bên trong PKG-27 và PKG-28 (P09 F4 yêu cầu P10 chia nhỏ): mỗi package gồm các nhóm trong cùng package, không thành package riêng vì P09 F4, F5 đã đặt interface kho ở Domain cùng package với lớp miền, và tách ra sẽ thêm cạnh phụ thuộc tới package mới cho mọi package Application. PKG-27: nhóm thực thể (9 lớp DC), nhóm interface kho (IF-11 đến IF-15), cơ chế giao dịch (IF-08); 15 phần tử. PKG-28: nhóm thực thể (8 lớp DC), nhóm interface kho (IF-16 đến IF-21), kiểu sự kiện (DC-SeatChangeEvent); 15 phần tử, đúng mức 15 (Vấn đề còn mở 2).


## F5. Visibility

Ba nhãn đặc biệt: "chỉ vỏ ứng dụng React", "chỉ hàm khởi động chương trình đăng ký đường dẫn" và "chỉ hàm khởi động chương trình" chỉ nơi dùng nằm ngoài mô hình package (vỏ SPA, hàm khởi động chương trình Go dựng các lớp và nối IF-05, IF-08, IF-22, IF-23); các phần tử đó vẫn không bị package khác trong mô hình tham chiếu.

| PKG | Phần tử | Visibility (public / package-private) | Được dùng bởi (PKG) |
|---|---|---|---|
| PKG-05 | DC-BookTicketsView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-BookTicketsStore | package-private | - |
| PKG-05 | DC-CancelTicketView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-05 | DC-CancelTicketStore | package-private | - |
| PKG-06 | DC-CounterBookTicketsView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-06 | DC-CounterBookTicketsStore | package-private | - |
| PKG-06 | DC-CounterCancelTicketView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-06 | DC-CounterCancelTicketStore | package-private | - |
| PKG-07 | DC-CheckTicketView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-07 | DC-CheckTicketStore | package-private | - |
| PKG-08 | DC-ManagePriceListView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ManagePriceListStore | package-private | - |
| PKG-08 | DC-ScheduleShowtimesView | public (chỉ vỏ ứng dụng React, ngoài mô hình package) | - |
| PKG-08 | DC-ScheduleShowtimesStore | package-private | - |
| PKG-11 | DC-AuthFilter | package-private | - |
| PKG-11 | DC-BookingController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-SeatMapStreamController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-TicketController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-11 | DC-PricingScheduleController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-12 | DC-PaymentCallbackController | public (chỉ hàm khởi động chương trình đăng ký đường dẫn) | - |
| PKG-29 | DC-SeatMapSyncClient | public | PKG-05, PKG-06 |
| PKG-29 | DC-SeatMapReducer | public | PKG-05, PKG-06 |
| PKG-13 | DC-BookTicketsService | public | PKG-11 |
| PKG-13 | DC-SeatMapService | public | PKG-11 |
| PKG-13 | DC-HoldExpiryJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-13 | DC-SeatReleaseJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-14 | DC-PaymentReportService | public | PKG-12 |
| PKG-14 | DC-IpnAnswer | public | PKG-12 |
| PKG-14 | DC-RefundService | public | PKG-15 |
| PKG-14 | DC-RefundOutboxJob | public (chỉ hàm khởi động chương trình) | - |
| PKG-15 | DC-CancelTicketService | public | PKG-11 |
| PKG-15 | DC-CheckTicketService | public | PKG-11 |
| PKG-16 | DC-ManagePriceListService | public | PKG-11 |
| PKG-16 | DC-ScheduleShowtimesService | public | PKG-11 |
| PKG-20 | DC-EmailOutboxJob | public (chỉ hàm khởi động chương trình) | - |
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
| PKG-22 | SS-01 | package-private (chỉ interface của subsystem là public) | - |
| PKG-22 | IF-01 | public | PKG-13, PKG-14 |
| PKG-22 | IF-02 | public | PKG-14 |
| PKG-22 | DC-PaymentReport | public | PKG-14 |
| PKG-22 | DC-RefundOutcome | public | PKG-14 |
| PKG-23 | SS-02 | package-private (chỉ interface của subsystem là public) | - |
| PKG-23 | IF-03 | public | PKG-20 |
| PKG-23 | DC-EmailMessage | public | PKG-20 |
| PKG-24 | SS-03 | package-private (chỉ interface của subsystem là public) | - |
| PKG-24 | IF-04 | public | PKG-13 |
| PKG-25 | SS-04 | package-private (chỉ interface của subsystem là public) | - |
| PKG-25 | IF-05 | public (chỉ hàm khởi động chương trình) | - |
| PKG-25 | IF-06 | public | PKG-13, PKG-14, PKG-20 |
| PKG-26 | SS-05 | package-private (chỉ interface của subsystem là public) | - |
| PKG-26 | IF-07 | public | PKG-11, PKG-19 |
| PKG-27 | DC-Cinema | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-Auditorium | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-Seat | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-Movie | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-Showtime | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-PriceList | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-PriceEntry | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-CinemaManager | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | DC-TicketChecker | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-08 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-19, PKG-21 |
| PKG-27 | IF-11 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-12 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-13 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-14 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-27 | IF-15 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-20, PKG-21, PKG-28 |
| PKG-28 | DC-Customer | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-BoxOfficeClerk | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-SeatStatus | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-SeatHold | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-PaymentTransaction | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-RefundRequest | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-Booking | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-Ticket | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-16 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-17 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-18 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-19 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-20 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | IF-21 | public | PKG-13, PKG-14, PKG-15, PKG-16, PKG-18, PKG-19, PKG-20, PKG-21 |
| PKG-28 | DC-SeatChangeEvent | public | PKG-13, PKG-21, PKG-24 |

## F6. Kiểm tra coupling giữa package

P09 chọn layered nới lỏng nên cột Nhảy layer ghi "Không áp dụng". Phụ thuộc tới subsystem đều đi qua interface của nó (cột Phụ thuộc ghi "qua IF-nn"). Đã kiểm bằng chương trình: không có cặp phụ thuộc hai chiều, không có vòng (cả đồ thị 25 package lẫn đồ thị sau khi gộp thành 10 package Go ở Phụ lục), không có cạnh đi từ layer dưới lên layer trên.

| Phụ thuộc (PKG --> PKG) | Suy ra từ (quan hệ lớp, message) | Cross-coupled | Lower --> Upper | Nhảy layer | Vòng | Kết luận và cách sửa |
|---|---|---|---|---|---|---|
| PKG-05 --> PKG-29 | DC-BookTicketsStore, DC-CancelTicketStore dùng DC-SeatMapSyncClient, DC-SeatMapReducer | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-06 --> PKG-29 | DC-CounterBookTicketsStore, DC-CounterCancelTicketStore dùng DC-SeatMapSyncClient, DC-SeatMapReducer | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-13 | DC-BookingController gọi DC-BookTicketsService; DC-SeatMapStreamController gọi DC-SeatMapService và chỉ nhận khung SSE dạng văn bản, không chạm kiểu sự kiện của Domain (P07 UC-005) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-15 | DC-TicketController gọi DC-CancelTicketService, DC-CheckTicketService (P07 UC-008, UC-009) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-16 | DC-PricingScheduleController gọi DC-ManagePriceListService, DC-ScheduleShowtimesService (P07 UC-013, UC-014) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-17 | Giữ chỗ theo P09 F6, chưa có lớp | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-18 | Giữ chỗ theo P09 F6, chưa có lớp | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-19 | Giữ chỗ theo P09 F6, chưa có lớp | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-11 --> PKG-26 (qua IF-07) | DC-AuthFilter gọi IF-07 (ngoại lệ cho phép của P09 F6) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-12 --> PKG-14 | DC-PaymentCallbackController gọi DC-PaymentReportService, nhận DC-IpnAnswer (P07 UC-005 bước 11, UC-006 bước 2) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-22 (qua IF-01) | DC-BookTicketsService gọi IF-01 để ký URL thanh toán (P07 UC-005 bước 10) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-24 (qua IF-04) | DC-SeatMapService gọi IF-04 để đăng ký nhận cập nhật | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-21 | Mở giao dịch qua IF-08, đọc ảnh chụp và dọn sự kiện qua IF-22 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-27 | Dùng DC-Showtime, DC-PriceList, IF-11, IF-12, IF-13 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-28 | Dùng DC-SeatHold, DC-SeatStatus, IF-16, IF-17, IF-18, IF-20 (EX-01, EX-03, EX-04, EX-05); DC-SeatMapService dịch DC-SeatChangeEvent | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-13 --> PKG-25 (qua IF-06) | DC-HoldExpiryJob, DC-SeatReleaseJob hiện thực IF-06 (realization đi xuống) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-22 (qua IF-01, IF-02) | DC-PaymentReportService gọi IF-02; DC-RefundService gọi IF-01 (P07 UC-006 bước 3, 5) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-21 | Mở giao dịch qua IF-08; hàng đợi gửi qua IF-23 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-27 | EX-02 tạo DC-Booking, DC-Ticket tham chiếu DC-Showtime, DC-Seat (P09 F6) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-28 | Dùng DC-PaymentTransaction, DC-RefundRequest, DC-SeatHold, DC-SeatStatus, IF-17 đến IF-21 (EX-02, EX-09, EX-10) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-14 --> PKG-25 (qua IF-06) | DC-RefundOutboxJob hiện thực IF-06 (realization đi xuống) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-14 | DC-CancelTicketService gọi DC-RefundService (P07 UC-008 bước 5); PKG-14 không phụ thuộc PKG-15 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-21 | Mở giao dịch qua IF-08 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-27 | DC-CancelTicketService, DC-CheckTicketService đọc DC-Showtime (BR-33, hạn huỷ) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-15 --> PKG-28 | Dùng DC-Ticket, DC-Booking, IF-18, IF-20, IF-21 (EX-06, EX-07, EX-08) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-16 --> PKG-21 | Mở giao dịch qua IF-08 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-16 --> PKG-27 | Dùng DC-PriceList, DC-Showtime, DC-Auditorium, IF-11, IF-12, IF-13 (EX-11 đến EX-14) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-16 --> PKG-28 | EX-13, EX-14 khoá IF-17, IF-18, IF-20 (SeatHold S, SeatStatus X, Ticket S) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-17 --> PKG-21 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-17 --> PKG-27 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-21 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-27 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-18 --> PKG-28 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-21 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-26 (qua IF-07) | Giữ chỗ theo P09 F6: dùng IF-07 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-27 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-19 --> PKG-28 | Giữ chỗ theo P09 F6 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-21 | DC-EmailOutboxJob dùng IF-23 (claim, ghi kết quả) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-23 (qua IF-03) | DC-EmailOutboxJob gọi IF-03 (P07 UC-005 bước 14, UC-006 bước 7) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-27 | DC-EmailOutboxJob dựng nội dung email từ DC-Showtime, DC-Cinema, DC-Auditorium, DC-Seat, DC-Movie (cạnh P09 F6 còn thiếu, xem Đề xuất sửa) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-28 | DC-EmailOutboxJob đọc DC-Booking, DC-Ticket qua IF-20 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-20 --> PKG-25 (qua IF-06) | DC-EmailOutboxJob hiện thực IF-06 (realization đi xuống) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-21 --> PKG-27 | DC-PgUnitOfWork hiện thực IF-08; DC-PgCinemaOperationsStore hiện thực IF-11 đến IF-15 | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-21 --> PKG-28 | DC-PgTicketingStore hiện thực IF-16 đến IF-21; DC-SeatEventWriter dùng DC-SeatChangeEvent | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-24 --> PKG-21 | Hub đọc seat_event qua IF-22 (cùng layer, một chiều; PKG-21 không phụ thuộc PKG-24) | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-24 --> PKG-28 | Hub phát DC-SeatChangeEvent | Không | Không | Không áp dụng | Không | Hợp lệ |
| PKG-28 --> PKG-27 | DC-SeatStatus, DC-Ticket tham chiếu DC-Showtime, DC-Seat (cùng layer, một chiều; PKG-27 không phụ thuộc PKG-28) | Không | Không | Không áp dụng | Không | Hợp lệ |

So với P09 F6, P10 thêm ba cạnh (PKG-05 --> PKG-29, PKG-06 --> PKG-29, PKG-20 --> PKG-27) và đổi cạnh tới PKG-22, PKG-23, PKG-24, PKG-26 thành phụ thuộc interface; không cạnh P09 nào bị bỏ. Các phụ thuộc kiểu "cùng layer, một chiều" gồm PKG-15 --> PKG-14, PKG-24 --> PKG-21, PKG-28 --> PKG-27, PKG-05 --> PKG-29, PKG-06 --> PKG-29 đều không có chiều ngược.


## F7. Package diagram thiết kế

File diagrams/P10-package-design.drawio. Chỉ vẽ interface của subsystem (IF-01 đến IF-07) và các lớp hiện thực interface gọi ngược. Interface kho dữ liệu, IF-08, IF-22, IF-23 không vẽ: phụ thuộc tới chúng thể hiện ở cạnh giữa các package (các cạnh tới PKG-21, PKG-27, PKG-28, ví dụ D-13, D-14, D-15, D-45, D-46, D-47), tên interface ở F3 và F6. Interface vẽ dạng rút gọn (lollipop).

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
| PKG-13 | Package | SeatBooking | - | PKG-02 | Phần tử vẽ: DC-HoldExpiryJob, DC-SeatReleaseJob |
| PKG-14 | Package | PaymentRefund | - | PKG-02 | Phần tử vẽ: DC-RefundOutboxJob |
| PKG-15 | Package | TicketService | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-16 | Package | ScheduleAndPricing | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-17 | Package | Catalog | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-18 | Package | Reporting | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-19 | Package | AccountManagement | - | PKG-02 | Không vẽ phần tử bên trong |
| PKG-20 | Package | Notification | - | PKG-02 | Phần tử vẽ: DC-EmailOutboxJob |
| PKG-21 | Package | Persistence | - | PKG-03 | Không vẽ phần tử bên trong |
| PKG-22 | Package | PaymentGatewayClient | - | PKG-03 | Phần tử vẽ: SS-01, IF-01, IF-02 |
| PKG-23 | Package | EmailGatewayClient | - | PKG-03 | Phần tử vẽ: SS-02, IF-03 |
| PKG-24 | Package | SeatEventHub | - | PKG-03 | Phần tử vẽ: SS-03, IF-04 |
| PKG-25 | Package | Scheduler | - | PKG-03 | Phần tử vẽ: SS-04, IF-05, IF-06 |
| PKG-26 | Package | Security | - | PKG-03 | Phần tử vẽ: SS-05, IF-07 |
| PKG-27 | Package | CinemaOperations | - | PKG-04 | Không vẽ phần tử bên trong |
| PKG-28 | Package | Ticketing | - | PKG-04 | Không vẽ phần tử bên trong |
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
| D-04 | PKG-11 | PKG-15 | Dependency | - | UC-008, UC-009 |
| D-05 | PKG-11 | PKG-16 | Dependency | - | UC-013, UC-014 |
| D-06 | PKG-11 | PKG-17 | Dependency | - | Giữ chỗ (P09) |
| D-07 | PKG-11 | PKG-18 | Dependency | - | Giữ chỗ (P09) |
| D-08 | PKG-11 | PKG-19 | Dependency | - | Giữ chỗ (P09) |
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
| D-32 | PKG-17 | PKG-21 | Dependency | - | Giữ chỗ (P09) |
| D-33 | PKG-17 | PKG-27 | Dependency | - | Giữ chỗ (P09) |
| D-34 | PKG-18 | PKG-21 | Dependency | - | Giữ chỗ (P09) |
| D-35 | PKG-18 | PKG-27 | Dependency | - | Giữ chỗ (P09) |
| D-36 | PKG-18 | PKG-28 | Dependency | - | Giữ chỗ (P09) |
| D-37 | PKG-19 | PKG-21 | Dependency | - | Giữ chỗ (P09) |
| D-38 | PKG-19 | IF-07 | Dependency | - | Giữ chỗ (P09) |
| D-39 | PKG-19 | PKG-27 | Dependency | - | Giữ chỗ (P09) |
| D-40 | PKG-19 | PKG-28 | Dependency | - | Giữ chỗ (P09) |
| D-41 | PKG-20 | PKG-21 | Dependency | - | Hàng đợi email |
| D-42 | PKG-20 | IF-03 | Dependency | - | Gửi email |
| D-43 | PKG-20 | PKG-28 | Dependency | - | Đọc lần đặt, vé |
| D-44 | DC-EmailOutboxJob | IF-06 | Realization | «realize» | Công việc gửi email |
| D-45 | PKG-21 | PKG-27 | Dependency | - | Hiện thực IF-08, IF-11 đến IF-15 |
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
| IF-07 | Interface | «interface»<br>IAuthenticator | «interface» | - | Trách nhiệm: // hashPassword: băm mật khẩu; // verifyPassword: kiểm mật khẩu khi đăng nhập; // issueSession: cấp mã phiên; // verifySession: kiểm mã phiên và trả vai trò; // checkRole: kiểm vai trò được phép |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| C05-01 | SS-05 | IF-07 | Realization | «realize» | - |
| C05-02 | DC-AuthFilter | IF-07 | Dependency | - | - |


## Phụ lục. Ánh xạ sang 10 package Go khi viết mã (P09 Vấn đề còn mở 8)

Không đổi P09. Gộp theo gợi ý của P09; PKG-12 (điểm vào IPN) đi cùng nhóm payment vì chỉ gọi PKG-14. Đồ thị phụ thuộc sau khi gộp không có vòng (đã kiểm bằng chương trình). Phần giao diện React (PKG-05 đến PKG-10, PKG-29) là một ứng dụng web riêng.

| Package Go | PKG gộp | Ghi chú |
|---|---|---|
| api | PKG-11 | REST controller, SSE, bộ lọc mã phiên; chỉ gọi seatbooking, ticket, catalog, account |
| seatbooking | PKG-13, PKG-24 | Giữ ghế, sơ đồ ghế, công việc hết hạn, hub sự kiện; gọi payment qua IF-01 nên phụ thuộc payment, payment không phụ thuộc ngược |
| payment | PKG-14, PKG-22, PKG-12 | IPN, hoàn tiền, subsystem cổng thanh toán; không import seatbooking |
| ticket | PKG-15 | Huỷ vé, soát vé; gọi payment |
| catalog | PKG-16, PKG-17, PKG-18 | Bảng giá, lịch chiếu, danh mục, báo cáo |
| account | PKG-19, PKG-26 | Tài khoản và subsystem bảo mật |
| notify | PKG-20, PKG-23 | Hàng đợi email và subsystem email |
| store | PKG-21 | Persistence |
| jobs | PKG-25 | Subsystem hẹn giờ và IF-06 |
| domain | PKG-27, PKG-28 | Lớp miền và interface kho |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Trạng thái |
|---|---|---|---|---|
| Q-116 | Interface đọc và dọn bảng seat_event (IF-22) do package nào định nghĩa: PKG-21 Persistence hay PKG-24 SeatEventHub? | IF-22, PKG-21, PKG-24, D-47, P09 F4, F6 | P09 F4 ("chỉ lộ ra ngoài qua interface do PKG-24 ... định nghĩa") khác P09 F6 ("PKG-21 không phụ thuộc PKG-24") | Đã trả lời: PKG-21 định nghĩa IF-22 (PKG-24 gọi xuống PKG-21 cùng layer một chiều; nếu PKG-24 định nghĩa thì PKG-21 hiện thực nó và tạo vòng PKG-21 --> PKG-24 --> PKG-21). Sửa câu trong P09 F4 (Đề xuất sửa artifact trước) |
| Q-117 | Showtime là lớp chủ của EX-01 (holdSeats) nhưng việc ghi SeatHold, SeatStatus thuộc PKG-28; để PKG-27 không phụ thuộc PKG-28: (a) DC-Showtime chỉ kiểm tra và chốt giá, lớp dịch vụ gọi DC-SeatHold, DC-SeatStatus trong cùng giao dịch; hay (b) thêm interface ISeatHolder ở PKG-27? | DC-Showtime, DC-SeatHold, DC-SeatStatus, DC-BookTicketsService, DC-ScheduleShowtimesService, EX-01, EX-13, EX-14, P12 | P08 F4b EX-01 (lớp chủ Showtime) và P08 F3 AC-E-Showtime.holdSeats; P09 F4 ghi chú Domain chỉ nêu interface cho EX-13, EX-14 | Đã trả lời: phương án (a), áp dụng cùng nguyên tắc cho EX-13, EX-14 (bỏ IF-09, IF-10 và hai lớp hiện thực). BR-04 và điều kiện mở bán vẫn nằm trong DC-Showtime, DC-Customer, DC-BoxOfficeClerk |
| Q-118 | Khi tài liệu VNPay sandbox không có tra cứu giao dịch hoàn hoặc chống hoàn trùng (P09 Vấn đề còn mở 6), lần gửi lại hoàn tiền sau lỗi không rõ kết quả nên tự động gửi lại hay chuyển RefundRequest sang Cần xử lý thủ công? | IF-01 (findRefund), DC-RefundService, DC-RefundOutboxJob, EX-10 | P09 F7.7 và Vấn đề còn mở 6; BR-41, BR-43 | Đã trả lời: chuyển Cần xử lý thủ công khi không tra cứu được kết quả hoàn (gửi lại tự động có thể hoàn tiền hai lần). Khi viết mã kiểm tài liệu VNPay: nếu có khoá chống hoàn trùng hoặc tra cứu hoàn thì dùng findRefund và giữ gửi lại tự động |

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

## Vấn đề còn mở

1. Hồ sơ chưa cập nhật theo P09: project-profile.md mục 3 vẫn ghi CONG_NGHE "Chưa chốt" và NEN_TANG chưa theo khối F11. P10 dùng công nghệ ở P09 F11. Q-111 đến Q-115 giữ trạng thái đã trả lời ghi ở P09 và không còn chặn việc chọn công nghệ.
2. Hai package PKG-27, PKG-28 có 15 phần tử mỗi package, đúng mức hợp lý 15 (sau khi bỏ IF-09, IF-10 và hai lớp hiện thực); đã kiểm khả năng tách (F4) và giữ nguyên vì tách interface kho khỏi lớp miền làm thêm cạnh phụ thuộc cho mọi package Application mà không giảm coupling giữa hai package miền. Presentation có 9 package (P09 đã sát ngưỡng 8 với 8 package); PKG-29 là lý do thứ chín, chấp nhận vì dùng chung bởi hai tác nhân. PKG-12 chỉ có 1 phần tử, chấp nhận vì lý do thay đổi riêng (định dạng callback của cổng, không đăng nhập).
3. Năm package giữ chỗ không có phần tử: PKG-09, PKG-10, PKG-17, PKG-18, PKG-19 (UC-001, UC-003, UC-004, UC-007, UC-010, UC-011, UC-015, UC-016, UC-017 chưa có P07). Chạy lại P10 khi các use case này có P07; chưa tạo subsystem nào cho chúng. Các cạnh phụ thuộc của chúng giữ theo P09 F6.
4. Tám lớp Tạm (AC-E-Customer, AC-E-BoxOfficeClerk, AC-E-TicketChecker, AC-E-CinemaManager, AC-E-Cinema, AC-E-Auditorium, AC-E-Seat, AC-E-Movie) ánh xạ 1-1 tạm, chờ P07 của UC-001, UC-010, UC-011, UC-012, UC-017; Q-108 đã chốt giữ ba entity nhân viên riêng nên P10 không tạo lớp cha Staff.
5. EX-15 (sửa sơ đồ ghế, UC-012) chưa có lớp dịch vụ sở hữu; chuỗi khoá đã nêu ở F3a. Khi UC-012 có P07, thêm lớp dịch vụ vào PKG-16 và đối chiếu lại DC-Auditorium.
6. IF-08 đến IF-23 không phải interface của subsystem nên P11b không thiết kế; operation do P12 thiết kế, P12 cấp IF mới nối tiếp IF-24. Nhóm interface ghép (IF-12, IF-13, IF-16, IF-20) theo đơn vị khoá, P12 có thể tách khi thiết kế operation.
7. Phần lớn tên và ngưỡng của SS-03, SS-04 (500 ms, 5 giây, 10 giây, 256, 8 giây) là quyết định thiết kế đã chốt ở P09 F7 (C1.7); P10 không thêm tham số mới. Việc có đạt NFR-05 đến NFR-09 vẫn cần các ca đo T1 đến T5 (P09 Vấn đề còn mở 2).
8. Ba lớp hiện thực nối ở hàm khởi động chương trình (DC-Pg..., DC-ConnectionPools, bốn công việc nền) mang nhãn visibility riêng ở F5 vì hàm khởi động nằm ngoài mô hình package.
9. Trả lời P08 đã áp dụng: Q-106 (một lớp DC-RefundService dùng chung), Q-108 (ba entity nhân viên riêng), Q-109 (tạo trạng thái ghế do DC-ScheduleShowtimesService điều phối qua IF-18), Q-110 (không đổi ánh xạ).
