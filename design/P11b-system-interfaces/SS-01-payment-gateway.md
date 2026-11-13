# P11b - SS-01 PaymentGateway - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 1.3 |
| Thay đổi 1.3 | Hoàn tiền: claim từng dòng, hàng rào claim_token, thời gian xử lý tối đa 80 giây, rủi ro tiến trình bị tạm dừng (RF-01); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3); P01-actors.md 1.2 (ACT-07); P04-uc-specs UC-005 1.11, UC-006 1.8, UC-008 1.8 (luồng thay thế, ngoại lệ có bước của cổng thanh toán); P06-supplementary-spec.md 1.3 (NFR-10, NFR-15, NFR-16, NFR-17); P07-uc-analysis UC-005 1.1, UC-006 1.1, UC-008 1.2 (message tới PaymentGateway); P08-analysis-model.md 1.5 (AC-B-PaymentGateway); P09-architecture.md 1.6 (F4, F6, F7.1, F7.6, F7.7, F11); P10-design-elements.md 1.4 (F2, F4, F5); TAI_LIEU_GIAO_TIEP: Không có |
| Phạm vi | SS-01 PaymentGateway (IF-01, IF-02) |
| Mã Q, ASM cuối đã cấp | Ghi ở file chung (Q-126 đến Q-132) |

Tên lời gọi tới cổng thanh toán trong sơ đồ hộp trắng (tham số vnp_..., mã trả lời) là hiểu biết về VNPay sandbox chưa kiểm với tài liệu, nên mỗi message liên quan có nhãn [V-nn] trỏ tới bảng "Điểm chưa kiểm với tài liệu hệ thống ngoài" ở file chung. Chữ ký interface không phụ thuộc các điểm đó.

## F1. Bối cảnh sử dụng

| UC | Control gọi (AC hoặc DC) | Message trong P07 (STT, tên) | Dữ liệu truyền | Luồng lỗi trong P04 |
|---|---|---|---|---|
| UC-005 Đặt vé | DC-BookTicketsService (AC-C-BookTicketsController) | 3.1.1 và 3.1.1.1 // createPaymentTransaction (bước 10) | Vào: tổng tiền, mã tham chiếu lần giữ ghế. Ra: P07 ghi "mã giao dịch"; thiết kế trả địa chỉ thanh toán đã ký, mã giao dịch do hệ thống sinh (Vấn đề còn mở 4) | Luồng 10a (BR-90) |
| UC-005 Đặt vé | DC-PaymentReportService (AC-C-PaymentReportController) | 4 và 4.1 // reportTransactionResult (thành công, bước 11); 4a và 4a.1 (thất bại, bước 11a) | Mã giao dịch, mã tham chiếu lần giữ ghế, số tiền đã thanh toán, kết quả, thời điểm nhận báo | Luồng 11a; báo thành công đến muộn xử lý ở UC-006 (BR-15) |
| UC-006 Hoàn tiền thanh toán đến muộn | DC-PaymentReportService | 1 và 1.1 // reportTransactionResult (bước 1) | như trên | Luồng 2a, 2b, 2c, 2d, 2e |
| UC-006 Hoàn tiền thanh toán đến muộn | DC-RefundService (gom từ AC-C-PaymentReportController, Q-106; do DC-RefundOutboxJob gọi) | 1.1.5, 1.1.5.1 // requestRefund và trả về (bước 4, 5) | Mã giao dịch, số tiền hoàn, khoá chống hoàn trùng | Luồng 4a, 4b, 5a, 5b |
| UC-008 Huỷ vé | DC-RefundService (gom từ AC-C-CancelTicketController) | 1.1.9, 1.1.9.1 // requestRefund và trả về (bước 5, 6); 1.1.7b.6 (luồng 5b); 1.1.9a.6 (luồng 6a) | Mã giao dịch, số tiền hoàn 70% (BR-19), khoá chống hoàn trùng (mã giao dịch kèm mã vé) | Luồng 5b, 5c, 6a, 6b |

Operation findRefund không có message P07: là operation kỹ thuật cần cho chính sách lỗi (Q-118, P09 F7.7). Câu trả lời cho cổng không thuộc SS-01: DC-PaymentCallbackController (PKG-12) dịch kết quả xử lý DC-IpnOutcome của PKG-14 sang định dạng của cổng (P10 F3, P09 F7.6).

## F2. Interface

| IF | Tên | Vai trò (một câu) | Bên hiện thực (SS; DC khi là interface gọi ngược) | Client (DC, PKG) | Package chứa |
|---|---|---|---|---|---|
| IF-01 | IPaymentGateway | Hệ thống gọi ra cổng thanh toán: tạo địa chỉ thanh toán đã ký, gửi hoàn tiền, tra cứu hoàn tiền | SS-01 | DC-BookTicketsService (PKG-13); DC-RefundService (PKG-14) | PKG-22 |
| IF-02 | IPaymentReportReceiver | Cổng thanh toán báo kết quả vào hệ thống: kiểm chữ ký, giải mã thông báo, dựng câu trả lời | SS-01 | DC-PaymentReportService (PKG-14) | PKG-22 |

IF-01 có 3 operation, IF-02 có 1 operation (mức hợp lý). Hai interface tách theo hai chiều và hai nhóm client: PKG-13 chỉ cần tạo địa chỉ thanh toán, không cần biết thông báo. Không có interface gọi ngược: thông báo đi xuống qua DC-PaymentReportService (P10 F2).

## F3. Operation

