# P11b - SS-03 SeatEventHub - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3); P01-actors.md 1.1 (ACT-01, ACT-02); P04-uc-specs UC-005 1.8, UC-008 1.4; P06-supplementary-spec.md 1.1 (NFR-08, NFR-09); P07-uc-analysis UC-005 1.1, UC-008 (message updateSeatMap); P08-analysis-model.md 1.2; P09-architecture.md 1.2 (F4, F6, F7.2, F7.5); P10-design-elements.md 1.1 (F2, F4, F5, F3 interface IF-22); TAI_LIEU_GIAO_TIEP: Không có (luồng SSE do P09 F7.5 mô tả) |
| Phạm vi | SS-03 SeatEventHub (IF-04) |
| Mã Q, ASM cuối đã cấp | Ghi ở file chung (mã tạm Q-126 đến Q-131) |

SS-03 là phần giao tiếp nội bộ giữa máy chủ và trình duyệt cho sơ đồ ghế: subsystem chỉ giữ đăng ký, con trỏ sự kiện và phát lại; khung SSE trên dây và REST của máy chủ thuộc DC-SeatMapService, DC-SeatMapStreamController (P12). Bảng ánh xạ để P12 dùng:

| Thành phần SSE | Nguồn | Do ai làm |
|---|---|---|
| Trường id của mỗi sự kiện | eventId của SeatChangeEvent | DC-SeatMapService dựng khung |
| Last-Event-ID của trình duyệt nối lại | afterEventId của subscribe | DC-SeatMapStreamController đọc tiêu đề, truyền xuống |
| Tham số after khi mở lần đầu | con trỏ C của ảnh chụp sơ đồ ghế | Trình duyệt truyền, controller đọc |
| Sự kiện tải lại | SeatStreamItem ReloadRequired | DC-SeatMapService dựng khung |
| Nhịp tim 15 giây, giới hạn 10 kết nối mỗi địa chỉ IP, kết nối chết sau 20 giây | P09 F7.5 | DC-SeatMapStreamController, ngoài SS-03 |

## F1. Bối cảnh sử dụng

| UC | Control gọi (AC hoặc DC) | Message trong P07 (STT, tên) | Dữ liệu truyền | Luồng lỗi trong P04 |
|---|---|---|---|---|
| UC-005 Đặt vé | DC-SeatMapService (PKG-13; P07: AC-C-BookTicketsController, AC-C-PaymentReportController gửi updateSeatMap tới BookTicketsForm, CounterBookTicketsForm) | 2.1.6, 4.1.2, 2.1.5(7b).4, 2.1.7(*a).1.4, 4a.1.3, 3a.1.3 // updateSeatMap (bước 3: ghế được giữ, đã bán, trở về trống) | Mã suất chiếu, con trỏ sự kiện; ra: luồng sự kiện đổi ghế (mã ghế, trạng thái mới) | Không có luồng P04 cho mất kết nối đẩy; Q-114 (P09): NFR-08, NFR-09 không áp dụng trong lúc mất kết nối |
| UC-008 Huỷ vé | DC-SeatMapService | 1.1.14 và 2(5a).1.3 // updateSeatMap (bước 7: ghế trở về trống) | như trên | như trên |

Trong thiết kế, P07 gửi updateSeatMap từ control tới màn hình được thay bằng mô hình kéo: giao dịch đổi ghế ghi seat_event, SS-03 đọc rồi phát (P09 F7.5, P10 F2).

## F2. Interface

| IF | Tên | Vai trò (một câu) | Bên hiện thực (SS; DC khi là interface gọi ngược) | Client (DC, PKG) | Package chứa |
|---|---|---|---|---|---|
| IF-04 | ISeatEventSubscription | Đăng ký nhận sự kiện đổi ghế của một suất chiếu từ một con trỏ theo mô hình kéo, và huỷ đăng ký | SS-03 | DC-SeatMapService (PKG-13) | PKG-24 |

