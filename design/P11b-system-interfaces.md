# P11b - Giao diện hệ thống và thiết bị - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 1.4 |
| Thay đổi 1.4 | Ghi project-profile.md đã cập nhật CONG_NGHE (RF-15); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3, 4); P01-actors.md 1.2; P04-uc-specs UC-005 1.11, UC-006 1.8, UC-008 1.8, UC-009 1.5, UC-013 1.2, UC-014 1.4 (luồng thay thế, ngoại lệ, tiền điều kiện); P06-supplementary-spec.md 1.3 (NFR-01 đến NFR-03, NFR-07 đến NFR-10, NFR-15 đến NFR-18); P07-uc-analysis UC-005 1.1, UC-006 1.1, UC-008 1.2 (message tới boundary hệ thống); P08-analysis-model.md 1.5; P09-architecture.md 1.6 (F4, F6, F7, F11, Vấn đề còn mở 6); P10-design-elements.md 1.4 (F2, F4, F5, Q-116 đến Q-118); TAI_LIEU_GIAO_TIEP: Không có; CHINH_SACH_LOI: Không có (suy từ NFR và P09 F7 theo C1 mục 7); YEU_CAU_BO_SUNG: Không có |
| Phạm vi | Tất cả subsystem SS-01 đến SS-05 của P10 F2 (IF-01 đến IF-07) |
| Mã Q, ASM cuối đã cấp | Q-132; không có ASM (NGHIEM_NGAT) |

REST API giữa trình duyệt và máy chủ không thuộc P11b vì REST không phải subsystem của P10 F2. Phần giao tiếp trình duyệt với máy chủ mà P10 đã đặt thành subsystem là SS-03 (luồng sơ đồ ghế SSE có con trỏ sự kiện và Last-Event-ID, IF-04); điểm vào IPN của cổng thanh toán là DC-PaymentCallbackController (PKG-12) gọi IF-02 của SS-01.

## Danh sách file subsystem

| SS | File | Phiên bản |
|---|---|---|
| SS-01 PaymentGateway | P11b-system-interfaces/SS-01-payment-gateway.md | 1.1 |
| SS-02 EmailGateway | P11b-system-interfaces/SS-02-email-gateway.md | 1.1 |
| SS-03 SeatEventHub | P11b-system-interfaces/SS-03-seat-event-hub.md | 1.1 |
| SS-04 Scheduler | P11b-system-interfaces/SS-04-scheduler.md | 1.1 |
| SS-05 Security | P11b-system-interfaces/SS-05-security.md | 1.1 |

File sơ đồ: diagrams/P11b-subsystem-SS-01.drawio đến diagrams/P11b-subsystem-SS-05.drawio, mỗi file nhiều trang (hộp đen, hộp trắng, Phần tử, Phụ thuộc). Bước sau (P12, X1) đọc file này rồi file của các SS mà phạm vi dùng.

## Chính sách lỗi đã áp dụng (tóm tắt)

| Hệ thống ngoài | Timeout | Thử lại | Idempotency | Kết quả không rõ | Nguồn |
|---|---|---|---|---|---|
| Cổng thanh toán: tạo địa chỉ thanh toán | Không có (ký cục bộ) | Không | Không tác dụng phụ; mỗi lần bấm thanh toán là bản ghi chờ mới | Không áp dụng | P09 F7.6 |
| Cổng thanh toán: nhận IPN | Không áp dụng | Do cổng gửi lại | Dưới khoá lần giữ ghế, cờ đã xử lý, UNIQUE; câu trả lời theo kết quả | Rollback toàn bộ, trả mã tạm thời | P09 F7.6 |
| Cổng thanh toán: hoàn tiền | 30 giây (BR-43, NFR-17) | Qua hàng đợi: sau 1, 5, 15 phút, tối đa 3 lần thử lại (BR-41); lần thử sau luôn findRefund trước (hai lời gọi tối đa 60 giây, cả dòng tối đa 80 giây mỗi claim) | Khoá refundKey ổn định, dòng hàng đợi unique, claim_token (claim từng dòng, claimed_until 120 giây, hàng rào ở giao dịch 1); cổng có loại trùng hay không: chưa xác nhận (Q-132, V-09) | findRefund; không tra cứu được thì Cần xử lý thủ công, không gửi lại tự động (Q-118) | P09 F7.7, Q-118 |
| Dịch vụ email SMTP | 30 giây cho cả thư, kết nối 10 giây | Qua hàng đợi: sau 1, 5, 15 phút, tối đa 3 lần thử lại; lỗi vĩnh viễn không thử lại | Message-ID theo khoá chống lặp; không bảo đảm loại trùng, chấp nhận gửi trùng hiếm | Thử lại với cùng Message-ID | P09 F7.7, BR-89 |
| Sơ đồ ghế (SS-03) | Đọc phát lại 3 giây; độ trễ sự kiện tối đa 3 giây | Trình duyệt tự nối lại với Last-Event-ID | Trình duyệt áp theo từng ghế nên lặp và lệch thứ tự vô hại | ReloadRequired tải lại ảnh chụp | P09 F7.5 |
| Scheduler (SS-04) | Ngân sách 8 giây mỗi lượt chỉ chặn nhận mục mới, chu kỳ 10 giây | Chu kỳ sau | Công việc chạy lặp an toàn | Không áp dụng | P09 F7.4 |