| IF | Tên | Hệ thống/thiết bị | Operation | Tham số vào | Kết quả | Lỗi / ngoại lệ | UC | Tiền điều kiện | Hậu điều kiện | Đồng bộ | Idempotent | Timeout |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| IF-01 | IPaymentGateway | Cổng thanh toán (ACT-07) | createPaymentTransaction(transactionId: String, holdReference: String, amount: Integer, expiresAt: DateTime, customerAddress: String): String | transactionId: String - mã giao dịch do hệ thống sinh, duy nhất; bản ghi PaymentTransaction ở trạng thái chờ đã commit (P09 F7.6)<br>holdReference: String - mã tham chiếu lần giữ ghế (REQ-136)<br>amount: Integer - số tiền chốt của lần giữ ghế, đơn vị đồng, lớn hơn 0<br>expiresAt: DateTime - thời điểm hết hạn lần giữ ghế (BR-10), sau thời điểm hiện tại<br>customerAddress: String - địa chỉ IP của trình duyệt khách | String paymentUrl: địa chỉ https tuyệt đối để chuyển trình duyệt khách sang trang thanh toán | GatewayConfigurationError (Kỹ thuật, không tạm thời); InvalidGatewayRequestError (Nghiệp vụ nội bộ: vi phạm tiền điều kiện) | UC-005 (bước 10) | Bản ghi PaymentTransaction chờ đã commit; lần giữ ghế còn Đang giữ; không có giao dịch cơ sở dữ liệu đang mở | Không đổi dữ liệu; cổng chưa được gọi qua mạng | Đồng bộ | Có (không tác dụng phụ; mỗi lần gọi trả địa chỉ khác nhau ở thời điểm tạo, mọi địa chỉ đều hợp lệ) | Không áp dụng: ký cục bộ, không gọi mạng (P09 F7.6) |
| IF-01 | IPaymentGateway | Cổng thanh toán (ACT-07) | requestRefund(refundKey: String, transactionId: String, paidAt: DateTime, originalAmount: Integer, refundAmount: Integer): RefundOutcome | refundKey: String - khoá chống hoàn trùng của yêu cầu hoàn, giữ nguyên qua mọi lần thử lại (BR-43)<br>transactionId: String - mã giao dịch của hệ thống<br>paidAt: DateTime - thời điểm thanh toán thành công (cổng yêu cầu khi hoàn, V-08)<br>originalAmount: Integer - số tiền đã thanh toán, đồng<br>refundAmount: Integer - số tiền hoàn, lớn hơn 0 và không vượt originalAmount; bằng originalAmount là hoàn toàn bộ | RefundOutcome: status (Succeeded: cổng xác nhận đã hoàn / Rejected: cổng từ chối rõ ràng và chưa thực hiện / Unknown: hết 30 giây, mất kết nối, trả lời sai chữ ký hoặc mã không nhận ra), gatewayRefundNo, reasonCode | InvalidGatewayRequestError (Nghiệp vụ nội bộ); GatewayConfigurationError (Kỹ thuật); Rejected (Nghiệp vụ, là giá trị trả về); Unknown (Không rõ kết quả, là giá trị trả về) | UC-006 (bước 4, 5); UC-008 (bước 5, 6) | RefundRequest và dòng hàng đợi đã commit và đã claim; không giữ khoá, không mở giao dịch trong lúc gọi (P09 F7.1, F7.7); từ lần thử thứ hai trở đi findRefund đã trả NotRefunded | Succeeded: cổng đã nhận hoàn refundAmount cho giao dịch; các giá trị khác: không có hoàn nào được xác nhận. Không đổi dữ liệu của hệ thống | Đồng bộ | Có với khoá, chưa xác nhận (Q-132; V-09, Q-118): bên gọi không tự gửi lại sau Unknown nếu chưa findRefund | 30 giây (BR-43, NFR-17) |
| IF-01 | IPaymentGateway | Cổng thanh toán (ACT-07) | findRefund(refundKey: String, transactionId: String, paidAt: DateTime): RefundLookup | refundKey: String - khoá của yêu cầu hoàn cần tra<br>transactionId: String - mã giao dịch của hệ thống<br>paidAt: DateTime - thời điểm thanh toán thành công | RefundLookup: status (Refunded: cổng cho biết yêu cầu hoàn đã thành công / NotRefunded: cổng cho biết rõ chưa có yêu cầu hoàn / NotSupported: cổng không có cách tra cứu / Unreachable: không trả lời trong 30 giây, sai chữ ký hoặc trạng thái không rõ), refundedAmount | InvalidGatewayRequestError (Nghiệp vụ nội bộ); Unreachable (Kỹ thuật tạm thời, là giá trị trả về) | UC-006 (luồng 4a, 5a); UC-008 (luồng 5b, 6a). Operation kỹ thuật: cần cho chính sách lỗi của Q-118 và P09 F7.7 (không gửi lại khi chưa biết đã hoàn hay chưa) | Như requestRefund | Không đổi dữ liệu | Đồng bộ | Có (chỉ đọc) | 30 giây (P09 F7.1; Thiết kế: cùng máy khách với hoàn tiền) |
| IF-02 | IPaymentReportReceiver | Cổng thanh toán (ACT-07) | reportTransactionResult(parameters: Map(String, String)): PaymentReport | parameters: Map(String, String) - các cặp tên-giá trị nguyên văn của thông báo (IPN hoặc địa chỉ trả về), không rỗng | PaymentReport: outcome (Succeeded / Failed), transactionId, gatewayTransactionNo, holdReference (có thể rỗng), amount (Integer, đồng), paidAt | InvalidSignatureError (Nghiệp vụ); MalformedReportError (Nghiệp vụ) | UC-005 (bước 11, 11a); UC-006 (bước 1) | Không | Không đổi dữ liệu. Số tiền chỉ được giải mã; việc so với bản ghi do DC-PaymentReportService làm vì SS-01 không đọc cơ sở dữ liệu | Đồng bộ | Có (thuần, không tác dụng phụ) | Không áp dụng: tính toán cục bộ |

Phủ trách nhiệm của AC-B-PaymentGateway (P08 F3): createPaymentTransaction --> operation cùng tên; reportTransactionResult --> operation cùng tên; requestRefund --> operation cùng tên. Kết quả hoàn tiền trả về trong lời gọi, không có callback riêng (Q-91).

## F4. Sequence diagram

File diagrams/P11b-subsystem-SS-01.drawio, 10 trang. Trang hộp đen: S01B1 đến S01B4; trang hộp trắng: S01W1 đến S01W4; trang Phần tử (F5) và Phụ thuộc (F6). Trong sơ đồ, "request" của lời gọi nội bộ là gói các tham số của operation tương ứng.

### Trang "Hộp đen - createPaymentTransaction (UC-005 bước 10)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01B1-L1 | Lifeline | :BookTicketsService | - | DC-BookTicketsService, PKG-13 | Control của UC-005 (AC-C-BookTicketsController) |
| S01B1-L2 | Lifeline | :IF-01 IPaymentGateway | «interface» | SS-01 | Interface gọi ra |
| S01B1-F1 | Fragment | alt [tạo được địa chỉ thanh toán] | - | - | Operand tiếp: [thiếu cấu hình khoá của cổng]; [tham số sai (số tiền, hạn, mã rỗng)] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :BookTicketsService | :IF-01 IPaymentGateway | createPaymentTransaction(transactionId, holdReference, amount, expiresAt, customerAddress) | Đồng bộ | - | UC-005 bước 10 |
| 2 | :IF-01 IPaymentGateway | :BookTicketsService | paymentUrl | Trả về | S01B1-F1 [tạo được địa chỉ thanh toán] | UC-005 bước 10 (khách được chuyển sang cổng) |
| 3 | :IF-01 IPaymentGateway | :BookTicketsService | GatewayConfigurationError | Trả về | S01B1-F1 [thiếu cấu hình khoá của cổng] | UC-005 luồng 10a, BR-90 (giữ nguyên lần giữ ghế, báo chưa tạo được thanh toán) |
| 4 | :IF-01 IPaymentGateway | :BookTicketsService | InvalidGatewayRequestError | Trả về | S01B1-F1 [tham số sai (số tiền, hạn, mã rỗng)] | Lỗi lập trình bên gọi, không có luồng P04; xử lý như 10a |

