# P07 - Phân tích use case UC-015 Xem báo cáo cụm rạp - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P04-uc-specs/UC-015-view-cinema-report.md 1.1; P04-uc-specs/UC-008-cancel-ticket.md 1.9 (tình trạng hoàn tiền); P04-uc-specs/UC-014-schedule-showtimes.md 1.6 (suất chiếu đã xoá); P07-uc-analysis/UC-004-browse-showtimes-analysis.md 1.0 (cùng lô, dùng lại AC-E-Movie // provideMovieTitle, AC-E-Cinema); sổ AC lập từ F3.4 của P07-uc-analysis/UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 (đầu lô); P08-analysis-model.md 1.5 (mã AC-E-Cinema, AC-E-Seat đã cấp); _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-015, UC-016); dải mã Q được cấp 235 đến 244, không cấp ASM |
| Phạm vi | UC-015 |
| Mã Q, ASM cuối đã cấp | Q-236 (dải Q 235 đến 244, dùng Q-235, Q-236 ở UC-015, Q-237 ở UC-016); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-015 Xem báo cáo cụm rạp (View Cinema Report) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé (bước 12, 13 tạo vé), UC-008 Huỷ vé (bước 4, 7 huỷ vé và ghi tình trạng hoàn tiền), UC-006 Hoàn tiền thanh toán đến trễ, UC-014 Lập lịch suất chiếu (bước 8, 1b3): ghi dữ liệu mà UC-015 chỉ đọc, không loại trừ nhau. UC-012 Quản lý phòng chiếu: sức chứa, sơ đồ ghế (BR-118). UC-016 Xem báo cáo toàn chuỗi: dùng chung kỳ báo cáo, cách tính doanh thu, tỉ lệ lấp đầy, mở rộng ra mọi cụm rạp. UC-017: cấp cụm rạp của quản lý cụm rạp (REQ-100) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-015 đọc; P04 Mục 8 xác nhận không có bước hẹn hoặc huỷ mốc (F4.2 mục 17). Không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-014-schedule-showtimes-analysis.md (AC-E-CinemaManager, AC-E-Showtime, AC-E-Auditorium, AC-E-Movie, AC-E-Ticket), UC-008-cancel-ticket-analysis.md (AC-E-RefundRequest, trách nhiệm // provideRefundInfo), UC-004-browse-showtimes-analysis.md (cùng lô: AC-E-Cinema, // provideMovieTitle). Các lớp còn lại không tham gia UC-015 |
| Đồng thời | Use case chỉ đọc nên không có thao tác không chia cắt và không có đơn vị loại trừ (P04 Mục 8: Thao tác nguyên tử Không có; 00-Concurrency.md M3 mục 1). Thay đổi do use case khác ghi nhận trong lúc đọc chỉ hiện ở lần xem sau |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu xem báo cáo của cụm rạp mình, chọn cách xem (theo ngày, theo phim hoặc theo suất chiếu) và kỳ báo cáo (xem Dữ liệu vào 1). | Không đổi | REQ-66, REQ-67, GL-66 |
| 2 | Hệ thống | Xác định các suất chiếu của cụm rạp của quản lý cụm rạp thuộc kỳ báo cáo (BR-114): suất chiếu có ngày chiếu nằm trong kỳ báo cáo, kể cả suất chiếu chưa tới giờ bắt đầu (BR-117), không kể suất chiếu đã xoá (BR-116). | Control lấy cụm rạp của quản lý cụm rạp từ hồ sơ quản lý (BR-114). Cụm rạp cung cấp các suất chiếu của các phòng chiếu của mình có ngày chiếu nằm trong kỳ, gồm ngày đầu và ngày cuối, kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá; suất chiếu đã xoá không góp sức chứa (BR-116) nhưng vé đã huỷ của nó vẫn góp doanh thu (P04 Mục 8, Q-236). | BR-114, BR-116, BR-117, BR-58, GL-49, GL-66, Q-183, Q-184, Q-236 |
| 3 | Hệ thống | Tính doanh thu của từng nhóm theo cách xem đã chọn, bằng tiền vé đã bán trừ phần tiền đã hoàn cho khách (BR-77); cả tiền vé và phần đã hoàn xếp vào ngày chiếu của suất chiếu có vé đó (BR-115); khoản hoàn toàn bộ của thanh toán đến trễ không được trừ (BR-119). | Control đi qua từng suất chiếu thuộc kỳ; mỗi suất chiếu đi qua từng vé của mình, vé tính tiền vé đã ghi (BR-67) trừ phần đã hoàn của chính vé khi tình trạng hoàn tiền là đã hoàn (hỏi yêu cầu hoàn của vé, GL-56). Khoản hoàn toàn bộ của thanh toán đến trễ không gắn vé nên không bị trừ (BR-119). Control cộng số liệu của suất chiếu vào nhóm theo cách xem: ngày chiếu của suất chiếu (BR-115), phim hoặc chính suất chiếu. | BR-77, BR-115, BR-119, BR-67, GL-04, GL-56, REQ-99, Q-182, Q-187 |
| 4 | Hệ thống | Tính tỉ lệ lấp đầy của từng nhóm theo cách xem đã chọn, từ số ghế của vé đã bán chưa huỷ và sức chứa của các phòng chiếu, ghế đôi tính một ghế (BR-88, BR-06); sức chứa của mỗi suất chiếu là sức chứa lúc suất chiếu diễn ra (BR-118). | Mỗi suất chiếu đếm số vé chưa huỷ của mình (mỗi vé một ghế, ghế đôi một ghế, ghế đang giữ không tính) và cung cấp sức chứa: sức chứa giữ lúc mở bán nếu đã mở bán, sức chứa hiện tại của phòng chiếu nếu chưa mở bán (BR-118), bằng 0 nếu đã xoá (BR-116). Nhóm cộng ghế đã bán và sức chứa rồi tính tỉ lệ bằng tổng ghế chia tổng sức chứa (BR-88); nhóm có tổng sức chứa 0 xử lý theo Q-235. | BR-06, BR-88, BR-116, BR-118, GL-50, GL-55, REQ-153, Q-186, Q-235 |
| 5 | Hệ thống | Hiển thị báo cáo gồm doanh thu và tỉ lệ lấp đầy của từng nhóm (xem Dữ liệu ra 1). | Từng nhóm cung cấp tên nhóm, doanh thu, tỉ lệ lấp đầy; control chuyển cho boundary hiển thị. Không ghi dữ liệu nào. | Dữ liệu ra 1, REQ-66, REQ-67 |
| 1a | Hệ thống | Từ chối xem báo cáo và thông báo kỳ báo cáo không hợp lệ. | Control lập kỳ báo cáo từ từ ngày và đến ngày nhận được; kỳ báo cáo kiểm thiếu từ ngày hoặc đến ngày, hoặc từ ngày sau đến ngày (GL-66). Không hợp lệ thì control báo boundary thông báo, không tính gì, quay lại bước 1. | GL-66, Q-181 |
| 2a | Hệ thống | Thông báo cụm rạp không có suất chiếu trong kỳ báo cáo. | Cụm rạp không cung cấp suất chiếu nào thì control báo boundary thông báo; kết thúc thành công, không tính doanh thu và tỉ lệ (tránh chia cho sức chứa 0, BR-88). Có hiểu suất chiếu đã xoá là suất chiếu của 2a hay không: Q-236. | BR-88, REQ-66, Q-236 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-04 Quản lý cụm rạp | Người | ViewCinemaReportForm | Giao diện người dùng | Mới (AC-B-ViewCinemaReportForm) | Quản lý cụm rạp yêu cầu báo cáo, chọn cách xem và kỳ báo cáo, nhận báo cáo hoặc thông báo kỳ không hợp lệ, không có suất chiếu. Một boundary cho cả yêu cầu và kết quả. |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | quản lý cụm rạp | 1, 2; BR-114 | Entity AC-E-CinemaManager | Biểu diễn thông tin về tác nhân, không phải bản thân tác nhân: hồ sơ quản lý giữ cụm rạp của quản lý (BR-78, GL-42); dùng lại từ UC-013, UC-014. |
| 2 | báo cáo | 1, 5; Dữ liệu ra 1 | Loại - giá trị suy ra từ ReportGroup | Tập các nhóm báo cáo tính tại lúc xem, không lưu (P04 Mục 8). |
| 3 | nhóm báo cáo, dòng báo cáo | 3, 4, 5; Dữ liệu ra 1 dòng 1 | Entity AC-E-ReportGroup | Có hành vi riêng trên dữ liệu của nó: cộng doanh thu, số ghế đã bán chưa huỷ và sức chứa của các suất chiếu cùng nhóm, tính tỉ lệ lấp đầy bằng tổng ghế chia tổng sức chứa (BR-88). Không lưu vượt một lần thực hiện use case; ngoại lệ có chủ đích theo mệnh đề hành vi riêng của A4, là lớp mới giữ trách nhiệm tổng hợp (A6). |
| 4 | cách xem báo cáo (theo ngày, theo phim, theo suất chiếu) | 1; Dữ liệu vào 1 dòng 1 | Loại - dữ liệu trao đổi qua boundary ViewCinemaReportForm | Giá trị chọn của tác nhân; control dùng để chọn khoá nhóm. |
| 5 | kỳ báo cáo, từ ngày, đến ngày | 1, 1a, 2; Dữ liệu vào 1 dòng 2, 3 | Entity AC-E-ReportPeriod | GL-66: có quy tắc riêng (đủ hai ngày, từ ngày không sau đến ngày, gồm hai ngày đầu cuối) và dùng chung với UC-016, nên cần một nơi định nghĩa duy nhất (F3.5 c). Không lưu; ghi chú như ReportGroup. |
| 6 | cụm rạp | 2; BR-114 | Entity AC-E-Cinema | Hệ thống lưu; nắm các phòng chiếu và qua đó các suất chiếu của cụm (GL-03), cung cấp các suất chiếu thuộc kỳ. Cụm rạp do UC-011 quản lý, mã đã cấp ở P08. |
| 7 | suất chiếu | 2, 3, 4; Dữ liệu ra 1 | Entity AC-E-Showtime | Hệ thống lưu; nắm vé, ngày chiếu, thời điểm mở bán, sức chứa lúc mở bán; có hành vi cung cấp số liệu báo cáo (GL-47). |
| 8 | suất chiếu đã xoá | 2, 4; BR-116; Mục 8 | Loại - thuộc tính của Showtime | GL-49: giá trị Đã xoá của thuộc tính status. |
| 9 | ngày chiếu, ngày | 2, 3; BR-115; Dữ liệu ra 1 | Loại - thuộc tính của Showtime | GL-14: ngày của giờ bắt đầu (startTime). |
| 10 | giờ bắt đầu, ngày giờ bắt đầu | 2, 4; Dữ liệu ra 1 dòng 1 | Loại - thuộc tính của Showtime | GL-14. |
| 11 | phim, tên phim | Dữ liệu ra 1 dòng 1 | Entity AC-E-Movie | Showtime hỏi tên phim để làm khoá nhóm theo phim và nhãn nhóm theo suất chiếu (R-UC014-09); dùng lại // provideMovieTitle của UC-004. |
| 12 | phòng chiếu, tên phòng chiếu | 2, 4; Dữ liệu ra 1 dòng 1 | Entity AC-E-Auditorium | Showtime hỏi tên phòng cho nhãn nhóm theo suất chiếu và hỏi sức chứa của phòng khi suất chiếu chưa mở bán (GL-40, GL-50). |
| 13 | sơ đồ ghế, loại ghế, ghế, ghế đôi | 4; BR-06, BR-118 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Auditorium | Phòng chiếu tự đếm ghế của mình, ghế đôi một ghế (BR-06); không gửi message tới từng ghế (A6 b). |
| 14 | sức chứa | 4; BR-88, BR-116, BR-118 | Loại - thuộc tính của Showtime | GL-50: thuộc tính capacity (mới ở UC này) giữ sức chứa lúc suất chiếu mở bán; suất chiếu chưa mở bán hỏi Auditorium. |
| 15 | vé, vé đã bán, vé mua trực tuyến, vé mua tại quầy | 3, 4; BR-77, BR-88 | Entity AC-E-Ticket | Hệ thống lưu; có hành vi tính tiền vé đã bán trừ phần đã hoàn và cho biết đã huỷ chưa (GL-59, GL-63, GL-64). Báo cáo cộng cả hai kênh (P04 Mục 8). |
| 16 | vé đã huỷ, vé đã sử dụng | 3, 4; BR-88 | Loại - thuộc tính của Ticket | GL-60, GL-61: giá trị của status; vé đã sử dụng vẫn là vé đã bán chưa huỷ. |
| 17 | tiền vé đã bán, giá vé | 3; BR-77 | Loại - thuộc tính của Ticket | GL-10: thuộc tính price đã ghi trên vé (BR-67). |
| 18 | phần tiền đã hoàn, khoản hoàn, số tiền hoàn, tình trạng hoàn tiền | 3; BR-77, BR-119 | Entity AC-E-RefundRequest | Yêu cầu hoàn của vé giữ số tiền hoàn và kết quả (GL-45, GL-56); dùng lại // provideRefundInfo của UC-008. Chỉ khoản có tình trạng đã hoàn mới được trừ (GL-04). |
| 19 | thanh toán đến trễ, hoàn toàn bộ | 3; BR-119 | Loại - không tham gia hành vi của use case này (khái niệm của UC-006) | Giao dịch đó không tạo vé nên không có vé để trừ; yêu cầu hoàn toàn bộ không gắn vé nên không bị tính (R-UC008-13). |
| 20 | doanh thu | 3, 5; BR-77; Dữ liệu ra 1 dòng 2 | Loại - giá trị suy ra từ Ticket | GL-04: tính khi cần từ tiền vé và phần đã hoàn, không lưu. |
| 21 | tỉ lệ lấp đầy | 4, 5; BR-88; Dữ liệu ra 1 dòng 3 | Loại - giá trị suy ra từ ReportGroup | GL-55: tính từ tổng số ghế đã bán và tổng sức chứa của nhóm, không lưu. |
| 22 | ghế đang được giữ | 4; BR-88 | Loại - không tham gia hành vi của use case này (khái niệm của UC-005) | Không được tính; use case không đọc lần giữ ghế. |
| 23 | dữ liệu tại lúc xem | BR-117; Mục 8 | Loại - tham số của quy tắc BR-117 | Mốc tính của báo cáo. |
| 24 | thông báo kỳ báo cáo không hợp lệ, thông báo không có suất chiếu | 1a, 2a | Loại - dữ liệu trao đổi qua boundary ViewCinemaReportForm | Nội dung thông báo, không lưu. |
| 25 | đăng nhập, phiên làm việc | Tiền điều kiện | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4); control xác định quản lý của phiên. |
| 26 | hệ thống, thông tin, kết quả | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ViewCinemaReportController | UC-015 | Mới (AC-C-ViewCinemaReportController) | Một control cho use case: nhận yêu cầu duy nhất của tác nhân, lập và kiểm kỳ báo cáo, lấy cụm rạp và các suất chiếu thuộc kỳ, duyệt từng suất chiếu để cộng vào nhóm, rồi yêu cầu từng nhóm tính tỉ lệ và cung cấp số liệu. Công thức doanh thu nằm ở Ticket, quy tắc sức chứa ở Showtime và Auditorium, công thức tỉ lệ ở ReportGroup. Có 1 trách nhiệm (một yêu cầu duy nhất từ boundary, trong ngưỡng chấp nhận vì use case chỉ có một lần gọi từ tác nhân). |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ViewCinemaReportForm | boundary | ViewCinemaReportForm | // requestCinemaReport: quản lý cụm rạp yêu cầu xem báo cáo, chọn cách xem và kỳ báo cáo<br>// notifyInvalidPeriod: thông báo kỳ báo cáo không hợp lệ<br>// notifyNoShowtimes: thông báo cụm rạp không có suất chiếu trong kỳ báo cáo<br>// showReport: hiển thị doanh thu và tỉ lệ lấp đầy của từng nhóm theo cách xem đã chọn | reportRequest (Cách xem, từ ngày, đến ngày) | 1, 5, 1a, 2a | Giao diện người dùng | Mới | GL-42, GL-66 |
| AC-C-ViewCinemaReportController | control | ViewCinemaReportController | // startCinemaReport: điều phối bước 1 đến 5, 1a, 2a: lập kỳ báo cáo và kiểm, lấy cụm rạp của quản lý và các suất chiếu thuộc kỳ, duyệt từng suất chiếu để lấy số liệu và cộng vào nhóm theo cách xem, yêu cầu từng nhóm tính tỉ lệ lấp đầy và cung cấp số liệu, báo boundary hiển thị | - | 1, 2, 3, 4, 5, 1a, 2a | - | Mới | - |
| AC-E-CinemaManager | entity | CinemaManager | // provideCinema: cung cấp cụm rạp mà quản lý cụm rạp thuộc về, để chỉ xem báo cáo của cụm mình (BR-114) | cinema (Cụm rạp) | 2 | - | Tái dùng từ UC-013, UC-014; chủ sở hữu UC-017 | GL-42 |
| AC-E-ReportPeriod | entity | ReportPeriod | // createReportPeriod: lập kỳ báo cáo từ ngày đầu và ngày cuối quản lý nhập<br>// checkPeriodValid: kiểm tra kỳ báo cáo hợp lệ: có từ ngày và đến ngày, từ ngày không sau đến ngày (GL-66, Q-181) | fromDate (Ngày)<br>toDate (Ngày) | 1, 1a | - | Mới | GL-66 |
| AC-E-Cinema | entity | Cinema | // provideShowtimesInPeriod: cung cấp các suất chiếu của các phòng chiếu thuộc cụm rạp có ngày chiếu nằm trong kỳ báo cáo, gồm ngày đầu và ngày cuối, kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá (GL-66, BR-117) | - | 2 | - | Tái dùng từ UC-004, bổ sung trách nhiệm; chủ sở hữu UC-011 | GL-03, GL-66 |
| AC-E-Showtime | entity | Showtime | // provideReportFigures: cung cấp số liệu của suất chiếu cho báo cáo: ngày chiếu, tên phim, tên phòng chiếu, giờ bắt đầu, doanh thu (cộng tiền vé đã bán trừ phần đã hoàn của từng vé, hỏi từng vé), số ghế đã bán chưa huỷ (đếm vé chưa huỷ), sức chứa (BR-116, BR-118: bằng 0 nếu đã xoá; sức chứa giữ lúc mở bán nếu đã mở bán; chưa mở bán thì hỏi phòng chiếu) | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movie (Phim)<br>auditorium (Phòng chiếu)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá)<br>capacity (Số lượng: sức chứa lúc mở bán) (mới ở UC này) | 3, 4 | - | Tái dùng từ UC-014, bổ sung trách nhiệm | GL-47, GL-49, GL-50 |
| AC-E-Movie | entity | Movie | // provideMovieTitle: cung cấp tên phim | title (Văn bản) | 3 | - | Tái dùng từ UC-004; chủ sở hữu UC-010 | GL-37 |
| AC-E-Auditorium | entity | Auditorium | // provideAuditoriumInfo: cung cấp tên phòng chiếu (và loại phòng, các định dạng chiếu được) để hiển thị<br>// provideCapacity: cung cấp sức chứa hiện tại của phòng chiếu: số ghế của phòng, ghế đôi tính một ghế (BR-06, GL-50) | name (Văn bản)<br>auditoriumType (Văn bản) | 3, 4 | - | Tái dùng từ UC-014, bổ sung trách nhiệm; chủ sở hữu UC-012 | GL-40, GL-50 |
| AC-E-Ticket | entity | Ticket | // checkNotCancelled: kiểm tra vé chưa bị huỷ, nên tính một ghế đã bán (vé đã sử dụng vẫn tính) (BR-88)<br>// calculateNetRevenue: tính tiền vé đã bán trừ phần tiền đã hoàn của chính vé: giá vé trừ số tiền hoàn khi yêu cầu hoàn của vé có tình trạng đã hoàn (hỏi yêu cầu hoàn), vé không có yêu cầu hoàn thì tính đủ giá vé (BR-77, BR-119) | price (Số tiền)<br>status (Trạng thái) | 3, 4 | - | Tái dùng từ UC-005, UC-008, UC-009, UC-014, bổ sung trách nhiệm | GL-59, GL-10, GL-04 |
| AC-E-RefundRequest | entity | RefundRequest | // provideRefundInfo: cung cấp số tiền hoàn và tình trạng hoàn tiền (đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi) | refundAmount (Số tiền)<br>result (Văn bản) | 3 | - | Tái dùng từ UC-006, UC-008 | GL-45, GL-56 |
| AC-E-ReportGroup | entity | ReportGroup | // createReportGroup: lập nhóm báo cáo theo khoá nhóm (ngày chiếu, phim hoặc suất chiếu theo cách xem)<br>// addShowtimeFigures: cộng doanh thu, số ghế đã bán chưa huỷ và sức chứa của một suất chiếu vào nhóm (BR-115)<br>// calculateOccupancyRate: tính tỉ lệ lấp đầy của nhóm bằng tổng số ghế đã bán chưa huỷ chia tổng sức chứa (BR-88); tổng sức chứa bằng 0 xử lý theo Q-235<br>// provideGroupFigures: cung cấp khoá nhóm, doanh thu và tỉ lệ lấp đầy để hiển thị | groupKey (Ngày chiếu, phim hoặc suất chiếu)<br>revenue (Số tiền)<br>soldSeatCount (Số lượng)<br>capacity (Số lượng) | 3, 4, 5 | - | Mới | GL-04, GL-55 |

