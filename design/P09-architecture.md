# P09 - Thiết kế kiến trúc - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P09 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3); P01-actors.md 1.1 (Mục 1, 2); P02-usecases.md 1.8 (Mục 4); P05-glossary.md 1.1; P06-supplementary-spec.md 1.1 (Mục 2 đến 6, Câu hỏi mở); P08-analysis-model.md 1.1 (F1, F3, F4, F4b, F4c, Câu hỏi mở). Công nghệ do người dùng chốt trong yêu cầu chạy bước (xem F2.2) |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-115; không có ASM (NGHIEM_NGAT) |

Trọng tâm: hiện thực các đơn vị loại trừ EX-01 đến EX-15 và thứ tự khoá 9 hạng của P08 F4b bằng cơ chế của PostgreSQL; giải phóng ghế hết hạn trong 1 phút; cập nhật sơ đồ ghế trong 3 giây; tiếp nhận báo kết quả của cổng thanh toán một cách idempotent; chạy nhiều bản backend mà khoá vẫn đúng. Các cơ chế này nằm ở F7.3 đến F7.7.

## F1. Yêu cầu có ý nghĩa kiến trúc

Mức ưu tiên: P06 không xếp hạng NFR và không có TIEU_CHI_UU_TIEN; Thiết kế: xếp theo quy tắc F1 (ràng buộc cứng "không được", "phải" trước, rồi NFR có ngưỡng đo được, rồi định tính).

| STT | Nguồn (NFR, ràng buộc, ACT) | Kịch bản thuộc tính chất lượng (kích thích --> phản hồi --> thước đo) | Mức ưu tiên | Ảnh hưởng kiến trúc |
|---|---|---|---|---|
| 1 | BR-04, BR-07, BR-08, BR-09, BR-85, BR-86; NFR-04, NFR-05 | Nhiều người cùng xác nhận chọn ghế hoặc cùng thao tác trên một lần giữ ghế --> mỗi ghế chỉ giữ cho một người, giữ cả nhóm hoặc không ghế nào, trạng thái cuối không đổi --> không ghế nào giữ hoặc bán cho hai người ở 4.000 khách, 1.000 khách một suất chiếu (P06 NFR-05) | 1 | Khoá nằm ở cơ sở dữ liệu (không ở bộ nhớ tiến trình) để đúng khi chạy nhiều bản backend; thứ tự khoá 9 hạng của P08 F4b |
| 2 | NFR-06 (REQ-75, REQ-156) | Khách xác nhận chọn ghế (UC-005 bước 7) --> hệ thống giữ ghế hoặc từ chối --> không quá 2 giây; tải thường mọi lần, tải đỉnh 95% lần | 2 | Giao dịch giữ ghế ngắn, ít câu lệnh, khoá hẹp theo từng ghế; không gọi mạng ngoài trong giao dịch; có giới hạn thời gian chờ khoá |
| 3 | NFR-07 (REQ-76), BR-10 | Lần giữ ghế quá thời điểm hết hạn --> ghế về trống --> không quá 1 phút sau thời điểm hết hạn, mọi lần | 2 | Công việc nền định kỳ lưu trong cơ sở dữ liệu, không giữ bộ đếm giờ trong bộ nhớ; hết hạn tính theo cột thời điểm hết hạn |
| 4 | NFR-08, NFR-09 (REQ-19, REQ-119) | Ghế đổi trạng thái (giữ, bán, trống) --> sơ đồ ghế của người đang xem hiện trạng thái mới --> không quá 3 giây; tải đỉnh 95% lần | 2 | Kênh đẩy từ máy chủ xuống trình duyệt; phát sự kiện giữa các bản backend |
| 5 | NFR-16 (ACT-07), BR-37, BR-14, BR-15, BR-40, BR-85, BR-86 | Cổng thanh toán gửi kết quả giao dịch, có thể trùng, đến muộn, hoặc đến cùng lúc với hết hạn --> tạo vé đúng một lần hoặc ghi nhận thanh toán trễ kèm yêu cầu hoàn --> không tạo vé thứ hai, không mất khoản phải hoàn | 1 | Điểm tiếp nhận callback idempotent, quyết định trong một giao dịch cơ sở dữ liệu dưới khoá lần giữ ghế |
| 6 | NFR-15, NFR-17, NFR-18, BR-41, BR-43, BR-89, BR-90 (ACT-07, ACT-08) | Cổng thanh toán hoặc dịch vụ email từ chối, không trả lời trong 30 giây --> vé và lần giữ ghế giữ nguyên hiệu lực, thử lại, ghi log lỗi --> không treo luồng giữ khoá | 3 | Mỗi hệ thống ngoài che sau interface; việc gửi chạy ngoài giao dịch giữ khoá, có hàng đợi gửi lại lưu trong cơ sở dữ liệu |
| 7 | NFR-10 (REQ-77) | Hệ thống xử lý thanh toán --> không lưu thông tin thẻ --> không có dữ liệu thẻ trong mã nguồn, dữ liệu, log | 1 | Thanh toán chuyển hướng sang cổng; hệ thống chỉ lưu mã giao dịch và số tiền |
| 8 | NFR-11 (NEN_TANG), NFR-13, NFR-14; ACT-03 | Khách và nhân viên dùng trình duyệt từ 360 pixel; nhân viên soát vé dùng camera trên điện thoại qua HTTPS --> chạy đúng --> Chrome, Edge, Firefox, Safari bản mới | 1 | Ứng dụng web một trang responsive; mọi truy cập qua HTTPS; mã QR đọc phía trình duyệt, kiểm tra phía máy chủ |
| 9 | RANG_BUOC_KIEN_TRUC (người dùng) | Đồ án sinh viên, một nhóm phát triển, Go, React, PostgreSQL, không Redis --> kiến trúc triển khai được --> không microservices, không thành phần ngoài danh sách | 1 | Modular monolith phân lớp; khoá và hàng đợi dùng PostgreSQL |
| 10 | Sẵn sàng, khởi động lại (A7); P06 không có NFR sẵn sàng | Một bản backend dừng hoặc khởi động lại giữa lúc ghế đang được giữ --> không mất lần giữ ghế, ghế vẫn được giải phóng --> thước đo: Chưa quy định (Q-112) | 3 | Mọi trạng thái chờ (hết hạn, gửi lại) nằm trong cơ sở dữ liệu; backend không giữ trạng thái giữa hai yêu cầu |

## F2. Phương án và so sánh

### F2.1. Mẫu kiến trúc

Có từ 2 phương án khả thi nên lập bảng so sánh. Phía giao diện (Web app responsive) tách thành front-end chạy trình duyệt và back-end, nên mọi phương án đều là front-end/back-end ở mức triển khai.

| PA | Mẫu kiến trúc (và kết hợp) | Mô tả ngắn | Điều kiện phù hợp |
|---|---|---|---|
| PA1 | Front-end/back-end; back-end là modular monolith multi-layer (Presentation, Application, Services, Domain); nhiều bản chạy sau bộ cân bằng tải; khoá và hàng đợi trong PostgreSQL | Một mã nguồn Go, chia package theo nhóm chức năng, một cơ sở dữ liệu | Một nhóm phát triển, vài chục use case, tải đỉnh 4.000 khách |
| PA2 | Microservices (dịch vụ ghế, dịch vụ thanh toán, dịch vụ vé) với giao dịch phân tán | Mỗi dịch vụ một cơ sở dữ liệu, nhất quán qua sự kiện | Nhiều nhóm, yêu cầu mở rộng độc lập từng phần |
| PA3 | Front-end/back-end; back-end một bản duy nhất, khoá trong bộ nhớ (mutex theo suất chiếu) | Đơn giản nhất, không cần khoá ở cơ sở dữ liệu | Tải nhỏ, không cần nhiều bản |

| Tiêu chí (từ F1) | Trọng số | PA1 | PA2 | PA3 |
|---|---|---|---|---|
| Đúng đắn đồng thời (F1 dòng 1, 5) | Cao | Tốt: khoá dòng và ràng buộc của PostgreSQL, một nguồn sự thật | Kém: giao dịch phân tán qua nhiều dịch vụ khó bảo đảm tất cả hoặc không | Trung bình: đúng khi một bản, sai khi nhân bản |
| Hiệu năng 2 giây, 3 giây (F1 dòng 2, 3, 4) | Cao | Tốt: một lần đi tới cơ sở dữ liệu, khoá hẹp; cần kiểm bằng tải | Kém: thêm bước gọi mạng giữa dịch vụ | Tốt: không chờ khoá cơ sở dữ liệu |
| Chịu khởi động lại, nhiều bản (F1 dòng 10) | Trung bình | Tốt: không có trạng thái trong bộ nhớ | Tốt | Kém: mất bộ đếm giờ, không chạy được nhiều bản |
| Ràng buộc đồ án, phù hợp quy mô (F1 dòng 9) | Cao | Tốt: một mã nguồn, một cơ sở dữ liệu | Kém: quá lớn cho một nhóm | Tốt |
| Bảo trì, dễ kiểm thử | Trung bình | Tốt: package theo nhóm chức năng, Domain độc lập | Trung bình: nhiều thành phần triển khai | Trung bình |
| Kết luận | | Chọn PA1. Tiêu chí quyết định: đúng đắn đồng thời và ràng buộc đồ án; PA3 loại vì không chạy được nhiều bản (yêu cầu của người dùng), PA2 loại vì quá lớn | | |

