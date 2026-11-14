# P07 - Phân tích use case UC-016 Xem báo cáo toàn chuỗi - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md; project-profile.md; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P04-uc-specs/UC-016-view-chain-report.md 1.1; P04-uc-specs/UC-008-cancel-ticket.md 1.9 (tình trạng hoàn tiền); P04-uc-specs/UC-014-schedule-showtimes.md 1.6 (suất chiếu đã xoá); P07-uc-analysis/UC-015-view-cinema-report-analysis.md 1.0 (cùng lô, dùng lại AC-E-ReportPeriod, AC-E-ReportGroup, các trách nhiệm tính số liệu); sổ AC lập từ F3.4 của P07-uc-analysis/UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 (đầu lô); P08-analysis-model.md 1.5 (mã AC-E-Cinema, AC-E-Seat đã cấp); _sync-log.md (Đầu vào cho lần chạy lại P07-P13, dòng UC-015, UC-016); dải mã Q được cấp 235 đến 244, không cấp ASM |
| Phạm vi | UC-016 |
| Mã Q, ASM cuối đã cấp | Q-237 (dải Q 235 đến 244, dùng Q-235, Q-236 ở UC-015 và Q-237 ở UC-016); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-016 Xem báo cáo toàn chuỗi (View Chain Report) |
| Tác nhân chính | ACT-05 Quản lý chuỗi (Người) |
| Tác nhân phụ | Không có |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-015 Xem báo cáo cụm rạp: dùng chung kỳ báo cáo, cách tính doanh thu và tỉ lệ lấp đầy; UC-016 mở rộng ra mọi cụm rạp và bỏ BR-114. UC-005, UC-008, UC-006, UC-014: ghi dữ liệu mà UC-016 chỉ đọc, không loại trừ nhau (P04 Mục 8). UC-012: sức chứa, sơ đồ ghế (BR-118). UC-017: cấp tài khoản quản lý chuỗi, không thuộc cụm rạp nào (REQ-100, BR-78) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên đối tượng mà UC-016 đọc; P04 Mục 8 xác nhận không có bước hẹn hoặc huỷ mốc (F4.2 mục 17). Không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-015-view-cinema-report-analysis.md (cùng lô: AC-E-ReportPeriod, AC-E-ReportGroup, AC-E-Cinema // provideShowtimesInPeriod), UC-014-schedule-showtimes-analysis.md (AC-E-Showtime, AC-E-Auditorium, AC-E-Movie, AC-E-Ticket), UC-008-cancel-ticket-analysis.md (AC-E-RefundRequest), UC-004-browse-showtimes-analysis.md (cùng lô: AC-E-Cinema // provideCinemaInfo). AC-E-CinemaManager không tham gia vì quản lý chuỗi không thuộc cụm rạp nào |
| Đồng thời | Use case chỉ đọc nên không có thao tác không chia cắt và không có đơn vị loại trừ (P04 Mục 8: Thao tác nguyên tử Không có; 00-Concurrency.md M3 mục 1). Thay đổi do use case khác ghi nhận trong lúc đọc chỉ hiện ở lần xem sau |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản lý chuỗi | Yêu cầu xem báo cáo của toàn chuỗi, chọn cách xem (theo ngày, theo phim hoặc theo suất chiếu) và kỳ báo cáo (xem Dữ liệu vào 1). | Không đổi | REQ-68, REQ-99, GL-66 |
| 2 | Hệ thống | Xác định các suất chiếu của mọi cụm rạp thuộc kỳ báo cáo: suất chiếu có ngày chiếu nằm trong kỳ báo cáo, kể cả suất chiếu chưa tới giờ bắt đầu (BR-117), không kể suất chiếu đã xoá (BR-116). | Control đi qua từng cụm rạp của chuỗi (danh sách cụm rạp của chuỗi không là entity); mỗi cụm rạp cung cấp các suất chiếu của các phòng chiếu của mình có ngày chiếu nằm trong kỳ, gồm ngày đầu và ngày cuối, kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá; suất chiếu đã xoá không góp sức chứa (BR-116) nhưng vé đã huỷ của nó vẫn góp doanh thu (P04 UC-015 Mục 8, Q-236). Không giới hạn theo cụm rạp (BR-78). | BR-116, BR-117, BR-58, BR-78, GL-49, GL-66, Q-183, Q-184, Q-236 |
| 3 | Hệ thống | Tính doanh thu của toàn chuỗi và của từng cụm rạp theo cách xem đã chọn, bằng tiền vé đã bán trừ phần tiền đã hoàn cho khách (BR-77); cả tiền vé và phần đã hoàn xếp vào ngày chiếu của suất chiếu có vé đó (BR-115); khoản hoàn toàn bộ của thanh toán đến trễ không được trừ (BR-119). | Như UC-015 bước 3 cho từng suất chiếu: vé tính tiền vé đã ghi trừ phần đã hoàn của chính vé khi tình trạng hoàn tiền là đã hoàn; hoàn toàn bộ không gắn vé nên không bị trừ. Control cộng số liệu của suất chiếu vào hai nhóm cùng khoá nhóm theo cách xem: nhóm toàn chuỗi và nhóm của cụm rạp có suất chiếu đó. | BR-77, BR-115, BR-119, BR-67, GL-04, GL-56, REQ-99, Q-182, Q-187 |
| 4 | Hệ thống | Tính tỉ lệ lấp đầy của toàn chuỗi và của từng cụm rạp theo cách xem đã chọn, từ số ghế của vé đã bán chưa huỷ và sức chứa của các phòng chiếu, ghế đôi tính một ghế (BR-88, BR-06); sức chứa của mỗi suất chiếu là sức chứa lúc suất chiếu diễn ra (BR-118). | Như UC-015 bước 4: mỗi suất chiếu cung cấp số ghế đã bán chưa huỷ và sức chứa (bằng 0 nếu đã xoá). Mỗi nhóm tính tỉ lệ bằng tổng ghế chia tổng sức chứa, nên tỉ lệ toàn chuỗi là tỉ lệ trên tổng chứ không phải trung bình các tỉ lệ của cụm rạp (BR-88); tổng sức chứa 0 xử lý theo Q-235. | BR-06, BR-88, BR-116, BR-118, GL-50, GL-55, REQ-153, Q-186, Q-235 |
| 5 | Hệ thống | Tổng hợp doanh thu và tỉ lệ lấp đầy của các cụm rạp để so sánh giữa các cụm rạp bằng cách đặt doanh thu và tỉ lệ lấp đầy của mọi cụm rạp cạnh nhau trong cùng kỳ báo cáo và cùng cách xem; không tính chênh lệch, không xếp hạng, không chọn tập con cụm rạp (Q-185). | Với mỗi nhóm của chuỗi, control lấy doanh thu và tỉ lệ của nhóm toàn chuỗi, rồi với mỗi cụm rạp có số liệu trong nhóm lấy doanh thu, tỉ lệ của nhóm của cụm rạp và tên cụm rạp; chỉ đặt cạnh nhau. Cụm rạp không có số liệu trong nhóm xử lý theo Q-237. | REQ-69, Q-185, Q-237 |
| 6 | Hệ thống | Hiển thị báo cáo toàn chuỗi cùng kết quả so sánh giữa các cụm rạp (xem Dữ liệu ra 1, Dữ liệu ra 2). | Control chuyển số liệu của nhóm toàn chuỗi và của các cụm rạp cho boundary hiển thị. Không ghi dữ liệu nào. | Dữ liệu ra 1, Dữ liệu ra 2, REQ-68, REQ-69 |
| 1a | Hệ thống | Từ chối xem báo cáo và thông báo kỳ báo cáo không hợp lệ. | Như UC-015 luồng 1a: kỳ báo cáo kiểm thiếu từ ngày hoặc đến ngày, hoặc từ ngày sau đến ngày; không hợp lệ thì thông báo, quay lại bước 1. | GL-66, Q-181 |
| 2a | Hệ thống | Thông báo chuỗi không có suất chiếu trong kỳ báo cáo. | Không cụm rạp nào cung cấp suất chiếu thì control báo boundary thông báo; kết thúc thành công, không tính doanh thu và tỉ lệ (tránh chia cho sức chứa 0, BR-88). Q-236 như UC-015. | BR-88, REQ-68, Q-236 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-05 Quản lý chuỗi | Người | ViewChainReportForm | Giao diện người dùng | Mới (AC-B-ViewChainReportForm) | Quản lý chuỗi yêu cầu báo cáo, chọn cách xem và kỳ báo cáo, nhận báo cáo toàn chuỗi kèm so sánh hoặc thông báo. Khác ViewCinemaReportForm của UC-015 vì boundary giao diện người dùng đặt tên theo tương tác của từng use case (A3). |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | quản lý chuỗi | 1; BR-78 | Loại - là tác nhân hoặc ngoài phạm vi | Tác nhân chính; không thuộc cụm rạp nào nên hệ thống không cần thông tin về hồ sơ của quản lý chuỗi để lọc dữ liệu (GL-41). Thực thể hồ sơ quản lý chuỗi (sổ đồng bộ, UC-017) không có hành vi trong use case này. |
| 2 | chuỗi, toàn chuỗi | 1, 2, 3, 4, 6 | Loại - là tác nhân hoặc ngoài phạm vi | Tên riêng của tổ chức (P05 mục 3); phạm vi báo cáo là mọi cụm rạp, không là entity. |
| 3 | báo cáo, kết quả so sánh | 1, 5, 6; Dữ liệu ra 1, 2 | Loại - giá trị suy ra từ ReportGroup | Tập các nhóm toàn chuỗi và nhóm của cụm rạp tính tại lúc xem, không lưu. |
| 4 | nhóm báo cáo | 3, 4, 5, 6; Dữ liệu ra 1 dòng 1 | Entity AC-E-ReportGroup | Dùng lại từ UC-015; thêm thuộc tính cụm rạp cho nhóm của một cụm rạp. |
| 5 | cách xem báo cáo | 1; Dữ liệu vào 1 dòng 1 | Loại - dữ liệu trao đổi qua boundary ViewChainReportForm | Giá trị chọn của tác nhân. |
| 6 | kỳ báo cáo, từ ngày, đến ngày | 1, 1a, 2; Dữ liệu vào 1 | Entity AC-E-ReportPeriod | Dùng lại từ UC-015 (một nơi định nghĩa tính hợp lệ, F3.5 c). |
| 7 | cụm rạp, danh sách cụm rạp | 2, 5; Dữ liệu ra 2 dòng 1 | Entity AC-E-Cinema | Cung cấp suất chiếu thuộc kỳ và tên để so sánh; danh sách cụm rạp của chuỗi không là entity nên control lặp (A6). Mã đã cấp ở P08, chủ sở hữu UC-011. |
| 8 | suất chiếu, suất chiếu đã xoá | 2, 3, 4; BR-116 | Entity AC-E-Showtime | Như UC-015; suất chiếu đã xoá là giá trị của thuộc tính status (GL-49). |
| 9 | ngày chiếu, giờ bắt đầu | 2, 3; BR-115; Dữ liệu ra 1 | Loại - thuộc tính của Showtime | GL-14. |
| 10 | phim, tên phim | Dữ liệu ra 1 | Entity AC-E-Movie | Showtime hỏi tên phim cho khoá nhóm và nhãn nhóm. |
| 11 | phòng chiếu, tên phòng chiếu, sức chứa | 4; BR-116, BR-118 | Entity AC-E-Auditorium | Cung cấp tên phòng cho nhãn nhóm theo suất chiếu và sức chứa khi suất chiếu chưa mở bán (GL-50). |
| 12 | tên cụm rạp | Dữ liệu ra 2 dòng 1 | Loại - thuộc tính của Cinema | Thuộc tính name. |
| 13 | sơ đồ ghế, ghế, ghế đôi | 4; BR-06, BR-118 | Loại - khái niệm do UC-012 tạo, use case này chỉ đọc qua entity Auditorium | Phòng chiếu tự đếm ghế của mình (A6 b). |
| 14 | vé, vé đã bán, vé đã huỷ | 3, 4; BR-77, BR-88 | Entity AC-E-Ticket | Như UC-015; báo cáo cộng cả vé mua trực tuyến và tại quầy (UC-015 Mục 8). |
| 15 | tiền vé đã bán, giá vé | 3; BR-77 | Loại - thuộc tính của Ticket | Thuộc tính price. |
| 16 | phần tiền đã hoàn, khoản hoàn, tình trạng hoàn tiền | 3; BR-77, BR-119 | Entity AC-E-RefundRequest | Dùng lại // provideRefundInfo của UC-008. |
| 17 | thanh toán đến trễ, hoàn toàn bộ | 3; BR-119 | Loại - không tham gia hành vi của use case này (khái niệm của UC-006) | Không gắn vé nên không bị trừ. |
| 18 | doanh thu, doanh thu toàn chuỗi, doanh thu của cụm rạp | 3, 5; Dữ liệu ra 1, 2 | Loại - giá trị suy ra từ Ticket | GL-04: tính khi cần, không lưu. |
| 19 | tỉ lệ lấp đầy, tỉ lệ lấp đầy toàn chuỗi, tỉ lệ lấp đầy của cụm rạp | 4, 5; BR-88 | Loại - giá trị suy ra từ ReportGroup | GL-55: tổng ghế chia tổng sức chứa, không lưu. |
| 20 | chênh lệch, thứ hạng, tập con cụm rạp | 5; Q-185 | Loại - không tham gia hành vi của use case này | Q-185 đã trả lời: không tính chênh lệch, không xếp hạng, không chọn tập con. |
| 21 | thông báo kỳ báo cáo không hợp lệ, thông báo không có suất chiếu | 1a, 2a | Loại - dữ liệu trao đổi qua boundary ViewChainReportForm | Nội dung thông báo, không lưu. |
| 22 | đăng nhập, phiên làm việc | Tiền điều kiện | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4). |
| 23 | hệ thống, thông tin, kết quả | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ViewChainReportController | UC-016 | Mới (AC-C-ViewChainReportController) | Một control cho use case: nhận yêu cầu duy nhất, lập và kiểm kỳ báo cáo, hỏi từng cụm rạp các suất chiếu thuộc kỳ, duyệt từng suất chiếu để cộng vào nhóm toàn chuỗi và nhóm của cụm rạp, rồi tính tỉ lệ và đặt các nhóm cạnh nhau. Công thức nằm ở Ticket, Showtime, Auditorium, ReportGroup như UC-015. Có 1 trách nhiệm (một yêu cầu duy nhất từ boundary). |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ViewChainReportForm | boundary | ViewChainReportForm | // requestChainReport: quản lý chuỗi yêu cầu xem báo cáo toàn chuỗi, chọn cách xem và kỳ báo cáo<br>// notifyInvalidPeriod: thông báo kỳ báo cáo không hợp lệ<br>// notifyNoShowtimes: thông báo chuỗi không có suất chiếu trong kỳ báo cáo<br>// showChainReport: hiển thị doanh thu và tỉ lệ lấp đầy toàn chuỗi của từng nhóm cùng doanh thu, tỉ lệ lấp đầy của từng cụm rạp để so sánh | reportRequest (Cách xem, từ ngày, đến ngày) | 1, 6, 1a, 2a | Giao diện người dùng | Mới | GL-41, GL-66 |
| AC-C-ViewChainReportController | control | ViewChainReportController | // startChainReport: điều phối bước 1 đến 6, 1a, 2a: lập kỳ báo cáo và kiểm, lấy các suất chiếu thuộc kỳ của từng cụm rạp, duyệt từng suất chiếu để lấy số liệu và cộng vào nhóm toàn chuỗi và nhóm của cụm rạp, yêu cầu từng nhóm tính tỉ lệ lấp đầy và cung cấp số liệu, đặt các cụm rạp cạnh nhau, báo boundary hiển thị | - | 1, 2, 3, 4, 5, 6, 1a, 2a | - | Mới | - |
| AC-E-ReportPeriod | entity | ReportPeriod | // createReportPeriod: lập kỳ báo cáo từ ngày đầu và ngày cuối quản lý nhập<br>// checkPeriodValid: kiểm tra kỳ báo cáo hợp lệ: có từ ngày và đến ngày, từ ngày không sau đến ngày (GL-66, Q-181) | fromDate (Ngày)<br>toDate (Ngày) | 1, 1a | - | Tái dùng từ UC-015 | GL-66 |
| AC-E-Cinema | entity | Cinema | // provideShowtimesInPeriod: cung cấp các suất chiếu của các phòng chiếu thuộc cụm rạp có ngày chiếu nằm trong kỳ báo cáo, gồm ngày đầu và ngày cuối, kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá (GL-66, BR-117)<br>// provideCinemaInfo: cung cấp tên cụm rạp và tỉnh thành phố để hiển thị | name (Văn bản) | 2, 5 | - | Tái dùng từ UC-004, UC-015; chủ sở hữu UC-011 | GL-03, GL-66 |
| AC-E-Showtime | entity | Showtime | // provideReportFigures: cung cấp số liệu của suất chiếu cho báo cáo: ngày chiếu, tên phim, tên phòng chiếu, giờ bắt đầu, doanh thu (cộng tiền vé đã bán trừ phần đã hoàn của từng vé, hỏi từng vé), số ghế đã bán chưa huỷ (đếm vé chưa huỷ), sức chứa (BR-116, BR-118: bằng 0 nếu đã xoá; sức chứa giữ lúc mở bán nếu đã mở bán; chưa mở bán thì hỏi phòng chiếu) | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movie (Phim)<br>auditorium (Phòng chiếu)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá)<br>capacity (Số lượng: sức chứa lúc mở bán) | 3, 4 | - | Tái dùng từ UC-015 | GL-47, GL-49, GL-50 |
| AC-E-Movie | entity | Movie | // provideMovieTitle: cung cấp tên phim | title (Văn bản) | 3 | - | Tái dùng từ UC-004, UC-015; chủ sở hữu UC-010 | GL-37 |
| AC-E-Auditorium | entity | Auditorium | // provideAuditoriumInfo: cung cấp tên phòng chiếu (và loại phòng, các định dạng chiếu được) để hiển thị<br>// provideCapacity: cung cấp sức chứa hiện tại của phòng chiếu: số ghế của phòng, ghế đôi tính một ghế (BR-06, GL-50) | name (Văn bản)<br>auditoriumType (Văn bản) | 3, 4 | - | Tái dùng từ UC-014, UC-015; chủ sở hữu UC-012 | GL-40, GL-50 |
| AC-E-Ticket | entity | Ticket | // checkNotCancelled: kiểm tra vé chưa bị huỷ, nên tính một ghế đã bán (vé đã sử dụng vẫn tính) (BR-88)<br>// calculateNetRevenue: tính tiền vé đã bán trừ phần tiền đã hoàn của chính vé: giá vé trừ số tiền hoàn khi yêu cầu hoàn của vé có tình trạng đã hoàn (hỏi yêu cầu hoàn), vé không có yêu cầu hoàn thì tính đủ giá vé (BR-77, BR-119) | price (Số tiền)<br>status (Trạng thái) | 3, 4 | - | Tái dùng từ UC-015 | GL-59, GL-10, GL-04 |
| AC-E-RefundRequest | entity | RefundRequest | // provideRefundInfo: cung cấp số tiền hoàn và tình trạng hoàn tiền (đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi) | refundAmount (Số tiền)<br>result (Văn bản) | 3 | - | Tái dùng từ UC-008, UC-015 | GL-45, GL-56 |
| AC-E-ReportGroup | entity | ReportGroup | // createReportGroup: lập nhóm báo cáo theo khoá nhóm (ngày chiếu, phim hoặc suất chiếu theo cách xem), nhóm của một cụm rạp kèm cụm rạp<br>// addShowtimeFigures: cộng doanh thu, số ghế đã bán chưa huỷ và sức chứa của một suất chiếu vào nhóm (BR-115)<br>// calculateOccupancyRate: tính tỉ lệ lấp đầy của nhóm bằng tổng số ghế đã bán chưa huỷ chia tổng sức chứa (BR-88), không phải trung bình các tỉ lệ; tổng sức chứa bằng 0 xử lý theo Q-235<br>// provideGroupFigures: cung cấp khoá nhóm, doanh thu và tỉ lệ lấp đầy để hiển thị | groupKey (Ngày chiếu, phim hoặc suất chiếu)<br>revenue (Số tiền)<br>soldSeatCount (Số lượng)<br>capacity (Số lượng)<br>cinema (Cụm rạp, chỉ nhóm của một cụm rạp) (mới ở UC này) | 3, 4, 5, 6 | - | Tái dùng từ UC-015, bổ sung thuộc tính | GL-04, GL-55 |

