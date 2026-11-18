# X2 - Thiết kế unit test - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | X2 |
| Phiên bản | 2.0 |
| Thay đổi 2.0 | Chạy lại theo P12 2.1 (lõi và sáu file package), P13 2.0, P09 2.1, P08 2.1, X1 2.0 (_sync-log.md, mục Đầu vào cho lần chạy lại X2): thêm DC-HoldSettlement (End, Sell, FinishSale) và chuyển các TC Expire, ReleaseHold, Complete, MarkSold, NewBooking, NewTicket khỏi bốn operation dịch vụ; viết lại CFG của HoldSeats, CancelHold, ConfirmCashReceived, StartOnlinePayment, HandleIpn, CancelOnlineTicket và ConfirmCashRefund (tách nhánh trực tuyến và tiền mặt); đóng các TC chờ Q-142 đến Q-154; thêm hạng khoá 0 đến 13 và AcquireValue, kiểm phiên theo mốc truy cập (BR-101), đăng ký, đăng nhập, quản lý tài khoản nhân viên, lịch sử đặt vé và snapshot vé (BR-140), quy tắc lịch chiếu và danh mục, báo cáo, lọc suất chiếu, ánh xạ lỗi HTTP, kiểm phiên của AuthFilter, hàng đợi sự kiện ghế, giới hạn kết nối, JobLoop; thêm ca tích hợp cho X-24 đến X-33, claim_token, trg_seat_status_link, EXCLUDE suất chiếu; F4.4, F4.5 đối chiếu P08 F4b và P09 F7.10 |
| Thay đổi 1.2 | Bản trước (X3 lần 2): Q-142 đến Q-154 đánh dấu đã trả lời; chưa chạy lại X2 |
| Đầu vào đã dùng | project-profile.md; P12-class-design.md 2.1 (F1, F1b, F2, F3, F6, Câu hỏi mở, Đề xuất sửa) cùng sáu file P12-class-design/ (PKG-05 đến PKG-10, PKG-20, PKG-23, PKG-29, PKG-31; PKG-11; PKG-16, PKG-27; PKG-17, PKG-18, PKG-30, PKG-33; PKG-19, PKG-32); P13-data-model.md 2.0, P13-schema.sql và P13-schema-tests.sql (207 case, PostgreSQL 16, chỉ tham chiếu); P09-architecture.md 2.1 (F7.3, F7.4, F7.6, F7.7, F7.9, F7.10, F7.11, F7.12); P08-analysis-model.md 2.1 (F4a EX-01 đến EX-22, F4b X-01 đến X-33); P06-supplementary-spec.md 1.4 (BR, NFR); P04-uc-specs/_BR-register.md; P04-uc-specs/UC-001, UC-004, UC-005, UC-006, UC-007, UC-008, UC-009, UC-010 đến UC-017 (luồng thay thế); X1-design-review.md 2.0 (Câu hỏi mở, F2); _sync-log.md (Đầu vào cho lần chạy lại X2); 00-Concurrency.md (M5, M9). Không có mã nguồn |
| Phạm vi | Toàn hệ thống theo P12 2.1: lõi giữ ghế, thanh toán, huỷ vé, soát vé (PKG-12 đến PKG-15, PKG-21, PKG-22, PKG-24 đến PKG-26, PKG-28), tài khoản và nhân viên (PKG-19, PKG-32), danh mục, lịch chiếu và báo cáo (PKG-16, PKG-17, PKG-18, PKG-27, PKG-30, PKG-33), PKG-11 (ánh xạ lỗi, AuthFilter, giới hạn kết nối). Ngoài lần chạy này: điều phối UC-010 đến UC-014, giao diện React (F1) |
| Tham số lần chạy | PHAM_VI_TEST: toàn hệ thống, ưu tiên chiều sâu ở giữ ghế, thanh toán, hoàn tiền, kiểm phiên và các ràng buộc tranh chấp; MUC_TIEU_PHU: mặc định (100% C1 cho operation ưu tiên Cao, 100% C0 cho còn lại); SINH_MA_TEST: Không có; MA_TC_BAT_DAU: Không có (giữ mã TC-001 đến TC-384 của 1.x, mã mới từ TC-385) |
| Chế độ | NGHIEM_NGAT; MUC_CHI_TIET = DAY_DU; TRANH_CHAP_TAI_NGUYEN = Có; CONG_NGHE: Go (net/http, pgx), PostgreSQL 15 trở lên, VNPay sandbox |
| Mã TC đã cấp | TC-001 đến TC-659 (653 TC hiện hành: 609 unit, 42 tích hợp, 2 chờ Q-nn); mã bỏ không cấp lại: TC-004, TC-069, TC-074, TC-115, TC-141, TC-163; TC-385 đến TC-659 là mã mới của 2.0 |
| Mã Q, ASM cuối đã cấp | Q-355 (Q-352 đến Q-355 mới của 2.0); không có ASM (NGHIEM_NGAT) |

## F1. Bảng chọn operation

Quy ước dùng chung cho mọi ca thử:

- Thời gian: ngày 2026-11-10 (Thứ Ba), múi giờ UTC+7. Lần giữ ghế H1 có holdTime 10:00:00.000, expiryTime E = 10:10:00.000; E - 1ms = 10:09:59.999. Suất chiếu 55 bắt đầu 20:00:00.000, mở bán 2026-11-09 08:00, phòng 7, cụm rạp 2. Thời điểm hiện tại luôn là tham số now hoặc kết quả stub của IF-25.Now, không dùng đồng hồ hệ thống.
- Tiền: Money là số đồng nguyên; ghế STANDARD 90.000 đồng, VIP 120.000 đồng; hoàn 70% làm tròn xuống đồng.
- Trạng thái đầu của đối tượng miền luôn dựng bằng operation công khai của P12 (NewSeatHold, Complete, Expire, BeginAttempt, RecordResult...), không dùng bộ dựng riêng; nếu không dựng được thì ghi ở cột Điều kiện đầu và ở Đề xuất sửa artifact trước.
- Test double của lớp dịch vụ: IF-08 giả (fake) chạy fn một lần trên bản sao in-memory và hoàn lại khi fn trả lỗi, mang LockOrderGuard thật; các store giả gọi Acquire theo hạng cố định của từng operation (P12 F2). Vì vậy mọi TC lớp dịch vụ đều ngầm khẳng định thứ tự khoá 14 hạng (0 đến 13) không bị vi phạm.
- Ca tích hợp: các ca cần PostgreSQL thật, nhiều goroutine hoặc nhiều bản backend, hoặc tiến trình chết. Cột Mức của F3 ghi Tích hợp; chúng không tính vào độ phủ C0, C1 của unit test. Kết quả mong đợi bắt đầu bằng Chưa xác định: chờ Q-nn là TC chờ câu hỏi, không tính vào độ phủ.
- Mã nội bộ: EC, BV, DT<k>-R<n>, N<n>, CE<n> theo prompt; CT-nn là mã chuyển trạng thái hoặc cặp (trạng thái, sự kiện) bị từ chối; P<n> là đường đi cơ sở; đều đánh số liên tục trong file.
- Dữ liệu vào dạng holdRef: ở CancelHold, StartOnlinePayment, ConfirmCashReceived, GetHold, ký hiệu H1 là holdRef của lần giữ ghế H1 (P12 2.1), 9999 là holdRef không tồn tại.
- DC-HoldSettlement (lớp miền không trạng thái, không I/O) được dùng đối tượng thật ở mọi TC lớp dịch vụ, không giả lập; các TC kiểm Expire, ReleaseHold, Complete, MarkSold, NewBooking, NewTicket trong HoldSeats, CancelHold, ConfirmCashReceived, HandleIpn nằm ở F2.41, F2.42.
- Mã TC đã bỏ không cấp lại: TC-004, TC-069, TC-074, TC-115, TC-141, TC-163 (giá trị ngoài miền là tiền điều kiện của bên gọi, Q-144).
- Các tham chiếu P13: 207 case của P13-schema-tests.sql (PostgreSQL 16) không lặp lại ở đây; X2 chỉ kiểm hành vi của lớp ứng dụng khi gặp các ràng buộc đó.

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
| DC-PaymentReportService.ResolveReturnedPayment, QueryPaymentStatus, logUnrecognized | ủy quyền IF-02, đọc dữ liệu, ghi log | Trung bình | Không: ủy quyền nguyên lời gọi hoặc chỉ đọc (Q-126); logUnrecognized được kiểm bằng spy ở HandleIpn |
| DC-RefundService.toAttempt, LockPaymentOfTicket | chuyển đổi, ủy quyền | Thấp | Không: toAttempt là phép ánh xạ enumeration; LockPaymentOfTicket phủ qua CancelOnlineTicket (thứ tự khoá 6, 7, 8) |
| DC-PgUnitOfWork.Do, runOnce, isRetryable; DC-PgTx; DC-ConnectionPools; DC-SeatEventWriter; DC-PgTicketingStore (lockRows, mapPgError, SaveChanges); DC-PgCinemaOperationsStore; DC-PgSeatEventStore; DC-PgOutboxStore | truy cập CSDL, khoá, thử lại | Cao | Không (unit): cần PostgreSQL thật (khoá dòng, NOWAIT, SKIP LOCKED, 40P01); ca tích hợp ở F2.40 (TC mức Tích hợp) |
| IF-11, IF-12, IF-13, IF-16 đến IF-21, IF-22, IF-23 (operation của interface store) | truy cập CSDL | Cao | Không (unit): chữ ký và SQL kiểm bằng ca tích hợp (Claim, ExtendClaim, AddRefunded, LockForHold, LockExpiredBatch); trong unit test dùng làm test double |
| IF-24, IF-25, DC-RandomCodeGenerator.NewHoldRef, NewTransactionCode, NewBookingCode, NewTicketCode | sinh số ngẫu nhiên, thời gian | Thấp | Không: giá trị ngẫu nhiên được tiêm vào (stub); định dạng (UUID v4, 20 chữ số, 16 ký tự) kiểm khi có mã nguồn |
| DC-HoldSettlement.End | sự kiện ST (ST-01 expire, cancel, failPayment; ST-02 releaseHold) / bảng quyết định / vòng lặp ghế | Cao | Có (F2.41) |
| DC-HoldSettlement.Sell, FinishSale | BR (BR-67, BR-80, BR-85, BR-140) / sự kiện ST (ST-01 complete, ST-02 markSold, ST-03 tạo vé) | Cao | Có (F2.42) |
| DC-LockOrderGuard.AcquireValue | BR/bất biến khoá (hạng 0, 11, 12, 13; Q-324) / rẽ nhánh | Cao | Có (F2.43) |
| DC-Staff.CheckAccessUnchanged; DC-BoxOfficeClerk.CheckAccessCurrent; DC-AccessCheckService.CheckStaffAccess | BR (BR-97, BR-100, BR-101) / kiểm tra điều kiện | Cao | Có (F2.44) |
| DC-Customer.CheckRegistrationData; DC-RegisterAccountService.RegisterAccount | BR (BR-81, BR-82, BR-98, BR-99) / kiểm tra hợp lệ / điều phối UC-001 | Cao | Có (F2.45) |
| DC-LoginService.LoginCustomer, LoginStaff | BR (BR-97, NFR-01 đến NFR-03) / rẽ nhánh / điều phối | Cao | Có (F2.46) |
| DC-Staff.CheckStaffData, CheckRoleAndCinema, SaveStaffChanges, LockStaff, UnlockStaff, RenameStaff, ResetStaffPassword; DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | BR (BR-78, BR-79, BR-95, BR-100 đến BR-102) / kiểm tra hợp lệ / sự kiện ST-12 | Cao | Có (F2.47) |
| DC-Customer.CheckOwnsBooking; DC-Ticket.Snapshot; DC-Booking.Summary; DC-ViewBookingHistoryService.ListHistory, FindBookingTickets | BR (BR-94, BR-140) / điều phối UC-007 | Cao | Có (F2.48) |
| DC-BookTicketsService.FindActiveHold, GetHold; DC-CancelTicketService.PrepareCashRefund | điều phối UC-005, UC-008 / BR (BR-04, BR-17, BR-18, Q-147) | Trung bình | Có (F2.49) |
| DC-Movie.CheckReleasedInFormat, CheckWithinRunPeriod, RunStatusAt; DC-Auditorium.CheckSupportsFormat, CheckRoomGap, CheckNeverScheduled; DC-Showtime.CheckNotStarted, CheckRoomChangeAllowed; DC-Cinema.NormalizeName, CheckNameNotTaken; CheckUnchangedSinceDisplayed của Movie, Cinema, Auditorium | BR (BR-47 đến BR-51, BR-56, BR-57, BR-76, BR-92, BR-138, BR-141, BR-142, BR-146, BR-147) / kiểm tra điều kiện, thời gian | Cao | Có (F2.50) |
| DC-ReportPeriod.CheckValid, ToRange; DC-ReportGroup.AddFigures, OccupancyPercent; DC-ViewCinemaReportService.ViewCinemaReport | BR (BR-88; GL-66) / tính toán / kiểm tra hợp lệ | Cao | Có (F2.51) |
| DC-BrowseShowtimesService.selectShowtimes | BR (BR-56, BR-58) / rẽ nhánh lọc | Trung bình | Có (F2.52) |
| DC-HttpErrorMapper.Classify; DC-AuthFilter.Require | điều phối / ánh xạ lỗi theo F2b / BR-101 | Cao | Có (F2.53) |
| IF-07.HashPassword, CheckRole và claims mang accessChangedAt | kiểm tra hợp lệ / hạn thời gian | Trung bình | Có (F2.54) |
| Ca tích hợp bổ sung (X-24 đến X-33, claim_token, trg_seat_status_link, EXCLUDE suất chiếu, kiểm phiên) | tranh chấp đồng thời, khoá dòng và khoá giá trị, tiến trình chết | Cao | Có (F2.55) |
| DC-PaymentCallbackController.writeIpnAnswer; DC-VnpaySigner.Sign, Verify; DC-VnpayReportDecoder.Decode | chuyển đổi dữ liệu, ký, gọi hệ thống ngoài | Trung bình | Có (F2.56; Decode chờ Q-355) |
| DC-SubscriberQueue.Offer, Close; DC-EmittedEventTracker; DC-SeatEventPoller.pollOnce; DC-IpConnectionLimiter.TryAcquire; DC-JobLoop.runOnce, Run | vòng lặp, biên 256, biên 10 kết nối, thời gian | Trung bình | Có (F2.57) |
| DC-BookTicketsService.GetHold, FindActiveHold | đọc dữ liệu | Trung bình | Có (F2.49) |
| DC-SeatMapService.GetSnapshot, OpenStream; DC-SeatEventHubManager.Subscribe; DC-SubscriberRegistry; DC-SeatReplayReader.Replay | ủy quyền IF-04, đăng ký hàng đợi | Thấp | Không: chỉ ủy quyền hoặc nối các lớp đã kiểm ở F2.57; thứ tự Add trước Replay kiểm bằng ca tích hợp T3 của P09 F7.9 |
| DC-RefundOutboxJob.RunDue; DC-EmailOutboxJob.RunDue | điều phối công việc nền, song song | Trung bình | Không: logic xử lý một dòng nằm ở ProcessRefund (F2.36); claim từng dòng và SKIP LOCKED là ca tích hợp (F2.55 TC claim_token, F2.40) |
| DC-PaymentCallbackController.HandleIpn, HandleReturn, HandlePaymentStatus | giải mã, gọi service, ghi kết quả | Thấp | Không: chỉ ủy quyền nguyên lời gọi (Bước 1); ánh xạ RspCode kiểm ở F2.56 |
| DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-PaymentGatewayManager, DC-PaymentReportReceiver, DC-GatewayConfig; IF-01, IF-02 | gọi hệ thống ngoài, dựng địa chỉ ký | Trung bình | Không: oracle phụ thuộc V-01 đến V-11 của VNPay chưa kiểm tài liệu (Q-355); kiểm với VNPay sandbox khi có tài liệu |
| DC-ManageMoviesService, DC-ManageCinemasService, DC-ManageAuditoriumsService, DC-ManagePriceListService, DC-ScheduleShowtimesService (UC-010 đến UC-014); DC-ViewChainReportService; DC-BrowseMoviesService | điều phối UC có nhiều luồng thay thế | Trung bình | Không: vượt ngưỡng 60 TC mỗi lần chạy; quy tắc của entity đã kiểm ở F2.50, F2.51, loại trừ ở F2.55; làm tiếp bằng MA_TC_BAT_DAU (Vấn đề còn mở 2) |
| PKG-05 đến PKG-10, PKG-29, PKG-31 (React: boundary, hook, store, ApiClient) và DC-SessionClient | giao diện, định dạng hiển thị | Thấp | Không: kiểm bằng công cụ UI riêng theo P11a; mã lỗi hiển thị đối chiếu bảng F2b ở F2.53 |
| DC-PgUnitOfWork.Do, runOnce, LockValue; DC-PgTx; DC-ConnectionPools; DC-PgTicketingStore; mọi IF-11 đến IF-23, IF-26 đến IF-28 (hiện thực SQL) | truy cập CSDL, khoá, thử lại | Cao | Không (unit): cần PostgreSQL thật; ca tích hợp F2.40, F2.55; ràng buộc cấp dữ liệu đã chạy ở P13-schema-tests.sql |

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
| EC-03 | holder, requestId, holdRef | rỗng, nil hoặc zero (P12 không nêu hành vi) | Không hợp lệ | requestId = rỗng | tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |

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
| EC-08 | status = ACTIVE, now | now >= expiryTime (bên gọi chưa gọi Expire) | Không hợp lệ | now = E | P12 F3, F6.2; Q-142 đã trả lời (entity không tự hết hạn) |
| EC-09 | status | trạng thái cuối (COMPLETED, EXPIRED, CANCELLED, PAYMENT_FAILED) | Không hợp lệ | EXPIRED | P12 F6.2; BR-86 |

#### F2.3.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-05 | EC-07 | now = E - 1ms | EC-07 | Chuyển sang trạng thái đích |
| BV-06 | EC-08 | now = E | EC-08 | HoldNotActiveError mang Status = ACTIVE, trạng thái không đổi (Q-142) |
| BV-07 | EC-08 | now = E + 1ms | EC-08 | HoldNotActiveError mang Status = ACTIVE, trạng thái không đổi (Q-142) |

#### F2.3.5 Chuyển trạng thái

| CT | Trạng thái đầu | Sự kiện (tham số) | Guard đúng/sai | Kết quả mong đợi | Trạng thái sau | ST nguồn |
|---|---|---|---|---|---|---|
| CT-05 | Đang giữ | complete(now) [now < expiryTime] | đúng | Trả nil | Đã hoàn tất (COMPLETED) | ST-01 STT 2 |
| CT-06 | Đang giữ | cancel(now) [now < expiryTime] | đúng | Trả nil | Đã huỷ (CANCELLED) | ST-01 STT 4 |
| CT-07 | Đang giữ | failPayment(now) [now < expiryTime] | đúng | Trả nil | Thanh toán thất bại (PAYMENT_FAILED) | ST-01 STT 5 |
| CT-08 | Đang giữ | complete(now) [now >= expiryTime] | sai | HoldNotActiveError mang Status = ACTIVE (Q-142) | Đang giữ | P12 F6.2 / F3 |
| CT-09 | Đang giữ | cancel(now) [now >= expiryTime] | sai | HoldNotActiveError mang Status = ACTIVE (Q-142) | Đang giữ | P12 F6.2 / F3 |
| CT-10 | Đang giữ | failPayment(now) [now >= expiryTime] | sai | HoldNotActiveError mang Status = ACTIVE (Q-142) | Đang giữ | P12 F6.2 / F3 |
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
| Chưa nêu | Ghế trong danh sách không thuộc lần giữ ghế (currentHold khác hoặc không HELD); danh sách rỗng | P12 F2 (Q-143 đã trả lời: ghế HELD của lần giữ ghế khác bị bỏ qua, danh sách rỗng trả 0) |
| Không áp dụng | Không áp dụng: F2.5.4 (một điều kiện), F2.5.5 (không là sự kiện ST), F2.5.6 (tổng một vòng lặp đơn, ghi ở bảng vòng lặp) | - |

#### F2.5.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-13 | seats | mọi ghế HELD bởi lần giữ ghế này, 1 đến 8 ghế | Hợp lệ | 3 ghế: 90.000, 90.000, 120.000 | BR-65; BR-05 |
| EC-14 | seats | có ghế không thuộc lần giữ ghế này (currentHold khác hoặc không HELD) | Hợp lệ (ghế đó bị bỏ qua) | 1 ghế HELD bởi hold khác | P12 F2; Q-143 |
| EC-15 | seats | danh sách rỗng | Hợp lệ (trả 0) | [] | P12 F2; Q-143 |

#### F2.5.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-10 | kích thước seats (EC-13) | 1 ghế | EC-13 | Tổng = giá ghế đó |
| BV-11 | kích thước seats (EC-13) | 8 ghế (tối đa BR-05) | EC-13 | Tổng = 8 x 90.000 = 720.000 |

Vòng lặp:

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử (0, 1, m, n-1, n, n+1) | TC |
|---|---|---|---|---|
| cộng heldPrice theo từng ghế | 8 (BR-05) | 3 | 0, 1, 3, 8; n - 1 và n + 1 không thêm TC | TC-025, TC-026, TC-027 |

Ghi chú vòng lặp: cộng heldPrice theo từng ghế. n = 8 (BR-05), m = 3. Số lần kiểm thử: 0 (EC-15), 1, m = 3, 8; n - 1 = 7 và n + 1 = 9 không thêm TC vì kích thước nhóm ghế do HoldSeats chặn trước (SeatSelectionError ở DC-Showtime.CheckSeatSelection), không phải trách nhiệm của operation này.

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
| EC-29 | amount | <= 0 | Không hợp lệ | 0 | tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |

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
| EC-33 | amount, txn, ticket | amount <= 0, txn hoặc ticket nil | Không hợp lệ | amount 0 | tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |

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
| EC-57 | price | <= 0 | Không hợp lệ | 0 | P13 ck_ticket_price (price > 0); tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |

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
| Giới hạn của operation | Booking không giữ cụm rạp nên luồng 2c do ConfirmCashRefund kiểm bằng Showtime.BelongsToCinema(clerk.cinemaId) (P12 1.5 trở đi) | P12 F2, F3 |
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
| Hạng | CINEMA=0, PRICE_LIST=1, AUDITORIUM=2, SHOWTIME=3, HOLDER=4 (Customer hoặc Staff), SEAT_HOLD=5, SEAT_STATUS=6, PAYMENT_TRANSACTION=7, TICKET=8, REFUND_REQUEST=9, MOVIE=10, CUSTOMER_EMAIL=11, CUSTOMER_PHONE=12, STAFF_EMAIL=13 (14 hạng); khoá giá trị kiểm ở F2.43 | P12 F1b DC-LockRank; P09 F7.3 |
| Chưa nêu | AcquireAll với hai keys bằng nhau: tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |
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
| Thứ tự lý do | EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM; hằng 8 là DC-Showtime.MaxSeatsPerHold | P12 F2; Q-152 (đã trả lời) |
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
| EC-83 | lastChangedAt so với displayedAt | lastChangedAt < displayedAt (không xảy ra vì mốc lấy từ chính LastChangedAt) | Không hợp lệ | 08:59:59.999 | tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |

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
| Múi giờ | startTime đổi sang Asia/Ho_Chi_Minh (UTC+7) trước khi xác định khung giờ và ngày trong tuần | P12 F2; Q-151 (đã trả lời) |
| Không áp dụng | Không áp dụng: F2.24.4 (khung giờ là hàm của hai điều kiện độc lập, phân vùng theo đầu ra đủ), F2.24.5, F2.24.6 (không có F3 riêng) | - |

#### F2.24.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-84 | khung giờ | ngày thường (Thứ Hai đến Thứ Sáu), trước 17:00 | Hợp lệ | Thứ Tư 2026-11-11 10:00 | BR-11, BR-12 |
| EC-85 | khung giờ | ngày thường, từ 17:00 | Hợp lệ | Thứ Tư 20:00 | BR-12 |
| EC-86 | khung giờ | cuối tuần (Thứ Bảy, Chủ nhật), trước 17:00 | Hợp lệ | Thứ Bảy 2026-11-14 10:00 | BR-12 |
| EC-87 | khung giờ | cuối tuần, từ 17:00 | Hợp lệ | Chủ nhật 2026-11-15 20:00 | BR-12 |
| EC-88 | tổ hợp (loại phòng, định dạng, loại ghế) | không có mục giá | Không hợp lệ | IMAX, 3D, VIP | BR-72 |
| EC-89 | startTime | mang múi giờ khác UTC+7 | Hợp lệ (đổi sang UTC+7) | 2026-11-13 10:00:00Z | Q-151 |

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
| Chữ ký | HoldSeats(ctx Ctx, req HoldSeatsRequest) (HoldResult, error); req gồm showtimeId, seatIds, holder, holderCinemaId (nhân viên quầy), accessChangedAt (nhân viên quầy), requestId, displayedAt | P12 F2, F1b |
| Hậu điều kiện | SeatHold ACTIVE, các ghế HELD với heldPrice, một dòng seat_event mỗi suất chiếu, không NOTIFY; requestId trùng lần giữ ghế ACTIVE chưa quá hạn của chính người giữ thì trả lại lần đó (replayed) | P12 F2, F3 (d) |
| Ngoại lệ | ChannelMismatchError, StaffAccessChangedError, ShowtimeNotOpenError, ShowtimeChangedError, SeatSelectionError, HolderBusyError, HoldNotActiveError, SeatUnavailableError, NotFoundError, LockOrderViolationError, SystemBusyError | P12 F2 |
| Thao tác nguyên tử | EX-01; X-01, X-02, X-03, X-04, X-13, X-21, X-33 | P08 F4b |
| Thứ tự báo lỗi cả hàm | 2b (BR-02), 2a và 2c (mở bán), 7c (BR-04), 6a (số ghế), 7d, 7a, 7e (Q-145) | P12 F3 (e), (f); P04 UC-005 mục 3, 8 |
| Luồng P04 | UC-005 2a, 2b, 2c, 5b, 6a, 7a, 7c, 7d, 7e | P04 UC-005 |
| Hạn tổng | TxOptions.deadline = lúc nhận yêu cầu + 1,8 giây (NFR-06) | P12 F3; P09 F7.3 |
| Không áp dụng | F2.25.5 (không là sự kiện ST; chuyển trạng thái kiểm ở DC-HoldSettlement, DC-SeatHold, DC-SeatStatus) | - |

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
| EC-186 | người giữ là nhân viên quầy, cụm rạp của dòng Staff đã khoá | khớp cụm rạp của suất chiếu | Hợp lệ | CLERK 3, cụm rạp 2 | BR-02; UC-005 2b |
| EC-187 | người giữ là nhân viên quầy, cụm rạp của dòng Staff đã khoá | khác cụm rạp của suất chiếu | Không hợp lệ | CLERK 5, cụm rạp 3 | BR-02; UC-005 2b |
| EC-188 | trạng thái và accessChangedAt của dòng Staff (hạng 4) | Đang hoạt động và accessChangedAt bằng mốc của phiên | Hợp lệ | 2026-11-10 07:00:00.000001 | BR-101; X-33 |
| EC-189 | trạng thái và accessChangedAt của dòng Staff (hạng 4) | Bị khoá hoặc accessChangedAt khác mốc của phiên | Không hợp lệ | LOCKED; mốc lệch 1 micro giây | BR-101; X-33 |

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
| C1: suất chiếu chưa mở bán hoặc đã bắt đầu (UC-005 2a, 2c) | N | Y | N | N | N | N | N | Y | N | Y |
| C2: số ghế rỗng hoặc quá 8 (6a) | N | N | Y | N | N | N | N | N | Y | Y |
| C3: người giữ còn lần giữ ghế chưa kết thúc (7c) | N | N | N | Y | N | N | N | Y | Y | - |
| C4: suất chiếu đã đổi (7d) | N | N | N | - | Y | N | N | - | - | - |
| C5: có ghế không trống (7a) | N | N | N | - | - | Y | N | - | - | - |
| C6: thiếu giá của một ghế (7e) | N | N | N | - | - | - | Y | - | - | - |
| A0: giữ thành công | X | - | - | - | - | - | - | - | - | - |
| A1: ShowtimeNotOpenError | - | X | - | - | - | - | - | X | - | X |
| A2: SeatSelectionError | - | - | X | - | - | - | - | - | - | - |
| A3: HolderBusyError | - | - | - | X | - | - | - | - | X | - |
| A4: ShowtimeChangedError | - | - | - | - | X | - | - | - | - | - |
| A5: SeatUnavailableError | - | - | - | - | - | X | - | - | - | - |
| A6: NotFoundError (không có giá) | - | - | - | - | - | - | X | - | - | - |
```

Căn cứ gộp: thứ tự báo lỗi cả hàm 2a, 2c, 7c, 6a, 7d, 7a, 7e do Q-145 (đã trả lời) và P12 F3 (f) quyết định; vì thế C2 đến C6 gộp bằng "-" khi một điều kiện đứng trước đã sai (R4 đến R6, R8, R10). R9 (C2 và C3 cùng sai) cho HolderBusyError vì 7c đứng trước 6a. R8, R9, R10 là ba quy tắc vi phạm hai điều kiện, mỗi quy tắc một TC; không gộp thêm với R2, R3 vì kết quả phụ thuộc thứ tự.

Bảng DT10 (thứ tự 2b, 2a, 2c): nhân viên quầy sai cụm rạp kiểm trước mở bán.

```text
| Điều kiện / Hành động | DT10-R1 | DT10-R2 | DT10-R3 | DT10-R4 |
| C1: nhân viên quầy thuộc cụm rạp khác (2b) | Y | Y | N | N |
| C2: suất chiếu chưa mở bán hoặc đã bắt đầu (2a, 2c) | Y | N | Y | N |
| A1: ChannelMismatchError | X | X | - | - |
| A2: ShowtimeNotOpenError | - | - | X | - |
| A3: tiếp tục kiểm các điều kiện sau | - | - | - | X |
```

Căn cứ: thứ tự 2b trước 2a, 2c ghi ở P12 F3 (e) ("thứ tự báo lỗi cả hàm: 2b, 2a và 2c ..."); P04 UC-005 không nêu thứ tự giữa 2b và 2a nên chỉ P12 F3 làm căn cứ, ghi Đề xuất sửa P12 bổ sung thứ tự vào F2 (Q-353 ở Câu hỏi mở).

#### F2.25.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N324 | bắt đầu | bắt đầu |
| N325 | selectionFlaw = EMPTY khi seatIds rỗng, TOO_MANY khi quá MaxSeatsPerHold (chỉ ghi nhớ) | khối lệnh |
| N326 | FindRouting ném NotFoundError? | quyết định |
| N327 | trả NotFoundError (Do 0 lần) | khối lệnh |
| N328 | IF-08.Do ném SystemBusyError (hết hạn tổng, hết lần thử)? | quyết định |
| N329 | trả SystemBusyError; rollback | khối lệnh |
| N330 | khoá hạng 1, 2, 3, 4 (LockHolder hoặc LockClerk) | khối lệnh |
| N331 | người giữ là nhân viên quầy? | quyết định |
| N332 | CheckAccessCurrent(accessChangedAt) ném StaffAccessChangedError? | quyết định |
| N333 | trả StaffAccessChangedError; rollback | khối lệnh |
| N334 | LockUnfinishedOrByRequest (hạng 5); now = tx.Now | khối lệnh |
| N335 | phòng chiếu của suất chiếu khác kết quả FindRouting? | quyết định |
| N336 | trả ShowtimeChangedError | khối lệnh |
| N337 | có lần giữ ghế cùng requestId của chính người giữ? | quyết định |
| N338 | lần giữ ghế đó ACTIVE và chưa quá hạn? | quyết định |
| N339 | trả lại lần giữ ghế đó (replayed = true) | khối lệnh |
| N340 | trả HoldNotActiveError mang status hiện tại | khối lệnh |
| N341 | người giữ là nhân viên quầy và BelongsToCinema sai? | quyết định |
| N342 | trả ChannelMismatchError | khối lệnh |
| N343 | CheckSaleOpen ném ShowtimeNotOpenError? | quyết định |
| N344 | trả ShowtimeNotOpenError | khối lệnh |
| N345 | có lần giữ ghế ACTIVE cũ của người giữ đã quá hạn? | quyết định |
| N346 | End(now, cũ, EXPIRY, nil); UpdateStatus; nhớ mã lần giữ ghế cũ | khối lệnh |
| N347 | CheckNoActiveSeatHold(now) ném HolderBusyError? | quyết định |
| N348 | trả HolderBusyError | khối lệnh |
| N349 | selectionFlaw khác rỗng? | quyết định |
| N350 | trả SeatSelectionError(EMPTY hoặc TOO_MANY) | khối lệnh |
| N351 | CheckUnchangedSince(displayedAt) ném ShowtimeChangedError? | quyết định |
| N352 | FindSeats(seatIds) | khối lệnh |
| N353 | CheckSeatSelection ném SeatSelectionError (DUPLICATE, NOT_IN_AUDITORIUM)? | quyết định |
| N354 | trả SeatSelectionError | khối lệnh |
| N355 | LockForHold (hạng 6, NOWAIT) trả 55P03? | quyết định |
| N356 | FindBeingReleased trả true (sau rollback)? | quyết định |
| N357 | trả SeatUnavailableError(BEING_RELEASED) | khối lệnh |
| N358 | trả SeatUnavailableError(LOCKED_BY_OTHER) | khối lệnh |
| N359 | số dòng khoá được khác số ghế yêu cầu? | quyết định |
| N360 | trả SeatUnavailableError | khối lệnh |
| N361 | có ghế còn trỏ tới lần giữ ghế cũ vừa hết hạn? | quyết định |
| N362 | End(now, cũ, EXPIRY, các ghế vừa khoá); SaveChanges lần 1 (Trống) | khối lệnh |
| N363 | có ghế không ở trạng thái Trống? | quyết định |
| N364 | trả SeatUnavailableError(NOT_AVAILABLE) | khối lệnh |
| N365 | DetermineSeatPrice ném NotFoundError cho một ghế? | quyết định |
| N366 | trả NotFoundError (không có giá, BR-72) | khối lệnh |
| N367 | NewSeatHold; Insert; HoldFor từng ghế; SaveChanges lần 2; commit; dựng HoldResult | khối lệnh |
| N368 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE413 | N324 | N325 |  |
| CE414 | N325 | N326 |  |
| CE415 | N326 | N327 | Đúng |
| CE416 | N326 | N328 | Sai |
| CE417 | N327 | N368 |  |
| CE418 | N328 | N329 | Đúng |
| CE419 | N328 | N330 | Sai |
| CE420 | N329 | N368 |  |
| CE421 | N330 | N331 |  |
| CE422 | N331 | N332 | Đúng |
| CE423 | N331 | N334 | Sai |
| CE424 | N332 | N333 | Đúng |
| CE425 | N332 | N334 | Sai |
| CE426 | N333 | N368 |  |
| CE427 | N334 | N335 |  |
| CE428 | N335 | N336 | Đúng |
| CE429 | N335 | N337 | Sai |
| CE430 | N336 | N368 |  |
| CE431 | N337 | N338 | Đúng |
| CE432 | N337 | N341 | Sai |
| CE433 | N338 | N339 | Đúng |
| CE434 | N338 | N340 | Sai |
| CE435 | N339 | N368 |  |
| CE436 | N340 | N368 |  |
| CE437 | N341 | N342 | Đúng |
| CE438 | N341 | N343 | Sai |
| CE439 | N342 | N368 |  |
| CE440 | N343 | N344 | Đúng |
| CE441 | N343 | N345 | Sai |
| CE442 | N344 | N368 |  |
| CE443 | N345 | N346 | Đúng |
| CE444 | N345 | N347 | Sai |
| CE445 | N346 | N349 |  |
| CE446 | N347 | N348 | Đúng |
| CE447 | N347 | N349 | Sai |
| CE448 | N348 | N368 |  |
| CE449 | N349 | N350 | Đúng |
| CE450 | N349 | N351 | Sai |
| CE451 | N350 | N368 |  |
| CE452 | N351 | N336 | Đúng |
| CE453 | N351 | N352 | Sai |
| CE454 | N352 | N353 |  |
| CE455 | N353 | N354 | Đúng |
| CE456 | N353 | N355 | Sai |
| CE457 | N354 | N368 |  |
| CE458 | N355 | N356 | Đúng |
| CE459 | N355 | N359 | Sai |
| CE460 | N356 | N357 | Đúng |
| CE461 | N356 | N358 | Sai |
| CE462 | N357 | N368 |  |
| CE463 | N358 | N368 |  |
| CE464 | N359 | N360 | Đúng |
| CE465 | N359 | N361 | Sai |
| CE466 | N360 | N368 |  |
| CE467 | N361 | N362 | Đúng |
| CE468 | N361 | N363 | Sai |
| CE469 | N362 | N363 |  |
| CE470 | N363 | N364 | Đúng |
| CE471 | N363 | N365 | Sai |
| CE472 | N364 | N368 |  |
| CE473 | N365 | N366 | Đúng |
| CE474 | N365 | N367 | Sai |
| CE475 | N366 | N368 |  |
| CE476 | N367 | N368 |  |

V(G) = số điểm quyết định nhị phân + 1 = 20 + 1 = 21; kiểm bằng E - N + 2 = 64 - 45 + 2 = 21. V(G) lớn hơn 10: đề xuất P12 tách thành ba hàm private theo giai đoạn (kiểm điều kiện không khoá D1 đến D8; kiểm quy tắc người giữ và lựa chọn ghế D9 đến D11; khoá và giữ ghế D13 đến D18), mỗi hàm V(G) nhỏ hơn 10. Nhánh LockByID không ném NotFoundError dưới khoá hạng 5 vì seat_hold không có thao tác xoá; không tạo node.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P138 | N324 - N325 - N326 - N328 - N330 - N331 - N332 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N355 - N359 - N361 - N363 - N365 - N367 - N368 | TC-648 |
| P139 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N346 - N349 - N351 - N352 - N353 - N355 - N359 - N361 - N362 - N363 - N365 - N367 - N368 | TC-188 |
| P140 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N338 - N339 - N368 | TC-183 |
| P141 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N355 - N356 - N358 - N368 | TC-193 |
| P142 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N350 - N368 | TC-178, TC-179 |
| P143 | N324 - N325 - N326 - N327 - N368 | TC-180 |
| P144 | N324 - N325 - N326 - N328 - N329 - N368 | TC-181, TC-199 |
| P145 | N324 - N325 - N326 - N328 - N330 - N331 - N332 - N333 - N368 | TC-649 |
| P146 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N336 - N368 | TC-182 |
| P147 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N338 - N340 - N368 | TC-184, TC-654 |
| P148 | N324 - N325 - N326 - N328 - N330 - N331 - N332 - N334 - N335 - N337 - N341 - N342 - N368 | TC-651, TC-652 |
| P149 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N344 - N368 | TC-189, TC-190, TC-204, TC-206 |
| P150 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N348 - N368 | TC-186, TC-200, TC-203, TC-205 |
| P151 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N354 - N368 | TC-192 |
| P152 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N355 - N356 - N357 - N368 | TC-194 |
| P153 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N355 - N359 - N360 - N368 | TC-195 |
| P154 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N355 - N359 - N361 - N363 - N364 - N368 | TC-196, TC-197, TC-202 |
| P155 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N352 - N353 - N355 - N359 - N361 - N363 - N365 - N366 - N368 | TC-198 |
| P156 | N324 - N325 - N326 - N328 - N330 - N331 - N334 - N335 - N337 - N341 - N343 - N345 - N347 - N349 - N351 - N336 - N368 | TC-191, TC-201 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE413 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-180, TC-181, TC-199, TC-649, TC-182, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE414 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-180, TC-181, TC-199, TC-649, TC-182, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE415 | TC-180 | Có |
| CE416 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-181, TC-199, TC-649, TC-182, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE417 | TC-180 | Có |
| CE418 | TC-181, TC-199 | Có |
| CE419 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-649, TC-182, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE420 | TC-181, TC-199 | Có |
| CE421 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-649, TC-182, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE422 | TC-648, TC-649, TC-651, TC-652 | Có |
| CE423 | TC-174, TC-175, TC-176, TC-177, TC-178, TC-179, TC-182, TC-183, TC-184, TC-654, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE424 | TC-649 | Có |
| CE425 | TC-648, TC-651, TC-652 | Có |
| CE426 | TC-649 | Có |
| CE427 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-182, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE428 | TC-182 | Có |
| CE429 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-183, TC-184, TC-654, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE430 | TC-182, TC-191, TC-201 | Có |
| CE431 | TC-183, TC-184, TC-654 | Có |
| CE432 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-651, TC-652, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE433 | TC-183 | Có |
| CE434 | TC-184, TC-654 | Có |
| CE435 | TC-183 | Có |
| CE436 | TC-184, TC-654 | Có |
| CE437 | TC-651, TC-652 | Có |
| CE438 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-189, TC-190, TC-204, TC-206, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE439 | TC-651, TC-652 | Có |
| CE440 | TC-189, TC-190, TC-204, TC-206 | Có |
| CE441 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-186, TC-200, TC-203, TC-205, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE442 | TC-189, TC-190, TC-204, TC-206 | Có |
| CE443 | TC-187, TC-188 | Có |
| CE444 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-186, TC-200, TC-203, TC-205, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE445 | TC-187, TC-188 | Có |
| CE446 | TC-186, TC-200, TC-203, TC-205 | Có |
| CE447 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-178, TC-179, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE448 | TC-186, TC-200, TC-203, TC-205 | Có |
| CE449 | TC-178, TC-179 | Có |
| CE450 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-191, TC-201, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE451 | TC-178, TC-179 | Có |
| CE452 | TC-191, TC-201 | Có |
| CE453 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE454 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-192, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE455 | TC-192 | Có |
| CE456 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-193, TC-194, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE457 | TC-192 | Có |
| CE458 | TC-193, TC-194 | Có |
| CE459 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-195, TC-196, TC-197, TC-202, TC-198 | Có |
| CE460 | TC-194 | Có |
| CE461 | TC-193 | Có |
| CE462 | TC-194 | Có |
| CE463 | TC-193 | Có |
| CE464 | TC-195 | Có |
| CE465 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-196, TC-197, TC-202, TC-198 | Có |
| CE466 | TC-195 | Có |
| CE467 | TC-188 | Có |
| CE468 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-196, TC-197, TC-202, TC-198 | Có |
| CE469 | TC-188 | Có |
| CE470 | TC-196, TC-197, TC-202 | Có |
| CE471 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188, TC-198 | Có |
| CE472 | TC-196, TC-197, TC-202 | Có |
| CE473 | TC-198 | Có |
| CE474 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188 | Có |
| CE475 | TC-198 | Có |
| CE476 | TC-174, TC-175, TC-176, TC-177, TC-648, TC-187, TC-188 | Có |

Độ phủ đạt được: C0 = 45/45 lệnh và điểm quyết định (100%); C1 = 64/64 nhánh (100%).

Điều kiện ghép D5 hiện thực BR-02: nhân viên quầy khớp cụm rạp phủ bởi TC mới hs_clerk_ok (cả hai vế đúng), vế cụm rạp sai bởi hs_clerk_other, vế không phải nhân viên quầy bởi TC-174 (người giữ là khách).

#### F2.25.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn trên bản sao in-memory của các store giả, hoàn lại khi fn trả lỗi; ghi TxOptions (deadline = lúc nhận + 1,8 giây) và số lần gọi; mang LockOrderGuard thật, test khẳng định Violated() = false; cấu hình được để trả SystemBusyError | Không dùng PostgreSQL trong unit test |
| IF-25.Now | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào |
| IF-11 (FindRouting, FindByID), IF-12, IF-13, IF-16 (LockHolder, LockClerk, FindStaff) | fake | FindRouting trả phòng 7 và cụm rạp 2; LockClerk trả dòng Staff với trạng thái và accessChangedAt cấu hình được | Store thay bằng bộ nhớ |
| IF-17, IF-18 | fake | LockUnfinishedOrByRequest, Insert, UpdateStatus; LockForHold trả 55P03 theo cấu hình; FindBeingReleased cấu hình được; SaveChanges ghi lại số lần và danh sách ghế (hai lần khi chọn lại ghế của lần giữ ghế cũ) | Kiểm chuỗi ghi theo thứ tự trigger trg_seat_status_link |
| DC-HoldSettlement | đối tượng thật | Lớp miền không trạng thái, không I/O nên không giả lập; nhờ đó TC kiểm luôn dãy End | Đúng thiết kế (X1 RV-01) |
| IF-24 (DC-RandomCodeGenerator) | stub | NewHoldRef trả ref-1 | Giá trị ngẫu nhiên phải tiêm vào |

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
| Chữ ký | CancelHold(ctx Ctx, holdRef string, by HolderRef) error | P12 F2 |
| Hậu điều kiện | SeatHold CANCELLED, ghế AVAILABLE nếu còn trỏ tới lần giữ ghế này, cùng một commit; lần giữ ghế đã ở trạng thái cuối khác: HoldNotActiveError mang status, không ghi gì; quá hạn: lần giữ ghế EXPIRED, ghế trả, kết quả HoldNotActiveError(EXPIRED) và vẫn commit; by không phải người giữ hoặc holdRef lạ: NotFoundError (không lộ sự tồn tại) | P12 F2, F3 |
| Thao tác nguyên tử | EX-04 gộp EX-05 (Q-134); X-10, X-12, X-18, X-22 | P08 F4b; P12 F3 |
| Luồng P04 | UC-005 *a, 7b | P04 UC-005 |
| Không áp dụng | F2.27.5 (sự kiện ST-01 kiểm ở DC-HoldSettlement.End); quy tắc DC-HoldSettlement.End kiểm ở F2.41 | - |

#### F2.27.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-112 | lần giữ ghế | ACTIVE, now < expiryTime, by là người giữ | Hợp lệ | H1 ACTIVE, now 10:05 | BR-85 |
| EC-113 | lần giữ ghế | ACTIVE nhưng now >= expiryTime | Hợp lệ (kết quả HoldNotActiveError(EXPIRED), vẫn commit) | now = E | BR-86; F3 CancelHold bước 2 |
| EC-114 | lần giữ ghế | trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED) | Không hợp lệ | COMPLETED | BR-86 |
| EC-115 | by | không phải người giữ | Không hợp lệ | khách 8 | P12 F3 (NotFoundError) |
| EC-116 | holdRef | không tồn tại | Không hợp lệ | ref-9999 | P12 F3 bước 0 (NotFoundError) |

#### F2.27.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-56 | now so với expiryTime (EC-112) | now = E - 1ms | EC-112 | Huỷ được: CANCELLED, ghế về AVAILABLE |
| BV-57 | now so với expiryTime (EC-113) | now = E | EC-113 | EXPIRED, HoldNotActiveError(EXPIRED), ghế về AVAILABLE, một commit |

#### F2.27.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N369 | bắt đầu | bắt đầu |
| N370 | holdId = IF-17.FindIDByRef(holdRef) | khối lệnh |
| N371 | FindIDByRef ném NotFoundError? | quyết định |
| N372 | trả NotFoundError (Do 0 lần) | khối lệnh |
| N373 | Do(UserTx): LockByID (hạng 5); now = tx.Now | khối lệnh |
| N374 | by không phải người giữ? | quyết định |
| N375 | trả NotFoundError (không lộ sự tồn tại) | khối lệnh |
| N376 | LockByHold (hạng 6) | khối lệnh |
| N377 | HoldSettlement.End(now, hold, CANCEL, ghế đã khoá) | khối lệnh |
| N378 | End ném HoldNotActiveError? | quyết định |
| N379 | trả HoldNotActiveError mang status; không ghi gì | khối lệnh |
| N380 | outcome.expired? | quyết định |
| N381 | UpdateStatus; SaveChanges ghế trả về; kết quả = HoldNotActiveError(EXPIRED); fn trả nil để commit | khối lệnh |
| N382 | UpdateStatus (CANCELLED); SaveChanges ghế đã trả | khối lệnh |
| N383 | commit; trả kết quả | khối lệnh |
| N384 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE477 | N369 | N370 |  |
| CE478 | N370 | N371 |  |
| CE479 | N371 | N372 | Đúng |
| CE480 | N371 | N373 | Sai |
| CE481 | N372 | N384 |  |
| CE482 | N373 | N374 |  |
| CE483 | N374 | N375 | Đúng |
| CE484 | N374 | N376 | Sai |
| CE485 | N375 | N384 |  |
| CE486 | N376 | N377 |  |
| CE487 | N377 | N378 |  |
| CE488 | N378 | N379 | Đúng |
| CE489 | N378 | N380 | Sai |
| CE490 | N379 | N384 |  |
| CE491 | N380 | N381 | Đúng |
| CE492 | N380 | N382 | Sai |
| CE493 | N381 | N383 |  |
| CE494 | N382 | N383 |  |
| CE495 | N383 | N384 |  |

V(G) = số điểm quyết định nhị phân + 1 = 4 + 1 = 5; kiểm bằng E - N + 2 = 19 - 16 + 2 = 5. End ném HoldNotActiveError chỉ khi lần giữ ghế đã ở trạng thái cuối khác EXPIRED (DT9-R8 của F2.41).

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P157 | N369 - N370 - N371 - N373 - N374 - N376 - N377 - N378 - N380 - N382 - N383 - N384 | TC-216, TC-217 |
| P158 | N369 - N370 - N371 - N373 - N374 - N376 - N377 - N378 - N380 - N381 - N383 - N384 | TC-218 |
| P159 | N369 - N370 - N371 - N373 - N374 - N375 - N384 | TC-219 |
| P160 | N369 - N370 - N371 - N372 - N384 | TC-220 |
| P161 | N369 - N370 - N371 - N373 - N374 - N376 - N377 - N378 - N379 - N384 | TC-221, TC-222, TC-223, TC-224 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE477 | TC-216, TC-217, TC-218, TC-219, TC-220, TC-221, TC-222, TC-223, TC-224 | Có |
| CE478 | TC-216, TC-217, TC-218, TC-219, TC-220, TC-221, TC-222, TC-223, TC-224 | Có |
| CE479 | TC-220 | Có |
| CE480 | TC-216, TC-217, TC-218, TC-219, TC-221, TC-222, TC-223, TC-224 | Có |
| CE481 | TC-220 | Có |
| CE482 | TC-216, TC-217, TC-218, TC-219, TC-221, TC-222, TC-223, TC-224 | Có |
| CE483 | TC-219 | Có |
| CE484 | TC-216, TC-217, TC-218, TC-221, TC-222, TC-223, TC-224 | Có |
| CE485 | TC-219 | Có |
| CE486 | TC-216, TC-217, TC-218, TC-221, TC-222, TC-223, TC-224 | Có |
| CE487 | TC-216, TC-217, TC-218, TC-221, TC-222, TC-223, TC-224 | Có |
| CE488 | TC-221, TC-222, TC-223, TC-224 | Có |
| CE489 | TC-216, TC-217, TC-218 | Có |
| CE490 | TC-221, TC-222, TC-223, TC-224 | Có |
| CE491 | TC-218 | Có |
| CE492 | TC-216, TC-217 | Có |
| CE493 | TC-218 | Có |
| CE494 | TC-216, TC-217 | Có |
| CE495 | TC-216, TC-217, TC-218 | Có |

Độ phủ đạt được: C0 = 16/16 lệnh và điểm quyết định (100%); C1 = 19/19 nhánh (100%).

#### F2.27.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> giữ thay đổi, trả lỗi --> hoàn lại; ghi lại TxOptions và số commit; mang LockOrderGuard thật, test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật là ca tích hợp |
| IF-25.Now | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào |
| IF-17, IF-18 | fake | FindIDByRef trả mã theo holdRef; LockByID trả hold theo điều kiện đầu; LockByHold trả các ghế có currentHold = holdId (ghế đã giữ lại cho hold khác không có trong kết quả); UpdateStatus, SaveChanges ghi lại số lần và danh sách ghế | Store thay bằng bộ nhớ |
| DC-HoldSettlement | đối tượng thật | Lớp miền không trạng thái, không I/O nên không giả lập; TC kiểm luôn dãy End, Sell, FinishSale ở mức service | Đúng thiết kế (X1 RV-01) |

### F2.28 DC-BookTicketsService.ConfirmCashReceived

#### F2.28.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | ConfirmCashReceived(ctx Ctx, holdRef string, clerk HolderRef) (BookingView, error) | P12 F2 |
| Hậu điều kiện | SeatHold COMPLETED, ghế SOLD với currentTicket, một Booking cùng vé UNUSED mang tên phim, cụm rạp, phòng chiếu, loại phòng lúc bán (BR-140); không xếp email (UC-005 9a). Quá hạn: lần giữ ghế EXPIRED, ghế trả, HoldNotActiveError(EXPIRED), vẫn commit, nhân viên được báo trả lại tiền mặt (BR-44). clerk không phải người giữ hoặc holdRef lạ: NotFoundError (Q-147) | P12 F2, F3 |
| Ngoại lệ | HoldNotActiveError, NotFoundError, SystemBusyError | P12 F2 |
| Thao tác nguyên tử | EX-03; X-09, X-10, X-12 | P08 F4b |
| Luồng P04 | UC-005 9a | P04 UC-005 |
| Phát hiện | Lần giữ ghế đã CANCELLED, COMPLETED hoặc PAYMENT_FAILED: LockByHold không trả ghế nào (ghế đã trả hoặc đã bán, liên kết xoá), nên Sell dừng ở bước kiểm ghế rỗng với LinkMismatchError trước khi gọi Complete; F2 của ConfirmCashReceived và BR-86 đòi HoldNotActiveError. TC-228, TC-231 giữ kết quả theo F2 (không theo F3) và sẽ thất bại trên thiết kế hiện hành | P12 F2, F3; Q-352 |
| Không áp dụng | F2.28.5 (sự kiện ST-01 kiểm ở F2.41, F2.42) | - |

#### F2.28.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-117 | lần giữ ghế | ACTIVE, now < expiryTime, clerk là người giữ | Hợp lệ | H1 ACTIVE | BR-44 |
| EC-118 | lần giữ ghế | ACTIVE nhưng now >= expiryTime | Không hợp lệ | now = E | BR-44; UC-005 9a1a |
| EC-119 | lần giữ ghế | đã ở trạng thái cuối | Không hợp lệ | CANCELLED | BR-86 |
| EC-120 | clerk | không phải người giữ | Không hợp lệ | nhân viên 4 | Q-147 |
| EC-121 | holdRef | không tồn tại | Không hợp lệ | 9999 | P12 F2 |

#### F2.28.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-58 | now so với expiryTime (EC-117) | now = E - 1ms | EC-117 | Bán thành công |
| BV-59 | now so với expiryTime (EC-118) | now = E | EC-118 | Từ chối; EXPIRED; ghế trả |

#### F2.28.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N385 | bắt đầu | bắt đầu |
| N386 | holdId = IF-17.FindIDByRef(holdRef) | khối lệnh |
| N387 | FindIDByRef ném NotFoundError? | quyết định |
| N388 | trả NotFoundError | khối lệnh |
| N389 | Do(UserTx): LockByID (5); now = tx.Now | khối lệnh |
| N390 | clerk không phải người giữ? | quyết định |
| N391 | trả NotFoundError | khối lệnh |
| N392 | LockByHold (6); HoldSettlement.End(now, hold, EXPIRY, ghế đã khoá) | khối lệnh |
| N393 | outcome.expired? | quyết định |
| N394 | UpdateStatus nếu holdChanged; SaveChanges ghế trả về; kết quả HoldNotActiveError(EXPIRED); fn trả nil để commit | khối lệnh |
| N395 | snap = FindSaleSnapshot; Sell(now, hold, ghế, bookingCode, ticketCodes, snap) | khối lệnh |
| N396 | Sell ném LinkMismatchError hoặc HoldNotActiveError? | quyết định |
| N397 | trả lỗi của Sell; rollback | khối lệnh |
| N398 | InsertWithTickets; FinishSale; SaveChanges; UpdateStatus | khối lệnh |
| N399 | commit; dựng BookingView | khối lệnh |
| N400 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE496 | N385 | N386 |  |
| CE497 | N386 | N387 |  |
| CE498 | N387 | N388 | Đúng |
| CE499 | N387 | N389 | Sai |
| CE500 | N388 | N400 |  |
| CE501 | N389 | N390 |  |
| CE502 | N390 | N391 | Đúng |
| CE503 | N390 | N392 | Sai |
| CE504 | N391 | N400 |  |
| CE505 | N392 | N393 |  |
| CE506 | N393 | N394 | Đúng |
| CE507 | N393 | N395 | Sai |
| CE508 | N394 | N399 |  |
| CE509 | N395 | N396 |  |
| CE510 | N396 | N397 | Đúng |
| CE511 | N396 | N398 | Sai |
| CE512 | N397 | N400 |  |
| CE513 | N398 | N399 |  |
| CE514 | N399 | N400 |  |

V(G) = số điểm quyết định nhị phân + 1 = 4 + 1 = 5; kiểm bằng E - N + 2 = 19 - 16 + 2 = 5. TC-231 đi qua B5 ở lần xác nhận thứ nhất; lần thứ hai (TC-228 và TC-231) đi nhánh X3 (xem mục Phát hiện).

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P162 | N385 - N386 - N387 - N389 - N390 - N392 - N393 - N395 - N396 - N398 - N399 - N400 | TC-225, TC-226, TC-231 |
| P163 | N385 - N386 - N387 - N389 - N390 - N392 - N393 - N394 - N399 - N400 | TC-227 |
| P164 | N385 - N386 - N387 - N388 - N400 | TC-229 |
| P165 | N385 - N386 - N387 - N389 - N390 - N391 - N400 | TC-230 |
| P166 | N385 - N386 - N387 - N389 - N390 - N392 - N393 - N395 - N396 - N397 - N400 | TC-228 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE496 | TC-225, TC-226, TC-231, TC-227, TC-229, TC-230, TC-228 | Có |
| CE497 | TC-225, TC-226, TC-231, TC-227, TC-229, TC-230, TC-228 | Có |
| CE498 | TC-229 | Có |
| CE499 | TC-225, TC-226, TC-231, TC-227, TC-230, TC-228 | Có |
| CE500 | TC-229 | Có |
| CE501 | TC-225, TC-226, TC-231, TC-227, TC-230, TC-228 | Có |
| CE502 | TC-230 | Có |
| CE503 | TC-225, TC-226, TC-231, TC-227, TC-228 | Có |
| CE504 | TC-230 | Có |
| CE505 | TC-225, TC-226, TC-231, TC-227, TC-228 | Có |
| CE506 | TC-227 | Có |
| CE507 | TC-225, TC-226, TC-231, TC-228 | Có |
| CE508 | TC-227 | Có |
| CE509 | TC-225, TC-226, TC-231, TC-228 | Có |
| CE510 | TC-228 | Có |
| CE511 | TC-225, TC-226, TC-231 | Có |
| CE512 | TC-228 | Có |
| CE513 | TC-225, TC-226, TC-231 | Có |
| CE514 | TC-225, TC-226, TC-231, TC-227 | Có |

Độ phủ đạt được: C0 = 16/16 lệnh và điểm quyết định (100%); C1 = 19/19 nhánh (100%).

#### F2.28.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> giữ thay đổi, trả lỗi --> hoàn lại; ghi lại TxOptions và số commit; mang LockOrderGuard thật, test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật là ca tích hợp |
| IF-25.Now | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào |
| IF-17, IF-18, IF-20 | fake | FindIDByRef, LockByID, LockByHold; FindSaleSnapshot (IF-11) trả tên phim, cụm rạp, phòng chiếu, loại phòng; InsertWithTickets gán id vé; SaveChanges ghi danh sách ghế | Store thay bằng bộ nhớ |
| IF-23 (hàng đợi) | mock | Enqueue được gọi 0 lần (người giữ là nhân viên quầy, không email) | Kiểm UC-005 9a |
| IF-24 | stub | NewBookingCode trả BK1; NewTicketCode trả TKA, TKB | Giá trị ngẫu nhiên phải tiêm vào |
| DC-HoldSettlement | đối tượng thật | Lớp miền không trạng thái, không I/O nên không giả lập; TC kiểm luôn dãy End, Sell, FinishSale ở mức service | Đúng thiết kế (X1 RV-01) |

### F2.29 DC-BookTicketsService.StartOnlinePayment

#### F2.29.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | StartOnlinePayment(ctx Ctx, holdRef string, by HolderRef, clientIp string) (PaymentStart, error) | P12 F2 |
| Hậu điều kiện | Một PaymentTransaction PENDING mới (số tiền = CalculateTotal) gắn lần giữ ghế đã commit, rồi IF-01.CreatePaymentTransaction ngoài giao dịch trả địa chỉ đã ký; lỗi ở bước ký giữ nguyên lần giữ ghế (BR-90); gọi lại tạo bản ghi PENDING mới, không xoá bản cũ. Quá hạn: End(EXPIRY) ghi EXPIRED, trả HoldNotActiveError. by không phải người giữ hoặc holdRef lạ: NotFoundError (Q-147) | P12 F2, F3 |
| Ngoại lệ | HoldNotActiveError, NotFoundError, GatewayConfigurationError, SystemBusyError | P12 F2 |
| Luồng P04 | UC-005 bước 9, 10; BR-90 | P04 UC-005 |
| Thao tác nguyên tử | EX-02 (giao dịch ngắn đầu); X-09, X-10 | P08 F4b |
| Không áp dụng | F2.29.4 (điều kiện độc lập), F2.29.5 | - |

#### F2.29.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-122 | lần giữ ghế | ACTIVE, chưa quá hạn, by là người giữ | Hợp lệ | H1 ACTIVE | BR-90 |
| EC-123 | lần giữ ghế | ACTIVE nhưng now >= expiryTime | Không hợp lệ | now = E | BR-86 |
| EC-124 | lần giữ ghế | đã ở trạng thái cuối | Không hợp lệ | CANCELLED | BR-86 |
| EC-125 | IF-01.CreatePaymentTransaction | ném GatewayConfigurationError | Không hợp lệ | lỗi cấu hình | BR-90; UC-005 10a |
| EC-126 | by | không phải người giữ | Không hợp lệ | khách 8 | Q-147 |
| EC-127 | holdRef | không tồn tại | Không hợp lệ | 9999 | P12 F2 |

#### F2.29.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N401 | bắt đầu | bắt đầu |
| N402 | holdId = FindIDByRef(holdRef) | khối lệnh |
| N403 | FindIDByRef ném NotFoundError? | quyết định |
| N404 | trả NotFoundError; IF-01 0 lần | khối lệnh |
| N405 | Do(UserTx): LockByID (5); now = tx.Now | khối lệnh |
| N406 | by không phải người giữ? | quyết định |
| N407 | trả NotFoundError; không đổi dữ liệu | khối lệnh |
| N408 | HoldSettlement.End(now, hold, EXPIRY, nil) | khối lệnh |
| N409 | outcome.expired? | quyết định |
| N410 | UpdateStatus nếu holdChanged; commit; trả HoldNotActiveError(EXPIRED) | khối lệnh |
| N411 | lần giữ ghế không còn Đang giữ (IsActiveAt sai)? | quyết định |
| N412 | trả HoldNotActiveError mang status | khối lệnh |
| N413 | FindByHold; CalculateTotal; NewPending; Insert (hạng 7); commit | khối lệnh |
| N414 | IF-01.CreatePaymentTransaction(code, holdRef, total, expiryTime, clientIp) ngoài giao dịch | khối lệnh |
| N415 | IF-01 ném GatewayConfigurationError? | quyết định |
| N416 | trả GatewayConfigurationError (bản ghi PENDING đã commit giữ nguyên) | khối lệnh |
| N417 | trả PaymentStart | khối lệnh |
| N418 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE515 | N401 | N402 |  |
| CE516 | N402 | N403 |  |
| CE517 | N403 | N404 | Đúng |
| CE518 | N403 | N405 | Sai |
| CE519 | N404 | N418 |  |
| CE520 | N405 | N406 |  |
| CE521 | N406 | N407 | Đúng |
| CE522 | N406 | N408 | Sai |
| CE523 | N407 | N418 |  |
| CE524 | N408 | N409 |  |
| CE525 | N409 | N410 | Đúng |
| CE526 | N409 | N411 | Sai |
| CE527 | N410 | N418 |  |
| CE528 | N411 | N412 | Đúng |
| CE529 | N411 | N413 | Sai |
| CE530 | N412 | N418 |  |
| CE531 | N413 | N414 |  |
| CE532 | N414 | N415 |  |
| CE533 | N415 | N416 | Đúng |
| CE534 | N415 | N417 | Sai |
| CE535 | N416 | N418 |  |
| CE536 | N417 | N418 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 22 - 18 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P167 | N401 - N402 - N403 - N405 - N406 - N408 - N409 - N411 - N413 - N414 - N415 - N417 - N418 | TC-232, TC-233 |
| P168 | N401 - N402 - N403 - N405 - N406 - N408 - N409 - N410 - N418 | TC-234 |
| P169 | N401 - N402 - N403 - N405 - N406 - N408 - N409 - N411 - N412 - N418 | TC-235 |
| P170 | N401 - N402 - N403 - N405 - N406 - N408 - N409 - N411 - N413 - N414 - N415 - N416 - N418 | TC-236 |
| P171 | N401 - N402 - N403 - N405 - N406 - N407 - N418 | TC-237 |
| P172 | N401 - N402 - N403 - N404 - N418 | TC-238 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE515 | TC-232, TC-233, TC-234, TC-235, TC-236, TC-237, TC-238 | Có |
| CE516 | TC-232, TC-233, TC-234, TC-235, TC-236, TC-237, TC-238 | Có |
| CE517 | TC-238 | Có |
| CE518 | TC-232, TC-233, TC-234, TC-235, TC-236, TC-237 | Có |
| CE519 | TC-238 | Có |
| CE520 | TC-232, TC-233, TC-234, TC-235, TC-236, TC-237 | Có |
| CE521 | TC-237 | Có |
| CE522 | TC-232, TC-233, TC-234, TC-235, TC-236 | Có |
| CE523 | TC-237 | Có |
| CE524 | TC-232, TC-233, TC-234, TC-235, TC-236 | Có |
| CE525 | TC-234 | Có |
| CE526 | TC-232, TC-233, TC-235, TC-236 | Có |
| CE527 | TC-234 | Có |
| CE528 | TC-235 | Có |
| CE529 | TC-232, TC-233, TC-236 | Có |
| CE530 | TC-235 | Có |
| CE531 | TC-232, TC-233, TC-236 | Có |
| CE532 | TC-232, TC-233, TC-236 | Có |
| CE533 | TC-236 | Có |
| CE534 | TC-232, TC-233 | Có |
| CE535 | TC-236 | Có |
| CE536 | TC-232, TC-233 | Có |

Độ phủ đạt được: C0 = 18/18 lệnh và điểm quyết định (100%); C1 = 22/22 nhánh (100%).

#### F2.29.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> giữ thay đổi, trả lỗi --> hoàn lại; ghi lại TxOptions và số commit; mang LockOrderGuard thật, test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật là ca tích hợp |
| IF-25.Now | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào |
| IF-17, IF-18, IF-19 | fake | FindIDByRef, LockByID, FindByHold; IF-19.Insert ghi PaymentTransaction mới (hạng 7) | Store thay bằng bộ nhớ |
| IF-01 | mock | CreatePaymentTransaction được gọi đúng một lần với (mã giao dịch, holdRef, số tiền nguyên đồng, expiryTime, clientIp) sau khi giao dịch commit; cấu hình ném GatewayConfigurationError | Hệ thống ngoài |
| IF-24 | stub | NewTransactionCode trả T1 | Giá trị ngẫu nhiên phải tiêm vào |
| DC-HoldSettlement | đối tượng thật | Lớp miền không trạng thái, không I/O nên không giả lập; TC kiểm luôn dãy End, Sell, FinishSale ở mức service | Đúng thiết kế (X1 RV-01) |

### F2.30 DC-PaymentReportService.HandleIpn

#### F2.30.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | HandleIpn(ctx Ctx, params map[string]string) (IpnAnswer, error) | P12 F2 |
| Hậu điều kiện | Sai chữ ký (INVALID_SIGNATURE) hoặc thiếu tham số (MALFORMED): không ghi gì. Không nhận ra giao dịch và lần giữ ghế: log, UNKNOWN_TRANSACTION. Báo thành công chưa xử lý có số tiền khác bản ghi (hoặc khác tổng giá ghế khi tạo giao dịch từ báo): AMOUNT_MISMATCH, log, không ghi gì (BR-91, Q-146). Còn lại: End(EXPIRY), decide, rồi SELL (Sell, FinishSale, MarkTicketed, Enqueue(EMAIL_TICKET)), LATE (MarkLatePayment, CreateFullRefund), FAILURE (RecordFailure, End(PAYMENT_FAILURE) chỉ khi là giao dịch mới nhất và lần giữ ghế còn ACTIVE) hoặc DUPLICATE (RecordDuplicate); lỗi tạm thời: TEMPORARY_FAILURE, rollback trọn | P12 F2, F3; P09 F7.6 |
| Ngoại lệ | SystemBusyError (quy thành RspCode 99) | P12 F2 |
| Thao tác nguyên tử | EX-02, EX-03 (gồm tạo vé và Booking); X-09, X-10, X-12, X-16 | P08 F4b |
| Luồng P04 | UC-005 bước 11 đến 15; UC-006 bước 1 đến 3, 2a, 2c, 2d, 2e, 2f | P04 UC-005, UC-006 (luồng 7a, email hoàn tiền thất bại, thuộc DC-EmailOutboxJob: at-least-once, kiểm ở F4.5 mục 2) |
| Không áp dụng | F2.30.5 (sự kiện ST-01, ST-05 kiểm ở F2.8, F2.41, F2.42) | - |

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
| A9: không kiểm số tiền (BR-91 chỉ nêu báo thành công): kết quả như R7 (DUPLICATE) hoặc R8 (PROCESSED, ghi nhận thất bại) | - | - | - | - | - | - | - | - | X |
```

Căn cứ: F2 của DC-PaymentReportReceiver nêu Verify trước Decode (sai chữ ký khi cũng thiếu tham số: INVALID_SIGNATURE), P12 F3 và P09 F7.6 nêu thứ tự các bước; R9 theo Q-146 đã trả lời (chỉ báo thành công chưa xử lý bị kiểm số tiền); TC-260 và TC-261 là hai đại diện của R9.

#### F2.30.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N419 | bắt đầu | bắt đầu |
| N420 | IF-02.ReportTransactionResult(params) | khối lệnh |
| N421 | chữ ký sai (InvalidSignatureError)? | quyết định |
| N422 | trả INVALID_SIGNATURE (97); không ghi gì | khối lệnh |
| N423 | thiếu tham số (MalformedReportError)? | quyết định |
| N424 | trả MALFORMED (99); không ghi gì | khối lệnh |
| N425 | FindIDByRef hoặc FindByCode (không khoá) | khối lệnh |
| N426 | không nhận ra cả mã tham chiếu và mã giao dịch? | quyết định |
| N427 | logUnrecognized; trả UNKNOWN_TRANSACTION (01) | khối lệnh |
| N428 | Do(UserTx): LockByID (5), LockByHold (6), LockByCode (7); now = tx.Now | khối lệnh |
| N429 | Do trả lỗi tạm thời (40P01, 55P03 sau thử lại)? | quyết định |
| N430 | trả TEMPORARY_FAILURE (99); rollback trọn | khối lệnh |
| N431 | giao dịch chưa có (Insert từ báo dưới khoá hạng 5)? | quyết định |
| N432 | báo thành công, lần giữ ghế còn ACTIVE và r.amount khác CalculateTotal? | quyết định |
| N433 | báo thành công, giao dịch chưa xử lý và r.amount khác txn.Amount? | quyết định |
| N434 | log; trả AMOUNT_MISMATCH (04); không ghi gì | khối lệnh |
| N435 | HoldSettlement.End(now, hold, EXPIRY, ghế); UpdateStatus nếu holdChanged; SaveChanges nếu có ghế trả về | khối lệnh |
| N436 | decide = DUPLICATE? | quyết định |
| N437 | txn.RecordDuplicate; UpdateStatus | khối lệnh |
| N438 | decide = SELL? | quyết định |
| N439 | snap = FindSaleSnapshot; Sell(...) | khối lệnh |
| N440 | Sell ném LinkMismatchError? | quyết định |
| N441 | InsertWithTickets; FinishSale; SaveChanges; MarkTicketed; UpdateStatus; Enqueue(EMAIL_TICKET) | khối lệnh |
| N442 | decide = LATE (hoặc Sell dừng với HOLD_LINK_BROKEN)? | quyết định |
| N443 | MarkLatePayment; CreateFullRefund; UpdateStatus; ghi log lỗi nghiêm trọng khi HOLD_LINK_BROKEN | khối lệnh |
| N444 | txn.RecordFailure | khối lệnh |
| N445 | txn là giao dịch tạo sau cùng của lần giữ ghế và hold IsActiveAt(now)? | quyết định |
| N446 | HoldSettlement.End(now, hold, PAYMENT_FAILURE, ghế); UpdateStatus; SaveChanges | khối lệnh |
| N447 | UpdateStatus giao dịch | khối lệnh |
| N448 | commit; trả PROCESSED (00) hoặc DUPLICATE (02) | khối lệnh |
| N449 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE537 | N419 | N420 |  |
| CE538 | N420 | N421 |  |
| CE539 | N421 | N422 | Đúng |
| CE540 | N421 | N423 | Sai |
| CE541 | N422 | N449 |  |
| CE542 | N423 | N424 | Đúng |
| CE543 | N423 | N425 | Sai |
| CE544 | N424 | N449 |  |
| CE545 | N425 | N426 |  |
| CE546 | N426 | N427 | Đúng |
| CE547 | N426 | N428 | Sai |
| CE548 | N427 | N449 |  |
| CE549 | N428 | N429 |  |
| CE550 | N429 | N430 | Đúng |
| CE551 | N429 | N431 | Sai |
| CE552 | N430 | N449 |  |
| CE553 | N431 | N432 | Đúng |
| CE554 | N431 | N433 | Sai |
| CE555 | N432 | N434 | Đúng |
| CE556 | N432 | N435 | Sai |
| CE557 | N433 | N434 | Đúng |
| CE558 | N433 | N435 | Sai |
| CE559 | N434 | N449 |  |
| CE560 | N435 | N436 |  |
| CE561 | N436 | N437 | Đúng |
| CE562 | N436 | N438 | Sai |
| CE563 | N437 | N448 |  |
| CE564 | N438 | N439 | Đúng |
| CE565 | N438 | N442 | Sai |
| CE566 | N439 | N440 |  |
| CE567 | N440 | N443 | Đúng |
| CE568 | N440 | N441 | Sai |
| CE569 | N441 | N448 |  |
| CE570 | N442 | N443 | Đúng |
| CE571 | N442 | N444 | Sai |
| CE572 | N443 | N448 |  |
| CE573 | N444 | N445 |  |
| CE574 | N445 | N446 | Đúng |
| CE575 | N445 | N447 | Sai |
| CE576 | N446 | N448 |  |
| CE577 | N447 | N448 |  |
| CE578 | N448 | N449 |  |

V(G) = số điểm quyết định nhị phân + 1 = 12 + 1 = 13; kiểm bằng E - N + 2 = 42 - 31 + 2 = 13. V(G) lớn hơn 10: đề xuất P12 tách thành validateReport (D4 đến D6) và applyDecision (D7 đến D11), mỗi hàm nhỏ hơn 10. Điều kiện ghép D6 hiện thực BR-91 (báo thành công và chưa xử lý): vế báo thành công sai phủ bởi TC-260 (báo thất bại), vế chưa xử lý sai phủ bởi TC-261 (báo thành công trùng), cả hai đúng phủ bởi TC-255. D11 hiện thực BR-93: giao dịch cũ phủ bởi TC-248, lần giữ ghế không còn ACTIVE phủ bởi TC-249.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P173 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N433 - N435 - N436 - N438 - N442 - N444 - N445 - N446 - N448 - N449 | TC-247, TC-260 |
| P174 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N432 - N435 - N436 - N438 - N439 - N440 - N441 - N448 - N449 | TC-252 |
| P175 | N419 - N420 - N421 - N422 - N449 | TC-256, TC-258 |
| P176 | N419 - N420 - N421 - N423 - N424 - N449 | TC-257 |
| P177 | N419 - N420 - N421 - N423 - N425 - N426 - N427 - N449 | TC-251 |
| P178 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N430 - N449 | TC-259 |
| P179 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N432 - N434 - N449 | TC-253 |
| P180 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N432 - N435 - N436 - N438 - N442 - N443 - N448 - N449 | TC-254 |
| P181 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N433 - N435 - N436 - N437 - N448 - N449 | TC-245, TC-246, TC-261, TC-262 |
| P182 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N433 - N435 - N436 - N438 - N442 - N444 - N445 - N447 - N448 - N449 | TC-248, TC-249, TC-250 |
| P183 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N433 - N434 - N449 | TC-255 |
| P184 | N419 - N420 - N421 - N423 - N425 - N426 - N428 - N429 - N431 - N433 - N435 - N436 - N438 - N439 - N440 - N443 - N448 - N449 | TC-244 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE537 | TC-256, TC-258, TC-257, TC-251, TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE538 | TC-256, TC-258, TC-257, TC-251, TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE539 | TC-256, TC-258 | Có |
| CE540 | TC-257, TC-251, TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE541 | TC-256, TC-258 | Có |
| CE542 | TC-257 | Có |
| CE543 | TC-251, TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE544 | TC-257 | Có |
| CE545 | TC-251, TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE546 | TC-251 | Có |
| CE547 | TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE548 | TC-251 | Có |
| CE549 | TC-259, TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE550 | TC-259 | Có |
| CE551 | TC-252, TC-253, TC-254, TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE552 | TC-259 | Có |
| CE553 | TC-252, TC-253, TC-254 | Có |
| CE554 | TC-255, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE555 | TC-253 | Có |
| CE556 | TC-252, TC-254 | Có |
| CE557 | TC-255 | Có |
| CE558 | TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE559 | TC-253, TC-255 | Có |
| CE560 | TC-252, TC-254, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE561 | TC-245, TC-246, TC-261, TC-262 | Có |
| CE562 | TC-252, TC-254, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE563 | TC-245, TC-246, TC-261, TC-262 | Có |
| CE564 | TC-252, TC-239, TC-240, TC-244 | Có |
| CE565 | TC-254, TC-241, TC-242, TC-243, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE566 | TC-252, TC-239, TC-240, TC-244 | Có |
| CE567 | TC-244 | Có |
| CE568 | TC-252, TC-239, TC-240 | Có |
| CE569 | TC-252, TC-239, TC-240 | Có |
| CE570 | TC-254, TC-241, TC-242, TC-243 | Có |
| CE571 | TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE572 | TC-254, TC-241, TC-242, TC-243, TC-244 | Có |
| CE573 | TC-247, TC-260, TC-248, TC-249, TC-250 | Có |
| CE574 | TC-247, TC-260 | Có |
| CE575 | TC-248, TC-249, TC-250 | Có |
| CE576 | TC-247, TC-260 | Có |
| CE577 | TC-248, TC-249, TC-250 | Có |
| CE578 | TC-252, TC-254, TC-239, TC-240, TC-241, TC-242, TC-243, TC-244, TC-245, TC-246, TC-261, TC-262, TC-247, TC-260, TC-248, TC-249, TC-250 | Có |

Độ phủ đạt được: C0 = 31/31 lệnh và điểm quyết định (100%); C1 = 42/42 nhánh (100%).

#### F2.30.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> giữ thay đổi, trả lỗi --> hoàn lại; ghi lại TxOptions và số commit; mang LockOrderGuard thật, test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật là ca tích hợp |
| IF-25.Now | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào |
| IF-02 | stub | ReportTransactionResult trả PaymentReport theo điều kiện đầu hoặc InvalidSignatureError, MalformedReportError | Hệ thống ngoài (cổng) |
| IF-17, IF-18, IF-19, IF-20, IF-11 | fake | FindIDByRef; LockByID; LockByHold; LockByCode; FindLatestByHold; Insert; UpdateStatus; InsertWithTickets; SaveChanges; FindSaleSnapshot; ghi lại thứ tự gọi | Store thay bằng bộ nhớ; guard khoá thật |
| DC-RefundService | mock | CreateFullRefund(tx, txn): đúng 1 lần với LATE, 0 lần với SELL, DUPLICATE, FAILURE | Kiểm tương tác |
| IF-23 | mock | Enqueue(EMAIL_TICKET) đúng 1 lần ở SELL, 0 lần ở nhánh khác | Kiểm tương tác |
| logUnrecognized (log) | spy | Đếm số lần ghi log (UNKNOWN_TRANSACTION, AMOUNT_MISMATCH, HOLD_LINK_BROKEN) | Kiểm hiệu ứng phụ |
| DC-HoldSettlement | đối tượng thật | Lớp miền không trạng thái, không I/O nên không giả lập; TC kiểm luôn dãy End, Sell, FinishSale ở mức service | Đúng thiết kế (X1 RV-01) |

### F2.31 DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents)

#### F2.31.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | RunDue(ctx Ctx, budget time.Duration) (JobRunResult, error); expireBatch(ctx) (int, error); cleanupEvents(ctx) (int, error) | P12 F2 |
| Hậu điều kiện | Mỗi lần giữ ghế ACTIVE đã quá hạn chuyển EXPIRED; chạy lặp an toàn; lặp expireBatch tới khi lô ít hơn batchSize (200) hoặc hết budget (8 giây), rồi cleanupEvents(IF-22.DeleteOlderThan(10 phút, 200)) | P12 F2, F3; P09 F7.4 |
| BR / NFR | BR-10, BR-85, BR-86; NFR-07 (ghế được giải phóng trong 1 phút; HoldExpiryJob chỉ đổi lần giữ ghế, không đổi ghế, ghế do SeatReleaseJob trả) | P06; P12 F3 |
| Ngữ cảnh cleanupEvents | Luôn chạy trong ngữ cảnh riêng có hạn 2 giây, kể cả khi expireBatch đã hết ngân sách 8 giây | P12 F3; Q-148 (đã trả lời) |
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

### F2.33 DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (cancelOnlineInTx, cancelCashInTx, cancelAndReleaseSeat)

#### F2.33.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CancelOnlineTicket(ctx Ctx, ticketId TicketId, customer HolderRef) (CancelResult, error); ConfirmCashRefund(ctx Ctx, ticketId TicketId, clerk HolderRef) (CancelResult, error) | P12 F2 |
| Hậu điều kiện | Một giao dịch: vé CANCELLED, ghế về Trống khi currentTicket khớp, rồi yêu cầu hoàn 70% làm tròn xuống đồng (trực tuyến: RequestTicketRefund, hàng đợi REFUND_GATEWAY; tại quầy: NewCashRefund REFUNDED, không cổng, không email, BR-20); lỗi ở bước nào thì rollback trọn | P12 F3 |
| Ngoại lệ | ChannelMismatchError, CancelDeadlineError, TicketStateError, RefundLimitError, NotFoundError, SystemBusyError | P12 F2 |
| Thao tác nguyên tử | EX-07, EX-06, EX-09 gộp (Q-133); X-14, X-15, X-16, X-23 | P08 F4b |
| Luồng P04 | UC-008 2a, 2b, 2c, 3a, 4a, 4b | P04 UC-008 |
| Không áp dụng | F2.33.5 (sự kiện ST-03 kiểm ở F2.14) | - |

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

Nhánh trực tuyến (cancelOnlineInTx):

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N450 | bắt đầu | bắt đầu |
| N451 | Do(UserTx): FindByTicket; FindByID suất chiếu (đọc không khoá) | khối lệnh |
| N452 | FindByTicket ném NotFoundError? | quyết định |
| N453 | trả NotFoundError | khối lệnh |
| N454 | Do ném SystemBusyError (40P01 hết lần thử)? | quyết định |
| N455 | trả SystemBusyError; rollback | khối lệnh |
| N456 | LockByKey ghế (6); lockPaymentOfTicket (7); LockTicketByID (8); now = tx.Now | khối lệnh |
| N457 | CheckCancellationChannel(customer) ném ChannelMismatchError? | quyết định |
| N458 | trả ChannelMismatchError | khối lệnh |
| N459 | CheckCancellationDeadline ném CancelDeadlineError? | quyết định |
| N460 | trả CancelDeadlineError | khối lệnh |
| N461 | Ticket.Cancel ném TicketStateError? | quyết định |
| N462 | trả TicketStateError mang status | khối lệnh |
| N463 | UpdateTicketStatus(CANCELLED); ReleaseTicket(ticketId) | khối lệnh |
| N464 | ReleaseTicket trả true? | quyết định |
| N465 | SaveChanges ghế | khối lệnh |
| N466 | amount = RefundAmount; RequestTicketRefund(txn, ticket, amount) | khối lệnh |
| N467 | RequestTicketRefund ném RefundLimitError? | quyết định |
| N468 | trả RefundLimitError; rollback trọn | khối lệnh |
| N469 | commit; trả CancelResult | khối lệnh |
| N470 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE579 | N450 | N451 |  |
| CE580 | N451 | N452 |  |
| CE581 | N452 | N453 | Đúng |
| CE582 | N452 | N454 | Sai |
| CE583 | N453 | N470 |  |
| CE584 | N454 | N455 | Đúng |
| CE585 | N454 | N456 | Sai |
| CE586 | N455 | N470 |  |
| CE587 | N456 | N457 |  |
| CE588 | N457 | N458 | Đúng |
| CE589 | N457 | N459 | Sai |
| CE590 | N458 | N470 |  |
| CE591 | N459 | N460 | Đúng |
| CE592 | N459 | N461 | Sai |
| CE593 | N460 | N470 |  |
| CE594 | N461 | N462 | Đúng |
| CE595 | N461 | N463 | Sai |
| CE596 | N462 | N470 |  |
| CE597 | N463 | N464 |  |
| CE598 | N464 | N465 | Đúng |
| CE599 | N464 | N466 | Sai |
| CE600 | N465 | N466 |  |
| CE601 | N466 | N467 |  |
| CE602 | N467 | N468 | Đúng |
| CE603 | N467 | N469 | Sai |
| CE604 | N468 | N470 |  |
| CE605 | N469 | N470 |  |

V(G) = số điểm quyết định nhị phân + 1 = 7 + 1 = 8; kiểm bằng E - N + 2 = 27 - 21 + 2 = 8.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P185 | N450 - N451 - N452 - N454 - N456 - N457 - N459 - N461 - N463 - N464 - N465 - N466 - N467 - N469 - N470 | TC-287, TC-288, TC-299 |
| P186 | N450 - N451 - N452 - N453 - N470 | TC-300 |
| P187 | N450 - N451 - N452 - N454 - N455 - N470 | TC-301 |
| P188 | N450 - N451 - N452 - N454 - N456 - N457 - N458 - N470 | TC-291, TC-292, TC-295 |
| P189 | N450 - N451 - N452 - N454 - N456 - N457 - N459 - N460 - N470 | TC-289, TC-290, TC-296 |
| P190 | N450 - N451 - N452 - N454 - N456 - N457 - N459 - N461 - N462 - N470 | TC-293, TC-294, TC-316 |
| P191 | N450 - N451 - N452 - N454 - N456 - N457 - N459 - N461 - N463 - N464 - N465 - N466 - N467 - N468 - N470 | TC-297 |
| P192 | N450 - N451 - N452 - N454 - N456 - N457 - N459 - N461 - N463 - N464 - N466 - N467 - N469 - N470 | TC-298 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE579 | TC-287, TC-288, TC-299, TC-298, TC-300, TC-301, TC-291, TC-292, TC-295, TC-289, TC-290, TC-296, TC-293, TC-294, TC-316, TC-297 | Có |
| CE580 | TC-287, TC-288, TC-299, TC-298, TC-300, TC-301, TC-291, TC-292, TC-295, TC-289, TC-290, TC-296, TC-293, TC-294, TC-316, TC-297 | Có |
| CE581 | TC-300 | Có |
| CE582 | TC-287, TC-288, TC-299, TC-298, TC-301, TC-291, TC-292, TC-295, TC-289, TC-290, TC-296, TC-293, TC-294, TC-316, TC-297 | Có |
| CE583 | TC-300 | Có |
| CE584 | TC-301 | Có |
| CE585 | TC-287, TC-288, TC-299, TC-298, TC-291, TC-292, TC-295, TC-289, TC-290, TC-296, TC-293, TC-294, TC-316, TC-297 | Có |
| CE586 | TC-301 | Có |
| CE587 | TC-287, TC-288, TC-299, TC-298, TC-291, TC-292, TC-295, TC-289, TC-290, TC-296, TC-293, TC-294, TC-316, TC-297 | Có |
| CE588 | TC-291, TC-292, TC-295 | Có |
| CE589 | TC-287, TC-288, TC-299, TC-298, TC-289, TC-290, TC-296, TC-293, TC-294, TC-316, TC-297 | Có |
| CE590 | TC-291, TC-292, TC-295 | Có |
| CE591 | TC-289, TC-290, TC-296 | Có |
| CE592 | TC-287, TC-288, TC-299, TC-298, TC-293, TC-294, TC-316, TC-297 | Có |
| CE593 | TC-289, TC-290, TC-296 | Có |
| CE594 | TC-293, TC-294, TC-316 | Có |
| CE595 | TC-287, TC-288, TC-299, TC-298, TC-297 | Có |
| CE596 | TC-293, TC-294, TC-316 | Có |
| CE597 | TC-287, TC-288, TC-299, TC-298, TC-297 | Có |
| CE598 | TC-287, TC-288, TC-299, TC-297 | Có |
| CE599 | TC-298 | Có |
| CE600 | TC-287, TC-288, TC-299, TC-297 | Có |
| CE601 | TC-287, TC-288, TC-299, TC-298, TC-297 | Có |
| CE602 | TC-297 | Có |
| CE603 | TC-287, TC-288, TC-299, TC-298 | Có |
| CE604 | TC-297 | Có |
| CE605 | TC-287, TC-288, TC-299, TC-298 | Có |

Độ phủ đạt được: C0 = 21/21 lệnh và điểm quyết định (100%); C1 = 27/27 nhánh (100%).

Nhánh tiền mặt (cancelCashInTx):

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N471 | bắt đầu | bắt đầu |
| N472 | Do(UserTx): FindByTicket; FindByID suất chiếu (đọc không khoá) | khối lệnh |
| N473 | FindByTicket ném NotFoundError? | quyết định |
| N474 | trả NotFoundError | khối lệnh |
| N475 | LockByKey ghế (6); LockTicketByID (8); now = tx.Now (không có hạng 7) | khối lệnh |
| N476 | CheckCancellationChannel(clerk) ném ChannelMismatchError? | quyết định |
| N477 | trả ChannelMismatchError (vé trực tuyến) | khối lệnh |
| N478 | Showtime.BelongsToCinema(clerk.cinemaId) sai? | quyết định |
| N479 | trả ChannelMismatchError (cụm rạp khác, UC-008 2c) | khối lệnh |
| N480 | CheckCancellationDeadline ném CancelDeadlineError? | quyết định |
| N481 | trả CancelDeadlineError | khối lệnh |
| N482 | Ticket.Cancel ném TicketStateError? | quyết định |
| N483 | trả TicketStateError mang status | khối lệnh |
| N484 | UpdateTicketStatus(CANCELLED); ReleaseTicket(ticketId) | khối lệnh |
| N485 | ReleaseTicket trả true? | quyết định |
| N486 | SaveChanges ghế | khối lệnh |
| N487 | NewCashRefund (REFUNDED, 70%); IF-21.Insert | khối lệnh |
| N488 | commit; trả CancelResult | khối lệnh |
| N489 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE606 | N471 | N472 |  |
| CE607 | N472 | N473 |  |
| CE608 | N473 | N474 | Đúng |
| CE609 | N473 | N475 | Sai |
| CE610 | N474 | N489 |  |
| CE611 | N475 | N476 |  |
| CE612 | N476 | N477 | Đúng |
| CE613 | N476 | N478 | Sai |
| CE614 | N477 | N489 |  |
| CE615 | N478 | N479 | Đúng |
| CE616 | N478 | N480 | Sai |
| CE617 | N479 | N489 |  |
| CE618 | N480 | N481 | Đúng |
| CE619 | N480 | N482 | Sai |
| CE620 | N481 | N489 |  |
| CE621 | N482 | N483 | Đúng |
| CE622 | N482 | N484 | Sai |
| CE623 | N483 | N489 |  |
| CE624 | N484 | N485 |  |
| CE625 | N485 | N486 | Đúng |
| CE626 | N485 | N487 | Sai |
| CE627 | N486 | N487 |  |
| CE628 | N487 | N488 |  |
| CE629 | N488 | N489 |  |

V(G) = số điểm quyết định nhị phân + 1 = 6 + 1 = 7; kiểm bằng E - N + 2 = 24 - 19 + 2 = 7. Không có node SystemBusyError ở nhánh tiền mặt: IF-08.Do dùng chung, TC-301 đã phủ.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P193 | N471 - N472 - N473 - N475 - N476 - N478 - N480 - N482 - N484 - N485 - N486 - N487 - N488 - N489 | TC-302, TC-655 |
| P194 | N471 - N472 - N473 - N474 - N489 | TC-656 |
| P195 | N471 - N472 - N473 - N475 - N476 - N477 - N489 | TC-303 |
| P196 | N471 - N472 - N473 - N475 - N476 - N478 - N479 - N489 | TC-304 |
| P197 | N471 - N472 - N473 - N475 - N476 - N478 - N480 - N481 - N489 | TC-305 |
| P198 | N471 - N472 - N473 - N475 - N476 - N478 - N480 - N482 - N483 - N489 | TC-306, TC-657 |
| P199 | N471 - N472 - N473 - N475 - N476 - N478 - N480 - N482 - N484 - N485 - N487 - N488 - N489 | TC-307 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE606 | TC-302, TC-655, TC-307, TC-656, TC-303, TC-304, TC-305, TC-306, TC-657 | Có |
| CE607 | TC-302, TC-655, TC-307, TC-656, TC-303, TC-304, TC-305, TC-306, TC-657 | Có |
| CE608 | TC-656 | Có |
| CE609 | TC-302, TC-655, TC-307, TC-303, TC-304, TC-305, TC-306, TC-657 | Có |
| CE610 | TC-656 | Có |
| CE611 | TC-302, TC-655, TC-307, TC-303, TC-304, TC-305, TC-306, TC-657 | Có |
| CE612 | TC-303 | Có |
| CE613 | TC-302, TC-655, TC-307, TC-304, TC-305, TC-306, TC-657 | Có |
| CE614 | TC-303 | Có |
| CE615 | TC-304 | Có |
| CE616 | TC-302, TC-655, TC-307, TC-305, TC-306, TC-657 | Có |
| CE617 | TC-304 | Có |
| CE618 | TC-305 | Có |
| CE619 | TC-302, TC-655, TC-307, TC-306, TC-657 | Có |
| CE620 | TC-305 | Có |
| CE621 | TC-306, TC-657 | Có |
| CE622 | TC-302, TC-655, TC-307 | Có |
| CE623 | TC-306, TC-657 | Có |
| CE624 | TC-302, TC-655, TC-307 | Có |
| CE625 | TC-302, TC-655 | Có |
| CE626 | TC-307 | Có |
| CE627 | TC-302, TC-655 | Có |
| CE628 | TC-302, TC-655, TC-307 | Có |
| CE629 | TC-302, TC-655, TC-307 | Có |

Độ phủ đạt được: C0 = 19/19 lệnh và điểm quyết định (100%); C1 = 24/24 nhánh (100%).

#### F2.33.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (DC-PgUnitOfWork.Do) | fake | Chạy fn một lần trên bản sao in-memory của các store giả; fn trả nil --> giữ thay đổi, trả lỗi --> hoàn lại; ghi lại TxOptions và số commit; mang LockOrderGuard thật, test khẳng định Violated() = false | Không dùng PostgreSQL trong unit test; khoá thật là ca tích hợp |
| IF-25.Now | stub | Trả now cố định theo điều kiện đầu, cùng giá trị trong cả giao dịch | Thời gian phải tiêm vào |
| IF-11, IF-18, IF-20, IF-27 | fake | FindByTicket trả Booking (người giữ, kênh); FindByID trả Showtime 55 (start 2026-11-10 20:00, cụm rạp 2); LockByKey; LockTicketByID; UpdateTicketStatus; SaveChanges; thứ tự gọi ghi lại | Store thay bằng bộ nhớ |
| IF-19 | fake | FindTicketedByHold, LockByID, AddRefunded (qua DC-RefundService) | lockPaymentOfTicket |
| DC-RefundService | mock | RequestTicketRefund(tx, txn, ticket, amount): ghi lại tham số, có thể trả RefundLimitError | Kiểm tương tác; logic hoàn tiền kiểm ở F2.35 |
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
| Thời gian | Hạn mỗi lời gọi cổng = nhỏ hơn của 30 giây và (claimedUntil - hiện tại - 10 giây biên); còn dưới 15 giây (hạn tính ra dưới 5 giây) thì bỏ lượt, trả nil và ghi log cảnh báo; Reschedule 1, 5, 15 phút theo lần thử 1, 2, 3 | P12 F3; P09 F7.7 |
| Đã chốt | Bỏ lượt khi claim còn dưới 15 giây, trả nil, ghi log cảnh báo (Q-149, Q-150 đã trả lời); ngoại lệ tên ClaimLostError | P12 F2, F3 |
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
| EC-170 | phần claim còn lại sau giao dịch 1 | dưới 15 giây | Không hợp lệ (bỏ lượt) | 9 giây | P12 F3 bước 2 |
| EC-171 | phần claim còn lại sau giao dịch 1 | từ 40 giây (hạn gọi cổng = 30 giây) | Hợp lệ | 120 giây | BR-43 |

#### F2.36.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-64 | MaxAttempts (RR attemptCount trước khi ghi kết quả) | attemptCount 3 thất bại --> Reschedule 15 phút | EC-165 | WAITING_RETRY, hẹn 15 phút |
| BV-65 | MaxAttempts | attemptCount 4 thất bại | EC-165 | MANUAL_REQUIRED, MarkExhausted |
| BV-66 | phần claim còn lại (EC-170) | 9,999 giây | EC-170 | Bỏ lượt, không gọi cổng |
| BV-67 | phần claim còn lại (EC-170) | 10,001 giây | EC-170 | Bỏ lượt, không gọi cổng (dưới 15 giây) |
| BV-70 | phần claim còn lại (EC-170) | 14,999 giây | EC-170 | Bỏ lượt, không gọi cổng |
| BV-71 | phần claim còn lại | 15,000 giây | EC-171 | Gọi cổng với hạn 5 giây (nhỏ hơn của 30 giây và 15 - 10 giây) |
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
| N302 | mốc cục bộ còn dưới 15 giây (trước FindRefund)? | quyết định |
| N303 | IF-01.FindRefund | khối lệnh |
| N304 | kết quả = REFUNDED? | quyết định |
| N305 | kết quả = NOT_SUPPORTED hoặc UNREACHABLE? | quyết định |
| N306 | MarkManualRequired trong giao dịch riêng; MarkSucceeded dòng hàng đợi | khối lệnh |
| N307 | mốc cục bộ còn dưới 15 giây (trước RequestRefund)? | quyết định |
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
| Chữ ký | VerifyPassword(plain, storedHash) (bool, error); IssueSession(subjectId, subjectKind, role, cinemaId, accessChangedAt) (IssuedSession, error); VerifySession(token) (SessionClaims, error) | P12 F2 PKG-26 |
| Hậu điều kiện | VerifyPassword so mã băm một chiều, so sánh thời gian hằng, MalformedHashError khi hash hỏng. IssueSession: khách 24 giờ, nhân viên 8 giờ, không tự gia hạn (Q-129). VerifySession kiểm chữ ký và hạn, trả claims; không đọc CSDL | P12 F2; P11b Q-129 |
| Đã chốt | Hạn phiên quản trị viên 8 giờ (Q-153); hết hạn khi now >= expiresAt, đồng hồ tiêm vào bộ xác thực (Q-154); chữ ký 2.x: IssueSession(subjectId, subjectKind, role, cinemaId, accessChangedAt); thao tác HashPassword, CheckRole và mốc accessChangedAt kiểm ở F2.54 | P12 F2; Q-153, Q-154 (đã trả lời) |
| Giới hạn | Phần bên trong SS-05 chưa thiết kế (ngoài phạm vi); TC kiểm theo hợp đồng của interface, hiện thực chưa có nên dùng driver gọi interface | P12 mục 0.1 |
| Không áp dụng | Không áp dụng: F2.39.4 (điều kiện độc lập), F2.39.5, F2.39.6 (không có F3: Đo khi có mã nguồn) | - |

#### F2.39.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-179 | role | CUSTOMER | Hợp lệ | CUSTOMER | Q-129 |
| EC-180 | role | nhân viên (BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER) | Hợp lệ | BOX_OFFICE_CLERK | Q-129; NFR-02 |
| EC-181 | role | ADMINISTRATOR | Hợp lệ | ADMINISTRATOR | NFR-03; Q-153 (8 giờ) |
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
| Quan hệ với M9 | Mỗi X-nn trong phạm vi có ca ép cả hai thứ tự đến khi hai thứ tự cho kết cục khác nhau; mỗi dòng Bảng hỏng (M5) có ca hồi phục: ánh xạ ở F4.4 và F4.5 | 00-Concurrency.md M9; User yêu cầu chạy |
| Không áp dụng | Không áp dụng: F2.40.2 đến F2.40.7 (ca tích hợp không phân tích hộp đen/hộp trắng mức đơn vị; test double: không dùng, ngoại trừ cổng thanh toán giả lập) | - |

#### F2.40.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-01 (cổng thanh toán) | fake | Dịch vụ HTTP giả: tạo độ trễ cấu hình được, đếm số lời gọi RequestRefund theo refundKey, trả SUCCEEDED, REJECTED hoặc không trả lời | Hệ thống ngoài VNPay sandbox không dùng cho kiểm thử lặp |

### F2.41 DC-HoldSettlement.End

#### F2.41.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | End(now time.Time, hold *SeatHold, reason HoldEndReason, seats []*SeatStatus) (HoldEndOutcome, error); outcome gồm expired, holdChanged, released | P12 F2 |
| Hậu điều kiện | Luôn gọi hold.Expire(now) trước. EXPIRY chỉ Expire và không bao giờ trả lỗi. CANCEL, PAYMENT_FAILURE: nếu vừa hết hạn do lời gọi này thì expired = true và không gọi Cancel hay FailPayment; ngược lại gọi Cancel hoặc FailPayment, HoldNotActiveError thì trả lỗi và chưa đổi ghế. Khi lần giữ ghế đang EXPIRED, CANCELLED hoặc PAYMENT_FAILED do lời gọi này (hoặc EXPIRED với EXPIRY): ReleaseHold(hold.ID) từng ghế, gom ghế đổi được. Trạng thái cuối khác không đổi. Chạy lặp an toàn | P12 F2, F3; BR-10, BR-85, BR-86 |
| Ngoại lệ | HoldNotActiveError (chỉ CANCEL, PAYMENT_FAILURE) | P12 F2 |
| Sự kiện ST | ST-01 expire, cancel, failPayment; ST-02 releaseHold | P12 F6 |
| Không áp dụng | F2.41.5 gộp vào bảng quyết định DT9 (mỗi chuyển ST-01 một quy tắc); giá trị biên thời gian ở F2.41.3 | - |

#### F2.41.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-190 | reason | EXPIRY | Hợp lệ | EXPIRY | P12 F2 |
| EC-191 | reason | CANCEL | Hợp lệ | CANCEL | P12 F2 |
| EC-192 | reason | PAYMENT_FAILURE | Hợp lệ | PAYMENT_FAILURE | P12 F2 |
| EC-193 | trạng thái lần giữ ghế | ACTIVE và now trước expiryTime | Hợp lệ | H1 ACTIVE, now 10:05 | ST-01 |
| EC-194 | trạng thái lần giữ ghế | ACTIVE và now không trước expiryTime | Hợp lệ | H1 ACTIVE, now 10:10 | BR-10 |
| EC-195 | trạng thái lần giữ ghế | EXPIRED sẵn | Hợp lệ với EXPIRY, Không hợp lệ với CANCEL, PAYMENT_FAILURE | H1 EXPIRED | BR-86 |
| EC-196 | trạng thái lần giữ ghế | COMPLETED, CANCELLED hoặc PAYMENT_FAILED | Hợp lệ với EXPIRY (không đổi), Không hợp lệ với CANCEL, PAYMENT_FAILURE | H1 COMPLETED | BR-86 |
| EC-197 | seats | rỗng hoặc nil | Hợp lệ | nil | P12 F2 |
| EC-198 | seats | mọi ghế HELD bởi chính lần giữ ghế | Hợp lệ | 101, 102 | P12 F2 |
| EC-199 | seats | có ghế đã giữ lại bởi lần giữ ghế khác hoặc đã Trống | Hợp lệ (ghế đó không đổi) | 101 HELD bởi H2 | R-63 |

#### F2.41.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-72 | now so với expiryTime (EC end_hold_active) | now = E - 1ms | lần giữ ghế còn hạn | EXPIRY không đổi gì; CANCEL thành CANCELLED |
| BV-73 | now so với expiryTime (EC end_hold_late) | now = E | quá hạn | EXPIRED với mọi reason |
| BV-74 | kích thước seats | 0 ghế | EC end_seats_none | chỉ đổi trạng thái lần giữ ghế |
| BV-75 | kích thước seats | 1 ghế | EC end_seats_own | ghế duy nhất được trả |
| BV-76 | kích thước seats | 8 ghế (tối đa BR-05) | EC end_seats_own | cả 8 ghế được trả |

#### F2.41.4 Bảng quyết định (DT9)

```text
| Điều kiện / Hành động | DT9-R1 | DT9-R2 | DT9-R3 | DT9-R4 | DT9-R5 | DT9-R6 | DT9-R7 | DT9-R8 |
| C1: reason = EXPIRY | Y | Y | Y | Y | N | N | N | N |
| C2: lần giữ ghế ACTIVE và now trước expiryTime | Y | N | N | N | Y | N | N | N |
| C3: lần giữ ghế ACTIVE và now không trước expiryTime | N | Y | N | N | N | Y | N | N |
| C4: lần giữ ghế đã EXPIRED | N | N | Y | N | N | N | Y | N |
| A1: không đổi gì, expired = false, không trả ghế | X | - | - | - | - | - | - | - |
| A2: chuyển EXPIRED, expired = true, trả các ghế | - | X | - | - | - | X | - | - |
| A3: giữ EXPIRED, expired = true, chỉ trả ghế còn trỏ tới | - | - | X | - | - | - | - | - |
| A4: không đổi (trạng thái cuối khác), expired = false | - | - | - | X | - | - | - | - |
| A5: chuyển CANCELLED hoặc PAYMENT_FAILED, trả các ghế | - | - | - | - | X | - | - | - |
| A6: trả HoldNotActiveError(EXPIRED) | - | - | - | - | - | - | X | - |
| A7: trả HoldNotActiveError mang status cuối | - | - | - | - | - | - | - | X |
```

Căn cứ: C2, C3, C4 loại trừ nhau theo ST-01 (một lần giữ ghế ở đúng một trạng thái), nên tổ hợp có hai điều kiện cùng đúng là N/A và không lập cột; R4 và R8 là trạng thái cuối khác EXPIRED (không điều kiện nào đúng). Với reason khác EXPIRY, CANCEL và PAYMENT_FAILURE cho cùng hành động nên gộp trong một cột, kết quả HoldNotActiveError mang status tương ứng; mỗi reason có TC riêng ở F3.

#### F2.41.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N490 | bắt đầu | bắt đầu |
| N491 | changedByExpiry = hold.Expire(now) | khối lệnh |
| N492 | reason = EXPIRY? | quyết định |
| N493 | lần giữ ghế đang EXPIRED? | quyết định |
| N494 | outcome.expired = true | khối lệnh |
| N495 | changedByExpiry? | quyết định |
| N496 | outcome.expired = true (không gọi Cancel, FailPayment) | khối lệnh |
| N497 | Cancel hoặc FailPayment ném HoldNotActiveError? | quyết định |
| N498 | trả HoldNotActiveError; chưa đổi ghế | khối lệnh |
| N499 | còn ghế chưa xét trong seats? | quyết định |
| N500 | ReleaseHold(hold.ID) trên ghế; gom ghế nếu trả true | khối lệnh |
| N501 | ReleaseHold trả true? | quyết định |
| N502 | thêm ghế vào outcome.released | khối lệnh |
| N503 | outcome.holdChanged = lần giữ ghế vừa đổi trạng thái; trả outcome | khối lệnh |
| N504 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE630 | N490 | N491 |  |
| CE631 | N491 | N492 |  |
| CE632 | N492 | N493 | Đúng |
| CE633 | N492 | N495 | Sai |
| CE634 | N493 | N494 | Đúng |
| CE635 | N493 | N503 | Sai |
| CE636 | N494 | N499 |  |
| CE637 | N495 | N496 | Đúng |
| CE638 | N495 | N497 | Sai |
| CE639 | N496 | N499 |  |
| CE640 | N497 | N498 | Đúng |
| CE641 | N497 | N499 | Sai |
| CE642 | N498 | N504 |  |
| CE643 | N499 | N500 | Đúng |
| CE644 | N499 | N503 | Sai |
| CE645 | N500 | N501 |  |
| CE646 | N501 | N502 | Đúng |
| CE647 | N501 | N499 | Sai |
| CE648 | N502 | N499 |  |
| CE649 | N503 | N504 |  |

V(G) = số điểm quyết định nhị phân + 1 = 6 + 1 = 7; kiểm bằng E - N + 2 = 20 - 15 + 2 = 7. Vòng lặp trên seats: n = 8 (BR-05), m = 3 (điển hình); kiểm thử 0, 1, 3, 7, 8 ghế ở bảng dưới; n+1 = 9 ghế không áp dụng vì số ghế là tiền điều kiện của bên gọi (BR-05 kiểm ở HoldSeats). Lần lặp mà ReleaseHold trả false (DR sai) phủ bởi TC end_exp_again.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P200 | N490 - N491 - N492 - N493 - N494 - N499 - N500 - N501 - N502 - N499 - N503 - N504 | TC-386, TC-387 |
| P201 | N490 - N491 - N492 - N495 - N497 - N498 - N504 | TC-398, TC-397, TC-399 |
| P202 | N490 - N491 - N492 - N495 - N496 - N499 - N500 - N501 - N502 - N499 - N503 - N504 | TC-394, TC-395 |
| P203 | N490 - N491 - N492 - N493 - N503 - N504 | TC-385 |
| P204 | N490 - N491 - N492 - N493 - N494 - N499 - N500 - N501 - N499 - N503 - N504 | TC-388 |
| P205 | N490 - N491 - N492 - N495 - N497 - N499 - N500 - N501 - N502 - N499 - N503 - N504 | TC-391, TC-393 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE630 | TC-385, TC-386, TC-387, TC-388, TC-389, TC-391, TC-393, TC-394, TC-395, TC-398, TC-397, TC-399 | Có |
| CE631 | TC-385, TC-386, TC-387, TC-388, TC-389, TC-391, TC-393, TC-394, TC-395, TC-398, TC-397, TC-399 | Có |
| CE632 | TC-385, TC-386, TC-387, TC-388, TC-389 | Có |
| CE633 | TC-391, TC-393, TC-394, TC-395, TC-398, TC-397, TC-399 | Có |
| CE634 | TC-386, TC-387, TC-388, TC-389 | Có |
| CE635 | TC-385 | Có |
| CE636 | TC-386, TC-387, TC-388, TC-389 | Có |
| CE637 | TC-394, TC-395 | Có |
| CE638 | TC-391, TC-393, TC-398, TC-397, TC-399 | Có |
| CE639 | TC-394, TC-395 | Có |
| CE640 | TC-398, TC-397, TC-399 | Có |
| CE641 | TC-391, TC-393 | Có |
| CE642 | TC-398, TC-397, TC-399 | Có |
| CE643 | TC-386, TC-387, TC-388, TC-391, TC-393, TC-394, TC-395 | Có |
| CE644 | TC-386, TC-387, TC-388, TC-389, TC-391, TC-393, TC-394, TC-395 | Có |
| CE645 | TC-386, TC-387, TC-388, TC-391, TC-393, TC-394, TC-395 | Có |
| CE646 | TC-386, TC-387, TC-391, TC-393, TC-394, TC-395 | Có |
| CE647 | TC-388 | Có |
| CE648 | TC-386, TC-387, TC-391, TC-393, TC-394, TC-395 | Có |
| CE649 | TC-385, TC-386, TC-387, TC-388, TC-389, TC-391, TC-393, TC-394, TC-395 | Có |

Độ phủ đạt được: C0 = 15/15 lệnh và điểm quyết định (100%); C1 = 20/20 nhánh (100%).

| Vòng | n (tối đa) | m (điển hình) | Số lần kiểm thử | TC |
|---|---|---|---|---|
| L trên seats | 8 | 3 | 0 | TC-389 |
| L trên seats | 8 | 3 | 1 | TC-387 |
| L trên seats | 8 | 3 | 3 (m) | TC-391 |
| L trên seats | 8 | 3 | 7 (n-1) | TC-392 |
| L trên seats | 8 | 3 | 8 (n) | TC-393 |

#### F2.41.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-SeatHold, DC-SeatStatus | đối tượng thật | Dựng bằng NewSeatHold, NewAvailable, HoldFor; không giả lập vì là entity thuần | Hậu điều kiện quan sát bằng Status, State, CurrentHold |

### F2.42 DC-HoldSettlement.Sell, FinishSale

#### F2.42.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Sell(now time.Time, hold *SeatHold, seats []*SeatStatus, bookingCode string, ticketCodes []string, snap TicketSnapshot) (*Booking, error); FinishSale(hold *SeatHold, booking *Booking, seats []*SeatStatus) error | P12 F2 |
| Hậu điều kiện | Sell: seats rỗng, số mã vé khác số ghế hoặc có ghế không IsHeldBy(hold.ID) thì LinkMismatchError, chưa đổi gì; rồi hold.Complete(now); rồi Booking cùng vé UNUSED mang giá lúc bán (BR-67) và snapshot (BR-140), chưa đánh dấu ghế. FinishSale: MarkSold(hold.ID, ticketId) cho từng ghế theo khoá ghế của vé; LinkMismatchError nếu không khớp | P12 F2, F3 |
| Ngoại lệ | LinkMismatchError, HoldNotActiveError | P12 F2 |
| Thứ tự kiểm | Kiểm ghế (LinkMismatchError) trước Complete (HoldNotActiveError) | P12 F2 Sell |
| Sự kiện ST | ST-01 complete; ST-02 markSold; ST-03 tạo vé | P12 F6 |
| Không áp dụng | F2.42.4 (hai điều kiện, thứ tự cố định theo F2: bảng nhỏ dưới); F2.42.6 (không có F3 riêng ngoài F2: Đo khi có mã nguồn) | - |

#### F2.42.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-200 | seats và mã vé | không rỗng, mọi ghế IsHeldBy(hold.ID), len(ticketCodes) = len(seats) | Hợp lệ | 2 ghế, 2 mã | P12 F2 |
| EC-201 | seats | rỗng | Không hợp lệ | [] | P12 F2 |
| EC-202 | số mã vé | khác số ghế | Không hợp lệ | 2 ghế, 1 mã | P12 F2 |
| EC-203 | liên kết ghế | có ghế không IsHeldBy(hold.ID) | Không hợp lệ | ghế 102 HELD bởi H2 | R-63 |
| EC-204 | lần giữ ghế | ACTIVE, now trước expiryTime | Hợp lệ | now 10:05 | BR-85 |
| EC-205 | lần giữ ghế | không còn ACTIVE hoặc now không trước expiryTime | Không hợp lệ | EXPIRED; ACTIVE ở now = E | BR-86; Q-142 |
| EC-206 | vé và ghế của FinishSale | mỗi ghế có vé cùng khoá ghế, ghế HELD bởi hold.ID | Hợp lệ | 2 vé có id | P12 F2 |
| EC-207 | vé và ghế của FinishSale | ghế không có vé khớp khoá, hoặc ghế không còn HELD bởi hold.ID | Không hợp lệ | ghế 102 đã Trống | P12 F2 |

Bảng quyết định nhỏ (thứ tự kiểm theo F2: kiểm ghế trước Complete): hai điều kiện C1 (ghế sai) và C2 (lần giữ ghế không còn hiệu lực) cho bốn quy tắc: C1 đúng thì LinkMismatchError bất kể C2 (gộp "-" có căn cứ thứ tự F2); C1 sai và C2 đúng thì HoldNotActiveError; cả hai sai thì Booking. Ba quy tắc, mỗi quy tắc có TC ở F3: DT11-R1 (C1 Y, C2 -): LinkMismatchError; DT11-R2 (N, Y): HoldNotActiveError; DT11-R3 (N, N): Booking.

#### F2.42.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| DC-SeatHold, DC-SeatStatus, DC-Booking, DC-Ticket | đối tượng thật | Dựng bằng hàm dựng công khai; vé nhận id bằng bộ dựng chỉ có ở test (SetTicketId) vì id do kho gán lúc InsertWithTickets; ghi đề xuất sửa P12 bổ sung operation gán id vé | Điều kiện đầu không dựng được bằng operation công khai |

### F2.43 DC-LockOrderGuard.AcquireValue (khoá giá trị hạng 0, 11, 12, 13)

#### F2.43.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | AcquireValue(kind ValueLockKind, raw string) error | P12 F2 |
| Hậu điều kiện | Ghi nhận khoá tư vấn theo giá trị với khoá (-1, 0) và hạng của kind: CINEMA_NAME hạng 0, CUSTOMER_EMAIL 11, CUSTOMER_PHONE 12, STAFF_EMAIL 13. Hạng nhỏ hơn maxRank vi phạm; cùng hạng chỉ hợp lệ khi lấy lại đúng giá trị đã lấy hoặc chưa có khoá nào ở hạng đó; mỗi hạng tối đa một giá trị mỗi giao dịch (Q-324) | P12 F2, F3; P09 F7.3 |
| Ngoại lệ | LockOrderViolationError, LockInReadOnlyTxError | P12 F2 |
| Thao tác nguyên tử | EX-17 (CINEMA_NAME), EX-20 (CUSTOMER_EMAIL rồi CUSTOMER_PHONE), EX-21 (STAFF_EMAIL); X-26, X-30, X-31 | P08 F4b |
| Ghi chú | Khoá thật là pg_advisory_xact_lock(1000 + hạng, hashtext(...)) do DC-PgUnitOfWork.LockValue gửi, kiểm bằng ca tích hợp (F2.55); P13 kiểm các chỉ mục unique theo biểu thức bằng P13-schema-tests.sql nên không lặp ở đây | P12 F3 |

#### F2.43.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-208 | chế độ giao dịch | READ_ONLY hoặc SNAPSHOT_READ_ONLY | Không hợp lệ | guard chỉ đọc | P12 F2 |
| EC-209 | chế độ giao dịch | READ_WRITE | Hợp lệ | guard ghi | P12 F2 |
| EC-210 | hạng của kind so với maxRank | lớn hơn | Hợp lệ | email (11) rồi phone (12) | P09 F7.3 |
| EC-211 | hạng của kind so với maxRank | nhỏ hơn | Không hợp lệ | phone (12) rồi email (11) | P08 F4b quy tắc 3 |
| EC-212 | cùng hạng | lấy lại đúng raw | Hợp lệ | email a, email a | Q-324 |
| EC-213 | cùng hạng | raw khác | Không hợp lệ | email a, email b | Q-324 |
| EC-214 | cùng hạng 0 | đã có khoá dòng Cinema | Không hợp lệ | Acquire(CINEMA, 9) rồi CINEMA_NAME | P12 F2 |

#### F2.43.6 Hộp trắng

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N505 | bắt đầu | bắt đầu |
| N506 | guard của giao dịch chỉ đọc? | quyết định |
| N507 | trả LockInReadOnlyTxError | khối lệnh |
| N508 | rank = kind.rank | khối lệnh |
| N509 | rank nhỏ hơn maxRank? | quyết định |
| N510 | violated = true; trả LockOrderViolationError | khối lệnh |
| N511 | rank bằng maxRank? | quyết định |
| N512 | đã có khoá giá trị cùng kind? | quyết định |
| N513 | raw khác giá trị đã lấy? | quyết định |
| N514 | violated = true; trả LockOrderViolationError | khối lệnh |
| N515 | lấy lại cùng giá trị: không đổi gì; trả nil | khối lệnh |
| N516 | đã có khoá dòng cùng hạng 0: violated = true; trả LockOrderViolationError | khối lệnh |
| N517 | maxRank = rank; maxKey = (-1, 0); nhớ raw theo kind; trả nil | khối lệnh |
| N518 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE650 | N505 | N506 |  |
| CE651 | N506 | N507 | Đúng |
| CE652 | N506 | N508 | Sai |
| CE653 | N507 | N518 |  |
| CE654 | N508 | N509 |  |
| CE655 | N509 | N510 | Đúng |
| CE656 | N509 | N511 | Sai |
| CE657 | N510 | N518 |  |
| CE658 | N511 | N512 | Đúng |
| CE659 | N511 | N517 | Sai |
| CE660 | N512 | N513 | Đúng |
| CE661 | N512 | N516 | Sai |
| CE662 | N513 | N514 | Đúng |
| CE663 | N513 | N515 | Sai |
| CE664 | N514 | N518 |  |
| CE665 | N515 | N518 |  |
| CE666 | N516 | N518 |  |
| CE667 | N517 | N518 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 18 - 14 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P206 | N505 - N506 - N508 - N509 - N511 - N512 - N513 - N515 - N518 | TC-413 |
| P207 | N505 - N506 - N507 - N518 | TC-409 |
| P208 | N505 - N506 - N508 - N509 - N510 - N518 | TC-412 |
| P209 | N505 - N506 - N508 - N509 - N511 - N517 - N518 | TC-410, TC-411, TC-416 |
| P210 | N505 - N506 - N508 - N509 - N511 - N512 - N513 - N514 - N518 | TC-414 |
| P211 | N505 - N506 - N508 - N509 - N511 - N512 - N516 - N518 | TC-415 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE650 | TC-409, TC-412, TC-410, TC-411, TC-416, TC-413, TC-414, TC-415 | Có |
| CE651 | TC-409 | Có |
| CE652 | TC-412, TC-410, TC-411, TC-416, TC-413, TC-414, TC-415 | Có |
| CE653 | TC-409 | Có |
| CE654 | TC-412, TC-410, TC-411, TC-416, TC-413, TC-414, TC-415 | Có |
| CE655 | TC-412 | Có |
| CE656 | TC-410, TC-411, TC-416, TC-413, TC-414, TC-415 | Có |
| CE657 | TC-412 | Có |
| CE658 | TC-413, TC-414, TC-415 | Có |
| CE659 | TC-410, TC-411, TC-416 | Có |
| CE660 | TC-413, TC-414 | Có |
| CE661 | TC-415 | Có |
| CE662 | TC-414 | Có |
| CE663 | TC-413 | Có |
| CE664 | TC-414 | Có |
| CE665 | TC-413 | Có |
| CE666 | TC-415 | Có |
| CE667 | TC-410, TC-411, TC-416 | Có |

Độ phủ đạt được: C0 = 14/14 lệnh và điểm quyết định (100%); C1 = 18/18 nhánh (100%).

#### F2.43.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có | - | Đối tượng thuần: DC-LockOrderGuard dựng bằng NewLockOrderGuard(readOnly) | Không phụ thuộc ngoài |

### F2.44 DC-Staff.CheckAccessUnchanged, DC-BoxOfficeClerk.CheckAccessCurrent, DC-AccessCheckService.CheckStaffAccess (BR-101)

#### F2.44.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckAccessUnchanged(sessionAccessChangedAt time.Time) error; CheckAccessCurrent(sessionAccessChangedAt time.Time) error; CheckStaffAccess(ctx Ctx, claims SessionClaims) (StaffAccess, error) | P12 F2 |
| Hậu điều kiện | Từ chối khi dòng Staff Bị khoá hoặc accessChangedAt khác mốc của phiên (so Equal, micro giây); CheckStaffAccess trả vai trò và cụm rạp của dòng vừa đọc, không lấy từ mã phiên; dòng không có hoặc subjectId không phải số: StaffAccessRevokedError | P12 F2, F3 |
| Ngoại lệ | StaffAccessRevokedError (CheckAccessUnchanged, CheckStaffAccess), StaffAccessChangedError (CheckAccessCurrent), SystemBusyError | P12 F2 |
| Thao tác nguyên tử | EX-22 với EX-01 (X-33) | P08 F4b; P09 F7.11 |
| Bất biến | Dòng staff không bị xoá (BR-96) nên nhánh "không có dòng" của CheckStaffAccess chỉ xảy ra với subjectId giả; kiểm bằng TC subjectId không phải số | BR-96 |

#### F2.44.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-215 | trạng thái và mốc của dòng Staff | Đang hoạt động và accessChangedAt bằng mốc phiên | Hợp lệ | 2026-11-10 07:00:00.000001 | BR-101 |
| EC-216 | trạng thái | Bị khoá | Không hợp lệ | LOCKED, mốc bằng | BR-97, BR-101 |
| EC-217 | mốc | khác mốc phiên | Không hợp lệ | lệch 1 micro giây | BR-101 |
| EC-218 | subjectId | không phải số | Không hợp lệ | "abc" | P12 F3 |

#### F2.44.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-77 | mốc so với phiên (EC ac_ok) | cùng thời điểm, khác múi giờ (UTC và +07:00) | ac_ok | chấp nhận (so Equal, không so ==) |
| BV-78 | mốc so với phiên | lớn hơn 1 micro giây | ac_stale | từ chối |

#### F2.44.4 Bảng quyết định

```text
| Điều kiện / Hành động | DT13-R1 | DT13-R2 | DT13-R3 |
| C1: tài khoản Bị khoá | N | Y | N |
| C2: accessChangedAt khác mốc phiên | N | - | Y |
| A1: chấp nhận | X | - | - |
| A2: từ chối (StaffAccessRevokedError) | - | X | X |
```

Căn cứ gộp: hai điều kiện cho cùng một lỗi nên thứ tự kiểm không ảnh hưởng kết quả; quy tắc C1 và C2 cùng đúng gộp vào R2 bằng "-".

#### F2.44.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-15 (FindByID), IF-08 | fake | FindByID trả Staff theo điều kiện đầu; Do(ReadOnlyTx) chạy fn; guard chỉ đọc không cho Acquire | Store thay bằng bộ nhớ |
| DC-Staff | đối tượng thật | Dựng bằng RestoreStaff(rec) | Điều kiện đầu dựng từ bản ghi, không có operation công khai tạo trạng thái LOCKED trực tiếp ngoài LockStaff |

### F2.45 DC-Customer.CheckRegistrationData, DC-RegisterAccountService.RegisterAccount

#### F2.45.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckRegistrationData(email, phoneNumber, plainPassword string) error; RegisterAccount(ctx Ctx, email, phoneNumber, plainPassword string) (CustomerId, error) | P12 F2 |
| Hậu điều kiện | CheckRegistrationData trả điều kiện đầu tiên vi phạm theo thứ tự EMAIL (BR-81), PHONE (BR-82), PASSWORD (BR-99), không đọc CSDL. RegisterAccount: sai dữ liệu thì chưa băm, chưa mở giao dịch; rồi băm, rồi một giao dịch LockValue(email) hạng 11 trước LockValue(phone) hạng 12, SaveCustomer; trùng email hoặc số điện thoại thì DuplicateAccountError, không ghi gì; thành công trả mã khách, không cấp phiên (Q-158) | P12 F2, F3 |
| Ngoại lệ | RegistrationDataError (mang field), DuplicateAccountError, SystemBusyError | P12 F2 |
| Thao tác nguyên tử | EX-20; X-30 | P08 F4b |
| Luồng P04 | UC-001 2a, 2b, 2c, 7a | P04 UC-001 |

#### F2.45.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-219 | email | có dạng email chuẩn | Hợp lệ | an@cinebook.vn | BR-81 |
| EC-220 | email | không có @ hoặc thiếu miền | Không hợp lệ | an.cinebook.vn | BR-81 |
| EC-221 | số điện thoại | 10 chữ số, bắt đầu 0 | Hợp lệ | 0901234567 | BR-82 |
| EC-222 | số điện thoại | không đủ 10 chữ số | Không hợp lệ | 090123456 | BR-82 |
| EC-223 | số điện thoại | 10 chữ số nhưng không bắt đầu 0 | Không hợp lệ | 1901234567 | BR-82 |
| EC-224 | số điện thoại | có ký tự không phải chữ số | Không hợp lệ | 09012345a7 | BR-82 |
| EC-225 | mật khẩu | từ 8 ký tự | Hợp lệ | Abc@1234 | BR-99 |
| EC-226 | mật khẩu | dưới 8 ký tự | Không hợp lệ | Abc@123 | BR-99 |
| EC-227 | email đã đăng ký | thuộc khách khác | Không hợp lệ | an@cinebook.vn | BR-98 |
| EC-228 | số điện thoại đã đăng ký | thuộc khách khác | Không hợp lệ | 0901234567 | BR-98 |

#### F2.45.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-79 | độ dài số điện thoại (EC rg_phone_ok) | 9 chữ số | rg_phone_len | RegistrationDataError(PHONE) |
| BV-80 | độ dài số điện thoại | 10 chữ số | rg_phone_ok | hợp lệ |
| BV-81 | độ dài số điện thoại | 11 chữ số | rg_phone_len | RegistrationDataError(PHONE) |
| BV-82 | độ dài mật khẩu (EC rg_pw_ok) | 7 ký tự | rg_pw_short | RegistrationDataError(PASSWORD) |
| BV-83 | độ dài mật khẩu | 8 ký tự | rg_pw_ok | hợp lệ |

#### F2.45.4 Bảng quyết định

```text
| Điều kiện / Hành động | DT12-R1 | DT12-R2 | DT12-R3 | DT12-R4 | DT12-R5 | DT12-R6 | DT12-R7 | DT12-R8 |
| C1: email sai | N | Y | N | N | Y | Y | N | Y |
| C2: số điện thoại sai | N | - | Y | N | Y | N | Y | Y |
| C3: mật khẩu sai | N | - | - | Y | N | Y | Y | Y |
| A0: hợp lệ | X | - | - | - | - | - | - | - |
| A1: RegistrationDataError(EMAIL) | - | X | - | - | X | X | - | X |
| A2: RegistrationDataError(PHONE) | - | - | X | - | - | - | X | - |
| A3: RegistrationDataError(PASSWORD) | - | - | - | X | - | - | - | - |
```

Căn cứ gộp: F2 nêu thứ tự EMAIL, PHONE, PASSWORD và trả điều kiện đầu tiên vi phạm, nên R2 gộp C2, C3 bằng "-", R3 gộp C3. Tám cột liệt kê đủ 2^3 tổ hợp: R5 (email và phone sai) và R6 (email và mật khẩu sai) và R8 (cả ba sai) cùng cho EMAIL; R7 (phone và mật khẩu sai) cho PHONE.

#### F2.45.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-07 | mock | HashPassword được gọi 0 lần khi dữ liệu sai, 1 lần khi hợp lệ, trước khi mở giao dịch | Kiểm thứ tự băm ngoài giao dịch |
| IF-08 (Do, LockValue) | fake | LockValue ghi lại thứ tự (CUSTOMER_EMAIL rồi CUSTOMER_PHONE); guard thật | Kiểm thứ tự khoá hạng 11 trước 12 |
| IF-16 (SaveCustomer) | fake | Trả DuplicateAccountError theo điều kiện đầu; ghi khách vào bộ nhớ | Store thay bằng bộ nhớ |

### F2.46 DC-LoginService.LoginCustomer, LoginStaff

#### F2.46.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | LoginCustomer(ctx Ctx, login, plainPassword string) (IssuedSession, error); LoginStaff(ctx Ctx, email, plainPassword string) (IssuedSession, error) | P12 F2 |
| Hậu điều kiện | Một thông điệp chung LoginFailedError cho tài khoản không có và mật khẩu sai (NFR-01, Q-131), kèm VerifyPassword với dummyPasswordHash để thời gian phản hồi không lộ tài khoản có hay không. StaffLockedError chỉ khi mật khẩu đúng (BR-97, Q-276). Mốc accessChangedAt của phiên nhân viên là giá trị của đúng câu đọc đăng nhập (BR-101). Không đổi dữ liệu, không lưu phiên | P12 F2, F3 |
| Ngoại lệ | LoginFailedError, StaffLockedError, SystemBusyError | P12 F2 |
| Luồng P04 | UC-005 5a2a (đăng nhập khách); UC-017 (khoá tài khoản) | P04 |

#### F2.46.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-229 | tài khoản và mật khẩu | tài khoản có, mật khẩu đúng | Hợp lệ | an@cinebook.vn | NFR-01 |
| EC-230 | tài khoản | không có | Không hợp lệ | none@x.vn | Q-131 |
| EC-231 | mật khẩu | sai với tài khoản có | Không hợp lệ | Abc@12345 | NFR-01 |
| EC-232 | trạng thái nhân viên với mật khẩu đúng | Bị khoá | Không hợp lệ | LOCKED | BR-97; Q-276 |
| EC-233 | trạng thái nhân viên với mật khẩu sai | Bị khoá | Không hợp lệ | LOCKED, mật khẩu sai | Q-276 |
| EC-234 | email | thuộc quản trị viên | Hợp lệ | admin@cinebook.vn | Q-271 |

#### F2.46.6 Hộp trắng

LoginCustomer:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N519 | bắt đầu | bắt đầu |
| N520 | c = IF-16.FindCustomerByLogin(login) | khối lệnh |
| N521 | không tìm thấy khách? | quyết định |
| N522 | VerifyPassword(plain, dummyPasswordHash); bỏ kết quả | khối lệnh |
| N523 | trả LoginFailedError | khối lệnh |
| N524 | VerifyPassword(plain, c.PasswordHash()) sai? | quyết định |
| N525 | IssueSession(id, CUSTOMER, CUSTOMER, "", nil); trả | khối lệnh |
| N526 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE668 | N519 | N520 |  |
| CE669 | N520 | N521 |  |
| CE670 | N521 | N522 | Đúng |
| CE671 | N521 | N524 | Sai |
| CE672 | N522 | N523 |  |
| CE673 | N524 | N523 | Đúng |
| CE674 | N524 | N525 | Sai |
| CE675 | N523 | N526 |  |
| CE676 | N525 | N526 |  |

V(G) = số điểm quyết định nhị phân + 1 = 2 + 1 = 3; kiểm bằng E - N + 2 = 9 - 8 + 2 = 3.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P212 | N519 - N520 - N521 - N524 - N525 - N526 | TC-445, TC-446 |
| P213 | N519 - N520 - N521 - N522 - N523 - N526 | TC-447 |
| P214 | N519 - N520 - N521 - N524 - N523 - N526 | TC-448 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE668 | TC-445, TC-446, TC-447, TC-448 | Có |
| CE669 | TC-445, TC-446, TC-447, TC-448 | Có |
| CE670 | TC-447 | Có |
| CE671 | TC-445, TC-446, TC-448 | Có |
| CE672 | TC-447 | Có |
| CE673 | TC-448 | Có |
| CE674 | TC-445, TC-446 | Có |
| CE675 | TC-447, TC-448 | Có |
| CE676 | TC-445, TC-446 | Có |

Độ phủ đạt được: C0 = 8/8 lệnh và điểm quyết định (100%); C1 = 9/9 nhánh (100%).

LoginStaff:

Bảng node:

| N | Nội dung (lệnh hoặc điều kiện) | Loại (khối lệnh / quyết định / bắt đầu / kết thúc) |
|---|---|---|
| N527 | bắt đầu | bắt đầu |
| N528 | s = IF-15.FindByEmail(email) | khối lệnh |
| N529 | không có dòng nhân viên? | quyết định |
| N530 | a = FindAdministratorByEmail | khối lệnh |
| N531 | không có tài khoản quản trị viên? | quyết định |
| N532 | VerifyPassword(plain, dummyPasswordHash); bỏ kết quả | khối lệnh |
| N533 | VerifyPassword(plain, a.passwordHash) sai? | quyết định |
| N534 | IssueSession(id, STAFF, ADMINISTRATOR, "", nil) | khối lệnh |
| N535 | VerifyPassword(plain, s.PasswordHash()) sai? | quyết định |
| N536 | s.Status() là LOCKED? | quyết định |
| N537 | trả StaffLockedError | khối lệnh |
| N538 | IssueSession(id, STAFF, ToRole(role), cinemaId, s.AccessChangedAt()) | khối lệnh |
| N539 | trả LoginFailedError | khối lệnh |
| N540 | kết thúc | kết thúc |

Bảng cạnh:

| CE | Từ N | Tới N | Nhãn (Đúng / Sai / rỗng) |
|---|---|---|---|
| CE677 | N527 | N528 |  |
| CE678 | N528 | N529 |  |
| CE679 | N529 | N530 | Đúng |
| CE680 | N529 | N535 | Sai |
| CE681 | N530 | N531 |  |
| CE682 | N531 | N532 | Đúng |
| CE683 | N531 | N533 | Sai |
| CE684 | N532 | N539 |  |
| CE685 | N533 | N539 | Đúng |
| CE686 | N533 | N534 | Sai |
| CE687 | N535 | N539 | Đúng |
| CE688 | N535 | N536 | Sai |
| CE689 | N536 | N537 | Đúng |
| CE690 | N536 | N538 | Sai |
| CE691 | N539 | N540 |  |
| CE692 | N537 | N540 |  |
| CE693 | N534 | N540 |  |
| CE694 | N538 | N540 |  |

V(G) = số điểm quyết định nhị phân + 1 = 5 + 1 = 6; kiểm bằng E - N + 2 = 18 - 14 + 2 = 6.

Đường đi cơ sở (mỗi đường do ít nhất một TC đi qua):

| Đường | Chuỗi node | TC |
|---|---|---|
| P215 | N527 - N528 - N529 - N530 - N531 - N533 - N534 - N540 | TC-453 |
| P216 | N527 - N528 - N529 - N535 - N536 - N538 - N540 | TC-449 |
| P217 | N527 - N528 - N529 - N530 - N531 - N532 - N539 - N540 | TC-455 |
| P218 | N527 - N528 - N529 - N535 - N536 - N537 - N540 | TC-450 |
| P219 | N527 - N528 - N529 - N535 - N539 - N540 | TC-452 |
| P220 | N527 - N528 - N529 - N530 - N531 - N533 - N539 - N540 | TC-454 |

Bảng phủ nhánh:

| Nhánh (CE) | TC phủ | Đạt |
|---|---|---|
| CE677 | TC-449, TC-450, TC-452, TC-453, TC-454, TC-455 | Có |
| CE678 | TC-449, TC-450, TC-452, TC-453, TC-454, TC-455 | Có |
| CE679 | TC-453, TC-454, TC-455 | Có |
| CE680 | TC-449, TC-450, TC-452 | Có |
| CE681 | TC-453, TC-454, TC-455 | Có |
| CE682 | TC-455 | Có |
| CE683 | TC-453, TC-454 | Có |
| CE684 | TC-455 | Có |
| CE685 | TC-454 | Có |
| CE686 | TC-453 | Có |
| CE687 | TC-452 | Có |
| CE688 | TC-449, TC-450 | Có |
| CE689 | TC-450 | Có |
| CE690 | TC-449 | Có |
| CE691 | TC-452, TC-454, TC-455 | Có |
| CE692 | TC-450 | Có |
| CE693 | TC-453 | Có |
| CE694 | TC-449 | Có |

Độ phủ đạt được: C0 = 14/14 lệnh và điểm quyết định (100%); C1 = 18/18 nhánh (100%).

TC TC-451 phủ vế "mật khẩu sai" của điều kiện kiểm khoá (BR-97): nhân viên Bị khoá mà mật khẩu sai thì đi nhánh D4 và nhận LoginFailedError, không nhận StaffLockedError.

#### F2.46.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-16 (FindCustomerByLogin), IF-15 (FindByEmail, FindAdministratorByEmail) | fake | Trả khách, nhân viên, quản trị viên theo điều kiện đầu hoặc NotFoundError | Store thay bằng bộ nhớ |
| IF-07 | stub | VerifyPassword trả đúng, sai theo cặp (plain, hash); ghi lại số lần và mã băm đã dùng (dummyPasswordHash khi không có tài khoản); IssueSession ghi lại tham số | Kiểm không lộ tài khoản có hay không |

### F2.47 DC-Staff.CheckStaffData, CheckRoleAndCinema, SaveStaffChanges, LockStaff, UnlockStaff, RenameStaff, ResetStaffPassword; DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess

#### F2.47.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckStaffData(email, fullName, role, cinemaId) error; CheckRoleAndCinema(role, cinemaId) error; SaveStaffChanges(expectedChangedAt, role, cinemaId, now) error; LockStaff, UnlockStaff(expectedChangedAt, now) error; RenameStaff(expectedChangedAt, newFullName, now) error; ResetStaffPassword(expectedChangedAt, newPasswordHash, now) error | P12 F2 |
| Hậu điều kiện | CheckStaffData theo thứ tự email (định dạng chuẩn, tối đa 254 ký tự), họ tên (không rỗng, tối đa 100), rồi CheckRoleAndCinema. CheckRoleAndCinema: bốn vai trò; quản lý chuỗi cinemaId = 0, ba vai trò còn lại cinemaId khác 0. Mọi thao tác lưu: lệch expectedChangedAt thì StaleStaffError, không ghi (BR-102). lastChangedAt = now ở mọi thao tác ghi; accessChangedAt = now chỉ khi khoá hoặc đổi vai trò hoặc cụm rạp; mở khoá, đổi tên, đặt lại mật khẩu giữ accessChangedAt | P12 F2; BR-78, BR-79, BR-101, BR-102 |
| Ngoại lệ | StaffDataError, StaleStaffError, StaffStatusUnchangedError | P12 F2 |
| Thứ tự kiểm LockStaff, UnlockStaff | Trạng thái không đổi (1b3a, 1c3a) trước mốc lệch (1b3b, 1c3b) | P12 F3 LockStaffAccount; P08 F4b X-32; P04 UC-017 |
| Thao tác nguyên tử | EX-21, EX-22; X-31, X-32, X-33 | P08 F4b |
| Luồng P04 | UC-017 4a đến 4d, 5a, 5b, 1b3a, 1b3b, 1c3a, 1c3b, 1d4b, 1e4a | P04 UC-017 |

#### F2.47.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-235 | email | định dạng chuẩn, tối đa 254 ký tự | Hợp lệ | mai@cinebook.vn | BR-95; Q-163 |
| EC-236 | email | sai định dạng hoặc dài hơn 254 ký tự | Không hợp lệ | mai.cinebook.vn | Q-163 |
| EC-237 | họ tên | 1 đến 100 ký tự | Hợp lệ | Nguyễn Thị Mai | Q-273 |
| EC-238 | họ tên | rỗng hoặc dài hơn 100 ký tự | Không hợp lệ | "" | Q-273 |
| EC-239 | vai trò và cụm rạp | CHAIN_MANAGER với cinemaId = 0 | Hợp lệ | CHAIN_MANAGER, 0 | BR-78 |
| EC-240 | vai trò và cụm rạp | CHAIN_MANAGER với cinemaId khác 0 | Không hợp lệ | CHAIN_MANAGER, 2 | BR-78 |
| EC-241 | vai trò và cụm rạp | ba vai trò còn lại với cinemaId khác 0 | Hợp lệ | TICKET_CHECKER, 2 | BR-78 |
| EC-242 | vai trò và cụm rạp | ba vai trò còn lại với cinemaId = 0 | Không hợp lệ | BOX_OFFICE_CLERK, 0 | BR-78 |
| EC-243 | vai trò | ngoài bốn giá trị | Không hợp lệ | giá trị 9 | BR-79 |
| EC-244 | mốc lúc hiển thị | bằng lastChangedAt của dòng | Hợp lệ | T0 | BR-102 |
| EC-245 | mốc lúc hiển thị | khác lastChangedAt | Không hợp lệ | T0 - 1 micro giây | BR-102 |
| EC-246 | trạng thái với LockStaff | ACTIVE | Hợp lệ | ACTIVE | BR-96 |
| EC-247 | trạng thái với LockStaff | LOCKED | Không hợp lệ | LOCKED | UC-017 1b3a |

#### F2.47.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-84 | độ dài email (EC sf_email_ok) | 254 ký tự | sf_email_ok | hợp lệ |
| BV-85 | độ dài email | 255 ký tự | sf_email_bad | StaffDataError(EMAIL) |
| BV-86 | độ dài họ tên | 0 ký tự | sf_name_bad | StaffDataError(NAME) |
| BV-87 | độ dài họ tên | 1 ký tự | sf_name_ok | hợp lệ |
| BV-88 | độ dài họ tên | 100 ký tự | sf_name_ok | hợp lệ |
| BV-89 | độ dài họ tên | 101 ký tự | sf_name_bad | StaffDataError(NAME) |

#### F2.47.4 Bảng quyết định

```text
| Điều kiện / Hành động | DT14-R1 | DT14-R2 | DT14-R3 | DT14-R4 |
| C1: tài khoản đang Bị khoá (1b3a) | N | Y | N | Y |
| C2: mốc lệch khỏi lúc hiển thị (1b3b) | N | N | Y | Y |
| A1: khoá thành công, accessChangedAt = now | X | - | - | - |
| A2: StaffStatusUnchangedError | - | X | - | X |
| A3: StaleStaffError | - | - | X | - |
```

Căn cứ: P08 F4b X-32 ("hai yêu cầu khoá: bên sau thấy tài khoản đã bị khoá") và P12 F3 LockStaffAccount nêu trạng thái kiểm trước mốc, nên R4 cho StaffStatusUnchangedError; bảng cho LockStaff; UnlockStaff đối xứng nhưng P12, P04 chưa nêu rõ quy tắc cả hai điều kiện cùng sai nên TC tương ứng chờ Q-354.

#### F2.47.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có | - | Đối tượng thuần (DC-Staff dựng bằng DraftStaff, RestoreStaff); DC-ManageStaffAccountsService kiểm ở F2.47 bằng fake IF-08, IF-15, IF-13 và stub IF-07 theo cùng mẫu F2.45 | Entity không biết SQL |

### F2.48 DC-Customer.CheckOwnsBooking, DC-Ticket.Snapshot, DC-Booking.Summary, DC-ViewBookingHistoryService.ListHistory, FindBookingTickets

#### F2.48.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckOwnsBooking(b *Booking) error; Snapshot() TicketSnapshot; Summary(startTime time.Time) BookingSummary; ListHistory(ctx Ctx, customerId CustomerId) ([]BookingSummary, error); FindBookingTickets(ctx Ctx, customerId CustomerId, bookingCode string) (BookingView, error) | P12 F2 |
| Hậu điều kiện | Khách chỉ xem lần đặt có customerId bằng ID của mình (BR-94). Vé giữ tên phim, cụm rạp, phòng chiếu, loại phòng lúc bán (BR-140); sửa các thông tin này sau đó không đổi vé. Lần đặt tại quầy có customerId rỗng. Lịch sử sắp bookedAt giảm dần; khách chưa có lần đặt thì danh sách rỗng | P12 F2, F3 |
| Ngoại lệ | BookingNotOwnedError, NotFoundError, SystemBusyError | P12 F2 |
| Luồng P04 | UC-007 luồng chính, luồng thay thế rỗng, 3a (lần đặt của khách khác) | P04 UC-007 |

#### F2.48.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-248 | chủ lần đặt | customerId bằng khách | Hợp lệ | khách 7, lần đặt của 7 | BR-94 |
| EC-249 | chủ lần đặt | customerId của khách khác | Không hợp lệ | khách 7, lần đặt của 8 | BR-94 |
| EC-250 | chủ lần đặt | không có customerId (mua tại quầy) | Không hợp lệ | rỗng | BR-94 |
| EC-251 | sửa thông tin sau khi bán | tên phim, cụm rạp, phòng đổi | Hợp lệ (vé giữ giá trị cũ) | phim đổi tên | BR-140 |
| EC-252 | số lần đặt | 0, 1, nhiều | Hợp lệ | 0 và 3 | UC-007 |

#### F2.48.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (ReadTx), IF-20, IF-16 | fake | ListSummariesByCustomer trả danh sách đã sắp; FindByCode trả Booking hoặc NotFoundError; FindCustomer | Store thay bằng bộ nhớ |
| DC-Booking, DC-Ticket | đối tượng thật | Dựng bằng NewBooking với snap | Entity thuần |

### F2.49 DC-BookTicketsService.FindActiveHold, GetHold; DC-CancelTicketService.PrepareCashRefund

#### F2.49.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | FindActiveHold(ctx Ctx, by HolderRef) (HoldResult, bool, error); GetHold(ctx Ctx, holdRef string, by HolderRef) (HoldResult, error); PrepareCashRefund(ctx Ctx, ticketId TicketId, clerk HolderRef) (CashRefundView, error) | P12 F2 |
| Hậu điều kiện | Chỉ đọc, không khoá. FindActiveHold: lần giữ ghế ACTIVE chưa quá hạn của người giữ, ngược lại (HoldResult{}, false, nil). GetHold: holdStatus = trạng thái đang lưu (ACTIVE quá expiryTime vẫn ACTIVE, quyết định hết hạn thuộc thao tác ghi), serverTime = now của CSDL, bookingCode khi COMPLETED; by không phải người giữ hoặc holdRef lạ: NotFoundError (Q-147). PrepareCashRefund kiểm đúng thứ tự kênh, cụm rạp, trạng thái vé, hạn huỷ, không ghi, trả số tiền hoàn 70% | P12 F2, F3 |
| Ngoại lệ | NotFoundError, ChannelMismatchError, TicketStateError, CancelDeadlineError | P12 F2 |

#### F2.49.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-253 | lần giữ ghế của người giữ | ACTIVE, now trước expiryTime | Hợp lệ | H1 ACTIVE | BR-04 |
| EC-254 | lần giữ ghế của người giữ | ACTIVE nhưng now không trước expiryTime | Hợp lệ (coi như không có) | now = E | BR-10 |
| EC-255 | lần giữ ghế của người giữ | không có | Hợp lệ (false) | khách 9 | UC-005 |
| EC-256 | GetHold với by | không phải người giữ | Không hợp lệ | khách 8 | Q-147 |
| EC-257 | GetHold với trạng thái | COMPLETED | Hợp lệ (kèm bookingCode) | H1 COMPLETED | P12 F3 |

#### F2.49.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-90 | now so với expiryTime (EC qh_active) | now = E - 1ms | qh_active | trả (HoldResult, true) |
| BV-91 | now so với expiryTime (EC qh_late) | now = E | qh_late | trả (HoldResult{}, false) |

#### F2.49.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (ReadOnlyTx), IF-17, IF-18, IF-20, IF-11 | fake | FindActiveByHolder, FindIDByRef, FindByID, FindByHold, FindByHold của IF-20, FindByTicket, FindByID suất chiếu; guard chỉ đọc, test khẳng định không có Acquire nào | Store thay bằng bộ nhớ |
| IF-25.Now | stub | now cố định | Thời gian phải tiêm vào |

### F2.50 DC-Movie, DC-Auditorium, DC-Showtime, DC-Cinema: quy tắc lịch chiếu và danh mục

#### F2.50.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Movie.CheckReleasedInFormat(f), CheckWithinRunPeriod(start), RunStatusAt(today); Auditorium.CheckSupportsFormat(f), CheckRoomGap(draft, others, excludeId), CheckNeverScheduled(everScheduled); Showtime.CheckNotStarted(now), CheckRoomChangeAllowed(targetId, everHadTicket); Cinema.NormalizeName(s), CheckNameNotTaken(sameName), CheckUnchangedSinceDisplayed(displayedAt) (cùng dạng ở Movie, Auditorium) | P12 PKG-16-PKG-27 F2 |
| BR | BR-47 (định dạng phát hành), BR-48 (phòng chiếu được định dạng), BR-49 (khoảng chiếu, múi giờ Asia/Ho_Chi_Minh, hai đầu gồm), BR-51 (cách 15 phút, đúng 15 phút hợp lệ), BR-56, BR-57 (giờ bắt đầu phải sau now; bằng now là đã qua), BR-76 (đang chiếu, sắp chiếu), BR-92 (không đổi phòng suất từng có vé, kể cả vé đã huỷ), BR-141 (tên cụm rạp duy nhất), BR-147 (xoá phòng chưa từng có suất chiếu, kể cả đã xoá), BR-60, BR-138, BR-142, BR-146 (mốc lúc hiển thị) | P06; P04 UC-010 đến UC-014 |
| Ghi chú | EXCLUDE chống hai suất chiếu giao nhau trong cùng phòng (kể cả khoảng cách 15 phút) và các chỉ mục unique theo biểu thức đã chạy ở P13-schema-tests.sql nên không lặp ở unit test; X-07, X-28 là ca tích hợp ở F2.55 | P13 |
| Ngoại lệ | FormatNotReleasedError, OutsideRunPeriodError, FormatNotSupportedError, RoomGapError, AuditoriumHasScheduleError, ShowtimeStartedError, RoomChangeNotAllowedError, CinemaNameTakenError, CinemaChangedError, MovieChangedError, AuditoriumChangedError | P12 F2 |

#### F2.50.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-258 | ngày chiếu của suất | trong [releaseDate, endOfRunDate] | Hợp lệ | 2026-11-10 | BR-49 |
| EC-259 | ngày chiếu của suất | trước releaseDate hoặc sau endOfRunDate | Không hợp lệ | 2026-11-09, 2026-11-21 | BR-49 |
| EC-260 | định dạng | thuộc releaseFormats | Hợp lệ | 2D | BR-47 |
| EC-261 | định dạng | không thuộc releaseFormats | Không hợp lệ | IMAX | BR-47 |
| EC-262 | khoảng cách tới suất khác trong phòng | từ 15 phút | Hợp lệ | 15 phút | BR-51 |
| EC-263 | khoảng cách | dưới 15 phút hoặc giao nhau | Không hợp lệ | 14 phút | BR-51 |
| EC-264 | giờ bắt đầu so với now | sau now | Hợp lệ | now + 1 phút | BR-56 |
| EC-265 | giờ bắt đầu so với now | bằng hoặc trước now | Không hợp lệ | now | BR-56 |
| EC-266 | đổi phòng | cùng phòng, hoặc khác phòng và chưa từng có vé | Hợp lệ | khác phòng, everHadTicket = false | BR-92 |
| EC-267 | đổi phòng | khác phòng và từng có vé (kể cả đã huỷ) | Không hợp lệ | khác phòng, everHadTicket = true | BR-92 |
| EC-268 | phòng chiếu | chưa từng có suất chiếu | Hợp lệ | everScheduled = false | BR-147 |
| EC-269 | phòng chiếu | từng có suất chiếu (kể cả đã xoá) | Không hợp lệ | true | BR-147 |
| EC-270 | tên cụm rạp | không trùng cụm rạp khác sau chuẩn hoá | Hợp lệ | sameName = nil | BR-141 |
| EC-271 | tên cụm rạp | trùng chính cụm rạp đang sửa | Hợp lệ | sameName = chính nó | BR-141 |
| EC-272 | tên cụm rạp | trùng cụm rạp khác | Không hợp lệ | sameName.id khác | BR-141 |
| EC-273 | mốc lúc hiển thị | bằng lastChangedAt | Hợp lệ | T0 | BR-138, BR-142, BR-146 |
| EC-274 | mốc lúc hiển thị | lastChangedAt sau mốc | Không hợp lệ | T0 + 1 micro giây | BR-138, BR-142, BR-146 |

#### F2.50.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-92 | ngày đầu khoảng chiếu (EC sc_run_in) | start = releaseDate 00:00 (+07:00) | sc_run_in | hợp lệ |
| BV-93 | trước ngày đầu | releaseDate - 1 ngày 23:59:59.999 | sc_run_out | OutsideRunPeriodError |
| BV-94 | ngày cuối | endOfRunDate 23:59:59.999 | sc_run_in | hợp lệ (hai đầu gồm) |
| BV-95 | sau ngày cuối | endOfRunDate + 1 ngày 00:00 | sc_run_out | OutsideRunPeriodError |
| BV-96 | khoảng cách (EC sc_gap_ok) | đúng 15 phút | sc_gap_ok | hợp lệ |
| BV-97 | khoảng cách | 14 phút 59 giây | sc_gap_bad | RoomGapError |
| BV-98 | giờ bắt đầu so với now | bằng now | sc_start_bad | ShowtimeStartedError |
| BV-99 | giờ bắt đầu so với now | now + 1ms | sc_start_ok | hợp lệ |

#### F2.50.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có | - | Đối tượng thuần: Movie, Auditorium, Showtime, Cinema dựng bằng hàm dựng hoặc RestoreFrom; thời gian truyền qua tham số | Entity không biết SQL và đồng hồ |

### F2.51 DC-ReportPeriod.CheckValid, ToRange; DC-ReportGroup.AddFigures, OccupancyPercent; DC-ViewCinemaReportService.ViewCinemaReport

#### F2.51.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | CheckValid() error; ToRange(zone) (start, end); AddFigures(f); OccupancyPercent() (float64, bool); ViewCinemaReport(ctx, cinemaId, req) (CinemaReport, error) | P12 PKG-17-PKG-18-PKG-30-PKG-33 F2 |
| Hậu điều kiện | CheckValid trả lý do đầu tiên theo thứ tự MISSING_FROM, MISSING_TO, FROM_AFTER_TO (từ ngày bằng đến ngày là hợp lệ). ToRange trả khoảng nửa mở [từ ngày 00:00, đến ngày + 1 ngày 00:00) theo múi giờ. OccupancyPercent = soldSeats nhân 100 chia capacity; capacity = 0 thì (0, false). ViewCinemaReport kiểm kỳ trước khi mở giao dịch; không có suất chiếu trong kỳ thì báo cáo rỗng | P12 F2, F3; GL-66; BR-88 |
| Ngoại lệ | InvalidPeriodError, SystemBusyError | P12 F2 |
| Luồng P04 | UC-015, UC-016 luồng 1a (kỳ sai), 2a (rỗng) | P04 UC-015, UC-016 |

#### F2.51.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-275 | kỳ | có từ ngày, có đến ngày, từ ngày không sau đến ngày | Hợp lệ | 2026-11-01 đến 2026-11-30 | GL-66 |
| EC-276 | kỳ | thiếu từ ngày | Không hợp lệ | rỗng | UC-015 1a |
| EC-277 | kỳ | có từ ngày, thiếu đến ngày | Không hợp lệ | rỗng | UC-015 1a |
| EC-278 | kỳ | từ ngày sau đến ngày | Không hợp lệ | 11-30 đến 11-01 | UC-015 1a |
| EC-279 | sức chứa của nhóm | bằng 0 | Hợp lệ (không áp dụng) | 0 | BR-88 |
| EC-280 | sức chứa của nhóm | lớn hơn 0 | Hợp lệ | 200 | BR-88 |

#### F2.51.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-100 | từ ngày so với đến ngày (EC rp_ok) | từ ngày = đến ngày | rp_ok | hợp lệ |
| BV-101 | từ ngày so với đến ngày | từ ngày = đến ngày + 1 | rp_inv | InvalidPeriodError(FROM_AFTER_TO) |
| BV-102 | sức chứa | 1 | rg_cap | tỉ lệ = soldSeats nhân 100 |

#### F2.51.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-08 (ReportTx), IF-28 | fake | FindCinemaFigures trả dòng số liệu đã gộp theo điều kiện đầu; Do(ReportTx) cấm Acquire; ghi lại q (start, end) | Store thay bằng bộ nhớ |
| múi giờ | stub | zone = Asia/Ho_Chi_Minh | Thời gian phải tiêm vào |

### F2.52 DC-BrowseShowtimesService.selectShowtimes (qua FindShowtimesByMovie, FindShowtimesByCinema)

#### F2.52.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | selectShowtimes(infos []ShowtimeInfo, criteria BrowseCriteria, now time.Time) []ShowtimeInfo | P12 PKG-17 F2 |
| Hậu điều kiện | Giữ suất chiếu theo thứ tự đầu vào: status IN_SCHEDULE, StartTime sau now (BR-56), rồi tiêu chí: province bằng, ngày chiếu (đổi theo múi giờ) bằng date, auditoriumType bằng, format bằng; trường tiêu chí rỗng thì bỏ qua | P12 F3 |
| Luồng P04 | UC-004 luồng 4a (không có suất chiếu), 1a4a | P04 UC-004 |

#### F2.52.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-281 | suất chiếu | IN_SCHEDULE, bắt đầu sau now, khớp mọi tiêu chí | Hợp lệ (giữ) | S1 | BR-56 |
| EC-282 | suất chiếu | bắt đầu bằng hoặc trước now | Không hợp lệ (loại) | bắt đầu = now | BR-56 |
| EC-283 | suất chiếu | status khác IN_SCHEDULE | Không hợp lệ (loại) | đã xoá | BR-58 |
| EC-284 | tiêu chí | mọi trường rỗng | Hợp lệ (không lọc) | zero value | P12 F3 |
| EC-285 | ngày chiếu | khác date theo múi giờ | Không hợp lệ (loại) | 23:30 UTC ngày 10 = 06:30 ngày 11 | P12 F3 |

#### F2.52.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-103 | StartTime so với now | bằng now | sh_past | loại |
| BV-104 | StartTime so với now | now + 1ms | sh_in | giữ |
| BV-105 | ngày chiếu theo múi giờ | 2026-11-10 17:00:00Z (đúng 00:00 ngày 11 +07:00) | sh_date | thuộc ngày 11 |

#### F2.52.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| múi giờ | stub | zone = Asia/Ho_Chi_Minh | Thời gian phải tiêm vào |
| IF-08, IF-11 | fake | Do(UserTx) chạy fn; ListInfoByMovie trả danh sách | Store thay bằng bộ nhớ |

### F2.53 DC-HttpErrorMapper.Classify, DC-AuthFilter.Require

#### F2.53.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Classify(err error, scope ErrorScope) (int, ApiErrorBody); Require(allowed []Role, next CallerHandler) http.Handler | P12 PKG-11 F2, F2b |
| Hậu điều kiện | Classify tra errors.As từ lỗi cụ thể tới chung theo bảng F2b, ra mã HTTP, code, messageId; SeatUnavailable, SeatSelection, HoldNotActive đưa lý do vào detail; lỗi không phân loại và lỗi lập trình (LockOrderViolationError, PaymentStateError, LinkMismatchError) là 500 INTERNAL; hết hạn ngữ cảnh là 503 SYSTEM_BUSY; hàm thuần. Require: deadline 14 giây, kiểm phiên (IF-07.VerifySession và với nhân viên bốn vai trò DC-AccessCheckService, lấy vai trò hiện hành), rồi CheckRole với vai trò hiện hành; next chỉ chạy khi phiên và vai trò hợp lệ | P12 F2, F2b, F3 |
| Ngoại lệ | SESSION_INVALID, FORBIDDEN_ROLE, SYSTEM_BUSY; allowed rỗng là lỗi lập trình lúc đăng ký (tiền điều kiện, không có TC) | P12 F2; Q-144 |
| Luồng P04 | UC-005 5a (phiên), UC-017 BR-101 (thu hồi phiên) | P04 |

#### F2.53.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-286 | lỗi phiên | StaffAccessRevokedError, StaffAccessChangedError, LoginFailedError | Hợp lệ (401) | StaffAccessRevokedError | BR-101 |
| EC-287 | lỗi quyền | ChannelMismatchError, BookingNotOwnedError, StaffLockedError | Hợp lệ (403) | StaffLockedError | BR-97 |
| EC-288 | lỗi không có dòng | NotFoundError | Hợp lệ (404) | NotFoundError | Q-147 |
| EC-289 | lỗi trạng thái | HolderBusy, SeatUnavailable, HoldNotActive, StaleStaff, DuplicateAccount | Hợp lệ (409) | HolderBusyError | BR-04 |
| EC-290 | lỗi dữ liệu nhập | SeatSelection, RegistrationData, StaffData | Hợp lệ (422) | SeatSelectionError(TOO_MANY) | BR-05 |
| EC-291 | lỗi tạm thời | SystemBusyError, context deadline | Hợp lệ (503) | SystemBusyError | NFR-06 |
| EC-292 | lỗi lập trình hoặc không phân loại | LockOrderViolationError, PaymentStateError, LinkMismatchError, lỗi lạ | Hợp lệ (500) | errors.New("x") | P12 F2b |
| EC-293 | cùng lỗi, hai scope | ShowtimeChangedError với BOOKING và SCHEDULE | Hợp lệ (hai messageId) | MSG-12 và MSG-68 | P12 F2b |
| EC-294 | lỗi bọc | fmt.Errorf("%w") quanh lỗi nghiệp vụ | Hợp lệ (vẫn phân loại) | HolderBusyError bọc | P12 F3 |

#### F2.53.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| Không có (Classify) | - | Hàm thuần | Không phụ thuộc ngoài |
| IF-07, DC-AccessCheckService | stub | VerifySession trả claims hoặc SessionInvalidError, SessionExpiredError; CheckStaffAccess trả StaffAccess hoặc StaffAccessRevokedError; CheckRole thật | Kiểm vai trò hiện hành |
| CallerHandler (next) | mock | Đếm số lần gọi và nhận caller | Kiểm next chỉ chạy khi hợp lệ |

### F2.54 IF-07.HashPassword, CheckRole, và claims mang loại chủ thể, accessChangedAt (bổ sung F2.39)

#### F2.54.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | HashPassword(plainPassword) (string, error); CheckRole(role, allowedRoles) bool; IssueSession(subjectId, subjectKind, role, cinemaId, accessChangedAt *time.Time); VerifySession(token) (SessionClaims, error) | P12 F2 PKG-26 |
| Hậu điều kiện | HashPassword một chiều, mỗi lần gọi cho mã băm khác nhau, VerifyPassword xác nhận được. CheckRole đúng khi role thuộc allowedRoles. Mã phiên mã hoá subjectKind và accessChangedAt ở độ chính xác micro giây; VerifySession trả lại đúng các giá trị đó | P12 F2 |
| Giới hạn | Hiện thực bên trong SS-05 chưa có; TC kiểm theo hợp đồng interface bằng driver | P12 mục 0.1 |

#### F2.54.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-295 | mật khẩu | chuỗi không rỗng | Hợp lệ | Abc@1234 | NFR-01 |
| EC-296 | role | thuộc allowedRoles | Hợp lệ (true) | CUSTOMER trong [CUSTOMER] | P12 F2 |
| EC-297 | role | không thuộc allowedRoles | Không hợp lệ (false) | CUSTOMER trong [BOX_OFFICE_CLERK] | P12 F2 |
| EC-298 | claims nhân viên | có accessChangedAt | Hợp lệ | A1 | BR-101 |

#### F2.54.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| đồng hồ | stub | now cố định tiêm vào bộ xác thực | Thời gian phải tiêm vào |

### F2.55 Ca tích hợp bổ sung (PostgreSQL 15 thật, nhiều goroutine hoặc nhiều bản backend)

#### F2.55.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Phân loại | Bổ sung cho F2.40 theo P08 2.x, P09 2.x, P12 2.x: cặp loại trừ X-24 đến X-33 và hạng khoá 0, 10 đến 13, hàng rào claim_token, trigger trg_seat_status_link, EXCLUDE suất chiếu, kiểm phiên theo mốc truy cập, DC-HoldSettlement trong giao dịch thật. Mỗi X-nn có ca ép cả hai thứ tự đến; mỗi dòng Bảng hỏng của P09 F7.10 có ca hồi phục (ánh xạ ở F4.4, F4.5) | 00-Concurrency.md M9; P09 F7.10 |
| Tham chiếu P13 | Các ràng buộc cấp dữ liệu (unique theo biểu thức, EXCLUDE khoảng cách 15 phút, trigger liên kết ghế, CHECK) đã chạy đạt trong P13-schema-tests.sql (207 case, PostgreSQL 16); X2 không lặp các case đó, các ca dưới đây kiểm hành vi của lớp ứng dụng khi gặp chúng (không có 23505 lọt ra, kết cục đúng cho từng thứ tự đến) | P13-schema-tests.sql |
| Hạ tầng | Như F2.40.1; thêm 2 tài khoản nhân viên quầy, 1 quản trị viên, 3 cụm rạp | F2.40 |
| Không áp dụng | F2.55.2 đến F2.55.6 (ca tích hợp, không phân tích mức đơn vị) | - |

#### F2.55.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| IF-01 (cổng thanh toán) | fake | Như F2.40.7 | Hệ thống ngoài |
| Hook giữ giao dịch (pg_sleep, giao dịch của harness) | driver | Ép thứ tự đến của hai giao dịch | Tái lập được thứ tự |

### F2.56 DC-PaymentCallbackController.writeIpnAnswer, DC-VnpaySigner.Sign, Verify, DC-VnpayReportDecoder.Decode

#### F2.56.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | writeIpnAnswer(w, a IpnAnswer); Sign(params) string; Verify(params, signature) bool; Decode(params) (PaymentReport, error) | P12 PKG-12, PKG-22 F2 |
| Hậu điều kiện | writeIpnAnswer dịch IpnAnswer sang RspCode của cổng: PROCESSED 00, DUPLICATE 02, INVALID_SIGNATURE 97, AMOUNT_MISMATCH 04, UNKNOWN_TRANSACTION 01, TEMPORARY_FAILURE và MALFORMED 99. Sign sắp tham số theo tên và ký HMAC-SHA512 (thuần). Verify so thời gian hằng. Decode đọc mã giao dịch, mã tham chiếu, số tiền (chia 100 nếu cổng nhân 100), kết quả; thiếu tham số thì MalformedReportError | P12 F2; P09 F7.6; NFR-16 |
| Giới hạn oracle | Tên tham số và chuỗi ký chính xác phụ thuộc V-01 đến V-11 của VNPay chưa kiểm với tài liệu (P11b); TC kiểm thuộc tính (đối xứng Sign và Verify, độc lập thứ tự, nhạy với mọi thay đổi) không dùng vector chuẩn; TC dùng tên tham số VNPay chờ Q-355 | P11b SS-01 |

#### F2.56.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-299 | IpnAnswer | một trong 7 giá trị | Hợp lệ | PROCESSED | P09 F7.6 |
| EC-300 | tham số và chữ ký | chữ ký sinh từ chính tham số | Hợp lệ (true) | params P | NFR-16 |
| EC-301 | tham số và chữ ký | một tham số đổi hoặc chữ ký đổi một ký tự | Không hợp lệ (false) | amount đổi | NFR-16 |
| EC-302 | tham số báo | đủ tham số | Hợp lệ | đủ | P12 F2 |
| EC-303 | tham số báo | thiếu số tiền | Không hợp lệ | thiếu | P12 F2 |

#### F2.56.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| http.ResponseWriter | fake | httptest.ResponseRecorder ghi lại thân JSON và mã HTTP | Không dùng mạng thật |
| GatewayConfig | stub | Khoá HMAC cố định "k-test" | Giá trị cấu hình tiêm vào |

### F2.57 DC-SubscriberQueue.Offer, Close; DC-EmittedEventTracker; DC-SeatEventPoller.pollOnce; DC-IpConnectionLimiter; DC-JobLoop.runOnce

#### F2.57.1 Cơ sở kiểm thử

| Mục (chữ ký / tiền điều kiện / hậu điều kiện / ngoại lệ / BR / luồng thay thế / điều kiện hợp lệ) | Nội dung | Nguồn |
|---|---|---|
| Chữ ký | Offer(item) bool; Close(reason); WasEmitted(id), Record(e, now), AdvanceMark(now); pollOnce; TryAcquire(clientIp) (release, ok); runOnce(ctx) | P12 PKG-24, PKG-25, PKG-11 F2, F3 |
| Hậu điều kiện | Offer đẩy không chặn; hàng đợi 256 phần tử đầy thì Close(SLOW_CONSUMER) và trả false; Close gọi hai lần vô hại. AdvanceMark: mốc W = mã lớn nhất trong các dòng đã phát có created_at cũ hơn 10 giây, xoá mã đã phát cũ hơn 20 giây. pollOnce phát mỗi sự kiện chưa WasEmitted theo mã tăng dần. TryAcquire cho tối đa 10 kết nối mỗi địa chỉ IP; release giảm đúng một lần. runOnce bắt panic và lỗi, ghi log, xoá cờ running | P12 F3; P09 F7.5; NFR-08, NFR-09 |
| Vòng lặp | SubscriberQueue: n = 256, m = 10; IpConnectionLimiter: n = 10 | P12 |

#### F2.57.2 Phân vùng tương đương

| EC | Điều kiện | Lớp tương đương | Hợp lệ / Không hợp lệ | Giá trị đại diện | Nguồn |
|---|---|---|---|---|---|
| EC-304 | hàng đợi | còn chỗ (dưới 256) | Hợp lệ | 10 phần tử | NFR-08 |
| EC-305 | hàng đợi | đã đủ 256 | Không hợp lệ | 256 | NFR-08 |
| EC-306 | mã sự kiện | chưa phát | Hợp lệ | id 501 | P12 F3 |
| EC-307 | mã sự kiện | đã phát | Hợp lệ (bỏ qua) | id 500 | P12 F3 |
| EC-308 | số kết nối của một IP | dưới 10 | Hợp lệ | 9 | P12 F2 |
| EC-309 | số kết nối của một IP | đã 10 | Không hợp lệ | 10 | P12 F2 |
| EC-310 | RunDue | trả nil | Hợp lệ | nil | P12 F2 |
| EC-311 | RunDue | trả lỗi hoặc panic | Không hợp lệ | panic | P12 F2 |

#### F2.57.3 Giá trị biên

| BV | Biên (của EC nào) | Giá trị kiểm thử | Kỳ vọng thuộc lớp | Kết quả mong đợi |
|---|---|---|---|---|
| BV-106 | số phần tử (EC sq_room) | 255 phần tử rồi Offer | sq_room | trả true, hàng đợi 256 |
| BV-107 | số phần tử | 256 phần tử rồi Offer | sq_full | trả false, Close(SLOW_CONSUMER) |
| BV-108 | số kết nối (EC il_ok) | 9 rồi TryAcquire | il_ok | ok = true (kết nối thứ 10) |
| BV-109 | số kết nối | 10 rồi TryAcquire | il_full | ok = false |
| BV-110 | tuổi dòng đã phát | 10 giây và 1 ms (cũ hơn 10 giây); đúng 10 giây không tiến | tiến mốc | W tiến tới mã đó khi cũ hơn 10 giây |
| BV-111 | tuổi mã đã phát | 20 giây và 1 ms | xoá | mã bị xoá khi cũ hơn 20 giây |

#### F2.57.7 Test double

| Phụ thuộc (DC / IF) | Loại (stub / driver / mock / fake) | Hành vi giả lập hoặc điều cần xác minh | Lý do |
|---|---|---|---|
| đồng hồ | stub | now tiêm vào Record, AdvanceMark | Thời gian phải tiêm vào |
| IF-22 (ReadEventsAfter) | fake | Trả danh sách dòng seat_event theo điều kiện đầu | Store thay bằng bộ nhớ |
| IScheduledJob | mock | RunDue(budget) ghi lại số lần gọi, có thể ném panic hoặc lỗi | Kiểm hợp đồng JobLoop |
| log | spy | Đếm số lần ghi log lỗi | Kiểm hiệu ứng phụ |

## F3. Bảng test case

| TC | DC.operation | Kỹ thuật (phân vùng tương đương / giá trị biên / bảng quyết định / chuyển trạng thái / use case / đường đi) | Điều kiện đầu | Dữ liệu vào | Kết quả mong đợi | Nguồn (BR / UC bước) | Phủ (EC, BV, DT-R, chuyển trạng thái, nhánh CE) | Test double | Ưu tiên | Mức |
|---|---|---|---|---|---|---|---|---|---|---|
| TC-001 | DC-SeatHold.NewSeatHold | phân vùng tương đương | Không có | holder = CUSTOMER 7; showtimeId = 55; requestId = r-1; holdRef = ref-1; now = 10:00:00.000 | Status = ACTIVE; ExpiryTime = 10:10:00.000; Holder = CUSTOMER 7; ShowtimeId = 55; Ref = ref-1 | BR-10; UC-005 bước 7; ST-01 STT 1 | EC-01, CT-01 | Không (đối tượng thuần) | Cao | Unit |
| TC-002 | DC-SeatHold.NewSeatHold | phân vùng tương đương | Không có | holder = CLERK 3; now = 10:00:00.000; các tham số khác như TC trước | Status = ACTIVE; ExpiryTime = 10:10:00.000; Holder = CLERK 3 | BR-10 (áp dụng cả bán tại quầy); R-49 | EC-02 | Không (đối tượng thuần) | Cao | Unit |
| TC-003 | DC-SeatHold.NewSeatHold | giá trị biên | Không có | holder = CUSTOMER 7; now = 2026-11-10 23:55:00 | ExpiryTime = 2026-11-11 00:05:00; Status = ACTIVE | BR-10 | BV-01 | Không (đối tượng thuần) | Cao | Unit |
| TC-005 | DC-SeatHold.Expire | giá trị biên | SeatHold ACTIVE, expiryTime = E | Expire(now = E - 1ms) | Trả false; Status = ACTIVE | BR-10; ST-01 STT 3 | EC-04, BV-02, CT-03, đường P2, CE1 đến CE2, CE5, CE7 | Không (đối tượng thuần) | Cao | Unit |
| TC-006 | DC-SeatHold.Expire | giá trị biên | SeatHold ACTIVE, expiryTime = E | Expire(now = E) | Trả true; Status = EXPIRED | BR-10; BR-14; ST-01 STT 3; UC-005 7b | EC-05, BV-03, CT-02, đường P1, CE1 đến CE2, CE4, CE6 | Không (đối tượng thuần) | Cao | Unit |
| TC-007 | DC-SeatHold.Expire | giá trị biên | SeatHold ACTIVE, expiryTime = E | Expire(now = E + 1ms) | Trả true; Status = EXPIRED | BR-10; ST-01 STT 3 | BV-04 | Không (đối tượng thuần) | Cao | Unit |
| TC-008 | DC-SeatHold.Expire | chuyển trạng thái | SeatHold COMPLETED (tạo bằng NewSeatHold, Complete(E - 1ms)) | Expire(now = E + 5 phút) | Trả false; Status = COMPLETED | BR-86; ST-01 (bị bỏ qua) | EC-06, CT-04, đường P3, CE1, CE3, CE7 | Không (đối tượng thuần) | Cao | Unit |
| TC-009 | DC-SeatHold.Expire | chuyển trạng thái | SeatHold EXPIRED (sau Expire(E)) | Expire(now = E + 5 phút) lần hai | Trả false; Status = EXPIRED (chạy lặp an toàn) | BR-86; P12 F2 (chạy lặp an toàn) | EC-06, CT-04 | Không (đối tượng thuần) | Cao | Unit |
| TC-010 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold ACTIVE, expiryTime = E | Complete(now = E - 1ms) | Trả nil; Status = COMPLETED | BR-37, BR-44; ST-01 STT 2; UC-005 12 | EC-07, BV-05, CT-05, đường P4, CE8 đến CE9, CE11, CE13 | Không (đối tượng thuần) | Cao | Unit |
| TC-011 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold ACTIVE, expiryTime = E | Cancel(now = E - 1ms) | Trả nil; Status = CANCELLED | BR-85; ST-01 STT 4; UC-005 *a | CT-06, đường P4, CE8 đến CE9, CE11, CE13 | Không (đối tượng thuần) | Cao | Unit |
| TC-012 | DC-SeatHold.Complete, Cancel, FailPayment | chuyển trạng thái | SeatHold ACTIVE, expiryTime = E | FailPayment(now = E - 1ms) | Trả nil; Status = PAYMENT_FAILED | BR-39, BR-85; ST-01 STT 5; UC-005 11a | CT-07, đường P4, CE8 đến CE9, CE11, CE13 | Không (đối tượng thuần) | Cao | Unit |
| TC-013 | DC-SeatHold.Complete, Cancel, FailPayment | giá trị biên | SeatHold ACTIVE, expiryTime = E (chưa gọi Expire) | Complete(now = E) | Ném HoldNotActiveError mang Status = ACTIVE; Status vẫn ACTIVE (entity không tự hết hạn, Q-142) | P12 F3 và F6.2; BR-86 | EC-08, BV-06, CT-08, đường P5, CE8 đến CE9, CE12, CE14 | Không (đối tượng thuần) | Cao | Unit |
| TC-014 | DC-SeatHold.Complete, Cancel, FailPayment | giá trị biên | SeatHold ACTIVE, expiryTime = E (chưa gọi Expire) | Cancel(now = E) | Ném HoldNotActiveError mang Status = ACTIVE; Status vẫn ACTIVE (Q-142) | P12 F3 và F6.2; BR-86 | CT-09 | Không (đối tượng thuần) | Cao | Unit |
| TC-015 | DC-SeatHold.Complete, Cancel, FailPayment | giá trị biên | SeatHold ACTIVE, expiryTime = E (chưa gọi Expire) | FailPayment(now = E + 1ms) | Ném HoldNotActiveError mang Status = ACTIVE; Status vẫn ACTIVE (Q-142) | P12 F3 và F6.2; BR-86 | BV-07, CT-10 | Không (đối tượng thuần) | Cao | Unit |
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
| TC-028 | DC-SeatHold.CalculateTotal | phân vùng tương đương | Hold H1; ghế a HELD bởi H1 (90.000), ghế b HELD bởi H2 (120.000) | CalculateTotal([a, b]) | Trả 90.000 (ghế b HELD bởi H2 bị bỏ qua, Q-143) | P12 F2 (không nêu) | EC-14 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-029 | DC-SeatHold.CalculateTotal | phân vùng tương đương | Hold H1 | CalculateTotal([]) | Trả 0 (Q-143) | P12 F2 (không nêu) | EC-15 | Không (đối tượng thuần) | Trung bình | Unit |
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
| TC-070 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn code 20260001 | NewFullRefund(txn, 100.000) | IdempotencyKey = "20260001-FULL"; Status = NEW; AttemptCount = 0; Amount = 100.000 | BR-43; BR-14; ST-04 STT 3 | EC-30, CT-41 | Không (đối tượng thuần) | Cao | Unit |
| TC-071 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn code 20260001; vé 9 | NewTicketRefund(txn, vé 9, 63.000) | IdempotencyKey = "20260001-T9"; Status = NEW; AttemptCount = 0; Amount = 63.000 | BR-43; BR-19; ST-04 STT 3 | EC-31 | Không (đối tượng thuần) | Cao | Unit |
| TC-072 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | txn code 20260001; vé 9 và vé 10 | NewTicketRefund(txn, vé 10, 63.000) so với kết quả TC trước | IdempotencyKey = "20260001-T10", khác "20260001-T9" và khác "20260001-FULL" | BR-43 (phân biệt khoá trên cùng giao dịch); X-17 | EC-31 | Không (đối tượng thuần) | Cao | Unit |
| TC-073 | DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | phân vùng tương đương | vé 9 mua tại quầy | NewCashRefund(vé 9, 63.000) | Status = REFUNDED; AttemptCount = 0; Amount = 63.000 | BR-20; ST-04 STT 2; UC-008 5a2 | EC-32, CT-42 | Không (đối tượng thuần) | Cao | Unit |
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
| TC-159 | DC-Showtime.CheckSeatSelection | phân vùng tương đương | Showtime của phòng chiếu 7 | CheckSeatSelection(9 ghế của phòng 7 trong đó hai phần tử trùng) | Ném SeatSelectionError(TOO_MANY) (thứ tự EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM, Q-152) | P12 F2 (không nêu thứ tự) | - | Không (đối tượng thuần) | Trung bình | Unit |
| TC-160 | DC-Showtime.CheckUnchangedSince | phân vùng tương đương | Showtime IN_SCHEDULE, lastChangedAt 2026-11-08 09:00:00.000 | CheckUnchangedSince(2026-11-08 09:00:00.000) | Trả nil | BR-54 | EC-80 | Không (đối tượng thuần) | Cao | Unit |
| TC-161 | DC-Showtime.CheckUnchangedSince | giá trị biên | Showtime IN_SCHEDULE, lastChangedAt 2026-11-08 09:00:00.001 | CheckUnchangedSince(2026-11-08 09:00:00.000) | Ném ShowtimeChangedError | BR-54; UC-005 7d; X-03 | EC-81, BV-39 | Không (đối tượng thuần) | Cao | Unit |
| TC-162 | DC-Showtime.CheckUnchangedSince | phân vùng tương đương | Showtime Đã xoá, lastChangedAt 2026-11-08 09:00:00.000 | CheckUnchangedSince(2026-11-08 09:00:00.000) | Ném ShowtimeChangedError | BR-54; UC-005 7d | EC-82 | Không (đối tượng thuần) | Cao | Unit |
| TC-164 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Tư 2026-11-11 16:59:59.999 +07:00) | Trả Money 70.000 | BR-11, BR-12 | EC-84, BV-40 | Không (đối tượng thuần) | Cao | Unit |
| TC-165 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Tư 2026-11-11 17:00:00.000 +07:00) | Trả Money 90.000 | BR-11, BR-12 | EC-85, BV-41 | Không (đối tượng thuần) | Cao | Unit |
| TC-166 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Sáu 2026-11-13 23:59:59.999 +07:00) | Trả Money 90.000 | BR-11, BR-12 | EC-85, BV-42 | Không (đối tượng thuần) | Cao | Unit |
| TC-167 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Bảy 2026-11-14 00:00:00.000 +07:00) | Trả Money 85.000 | BR-11, BR-12 | EC-86, BV-43 | Không (đối tượng thuần) | Cao | Unit |
| TC-168 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Bảy 2026-11-14 16:59:59.999 +07:00) | Trả Money 85.000 | BR-11, BR-12 | EC-86, BV-44 | Không (đối tượng thuần) | Cao | Unit |
| TC-169 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Bảy 2026-11-14 17:00:00.000 +07:00) | Trả Money 110.000 | BR-11, BR-12 | EC-87, BV-45 | Không (đối tượng thuần) | Cao | Unit |
| TC-170 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Chủ nhật 2026-11-15 23:59:59.999 +07:00) | Trả Money 110.000 | BR-11, BR-12 | EC-87, BV-46 | Không (đối tượng thuần) | Cao | Unit |
| TC-171 | DC-PriceList.DetermineSeatPrice | giá trị biên | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = Thứ Hai 2026-11-16 00:00:00.000 +07:00) | Trả Money 70.000 | BR-11, BR-12 | EC-84, BV-47 | Không (đối tượng thuần) | Cao | Unit |
| TC-172 | DC-PriceList.DetermineSeatPrice | phân vùng tương đương | PriceList như trên | DetermineSeatPrice(IMAX, 3D, VIP, startTime = Thứ Tư 20:00 +07:00) | Ném NotFoundError | BR-72; UC-005 7e | EC-88 | Không (đối tượng thuần) | Cao | Unit |
| TC-173 | DC-PriceList.DetermineSeatPrice | phân vùng tương đương | PriceList như trên | DetermineSeatPrice(STANDARD, 2D, STANDARD, startTime = 2026-11-13 10:00:00Z, tức Thứ Sáu 17:00 +07:00) | Trả Money 90.000 (đổi sang UTC+7: Thứ Sáu 17:00, ngày thường từ 17:00, Q-151) | BR-12 (múi giờ chưa nêu) | EC-89 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-174 | DC-BookTicketsService.HoldSeats | use case | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Trả HoldResult: replayed = false, tổng = 270.000; SeatHold ACTIVE expiry 10:10:00.000, holdRef ref-1; ghế 101, 102, 103 HELD bởi hold mới, heldPrice 90.000; Insert 1 lần; SaveChanges 1 lần với 3 ghế; Do 1 lần với deadline = lúc nhận + 1,8 giây, pool USER; Violated() = false | BR-07, BR-10, BR-65; UC-005 7, 8 (KB1); NFR-06 | EC-102, EC-106, EC-108, EC-90, EC-94, EC-96, EC-98, DT4-R1 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-175 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 1 ghế [101] | Giữ được: tổng 90.000; 1 ghế HELD | BR-05 (tối thiểu); UC-005 7 | BV-49 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-176 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101 đến 107 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 7 ghế [101..107] | Giữ được: tổng 630.000; 7 ghế HELD; SaveChanges 1 lần | BR-05 (n - 1) | BV-50 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-177 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101 đến 108 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 8 ghế [101..108] | Giữ được: tổng 720.000; 8 ghế HELD; SaveChanges 1 lần | BR-05 (tối đa); UC-005 6 | BV-51 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-178 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với seatIds = [] | Ném SeatSelectionError(EMPTY) sau khi qua kiểm BR-04; FindRouting 1 lần; Do 1 lần; không ghi gì (lỗi số ghế chỉ ném sau BR-04, Q-145) | BR-05 | EC-91, BV-48, DT4-R3 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-179 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với 9 ghế [101..109] | Ném SeatSelectionError(TOO_MANY) sau khi qua kiểm BR-04; FindRouting 1 lần; Do 1 lần; không ghi gì (Q-145) | BR-05; UC-005 6a | EC-92, BV-52 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-180 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với showtimeId 9999 (FindRouting ném NotFoundError) | Ném NotFoundError; Do 0 lần | P12 F2 (NotFoundError) | EC-111 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-181 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockUnfinishedOrByRequest ném SystemBusyError (hết lock_timeout) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SystemBusyError; không có lần giữ ghế, không ghế đổi; rollback | P09 F7.3; P12 F2 | - | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-182 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; phòng của suất chiếu đã khoá là 8 (FindRouting trả 7) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeChangedError; không ghi gì; không gọi LockForHold | BR-54; P12 F3 (c); UC-005 7d | EC-110 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-183 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; đã có lần giữ ghế H0 ACTIVE của khách 7 với requestId r-1, expiry 10:10:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) với tx.Now = 10:09:59.999 | Trả lại H0: replayed = true; Insert 0 lần; ghế không đổi; không tạo lần giữ ghế thứ hai | P09 F7.3 EX-01 (xác nhận lặp an toàn khi phản hồi mất); Bảng hỏng M5 mục 4 | EC-100, BV-53 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-184 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; lần giữ ghế H0 của khách 7 với requestId r-1 ở trạng thái CANCELLED | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HoldNotActiveError mang Status = CANCELLED; Insert 0 lần; ghế không đổi | P12 F3 (d); BR-86 | EC-101 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-185 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 của khách 7 với requestId r-1, ACTIVE, expiry 10:10:00.000; tx.Now = 10:10:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HoldNotActiveError mang Status = ACTIVE (H0 quá hạn nhưng chưa được ghi EXPIRED, Q-142); Insert 0 lần; H0 vẫn ACTIVE | P12 F3 (d); Q-142; BR-86 | - | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-186 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; lần giữ ghế H0 ACTIVE của khách 7 (requestId r-0, expiry 10:10:00.000); tx.Now = 10:09:59.999 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HolderBusyError; không có lần giữ ghế mới; ghế 101..103 vẫn AVAILABLE; H0 vẫn ACTIVE | BR-04; X-02; UC-005 5b, 7c (KB6) | EC-99, BV-55, DT4-R4 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-187 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 ACTIVE của khách 7 (requestId r-0, expiry 10:10:00.000); tx.Now = 10:10:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Giữ thành công (H0 coi là đã kết thúc tại thời điểm hết hạn): H0 EXPIRED, UpdateStatus H0 1 lần; lần giữ ghế mới ACTIVE; 3 ghế HELD bởi hold mới | BR-04, BR-10; UC-005 mục 8 (mốc hết hạn); P12 F3 (e) | BV-54 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-188 | DC-BookTicketsService.HoldSeats | use case | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 của khách 7 ACTIVE hết hạn 10:10:00.000, đang giữ ghế 101 và 109 (HELD bởi H0); tx.Now = 10:10:00.000 | HoldSeats(ghế [101, 102, 103]) | Giữ thành công: H0 EXPIRED; ghế 101 HELD bởi hold mới (HoldSettlement.End trả Trống, rồi HoldFor); ghế 109 vẫn HELD bởi H0 (SeatReleaseJob trả sau); SaveChanges 2 lần (Trống rồi giữ lại, tránh trg_seat_status_link); Violated() = false | Q-134; P12 F3 (g); BR-04 | - | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-189 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-09 07:59:59.999 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeNotOpenError; không ghi gì | BR-01; UC-005 2a | EC-95, DT4-R2 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-190 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-10 20:00:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeNotOpenError; không ghi gì | BR-45; UC-005 2c (KB7) | DT4-R2 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-191 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-09 12:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeChangedError; không ghế bị khoá; không ghi gì | BR-54; UC-005 7d (KB9) | EC-97, DT4-R5 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-192 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000 | HoldSeats với seatIds [101, 900], ghế 900 thuộc phòng 8 | Ném SeatSelectionError(NOT_IN_AUDITORIUM); không ghi gì | P12 F3 (f); F1b | EC-93 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-193 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockForHold ném SeatUnavailableError(LOCKED_BY_OTHER) (55P03); FindBeingReleased = false | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(LOCKED_BY_OTHER); Do 1 lần (không thử lại); không có lần giữ ghế mới | BR-09; P09 F7.3 EX-01; X-01 | EC-104 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-194 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockForHold ném 55P03; FindBeingReleased = true (ghế đang được trả) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(BEING_RELEASED) (MSG-82); Do 1 lần | P12 F3 (g); X-13 | - | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-195 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; LockForHold trả 2 dòng cho 3 ghế | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError; không ghi gì | P12 F3 (g); BR-07 | EC-105 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-196 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; ghế 102 HELD bởi hold H9 của người khác | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(NOT_AVAILABLE); không có lần giữ ghế mới; ghế 101, 103 vẫn AVAILABLE (cả nhóm hoặc không ghế nào) | BR-07, BR-08; UC-005 7a (KB3) | EC-103, DT4-R6 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-197 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; ghế 102 SOLD | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(NOT_AVAILABLE); ghế 101, 103 vẫn AVAILABLE | BR-09; UC-005 7a | EC-103, DT4-R6 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-198 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; bảng giá không có mục cho ghế 103 (VIP) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném NotFoundError; không có lần giữ ghế; không ghế đổi | BR-72; UC-005 7e (KB10) | EC-107, DT4-R7 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-199 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; fake IF-08.Do trả SystemBusyError sau hết lần thử | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SystemBusyError; không ghi gì; TxOptions.deadline = lúc nhận + 1,8 giây | NFR-06; P09 F7.3 | EC-109 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-200 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; khách 7 có H0 ACTIVE (7c) và suất chiếu đã đổi (7d) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HolderBusyError (7c trước 7d) | UC-005 mục 8 (7c kiểm trước 7d); BR-04 | DT4-R4 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-201 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; suất chiếu đã đổi (7d) và ghế 102 HELD bởi người khác (7a) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeChangedError (7d trước 7a) | UC-005 mục 8 (7d trước 7a); BR-54 | DT4-R5 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-202 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; ghế 102 HELD bởi người khác (7a) và thiếu giá ghế 103 (7e) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném SeatUnavailableError(NOT_AVAILABLE) (7e kiểm sau 7a) | UC-005 mục 8 (7e sau 7a); BR-72 | DT4-R6 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-203 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; khách 7 có H0 ACTIVE (7c) và ghế 102 HELD bởi người khác (7a) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném HolderBusyError (7c trước 7a) | UC-005 7c (kiểm trước 7a) | DT4-R4 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-204 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-10 20:00:00.000 (đã bắt đầu) và khách 7 có H0 ACTIVE | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Ném ShowtimeNotOpenError (2a, 2c kiểm trước 7c, Q-145); H0 vẫn ACTIVE; không ghi gì | UC-005 2c và 7c (không nêu thứ tự trong cùng yêu cầu) | DT4-R8 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-205 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; khách 7 có H0 ACTIVE | HoldSeats với 9 ghế | Ném HolderBusyError (7c trước 6a, Q-145); không ghi gì | UC-005 6a và 7c | DT4-R9 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-206 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; tx.Now = 2026-11-10 20:00:00.000 | HoldSeats với 9 ghế | Ném ShowtimeNotOpenError (2c trước 6a, Q-145); không ghi gì | UC-005 2c và 6a | DT4-R10 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-207 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 COMPLETED; txn TICKETED | decide(báo thành công, now = 10:12:00) | Trả DUPLICATE | BR-37; UC-006 2a | DT5-R1, đường P68, CE177, CE179 đến CE180, CE187 | Không (đối tượng thuần) | Cao | Unit |
| TC-208 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 EXPIRED; txn LATE_PAYMENT | decide(báo thành công, now = 10:30:00) | Trả DUPLICATE (đã xử lý bất kể trạng thái lần giữ ghế) | BR-37; UC-006 2a | DT5-R1 | Không (đối tượng thuần) | Cao | Unit |
| TC-209 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn PENDING | decide(báo thành công, now = 10:09:59.999) | Trả SELL | BR-37; UC-005 11, 12 | DT5-R2, đường P69, CE177, CE179, CE181 đến CE182, CE184, CE188 | Không (đối tượng thuần) | Cao | Unit |
| TC-210 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn PENDING | decide(báo thành công, now = 10:10:00.000) | Trả LATE (IsActiveAt sai đúng tại thời điểm hết hạn) | BR-14; UC-006 (trễ) | DT5-R3, đường P70, CE177, CE179, CE181 đến CE182, CE185, CE189 | Không (đối tượng thuần) | Cao | Unit |
| TC-211 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 CANCELLED (Cancel 10:03); txn PENDING | decide(báo thành công, now = 10:05:00) | Trả LATE (huỷ giữ ghế trước hạn vẫn là thanh toán trễ) | BR-15; UC-005 *a | DT5-R3 | Không (đối tượng thuần) | Cao | Unit |
| TC-212 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn FAILED (RecordFailure) | decide(báo thành công, now = 10:05:00) | Trả LATE | BR-15; ST-05 STT 5 | DT5-R4, đường P71, CE177, CE179, CE181, CE183, CE189 | Không (đối tượng thuần) | Cao | Unit |
| TC-213 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 PAYMENT_FAILED; txn FAILED | decide(báo thành công, now = 10:20:00) | Trả LATE | BR-15; BR-86 | DT5-R5 | Không (đối tượng thuần) | Cao | Unit |
| TC-214 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 ACTIVE; txn PENDING | decide(báo thất bại, now = 10:05:00) | Trả FAILURE | BR-39; UC-005 11a | DT5-R6, đường P67, CE177 đến CE178, CE186 | Không (đối tượng thuần) | Cao | Unit |
| TC-215 | DC-PaymentReportService.decide | bảng quyết định | SeatHold H1 expiry E = 10:10:00.000 COMPLETED; txn TICKETED | decide(báo thất bại, now = 10:20:00) | Trả FAILURE (HandleIpn ghi nhận, không hoàn tiền) | BR-39; UC-006 2d | DT5-R6 | Không (đối tượng thuần) | Cao | Unit |
| TC-216 | DC-BookTicketsService.CancelHold | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:05:00.000 | CancelHold(H1, by khách 7) | Trả nil; H1 CANCELLED; ghế 101..103 AVAILABLE; UpdateStatus 1 lần; SaveChanges 1 lần (3 ghế); 1 commit; Violated() = false (hạng 5 rồi 6) | BR-85; UC-005 *a; Q-134 (KB: huỷ giữ ghế) | EC-112 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-217 | DC-BookTicketsService.CancelHold | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:09:59.999 | CancelHold(H1, by khách 7) | Trả nil; H1 CANCELLED; ghế AVAILABLE | BR-10; BR-85 | BV-56 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-218 | DC-BookTicketsService.CancelHold | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:10:00.000 | CancelHold(H1, by khách 7) | Ném HoldNotActiveError mang Status = EXPIRED; H1 EXPIRED (đã ghi); ghế 101..103 AVAILABLE; cùng một commit (fn trả nil) | BR-86; UC-005 7b; Q-134; X-10 | EC-113, BV-57 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-219 | DC-BookTicketsService.CancelHold | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD bởi H1; tx.Now = 10:05:00.000 | CancelHold(H1, by khách 8) | Ném NotFoundError; H1 vẫn ACTIVE; ghế vẫn HELD bởi H1; không ghi gì | P12 F3 (không lộ sự tồn tại) | EC-115 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-220 | DC-BookTicketsService.CancelHold | phân vùng tương đương | Không có lần giữ ghế mã 9999 | CancelHold(9999, by khách 7) | Ném NotFoundError; không ghi gì | P12 F2 | EC-116 | fake IF-08/17/18, stub IF-25 | Trung bình | Unit |
| TC-221 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 COMPLETED (đã bán); ghế 101..103 SOLD | CancelHold(H1, by khách 7) lúc 10:05:00 | Ném HoldNotActiveError mang Status = COMPLETED; ghế vẫn SOLD; UpdateStatus 0 lần; SaveChanges 0 lần | BR-86; X-12; UC-005 *a (huỷ đến sau khi bán) | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-222 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 CANCELLED (đã huỷ một lần, ghế đã trả) | CancelHold(H1, by khách 7) lần hai | Ném HoldNotActiveError mang Status = CANCELLED; không ghi gì | BR-86 (người dùng bấm huỷ hai lần) | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-223 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 EXPIRED; ghế 101 đã được giữ lại bởi H2 (HELD bởi H2), ghế 102, 103 AVAILABLE | CancelHold(H1, by khách 7) | Ném HoldNotActiveError mang Status = EXPIRED; ghế 101 vẫn HELD bởi H2; không ghi gì | R-63; X-13; X-18 | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-224 | DC-BookTicketsService.CancelHold | chuyển trạng thái | H1 PAYMENT_FAILED | CancelHold(H1, by khách 7) | Ném HoldNotActiveError mang Status = PAYMENT_FAILED; không ghi gì | BR-86; UC-005 11a | EC-114 | fake IF-08/17/18, stub IF-25 | Cao | Unit |
| TC-225 | DC-BookTicketsService.ConfirmCashReceived | use case | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:05:00.000 | ConfirmCashReceived(H1, clerk 3) | Trả BookingView mã BK1 với 2 vé: ghế 101 giá 90.000 mã TKA, ghế 105 giá 120.000 mã TKB; H1 COMPLETED; hai ghế SOLD với currentTicket; InsertWithTickets 1 lần; IF-23.Enqueue 0 lần; Violated() = false | BR-44, BR-67, BR-80; UC-005 9a2 đến 9a4 (KB2); UC-005 9a | EC-117 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-226 | DC-BookTicketsService.ConfirmCashReceived | giá trị biên | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:09:59.999 | ConfirmCashReceived(H1, clerk 3) | Bán thành công; H1 COMPLETED | BR-44; UC-005 9a2 | BV-58 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-227 | DC-BookTicketsService.ConfirmCashReceived | giá trị biên | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:10:00.000 | ConfirmCashReceived(H1, clerk 3) | Ném HoldNotActiveError mang Status = EXPIRED (nhân viên được báo trả lại tiền mặt); H1 EXPIRED đã ghi; ghế 101, 105 AVAILABLE; InsertWithTickets 0 lần; không vé; cùng một commit | BR-44; UC-005 9a1a (KB8); Q-134; X-09 | EC-118, BV-59 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-228 | DC-BookTicketsService.ConfirmCashReceived | chuyển trạng thái | H1 của nhân viên 3 CANCELLED | ConfirmCashReceived(H1, clerk 3) lúc 10:05:00 | Ném HoldNotActiveError mang Status = CANCELLED; không ghi gì; không vé | BR-86; X-09 | EC-119 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-229 | DC-BookTicketsService.ConfirmCashReceived | phân vùng tương đương | Không có lần giữ ghế 9999 | ConfirmCashReceived(9999, clerk 3) | Ném NotFoundError; không ghi gì | P12 F2 | EC-121 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Trung bình | Unit |
| TC-230 | DC-BookTicketsService.ConfirmCashReceived | phân vùng tương đương | Hold H1 của nhân viên quầy 3 ACTIVE, expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; tx.Now = 10:05:00.000 | ConfirmCashReceived(H1, clerk 4) | Ném NotFoundError (Q-147); H1 vẫn ACTIVE; ghế vẫn HELD bởi H1; không Booking, không vé | P12 F3 (không nêu lỗi) | EC-120 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Trung bình | Unit |
| TC-231 | DC-BookTicketsService.ConfirmCashReceived | chuyển trạng thái | H1 đã COMPLETED bởi lần xác nhận trước (ghế SOLD) | ConfirmCashReceived(H1, clerk 3) lần hai lúc 10:05:00 | Ném HoldNotActiveError mang Status = COMPLETED; chỉ một Booking; không vé thứ hai | BR-24 (tương tự); BR-85, BR-86; Bảng hỏng M5 mục 4 (bấm lại) | EC-119 | fake IF-08/17/18/20, stub IF-24/IF-25, mock IF-23 | Cao | Unit |
| TC-232 | DC-BookTicketsService.StartOnlinePayment | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); tx.Now = 10:05:00.000 | StartOnlinePayment(H1, by khách 7, clientIp 10.0.0.9) | Trả PaymentStart (địa chỉ từ IF-01); PaymentTransaction mới PENDING mã T1, số tiền 270.000, gắn H1; IF-01 gọi 1 lần với (T1, ref của H1, 270000, 10:10:00.000, 10.0.0.9) sau commit; H1 vẫn ACTIVE; ghế vẫn HELD | BR-90; UC-005 9, 10 (KB1); NFR-15 | EC-122 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Cao | Unit |
| TC-233 | DC-BookTicketsService.StartOnlinePayment | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); đã gọi StartOnlinePayment một lần (txn T1 PENDING) | StartOnlinePayment(H1, by khách 7, 10.0.0.9) lần hai lúc 10:06:00 | Trả PaymentStart mới; tồn tại hai PaymentTransaction PENDING (T1, T2) cùng gắn H1; T1 không bị xoá hay sửa | BR-90 (thanh toán lại mỗi lần tạo bản ghi mới); P09 F7.6 | EC-122 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-234 | DC-BookTicketsService.StartOnlinePayment | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); tx.Now = 10:10:00.000 | StartOnlinePayment(H1, by khách 7, 10.0.0.9) | Ném HoldNotActiveError mang Status = EXPIRED; H1 EXPIRED đã ghi; PaymentTransaction mới 0; IF-01 0 lần; ghế vẫn HELD (SeatReleaseJob trả sau) | BR-86; UC-005 7b | EC-123 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-235 | DC-BookTicketsService.StartOnlinePayment | chuyển trạng thái | Hold H1 CANCELLED | StartOnlinePayment(H1, by khách 7, 10.0.0.9) lúc 10:05:00 | Ném HoldNotActiveError mang Status = CANCELLED; PaymentTransaction mới 0; IF-01 0 lần | BR-86; UC-005 *a | EC-124 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-236 | DC-BookTicketsService.StartOnlinePayment | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); IF-01 ném GatewayConfigurationError; tx.Now = 10:05:00.000 | StartOnlinePayment(H1, by khách 7, 10.0.0.9) | Ném GatewayConfigurationError; PaymentTransaction PENDING T1 vẫn tồn tại (đã commit); H1 vẫn ACTIVE; ghế vẫn HELD | BR-90; UC-005 10a | EC-125 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-237 | DC-BookTicketsService.StartOnlinePayment | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102, 103 HELD (90.000 mỗi ghế); tx.Now = 10:05:00.000 | StartOnlinePayment(H1, by khách 8, 10.0.0.9) | Ném NotFoundError (Q-147); IF-01 0 lần; PaymentTransaction mới 0 | P12 F2, F3 (không nêu) | EC-126 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-238 | DC-BookTicketsService.StartOnlinePayment | phân vùng tương đương | Không có lần giữ ghế 9999 | StartOnlinePayment(9999, by khách 7, 10.0.0.9) | Ném NotFoundError; IF-01 0 lần | P12 F2 | EC-127 | fake IF-08/17/18/19, mock IF-01, stub IF-24/IF-25 | Trung bình | Unit |
| TC-239 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED (00); H1 COMPLETED; ghế 101, 102 SOLD với currentTicket; 2 vé giá 90.000, 1 Booking; PT1 TICKETED, mã cổng GW1, paidAt 10:04:00; Enqueue(EMAIL_TICKET) 1 lần; CreateFullRefund 0 lần; Violated() = false | BR-37, BR-85; UC-005 11 đến 14 (KB1) | EC-132, DT6-R5 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-240 | DC-PaymentReportService.HandleIpn | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:09:59.999 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; bán ghế: H1 COMPLETED, PT1 TICKETED | BR-14 (còn trước hạn 1 ms); BR-85 | EC-132 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-241 | DC-PaymentReportService.HandleIpn | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:10:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; H1 EXPIRED (đã ghi); ghế 101, 102 AVAILABLE (Q-134); không vé, không Booking; PT1 LATE_PAYMENT; CreateFullRefund 1 lần với PT1; Enqueue(EMAIL_TICKET) 0 lần | BR-14; UC-006 (thanh toán trễ); X-09; Q-134 | EC-133, DT6-R6 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-242 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 CANCELLED lúc 10:03:00 (expiry 10:10:00.000); ghế 101, 102 AVAILABLE; txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, mã cổng GW1, ref-1, amount 180000; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; H1 vẫn CANCELLED; PT1 LATE_PAYMENT; CreateFullRefund 1 lần; không vé | BR-15; BR-86; UC-005 *a, UC-006 | EC-133, DT6-R6 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-243 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) | Trả PROCESSED; PT1 LATE_PAYMENT; CreateFullRefund 1 lần; H1 vẫn ACTIVE; ghế vẫn HELD (không bán) | BR-15; ST-05 STT 5; UC-006 | DT6-R6 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-244 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; ghế 102 có currentHold = H2 (liên kết ghế vỡ) | HandleIpn(params hợp lệ của r) | Trả PROCESSED; không bán ghế, không vé; PT1 LATE_PAYMENT với lateReason HOLD_LINK_BROKEN; CreateFullRefund 1 lần; ghi log lỗi nghiêm trọng; không rollback; ghế 102 vẫn HELD bởi H2 | P08 F4b EX-02 (Q-84); P09 F7.6 dòng 1 | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-245 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) (báo thành công lặp lại) | Trả DUPLICATE (02); PT1 TICKETED, duplicateReportCount = 1; không vé thứ hai; CreateFullRefund 0 lần | BR-37; UC-006 2a; X-09 | EC-134, DT6-R7 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-246 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) (báo trùng) | Trả DUPLICATE; duplicateReportCount = 1; CreateFullRefund 0 lần (mỗi giao dịch chỉ hoàn toàn bộ một lần) | BR-16 (gộp BR-37); BR-37; UC-006 2a | DT6-R7 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-247 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; PT1 là giao dịch tạo sau cùng của H1 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; PT1 FAILED, mã cổng vẫn rỗng; H1 PAYMENT_FAILED; ghế 101, 102 AVAILABLE trong cùng giao dịch; CreateFullRefund 0 lần | BR-39, BR-93; UC-005 11a; Q-134 | EC-135, DT6-R8 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-248 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; có PT2 PENDING tạo sau PT1 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; PT1 FAILED; H1 vẫn ACTIVE; ghế vẫn HELD; PT2 vẫn PENDING | BR-93; UC-005 11a (giao dịch cũ) | DT6-R8 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-249 | DC-PaymentReportService.HandleIpn | giá trị biên | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:10:00.000 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; H1 EXPIRED (không PAYMENT_FAILED); ghế AVAILABLE; PT1 FAILED; CreateFullRefund 0 lần | BR-39; BR-86; UC-006 2c | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-250 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(báo thất bại của PT1) | Trả PROCESSED; PT1 vẫn TICKETED; H1 vẫn COMPLETED; ghế vẫn SOLD; CreateFullRefund 0 lần | BR-39; UC-006 2d | DT6-R8 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-251 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 ACTIVE như ca bán ghế; không có giao dịch nào mã LẠ-99; không có lần giữ ghế mang ref-lạ; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với giao dịch LẠ-99 và holdRef ref-lạ | Trả UNKNOWN_TRANSACTION (01); logUnrecognized 1 lần; Do 0 lần; không vé; CreateFullRefund 0 lần; Enqueue 0 lần | BR-38; UC-006 2e | EC-130, DT6-R3 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-252 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); không có PaymentTransaction nào (StartOnlinePayment lỗi trước khi commit); báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với giao dịch 20260001 chưa tồn tại, ref-1 hợp lệ, amount 180000 | Trả PROCESSED; PaymentTransaction mới mã 20260001 được tạo từ báo rồi TICKETED; H1 COMPLETED; ghế SOLD | P09 F7.6 (tạo giao dịch từ báo); P12 Vấn đề còn mở 3 | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-253 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); không có PaymentTransaction nào; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với giao dịch chưa tồn tại, ref-1, amount 170000 | Trả AMOUNT_MISMATCH (04); không tạo PaymentTransaction; H1 vẫn ACTIVE; ghế vẫn HELD; log 1 lần | BR-91; P09 F7.6 | EC-131 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-254 | DC-PaymentReportService.HandleIpn | use case | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); không có PaymentTransaction nào; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:12:00.000; H1 EXPIRED, ghế AVAILABLE | HandleIpn(params hợp lệ của r) với giao dịch chưa tồn tại, amount 170000 | Trả PROCESSED; PaymentTransaction mới LATE_PAYMENT số tiền 170.000; CreateFullRefund 1 lần với 170.000 (không có giá để so) | BR-40; P09 F7.6 (hoàn theo số tiền cổng báo) | - | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-255 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với amount 170000 | Trả AMOUNT_MISMATCH (04); PT1 PENDING; H1 ACTIVE; ghế HELD; không vé; CreateFullRefund 0 lần; log lỗi 1 lần | BR-91; UC-006 2f | DT6-R4 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-256 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) với chữ ký sai | Trả INVALID_SIGNATURE (97); mọi store 0 lần gọi; không ghi gì | NFR-16; P09 F7.6 | EC-128, DT6-R1 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-257 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) thiếu tham số số tiền (chữ ký đúng) | Trả MALFORMED (99); mọi store 0 lần gọi | P12 F2 (MalformedReportError) | EC-129, DT6-R2 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Trung bình | Unit |
| TC-258 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(params hợp lệ của r) vừa sai chữ ký vừa thiếu tham số | Trả INVALID_SIGNATURE (Verify chạy trước Decode) | P12 F2 DC-PaymentReportReceiver | DT6-R1 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Trung bình | Unit |
| TC-259 | DC-PaymentReportService.HandleIpn | phân vùng tương đương | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; fake IF-08.Do trả SystemBusyError sau hết lần thử | HandleIpn(params hợp lệ của r) | Trả TEMPORARY_FAILURE (99); H1 ACTIVE; PT1 PENDING; ghế HELD; không vé (rollback trọn) | P09 F7.6 (lỗi tạm thời); Bảng hỏng M5 mục 3 | EC-136 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-260 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 PENDING, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000; amount báo 170000 | HandleIpn(báo thất bại của PT1, amount 170000) | Trả PROCESSED (00) (báo thất bại không kiểm số tiền, Q-146); PT1 FAILED; H1 PAYMENT_FAILED; ghế 101, 102 AVAILABLE; log AMOUNT_MISMATCH 0 lần | BR-91 (chỉ nêu báo thành công); BR-39 | DT6-R9 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
| TC-261 | DC-PaymentReportService.HandleIpn | bảng quyết định | Hold H1 của khách 7 ACTIVE, expiry 10:10:00.000; ghế 101, 102 HELD bởi H1 (90.000 mỗi ghế, tổng 180.000); txn PT1 mã 20260001 TICKETED (đã xử lý), H1 COMPLETED, amount 180.000, gắn H1; báo r: thành công, giao dịch 20260001, mã cổng GW1, ref-1, amount 180000, paidAt 10:04:00; tx.Now = 10:05:00.000 | HandleIpn(báo thành công trùng, amount 170000) | Trả DUPLICATE (02) (báo trùng không kiểm số tiền, Q-146); duplicateReportCount tăng 1; log AMOUNT_MISMATCH 0 lần | BR-91 và BR-37 | DT6-R9 | fake IF-08/17/18/19/20, stub IF-02/IF-25, mock DC-RefundService/IF-23, spy log | Cao | Unit |
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
| TC-275 | DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | vòng lặp | tx.Now = 10:10:00.000; 250 hold quá hạn; hết budget sau lô đầu | RunDue(budget 8 giây): cleanupEvents có được gọi không | cleanupEvents được gọi đúng 1 lần trong ngữ cảnh riêng có hạn 2 giây (không dùng ngữ cảnh đã hết ngân sách 8 giây); IF-22.DeleteOlderThan(10 phút, 200) 1 lần (Q-148) | P12 F3 (không nêu ngữ cảnh của cleanupEvents); X1 RV-04 | - | fake IF-08/17, mock IF-22/IF-18, stub IF-25 | Cao | Unit |
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
| TC-287 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00:00.000 | CancelOnlineTicket(TK1, customer khách 7) | Trả CancelResult; TK1 CANCELLED; ghế 101 AVAILABLE; RequestTicketRefund 1 lần với (PT1, TK1, 70.000); 1 commit; thứ tự khoá ghi nhận LockByKey (6), LockPaymentOfTicket (7), LockTicketByID (8); Violated() = false | BR-17 đến BR-19, BR-21, BR-42; Q-133; UC-008 bước 4 đến 7 | EC-146, DT7-R1 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-288 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 18:00:00.000 | CancelOnlineTicket(TK1, khách 7) | Huỷ thành công: TK1 CANCELLED; ghế AVAILABLE; hoàn 70.000 | BR-18, BR-32 (đúng 2 giờ) | BV-60 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-289 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 18:00:00.001 | CancelOnlineTicket(TK1, khách 7) | Ném CancelDeadlineError; TK1 UNUSED; ghế 101 SOLD; RequestTicketRefund 0 lần | BR-18, BR-32; UC-008 3a | EC-148, BV-61, DT7-R3 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-290 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | phân vùng tương đương | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 20:30:00.000 (suất chiếu đã bắt đầu) | CancelOnlineTicket(TK1, khách 7) | Ném CancelDeadlineError; không ghi gì | BR-18; UC-008 3a (đã bắt đầu) | EC-148 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-291 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00 | CancelOnlineTicket(TK1, customer khách 8) | Ném ChannelMismatchError; TK1 UNUSED; ghế SOLD; không ghi gì | BR-17; UC-008 2a | EC-147, DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-292 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK2 mua tại quầy (Booking của hold CLERK 3); ghế 102 SOLD; Showtime như trên; tx.Now = 17:00 | CancelOnlineTicket(TK2, customer khách 7) | Ném ChannelMismatchError; không ghi gì | BR-17; UC-008 2a (vé mua tại quầy) | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-293 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2 với TK1 đã CANCELLED (huỷ lần trước); tx.Now = 17:00 | CancelOnlineTicket(TK1, khách 7) lần hai | Ném TicketStateError mang CANCELLED; RequestTicketRefund 0 lần (không hoàn thêm); ghế không đổi | BR-21; UC-008 4a; X-15 | DT7-R4 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-294 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2 với TK1 USED (đã soát); tx.Now = 17:00 | CancelOnlineTicket(TK1, khách 7) | Ném TicketStateError mang USED; TK1 vẫn USED; ghế vẫn SOLD; không hoàn | BR-30; UC-008 4b; X-14 | EC-149, DT7-R5 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-295 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; vé của khách 8 (khách 7 gọi) và tx.Now = 19:00 (quá hạn) | CancelOnlineTicket(TK1, khách 7) | Ném ChannelMismatchError (kênh kiểm trước hạn theo thứ tự bước 2 rồi bước 3) | UC-008 mục 3 (2a trước 3a); BR-17 | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-296 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2 với TK1 CANCELLED; tx.Now = 19:00 (quá hạn) | CancelOnlineTicket(TK1, khách 7) | Ném CancelDeadlineError (3a trước 4a) | UC-008 mục 3 (hạn kiểm ở bước 3 trước bước 4) | DT7-R3 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-297 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00; RequestTicketRefund ném RefundLimitError | CancelOnlineTicket(TK1, khách 7) | Ném RefundLimitError; TK1 vẫn UNUSED; ghế 101 vẫn SOLD (rollback trọn, không có vé huỷ mà khách mất tiền không dấu vết) | BR-26; Q-133; X-16 | EC-150 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-298 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; ghế 101 đã bán lại bằng vé TK9 (currentTicket = TK9) | CancelOnlineTicket(TK1, khách 7) lúc 17:00 | TK1 CANCELLED; ghế 101 vẫn SOLD bởi TK9; SaveChanges 0 lần; RequestTicketRefund 1 lần | BR-42; R-64; X-18 | EC-151 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-299 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK1 ghế 101 giá 45.001 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00 | CancelOnlineTicket(TK1, khách 7) | RequestTicketRefund nhận amount 31.500 (70% của 45.001 làm tròn xuống) | BR-19, BR-31; UC-008 5 | EC-146 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-300 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | phân vùng tương đương | Không có vé mã 9999 | CancelOnlineTicket(9999, khách 7) | Ném NotFoundError; không ghi gì | P12 F2 | - | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Trung bình | Unit |
| TC-301 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | phân vùng tương đương | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; LockTicketByID ném SystemBusyError | CancelOnlineTicket(TK1, khách 7) | Ném SystemBusyError; TK1 UNUSED; ghế SOLD | P09 F7.3; P12 F2 | - | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Trung bình | Unit |
| TC-302 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK2 giá 100.000 UNUSED thuộc Booking BK2 của hold CLERK 3 (cụm rạp 2); ghế 102 SOLD; Showtime 55; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4 của cụm rạp 2) | TK2 CANCELLED; ghế 102 AVAILABLE; IF-21.Insert 1 lần với yêu cầu hoàn TICKET_CASH, REFUNDED, 70.000; LockPaymentOfTicket 0 lần (không hạng 7); IF-23.Enqueue 0 lần; IF-01 0 lần; 1 commit; Violated() = false | BR-17 đến BR-21, BR-42; UC-008 5a1, 5a2 (KB: huỷ tại quầy) | EC-152 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-303 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK1 ghế 101 giá 100.000 UNUSED thuộc Booking BK1 của hold khách 7 (mua trực tuyến); ghế 101 SOLD với currentTicket TK1; giao dịch PT1 TICKETED, amount 200.000, refundedTotal 0; Showtime 55 bắt đầu 2026-11-10 20:00:00.000, cụm rạp 2; tx.Now = 17:00 | ConfirmCashRefund(TK1, clerk 4) | Ném ChannelMismatchError (vé mua trực tuyến); không ghi gì | BR-17; UC-008 2b | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-304 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK2 mua tại quầy của cụm rạp 3; Showtime 55 thuộc cụm rạp 3; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4 của cụm rạp 2) | Ném ChannelMismatchError (vé quầy của cụm rạp khác); không ghi gì | BR-17; UC-008 2c | DT7-R2 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-305 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | giá trị biên | Vé TK2 mua tại quầy UNUSED, ghế 102 SOLD; Showtime 55 bắt đầu 20:00; tx.Now = 18:00:00.001 | ConfirmCashRefund(TK2, clerk 4) | Ném CancelDeadlineError; không ghi gì | BR-18 (áp dụng cả vé quầy); UC-008 3a | DT7-R3 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-306 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | bảng quyết định | Vé TK2 mua tại quầy, USED; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4) | Ném TicketStateError mang USED; không tạo yêu cầu hoàn tiền mặt; ghế vẫn SOLD | BR-30; UC-008 4b | DT7-R5 | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
| TC-307 | DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | use case | Vé TK2 quầy, ghế 102 đã bán lại bằng TK9; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4) | TK2 CANCELLED; ghế 102 vẫn SOLD bởi TK9; SaveChanges 0 lần; IF-21.Insert 1 lần (REFUNDED, 70.000) | BR-42; R-64 | - | fake IF-08/11/18/20, mock DC-RefundService/IF-21, stub IF-25 | Cao | Unit |
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
| TC-341 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim trả claimedUntil = tx.Now + 9,999 giây | ProcessRefund(E1): giá trị trả về | Trả nil; log cảnh báo 1 lần; IF-01.RequestRefund 0 lần, IF-01.FindRefund 0 lần; RR1 IN_FLIGHT attemptCount 1 (giao dịch 1 đã commit); dòng outbox giữ claim, nhận lại sau claimed_until (Q-150) | P12 F2, F3 (không nêu) | - | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-342 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 WAITING_RETRY, attemptCount 1; claim còn 9 giây trước FindRefund | ProcessRefund(E1) | IF-01 0 lần (cả FindRefund lẫn RequestRefund); không ghi sau giao dịch 1 | P12 F3 bước 2 (kiểm mốc trước mỗi lời gọi) | đường P136, CE371 đến CE372, CE374, CE376, CE378 đến CE380, CE382, CE410 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-343 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; claim còn 10,001 giây | ProcessRefund(E1) | Trả nil; bỏ lượt vì claim còn dưới 15 giây (hạn tính ra dưới 5 giây); IF-01.RequestRefund 0 lần (Q-149) | P12 F3 bước 2; Q-149 | BV-67 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
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
| TC-356 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | now = 2026-11-10 08:00:00 | IssueSession("7", CUSTOMER, CUSTOMER, "", nil) | IssuedSession.expiresAt = 2026-11-11 08:00:00 (24 giờ) | Q-129 | EC-179 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-357 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | now = 2026-11-10 08:00:00 | IssueSession("3", STAFF, BOX_OFFICE_CLERK, "2", accessChangedAt A1) | IssuedSession.expiresAt = 2026-11-10 16:00:00 (8 giờ) | Q-129; NFR-02 | EC-180 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-358 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | now = 2026-11-10 08:00:00 | IssueSession("1", STAFF, ADMINISTRATOR, "", nil) | IssuedSession.expiresAt = 2026-11-10 16:00:00 (8 giờ) | NFR-03; Q-153 | EC-181 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-359 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Phiên của nhân viên quầy 3 cụm rạp 2 cấp lúc 08:00:00 | VerifySession(token) lúc 15:59:59.999 | Trả SessionClaims{subjectId 3, role BOX_OFFICE_CLERK, cinemaId 2, subjectKind STAFF, accessChangedAt A1, expiresAt 16:00:00} | Q-129 | EC-182 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-360 | IF-07.VerifyPassword, IssueSession, VerifySession | phân vùng tương đương | Như trên | VerifySession(token đã đổi một ký tự) | Ném SessionInvalidError | P12 F2 | EC-183 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-361 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | Như trên | VerifySession(token) lúc 16:00:01 | Ném SessionExpiredError | Q-129; P12 F2 | EC-184 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-362 | IF-07.VerifyPassword, IssueSession, VerifySession | giá trị biên | Như trên | VerifySession(token) lúc đúng 16:00:00.000 | Ném SessionExpiredError (hết hạn khi now >= expiresAt) | Q-154; P12 F2 | - | driver IF-07, stub đồng hồ | Trung bình | Unit |
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
| TC-385 | DC-HoldSettlement.End | bảng quyết định | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; H1 ACTIVE | End(now = 10:09:59.999, H1, EXPIRY, [101, 102]) | Trả outcome{expired = false, holdChanged = false, released = []}; H1 vẫn ACTIVE; ghế 101, 102 vẫn HELD bởi H1 | BR-10; ST-01 | DT9-R1, EC-190, EC-193, BV-72 | Không (đối tượng thuần) | Cao | Unit |
| TC-386 | DC-HoldSettlement.End | bảng quyết định | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; H1 ACTIVE | End(now = 10:10:00.000, H1, EXPIRY, [101, 102]) | Trả outcome{expired = true, holdChanged = true, released = [101, 102]}; H1 EXPIRED; ghế 101, 102 AVAILABLE, currentHold rỗng, heldPrice rỗng | BR-10, BR-86; ST-01 STT 3; ST-02 | DT9-R2, BV-73, EC-194, EC-198 | Không (đối tượng thuần) | Cao | Unit |
| TC-387 | DC-HoldSettlement.End | giá trị biên | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101 HELD bởi H1; H1 ACTIVE | End(now = 10:10:00.001, H1, EXPIRY, [101]) | Trả outcome{expired = true, holdChanged = true, released = [101]}; H1 EXPIRED; ghế 101 AVAILABLE | BR-10 | BV-75 | Không (đối tượng thuần) | Cao | Unit |
| TC-388 | DC-HoldSettlement.End | bảng quyết định | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101 HELD bởi H1, ghế 102 đã giữ lại bởi H2; H1 EXPIRED (chạy lần thứ hai) | End(now = 10:11:00.000, H1, EXPIRY, [101, 102]) | Trả outcome{expired = true, holdChanged = false, released = [101]}; ghế 101 AVAILABLE; ghế 102 vẫn HELD bởi H2; H1 vẫn EXPIRED | BR-86; R-63; P12 F2 (chạy lặp an toàn) | DT9-R3, EC-195, EC-199 | Không (đối tượng thuần) | Cao | Unit |
| TC-389 | DC-HoldSettlement.End | giá trị biên | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; H1 ACTIVE | End(now = 10:10:00.000, H1, EXPIRY, nil) | Trả outcome{expired = true, holdChanged = true, released = []}; H1 EXPIRED; ghế 101, 102 vẫn HELD bởi H1 (SeatReleaseJob trả sau) | P12 F3 HoldSeats (f); BR-10 | BV-74, EC-197 | Không (đối tượng thuần) | Cao | Unit |
| TC-390 | DC-HoldSettlement.End | bảng quyết định | H1 COMPLETED (đã bán), ghế 101, 102 SOLD | End(now = 10:11:00.000, H1, EXPIRY, []) | Trả outcome{expired = false, holdChanged = false, released = []}; H1 vẫn COMPLETED | BR-86 | DT9-R4, EC-196 | Không (đối tượng thuần) | Cao | Unit |
| TC-391 | DC-HoldSettlement.End | bảng quyết định | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; thêm ghế 103 HELD bởi H1; H1 ACTIVE | End(now = 10:05:00.000, H1, CANCEL, [101, 102, 103]) | Trả outcome{expired = false, holdChanged = true, released = [101, 102, 103]}; H1 CANCELLED; 3 ghế AVAILABLE | BR-85; ST-01 STT cancel | DT9-R5, EC-191, EC-193 | Không (đối tượng thuần) | Cao | Unit |
| TC-392 | DC-HoldSettlement.End | giá trị biên | H1 ACTIVE giữ 7 ghế 101..107 (90.000 mỗi ghế) | End(now = 10:05:00.000, H1, CANCEL, 7 ghế) | Trả outcome{released = 7 ghế}; H1 CANCELLED; cả 7 ghế AVAILABLE | BR-05 | BV-76 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-393 | DC-HoldSettlement.End | giá trị biên | H1 ACTIVE giữ 8 ghế 101..108 | End(now = 10:05:00.000, H1, CANCEL, 8 ghế) | Trả outcome{released = 8 ghế}; H1 CANCELLED; cả 8 ghế AVAILABLE | BR-05 | BV-76 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-394 | DC-HoldSettlement.End | bảng quyết định | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; H1 ACTIVE | End(now = 10:10:00.000, H1, CANCEL, [101, 102]) | Không gọi Cancel; trả outcome{expired = true, holdChanged = true, released = [101, 102]}; H1 EXPIRED (không CANCELLED); ghế AVAILABLE | BR-10, BR-86; P12 F3 End (3) | DT9-R6, BV-73 | Không (đối tượng thuần) | Cao | Unit |
| TC-395 | DC-HoldSettlement.End | bảng quyết định | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; H1 ACTIVE | End(now = 10:10:00.001, H1, PAYMENT_FAILURE, [101, 102]) | Trả outcome{expired = true, holdChanged = true, released = [101, 102]}; H1 EXPIRED, không PAYMENT_FAILED | BR-39, BR-86 | DT9-R6, EC-192 | Không (đối tượng thuần) | Cao | Unit |
| TC-396 | DC-HoldSettlement.End | chuyển trạng thái | Hold H1 của khách 7, expiry E = 10:10:00.000; ghế 101, 102 HELD bởi H1; H1 ACTIVE | End(now = 10:05:00.000, H1, PAYMENT_FAILURE, [101, 102]) | Trả outcome{expired = false, holdChanged = true, released = [101, 102]}; H1 PAYMENT_FAILED; ghế AVAILABLE | BR-39; ST-01 failPayment | DT9-R5 | Không (đối tượng thuần) | Cao | Unit |
| TC-397 | DC-HoldSettlement.End | bảng quyết định | H1 EXPIRED (đã hết hạn từ trước); ghế 101 HELD bởi H2 | End(now = 10:11:00.000, H1, CANCEL, [101]) | Ném HoldNotActiveError mang Status = EXPIRED; ghế 101 vẫn HELD bởi H2; H1 vẫn EXPIRED | BR-86 | DT9-R7, EC-195 | Không (đối tượng thuần) | Cao | Unit |
| TC-398 | DC-HoldSettlement.End | bảng quyết định | H1 COMPLETED; ghế 101, 102 SOLD | End(now = 10:11:00.000, H1, CANCEL, [101, 102]) | Ném HoldNotActiveError mang Status = COMPLETED; ghế vẫn SOLD; H1 vẫn COMPLETED | BR-86 | DT9-R8, EC-196 | Không (đối tượng thuần) | Cao | Unit |
| TC-399 | DC-HoldSettlement.End | bảng quyết định | H1 CANCELLED | End(now = 10:05:00.000, H1, PAYMENT_FAILURE, []) | Ném HoldNotActiveError mang Status = CANCELLED; H1 vẫn CANCELLED | BR-86 | DT9-R8 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-400 | DC-HoldSettlement.Sell, FinishSale | bảng quyết định | H1 ACTIVE expiry 10:10:00.000; ghế 101 (90.000) và 105 (120.000) HELD bởi H1; snap = (phim Dune, cụm rạp Q1, phòng 7, 2D) | Sell(now = 10:05:00.000, H1, [101, 105], BK1, [TKA, TKB], snap) | Trả Booking mã BK1 bookedAt 10:05:00.000 với 2 vé UNUSED giá 90.000 (TKA, ghế 101) và 120.000 (TKB, ghế 105) mang snapshot; H1 COMPLETED; ghế vẫn HELD (chưa MarkSold) | BR-67, BR-80, BR-85, BR-140; ST-01 complete; ST-03 tạo vé | DT11-R3, EC-200, EC-204 | Không (đối tượng thuần) | Cao | Unit |
| TC-401 | DC-HoldSettlement.Sell, FinishSale | phân vùng tương đương | H1 ACTIVE | Sell(now = 10:05:00.000, H1, [], BK1, [], snap) | Ném LinkMismatchError; H1 vẫn ACTIVE | P12 F2 Sell | DT11-R1, EC-201 | Không (đối tượng thuần) | Cao | Unit |
| TC-402 | DC-HoldSettlement.Sell, FinishSale | phân vùng tương đương | H1 ACTIVE; ghế 101, 105 HELD bởi H1 | Sell(now, H1, [101, 105], BK1, [TKA], snap) | Ném LinkMismatchError; H1 vẫn ACTIVE; không Booking | P12 F2 Sell | EC-202 | Không (đối tượng thuần) | Cao | Unit |
| TC-403 | DC-HoldSettlement.Sell, FinishSale | phân vùng tương đương | H1 ACTIVE; ghế 101 HELD bởi H1, ghế 105 HELD bởi H2 | Sell(now, H1, [101, 105], BK1, [TKA, TKB], snap) | Ném LinkMismatchError; H1 vẫn ACTIVE; ghế 101 vẫn HELD bởi H1 | R-63; P12 F2 Sell | EC-203 | Không (đối tượng thuần) | Cao | Unit |
| TC-404 | DC-HoldSettlement.Sell, FinishSale | bảng quyết định | H1 EXPIRED; ghế 101, 105 còn HELD bởi H1 (dữ kiện dựng bằng bộ dựng thử) | Sell(now = 10:11:00.000, H1, [101, 105], BK1, [TKA, TKB], snap) | Ném HoldNotActiveError mang Status = EXPIRED; không Booking | BR-86 | DT11-R2, EC-205 | Không (đối tượng thuần) | Cao | Unit |
| TC-405 | DC-HoldSettlement.Sell, FinishSale | giá trị biên | H1 ACTIVE chưa gọi Expire; ghế 101 HELD bởi H1 | Sell(now = 10:10:00.000, H1, [101], BK1, [TKA], snap) | Ném HoldNotActiveError mang Status = ACTIVE (Q-142: entity không tự hết hạn); H1 vẫn ACTIVE | Q-142; BR-10 | DT11-R2, EC-205 | Không (đối tượng thuần) | Cao | Unit |
| TC-406 | DC-HoldSettlement.Sell, FinishSale | bảng quyết định | H1 CANCELLED; seats rỗng (LockByHold không trả ghế đã trả) | Sell(now, H1, [], BK1, [], snap) | Ném LinkMismatchError (kiểm ghế trước Complete), không phải HoldNotActiveError | P12 F2 Sell (thứ tự kiểm); Q-352 | DT11-R1 | Không (đối tượng thuần) | Cao | Unit |
| TC-407 | DC-HoldSettlement.Sell, FinishSale | phân vùng tương đương | Booking vừa Sell, vé TKA và TKB đã có id 501, 502 (bộ dựng SetTicketId); ghế 101, 105 HELD bởi H1 | FinishSale(H1, booking, [101, 105]) | Trả nil; ghế 101 SOLD currentTicket 501, ghế 105 SOLD currentTicket 502; currentHold rỗng | R-63, R-64; ST-02 markSold | EC-206 | Không (đối tượng thuần) | Cao | Unit |
| TC-408 | DC-HoldSettlement.Sell, FinishSale | phân vùng tương đương | Booking có vé cho ghế 101; ghế 102 trong seats không có vé; ghế 102 AVAILABLE | FinishSale(H1, booking, [101, 102]) | Ném LinkMismatchError; không ghế nào bị đổi thêm ngoài ghế đã xử lý trước khi lỗi (lỗi lập trình dưới khoá hạng 6, bên gọi rollback) | P12 F2 FinishSale | EC-207 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-409 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_ONLY | AcquireValue(CUSTOMER_EMAIL, "an@cinebook.vn") | Ném LockInReadOnlyTxError; Violated() = false | P12 F2; P09 F7.12 | EC-208 | Không (đối tượng thuần) | Cao | Unit |
| TC-410 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_WRITE mới | AcquireValue(CINEMA_NAME, "rạp q1") | Trả nil; Violated() = false; maxRank = 0 | P09 F7.3 EX-17 | EC-209 | Không (đối tượng thuần) | Cao | Unit |
| TC-411 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_WRITE mới | AcquireValue(CUSTOMER_EMAIL, "an@cinebook.vn") rồi AcquireValue(CUSTOMER_PHONE, "0901234567") | Cả hai trả nil; Violated() = false | P09 F7.3 EX-20; X-30 | EC-210 | Không (đối tượng thuần) | Cao | Unit |
| TC-412 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_WRITE mới | AcquireValue(CUSTOMER_PHONE, "0901234567") rồi AcquireValue(CUSTOMER_EMAIL, "an@cinebook.vn") | Lần hai ném LockOrderViolationError; Violated() = true | P08 F4b quy tắc 3; X-30 | EC-211 | Không (đối tượng thuần) | Cao | Unit |
| TC-413 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_WRITE mới đã AcquireValue(CUSTOMER_EMAIL, "an@cinebook.vn") | AcquireValue(CUSTOMER_EMAIL, "an@cinebook.vn") lần hai | Trả nil; Violated() = false | Q-324 | EC-212 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-414 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Như trên | AcquireValue(CUSTOMER_EMAIL, "binh@cinebook.vn") | Ném LockOrderViolationError; Violated() = true | Q-324 | EC-213 | Không (đối tượng thuần) | Cao | Unit |
| TC-415 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_WRITE đã Acquire(CINEMA, key 9, X) | AcquireValue(CINEMA_NAME, "rạp q1") | Ném LockOrderViolationError (khoá giá trị phải đứng trước khoá dòng hạng 0); Violated() = true | P12 F2, F3 | EC-214 | Không (đối tượng thuần) | Cao | Unit |
| TC-416 | DC-LockOrderGuard.AcquireValue | phân vùng tương đương | Guard READ_WRITE đã Acquire(STAFF, 4, key 7, X) | AcquireValue(STAFF_EMAIL, "mai@cinebook.vn") | Trả nil (hạng 13 sau hạng 4); Violated() = false | P09 F7.3 EX-21 | EC-210 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-417 | DC-LockOrderGuard.Acquire | phân vùng tương đương | Guard READ_WRITE đã AcquireValue(CINEMA_NAME, "rạp q1") | Acquire(CINEMA, key 9, X) | Trả nil (khoá giá trị (-1, 0) nhỏ hơn khoá dòng (9, 0)); Violated() = false | P12 F3 AcquireValue | EC-210 | Không (đối tượng thuần) | Cao | Unit |
| TC-418 | DC-LockOrderGuard.Acquire | phân vùng tương đương | Guard READ_WRITE đã AcquireValue(STAFF_EMAIL, "mai@cinebook.vn") | Acquire(STAFF, hạng 4, key 7, X) | Ném LockOrderViolationError; Violated() = true | P08 F4b quy tắc 3 | EC-211 | Không (đối tượng thuần) | Cao | Unit |
| TC-419 | DC-Staff.CheckAccessUnchanged | bảng quyết định | Staff 7 ACTIVE, accessChangedAt = 2026-11-10 07:00:00.000001 | CheckAccessUnchanged(07:00:00.000001) | Trả nil; Staff không đổi | BR-101 | DT13-R1, EC-215 | Không (đối tượng thuần) | Cao | Unit |
| TC-420 | DC-Staff.CheckAccessUnchanged | giá trị biên | Staff 7 ACTIVE, accessChangedAt = 2026-11-10 07:00:00.000001 UTC | CheckAccessUnchanged(2026-11-10 14:00:00.000001 +07:00) | Trả nil (cùng thời điểm, so Equal) | P12 F2 (Equal) | BV-77 | Không (đối tượng thuần) | Cao | Unit |
| TC-421 | DC-Staff.CheckAccessUnchanged | giá trị biên | Staff 7 ACTIVE, accessChangedAt = 2026-11-10 07:00:00.000002 | CheckAccessUnchanged(07:00:00.000001) | Ném StaffAccessRevokedError; Staff không đổi | BR-101 | BV-78, DT13-R3, EC-217 | Không (đối tượng thuần) | Cao | Unit |
| TC-422 | DC-Staff.CheckAccessUnchanged | bảng quyết định | Staff 7 sau LockStaff (status LOCKED, accessChangedAt = now của lần khoá); phiên mang đúng mốc đó | CheckAccessUnchanged(mốc của lần khoá) | Ném StaffAccessRevokedError | BR-97, BR-101 | DT13-R2, EC-216 | Không (đối tượng thuần) | Cao | Unit |
| TC-423 | DC-BoxOfficeClerk.CheckAccessCurrent | phân vùng tương đương | Clerk 3 bọc Staff ACTIVE, accessChangedAt A | CheckAccessCurrent(A) | Trả nil | BR-100, BR-101 | EC-215 | Không (đối tượng thuần) | Cao | Unit |
| TC-424 | DC-BoxOfficeClerk.CheckAccessCurrent | phân vùng tương đương | Clerk 3 bọc Staff ACTIVE, accessChangedAt A + 1 micro giây | CheckAccessCurrent(A) | Ném StaffAccessChangedError | BR-101; X-33 | EC-217 | Không (đối tượng thuần) | Cao | Unit |
| TC-425 | DC-AccessCheckService.CheckStaffAccess | phân vùng tương đương | Staff 7 ACTIVE, role CINEMA_MANAGER, cụm rạp 2, mốc A; claims của phiên cấp lúc staff còn BOX_OFFICE_CLERK nhưng mốc A giống nhau (dữ kiện dựng bằng claims tay) | CheckStaffAccess(claims{subjectId "7", accessChangedAt A}) | Trả StaffAccess{id 7, role CINEMA_MANAGER, cinemaId 2} theo dòng vừa đọc, không theo role trong claims; Do dùng ReadOnlyTx; không khoá | BR-101; P12 F3 | EC-215 | fake IF-08 (ReadOnlyTx), IF-15 | Cao | Unit |
| TC-426 | DC-AccessCheckService.CheckStaffAccess | phân vùng tương đương | Staff 7 Bị khoá sau khi phiên được cấp | CheckStaffAccess(claims của phiên cũ) | Ném StaffAccessRevokedError | BR-97, BR-101 | EC-216 | fake IF-08, IF-15 | Cao | Unit |
| TC-427 | DC-AccessCheckService.CheckStaffAccess | phân vùng tương đương | Staff 7 đổi vai trò (SaveStaffChanges làm accessChangedAt = A2) sau khi phiên mang mốc A1 | CheckStaffAccess(claims mốc A1) | Ném StaffAccessRevokedError (thao tác kế tiếp trong phiên cũ bị từ chối) | BR-101; UC-017 1a | EC-217 | fake IF-08, IF-15 | Cao | Unit |
| TC-428 | DC-AccessCheckService.CheckStaffAccess | phân vùng tương đương | Không có | CheckStaffAccess(claims{subjectId "abc"}) | Ném StaffAccessRevokedError; IF-15.FindByID 0 lần | P12 F3 bước 1 | EC-218 | fake IF-08, IF-15 | Trung bình | Unit |
| TC-429 | DC-Customer.CheckRegistrationData | bảng quyết định | Không có | CheckRegistrationData("an@cinebook.vn", "0901234567", "Abc@1234") | Trả nil | BR-81, BR-82, BR-99; UC-001 | DT12-R1, EC-219, EC-221, EC-225, BV-80, BV-83 | Không (đối tượng thuần) | Cao | Unit |
| TC-430 | DC-Customer.CheckRegistrationData | bảng quyết định | Không có | CheckRegistrationData("an.cinebook.vn", "0901234567", "Abc@1234") | Ném RegistrationDataError(EMAIL) | BR-81; UC-001 2a | DT12-R2, EC-220 | Không (đối tượng thuần) | Cao | Unit |
| TC-431 | DC-Customer.CheckRegistrationData | giá trị biên | Không có | CheckRegistrationData("an@cinebook.vn", "090123456", "Abc@1234") | Ném RegistrationDataError(PHONE) | BR-82; UC-001 2b | DT12-R3, BV-79, EC-222 | Không (đối tượng thuần) | Cao | Unit |
| TC-432 | DC-Customer.CheckRegistrationData | giá trị biên | Không có | CheckRegistrationData("an@cinebook.vn", "09012345678", "Abc@1234") | Ném RegistrationDataError(PHONE) | BR-82 | BV-81 | Không (đối tượng thuần) | Cao | Unit |
| TC-433 | DC-Customer.CheckRegistrationData | phân vùng tương đương | Không có | CheckRegistrationData("an@cinebook.vn", "1901234567", "Abc@1234") | Ném RegistrationDataError(PHONE) | BR-82 | EC-223 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-434 | DC-Customer.CheckRegistrationData | phân vùng tương đương | Không có | CheckRegistrationData("an@cinebook.vn", "09012345a7", "Abc@1234") | Ném RegistrationDataError(PHONE) | BR-82 | EC-224 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-435 | DC-Customer.CheckRegistrationData | giá trị biên | Không có | CheckRegistrationData("an@cinebook.vn", "0901234567", "Abc@123") | Ném RegistrationDataError(PASSWORD) | BR-99; UC-001 2c | DT12-R4, BV-82, EC-226 | Không (đối tượng thuần) | Cao | Unit |
| TC-436 | DC-Customer.CheckRegistrationData | bảng quyết định | Không có | CheckRegistrationData("an.cinebook.vn", "090", "Abc@123") | Ném RegistrationDataError(EMAIL) (điều kiện đầu tiên theo thứ tự EMAIL, PHONE, PASSWORD) | P12 F2 (thứ tự); BR-81 | DT12-R5, DT12-R6, DT12-R8 | Không (đối tượng thuần) | Cao | Unit |
| TC-437 | DC-Customer.CheckRegistrationData | bảng quyết định | Không có | CheckRegistrationData("an@cinebook.vn", "090", "Abc@123") | Ném RegistrationDataError(PHONE) | P12 F2 (thứ tự); BR-82 | DT12-R7 | Không (đối tượng thuần) | Cao | Unit |
| TC-438 | DC-RegisterAccountService.RegisterAccount | use case | Chưa có khách nào; stub IF-07.HashPassword trả H1 | RegisterAccount("an@cinebook.vn", "0901234567", "Abc@1234") | Trả CustomerId mới (11); khách 11 có email, số điện thoại, mã băm H1 (không lưu mật khẩu gốc); LockValue gọi theo thứ tự CUSTOMER_EMAIL rồi CUSTOMER_PHONE; không cấp phiên; Violated() = false | UC-001 bước 4 đến 7; Q-158 | EC-219 | fake IF-08/16, mock IF-07 | Cao | Unit |
| TC-439 | DC-RegisterAccountService.RegisterAccount | use case | Không có | RegisterAccount("an@cinebook.vn", "090", "Abc@1234") | Ném RegistrationDataError(PHONE); HashPassword 0 lần; Do 0 lần; không khách mới | UC-001 2b; P12 F3 bước 1 | EC-222 | fake IF-08/16, mock IF-07 | Cao | Unit |
| TC-440 | DC-RegisterAccountService.RegisterAccount | use case | Khách 5 đã có email an@cinebook.vn | RegisterAccount("an@cinebook.vn", "0911111111", "Abc@1234") | Ném DuplicateAccountError; không khách mới; rollback | BR-98; UC-001 7a; X-30 | EC-227 | fake IF-08/16, mock IF-07 | Cao | Unit |
| TC-441 | DC-RegisterAccountService.RegisterAccount | use case | Khách 5 đã có số điện thoại 0901234567 | RegisterAccount("binh@cinebook.vn", "0901234567", "Abc@1234") | Ném DuplicateAccountError; không khách mới | BR-98; UC-001 7a; X-30 | EC-228 | fake IF-08/16, mock IF-07 | Cao | Unit |
| TC-442 | DC-RegisterAccountService.RegisterAccount | bảng quyết định | Khách 5 có email an@cinebook.vn; khách 6 có số điện thoại 0901234567 | RegisterAccount("an@cinebook.vn", "0901234567", "Abc@1234") | Ném DuplicateAccountError (một lỗi chung, không phân biệt trường); không khách mới; rollback | BR-98; P12 F2 (DuplicateAccountError không mang trường) | EC-227, EC-228 | fake IF-08/16, mock IF-07 | Trung bình | Unit |
| TC-443 | DC-RegisterAccountService.RegisterAccount | use case | IF-08.Do cấu hình trả SystemBusyError | RegisterAccount("an@cinebook.vn", "0901234567", "Abc@1234") | Ném SystemBusyError; không khách mới | P12 F2 | EC-219 | fake IF-08/16, mock IF-07 | Trung bình | Unit |
| TC-444 | DC-RegisterAccountService.RegisterAccount | use case | Lần đăng ký đầu đã commit nhưng phản hồi mất | RegisterAccount cùng ba giá trị lần hai | Ném DuplicateAccountError từ chính lần trước; vẫn đúng một khách | P09 F7.10 mục 4; BR-98 | EC-227 | fake IF-08/16, mock IF-07 | Trung bình | Unit |
| TC-445 | DC-LoginService.LoginCustomer | use case | Khách 7 (email an@cinebook.vn, số điện thoại 0901234567, hash H7); VerifyPassword(Abc@1234, H7) = true | LoginCustomer("an@cinebook.vn", "Abc@1234") | IssueSession(subjectId "7", subjectKind CUSTOMER, role CUSTOMER, cinemaId "", accessChangedAt rỗng) được gọi 1 lần; trả phiên; không ghi gì | NFR-01; UC-005 5a2 | EC-229 | fake IF-16, stub IF-07 | Cao | Unit |
| TC-446 | DC-LoginService.LoginCustomer | use case | Như trên | LoginCustomer("0901234567", "Abc@1234") | Trả phiên của khách 7 như TC trước | NFR-01 | EC-229 | fake IF-16, stub IF-07 | Trung bình | Unit |
| TC-447 | DC-LoginService.LoginCustomer | phân vùng tương đương | Không có khách none@x.vn | LoginCustomer("none@x.vn", "Abc@1234") | Ném LoginFailedError; VerifyPassword gọi 1 lần với dummyPasswordHash; IssueSession 0 lần | Q-131; P12 F3 | EC-230 | fake IF-16, stub IF-07 | Cao | Unit |
| TC-448 | DC-LoginService.LoginCustomer | phân vùng tương đương | Khách 7 như trên; VerifyPassword(Abc@12345, H7) = false | LoginCustomer("an@cinebook.vn", "Abc@12345") | Ném LoginFailedError (cùng thông điệp với tài khoản không có); IssueSession 0 lần | NFR-01; UC-005 5a2a | EC-231 | fake IF-16, stub IF-07 | Cao | Unit |
| TC-449 | DC-LoginService.LoginStaff | use case | Staff 3 ACTIVE role BOX_OFFICE_CLERK cụm rạp 2, accessChangedAt = A1 (giá trị của câu đọc), mật khẩu đúng | LoginStaff("mai@cinebook.vn", "Abc@1234") | IssueSession("3", STAFF, BOX_OFFICE_CLERK, "2", A1) được gọi 1 lần; trả phiên mang A1 | BR-101; P12 F3 bước 5 | EC-229 | fake IF-15, stub IF-07 | Cao | Unit |
| TC-450 | DC-LoginService.LoginStaff | bảng quyết định | Staff 3 LOCKED, mật khẩu đúng | LoginStaff("mai@cinebook.vn", "Abc@1234") | Ném StaffLockedError; IssueSession 0 lần | BR-97; Q-276 | EC-232 | fake IF-15, stub IF-07 | Cao | Unit |
| TC-451 | DC-LoginService.LoginStaff | bảng quyết định | Staff 3 LOCKED, mật khẩu sai | LoginStaff("mai@cinebook.vn", "sai-mat-khau") | Ném LoginFailedError (không lộ trạng thái khoá khi mật khẩu sai); IssueSession 0 lần | Q-276 | EC-233 | fake IF-15, stub IF-07 | Cao | Unit |
| TC-452 | DC-LoginService.LoginStaff | phân vùng tương đương | Staff 3 ACTIVE, mật khẩu sai | LoginStaff("mai@cinebook.vn", "sai-mat-khau") | Ném LoginFailedError | NFR-02 | EC-231 | fake IF-15, stub IF-07 | Trung bình | Unit |
| TC-453 | DC-LoginService.LoginStaff | use case | Không có nhân viên email admin@cinebook.vn; quản trị viên 1 có email đó, mật khẩu đúng | LoginStaff("admin@cinebook.vn", "Abc@1234") | IssueSession("1", STAFF, ADMINISTRATOR, "", rỗng) được gọi 1 lần | NFR-03; Q-271 | EC-234 | fake IF-15, stub IF-07 | Trung bình | Unit |
| TC-454 | DC-LoginService.LoginStaff | phân vùng tương đương | Như trên, mật khẩu sai | LoginStaff("admin@cinebook.vn", "sai") | Ném LoginFailedError | NFR-03 | EC-231 | fake IF-15, stub IF-07 | Trung bình | Unit |
| TC-455 | DC-LoginService.LoginStaff | phân vùng tương đương | Không có nhân viên và quản trị viên với email | LoginStaff("none@x.vn", "Abc@1234") | Ném LoginFailedError; VerifyPassword gọi 1 lần với dummyPasswordHash | Q-131 | EC-230 | fake IF-15, stub IF-07 | Cao | Unit |
| TC-456 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("mai@cinebook.vn", "Nguyễn Thị Mai", BOX_OFFICE_CLERK, 2) | Trả nil | BR-78, BR-79 | EC-235, EC-237, EC-241, BV-87 | Không (đối tượng thuần) | Cao | Unit |
| TC-457 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("mai.cinebook.vn", "Nguyễn Thị Mai", BOX_OFFICE_CLERK, 2) | Ném StaffDataError(EMAIL) | Q-163; UC-017 4c | EC-236 | Không (đối tượng thuần) | Cao | Unit |
| TC-458 | DC-Staff.CheckStaffData | giá trị biên | Không có | CheckStaffData("mai@cinebook.vn", "", BOX_OFFICE_CLERK, 2) | Ném StaffDataError(NAME) | Q-273; UC-017 4d | BV-86, EC-238 | Không (đối tượng thuần) | Cao | Unit |
| TC-459 | DC-Staff.CheckStaffData | giá trị biên | Không có | CheckStaffData("mai@cinebook.vn", "chuỗi 100 ký tự", BOX_OFFICE_CLERK, 2) | Trả nil | Q-273 | BV-88 | Không (đối tượng thuần) | Cao | Unit |
| TC-460 | DC-Staff.CheckStaffData | giá trị biên | Không có | CheckStaffData("mai@cinebook.vn", "chuỗi 101 ký tự", BOX_OFFICE_CLERK, 2) | Ném StaffDataError(NAME) | Q-273 | BV-89 | Không (đối tượng thuần) | Cao | Unit |
| TC-461 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("mai.cinebook.vn", "", BOX_OFFICE_CLERK, 0) | Ném StaffDataError(EMAIL) (email kiểm trước họ tên và vai trò) | P12 F2 (thứ tự kiểm) | EC-236 | Không (đối tượng thuần) | Cao | Unit |
| TC-462 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("chain@cinebook.vn", "Lê Chuỗi", CHAIN_MANAGER, 0) | Trả nil | BR-78 | EC-239 | Không (đối tượng thuần) | Cao | Unit |
| TC-463 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("chain@cinebook.vn", "Lê Chuỗi", CHAIN_MANAGER, 2) | Ném StaffDataError(CINEMA) | BR-78; UC-017 4a | EC-240 | Không (đối tượng thuần) | Cao | Unit |
| TC-464 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("mai@cinebook.vn", "Nguyễn Thị Mai", BOX_OFFICE_CLERK, 0) | Ném StaffDataError(CINEMA) | BR-78; UC-017 4b | EC-242 | Không (đối tượng thuần) | Cao | Unit |
| TC-465 | DC-Staff.CheckStaffData | phân vùng tương đương | Không có | CheckStaffData("mai@cinebook.vn", "Nguyễn Thị Mai", giá trị 9, 2) | Ném StaffDataError(ROLE) | BR-79 | EC-243 | Không (đối tượng thuần) | Cao | Unit |
| TC-466 | DC-Staff.CheckStaffData | giá trị biên | Không có | CheckStaffData(email dài đúng 254 ký tự có dạng chuẩn, "Mai", BOX_OFFICE_CLERK, 2) | Trả nil | Q-163 | BV-84 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-467 | DC-Staff.CheckStaffData | giá trị biên | Không có | CheckStaffData(email dài 255 ký tự, "Mai", BOX_OFFICE_CLERK, 2) | Ném StaffDataError(EMAIL) | Q-163 | BV-85 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-468 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | bảng quyết định | Staff 7 ACTIVE, lastChangedAt T0, accessChangedAt A0 | LockStaff(T0, now = T1) | Trả nil; status LOCKED; lastChangedAt = T1; accessChangedAt = T1 | BR-96, BR-97, BR-101; UC-017 1b3 | DT14-R1, EC-244, EC-246 | Không (đối tượng thuần) | Cao | Unit |
| TC-469 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | bảng quyết định | Staff 7 LOCKED, lastChangedAt T1 | LockStaff(T1, T2) | Ném StaffStatusUnchangedError; status vẫn LOCKED; lastChangedAt vẫn T1 | UC-017 1b3a | DT14-R2, EC-247 | Không (đối tượng thuần) | Cao | Unit |
| TC-470 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | bảng quyết định | Staff 7 ACTIVE, lastChangedAt T1 (đã đổi tên sau lúc hiển thị T0) | LockStaff(T0, T2) | Ném StaleStaffError; status vẫn ACTIVE; mốc không đổi | BR-102; UC-017 1b3b | DT14-R3, EC-245 | Không (đối tượng thuần) | Cao | Unit |
| TC-471 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | bảng quyết định | Staff 7 LOCKED, lastChangedAt T1; người gọi giữ mốc T0 (hai yêu cầu khoá cùng lúc, X-32) | LockStaff(T0, T2) | Ném StaffStatusUnchangedError (không phải StaleStaffError) | P08 F4b X-32; P12 F3 LockStaffAccount | DT14-R4 | Không (đối tượng thuần) | Cao | Unit |
| TC-472 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | chuyển trạng thái | Staff 7 LOCKED, lastChangedAt T1, accessChangedAt A1 | UnlockStaff(T1, T2) | Trả nil; status ACTIVE; lastChangedAt = T2; accessChangedAt vẫn A1 | BR-102; ST-12 | EC-244 | Không (đối tượng thuần) | Cao | Unit |
| TC-473 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | chuyển trạng thái | Staff 7 ACTIVE | UnlockStaff(mốc đúng, T2) | Ném StaffStatusUnchangedError; không đổi | UC-017 1c3a | EC-246 | Không (đối tượng thuần) | Cao | Unit |
| TC-474 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | chuyển trạng thái | Staff 7 LOCKED, lastChangedAt T1 | UnlockStaff(T0, T2) | Ném StaleStaffError; vẫn LOCKED | UC-017 1c3b | EC-245 | Không (đối tượng thuần) | Cao | Unit |
| TC-475 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | bảng quyết định | Staff 7 ACTIVE vừa được yêu cầu khác mở khoá (lastChangedAt T2); người gọi giữ mốc T1 | UnlockStaff(T1, T3) | Chưa xác định: chờ Q-354 (trạng thái không đổi hay mốc lệch khi cả hai cùng đúng) | UC-017 1c3a, 1c3b (không nêu thứ tự) | không tính vào độ phủ (chờ Q-354) | Không (đối tượng thuần) | Trung bình | Unit |
| TC-476 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Staff 7 ACTIVE BOX_OFFICE_CLERK cụm rạp 2, lastChangedAt T0, accessChangedAt A0 | SaveStaffChanges(T0, TICKET_CHECKER, 2, T1) | Trả nil; role TICKET_CHECKER; lastChangedAt = T1; accessChangedAt = T1 (đổi vai trò) | BR-101; UC-017 1a | EC-244 | Không (đối tượng thuần) | Cao | Unit |
| TC-477 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Như trên | SaveStaffChanges(T0, BOX_OFFICE_CLERK, 2, T1) (không đổi vai trò và cụm rạp) | Trả nil; lastChangedAt = T1; accessChangedAt vẫn A0 | P12 F2 (chỉ đổi khi role hoặc cinemaId đổi) | EC-244 | Không (đối tượng thuần) | Cao | Unit |
| TC-478 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Như trên | SaveStaffChanges(T0, BOX_OFFICE_CLERK, 3, T1) | Trả nil; cinemaId 3; accessChangedAt = T1 | BR-101 | EC-244 | Không (đối tượng thuần) | Cao | Unit |
| TC-479 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Như trên, lastChangedAt T0 | SaveStaffChanges(T0 - 1 micro giây, TICKET_CHECKER, 2, T1) | Ném StaleStaffError; role, cụm rạp, mốc không đổi | BR-102; UC-017 5b | EC-245 | Không (đối tượng thuần) | Cao | Unit |
| TC-480 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Staff 7 lastChangedAt T0, accessChangedAt A0 | RenameStaff(T0, "Trần Thị Mai", T1) | Trả nil; fullName mới; lastChangedAt = T1; accessChangedAt vẫn A0 | Q-163; UC-017 1d | EC-237 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-481 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Như trên | RenameStaff(T0, "", T1) | Ném StaffDataError(NAME); không đổi | Q-273; UC-017 1d | EC-238 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-482 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Staff 7 lastChangedAt T1 | RenameStaff(T0, "Trần Thị Mai", T2) | Ném StaleStaffError; fullName không đổi | BR-102; UC-017 1d4b | EC-245 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-483 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Staff 7 lastChangedAt T0, accessChangedAt A0 | ResetStaffPassword(T0, "H-new", T1) | Trả nil; passwordHash H-new; lastChangedAt = T1; accessChangedAt vẫn A0 | UC-017 1e | EC-244 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-484 | DC-Staff.LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword | phân vùng tương đương | Như trên | ResetStaffPassword(T0 - 1 micro giây, "H-new", T1) | Ném StaleStaffError; passwordHash không đổi | BR-102; UC-017 1e4a | EC-245 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-485 | DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | use case | Cụm rạp 2 tồn tại; chưa có email mai@cinebook.vn | CreateStaffAccount(req: mai@cinebook.vn, "Nguyễn Thị Mai", BOX_OFFICE_CLERK, cụm rạp 2, mật khẩu Abc@1234) | Trả StaffAccountView ACTIVE; HashPassword 1 lần trước giao dịch; LockValue(STAFF_EMAIL) rồi ExistsByEmail rồi InsertStaff; accessChangedAt = lastChangedAt = now | BR-95, BR-78; UC-017 5 | EC-235 | fake IF-08/13/15, stub IF-07 | Cao | Unit |
| TC-486 | DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | use case | Đã có nhân viên mai@cinebook.vn | CreateStaffAccount(req cùng email) | Ném DuplicateStaffEmailError; không InsertStaff; rollback | BR-95; UC-017 5a; X-31 | EC-235 | fake IF-08/13/15, stub IF-07 | Cao | Unit |
| TC-487 | DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | phân vùng tương đương | Không có | CreateStaffAccount(req: role CUSTOMER) | Ném StaffDataError(ROLE); HashPassword 0 lần | BR-79 | EC-243 | fake IF-08/13/15, stub IF-07 | Trung bình | Unit |
| TC-488 | DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | phân vùng tương đương | Cụm rạp 99 không tồn tại | CreateStaffAccount(req: BOX_OFFICE_CLERK, cụm rạp 99) | Ném NotFoundError; không ghi | P12 F3 bước 4 | EC-241 | fake IF-08/13/15, stub IF-07 | Trung bình | Unit |
| TC-489 | DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | use case | Staff 7 lastChangedAt T1 (yêu cầu khác đã đổi); người gọi giữ T0 | UpdateStaffAccess(7, T0, TICKET_CHECKER, 2) | Ném StaleStaffError; LockStaff (hạng 4) gọi 1 lần; SaveChanges 0 lần; Staff không đổi | BR-102; X-32; UC-017 5b | EC-245 | fake IF-08/15 | Cao | Unit |
| TC-490 | DC-ManageStaffAccountsService.CreateStaffAccount, UpdateStaffAccess | use case | Staff 7 BOX_OFFICE_CLERK cụm rạp 2, lastChangedAt T0 | UpdateStaffAccess(7, T0, TICKET_CHECKER, 2) | Trả StaffAccountView role TICKET_CHECKER; accessChangedAt = now; SeatHold của Staff 7 không bị gọi (BR-100) | BR-100, BR-101; UC-017 1a | EC-244 | fake IF-08/15 | Cao | Unit |
| TC-491 | DC-Customer.CheckOwnsBooking | phân vùng tương đương | Khách 7; Booking của khách 7 | CheckOwnsBooking(booking) | Trả nil | BR-94 | EC-248 | Không (đối tượng thuần) | Cao | Unit |
| TC-492 | DC-Customer.CheckOwnsBooking | phân vùng tương đương | Khách 7; Booking của khách 8 | CheckOwnsBooking(booking) | Ném BookingNotOwnedError | BR-94; UC-007 3a | EC-249 | Không (đối tượng thuần) | Cao | Unit |
| TC-493 | DC-Customer.CheckOwnsBooking | phân vùng tương đương | Khách 7; Booking mua tại quầy (customerId rỗng) | CheckOwnsBooking(booking) | Ném BookingNotOwnedError | BR-94; Q-322 | EC-250 | Không (đối tượng thuần) | Cao | Unit |
| TC-494 | DC-Ticket.Snapshot | phân vùng tương đương | Vé bán với snap (phim "Dune", cụm rạp "Q1", phòng "P7", loại 2D); sau đó dữ liệu nguồn đổi tên phim thành "Dune 2" | Snapshot() | Trả đúng (Dune, Q1, P7, 2D); không đổi theo dữ liệu nguồn | BR-140 | EC-251 | Không (đối tượng thuần) | Cao | Unit |
| TC-495 | DC-Booking.Summary | phân vùng tương đương | Booking BK1 gồm 2 vé, snapshot phim Dune, cụm rạp Q1, bookedAt 10:05 | Summary(startTime = 20:00) | Trả BookingSummary{mã BK1, số vé 2, phim Dune, cụm rạp Q1, giờ 20:00, bookedAt 10:05} | BR-94, BR-140 | EC-251 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-496 | DC-ViewBookingHistoryService.ListHistory | use case | Khách 7 có 3 lần đặt lúc 09:00, 11:00, 10:00 | ListHistory(7) | Trả 3 phần tử theo bookedAt giảm dần: 11:00, 10:00, 09:00; chỉ lần đặt của khách 7; Do dùng ReadTx | UC-007; BR-94 | EC-252 | fake IF-08/20 | Cao | Unit |
| TC-497 | DC-ViewBookingHistoryService.ListHistory | use case | Khách 7 chưa có lần đặt | ListHistory(7) | Trả danh sách rỗng, không lỗi | UC-007 luồng thay thế rỗng | EC-252 | fake IF-08/20 | Cao | Unit |
| TC-498 | DC-ViewBookingHistoryService.FindBookingTickets | use case | Booking BK2 thuộc khách 8 | FindBookingTickets(7, BK2) | Ném BookingNotOwnedError; không trả vé | BR-94 | EC-249 | fake IF-08/16/20 | Cao | Unit |
| TC-499 | DC-ViewBookingHistoryService.FindBookingTickets | use case | Không có lần đặt mã BK-X | FindBookingTickets(7, BK-X) | Ném NotFoundError | P12 F3 | EC-248 | fake IF-08/16/20 | Trung bình | Unit |
| TC-500 | DC-ViewBookingHistoryService.FindBookingTickets | use case | Booking BK1 của khách 7, 2 vé, một vé CANCELLED có yêu cầu hoàn | FindBookingTickets(7, BK1) | Trả BookingView 2 vé với snapshot lúc bán, giá, trạng thái và tình trạng hoàn tiền | UC-007; BR-140 | EC-248 | fake IF-08/16/20 | Cao | Unit |
| TC-501 | DC-BookTicketsService.FindActiveHold | giá trị biên | Khách 7 có H1 ACTIVE expiry 10:10:00.000 giữ 101, 102 (90.000 mỗi ghế); now = 10:09:59.999 | FindActiveHold(khách 7) | Trả (HoldResult{ref, expiry 10:10:00.000, 2 ghế, tổng 180.000, holdStatus ACTIVE, serverTime 10:09:59.999}, true, nil) | UC-005; BR-04 | EC-253, BV-90 | fake IF-08/17/18 | Cao | Unit |
| TC-502 | DC-BookTicketsService.FindActiveHold | giá trị biên | Như trên; now = 10:10:00.000 | FindActiveHold(khách 7) | Trả (HoldResult{}, false, nil) | BR-10 | EC-254, BV-91 | fake IF-08/17/18 | Cao | Unit |
| TC-503 | DC-BookTicketsService.FindActiveHold | phân vùng tương đương | Khách 9 không có lần giữ ghế | FindActiveHold(khách 9) | Trả (HoldResult{}, false, nil), không lỗi | UC-005 | EC-255 | fake IF-08/17/18 | Trung bình | Unit |
| TC-504 | DC-BookTicketsService.GetHold | phân vùng tương đương | H1 của khách 7 ACTIVE, now = 10:10:30 (quá hạn, chưa có thao tác ghi) | GetHold(ref-1, khách 7) | Trả HoldResult holdStatus = ACTIVE (không tự ghi EXPIRED), serverTime 10:10:30; Do dùng ReadOnlyTx; UpdateStatus 0 lần | P12 F3 GetHold | EC-254 | fake IF-08/17/18 | Cao | Unit |
| TC-505 | DC-BookTicketsService.GetHold | phân vùng tương đương | H1 COMPLETED, Booking BK1 | GetHold(ref-1, khách 7) | Trả holdStatus COMPLETED, bookingCode BK1 | P12 F3 GetHold | EC-257 | fake IF-08/17/18/20 | Trung bình | Unit |
| TC-506 | DC-BookTicketsService.GetHold | phân vùng tương đương | H1 của khách 7 | GetHold(ref-1, khách 8) | Ném NotFoundError; không lộ sự tồn tại | Q-147 | EC-256 | fake IF-08/17/18 | Cao | Unit |
| TC-507 | DC-BookTicketsService.GetHold | phân vùng tương đương | Không có holdRef ref-9 | GetHold(ref-9, khách 7) | Ném NotFoundError | P12 F3 | EC-256 | fake IF-08/17/18 | Trung bình | Unit |
| TC-508 | DC-CancelTicketService.PrepareCashRefund | use case | Vé TK2 mua tại quầy cụm rạp 2 UNUSED giá 100.000; Showtime 55 bắt đầu 20:00 cụm rạp 2; tx.Now = 18:00:00.000; clerk 4 cụm rạp 2 | PrepareCashRefund(TK2, clerk 4) | Trả CashRefundView số tiền hoàn 70.000; không ghi gì; Acquire 0 lần | BR-17, BR-18, BR-31; UC-008 bước 1 đến 3 | BV-90 | fake IF-08/11/20 | Cao | Unit |
| TC-509 | DC-CancelTicketService.PrepareCashRefund | use case | Vé TK1 mua trực tuyến | PrepareCashRefund(TK1, clerk 4) | Ném ChannelMismatchError; không ghi | BR-17; UC-008 2a | EC-256 | fake IF-08/11/20 | Cao | Unit |
| TC-510 | DC-CancelTicketService.PrepareCashRefund | use case | Vé TK2 quầy của cụm rạp 3; clerk 4 cụm rạp 2 | PrepareCashRefund(TK2, clerk 4) | Ném ChannelMismatchError (UC-008 2c); không ghi | BR-02, BR-17; UC-008 2c | EC-256 | fake IF-08/11/20 | Cao | Unit |
| TC-511 | DC-CancelTicketService.PrepareCashRefund | use case | Vé TK2 quầy đã CANCELLED | PrepareCashRefund(TK2, clerk 4) | Ném TicketStateError mang CANCELLED | BR-21; UC-008 4a | EC-256 | fake IF-08/11/20 | Cao | Unit |
| TC-512 | DC-CancelTicketService.PrepareCashRefund | giá trị biên | Vé TK2 quầy UNUSED; now = 18:00:00.001 (còn dưới 2 giờ) | PrepareCashRefund(TK2, clerk 4) | Ném CancelDeadlineError | BR-18, BR-32; UC-008 3a | BV-91 | fake IF-08/11/20 | Cao | Unit |
| TC-513 | DC-Movie.CheckWithinRunPeriod | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 (Asia/Ho_Chi_Minh) | CheckWithinRunPeriod(2026-11-05 00:00:00 +07:00) | Trả nil | BR-49; Q-268 | BV-92 | Không (đối tượng thuần) | Cao | Unit |
| TC-514 | DC-Movie.CheckWithinRunPeriod | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 (Asia/Ho_Chi_Minh) | CheckWithinRunPeriod(2026-11-04 23:59:59.999 +07:00) | Ném OutsideRunPeriodError | BR-49; Q-268 | BV-93 | Không (đối tượng thuần) | Cao | Unit |
| TC-515 | DC-Movie.CheckWithinRunPeriod | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 (Asia/Ho_Chi_Minh) | CheckWithinRunPeriod(2026-11-20 23:59:59.999 +07:00) | Trả nil | BR-49; Q-268 | BV-94 | Không (đối tượng thuần) | Cao | Unit |
| TC-516 | DC-Movie.CheckWithinRunPeriod | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 (Asia/Ho_Chi_Minh) | CheckWithinRunPeriod(2026-11-21 00:00:00 +07:00) | Ném OutsideRunPeriodError | BR-49; Q-268 | BV-95 | Không (đối tượng thuần) | Cao | Unit |
| TC-517 | DC-Movie.CheckWithinRunPeriod | giá trị biên | Như trên | CheckWithinRunPeriod(2026-11-20 17:00:00Z, tức 2026-11-21 00:00 +07:00) | Ném OutsideRunPeriodError (ngày tính theo múi giờ Asia/Ho_Chi_Minh, không theo UTC) | BR-49; Q-268 | EC-259 | Không (đối tượng thuần) | Cao | Unit |
| TC-518 | DC-Movie.CheckReleasedInFormat | phân vùng tương đương | Movie releaseFormats = {2D, 3D} | CheckReleasedInFormat(2D) | Trả nil | BR-47 | EC-260 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-519 | DC-Movie.CheckReleasedInFormat | phân vùng tương đương | Như trên | CheckReleasedInFormat(IMAX) | Ném FormatNotReleasedError | BR-47 | EC-261 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-520 | DC-Movie.RunStatusAt | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 | RunStatusAt(2026-11-04) | Trả COMING_SOON | BR-76 | EC-259 | Không (đối tượng thuần) | Cao | Unit |
| TC-521 | DC-Movie.RunStatusAt | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 | RunStatusAt(2026-11-05) | Trả NOW_SHOWING | BR-76 | EC-258 | Không (đối tượng thuần) | Cao | Unit |
| TC-522 | DC-Movie.RunStatusAt | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 | RunStatusAt(2026-11-20) | Trả NOW_SHOWING (ngày kết thúc vẫn thuộc khoảng chiếu) | BR-76 | EC-258 | Không (đối tượng thuần) | Cao | Unit |
| TC-523 | DC-Movie.RunStatusAt | giá trị biên | Movie releaseDate 2026-11-05, endOfRunDate 2026-11-20 | RunStatusAt(2026-11-21) | Trả ENDED | BR-76 | EC-259 | Không (đối tượng thuần) | Cao | Unit |
| TC-524 | DC-Auditorium.CheckRoomGap | giá trị biên | Phòng 7 có suất S1 kết thúc 18:00:00.000; draft bắt đầu 18:15:00.000 | CheckRoomGap(draft, [S1], 0) | Trả nil (đúng 15 phút là hợp lệ) | BR-51 | BV-96, EC-262 | Không (đối tượng thuần) | Cao | Unit |
| TC-525 | DC-Auditorium.CheckRoomGap | giá trị biên | Như trên; draft bắt đầu 18:14:59 | CheckRoomGap(draft, [S1], 0) | Ném RoomGapError | BR-51 | BV-97, EC-263 | Không (đối tượng thuần) | Cao | Unit |
| TC-526 | DC-Auditorium.CheckRoomGap | phân vùng tương đương | Phòng 7 có suất S2 bắt đầu 21:00; draft kết thúc 20:45 | CheckRoomGap(draft, [S2], 0) | Trả nil (suất sau cách đúng 15 phút) | BR-51 | EC-262 | Không (đối tượng thuần) | Cao | Unit |
| TC-527 | DC-Auditorium.CheckRoomGap | phân vùng tương đương | Phòng 7 có suất S1 18:00 đến 20:00; draft 19:00 đến 21:00 | CheckRoomGap(draft, [S1], 0) | Ném RoomGapError (giao nhau) | BR-51 | EC-263 | Không (đối tượng thuần) | Cao | Unit |
| TC-528 | DC-Auditorium.CheckRoomGap | phân vùng tương đương | Phòng 7 có suất S1 18:00 đến 20:00; sửa chính S1 thành 18:30 đến 20:30 (excludeId = S1) | CheckRoomGap(draft, [S1], S1) | Trả nil (bỏ chính suất đang sửa) | BR-51; UC-014 sửa | EC-262 | Không (đối tượng thuần) | Cao | Unit |
| TC-529 | DC-Auditorium.CheckRoomGap | phân vùng tương đương | Phòng 7 có suất S1 đã xoá 18:00 đến 20:00 | CheckRoomGap(draft 19:00 đến 21:00, [S1 đã xoá], 0) | Trả nil (suất đã xoá không tính) | BR-51; BR-58 | EC-262 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-530 | DC-Auditorium.CheckSupportsFormat | phân vùng tương đương | Phòng formats {2D} | CheckSupportsFormat(2D) | Trả nil | BR-48 | EC-260 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-531 | DC-Auditorium.CheckSupportsFormat | phân vùng tương đương | Phòng formats {2D} | CheckSupportsFormat(3D) | Ném FormatNotSupportedError | BR-48 | EC-261 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-532 | DC-Auditorium.CheckNeverScheduled | phân vùng tương đương | Phòng 7 | CheckNeverScheduled(false) | Trả nil | BR-147 | EC-268 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-533 | DC-Auditorium.CheckNeverScheduled | phân vùng tương đương | Phòng 7 từng có suất chiếu đã xoá | CheckNeverScheduled(true) | Ném AuditoriumHasScheduleError | BR-147; X-28 | EC-269 | Không (đối tượng thuần) | Cao | Unit |
| TC-534 | DC-Showtime.CheckNotStarted | giá trị biên | Showtime bắt đầu 2026-11-10 20:00:00.000 | CheckNotStarted(now = 20:00:00.000) | Ném ShowtimeStartedError (bằng đúng thời điểm kiểm tra là đã qua) | BR-56, BR-57 | BV-98, EC-265 | Không (đối tượng thuần) | Cao | Unit |
| TC-535 | DC-Showtime.CheckNotStarted | giá trị biên | Showtime bắt đầu 20:00:00.000 | CheckNotStarted(now = 19:59:59.999) | Trả nil | BR-56, BR-57 | BV-99, EC-264 | Không (đối tượng thuần) | Cao | Unit |
| TC-536 | DC-Showtime.CheckRoomChangeAllowed | phân vùng tương đương | Showtime ở phòng 7, từng có vé | CheckRoomChangeAllowed(7, true) | Trả nil (không đổi phòng) | BR-92 | EC-266 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-537 | DC-Showtime.CheckRoomChangeAllowed | phân vùng tương đương | Showtime ở phòng 7, chưa từng có vé | CheckRoomChangeAllowed(8, false) | Trả nil | BR-92 | EC-266 | Không (đối tượng thuần) | Cao | Unit |
| TC-538 | DC-Showtime.CheckRoomChangeAllowed | phân vùng tương đương | Showtime ở phòng 7, mọi vé đã huỷ (từng có vé) | CheckRoomChangeAllowed(8, true) | Ném RoomChangeNotAllowedError | BR-92; X-19 | EC-267 | Không (đối tượng thuần) | Cao | Unit |
| TC-539 | DC-Cinema.NormalizeName | phân vùng tương đương | Không có | NormalizeName("  CineBook   Quận  1 ") | Trả "cinebook quận 1" (cắt đầu cuối, gộp khoảng trắng, chữ thường) | BR-141; Q-266 | EC-270 | Không (đối tượng thuần) | Cao | Unit |
| TC-540 | DC-Cinema.CheckNameNotTaken | phân vùng tương đương | Cụm rạp 3 | CheckNameNotTaken(nil) | Trả nil | BR-141 | EC-270 | Không (đối tượng thuần) | Cao | Unit |
| TC-541 | DC-Cinema.CheckNameNotTaken | phân vùng tương đương | Cụm rạp 3 | CheckNameNotTaken(chính cụm rạp 3) | Trả nil (sửa giữ nguyên tên) | BR-141 | EC-271 | Không (đối tượng thuần) | Cao | Unit |
| TC-542 | DC-Cinema.CheckNameNotTaken | phân vùng tương đương | Cụm rạp 3 | CheckNameNotTaken(cụm rạp 4 cùng tên chuẩn hoá) | Ném CinemaNameTakenError | BR-141; UC-011 5b; X-26 | EC-272 | Không (đối tượng thuần) | Cao | Unit |
| TC-543 | DC-Cinema.NormalizeName, CheckNameNotTaken, CheckUnchangedSinceDisplayed | giá trị biên | Cinema 3 lastChangedAt T0 | CheckUnchangedSinceDisplayed(T0) | Trả nil | BR-142 | EC-273 | Không (đối tượng thuần) | Cao | Unit |
| TC-544 | DC-Cinema.NormalizeName, CheckNameNotTaken, CheckUnchangedSinceDisplayed | giá trị biên | Cinema 3 lastChangedAt T0 + 1 micro giây | CheckUnchangedSinceDisplayed(T0) | Ném CinemaChangedError | BR-142; X-26 | EC-274 | Không (đối tượng thuần) | Cao | Unit |
| TC-545 | DC-Movie.CheckUnchangedSinceDisplayed | giá trị biên | Movie 5 lastChangedAt T0 + 1 micro giây | CheckUnchangedSinceDisplayed(T0) | Ném MovieChangedError | BR-138; X-24 | EC-274 | Không (đối tượng thuần) | Cao | Unit |
| TC-546 | DC-Auditorium.CheckUnchangedSinceDisplayed | giá trị biên | Auditorium 7 lastChangedAt T0 + 1 micro giây | CheckUnchangedSinceDisplayed(T0) | Ném AuditoriumChangedError | BR-146; X-29 | EC-274 | Không (đối tượng thuần) | Cao | Unit |
| TC-547 | DC-ReportPeriod.CheckValid | phân vùng tương đương | Không có | CheckValid(từ 2026-11-01, đến 2026-11-30) | Trả nil | GL-66 | EC-275 | Không (đối tượng thuần) | Cao | Unit |
| TC-548 | DC-ReportPeriod.CheckValid | giá trị biên | Không có | CheckValid(từ 2026-11-15, đến 2026-11-15) | Trả nil | GL-66 | BV-100 | Không (đối tượng thuần) | Cao | Unit |
| TC-549 | DC-ReportPeriod.CheckValid | giá trị biên | Không có | CheckValid(từ 2026-11-16, đến 2026-11-15) | Ném InvalidPeriodError(FROM_AFTER_TO) | UC-015 1a | BV-101, EC-278 | Không (đối tượng thuần) | Cao | Unit |
| TC-550 | DC-ReportPeriod.CheckValid | phân vùng tương đương | Không có | CheckValid(từ rỗng, đến 2026-11-15) | Ném InvalidPeriodError(MISSING_FROM) | UC-015 1a | EC-276 | Không (đối tượng thuần) | Cao | Unit |
| TC-551 | DC-ReportPeriod.CheckValid | phân vùng tương đương | Không có | CheckValid(từ 2026-11-01, đến rỗng) | Ném InvalidPeriodError(MISSING_TO) | UC-015 1a | EC-277 | Không (đối tượng thuần) | Cao | Unit |
| TC-552 | DC-ReportPeriod.CheckValid | bảng quyết định | Không có | CheckValid(từ rỗng, đến rỗng) | Ném InvalidPeriodError(MISSING_FROM) (thứ tự MISSING_FROM trước MISSING_TO) | P12 F2 (thứ tự) | EC-276 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-553 | DC-ReportPeriod.ToRange | giá trị biên | Kỳ 2026-11-01 đến 2026-11-30 | ToRange(Asia/Ho_Chi_Minh) | Trả start = 2026-11-01 00:00:00 +07:00, end = 2026-12-01 00:00:00 +07:00 (nửa mở: ghế bán 2026-11-30 23:59:59.999 thuộc kỳ, 2026-12-01 00:00 không thuộc) | GL-66; P09 F7.12 | EC-275 | Không (đối tượng thuần) | Cao | Unit |
| TC-554 | DC-ReportPeriod.ToRange | giá trị biên | Kỳ 2026-11-15 đến 2026-11-15 | ToRange(Asia/Ho_Chi_Minh) | Trả khoảng đúng 24 giờ: 2026-11-15 00:00 +07:00 đến 2026-11-16 00:00 +07:00 | GL-66 | BV-100 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-555 | DC-ReportGroup.OccupancyPercent, AddFigures | phân vùng tương đương | Nhóm sức chứa 0, đã bán 0 | OccupancyPercent() | Trả (0, false) (không áp dụng, không chia cho 0) | BR-88; Q-235 | EC-279 | Không (đối tượng thuần) | Cao | Unit |
| TC-556 | DC-ReportGroup.OccupancyPercent, AddFigures | giá trị biên | Nhóm sau AddFigures(doanh thu 90.000, bán 1, sức chứa 1) | OccupancyPercent() | Trả (100, true) | BR-88 | BV-102 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-557 | DC-ReportGroup.OccupancyPercent, AddFigures | phân vùng tương đương | Nhóm trống | AddFigures(120.000 đồng, bán 2, sức chứa 100) rồi AddFigures(90.000, bán 1, sức chứa 50) | Doanh thu 210.000; ghế bán 3; sức chứa 150; OccupancyPercent = (2, true) | BR-88 | EC-280 | Không (đối tượng thuần) | Cao | Unit |
| TC-558 | DC-ViewCinemaReportService.ViewCinemaReport | use case | Không có | ViewCinemaReport(cụm rạp 2, kỳ từ 11-16 đến 11-15) | Ném InvalidPeriodError; Do 0 lần; IF-28 0 lần | UC-015 1a | EC-278 | fake IF-08/28 | Cao | Unit |
| TC-559 | DC-ViewCinemaReportService.ViewCinemaReport | use case | IF-28 trả danh sách rỗng cho cụm rạp 2 | ViewCinemaReport(2, kỳ 2026-11-01 đến 2026-11-30) | Trả CinemaReport rỗng (IsEmpty = true); Do dùng ReportTx; q.start = 2026-11-01 00:00 +07:00 | UC-015 2a; Q-236 | EC-275 | fake IF-08/28 | Cao | Unit |
| TC-560 | DC-ViewCinemaReportService.ViewCinemaReport | use case | IF-28 trả 2 dòng cùng khoá nhóm G1 (doanh thu 100.000 bán 2 sức chứa 40 và 50.000 bán 1 sức chứa 10) và 1 dòng G2 (0 đồng, bán 0, sức chứa 0) | ViewCinemaReport(2, kỳ hợp lệ) | Trả 2 nhóm theo thứ tự của IF-28: G1 doanh thu 150.000, bán 3, sức chứa 50, lấp đầy 6%; G2 doanh thu 0, bán 0, lấp đầy không áp dụng | BR-88; UC-015 | EC-280, EC-279 | fake IF-08/28 | Cao | Unit |
| TC-561 | DC-BrowseShowtimesService.selectShowtimes | giá trị biên | now = 2026-11-10 19:00:00.000; S1 bắt đầu 19:00:00.000 và S2 bắt đầu 19:00:00.001, cùng IN_SCHEDULE | selectShowtimes([S1, S2], tiêu chí rỗng, now) | Trả [S2] (S1 bằng now bị loại) | BR-56 | BV-103, BV-104, EC-284, EC-282 | Không (đối tượng thuần) | Cao | Unit |
| TC-562 | DC-BrowseShowtimesService.selectShowtimes | phân vùng tương đương | S3 status DELETED bắt đầu sau now | selectShowtimes([S3], tiêu chí rỗng, now) | Trả danh sách rỗng | BR-58 | EC-283 | Không (đối tượng thuần) | Cao | Unit |
| TC-563 | DC-BrowseShowtimesService.selectShowtimes | phân vùng tương đương | S1 (TP.HCM, 2D, STANDARD) và S4 (Hà Nội, 3D, IMAX) đều sau now | selectShowtimes([S1, S4], {province TP.HCM, format 2D}, now) | Trả [S1]; giữ thứ tự đầu vào | P12 F3 | EC-281 | Không (đối tượng thuần) | Cao | Unit |
| TC-564 | DC-BrowseShowtimesService.selectShowtimes | giá trị biên | S5 bắt đầu 2026-11-10 17:00:00Z (00:00 ngày 11 +07:00) | selectShowtimes([S5], {date 2026-11-10}, now) rồi {date 2026-11-11} | Lần một trả rỗng; lần hai trả [S5] | Q-151; P12 F3 | BV-105, EC-285 | Không (đối tượng thuần) | Cao | Unit |
| TC-565 | DC-BrowseShowtimesService.selectShowtimes | phân vùng tương đương | infos rỗng | selectShowtimes([], tiêu chí rỗng, now) | Trả rỗng (ShowtimeListing.IsEmpty) | UC-004 4a, 1a4a | EC-284 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-566 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(StaffAccessRevokedError, scope BOOKING) | Trả 401, code SESSION_INVALID, messageId MSG-85 | P12 F2b | EC-286 | Không (đối tượng thuần) | Cao | Unit |
| TC-567 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(StaffAccessChangedError (từ HoldSeats), scope BOOKING) | Trả 401, code SESSION_INVALID, messageId MSG-85 | P12 F2b | EC-286 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-568 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(LoginFailedError, scope ACCOUNT) | Trả 401, code LOGIN_FAILED | P12 F2b | EC-286 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-569 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(StaffLockedError, scope ACCOUNT) | Trả 403, code STAFF_LOCKED, messageId MSG-87 | P12 F2b | EC-287 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-570 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(ChannelMismatchError(reason của UC-008 2c), scope TICKET) | Trả 403, code CHANNEL_MISMATCH, detail.reason giữ nguyên | P12 F2b | EC-287 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-571 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(NotFoundError, scope BOOKING) | Trả 404, code NOT_FOUND | P12 F2b | EC-288 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-572 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(HolderBusyError, scope BOOKING) | Trả 409, code HOLDER_BUSY, messageId MSG-09 | P12 F2b | EC-289 | Không (đối tượng thuần) | Cao | Unit |
| TC-573 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(SeatUnavailableError(seatIds [102]), scope BOOKING) | Trả 409, code SEAT_UNAVAILABLE, messageId MSG-11, detail.seatIds [102] | P12 F2b | EC-289 | Không (đối tượng thuần) | Cao | Unit |
| TC-574 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(SeatUnavailableError(BEING_RELEASED), scope BOOKING) | Trả 409, code SEAT_UNAVAILABLE, messageId MSG-82 | P12 F2b | EC-289 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-575 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(HoldNotActiveError(EXPIRED), scope BOOKING) | Trả 409, code HOLD_NOT_ACTIVE, detail.holdStatus EXPIRED | P12 F2b | EC-289 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-576 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(StaleStaffError, scope ACCOUNT) | Trả 409, code STALE_STAFF, messageId MSG-120 | P12 F2b | EC-289 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-577 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(SeatSelectionError(TOO_MANY), scope BOOKING) | Trả 422, code SEAT_SELECTION_INVALID, messageId MSG-10, detail.reason TOO_MANY | P12 F2b | EC-290 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-578 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(RegistrationDataError(PHONE), scope ACCOUNT) | Trả 422, code REGISTRATION_DATA_INVALID, detail.field PHONE | P12 F2b | EC-290 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-579 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(SystemBusyError, scope BOOKING) | Trả 503, code SYSTEM_BUSY, messageId MSG-72 | P12 F2b | EC-291 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-580 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(context.DeadlineExceeded, scope BOOKING) | Trả 503, code SYSTEM_BUSY | P12 F2b | EC-291 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-581 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(LockOrderViolationError, scope BOOKING) | Trả 500, code INTERNAL, messageId MSG-72; chi tiết không đưa vào body | P12 F2b | EC-292 | Không (đối tượng thuần) | Cao | Unit |
| TC-582 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(LinkMismatchError (lỗi lập trình), scope BOOKING) | Trả 500, code INTERNAL (đây là kết quả hiện hành của ConfirmCashReceived trên lần giữ ghế đã huỷ, xem Q-352) | P12 F2b | EC-292 | Không (đối tượng thuần) | Cao | Unit |
| TC-583 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(errors.New("x"), scope BOOKING) | Trả 500, code INTERNAL | P12 F2b | EC-292 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-584 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(fmt.Errorf("giữ ghế: %w", HolderBusyError), scope BOOKING) | Trả 409, code HOLDER_BUSY (errors.As qua lớp bọc) | P12 F2b | EC-294 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-585 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(ShowtimeChangedError, BOOKING) | Trả 409, code SHOWTIME_CHANGED, messageId MSG-12 | P12 F2b | EC-293 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-586 | DC-HttpErrorMapper.Classify | phân vùng tương đương | Không có | Classify(ShowtimeChangedError, SCHEDULE) | Trả 409, code SHOWTIME_CHANGED, messageId MSG-68 | P12 F2b | EC-293 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-587 | DC-AuthFilter.Require | use case | Phiên khách 7 hợp lệ; allowed = [CUSTOMER] | Require([CUSTOMER], next) nhận yêu cầu có mã phiên hợp lệ | next được gọi 1 lần với caller{id 7, role CUSTOMER}; ngữ cảnh có deadline 14 giây | UC-005 5a; P12 F3 | EC-286 | stub IF-07, mock next | Cao | Unit |
| TC-588 | DC-AuthFilter.Require | phân vùng tương đương | Không có mã phiên | Require([CUSTOMER], next) nhận yêu cầu không có mã phiên | Trả 401 SESSION_INVALID MSG-85; next 0 lần | P12 F2b | EC-286 | stub IF-07, mock next | Cao | Unit |
| TC-589 | DC-AuthFilter.Require | phân vùng tương đương | VerifySession trả SessionExpiredError | Require([CUSTOMER], next) với mã phiên hết hạn | Trả 401 SESSION_INVALID; next 0 lần | Q-154 | EC-286 | stub IF-07, mock next | Cao | Unit |
| TC-590 | DC-AuthFilter.Require | phân vùng tương đương | Phiên khách 7 hợp lệ; allowed = [BOX_OFFICE_CLERK] | Require([BOX_OFFICE_CLERK], next) | Trả 403 FORBIDDEN_ROLE; next 0 lần | P12 F2b | EC-287 | stub IF-07, mock next | Cao | Unit |
| TC-591 | DC-AuthFilter.Require | use case | Phiên nhân viên 3 hợp lệ về chữ ký; CheckStaffAccess ném StaffAccessRevokedError (đã khoá hoặc đổi quyền) | Require([BOX_OFFICE_CLERK], next) | Trả 401 SESSION_INVALID MSG-85; next 0 lần | BR-101 | EC-286 | stub IF-07/AccessCheck, mock next | Cao | Unit |
| TC-592 | DC-AuthFilter.Require | use case | Mã phiên ghi BOX_OFFICE_CLERK nhưng dòng Staff hiện là CINEMA_MANAGER (mốc vẫn khớp); allowed = [BOX_OFFICE_CLERK] | Require([BOX_OFFICE_CLERK], next) | Trả 403 FORBIDDEN_ROLE (phân quyền theo vai trò hiện hành do CheckStaffAccess trả, không theo mã phiên); next 0 lần | P12 F2 CheckRole; BR-101 | EC-287 | stub IF-07/AccessCheck, mock next | Cao | Unit |
| TC-593 | IF-07.HashPassword, CheckRole, IssueSession, VerifySession | phân vùng tương đương | Bộ băm của hệ thống | HashPassword("Abc@1234") hai lần | Hai mã băm khác nhau; VerifyPassword("Abc@1234", từng mã) = true cho cả hai; không chứa chuỗi gốc | NFR-01 | EC-295 | driver IF-07 | Trung bình | Unit |
| TC-594 | IF-07.HashPassword, CheckRole, IssueSession, VerifySession | phân vùng tương đương | Không có | CheckRole(CUSTOMER, [CUSTOMER, BOX_OFFICE_CLERK]) | Trả true | P12 F2 | EC-296 | driver IF-07 | Trung bình | Unit |
| TC-595 | IF-07.HashPassword, CheckRole, IssueSession, VerifySession | phân vùng tương đương | Không có | CheckRole(CUSTOMER, [BOX_OFFICE_CLERK]) | Trả false | P12 F2 | EC-297 | driver IF-07 | Trung bình | Unit |
| TC-596 | IF-07.HashPassword, CheckRole, IssueSession, VerifySession | phân vùng tương đương | now = 2026-11-10 08:00:00; A1 = 2026-11-10 07:00:00.000001 | IssueSession("3", STAFF, BOX_OFFICE_CLERK, "2", A1) rồi VerifySession(token) lúc 08:30 | Claims{subjectId "3", subjectKind STAFF, role BOX_OFFICE_CLERK, cinemaId "2", accessChangedAt Equal A1 (giữ micro giây), expiresAt 16:00:00} | BR-101; Q-267 | EC-298 | driver IF-07, stub đồng hồ | Cao | Unit |
| TC-597 | IF-07.HashPassword, CheckRole, IssueSession, VerifySession | phân vùng tương đương | now = 08:00:00 | IssueSession("7", CUSTOMER, CUSTOMER, "", nil) rồi VerifySession | Claims accessChangedAt rỗng (nil), subjectKind CUSTOMER | Q-267 | EC-298 | driver IF-07, stub đồng hồ | Trung bình | Unit |
| TC-598 | DC-PgOutboxStore.ExtendClaim, DC-RefundService.ProcessRefund | tích hợp đồng thời | Dòng outbox REFUND_GATEWAY E1 được bản 1 nhận (claim_token TOK1); bản 2 đọc cùng dòng sau khi claim của bản 1 hết hạn và nhận lại (TOK2) | Bản 1 gọi ExtendClaim với TOK1 sau khi bản 2 đã đổi sang TOK2; sau đó cả hai ghi MarkSucceeded | ExtendClaim của bản 1 trả 0 dòng: ClaimLostError, rollback giao dịch 1, cổng giả 0 lời gọi từ bản 1; MarkSucceeded có điều kiện claim_token nên bản 1 không đóng dòng của bản 2; đúng một lời gọi RequestRefund cho refundKey | BR-43; Bảng hỏng mục 3, 5; P09 F7.7 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-599 | DC-BookTicketsService.HoldSeats, DC-PgTicketingStore.SaveChanges | tích hợp đồng thời | Khách 7 có H0 ACTIVE quá hạn giữ ghế 101 (job chưa quét); ghế 101 HELD bởi H0 | HoldSeats ghế [101, 102] của khách 7 (chọn lại đúng ghế cũ); lặp thêm phiên bản gộp một UPDATE đổi current_hold_id từ H0 sang H1 do harness chạy trực tiếp | HoldSeats thành công bằng hai SaveChanges (Trống rồi giữ lại), không check_violation; UPDATE trực tiếp từ H0 sang H1 bị trg_seat_status_link từ chối; seat_event có một dòng Trống và một dòng Đang giữ cho ghế 101, thứ tự event_seq tăng | P13 trg_seat_status_link; P12 F3 HoldSeats (g); X-13 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-600 | DC-HoldSettlement.End, DC-BookTicketsService.CancelHold, DC-PaymentReportService.HandleIpn | tích hợp đồng thời | H1 ACTIVE giữ ghế 101, 102; PT1 PENDING | Thứ tự A: CancelHold giữ khoá hạng 5 trước. Thứ tự B: IPN thành công giữ khoá hạng 5 trước. Lặp 1.000 lần mỗi thứ tự | A: H1 CANCELLED, ghế AVAILABLE trong cùng commit, IPN sau đó là thanh toán trễ (LATE_PAYMENT, hoàn toàn bộ). B: H1 COMPLETED, ghế SOLD, CancelHold nhận HoldNotActiveError(COMPLETED). Không có ghế kẹt HELD với lần giữ ghế đã kết thúc; không 40P01 | X-10, X-12, X-22; BR-85, BR-86 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-601 | DC-BookTicketsService.ConfirmCashReceived | tích hợp đồng thời | H1 của nhân viên quầy 3 ACTIVE giữ ghế 101 | Hai ConfirmCashReceived cùng H1 đồng thời (nhân viên bấm hai lần), sau barrier | Đúng một Booking và một vé; lần còn lại nhận HoldNotActiveError(COMPLETED) theo F2 và BR-86. Kết quả hiện hành theo F3 là LinkMismatchError (HTTP 500): ca này thất bại cho tới khi Q-352 được xử lý | BR-86; EX-03; Q-352 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-602 | DC-ManageSchedule (EX-13), P13 EXCLUDE suất chiếu | tích hợp đồng thời | Phòng 7 trống từ 18:00; hai quản lý cụm rạp cùng phòng | Hai yêu cầu lập suất chiếu cho phòng 7: A 18:00 đến 20:00, B 19:00 đến 21:00 (giao nhau) đồng thời; biến thể B 20:10 (cách 10 phút); biến thể B 20:15 (đúng 15 phút) | Giao nhau và cách 10 phút: đúng một yêu cầu thành công, bên kia RoomGapError hoặc từ chối theo mốc (X-07); không có 23505 hay lỗi EXCLUDE lọt ra ngoài; đúng 15 phút: cả hai thành công | BR-51; BR-52, BR-60; X-07, X-19 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-603 | Movie save (EX-16) | tích hợp đồng thời | Phim 5 hiển thị mốc T0 cho hai quản lý chuỗi | Hai SaveMovieChanges cùng displayedAt T0 đồng thời; thứ tự A rồi B và B rồi A | Đúng một thành công, bên sau MovieChangedError, không ghi đè; mở lại phim thấy dữ liệu của bên đầu | BR-138; X-24 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-604 | Movie save (EX-16), suất chiếu (EX-13) | tích hợp đồng thời | Phim 5 có thể lập suất chiếu; quản lý cụm rạp lập suất chiếu cho phim 5 | Thứ tự A: sửa phim (rút endOfRunDate) rồi lập suất chiếu. Thứ tự B: lập suất chiếu rồi sửa phim | A: lập suất chiếu dùng phim hiện hành và bị OutsideRunPeriodError nếu ngoài khoảng mới. B: suất chiếu đã lưu không đổi theo sửa phim sau đó | BR-139, BR-84; X-25 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-605 | DC-ManageCinemasService.AddCinema, SaveCinemaChanges | tích hợp đồng thời | Chưa có cụm rạp tên "cinebook q1" | Hai AddCinema đồng thời với tên "CineBook Q1" và " cinebook   q1 " (khác hoa thường, khoảng trắng); và hai SaveCinemaChanges cùng một cụm rạp cùng displayedAt | Cùng tên: đúng một thành công, bên kia CinemaNameTakenError; cùng cụm rạp: bên sau CinemaChangedError; số 23505 lọt ra bằng 0; khoá giá trị hạng 0 trước khoá dòng Cinema | BR-141, BR-142; X-26 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-606 | DC-ManageAuditoriumsService | tích hợp đồng thời | Cụm rạp 2 chưa có phòng tên "p9" | Hai thêm phòng đồng thời "P9" và "p9 "; hai sửa tên hai phòng khác nhau thành cùng một tên | Đúng một thành công, bên kia AuditoriumNameTakenError; không 23505 lọt ra | BR-145; X-27 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-607 | DC-ManageAuditoriumsService (xoá), EX-13 | tích hợp đồng thời | Phòng 7 chưa từng có suất chiếu | Thứ tự A: xoá phòng 7 rồi lập suất chiếu cho phòng 7. Thứ tự B: lập suất chiếu rồi xoá phòng 7 | A: lập suất chiếu nhận AuditoriumGoneError (luồng 8h). B: xoá nhận AuditoriumHasScheduleError (luồng 1b3a); kể cả suất chiếu đã xoá cũng chặn xoá phòng | BR-147, BR-136; X-28 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-608 | DC-ManageAuditoriumsService (sửa, xoá) | tích hợp đồng thời | Phòng 7 hiển thị mốc T0 | Hai sửa cùng T0; sửa rồi xoá; xoá rồi sửa; xoá hai lần | Bên ghi nhận sau bị AuditoriumChangedError hoặc AuditoriumGoneError, không ghi đè; phòng đã xoá không còn để sửa | BR-146; X-29 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-609 | DC-RegisterAccountService.RegisterAccount | tích hợp đồng thời | Chưa có khách | Hai RegisterAccount cùng email (khác hoa thường: An@CineBook.vn và an@cinebook.vn) đồng thời; và hai yêu cầu chung số điện thoại khác email; và hai yêu cầu chéo (email e1 với phone p2, email e2 với phone p1) đồng thời; 1.000 lần | Đúng một thành công cho mỗi cặp trùng, bên kia DuplicateAccountError; yêu cầu chéo không deadlock (email hạng 11 trước phone hạng 12): 40P01 bằng 0; 23505 lọt ra bằng 0 | BR-98; X-30; P09 F7.3 EX-20 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-610 | DC-ManageStaffAccountsService.CreateStaffAccount | tích hợp đồng thời | Chưa có nhân viên; có khách cùng email | Hai CreateStaffAccount cùng email (khác hoa thường) đồng thời; thêm một CreateStaffAccount cùng email với khách sẵn có | Đúng một thành công, bên kia DuplicateStaffEmailError; nhân viên cùng email với khách được tạo (hai tập khác nhau, hạng 13 và 11); 23505 lọt ra bằng 0 | BR-95; X-31 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-611 | DC-ManageStaffAccountsService (UpdateStaffAccess, Lock, Unlock, Rename, Reset) | tích hợp đồng thời | Staff 7 hiển thị mốc T0 cho hai quản trị viên | Hai LockStaffAccount cùng T0; LockStaffAccount với RenameStaffAccount cùng T0, cả hai thứ tự | Hai khoá: bên sau nhận StaffStatusUnchangedError (1b3a). Khoá và đổi tên: bên sau nhận StaleStaffError (1b3b hoặc 1d4b); không ghi đè; accessChangedAt chỉ đổi bởi lần khoá | BR-102; X-32 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-612 | DC-BookTicketsService.HoldSeats, DC-ManageStaffAccountsService.LockStaffAccount | tích hợp đồng thời | Nhân viên quầy 3 ACTIVE đăng nhập mốc A1; ghế 101 trống | Thứ tự A: HoldSeats giữ khoá Staff (hạng 4) trước, rồi LockStaffAccount. Giữ ghế của nhân viên 3 ở thứ tự A hoàn tất, sau đó ConfirmCashReceived (phiên cũ, nhưng thao tác này không kiểm phiên theo F7.11) | Lần giữ ghế được tạo và giữ nguyên, kết thúc theo UC-005 (BR-100); khoá tài khoản thành công sau đó; thao tác kế tiếp qua DC-AuthFilter bị 401 | BR-100, BR-101; X-33 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-613 | DC-BookTicketsService.HoldSeats, DC-ManageStaffAccountsService.LockStaffAccount | tích hợp đồng thời | Như trên | Thứ tự B: LockStaffAccount (hoặc UpdateStaffAccess) giữ khoá Staff trước, rồi HoldSeats của nhân viên 3 với mốc A1 | HoldSeats nhận StaffAccessChangedError, không có lần giữ ghế mới, ghế 101 vẫn trống; phiên cũ gọi API khác bị 401 SESSION_INVALID; đăng nhập lại (nếu chưa khoá) nhận mốc mới | BR-101; X-33; Bảng hỏng mục 10 | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-614 | DC-PgUnitOfWork.LockValue, AcquireValue (hạng 0, 11, 12, 13) | tích hợp đồng thời | Schema P13 | fn cố ý LockValue(CUSTOMER_PHONE) rồi LockValue(CUSTOMER_EMAIL); fn LockValue trong giao dịch chỉ đọc; fn lấy khoá dòng Cinema rồi LockValue(CINEMA_NAME) | Cả ba trường hợp: LockOrderViolationError hoặc LockInReadOnlyTxError, không gửi SQL khoá, không thử lại, rollback | P09 F7.3; P12 F3 LockValue | - | không (PostgreSQL thật); IF-01 giả lập | Cao | Tích hợp |
| TC-615 | DC-ViewChainReportService.ViewChainReport, DC-PgReportStore | tích hợp đồng thời | Dữ liệu bán vé của 3 cụm rạp; một giao dịch bán ghế commit giữa hai câu của báo cáo | Chạy báo cáo toàn chuỗi (REPEATABLE READ READ ONLY) trong khi bán ghế | Mọi câu của một báo cáo thấy cùng một ảnh chụp: tổng toàn chuỗi bằng tổng các cụm rạp; báo cáo vượt statement_timeout 15 giây thì SystemBusyError | P09 F7.12; UC-016 | - | không (PostgreSQL thật); IF-01 giả lập | Trung bình | Tích hợp |
| TC-616 | DC-ManageCinemasService.AddCinema, DC-ManageAuditoriumsService, DC-RegisterAccountService, DC-ManageStaffAccountsService.CreateStaffAccount | tích hợp đồng thời | Schema P13 | SIGKILL backend giữa thao tác (trước COMMIT) của EX-17, EX-18, EX-19, EX-20, EX-21 | Không có cụm rạp thiếu bảng giá, phòng thiếu ghế, khách hoặc nhân viên thiếu dòng; bấm lại thành công hoặc nhận lỗi đã tồn tại từ chính lần trước | Bảng hỏng mục 8; BR-141, BR-145, BR-147 | - | không (PostgreSQL thật); IF-01 giả lập | Trung bình | Tích hợp |
| TC-617 | DC-PgUnitOfWork (idle_in_transaction_session_timeout) | tích hợp đồng thời | Giao dịch của harness giữ khoá dòng Staff rồi treo | Một HoldSeats của nhân viên quầy cùng nhân viên bị chặn bởi khoá treo | Phiên treo bị cắt sau 5 giây, khoá nhả; HoldSeats chờ tối đa lock_timeout 1 giây rồi thử lại tối đa 2 lần, kết cục SystemBusyError trong hạn 1,8 giây hoặc thành công sau khi khoá nhả; không còn khoá tư vấn sót | Bảng hỏng mục 9; NFR-06 | - | không (PostgreSQL thật); IF-01 giả lập | Trung bình | Tích hợp |
| TC-618 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, PROCESSED) | Thân JSON chứa RspCode "00"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-619 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, DUPLICATE) | Thân JSON chứa RspCode "02"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-620 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, INVALID_SIGNATURE) | Thân JSON chứa RspCode "97"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-621 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, AMOUNT_MISMATCH) | Thân JSON chứa RspCode "04"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-622 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, UNKNOWN_TRANSACTION) | Thân JSON chứa RspCode "01"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-623 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, TEMPORARY_FAILURE) | Thân JSON chứa RspCode "99"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-624 | DC-PaymentCallbackController.writeIpnAnswer | phân vùng tương đương | Không có | writeIpnAnswer(w, MALFORMED) | Thân JSON chứa RspCode "99"; mã HTTP 200 (cổng chỉ đọc RspCode) | P09 F7.6 | EC-299 | fake ResponseWriter | Trung bình | Unit |
| TC-625 | DC-VnpaySigner.Sign, Verify | phân vùng tương đương | Khoá "k-test"; params P = {a: 1, b: 2} | Verify(P, Sign(P)) | Trả true | NFR-16 | EC-300 | stub GatewayConfig | Cao | Unit |
| TC-626 | DC-VnpaySigner.Sign, Verify | phân vùng tương đương | Như trên | Sign({b: 2, a: 1}) và Sign({a: 1, b: 2}) | Hai chuỗi bằng nhau (độc lập thứ tự nhập) | P12 F2 (sắp theo tên) | EC-300 | stub GatewayConfig | Cao | Unit |
| TC-627 | DC-VnpaySigner.Sign, Verify | phân vùng tương đương | Như trên; s = Sign(P) | Verify({a: 1, b: 3}, s) | Trả false | NFR-16 | EC-301 | stub GatewayConfig | Cao | Unit |
| TC-628 | DC-VnpaySigner.Sign, Verify | phân vùng tương đương | Như trên | Verify(P, s với một ký tự cuối đổi) | Trả false | NFR-16 | EC-301 | stub GatewayConfig | Cao | Unit |
| TC-629 | DC-VnpaySigner.Sign, Verify | phân vùng tương đương | Hai bộ ký dùng khoá "k-test" và "k-other" | Verify(P, Sign của bộ thứ hai) trên bộ thứ nhất | Trả false | NFR-16 | EC-301 | stub GatewayConfig | Trung bình | Unit |
| TC-630 | DC-VnpayReportDecoder.Decode | phân vùng tương đương | Tham số báo thành công của giao dịch 20260001, ref-1, số tiền cổng 18000000 (nhân 100) | Decode(params) | Chưa xác định: chờ Q-355 (tên tham số và hệ số nhân 100 theo V-04, V-05 chưa kiểm) | P11b SS-01 V-04, V-05 | EC-302; không tính vào độ phủ (chờ Q-355) | stub GatewayConfig | Trung bình | Unit |
| TC-631 | DC-VnpayReportDecoder.Decode | phân vùng tương đương | Tham số báo thiếu số tiền | Decode(params) | Ném MalformedReportError | P12 F2 | EC-303 | stub GatewayConfig | Trung bình | Unit |
| TC-632 | DC-SubscriberQueue.Offer, Close | giá trị biên | Hàng đợi có 255 phần tử | Offer(item) | Trả true; hàng đợi 256; không đóng | NFR-08 | BV-106, EC-304 | Không (đối tượng thuần) | Cao | Unit |
| TC-633 | DC-SubscriberQueue.Offer, Close | giá trị biên | Hàng đợi đủ 256 phần tử | Offer(item) | Trả false; Close(SLOW_CONSUMER) được gọi 1 lần; gửi CLOSED kèm lý do SLOW_CONSUMER; mọi Offer sau đó trả false | NFR-08 | BV-107, EC-305 | Không (đối tượng thuần) | Cao | Unit |
| TC-634 | DC-SubscriberQueue.Offer, Close | phân vùng tương đương | Hàng đợi đã Close(SLOW_CONSUMER) | Close(SLOW_CONSUMER) lần hai | Không panic, không gửi CLOSED thứ hai | P12 F2 (gọi hai lần vô hại) | EC-305 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-635 | DC-EmittedEventTracker.WasEmitted, Record, AdvanceMark; DC-SeatEventPoller.pollOnce | phân vùng tương đương | Tracker đã Record(id 500, 10:00:00) | WasEmitted(500) và WasEmitted(501) | Trả true và false | P12 F3 pollOnce | EC-307, EC-306 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-636 | DC-EmittedEventTracker.WasEmitted, Record, AdvanceMark; DC-SeatEventPoller.pollOnce | giá trị biên | Tracker có sự kiện id 500 phát lúc 10:00:00 (created_at 10:00:00); now = 10:00:10.001 | AdvanceMark(now) | Mốc W = 500 (dòng cũ hơn 10 giây); mã 500 vẫn nhớ (chưa cũ hơn 20 giây) | P12 F3 pollOnce bước 3; P09 F7.5 | BV-110 | Không (đối tượng thuần) | Cao | Unit |
| TC-637 | DC-EmittedEventTracker.WasEmitted, Record, AdvanceMark; DC-SeatEventPoller.pollOnce | giá trị biên | Như trên; now = 10:00:10.000 (đúng 10 giây, chưa cũ hơn 10 giây) | AdvanceMark(now) | Mốc W chưa tiến tới 500 | P09 F7.5 | BV-110 | Không (đối tượng thuần) | Cao | Unit |
| TC-638 | DC-EmittedEventTracker.WasEmitted, Record, AdvanceMark; DC-SeatEventPoller.pollOnce | giá trị biên | Như trên; now = 10:00:20.001 | AdvanceMark(now) | Mã 500 bị xoá khỏi tracker (WasEmitted(500) = false) | P12 F3 | BV-111 | Không (đối tượng thuần) | Cao | Unit |
| TC-639 | DC-EmittedEventTracker.WasEmitted, Record, AdvanceMark; DC-SeatEventPoller.pollOnce | phân vùng tương đương | IF-22.ReadEventsAfter trả sự kiện id 502, 501, 500 (chưa phát), 500 đã phát trước đó; một hàng đợi đăng ký suất chiếu 55 | pollOnce | Offer vào hàng đợi theo mã tăng dần 501, 502; không Offer 500; Record cả hai | P12 F3 pollOnce | EC-306 | fake IF-22, stub đồng hồ | Cao | Unit |
| TC-640 | DC-IpConnectionLimiter.TryAcquire | giá trị biên | Limiter maxPerIp 10; 9 kết nối đang mở từ 10.0.0.9 | TryAcquire("10.0.0.9") | Trả (release, true) | P12 F2; SSE_LIMIT | BV-108, EC-308 | Không (đối tượng thuần) | Cao | Unit |
| TC-641 | DC-IpConnectionLimiter.TryAcquire | giá trị biên | Limiter maxPerIp 10; 10 kết nối đang mở từ 10.0.0.9 | TryAcquire("10.0.0.9") | Trả (nil, false) (429 SSE_LIMIT); đếm vẫn 10 | P12 F2; SSE_LIMIT | BV-109, EC-309 | Không (đối tượng thuần) | Cao | Unit |
| TC-642 | DC-IpConnectionLimiter.TryAcquire | phân vùng tương đương | Như trên | TryAcquire("10.0.0.10") | Trả (release, true) (đếm theo từng IP) | P12 F2 | EC-308 | Không (đối tượng thuần) | Trung bình | Unit |
| TC-643 | DC-IpConnectionLimiter.TryAcquire | phân vùng tương đương | 10 kết nối từ 10.0.0.9; r = release của một kết nối | r() hai lần rồi TryAcquire("10.0.0.9") | Đếm giảm đúng một lần (còn 9) nên TryAcquire trả true | P12 F2 (release đúng một lần) | BV-108 | Không (đối tượng thuần) | Cao | Unit |
| TC-644 | DC-JobLoop.runOnce | phân vùng tương đương | IScheduledJob.RunDue trả nil | runOnce(ctx) | RunDue gọi 1 lần với ctx có deadline budget; running = false sau khi xong; log lỗi 0 lần | P12 F3 JobLoop | EC-310 | mock IScheduledJob, spy log | Trung bình | Unit |
| TC-645 | DC-JobLoop.runOnce | phân vùng tương đương | RunDue trả lỗi | runOnce(ctx) | Lỗi được ghi log 1 lần, không lọt ra ngoài; running = false | P12 F2 | EC-311 | mock IScheduledJob, spy log | Trung bình | Unit |
| TC-646 | DC-JobLoop.runOnce | phân vùng tương đương | RunDue panic | runOnce(ctx) | Panic được bắt và ghi log; running = false; chu kỳ sau vẫn chạy được | P12 F2 | EC-311 | mock IScheduledJob, spy log | Cao | Unit |
| TC-647 | DC-JobLoop.Run | phân vùng tương đương | runOnce của chu kỳ trước còn chạy (running = true) | Đến hạn chu kỳ kế (đồng hồ giả) | Chu kỳ này bị bỏ, RunDue không gọi lần hai song song; lượt quá budget cộng 2 giây chỉ ghi log | P12 F3 JobLoop.Run | EC-310 | mock IScheduledJob, stub đồng hồ | Trung bình | Unit |
| TC-648 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); ghế 101, 102, 103 AVAILABLE (giá 90.000); tx.Now = 2026-11-10 10:00:00.000; nhân viên quầy 3 (Staff ACTIVE, cụm rạp 2, accessChangedAt A1 = 2026-11-10 07:00:00.000001) không có lần giữ ghế nào | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CLERK 3, holderCinemaId 2, accessChangedAt A1, requestId r-1, displayedAt 2026-11-08 09:00:00.000) | Trả HoldResult replayed = false, tổng 270.000; lần giữ ghế ACTIVE của CLERK 3; ghế 101..103 HELD; LockClerk (hạng 4) gọi 1 lần trước LockUnfinishedOrByRequest (hạng 5); Violated() = false | BR-02, BR-101; UC-005 2b | EC-186, EC-188, DT10-R4 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-649 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); ghế 101, 102, 103 AVAILABLE (giá 90.000); tx.Now = 2026-11-10 10:00:00.000; nhân viên quầy 3 (Staff LOCKED sau khi phiên cấp, cụm rạp 2, accessChangedAt A2 = 2026-11-10 09:30:00.000001) không có lần giữ ghế nào | HoldSeats(req như TC trước với accessChangedAt A1) | Ném StaffAccessChangedError; không có lần giữ ghế; ghế 101..103 vẫn AVAILABLE; rollback | BR-97, BR-101; X-33 | EC-189 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-650 | DC-BookTicketsService.HoldSeats | giá trị biên | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); ghế 101, 102, 103 AVAILABLE (giá 90.000); tx.Now = 2026-11-10 10:00:00.000; nhân viên quầy 3 (Staff ACTIVE, cụm rạp 2, accessChangedAt = 2026-11-10 07:00:00.000002) không có lần giữ ghế nào | HoldSeats(req như TC trước với accessChangedAt = 07:00:00.000001) | Ném StaffAccessChangedError (lệch 1 micro giây); không ghi gì | BR-101; X-33 | EC-189 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-651 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); ghế 101, 102, 103 AVAILABLE (giá 90.000); tx.Now = 2026-11-10 10:00:00.000; nhân viên quầy 5 (cụm rạp 3) (Staff ACTIVE, cụm rạp 2, accessChangedAt A1 = 2026-11-10 07:00:00.000001) không có lần giữ ghế nào | HoldSeats(req: holder CLERK 5, holderCinemaId 3, các tham số khác như TC trước) | Ném ChannelMismatchError; không có lần giữ ghế; ghế vẫn AVAILABLE; rollback | BR-02; UC-005 2b | EC-187, DT10-R2 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-652 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); ghế 101, 102, 103 AVAILABLE (giá 90.000); tx.Now = 2026-11-09 07:59:59.999 (chưa mở bán); nhân viên quầy 5 (cụm rạp 3) (Staff ACTIVE, cụm rạp 2, accessChangedAt A1 = 2026-11-10 07:00:00.000001) không có lần giữ ghế nào | HoldSeats(req: holder CLERK 5, holderCinemaId 3) | Ném ChannelMismatchError (2b kiểm trước 2a, Q-353); không ghi gì | P12 F3 (e) (thứ tự báo lỗi cả hàm); Q-353 | DT10-R1 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-653 | DC-BookTicketsService.HoldSeats | bảng quyết định | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); ghế 101, 102, 103 AVAILABLE (giá 90.000); tx.Now = 2026-11-09 07:59:59.999 (chưa mở bán); nhân viên quầy 3 (Staff ACTIVE, cụm rạp 2, accessChangedAt A1 = 2026-11-10 07:00:00.000001) không có lần giữ ghế nào | HoldSeats(req: holder CLERK 3, holderCinemaId 2) | Ném ShowtimeNotOpenError; không ghi gì | UC-005 2a; BR-45 | DT10-R3 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Cao | Unit |
| TC-654 | DC-BookTicketsService.HoldSeats | phân vùng tương đương | Showtime 55 (phòng 7, cụm rạp 2, mở bán 2026-11-09 08:00, bắt đầu 2026-11-10 20:00, lastChangedAt 2026-11-08 09:00, IN_SCHEDULE); khách 7 không có lần giữ ghế nào; ghế 101, 102, 103 AVAILABLE (STANDARD, giá 90.000 theo bảng giá); tx.Now = 2026-11-10 10:00:00.000; H0 của khách 7 requestId r-1 đã được ghi EXPIRED lúc 10:10:00 (tx.Now = 10:11:00) | HoldSeats(req: showtimeId 55, seatIds [101,102,103], holder CUSTOMER 7, requestId r-1) | Ném HoldNotActiveError mang Status = EXPIRED; Insert 0 lần; ghế không đổi | P12 F3 (d); BR-86 | EC-101 | fake IF-08/11/12/13/16/17/18, stub IF-25, IF-24 | Trung bình | Unit |
| TC-655 | DC-CancelTicketService.ConfirmCashRefund | giá trị biên | Vé TK2 mua tại quầy (Booking của hold CLERK 3), UNUSED, giá 100.000; ghế 102 SOLD với currentTicket TK2; Showtime 55 cụm rạp 2 bắt đầu 20:00; clerk 4 cụm rạp 2; tx.Now = 18:00:00.000 (đúng 2 giờ trước) | ConfirmCashRefund(TK2, clerk 4) | Huỷ được: TK2 CANCELLED; ghế 102 AVAILABLE; IF-21.Insert 1 lần (TICKET_CASH, REFUNDED, 70.000); 1 commit | BR-18, BR-32, BR-20; UC-008 | BV-60, EC-152 | fake IF-08/11/18/20/21/27, stub IF-25 | Cao | Unit |
| TC-656 | DC-CancelTicketService.ConfirmCashRefund | phân vùng tương đương | Không có vé mã 9999 | ConfirmCashRefund(9999, clerk 4) | Ném NotFoundError; không ghi gì | P12 F2 | EC-147 | fake IF-08/11/18/20/21/27, stub IF-25 | Trung bình | Unit |
| TC-657 | DC-CancelTicketService.ConfirmCashRefund | phân vùng tương đương | Vé TK2 mua tại quầy (Booking của hold CLERK 3), CANCELLED, giá 100.000; ghế 102 SOLD với currentTicket TK2; Showtime 55 cụm rạp 2 bắt đầu 20:00; clerk 4 cụm rạp 2; tx.Now = 17:00 | ConfirmCashRefund(TK2, clerk 4) | Ném TicketStateError mang CANCELLED; không tạo yêu cầu hoàn tiền mặt thứ hai | BR-21; UC-008 4a | EC-149 | fake IF-08/11/18/20/21/27, stub IF-25 | Cao | Unit |
| TC-658 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim trả claimedUntil = tx.Now + 14,999 giây | ProcessRefund(E1) | Trả nil; log cảnh báo 1 lần; IF-01.RequestRefund 0 lần; IF-01.FindRefund 0 lần | P12 F3 bước 2; Q-149 | BV-70, EC-170 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |
| TC-659 | DC-RefundService.ProcessRefund | giá trị biên | Dòng hàng đợi E1 (REFUND_GATEWAY, claimToken TOK1); RR1 FULL của PT1 (mã 20260001, paidAt 10:04:00, 100.000), khoá 20260001-FULL; tx.Now = 11:00:00.000, ExtendClaim trả claimedUntil = 11:02:00; RR1 NEW; ExtendClaim trả claimedUntil = tx.Now + 15,000 giây | ProcessRefund(E1) | Gọi IF-01.RequestRefund đúng 1 lần với ctx có hạn 5 giây (nhỏ hơn của 30 giây và 15 - 10 giây); không bỏ lượt | P12 F3 bước 2; Q-149 | BV-71, EC-171 | fake IF-08/19/21/23, mock IF-01, stub IF-25/đồng hồ, spy log | Cao | Unit |

## F4. Ma trận phủ

F4.1. Phân vùng, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái theo từng operation (nhánh CE nằm ở bảng phủ nhánh của F2.x.6 và tóm tắt ở F4.6). Cột Đạt: Có khi có ít nhất một TC với kết quả đã xác định; Không kèm lý do khi mọi TC của mục đều chờ câu hỏi hoặc mục là tiền điều kiện của bên gọi; N/A khi mục không thể xảy ra theo thiết kế.

| Mục cần phủ (EC / BV / DT-R / chuyển trạng thái) | TC phủ | Đạt (Có / Không: lý do) |
|---|---|---|
| EC-01 (holder - kind = CUSTOMER) | TC-001 | Có |
| EC-02 (holder - kind = CLERK) | TC-002 | Có |
| EC-03 (holder, requestId, holdRef - rỗng, nil hoặc zero (P12 không nêu hành vi) [Q-144]) | - | Không: tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |
| BV-01 (EC-01 (now) - now = 2026-11-10 23:55:00 (expiryTime vượt qua nửa đêm)) | TC-003 | Có |
| CT-01 ((initial) - create(holder, showtimeId, requestId, holdRef, now) [cả nhóm ghế giữ được, bảo đảm bởi bên gọi]) | TC-001 | Có |
| EC-04 (status = ACTIVE, now - now < expiryTime) | TC-005 | Có |
| EC-05 (status = ACTIVE, now - now >= expiryTime) | TC-006 | Có |
| EC-06 (status - trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED)) | TC-008, TC-009 | Có |
| BV-02 (EC-04 (now so với expiryTime) - E - 1ms) | TC-005 | Có |
| BV-03 (EC-05 (now so với expiryTime) - E (đúng hạn)) | TC-006 | Có |
| BV-04 (EC-05 (now so với expiryTime) - E + 1ms) | TC-007 | Có |
| CT-02 (Đang giữ - expire(now) [now >= expiryTime]) | TC-006 | Có |
| CT-03 (Đang giữ - expire(now) [now < expiryTime]) | TC-005 | Có |
| CT-04 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại - expire(now)) | TC-008, TC-009 | Có |
| EC-07 (status = ACTIVE, now - now < expiryTime) | TC-010 | Có |
| EC-08 (status = ACTIVE, now - now >= expiryTime (bên gọi chưa gọi Expire)) | TC-013 | Có |
| EC-09 (status - trạng thái cuối (COMPLETED, EXPIRED, CANCELLED, PAYMENT_FAILED)) | TC-016, TC-017, TC-018, TC-019 | Có |
| BV-05 (EC-07 - now = E - 1ms) | TC-010 | Có |
| BV-06 (EC-08 - now = E) | TC-013 | Có |
| BV-07 (EC-08 - now = E + 1ms) | TC-015 | Có |
| CT-05 (Đang giữ - complete(now) [now < expiryTime]) | TC-010 | Có |
| CT-06 (Đang giữ - cancel(now) [now < expiryTime]) | TC-011 | Có |
| CT-07 (Đang giữ - failPayment(now) [now < expiryTime]) | TC-012 | Có |
| CT-08 (Đang giữ - complete(now) [now >= expiryTime]) | TC-013 | Có |
| CT-09 (Đang giữ - cancel(now) [now >= expiryTime]) | TC-014 | Có |
| CT-10 (Đang giữ - failPayment(now) [now >= expiryTime]) | TC-015 | Có |
| CT-11 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại - complete(now)) | TC-016, TC-017, TC-018, TC-019 | Có |
| CT-12 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại - cancel(now)) | TC-020 | Có |
| CT-13 (Đã hoàn tất / Hết hạn / Đã huỷ / Thanh toán thất bại - failPayment(now)) | TC-021 | Có |
| EC-10 (status, now - ACTIVE và now < expiryTime) | TC-022 | Có |
| EC-11 (status, now - ACTIVE và now >= expiryTime) | TC-023 | Có |
| EC-12 (status - trạng thái cuối) | TC-024 | Có |
| BV-08 (EC-10 - E - 1ms) | TC-022 | Có |
| BV-09 (EC-11 - E) | TC-023 | Có |
| EC-13 (seats - mọi ghế HELD bởi lần giữ ghế này, 1 đến 8 ghế) | TC-025 | Có |
| EC-14 (seats - có ghế không thuộc lần giữ ghế này (currentHold khác hoặc không HELD)) | TC-028 | Có |
| EC-15 (seats - danh sách rỗng) | TC-029 | Có |
| BV-10 (kích thước seats (EC-13) - 1 ghế) | TC-026 | Có |
| BV-11 (kích thước seats (EC-13) - 8 ghế (tối đa BR-05)) | TC-027 | Có |
| EC-16 (state (HoldFor) - AVAILABLE) | TC-030 | Có |
| EC-17 (state (HoldFor) - HELD hoặc SOLD) | TC-031, TC-032 | Có |
| EC-18 (state, currentHold (MarkSold) - HELD và currentHold = holdId) | TC-033 | Có |
| EC-19 (state, currentHold (MarkSold) - HELD nhưng currentHold khác holdId) | TC-034 | Có |
| EC-20 (state (MarkSold) - AVAILABLE hoặc SOLD) | TC-035, TC-036 | Có |
| CT-14 (Trống - holdFor(holdId, price) [state = AVAILABLE]) | TC-030 | Có |
| CT-15 (Đang được giữ / Đã bán - holdFor) | TC-031, TC-032 | Có |
| CT-16 (Đang được giữ - markSold(holdId, ticketId) [currentHold = holdId]) | TC-033 | Có |
| CT-17 (Đang được giữ - markSold khi currentHold khác holdId) | TC-034 | Có |
| CT-18 (Trống / Đã bán - markSold) | TC-035, TC-036 | Có |
| EC-21 (state, currentHold (ReleaseHold) - HELD và currentHold = holdId) | TC-037 | Có |
| EC-22 (state, currentHold (ReleaseHold) - HELD nhưng currentHold khác holdId) | TC-038 | Có |
| EC-23 (state (ReleaseHold) - AVAILABLE hoặc SOLD) | TC-039, TC-040, TC-041 | Có |
| EC-24 (state, currentTicket (ReleaseTicket) - SOLD và currentTicket = ticketId) | TC-042 | Có |
| EC-25 (state, currentTicket (ReleaseTicket) - SOLD nhưng currentTicket khác ticketId) | TC-043 | Có |
| EC-26 (state (ReleaseTicket) - AVAILABLE hoặc HELD) | TC-044, TC-045 | Có |
| CT-19 (Đang được giữ - releaseHold(holdId) [currentHold = holdId]) | TC-037 | Có |
| CT-20 (Đang được giữ - releaseHold khi currentHold khác holdId) | TC-038 | Có |
| CT-21 (Trống / Đã bán - releaseHold) | TC-039, TC-040, TC-041 | Có |
| CT-22 (Đã bán - releaseTicket(ticketId) [currentTicket = ticketId]) | TC-042 | Có |
| CT-23 (Đã bán - releaseTicket khi currentTicket khác ticketId) | TC-043 | Có |
| CT-24 (Trống / Đang được giữ - releaseTicket) | TC-044, TC-045 | Có |
| CT-25 (Chưa xử lý (PENDING) - MarkTicketed) | TC-046 | Có |
| CT-26 (Chưa xử lý (PENDING) - MarkLatePayment) | TC-047 | Có |
| CT-27 (Chưa xử lý (PENDING) - RecordFailure) | TC-048 | Có |
| CT-28 (Chưa xử lý (PENDING) - RecordDuplicate) | TC-049 | Có |
| CT-29 (Đã ghi nhận thất bại (FAILED) - MarkTicketed) | TC-050 | Có |
| CT-30 (Đã ghi nhận thất bại (FAILED) - MarkLatePayment) | TC-051 | Có |
| CT-31 (Đã ghi nhận thất bại (FAILED) - RecordFailure) | TC-052 | Có |
| CT-32 (Đã ghi nhận thất bại (FAILED) - RecordDuplicate) | TC-053 | Có |
| CT-33 (Đã tạo vé (TICKETED) - MarkTicketed) | TC-054 | Có |
| CT-34 (Đã tạo vé (TICKETED) - MarkLatePayment) | TC-055 | Có |
| CT-35 (Đã tạo vé (TICKETED) - RecordFailure) | TC-056 | Có |
| CT-36 (Đã tạo vé (TICKETED) - RecordDuplicate) | TC-057, TC-062 | Có |
| CT-37 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) - MarkTicketed) | TC-058 | Có |
| CT-38 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) - MarkLatePayment) | TC-059 | Có |
| CT-39 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) - RecordFailure) | TC-060 | Có |
| CT-40 (Đã ghi nhận thanh toán trễ (LATE_PAYMENT) - RecordDuplicate) | TC-061 | Có |
| EC-27 (refundedTotal + amount - <= số đã thanh toán) | TC-063, TC-067 | Có |
| EC-28 (refundedTotal + amount - > số đã thanh toán) | TC-064, TC-068 | Có |
| EC-29 (amount - <= 0 [Q-144]) | - | Không: tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |
| BV-12 (max của EC-27 - refundedTotal 0, amount 100.000 (bằng đúng số đã thanh toán)) | TC-063 | Có |
| BV-13 (max của EC-27 - refundedTotal 0, amount 100.001) | TC-064 | Có |
| BV-14 (max của EC-27 - refundedTotal 70.000, amount 30.000) | TC-065 | Có |
| BV-15 (max của EC-27 - refundedTotal 70.000, amount 30.001) | TC-066 | Có |
| EC-30 (loại yêu cầu - hoàn toàn bộ (FULL)) | TC-070 | Có |
| EC-31 (loại yêu cầu - hoàn một vé qua cổng (TICKET_GATEWAY)) | TC-071, TC-072 | Có |
| EC-32 (loại yêu cầu - hoàn tiền mặt (TICKET_CASH)) | TC-073 | Có |
| EC-33 (amount, txn, ticket - amount <= 0, txn hoặc ticket nil [Q-144]) | - | Không: tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |
| CT-41 ((initial) - create(requestType = FULL hoặc TICKET_GATEWAY) [else]) | TC-070 | Có |
| CT-42 ((initial) - create(requestType = TICKET_CASH) [TICKET_CASH]) | TC-073 | Có |
| EC-34 (status - NEW) | TC-075 | Có |
| EC-35 (status - WAITING_RETRY) | TC-076 | Có |
| EC-36 (status - IN_FLIGHT (nhận lại claim sau khi tiến trình chết)) | TC-077 | Có |
| EC-37 (status - REFUNDED hoặc MANUAL_REQUIRED) | TC-080, TC-081 | Có |
| EC-38 (attemptCount (IN_FLIGHT) - attemptCount < 4 (còn lượt)) | TC-077 | Có |
| EC-39 (attemptCount (IN_FLIGHT) - attemptCount >= 4 (hết lượt)) | TC-079 | Có |
| BV-16 (max của EC-38 - attemptCount 3 --> sau BeginAttempt = 4) | TC-078 | Có |
| BV-17 (max của EC-38 - attemptCount 4) | TC-079 | Có |
| CT-43 (Mới - beginAttempt()) | TC-075 | Có |
| CT-44 (Chờ gửi lại - beginAttempt()) | TC-076 | Có |
| CT-45 (Đang chờ kết quả - beginAttempt() [nhận lại claim, attemptCount < MaxAttempts]) | TC-077 | Có |
| CT-46 (Đang chờ kết quả - beginAttempt() [attemptCount >= MaxAttempts]) | TC-079 | Có |
| CT-47 (Đã hoàn / Cần xử lý thủ công - beginAttempt()) | TC-080, TC-081 | Có |
| EC-40 (status - IN_FLIGHT) | TC-082 | Có |
| EC-41 (status - NEW, WAITING_RETRY, REFUNDED, MANUAL_REQUIRED) | TC-089, TC-090, TC-091, TC-092 | Có |
| EC-42 (r - SUCCEEDED) | TC-082, TC-083 | Có |
| EC-43 (r, attemptCount - REJECTED hoặc UNKNOWN và attemptCount < 4) | TC-084, TC-085 | Có |
| EC-44 (r, attemptCount - REJECTED hoặc UNKNOWN và attemptCount >= 4) | TC-087, TC-088 | Có |
| BV-18 (max của EC-43 (attemptCount) - attemptCount 3 với REJECTED) | TC-086 | Có |
| BV-19 (min của EC-44 (attemptCount) - attemptCount 4 với REJECTED) | TC-087 | Có |
| CT-48 (Đang chờ kết quả - recordResult(SUCCEEDED)) | TC-082 | Có |
| CT-49 (Đang chờ kết quả - recordResult(REJECTED hoặc UNKNOWN) [attemptCount < MaxAttempts]) | TC-084, TC-085 | Có |
| CT-50 (Đang chờ kết quả - recordResult(REJECTED hoặc UNKNOWN) [attemptCount >= MaxAttempts]) | TC-087, TC-088 | Có |
| CT-51 (Mới / Chờ gửi lại / Đã hoàn / Cần xử lý thủ công - recordResult) | TC-089, TC-090, TC-091, TC-092 | Có |
| CT-52 (Đang chờ kết quả - markManualRequired(reason) [findRefund NOT_SUPPORTED hoặc UNREACHABLE, hoặc nhận lại claim khi hết lượt]) | TC-093 | Có |
| CT-53 (Mới - markManualRequired) | TC-094 | Có |
| CT-54 (Chờ gửi lại - markManualRequired) | TC-095 | Có |
| CT-55 (Đã hoàn - markManualRequired) | TC-096 | Có |
| CT-56 (Cần xử lý thủ công - markManualRequired) | TC-097 | Có |
| EC-45 (status - UNUSED) | TC-098 | Có |
| EC-46 (status - CANCELLED) | TC-099 | Có |
| EC-47 (status - USED) | TC-100 | Có |
| CT-57 (Chưa sử dụng - cancel() [đã qua kiểm hạn huỷ và kênh ở bên gọi]) | TC-098 | Có |
| CT-58 (Đã huỷ - cancel()) | TC-099 | Có |
| CT-59 (Đã sử dụng - cancel()) | TC-100 | Có |
| EC-48 (cinemaId so với cụm rạp của suất chiếu - đúng cụm rạp) | TC-103, TC-107 | Có |
| EC-49 (cinemaId so với cụm rạp của suất chiếu - khác cụm rạp) | TC-101, TC-102 | Có |
| EC-50 (selected so với ID suất chiếu - đúng suất chiếu) | TC-105, TC-107 | Có |
| EC-51 (selected so với ID suất chiếu - khác suất chiếu) | TC-103 | Có |
| EC-52 (status - UNUSED) | TC-107 | Có |
| EC-53 (status - USED) | TC-105 | Có |
| EC-54 (status - CANCELLED) | TC-106 | Có |
| CT-60 (Chưa sử dụng - admit(showtime, selected, cinemaId) [đúng cụm rạp và đúng suất chiếu]) | TC-107 | Có |
| CT-61 (Chưa sử dụng - admit khi sai cụm rạp) | TC-101 | Có |
| CT-62 (Chưa sử dụng - admit khi sai suất chiếu) | TC-103 | Có |
| CT-63 (Đã sử dụng - admit) | TC-105 | Có |
| CT-64 (Đã huỷ - admit) | TC-106 | Có |
| EC-55 (price x 70 - chia hết cho 100 (70% tròn đồng)) | TC-109, TC-110 | Có |
| EC-56 (price x 70 - không chia hết cho 100 (phần lẻ 0,1 đến 0,9 đồng)) | TC-113 | Có |
| EC-57 (price - <= 0 [Q-144]) | - | Không: tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |
| BV-20 (EC-56 - price 45.005 (phần lẻ đúng 0,5)) | TC-111 | Có |
| BV-21 (EC-56 - price 45.007 (phần lẻ 0,9: lớn nhất trong các số lẻ chục)) | TC-112 | Có |
| BV-22 (EC-56 - price 1 (nhỏ nhất P13 cho phép)) | TC-114 | Có |
| EC-58 (unfinished - rỗng hoặc chỉ gồm lần giữ ghế đã ở trạng thái cuối) | TC-121, TC-122 | Có |
| EC-59 (unfinished - có lần giữ ghế ACTIVE và now < expiryTime) | TC-123, TC-125 | Có |
| EC-60 (unfinished - có lần giữ ghế ACTIVE nhưng now >= expiryTime (đã quá hạn, chưa Expire)) | TC-124, TC-126 | Có |
| BV-23 (EC-59 (now so với expiryTime) - now = E - 1ms) | TC-123 | Có |
| BV-24 (EC-60 (now so với expiryTime) - now = E) | TC-124 | Có |
| EC-61 ((rank, key) so với (maxRank, maxKey) - rank lớn hơn maxRank) | TC-127, TC-128 | Có |
| EC-62 ((rank, key) so với (maxRank, maxKey) - cùng rank, key lớn hơn maxKey) | TC-129, TC-138 | Có |
| EC-63 ((rank, key) so với (maxRank, maxKey) - rank nhỏ hơn maxRank) | TC-131 | Có |
| EC-64 ((rank, key) so với (maxRank, maxKey) - cùng rank, key nhỏ hơn maxKey) | TC-130, TC-139 | Có |
| EC-65 (khoá lại cùng dòng - chế độ bằng hoặc yếu hơn đã giữ) | TC-134, TC-135, TC-137 | Có |
| EC-66 (khoá lại cùng dòng - nâng S lên X) | TC-136 | Có |
| BV-25 (EC-61 (rank so với maxRank) - rank lớn hơn maxRank nhưng key nhỏ hơn maxKey (TICKET (1,0) sau PAYMENT_TRANSACTION (100,0))) | TC-132 | Có |
| BV-26 (rank nhỏ nhất, lớn nhất - PRICE_LIST (1) là khoá đầu tiên; REFUND_REQUEST (9) sau TICKET (8)) | TC-127, TC-133 | Có |
| EC-67 (startTime - now - >= 2 giờ) | TC-142, TC-144 | Có |
| EC-68 (startTime - now - < 2 giờ nhưng now trước startTime) | TC-143, TC-145 | Có |
| EC-69 (now so với startTime - now >= startTime (đã bắt đầu hoặc kết thúc)) | TC-146 | Có |
| BV-27 (min của EC-67 - now = start - 2h (18:00:00.000)) | TC-142 | Có |
| BV-28 (max của EC-68 - now = 18:00:00.001 (còn 1 giờ 59 phút 59,999 giây)) | TC-143 | Có |
| BV-29 (min của EC-67 - now = 17:59:59.999 (ngay trong biên)) | TC-144 | Có |
| BV-30 (EC-69 - now = start (20:00:00.000)) | TC-145 | Có |
| EC-70 (now, saleOpenTime, startTime - now < saleOpenTime) | TC-147 | Có |
| EC-71 (now, saleOpenTime, startTime - saleOpenTime <= now < startTime) | TC-148, TC-149 | Có |
| EC-72 (now, startTime - now >= startTime) | TC-150 | Có |
| EC-73 (status - Đã xoá) | TC-151 | Có |
| BV-31 (min của EC-71 - now = sale_open - 1ms (2026-11-09 07:59:59.999)) | TC-147 | Có |
| BV-32 (min của EC-71 - now = sale_open (08:00:00.000)) | TC-148 | Có |
| BV-33 (max của EC-71 - now = start - 1ms (2026-11-10 19:59:59.999)) | TC-149 | Có |
| BV-34 (max của EC-71 - now = start (20:00:00.000)) | TC-150 | Có |
| EC-74 (số ghế - 0 ghế) | TC-152 | Có |
| EC-75 (số ghế - 1 đến 8 ghế, không trùng, thuộc phòng) | TC-153 | Có |
| EC-76 (số ghế - từ 9 ghế trở lên) | TC-155 | Có |
| EC-77 (trùng - có hai phần tử cùng mã ghế) | TC-156 | Có |
| EC-78 (phòng - có ghế thuộc phòng chiếu khác) | TC-157 | Có |
| EC-79 (loại ghế - ghế đôi (COUPLE)) | TC-158 | Có |
| BV-35 (kích thước của EC-75 - 0 ghế) | TC-152 | Có |
| BV-36 (kích thước của EC-75 - 1 ghế) | TC-153 | Có |
| BV-37 (kích thước của EC-75 - 8 ghế) | TC-154 | Có |
| BV-38 (kích thước của EC-75 - 9 ghế) | TC-155 | Có |
| EC-80 (lastChangedAt so với displayedAt - lastChangedAt = displayedAt) | TC-160 | Có |
| EC-81 (lastChangedAt so với displayedAt - lastChangedAt > displayedAt) | TC-161 | Có |
| EC-82 (status - Đã xoá) | TC-162 | Có |
| EC-83 (lastChangedAt so với displayedAt - lastChangedAt < displayedAt (không xảy ra vì mốc lấy từ chính LastChangedAt) [Q-144]) | - | Không: tiền điều kiện của bên gọi, không thiết kế TC (Q-144) |
| BV-39 (EC-80 - lastChangedAt vượt displayedAt 1ms) | TC-161 | Có |
| EC-84 (khung giờ - ngày thường (Thứ Hai đến Thứ Sáu), trước 17:00) | TC-164, TC-171 | Có |
| EC-85 (khung giờ - ngày thường, từ 17:00) | TC-165, TC-166 | Có |
| EC-86 (khung giờ - cuối tuần (Thứ Bảy, Chủ nhật), trước 17:00) | TC-167, TC-168 | Có |
| EC-87 (khung giờ - cuối tuần, từ 17:00) | TC-169, TC-170 | Có |
| EC-88 (tổ hợp (loại phòng, định dạng, loại ghế) - không có mục giá) | TC-172 | Có |
| EC-89 (startTime - mang múi giờ khác UTC+7) | TC-173 | Có |
| BV-40 (17:00 ngày thường - Thứ Tư 16:59:59.999 (UTC+7)) | TC-164 | Có |
| BV-41 (17:00 ngày thường - Thứ Tư 17:00:00.000) | TC-165 | Có |
| BV-42 (ngày thường --> cuối tuần - Thứ Sáu 23:59:59.999 (vẫn ngày thường, từ 17:00)) | TC-166 | Có |
| BV-43 (ngày thường --> cuối tuần - Thứ Bảy 00:00:00.000) | TC-167 | Có |
| BV-44 (17:00 cuối tuần - Thứ Bảy 16:59:59.999) | TC-168 | Có |
| BV-45 (17:00 cuối tuần - Thứ Bảy 17:00:00.000) | TC-169 | Có |
| BV-46 (cuối tuần --> ngày thường - Chủ nhật 23:59:59.999) | TC-170 | Có |
| BV-47 (cuối tuần --> ngày thường - Thứ Hai 00:00:00.000 (2026-11-16)) | TC-171 | Có |
| EC-90 (seatIds - 1 đến 8 ghế hợp lệ) | TC-174 | Có |
| EC-91 (seatIds - rỗng) | TC-178 | Có |
| EC-92 (seatIds - từ 9 ghế) | TC-179 | Có |
| EC-93 (seatIds - ghế trùng hoặc thuộc phòng khác) | TC-192 | Có |
| EC-94 (suất chiếu theo tx.Now - đang trong khoảng mở bán) | TC-174 | Có |
| EC-95 (suất chiếu theo tx.Now - chưa mở bán, đã bắt đầu hoặc đã xoá) | TC-189 | Có |
| EC-96 (suất chiếu so với displayedAt - chưa đổi) | TC-174 | Có |
| EC-97 (suất chiếu so với displayedAt - đã đổi hoặc phòng chiếu đổi sau FindRouting) | TC-191 | Có |
| EC-98 (lần giữ ghế chưa kết thúc của người giữ - không có (hoặc đã quá hạn)) | TC-174 | Có |
| EC-99 (lần giữ ghế chưa kết thúc của người giữ - có ACTIVE chưa quá hạn, requestId khác) | TC-186 | Có |
| EC-100 (requestId - trùng lần giữ ghế ACTIVE chưa quá hạn của chính người giữ) | TC-183 | Có |
| EC-101 (requestId - trùng lần giữ ghế đã ở trạng thái cuối hoặc đã quá hạn) | TC-184, TC-654 | Có |
| EC-102 (trạng thái các ghế sau khi khoá - mọi ghế AVAILABLE (hoặc vừa được trả từ lần giữ ghế cũ của chính người giữ)) | TC-174 | Có |
| EC-103 (trạng thái các ghế sau khi khoá - có ghế HELD hoặc SOLD) | TC-196, TC-197 | Có |
| EC-104 (khoá ghế NOWAIT - ghế đang bị giao dịch khác khoá (55P03)) | TC-193 | Có |
| EC-105 (số dòng khoá được - khác số ghế yêu cầu) | TC-195 | Có |
| EC-106 (bảng giá - có giá cho mọi ghế) | TC-174 | Có |
| EC-107 (bảng giá - thiếu giá cho một ghế) | TC-198 | Có |
| EC-108 (giao dịch - hoàn tất trong hạn 1,8 giây) | TC-174 | Có |
| EC-109 (giao dịch - hết hạn tổng hoặc hết lần thử (SystemBusyError)) | TC-199 | Có |
| EC-110 (phòng chiếu sau khoá - khác phòng ở FindRouting) | TC-182 | Có |
| EC-111 (showtimeId - không tồn tại) | TC-180 | Có |
| EC-186 (người giữ là nhân viên quầy, cụm rạp của dòng Staff đã khoá - khớp cụm rạp của suất chiếu) | TC-648 | Có |
| EC-187 (người giữ là nhân viên quầy, cụm rạp của dòng Staff đã khoá - khác cụm rạp của suất chiếu) | TC-651 | Có |
| EC-188 (trạng thái và accessChangedAt của dòng Staff (hạng 4) - Đang hoạt động và accessChangedAt bằng mốc của phiên) | TC-648 | Có |
| EC-189 (trạng thái và accessChangedAt của dòng Staff (hạng 4) - Bị khoá hoặc accessChangedAt khác mốc của phiên) | TC-649, TC-650 | Có |
| BV-48 (kích thước seatIds (EC-90) - 0 ghế) | TC-178 | Có |
| BV-49 (kích thước seatIds (EC-90) - 1 ghế) | TC-175 | Có |
| BV-50 (kích thước seatIds (EC-90) - 7 ghế) | TC-176 | Có |
| BV-51 (kích thước seatIds (EC-90) - 8 ghế) | TC-177 | Có |
| BV-52 (kích thước seatIds (EC-90) - 9 ghế) | TC-179 | Có |
| BV-53 (hết hạn của replay (EC-100) - now = E - 1ms) | TC-183 | Có |
| BV-54 (hết hạn của lần giữ ghế cũ (EC-98) - now = E (lần giữ ghế cũ vừa quá hạn)) | TC-187 | Có |
| BV-55 (hết hạn của lần giữ ghế cũ (EC-99) - now = E - 1ms) | TC-186 | Có |
| EC-112 (lần giữ ghế - ACTIVE, now < expiryTime, by là người giữ) | TC-216 | Có |
| EC-113 (lần giữ ghế - ACTIVE nhưng now >= expiryTime) | TC-218 | Có |
| EC-114 (lần giữ ghế - trạng thái cuối (COMPLETED, CANCELLED, EXPIRED, PAYMENT_FAILED)) | TC-221, TC-222, TC-223, TC-224 | Có |
| EC-115 (by - không phải người giữ) | TC-219 | Có |
| EC-116 (holdRef - không tồn tại) | TC-220 | Có |
| BV-56 (now so với expiryTime (EC-112) - now = E - 1ms) | TC-217 | Có |
| BV-57 (now so với expiryTime (EC-113) - now = E) | TC-218 | Có |
| EC-117 (lần giữ ghế - ACTIVE, now < expiryTime, clerk là người giữ) | TC-225 | Có |
| EC-118 (lần giữ ghế - ACTIVE nhưng now >= expiryTime) | TC-227 | Có |
| EC-119 (lần giữ ghế - đã ở trạng thái cuối) | TC-228, TC-231 | Có |
| EC-120 (clerk - không phải người giữ) | TC-230 | Có |
| EC-121 (holdRef - không tồn tại) | TC-229 | Có |
| BV-58 (now so với expiryTime (EC-117) - now = E - 1ms) | TC-226 | Có |
| BV-59 (now so với expiryTime (EC-118) - now = E) | TC-227 | Có |
| EC-122 (lần giữ ghế - ACTIVE, chưa quá hạn, by là người giữ) | TC-232, TC-233 | Có |
| EC-123 (lần giữ ghế - ACTIVE nhưng now >= expiryTime) | TC-234 | Có |
| EC-124 (lần giữ ghế - đã ở trạng thái cuối) | TC-235 | Có |
| EC-125 (IF-01.CreatePaymentTransaction - ném GatewayConfigurationError) | TC-236 | Có |
| EC-126 (by - không phải người giữ) | TC-237 | Có |
| EC-127 (holdRef - không tồn tại) | TC-238 | Có |
| EC-128 (chữ ký (IF-02) - sai) | TC-256 | Có |
| EC-129 (tham số - thiếu hoặc sai kiểu) | TC-257 | Có |
| EC-130 (mã tham chiếu / mã giao dịch - không nhận ra) | TC-251 | Có |
| EC-131 (số tiền báo thành công chưa xử lý - khác bản ghi (hoặc khác tổng giá ghế khi tạo giao dịch từ báo)) | TC-253 | Có |
| EC-132 (báo thành công - giao dịch PENDING, lần giữ ghế ACTIVE còn hạn, liên kết ghế khớp) | TC-239, TC-240 | Có |
| EC-133 (báo thành công - lần giữ ghế không còn hiệu lực hoặc giao dịch đã FAILED hoặc liên kết ghế vỡ) | TC-241, TC-242 | Có |
| EC-134 (báo thành công - giao dịch đã xử lý (TICKETED hoặc LATE_PAYMENT)) | TC-245, TC-262 | Có |
| EC-135 (báo thất bại - bất kỳ trạng thái) | TC-247 | Có |
| EC-136 (cơ sở dữ liệu - lỗi tạm thời (40P01, 55P03 sau thử lại)) | TC-259 | Có |
| EC-137 (số lần giữ ghế đã quá hạn - 0) | TC-267, TC-277 | Có |
| EC-138 (số lần giữ ghế đã quá hạn - 1 đến 199 (một lô chưa đầy)) | TC-268, TC-269, TC-270 | Có |
| EC-139 (số lần giữ ghế đã quá hạn - từ 200 (lô đầy, cần lô tiếp)) | TC-271, TC-272 | Có |
| EC-140 (hàng ứng viên - hàng chưa quá hạn theo tx.Now (ứng viên chọn trước khoá)) | TC-273 | Có |
| EC-141 (expireBatch - trả lỗi) | TC-276 | Có |
| EC-142 (lô lần giữ ghế đạt điều kiện - rỗng) | TC-278, TC-282 | Có |
| EC-143 (ghế còn trỏ tới lần giữ ghế đã ở trạng thái cuối - HELD với currentHold thuộc lô) | TC-279, TC-283, TC-284, TC-285, TC-286 | Có |
| EC-144 (ghế đã giữ lại cho lần giữ ghế khác - HELD với currentHold ngoài lô) | TC-280 | Có |
| EC-145 (lần giữ ghế COMPLETED - ghế SOLD) | TC-281 | Có |
| EC-146 (kênh, hạn, trạng thái vé - đúng kênh, còn từ 2 giờ, vé UNUSED) | TC-287, TC-299 | Có |
| EC-147 (kênh - sai kênh hoặc sai chủ (2a, 2b, 2c)) | TC-291, TC-656 | Có |
| EC-148 (hạn huỷ - còn dưới 2 giờ hoặc đã bắt đầu) | TC-289, TC-290 | Có |
| EC-149 (trạng thái vé - đã huỷ hoặc đã sử dụng) | TC-294, TC-657 | Có |
| EC-150 (hạn mức hoàn - refundedTotal + 70% vượt số đã thanh toán) | TC-297 | Có |
| EC-151 (liên kết ghế - currentTicket khác vé đang huỷ (ghế đã bán lại)) | TC-298 | Có |
| EC-152 (kênh quầy - vé mua tại quầy, nhân viên đúng cụm rạp) | TC-302, TC-655 | Có |
| BV-60 (thời điểm huỷ (EC-146) - now = 18:00:00.000 (đúng 2 giờ trước 20:00)) | TC-288, TC-655 | Có |
| BV-61 (thời điểm huỷ (EC-148) - now = 18:00:00.001) | TC-289 | Có |
| EC-153 (kết quả Admit - ADMITTED) | TC-308 | Có |
| EC-154 (kết quả Admit - một trong WRONG_CINEMA, WRONG_SHOWTIME, ALREADY_USED, CANCELLED) | TC-309, TC-310, TC-311, TC-312, TC-314, TC-315, TC-316 | Có |
| EC-155 (ticketCode - không tương ứng vé nào) | TC-313 | Có |
| EC-156 (hạn mức - refundedTotal + amount <= số đã thanh toán) | TC-317, TC-319 | Có |
| EC-157 (hạn mức - refundedTotal + amount > số đã thanh toán) | TC-318 | Có |
| EC-158 (IF-19.AddRefunded - 0 dòng ảnh hưởng (bên khác vừa cộng)) | TC-322 | Có |
| BV-62 (max của EC-156 - refundedTotal 37.000 + 63.000 = 100.000) | TC-320 | Có |
| BV-63 (max của EC-156 - refundedTotal 37.001 + 63.000) | TC-321 | Có |
| EC-159 (lần gửi - lần đầu (AttemptCount = 1 sau BeginAttempt)) | TC-323 | Có |
| EC-160 (lần gửi - lần hai trở đi (AttemptCount > 1, kể cả nhận lại claim)) | TC-327 | Có |
| EC-161 (FindRefund - REFUNDED) | TC-329 | Có |
| EC-162 (FindRefund - NOT_REFUNDED) | TC-327 | Có |
| EC-163 (FindRefund - NOT_SUPPORTED hoặc UNREACHABLE) | TC-330 | Có |
| EC-164 (RequestRefund - SUCCEEDED) | TC-323 | Có |
| EC-165 (RequestRefund - REJECTED hoặc UNKNOWN (hết 30 giây)) | TC-325 | Có |
| EC-166 (claim_token ở giao dịch 1 - đã mất (claim hết hạn và bản khác nhận)) | TC-334 | Có |
| EC-167 (claim_token ở giao dịch 3 - đã mất) | TC-335 | Có |
| EC-168 (trạng thái RefundRequest khi nhận dòng - REFUNDED hoặc MANUAL_REQUIRED (dòng giao lại)) | TC-336 | Có |
| EC-169 (IN_FLIGHT khi nhận lại claim - hết lượt (attemptCount = 4)) | TC-339 | Có |
| EC-170 (phần claim còn lại sau giao dịch 1 - dưới 15 giây) | TC-340, TC-658 | Có |
| EC-171 (phần claim còn lại sau giao dịch 1 - từ 40 giây (hạn gọi cổng = 30 giây)) | TC-344, TC-659 | Có |
| BV-64 (MaxAttempts (RR attemptCount trước khi ghi kết quả) - attemptCount 3 thất bại --> Reschedule 15 phút) | TC-332 | Có |
| BV-65 (MaxAttempts - attemptCount 4 thất bại) | TC-333 | Có |
| BV-66 (phần claim còn lại (EC-170) - 9,999 giây) | TC-340 | Có |
| BV-67 (phần claim còn lại (EC-170) - 10,001 giây) | TC-343 | Có |
| BV-70 (phần claim còn lại (EC-170) - 14,999 giây) | TC-658 | Có |
| BV-71 (phần claim còn lại - 15,000 giây) | TC-659 | Có |
| BV-68 (hạn gọi cổng - claim còn 40 giây --> hạn 30 giây) | TC-323, TC-344 | Có |
| BV-69 (hạn gọi cổng - claim còn 35 giây --> hạn 25 giây) | TC-345 | Có |
| EC-172 (bookingCode - tương ứng một lần đặt mua tại quầy của cụm rạp của nhân viên) | TC-346 | Có |
| EC-173 (bookingCode - không tương ứng lần đặt nào) | TC-347 | Có |
| EC-174 (lần đặt - mua tại quầy của cụm rạp khác cụm rạp của nhân viên) | TC-348 | Có |
| EC-175 (lần đặt - mua trực tuyến) | TC-349 | Có |
| EC-176 (suất chiếu - thuộc cụm rạp của nhân viên soát vé) | TC-350 | Có |
| EC-177 (suất chiếu - thuộc cụm rạp khác) | TC-351 | Có |
| EC-178 (showtimeId - không tồn tại) | TC-352 | Có |
| EC-179 (role - CUSTOMER) | TC-356 | Có |
| EC-180 (role - nhân viên (BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER)) | TC-357 | Có |
| EC-181 (role - ADMINISTRATOR) | TC-358 | Có |
| EC-182 (token - đúng chữ ký, chưa hết hạn) | TC-359 | Có |
| EC-183 (token - sai chữ ký (bị sửa)) | TC-360 | Có |
| EC-184 (token - đã hết hạn) | TC-361 | Có |
| EC-185 (storedHash - định dạng hỏng) | TC-355 | Có |
| EC-190 (reason - EXPIRY) | TC-385 | Có |
| EC-191 (reason - CANCEL) | TC-391 | Có |
| EC-192 (reason - PAYMENT_FAILURE) | TC-395 | Có |
| EC-193 (trạng thái lần giữ ghế - ACTIVE và now trước expiryTime) | TC-385, TC-391 | Có |
| EC-194 (trạng thái lần giữ ghế - ACTIVE và now không trước expiryTime) | TC-386 | Có |
| EC-195 (trạng thái lần giữ ghế - EXPIRED sẵn) | TC-388, TC-397 | Có |
| EC-196 (trạng thái lần giữ ghế - COMPLETED, CANCELLED hoặc PAYMENT_FAILED) | TC-390, TC-398 | Có |
| EC-197 (seats - rỗng hoặc nil) | TC-389 | Có |
| EC-198 (seats - mọi ghế HELD bởi chính lần giữ ghế) | TC-386 | Có |
| EC-199 (seats - có ghế đã giữ lại bởi lần giữ ghế khác hoặc đã Trống) | TC-388 | Có |
| BV-72 (now so với expiryTime (EC end_hold_active) - now = E - 1ms) | TC-385 | Có |
| BV-73 (now so với expiryTime (EC end_hold_late) - now = E) | TC-386, TC-394 | Có |
| BV-74 (kích thước seats - 0 ghế) | TC-389 | Có |
| BV-75 (kích thước seats - 1 ghế) | TC-387 | Có |
| BV-76 (kích thước seats - 8 ghế (tối đa BR-05)) | TC-392, TC-393 | Có |
| EC-200 (seats và mã vé - không rỗng, mọi ghế IsHeldBy(hold.ID), len(ticketCodes) = len(seats)) | TC-400 | Có |
| EC-201 (seats - rỗng) | TC-401 | Có |
| EC-202 (số mã vé - khác số ghế) | TC-402 | Có |
| EC-203 (liên kết ghế - có ghế không IsHeldBy(hold.ID)) | TC-403 | Có |
| EC-204 (lần giữ ghế - ACTIVE, now trước expiryTime) | TC-400 | Có |
| EC-205 (lần giữ ghế - không còn ACTIVE hoặc now không trước expiryTime) | TC-404, TC-405 | Có |
| EC-206 (vé và ghế của FinishSale - mỗi ghế có vé cùng khoá ghế, ghế HELD bởi hold.ID) | TC-407 | Có |
| EC-207 (vé và ghế của FinishSale - ghế không có vé khớp khoá, hoặc ghế không còn HELD bởi hold.ID) | TC-408 | Có |
| EC-208 (chế độ giao dịch - READ_ONLY hoặc SNAPSHOT_READ_ONLY) | TC-409 | Có |
| EC-209 (chế độ giao dịch - READ_WRITE) | TC-410 | Có |
| EC-210 (hạng của kind so với maxRank - lớn hơn) | TC-411, TC-416, TC-417 | Có |
| EC-211 (hạng của kind so với maxRank - nhỏ hơn) | TC-412, TC-418 | Có |
| EC-212 (cùng hạng - lấy lại đúng raw) | TC-413 | Có |
| EC-213 (cùng hạng - raw khác) | TC-414 | Có |
| EC-214 (cùng hạng 0 - đã có khoá dòng Cinema) | TC-415 | Có |
| EC-215 (trạng thái và mốc của dòng Staff - Đang hoạt động và accessChangedAt bằng mốc phiên) | TC-419, TC-423, TC-425 | Có |
| EC-216 (trạng thái - Bị khoá) | TC-422, TC-426 | Có |
| EC-217 (mốc - khác mốc phiên) | TC-421, TC-424, TC-427 | Có |
| EC-218 (subjectId - không phải số) | TC-428 | Có |
| BV-77 (mốc so với phiên (EC ac_ok) - cùng thời điểm, khác múi giờ (UTC và +07:00)) | TC-420 | Có |
| BV-78 (mốc so với phiên - lớn hơn 1 micro giây) | TC-421 | Có |
| EC-219 (email - có dạng email chuẩn) | TC-429, TC-438, TC-443 | Có |
| EC-220 (email - không có @ hoặc thiếu miền) | TC-430 | Có |
| EC-221 (số điện thoại - 10 chữ số, bắt đầu 0) | TC-429 | Có |
| EC-222 (số điện thoại - không đủ 10 chữ số) | TC-431, TC-439 | Có |
| EC-223 (số điện thoại - 10 chữ số nhưng không bắt đầu 0) | TC-433 | Có |
| EC-224 (số điện thoại - có ký tự không phải chữ số) | TC-434 | Có |
| EC-225 (mật khẩu - từ 8 ký tự) | TC-429 | Có |
| EC-226 (mật khẩu - dưới 8 ký tự) | TC-435 | Có |
| EC-227 (email đã đăng ký - thuộc khách khác) | TC-440, TC-442, TC-444 | Có |
| EC-228 (số điện thoại đã đăng ký - thuộc khách khác) | TC-441, TC-442 | Có |
| BV-79 (độ dài số điện thoại (EC rg_phone_ok) - 9 chữ số) | TC-431 | Có |
| BV-80 (độ dài số điện thoại - 10 chữ số) | TC-429 | Có |
| BV-81 (độ dài số điện thoại - 11 chữ số) | TC-432 | Có |
| BV-82 (độ dài mật khẩu (EC rg_pw_ok) - 7 ký tự) | TC-435 | Có |
| BV-83 (độ dài mật khẩu - 8 ký tự) | TC-429 | Có |
| EC-229 (tài khoản và mật khẩu - tài khoản có, mật khẩu đúng) | TC-445, TC-446, TC-449 | Có |
| EC-230 (tài khoản - không có) | TC-447, TC-455 | Có |
| EC-231 (mật khẩu - sai với tài khoản có) | TC-448, TC-452, TC-454 | Có |
| EC-232 (trạng thái nhân viên với mật khẩu đúng - Bị khoá) | TC-450 | Có |
| EC-233 (trạng thái nhân viên với mật khẩu sai - Bị khoá) | TC-451 | Có |
| EC-234 (email - thuộc quản trị viên) | TC-453 | Có |
| EC-235 (email - định dạng chuẩn, tối đa 254 ký tự) | TC-456, TC-485, TC-486 | Có |
| EC-236 (email - sai định dạng hoặc dài hơn 254 ký tự) | TC-457, TC-461 | Có |
| EC-237 (họ tên - 1 đến 100 ký tự) | TC-456, TC-480 | Có |
| EC-238 (họ tên - rỗng hoặc dài hơn 100 ký tự) | TC-458, TC-481 | Có |
| EC-239 (vai trò và cụm rạp - CHAIN_MANAGER với cinemaId = 0) | TC-462 | Có |
| EC-240 (vai trò và cụm rạp - CHAIN_MANAGER với cinemaId khác 0) | TC-463 | Có |
| EC-241 (vai trò và cụm rạp - ba vai trò còn lại với cinemaId khác 0) | TC-456, TC-488 | Có |
| EC-242 (vai trò và cụm rạp - ba vai trò còn lại với cinemaId = 0) | TC-464 | Có |
| EC-243 (vai trò - ngoài bốn giá trị) | TC-465, TC-487 | Có |
| EC-244 (mốc lúc hiển thị - bằng lastChangedAt của dòng) | TC-468, TC-472, TC-476, TC-477, TC-478, TC-483, TC-490 | Có |
| EC-245 (mốc lúc hiển thị - khác lastChangedAt) | TC-470, TC-474, TC-479, TC-482, TC-484, TC-489 | Có |
| EC-246 (trạng thái với LockStaff - ACTIVE) | TC-468, TC-473 | Có |
| EC-247 (trạng thái với LockStaff - LOCKED) | TC-469 | Có |
| BV-84 (độ dài email (EC sf_email_ok) - 254 ký tự) | TC-466 | Có |
| BV-85 (độ dài email - 255 ký tự) | TC-467 | Có |
| BV-86 (độ dài họ tên - 0 ký tự) | TC-458 | Có |
| BV-87 (độ dài họ tên - 1 ký tự) | TC-456 | Có |
| BV-88 (độ dài họ tên - 100 ký tự) | TC-459 | Có |
| BV-89 (độ dài họ tên - 101 ký tự) | TC-460 | Có |
| EC-248 (chủ lần đặt - customerId bằng khách) | TC-491, TC-499, TC-500 | Có |
| EC-249 (chủ lần đặt - customerId của khách khác) | TC-492, TC-498 | Có |
| EC-250 (chủ lần đặt - không có customerId (mua tại quầy)) | TC-493 | Có |
| EC-251 (sửa thông tin sau khi bán - tên phim, cụm rạp, phòng đổi) | TC-494, TC-495 | Có |
| EC-252 (số lần đặt - 0, 1, nhiều) | TC-496, TC-497 | Có |
| EC-253 (lần giữ ghế của người giữ - ACTIVE, now trước expiryTime) | TC-501 | Có |
| EC-254 (lần giữ ghế của người giữ - ACTIVE nhưng now không trước expiryTime) | TC-502, TC-504 | Có |
| EC-255 (lần giữ ghế của người giữ - không có) | TC-503 | Có |
| EC-256 (GetHold với by - không phải người giữ) | TC-506, TC-507, TC-509, TC-510, TC-511 | Có |
| EC-257 (GetHold với trạng thái - COMPLETED) | TC-505 | Có |
| BV-90 (now so với expiryTime (EC qh_active) - now = E - 1ms) | TC-501, TC-508 | Có |
| BV-91 (now so với expiryTime (EC qh_late) - now = E) | TC-502, TC-512 | Có |
| EC-258 (ngày chiếu của suất - trong [releaseDate, endOfRunDate]) | TC-521, TC-522 | Có |
| EC-259 (ngày chiếu của suất - trước releaseDate hoặc sau endOfRunDate) | TC-517, TC-520, TC-523 | Có |
| EC-260 (định dạng - thuộc releaseFormats) | TC-518, TC-530 | Có |
| EC-261 (định dạng - không thuộc releaseFormats) | TC-519, TC-531 | Có |
| EC-262 (khoảng cách tới suất khác trong phòng - từ 15 phút) | TC-524, TC-526, TC-528, TC-529 | Có |
| EC-263 (khoảng cách - dưới 15 phút hoặc giao nhau) | TC-525, TC-527 | Có |
| EC-264 (giờ bắt đầu so với now - sau now) | TC-535 | Có |
| EC-265 (giờ bắt đầu so với now - bằng hoặc trước now) | TC-534 | Có |
| EC-266 (đổi phòng - cùng phòng, hoặc khác phòng và chưa từng có vé) | TC-536, TC-537 | Có |
| EC-267 (đổi phòng - khác phòng và từng có vé (kể cả đã huỷ)) | TC-538 | Có |
| EC-268 (phòng chiếu - chưa từng có suất chiếu) | TC-532 | Có |
| EC-269 (phòng chiếu - từng có suất chiếu (kể cả đã xoá)) | TC-533 | Có |
| EC-270 (tên cụm rạp - không trùng cụm rạp khác sau chuẩn hoá) | TC-539, TC-540 | Có |
| EC-271 (tên cụm rạp - trùng chính cụm rạp đang sửa) | TC-541 | Có |
| EC-272 (tên cụm rạp - trùng cụm rạp khác) | TC-542 | Có |
| EC-273 (mốc lúc hiển thị - bằng lastChangedAt) | TC-543 | Có |
| EC-274 (mốc lúc hiển thị - lastChangedAt sau mốc) | TC-544, TC-545, TC-546 | Có |
| BV-92 (ngày đầu khoảng chiếu (EC sc_run_in) - start = releaseDate 00:00 (+07:00)) | TC-513 | Có |
| BV-93 (trước ngày đầu - releaseDate - 1 ngày 23:59:59.999) | TC-514 | Có |
| BV-94 (ngày cuối - endOfRunDate 23:59:59.999) | TC-515 | Có |
| BV-95 (sau ngày cuối - endOfRunDate + 1 ngày 00:00) | TC-516 | Có |
| BV-96 (khoảng cách (EC sc_gap_ok) - đúng 15 phút) | TC-524 | Có |
| BV-97 (khoảng cách - 14 phút 59 giây) | TC-525 | Có |
| BV-98 (giờ bắt đầu so với now - bằng now) | TC-534 | Có |
| BV-99 (giờ bắt đầu so với now - now + 1ms) | TC-535 | Có |
| EC-275 (kỳ - có từ ngày, có đến ngày, từ ngày không sau đến ngày) | TC-547, TC-553, TC-559 | Có |
| EC-276 (kỳ - thiếu từ ngày) | TC-550, TC-552 | Có |
| EC-277 (kỳ - có từ ngày, thiếu đến ngày) | TC-551 | Có |
| EC-278 (kỳ - từ ngày sau đến ngày) | TC-549, TC-558 | Có |
| EC-279 (sức chứa của nhóm - bằng 0) | TC-555, TC-560 | Có |
| EC-280 (sức chứa của nhóm - lớn hơn 0) | TC-557, TC-560 | Có |
| BV-100 (từ ngày so với đến ngày (EC rp_ok) - từ ngày = đến ngày) | TC-548, TC-554 | Có |
| BV-101 (từ ngày so với đến ngày - từ ngày = đến ngày + 1) | TC-549 | Có |
| BV-102 (sức chứa - 1) | TC-556 | Có |
| EC-281 (suất chiếu - IN_SCHEDULE, bắt đầu sau now, khớp mọi tiêu chí) | TC-563 | Có |
| EC-282 (suất chiếu - bắt đầu bằng hoặc trước now) | TC-561 | Có |
| EC-283 (suất chiếu - status khác IN_SCHEDULE) | TC-562 | Có |
| EC-284 (tiêu chí - mọi trường rỗng) | TC-561, TC-565 | Có |
| EC-285 (ngày chiếu - khác date theo múi giờ) | TC-564 | Có |
| BV-103 (StartTime so với now - bằng now) | TC-561 | Có |
| BV-104 (StartTime so với now - now + 1ms) | TC-561 | Có |
| BV-105 (ngày chiếu theo múi giờ - 2026-11-10 17:00:00Z (đúng 00:00 ngày 11 +07:00)) | TC-564 | Có |
| EC-286 (lỗi phiên - StaffAccessRevokedError, StaffAccessChangedError, LoginFailedError) | TC-566, TC-567, TC-568, TC-587, TC-588, TC-589, TC-591 | Có |
| EC-287 (lỗi quyền - ChannelMismatchError, BookingNotOwnedError, StaffLockedError) | TC-569, TC-570, TC-590, TC-592 | Có |
| EC-288 (lỗi không có dòng - NotFoundError) | TC-571 | Có |
| EC-289 (lỗi trạng thái - HolderBusy, SeatUnavailable, HoldNotActive, StaleStaff, DuplicateAccount) | TC-572, TC-573, TC-574, TC-575, TC-576 | Có |
| EC-290 (lỗi dữ liệu nhập - SeatSelection, RegistrationData, StaffData) | TC-577, TC-578 | Có |
| EC-291 (lỗi tạm thời - SystemBusyError, context deadline) | TC-579, TC-580 | Có |
| EC-292 (lỗi lập trình hoặc không phân loại - LockOrderViolationError, PaymentStateError, LinkMismatchError, lỗi lạ) | TC-581, TC-582, TC-583 | Có |
| EC-293 (cùng lỗi, hai scope - ShowtimeChangedError với BOOKING và SCHEDULE) | TC-585, TC-586 | Có |
| EC-294 (lỗi bọc - fmt.Errorf("%w") quanh lỗi nghiệp vụ) | TC-584 | Có |
| EC-295 (mật khẩu - chuỗi không rỗng) | TC-593 | Có |
| EC-296 (role - thuộc allowedRoles) | TC-594 | Có |
| EC-297 (role - không thuộc allowedRoles) | TC-595 | Có |
| EC-298 (claims nhân viên - có accessChangedAt) | TC-596, TC-597 | Có |
| EC-299 (IpnAnswer - một trong 7 giá trị) | TC-618, TC-619, TC-620, TC-621, TC-622, TC-623, TC-624 | Có |
| EC-300 (tham số và chữ ký - chữ ký sinh từ chính tham số) | TC-625, TC-626 | Có |
| EC-301 (tham số và chữ ký - một tham số đổi hoặc chữ ký đổi một ký tự) | TC-627, TC-628, TC-629 | Có |
| EC-302 (tham số báo - đủ tham số) | TC-630 | Không: chờ Q-355 |
| EC-303 (tham số báo - thiếu số tiền) | TC-631 | Có |
| EC-304 (hàng đợi - còn chỗ (dưới 256)) | TC-632 | Có |
| EC-305 (hàng đợi - đã đủ 256) | TC-633, TC-634 | Có |
| EC-306 (mã sự kiện - chưa phát) | TC-635, TC-639 | Có |
| EC-307 (mã sự kiện - đã phát) | TC-635 | Có |
| EC-308 (số kết nối của một IP - dưới 10) | TC-640, TC-642 | Có |
| EC-309 (số kết nối của một IP - đã 10) | TC-641 | Có |
| EC-310 (RunDue - trả nil) | TC-644, TC-647 | Có |
| EC-311 (RunDue - trả lỗi hoặc panic) | TC-645, TC-646 | Có |
| BV-106 (số phần tử (EC sq_room) - 255 phần tử rồi Offer) | TC-632 | Có |
| BV-107 (số phần tử - 256 phần tử rồi Offer) | TC-633 | Có |
| BV-108 (số kết nối (EC il_ok) - 9 rồi TryAcquire) | TC-640, TC-643 | Có |
| BV-109 (số kết nối - 10 rồi TryAcquire) | TC-641 | Có |
| BV-110 (tuổi dòng đã phát - 10 giây và 1 ms (cũ hơn 10 giây); đúng 10 giây không tiến) | TC-636, TC-637 | Có |
| BV-111 (tuổi mã đã phát - 20 giây và 1 ms) | TC-638 | Có |
| DT1-R1 (quy tắc bảng quyết định DT1-R1) | TC-101, TC-102 | Có |
| DT1-R2 (quy tắc bảng quyết định DT1-R2) | TC-103, TC-104 | Có |
| DT1-R3 (quy tắc bảng quyết định DT1-R3) | TC-105, TC-108 | Có |
| DT1-R4 (quy tắc bảng quyết định DT1-R4) | TC-106 | Có |
| DT1-R5 (quy tắc bảng quyết định DT1-R5) | TC-107 | Có |
| DT1-R6 (quy tắc bảng quyết định DT1-R6) | - | N/A (quy tắc không thể xảy ra theo bảng quyết định) |
| DT2-R1 (quy tắc bảng quyết định DT2-R1) | TC-116 | Có |
| DT2-R2 (quy tắc bảng quyết định DT2-R2) | TC-117 | Có |
| DT2-R3 (quy tắc bảng quyết định DT2-R3) | TC-118 | Có |
| DT2-R4 (quy tắc bảng quyết định DT2-R4) | TC-119 | Có |
| DT2-R5 (quy tắc bảng quyết định DT2-R5) | TC-120 | Có |
| DT3-R1 (quy tắc bảng quyết định DT3-R1) | TC-134, TC-135, TC-137 | Có |
| DT3-R2 (quy tắc bảng quyết định DT3-R2) | TC-136 | Có |
| DT3-R3 (quy tắc bảng quyết định DT3-R3) | TC-131 | Có |
| DT3-R4 (quy tắc bảng quyết định DT3-R4) | TC-130 | Có |
| DT3-R5 (quy tắc bảng quyết định DT3-R5) | TC-127, TC-128, TC-129 | Có |
| DT4-R1 (quy tắc bảng quyết định DT4-R1) | TC-174 | Có |
| DT4-R2 (quy tắc bảng quyết định DT4-R2) | TC-189, TC-190 | Có |
| DT4-R3 (quy tắc bảng quyết định DT4-R3) | TC-178 | Có |
| DT4-R4 (quy tắc bảng quyết định DT4-R4) | TC-186, TC-200, TC-203 | Có |
| DT4-R5 (quy tắc bảng quyết định DT4-R5) | TC-191, TC-201 | Có |
| DT4-R6 (quy tắc bảng quyết định DT4-R6) | TC-196, TC-197, TC-202 | Có |
| DT4-R7 (quy tắc bảng quyết định DT4-R7) | TC-198 | Có |
| DT4-R8 (quy tắc bảng quyết định DT4-R8) | TC-204 | Có |
| DT4-R9 (quy tắc bảng quyết định DT4-R9) | TC-205 | Có |
| DT4-R10 (quy tắc bảng quyết định DT4-R10) | TC-206 | Có |
| DT10-R1 (quy tắc bảng quyết định DT10-R1) | TC-652 | Có |
| DT10-R2 (quy tắc bảng quyết định DT10-R2) | TC-651 | Có |
| DT10-R3 (quy tắc bảng quyết định DT10-R3) | TC-653 | Có |
| DT10-R4 (quy tắc bảng quyết định DT10-R4) | TC-648 | Có |
| DT5-R1 (quy tắc bảng quyết định DT5-R1) | TC-207, TC-208 | Có |
| DT5-R2 (quy tắc bảng quyết định DT5-R2) | TC-209 | Có |
| DT5-R3 (quy tắc bảng quyết định DT5-R3) | TC-210, TC-211 | Có |
| DT5-R4 (quy tắc bảng quyết định DT5-R4) | TC-212 | Có |
| DT5-R5 (quy tắc bảng quyết định DT5-R5) | TC-213 | Có |
| DT5-R6 (quy tắc bảng quyết định DT5-R6) | TC-214, TC-215 | Có |
| DT5-R7 (quy tắc bảng quyết định DT5-R7) | - | N/A (quy tắc không thể xảy ra theo bảng quyết định) |
| DT6-R1 (quy tắc bảng quyết định DT6-R1) | TC-256, TC-258 | Có |
| DT6-R2 (quy tắc bảng quyết định DT6-R2) | TC-257 | Có |
| DT6-R3 (quy tắc bảng quyết định DT6-R3) | TC-251 | Có |
| DT6-R4 (quy tắc bảng quyết định DT6-R4) | TC-255 | Có |
| DT6-R5 (quy tắc bảng quyết định DT6-R5) | TC-239 | Có |
| DT6-R6 (quy tắc bảng quyết định DT6-R6) | TC-241, TC-242, TC-243 | Có |
| DT6-R7 (quy tắc bảng quyết định DT6-R7) | TC-245, TC-246 | Có |
| DT6-R8 (quy tắc bảng quyết định DT6-R8) | TC-247, TC-248, TC-250 | Có |
| DT6-R9 (quy tắc bảng quyết định DT6-R9) | TC-260, TC-261 | Có |
| DT7-R1 (quy tắc bảng quyết định DT7-R1) | TC-287 | Có |
| DT7-R2 (quy tắc bảng quyết định DT7-R2) | TC-291, TC-292, TC-295, TC-303, TC-304 | Có |
| DT7-R3 (quy tắc bảng quyết định DT7-R3) | TC-289, TC-296, TC-305 | Có |
| DT7-R4 (quy tắc bảng quyết định DT7-R4) | TC-293 | Có |
| DT7-R5 (quy tắc bảng quyết định DT7-R5) | TC-294, TC-306 | Có |
| DT7-R6 (quy tắc bảng quyết định DT7-R6) | - | N/A (quy tắc không thể xảy ra theo bảng quyết định) |
| DT8-R1 (quy tắc bảng quyết định DT8-R1) | TC-334 | Có |
| DT8-R2 (quy tắc bảng quyết định DT8-R2) | TC-336, TC-337 | Có |
| DT8-R3 (quy tắc bảng quyết định DT8-R3) | TC-339 | Có |
| DT8-R4 (quy tắc bảng quyết định DT8-R4) | TC-323 | Có |
| DT8-R5 (quy tắc bảng quyết định DT8-R5) | TC-325, TC-326 | Có |
| DT8-R6 (quy tắc bảng quyết định DT8-R6) | - | N/A (quy tắc không thể xảy ra theo bảng quyết định) |
| DT8-R7 (quy tắc bảng quyết định DT8-R7) | TC-329 | Có |
| DT8-R8 (quy tắc bảng quyết định DT8-R8) | TC-328, TC-338 | Có |
| DT8-R9 (quy tắc bảng quyết định DT8-R9) | TC-327 | Có |
| DT8-R10 (quy tắc bảng quyết định DT8-R10) | TC-332, TC-333 | Có |
| DT8-R11 (quy tắc bảng quyết định DT8-R11) | TC-330, TC-331 | Có |
| DT9-R1 (quy tắc bảng quyết định DT9-R1) | TC-385 | Có |
| DT9-R2 (quy tắc bảng quyết định DT9-R2) | TC-386 | Có |
| DT9-R3 (quy tắc bảng quyết định DT9-R3) | TC-388 | Có |
| DT9-R4 (quy tắc bảng quyết định DT9-R4) | TC-390 | Có |
| DT9-R5 (quy tắc bảng quyết định DT9-R5) | TC-391, TC-396 | Có |
| DT9-R6 (quy tắc bảng quyết định DT9-R6) | TC-394, TC-395 | Có |
| DT9-R7 (quy tắc bảng quyết định DT9-R7) | TC-397 | Có |
| DT9-R8 (quy tắc bảng quyết định DT9-R8) | TC-398, TC-399 | Có |
| DT13-R1 (quy tắc bảng quyết định DT13-R1) | TC-419 | Có |
| DT13-R2 (quy tắc bảng quyết định DT13-R2) | TC-422 | Có |
| DT13-R3 (quy tắc bảng quyết định DT13-R3) | TC-421 | Có |
| DT12-R1 (quy tắc bảng quyết định DT12-R1) | TC-429 | Có |
| DT12-R2 (quy tắc bảng quyết định DT12-R2) | TC-430 | Có |
| DT12-R3 (quy tắc bảng quyết định DT12-R3) | TC-431 | Có |
| DT12-R4 (quy tắc bảng quyết định DT12-R4) | TC-435 | Có |
| DT12-R5 (quy tắc bảng quyết định DT12-R5) | TC-436 | Có |
| DT12-R6 (quy tắc bảng quyết định DT12-R6) | TC-436 | Có |
| DT12-R7 (quy tắc bảng quyết định DT12-R7) | TC-437 | Có |
| DT12-R8 (quy tắc bảng quyết định DT12-R8) | TC-436 | Có |
| DT14-R1 (quy tắc bảng quyết định DT14-R1) | TC-468 | Có |
| DT14-R2 (quy tắc bảng quyết định DT14-R2) | TC-469 | Có |
| DT14-R3 (quy tắc bảng quyết định DT14-R3) | TC-470 | Có |
| DT14-R4 (quy tắc bảng quyết định DT14-R4) | TC-471 | Có |

F4.2. Quy tắc nghiệp vụ (BR) và NFR liên quan tới phương thức trong phạm vi. Mọi BR ghi ở cột Nguồn của F3 xuất hiện ở đây; mục chỉ có TC tích hợp ghi rõ.

| BR hoặc NFR | TC phủ | Đạt |
|---|---|---|
| BR-01 | unit: TC-147, TC-148, TC-149, TC-150, TC-189 | Có (unit) |
| BR-02 | unit: TC-510, TC-648, TC-651 | Có (unit) |
| BR-04 | unit: TC-024, TC-121, TC-122, TC-123, TC-124, TC-125, TC-126, TC-186, TC-187, TC-188, TC-200, TC-501; tích hợp: TC-365, TC-384 | Có (unit và tích hợp) |
| BR-05 | unit: TC-026, TC-027, TC-152, TC-153, TC-154, TC-155, TC-175, TC-176, TC-177, TC-178, TC-179, TC-392, TC-393 | Có (unit) |
| BR-06 | unit: TC-158 | Có (unit) |
| BR-07 | unit: TC-030, TC-174, TC-195, TC-196; tích hợp: TC-363, TC-364 | Có (unit và tích hợp) |
| BR-08 | unit: TC-030, TC-031, TC-196 | Có (unit) |
| BR-09 | unit: TC-031, TC-032, TC-036, TC-193, TC-197; tích hợp: TC-363, TC-364, TC-366, TC-367, TC-384 | Có (unit và tích hợp) |
| BR-10 | unit: TC-001, TC-002, TC-003, TC-005, TC-006, TC-007, TC-174, TC-187, TC-217, TC-268, TC-385, TC-386, TC-387, TC-389, và 3 TC khác; tích hợp: TC-375 | Có (unit và tích hợp) |
| BR-11 | unit: TC-164, TC-165, TC-166, TC-167, TC-168, TC-169, TC-170, TC-171 | Có (unit) |
| BR-12 | unit: TC-164, TC-165, TC-166, TC-167, TC-168, TC-169, TC-170, TC-171, TC-173 | Có (unit) |
| BR-14 | unit: TC-006, TC-047, TC-070, TC-210, TC-240, TC-241, TC-265, TC-317; tích hợp: TC-372 | Có (unit và tích hợp) |
| BR-15 | unit: TC-051, TC-211, TC-212, TC-213, TC-242, TC-243, TC-264; tích hợp: TC-371 | Có (unit và tích hợp) |
| BR-16 | unit: TC-059, TC-246 | Có (unit) |
| BR-17 | unit: TC-116, TC-117, TC-118, TC-119, TC-120, TC-287, TC-291, TC-292, TC-295, TC-302, TC-303, TC-304, TC-348, TC-349, và 3 TC khác | Có (unit) |
| BR-18 | unit: TC-142, TC-143, TC-144, TC-145, TC-146, TC-288, TC-289, TC-290, TC-305, TC-508, TC-512, TC-655 | Có (unit) |
| BR-19 | unit: TC-071, TC-109, TC-110, TC-287, TC-299, TC-319, TC-346 | Có (unit) |
| BR-20 | unit: TC-073, TC-655 | Có (unit) |
| BR-21 | unit: TC-098, TC-099, TC-287, TC-293, TC-302, TC-511, TC-657; tích hợp: TC-378 | Có (unit và tích hợp) |
| BR-22 | unit: TC-101, TC-107, TC-308, TC-309 | Có (unit) |
| BR-23 | unit: TC-103, TC-107, TC-310 | Có (unit) |
| BR-24 | unit: TC-105, TC-107, TC-108, TC-231, TC-308, TC-311, TC-314; tích hợp: TC-376 | Có (unit và tích hợp) |
| BR-25 | unit: TC-106, TC-312, TC-315; tích hợp: TC-377 | Có (unit và tích hợp) |
| BR-26 | unit: TC-063, TC-064, TC-065, TC-066, TC-067, TC-068, TC-297, TC-317, TC-318, TC-319, TC-320, TC-321, TC-322; tích hợp: TC-378, TC-379, TC-384 | Có (unit và tích hợp) |
| BR-30 | unit: TC-100, TC-294, TC-306, TC-315, TC-316; tích hợp: TC-376, TC-377 | Có (unit và tích hợp) |
| BR-31 | unit: TC-110, TC-111, TC-112, TC-113, TC-114, TC-299, TC-346, TC-508 | Có (unit) |
| BR-32 | unit: TC-142, TC-143, TC-144, TC-145, TC-288, TC-289, TC-512, TC-655 | Có (unit) |
| BR-33 | unit: TC-101, TC-102, TC-104, TC-105, TC-106 | Có (unit) |
| BR-34 | unit: TC-350, TC-351 | Có (unit) |
| BR-37 | unit: TC-010, TC-046, TC-049, TC-054, TC-055, TC-057, TC-059, TC-061, TC-062, TC-207, TC-208, TC-209, TC-239, TC-245, và 3 TC khác; tích hợp: TC-370, TC-384 | Có (unit và tích hợp) |
| BR-38 | unit: TC-251 | Có (unit) |
| BR-39 | unit: TC-012, TC-021, TC-048, TC-052, TC-056, TC-060, TC-214, TC-215, TC-247, TC-249, TC-250, TC-260, TC-395, TC-396 | Có (unit) |
| BR-40 | unit: TC-254 | Có (unit) |
| BR-41 | unit: TC-076, TC-078, TC-079, TC-081, TC-083, TC-084, TC-085, TC-086, TC-087, TC-088, TC-093, TC-323, TC-324, TC-325, và 8 TC khác; tích hợp: TC-381 | Có (unit và tích hợp) |
| BR-42 | unit: TC-042, TC-287, TC-298, TC-302, TC-307 | Có (unit) |
| BR-43 | unit: TC-070, TC-071, TC-072, TC-075, TC-082, TC-085, TC-317, TC-319, TC-323, TC-326, TC-327, TC-329, TC-344; tích hợp: TC-380, TC-598 | Có (unit và tích hợp) |
| BR-44 | unit: TC-010, TC-225, TC-226, TC-227 | Có (unit) |
| BR-45 | unit: TC-147, TC-148, TC-149, TC-150, TC-190, TC-653 | Có (unit) |
| BR-47 | unit: TC-518, TC-519 | Có (unit) |
| BR-48 | unit: TC-530, TC-531 | Có (unit) |
| BR-49 | unit: TC-513, TC-514, TC-515, TC-516, TC-517 | Có (unit) |
| BR-51 | unit: TC-524, TC-525, TC-526, TC-527, TC-528, TC-529; tích hợp: TC-602 | Có (unit và tích hợp) |
| BR-52 | tích hợp: TC-602 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| BR-53 | unit: TC-022, TC-023 | Có (unit) |
| BR-54 | unit: TC-160, TC-161, TC-162, TC-182, TC-191, TC-201 | Có (unit) |
| BR-56 | unit: TC-534, TC-535, TC-561 | Có (unit) |
| BR-57 | unit: TC-534, TC-535 | Có (unit) |
| BR-58 | unit: TC-151, TC-529, TC-562 | Có (unit) |
| BR-60 | tích hợp: TC-602 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| BR-65 | unit: TC-025, TC-026, TC-027, TC-030, TC-174 | Có (unit) |
| BR-67 | unit: TC-225, TC-400 | Có (unit) |
| BR-72 | unit: TC-172, TC-198, TC-202 | Có (unit) |
| BR-76 | unit: TC-520, TC-521, TC-522, TC-523 | Có (unit) |
| BR-78 | unit: TC-456, TC-462, TC-463, TC-464, TC-485 | Có (unit) |
| BR-79 | unit: TC-456, TC-465, TC-487 | Có (unit) |
| BR-80 | unit: TC-225, TC-400 | Có (unit) |
| BR-81 | unit: TC-429, TC-430, TC-436 | Có (unit) |
| BR-82 | unit: TC-429, TC-431, TC-432, TC-433, TC-434, TC-437 | Có (unit) |
| BR-84 | tích hợp: TC-604 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| BR-85 | unit: TC-011, TC-012, TC-022, TC-033, TC-034, TC-040, TC-216, TC-217, TC-231, TC-239, TC-240, TC-262, TC-263, TC-264, và 4 TC khác; tích hợp: TC-370, TC-371, TC-372, TC-600 | Có (unit và tích hợp) |
| BR-86 | unit: TC-008, TC-009, TC-013, TC-014, TC-015, TC-016, TC-017, TC-018, TC-019, TC-020, TC-021, TC-024, TC-184, TC-185, và 27 TC khác; tích hợp: TC-371, TC-372, TC-384, TC-600, TC-601 | Có (unit và tích hợp) |
| BR-88 | unit: TC-555, TC-556, TC-557, TC-560 | Có (unit) |
| BR-90 | unit: TC-232, TC-233, TC-236 | Có (unit) |
| BR-91 | unit: TC-253, TC-255, TC-260, TC-261 | Có (unit) |
| BR-92 | unit: TC-536, TC-537, TC-538 | Có (unit) |
| BR-93 | unit: TC-247, TC-248 | Có (unit) |
| BR-94 | unit: TC-491, TC-492, TC-493, TC-495, TC-496, TC-498 | Có (unit) |
| BR-95 | unit: TC-485, TC-486; tích hợp: TC-610 | Có (unit và tích hợp) |
| BR-96 | unit: TC-468 | Có (unit) |
| BR-97 | unit: TC-422, TC-426, TC-450, TC-468, TC-649 | Có (unit) |
| BR-98 | unit: TC-440, TC-441, TC-442, TC-444; tích hợp: TC-609 | Có (unit và tích hợp) |
| BR-99 | unit: TC-429, TC-435 | Có (unit) |
| BR-100 | unit: TC-423, TC-490; tích hợp: TC-612 | Có (unit và tích hợp) |
| BR-101 | unit: TC-419, TC-421, TC-422, TC-423, TC-424, TC-425, TC-426, TC-427, TC-449, TC-468, TC-476, TC-478, TC-490, TC-591, và 5 TC khác; tích hợp: TC-612, TC-613 | Có (unit và tích hợp) |
| BR-102 | unit: TC-470, TC-472, TC-479, TC-482, TC-484, TC-489; tích hợp: TC-611 | Có (unit và tích hợp) |
| BR-136 | tích hợp: TC-607 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| BR-138 | unit: TC-545; tích hợp: TC-603 | Có (unit và tích hợp) |
| BR-139 | tích hợp: TC-604 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| BR-140 | unit: TC-400, TC-494, TC-495, TC-500 | Có (unit) |
| BR-141 | unit: TC-539, TC-540, TC-541, TC-542; tích hợp: TC-605, TC-616 | Có (unit và tích hợp) |
| BR-142 | unit: TC-543, TC-544; tích hợp: TC-605 | Có (unit và tích hợp) |
| BR-145 | tích hợp: TC-606, TC-616 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| BR-146 | unit: TC-546; tích hợp: TC-608 | Có (unit và tích hợp) |
| BR-147 | unit: TC-532, TC-533; tích hợp: TC-607, TC-616 | Có (unit và tích hợp) |
| NFR-01 | unit: TC-353, TC-354, TC-445, TC-446, TC-448, TC-593 | Có (unit) |
| NFR-02 | unit: TC-353, TC-357, TC-452 | Có (unit) |
| NFR-03 | unit: TC-358, TC-453, TC-454 | Có (unit) |
| NFR-05 | tích hợp: TC-366 | Có (tích hợp: loại trừ thật cần PostgreSQL) |
| NFR-06 | unit: TC-174, TC-199; tích hợp: TC-366, TC-367, TC-382, TC-617 | Có (unit và tích hợp) |
| NFR-07 | unit: TC-267, TC-268, TC-272, TC-279, TC-283, TC-284, TC-285, TC-286; tích hợp: TC-372, TC-375 | Có (unit và tích hợp) |
| NFR-08 | unit: TC-632, TC-633; tích hợp: TC-383 | Có (unit và tích hợp) |
| NFR-14 | unit: TC-313 | Có (unit) |
| NFR-15 | unit: TC-232 | Có (unit) |
| NFR-16 | unit: TC-256, TC-625, TC-627, TC-628, TC-629 | Có (unit) |

F4.3. Luồng thay thế và ngoại lệ của đặc tả use case (P04) liên quan (chỉ các luồng có TC trích dẫn ở cột Nguồn của F3).

| Luồng P04 | TC phủ | Đạt |
|---|---|---|
| UC-001 2a | TC-430 | Có |
| UC-001 2b | TC-431, TC-439 | Có |
| UC-001 2c | TC-435 | Có |
| UC-001 7a | TC-440, TC-441 | Có |
| UC-004 1a4a | TC-565 | Có |
| UC-004 4a | TC-565 | Có |
| UC-005 *a | TC-011, TC-020, TC-037, TC-211, TC-216, TC-221, TC-235, TC-242, TC-264 | Có |
| UC-005 10a | TC-236 | Có |
| UC-005 11a | TC-012, TC-037, TC-048, TC-214, TC-224, TC-247, TC-248 | Có |
| UC-005 2a | TC-147, TC-189, TC-653 | Có |
| UC-005 2b | TC-648, TC-651 | Có |
| UC-005 2c | TC-150, TC-190, TC-204, TC-206 | Có |
| UC-005 5a | TC-587 | Có |
| UC-005 5a2 | TC-445 | Có |
| UC-005 5a2a | TC-354, TC-448 | Có |
| UC-005 5b | TC-123, TC-125, TC-186 | Có |
| UC-005 6a | TC-155, TC-179, TC-205, TC-206 | Có |
| UC-005 7a | TC-196, TC-197, TC-201, TC-202, TC-203 | Có |
| UC-005 7b | TC-006, TC-020, TC-037, TC-218, TC-234, TC-265 | Có |
| UC-005 7c | TC-123, TC-186, TC-200, TC-203, TC-204, TC-205, TC-365 | Có |
| UC-005 7d | TC-161, TC-162, TC-182, TC-191, TC-200, TC-201 | Có |
| UC-005 7e | TC-172, TC-198, TC-202 | Có |
| UC-005 9a | TC-225 | Có |
| UC-005 9a1a | TC-227 | Có |
| UC-005 9a2 | TC-225, TC-226 | Có |
| UC-005 9a4 | TC-225 | Có |
| UC-006 2a | TC-057, TC-061, TC-207, TC-208, TC-245, TC-246 | Có |
| UC-006 2c | TC-249 | Có |
| UC-006 2d | TC-056, TC-215, TC-250 | Có |
| UC-006 2e | TC-251 | Có |
| UC-006 2f | TC-255 | Có |
| UC-006 4a | TC-085, TC-326 | Có |
| UC-006 4b | TC-088, TC-093, TC-330 | Có |
| UC-006 4t | TC-327, TC-328, TC-329, TC-330, TC-331 | Có |
| UC-006 5a | TC-084, TC-325, TC-327 | Có |
| UC-006 5b | TC-087, TC-333 | Có |
| UC-007 3a | TC-492 | Có |
| UC-008 1a1a | TC-347 | Có |
| UC-008 1a2 | TC-346 | Có |
| UC-008 2a | TC-117, TC-118, TC-291, TC-292, TC-295, TC-509 | Có |
| UC-008 2b | TC-119, TC-303, TC-349 | Có |
| UC-008 2c | TC-304, TC-348, TC-510 | Có |
| UC-008 3a | TC-142, TC-143, TC-144, TC-145, TC-146, TC-289, TC-290, TC-295, TC-305, TC-512 | Có |
| UC-008 4a | TC-099, TC-293, TC-511, TC-657 | Có |
| UC-008 4b | TC-100, TC-294, TC-306, TC-316, TC-377 | Có |
| UC-008 4e | TC-377 | Có |
| UC-008 5a | TC-120 | Có |
| UC-008 5a1 | TC-109, TC-110, TC-111, TC-112, TC-113, TC-114, TC-302 | Có |
| UC-008 5a2 | TC-073, TC-302 | Có |
| UC-008 5b | TC-326 | Có |
| UC-008 5c | TC-330 | Có |
| UC-008 5t | TC-327 | Có |
| UC-008 6a | TC-325 | Có |
| UC-008 6b | TC-333 | Có |
| UC-009 4a | TC-313 | Có |
| UC-009 4b | TC-101, TC-102, TC-309 | Có |
| UC-009 4c | TC-103, TC-104, TC-310 | Có |
| UC-009 4d | TC-105, TC-108, TC-311, TC-314, TC-376 | Có |
| UC-009 4e | TC-106, TC-312, TC-315 | Có |
| UC-011 5b | TC-542 | Có |
| UC-015 1a | TC-549, TC-550, TC-551, TC-558 | Có |
| UC-015 2a | TC-559 | Có |
| UC-017 1a | TC-427, TC-476, TC-490 | Có |
| UC-017 1b3 | TC-468 | Có |
| UC-017 1b3a | TC-469 | Có |
| UC-017 1b3b | TC-470 | Có |
| UC-017 1c3a | TC-473, TC-475 | Có |
| UC-017 1c3b | TC-474, TC-475 | Có |
| UC-017 1d | TC-480, TC-481 | Có |
| UC-017 1d4b | TC-482 | Có |
| UC-017 1e | TC-483 | Có |
| UC-017 1e4a | TC-484 | Có |
| UC-017 4a | TC-463 | Có |
| UC-017 4b | TC-464 | Có |
| UC-017 4c | TC-457 | Có |
| UC-017 4d | TC-458 | Có |
| UC-017 5a | TC-486 | Có |
| UC-017 5b | TC-479, TC-489 | Có |

F4.4. Cặp loại trừ X-nn trong phạm vi (00-Concurrency.md M9: mỗi X-nn có ca thử cho từng thứ tự đến khác kết cục). Ca unit chạy tuần tự trên IF-08 giả và chứng minh kết cục sau khi có khoá; loại trừ thật là ca tích hợp (F2.40, F2.55).

| Cặp loại trừ | TC phủ | Đạt |
|---|---|---|
| X-01: EX-01 với EX-01 cùng suất chiếu: một bên giữ được, bên kia bị từ chối (BR-07, BR-09) | unit: TC-031, TC-193, TC-648; tích hợp: TC-363, TC-364 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-02: EX-01 với EX-01 cùng người giữ khác suất chiếu: bên sau thấy lần giữ ghế chưa kết thúc (BR-04) | unit: TC-186; tích hợp: TC-365 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-03: EX-01 với EX-13, EX-14: phía EX-01 (suất chiếu đã đổi thì bị từ chối); phía EX-13, EX-14 thuộc UC-014 chưa chi tiết hoá | unit: TC-161; tích hợp: - | Có (unit) |
| X-04: EX-01 với EX-11, EX-12 (giá): phía EX-11, EX-12 thuộc UC-013 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-05: EX-11, EX-12: UC-013 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-06: EX-12 với EX-13: UC-013, UC-014 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-07: EX-13 với EX-13 (cùng phòng chiếu hoặc suất chiếu): chỉ một yêu cầu được lưu (BR-52, BR-60) | unit: TC-524, TC-525, TC-527, TC-528; tích hợp: TC-602 | Có (một phía: lập suất chiếu giao nhau hoặc cách dưới 15 phút; phía sửa cùng suất chiếu chưa có TC) |
| X-08: EX-13, EX-14: UC-014 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-09: EX-02, EX-03 với EX-02, EX-03 cùng lần giữ ghế: báo đầu được xử lý, báo sau là báo trùng hoặc thanh toán trễ | unit: TC-227, TC-228, TC-241, TC-245, TC-262, TC-404; tích hợp: TC-370, TC-601 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-10: EX-02, EX-03 với EX-04 cùng lần giữ ghế: chỉ một trạng thái cuối; hết hạn, huỷ, báo thanh toán theo hai thứ tự | unit: TC-020, TC-218, TC-263, TC-264, TC-265, TC-266, TC-277, TC-394, TC-395, TC-398, TC-397; tích hợp: TC-371, TC-372, TC-600 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-11: EX-02, EX-03 với EX-13, EX-14: phía sửa hoặc xoá suất chiếu thuộc UC-014 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-12: EX-05 với EX-02, EX-03: không thể vừa bán vừa giải phóng cùng một ghế | unit: TC-034, TC-040, TC-221, TC-263, TC-266, TC-281, TC-386, TC-400; tích hợp: TC-371, TC-600 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-13: EX-05, EX-06 với EX-01: ghế chỉ giữ lại được sau khi đã về trống | unit: TC-038, TC-194, TC-223, TC-280, TC-386; tích hợp: TC-369, TC-374, TC-599 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-14: EX-07 với EX-08 cùng vé: bên ghi nhận trước thành công (huỷ và soát) | unit: TC-100, TC-294, TC-315, TC-316; tích hợp: TC-377 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-15: EX-07 với EX-07, EX-08 với EX-08 cùng vé: một lần huỷ hoặc một lần soát | unit: TC-099, TC-108, TC-293, TC-314; tích hợp: TC-376, TC-378 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-16: EX-09 với EX-09, EX-02: tổng đã hoàn không mất cập nhật, không vượt số đã thanh toán (BR-26) | unit: TC-066, TC-297, TC-318, TC-321, TC-322; tích hợp: TC-379 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-17: EX-10 với EX-10 cùng yêu cầu hoàn: một lời gọi cổng cho mỗi khoá chống hoàn trùng (BR-43) | unit: TC-072; tích hợp: TC-380 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-18: EX-05 với EX-05, EX-06 với EX-06 cùng ghế: chạy lặp, không trả nhầm ghế đã giữ lại hoặc bán lại | unit: TC-038, TC-041, TC-043, TC-223, TC-280, TC-282, TC-298; tích hợp: TC-374 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-19: EX-15 với EX-13, EX-14 (cùng phòng chiếu) | unit: TC-538; tích hợp: TC-602 | Có (phía EX-13 với EX-13 của i_exclude_gap; phía EX-15 chưa có TC, xem Vấn đề còn mở 2) |
| X-20: EX-13 với EX-05, EX-06: phía EX-13 thuộc UC-014 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-21: EX-15 với EX-01, EX-12: UC-012, UC-013 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-22: EX-04 với EX-05 cùng lần giữ ghế: giải phóng chỉ khi lần giữ ghế đã ở trạng thái cuối | unit: TC-279, TC-388; tích hợp: TC-375, TC-600 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-23: EX-07 với EX-13, EX-14: phía EX-13, EX-14 thuộc UC-014 chưa chi tiết hoá | - | Không: orchestration của UC-013, UC-014 (DC-ManagePriceListService, DC-ScheduleShowtimesService) chưa có TC trong lần chạy này vì vượt ngưỡng; làm tiếp bằng MA_TC_BAT_DAU = TC-660 (Vấn đề còn mở 2) |
| X-24: EX-16 với EX-16 cùng phim: bên ghi nhận sau bị từ chối ở luồng 5a, không ghi đè (BR-138) | unit: TC-545, TC-543; tích hợp: TC-603 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-25: EX-16 với EX-13 cùng phim: EX-16 trước thì EX-13 dùng phim hiện hành (luồng 8g); EX-13 trước thì suất chiếu đã lưu không đổi (BR-139, BR-84) | unit: TC-516, TC-514, TC-519; tích hợp: TC-604 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-26: EX-17 với EX-17 cùng tên hoặc cùng cụm rạp: bên sau bị từ chối ở luồng 5b hoặc 5a (BR-141, BR-142) | unit: TC-410, TC-539, TC-542, TC-541, TC-544; tích hợp: TC-605 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-27: EX-18 với EX-18, EX-15 và EX-15 với EX-15 cùng cụm rạp cùng tên phòng (BR-145) | unit: -; tích hợp: TC-606 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-28: EX-19 với EX-13 cùng phòng chiếu: kết cục theo thứ tự đến (BR-147, BR-136) | unit: TC-532, TC-533; tích hợp: TC-607 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-29: EX-19 với EX-15, EX-19: bên sau bị từ chối hoặc thấy phòng không còn (BR-146) | unit: TC-546; tích hợp: TC-608 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-30: EX-20 với EX-20 cùng email hoặc số điện thoại: bên sau bị từ chối ở luồng 7a (BR-98) | unit: TC-411, TC-412, TC-413, TC-414, TC-438, TC-440, TC-441, TC-442, TC-444; tích hợp: TC-609 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-31: EX-21 với EX-21 cùng email: bên sau bị từ chối ở luồng 5a (BR-95) | unit: TC-416, TC-485, TC-486; tích hợp: TC-610 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-32: EX-22 với EX-22 cùng tài khoản: bên sau bị từ chối, hai yêu cầu khoá thì bên sau thấy đã khoá (BR-102) | unit: TC-468, TC-469, TC-470, TC-471, TC-474, TC-479, TC-482, TC-484, TC-489; tích hợp: TC-611 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |
| X-33: EX-22 với EX-01 cùng nhân viên quầy: EX-01 trước thì lần giữ ghế giữ nguyên (BR-100); EX-22 trước thì giữ ghế bị từ chối (BR-101) | unit: TC-648, TC-649, TC-650, TC-419, TC-421, TC-422, TC-423, TC-424, TC-425, TC-426, TC-427, TC-591, TC-476; tích hợp: TC-612, TC-613 | Có (unit: logic sau khoá; tích hợp: loại trừ thật) |

F4.5. Tình huống hỏng (P09 F7.10 Bảng hỏng, 10 dòng; 00-Concurrency.md M9: mỗi dòng có ca thử hồi phục).

| Tình huống (P09 F7.10) | TC phủ | Đạt |
|---|---|---|
| 1. Tiến trình dừng giữa hai giao dịch của cùng một nghiệp vụ (StartOnlinePayment sau commit, ProcessRefund sau giao dịch 1) | unit: TC-236, TC-276, TC-338; tích hợp: TC-381 | Có |
| 2. Tiến trình dừng sau khi gọi hệ thống ngoài và trước khi ghi kết quả (RequestRefund đã gọi; email at-least-once, UC-006 7a) | unit: TC-329, TC-338; tích hợp: TC-381 | Có |
| 3. Sự kiện đến trùng, muộn, sai thứ tự; lần thử cũ khi lần thử mới đang chạy (IPN trùng, thất bại của giao dịch cũ, ClaimLostError) | unit: TC-248, TC-259, TC-262, TC-335, TC-336, TC-591; tích hợp: TC-370, TC-380, TC-598 | Có |
| 4. Giao dịch đã ghi nhưng phản hồi mất, tác nhân bấm lại (HoldSeats cùng requestId, xác nhận thu tiền hai lần, đăng ký, tạo tài khoản, lưu phim, cụm rạp, phòng, nhân viên) | unit: TC-183, TC-231, TC-444, TC-486, TC-544; tích hợp: TC-601, TC-603, TC-609, TC-611 | Có |
| 5. Nhiều bản cùng quét một hàng đợi (SKIP LOCKED, hàng rào claim_token) | unit: TC-282, TC-340; tích hợp: TC-374, TC-380, TC-598 | Có |
| 6. Tiến trình dọn dẹp ở tải đỉnh (4.000 lần giữ ghế hết hạn, ngân sách 8 giây, cleanupEvents ngữ cảnh riêng) | unit: TC-274, TC-275; tích hợp: TC-375 | Có |
| 7. Nguồn thông báo hoặc hàng đợi mất sự kiện, bên nhận lấy lại được (RELOAD_REQUIRED, SLOW_CONSUMER) | unit: TC-632, TC-633, TC-636, TC-638, TC-639; tích hợp: TC-381 | Có |
| 8. Tiến trình dừng giữa thao tác ghi nhiều bản ghi (EX-17 đến EX-21) | unit: -; tích hợp: TC-616 | Có (tích hợp: rollback trọn do một COMMIT) |
| 9. Khoá giữ lâu do giao dịch treo hoặc kết nối chết | unit: -; tích hợp: TC-367, TC-617 | Có |
| 10. Phiên của nhân viên bị thu hồi lúc đang có yêu cầu bay (EX-22 với EX-01, BR-101) | unit: TC-649, TC-421, TC-426, TC-591; tích hợp: TC-612, TC-613 | Có |

F4.6. Độ phủ hộp trắng đạt được so với mục tiêu (mức thiết kế, chưa có mã nguồn; Đo khi có mã nguồn để xác nhận). Operation có thiết kế method ở P12 F3 được tính C0, C1 theo CFG ở F2.x.6; operation còn lại ghi Đo khi có mã nguồn.

| Operation (mục F2) | C0 | C1 | V(G) | Mục tiêu | Kết luận |
|---|---|---|---|---|---|
| DC-SeatHold.NewSeatHold (F2.1) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SeatHold.Expire (F2.2) | 4/4 (100%) | 7/7 (100%) | 3 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatHold.Complete, Cancel, FailPayment (F2.3) | 4/4 (100%) | 6/7 (100%) | 3 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatHold.IsActiveAt (F2.4) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SeatHold.CalculateTotal (F2.5) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SeatStatus.HoldFor, MarkSold (F2.6) | 7/7 (100%) | 12/12 (100%) | 2, 3 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatStatus.ReleaseHold, ReleaseTicket (F2.7) | 8/8 (100%) | 14/14 (100%) | 3, 3 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate (F2.8) | 14/14 (100%) | 24/24 (100%) | 2, 3, 2, 3 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentTransaction.CheckRefundWithin, RecordRefunded (F2.9) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund (F2.10) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-RefundRequest.BeginAttempt (F2.11) | 5/5 (100%) | 8/8 (100%) | 3 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-RefundRequest.RecordResult (F2.12) | 7/7 (100%) | 11/11 (100%) | 4 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-RefundRequest.MarkManualRequired (F2.13) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Ticket.Cancel (F2.14) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Ticket.Admit (F2.15) | 9/9 (100%) | 14/14 (100%) | 5 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-Ticket.RefundAmount (F2.16) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Booking.CheckCancellationChannel (F2.17) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold (F2.18) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-LockOrderGuard.Acquire, AcquireAll (F2.19) | 8/8 (100%) | 14/14 (100%) | 6 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-Showtime.CheckCancellationDeadline (F2.20) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Showtime.CheckSaleOpen (F2.21) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Showtime.CheckSeatSelection (F2.22) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Showtime.CheckUnchangedSince (F2.23) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-PriceList.DetermineSeatPrice (F2.24) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-BookTicketsService.HoldSeats (F2.25) | 45/45 (100%) | 64/64 (100%) | 21 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentReportService.decide (F2.26) | 8/8 (100%) | 13/13 (100%) | 5 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-BookTicketsService.CancelHold (F2.27) | 16/16 (100%) | 19/19 (100%) | 5 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-BookTicketsService.ConfirmCashReceived (F2.28) | 16/16 (100%) | 19/19 (100%) | 5 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-BookTicketsService.StartOnlinePayment (F2.29) | 18/18 (100%) | 22/22 (100%) | 6 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-PaymentReportService.HandleIpn (F2.30) | 31/31 (100%) | 42/42 (100%) | 13 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) (F2.31) | 6/6 (100%) | 10/10 (100%) | 4 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-SeatReleaseJob.RunDue (releaseBatch) (F2.32) | 9/9 (100%) | 12/12 (100%) | 4 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (cancelOnlineInTx, cancelCashInTx, cancelAndRelea (F2.33) | 40/40 (100%) | 51/51 (100%) | 8, 7 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-CheckTicketService.CheckTicket (F2.34) | 9/9 (100%) | 12/12 (100%) | 4 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-RefundService.CreateFullRefund, RequestTicketRefund (F2.35) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-RefundService.ProcessRefund (F2.36) | 29/29 (100%) | 42/42 (100%) | 13 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-CancelTicketService.FindBooking (F2.37) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-CheckTicketService.StartChecking (F2.38) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| IF-07.VerifyPassword, IssueSession, VerifySession (F2.39) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| Ca tích hợp (PostgreSQL 15 thật, nhiều goroutine hoặc nhiều bản backend) (F2.40) | không áp dụng | không áp dụng | - | - | Ca tích hợp, không tính độ phủ đơn vị |
| DC-HoldSettlement.End (F2.41) | 15/15 (100%) | 20/20 (100%) | 7 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-HoldSettlement.Sell, FinishSale (F2.42) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-LockOrderGuard.AcquireValue (khoá giá trị hạng 0, 11, 12, 13) (F2.43) | 14/14 (100%) | 18/18 (100%) | 6 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-Staff.CheckAccessUnchanged, DC-BoxOfficeClerk.CheckAccessCurrent, DC-AccessCheckService.CheckStaffAccess (B (F2.44) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Customer.CheckRegistrationData, DC-RegisterAccountService.RegisterAccount (F2.45) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-LoginService.LoginCustomer, LoginStaff (F2.46) | 22/22 (100%) | 27/27 (100%) | 3, 6 | 100% C1 (ưu tiên Cao) | Đạt |
| DC-Staff.CheckStaffData, CheckRoleAndCinema, SaveStaffChanges, LockStaff, UnlockStaff, RenameStaff, ResetStaff (F2.47) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Customer.CheckOwnsBooking, DC-Ticket.Snapshot, DC-Booking.Summary, DC-ViewBookingHistoryService.ListHistory (F2.48) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-BookTicketsService.FindActiveHold, GetHold; DC-CancelTicketService.PrepareCashRefund (F2.49) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-Movie, DC-Auditorium, DC-Showtime, DC-Cinema: quy tắc lịch chiếu và danh mục (F2.50) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-ReportPeriod.CheckValid, ToRange; DC-ReportGroup.AddFigures, OccupancyPercent; DC-ViewCinemaReportService.V (F2.51) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-BrowseShowtimesService.selectShowtimes (qua FindShowtimesByMovie, FindShowtimesByCinema) (F2.52) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-HttpErrorMapper.Classify, DC-AuthFilter.Require (F2.53) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| IF-07.HashPassword, CheckRole, và claims mang loại chủ thể, accessChangedAt (bổ sung F2.39) (F2.54) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| Ca tích hợp bổ sung (PostgreSQL 15 thật, nhiều goroutine hoặc nhiều bản backend) (F2.55) | không áp dụng | không áp dụng | - | - | Ca tích hợp, không tính độ phủ đơn vị |
| DC-PaymentCallbackController.writeIpnAnswer, DC-VnpaySigner.Sign, Verify, DC-VnpayReportDecoder.Decode (F2.56) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |
| DC-SubscriberQueue.Offer, Close; DC-EmittedEventTracker; DC-SeatEventPoller.pollOnce; DC-IpConnectionLimiter;  (F2.57) | Đo khi có mã nguồn | Đo khi có mã nguồn | - | 100% C1 (Cao) hoặc C0 (còn lại) | Mọi lớp tương đương, giá trị biên, quy tắc bảng quyết định, chuyển trạng thái đều có TC (F4.1) |

V(G) lớn hơn 10: HoldSeats (21), HandleIpn (13), ProcessRefund (13); đề xuất tách ghi ở F2.25.6, F2.30.6, F2.36.6 và mục Đề xuất sửa artifact trước. Mọi operation có CFG còn lại có V(G) từ 2 đến 8.

## F5. Khung mã test

Không áp dụng: SINH_MA_TEST là Không có theo yêu cầu người chạy (chỉ thiết kế, không viết mã thật).

## Câu hỏi mở

Q-142 đến Q-154 của lần chạy 1.x đã trả lời (giữ để truy vết); Q-352 đến Q-355 là câu hỏi mới của lần chạy 2.0.

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-352 | Khi nhân viên quầy xác nhận thu tiền (ConfirmCashReceived) cho lần giữ ghế đã Đã huỷ, Đã hoàn tất hoặc Thanh toán thất bại, kết quả là HoldNotActiveError mang trạng thái (F2 của ConfirmCashReceived, BR-86) hay LinkMismatchError (F3: LockByHold không trả ghế nào nên DC-HoldSettlement.Sell dừng ở bước kiểm ghế rỗng trước khi gọi Complete)? | DC-BookTicketsService.ConfirmCashReceived, DC-HoldSettlement.Sell; TC-228, TC-231, TC-601; HTTP 500 INTERNAL thay vì 409 HOLD_NOT_ACTIVE | P12 F2 nêu HoldNotActiveError; F3 bước 3 gọi Sell ngay sau End(EXPIRY) và Sell kiểm ghế trước lần giữ ghế | Nhóm dự án | HoldNotActiveError mang trạng thái của lần giữ ghế (409). Sửa P12 F3 ConfirmCashReceived: sau End(EXPIRY) kiểm hold.IsActiveAt(now), sai thì trả HoldNotActiveError mang status trước khi gọi Sell; hoặc đổi thứ tự trong Sell (kiểm lần giữ ghế trước ghế). Các TC giữ kết quả theo F2 |
| Q-353 | Khi nhân viên quầy thuộc cụm rạp khác và suất chiếu chưa mở bán cùng lúc, báo lỗi nào (UC-005 2b hay 2a, 2c)? | DC-BookTicketsService.HoldSeats; TC-652 | P04 UC-005 không nêu thứ tự giữa 2b và 2a, 2c; chỉ P12 F3 (e) nêu 2b trước | Nhóm dự án | ChannelMismatchError (2b trước 2a, 2c) như P12 F3; bổ sung thứ tự vào P12 F2 và P04 UC-005 mục 8. TC dùng kết quả này làm oracle |
| Q-354 | UnlockStaff khi tài khoản đang hoạt động (đã được yêu cầu khác mở khoá) và đồng thời mốc lúc hiển thị đã lệch, báo StaffStatusUnchangedError (1c3a) hay StaleStaffError (1c3b)? | DC-Staff.UnlockStaff; TC-475 | P04 UC-017 1c3a, 1c3b không nêu thứ tự; X-32 và P12 F3 chỉ nêu thứ tự cho LockStaff | Nhóm dự án | StaffStatusUnchangedError trước StaleStaffError, đối xứng với LockStaff (X-32); ghi vào P12 F2, F3 của UnlockStaff |
| Q-355 | Tên tham số của báo IPN và hệ số nhân 100 của số tiền (V-04, V-05) mà DC-VnpayReportDecoder.Decode đọc là gì theo tài liệu VNPay sandbox? | DC-VnpayReportDecoder.Decode; TC-630; DC-VnpayUrlBuilder, DC-VnpayRefundClient | P11b SS-01 V-01 đến V-11 chưa kiểm với tài liệu VNPay | Nhóm dự án | Đối chiếu tài liệu VNPay, ghi tên tham số và hệ số vào P11b SS-01 và P12 F2 của Decode; TC dùng vector từ tài liệu |
| Q-142 | Đã trả lời (chủ dự án chốt theo đề xuất: entity giữ thuần, không đổi trạng thái, HoldNotActiveError mang ACTIVE; service luôn gọi Expire trước nên EXPIRED chỉ do service ghi; F6.2 khớp F3; đã áp ở SY-03, từ P12 1.6 mọi lời gọi Expire đi qua DC-HoldSettlement). Câu hỏi gốc: Khi Complete, Cancel hoặc FailPayment được gọi lúc lần giữ ghế còn ACTIVE nhưng now không trước expiryTime (bên gọi chưa gọi Expire), HoldNotActiveError mang status nào (ACTIVE hay EXPIRED) và operation có chuyển trạng thái sang EXPIRED không? | DC-SeatHold.Complete, Cancel, FailPayment; DC-BookTicketsService.HoldSeats (replay hết hạn); TC chờ Q-142 | P12 F3 ghi 'trả HoldNotActiveError mang status hiện tại, không đổi' (status ACTIVE) còn P12 F6.2 ghi 'gọi Expire trước (chuyển Hết hạn, lưu), rồi ném HoldNotActiveError(EXPIRED)'; X1 RV-01 điểm 4 đã nêu giao thức ngầm này | Nhóm dự án | Entity giữ thuần: không đổi trạng thái, HoldNotActiveError mang status ACTIVE kèm cờ đã quá hạn; bên gọi (service) luôn gọi Expire trước nên EXPIRED chỉ do service ghi. Sửa F6.2 theo F3 |
| Q-143 | Đã trả lời (chủ dự án chốt theo đề xuất: chỉ cộng ghế HELD có currentHold bằng ID của lần giữ ghế, bỏ qua ghế khác; danh sách rỗng trả 0; ghi ở P12 1.6 F2 CalculateTotal). Câu hỏi gốc: DC-SeatHold.CalculateTotal xử lý thế nào với ghế trong danh sách không thuộc lần giữ ghế này (currentHold khác hoặc không HELD) và với danh sách rỗng? | DC-SeatHold.CalculateTotal; HandleIpn bước 3 (so r.amount với tổng giá); TC chờ Q-143 | P12 F2 chỉ nêu 'tổng heldPrice của các ghế đang giữ cho lần giữ ghế này' | Nhóm dự án | Chỉ cộng ghế HELD có currentHold bằng ID của lần giữ ghế, bỏ qua ghế khác; danh sách rỗng trả 0 |
| Q-144 | Đã trả lời (chủ dự án chốt theo đề xuất: coi là lỗi lập trình của bên gọi (tiền điều kiện), không kiểm trong operation, không thiết kế TC; lưới an toàn là CHECK của P13; ghi ở P12 1.6 mục 0.3). Câu hỏi gốc: Giá trị ngoài miền mà P12 không nêu hành vi: tham số rỗng hoặc nil của NewSeatHold; Money bằng 0 hoặc âm ở NewFullRefund, NewTicketRefund, NewCashRefund, CheckRefundWithin, RecordRefunded, RefundAmount; ghế lùi mốc ở CheckUnchangedSince; hai key bằng nhau ở AcquireAll. Các operation phải từ chối, bỏ qua hay coi là lỗi lập trình? | NewSeatHold; DC-RefundRequest.New*; DC-PaymentTransaction.CheckRefundWithin, RecordRefunded; DC-Ticket.RefundAmount; DC-Showtime.CheckUnchangedSince; DC-LockOrderGuard.AcquireAll; mọi TC ghi chờ Q-144 | P12 F2 không nêu ngoại lệ cho các miền này; P13 có CHECK > 0 cho giá, số tiền | Nhóm dự án | Coi là lỗi lập trình của bên gọi (tiền điều kiện), không kiểm trong operation, không thiết kế TC; lưới an toàn là CHECK của P13 (ck_payment_transaction_amount, ck_refund_request_amount, ck_ticket_price) |
| Q-145 | Đã trả lời (chủ dự án chốt theo đề xuất: theo thứ tự bước của P04, CheckSaleOpen, rồi BR-04, rồi số ghế, rồi 7d, 7a, 7e; P12 1.6 F3 HoldSeats ghi nhận số ghế ở bước 1 nhưng chỉ ném lỗi sau BR-04). Câu hỏi gốc: Khi HoldSeats nhận yêu cầu vi phạm đồng thời suất chiếu chưa mở bán hoặc đã bắt đầu (UC-005 2a, 2c) hoặc số ghế rỗng hoặc quá 8 (6a) cùng với một điều kiện khác (người giữ còn lần giữ ghế chưa kết thúc 7c, suất chiếu đã đổi 7d, ghế không trống 7a, thiếu giá 7e), thông báo lỗi nào được báo trước? | DC-BookTicketsService.HoldSeats; DT bảng quyết định HoldSeats; TC chờ Q-145 | P04 UC-005 mục 3 và 8 chỉ nêu thứ tự 7c, 7d, 7a, 7e; luồng 2a, 2c ở bước 2 và 6a ở bước 6 là bước khác, và mục 8 nói BR-45 chỉ kiểm ở bước 2; P12 F3 kiểm số ghế ở bước 1 rồi BR-04 rồi CheckSaleOpen | Nhóm dự án | Theo thứ tự bước của P04: CheckSaleOpen (2a, 2c), rồi BR-04 (5b, 7c), rồi số ghế (6a), rồi 7d, 7a, 7e. Đổi F3: kiểm nhanh số ghế không ném lỗi sớm hơn BR-04, hoặc ghi rõ thứ tự của F3 vào P04 |
| Q-146 | Đã trả lời (chủ dự án chốt theo đề xuất: chỉ kiểm với báo thành công chưa xử lý; báo thất bại (BR-39) và báo trùng (BR-37) không kiểm số tiền; ghi ở P12 1.6 F3 HandleIpn, P09 1.7 F7.6, SS-01 1.4). Câu hỏi gốc: Kiểm số tiền cổng báo so với bản ghi (BR-91, AMOUNT_MISMATCH) áp dụng cho mọi báo hay chỉ báo thành công chưa xử lý? Báo thất bại và báo trùng mang số tiền khác có bị AMOUNT_MISMATCH không? | DC-PaymentReportService.HandleIpn bước 4; TC chờ Q-146 | BR-91 chỉ nêu 'thanh toán thành công mà số tiền khác'; P12 F3 bước 4 kiểm cho mọi báo trước khi gọi decide | Bên nghiệp vụ | Chỉ kiểm với báo thành công chưa xử lý; báo thất bại (BR-39) và báo trùng (BR-37) không kiểm số tiền, vẫn ghi nhận hoặc đếm trùng |
| Q-147 | Đã trả lời (chủ dự án chốt theo đề xuất: NotFoundError như CancelHold, không đổi dữ liệu; ghi ở P12 1.6 F2, F3). Câu hỏi gốc: StartOnlinePayment, ConfirmCashReceived và GetHold trả lỗi gì khi by hoặc clerk không phải người giữ ghế? | DC-BookTicketsService.StartOnlinePayment, ConfirmCashReceived, GetHold; TC chờ Q-147 | P12 F3 chỉ CancelHold nêu NotFoundError (không lộ sự tồn tại); ba operation còn lại ghi 'kiểm by là người giữ ghế' không nêu lỗi | Nhóm dự án | NotFoundError như CancelHold, không đổi dữ liệu |
| Q-148 | Đã trả lời (chủ dự án chốt theo đề xuất: cleanupEvents luôn chạy với ngữ cảnh riêng có hạn 2 giây (không tách DC-SeatEventCleanupJob); ghi ở P12 1.6 F2, F3). Câu hỏi gốc: Sau khi HoldExpiryJob.RunDue hết ngân sách 8 giây, cleanupEvents có được gọi không và dùng ngữ cảnh nào? | DC-HoldExpiryJob.RunDue; TC chờ Q-148 | P12 F3 bước 3 'cuối lượt: cleanupEvents' không nêu ngữ cảnh; X1 RV-04 đã nêu nguy cơ ngân sách bị dùng hết trước bước dọn | Nhóm dự án | cleanupEvents luôn chạy với ngữ cảnh riêng có hạn 2 giây; hoặc tách DC-SeatEventCleanupJob như đề xuất của X1 RV-04 |
| Q-149 | Đã trả lời (chủ dự án chốt theo đề xuất: bỏ lượt khi hạn tính ra dưới 5 giây (phần claim còn lại dưới 15 giây); đề xuất khớp nội dung đã áp ở SY-08, không sửa thêm). Câu hỏi gốc: Ngưỡng bỏ lượt của ProcessRefund (phần claim còn dưới 10 giây) trùng với biên 10 giây trừ vào hạn gọi cổng; khi phần claim còn lại nằm trong khoảng từ 10 giây trở lên và gần 10 giây thì hạn gọi cổng tính ra gần 0. Ngưỡng bỏ lượt có cần lớn hơn biên cộng một thời gian chờ tối thiểu hữu ích không? | DC-RefundService.ProcessRefund bước 2; TC chờ Q-149 | P12 F3 bước 2 và P09 F7.7: hạn = nhỏ hơn của 30 giây và (claimedUntil - hiện tại - 10 giây); bỏ lượt nếu còn dưới 10 giây | Nhóm dự án | Bỏ lượt khi hạn tính ra dưới 5 giây (tức phần claim còn lại dưới 15 giây) |
| Q-150 | Đã trả lời (chủ dự án chốt theo đề xuất: trả nil, ghi log mức cảnh báo, dòng được nhận lại sau claimed_until; ghi ở P12 1.6 F2, F3). Câu hỏi gốc: ProcessRefund trả gì khi bỏ lượt vì phần claim còn lại quá ngắn: nil hay lỗi, và RefundOutboxJob xử lý thế nào? | DC-RefundService.ProcessRefund; DC-RefundOutboxJob; TC chờ Q-150 | P12 F3 bước 2 chỉ ghi 'thôi, không gọi cổng và không ghi gì'; F2 chỉ liệt kê ClaimLostError và lỗi CSDL | Nhóm dự án | Trả nil, ghi log mức cảnh báo (dòng được nhận lại sau claimed_until) |
| Q-151 | Đã trả lời (chủ dự án chốt theo đề xuất: múi giờ Asia/Ho_Chi_Minh (UTC+7), đổi startTime sang múi giờ này trước khi xác định khung giờ và ngày trong tuần; ghi ở P12 1.6 F2 DetermineSeatPrice). Câu hỏi gốc: Khung giờ chiếu (trước hay từ 17 giờ) và ngày trong tuần (Thứ Bảy, Chủ nhật) tính theo múi giờ nào của giờ bắt đầu suất chiếu? | DC-PriceList.DetermineSeatPrice; TC chờ Q-151 | BR-11, BR-12 không nêu múi giờ; P12 F2 PriceQuery.startTime là time.Time | Nhóm dự án | Múi giờ cố định của chuỗi rạp là Asia/Ho_Chi_Minh (UTC+7), đổi startTime sang múi giờ này trước khi xác định khung giờ |
| Q-152 | Đã trả lời (chủ dự án chốt theo đề xuất: thứ tự EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM; hằng 8 một nơi (DC-Showtime.MaxSeatsPerHold); ghi ở P12 1.6 F2). Câu hỏi gốc: DC-Showtime.CheckSeatSelection báo lý do nào khi nhiều lý do cùng đúng (EMPTY, TOO_MANY, NOT_IN_AUDITORIUM, DUPLICATE)? | DC-Showtime.CheckSeatSelection; TC chờ Q-152 | P12 F2 chỉ liệt kê bốn lý do, không nêu thứ tự | Nhóm dự án | Thứ tự EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM |
| Q-153 | Đã trả lời (chủ dự án chốt theo đề xuất: 8 giờ như nhân viên; ghi ở P12 1.6 F2 IF-07.IssueSession). Câu hỏi gốc: Thời hạn phiên đăng nhập của quản trị viên (ADMINISTRATOR) là bao lâu? | IF-07.IssueSession; TC chờ Q-153 | Q-129 chỉ nêu khách 24 giờ và nhân viên 8 giờ; NFR-03 tách quản trị viên khỏi nhân viên của NFR-02 | Bên nghiệp vụ | 8 giờ như nhân viên |
| Q-154 | Đã trả lời (chủ dự án chốt theo đề xuất: hết hạn khi now >= expiresAt, đồng hồ hệ thống tiêm vào bộ xác thực; ghi ở P12 1.6 F2 IF-07.VerifySession). Câu hỏi gốc: Phiên hết hạn đúng tại expiresAt hay sau expiresAt (VerifySession tại now = expiresAt), và bộ xác thực dùng đồng hồ nào? | IF-07.VerifySession; TC chờ Q-154 | Q-129 và P12 F2 IF-07 không nêu biên và nguồn đồng hồ (thời gian CSDL chỉ dùng trong giao dịch) | Nhóm dự án | Hết hạn khi now >= expiresAt, đồng hồ hệ thống tiêm vào bộ xác thực |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P12 | F3 DC-BookTicketsService.ConfirmCashReceived; F2, F3 DC-HoldSettlement.Sell | Lần giữ ghế đã kết thúc (Đã huỷ, Đã hoàn tất, Thanh toán thất bại) không còn ghế trỏ tới nó nên LockByHold trả rỗng, Sell trả LinkMismatchError thay vì HoldNotActiveError; nhân viên bấm xác nhận hai lần nhận HTTP 500 (Q-352) | Kiểm hold.IsActiveAt(now) sau End(EXPIRY) và trước Sell, hoặc đổi thứ tự kiểm trong Sell; áp cho cả DC-PaymentReportService nếu sau này gọi Sell không qua decide |
| P12 | F2 DC-BookTicketsService.HoldSeats (hậu điều kiện, ngoại lệ) | Thứ tự báo lỗi 2b, 2a và 2c, 7c, 6a, 7d, 7a, 7e chỉ nằm ở F3 (Q-145, Q-353) | Bổ sung thứ tự vào F2; sửa P04 UC-005 mục 8 thêm 2b |
| P12 | F3 DC-BookTicketsService.HoldSeats (V(G) 21); DC-PaymentReportService.HandleIpn (V(G) 13); DC-RefundService.ProcessRefund (V(G) 13) | V(G) lớn hơn 10 | Tách HoldSeats thành ba hàm private (kiểm không khoá, quy tắc người giữ và lựa chọn ghế, khoá và giữ ghế); tách HandleIpn thành validateReport và applyDecision; tách ProcessRefund theo ba giao dịch |
| P12 | F2 DC-Booking, DC-Ticket (hàm dựng) | Id vé do kho gán lúc InsertWithTickets nên điều kiện đầu của FinishSale không dựng được bằng operation công khai (Bước 0) | Thêm operation gán id vé, hoặc cho phép F2.42.7 dùng bộ dựng SetTicketId chỉ có ở test |
| P12 | F2 DC-Staff.UnlockStaff | Thứ tự kiểm trạng thái và mốc khi cả hai cùng sai chưa nêu (Q-354) | Ghi thứ tự StaffStatusUnchangedError trước StaleStaffError |
| P12 | F3 IF-17.LockByID sau FindIDByRef | Nhánh NotFoundError không thể đi tới (seat_hold không có thao tác xoá) | Ghi bất biến này ở F2, bỏ nhánh khỏi CFG |
| P12, P11b | F2 DC-VnpayReportDecoder.Decode; P11b SS-01 V-04, V-05 | Tên tham số và hệ số số tiền chưa nêu (Q-355) | Ghi tên tham số, hệ số nhân 100 sau khi đối chiếu tài liệu VNPay |
| P12 | F2b DC-HttpErrorMapper, DC-ErrorScope | LoginFailedError có hai messageId (MSG-02 khách, MSG-86 nhân viên) nhưng ErrorScope chỉ có ACCOUNT, Classify không phân biệt được | Thêm scope CUSTOMER_LOGIN, STAFF_LOGIN hoặc hai mã lỗi riêng |
| P09, P10 (RV-02, RV-04 của X1) | Chữ ký công khai PKG-13, PKG-15; DC-HoldExpiryJob.cleanupEvents | DTO thay kiểu miền ở chữ ký công khai và tách job dọn seat_event để sau Project 3 (SY-19 loại Chờ) | Nếu áp dụng, dữ liệu vào của TC HoldSeats, CancelHold, StartOnlinePayment, ConfirmCashReceived, CancelOnlineTicket, CheckTicket ghi lại bằng int64 và string; số TC không đổi |

## Vấn đề còn mở

1. Phạm vi vượt ngưỡng: lần chạy 2.0 gồm 653 TC (609 unit, 42 tích hợp, 2 chờ câu hỏi) trên 57 mục F2, vượt ngưỡng 60 TC mỗi lần chạy của prompt; theo yêu cầu người chạy (Conventions C9 mức 2) làm toàn hệ thống trong một file, chia nhóm package và viết tuần tự. Operation ưu tiên Thấp và Trung bình ngoài trọng tâm bị bớt trước (F1).
2. Operation chưa có TC (F1, chọn Không kèm lý do), làm tiếp bằng MA_TC_BAT_DAU = TC-660: điều phối UC-010 đến UC-014 (DC-ManageMoviesService, DC-ManageCinemasService, DC-ManageAuditoriumsService, DC-ManagePriceListService, DC-ScheduleShowtimesService), DC-ViewChainReportService, DC-BrowseMoviesService; hệ quả: X-04, X-05, X-06, X-08, X-11, X-20, X-21, X-23 chưa có TC, X-19 chỉ một phía (F4.4). Quy tắc của entity thuộc các UC này đã có TC ở F2.50, F2.51.
3. Sơ đồ CFG (diagrams/X2-cfg-<DC>-<operation>.drawio, MUC_CHI_TIET = DAY_DU) chưa sinh. Bảng node (N) và cạnh (CE) ở F2.x.6 đã đủ định danh để dựng sơ đồ theo Conventions C7; cần chạy riêng bước vẽ.
4. Chưa có mã nguồn: C0, C1 ở F4.6 là mức thiết kế (CFG từ P12 F3); operation không có thiết kế method ghi Đo khi có mã nguồn. Khi có mã Go, chạy lại bước hộp trắng với go test -cover.
5. Unit test dùng IF-08 giả chạy tuần tự nên chỉ chứng minh logic quyết định sau khi có khoá; loại trừ thật, khoá dòng và khoá giá trị, NOWAIT, SKIP LOCKED, trigger, EXCLUDE, hàng rào claim_token và tiến trình chết nằm ở các ca tích hợp (F2.40, F2.55). 207 case P13-schema-tests.sql đã chạy đạt trên PostgreSQL 16 không lặp lại.
6. Phát hiện mức Cao: TC-228, TC-231 và TC TC-601 sẽ thất bại trên thiết kế hiện hành do Q-352 (ConfirmCashReceived trên lần giữ ghế đã kết thúc trả LinkMismatchError, HTTP 500); chờ quyết định, TC giữ kết quả theo F2 và BR-86.
7. TC chờ câu hỏi còn lại: TC-475, TC-630 (Q-354, Q-355); không tính vào độ phủ.
8. DC-Ticket.RefundAmount: giá vé nhỏ nhất P13 cho phép là 1 đồng (ck_ticket_price) cho khoản hoàn 0 đồng theo BR-31, trong khi ck_refund_request_amount yêu cầu refund_amount lớn hơn 0; TC-114 giữ kết quả 0 theo BR-31. Không lập Q vì giá vé thực tế lớn hơn nhiều; nên có giá vé tối thiểu ở BR bảng giá.