## F8. Tổng hợp toàn hệ thống

| SS | IF | Số operation | UC dùng | Rủi ro chính |
|---|---|---|---|---|
| SS-01 | IF-01 IPaymentGateway | 3 | UC-005, UC-006, UC-008 | Hoàn tiền hai lần khi kết quả không rõ mà cổng không loại trùng theo khoá hoặc tra cứu sai (V-09, V-11, Q-132); mọi tham số VNPay chưa kiểm với tài liệu thật |
| SS-01 | IF-02 IPaymentReportReceiver | 1 | UC-005, UC-006 | Thông báo giả hoặc trùng, đến muộn, đến đồng thời (xử lý dưới khoá ở PKG-14); số tiền lệch xử lý theo UC-006 luồng 2f (Q-128, BR-91); chính sách gửi lại IPN của cổng chưa kiểm (V-04) |
| SS-02 | IF-03 IEmailSender | 1 | UC-005, UC-006 | Gửi trùng hiếm; hết lần thử thì khách không nhận email nhưng vé và khoản hoàn vẫn hiệu lực (BR-89); nhà cung cấp SMTP chưa chọn (V-17) |
| SS-03 | IF-04 ISeatEventSubscription | 2 | UC-005, UC-008 | Trễ trên 3 giây khi quá tải (NFR-08, NFR-09, ca đo T3); hàng đợi đầy làm đóng kết nối; chữ ký IF-22 còn tạm |
| SS-04 | IF-05 IJobScheduler | 3 | UC-005, UC-006, UC-008 (hạ tầng) | Mọi bản backend dừng thì ghế trả chậm hơn NFR-07 (kết quả hết hạn vẫn đúng) |
| SS-04 | IF-06 IScheduledJob (gọi ngược) | 1 | UC-005, UC-006, UC-008 (hạ tầng) | Lượt treo quá ngân sách; lỗi công việc bị che bởi log |
| SS-05 | IF-07 IAuthenticator | 5 (4 có chữ ký, hashPassword chờ P07) | UC-005, UC-008, UC-009, UC-013, UC-014 (tiền điều kiện) | Token không thu hồi được tới khi hết hạn; thời hạn phiên khách 24 giờ, nhân viên 8 giờ (Q-129); chưa có DC đăng nhập gọi verifyPassword, issueSession |

## Điểm chưa kiểm với tài liệu hệ thống ngoài

Đầu vào không có tài liệu API (TAI_LIEU_GIAO_TIEP là Không có). Các mục dưới là hiểu biết về VNPay sandbox và SMTP chưa kiểm với tài liệu hiện hành; kiểm khi viết mã. Chữ ký interface ở các file SS không phụ thuộc kết quả kiểm; chỉ phần bên trong subsystem (tham số, bảng mã, chuỗi ký) có thể đổi. Mỗi message trong sơ đồ hộp trắng có nhãn [V-nn] khi dựa vào mục tương ứng.