Tổng cộng 10 lớp: 1 boundary, 1 control, 8 entity. Hai nhóm cùng lớp AC-E-ReportGroup (nhóm toàn chuỗi và nhóm của cụm rạp) là hai đối tượng khác nhau của một lớp. Mọi entity đều có trách nhiệm hành vi.

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestChainReport | AC-B-ViewChainReportForm | Giao tiếp tác nhân | - |
| 1, 2, 3, 4, 5, 6, 1a, 2a | // startChainReport | AC-C-ViewChainReportController | Controller | Boundary chỉ chuyển yêu cầu, không kiểm kỳ báo cáo. Không có đối tượng toàn thể cho chuỗi (chuỗi là tên riêng) nên control lặp qua từng cụm rạp (A6). |
| 1, 1a | // createReportPeriod, // checkPeriodValid | AC-E-ReportPeriod | Creator, Information Expert | Dùng lại UC-015; một nơi định nghĩa tính hợp lệ của kỳ báo cáo (F3.5 c). |
| 1a | // notifyInvalidPeriod | AC-B-ViewChainReportForm | Giao tiếp tác nhân | - |
| 2 | // provideShowtimesInPeriod | AC-E-Cinema | Information Expert | Dùng lại UC-015: mỗi cụm rạp chọn các suất chiếu của mình thuộc kỳ; không có lớp nào nắm cả chuỗi nên control gọi từng cụm rạp. |
| 2a | // notifyNoShowtimes | AC-B-ViewChainReportForm | Giao tiếp tác nhân | Control biết tập rỗng sau khi hỏi hết các cụm rạp (A6 b). |
| 3, 4 | // provideReportFigures | AC-E-Showtime | Information Expert | Dùng lại UC-015 cho mọi suất chiếu của chuỗi. |
| 3 | // provideMovieTitle, // provideAuditoriumInfo, // provideRefundInfo | AC-E-Movie, AC-E-Auditorium, AC-E-RefundRequest | Information Expert | Như UC-015. |
| 3, 4 | // checkNotCancelled, // calculateNetRevenue | AC-E-Ticket | Information Expert | Như UC-015: điều kiện vé đã huỷ và doanh thu của một vé có một nơi định nghĩa. |
| 4 | // provideCapacity | AC-E-Auditorium | Information Expert | Như UC-015. |
| 3, 4 | // createReportGroup, // addShowtimeFigures | AC-E-ReportGroup | Creator, Lớp mới | Hai nhóm cho mỗi khoá nhóm: nhóm toàn chuỗi và nhóm của cụm rạp. Phương án khác: một nhóm giữ bảng số liệu theo cụm rạp, bị loại vì nhóm sẽ giữ tập đối tượng con (A6: lifeline luôn là một đối tượng) và quy tắc cộng khác nhau cho hai cấp. |
| 4 | // calculateOccupancyRate | AC-E-ReportGroup | Information Expert | Tỉ lệ lấp đầy toàn chuỗi tính trên tổng ghế và tổng sức chứa của nhóm toàn chuỗi, không lấy trung bình các tỉ lệ của cụm rạp (BR-88). |
| 5 | // provideGroupFigures | AC-E-ReportGroup | Information Expert | - |
| 5 | // provideCinemaInfo | AC-E-Cinema | Information Expert | Dùng lại UC-004; chỉ lấy tên cụm rạp để so sánh. |
| 6 | // showChainReport | AC-B-ViewChainReportForm | Giao tiếp tác nhân | - |

