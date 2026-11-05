# P11b - SS-02 EmailGateway - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3); P01-actors.md 1.1 (ACT-08); P04-uc-specs UC-005 1.9 (bước 14, BR-89), UC-006 1.6 (bước 7, BR-89); P06-supplementary-spec.md 1.2 (NFR-18); P07-uc-analysis UC-005 1.1, UC-006 (message tới EmailService); P08-analysis-model.md 1.2 (AC-B-EmailService); P09-architecture.md 1.3 (F4, F6, F7.1, F7.7); P10-design-elements.md 1.1 (F2, F4, F5); TAI_LIEU_GIAO_TIEP: Không có |
| Phạm vi | SS-02 EmailGateway (IF-03) |
| Mã Q, ASM cuối đã cấp | Ghi ở file chung (Q-126 đến Q-132) |

Nhà cung cấp SMTP chưa được chọn (project-profile.md chỉ ghi "Dịch vụ gửi email (SMTP)"), nên mọi tham số kết nối nằm ở cấu hình và các điểm cần kiểm khi viết mã ghi ở V-17 trong file chung.

## F1. Bối cảnh sử dụng

| UC | Control gọi (AC hoặc DC) | Message trong P07 (STT, tên) | Dữ liệu truyền | Luồng lỗi trong P04 |
|---|---|---|---|---|
| UC-005 Đặt vé | DC-EmailOutboxJob (P07: AC-C-PaymentReportController; P09 F7.7 chuyển việc gửi sang hàng đợi, gọi sau commit) | 4.1.3 và 4.1.3.1 // sendTicketsEmail (bước 14) | Khách (địa chỉ email), các vé; nội dung theo REQ-105 | Không có luồng đánh số; ghi chú bước 14 và BR-89: vé giữ hiệu lực, thử gửi lại vài lần rồi ghi log lỗi |
| UC-006 Hoàn tiền thanh toán đến muộn | DC-EmailOutboxJob (P07: AC-C-PaymentReportController) | 1.1.11 và 1.1.11.1 // sendRefundNotificationEmail (bước 7) | Email khách, mã giao dịch, số tiền hoàn, tên phim, suất chiếu, lý do hoàn (REQ-116) | Ghi chú bước 7 và BR-89: khoản hoàn giữ nguyên hiệu lực |

## F2. Interface

| IF | Tên | Vai trò (một câu) | Bên hiện thực (SS; DC khi là interface gọi ngược) | Client (DC, PKG) | Package chứa |
|---|---|---|---|---|---|
| IF-03 | IEmailSender | Gửi một email đã dựng sẵn tới dịch vụ email SMTP và báo kết quả | SS-02 | DC-EmailOutboxJob (PKG-20) | PKG-23 |

IF-03 có 1 operation. Hai trách nhiệm sendTicketsEmail và sendRefundNotificationEmail của P08 gộp thành một operation vì nội dung thư do PKG-20 dựng (P10 F3, DC-EmailOutboxJob), subsystem chỉ chuyển thư và không cần biết loại thư.

## F3. Operation

| IF | Tên | Hệ thống/thiết bị | Operation | Tham số vào | Kết quả | Lỗi / ngoại lệ | UC | Tiền điều kiện | Hậu điều kiện | Đồng bộ | Idempotent | Timeout |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| IF-03 | IEmailSender | Dịch vụ email SMTP (ACT-08) | sendEmail(message: EmailMessage): EmailSendResult | message: EmailMessage gồm<br>recipientAddress: String - địa chỉ email theo định dạng chuẩn (REQ-107)<br>subject: String - không rỗng<br>body: String - nội dung HTML UTF-8 đã dựng<br>attachments: List(EmailAttachment) - ảnh mã QR nhúng cho email vé; rỗng với email hoàn tiền<br>deduplicationKey: String - khoá chống lặp, giữ nguyên qua mọi lần thử, dùng làm Message-ID (P09 F7.7) | EmailSendResult: status (Accepted: máy chủ thư đã nhận thư / Rejected: máy chủ từ chối vĩnh viễn / TemporaryFailure: lỗi tạm thời hoặc không rõ), maybeDelivered (Boolean: đúng khi lỗi xảy ra sau khi đã gửi nội dung thư), detail (mô tả ngắn cho log) | InvalidEmailMessageError (Nghiệp vụ nội bộ); Rejected (Nghiệp vụ, là giá trị trả về); TemporaryFailure (Kỹ thuật tạm thời hoặc Không rõ kết quả, là giá trị trả về) | UC-005 (bước 14); UC-006 (bước 7) | Dòng hàng đợi đã claim; giao dịch tạo dòng đã commit (không bao giờ gửi trong giao dịch, P09 F7.1); EmailMessage đã dựng đủ | Accepted: máy chủ thư đã nhận thư; thư chưa chắc đã tới hộp thư vì chuyển phát là việc của dịch vụ thư. Không đổi dữ liệu của hệ thống | Đồng bộ (bên gọi là công việc nền, không chặn người dùng) | Không bảo đảm: SMTP không loại trùng theo Message-ID; Message-ID giúp phía nhận loại trùng; chấp nhận gửi trùng hiếm (P09 F7.7); email không có tác dụng phụ tài chính nên được tự thử lại (A5) | 30 giây cho cả thư (P09 F7.7, P10 F2); kết nối tối đa 10 giây (Thiết kế: DNS, TCP, TLS thường dưới 10 giây, phần còn lại dành cho truyền thư) |

