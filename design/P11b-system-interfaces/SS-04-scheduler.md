# P11b - SS-04 Scheduler - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 1.2 |
| Thay đổi 1.2 | runDue: dòng hoàn tiền xử lý tối đa 80 giây, hàng rào claim_token, xử lý bản bị tạm dừng (RF-01); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3); P01-actors.md 1.2; P04-uc-specs UC-005 1.11 (luồng 7b, 11a, *a), UC-006 1.7, UC-008 1.7; P06-supplementary-spec.md 1.3 (NFR-07); P07-uc-analysis UC-005 1.1 (startWaitingForHoldExpiry, stopWaitingForHoldExpiry), UC-006 1.1, UC-008 1.2; P09-architecture.md 1.5 (F4, F6, F7.4, F7.7); P10-design-elements.md 1.4 (F2, F4, F5, interface gọi ngược IF-06); TAI_LIEU_GIAO_TIEP: Không có |
| Phạm vi | SS-04 Scheduler (IF-05, IF-06) |
| Mã Q, ASM cuối đã cấp | Ghi ở file chung (Q-126 đến Q-132) |

SS-04 không có lớp phân tích nguồn tương ứng một-một; trách nhiệm lấy từ P10 F2 và từ message P07 startWaitingForHoldExpiry, stopWaitingForHoldExpiry của AC-C-BookTicketsController (P10 F1, A1).

## F1. Bối cảnh sử dụng

| UC | Control gọi (AC hoặc DC) | Message trong P07 (STT, tên) | Dữ liệu truyền | Luồng lỗi trong P04 |
|---|---|---|---|---|
| UC-005 Đặt vé | DC-HoldExpiryJob, DC-SeatReleaseJob (PKG-13) hiện thực IF-06; SS-04 gọi | 2.1.5 // startWaitingForHoldExpiry (bước 7); 2.1.7(*a).1.1 // stopWaitingForHoldExpiry; 2.1.5(7b) // after(BR-10) handleHoldExpired | Ngân sách thời gian của lượt; kết quả: số mục đã xử lý, còn việc hay không | Luồng 7b (hết hạn), 11a và *a (giải phóng ghế); NFR-07 |
| UC-006 Hoàn tiền thanh toán đến muộn | DC-RefundOutboxJob (PKG-14) hiện thực IF-06 | 1.1.5 // requestRefund và thử lại (bước 4 đến 7) | như trên | Luồng 4a, 4b, 5a, 5b |
| UC-008 Huỷ vé | DC-RefundOutboxJob (PKG-14) hiện thực IF-06 | 1.1.9 // requestRefund (bước 5, 6) | như trên | Luồng 5b, 5c, 6a, 6b |
| UC-005, UC-006 | DC-EmailOutboxJob (PKG-20) hiện thực IF-06 | 4.1.3 // sendTicketsEmail (bước 14); 1.1.11 // sendRefundNotificationEmail (bước 7) | như trên | Ghi chú bước 14 (UC-005), bước 7 (UC-006); BR-89 |

Hàm khởi động chương trình (ngoài mô hình package, P10 F2) gọi registerJob, start, stop; hàm này không là DC và không là use case.

## F2. Interface

| IF | Tên | Vai trò (một câu) | Bên hiện thực (SS; DC khi là interface gọi ngược) | Client (DC, PKG) | Package chứa |
|---|---|---|---|---|---|
| IF-05 | IJobScheduler | Đăng ký công việc định kỳ, bắt đầu và dừng chạy | SS-04 | Hàm khởi động chương trình (ngoài mô hình package) | PKG-25 |
| IF-06 | IScheduledJob | Một công việc nền chạy một lượt các mục đã đến hạn trong ngân sách thời gian (interface gọi ngược do SS-04 gọi) | DC-HoldExpiryJob, DC-SeatReleaseJob (PKG-13); DC-RefundOutboxJob (PKG-14); DC-EmailOutboxJob (PKG-20) | SS-04 (DC-JobLoop) | PKG-25 |