Thao tác nguyên tử: không có (P04 Mục 8). Không có dòng thao tác nguyên tử, không có lớp điều phối loại trừ (00-Concurrency.md M3 mục 1, 2).

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-016.drawio, 3 trang. Số message không kể trả về: SD1a 7, SD1b 11, SD1c 6. Fragment ở mức ngoài cùng: SD1a alt, loop, break (3); SD1b ref, loop (2); SD1c ref, loop (2).

### SD1a - Luồng chính bước 1, 2 và luồng 1a, 2a

a) Luồng thể hiện: Quản lý chuỗi yêu cầu báo cáo kèm cách xem và kỳ báo cáo; hệ thống kiểm kỳ báo cáo (luồng 1a quay lại bước 1) và lấy các suất chiếu thuộc kỳ của mọi cụm rạp; luồng 2a kết thúc khi chuỗi không có suất chiếu.

Luồng 1a quay lại bước 1 nên vẽ bằng alt; luồng 2a kết thúc use case (thành công) nên vẽ bằng break ở mức ngoài cùng, đặt sau vòng lặp lấy suất chiếu của từng cụm rạp vì chỉ biết kết quả rỗng sau khi hỏi hết các cụm rạp.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-A | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD1a-L-F | Lifeline | :ViewChainReportForm | «boundary» | - | AC-B-ViewChainReportForm |
| SD1a-L-C | Lifeline | :ViewChainReportController | «control» | - | AC-C-ViewChainReportController |
| SD1a-L-P | Lifeline | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| SD1a-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD1a-F1 | Fragment | alt [kỳ báo cáo không hợp lệ (1a)] | - | - | mức ngoài cùng |
| SD1a-F1-O2 | Fragment | [kỳ báo cáo hợp lệ] | - | SD1a-F1 | toán hạng 2 |
| SD1a-F2 | Fragment | loop [mỗi cụm rạp trong danh sách cụm rạp của chuỗi] | - | - | mức ngoài cùng |
| SD1a-F3 | Fragment | break [không có suất chiếu nào của chuỗi thuộc kỳ báo cáo (2a)] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản lý chuỗi | :ViewChainReportForm | // requestChainReport (cách xem, từ ngày, đến ngày) | Đồng bộ | - | 1 |
| 1.1 | :ViewChainReportForm | :ViewChainReportController | // startChainReport (cách xem, từ ngày, đến ngày) | Đồng bộ | - | 1, 2 |
| 1.1.1 | :ViewChainReportController | :ReportPeriod | // createReportPeriod (từ ngày, đến ngày) | Tạo | - | 1, 1a |
| 1.1.2 | :ViewChainReportController | :ReportPeriod | // checkPeriodValid | Đồng bộ | - | 1a |
| 1.1.2 (trả về) | :ReportPeriod | :ViewChainReportController | hợp lệ hoặc không hợp lệ | Trả về | - | 1a |
| 1.1.3 | :ViewChainReportController | :ViewChainReportForm | // notifyInvalidPeriod | Đồng bộ | SD1a-F1 | 1a |
| 1.1.4 | :ViewChainReportController | :Cinema | // provideShowtimesInPeriod (từ ngày, đến ngày) | Đồng bộ | SD1a-F2 | 2 |
| 1.1.4 (trả về) | :Cinema | :ViewChainReportController | các suất chiếu có ngày chiếu thuộc kỳ báo cáo, kể cả suất chiếu đã xoá | Trả về | SD1a-F2 | 2 |
| 1.1.5 | :ViewChainReportController | :ViewChainReportForm | // notifyNoShowtimes | Đồng bộ | SD1a-F3 | 2a |