Phủ trách nhiệm của AC-B-EmailService: sendTicketsEmail và sendRefundNotificationEmail --> sendEmail.

## F4. Sequence diagram

File diagrams/P11b-subsystem-SS-02.drawio, 4 trang: S02B1 (hộp đen), S02W1 (hộp trắng), Phần tử, Phụ thuộc. Lời gọi tới máy chủ SMTP (kết nối, TLS, MAIL FROM, RCPT TO, DATA) là hiểu biết về giao thức SMTP chung, chưa kiểm với nhà cung cấp cụ thể (V-17).

### Trang "Hộp đen - sendEmail (UC-005 bước 14; UC-006 bước 7)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S02B1-L1 | Lifeline | :EmailOutboxJob | - | DC-EmailOutboxJob, PKG-20 | Lấy dòng hàng đợi đã claim, dựng EmailMessage, gọi IF-03 ngoài giao dịch |
| S02B1-L2 | Lifeline | :IF-03 IEmailSender | «interface» | SS-02 | Interface gửi email |
| S02B1-F1 | Fragment | alt [máy chủ thư chấp nhận] | - | - | Operand tiếp: [máy chủ thư từ chối vĩnh viễn]; [lỗi tạm thời hoặc không rõ đã giao]; [dữ liệu thư sai] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :EmailOutboxJob | :IF-03 IEmailSender | sendEmail(message) | Đồng bộ | - | UC-005 bước 14 (email vé); UC-006 bước 7 (email hoàn tiền) |
| 2 | :IF-03 IEmailSender | :EmailOutboxJob | EmailSendResult(Accepted) | Trả về | S02B1-F1 [máy chủ thư chấp nhận] | BR-89: đánh dấu thành công |
| 3 | :IF-03 IEmailSender | :EmailOutboxJob | EmailSendResult(Rejected) | Trả về | S02B1-F1 [máy chủ thư từ chối vĩnh viễn] | BR-89: không thử lại, ghi log lỗi, vé và khoản hoàn giữ hiệu lực (P04 UC-005 bước 14, UC-006 bước 7) |
| 4 | :IF-03 IEmailSender | :EmailOutboxJob | EmailSendResult(TemporaryFailure) | Trả về | S02B1-F1 [lỗi tạm thời hoặc không rõ đã giao] | BR-89: hẹn gửi lại sau 1, 5, 15 phút, tối đa 3 lần thử lại rồi ghi log lỗi |
| 5 | :IF-03 IEmailSender | :EmailOutboxJob | InvalidEmailMessageError | Trả về | S02B1-F1 [dữ liệu thư sai] | Không thử lại, ghi log lỗi |