### F2.2. Chốt công nghệ

Hồ sơ dự án ghi CONG_NGHE là "Chưa chốt" nhưng người dùng đã chốt công nghệ trong yêu cầu chạy bước này (tương đương PHUONG_AN_DA_CHON), nên không lập bảng so sánh nhiều phương án công nghệ; chỉ kiểm tra phương án có phù hợp.

| CN | Nền tảng | Phía máy chủ | Phía giao diện | CSDL | Giao tiếp ngoài |
|---|---|---|---|---|---|
| CN-chốt | Web app responsive | Go (net/http của thư viện chuẩn, driver pgx cho PostgreSQL) | React, ứng dụng một trang (SPA) | PostgreSQL 15 trở lên (Thiết kế: có đủ khoá dòng FOR SHARE, FOR UPDATE, SKIP LOCKED, LISTEN/NOTIFY) | HTTPS tới API cổng thanh toán sandbox, callback HTTPS từ cổng; SMTP tới dịch vụ email |

| Tiêu chí | Mức phù hợp | Lý do |
|---|---|---|
| Đúng đắn đồng thời | Tốt | PostgreSQL có khoá dòng, mức cô lập, ràng buộc unique và LISTEN/NOTIFY, đủ thay Redis |
| Tải 4.000 khách | Tốt | Go có goroutine nhẹ cho 4.000 kết nối đẩy giữ lâu; pgxpool giới hạn số kết nối cơ sở dữ liệu |
| Camera soát vé, responsive (NFR-11) | Tốt | React chạy trên trình duyệt; camera cần HTTPS, do bộ cân bằng tải kết thúc TLS |
| Hệ thống ngoài | Tốt | Cổng thanh toán dùng REST và callback HTTP; SMTP có thư viện chuẩn của Go |

Trạng thái: Đã chốt bởi người dùng.

## F3. Quyết định kiến trúc

| Mục | Nội dung |
|---|---|
| Bối cảnh | Hệ thống bán vé trực tuyến và tại quầy trên cùng sơ đồ ghế; trọng tâm là chống tranh chấp ghế, giữ ghế 10 phút, giải phóng ghế đúng hạn, báo kết quả thanh toán không đáng tin về thứ tự. 16 use case trong phạm vi, 8 tác nhân (6 người, 2 hệ thống ngoài), đồ án một nhóm |
| Quyết định (mẫu và cách kết hợp) | PA1: front-end/back-end. Back-end là modular monolith multi-layer 4 layer, Presentation --> Application --> Services --> Domain (Domain thấp nhất, theo A4), layered nới lỏng. Mọi bản backend giống nhau, không giữ trạng thái giữa hai yêu cầu; mọi loại trừ, hàng đợi, bộ hẹn giờ dựa vào PostgreSQL |
| Mẫu cho phía giao diện (A3b) | Kiến trúc component của React kết hợp luồng dữ liệu một chiều kiểu Flux (kho trạng thái, hành động, reducer). Sự kiện đẩy của sơ đồ ghế đi vào kho trạng thái như một hành động. Không dùng MVC phía server vì giao diện là SPA; phần tiếp nhận yêu cầu ở back-end (REST controller, điểm vào callback) thuộc Presentation phía máy chủ, khác lớp control của phân tích |
| Công nghệ | Go, React, PostgreSQL (F2.2); trạng thái Đã chốt bởi người dùng. Không Redis, không hàng đợi tin nhắn ngoài |
| Phương án đã loại và lý do | PA2 microservices (quá lớn, giao dịch phân tán phá tính tất cả hoặc không của BR-07); PA3 khoá trong bộ nhớ (sai khi nhiều bản, mất hẹn giờ khi khởi động lại); Redis (người dùng không chọn); mức cô lập SERIALIZABLE cho toàn hệ thống (dưới 1.000 giao dịch tranh nhau một suất chiếu sẽ có nhiều lỗi 40001 phải thử lại, vượt 2 giây, xem F7.3); thăm dò định kỳ (polling) sơ đồ ghế (4.000 khách mỗi giây là 4.000 yêu cầu mỗi giây chỉ để biết không có gì mới); WebSocket (cần hai chiều, không có nhu cầu, F7.5) |
| Hệ quả tích cực | Khoá đúng với mọi số bản backend vì nằm ở cơ sở dữ liệu; một cơ sở dữ liệu nên mọi thao tác không chia cắt của P08 là một giao dịch; triển khai và kiểm thử đơn giản; thay đổi cổng thanh toán hay dịch vụ email chỉ đổi một package Services |
| Hệ quả tiêu cực và cách giảm thiểu | (1) Cơ sở dữ liệu là điểm nghẽn và điểm lỗi duy nhất: giữ giao dịch giữ ghế ngắn, ít câu lệnh, khoá hẹp, giới hạn pool, đo bằng kiểm thử tải (Q-115). (2) Khoá hàng dùng chung nhiều người đọc (FOR SHARE) có thể sinh chi phí MultiXact khi nhiều giao dịch cùng giữ: giới hạn số kết nối nên số người giữ chung tối đa bằng kích thước pool (20 mỗi bản); nếu đo thấy nghẽn, thay khoá hạng 1 đến 5 bằng khoá tư vấn (advisory lock) có chế độ chia sẻ cùng thứ tự (F7.3). (3) NOTIFY không bền: máy khách tải lại sơ đồ khi nối lại (F7.5). (4) Domain gom 8 entity trong Ticketing để tránh vòng phụ thuộc, package hơi lớn: P10 chia nhỏ bên trong |
| NFR được đáp ứng | NFR-04, NFR-05, NFR-06, NFR-07, NFR-08, NFR-09, NFR-10, NFR-11, NFR-13, NFR-14, NFR-15, NFR-16, NFR-17, NFR-18 |
| Rủi ro còn mở | Q-111 (hành vi callback của cổng cụ thể: thử lại, chữ ký, đến trước khi ghi giao dịch); Q-112 (số bản backend và thước đo sẵn sàng, quyết định kiến trúc nguồn không nêu: dùng 2 bản trong triển khai mẫu, chờ Q-112); Q-113 (một ứng dụng web chung cho mọi vai trò, chờ Q-113); Q-114 (người xem mất kết nối có tính vào NFR-08, NFR-09 không); Q-115 (cấu hình hạ tầng chuẩn để đo NFR-04 đến NFR-09) |

## F4. Layer và package cấp cao

Node triển khai: Trình duyệt (khách, nhân viên) và Máy chủ ứng dụng (nhiều bản). Gọi mạng giữa hai node không là phụ thuộc package nên không ghi ở bảng này (xem F7, F10).

