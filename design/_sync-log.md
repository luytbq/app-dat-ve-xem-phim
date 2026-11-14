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

## Lần 2 - Cần người quyết của lần 1 (SY-04, SY-11, SY-13 đến SY-33, SY-36) và Q-140 đến Q-154

### Cần người quyết

Không còn mục nào. Chủ dự án chốt tất cả theo đề xuất ghi ở lần 1 (_sync-log.md, X1, X2). Các mục chốt "để sau khi có mã Project 3" ghi loại Chờ ở bảng dưới.

### Bảng đồng bộ

| SY | Nguồn (file, mục) | Đích (bước, mã phần tử) | Loại | Nội dung | Kết quả hoặc lý do |
|---|---|---|---|---|---|
| SY-04 | X2 dòng 4; CQ-3, Q-145 | P12 F3 HoldSeats | Áp dụng | Thứ tự báo lỗi theo P04: CheckSaleOpen, BR-04, số ghế, 7d, 7a, 7e | Đã áp, P12 1.6: kiểm nhanh số ghế ở bước 1 chỉ ghi nhớ selectionFlaw, ném sau BR-04; không đổi P04 |
| SY-11 | X2 dòng 11; CQ-1 | P12 F3 HoldSeats, HandleIpn, ProcessRefund | Áp dụng | Giảm V(G) bằng cách tách theo giai đoạn | Đã áp qua SY-22 cho HoldSeats và HandleIpn (dãy kết thúc và bán ghế chuyển sang DC-HoldSettlement); ProcessRefund (V(G) 13) giữ nguyên vì ba giao dịch đã là ba giai đoạn rõ |
| SY-13 | X2 dòng 13; CQ-4, Q-146 | P12 F3 HandleIpn bước 3, 4; P09 F7.6; P11b SS-01 | Áp dụng | Kiểm số tiền (BR-91) chỉ với báo thành công chưa xử lý | Đã áp, P12 1.6, P09 1.7, SS-01 1.4. BR-91 vốn chỉ nêu thanh toán thành công nên sổ BR và P04 UC-006 không đổi |
| SY-14 | X2 dòng 14; CQ-2 | P12 F3 HoldSeats, F1b DC-HoldSeatsRequest | Áp dụng | Kiểm BR-02 ở HoldSeats (phương án a) | Đã áp, P12 1.6: nhân viên quầy thì Showtime.BelongsToCinema(req.holderCinemaId), sai thì ChannelMismatchError (UC-005 2b). Thêm trường holderCinemaId vào DC-HoldSeatsRequest vì HolderRef không mang cụm rạp (lệch nhỏ so với đề xuất gốc, xem Ghi chú) |
| SY-15 | X2 dòng 15; CQ-5, Q-152 | P12 F2 CheckSeatSelection, DC-Showtime | Áp dụng | Thứ tự lý do EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM; hằng 8 một nơi | Đã áp, P12 1.6: DC-Showtime.MaxSeatsPerHold thay maxSeats của DC-BookTicketsService |
| SY-16 | X2 dòng 16; CQ-1 | P12 F3, TC của PKG-13, PKG-14 | Áp dụng | Chạy lại X2 cho PKG-13, PKG-14 vì RV-01 được áp | Đã ghi ở mục Cần chạy lại X2; X2 chưa chạy lại |
| SY-17 | X2 dòng 17; CQ-9 | P12 IF-17, IF-18, IF-20, IF-22, IF-23, DC-PgTicketingStore | Áp dụng | Cập nhật bản giả theo RV-06 | Phần RV-06 đã áp (IF-26, IF-27); cập nhật bản giả nằm ở X2 chạy lại. Phần RV-05, RV-12 chờ (SY-26, SY-33) |
| SY-18 | X2 dòng 18; CQ-9 | P12 cancelInTx, DC-Customer, DC-BoxOfficeClerk, hàm dựng | Áp dụng | Chạy lại X2 theo RV-09 | Phần RV-09 đã áp; chạy lại X2 cho F2.33. Phần RV-08, RV-11 chờ (SY-29, SY-32) |
| SY-19 | X2 dòng 19; CQ-7, CQ-9 | P09, P10, P12 chữ ký công khai, writeIpnAnswer, cleanupEvents | Chờ | Chạy lại X2 nếu áp RV-02, RV-04 | RV-02, RV-04 để sau Project 3 (SY-23, SY-25); phần RV-03 đã áp theo SY-24 nhưng không đổi TC |
| SY-20 | X2 dòng 20; CQ-8 | Hồ sơ dự án, P09 F7 | Áp dụng | Bật TRANH_CHAP_TAI_NGUYEN, thêm Bảng hỏng | Đã áp: hồ sơ thêm trường; P09 1.7 thêm F7.10 Bảng hỏng; F4.5 của X2 đối chiếu bảng này khi chạy lại |
| SY-21 | X2 dòng 21; CQ-6 | P13 ck_seat_hold_expiry, ck_refund_request_attempts | Không áp | Cập nhật ca tích hợp cuối nếu áp RV-07 | RV-07 không đổi CHECK (Q-140 giữ hằng cố định) nên ca tích hợp cuối giữ nguyên |
| SY-22 | X1 RV-01; CQ-1 | P10; P12 (DC-BookTicketsService, DC-PaymentReportService, DC-SeatHold, DC-Booking, DC-Ticket) | Áp dụng | Extract Class DC-HoldSettlement | Đã áp, P12 1.6, P10 1.5. Xem mục RV-01 bên dưới |
| SY-23 | X1 RV-02; CQ-9 | P12 chữ ký công khai PKG-13, PKG-15 | Chờ | DTO ở chữ ký công khai | Chủ dự án chốt để sau khi có mã Project 3 và thiết kế PKG-11 |
| SY-24 | X1 RV-03; CQ-7, Q-141 | P09 F3, P10 F2, F3 (PKG-22), P12 F10 | Áp dụng | Sửa câu cam kết đổi cổng | Đã áp, P09 1.7, P10 1.5, P12 1.6: "đổi cổng sửa PKG-22, bảng RspCode ở PKG-12 và phần đọc tham số ở PKG-14"; thiết kế không đổi |
| SY-25 | X1 RV-04; CQ-9, Q-148 | P10, P12 DC-HoldExpiryJob | Chờ | Khôi phục DC-SeatEventCleanupJob | Để sau Project 3; Q-148 xử lý bằng cleanupEvents ngữ cảnh riêng 2 giây (P12 1.6) |
| SY-26 | X1 RV-05; CQ-9 | P10, P12 DC-PgTicketingStore | Chờ | Tách store theo bên gọi | Để sau Project 3: cần thân SQL của 39 operation |
| SY-27 | X1 RV-06; CQ-9 | P12 IF-17, IF-18, IF-20 | Áp dụng | Tách interface theo bên gọi | Đã áp, P12 1.6, P10 1.5: IF-26 IHoldSweepRepository (LockExpiredBatch, LockReleasableBatch, LockByHolds) và IF-27 ITicketLockRepository (LockTicketByID, LockTicketByCode, LockTicketShared, UpdateTicketStatus); IF-20 còn bốn operation đọc và thêm lần đặt |
| SY-28 | X1 RV-07; CQ-6, Q-140 | P13 F5.3 seat_hold.expiry_time | Áp dụng | Giữ CHECK, sửa câu lý do | Đã áp, P13 1.5; P13-schema.sql không đổi |
| SY-29 | X1 RV-08; CQ-9 | P08, P12 CheckNoActiveSeatHold | Chờ | Gộp hai hàm | Để sau Project 3 (Cần xác nhận khi có thân method) |
| SY-30 | X1 RV-09; CQ-9 | P12 cancelInTx, LockPaymentOfTicket | Áp dụng | Tách nhánh trực tuyến và tiền mặt | Đã áp, P12 1.6: cancelOnlineInTx, cancelCashInTx, cancelAndReleaseSeat; lockPaymentOfTicket thuộc DC-CancelTicketService (thêm IF-19), DC-RefundService bỏ IF-20; sequence SQ-04 khớp |
| SY-31 | X1 RV-10; CQ-9 | P11b, P12 IF-01 và các lớp VNPay | Chờ | Gom tham số thành kiểu chung | Để sau Project 3 |
| SY-32 | X1 RV-11; CQ-9 | P12 hàm dựng | Chờ | Truyền mã thay entity | Để sau Project 3 (Cần xác nhận) |
| SY-33 | X1 RV-12; CQ-9 | P10, P12 IF-22, IF-23 | Chờ | Chuyển interface sang PKG-28 | Để sau Project 3 (Cần xác nhận) |
| SY-36 | X1 RV-15; CQ-8 | Hồ sơ dự án, P09 F7, P12 F3 | Áp dụng | Bật mô-đun đồng thời, Bảng hỏng, Nếu dừng tại đây | Đã áp: hồ sơ, P09 1.7 F7.10, P12 1.6 (StartOnlinePayment một dòng, ProcessRefund hai dòng) |

