# Sổ trách nhiệm P07 (phần mới của UC-016) - Hệ thống đặt vé xem phim CineBook

Bảng 1: dòng mới hoặc dòng được bổ sung trách nhiệm, thuộc tính, UC dùng.

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính | UC dùng |
|---|---|---|---|---|---|
| AC-B-ViewChainReportForm | boundary | ViewChainReportForm | // requestChainReport: quản lý chuỗi yêu cầu xem báo cáo toàn chuỗi, chọn cách xem và kỳ báo cáo<br>// notifyInvalidPeriod: thông báo kỳ báo cáo không hợp lệ<br>// notifyNoShowtimes: thông báo chuỗi không có suất chiếu trong kỳ báo cáo<br>// showChainReport: hiển thị doanh thu và tỉ lệ lấp đầy toàn chuỗi của từng nhóm cùng doanh thu, tỉ lệ lấp đầy của từng cụm rạp để so sánh | reportRequest (Cách xem, từ ngày, đến ngày) | UC-016 |
| AC-C-ViewChainReportController | control | ViewChainReportController | // startChainReport: điều phối bước 1 đến 6, 1a, 2a: lập kỳ báo cáo và kiểm, lấy các suất chiếu thuộc kỳ của từng cụm rạp, duyệt từng suất chiếu để lấy số liệu và cộng vào nhóm toàn chuỗi và nhóm của cụm rạp, yêu cầu từng nhóm tính tỉ lệ lấp đầy và cung cấp số liệu, đặt các cụm rạp cạnh nhau, báo boundary hiển thị | - | UC-016 |
| AC-E-ReportPeriod | entity | ReportPeriod | - | - | UC-016 |
| AC-E-Cinema | entity | Cinema | - | - | UC-016 |
| AC-E-Showtime | entity | Showtime | - | - | UC-016 |
| AC-E-Movie | entity | Movie | - | - | UC-016 |
| AC-E-Auditorium | entity | Auditorium | - | - | UC-016 |
| AC-E-Ticket | entity | Ticket | - | - | UC-016 |
| AC-E-RefundRequest | entity | RefundRequest | - | - | UC-016 |
| AC-E-ReportGroup | entity | ReportGroup | - | cinema (Cụm rạp, chỉ nhóm của một cụm rạp) (mới ở UC này) | UC-016 |

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