### SD1b - Luồng chính bước 3, 4 (gom số liệu theo nhóm)

a) Luồng thể hiện: Với mỗi suất chiếu thuộc kỳ, hệ thống lấy doanh thu, số ghế đã bán chưa huỷ, sức chứa rồi cộng vào nhóm của chuỗi và nhóm của cụm rạp theo cách xem.

Trang bắt đầu bằng fragment ref tới SD1a. Hai nhóm cùng lớp ReportGroup được phân biệt bằng nhãn chainGroup (nhóm toàn chuỗi theo khoá nhóm) và cinemaGroup (nhóm của một cụm rạp theo khoá nhóm và cụm rạp). Message 1.1.6.x do Showtime gửi trong khi xử lý // provideReportFigures.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-A | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD1b-L-F | Lifeline | :ViewChainReportForm | «boundary» | - | AC-B-ViewChainReportForm |
| SD1b-L-C | Lifeline | :ViewChainReportController | «control» | - | AC-C-ViewChainReportController |
| SD1b-L-P | Lifeline | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| SD1b-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD1b-L-S | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1b-L-M | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1b-L-U | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1b-L-T | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD1b-L-R | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| SD1b-L-G1 | Lifeline | chainGroup:ReportGroup | «entity» | - | AC-E-ReportGroup |
| SD1b-L-G2 | Lifeline | cinemaGroup:ReportGroup | «entity» | - | AC-E-ReportGroup |
| SD1b-F0 | Fragment | ref SD1a - Luồng chính bước 1, 2 và luồng 1a, 2a | - | - | ref, mức ngoài cùng |
| SD1b-F1 | Fragment | loop [mỗi suất chiếu thuộc kỳ báo cáo, kèm cụm rạp đã cung cấp suất chiếu đó] | - | - | mức ngoài cùng |
| SD1b-F2 | Fragment | loop [mỗi vé của suất chiếu] | - | SD1b-F1 | lồng trong SD1b-F1 |
| SD1b-F3 | Fragment | opt [vé có yêu cầu hoàn tiền] | - | SD1b-F2 | lồng trong SD1b-F2 |
| SD1b-F4 | Fragment | opt [suất chiếu chưa xoá và chưa mở bán] | - | SD1b-F1 | lồng trong SD1b-F1 |
| SD1b-F5 | Fragment | opt [chưa có nhóm của chuỗi theo khoá nhóm] | - | SD1b-F1 | lồng trong SD1b-F1 |
| SD1b-F6 | Fragment | opt [chưa có nhóm của cụm rạp theo khoá nhóm] | - | SD1b-F1 | lồng trong SD1b-F1 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.6 | :ViewChainReportController | :Showtime | // provideReportFigures | Đồng bộ | SD1b-F1 | 3, 4 |
| 1.1.6.1 | :Showtime | :Movie | // provideMovieTitle | Đồng bộ | SD1b-F1 | 3 |
| 1.1.6.2 | :Showtime | :Auditorium | // provideAuditoriumInfo | Đồng bộ | SD1b-F1 | 3 |
| 1.1.6.3 | :Showtime | :Ticket | // checkNotCancelled | Đồng bộ | SD1b-F2 | 4 |
| 1.1.6.4 | :Showtime | :Ticket | // calculateNetRevenue | Đồng bộ | SD1b-F2 | 3 |
| 1.1.6.4.1 | :Ticket | :RefundRequest | // provideRefundInfo | Đồng bộ | SD1b-F3 | 3 |
| 1.1.6.5 | :Showtime | :Auditorium | // provideCapacity | Đồng bộ | SD1b-F4 | 4 |
| 1.1.6 (trả về) | :Showtime | :ViewChainReportController | ngày chiếu, tên phim, tên phòng chiếu, giờ bắt đầu, doanh thu, số ghế đã bán chưa huỷ, sức chứa | Trả về | SD1b-F1 | 3, 4 |
| 1.1.7 | :ViewChainReportController | chainGroup:ReportGroup | // createReportGroup (khoá nhóm) | Tạo | SD1b-F5 | 3, 4 |
| 1.1.8 | :ViewChainReportController | chainGroup:ReportGroup | // addShowtimeFigures (doanh thu, số ghế đã bán chưa huỷ, sức chứa) | Đồng bộ | SD1b-F1 | 3, 4 |
| 1.1.9 | :ViewChainReportController | cinemaGroup:ReportGroup | // createReportGroup (khoá nhóm, cụm rạp) | Tạo | SD1b-F6 | 3, 4 |
| 1.1.10 | :ViewChainReportController | cinemaGroup:ReportGroup | // addShowtimeFigures (doanh thu, số ghế đã bán chưa huỷ, sức chứa) | Đồng bộ | SD1b-F1 | 3, 4 |

