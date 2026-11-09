# X1 - Review thiết kế (coupling, cohesion, nguyên lý) - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | X1 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | project-profile.md; P12-class-design.md 1.4 (F1, F1b, F2, F3, F4, F5, F6 theo các review đã có, F7, F9, F10, Xử lý mục chuyển, Câu hỏi mở, Đề xuất sửa, Vấn đề còn mở; F8 chỉ bảng đầu); P13-data-model.md 1.3 (F2, F4.4, F5, F6.3, F6.4) và P13-schema.sql; P10-design-elements.md 1.4 (F3, F4, F6); P09-architecture.md 1.5 (F3, F6, F7); P11b-system-interfaces.md 1.4 (SS-01); P08-analysis-model.md 1.5 (F3, F4b); P07-uc-analysis UC-005 1.1, UC-006 1.1, UC-008 1.2, UC-009 1.1 (tên message); P06-supplementary-spec.md 1.3 (mục NFR); P04-uc-specs/_BR-register.md; mục Câu hỏi mở, Đề xuất sửa của P00 đến P13; _review-P12.md, _review-P13.md, _review-final.md; 00-Conventions.md, 00-Concurrency.md (M9) |
| Phạm vi | P12 phần đã chi tiết hoá: PKG-12, PKG-13, PKG-14, PKG-15, PKG-21, PKG-22, PKG-24, PKG-25, PKG-26 (chỉ IF-07), PKG-28 và phần PKG-27 mà UC-005, UC-008, UC-009 dùng; các bảng TBL-01 đến TBL-10, TBL-20, TBL-21 của P13 |
| Mã Q, ASM cuối đã cấp | Q-141; không có ASM (NGHIEM_NGAT) |

## F1. Phạm vi và phương pháp

| Hạng mục | Nội dung |
|---|---|
| Artifact và phiên bản đã review | P12 1.4 (chính); P13 1.3 và P13-schema.sql; P09 1.5, P10 1.4, P11b 1.4, P08 1.5 (đối chiếu); P07 của UC-005, UC-006, UC-008, UC-009 (đối chiếu message) |
| Phần tử trong phạm vi | 11 package (PKG-12, 13, 14, 15, 21, 22, 24, 25, 26, 27, 28); 66 phần tử có hành vi theo P12 F1 (46 lớp, 20 interface); 73 kiểu phụ trợ ở F1b (32 value object, 17 enumeration, 24 ngoại lệ); 136 quan hệ ở F5 (R-10 đến R-18, R-44 đến R-178); 5 state machine ST-01 đến ST-05; 12 bảng liên quan ở P13 (TBL-01 đến TBL-10, TBL-20, TBL-21) |
| Nhóm tiêu chí đã áp dụng | Tất cả: MOD, CPL, COH, SOLID, GRASP, PRN, PKP, SML, CNS, DAT; thêm đối chiếu 00-Concurrency.md M9 theo yêu cầu người chạy |
| Chế độ | NGHIEM_NGAT; MUC_CHI_TIET = DAY_DU nên F6.3 được tính |
| Ngoài phạm vi (không tính là lỗi) | Phần PKG-27 chưa chi tiết hoá (DC-Cinema, DC-Auditorium, DC-Movie, DC-PriceEntry, DC-CinemaManager, DC-TicketChecker, IF-14, IF-15, operation của UC-013, UC-014); PKG-16; PKG-11, PKG-17 đến PKG-20, PKG-23, PKG-29, PKG-05 đến PKG-10; 10 use case chưa đặc tả; phần bên trong SS-05 |
| Không lặp lại | Các phát hiện đã xử lý ở _review-P12.md (R12-01 đến R12-19), _review-P13.md (R13D-01 đến R13D-07), _review-final.md (RF-01 đến RF-17). DC-BookTicketsService nhiều phụ thuộc đã được _review-P12.md xếp vào "đã soát và đạt" nên ghi nhận ở F4, không lập RV |
| Phần không review được | Thân method SQL và thân method của entity (P12 F3 chỉ mô tả 26 nhóm operation, phần còn lại là getter hoặc hiện thực nguyên một operation interface): các phát hiện stamp coupling và cohesion cấp lớp của lớp Pg ghi "Cần xác nhận"; F8 Node và Edge không đọc nên tiêu chí "Class diagram khớp bảng" ghi "Không xét: không đọc F8"; P05 không đọc nên tiêu chí "Tên dùng đúng glossary" ghi "Không xét: không đọc P05"; P04 chỉ đọc sổ BR; P07 chỉ so khớp tên message "// tên" của bốn UC, không đối chiếu số thứ tự message |
| Mô-đun đồng thời | project-profile.md không có trường TRANH_CHAP_TAI_NGUYEN nên theo Conventions C1 mục 9 mô-đun không bắt buộc; thiết kế vẫn dùng EX-nn và X-nn nên M9 được đối chiếu về nội dung, lệch về hình thức ghi ở RV-15 |
| Phương pháp | Dựng đồ thị quan hệ từ F5 bằng chương trình (cạnh theo cột Điều hướng) để tính phụ thuộc package và Ca, Ce; so cột "Đối tượng và operation khác được dùng" của F3 với F5; so tên message P07 với F4; đếm operation mỗi interface và operation mỗi bên gọi từ F3; chạy thử ba thay đổi yêu cầu để đếm lớp và package phải sửa. Không có NFR về khả năng bảo trì trong P06 (NFR-01 đến NFR-18 không có) nên không nâng mức theo NFR |

## F2. Bảng phát hiện