| V | Điều cần kiểm | Giả định tạm của thiết kế | Ảnh hưởng nếu khác |
|---|---|---|---|
| V-01 | Tên, bắt buộc và giới hạn của tham số tạo địa chỉ thanh toán (phiên bản, lệnh pay, mã đơn vị, số tiền, đơn vị tiền, mã tham chiếu giao dịch, thông tin đơn hàng, loại hàng, ngôn ngữ, địa chỉ trả về, địa chỉ IP, thời điểm tạo, hạn) | Dùng bộ tham số vnp_ của VNPay | DC-VnpayUrlBuilder |
| V-02 | Chuỗi dùng để ký: sắp tham số tăng dần theo tên, mã hoá URL ra sao, bỏ vnp_SecureHash và vnp_SecureHashType, HMAC-SHA512 trên chuỗi nào | HMAC-SHA512 trên chuỗi tham số đã sắp, bỏ hai tham số chữ ký | DC-VnpaySigner; sai thì mọi chữ ký bị từ chối |
| V-03 | Số tiền nhân 100 khi gửi và chia 100 khi nhận | Nhân và chia 100 | DC-VnpayUrlBuilder, DC-VnpayReportDecoder |
| V-04 | IPN: HTTP phương thức nào (GET với tham số trên địa chỉ), câu trả lời JSON RspCode và Message, ý nghĩa 00, 01, 02, 04, 97, 99; số lần và khoảng cách gửi lại IPN, hành vi khi RspCode khác 00 và 02, thời gian cổng chờ câu trả lời; có IPN cho giao dịch thất bại không | Như P09 F7.6 | DC-PaymentReportReceiver; Q-111 mục b |
| V-05 | Cách suy ra thành công hay thất bại: mã phản hồi bằng 00 và trạng thái giao dịch bằng 00, hay chỉ một trong hai | Cả hai bằng 00 mới là Succeeded | DC-VnpayReportDecoder |
| V-06 | Thông tin đơn hàng mang được mã tham chiếu lần giữ ghế không (độ dài, ký tự cho phép, có bắt buộc không dấu) và cổng trả nguyên vẹn trong IPN | Mang được và trả nguyên vẹn (NFR-16) | Nếu không, phải nhúng mã tham chiếu vào mã tham chiếu giao dịch |
| V-07 | Tham số hạn thanh toán: có trong sandbox không, múi giờ, quá hạn thì trang thanh toán báo gì và có còn IPN không | Đặt hạn bằng expiry_time của lần giữ ghế (BR-10) để giảm thanh toán trễ | DC-VnpayUrlBuilder; nếu không có thì không đặt hạn, thanh toán trễ xử lý ở UC-006 |
| V-08 | API hoàn tiền: địa chỉ, phương thức, danh sách trường (mã yêu cầu, loại hoàn toàn phần hoặc một phần, mã tham chiếu giao dịch, số tiền, thời điểm giao dịch gốc, người tạo, địa chỉ IP, thông tin), chuỗi ký của yêu cầu | Bộ trường như mô tả ở S01W3 | DC-VnpayRefundClient |
| V-09 | Mã yêu cầu hoàn (độ dài tối đa, có phải duy nhất trong ngày không) và cổng có loại trùng yêu cầu hoàn theo mã đó không; gửi lại cùng mã thì trả gì | Không giả định cổng loại trùng; requestId suy ra ổn định từ refundKey; chống hoàn trùng dựa vào findRefund trước khi gửi lại (Q-111 mục d, Q-118) | Nếu cổng loại trùng được thì giữ gửi lại tự động; nếu không thì chỉ findRefund bảo vệ |
| V-10 | Mã trả lời của hoàn tiền: mã nào là đã hoàn, mã nào là từ chối rõ ràng (chưa thực hiện), mã nào là đang xử lý hoặc đã yêu cầu trước đó; mã 00 là đã hoàn xong hay mới nhận yêu cầu | Chỉ các mã liệt kê là từ chối rõ ràng mới là Rejected; mã đang xử lý, mã lạ, 99 là Unknown | Bảng mã trong DC-VnpayRefundClient |
| V-11 | API tra cứu: có cho biết trạng thái hoàn của giao dịch gốc hoặc của yêu cầu hoàn theo mã không; các trạng thái trả về (chưa xong, đang xử lý hoàn, đã gửi yêu cầu hoàn sang ngân hàng, bị từ chối hoàn); sandbox có mô phỏng không | Trạng thái đang xử lý hoàn không bao giờ là NotRefunded; không có cách tra cứu thì cờ cấu hình cổng có tra cứu hoàn đặt sai, findRefund trả NotSupported (Q-118) | Nếu không tra cứu được thì mọi hoàn tiền lỗi không rõ sang Cần xử lý thủ công |
| V-12 | Điều kiện hoàn của cổng: hạn số ngày, hoàn một phần nhiều lần, hoàn khi chưa quyết toán, sandbox có áp dụng không | Không có hạn trong sandbox | Có thể phát sinh mã từ chối mới (V-10) |
| V-13 | Trả lời của hoàn tiền và tra cứu có chữ ký không và ký thế nào | Có chữ ký, kiểm bằng cùng khoá | Nếu không có thì bỏ bước verify ở S01W3, S01W4 |
| V-14 | Địa chỉ công khai cho IPN khi chạy thử (công cụ đường hầm) và nơi cấu hình địa chỉ IPN trên cổng | Cấu hình ở trang quản trị của cổng | Chỉ ảnh hưởng chạy thử (P09 Vấn đề còn mở 6) |
| V-15 | Định dạng và múi giờ của thời điểm trong tham số và trong IPN | yyyyMMddHHmmss, múi giờ GMT+7 | DC-VnpayReportDecoder, DC-VnpayUrlBuilder |
| V-16 | Địa chỉ trả về nhận cùng bộ tham số và chữ ký như IPN không | Có, dùng chung reportTransactionResult | Nếu khác thì thêm operation riêng cho địa chỉ trả về |
| V-17 | SMTP: nhà cung cấp, máy chủ, cổng, chế độ TLS, xác thực, giới hạn tốc độ và kích thước thư, có nhận Message-ID do hệ thống đặt không, ảnh nhúng bằng Content-ID có hiển thị không | SMTP chuẩn có TLS và xác thực; Message-ID do hệ thống đặt; ảnh mã QR nhúng trong thân thư | DC-SmtpClient, DC-MimeMessageBuilder, DC-SmtpConfig |