### SD1c - Luồng chính bước 4 (tỉ lệ), 5, 6

a) Luồng thể hiện: Hệ thống tính tỉ lệ lấp đầy của từng nhóm toàn chuỗi và của từng cụm rạp trong nhóm, đặt cạnh nhau để so sánh rồi hiển thị.

Trang bắt đầu bằng fragment ref tới SD1b. Chỉ đặt các số liệu cạnh nhau, không tính chênh lệch, không xếp hạng, không chọn tập con cụm rạp (Q-185).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1c-L-A | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| SD1c-L-F | Lifeline | :ViewChainReportForm | «boundary» | - | AC-B-ViewChainReportForm |
| SD1c-L-C | Lifeline | :ViewChainReportController | «control» | - | AC-C-ViewChainReportController |
| SD1c-L-P | Lifeline | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| SD1c-L-N | Lifeline | :Cinema | «entity» | - | AC-E-Cinema |
| SD1c-L-S | Lifeline | :Showtime | «entity» | - | AC-E-Showtime |
| SD1c-L-M | Lifeline | :Movie | «entity» | - | AC-E-Movie |
| SD1c-L-U | Lifeline | :Auditorium | «entity» | - | AC-E-Auditorium |
| SD1c-L-T | Lifeline | :Ticket | «entity» | - | AC-E-Ticket |
| SD1c-L-R | Lifeline | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| SD1c-L-G1 | Lifeline | chainGroup:ReportGroup | «entity» | - | AC-E-ReportGroup |
| SD1c-L-G2 | Lifeline | cinemaGroup:ReportGroup | «entity» | - | AC-E-ReportGroup |
| SD1c-F0 | Fragment | ref SD1b - Luồng chính bước 3, 4 (gom số liệu theo nhóm) | - | - | ref, mức ngoài cùng |
| SD1c-F1 | Fragment | loop [mỗi nhóm báo cáo của chuỗi] | - | - | mức ngoài cùng |
| SD1c-F2 | Fragment | loop [mỗi cụm rạp có số liệu trong nhóm] | - | SD1c-F1 | lồng trong SD1c-F1 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1.1.11 | :ViewChainReportController | chainGroup:ReportGroup | // calculateOccupancyRate | Đồng bộ | SD1c-F1 | 4 |
| 1.1.11 (trả về) | chainGroup:ReportGroup | :ViewChainReportController | tỉ lệ lấp đầy toàn chuỗi của nhóm | Trả về | SD1c-F1 | 4 |
| 1.1.12 | :ViewChainReportController | chainGroup:ReportGroup | // provideGroupFigures | Đồng bộ | SD1c-F1 | 5 |
| 1.1.12 (trả về) | chainGroup:ReportGroup | :ViewChainReportController | tên nhóm, doanh thu toàn chuỗi, tỉ lệ lấp đầy toàn chuỗi | Trả về | SD1c-F1 | 5 |
| 1.1.13 | :ViewChainReportController | cinemaGroup:ReportGroup | // calculateOccupancyRate | Đồng bộ | SD1c-F2 | 4 |
| 1.1.13 (trả về) | cinemaGroup:ReportGroup | :ViewChainReportController | tỉ lệ lấp đầy của cụm rạp trong nhóm | Trả về | SD1c-F2 | 4 |
| 1.1.14 | :ViewChainReportController | cinemaGroup:ReportGroup | // provideGroupFigures | Đồng bộ | SD1c-F2 | 5 |
| 1.1.14 (trả về) | cinemaGroup:ReportGroup | :ViewChainReportController | doanh thu, tỉ lệ lấp đầy của cụm rạp trong nhóm | Trả về | SD1c-F2 | 5 |
| 1.1.15 | :ViewChainReportController | :Cinema | // provideCinemaInfo | Đồng bộ | SD1c-F2 | 5 |
| 1.1.15 (trả về) | :Cinema | :ViewChainReportController | tên cụm rạp | Trả về | SD1c-F2 | 5 |
| 1.1.16 | :ViewChainReportController | :ViewChainReportForm | // showChainReport (doanh thu và tỉ lệ lấp đầy toàn chuỗi của từng nhóm, kết quả so sánh giữa các cụm rạp) | Đồng bộ | - | 6 |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: Showtime --> Movie, Auditorium, Ticket và Ticket --> RefundRequest là entity gọi entity có quan hệ cấu trúc (R-UC016-06 đến R-UC016-09). Control gọi trực tiếp ReportPeriod, Cinema, Showtime, ReportGroup. Hai lifeline chainGroup và cinemaGroup đều là ReportGroup.

