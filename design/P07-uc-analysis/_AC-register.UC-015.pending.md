# Sổ trách nhiệm P07 (phần mới của UC-015) - Hệ thống đặt vé xem phim CineBook

Bảng 1: dòng mới hoặc dòng được bổ sung trách nhiệm, thuộc tính, UC dùng.

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính | UC dùng |
|---|---|---|---|---|---|
| AC-B-ViewCinemaReportForm | boundary | ViewCinemaReportForm | // requestCinemaReport: quản lý cụm rạp yêu cầu xem báo cáo, chọn cách xem và kỳ báo cáo<br>// notifyInvalidPeriod: thông báo kỳ báo cáo không hợp lệ<br>// notifyNoShowtimes: thông báo cụm rạp không có suất chiếu trong kỳ báo cáo<br>// showReport: hiển thị doanh thu và tỉ lệ lấp đầy của từng nhóm theo cách xem đã chọn | reportRequest (Cách xem, từ ngày, đến ngày) | UC-015 |
| AC-C-ViewCinemaReportController | control | ViewCinemaReportController | // startCinemaReport: điều phối bước 1 đến 5, 1a, 2a: lập kỳ báo cáo và kiểm, lấy cụm rạp của quản lý và các suất chiếu thuộc kỳ, duyệt từng suất chiếu để lấy số liệu và cộng vào nhóm theo cách xem, yêu cầu từng nhóm tính tỉ lệ lấp đầy và cung cấp số liệu, báo boundary hiển thị | - | UC-015 |
| AC-E-CinemaManager | entity | CinemaManager | - | - | UC-015 |
| AC-E-ReportPeriod | entity | ReportPeriod | // createReportPeriod: lập kỳ báo cáo từ ngày đầu và ngày cuối quản lý nhập<br>// checkPeriodValid: kiểm tra kỳ báo cáo hợp lệ: có từ ngày và đến ngày, từ ngày không sau đến ngày (GL-66, Q-181) | fromDate (Ngày)<br>toDate (Ngày) | UC-015 |
| AC-E-Cinema | entity | Cinema | // provideShowtimesInPeriod: cung cấp các suất chiếu của các phòng chiếu thuộc cụm rạp có ngày chiếu nằm trong kỳ báo cáo, gồm ngày đầu và ngày cuối, kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá (GL-66, BR-117) | - | UC-015 |
| AC-E-Showtime | entity | Showtime | // provideReportFigures: cung cấp số liệu của suất chiếu cho báo cáo: ngày chiếu, tên phim, tên phòng chiếu, giờ bắt đầu, doanh thu (cộng tiền vé đã bán trừ phần đã hoàn của từng vé, hỏi từng vé), số ghế đã bán chưa huỷ (đếm vé chưa huỷ), sức chứa (BR-116, BR-118: bằng 0 nếu đã xoá; sức chứa giữ lúc mở bán nếu đã mở bán; chưa mở bán thì hỏi phòng chiếu) | capacity (Số lượng: sức chứa lúc mở bán) (mới ở UC này) | UC-015 |
| AC-E-Movie | entity | Movie | - | - | UC-015 |
| AC-E-Auditorium | entity | Auditorium | // provideCapacity: cung cấp sức chứa hiện tại của phòng chiếu: số ghế của phòng, ghế đôi tính một ghế (BR-06, GL-50) | - | UC-015 |
| AC-E-Ticket | entity | Ticket | // calculateNetRevenue: tính tiền vé đã bán trừ phần tiền đã hoàn của chính vé: giá vé trừ số tiền hoàn khi yêu cầu hoàn của vé có tình trạng đã hoàn (hỏi yêu cầu hoàn), vé không có yêu cầu hoàn thì tính đủ giá vé (BR-77, BR-119) | - | UC-015 |
| AC-E-RefundRequest | entity | RefundRequest | - | - | UC-015 |
| AC-E-ReportGroup | entity | ReportGroup | // createReportGroup: lập nhóm báo cáo theo khoá nhóm (ngày chiếu, phim hoặc suất chiếu theo cách xem)<br>// addShowtimeFigures: cộng doanh thu, số ghế đã bán chưa huỷ và sức chứa của một suất chiếu vào nhóm (BR-115)<br>// calculateOccupancyRate: tính tỉ lệ lấp đầy của nhóm bằng tổng số ghế đã bán chưa huỷ chia tổng sức chứa (BR-88); tổng sức chứa bằng 0 xử lý theo Q-235<br>// provideGroupFigures: cung cấp khoá nhóm, doanh thu và tỉ lệ lấp đầy để hiển thị | groupKey (Ngày chiếu, phim hoặc suất chiếu)<br>revenue (Số tiền)<br>soldSeatCount (Số lượng)<br>capacity (Số lượng) | UC-015 |

Bảng 2: điều kiện hoặc sự kiện từ hai use case trở lên cùng dựa vào.

| Điều kiện hoặc sự kiện | Lớp chịu trách nhiệm (AC) | Trách nhiệm | Định nghĩa | UC dùng |
|---|---|---|---|---|
| Kỳ báo cáo hợp lệ (GL-66, Q-181) | AC-E-ReportPeriod | // checkPeriodValid | Có từ ngày và đến ngày, từ ngày không sau đến ngày | UC-015, UC-016 |
| Suất chiếu thuộc kỳ báo cáo (GL-66, BR-117) | AC-E-Cinema | // provideShowtimesInPeriod | Ngày chiếu của suất chiếu nằm trong kỳ gồm ngày đầu và ngày cuối; kể cả suất chiếu chưa tới giờ bắt đầu và suất chiếu đã xoá | UC-015, UC-016 |
| Vé đã bán chưa huỷ (BR-88) | AC-E-Ticket | // checkNotCancelled | Vé chưa ở trạng thái đã huỷ; vé đã sử dụng vẫn tính | UC-014, UC-015, UC-016 |
| Doanh thu của một vé (BR-77, BR-119) | AC-E-Ticket | // calculateNetRevenue | Giá vé trừ số tiền hoàn khi yêu cầu hoàn của vé có tình trạng đã hoàn | UC-015, UC-016 |
| Sức chứa của phòng chiếu (BR-06, GL-50) | AC-E-Auditorium | // provideCapacity | Số ghế của phòng chiếu, ghế đôi tính một ghế | UC-015, UC-016 |
| Số liệu báo cáo của suất chiếu: sức chứa của suất chiếu (BR-116, BR-118) | AC-E-Showtime | // provideReportFigures | Sức chứa bằng 0 nếu đã xoá; sức chứa giữ lúc mở bán nếu đã mở bán; chưa mở bán thì sức chứa hiện tại của phòng chiếu | UC-015, UC-016 |
| Tỉ lệ lấp đầy của nhóm (BR-88) | AC-E-ReportGroup | // calculateOccupancyRate | Tổng số ghế đã bán chưa huỷ chia tổng sức chứa của nhóm | UC-015, UC-016 |