IF-04 có 2 operation. SS-03 dùng IF-22 ISeatEventStore do PKG-21 định nghĩa (Q-116); operation của IF-22 do P12 chốt, tên dùng ở đây là chữ ký tạm.

## F3. Operation

| IF | Tên | Hệ thống/thiết bị | Operation | Tham số vào | Kết quả | Lỗi / ngoại lệ | UC | Tiền điều kiện | Hậu điều kiện | Đồng bộ | Idempotent | Timeout |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| IF-04 | ISeatEventSubscription | Trình duyệt người xem (qua DC-SeatMapStreamController) | subscribe(showtimeId: String, afterEventId: Integer): SeatEventSubscription | showtimeId: String - mã suất chiếu<br>afterEventId: Integer - con trỏ: mã sự kiện lớn nhất bên gọi đã thấy (từ ảnh chụp sơ đồ ghế hoặc Last-Event-ID); rỗng nghĩa là chỉ nhận sự kiện từ lúc đăng ký | SeatEventSubscription: subscriptionId (String), items (luồng SeatStreamItem do bên gọi đọc: Event mang SeatChangeEvent, ReloadRequired khi con trỏ cũ hơn thời gian giữ 10 phút, Closed kèm lý do SlowConsumer, Unsubscribed hoặc Shutdown) | SeatHubUnavailableError (Kỹ thuật tạm thời: bộ phát chưa chạy, đang tắt hoặc đọc phát lại lỗi) | UC-005 (bước 3); UC-008 (bước 7) | Bộ phát đã khởi động cùng chương trình; bên gọi đã tải ảnh chụp sơ đồ ghế kèm con trỏ nếu muốn không bỏ sót | Đăng ký đã nằm trong danh sách trước khi đọc phát lại; sự kiện từ con trỏ được phát lại rồi chuyển sang trực tiếp; bên gọi chịu được sự kiện lặp và lệch thứ tự giữa các ghế (áp theo từng ghế, P09 F7.5 điểm 5) | Đồng bộ trả handle ngay; luồng items bất đồng bộ | Không (mỗi lần gọi tạo đăng ký mới); gọi lại với cùng con trỏ an toàn | Không áp dụng cho việc trả handle; đọc phát lại tối đa 3 giây (Thiết kế: bằng statement_timeout, P09 F7.2); độ trễ sự kiện tới bên gọi tối đa 3 giây tính từ commit (NFR-08, NFR-09; P09 F7.5) |
| IF-04 | ISeatEventSubscription | Trình duyệt người xem | unsubscribe(subscriptionId: String): void | subscriptionId: String - mã do subscribe trả | - | Không | UC-005 (bước 3); UC-008 (bước 7): khi kết nối đóng | Không | Đăng ký đã gỡ khỏi danh sách, hàng đợi đóng với lý do Unsubscribed | Đồng bộ | Có (gọi lần hai không có tác dụng) | Không áp dụng |

Phủ trách nhiệm: updateSeatMap của hai boundary đặt vé --> subscribe và luồng items; kết nối đóng --> unsubscribe (P10 F2).

## F4. Sequence diagram

File diagrams/P11b-subsystem-SS-03.drawio, 5 trang: S03B1 (hộp đen), S03W1 (hộp trắng subscribe), S03W2 (vòng đọc seat_event, luồng nội bộ không do operation kích hoạt), Phần tử, Phụ thuộc. Operation unsubscribe được hiện thực một-một bởi DC-SeatEventHubManager (gỡ đăng ký khỏi DC-SubscriberRegistry và đóng hàng đợi) nên không có sơ đồ hộp trắng riêng.