Tổng cộng 11 lớp: 1 boundary, 1 control, 9 entity. AC-E-ReportPeriod và AC-E-ReportGroup là hai entity mới, không lưu vượt một lần thực hiện use case (xem F3.2) và dùng chung với UC-016. Mọi entity đều có trách nhiệm hành vi.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestCinemaReport | AC-B-ViewCinemaReportForm | Giao tiếp tác nhân | - |
| 1, 2, 3, 4, 5, 1a, 2a | // startCinemaReport | AC-C-ViewCinemaReportController | Controller | Boundary chỉ chuyển yêu cầu và dữ liệu nhập, không kiểm kỳ báo cáo. |
| 1, 1a | // createReportPeriod, // checkPeriodValid | AC-E-ReportPeriod | Creator, Information Expert | Kỳ báo cáo là một khái niệm của glossary (GL-66) dùng chung với UC-016, nên một lớp định nghĩa tính hợp lệ (F3.5 c). Phương án khác: boundary hoặc control của từng use case tự kiểm, bị loại vì hai nơi định nghĩa một điều kiện. Control có dữ liệu khởi tạo (từ ngày, đến ngày) nên tạo kỳ báo cáo (Creator). |
| 1a | // notifyInvalidPeriod | AC-B-ViewCinemaReportForm | Giao tiếp tác nhân | - |
| 2 | // provideCinema | AC-E-CinemaManager | Information Expert | Hồ sơ quản lý giữ cụm rạp của quản lý (BR-78); cùng trách nhiệm với UC-013, UC-014. |
| 2 | // provideShowtimesInPeriod | AC-E-Cinema | Information Expert | Cụm rạp nắm các phòng chiếu và qua đó các suất chiếu của mình (GL-03), nên cụm rạp chọn các suất chiếu có ngày chiếu thuộc kỳ; việc chọn tập theo điều kiện coi là có sẵn (A6 a). Một nơi định nghĩa "suất chiếu thuộc kỳ báo cáo" cho UC-015 và UC-016 (F3.5 c). Ngày đầu và ngày cuối thuộc kỳ theo GL-66. |
| 2a | // notifyNoShowtimes | AC-B-ViewCinemaReportForm | Giao tiếp tác nhân | Control biết tập suất chiếu rỗng từ kết quả của cụm rạp, không cần message kiểm tra riêng (A6 b). |
| 3, 4 | // provideReportFigures | AC-E-Showtime | Information Expert | Showtime nắm vé của mình, ngày chiếu, trạng thái, sức chứa lúc mở bán nên gom số liệu của suất chiếu một nơi. Phương án khác: control hỏi riêng từng vé và từng phòng chiếu, bị loại vì control sẽ giữ quy tắc BR-116, BR-118 thuộc dữ liệu của suất chiếu. Control lặp qua từng suất chiếu vì không có đối tượng toàn thể cho tập suất chiếu theo kỳ (A6); cụm rạp đã làm việc chọn tập. |
| 3 | // provideMovieTitle, // provideAuditoriumInfo | AC-E-Movie, AC-E-Auditorium | Information Expert | Tên phim, tên phòng là dữ liệu của phim, phòng chiếu; Showtime hỏi qua quan hệ cấu trúc (R-UC014-09, R-UC014-07). |
| 3, 4 | // checkNotCancelled, // calculateNetRevenue | AC-E-Ticket | Information Expert | Vé nắm giá vé và trạng thái nên vé tính phần của mình; điều kiện vé đã huỷ một nơi (UC-014 đã định nghĩa). Showtime lặp qua từng vé vì cần dữ liệu riêng của từng vé (A6). |
| 3 | // provideRefundInfo | AC-E-RefundRequest | Information Expert | Số tiền hoàn và tình trạng hoàn là dữ liệu của yêu cầu hoàn; chỉ khoản đã hoàn được trừ (GL-04). Yêu cầu hoàn toàn bộ không gắn vé nên không tới đây (BR-119). Ticket hỏi qua R-UC008-13. |
| 4 | // provideCapacity | AC-E-Auditorium | Information Expert | Phòng chiếu nắm tập ghế của mình nên tự đếm, ghế đôi một ghế (BR-06); là trách nhiệm đếm của đối tượng toàn thể (A6 b). Chỉ gọi khi suất chiếu chưa xoá và chưa mở bán (BR-118). |
| 3, 4 | // createReportGroup, // addShowtimeFigures | AC-E-ReportGroup | Creator, Lớp mới | Không entity nào có sẵn dữ liệu của nhiều suất chiếu cùng ngày hoặc cùng phim; phương án khác là control tự cộng, bị loại vì phép cộng theo nhóm và công thức BR-88 là quy tắc tính toán. Control tạo nhóm vì nắm khoá nhóm và số liệu đầu tiên (Creator). |
| 4 | // calculateOccupancyRate | AC-E-ReportGroup | Information Expert | Tỉ lệ lấp đầy bằng tổng ghế chia tổng sức chứa, dữ liệu nằm ở nhóm (BR-88); không phải trung bình các tỉ lệ. |
| 5 | // provideGroupFigures | AC-E-ReportGroup | Information Expert | - |
| 5 | // showReport | AC-B-ViewCinemaReportForm | Giao tiếp tác nhân | - |