### Câu hỏi Q-140 đến Q-154

Cả 15 câu đã đánh dấu "Đã trả lời" kèm nội dung chốt: Q-140, Q-141 ở X1 (1.2); Q-142 đến Q-154 ở X2 (1.2). Q-142 và Q-149 đã áp ở lần 1 và đề xuất khớp nên chỉ đánh dấu. Không câu nào đổi quy tắc nghiệp vụ: Q-140 giữ hằng cố định, Q-146 chỉ làm rõ BR-91 (vốn chỉ nêu thanh toán thành công) với BR-37 và BR-39, Q-151 và Q-153 là tham số kỹ thuật không có trong đề bài. Không cấp BR mới (BR lớn nhất vẫn BR-93), sổ BR, UC, P06 và yeu-cau-dat-ve.md không đổi.

| Q | Chốt | Nơi áp |
|---|---|---|
| Q-140 | Hằng cố định, giữ CHECK | P13 1.5 F5.3 |
| Q-141 | Không cần thay cổng, sửa câu cam kết | P09 1.7 F3, P10 1.5, P12 1.6 F10 |
| Q-142 | Entity thuần, service gọi Expire trước | P12 F3 (đã áp lần 1), nay End và Sell gọi Expire |
| Q-143 | CalculateTotal chỉ cộng ghế HELD thuộc lần giữ ghế, rỗng trả 0 | P12 1.6 F2 |
| Q-144 | Tiền điều kiện, không kiểm | P12 1.6 mục 0.3 |
| Q-145 | Thứ tự theo P04 | P12 1.6 F3 HoldSeats |
| Q-146 | Chỉ báo thành công chưa xử lý | P12 1.6 F3, P09 1.7 F7.6, SS-01 1.4 |
| Q-147 | NotFoundError | P12 1.6 F2, F3 |
| Q-148 | cleanupEvents ngữ cảnh riêng 2 giây | P12 1.6 F2, F3 |
| Q-149 | Ngưỡng 15 giây | Đã áp lần 1 (P12 F3, P09 F7.7), khớp |
| Q-150 | Trả nil kèm log cảnh báo | P12 1.6 F2, F3 |
| Q-151 | Asia/Ho_Chi_Minh | P12 1.6 F2 DetermineSeatPrice |
| Q-152 | Thứ tự EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM | P12 1.6 F2 |
| Q-153 | Quản trị viên 8 giờ | P12 1.6 F2 IssueSession |
| Q-154 | now >= expiresAt, đồng hồ tiêm vào | P12 1.6 F2 VerifySession |