### Trang "Hộp đen - subscribe, unsubscribe (UC-005, UC-008)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S03B1-L1 | Lifeline | :SeatMapService | - | DC-SeatMapService, PKG-13 | Do DC-SeatMapStreamController (PKG-11) gọi; dịch luồng thành khung SSE |
| S03B1-L2 | Lifeline | :IF-04 ISeatEventSubscription | «interface» | SS-03 | Interface đăng ký |
| S03B1-F1 | Fragment | alt [đăng ký được] | - | - | Operand tiếp: [bộ phát chưa chạy, đang tắt hoặc đọc phát lại lỗi] |
| S03B1-F2 | Fragment | loop [đến khi kết nối đóng] | - | - | Một operand |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :SeatMapService | :IF-04 ISeatEventSubscription | subscribe(showtimeId, afterEventId) | Đồng bộ | - | UC-005 bước 3 (updateSeatMap); mở SSE sau ảnh chụp hoặc nối lại bằng Last-Event-ID |
| 2 | :IF-04 ISeatEventSubscription | :SeatMapService | SeatEventSubscription(subscriptionId, items) | Trả về | S03B1-F1 [đăng ký được] | Luồng items gồm sự kiện phát lại rồi trực tiếp |
| 3 | :IF-04 ISeatEventSubscription | :SeatMapService | SeatHubUnavailableError | Trả về | S03B1-F1 [bộ phát chưa chạy, đang tắt hoặc đọc phát lại lỗi] | Trình duyệt nối lại tự động; không có luồng P04 |
| 4 | :IF-04 ISeatEventSubscription | :SeatMapService | SeatStreamItem(Event, ReloadRequired hoặc Closed) | Bất đồng bộ | S03B1-F2 [đến khi kết nối đóng] | UC-005 bước 3, luồng 7b, 11a, *a; UC-008 bước 7 (ghế đổi hoặc trả về trống, NFR-08, NFR-09) |
| 5 | :SeatMapService | :IF-04 ISeatEventSubscription | unsubscribe(subscriptionId) | Đồng bộ | - | Kết nối đóng |
| 6 | :IF-04 ISeatEventSubscription | :SeatMapService | void | Trả về | - | Gọi lại lần hai không có tác dụng |