Thao tác nguyên tử: không có (P04 Mục 8). Không có dòng thao tác nguyên tử, không có lớp điều phối loại trừ (00-Concurrency.md M3 mục 1, 2).

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-015.drawio, 2 trang. Số message không kể trả về: SD1a 8, SD1b 12. Fragment ở mức ngoài cùng: SD1a alt, break (2); SD1b ref, loop, loop (3).

### SD1a - Luồng chính bước 1, 2 và luồng 1a, 2a

a) Luồng thể hiện: Quản lý cụm rạp yêu cầu báo cáo kèm cách xem và kỳ báo cáo; hệ thống kiểm kỳ báo cáo (luồng 1a quay lại bước 1), xác định cụm rạp của quản lý và các suất chiếu thuộc kỳ; luồng 2a kết thúc khi cụm rạp không có suất chiếu.

Luồng 1a quay lại bước 1 nên vẽ bằng alt: toán hạng luồng chính chỉ ghi guard và note. Luồng 2a kết thúc use case (thành công) nên vẽ bằng break ở mức ngoài cùng, đặt sau alt của luồng 1a theo thứ tự kiểm tra của đặc tả.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1a-L-F | Lifeline | :ViewCinemaReportForm | «boundary» | - | AC-B-ViewCinemaReportForm |
| SD1a-L-C | Lifeline | :ViewCinemaReportController | «control» | - | AC-C-ViewCinemaReportController |
| SD1a-L-P | Lifeline | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| SD1a-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD1a-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD1a-F1 | Fragment | alt [kỳ báo cáo không hợp lệ (1a)] | - | - | mức ngoài cùng |
| SD1a-F1-O2 | Fragment | [kỳ báo cáo hợp lệ] | - | SD1a-F1 | toán hạng 2 |
| SD1a-F2 | Fragment | break [không có suất chiếu nào của cụm rạp thuộc kỳ báo cáo (2a)] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý cụm rạp | :ViewCinemaReportForm | // requestCinemaReport (cách xem, từ ngày, đến ngày) | Đồng bộ | - | 1 |
| 1.1 | :ViewCinemaReportForm | :ViewCinemaReportController | // startCinemaReport (cách xem, từ ngày, đến ngày) | Đồng bộ | - | 1, 2 |
| 1.1.1 | :ViewCinemaReportController | :ReportPeriod | // createReportPeriod (từ ngày, đến ngày) | Tạo | - | 1, 1a |
| 1.1.2 | :ViewCinemaReportController | :ReportPeriod | // checkPeriodValid | Đồng bộ | - | 1a |
| 1.1.2 (trả về) | :ReportPeriod | :ViewCinemaReportController | hợp lệ hoặc không hợp lệ | Trả về | - | 1a |
| 1.1.3 | :ViewCinemaReportController | :ViewCinemaReportForm | // notifyInvalidPeriod | Đồng bộ | SD1a-F1 | 1a |
| 1.1.4 | :ViewCinemaReportController | :CinemaManager | // provideCinema | Đồng bộ | - | 2 |
| 1.1.4 (trả về) | :CinemaManager | :ViewCinemaReportController | cụm rạp của quản lý cụm rạp | Trả về | - | 2 |
| 1.1.5 | :ViewCinemaReportController | :Cinema | // provideShowtimesInPeriod (từ ngày, đến ngày) | Đồng bộ | - | 2 |
| 1.1.5 (trả về) | :Cinema | :ViewCinemaReportController | các suất chiếu có ngày chiếu thuộc kỳ báo cáo, kể cả suất chiếu đã xoá | Trả về | - | 2 |
| 1.1.6 | :ViewCinemaReportController | :ViewCinemaReportForm | // notifyNoShowtimes | Đồng bộ | SD1a-F2 | 2a |