### Trang "Hộp đen - Báo kết quả giao dịch (UC-005 bước 11, 11a; UC-006 bước 1)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01B2-L1 | Lifeline | :PaymentReportService | - | DC-PaymentReportService, PKG-14 | Nhận từ DC-PaymentCallbackController (PKG-12) và từ điểm vào địa chỉ trả về |
| S01B2-L2 | Lifeline | :IF-02 IPaymentReportReceiver | «interface» | SS-01 | Interface nhận thông báo |
| S01B2-F1 | Fragment | alt [chữ ký hợp lệ, đủ tham số] | - | - | Operand tiếp: [chữ ký sai]; [thiếu tham số hoặc số tiền không là số] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :PaymentReportService | :IF-02 IPaymentReportReceiver | reportTransactionResult(parameters) | Đồng bộ | - | UC-005 bước 11, 11a; UC-006 bước 1 |
| 2 | :IF-02 IPaymentReportReceiver | :PaymentReportService | PaymentReport | Trả về | S01B2-F1 [chữ ký hợp lệ, đủ tham số] | UC-005 bước 11; UC-006 bước 1 (mã giao dịch, mã tham chiếu lần giữ ghế, số tiền, kết quả) |
| 3 | :IF-02 IPaymentReportReceiver | :PaymentReportService | InvalidSignatureError | Trả về | S01B2-F1 [chữ ký sai] | Không có luồng P04 riêng: không ghi gì, cổng nhận lỗi |
| 4 | :IF-02 IPaymentReportReceiver | :PaymentReportService | MalformedReportError | Trả về | S01B2-F1 [thiếu tham số hoặc số tiền không là số] | Không có luồng P04 riêng: không ghi gì, cổng nhận lỗi |

### Trang "Hộp đen - requestRefund (UC-006 bước 4, 5; UC-008 bước 5, 6)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01B3-L1 | Lifeline | :RefundService | - | DC-RefundService, PKG-14 | Do DC-RefundOutboxJob gọi (EX-10); không giữ khoá, không mở giao dịch trong lúc chờ |
| S01B3-L2 | Lifeline | :IF-01 IPaymentGateway | «interface» | SS-01 | Interface gọi ra |
| S01B3-F1 | Fragment | alt [cổng xác nhận đã hoàn] | - | - | Operand tiếp: [cổng từ chối rõ ràng]; [hết 30 giây hoặc kết quả không rõ]; [tham số sai] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :RefundService | :IF-01 IPaymentGateway | requestRefund(refundKey, transactionId, paidAt, originalAmount, refundAmount) | Đồng bộ | - | UC-006 bước 4; UC-008 bước 5 |
| 2 | :IF-01 IPaymentGateway | :RefundService | RefundOutcome(Succeeded) | Trả về | S01B3-F1 [cổng xác nhận đã hoàn] | UC-006 bước 5; UC-008 bước 6 |
| 3 | :IF-01 IPaymentGateway | :RefundService | RefundOutcome(Rejected) | Trả về | S01B3-F1 [cổng từ chối rõ ràng] | UC-006 luồng 5a, 5b; UC-008 luồng 6a, 6b |
| 4 | :IF-01 IPaymentGateway | :RefundService | RefundOutcome(Unknown) | Trả về | S01B3-F1 [hết 30 giây hoặc kết quả không rõ] | UC-006 luồng 4a, 4b; UC-008 luồng 5b, 5c (Q-127) |
| 5 | :IF-01 IPaymentGateway | :RefundService | InvalidGatewayRequestError | Trả về | S01B3-F1 [tham số sai] | Lỗi lập trình bên gọi |

### Trang "Hộp đen - findRefund trước khi gửi lại (UC-006 bước 4; UC-008 bước 5)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01B4-L1 | Lifeline | :RefundService | - | DC-RefundService, PKG-14 | Lần thử thứ hai trở đi hoặc sau kết quả Unknown (P09 F7.7) |
| S01B4-L2 | Lifeline | :IF-01 IPaymentGateway | «interface» | SS-01 | Interface gọi ra |
| S01B4-F1 | Fragment | alt [đã hoàn] | - | - | Operand tiếp: [chưa hoàn]; [cổng không có tra cứu hoặc không trả lời] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :RefundService | :IF-01 IPaymentGateway | findRefund(refundKey, transactionId, paidAt) | Đồng bộ | - | UC-006 luồng 4a, 5a; UC-008 luồng 5b, 6a |
| 2 | :IF-01 IPaymentGateway | :RefundService | RefundLookup(Refunded) | Trả về | S01B4-F1 [đã hoàn] | Ghi nhận đã hoàn, không gửi lại (UC-006 bước 6; UC-008 bước 8) |
| 3 | :IF-01 IPaymentGateway | :RefundService | RefundLookup(NotRefunded) | Trả về | S01B4-F1 [chưa hoàn] | Được phép gửi lại |
| 4 | :RefundService | :IF-01 IPaymentGateway | requestRefund(refundKey, transactionId, paidAt, originalAmount, refundAmount) | Đồng bộ | S01B4-F1 [chưa hoàn] | UC-006 bước 4 (lượt thử lại) |
| 5 | :IF-01 IPaymentGateway | :RefundService | RefundOutcome | Trả về | S01B4-F1 [chưa hoàn] | Như sơ đồ S01B3 |
| 6 | :IF-01 IPaymentGateway | :RefundService | RefundLookup(Unavailable) | Trả về | S01B4-F1 [cổng không có tra cứu hoặc không trả lời] | Không gửi lại tự động (Q-118): hẹn tra cứu lại hoặc Cần xử lý thủ công, UC-006 luồng 4b, 5b; UC-008 luồng 5c, 6b |

### Trang "Hộp trắng - createPaymentTransaction"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01W1 | Fragment | sd createPaymentTransaction | - | - | Khung sd; mọi lifeline nằm trong khung |
| S01W1-L1 | Lifeline | :PaymentGatewayManager | - | DC-PaymentGatewayManager | Điều phối, hiện thực IF-01 |
| S01W1-L2 | Lifeline | :VnpayUrlBuilder | - | DC-VnpayUrlBuilder | Chuyển đổi dữ liệu |
| S01W1-L3 | Lifeline | :VnpaySigner | - | DC-VnpaySigner | Chuyển đổi dữ liệu |
| S01W1-L4 | Lifeline | :GatewayConfig | - | DC-GatewayConfig | Cấu hình |
| S01W1-G1 | Gate | createPaymentTransaction | - | S01W1 | Gate của message 1 |
| S01W1-G3 | Gate | trả về InvalidGatewayRequestError | - | S01W1 | Gate của message 3 |
| S01W1-G12 | Gate | trả về paymentUrl | - | S01W1 | Gate của message 12 |
| S01W1-F1 | Fragment | alt [tham số sai] | - | S01W1 | Một operand |
| S01W1-F2 | Fragment | alt [thiếu khoá hoặc mã đơn vị] | - | S01W1 | Operand tiếp: [đủ cấu hình] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :PaymentGatewayManager | createPaymentTransaction(transactionId, holdReference, amount, expiresAt, customerAddress) | Đồng bộ | - | IF-01; UC-005 bước 10 |
| 2 | :PaymentGatewayManager | :PaymentGatewayManager | validate(amount > 0, expiresAt > now, mã không rỗng) | Tự gọi | - | Kiểm tham số |
| 3 | :PaymentGatewayManager | Gate | InvalidGatewayRequestError | Trả về | S01W1-F1 [tham số sai] | Lỗi lập trình bên gọi |
| 4 | :PaymentGatewayManager | :GatewayConfig | paymentSettings() | Đồng bộ | - | Đọc mã đơn vị, khoá ký, địa chỉ cổng, địa chỉ trả về |
| 5 | :GatewayConfig | :PaymentGatewayManager | GatewayConfigurationError | Trả về | S01W1-F2 [thiếu khoá hoặc mã đơn vị] | UC-005 luồng 10a |
| 6 | :GatewayConfig | :PaymentGatewayManager | settings | Trả về | S01W1-F2 [đủ cấu hình] | - |
| 7 | :PaymentGatewayManager | :VnpayUrlBuilder | buildPaymentUrl(settings, request) | Đồng bộ | - | request gồm transactionId, holdReference, amount, expiresAt, customerAddress; NFR-15; REQ-136 [V-01] |
| 8 | :VnpayUrlBuilder | :VnpayUrlBuilder | composeParameters(request, settings) | Tự gọi | - | Số tiền nhân 100, mã tham chiếu giao dịch là transactionId, thông tin đơn hàng mang holdReference, hạn thanh toán là expiresAt [V-01, V-03, V-06, V-07] |
| 9 | :VnpayUrlBuilder | :VnpaySigner | sign(sortedQuery) | Đồng bộ | - | HMAC-SHA512 [V-02] |
| 10 | :VnpaySigner | :VnpayUrlBuilder | secureHash | Trả về | - | - |
| 11 | :VnpayUrlBuilder | :PaymentGatewayManager | paymentUrl | Trả về | - | - |
| 12 | :PaymentGatewayManager | Gate | paymentUrl | Trả về | - | Không gọi mạng |