### Trang "Hộp trắng - sendEmail"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S02W1 | Fragment | sd sendEmail | - | - | Khung sd; mọi lifeline nằm trong khung |
| S02W1-L1 | Lifeline | :EmailGatewayManager | - | DC-EmailGatewayManager | Điều phối, hiện thực IF-03 |
| S02W1-L2 | Lifeline | :MimeMessageBuilder | - | DC-MimeMessageBuilder | Chuyển đổi dữ liệu |
| S02W1-L3 | Lifeline | :SmtpClient | - | DC-SmtpClient | Giao tiếp ngoài |
| S02W1-L4 | Actor | :Máy chủ SMTP | - | ACT-08 | Dịch vụ email bên ngoài |
| S02W1-G1 | Gate | sendEmail | - | S02W1 | Gate của message 1 |
| S02W1-G3 | Gate | trả về InvalidEmailMessageError | - | S02W1 | Gate của message 3 |
| S02W1-G16 | Gate | trả về EmailSendResult | - | S02W1 | Gate của message 16 |
| S02W1-F1 | Fragment | alt [dữ liệu sai] | - | S02W1 | Một operand |
| S02W1-F2 | Fragment | alt [máy chủ trả mã thành công] | - | S02W1 | Operand tiếp: [máy chủ trả mã từ chối vĩnh viễn]; [mã tạm thời, mất kết nối hoặc hết thời gian] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :EmailGatewayManager | sendEmail(message) | Đồng bộ | - | IF-03; UC-005 bước 14; UC-006 bước 7 |
| 2 | :EmailGatewayManager | :EmailGatewayManager | validate(recipientAddress, subject, deduplicationKey) | Tự gọi | - | Kiểm định dạng địa chỉ (REQ-107), tiêu đề, khoá không rỗng |
| 3 | :EmailGatewayManager | Gate | InvalidEmailMessageError | Trả về | S02W1-F1 [dữ liệu sai] | - |
| 4 | :EmailGatewayManager | :MimeMessageBuilder | build(message) | Đồng bộ | - | - |
| 5 | :MimeMessageBuilder | :MimeMessageBuilder | compose(message) | Tự gọi | - | Message-ID từ deduplicationKey, nội dung UTF-8, ảnh mã QR nhúng trong thân thư [V-17] |
| 6 | :MimeMessageBuilder | :EmailGatewayManager | rawMime | Trả về | - | - |
| 7 | :EmailGatewayManager | :SmtpClient | deliver(rawMime, recipientAddress) | Đồng bộ | - | Ngoài giao dịch cơ sở dữ liệu, không giữ khoá |
| 8 | :SmtpClient | :Máy chủ SMTP | openSession(), chờ kết nối tối đa 10 giây | Đồng bộ | - | TLS, xác thực [V-17] |
| 9 | :SmtpClient | :Máy chủ SMTP | transmit(rawMime), tổng thời gian tối đa 30 giây | Đồng bộ | - | MAIL FROM, RCPT TO, DATA [V-17] |
| 10 | :Máy chủ SMTP | :SmtpClient | acceptedReply | Trả về | S02W1-F2 [máy chủ trả mã thành công] | - |
| 11 | :SmtpClient | :EmailGatewayManager | EmailSendResult(Accepted) | Trả về | S02W1-F2 [máy chủ trả mã thành công] | - |
| 12 | :Máy chủ SMTP | :SmtpClient | permanentRefusal | Trả về | S02W1-F2 [máy chủ trả mã từ chối vĩnh viễn] | - |
| 13 | :SmtpClient | :EmailGatewayManager | EmailSendResult(Rejected) | Trả về | S02W1-F2 [máy chủ trả mã từ chối vĩnh viễn] | - |
| 14 | :Máy chủ SMTP | :SmtpClient | temporaryRefusalOrTimeout | Trả về | S02W1-F2 [mã tạm thời, mất kết nối hoặc hết thời gian] | - |
| 15 | :SmtpClient | :EmailGatewayManager | EmailSendResult(TemporaryFailure) | Trả về | S02W1-F2 [mã tạm thời, mất kết nối hoặc hết thời gian] | maybeDelivered là đúng nếu lỗi xảy ra sau khi đã gửi nội dung thư |
| 16 | :EmailGatewayManager | Gate | EmailSendResult | Trả về | - | - |

## F5. Phần tử của subsystem

a) Bảng phần tử

