# Nhật ký đồng bộ - Hệ thống đặt vé xem phim CineBook

## Lần 1 - Toàn bộ (X1 mục F7 và Đề xuất sửa artifact trước; X2 Đề xuất sửa artifact trước, 21 dòng)

### Cần người quyết

Các Q-140 đến Q-154 giữ trạng thái mở, chưa đánh dấu đã trả lời. Đề xuất bên dưới là đề xuất đã có trong X1, X2.

| Mục | Câu hỏi | Phương án | Đề xuất |
|---|---|---|---|
| CQ-1 (SY-22, SY-11, SY-16) | Có tách lớp miền không trạng thái DC-HoldSettlement (End, Sell) để bốn operation HoldSeats, CancelHold, ConfirmCashReceived, HandleIpn không lặp dãy Expire, UpdateStatus, ReleaseHold, SaveChanges không? Đây là phát hiện mức Cao duy nhất của X1 và là gốc của V(G) 20, 16, 13 | (a) Giữ nguyên, ghi rủi ro shotgun surgery; (b) Áp RV-01: thêm lớp mới ở PKG-28, đổi bốn operation, bốn dòng EX của P10, chạy lại X2 cho PKG-13, PKG-14 | (b), làm trước khi viết mã ở Project 3 vì Q-134 đã buộc sửa đồng thời bốn chỗ |
| CQ-2 (SY-14) | Kiểm BR-02 (nhân viên quầy chỉ bán vé cho cụm rạp của mình) đặt ở HoldSeats hay ở bước hiển thị sơ đồ ghế? Hiện HoldSeats không gọi DC-Showtime.BelongsToCinema, một yêu cầu gọi trực tiếp bỏ qua bước hiển thị | (a) Thêm kiểm vào HoldSeats (như ConfirmCashRefund đã làm cho UC-008 2c); (b) Chỉ kiểm ở bước hiển thị và ghi vào P04 UC-005 | (a), vì HoldSeats là điểm ghi duy nhất và bước hiển thị không bảo vệ được đường gọi trực tiếp |
| CQ-3 (SY-04, Q-145) | Thứ tự báo lỗi của HoldSeats khi vi phạm đồng thời suất chiếu chưa mở bán hoặc đã bắt đầu (UC-005 2a, 2c), số ghế (6a) và các điều kiện 7c, 7d, 7a, 7e | (a) Theo thứ tự bước P04; (b) Giữ thứ tự F3 hiện tại và ghi vào P04 mục 8 | (a): CheckSaleOpen, rồi BR-04, rồi số ghế, rồi 7d, 7a, 7e; kiểm nhanh số ghế ở bước 1 không ném lỗi sớm hơn BR-04 |
| CQ-4 (SY-13, Q-146) | Kiểm số tiền cổng báo (BR-91, AMOUNT_MISMATCH) áp dụng cho mọi báo hay chỉ báo thành công chưa xử lý? | (a) Chỉ báo thành công chưa xử lý; (b) Mọi báo | (a): báo thất bại (BR-39) và báo trùng (BR-37) không kiểm số tiền |
| CQ-5 (SY-15, Q-152) | Thứ tự lý do của CheckSeatSelection khi nhiều lý do cùng đúng; giữ hằng 8 (BR-05) ở một nơi | (a) EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM; (b) Thứ tự khác | (a) |
| CQ-6 (SY-28, Q-140) | Hằng BR-10 (10 phút), BR-19 (70%), BR-18 (2 tiếng), BR-05 (8 ghế) có điều chỉnh được không phát hành lại không? Quyết định này kéo theo RV-07 (bỏ hằng khỏi CHECK của P13) | (a) Hằng cố định; (b) Cấu hình được | (a): giữ hằng ở một lớp mỗi giá trị, giữ CHECK, chỉ sửa câu lý do ở P13 F5.3 |
| CQ-7 (SY-24, Q-141) | Có cần thay cổng thanh toán ngoài VNPay đến mức chỉ sửa một package không? Kéo theo RV-03 | (a) Không; (b) Có | (a): sửa các câu cam kết ở P09 F3, P10 F2, F4, P12 F10 thành "đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14" |
| CQ-8 (SY-36) | Bật TRANH_CHAP_TAI_NGUYEN = Có trong hồ sơ dự án, thêm bảng Bảng hỏng ở P09 F7 và dòng "Nếu dừng tại đây" ở P12 F3? | (a) Bật; (b) Không | (a), vì race condition là trọng tâm của đề tài |
| CQ-9 (SY-23, SY-25 đến SY-27, SY-29 đến SY-33) | Các tái cấu trúc mức Trung bình và Thấp của X1 (RV-02 DTO ở chữ ký công khai; RV-04 tách DC-SeatEventCleanupJob, gắn Q-148; RV-05 tách DC-PgTicketingStore; RV-06 tách IF-17, IF-18, IF-20 theo bên gọi; RV-08 gộp CheckNoActiveSeatHold; RV-09 tách cancelInTx; RV-10 gom tham số IF-01; RV-11 truyền mã thay entity; RV-12 chuyển IF-22, IF-23 sang PKG-28) có áp dụng không? | Áp từng mục hoặc để lại làm hướng cải tiến | Áp RV-06 và RV-09 cùng đợt với RV-01 (cùng chạm bốn operation); các mục còn lại để sau khi có mã Project 3, vì nhiều mục ở độ tin cậy "Cần xác nhận" chưa có thân method |
| CQ-10 (Q còn lại) | Q-142 (SeatHold.Complete, Cancel, FailPayment khi chưa gọi Expire), Q-143, Q-144, Q-147, Q-148, Q-149 và Q-150, Q-151, Q-153, Q-154 | Theo từng Q | Giữ đề xuất đã ghi ở Câu hỏi mở của X2: Q-142 entity giữ thuần, HoldNotActiveError mang ACTIVE; Q-143 chỉ cộng ghế HELD thuộc lần giữ ghế, rỗng trả 0; Q-144 coi là tiền điều kiện; Q-147 NotFoundError như CancelHold; Q-148 cleanupEvents ngữ cảnh riêng 2 giây; Q-149 bỏ lượt khi hạn dưới 5 giây; Q-150 trả nil kèm log cảnh báo; Q-151 múi giờ Asia/Ho_Chi_Minh; Q-153 8 giờ; Q-154 hết hạn khi now >= expiresAt. Hai chỗ đã áp theo yêu cầu bổ sung (SY-03 theo hướng Q-142, SY-08 theo hướng Q-149) cần sửa lại nếu chọn khác |