### SD1b - Luồng chính bước 3 đến 5

a) Luồng thể hiện: Hệ thống tính doanh thu và tỉ lệ lấp đầy của từng suất chiếu, cộng vào nhóm theo cách xem, tính tỉ lệ lấp đầy của từng nhóm rồi hiển thị báo cáo.

Trang bắt đầu bằng fragment ref tới SD1a. Message 1.1.7.x do Showtime gửi trong khi xử lý // provideReportFigures; vòng lặp mỗi vé là trách nhiệm của Showtime vì suất chiếu nắm tập vé của mình (A6). Điều kiện của opt F5 do control biết từ khoá nhóm đã nhận.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| SD1b-L-F | Lifeline | :ViewCinemaReportForm | «boundary» | - | AC-B-ViewCinemaReportForm |
| SD1b-L-C | Lifeline | :ViewCinemaReportController | «control» | - | AC-C-ViewCinemaReportController |
| SD1b-L-P | Lifeline | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| SD1b-L-CM | Lifeline | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| SD1b-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD1b-L-S | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1b-L-M | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1b-L-U | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1b-L-T | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD1b-L-R | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| SD1b-L-G | Lifeline | :ReportGroup | «entity» | - | AC-E-ReportGroup |
| SD1b-F0 | Fragment | ref SD1a - Luồng chính bước 1, 2 và luồng 1a, 2a | - | - | ref, mức ngoài cùng |
| SD1b-F1 | Fragment | loop [mỗi suất chiếu thuộc kỳ báo cáo] | - | - | mức ngoài cùng |
| SD1b-F2 | Fragment | loop [mỗi vé của suất chiếu] | - | SD1b-F1 | lồng trong SD1b-F1 |
| SD1b-F3 | Fragment | opt [vé có yêu cầu hoàn tiền] | - | SD1b-F2 | lồng trong SD1b-F2 |
| SD1b-F4 | Fragment | opt [suất chiếu chưa xoá và chưa mở bán] | - | SD1b-F1 | lồng trong SD1b-F1 |
| SD1b-F5 | Fragment | opt [chưa có nhóm của khoá nhóm theo cách xem] | - | SD1b-F1 | lồng trong SD1b-F1 |
| SD1b-F6 | Fragment | loop [mỗi nhóm báo cáo] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.7 | :ViewCinemaReportController | :Showtime | // provideReportFigures | Đồng bộ | SD1b-F1 | 3, 4 |
| 1.1.7.1 | :Showtime | :Movie | // provideMovieTitle | Đồng bộ | SD1b-F1 | 3 |
| 1.1.7.2 | :Showtime | :Auditorium | // provideAuditoriumInfo | Đồng bộ | SD1b-F1 | 3 |
| 1.1.7.3 | :Showtime | :Ticket | // checkNotCancelled | Đồng bộ | SD1b-F2 | 4 |
| 1.1.7.4 | :Showtime | :Ticket | // calculateNetRevenue | Đồng bộ | SD1b-F2 | 3 |
| 1.1.7.4.1 | :Ticket | :RefundRequest | // provideRefundInfo | Đồng bộ | SD1b-F3 | 3 |
| 1.1.7.5 | :Showtime | :Auditorium | // provideCapacity | Đồng bộ | SD1b-F4 | 4 |
| 1.1.7 (trả về) | :Showtime | :ViewCinemaReportController | ngày chiếu, tên phim, tên phòng chiếu, giờ bắt đầu, doanh thu, số ghế đã bán chưa huỷ, sức chứa | Trả về | SD1b-F1 | 3, 4 |
| 1.1.8 | :ViewCinemaReportController | :ReportGroup | // createReportGroup (khoá nhóm) | Tạo | SD1b-F5 | 3, 4 |
| 1.1.9 | :ViewCinemaReportController | :ReportGroup | // addShowtimeFigures (doanh thu, số ghế đã bán chưa huỷ, sức chứa) | Đồng bộ | SD1b-F1 | 3, 4 |
| 1.1.10 | :ViewCinemaReportController | :ReportGroup | // calculateOccupancyRate | Đồng bộ | SD1b-F6 | 4 |
| 1.1.10 (trả về) | :ReportGroup | :ViewCinemaReportController | tỉ lệ lấp đầy của nhóm | Trả về | SD1b-F6 | 4 |
| 1.1.11 | :ViewCinemaReportController | :ReportGroup | // provideGroupFigures | Đồng bộ | SD1b-F6 | 5 |
| 1.1.11 (trả về) | :ReportGroup | :ViewCinemaReportController | tên nhóm, doanh thu, tỉ lệ lấp đầy | Trả về | SD1b-F6 | 5 |
| 1.1.12 | :ViewCinemaReportController | :ViewCinemaReportForm | // showReport (doanh thu và tỉ lệ lấp đầy của từng nhóm) | Đồng bộ | - | 5 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: Showtime --> Movie, Auditorium, Ticket và Ticket --> RefundRequest là entity gọi entity có quan hệ cấu trúc (R-UC015-07 đến R-UC015-10). Control gọi trực tiếp ReportPeriod, CinemaManager, Cinema, Showtime, ReportGroup (kỳ báo cáo, nhóm không có quan hệ cấu trúc với Showtime). Cinema không gọi entity nào trong use case này.