| DC | Tên | Vai trò (Điều phối / Giao tiếp ngoài / Chuyển đổi dữ liệu / Lưu trữ trong subsystem / Kiểu dữ liệu / Ngoại lệ) | Trách nhiệm | Visibility | Hiện thực IF |
|---|---|---|---|---|---|
| DC-EmailGatewayManager | EmailGatewayManager | Điều phối | Nhận sendEmail; kiểm dữ liệu thư; gọi bộ dựng thư và máy khách SMTP; chuyển lỗi giao thức thành EmailSendResult | package-private | IF-03 |
| DC-MimeMessageBuilder | MimeMessageBuilder | Chuyển đổi dữ liệu | Đổi EmailMessage thành thư MIME UTF-8; đặt Message-ID từ khoá chống lặp; nhúng ảnh mã QR | package-private | - |
| DC-SmtpClient | SmtpClient | Giao tiếp ngoài | Mở phiên SMTP có TLS, gửi thư, giới hạn 10 giây kết nối và 30 giây toàn thư, phân loại mã trả lời thành thành công, từ chối vĩnh viễn, tạm thời | package-private | - |
| DC-SmtpConfig | SmtpConfig | Lưu trữ trong subsystem | Giữ máy chủ, cổng, chế độ TLS, tài khoản và mật khẩu (từ môi trường, không log), địa chỉ người gửi, miền của Message-ID | package-private | - |
| DC-EmailMessage | EmailMessage | Kiểu dữ liệu | recipientAddress, subject, body (HTML), attachments, deduplicationKey; dùng trong chữ ký if-03 | public | - |
| DC-EmailAttachment | EmailAttachment | Kiểu dữ liệu | name, mimeType, content, inline (true cho ảnh mã QR trong thân thư); dùng trong emailmessage | public | - |
| DC-EmailSendResult | EmailSendResult | Kiểu dữ liệu | status (Accepted / Rejected / TemporaryFailure), maybeDelivered (Boolean), detail (mô tả ngắn cho log); dùng trong chữ ký if-03 | public | - |
| DC-InvalidEmailMessageError | InvalidEmailMessageError | Ngoại lệ | Địa chỉ nhận sai định dạng, tiêu đề hoặc khoá chống lặp rỗng; dùng trong chữ ký if-03 | public | - |

Cấu hình địa chỉ và thông tin xác thực SMTP (Thiết kế: đọc từ biến môi trường khi khởi động, không đặt trong mã nguồn hay log vì thông tin xác thực không được lộ). Ghi nhật ký (Thiết kế: mỗi lần gửi ghi một dòng log gồm khoá chống lặp, trạng thái, mã trả lời; không ghi nội dung thư).

b) Class diagram phần tử (trang "Phần tử")

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| IF-03 | Interface | IEmailSender | «interface» | - | PKG-23 |
| SS-02 | Subsystem | EmailGateway | - | - | Chỉ interface là public |
| DC-EmailGatewayManager | Class | EmailGatewayManager | - | SS-02 | Hiện thực IF-03 |
| DC-MimeMessageBuilder | Class | MimeMessageBuilder | - | SS-02 | Chuyển đổi dữ liệu |
| DC-SmtpClient | Class | SmtpClient | - | SS-02 | Giao tiếp ngoài |
| DC-SmtpConfig | Class | SmtpConfig | - | SS-02 | Cấu hình |
| DC-EmailMessage | Class | EmailMessage | «value» | SS-02 | Kiểu dữ liệu (public) |
| DC-EmailAttachment | Class | EmailAttachment | «value» | SS-02 | Kiểu dữ liệu (public) |
| DC-EmailSendResult | Class | EmailSendResult | «value» | SS-02 | Kiểu dữ liệu (public) |
| DC-InvalidEmailMessageError | Class | InvalidEmailMessageError | «exception» | SS-02 | Ngoại lệ (public) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| C02-01 | DC-EmailGatewayManager | IF-03 | Realization | - | - |
| C02-02 | DC-EmailGatewayManager | DC-MimeMessageBuilder | Dependency | - | dựng thư |
| C02-03 | DC-EmailGatewayManager | DC-SmtpClient | Dependency | - | gửi |
| C02-04 | DC-SmtpClient | DC-SmtpConfig | Dependency | - | cấu hình |
| C02-05 | DC-MimeMessageBuilder | DC-SmtpConfig | Dependency | - | miền Message-ID |
| C02-06 | DC-EmailMessage | DC-EmailAttachment | Composition | 1 ở đầu nguồn; 0..* ở đầu đích | - |

## F6. Phụ thuộc subsystem

| Subsystem | Phụ thuộc vào (IF, SS, PKG) | Loại (Qua interface / Vào package) | Lý do | Đánh giá (Ưu tiên / Dùng thận trọng) |
|---|---|---|---|---|
| SS-02 EmailGateway | Không phụ thuộc subsystem hoặc package nào khác | - | P09 F6: PKG-23 không có cạnh phụ thuộc ra ngoài; dịch vụ email là hệ thống ngoài | Ưu tiên |

Phía client: PKG-20 phụ thuộc IF-03 (P10 F6).