### RV-01: DC-HoldSettlement

- Lớp mới DC-HoldSettlement («utility», PKG-28, không trạng thái, không I/O, không khoá, không gọi kho) cùng kiểu DC-HoldEndReason (EXPIRY, CANCEL, PAYMENT_FAILURE) và DC-HoldEndOutcome (holdChanged, expired, released). Ba operation: End (Expire, Cancel hoặc FailPayment, rồi ReleaseHold từng ghế), Sell (kiểm ghế, Complete, NewBooking tự tạo vé), FinishSale (MarkSold sau khi InsertWithTickets gán mã vé).
- Bốn operation đổi: HoldSeats (End(EXPIRY) ở bước (f) khi chưa có ghế khoá, lần hai ở (g) để trả ghế), CancelHold (End(CANCEL)), ConfirmCashReceived (End(EXPIRY), Sell, FinishSale), HandleIpn (End(EXPIRY), Sell, FinishSale, End(PAYMENT_FAILURE)); StartOnlinePayment dùng End(EXPIRY, nil). DC-Booking.NewBooking nhận ghế và mã vé rồi tự tạo vé; DC-Ticket.NewTicket thành newTicket nội bộ PKG-28. DC-SeatHold.Complete, Cancel, FailPayment chỉ còn DC-HoldSettlement gọi (ngoại lệ DC-HoldExpiryJob.expireBatch gọi Expire theo lô).
- Giữ nguyên thứ tự khoá hạng 5, 6, 8 (P09 F7.3) và ranh giới giao dịch: HoldSettlement không khoá, mọi lời gọi khoá, UpdateStatus, SaveChanges, InsertWithTickets vẫn ở service.
- trg_seat_status_link: HoldSeats (g) vẫn ghi Trống bằng SaveChanges riêng cho ghế của lần giữ ghế cũ (End trả các ghế đó về AVAILABLE) trước khi HoldFor gán lần giữ ghế mới và SaveChanges lần hai, nên không có UPDATE nào đổi liên kết từ lần giữ ghế này sang lần giữ ghế khác; P13-schema.sql không đổi.
- Tài liệu và sơ đồ đổi: P12 (F1, F1b, F2, F3, F3b SQ-01 đến SQ-05, F4, F5, F6, F8, F9, F10), P10 (F3, F3a EX-01 đến EX-08, EX-13, EX-14, F4, F5, F6), sơ đồ P12-class-PKG-28, PKG-13, PKG-12-PKG-14-PKG-15, PKG-21, PKG-27 và P12-sequence-hold-seats, handle-ipn, expiry-sweep, cancel-ticket, check-ticket. P13 không đổi nội dung nghiệp vụ: ánh xạ bảng và SQL mẫu không đổi.

### Ghi chú khi áp dụng (lệch hoặc làm rõ so với đề xuất gốc)

1. FinishSale là operation thứ ba: Sell không đánh dấu ghế đã bán được vì mã vé do IF-20.InsertWithTickets gán sau; tách FinishSale giữ đúng thứ tự Insert rồi MarkSold rồi SaveChanges.
2. End là lặp an toàn: EXPIRY gọi trên lần giữ ghế đã Hết hạn thì chỉ trả các ghế còn trỏ tới nó. Cần cho HoldSeats (g), vì (e) và (f) đã chuyển Hết hạn trước khi khoá ghế. Hệ quả nhỏ: HandleIpn và ConfirmCashReceived gặp lần giữ ghế đã được job chuyển Hết hạn mà ghế chưa trả thì trả ghế luôn trong giao dịch đang giữ khoá hạng 6 (Q-134), không còn chờ DC-SeatReleaseJob.
3. SY-14: HoldSeatsRequest thêm holderCinemaId (tầng gọi lấy từ ActorContext của phiên). Thứ tự báo lỗi cho nhân viên quầy sai cụm rạp trên suất chiếu chưa mở bán: 2b đứng trước 2a và 2c (P04 chỉ định 2a rồi 2b rồi 2c nhưng CheckSaleOpen gộp 2a và 2c).
4. SY-27: một interface IF-26 cho cả ba operation của hai job nền (X1 ghi "tách thao tác chỉ dành cho hai job nền").
5. PKG-28 có 18 phần tử (P10) vượt mức 15; ghi ở P10 Vấn đề còn mở 2 và P12 F9, giữ nguyên vì tách package thêm cạnh phụ thuộc.
6. Hồ sơ bật TRANH_CHAP_TAI_NGUYEN nên check_artifacts.py sinh 6 cảnh báo K14 (UC-005, 006, 008, 009, 013, 014 chưa có bảng Thao tác nguyên tử M1). Đó là việc chạy lại P04, không thuộc X3 (không thêm yêu cầu mới).
7. Chưa đổi: sổ BR, P04, P06, P07, P08, P11b chính, yeu-cau-dat-ve.md, P13-schema.sql.

### Lỗi hình thức (check_artifacts.py)

check_artifacts.py: trước lượt 2: 0 LOI, 111 CANH_BAO; sau (đã đồng bộ dòng Đầu vào đã dùng): 0 LOI, 117 CANH_BAO. Tăng 6 cảnh báo K14 do bật TRANH_CHAP_TAI_NGUYEN (ghi chú 6); K09 mới do đổi phiên bản đã xử lý. Cảnh báo còn lại có sẵn từ lần 1 (K09 lệch phiên bản ở file chưa đổi nội dung, K10, K11, K18, K03).