## 7. Communication diagram

File diagrams/P07-communication-UC-015.drawio, 1 trang CM1 gồm luồng chính và mọi luồng thay thế (MUC_CHI_TIET là DAY_DU), giữ STT của SD1a, SD1b.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A | Actor | :Quản lý cụm rạp | - | - | Tác nhân (ACT-04) |
| CM1-O-F | Object | :ViewCinemaReportForm | «boundary» | - | AC-B-ViewCinemaReportForm |
| CM1-O-C | Object | :ViewCinemaReportController | «control» | - | AC-C-ViewCinemaReportController |
| CM1-O-P | Object | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| CM1-O-CM | Object | :CinemaManager | «entity» | - | AC-E-CinemaManager |
| CM1-O-N | Object | :Cinema | «entity» | - | AC-E-Cinema |
| CM1-O-S | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-M | Object | :Movie | «entity» | - | AC-E-Movie |
| CM1-O-U | Object | :Auditorium | «entity» | - | AC-E-Auditorium |
| CM1-O-T | Object | :Ticket | «entity» | - | AC-E-Ticket |
| CM1-O-R | Object | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| CM1-O-G | Object | :ReportGroup | «entity» | - | AC-E-ReportGroup |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A | CM1-O-F | Link | 1: // requestCinemaReport (cách xem, từ ngày, đến ngày) (-->) | Nguồn-->Đích: 1 |
| CM1-L2 | CM1-O-F | CM1-O-C | Link | 1.1: // startCinemaReport (cách xem, từ ngày, đến ngày) (-->)<br>1.1.3: // notifyInvalidPeriod (<--) [kỳ báo cáo không hợp lệ (1a)]<br>1.1.6: // notifyNoShowtimes (<--) [không có suất chiếu nào của cụm rạp thuộc kỳ báo cáo (2a)]<br>1.1.12: // showReport (doanh thu và tỉ lệ lấp đầy của từng nhóm) (<--) | Nguồn-->Đích: 1.1; Đích-->Nguồn: 1.1.3, 1.1.6, 1.1.12 |
| CM1-L3 | CM1-O-C | CM1-O-P | Link | 1.1.1: // createReportPeriod (từ ngày, đến ngày) (-->)<br>1.1.2: // checkPeriodValid (-->) | Nguồn-->Đích: 1.1.1, 1.1.2 |
| CM1-L4 | CM1-O-C | CM1-O-CM | Link | 1.1.4: // provideCinema (-->) | Nguồn-->Đích: 1.1.4 |
| CM1-L5 | CM1-O-C | CM1-O-N | Link | 1.1.5: // provideShowtimesInPeriod (từ ngày, đến ngày) (-->) | Nguồn-->Đích: 1.1.5 |
| CM1-L6 | CM1-O-C | CM1-O-S | Link | 1.1.7: // provideReportFigures (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo] | Nguồn-->Đích: 1.1.7 |
| CM1-L7 | CM1-O-S | CM1-O-M | Link | 1.1.7.1: // provideMovieTitle (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo] | Nguồn-->Đích: 1.1.7.1 |
| CM1-L8 | CM1-O-S | CM1-O-U | Link | 1.1.7.2: // provideAuditoriumInfo (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo]<br>1.1.7.5: // provideCapacity (-->) [suất chiếu chưa xoá và chưa mở bán] | Nguồn-->Đích: 1.1.7.2, 1.1.7.5 |
| CM1-L9 | CM1-O-S | CM1-O-T | Link | 1.1.7.3: // checkNotCancelled (-->) [lặp: mỗi vé của suất chiếu]<br>1.1.7.4: // calculateNetRevenue (-->) [lặp: mỗi vé của suất chiếu] | Nguồn-->Đích: 1.1.7.3, 1.1.7.4 |
| CM1-L10 | CM1-O-T | CM1-O-R | Link | 1.1.7.4.1: // provideRefundInfo (-->) [vé có yêu cầu hoàn tiền] | Nguồn-->Đích: 1.1.7.4.1 |
| CM1-L11 | CM1-O-C | CM1-O-G | Link | 1.1.8: // createReportGroup (khoá nhóm) (-->) [chưa có nhóm của khoá nhóm theo cách xem]<br>1.1.9: // addShowtimeFigures (doanh thu, số ghế đã bán chưa huỷ, sức chứa) (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo]<br>1.1.10: // calculateOccupancyRate (-->) [lặp: mỗi nhóm báo cáo]<br>1.1.11: // provideGroupFigures (-->) [lặp: mỗi nhóm báo cáo] | Nguồn-->Đích: 1.1.8, 1.1.9, 1.1.10, 1.1.11 |

