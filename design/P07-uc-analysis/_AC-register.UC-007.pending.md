# Sổ trách nhiệm AC - phần mới của UC-007

Sổ dùng chung ở trạng thái đầu lô không bị sửa; file này chỉ gồm dòng mới hoặc dòng được bổ sung trách nhiệm, thuộc tính (Conventions C10 mục 3). Phiên bản P07 của use case: 1.0.

## Bảng 1 - Trách nhiệm và thuộc tính

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính | UC dùng |
|---|---|---|---|---|---|
| AC-B-ViewBookingHistoryForm | boundary | ViewBookingHistoryForm | // requestBookingHistory: khách yêu cầu xem lịch sử đặt vé<br>// showNoBooking: thông báo khách chưa có lần đặt vé nào<br>// showBookingHistory: hiển thị các lần đặt của khách<br>// selectBooking: khách chọn một lần đặt cần xem<br>// rejectBookingView: thông báo từ chối hiển thị kèm quy tắc bị vi phạm<br>// showBookingTickets: hiển thị các vé của lần đặt đã chọn | selectedBookingCode (Mã đặt vé) | UC-007 |
| AC-C-ViewBookingHistoryController | control | ViewBookingHistoryController | // startViewHistory: điều phối bước 2 và 2a: xác định khách của phiên, hỏi khách có lần đặt nào chưa, lấy các lần đặt để hiển thị<br>// viewBookingTickets: điều phối bước 4, 5, 4a: hỏi khách có sở hữu lần đặt đã chọn không, lấy các vé của lần đặt để hiển thị hoặc từ chối | - | UC-007 |
| AC-E-Customer | entity | Customer | // checkHasBookings: kiểm tra khách đã có lần đặt vé nào chưa<br>// provideBookingHistory: duyệt các lần đặt của khách từ gần nhất trước, lấy tóm tắt của từng lần đặt (BR-94)<br>// checkOwnsBooking: kiểm tra lần đặt có mã đặt vé đã chọn thuộc các lần đặt của khách (BR-94) | - (email, phoneNumber, password đã có ở UC-005, không dùng ở use case này) | UC-007 |
| AC-E-Booking | entity | Booking | // provideBookingSummary: cung cấp mã đặt vé, số vé (đếm các vé của lần đặt) và tên phim, tên cụm rạp, ngày giờ bắt đầu lấy từ một vé của lần đặt<br>// provideBookingHistoryDetail: cung cấp mã đặt vé và nội dung từng vé của lần đặt kèm mã QR và trạng thái | bookedAt (Ngày giờ) (mới ở UC này) | UC-007 |
| AC-E-Ticket | entity | Ticket | // provideTicketSummary: cung cấp tên phim, tên cụm rạp theo vé lúc bán và ngày giờ bắt đầu của suất chiếu (BR-140)<br>// provideTicketForHistory: cung cấp nội dung vé kèm mã QR và trạng thái: tên phim, định dạng, cụm rạp, phòng và loại phòng, ngày giờ bắt đầu, vị trí ghế, loại ghế, giá vé (BR-140, REQ-105) | movieTitle (Văn bản) (mới ở UC này), cinemaName (Văn bản) (mới ở UC này), auditoriumName (Văn bản) (mới ở UC này), auditoriumType (Văn bản) (mới ở UC này) | UC-007 |
| AC-E-Showtime | entity | Showtime | // provideShowtimeSchedule: cung cấp định dạng phim và ngày giờ bắt đầu của suất chiếu | startTime (Ngày giờ), movieFormat (Văn bản) | UC-007 |

## Bảng 2 - Điều kiện và sự kiện dùng chung

| Điều kiện hoặc sự kiện | Lớp chịu trách nhiệm (AC) | Trách nhiệm | Định nghĩa | UC dùng |
|---|---|---|---|---|
| Không có | - | - | Phiên không có điều kiện hoặc sự kiện nào mà từ hai use case trở lên cùng dựa vào | - |