IF-05 có 3 operation, IF-06 có 1 operation. IF-06 do SS-04 định nghĩa ở layer Services và Application hiện thực, nên realization đi xuống, không đi lên (P09 F6, P10 F2).

## F3. Operation

| IF | Tên | Hệ thống/thiết bị | Operation | Tham số vào | Kết quả | Lỗi / ngoại lệ | UC | Tiền điều kiện | Hậu điều kiện | Đồng bộ | Idempotent | Timeout |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| IF-05 | IJobScheduler | Không có (nội bộ máy chủ) | registerJob(name: String, job: IScheduledJob, interval: Duration): void | name: String - tên công việc, duy nhất, dùng cho log<br>job: IScheduledJob - lớp hiện thực IF-06<br>interval: Duration - chu kỳ, lớn hơn 0; 10 giây cho cả bốn công việc (P09 F7.4) | - | SchedulerStateError (Kỹ thuật, lỗi lập trình: đăng ký sau start, tên trùng, chu kỳ không dương) | UC-005, UC-006, UC-008 (hạ tầng của luồng 7b, 11a và các bước hoàn tiền, gửi email) | Chưa start | Công việc nằm trong danh sách đăng ký | Đồng bộ | Không (đăng ký trùng tên báo lỗi) | Không áp dụng |
| IF-05 | IJobScheduler | Không có (nội bộ máy chủ) | start(): void | - | - | SchedulerStateError (Kỹ thuật: đã start) | UC-005, UC-006, UC-008 | Mọi công việc đã đăng ký | Mỗi công việc chạy định kỳ ở nền trên bản backend này; trả ngay | Đồng bộ (vòng chạy nền bất đồng bộ) | Không (gọi lần hai báo lỗi) | Không áp dụng |
| IF-05 | IJobScheduler | Không có (nội bộ máy chủ) | stop(grace: Duration): void | grace: Duration - thời gian chờ lượt đang chạy, lớn hơn 0; 10 giây (Thiết kế: ngân sách 8 giây của một lượt cộng 2 giây) | - | Không | UC-005, UC-006, UC-008 | Không | Không bắt đầu lượt mới; lượt đang chạy xong hoặc bị bỏ dở an toàn vì chạy lặp được | Đồng bộ | Có | grace (10 giây, Thiết kế như trên) |
| IF-06 | IScheduledJob | Không có (do Application hiện thực, SS-04 gọi ngược) | runDue(budget: Duration): JobRunResult | budget: Duration - ngân sách thời gian của lượt, 8 giây (P09 F7.4); chỉ chặn việc nhận mục mới, mục đã nhận được chạy xong | JobRunResult: processedCount (Integer), hasMore (Boolean: còn mục đến hạn khi hết ngân sách) | Lỗi của công việc (Kỹ thuật): SS-04 bắt, ghi log, không để lọt ra ngoài | UC-005 (luồng 7b, 11a); UC-006 (bước 4 đến 7); UC-008 (bước 5, 6) | Nhiều bản backend gọi song song được | Các mục đến hạn trong ngân sách đã xử lý theo lô; chia việc giữa các bản bằng SKIP LOCKED hoặc claim (P09 F7.4, F7.7) | Đồng bộ (SS-04 chờ tới hết lượt) | Có (chạy lặp an toàn: EX-04, EX-05, claim_token) | 8 giây (P09 F7.4); lượt quá 8 giây cộng 2 giây được coi là treo: ghi log, không mở lượt mới của công việc đó tới khi lượt cũ kết thúc (Thiết kế) |

Phủ trách nhiệm: registerJob, start, stop của P10 F2; startWaitingForHoldExpiry và stopWaitingForHoldExpiry của P07 không còn là lời gọi vì hết hạn tính theo expiry_time và công việc nền chỉ quyết định khi nào ghế trống (P09 F7.4).