### Kiểm PostgreSQL

P13-schema.sql không đổi (Q-140 giữ CHECK, RV-01 không chạm schema) nên không chạy lại PostgreSQL 16; kết quả 5/5 ca trigger của lần 1 vẫn là kết quả hiện hành. Không khởi động docker hay colima.

### File đã sửa và phiên bản mới

| File | Phiên bản |
|---|---|
| design/P12-class-design.md | 1.6 |
| design/P10-design-elements.md | 1.5 |
| design/P09-architecture.md | 1.7 |
| design/P13-data-model.md | 1.5 |
| design/X1-design-review.md | 1.2 |
| design/X2-unit-tests.md | 1.2 (chỉ đánh dấu Q, trạng thái đề xuất, dòng Đầu vào đã dùng) |
| design/P11b-system-interfaces/SS-01-payment-gateway.md | 1.4 |
| design/project-profile.md | thêm trường TRANH_CHAP_TAI_NGUYEN (hồ sơ không có số phiên bản) |
| design/diagrams/P12-class-PKG-28.drawio, P12-class-PKG-13.drawio, P12-class-PKG-12-PKG-14-PKG-15.drawio, P12-class-PKG-21.drawio, P12-class-PKG-27.drawio | XML parse được, bố cục đã căn chỉnh tự động theo kiểu sơ đồ lớp (PKG-28 giữ bố cục cũ vì kết quả tự động kém hơn, ba hộp mới đặt ở hàng dưới) |
| design/diagrams/P12-sequence-hold-seats.drawio, P12-sequence-handle-ipn.drawio, P12-sequence-expiry-sweep.drawio, P12-sequence-cancel-ticket.drawio, P12-sequence-check-ticket.drawio | Sửa nhãn và ghi chú, giữ toạ độ do bộ sinh đặt |

Chỉ sửa dòng Đầu vào đã dùng (không đổi nội dung): P11b-system-interfaces.md, P07-uc-analysis/UC-014-schedule-showtimes-analysis.md.

### Bước cần rà lại

- P04: bảng Thao tác nguyên tử (M1) cho UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 do hồ sơ bật TRANH_CHAP_TAI_NGUYEN (cảnh báo K14); P06 M2, P07 M3, P08 M4 theo 00-Concurrency.md nếu muốn đủ mô-đun.
- X2: chạy lại theo danh sách dưới; thêm mục F2 cho DC-HoldSettlement (End, Sell, FinishSale) và chuyển các TC kiểm Expire, ReleaseHold, Complete, MarkSold, NewTicket, NewBooking trong bốn operation sang lớp mới; F4.5 đối chiếu Bảng hỏng P09 F7.10.
- X1: rà F5, F6, F9 cho R-184 đến R-196, IF-26, IF-27 và PKG-28 vượt mức 15.
- P11b: SS-01 1.4 đổi một ô; P11b chính chỉ đồng bộ dòng Đầu vào đã dùng.
- P13: không đổi nội dung, không cần chạy lại.

### Cần chạy lại X2

Tổng 279 TC (215 do lượt này, 64 còn lại từ lần 1) trên 22 operation, cộng một lớp mới chưa có TC (DC-HoldSettlement). Cột TC ghi toàn bộ TC của operation; TC trực tiếp lệch kết quả mong đợi hoặc bản giả là các ca có nhánh Expire, ReleaseHold, Complete, MarkSold, NewTicket, NewBooking, AMOUNT_MISMATCH, NotFoundError, thứ tự lỗi và khoá vé.