### Bảng đồng bộ

| SY | Nguồn (file, mục) | Đích (bước, mã phần tử) | Loại | Nội dung | Kết quả hoặc lý do |
|---|---|---|---|---|---|
| SY-01 | X2, Đề xuất sửa dòng 1 | P12 F2 DC-PaymentTransaction | Áp dụng | Thêm getter GatewayTransactionNo, LateReason, DuplicateReportCount, RefundedTotal | Đã áp, P12 lên 1.5; diagram P12-class-PKG-28 khớp |
| SY-02 | X2, dòng 2 | P12 F2 DC-RefundRequest | Áp dụng | Thêm getter RequestType, RefundResult | Đã áp, P12 1.5; diagram P12-class-PKG-28 khớp |
| SY-03 | X2, dòng 3 | P12 F6.2 ST-01 (hàng complete, cancel, failPayment khi now >= expiryTime) | Áp dụng | Hàng F6.2 sửa theo F3: entity không đổi trạng thái, ném HoldNotActiveError mang ACTIVE; bên gọi gọi Expire trước | Đã áp theo yêu cầu bổ sung, mọi service trong F3 đã gọi Expire trước nên không đổi hành vi; Q-142 giữ mở (CQ-10) |
| SY-04 | X2, dòng 4 | P12 F3 HoldSeats bước 1, (e), (f); P04 UC-005 mục 8 | Cần người quyết | Thứ tự kiểm khác P04 | Phụ thuộc Q-145 còn mở; xem CQ-3 |
| SY-05 | X2, dòng 5 | P12 F3 HoldSeats (g), IF-18.SaveChanges, F3b SQ-01-N2; P13 F4.5 EX-01, SQL mẫu, F6 hàng "Hai người cùng giữ một ghế" | Áp dụng | Lỗi thật của trg_seat_status_link khi chọn lại ghế của lần giữ ghế cũ; sửa bằng hai lượt SaveChanges (Trống rồi giữ lại) | Đã áp, P12 1.5, P13 1.4, P13-schema.sql không đổi; kiểm trên PostgreSQL 16 (xem Kiểm PostgreSQL) |
| SY-06 | X2, dòng 6 | P12 F6.2 ST-04 (bảng sự kiện bị từ chối) | Áp dụng | Tách hàng: BeginAttempt chỉ kiểm trạng thái và lượt còn; chặn gửi song song nằm ở ProcessRefund và IF-23.ExtendClaim (ClaimLostError) | Đã áp, P12 1.5. Bảng này không có cột Operation nên sửa nội dung hàng thay vì đổi cột |
| SY-07 | X2, dòng 7 | P12 F2 DC-RefundService.ProcessRefund (cột Ngoại lệ) | Áp dụng | ErrClaimLost đổi thành ClaimLostError | Đã áp, P12 1.5 |
| SY-08 | X2, dòng 8 | P12 F3 ProcessRefund bước 2; P09 F7.7 | Áp dụng | Ngưỡng bỏ lượt từ 10 giây thành 15 giây (hạn tính ra dưới 5 giây) để không trùng biên 10 giây | Đã áp theo yêu cầu bổ sung, P12 1.5, P09 1.6; phần giá trị trả về khi bỏ lượt (Q-150) và Q-149 giữ mở (CQ-10) |
| SY-09 | X2, dòng 9 | P12 F2 BeginAttempt; F3 releaseBatch, CheckTicket | Áp dụng | Ghi bất biến cho ba nhánh không tới được (không bỏ nhánh) | Đã áp, P12 1.5. Đã đối chiếu: RecordResult chỉ tạo WAITING_RETRY khi còn lượt; LockByHolds chỉ trả ghế thuộc lô; khoá ngoại RESTRICT từ vé tới seat_status và từ seat_status tới suất chiếu |
| SY-10 | X2, dòng 10 | P12 F3 ConfirmCashRefund bước 3; F2 DC-Showtime.BelongsToCinema | Áp dụng | Thêm Showtime.BelongsToCinema(clerk.cinemaId), sai thì ChannelMismatchError (UC-008 2c); BR-17 thêm vào nguồn của BelongsToCinema | Đã áp, P12 1.5. Đúng với UC-008 luồng 2c ("Từ chối huỷ vé và thông báo quy tắc bị vi phạm (BR-17)"); ConfirmCashRefund đã nạp suất chiếu ở bước 1 nên không thêm khoá |
| SY-11 | X2, dòng 11 | P12 F3 HoldSeats, HandleIpn, ProcessRefund | Cần người quyết | Tách phương thức theo giai đoạn (V(G) 20, 16, 13) | Tái cấu trúc, trùng hướng RV-01; xem CQ-1 |
| SY-12 | X2, dòng 12 | P12 F2 HoldSeats (cột Ngoại lệ) | Áp dụng | Thêm HoldNotActiveError, LockOrderViolationError | Đã áp, P12 1.5 |
| SY-13 | X2, dòng 13 | P12 F3 HandleIpn bước 4 | Cần người quyết | Kiểm số tiền chỉ với báo thành công | Phụ thuộc Q-146 còn mở và đổi BR-91; xem CQ-4 |
| SY-14 | X2, dòng 14 | P12 F3 HoldSeats; P04 UC-005 2b; BR-02 | Cần người quyết | Nơi kiểm BR-02 khi giữ ghế | Đổi tiền điều kiện của HoldSeats; xem CQ-2 |
| SY-15 | X2, dòng 15 | P12 F2 CheckSeatSelection; maxSeats | Cần người quyết | Thứ tự lý do, một nơi định nghĩa hằng 8 | Phụ thuộc Q-152 còn mở; xem CQ-5 |
| SY-16 | X2, dòng 16 | P12 F3, TC của PKG-13, PKG-14 | Cần người quyết | Chạy lại X2 nếu áp RV-01 | Phụ thuộc quyết định SY-22 (CQ-1) |
| SY-17 | X2, dòng 17 | P12 IF-17, IF-18, IF-20, IF-22, IF-23, DC-PgTicketingStore | Cần người quyết | Cập nhật test double nếu áp RV-05, RV-06, RV-12 | Phụ thuộc SY-26, SY-27, SY-33 (CQ-9) |
| SY-18 | X2, dòng 18 | P12 DC-Customer, DC-BoxOfficeClerk, cancelInTx, hàm dựng RefundRequest | Cần người quyết | Chạy lại X2 nếu áp RV-08, RV-09, RV-11 | Phụ thuộc SY-29, SY-30, SY-32 (CQ-9) |
| SY-19 | X2, dòng 19 | P09, P10, P12 chữ ký công khai, writeIpnAnswer, cleanupEvents | Cần người quyết | Chạy lại X2 nếu áp RV-02, RV-03, RV-04 | Phụ thuộc SY-23, SY-24, SY-25 (CQ-7, CQ-9) |
| SY-20 | X2, dòng 20 | Hồ sơ dự án, P09 F7 | Cần người quyết | Bật TRANH_CHAP_TAI_NGUYEN, thêm Bảng hỏng | Trùng RV-15; xem CQ-8 |
| SY-21 | X2, dòng 21 | P13 ck_seat_hold_expiry, ck_refund_request_attempts | Cần người quyết | Cập nhật ca tích hợp cuối nếu áp RV-07 | Phụ thuộc Q-140 (CQ-6) |
| SY-22 | X1 RV-01 | P10; P12 (DC-BookTicketsService, DC-PaymentReportService, DC-SeatHold, DC-Booking, DC-Ticket) | Cần người quyết | Extract Class DC-HoldSettlement | Thêm lớp, đổi bốn operation và sequence; xem CQ-1 |
| SY-23 | X1 RV-02 | P12 chữ ký công khai PKG-13, PKG-15 | Cần người quyết | DTO thay kiểu miền ở chữ ký công khai | Đổi nhiều operation; phụ thuộc PKG-11 chưa thiết kế; xem CQ-9 |
| SY-24 | X1 RV-03 | P09, P10, P12 PKG-22, writeIpnAnswer | Cần người quyết | Cô lập cổng thanh toán | Phụ thuộc Q-141 còn mở; xem CQ-7 |
| SY-25 | X1 RV-04 | P10, P12 DC-HoldExpiryJob | Cần người quyết | Khôi phục DC-SeatEventCleanupJob | Đổi cấu trúc lớp; liên quan Q-148; xem CQ-9 |
| SY-26 | X1 RV-05 | P10, P12 DC-PgTicketingStore | Cần người quyết | Tách store theo bên gọi | Độ tin cậy Cần xác nhận, đổi ranh giới lớp; xem CQ-9 |
| SY-27 | X1 RV-06 | P12 IF-17, IF-18, IF-20 | Cần người quyết | Tách interface theo bên gọi | Đổi interface và sequence; xem CQ-9 |
| SY-28 | X1 RV-07 | P13 ck_seat_hold_expiry, ck_refund_request_attempts | Cần người quyết | Bỏ hằng nghiệp vụ khỏi CHECK | Phụ thuộc Q-140 còn mở, đổi P13-schema.sql; xem CQ-6 |
| SY-29 | X1 RV-08 | P08, P12 CheckNoActiveSeatHold | Cần người quyết | Gộp hai hàm thành một | Đổi cấu trúc lớp, Cần xác nhận; xem CQ-9 |
| SY-30 | X1 RV-09 | P12 cancelInTx, LockPaymentOfTicket | Cần người quyết | Tách cancelInTx thành nhánh trực tuyến và tiền mặt | Đổi operation và sequence SQ-04; xem CQ-9 |
| SY-31 | X1 RV-10 | P11b, P12 IF-01, DC-VnpayRefundClient, DC-VnpayUrlBuilder | Cần người quyết | Gom tham số thành kiểu chung | Đổi chữ ký interface của hệ thống ngoài; xem CQ-9 |
| SY-32 | X1 RV-11 | P12 hàm dựng PaymentTransaction, Booking, RefundRequest | Cần người quyết | Truyền mã thay entity | Đổi chữ ký, Cần xác nhận; xem CQ-9 |
| SY-33 | X1 RV-12 | P10, P12 IF-22, IF-23 | Cần người quyết | Chuyển interface sang PKG-28 | Đổi ranh giới package; xem CQ-9 |
| SY-34 | X1 RV-13 | P12 F5, F3 | Áp dụng | Thêm R-179 đến R-183 (Dependency, local); với DC-SeatEventHubManager --> IF-22 sửa cột "được dùng" của F3 vì IF-22 chỉ được gọi bên trong DC-SeatReplayReader | Đã áp, P12 1.5; tổng 141 quan hệ; quan hệ local không vẽ trên class diagram; P13 cập nhật dải R-160 đến R-183 |
| SY-35 | X1 RV-14 | P12 F4 | Áp dụng | Thêm hai dòng // sendTicketsEmail (P07 UC-005 message 14), // sendRefundNotificationEmail (P07 UC-006 message 7) | Đã áp, P12 1.5. Phần điền số thứ tự message P07 cho 88 dòng cũ không áp: cần đính kèm P07, để lần rà F4 sau |
| SY-36 | X1 RV-15 | project-profile.md, P09 F7, P12 F3 | Cần người quyết | Bật TRANH_CHAP_TAI_NGUYEN, thêm Bảng hỏng, thêm "Nếu dừng tại đây" | Đổi phạm vi mô-đun của hồ sơ; xem CQ-8 |