## 8. VOPC

File diagrams/P07-class-UC-015.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ViewCinemaReportForm | Class | ViewCinemaReportForm | «boundary» | - | reportRequest (Cách xem, từ ngày, đến ngày) | // requestCinemaReport<br>// notifyInvalidPeriod<br>// notifyNoShowtimes<br>// showReport |
| AC-C-ViewCinemaReportController | Class | ViewCinemaReportController | «control» | - | - | // startCinemaReport |
| AC-E-CinemaManager | Class | CinemaManager | «entity» | - | cinema (Cụm rạp) | // provideCinema |
| AC-E-ReportPeriod | Class | ReportPeriod | «entity» | - | fromDate (Ngày)<br>toDate (Ngày) | // createReportPeriod<br>// checkPeriodValid |
| AC-E-Cinema | Class | Cinema | «entity» | - | - | // provideShowtimesInPeriod |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movie (Phim)<br>auditorium (Phòng chiếu)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá)<br>capacity (Số lượng: sức chứa lúc mở bán) (mới ở UC này) | // provideReportFigures |
| AC-E-Movie | Class | Movie | «entity» | - | title (Văn bản) | // provideMovieTitle |
| AC-E-Auditorium | Class | Auditorium | «entity» | - | name (Văn bản)<br>auditoriumType (Văn bản) | // provideAuditoriumInfo<br>// provideCapacity |
| AC-E-Ticket | Class | Ticket | «entity» | - | price (Số tiền)<br>status (Trạng thái) | // checkNotCancelled<br>// calculateNetRevenue |
| AC-E-RefundRequest | Class | RefundRequest | «entity» | - | refundAmount (Số tiền)<br>result (Văn bản) | // provideRefundInfo |
| AC-E-ReportGroup | Class | ReportGroup | «entity» | - | groupKey (Ngày chiếu, phim hoặc suất chiếu)<br>revenue (Số tiền)<br>soldSeatCount (Số lượng)<br>capacity (Số lượng) | // createReportGroup<br>// addShowtimeFigures<br>// calculateOccupancyRate<br>// provideGroupFigures |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC015-01 | AC-B-ViewCinemaReportForm | AC-C-ViewCinemaReportController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC015-02 | AC-C-ViewCinemaReportController | AC-E-ReportPeriod | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC015-03 | AC-C-ViewCinemaReportController | AC-E-CinemaManager | Association | - | - | tạm thời; link F7: CM1-L4 |
| R-UC015-04 | AC-C-ViewCinemaReportController | AC-E-Cinema | Association | - | - | tạm thời; link F7: CM1-L5 |
| R-UC015-05 | AC-C-ViewCinemaReportController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L6 |
| R-UC015-06 | AC-C-ViewCinemaReportController | AC-E-ReportGroup | Association | - | - | tạm thời; link F7: CM1-L11 |
| R-UC015-07 | AC-E-Showtime | AC-E-Movie | Association | A 0..* - B 1 | - | Mỗi suất chiếu trình chiếu một phim (GL-47); cùng R-UC014-09; link F7: CM1-L7 |
| R-UC015-08 | AC-E-Auditorium | AC-E-Showtime | Association | A 1 - B 0..* | - | Suất chiếu diễn ra trong đúng một phòng chiếu (GL-47); cùng R-UC014-07; link F7: CM1-L8 |
| R-UC015-09 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | Vé thuộc đúng một ghế của một suất chiếu (GL-59); cùng R-UC005-19; link F7: CM1-L9 |
| R-UC015-10 | AC-E-Ticket | AC-E-RefundRequest | Association | A 0..1 - B 0..1 | - | Mỗi vé có tối đa một yêu cầu hoàn (BR-21); cùng R-UC008-13; link F7: CM1-L10 |
| R-UC015-11 | AC-E-Cinema | AC-E-Auditorium | Aggregation | A 1 - B 1..* | - | Cụm rạp gồm nhiều phòng chiếu (GL-03, GL-40); cụm rạp lấy suất chiếu qua các phòng chiếu; cùng R-38 của P08; bằng chứng từ đặc tả, không có link |