## F4. Sequence diagram

File diagrams/P11b-subsystem-SS-04.drawio, 5 trang: S04B1 (hộp đen), S04W1 (hộp trắng start và vòng chạy), S04W2 (hộp trắng stop), Phần tử, Phụ thuộc. Operation registerJob được hiện thực một-một bởi DC-JobSchedulerManager (ghi vào DC-JobRegistry sau khi kiểm trạng thái) nên không có sơ đồ hộp trắng riêng. runDue là operation do Application hiện thực, thân của nó thuộc P12; phía SS-04 thể hiện ở S04W1.

### Trang "Hộp đen - đăng ký và chạy công việc nền (UC-005 luồng 7b, 11a; UC-006 bước 4 đến 7; UC-008 bước 5, 6)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S04B1-L1 | Lifeline | :ApplicationBootstrap | - | Hàm khởi động chương trình (ngoài mô hình package) | Nối IF-05 với bốn lớp hiện thực IF-06 |
| S04B1-L2 | Lifeline | :IF-05 IJobScheduler | «interface» | SS-04 | Interface đăng ký và điều khiển |
| S04B1-L3 | Lifeline | :Scheduler | «subsystem» | SS-04 | Subsystem gọi ngược IF-06 |
| S04B1-L4 | Lifeline | :IF-06 IScheduledJob | «interface» | PKG-25 | Hiện thực bởi DC-HoldExpiryJob, DC-SeatReleaseJob (PKG-13), DC-RefundOutboxJob (PKG-14), DC-EmailOutboxJob (PKG-20) |
| S04B1-F1 | Fragment | loop [với từng công việc trong bốn công việc nền] | - | - | Một operand |
| S04B1-F2 | Fragment | loop [mỗi chu kỳ, đến khi stop] | - | - | Một operand |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :ApplicationBootstrap | :IF-05 IJobScheduler | registerJob(name, job, interval) | Đồng bộ | S04B1-F1 [với từng công việc trong bốn công việc nền] | Chu kỳ 10 giây (P09 F7.4) |
| 2 | :IF-05 IJobScheduler | :ApplicationBootstrap | void | Trả về | S04B1-F1 [với từng công việc trong bốn công việc nền] | - |
| 3 | :ApplicationBootstrap | :IF-05 IJobScheduler | start() | Đồng bộ | - | Mọi bản backend đều chạy |
| 4 | :IF-05 IJobScheduler | :ApplicationBootstrap | void | Trả về | - | - |
| 5 | :Scheduler | :IF-06 IScheduledJob | runDue(budget) | Đồng bộ | S04B1-F2 [mỗi chu kỳ, đến khi stop] | UC-005 luồng 7b, 11a (hết hạn, giải phóng ghế); UC-006 bước 4 đến 7 và UC-008 bước 5, 6 (hoàn tiền); email UC-005 bước 14, UC-006 bước 7 |
| 6 | :IF-06 IScheduledJob | :Scheduler | JobRunResult | Trả về | S04B1-F2 [mỗi chu kỳ, đến khi stop] | - |
| 7 | :ApplicationBootstrap | :IF-05 IJobScheduler | stop(grace) | Đồng bộ | - | Tắt chương trình |
| 8 | :IF-05 IJobScheduler | :ApplicationBootstrap | void | Trả về | - | - |