### Trang "Hộp trắng - subscribe"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S03W1 | Fragment | sd subscribe | - | - | Khung sd; mọi lifeline nằm trong khung |
| S03W1-L1 | Lifeline | :SeatEventHubManager | - | DC-SeatEventHubManager | Điều phối, hiện thực IF-04 |
| S03W1-L2 | Lifeline | :SubscriberRegistry | - | DC-SubscriberRegistry | Lưu trữ trong subsystem |
| S03W1-L3 | Lifeline | :SubscriberQueue | - | DC-SubscriberQueue | Hàng đợi 256 sự kiện mỗi kết nối |
| S03W1-L4 | Lifeline | :SeatReplayReader | - | DC-SeatReplayReader | Giao tiếp (đọc phát lại) |
| S03W1-L5 | Lifeline | :IF-22 ISeatEventStore | «interface» | PKG-21 | Chữ ký tạm, P12 chốt |
| S03W1-G1 | Gate | subscribe | - | S03W1 | Gate của message 1 |
| S03W1-G13 | Gate | trả về SeatHubUnavailableError | - | S03W1 | Gate của message 13 |
| S03W1-G17 | Gate | trả về SeatEventSubscription | - | S03W1 | Gate của message 17 |
| S03W1-F1 | Fragment | alt [afterEventId rỗng] | - | S03W1 | Operand tiếp: [có con trỏ] |
| S03W1-F2 | Fragment | alt [dòng con trỏ đã bị xoá (cũ hơn 10 phút)] | - | S03W1 | Operand tiếp: [còn dòng con trỏ] |
| S03W1-F3 | Fragment | alt [đọc lỗi hoặc quá 3 giây] | - | S03W1 | Operand tiếp: [đọc được] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :SeatEventHubManager | subscribe(showtimeId, afterEventId) | Đồng bộ | - | IF-04; UC-005 bước 3 |
| 2 | :SeatEventHubManager | :SubscriberRegistry | register(showtimeId) | Đồng bộ | - | Đăng ký trước khi đọc phát lại để không hở sự kiện |
| 3 | :SubscriberRegistry | :SeatEventHubManager | subscriber(subscriptionId, queue) | Trả về | - | Trạng thái đang phát lại: sự kiện trực tiếp được giữ tạm |
| 4 | :SeatEventHubManager | :SubscriberRegistry | startLive(subscriptionId) | Đồng bộ | S03W1-F1 [afterEventId rỗng] | Chỉ nhận sự kiện từ lúc đăng ký |
| 5 | :SeatEventHubManager | :SeatReplayReader | replay(showtimeId, afterEventId, queue) | Đồng bộ | S03W1-F1 [có con trỏ] | P09 F7.5 điểm 4 |
| 6 | :SeatReplayReader | :IF-22 ISeatEventStore | findEvent(afterEventId) | Đồng bộ | S03W1-F1 [có con trỏ] | Tên tạm |
| 7 | :IF-22 ISeatEventStore | :SeatReplayReader | event hoặc không có | Trả về | S03W1-F1 [có con trỏ] | - |
| 8 | :SeatReplayReader | :SubscriberQueue | offer(SeatStreamItem(ReloadRequired)) | Đồng bộ | S03W1-F2 [dòng con trỏ đã bị xoá (cũ hơn 10 phút)] | Trình duyệt tải lại ảnh chụp sau độ trễ ngẫu nhiên 0 đến 3 giây |
| 9 | :SeatReplayReader | :IF-22 ISeatEventStore | readShowtimeEvents(showtimeId, afterEventId, notBefore) | Đồng bộ | S03W1-F2 [còn dòng con trỏ] | notBefore là createdAt của con trỏ trừ 5 giây; tên tạm; hạn 3 giây theo statement_timeout |
| 10 | :IF-22 ISeatEventStore | :SeatReplayReader | StorageError | Trả về | S03W1-F3 [đọc lỗi hoặc quá 3 giây] | - |
| 11 | :SeatReplayReader | :SeatEventHubManager | StorageError | Trả về | S03W1-F3 [đọc lỗi hoặc quá 3 giây] | - |
| 12 | :SeatEventHubManager | :SubscriberRegistry | remove(subscriptionId) | Đồng bộ | S03W1-F3 [đọc lỗi hoặc quá 3 giây] | Dọn đăng ký đã tạo |
| 13 | :SeatEventHubManager | Gate | SeatHubUnavailableError | Trả về | S03W1-F3 [đọc lỗi hoặc quá 3 giây] | Trình duyệt nối lại tự động |
| 14 | :IF-22 ISeatEventStore | :SeatReplayReader | events | Trả về | S03W1-F3 [đọc được] | - |
| 15 | :SeatReplayReader | :SubscriberQueue | offerAll(events) | Đồng bộ | S03W1-F3 [đọc được] | Sự kiện phát lại đi trước sự kiện trực tiếp |
| 16 | :SeatEventHubManager | :SubscriberRegistry | startLive(subscriptionId) | Đồng bộ | S03W1-F1 [có con trỏ] | Nhả sự kiện giữ tạm, bỏ mã đã phát lại |
| 17 | :SeatEventHubManager | Gate | SeatEventSubscription(subscriptionId, items) | Trả về | - | - |