| PKG | Tên | Layer | Trách nhiệm | Phụ thuộc vào (PKG) | Nguồn (NFR, UC nhóm, ACT) |
|---|---|---|---|---|---|
| PKG-01 | Presentation | - | Giao diện người dùng trên trình duyệt và điểm tiếp nhận yêu cầu, callback ở máy chủ | PKG-13, PKG-14, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-26 | NFR-11 |
| PKG-02 | Application | - | Điều phối từng use case thành các thao tác không chia cắt | PKG-21, PKG-22, PKG-23, PKG-24, PKG-25, PKG-26, PKG-27, PKG-28 | UC-001 đến UC-017 |
| PKG-03 | Services | - | Dịch vụ kỹ thuật: truy cập dữ liệu, hệ thống ngoài, sự kiện thời gian thực, hẹn giờ, bảo mật | PKG-27, PKG-28 | NFR-04 đến NFR-09, NFR-15 đến NFR-18 |
| PKG-04 | Domain | - | Lớp miền và interface kho dữ liệu | PKG-27 | P08 F3 |
| PKG-05 | CustomerWeb | PKG-01 | Giao diện của khách: tra cứu phim, lịch chiếu, đặt vé, huỷ vé, lịch sử đặt vé, đăng ký | - (node Trình duyệt) | ACT-01; UC-001, UC-003, UC-004, UC-005, UC-007, UC-008 |
| PKG-06 | CounterWeb | PKG-01 | Giao diện của nhân viên quầy: bán vé, huỷ vé mua tại quầy | - (node Trình duyệt) | ACT-02; UC-005, UC-008 |
| PKG-07 | CheckInWeb | PKG-01 | Giao diện soát vé trên điện thoại hoặc máy tính bảng, đọc mã QR bằng camera | - (node Trình duyệt) | ACT-03; UC-009; NFR-11, NFR-13 |
| PKG-08 | CinemaAdminWeb | PKG-01 | Giao diện của quản lý cụm rạp: phòng chiếu, bảng giá, lịch suất chiếu, báo cáo cụm | - (node Trình duyệt) | ACT-04; UC-012, UC-013, UC-014, UC-015 |
| PKG-09 | ChainAdminWeb | PKG-01 | Giao diện của quản lý chuỗi: phim, cụm rạp, báo cáo toàn chuỗi | - (node Trình duyệt) | ACT-05; chưa có lớp P08 (UC-010, UC-011, UC-016) |
| PKG-10 | AccountAdminWeb | PKG-01 | Giao diện của quản trị viên: tài khoản nhân viên, cụm rạp, vai trò | - (node Trình duyệt) | ACT-06; chưa có lớp P08 (UC-017) |
| PKG-11 | HttpApi | PKG-01 | Tiếp nhận yêu cầu REST và kết nối đẩy sơ đồ ghế của người dùng, kiểm tra đăng nhập, chuyển thành lời gọi Application | PKG-13, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19, PKG-26 | NFR-06, NFR-08, NFR-09; node Máy chủ ứng dụng |
| PKG-12 | PaymentCallbackApi | PKG-01 | Tiếp nhận callback của cổng thanh toán và chuyển cho Application | PKG-14 | ACT-07; NFR-16; node Máy chủ ứng dụng |
| PKG-13 | SeatBooking | PKG-02 | Hiện thực giữ ghế, huỷ giữ ghế, xác nhận thu tiền mặt, hết hạn, giải phóng ghế, sơ đồ ghế và đăng ký nhận cập nhật | PKG-21, PKG-22, PKG-24, PKG-25, PKG-27, PKG-28 | UC-005; NFR-05, NFR-06, NFR-07 |
| PKG-14 | PaymentRefund | PKG-02 | Xử lý báo kết quả giao dịch và hoàn tiền qua cổng, kể cả thanh toán trễ | PKG-21, PKG-22, PKG-25, PKG-27, PKG-28 | UC-005, UC-006; NFR-16, NFR-17 |
| PKG-15 | TicketService | PKG-02 | Huỷ vé, soát vé, lịch sử đặt vé | PKG-14, PKG-21, PKG-27, PKG-28 | UC-007, UC-008, UC-009 |
| PKG-16 | ScheduleAndPricing | PKG-02 | Quản lý bảng giá, suất chiếu, sơ đồ ghế phòng chiếu | PKG-21, PKG-27, PKG-28 | UC-012, UC-013, UC-014 |
| PKG-17 | Catalog | PKG-02 | Tra cứu và quản lý phim, cụm rạp, lịch chiếu | PKG-21, PKG-27 | chưa có lớp P08 (UC-003, UC-004, UC-010, UC-011) |
| PKG-18 | Reporting | PKG-02 | Báo cáo doanh thu và tỉ lệ lấp đầy | PKG-21, PKG-27, PKG-28 | chưa có lớp P08 (UC-015, UC-016) |
| PKG-19 | AccountManagement | PKG-02 | Đăng ký khách, quản lý tài khoản nhân viên | PKG-21, PKG-26, PKG-27, PKG-28 | chưa có lớp P08 (UC-001, UC-017); NFR-01, NFR-02, NFR-03, NFR-12 |
| PKG-20 | Notification | PKG-02 | Gửi email chứa vé và email hoàn tiền từ hàng đợi, thử lại, ghi log lỗi | PKG-21, PKG-23, PKG-25, PKG-28 | ACT-08; NFR-18, BR-89 |
| PKG-21 | Persistence | PKG-03 | Hiện thực kho dữ liệu trên PostgreSQL: giao dịch, khoá dòng theo thứ tự hạng, phát NOTIFY | PKG-27, PKG-28 | NFR-04, NFR-05, NFR-06 |
| PKG-22 | PaymentGatewayClient | PKG-03 | Che cổng thanh toán sau interface: tạo giao dịch, hoàn tiền, kiểm tra chữ ký callback | - | ACT-07; NFR-15, NFR-16, NFR-17 |
| PKG-23 | EmailGatewayClient | PKG-03 | Che dịch vụ email SMTP sau interface | - | ACT-08; NFR-18 |
| PKG-24 | SeatEventHub | PKG-03 | Nhận NOTIFY của PostgreSQL và phát sự kiện đổi ghế tới các kết nối đẩy của bản backend này | PKG-28 | NFR-08, NFR-09 |
| PKG-25 | Scheduler | PKG-03 | Chạy định kỳ các công việc nền đã đăng ký, định nghĩa interface công việc cho Application hiện thực | - | NFR-07, BR-89, BR-41 |
| PKG-26 | Security | PKG-03 | Băm mật khẩu, cấp và kiểm tra mã phiên, kiểm tra vai trò | - | NFR-01, NFR-02, NFR-03, NFR-10 |
| PKG-27 | CinemaOperations | PKG-04 | Lớp miền của cụm rạp, phòng chiếu, ghế, phim, suất chiếu, bảng giá, mục giá, quản lý cụm rạp, nhân viên soát vé và interface kho dữ liệu của chúng | - | P08 F3 (9 entity) |
| PKG-28 | Ticketing | PKG-04 | Lớp miền của khách, nhân viên quầy, trạng thái ghế, lần giữ ghế, lần đặt, vé, giao dịch thanh toán, yêu cầu hoàn và interface kho dữ liệu của chúng | PKG-27 | P08 F3 (8 entity) |

Mã PKG tiếp theo cho P10: PKG-29.

Ghi chú về Domain: entity của P08 gọi lẫn nhau (Showtime gọi SeatHold, Ticket, SeatStatus ở EX-13, EX-14; SeatStatus tham chiếu Showtime). Để không có vòng giữa PKG-27 và PKG-28, PKG-27 định nghĩa interface (kiểm ghế đang giữ hoặc vé chưa huỷ của suất chiếu, tạo trạng thái ghế) và PKG-28 hiện thực chúng (realization đi từ PKG-28 tới interface ở PKG-27, cùng layer, không vòng). Customer và BoxOfficeClerk (trạng thái Tạm ở P08) đặt trong PKG-28 vì cùng tham gia kiểm BR-04 với SeatHold. P12 cụ thể hoá.

Công việc nền gọi lên Application (callback ngược): PKG-25 Scheduler định nghĩa interface công việc; PKG-13, PKG-14, PKG-20 hiện thực (realization đi xuống từ Application tới Services). Việc đăng ký hiện thực vào Scheduler làm ở hàm khởi động chương trình, ngoài các package.

## F5. Quy tắc ánh xạ lớp phân tích sang kiến trúc

Controller của giao diện (REST controller ở PKG-11, PKG-12) khác lớp control của phân tích.

| Stereotype hoặc loại lớp phân tích | Layer hoặc vai trò trong mẫu đích | Ghi chú |
|---|---|---|
| boundary giao diện người dùng (7 lớp) | Component React và kho trạng thái ở package giao diện theo tác nhân (PKG-05 đến PKG-10); phần tiếp nhận yêu cầu tương ứng là REST controller ở PKG-11 | Một form phân tích có thể thành nhiều component; không gộp hai tác nhân vào một package. Cập nhật sơ đồ ghế đến qua kết nối đẩy, thành hành động của kho trạng thái |
| boundary có Loại boundary "Kênh thông báo" | Không có trong P08 (EmailService là giao diện hệ thống) | Nếu về sau có kênh SMS hoặc thông báo đẩy, đặt cạnh PKG-23 ở Services |
| boundary giao diện hệ thống (PaymentGateway, EmailService) | Subsystem ở Services: PKG-22, PKG-23 | Che sau interface; callback của cổng đi vào qua PKG-12 và PKG-14, chữ ký kiểm bởi PKG-22 |
| boundary giao diện thiết bị | Không có | Camera của thiết bị soát vé là kênh nhập của PKG-07 (đọc mã QR trong trình duyệt), không là subsystem; gửi chuỗi mã QR tới PKG-11 |
| control | Lớp dịch vụ ứng dụng ở Application (PKG-13 đến PKG-20) | Control không giữ trạng thái chờ trong bộ nhớ qua hai yêu cầu (xem F8, A7) |
| entity (phần hành vi nghiệp vụ) | Lớp miền ở Domain: PKG-27, PKG-28 | Quy tắc BR kiểm trong entity; hạng khoá do Application lấy theo bảng F7.3 trước khi gọi entity |
| entity (phần lưu trữ) | Interface kho dữ liệu ở Domain, hiện thực ở PKG-21 Persistence | Persistence thực hiện SQL khoá dòng theo thứ tự hạng, kèm NOTIFY |

## F6. Quy tắc phụ thuộc

- Layered nới lỏng: Application được phụ thuộc Services và Domain; Services được phụ thuộc Domain. Lý do: Application dùng trực tiếp lớp miền để điều phối, đi qua Services chỉ thêm lớp trung gian. Hạn chế bổ sung: Presentation chỉ phụ thuộc Application và PKG-26 Security, không phụ thuộc Services khác và không phụ thuộc Domain.
- Layer dưới không phụ thuộc layer trên; không có mũi tên dependency hoặc realization đi lên.
- Không có vòng phụ thuộc giữa các package, kể cả vòng qua nhiều package.
- Gọi ngược lên: công việc nền do PKG-25 định nghĩa interface, PKG-13, PKG-14, PKG-20 hiện thực (realization đi xuống). Cập nhật sơ đồ ghế không cần gọi ngược: PKG-21 phát NOTIFY trong cùng giao dịch, PKG-24 nghe NOTIFY độc lập. Interface kho dữ liệu do Domain định nghĩa không thuộc mục này.
- Package phụ thuộc vào interface của subsystem (PKG-22, PKG-23), không phụ thuộc lớp bên trong.
- Lời gọi qua mạng giữa trình duyệt và máy chủ, giữa máy chủ với cổng thanh toán, dịch vụ email, cơ sở dữ liệu không là phụ thuộc package.