## 7. Communication diagram

File diagrams/P07-communication-UC-016.drawio, 1 trang CM1 gồm luồng chính và mọi luồng thay thế (MUC_CHI_TIET là DAY_DU), giữ STT của SD1a, SD1b, SD1c.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-A | Actor | :Quản lý chuỗi | - | - | Tác nhân (ACT-05) |
| CM1-O-F | Object | :ViewChainReportForm | «boundary» | - | AC-B-ViewChainReportForm |
| CM1-O-C | Object | :ViewChainReportController | «control» | - | AC-C-ViewChainReportController |
| CM1-O-P | Object | :ReportPeriod | «entity» | - | AC-E-ReportPeriod |
| CM1-O-N | Object | :Cinema | «entity» | - | AC-E-Cinema |
| CM1-O-S | Object | :Showtime | «entity» | - | AC-E-Showtime |
| CM1-O-M | Object | :Movie | «entity» | - | AC-E-Movie |
| CM1-O-U | Object | :Auditorium | «entity» | - | AC-E-Auditorium |
| CM1-O-T | Object | :Ticket | «entity» | - | AC-E-Ticket |
| CM1-O-R | Object | :RefundRequest | «entity» | - | AC-E-RefundRequest |
| CM1-O-G1 | Object | chainGroup:ReportGroup | «entity» | - | AC-E-ReportGroup |
| CM1-O-G2 | Object | cinemaGroup:ReportGroup | «entity» | - | AC-E-ReportGroup |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-A | CM1-O-F | Link | 1: // requestChainReport (cách xem, từ ngày, đến ngày) (-->) | Nguồn-->Đích: 1 |
| CM1-L2 | CM1-O-F | CM1-O-C | Link | 1.1: // startChainReport (cách xem, từ ngày, đến ngày) (-->)<br>1.1.3: // notifyInvalidPeriod (<--) [kỳ báo cáo không hợp lệ (1a)]<br>1.1.5: // notifyNoShowtimes (<--) [không có suất chiếu nào của chuỗi thuộc kỳ báo cáo (2a)]<br>1.1.16: // showChainReport (doanh thu và tỉ lệ lấp đầy toàn chuỗi của từng nhóm, kết quả so sánh giữa các cụm rạp) (<--) | Nguồn-->Đích: 1.1; Đích-->Nguồn: 1.1.3, 1.1.5, 1.1.16 |
| CM1-L3 | CM1-O-C | CM1-O-P | Link | 1.1.1: // createReportPeriod (từ ngày, đến ngày) (-->)<br>1.1.2: // checkPeriodValid (-->) | Nguồn-->Đích: 1.1.1, 1.1.2 |
| CM1-L4 | CM1-O-C | CM1-O-N | Link | 1.1.4: // provideShowtimesInPeriod (từ ngày, đến ngày) (-->) [lặp: mỗi cụm rạp trong danh sách cụm rạp của chuỗi]<br>1.1.15: // provideCinemaInfo (-->) [lặp: mỗi cụm rạp có số liệu trong nhóm] | Nguồn-->Đích: 1.1.4, 1.1.15 |
| CM1-L5 | CM1-O-C | CM1-O-S | Link | 1.1.6: // provideReportFigures (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo, kèm cụm rạp đã cung cấp suất chiếu đó] | Nguồn-->Đích: 1.1.6 |
| CM1-L6 | CM1-O-S | CM1-O-M | Link | 1.1.6.1: // provideMovieTitle (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo, kèm cụm rạp đã cung cấp suất chiếu đó] | Nguồn-->Đích: 1.1.6.1 |
| CM1-L7 | CM1-O-S | CM1-O-U | Link | 1.1.6.2: // provideAuditoriumInfo (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo, kèm cụm rạp đã cung cấp suất chiếu đó]<br>1.1.6.5: // provideCapacity (-->) [suất chiếu chưa xoá và chưa mở bán] | Nguồn-->Đích: 1.1.6.2, 1.1.6.5 |
| CM1-L8 | CM1-O-S | CM1-O-T | Link | 1.1.6.3: // checkNotCancelled (-->) [lặp: mỗi vé của suất chiếu]<br>1.1.6.4: // calculateNetRevenue (-->) [lặp: mỗi vé của suất chiếu] | Nguồn-->Đích: 1.1.6.3, 1.1.6.4 |
| CM1-L9 | CM1-O-T | CM1-O-R | Link | 1.1.6.4.1: // provideRefundInfo (-->) [vé có yêu cầu hoàn tiền] | Nguồn-->Đích: 1.1.6.4.1 |
| CM1-L10 | CM1-O-C | CM1-O-G1 | Link | 1.1.7: // createReportGroup (khoá nhóm) (-->) [chưa có nhóm của chuỗi theo khoá nhóm]<br>1.1.8: // addShowtimeFigures (doanh thu, số ghế đã bán chưa huỷ, sức chứa) (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo, kèm cụm rạp đã cung cấp suất chiếu đó]<br>1.1.11: // calculateOccupancyRate (-->) [lặp: mỗi nhóm báo cáo của chuỗi]<br>1.1.12: // provideGroupFigures (-->) [lặp: mỗi nhóm báo cáo của chuỗi] | Nguồn-->Đích: 1.1.7, 1.1.8, 1.1.11, 1.1.12 |
| CM1-L11 | CM1-O-C | CM1-O-G2 | Link | 1.1.9: // createReportGroup (khoá nhóm, cụm rạp) (-->) [chưa có nhóm của cụm rạp theo khoá nhóm]<br>1.1.10: // addShowtimeFigures (doanh thu, số ghế đã bán chưa huỷ, sức chứa) (-->) [lặp: mỗi suất chiếu thuộc kỳ báo cáo, kèm cụm rạp đã cung cấp suất chiếu đó]<br>1.1.13: // calculateOccupancyRate (-->) [lặp: mỗi cụm rạp có số liệu trong nhóm]<br>1.1.14: // provideGroupFigures (-->) [lặp: mỗi cụm rạp có số liệu trong nhóm] | Nguồn-->Đích: 1.1.9, 1.1.10, 1.1.13, 1.1.14 |