### Trang "Hộp trắng - start và vòng chạy một công việc"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S04W1 | Fragment | sd start | - | - | Khung sd; mọi lifeline nằm trong khung |
| S04W1-L1 | Lifeline | :JobSchedulerManager | - | DC-JobSchedulerManager | Điều phối, hiện thực IF-05 |
| S04W1-L2 | Lifeline | :JobRegistry | - | DC-JobRegistry | Lưu trữ trong subsystem |
| S04W1-L3 | Lifeline | :JobLoop | - | DC-JobLoop | Một vòng cho mỗi công việc |
| S04W1-L4 | Lifeline | :IF-06 IScheduledJob | «interface» | PKG-25 | Lớp hiện thực ở Application |
| S04W1-G1 | Gate | start | - | S04W1 | Gate của message 1 |
| S04W1-G2 | Gate | trả về SchedulerStateError | - | S04W1 | Gate của message 2 |
| S04W1-G6 | Gate | trả về void | - | S04W1 | Gate của message 6 |
| S04W1-F1 | Fragment | alt [đã start] | - | S04W1 | Operand tiếp: [chưa start] |
| S04W1-F2 | Fragment | loop [với từng công việc] | - | S04W1 | Một operand |
| S04W1-F3 | Fragment | loop [mỗi interval, đến khi stop] | - | S04W1 | Một operand |
| S04W1-F4 | Fragment | alt [lượt trước chưa xong] | - | S04W1 | Operand tiếp: [rảnh] |
| S04W1-F5 | Fragment | alt [trả JobRunResult] | - | S04W1 | Operand tiếp: [lỗi hoặc panic] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :JobSchedulerManager | start() | Đồng bộ | - | IF-05 |
| 2 | :JobSchedulerManager | Gate | SchedulerStateError | Trả về | S04W1-F1 [đã start] | Lỗi lập trình hàm khởi động |
| 3 | :JobSchedulerManager | :JobRegistry | registeredJobs() | Đồng bộ | S04W1-F1 [chưa start] | - |
| 4 | :JobRegistry | :JobSchedulerManager | jobs | Trả về | S04W1-F1 [chưa start] | - |
| 5 | :JobSchedulerManager | :JobLoop | run(name, job, interval) | Bất đồng bộ | S04W1-F2 [với từng công việc] | Mở vòng nền, không chặn |
| 6 | :JobSchedulerManager | Gate | void | Trả về | S04W1-F1 [chưa start] | - |
| 7 | :JobLoop | :JobLoop | tryAcquireRunning() | Tự gọi | S04W1-F3 [mỗi interval, đến khi stop] | Cờ đang chạy của công việc trong bản backend này |
| 8 | :JobLoop | :JobLoop | skipCycle() | Tự gọi | S04W1-F4 [lượt trước chưa xong] | Bỏ qua chu kỳ, không chạy chồng (P09 F7.4) |
| 9 | :JobLoop | :IF-06 IScheduledJob | runDue(budget = 8 giây) | Đồng bộ | S04W1-F4 [rảnh] | IF-06 |
| 10 | :IF-06 IScheduledJob | :JobLoop | JobRunResult | Trả về | S04W1-F5 [trả JobRunResult] | Hết việc hoặc hết ngân sách |
| 11 | :IF-06 IScheduledJob | :JobLoop | error | Trả về | S04W1-F5 [lỗi hoặc panic] | - |
| 12 | :JobLoop | :JobLoop | recoverAndLog() | Tự gọi | S04W1-F5 [lỗi hoặc panic] | Lỗi không lọt ra ngoài; chu kỳ sau chạy tiếp |
| 13 | :JobLoop | :JobLoop | releaseRunning() | Tự gọi | S04W1-F4 [rảnh] | - |