| Phụ thuộc (PKG --> PKG) | Hợp lệ | Quy tắc áp dụng |
|---|---|---|
| PKG-11 --> PKG-13, PKG-15, PKG-16, PKG-17, PKG-18, PKG-19 | Có | Presentation --> Application |
| PKG-11 --> PKG-26 | Có | Ngoại lệ cho phép: kiểm tra mã phiên |
| PKG-12 --> PKG-14 | Có | Presentation --> Application |
| PKG-13 --> PKG-21, PKG-22, PKG-24, PKG-25, PKG-27, PKG-28 | Có | Application --> Services, Domain (nới lỏng); PKG-25 là realization đi xuống |
| PKG-14 --> PKG-21, PKG-22, PKG-25, PKG-27, PKG-28 | Có | như trên |
| PKG-15 --> PKG-14 | Có | Cùng layer, một chiều (huỷ vé gọi hoàn tiền); PKG-14 không phụ thuộc PKG-15 |
| PKG-15 --> PKG-21, PKG-27, PKG-28 | Có | Application --> Services, Domain |
| PKG-16 --> PKG-21, PKG-27, PKG-28 | Có | như trên |
| PKG-17 --> PKG-21, PKG-27 | Có | như trên |
| PKG-18 --> PKG-21, PKG-27, PKG-28 | Có | như trên |
| PKG-19 --> PKG-21, PKG-26, PKG-27, PKG-28 | Có | như trên |
| PKG-20 --> PKG-21, PKG-23, PKG-25, PKG-28 | Có | như trên; PKG-25 là realization đi xuống |
| PKG-21 --> PKG-27, PKG-28 | Có | Services --> Domain (hiện thực interface kho dữ liệu) |
| PKG-24 --> PKG-28 | Có | Services --> Domain (kiểu sự kiện đổi ghế) |
| PKG-28 --> PKG-27 | Có | Cùng layer, một chiều; PKG-27 không phụ thuộc PKG-28 (dùng interface do PKG-28 hiện thực) |

## F7. Định hướng giao tiếp ngoài và dữ liệu

### F7.1. Giao tiếp ngoài

| ACT hoặc node khác | PKG chứa | Nguyên tắc cô lập | Rủi ro (lỗi, timeout, thay đổi API) |
|---|---|---|---|
| ACT-07 Cổng thanh toán (gọi ra: tạo giao dịch, hoàn tiền) | PKG-22 (interface cho PKG-13, PKG-14) | Application chỉ biết interface với kiểu dữ liệu thuần (mã tham chiếu lần giữ ghế, số tiền, khoá chống hoàn trùng); thời gian chờ 30 giây (BR-43, NFR-15); gọi ngoài giao dịch cơ sở dữ liệu và không giữ khoá | Cổng chậm hoặc từ chối: BR-90, BR-41; thay đổi API chỉ sửa PKG-22 (Q-111) |
| ACT-07 Cổng thanh toán (callback vào) | PKG-12 nhận; PKG-22 kiểm chữ ký; PKG-14 xử lý | Điểm vào không đăng nhập nhưng bắt buộc kiểm chữ ký và số tiền; mọi kết quả đã nhận diện trả 200 để cổng ngừng gửi lại | Cổng gửi trùng, gửi muộn, gửi trước khi ghi giao dịch (Q-111) |
| ACT-08 Dịch vụ email | PKG-23 (interface cho PKG-20) | Gửi từ hàng đợi sau khi giao dịch bán vé đã commit; không bao giờ gửi trong giao dịch | Lỗi hoặc không phản hồi: BR-89, thử lại rồi ghi log; vé vẫn hiệu lực |
| Node Trình duyệt (khách, nhân viên) | PKG-11 | REST qua HTTPS và kết nối đẩy; mã QR chỉ là chuỗi do trình duyệt đọc, máy chủ tự tra vé (NFR-14) | Ngắt kết nối khi xem sơ đồ ghế (Q-114) |

### F7.2. Dữ liệu

| Mục | Quyết định | Lý do |
|---|---|---|
| Loại cơ chế lưu trữ | Quan hệ, một cơ sở dữ liệu PostgreSQL, ghi tại một node chính | Cần giao dịch, khoá dòng, ràng buộc unique, LISTEN/NOTIFY |
| Layer truy cập dữ liệu | PKG-21 Persistence (Services); interface kho ở Domain | A4, A5 |
| Chiến lược giao dịch mức cao | Mỗi thao tác EX-nn là đúng một giao dịch, mức cô lập READ COMMITTED, khoá tường minh theo thứ tự hạng (F7.3) | NFR-05, NFR-06, BR-85 |
| Dữ liệu cần bảo vệ | Mật khẩu (băm một chiều), mã phiên, mã giao dịch; không lưu thông tin thẻ (NFR-10); mọi truy cập qua HTTPS | NFR-10, NFR-11 |
| Nguồn thời gian | Thời điểm giữ ghế, hết hạn, so sánh hết hạn đều lấy từ đồng hồ cơ sở dữ liệu (hàm clock_timestamp) tại thời điểm sau khi đã lấy được khoá | Các bản backend có thể lệch đồng hồ; xem F7.4 |

### F7.3. Hiện thực EX-01 đến EX-15 bằng PostgreSQL

Mức cô lập: READ COMMITTED (mặc định) cho mọi giao dịch. Mỗi câu SELECT trong giao dịch thấy trạng thái đã commit mới nhất; câu SELECT ... FOR UPDATE hoặc FOR SHARE chờ khoá rồi trả về phiên bản dòng mới nhất sau khi bên giữ khoá commit. Vì vậy mẫu đúng là: lấy khoá trước, đọc và kiểm điều kiện sau (quy tắc 7 của P08 F4b), không dùng kết quả đọc trước khoá để quyết định. Không dùng SERIALIZABLE vì khi 1.000 giao dịch tranh một suất chiếu, PostgreSQL sẽ huỷ phần lớn bằng lỗi 40001 và bắt thử lại, làm vượt 2 giây; không dùng REPEATABLE READ vì chờ khoá xong sẽ báo lỗi không tuần tự hoá được.

Ánh xạ hạng khoá (P08 F4b) sang câu lệnh. S là SELECT ... FOR SHARE; X là SELECT ... FOR UPDATE; mỗi lần lấy nhiều dòng cùng hạng thì SELECT ... ORDER BY ... FOR UPDATE: PostgreSQL sắp xếp rồi mới khoá nên khoá được lấy đúng thứ tự ORDER BY.

| Hạng | Lớp | Bảng và dòng bị khoá | Thứ tự trong hạng |
|---|---|---|---|
| 1 | PriceList | dòng bảng giá của cụm rạp | mã cụm rạp |
| 2 | Auditorium | dòng phòng chiếu | mã phòng chiếu tăng dần |
| 3 | Showtime | dòng suất chiếu | mã suất chiếu tăng dần |
| 4 | Customer, BoxOfficeClerk | dòng người giữ ghế | một dòng |
| 5 | SeatHold | dòng lần giữ ghế | mã tăng dần |
| 6 | SeatStatus | dòng trạng thái ghế của suất chiếu | (mã phòng chiếu,) hàng rồi số ghế tăng dần |
| 7 | PaymentTransaction | dòng giao dịch | mã tăng dần |
| 8 | Ticket | dòng vé | mã tăng dần |
| 9 | RefundRequest | dòng yêu cầu hoàn | mã tăng dần |

Mọi giao dịch lấy khoá theo hạng tăng dần, nên không thể có chu trình chờ khoá (không deadlock). Có hai lớp an toàn thêm: lock_timeout 1 giây trên giao dịch giữ ghế (Thiết kế: để nhỏ hơn ngưỡng 2 giây của NFR-06; hết thời gian thì trả "hệ thống bận" cho khách thử lại) và thử lại tối đa 2 lần khi gặp mã lỗi deadlock 40P01 (chỉ phòng sai thứ tự, không kỳ vọng xảy ra). Khoá chỉ biết được dòng cần lấy sau khi đã lấy khoá thấp hơn (ví dụ lần giữ ghế cũ của người giữ ghế) vẫn lấy theo thứ tự tăng, nên quy tắc là lấy tăng dần, không bắt buộc lấy hết từ đầu.

Từng thao tác:

| ID | Cơ chế PostgreSQL | Vì sao đúng |
|---|---|---|
| EX-01 | Một giao dịch. Khoá: PriceList S, Auditorium S (đọc loại phòng hiện tại), Showtime S, người giữ ghế X, SeatStatus của các ghế chọn X theo (hàng, số ghế). Sau khoá: kiểm đã mở bán, suất chiếu và phòng chưa đổi, người giữ ghế không có lần giữ ghế chưa kết thúc, mọi ghế đang Trống; rồi INSERT lần giữ ghế (expiry_time = clock_timestamp() + 10 phút), UPDATE các SeatStatus sang Đang được giữ kèm khoá liên kết hiện tại (current_hold_id), chốt giá. Có ghế không Trống thì ROLLBACK, không để lại gì | Showtime chỉ lấy S theo ghi chú hạng 3 của P08 F4b: EX-13, EX-14 lấy X nên vẫn loại trừ với EX-01 (X-03, X-08), nhưng nhiều EX-01 cùng suất chiếu chạy song song. Loại trừ giữa các EX-01 chuyển xuống khoá X từng SeatStatus: hai yêu cầu có ghế chung thì yêu cầu sau chờ, khi được khoá đọc lại trạng thái đã đổi và bị từ chối (X-01, BR-09); hai yêu cầu không chung ghế không cản nhau. Tất cả hoặc không ghế nào do một giao dịch và ROLLBACK (BR-07). Mỗi ghế có đúng một dòng SeatStatus nên số ghế giữ cộng đã bán không thể vượt sức chứa (NFR-05) |
| EX-01 (BR-04) | Khoá dòng người giữ ghế X (hạng 4) tuần tự hoá mọi EX-01 của cùng người xuyên suất chiếu (X-02). Lần giữ ghế chưa kết thúc cũ mà đã quá expiry_time được chuyển Hết hạn ngay trong giao dịch (khoá hạng 5 sau hạng 4) để BR-04 coi là đã kết thúc. Thêm chỉ mục unique từng phần trên lần giữ ghế (một cho khách, một cho nhân viên quầy) với điều kiện trạng thái Đang giữ | Chỉ mục unique là lưới an toàn: nếu vì lỗi lập trình hai giao dịch cùng tạo lần giữ ghế cho một người thì một giao dịch bị cơ sở dữ liệu từ chối |
| EX-02 | Một giao dịch. Tra không khoá mã lần giữ ghế từ mã tham chiếu hoặc mã giao dịch (bất biến). Khoá: SeatHold X, SeatStatus của lần giữ ghế X (SELECT ... WHERE current_hold_id = mã lần giữ ghế ORDER BY hàng, số ghế FOR UPDATE), PaymentTransaction X. Sau khoá, so thời điểm hiện tại clock_timestamp() với expiry_time, đọc processed và trạng thái lần giữ ghế, rồi quyết định theo bảng F7.6 | Ba khoá theo hạng 5, 6, 7. Hai báo cùng một giao dịch hoặc báo với hết hạn, huỷ giữ ghế cùng lúc cùng tranh khoá SeatHold nên xử lý tuần tự; báo sau thấy trạng thái cuối do báo trước để lại (X-09, X-10, BR-85, BR-86). Ghi nhận thanh toán trễ và INSERT yêu cầu hoàn nằm cùng giao dịch nên không có giao dịch đã thu tiền mà thiếu yêu cầu hoàn |
| EX-03 | Như EX-02 không có PaymentTransaction: SeatHold X, SeatStatus X; so clock_timestamp() với expiry_time rồi bán hoặc từ chối | BR-44 |
| EX-04 | SELECT lần giữ ghế FOR UPDATE; UPDATE trạng thái chỉ khi còn Đang giữ, trong đó trạng thái đích là Hết hạn nếu expiry_time đã qua, ngược lại là trạng thái được yêu cầu | Chỉ một trạng thái cuối; thao tác đến sau thấy trạng thái cuối nên không đổi (X-10); quá hạn thì chuyển Hết hạn trước mà không phụ thuộc công việc nền |
| EX-05 | Giao dịch riêng, sau EX-04 hoặc theo công việc quét. SeatHold S rồi một câu UPDATE seat_status SET Trống, current_hold_id = NULL WHERE id IN (SELECT id ... WHERE current_hold_id = mã lần giữ ghế ORDER BY hàng, số ghế FOR UPDATE) AND lần giữ ghế đã ở trạng thái cuối | Điều kiện current_hold_id = mã lần giữ ghế được kiểm lại sau khi chờ khoá (READ COMMITTED kiểm lại vị từ trên dòng mới), nên ghế đã được giữ lại cho lần giữ ghế khác hoặc đã bán thì không bị đổi (R-63, X-18). Chạy hai lần cho kết quả như một lần (chạy lặp an toàn) |
| EX-06 | SeatStatus X (hạng 6) rồi Ticket S (hạng 8); UPDATE chỉ khi vé hiện tại (current_ticket_id) của ghế là vé đã huỷ đang xử lý | Điều kiện liên kết hiện tại như EX-05 (R-64, X-18); không lồng với EX-07, EX-09 (quy tắc 4) |
| EX-07 | Ticket X; kiểm chưa huỷ, chưa sử dụng; UPDATE sang Đã huỷ | X-14, X-15: hai yêu cầu cùng vé chỉ một thành công |
| EX-08 | Ticket X; kiểm theo thứ tự BR-33; UPDATE sang Đã sử dụng | X-14, X-15 |
| EX-09 | PaymentTransaction X; kiểm refunded_total + số tiền hoàn <= số đã thanh toán; INSERT yêu cầu hoàn; UPDATE refunded_total = refunded_total + số tiền (phép cộng nằm trong chính câu UPDATE, không đọc rồi ghi lại). Thêm ràng buộc CHECK refunded_total <= paid_amount | Hai vé của cùng giao dịch huỷ đồng thời được tuần tự hoá bởi khoá dòng giao dịch, không mất cập nhật (X-16); CHECK là lưới an toàn |
| EX-10 | RefundRequest X (cộng Ticket S khi hoàn tiền mặt). Chia ba giao dịch ngắn: ghi lần gửi (commit), gọi cổng 30 giây ngoài giao dịch, ghi kết quả. Khoá chống hoàn trùng là cột có ràng buộc UNIQUE và được gửi nguyên cho cổng ở mọi lần thử lại | X-17, BR-43; không giữ khoá trong lúc chờ cổng |
| EX-11 | PriceList X; so mốc thay đổi của mục giá với mốc lúc hiển thị; ghi mục giá và mốc | X-05: bên sau thấy mốc đã đổi và bị từ chối |
| EX-12 | PriceList X; Auditorium S theo mã tăng dần; Showtime S của cụm rạp; kiểm không suất chiếu chưa chiếu đang dùng mục giá; xoá mục giá | X-04, X-06: EX-01 giữ PriceList S nên không xen vào |
| EX-13 | PriceList S, Auditorium X (hai phòng theo mã tăng dần), Showtime X, SeatHold S của suất chiếu, SeatStatus X (theo phòng chiếu, hàng, số ghế; chỉ khi lập mới hoặc đổi phòng), Ticket S; kiểm rồi ghi trong một giao dịch | X-03, X-07, X-08, X-11, X-19, X-20, X-23: Showtime X loại trừ mọi EX-01 cùng suất chiếu |
| EX-14 | Showtime X, SeatHold S, Ticket S; đánh dấu Đã xoá | X-03, X-08 |
| EX-15 | PriceList S, Auditorium X, Showtime S của phòng, SeatStatus X của suất chiếu chưa mở bán | X-19, X-21; khung chờ P07 của UC-012 |

Dung lượng và rủi ro của F7.3 (Thiết kế, ước lượng cần kiểm bằng kiểm thử tải theo Q-115): giao dịch giữ ghế gồm khoảng 8 câu lệnh trên các dòng đã có chỉ mục khoá chính, một lần đi tới cơ sở dữ liệu; pool 20 kết nối mỗi bản backend (Thiết kế: cơ sở dữ liệu chịu được hàng trăm kết nối nhưng nhiều hơn số lõi CPU thì không nhanh hơn). Hàng đợi chờ khoá sinh ra ở pool và ở các ghế tranh chấp, không sinh ra ở suất chiếu. Ghế đẹp bị chọn chung là điểm nóng thật: yêu cầu thua tranh chấp được từ chối ngay khi thấy ghế đã giữ nên không chờ lâu. Nếu kiểm thử tải cho thấy chờ ở khoá S của PriceList, Auditorium, Showtime (chi phí MultiXact), thay các khoá hạng 1 đến 5 bằng khoá tư vấn: pg_advisory_xact_lock_shared và pg_advisory_xact_lock với khoá một số 64 bit gồm hạng ở các bit cao và mã định danh ở các bit thấp (không trùng khoá, thứ tự tăng giữ nguyên); khoá SeatStatus giữ là khoá dòng.

### F7.4. Giải phóng ghế hết hạn và vì sao hết hạn tính theo thời điểm hết hạn

Hết hạn là sự thật được tính, không phải sự kiện được chạy: mỗi lần giữ ghế lưu expiry_time = thời điểm giữ thành công + 10 phút (BR-10), lấy từ đồng hồ cơ sở dữ liệu. Mọi thao tác quyết định theo hết hạn (EX-02, EX-03, EX-04, BR-04 trong EX-01, kiểm BR-53 của EX-13, EX-14) so clock_timestamp() với cột expiry_time sau khi đã lấy khoá lần giữ ghế. Do đó một lần giữ ghế còn nhãn Đang giữ nhưng đã quá expiry_time được xử lý như Hết hạn (đúng BR-14, BR-44, BR-53, bảng "Hết hạn trước" của P08 F4c) dù công việc nền chạy trễ 5 giây hay 50 giây. Công việc nền chỉ quyết định khi nào ghế được trả về trống (NFR-07), không quyết định kết quả thanh toán hay xác nhận thu tiền.