Không có mục loại Chờ: không đề xuất nào phụ thuộc use case chưa đặc tả (RV-02 phụ thuộc PKG-11 chưa thiết kế, đã gộp vào CQ-9).

### Lỗi hình thức xử lý (check_artifacts.py)

| Lỗi | Xử lý |
|---|---|
| K10 UC-006: A-2e, A-6, A-RX có nhiều cạnh vào | Thêm Merge M-2e, M-6, M-RX và cạnh E-33, E-34, E-35 ở bảng Node, bảng Edge, bảng đối chiếu và diagrams/P04-activity-UC-006.drawio; UC-006 lên 1.8 |
| K10 UC-008: A-6c có nhiều cạnh vào | Thêm Merge M-6c và cạnh E-57 tương tự; UC-008 lên 1.8; diagrams/P04-activity-UC-008.drawio |

check_artifacts.py: trước 4 LOI, 111 CANH_BAO; sau 0 LOI, 111 CANH_BAO. Cảnh báo còn lại có sẵn từ trước (K09 lệch phiên bản ở file chưa đổi nội dung, K11, K18 toạ độ), ngoài phạm vi.

### Kiểm PostgreSQL

P13-schema.sql không đổi; vẫn chạy lại trên PostgreSQL 16 (docker postgres:16, psql ON_ERROR_STOP=1, schema áp không lỗi). File p13-tests.sql của phiên trước không còn nên viết bộ ca tối thiểu mới tại /private/tmp/claude-502/-Users-luytbq-projects-l-dat-ve-xem-phim/42f5045c-a07a-493d-b921-24e486bb05b9/scratchpad/p13-tests.sql. Kết quả 5/5 đạt:

| Ca | Nội dung | Kết quả |
|---|---|---|
| TC-P1 | Một UPDATE đổi current_hold_id từ H0 (EXPIRED) sang H1 bị từ chối bằng check_violation: tái hiện đúng lỗi của P12 1.4 | Đạt |
| TC-P2 | Hai UPDATE trong cùng giao dịch (Trống rồi HELD bởi H1) thành công | Đạt |
| TC-P3 | Chọn lại ghế 101 của H0 cùng ghế trống 103, hai lượt, cả hai HELD bởi H1 | Đạt |
| TC-P4 | Ghi đè trực tiếp liên kết đang có của lần giữ ghế còn ACTIVE vẫn bị từ chối (lưới an toàn còn nguyên) | Đạt |
| TC-P5 | Gán H1 trước khi trả ghế (sai thứ tự) vẫn bị từ chối | Đạt |

Container p13check đã dừng. Docker daemon đã chạy sẵn nên không khởi động hay dừng colima.

### Kết luận về trg_seat_status_link

Đề xuất của X2 đúng, là lỗi thiết kế thật: HoldSeats (g) làm ReleaseHold(mã cũ) rồi HoldFor trên cùng một SeatStatus trong bộ nhớ, SaveChanges ghi một UPDATE đổi liên kết từ H0 sang H1 và bị trigger từ chối, làm hỏng chính luồng chọn lại ghế sau khi giữ ghế hết hạn mà job chưa quét. Phương án ít đổi nhất: không sửa schema (giữ lưới an toàn của BR-08, BR-09), đổi cách gọi ở P12: SaveChanges ngay sau ReleaseHold để ghi Trống, rồi HoldFor và SaveChanges lần hai; IF-18.SaveChanges gọi nhiều lần trong một giao dịch, dùng chung mã sự kiện và một dòng seat_event mỗi suất chiếu. P13 EX-01 và SQL mẫu có thêm câu UPDATE trả Trống riêng.