### Trang "Hộp trắng - stop"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S04W2 | Fragment | sd stop | - | - | Khung sd; mọi lifeline nằm trong khung |
| S04W2-L1 | Lifeline | :JobSchedulerManager | - | DC-JobSchedulerManager | Điều phối, hiện thực IF-05 |
| S04W2-L2 | Lifeline | :JobRegistry | - | DC-JobRegistry | Lưu trữ trong subsystem |
| S04W2-L3 | Lifeline | :JobLoop | - | DC-JobLoop | Một vòng cho mỗi công việc |
| S04W2-G1 | Gate | stop | - | S04W2 | Gate của message 1 |
| S04W2-G9 | Gate | trả về void | - | S04W2 | Gate của message 9 |
| S04W2-F1 | Fragment | alt [xong trong grace] | - | S04W2 | Operand tiếp: [quá grace] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :JobSchedulerManager | stop(grace) | Đồng bộ | - | IF-05 |
| 2 | :JobSchedulerManager | :JobRegistry | runningLoops() | Đồng bộ | - | - |
| 3 | :JobRegistry | :JobSchedulerManager | loops | Trả về | - | - |
| 4 | :JobSchedulerManager | :JobLoop | requestStop() | Bất đồng bộ | - | Không bắt đầu lượt mới |
| 5 | :JobSchedulerManager | :JobLoop | awaitIdle(grace) | Đồng bộ | - | Chờ lượt đang chạy xong |
| 6 | :JobLoop | :JobSchedulerManager | idle | Trả về | S04W2-F1 [xong trong grace] | - |
| 7 | :JobLoop | :JobSchedulerManager | timeout | Trả về | S04W2-F1 [quá grace] | - |
| 8 | :JobSchedulerManager | :JobSchedulerManager | logAbandonedJobs() | Tự gọi | S04W2-F1 [quá grace] | Lượt bị bỏ dở an toàn vì chạy lặp được (EX-04, EX-05, claim) |
| 9 | :JobSchedulerManager | Gate | void | Trả về | - | - |

## F5. Phần tử của subsystem

a) Bảng phần tử

| DC | Tên | Vai trò (Điều phối / Giao tiếp ngoài / Chuyển đổi dữ liệu / Lưu trữ trong subsystem / Kiểu dữ liệu / Ngoại lệ) | Trách nhiệm | Visibility | Hiện thực IF |
|---|---|---|---|---|---|
| DC-JobSchedulerManager | JobSchedulerManager | Điều phối | Nhận registerJob, start, stop; kiểm trạng thái; mở và dừng các vòng chạy | package-private | IF-05 |
| DC-JobRegistry | JobRegistry | Lưu trữ trong subsystem | Giữ danh sách công việc đã đăng ký (tên duy nhất) và các vòng đang chạy | package-private | - |
| DC-JobLoop | JobLoop | Điều phối | Với một công việc: đếm chu kỳ theo đồng hồ đơn điệu, giữ cờ đang chạy, gọi runDue với ngân sách 8 giây, bắt panic và lỗi rồi ghi log, không để lỗi lọt ra ngoài | package-private | - |
| DC-JobRunResult | JobRunResult | Kiểu dữ liệu | processedCount (Integer), hasMore (Boolean: còn việc đến hạn khi hết ngân sách); dùng trong chữ ký if-06 | public | - |
| DC-SchedulerStateError | SchedulerStateError | Ngoại lệ | Đăng ký sau start, start hai lần, tên công việc trùng hoặc chu kỳ không dương; dùng trong chữ ký if-05 | public | - |

Đồng hồ chu kỳ dùng đồng hồ đơn điệu của hệ điều hành, không dùng để quyết định nghiệp vụ (thời điểm hết hạn lấy từ cơ sở dữ liệu, P09 F7.2). Ghi nhật ký (Thiết kế: mỗi lỗi, mỗi lượt bị bỏ qua và mỗi lượt quá ngân sách ghi một dòng log kèm tên công việc). Cấu hình: chu kỳ và ngân sách nạp từ hàm khởi động khi gọi registerJob.