Công việc nền (PKG-25 Scheduler gọi PKG-13) chạy mỗi 10 giây trên mọi bản backend (Thiết kế: chu kỳ 10 giây cộng thời gian xử lý nhỏ hơn nhiều so với hạn 60 giây, chịu được vài chu kỳ bị trễ hoặc một bản dừng):

1. Quét hết hạn (EX-04): chọn tối đa 200 lần giữ ghế có trạng thái Đang giữ và expiry_time <= clock_timestamp(), sắp theo expiry_time, bằng SELECT ... FOR UPDATE SKIP LOCKED. Mỗi lần giữ ghế một giao dịch: chuyển Hết hạn. SKIP LOCKED để các bản backend chia việc, không chờ nhau.
2. Quét giải phóng (EX-05): chọn các lần giữ ghế có trạng thái cuối khác Đã hoàn tất mà vẫn còn SeatStatus có current_hold_id trỏ tới (chỉ mục từng phần trên current_hold_id không rỗng), mỗi lần giữ ghế một giao dịch EX-05. Bước này cũng sửa các trường hợp khác: khách huỷ giữ ghế, thanh toán thất bại mà tiến trình chết giữa EX-04 và EX-05.

Vì sao chạy lặp an toàn nhờ liên kết currentHold của P08 (R-63): EX-04 chỉ đổi lần giữ ghế đang Đang giữ; EX-05 chỉ đổi SeatStatus có current_hold_id đúng bằng lần giữ ghế đang xử lý. Hai bản backend quét chồng nhau, quét hai lần, hoặc khởi động lại giữa chừng: lần sau thấy liên kết đã xoá hoặc trỏ lần giữ ghế khác nên không đổi gì, không trả nhầm ghế vừa được giữ lại cho người khác. Không có bộ đếm giờ trong bộ nhớ nên khởi động lại không làm mất lần giữ ghế nào. Chạy được cả khi suất chiếu Đã xoá vì chỉ dùng SeatStatus đã có (EX-14, BR-58).

Độ trễ: tối đa khoảng 10 giây chờ chu kỳ cộng xử lý, thấp hơn 60 giây của NFR-07 và NFR-09 tính từ lúc ghế trống (sơ đồ cập nhật sau đó trong 3 giây, F7.5). Khoảng giữa thời điểm hết hạn và lúc ghế trống, người khác chưa chọn được ghế (BR-07, BR-53) và sơ đồ vẫn hiện ghế đang giữ, đúng mô tả NFR-09.

### F7.5. Cập nhật sơ đồ ghế real-time trong 3 giây

Chọn Server-Sent Events (SSE) thay WebSocket. Lý do gắn tiêu chí: sơ đồ ghế chỉ cần chiều máy chủ --> trình duyệt (khách vẫn dùng REST để giữ ghế); SSE chạy trên HTTP thường, qua bộ cân bằng tải và proxy không cần cấu hình nâng cấp giao thức, trình duyệt tự nối lại, Go phục vụ mỗi kết nối bằng một goroutine; WebSocket thêm giao thức hai chiều mà không có nhu cầu. Thăm dò định kỳ bị loại ở F3.

Luồng:

1. Trình duyệt mở trang sơ đồ ghế của suất chiếu: gọi REST lấy ảnh chụp đầy đủ trạng thái ghế, rồi mở kết nối SSE cho suất chiếu đó. Sơ đồ ghế công khai (chưa đăng nhập vẫn xem) nên kết nối không cần đăng nhập.
2. Persistence, ngay trong giao dịch đổi trạng thái ghế (EX-01, EX-02, EX-03, EX-05, EX-06, EX-13), gọi pg_notify trên kênh seat_changes với nội dung nhỏ: mã suất chiếu và danh sách (vị trí ghế, trạng thái mới). PostgreSQL chỉ chuyển NOTIFY khi giao dịch commit, và bỏ nếu rollback, nên không bao giờ đẩy trạng thái chưa commit.
3. Mỗi bản backend giữ một kết nối LISTEN riêng (ngoài pool) trong PKG-24; nhận NOTIFY, gom theo suất chiếu và ghi sự kiện tới mọi kết nối SSE của suất chiếu đó ở bản mình. Nhờ đó nhiều bản backend vẫn đẩy đủ: bản nào xử lý yêu cầu, mọi bản đều nhận sự kiện qua cơ sở dữ liệu, không cần Redis.
4. Trình duyệt đưa sự kiện vào kho trạng thái và vẽ lại ghế.

Ngân sách thời gian cho 3 giây: commit --> NOTIFY --> goroutine nghe --> ghi tới tối đa 1.000 kết nối của một suất chiếu cỡ mili giây đến vài chục mili giây trong mạng nội bộ, xa dưới 3 giây (cần kiểm trong kiểm thử tải). Một lần giữ nhóm 8 ghế là một sự kiện, không phải 8.

Độ tin cậy: NOTIFY không bền và có thể mất khi kết nối LISTEN đứt. Giảm thiểu (Thiết kế): khi PKG-24 nối lại LISTEN thì đóng mọi kết nối SSE của bản đó để trình duyệt nối lại và tải lại ảnh chụp đầy đủ; mỗi 15 giây máy chủ gửi dòng nhịp tim để phát hiện kết nối chết và giữ qua proxy (proxy phải tắt bộ đệm và có thời gian chờ đọc lớn hơn 15 giây); trình duyệt tải lại ảnh chụp khi SSE nối lại và tự làm mới 60 giây một lần. Người xem mất mạng phía trình duyệt không được bảo đảm 3 giây trong thời gian mất kết nối (Q-114). Dung lượng: 4.000 kết nối SSE chia cho các bản backend; cần nâng giới hạn số tệp mở và dùng HTTP/2 ở bộ cân bằng tải để không vướng giới hạn 6 kết nối mỗi nguồn của HTTP/1.1.

### F7.6. Tiếp nhận callback của cổng thanh toán idempotent

Điểm vào PKG-12 làm theo thứ tự:

1. Kiểm chữ ký và số tiền theo cách của cổng (PKG-22, Q-111). Sai chữ ký trả 4xx và không ghi gì.
2. Chuyển cho PKG-14 chạy EX-02 trong một giao dịch như F7.3. Khoá SeatHold X làm mọi báo của cùng một lần giữ ghế tuần tự, kể cả hai báo giống hệt đến cùng lúc ở hai bản backend: bản chờ sau thấy giao dịch đã xử lý.
3. Quyết định dưới khoá, theo thời điểm hiện tại so với expiry_time (F7.4) và trạng thái lần giữ ghế:

| Điều kiện sau khi có khoá | Kết quả | Mã trả cho cổng |
|---|---|---|
| Báo thành công, giao dịch chưa xử lý, lần giữ ghế Đang giữ và chưa quá expiry_time | Bán ghế (SeatStatus Đã bán, xoá current_hold_id), lần giữ ghế Đã hoàn tất, tạo lần đặt, vé, đánh dấu giao dịch đã xử lý, ghi hàng đợi email vé | 200 |
| Báo thành công, giao dịch chưa xử lý, lần giữ ghế Hết hạn, Đã huỷ, Thanh toán thất bại hoặc quá expiry_time hoặc giao dịch thứ hai | Chuyển Hết hạn trước nếu cần; ghi thanh toán trễ và tạo yêu cầu hoàn toàn bộ cùng khoá chống hoàn trùng; ghi hàng đợi gửi hoàn tiền và email | 200 |
| Báo thành công, giao dịch đã xử lý | Báo trùng: tăng duplicateReportCount, không tạo vé, không hoàn thêm | 200 |
| Báo thất bại | Chỉ ghi nhận; lần giữ ghế Đang giữ chuyển Thanh toán thất bại rồi EX-05 | 200 |
| Không tìm thấy giao dịch hoặc lần giữ ghế | Ghi log để xử lý thủ công (GL-11, ngoài phạm vi); nếu có thể là PaymentTransaction chưa kịp ghi thì trả 5xx để cổng gửi lại (Q-111) | 200 hoặc 5xx |
| Lỗi tạm thời của cơ sở dữ liệu, hết thời gian chờ khoá | Giao dịch rollback hoàn toàn | 5xx, cổng gửi lại |

Tính idempotent đến từ hai tầng: trạng thái dưới khoá (xử lý lần hai thấy cờ đã xử lý) và ràng buộc UNIQUE làm lưới an toàn (một lần đặt cho mỗi lần giữ ghế, một vé cho mỗi ghế đã bán, một yêu cầu hoàn cho mỗi khoá chống hoàn trùng). Gửi lại do 5xx an toàn vì giao dịch đã rollback toàn bộ. Việc gọi cổng hoàn tiền và gửi email xảy ra sau commit, qua hàng đợi (F7.7), nên cổng không bị chặn và khoá không bị giữ lâu.

### F7.7. Hàng đợi gửi ngoài và giao tiếp chậm