| Operation | Lớp đã đổi | Thay đổi so với thiết kế X2 đã dùng | TC (số ca: mã) | EC |
|---|---|---|---|---|
| DC-BookTicketsService.HoldSeats | DC-BookTicketsService, DC-HoldSettlement (mới), DC-HoldSeatsRequest, DC-Showtime | BR-02 kiểm ở HoldSeats (ChannelMismatchError, holderCinemaId), thứ tự báo lỗi mới (Q-145), selectionFlaw ném sau BR-04, End(EXPIRY) thay Expire và ReleaseHold, MaxSeatsPerHold thay maxSeats | 40: TC-174 đến TC-206, TC-363 đến TC-369 | EC-90 đến EC-111 |
| DC-BookTicketsService.CancelHold | DC-BookTicketsService, DC-HoldSettlement | Expire, Cancel, ReleaseHold đi qua DC-HoldSettlement.End(CANCEL) | 9: TC-216 đến TC-224 | EC-112 đến EC-116 |
| DC-BookTicketsService.StartOnlinePayment | DC-BookTicketsService, DC-HoldSettlement | by khác người giữ ghế trả NotFoundError (Q-147); quá hạn đi qua End(EXPIRY, nil) | 7: TC-232 đến TC-238 | EC-122 đến EC-127 |
| DC-BookTicketsService.ConfirmCashReceived | DC-BookTicketsService, DC-HoldSettlement, DC-Booking, DC-Ticket | End(EXPIRY) rồi Sell và FinishSale thay Complete, NewTicket, NewBooking, MarkSold; clerk khác người giữ ghế trả NotFoundError (Q-147) | 7: TC-225 đến TC-231 | EC-117 đến EC-121 |
| DC-PaymentReportService.HandleIpn | DC-PaymentReportService, DC-HoldSettlement, DC-Booking, DC-Ticket | End(EXPIRY), Sell, FinishSale, End(PAYMENT_FAILURE) thay Expire, ReleaseHold, Complete, FailPayment, NewTicket, NewBooking, MarkSold; kiểm số tiền chỉ với báo thành công chưa xử lý (Q-146); LinkMismatchError của Sell thay phép kiểm IsHeldBy tại chỗ | 32: TC-239 đến TC-266, TC-370 đến TC-373 | EC-128 đến EC-136 |
| DC-SeatHold.CalculateTotal | DC-SeatHold | Q-143 đã trả lời: ghế HELD khác lần giữ ghế bị bỏ qua, danh sách rỗng trả 0; các TC chờ Q-143 chuyển thành ca chính thức | 5: TC-025 đến TC-029 | EC-13 đến EC-15 |
| DC-Showtime.CheckSeatSelection | DC-Showtime | Thứ tự lý do EMPTY, TOO_MANY, DUPLICATE, NOT_IN_AUDITORIUM (Q-152); hằng DC-Showtime.MaxSeatsPerHold | 8: TC-152 đến TC-159 | EC-74 đến EC-79 |
| DC-PriceList.DetermineSeatPrice | DC-PriceList | Múi giờ Asia/Ho_Chi_Minh khi xác định khung giờ và ngày trong tuần (Q-151) | 10: TC-164 đến TC-173 | EC-84 đến EC-89 |
| DC-HoldExpiryJob.RunDue (expireBatch, cleanupEvents) | DC-HoldExpiryJob, IF-26 | LockExpiredBatch thuộc IF-26 (bản giả đổi); cleanupEvents chạy ngữ cảnh riêng 2 giây (Q-148) | 12: TC-267 đến TC-277, TC-375 | EC-137 đến EC-141 |
| DC-SeatReleaseJob.RunDue (releaseBatch) | DC-SeatReleaseJob, IF-26 | LockReleasableBatch, LockByHolds thuộc IF-26; không còn dùng IF-17 (bản giả đổi) | 10: TC-278 đến TC-286, TC-374 | EC-142 đến EC-145 |
| DC-CancelTicketService.CancelOnlineTicket, ConfirmCashRefund (thân chung cancelInTx) | DC-CancelTicketService, DC-RefundService, IF-27, IF-19 | cancelInTx tách thành cancelOnlineInTx, cancelCashInTx, cancelAndReleaseSeat; lockPaymentOfTicket chuyển từ DC-RefundService; IF-27 thay IF-20 cho khoá vé; thêm IF-19 vào bản giả; ConfirmCashRefund kiểm cụm rạp (UC-008 2c) còn lệch từ lần 1 | 23: TC-287 đến TC-307, TC-377 đến TC-378 | EC-146 đến EC-152 |
| DC-CheckTicketService.CheckTicket | DC-CheckTicketService, IF-27 | LockTicketByCode, UpdateTicketStatus thuộc IF-27 (bản giả đổi) | 10: TC-308 đến TC-316, TC-376 | EC-153 đến EC-155 |
| DC-RefundService.CreateFullRefund, RequestTicketRefund | DC-RefundService | DC-RefundService không còn IF-20 và LockPaymentOfTicket (bản giả đổi) | 7: TC-317 đến TC-322, TC-379 | EC-156 đến EC-158 |
| DC-RefundService.ProcessRefund | DC-RefundService | Bỏ lượt trả nil kèm log cảnh báo (Q-150); ngưỡng 15 giây (Q-149) còn lệch từ lần 1 (EC-170, TC-340) | 25: TC-323 đến TC-345, TC-380 đến TC-381 | EC-159 đến EC-171 |
| IF-07.VerifyPassword, IssueSession, VerifySession | IF-07 | Phiên quản trị viên 8 giờ (Q-153); hết hạn khi now >= expiresAt, đồng hồ tiêm vào (Q-154) | 10: TC-353 đến TC-362 | EC-179 đến EC-185 |

Còn lại từ lần 1, chưa xử lý trong X2:

| Operation | Lớp đã đổi | Thay đổi | TC | EC |
|---|---|---|---|---|
| DC-SeatHold.Complete, Cancel, FailPayment | DC-SeatHold | Còn từ lần 1 (Q-142 đã trả lời): hàng F6.2 và F3 khớp nhau, TC at-expiry của F2.3 và replay hết hạn của F2.25 hết chờ | 12: TC-010 đến TC-021 | F2.3 |
| DC-PaymentTransaction.MarkTicketed, MarkLatePayment, RecordFailure, RecordDuplicate; CheckRefundWithin, RecordRefunded | DC-PaymentTransaction | Còn từ lần 1 (SY-01): dùng getter GatewayTransactionNo, LateReason, DuplicateReportCount, RefundedTotal | 24: TC-046 đến TC-069 | F2.8, F2.9 |
| DC-RefundRequest.NewFullRefund, NewTicketRefund, NewCashRefund, BeginAttempt, RecordResult, MarkManualRequired | DC-RefundRequest | Còn từ lần 1 (SY-02, SY-09): dùng getter RequestType, RefundResult; nhánh BeginAttempt không tới được | 28: TC-070 đến TC-097 | F2.10 đến F2.13 |

### Mã cấp mới

R-184 đến R-196 (13 quan hệ; R-83, R-96, R-109, R-165, R-167 đã bỏ, tổng 149); DC-HoldSettlement, DC-HoldEndReason, DC-HoldEndOutcome, IF-26, IF-27. Không cấp SY mới (SY cuối vẫn SY-36), không cấp Q hay ASM mới (Q cuối vẫn Q-154). Không có file pending nên không có khoảng trống do gộp lô.


## Lần 3 - Lô P04 song song (UC-001, 003, 004, 007, 010, 011, 012, 015, 016, 017; bảng Thao tác nguyên tử UC-005, 006, 008, 009, 013, 014)