### File đã sửa và phiên bản mới

| File | Phiên bản |
|---|---|
| design/P12-class-design.md | 1.5 |
| design/P13-data-model.md | 1.4 |
| design/P09-architecture.md | 1.6 |
| design/P04-uc-specs/UC-006-refund-late-payment.md | 1.8 |
| design/P04-uc-specs/UC-008-cancel-ticket.md | 1.8 |
| design/X1-design-review.md | 1.1 |
| design/X2-unit-tests.md | 1.1 |
| design/diagrams/P12-class-PKG-28.drawio, P12-sequence-hold-seats.drawio, P04-activity-UC-006.drawio, P04-activity-UC-008.drawio | bố cục đã căn chỉnh, XML parse được |

Chỉ sửa dòng Đầu vào đã dùng (không đổi nội dung, không nâng phiên bản để tránh dây chuyền): P06-supplementary-spec.md, P10-design-elements.md, P11b-system-interfaces.md, P11b-system-interfaces/SS-01-payment-gateway.md, SS-04-scheduler.md, P11a-gui/screen-list.md, P11a-gui/ui-standards.md, P04-uc-specs/UC-005-book-tickets.md, UC-009-check-ticket.md, UC-014-schedule-showtimes.md, P07-uc-analysis/UC-014-schedule-showtimes-analysis.md. Dòng Đầu vào đã dùng của X1 và X2 đã khớp số phiên bản nhưng hai file chưa được chạy lại.

### Bước cần rà lại

- X2: chạy lại cho DC-RefundService.ProcessRefund (EC-170, TC-340 và các TC biên 10 giây theo ngưỡng 15 giây), DC-SeatHold.Complete, Cancel, FailPayment (F2.3), ConfirmCashRefund (TC luồng 2c), HoldSeats (TC-368 và ca tích hợp thứ sáu), F2.8, F2.9, F2.10 đến F2.13 (dùng getter mới).
- X1: rà lại F5, F6 cho 5 quan hệ mới và sơ đồ phụ thuộc package (không đổi cạnh package).
- P07, P08: không đổi nội dung; K09 của P07 UC-006, UC-008 lệch phiên bản P04 là cảnh báo có sẵn.
- P10, P11b: chỉ cần rà nếu quyết định áp RV-01, RV-03, RV-04, RV-05, RV-12, RV-10.
- Chạy lại P13 sau khi quyết SY-28 (RV-07); P13-schema.sql hiện không đổi.

Khoảng trống trong dải mã do gộp lô: không có (không có file pending). Mã SY cấp SY-01 đến SY-36; không cấp Q hay ASM mới (Q cuối vẫn Q-154).