Việc gửi email và gửi hoàn tiền qua cổng ghi thành dòng trong bảng hàng đợi gửi (outbox) cùng giao dịch tạo ra chúng; Scheduler gọi PKG-14 (hoàn tiền) và PKG-20 (email) mỗi 10 giây, chọn dòng đến hạn bằng SELECT ... FOR UPDATE SKIP LOCKED. Lỗi hoặc không trả lời 30 giây thì tăng số lần thử và hẹn lại sau 1, 5, 15 phút, tối đa 3 lần thử lại rồi ghi log lỗi (BR-41, BR-89; Thiết kế: lùi dần để không dồn tải lên dịch vụ đang lỗi). Hoàn tiền dùng cùng khoá chống hoàn trùng ở mọi lần thử (BR-43). Giao dịch UC-008 giải phóng ghế độc lập với kết quả hoàn (BR-42, quy tắc 4 của P08 F4b). Lần tạo giao dịch thanh toán lúc khách xác nhận (UC-005 bước 10) gọi cổng trực tiếp ngoài giao dịch, chờ 30 giây (BR-90), rồi ghi PaymentTransaction dưới khoá SeatHold X.

### F7.8. Nhiều bản backend

Mọi bản giống nhau và không giữ trạng thái giữa hai yêu cầu. Khoá, thời điểm hết hạn, hàng đợi gửi, liên kết hiện tại đều nằm trong PostgreSQL, nên bất kỳ bản nào xử lý bất kỳ yêu cầu nào cũng cùng thấy một thứ tự loại trừ. Công việc nền chạy trên mọi bản và chia việc bằng SKIP LOCKED (F7.4), không cần bầu chủ. Chỉ phần phát sự kiện cần khớp nối giữa các bản, do NOTIFY đảm nhận (F7.5). Bộ cân bằng tải không cần dính phiên (session affinity); mã phiên nằm trong token tự kiểm chứng được. Số bản triển khai mẫu: 2 (Q-112).

## F8. Kiểm tra chứa mô hình phân tích

| Nhóm lớp phân tích | Số lớp | Layer, PKG đích | Vấn đề |
|---|---|---|---|
| boundary giao diện người dùng | 7 | PKG-05 (BookTicketsForm, CancelTicketForm), PKG-06 (CounterBookTicketsForm, CounterCancelTicketForm), PKG-07 (CheckTicketForm), PKG-08 (ManagePriceListForm, ScheduleShowtimesForm); phần nhận yêu cầu ở PKG-11 | Không |
| boundary giao diện hệ thống | 2 | PKG-22 (PaymentGateway), PKG-23 (EmailService) | Không |
| control | 6 | PKG-13 (BookTicketsController), PKG-14 (PaymentReportController), PKG-15 (CancelTicketController, CheckTicketController), PKG-16 (ManagePriceListController, ScheduleShowtimesController) | BookTicketsController giữ trạng thái chờ hết hạn: không được giữ trong bộ nhớ, xem Đề xuất sửa |
| entity (Hoạt động và Tạm) | 17 | PKG-27 (Cinema, Auditorium, Seat, Movie, Showtime, PriceList, PriceEntry, CinemaManager, TicketChecker: 9 lớp), PKG-28 (Customer, BoxOfficeClerk, SeatStatus, SeatHold, Booking, Ticket, PaymentTransaction, RefundRequest: 8 lớp) | Showtime, SeatHold, Ticket, PriceList, PaymentTransaction gọi chéo nhau (P08 Vấn đề còn mở 2, 6); xử lý bằng interface ở F4, P12 cụ thể hoá |
| Nhóm chưa phân tích | 0 | PKG-17 Catalog (UC-003, UC-004, UC-010, UC-011), PKG-18 Reporting (UC-015, UC-016), PKG-19 AccountManagement (UC-001, UC-017), PKG-15 (UC-007), PKG-16 (UC-012), PKG-09 ChainAdminWeb, PKG-10 AccountAdminWeb | Chưa có lớp P08; có package theo nhóm chức năng |

Tổng 32 lớp (7 + 2 + 6 + 17), không lớp nào "Gộp vào".

Kiểm control giữ trạng thái giữa hai sự kiện của tác nhân: (1) chờ hết hạn giữ ghế: nằm trong cột expiry_time và công việc nền, không trong bộ nhớ; (2) chờ cổng trả lời 30 giây: nằm trong một yêu cầu đang xử lý, nếu tiến trình chết thì dòng hàng đợi gửi đã ghi lần thử và được thử lại; (3) chờ kết quả giao dịch của cổng: nằm ở trạng thái lần giữ ghế trong cơ sở dữ liệu. Kiến trúc cho nhiều bản và khởi động lại nên các trạng thái này phải ở cơ sở dữ liệu.

## F9. Package diagram

File diagrams/P09-package-layers.drawio. Layer xếp chồng, Presentation trên cùng, Domain dưới cùng; layer là container, package con nằm trong layer.

a) Bảng Node

| ID (PKG) | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| PKG-01 | Layer | Presentation | «layer» | - | |
| PKG-02 | Layer | Application | «layer» | - | |
| PKG-03 | Layer | Services | «layer» | - | |
| PKG-04 | Layer | Domain | «layer» | - | |
| PKG-05 | Package | CustomerWeb | - | PKG-01 | Trình duyệt |
| PKG-06 | Package | CounterWeb | - | PKG-01 | Trình duyệt |
| PKG-07 | Package | CheckInWeb | - | PKG-01 | Trình duyệt |
| PKG-08 | Package | CinemaAdminWeb | - | PKG-01 | Trình duyệt |
| PKG-09 | Package | ChainAdminWeb | - | PKG-01 | Trình duyệt |
| PKG-10 | Package | AccountAdminWeb | - | PKG-01 | Trình duyệt |
| PKG-11 | Package | HttpApi | - | PKG-01 | Máy chủ |
| PKG-12 | Package | PaymentCallbackApi | - | PKG-01 | Máy chủ |
| PKG-13 | Package | SeatBooking | - | PKG-02 | |
| PKG-14 | Package | PaymentRefund | - | PKG-02 | |
| PKG-15 | Package | TicketService | - | PKG-02 | |
| PKG-16 | Package | ScheduleAndPricing | - | PKG-02 | |
| PKG-17 | Package | Catalog | - | PKG-02 | |
| PKG-18 | Package | Reporting | - | PKG-02 | |
| PKG-19 | Package | AccountManagement | - | PKG-02 | |
| PKG-20 | Package | Notification | - | PKG-02 | |
| PKG-21 | Package | Persistence | - | PKG-03 | |
| PKG-22 | Package | PaymentGatewayClient | - | PKG-03 | |
| PKG-23 | Package | EmailGatewayClient | - | PKG-03 | |
| PKG-24 | Package | SeatEventHub | - | PKG-03 | |
| PKG-25 | Package | Scheduler | - | PKG-03 | |
| PKG-26 | Package | Security | - | PKG-03 | |
| PKG-27 | Package | CinemaOperations | - | PKG-04 | |
| PKG-28 | Package | Ticketing | - | PKG-04 | |

b) Bảng Edge. Loại Dependency (mũi tên nét đứt đầu mở). Cạnh có nhãn «realize» là realization (nét đứt, đầu tam giác rỗng) đi xuống tới interface.

| ID | Nguồn | Đích | Loại quan hệ | Nhãn | Ghi chú |
|---|---|---|---|---|---|
| E-01 | PKG-11 | PKG-13 | Dependency | - | |
| E-02 | PKG-11 | PKG-15 | Dependency | - | |
| E-03 | PKG-11 | PKG-16 | Dependency | - | |
| E-04 | PKG-11 | PKG-17 | Dependency | - | |
| E-05 | PKG-11 | PKG-18 | Dependency | - | |
| E-06 | PKG-11 | PKG-19 | Dependency | - | |
| E-07 | PKG-11 | PKG-26 | Dependency | - | Kiểm tra mã phiên |
| E-08 | PKG-12 | PKG-14 | Dependency | - | |
| E-09 | PKG-13 | PKG-21 | Dependency | - | |
| E-10 | PKG-13 | PKG-22 | Dependency | - | |
| E-11 | PKG-13 | PKG-24 | Dependency | - | Đăng ký nhận cập nhật |
| E-12 | PKG-13 | PKG-25 | Realization | «realize» | Công việc hết hạn |
| E-13 | PKG-13 | PKG-27 | Dependency | - | |
| E-14 | PKG-13 | PKG-28 | Dependency | - | |
| E-15 | PKG-14 | PKG-21 | Dependency | - | |
| E-16 | PKG-14 | PKG-22 | Dependency | - | |
| E-17 | PKG-14 | PKG-25 | Realization | «realize» | Công việc gửi hoàn tiền |
| E-18 | PKG-14 | PKG-27 | Dependency | - | |
| E-19 | PKG-14 | PKG-28 | Dependency | - | |
| E-20 | PKG-15 | PKG-14 | Dependency | - | Huỷ vé gọi hoàn tiền |
| E-21 | PKG-15 | PKG-21 | Dependency | - | |
| E-22 | PKG-15 | PKG-27 | Dependency | - | |
| E-23 | PKG-15 | PKG-28 | Dependency | - | |
| E-24 | PKG-16 | PKG-21 | Dependency | - | |
| E-25 | PKG-16 | PKG-27 | Dependency | - | |
| E-26 | PKG-16 | PKG-28 | Dependency | - | |
| E-27 | PKG-17 | PKG-21 | Dependency | - | |
| E-28 | PKG-17 | PKG-27 | Dependency | - | |
| E-29 | PKG-18 | PKG-21 | Dependency | - | |
| E-30 | PKG-18 | PKG-27 | Dependency | - | |
| E-31 | PKG-18 | PKG-28 | Dependency | - | |
| E-32 | PKG-19 | PKG-21 | Dependency | - | |
| E-33 | PKG-19 | PKG-26 | Dependency | - | |
| E-34 | PKG-19 | PKG-27 | Dependency | - | |
| E-35 | PKG-19 | PKG-28 | Dependency | - | |
| E-36 | PKG-20 | PKG-21 | Dependency | - | |
| E-37 | PKG-20 | PKG-23 | Dependency | - | |
| E-38 | PKG-20 | PKG-25 | Realization | «realize» | Công việc gửi email |
| E-39 | PKG-20 | PKG-28 | Dependency | - | |
| E-40 | PKG-21 | PKG-27 | Dependency | - | |
| E-41 | PKG-21 | PKG-28 | Dependency | - | |
| E-42 | PKG-24 | PKG-28 | Dependency | - | |
| E-43 | PKG-28 | PKG-27 | Dependency | - | Cùng layer, một chiều |