### Trang "Hộp trắng - reportTransactionResult"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01W2 | Fragment | sd reportTransactionResult | - | - | Khung sd; mọi lifeline nằm trong khung |
| S01W2-L1 | Lifeline | :PaymentReportReceiver | - | DC-PaymentReportReceiver | Điều phối, hiện thực IF-02 |
| S01W2-L2 | Lifeline | :VnpaySigner | - | DC-VnpaySigner | Chuyển đổi dữ liệu |
| S01W2-L3 | Lifeline | :VnpayReportDecoder | - | DC-VnpayReportDecoder | Chuyển đổi dữ liệu |
| S01W2-G1 | Gate | reportTransactionResult | - | S01W2 | Gate của message 1 |
| S01W2-G4 | Gate | trả về InvalidSignatureError | - | S01W2 | Gate của message 4 |
| S01W2-G9 | Gate | trả về MalformedReportError | - | S01W2 | Gate của message 9 |
| S01W2-G11 | Gate | trả về PaymentReport | - | S01W2 | Gate của message 11 |
| S01W2-F1 | Fragment | alt [chữ ký sai hoặc thiếu] | - | S01W2 | Operand tiếp: [chữ ký đúng] |
| S01W2-F2 | Fragment | alt [thiếu tham số bắt buộc hoặc số tiền không là số] | - | S01W2 | Operand tiếp: [đủ và hợp lệ] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :PaymentReportReceiver | reportTransactionResult(parameters) | Đồng bộ | - | IF-02; UC-005 bước 11, 11a; UC-006 bước 1 |
| 2 | :PaymentReportReceiver | :VnpaySigner | verifySignature(parameters) | Đồng bộ | - | So sánh thời gian hằng, bỏ vnp_SecureHash khỏi chuỗi ký [V-02] |
| 3 | :VnpaySigner | :PaymentReportReceiver | false | Trả về | S01W2-F1 [chữ ký sai hoặc thiếu] | - |
| 4 | :PaymentReportReceiver | Gate | InvalidSignatureError | Trả về | S01W2-F1 [chữ ký sai hoặc thiếu] | DC-PaymentReportService trả DC-IpnOutcome INVALID_SIGNATURE, PKG-12 dịch sang RspCode 97 |
| 5 | :VnpaySigner | :PaymentReportReceiver | true | Trả về | S01W2-F1 [chữ ký đúng] | - |
| 6 | :PaymentReportReceiver | :VnpayReportDecoder | decode(parameters) | Đồng bộ | S01W2-F1 [chữ ký đúng] | Tách mã giao dịch, mã tham chiếu lần giữ ghế, số tiền, kết quả |
| 7 | :VnpayReportDecoder | :VnpayReportDecoder | parse(parameters) | Tự gọi | S01W2-F1 [chữ ký đúng] | Số tiền chia 100, thời điểm múi giờ GMT+7, kết quả suy từ mã phản hồi và trạng thái giao dịch [V-03, V-05, V-15] |
| 8 | :VnpayReportDecoder | :PaymentReportReceiver | MalformedReportError | Trả về | S01W2-F2 [thiếu tham số bắt buộc hoặc số tiền không là số] | - |
| 9 | :PaymentReportReceiver | Gate | MalformedReportError | Trả về | S01W2-F2 [thiếu tham số bắt buộc hoặc số tiền không là số] | DC-PaymentReportService trả DC-IpnOutcome MALFORMED, PKG-12 dịch sang RspCode 99 [V-04] |
| 10 | :VnpayReportDecoder | :PaymentReportReceiver | PaymentReport | Trả về | S01W2-F2 [đủ và hợp lệ] | - |
| 11 | :PaymentReportReceiver | Gate | PaymentReport | Trả về | S01W2-F2 [đủ và hợp lệ] | Số tiền chỉ được giải mã ở đây, so với bản ghi do DC-PaymentReportService |

### Trang "Hộp trắng - requestRefund"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01W3 | Fragment | sd requestRefund | - | - | Khung sd; mọi lifeline nằm trong khung |
| S01W3-L1 | Lifeline | :PaymentGatewayManager | - | DC-PaymentGatewayManager | Điều phối, hiện thực IF-01 |
| S01W3-L2 | Lifeline | :VnpayRefundClient | - | DC-VnpayRefundClient | Giao tiếp ngoài |
| S01W3-L3 | Lifeline | :VnpaySigner | - | DC-VnpaySigner | Chuyển đổi dữ liệu |
| S01W3-L4 | Actor | :Cổng thanh toán VNPay | - | ACT-07 | Hệ thống ngoài (sandbox) |
| S01W3-G1 | Gate | requestRefund | - | S01W3 | Gate của message 1 |
| S01W3-G3 | Gate | trả về InvalidGatewayRequestError | - | S01W3 | Gate của message 3 |
| S01W3-G16 | Gate | trả về RefundOutcome | - | S01W3 | Gate của message 16 |
| S01W3-F1 | Fragment | alt [tham số sai] | - | S01W3 | Một operand |
| S01W3-F2 | Fragment | alt [có trả lời trong 30 giây] | - | S01W3 | Operand tiếp: [hết 30 giây hoặc mất kết nối sau khi gửi] |
| S01W3-F3 | Fragment | alt [hợp lệ và mã thành công] | - | S01W3 | Operand tiếp: [hợp lệ và mã từ chối xác định]; [chữ ký sai hoặc mã không nhận ra] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :PaymentGatewayManager | requestRefund(refundKey, transactionId, paidAt, originalAmount, refundAmount) | Đồng bộ | - | IF-01; UC-006 bước 4; UC-008 bước 5 |
| 2 | :PaymentGatewayManager | :PaymentGatewayManager | validate(0 < refundAmount <= originalAmount) | Tự gọi | - | Kiểm tham số |
| 3 | :PaymentGatewayManager | Gate | InvalidGatewayRequestError | Trả về | S01W3-F1 [tham số sai] | Lỗi lập trình bên gọi |
| 4 | :PaymentGatewayManager | :VnpayRefundClient | refund(request) | Đồng bộ | - | request gồm refundKey, transactionId, paidAt, originalAmount, refundAmount |
| 5 | :VnpayRefundClient | :VnpayRefundClient | composeBody(request) | Tự gọi | - | requestId suy ra từ refundKey, loại toàn phần hoặc một phần theo refundAmount so với originalAmount [V-08, V-09] |
| 6 | :VnpayRefundClient | :VnpaySigner | sign(refundFields) | Đồng bộ | - | [V-08] |
| 7 | :VnpaySigner | :VnpayRefundClient | secureHash | Trả về | - | - |
| 8 | :VnpayRefundClient | :Cổng thanh toán VNPay | submitRefund(body), chờ tối đa 30 giây | Đồng bộ | - | NFR-17, BR-43 [V-08] |
| 9 | :Cổng thanh toán VNPay | :VnpayRefundClient | refundAnswer(responseCode, secureHash) | Trả về | S01W3-F2 [có trả lời trong 30 giây] | [V-10] |
| 10 | :VnpayRefundClient | :VnpaySigner | verify(refundAnswer) | Đồng bộ | S01W3-F2 [có trả lời trong 30 giây] | [V-13] |
| 11 | :VnpaySigner | :VnpayRefundClient | valid | Trả về | S01W3-F2 [có trả lời trong 30 giây] | - |
| 12 | :VnpayRefundClient | :PaymentGatewayManager | RefundOutcome(Succeeded) | Trả về | S01W3-F3 [hợp lệ và mã thành công] | - |
| 13 | :VnpayRefundClient | :PaymentGatewayManager | RefundOutcome(Rejected) | Trả về | S01W3-F3 [hợp lệ và mã từ chối xác định] | Chỉ các mã đã liệt kê là chưa thực hiện [V-10] |
| 14 | :VnpayRefundClient | :PaymentGatewayManager | RefundOutcome(Unknown) | Trả về | S01W3-F3 [chữ ký sai hoặc mã không nhận ra] | Không đoán là chưa hoàn |
| 15 | :VnpayRefundClient | :PaymentGatewayManager | RefundOutcome(Unknown) | Trả về | S01W3-F2 [hết 30 giây hoặc mất kết nối sau khi gửi] | Không thử lại trong subsystem |
| 16 | :PaymentGatewayManager | Gate | RefundOutcome | Trả về | - | - |