## 8. VOPC

File diagrams/P07-class-UC-016.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ViewChainReportForm | Class | ViewChainReportForm | «boundary» | - | reportRequest (Cách xem, từ ngày, đến ngày) | // requestChainReport<br>// notifyInvalidPeriod<br>// notifyNoShowtimes<br>// showChainReport |
| AC-C-ViewChainReportController | Class | ViewChainReportController | «control» | - | - | // startChainReport |
| AC-E-ReportPeriod | Class | ReportPeriod | «entity» | - | fromDate (Ngày)<br>toDate (Ngày) | // createReportPeriod<br>// checkPeriodValid |
| AC-E-Cinema | Class | Cinema | «entity» | - | name (Văn bản) | // provideShowtimesInPeriod<br>// provideCinemaInfo |
| AC-E-Showtime | Class | Showtime | «entity» | - | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>movie (Phim)<br>auditorium (Phòng chiếu)<br>status (Trạng thái: Trong lịch chiếu, Đã xoá)<br>capacity (Số lượng: sức chứa lúc mở bán) | // provideReportFigures |
| AC-E-Movie | Class | Movie | «entity» | - | title (Văn bản) | // provideMovieTitle |
| AC-E-Auditorium | Class | Auditorium | «entity» | - | name (Văn bản)<br>auditoriumType (Văn bản) | // provideAuditoriumInfo<br>// provideCapacity |
| AC-E-Ticket | Class | Ticket | «entity» | - | price (Số tiền)<br>status (Trạng thái) | // checkNotCancelled<br>// calculateNetRevenue |
| AC-E-RefundRequest | Class | RefundRequest | «entity» | - | refundAmount (Số tiền)<br>result (Văn bản) | // provideRefundInfo |
| AC-E-ReportGroup | Class | ReportGroup | «entity» | - | groupKey (Ngày chiếu, phim hoặc suất chiếu)<br>revenue (Số tiền)<br>soldSeatCount (Số lượng)<br>capacity (Số lượng)<br>cinema (Cụm rạp, chỉ nhóm của một cụm rạp) (mới ở UC này) | // createReportGroup<br>// addShowtimeFigures<br>// calculateOccupancyRate<br>// provideGroupFigures |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC016-01 | AC-B-ViewChainReportForm | AC-C-ViewChainReportController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC016-02 | AC-C-ViewChainReportController | AC-E-ReportPeriod | Association | - | - | tạm thời; link F7: CM1-L3 |
| R-UC016-03 | AC-C-ViewChainReportController | AC-E-Cinema | Association | - | - | tạm thời; link F7: CM1-L4 |
| R-UC016-04 | AC-C-ViewChainReportController | AC-E-Showtime | Association | - | - | tạm thời; link F7: CM1-L5 |
| R-UC016-05 | AC-C-ViewChainReportController | AC-E-ReportGroup | Association | - | - | tạm thời; link F7: CM1-L10, CM1-L11 |
| R-UC016-06 | AC-E-Showtime | AC-E-Movie | Association | A 0..* - B 1 | - | Mỗi suất chiếu trình chiếu một phim (GL-47); cùng R-UC014-09; link F7: CM1-L6 |
| R-UC016-07 | AC-E-Auditorium | AC-E-Showtime | Association | A 1 - B 0..* | - | Suất chiếu diễn ra trong đúng một phòng chiếu (GL-47); cùng R-UC014-07; link F7: CM1-L7 |
| R-UC016-08 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | Vé thuộc đúng một ghế của một suất chiếu (GL-59); cùng R-UC005-19; link F7: CM1-L8 |
| R-UC016-09 | AC-E-Ticket | AC-E-RefundRequest | Association | A 0..1 - B 0..1 | - | Mỗi vé có tối đa một yêu cầu hoàn (BR-21); cùng R-UC008-13; link F7: CM1-L9 |
| R-UC016-10 | AC-E-Cinema | AC-E-Auditorium | Aggregation | A 1 - B 1..* | - | Cụm rạp gồm nhiều phòng chiếu (GL-03, GL-40); cụm rạp lấy suất chiếu qua các phòng chiếu; cùng R-38 của P08; bằng chứng từ đặc tả, không có link |