Link actor - boundary không vào VOPC. Không có link tự nối. Quan hệ Showtime - Movie, Auditorium - Showtime, Ticket - Showtime, Ticket - RefundRequest dùng lại quan hệ đã có ở UC-014, UC-005, UC-008.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1, 1.1.1 | Quản lý cụm rạp, AC-B-ViewCinemaReportForm, AC-C-ViewCinemaReportController, AC-E-ReportPeriod |
| 2 | 1.1, 1.1.4, 1.1.4 (trả về), 1.1.5, 1.1.5 (trả về) | AC-B-ViewCinemaReportForm, AC-C-ViewCinemaReportController, AC-E-CinemaManager, AC-E-Cinema |
| 3 | 1.1.7, 1.1.7.1, 1.1.7.2, 1.1.7.4, 1.1.7.4.1, 1.1.7 (trả về), 1.1.8, 1.1.9 | AC-C-ViewCinemaReportController, AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Ticket, AC-E-RefundRequest, AC-E-ReportGroup |
| 4 | 1.1.7, 1.1.7.3, 1.1.7.5, 1.1.7 (trả về), 1.1.8, 1.1.9, 1.1.10, 1.1.10 (trả về) | AC-C-ViewCinemaReportController, AC-E-Showtime, AC-E-Ticket, AC-E-Auditorium, AC-E-ReportGroup |
| 5 | 1.1.11, 1.1.11 (trả về), 1.1.12 | AC-C-ViewCinemaReportController, AC-E-ReportGroup, AC-B-ViewCinemaReportForm |
| 1a | 1.1.1, 1.1.2, 1.1.2 (trả về), 1.1.3 | AC-C-ViewCinemaReportController, AC-E-ReportPeriod, AC-B-ViewCinemaReportForm |
| 2a | 1.1.6 | AC-C-ViewCinemaReportController, AC-B-ViewCinemaReportForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-015.drawio (2 trang), P07-communication-UC-015.drawio (1 trang), P07-class-UC-015.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-235 | Nhóm báo cáo có tổng sức chứa bằng 0 (nhóm chỉ gồm suất chiếu đã xoá, BR-116) hiển thị tỉ lệ lấp đầy thế nào, vì BR-88 chia cho tổng sức chứa? (Hiển thị không áp dụng / Hiển thị 0% / Không hiển thị dòng của nhóm) | // calculateOccupancyRate của AC-E-ReportGroup; Dữ liệu ra 1 dòng 3 của UC-015, UC-016; SD1b | P04 bước 2 loại suất chiếu đã xoá khỏi sức chứa (BR-116) và Mục 8 giữ vé đã huỷ của suất đã xoá trong doanh thu, nên một nhóm có thể có doanh thu mà sức chứa 0; luồng 2a chỉ xử lý khi không có suất chiếu nào | Bên nghiệp vụ | Hiển thị "không áp dụng" cho tỉ lệ lấp đầy và vẫn hiển thị doanh thu của nhóm |
| Q-236 | Kỳ báo cáo chỉ có suất chiếu đã xoá của cụm rạp thì có tính là "không xác định được suất chiếu nào" (luồng 2a) hay vẫn hiển thị báo cáo với doanh thu của vé đã huỷ? (Luồng 2a, bỏ qua suất đã xoá / Hiển thị báo cáo) | Bước 2, luồng 2a của UC-015, UC-016; // provideShowtimesInPeriod của AC-E-Cinema; SD1a | P04 bước 2 ghi "không kể suất chiếu đã xoá (BR-116)" nhưng BR-116 chỉ nói sức chứa, và Mục 8 ghi phần tiền vé của suất đã xoá vẫn thuộc doanh thu | Bên nghiệp vụ | Hiển thị báo cáo khi kỳ có suất chiếu đã xoá còn vé đã huỷ; luồng 2a chỉ khi kỳ không có suất chiếu nào, kể cả đã xoá |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-015 bước 2; UC-016 bước 2 | Câu "không kể suất chiếu đã xoá (BR-116)" mâu thuẫn với Mục 8 (vé đã huỷ của suất đã xoá vẫn thuộc doanh thu); BR-116 chỉ loại suất đã xoá khỏi tổng sức chứa | Sửa bước 2 thành "suất chiếu đã xoá không được tính vào sức chứa (BR-116)" sau khi Q-236 được trả lời; thêm điều kiện của luồng 2a nêu rõ có kể suất chiếu đã xoá hay không |
| P08 | AC-E-Cinema, AC-E-Showtime, AC-E-Auditorium, AC-E-Movie | UC-015 và UC-004 bổ sung: Cinema // provideShowtimesInPeriod, // provideCinemaInfo, // checkInProvince, thuộc tính name, province; Showtime // provideReportFigures và thuộc tính capacity; Auditorium // provideCapacity; Movie // provideMovieTitle | Hợp nhất vào lớp tương ứng ở lần chạy lại P08 |
| P08 | Lớp mới AC-E-ReportPeriod, AC-E-ReportGroup | Hai entity không lưu, dùng chung UC-015 và UC-016 | P08 quyết định giữ làm lớp phân tích hay đưa vào dịch vụ báo cáo ở thiết kế; không đổi mã đã cấp (C3) |
| P08 | Showtime, SeatStatus (BR-118) | Cơ chế giữ sức chứa lúc suất chiếu mở bán chưa có use case hay tác nhân thời gian đảm nhiệm; P07 chỉ giả định thuộc tính capacity của Showtime | Chốt ở P08, P13 cách ghi nhận sơ đồ ghế của suất chiếu khi tới thời điểm mở bán (liên quan sổ đồng bộ dòng Showtime, Auditorium) |