### Trang "Hộp trắng - findRefund"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S01W4 | Fragment | sd findRefund | - | - | Khung sd; mọi lifeline nằm trong khung |
| S01W4-L1 | Lifeline | :PaymentGatewayManager | - | DC-PaymentGatewayManager | Điều phối, hiện thực IF-01 |
| S01W4-L2 | Lifeline | :VnpayRefundClient | - | DC-VnpayRefundClient | Giao tiếp ngoài |
| S01W4-L3 | Lifeline | :VnpaySigner | - | DC-VnpaySigner | Chuyển đổi dữ liệu |
| S01W4-L4 | Actor | :Cổng thanh toán VNPay | - | ACT-07 | Hệ thống ngoài (sandbox) |
| S01W4-G1 | Gate | findRefund | - | S01W4 | Gate của message 1 |
| S01W4-G14 | Gate | trả về RefundLookup | - | S01W4 | Gate của message 14 |
| S01W4-F1 | Fragment | alt [cấu hình ghi cổng không có tra cứu hoàn] | - | S01W4 | Operand tiếp: [có tra cứu] |
| S01W4-F2 | Fragment | alt [có trả lời trong 30 giây] | - | S01W4 | Operand tiếp: [hết 30 giây] |
| S01W4-F3 | Fragment | alt [hợp lệ và trạng thái là đã hoàn] | - | S01W4 | Operand tiếp: [hợp lệ và trạng thái là chưa hoàn xác định]; [chữ ký sai hoặc trạng thái không rõ] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :PaymentGatewayManager | findRefund(refundKey, transactionId, paidAt) | Đồng bộ | - | IF-01; UC-006 luồng 4a, 5a; UC-008 luồng 5b, 6a |
| 2 | :PaymentGatewayManager | :VnpayRefundClient | lookup(refundKey, transactionId, paidAt) | Đồng bộ | - | - |
| 3 | :VnpayRefundClient | :PaymentGatewayManager | RefundLookup(NotSupported) | Trả về | S01W4-F1 [cấu hình ghi cổng không có tra cứu hoàn] | Q-118: bên gọi chuyển Cần xử lý thủ công [V-11] |
| 4 | :VnpayRefundClient | :VnpaySigner | sign(queryFields) | Đồng bộ | S01W4-F1 [có tra cứu] | [V-11] |
| 5 | :VnpaySigner | :VnpayRefundClient | secureHash | Trả về | S01W4-F1 [có tra cứu] | - |
| 6 | :VnpayRefundClient | :Cổng thanh toán VNPay | submitQuery(body), chờ tối đa 30 giây | Đồng bộ | S01W4-F1 [có tra cứu] | [V-11] |
| 7 | :Cổng thanh toán VNPay | :VnpayRefundClient | queryAnswer(status, secureHash) | Trả về | S01W4-F2 [có trả lời trong 30 giây] | [V-11] |
| 8 | :VnpayRefundClient | :VnpaySigner | verify(queryAnswer) | Đồng bộ | S01W4-F2 [có trả lời trong 30 giây] | [V-13] |
| 9 | :VnpaySigner | :VnpayRefundClient | valid | Trả về | S01W4-F2 [có trả lời trong 30 giây] | - |
| 10 | :VnpayRefundClient | :PaymentGatewayManager | RefundLookup(Refunded) | Trả về | S01W4-F3 [hợp lệ và trạng thái là đã hoàn] | - |
| 11 | :VnpayRefundClient | :PaymentGatewayManager | RefundLookup(NotRefunded) | Trả về | S01W4-F3 [hợp lệ và trạng thái là chưa hoàn xác định] | Chỉ khi cổng nói rõ chưa có yêu cầu hoàn [V-11] |
| 12 | :VnpayRefundClient | :PaymentGatewayManager | RefundLookup(Unreachable) | Trả về | S01W4-F3 [chữ ký sai hoặc trạng thái không rõ] | - |
| 13 | :VnpayRefundClient | :PaymentGatewayManager | RefundLookup(Unreachable) | Trả về | S01W4-F2 [hết 30 giây] | - |
| 14 | :PaymentGatewayManager | Gate | RefundLookup | Trả về | - | - |

## F5. Phần tử của subsystem

a) Bảng phần tử