### Cần người quyết

Không có. Chủ dự án đã chốt tất cả Q mới của lô theo đúng phương án đề xuất trong đặc tả: Q-155 đến Q-166 (12), Q-175 đến Q-187 (13), Q-195 đến Q-214 (20), tổng 45 Q, đều đánh dấu "Đã trả lời" ở nơi cấp Q và đã áp vào luồng, dữ liệu, BR của đặc tả. Không tạo Q mới (Q cuối vẫn Q-214, SY mới từ SY-37).

### Gộp sổ BR (A1)

- Gộp 8 file pending (UC-001, UC-004, UC-007, UC-010, UC-011, UC-012, UC-015, UC-017; không có pending của UC-003, UC-016) vào _BR-register.md rồi xoá. Sổ từ 93 lên 121 BR.
- 28 BR mới: BR-94 đến BR-102 (UC-007, UC-017, UC-001), BR-114 đến BR-119 (UC-015, UC-016), BR-134 đến BR-142 (UC-010, UC-011, UC-012), BR-144 đến BR-147 (UC-012). Giữ mã đã cấp, không mã nào bị đổi nghĩa.
- Hai dòng cùng nghĩa do hai phiên cấp: quy tắc "suất chiếu đã kết thúc hoặc đã xoá giữ sức chứa, sơ đồ ghế lúc mở bán" nảy ra ở Q-186 (UC-015, BR-118) và Q-210 (UC-012, dự kiến BR-143). Giữ mã nhỏ hơn BR-118, mở rộng nội dung gồm sơ đồ ghế, loại ghế và sức chứa, UC áp dụng UC-015, UC-016, UC-012; BR-143 không cấp, UC-012 dẫn BR-118.
- Dòng bổ sung: BR-84 từ hai pending (UC-010, UC-012) hợp thành một dòng UC-014, UC-010, UC-012; BR-45, BR-58, BR-76, BR-06, BR-69, BR-73, BR-74, BR-87 cập nhật cột UC áp dụng và Ghi chú; BR-81, BR-82, BR-88 bỏ cụm "chưa đặc tả P04".
- BR-114 (UC-015, báo cáo của cụm rạp mình) và BR-135 (UC-012, phòng chiếu của cụm rạp mình) cùng kiểu với BR-46, BR-61 nhưng khác chức năng, giữ riêng.
- Dải mã không dùng: Q-167 đến Q-174, Q-188 đến Q-194; BR-103 đến BR-113, BR-120 đến BR-133, BR-143, BR-148 đến BR-153.

### Bảng đồng bộ

| SY | Nguồn (file, mục) | Đích (bước, mã phần tử) | Loại | Nội dung | Kết quả hoặc lý do |
|---|---|---|---|---|---|
| SY-37 | 8 file _BR-register.*.pending.md | P04 _BR-register.md | Áp dụng | Gộp dòng mới và dòng bổ sung | Đã gộp, xoá pending; P06 Mục 6 thêm 28 BR |
| SY-38 | UC-001, Đề xuất | P05 GL-18; P06 BR-81, BR-82 | Áp dụng | Bỏ cụm "chưa đặc tả P04" | Đã áp; P05 1.2, P06 1.4 |
| SY-39 | UC-003, Đề xuất | P05 GL-37, GL-38, GL-39; P06 dòng UC-003 | Áp dụng | Cập nhật ghi chú; dòng UC-003 đã khớp BR-76 | Đã áp |
| SY-40 | UC-004, Đề xuất | P06 dòng UC-004; sổ BR-58; P05 GL-47 | Áp dụng | Thêm BR-58, BR-45, BR-76 cho UC-004 | Đã áp |
| SY-41 | UC-007, Đề xuất | P06 dòng UC-007; P05 GL-18 | Áp dụng | Thêm BR-94, BR-140 | Đã áp |
| SY-42 | UC-015, UC-016, Đề xuất | P02 bảng 4b, Mục 5 | Áp dụng | Thêm REQ-153 cho UC-015, UC-016; thêm dòng REQ-153 | Đã áp; P02 1.9 |
| SY-43 | UC-015, UC-016, Đề xuất | P06 dòng UC-015, UC-016; P05 GL-04, GL-55 | Áp dụng | Thêm BR-114 đến BR-119; ghi chú GL; thêm GL-66 Kỳ báo cáo theo Q-181 | Đã áp |
| SY-44 | UC-017, Đề xuất | P05 GL-34, GL-43; P06 dòng UC-017 | Áp dụng | Bỏ cụm "chưa đặc tả"; thêm BR-95 đến BR-97, BR-100 đến BR-102 | Đã áp |
| SY-45 | UC-012, Đề xuất | P02 bảng 4b, Mục 5 | Áp dụng | Thêm REQ-162 và REQ-03 vào UC-012, thêm dòng REQ-162; REQ-01 không thêm vì Q-212 chốt không là giới hạn cứng | Đã áp |
| SY-46 | UC-012, Đề xuất | P04 UC-014 bước 8, Mục 8 | Áp dụng | Dẫn BR-136; UC-012 bước 5 và luồng 1b3 vào cột Loại trừ với; thêm luồng 8h (phòng đã xoá) theo Q-208 | Đã áp; UC-014 1.6 |
| SY-47 | UC-012, Đề xuất | P04 UC-013 luồng 1a3, Mục 8 | Áp dụng | Dẫn BR-136, đối thủ UC-012 bước 5 | Đã áp; UC-013 1.4 |
| SY-48 | UC-012, Đề xuất | P04 UC-005 bước 7, Mục 8 | Áp dụng | Dẫn BR-137, đối thủ UC-012 bước 5 | Đã áp; UC-005 1.14 |
| SY-49 | UC-010, Đề xuất | P04 UC-014 bước 8 | Áp dụng | Đối thủ UC-010 bước 5; Q-202: kiểm lại BR-47, BR-49, tính BR-50 theo phim hiện hành, luồng 8g, BR-139 | Đã áp; UC-014 1.6 |
| SY-50 | UC-013, Đề xuất | P04 UC-012 | Áp dụng | UC-012 dẫn BR-73, BR-87 và cặp loại trừ giống BR-68 | UC-012 đã đặc tả, xoá dòng đề xuất |
| SY-51 | UC-005, Đề xuất (phiên 4) | P04 UC-005 luồng 9a1a, BR-44 | Áp dụng | Xác nhận đã thu tiền tới khi lần giữ ghế đã ở trạng thái cuối khác thì bị từ chối, nhân viên quầy trả lại tiền mặt; sửa decision D-9a1 và drawio | Đã áp theo chỉ đạo của chủ dự án |
| SY-52 | UC-010, Đề xuất | P08 EX-13, mục 6 sau F4b | Chờ | Thêm Movie (S) vào bộ khoá EX-13 và đơn vị loại trừ lưu phim | Vào mục Đầu vào cho lần chạy lại P07-P13 |
| SY-53 | UC-010, UC-011, UC-012, UC-017, Đề xuất | P08, P13 | Chờ | Cột trailer, tỉnh thành phố, tên duy nhất, ghế lịch sử, email nhân viên duy nhất, thực thể quản lý chuỗi, AC-E-Cinema, EX-15 | Vào mục Đầu vào cho lần chạy lại P07-P13 |