### Trang "Hộp trắng - vòng đọc seat_event mỗi 500 ms (nội bộ)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S03W2 | Fragment | sd pollSeatEvents | - | - | Khung sd; mọi lifeline nằm trong khung |
| S03W2-L1 | Lifeline | :SeatEventPoller | - | DC-SeatEventPoller | Điều phối nền, kích hoạt mỗi 500 ms |
| S03W2-L2 | Lifeline | :IF-22 ISeatEventStore | «interface» | PKG-21 | Chữ ký tạm, P12 chốt |
| S03W2-L3 | Lifeline | :EmittedEventTracker | - | DC-EmittedEventTracker | Lưu trữ trong subsystem |
| S03W2-L4 | Lifeline | :SubscriberRegistry | - | DC-SubscriberRegistry | Lưu trữ trong subsystem |
| S03W2-L5 | Lifeline | :SubscriberQueue | - | DC-SubscriberQueue | Hàng đợi 256 sự kiện mỗi kết nối |
| S03W2-F1 | Fragment | loop [mỗi sự kiện, theo mã tăng dần] | - | S03W2 | Một operand |
| S03W2-F2 | Fragment | opt [hàng đợi đầy (256)] | - | S03W2 | Một operand |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :SeatEventPoller | :IF-22 ISeatEventStore | readEventsAfter(watermark) | Đồng bộ | - | P09 F7.5 điểm 3; mỗi lần quét khoảng 5 giây gần nhất |
| 2 | :IF-22 ISeatEventStore | :SeatEventPoller | events, databaseNow | Trả về | - | Thời điểm cơ sở dữ liệu đi kèm để tính mốc |
| 3 | :SeatEventPoller | :EmittedEventTracker | isEmitted(eventId) | Đồng bộ | S03W2-F1 [mỗi sự kiện, theo mã tăng dần] | - |
| 4 | :EmittedEventTracker | :SeatEventPoller | false | Trả về | S03W2-F1 [mỗi sự kiện, theo mã tăng dần] | Đã phát thì bỏ qua |
| 5 | :SeatEventPoller | :SubscriberRegistry | queuesOf(showtimeId) | Đồng bộ | S03W2-F1 [mỗi sự kiện, theo mã tăng dần] | - |
| 6 | :SubscriberRegistry | :SeatEventPoller | queues | Trả về | S03W2-F1 [mỗi sự kiện, theo mã tăng dần] | - |
| 7 | :SeatEventPoller | :SubscriberQueue | offer(SeatStreamItem(Event)) | Đồng bộ | S03W2-F1 [mỗi sự kiện, theo mã tăng dần] | Không chặn |
| 8 | :SubscriberQueue | :SubscriberRegistry | closeAndRemove(SlowConsumer) | Đồng bộ | S03W2-F2 [hàng đợi đầy (256)] | Đóng kết nối để trình duyệt nối lại và tải lại ảnh chụp |
| 9 | :SeatEventPoller | :EmittedEventTracker | markEmitted(eventId) | Đồng bộ | S03W2-F1 [mỗi sự kiện, theo mã tăng dần] | - |
| 10 | :SeatEventPoller | :EmittedEventTracker | advanceWatermark(events, databaseNow trừ 5 giây) | Đồng bộ | - | Mốc W là mã lớn nhất trong các dòng đã phát cũ hơn 5 giây |
| 11 | :SeatEventPoller | :EmittedEventTracker | forgetOlderThan(10 giây) | Đồng bộ | - | - |

## F5. Phần tử của subsystem

a) Bảng phần tử

| DC | Tên | Vai trò (Điều phối / Giao tiếp ngoài / Chuyển đổi dữ liệu / Lưu trữ trong subsystem / Kiểu dữ liệu / Ngoại lệ) | Trách nhiệm | Visibility | Hiện thực IF |
|---|---|---|---|---|---|
| DC-SeatEventHubManager | SeatEventHubManager | Điều phối | Nhận subscribe, unsubscribe; đăng ký trước, phát lại sau, rồi chuyển sang trực tiếp; chuyển lỗi đọc thành SeatHubUnavailableError | package-private | IF-04 |
| DC-SeatEventPoller | SeatEventPoller | Điều phối | Vòng 500 ms: đọc sự kiện sau mốc W qua IF-22, bỏ mã đã phát, đẩy vào hàng đợi các kết nối của suất chiếu, tiến mốc W, dọn tập mã đã phát | package-private | - |
| DC-SeatReplayReader | SeatReplayReader | Giao tiếp ngoài | Đọc sự kiện của một suất chiếu từ con trỏ qua IF-22 và đẩy vào hàng đợi; phát hiện con trỏ đã bị xoá để yêu cầu tải lại | package-private | - |
| DC-SubscriberRegistry | SubscriberRegistry | Lưu trữ trong subsystem | Giữ danh sách đăng ký theo suất chiếu và trạng thái đang phát lại hay trực tiếp; đóng và gỡ đăng ký | package-private | - |
| DC-SubscriberQueue | SubscriberQueue | Lưu trữ trong subsystem | Hàng đợi giới hạn 256 sự kiện mỗi kết nối; đầy thì đóng với lý do SlowConsumer | package-private | - |
| DC-EmittedEventTracker | EmittedEventTracker | Lưu trữ trong subsystem | Giữ tập mã sự kiện đã phát trong 10 giây gần nhất và mốc W (mã lớn nhất trong các dòng đã phát cũ hơn 5 giây) | package-private | - |
| DC-SeatEventSubscription | SeatEventSubscription | Kiểu dữ liệu | subscriptionId (String), items (luồng SeatStreamItem, bên gọi đọc); dùng trong chữ ký if-04 | public | - |
| DC-SeatStreamItem | SeatStreamItem | Kiểu dữ liệu | kind (Event / ReloadRequired / Closed), event (SeatChangeEvent, có khi kind là Event), closeReason (SlowConsumer / Unsubscribed / Shutdown, có khi kind là Closed); dùng trong chữ ký if-04 | public | - |
| DC-SeatHubUnavailableError | SeatHubUnavailableError | Ngoại lệ | Bộ phát chưa chạy, đang tắt hoặc đọc phát lại lỗi; dùng trong chữ ký if-04 | public | - |