| DC | Tên | Vai trò (Điều phối / Giao tiếp ngoài / Chuyển đổi dữ liệu / Lưu trữ trong subsystem / Kiểu dữ liệu / Ngoại lệ) | Trách nhiệm | Visibility | Hiện thực IF |
|---|---|---|---|---|---|
| DC-PaymentGatewayManager | PaymentGatewayManager | Điều phối | Nhận createPaymentTransaction, requestRefund, findRefund; kiểm tham số; điều phối bộ dựng URL, máy khách hoàn tiền; chuyển lỗi nội bộ thành kết quả hoặc ngoại lệ của interface | package-private | IF-01 |
| DC-PaymentReportReceiver | PaymentReportReceiver | Điều phối | Nhận reportTransactionResult (kiểm chữ ký, giải mã) | package-private | IF-02 |
| DC-VnpayUrlBuilder | VnpayUrlBuilder | Chuyển đổi dữ liệu | Dựng tập tham số thanh toán (số tiền nhân 100, mã tham chiếu giao dịch, thông tin đơn hàng chứa mã tham chiếu lần giữ ghế, hạn thanh toán, ngôn ngữ, đơn vị tiền), sắp theo tên, ghép địa chỉ và chữ ký | package-private | - |
| DC-VnpaySigner | VnpaySigner | Chuyển đổi dữ liệu | Ký chuỗi tham số bằng HMAC-SHA512 và kiểm chữ ký bằng so sánh thời gian hằng; dùng cho URL, thông báo, yêu cầu và trả lời của hoàn tiền, tra cứu | package-private | - |
| DC-VnpayReportDecoder | VnpayReportDecoder | Chuyển đổi dữ liệu | Đổi tập tham số thông báo thành PaymentReport: số tiền chia 100, thời điểm múi giờ GMT+7, kết quả suy từ mã phản hồi và trạng thái giao dịch | package-private | - |
| DC-VnpayRefundClient | VnpayRefundClient | Giao tiếp ngoài | Gửi yêu cầu hoàn tiền và tra cứu tới cổng bằng HTTPS, thời gian chờ 30 giây, ánh xạ mã trả lời sang RefundOutcome và RefundLookup theo bảng mã (mã lạ là Unknown hoặc Unreachable) | package-private | - |
| DC-GatewayConfig | GatewayConfig | Lưu trữ trong subsystem | Giữ mã đơn vị, khoá ký, địa chỉ trang thanh toán, địa chỉ API, địa chỉ trả về, cờ cổng có tra cứu hoàn; đọc từ biến môi trường, không ghi log, không lưu thông tin thẻ (NFR-10) | package-private | - |
| DC-PaymentReport | PaymentReport | Kiểu dữ liệu | Kết quả thông báo: outcome (Succeeded / Failed), transactionId, gatewayTransactionNo, holdReference (có thể rỗng), amount, paidAt (có thể rỗng); dùng trong chữ ký if-02 | public | - |
| DC-RefundOutcome | RefundOutcome | Kiểu dữ liệu | status (Succeeded / Rejected / Unknown), gatewayRefundNo (có thể rỗng), reasonCode (mã tóm tắt trung lập, có thể rỗng); dùng trong chữ ký if-01 | public | - |
| DC-RefundLookup | RefundLookup | Kiểu dữ liệu | status (Refunded / NotRefunded / NotSupported / Unreachable), refundedAmount (có thể rỗng); dùng trong chữ ký if-01 | public | - |
| DC-InvalidGatewayRequestError | InvalidGatewayRequestError | Ngoại lệ | Tham số của bên gọi vi phạm tiền điều kiện (số tiền, hạn, mã rỗng, số hoàn lớn hơn số đã thanh toán); dùng trong chữ ký if-01 | public | - |
| DC-GatewayConfigurationError | GatewayConfigurationError | Ngoại lệ | Thiếu hoặc sai cấu hình bắt buộc của cổng; dùng trong chữ ký if-01 | public | - |
| DC-InvalidSignatureError | InvalidSignatureError | Ngoại lệ | Chữ ký của thông báo không khớp; dùng trong chữ ký if-02 | public | - |
| DC-MalformedReportError | MalformedReportError | Ngoại lệ | Thông báo thiếu tham số bắt buộc hoặc số tiền không là số; dùng trong chữ ký if-02 | public | - |

b) Class diagram phần tử (trang "Phần tử")

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| IF-01 | Interface | IPaymentGateway | «interface» | - | Gọi ra; PKG-22 |
| IF-02 | Interface | IPaymentReportReceiver | «interface» | - | Nhận thông báo; PKG-22 |
| SS-01 | Subsystem | PaymentGateway | - | - | Chỉ interface là public |
| DC-PaymentGatewayManager | Class | PaymentGatewayManager | - | SS-01 | Hiện thực IF-01 |
| DC-PaymentReportReceiver | Class | PaymentReportReceiver | - | SS-01 | Hiện thực IF-02 |
| DC-VnpayUrlBuilder | Class | VnpayUrlBuilder | - | SS-01 | Chuyển đổi dữ liệu |
| DC-VnpayRefundClient | Class | VnpayRefundClient | - | SS-01 | Giao tiếp ngoài |
| DC-GatewayConfig | Class | GatewayConfig | - | SS-01 | Cấu hình |
| DC-VnpaySigner | Class | VnpaySigner | - | SS-01 | Chuyển đổi dữ liệu |
| DC-VnpayReportDecoder | Class | VnpayReportDecoder | - | SS-01 | Chuyển đổi dữ liệu |
| DC-PaymentReport | Class | PaymentReport | «value» | SS-01 | Kiểu dữ liệu (public) |
| DC-RefundOutcome | Class | RefundOutcome | «value» | SS-01 | Kiểu dữ liệu (public) |
| DC-RefundLookup | Class | RefundLookup | «value» | SS-01 | Kiểu dữ liệu (public) |
| DC-InvalidGatewayRequestError | Class | InvalidGatewayRequestError | «exception» | SS-01 | Ngoại lệ (public) |
| DC-GatewayConfigurationError | Class | GatewayConfigurationError | «exception» | SS-01 | Ngoại lệ (public) |
| DC-InvalidSignatureError | Class | InvalidSignatureError | «exception» | SS-01 | Ngoại lệ (public) |
| DC-MalformedReportError | Class | MalformedReportError | «exception» | SS-01 | Ngoại lệ (public) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| C01-01 | DC-PaymentGatewayManager | IF-01 | Realization | - | - |
| C01-02 | DC-PaymentReportReceiver | IF-02 | Realization | - | - |
| C01-03 | DC-PaymentGatewayManager | DC-VnpayUrlBuilder | Dependency | - | dựng URL |
| C01-04 | DC-PaymentGatewayManager | DC-VnpayRefundClient | Dependency | - | hoàn tiền, tra cứu |
| C01-05 | DC-PaymentGatewayManager | DC-GatewayConfig | Dependency | - | đọc cấu hình |
| C01-06 | DC-VnpayUrlBuilder | DC-VnpaySigner | Dependency | - | ký |
| C01-07 | DC-VnpayRefundClient | DC-VnpaySigner | Dependency | - | ký và kiểm |
| C01-08 | DC-VnpayRefundClient | DC-GatewayConfig | Dependency | - | địa chỉ, thời gian chờ |
| C01-09 | DC-PaymentReportReceiver | DC-VnpaySigner | Dependency | - | kiểm chữ ký |
| C01-10 | DC-PaymentReportReceiver | DC-VnpayReportDecoder | Dependency | - | giải mã |

Kiểu và ngoại lệ không vẽ cạnh tới lớp dùng chúng; chữ ký ở F3 đã nêu nơi dùng.

## F6. Phụ thuộc subsystem

| Subsystem | Phụ thuộc vào (IF, SS, PKG) | Loại (Qua interface / Vào package) | Lý do | Đánh giá (Ưu tiên / Dùng thận trọng) |
|---|---|---|---|---|
| SS-01 PaymentGateway | Không phụ thuộc subsystem hoặc package nào khác | - | P09 F6: PKG-22 không có cạnh phụ thuộc ra ngoài; mọi dữ liệu vào qua tham số của interface; cổng thanh toán là hệ thống ngoài, không là package | Ưu tiên |