Đề bài yeu-cau-dat-ve.md: không đổi. Không câu trả lời nào mâu thuẫn hoặc đổi quy tắc đã có của đề bài; các quy tắc mới (Q-211 sức chứa 50 đến 400 thành điều kiện hợp lệ, Q-212 số phòng không là giới hạn cứng, Q-208 xoá phòng chưa từng có suất chiếu) làm rõ chỗ đề bài để trống.

### File đã sửa và phiên bản mới

- P02-usecases.md 1.9; P03-usecase-model.md 1.2 (chỉ đồng bộ đầu vào, không đổi sơ đồ use case); P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; _BR-register.md.
- UC-001 1.1, UC-003 1.1, UC-004 1.1, UC-007 1.1, UC-010 1.1, UC-011 1.1, UC-012 1.1, UC-015 1.1, UC-016 1.1, UC-017 1.1, UC-005 1.14, UC-013 1.4, UC-014 1.6.
- Sơ đồ activity đã đổi: UC-001, UC-005, UC-010, UC-011, UC-012, UC-014, UC-015, UC-016, UC-017 (ghi chú cho luồng mới, UC-001 thêm node và cạnh; diakempt đã chạy, XML parse được).

### Bước cần rà lại

P07 (UC-001, 004, 005, 007, 010 đến 017), P08, P09, P10, P11a, P11b, P12, P13, X1, X2 theo mục dưới. P07 của UC-003, UC-004, UC-015, UC-016 cần chạy mới vì BR-115 đến BR-119 và Q-175 đến Q-187.

### Đầu vào cho lần chạy lại P07-P13