Kiểu DC-SeatChangeEvent thuộc PKG-28 (P10 F4); SS-03 dùng trực tiếp vì Domain là layer thấp nhất (P09 A4). Cơ chế ghi nhật ký và cấu hình (Thiết kế: chu kỳ 500 ms, cửa sổ chồng 5 giây, tập mã đã phát 10 giây, hàng đợi 256 là hằng của subsystem theo P09 F7.5, đọc từ cấu hình khi khởi động để chỉnh sau ca đo T3; log mỗi lần đóng kết nối kèm lý do, không log từng sự kiện).

b) Class diagram phần tử (trang "Phần tử")

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| IF-04 | Interface | ISeatEventSubscription | «interface» | - | PKG-24 |
| IF-22 | Interface | ISeatEventStore | «interface» | - | PKG-21 định nghĩa; tên operation tạm |
| SS-03 | Subsystem | SeatEventHub | - | - | Chỉ interface là public |
| DC-SeatEventHubManager | Class | SeatEventHubManager | - | SS-03 | Hiện thực IF-04 |
| DC-SeatEventPoller | Class | SeatEventPoller | - | SS-03 | Điều phối nền |
| DC-SeatReplayReader | Class | SeatReplayReader | - | SS-03 | Giao tiếp |
| DC-SubscriberRegistry | Class | SubscriberRegistry | - | SS-03 | Lưu trữ trong subsystem |
| DC-SubscriberQueue | Class | SubscriberQueue | - | SS-03 | Lưu trữ trong subsystem |
| DC-EmittedEventTracker | Class | EmittedEventTracker | - | SS-03 | Lưu trữ trong subsystem |
| DC-SeatEventSubscription | Class | SeatEventSubscription | «value» | SS-03 | Kiểu dữ liệu (public) |
| DC-SeatStreamItem | Class | SeatStreamItem | «value» | SS-03 | Kiểu dữ liệu (public) |
| DC-SeatChangeEvent | Class | SeatChangeEvent | «value» | SS-03 | PKG-28 (Domain); hiện ở đây để thấy kiểu của chữ ký |
| DC-SeatHubUnavailableError | Class | SeatHubUnavailableError | «exception» | SS-03 | Ngoại lệ (public) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| C03-01 | DC-SeatEventHubManager | IF-04 | Realization | - | - |
| C03-02 | DC-SeatEventHubManager | DC-SubscriberRegistry | Dependency | - | đăng ký |
| C03-03 | DC-SeatEventHubManager | DC-SeatReplayReader | Dependency | - | phát lại |
| C03-04 | DC-SeatEventPoller | DC-SubscriberRegistry | Dependency | - | tìm hàng đợi |
| C03-05 | DC-SeatEventPoller | DC-EmittedEventTracker | Dependency | - | chống phát lặp |
| C03-06 | DC-SeatEventPoller | DC-SubscriberQueue | Dependency | - | offer |
| C03-07 | DC-SeatReplayReader | DC-SubscriberQueue | Dependency | - | offerAll |
| C03-08 | DC-SubscriberRegistry | DC-SubscriberQueue | Composition | 1 ở đầu nguồn; 0..* ở đầu đích | - |
| C03-09 | DC-SeatEventPoller | IF-22 | Dependency | - | đọc sau mốc |
| C03-10 | DC-SeatReplayReader | IF-22 | Dependency | - | đọc phát lại |
| C03-11 | DC-SeatEventSubscription | DC-SeatStreamItem | Association | 1 ở đầu nguồn; 0..* ở đầu đích | - |
| C03-12 | DC-SeatStreamItem | DC-SeatChangeEvent | Association | 1 ở đầu nguồn; 0..1 ở đầu đích | - |