Phía client: PKG-13 và PKG-14 phụ thuộc IF-01; PKG-14 phụ thuộc IF-02 (P10 F6); không client nào chạm lớp bên trong.

Trang "Phụ thuộc"

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| PKG-13 | Package | PKG-13 SeatBooking | - | - | Client IF-01: DC-BookTicketsService |
| PKG-14 | Package | PKG-14 PaymentRefund | - | - | Client IF-01, IF-02: DC-RefundService, DC-PaymentReportService |
| IF-01 | Interface | IF-01 IPaymentGateway | «interface» | - | PKG-22 |
| IF-02 | Interface | IF-02 IPaymentReportReceiver | «interface» | - | PKG-22 |
| SS-01 | Subsystem | PaymentGateway | - | - | PKG-22; không phụ thuộc package nào khác |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| D01-01 | PKG-13 | IF-01 | Dependency | - | Qua interface |
| D01-02 | PKG-14 | IF-01 | Dependency | - | Qua interface |
| D01-03 | PKG-14 | IF-02 | Dependency | - | Qua interface |
| D01-04 | SS-01 | IF-01 | Realization | - | - |
| D01-05 | SS-01 | IF-02 | Realization | - | - |

## F7. Thiết kế xử lý lỗi và điểm kiểm tra

a) Bảng lỗi

| Operation | Tình huống lỗi | Loại | Phát hiện bằng | Xử lý trong subsystem (thử lại, tra cứu trạng thái, chuyển đổi ngoại lệ) | Kết quả trả cho client | Luồng P04 tương ứng | Q, ASM |
|---|---|---|---|---|---|---|---|
| createPaymentTransaction | Thiếu hoặc sai khoá ký, mã đơn vị | Kỹ thuật, không tạm thời | Kiểm cấu hình khi gọi | Không thử lại; ghi log không kèm khoá | GatewayConfigurationError | UC-005 luồng 10a (BR-90): giữ nguyên lần giữ ghế, báo chưa tạo được thanh toán | Q-130 |
| createPaymentTransaction | Tham số vi phạm tiền điều kiện | Nghiệp vụ nội bộ | validate | Không xử lý | InvalidGatewayRequestError | Xử lý như 10a | - |
| createPaymentTransaction | Cổng từ chối hoặc không trả lời yêu cầu tạo giao dịch (NFR-15, BR-90) | Không xảy ra như lời gọi mạng: VNPay không có lệnh tạo giao dịch qua mạng. Luồng 10a chỉ còn khi hệ thống lỗi trước lúc chuyển sang cổng (hai dòng trên) | - | Không thử lại; lần giữ ghế giữ nguyên tới hết hạn; mỗi lần khách bấm thanh toán là một bản ghi chờ mới (P09 F7.6). Cổng báo thất bại bằng IPN: lần giữ ghế sang Thanh toán thất bại và ghế được trả (bảng thời điểm IPN, luồng 11a). Khách bấm huỷ ở cổng hoặc đóng tab mà chưa có IPN không là thất bại: lần giữ ghế chạy tới hết hạn (luồng 7b) | - | UC-005 luồng 10a, 11a, 7b | Q-126, Q-130 |
| reportTransactionResult | Chữ ký sai hoặc thiếu | Nghiệp vụ | verifySignature | Không ghi gì | InvalidSignatureError; DC-PaymentReportService trả DC-IpnOutcome INVALID_SIGNATURE | Không có luồng P04: thông báo giả không là sự kiện nghiệp vụ | - |
| reportTransactionResult | Thiếu tham số bắt buộc, số tiền không là số | Nghiệp vụ | decode | Không ghi gì | MalformedReportError; DC-IpnOutcome MALFORMED | Như trên | V-04 |
| (PKG-14 sau reportTransactionResult) | Số tiền của thông báo khác bản ghi (DC-PaymentReportService phát hiện) | Nghiệp vụ | So sánh ở PKG-14 sau reportTransactionResult | Không tạo vé, ghi log, không hoàn tự động | DC-IpnOutcome AMOUNT_MISMATCH | UC-006 luồng 2f (BR-91): ghi log, xử lý thủ công ngoài hệ thống | Q-128 |
| (PKG-14 sau reportTransactionResult) | IPN trùng với báo đã xử lý | Nghiệp vụ | Cờ đã xử lý dưới khoá lần giữ ghế X ở PKG-14 | Không tạo vé, không hoàn thêm | DC-IpnOutcome DUPLICATE | UC-006 luồng 2a | - |
| (PKG-14 sau reportTransactionResult) | Lỗi tạm thời cơ sở dữ liệu hoặc hết thời gian chờ khoá ở PKG-14 | Kỹ thuật tạm thời | Giao dịch rollback hoàn toàn | Không xử lý trong SS-01 | DC-IpnOutcome TEMPORARY_FAILURE; cổng có thể gửi lại, an toàn vì giao dịch đã rollback | UC-006 không có luồng riêng | V-04 |
| requestRefund | Hết 30 giây hoặc mất kết nối sau khi gửi | Không rõ kết quả | Hết thời gian chờ | Không thử lại trong subsystem | RefundOutcome(Unknown) | UC-006 luồng 4a, 4b; UC-008 luồng 5b, 5c | Q-127 |
| requestRefund | Cổng từ chối rõ ràng, mã đã biết là chưa thực hiện | Nghiệp vụ | Mã trả lời hợp lệ chữ ký | Không thử lại trong subsystem | RefundOutcome(Rejected) | UC-006 luồng 5a, 5b; UC-008 luồng 6a, 6b | Q-111 mục d |
| requestRefund | Mã trả lời không nhận ra hoặc chữ ký trả lời sai | Không rõ kết quả | Bảng mã, kiểm chữ ký | Không đoán là chưa hoàn | RefundOutcome(Unknown) | Như dòng hết 30 giây | V-10, V-13 |
| requestRefund | Tham số vi phạm tiền điều kiện (số hoàn vượt số đã thanh toán) | Nghiệp vụ nội bộ | validate | Không gửi ra ngoài | InvalidGatewayRequestError | Không có (lỗi lập trình bên gọi) | - |
| findRefund | Cổng không có cách tra cứu hoàn | Kỹ thuật, không tạm thời | Cờ cấu hình (V-11) | Không gọi mạng | RefundLookup(NotSupported); bên gọi chuyển RefundRequest sang Cần xử lý thủ công, không gửi lại tự động (Q-118) | UC-006 luồng 4b, 5b; UC-008 luồng 5c, 6b | Q-118, Q-127 |
| findRefund | Không trả lời trong 30 giây, sai chữ ký hoặc trạng thái không rõ | Kỹ thuật tạm thời | Hết thời gian chờ, kiểm chữ ký | Không thử lại trong subsystem | RefundLookup(Unreachable); bên gọi hẹn lại theo hàng đợi (1, 5, 15 phút, tính vào số lần thử), hết lượt thì Cần xử lý thủ công | UC-006 luồng 4a, 4b; UC-008 luồng 5b, 5c | Q-127 |