b) Class diagram phần tử (trang "Phần tử")

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| IF-05 | Interface | IJobScheduler | «interface» | - | PKG-25 |
| IF-06 | Interface | IScheduledJob | «interface» | - | PKG-25 định nghĩa; Application hiện thực |
| SS-04 | Subsystem | Scheduler | - | - | Chỉ interface là public |
| DC-JobSchedulerManager | Class | JobSchedulerManager | - | SS-04 | Hiện thực IF-05 |
| DC-JobRegistry | Class | JobRegistry | - | SS-04 | Lưu trữ trong subsystem |
| DC-JobLoop | Class | JobLoop | - | SS-04 | Điều phối nền |
| DC-JobRunResult | Class | JobRunResult | «value» | SS-04 | Kiểu dữ liệu (public) |
| DC-SchedulerStateError | Class | SchedulerStateError | «exception» | SS-04 | Ngoại lệ (public) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| C04-01 | DC-JobSchedulerManager | IF-05 | Realization | - | - |
| C04-02 | DC-JobSchedulerManager | DC-JobRegistry | Dependency | - | lưu công việc |
| C04-03 | DC-JobSchedulerManager | DC-JobLoop | Dependency | - | mở vòng |
| C04-04 | DC-JobRegistry | DC-JobLoop | Composition | 1 ở đầu nguồn; 0..* ở đầu đích | - |
| C04-05 | DC-JobLoop | IF-06 | Dependency | - | gọi runDue |

## F6. Phụ thuộc subsystem

| Subsystem | Phụ thuộc vào (IF, SS, PKG) | Loại (Qua interface / Vào package) | Lý do | Đánh giá (Ưu tiên / Dùng thận trọng) |
|---|---|---|---|---|
| SS-04 Scheduler | IF-06 (do chính SS-04 định nghĩa, PKG-13, PKG-14, PKG-20 hiện thực) | Qua interface | Gọi ngược công việc ở Application mà không phụ thuộc package Application; realization đi xuống (P09 F6) | Ưu tiên |

SS-04 không dùng pool kết nối và không phụ thuộc package nào (pool nền thuộc DC-ConnectionPools ở PKG-21, P10 F2). Client của IF-05 là hàm khởi động chương trình, ngoài mô hình package.

Trang "Phụ thuộc"

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| BOOT | Package | Hàm khởi động chương trình | - | - | Client IF-05, ngoài mô hình package |
| IF-05 | Interface | IF-05 IJobScheduler | «interface» | - | PKG-25 |
| SS-04 | Subsystem | Scheduler | - | - | PKG-25; không phụ thuộc package nào khác |
| IF-06 | Interface | IF-06 IScheduledJob | «interface» | - | PKG-25 định nghĩa |
| PKG-13 | Package | PKG-13 SeatBooking | - | - | DC-HoldExpiryJob, DC-SeatReleaseJob |
| PKG-14 | Package | PKG-14 PaymentRefund | - | - | DC-RefundOutboxJob |
| PKG-20 | Package | PKG-20 Notification | - | - | DC-EmailOutboxJob |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| D04-01 | BOOT | IF-05 | Dependency | - | Qua interface |
| D04-02 | SS-04 | IF-05 | Realization | - | - |
| D04-03 | SS-04 | IF-06 | Dependency | - | Gọi ngược qua interface do SS-04 định nghĩa |
| D04-04 | PKG-13 | IF-06 | Realization | - | Realization đi xuống, không đi lên |
| D04-05 | PKG-14 | IF-06 | Realization | - | Realization đi xuống |
| D04-06 | PKG-20 | IF-06 | Realization | - | Realization đi xuống |

## F7. Thiết kế xử lý lỗi và điểm kiểm tra

a) Bảng lỗi