## F6. Phụ thuộc subsystem

| Subsystem | Phụ thuộc vào (IF, SS, PKG) | Loại (Qua interface / Vào package) | Lý do | Đánh giá (Ưu tiên / Dùng thận trọng) |
|---|---|---|---|---|
| SS-03 SeatEventHub | IF-22 (PKG-21) | Qua interface | Đọc seat_event theo con trỏ và dọn sự kiện; PKG-24 --> PKG-21 cùng layer Services, một chiều, PKG-21 không phụ thuộc PKG-24 (P09 F6, Q-116) | Ưu tiên |
| SS-03 SeatEventHub | PKG-28 | Vào package | Kiểu SeatChangeEvent trong chữ ký IF-04; Services --> Domain (P09 F6) | Dùng thận trọng: chỉ dùng kiểu giá trị, không dùng entity |

Phía client: PKG-13 phụ thuộc IF-04.

Trang "Phụ thuộc"

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| PKG-13 | Package | PKG-13 SeatBooking | - | - | Client IF-04: DC-SeatMapService |
| IF-04 | Interface | IF-04 ISeatEventSubscription | «interface» | - | PKG-24 |
| SS-03 | Subsystem | SeatEventHub | - | - | PKG-24 |
| IF-22 | Interface | IF-22 ISeatEventStore | «interface» | - | PKG-21 |
| PKG-21 | Package | PKG-21 Persistence | - | - | Hiện thực IF-22 |
| PKG-28 | Package | PKG-28 Ticketing | - | - | Kiểu DC-SeatChangeEvent |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| D03-01 | PKG-13 | IF-04 | Dependency | - | Qua interface |
| D03-02 | SS-03 | IF-04 | Realization | - | - |
| D03-03 | SS-03 | IF-22 | Dependency | - | Qua interface, cùng layer Services, một chiều |
| D03-04 | PKG-21 | IF-22 | Realization | - | PKG-21 --> PKG-24 không có (không vòng) |
| D03-05 | SS-03 | PKG-28 | Dependency | - | Vào package: kiểu sự kiện đổi ghế (Services --> Domain) |

## F7. Thiết kế xử lý lỗi và điểm kiểm tra

a) Bảng lỗi