Ánh xạ kết quả xử lý sang câu trả lời của cổng (do DC-PaymentCallbackController ở PKG-12 giữ, theo P09 F7.6, chưa kiểm V-04): PROCESSED --> RspCode 00; DUPLICATE --> 02; INVALID_SIGNATURE --> 97; AMOUNT_MISMATCH --> 04; UNKNOWN_TRANSACTION --> 01; TEMPORARY_FAILURE --> 99 (hoặc mã 5xx tuỳ hành vi gửi lại của sandbox); MALFORMED --> 99. Mọi trường hợp trả HTTP 200 với nội dung JSON gồm RspCode và Message, trừ TemporaryFailure có thể trả 5xx.

Cách bảo đảm idempotent của IPN. Subsystem không giữ trạng thái: reportTransactionResult là hàm thuần nên gọi lặp bao nhiêu lần cũng cùng kết quả. Idempotent thật nằm ở DC-PaymentReportService (PKG-14, P09 F7.6): mọi báo của cùng một lần giữ ghế đi qua khoá SeatHold X nên tuần tự, kể cả hai báo giống hệt đến cùng lúc ở hai bản backend; dưới khoá, cờ đã xử lý của giao dịch làm lần hai trả DUPLICATE (RspCode 02) và không tạo vé, không hoàn thêm; ràng buộc UNIQUE (một lần đặt cho mỗi lần giữ ghế, một vé cho mỗi ghế đã bán, một yêu cầu hoàn cho mỗi khoá chống hoàn trùng, một PaymentTransaction cho mỗi mã giao dịch) là lưới an toàn. Lỗi tạm thời làm giao dịch rollback hoàn toàn nên cổng gửi lại an toàn.

Tình huống thời điểm của IPN (quyết định dưới khoá, so thời điểm cơ sở dữ liệu với expiry_time, P09 F7.4, F7.6):

| Tình huống | Xử lý | Câu trả lời |
|---|---|---|
| IPN thành công đến trước hạn giữ ghế, giao dịch chưa xử lý | Bán ghế, tạo vé, xếp email vé (UC-005 bước 11) | Processed (00) |
| IPN thành công đến sau hạn, sau khi khách huỷ giữ ghế, hoặc sau khi cổng đã báo thất bại | Ghi thanh toán trễ, tạo yêu cầu hoàn toàn bộ với khoá chống hoàn trùng, xếp hàng hoàn tiền (UC-006 bước 3, 4) | Processed (00) |
| IPN thành công thứ hai cho lần giữ ghế đã có vé (mã giao dịch khác) | Hoàn toàn bộ như thanh toán trễ, số tiền lấy từ báo của cổng (UC-006, REQ-136) | Processed (00) |
| IPN đến trước khi khách quay về địa chỉ trả về | Xử lý bình thường; địa chỉ trả về chỉ đọc trạng thái từ cơ sở dữ liệu, không ghi gì | Processed (00) |
| Khách quay về địa chỉ trả về trước khi IPN đến | Trang đọc trạng thái hiện có, chưa ghi nhận thanh toán; IPN đến sau xử lý bình thường | Không áp dụng: trang quay về không trả lời cho cổng; xem Q-126 |
| IPN đến khi PaymentTransaction của bước tạo thiếu | EX-02 tạo bản ghi từ mã tham chiếu lần giữ ghế trong báo (P09 F7.6) | Theo kết quả |
| IPN thất bại | Chỉ ghi nhận; lần giữ ghế Đang giữ chuyển Thanh toán thất bại, ghế được trả (UC-005 luồng 11a) | Processed (00) |
| IPN trùng, chữ ký sai, số tiền lệch, mã không tồn tại | Như bảng lỗi ở trên | 02, 97, 04, 01 |

Cách bảo đảm idempotent của hoàn tiền. Mỗi yêu cầu hoàn có một refundKey cố định (mã giao dịch kèm mã vé hoặc kèm loại hoàn toàn bộ, BR-43) và một dòng hàng đợi unique theo khoá đó, nên không tạo hai yêu cầu hoàn cho cùng khoản. Mọi lần thử dùng cùng refundKey và chỉ do bên giữ claim_token hợp lệ tại giao dịch 1 của ProcessRefund (ExtendClaim đặt lại claimed_until 120 giây, 0 dòng thì không gọi cổng) gọi, ngoài giao dịch cơ sở dữ liệu. Mỗi luồng claim đúng một dòng ngay trước khi xử lý, không claim trước một lô. Lần thử từ lần hai gọi findRefund (tối đa 30 giây) rồi requestRefund (tối đa 30 giây) trong cùng một claim; tính cả hai giao dịch ngắn (mỗi giao dịch tối đa 10 giây) là tối đa 80 giây, cộng biên 10 giây là 90 giây, nhỏ hơn 120 giây nên bản backend khác không nhận lại dòng khi lời gọi gửi hoàn còn chạy. Hạn mỗi lời gọi cũng bị cắt theo claimed_until trừ 10 giây biên, và tiến trình kiểm mốc đơn điệu cục bộ trước mỗi lời gọi. Công việc hoàn tiền không bị tính theo ngân sách 8 giây của lượt: ngân sách chỉ chặn việc nhận dòng mới (SS-04). Subsystem không tự thử lại. Sau kết quả Unknown hoặc Rejected, lần thử sau luôn gọi findRefund trước: Refunded thì ghi thành công mà không gửi lại; NotRefunded mới gửi lại, tối đa 3 lần thử lại (1, 5, 15 phút, P09 F7.7); NotSupported hoặc hết lượt thì RefundRequest sang Cần xử lý thủ công, không gửi lại tự động (Q-118). Rủi ro còn lại: nếu cổng không loại trùng theo refundKey (V-09) và findRefund trả NotRefunded sai (cổng chưa phản ánh yêu cầu đang xử lý, trạng thái 05 hoặc 06 của V-11), một khoản có thể bị hoàn hai lần; tương tự khi một bản backend bị tạm dừng (dừng GC, máy ảo tạm dừng) quá claimed_until đúng giữa lúc kiểm xong và lúc gói tin rời máy, trong khi bản nhận lại đã tra cứu thấy chưa hoàn rồi gửi (chỉ khoá refundKey ở cổng ngăn được, P09 F7.7 bước 2); giảm bằng cách coi mọi trạng thái đang xử lý là Refunded hoặc Unreachable, không là NotRefunded. Mã trả lời cổng không có trong bảng được coi là Unknown, không bao giờ là Rejected.

b) Điểm kiểm tra

| Điểm kiểm tra | Kết quả | Ghi chú |
|---|---|---|
| Mỗi interface subsystem cung cấp có realization | Đạt | IF-01 do DC-PaymentGatewayManager, IF-02 do DC-PaymentReportReceiver |
| Mỗi interface subsystem dùng có phụ thuộc | Không áp dụng | SS-01 không dùng interface nào |
| Không phần tử bên trong nào public, trừ kiểu dữ liệu và ngoại lệ thuộc chữ ký interface | Đạt | Public: PaymentReport, RefundOutcome, RefundLookup, bốn ngoại lệ; còn lại package-private |
| Mỗi operation có sơ đồ hộp trắng hoặc ánh xạ 1-1 | Đạt | Mỗi operation có trang S01W1 đến S01W4 |

## Câu hỏi mở

Ghi ở file chung.

## Giả định

Ghi ở file chung.

## Đề xuất sửa artifact trước

Ghi ở file chung.

## Vấn đề còn mở

Ghi ở file chung.