## Vấn đề còn mở

- Kỳ báo cáo và nhóm báo cáo là entity không lưu vượt một lần thực hiện use case: lựa chọn mô hình theo A4 mệnh đề hành vi riêng và F3.5 (một nơi định nghĩa điều kiện dùng chung hai use case). Nếu P08 coi đây là cấu trúc cài đặt thì phép cộng theo nhóm và công thức BR-88 chuyển lên control, tăng nguy cơ god control.
- Control chỉ có 1 trách nhiệm (một yêu cầu duy nhất từ tác nhân); dưới mức 2 của gợi ý nhưng vẫn không giữ quy tắc của entity.
- Số lớp là 11, trong khoảng 4-12.
- Cinema chỉ chọn tập suất chiếu theo kỳ; vòng lặp tính số liệu của từng suất chiếu nằm ở control vì cách xem báo cáo là hiểu biết riêng của use case (Cinema không biết nhóm). Phương án cho Cinema gom số liệu theo nhóm bị loại để UC-016 dùng lại cho nhiều cụm rạp.
- Showtime nắm tập vé của mình (R-UC005-19) và gom doanh thu, số ghế đã bán bằng cách hỏi từng vé; dữ liệu giá vé, trạng thái nằm ở Ticket, tình trạng hoàn tiền ở RefundRequest.
- Báo cáo cộng cả vé mua trực tuyến và tại quầy; Ticket không phân biệt kênh nên không có phép kiểm riêng (P04 Mục 8).
- Thuộc tính capacity của Showtime (sức chứa lúc mở bán, BR-118) và cơ chế ghi nhận ở thời điểm mở bán do P08, P13 quyết định; use case không có bước ghi.
- Q-235, Q-236 cấp ở use case này (dải Q 235 đến 244); UC-016 dùng lại và cấp thêm Q-237.
- Use case chỉ đọc nên không có thao tác không chia cắt (00-Concurrency.md M3); báo cáo tính từ dữ liệu có tại lúc xử lý bước 3, 4 (P04 Mục 8).