| Operation | Tình huống lỗi | Loại | Phát hiện bằng | Xử lý trong subsystem (thử lại, tra cứu trạng thái, chuyển đổi ngoại lệ) | Kết quả trả cho client | Luồng P04 tương ứng | Q, ASM |
|---|---|---|---|---|---|---|---|
| subscribe | Bộ phát chưa chạy hoặc đang tắt | Kỹ thuật tạm thời | Cờ trạng thái bộ phát | Không đăng ký | SeatHubUnavailableError; controller trả 503, trình duyệt nối lại tự động | Không có luồng P04 | Q-114 (đã trả lời: không áp dụng NFR-08, NFR-09 khi mất kết nối) |
| subscribe | Đọc phát lại qua IF-22 lỗi hoặc quá 3 giây | Kỹ thuật tạm thời | StorageError, hết thời gian | Gỡ đăng ký vừa tạo; không thử lại | SeatHubUnavailableError | Như trên | Q-114 |
| subscribe | Con trỏ cũ hơn thời gian giữ (dòng bị xoá sau 10 phút) | Nghiệp vụ (dữ liệu quá hạn) | findEvent không thấy dòng | Đặt ReloadRequired vào hàng đợi, vẫn chuyển sang trực tiếp | Item ReloadRequired; trình duyệt tải lại ảnh chụp sau độ trễ ngẫu nhiên 0 đến 3 giây | UC-005 bước 3 (sơ đồ ghế được tải lại) | - |
| (nội bộ) vòng đọc 500 ms | IF-22 lỗi khi đọc sau mốc W | Kỹ thuật tạm thời | StorageError | Ghi log, giữ nguyên mốc W, thử lại ở lượt 500 ms kế; không phát gì sai | Không lộ ra (không có operation) | NFR-08, NFR-09 (độ trễ tăng cho tới khi đọc lại được) | - |
| (nội bộ) vòng đọc 500 ms | Hàng đợi một kết nối đầy 256 sự kiện | Kỹ thuật (người nhận chậm) | offer thất bại | Đóng đăng ký với lý do SlowConsumer, gỡ khỏi danh sách | Item Closed(SlowConsumer); trình duyệt nối lại và tải lại ảnh chụp | Không có | - |
| (nội bộ) vòng đọc 500 ms | Dòng mã nhỏ commit sau dòng mã lớn | Kỹ thuật | Mốc W và cửa sổ chồng 5 giây | Giữ tập mã đã phát 10 giây, bỏ trùng; mốc W chỉ tiến qua dòng đã cũ hơn 5 giây | Không có; trình duyệt áp theo từng ghế nên phát lặp, lệch thứ tự đều vô hại | Không có | - |
| unsubscribe | Mã đăng ký không tồn tại hoặc đã gỡ | Kỹ thuật | Tra danh sách | Bỏ qua | Không lỗi (idempotent) | Không có | - |
| (nội bộ) tắt chương trình | Bản backend dừng | Kỹ thuật | Tín hiệu tắt | Đóng mọi đăng ký với lý do Shutdown | Item Closed(Shutdown); trình duyệt nối lại bản khác với Last-Event-ID | Không có | Q-114 |

Cách bảo đảm không bỏ sót và không phát nhầm. Sự kiện nằm trong bảng seat_event bền nên không mất khi kết nối đứt hay bản backend khởi động lại; đăng ký được đặt trước khi đọc phát lại nên không có khe hở giữa ảnh chụp và luồng trực tiếp; phát lại lấy các dòng có mã lớn hơn con trỏ hoặc created_at không sớm hơn created_at của dòng con trỏ trừ 5 giây để bù dòng commit muộn; trình duyệt chỉ áp sự kiện khi mã lớn hơn event_seq đang có của ghế (P09 F7.5). Mỗi bản backend tự đọc và tự phát cho kết nối của mình, không có kênh giữa các bản (P09 F7.8).

b) Điểm kiểm tra

| Điểm kiểm tra | Kết quả | Ghi chú |
|---|---|---|
| Mỗi interface subsystem cung cấp có realization | Đạt | IF-04 do DC-SeatEventHubManager |
| Mỗi interface subsystem dùng có phụ thuộc | Đạt | IF-22: SS-03 --> IF-22 trên trang Phụ thuộc |
| Không phần tử bên trong nào public, trừ kiểu dữ liệu và ngoại lệ thuộc chữ ký interface | Đạt | Public: SeatEventSubscription, SeatStreamItem, SeatHubUnavailableError |
| Mỗi operation có sơ đồ hộp trắng hoặc ánh xạ 1-1 | Đạt | subscribe có trang S03W1; unsubscribe ánh xạ 1-1 qua DC-SeatEventHubManager |

## Câu hỏi mở

Ghi ở file chung.

## Giả định

Ghi ở file chung.

## Đề xuất sửa artifact trước

Ghi ở file chung.

## Vấn đề còn mở

Ghi ở file chung.
