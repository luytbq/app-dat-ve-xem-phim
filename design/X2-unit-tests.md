# X2 - Thiết kế unit test - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | X2 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Đồng bộ X3 (design/_sync-log.md): đánh dấu trạng thái từng dòng Đề xuất sửa artifact trước; cập nhật các câu về luồng UC-008 2c và ca tích hợp Q-134 theo P12 1.5; chưa chạy lại X2 |
| Đầu vào đã dùng | project-profile.md; P12-class-design.md 1.5 (F1, F1b, F2, F3, F5, F6, F7, Câu hỏi mở, Đề xuất sửa, Vấn đề còn mở); P13-data-model.md 1.4 và P13-schema.sql (ràng buộc, chỉ mục, trigger); P09-architecture.md 1.6 (F7.3, F7.4, F7.6, F7.7, F7.9); P08-analysis-model.md 1.5 (F4a EX-01 đến EX-15, F4b X-01 đến X-23); P06-supplementary-spec.md 1.3 (BR, NFR); P04-uc-specs/_BR-register.md; P04-uc-specs/UC-005-book-tickets.md, UC-006-refund-late-payment.md, UC-008-cancel-ticket.md, UC-009-check-ticket.md (luồng thay thế); X1-design-review.md 1.1 (Câu hỏi mở, F2); 00-Concurrency.md (M9, theo yêu cầu người chạy). Không có mã nguồn |
| Phạm vi | P12 phần đã chi tiết hoá: PKG-12, PKG-13, PKG-14, PKG-15, PKG-21, PKG-22, PKG-24, PKG-25, PKG-26 (chỉ IF-07), PKG-28 và phần PKG-27 mà UC-005, UC-008, UC-009 dùng. Ngoài phạm vi (chưa thiết kế): phần còn lại của PKG-27 (DC-Cinema, DC-Auditorium, DC-Movie, DC-PriceEntry, DC-CinemaManager, DC-TicketChecker, IF-14, IF-15, operation của UC-013, UC-014), PKG-16 |
| Tham số lần chạy | PHAM_VI_TEST: phạm vi trên, ưu tiên chiều sâu ở giữ ghế, giữ ghế có timeout, giải phóng ghế, IPN, huỷ vé, hoàn tiền; MUC_TIEU_PHU: mặc định (100% C1 cho operation ưu tiên Cao, 100% C0 cho còn lại); SINH_MA_TEST: Không có; MA_TC_BAT_DAU: Không có (TC-001) |
| Chế độ | NGHIEM_NGAT; MUC_CHI_TIET = DAY_DU; CONG_NGHE: Go (net/http, pgx), PostgreSQL 15 trở lên, VNPay sandbox |
| Mã TC đã cấp | TC-001 đến TC-384: 362 ca unit (trong đó 26 ca chờ Q-nn) và 22 ca tích hợp |
| Mã Q, ASM cuối đã cấp | Q-154; không có ASM (NGHIEM_NGAT) |

## F1. Bảng chọn operation

Quy ước dùng chung cho mọi ca thử:

- Thời gian: ngày 2026-11-10 (Thứ Ba), múi giờ UTC+7. Lần giữ ghế H1 có holdTime 10:00:00.000, expiryTime E = 10:10:00.000; E - 1ms = 10:09:59.999. Suất chiếu 55 bắt đầu 20:00:00.000, mở bán 2026-11-09 08:00, phòng 7, cụm rạp 2. Thời điểm hiện tại luôn là tham số now hoặc kết quả stub của IF-25.Now, không dùng đồng hồ hệ thống.
- Tiền: Money là số đồng nguyên; ghế STANDARD 90.000 đồng, VIP 120.000 đồng; hoàn 70% làm tròn xuống đồng.
- Trạng thái đầu của đối tượng miền luôn dựng bằng operation công khai của P12 (NewSeatHold, Complete, Expire, BeginAttempt, RecordResult...), không dùng bộ dựng riêng; nếu không dựng được thì ghi ở cột Điều kiện đầu và ở Đề xuất sửa artifact trước.
- Test double của lớp dịch vụ: IF-08 giả (fake) chạy fn một lần trên bản sao in-memory và hoàn lại khi fn trả lỗi, mang LockOrderGuard thật; các store giả gọi Acquire theo hạng cố định của từng operation (P12 F2). Vì vậy mọi TC lớp dịch vụ đều ngầm khẳng định thứ tự khoá 9 hạng không bị vi phạm.
- Ca tích hợp: các ca cần PostgreSQL thật, nhiều goroutine hoặc nhiều bản backend, hoặc tiến trình chết. Cột Mức của F3 ghi Tích hợp; chúng không tính vào độ phủ C0, C1 của unit test. Kết quả mong đợi bắt đầu bằng Chưa xác định: chờ Q-nn là TC chờ câu hỏi, không tính vào độ phủ.
- Mã nội bộ: EC, BV, DT<k>-R<n>, N<n>, CE<n> theo prompt; CT-nn là mã chuyển trạng thái hoặc cặp (trạng thái, sự kiện) bị từ chối; P<n> là đường đi cơ sở; đều đánh số liên tục trong file.

| DC.operation | Tiêu chí (BR / rẽ nhánh / tính toán / sự kiện ST / kiểm tra hợp lệ / điều phối UC / gọi hệ thống ngoài) | Ưu tiên (Cao / Trung bình / Thấp) | Chọn (Có / Không: lý do) |
|---|---|---|---|
| DC-SeatHold.NewSeatHold | BR (BR-10) / sự kiện ST (create ST-01) | Cao | Có (F2.1) |
| DC-SeatHold.Expire | sự kiện ST (ST-01 expire) / BR (BR-10, BR-85, BR-86) | Cao | Có (F2.2) |
| DC-SeatHold.Complete, Cancel, FailPayment | sự kiện ST (ST-01 complete, cancel, failPayment) / BR (BR-85, BR-86) | Cao | Có (F2.3) |
| DC-SeatHold.IsActiveAt | BR (BR-04, BR-53, BR-85) / kiểm tra điều kiện | Cao | Có (F2.4) |
| DC-SeatHold.CalculateTotal | BR (BR-65) / tính toán | Cao | Có (F2.5) |
| DC-SeatStatus.HoldFor, MarkSold | sự kiện ST (ST-02 holdFor, markSold) / BR (BR-07, BR-08, BR-09, BR-85) | Cao | Có (F2.6) |
| DC-SeatStatus.ReleaseHold, ReleaseTicket | sự kiện ST (ST-02 releaseHold, releaseTicket) / BR (BR-42; REQ-76; X-13, X-18) | Cao | Có (F2.7) |
| DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | sự kiện ST (ST-05) / BR (BR-14, BR-15, BR-37, BR-39, BR-40) | Cao | Có (F2.8) |
| DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | BR (BR-26) / kiểm tra giới hạn | Cao | Có (F2.9) |
| DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | BR (BR-43 khoá chống hoàn trùng; BR-20) / sự kiện ST (create ST-04) | Trung bình | Có (F2.10) |
| DC-RefundRequest.BeginAttempt | sự kiện ST (ST-04 beginAttempt) / BR (BR-41, BR-43) | Cao | Có (F2.11) |
| DC-RefundRequest.RecordResult | sự kiện ST (ST-04 recordResult) / BR (BR-41, BR-43) | Cao | Có (F2.12) |
| DC-RefundRequest.MarkManualRequired | sự kiện ST (ST-04 markManualRequired) / BR (BR-41) | Cao | Có (F2.13) |
| DC-Ticket.Cancel | sự kiện ST (ST-03 cancel) / BR (BR-21, BR-30) | Cao | Có (F2.14) |
| DC-Ticket.Admit | sự kiện ST (ST-03 admit) / BR (BR-22 đến BR-25, BR-30, BR-33) | Cao | Có (F2.15) |
| DC-Ticket.RefundAmount | BR (BR-19, BR-31) / tính toán | Cao | Có (F2.16) |
| DC-Booking.CheckCancellationChannel | BR (BR-17) / kiểm tra điều kiện | Cao | Có (F2.17) |
| DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | BR (BR-04) / kiểm tra điều kiện | Cao | Có (F2.18) |
| DC-LockOrderGuard.Acquire, AcquireAll | BR/bất biến khoá (P08 F4b: thứ tự 9 hạng, quy tắc 3) / rẽ nhánh | Cao | Có (F2.19) |
| DC-Showtime.CheckCancellationDeadline | BR (BR-18, BR-32) / kiểm tra điều kiện, thời gian | Cao | Có (F2.20) |
| DC-Showtime.CheckSaleOpen | BR (BR-01, BR-45) / kiểm tra điều kiện, thời gian | Cao | Có (F2.21) |
| DC-Showtime.CheckSeatSelection | BR (BR-05, BR-06) / kiểm tra hợp lệ dữ liệu vào | Cao | Có (F2.22) |
| DC-Showtime.CheckUnchangedSince | BR (BR-54) / kiểm tra điều kiện | Cao | Có (F2.23) |
| DC-PriceList.DetermineSeatPrice | BR (BR-11, BR-12, BR-72) / tính toán, tra cứu | Cao | Có (F2.24) |
| DC-BookTicketsService.HoldSeats | điều phối UC (UC-005 bước 5 đến 8) / BR (BR-04, BR-05, BR-07, BR-09, BR-10, BR-54, BR-65, BR-72) / nhiều nhánh | Cao | Có (F2.25) |
| DC-PaymentReportService.decide | BR (BR-14, BR-15, BR-37, BR-39, BR-40, BR-85, BR-86) / bảng quyết định P09 F7.6 / nhiều nhánh | Cao | Có (F2.26) |
| DC-BookTicketsService.CancelHold | điều phối UC (UC-005 luồng *a, 7b) / BR (BR-04, BR-85, BR-86) / EX-04 gộp EX-05 (Q-134) | Cao | Có (F2.27) |
| DC-BookTicketsService.ConfirmCashReceived | điều phối UC (UC-005 luồng 9a) / BR (BR-44, BR-85, BR-67) / EX-03 | Cao | Có (F2.28) |
| DC-BookTicketsService.StartOnlinePayment | điều phối UC (UC-005 bước 9, 10) / gọi hệ thống ngoài qua interface (IF-01) / BR (BR-90) | Trung bình | Có (F2.29) |
| DC-PaymentReportService.HandleIpn | điều phối UC (UC-005 bước 11 đến 15, UC-006 bước 1 đến 3) / BR (BR-14, BR-15, BR-37 đến BR-40, BR-85, BR-86, BR-91, BR-93) / EX-02 / gọi hệ thống ngoài (IF-02) | Cao | Có (F2.30) |
| DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | điều phối công việc nền / BR (BR-10, BR-85, BR-86; NFR-07) / vòng lặp theo lô / EX-04 | Cao | Có (F2.31) |
| DC-SeatReleaseJob.RunDue (releaseBatch) | điều phối công việc nền / BR (REQ-76, NFR-07, BR-42) / liên kết hiện tại R-63 / EX-05 | Cao | Có (F2.32) |
| DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | điều phối UC (UC-008 bước 1 đến 7) / BR (BR-17 đến BR-21, BR-26, BR-30, BR-42, BR-43) / EX-06, EX-07, EX-09 | Cao | Có (F2.33) |
| DC-CheckTicketService.CheckTicket | điều phối UC (UC-009 bước 4, 5) / BR (BR-22 đến BR-25, BR-30, BR-33) / EX-08 | Cao | Có (F2.34) |
| DC-RefundService.CreateFullRefund, RequestTicketRefund | BR (BR-26, BR-43, BR-14, BR-19) / EX-09 / gọi qua interface store | Cao | Có (F2.35) |
| DC-RefundService.ProcessRefund | điều phối UC (UC-006 bước 4 đến 6, UC-008 bước 5, 6) / gọi hệ thống ngoài (IF-01) / BR (BR-41, BR-43) / EX-10 / hàng rào claim_token | Cao | Có (F2.36) |
| DC-CancelTicketService.FindBooking | điều phối UC (UC-008 bước 1a1) / BR (BR-02, BR-17) / kiểm tra kênh và cụm rạp | Cao | Có (F2.37) |
| DC-CheckTicketService.StartChecking | điều phối UC (UC-009 bước 1 đến 3) / BR (BR-34) / kiểm tra điều kiện | Cao | Có (F2.38) |
| IF-07.VerifyPassword, IssueSession, VerifySession | BR (NFR-01 đến NFR-03; Q-129 hạn phiên) / kiểm tra hợp lệ / hạn thời gian | Trung bình | Có (F2.39) |
| Ca tích hợp (PostgreSQL 15 thật, nhiều goroutine hoặc nhiều bản backend) | tranh chấp đồng thời, khoá dòng, thứ tự đến, tiến trình chết / BR (BR-04, BR-09, BR-21, BR-24, BR-26, BR-30, BR-37, BR-43, BR-85, BR-86; NFR-06, NFR-07) | Cao | Có (F2.40) |
| DC-SeatHold.ID, Ref, Status, ExpiryTime, Holder, ShowtimeId, IsHeldBy | getter, so sánh bằng (IsHeldBy) | Thấp | Không: getter không có logic (Bước 1); IsHeldBy là so sánh bằng của HolderRef, được dùng làm đầu vào quan sát hậu điều kiện ở mọi TC |
| DC-SeatStatus.NewAvailable, IsHeldBy, IsAvailable, State, Key, CurrentHold, CurrentTicket, HeldPrice | getter, hàm dựng, predicate một dòng | Thấp | Không: không có logic riêng; IsHeldBy và IsAvailable được phủ gián tiếp qua HandleIpn (ghế liên kết vỡ) và HoldSeats (ghế không trống) |
| DC-PaymentTransaction.NewPending, IsProcessed, ID, Code, Amount, Status, PaidAt | hàm dựng, predicate, getter | Thấp | Không: NewPending phủ qua StartOnlinePayment, IsProcessed phủ qua decide; getter không logic |
| DC-RefundRequest.HasAttemptsRemaining, Status, Amount, IdempotencyKey, AttemptCount | predicate, getter | Thấp | Không: HasAttemptsRemaining là so sánh attemptCount < 4, phủ qua BeginAttempt và RecordResult với biên 3 và 4 |
| DC-Booking.NewBooking, Code, Tickets, ID | hàm dựng, getter | Thấp | Không: NewBooking phủ qua ConfirmCashReceived và HandleIpn (SELL); getter không logic |
| DC-Ticket.NewTicket, IsCancelled, ID, Code, Price, Status, Key | hàm dựng, getter | Thấp | Không: NewTicket phủ qua ConfirmCashReceived; getter không logic |
| DC-Customer.Ref, Email; DC-BoxOfficeClerk.Ref, CinemaId | getter | Thấp | Không: getter không logic |
| DC-Showtime.QuoteSeatPrices, BelongsToCinema, ID, StartTime, Status, LastChangedAt | ủy quyền, so sánh bằng, getter | Trung bình | Không: QuoteSeatPrices chỉ ủy quyền PriceList.DetermineSeatPrice (phủ ở đó và qua HoldSeats); BelongsToCinema là so sánh bằng, phủ qua Ticket.Admit và StartChecking |
| DC-BookTicketsService.GetHold | đọc dữ liệu | Thấp | Không: chỉ đọc; kết quả khi by không phải người giữ chưa xác định (Q-147); để lượt sau |
| DC-SeatMapService.GetSnapshot, OpenStream | đọc, gọi IF-04 | Trung bình | Không: ngoài trọng tâm của lượt này (sơ đồ ghế real-time, NFR-08, NFR-09); để lượt sau với MA_TC_BAT_DAU |
| DC-PaymentReportService.ResolveReturnedPayment, QueryPaymentStatus, logUnrecognized | ủy quyền IF-02, đọc dữ liệu, ghi log | Trung bình | Không: ủy quyền nguyên lời gọi hoặc chỉ đọc (Q-126); logUnrecognized được kiểm bằng spy ở HandleIpn |
| DC-RefundService.toAttempt, LockPaymentOfTicket | chuyển đổi, ủy quyền | Thấp | Không: toAttempt là phép ánh xạ enumeration; LockPaymentOfTicket phủ qua CancelOnlineTicket (thứ tự khoá 6, 7, 8) |
| DC-RefundOutboxJob.RunDue | điều phối công việc nền, song song | Trung bình | Không: logic xử lý một dòng nằm ở ProcessRefund; tính song song thật và claim từng dòng là ca tích hợp; để lượt sau (Trung bình) |
| DC-PaymentCallbackController.HandleIpn, HandleReturn, HandlePaymentStatus, writeIpnAnswer | định dạng dữ liệu, ánh xạ RspCode | Trung bình | Không: để lượt sau (PKG-22, PKG-12 thuộc ưu tiên Trung bình); bảng RspCode PROCESSED 00, DUPLICATE 02, INVALID_SIGNATURE 97, AMOUNT_MISMATCH 04, UNKNOWN_TRANSACTION 01, TEMPORARY_FAILURE và MALFORMED 99 cần TC khi chạy lại |
| IF-01, IF-02 và PKG-22 (DC-PaymentGatewayManager, DC-PaymentReportReceiver, DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-VnpaySigner, DC-VnpayReportDecoder, DC-GatewayConfig) | gọi hệ thống ngoài, chuyển đổi dữ liệu, ký | Trung bình | Không: để lượt sau; V-01 đến V-11 của VNPay chưa kiểm tài liệu (P11b), nên oracle (chữ ký, nhân số tiền 100) chưa chắc; dùng sandbox khi chạy lại |
| PKG-24: IF-04, DC-SeatEventHubManager, DC-SeatEventPoller, DC-SeatReplayReader, DC-SubscriberRegistry, DC-SubscriberQueue, DC-EmittedEventTracker | vòng lặp, phát sự kiện | Trung bình | Không: ngoài trọng tâm lượt này; để lượt sau (SubscriberQueue.Offer biên 256, EmittedEventTracker.AdvanceMark) |
| PKG-25: IF-05, IF-06, DC-JobSchedulerManager, DC-JobRegistry, DC-JobLoop | vòng lặp theo chu kỳ | Trung bình | Không: để lượt sau (JobLoop.runOnce bỏ chu kỳ nếu đang chạy); logic công việc nền được phủ ở HoldExpiryJob và SeatReleaseJob |
| DC-PgUnitOfWork.Do, runOnce, isRetryable; DC-PgTx; DC-ConnectionPools; DC-SeatEventWriter; DC-PgTicketingStore (lockRows, mapPgError, SaveChanges); DC-PgCinemaOperationsStore; DC-PgSeatEventStore; DC-PgOutboxStore | truy cập CSDL, khoá, thử lại | Cao | Không (unit): cần PostgreSQL thật (khoá dòng, NOWAIT, SKIP LOCKED, 40P01); ca tích hợp ở F2.40 (TC mức Tích hợp) |
| IF-11, IF-12, IF-13, IF-16 đến IF-21, IF-22, IF-23 (operation của interface store) | truy cập CSDL | Cao | Không (unit): chữ ký và SQL kiểm bằng ca tích hợp (Claim, ExtendClaim, AddRefunded, LockForHold, LockExpiredBatch); trong unit test dùng làm test double |
| IF-24, IF-25, DC-RandomCodeGenerator.NewHoldRef, NewTransactionCode, NewBookingCode, NewTicketCode | sinh số ngẫu nhiên, thời gian | Thấp | Không: giá trị ngẫu nhiên được tiêm vào (stub); định dạng (UUID v4, 20 chữ số, 16 ký tự) kiểm khi có mã nguồn |

## F2. Phân tích kỹ thuật cho từng operation

### F2.1 DC-SeatHold.NewSeatHold

#### F2.1.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | NewSeatHold(holder HolderRef, showtimeId ShowtimeId, requestId string, holdRef string, now time.Time) *SeatHold | P12 F2 |
| Hậu điều kiện | status = ACTIVE; expiryTime = now + HoldDuration (10 phút) | P12 F2, F7; BR-10 |
| Tiền điều kiện | now là tx.Now sau khi có khoá | P12 F2 |
| BR | BR-10: giữ tạm 10 phút kể từ khi giữ thành công, áp dụng cả bán tại quầy | P06; _BR-register |
| Người giữ | holder là khách (CUSTOMER) hoặc nhân viên quầy (CLERK), loại trừ nhau | P12 F1b DC-HolderRef; R-48, R-49 |
| Không áp dụng | Không áp dụng: F2.1.4 (một điều kiện ảnh hưởng kết quả), F2.1.6 (không rẽ nhánh) | - |

#### F2.1.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-01 | holder | kind = CUSTOMER | Hợp lệ | CUSTOMER 7 | P12 F1b |
| EC-02 | holder | kind = CLERK | Hợp lệ | CLERK 3 | P12 F1b |
| EC-03 | holder, requestId, holdRef | rỗng, nil hoặc zero (P12 không nêu hành vi) | Không hợp lệ | requestId = rỗng | P12 F2: không nêu |

#### F2.1.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-01 | EC-01 (now) | now = 2026-11-10 23:55:00 (expiryTime vượt qua nửa đêm) | EC-01 | expiryTime = 2026-11-11 00:05:00, không cắt theo ngày |

#### F2.1.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-01 | (initial) | create(holder, showtimeId, requestId, holdRef, now) [cả nhóm ghế giữ được, bảo đảm bởi bên gọi] | - | Tạo SeatHold | Đang giữ (ACTIVE), expiryTime = now + 10 phút | ST-01 STT 1 |

#### F2.1.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần; now là tham số | Prompt Bước 5: thời gian tiêm vào qua tham số |

### F2.2 DC-SeatHold.Expire

#### F2.2.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Expire(now time.Time) bool | P12 F2 |
| Mô tả / hậu | Chuyển ACTIVE sang EXPIRED khi now không trước expiryTime; trả true nếu có đổi; trạng thái cuối không đổi; chạy lặp an toàn | P12 F2, F3 |
| BR | BR-10 (hạn 10 phút), BR-85 (xử lý tuần tự), BR-86 (trạng thái cuối không đổi) | P06 |
| Chuyển trạng thái | ST-01 STT 3: Đang giữ --> Hết hạn khi [now >= expiryTime]; expire ở trạng thái cuối hoặc khi now < expiryTime: bỏ qua, trả false | P12 F6.2 |
| Không áp dụng | Không áp dụng: F2.2.4 (một biến thiên kết quả theo hai điều kiện đã gộp trong phân vùng đầu ra và CFG), vòng lặp (không có) | - |

#### F2.2.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-04 | status = ACTIVE, now | now < expiryTime | Không hợp lệ (false) | now = E - 1ms | P12 F6.2 |
| EC-05 | status = ACTIVE, now | now >= expiryTime | Hợp lệ (true) | now = E + 5 phút | P12 F6.2 |
| EC-06 | status | trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED) | Không hợp lệ (false) | COMPLETED; EXPIRED | P12 F6.2; BR-86 |

#### F2.2.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-02 | EC-04 (now so với expiryTime) | E - 1ms | EC-04 | false; Status = ACTIVE |
| BV-03 | EC-05 (now so với expiryTime) | E (đúng hạn) | EC-05 | true; Status = EXPIRED |
| BV-04 | EC-05 (now so với expiryTime) | E + 1ms | EC-05 | true; Status = EXPIRED |

#### F2.2.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-02 | Đang giữ | expire(now) [now >= expiryTime] | đúng | Trả true | Đã hết hạn (EXPIRED) | ST-01 STT 3 |
| CT-03 | Đang giữ | expire(now) [now < expiryTime] | sai | Bỏ qua, trả false | Đang giữ | P12 F6.2 (bị bỏ qua) |
| CT-04 | Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại | expire(now) | - | Bỏ qua, trả false (chạy lặp an toàn) | Không đổi | P12 F6.2 (bị bỏ qua) |

#### F2.2.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N1 | bắt đầu | bắt đầu |
| N2 | status = ACTIVE? | quyết định |
| N3 | now không trước expiryTime? | quyết định |
| N4 | status = EXPIRED; trả true | khối lệnh |
| N5 | trả false | khối lệnh |
| N6 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE1 | N1 | N2 |  |
| CE2 | N2 | N3 | Đúng |
| CE3 | N2 | N5 | Sai |
| CE4 | N3 | N4 | Đúng |
| CE5 | N3 | N5 | Sai |
| CE6 | N4 | N6 |  |
| CE7 | N5 | N6 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P1 | N1 - N2 - N3 - N4 - N6 | TC-006 |
| P2 | N1 - N2 - N3 - N5 - N6 | TC-005 |
| P3 | N1 - N2 - N5 - N6 | TC-008 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE1 | TC-005, TC-006, TC-008 | Có |
| CE2 | TC-005, TC-006 | Có |
| CE3 | TC-008 | Có |
| CE4 | TC-006 | Có |
| CE5 | TC-005 | Có |
| CE6 | TC-006 | Có |
| CE7 | TC-005, TC-008 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 7/7 nhánh (100%).

#### F2.2.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Thời gian là tham số |

### F2.3 DC-SeatHold.Complete, Cancel, FailPayment

#### F2.3.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Complete(now) error; Cancel(now) error; FailPayment(now) error | P12 F2 |
| Tiền / hậu điều kiện | Tiền: ACTIVE và now trước expiryTime (bên gọi gọi Expire trước). Hậu: COMPLETED, CANCELLED, PAYMENT_FAILED tương ứng | P12 F2 |
| Ngoại lệ | HoldNotActiveError mang status hiện tại, không đổi (F3); F6.2 nêu 'gọi Expire trước (chuyển Hết hạn, lưu), rồi ném HoldNotActiveError(EXPIRED)' khi now >= expiryTime: hai nguồn mâu thuẫn | P12 F2, F3, F6.2; X1 RV-01 (4) |
| BR | BR-85, BR-86 (trạng thái cuối không đổi), BR-93 (guard FailPayment ở bên gọi, ngoài operation này) | P06 |
| Không áp dụng | Không áp dụng: F2.3.4 (một biến điều kiện chính theo từng sự kiện; tổ hợp đã gộp ở F2.3.5) | - |

#### F2.3.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-07 | status = ACTIVE, now | now < expiryTime | Hợp lệ | now = E - 1ms | P12 F2 |
| EC-08 | status = ACTIVE, now | now >= expiryTime (bên gọi chưa gọi Expire) | Không hợp lệ | now = E | P12 F3 và F6.2 mâu thuẫn --> Q-142 |
| EC-09 | status | trạng thái cuối (COMPLETED, EXPIRED, CANCELLED, PAYMENT_FAILED) | Không hợp lệ | EXPIRED | P12 F6.2; BR-86 |

#### F2.3.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-05 | EC-07 | now = E - 1ms | EC-07 | Chuyển sang trạng thái đích |
| BV-06 | EC-08 | now = E | EC-08 | Chưa xác định: chờ Q-142 |
| BV-07 | EC-08 | now = E + 1ms | EC-08 | Chưa xác định: chờ Q-142 |

#### F2.3.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-05 | Đang giữ | complete(now) [now < expiryTime] | đúng | Trả nil | Đã hoàn tất (COMPLETED) | ST-01 STT 2 |
| CT-06 | Đang giữ | cancel(now) [now < expiryTime] | đúng | Trả nil | Đã huỷ (CANCELLED) | ST-01 STT 4 |
| CT-07 | Đang giữ | failPayment(now) [now < expiryTime] | đúng | Trả nil | Thanh toán thất bại (PAYMENT_FAILED) | ST-01 STT 5 |
| CT-08 | Đang giữ | complete(now) [now >= expiryTime] | sai | HoldNotActiveError; status và trạng thái sau chờ Q-142 | Chờ Q-142 | P12 F6.2 / F3 |
| CT-09 | Đang giữ | cancel(now) [now >= expiryTime] | sai | HoldNotActiveError; status và trạng thái sau chờ Q-142 | Chờ Q-142 | P12 F6.2 / F3 |
| CT-10 | Đang giữ | failPayment(now) [now >= expiryTime] | sai | HoldNotActiveError; status và trạng thái sau chờ Q-142 | Chờ Q-142 | P12 F6.2 / F3 |
| CT-11 | Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại | complete(now) | - | HoldNotActiveError mang status hiện tại | Không đổi | P12 F6.2 (bị từ chối) |
| CT-12 | Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại | cancel(now) | - | HoldNotActiveError mang status hiện tại | Không đổi | P12 F6.2 (bị từ chối) |
| CT-13 | Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại | failPayment(now) | - | HoldNotActiveError mang status hiện tại | Không đổi | P12 F6.2 (bị từ chối) |

#### F2.3.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N7 | bắt đầu | bắt đầu |
| N8 | status = ACTIVE? | quyết định |
| N9 | now trước expiryTime? | quyết định |
| N10 | status = trạng thái đích; trả nil | khối lệnh |
| N11 | trả HoldNotActiveError(status hiện tại) | khối lệnh |
| N12 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE8 | N7 | N8 |  |
| CE9 | N8 | N9 | Đúng |
| CE10 | N8 | N11 | Sai |
| CE11 | N9 | N10 | Đúng |
| CE12 | N9 | N11 | Sai |
| CE13 | N10 | N12 |  |
| CE14 | N11 | N12 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P4 | N7 - N8 - N9 - N10 - N12 | TC-010, TC-011, TC-012 |
| P5 | N7 - N8 - N9 - N11 - N12 | - |
| P6 | N7 - N8 - N11 - N12 | TC-016 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE8 | TC-010, TC-011, TC-012, TC-016 | Có |
| CE9 | TC-010, TC-011, TC-012 | Có |
| CE10 | TC-016 | Có |
| CE11 | TC-010, TC-011, TC-012 | Có |
| CE12 | Không | Không |
| CE13 | TC-010, TC-011, TC-012 | Có |
| CE14 | TC-016 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 6/7 nhánh (85%).

#### F2.3.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Thời gian là tham số |

### F2.4 DC-SeatHold.IsActiveAt

#### F2.4.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | IsActiveAt(now) bool | P12 F2 |
| Mô tả | ACTIVE và now trước expiryTime; điều kiện ghép hiện thực BR-04, BR-53, BR-85 | P12 F2 |
| Không áp dụng | Không áp dụng: F2.4.4 (một biểu thức), F2.4.5 (không là sự kiện ST), F2.4.6 (biểu thức một dòng; điều kiện ghép kiểm bằng ba TC phủ mọi giá trị điều kiện con) | - |

#### F2.4.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-10 | status, now | ACTIVE và now < expiryTime | Hợp lệ (true) | now = E - 1ms | BR-53 |
| EC-11 | status, now | ACTIVE và now >= expiryTime | Không hợp lệ (false) | now = E | BR-53; BR-14 |
| EC-12 | status | trạng thái cuối | Không hợp lệ (false) | COMPLETED | BR-86 |

#### F2.4.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-08 | EC-10 | E - 1ms | EC-10 | true |
| BV-09 | EC-11 | E | EC-11 | false |

#### F2.4.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Thời gian là tham số |

### F2.5 DC-SeatHold.CalculateTotal

#### F2.5.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CalculateTotal(seats []*SeatStatus) Money | P12 F2 |
| Mô tả | Tổng heldPrice của các ghế đang giữ cho lần giữ ghế này | P12 F2; BR-65 |
| Dùng ở | HandleIpn bước 3 (so r.amount với tổng giá khi tạo giao dịch từ báo), HoldSeats (HoldResult), StartOnlinePayment (số tiền giao dịch) | P12 F3 |
| Chưa nêu | Ghế trong danh sách không thuộc lần giữ ghế (currentHold khác hoặc không HELD); danh sách rỗng | P12 F2: không nêu --> Q-143 |
| Không áp dụng | Không áp dụng: F2.5.4 (một điều kiện), F2.5.5 (không là sự kiện ST), F2.5.6 (tổng một vòng lặp đơn, ghi ở bảng vòng lặp) | - |

#### F2.5.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-13 | seats | mọi ghế HELD bởi lần giữ ghế này, 1 đến 8 ghế | Hợp lệ | 3 ghế: 90.000, 90.000, 120.000 | BR-65; BR-05 |
| EC-14 | seats | có ghế không thuộc lần giữ ghế này (currentHold khác hoặc không HELD) | Không hợp lệ | 1 ghế HELD bởi hold khác | P12 F2 không nêu --> Q-143 |
| EC-15 | seats | danh sách rỗng | Không hợp lệ | [] | P12 F2 không nêu --> Q-143 |

#### F2.5.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-10 | kích thước seats (EC-13) | 1 ghế | EC-13 | Tổng = giá ghế đó |
| BV-11 | kích thước seats (EC-13) | 8 ghế (tối đa BR-05) | EC-13 | Tổng = 8 x 90.000 = 720.000 |

Vòng lặp:

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử (0, 1, m, n-1, n, n+1) | TC |
|---|---|---|---|---|
| cộng heldPrice theo từng ghế | 8 (BR-05) | 3 | 0 (chờ Q-143), 1, 3, 8; n - 1 và n + 1 không thêm TC | TC-025, TC-026, TC-027 |

Ghi chú vòng lặp: cộng heldPrice theo từng ghế. n = 8 (BR-05), m = 3. Số lần kiểm thử: 0 (ghi ở EC-15, chờ Q-143), 1, m = 3, 8; n - 1 = 7 và n + 1 = 9 không thêm TC vì kích thước nhóm ghế do HoldSeats chặn trước (SeatSelectionError ở DC-Showtime.CheckSeatSelection), không phải trách nhiệm của operation này.

#### F2.5.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-SeatStatus | stub | Dùng đối tượng thật (đối tượng miền thuần) dựng bằng NewAvailable, HoldFor | Không cần double |

### F2.6 DC-SeatStatus.HoldFor, MarkSold

#### F2.6.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | HoldFor(holdId, price) error; MarkSold(holdId, ticketId) error | P12 F2 |
| Tiền / hậu | HoldFor: tiền AVAILABLE, hậu HELD, currentHold = holdId, heldPrice = price; lỗi SeatUnavailableError(NOT_AVAILABLE). MarkSold: tiền HELD và currentHold = holdId, hậu SOLD, xoá currentHold, đặt currentTicket; lỗi LinkMismatchError | P12 F2, F3; F6.2 |
| Bất biến | state HELD khi và chỉ khi có currentHold; SOLD khi và chỉ khi có currentTicket (P13 ck_seat_status_state_link) | P12 F6.4; P13-schema.sql |
| Không áp dụng | Không áp dụng: F2.6.4 (mỗi operation một điều kiện trạng thái) | - |

#### F2.6.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-16 | state (HoldFor) | AVAILABLE | Hợp lệ | ghế Trống | ST-02 STT 2 |
| EC-17 | state (HoldFor) | HELD hoặc SOLD | Không hợp lệ | HELD bởi H2; SOLD | ST-02 (bị từ chối) |
| EC-18 | state, currentHold (MarkSold) | HELD và currentHold = holdId | Hợp lệ | HELD bởi H1 | ST-02 STT 3 |
| EC-19 | state, currentHold (MarkSold) | HELD nhưng currentHold khác holdId | Không hợp lệ | HELD bởi H2, gọi với H1 | ST-02 (bị từ chối) |
| EC-20 | state (MarkSold) | AVAILABLE hoặc SOLD | Không hợp lệ | AVAILABLE; SOLD | ST-02 (bị từ chối) |

#### F2.6.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-14 | Trống | holdFor(holdId, price) [state = AVAILABLE] | đúng | Trả nil | Đang được giữ | ST-02 STT 2 |
| CT-15 | Đang được giữ / Đã bán | holdFor | sai | SeatUnavailableError(NOT_AVAILABLE) | Không đổi | ST-02 (bị từ chối) |
| CT-16 | Đang được giữ | markSold(holdId, ticketId) [currentHold = holdId] | đúng | Trả nil | Đã bán | ST-02 STT 3 |
| CT-17 | Đang được giữ | markSold khi currentHold khác holdId | sai | LinkMismatchError | Không đổi | ST-02 (bị từ chối) |
| CT-18 | Trống / Đã bán | markSold | sai | LinkMismatchError | Không đổi | ST-02 (bị từ chối) |

#### F2.6.6 Hộp trắng

CFG của DC-SeatStatus.HoldFor:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N13 | bắt đầu | bắt đầu |
| N14 | state = AVAILABLE? | quyết định |
| N15 | state = HELD; currentHold = holdId; heldPrice = price; trả nil | khối lệnh |
| N16 | trả SeatUnavailableError(NOT_AVAILABLE) | khối lệnh |
| N17 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE15 | N13 | N14 |  |
| CE16 | N14 | N15 | Đúng |
| CE17 | N14 | N16 | Sai |
| CE18 | N15 | N17 |  |
| CE19 | N16 | N17 |  |

V(G) = số điểm quyết định nhị phân + 1 = 1 + 1 = 2; kiểm bằng E - N + 2 = 5 - 5 + 2 = 2.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P7 | N13 - N14 - N15 - N17 | TC-030 |
| P8 | N13 - N14 - N16 - N17 | TC-031, TC-032 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE15 | TC-030, TC-031, TC-032 | Có |
| CE16 | TC-030 | Có |
| CE17 | TC-031, TC-032 | Có |
| CE18 | TC-030 | Có |
| CE19 | TC-031, TC-032 | Có |

Độ phủ đạt được: C0 = 3/3 lệnh và điểm quyết định (100%); C1 = 5/5 nhánh (100%).

CFG của DC-SeatStatus.MarkSold:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N18 | bắt đầu | bắt đầu |
| N19 | state = HELD? | quyết định |
| N20 | currentHold = holdId? | quyết định |
| N21 | state = SOLD; xoá currentHold; currentTicket = ticketId; trả nil | khối lệnh |
| N22 | trả LinkMismatchError | khối lệnh |
| N23 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE20 | N18 | N19 |  |
| CE21 | N19 | N20 | Đúng |
| CE22 | N19 | N22 | Sai |
| CE23 | N20 | N21 | Đúng |
| CE24 | N20 | N22 | Sai |
| CE25 | N21 | N23 |  |
| CE26 | N22 | N23 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P9 | N18 - N19 - N20 - N21 - N23 | TC-033 |
| P10 | N18 - N19 - N20 - N22 - N23 | TC-034 |
| P11 | N18 - N19 - N22 - N23 | TC-035, TC-036 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE20 | TC-033, TC-034, TC-035, TC-036 | Có |
| CE21 | TC-033, TC-034 | Có |
| CE22 | TC-035, TC-036 | Có |
| CE23 | TC-033 | Có |
| CE24 | TC-034 | Có |
| CE25 | TC-033 | Có |
| CE26 | TC-034, TC-035, TC-036 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 7/7 nhánh (100%).

#### F2.6.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.7 DC-SeatStatus.ReleaseHold, ReleaseTicket

#### F2.7.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | ReleaseHold(holdId) bool; ReleaseTicket(ticketId) bool | P12 F2 |
| Hậu điều kiện | ReleaseHold: về AVAILABLE chỉ khi HELD và currentHold = holdId, xoá currentHold và heldPrice, trả true; ngược lại không đổi, trả false. ReleaseTicket: tương tự với SOLD và currentTicket = ticketId | P12 F2, F3 |
| BR | REQ-76, BR-42 (ghế của vé huỷ trả về trống), R-63, R-64 (liên kết hiện tại), X-13, X-18 | P12 F2; P08 F4b |
| Không áp dụng | Không áp dụng: F2.7.4 (một điều kiện theo từng operation) | - |

#### F2.7.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-21 | state, currentHold (ReleaseHold) | HELD và currentHold = holdId | Hợp lệ (true) | HELD bởi H1 | ST-02 STT 4 |
| EC-22 | state, currentHold (ReleaseHold) | HELD nhưng currentHold khác holdId | Không hợp lệ (false) | HELD bởi H2 | R-63; X-18 |
| EC-23 | state (ReleaseHold) | AVAILABLE hoặc SOLD | Không hợp lệ (false) | AVAILABLE; SOLD | ST-02 (bị bỏ qua) |
| EC-24 | state, currentTicket (ReleaseTicket) | SOLD và currentTicket = ticketId | Hợp lệ (true) | SOLD bởi TK1 | ST-02 STT 5 |
| EC-25 | state, currentTicket (ReleaseTicket) | SOLD nhưng currentTicket khác ticketId | Không hợp lệ (false) | SOLD bởi TK9 | R-64; X-18 |
| EC-26 | state (ReleaseTicket) | AVAILABLE hoặc HELD | Không hợp lệ (false) | AVAILABLE; HELD | ST-02 (bị bỏ qua) |

#### F2.7.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-19 | Đang được giữ | releaseHold(holdId) [currentHold = holdId] | đúng | Trả true | Trống | ST-02 STT 4 |
| CT-20 | Đang được giữ | releaseHold khi currentHold khác holdId | sai | Trả false | Không đổi | ST-02 (bị bỏ qua) |
| CT-21 | Trống / Đã bán | releaseHold | - | Trả false | Không đổi | ST-02 (bị bỏ qua) |
| CT-22 | Đã bán | releaseTicket(ticketId) [currentTicket = ticketId] | đúng | Trả true | Trống | ST-02 STT 5 |
| CT-23 | Đã bán | releaseTicket khi currentTicket khác ticketId | sai | Trả false | Không đổi | ST-02 (bị bỏ qua) |
| CT-24 | Trống / Đang được giữ | releaseTicket | - | Trả false | Không đổi | ST-02 (bị bỏ qua) |

#### F2.7.6 Hộp trắng

CFG của DC-SeatStatus.ReleaseHold:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N24 | bắt đầu | bắt đầu |
| N25 | state = HELD? | quyết định |
| N26 | currentHold = holdId? | quyết định |
| N27 | state = AVAILABLE; xoá currentHold, heldPrice; trả true | khối lệnh |
| N28 | trả false | khối lệnh |
| N29 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE27 | N24 | N25 |  |
| CE28 | N25 | N26 | Đúng |
| CE29 | N25 | N28 | Sai |
| CE30 | N26 | N27 | Đúng |
| CE31 | N26 | N28 | Sai |
| CE32 | N27 | N29 |  |
| CE33 | N28 | N29 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P12 | N24 - N25 - N26 - N27 - N29 | TC-037 |
| P13 | N24 - N25 - N26 - N28 - N29 | TC-038 |
| P14 | N24 - N25 - N28 - N29 | TC-039, TC-040, TC-041 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE27 | TC-037, TC-038, TC-039, TC-040, TC-041 | Có |
| CE28 | TC-037, TC-038 | Có |
| CE29 | TC-039, TC-040, TC-041 | Có |
| CE30 | TC-037 | Có |
| CE31 | TC-038 | Có |
| CE32 | TC-037 | Có |
| CE33 | TC-038, TC-039, TC-040, TC-041 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 7/7 nhánh (100%).

CFG của DC-SeatStatus.ReleaseTicket:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N30 | bắt đầu | bắt đầu |
| N31 | state = SOLD? | quyết định |
| N32 | currentTicket = ticketId? | quyết định |
| N33 | state = AVAILABLE; xoá currentTicket, heldPrice; trả true | khối lệnh |
| N34 | trả false | khối lệnh |
| N35 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE34 | N30 | N31 |  |
| CE35 | N31 | N32 | Đúng |
| CE36 | N31 | N34 | Sai |
| CE37 | N32 | N33 | Đúng |
| CE38 | N32 | N34 | Sai |
| CE39 | N33 | N35 |  |
| CE40 | N34 | N35 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P15 | N30 - N31 - N32 - N33 - N35 | TC-042 |
| P16 | N30 - N31 - N32 - N34 - N35 | TC-043 |
| P17 | N30 - N31 - N34 - N35 | TC-044, TC-045 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE34 | TC-042, TC-043, TC-044, TC-045 | Có |
| CE35 | TC-042, TC-043 | Có |
| CE36 | TC-044, TC-045 | Có |
| CE37 | TC-042 | Có |
| CE38 | TC-043 | Có |
| CE39 | TC-042 | Có |
| CE40 | TC-043, TC-044, TC-045 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 7/7 nhánh (100%).

#### F2.7.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.8 DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate

#### F2.8.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | MarkTicketed(gatewayTransactionNo, paidAt) error; MarkLatePayment(gatewayTransactionNo, paidAt, reason) error; RecordFailure() bool; RecordDuplicate() error | P12 F2 |
| Hậu điều kiện | MarkTicketed: PENDING --> TICKETED, lưu mã cổng và paidAt. MarkLatePayment: PENDING hoặc FAILED --> LATE_PAYMENT, lưu lý do. RecordFailure: PENDING --> FAILED; FAILED, TICKETED, LATE_PAYMENT không đổi, trả false, không lưu mã cổng. RecordDuplicate: chỉ TICKETED hoặc LATE_PAYMENT, duplicateReportCount tăng 1; trạng thái khác PaymentStateError | P12 F2, F3, F6.2 |
| Quan sát hậu điều kiện | Chỉ có Status(), PaidAt(), IsProcessed(); duplicateReportCount, lateReason, gatewayTransactionNo, refundedTotal không có getter. TC ghi kết quả theo hậu điều kiện và dùng getter đề xuất (Đề xuất sửa P12 dòng 1) | P12 F2; Bước 0 |
| BR | BR-14, BR-15 (thanh toán trễ), BR-37 (xử lý một lần, báo trùng), BR-39 (thất bại chỉ ghi nhận), BR-40 | P06 |
| Không áp dụng | Không áp dụng: F2.8.2 đến F2.8.4 (không có tham số có miền thứ tự; kết quả hoàn toàn theo ma trận trạng thái-sự kiện ở F2.8.5) | - |

#### F2.8.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-25 | Chưa xử lý (PENDING) | MarkTicketed | [PENDING] | Trả nil | Đã tạo vé | ST-05 STT 2 |
| CT-26 | Chưa xử lý (PENDING) | MarkLatePayment | [PENDING] | Trả nil | Đã ghi nhận thanh toán trễ | ST-05 STT 3 |
| CT-27 | Chưa xử lý (PENDING) | RecordFailure | [PENDING] | Trả true | Đã ghi nhận thất bại | ST-05 STT 4 |
| CT-28 | Chưa xử lý (PENDING) | RecordDuplicate | - | PaymentStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-29 | Đã ghi nhận thất bại (FAILED) | MarkTicketed | - | PaymentStateError | Không đổi | P12 F2 (tiền: PENDING) |
| CT-30 | Đã ghi nhận thất bại (FAILED) | MarkLatePayment | [FAILED] | Trả nil | Đã ghi nhận thanh toán trễ | ST-05 STT 5 |
| CT-31 | Đã ghi nhận thất bại (FAILED) | RecordFailure | - | Trả false | Không đổi | P12 F6.2 (chỉ ghi nhận) |
| CT-32 | Đã ghi nhận thất bại (FAILED) | RecordDuplicate | - | PaymentStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-33 | Đã tạo vé (TICKETED) | MarkTicketed | - | PaymentStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-34 | Đã tạo vé (TICKETED) | MarkLatePayment | - | PaymentStateError | Không đổi | P12 F6.2 (báo trùng) |
| CT-35 | Đã tạo vé (TICKETED) | RecordFailure | - | Trả false | Không đổi | P12 F6.2; BR-39 |
| CT-36 | Đã tạo vé (TICKETED) | RecordDuplicate | [TICKETED] | Trả nil, duplicateReportCount + 1 | Đã tạo vé | ST-05 STT 6 |
| CT-37 | Đã ghi nhận thanh toán trễ (LATE_PAYMENT) | MarkTicketed | - | PaymentStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-38 | Đã ghi nhận thanh toán trễ (LATE_PAYMENT) | MarkLatePayment | - | PaymentStateError | Không đổi | P12 F3 (chỉ từ PENDING hoặc FAILED) |
| CT-39 | Đã ghi nhận thanh toán trễ (LATE_PAYMENT) | RecordFailure | - | Trả false | Không đổi | P12 F6.2; BR-39 |
| CT-40 | Đã ghi nhận thanh toán trễ (LATE_PAYMENT) | RecordDuplicate | [LATE_PAYMENT] | Trả nil, duplicateReportCount + 1 | Đã ghi nhận thanh toán trễ | ST-05 STT 7 |

#### F2.8.6 Hộp trắng

CFG của DC-PaymentTransaction.MarkTicketed:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N36 | bắt đầu | bắt đầu |
| N37 | status = PENDING? | quyết định |
| N38 | status = TICKETED; lưu mã cổng, paidAt; trả nil | khối lệnh |
| N39 | trả PaymentStateError | khối lệnh |
| N40 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE41 | N36 | N37 |  |
| CE42 | N37 | N38 | Đúng |
| CE43 | N37 | N39 | Sai |
| CE44 | N38 | N40 |  |
| CE45 | N39 | N40 |  |

V(G) = số điểm quyết định nhị phân + 1 = 1 + 1 = 2; kiểm bằng E - N + 2 = 5 - 5 + 2 = 2.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P18 | N36 - N37 - N38 - N40 | TC-046 |
| P19 | N36 - N37 - N39 - N40 | TC-050, TC-054, TC-058 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE41 | TC-046, TC-050, TC-054, TC-058 | Có |
| CE42 | TC-046 | Có |
| CE43 | TC-050, TC-054, TC-058 | Có |
| CE44 | TC-046 | Có |
| CE45 | TC-050, TC-054, TC-058 | Có |

Độ phủ đạt được: C0 = 3/3 lệnh và điểm quyết định (100%); C1 = 5/5 nhánh (100%).

CFG của DC-PaymentTransaction.MarkLatePayment:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N41 | bắt đầu | bắt đầu |
| N42 | status = PENDING? | quyết định |
| N43 | status = FAILED? | quyết định |
| N44 | status = LATE_PAYMENT; lưu lateReason, mã cổng, paidAt; trả nil | khối lệnh |
| N45 | trả PaymentStateError | khối lệnh |
| N46 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE46 | N41 | N42 |  |
| CE47 | N42 | N44 | Đúng |
| CE48 | N42 | N43 | Sai |
| CE49 | N43 | N44 | Đúng |
| CE50 | N43 | N45 | Sai |
| CE51 | N44 | N46 |  |
| CE52 | N45 | N46 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P20 | N41 - N42 - N44 - N46 | TC-047 |
| P21 | N41 - N42 - N43 - N44 - N46 | TC-051 |
| P22 | N41 - N42 - N43 - N45 - N46 | TC-055, TC-059 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE46 | TC-047, TC-051, TC-055, TC-059 | Có |
| CE47 | TC-047 | Có |
| CE48 | TC-051, TC-055, TC-059 | Có |
| CE49 | TC-051 | Có |
| CE50 | TC-055, TC-059 | Có |
| CE51 | TC-047, TC-051 | Có |
| CE52 | TC-055, TC-059 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 7/7 nhánh (100%).

CFG của DC-PaymentTransaction.RecordFailure:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N47 | bắt đầu | bắt đầu |
| N48 | status = PENDING? | quyết định |
| N49 | status = FAILED; trả true | khối lệnh |
| N50 | trả false | khối lệnh |
| N51 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE53 | N47 | N48 |  |
| CE54 | N48 | N49 | Đúng |
| CE55 | N48 | N50 | Sai |
| CE56 | N49 | N51 |  |
| CE57 | N50 | N51 |  |

V(G) = số điểm quyết định nhị phân + 1 = 1 + 1 = 2; kiểm bằng E - N + 2 = 5 - 5 + 2 = 2.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P23 | N47 - N48 - N49 - N51 | TC-048 |
| P24 | N47 - N48 - N50 - N51 | TC-052, TC-056, TC-060 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE53 | TC-048, TC-052, TC-056, TC-060 | Có |
| CE54 | TC-048 | Có |
| CE55 | TC-052, TC-056, TC-060 | Có |
| CE56 | TC-048 | Có |
| CE57 | TC-052, TC-056, TC-060 | Có |

Độ phủ đạt được: C0 = 3/3 lệnh và điểm quyết định (100%); C1 = 5/5 nhánh (100%).

CFG của DC-PaymentTransaction.RecordDuplicate:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N52 | bắt đầu | bắt đầu |
| N53 | status = TICKETED? | quyết định |
| N54 | status = LATE_PAYMENT? | quyết định |
| N55 | duplicateReportCount + 1; trả nil | khối lệnh |
| N56 | trả PaymentStateError | khối lệnh |
| N57 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE58 | N52 | N53 |  |
| CE59 | N53 | N55 | Đúng |
| CE60 | N53 | N54 | Sai |
| CE61 | N54 | N55 | Đúng |
| CE62 | N54 | N56 | Sai |
| CE63 | N55 | N57 |  |
| CE64 | N56 | N57 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 7 - 6 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P25 | N52 - N53 - N55 - N57 | TC-057, TC-062 |
| P26 | N52 - N53 - N54 - N55 - N57 | TC-061 |
| P27 | N52 - N53 - N54 - N56 - N57 | TC-049, TC-053 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE58 | TC-049, TC-053, TC-057, TC-061, TC-062 | Có |
| CE59 | TC-057, TC-062 | Có |
| CE60 | TC-049, TC-053, TC-061 | Có |
| CE61 | TC-061 | Có |
| CE62 | TC-049, TC-053 | Có |
| CE63 | TC-057, TC-061, TC-062 | Có |
| CE64 | TC-049, TC-053 | Có |

Độ phủ đạt được: C0 = 4/4 lệnh và điểm quyết định (100%); C1 = 7/7 nhánh (100%).

#### F2.8.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.9 DC-PaymentTransaction.CheckRefundWithin, RecordRefunded

#### F2.9.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckRefundWithin(amount Money) error; RecordRefunded(amount Money) error | P12 F2 |
| BR | BR-26: tổng đã hoàn của một giao dịch không vượt số tiền đã thanh toán, nên refundedTotal + amount <= amount của giao dịch | P06 |
| Hậu | RecordRefunded cộng amount vào refundedTotal trong bộ nhớ sau CheckRefundWithin; vượt hạn: RefundLimitError, không đổi. CSDL cộng bằng IF-19.AddRefunded (ngoài operation này) | P12 F2 |
| Chưa nêu | amount <= 0; amount âm | Q-144 |
| Không áp dụng | Không áp dụng: F2.9.4 (một điều kiện), F2.9.5 (không là sự kiện ST), F2.9.6 (một rẽ nhánh, phủ bằng F2.9.3) | - |

#### F2.9.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-27 | refundedTotal + amount | <= số đã thanh toán | Hợp lệ | 0 + 63.000 trên giao dịch 100.000 | BR-26 |
| EC-28 | refundedTotal + amount | > số đã thanh toán | Không hợp lệ | 70.000 + 63.000 trên 100.000 | BR-26 |
| EC-29 | amount | <= 0 | Không hợp lệ | 0 | P12 F2 không nêu --> Q-144 |

#### F2.9.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-12 | max của EC-27 | refundedTotal 0, amount 100.000 (bằng đúng số đã thanh toán) | EC-27 | Không ngoại lệ |
| BV-13 | max của EC-27 | refundedTotal 0, amount 100.001 | EC-28 | RefundLimitError |
| BV-14 | max của EC-27 | refundedTotal 70.000, amount 30.000 | EC-27 | Không ngoại lệ |
| BV-15 | max của EC-27 | refundedTotal 70.000, amount 30.001 | EC-28 | RefundLimitError |

#### F2.9.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.10 DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund

#### F2.10.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | NewFullRefund(txn, amount); NewTicketRefund(txn, ticket, amount); NewCashRefund(ticket, amount) | P12 F2 |
| Hậu điều kiện | Full: khoá = mã giao dịch + "-FULL", NEW. Ticket: khoá = mã giao dịch + "-T" + mã vé, NEW. Cash: không gắn giao dịch, trạng thái REFUNDED | P12 F2; ST-04 STT 1-3 |
| BR | BR-43: khoá gắn với từng yêu cầu hoàn và phân biệt được với yêu cầu khác trên cùng giao dịch; BR-20 (vé quầy hoàn tiền mặt) | P06 |
| Quan sát | Không có getter requestType và refundResult (Đề xuất sửa P12 dòng 2); TC ghi theo hậu điều kiện | P12 F2 |
| Không áp dụng | Không áp dụng: F2.10.3, F2.10.4 (không có miền thứ tự), F2.10.6 (hàm dựng không rẽ nhánh) | - |

#### F2.10.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-30 | loại yêu cầu | hoàn toàn bộ (FULL) | Hợp lệ | txn code 20260001, amount 100.000 | BR-43 |
| EC-31 | loại yêu cầu | hoàn một vé qua cổng (TICKET_GATEWAY) | Hợp lệ | txn 20260001, vé 9, amount 63.000 | BR-43 |
| EC-32 | loại yêu cầu | hoàn tiền mặt (TICKET_CASH) | Hợp lệ | vé 9, amount 63.000 | BR-20 |
| EC-33 | amount, txn, ticket | amount <= 0, txn hoặc ticket nil | Không hợp lệ | amount 0 | P12 F2 không nêu --> Q-144 |

#### F2.10.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-41 | (initial) | create(requestType = FULL hoặc TICKET_GATEWAY) [else] | else | Tạo yêu cầu hoàn | Mới (NEW), attemptCount = 0 | ST-04 STT 1, 3 |
| CT-42 | (initial) | create(requestType = TICKET_CASH) [TICKET_CASH] | đúng | Tạo yêu cầu hoàn | Đã hoàn (REFUNDED) | ST-04 STT 1, 2 |

#### F2.10.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-PaymentTransaction, DC-Ticket | stub | Dùng đối tượng thật: txn.Code() = "20260001"; ticket.ID() = 9 | Đối tượng miền thuần |

### F2.11 DC-RefundRequest.BeginAttempt

#### F2.11.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | BeginAttempt() error | P12 F2 |
| Hậu điều kiện | NEW hoặc WAITING_RETRY --> IN_FLIGHT, attemptCount + 1; IN_FLIGHT --> IN_FLIGHT khi nhận lại claim, attemptCount + 1; chỉ khi HasAttemptsRemaining (attemptCount < MaxAttempts = 4). Hết lượt: RefundStateError | P12 F2, F6.2 (STT 4, 5, 6) |
| Ngoại lệ | RefundStateError ở REFUNDED, MANUAL_REQUIRED. F6.2 còn nêu 'beginAttempt khi claim còn hiệu lực' bị từ chối, nhưng operation không có tham số claim: việc chặn do IF-23.ExtendClaim (ngoài entity) --> Đề xuất sửa P12 dòng 6 | P12 F6.2 |
| BR | BR-41 (thử lại vài lần), BR-43 (lần đầu cộng ba lần thử lại: MaxAttempts = 4) | P06; P12 F3 |
| Không áp dụng | Không áp dụng: F2.11.4 (hai điều kiện, status và lượt còn; tổ hợp gộp ở F2.11.5 và CFG) | - |

#### F2.11.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-34 | status | NEW | Hợp lệ | NEW, attemptCount 0 | ST-04 STT 4 |
| EC-35 | status | WAITING_RETRY | Hợp lệ | WAITING_RETRY, attemptCount 2 | ST-04 STT 5 |
| EC-36 | status | IN_FLIGHT (nhận lại claim sau khi tiến trình chết) | Hợp lệ | IN_FLIGHT, attemptCount 2 | ST-04 STT 6 |
| EC-37 | status | REFUNDED hoặc MANUAL_REQUIRED | Không hợp lệ | REFUNDED; MANUAL_REQUIRED | P12 F6.2 |
| EC-38 | attemptCount (IN_FLIGHT) | attemptCount < 4 (còn lượt) | Hợp lệ | 3 | BR-41 |
| EC-39 | attemptCount (IN_FLIGHT) | attemptCount >= 4 (hết lượt) | Không hợp lệ | 4 | BR-41 |

#### F2.11.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-16 | max của EC-38 | attemptCount 3 --> sau BeginAttempt = 4 | EC-38 | Không ngoại lệ; AttemptCount = 4 |
| BV-17 | max của EC-38 | attemptCount 4 | EC-39 | RefundStateError; AttemptCount vẫn 4 |

#### F2.11.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-43 | Mới | beginAttempt() | - | Trả nil, attemptCount + 1 | Đang chờ kết quả | ST-04 STT 4 |
| CT-44 | Chờ gửi lại | beginAttempt() | - | Trả nil, attemptCount + 1 | Đang chờ kết quả | ST-04 STT 5 |
| CT-45 | Đang chờ kết quả | beginAttempt() [nhận lại claim, attemptCount < MaxAttempts] | đúng | Trả nil, attemptCount + 1 | Đang chờ kết quả | ST-04 STT 6 |
| CT-46 | Đang chờ kết quả | beginAttempt() [attemptCount >= MaxAttempts] | sai | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-47 | Đã hoàn / Cần xử lý thủ công | beginAttempt() | - | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |

#### F2.11.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N58 | bắt đầu | bắt đầu |
| N59 | status thuộc NEW, WAITING_RETRY, IN_FLIGHT? | quyết định |
| N60 | HasAttemptsRemaining? | quyết định |
| N61 | attemptCount + 1; status = IN_FLIGHT; trả nil | khối lệnh |
| N62 | trả RefundStateError (trạng thái không cho phép) | khối lệnh |
| N63 | trả RefundStateError (hết lượt) | khối lệnh |
| N64 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE65 | N58 | N59 |  |
| CE66 | N59 | N60 | Đúng |
| CE67 | N59 | N62 | Sai |
| CE68 | N60 | N61 | Đúng |
| CE69 | N60 | N63 | Sai |
| CE70 | N61 | N64 |  |
| CE71 | N62 | N64 |  |
| CE72 | N63 | N64 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 8 - 7 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P28 | N58 - N59 - N60 - N61 - N64 | TC-075, TC-076 |
| P29 | N58 - N59 - N62 - N64 | TC-080 |
| P30 | N58 - N59 - N60 - N63 - N64 | TC-079 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE65 | TC-075, TC-076, TC-079, TC-080 | Có |
| CE66 | TC-075, TC-076, TC-079 | Có |
| CE67 | TC-080 | Có |
| CE68 | TC-075, TC-076 | Có |
| CE69 | TC-079 | Có |
| CE70 | TC-075, TC-076 | Có |
| CE71 | TC-080 | Có |
| CE72 | TC-079 | Có |

Độ phủ đạt được: C0 = 5/5 lệnh và điểm quyết định (100%); C1 = 8/8 nhánh (100%).

Nhánh không thể đi tới theo thiết kế: BeginAttempt ở NEW hoặc WAITING_RETRY với attemptCount >= 4. NEW luôn có attemptCount 0; WAITING_RETRY chỉ được tạo bởi RecordResult khi còn lượt (attemptCount < 4, F6.2 STT 8) nên bất biến chặn. Không thiết kế TC ép giá trị trái đặc tả; HasAttemptsRemaining trên hai trạng thái này luôn true. Đề xuất P12: ghi bất biến này, chỉ giữ điều kiện hết lượt cho IN_FLIGHT.

#### F2.11.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần; trạng thái đầu dựng bằng chuỗi NewFullRefund, BeginAttempt, RecordResult(REJECTED) | Không cần double |

### F2.12 DC-RefundRequest.RecordResult

#### F2.12.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | RecordResult(r AttemptResult, detail string) error | P12 F2 |
| Hậu điều kiện | Yêu cầu IN_FLIGHT. SUCCEEDED --> REFUNDED. REJECTED hoặc UNKNOWN: còn lượt (attemptCount < 4) --> WAITING_RETRY, hết lượt --> MANUAL_REQUIRED. Ghi detail vào refundResult | P12 F2, F3; ST-04 STT 7, 8, 9 |
| Ngoại lệ | RefundStateError khi không ở IN_FLIGHT (F6.2: NEW, WAITING_RETRY, REFUNDED, MANUAL_REQUIRED) | P12 F2, F6.2 |
| BR | BR-41: thử lại vài lần, hết lượt thì xử lý thủ công | P06 |
| Không áp dụng | Không áp dụng: F2.12.4 (kết quả theo (status, r, lượt) trình bày ở F2.12.5) | - |

#### F2.12.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-40 | status | IN_FLIGHT | Hợp lệ | IN_FLIGHT | ST-04 |
| EC-41 | status | NEW, WAITING_RETRY, REFUNDED, MANUAL_REQUIRED | Không hợp lệ | NEW; WAITING_RETRY; REFUNDED; MANUAL_REQUIRED | P12 F6.2 |
| EC-42 | r | SUCCEEDED | Hợp lệ | SUCCEEDED | ST-04 STT 7 |
| EC-43 | r, attemptCount | REJECTED hoặc UNKNOWN và attemptCount < 4 | Hợp lệ | REJECTED, 1 | ST-04 STT 8 |
| EC-44 | r, attemptCount | REJECTED hoặc UNKNOWN và attemptCount >= 4 | Hợp lệ | UNKNOWN, 4 | ST-04 STT 9 |

#### F2.12.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-18 | max của EC-43 (attemptCount) | attemptCount 3 với REJECTED | EC-43 | WAITING_RETRY |
| BV-19 | min của EC-44 (attemptCount) | attemptCount 4 với REJECTED | EC-44 | MANUAL_REQUIRED |

#### F2.12.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-48 | Đang chờ kết quả | recordResult(SUCCEEDED) | - | Trả nil | Đã hoàn | ST-04 STT 7 |
| CT-49 | Đang chờ kết quả | recordResult(REJECTED hoặc UNKNOWN) [attemptCount < MaxAttempts] | đúng | Trả nil | Chờ gửi lại | ST-04 STT 8 |
| CT-50 | Đang chờ kết quả | recordResult(REJECTED hoặc UNKNOWN) [attemptCount >= MaxAttempts] | sai | Trả nil | Cần xử lý thủ công | ST-04 STT 9 |
| CT-51 | Mới / Chờ gửi lại / Đã hoàn / Cần xử lý thủ công | recordResult | - | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |

#### F2.12.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N65 | bắt đầu | bắt đầu |
| N66 | status = IN_FLIGHT? | quyết định |
| N67 | r = SUCCEEDED? | quyết định |
| N68 | HasAttemptsRemaining? | quyết định |
| N69 | trả RefundStateError | khối lệnh |
| N70 | status = REFUNDED; ghi detail | khối lệnh |
| N71 | status = WAITING_RETRY; ghi detail | khối lệnh |
| N72 | status = MANUAL_REQUIRED; ghi detail | khối lệnh |
| N73 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE73 | N65 | N66 |  |
| CE74 | N66 | N67 | Đúng |
| CE75 | N66 | N69 | Sai |
| CE76 | N67 | N70 | Đúng |
| CE77 | N67 | N68 | Sai |
| CE78 | N68 | N71 | Đúng |
| CE79 | N68 | N72 | Sai |
| CE80 | N69 | N73 |  |
| CE81 | N70 | N73 |  |
| CE82 | N71 | N73 |  |
| CE83 | N72 | N73 |  |

V(G) = số điểm quyết định nhị phân + 1 = 3 + 1 = 4; kiểm bằng E - N + 2 = 11 - 9 + 2 = 4.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P31 | N65 - N66 - N69 - N73 | TC-089 |
| P32 | N65 - N66 - N67 - N70 - N73 | TC-082 |
| P33 | N65 - N66 - N67 - N68 - N71 - N73 | TC-084 |
| P34 | N65 - N66 - N67 - N68 - N72 - N73 | TC-087 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE73 | TC-082, TC-084, TC-087, TC-089 | Có |
| CE74 | TC-082, TC-084, TC-087 | Có |
| CE75 | TC-089 | Có |
| CE76 | TC-082 | Có |
| CE77 | TC-084, TC-087 | Có |
| CE78 | TC-084 | Có |
| CE79 | TC-087 | Có |
| CE80 | TC-089 | Có |
| CE81 | TC-082 | Có |
| CE82 | TC-084 | Có |
| CE83 | TC-087 | Có |

Độ phủ đạt được: C0 = 7/7 lệnh và điểm quyết định (100%); C1 = 11/11 nhánh (100%).

#### F2.12.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần; trạng thái đầu dựng bằng BeginAttempt lặp (attemptCount = số lần gọi) | Không cần double |

### F2.13 DC-RefundRequest.MarkManualRequired

#### F2.13.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | MarkManualRequired(reason string) error | P12 F2 |
| Hậu điều kiện | Chuyển MANUAL_REQUIRED từ IN_FLIGHT; trạng thái cuối, không có đường đặt lại (Q-135) | P12 F2, F6.2 STT 10 |
| Ngoại lệ | RefundStateError ở NEW, WAITING_RETRY, REFUNDED, MANUAL_REQUIRED | P12 F6.2 |
| Không áp dụng | Không áp dụng: F2.13.2 đến F2.13.4 (một điều kiện, phủ bằng F2.13.5), F2.13.6 (một rẽ nhánh) | - |

#### F2.13.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-52 | Đang chờ kết quả | markManualRequired(reason) [findRefund NOT_SUPPORTED hoặc UNREACHABLE, hoặc nhận lại claim khi hết lượt] | đúng | Trả nil | Cần xử lý thủ công | ST-04 STT 10 |
| CT-53 | Mới | markManualRequired | - | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-54 | Chờ gửi lại | markManualRequired | - | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-55 | Đã hoàn | markManualRequired | - | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |
| CT-56 | Cần xử lý thủ công | markManualRequired | - | RefundStateError | Không đổi | P12 F6.2 (bị từ chối) |

#### F2.13.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.14 DC-Ticket.Cancel

#### F2.14.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Cancel() error | P12 F2 |
| Hậu điều kiện | UNUSED --> CANCELLED; kiểm đã huỷ trước, đã sử dụng sau; lỗi TicketStateError mang status | P12 F2, F3; F6.2 |
| BR | BR-21 (mỗi vé huỷ một lần), BR-30 (vé đã sử dụng không huỷ được) | P06 |
| Không áp dụng | Không áp dụng: F2.14.4 (một điều kiện status), F2.14.6 (rẽ nhánh đơn giản, phủ bằng F2.14.5) | - |

#### F2.14.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-45 | status | UNUSED | Hợp lệ | UNUSED | ST-03 STT 3 |
| EC-46 | status | CANCELLED | Không hợp lệ | CANCELLED | BR-21 |
| EC-47 | status | USED | Không hợp lệ | USED | BR-30 |

#### F2.14.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-57 | Chưa sử dụng | cancel() [đã qua kiểm hạn huỷ và kênh ở bên gọi] | đúng | Trả nil | Đã huỷ | ST-03 STT 3 |
| CT-58 | Đã huỷ | cancel() | - | TicketStateError(CANCELLED) | Không đổi | P12 F6.2 (bị từ chối) |
| CT-59 | Đã sử dụng | cancel() | - | TicketStateError(USED) | Không đổi | P12 F6.2 (bị từ chối) |

#### F2.14.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.15 DC-Ticket.Admit

#### F2.15.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Admit(showtime *Showtime, selected ShowtimeId, cinemaId CinemaId) AdmitOutcome | P12 F2 |
| Hậu điều kiện | Kiểm theo thứ tự cụm rạp, suất chiếu, đã sử dụng, đã huỷ; hợp lệ thì USED và trả ADMITTED; ngược lại một lý do duy nhất, không đổi | P12 F2, F3 |
| BR | BR-22 (đúng cụm rạp), BR-23 (đúng suất chiếu), BR-24 (một lần), BR-25 (vé huỷ không soát), BR-33 (thứ tự lý do: cụm rạp, suất chiếu, đã sử dụng, đã huỷ) | P06 |
| Luồng P04 | UC-009 4b (cụm rạp khác), 4c (suất chiếu khác), 4d (đã sử dụng), 4e (đã huỷ) | P04 UC-009 |
| Không áp dụng | Không áp dụng: F2.15.3 (không có miền thứ tự) | - |

#### F2.15.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-48 | cinemaId so với cụm rạp của suất chiếu | đúng cụm rạp | Hợp lệ | cụm rạp 2 | BR-22 |
| EC-49 | cinemaId so với cụm rạp của suất chiếu | khác cụm rạp | Không hợp lệ (WRONG_CINEMA) | cụm rạp 3 | BR-22 |
| EC-50 | selected so với ID suất chiếu | đúng suất chiếu | Hợp lệ | suất 55 | BR-23 |
| EC-51 | selected so với ID suất chiếu | khác suất chiếu | Không hợp lệ (WRONG_SHOWTIME) | suất 56 | BR-23 |
| EC-52 | status | UNUSED | Hợp lệ | UNUSED | BR-24 |
| EC-53 | status | USED | Không hợp lệ (ALREADY_USED) | USED | BR-24 |
| EC-54 | status | CANCELLED | Không hợp lệ (CANCELLED) | CANCELLED | BR-25 |

#### F2.15.4 Bảng quyết định (DT1)

```text
| Điều kiện / Hành động | DT1-R1 | DT1-R2 | DT1-R3 | DT1-R4 | DT1-R5 | DT1-R6 |
| C1: đúng cụm rạp của suất chiếu | N | Y | Y | Y | Y | N/A |
| C2: đúng suất chiếu đã chọn | - | N | Y | Y | Y | N/A |
| C3: status = USED | - | - | Y | N | N | N/A |
| C4: status = CANCELLED | - | - | N | Y | N | N/A |
| A1: WRONG_CINEMA | X | - | - | - | - | N/A |
| A2: WRONG_SHOWTIME | - | X | - | - | - | N/A |
| A3: ALREADY_USED | - | - | X | - | - | N/A |
| A4: CANCELLED | - | - | - | X | - | N/A |
| A5: ADMITTED, status = USED | - | - | - | - | X | N/A |
```

Căn cứ: Gộp bằng - có căn cứ BR-33 (P06) và F2: lý do được báo theo thứ tự cụm rạp, suất chiếu, đã sử dụng, đã huỷ nên điều kiện đứng sau không ảnh hưởng khi điều kiện đứng trước sai; P12 F3 trùng thứ tự này.

DT1-R6: N/A, C3 và C4 không cùng đúng (USED và CANCELLED loại trừ nhau).

#### F2.15.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-60 | Chưa sử dụng | admit(showtime, selected, cinemaId) [đúng cụm rạp và đúng suất chiếu] | đúng | ADMITTED | Đã sử dụng | ST-03 STT 2 |
| CT-61 | Chưa sử dụng | admit khi sai cụm rạp | - | WRONG_CINEMA | Không đổi | P12 F6.2 |
| CT-62 | Chưa sử dụng | admit khi sai suất chiếu | - | WRONG_SHOWTIME | Không đổi | P12 F6.2 |
| CT-63 | Đã sử dụng | admit | - | ALREADY_USED | Không đổi | P12 F6.2 |
| CT-64 | Đã huỷ | admit | - | CANCELLED | Không đổi | P12 F6.2 |

#### F2.15.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N74 | bắt đầu | bắt đầu |
| N75 | showtime.BelongsToCinema(cinemaId)? | quyết định |
| N76 | showtime.ID = selected? | quyết định |
| N77 | status = USED? | quyết định |
| N78 | status = CANCELLED? | quyết định |
| N79 | trả WRONG_CINEMA | khối lệnh |
| N80 | trả WRONG_SHOWTIME | khối lệnh |
| N81 | trả ALREADY_USED | khối lệnh |
| N82 | trả CANCELLED | khối lệnh |
| N83 | status = USED; trả ADMITTED | khối lệnh |
| N84 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE84 | N74 | N75 |  |
| CE85 | N75 | N76 | Đúng |
| CE86 | N75 | N79 | Sai |
| CE87 | N76 | N77 | Đúng |
| CE88 | N76 | N80 | Sai |
| CE89 | N77 | N81 | Đúng |
| CE90 | N77 | N78 | Sai |
| CE91 | N78 | N82 | Đúng |
| CE92 | N78 | N83 | Sai |
| CE93 | N79 | N84 |  |
| CE94 | N80 | N84 |  |
| CE95 | N81 | N84 |  |
| CE96 | N82 | N84 |  |
| CE97 | N83 | N84 |  |

V(G) = số điểm quyết định nhị phân + 1 = 4 + 1 = 5; kiểm bằng E - N + 2 = 14 - 11 + 2 = 5.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P35 | N74 - N75 - N79 - N84 | TC-101 |
| P36 | N74 - N75 - N76 - N80 - N84 | TC-103 |
| P37 | N74 - N75 - N76 - N77 - N81 - N84 | TC-105 |
| P38 | N74 - N75 - N76 - N77 - N78 - N82 - N84 | TC-106 |
| P39 | N74 - N75 - N76 - N77 - N78 - N83 - N84 | TC-107 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE84 | TC-101, TC-103, TC-105, TC-106, TC-107 | Có |
| CE85 | TC-103, TC-105, TC-106, TC-107 | Có |
| CE86 | TC-101 | Có |
| CE87 | TC-105, TC-106, TC-107 | Có |
| CE88 | TC-103 | Có |
| CE89 | TC-105 | Có |
| CE90 | TC-106, TC-107 | Có |
| CE91 | TC-106 | Có |
| CE92 | TC-107 | Có |
| CE93 | TC-101 | Có |
| CE94 | TC-103 | Có |
| CE95 | TC-105 | Có |
| CE96 | TC-106 | Có |
| CE97 | TC-107 | Có |

Độ phủ đạt được: C0 = 9/9 lệnh và điểm quyết định (100%); C1 = 14/14 nhánh (100%).

#### F2.15.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-Showtime | stub | Dùng đối tượng thật hoặc stub: BelongsToCinema và ID() theo điều kiện đầu | Showtime thuộc PKG-27, đã chi tiết hoá phần UC-009 |

### F2.16 DC-Ticket.RefundAmount

#### F2.16.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | RefundAmount() Money | P12 F2 |
| Hậu điều kiện | price.Percent(RefundPercent) với RefundPercent = 70, làm tròn xuống đồng | P12 F2, F7; BR-19, BR-31 |
| BR | BR-19: 70% giá vé; BR-31: không tròn đồng thì làm tròn xuống | P06 |
| Không áp dụng | Không áp dụng: F2.16.4, F2.16.5, F2.16.6 (không rẽ nhánh) | - |

#### F2.16.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-55 | price x 70 | chia hết cho 100 (70% tròn đồng) | Hợp lệ | 100.000 | BR-19 |
| EC-56 | price x 70 | không chia hết cho 100 (phần lẻ 0,1 đến 0,9 đồng) | Hợp lệ | 45.007 | BR-31 |
| EC-57 | price | <= 0 | Không hợp lệ | 0 | P13 ck_ticket_price (price > 0); P12 không nêu --> Q-144 |

#### F2.16.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-20 | EC-56 | price 45.005 (phần lẻ đúng 0,5) | EC-56 | 31.503 |
| BV-21 | EC-56 | price 45.007 (phần lẻ 0,9: lớn nhất trong các số lẻ chục) | EC-56 | 31.504 (cắt, không làm tròn lên) |
| BV-22 | EC-56 | price 1 (nhỏ nhất P13 cho phép) | EC-56 | 0 (70% của 1 đồng là 0,7) |

#### F2.16.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.17 DC-Booking.CheckCancellationChannel

#### F2.17.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckCancellationChannel(actor ActorContext) error | P12 F2 |
| Mô tả | Khách chỉ huỷ vé mình mua trực tuyến, nhân viên quầy chỉ huỷ vé mua tại quầy; lỗi ChannelMismatchError | P12 F2; BR-17 |
| Luồng P04 | UC-008 2a (khách, vé quầy hoặc vé người khác), 2b (nhân viên, vé trực tuyến), 2c (nhân viên, vé quầy của cụm rạp khác) | P04 UC-008 |
| Giới hạn của operation | Booking không giữ cụm rạp nên luồng 2c do ConfirmCashRefund kiểm bằng Showtime.BelongsToCinema(clerk.cinemaId) (P12 1.5, Đề xuất sửa P12 dòng 10 đã áp dụng) | P12 F2, F3 |
| Không áp dụng | Không áp dụng: F2.17.2 và F2.17.3 gộp trong bảng quyết định (điều kiện nhị phân), F2.17.5 (không là sự kiện ST), F2.17.6 (không có thiết kế method ở F3 riêng; Đo khi có mã nguồn) | - |

#### F2.17.4 Bảng quyết định (DT2)

```text
| Điều kiện / Hành động | DT2-R1 | DT2-R2 | DT2-R3 | DT2-R4 | DT2-R5 |
| C1: actor là khách | Y | Y | Y | N | N |
| C2: lần đặt mua trực tuyến (người giữ ghế là khách) | Y | Y | N | Y | N |
| C3: người giữ ghế của lần đặt trùng actor (chỉ có nghĩa khi C1, C2 cùng Y) | Y | N | - | - | - |
| A1: cho phép (nil) | X | - | - | - | X |
| A2: ChannelMismatchError | - | X | X | X | - |
```

Căn cứ: Gộp - có căn cứ: các vi phạm UC-008 2a, 2b ghi cùng hành động từ chối (cùng một lỗi), kết quả không phụ thuộc thứ tự. Nhân viên quầy so cụm rạp nằm ngoài operation (xem giới hạn).

#### F2.17.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Booking dựng bằng NewBooking(hold, code, tickets) với hold.Holder kind CUSTOMER 7 hoặc CLERK 3; ActorContext do test dựng | Đối tượng miền thuần |

### F2.18 DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold

#### F2.18.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckNoActiveSeatHold(unfinished []*SeatHold, now time.Time) error (hai lớp cùng chữ ký, cùng quy tắc: X1 RV-08) | P12 F2 |
| Mô tả | Từ chối (HolderBusyError) khi có lần giữ ghế ACTIVE chưa quá hạn trong unfinished | P12 F2 |
| BR | BR-04: mỗi khách và mỗi nhân viên quầy có tối đa một lần giữ ghế chưa kết thúc; kết thúc tại thời điểm hết hạn, không đợi ghế được giải phóng | P06; P04 UC-005 mục 8 |
| Luồng P04 | UC-005 5b, 7c | P04 UC-005 |
| Không áp dụng | Không áp dụng: F2.18.4 (một điều kiện), F2.18.5, F2.18.6 (không có F3 riêng) | - |

#### F2.18.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-58 | unfinished | rỗng hoặc chỉ gồm lần giữ ghế đã ở trạng thái cuối | Hợp lệ (không lỗi) | []; [CANCELLED] | BR-04 |
| EC-59 | unfinished | có lần giữ ghế ACTIVE và now < expiryTime | Không hợp lệ (HolderBusyError) | [ACTIVE] | BR-04 |
| EC-60 | unfinished | có lần giữ ghế ACTIVE nhưng now >= expiryTime (đã quá hạn, chưa Expire) | Hợp lệ (không lỗi) | [ACTIVE quá hạn] | BR-04 (mốc hết hạn); BR-53 |

#### F2.18.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-23 | EC-59 (now so với expiryTime) | now = E - 1ms | EC-59 | HolderBusyError |
| BV-24 | EC-60 (now so với expiryTime) | now = E | EC-60 | Trả nil |

#### F2.18.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-SeatHold | stub | Đối tượng thật (NewSeatHold, expiryTime = E = 10:10:00.000) | Đối tượng miền thuần |

### F2.19 DC-LockOrderGuard.Acquire, AcquireAll

#### F2.19.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Acquire(rank LockRank, key LockKey, exclusive bool) error; AcquireAll(rank, keys []LockKey, exclusive) error; Violated() bool | P12 F2 |
| Hậu điều kiện | Hạng nhỏ hơn maxRank, hoặc cùng hạng mã nhỏ hơn maxKey: vi phạm (LockOrderViolationError, violated = true). Cùng dòng khoá lại với chế độ bằng hoặc yếu hơn: hợp lệ. Nâng S lên X trên cùng dòng: vi phạm. AcquireAll: keys phải tăng dần | P12 F2, F3 |
| Hạng | PRICE_LIST=1, AUDITORIUM=2, SHOWTIME=3, HOLDER=4, SEAT_HOLD=5, SEAT_STATUS=6, PAYMENT_TRANSACTION=7, TICKET=8, REFUND_REQUEST=9 | P12 F1b DC-LockRank; P09 F7.3 |
| Chưa nêu | AcquireAll với hai keys bằng nhau | Q-144 |
| Không áp dụng | Không áp dụng: F2.19.3 (hạng là enumeration, khoá là cặp số; biên nằm trong bảng quyết định thứ tự), F2.19.5 (không là sự kiện ST) | - |

#### F2.19.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-61 | (rank, key) so với (maxRank, maxKey) | rank lớn hơn maxRank | Hợp lệ | SEAT_STATUS sau SHOWTIME | P08 F4b |
| EC-62 | (rank, key) so với (maxRank, maxKey) | cùng rank, key lớn hơn maxKey | Hợp lệ | (10,21) sau (10,20) | P09 F7.3 |
| EC-63 | (rank, key) so với (maxRank, maxKey) | rank nhỏ hơn maxRank | Không hợp lệ | SEAT_HOLD sau SEAT_STATUS | P08 F4b |
| EC-64 | (rank, key) so với (maxRank, maxKey) | cùng rank, key nhỏ hơn maxKey | Không hợp lệ | (10,19) sau (10,20) | P09 F7.3 |
| EC-65 | khoá lại cùng dòng | chế độ bằng hoặc yếu hơn đã giữ | Hợp lệ | X rồi X; X rồi S | P12 F2 |
| EC-66 | khoá lại cùng dòng | nâng S lên X | Không hợp lệ | S rồi X | P08 F4b quy tắc 2 |

#### F2.19.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-25 | EC-61 (rank so với maxRank) | rank lớn hơn maxRank nhưng key nhỏ hơn maxKey (TICKET (1,0) sau PAYMENT_TRANSACTION (100,0)) | EC-61 | Hợp lệ: khoá so rank trước, key chỉ so khi cùng rank |
| BV-26 | rank nhỏ nhất, lớn nhất | PRICE_LIST (1) là khoá đầu tiên; REFUND_REQUEST (9) sau TICKET (8) | EC-61 | Hợp lệ |

#### F2.19.4 Bảng quyết định (DT3)

```text
| Điều kiện / Hành động | DT3-R1 | DT3-R2 | DT3-R3 | DT3-R4 | DT3-R5 |
| C1: khoá lại một dòng đã giữ | Y | Y | N | N | N |
| C2: chế độ yêu cầu yếu hơn hoặc bằng chế độ đã giữ | Y | N | - | - | - |
| C3: rank < maxRank | - | - | Y | N | N |
| C4: rank = maxRank và key < maxKey | - | - | - | Y | N |
| A1: hợp lệ, không đổi maxRank, maxKey | X | - | - | - | - |
| A2: ghi nhận khoá, cập nhật maxRank, maxKey | - | - | - | - | X |
| A3: LockOrderViolationError, violated = true | - | X | X | X | - |
```

Căn cứ: Gộp - có căn cứ: P12 F3 mô tả thứ tự kiểm (khoá lại cùng dòng, rồi rank, rồi key) và F2 không mâu thuẫn; C3 ở rank lớn hơn bỏ qua key.

#### F2.19.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N85 | bắt đầu | bắt đầu |
| N86 | khoá lại dòng đã giữ? | quyết định |
| N87 | chế độ yêu cầu yếu hơn hoặc bằng? | quyết định |
| N88 | rank < maxRank? | quyết định |
| N89 | rank = maxRank? | quyết định |
| N90 | key < maxKey? | quyết định |
| N91 | trả nil (không đổi) | khối lệnh |
| N92 | violated = true; trả LockOrderViolationError | khối lệnh |
| N93 | ghi nhận khoá; cập nhật maxRank, maxKey; trả nil | khối lệnh |
| N94 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE98 | N85 | N86 |  |
| CE99 | N86 | N87 | Đúng |
| CE100 | N86 | N88 | Sai |
| CE101 | N87 | N91 | Đúng |
| CE102 | N87 | N92 | Sai |
| CE103 | N88 | N92 | Đúng |
| CE104 | N88 | N89 | Sai |
| CE105 | N89 | N90 | Đúng |
| CE106 | N89 | N93 | Sai |
| CE107 | N90 | N92 | Đúng |
| CE108 | N90 | N93 | Sai |
| CE109 | N91 | N94 |  |
| CE110 | N92 | N94 |  |
| CE111 | N93 | N94 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 14 - 10 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P40 | N85 - N86 - N87 - N91 - N94 | TC-134 |
| P41 | N85 - N86 - N87 - N92 - N94 | TC-136 |
| P42 | N85 - N86 - N88 - N92 - N94 | TC-131 |
| P43 | N85 - N86 - N88 - N89 - N90 - N92 - N94 | TC-130 |
| P44 | N85 - N86 - N88 - N89 - N90 - N93 - N94 | TC-129 |
| P45 | N85 - N86 - N88 - N89 - N93 - N94 | TC-127 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE98 | TC-127, TC-129, TC-130, TC-131, TC-134, TC-136 | Có |
| CE99 | TC-134, TC-136 | Có |
| CE100 | TC-127, TC-129, TC-130, TC-131 | Có |
| CE101 | TC-134 | Có |
| CE102 | TC-136 | Có |
| CE103 | TC-131 | Có |
| CE104 | TC-127, TC-129, TC-130 | Có |
| CE105 | TC-129, TC-130 | Có |
| CE106 | TC-127 | Có |
| CE107 | TC-130 | Có |
| CE108 | TC-129 | Có |
| CE109 | TC-134 | Có |
| CE110 | TC-130, TC-131, TC-136 | Có |
| CE111 | TC-127, TC-129 | Có |

Độ phủ đạt được: C0 = 8/8 lệnh và điểm quyết định (100%); C1 = 14/14 nhánh (100%).

#### F2.19.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng thuần, một giao dịch một goroutine | Không cần |

### F2.20 DC-Showtime.CheckCancellationDeadline

#### F2.20.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckCancellationDeadline(now time.Time) error | P12 F2 |
| BR | BR-18: huỷ khi thời điểm huỷ cách giờ bắt đầu ít nhất 2 tiếng; BR-32: thời điểm huỷ là lúc hệ thống kiểm tra (tx.Now) | P06 |
| Luồng P04 | UC-008 3a: chưa tới 2 tiếng, kể cả đã bắt đầu hoặc đã kết thúc: từ chối (CancelDeadlineError) | P04 UC-008 |
| Không áp dụng | Không áp dụng: F2.20.4 (một điều kiện), F2.20.5, F2.20.6 | - |

#### F2.20.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-67 | startTime - now | >= 2 giờ | Hợp lệ | 17:00:00 với start 20:00 | BR-18 |
| EC-68 | startTime - now | < 2 giờ nhưng now trước startTime | Không hợp lệ | 19:00:00 | BR-18; UC-008 3a |
| EC-69 | now so với startTime | now >= startTime (đã bắt đầu hoặc kết thúc) | Không hợp lệ | 21:00:00 | UC-008 3a |

#### F2.20.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-27 | min của EC-67 | now = start - 2h (18:00:00.000) | EC-67 | Không ngoại lệ |
| BV-28 | max của EC-68 | now = 18:00:00.001 (còn 1 giờ 59 phút 59,999 giây) | EC-68 | CancelDeadlineError |
| BV-29 | min của EC-67 | now = 17:59:59.999 (ngay trong biên) | EC-67 | Không ngoại lệ |
| BV-30 | EC-69 | now = start (20:00:00.000) | EC-69 | CancelDeadlineError |

#### F2.20.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần; Showtime start 2026-11-10 20:00:00.000 dựng sẵn | Không cần |

### F2.21 DC-Showtime.CheckSaleOpen

#### F2.21.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckSaleOpen(now time.Time) error | P12 F2 |
| BR | BR-01: trước thời điểm mở bán không bán; BR-45: từ giờ bắt đầu không bắt đầu đặt vé. ShowtimeNotOpenError cũng cho suất chiếu Đã xoá (F1b) | P06; P12 F1b DC-ShowtimeNotOpenError |
| Luồng P04 | UC-005 2a (chưa mở bán), 2c (đã tới giờ bắt đầu) | P04 UC-005 |
| Không áp dụng | Không áp dụng: F2.21.4 (ba điều kiện cùng dẫn tới một lỗi duy nhất, thứ tự không ảnh hưởng kết quả), F2.21.5, F2.21.6 | - |

#### F2.21.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-70 | now, saleOpenTime, startTime | now < saleOpenTime | Không hợp lệ | 2026-11-09 07:00 | BR-01 |
| EC-71 | now, saleOpenTime, startTime | saleOpenTime <= now < startTime | Hợp lệ | 2026-11-10 10:00 | BR-01, BR-45 |
| EC-72 | now, startTime | now >= startTime | Không hợp lệ | 2026-11-10 21:00 | BR-45 |
| EC-73 | status | Đã xoá | Không hợp lệ | DELETED | P12 F1b |

#### F2.21.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-31 | min của EC-71 | now = sale_open - 1ms (2026-11-09 07:59:59.999) | EC-70 | ShowtimeNotOpenError |
| BV-32 | min của EC-71 | now = sale_open (08:00:00.000) | EC-71 | Không ngoại lệ |
| BV-33 | max của EC-71 | now = start - 1ms (2026-11-10 19:59:59.999) | EC-71 | Không ngoại lệ |
| BV-34 | max của EC-71 | now = start (20:00:00.000) | EC-72 | ShowtimeNotOpenError |

#### F2.21.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần; Showtime sale_open 2026-11-09 08:00, start 2026-11-10 20:00, IN_SCHEDULE | Không cần |

### F2.22 DC-Showtime.CheckSeatSelection

#### F2.22.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckSeatSelection(selected []*Seat) error | P12 F2 |
| Mô tả | Kiểm 1 đến 8 ghế, không trùng, đều thuộc phòng chiếu của suất chiếu; SeatSelectionError mang reason EMPTY, TOO_MANY, NOT_IN_AUDITORIUM, DUPLICATE | P12 F2, F1b |
| BR | BR-05: tối đa 8 ghế; BR-06: ghế đôi tính là một ghế | P06 |
| Luồng P04 | UC-005 6a (vượt 8 ghế) | P04 UC-005 |
| Chưa nêu | Hai lý do cùng sai (ví dụ 9 ghế có ghế trùng) báo lý do nào | Q-152 |
| Không áp dụng | Không áp dụng: F2.22.5, F2.22.6 (Đo khi có mã nguồn; không có F3 riêng) | - |

#### F2.22.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-74 | số ghế | 0 ghế | Không hợp lệ | [] | BR-05 (EMPTY) |
| EC-75 | số ghế | 1 đến 8 ghế, không trùng, thuộc phòng | Hợp lệ | 3 ghế | BR-05 |
| EC-76 | số ghế | từ 9 ghế trở lên | Không hợp lệ | 9 ghế | BR-05 (TOO_MANY) |
| EC-77 | trùng | có hai phần tử cùng mã ghế | Không hợp lệ | [101, 101] | F1b (DUPLICATE) |
| EC-78 | phòng | có ghế thuộc phòng chiếu khác | Không hợp lệ | ghế 900 của phòng 8 | F1b (NOT_IN_AUDITORIUM) |
| EC-79 | loại ghế | ghế đôi (COUPLE) | Hợp lệ | 8 ghế COUPLE | BR-06 (ghế đôi tính một ghế) |

#### F2.22.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-35 | kích thước của EC-75 | 0 ghế | EC-74 | SeatSelectionError(EMPTY) |
| BV-36 | kích thước của EC-75 | 1 ghế | EC-75 | Không ngoại lệ |
| BV-37 | kích thước của EC-75 | 8 ghế | EC-75 | Không ngoại lệ |
| BV-38 | kích thước của EC-75 | 9 ghế | EC-76 | SeatSelectionError(TOO_MANY) |

Vòng lặp:

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử (0, 1, m, n-1, n, n+1) | TC |
|---|---|---|---|---|
| duyệt selected để kiểm trùng và phòng | 8 | 3 | 0, 1, 3, 7, 8, 9 | TC-152, TC-153, TC-154, TC-155 |

Ghi chú vòng lặp: duyệt selected để kiểm trùng và phòng. n = 8, m = 3; số lần 0, 1, m, n - 1 (7), n, n + 1 (9). Các giá trị 0, 1, 8, 9 có TC; m = 3 phủ bởi TC ghế hợp lệ; n - 1 = 7 thuộc cùng lớp hợp lệ nên không thêm TC.

#### F2.22.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-Seat | stub | Seat thật dựng với ID và auditoriumId (7 hoặc 8) | Đối tượng đơn giản |

### F2.23 DC-Showtime.CheckUnchangedSince

#### F2.23.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckUnchangedSince(displayedAt time.Time) error | P12 F2 |
| Mô tả | So lastChangedAt với mốc lúc hiển thị sơ đồ ghế và kiểm chưa Đã xoá; ShowtimeChangedError. displayedAt là giá trị LastChangedAt đã đưa ra màn hình (F2 DC-Showtime.LastChangedAt) | P12 F2 |
| BR / luồng | BR-54; UC-005 7d | P06; P04 UC-005 |
| Không áp dụng | Không áp dụng: F2.23.3 (chỉ một điểm so sánh, phủ bằng ba TC), F2.23.4, F2.23.5, F2.23.6 | - |

#### F2.23.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-80 | lastChangedAt so với displayedAt | lastChangedAt = displayedAt | Hợp lệ | 2026-11-08 09:00:00.000 | BR-54 |
| EC-81 | lastChangedAt so với displayedAt | lastChangedAt > displayedAt | Không hợp lệ | 09:00:00.001 | BR-54 |
| EC-82 | status | Đã xoá | Không hợp lệ | DELETED | BR-54; F2 |
| EC-83 | lastChangedAt so với displayedAt | lastChangedAt < displayedAt (không xảy ra vì mốc lấy từ chính LastChangedAt) | Không hợp lệ | 08:59:59.999 | P12 F2 không nêu --> Q-144 |

#### F2.23.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-39 | EC-80 | lastChangedAt vượt displayedAt 1ms | EC-81 | ShowtimeChangedError |

#### F2.23.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | Đối tượng miền thuần | Không cần |

### F2.24 DC-PriceList.DetermineSeatPrice

#### F2.24.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | DetermineSeatPrice(q PriceQuery) (Money, error); PriceQuery gồm auditoriumType, movieFormat, startTime, seatType | P12 F2, F1b |
| BR | BR-11: giá theo loại phòng, định dạng, loại ghế, khung giờ (trước 17 giờ hoặc từ 17 giờ trở đi; ngày thường hoặc cuối tuần); BR-12: khung giờ theo giờ bắt đầu, cuối tuần là Thứ Bảy và Chủ nhật; BR-72: không có giá thì không giữ ghế | P06 |
| Luồng P04 | UC-005 7e | P04 UC-005 |
| Chưa nêu | Múi giờ dùng để xác định 17 giờ và thứ trong tuần khi startTime mang múi giờ khác | Q-151 |
| Không áp dụng | Không áp dụng: F2.24.4 (khung giờ là hàm của hai điều kiện độc lập, phân vùng theo đầu ra đủ), F2.24.5, F2.24.6 (không có F3 riêng) | - |

#### F2.24.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-84 | khung giờ | ngày thường (Thứ Hai đến Thứ Sáu), trước 17:00 | Hợp lệ | Thứ Tư 2026-11-11 10:00 | BR-11, BR-12 |
| EC-85 | khung giờ | ngày thường, từ 17:00 | Hợp lệ | Thứ Tư 20:00 | BR-12 |
| EC-86 | khung giờ | cuối tuần (Thứ Bảy, Chủ nhật), trước 17:00 | Hợp lệ | Thứ Bảy 2026-11-14 10:00 | BR-12 |
| EC-87 | khung giờ | cuối tuần, từ 17:00 | Hợp lệ | Chủ nhật 2026-11-15 20:00 | BR-12 |
| EC-88 | tổ hợp (loại phòng, định dạng, loại ghế) | không có mục giá | Không hợp lệ | IMAX, 3D, VIP | BR-72 |
| EC-89 | startTime | mang múi giờ khác UTC+7 | Hợp lệ hoặc không | 2026-11-13 10:00:00Z | Q-151 |

#### F2.24.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-40 | 17:00 ngày thường | Thứ Tư 16:59:59.999 (UTC+7) | EC-84 | 70.000 |
| BV-41 | 17:00 ngày thường | Thứ Tư 17:00:00.000 | EC-85 | 90.000 |
| BV-42 | ngày thường --> cuối tuần | Thứ Sáu 23:59:59.999 (vẫn ngày thường, từ 17:00) | EC-85 | 90.000 |
| BV-43 | ngày thường --> cuối tuần | Thứ Bảy 00:00:00.000 | EC-86 | 85.000 |
| BV-44 | 17:00 cuối tuần | Thứ Bảy 16:59:59.999 | EC-86 | 85.000 |
| BV-45 | 17:00 cuối tuần | Thứ Bảy 17:00:00.000 | EC-87 | 110.000 |
| BV-46 | cuối tuần --> ngày thường | Chủ nhật 23:59:59.999 | EC-87 | 110.000 |
| BV-47 | cuối tuần --> ngày thường | Thứ Hai 00:00:00.000 (2026-11-16) | EC-84 | 70.000 |

#### F2.24.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có phụ thuộc | - | PriceList dựng với mục giá cho (STANDARD, 2D, STANDARD): WEEKDAY_BEFORE_17 = 70.000, WEEKDAY_FROM_17 = 90.000, WEEKEND_BEFORE_17 = 85.000, WEEKEND_FROM_17 = 110.000; không có mục (IMAX, 3D, VIP) | Đối tượng miền thuần |

### F2.25 DC-BookTicketsService.HoldSeats

#### F2.25.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | HoldSeats(ctx Ctx, req HoldSeatsRequest) (HoldResult, error) | P12 F2 |
| Hậu điều kiện | SeatHold ACTIVE, các ghế HELD, một dòng seat_event, không NOTIFY; req.requestId trùng lần giữ ghế đã có thì trả lại lần đó (replayed) | P12 F2 |
| Ngoại lệ | ShowtimeNotOpenError, ShowtimeChangedError, SeatSelectionError, HolderBusyError, SeatUnavailableError, SystemBusyError, NotFoundError. Thiếu ở F2 nhưng có ở F3 (d): HoldNotActiveError --> Đề xuất sửa P12 dòng 12 | P12 F2, F3 |
| Thao tác nguyên tử | UC-005 mục 8: bước 7 kiểm tra và giữ là một thao tác không chia cắt; EX-01; loại trừ X-01 (cùng suất chiếu), X-02 (cùng người giữ), X-03, X-04, X-13 | P08 F4a, F4b; P04 UC-005 |
| Thứ tự kiểm (nguồn P04) | UC-005: 7c (BR-04) trước 7d trước 7a trước 7e (mục 8); các luồng 2a, 2c (bước 2), 6a (bước 6) thuộc bước khác với bước 7 | P04 UC-005 mục 3, 8 |
| Luồng P04 | UC-005 2a, 2c, 5b, 6a, 7a, 7c, 7d, 7e | P04 UC-005 |
| Hạn tổng | TxOptions.WithDeadline = lúc nhận yêu cầu + 1,8 giây (NFR-06, tối đa 2 giây kể cả từ chối) | P12 F3; P09 F7.3 |
| Không áp dụng | Không áp dụng: F2.25.5 (không là sự kiện ST; chuyển trạng thái của SeatHold, SeatStatus kiểm ở các operation entity) | - |

#### F2.25.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-90 | seatIds | 1 đến 8 ghế hợp lệ | Hợp lệ | [101,102,103] | BR-05 |
| EC-91 | seatIds | rỗng | Không hợp lệ | [] | BR-05 (EMPTY) |
| EC-92 | seatIds | từ 9 ghế | Không hợp lệ | 9 ghế | BR-05; UC-005 6a |
| EC-93 | seatIds | ghế trùng hoặc thuộc phòng khác | Không hợp lệ | ghế 900 của phòng 8 | F1b DC-SeatSelectionError |
| EC-94 | suất chiếu theo tx.Now | đang trong khoảng mở bán | Hợp lệ | 10:00 ngày 2026-11-10 | BR-01, BR-45 |
| EC-95 | suất chiếu theo tx.Now | chưa mở bán, đã bắt đầu hoặc đã xoá | Không hợp lệ | 2026-11-09 07:59:59.999 | UC-005 2a, 2c |
| EC-96 | suất chiếu so với displayedAt | chưa đổi | Hợp lệ | lastChangedAt = displayedAt | BR-54 |
| EC-97 | suất chiếu so với displayedAt | đã đổi hoặc phòng chiếu đổi sau FindRouting | Không hợp lệ | lastChangedAt > displayedAt | BR-54; UC-005 7d |
| EC-98 | lần giữ ghế chưa kết thúc của người giữ | không có (hoặc đã quá hạn) | Hợp lệ | [] | BR-04 |
| EC-99 | lần giữ ghế chưa kết thúc của người giữ | có ACTIVE chưa quá hạn, requestId khác | Không hợp lệ | ACTIVE, expiry 10:10 | BR-04; UC-005 7c |
| EC-100 | requestId | trùng lần giữ ghế ACTIVE chưa quá hạn của chính người giữ | Hợp lệ (trả lại) | r-1 | P09 F7.3 EX-01 |
| EC-101 | requestId | trùng lần giữ ghế đã ở trạng thái cuối hoặc đã quá hạn | Không hợp lệ | hold CANCELLED | P12 F3 (d) |
| EC-102 | trạng thái các ghế sau khi khoá | mọi ghế AVAILABLE (hoặc vừa được trả từ lần giữ ghế cũ của chính người giữ) | Hợp lệ | 101,102,103 AVAILABLE | BR-07 |
| EC-103 | trạng thái các ghế sau khi khoá | có ghế HELD hoặc SOLD | Không hợp lệ | ghế 102 HELD bởi hold khác | BR-07, BR-08, BR-09; UC-005 7a |
| EC-104 | khoá ghế NOWAIT | ghế đang bị giao dịch khác khoá (55P03) | Không hợp lệ | LOCKED_BY_OTHER | P09 F7.3 EX-01; BR-09 |
| EC-105 | số dòng khoá được | khác số ghế yêu cầu | Không hợp lệ | 2 dòng cho 3 ghế | P12 F3 (g) |
| EC-106 | bảng giá | có giá cho mọi ghế | Hợp lệ | đủ mục giá | BR-11 |
| EC-107 | bảng giá | thiếu giá cho một ghế | Không hợp lệ | ghế VIP không có mục giá | BR-72; UC-005 7e |
| EC-108 | giao dịch | hoàn tất trong hạn 1,8 giây | Hợp lệ | Do trả nil | NFR-06 |
| EC-109 | giao dịch | hết hạn tổng hoặc hết lần thử (SystemBusyError) | Không hợp lệ | Do trả SystemBusyError | P09 F7.3 |
| EC-110 | phòng chiếu sau khoá | khác phòng ở FindRouting | Không hợp lệ | phòng 8 thay vì 7 | P12 F3 (c) |
| EC-111 | showtimeId | không tồn tại | Không hợp lệ | 9999 | P12 F2 NotFoundError |

#### F2.25.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-48 | kích thước seatIds (EC-90) | 0 ghế | EC-91 | SeatSelectionError(EMPTY); Do 0 lần |
| BV-49 | kích thước seatIds (EC-90) | 1 ghế | EC-90 | Giữ được 1 ghế |
| BV-50 | kích thước seatIds (EC-90) | 7 ghế | EC-90 | Giữ được 7 ghế |
| BV-51 | kích thước seatIds (EC-90) | 8 ghế | EC-90 | Giữ được 8 ghế |
| BV-52 | kích thước seatIds (EC-90) | 9 ghế | EC-92 | SeatSelectionError(TOO_MANY); Do 0 lần |
| BV-53 | hết hạn của replay (EC-100) | now = E - 1ms | EC-100 | Trả lại lần giữ ghế cũ |
| BV-54 | hết hạn của lần giữ ghế cũ (EC-98) | now = E (lần giữ ghế cũ vừa quá hạn) | EC-98 | Lần giữ ghế cũ EXPIRED, giữ ghế mới thành công |
| BV-55 | hết hạn của lần giữ ghế cũ (EC-99) | now = E - 1ms | EC-99 | HolderBusyError |

#### F2.25.4 Bảng quyết định (DT4)

```text
| Điều kiện / Hành động | DT4-R1 | DT4-R2 | DT4-R3 | DT4-R4 | DT4-R5 | DT4-R6 | DT4-R7 | DT4-R8 | DT4-R9 | DT4-R10 |
| C1: suất chiếu chưa mở bán hoặc đã bắt đầu (UC-005 2a, 2c) | N | Y | N | N | N | N | N | Y | - | Y |
| C2: số ghế rỗng hoặc quá 8 (6a, kiểm nhanh) | N | N | Y | N | N | N | N | - | Y | Y |
| C3: người giữ còn lần giữ ghế chưa kết thúc (7c) | N | N | N | Y | N | N | N | Y | Y | - |
| C4: suất chiếu đã đổi (7d) | N | N | N | - | Y | N | N | - | - | - |
| C5: có ghế không trống (7a) | N | N | N | - | - | Y | N | - | - | - |
| C6: thiếu giá của một ghế (7e) | N | N | N | - | - | - | Y | - | - | - |
| A0: giữ thành công | X | - | - | - | - | - | - | - | - | - |
| A1: ShowtimeNotOpenError | - | X | - | - | - | - | - | - | - | - |
| A2: SeatSelectionError | - | - | X | - | - | - | - | - | - | - |
| A3: HolderBusyError | - | - | - | X | - | - | - | - | - | - |
| A4: ShowtimeChangedError | - | - | - | - | X | - | - | - | - | - |
| A5: SeatUnavailableError | - | - | - | - | - | X | - | - | - | - |
| A6: NotFoundError (không có giá) | - | - | - | - | - | - | X | - | - | - |
| A7: chưa xác định (chờ Q-145) | - | - | - | - | - | - | - | X | X | X |
```

Căn cứ: P04 UC-005 mục 3 và 8 nêu 7c kiểm trước 7d, 7d trước 7a, 7e kiểm sau 7a, nên R4 đến R6 gộp C4 đến C6 bằng -. P04 không nêu thứ tự giữa C1 hoặc C2 với C3 đến C6 (bước 2 và bước 6 là bước khác với bước 7; BR-45 chỉ kiểm ở bước 2); quy tắc vi phạm đồng thời C1 hoặc C2 với điều kiện khác (R8, R9, R10) chờ cùng một Q-145, chọn mỗi nhóm một đại diện. Các quy tắc R2 đến R7 là vi phạm đơn; R4 đến R6 gồm cả TC vi phạm đồng thời có thứ tự theo P04.

#### F2.25.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N95 | bắt đầu | bắt đầu |
| N96 | seatIds rỗng hoặc nhiều hơn maxSeats? | quyết định |
| N97 | FindRouting(showtimeId) | khối lệnh |
| N98 | FindRouting ném NotFoundError? | quyết định |
| N99 | Do(UserTx, deadline 1,8 giây): khoá hạng 1 đến 5; now = tx.Now | khối lệnh |
| N100 | một lời gọi khoá ném NotFoundError hoặc SystemBusyError? | quyết định |
| N101 | phòng chiếu đã khoá khác phòng ở FindRouting? | quyết định |
| N102 | có lần giữ ghế cùng requestId của người giữ? | quyết định |
| N103 | lần giữ ghế đó ACTIVE và chưa quá hạn? | quyết định |
| N104 | trả lại lần giữ ghế đó (replayed) | khối lệnh |
| N105 | có lần giữ ghế ACTIVE cũ đã quá hạn? | quyết định |
| N106 | Expire(now); UpdateStatus; nhớ mã lần giữ ghế cũ | khối lệnh |
| N107 | CheckNoActiveSeatHold ném HolderBusyError? | quyết định |
| N108 | CheckSaleOpen ném ShowtimeNotOpenError? | quyết định |
| N109 | CheckUnchangedSince ném ShowtimeChangedError? | quyết định |
| N110 | FindSeats | khối lệnh |
| N111 | CheckSeatSelection ném SeatSelectionError? | quyết định |
| N112 | LockForHold ném SeatUnavailableError (55P03 NOWAIT)? | quyết định |
| N113 | rollback; IF-18.FindBeingReleased | khối lệnh |
| N114 | FindBeingReleased = true? | quyết định |
| N115 | số dòng khoá được khác số ghế yêu cầu? | quyết định |
| N116 | có ghế đang HELD bởi lần giữ ghế cũ vừa Expire? | quyết định |
| N117 | ReleaseHold(mã cũ) cho ghế đó | khối lệnh |
| N118 | có ghế không IsAvailable? | quyết định |
| N119 | QuoteSeatPrices ném NotFoundError? | quyết định |
| N120 | NewSeatHold; Insert | khối lệnh |
| N121 | còn ghế chưa HoldFor? | quyết định |
| N122 | HoldFor từng ghế | khối lệnh |
| N123 | SaveChanges (seat_event cùng giao dịch) | khối lệnh |
| N124 | Do trả SystemBusyError (hết hạn tổng hoặc hết lần thử)? | quyết định |
| N125 | commit; dựng HoldResult, tổng = CalculateTotal | khối lệnh |
| N126 | ném SeatSelectionError (kiểm nhanh) | khối lệnh |
| N127 | trả NotFoundError | khối lệnh |
| N128 | fn trả lỗi, rollback | khối lệnh |
| N129 | ném ShowtimeChangedError (phòng đổi) | khối lệnh |
| N130 | ném HoldNotActiveError mang status | khối lệnh |
| N131 | ném HolderBusyError | khối lệnh |
| N132 | ném ShowtimeNotOpenError | khối lệnh |
| N133 | ném ShowtimeChangedError | khối lệnh |
| N134 | ném SeatSelectionError | khối lệnh |
| N135 | ném SeatUnavailableError(BEING_RELEASED) | khối lệnh |
| N136 | ném SeatUnavailableError(LOCKED_BY_OTHER) | khối lệnh |
| N137 | ném SeatUnavailableError (số dòng) | khối lệnh |
| N138 | ném SeatUnavailableError(NOT_AVAILABLE) | khối lệnh |
| N139 | ném NotFoundError (không có giá) | khối lệnh |
| N140 | trả SystemBusyError | khối lệnh |
| N141 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE112 | N95 | N96 |  |
| CE113 | N96 | N126 | Đúng |
| CE114 | N96 | N97 | Sai |
| CE115 | N97 | N98 |  |
| CE116 | N98 | N127 | Đúng |
| CE117 | N98 | N99 | Sai |
| CE118 | N99 | N100 |  |
| CE119 | N100 | N128 | Đúng |
| CE120 | N100 | N101 | Sai |
| CE121 | N101 | N129 | Đúng |
| CE122 | N101 | N102 | Sai |
| CE123 | N102 | N103 | Đúng |
| CE124 | N102 | N105 | Sai |
| CE125 | N103 | N104 | Đúng |
| CE126 | N103 | N130 | Sai |
| CE127 | N105 | N106 | Đúng |
| CE128 | N105 | N107 | Sai |
| CE129 | N106 | N108 |  |
| CE130 | N107 | N131 | Đúng |
| CE131 | N107 | N108 | Sai |
| CE132 | N108 | N132 | Đúng |
| CE133 | N108 | N109 | Sai |
| CE134 | N109 | N133 | Đúng |
| CE135 | N109 | N110 | Sai |
| CE136 | N110 | N111 |  |
| CE137 | N111 | N134 | Đúng |
| CE138 | N111 | N112 | Sai |
| CE139 | N112 | N113 | Đúng |
| CE140 | N113 | N114 |  |
| CE141 | N114 | N135 | Đúng |
| CE142 | N114 | N136 | Sai |
| CE143 | N112 | N115 | Sai |
| CE144 | N115 | N137 | Đúng |
| CE145 | N115 | N116 | Sai |
| CE146 | N116 | N117 | Đúng |
| CE147 | N116 | N118 | Sai |
| CE148 | N117 | N118 |  |
| CE149 | N118 | N138 | Đúng |
| CE150 | N118 | N119 | Sai |
| CE151 | N119 | N139 | Đúng |
| CE152 | N119 | N120 | Sai |
| CE153 | N120 | N121 |  |
| CE154 | N121 | N122 | Đúng |
| CE155 | N122 | N121 |  |
| CE156 | N121 | N123 | Sai |
| CE157 | N123 | N124 |  |
| CE158 | N124 | N140 | Đúng |
| CE159 | N124 | N125 | Sai |
| CE160 | N125 | N141 |  |
| CE161 | N104 | N141 |  |
| CE162 | N126 | N141 |  |
| CE163 | N127 | N141 |  |
| CE164 | N128 | N141 |  |
| CE165 | N129 | N141 |  |
| CE166 | N130 | N141 |  |
| CE167 | N131 | N141 |  |
| CE168 | N132 | N141 |  |
| CE169 | N133 | N141 |  |
| CE170 | N134 | N141 |  |
| CE171 | N135 | N141 |  |
| CE172 | N136 | N141 |  |
| CE173 | N137 | N141 |  |
| CE174 | N138 | N141 |  |
| CE175 | N139 | N141 |  |
| CE176 | N140 | N141 |  |

V(G) = số điểm quyết định nhị phân + 1 = 19 + 1 = 20; kiểm bằng E - N + 2 = 65 - 47 + 2 = 20. V(G) lớn hơn 10: đề xuất tách phương thức (xem Đề xuất sửa artifact trước). Các lời gọi khoá hạng 1 đến 5 gộp thành một node quyết định d3 vì cùng hai ngoại lệ NotFoundError và SystemBusyError và cùng cách xử lý (fn trả lỗi, rollback). Tách riêng sẽ thêm 4 điểm quyết định; V(G) thật lớn hơn con số dưới đây.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P46 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N119 - N120 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N123 - N124 - N125 - N141 | TC-174 |
| P47 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N119 - N120 - N121 - N122 - N121 - N123 - N124 - N125 - N141 | TC-175 |
| P48 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N119 - N120 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N123 - N124 - N125 - N141 | TC-177 |
| P49 | N95 - N96 - N126 - N141 | TC-178 |
| P50 | N95 - N96 - N97 - N98 - N127 - N141 | TC-180 |
| P51 | N95 - N96 - N97 - N98 - N99 - N100 - N128 - N141 | TC-181 |
| P52 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N129 - N141 | TC-182 |
| P53 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N103 - N104 - N141 | TC-183 |
| P54 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N103 - N130 - N141 | TC-184 |
| P55 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N106 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N119 - N120 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N123 - N124 - N125 - N141 | TC-187 |
| P56 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N106 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N117 - N118 - N119 - N120 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N123 - N124 - N125 - N141 | TC-188 |
| P57 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N131 - N141 | TC-186 |
| P58 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N132 - N141 | TC-189 |
| P59 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N133 - N141 | TC-191 |
| P60 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N134 - N141 | TC-192 |
| P61 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N113 - N114 - N136 - N141 | TC-193 |
| P62 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N113 - N114 - N135 - N141 | TC-194 |
| P63 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N137 - N141 | TC-195 |
| P64 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N138 - N141 | TC-196 |
| P65 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N119 - N139 - N141 | TC-198 |
| P66 | N95 - N96 - N97 - N98 - N99 - N100 - N101 - N102 - N105 - N107 - N108 - N109 - N110 - N111 - N112 - N115 - N116 - N118 - N119 - N120 - N121 - N122 - N121 - N122 - N121 - N122 - N121 - N123 - N124 - N140 - N141 | TC-199 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE112 | TC-174, TC-175, TC-177, TC-178, TC-180, TC-181, TC-182, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE113 | TC-178 | Có |
| CE114 | TC-174, TC-175, TC-177, TC-180, TC-181, TC-182, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE115 | TC-174, TC-175, TC-177, TC-180, TC-181, TC-182, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE116 | TC-180 | Có |
| CE117 | TC-174, TC-175, TC-177, TC-181, TC-182, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE118 | TC-174, TC-175, TC-177, TC-181, TC-182, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE119 | TC-181 | Có |
| CE120 | TC-174, TC-175, TC-177, TC-182, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE121 | TC-182 | Có |
| CE122 | TC-174, TC-175, TC-177, TC-183, TC-184, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE123 | TC-183, TC-184 | Có |
| CE124 | TC-174, TC-175, TC-177, TC-186, TC-187, TC-188, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE125 | TC-183 | Có |
| CE126 | TC-184 | Có |
| CE127 | TC-187, TC-188 | Có |
| CE128 | TC-174, TC-175, TC-177, TC-186, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE129 | TC-187, TC-188 | Có |
| CE130 | TC-186 | Có |
| CE131 | TC-174, TC-175, TC-177, TC-189, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE132 | TC-189 | Có |
| CE133 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-191, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE134 | TC-191 | Có |
| CE135 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE136 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-192, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE137 | TC-192 | Có |
| CE138 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-193, TC-194, TC-195, TC-196, TC-198, TC-199 | Có |
| CE139 | TC-193, TC-194 | Có |
| CE140 | TC-193, TC-194 | Có |
| CE141 | TC-194 | Có |
| CE142 | TC-193 | Có |
| CE143 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-195, TC-196, TC-198, TC-199 | Có |
| CE144 | TC-195 | Có |
| CE145 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-196, TC-198, TC-199 | Có |
| CE146 | TC-188 | Có |
| CE147 | TC-174, TC-175, TC-177, TC-187, TC-196, TC-198, TC-199 | Có |
| CE148 | TC-188 | Có |
| CE149 | TC-196 | Có |
| CE150 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-198, TC-199 | Có |
| CE151 | TC-198 | Có |
| CE152 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-199 | Có |
| CE153 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-199 | Có |
| CE154 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-199 | Có |
| CE155 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-199 | Có |
| CE156 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-199 | Có |
| CE157 | TC-174, TC-175, TC-177, TC-187, TC-188, TC-199 | Có |
| CE158 | TC-199 | Có |
| CE159 | TC-174, TC-175, TC-177, TC-187, TC-188 | Có |
| CE160 | TC-174, TC-175, TC-177, TC-187, TC-188 | Có |
| CE161 | TC-183 | Có |
| CE162 | TC-178 | Có |
| CE163 | TC-180 | Có |
| CE164 | TC-181 | Có |
| CE165 | TC-182 | Có |
| CE166 | TC-184 | Có |
| CE167 | TC-186 | Có |
| CE168 | TC-189 | Có |
| CE169 | TC-191 | Có |
| CE170 | TC-192 | Có |
| CE171 | TC-194 | Có |
| CE172 | TC-193 | Có |
| CE173 | TC-195 | Có |
| CE174 | TC-196 | Có |
| CE175 | TC-198 | Có |
| CE176 | TC-199 | Có |

Độ phủ đạt được: C0 = 45/45 lệnh và điểm quyết định (100%); C1 = 65/65 nhánh (100%).

Vòng lặp:

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử (0, 1, m, n-1, n, n+1) | TC |
|---|---|---|---|---|
| HoldFor từng ghế (SaveChanges một lần) | 8 (BR-05) | 3 | 0 (SeatSelectionError), 1, 3, 7, 8, 9 (SeatSelectionError) | TC-178, TC-175, TC-176, TC-177, TC-179, TC-174 |

V(G) lớn hơn 10: đề xuất tách HoldSeats (kiểm tra đầu vào và định tuyến, giai đoạn khoá, giai đoạn kiểm điều kiện, giai đoạn giữ và ghi) hoặc đưa pha ghi vào lớp miền không trạng thái như X1 RV-01; ghi ở Đề xuất sửa artifact trước.

#### F2.25.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-11, IF-12, IF-13 | fake | FindRouting trả (phòng 7, cụm rạp 2); LockShared trả Showtime 55; LockSharedByCinema trả PriceList; LockAuditoriumShared; FindSeats trả ghế theo mã | Store (PostgreSQL) thay bằng bộ nhớ |
| IF-16, IF-17 | fake | LockHolder; LockUnfinishedOrByRequest trả các lần giữ ghế theo điều kiện đầu; Insert gán id; UpdateStatus ghi lại | Store thay bằng bộ nhớ |
| IF-18 | fake | LockForHold trả ghế theo (suất, ghế) hoặc SeatUnavailableError(LOCKED_BY_OTHER); FindBeingReleased cấu hình true hoặc false; SaveChanges ghi lại số lần và danh sách ghế | Store thay bằng bộ nhớ; 55P03 là lỗi do store dịch |
| IF-24 | stub | NewHoldRef trả ref-1 | Giá trị ngẫu nhiên phải tiêm vào |

### F2.26 DC-PaymentReportService.decide

#### F2.26.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | decide(r PaymentReport, hold *SeatHold, txn *PaymentTransaction, now time.Time) settlement (private, hàm thuần) | P12 F2 |
| Mô tả | Bốn nhánh loại trừ theo thứ tự: (1) thành công và txn.IsProcessed: DUPLICATE; (2) thành công, txn PENDING, hold.IsActiveAt(now): SELL; (3) thành công còn lại (lần giữ ghế Hết hạn, Đã huỷ, Thanh toán thất bại, Đã hoàn tất bởi giao dịch khác, hoặc txn đã FAILED): LATE; (4) thất bại: FAILURE | P12 F2, F3; P09 F7.6 |
| BR | BR-14, BR-15 (thanh toán trễ, đã huỷ, sau thất bại), BR-37 (báo trùng), BR-39 (thất bại chỉ ghi nhận), BR-40, BR-86 | P06 |
| Luồng P04 | UC-005 11, 11a; UC-006 2a, 2c, 2d | P04 UC-005, UC-006 |
| Chọn private | Operation private có logic BR: kiểm qua test trực tiếp (cùng package) vì hàm thuần không phụ thuộc; ghi lý do theo Bước 5, không đề xuất đổi visibility | Prompt Bước 5 |
| Không áp dụng | Không áp dụng: F2.26.2, F2.26.3 (điều kiện nhị phân, kết quả theo bảng quyết định), F2.26.5 (không là sự kiện ST) | - |

#### F2.26.4 Bảng quyết định (DT5)

```text
| Điều kiện / Hành động | DT5-R1 | DT5-R2 | DT5-R3 | DT5-R4 | DT5-R5 | DT5-R6 | DT5-R7 |
| C1: báo thành công | Y | Y | Y | Y | Y | N | N/A |
| C2: txn.IsProcessed (TICKETED hoặc LATE_PAYMENT) | Y | N | N | N | N | - | N/A |
| C3: txn.Status = PENDING | N | Y | Y | N | N | - | N/A |
| C4: hold.IsActiveAt(now) | - | Y | N | Y | N | - | N/A |
| A1: DUPLICATE | X | - | - | - | - | - | N/A |
| A2: SELL | - | X | - | - | - | - | N/A |
| A3: LATE | - | - | X | X | X | - | N/A |
| A4: FAILURE | - | - | - | - | - | X | N/A |
```

Căn cứ: Gộp - có căn cứ: P09 F7.6 bảng quyết định ghi 'báo thành công, giao dịch đã xử lý' cho DUPLICATE bất kể trạng thái lần giữ ghế, và 'báo thất bại' cho FAILURE bất kể các điều kiện còn lại; P12 F3 trùng thứ tự (1) đến (4).

DT5-R7: N/A, C2 và C3 không cùng đúng (đã xử lý và PENDING loại trừ nhau).

#### F2.26.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N142 | bắt đầu | bắt đầu |
| N143 | báo thất bại? | quyết định |
| N144 | txn.IsProcessed? | quyết định |
| N145 | txn.Status = PENDING? | quyết định |
| N146 | hold.IsActiveAt(now)? | quyết định |
| N147 | trả FAILURE | khối lệnh |
| N148 | trả DUPLICATE | khối lệnh |
| N149 | trả SELL | khối lệnh |
| N150 | trả LATE | khối lệnh |
| N151 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE177 | N142 | N143 |  |
| CE178 | N143 | N147 | Đúng |
| CE179 | N143 | N144 | Sai |
| CE180 | N144 | N148 | Đúng |
| CE181 | N144 | N145 | Sai |
| CE182 | N145 | N146 | Đúng |
| CE183 | N145 | N150 | Sai |
| CE184 | N146 | N149 | Đúng |
| CE185 | N146 | N150 | Sai |
| CE186 | N147 | N151 |  |
| CE187 | N148 | N151 |  |
| CE188 | N149 | N151 |  |
| CE189 | N150 | N151 |  |

V(G) = số điểm quyết định nhị phân + 1 = 4 + 1 = 5; kiểm bằng E - N + 2 = 13 - 10 + 2 = 5.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P67 | N142 - N143 - N147 - N151 | TC-214 |
| P68 | N142 - N143 - N144 - N148 - N151 | TC-207 |
| P69 | N142 - N143 - N144 - N145 - N146 - N149 - N151 | TC-209 |
| P70 | N142 - N143 - N144 - N145 - N146 - N150 - N151 | TC-210 |
| P71 | N142 - N143 - N144 - N145 - N150 - N151 | TC-212 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE177 | TC-207, TC-209, TC-210, TC-212, TC-214 | Có |
| CE178 | TC-214 | Có |
| CE179 | TC-207, TC-209, TC-210, TC-212 | Có |
| CE180 | TC-207 | Có |
| CE181 | TC-209, TC-210, TC-212 | Có |
| CE182 | TC-209, TC-210 | Có |
| CE183 | TC-212 | Có |
| CE184 | TC-209 | Có |
| CE185 | TC-210 | Có |
| CE186 | TC-214 | Có |
| CE187 | TC-207 | Có |
| CE188 | TC-209 | Có |
| CE189 | TC-210, TC-212 | Có |

Độ phủ đạt được: C0 = 8/8 lệnh và điểm quyết định (100%); C1 = 13/13 nhánh (100%).

#### F2.26.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-SeatHold, DC-PaymentTransaction | stub | Đối tượng thật dựng đến trạng thái yêu cầu qua operation công khai | Đối tượng miền thuần |

### F2.27 DC-BookTicketsService.CancelHold

#### F2.27.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CancelHold(ctx Ctx, holdId SeatHoldId, by HolderRef) error | P12 F2 |
| Hậu điều kiện | SeatHold CANCELLED, ghế AVAILABLE nếu còn thuộc lần giữ ghế này, cùng một commit; lần giữ ghế đã ở trạng thái cuối khác: HoldNotActiveError mang status, không ghi gì; by không phải người giữ: NotFoundError (không lộ sự tồn tại) | P12 F2, F3 |
| Thao tác nguyên tử | EX-04 + EX-05 gộp (Q-134); X-10 (với hết hạn, báo thanh toán), X-12, X-18, X-22 | P08 F4b; P12 F3 |
| Luồng P04 | UC-005 *a, 7b | P04 UC-005 |
| Không áp dụng | Không áp dụng: F2.27.2 và F2.27.3 gộp ở bảng quyết định (điều kiện nhị phân); F2.27.5 (sự kiện ST-01 kiểm ở các operation của DC-SeatHold) | - |

#### F2.27.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-112 | lần giữ ghế | ACTIVE, now < expiryTime, by là người giữ | Hợp lệ | H1 ACTIVE, now 10:05 | BR-85 |
| EC-113 | lần giữ ghế | ACTIVE nhưng now >= expiryTime | Hợp lệ (kết quả HoldNotActiveError(EXPIRED), vẫn commit) | now = E | BR-86; F3 CancelHold bước 2 |
| EC-114 | lần giữ ghế | trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED) | Không hợp lệ | COMPLETED | BR-86 |
| EC-115 | by | không phải người giữ | Không hợp lệ | khách 8 | P12 F3 (NotFoundError) |
| EC-116 | holdId | không tồn tại | Không hợp lệ | 9999 | P12 F2 NotFoundError |

#### F2.27.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-56 | now so với expiryTime (EC-112) | now = E - 1ms | EC-112 | Huỷ được: CANCELLED, ghế về AVAILABLE |
| BV-57 | now so với expiryTime (EC-113) | now = E | EC-113 | EXPIRED, HoldNotActiveError(EXPIRED), ghế về AVAILABLE, một commit |

#### F2.27.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N152 | bắt đầu | bắt đầu |
| N153 | Do(UserTx): LockByID (hạng 5); now = tx.Now | khối lệnh |
| N154 | LockByID ném NotFoundError? | quyết định |
| N155 | by không phải người giữ? | quyết định |
| N156 | LockByHold (hạng 6) | khối lệnh |
| N157 | Expire(now) đổi được? | quyết định |
| N158 | UpdateStatus; kết quả = HoldNotActiveError(EXPIRED); fn trả nil | khối lệnh |
| N159 | Cancel(now) ném HoldNotActiveError? | quyết định |
| N160 | trả HoldNotActiveError mang status; không ghi gì | khối lệnh |
| N161 | UpdateStatus (CANCELLED) | khối lệnh |
| N162 | còn ghế đã khoá chưa ReleaseHold? | quyết định |
| N163 | ReleaseHold ghế | khối lệnh |
| N164 | SaveChanges cùng giao dịch | khối lệnh |
| N165 | commit; trả kết quả | khối lệnh |
| N166 | trả NotFoundError | khối lệnh |
| N167 | trả NotFoundError (không lộ sự tồn tại) | khối lệnh |
| N168 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE190 | N152 | N153 |  |
| CE191 | N153 | N154 |  |
| CE192 | N154 | N166 | Đúng |
| CE193 | N154 | N155 | Sai |
| CE194 | N155 | N167 | Đúng |
| CE195 | N155 | N156 | Sai |
| CE196 | N156 | N157 |  |
| CE197 | N157 | N158 | Đúng |
| CE198 | N157 | N159 | Sai |
| CE199 | N159 | N160 | Đúng |
| CE200 | N159 | N161 | Sai |
| CE201 | N158 | N162 |  |
| CE202 | N161 | N162 |  |
| CE203 | N162 | N163 | Đúng |
| CE204 | N163 | N162 |  |
| CE205 | N162 | N164 | Sai |
| CE206 | N164 | N165 |  |
| CE207 | N165 | N168 |  |
| CE208 | N166 | N168 |  |
| CE209 | N167 | N168 |  |
| CE210 | N160 | N168 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 21 - 17 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P72 | N152 - N153 - N154 - N155 - N156 - N157 - N159 - N161 - N162 - N163 - N162 - N163 - N162 - N163 - N162 - N164 - N165 - N168 | TC-216 |
| P73 | N152 - N153 - N154 - N155 - N156 - N157 - N158 - N162 - N163 - N162 - N163 - N162 - N163 - N162 - N164 - N165 - N168 | TC-218 |
| P74 | N152 - N153 - N154 - N166 - N168 | TC-220 |
| P75 | N152 - N153 - N154 - N155 - N167 - N168 | TC-219 |
| P76 | N152 - N153 - N154 - N155 - N156 - N157 - N159 - N160 - N168 | TC-221 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE190 | TC-216, TC-218, TC-219, TC-220, TC-221 | Có |
| CE191 | TC-216, TC-218, TC-219, TC-220, TC-221 | Có |
| CE192 | TC-220 | Có |
| CE193 | TC-216, TC-218, TC-219, TC-221 | Có |
| CE194 | TC-219 | Có |
| CE195 | TC-216, TC-218, TC-221 | Có |
| CE196 | TC-216, TC-218, TC-221 | Có |
| CE197 | TC-218 | Có |
| CE198 | TC-216, TC-221 | Có |
| CE199 | TC-221 | Có |
| CE200 | TC-216 | Có |
| CE201 | TC-218 | Có |
| CE202 | TC-216 | Có |
| CE203 | TC-216, TC-218 | Có |
| CE204 | TC-216, TC-218 | Có |
| CE205 | TC-216, TC-218 | Có |
| CE206 | TC-216, TC-218 | Có |
| CE207 | TC-216, TC-218 | Có |
| CE208 | TC-220 | Có |
| CE209 | TC-219 | Có |
| CE210 | TC-221 | Có |

Độ phủ đạt được: C0 = 15/15 lệnh và điểm quyết định (100%); C1 = 21/21 nhánh (100%).

#### F2.27.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-17, IF-18 | fake | IF-17.LockByID trả hold theo điều kiện đầu; IF-18.LockByHold trả các ghế có currentHold = holdId (ghế đã giữ lại cho hold khác không có trong kết quả); SaveChanges ghi lại danh sách ghế | Store thay bằng bộ nhớ |

### F2.28 DC-BookTicketsService.ConfirmCashReceived

#### F2.28.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | ConfirmCashReceived(ctx Ctx, holdId SeatHoldId, clerk HolderRef) (BookingView, error) | P12 F2 |
| Hậu điều kiện | COMPLETED, SOLD, Booking và Ticket; không gửi email; quá hạn: ghi Hết hạn, trả ghế, từ chối (HoldNotActiveError) | P12 F2, F3 |
| BR | BR-44: xác nhận thu tiền tới sau hạn bị từ chối và nhân viên quầy được báo trả tiền; so hạn và bán ghế là một thao tác không chia cắt | P06 |
| Luồng P04 | UC-005 9a1a, 9a2 đến 9a4 (KB2, KB8) | P04 UC-005 |
| Chưa nêu | clerk không phải người giữ ghế: F3 chỉ nói 'kiểm clerk là người giữ ghế', không nêu lỗi | Q-147 |
| Không áp dụng | Không áp dụng: F2.28.5 (kiểm ở các operation của DC-SeatHold và DC-SeatStatus), F2.28.4 (gộp CFG) | - |

#### F2.28.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-117 | lần giữ ghế | ACTIVE, now < expiryTime, clerk là người giữ | Hợp lệ | H1 ACTIVE | BR-44 |
| EC-118 | lần giữ ghế | ACTIVE nhưng now >= expiryTime | Không hợp lệ | now = E | BR-44; UC-005 9a1a |
| EC-119 | lần giữ ghế | đã ở trạng thái cuối | Không hợp lệ | CANCELLED | BR-86 |
| EC-120 | clerk | không phải người giữ | Không hợp lệ | nhân viên 4 | Q-147 |
| EC-121 | holdId | không tồn tại | Không hợp lệ | 9999 | P12 F2 |

#### F2.28.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-58 | now so với expiryTime (EC-117) | now = E - 1ms | EC-117 | Bán thành công |
| BV-59 | now so với expiryTime (EC-118) | now = E | EC-118 | Từ chối; EXPIRED; ghế trả |

#### F2.28.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N169 | bắt đầu | bắt đầu |
| N170 | Do(UserTx): LockByID (5); LockByHold (6); now = tx.Now | khối lệnh |
| N171 | LockByID ném NotFoundError? | quyết định |
| N172 | clerk không phải người giữ? | quyết định |
| N173 | Expire(now) đổi được? | quyết định |
| N174 | UpdateStatus; ReleaseHold từng ghế; SaveChanges; kết quả = HoldNotActiveError(EXPIRED); fn trả nil | khối lệnh |
| N175 | Complete(now) ném HoldNotActiveError? | quyết định |
| N176 | trả HoldNotActiveError mang status; không ghi gì | khối lệnh |
| N177 | còn ghế chưa NewTicket? | quyết định |
| N178 | NewTicket(key, heldPrice, NewTicketCode()) cho một ghế | khối lệnh |
| N179 | NewBooking; InsertWithTickets; MarkSold từng ghế; SaveChanges; UpdateStatus hold | khối lệnh |
| N180 | commit; dựng BookingView (không xếp email) | khối lệnh |
| N181 | trả NotFoundError | khối lệnh |
| N182 | trả lỗi (chờ Q-147) | khối lệnh |
| N183 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE211 | N169 | N170 |  |
| CE212 | N170 | N171 |  |
| CE213 | N171 | N181 | Đúng |
| CE214 | N171 | N172 | Sai |
| CE215 | N172 | N182 | Đúng |
| CE216 | N172 | N173 | Sai |
| CE217 | N173 | N174 | Đúng |
| CE218 | N173 | N175 | Sai |
| CE219 | N175 | N176 | Đúng |
| CE220 | N175 | N177 | Sai |
| CE221 | N177 | N178 | Đúng |
| CE222 | N178 | N177 |  |
| CE223 | N177 | N179 | Sai |
| CE224 | N179 | N180 |  |
| CE225 | N180 | N183 |  |
| CE226 | N174 | N183 |  |
| CE227 | N181 | N183 |  |
| CE228 | N182 | N183 |  |
| CE229 | N176 | N183 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 19 - 15 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P77 | N169 - N170 - N171 - N172 - N173 - N175 - N177 - N178 - N177 - N178 - N177 - N179 - N180 - N183 | TC-225 |
| P78 | N169 - N170 - N171 - N172 - N173 - N174 - N183 | TC-227 |
| P79 | N169 - N170 - N171 - N172 - N173 - N175 - N176 - N183 | TC-228 |
| P80 | N169 - N170 - N171 - N181 - N183 | TC-229 |
| P81 | N169 - N170 - N171 - N172 - N182 - N183 | - |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE211 | TC-225, TC-227, TC-228, TC-229 | Có |
| CE212 | TC-225, TC-227, TC-228, TC-229 | Có |
| CE213 | TC-229 | Có |
| CE214 | TC-225, TC-227, TC-228 | Có |
| CE215 | Không | Không |
| CE216 | TC-225, TC-227, TC-228 | Có |
| CE217 | TC-227 | Có |
| CE218 | TC-225, TC-228 | Có |
| CE219 | TC-228 | Có |
| CE220 | TC-225 | Có |
| CE221 | TC-225 | Có |
| CE222 | TC-225 | Có |
| CE223 | TC-225 | Có |
| CE224 | TC-225 | Có |
| CE225 | TC-225 | Có |
| CE226 | TC-227 | Có |
| CE227 | TC-229 | Có |
| CE228 | Không | Không |
| CE229 | TC-228 | Có |

Độ phủ đạt được: C0 = 12/13 lệnh và điểm quyết định (92%); C1 = 17/19 nhánh (89%).

#### F2.28.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-17, IF-18, IF-20, IF-24 | fake | IF-17 và IF-18 như CancelHold; IF-20.InsertWithTickets ghi lại Booking; IF-24 stub trả mã vé TKA, TKB và mã đặt vé BK1; IF-23 (Enqueue) mock để khẳng định 0 lần gọi | Store và mã ngẫu nhiên thay bằng bộ nhớ và giá trị cố định |

### F2.29 DC-BookTicketsService.StartOnlinePayment

#### F2.29.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | StartOnlinePayment(ctx Ctx, holdId, by HolderRef, clientIp string) (PaymentStart, error) | P12 F2 |
| Hậu điều kiện | Một PaymentTransaction PENDING mới mỗi lần gọi; lần giữ ghế giữ nguyên; lỗi sau commit không đổi lần giữ ghế | P12 F2; BR-90 |
| Luồng P04 | UC-005 10a, 7b | P04 UC-005 |
| Ngoại lệ | HoldNotActiveError, NotFoundError, GatewayConfigurationError | P12 F2 |
| Chưa nêu | by không phải người giữ | Q-147 |
| Không áp dụng | Không áp dụng: F2.29.4 (gộp CFG), F2.29.5; mục tiêu độ phủ: 100% C0 (ưu tiên Trung bình), CFG có thể dùng làm đo C1 | - |

#### F2.29.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-122 | lần giữ ghế | ACTIVE, chưa quá hạn, by là người giữ | Hợp lệ | H1 ACTIVE | BR-90 |
| EC-123 | lần giữ ghế | ACTIVE nhưng now >= expiryTime | Không hợp lệ | now = E | BR-86 |
| EC-124 | lần giữ ghế | đã ở trạng thái cuối | Không hợp lệ | CANCELLED | BR-86 |
| EC-125 | IF-01.CreatePaymentTransaction | ném GatewayConfigurationError | Không hợp lệ | lỗi cấu hình | BR-90; UC-005 10a |
| EC-126 | by | không phải người giữ | Không hợp lệ | khách 8 | Q-147 |
| EC-127 | holdId | không tồn tại | Không hợp lệ | 9999 | P12 F2 |

#### F2.29.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N184 | bắt đầu | bắt đầu |
| N185 | Do: LockByID (5); now = tx.Now | khối lệnh |
| N186 | LockByID ném NotFoundError? | quyết định |
| N187 | by không phải người giữ? | quyết định |
| N188 | Expire(now) đổi được? | quyết định |
| N189 | UpdateStatus; commit; trả HoldNotActiveError(EXPIRED) | khối lệnh |
| N190 | hold.IsActiveAt(now) sai? | quyết định |
| N191 | trả HoldNotActiveError mang status | khối lệnh |
| N192 | FindByHold; CalculateTotal; NewPending; IF-19.Insert; commit | khối lệnh |
| N193 | IF-01.CreatePaymentTransaction(mã, holdRef, tổng, expiry, clientIp) | khối lệnh |
| N194 | IF-01 ném GatewayConfigurationError? | quyết định |
| N195 | trả lỗi (lần giữ ghế giữ nguyên) | khối lệnh |
| N196 | trả PaymentStart | khối lệnh |
| N197 | trả NotFoundError | khối lệnh |
| N198 | trả lỗi (chờ Q-147) | khối lệnh |
| N199 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE230 | N184 | N185 |  |
| CE231 | N185 | N186 |  |
| CE232 | N186 | N197 | Đúng |
| CE233 | N186 | N187 | Sai |
| CE234 | N187 | N198 | Đúng |
| CE235 | N187 | N188 | Sai |
| CE236 | N188 | N189 | Đúng |
| CE237 | N188 | N190 | Sai |
| CE238 | N190 | N191 | Đúng |
| CE239 | N190 | N192 | Sai |
| CE240 | N192 | N193 |  |
| CE241 | N193 | N194 |  |
| CE242 | N194 | N195 | Đúng |
| CE243 | N194 | N196 | Sai |
| CE244 | N196 | N199 |  |
| CE245 | N189 | N199 |  |
| CE246 | N197 | N199 |  |
| CE247 | N198 | N199 |  |
| CE248 | N191 | N199 |  |
| CE249 | N195 | N199 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 20 - 16 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P82 | N184 - N185 - N186 - N187 - N188 - N190 - N192 - N193 - N194 - N196 - N199 | TC-232 |
| P83 | N184 - N185 - N186 - N187 - N188 - N189 - N199 | TC-234 |
| P84 | N184 - N185 - N186 - N187 - N188 - N190 - N191 - N199 | TC-235 |
| P85 | N184 - N185 - N186 - N187 - N188 - N190 - N192 - N193 - N194 - N195 - N199 | TC-236 |
| P86 | N184 - N185 - N186 - N197 - N199 | TC-238 |
| P87 | N184 - N185 - N186 - N187 - N198 - N199 | - |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE230 | TC-232, TC-234, TC-235, TC-236, TC-238 | Có |
| CE231 | TC-232, TC-234, TC-235, TC-236, TC-238 | Có |
| CE232 | TC-238 | Có |
| CE233 | TC-232, TC-234, TC-235, TC-236 | Có |
| CE234 | Không | Không |
| CE235 | TC-232, TC-234, TC-235, TC-236 | Có |
| CE236 | TC-234 | Có |
| CE237 | TC-232, TC-235, TC-236 | Có |
| CE238 | TC-235 | Có |
| CE239 | TC-232, TC-236 | Có |
| CE240 | TC-232, TC-236 | Có |
| CE241 | TC-232, TC-236 | Có |
| CE242 | TC-236 | Có |
| CE243 | TC-232 | Có |
| CE244 | TC-232 | Có |
| CE245 | TC-234 | Có |
| CE246 | TC-238 | Có |
| CE247 | Không | Không |
| CE248 | TC-235 | Có |
| CE249 | TC-236 | Có |

Độ phủ đạt được: C0 = 13/14 lệnh và điểm quyết định (92%); C1 = 18/20 nhánh (90%).

#### F2.29.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-01 | mock | CreatePaymentTransaction trả địa chỉ ký sẵn hoặc GatewayConfigurationError; khẳng định tham số (code, holdRef, int64(tổng), expiryTime, clientIp) và thời điểm gọi sau commit | Hệ thống ngoài: dùng mock để kiểm tương tác (Bước 5) |
| IF-17, IF-18, IF-19, IF-24 | fake | LockByID, FindByHold, Insert (PaymentTransaction); IF-24.NewTransactionCode trả T1 rồi T2 | Store và mã ngẫu nhiên thay bằng bộ nhớ |

### F2.30 DC-PaymentReportService.HandleIpn

#### F2.30.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | HandleIpn(ctx Ctx, params map[string]string) IpnAnswer (không trả error) | P12 F2 |
| Hậu điều kiện | Mọi báo cùng lần giữ ghế tuần tự hoá; tối đa một lần tạo vé; IpnOutcome: PROCESSED, DUPLICATE, INVALID_SIGNATURE, AMOUNT_MISMATCH, UNKNOWN_TRANSACTION, TEMPORARY_FAILURE, MALFORMED | P12 F2, F1b DC-IpnOutcome |
| Thao tác nguyên tử | EX-02 (khoá hạng 5, 6, 7); X-09, X-10, X-11, X-12, X-16 | P08 F4a, F4b |
| Bảng quyết định nguồn | Bảng P09 F7.6: sai chữ ký 97; số tiền không khớp 04; không nhận ra 01; thành công chưa xử lý còn hiệu lực: bán ghế; còn lại: thanh toán trễ và hoàn toàn bộ; đã xử lý: báo trùng 02; thất bại: ghi nhận (chỉ làm hỏng lần giữ ghế khi là giao dịch tạo sau cùng); lỗi tạm thời: rollback | P09 F7.6 |
| Luồng P04 | UC-005 11, 11a, *a; UC-006 2a, 2c, 2d, 2e, 2f | P04 UC-005, UC-006 |
| Chưa nêu | Phạm vi kiểm số tiền (BR-91 chỉ nêu báo thành công): báo thất bại và báo trùng có số tiền khác bản ghi | Q-146 |
| Không áp dụng | Không áp dụng: F2.30.5 (sự kiện ST của SeatHold, PaymentTransaction kiểm ở các operation của DC-SeatHold và DC-PaymentTransaction) | - |

#### F2.30.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-128 | chữ ký (IF-02) | sai | Không hợp lệ | InvalidSignatureError | NFR-16; P09 F7.6 |
| EC-129 | tham số | thiếu hoặc sai kiểu | Không hợp lệ | MalformedReportError | P12 F2 IF-02 |
| EC-130 | mã tham chiếu / mã giao dịch | không nhận ra | Không hợp lệ | mã lạ | BR-38; UC-006 2e |
| EC-131 | số tiền báo thành công chưa xử lý | khác bản ghi (hoặc khác tổng giá ghế khi tạo giao dịch từ báo) | Không hợp lệ | 170.000 so với 180.000 | BR-91; UC-006 2f |
| EC-132 | báo thành công | giao dịch PENDING, lần giữ ghế ACTIVE còn hạn, liên kết ghế khớp | Hợp lệ (bán ghế) | H1 ACTIVE, now 10:05 | BR-37; UC-005 12 |
| EC-133 | báo thành công | lần giữ ghế không còn hiệu lực hoặc giao dịch đã FAILED hoặc liên kết ghế vỡ | Hợp lệ (thanh toán trễ) | H1 EXPIRED | BR-14, BR-15; UC-006 |
| EC-134 | báo thành công | giao dịch đã xử lý (TICKETED hoặc LATE_PAYMENT) | Hợp lệ (báo trùng) | txn TICKETED | BR-37; UC-006 2a |
| EC-135 | báo thất bại | bất kỳ trạng thái | Hợp lệ (ghi nhận) | txn PENDING | BR-39; UC-006 2c, 2d |
| EC-136 | cơ sở dữ liệu | lỗi tạm thời (40P01, 55P03 sau thử lại) | Không hợp lệ | Do trả SystemBusyError | P09 F7.6 |

#### F2.30.4 Bảng quyết định (DT6)

```text
| Điều kiện / Hành động | DT6-R1 | DT6-R2 | DT6-R3 | DT6-R4 | DT6-R5 | DT6-R6 | DT6-R7 | DT6-R8 | DT6-R9 |
| C1: chữ ký hợp lệ | N | Y | Y | Y | Y | Y | Y | Y | Y |
| C2: tham số đủ | - | N | Y | Y | Y | Y | Y | Y | Y |
| C3: nhận ra giao dịch hoặc lần giữ ghế | - | - | N | Y | Y | Y | Y | Y | Y |
| C4: số tiền khớp (báo thành công chưa xử lý) | - | - | - | N | Y | Y | Y | Y | N |
| C5: kết quả decide | - | - | - | SELL hoặc LATE | SELL | LATE | DUPLICATE | FAILURE | DUPLICATE hoặc FAILURE |
| A1: INVALID_SIGNATURE (RspCode 97), không ghi | X | - | - | - | - | - | - | - | - |
| A2: MALFORMED (99), không ghi | - | X | - | - | - | - | - | - | - |
| A3: UNKNOWN_TRANSACTION (01), log, không ghi | - | - | X | - | - | - | - | - | - |
| A4: AMOUNT_MISMATCH (04), log, không ghi | - | - | - | X | - | - | - | - | - |
| A5: PROCESSED (00) và bán ghế | - | - | - | - | X | - | - | - | - |
| A6: PROCESSED (00) và thanh toán trễ, hoàn toàn bộ | - | - | - | - | - | X | - | - | - |
| A7: DUPLICATE (02) | - | - | - | - | - | - | X | - | - |
| A8: PROCESSED (00) và ghi nhận thất bại | - | - | - | - | - | - | - | X | - |
| A9: chưa xác định (chờ Q-146) | - | - | - | - | - | - | - | - | X |
```

Căn cứ: F2 của DC-PaymentReportReceiver nêu Verify trước Decode (sai chữ ký khi cũng thiếu tham số: INVALID_SIGNATURE), P12 F3 và P09 F7.6 nêu thứ tự các bước; R9 chờ Q-146 (BR-91 chỉ nêu báo thành công).

#### F2.30.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N200 | bắt đầu | bắt đầu |
| N201 | IF-02 ném InvalidSignatureError? | quyết định |
| N202 | IF-02 ném MalformedReportError? | quyết định |
| N203 | không tìm thấy lần giữ ghế và giao dịch? | quyết định |
| N204 | Do(SettleReport): LockByID hold (5); LockByHold (6); LockByCode txn (7); now = tx.Now | khối lệnh |
| N205 | chưa có PaymentTransaction? | quyết định |
| N206 | lần giữ ghế IsActiveAt(now)? | quyết định |
| N207 | r.amount khác CalculateTotal? | quyết định |
| N208 | Insert PaymentTransaction từ dữ liệu báo | khối lệnh |
| N209 | r.amount khác txn.Amount? | quyết định |
| N210 | hold.Expire(now) | khối lệnh |
| N211 | Expire đổi được? | quyết định |
| N212 | UpdateStatus hold; ReleaseHold từng ghế; SaveChanges | khối lệnh |
| N213 | decide(r, hold, txn, now) | khối lệnh |
| N214 | settlement = DUPLICATE? | quyết định |
| N215 | txn.RecordDuplicate; UpdateStatus | khối lệnh |
| N216 | settlement = SELL? | quyết định |
| N217 | có ghế đã khoá và mọi ghế IsHeldBy(hold)? | quyết định |
| N218 | NewTicket từng ghế; NewBooking; InsertWithTickets; MarkSold; SaveChanges; hold.Complete; txn.MarkTicketed; UpdateStatus; Enqueue(EMAIL_TICKET) | khối lệnh |
| N219 | settlement = LATE? | quyết định |
| N220 | txn.MarkLatePayment; RefundService.CreateFullRefund | khối lệnh |
| N221 | txn.RecordFailure | khối lệnh |
| N222 | txn là giao dịch tạo sau cùng của lần giữ ghế? | quyết định |
| N223 | hold.IsActiveAt(now)? | quyết định |
| N224 | hold.FailPayment; ReleaseHold từng ghế; SaveChanges | khối lệnh |
| N225 | UpdateStatus txn | khối lệnh |
| N226 | commit | khối lệnh |
| N227 | commit lỗi tạm thời sau thử lại? | quyết định |
| N228 | trả PROCESSED hoặc DUPLICATE | khối lệnh |
| N229 | trả INVALID_SIGNATURE | khối lệnh |
| N230 | trả MALFORMED | khối lệnh |
| N231 | logUnrecognized | khối lệnh |
| N232 | trả UNKNOWN_TRANSACTION | khối lệnh |
| N233 | ghi log; trả AMOUNT_MISMATCH; không ghi | khối lệnh |
| N234 | rollback; trả TEMPORARY_FAILURE | khối lệnh |
| N235 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE250 | N200 | N201 |  |
| CE251 | N201 | N229 | Đúng |
| CE252 | N201 | N202 | Sai |
| CE253 | N202 | N230 | Đúng |
| CE254 | N202 | N203 | Sai |
| CE255 | N203 | N231 | Đúng |
| CE256 | N231 | N232 |  |
| CE257 | N203 | N204 | Sai |
| CE258 | N204 | N205 |  |
| CE259 | N205 | N206 | Đúng |
| CE260 | N205 | N209 | Sai |
| CE261 | N206 | N207 | Đúng |
| CE262 | N206 | N208 | Sai |
| CE263 | N207 | N233 | Đúng |
| CE264 | N207 | N208 | Sai |
| CE265 | N208 | N210 |  |
| CE266 | N209 | N233 | Đúng |
| CE267 | N209 | N210 | Sai |
| CE268 | N210 | N211 |  |
| CE269 | N211 | N212 | Đúng |
| CE270 | N211 | N213 | Sai |
| CE271 | N212 | N213 |  |
| CE272 | N213 | N214 |  |
| CE273 | N214 | N215 | Đúng |
| CE274 | N214 | N216 | Sai |
| CE275 | N215 | N226 |  |
| CE276 | N216 | N217 | Đúng |
| CE277 | N216 | N219 | Sai |
| CE278 | N217 | N218 | Đúng |
| CE279 | N217 | N220 | Sai |
| CE280 | N218 | N226 |  |
| CE281 | N219 | N220 | Đúng |
| CE282 | N219 | N221 | Sai |
| CE283 | N220 | N226 |  |
| CE284 | N221 | N222 |  |
| CE285 | N222 | N223 | Đúng |
| CE286 | N222 | N225 | Sai |
| CE287 | N223 | N224 | Đúng |
| CE288 | N223 | N225 | Sai |
| CE289 | N224 | N225 |  |
| CE290 | N225 | N226 |  |
| CE291 | N226 | N227 |  |
| CE292 | N227 | N234 | Đúng |
| CE293 | N227 | N228 | Sai |
| CE294 | N228 | N235 |  |
| CE295 | N229 | N235 |  |
| CE296 | N230 | N235 |  |
| CE297 | N232 | N235 |  |
| CE298 | N233 | N235 |  |
| CE299 | N234 | N235 |  |

V(G) = số điểm quyết định nhị phân + 1 = 15 + 1 = 16; kiểm bằng E - N + 2 = 50 - 36 + 2 = 16. V(G) lớn hơn 10: đề xuất tách phương thức (xem Đề xuất sửa artifact trước). Vòng lặp theo ghế bên trong các node ReleaseHold, NewTicket, MarkSold gộp vào node khối lệnh (n tối đa 8, đã kiểm ở HoldSeats và ConfirmCashReceived).

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P88 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N216 - N217 - N218 - N226 - N227 - N228 - N235 | TC-239 |
| P89 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N212 - N213 - N214 - N216 - N219 - N220 - N226 - N227 - N228 - N235 | TC-241 |
| P90 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N216 - N219 - N220 - N226 - N227 - N228 - N235 | TC-242 |
| P91 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N216 - N217 - N220 - N226 - N227 - N228 - N235 | TC-244 |
| P92 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N215 - N226 - N227 - N228 - N235 | TC-245 |
| P93 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N216 - N219 - N221 - N222 - N223 - N224 - N225 - N226 - N227 - N228 - N235 | TC-247 |
| P94 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N216 - N219 - N221 - N222 - N225 - N226 - N227 - N228 - N235 | TC-248 |
| P95 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N212 - N213 - N214 - N216 - N219 - N221 - N222 - N223 - N225 - N226 - N227 - N228 - N235 | TC-249 |
| P96 | N200 - N201 - N202 - N203 - N231 - N232 - N235 | TC-251 |
| P97 | N200 - N201 - N202 - N203 - N204 - N205 - N206 - N207 - N208 - N210 - N211 - N213 - N214 - N216 - N217 - N218 - N226 - N227 - N228 - N235 | TC-252 |
| P98 | N200 - N201 - N202 - N203 - N204 - N205 - N206 - N207 - N233 - N235 | TC-253 |
| P99 | N200 - N201 - N202 - N203 - N204 - N205 - N206 - N208 - N210 - N211 - N213 - N214 - N216 - N219 - N220 - N226 - N227 - N228 - N235 | TC-254 |
| P100 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N233 - N235 | TC-255 |
| P101 | N200 - N201 - N229 - N235 | TC-256 |
| P102 | N200 - N201 - N202 - N230 - N235 | TC-257 |
| P103 | N200 - N201 - N202 - N203 - N204 - N205 - N209 - N210 - N211 - N213 - N214 - N216 - N217 - N218 - N226 - N227 - N234 - N235 | TC-259 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE250 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-251, TC-252, TC-253, TC-254, TC-255, TC-256, TC-257, TC-259 | Có |
| CE251 | TC-256 | Có |
| CE252 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-251, TC-252, TC-253, TC-254, TC-255, TC-257, TC-259 | Có |
| CE253 | TC-257 | Có |
| CE254 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-251, TC-252, TC-253, TC-254, TC-255, TC-259 | Có |
| CE255 | TC-251 | Có |
| CE256 | TC-251 | Có |
| CE257 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-253, TC-254, TC-255, TC-259 | Có |
| CE258 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-253, TC-254, TC-255, TC-259 | Có |
| CE259 | TC-252, TC-253, TC-254 | Có |
| CE260 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-255, TC-259 | Có |
| CE261 | TC-252, TC-253 | Có |
| CE262 | TC-254 | Có |
| CE263 | TC-253 | Có |
| CE264 | TC-252 | Có |
| CE265 | TC-252, TC-254 | Có |
| CE266 | TC-255 | Có |
| CE267 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-259 | Có |
| CE268 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-254, TC-259 | Có |
| CE269 | TC-241, TC-249 | Có |
| CE270 | TC-239, TC-242, TC-244, TC-245, TC-247, TC-248, TC-252, TC-254, TC-259 | Có |
| CE271 | TC-241, TC-249 | Có |
| CE272 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-254, TC-259 | Có |
| CE273 | TC-245 | Có |
| CE274 | TC-239, TC-241, TC-242, TC-244, TC-247, TC-248, TC-249, TC-252, TC-254, TC-259 | Có |
| CE275 | TC-245 | Có |
| CE276 | TC-239, TC-244, TC-252, TC-259 | Có |
| CE277 | TC-241, TC-242, TC-247, TC-248, TC-249, TC-254 | Có |
| CE278 | TC-239, TC-252, TC-259 | Có |
| CE279 | TC-244 | Có |
| CE280 | TC-239, TC-252, TC-259 | Có |
| CE281 | TC-241, TC-242, TC-254 | Có |
| CE282 | TC-247, TC-248, TC-249 | Có |
| CE283 | TC-241, TC-242, TC-244, TC-254 | Có |
| CE284 | TC-247, TC-248, TC-249 | Có |
| CE285 | TC-247, TC-249 | Có |
| CE286 | TC-248 | Có |
| CE287 | TC-247 | Có |
| CE288 | TC-249 | Có |
| CE289 | TC-247 | Có |
| CE290 | TC-247, TC-248, TC-249 | Có |
| CE291 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-254, TC-259 | Có |
| CE292 | TC-259 | Có |
| CE293 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-254 | Có |
| CE294 | TC-239, TC-241, TC-242, TC-244, TC-245, TC-247, TC-248, TC-249, TC-252, TC-254 | Có |
| CE295 | TC-256 | Có |
| CE296 | TC-257 | Có |
| CE297 | TC-251 | Có |
| CE298 | TC-253, TC-255 | Có |
| CE299 | TC-259 | Có |

Độ phủ đạt được: C0 = 34/34 lệnh và điểm quyết định (100%); C1 = 50/50 nhánh (100%).

V(G) lớn hơn 10: đề xuất tách HandleIpn (giai đoạn tra cứu và xác thực, giai đoạn tạo giao dịch từ báo, giai đoạn thực thi settlement SELL, LATE, FAILURE, DUPLICATE thành hàm riêng) hoặc đưa pha ghi vào lớp miền không trạng thái như X1 RV-01; ghi ở Đề xuất sửa artifact trước.

#### F2.30.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-02 | stub | ReportTransactionResult trả PaymentReport theo điều kiện đầu hoặc InvalidSignatureError, MalformedReportError | Hệ thống ngoài (cổng): stub kết quả giải mã |
| IF-17, IF-18, IF-19, IF-20 | fake | FindIDByRef; LockByID; LockByHold; LockByCode; FindLatestByHold; Insert; UpdateStatus; InsertWithTickets; SaveChanges; ghi lại thứ tự gọi | Store thay bằng bộ nhớ; guard khoá thật |
| DC-RefundService | mock | CreateFullRefund(tx, txn): khẳng định đúng 1 lần với LATE, 0 lần với SELL, DUPLICATE, FAILURE | Kiểm tương tác; logic hoàn tiền kiểm ở DC-RefundService.CreateFullRefund, RequestTicketRefund |
| IF-23 | mock | Enqueue(EMAIL_TICKET) đúng 1 lần ở SELL, 0 lần ở nhánh khác | Kiểm tương tác |
| logUnrecognized (log) | spy | Đếm số lần ghi log lỗi | Kiểm hiệu ứng phụ |

### F2.31 DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents)

#### F2.31.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error); expireBatch(ctx) (int, error); cleanupEvents(ctx) (int, error) | P12 F2 |
| Hậu điều kiện | Mỗi lần giữ ghế ACTIVE đã quá hạn chuyển EXPIRED; chạy lặp an toàn; lặp expireBatch tới khi lô ít hơn batchSize (200) hoặc hết budget (8 giây), rồi cleanupEvents(IF-22.DeleteOlderThan(10 phút, 200)) | P12 F2, F3; P09 F7.4 |
| BR / NFR | BR-10, BR-85, BR-86; NFR-07 (ghế được giải phóng trong 1 phút; HoldExpiryJob chỉ đổi lần giữ ghế, không đổi ghế, ghế do SeatReleaseJob trả) | P06; P12 F3 |
| Chưa nêu | Sau khi hết budget, cleanupEvents có chạy không (ngữ cảnh nào) | Q-148; X1 RV-04 |
| Không áp dụng | Không áp dụng: F2.31.2 và F2.31.3 theo vòng lặp (ghi ở bảng vòng lặp), F2.31.5 (không là sự kiện ST; Expire kiểm ở DC-SeatHold.Expire) | - |

#### F2.31.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-137 | số lần giữ ghế đã quá hạn | 0 | Hợp lệ | 0 | NFR-07 |
| EC-138 | số lần giữ ghế đã quá hạn | 1 đến 199 (một lô chưa đầy) | Hợp lệ | 50 | P09 F7.4 |
| EC-139 | số lần giữ ghế đã quá hạn | từ 200 (lô đầy, cần lô tiếp) | Hợp lệ | 200; 201 | P09 F7.4 |
| EC-140 | hàng ứng viên | hàng chưa quá hạn theo tx.Now (ứng viên chọn trước khoá) | Không hợp lệ (bỏ qua) | expiry 10:10:30 | P12 F3 (UpdateStatus chỉ khi Expire đổi) |
| EC-141 | expireBatch | trả lỗi | Không hợp lệ | lỗi CSDL | P12 F2 |

#### F2.31.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N236 | bắt đầu | bắt đầu |
| N237 | expireBatch: Do(BackgroundTx): LockExpiredBatch; now = tx.Now; Expire từng hold; UpdateStatus hold đổi | khối lệnh |
| N238 | expireBatch trả lỗi? | quyết định |
| N239 | số hold của lô nhỏ hơn batchSize (200)? | quyết định |
| N240 | hết budget? | quyết định |
| N241 | cleanupEvents (IF-22.DeleteOlderThan(10 phút, 200)) | khối lệnh |
| N242 | trả lỗi (các lô trước đã commit) | khối lệnh |
| N243 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE300 | N236 | N237 |  |
| CE301 | N237 | N238 |  |
| CE302 | N238 | N242 | Đúng |
| CE303 | N238 | N239 | Sai |
| CE304 | N239 | N241 | Đúng |
| CE305 | N239 | N240 | Sai |
| CE306 | N240 | N241 | Đúng |
| CE307 | N240 | N237 | Sai |
| CE308 | N241 | N243 |  |
| CE309 | N242 | N243 |  |

V(G) = số điểm quyết định nhị phân + 1 = 3 + 1 = 4; kiểm bằng E - N + 2 = 10 - 8 + 2 = 4.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P104 | N236 - N237 - N238 - N239 - N241 - N243 | TC-267 |
| P105 | N236 - N237 - N238 - N239 - N240 - N237 - N238 - N239 - N241 - N243 | TC-271 |
| P106 | N236 - N237 - N238 - N239 - N240 - N241 - N243 | TC-274 |
| P107 | N236 - N237 - N238 - N239 - N240 - N237 - N238 - N242 - N243 | TC-276 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE300 | TC-267, TC-271, TC-274, TC-276 | Có |
| CE301 | TC-267, TC-271, TC-274, TC-276 | Có |
| CE302 | TC-276 | Có |
| CE303 | TC-267, TC-271, TC-274, TC-276 | Có |
| CE304 | TC-267, TC-271 | Có |
| CE305 | TC-271, TC-274, TC-276 | Có |
| CE306 | TC-274 | Có |
| CE307 | TC-271, TC-276 | Có |
| CE308 | TC-267, TC-271, TC-274 | Có |
| CE309 | TC-276 | Có |

Độ phủ đạt được: C0 = 6/6 lệnh và điểm quyết định (100%); C1 = 10/10 nhánh (100%).

Vòng lặp:

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử (0, 1, m, n-1, n, n+1) | TC |
|---|---|---|---|---|
| expireBatch trên một lô | 200 (batchSize) | 50 | 0, 1, 50, 199, 200, 201 hold quá hạn | TC-267, TC-277, TC-268, TC-269, TC-270, TC-271, TC-272 |

#### F2.31.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-17 | fake | LockExpiredBatch trả tối đa limit hàng ACTIVE đã quá hạn (chọn theo expiry nhỏ hơn tx.Now); UpdateStatus ghi lại; đếm số lần gọi | Store thay bằng bộ nhớ; SKIP LOCKED là ca tích hợp |
| IF-22 | mock | DeleteOlderThan(10 phút, 200): khẳng định số lần gọi và tham số | Kiểm tương tác |
| IF-18 | mock | Khẳng định 0 lần gọi (job không đổi ghế) | NFR-07: ghế do SeatReleaseJob trả |
| Đồng hồ ngân sách | stub | Context có deadline giả: tiến theo lệnh của test | Thời gian tiêm vào |

### F2.32 DC-SeatReleaseJob.RunDue (releaseBatch)

#### F2.32.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | RunDue(ctx, budget) (JobRunResult, error); releaseBatch(ctx) (int, error) | P12 F2 |
| Hậu điều kiện | Một giao dịch mỗi lô: LockReleasableBatch (hạng 5, SKIP LOCKED) rồi LockByHolds (hạng 6), ReleaseHold ghế còn trỏ tới lần giữ ghế đã ở trạng thái cuối, SaveChanges; chạy lặp an toàn | P12 F2, F3 |
| BR / thao tác nguyên tử | REQ-76, NFR-07 (1 phút), X-12, X-13, X-18, X-22; lưới an toàn cho Q-134 | P08 F4b; P12 F3 |
| Không áp dụng | Không áp dụng: F2.32.2 và F2.32.3 theo vòng lặp (bảng vòng lặp); F2.32.4 (một điều kiện) | - |

#### F2.32.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-142 | lô lần giữ ghế đạt điều kiện | rỗng | Hợp lệ | [] | P12 F3 |
| EC-143 | ghế còn trỏ tới lần giữ ghế đã ở trạng thái cuối | HELD với currentHold thuộc lô | Hợp lệ | ghế 101..103 của H1 EXPIRED | REQ-76 |
| EC-144 | ghế đã giữ lại cho lần giữ ghế khác | HELD với currentHold ngoài lô | Hợp lệ (không đổi) | ghế 105 HELD bởi H2 ACTIVE | R-63; X-13, X-18 |
| EC-145 | lần giữ ghế COMPLETED | ghế SOLD | Hợp lệ (không đổi) | ghế SOLD | X-12 |

#### F2.32.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N244 | bắt đầu | bắt đầu |
| N245 | Do(BackgroundTx): LockReleasableBatch (hạng 5) | khối lệnh |
| N246 | lô rỗng? | quyết định |
| N247 | LockByHolds (hạng 6) | khối lệnh |
| N248 | còn ghế chưa xử lý? | quyết định |
| N249 | ReleaseHold(holdId của lần giữ ghế đang trỏ tới ghế) | khối lệnh |
| N250 | ReleaseHold trả true? | quyết định |
| N251 | gom ghế đã đổi | khối lệnh |
| N252 | SaveChanges (ghế đã đổi); commit; trả số ghế | khối lệnh |
| N253 | commit; trả 0 | khối lệnh |
| N254 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE310 | N244 | N245 |  |
| CE311 | N245 | N246 |  |
| CE312 | N246 | N253 | Đúng |
| CE313 | N246 | N247 | Sai |
| CE314 | N247 | N248 |  |
| CE315 | N248 | N249 | Đúng |
| CE316 | N249 | N250 |  |
| CE317 | N250 | N251 | Đúng |
| CE318 | N250 | N248 | Sai |
| CE319 | N251 | N248 |  |
| CE320 | N248 | N252 | Sai |
| CE321 | N252 | N254 |  |
| CE322 | N253 | N254 |  |

V(G) = số điểm quyết định nhị phân + 1 = 3 + 1 = 4; kiểm bằng E - N + 2 = 13 - 11 + 2 = 4.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P108 | N244 - N245 - N246 - N253 - N254 | TC-278 |
| P109 | N244 - N245 - N246 - N247 - N248 - N249 - N250 - N251 - N248 - N249 - N250 - N251 - N248 - N249 - N250 - N251 - N248 - N252 - N254 | TC-279 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE310 | TC-278, TC-279 | Có |
| CE311 | TC-278, TC-279 | Có |
| CE312 | TC-278 | Có |
| CE313 | TC-279 | Có |
| CE314 | TC-279 | Có |
| CE315 | TC-279 | Có |
| CE316 | TC-279 | Có |
| CE317 | TC-279 | Có |
| CE318 | - | Loại khỏi mẫu số: LockByHolds chỉ trả ghế có current_hold_id thuộc lô nên ReleaseHold luôn đúng; ghế đã giữ lại cho lần giữ ghế khác không nằm trong kết quả khoá (P12 F2 IF-18.LockByHolds). Đề xuất P12: ghi bất biến hoặc bỏ nhánh |
| CE319 | TC-279 | Có |
| CE320 | TC-279 | Có |
| CE321 | TC-279 | Có |
| CE322 | TC-278 | Có |

Độ phủ đạt được: C0 = 9/9 lệnh và điểm quyết định (100%); C1 = 12/12 nhánh (100%).

Vòng lặp:

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử (0, 1, m, n-1, n, n+1) | TC |
|---|---|---|---|---|
| RunDue lặp releaseBatch trên số lần giữ ghế | 200 (batchSize) | 50 | 0, 1, 199, 200, 201 lần giữ ghế đạt điều kiện (m = 50 cùng lớp với 1) | TC-278, TC-282, TC-279, TC-283, TC-284, TC-285, TC-286 |

#### F2.32.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-17, IF-18 | fake | LockReleasableBatch trả các lần giữ ghế trạng thái cuối khác COMPLETED còn ghế trỏ tới (mã tăng dần); LockByHolds trả ghế có currentHold thuộc lô; SaveChanges ghi lại danh sách; thứ tự gọi ghi lại | Store thay bằng bộ nhớ |

### F2.33 DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx)

#### F2.33.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CancelOnlineTicket(ctx, ticketId, customer ActorContext) (CancelResult, error); ConfirmCashRefund(ctx, ticketId, clerk ActorContext) (CancelResult, error); private cancelInTx(ctx, tx, ticketId, actor, cash bool) | P12 F2 |
| Hậu điều kiện | Vé CANCELLED, ghế AVAILABLE nếu còn thuộc vé, RefundRequest NEW kèm dòng hàng đợi (trực tuyến) hoặc RefundRequest TICKET_CASH REFUNDED (quầy), cùng một commit; vé đã huỷ: TicketStateError, không có đường chạy tiếp | P12 F2, F3 |
| Thao tác nguyên tử | Q-133: EX-06, EX-07, EX-09 gộp; thứ tự khoá 6, 7, 8 rồi chèn hạng 9; X-14, X-15, X-16, X-23 | P08 F4b; P12 F3 |
| Thứ tự kiểm (nguồn P04) | UC-008: 2a, 2b, 2c (kênh, bước 2) trước 3a (hạn, bước 3) trước 4a (đã huỷ) trước 4b (đã sử dụng) (mục 3, thứ tự bước và ghi chú 'kiểm trước 4b') | P04 UC-008 |
| Luồng P04 | UC-008 2a, 2b, 2c, 3a, 4a, 4b, 5a1, 5a2 | P04 UC-008 |
| Khoảng trống P12 | Luồng 2c (nhân viên quầy khác cụm rạp) do ConfirmCashRefund kiểm bằng Showtime.BelongsToCinema(clerk.cinemaId) từ P12 1.5; Booking.CheckCancellationChannel không nhận cụm rạp (Đề xuất sửa P12 dòng 10 đã áp dụng) | P12 F2, F3 |
| Không áp dụng | Không áp dụng: F2.33.5 (sự kiện ST-03, ST-02 kiểm ở DC-SeatStatus.ReleaseTicket và DC-Ticket.Cancel) | - |

#### F2.33.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-146 | kênh, hạn, trạng thái vé | đúng kênh, còn từ 2 giờ, vé UNUSED | Hợp lệ | khách 7 huỷ vé TK1 của mình, now 17:00 | BR-17, BR-18, BR-21 |
| EC-147 | kênh | sai kênh hoặc sai chủ (2a, 2b, 2c) | Không hợp lệ | khách 8 huỷ vé của khách 7 | BR-17 |
| EC-148 | hạn huỷ | còn dưới 2 giờ hoặc đã bắt đầu | Không hợp lệ | now 18:00:00.001 | BR-18, BR-32 |
| EC-149 | trạng thái vé | đã huỷ hoặc đã sử dụng | Không hợp lệ | CANCELLED; USED | BR-21, BR-30 |
| EC-150 | hạn mức hoàn | refundedTotal + 70% vượt số đã thanh toán | Không hợp lệ | RefundLimitError từ RequestTicketRefund | BR-26 |
| EC-151 | liên kết ghế | currentTicket khác vé đang huỷ (ghế đã bán lại) | Hợp lệ (ghế giữ nguyên) | ghế SOLD bởi TK9 | BR-42; R-64 |
| EC-152 | kênh quầy | vé mua tại quầy, nhân viên đúng cụm rạp | Hợp lệ | nhân viên 4, vé của hold CLERK 3 | BR-20 |

#### F2.33.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-60 | thời điểm huỷ (EC-146) | now = 18:00:00.000 (đúng 2 giờ trước 20:00) | EC-146 | Huỷ được |
| BV-61 | thời điểm huỷ (EC-148) | now = 18:00:00.001 | EC-148 | CancelDeadlineError |

#### F2.33.4 Bảng quyết định (DT7)

```text
| Điều kiện / Hành động | DT7-R1 | DT7-R2 | DT7-R3 | DT7-R4 | DT7-R5 | DT7-R6 |
| C1: sai kênh hoặc chủ (UC-008 2a, 2b, 2c) | N | Y | N | N | N | N/A |
| C2: quá hạn huỷ 2 giờ (3a) | N | - | Y | N | N | N/A |
| C3: vé đã huỷ (4a) | N | - | - | Y | N | N/A |
| C4: vé đã sử dụng (4b) | N | - | - | - | Y | N/A |
| A0: huỷ thành công | X | - | - | - | - | N/A |
| A1: ChannelMismatchError | - | X | - | - | - | N/A |
| A2: CancelDeadlineError | - | - | X | - | - | N/A |
| A3: TicketStateError(CANCELLED) | - | - | - | X | - | N/A |
| A4: TicketStateError(USED) | - | - | - | - | X | N/A |
```

Căn cứ: Gộp - có căn cứ: P04 UC-008 mục 3 theo thứ tự bước 2 (kênh), bước 3 (hạn), 4a trước 4b; P12 F3 trùng thứ tự CheckCancellationChannel, CheckCancellationDeadline, Ticket.Cancel (đã huỷ trước, đã sử dụng sau).

DT7-R6: N/A, C3 và C4 không cùng đúng (vé không vừa đã huỷ vừa đã sử dụng).

#### F2.33.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N255 | bắt đầu | bắt đầu |
| N256 | Do: IF-20.FindByTicket; IF-11.FindByID suất chiếu | khối lệnh |
| N257 | FindByTicket ném NotFoundError? | quyết định |
| N258 | LockByKey ghế (hạng 6) | khối lệnh |
| N259 | cash = true? | quyết định |
| N260 | LockPaymentOfTicket (hạng 7) | khối lệnh |
| N261 | LockTicketByID (hạng 8); now = tx.Now | khối lệnh |
| N262 | một lời gọi khoá ném NotFoundError hoặc SystemBusyError? | quyết định |
| N263 | CheckCancellationChannel ném ChannelMismatchError? | quyết định |
| N264 | CheckCancellationDeadline ném CancelDeadlineError? | quyết định |
| N265 | Ticket.Cancel ném TicketStateError? | quyết định |
| N266 | UpdateTicketStatus; ReleaseTicket | khối lệnh |
| N267 | ReleaseTicket trả true? | quyết định |
| N268 | SaveChanges (ghế) | khối lệnh |
| N269 | cash = true? | quyết định |
| N270 | IF-21.Insert(NewCashRefund) | khối lệnh |
| N271 | RefundAmount; RefundService.RequestTicketRefund | khối lệnh |
| N272 | RequestTicketRefund ném RefundLimitError? | quyết định |
| N273 | commit; trả CancelResult | khối lệnh |
| N274 | trả NotFoundError | khối lệnh |
| N275 | fn trả lỗi, rollback | khối lệnh |
| N276 | trả ChannelMismatchError | khối lệnh |
| N277 | trả CancelDeadlineError | khối lệnh |
| N278 | trả TicketStateError | khối lệnh |
| N279 | trả RefundLimitError, rollback trọn | khối lệnh |
| N280 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE323 | N255 | N256 |  |
| CE324 | N256 | N257 |  |
| CE325 | N257 | N274 | Đúng |
| CE326 | N257 | N258 | Sai |
| CE327 | N258 | N259 |  |
| CE328 | N259 | N261 | Đúng |
| CE329 | N259 | N260 | Sai |
| CE330 | N260 | N261 |  |
| CE331 | N261 | N262 |  |
| CE332 | N262 | N275 | Đúng |
| CE333 | N262 | N263 | Sai |
| CE334 | N263 | N276 | Đúng |
| CE335 | N263 | N264 | Sai |
| CE336 | N264 | N277 | Đúng |
| CE337 | N264 | N265 | Sai |
| CE338 | N265 | N278 | Đúng |
| CE339 | N265 | N266 | Sai |
| CE340 | N266 | N267 |  |
| CE341 | N267 | N268 | Đúng |
| CE342 | N267 | N269 | Sai |
| CE343 | N268 | N269 |  |
| CE344 | N269 | N270 | Đúng |
| CE345 | N269 | N271 | Sai |
| CE346 | N271 | N272 |  |
| CE347 | N272 | N279 | Đúng |
| CE348 | N272 | N273 | Sai |
| CE349 | N270 | N273 |  |
| CE350 | N273 | N280 |  |
| CE351 | N274 | N280 |  |
| CE352 | N275 | N280 |  |
| CE353 | N276 | N280 |  |
| CE354 | N277 | N280 |  |
| CE355 | N278 | N280 |  |
| CE356 | N279 | N280 |  |

V(G) = số điểm quyết định nhị phân + 1 = 9 + 1 = 10; kiểm bằng E - N + 2 = 34 - 26 + 2 = 10. cancelInTx là thân chung; cờ cash tạo hai điểm quyết định (dc1, dc2) nên hai operation công khai cùng phủ một CFG.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P110 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N263 - N264 - N265 - N266 - N267 - N268 - N269 - N271 - N272 - N273 - N280 | TC-287 |
| P111 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N263 - N264 - N265 - N266 - N267 - N269 - N271 - N272 - N273 - N280 | TC-298 |
| P112 | N255 - N256 - N257 - N274 - N280 | TC-300 |
| P113 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N275 - N280 | TC-301 |
| P114 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N263 - N276 - N280 | TC-291 |
| P115 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N263 - N264 - N277 - N280 | TC-289 |
| P116 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N263 - N264 - N265 - N278 - N280 | TC-293 |
| P117 | N255 - N256 - N257 - N258 - N259 - N260 - N261 - N262 - N263 - N264 - N265 - N266 - N267 - N268 - N269 - N271 - N272 - N279 - N280 | TC-297 |
| P118 | N255 - N256 - N257 - N258 - N259 - N261 - N262 - N263 - N264 - N265 - N266 - N267 - N268 - N269 - N270 - N273 - N280 | TC-302 |
| P119 | N255 - N256 - N257 - N258 - N259 - N261 - N262 - N263 - N276 - N280 | TC-303 |
| P120 | N255 - N256 - N257 - N258 - N259 - N261 - N262 - N263 - N264 - N265 - N266 - N267 - N269 - N270 - N273 - N280 | TC-307 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE323 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-300, TC-301, TC-302, TC-303, TC-307 | Có |
| CE324 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-300, TC-301, TC-302, TC-303, TC-307 | Có |
| CE325 | TC-300 | Có |
| CE326 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-301, TC-302, TC-303, TC-307 | Có |
| CE327 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-301, TC-302, TC-303, TC-307 | Có |
| CE328 | TC-302, TC-303, TC-307 | Có |
| CE329 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-301 | Có |
| CE330 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-301 | Có |
| CE331 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-301, TC-302, TC-303, TC-307 | Có |
| CE332 | TC-301 | Có |
| CE333 | TC-287, TC-289, TC-291, TC-293, TC-297, TC-298, TC-302, TC-303, TC-307 | Có |
| CE334 | TC-291, TC-303 | Có |
| CE335 | TC-287, TC-289, TC-293, TC-297, TC-298, TC-302, TC-307 | Có |
| CE336 | TC-289 | Có |
| CE337 | TC-287, TC-293, TC-297, TC-298, TC-302, TC-307 | Có |
| CE338 | TC-293 | Có |
| CE339 | TC-287, TC-297, TC-298, TC-302, TC-307 | Có |
| CE340 | TC-287, TC-297, TC-298, TC-302, TC-307 | Có |
| CE341 | TC-287, TC-297, TC-302 | Có |
| CE342 | TC-298, TC-307 | Có |
| CE343 | TC-287, TC-297, TC-302 | Có |
| CE344 | TC-302, TC-307 | Có |
| CE345 | TC-287, TC-297, TC-298 | Có |
| CE346 | TC-287, TC-297, TC-298 | Có |
| CE347 | TC-297 | Có |
| CE348 | TC-287, TC-298 | Có |
| CE349 | TC-302, TC-307 | Có |
| CE350 | TC-287, TC-298, TC-302, TC-307 | Có |
| CE351 | TC-300 | Có |
| CE352 | TC-301 | Có |
| CE353 | TC-291, TC-303 | Có |
| CE354 | TC-289 | Có |
| CE355 | TC-293 | Có |
| CE356 | TC-297 | Có |

Độ phủ đạt được: C0 = 24/24 lệnh và điểm quyết định (100%); C1 = 34/34 nhánh (100%).

#### F2.33.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-11, IF-18, IF-20 | fake | FindByTicket trả Booking (người giữ, kênh); FindByID trả Showtime 55 (start 2026-11-10 20:00, cụm rạp 2); LockByKey; LockTicketByID; UpdateTicketStatus; SaveChanges; thứ tự gọi ghi lại | Store thay bằng bộ nhớ |
| DC-RefundService | mock | LockPaymentOfTicket trả PT1 (amount 200.000, TICKETED); RequestTicketRefund(tx, txn, ticket, amount): ghi lại tham số, có thể trả RefundLimitError | Kiểm tương tác; logic hoàn tiền kiểm ở DC-RefundService.CreateFullRefund, RequestTicketRefund |
| IF-21 | mock | Insert(NewCashRefund): khẳng định tham số ở nhánh tiền mặt; IF-23.Enqueue và IF-01: 0 lần ở nhánh tiền mặt | Kiểm tương tác |

### F2.34 DC-CheckTicketService.CheckTicket

#### F2.34.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckTicket(ctx, ticketCode string, showtimeId ShowtimeId, checker ActorContext) (AdmitResult, error) | P12 F2 |
| Hậu điều kiện | USED chỉ khi ADMITTED; hai lần soát đồng thời một vé chỉ một lần ADMITTED; NotFoundError khi mã không tương ứng vé | P12 F2, F3 |
| Luồng P04 | UC-009 4a (mã QR lạ), 4b, 4c, 4d, 4e (lý do qua Ticket.Admit) | P04 UC-009 |
| Không áp dụng | Không áp dụng: F2.34.4 (thứ tự lý do thuộc DC-Ticket.Admit), F2.34.5 | - |

#### F2.34.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-153 | kết quả Admit | ADMITTED | Hợp lệ | vé UNUSED, đúng cụm rạp và suất | BR-22, BR-23 |
| EC-154 | kết quả Admit | một trong WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, CANCELLED | Hợp lệ (từ chối, không ghi) | WRONG_CINEMA | BR-33 |
| EC-155 | ticketCode | không tương ứng vé nào | Không hợp lệ | QR-LẠ | UC-009 4a |

#### F2.34.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N281 | bắt đầu | bắt đầu |
| N282 | Do(UserTx): LockTicketByCode (hạng 8) | khối lệnh |
| N283 | LockTicketByCode ném NotFoundError? | quyết định |
| N284 | IF-11.FindByID suất chiếu | khối lệnh |
| N285 | FindByID ném NotFoundError? | quyết định |
| N286 | Ticket.Admit(showtime, showtimeId, checker.cinemaId) | khối lệnh |
| N287 | kết quả = ADMITTED? | quyết định |
| N288 | UpdateTicketStatus(USED) | khối lệnh |
| N289 | commit; dựng AdmitResult | khối lệnh |
| N290 | trả NotFoundError | khối lệnh |
| N291 | trả NotFoundError (suất chiếu) | khối lệnh |
| N292 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE357 | N281 | N282 |  |
| CE358 | N282 | N283 |  |
| CE359 | N283 | N290 | Đúng |
| CE360 | N283 | N284 | Sai |
| CE361 | N284 | N285 |  |
| CE362 | N285 | N291 | Đúng |
| CE363 | N285 | N286 | Sai |
| CE364 | N286 | N287 |  |
| CE365 | N287 | N288 | Đúng |
| CE366 | N287 | N289 | Sai |
| CE367 | N288 | N289 |  |
| CE368 | N289 | N292 |  |
| CE369 | N290 | N292 |  |
| CE370 | N291 | N292 |  |

V(G) = số điểm quyết định nhị phân + 1 = 3 + 1 = 4; kiểm bằng E - N + 2 = 14 - 12 + 2 = 4.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P121 | N281 - N282 - N283 - N284 - N285 - N286 - N287 - N288 - N289 - N292 | TC-308 |
| P122 | N281 - N282 - N283 - N284 - N285 - N286 - N287 - N289 - N292 | TC-309 |
| P123 | N281 - N282 - N283 - N290 - N292 | TC-313 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE357 | TC-308, TC-309, TC-313 | Có |
| CE358 | TC-308, TC-309, TC-313 | Có |
| CE359 | TC-313 | Có |
| CE360 | TC-308, TC-309 | Có |
| CE361 | TC-308, TC-309 | Có |
| CE362 | - | Loại khỏi mẫu số: Khoá ngoại ticket --> seat_status --> showtime (ON DELETE RESTRICT) và xoá suất chiếu là xoá mềm bảo đảm suất chiếu của vé luôn tồn tại (P13-schema.sql). Đề xuất P12 bỏ NotFoundError của lời gọi này |
| CE363 | TC-308, TC-309 | Có |
| CE364 | TC-308, TC-309 | Có |
| CE365 | TC-308 | Có |
| CE366 | TC-309 | Có |
| CE367 | TC-308 | Có |
| CE368 | TC-308, TC-309 | Có |
| CE369 | TC-313 | Có |
| CE370 | - | Loại khỏi mẫu số: Đi theo nhánh d2 Đúng, không thể tới theo thiết kế (xem CE trước đó) |

Độ phủ đạt được: C0 = 9/9 lệnh và điểm quyết định (100%); C1 = 12/12 nhánh (100%).

#### F2.34.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-11, IF-20 | fake | LockTicketByCode trả Ticket theo mã; FindByID trả Showtime; UpdateTicketStatus ghi lại số lần | Store thay bằng bộ nhớ |

### F2.35 DC-RefundService.CreateFullRefund, RequestTicketRefund

#### F2.35.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CreateFullRefund(ctx, tx, txn) error; RequestTicketRefund(ctx, tx, txn, ticket, amount) error | P12 F2 |
| Hậu điều kiện | Kiểm hạn mức, thêm RefundRequest (FULL hoặc TICKET_GATEWAY), cộng refundedTotal bằng IF-19.AddRefunded, xếp dòng hàng đợi REFUND_GATEWAY; không commit riêng; không gửi email hoàn; không gọi cổng | P12 F2, F3 |
| BR / thao tác nguyên tử | BR-26, BR-43, X-16 (phép cộng nằm trong câu UPDATE, không đọc rồi ghi) | P06; P12 F3 |
| Luồng P04 | UC-006 bước 3 đến 4; UC-008 bước 5 | P04 UC-006, UC-008 |
| Không áp dụng | Không áp dụng: F2.35.5 (không là sự kiện ST); F2.35.6 (thiết kế ngắn, Đo khi có mã nguồn) | - |

#### F2.35.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-156 | hạn mức | refundedTotal + amount <= số đã thanh toán | Hợp lệ | 0 + 100.000 trên 100.000 | BR-26 |
| EC-157 | hạn mức | refundedTotal + amount > số đã thanh toán | Không hợp lệ | 70.000 + 100.000 | BR-26 |
| EC-158 | IF-19.AddRefunded | 0 dòng ảnh hưởng (bên khác vừa cộng) | Không hợp lệ | RefundLimitError từ store | X-16 |

#### F2.35.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-62 | max của EC-156 | refundedTotal 37.000 + 63.000 = 100.000 | EC-156 | Không ngoại lệ |
| BV-63 | max của EC-156 | refundedTotal 37.001 + 63.000 | EC-157 | RefundLimitError |

#### F2.35.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-19, IF-21, IF-23 | mock | Insert, AddRefunded, Enqueue: ghi lại số lần và tham số; AddRefunded cấu hình trả RefundLimitError | Kiểm tương tác; store thay bằng bộ nhớ |
| IF-08 | mock | Khẳng định Do 0 lần được gọi (dùng tx của bên gọi) | Không mở giao dịch riêng |

### F2.36 DC-RefundService.ProcessRefund

#### F2.36.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | ProcessRefund(ctx Ctx, e OutboxEntry) error | P12 F2 |
| Hậu điều kiện | Ba giao dịch ngắn: (1) ExtendClaim có điều kiện claim_token rồi BeginAttempt, commit; (2) ngoài giao dịch FindRefund (từ lần hai) và RequestRefund; (3) ghi kết quả có điều kiện claim_token. Chỉ bên giữ claim_token hợp lệ tại giao dịch 1 mới được gọi cổng. Email hoàn tiền xếp hàng chỉ khi REFUNDED và requestType là FULL | P12 F2, F3 |
| Luồng P04 | UC-006 4a, 5a, 4t, 4b, 5b; UC-008 5b, 6a, 5t, 5c, 6b | P04 UC-006, UC-008 |
| BR | BR-41 (thử lại vài lần sau tra cứu; không tra cứu được thì không gửi lại tự động; hết lượt thì xử lý thủ công, không email), BR-43 (30 giây, cùng khoá chống hoàn trùng) | P06 |
| Thời gian | Hạn mỗi lời gọi cổng = nhỏ hơn của 30 giây và (claimedUntil - hiện tại - 10 giây biên); còn dưới 10 giây thì bỏ lượt; Reschedule 1, 5, 15 phút theo lần thử 1, 2, 3 | P12 F3; P09 F7.7 |
| Chưa nêu / lệch | Giá trị trả về khi bỏ lượt (Q-150); biên 10 giây trùng nhau (Q-149); tên ngoại lệ ErrClaimLost ở F2 và ClaimLostError ở IF-23, F1b (Đề xuất sửa P12 dòng 7) | P12 F2, F3 |
| Không áp dụng | Không áp dụng: F2.36.5 (chuyển trạng thái ST-04 kiểm ở các operation của DC-RefundRequest) | - |

#### F2.36.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-159 | lần gửi | lần đầu (AttemptCount = 1 sau BeginAttempt) | Hợp lệ | RR NEW | BR-43 |
| EC-160 | lần gửi | lần hai trở đi (AttemptCount > 1, kể cả nhận lại claim) | Hợp lệ | RR WAITING_RETRY, attemptCount 1 | Q-118 |
| EC-161 | FindRefund | REFUNDED | Hợp lệ (không gửi lại) | REFUNDED | BR-41 |
| EC-162 | FindRefund | NOT_REFUNDED | Hợp lệ (gửi lại cùng khoá) | NOT_REFUNDED | BR-41 |
| EC-163 | FindRefund | NOT_SUPPORTED hoặc UNREACHABLE | Hợp lệ (xử lý thủ công, không gửi lại tự động) | UNREACHABLE | BR-41; UC-006 4b |
| EC-164 | RequestRefund | SUCCEEDED | Hợp lệ | SUCCEEDED | BR-43 |
| EC-165 | RequestRefund | REJECTED hoặc UNKNOWN (hết 30 giây) | Hợp lệ (thử lại hoặc hết lượt) | UNKNOWN | BR-41, BR-43 |
| EC-166 | claim_token ở giao dịch 1 | đã mất (claim hết hạn và bản khác nhận) | Không hợp lệ | ClaimLostError | P09 F7.7; T5b |
| EC-167 | claim_token ở giao dịch 3 | đã mất | Không hợp lệ | ClaimLostError ở MarkSucceeded | P09 F7.7 |
| EC-168 | trạng thái RefundRequest khi nhận dòng | REFUNDED hoặc MANUAL_REQUIRED (dòng giao lại) | Hợp lệ (chỉ đóng dòng) | REFUNDED | P12 F3 bước 1 |
| EC-169 | IN_FLIGHT khi nhận lại claim | hết lượt (attemptCount = 4) | Hợp lệ (xử lý thủ công) | IN_FLIGHT, 4 | BR-41; ST-04 STT 10 |
| EC-170 | phần claim còn lại sau giao dịch 1 | dưới 10 giây | Không hợp lệ (bỏ lượt) | 9 giây | P12 F3 bước 2 |
| EC-171 | phần claim còn lại sau giao dịch 1 | từ 40 giây (hạn gọi cổng = 30 giây) | Hợp lệ | 120 giây | BR-43 |

#### F2.36.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-64 | MaxAttempts (RR attemptCount trước khi ghi kết quả) | attemptCount 3 thất bại --> Reschedule 15 phút | EC-165 | WAITING_RETRY, hẹn 15 phút |
| BV-65 | MaxAttempts | attemptCount 4 thất bại | EC-165 | MANUAL_REQUIRED, MarkExhausted |
| BV-66 | phần claim còn lại (EC-170) | 9,999 giây | EC-170 | Bỏ lượt, không gọi cổng |
| BV-67 | phần claim còn lại (EC-170) | 10,001 giây | EC-170 | Chưa xác định: chờ Q-149 |
| BV-68 | hạn gọi cổng | claim còn 40 giây --> hạn 30 giây | EC-171 | ctx deadline 30 giây |
| BV-69 | hạn gọi cổng | claim còn 35 giây --> hạn 25 giây | EC-171 | ctx deadline 25 giây |

#### F2.36.4 Bảng quyết định (DT8)

```text
| Điều kiện / Hành động | DT8-R1 | DT8-R2 | DT8-R3 | DT8-R4 | DT8-R5 | DT8-R6 | DT8-R7 | DT8-R8 | DT8-R9 | DT8-R10 | DT8-R11 |
| C1: giữ claim_token hợp lệ | N | Y | Y | Y | Y | N/A | Y | Y | Y | Y | Y |
| C2: RR đã REFUNDED hoặc MANUAL_REQUIRED | - | Y | N | N | N | N/A | N | N | N | N | N |
| C3: RR IN_FLIGHT và hết lượt | - | - | Y | N | N | N/A | N | N | N | N | N |
| C4: lần gửi từ lần hai | - | - | - | N | N | N/A | Y | Y | Y | Y | Y |
| C5: kết quả tra cứu | - | - | - | - | - | N/A | REFUNDED | NOT_REFUNDED | NOT_REFUNDED | NOT_REFUNDED | NOT_SUPPORTED hoặc UNREACHABLE |
| C6: kết quả gửi hoàn | - | - | - | SUCCEEDED | REJECTED hoặc UNKNOWN | N/A | - | SUCCEEDED | REJECTED hoặc UNKNOWN | REJECTED hoặc UNKNOWN | - |
| C7: còn lượt sau thất bại | - | - | - | - | Y | N/A | - | - | Y | N | - |
| A1: ClaimLostError, không gọi cổng, không đổi gì | X | - | - | - | - | N/A | - | - | - | - | - |
| A2: chỉ đóng dòng hàng đợi (MarkSucceeded) | - | X | - | - | - | N/A | - | - | - | - | - |
| A3: MANUAL_REQUIRED, đóng dòng, không gọi cổng | - | - | X | - | - | N/A | - | - | - | - | X |
| A4: gửi hoàn (cùng khoá) | - | - | - | X | X | N/A | - | X | X | X | - |
| A5: REFUNDED (+ email nếu FULL), MarkSucceeded | - | - | - | X | - | N/A | X | X | - | - | - |
| A6: WAITING_RETRY, Reschedule | - | - | - | - | X | N/A | - | - | X | - | - |
| A7: MANUAL_REQUIRED, MarkExhausted | - | - | - | - | - | N/A | - | - | - | X | - |
```

Căn cứ: thứ tự bước của P12 F3 bước 1 và 2 trùng P09 F7.7 và P04 UC-006 (4a, 5a, 4t, 4b, 5b). Gộp - có căn cứ: A4 'gửi hoàn' ghi cả hai hành động liên tiếp (RequestRefund rồi ghi kết quả).

DT8-R6: N/A, Lần gửi đầu (attemptCount = 1) luôn còn lượt vì MaxAttempts = 4, không thể hết lượt ngay sau lần đầu.

#### F2.36.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N293 | bắt đầu | bắt đầu |
| N294 | Giao dịch 1: LockByID RefundRequest (9); IF-23.ExtendClaim(tx, e) | khối lệnh |
| N295 | ExtendClaim ném ClaimLostError? | quyết định |
| N296 | RR REFUNDED hoặc MANUAL_REQUIRED? | quyết định |
| N297 | MarkSucceeded dòng hàng đợi; commit | khối lệnh |
| N298 | RR IN_FLIGHT và không HasAttemptsRemaining? | quyết định |
| N299 | MarkManualRequired; ghi log; MarkSucceeded dòng hàng đợi; commit | khối lệnh |
| N300 | BeginAttempt; Update; commit; ghi mốc đơn điệu cục bộ | khối lệnh |
| N301 | AttemptCount lớn hơn 1? | quyết định |
| N302 | mốc cục bộ còn dưới 10 giây (trước FindRefund)? | quyết định |
| N303 | IF-01.FindRefund | khối lệnh |
| N304 | kết quả = REFUNDED? | quyết định |
| N305 | kết quả = NOT_SUPPORTED hoặc UNREACHABLE? | quyết định |
| N306 | MarkManualRequired trong giao dịch riêng; MarkSucceeded dòng hàng đợi | khối lệnh |
| N307 | mốc cục bộ còn dưới 10 giây (trước RequestRefund)? | quyết định |
| N308 | IF-01.RequestRefund(cùng khoá, hạn = nhỏ hơn của 30 giây và claimedUntil - hiện tại - 10 giây) | khối lệnh |
| N309 | Giao dịch 3: LockByID (9); RecordResult(toAttempt(outcome)); Update | khối lệnh |
| N310 | kết quả = SUCCEEDED? | quyết định |
| N311 | requestType = FULL? | quyết định |
| N312 | Enqueue(EMAIL_REFUND) | khối lệnh |
| N313 | MarkSucceeded dòng hàng đợi | khối lệnh |
| N314 | còn lượt (RR WAITING_RETRY)? | quyết định |
| N315 | Reschedule(1, 5 hoặc 15 phút) | khối lệnh |
| N316 | MarkExhausted; ghi log | khối lệnh |
| N317 | ghi hàng đợi ném ClaimLostError? | quyết định |
| N318 | commit; trả nil | khối lệnh |
| N319 | rollback; trả ClaimLostError; không gọi cổng | khối lệnh |
| N320 | bỏ lượt: không gọi cổng, không ghi | khối lệnh |
| N321 | bỏ lượt: không gọi cổng, không ghi | khối lệnh |
| N322 | rollback; trả ClaimLostError | khối lệnh |
| N323 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE371 | N293 | N294 |  |
| CE372 | N294 | N295 |  |
| CE373 | N295 | N319 | Đúng |
| CE374 | N295 | N296 | Sai |
| CE375 | N296 | N297 | Đúng |
| CE376 | N296 | N298 | Sai |
| CE377 | N298 | N299 | Đúng |
| CE378 | N298 | N300 | Sai |
| CE379 | N300 | N301 |  |
| CE380 | N301 | N302 | Đúng |
| CE381 | N301 | N307 | Sai |
| CE382 | N302 | N320 | Đúng |
| CE383 | N302 | N303 | Sai |
| CE384 | N303 | N304 |  |
| CE385 | N304 | N309 | Đúng |
| CE386 | N304 | N305 | Sai |
| CE387 | N305 | N306 | Đúng |
| CE388 | N305 | N307 | Sai |
| CE389 | N307 | N321 | Đúng |
| CE390 | N307 | N308 | Sai |
| CE391 | N308 | N309 |  |
| CE392 | N309 | N310 |  |
| CE393 | N310 | N311 | Đúng |
| CE394 | N310 | N314 | Sai |
| CE395 | N311 | N312 | Đúng |
| CE396 | N311 | N313 | Sai |
| CE397 | N312 | N313 |  |
| CE398 | N314 | N315 | Đúng |
| CE399 | N314 | N316 | Sai |
| CE400 | N313 | N317 |  |
| CE401 | N315 | N317 |  |
| CE402 | N316 | N317 |  |
| CE403 | N317 | N322 | Đúng |
| CE404 | N317 | N318 | Sai |
| CE405 | N297 | N323 |  |
| CE406 | N299 | N323 |  |
| CE407 | N306 | N323 |  |
| CE408 | N318 | N323 |  |
| CE409 | N319 | N323 |  |
| CE410 | N320 | N323 |  |
| CE411 | N321 | N323 |  |
| CE412 | N322 | N323 |  |

V(G) = số điểm quyết định nhị phân + 1 = 12 + 1 = 13; kiểm bằng E - N + 2 = 42 - 31 + 2 = 13. V(G) lớn hơn 10: đề xuất tách phương thức (xem Đề xuất sửa artifact trước).

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P124 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N307 - N308 - N309 - N310 - N311 - N312 - N313 - N317 - N318 - N323 | TC-323 |
| P125 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N307 - N308 - N309 - N310 - N311 - N313 - N317 - N318 - N323 | TC-324 |
| P126 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N307 - N308 - N309 - N310 - N314 - N315 - N317 - N318 - N323 | TC-325 |
| P127 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N302 - N303 - N304 - N305 - N307 - N308 - N309 - N310 - N314 - N315 - N317 - N318 - N323 | TC-327 |
| P128 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N302 - N303 - N304 - N309 - N310 - N311 - N312 - N313 - N317 - N318 - N323 | TC-329 |
| P129 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N302 - N303 - N304 - N305 - N306 - N323 | TC-330 |
| P130 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N302 - N303 - N304 - N305 - N307 - N308 - N309 - N310 - N314 - N316 - N317 - N318 - N323 | TC-333 |
| P131 | N293 - N294 - N295 - N319 - N323 | TC-334 |
| P132 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N307 - N308 - N309 - N310 - N311 - N313 - N317 - N322 - N323 | TC-335 |
| P133 | N293 - N294 - N295 - N296 - N297 - N323 | TC-336 |
| P134 | N293 - N294 - N295 - N296 - N298 - N299 - N323 | TC-339 |
| P135 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N307 - N321 - N323 | TC-340 |
| P136 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N302 - N320 - N323 | TC-342 |
| P137 | N293 - N294 - N295 - N296 - N298 - N300 - N301 - N302 - N303 - N304 - N305 - N307 - N308 - N309 - N310 - N311 - N312 - N313 - N317 - N318 - N323 | TC-328 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE371 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-330, TC-333, TC-334, TC-335, TC-336, TC-339, TC-340, TC-342 | Có |
| CE372 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-330, TC-333, TC-334, TC-335, TC-336, TC-339, TC-340, TC-342 | Có |
| CE373 | TC-334 | Có |
| CE374 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-330, TC-333, TC-335, TC-336, TC-339, TC-340, TC-342 | Có |
| CE375 | TC-336 | Có |
| CE376 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-330, TC-333, TC-335, TC-339, TC-340, TC-342 | Có |
| CE377 | TC-339 | Có |
| CE378 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-330, TC-333, TC-335, TC-340, TC-342 | Có |
| CE379 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-330, TC-333, TC-335, TC-340, TC-342 | Có |
| CE380 | TC-327, TC-328, TC-329, TC-330, TC-333, TC-342 | Có |
| CE381 | TC-323, TC-324, TC-325, TC-335, TC-340 | Có |
| CE382 | TC-342 | Có |
| CE383 | TC-327, TC-328, TC-329, TC-330, TC-333 | Có |
| CE384 | TC-327, TC-328, TC-329, TC-330, TC-333 | Có |
| CE385 | TC-329 | Có |
| CE386 | TC-327, TC-328, TC-330, TC-333 | Có |
| CE387 | TC-330 | Có |
| CE388 | TC-327, TC-328, TC-333 | Có |
| CE389 | TC-340 | Có |
| CE390 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-333, TC-335 | Có |
| CE391 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-333, TC-335 | Có |
| CE392 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-333, TC-335 | Có |
| CE393 | TC-323, TC-324, TC-328, TC-329, TC-335 | Có |
| CE394 | TC-325, TC-327, TC-333 | Có |
| CE395 | TC-323, TC-328, TC-329 | Có |
| CE396 | TC-324, TC-335 | Có |
| CE397 | TC-323, TC-328, TC-329 | Có |
| CE398 | TC-325, TC-327 | Có |
| CE399 | TC-333 | Có |
| CE400 | TC-323, TC-324, TC-328, TC-329, TC-335 | Có |
| CE401 | TC-325, TC-327 | Có |
| CE402 | TC-333 | Có |
| CE403 | TC-335 | Có |
| CE404 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-333 | Có |
| CE405 | TC-336 | Có |
| CE406 | TC-339 | Có |
| CE407 | TC-330 | Có |
| CE408 | TC-323, TC-324, TC-325, TC-327, TC-328, TC-329, TC-333 | Có |
| CE409 | TC-334 | Có |
| CE410 | TC-342 | Có |
| CE411 | TC-340 | Có |
| CE412 | TC-335 | Có |

Độ phủ đạt được: C0 = 29/29 lệnh và điểm quyết định (100%); C1 = 42/42 nhánh (100%).

V(G) lớn hơn 10: đề xuất tách ProcessRefund theo ba giao dịch (beginAttemptTx, callGateway, recordResultTx) thành ba hàm private, ProcessRefund chỉ điều phối; ghi ở Đề xuất sửa artifact trước.

#### F2.36.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> commit (giữ thay đổi), trả lỗi --> khôi phục bản sao (rollback); ghi lại TxOptions và số commit; cấu hình được để trả SystemBusyError. Tx giả mang LockOrderGuard thật; store giả gọi Acquire theo hạng cố định của từng operation (P12 F2) và test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật và chờ khoá là ca tích hợp |
| IF-25.Now (tx.Now) | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào (Bước 5) |
| IF-23 | fake | ExtendClaim (trả claimedUntil = tx.Now + 120 giây hoặc ClaimLostError theo cấu hình), MarkSucceeded, Reschedule, MarkExhausted, Enqueue; ghi lại thứ tự và tham số; lỗi ClaimLostError cấu hình được theo từng thao tác | Hàng đợi (PostgreSQL) thay bằng bộ nhớ; hàng rào thật ở ca tích hợp |
| IF-21, IF-19 | fake | LockByID RefundRequest; Update; FindByID PaymentTransaction trả paidAt 10:04:00 và mã 20260001 | Store thay bằng bộ nhớ |
| IF-01 | mock | FindRefund và RequestRefund trả kết quả theo kịch bản; khẳng định thứ tự (FindRefund trước RequestRefund), refundKey, ctx deadline của từng lời gọi | Hệ thống ngoài (VNPay): mock để kiểm tương tác và tham số (Bước 5) |
| Đồng hồ đơn điệu cục bộ | stub | Trả thời điểm cục bộ; test đặt phần claim còn lại sau giao dịch 1 | Thời gian tiêm vào |
| log | spy | Đếm dòng log lỗi khoản hoàn (mã yêu cầu hoàn, mã giao dịch, số tiền) | ST-04 F6.4 |

### F2.37 DC-CancelTicketService.FindBooking

#### F2.37.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | FindBooking(ctx, bookingCode string, actor ActorContext) (BookingView, error) | P12 F2 |
| Hậu điều kiện | Tìm lần đặt theo mã, dựng các vé kèm số tiền hoàn nếu huỷ; kiểm kênh và cụm rạp; không đổi dữ liệu | P12 F2 |
| Luồng P04 | UC-008 1a1a (mã không tồn tại), 2b (nhân viên, vé trực tuyến), 2c (nhân viên, vé quầy của cụm rạp khác) | P04 UC-008 |
| Không áp dụng | Không áp dụng: F2.37.3 đến F2.37.6 (không có F3 riêng; mục tiêu ghi 'Đo khi có mã nguồn' ở F4) | - |

#### F2.37.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-172 | bookingCode | tương ứng một lần đặt mua tại quầy của cụm rạp của nhân viên | Hợp lệ | BK1 | UC-008 1a |
| EC-173 | bookingCode | không tương ứng lần đặt nào | Không hợp lệ | BK-LẠ | UC-008 1a1a |
| EC-174 | lần đặt | mua tại quầy của cụm rạp khác cụm rạp của nhân viên | Không hợp lệ | BK2 của cụm rạp 3 | BR-17; UC-008 2c |
| EC-175 | lần đặt | mua trực tuyến | Không hợp lệ | BK3 | BR-17; UC-008 2b |

#### F2.37.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-20 | fake | FindByCode trả Booking và vé (giá, trạng thái, người giữ, cụm rạp) hoặc NotFoundError | Store thay bằng bộ nhớ |

### F2.38 DC-CheckTicketService.StartChecking

#### F2.38.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | StartChecking(ctx, showtimeId, checker ActorContext) (ShowtimeInfo, error) | P12 F2 |
| Hậu điều kiện | Kiểm suất chiếu thuộc cụm rạp của nhân viên soát vé rồi trả thông tin suất chiếu; không đổi dữ liệu | P12 F2; BR-34 |
| Không áp dụng | Không áp dụng: F2.38.3 đến F2.38.6 (một điều kiện; không có F3 riêng) | - |

#### F2.38.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-176 | suất chiếu | thuộc cụm rạp của nhân viên soát vé | Hợp lệ | suất 55 cụm rạp 2 | BR-34 |
| EC-177 | suất chiếu | thuộc cụm rạp khác | Không hợp lệ | suất 77 cụm rạp 3 | BR-34 |
| EC-178 | showtimeId | không tồn tại | Không hợp lệ | 9999 | P12 F2 |

#### F2.38.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-11 | fake | FindInfo và FindByID trả suất chiếu theo mã | Store thay bằng bộ nhớ |

### F2.39 IF-07.VerifyPassword, IssueSession, VerifySession

#### F2.39.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | VerifyPassword(plain, storedHash) (bool, error); IssueSession(subjectId, role, cinemaId) (IssuedSession, error); VerifySession(token) (SessionClaims, error) | P12 F2 PKG-26 |
| Hậu điều kiện | VerifyPassword so mã băm một chiều, so sánh thời gian hằng, MalformedHashError khi hash hỏng. IssueSession: khách 24 giờ, nhân viên 8 giờ, không tự gia hạn (Q-129). VerifySession kiểm chữ ký và hạn, trả claims; không đọc CSDL | P12 F2; P11b Q-129 |
| Chưa nêu | Hạn phiên của quản trị viên; biên đúng tại expiresAt và nguồn đồng hồ của bộ xác thực | Q-153, Q-154 |
| Giới hạn | Phần bên trong SS-05 chưa thiết kế (ngoài phạm vi); TC kiểm theo hợp đồng của interface, hiện thực chưa có nên dùng driver gọi interface | P12 mục 0.1 |
| Không áp dụng | Không áp dụng: F2.39.4 (điều kiện độc lập), F2.39.5, F2.39.6 (không có F3: Đo khi có mã nguồn) | - |

#### F2.39.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-179 | role | CUSTOMER | Hợp lệ | CUSTOMER | Q-129 |
| EC-180 | role | nhân viên (BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER) | Hợp lệ | BOX_OFFICE_CLERK | Q-129; NFR-02 |
| EC-181 | role | ADMINISTRATOR | Hợp lệ | ADMINISTRATOR | NFR-03 (hạn: Q-153) |
| EC-182 | token | đúng chữ ký, chưa hết hạn | Hợp lệ | token do IssueSession cấp | P12 F2 |
| EC-183 | token | sai chữ ký (bị sửa) | Không hợp lệ | đổi một ký tự | P12 F2 SessionInvalidError |
| EC-184 | token | đã hết hạn | Không hợp lệ | now = expiresAt + 1 giây | P12 F2 SessionExpiredError |
| EC-185 | storedHash | định dạng hỏng | Không hợp lệ | chuỗi rỗng | P12 F2 MalformedHashError |

#### F2.39.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Đồng hồ của bộ xác thực | stub | Trả now cố định (thời gian tiêm vào) | Bước 5: thời gian phải tiêm vào |
| IF-07 | driver | Test gọi trực tiếp interface IF-07 vì hiện thực SS-05 chưa có | Driver theo Bước 5 |

### F2.40 Ca tích hợp (PostgreSQL 15 thật, nhiều goroutine hoặc nhiều bản backend)

#### F2.40.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Phân loại | Các ca dưới đây không là unit test: kết cục phụ thuộc khoá dòng thật của PostgreSQL (FOR NO KEY UPDATE, NOWAIT, SKIP LOCKED, lock_timeout), thứ tự đến thật của hai giao dịch, trigger và ràng buộc của P13, hoặc tiến trình chết giữa hai giao dịch. Unit test với IF-08 giả chỉ chạy tuần tự nên chứng minh logic quyết định sau khi có khoá, không chứng minh loại trừ | P12 F2 IF-08; P09 F7.3; Prompt mục 5 (kiểm thử tích hợp ngoài bước này) |
| Hạ tầng đề xuất | PostgreSQL 15 trở lên (Docker Compose), 2 bản backend dùng chung 1 cơ sở dữ liệu, cổng thanh toán giả lập qua IF-01 (HTTP giả, chậm cấu hình được), barrier để hai goroutine cùng vào, hook (pg_sleep hoặc giữ giao dịch của harness) để ép từng thứ tự đến, k6 cho ca tải; schema theo P13-schema.sql | P09 F7.9; P13-schema.sql |
| Quan hệ với M9 | Mỗi X-nn trong phạm vi có ca ép cả hai thứ tự đến khi hai thứ tự cho kết cục khác nhau; mỗi dòng Bảng hỏng (M5) có ca hồi phục: ánh xạ ở F4.2 và F4.3 | 00-Concurrency.md M9; User yêu cầu chạy |
| Không áp dụng | Không áp dụng: F2.40.2 đến F2.40.7 (ca tích hợp không phân tích hộp đen/hộp trắng mức đơn vị; test double: không dùng, ngoại trừ cổng thanh toán giả lập) | - |

#### F2.40.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-01 (cổng thanh toán) | fake | Dịch vụ HTTP giả: tạo độ trễ cấu hình được, đếm số lời gọi RequestRefund theo refundKey, trả SUCCEEDED, REJECTED hoặc không trả lời | Hệ thống ngoài VNPay sandbox không dùng cho kiểm thử lặp |

## F3. Bảng test case

| TC | DC.operation | Kỹ thuật (phân vùng tương đương / giá trị biên / bảng quyết định / chuyển trạng thái / use case / đường đi) | Điều kiện đầu | Dữ liệu vào | Kết quả mong đợi | Nguồn (BR / UC bước) | Phủ (EC, BV, DT-R, chuyển trạng thái, nhánh CE) | Test double | Ưu tiên | Mức |
|---|---|---|---|---|---|---|---|---|---|---|
| TC-001 | DC-SeatHold.NewSeatHold | phân vùng tương đương | Không có | holder = CUSTOMER 7; showtimeId = 55; requestId = r-1; holdRef = ref-1; now = 10:00:00.000 | Status = ACTIVE; ExpiryTime = 10:10:00.000; Holder = CUSTOMER 7; ShowtimeId = 55; Ref = ref-1 | BR-10; UC-005 bước 7; ST-01 STT 1 | EC-01, CT-01 | Không (đối tượng thuần) | Cao | Unit |
| TC-002 | DC-SeatHold.NewSeatHold | phân vùng tương đương | Không có | holder = CLERK 3; now = 10:00:00.000; các tham số khác như TC trước | Status = ACTIVE; ExpiryTime = 10:10:00.000; Holder = CLERK 3 | BR-10 (áp dụng cả bán tại quầy); R-49 | EC-02 | Không (đối tượng thuần) | Cao | Unit |
| TC-003 | DC-SeatHold.NewSeatHold | giá trị biên | Không có | holder = CUSTOMER 7; now = 2026-11-10 23:55:00 | ExpiryTime = 2026-11-11 00:05:00; Status = ACTIVE | BR-10 | BV-01 | Không (đối tượng thuần) | Cao | Unit |
| TC-004 | DC-SeatHold.NewSeatHold | phân vùng tương đương | Không có | requestId = rỗng (hoặc holdRef rỗng) | Chưa xác định: chờ Q-144 | P12 F2 (không nêu hành vi) | EC-03; không tính vào độ phủ (chờ Q-144) | Không (đối tượng thuần) | Thấp | Unit |
| TC-005 | DC-SeatHold.Expire | giá trị biên | SeatHold ACTIVE, expiryTime = E | Expire(now = E - 1ms) | Trả false; Status = ACTIVE | BR-10; ST-01 STT 3 | EC-04, BV-02, CT-03, đường P2, CE1 đến CE2, CE5, CE7 | Không (đối tượng thuần) | Cao | Unit |
| TC-006 | DC-SeatHold.Expire | giá trị biên | SeatHold ACTIVE, expiryTime = E | Expire(now = E) | Trả true; Status = EXPIRED | BR-10; BR-14; ST-01 STT 3; UC-005 7b | EC-05, BV-03, CT-02, đường P1, CE1 đến CE2, CE4, CE6 | Không (đối tượng thuần) | Cao | Unit |
| TC-007 | DC-SeatHold.Expire | giá trị biên | SeatHold ACTIVE, expiryTime = E | Expire(now = E + 1ms) | Trả true; Status = EXPIRED | BR-10; ST-01 STT 3 | BV-04 | Không (đối tượng thuần) | Cao | Unit |
| TC-008 | DC-SeatHold.Expire | chuyển trạng thái | SeatHold COMPLETED (tạo bằng NewSeatHold, Complete(E - 1ms)) | Expire(now = E + 5 phút) | Trả false; Status = COMPLETED | BR-86; ST-01 (bị bỏ qua) | EC-06, CT-04, đường P3, CE1, CE3, CE7 | Không (đối tượng thuần) | Cao | Unit |
| TC-009 | DC-SeatHold.Expire | chuyển trạng thái | SeatHold EXPIRED (sau Expire(E)) | Expire(now = E + 5 phút) lần hai | Trả false; Status = EXPIRED (chạy lặp an toàn) | BR-86; P12 F2 (chạy lặp an toàn) | EC-06, CT-04 | Không (đối tượng thuần) | Cao | Unit |
| TC-010 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold ACTIVE, expiryTime = E | Complete(now = E - 1ms) | Trả nil; Status = COMPLETED | BR-37, BR-44; ST-01 STT 2; UC-005 12 | EC-07, BV-05, CT-05, đường P4, CE8 đến CE9, CE11, CE13 | Không (đối tượng thuần) | Cao | Unit |
| TC-011 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold ACTIVE, expiryTime = E | Cancel(now = E - 1ms) | Trả nil; Status = CANCELLED | BR-85; ST-01 STT 4; UC-005 *a | CT-06, đường P4, CE8 đến CE9, CE11, CE13 | Không (đối tượng thuần) | Cao | Unit |
| TC-012 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold ACTIVE, expiryTime = E | FailPayment(now = E - 1ms) | Trả nil; Status = PAYMENT_FAILED | BR-39, BR-85; ST-01 STT 5; UC-005 11a | CT-07, đường P4, CE8 đến CE9, CE11, CE13 | Không (đối tượng thuần) | Cao | Unit |
| TC-013 | DC-SeatHold.Complete, Cancel, FailPayment | giá trị biên | SeatHold ACTIVE, expiryTime = E (chưa gọi Expire) | Complete(now = E) | Chưa xác định: chờ Q-142 | P12 F3 và F6.2; BR-86 | EC-08, BV-06, CT-08, đường P5, CE8 đến CE9, CE12, CE14; không tính vào độ phủ (chờ Q-142) | Không (đối tượng thuần) | Cao | Unit |
| TC-014 | DC-SeatHold.Complete, Cancel, FailPayment | giá trị biên | SeatHold ACTIVE, expiryTime = E (chưa gọi Expire) | Cancel(now = E) | Chưa xác định: chờ Q-142 | P12 F3 và F6.2; BR-86 | CT-09; không tính vào độ phủ (chờ Q-142) | Không (đối tượng thuần) | Cao | Unit |
| TC-015 | DC-SeatHold.Complete, Cancel, FailPayment | giá trị biên | SeatHold ACTIVE, expiryTime = E (chưa gọi Expire) | FailPayment(now = E + 1ms) | Chưa xác định: chờ Q-142 | P12 F3 và F6.2; BR-86 | BV-07, CT-10; không tính vào độ phủ (chờ Q-142) | Không (đối tượng thuần) | Cao | Unit |
| TC-016 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold COMPLETED (tạo bằng NewSeatHold rồi Complete(E - 1ms)) | Complete(now = E - 1ms) | Ném HoldNotActiveError mang Status = COMPLETED; Status vẫn COMPLETED | BR-86; ST-01 (bị từ chối) | EC-09, CT-11, đường P6, CE8, CE10, CE14 | Không (đối tượng thuần) | Cao | Unit |
| TC-017 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold EXPIRED (tạo bằng NewSeatHold rồi Expire(E)) | Complete(now = E - 1ms) | Ném HoldNotActiveError mang Status = EXPIRED; Status vẫn EXPIRED | BR-86; ST-01 (bị từ chối) | EC-09, CT-11 | Không (đối tượng thuần) | Cao | Unit |
| TC-018 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold CANCELLED (tạo bằng NewSeatHold rồi Cancel(E - 1ms)) | Complete(now = E - 1ms) | Ném HoldNotActiveError mang Status = CANCELLED; Status vẫn CANCELLED | BR-86; ST-01 (bị từ chối) | EC-09, CT-11 | Không (đối tượng thuần) | Cao | Unit |
| TC-019 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold PAYMENT_FAILED (tạo bằng NewSeatHold rồi FailPayment(E - 1ms)) | Complete(now = E - 1ms) | Ném HoldNotActiveError mang Status = PAYMENT_FAILED; Status vẫn PAYMENT_FAILED | BR-86; ST-01 (bị từ chối) | EC-09, CT-11 | Không (đối tượng thuần) | Cao | Unit |
| TC-020 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold EXPIRED (Expire(E)) | Cancel(now = E + 1 phút) | Ném HoldNotActiveError mang Status = EXPIRED; Status vẫn EXPIRED | BR-86; UC-005 7b, *a; X-10 | CT-12 | Không (đối tượng thuần) | Cao | Unit |
| TC-021 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold COMPLETED | FailPayment(now = E - 1ms) | Ném HoldNotActiveError mang Status = COMPLETED; Status vẫn COMPLETED | BR-39, BR-86 | CT-13 | Không (đối tượng thuần) | Cao | Unit |
| TC-022 | DC-SeatHold.IsActiveAt | giá trị biên | SeatHold ACTIVE, expiryTime = E | IsActiveAt(E - 1ms) | Trả true | BR-53, BR-85 | EC-10, BV-08 | Không (đối tượng thuần) | Cao | Unit |
| TC-023 | DC-SeatHold.IsActiveAt | giá trị biên | SeatHold ACTIVE, expiryTime = E | IsActiveAt(E) | Trả false | BR-53 (ghế quá hạn không còn là ghế được giữ) | EC-11, BV-09 | Không (đối tượng thuần) | Cao | Unit |
| TC-024 | DC-SeatHold.IsActiveAt | phân vùng tương đương | SeatHold CANCELLED (Cancel(E - 1ms)) | IsActiveAt(E - 1ms) | Trả false | BR-04, BR-86 | EC-12 | Không (đối tượng thuần) | Cao | Unit |
| TC-025 | DC-SeatHold.CalculateTotal | phân vùng tương đương | Hold H1 ACTIVE; 3 ghế HELD bởi H1, giá 90.000, 90.000, 120.000 | CalculateTotal(3 ghế) | Trả Money 300.000 | BR-65; UC-005 8 | EC-13 | Không (đối tượng thuần) | Cao | Unit |
| TC-026 | DC-SeatHold.CalculateTotal | giá trị biên | Hold H1; 1 ghế HELD bởi H1, giá 90.000 | CalculateTotal([ghế]) | Trả 90.000 | BR-65; BR-05 (tối thiểu 1 ghế) | BV-10 | Không (đối tượng thuần) | Cao | Unit |
| TC-027 | DC-SeatHold.CalculateTotal | giá trị biên | Hold H1; 8 ghế HELD bởi H1, mỗi ghế 90.000 | CalculateTotal(8 ghế) | Trả 720.000 | BR-65; BR-05 (tối đa 8 ghế) | BV-11 | Không (đối tượng thuần) | Cao | Unit |
| TC-028 | DC-SeatHold.CalculateTotal | phân vùng tương đương | Hold H1; ghế a HELD bởi H1 (90.000), ghế b HELD bởi H2 (120.000) | CalculateTotal([a, b]) | Chưa xác định: chờ Q-143 | P12 F2 (không nêu) | EC-14; không tính vào độ phủ (chờ Q-143) | Không (đối tượng thuần) | Trung bình | Unit |
| TC-029 | DC-SeatHold.CalculateTotal | phân vùng tương đương | Hold H1 | CalculateTotal([]) | Chưa xác định: chờ Q-143 | P12 F2 (không nêu) | EC-15; không tính vào độ phủ (chờ Q-143) | Không (đối tượng thuần) | Trung bình | Unit |
| TC-030 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus AVAILABLE (NewAvailable) | HoldFor(H1, 90.000) | Trả nil; State = HELD; CurrentHold = (H1, true); CurrentTicket = (-, false); HeldPrice = 90.000 | BR-07, BR-08, BR-65; ST-02 STT 2 | EC-16, CT-14, đường P7, CE15 đến CE16, CE18 | Không (đối tượng thuần) | Cao | Unit |
| TC-031 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus HELD bởi H2 | HoldFor(H1, 90.000) | Ném SeatUnavailableError(NOT_AVAILABLE); State = HELD; CurrentHold = (H2, true) | BR-08, BR-09; X-01 | EC-17, CT-15, đường P8, CE15, CE17, CE19 | Không (đối tượng thuần) | Cao | Unit |
| TC-032 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus SOLD (HoldFor H2, MarkSold(H2, TK9)) | HoldFor(H1, 90.000) | Ném SeatUnavailableError(NOT_AVAILABLE); State = SOLD; CurrentTicket = (TK9, true) | BR-09; ST-02 | EC-17, CT-15, đường P8, CE15, CE17, CE19 | Không (đối tượng thuần) | Cao | Unit |
| TC-033 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus HELD bởi H1, heldPrice 90.000 | MarkSold(H1, TK1) | Trả nil; State = SOLD; CurrentHold = (-, false); CurrentTicket = (TK1, true) | BR-85; ST-02 STT 3; UC-005 12 | EC-18, CT-16, đường P9, CE20 đến CE21, CE23, CE25 | Không (đối tượng thuần) | Cao | Unit |
| TC-034 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus HELD bởi H2 | MarkSold(H1, TK1) | Ném LinkMismatchError; State = HELD; CurrentHold = (H2, true); CurrentTicket = (-, false) | BR-85; X-12 | EC-19, CT-17, đường P10, CE20 đến CE21, CE24, CE26 | Không (đối tượng thuần) | Cao | Unit |
| TC-035 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus AVAILABLE | MarkSold(H1, TK1) | Ném LinkMismatchError; State = AVAILABLE | ST-02 (bị từ chối) | EC-20, CT-18, đường P11, CE20, CE22, CE26 | Không (đối tượng thuần) | Cao | Unit |
| TC-036 | DC-SeatStatus.HoldFor, MarkSold | chuyển trạng thái | SeatStatus SOLD bởi TK9 | MarkSold(H1, TK1) | Ném LinkMismatchError; State = SOLD; CurrentTicket = (TK9, true) | BR-09; ST-02 (bị từ chối) | EC-20, CT-18, đường P11, CE20, CE22, CE26 | Không (đối tượng thuần) | Cao | Unit |
| TC-037 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus HELD bởi H1 (heldPrice 90.000) | ReleaseHold(H1) | Trả true; State = AVAILABLE; CurrentHold = (-, false); HeldPrice = 0 | REQ-76; ST-02 STT 4; UC-005 7b, *a, 11a | EC-21, CT-19, đường P12, CE27 đến CE28, CE30, CE32 | Không (đối tượng thuần) | Cao | Unit |
| TC-038 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus HELD bởi H2 (ghế đã giữ lại cho lần giữ ghế khác) | ReleaseHold(H1) | Trả false; State = HELD; CurrentHold = (H2, true) | R-63; X-18; X-13 | EC-22, CT-20, đường P13, CE27 đến CE28, CE31, CE33 | Không (đối tượng thuần) | Cao | Unit |
| TC-039 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus AVAILABLE | ReleaseHold(H1) | Trả false; State = AVAILABLE | ST-02 (chạy lặp an toàn) | EC-23, CT-21, đường P14, CE27, CE29, CE33 | Không (đối tượng thuần) | Cao | Unit |
| TC-040 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus SOLD bởi TK1 | ReleaseHold(H1) | Trả false; State = SOLD; CurrentTicket = (TK1, true) | BR-85; X-12 (không thể vừa bán vừa giải phóng) | EC-23, CT-21, đường P14, CE27, CE29, CE33 | Không (đối tượng thuần) | Cao | Unit |
| TC-041 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus HELD bởi H1; đã gọi ReleaseHold(H1) một lần | ReleaseHold(H1) lần hai | Trả false; State = AVAILABLE (chạy lặp, không đổi) | X-18; P12 F2 (chạy lặp an toàn) | EC-23, CT-21, đường P14, CE27, CE29, CE33 | Không (đối tượng thuần) | Cao | Unit |
| TC-042 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus SOLD bởi TK1 | ReleaseTicket(TK1) | Trả true; State = AVAILABLE; CurrentTicket = (-, false) | BR-42; ST-02 STT 5; UC-008 7 | EC-24, CT-22, đường P15, CE34 đến CE35, CE37, CE39 | Không (đối tượng thuần) | Cao | Unit |
| TC-043 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus SOLD bởi TK9 (ghế đã bán lại bằng vé khác) | ReleaseTicket(TK1) | Trả false; State = SOLD; CurrentTicket = (TK9, true) | R-64; X-18; UC-008 7 | EC-25, CT-23, đường P16, CE34 đến CE35, CE38, CE40 | Không (đối tượng thuần) | Cao | Unit |
| TC-044 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus AVAILABLE | ReleaseTicket(TK1) | Trả false; State = AVAILABLE | ST-02 (bị bỏ qua) | EC-26, CT-24, đường P17, CE34, CE36, CE40 | Không (đối tượng thuần) | Cao | Unit |
| TC-045 | DC-SeatStatus.ReleaseHold, ReleaseTicket | chuyển trạng thái | SeatStatus HELD bởi H1 | ReleaseTicket(TK1) | Trả false; State = HELD; CurrentHold = (H1, true) | ST-02 (bị bỏ qua) | EC-26, CT-24, đường P17, CE34, CE36, CE40 | Không (đối tượng thuần) | Cao | Unit |
| TC-046 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction PENDING (NewPending(hold, "20260001", 100.000)) | MarkTicketed("GW1", 10:05:00) | Trả nil; Status = TICKETED; PaidAt = 10:05:00; IsProcessed = true; mã cổng = GW1 | BR-37; UC-005 12 | CT-25, đường P18, CE41 đến CE42, CE44 | Không (đối tượng thuần) | Cao | Unit |
| TC-047 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction PENDING (NewPending(hold, "20260001", 100.000)) | MarkLatePayment("GW1", 10:11:00, "EXPIRED") | Trả nil; Status = LATE_PAYMENT; IsProcessed = true; lateReason = EXPIRED; mã cổng = GW1 | BR-14; UC-006 2 | CT-26, đường P20, CE46 đến CE47, CE51 | Không (đối tượng thuần) | Cao | Unit |
| TC-048 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction PENDING (NewPending(hold, "20260001", 100.000)) | RecordFailure() | Trả true; Status = FAILED; IsProcessed = false; mã cổng vẫn rỗng | BR-39; UC-005 11a | CT-27, đường P23, CE53 đến CE54, CE56 | Không (đối tượng thuần) | Cao | Unit |
| TC-049 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction PENDING (NewPending(hold, "20260001", 100.000)) | RecordDuplicate() | Ném PaymentStateError; Status = PENDING; duplicateReportCount = 0 | BR-37; P12 F6.2 | CT-28, đường P27, CE58, CE60, CE62, CE64 | Không (đối tượng thuần) | Cao | Unit |
| TC-050 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction FAILED (PENDING sau RecordFailure) | MarkTicketed("GW1", 10:05:00) | Ném PaymentStateError; Status = FAILED | ST-05; P12 F2 (tiền PENDING) | CT-29, đường P19, CE41, CE43, CE45 | Không (đối tượng thuần) | Cao | Unit |
| TC-051 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction FAILED (PENDING sau RecordFailure) | MarkLatePayment("GW1", 10:06:00, "PAYMENT_FAILED") | Trả nil; Status = LATE_PAYMENT; lateReason = PAYMENT_FAILED | BR-15; ST-05 STT 5 | CT-30, đường P21, CE46, CE48 đến CE49, CE51 | Không (đối tượng thuần) | Cao | Unit |
| TC-052 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction FAILED (PENDING sau RecordFailure) | RecordFailure() | Trả false; Status = FAILED | BR-39 (thất bại báo hai lần chỉ ghi nhận) | CT-31, đường P24, CE53, CE55, CE57 | Không (đối tượng thuần) | Cao | Unit |
| TC-053 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction FAILED (PENDING sau RecordFailure) | RecordDuplicate() | Ném PaymentStateError; Status = FAILED | P12 F6.2 | CT-32, đường P27, CE58, CE60, CE62, CE64 | Không (đối tượng thuần) | Cao | Unit |
| TC-054 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction TICKETED (PENDING sau MarkTicketed("GW1", 10:05:00)) | MarkTicketed("GW2", 10:07:00) | Ném PaymentStateError; Status = TICKETED; mã cổng vẫn GW1; PaidAt vẫn 10:05:00 | BR-37; P12 F6.2 | CT-33, đường P19, CE41, CE43, CE45 | Không (đối tượng thuần) | Cao | Unit |
| TC-055 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction TICKETED (PENDING sau MarkTicketed("GW1", 10:05:00)) | MarkLatePayment("GW2", 10:07:00, "X") | Ném PaymentStateError; Status = TICKETED | BR-37; P12 F6.2 | CT-34, đường P22, CE46, CE48, CE50, CE52 | Không (đối tượng thuần) | Cao | Unit |
| TC-056 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction TICKETED (PENDING sau MarkTicketed("GW1", 10:05:00)) | RecordFailure() | Trả false; Status = TICKETED (không hoàn tiền) | BR-39; UC-006 2d | CT-35, đường P24, CE53, CE55, CE57 | Không (đối tượng thuần) | Cao | Unit |
| TC-057 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction TICKETED (PENDING sau MarkTicketed("GW1", 10:05:00)) | RecordDuplicate() | Trả nil; Status = TICKETED; duplicateReportCount = 1 | BR-37; UC-006 2a; ST-05 STT 6 | CT-36, đường P25, CE58 đến CE59, CE63 | Không (đối tượng thuần) | Cao | Unit |
| TC-058 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction LATE_PAYMENT (PENDING sau MarkLatePayment("GW1", 10:11:00, "EXPIRED")) | MarkTicketed("GW2", 10:12:00) | Ném PaymentStateError; Status = LATE_PAYMENT | P12 F6.2 | CT-37, đường P19, CE41, CE43, CE45 | Không (đối tượng thuần) | Cao | Unit |
| TC-059 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction LATE_PAYMENT (PENDING sau MarkLatePayment("GW1", 10:11:00, "EXPIRED")) | MarkLatePayment("GW2", 10:12:00, "X") | Ném PaymentStateError; Status = LATE_PAYMENT; lateReason vẫn EXPIRED | BR-16 (gộp BR-37: hoàn một lần); P12 F3 | CT-38, đường P22, CE46, CE48, CE50, CE52 | Không (đối tượng thuần) | Cao | Unit |
| TC-060 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction LATE_PAYMENT (PENDING sau MarkLatePayment("GW1", 10:11:00, "EXPIRED")) | RecordFailure() | Trả false; Status = LATE_PAYMENT | BR-39 | CT-39, đường P24, CE53, CE55, CE57 | Không (đối tượng thuần) | Cao | Unit |
| TC-061 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction LATE_PAYMENT (PENDING sau MarkLatePayment("GW1", 10:11:00, "EXPIRED")) | RecordDuplicate() | Trả nil; Status = LATE_PAYMENT; duplicateReportCount = 1 | BR-37; UC-006 2a; ST-05 STT 7 | CT-40, đường P26, CE58, CE60 đến CE61, CE63 | Không (đối tượng thuần) | Cao | Unit |
| TC-062 | DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | chuyển trạng thái | PaymentTransaction TICKETED, đã RecordDuplicate một lần | RecordDuplicate() lần hai | Trả nil; duplicateReportCount = 2; Status = TICKETED | BR-37 (báo trùng nhiều lần, không tạo thêm vé) | CT-36, đường P25, CE58 đến CE59, CE63 | Không (đối tượng thuần) | Cao | Unit |
| TC-063 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | giá trị biên | PaymentTransaction TICKETED, amount 100.000, refundedTotal 0 | CheckRefundWithin(100.000) | Trả nil | BR-26; UC-006 6 | EC-27, BV-12 | Không (đối tượng thuần) | Cao | Unit |
| TC-064 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | giá trị biên | PaymentTransaction TICKETED, amount 100.000, refundedTotal 0 | CheckRefundWithin(100.001) | Ném RefundLimitError | BR-26 | EC-28, BV-13 | Không (đối tượng thuần) | Cao | Unit |
| TC-065 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | giá trị biên | PaymentTransaction TICKETED, amount 100.000, refundedTotal 70.000 (sau RecordRefunded(70.000)) | CheckRefundWithin(30.000) | Trả nil | BR-26; UC-008 5 | BV-14 | Không (đối tượng thuần) | Cao | Unit |
| TC-066 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | giá trị biên | PaymentTransaction TICKETED, amount 100.000, refundedTotal 70.000 | CheckRefundWithin(30.001) | Ném RefundLimitError | BR-26; X-16 | BV-15 | Không (đối tượng thuần) | Cao | Unit |
| TC-067 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | phân vùng tương đương | PaymentTransaction TICKETED, amount 100.000, refundedTotal 0 | RecordRefunded(63.000) rồi CheckRefundWithin(37.000) | RecordRefunded trả nil, refundedTotal = 63.000; CheckRefundWithin trả nil | BR-26 | EC-27 | Không (đối tượng thuần) | Cao | Unit |
| TC-068 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | phân vùng tương đương | PaymentTransaction TICKETED, amount 100.000, refundedTotal 70.000 | RecordRefunded(63.000) | Ném RefundLimitError; refundedTotal vẫn 70.000 | BR-26 | EC-28 | Không (đối tượng thuần) | Cao | Unit |
| TC-069 | DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | phân vùng tương đương | PaymentTransaction TICKETED, amount 100.000 | CheckRefundWithin(0) | Chưa xác định: chờ Q-144 | P12 F2 (không nêu) | EC-29; không tính vào độ phủ (chờ Q-144) | Không (đối tượng thuần) | Thấp | Unit |
| TC-070 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn code 20260001 | NewFullRefund(txn, 100.000) | IdempotencyKey = "20260001-FULL"; Status = NEW; AttemptCount = 0; Amount = 100.000 | BR-43; BR-14; ST-04 STT 3 | EC-30, CT-41 | Không (đối tượng thuần) | Cao | Unit |
| TC-071 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn code 20260001; vé 9 | NewTicketRefund(txn, vé 9, 63.000) | IdempotencyKey = "20260001-T9"; Status = NEW; AttemptCount = 0; Amount = 63.000 | BR-43; BR-19; ST-04 STT 3 | EC-31 | Không (đối tượng thuần) | Cao | Unit |
| TC-072 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn code 20260001; vé 9 và vé 10 | NewTicketRefund(txn, vé 10, 63.000) so với kết quả TC trước | IdempotencyKey = "20260001-T10", khác "20260001-T9" và khác "20260001-FULL" | BR-43 (phân biệt khoá trên cùng giao dịch); X-17 | EC-31 | Không (đối tượng thuần) | Cao | Unit |
| TC-073 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | vé 9 mua tại quầy | NewCashRefund(vé 9, 63.000) | Status = REFUNDED; AttemptCount = 0; Amount = 63.000 | BR-20; ST-04 STT 2; UC-008 5a2 | EC-32, CT-42 | Không (đối tượng thuần) | Cao | Unit |
| TC-074 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn nil hoặc amount = 0 | NewFullRefund(txn, 0) | Chưa xác định: chờ Q-144 | P12 F2 (không nêu) | EC-33; không tính vào độ phủ (chờ Q-144) | Không (đối tượng thuần) | Thấp | Unit |
| TC-075 | DC-RefundRequest.BeginAttempt | chuyển trạng thái | RefundRequest NEW (NewFullRefund), attemptCount 0 | BeginAttempt() | Trả nil; Status = IN_FLIGHT; AttemptCount = 1 | BR-43; ST-04 STT 4; UC-006 4 | EC-34, CT-43, đường P28, CE65 đến CE66, CE68, CE70 | Không (đối tượng thuần) | Cao | Unit |
| TC-076 | DC-RefundRequest.BeginAttempt | chuyển trạng thái | RefundRequest WAITING_RETRY, attemptCount 2 (BeginAttempt, RecordResult(REJECTED), BeginAttempt, RecordResult(UNKNOWN)) | BeginAttempt() | Trả nil; Status = IN_FLIGHT; AttemptCount = 3 | BR-41; ST-04 STT 5 | EC-35, CT-44, đường P28, CE65 đến CE66, CE68, CE70 | Không (đối tượng thuần) | Cao | Unit |
| TC-077 | DC-RefundRequest.BeginAttempt | chuyển trạng thái | RefundRequest IN_FLIGHT, attemptCount 2 (tiến trình chết sau BeginAttempt lần hai) | BeginAttempt() (nhận lại claim) | Trả nil; Status = IN_FLIGHT; AttemptCount = 3 | Q-118; ST-04 STT 6; P09 F7.7 bước 4 | EC-36, EC-38, CT-45 | Không (đối tượng thuần) | Cao | Unit |
| TC-078 | DC-RefundRequest.BeginAttempt | giá trị biên | RefundRequest IN_FLIGHT, attemptCount 3 | BeginAttempt() | Trả nil; Status = IN_FLIGHT; AttemptCount = 4 | BR-41 (MaxAttempts = 4); ST-04 STT 6 | BV-16 | Không (đối tượng thuần) | Cao | Unit |
| TC-079 | DC-RefundRequest.BeginAttempt | giá trị biên | RefundRequest IN_FLIGHT, attemptCount 4 | BeginAttempt() | Ném RefundStateError; Status = IN_FLIGHT; AttemptCount = 4 | BR-41; P12 F2 (hết lượt) | EC-39, BV-17, CT-46, đường P30, CE65 đến CE66, CE69, CE72 | Không (đối tượng thuần) | Cao | Unit |
| TC-080 | DC-RefundRequest.BeginAttempt | chuyển trạng thái | RefundRequest REFUNDED (BeginAttempt, RecordResult(SUCCEEDED)) | BeginAttempt() | Ném RefundStateError; Status = REFUNDED; AttemptCount = 1 | P12 F6.2 | EC-37, CT-47, đường P29, CE65, CE67, CE71 | Không (đối tượng thuần) | Cao | Unit |
| TC-081 | DC-RefundRequest.BeginAttempt | chuyển trạng thái | RefundRequest MANUAL_REQUIRED (4 lần BeginAttempt và RecordResult(REJECTED)) | BeginAttempt() | Ném RefundStateError; Status = MANUAL_REQUIRED; AttemptCount = 4 | BR-41; Q-135 (trạng thái cuối) | EC-37, CT-47 | Không (đối tượng thuần) | Cao | Unit |
| TC-082 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest IN_FLIGHT, attemptCount 1 | RecordResult(SUCCEEDED, "00") | Trả nil; Status = REFUNDED | BR-43; ST-04 STT 7; UC-006 5 | EC-40, EC-42, CT-48, đường P32, CE73 đến CE74, CE76, CE81 | Không (đối tượng thuần) | Cao | Unit |
| TC-083 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest IN_FLIGHT, attemptCount 4 | RecordResult(SUCCEEDED, "00") | Trả nil; Status = REFUNDED (lần gửi cuối vẫn thành công được) | BR-41; ST-04 STT 7 | EC-42 | Không (đối tượng thuần) | Cao | Unit |
| TC-084 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest IN_FLIGHT, attemptCount 1 | RecordResult(REJECTED, "15") | Trả nil; Status = WAITING_RETRY; AttemptCount = 1 | BR-41; ST-04 STT 8; UC-006 5a | EC-43, CT-49, đường P33, CE73 đến CE74, CE77 đến CE78, CE82 | Không (đối tượng thuần) | Cao | Unit |
| TC-085 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest IN_FLIGHT, attemptCount 1 | RecordResult(UNKNOWN, "timeout") | Trả nil; Status = WAITING_RETRY; AttemptCount = 1 | BR-41, BR-43; ST-04 STT 8; UC-006 4a | EC-43, CT-49 | Không (đối tượng thuần) | Cao | Unit |
| TC-086 | DC-RefundRequest.RecordResult | giá trị biên | RefundRequest IN_FLIGHT, attemptCount 3 | RecordResult(REJECTED, "15") | Trả nil; Status = WAITING_RETRY (còn đúng một lần gửi nữa) | BR-41; ST-04 STT 8 | BV-18 | Không (đối tượng thuần) | Cao | Unit |
| TC-087 | DC-RefundRequest.RecordResult | giá trị biên | RefundRequest IN_FLIGHT, attemptCount 4 | RecordResult(REJECTED, "15") | Trả nil; Status = MANUAL_REQUIRED | BR-41; ST-04 STT 9; UC-006 5b | EC-44, BV-19, CT-50, đường P34, CE73 đến CE74, CE77, CE79, CE83 | Không (đối tượng thuần) | Cao | Unit |
| TC-088 | DC-RefundRequest.RecordResult | giá trị biên | RefundRequest IN_FLIGHT, attemptCount 4 | RecordResult(UNKNOWN, "timeout") | Trả nil; Status = MANUAL_REQUIRED | BR-41; ST-04 STT 9; UC-006 4b | EC-44, CT-50 | Không (đối tượng thuần) | Cao | Unit |
| TC-089 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest NEW (dựng bằng NewFullRefund) | RecordResult(SUCCEEDED, "00") | Ném RefundStateError; Status vẫn NEW | P12 F6.2 (bị từ chối) | EC-41, CT-51, đường P31, CE73, CE75, CE80 | Không (đối tượng thuần) | Cao | Unit |
| TC-090 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest WAITING_RETRY (dựng bằng BeginAttempt, RecordResult(REJECTED)) | RecordResult(SUCCEEDED, "00") | Ném RefundStateError; Status vẫn WAITING_RETRY | P12 F6.2 (bị từ chối) | EC-41, CT-51 | Không (đối tượng thuần) | Cao | Unit |
| TC-091 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest REFUNDED (dựng bằng BeginAttempt, RecordResult(SUCCEEDED)) | RecordResult(SUCCEEDED, "00") | Ném RefundStateError; Status vẫn REFUNDED | P12 F6.2 (bị từ chối) | EC-41, CT-51 | Không (đối tượng thuần) | Cao | Unit |
| TC-092 | DC-RefundRequest.RecordResult | chuyển trạng thái | RefundRequest MANUAL_REQUIRED (dựng bằng 4 lần BeginAttempt kèm RecordResult(REJECTED)) | RecordResult(SUCCEEDED, "00") | Ném RefundStateError; Status vẫn MANUAL_REQUIRED | P12 F6.2 (bị từ chối) | EC-41, CT-51 | Không (đối tượng thuần) | Cao | Unit |
| TC-093 | DC-RefundRequest.MarkManualRequired | chuyển trạng thái | RefundRequest IN_FLIGHT, attemptCount 2 | MarkManualRequired("NOT_SUPPORTED") | Trả nil; Status = MANUAL_REQUIRED | BR-41; Q-118; ST-04 STT 10; UC-006 4b | CT-52 | Không (đối tượng thuần) | Cao | Unit |
| TC-094 | DC-RefundRequest.MarkManualRequired | chuyển trạng thái | RefundRequest NEW | MarkManualRequired("NOT_SUPPORTED") | Ném RefundStateError; Status vẫn NEW | P12 F6.2 (bị từ chối) | CT-53 | Không (đối tượng thuần) | Cao | Unit |
| TC-095 | DC-RefundRequest.MarkManualRequired | chuyển trạng thái | RefundRequest WAITING_RETRY, attemptCount 1 | MarkManualRequired("NOT_SUPPORTED") | Ném RefundStateError; Status vẫn WAITING_RETRY | P12 F6.2 (bị từ chối) | CT-54 | Không (đối tượng thuần) | Cao | Unit |
| TC-096 | DC-RefundRequest.MarkManualRequired | chuyển trạng thái | RefundRequest REFUNDED | MarkManualRequired("NOT_SUPPORTED") | Ném RefundStateError; Status vẫn REFUNDED | P12 F6.2 (bị từ chối) | CT-55 | Không (đối tượng thuần) | Cao | Unit |
| TC-097 | DC-RefundRequest.MarkManualRequired | chuyển trạng thái | RefundRequest MANUAL_REQUIRED | MarkManualRequired("NOT_SUPPORTED") | Ném RefundStateError; Status vẫn MANUAL_REQUIRED | P12 F6.2 (bị từ chối) | CT-56 | Không (đối tượng thuần) | Cao | Unit |
| TC-098 | DC-Ticket.Cancel | chuyển trạng thái | Ticket UNUSED (NewTicket) | Cancel() | Trả nil; Status = CANCELLED; IsCancelled = true | BR-21; ST-03 STT 3; UC-008 4 | EC-45, CT-57 | Không (đối tượng thuần) | Cao | Unit |
| TC-099 | DC-Ticket.Cancel | chuyển trạng thái | Ticket CANCELLED (Cancel một lần) | Cancel() lần hai | Ném TicketStateError mang Status = CANCELLED; Status vẫn CANCELLED | BR-21; UC-008 4a; X-15 | EC-46, CT-58 | Không (đối tượng thuần) | Cao | Unit |
| TC-100 | DC-Ticket.Cancel | chuyển trạng thái | Ticket USED (Admit thành công) | Cancel() | Ném TicketStateError mang Status = USED; Status vẫn USED | BR-30; UC-008 4b; X-14 | EC-47, CT-59 | Không (đối tượng thuần) | Cao | Unit |
| TC-101 | DC-Ticket.Admit | bảng quyết định | Ticket UNUSED của suất 55; Showtime suất 55 thuộc cụm rạp 2 | Admit(showtime, selected = 55, cinemaId = 3) | Trả WRONG_CINEMA; Status vẫn UNUSED | BR-22; BR-33; UC-009 4b | EC-49, DT1-R1, CT-61, đường P35, CE84, CE86, CE93 | stub Showtime | Cao | Unit |
| TC-102 | DC-Ticket.Admit | bảng quyết định | Ticket USED của suất 55; Showtime suất 55 thuộc cụm rạp 2 | Admit(showtime, selected = 56, cinemaId = 3) (sai cụm rạp, sai suất, đã sử dụng) | Trả WRONG_CINEMA (lý do đầu theo BR-33); Status vẫn USED | BR-33; UC-009 4b | EC-49, DT1-R1 | stub Showtime | Cao | Unit |
| TC-103 | DC-Ticket.Admit | bảng quyết định | Ticket UNUSED của suất 55; Showtime suất 55 thuộc cụm rạp 2 | Admit(showtime, selected = 56, cinemaId = 2) | Trả WRONG_SHOWTIME; Status vẫn UNUSED | BR-23; UC-009 4c | EC-48, EC-51, DT1-R2, CT-62, đường P36, CE84 đến CE85, CE88, CE94 | stub Showtime | Cao | Unit |
| TC-104 | DC-Ticket.Admit | bảng quyết định | Ticket CANCELLED của suất 55; cụm rạp 2 | Admit(showtime, selected = 56, cinemaId = 2) (sai suất, đã huỷ) | Trả WRONG_SHOWTIME (lý do đầu theo BR-33); Status vẫn CANCELLED | BR-33; UC-009 4c | DT1-R2 | stub Showtime | Cao | Unit |
| TC-105 | DC-Ticket.Admit | bảng quyết định | Ticket USED của suất 55 (Admit thành công một lần); cụm rạp 2 | Admit(showtime, selected = 55, cinemaId = 2) | Trả ALREADY_USED; Status vẫn USED | BR-24; BR-33; UC-009 4d | EC-50, EC-53, DT1-R3, CT-63, đường P37, CE84 đến CE85, CE87, CE89, CE95 | stub Showtime | Cao | Unit |
| TC-106 | DC-Ticket.Admit | bảng quyết định | Ticket CANCELLED (Cancel) của suất 55; cụm rạp 2 | Admit(showtime, selected = 55, cinemaId = 2) | Trả CANCELLED; Status vẫn CANCELLED | BR-25; BR-33; UC-009 4e | EC-54, DT1-R4, CT-64, đường P38, CE84 đến CE85, CE87, CE90 đến CE91, CE96 | stub Showtime | Cao | Unit |
| TC-107 | DC-Ticket.Admit | bảng quyết định | Ticket UNUSED của suất 55; cụm rạp 2 | Admit(showtime, selected = 55, cinemaId = 2) | Trả ADMITTED; Status = USED | BR-22, BR-23, BR-24; ST-03 STT 2; UC-009 4 | EC-48, EC-50, EC-52, DT1-R5, CT-60, đường P39, CE84 đến CE85, CE87, CE90, CE92, CE97 | stub Showtime | Cao | Unit |
| TC-108 | DC-Ticket.Admit | chuyển trạng thái | Ticket UNUSED --> vừa Admit thành công | Admit(showtime, selected = 55, cinemaId = 2) lần hai | Trả ALREADY_USED; Status vẫn USED (một vé chỉ vào một lần) | BR-24; X-15; UC-009 4d | DT1-R3 | stub Showtime | Cao | Unit |
| TC-109 | DC-Ticket.RefundAmount | phân vùng tương đương | Ticket UNUSED, price 100.000 | RefundAmount() | Trả Money 70.000 | BR-19; UC-008 5a1 | EC-55 | Không (đối tượng thuần) | Cao | Unit |
| TC-110 | DC-Ticket.RefundAmount | phân vùng tương đương | Ticket UNUSED, price 45.000 | RefundAmount() | Trả Money 31.500 | BR-19, BR-31; UC-008 5a1 | EC-55 | Không (đối tượng thuần) | Cao | Unit |
| TC-111 | DC-Ticket.RefundAmount | giá trị biên | Ticket UNUSED, price 45.005 | RefundAmount() | Trả Money 31.503 | BR-31; UC-008 5a1 | BV-20 | Không (đối tượng thuần) | Cao | Unit |
| TC-112 | DC-Ticket.RefundAmount | giá trị biên | Ticket UNUSED, price 45.007 | RefundAmount() | Trả Money 31.504 | BR-31; UC-008 5a1 | BV-21 | Không (đối tượng thuần) | Cao | Unit |
| TC-113 | DC-Ticket.RefundAmount | giá trị biên | Ticket UNUSED, price 45.001 | RefundAmount() | Trả Money 31.500 | BR-31; UC-008 5a1 | EC-56 | Không (đối tượng thuần) | Cao | Unit |
| TC-114 | DC-Ticket.RefundAmount | giá trị biên | Ticket UNUSED, price 1 | RefundAmount() | Trả Money 0 | BR-31; xem Vấn đề còn mở 6; UC-008 5a1 | BV-22 | Không (đối tượng thuần) | Cao | Unit |
| TC-115 | DC-Ticket.RefundAmount | phân vùng tương đương | Ticket price = 0 | RefundAmount() | Chưa xác định: chờ Q-144 | P12 F2 (không nêu) | EC-57; không tính vào độ phủ (chờ Q-144) | Không (đối tượng thuần) | Thấp | Unit |
| TC-116 | DC-Booking.CheckCancellationChannel | bảng quyết định | Booking của hold CUSTOMER 7 | CheckCancellationChannel(actor = khách 7) | Trả nil | BR-17; UC-008 2 | DT2-R1 | Không (đối tượng thuần) | Cao | Unit |
| TC-117 | DC-Booking.CheckCancellationChannel | bảng quyết định | Booking của hold CUSTOMER 7 | CheckCancellationChannel(actor = khách 8) | Ném ChannelMismatchError | BR-17; UC-008 2a | DT2-R2 | Không (đối tượng thuần) | Cao | Unit |
| TC-118 | DC-Booking.CheckCancellationChannel | bảng quyết định | Booking của hold CLERK 3 (mua tại quầy) | CheckCancellationChannel(actor = khách 7) | Ném ChannelMismatchError | BR-17; UC-008 2a | DT2-R3 | Không (đối tượng thuần) | Cao | Unit |
| TC-119 | DC-Booking.CheckCancellationChannel | bảng quyết định | Booking của hold CUSTOMER 7 | CheckCancellationChannel(actor = nhân viên quầy 3) | Ném ChannelMismatchError | BR-17; UC-008 2b | DT2-R4 | Không (đối tượng thuần) | Cao | Unit |
| TC-120 | DC-Booking.CheckCancellationChannel | bảng quyết định | Booking của hold CLERK 3 | CheckCancellationChannel(actor = nhân viên quầy 4, cùng cụm rạp) | Trả nil | BR-17; UC-008 5a | DT2-R5 | Không (đối tượng thuần) | Cao | Unit |
| TC-121 | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | phân vùng tương đương | Khách 7 không có lần giữ ghế nào | DC-Customer.CheckNoActiveSeatHold([], now = 10:05:00) | Trả nil | BR-04; UC-005 5 | EC-58 | Không (đối tượng thuần) | Cao | Unit |
| TC-122 | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | phân vùng tương đương | Khách 7; unfinished = [hold CANCELLED] | DC-Customer.CheckNoActiveSeatHold([CANCELLED], now = 10:05:00) | Trả nil | BR-04 (hủy giữ ghế là kết thúc) | EC-58 | Không (đối tượng thuần) | Cao | Unit |
| TC-123 | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | giá trị biên | Khách 7; unfinished = [hold ACTIVE, expiryTime E] | DC-Customer.CheckNoActiveSeatHold(..., now = E - 1ms) | Ném HolderBusyError | BR-04; UC-005 5b, 7c | EC-59, BV-23 | Không (đối tượng thuần) | Cao | Unit |
| TC-124 | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | giá trị biên | Khách 7; unfinished = [hold ACTIVE, expiryTime E] | DC-Customer.CheckNoActiveSeatHold(..., now = E) | Trả nil (lần giữ ghế đã kết thúc tại thời điểm hết hạn) | BR-04; UC-005 mục 8 (mốc hết hạn) | EC-60, BV-24 | Không (đối tượng thuần) | Cao | Unit |
| TC-125 | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | phân vùng tương đương | Nhân viên quầy 3; unfinished = [hold ACTIVE, expiryTime E] | DC-BoxOfficeClerk.CheckNoActiveSeatHold(..., now = E - 1ms) | Ném HolderBusyError | BR-04; UC-005 5b | EC-59 | Không (đối tượng thuần) | Cao | Unit |
| TC-126 | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | giá trị biên | Nhân viên quầy 3; unfinished = [hold ACTIVE, expiryTime E] | DC-BoxOfficeClerk.CheckNoActiveSeatHold(..., now = E) | Trả nil | BR-04 | EC-60 | Không (đối tượng thuần) | Cao | Unit |
| TC-127 | DC-LockOrderGuard.Acquire, AcquireAll | giá trị biên | Guard mới (maxRank 0) | Acquire(PRICE_LIST, (2,0), S) | Trả nil; Violated() = false | BR/P08 F4b quy tắc 1, 3; P09 F7.3 | EC-61, BV-26, DT3-R5, đường P45, CE98, CE100, CE104, CE106, CE111 | Không (đối tượng thuần) | Cao | Unit |
| TC-128 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard mới | Acquire(PRICE_LIST,(2,0),S); Acquire(AUDITORIUM,(7,0),S); Acquire(SHOWTIME,(55,0),S); Acquire(HOLDER,(7,0),X) | Mọi lời gọi trả nil; Violated() = false | BR/P08 F4b quy tắc 1, 3; P09 F7.3 | EC-61, DT3-R5 | Không (đối tượng thuần) | Cao | Unit |
| TC-129 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard mới | Acquire(SEAT_STATUS,(55,101),X); Acquire(SEAT_STATUS,(55,102),X) | Cả hai trả nil; Violated() = false | BR/P08 F4b quy tắc 1, 3; P09 F7.3 | EC-62, DT3-R5, đường P44, CE98, CE100, CE104 đến CE105, CE108, CE111 | Không (đối tượng thuần) | Cao | Unit |
| TC-130 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã Acquire(SEAT_STATUS,(55,102),X) | Acquire(SEAT_STATUS,(55,101),X) | Ném LockOrderViolationError; Violated() = true | BR/P08 F4b quy tắc 1, 3; P09 F7.3 | EC-64, DT3-R4, đường P43, CE98, CE100, CE104 đến CE105, CE107, CE110 | Không (đối tượng thuần) | Cao | Unit |
| TC-131 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã Acquire(SEAT_STATUS,(55,101),X) | Acquire(SEAT_HOLD,(3,0),X) | Ném LockOrderViolationError; Violated() = true (chuỗi SeatReleaseJob không được xen kẽ hạng 5 sau hạng 6) | P09 F7.4 bước 2; P10 F3a EX-05 | EC-63, DT3-R3, đường P42, CE98, CE100, CE103, CE110 | Không (đối tượng thuần) | Cao | Unit |
| TC-132 | DC-LockOrderGuard.Acquire, AcquireAll | giá trị biên | Guard đã Acquire(PAYMENT_TRANSACTION,(100,0),X) | Acquire(TICKET,(1,0),X) | Trả nil (rank lớn hơn thì không so key); Violated() = false | P09 F7.3 (hạng 7 rồi 8) | BV-25 | Không (đối tượng thuần) | Cao | Unit |
| TC-133 | DC-LockOrderGuard.Acquire, AcquireAll | giá trị biên | Guard đã Acquire(TICKET,(9,0),X) | Acquire(REFUND_REQUEST,(4,0),X) | Trả nil; Violated() = false (hạng 9 lớn nhất) | P08 F4b EX-09, EX-10 | BV-26 | Không (đối tượng thuần) | Cao | Unit |
| TC-134 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã Acquire(SEAT_STATUS,(55,101),X) | Acquire(SEAT_STATUS,(55,101),X) lần hai | Trả nil; Violated() = false | P12 F2 (khoá lại cùng chế độ) | EC-65, DT3-R1, đường P40, CE98 đến CE99, CE101, CE109 | Không (đối tượng thuần) | Cao | Unit |
| TC-135 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã Acquire(SEAT_STATUS,(55,101),X) | Acquire(SEAT_STATUS,(55,101),S) | Trả nil; Violated() = false (chế độ yếu hơn) | P12 F2 | EC-65, DT3-R1 | Không (đối tượng thuần) | Cao | Unit |
| TC-136 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã Acquire(SEAT_STATUS,(55,101),S) | Acquire(SEAT_STATUS,(55,101),X) | Ném LockOrderViolationError; Violated() = true | P08 F4b quy tắc 2 (không nâng S thành X) | EC-66, DT3-R2, đường P41, CE98 đến CE99, CE102, CE110 | Không (đối tượng thuần) | Cao | Unit |
| TC-137 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã Acquire(...,(55,101),X) và (55,102),X) | Acquire(SEAT_STATUS,(55,101),S) (dòng thấp hơn maxKey đã giữ từ trước) | Trả nil; Violated() = false (khoá lại dòng đã giữ không phải đi lùi) | P12 F3 (Acquire bước 2) | EC-65, DT3-R1 | Không (đối tượng thuần) | Cao | Unit |
| TC-138 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard mới | AcquireAll(SEAT_STATUS, [(55,101),(55,102),(55,105)], X) | Trả nil; Violated() = false | P12 F3 (AcquireAll bước 3) | EC-62 | Không (đối tượng thuần) | Cao | Unit |
| TC-139 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard mới | AcquireAll(SEAT_STATUS, [(55,105),(55,102)], X) | Ném LockOrderViolationError; Violated() = true | P12 F3 (AcquireAll bước 3); P09 F7.3 | EC-64 | Không (đối tượng thuần) | Cao | Unit |
| TC-140 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard đã vi phạm một lần | Violated() | Trả true (PgUnitOfWork rollback, không thử lại) | P12 F2 (Violated) | - | Không (đối tượng thuần) | Cao | Unit |
| TC-141 | DC-LockOrderGuard.Acquire, AcquireAll | phân vùng tương đương | Guard mới | AcquireAll(SEAT_STATUS, [(55,101),(55,101)], X) | Chưa xác định: chờ Q-144 | P12 F3 (keys phải tăng dần, không nêu bằng nhau) | không tính vào độ phủ (chờ Q-144) | Không (đối tượng thuần) | Thấp | Unit |
| TC-142 | DC-Showtime.CheckCancellationDeadline | giá trị biên | Showtime start 20:00:00.000 | CheckCancellationDeadline(now = 18:00:00.000) | Trả nil | BR-18, BR-32; UC-008 3a | EC-67, BV-27 | Không (đối tượng thuần) | Cao | Unit |
| TC-143 | DC-Showtime.CheckCancellationDeadline | giá trị biên | Showtime start 20:00:00.000 | CheckCancellationDeadline(now = 18:00:00.001) | Ném CancelDeadlineError | BR-18, BR-32; UC-008 3a | EC-68, BV-28 | Không (đối tượng thuần) | Cao | Unit |
| TC-144 | DC-Showtime.CheckCancellationDeadline | giá trị biên | Showtime start 20:00:00.000 | CheckCancellationDeadline(now = 17:59:59.999) | Trả nil | BR-18, BR-32; UC-008 3a | EC-67, BV-29 | Không (đối tượng thuần) | Cao | Unit |
| TC-145 | DC-Showtime.CheckCancellationDeadline | giá trị biên | Showtime start 20:00:00.000 | CheckCancellationDeadline(now = 20:00:00.000) | Ném CancelDeadlineError | BR-18, BR-32; UC-008 3a | EC-68, BV-30 | Không (đối tượng thuần) | Cao | Unit |
| TC-146 | DC-Showtime.CheckCancellationDeadline | phân vùng tương đương | Showtime start 20:00:00.000 | CheckCancellationDeadline(now = 21:00:00.000) | Ném CancelDeadlineError | BR-18; UC-008 3a (đã bắt đầu) | EC-69 | Không (đối tượng thuần) | Cao | Unit |
| TC-147 | DC-Showtime.CheckSaleOpen | giá trị biên | Showtime IN_SCHEDULE | CheckSaleOpen(now = 2026-11-09 07:59:59.999) | Ném ShowtimeNotOpenError | BR-01, BR-45; UC-005 2a | EC-70, BV-31 | Không (đối tượng thuần) | Cao | Unit |
| TC-148 | DC-Showtime.CheckSaleOpen | giá trị biên | Showtime IN_SCHEDULE | CheckSaleOpen(now = 2026-11-09 08:00:00.000) | Trả nil | BR-01, BR-45; UC-005 2 | EC-71, BV-32 | Không (đối tượng thuần) | Cao | Unit |
| TC-149 | DC-Showtime.CheckSaleOpen | giá trị biên | Showtime IN_SCHEDULE | CheckSaleOpen(now = 2026-11-10 19:59:59.999) | Trả nil | BR-01, BR-45; UC-005 2 | EC-71, BV-33 | Không (đối tượng thuần) | Cao | Unit |
| TC-150 | DC-Showtime.CheckSaleOpen | giá trị biên | Showtime IN_SCHEDULE | CheckSaleOpen(now = 2026-11-10 20:00:00.000) | Ném ShowtimeNotOpenError | BR-01, BR-45; UC-005 2c | EC-72, BV-34 | Không (đối tượng thuần) | Cao | Unit |
| TC-151 | DC-Showtime.CheckSaleOpen | phân vùng tương đương | Showtime Đã xoá (DELETED), now trong khoảng mở bán | CheckSaleOpen(now = 2026-11-10 10:00:00.000) | Ném ShowtimeNotOpenError | P12 F1b; BR-58 | EC-73 | Không (đối tượng thuần) | Cao | Unit |
| TC-152 | DC-Showtime.CheckSeatSelection | giá trị biên | Showtime của phòng chiếu 7 | CheckSeatSelection([]) | Ném SeatSelectionError(EMPTY) | BR-05 | EC-74, BV-35 | Không (đối tượng thuần) | Cao | Unit |
| TC-153 | DC-Showtime.CheckSeatSelection | giá trị biên | Showtime của phòng chiếu 7 | CheckSeatSelection([ghế 101]) | Trả nil | BR-05 | EC-75, BV-36 | Không (đối tượng thuần) | Cao | Unit |
| TC-154 | DC-Showtime.CheckSeatSelection | giá trị biên | Showtime của phòng chiếu 7 | CheckSeatSelection(8 ghế 101..108 của phòng 7) | Trả nil | BR-05; UC-005 6 | BV-37 | Không (đối tượng thuần) | Cao | Unit |
| TC-155 | DC-Showtime.CheckSeatSelection | giá trị biên | Showtime của phòng chiếu 7 | CheckSeatSelection(9 ghế 101..109 của phòng 7) | Ném SeatSelectionError(TOO_MANY) | BR-05; UC-005 6a | EC-76, BV-38 | Không (đối tượng thuần) | Cao | Unit |
| TC-156 | DC-Showtime.CheckSeatSelection | phân vùng tương đương | Showtime của phòng chiếu 7 | CheckSeatSelection([ghế 101, ghế 101]) | Ném SeatSelectionError(DUPLICATE) | P12 F2 | EC-77 | Không (đối tượng thuần) | Cao | Unit |
| TC-157 | DC-Showtime.CheckSeatSelection | phân vùng tương đương | Showtime của phòng chiếu 7 | CheckSeatSelection([ghế 101, ghế 900 của phòng 8]) | Ném SeatSelectionError(NOT_IN_AUDITORIUM) | P12 F2 | EC-78 | Không (đối tượng thuần) | Cao | Unit |
| TC-158 | DC-Showtime.CheckSeatSelection | phân vùng tương đương | Showtime của phòng chiếu 7 | CheckSeatSelection(8 ghế COUPLE của phòng 7) | Trả nil (mỗi ghế đôi tính một ghế) | BR-06 | EC-79 | Không (đối tượng thuần) | Cao | Unit |
| TC-159 | DC-Showtime.CheckSeatSelection | phân vùng tương đương | Showtime của phòng chiếu 7 | CheckSeatSelection(9 ghế của phòng 7 trong đó hai phần tử trùng) | Chưa xác định: chờ Q-152 | P12 F2 (không nêu thứ tự) | không tính vào độ phủ (chờ Q-152) | Không (đối tượng thuần) | Trung bình | Unit |
| TC-160 | DC-Showtime.CheckUnchangedSince | phân vùng tương đương | Showtime IN_SCHEDULE, lastChangedAt 2026-11-08 09:00:00.000 | CheckUnchangedSince(2026-11-08 09:00:00.000) | Trả nil | BR-54 | EC-80 | Không (đối tượng thuần) | Cao | Unit |
| TC-161 | DC-Showtime.CheckUnchangedSince | giá trị biên | Showtime IN_SCHEDULE, lastChangedAt 2026-11-08 09:00:00.001 | CheckUnchangedSince(2026-11-08 09:00:00.000) | Ném ShowtimeChangedError | BR-54; UC-005 7d; X-03 | EC-81, BV-39 | Không (đối tượng thuần) | Cao | Unit |
| TC-162 | DC-Showtime.CheckUnchangedSince | phân vùng tương đương | Showtime Đã xoá, lastChangedAt 2026-11-08 09:00:00.000 | CheckUnchangedSince(2026-11-08 09:00:00.000) | Ném ShowtimeChangedError | BR-54; UC-005 7d | EC-82 | Không (đối tượng thuần) | Cao | Unit |
| TC-163 | DC-Showtime.CheckUnchangedSince | phân vùng tương đương | Showtime IN_SCHEDULE, lastChangedAt 2026-11-08 09:00:00.000 | CheckUnchangedSince(2026-11-08 09:00:00.001) | Chưa xác định: chờ Q-144 | P12 F2 (không nêu) | EC-83; không tính vào độ phủ (chờ Q-144) | Không (đối tượng thuần) | Thấp | Unit |
| TC-164 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Tư 2026-11-11 16:59:59.999 +07:00) | Trả Money 70.000 | BR-11, BR-12 | EC-84, BV-40 | Không (đối tượng thuần) | Cao | Unit |
| TC-165 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Tư 2026-11-11 17:00:00.000 +07:00) | Trả Money 90.000 | BR-11, BR-12 | EC-85, BV-41 | Không (đối tượng thuần) | Cao | Unit |
| TC-166 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Sáu 2026-11-13 23:59:59.999 +07:00) | Trả Money 90.000 | BR-11, BR-12 | EC-85, BV-42 | Không (đối tượng thuần) | Cao | Unit |
| TC-167 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Bảy 2026-11-14 00:00:00.000 +07:00) | Trả Money 85.000 | BR-11, BR-12 | EC-86, BV-43 | Không (đối tượng thuần) | Cao | Unit |
| TC-168 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Bảy 2026-11-14 16:59:59.999 +07:00) | Trả Money 85.000 | BR-11, BR-12 | EC-86, BV-44 | Không (đối tượng thuần) | Cao | Unit |
| TC-169 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Bảy 2026-11-14 17:00:00.000 +07:00) | Trả Money 110.000 | BR-11, BR-12 | EC-87, BV-45 | Không (đối tượng thuần) | Cao | Unit |
| TC-170 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Chủ nhật 2026-11-15 23:59:59.999 +07:00) | Trả Money 110.000 | BR-11, BR-12 | EC-87, BV-46 | Không (đối tượng thuần) | Cao | Unit |
| TC-171 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Hai 2026-11-16 00:00:00.000 +07:00) | Trả Money 70.000 | BR-11, BR-12 | EC-84, BV-47 | Không (đối tượng thuần) | Cao | Unit |
| TC-172 | DC-PriceList.DetermineSeatPrice | phân vùng tương đương | PriceList như trên | DetermineSeatPrice(IMAX, 3D, VIP, startTime = Thứ Tư 20:00 +07:00) | Ném NotFoundError | BR-72; UC-005 7e | EC-88 | Không (đối tượng thuần) | Cao | Unit |
| TC-173 | DC-PriceList.DetermineSeatPrice | phân vùng tương đương | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = 2026-11-13 10:00:00Z, tức Thứ Sáu 17:00 +07:00) | Chưa xác định: chờ Q-151 | BR-12 (múi giờ chưa nêu) | EC-89; không tính vào độ phủ (chờ Q-151) | Không (đối tượng thuần) | Trung bình | Unit |
| TC-174 | DC-BookTicketsService.HoldSeats | use case | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Trả HoldResult: replayed = false, tổng = 270.000; SeatHold ACTIVE expiry 10:10:00.000, holdRef ref-1; ghế 101, 102, 103 HELD bởi hold mới, heldPrice 90.000; Insert 1 lần; SaveChanges 1 lần với 3 ghế; Do 1 lần với deadline = lúc nhận + 1,8 giây, pool USER; Violated() = false | BR-07, BR-10, BR-65; UC-005 7, 8 (KB1); NFR-06 | EC-102, EC-106, EC-108, EC-90, EC-94, EC-96, EC-98, DT4-R1, đường P46, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE150, CE152 đến CE157, CE159 đến CE160 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-175 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 1 ghế [101] | Giữ được: tổng 90.000; 1 ghế HELD | BR-05 (tối thiểu); UC-005 7 | BV-49, đường P47, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE150, CE152 đến CE157, CE159 đến CE160 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-176 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101 đến 107 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 7 ghế [101..107] | Giữ được: tổng 630.000; 7 ghế HELD; SaveChanges 1 lần | BR-05 (n - 1) | BV-50 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-177 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101 đến 108 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 8 ghế [101..108] | Giữ được: tổng 720.000; 8 ghế HELD; SaveChanges 1 lần | BR-05 (tối đa); UC-005 6 | BV-51, đường P48, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE150, CE152 đến CE157, CE159 đến CE160 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-178 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với seatIds = [] | Ném SeatSelectionError(EMPTY); FindRouting 0 lần; Do 0 lần; không ghi gì | BR-05 | EC-91, BV-48, DT4-R3, đường P49, CE112 đến CE113, CE162 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-179 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 9 ghế [101..109] | Ném SeatSelectionError(TOO_MANY); FindRouting 0 lần; Do 0 lần; không ghi gì | BR-05; UC-005 6a | EC-92, BV-52 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-180 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với showtimeId 9999 (FindRouting ném NotFoundError) | Ném NotFoundError; Do 0 lần | P12 F2 (NotFoundError) | EC-111, đường P50, CE112, CE114 đến CE116, CE163 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-181 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockUnfinishedOrByRequest ném SystemBusyError (hết lock_timeout) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SystemBusyError; không có lần giữ ghế, không ghế đổi; rollback | P09 F7.3; P12 F2 | đường P51, CE112, CE114 đến CE115, CE117 đến CE119, CE164 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-182 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; phòng của suất chiếu đã khoá là 8 (FindRouting trả 7) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeChangedError; không ghi gì; không gọi LockForHold | BR-54; P12 F3 (c); UC-005 7d | EC-110, đường P52, CE112, CE114 đến CE115, CE117 đến CE118, CE120 đến CE121, CE165 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-183 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; đã có lần giữ ghế H0 ACTIVE của khách 7 với requestId r-1, expiry 10:10:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) với tx.Now = 10:09:59.999 | Trả lại H0: replayed = true; Insert 0 lần; ghế không đổi; không tạo lần giữ ghế thứ hai | P09 F7.3 EX-01 (xác nhận lặp an toàn khi phản hồi mất); Bảng hỏng M5 mục 4 | EC-100, BV-53, đường P53, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122 đến CE123, CE125, CE161 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-184 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; lần giữ ghế H0 của khách 7 với requestId r-1 ở trạng thái CANCELLED | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HoldNotActiveError mang Status = CANCELLED; Insert 0 lần; ghế không đổi | P12 F3 (d); BR-86 | EC-101, đường P54, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122 đến CE123, CE126, CE166 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-185 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 của khách 7 với requestId r-1, ACTIVE, expiry 10:10:00.000; tx.Now = 10:10:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Chưa xác định: chờ Q-142 | P12 F3 (d) và F6.2; BR-86 | không tính vào độ phủ (chờ Q-142) | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-186 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; lần giữ ghế H0 ACTIVE của khách 7 (requestId r-0, expiry 10:10:00.000); tx.Now = 10:09:59.999 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HolderBusyError; không có lần giữ ghế mới; ghế 101..103 vẫn AVAILABLE; H0 vẫn ACTIVE | BR-04; X-02; UC-005 5b, 7c (KB6) | EC-99, BV-55, DT4-R4, đường P57, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE130, CE167 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-187 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 ACTIVE của khách 7 (requestId r-0, expiry 10:10:00.000); tx.Now = 10:10:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Giữ thành công (H0 coi là đã kết thúc tại thời điểm hết hạn): H0 EXPIRED, UpdateStatus H0 1 lần; lần giữ ghế mới ACTIVE; 3 ghế HELD bởi hold mới | BR-04, BR-10; UC-005 mục 8 (mốc hết hạn); P12 F3 (e) | BV-54, đường P55, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE127, CE129, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE150, CE152 đến CE157, CE159 đến CE160 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-188 | DC-BookTicketsService.HoldSeats | use case | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 của khách 7 ACTIVE hết hạn 10:10:00.000, đang giữ ghế 101 và 109 (HELD bởi H0); tx.Now = 10:10:00.000 | HoldSeats(ghế [101, 102, 103]) | Giữ thành công: H0 EXPIRED; ghế 101 HELD bởi hold mới (ReleaseHold(H0) rồi HoldFor); ghế 109 vẫn HELD bởi H0 (SeatReleaseJob trả sau); SaveChanges 1 lần; Violated() = false | Q-134; P12 F3 (g); BR-04 | đường P56, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE127, CE129, CE133, CE135 đến CE136, CE138, CE143, CE145 đến CE146, CE148, CE150, CE152 đến CE157, CE159 đến CE160 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-189 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-09 07:59:59.999 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeNotOpenError; không ghi gì | BR-01; UC-005 2a | EC-95, DT4-R2, đường P58, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131 đến CE132, CE168 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-190 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-10 20:00:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeNotOpenError; không ghi gì | BR-45; UC-005 2c (KB7) | DT4-R2 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-191 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-09 12:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeChangedError; không ghế bị khoá; không ghi gì | BR-54; UC-005 7d (KB9) | EC-97, DT4-R5, đường P59, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133 đến CE134, CE169 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-192 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với seatIds [101, 900], ghế 900 thuộc phòng 8 | Ném SeatSelectionError(NOT_IN_AUDITORIUM); không ghi gì | P12 F3 (f); F1b | EC-93, đường P60, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE137, CE170 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-193 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockForHold ném SeatUnavailableError(LOCKED_BY_OTHER) (55P03); FindBeingReleased = false | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(LOCKED_BY_OTHER); Do 1 lần (không thử lại); không có lần giữ ghế mới | BR-09; P09 F7.3 EX-01; X-01 | EC-104, đường P61, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138 đến CE140, CE142, CE172 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-194 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockForHold ném 55P03; FindBeingReleased = true (ghế đang được trả) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(BEING_RELEASED) (MSG-82); Do 1 lần | P12 F3 (g); X-13 | đường P62, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138 đến CE141, CE171 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-195 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockForHold trả 2 dòng cho 3 ghế | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError; không ghi gì | P12 F3 (g); BR-07 | EC-105, đường P63, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143 đến CE144, CE173 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-196 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; ghế 102 HELD bởi hold H9 của người khác | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(NOT_AVAILABLE); không có lần giữ ghế mới; ghế 101, 103 vẫn AVAILABLE (cả nhóm hoặc không ghế nào) | BR-07, BR-08; UC-005 7a (KB3) | EC-103, DT4-R6, đường P64, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE149, CE174 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-197 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; ghế 102 SOLD | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(NOT_AVAILABLE); ghế 101, 103 vẫn AVAILABLE | BR-09; UC-005 7a | EC-103, DT4-R6 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-198 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; bảng giá không có mục cho ghế 103 (VIP) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném NotFoundError; không có lần giữ ghế; không ghế đổi | BR-72; UC-005 7e (KB10) | EC-107, DT4-R7, đường P65, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE150 đến CE151, CE175 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-199 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; fake IF-08.Do trả SystemBusyError sau hết lần thử | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SystemBusyError; không ghi gì; TxOptions.deadline = lúc nhận + 1,8 giây | NFR-06; P09 F7.3 | EC-109, đường P66, CE112, CE114 đến CE115, CE117 đến CE118, CE120, CE122, CE124, CE128, CE131, CE133, CE135 đến CE136, CE138, CE143, CE145, CE147, CE150, CE152 đến CE158, CE176 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-200 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; khách 7 có H0 ACTIVE (7c) và suất chiếu đã đổi (7d) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HolderBusyError (7c trước 7d) | UC-005 mục 8 (7c kiểm trước 7d); BR-04 | DT4-R4 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-201 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; suất chiếu đã đổi (7d) và ghế 102 HELD bởi người khác (7a) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeChangedError (7d trước 7a) | UC-005 mục 8 (7d trước 7a); BR-54 | DT4-R5 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-202 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; ghế 102 HELD bởi người khác (7a) và thiếu giá ghế 103 (7e) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(NOT_AVAILABLE) (7e kiểm sau 7a) | UC-005 mục 8 (7e sau 7a); BR-72 | DT4-R6 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-203 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; khách 7 có H0 ACTIVE (7c) và ghế 102 HELD bởi người khác (7a) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HolderBusyError (7c trước 7a) | UC-005 7c (kiểm trước 7a) | DT4-R4 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-204 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-10 20:00:00.000 (đã bắt đầu) và khách 7 có H0 ACTIVE | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Chưa xác định: chờ Q-145 | UC-005 2c và 7c (không nêu thứ tự trong cùng yêu cầu) | DT4-R8; không tính vào độ phủ (chờ Q-145) | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-205 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; khách 7 có H0 ACTIVE | HoldSeats với 9 ghế | Chưa xác định: chờ Q-145 | UC-005 6a và 7c | DT4-R9; không tính vào độ phủ (chờ Q-145) | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-206 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-10 20:00:00.000 | HoldSeats với 9 ghế | Chưa xác định: chờ Q-145 | UC-005 2c và 6a | DT4-R10; không tính vào độ phủ (chờ Q-145) | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-207 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 COMPLETED; txn TICKETED | decide(báo thành công, now = 10:12:00) | Trả DUPLICATE | BR-37; UC-006 2a | DT5-R1, đường P68, CE177, CE179 đến CE180, CE187 | Không (đối tượng thuần) | Cao | Unit |
| TC-208 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 EXPIRED; txn LATE_PAYMENT | decide(báo thành công, now = 10:30:00) | Trả DUPLICATE (đã xử lý bất kể trạng thái lần giữ ghế) | BR-37; UC-006 2a | DT5-R1 | Không (đối tượng thuần) | Cao | Unit |
| TC-209 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn PENDING | decide(báo thành công, now = 10:09:59.999) | Trả SELL | BR-37; UC-005 11, 12 | DT5-R2, đường P69, CE177, CE179, CE181 đến CE182, CE184, CE188 | Không (đối tượng thuần) | Cao | Unit |
| TC-210 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn PENDING | decide(báo thành công, now = 10:10:00.000) | Trả LATE (IsActiveAt sai đúng tại thời điểm hết hạn) | BR-14; UC-006 (trễ) | DT5-R3, đường P70, CE177, CE179, CE181 đến CE182, CE185, CE189 | Không (đối tượng thuần) | Cao | Unit |
| TC-211 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 CANCELLED (Cancel 10:03); txn PENDING | decide(báo thành công, now = 10:05:00) | Trả LATE (huỷ giữ ghế trước hạn vẫn là thanh toán trễ) | BR-15; UC-005 *a | DT5-R3 | Không (đối tượng thuần) | Cao | Unit |
| TC-212 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn FAILED (RecordFailure) | decide(báo thành công, now = 10:05:00) | Trả LATE | BR-15; ST-05 STT 5 | DT5-R4, đường P71, CE177, CE179, CE181, CE183, CE189 | Không (đối tượng thuần) | Cao | Unit |
| TC-213 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 PAYMENT_FAILED; txn FAILED | decide(báo thành công, now = 10:20:00) | Trả LATE | BR-15; BR-86 | DT5-R5 | Không (đối tượng thuần) | Cao | Unit |
| TC-214 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn PENDING | decide(báo thất bại, now = 10:05:00) | Trả FAILURE | BR-39; UC-005 11a | DT5-R6, đường P67, CE177 đến CE178, CE186 | Không (đối tượng thuần) | Cao | Unit |
| TC-215 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 COMPLETED; txn TICKETED | decide(báo thất bại, now = 10:20:00) | Trả FAILURE (HandleIpn ghi nhận, không hoàn tiền) | BR-39; UC-006 2d | DT5-R6 | Không (đối tượng thuần) | Cao | Unit |
| TC-216 | DC-BookTicketsService.CancelHold | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:05:00.000 | CancelHold(H1, by khách 7) | Trả nil; H1 CANCELLED; ghế 101..103 AVAILABLE; UpdateStatus 1 lần; SaveChanges 1 lần (3 ghế); 1 commit; Violated() = false (hạng 5 rồi 6) | BR-85; UC-005 *a; Q-134 (KB: huỷ giữ ghế) | EC-112, đường P72, CE190 đến CE191, CE193, CE195 đến CE196, CE198, CE200, CE202 đến CE207 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-217 | DC-BookTicketsService.CancelHold | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:09:59.999 | CancelHold(H1, by khách 7) | Trả nil; H1 CANCELLED; ghế AVAILABLE | BR-10; BR-85 | BV-56 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-218 | DC-BookTicketsService.CancelHold | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:10:00.000 | CancelHold(H1, by khách 7) | Ném HoldNotActiveError mang Status = EXPIRED; H1 EXPIRED (đã ghi); ghế 101..103 AVAILABLE; cùng một commit (fn trả nil) | BR-86; UC-005 7b; Q-134; X-10 | EC-113, BV-57, đường P73, CE190 đến CE191, CE193, CE195 đến CE197, CE201, CE203 đến CE207 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-219 | DC-BookTicketsService.CancelHold | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:05:00.000 | CancelHold(H1, by khách 8) | Ném NotFoundError; H1 vẫn ACTIVE; ghế vẫn HELD bởi H1; không ghi gì | P12 F3 (không lộ sự tồn tại) | EC-115, đường P75, CE190 đến CE191, CE193 đến CE194, CE209 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-220 | DC-BookTicketsService.CancelHold | phân vùng tương đương | Không có lần giữ ghế mã 9999 | CancelHold(9999, by khách 7) | Ném NotFoundError; không ghi gì | P12 F2 | EC-116, đường P74, CE190 đến CE192, CE208 | fake IF-08/17/18, stub IF-25 | Trung bình | Unit |
| TC-221 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 COMPLETED (đã bán); ghế 101..103 SOLD | CancelHold(H1, by khách 7) lúc 10:05:00 | Ném HoldNotActiveError mang Status = COMPLETED; ghế vẫn SOLD; UpdateStatus 0 lần; SaveChanges 0 lần | BR-86; X-12; UC-005 *a (huỷ đến sau khi bán) | EC-114, đường P76, CE190 đến CE191, CE193, CE195 đến CE196, CE198 đến CE199, CE210 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-222 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 CANCELLED (đã huỷ một lần, ghế đã trả) | CancelHold(H1, by khách 7) lần hai | Ném HoldNotActiveError mang Status = CANCELLED; không ghi gì | BR-86 (người dùng bấm huỷ hai lần) | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-223 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 EXPIRED; ghế 101 đã được giữ lại bởi H2 (HELD bởi H2), ghế 102, 103 AVAILABLE | CancelHold(H1, by khách 7) | Ném HoldNotActiveError mang Status = EXPIRED; ghế 101 vẫn HELD bởi H2; không ghi gì | R-63; X-13; X-18 | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-224 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 PAYMENT_FAILED | CancelHold(H1, by khách 7) | Ném HoldNotActiveError mang Status = PAYMENT_FAILED; không ghi gì | BR-86; UC-005 11a | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-225 | DC-BookTicketsService.ConfirmCashReceived | use case | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:05:00.000 | ConfirmCashReceived(H1, clerk 3) | Trả BookingView mã BK1 với 2 vé: ghế 101 giá 90.000 mã TKA, ghế 105 giá 120.000 mã TKB; H1 COMPLETED; hai ghế SOLD với currentTicket; InsertWithTickets 1 lần; IF-23.Enqueue 0 lần; Violated() = false | BR-44, BR-67, BR-80; UC-005 9a2 đến 9a4 (KB2) | EC-117, đường P77, CE211 đến CE212, CE214, CE216, CE218, CE220 đến CE225 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-226 | DC-BookTicketsService.ConfirmCashReceived | giá trị biên | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:09:59.999 | ConfirmCashReceived(H1, clerk 3) | Bán thành công; H1 COMPLETED | BR-44; UC-005 9a2 | BV-58 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-227 | DC-BookTicketsService.ConfirmCashReceived | giá trị biên | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:10:00.000 | ConfirmCashReceived(H1, clerk 3) | Ném HoldNotActiveError mang Status = EXPIRED (nhân viên được báo trả lại tiền mặt); H1 EXPIRED đã ghi; ghế 101, 105 AVAILABLE; InsertWithTickets 0 lần; không vé; cùng một commit | BR-44; UC-005 9a1a (KB8); Q-134; X-09 | EC-118, BV-59, đường P78, CE211 đến CE212, CE214, CE216 đến CE217, CE226 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-228 | DC-BookTicketsService.ConfirmCashReceived | chuyển trạng thái | H1 của nhân viên 3 CANCELLED | ConfirmCashReceived(H1, clerk 3) lúc 10:05:00 | Ném HoldNotActiveError mang Status = CANCELLED; không ghi gì; không vé | BR-86; X-09 | EC-119, đường P79, CE211 đến CE212, CE214, CE216, CE218 đến CE219, CE229 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-229 | DC-BookTicketsService.ConfirmCashReceived | phân vùng tương đương | Không có lần giữ ghế 9999 | ConfirmCashReceived(9999, clerk 3) | Ném NotFoundError; không ghi gì | P12 F2 | EC-121, đường P80, CE211 đến CE213, CE227 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Trung bình | Unit |
| TC-230 | DC-BookTicketsService.ConfirmCashReceived | phân vùng tương đương | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:05:00.000 | ConfirmCashReceived(H1, clerk 4) | Chưa xác định: chờ Q-147 | P12 F3 (không nêu lỗi) | EC-120, đường P81, CE211 đến CE212, CE214 đến CE215, CE228; không tính vào độ phủ (chờ Q-147) | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Trung bình | Unit |
| TC-231 | DC-BookTicketsService.ConfirmCashReceived | chuyển trạng thái | H1 đã COMPLETED bởi lần xác nhận trước (ghế SOLD) | ConfirmCashReceived(H1, clerk 3) lần hai lúc 10:05:00 | Ném HoldNotActiveError mang Status = COMPLETED; chỉ một Booking; không vé thứ hai | BR-24 (tương tự); BR-85, BR-86; Bảng hỏng M5 mục 4 (bấm lại) | EC-119 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-232 | DC-BookTicketsService.StartOnlinePayment | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); tx.Now = 10:05:00.000 | StartOnlinePayment(H1, by khách 7, clientIp 10.0.0.9) | Trả PaymentStart (địa chỉ từ IF-01); PaymentTransaction mới PENDING mã T1, số tiền 270.000, gắn H1; IF-01 gọi 1 lần với (T1, ref của H1, 270000, 10:10:00.000, 10.0.0.9) sau commit; H1 vẫn ACTIVE; ghế vẫn HELD | BR-90; UC-005 9, 10 (KB1); NFR-15 | EC-122, đường P82, CE230 đến CE231, CE233, CE235, CE237, CE239 đến CE241, CE243 đến CE244 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Cao | Unit |
| TC-233 | DC-BookTicketsService.StartOnlinePayment | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); đã gọi StartOnlinePayment một lần (txn T1 PENDING) | StartOnlinePayment(H1, by khách 7, 10.0.0.9) lần hai lúc 10:06:00 | Trả PaymentStart mới; tồn tại hai PaymentTransaction PENDING (T1, T2) cùng gắn H1; T1 không bị xoá hay sửa | BR-90 (thanh toán lại mỗi lần tạo bản ghi mới); P09 F7.6 | EC-122 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-234 | DC-BookTicketsService.StartOnlinePayment | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); tx.Now = 10:10:00.000 | StartOnlinePayment(H1, by khách 7, 10.0.0.9) | Ném HoldNotActiveError mang Status = EXPIRED; H1 EXPIRED đã ghi; PaymentTransaction mới 0; IF-01 0 lần; ghế vẫn HELD (SeatReleaseJob trả sau) | BR-86; UC-005 7b | EC-123, đường P83, CE230 đến CE231, CE233, CE235 đến CE236, CE245 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-235 | DC-BookTicketsService.StartOnlinePayment | chuyển trạng thái | Hold H1 CANCELLED | StartOnlinePayment(H1, by khách 7, 10.0.0.9) lúc 10:05:00 | Ném HoldNotActiveError mang Status = CANCELLED; PaymentTransaction mới 0; IF-01 0 lần | BR-86; UC-005 *a | EC-124, đường P84, CE230 đến CE231, CE233, CE235, CE237 đến CE238, CE248 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-236 | DC-BookTicketsService.StartOnlinePayment | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); IF-01 ném GatewayConfigurationError; tx.Now = 10:05:00.000 | StartOnlinePayment(H1, by khách 7, 10.0.0.9) | Ném GatewayConfigurationError; PaymentTransaction PENDING T1 vẫn tồn tại (đã commit); H1 vẫn ACTIVE; ghế vẫn HELD | BR-90; UC-005 10a | EC-125, đường P85, CE230 đến CE231, CE233, CE235, CE237, CE239 đến CE242, CE249 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-237 | DC-BookTicketsService.StartOnlinePayment | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); tx.Now = 10:05:00.000 | StartOnlinePayment(H1, by khách 8, 10.0.0.9) | Chưa xác định: chờ Q-147 | P12 F2, F3 (không nêu) | EC-126, đường P87, CE230 đến CE231, CE233 đến CE234, CE247; không tính vào độ phủ (chờ Q-147) | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-238 | DC-BookTicketsService.StartOnlinePayment | phân vùng tương đương | Không có lần giữ ghế 9999 | StartOnlinePayment(9999, by khách 7, 10.0.0.9) | Ném NotFoundError; IF-01 0 lần | P12 F2 | EC-127, đường P86, CE230 đến CE232, CE246 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-239 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED (00); H1 COMPLETED; ghế 101, 102 SOLD với currentTicket; 2 vé giá 90.000, 1 Booking; PT1 TICKETED, mã cổng GW1, paidAt 10:04:00; Enqueue(EMAIL_TICKET) 1 lần; CreateFullRefund 0 lần; Violated() = false | BR-37, BR-85; UC-005 11 đến 14 (KB1) | EC-132, DT6-R5, đường P88, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272, CE274, CE276, CE278, CE280, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-240 | DC-PaymentReportService.HandleIpn | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:09:59.999 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; bán ghế: H1 COMPLETED, PT1 TICKETED | BR-14 (còn trước hạn 1 ms); BR-85 | EC-132 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-241 | DC-PaymentReportService.HandleIpn | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:10:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; H1 EXPIRED (đã ghi); ghế 101, 102 AVAILABLE (Q-134); không vé, không Booking; PT1 LATE_PAYMENT; CreateFullRefund 1 lần với PT1; Enqueue(EMAIL_TICKET) 0 lần | BR-14; UC-006 (thanh toán trễ); X-09; Q-134 | EC-133, DT6-R6, đường P89, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE269, CE271 đến CE272, CE274, CE277, CE281, CE283, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-242 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 CANCELLED lúc 10:03:00 (expiry 10:10:00.000); ghế 101, 102 AVAILABLE; txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, mã cổng GW1, ref-1, amount 180000; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; H1 vẫn CANCELLED; PT1 LATE_PAYMENT; CreateFullRefund 1 lần; không vé | BR-15; BR-86; UC-005 *a, UC-006 | EC-133, DT6-R6, đường P90, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272, CE274, CE277, CE281, CE283, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-243 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; PT1 LATE_PAYMENT; CreateFullRefund 1 lần; H1 vẫn ACTIVE; ghế vẫn HELD (không bán) | BR-15; ST-05 STT 5; UC-006 | DT6-R6 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-244 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; ghế 102 có currentHold = H2 (liên kết ghế vỡ) | HandleIpn(params hợp lệ của r) | Trả PROCESSED; không bán ghế, không vé; PT1 LATE_PAYMENT với lateReason HOLD_LINK_BROKEN; CreateFullRefund 1 lần; ghi log lỗi nghiêm trọng; không rollback; ghế 102 vẫn HELD bởi H2 | P08 F4b EX-02 (Q-84); P09 F7.6 dòng 1 | đường P91, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272, CE274, CE276, CE279, CE283, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-245 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) (báo thành công lặp lại) | Trả DUPLICATE (02); PT1 TICKETED, duplicateReportCount = 1; không vé thứ hai; CreateFullRefund 0 lần | BR-37; UC-006 2a; X-09 | EC-134, DT6-R7, đường P92, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272 đến CE273, CE275, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-246 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) (báo trùng) | Trả DUPLICATE; duplicateReportCount = 1; CreateFullRefund 0 lần (mỗi giao dịch chỉ hoàn toàn bộ một lần) | BR-16 (gộp BR-37); BR-37; UC-006 2a | DT6-R7 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-247 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; PT1 là giao dịch tạo sau cùng của H1 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; PT1 FAILED, mã cổng vẫn rỗng; H1 PAYMENT_FAILED; ghế 101, 102 AVAILABLE trong cùng giao dịch; CreateFullRefund 0 lần | BR-39, BR-93; UC-005 11a; Q-134 | EC-135, DT6-R8, đường P93, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272, CE274, CE277, CE282, CE284 đến CE285, CE287, CE289 đến CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-248 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; có PT2 PENDING tạo sau PT1 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; PT1 FAILED; H1 vẫn ACTIVE; ghế vẫn HELD; PT2 vẫn PENDING | BR-93; UC-005 11a (giao dịch cũ) | DT6-R8, đường P94, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272, CE274, CE277, CE282, CE284, CE286, CE290 đến CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-249 | DC-PaymentReportService.HandleIpn | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:10:00.000 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; H1 EXPIRED (không PAYMENT_FAILED); ghế AVAILABLE; PT1 FAILED; CreateFullRefund 0 lần | BR-39; BR-86; UC-006 2c | đường P95, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE269, CE271 đến CE272, CE274, CE277, CE282, CE284 đến CE285, CE288, CE290 đến CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-250 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; PT1 vẫn TICKETED; H1 vẫn COMPLETED; ghế vẫn SOLD; CreateFullRefund 0 lần | BR-39; UC-006 2d | DT6-R8 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-251 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 ACTIVE như ca bán ghế; không có giao dịch nào mã LẠ-99; không có lần giữ ghế mang ref-lạ; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với giao dịch LẠ-99 và holdRef ref-lạ | Trả UNKNOWN_TRANSACTION (01); logUnrecognized 1 lần; Do 0 lần; không vé; CreateFullRefund 0 lần; Enqueue 0 lần | BR-38; UC-006 2e | EC-130, DT6-R3, đường P96, CE250, CE252, CE254 đến CE256, CE297 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-252 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); không có PaymentTransaction nào (StartOnlinePayment lỗi trước khi commit); báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với giao dịch 20260001 chưa tồn tại, ref-1 hợp lệ, amount 180000 | Trả PROCESSED; PaymentTransaction mới mã 20260001 được tạo từ báo rồi TICKETED; H1 COMPLETED; ghế SOLD | P09 F7.6 (tạo giao dịch từ báo); P12 Vấn đề còn mở 3 | đường P97, CE250, CE252, CE254, CE257 đến CE259, CE261, CE264 đến CE265, CE268, CE270, CE272, CE274, CE276, CE278, CE280, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-253 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); không có PaymentTransaction nào; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với giao dịch chưa tồn tại, ref-1, amount 170000 | Trả AMOUNT_MISMATCH (04); không tạo PaymentTransaction; H1 vẫn ACTIVE; ghế vẫn HELD; log 1 lần | BR-91; P09 F7.6 | EC-131, đường P98, CE250, CE252, CE254, CE257 đến CE259, CE261, CE263, CE298 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-254 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); không có PaymentTransaction nào; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:12:00.000; H1 EXPIRED, ghế AVAILABLE | HandleIpn(params hợp lệ của r) với giao dịch chưa tồn tại, amount 170000 | Trả PROCESSED; PaymentTransaction mới LATE_PAYMENT số tiền 170.000; CreateFullRefund 1 lần với 170.000 (không có giá để so) | BR-40; P09 F7.6 (hoàn theo số tiền cổng báo) | đường P99, CE250, CE252, CE254, CE257 đến CE259, CE262, CE265, CE268, CE270, CE272, CE274, CE277, CE281, CE283, CE291, CE293 đến CE294 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-255 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với amount 170000 | Trả AMOUNT_MISMATCH (04); PT1 PENDING; H1 ACTIVE; ghế HELD; không vé; CreateFullRefund 0 lần; log lỗi 1 lần | BR-91; UC-006 2f | DT6-R4, đường P100, CE250, CE252, CE254, CE257 đến CE258, CE260, CE266, CE298 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-256 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với chữ ký sai | Trả INVALID_SIGNATURE (97); mọi store 0 lần gọi; không ghi gì | NFR-16; P09 F7.6 | EC-128, DT6-R1, đường P101, CE250 đến CE251, CE295 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-257 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) thiếu tham số số tiền (chữ ký đúng) | Trả MALFORMED (99); mọi store 0 lần gọi | P12 F2 (MalformedReportError) | EC-129, DT6-R2, đường P102, CE250, CE252 đến CE253, CE296 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Trung bình | Unit |
| TC-258 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) vừa sai chữ ký vừa thiếu tham số | Trả INVALID_SIGNATURE (Verify chạy trước Decode) | P12 F2 DC-PaymentReportReceiver | DT6-R1 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Trung bình | Unit |
| TC-259 | DC-PaymentReportService.HandleIpn | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; fake IF-08.Do trả SystemBusyError sau hết lần thử | HandleIpn(params hợp lệ của r) | Trả TEMPORARY_FAILURE (99); H1 ACTIVE; PT1 PENDING; ghế HELD; không vé (rollback trọn) | P09 F7.6 (lỗi tạm thời); Bảng hỏng M5 mục 3 | EC-136, đường P103, CE250, CE252, CE254, CE257 đến CE258, CE260, CE267 đến CE268, CE270, CE272, CE274, CE276, CE278, CE280, CE291 đến CE292, CE299 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-260 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; amount báo 170000 | HandleIpn(báo thất bại của PT1, amount 170000) | Chưa xác định: chờ Q-146 | BR-91 (chỉ nêu báo thành công); BR-39 | DT6-R9; không tính vào độ phủ (chờ Q-146) | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-261 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(báo thành công trùng, amount 170000) | Chưa xác định: chờ Q-146 | BR-91 và BR-37 | DT6-R9; không tính vào độ phủ (chờ Q-146) | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-262 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(r) hai lần liên tiếp (cùng báo, 10:05:00 rồi 10:05:01) | Lần 1: PROCESSED, bán ghế. Lần 2: DUPLICATE, duplicateReportCount = 1; tổng cộng 1 Booking, 2 vé, Enqueue(EMAIL_TICKET) 1 lần | BR-37, BR-85; X-09 (hai thứ tự đến như nhau); Bảng hỏng M5 mục 3 | EC-134 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-263 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | Thứ tự A (X-10): HandleIpn(r) lúc 10:05:00 rồi CancelHold(H1) lúc 10:05:30 | HandleIpn: bán ghế. CancelHold: ném HoldNotActiveError mang Status = COMPLETED; ghế vẫn SOLD, 2 vé còn hiệu lực | BR-85, BR-86; X-10; X-12 | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-264 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | Thứ tự B (X-10): CancelHold(H1) lúc 10:05:00 rồi HandleIpn(r) lúc 10:05:30 | CancelHold: H1 CANCELLED, ghế AVAILABLE. HandleIpn: PROCESSED, PT1 LATE_PAYMENT, CreateFullRefund 1 lần, không vé | BR-15, BR-85, BR-86; X-10; UC-005 *a | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-265 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | Thứ tự C (X-10): HoldExpiryJob.RunDue lúc 10:10:30 rồi HandleIpn(r) lúc 10:11:00 (paidAt 10:09:00) | Job: H1 EXPIRED. HandleIpn: PT1 LATE_PAYMENT, hoàn toàn bộ 180.000; không vé (mốc hết hạn, không phải lúc ghế được trả) | BR-14, BR-86; X-10; UC-005 7b | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-266 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | Thứ tự D (X-10): HandleIpn(r) lúc 10:09:59.999 rồi HoldExpiryJob.RunDue lúc 10:10:30 | HandleIpn: bán ghế (H1 COMPLETED). Job: LockExpiredBatch không trả H1 (không còn ACTIVE), số hold hết hạn xử lý = 0; ghế vẫn SOLD | BR-85, BR-86; X-10; X-12 | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-267 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | giá trị biên | tx.Now = 10:10:00.000; không có lần giữ ghế nào quá hạn | RunDue(budget 8 giây) | Trả JobRunResult processed = 0; expireBatch 1 lần; cleanupEvents 1 lần với (10 phút, 200); ghế không đổi | NFR-07; P09 F7.4 (vòng lặp 0 hold) | EC-137, đường P104, CE300 đến CE301, CE303 đến CE304, CE308 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-268 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | giá trị biên | tx.Now = 10:10:00.000; 1 hold H1 ACTIVE expiry 10:09:00 | RunDue(budget 8 giây) | processed = 1; H1 EXPIRED; UpdateStatus 1 lần; expireBatch 1 lần; IF-18 0 lần gọi (ghế vẫn HELD) | BR-10, BR-86; NFR-07; ST-01 STT 3 | EC-138 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-269 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | giá trị biên | tx.Now = 10:10:00.000; 50 hold ACTIVE đã quá hạn | RunDue(budget 8 giây) | processed = 50, 50 hold EXPIRED; expireBatch 1 lần (lô 50 < 200) | P09 F7.4 (m điển hình) | EC-138 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-270 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | giá trị biên | tx.Now = 10:10:00.000; 199 hold quá hạn | RunDue(budget 8 giây) | processed = 199; expireBatch 1 lần | P09 F7.4 (n - 1) | EC-138 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-271 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | giá trị biên | tx.Now = 10:10:00.000; 200 hold quá hạn | RunDue(budget 8 giây) | processed = 200; expireBatch 2 lần (lô đầy nên chạy lô tiếp, lô hai trả 0); cleanupEvents 1 lần | P09 F7.4 (n) | EC-139, đường P105, CE300 đến CE301, CE303 đến CE305, CE307 đến CE308 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-272 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | giá trị biên | tx.Now = 10:10:00.000; 201 hold quá hạn | RunDue(budget 8 giây) | processed = 201; expireBatch 2 lần (200 rồi 1); mọi hold EXPIRED | P09 F7.4 (n + 1); NFR-07 (4.000 hold = 20 lô) | EC-139 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-273 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | phân vùng tương đương | tx.Now = 10:10:00.000; H5 ACTIVE expiry 10:10:30 được fake trả làm ứng viên | RunDue(budget 8 giây) | H5 vẫn ACTIVE; UpdateStatus 0 lần cho H5; processed không tính H5 | P12 F3 (UpdateStatus chỉ khi còn Đang giữ và Expire đổi) | EC-140 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Trung bình | Unit |
| TC-274 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | vòng lặp | tx.Now = 10:10:00.000; 250 hold quá hạn; đồng hồ giả: lô đầu tiên dùng hết 8 giây | RunDue(budget 8 giây) | expireBatch đúng 1 lần (không mở lô hai); 200 hold EXPIRED; 50 hold còn ACTIVE chờ lượt sau (chạy lặp an toàn) | P12 F3 (hết budget); Bảng hỏng M5 mục 6 | đường P106, CE300 đến CE301, CE303, CE305 đến CE306, CE308 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-275 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | vòng lặp | tx.Now = 10:10:00.000; 250 hold quá hạn; hết budget sau lô đầu | RunDue(budget 8 giây): cleanupEvents có được gọi không | Chưa xác định: chờ Q-148 | P12 F3 (không nêu ngữ cảnh của cleanupEvents); X1 RV-04 | không tính vào độ phủ (chờ Q-148) | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
| TC-276 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | phân vùng tương đương | tx.Now = 10:10:00.000; 400 hold quá hạn; expireBatch lô hai trả lỗi CSDL | RunDue(budget 8 giây) | Trả lỗi; 200 hold của lô đầu EXPIRED (đã commit); 200 hold còn ACTIVE; lượt sau xử lý tiếp | P12 F2 (lỗi CSDL); Bảng hỏng M5 mục 1 | EC-141, đường P107, CE300 đến CE303, CE305, CE307, CE309 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Trung bình | Unit |
| TC-277 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | use case | tx.Now = 10:10:00.000; H1 ACTIVE expiry 10:09:00 | RunDue lần một rồi RunDue lần hai | Lần hai: processed = 0; H1 vẫn EXPIRED (chạy lặp an toàn, hai bản backend quét chồng không đổi gì) | BR-86; X-10; P09 F7.4 | EC-137 | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Trung bình | Unit |
| TC-278 | DC-SeatReleaseJob.RunDue (releaseBatch) | giá trị biên | Không có lần giữ ghế đạt điều kiện | RunDue(budget 8 giây) | processed = 0; LockByHolds 0 lần; SaveChanges 0 lần; không dòng seat_event | REQ-76; P12 F3 | EC-142, đường P108, CE310 đến CE312, CE322 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-279 | DC-SeatReleaseJob.RunDue (releaseBatch) | use case | H1 EXPIRED, ghế 101, 102, 103 HELD bởi H1 | RunDue(budget 8 giây) | 3 ghế AVAILABLE; SaveChanges 1 lần với 3 ghế; thứ tự gọi: LockReleasableBatch rồi LockByHolds rồi SaveChanges; Violated() = false; processed = 3 | REQ-76; NFR-07; X-22; P09 F7.4 bước 2 | EC-143, đường P109, CE310 đến CE311, CE313 đến CE317, CE319 đến CE321 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-280 | DC-SeatReleaseJob.RunDue (releaseBatch) | use case | H1 EXPIRED giữ ghế 101; H3 PAYMENT_FAILED giữ ghế 102; ghế 105 HELD bởi H2 ACTIVE | RunDue(budget 8 giây) | Ghế 101, 102 AVAILABLE; ghế 105 vẫn HELD bởi H2 và không nằm trong danh sách SaveChanges | R-63; X-13; X-18 | EC-144 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-281 | DC-SeatReleaseJob.RunDue (releaseBatch) | phân vùng tương đương | H4 COMPLETED, ghế 110 SOLD với currentTicket | RunDue(budget 8 giây) | H4 không có trong lô; ghế 110 vẫn SOLD; SaveChanges 0 lần | BR-85; X-12 (không thể vừa bán vừa giải phóng) | EC-145 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-282 | DC-SeatReleaseJob.RunDue (releaseBatch) | use case | H1 EXPIRED, 3 ghế HELD bởi H1 | RunDue hai lần liên tiếp | Lần hai: processed = 0, SaveChanges 0 lần (liên kết đã xoá); ghế không đổi | X-18; P12 F3 (chạy lặp an toàn); Bảng hỏng M5 mục 5 | EC-142 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-283 | DC-SeatReleaseJob.RunDue (releaseBatch) | giá trị biên | 1 lần giữ ghế EXPIRED, mỗi lần giữ 1 ghế HELD | RunDue(budget 8 giây) | processed = 1; releaseBatch 1 lần; mọi ghế AVAILABLE | NFR-07; P09 F7.4 (4.000 lần giữ ghế hết hạn là 20 lô) | EC-143 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-284 | DC-SeatReleaseJob.RunDue (releaseBatch) | giá trị biên | 199 lần giữ ghế EXPIRED, mỗi lần giữ 1 ghế HELD | RunDue(budget 8 giây) | processed = 199; releaseBatch 1 lần (lô nhỏ hơn 200); mọi ghế AVAILABLE | NFR-07; P09 F7.4 (4.000 lần giữ ghế hết hạn là 20 lô) | EC-143 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-285 | DC-SeatReleaseJob.RunDue (releaseBatch) | giá trị biên | 200 lần giữ ghế EXPIRED, mỗi lần giữ 1 ghế HELD | RunDue(budget 8 giây) | processed = 200; releaseBatch 2 lần (lô đầy nên chạy lô hai trả 0); mọi ghế AVAILABLE | NFR-07; P09 F7.4 (4.000 lần giữ ghế hết hạn là 20 lô) | EC-143 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-286 | DC-SeatReleaseJob.RunDue (releaseBatch) | giá trị biên | 201 lần giữ ghế EXPIRED, mỗi lần giữ 1 ghế HELD | RunDue(budget 8 giây) | processed = 201; releaseBatch 2 lần (200 rồi 1); mọi ghế AVAILABLE | NFR-07; P09 F7.4 (4.000 lần giữ ghế hết hạn là 20 lô) | EC-143 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-287 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00:00.000 | CancelOnlineTicket(TK1, customer khách 7) | Trả CancelResult; TK1 CANCELLED; ghế 101 AVAILABLE; RequestTicketRefund 1 lần với (PT1, TK1, 70.000); 1 commit; thứ tự khoá ghi nhận LockByKey (6), LockPaymentOfTicket (7), LockTicketByID (8); Violated() = false | BR-17 đến BR-19, BR-21, BR-42; Q-133; UC-008 bước 4 đến 7 | EC-146, DT7-R1, đường P110, CE323 đến CE324, CE326 đến CE327, CE329 đến CE331, CE333, CE335, CE337, CE339 đến CE341, CE343, CE345 đến CE346, CE348, CE350 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-288 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 18:00:00.000 | CancelOnlineTicket(TK1, khách 7) | Huỷ thành công: TK1 CANCELLED; ghế AVAILABLE; hoàn 70.000 | BR-18, BR-32 (đúng 2 giờ) | BV-60 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-289 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 18:00:00.001 | CancelOnlineTicket(TK1, khách 7) | Ném CancelDeadlineError; TK1 UNUSED; ghế 101 SOLD; RequestTicketRefund 0 lần | BR-18, BR-32; UC-008 3a | EC-148, BV-61, DT7-R3, đường P115, CE323 đến CE324, CE326 đến CE327, CE329 đến CE331, CE333, CE335 đến CE336, CE354 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-290 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | phân vùng tương đương | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 20:30:00.000 (suất chiếu đã bắt đầu) | CancelOnlineTicket(TK1, khách 7) | Ném CancelDeadlineError; không ghi gì | BR-18; UC-008 3a (đã bắt đầu) | EC-148 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-291 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00 | CancelOnlineTicket(TK1, customer khách 8) | Ném ChannelMismatchError; TK1 UNUSED; ghế SOLD; không ghi gì | BR-17; UC-008 2a | EC-147, DT7-R2, đường P114, CE323 đến CE324, CE326 đến CE327, CE329 đến CE331, CE333 đến CE334, CE353 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-292 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK2 mua tại quầy (Booking của hold CLERK 3); ghế 102 SOLD; Showtime như trên; tx.Now = 17:00 | CancelOnlineTicket(TK2, customer khách 7) | Ném ChannelMismatchError; không ghi gì | BR-17; UC-008 2a (vé mua tại quầy) | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-293 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2 với TK1 đã CANCELLED (huỷ lần trước); tx.Now = 17:00 | CancelOnlineTicket(TK1, khách 7) lần hai | Ném TicketStateError mang CANCELLED; RequestTicketRefund 0 lần (không hoàn thêm); ghế không đổi | BR-21; UC-008 4a; X-15 | DT7-R4, đường P116, CE323 đến CE324, CE326 đến CE327, CE329 đến CE331, CE333, CE335, CE337 đến CE338, CE355 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-294 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2 với TK1 USED (đã soát); tx.Now = 17:00 | CancelOnlineTicket(TK1, khách 7) | Ném TicketStateError mang USED; TK1 vẫn USED; ghế vẫn SOLD; không hoàn | BR-30; UC-008 4b; X-14 | EC-149, DT7-R5 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-295 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; vé của khách 8 (khách 7 gọi) và tx.Now = 19:00 (quá hạn) | CancelOnlineTicket(TK1, khách 7) | Ném ChannelMismatchError (kênh kiểm trước hạn theo thứ tự bước 2 rồi bước 3) | UC-008 mục 3 (2a trước 3a); BR-17 | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-296 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2 với TK1 CANCELLED; tx.Now = 19:00 (quá hạn) | CancelOnlineTicket(TK1, khách 7) | Ném CancelDeadlineError (3a trước 4a) | UC-008 mục 3 (hạn kiểm ở bước 3 trước bước 4) | DT7-R3 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-297 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00; RequestTicketRefund ném RefundLimitError | CancelOnlineTicket(TK1, khách 7) | Ném RefundLimitError; TK1 vẫn UNUSED; ghế 101 vẫn SOLD (rollback trọn, không có vé huỷ mà khách mất tiền không dấu vết) | BR-26; Q-133; X-16 | EC-150, đường P117, CE323 đến CE324, CE326 đến CE327, CE329 đến CE331, CE333, CE335, CE337, CE339 đến CE341, CE343, CE345 đến CE347, CE356 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-298 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; ghế 101 đã bán lại bằng vé TK9 (currentTicket = TK9) | CancelOnlineTicket(TK1, khách 7) lúc 17:00 | TK1 CANCELLED; ghế 101 vẫn SOLD bởi TK9; SaveChanges 0 lần; RequestTicketRefund 1 lần | BR-42; R-64; X-18 | EC-151, đường P111, CE323 đến CE324, CE326 đến CE327, CE329 đến CE331, CE333, CE335, CE337, CE339 đến CE340, CE342, CE345 đến CE346, CE348, CE350 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-299 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK1 ghế 101 giá 45.001 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00 | CancelOnlineTicket(TK1, khách 7) | RequestTicketRefund nhận amount 31.500 (70% của 45.001 làm tròn xuống) | BR-19, BR-31; UC-008 5 | EC-146 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-300 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | phân vùng tương đương | Không có vé mã 9999 | CancelOnlineTicket(9999, khách 7) | Ném NotFoundError; không ghi gì | P12 F2 | đường P112, CE323 đến CE325, CE351 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Trung bình | Unit |
| TC-301 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | phân vùng tương đương | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; LockTicketByID ném SystemBusyError | CancelOnlineTicket(TK1, khách 7) | Ném SystemBusyError; TK1 UNUSED; ghế SOLD | P09 F7.3; P12 F2 | đường P113, CE323 đến CE324, CE326 đến CE327, CE329 đến CE332, CE352 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Trung bình | Unit |
| TC-302 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK2 giá 100.000 UNUSED thuộc Booking BK2 của hold CLERK 3 (cụm rạp 2); ghế 102 SOLD; Showtime 55; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4 của cụm rạp 2) | TK2 CANCELLED; ghế 102 AVAILABLE; IF-21.Insert 1 lần với yêu cầu hoàn TICKET_CASH, REFUNDED, 70.000; LockPaymentOfTicket 0 lần (không hạng 7); IF-23.Enqueue 0 lần; IF-01 0 lần; 1 commit; Violated() = false | BR-17 đến BR-21, BR-42; UC-008 5a1, 5a2 (KB: huỷ tại quầy) | EC-152, đường P118, CE323 đến CE324, CE326 đến CE328, CE331, CE333, CE335, CE337, CE339 đến CE341, CE343 đến CE344, CE349 đến CE350 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-303 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00 | ConfirmCashRefund(TK1, clerk 4) | Ném ChannelMismatchError (vé mua trực tuyến); không ghi gì | BR-17; UC-008 2b | DT7-R2, đường P119, CE323 đến CE324, CE326 đến CE328, CE331, CE333 đến CE334, CE353 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-304 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK2 mua tại quầy của cụm rạp 3; Showtime 55 thuộc cụm rạp 3; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4 của cụm rạp 2) | Ném ChannelMismatchError (vé quầy của cụm rạp khác); không ghi gì. Lưu ý: P12 F3 không nêu lời gọi so cụm rạp nên TC này sẽ thất bại trên thiết kế hiện hành (Đề xuất sửa P12 dòng 10) | BR-17; UC-008 2c | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-305 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK2 mua tại quầy UNUSED, ghế 102 SOLD; Showtime 55 bắt đầu 20:00; tx.Now = 18:00:00.001 | ConfirmCashRefund(TK2, clerk 4) | Ném CancelDeadlineError; không ghi gì | BR-18 (áp dụng cả vé quầy); UC-008 3a | DT7-R3 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-306 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK2 mua tại quầy, USED; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4) | Ném TicketStateError mang USED; không tạo yêu cầu hoàn tiền mặt; ghế vẫn SOLD | BR-30; UC-008 4b | DT7-R5 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-307 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK2 quầy, ghế 102 đã bán lại bằng TK9; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4) | TK2 CANCELLED; ghế 102 vẫn SOLD bởi TK9; SaveChanges 0 lần; IF-21.Insert 1 lần (REFUNDED, 70.000) | BR-42; R-64 | đường P120, CE323 đến CE324, CE326 đến CE328, CE331, CE333, CE335, CE337, CE339 đến CE340, CE342, CE344, CE349 đến CE350 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-308 | DC-CheckTicketService.CheckTicket | use case | Vé TK1 mã QR1 của suất 55 (cụm rạp 2), UNUSED | CheckTicket(QR1, showtime 55, checker cụm rạp 2) | Trả ADMITTED (kèm mã đặt vé và vị trí ghế); TK1 USED; UpdateTicketStatus 1 lần; 1 commit | BR-22 đến BR-24; UC-009 4, 5 (KB chính) | EC-153, đường P121, CE357 đến CE358, CE360 đến CE361, CE363 đến CE365, CE367 đến CE368 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-309 | DC-CheckTicketService.CheckTicket | bảng quyết định | Vé TK1 mã QR1 của suất 55 (cụm rạp 2), UNUSED | CheckTicket(QR1, showtime 55, checker cụm rạp 3) | Trả WRONG_CINEMA; TK1 vẫn UNUSED; UpdateTicketStatus 0 lần | BR-22; UC-009 4b | EC-154, đường P122, CE357 đến CE358, CE360 đến CE361, CE363 đến CE364, CE366, CE368 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-310 | DC-CheckTicketService.CheckTicket | bảng quyết định | Vé TK1 mã QR1 của suất 55 (cụm rạp 2), UNUSED | CheckTicket(QR1, showtime 56, checker cụm rạp 2) | Trả WRONG_SHOWTIME; TK1 UNUSED; UpdateTicketStatus 0 lần | BR-23; UC-009 4c | EC-154 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-311 | DC-CheckTicketService.CheckTicket | bảng quyết định | Vé TK1 đã USED (soát một lần) | CheckTicket(QR1, showtime 55, checker cụm rạp 2) | Trả ALREADY_USED; TK1 vẫn USED; UpdateTicketStatus 0 lần | BR-24; UC-009 4d | EC-154 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-312 | DC-CheckTicketService.CheckTicket | bảng quyết định | Vé TK1 CANCELLED | CheckTicket(QR1, showtime 55, checker cụm rạp 2) | Trả CANCELLED; TK1 vẫn CANCELLED; UpdateTicketStatus 0 lần | BR-25; UC-009 4e | EC-154 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-313 | DC-CheckTicketService.CheckTicket | phân vùng tương đương | Không có vé mã QR-LẠ | CheckTicket(QR-LẠ, showtime 55, checker cụm rạp 2) | Ném NotFoundError; không ghi gì | UC-009 4a; NFR-14 | EC-155, đường P123, CE357 đến CE359, CE369 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-314 | DC-CheckTicketService.CheckTicket | use case | Vé TK1 mã QR1 của suất 55 (cụm rạp 2), UNUSED | CheckTicket(QR1, 55, cụm rạp 2) hai lần liên tiếp | Lần 1: ADMITTED. Lần 2: ALREADY_USED; UpdateTicketStatus tổng cộng 1 lần | BR-24; X-15 (hai thứ tự đến như nhau ở mức tuần tự); UC-009 4d | EC-154 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-315 | DC-CheckTicketService.CheckTicket | use case | Vé TK1 mã QR1 của suất 55 (cụm rạp 2), UNUSED; vừa huỷ ở UC-008 (Cancel) | CheckTicket(QR1, 55, cụm rạp 2) sau CancelOnlineTicket(TK1) | Trả CANCELLED; UpdateTicketStatus 0 lần (vé vừa huỷ không soát được) | BR-25, BR-30; X-14 (thứ tự huỷ trước soát); UC-009 4e | EC-154 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-316 | DC-CheckTicketService.CheckTicket | use case | Vé TK1 mã QR1 của suất 55 (cụm rạp 2), UNUSED; vừa được soát (ADMITTED) | CancelOnlineTicket(TK1, khách 7) sau CheckTicket thành công lúc 17:00 | Ném TicketStateError mang USED; ghế vẫn SOLD (thứ tự soát trước huỷ) | BR-30; X-14; UC-008 4b | EC-154 | fake IF-08/11/20, stub IF-25 | Cao | Unit |
| TC-317 | DC-RefundService.CreateFullRefund, RequestTicketRefund | use case | PaymentTransaction PT1 mã 20260001 LATE_PAYMENT hoặc TICKETED, amount 100.000, refundedTotal 0 | CreateFullRefund(tx, PT1) | IF-21.Insert 1 lần với yêu cầu FULL (khoá 20260001-FULL, NEW, 100.000); AddRefunded(PT1, 100.000) 1 lần; Enqueue(REFUND_GATEWAY, idempotencyKey 20260001-FULL) 1 lần; Enqueue(EMAIL_REFUND) 0 lần; Do 0 lần | BR-14, BR-26, BR-43; UC-006 3, 4 | EC-156 | mock IF-19/21/23/08, đối tượng thật DC-PaymentTransaction/DC-RefundRequest | Cao | Unit |
| TC-318 | DC-RefundService.CreateFullRefund, RequestTicketRefund | phân vùng tương đương | PaymentTransaction PT1 amount 100.000, refundedTotal 70.000 | CreateFullRefund(tx, PT1) | Ném RefundLimitError; Insert 0 lần; AddRefunded 0 lần; Enqueue 0 lần | BR-26; X-16 | EC-157 | mock IF-19/21/23/08, đối tượng thật DC-PaymentTransaction/DC-RefundRequest | Cao | Unit |
| TC-319 | DC-RefundService.CreateFullRefund, RequestTicketRefund | use case | PT1 TICKETED amount 200.000, refundedTotal 0; vé 9 giá 90.000 | RequestTicketRefund(tx, PT1, vé 9, 63.000) | Insert 1 lần (TICKET_GATEWAY, khoá 20260001-T9, 63.000); AddRefunded(PT1, 63.000) 1 lần; Enqueue(REFUND_GATEWAY) 1 lần; Do 0 lần; IF-01 0 lần | BR-19, BR-26, BR-43; UC-008 5 | EC-156 | mock IF-19/21/23/08, đối tượng thật DC-PaymentTransaction/DC-RefundRequest | Cao | Unit |
| TC-320 | DC-RefundService.CreateFullRefund, RequestTicketRefund | giá trị biên | PT1 amount 100.000, refundedTotal 37.000 | RequestTicketRefund(tx, PT1, vé 9, 63.000) | Thành công (tổng 100.000 bằng đúng số đã thanh toán) | BR-26 | BV-62 | mock IF-19/21/23/08, đối tượng thật DC-PaymentTransaction/DC-RefundRequest | Cao | Unit |
| TC-321 | DC-RefundService.CreateFullRefund, RequestTicketRefund | giá trị biên | PT1 amount 100.000, refundedTotal 37.001 | RequestTicketRefund(tx, PT1, vé 9, 63.000) | Ném RefundLimitError; Insert 0 lần; Enqueue 0 lần | BR-26; X-16 | BV-63 | mock IF-19/21/23/08, đối tượng thật DC-PaymentTransaction/DC-RefundRequest | Cao | Unit |
| TC-322 | DC-RefundService.CreateFullRefund, RequestTicketRefund | phân vùng tương đương | PT1 amount 100.000, refundedTotal 0 trong bộ nhớ; IF-19.AddRefunded trả RefundLimitError (bên khác vừa cộng) | RequestTicketRefund(tx, PT1, vé 9, 63.000) | Ném RefundLimitError; bên gọi rollback; Enqueue 0 lần hoặc bị rollback cùng giao dịch | BR-26; X-16 (lưới an toàn ở câu UPDATE) | EC-158 | mock IF-19/21/23/08, đối tượng thật DC-PaymentTransaction/DC-RefundRequest | Cao | Unit |
| TC-323 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW, attemptCount 0 | ProcessRefund(E1); IF-01.RequestRefund trả SUCCEEDED | RR1 REFUNDED, attemptCount 1; FindRefund 0 lần; RequestRefund 1 lần với (20260001-FULL, 20260001, paidAt 10:04:00, 100000, 100000); Enqueue(EMAIL_REFUND) 1 lần; MarkSucceeded 1 lần; trả nil | BR-41, BR-43; UC-006 4 đến 6 (hoàn toàn bộ) | EC-159, EC-164, BV-68, DT8-R4, đường P124, CE371 đến CE372, CE374, CE376, CE378 đến CE379, CE381, CE390 đến CE393, CE395, CE397, CE400, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-324 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 TICKET_GATEWAY của PT1 và vé 9 (mã 20260001, paidAt 10:04:00, 63.000), khoá 20260001-T9; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00 | ProcessRefund(E1); RequestRefund trả SUCCEEDED | RR1 REFUNDED; Enqueue(EMAIL_REFUND) 0 lần (huỷ vé UC-008 không email); MarkSucceeded 1 lần | BR-41; UC-008 5, 6; P09 F7.7 (thứ tự email) | đường P125, CE371 đến CE372, CE374, CE376, CE378 đến CE379, CE381, CE390 đến CE393, CE396, CE400, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-325 | DC-RefundService.ProcessRefund | bảng quyết định | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW | ProcessRefund(E1); RequestRefund trả REJECTED | RR1 WAITING_RETRY, attemptCount 1; Reschedule(1 phút) 1 lần; FindRefund 0 lần; email 0; MarkExhausted 0 | BR-41; UC-006 5a; UC-008 6a; ST-04 STT 8 | EC-165, DT8-R5, đường P126, CE371 đến CE372, CE374, CE376, CE378 đến CE379, CE381, CE390 đến CE392, CE394, CE398, CE401, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-326 | DC-RefundService.ProcessRefund | bảng quyết định | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW | ProcessRefund(E1); RequestRefund trả UNKNOWN (hết 30 giây) | RR1 WAITING_RETRY, attemptCount 1; Reschedule(1 phút); không gửi lại ngay | BR-43; UC-006 4a; UC-008 5b | DT8-R5 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-327 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1 | ProcessRefund(E1); FindRefund trả NOT_REFUNDED; RequestRefund trả REJECTED | BeginAttempt --> attemptCount 2; FindRefund trước RequestRefund; RequestRefund dùng cùng khoá 20260001-FULL; RR1 WAITING_RETRY; Reschedule(5 phút) | BR-41, BR-43; Q-118; UC-006 4t(ii), 5a; UC-008 5t | EC-160, EC-162, DT8-R9, đường P127, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE383 đến CE384, CE386, CE388, CE390 đến CE392, CE394, CE398, CE401, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-328 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1 | ProcessRefund(E1); FindRefund trả NOT_REFUNDED; RequestRefund trả SUCCEEDED | RR1 REFUNDED; RequestRefund 1 lần; email (FULL) 1 lần | BR-41; UC-006 4t(ii) | DT8-R8, đường P137, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE383 đến CE384, CE386, CE388, CE390 đến CE393, CE395, CE397, CE400, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-329 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1 | ProcessRefund(E1); FindRefund trả REFUNDED | RR1 REFUNDED; RequestRefund 0 lần (không hoàn hai lần); Enqueue(EMAIL_REFUND) 1 lần; MarkSucceeded | BR-41, BR-43; UC-006 4t(i); Bảng hỏng M5 mục 2 | EC-161, DT8-R7, đường P128, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE383 đến CE385, CE392 đến CE393, CE395, CE397, CE400, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-330 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1 | ProcessRefund(E1); FindRefund trả NOT_SUPPORTED | RR1 MANUAL_REQUIRED (MarkManualRequired ở giao dịch riêng); RequestRefund 0 lần; MarkSucceeded 1 lần; log 1 dòng; email 0 | BR-41; Q-118; UC-006 4t(iv), 4b; UC-008 5c | EC-163, DT8-R11, đường P129, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE383 đến CE384, CE386 đến CE387, CE407 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-331 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1 | ProcessRefund(E1); FindRefund trả UNREACHABLE | RR1 MANUAL_REQUIRED; RequestRefund 0 lần; MarkSucceeded 1 lần | BR-41; UC-006 4t(iv) | DT8-R11 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-332 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 2 | ProcessRefund(E1); FindRefund NOT_REFUNDED; RequestRefund UNKNOWN | attemptCount 3; RR1 WAITING_RETRY (còn 1 lần); Reschedule(15 phút) | BR-41; P09 F7.7 (1, 5, 15 phút) | BV-64, DT8-R10 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-333 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 3 | ProcessRefund(E1); FindRefund NOT_REFUNDED; RequestRefund UNKNOWN | attemptCount 4; RR1 MANUAL_REQUIRED; MarkExhausted 1 lần; Reschedule 0 lần; email 0; log 1 dòng (mã yêu cầu hoàn, mã giao dịch, số tiền) | BR-41; UC-006 5b; UC-008 6b; ST-04 STT 9, F6.4 | BV-65, DT8-R10, đường P130, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE383 đến CE384, CE386, CE388, CE390 đến CE392, CE394, CE399, CE402, CE404, CE408 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-334 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim ném ClaimLostError (bản khác đã nhận claim) | ProcessRefund(E1) | Trả ClaimLostError; RR1 vẫn NEW, attemptCount 0 (rollback); IF-01 0 lần; MarkSucceeded 0 lần | P09 F7.7 (hàng rào claim_token); T5b | EC-166, DT8-R1, đường P131, CE371 đến CE373, CE409 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-335 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; RequestRefund trả SUCCEEDED; MarkSucceeded ném ClaimLostError (claim bị bản khác nhận trong lúc chờ cổng) | ProcessRefund(E1) | Trả ClaimLostError; ghi kết quả bị rollback: RR1 vẫn IN_FLIGHT, attemptCount 1; IF-01.RequestRefund đã gọi 1 lần; email 0 | P09 F7.7 bước 3; Bảng hỏng M5 mục 3 (lần thử cũ khi lần mới đang chạy) | EC-167, đường P132, CE371 đến CE372, CE374, CE376, CE378 đến CE379, CE381, CE390 đến CE393, CE396, CE400, CE403, CE412 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-336 | DC-RefundService.ProcessRefund | bảng quyết định | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 REFUNDED (dòng được giao lại) | ProcessRefund(E1) | MarkSucceeded 1 lần; BeginAttempt 0; IF-01 0 lần; trả nil | P12 F3 bước 1; Bảng hỏng M5 mục 3 (sự kiện đến trùng) | EC-168, DT8-R2, đường P133, CE371 đến CE372, CE374 đến CE375, CE405 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-337 | DC-RefundService.ProcessRefund | bảng quyết định | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 MANUAL_REQUIRED | ProcessRefund(E1) | MarkSucceeded 1 lần; IF-01 0 lần; RR1 vẫn MANUAL_REQUIRED | Q-135; P12 F3 bước 1 | DT8-R2 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-338 | DC-RefundService.ProcessRefund | use case | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 IN_FLIGHT, attemptCount 2 (tiến trình chết sau BeginAttempt lần hai; claim cũ hết hạn) | ProcessRefund(E1); FindRefund NOT_REFUNDED; RequestRefund SUCCEEDED | attemptCount 3; FindRefund được gọi trước RequestRefund (bắt buộc tra cứu khi nhận lại); RR1 REFUNDED | Q-118; P09 F7.7 bước 4; Bảng hỏng M5 mục 1, 2 | DT8-R8 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-339 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 IN_FLIGHT, attemptCount 4 (nhận lại claim) | ProcessRefund(E1) | RR1 MANUAL_REQUIRED (MarkManualRequired); log 1 dòng; MarkSucceeded 1 lần; BeginAttempt 0; IF-01 0 lần | BR-41; ST-04 STT 10; P12 F3 bước 1 | EC-169, DT8-R3, đường P134, CE371 đến CE372, CE374, CE376 đến CE377, CE406 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-340 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim trả claimedUntil = tx.Now + 9,999 giây | ProcessRefund(E1) | IF-01.RequestRefund 0 lần; không ghi sau giao dịch 1; RR1 IN_FLIGHT attemptCount 1 (đã commit ở giao dịch 1) | P12 F3 bước 2 (còn dưới 10 giây thì thôi); Bảng hỏng M5 mục 5 | EC-170, BV-66, đường P135, CE371 đến CE372, CE374, CE376, CE378 đến CE379, CE381, CE389, CE411 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-341 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim trả claimedUntil = tx.Now + 9,999 giây | ProcessRefund(E1): giá trị trả về | Chưa xác định: chờ Q-150 | P12 F2, F3 (không nêu) | không tính vào độ phủ (chờ Q-150) | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-342 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1; claim còn 9 giây trước FindRefund | ProcessRefund(E1) | IF-01 0 lần (cả FindRefund lẫn RequestRefund); không ghi sau giao dịch 1 | P12 F3 bước 2 (kiểm mốc trước mỗi lời gọi) | đường P136, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE382, CE410 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-343 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; claim còn 10,001 giây | ProcessRefund(E1) | Chưa xác định: chờ Q-149 | P12 F3 bước 2 (biên 10 giây trùng) | BV-67; không tính vào độ phủ (chờ Q-149) | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-344 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; claim còn 120 giây (ExtendClaim trả tx.Now + 120 giây) | ProcessRefund(E1) | ctx của RequestRefund có deadline 30 giây | BR-43; P12 F3 bước 2 | EC-171, BV-68 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-345 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim trả claimedUntil = tx.Now + 35 giây | ProcessRefund(E1) | ctx của RequestRefund có deadline 25 giây (35 trừ biên 10) | P12 F3 bước 2 | BV-69 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-346 | DC-CancelTicketService.FindBooking | phân vùng tương đương | Booking BK1 mua tại quầy cụm rạp 2, hai vé giá 100.000 và 90.000 UNUSED | FindBooking(BK1, nhân viên quầy cụm rạp 2) | Trả BookingView với 2 vé; số tiền hoàn nếu huỷ 70.000 và 63.000; không ghi gì | BR-19, BR-31; UC-008 1a2 (Dữ liệu ra 2) | EC-172 | fake IF-20 | Cao | Unit |
| TC-347 | DC-CancelTicketService.FindBooking | phân vùng tương đương | Không có lần đặt BK-LẠ | FindBooking(BK-LẠ, nhân viên quầy cụm rạp 2) | Ném NotFoundError | UC-008 1a1a | EC-173 | fake IF-20 | Cao | Unit |
| TC-348 | DC-CancelTicketService.FindBooking | phân vùng tương đương | Booking BK2 mua tại quầy cụm rạp 3 | FindBooking(BK2, nhân viên quầy cụm rạp 2) | Ném ChannelMismatchError | BR-17; UC-008 2c | EC-174 | fake IF-20 | Cao | Unit |
| TC-349 | DC-CancelTicketService.FindBooking | phân vùng tương đương | Booking BK3 mua trực tuyến | FindBooking(BK3, nhân viên quầy cụm rạp 2) | Ném ChannelMismatchError | BR-17; UC-008 2b | EC-175 | fake IF-20 | Cao | Unit |
| TC-350 | DC-CheckTicketService.StartChecking | phân vùng tương đương | Suất 55 thuộc cụm rạp 2 | StartChecking(55, nhân viên soát vé cụm rạp 2) | Trả ShowtimeInfo của suất 55 | BR-34; UC-009 3 | EC-176 | fake IF-20 | Cao | Unit |
| TC-351 | DC-CheckTicketService.StartChecking | phân vùng tương đương | Suất 77 thuộc cụm rạp 3 | StartChecking(77, nhân viên soát vé cụm rạp 2) | Ném ChannelMismatchError | BR-34 | EC-177 | fake IF-20 | Cao | Unit |
| TC-352 | DC-CheckTicketService.StartChecking | phân vùng tương đương | Không có suất 9999 | StartChecking(9999, nhân viên soát vé cụm rạp 2) | Ném NotFoundError | P12 F2 | EC-178 | fake IF-20 | Cao | Unit |
| TC-353 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Mật khẩu đã băm bằng bộ băm của hệ thống: hash("Abc@1234") | VerifyPassword("Abc@1234", hash) | Trả (true, nil) | NFR-01, NFR-02 | - | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-354 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Như trên | VerifyPassword("Abc@12345", hash) | Trả (false, nil) | NFR-01; UC-005 5a2a | - | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-355 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Không có | VerifyPassword("Abc@1234", "") | Ném MalformedHashError | P12 F2 | EC-185 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-356 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | now = 2026-11-10 08:00:00 | IssueSession("7", CUSTOMER, "") | IssuedSession.expiresAt = 2026-11-11 08:00:00 (24 giờ) | Q-129 | EC-179 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-357 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | now = 2026-11-10 08:00:00 | IssueSession("3", BOX_OFFICE_CLERK, "2") | IssuedSession.expiresAt = 2026-11-10 16:00:00 (8 giờ) | Q-129; NFR-02 | EC-180 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-358 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | now = 2026-11-10 08:00:00 | IssueSession("1", ADMINISTRATOR, "") | Chưa xác định: chờ Q-153 | NFR-03 (không nêu hạn) | EC-181; không tính vào độ phủ (chờ Q-153) | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-359 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Phiên của nhân viên quầy 3 cụm rạp 2 cấp lúc 08:00:00 | VerifySession(token) lúc 15:59:59.999 | Trả SessionClaims{subjectId 3, role BOX_OFFICE_CLERK, cinemaId 2, expiresAt 16:00:00} | Q-129 | EC-182 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-360 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Như trên | VerifySession(token đã đổi một ký tự) | Ném SessionInvalidError | P12 F2 | EC-183 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-361 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | Như trên | VerifySession(token) lúc 16:00:01 | Ném SessionExpiredError | Q-129; P12 F2 | EC-184 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-362 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | Như trên | VerifySession(token) lúc đúng 16:00:00.000 | Chưa xác định: chờ Q-154 | Q-129 (không nêu biên) | không tính vào độ phủ (chờ Q-154) | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-363 | DC-BookTicketsService.HoldSeats | tích hợp đồng thời (X-01) | Suất 55, ghế 101..103 AVAILABLE; khách 7 và khách 8 không có lần giữ ghế | Hai goroutine cùng gọi HoldSeats ghế [101,102,103] sau barrier; lặp 1.000 lần (mỗi lần reset dữ liệu) | Đúng một lần gọi thành công, lần kia SeatUnavailableError (LOCKED_BY_OTHER hoặc NOT_AVAILABLE) và không giữ ghế nào; mỗi ghế có currentHold của bên thắng; không lỗi 40P01; không có ghế thuộc hai lần giữ ghế ACTIVE | BR-07, BR-09; X-01; P09 F7.9 T4 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-364 | DC-BookTicketsService.HoldSeats | tích hợp đồng thời (X-01, hai thứ tự đến) | Như trên | Thứ tự A: lần gọi 1 commit xong rồi lần gọi 2 bắt đầu. Thứ tự B: lần gọi 2 bắt đầu khi lần gọi 1 còn giữ khoá ghế (hook giữ giao dịch) | A: lần gọi 2 nhận SeatUnavailableError(NOT_AVAILABLE) sau khi khoá. B: lần gọi 2 nhận SeatUnavailableError(LOCKED_BY_OTHER) ngay, không chờ. Cả hai: bên thua không giữ ghế nào | BR-07, BR-09; X-01; P09 F7.3 EX-01 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-365 | DC-BookTicketsService.HoldSeats | tích hợp đồng thời (X-02) | Khách 7 chưa có lần giữ ghế; suất 55 và suất 56 mỗi suất có ghế trống | Hai goroutine cùng khách 7 gọi HoldSeats suất 55 và suất 56 sau barrier; lặp 1.000 lần | Đúng một lần thành công, lần kia HolderBusyError; khách 7 có đúng 1 lần giữ ghế ACTIVE; chỉ mục uq_seat_hold_active_customer không bị kích hoạt (23505 không xảy ra) | BR-04; X-02; UC-005 7c (KB6) | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-366 | DC-BookTicketsService.HoldSeats | tích hợp đồng thời (tải) | Suất 55 có 100 ghế; 1.000 khách khác nhau; 2 bản backend; seat_event bật | 1.000 HoldSeats song song với nhóm 1 đến 8 ghế chồng lấn; thêm lượt 100 yêu cầu ở tải thường | Không có 40P01; không ghế nào có hai lần giữ ghế ACTIVE; mọi kết quả (kể cả từ chối) không quá 1,8 giây ở tải thường, p95 dưới 2 giây ở tải đỉnh | NFR-05, NFR-06; BR-09; P09 F7.9 T1, T4 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-367 | DC-BookTicketsService.HoldSeats | tích hợp (EX-01 NOWAIT) | Ghế 101 đang bị giao dịch của harness khoá FOR NO KEY UPDATE trong 5 giây | HoldSeats ghế [101] của khách 7 | Trả SeatUnavailableError(LOCKED_BY_OTHER) trong dưới 200 ms (không chờ lock_timeout 1 giây); không thử lại; không có lần giữ ghế mới | BR-09; P09 F7.3 EX-01; NFR-06 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-368 | DC-BookTicketsService.HoldSeats | tích hợp (Q-134 và trigger P13) | Khách 7 có H0 ACTIVE đã quá hạn (expiry 10:10:00), H0 giữ ghế 101; tx.Now sau 10:10:00; job chưa chạy | HoldSeats ghế [101,102] của khách 7 (chọn lại đúng ghế của lần giữ ghế cũ) | Thành công: H0 EXPIRED; ghế 101 HELD bởi hold mới; không check_violation. P12 1.5 ghi Trống bằng một SaveChanges riêng rồi mới HoldFor và SaveChanges lần hai, vì trg_seat_status_link (P13-schema.sql) từ chối một UPDATE đổi liên kết hiện tại từ giá trị này sang giá trị khác; ca này xác nhận luồng hai lượt chạy được | Q-134; P12 F3 (g); P13 fn_seat_status_link_guard; Đề xuất sửa P12/P13 dòng 5 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-369 | DC-BookTicketsService.HoldSeats | tích hợp (thông điệp ghế đang được trả) | Ghế 101 HELD bởi H0 đã EXPIRED, SeatReleaseJob đang giữ khoá ghế (hook) | HoldSeats ghế [101] của khách 8 trong lúc job giữ khoá | Trả SeatUnavailableError(BEING_RELEASED) (MSG-82), không phải LOCKED_BY_OTHER; sau khi job commit, HoldSeats lại thành công | X-13; P12 F3 (g); P09 F7.3 EX-01 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-370 | DC-PaymentReportService.HandleIpn | tích hợp đồng thời (X-09, T4) | H1 ACTIVE, PT1 PENDING; hai bản backend | Hai IPN thành công giống hệt đến đồng thời ở hai bản sau barrier; lặp 1.000 lần | Đúng một Booking, đúng một vé mỗi ghế; một lần trả PROCESSED và một lần DUPLICATE; duplicateReportCount = 1; không 40P01; chỉ mục uq_payment_transaction_ticketed_hold không bị kích hoạt | BR-37, BR-85; X-09; P09 F7.9 T4; Bảng hỏng M5 mục 3 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-371 | DC-PaymentReportService.HandleIpn | tích hợp đồng thời (X-10, hai thứ tự đến) | H1 ACTIVE giữ ghế 101, 102; PT1 PENDING | IPN thành công và CancelHold(H1) cùng lúc. Thứ tự A: IPN giữ khoá hạng 5 trước (hook). Thứ tự B: CancelHold giữ khoá trước | A: IPN bán ghế (H1 COMPLETED), CancelHold nhận HoldNotActiveError(COMPLETED), ghế SOLD. B: H1 CANCELLED, ghế AVAILABLE, IPN ghi thanh toán trễ và tạo RefundRequest FULL. Không có trạng thái vừa bán vừa trả ghế | BR-15, BR-85, BR-86; X-10; X-12 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-372 | DC-PaymentReportService.HandleIpn | tích hợp đồng thời (X-10, mốc hết hạn) | H1 ACTIVE expiry E; PT1 PENDING; HoldExpiryJob chạy | IPN thành công đến sát E (một lần trước E, một lần sau E) đồng thời HoldExpiryJob | Báo nhận trước E (theo đồng hồ CSDL): COMPLETED; từ E trở đi: LATE_PAYMENT và hoàn toàn bộ; job không đổi H1 đã COMPLETED; không có kết cục thứ ba | BR-14, BR-85, BR-86; X-10; NFR-07 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-373 | DC-PaymentReportService.HandleIpn | tích hợp đồng thời (tạo giao dịch từ báo) | H1 ACTIVE; chưa có PaymentTransaction (StartOnlinePayment bị giữ trước commit bằng hook) | IPN thành công của H1 đến trong lúc StartOnlinePayment chưa commit, sau đó StartOnlinePayment tiếp tục | Không lỗi 23505 trên code; số PaymentTransaction PENDING hoặc TICKETED nhất quán; đúng một Booking; không vé thứ hai | P12 Vấn đề còn mở 3; P09 F7.6; T4 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-374 | DC-SeatReleaseJob.RunDue (releaseBatch) | tích hợp đồng thời (X-12, X-13, X-18, SKIP LOCKED) | 100 lần giữ ghế EXPIRED còn ghế HELD; 2 bản backend chạy SeatReleaseJob; HoldSeats của khách khác chọn lại một số ghế đó | Hai bản job chạy chồng nhau nhiều lượt cùng HoldSeats | Không ghế nào bị trả nhầm cho lần giữ ghế đã được giữ lại (R-63); mỗi ghế được trả đúng một lần; không 40P01; không bản nào chờ khoá của bản kia (SKIP LOCKED) | REQ-76; R-63; X-13, X-18; Bảng hỏng M5 mục 5 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-375 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | tích hợp tải (T2) | 4.000 lần giữ ghế ACTIVE hết hạn cùng một giây; 2 bản backend | Chạy lịch 10 giây của cả hai bản cho tới khi hết việc | Mọi lần giữ ghế EXPIRED và mọi ghế AVAILABLE không quá 60 giây sau thời điểm hết hạn; số lô xấp xỉ 20; không lần giữ ghế nào bị xử lý bởi hai bản; không 40P01 | NFR-07; BR-10; X-22; P09 F7.4, F7.9 T2; Bảng hỏng M5 mục 6 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-376 | DC-CheckTicketService.CheckTicket | tích hợp đồng thời (X-15, BR-24) | Vé TK1 UNUSED; hai nhân viên cụm rạp 2 | Hai CheckTicket(QR1) đồng thời sau barrier; lặp 1.000 lần | Đúng một ADMITTED và một ALREADY_USED; TK1 USED; người chờ khoá thấy USED (lock_timeout 1 giây đủ) | BR-24, BR-30; X-15; UC-009 4d | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-377 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | tích hợp đồng thời (X-14, hai thứ tự đến) | Vé TK1 UNUSED, huỷ được (còn từ 2 giờ) | CancelOnlineTicket(TK1) và CheckTicket(QR1) cùng lúc. Thứ tự A: soát giữ khoá hạng 8 trước. Thứ tự B: huỷ giữ khoá trước | A: ADMITTED rồi huỷ nhận TicketStateError(USED). B: huỷ thành công rồi soát trả CANCELLED. Đúng một bên thành công | BR-25, BR-30; X-14; UC-008 4b, UC-009 4e | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-378 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | tích hợp đồng thời (X-15, BR-21) | Vé TK1 UNUSED, giao dịch PT1 TICKETED | Hai CancelOnlineTicket(TK1) đồng thời sau barrier; lặp 1.000 lần | Một lần thành công, lần kia TicketStateError(CANCELLED); đúng 1 refund_request cho TK1 (uq_refund_request_ticket), refunded_total tăng một lần, 1 dòng outbox REFUND_GATEWAY | BR-21, BR-26; X-15; Q-133 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-379 | DC-RefundService.CreateFullRefund, RequestTicketRefund | tích hợp đồng thời (X-16, BR-26) | PT1 amount 200.000 TICKETED; hai vé 63.000 và 63.000; refunded_total 0 | Hai CancelOnlineTicket cho hai vé cùng PT1 đồng thời; lặp 1.000 lần. Biến thể: hạn mức còn lại đúng 63.000 và hai yêu cầu 63.000 đồng thời | Không mất cập nhật: refunded_total = 126.000 (≤ amount); biến thể: đúng một yêu cầu thành công, bên kia RefundLimitError và rollback trọn; CHECK ck_payment_transaction_refund_limit không bị kích hoạt | BR-26; X-16; P09 F7.3 EX-09 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-380 | DC-RefundService.ProcessRefund | tích hợp đồng thời (X-17, T5b, hàng rào claim_token) | 20 RefundRequest đến hạn; 2 bản backend; cổng giả chậm 25 giây mỗi lời gọi; tạm dừng một bản backend quá claimed_until | Chạy RefundOutboxJob cả hai bản, tạm dừng bản 1 trong lúc đang gọi cổng rồi cho chạy tiếp | Mỗi refundKey đúng một lời gọi RequestRefund tại cổng giả; bản bị tạm dừng nhận ClaimLostError khi tỉnh dậy và không gọi cổng; không hoàn trùng | BR-43; X-17; P09 F7.7, F7.9 T5b; Bảng hỏng M5 mục 3, 5 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-381 | DC-RefundService.ProcessRefund | tích hợp (tiến trình chết, T5) | RR1 NEW; cổng giả lập trả lỗi liên tục sau lần đầu | SIGKILL bản backend ngay sau giao dịch 1 (đã BeginAttempt); bản kia nhận lại dòng sau claimed_until; tiếp tục tới hết 4 lần | Dòng được nhận lại sau claimed_until; FindRefund luôn đứng trước RequestRefund khi nhận lại; sau 4 lần RR1 MANUAL_REQUIRED, outbox EXHAUSTED, 1 dòng log, không email hoàn tiền | BR-41; Q-118; Q-135; P09 F7.7, F7.9 T5; Bảng hỏng M5 mục 1, 2, 7 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-382 | DC-PgUnitOfWork.Do | tích hợp (IF-08.Do) | Hai giao dịch của harness khoá chéo ngoài thứ tự (tạo 40P01); và một giao dịch vi phạm thứ tự hạng | Gọi HoldSeats trong tình huống deadlock giả lập; gọi một fn cố ý Acquire lùi hạng | 40P01 thử lại tối đa 2 lần rồi SystemBusyError, tổng không quá 1,8 giây với HoldSeats; vi phạm hạng: LockOrderViolationError, không thử lại, rollback | P09 F7.3; NFR-06; P12 F2 IF-08 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-383 | DC-PgTicketingStore.SaveChanges (IF-18) | tích hợp (seat_event, NFR-08) | Suất 55 có 3 ghế AVAILABLE; một bên đăng ký đọc seat_event | HoldSeats thành công rồi HoldSeats bị rollback (SeatUnavailableError) | Commit tạo đúng 1 dòng seat_event cho suất 55 và chỉ hiện sau commit; rollback không để lại dòng seat_event nào | P09 F7.5 điểm 1; NFR-08 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-384 | Ràng buộc và trigger của P13 (lưới an toàn) | tích hợp (P13 lưới an toàn) | Schema theo P13-schema.sql | INSERT hai seat_hold ACTIVE cùng khách; INSERT hai ticket chưa huỷ cùng ghế; hai payment_transaction TICKETED cùng lần giữ ghế; UPDATE refunded_total vượt amount; UPDATE seat_hold từ EXPIRED về ACTIVE | Mỗi lệnh bị từ chối: 23505 cho ba lệnh đầu, check_violation cho hai lệnh sau (ck_payment_transaction_refund_limit, trg_seat_hold_status) | BR-04, BR-09, BR-26, BR-37, BR-86; P13 F4.4 | - | không (PostgreSQL thật); IF-01 giả lập | Trung bình | Tích hợp |

## F4. Ma trận phủ

F4.1. Phân vùng, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái và nhánh theo từng operation. Cột Đạt: Có khi có ít nhất một TC mức Unit với kết quả đã xác định; Không: chờ Q-nn khi mọi TC của mục đều chờ câu hỏi; N/A khi mục không thể xảy ra theo thiết kế.

| Mục cần phủ (EC / BV / DT-R / chuyển trạng thái / nhánh CE) | TC phủ | Đạt (Có / Không: lý do) |
|---|---|---|
| EC-01 (holder: kind = CUSTOMER) | TC-001 | Có |
| EC-02 (holder: kind = CLERK) | TC-002 | Có |
| EC-03 (holder, requestId, holdRef: rỗng, nil hoặc zero (P12 không nêu hành vi) | TC-004 | Không: chờ Q-144 |
| BV-01 (EC-01 (now): now = 2026-11-10 23:55:00 (expiryTime vượt qua nửa đêm)) | TC-003 | Có |
| CT-01 ((initial) / create(holder, showtimeId, requestId, holdRef, now) [cả nh) | TC-001 | Có |
| EC-04 (status = ACTIVE, now: now < expiryTime) | TC-005 | Có |
| EC-05 (status = ACTIVE, now: now >= expiryTime) | TC-006 | Có |
| EC-06 (status: trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED) | TC-008, TC-009 | Có |
| BV-02 (EC-04 (now so với expiryTime): E - 1ms) | TC-005 | Có |
| BV-03 (EC-05 (now so với expiryTime): E (đúng hạn)) | TC-006 | Có |
| BV-04 (EC-05 (now so với expiryTime): E + 1ms) | TC-007 | Có |
| CT-02 (Đang giữ / expire(now) [now >= expiryTime]) | TC-006 | Có |
| CT-03 (Đang giữ / expire(now) [now < expiryTime]) | TC-005 | Có |
| CT-04 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại / expire(now)) | TC-008, TC-009 | Có |
| Nhánh CE1 đến CE7 của F2.2 | 3 TC (xem F2.2.6) | Có |
| EC-07 (status = ACTIVE, now: now < expiryTime) | TC-010 | Có |
| EC-08 (status = ACTIVE, now: now >= expiryTime (bên gọi chưa gọi Expire)) | TC-013 | Không: chờ Q-142 |
| EC-09 (status: trạng thái cuối (COMPLETED, EXPIRED, CANCELLED, PAYMENT_FAILED) | TC-016, TC-017, TC-018, TC-019 | Có |
| BV-05 (EC-07: now = E - 1ms) | TC-010 | Có |
| BV-06 (EC-08: now = E) | TC-013 | Không: chờ Q-142 |
| BV-07 (EC-08: now = E + 1ms) | TC-015 | Không: chờ Q-142 |
| CT-05 (Đang giữ / complete(now) [now < expiryTime]) | TC-010 | Có |
| CT-06 (Đang giữ / cancel(now) [now < expiryTime]) | TC-011 | Có |
| CT-07 (Đang giữ / failPayment(now) [now < expiryTime]) | TC-012 | Có |
| CT-08 (Đang giữ / complete(now) [now >= expiryTime]) | TC-013 | Không: chờ Q-142 |
| CT-09 (Đang giữ / cancel(now) [now >= expiryTime]) | TC-014 | Không: chờ Q-142 |
| CT-10 (Đang giữ / failPayment(now) [now >= expiryTime]) | TC-015 | Không: chờ Q-142 |
| CT-11 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại / complete(now)) | TC-016, TC-017, TC-018, TC-019 | Có |
| CT-12 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại / cancel(now)) | TC-020 | Có |
| CT-13 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại / failPayment(now) | TC-021 | Có |
| Nhánh CE8 đến CE14 của F2.3 | 4 TC (xem F2.3.6) | Không: CE12 (chờ Q-142) |
| EC-10 (status, now: ACTIVE và now < expiryTime) | TC-022 | Có |
| EC-11 (status, now: ACTIVE và now >= expiryTime) | TC-023 | Có |
| EC-12 (status: trạng thái cuối) | TC-024 | Có |
| BV-08 (EC-10: E - 1ms) | TC-022 | Có |
| BV-09 (EC-11: E) | TC-023 | Có |
| EC-13 (seats: mọi ghế HELD bởi lần giữ ghế này, 1 đến 8 ghế) | TC-025 | Có |
| EC-14 (seats: có ghế không thuộc lần giữ ghế này (currentHold khác hoặc không) | TC-028 | Không: chờ Q-143 |
| EC-15 (seats: danh sách rỗng) | TC-029 | Không: chờ Q-143 |
| BV-10 (kích thước seats (EC-13): 1 ghế) | TC-026 | Có |
| BV-11 (kích thước seats (EC-13): 8 ghế (tối đa BR-05)) | TC-027 | Có |
| EC-16 (state (HoldFor): AVAILABLE) | TC-030 | Có |
| EC-17 (state (HoldFor): HELD hoặc SOLD) | TC-031, TC-032 | Có |
| EC-18 (state, currentHold (MarkSold): HELD và currentHold = holdId) | TC-033 | Có |
| EC-19 (state, currentHold (MarkSold): HELD nhưng currentHold khác holdId) | TC-034 | Có |
| EC-20 (state (MarkSold): AVAILABLE hoặc SOLD) | TC-035, TC-036 | Có |
| CT-14 (Trống / holdFor(holdId, price) [state = AVAILABLE]) | TC-030 | Có |
| CT-15 (Đang được giữ / Đã bán / holdFor) | TC-031, TC-032 | Có |
| CT-16 (Đang được giữ / markSold(holdId, ticketId) [currentHold = holdId]) | TC-033 | Có |
| CT-17 (Đang được giữ / markSold khi currentHold khác holdId) | TC-034 | Có |
| CT-18 (Trống / Đã bán / markSold) | TC-035, TC-036 | Có |
| Nhánh CE15 đến CE26 của F2.6 | 7 TC (xem F2.6.6) | Có |
| EC-21 (state, currentHold (ReleaseHold): HELD và currentHold = holdId) | TC-037 | Có |
| EC-22 (state, currentHold (ReleaseHold): HELD nhưng currentHold khác holdId) | TC-038 | Có |
| EC-23 (state (ReleaseHold): AVAILABLE hoặc SOLD) | TC-039, TC-040, TC-041 | Có |
| EC-24 (state, currentTicket (ReleaseTicket): SOLD và currentTicket = ticketId) | TC-042 | Có |
| EC-25 (state, currentTicket (ReleaseTicket): SOLD nhưng currentTicket khác ti) | TC-043 | Có |
| EC-26 (state (ReleaseTicket): AVAILABLE hoặc HELD) | TC-044, TC-045 | Có |
| CT-19 (Đang được giữ / releaseHold(holdId) [currentHold = holdId]) | TC-037 | Có |
| CT-20 (Đang được giữ / releaseHold khi currentHold khác holdId) | TC-038 | Có |
| CT-21 (Trống / Đã bán / releaseHold) | TC-039, TC-040, TC-041 | Có |
| CT-22 (Đã bán / releaseTicket(ticketId) [currentTicket = ticketId]) | TC-042 | Có |
| CT-23 (Đã bán / releaseTicket khi currentTicket khác ticketId) | TC-043 | Có |
| CT-24 (Trống / Đang được giữ / releaseTicket) | TC-044, TC-045 | Có |
| Nhánh CE27 đến CE40 của F2.7 | 9 TC (xem F2.7.6) | Có |
| CT-25 (Chưa xử lý (PENDING) / MarkTicketed) | TC-046 | Có |
| CT-26 (Chưa xử lý (PENDING) / MarkLatePayment) | TC-047 | Có |
| CT-27 (Chưa xử lý (PENDING) / RecordFailure) | TC-048 | Có |
| CT-28 (Chưa xử lý (PENDING) / RecordDuplicate) | TC-049 | Có |
| CT-29 (Đã ghi nhận thất bại (FAILED) / MarkTicketed) | TC-050 | Có |
| CT-30 (Đã ghi nhận thất bại (FAILED) / MarkLatePayment) | TC-051 | Có |
| CT-31 (Đã ghi nhận thất bại (FAILED) / RecordFailure) | TC-052 | Có |
| CT-32 (Đã ghi nhận thất bại (FAILED) / RecordDuplicate) | TC-053 | Có |
| CT-33 (Đã tạo vé (TICKETED) / MarkTicketed) | TC-054 | Có |
| CT-34 (Đã tạo vé (TICKETED) / MarkLatePayment) | TC-055 | Có |
| CT-35 (Đã tạo vé (TICKETED) / RecordFailure) | TC-056 | Có |
| CT-36 (Đã tạo vé (TICKETED) / RecordDuplicate) | TC-057, TC-062 | Có |
| CT-37 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) / MarkTicketed) | TC-058 | Có |
| CT-38 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) / MarkLatePayment) | TC-059 | Có |
| CT-39 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) / RecordFailure) | TC-060 | Có |
| CT-40 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) / RecordDuplicate) | TC-061 | Có |
| Nhánh CE41 đến CE64 của F2.8 | 17 TC (xem F2.8.6) | Có |
| EC-27 (refundedTotal + amount: <= số đã thanh toán) | TC-063, TC-067 | Có |
| EC-28 (refundedTotal + amount: > số đã thanh toán) | TC-064, TC-068 | Có |
| EC-29 (amount: <= 0) | TC-069 | Không: chờ Q-144 |
| BV-12 (max của EC-27: refundedTotal 0, amount 100.000 (bằng đúng số đã thanh ) | TC-063 | Có |
| BV-13 (max của EC-27: refundedTotal 0, amount 100.001) | TC-064 | Có |
| BV-14 (max của EC-27: refundedTotal 70.000, amount 30.000) | TC-065 | Có |
| BV-15 (max của EC-27: refundedTotal 70.000, amount 30.001) | TC-066 | Có |
| EC-30 (loại yêu cầu: hoàn toàn bộ (FULL)) | TC-070 | Có |
| EC-31 (loại yêu cầu: hoàn một vé qua cổng (TICKET_GATEWAY)) | TC-071, TC-072 | Có |
| EC-32 (loại yêu cầu: hoàn tiền mặt (TICKET_CASH)) | TC-073 | Có |
| EC-33 (amount, txn, ticket: amount <= 0, txn hoặc ticket nil) | TC-074 | Không: chờ Q-144 |
| CT-41 ((initial) / create(requestType = FULL hoặc TICKET_GATEWAY) [else]) | TC-070 | Có |
| CT-42 ((initial) / create(requestType = TICKET_CASH) [TICKET_CASH]) | TC-073 | Có |
| EC-34 (status: NEW) | TC-075 | Có |
| EC-35 (status: WAITING_RETRY) | TC-076 | Có |
| EC-36 (status: IN_FLIGHT (nhận lại claim sau khi tiến trình chết)) | TC-077 | Có |
| EC-37 (status: REFUNDED hoặc MANUAL_REQUIRED) | TC-080, TC-081 | Có |
| EC-38 (attemptCount (IN_FLIGHT): attemptCount < 4 (còn lượt)) | TC-077 | Có |
| EC-39 (attemptCount (IN_FLIGHT): attemptCount >= 4 (hết lượt)) | TC-079 | Có |
| BV-16 (max của EC-38: attemptCount 3 --> sau BeginAttempt = 4) | TC-078 | Có |
| BV-17 (max của EC-38: attemptCount 4) | TC-079 | Có |
| CT-43 (Mới / beginAttempt()) | TC-075 | Có |
| CT-44 (Chờ gửi lại / beginAttempt()) | TC-076 | Có |
| CT-45 (Đang chờ kết quả / beginAttempt() [nhận lại claim, attemptCount < MaxA) | TC-077 | Có |
| CT-46 (Đang chờ kết quả / beginAttempt() [attemptCount >= MaxAttempts]) | TC-079 | Có |
| CT-47 (Đã hoàn / Cần xử lý thủ công / beginAttempt()) | TC-080, TC-081 | Có |
| Nhánh CE65 đến CE72 của F2.11 | 4 TC (xem F2.11.6) | Có |
| EC-40 (status: IN_FLIGHT) | TC-082 | Có |
| EC-41 (status: NEW, WAITING_RETRY, REFUNDED, MANUAL_REQUIRED) | TC-089, TC-090, TC-091, TC-092 | Có |
| EC-42 (r: SUCCEEDED) | TC-082, TC-083 | Có |
| EC-43 (r, attemptCount: REJECTED hoặc UNKNOWN và attemptCount < 4) | TC-084, TC-085 | Có |
| EC-44 (r, attemptCount: REJECTED hoặc UNKNOWN và attemptCount >= 4) | TC-087, TC-088 | Có |
| BV-18 (max của EC-43 (attemptCount): attemptCount 3 với REJECTED) | TC-086 | Có |
| BV-19 (min của EC-44 (attemptCount): attemptCount 4 với REJECTED) | TC-087 | Có |
| CT-48 (Đang chờ kết quả / recordResult(SUCCEEDED)) | TC-082 | Có |
| CT-49 (Đang chờ kết quả / recordResult(REJECTED hoặc UNKNOWN) [attemptCount <) | TC-084, TC-085 | Có |
| CT-50 (Đang chờ kết quả / recordResult(REJECTED hoặc UNKNOWN) [attemptCount >) | TC-087, TC-088 | Có |
| CT-51 (Mới / Chờ gửi lại / Đã hoàn / Cần xử lý thủ công / recordResult) | TC-089, TC-090, TC-091, TC-092 | Có |
| Nhánh CE73 đến CE83 của F2.12 | 4 TC (xem F2.12.6) | Có |
| CT-52 (Đang chờ kết quả / markManualRequired(reason) [findRefund NOT_SUPPORTE) | TC-093 | Có |
| CT-53 (Mới / markManualRequired) | TC-094 | Có |
| CT-54 (Chờ gửi lại / markManualRequired) | TC-095 | Có |
| CT-55 (Đã hoàn / markManualRequired) | TC-096 | Có |
| CT-56 (Cần xử lý thủ công / markManualRequired) | TC-097 | Có |
| EC-45 (status: UNUSED) | TC-098 | Có |
| EC-46 (status: CANCELLED) | TC-099 | Có |
| EC-47 (status: USED) | TC-100 | Có |
| CT-57 (Chưa sử dụng / cancel() [đã qua kiểm hạn huỷ và kênh ở bên gọi]) | TC-098 | Có |
| CT-58 (Đã huỷ / cancel()) | TC-099 | Có |
| CT-59 (Đã sử dụng / cancel()) | TC-100 | Có |
| EC-48 (cinemaId so với cụm rạp của suất chiếu: đúng cụm rạp) | TC-103, TC-107 | Có |
| EC-49 (cinemaId so với cụm rạp của suất chiếu: khác cụm rạp) | TC-101, TC-102 | Có |
| EC-50 (selected so với ID suất chiếu: đúng suất chiếu) | TC-105, TC-107 | Có |
| EC-51 (selected so với ID suất chiếu: khác suất chiếu) | TC-103 | Có |
| EC-52 (status: UNUSED) | TC-107 | Có |
| EC-53 (status: USED) | TC-105 | Có |
| EC-54 (status: CANCELLED) | TC-106 | Có |
| DT1-R1 (bảng 1 quy tắc 1) | TC-101, TC-102 | Có |
| DT1-R2 (bảng 1 quy tắc 2) | TC-103, TC-104 | Có |
| DT1-R3 (bảng 1 quy tắc 3) | TC-105, TC-108 | Có |
| DT1-R4 (bảng 1 quy tắc 4) | TC-106 | Có |
| DT1-R5 (bảng 1 quy tắc 5) | TC-107 | Có |
| DT1-R6 | - | N/A: C3 và C4 không cùng đúng (USED và CANCELLED loại trừ nhau) |
| CT-60 (Chưa sử dụng / admit(showtime, selected, cinemaId) [đúng cụm rạp và đú) | TC-107 | Có |
| CT-61 (Chưa sử dụng / admit khi sai cụm rạp) | TC-101 | Có |
| CT-62 (Chưa sử dụng / admit khi sai suất chiếu) | TC-103 | Có |
| CT-63 (Đã sử dụng / admit) | TC-105 | Có |
| CT-64 (Đã huỷ / admit) | TC-106 | Có |
| Nhánh CE84 đến CE97 của F2.15 | 5 TC (xem F2.15.6) | Có |
| EC-55 (price x 70: chia hết cho 100 (70% tròn đồng)) | TC-109, TC-110 | Có |
| EC-56 (price x 70: không chia hết cho 100 (phần lẻ 0,1 đến 0,9 đồng)) | TC-113 | Có |
| EC-57 (price: <= 0) | TC-115 | Không: chờ Q-144 |
| BV-20 (EC-56: price 45.005 (phần lẻ đúng 0,5)) | TC-111 | Có |
| BV-21 (EC-56: price 45.007 (phần lẻ 0,9: lớn nhất trong các số lẻ chục)) | TC-112 | Có |
| BV-22 (EC-56: price 1 (nhỏ nhất P13 cho phép)) | TC-114 | Có |
| DT2-R1 (bảng 2 quy tắc 1) | TC-116 | Có |
| DT2-R2 (bảng 2 quy tắc 2) | TC-117 | Có |
| DT2-R3 (bảng 2 quy tắc 3) | TC-118 | Có |
| DT2-R4 (bảng 2 quy tắc 4) | TC-119 | Có |
| DT2-R5 (bảng 2 quy tắc 5) | TC-120 | Có |
| EC-58 (unfinished: rỗng hoặc chỉ gồm lần giữ ghế đã ở trạng thái cuối) | TC-121, TC-122 | Có |
| EC-59 (unfinished: có lần giữ ghế ACTIVE và now < expiryTime) | TC-123, TC-125 | Có |
| EC-60 (unfinished: có lần giữ ghế ACTIVE nhưng now >= expiryTime (đã quá hạn,) | TC-124, TC-126 | Có |
| BV-23 (EC-59 (now so với expiryTime): now = E - 1ms) | TC-123 | Có |
| BV-24 (EC-60 (now so với expiryTime): now = E) | TC-124 | Có |
| EC-61 ((rank, key) so với (maxRank, maxKey): rank lớn hơn maxRank) | TC-127, TC-128 | Có |
| EC-62 ((rank, key) so với (maxRank, maxKey): cùng rank, key lớn hơn maxKey) | TC-129, TC-138 | Có |
| EC-63 ((rank, key) so với (maxRank, maxKey): rank nhỏ hơn maxRank) | TC-131 | Có |
| EC-64 ((rank, key) so với (maxRank, maxKey): cùng rank, key nhỏ hơn maxKey) | TC-130, TC-139 | Có |
| EC-65 (khoá lại cùng dòng: chế độ bằng hoặc yếu hơn đã giữ) | TC-134, TC-135, TC-137 | Có |
| EC-66 (khoá lại cùng dòng: nâng S lên X) | TC-136 | Có |
| BV-25 (EC-61 (rank so với maxRank): rank lớn hơn maxRank nhưng key nhỏ hơn ma) | TC-132 | Có |
| BV-26 (rank nhỏ nhất, lớn nhất: PRICE_LIST (1) là khoá đầu tiên; REFUND_REQUE) | TC-127, TC-133 | Có |
| DT3-R1 (bảng 3 quy tắc 1) | TC-134, TC-135, TC-137 | Có |
| DT3-R2 (bảng 3 quy tắc 2) | TC-136 | Có |
| DT3-R3 (bảng 3 quy tắc 3) | TC-131 | Có |
| DT3-R4 (bảng 3 quy tắc 4) | TC-130 | Có |
| DT3-R5 (bảng 3 quy tắc 5) | TC-127, TC-128, TC-129 | Có |
| Nhánh CE98 đến CE111 của F2.19 | 6 TC (xem F2.19.6) | Có |
| EC-67 (startTime - now: >= 2 giờ) | TC-142, TC-144 | Có |
| EC-68 (startTime - now: < 2 giờ nhưng now trước startTime) | TC-143, TC-145 | Có |
| EC-69 (now so với startTime: now >= startTime (đã bắt đầu hoặc kết thúc)) | TC-146 | Có |
| BV-27 (min của EC-67: now = start - 2h (18:00:00.000)) | TC-142 | Có |
| BV-28 (max của EC-68: now = 18:00:00.001 (còn 1 giờ 59 phút 59,999 giây)) | TC-143 | Có |
| BV-29 (min của EC-67: now = 17:59:59.999 (ngay trong biên)) | TC-144 | Có |
| BV-30 (EC-69: now = start (20:00:00.000)) | TC-145 | Có |
| EC-70 (now, saleOpenTime, startTime: now < saleOpenTime) | TC-147 | Có |
| EC-71 (now, saleOpenTime, startTime: saleOpenTime <= now < startTime) | TC-148, TC-149 | Có |
| EC-72 (now, startTime: now >= startTime) | TC-150 | Có |
| EC-73 (status: Đã xoá) | TC-151 | Có |
| BV-31 (min của EC-71: now = sale_open - 1ms (2026-11-09 07:59:59.999)) | TC-147 | Có |
| BV-32 (min của EC-71: now = sale_open (08:00:00.000)) | TC-148 | Có |
| BV-33 (max của EC-71: now = start - 1ms (2026-11-10 19:59:59.999)) | TC-149 | Có |
| BV-34 (max của EC-71: now = start (20:00:00.000)) | TC-150 | Có |
| EC-74 (số ghế: 0 ghế) | TC-152 | Có |
| EC-75 (số ghế: 1 đến 8 ghế, không trùng, thuộc phòng) | TC-153 | Có |
| EC-76 (số ghế: từ 9 ghế trở lên) | TC-155 | Có |
| EC-77 (trùng: có hai phần tử cùng mã ghế) | TC-156 | Có |
| EC-78 (phòng: có ghế thuộc phòng chiếu khác) | TC-157 | Có |
| EC-79 (loại ghế: ghế đôi (COUPLE)) | TC-158 | Có |
| BV-35 (kích thước của EC-75: 0 ghế) | TC-152 | Có |
| BV-36 (kích thước của EC-75: 1 ghế) | TC-153 | Có |
| BV-37 (kích thước của EC-75: 8 ghế) | TC-154 | Có |
| BV-38 (kích thước của EC-75: 9 ghế) | TC-155 | Có |
| EC-80 (lastChangedAt so với displayedAt: lastChangedAt = displayedAt) | TC-160 | Có |
| EC-81 (lastChangedAt so với displayedAt: lastChangedAt > displayedAt) | TC-161 | Có |
| EC-82 (status: Đã xoá) | TC-162 | Có |
| EC-83 (lastChangedAt so với displayedAt: lastChangedAt < displayedAt (không x) | TC-163 | Không: chờ Q-144 |
| BV-39 (EC-80: lastChangedAt vượt displayedAt 1ms) | TC-161 | Có |
| EC-84 (khung giờ: ngày thường (Thứ Hai đến Thứ Sáu), trước 17:00) | TC-164, TC-171 | Có |
| EC-85 (khung giờ: ngày thường, từ 17:00) | TC-165, TC-166 | Có |
| EC-86 (khung giờ: cuối tuần (Thứ Bảy, Chủ nhật), trước 17:00) | TC-167, TC-168 | Có |
| EC-87 (khung giờ: cuối tuần, từ 17:00) | TC-169, TC-170 | Có |
| EC-88 (tổ hợp (loại phòng, định dạng, loại ghế): không có mục giá) | TC-172 | Có |
| EC-89 (startTime: mang múi giờ khác UTC+7) | TC-173 | Không: chờ Q-151 |
| BV-40 (17:00 ngày thường: Thứ Tư 16:59:59.999 (UTC+7)) | TC-164 | Có |
| BV-41 (17:00 ngày thường: Thứ Tư 17:00:00.000) | TC-165 | Có |
| BV-42 (ngày thường --> cuối tuần: Thứ Sáu 23:59:59.999 (vẫn ngày thường, từ 1) | TC-166 | Có |
| BV-43 (ngày thường --> cuối tuần: Thứ Bảy 00:00:00.000) | TC-167 | Có |
| BV-44 (17:00 cuối tuần: Thứ Bảy 16:59:59.999) | TC-168 | Có |
| BV-45 (17:00 cuối tuần: Thứ Bảy 17:00:00.000) | TC-169 | Có |
| BV-46 (cuối tuần --> ngày thường: Chủ nhật 23:59:59.999) | TC-170 | Có |
| BV-47 (cuối tuần --> ngày thường: Thứ Hai 00:00:00.000 (2026-11-16)) | TC-171 | Có |
| EC-90 (seatIds: 1 đến 8 ghế hợp lệ) | TC-174 | Có |
| EC-91 (seatIds: rỗng) | TC-178 | Có |
| EC-92 (seatIds: từ 9 ghế) | TC-179 | Có |
| EC-93 (seatIds: ghế trùng hoặc thuộc phòng khác) | TC-192 | Có |
| EC-94 (suất chiếu theo tx.Now: đang trong khoảng mở bán) | TC-174 | Có |
| EC-95 (suất chiếu theo tx.Now: chưa mở bán, đã bắt đầu hoặc đã xoá) | TC-189 | Có |
| EC-96 (suất chiếu so với displayedAt: chưa đổi) | TC-174 | Có |
| EC-97 (suất chiếu so với displayedAt: đã đổi hoặc phòng chiếu đổi sau FindRou) | TC-191 | Có |
| EC-98 (lần giữ ghế chưa kết thúc của người giữ: không có (hoặc đã quá hạn)) | TC-174 | Có |
| EC-99 (lần giữ ghế chưa kết thúc của người giữ: có ACTIVE chưa quá hạn, reque) | TC-186 | Có |
| EC-100 (requestId: trùng lần giữ ghế ACTIVE chưa quá hạn của chính người giữ) | TC-183 | Có |
| EC-101 (requestId: trùng lần giữ ghế đã ở trạng thái cuối hoặc đã quá hạn) | TC-184 | Có |
| EC-102 (trạng thái các ghế sau khi khoá: mọi ghế AVAILABLE (hoặc vừa được trả ) | TC-174 | Có |
| EC-103 (trạng thái các ghế sau khi khoá: có ghế HELD hoặc SOLD) | TC-196, TC-197 | Có |
| EC-104 (khoá ghế NOWAIT: ghế đang bị giao dịch khác khoá (55P03)) | TC-193 | Có |
| EC-105 (số dòng khoá được: khác số ghế yêu cầu) | TC-195 | Có |
| EC-106 (bảng giá: có giá cho mọi ghế) | TC-174 | Có |
| EC-107 (bảng giá: thiếu giá cho một ghế) | TC-198 | Có |
| EC-108 (giao dịch: hoàn tất trong hạn 1,8 giây) | TC-174 | Có |
| EC-109 (giao dịch: hết hạn tổng hoặc hết lần thử (SystemBusyError)) | TC-199 | Có |
| EC-110 (phòng chiếu sau khoá: khác phòng ở FindRouting) | TC-182 | Có |
| EC-111 (showtimeId: không tồn tại) | TC-180 | Có |
| BV-48 (kích thước seatIds (EC-90): 0 ghế) | TC-178 | Có |
| BV-49 (kích thước seatIds (EC-90): 1 ghế) | TC-175 | Có |
| BV-50 (kích thước seatIds (EC-90): 7 ghế) | TC-176 | Có |
| BV-51 (kích thước seatIds (EC-90): 8 ghế) | TC-177 | Có |
| BV-52 (kích thước seatIds (EC-90): 9 ghế) | TC-179 | Có |
| BV-53 (hết hạn của replay (EC-100): now = E - 1ms) | TC-183 | Có |
| BV-54 (hết hạn của lần giữ ghế cũ (EC-98): now = E (lần giữ ghế cũ vừa quá hạ) | TC-187 | Có |
| BV-55 (hết hạn của lần giữ ghế cũ (EC-99): now = E - 1ms) | TC-186 | Có |
| DT4-R1 (bảng 4 quy tắc 1) | TC-174 | Có |
| DT4-R2 (bảng 4 quy tắc 2) | TC-189, TC-190 | Có |
| DT4-R3 (bảng 4 quy tắc 3) | TC-178 | Có |
| DT4-R4 (bảng 4 quy tắc 4) | TC-186, TC-200, TC-203 | Có |
| DT4-R5 (bảng 4 quy tắc 5) | TC-191, TC-201 | Có |
| DT4-R6 (bảng 4 quy tắc 6) | TC-196, TC-197, TC-202 | Có |
| DT4-R7 (bảng 4 quy tắc 7) | TC-198 | Có |
| DT4-R8 (bảng 4 quy tắc 8) | TC-204 | Không: chờ Q-145 |
| DT4-R9 (bảng 4 quy tắc 9) | TC-205 | Không: chờ Q-145 |
| DT4-R10 (bảng 4 quy tắc 10) | TC-206 | Không: chờ Q-145 |
| Nhánh CE112 đến CE176 của F2.25 | 21 TC (xem F2.25.6) | Có |
| DT5-R1 (bảng 5 quy tắc 1) | TC-207, TC-208 | Có |
| DT5-R2 (bảng 5 quy tắc 2) | TC-209 | Có |
| DT5-R3 (bảng 5 quy tắc 3) | TC-210, TC-211 | Có |
| DT5-R4 (bảng 5 quy tắc 4) | TC-212 | Có |
| DT5-R5 (bảng 5 quy tắc 5) | TC-213 | Có |
| DT5-R6 (bảng 5 quy tắc 6) | TC-214, TC-215 | Có |
| DT5-R7 | - | N/A: C2 và C3 không cùng đúng (đã xử lý và PENDING loại trừ nhau) |
| Nhánh CE177 đến CE189 của F2.26 | 5 TC (xem F2.26.6) | Có |
| EC-112 (lần giữ ghế: ACTIVE, now < expiryTime, by là người giữ) | TC-216 | Có |
| EC-113 (lần giữ ghế: ACTIVE nhưng now >= expiryTime) | TC-218 | Có |
| EC-114 (lần giữ ghế: trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_F) | TC-221, TC-222, TC-223, TC-224 | Có |
| EC-115 (by: không phải người giữ) | TC-219 | Có |
| EC-116 (holdId: không tồn tại) | TC-220 | Có |
| BV-56 (now so với expiryTime (EC-112): now = E - 1ms) | TC-217 | Có |
| BV-57 (now so với expiryTime (EC-113): now = E) | TC-218 | Có |
| Nhánh CE190 đến CE210 của F2.27 | 5 TC (xem F2.27.6) | Có |
| EC-117 (lần giữ ghế: ACTIVE, now < expiryTime, clerk là người giữ) | TC-225 | Có |
| EC-118 (lần giữ ghế: ACTIVE nhưng now >= expiryTime) | TC-227 | Có |
| EC-119 (lần giữ ghế: đã ở trạng thái cuối) | TC-228, TC-231 | Có |
| EC-120 (clerk: không phải người giữ) | TC-230 | Không: chờ Q-147 |
| EC-121 (holdId: không tồn tại) | TC-229 | Có |
| BV-58 (now so với expiryTime (EC-117): now = E - 1ms) | TC-226 | Có |
| BV-59 (now so với expiryTime (EC-118): now = E) | TC-227 | Có |
| Nhánh CE211 đến CE229 của F2.28 | 4 TC (xem F2.28.6) | Không: CE215, CE228 (chờ Q-147) |
| EC-122 (lần giữ ghế: ACTIVE, chưa quá hạn, by là người giữ) | TC-232, TC-233 | Có |
| EC-123 (lần giữ ghế: ACTIVE nhưng now >= expiryTime) | TC-234 | Có |
| EC-124 (lần giữ ghế: đã ở trạng thái cuối) | TC-235 | Có |
| EC-125 (IF-01.CreatePaymentTransaction: ném GatewayConfigurationError) | TC-236 | Có |
| EC-126 (by: không phải người giữ) | TC-237 | Không: chờ Q-147 |
| EC-127 (holdId: không tồn tại) | TC-238 | Có |
| Nhánh CE230 đến CE249 của F2.29 | 5 TC (xem F2.29.6) | Không: CE234, CE247 (chờ Q-147) |
| EC-128 (chữ ký (IF-02): sai) | TC-256 | Có |
| EC-129 (tham số: thiếu hoặc sai kiểu) | TC-257 | Có |
| EC-130 (mã tham chiếu / mã giao dịch: không nhận ra) | TC-251 | Có |
| EC-131 (số tiền báo thành công chưa xử lý: khác bản ghi (hoặc khác tổng giá gh) | TC-253 | Có |
| EC-132 (báo thành công: giao dịch PENDING, lần giữ ghế ACTIVE còn hạn, liên kế) | TC-239, TC-240 | Có |
| EC-133 (báo thành công: lần giữ ghế không còn hiệu lực hoặc giao dịch đã FAILE) | TC-241, TC-242 | Có |
| EC-134 (báo thành công: giao dịch đã xử lý (TICKETED hoặc LATE_PAYMENT)) | TC-245, TC-262 | Có |
| EC-135 (báo thất bại: bất kỳ trạng thái) | TC-247 | Có |
| EC-136 (cơ sở dữ liệu: lỗi tạm thời (40P01, 55P03 sau thử lại)) | TC-259 | Có |
| DT6-R1 (bảng 6 quy tắc 1) | TC-256, TC-258 | Có |
| DT6-R2 (bảng 6 quy tắc 2) | TC-257 | Có |
| DT6-R3 (bảng 6 quy tắc 3) | TC-251 | Có |
| DT6-R4 (bảng 6 quy tắc 4) | TC-255 | Có |
| DT6-R5 (bảng 6 quy tắc 5) | TC-239 | Có |
| DT6-R6 (bảng 6 quy tắc 6) | TC-241, TC-242, TC-243 | Có |
| DT6-R7 (bảng 6 quy tắc 7) | TC-245, TC-246 | Có |
| DT6-R8 (bảng 6 quy tắc 8) | TC-247, TC-248, TC-250 | Có |
| DT6-R9 (bảng 6 quy tắc 9) | TC-260, TC-261 | Không: chờ Q-146 |
| Nhánh CE250 đến CE299 của F2.30 | 16 TC (xem F2.30.6) | Có |
| EC-137 (số lần giữ ghế đã quá hạn: 0) | TC-267, TC-277 | Có |
| EC-138 (số lần giữ ghế đã quá hạn: 1 đến 199 (một lô chưa đầy)) | TC-268, TC-269, TC-270 | Có |
| EC-139 (số lần giữ ghế đã quá hạn: từ 200 (lô đầy, cần lô tiếp)) | TC-271, TC-272 | Có |
| EC-140 (hàng ứng viên: hàng chưa quá hạn theo tx.Now (ứng viên chọn trước khoá) | TC-273 | Có |
| EC-141 (expireBatch: trả lỗi) | TC-276 | Có |
| Nhánh CE300 đến CE309 của F2.31 | 4 TC (xem F2.31.6) | Có |
| EC-142 (lô lần giữ ghế đạt điều kiện: rỗng) | TC-278, TC-282 | Có |
| EC-143 (ghế còn trỏ tới lần giữ ghế đã ở trạng thái cuối: HELD với currentHold) | TC-279, TC-283, TC-284, TC-285, TC-286 | Có |
| EC-144 (ghế đã giữ lại cho lần giữ ghế khác: HELD với currentHold ngoài lô) | TC-280 | Có |
| EC-145 (lần giữ ghế COMPLETED: ghế SOLD) | TC-281 | Có |
| Nhánh CE310 đến CE322 của F2.32 | 2 TC (xem F2.32.6) | Có; loại khỏi mẫu số: CE318 |
| EC-146 (kênh, hạn, trạng thái vé: đúng kênh, còn từ 2 giờ, vé UNUSED) | TC-287, TC-299 | Có |
| EC-147 (kênh: sai kênh hoặc sai chủ (2a, 2b, 2c)) | TC-291 | Có |
| EC-148 (hạn huỷ: còn dưới 2 giờ hoặc đã bắt đầu) | TC-289, TC-290 | Có |
| EC-149 (trạng thái vé: đã huỷ hoặc đã sử dụng) | TC-294 | Có |
| EC-150 (hạn mức hoàn: refundedTotal + 70% vượt số đã thanh toán) | TC-297 | Có |
| EC-151 (liên kết ghế: currentTicket khác vé đang huỷ (ghế đã bán lại)) | TC-298 | Có |
| EC-152 (kênh quầy: vé mua tại quầy, nhân viên đúng cụm rạp) | TC-302 | Có |
| BV-60 (thời điểm huỷ (EC-146): now = 18:00:00.000 (đúng 2 giờ trước 20:00)) | TC-288 | Có |
| BV-61 (thời điểm huỷ (EC-148): now = 18:00:00.001) | TC-289 | Có |
| DT7-R1 (bảng 7 quy tắc 1) | TC-287 | Có |
| DT7-R2 (bảng 7 quy tắc 2) | TC-291, TC-292, TC-295, TC-303, TC-304 | Có |
| DT7-R3 (bảng 7 quy tắc 3) | TC-289, TC-296, TC-305 | Có |
| DT7-R4 (bảng 7 quy tắc 4) | TC-293 | Có |
| DT7-R5 (bảng 7 quy tắc 5) | TC-294, TC-306 | Có |
| DT7-R6 | - | N/A: C3 và C4 không cùng đúng (vé không vừa đã huỷ vừa đã sử dụng) |
| Nhánh CE323 đến CE356 của F2.33 | 11 TC (xem F2.33.6) | Có |
| EC-153 (kết quả Admit: ADMITTED) | TC-308 | Có |
| EC-154 (kết quả Admit: một trong WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, C) | TC-309, TC-310, TC-311, TC-312, TC-314, TC-315, TC-316 | Có |
| EC-155 (ticketCode: không tương ứng vé nào) | TC-313 | Có |
| Nhánh CE357 đến CE370 của F2.34 | 3 TC (xem F2.34.6) | Có; loại khỏi mẫu số: CE362, CE370 |
| EC-156 (hạn mức: refundedTotal + amount <= số đã thanh toán) | TC-317, TC-319 | Có |
| EC-157 (hạn mức: refundedTotal + amount > số đã thanh toán) | TC-318 | Có |
| EC-158 (IF-19.AddRefunded: 0 dòng ảnh hưởng (bên khác vừa cộng)) | TC-322 | Có |
| BV-62 (max của EC-156: refundedTotal 37.000 + 63.000 = 100.000) | TC-320 | Có |
| BV-63 (max của EC-156: refundedTotal 37.001 + 63.000) | TC-321 | Có |
| EC-159 (lần gửi: lần đầu (AttemptCount = 1 sau BeginAttempt)) | TC-323 | Có |
| EC-160 (lần gửi: lần hai trở đi (AttemptCount > 1, kể cả nhận lại claim)) | TC-327 | Có |
| EC-161 (FindRefund: REFUNDED) | TC-329 | Có |
| EC-162 (FindRefund: NOT_REFUNDED) | TC-327 | Có |
| EC-163 (FindRefund: NOT_SUPPORTED hoặc UNREACHABLE) | TC-330 | Có |
| EC-164 (RequestRefund: SUCCEEDED) | TC-323 | Có |
| EC-165 (RequestRefund: REJECTED hoặc UNKNOWN (hết 30 giây)) | TC-325 | Có |
| EC-166 (claim_token ở giao dịch 1: đã mất (claim hết hạn và bản khác nhận)) | TC-334 | Có |
| EC-167 (claim_token ở giao dịch 3: đã mất) | TC-335 | Có |
| EC-168 (trạng thái RefundRequest khi nhận dòng: REFUNDED hoặc MANUAL_REQUIRED ) | TC-336 | Có |
| EC-169 (IN_FLIGHT khi nhận lại claim: hết lượt (attemptCount = 4)) | TC-339 | Có |
| EC-170 (phần claim còn lại sau giao dịch 1: dưới 10 giây) | TC-340 | Có |
| EC-171 (phần claim còn lại sau giao dịch 1: từ 40 giây (hạn gọi cổng = 30 giây) | TC-344 | Có |
| BV-64 (MaxAttempts (RR attemptCount trước khi ghi kết quả): attemptCount 3 th) | TC-332 | Có |
| BV-65 (MaxAttempts: attemptCount 4 thất bại) | TC-333 | Có |
| BV-66 (phần claim còn lại (EC-170): 9,999 giây) | TC-340 | Có |
| BV-67 (phần claim còn lại (EC-170): 10,001 giây) | TC-343 | Không: chờ Q-149 |
| BV-68 (hạn gọi cổng: claim còn 40 giây --> hạn 30 giây) | TC-323, TC-344 | Có |
| BV-69 (hạn gọi cổng: claim còn 35 giây --> hạn 25 giây) | TC-345 | Có |
| DT8-R1 (bảng 8 quy tắc 1) | TC-334 | Có |
| DT8-R2 (bảng 8 quy tắc 2) | TC-336, TC-337 | Có |
| DT8-R3 (bảng 8 quy tắc 3) | TC-339 | Có |
| DT8-R4 (bảng 8 quy tắc 4) | TC-323 | Có |
| DT8-R5 (bảng 8 quy tắc 5) | TC-325, TC-326 | Có |
| DT8-R6 | - | N/A: Lần gửi đầu (attemptCount = 1) luôn còn lượt vì MaxAttempts = 4, không thể hết lượt ngay sau lần đầu |
| DT8-R7 (bảng 8 quy tắc 7) | TC-329 | Có |
| DT8-R8 (bảng 8 quy tắc 8) | TC-328, TC-338 | Có |
| DT8-R9 (bảng 8 quy tắc 9) | TC-327 | Có |
| DT8-R10 (bảng 8 quy tắc 10) | TC-332, TC-333 | Có |
| DT8-R11 (bảng 8 quy tắc 11) | TC-330, TC-331 | Có |
| Nhánh CE371 đến CE412 của F2.36 | 14 TC (xem F2.36.6) | Có |
| EC-172 (bookingCode: tương ứng một lần đặt mua tại quầy của cụm rạp của nhân v) | TC-346 | Có |
| EC-173 (bookingCode: không tương ứng lần đặt nào) | TC-347 | Có |
| EC-174 (lần đặt: mua tại quầy của cụm rạp khác cụm rạp của nhân viên) | TC-348 | Có |
| EC-175 (lần đặt: mua trực tuyến) | TC-349 | Có |
| EC-176 (suất chiếu: thuộc cụm rạp của nhân viên soát vé) | TC-350 | Có |
| EC-177 (suất chiếu: thuộc cụm rạp khác) | TC-351 | Có |
| EC-178 (showtimeId: không tồn tại) | TC-352 | Có |
| EC-179 (role: CUSTOMER) | TC-356 | Có |
| EC-180 (role: nhân viên (BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHA) | TC-357 | Có |
| EC-181 (role: ADMINISTRATOR) | TC-358 | Không: chờ Q-153 |
| EC-182 (token: đúng chữ ký, chưa hết hạn) | TC-359 | Có |
| EC-183 (token: sai chữ ký (bị sửa)) | TC-360 | Có |
| EC-184 (token: đã hết hạn) | TC-361 | Có |
| EC-185 (storedHash: định dạng hỏng) | TC-355 | Có |

F4.2. Quy tắc nghiệp vụ (BR) và NFR liên quan tới phương thức trong phạm vi.

| BR / NFR | TC phủ | Đạt (Có / Không: lý do) |
|---|---|---|
| BR-01 | TC-147, TC-148, TC-149, TC-150, TC-189 | Có |
| BR-02 | - | Không phủ bằng unit test trong phạm vi: kiểm cụm rạp của nhân viên quầy khi chọn suất chiếu (UC-005 2b) không có trong F3 của HoldSeats; thuộc bước hiển thị sơ đồ ghế (PKG-11/GetSnapshot, ngoài phạm vi); Đề xuất sửa P12 dòng 14. Mức kiểm thử phù hợp: kiểm thử tích hợp API và UI |
| BR-04 | TC-024, TC-121, TC-122, TC-123, TC-124, TC-125, TC-126, TC-186, TC-187, TC-188, TC-200; tích hợp: TC-365, TC-384 | Có |
| BR-05 | TC-026, TC-027, TC-152, TC-153, TC-154, TC-155, TC-175, TC-176, TC-177, TC-178, TC-179 | Có |
| BR-06 | TC-158 | Có |
| BR-07 | TC-030, TC-174, TC-195, TC-196; tích hợp: TC-363, TC-364 | Có |
| BR-08 | TC-030, TC-031, TC-196 | Có |
| BR-09 | TC-031, TC-032, TC-036, TC-193, TC-197; tích hợp: TC-363, TC-364, TC-366, TC-367, TC-384 | Có |
| BR-10 | TC-001, TC-002, TC-003, TC-005, TC-006, TC-007, TC-174, TC-187, TC-217, TC-268; tích hợp: TC-375 | Có |
| BR-11 | TC-164, TC-165, TC-166, TC-167, TC-168, TC-169, TC-170, TC-171 | Có |
| BR-12 | TC-164, TC-165, TC-166, TC-167, TC-168, TC-169, TC-170, TC-171 | Có |
| BR-14 | TC-006, TC-047, TC-070, TC-210, TC-240, TC-241, TC-265, TC-317; tích hợp: TC-372 | Có |
| BR-15 | TC-051, TC-211, TC-212, TC-213, TC-242, TC-243, TC-264; tích hợp: TC-371 | Có |
| BR-17 | TC-116, TC-117, TC-118, TC-119, TC-120, TC-287, TC-291, TC-292, TC-295, TC-302, TC-303, TC-304 và 2 TC khác | Có |
| BR-18 | TC-142, TC-143, TC-144, TC-145, TC-146, TC-288, TC-289, TC-290, TC-305 | Có |
| BR-19 | TC-071, TC-109, TC-110, TC-287, TC-299, TC-319, TC-346 | Có |
| BR-20 | TC-073 | Có |
| BR-21 | TC-098, TC-099, TC-287, TC-293, TC-302; tích hợp: TC-378 | Có |
| BR-22 | TC-101, TC-107, TC-308, TC-309 | Có |
| BR-23 | TC-103, TC-107, TC-310 | Có |
| BR-24 | TC-105, TC-107, TC-108, TC-231, TC-308, TC-311, TC-314; tích hợp: TC-376 | Có |
| BR-25 | TC-106, TC-312, TC-315; tích hợp: TC-377 | Có |
| BR-26 | TC-063, TC-064, TC-065, TC-066, TC-067, TC-068, TC-297, TC-317, TC-318, TC-319, TC-320, TC-321 và 1 TC khác; tích hợp: TC-378, TC-379, TC-384 | Có |
| BR-30 | TC-100, TC-294, TC-306, TC-315, TC-316; tích hợp: TC-376, TC-377 | Có |
| BR-31 | TC-110, TC-111, TC-112, TC-113, TC-114, TC-299, TC-346 | Có |
| BR-32 | TC-142, TC-143, TC-144, TC-145, TC-288, TC-289 | Có |
| BR-33 | TC-101, TC-102, TC-104, TC-105, TC-106 | Có |
| BR-34 | TC-350, TC-351 | Có |
| BR-37 | TC-010, TC-046, TC-049, TC-054, TC-055, TC-057, TC-059, TC-061, TC-062, TC-207, TC-208, TC-209 và 4 TC khác; tích hợp: TC-370, TC-384 | Có |
| BR-38 | TC-251 | Có |
| BR-39 | TC-012, TC-021, TC-048, TC-052, TC-056, TC-060, TC-214, TC-215, TC-247, TC-249, TC-250 | Có |
| BR-40 | TC-254 | Có |
| BR-41 | TC-076, TC-078, TC-079, TC-081, TC-083, TC-084, TC-085, TC-086, TC-087, TC-088, TC-093, TC-323 và 10 TC khác; tích hợp: TC-381 | Có |
| BR-42 | TC-042, TC-287, TC-298, TC-302, TC-307 | Có |
| BR-43 | TC-070, TC-071, TC-072, TC-075, TC-082, TC-085, TC-317, TC-319, TC-323, TC-326, TC-327, TC-329 và 1 TC khác; tích hợp: TC-380 | Có |
| BR-44 | TC-010, TC-225, TC-226, TC-227 | Có |
| BR-45 | TC-147, TC-148, TC-149, TC-150, TC-190 | Có |
| BR-53 | TC-022, TC-023 | Có |
| BR-54 | TC-160, TC-161, TC-162, TC-182, TC-191, TC-201 | Có |
| BR-58 | TC-151 | Có |
| BR-65 | TC-025, TC-026, TC-027, TC-030, TC-174 | Có |
| BR-67 | TC-225 | Có |
| BR-72 | TC-172, TC-198, TC-202 | Có |
| BR-80 | TC-225 | Có |
| BR-85 | TC-011, TC-012, TC-022, TC-033, TC-034, TC-040, TC-216, TC-217, TC-231, TC-239, TC-240, TC-262 và 4 TC khác; tích hợp: TC-370, TC-371, TC-372 | Có |
| BR-86 | TC-008, TC-009, TC-016, TC-017, TC-018, TC-019, TC-020, TC-021, TC-024, TC-184, TC-213, TC-218 và 15 TC khác; tích hợp: TC-371, TC-372, TC-384 | Có |
| BR-90 | TC-232, TC-233, TC-236 | Có |
| BR-91 | TC-253, TC-255 | Có |
| BR-93 | TC-247, TC-248 | Có |
| NFR-06 | TC-174, TC-199, TC-366, TC-367, TC-382 | TC tích hợp (hạn 1,8 giây) và unit kiểm TxOptions.deadline |
| NFR-07 | TC-267, TC-268, TC-272, TC-279, TC-283, TC-284, TC-285, TC-286 | TC tích hợp T2 và unit lô 200 |
| NFR-08 | TC-383 | Không (unit): ngoài phạm vi lượt này (SS-03); ca tích hợp seat_event |
| NFR-09 | - | Không (unit): ngoài phạm vi lượt này (SS-03) |
| NFR-16 | TC-256 | Không (unit): kiểm chữ ký thuộc PKG-22, để lượt sau; HandleIpn dùng stub IF-02 |
| NFR-17 | - | Không (unit): PKG-22 để lượt sau; ProcessRefund dùng mock IF-01 |

F4.3. Luồng thay thế và ngoại lệ của đặc tả use case (P04) liên quan.

| Luồng P04 | TC phủ | Đạt (Có / Không: lý do) |
|---|---|---|
| UC-005 2a | TC-147, TC-189 | Có |
| UC-005 2b | - | Không: Xem BR-02: không có bước kiểm trong F3 của HoldSeats |
| UC-005 2c | TC-150, TC-190 | Có |
| UC-005 5b | TC-123, TC-125, TC-186 | Có |
| UC-005 6a | TC-155, TC-179 | Có |
| UC-005 7a | TC-196, TC-197, TC-201, TC-202, TC-203 | Có |
| UC-005 7b | TC-006, TC-020, TC-037, TC-218, TC-234, TC-265 | Có |
| UC-005 7c | TC-123, TC-186, TC-200, TC-203, TC-365 | Có |
| UC-005 7d | TC-161, TC-162, TC-182, TC-191, TC-200, TC-201 | Có |
| UC-005 7e | TC-172, TC-198, TC-202 | Có |
| UC-005 9a1a | TC-227 | Có |
| UC-005 10a | TC-236 | Có |
| UC-005 11a | TC-012, TC-037, TC-048, TC-214, TC-224, TC-247, TC-248 | Có |
| UC-005 *a | TC-011, TC-020, TC-037, TC-211, TC-216, TC-221, TC-235, TC-242, TC-264 | Có |
| UC-006 2a | TC-057, TC-061, TC-207, TC-208, TC-245, TC-246 | Có |
| UC-006 2c | TC-249 | Có |
| UC-006 2d | TC-056, TC-215, TC-250 | Có |
| UC-006 2e | TC-251 | Có |
| UC-006 2f | TC-255 | Có |
| UC-006 4a | TC-085, TC-326 | Có |
| UC-006 5a | TC-084, TC-325, TC-327 | Có |
| UC-006 4t | TC-327, TC-328, TC-329, TC-330, TC-331 | Có |
| UC-006 4b | TC-088, TC-093, TC-330 | Có |
| UC-006 5b | TC-087, TC-333 | Có |
| UC-008 1a1a | TC-347 | Có |
| UC-008 2a | TC-117, TC-118, TC-291, TC-292, TC-295 | Có |
| UC-008 2b | TC-119, TC-303, TC-349 | Có |
| UC-008 2c | TC-304, TC-348 | Có |
| UC-008 3a | TC-142, TC-143, TC-144, TC-145, TC-146, TC-289, TC-290, TC-295, TC-305 | Có |
| UC-008 4a | TC-099, TC-293 | Có |
| UC-008 4b | TC-100, TC-294, TC-306, TC-316, TC-377 | Có |
| UC-008 5a1 | TC-109, TC-110, TC-111, TC-112, TC-113, TC-114, TC-302 | Có |
| UC-008 5a2 | TC-073, TC-302 | Có |
| UC-008 5b | TC-326 | Có |
| UC-008 6a | TC-325 | Có |
| UC-008 5t | TC-327 | Có |
| UC-008 5c | TC-330 | Có |
| UC-008 6b | TC-333 | Có |
| UC-009 4a | TC-313 | Có |
| UC-009 4b | TC-101, TC-102, TC-309 | Có |
| UC-009 4c | TC-103, TC-104, TC-310 | Có |
| UC-009 4d | TC-105, TC-108, TC-311, TC-314, TC-376 | Có |
| UC-009 4e | TC-106, TC-312, TC-315 | Có |

F4.4. Cặp loại trừ X-nn trong phạm vi (00-Concurrency.md M9: mỗi X-nn có ca thử cho từng thứ tự đến khác kết cục). Ca unit chạy tuần tự trên IF-08 giả và chứng minh kết cục sau khi có khoá; loại trừ thật là ca tích hợp.

| Cặp loại trừ | TC phủ | Đạt |
|---|---|---|
| X-01: EX-01 với EX-01 cùng suất chiếu: một bên giữ được, bên kia bị từ chối (BR-07, BR-09) | unit: TC-031, TC-193; tích hợp: TC-363, TC-364 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-02: EX-01 với EX-01 cùng người giữ khác suất chiếu: bên sau thấy lần giữ ghế chưa kết thúc (BR-04) | unit: TC-186; tích hợp: TC-365 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-03: EX-01 với EX-13, EX-14: phía EX-01 (suất chiếu đã đổi thì bị từ chối); phía EX-13, EX-14 thuộc UC-014 chưa chi tiết hoá | unit: TC-161; tích hợp: - | Có (unit) |
| X-09: EX-02, EX-03 với EX-02, EX-03 cùng lần giữ ghế: báo đầu được xử lý, báo sau là báo trùng hoặc thanh toán trễ | unit: TC-227, TC-228, TC-241, TC-245, TC-262; tích hợp: TC-370 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-10: EX-02, EX-03 với EX-04 cùng lần giữ ghế: chỉ một trạng thái cuối; hết hạn, huỷ, báo thanh toán theo hai thứ tự | unit: TC-020, TC-218, TC-263, TC-264, TC-265, TC-266, TC-277; tích hợp: TC-371, TC-372 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-12: EX-05 với EX-02, EX-03: không thể vừa bán vừa giải phóng cùng một ghế | unit: TC-034, TC-040, TC-221, TC-263, TC-266, TC-281; tích hợp: TC-371 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-13: EX-05, EX-06 với EX-01: ghế chỉ giữ lại được sau khi đã về trống | unit: TC-038, TC-194, TC-223, TC-280; tích hợp: TC-369, TC-374 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-14: EX-07 với EX-08 cùng vé: bên ghi nhận trước thành công (huỷ và soát) | unit: TC-100, TC-294, TC-315, TC-316; tích hợp: TC-377 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-15: EX-07 với EX-07, EX-08 với EX-08 cùng vé: một lần huỷ hoặc một lần soát | unit: TC-099, TC-108, TC-293, TC-314; tích hợp: TC-376, TC-378 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-16: EX-09 với EX-09, EX-02: tổng đã hoàn không mất cập nhật, không vượt số đã thanh toán (BR-26) | unit: TC-066, TC-297, TC-318, TC-321, TC-322; tích hợp: TC-379 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-17: EX-10 với EX-10 cùng yêu cầu hoàn: một lời gọi cổng cho mỗi khoá chống hoàn trùng (BR-43) | unit: TC-072; tích hợp: TC-380 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-18: EX-05 với EX-05, EX-06 với EX-06 cùng ghế: chạy lặp, không trả nhầm ghế đã giữ lại hoặc bán lại | unit: TC-038, TC-041, TC-043, TC-223, TC-280, TC-282, TC-298; tích hợp: TC-374 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-22: EX-04 với EX-05 cùng lần giữ ghế: giải phóng chỉ khi lần giữ ghế đã ở trạng thái cuối | unit: TC-279; tích hợp: TC-375 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-04: EX-01 với EX-11, EX-12 (giá): phía EX-11, EX-12 thuộc UC-013 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-05: EX-11, EX-12: UC-013 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-06: EX-12 với EX-13: UC-013, UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-07: EX-13 với EX-13: UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-08: EX-13, EX-14: UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-11: EX-02, EX-03 với EX-13, EX-14: phía sửa hoặc xoá suất chiếu thuộc UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-19: EX-15 với EX-13: UC-012, UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-20: EX-13 với EX-05, EX-06: phía EX-13 thuộc UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-21: EX-15 với EX-01, EX-12: UC-012, UC-013 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |
| X-23: EX-07 với EX-13, EX-14: phía EX-13, EX-14 thuộc UC-014 chưa chi tiết hoá | - | Không: ngoài phạm vi (phần PKG-27 chưa thiết kế); chạy lại khi có P12 cho UC-012, UC-013, UC-014 |

F4.5. Tình huống hỏng (00-Concurrency.md M5, bảy tình huống) và ca thử hồi phục. P09 F7 chưa có bảng Bảng hỏng nên các mục lấy từ danh sách M5.

| Tình huống | TC phủ | Đạt |
|---|---|---|
| Mục 1: Tiến trình dừng giữa hai giao dịch của cùng một nghiệp vụ (ProcessRefund sau giao dịch 1, StartOnlinePayment sau commit) | unit: TC-276, TC-338; tích hợp: TC-381 | Có |
| Mục 2: Tiến trình dừng sau khi gọi hệ thống ngoài và trước khi ghi kết quả (RequestRefund đã gọi) | unit: TC-329, TC-338; tích hợp: TC-381 | Có |
| Mục 3: Sự kiện đến trùng, đến muộn, sai thứ tự; lần thử cũ khi lần thử mới đang chạy (IPN trùng, muộn, báo thất bại của giao dịch cũ, ClaimLostError) | unit: TC-259, TC-262, TC-335, TC-336; tích hợp: TC-370, TC-380 | Có |
| Mục 4: Giao dịch đã ghi nhưng phản hồi mất, tác nhân bấm lại (HoldSeats cùng requestId, xác nhận thu tiền hai lần) | unit: TC-183, TC-231; tích hợp: - | Có |
| Mục 5: Nhiều bản cùng quét một hàng đợi (SKIP LOCKED, hàng rào claim_token, hạn nhận việc) | unit: TC-282, TC-340; tích hợp: TC-374, TC-380 | Có |
| Mục 6: Tiến trình dọn dẹp ở tải đỉnh (4.000 lần giữ ghế hết hạn, ngân sách 8 giây) | unit: TC-274; tích hợp: TC-375 | Có |
| Mục 7: Nguồn thông báo hoặc hàng đợi mất sự kiện, bên nhận lấy lại được | unit: -; tích hợp: TC-381 | Có |

F4.6. Độ phủ hộp trắng đạt được so với mục tiêu (mức thiết kế, chưa có mã nguồn; Đo khi có mã nguồn để xác nhận).

| Operation | C0 | C1 | Mục tiêu | Kết luận |
|---|---|---|---|---|
| DC-SeatHold.NewSeatHold | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SeatHold.Expire | 4/4 (100%) | 7/7 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatHold.Complete, Cancel, FailPayment | 4/4 (100%) | 6/7 (85%) | 100% C1 (ưu tiên Cao) | Chưa đạt (còn thiếu do TC chờ Q-nn hoặc nhánh loại khỏi mẫu số) |
| DC-SeatHold.IsActiveAt | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SeatHold.CalculateTotal | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SeatStatus.HoldFor, MarkSold | 7/7 (100%) | 12/12 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatStatus.ReleaseHold, ReleaseTicket | 8/8 (100%) | 14/14 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate | 14/14 (100%) | 24/24 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentTransaction.CheckRefundWithin, RecordRefunded | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C0 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-RefundRequest.BeginAttempt | 5/5 (100%) | 8/8 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-RefundRequest.RecordResult | 7/7 (100%) | 11/11 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-RefundRequest.MarkManualRequired | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Ticket.Cancel | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Ticket.Admit | 9/9 (100%) | 14/14 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-Ticket.RefundAmount | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Booking.CheckCancellationChannel | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-LockOrderGuard.Acquire, AcquireAll | 8/8 (100%) | 14/14 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-Showtime.CheckCancellationDeadline | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Showtime.CheckSaleOpen | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Showtime.CheckSeatSelection | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Showtime.CheckUnchangedSince | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-PriceList.DetermineSeatPrice | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-BookTicketsService.HoldSeats | 45/45 (100%) | 65/65 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentReportService.decide | 8/8 (100%) | 13/13 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-BookTicketsService.CancelHold | 15/15 (100%) | 21/21 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-BookTicketsService.ConfirmCashReceived | 12/13 (92%) | 17/19 (89%) | 100% C1 (ưu tiên Cao) | Chưa đạt (còn thiếu do TC chờ Q-nn hoặc nhánh loại khỏi mẫu số) |
| DC-BookTicketsService.StartOnlinePayment | 13/14 (92%) | 18/20 (90%) | 100% C0 | Chưa đạt (còn thiếu do TC chờ Q-nn hoặc nhánh loại khỏi mẫu số) |
| DC-PaymentReportService.HandleIpn | 34/34 (100%) | 50/50 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | 6/6 (100%) | 10/10 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatReleaseJob.RunDue (releaseBatch) | 9/9 (100%) | 12/12 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | 24/24 (100%) | 34/34 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-CheckTicketService.CheckTicket | 9/9 (100%) | 12/12 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-RefundService.CreateFullRefund, RequestTicketRefund | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-RefundService.ProcessRefund | 29/29 (100%) | 42/42 (100%) | 100% C1 (ưu tiên Cao) | Đạt |
| DC-CancelTicketService.FindBooking | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-CheckTicketService.StartChecking | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C1 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| IF-07.VerifyPassword, IssueSession, VerifySession | Đo khi có mã nguồn | Đo khi có mã nguồn | 100% C0 | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |

## F5. Khung mã test

Không áp dụng: SINH_MA_TEST là Không có theo yêu cầu người chạy (chỉ thiết kế, không viết mã thật).

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-142 | Khi Complete, Cancel hoặc FailPayment được gọi lúc lần giữ ghế còn ACTIVE nhưng now không trước expiryTime (bên gọi chưa gọi Expire), HoldNotActiveError mang status nào (ACTIVE hay EXPIRED) và operation có chuyển trạng thái sang EXPIRED không? | DC-SeatHold.Complete, Cancel, FailPayment; DC-BookTicketsService.HoldSeats (replay hết hạn); TC chờ Q-142 | P12 F3 ghi 'trả HoldNotActiveError mang status hiện tại, không đổi' (status ACTIVE) còn P12 F6.2 ghi 'gọi Expire trước (chuyển Hết hạn, lưu), rồi ném HoldNotActiveError(EXPIRED)'; X1 RV-01 điểm 4 đã nêu giao thức ngầm này | Nhóm dự án | Entity giữ thuần: không đổi trạng thái, HoldNotActiveError mang status ACTIVE kèm cờ đã quá hạn; bên gọi (service) luôn gọi Expire trước nên EXPIRED chỉ do service ghi. Sửa F6.2 theo F3 |
| Q-143 | DC-SeatHold.CalculateTotal xử lý thế nào với ghế trong danh sách không thuộc lần giữ ghế này (currentHold khác hoặc không HELD) và với danh sách rỗng? | DC-SeatHold.CalculateTotal; HandleIpn bước 3 (so r.amount với tổng giá); TC chờ Q-143 | P12 F2 chỉ nêu 'tổng heldPrice của các ghế đang giữ cho lần giữ ghế này' | Nhóm dự án | Chỉ cộng ghế HELD có currentHold bằng ID của lần giữ ghế, bỏ qua ghế khác; danh sách rỗng trả 0 |
| Q-144 | Giá trị ngoài miền mà P12 không nêu hành vi: tham số rỗng hoặc nil của NewSeatHold; Money bằng 0 hoặc âm ở NewFullRefund, NewTicketRefund, NewCashRefund, CheckRefundWithin, RecordRefunded, RefundAmount; ghế lùi mốc ở CheckUnchangedSince; hai key bằng nhau ở AcquireAll. Các operation phải từ chối, bỏ qua hay coi là lỗi lập trình? | NewSeatHold; DC-RefundRequest.New*; DC-PaymentTransaction.CheckRefundWithin, RecordRefunded; DC-Ticket.RefundAmount; DC-Showtime.CheckUnchangedSince; DC-LockOrderGuard.AcquireAll; mọi TC ghi chờ Q-144 | P12 F2 không nêu ngoại lệ cho các miền này; P13 có CHECK > 0 cho giá, số tiền | Nhóm dự án | Coi là lỗi lập trình của bên gọi (tiền điều kiện), không kiểm trong operation, không thiết kế TC; lưới an toàn là CHECK của P13 (ck_payment_transaction_amount, ck_refund_request_amount, ck_ticket_price) |
| Q-145 | Khi HoldSeats nhận yêu cầu vi phạm đồng thời suất chiếu chưa mở bán hoặc đã bắt đầu (UC-005 2a, 2c) hoặc số ghế rỗng hoặc quá 8 (6a) cùng với một điều kiện khác (người giữ còn lần giữ ghế chưa kết thúc 7c, suất chiếu đã đổi 7d, ghế không trống 7a, thiếu giá 7e), thông báo lỗi nào được báo trước? | DC-BookTicketsService.HoldSeats; DT bảng quyết định HoldSeats; TC chờ Q-145 | P04 UC-005 mục 3 và 8 chỉ nêu thứ tự 7c, 7d, 7a, 7e; luồng 2a, 2c ở bước 2 và 6a ở bước 6 là bước khác, và mục 8 nói BR-45 chỉ kiểm ở bước 2; P12 F3 kiểm số ghế ở bước 1 rồi BR-04 rồi CheckSaleOpen | Nhóm dự án | Theo thứ tự bước của P04: CheckSaleOpen (2a, 2c), rồi BR-04 (5b, 7c), rồi số ghế (6a), rồi 7d, 7a, 7e. Đổi F3: kiểm nhanh số ghế không ném lỗi sớm hơn BR-04, hoặc ghi rõ thứ tự của F3 vào P04 |
| Q-146 | Kiểm số tiền cổng báo so với bản ghi (BR-91, AMOUNT_MISMATCH) áp dụng cho mọi báo hay chỉ báo thành công chưa xử lý? Báo thất bại và báo trùng mang số tiền khác có bị AMOUNT_MISMATCH không? | DC-PaymentReportService.HandleIpn bước 4; TC chờ Q-146 | BR-91 chỉ nêu 'thanh toán thành công mà số tiền khác'; P12 F3 bước 4 kiểm cho mọi báo trước khi gọi decide | Bên nghiệp vụ | Chỉ kiểm với báo thành công chưa xử lý; báo thất bại (BR-39) và báo trùng (BR-37) không kiểm số tiền, vẫn ghi nhận hoặc đếm trùng |
| Q-147 | StartOnlinePayment, ConfirmCashReceived và GetHold trả lỗi gì khi by hoặc clerk không phải người giữ ghế? | DC-BookTicketsService.StartOnlinePayment, ConfirmCashReceived, GetHold; TC chờ Q-147 | P12 F3 chỉ CancelHold nêu NotFoundError (không lộ sự tồn tại); ba operation còn lại ghi 'kiểm by là người giữ ghế' không nêu lỗi | Nhóm dự án | NotFoundError như CancelHold, không đổi dữ liệu |
| Q-148 | Sau khi HoldExpiryJob.RunDue hết ngân sách 8 giây, cleanupEvents có được gọi không và dùng ngữ cảnh nào? | DC-HoldExpiryJob.RunDue; TC chờ Q-148 | P12 F3 bước 3 'cuối lượt: cleanupEvents' không nêu ngữ cảnh; X1 RV-04 đã nêu nguy cơ ngân sách bị dùng hết trước bước dọn | Nhóm dự án | cleanupEvents luôn chạy với ngữ cảnh riêng có hạn 2 giây; hoặc tách DC-SeatEventCleanupJob như đề xuất của X1 RV-04 |
| Q-149 | Ngưỡng bỏ lượt của ProcessRefund (phần claim còn dưới 10 giây) trùng với biên 10 giây trừ vào hạn gọi cổng; khi phần claim còn lại nằm trong khoảng từ 10 giây trở lên và gần 10 giây thì hạn gọi cổng tính ra gần 0. Ngưỡng bỏ lượt có cần lớn hơn biên cộng một thời gian chờ tối thiểu hữu ích không? | DC-RefundService.ProcessRefund bước 2; TC chờ Q-149 | P12 F3 bước 2 và P09 F7.7: hạn = nhỏ hơn của 30 giây và (claimedUntil - hiện tại - 10 giây); bỏ lượt nếu còn dưới 10 giây | Nhóm dự án | Bỏ lượt khi hạn tính ra dưới 5 giây (tức phần claim còn lại dưới 15 giây) |
| Q-150 | ProcessRefund trả gì khi bỏ lượt vì phần claim còn lại quá ngắn: nil hay lỗi, và RefundOutboxJob xử lý thế nào? | DC-RefundService.ProcessRefund; DC-RefundOutboxJob; TC chờ Q-150 | P12 F3 bước 2 chỉ ghi 'thôi, không gọi cổng và không ghi gì'; F2 chỉ liệt kê ClaimLostError và lỗi CSDL | Nhóm dự án | Trả nil, ghi log mức cảnh báo (dòng được nhận lại sau claimed_until) |
| Q-151 | Khung giờ chiếu (trước hay từ 17 giờ) và ngày trong tuần (Thứ Bảy, Chủ nhật) tính theo múi giờ nào của giờ bắt đầu suất chiếu? | DC-PriceList.DetermineSeatPrice; TC chờ Q-151 | BR-11, BR-12 không nêu múi giờ; P12 F2 PriceQuery.startTime là time.Time | Nhóm dự án | Múi giờ cố định của chuỗi rạp là Asia/Ho_Chi_Minh (UTC+7), đổi startTime sang múi giờ này trước khi xác định khung giờ |
| Q-152 | DC-Showtime.CheckSeatSelection báo lý do nào khi nhiều lý do cùng đúng (EMPTY, TOO_MANY, NOT_IN_AUDITORIUM, DUPLICATE)? | DC-Showtime.CheckSeatSelection; TC chờ Q-152 | P12 F2 chỉ liệt kê bốn lý do, không nêu thứ tự | Nhóm dự án | Thứ tự EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM |
| Q-153 | Thời hạn phiên đăng nhập của quản trị viên (ADMINISTRATOR) là bao lâu? | IF-07.IssueSession; TC chờ Q-153 | Q-129 chỉ nêu khách 24 giờ và nhân viên 8 giờ; NFR-03 tách quản trị viên khỏi nhân viên của NFR-02 | Bên nghiệp vụ | 8 giờ như nhân viên |
| Q-154 | Phiên hết hạn đúng tại expiresAt hay sau expiresAt (VerifySession tại now = expiresAt), và bộ xác thực dùng đồng hồ nào? | IF-07.VerifySession; TC chờ Q-154 | Q-129 và P12 F2 IF-07 không nêu biên và nguồn đồng hồ (thời gian CSDL chỉ dùng trong giao dịch) | Nhóm dự án | Hết hạn khi now >= expiresAt, đồng hồ hệ thống tiêm vào bộ xác thực |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P12 | F2 DC-PaymentTransaction (MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate, RecordRefunded) | Hậu điều kiện không quan sát được qua operation công khai: gatewayTransactionNo, lateReason, duplicateReportCount, refundedTotal không có getter (Status, PaidAt, IsProcessed không đủ) | Đã áp dụng (SY-01, P12 1.5): Thêm getter GatewayTransactionNo(), LateReason(), DuplicateReportCount(), RefundedTotal(); các TC của F2.8 và F2.9 dùng getter đề xuất |
| P12 | F2 DC-RefundRequest | requestType và refundResult (detail của RecordResult, reason của MarkManualRequired) không có getter, trong khi ProcessRefund phải biết requestType = FULL để quyết định xếp email | Đã áp dụng (SY-02, P12 1.5): Thêm RequestType(), RefundResult(); các TC của F2.10 đến F2.13 dùng getter đề xuất |
| P12 | F3 và F6.2 DC-SeatHold.Complete, Cancel, FailPayment | F3 nói không đổi và mang status hiện tại; F6.2 nói gọi Expire trước rồi ném HoldNotActiveError(EXPIRED) (Q-142) | Đã áp dụng (SY-03, P12 1.5; Q-142 giữ mở): Thống nhất theo câu trả lời Q-142; TC at-expiry của F2.3 và replay hết hạn của F2.25 đang chờ |
| P12 | F3 DC-BookTicketsService.HoldSeats bước 1, (e), (f); P04 UC-005 mục 8 (BR-45) | Thứ tự kiểm khác P04 (kiểm nhanh số ghế đứng trước BR-04, CheckSaleOpen đứng sau BR-04) và P04 nói BR-45 chỉ kiểm ở bước 2 trong khi HoldSeats kiểm lại (Q-145) | Chưa áp dụng (SY-04, Cần người quyết, xem design/_sync-log.md): Theo Q-145, ghi thứ tự kiểm trong F3 hoặc sửa mục 8 của UC-005 |
| P12, P13 | F3 DC-BookTicketsService.HoldSeats (g) và IF-18.SaveChanges; P13-schema.sql trigger trg_seat_status_link (fn_seat_status_link_guard) | ReleaseHold(mã cũ) rồi HoldFor trên cùng một SeatStatus trong bộ nhớ, SaveChanges ghi một UPDATE đổi current_hold_id từ lần giữ ghế cũ sang lần giữ ghế mới; trigger từ chối đổi trực tiếp liên kết khi cả hai giá trị khác NULL (chỉ NULL --> giá trị hoặc giá trị --> NULL) | Đã áp dụng (SY-05, P12 1.5, P13 1.4): Cho SaveChanges ghi hai lượt trong cùng giao dịch (trả về AVAILABLE rồi gán lại) hoặc đổi trigger cho phép khi lần giữ ghế cũ đã ở trạng thái cuối; xác nhận bằng ca tích hợp thứ sáu của F3 |
| P12 | F6.2 ST-04 hàng 'Đang chờ kết quả, beginAttempt khi claim còn hiệu lực' | BeginAttempt() không nhận claim nên không phân biệt được claim còn hiệu lực; việc chặn do IF-23.ExtendClaim ở giao dịch 1 | Đã áp dụng (SY-06, P12 1.5): Đổi cột Operation tương ứng của hàng này sang DC-RefundService.ProcessRefund và IF-23.ExtendClaim; ghi BeginAttempt chỉ kiểm trạng thái và lượt còn |
| P12 | F2 DC-RefundService.ProcessRefund (cột Ngoại lệ) | Ghi ErrClaimLost trong khi IF-23 và F1b dùng ClaimLostError | Đã áp dụng (SY-07, P12 1.5): Thống nhất tên ClaimLostError |
| P12 | F3 DC-RefundService.ProcessRefund bước 2 | Ngưỡng bỏ lượt 10 giây trùng với biên 10 giây trừ vào hạn gọi cổng (Q-149); giá trị trả về khi bỏ lượt không nêu (Q-150) | Đã áp dụng (SY-08, P12 1.5, P09 1.6; Q-150 giữ mở): Theo Q-149 và Q-150 |
| P12 | F2, F3 DC-RefundRequest.BeginAttempt; DC-SeatReleaseJob.releaseBatch; DC-CheckTicketService.CheckTicket | Ba nhánh không thể đi tới theo thiết kế: BeginAttempt ở NEW hoặc WAITING_RETRY mà hết lượt (RecordResult chỉ tạo WAITING_RETRY khi còn lượt); ReleaseHold trả false trong releaseBatch (LockByHolds chỉ trả ghế thuộc lô); IF-11.FindByID ném NotFoundError cho suất chiếu của vé (khoá ngoại ON DELETE RESTRICT bảo đảm tồn tại) | Đã áp dụng (SY-09, P12 1.5): Ghi các bất biến này vào F2 hoặc bỏ nhánh; X2 đã loại các nhánh khỏi mẫu số C1 (F4.6) |
| P12 | F3 DC-CancelTicketService.ConfirmCashRefund (cancelInTx nhánh tiền mặt); F2 DC-Booking.CheckCancellationChannel | Luồng UC-008 2c (nhân viên quầy của cụm rạp khác) chỉ được kiểm ở FindBooking; ConfirmCashRefund nhận ticketId độc lập, Booking không giữ cụm rạp, nên yêu cầu gọi trực tiếp bỏ qua kiểm cụm rạp | Đã áp dụng (SY-10, P12 1.5): Thêm lời gọi so cụm rạp (DC-Showtime.BelongsToCinema) vào cancelInTx nhánh tiền mặt; TC của luồng 2c trong F2.33 sẽ thất bại trên thiết kế hiện hành cho tới khi sửa |
| P12 | F3 DC-BookTicketsService.HoldSeats, DC-PaymentReportService.HandleIpn, DC-RefundService.ProcessRefund | V(G) lớn hơn 10: HoldSeats 20, HandleIpn 16, ProcessRefund 13 (F2.25.6, F2.30.6, F2.36.6); riêng HoldSeats đã gộp các lời gọi khoá cùng ngoại lệ nên V(G) thật cao hơn | Chưa áp dụng (SY-11, Cần người quyết, xem design/_sync-log.md): Tách phương thức theo giai đoạn (kiểm tra và định tuyến, khoá, kiểm điều kiện, ghi), trùng hướng X1 RV-01; chạy lại X2 cho ba operation sau khi tách |
| P12 | F2 DC-BookTicketsService.HoldSeats (cột Ngoại lệ) | F3 (d) trả HoldNotActiveError khi requestId trùng lần giữ ghế đã kết thúc hoặc hết hạn, và IF-08.Do có thể trả LockOrderViolationError, nhưng cả hai không có ở F2 | Đã áp dụng (SY-12, P12 1.5): Bổ sung HoldNotActiveError và LockOrderViolationError vào cột Ngoại lệ |
| P12 | F3 DC-PaymentReportService.HandleIpn bước 4 | Kiểm số tiền áp dụng cho mọi báo trong khi BR-91 chỉ nêu báo thành công (Q-146) | Chưa áp dụng (SY-13, Cần người quyết, xem design/_sync-log.md): Theo Q-146 |
| P12, P04 | F3 DC-BookTicketsService.HoldSeats; P04 UC-005 2b; BR-02 | Không có bước kiểm cụm rạp của nhân viên quầy khi giữ ghế (HoldSeats không gọi DC-Showtime.BelongsToCinema) | Chưa áp dụng (SY-14, Cần người quyết, xem design/_sync-log.md): Quyết định nơi kiểm BR-02 (HoldSeats hoặc bước hiển thị sơ đồ ghế) và ghi vào F3 hoặc P04 |
| P12 | F2 DC-Showtime.CheckSeatSelection; DC-BookTicketsService maxSeats | Thứ tự lý do khi nhiều lý do cùng đúng không nêu (Q-152); hằng 8 (BR-05) lặp ở kiểm nhanh của HoldSeats và ở CheckSeatSelection | Chưa áp dụng (SY-15, Cần người quyết, xem design/_sync-log.md): Theo Q-152; giữ một nơi định nghĩa hằng |
| P12, P10 (RV-01 của X1) | DC-BookTicketsService.HoldSeats, CancelHold, ConfirmCashReceived; DC-PaymentReportService.HandleIpn; DC-SeatHold; DC-Booking.NewBooking; DC-Ticket.NewTicket | Nếu áp dụng DC-HoldSettlement.End và Sell, các TC kiểm Expire, ReleaseHold, Complete, MarkSold, NewTicket, NewBooking ngay trong bốn operation phải chuyển sang TC của lớp mới (bảng quyết định theo nhánh SELL, LATE, FAILURE); bốn operation chỉ còn TC điều phối với mock lớp mới. X2 đang bám F3 hiện hành | Chưa áp dụng (SY-16, Cần người quyết, xem design/_sync-log.md): Khi áp dụng RV-01, chạy lại X2 cho PKG-13, PKG-14 (TC F2.25, F2.27, F2.28, F2.30) |
| P12 (RV-05, RV-06, RV-12 của X1) | IF-17, IF-18, IF-20, DC-PgTicketingStore, IF-22, IF-23 | Nếu tách interface theo nhóm bên gọi và tách DC-PgTicketingStore, các bản giả fake IF-17, IF-18, IF-20 trong test double nhỏ hơn (HoldExpiryJob, SeatReleaseJob, CheckTicket chỉ cần một đến hai operation); nếu chuyển IF-22, IF-23 sang PKG-28 thì tên gói trong test double đổi. Số TC và dữ liệu vào không đổi | Chưa áp dụng (SY-17, Cần người quyết, xem design/_sync-log.md): Cập nhật cột Test double và tên interface của F2 khi áp dụng |
| P12 (RV-08, RV-09, RV-11 của X1) | DC-Customer, DC-BoxOfficeClerk.CheckNoActiveSeatHold; DC-CancelTicketService.cancelInTx; DC-RefundRequest.NewFullRefund, NewTicketRefund; DC-PaymentTransaction.NewPending | RV-08: gộp thành một hàm thì các TC của F2.18 còn một hàm nhận chung; RV-09: tách cancelInTx thành cancelOnlineInTx và cancelCashInTx thì CFG của F2.33 tách đôi (V(G) mỗi nửa nhỏ hơn); RV-11: hàm dựng nhận mã thay vì entity thì dữ liệu vào của F2.10 đổi (truyền mã giao dịch, mã vé), kết quả không đổi | Chưa áp dụng (SY-18, Cần người quyết, xem design/_sync-log.md): Chạy lại X2 cho các operation này khi áp dụng |
| P09, P10, P12 (RV-02, RV-03, RV-04 của X1) | PKG-13 và PKG-15 chữ ký công khai; DC-PaymentCallbackController.writeIpnAnswer; DC-HoldExpiryJob.cleanupEvents | RV-02: DTO thay kiểu miền ở chữ ký công khai nên dữ liệu vào của TC HoldSeats, CancelHold, StartOnlinePayment, ConfirmCashReceived, CancelOnlineTicket, CheckTicket ghi lại bằng int64 và string; RV-03: bảng RspCode chuyển sang PKG-22, TC của writeIpnAnswer (để lượt sau) đổi gói; RV-04: tách DC-SeatEventCleanupJob thì Q-148 hết hiệu lực và TC cleanupEvents chuyển sang job mới | Chưa áp dụng (SY-19, Cần người quyết, xem design/_sync-log.md): Chạy lại X2 khi áp dụng; không ảnh hưởng kết quả mong đợi hiện hành |
| Hồ sơ dự án, P09 | project-profile.md (TRANH_CHAP_TAI_NGUYEN); P09 F7 | Hồ sơ chưa có trường TRANH_CHAP_TAI_NGUYEN (X1 RV-15) nên 00-Concurrency.md M9 được áp dụng theo yêu cầu người chạy; P09 F7 chưa có bảng Bảng hỏng nên F4.5 lấy bảy tình huống từ M5 | Chưa áp dụng (SY-20, Cần người quyết, xem design/_sync-log.md): Bật TRANH_CHAP_TAI_NGUYEN = Có và bổ sung Bảng hỏng ở P09 F7; khi đó F4.5 đối chiếu bảng của P09 |
| P13 (RV-07 của X1) | ck_seat_hold_expiry, ck_refund_request_attempts | Nếu RV-07 áp dụng (bỏ hằng 10 phút và 4 lần khỏi CHECK), ca tích hợp 'P13 lưới an toàn' không còn kiểm hằng này; kiểm hằng chỉ còn ở unit test (NewSeatHold, BeginAttempt) | Chưa áp dụng (SY-21, Cần người quyết, xem design/_sync-log.md): Cập nhật ca tích hợp cuối của F3 khi áp dụng |

## Vấn đề còn mở

1. Phạm vi vượt ngưỡng: 39 operation (nhóm theo thiết kế method) và 362 ca unit cộng 22 ca tích hợp, vượt ngưỡng khoảng 10 operation hoặc 60 TC mỗi lần chạy. Theo yêu cầu người chạy (Conventions C9 mức 2) làm một file cho lõi giữ ghế, thanh toán, huỷ vé, hoàn tiền; không chia theo MA_TC_BAT_DAU. Operation Trung bình và Thấp ngoài trọng tâm được bớt trước (F1).
2. Sơ đồ CFG (diagrams/X2-cfg-<DC>-<operation>.drawio, MUC_CHI_TIET = DAY_DU) chưa sinh. Bảng node (N) và cạnh (CE) ở F2.x.6 đã đủ định danh để dựng sơ đồ theo Conventions C7; cần chạy riêng bước vẽ.
3. Operation để lượt sau (F1, chọn Không kèm lý do): PKG-22 (VnpaySigner, VnpayReportDecoder, VnpayUrlBuilder, VnpayRefundClient, PaymentGatewayManager), DC-PaymentCallbackController (bảng RspCode), PKG-24 (SubscriberQueue.Offer biên 256, EmittedEventTracker), PKG-25 (JobLoop.runOnce), DC-RefundOutboxJob, DC-SeatMapService, QueryPaymentStatus. V-01 đến V-11 của VNPay chưa kiểm tài liệu nên oracle của PKG-22 chưa chắc.
4. Chưa có mã nguồn: C0, C1 ở F4.6 là mức thiết kế (CFG từ P12 F3); với operation không có F3 (Showtime, PriceList, Booking, FindBooking, StartChecking, IF-07) mục tiêu C0, C1 ghi Đo khi có mã nguồn. Khi có mã Go, chạy lại bước hộp trắng với go test -cover.
5. Unit test dùng IF-08 giả chạy tuần tự nên chứng minh logic quyết định sau khi có khoá, không chứng minh loại trừ; loại trừ, khoá dòng, NOWAIT, SKIP LOCKED, trigger, ràng buộc P13 và tiến trình chết nằm ở các ca tích hợp (F3, mức Tích hợp). Kế hoạch kiểm thử tích hợp riêng cần dùng lại các ca này.
6. DC-Ticket.RefundAmount: giá vé nhỏ nhất P13 cho phép là 1 đồng (ck_ticket_price) cho khoản hoàn 0 đồng theo BR-31, trong khi ck_refund_request_amount yêu cầu refund_amount lớn hơn 0; TC-114 giữ kết quả 0 theo BR-31. Không lập Q vì giá vé thực tế lớn hơn nhiều; nên có giá vé tối thiểu ở BR bảng giá nếu nhóm muốn loại trường hợp này.
7. Độ phủ C1 chưa đạt 100% ở DC-SeatHold.Complete, Cancel, FailPayment (nhánh now không trước expiryTime chờ Q-142), ConfirmCashReceived và StartOnlinePayment (nhánh người gọi không phải người giữ chờ Q-147); các nhánh không thể đi tới đã loại khỏi mẫu số (F4.6).
8. Các khoảng trống trên thiết kế P12 1.4 từng làm một số TC thất bại có chủ đích (luồng UC-008 2c ở ConfirmCashRefund, ca tích hợp Q-134 với trigger P13) đã được xử lý ở P12 1.5; còn lại: Các TC chờ Q-nn còn mở (Q-142 đến Q-154, giữ nguyên, xem Câu hỏi mở).
9. Các TC mức use case X-09, X-10 (thứ tự A đến D) và hai IPN liên tiếp chạy nhiều operation trên cùng bộ fake nên xếp ở DC-PaymentReportService.HandleIpn; chúng không có đường đi CFG riêng.