| Operation | Tình huống lỗi | Loại | Phát hiện bằng | Xử lý trong subsystem (thử lại, tra cứu trạng thái, chuyển đổi ngoại lệ) | Kết quả trả cho client | Luồng P04 tương ứng | Q, ASM |
|---|---|---|---|---|---|---|---|
| registerJob, start | Đăng ký sau start, start hai lần, tên trùng, chu kỳ không dương | Kỹ thuật (lỗi lập trình) | Kiểm trạng thái | Không xử lý | SchedulerStateError; hàm khởi động dừng chương trình | Không có | - |
| runDue | Công việc trả lỗi hoặc panic | Kỹ thuật | recover trong DC-JobLoop | Ghi log, nhả cờ đang chạy; chu kỳ sau chạy lại (chu kỳ 10 giây cho nhiều cơ hội trong 1 phút của NFR-07) | Không lọt ra ngoài | UC-005 luồng 7b; NFR-07 | - |
| runDue | Lượt trước chưa xong khi tới chu kỳ mới | Kỹ thuật | Cờ đang chạy | Bỏ qua chu kỳ, không chạy chồng (P09 F7.4) | Không có | Không có | - |
| runDue | Lượt vượt ngân sách 8 giây cộng 2 giây (riêng DC-RefundOutboxJob: cộng thêm tối đa 80 giây cho dòng đã claim đang gọi cổng, phần này không là lượt treo) | Kỹ thuật | Đo thời gian lượt | Ghi log; công việc đó không mở lượt mới tới khi lượt cũ kết thúc | Không có | NFR-07 | - |
| runDue | Bản backend chết giữa lượt | Kỹ thuật | Ngoài SS-04 | Bản khác tiếp tục; mục hàng đợi được nhận lại sau claimed_until 120 giây (P09 F7.7); bản bị tạm dừng quá hạn đó khi tỉnh dậy bị ClaimLostError ở hàng rào giao dịch 1 hoặc ở bước ghi kết quả, không đè kết quả của bản nhận lại; quét hết hạn chia lô bằng SKIP LOCKED | Không có | UC-005 luồng 7b; UC-006, UC-008 | - |
| stop | Lượt đang chạy quá grace | Kỹ thuật | Hết grace | Ghi log lượt bị bỏ dở; an toàn vì chạy lặp được | void | Không có | - |
| (toàn hệ thống) | Mọi bản backend đều dừng | Kỹ thuật | Ngoài SS-04 | Kết quả hết hạn vẫn đúng vì tính theo expiry_time (P09 F7.4); chỉ việc trả ghế về trống chậm hơn NFR-07 | Không có | UC-005 luồng 7b | - |

Cách bảo đảm không chạy chồng và không bỏ sót. Trong một bản backend, DC-JobLoop giữ cờ đang chạy cho từng công việc nên không chạy chồng; giữa các bản backend, từng công việc tự chia việc (SKIP LOCKED cho quét hết hạn và giải phóng ghế, claim_token cho hàng đợi: mỗi luồng claim đúng một dòng ngay trước khi xử lý, và với hoàn tiền giao dịch 1 của ProcessRefund gia hạn claimed_until có điều kiện claim_token trước lời gọi cổng, P09 F7.7), không cần bầu chủ (P09 F7.8). SS-04 không có trạng thái nghiệp vụ nên mất một bản backend không làm mất việc.

b) Điểm kiểm tra

| Điểm kiểm tra | Kết quả | Ghi chú |
|---|---|---|
| Mỗi interface subsystem cung cấp có realization | Đạt | IF-05 do DC-JobSchedulerManager; IF-06 do bốn công việc ở Application (realization đi xuống) |
| Mỗi interface subsystem dùng có phụ thuộc | Đạt | SS-04 --> IF-06 trên trang Phụ thuộc |
| Không phần tử bên trong nào public, trừ kiểu dữ liệu và ngoại lệ thuộc chữ ký interface | Đạt | Public: JobRunResult, SchedulerStateError |
| Mỗi operation có sơ đồ hộp trắng hoặc ánh xạ 1-1 | Đạt | start (S04W1), stop (S04W2); registerJob ánh xạ 1-1; runDue là thân do Application hiện thực, phía SS-04 ở S04W1 |

## Câu hỏi mở

Ghi ở file chung.

## Giả định

Ghi ở file chung.

## Đề xuất sửa artifact trước

Ghi ở file chung.

## Vấn đề còn mở

Ghi ở file chung.