## Câu hỏi mở

Mã Q của P11b: Q-126 đến Q-132. Q-126 đến Q-131 đã trả lời theo đề xuất của review P11; Q-132 hỏi bên ngoài.

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-126 | Đã trả lời (theo đề xuất review P11: trang hiện "Đang xác nhận thanh toán", hỏi lại mỗi 2 giây, tối đa 60 giây; quá 60 giây hiện MSG-30, hoặc MSG-81 kèm nút Quay lại thanh toán nếu lần giữ ghế còn Đang giữ; lần giữ ghế chạy tới hết hạn). Khi khách quay về từ trang thanh toán (địa chỉ trả về) mà hệ thống chưa nhận IPN, trang hiển thị gì, và khách chờ tối đa bao lâu trước khi được báo "chưa xác nhận được thanh toán, kiểm tra lại sau"? | UC-005 sau bước 10 và trước bước 11; địa chỉ trả về; IF-02 reportTransactionResult; SS-01 | P09 F7.6 (địa chỉ trả về chỉ đọc trạng thái); P04 UC-005 không có luồng cho khách đã quay về mà chưa có kết quả |
| Q-127 | Đã trả lời (đồng ý: P04 UC-006 1.6 luồng 4t và UC-008 1.5 luồng 5t chỉ gửi lại sau khi tra cứu cho thấy chưa hoàn; không tra cứu được thì Cần xử lý thủ công; lịch hẹn lại 1, 5, 15 phút). Hoàn tiền hết 30 giây hoặc không rõ kết quả: P04 cho "quay lại bước 4 hoặc 5" thử lại, còn Q-118 chỉ cho gửi lại sau khi findRefund xác nhận chưa hoàn. Xác nhận sửa P04 theo Q-118? | IF-01 requestRefund, findRefund; DC-RefundService; UC-006 luồng 4a, 4t, 5a; UC-008 luồng 5b, 5t, 6a | P04 UC-006 4a, 4b, 5a, 5b; UC-008 5b, 5c, 6a, 6b so với P10 Q-118 và P09 F7.7 |
| Q-128 | Đã trả lời (theo đề xuất review P11: không tạo vé, không hoàn tự động, ghi log để xử lý thủ công, trả RspCode 04; thêm luồng 2f và BR-91 vào UC-006 1.6). Cổng báo thành công nhưng số tiền khác số tiền của giao dịch hoặc của lần giữ ghế: hoàn toàn bộ số cổng báo, hay chỉ ghi log? | DC-IpnOutcome AMOUNT_MISMATCH; DC-PaymentReportService; UC-006 | P04 UC-006 luồng 2e chỉ nêu giao dịch không nhận ra |
| Q-129 | Đã trả lời (theo đề xuất review P11: khách 24 giờ, nhân viên 8 giờ, không tự gia hạn; hết hạn thì đăng nhập lại; quyết định thiết kế). Thời hạn phiên đăng nhập của khách và của nhân viên là bao lâu, và phiên có tự gia hạn khi đang dùng không? | IF-07 issueSession, verifySession; SessionClaims.expiresAt | P06 NFR-01, NFR-02, NFR-03 chỉ nêu đăng nhập được, không nêu thời hạn phiên |
| Q-130 | Đã trả lời (theo đề xuất review P11 có chỉnh: luồng 10a chỉ còn khi hệ thống lỗi trước lúc chuyển sang cổng, lần giữ ghế giữ nguyên; cổng báo thất bại bằng IPN thì ghế được trả theo luồng 11a; đã ghi ở UC-005 1.9, P06 1.2, P09 1.3). UC-005 luồng 10a và BR-90 nêu "cổng từ chối hoặc không trả lời trong 30 giây yêu cầu tạo giao dịch", nhưng với VNPay hệ thống chỉ ký địa chỉ thanh toán, không gọi mạng. Hiểu 10a như thế nào? | IF-01 createPaymentTransaction; UC-005 luồng 10a; BR-90; NFR-15 | P04 UC-005 10a, BR-90, NFR-15 so với P09 F7.6 |
| Q-131 | Đã trả lời (theo đề xuất review P11: một thông điệp chung MSG-02, không giới hạn số lần thử, không khoá tạm trong phạm vi đồ án; khoá tài khoản thuộc UC-017 chưa đặc tả). Khi email, số điện thoại hoặc mật khẩu sai ở UC-005 luồng 5a2: hệ thống báo gì, cho nhập lại bao nhiêu lần, có khoá tạm không? | IF-07 verifyPassword; UC-005 luồng 5a2 | P04 UC-005 5a2 chỉ nêu khách cung cấp thông tin rồi quay lại bước 5, không nêu trường hợp sai |
| Q-132 | Chưa trả lời (hỏi bên ngoài: kiểm tài liệu VNPay sandbox khi viết mã). Cổng VNPay có loại trùng yêu cầu hoàn theo mã yêu cầu không, và gửi lại cùng mã thì trả gì? Có API tra cứu trạng thái hoàn theo mã yêu cầu không? | IF-01 requestRefund (cột Idempotent), findRefund; V-09, V-11; DC-RefundService | Không có tài liệu API của cổng trong đầu vào (TAI_LIEU_GIAO_TIEP: Không có) |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P10 | F2 SS-01 IF-02 (reportTransactionResult) | Trách nhiệm ghi "kiểm chữ ký và số tiền" nhưng SS-01 không đọc cơ sở dữ liệu nên không so được số tiền với bản ghi | Ghi "kiểm chữ ký, giải mã số tiền; DC-PaymentReportService so số tiền với bản ghi" Đã áp dụng (P10 1.2). |
| P10 | F3, F4 (PKG-22, PKG-23, PKG-24, PKG-25, PKG-26), F5 | Thiếu các kiểu, ngoại lệ trong chữ ký interface và các lớp bên trong subsystem do P11b cấp mã (mục F5 của từng file SS) | Thêm vào F3 và F4: DC-RefundLookup, DC-ReportHandlingResult, bốn ngoại lệ của SS-01; DC-EmailAttachment, DC-EmailSendResult, DC-InvalidEmailMessageError; DC-SeatEventSubscription, DC-SeatStreamItem, DC-SeatHubUnavailableError; DC-JobRunResult, DC-SchedulerStateError; DC-Role, DC-SessionClaims, DC-IssuedSession và ba ngoại lệ của SS-05; thêm nhãn visibility ở F5 (Đã áp dụng: P10 1.3) |
| P10 | F2 SS-02 | Hai trách nhiệm sendTicketsEmail, sendRefundNotificationEmail được hiện thực bằng một operation sendEmail(message) | Cập nhật cột Trách nhiệm của SS-02 thành sendEmail (nội dung thư do DC-EmailOutboxJob dựng) Đã áp dụng (P10 1.2). |
| P10 | F4 PKG-12, F3 DC-PaymentCallbackController | Chưa có điểm vào cho địa chỉ trả về (return URL) của khách sau thanh toán; P09 F7.6 yêu cầu trang này chỉ đọc trạng thái | Thêm điểm vào (DC-PaymentCallbackController hoặc controller riêng) và lớp Application đọc trạng thái giao dịch; dùng reportTransactionResult để kiểm chữ ký tham số (V-16) (Đã áp dụng: P10 1.3, DC-PaymentCallbackController có ba đường vào HandleIpn, HandleReturn, HandlePaymentStatus) |
| P10 | F2 SS-05 IF-07, F4 PKG-19 | verifyPassword và issueSession không có lớp gọi: P09 F6 chỉ cho PKG-11 kiểm phiên và PKG-19 dùng IF-07, nhưng PKG-19 chưa có DC | Thêm DC đăng nhập ở PKG-19 (chờ P07 UC-001) gọi verifyPassword, issueSession; DC-AuthFilter chỉ gọi verifySession, checkRole (Chờ UC-001) |
| P09 | F7.7 (lần thử hoàn tiền) | Viết "PKG-22 tra cứu giao dịch hoàn trước mỗi lần gửi lại" nhưng PKG-22 không có trạng thái attempt_count; việc gọi findRefund trước requestRefund do DC-RefundService (PKG-14) làm | Đã sửa (P09 1.3): chủ thể là DC-RefundService gọi findRefund của IF-01; claimed_until 120 giây; ngân sách 8 giây chỉ chặn nhận dòng mới |
| P06, P09 | NFR-15; F7.6 bước 2 | NFR-15 viết "qua API tạo giao dịch của cổng"; P09 F7.6 bước 2 viết "IPN thất bại hoặc khách không hoàn tất: giữ nguyên lần giữ ghế" | Đã sửa (P06 1.2, P09 1.3) |
| P10 | F2 SS-01 IF-02, F3 DC-IpnAnswer | replyToReport trả (httpStatus, body) nên để lộ mã HTTP của giao thức ngoài ra interface (quy tắc A3); tham số Map của reportTransactionResult là cặp tên-giá trị nguyên văn của VNPay | Bỏ replyToReport khỏi IF-02 và để PKG-12 (DC-PaymentCallbackController) dịch ReportHandlingResult sang câu trả lời, cùng chỗ với phần dịch RspCode; hoặc đổi kết quả thành kiểu IpnAnswer không nêu mã HTTP Đã áp dụng ở P10 1.2 (bỏ replyToReport khỏi IF-02, DC-IpnAnswer thành kết quả không nêu mã HTTP, PKG-12 dịch sang câu trả lời); chữ ký SS-01 ở P11b đã đổi theo (Đã áp dụng: P11b 1.3). |
| P04 | UC-005 luồng 10a, BR-90 | Với VNPay không có lệnh tạo giao dịch qua mạng nên "cổng từ chối hoặc không trả lời" không xảy ra khi tạo (Q-130) | Đã sửa (UC-005 1.9, BR-90 trong sổ BR, P06 1.2 NFR-15, P09 1.3 F7.6): luồng 10a chỉ còn khi hệ thống lỗi trước lúc chuyển sang cổng |
| P04 | UC-005 (giữa bước 10 và 11) | Thiếu luồng khách quay về từ cổng khi chưa có kết quả (Q-126) | Thêm luồng thay thế sau khi có câu trả lời Đã áp dụng (UC-005 1.10, luồng 10b). |
| P04 | UC-006 luồng 4a, 5a; UC-008 luồng 5b, 6a | "Quay lại bước 4 hoặc 5" ngầm gửi lại ngay; thiết kế chỉ gửi lại sau khi tra cứu cho thấy chưa hoàn, và chuyển Cần xử lý thủ công khi không tra cứu được (Q-118, Q-127) | Đã sửa (UC-006 1.6 luồng 4t, UC-008 1.5 luồng 5t, BR-41, BR-43) |
| P04 | UC-006 (luồng 2e và kế bên) | Không có luồng cho thông báo thành công hợp lệ chữ ký nhưng số tiền lệch (Q-128) | Đã sửa (UC-006 1.6 luồng 2f, BR-91) |
| P04 | UC-005 luồng 5a2 | Không có luồng thông tin đăng nhập sai (Q-131) | Thêm luồng sau khi có câu trả lời Đã áp dụng (UC-005 1.10, luồng 5a2a). |