| RV | Nguyên lý / tiêu chí vi phạm | Phần tử | Bằng chứng | Mức độ | Đề xuất sửa | Bước cần sửa | Nhóm | Độ tin cậy | Trạng thái |
|---|---|---|---|---|---|---|---|---|---|
| RV-01 | SML Shotgun surgery; PRN DRY; GRASP Creator; SML Temporal coupling ẩn | DC-BookTicketsService.HoldSeats, CancelHold, ConfirmCashReceived; DC-PaymentReportService.HandleIpn; DC-SeatHold.Complete, Cancel, FailPayment; DC-Booking.NewBooking; DC-Ticket.NewTicket | (1) P12 F3 dòng 535, 536, 538, 539: bốn operation của hai lớp ở hai package cùng lặp dãy "Expire(now) rồi UpdateStatus rồi ReleaseHold từng ghế đã khoá hạng 6 rồi SaveChanges": HoldSeats (g) "ReleaseHold(mã cũ) ngay (Q-134)", CancelHold bước 3 "ReleaseHold từng ghế đã khoá rồi SaveChanges", ConfirmCashReceived bước 2 "ReleaseHold từng ghế đã khoá hạng 6 và SaveChanges cùng giao dịch (Q-134)", HandleIpn bước 4 và nhánh FAILURE bước 6.<br>(2) Dãy bán ghế lặp ở ConfirmCashReceived bước 3 và HandleIpn bước 6 nhánh SELL: "NewTicket từng ghế, NewBooking, InsertWithTickets, MarkSold, SaveChanges, Complete, UpdateStatus"; R-165 và R-167. DC-Booking gộp DC-Ticket (R-52 Aggregation) nhưng vé do service tạo: NewBooking(hold \*SeatHold, code string, tickets \[\]\*Ticket) (F2).<br>(3) Đã xảy ra thật: Q-134 buộc sửa đồng thời hai lớp, hai package (PKG-13, PKG-14), bốn operation và bốn dòng EX của P10 (P12 Đề xuất sửa artifact trước, dòng "P10 F3a EX-05, EX-01, EX-02, EX-03, EX-04").<br>(4) Giao thức ngầm: F3 DC-SeatHold.Expire, Complete, Cancel, FailPayment: "Bên gọi luôn gọi Expire(now) trước và lưu nếu đổi"; năm điểm gọi (HoldSeats (e), CancelHold 2, StartOnlinePayment 1, ConfirmCashReceived 2, HandleIpn 4). Bên gọi quên thì Complete trả HoldNotActiveError mang status ACTIVE dù hạn đã qua | Cao | Extract Class: thêm lớp miền không trạng thái, không I/O, không khoá trong PKG-28 (Pure Fabrication, vẫn đúng Q-117 vì không gọi kho), tạm gọi DC-HoldSettlement, hai operation: End(now, hold, seatsĐãKhoá) gộp Expire hoặc Cancel hoặc FailPayment cùng ReleaseHold từng ghế và trả danh sách ghế đã đổi; Sell(now, hold, seatsĐãKhoá, mã) gộp Complete, tạo vé, tạo lần đặt, MarkSold. Move Method: DC-Booking tự tạo DC-Ticket từ ghế và mã. Bốn operation chỉ gọi hai operation này rồi lưu qua IF-17, IF-18, IF-20. Mã lớp do P10 cấp | P10; P12 | SML | Chắc chắn | Mở |
| RV-02 | CNS Layer (P09 F6: Presentation không phụ thuộc Domain); CPL kênh kiểu dùng chung | Chữ ký công khai của DC-BookTicketsService (GetHold, CancelHold, StartOnlinePayment, ConfirmCashReceived, OpenStream, GetSnapshot), DC-CancelTicketService (FindBooking, CancelOnlineTicket, ConfirmCashRefund, StartChecking, CheckTicket), DC-HoldSeatsRequest; DC-ActorContext, DC-HolderRef | P09 F6 dòng 143: "Presentation chỉ phụ thuộc Application và PKG-26 Security, không phụ thuộc Domain". P12 F2 PKG-13: GetHold(ctx Ctx, holdId SeatHoldId, by HolderRef), ConfirmCashReceived(... clerk HolderRef) (BookingView, error), OpenStream(ctx Ctx, showtimeId ShowtimeId, afterEventId EventId), GetSnapshot(...) (SeatSnapshot, error); PKG-15: CancelOnlineTicket(ctx Ctx, ticketId TicketId, customer ActorContext). Kiểu SeatHoldId, TicketId, HolderRef, ActorContext, BookingView, SeatSnapshot thuộc PKG-28; ShowtimeId, Money thuộc PKG-27 (F1b). F1b dòng 143: DC-ActorContext "lấy từ SessionClaims của IF-07 do tầng gọi dựng", tầng gọi là PKG-11. Gọi các operation này, PKG-11 phải nhập PKG-27 và PKG-28; hai cạnh này không có ở P09 F6 và P10 F6. P12 F9 chỉ kiểm cạnh của PKG-12 (đã dùng kiểu thuần) nên không bắt được | Trung bình | Phương án chọn: Introduce Parameter Object ở lớp Application: operation công khai của PKG-13, PKG-15 nhận và trả DTO do chính package đó định nghĩa với int64, string, time.Time (cách P12 đã làm cho DC-PaymentStatusView, DC-PaymentStart); chuyển đổi sang SeatHoldId, HolderRef, ActorContext làm trong service. Phương án khác nếu nhóm thích rẻ hơn: sửa P09 F6 cho phép Presentation dùng kiểu định danh và giá trị của Domain (DC-TicketingIds, DC-CinemaIds, DC-Money, DC-HolderRef, DC-ActorContext), không dùng entity hay interface kho. Đánh đổi: phương án đầu giữ nguyên quy tắc P09 nhưng thêm vài DTO; phương án sau không thêm lớp nhưng nới quy tắc | P12 | CNS | Chắc chắn | Mở |
| RV-03 | CPL External coupling; GRASP Protected Variations; CNS (cam kết P09, P10 so với P12) | DC-PaymentCallbackController.writeIpnAnswer, DC-PaymentReportService.HandleIpn, ResolveReturnedPayment, IF-02.ReportTransactionResult, PKG-22 | Cam kết: P09 F3 dòng 78 "thay đổi cổng thanh toán hay dịch vụ email chỉ đổi một package Services"; P10 F4 dòng 304 PKG-22 "thay cổng chỉ đổi gói này (NFR-15 đến NFR-17)"; P10 F2 dòng 20 SS-01 "Che ... định dạng trả lời của cổng"; P12 F10 hàng Adapter "NFR-15 đến NFR-17 đòi đổi cổng chỉ sửa PKG-22". Thực tế: P12 F2 dòng 426, DC-PaymentCallbackController (PKG-12) giữ "Bảng dịch: PROCESSED 00, DUPLICATE 02, INVALID_SIGNATURE 97, AMOUNT_MISMATCH 04, UNKNOWN_TRANSACTION 01, TEMPORARY_FAILURE và MALFORMED 99" (RspCode của VNPay, P11b V-04); HandleIpn(ctx Ctx, params map\[string\]string), ResolveReturnedPayment(params map\[string\]string) (PKG-14) và IF-02.ReportTransactionResult(parameters map\[string\]string) truyền cặp tên-giá trị nguyên văn của VNPay (P11b dòng 102 tự ghi như vậy). Thử thay đổi "đổi cổng": 7 lớp PKG-22 cộng DC-PaymentCallbackController cộng DC-PaymentReportService = 9 lớp, 3 package, không phải 1 package. NFR-15 đến NFR-17 (P06) chỉ nêu giao tiếp (Interoperability), không nêu khả năng thay cổng | Trung bình | Hai phương án, chọn theo Q-141. Nếu cổng cần thay được: Move Method đưa bảng dịch RspCode và việc đọc tham số vào PKG-22, qua IF-02 thêm operation dựng câu trả lời từ mã kết quả trung lập do PKG-22 định nghĩa; đây là đảo có chủ ý quyết định bỏ replyToReport của P10 1.2 theo quy tắc A3 của P11b (A3 chặn mã HTTP trong interface, Protected Variations đòi bọc điểm biến đổi; chọn Protected Variations vì cổng là hệ thống ngoài duy nhất có giao thức riêng). Nếu không: sửa bốn câu cam kết thành "đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14" | P09; P10; P12 | CPL | Cần xác nhận: Q-141 (có cần thay cổng không); sự lệch giữa cam kết và thiết kế là chắc chắn | Mở |
| RV-04 | COH Temporal; SRP | DC-HoldExpiryJob (RunDue, expireBatch, cleanupEvents), R-81 | P12 F1 dòng 91: "Chuyển các lần giữ ghế đã quá hạn sang Hết hạn theo lô và dọn sự kiện đổi ghế cũ", "gộp từ DC-SeatEventCleanupJob (P10)". F3 dòng 542: bước 2 expireBatch dùng IF-17 và DC-SeatHold; bước 3 "Cuối lượt: cleanupEvents gọi IF-22.DeleteOlderThan(10 phút, 200)". P10 F3 dòng 233 lý do gộp: "Cùng chu kỳ 10 giây, cùng bảng seat_event" nhưng expireBatch chỉ UpdateStatus lần giữ ghế, không chạm seat_event; chỉ bước dọn dùng IF-22 (R-81). Hai việc chung một ngân sách 8 giây và chạy nối đuôi: ở T2 (4.000 lần giữ hết hạn cùng giây, P09 F7.9) vòng expireBatch có thể dùng hết ngân sách trước bước dọn | Trung bình | Extract Class: khôi phục DC-SeatEventCleanupJob (mã P10 đã cấp, đang ở trạng thái Gộp) hiện thực IF-06 riêng, chỉ phụ thuộc IF-08 và IF-22; DC-HoldExpiryJob chỉ còn expireBatch và bỏ R-81. Phần "ngân sách bị dùng hết" Cần xác nhận vì F3 không nói bước dọn dùng cùng ngữ cảnh hay ngữ cảnh mới; không ảnh hưởng mức | P10; P12 | COH | Chắc chắn (cohesion); Cần xác nhận (ngân sách) | Mở |
| RV-05 | COH Logical; SOLID SRP; SML Large class | DC-PgTicketingStore (hiện thực IF-16 đến IF-21) | P12 F1 dòng 104: "Hiện thực SQL khoá và ghi cho các interface kho của PKG-28"; F5 R-144 đến R-149: sáu Realization. F2 PKG-28: IF-16 có 2, IF-17 có 7, IF-18 có 8, IF-19 có 9, IF-20 có 8, IF-21 có 5 operation = 39 operation công khai trong một lớp, trên tám bảng TBL-01 đến TBL-08 (P13 F2). Chung nhau chỉ hai hàm nội bộ lockRows, mapPgError (F2 dòng 445, 446) và ConnectionPools nên sáu nhóm không chia sẻ dữ liệu. Các store khác của PKG-21 được tách theo interface (DC-PgSeatEventStore, DC-PgOutboxStore, DC-PgCinemaOperationsStore). P12 Vấn đề còn mở 5 tự đặt ngưỡng 15 đến 20 operation mỗi lớp. P10 F3 dòng 114 liệt kê lớp này là một phần tử | Trung bình | Extract Class theo interface: DC-PgSeatHoldStore (IF-16, IF-17), DC-PgSeatStatusStore (IF-18), DC-PgPaymentStore (IF-19), DC-PgBookingStore (IF-20), DC-PgRefundStore (IF-21); lockRows, mapPgError chuyển thành hàm dùng chung của PKG-21. Interface không đổi nên PKG-13, 14, 15 không bị ảnh hưởng. Hạ một mức từ Cao (god class) vì chưa có thân SQL; nâng lại Cao nếu hiện thực thật chia sẻ trạng thái chung trong một struct lớn | P10; P12 | COH | Cần xác nhận: thân SQL của 39 operation (chưa có ở F3) | Mở |
| RV-06 | SOLID ISP | IF-17, IF-18, IF-20 | Từ P12 F3 (cột "Đối tượng và operation khác được dùng"), số operation bên gọi dùng trên tổng số: IF-17 (7): DC-BookTicketsService 4 (LockUnfinishedOrByRequest, LockByID, Insert, UpdateStatus), DC-PaymentReportService 3 (FindIDByRef, LockByID, UpdateStatus), DC-HoldExpiryJob 2 (LockExpiredBatch, UpdateStatus), DC-SeatReleaseJob 1 (LockReleasableBatch). IF-18 (8): bên gọi nhiều nhất dùng 3 (HoldSeats: LockForHold, FindBeingReleased, SaveChanges); DC-SeatReleaseJob dùng LockByHolds, SaveChanges. IF-20 (8): DC-CheckTicketService dùng 2 (LockTicketByCode, UpdateTicketStatus); DC-CancelTicketService dùng 4; LockTicketShared không có bên gọi trong phạm vi. IF-20 trộn lần đặt (InsertWithTickets, FindByCode, FindByTicket, FindByHold) với khoá vé (LockTicketByID, LockTicketByCode, LockTicketShared, UpdateTicketStatus). P12 mục "Xử lý mục chuyển từ bước trước", dòng cuối: "Giữ ghép IF-13, IF-16, IF-20 ... nếu X1 thấy phân tách interface cần thiết thì tách theo hạng khoá" | Trung bình | Extract Interface theo nhóm bên gọi, DC-PgTicketingStore (hoặc các store sau RV-05) vẫn hiện thực: (1) tách thao tác chỉ dành cho hai job nền: LockExpiredBatch, LockReleasableBatch (IF-17), LockByHolds (IF-18); (2) tách IF-20 thành interface lần đặt và interface khoá vé. Giữ IF-13 và IF-16 (2 operation, không đáng tách). Vấn đề giải quyết: bản giả trong X2 của hai job và của DC-CheckTicketService chỉ cần 1 đến 2 operation. Mã IF mới do P12 cấp từ IF-26 | P12 | SOLID | Chắc chắn | Mở |
| RV-07 | DAT (hằng nghiệp vụ trong CHECK); PRN DRY | seat_hold.ck_seat_hold_expiry, refund_request.ck_refund_request_attempts, DC-SeatHold.HoldDuration, DC-RefundRequest.MaxAttempts | P13-schema.sql dòng 214: CHECK (expiry_time = hold_time + interval '10 minutes'). P13 F5.3 hàng seat_hold.expiry_time: lý do lưu cột là "đổi BR-10 không đổi hạn của lần giữ ghế đã tạo". Hai câu mâu thuẫn: CHECK buộc mọi dòng đã lưu cách đúng 10 phút nên khi BR-10 đổi, ràng buộc mới không qua được dòng cũ nếu không NOT VALID hoặc bỏ ràng buộc. Tương tự dòng 327: CHECK (attempt_count BETWEEN 0 AND 4) mã hoá MaxAttempts = 4 (P12 F7). Thử thay đổi "đổi BR-10 sang giá trị khác": 1 lớp (DC-SeatHold), 1 package, cộng 1 ràng buộc P13 cần di trú | Thấp | Replace Magic Number: CHECK chỉ giữ miền bất biến (expiry_time > hold_time và chặn trên rộng, ví dụ cách không quá 1 giờ), hằng 10 phút chỉ ở DC-SeatHold.HoldDuration; ck_refund_request_attempts đổi thành attempt_count >= 0. Đánh đổi: bớt một lưới an toàn chặt (M8) để có một nơi biểu diễn duy nhất. Nếu Q-140 trả lời hằng số cố định thì chỉ cần sửa lại câu lý do ở F5.3, giữ CHECK. Hạ một mức vì chỉ là nguy cơ khi quy tắc đổi | P13 | DAT | Cần xác nhận: Q-140 | Mở |
| RV-08 | SML Duplicate code; GRASP Information Expert; SOLID OCP | DC-Customer.CheckNoActiveSeatHold, DC-BoxOfficeClerk.CheckNoActiveSeatHold, IF-16, R-163, R-164 | P12 F2 dòng 297 và 300: hai operation cùng chữ ký CheckNoActiveSeatHold(unfinished \[\]\*SeatHold, now time.Time) error, cùng mô tả "Từ chối khi có lần giữ ghế ACTIVE chưa quá hạn trong unfinished", cùng nguồn BR-04. F7: DC-Customer giữ id, email, phoneNumber, passwordHash; DC-BoxOfficeClerk giữ id: không thuộc tính nào được quy tắc dùng, chỉ tham số. F3 HoldSeats dùng "DC-Customer hoặc DC-BoxOfficeClerk" (rẽ nhánh theo loại người giữ). F2 IF-16 chỉ có LockHolder (trả error) và FindCustomer, không có operation trả DC-BoxOfficeClerk nên F3 không nói lấy đối tượng gọi phương thức này từ đâu. Nguồn trùng từ P08 F3 (AC-E-Customer và AC-E-BoxOfficeClerk cùng // checkNoActiveSeatHold, theo cột Nguồn F2) | Thấp | Pull Up Method và Move Method: một hàm CheckNoActiveSeatHold(unfinished, now) dùng chung (đặt cạnh DC-HolderRef hoặc ở phía DC-SeatHold), bỏ hai bản và nhánh theo loại; HoldSeats không cần nạp Customer hoặc BoxOfficeClerk để kiểm BR-04 | P08; P12 | SML | Cần xác nhận: thân method chưa có ở F3; hạ một mức | Mở |
| RV-09 | CPL Control coupling (nội bộ lớp); SML Feature envy | DC-CancelTicketService.cancelInTx, DC-RefundService.LockPaymentOfTicket | F2 dòng 415: cancelInTx(ctx Ctx, tx Tx, ticketId TicketId, actor ActorContext, cash bool); F3 dòng 544, 545: nhánh trực tuyến khoá hạng 7 và tạo yêu cầu hoàn qua RefundService, nhánh "cash = true" bỏ hạng 7 và tạo yêu cầu bằng IF-21.Insert với NewCashRefund. Việc khoá giao dịch thanh toán của vé được làm bằng DC-RefundService.LockPaymentOfTicket (F2 dòng 403: IF-20.FindByTicket, IF-19.FindTicketedByHold, IF-19.LockByID) dù DC-CancelTicketService không giữ IF-19 (R-101 đến R-106); ConfirmCashRefund dùng DC-RefundRequest nhưng F5 không có quan hệ này (xem RV-13) | Thấp | Replace Parameter with Explicit Methods: cancelOnlineInTx và cancelCashInTx dùng chung một hàm con ghi huỷ và trả ghế; Move Method LockPaymentOfTicket sang DC-CancelTicketService (thêm IF-19), DC-RefundService chỉ còn tạo và xử lý yêu cầu hoàn. Hạ một mức vì cờ là private, một lớp, hai giá trị, chưa có nhánh thứ ba | P12 | CPL | Chắc chắn | Mở |
| RV-10 | SML Long parameter list; Data clumps; Primitive obsession | IF-01.CreatePaymentTransaction, RequestRefund, FindRefund; DC-PaymentGatewayManager; DC-VnpayRefundClient.Refund, Query; DC-VnpayUrlBuilder.BuildPaymentURL | P12 F2 dòng 466 đến 468: CreatePaymentTransaction(transactionId string, holdReference string, amount int64, expiresAt time.Time, customerAddress string) (5 tham số, hai string liền nhau); RequestRefund(ctx Ctx, refundKey string, transactionId string, paidAt time.Time, originalAmount int64, refundAmount int64) (6 tham số, ba string); bộ ba refundKey, transactionId, paidAt lặp ở RequestRefund, FindRefund, Refund, Query. Lý do kiểu thô: PKG-22 không phụ thuộc Domain nên không dùng Money (F2 đoạn đầu IF-01) | Thấp | Introduce Parameter Object trong PKG-22 (không cần Domain): PaymentRequest, RefundTarget (refundKey, transactionId, paidAt); đảo thứ tự hai string liền nhau không còn biên dịch lọt | P11b; P12 | SML | Chắc chắn | Mở |
| RV-11 | CPL Stamp coupling | DC-PaymentTransaction.NewPending, DC-Booking.NewBooking, DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund | P12 F2: NewPending(hold \*SeatHold, code string, amount Money), NewBooking(hold \*SeatHold, code string, tickets \[\]\*Ticket), NewFullRefund(txn \*PaymentTransaction, amount Money), NewTicketRefund(txn, ticket, amount), NewCashRefund(ticket, amount). Mục 0.3: quan hệ giữa các entity "được hiện thực bằng struct giữ mã (ID)"; F7 của DC-RefundRequest không có thuộc tính nào ngoài mã, trạng thái, số tiền. Nếu thân chỉ đọc ID() của tham số thì cả đối tượng là thừa | Thấp | Truyền mã (SeatHoldId, PaymentTransactionId, TicketId) thay vì cả entity. Hạ một mức vì F3 không có thân của các hàm dựng này | P12 | CPL | Cần xác nhận: thân hàm dựng | Mở |
| RV-12 | PKP CRP, SDP; SOLID DIP (vị trí interface) | IF-22, IF-23 (PKG-21); R-77, R-81, R-91, R-98, R-99 | P12 F1: IF-22, IF-23 thuộc PKG-21 cùng các lớp Pg, trong khi IF-11 đến IF-13 và IF-16 đến IF-21 ở Domain (PKG-27, PKG-28); F10 hàng Repository: "P09 F5 buộc: entity phần lưu trữ là interface kho ở Domain, hiện thực ở PKG-21". Hai interface này là toàn bộ lý do của các cạnh PKG-13 --> PKG-21 (R-77, R-81) và PKG-14 --> PKG-21 (R-91, R-98, R-99) ở F9; Application nhập package chứa DC-PgTx (thuộc tính raw pgx.Tx, F7) và DC-ConnectionPools. F6.3 bên dưới: PKG-24 (I = 0,50) phụ thuộc PKG-21 (I = 0,61), phụ thuộc vào package kém ổn định hơn. Quy tắc layer vẫn đạt (P09 F6: Application --> Services) | Thấp | Move Class: đưa IF-22, IF-23 cùng kiểu OutboxEntry, SeatChangeEvent, SeatSnapshot sang PKG-28 (nơi đã có kiểu SeatChangeEvent, SeatSnapshot) hoặc PKG-27 theo P10; Application không còn nhập PKG-21, PKG-21 chỉ còn bị PKG-24 và hàm khởi động chương trình dùng. Cần xác nhận P10 có lý do giữ chúng ở PKG-21 không (P10 F4 dòng 312 chỉ giải thích PKG-27, PKG-28) | P10; P12 | PKP | Cần xác nhận | Mở |
| RV-13 | CNS Quan hệ thiếu giữa F3 và F5 | DC-CancelTicketService --> DC-RefundRequest; DC-PgUnitOfWork --> DC-PgTx, DC-LockOrderGuard; DC-PgTicketingStore, DC-PgCinemaOperationsStore --> DC-PgTx; DC-SeatEventHubManager --> IF-22 | So cột "Đối tượng và operation khác được dùng" của F3 với F5 bằng chương trình: F3 dòng 545 (ConfirmCashRefund) dùng DC-RefundRequest; dòng "DC-PgUnitOfWork.Do" dùng DC-PgTx, DC-LockOrderGuard (F5 chỉ có R-139, R-153); mục 0.3: "store ép Tx sang DC-PgTx" nhưng F5 không có quan hệ từ store tới DC-PgTx (chỉ R-140, R-159); "DC-SeatEventHubManager.Subscribe" dùng IF-22 nhưng chỉ DC-SeatReplayReader và DC-SeatEventPoller có quan hệ tới IF-22 (R-132, R-133). Không đổi đồ thị package vì cùng package hoặc cạnh đã có | Thấp | Thêm bốn nhóm quan hệ Dependency vào F5 (R-179 trở đi) và class diagram PKG-15, PKG-21, PKG-24; hoặc sửa cột "được dùng" của F3 nếu không phải quan hệ thật | P12 | CNS | Chắc chắn | Mở |
| RV-14 | CNS Message không có dòng ở F4 | UC-005 // sendTicketsEmail (P07 UC-005 message 14), UC-006 // sendRefundNotificationEmail (P07 UC-006 message 7); cột "STT message (P07)" của F4 | So tên "// tên" của P07 UC-005, 006, 008, 009 với F4: chỉ hai tên thuộc lớp trong phạm vi không có dòng; chúng được hiện thực bằng Enqueue(EMAIL_TICKET) ở HandleIpn bước 6 và Enqueue(EMAIL_REFUND) ở ProcessRefund bước 3 (F3) nhưng F4 chỉ có // provideRefundNoticeRecipient. Các tên còn lại không có dòng đều là message tới boundary giao diện hoặc từ tác nhân (selectShowtime, showSeatMap, scanTicketQr, rejectTicket ...) thuộc PKG-05 đến PKG-11 ngoài phạm vi. Cả 88 dòng F4 ghi "P08" ở cột STT message (P07) và F4 mở đầu nói P07 không được đính kèm; P12 Vấn đề còn mở 2 đã giao X1 đối chiếu | Thấp | Thêm hai dòng F4: // sendTicketsEmail --> IF-23.Enqueue(EMAIL_TICKET) trong HandleIpn, DC-EmailOutboxJob (PKG-20, Lượt sau); // sendRefundNotificationEmail --> Enqueue(EMAIL_REFUND) trong ProcessRefund; điền số thứ tự message P07 vào cột STT | P12 | CNS | Chắc chắn | Mở |
| RV-15 | CNS Hình thức mô-đun đồng thời (M5, M7) | project-profile.md; P09 F7; P12 F3 DC-RefundService.ProcessRefund, DC-BookTicketsService.StartOnlinePayment | Hồ sơ không có trường TRANH_CHAP_TAI_NGUYEN (Conventions C1 mục 9: không có trường thì hiểu là "Không"), trong khi đồ án lấy race condition làm trọng tâm và P08 đến P13 dùng EX-nn, X-nn. M5: P09 F7 không có mục "Bảng hỏng" (tìm "Bảng hỏng" không thấy), nội dung tương đương nằm rải ở F7.6, F7.7, F7.9 (ca T4, T5, T5b). M7.1: P12 F3 không có dòng "Nếu dừng tại đây" nào; ProcessRefund có ba giao dịch (bước 1, 2, 3) và StartOnlinePayment commit trước khi dựng địa chỉ, lối ra mô tả trong văn xuôi | Thấp | Bật TRANH_CHAP_TAI_NGUYEN = Có trong hồ sơ; gom nội dung đã có thành bảng "Bảng hỏng" ở P09 F7 (bảy tình huống M5, mục nào không áp dụng ghi lý do); thêm dòng "Nếu dừng tại đây: <trạng thái, ai đi tiếp>" giữa các giao dịch của ProcessRefund và StartOnlinePayment | Hồ sơ dự án; P09; P12 | CNS | Cần xác nhận: nhóm có muốn bật mô-đun không | Mở |

## F3. Đánh giá coupling

Kênh phụ thuộc: tiêm qua constructor (thuộc tính), tham số, biến cục bộ, kiểu dùng chung. Realization gộp vào dòng Data của lớp hiện thực. Mã R-nn nằm ở cột Bằng chứng; R-nn không liệt kê là cạnh Realization hoặc đã nằm trong dòng gộp cùng lớp A.

| Phần tử A (phụ thuộc) | Phần tử B (được dùng) | Kênh phụ thuộc | Mức coupling | Bằng chứng | Chấp nhận |
|---|---|---|---|---|---|
| DC-PaymentCallbackController | DC-PaymentReportService | tham số và định dạng dùng chung | External | R-110; F2 HandleIpn(ctx Ctx, params map\[string\]string); writeIpnAnswer dịch RspCode của VNPay | Không: RV-03 |
| DC-PaymentReportService | IF-02 | tham số | External | R-86; IF-02.ReportTransactionResult(parameters map\[string\]string) | Không: RV-03 |
| DC-BookTicketsService<br>DC-PaymentReportService | DC-SeatHold | thứ tự gọi (Expire trước Complete, Cancel, FailPayment) | Ngoài thang: phụ thuộc ngầm | R-10, R-12; F3 DC-SeatHold.Expire...: "Bên gọi luôn gọi Expire(now) trước" | Không: RV-01 |
| DC-CancelTicketService | cancelInTx (chính nó) | tham số cờ cash | Control | F2 dòng 415 | Không: RV-09 |
| DC-CancelTicketService | DC-RefundService | tham số, lời gọi LockPaymentOfTicket | Data | R-106; F3 dòng 544 | Không: RV-09 (vị trí operation) |
| DC-PaymentTransaction<br>DC-Booking<br>DC-RefundRequest | DC-SeatHold<br>DC-PaymentTransaction<br>DC-Ticket | tham số hàm dựng (cả entity, chỉ cần mã) | Stamp | R-50, R-51, R-55, R-56; NewPending, NewBooking, NewFullRefund, NewTicketRefund, NewCashRefund | Không: RV-11 |
| DC-Customer<br>DC-BoxOfficeClerk | DC-SeatHold | tham số (unfinished, now) | Stamp | F2 dòng 297, 300: chỉ đọc trạng thái và hạn của từng lần giữ ghế | Không: RV-08 |
| DC-Ticket | DC-Showtime | tham số Admit(showtime, selected, cinemaId) | Stamp | R-53; F3 DC-Ticket.Admit chỉ dùng BelongsToCinema và ID | Có: dùng hai predicate của một khái niệm trọn vẹn, giữ thứ tự BR-33 trong Ticket |
| DC-Showtime | DC-PriceList<br>DC-Auditorium<br>DC-Seat | tham số QuoteSeatPrices(list, room, seats) | Stamp | R-60; P12 mục 0.1: chỉ cần Type() và Label() của Seat, Type() của Auditorium | Có: ba đối tượng ngoài phạm vi, chữ ký cần ngắn gọn; DetermineSeatPrice đã nhận PriceQuery đúng dữ liệu |
| DC-PgTicketingStore<br>DC-PgCinemaOperationsStore<br>DC-SeatEventWriter | DC-PgTx | ép kiểu IF-25 sang DC-PgTx | Ngoài thang: phụ thuộc ngầm | P12 mục 0.3: "store ép Tx sang DC-PgTx"; chỉ DC-PgUnitOfWork tạo được Tx | Có: cùng package, phép ép luôn đúng (thiếu quan hệ ở F5: RV-13) |
| DC-SeatHold | DC-SeatStatus | tham số, mã liên kết (R-47 hai chiều) | Data | R-47 hiện thực bằng R-63 (SeatStatus giữ mã lần giữ ghế); không có tham chiếu đối tượng hai chiều | Có |
| DC-BookTicketsService | IF-08<br>IF-11<br>IF-12<br>IF-13<br>IF-16<br>IF-17<br>IF-18<br>IF-19<br>IF-20<br>IF-24<br>IF-01<br>DC-Booking<br>DC-Showtime<br>DC-SeatStatus<br>DC-PaymentTransaction<br>DC-Customer<br>DC-BoxOfficeClerk<br>DC-Ticket | thuộc tính (tiêm), tham số, biến cục bộ | Data | R-11, R-65 đến R-75, R-160 đến R-165; số phụ thuộc 11 tiêm (P12 Vấn đề còn mở 4) | Có (RV-06 cho độ rộng interface) |
| DC-PaymentReportService | IF-08<br>IF-17<br>IF-18<br>IF-19<br>IF-20<br>IF-23<br>DC-RefundService<br>DC-Booking<br>DC-PaymentTransaction<br>DC-RefundRequest<br>DC-SeatStatus<br>DC-Ticket | thuộc tính, tham số, biến cục bộ | Data | R-13, R-14, R-15, R-85, R-87 đến R-92, R-166, R-167 | Có |
| DC-RefundService | IF-01<br>IF-08<br>IF-19<br>IF-20<br>IF-21<br>IF-23<br>DC-RefundRequest<br>DC-PaymentTransaction | thuộc tính, biến cục bộ | Data | R-18, R-93 đến R-98, R-168, R-169 | Có |
| DC-RefundOutboxJob<br>DC-HoldExpiryJob<br>DC-SeatReleaseJob | IF-23, DC-RefundService<br>IF-08, IF-17, IF-22, DC-SeatHold<br>IF-08, IF-17, IF-18, DC-SeatStatus, DC-SeatHold | thuộc tính, biến cục bộ; Realization IF-06 | Data | R-99, R-100, R-79 đến R-84, R-176 đến R-178, R-111 đến R-113 | Có (RV-04 cho DC-HoldExpiryJob) |
| DC-SeatMapService | IF-22<br>IF-04 | thuộc tính | Data | R-77, R-78 | Có |
| DC-CancelTicketService | IF-08<br>IF-11<br>IF-18<br>IF-20<br>IF-21<br>DC-Ticket<br>DC-SeatStatus<br>DC-Booking<br>DC-Showtime | thuộc tính, biến cục bộ | Data | R-101 đến R-105, R-170 đến R-173 | Có |
| DC-CheckTicketService | IF-08<br>IF-11<br>IF-20<br>DC-Ticket<br>DC-Showtime | thuộc tính, biến cục bộ | Data | R-107 đến R-109, R-174, R-175 | Có |
| DC-SeatStatus<br>DC-SeatHold<br>DC-Ticket<br>DC-Booking | DC-Showtime, DC-Seat, DC-SeatHold, DC-Ticket<br>DC-Showtime, DC-Customer, DC-BoxOfficeClerk<br>DC-SeatStatus<br>DC-Ticket | mã liên kết (struct giữ ID) | Data | R-44 đến R-49, R-52, R-54, R-63, R-64 | Có |
| DC-PgUnitOfWork<br>DC-PgTicketingStore<br>DC-PgCinemaOperationsStore<br>DC-PgSeatEventStore<br>DC-PgOutboxStore<br>DC-PgTx | DC-ConnectionPools; DC-PgTicketingStore thêm DC-SeatEventWriter; DC-PgTx thêm DC-LockOrderGuard | thuộc tính (tiêm), Realization IF-08, IF-25, IF-11 đến IF-13, IF-16 đến IF-23 | Data | R-139, R-140, R-142 đến R-159 | Có |
| DC-PaymentGatewayManager<br>DC-VnpayUrlBuilder<br>DC-VnpayRefundClient<br>DC-PaymentReportReceiver<br>DC-VnpaySigner | DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-GatewayConfig<br>DC-VnpaySigner, DC-GatewayConfig<br>DC-VnpaySigner, DC-GatewayConfig<br>DC-VnpaySigner, DC-VnpayReportDecoder<br>DC-GatewayConfig | thuộc tính (tiêm), Realization IF-01, IF-02 | Data | R-114 đến R-125 | Có |
| DC-SeatEventHubManager<br>DC-SeatEventPoller<br>DC-SeatReplayReader<br>DC-SubscriberRegistry | DC-SubscriberRegistry, DC-SeatReplayReader, DC-SeatEventPoller<br>DC-SubscriberRegistry, DC-EmittedEventTracker, IF-22<br>IF-22<br>DC-SubscriberQueue (Composition) | thuộc tính (tiêm), Realization IF-04 | Data | R-126 đến R-134 | Có |
| DC-JobSchedulerManager<br>DC-JobRegistry<br>DC-JobLoop | DC-JobRegistry<br>DC-JobLoop (Composition)<br>IF-06 | thuộc tính, Realization IF-05 | Data | R-135 đến R-138 | Có |
| DC-RandomCodeGenerator | IF-24 | Realization | Data | R-141 | Có |

Cặp có tham số điều khiển bằng enumeration nghiệp vụ không rẽ nhánh bên nhận (HolderRef.kind, RefundType, AttemptResult) xếp Data. IF-08.Do nhận TxOptions: DC-PgUnitOfWork dùng đủ mọi trường (pool, lockTimeout, maxDuration, deadline) nên xếp Data. Law of Demeter: F3 không có chuỗi a.getB().getC().doX(); không phát hiện vi phạm.

## F4. Đánh giá cohesion

| Phần tử | Mức cohesion | Lý do | Chấp nhận |
|---|---|---|---|
| DC-SeatHold | Functional | Vòng đời một lần giữ ghế (tạo, hết hạn, hoàn tất, huỷ, thất bại); 14 operation công khai trong đó 6 getter (P12 Vấn đề còn mở 5) | Có |
| DC-SeatStatus | Functional | Chuyển trạng thái một ghế theo liên kết hiện tại (HoldFor, MarkSold, ReleaseHold, ReleaseTicket) | Có |
| DC-PaymentTransaction | Functional | Vòng đời xử lý một giao dịch và tổng đã hoàn (ST-05) | Có |
| DC-RefundRequest | Functional | Vòng đời một yêu cầu hoàn (ST-04) và ba hàm dựng theo loại | Có |
| DC-Booking | Functional | Tập vé của một lần giữ ghế và kiểm kênh khi huỷ | Có |
| DC-Ticket | Functional | Huỷ một lần hoặc soát một lần (ST-03), số tiền hoàn của chính vé | Có |
| DC-Customer, DC-BoxOfficeClerk | Functional | Mỗi lớp chứa danh tính một loại người giữ ghế; quy tắc BR-04 trùng nhau | Không: RV-08 |
| DC-Showtime | Functional | Các kiểm tra điều kiện bán, huỷ, soát và chốt giá của một suất chiếu | Có |
| DC-PriceList | Functional | Xác định giá một ghế | Có |
| DC-RandomCodeGenerator | Functional | Sinh mã tham chiếu | Có |
| DC-BookTicketsService | Sequential | Chuỗi giữ ghế, huỷ giữ, thanh toán, xác nhận tiền mặt của một lần giữ ghế; 11 phụ thuộc tiêm, 5 operation | Có: _review-P12.md xếp "đã soát và đạt", P12 Vấn đề còn mở 4; trùng gốc với RV-01 |
| DC-SeatMapService | Functional | Ảnh chụp và luồng sơ đồ ghế | Có |
| DC-HoldExpiryJob | Temporal | Hết hạn lần giữ ghế cộng dọn seat_event | Không: RV-04 |
| DC-SeatReleaseJob | Functional | Trả ghế còn trỏ tới lần giữ ghế đã kết thúc | Có |
| DC-PaymentReportService | Communicational | HandleIpn, ResolveReturnedPayment, QueryPaymentStatus cùng xoay quanh kết quả thanh toán của một lần giữ ghế nhưng hai bên gọi khác nhau (cổng, trình duyệt) | Có: ba operation chung PaymentTransaction và SeatHold, tách chỉ thêm lớp |
| DC-RefundService | Communicational | Tạo yêu cầu hoàn trong giao dịch của bên gọi và điều khiển gửi hoàn; chung RefundRequest | Có |
| DC-RefundOutboxJob | Functional | Nhận dòng hàng đợi đến hạn và giao cho DC-RefundService | Có |
| DC-CancelTicketService | Sequential | Huỷ một vé: ghi huỷ, trả ghế, tạo khoản hoàn | Có (RV-09 cho cờ cash) |
| DC-CheckTicketService | Functional | Chọn suất chiếu soát và soát một vé | Có |
| DC-PaymentCallbackController | Functional | Dịch ba đường vào của cổng sang lời gọi Application | Có (RV-03 cho phạm vi dịch) |
| DC-PgUnitOfWork, DC-PgTx, DC-LockOrderGuard, DC-ConnectionPools, DC-SeatEventWriter | Functional | Mỗi lớp một việc của cơ chế giao dịch và khoá | Có |
| DC-PgTicketingStore | Logical | 39 operation của sáu interface, gom theo kỹ thuật SQL | Không: RV-05 |
| DC-PgCinemaOperationsStore | Communicational | Ba interface IF-11 đến IF-13 của miền cụm rạp, ít operation | Có |
| DC-PgSeatEventStore, DC-PgOutboxStore | Functional | Mỗi lớp một interface | Có |
| DC-PaymentGatewayManager, DC-PaymentReportReceiver, DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-VnpaySigner, DC-VnpayReportDecoder, DC-GatewayConfig | Functional | Mỗi lớp một phần giao thức VNPay | Có |
| DC-SeatEventHubManager, DC-SeatEventPoller, DC-SeatReplayReader, DC-SubscriberRegistry, DC-SubscriberQueue, DC-EmittedEventTracker | Functional | Mỗi lớp một việc của cơ chế phát sơ đồ ghế | Có |
| DC-JobSchedulerManager, DC-JobRegistry, DC-JobLoop | Functional | Đăng ký, giữ danh sách, chạy vòng của công việc nền | Có |
| IF-01, IF-02, IF-04, IF-05, IF-06, IF-07, IF-08, IF-24, IF-25 | Functional | Mỗi interface một vai trò (IF-01 có nhóm tham số: RV-10) | Có |
| IF-11, IF-12, IF-13, IF-16, IF-19, IF-21, IF-22, IF-23 | Functional hoặc Communicational | Mỗi interface kho một hạng khoá hoặc một nhóm dữ liệu, tối đa 9 operation | Có |
| IF-17, IF-18, IF-20 | Communicational | Trộn thao tác của người dùng, job nền, soát vé | Không: RV-06 |
| Kiểu phụ trợ F1b theo package: PKG-13 (5), PKG-14 (3), PKG-15 (2), PKG-21 (7), PKG-22 (8), PKG-24 (3), PKG-25 (2), PKG-26 (4), PKG-27 (13), PKG-28 (26) | Functional | Value object, enumeration, ngoại lệ không hành vi, mỗi nhóm gắn với package sở hữu | Có |
| DC-Seat, DC-Auditorium, DC-PriceEntry | Không xét | Ngoài phạm vi, chỉ tham chiếu tên (P12 mục 0.1) | - |

## F5. Danh mục nguyên lý, design smell, nhất quán, dữ liệu

| Nguyên lý | Phần tử đã xét | Kết luận (Đạt / Vi phạm: RV) |
|---|---|---|
| MOD Decomposable | 11 package theo tầng (Presentation, Application, Services, Domain), 5 subsystem giao tiếp qua IF-nn | Đạt |
| MOD Composable | Subsystem SS-01, SS-03, SS-04 ghép qua IF-01, IF-02, IF-04, IF-05, IF-06; PKG-12 dùng kiểu thuần để chỉ phụ thuộc PKG-14 | Vi phạm: RV-02, RV-03 |
| MOD Understandable | Mỗi package đọc riêng được qua F1 và F9; lớp 39 operation khó đọc riêng | Vi phạm: RV-05 |
| MOD Continuity | Đổi cổng thanh toán: 9 lớp, 3 package (DC-PaymentGatewayManager, DC-PaymentReportReceiver, DC-VnpayUrlBuilder, DC-VnpayRefundClient, DC-VnpaySigner, DC-VnpayReportDecoder, DC-GatewayConfig, DC-PaymentCallbackController, DC-PaymentReportService)<br>Đổi quy tắc trả ghế khi kết thúc lần giữ ghế (Q-134 đã xảy ra thật): 2 lớp, 2 package (DC-BookTicketsService, DC-PaymentReportService), 4 operation<br>Đổi thời hạn giữ ghế BR-10: 1 lớp, 1 package (DC-SeatHold.HoldDuration) và 1 ràng buộc P13<br>Đổi tỷ lệ hoàn BR-19: 1 lớp, 1 package (DC-Ticket.RefundPercent)<br>Đổi số ghế tối đa BR-05: 1 lớp, 1 package (DC-BookTicketsService.maxSeats), P13 không có ràng buộc (F6.4 ghi do ứng dụng giữ) | Vi phạm: RV-01, RV-03, RV-07 (hai dòng còn lại Đạt) |
| MOD Protection | DC-ConnectionPools tách pool người dùng và pool nền; DC-JobLoop bắt panic và không chạy chồng; DC-SubscriberQueue đóng khi đầy 256; IPN lỗi tạm thời trả TEMPORARY_FAILURE để cổng gửi lại | Đạt |
| SOLID SRP | Toàn bộ lớp F4 | Vi phạm: RV-04, RV-05 (DC-BookTicketsService chấp nhận, F4) |
| SOLID OCP | Rẽ nhánh theo loại người giữ ghế ở HoldSeats; rẽ nhánh requestType FULL ở ProcessRefund (một nơi, ba giá trị cố định theo BR-16, BR-21) | Vi phạm: RV-08 (nhánh requestType: Đạt) |
| SOLID LSP | P12 F5 chỉ có Association, Dependency, Realization, Composition, Aggregation; không có Generalization (P13 F2) | Đạt |
| SOLID ISP | IF-17, IF-18, IF-20 và các interface còn lại | Vi phạm: RV-06 |
| SOLID DIP | 85 Association và 26 Dependency của F5: Application chỉ giữ Association tới interface hoặc service cùng tầng, không có cạnh từ PKG-12, 13, 14, 15 tới lớp cụ thể của PKG-21, 22, 24, 25; entity không gọi kho; ngoại lệ: vị trí IF-22, IF-23 | Đạt; vị trí interface: RV-12 |
| GRASP Information Expert | DC-SeatHold.CalculateTotal(seats) chỉ đọc heldPrice của SeatStatus; HandleIpn bước 4 so r.amount với txn.Amount ở service | Đạt có ghi nhận (hai điểm nhỏ, không lập RV: Q-117 buộc SeatHold không giữ danh sách ghế; so số tiền là một câu so sánh) |
| GRASP Creator | Service tạo DC-Ticket rồi truyền cho DC-Booking | Vi phạm: RV-01 |
| GRASP Controller | DC-BookTicketsService, DC-PaymentReportService, DC-CancelTicketService, DC-CheckTicketService nhận sự kiện từ Presentation; DC-PaymentCallbackController chỉ dịch | Đạt; phạm vi dịch của controller: RV-03 |
| GRASP Low Coupling, High Cohesion | F3, F4 | Vi phạm: RV-01, RV-04, RV-05 |
| GRASP Polymorphism | Không có hành vi đổi theo loại ngoài holder và requestType | Vi phạm: RV-08 |
| GRASP Pure Fabrication | DC-LockOrderGuard, DC-PgUnitOfWork, DC-SeatEventWriter; entity không tự lưu, không tự gửi email | Đạt; đề xuất thêm DC-HoldSettlement ở RV-01 |
| GRASP Indirection | IF-01, IF-02, IF-04, IF-06, IF-08, IF-24, IF-25 | Đạt |
| GRASP Protected Variations | Cổng thanh toán, email, thời gian (IF-25.Now), sinh mã (IF-24); cổng thanh toán chưa bọc hết | Vi phạm: RV-03 |
| PRN Encapsulation | Thuộc tính private, hành vi qua operation (F7 mọi thuộc tính có Visibility "-") | Đạt |
| PRN Favor composition over inheritance | Không có kế thừa | Đạt |
| PRN Program to an interface | Mọi phụ thuộc hạ tầng qua IF-nn | Đạt |
| PRN Law of Demeter | F3 không có chuỗi gọi xuyên đối tượng | Đạt |
| PRN DRY | Dãy kết thúc, bán ghế; CheckNoActiveSeatHold; hằng trong CHECK | Vi phạm: RV-01, RV-07, RV-08 |
| PRN KISS | Không dùng State GoF (F10 hàng "Không áp dụng State"); Outbox, Unit of Work có lý do nêu ở F10 | Đạt |
| PRN YAGNI | IF-05 (một hiện thực, bên gọi là hàm khởi động) và IF-24 (một hiện thực): IF-24 có lý do kiểm thử với mã cố định (F1); IF-05 do P11b SS-04 quy định | Đạt |
| SML God class / Large class | DC-PgTicketingStore 39 operation; DC-BookTicketsService 11 phụ thuộc | Vi phạm: RV-05 (DC-BookTicketsService chấp nhận, F4) |
| SML Data class | Entity có hành vi; DC-BoxOfficeClerk, DC-Customer ít hành vi | Đạt |
| SML Feature envy | CancelTicketService mượn RefundService.LockPaymentOfTicket | Vi phạm: RV-09 |
| SML Shotgun surgery / Divergent change | Q-134 sửa hai lớp bốn operation | Vi phạm: RV-01 |
| SML Long parameter list / Data clumps / Primitive obsession | IF-01 | Vi phạm: RV-10 |
| SML Switch statements theo mã loại | Nhánh theo holder.kind | Vi phạm: RV-08 |
| SML Message chains / Middle man / Inappropriate intimacy | R-47 ghi "Hai chiều" nhưng hiện thực chỉ R-63 một chiều theo mã (F5 cột Lý do giải thích); không có Middle man | Đạt |
| SML Refused bequest / Lazy class / Speculative generality | Không có kế thừa; DC-JobRegistry, DC-EmittedEventTracker có hành vi riêng | Đạt |
| SML Hidden dependencies / Temporal coupling | Thứ tự Expire trước Complete (RV-01); ép kiểu Tx sang PgTx (cùng package, có giải thích) | Vi phạm: RV-01 |
| PKP ADP (không vòng) | Xem F6.2: không có vòng | Đạt |
| PKP Layer | F6.1: mọi cạnh trong phạm vi hợp lệ; cạnh PKG-11 --> PKG-27, PKG-28 mà chữ ký đòi hỏi chưa được P09 F6 cho phép | Vi phạm: RV-02 |
| PKP Chỉ lớp public được tham chiếu từ ngoài | P12 F9 mục Visibility: lớp trong SS-01, SS-03, SS-04 package-private | Đạt |
| PKP REP | Mỗi package là một đơn vị phát hành Go, lớp dùng lại cùng nhau | Đạt |
| PKP CCP | PKG-27 trộn thực thể cụm rạp với cơ chế giao dịch (IF-08, IF-25) và sinh mã (IF-24); P10 F4 dòng 312 giải thích không tách để không thêm cạnh | Đạt có điều kiện: chấp nhận theo P10 F4 dòng 312 |
| PKP CRP | PKG-13, PKG-14 nhập PKG-21 chỉ để dùng IF-22, IF-23 | Vi phạm: RV-12 |
| PKP SDP | F6.3: PKG-24 (0,50) --> PKG-21 (0,61) lệch nhỏ; mọi cạnh còn lại đi tới package ổn định hơn | Vi phạm nhẹ: RV-12 |
| PKP SAP | F6.3: D >= 0,5 ở PKG-22 (0,78), PKG-25 (0,60); lớp cụ thể package-private nên bên ngoài chỉ thấy interface, D hiệu dụng 0 | Đạt |
| CNS Mọi message P07 có dòng ở F4; mọi operation public có nguồn | F4 so với P07 UC-005, 006, 008, 009; F2 cột Nguồn (không dòng nào rỗng) | Vi phạm: RV-14 (operation có nguồn: Đạt) |
| CNS Mọi AC trong P10 có DC hoặc lý do; mọi IF trong P11b có lớp «interface» và hiện thực | IF-01, IF-02, IF-04, IF-05, IF-06, IF-07 có dòng ở F1; IF-01 đến IF-06 có lớp hiện thực, IF-07 chỉ interface (phần trong SS-05 để lượt sau); AC của P10: chưa duyệt toàn bảng | Chưa xét đủ phần AC P10; phần IF: Đạt |
| CNS State machine khớp operation và thuộc tính; guard khớp BR | ST-01 đến ST-05 đã soát ở _review-P12.md (R12-13, R12-18), không phát hiện thêm | Đạt |
| CNS Multiplicity P12 khớp BR và NULL/FK P13; mọi lớp persistent có bảng; mọi cột có nguồn | P13 F2: 10 lớp Persistent = Có của P12 F1 có TBL-01 đến TBL-10; F6.1 có cột Nguồn DC; R-63, R-64 khớp ck_seat_status_state_link, uq_seat_status_current_ticket | Đạt |
| CNS Class diagram khớp bảng | F8 | Không xét: không đọc F8 |
| CNS Tên dùng đúng glossary | P05 | Không xét: không đọc P05 |
| CNS Quan hệ F3 so với F5; F9 so với F5 | F9 trùng đồ thị tính lại từ F5 (mọi cạnh, không thừa không thiếu); F3 so F5 thiếu bốn nhóm | Vi phạm: RV-13 (F9: Đạt) |
| DAT Chuẩn hoá và phi chuẩn hoá | P13 F5.1 và F5.3: hai chỗ phi chuẩn hoá (expiry_time, refunded_total) có cơ chế nhất quán | Đạt |
| DAT Khoá, composition, M:N, UNIQUE | Khoá nghiệp vụ có UNIQUE (hold_ref, request_id, code, idempotency_key); R-47 không bảng nối đã ghi ở P12 Vấn đề còn mở 6 | Đạt |
| DAT Kiểu tiền và CHECK miền giá trị | Tiền là BIGINT đồng; CHECK > 0, trạng thái, liên kết ghế | Vi phạm: RV-07 (hằng trong CHECK) |
| DAT Index | F6.3: mọi chỉ mục có truy vấn phục vụ; truy vấn nóng (hết hạn, giữ ghế, soát vé) có chỉ mục | Đạt |
| M9 Đối chiếu M4 | Thứ tự khoá HoldSeats 1 đến 6, HandleIpn 5, 6, 7 rồi 8, 9, CancelOnlineTicket 6, 7, 8, 9, ConfirmCashReceived 5, 6 rồi 8, ProcessRefund 9 khớp 9 hạng của P10 F3a | Đạt |
| M9 Đối chiếu M5 | P09 F7.6, F7.7, F7.9 có nội dung nhưng không có bảng "Bảng hỏng" | Vi phạm: RV-15 |
| M9 Đối chiếu M7 | F6 lối ra trạng thái trung gian đã soát ở _review-P12.md (R12-04, R12-13); thử lại chạy tiếp được (ProcessRefund bước 1, 2); thiếu dòng "Nếu dừng tại đây" | Vi phạm: RV-15 |
| M9 Đối chiếu M8 | P13 F6.4 và F4.5 ánh xạ EX sang câu khoá; chênh lệch với P08 đã giải thích (R13D-04) | Đạt |

## F6. Phụ thuộc package

### F6.1. Bảng phụ thuộc

| PKG nguồn | PKG đích | Quan hệ lớp tạo ra phụ thuộc (R-nn) | Hợp lệ theo layer |
|---|---|---|---|
| PKG-12 | PKG-14 | R-110 | Có |
| PKG-13 | PKG-21 | R-77, R-81 | Có (vị trí interface: RV-12) |
| PKG-13 | PKG-22 | R-75 | Có |
| PKG-13 | PKG-24 | R-78 | Có |
| PKG-13 | PKG-25 | R-111, R-112 | Có (Realization đi xuống) |
| PKG-13 | PKG-27 | R-65, R-66, R-67, R-68, R-74, R-79, R-82, R-160 | Có |
| PKG-13 | PKG-28 | R-10, R-11, R-69 đến R-73, R-80, R-83, R-84, R-161 đến R-165, R-176 đến R-178 | Có |
| PKG-14 | PKG-21 | R-91, R-98, R-99 | Có (RV-12) |
| PKG-14 | PKG-22 | R-18, R-86, R-94 | Có |
| PKG-14 | PKG-25 | R-113 | Có (Realization đi xuống) |
| PKG-14 | PKG-27 | R-85, R-93 | Có |
| PKG-14 | PKG-28 | R-12 đến R-15, R-87 đến R-90, R-95 đến R-97, R-166 đến R-169 | Có |
| PKG-15 | PKG-14 | R-106 | Có (cùng layer, một chiều) |
| PKG-15 | PKG-27 | R-101, R-102, R-107, R-108, R-173, R-175 | Có |
| PKG-15 | PKG-28 | R-103 đến R-105, R-109, R-170 đến R-172, R-174 | Có |
| PKG-21 | PKG-27 | R-139, R-140, R-150, R-151, R-152 | Có |
| PKG-21 | PKG-28 | R-144 đến R-149 | Có |
| PKG-24 | PKG-21 | R-132, R-133 | Có (cùng layer, một chiều) |
| PKG-24 | PKG-27, PKG-28 | kiểu ShowtimeId, SeatChangeEvent trong chữ ký IF-04 (F9; không phải cạnh F5) | Có (P09 F6) |
| PKG-28 | PKG-27 | R-44, R-45, R-46, R-53 | Có (cùng layer, một chiều) |
| PKG-11 (ngoài phạm vi) | PKG-27, PKG-28 | chữ ký công khai của PKG-13, PKG-15 (RV-02) | Không (P09 F6 dòng 143): RV-02 |

### F6.2. Vòng phụ thuộc

Không có. Đồ thị tính lại từ F5 (136 quan hệ, R-47 hai chiều tính hai cạnh): PKG-12 --> PKG-14 và PKG-15 --> PKG-14; PKG-12, 13, 14, 15 --> PKG-21, 22, 24, 25, 27, 28 theo bảng F6.1 (PKG-13 không phụ thuộc PKG-14, PKG-15); PKG-24 --> PKG-21; PKG-21 --> PKG-27, PKG-28; PKG-28 --> PKG-27; PKG-22, PKG-25, PKG-26 không phụ thuộc package nào. Không có cạnh nào ngược lại, không có cạnh đi lên layer trên.

### F6.3. Chỉ số

Ca và Ce tính theo lớp (66 phần tử cộng DC-Seat) từ cạnh F5; kiểu chỉ xuất hiện ở chữ ký (PKG-24 tới PKG-27, PKG-28) không tính.

| PKG | Ca | Ce | I = Ce / (Ca + Ce) | A | D = abs(A + I - 1) | Nhận xét |
|---|---|---|---|---|---|---|
| PKG-12 | 0 | 1 | 1,00 | 0,00 (0/1) | 0,00 | Biên của hệ thống, không ai phụ thuộc; Tham khảo: chưa gồm PKG-11 |
| PKG-13 | 0 | 22 | 1,00 | 0,00 (0/4) | 0,00 | Không ổn định, cụ thể; đúng với lớp Application; Tham khảo: chưa gồm PKG-11 |
| PKG-14 | 2 | 16 | 0,89 | 0,00 (0/3) | 0,11 | PKG-15 và PKG-12 phụ thuộc; Tham khảo: chưa gồm PKG-20 |
| PKG-15 | 0 | 10 | 1,00 | 0,00 (0/2) | 0,00 | Tham khảo: chưa gồm PKG-11 |
| PKG-21 | 7 | 11 | 0,61 | 0,18 (2/11) | 0,21 | Trộn interface ổn định (IF-22, IF-23) với lớp Pg cụ thể: RV-12; Tham khảo: chưa gồm PKG-16, PKG-17 đến PKG-20 |
| PKG-22 | 3 | 0 | 0,00 | 0,22 (2/9) | 0,78 | D lớn nhưng 7 lớp cụ thể package-private, bên ngoài chỉ thấy IF-01, IF-02 nên D hiệu dụng 0 |
| PKG-24 | 1 | 1 | 0,50 | 0,14 (1/7) | 0,36 | Phụ thuộc PKG-21 (I = 0,61) kém ổn định hơn mình: RV-12 |
| PKG-25 | 3 | 0 | 0,00 | 0,40 (2/5) | 0,60 | D lớn nhưng DC-JobSchedulerManager, DC-JobRegistry, DC-JobLoop package-private; ba bên Ca đều dùng IF-06 |
| PKG-26 | 0 | 0 | 0,00 | 1,00 (1/1) | 0,00 | Chỉ IF-07; Tham khảo: chưa gồm PKG-11 (DC-AuthFilter), PKG-19 |
| PKG-27 | 13 | 0 | 0,00 | 0,60 (6/10) | 0,40 | Ổn định, khá trừu tượng; Tham khảo: chưa gồm DC-Cinema, DC-Auditorium, DC-Movie, DC-PriceEntry, DC-CinemaManager, DC-TicketChecker, IF-14, IF-15 |
| PKG-28 | 8 | 2 | 0,20 | 0,43 (6/14) | 0,37 | Ổn định, một nửa trừu tượng (IF-16 đến IF-21); chưa gồm kiểu phụ trợ |

## F7. Tổng hợp

| Mức độ | Số phát hiện | Mã RV |
|---|---|---|
| Nghiêm trọng | 0 | - |
| Cao | 1 | RV-01 |
| Trung bình | 5 | RV-02, RV-03, RV-04, RV-05, RV-06 |
| Thấp | 9 | RV-07, RV-08, RV-09, RV-10, RV-11, RV-12, RV-13, RV-14, RV-15 |

Thứ tự chạy lại đề xuất (Bước cần sửa):

1. Hồ sơ dự án: RV-15.
2. P08: RV-08.
3. P09: RV-03, RV-15.
4. P10: RV-01, RV-03, RV-04, RV-05, RV-12.
5. P11b: RV-10.
6. P12: RV-01, RV-02, RV-03, RV-04, RV-05, RV-06, RV-08, RV-09, RV-10, RV-11, RV-12, RV-13, RV-14, RV-15.
7. P13: RV-07.

Sau đó chạy lại P13 (nếu P12 đổi interface), X1 và X2 theo bảng phụ thuộc ở README mục 5. Nhóm tiêu chí không phát hiện vi phạm: SOLID LSP, PRN Encapsulation, Composition over inheritance, Program to an interface, Law of Demeter, KISS, YAGNI, SML Data class, Message chains, Refused bequest, PKP ADP, PKP Chỉ lớp public, PKP REP, PKP SAP, DAT chuẩn hoá, DAT index.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-140 | Thời hạn giữ ghế (BR-10: 10 phút), tỷ lệ hoàn khi huỷ vé (BR-19: 70%), hạn huỷ vé (BR-18: 2 tiếng) và số ghế tối đa mỗi lần giữ (BR-05: 8 ghế) có phải điều chỉnh được mà không phát hành lại phần mềm, hay là hằng số cố định của hệ thống? | RV-07; DC-SeatHold.HoldDuration, DC-Ticket.RefundPercent, DC-BookTicketsService.maxSeats; ck_seat_hold_expiry (P13) | Các BR nêu giá trị cụ thể; P06 không có NFR về khả năng cấu hình hay bảo trì; không use case nào chỉnh các tham số này | Bên nghiệp vụ | Hằng số cố định, đổi bằng phát hành lại: giữ hằng ở một lớp mỗi giá trị, không thêm bảng cấu hình hay use case; RV-07 chỉ sửa lại câu lý do ở P13 F5.3 |
| Q-141 | Chuỗi rạp có yêu cầu hoặc kế hoạch chuyển sang cổng thanh toán khác ngoài VNPay, đến mức việc thay cổng phải chỉ sửa một package của hệ thống? | RV-03; PKG-22, DC-PaymentCallbackController, DC-PaymentReportService, IF-02; câu cam kết ở P09 F3, P10 F2, F4, P12 F10 | NFR-15 đến NFR-17 chỉ nêu giao tiếp với cổng (Interoperability); P09 F3 dòng 78 và P10 F4 dòng 304 tự suy ra khả năng thay cổng | Bên nghiệp vụ | Không: đồ án dùng VNPay sandbox, thay cổng nằm ngoài phạm vi; sửa các câu cam kết thành "đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14", không đổi thiết kế |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| Xem F2 | - | Toàn bộ đề xuất nằm ở F2 | - |

## Vấn đề còn mở

1. Tiêu chí "Class diagram khớp bảng" ghi "Không xét: không đọc F8" và "Tên dùng đúng glossary" ghi "Không xét: không đọc P05"; tiêu chí "Mọi AC trong P10 có DC" ghi "Chưa xét đủ" vì chỉ đối chiếu AC của UC-005, UC-006, UC-008, UC-009.
2. RV-04 (phần ngân sách), RV-05, RV-08, RV-11, RV-12, RV-15 ở độ tin cậy "Cần xác nhận" vì P12 F3 chưa có thân method SQL và thân hàm dựng của entity; cần P12 chạy lại với đặc tả đủ hơn hoặc hiện thực của Project 3 để xác nhận.
3. RV-02 phụ thuộc thiết kế PKG-11 chưa có: khi chạy P12 lượt PKG-11 cần kiểm lại cạnh PKG-11 --> PKG-27, PKG-28.
4. Phạm vi chưa review vì chưa thiết kế: phần còn lại của PKG-27, PKG-16, PKG-11, PKG-17 đến PKG-20, PKG-23, PKG-29, 10 use case chưa đặc tả. Hồ sơ dự án không có trường TRANH_CHAP_TAI_NGUYEN nên M9 được áp dụng theo yêu cầu người chạy, không theo hồ sơ (RV-15).
5. tools/check_artifacts.py chạy trên design/ cho file này: kết quả ghi ở phần trả lời của phiên chạy, không ghi vào artifact.