Link actor - boundary không vào VOPC. Không có link tự nối. Hai đối tượng ReportGroup (chainGroup, cinemaGroup) cùng một lớp nên chung một quan hệ với control. Quan hệ Showtime - Movie, Auditorium - Showtime, Ticket - Showtime, Ticket - RefundRequest dùng lại quan hệ đã có ở UC-014, UC-005, UC-008.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1, 1.1, 1.1.1 | Quản lý chuỗi, AC-B-ViewChainReportForm, AC-C-ViewChainReportController, AC-E-ReportPeriod |
| 2 | 1.1, 1.1.4, 1.1.4 (trả về) | AC-B-ViewChainReportForm, AC-C-ViewChainReportController, AC-E-Cinema |
| 3 | 1.1.6, 1.1.6.1, 1.1.6.2, 1.1.6.4, 1.1.6.4.1, 1.1.6 (trả về), 1.1.7, 1.1.8, 1.1.9, 1.1.10 | AC-C-ViewChainReportController, AC-E-Showtime, AC-E-Movie, AC-E-Auditorium, AC-E-Ticket, AC-E-RefundRequest, AC-E-ReportGroup |
| 4 | 1.1.6, 1.1.6.3, 1.1.6.5, 1.1.6 (trả về), 1.1.7, 1.1.8, 1.1.9, 1.1.10, 1.1.11, 1.1.11 (trả về), 1.1.13, 1.1.13 (trả về) | AC-C-ViewChainReportController, AC-E-Showtime, AC-E-Ticket, AC-E-Auditorium, AC-E-ReportGroup |
| 5 | 1.1.12, 1.1.12 (trả về), 1.1.14, 1.1.14 (trả về), 1.1.15, 1.1.15 (trả về) | AC-C-ViewChainReportController, AC-E-ReportGroup, AC-E-Cinema |
| 6 | 1.1.16 | AC-C-ViewChainReportController, AC-B-ViewChainReportForm |
| 1a | 1.1.1, 1.1.2, 1.1.2 (trả về), 1.1.3 | AC-C-ViewChainReportController, AC-E-ReportPeriod, AC-B-ViewChainReportForm |
| 2a | 1.1.5 | AC-C-ViewChainReportController, AC-B-ViewChainReportForm |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-016.drawio (3 trang), P07-communication-UC-016.drawio (1 trang), P07-class-UC-016.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-237 | Trong một nhóm báo cáo, cụm rạp không có suất chiếu hay vé nào thuộc nhóm đó có được liệt kê ở kết quả so sánh giữa các cụm rạp không? (Liệt kê với doanh thu 0 đ và tỉ lệ không áp dụng / Chỉ liệt kê cụm rạp có số liệu trong nhóm) | Bước 5, 6; Dữ liệu ra 2; SD1c vòng lặp mỗi cụm rạp có số liệu trong nhóm | P04 bước 5 ghi "đặt doanh thu và tỉ lệ lấp đầy của mọi cụm rạp cạnh nhau" nhưng không nói cụm rạp không có số liệu trong nhóm (ví dụ một ngày cụm rạp không chiếu suất nào) | Bên nghiệp vụ | Liệt kê mọi cụm rạp của chuỗi trong mỗi nhóm, cụm rạp không có số liệu hiển thị doanh thu 0 đ và tỉ lệ không áp dụng |

## Giả định

Không áp dụng (CHE_DO_GIA_DINH là NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-016 bước 2 | Như đề xuất cho UC-015 bước 2: câu "không kể suất chiếu đã xoá (BR-116)" mâu thuẫn với Mục 8 của UC-015 (vé đã huỷ của suất đã xoá vẫn thuộc doanh thu) | Sửa cùng UC-015 sau khi Q-236 được trả lời |
| P08 | AC-E-ReportGroup | UC-016 thêm thuộc tính cinema (nhóm của một cụm rạp) và dùng hai đối tượng cùng lớp (nhóm toàn chuỗi, nhóm của cụm rạp) | Hợp nhất vào lớp ReportGroup ở lần chạy lại P08 |
| P08 | Thực thể quản lý chuỗi (sổ đồng bộ, UC-017) | UC-016 không cần entity hồ sơ quản lý chuỗi vì quản lý chuỗi không thuộc cụm rạp nào và báo cáo không lọc theo quản lý (BR-78) | Không bắt buộc thêm trách nhiệm cho thực thể này theo UC-016 |

## Vấn đề còn mở

- Q-235, Q-236 cấp ở UC-015 và áp dụng như nhau cho UC-016 (tỉ lệ lấp đầy khi tổng sức chứa 0; luồng 2a có kể suất chiếu đã xoá). Q-237 cấp ở use case này.
- Control chỉ có 1 trách nhiệm (một yêu cầu duy nhất từ tác nhân); dưới mức 2 của gợi ý nhưng không giữ quy tắc của entity.
- Số lớp là 10, trong khoảng 4-12.
- Điều kiện "kỳ báo cáo hợp lệ", "suất chiếu thuộc kỳ báo cáo", "vé đã bán chưa huỷ", "doanh thu của một vé", "sức chứa", "tỉ lệ lấp đầy" dùng chung với UC-015 và có một nơi định nghĩa (sổ trách nhiệm bảng 2).
- Vòng lặp mỗi suất chiếu thuộc kỳ ở SD1b là vòng duy nhất theo tập đã gom ở SD1a; nhãn "kèm cụm rạp đã cung cấp suất chiếu đó" thể hiện control biết cụm rạp nguồn của từng suất chiếu để chọn nhóm của cụm rạp.
- Tỉ lệ lấp đầy toàn chuỗi là tỉ lệ trên tổng, không phải trung bình các tỉ lệ (BR-88); điều này buộc nhóm toàn chuỗi giữ tổng ghế và tổng sức chứa riêng, không lấy từ nhóm của cụm rạp.
- Use case chỉ đọc nên không có thao tác không chia cắt (00-Concurrency.md M3).