## Vấn đề còn mở

1. Toàn bộ ánh xạ lời gọi ngoài của SS-01 và SS-02 (tham số, bảng mã, chuỗi ký, giao thức) dựa vào hiểu biết chưa kiểm vì không có tài liệu API trong đầu vào; danh sách V-01 đến V-17 ở trên. Chữ ký interface đã được thiết kế không phụ thuộc các điểm này.
2. Gate 10 x 10 đặt chính giữa cạnh khung sd (theo F4 của prompt) nên toạ độ của gate lệch nửa ô so với lưới 10 của C7.3; các node còn lại là bội số của 10. Ưu tiên F4 (quy tắc riêng của bước) cho gate.
3. Câu trả lời cho cổng (mã HTTP, RspCode) không thuộc SS-01: DC-PaymentCallbackController (PKG-12) dịch DC-IpnOutcome của PKG-14 sang định dạng của cổng, nên IF-02 chỉ còn reportTransactionResult và không để lộ mã HTTP ra interface (quy tắc A3).
4. P07 UC-005 3.1.1.1 ghi cổng trả về "mã giao dịch" cho lời gọi tạo giao dịch; theo P09 F7.6 mã giao dịch do hệ thống sinh trước và cổng chỉ trả địa chỉ thanh toán đã ký. P11b theo P09, không sửa P07.
5. Email bị máy chủ từ chối vĩnh viễn không được thử lại (kết quả không đổi theo lần thử), trong khi BR-89 ghi "thử gửi lại vài lần"; chỉ lỗi tạm thời và không rõ được thử lại. Đây là quyết định thiết kế (C1 mục 7), không đổi hành vi nghiệp vụ: vé và khoản hoàn vẫn hiệu lực, ghi log lỗi.
6. Tên operation của IF-22 đã chốt ở P12: ReadEventsAfter, ReadShowtimeEvents (thêm tham số window), FindEvent; P12 thêm Snapshot và DeleteOlderThan cho ảnh chụp sơ đồ ghế và dọn seat_event.
7. SS-05: mã phiên tự kiểm chứng nên không thu hồi được; tài khoản bị khoá hoặc đổi vai trò vẫn dùng được tới khi token hết hạn. Chờ P07 UC-017 để chốt nghiệp vụ khoá tài khoản; hashPassword chờ P07 UC-001, UC-017.
8. SS-05: truy cập chức năng không đúng vai trò (checkRole sai) không có luồng P04; coi là lỗi truy cập hiển thị ở giao diện (P11a), không là hành vi nghiệp vụ mới.
9. project-profile.md mục 3 đã cập nhật CONG_NGHE theo P09 F11 (Go); chữ ký dùng kiểu trung lập (String, Integer, DateTime, Duration, List, Map). P12 ánh xạ sang Go (kết quả kèm error, context cho thời gian chờ, kênh cho luồng sự kiện). Định danh suất chiếu của IF-04 là số, con trỏ rỗng viết thành 0; tiền là số nguyên đồng (đã phản ánh ở chữ ký).
10. File drawio: các trang tuần tự do bộ sinh đặt toạ độ theo F4 và C7.3, không chạy diakempt; các trang Phần tử và Phụ thuộc đã chạy diakempt -in-place. Trên trang Phần tử, diakempt không sắp lại được các lớp nằm trong khung subsystem (container) nên bố cục do bộ sinh xếp theo tầng phụ thuộc; có thể còn cạnh đi qua gần node.
11. Phạm vi làm khi viết mã (P12): làm đầy đủ SS-01 và SS-03 (trọng tâm là race condition và giữ ghế); SS-04 chỉ cần một vòng lặp theo chu kỳ có ngân sách; SS-05 giữ ba operation verifyPassword, issueSession, verifySession và để checkRole là hàm thường. Kiểm V-02, V-04, V-09, V-11 trước, các V còn lại khi viết mã.