Không có cạnh đi lên. Bốn cạnh Realization và E-43 là các chỗ dùng interface đảo phụ thuộc (A5).

## F10. Deployment diagram

File diagrams/P09-deployment.drawio. Hệ thống có từ hai node thực thi.

| ID | Loại | Nhãn | Artifact |
|---|---|---|---|
| N-01 | Node | Trình duyệt web (điện thoại, máy tính bảng, máy tính) | «artifact» Gói React SPA (PKG-05 đến PKG-10) |
| N-02 | Node | Bộ cân bằng tải và máy chủ tệp tĩnh (kết thúc HTTPS) | «artifact» Gói React SPA dạng tệp tĩnh |
| N-03 | Node | Máy chủ ứng dụng (1 đến N bản giống nhau) | «artifact» Chương trình backend Go (PKG-11 đến PKG-26 và mọi package Domain PKG-27, PKG-28 mà các package đó phụ thuộc) |
| N-04 | Node | Máy chủ cơ sở dữ liệu | «artifact» PostgreSQL |
| N-05 | Node | Cổng thanh toán (hệ thống ngoài, sandbox) | - |
| N-06 | Node | Dịch vụ email SMTP (hệ thống ngoài) | - |

Mọi package mà một package trong artifact N-03 phụ thuộc đều có trong N-03; các package PKG-05 đến PKG-10 không phụ thuộc package nào nên chỉ cần ở N-01.

| ID | Nguồn | Đích | Nhãn giao thức |
|---|---|---|---|
| C-01 | N-01 | N-02 | Internet, HTTPS (tải SPA, REST, SSE) |
| C-02 | N-02 | N-03 | Mạng nội bộ, HTTP |
| C-03 | N-03 | N-04 | Mạng nội bộ, giao thức PostgreSQL (giao dịch, LISTEN/NOTIFY) |
| C-04 | N-03 | N-05 | Internet, HTTPS (tạo giao dịch, hoàn tiền) |
| C-05 | N-05 | N-02 | Internet, HTTPS (callback kết quả giao dịch) |
| C-06 | N-03 | N-06 | Internet, SMTP mã hoá |

## F11. Cập nhật hồ sơ dự án

```text
| NEN_TANG | Web app responsive |
| CONG_NGHE | Back-end Go (net/http, pgx), front-end React (SPA), PostgreSQL 15 trở lên; không Redis |
```

Trạng thái: Đã chốt bởi người dùng.

Q-nn mà lựa chọn công nghệ phụ thuộc: Không có.

Chấp nhận khối này là chọn công nghệ đã chốt; các Q liệt kê ở mục Câu hỏi mở vẫn mở nhưng không chặn việc chọn công nghệ. Cập nhật project-profile.md mục 3 trước khi chạy P10 (bước này không tự sửa project-profile.md).

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-111 | Cổng thanh toán sandbox cụ thể là gì và nó có: (a) cách ký callback nào; (b) chính sách gửi lại callback khi nhận 5xx (số lần, khoảng cách); (c) có thể gửi callback trước khi hệ thống kịp ghi giao dịch (sau khi nhận kết quả tạo giao dịch) không; (d) hỗ trợ khoá chống hoàn trùng ở API hoàn tiền không? (Chờ người dùng cho biết cổng) | PKG-12, PKG-22, EX-02, EX-10; F7.6 | HE_THONG_NGOAI và NFR-15 đến NFR-17 không nêu tên cổng và giao thức |
| Q-112 | Số bản backend khi triển khai và có yêu cầu sẵn sàng (thời gian dừng cho phép, khôi phục sau lỗi cơ sở dữ liệu) không? Đã dùng 2 bản backend, 1 node PostgreSQL không nhân bản trong triển khai mẫu (quyết định kiến trúc nguồn không nêu, A1). Chờ Q-112 | F10, N-03, F1 dòng 10 | P06 không có NFR sẵn sàng |
| Q-113 | Khách và nhân viên dùng một ứng dụng web chung với đường dẫn theo vai trò, hay tách thành hai ứng dụng web (khách; nhân viên)? Đã dùng một ứng dụng web chung có 6 package giao diện theo tác nhân (quyết định kiến trúc nguồn không nêu, A1). Chờ Q-113 | PKG-05 đến PKG-10, N-01, N-02 | P01 không nêu số loại client; NFR-11 chỉ nêu trình duyệt |
| Q-114 | NFR-08, NFR-09 có áp dụng cho người xem tạm mất kết nối mạng hoặc mất kết nối đẩy không? Đã hiểu: ngưỡng 3 giây áp dụng khi kết nối còn; sau khi nối lại, sơ đồ được tải lại đầy đủ | PKG-24, F7.5 | NFR-08 "đo trên mọi người đang xem" không nêu trường hợp mất kết nối |
| Q-115 | Cấu hình máy chủ ứng dụng, máy chủ cơ sở dữ liệu và mạng chuẩn dùng để đo NFR-04 đến NFR-09 là gì? Khả năng đạt 2 giây ở 1.000 khách cùng một suất chiếu (NFR-05, NFR-06) phụ thuộc cấu hình này; kích thước pool và số bản backend ở F7.3 là ước lượng thiết kế | F7.3, F10, kiểm thử tải X2 | NFR-04, NFR-05 nêu số khách nhưng không nêu hạ tầng |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | F4b (thiếu thao tác ghi PaymentTransaction của UC-005 bước 10) | Thao tác ghi PaymentTransaction sau khi cổng tạo giao dịch làm đổi lần giữ ghế, nhưng chưa có EX và chưa có hạng khoá; nếu không tuần tự với hết hạn, EX-02 có thể thấy lần giữ ghế đã Hết hạn mà chưa có giao dịch | Thêm EX cho recordPaymentTransaction: SeatHold X (hạng 5), kiểm còn Đang giữ, INSERT giao dịch. Nếu cổng báo kết quả trước khi giao dịch được ghi thì cổng gửi lại theo Q-111 |
| P07 | UC-005, AC-C-BookTicketsController.requestSeatHold (chờ hết hạn) | Bước chờ hết hạn mô tả như control đang chờ trong phiên | Ghi rõ trạng thái chờ nằm ở expiryTime của SeatHold và công việc nền, control không giữ bộ đếm giờ (A7, NFR-07) |
| P08 | F3, AC-E-Showtime (checkNoActiveSeatHold hoặc tương đương, tạo SeatStatus) | Showtime gọi SeatHold, Ticket, SeatStatus còn SeatStatus tham chiếu Showtime nên tạo vòng phụ thuộc ở mức package | P12 dùng interface do CinemaOperations định nghĩa, Ticketing hiện thực (F4) |

## Vấn đề còn mở

1. Presentation có 8 package (6 giao diện theo tác nhân, 2 phía máy chủ), sát ngưỡng 8 của mức hợp lý; giữ vì gộp giao diện của hai tác nhân là lỗi đã nêu ở A4.
2. Các con số trong F7.3 (pool 20, lock_timeout 1 giây, chu kỳ 10 giây, nhịp tim 15 giây, lùi 1, 5, 15 phút) là quyết định thiết kế (C1.7), chưa được đo; khả năng đạt NFR-05, NFR-06 ở 95% lần cần kiểm bằng kiểm thử tải trên cấu hình của Q-115.
3. Ngưỡng Showtime S thay X cho EX-01 là phương án thu hẹp mà P08 F4b hạng 3 cho phép; P12 phải giữ EX-13, EX-14 lấy Showtime X.
4. Cạnh E-11 (SeatBooking --> SeatEventHub) chỉ phục vụ đăng ký nhận cập nhật; phát sự kiện nằm ở PKG-21.
5. Sơ đồ deployment không vẽ máy tính tại quầy và thiết bị soát vé riêng vì đều là trình duyệt web ở N-01 (P01 Mục 1).