Trang "Phụ thuộc"

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| PKG-20 | Package | PKG-20 Notification | - | - | Client IF-03: DC-EmailOutboxJob |
| IF-03 | Interface | IF-03 IEmailSender | «interface» | - | PKG-23 |
| SS-02 | Subsystem | EmailGateway | - | - | PKG-23; không phụ thuộc package nào khác |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| D02-01 | PKG-20 | IF-03 | Dependency | - | Qua interface |
| D02-02 | SS-02 | IF-03 | Realization | - | - |

## F7. Thiết kế xử lý lỗi và điểm kiểm tra

a) Bảng lỗi

| Operation | Tình huống lỗi | Loại | Phát hiện bằng | Xử lý trong subsystem (thử lại, tra cứu trạng thái, chuyển đổi ngoại lệ) | Kết quả trả cho client | Luồng P04 tương ứng | Q, ASM |
|---|---|---|---|---|---|---|---|
| sendEmail | Địa chỉ nhận sai định dạng, tiêu đề hoặc khoá chống lặp rỗng | Nghiệp vụ nội bộ | validate | Không gửi ra ngoài | InvalidEmailMessageError; bên gọi ghi log và đánh dấu hết lần thử vì kết quả không đổi theo lần thử | UC-005 ghi chú bước 14, UC-006 ghi chú bước 7 (BR-89: ghi log lỗi) | - |
| sendEmail | Máy chủ thư từ chối vĩnh viễn (mã 5xx, địa chỉ không tồn tại) | Nghiệp vụ | Mã trả lời | Không thử lại trong subsystem | EmailSendResult(Rejected); bên gọi không hẹn lại, ghi log lỗi; vé hoặc khoản hoàn giữ hiệu lực | BR-89 (P04 ghi "thử gửi lại vài lần"; lỗi vĩnh viễn không thử lại, Vấn đề còn mở 5) | - |
| sendEmail | Mã tạm thời (4xx), mất kết nối, DNS, TLS lỗi | Kỹ thuật tạm thời | Mã trả lời, ngoại lệ mạng | Không thử lại trong subsystem | EmailSendResult(TemporaryFailure, maybeDelivered = false); bên gọi hẹn lại sau 1, 5, 15 phút, tối đa 3 lần thử lại rồi ghi log lỗi (P09 F7.7) | BR-89 | - |
| sendEmail | Hết 30 giây hoặc ngắt kết nối sau khi đã gửi nội dung thư | Không rõ kết quả | Hết thời gian chờ | Không thử lại trong subsystem | EmailSendResult(TemporaryFailure, maybeDelivered = true); bên gọi thử lại như trên với cùng Message-ID; chấp nhận gửi trùng hiếm | BR-89 | V-17 |
| sendEmail | Hết lần thử | Kỹ thuật | Bên gọi đếm attempt_count | Ngoài subsystem: bên gọi ghi log lỗi | Không có; vé và khoản hoàn giữ nguyên hiệu lực, khách vẫn thấy vé trên màn hình và trong lịch sử (BR-89) | UC-005 ghi chú bước 14; UC-006 ghi chú bước 7 | - |

Cách bảo đảm không gửi trùng và không mất thư. Hàng đợi gửi (P09 F7.7) bảo đảm thư không mất khi bản backend chết: dòng hàng đợi được claim có hạn 60 giây rồi nhận lại. Subsystem làm việc gửi một lần cho mỗi lời gọi, gắn Message-ID cố định theo khoá chống lặp để phía nhận loại trùng khi có gửi lại; chặn gửi trùng tuyệt đối không bảo đảm được vì SMTP không có xác nhận chuyển phát hai pha, nên gửi trùng hiếm là chấp nhận được (email không có tác dụng phụ tài chính).

b) Điểm kiểm tra

| Điểm kiểm tra | Kết quả | Ghi chú |
|---|---|---|
| Mỗi interface subsystem cung cấp có realization | Đạt | IF-03 do DC-EmailGatewayManager |
| Mỗi interface subsystem dùng có phụ thuộc | Không áp dụng | SS-02 không dùng interface nào |
| Không phần tử bên trong nào public, trừ kiểu dữ liệu và ngoại lệ thuộc chữ ký interface | Đạt | Public: EmailMessage, EmailAttachment, EmailSendResult, InvalidEmailMessageError |
| Mỗi operation có sơ đồ hộp trắng hoặc ánh xạ 1-1 | Đạt | sendEmail có trang S02W1 |

## Câu hỏi mở

Ghi ở file chung.

## Giả định

Ghi ở file chung.

## Đề xuất sửa artifact trước

Ghi ở file chung.

## Vấn đề còn mở

Ghi ở file chung.