| Bước | Phần tử | Nội dung | Nguồn |
|---|---|---|---|
| P07 | UC-005 luồng 9a1a | Nhánh xác nhận đã thu tiền khi lần giữ ghế đã Đã huỷ, Thanh toán thất bại hoặc Đã hoàn tất: từ chối, báo trả tiền mặt | UC-005 1.14, BR-44, BR-86 |
| P07 | UC-005 bước 7 | Chốt giá xen với UC-012 đổi loại phòng, đối thủ mới | UC-012, BR-137 |
| P07 | UC-014 bước 8 | Kiểm lại BR-47, BR-49, tính lại BR-50 theo phim hiện hành; luồng 8g (phim sửa), 8h (phòng đã xoá) | UC-010 Q-202; UC-012 Q-208; BR-136, BR-139, BR-147 |
| P07 | UC-013 luồng 1a3 | Đối thủ UC-012 bước 5 | UC-012, BR-136 |
| P07 | UC-010, UC-011, UC-012, UC-017 | Chạy mới: lưu đồng thời (từ chối bên ghi nhận sau), điều kiện hợp lệ, tên duy nhất, UC-012 xoá phòng, UC-017 mở khoá, sửa họ tên, đặt lại mật khẩu | Q-195 đến Q-214, Q-161 đến Q-166; BR-100 đến BR-102, BR-138 đến BR-147 |
| P07 | UC-001, UC-007 | Bước kiểm mật khẩu, kiểm trùng email và số điện thoại thành thao tác không chia cắt; lịch sử gồm mọi vé kèm trạng thái | UC-001 Q-155 đến Q-158; UC-007 Q-159, Q-160; BR-98, BR-99 |
| P07 | UC-015, UC-016 | Kỳ báo cáo là khoảng ngày; doanh thu xếp theo ngày chiếu; bỏ suất chiếu đã xoá khỏi sức chứa; sức chứa lúc suất chiếu diễn ra | Q-181 đến Q-187; BR-115 đến BR-119 |
| P08 | EX-13 | Thêm Movie (S) vào bộ khoá; đơn vị loại trừ mới cho lưu phim, cùng cặp X với EX-13 | UC-010 Q-202; BR-138, BR-139 |
| P08 | EX-15, X-19, X-21 | Xác nhận lại theo BR-136, BR-137, BR-118, suất chiếu đã xoá không chặn BR-87, BR-73; lớp chủ của EX-15 | UC-012 Q-209, Q-210 |
| P08 | Thực thể quản lý chuỗi | Thêm thực thể cho quản lý chuỗi (ACT-05, không thuộc cụm rạp); chốt cách đổi vai trò giữa các thực thể ở luồng 1a | UC-017, BR-78 |
| P08 | AC-E-Cinema | Thêm thuộc tính tỉnh, thành phố (bắt buộc, văn bản) | UC-011 Q-204 |
| P08 | AC-E-Movie | Thêm thuộc tính trailer (văn bản, không bắt buộc), nhãn độ tuổi P, K, T13, T16, T18, C | UC-010 Q-198, Q-199 |
| P08 | Showtime, Auditorium | Sức chứa, sơ đồ ghế lúc suất chiếu mở bán giữ cho suất chiếu đã kết thúc hoặc đã xoá; xoá phòng chỉ khi chưa từng có suất chiếu | UC-012 Q-208, Q-210; UC-015 Q-186; BR-118, BR-147 |
| P09 | Phiên đăng nhập, khoá tài khoản | Khoá, đổi cụm rạp, đổi vai trò có hiệu lực ngay với phiên đang mở; lần giữ ghế đang chạy giữ nguyên | UC-017 Q-164, Q-165; BR-100, BR-101 |
| P09 | Đồng thời | Bốn thao tác lưu mới (phim, cụm rạp, phòng chiếu, tài khoản nhân viên) từ chối bên ghi nhận sau, không ghi đè | BR-102, BR-138, BR-142, BR-146 |
| P10, P12 | DC-BookTicketsService.ConfirmCashReceived | Xác nhận đã thu tiền khi lần giữ ghế đã ở trạng thái cuối: trả lỗi để báo nhân viên quầy trả lại tiền mặt | UC-005 luồng 9a1a, BR-44 |
| P10, P12 | Dịch vụ lập suất chiếu | Kiểm lại phim hiện hành và phòng còn tồn tại trong cùng thao tác lưu | UC-014 8g, 8h |
| P10, P12 | Dịch vụ phim, cụm rạp, phòng chiếu, tài khoản nhân viên | Lưu có kiểm phiên bản, tên cụm rạp, tên phòng duy nhất, sức chứa 50 đến 400, xoá phòng, mở khoá, sửa họ tên, đặt lại mật khẩu, đăng ký (mật khẩu từ 8 ký tự, email và số điện thoại duy nhất) | UC-001, UC-010 đến UC-012, UC-017; BR-98, BR-99, BR-141, BR-144 đến BR-147 |
| P11a | UC-003, UC-004 | Danh sách phim hiển thị tên, thể loại, thời lượng, độ tuổi, ngày khởi chiếu (phim sắp chiếu); lịch chiếu thêm loại phòng, tỉnh thành phố, thời điểm mở bán, lọc theo một ngày | Q-175 đến Q-180 |
| P11a | UC-015, UC-016, UC-007, UC-001, UC-017, UC-012 | Kỳ báo cáo từ ngày đến ngày; lịch sử đặt vé kèm trạng thái và các cột của lần đặt; màn đăng ký; màn mở khoá, sửa họ tên, đặt lại mật khẩu; xoá phòng | Q-155, Q-159 đến Q-162, Q-181, Q-208 |
| P13 | movie | Thêm cột trailer; kiểm thời lượng lớn hơn 0, ngày kết thúc không trước ngày khởi chiếu, nhãn độ tuổi | UC-010 Q-196 đến Q-199 |
| P13 | cinema | Thêm cột tỉnh, thành phố (bắt buộc); tên cụm rạp duy nhất | UC-011 Q-204, Q-206; BR-141 |
| P13 | auditorium, seat, seat_status | Ràng buộc duy nhất (cinema_id, name); giữ ghế lịch sử (xoá mềm ghế) cho suất chiếu đã kết thúc hoặc đã xoá; xoá phòng chưa từng có suất chiếu | UC-012 Q-208, Q-210, Q-213; BR-118, BR-145, BR-147 |
| P13 | showtime | Lưu sức chứa lúc mở bán để báo cáo kỳ cũ không đổi | UC-015 Q-186; BR-118 |
| P13 | TBL-08, TBL-11, TBL-12 (email nhân viên) | Email duy nhất xuyên ba bảng nhân viên hoặc bảng định danh đăng nhập chung; cột trạng thái hoạt động | UC-017 Q-136, Q-163; BR-95 đến BR-97 |
| P13 | bảng quản lý chuỗi | Thêm bảng cho vai trò quản lý chuỗi | UC-017, BR-78 |
| P13 | cột phiên bản | Cột phiên bản hoặc cách tương đương cho phim, cụm rạp, phòng chiếu, tài khoản nhân viên | BR-102, BR-138, BR-142, BR-146 |
| X1, X2 | Thao tác bị ảnh hưởng | Chạy lại sau P12: ConfirmCashReceived, dịch vụ lập suất chiếu, thao tác lưu mới | các dòng trên |

### Lỗi hình thức (check_artifacts.py)

Trước: 0 LOI, 156 CANH_BAO. Sau: 0 LOI; CANH_BAO K09 còn lại thuộc P07 trở đi (chờ chạy lại), K18 và K11 cũ của P04 chưa đổi.

### Mã cấp mới

BR-94 đến BR-102, BR-114 đến BR-119, BR-134 đến BR-142, BR-144 đến BR-147 (28 BR); GL-66. Không cấp Q hay ASM mới (Q cuối Q-214). SY cuối SY-53. Khoảng trống: xem mục Gộp sổ BR.
