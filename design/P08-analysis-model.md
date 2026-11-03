# P08 - Mô hình phân tích hợp nhất - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P08 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; P01-actors.md 1.1; P02-usecases.md 1.8; P05-glossary.md 1.1; P06-supplementary-spec.md 1.1; P04-uc-specs/_BR-register.md; P07-uc-analysis/UC-005-book-tickets-analysis.md 1.1, UC-006-refund-late-payment-analysis.md 1.1, UC-008-cancel-ticket-analysis.md 1.1, UC-009-check-ticket-analysis.md 1.1, UC-013-manage-price-list-analysis.md 1.1, UC-014-schedule-showtimes-analysis.md 1.1 (F3.4, F6, F8 b, Câu hỏi mở, Giả định, Đề xuất sửa artifact trước, Vấn đề còn mở); P07-uc-analysis/_review-P07-batch.md (mục 2, 3, 4 và các phát hiện R7 chuyển cho P08). Q-97 đã trả lời theo đề xuất: suất chiếu đang soát chỉ có hiệu lực trong phiên làm việc, CheckTicketForm giữ |
| Phạm vi | Toàn hệ thống: 16 use case trong phạm vi, 6 use case đã có P07 (UC-005, UC-006, UC-008, UC-009, UC-013, UC-014) |
| Mã Q, ASM cuối đã cấp | Q-110; không có ASM (NGHIEM_NGAT) |

Trọng tâm: chống race condition, giữ ghế tạm có timeout, giải phóng ghế. Các phần phục vụ trọng tâm: F4b (đơn vị loại trừ, thứ tự khoá), F4c (vòng đời trạng thái SeatHold, SeatStatus, Ticket và các entity có trạng thái khác).

## F1. Độ phủ use case

| UC | Tên | File P07 | Trạng thái |
|---|---|---|---|
| UC-001 | Đăng ký tài khoản | - | Chưa phân tích |
| UC-002 | Đăng nhập | - | Loại theo P02, không tính vào phạm vi |
| UC-003 | Tra cứu phim | - | Chưa phân tích |
| UC-004 | Tra cứu lịch chiếu | - | Chưa phân tích |
| UC-005 | Đặt vé | P07-uc-analysis/UC-005-book-tickets-analysis.md | Đã phân tích |
| UC-006 | Hoàn tiền thanh toán trễ | P07-uc-analysis/UC-006-refund-late-payment-analysis.md | Đã phân tích |
| UC-007 | Xem lịch sử đặt vé | - | Chưa phân tích |
| UC-008 | Huỷ vé | P07-uc-analysis/UC-008-cancel-ticket-analysis.md | Đã phân tích |
| UC-009 | Soát vé | P07-uc-analysis/UC-009-check-ticket-analysis.md | Đã phân tích |
| UC-010 | Quản lý phim | - | Chưa phân tích |
| UC-011 | Quản lý cụm rạp | - | Chưa phân tích |
| UC-012 | Quản lý phòng chiếu | - | Chưa phân tích |
| UC-013 | Quản lý bảng giá | P07-uc-analysis/UC-013-manage-price-list-analysis.md | Đã phân tích |
| UC-014 | Lập lịch suất chiếu | P07-uc-analysis/UC-014-schedule-showtimes-analysis.md | Đã phân tích |
| UC-015 | Xem báo cáo cụm rạp | - | Chưa phân tích |
| UC-016 | Xem báo cáo toàn chuỗi | - | Chưa phân tích |
| UC-017 | Quản lý tài khoản nhân viên | - | Chưa phân tích |

Sáu use case đã phân tích có chung một chuỗi khách đặt vé, giữ ghế, thanh toán, hoàn tiền, huỷ vé, soát vé và hai use case quản trị loại trừ với chuỗi đó (bảng giá, lịch chiếu). Mười use case chưa phân tích (UC-001, UC-003, UC-004, UC-007, UC-010, UC-011, UC-012, UC-015, UC-016, UC-017) được ghi ở Vấn đề còn mở; các lớp chủ sở hữu của chúng có trạng thái Tạm ở F3.

## F2. Nhật ký hợp nhất

Mỗi dòng bảng lớp phân tích F3.4 của mỗi file P07 là một dòng (56 dòng cho 30 mã AC của P07). Không mã AC nào bị gộp vào mã khác; hai lớp mới được cấp ở F2c.

| STT | Lớp gốc (AC, tên) | UC nguồn | Tình huống | Kết quả | Bằng chứng (GL, BR, bước UC) |
|---|---|---|---|---|---|
| 1 | AC-B-BookTicketsForm, BookTicketsForm | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-18; bước UC: 1, 3, 4, 5a, 5b, 6a, 7a, 7b, 7c, 7d, 7e, 8, 9, 10a, 11a, 15, 12, *a; P05 mục 3: người xem sơ đồ ghế là Khách (ACT-01) |
| 2 | AC-B-CounterBookTicketsForm, CounterBookTicketsForm | UC-005 | Giữ nguyên | Giữ | GL-35; bước UC: 1, 2a, 2b, 2c, 3, 4, 8, 9a1, 9a1a, 9a4, 9a5, 9a2; A3: mỗi cặp tác nhân - use case một boundary |
| 3 | AC-B-PaymentGateway, PaymentGateway | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-02; bước UC: 10, 11, 11a; GL-02: một hệ thống ngoài một boundary (A3) |
| 4 | AC-B-EmailService, EmailService | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | -; bước UC: 14; ACT-08: một hệ thống ngoài một boundary (A3) |
| 5 | AC-C-BookTicketsController, BookTicketsController | UC-005 | Giữ nguyên | Giữ | -; bước UC: 1 đến 10, 2a đến 10a, 9a1 đến 9a5, *a |
| 6 | AC-C-PaymentReportController, PaymentReportController | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | -; bước UC: 11 đến 15, 11a; BR-85; P07 UC-005 Q-83 |
| 7 | AC-E-Customer, Customer | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-18; bước UC: 5, 5a2, 7; BR-04; Q-86 |
| 8 | AC-E-BoxOfficeClerk, BoxOfficeClerk | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-35; bước UC: 2b, 5, 7; BR-02, BR-04, BR-78; Q-86 |
| 9 | AC-E-Showtime, Showtime | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-47; bước UC: 2, 2a, 2b, 2c, 3, 6, 7; BR-54, BR-09; Q-81, Q-104 |
| 10 | AC-E-PriceList, PriceList | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-01; bước UC: 7, 7e; BR-71, BR-12; Q-104 |
| 11 | AC-E-SeatStatus, SeatStatus | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b); tách Seat (xem F2c) | GL-58; bước UC: 3, 7, 8, 11, 12, 9a2, 7b, 11a, *a; BR-07, BR-08, BR-09, BR-42; Q-81, Q-103 |
| 12 | AC-E-SeatHold, SeatHold | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-25, GL-31, GL-52, GL-54; bước UC: 7, 7b, 7c, 8, 10, 11, 11a, 12, 13, 9a1a, 9a2, 9a3, *a; BR-85, BR-86, BR-04, BR-53; Q-83, Q-88 |
| 13 | AC-E-PaymentTransaction, PaymentTransaction | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-12, GL-29; bước UC: 10, 11a, 12; BR-37, BR-26, BR-40 |
| 14 | AC-E-Booking, Booking | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-24, GL-28; bước UC: 13, 15, 9a3, 9a4; BR-80 |
| 15 | AC-E-Ticket, Ticket | UC-005 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-59, GL-30, GL-32; bước UC: 13, 15, 9a3, 9a4; BR-21, BR-30, BR-33; Q-73 |
| 16 | AC-B-PaymentGateway, PaymentGateway | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-02, GL-17; bước UC: 1, 2, 4, 5, 2a, 2b, 2c, 2d, 4a, 5a; GL-02: một hệ thống ngoài một boundary (A3) |
| 17 | AC-B-EmailService, EmailService | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-06; bước UC: 7; ACT-08: một hệ thống ngoài một boundary (A3) |
| 18 | AC-C-PaymentReportController, PaymentReportController | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | -; bước UC: 1 đến 7, 2a đến 2e, 4a, 4b, 5a, 5b; BR-85; P07 UC-005 Q-83 |
| 19 | AC-E-SeatHold, SeatHold | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-25, GL-31, GL-51; bước UC: 2, 3, 7, 2a đến 2d; BR-85, BR-86, BR-04, BR-53; Q-83, Q-88 |
| 20 | AC-E-PaymentTransaction, PaymentTransaction | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-12, GL-29, GL-44, GL-51; bước UC: 2, 3, 4, 6, 7, 2a, 2c, 2d; BR-37, BR-26, BR-40 |
| 21 | AC-E-RefundRequest, RefundRequest | UC-006 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-20, GL-45, GL-56; bước UC: 4, 6, 4a, 4b, 5a, 5b; BR-43, BR-41; Q-87, Q-93 |
| 22 | AC-E-Customer, Customer | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-18; bước UC: 7; BR-04; Q-86 |
| 23 | AC-E-Showtime, Showtime | UC-006 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-47; bước UC: 7; BR-54, BR-09; Q-81, Q-104 |
| 24 | AC-B-CancelTicketForm, CancelTicketForm | UC-008 | Giữ nguyên | Giữ | GL-18; bước UC: 1, 2a, 3a, 4a, 4b, 8 |
| 25 | AC-B-CounterCancelTicketForm, CounterCancelTicketForm | UC-008 | Giữ nguyên | Giữ | GL-35; bước UC: 1a1, 1a1a, 1a2, 1a3, 2b, 2c, 3a, 4a, 4b, 5a1, 5a2, 8 |
| 26 | AC-B-PaymentGateway, PaymentGateway | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-02; bước UC: 5, 5b, 6, 6a; GL-02: một hệ thống ngoài một boundary (A3) |
| 27 | AC-B-BookTicketsForm, BookTicketsForm | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-46; bước UC: 7; P05 mục 3: người xem sơ đồ ghế là Khách (ACT-01) |
| 28 | AC-C-CancelTicketController, CancelTicketController | UC-008 | Giữ nguyên | Giữ | -; bước UC: 1 đến 8, 1a1 đến 1a3, 2a đến 2c, 3a, 4a, 4b, 5a1, 5a2, 5b, 5c, 6a, 6b |
| 29 | AC-E-Ticket, Ticket | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-59, GL-60, GL-61, GL-65, GL-45, GL-56; bước UC: 1a2, 4, 4a, 4b, 5, 5a1, 7, 8; BR-21, BR-30, BR-33; Q-73 |
| 30 | AC-E-Booking, Booking | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-24, GL-28, GL-63, GL-64; bước UC: 1a2, 2, 2a, 2b, 5; BR-80 |
| 31 | AC-E-SeatHold, SeatHold | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-25; bước UC: 2, 2a, 2b, 5; BR-85, BR-86, BR-04, BR-53; Q-83, Q-88 |
| 32 | AC-E-Showtime, Showtime | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-47, GL-14, GL-16; bước UC: 2c, 3, 3a; BR-54, BR-09; Q-81, Q-104 |
| 33 | AC-E-PaymentTransaction, PaymentTransaction | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-12, GL-20, GL-29, GL-44; bước UC: 5, 7; BR-37, BR-26, BR-40 |
| 34 | AC-E-RefundRequest, RefundRequest | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-20, GL-45, GL-56; bước UC: 5, 5b, 6a, 7, 8, 5a2; BR-43, BR-41; Q-87, Q-93 |
| 35 | AC-E-SeatStatus, SeatStatus | UC-008 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b); tách Seat (xem F2c) | GL-58; bước UC: 7; BR-07, BR-08, BR-09, BR-42; Q-81, Q-103 |
| 36 | AC-B-CheckTicketForm, CheckTicketForm | UC-009 | Giữ nguyên | Giữ | GL-36; bước UC: 1, 2, 3, 6, 4a, 4b, 4c, 4d, 4e |
| 37 | AC-C-CheckTicketController, CheckTicketController | UC-009 | Giữ nguyên | Giữ | -; bước UC: 2, 4, 5, 6, 4a, 4b, 4c, 4d, 4e |
| 38 | AC-E-TicketChecker, TicketChecker | UC-009 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-36; bước UC: 2, 4; BR-78, BR-22, BR-34; Q-86 |
| 39 | AC-E-Showtime, Showtime | UC-009 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-47; bước UC: 2, 4, 6, 4b; BR-54, BR-09; Q-81, Q-104 |
| 40 | AC-E-Ticket, Ticket | UC-009 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-59, GL-60, GL-61, GL-65; bước UC: 4, 5, 6, 4b, 4c, 4d, 4e; BR-21, BR-30, BR-33; Q-73 |
| 41 | AC-E-Booking, Booking | UC-009 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-24, GL-28; bước UC: 6; BR-80 |
| 42 | AC-B-ManagePriceListForm, ManagePriceListForm | UC-013 | Giữ nguyên | Giữ | GL-42; bước UC: 1, 2, 3, 4a, 5a, 6, 1a, 1a1, 1a2, 1a3a, 1a3b, 1a4, *a |
| 43 | AC-C-ManagePriceListController, ManagePriceListController | UC-013 | Giữ nguyên | Giữ | -; bước UC: 1 đến 6, 1a đến 1a4, 4a, 5a, *a |
| 44 | AC-E-CinemaManager, CinemaManager | UC-013 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-42; bước UC: 2, 1a1; UC-013 và UC-014 cùng cấp mã AC-E-CinemaManager với trạng thái Mới; BR-78; Q-86, Q-100 |
| 45 | AC-E-PriceList, PriceList | UC-013 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-01; bước UC: 2, 4, 5, 1a1, 1a3; BR-71, BR-12; Q-104 |
| 46 | AC-E-PriceEntry, PriceEntry | UC-013 | Giữ nguyên | Giữ | GL-33; bước UC: 2, 5, 1a1 |
| 47 | AC-E-Showtime, Showtime | UC-013 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-47; bước UC: 1a3, 1a3b; BR-54, BR-09; Q-81, Q-104 |
| 48 | AC-B-ScheduleShowtimesForm, ScheduleShowtimesForm | UC-014 | Giữ nguyên | Giữ | GL-42; bước UC: 1, 2, 3, 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8a, 8b, 8c, 8d, 8e, 9, 1a, 1a1, 1a2, 1a3a, 1a3b, 1a4, 1b, 1b1, 1b2, 1b3a, 1b3b, 1b3c, 1b4, *a |
| 49 | AC-C-ScheduleShowtimesController, ScheduleShowtimesController | UC-014 | Giữ nguyên | Giữ | -; bước UC: 1 đến 9, 1a1 đến 1a4, 1b1 đến 1b4, 4a đến 8e, *a |
| 50 | AC-E-CinemaManager, CinemaManager | UC-014 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-42; bước UC: 2, 4, 1a1, 1b1; UC-013 và UC-014 cùng cấp mã AC-E-CinemaManager với trạng thái Mới; BR-78; Q-86, Q-100 |
| 51 | AC-E-Auditorium, Auditorium | UC-014 | Giữ nguyên | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b); thêm quan hệ Cinema, Seat (xem F2c) | GL-40, GL-21, GL-26, GL-27; bước UC: 2, 4, 5, 6, 8, 1a4; BR-51, BR-52; Q-81, Q-103 |
| 52 | AC-E-Movie, Movie | UC-014 | Giữ nguyên | Giữ | GL-37, GL-05; bước UC: 2, 5, 6, 7, 1a4 |
| 53 | AC-E-Showtime, Showtime | UC-014 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-47, GL-14, GL-15, GL-53, GL-49; bước UC: 6, 7, 8, 9, 1a1, 1a3, 1a4, 1b1, 1b3; BR-54, BR-09; Q-81, Q-104 |
| 54 | AC-E-PriceList, PriceList | UC-014 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-01, GL-33, GL-22; bước UC: 5, 8; BR-71, BR-12; Q-104 |
| 55 | AC-E-SeatHold, SeatHold | UC-014 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a) | GL-25, GL-52; bước UC: 8, 1a3, 1b3; BR-85, BR-86, BR-04, BR-53; Q-83, Q-88 |
| 56 | AC-E-Ticket, Ticket | UC-014 | Tái dùng mã | Giữ, hợp trách nhiệm và thuộc tính (xem F2a, F2b) | GL-59, GL-60; bước UC: 8, 1a3, 1b3; BR-21, BR-30, BR-33; Q-73 |

### F2a. Nhật ký trách nhiệm, thuộc tính và cặp đã xét

| STT | Lớp | Mục gốc (trách nhiệm, thuộc tính hoặc cặp lớp) | UC nguồn | Tình huống | Kết quả | Bằng chứng |
|---|---|---|---|---|---|---|
| 1 | SeatHold | settlePaymentReport (UC-005), settleLateTransactionResult đã gộp ở P07 bản 1.1 | UC-005, UC-006 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm settlePaymentReport với bốn kết quả: bán ghế, thanh toán trễ chờ hoàn, báo trùng, thất bại ghi nhận; UC-005 là chủ | BR-85, BR-86, BR-37; _review-P07-batch R7-01, Q-83 |
| 2 | SeatHold | checkHoldStillActive (UC-005, UC-006, UC-014) | UC-005, UC-006, UC-014 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm kiểm lần giữ ghế còn Đang giữ và chưa quá thời điểm hết hạn, dùng chung | BR-04, BR-53, BR-85; R7-03 |
| 3 | SeatHold | recordPaymentTransaction (UC-005, UC-006) | UC-005, UC-006 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Giữ một trách nhiệm tạo giao dịch qua SeatHold, dùng cả cho giao dịch thứ hai | BR-40; Q-85, Q-90; R7-10 |
| 4 | SeatHold | expire, cancel, nhánh thất bại của settlePaymentReport cùng gọi endHold | UC-005 | Cặp đã xét, giữ tách | Giữ ba lối vào (hết hạn, huỷ giữ ghế, thất bại) vì khác sự kiện và khác trạng thái cuối; endHold là lõi, chạy lại an toàn, không đổi khi đã ở trạng thái cuối | BR-85, BR-86; _review-P07-batch mục 2 STT 2 |
| 5 | SeatStatus | releaseSeat (UC-005) và releaseSoldSeat (UC-008) | UC-005, UC-008 | Đổi tên trách nhiệm | Một trách nhiệm releaseSeat có tiền điều kiện (ghế đang giữ hoặc đã bán, còn thuộc đúng lần giữ ghế hoặc đúng vé); bỏ releaseSoldSeat | BR-42, REQ-76; R7-15 |
| 6 | SeatStatus | SeatHold.releaseHeldSeats, Ticket.releaseTicketSeat, SeatStatus.releaseSeat | UC-005, UC-008 | Cặp đã xét, giữ tách | Giữ ba trách nhiệm ở ba lớp: SeatHold lặp qua các ghế của lần giữ ghế, Ticket chuyển yêu cầu trả ghế của vé, SeatStatus đổi trạng thái ghế | BR-42, REQ-76; GL-25, GL-59, GL-58 |
| 7 | Ticket | provideTicketContent (UC-005, UC-008, UC-009) | UC-005, UC-008, UC-009 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm, hợp nội dung (thêm số tiền hoàn và tình trạng hoàn tiền của UC-008 khi có yêu cầu hoàn) | REQ-105, GL-59, GL-45, GL-56 |
| 8 | Ticket | cancelTicket (UC-008) và admitTicket (UC-009) | UC-008, UC-009 | Cặp đã xét, giữ tách | Giữ hai thao tác không chia cắt riêng nhưng cùng đơn vị loại trừ là vé và cùng bộ giá trị trạng thái (xem EX-07, EX-08, cặp X-14) | BR-30, BR-21, BR-25; GL-60, GL-61, GL-65 |
| 9 | Booking | provideBookingInfo (UC-005, UC-008) | UC-005, UC-008 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm cung cấp mã đặt vé và nội dung các vé của lần đặt | GL-24, GL-28 |
| 10 | Booking | provideBookingCode (UC-009) và provideBookingInfo | UC-005, UC-009 | Cặp đã xét, giữ tách | Giữ tách: provideBookingCode chỉ trả mã đặt vé in trên vé, provideBookingInfo trả mã và nội dung các vé | GL-28; _review-P07-batch mục 2 STT 16 |
| 11 | PaymentGateway | reportTransactionResult (UC-005, UC-006) | UC-005, UC-006 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm nhận kết quả giao dịch do cổng báo về | GL-17, GL-02; R7-01 |
| 12 | PaymentGateway | requestRefund (UC-006, UC-008) | UC-006, UC-008 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm gửi yêu cầu hoàn kèm khoá chống hoàn trùng và nhận kết quả hoàn trả về trong 30 giây; không có callback riêng | BR-43, GL-20; Q-91 |
| 13 | PaymentGateway | createPaymentTransaction (PaymentGateway) và createPaymentTransaction (PaymentTransaction) | UC-005, UC-006 | Cặp đã xét, giữ tách | Giữ tách: ở boundary là gửi yêu cầu tạo giao dịch tới cổng, ở entity là tạo bản ghi giao dịch; khác lớp nên không đổi tên | GL-02, GL-12 |
| 14 | PaymentTransaction | createPaymentTransaction, checkNotProcessed, recordFailedResult (UC-005, UC-006) | UC-005, UC-006 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Giữ một tên, một nghĩa cho mỗi trách nhiệm | BR-37, BR-39, BR-40 |
| 15 | PaymentTransaction | prepareRefundRequest, checkRefundWithinPaidAmount, recordRefundedAmount (UC-006, UC-008) | UC-006, UC-008 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Giữ một tên, một nghĩa; hai UC cùng gọi trên cùng giao dịch (xem EX-09) | BR-26, BR-43; R7-06 |
| 16 | PaymentTransaction | markProcessed (UC-005) và markLatePayment (UC-006) | UC-005, UC-006 | Cặp đã xét, giữ tách | Giữ tách: markProcessed đánh dấu giao dịch đã dùng để tạo vé, markLatePayment đánh dấu đã ghi nhận thanh toán trễ kèm lý do hoàn; cùng đặt thuộc tính processed | BR-37, BR-14, BR-15 |
| 17 | RefundRequest | createRefundRequest, generateIdempotencyKey, recordAttempt, recordResult, checkRetryRemaining (UC-006, UC-008) | UC-006, UC-008 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một bộ trách nhiệm cho cả hoàn toàn bộ và hoàn từng vé | BR-43, BR-41; Q-87, Q-93 |
| 18 | PaymentReportController | handlePaymentReport (UC-005, UC-006) | UC-005, UC-006 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm tiếp nhận mọi báo kết quả giao dịch; UC-006 không có control riêng | BR-85; Q-83 |
| 19 | PaymentReportController | startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure cùng tên và cùng nghĩa với CancelTicketController (UC-008) | UC-006, UC-008 | Cặp đã xét, giữ tách | Hai control của hai use case không gộp (A3). Bốn trách nhiệm trùng nhau giữ ở cả hai cho tới khi có quyết định tách use case được include (Q-106) | BR-41, BR-43; _review-P07-batch R7-06 |
| 20 | BookTicketsForm | updateSeatMap (UC-005, UC-008) | UC-005, UC-008 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm cập nhật sơ đồ ghế đang hiển thị; UC-008 và PaymentReportController gửi tới BookTicketsForm, ngoại lệ boundary người dùng dùng chung được giữ vì người nhận là khách khác của UC-005; cách phát cập nhật là cơ chế dùng chung do P09, P12 chọn | REQ-119; _review-P07-batch R7-13, A3 |
| 21 | Showtime | checkUnchangedSinceDisplayed (UC-005, UC-014) | UC-005, UC-014 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm so mốc thay đổi của suất chiếu với mốc lúc hiển thị | BR-54, BR-60; R7-11 |
| 22 | Showtime | checkStartAfter và checkNotStarted (UC-014) | UC-014 | Đổi tên trách nhiệm | Một trách nhiệm checkNotStarted: cùng điều kiện giờ bắt đầu sau thời điểm kiểm tra, áp cho suất chiếu dự kiến (lập, sửa) và suất chiếu đang có (sửa, xoá) | BR-56, BR-57 |
| 23 | Showtime | provideMovieAndStartTime (UC-006), provideShowtimeForChecking (UC-009), provideShowtimeInfo (UC-014) | UC-006, UC-009, UC-014 | Đổi tên trách nhiệm | Một trách nhiệm provideShowtimeInfo trả bộ dữ liệu hợp (tên phim lấy qua Movie, tên phòng qua Auditorium); mỗi use case dùng phần mình cần | GL-47; R7-11 |
| 24 | Showtime | checkBelongsToCinema (UC-005, UC-008, UC-009) | UC-005, UC-008, UC-009 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm kiểm suất chiếu thuộc cụm rạp của nhân viên, chuyển cho phòng chiếu | BR-02, BR-17, BR-22, BR-34 |
| 25 | Showtime | checkBelongsToCinema (Showtime) và checkBelongsToCinema (Auditorium, UC-014) | UC-005, UC-014 | Cặp đã xét, giữ tách | Giữ tách: Showtime hỏi Auditorium, Auditorium so cụm rạp của mình với cụm rạp của nhân viên (BR-46); khác lớp, cùng nghĩa, một lớp chuyển cho lớp kia | BR-02, BR-46 |
| 26 | Showtime | checkSaleOpen (UC-005) và checkSaleOpenBeforeStart (UC-014) | UC-005, UC-014 | Cặp đã xét, giữ tách | Giữ tách: checkSaleOpen kiểm đã tới thời điểm mở bán và chưa tới giờ bắt đầu so với hiện tại, checkSaleOpenBeforeStart kiểm thời điểm mở bán đã nhập trước giờ bắt đầu đã nhập | BR-01, BR-45, BR-55 |
| 27 | PriceList | determineSeatPrice (UC-005), checkCoversShowtime (UC-014) và Showtime.checkUsesPriceEntry (UC-013) | UC-005, UC-013, UC-014 | Cặp đã xét, giữ tách | Giữ tách ba trách nhiệm có mục đích khác nhau (giá của một ghế, bảng giá phủ mọi loại ghế, suất chiếu có dùng một mục giá); phần so khớp bốn yếu tố dùng chung là chi tiết P12 | BR-11, BR-12, BR-64, BR-69; R7-09 |
| 28 | PriceEntry | lastChangedAt (PriceEntry) và entryChangeTimes (PriceList) | UC-013 | Cặp đã xét, giữ tách | Giữ cả hai: entryChangeTimes giữ mốc của tổ hợp kể cả mục giá đã bỏ (không còn PriceEntry), lastChangedAt là mốc của mục giá đang có; P12 giữ hai giá trị nhất quán | BR-63; Q-99 |
| 29 | CinemaManager | provideCinema (UC-013, UC-014) | UC-013, UC-014 | Gộp trách nhiệm cùng tên, cùng ý nghĩa | Một trách nhiệm cung cấp cụm rạp của quản lý cụm rạp; tên provideOwnCinema đã thống nhất ở P07 bản 1.1 | BR-61, BR-46; R7-14 |
| 30 | Cinema | Vòng lặp qua các phòng chiếu và các suất chiếu của cụm rạp do ScheduleShowtimesController thực hiện (UC-014 bước 2, 1a4) | UC-014 | Chuyển trách nhiệm sang lớp toàn thể | Chuyển sang Cinema: provideAuditoriums, provideShowtimes; control chỉ gọi Cinema một lần | UC-014 Vấn đề còn mở (Cụm rạp rút gọn, Q-81); GL-03; A4 |
| 31 | Ticket | status (UC-005, UC-008, UC-009) | UC-005, UC-008, UC-009 | Mở rộng tập giá trị thuộc tính | Tập giá trị: chưa sử dụng, đã sử dụng, đã huỷ; một bộ giá trị cho cancelTicket và admitTicket | GL-59, GL-60, GL-61, GL-65; Q-73 |
| 32 | SeatStatus | status (UC-005, UC-008) | UC-005, UC-008 | Mở rộng tập giá trị thuộc tính | Tập giá trị: trống, đang được giữ, đã bán; UC-008 thêm chuyển đã bán về trống | GL-58, BR-42 |
| 33 | SeatHold | status (UC-005, UC-006) | UC-005, UC-006 | Mở rộng tập giá trị thuộc tính | Tập giá trị: Đang giữ rồi đúng một trong bốn trạng thái cuối Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại; UC-006 chỉ thấy trạng thái cuối | GL-25, BR-86; Q-69, Q-88 |
| 34 | PaymentTransaction | processed (UC-005) và lateReason (UC-006) | UC-005, UC-006 | Mở rộng tập giá trị thuộc tính | processed nhận ba giá trị: chưa xử lý, đã tạo vé, đã ghi nhận thanh toán trễ; lateReason chỉ có khi đã ghi nhận thanh toán trễ | BR-37, BR-14, BR-15, BR-40 |
| 35 | RefundRequest | requestType (UC-006, UC-008) | UC-006, UC-008 | Mở rộng tập giá trị thuộc tính | Tập giá trị: hoàn toàn bộ thanh toán trễ, hoàn một vé qua cổng, hoàn một vé bằng tiền mặt | BR-20, BR-43; GL-20 |
| 36 | Customer, BoxOfficeClerk | Người giữ ghế là hai entity loại trừ nhau (R-48, R-49) | UC-005 | Cặp đã xét, giữ tách | Giữ tách theo Q-86; ràng buộc {xor} trên hai quan hệ | GL-18, GL-35, GL-25; BR-04 |
| 37 | BookTicketsForm, CounterBookTicketsForm, CancelTicketForm, CounterCancelTicketForm | Boundary người dùng của khách và của nhân viên quầy trong cùng use case | UC-005, UC-008 | Cặp đã xét, giữ tách | Giữ tách: mỗi cặp tác nhân - use case một boundary; hai kênh khác nhau ở nhiều bước (đăng nhập, thu tiền mặt, in vé, nhập mã đặt vé) | A3; P02 U-R10 b |
| 38 | Booking, SeatHold | Lần đặt và lần giữ ghế | UC-005 | Cặp đã xét, giữ tách | Giữ tách: lần đặt chỉ phát sinh khi mua thành công, một lần giữ ghế dẫn tới tối đa một lần đặt | GL-24, GL-25; Q-68 |
| 39 | SeatStatus, Seat | Trạng thái ghế của một suất chiếu và ghế của phòng chiếu | UC-005 | Cặp đã xét, giữ tách | Giữ tách và tách Seat khỏi SeatStatus: Seat là vị trí cố định của phòng (GL-07), SeatStatus là tình trạng của ghế trong một suất chiếu (GL-58) | GL-07, GL-58; Q-70, Q-81 |
| 40 | SeatHold.cancel, BookTicketsController.cancelSeatHold, Ticket.cancelTicket, ScheduleShowtimesForm.cancelRequest | Các trách nhiệm có chữ cancel | UC-005, UC-008, UC-013, UC-014 | Cặp đã xét, giữ tách | Giữ tách: huỷ giữ ghế (GL-25), huỷ vé (GL-60) và huỷ yêu cầu đang nhập trên giao diện là ba khái niệm khác nhau | P05 mục 3 (giữ ghế, huỷ vé) |
| 41 | BoxOfficeClerk, TicketChecker, CinemaManager | Ba entity nhân viên cùng thuộc một cụm rạp, đều chỉ có provideCinema ngoài kiểm giữ ghế | UC-005, UC-009, UC-013, UC-014 | Cặp đã xét, giữ tách | Giữ ba entity, không tạo lớp cha Staff: Quản lý chuỗi (GL-41) là nhân viên nhưng không thuộc cụm rạp nào nên thuộc tính chung không đúng cho mọi nhân viên; chờ P07 của UC-017 (Q-108) | GL-34, GL-35, GL-36, GL-41, GL-42; BR-78, BR-79 |

### F2b. Thuộc tính tham chiếu lớp hoặc suy ra được

Bảng bổ sung ngoài khung F2a: thuộc tính mà P07 viết bằng kiểu khái niệm của một lớp khác, hoặc có thể suy ra từ quan hệ, được chuyển thành quan hệ hoặc hạ khỏi lớp.

| STT | Lớp | Thuộc tính gốc (UC) | Kết quả | Bằng chứng |
|---|---|---|---|---|
| 1 | Showtime | movieName (UC-006), movieTitle (UC-009), movie (UC-014) | Chuyển thành quan hệ Showtime 0..* - Movie 1 (R-43); tên phim lấy từ Movie.title | GL-47, BR-50; R7-11 |
| 2 | Showtime | auditoriumName (UC-009), auditorium (UC-014) | Chuyển thành quan hệ Auditorium 1 - Showtime 0..* (R-42); tên phòng lấy từ Auditorium.name | GL-47; R7-11 |
| 3 | Showtime | cinema (UC-005, UC-008, UC-009, UC-013) | Hạ: suy ra qua R-42 và R-38 (Showtime --> Auditorium --> Cinema) | GL-03, GL-40; Q-81, Q-98 |
| 4 | Showtime | auditoriumType (UC-005, UC-013, UC-014) | Giữ chờ Q-110: nếu loại phòng chụp lại lúc lập suất chiếu (BR-84) thì giữ, nếu tra theo phòng hiện tại thì hạ | BR-84, BR-64, BR-69; Q-110 |
| 5 | Showtime | scheduleStatus (UC-013) và status (UC-014) | Gộp thành status (Trong lịch chiếu, Đã xoá) | GL-49, BR-58; R7-11 |
| 6 | Showtime | lastChangedAt (UC-005, UC-014) | Gộp thành một thuộc tính | BR-54, BR-60; R7-11 |
| 7 | PriceList | cinema (UC-005, UC-013, UC-014) | Chuyển thành quan hệ Cinema 1 - PriceList 1 (R-40) | GL-01, GL-03 |
| 8 | Auditorium | cinema (UC-014) | Chuyển thành quan hệ Cinema 1 - Auditorium 4..12 (R-38) | GL-03, GL-40 |
| 9 | Auditorium | seatTypes (UC-014) | Hạ: suy ra từ Seat qua R-39 (provideSeatTypes lặp qua từng Seat) | GL-26, BR-69; Q-103 |
| 10 | SeatStatus | seatPosition, seatType (UC-005) | Chuyển sang Seat qua quan hệ R-45 | GL-07, GL-58; Q-81, Q-103 |
| 11 | Ticket | seatPosition, seatType (UC-005) | Hạ: suy ra qua R-54 (Ticket --> SeatStatus) và R-45 (SeatStatus --> Seat); giá vé price giữ vì là giá chốt (BR-67) | GL-59, BR-67 |
| 12 | BoxOfficeClerk | cinema (UC-005) | Chuyển thành quan hệ R-57 | BR-78, GL-35 |
| 13 | TicketChecker | cinema (UC-009) | Chuyển thành quan hệ R-58 | BR-78, GL-36 |
| 14 | CinemaManager | cinema (UC-013, UC-014) | Chuyển thành quan hệ R-59 | BR-78, GL-42 |

### F2c. Lớp và trách nhiệm mới cấp ở P08

| Mã hoặc trách nhiệm | Loại | Mô tả | Bằng chứng |
|---|---|---|---|
| AC-E-Cinema | Lớp mới | Tách từ thuộc tính cinema rút gọn của Showtime, PriceList, Auditorium, BoxOfficeClerk, TicketChecker, CinemaManager; chủ sở hữu UC-011; trạng thái Tạm | GL-03; Q-81, Q-98, Q-103 |
| AC-E-Seat | Lớp mới | Tách từ seatPosition, seatType của SeatStatus và seatTypes của Auditorium; chủ sở hữu UC-012; trạng thái Tạm | GL-07, GL-58, GL-26; Q-70, Q-81, Q-103 |
| Cinema.provideAuditoriums, Cinema.provideShowtimes | Trách nhiệm mới (chuyển từ control) | Xem F2a STT 30 | GL-03; A4 |
| Seat.provideSeatInfo | Trách nhiệm mới | Cung cấp vị trí và loại ghế cho SeatStatus, Ticket, Auditorium | GL-07 |
| BoxOfficeClerk.provideCinema | Trách nhiệm bổ sung | Thuộc tính cinema của nhân viên quầy chỉ được control truyền làm tham số ở UC-005 (checkBelongsToCinema), không có trách nhiệm cung cấp; đặt cùng tên và cùng nghĩa với CinemaManager.provideCinema và TicketChecker.provideCinema | BR-02, BR-78; UC-005 SD11a message 1.1.1b |

## F3. Bảng lớp hợp nhất

| AC | Stereotype | Tên | Trách nhiệm (gộp) | Thuộc tính | Dùng trong UC | Loại boundary | Trạng thái |
|---|---|---|---|---|---|---|---|
| AC-B-BookTicketsForm | boundary | BookTicketsForm | // selectShowtime: tác nhân chọn suất chiếu cần mua vé (UC-005)<br>// showSeatMap: hiển thị sơ đồ ghế và trạng thái ghế của suất chiếu (UC-005)<br>// confirmSeatSelection: tác nhân xác nhận chọn các ghế muốn mua (UC-005)<br>// showHeldSeats: hiển thị các ghế đã giữ, giá vé từng ghế, tổng tiền (UC-005)<br>// requestOnlinePayment: khách yêu cầu thanh toán trực tuyến (UC-005)<br>// showBookingSuccess: thông báo đặt vé thành công, hiển thị mã đặt vé và các vé (UC-005)<br>// notifyRefusal: thông báo từ chối hoặc kết thúc thất bại kèm lý do (UC-005)<br>// requestLogin: yêu cầu khách đăng nhập, giữ nguyên các ghế đã chọn (UC-005)<br>// provideCredentials: khách nhập email hoặc số điện thoại và mật khẩu (UC-005)<br>// cancelSeatHold: tác nhân huỷ việc giữ ghế (UC-005)<br>// updateSeatMap: cập nhật sơ đồ ghế đang hiển thị khi trạng thái ghế của suất chiếu đổi (REQ-119) (UC-005, UC-008) | selectedSeats (Các ghế đã chọn)<br>credentials (Thông tin đăng nhập) | UC-005, UC-008 | Giao diện người dùng | Hoạt động |
| AC-B-CounterBookTicketsForm | boundary | CounterBookTicketsForm | // selectShowtime: nhân viên quầy chọn suất chiếu cần bán vé (UC-005)<br>// notifyRefusal: thông báo từ chối kèm lý do, kể cả yêu cầu trả lại tiền mặt (UC-005)<br>// showSeatMap: hiển thị sơ đồ ghế và trạng thái ghế của suất chiếu (UC-005)<br>// confirmSeatSelection: nhân viên quầy xác nhận chọn các ghế khách muốn mua (UC-005)<br>// showHeldSeats: hiển thị các ghế đã giữ, giá vé từng ghế, tổng tiền (UC-005)<br>// confirmCashReceived: nhân viên quầy xác nhận đã thu tiền mặt (UC-005)<br>// showTicketsForPrint: hiển thị mã đặt vé và các vé để in (UC-005)<br>// printTickets: nhân viên quầy in vé cho khách mua tại quầy (UC-005)<br>// updateSeatMap: cập nhật sơ đồ ghế đang hiển thị khi trạng thái ghế của suất chiếu đổi (REQ-119) (UC-005) | selectedSeats (Các ghế đã chọn) | UC-005 | Giao diện người dùng | Hoạt động |
| AC-B-PaymentGateway | boundary | PaymentGateway | // createPaymentTransaction: chuyển yêu cầu tạo giao dịch thanh toán tới cổng thanh toán (UC-005)<br>// reportTransactionResult: nhận kết quả giao dịch do cổng thanh toán báo về (UC-005, UC-006)<br>// requestRefund: chuyển yêu cầu hoàn toàn bộ, kèm khoá chống hoàn trùng, tới cổng thanh toán và nhận kết quả hoàn tiền trả về trong 30 giây (UC-006, UC-008) | - | UC-005, UC-006, UC-008 | Giao diện hệ thống | Hoạt động |
| AC-B-EmailService | boundary | EmailService | // sendTicketsEmail: chuyển email chứa vé tới dịch vụ email (UC-005)<br>// sendRefundNotificationEmail: chuyển email thông báo hoàn tiền tới dịch vụ email (UC-006) | - | UC-005, UC-006 | Giao diện hệ thống | Hoạt động |
| AC-B-CancelTicketForm | boundary | CancelTicketForm | // selectTicketToCancel: khách chọn vé mua trực tuyến cần huỷ và yêu cầu huỷ vé (UC-008)<br>// notifyRefusal: thông báo từ chối hoặc kết thúc thất bại kèm lý do (UC-008)<br>// showCancellationResult: thông báo huỷ vé thành công, hiển thị vé đã huỷ, giá vé, số tiền hoàn, hình thức và tình trạng hoàn tiền (UC-008) | - | UC-008 | Giao diện người dùng | Hoạt động |
| AC-B-CounterCancelTicketForm | boundary | CounterCancelTicketForm | // enterBookingCode: nhân viên quầy nhập mã đặt vé của lần đặt chứa vé cần huỷ (UC-008)<br>// showBookingTickets: hiển thị các vé của lần đặt: vị trí ghế, giá vé, trạng thái vé (UC-008)<br>// selectTicketToCancel: nhân viên quầy chọn vé cần huỷ và yêu cầu huỷ vé (UC-008)<br>// notifyRefusal: thông báo từ chối kèm lý do, kể cả mã đặt vé không tồn tại (UC-008)<br>// showCashRefund: hiển thị số tiền mặt cần hoàn cho khách mua tại quầy (UC-008)<br>// confirmCashRefunded: nhân viên quầy xác nhận đã hoàn tiền mặt (UC-008)<br>// showCancellationResult: thông báo huỷ vé thành công, hiển thị vé đã huỷ, giá vé, số tiền hoàn, hình thức và tình trạng hoàn tiền (UC-008) | - | UC-008 | Giao diện người dùng | Hoạt động |
| AC-B-CheckTicketForm | boundary | CheckTicketForm | // selectCheckingShowtime: nhân viên soát vé chọn suất chiếu đang soát (UC-009)<br>// showCheckingShowtime: hiển thị thông tin suất chiếu đang soát và giữ suất chiếu này trong phiên làm việc (UC-009)<br>// scanTicketQr: nhân viên soát vé quét mã QR trên vé bằng camera của thiết bị (UC-009)<br>// showValidTicket: thông báo vé hợp lệ và hiển thị nội dung vé trừ mã QR (UC-009)<br>// rejectTicket: thông báo từ chối cho vào kèm một lý do (UC-009) | scannedQr (Mã QR của vé)<br>checkingShowtime (Suất chiếu đang soát, giữ trong phiên làm việc) | UC-009 | Giao diện người dùng | Hoạt động |
| AC-B-ManagePriceListForm | boundary | ManagePriceListForm | // requestPriceListSetup: quản lý cụm rạp yêu cầu thiết lập bảng giá (UC-013)<br>// showPriceList: hiển thị bảng giá của cụm rạp, giữ tình trạng từng mục giá lúc hiển thị (UC-013)<br>// enterPriceEntry: quản lý cụm rạp chọn tổ hợp, nhập giá vé rồi gửi (UC-013)<br>// notifyRefusal: thông báo từ chối kèm quy tắc bị vi phạm hoặc lý do (UC-013)<br>// showSavedPriceEntry: thông báo lưu giá thành công và hiển thị mục giá đã lưu (UC-013)<br>// requestPriceRemoval: quản lý cụm rạp chọn bỏ giá thay vì đặt giá (UC-013)<br>// selectPriceEntryToRemove: quản lý cụm rạp chọn mục giá cần bỏ (UC-013)<br>// showRemovalSuccess: thông báo bỏ giá thành công (UC-013)<br>// cancelRequest: quản lý cụm rạp huỷ yêu cầu (UC-013) | displayedPriceList (Bảng giá đang hiển thị)<br>enteredPriceEntry (Tổ hợp và giá vé đã nhập)<br>selectedPriceEntry (Mục giá chọn để bỏ) | UC-013 | Giao diện người dùng | Hoạt động |
| AC-B-ScheduleShowtimesForm | boundary | ScheduleShowtimesForm | // requestNewShowtime: quản lý cụm rạp yêu cầu lập suất chiếu mới (UC-014)<br>// requestEditShowtime: quản lý cụm rạp chọn sửa một suất chiếu đã lập (UC-014)<br>// requestDeleteShowtime: quản lý cụm rạp chọn xoá một suất chiếu đã lập (UC-014)<br>// showAuditoriumsAndMovies: hiển thị các phòng chiếu của cụm rạp và danh sách phim (UC-014)<br>// submitShowtimeInfo: quản lý cụm rạp chọn phim, định dạng, phòng chiếu, nhập giờ bắt đầu, thời điểm mở bán rồi gửi (UC-014)<br>// showShowtimes: hiển thị các suất chiếu đã lập của cụm rạp (UC-014)<br>// selectShowtimeToEdit: quản lý cụm rạp chọn suất chiếu cần sửa (UC-014)<br>// selectShowtimeToDelete: quản lý cụm rạp chọn suất chiếu cần xoá (UC-014)<br>// showShowtimeForEdit: hiển thị thông tin hiện tại của suất chiếu cùng các phòng chiếu và danh sách phim để sửa (UC-014)<br>// showSavedShowtime: thông báo lưu suất chiếu thành công và hiển thị suất chiếu đã lưu (UC-014)<br>// notifyDeleted: thông báo xoá suất chiếu thành công (UC-014)<br>// notifyRefusal: thông báo từ chối kèm quy tắc bị vi phạm, hoặc suất chiếu đã thay đổi hoặc không còn (UC-014)<br>// cancelRequest: quản lý cụm rạp huỷ yêu cầu (UC-014)<br>// showRequestCancelled: báo yêu cầu đã huỷ, không có suất chiếu nào thay đổi (UC-014) | showtimeInput (Thông tin suất chiếu đã nhập)<br>selectedShowtime (Suất chiếu được chọn, mốc đã hiển thị) | UC-014 | Giao diện người dùng | Hoạt động |
| AC-C-BookTicketsController | control | BookTicketsController | // startBooking: điều phối bước 2 và 3: kiểm tra suất chiếu rồi lấy sơ đồ ghế để hiển thị (UC-005)<br>// requestSeatHold: điều phối bước 5 đến 8: kiểm tra, giữ ghế, chờ hết hạn, hiển thị (UC-005)<br>// checkCustomerLoggedIn: xác định khách của phiên đã đăng nhập chưa (UC-005)<br>// startWaitingForHoldExpiry: bắt đầu chờ thời điểm hết hạn giữ ghế (BR-10) (UC-005)<br>// startOnlinePayment: điều phối bước 10: tạo giao dịch thanh toán, ghi nhận số tiền (UC-005)<br>// stopWaitingForHoldExpiry: ngừng chờ hết hạn khi tác nhân huỷ giữ ghế hoặc xác nhận thu tiền mặt (UC-005)<br>// handleHoldExpired: nhận sự kiện hết hạn, kết thúc lần giữ ghế và giải phóng ghế (UC-005)<br>// cancelSeatHold: điều phối việc huỷ giữ ghế và giải phóng ghế (UC-005)<br>// confirmCashReceived: điều phối bước 9a2 đến 9a4 khi nhân viên quầy xác nhận đã thu tiền mặt (UC-005) | - | UC-005 | - | Hoạt động |
| AC-C-PaymentReportController | control | PaymentReportController | // handlePaymentReport: tiếp nhận mọi báo kết quả giao dịch của cổng, tìm lần giữ ghế theo mã giao dịch hoặc mã tham chiếu lần giữ ghế, giao SeatHold thao tác xử lý báo rồi điều phối theo kết quả: bán ghế (bước 12 đến 15), thất bại khi lần giữ ghế còn hiệu lực (11a); các kết quả còn lại do UC-006 điều phối tiếp (UC-005, UC-006)<br>// logUnrecognizedTransaction: ghi log lỗi giao dịch không nhận ra để xử lý thủ công ngoài hệ thống (BR-38) (UC-006)<br>// startWaitingForRefundResult: bắt đầu chờ kết quả hoàn tiền tối đa 30 giây (BR-43) (UC-006)<br>// stopWaitingForRefundResult: ngừng chờ khi cổng đã trả kết quả hoàn tiền (UC-006)<br>// handleRefundNoResponse: nhận sự kiện hết 30 giây không có kết quả hoàn tiền: ghi nhận, kiểm lượt thử lại (after BR-43) (UC-006)<br>// logRefundFailure: ghi log lỗi khoản hoàn khi hết lượt thử lại, không gửi email (BR-41) (UC-006) | - | UC-005, UC-006 | - | Hoạt động |
| AC-C-CancelTicketController | control | CancelTicketController | // requestCancellation: điều phối bước 2 đến 8 cho vé mua trực tuyến: kiểm tra, ghi nhận huỷ, hoàn tiền qua cổng, trả ghế, báo kết quả (UC-008)<br>// findBookingTickets: điều phối bước 1a1, 1a1a, 1a2: tìm lần đặt theo mã đặt vé và lấy các vé để hiển thị (UC-008)<br>// confirmCashRefund: điều phối bước 5a2, 7, 8 khi nhân viên quầy xác nhận đã hoàn tiền mặt (UC-008)<br>// startWaitingForRefundResult: bắt đầu chờ kết quả hoàn tiền của cổng thanh toán (BR-43) (UC-008)<br>// stopWaitingForRefundResult: ngừng chờ khi cổng thanh toán đã trả kết quả hoàn tiền (UC-008)<br>// handleRefundNoResponse: nhận sự kiện hết 30 giây không có kết quả hoàn tiền (BR-43) (UC-008)<br>// logRefundFailure: ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống, không gửi email cho khách (BR-41) (UC-008) | - | UC-008 | - | Hoạt động |
| AC-C-CheckTicketController | control | CheckTicketController | // startChecking: điều phối bước 2: lấy cụm rạp của nhân viên, kiểm tra suất chiếu thuộc cụm rạp rồi lấy thông tin suất chiếu để hiển thị (UC-009)<br>// checkTicket: điều phối bước 4 đến 6 và 4a đến 4e: lấy cụm rạp của nhân viên, xác định vé từ mã QR, yêu cầu vé cho vào, hiển thị hợp lệ hoặc lý do (UC-009) | - | UC-009 | - | Hoạt động |
| AC-C-ManagePriceListController | control | ManagePriceListController | // startPriceListSetup: điều phối bước 1 và 2: xác định cụm rạp của quản lý, lấy bảng giá để hiển thị (UC-013)<br>// submitPriceEntry: điều phối bước 4 đến 6: kiểm tra giá vé, lưu giá, báo kết quả (UC-013)<br>// startPriceRemoval: điều phối bước 1a1: xác định cụm rạp của quản lý, lấy bảng giá để hiển thị (UC-013)<br>// submitPriceEntryRemoval: điều phối bước 1a3 và 1a4: bỏ giá, báo kết quả (UC-013)<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu (UC-013)<br>// discardRequest: bỏ yêu cầu, không đổi bảng giá (luồng *a) (UC-013) | - | UC-013 | - | Hoạt động |
| AC-C-ScheduleShowtimesController | control | ScheduleShowtimesController | // startScheduling: điều phối bước 2: lấy cụm rạp của quản lý, các phòng chiếu và phim để hiển thị (UC-014)<br>// requestSaveShowtime: điều phối bước 4 đến 9: kiểm phòng chiếu, định dạng, bảng giá, ngày giờ, tính giờ kết thúc, lưu suất chiếu và báo kết quả (lập mới hoặc sửa) (UC-014)<br>// startEditingShowtime: điều phối bước 1a1: lấy các suất chiếu đã lập của cụm rạp để hiển thị (UC-014)<br>// prepareShowtimeEdit: điều phối bước 1a3, 1a4: kiểm suất chiếu chọn chưa tới giờ bắt đầu và không có ghế giữ, vé chưa huỷ rồi hiển thị để sửa (UC-014)<br>// startDeletingShowtime: điều phối bước 1b1: lấy các suất chiếu đã lập của cụm rạp để hiển thị (UC-014)<br>// deleteShowtime: điều phối bước 1b3, 1b4: xoá suất chiếu khỏi lịch chiếu và báo kết quả (UC-014)<br>// cancelRequest: điều phối luồng *a: huỷ yêu cầu (UC-014)<br>// discardRequest: bỏ yêu cầu đang xử lý, không thay đổi suất chiếu nào (UC-014) | - | UC-014 | - | Hoạt động |
| AC-E-Customer | entity | Customer | // checkNoActiveSeatHold: kiểm tra khách không có lần giữ ghế nào chưa kết thúc (BR-04) (UC-005)<br>// authenticateCustomer: đối chiếu email hoặc số điện thoại và mật khẩu với tài khoản khách (UC-005)<br>// provideEmail: cung cấp email của tài khoản khách đã giữ ghế (UC-006) | email (Văn bản)<br>phoneNumber (Văn bản)<br>password (Văn bản) | UC-005, UC-006 | - | Tạm (chờ P07 của UC-001) |
| AC-E-BoxOfficeClerk | entity | BoxOfficeClerk | // checkNoActiveSeatHold: kiểm tra nhân viên quầy không có lần giữ ghế nào chưa kết thúc (BR-04) (UC-005)<br>// provideCinema: cung cấp cụm rạp mà nhân viên quầy thuộc về để kiểm tra suất chiếu thuộc cụm rạp (BR-02) (UC-005, UC-008) | - | UC-005, UC-008 | - | Tạm (chờ P07 của UC-017) |
| AC-E-TicketChecker | entity | TicketChecker | // provideCinema: cung cấp cụm rạp mà nhân viên soát vé thuộc về để kiểm tra suất chiếu và vé (BR-22, BR-34) (UC-009) | - | UC-009 | - | Tạm (chờ P07 của UC-017) |
| AC-E-CinemaManager | entity | CinemaManager | // provideCinema: cung cấp cụm rạp mà quản lý cụm rạp thuộc về, để chỉ xem và sửa bảng giá cụm mình (BR-61) (UC-013, UC-014) | - | UC-013, UC-014 | - | Tạm (chờ P07 của UC-017) |
| AC-E-Cinema | entity | Cinema | // provideAuditoriums: cung cấp thông tin các phòng chiếu của cụm rạp để hiển thị, đi qua từng phòng chiếu (UC-014)<br>// provideShowtimes: cung cấp các suất chiếu đã lập của các phòng chiếu thuộc cụm rạp để hiển thị, đi qua từng phòng chiếu (UC-014) | - | UC-014 (trách nhiệm); tham chiếu: UC-005, UC-008, UC-009, UC-013 | - | Tạm (chờ P07 của UC-011) |
| AC-E-Auditorium | entity | Auditorium | // provideAuditoriumInfo: cung cấp tên phòng, loại phòng, các định dạng chiếu được để hiển thị (UC-014)<br>// checkBelongsToCinema: kiểm tra phòng chiếu thuộc cụm rạp của quản lý cụm rạp (BR-46) (UC-014)<br>// checkSupportsFormat: kiểm tra phòng chiếu chiếu được định dạng đã chọn (BR-48) (UC-014)<br>// provideSeatTypes: cung cấp loại phòng và các loại ghế có ít nhất một ghế trong phòng chiếu, đi qua từng Seat (BR-69) (UC-014)<br>// draftShowtime: tạo suất chiếu dự kiến của phòng chiếu từ dữ liệu quản lý cụm rạp nhập (Creator) (UC-014)<br>// saveShowtime: thao tác không chia cắt: kiểm suất chiếu, bảng giá, khoảng cách dọn phòng rồi ghi suất chiếu vào lịch phòng (BR-51, BR-52, BR-53, BR-54, BR-57, BR-60, BR-68, BR-69) (UC-014)<br>// checkRoomGap: kiểm tra suất chiếu cách các suất chiếu khác trong phòng ít nhất 15 phút dọn phòng (BR-51) (UC-014)<br>// addToSchedule: ghi suất chiếu dự kiến vào lịch chiếu của phòng (UC-014) | name (Văn bản)<br>auditoriumType (Văn bản)<br>supportedFormats (Văn bản) | UC-014 | - | Tạm (chờ P07 của UC-012) |
| AC-E-Seat | entity | Seat | // provideSeatInfo: cung cấp vị trí ghế (mã hàng, số ghế) và loại ghế (UC-005, UC-008, UC-009, UC-014) | seatPosition (Mã hàng, số ghế)<br>seatType (Văn bản) | UC-005, UC-008, UC-009, UC-014 | - | Tạm (chờ P07 của UC-012) |
| AC-E-Movie | entity | Movie | // provideMovieInfo: cung cấp tên, các định dạng phát hành, thời lượng, ngày khởi chiếu, ngày kết thúc chiếu để hiển thị (UC-014)<br>// checkReleasedInFormat: kiểm tra định dạng đã chọn là định dạng phát hành của phim (BR-47) (UC-014)<br>// checkWithinRunPeriod: kiểm tra ngày chiếu nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu (BR-49) (UC-014)<br>// provideDuration: cung cấp thời lượng phim để tính giờ kết thúc (BR-50) (UC-014) | title (Văn bản)<br>releaseFormats (Văn bản)<br>duration (Số phút)<br>releaseDate (Ngày)<br>endOfRunDate (Ngày) | UC-014 | - | Tạm (chờ P07 của UC-010) |
| AC-E-Showtime | entity | Showtime | // checkSaleOpen: kiểm tra đã tới thời điểm mở bán và chưa tới giờ bắt đầu (BR-01, BR-45) (UC-005)<br>// provideSeatMap: cung cấp sơ đồ ghế kèm trạng thái ghế của suất chiếu (UC-005)<br>// checkSeatSelectionLimit: kiểm tra các ghế chọn thuộc sơ đồ ghế và không vượt số ghế tối đa (BR-05, BR-06) (UC-005)<br>// holdSeats: thao tác không chia cắt: kiểm tra, giữ cả nhóm ghế và chốt giá vé; loại trừ theo suất chiếu và theo người giữ ghế (BR-04, BR-07, BR-09, BR-54, BR-65, BR-71) (UC-005)<br>// checkUnchangedSinceDisplayed: kiểm tra suất chiếu chưa bị sửa hoặc xoá kể từ lúc hiển thị sơ đồ ghế (BR-54) (UC-005, UC-014)<br>// checkBelongsToCinema: kiểm tra suất chiếu thuộc cụm rạp của nhân viên bằng cách hỏi phòng chiếu của suất chiếu (BR-02, BR-17, BR-22, BR-34) (UC-005, UC-008, UC-009)<br>// checkCancellationDeadline: kiểm tra thời điểm kiểm tra cách giờ bắt đầu ít nhất 2 tiếng (BR-18, BR-32) (UC-008)<br>// checkUsesPriceEntry: kiểm tra suất chiếu chưa tới giờ bắt đầu, còn trong lịch chiếu, cùng loại phòng, định dạng, khung giờ (hỏi PriceList xác định từ giờ bắt đầu) và có ghế thuộc loại ghế của mục giá (BR-64) (UC-013)<br>// createShowtime: khởi tạo suất chiếu dự kiến với phim, định dạng, phòng chiếu, giờ bắt đầu, thời điểm mở bán (UC-014)<br>// checkSaleOpenBeforeStart: kiểm tra thời điểm mở bán trước giờ bắt đầu (BR-55) (UC-014)<br>// calculateEndTime: tính giờ kết thúc bằng giờ bắt đầu cộng thời lượng phim (BR-50) (UC-014)<br>// checkNotStarted: kiểm tra giờ bắt đầu sau thời điểm kiểm tra, tức suất chiếu chưa tới giờ bắt đầu (BR-56, BR-57) (UC-014)<br>// checkNoActiveHoldOrSoldTicket: kiểm tra suất chiếu không có lần giữ ghế còn hiệu lực (hỏi từng lần giữ ghế) và không có vé chưa bị huỷ (hỏi từng vé) (BR-53) (UC-014)<br>// applyChanges: ghi thông tin mới của suất chiếu và đặt lại mốc thay đổi (BR-84) (UC-014)<br>// removeFromSchedule: thao tác không chia cắt: kiểm rồi xoá suất chiếu khỏi lịch chiếu, giữ lại dữ liệu (BR-53, BR-54, BR-57, BR-58, BR-60) (UC-014)<br>// markDeleted: đánh dấu suất chiếu Đã xoá, ngừng bán vé, giữ dữ liệu (BR-58) (UC-014)<br>// provideShowtimeInfo: cung cấp tên phim, định dạng, cụm rạp, phòng chiếu và loại phòng, ngày giờ bắt đầu, giờ kết thúc, thời điểm mở bán, mốc thay đổi gần nhất để hiển thị; mỗi use case lấy phần dữ liệu mình cần; đọc được cả suất chiếu Đã xoá (BR-58) (UC-006, UC-009, UC-014) | startTime (Ngày giờ)<br>saleOpenTime (Ngày giờ)<br>endTime (Ngày giờ)<br>lastChangedAt (Ngày giờ)<br>movieFormat (Văn bản)<br>auditoriumType (Văn bản, chờ Q-110)<br>status (Trong lịch chiếu, Đã xoá) | UC-005, UC-006, UC-008, UC-009, UC-013, UC-014 | - | Hoạt động |
| AC-E-PriceList | entity | PriceList | // determineSeatPrice: xác định giá vé theo loại phòng, định dạng phim, loại ghế và khung giờ do bảng giá tự xác định từ giờ bắt đầu (BR-11, BR-12, BR-72) (UC-005)<br>// providePriceEntries: cung cấp các mục giá của bảng giá kèm tình trạng từng mục giá lúc hiển thị (BR-62) (UC-013)<br>// checkTicketPriceValid: kiểm tra giá vé là số nguyên đồng lớn hơn 0 (BR-70) (UC-013)<br>// savePriceEntry: thao tác không chia cắt: kiểm tra mục giá của tổ hợp chưa bị đổi, tạo mục giá hoặc đổi giá, có hiệu lực ngay (BR-62, BR-63, BR-66, BR-71) (UC-013)<br>// checkEntryUnchangedSinceDisplayed: kiểm tra mục giá của tổ hợp chưa bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị (BR-63) (UC-013)<br>// findOrCreatePriceEntry: tìm mục giá của tổ hợp, chưa có thì tạo mục giá mới trong bảng giá (BR-62) (UC-013)<br>// removePriceEntry: thao tác không chia cắt: kiểm tra mục giá chưa bị đổi, kiểm tra không còn suất chiếu đang dùng, bỏ mục giá (BR-63, BR-64, BR-68, BR-71) (UC-013)<br>// deletePriceEntry: bỏ mục giá khỏi bảng giá, ghi mốc thay đổi của tổ hợp (UC-013)<br>// determineTimeBand: xác định khung giờ chiếu từ giờ bắt đầu (BR-12), nơi duy nhất xác định khung giờ cho UC-005, UC-013 và UC-014 (UC-013)<br>// checkCoversShowtime: kiểm tra bảng giá của cụm rạp có giá cho mọi loại ghế của phòng chiếu, ứng với khung giờ xác định từ giờ bắt đầu (BR-12), theo loại phòng và định dạng (BR-68, BR-69) (UC-014) | entryChangeTimes (Mốc thay đổi của từng tổ hợp, kể cả tổ hợp đã bỏ) | UC-005, UC-013, UC-014 | - | Hoạt động |
| AC-E-PriceEntry | entity | PriceEntry | // provideEntryInfo: cung cấp loại phòng, định dạng phim, loại ghế, khung giờ chiếu, giá vé và mốc thay đổi để hiển thị (UC-013)<br>// setTicketPrice: ghi giá vé của mục giá và mốc thay đổi, không đổi giá đã chốt của lần giữ ghế và vé đã bán (BR-65, BR-67) (UC-013) | auditoriumType (Văn bản)<br>movieFormat (Văn bản)<br>seatType (Văn bản)<br>timeBand (Văn bản)<br>ticketPrice (Số tiền)<br>lastChangedAt (Ngày giờ) | UC-013 | - | Hoạt động |
| AC-E-SeatStatus | entity | SeatStatus | // provideSeatStatus: cung cấp vị trí ghế và loại ghế (hỏi Seat) cùng trạng thái ghế để hiển thị (UC-005)<br>// holdSeatFor: chuyển ghế sang đang được giữ cho một lần giữ ghế khi ghế còn trống (BR-07, BR-08, BR-09) (UC-005)<br>// recordHeldPrice: ghi giá vé đã chốt của ghế (BR-65) (UC-005)<br>// provideHeldSeatInfo: cung cấp vị trí ghế, loại ghế (hỏi Seat) và giá vé đã chốt của ghế đang giữ (UC-005)<br>// markSold: chuyển ghế đang giữ sang đã bán (UC-005)<br>// releaseSeat: chuyển ghế về trống từ đang được giữ (kết thúc lần giữ ghế) hoặc từ đã bán (vé đã huỷ, BR-42); tiền điều kiện: ghế còn thuộc đúng lần giữ ghế hoặc đúng vé đó; chạy lại không hại (REQ-76) (UC-005, UC-008) | status (Trống, Đang được giữ, Đã bán)<br>heldPrice (Số tiền) | UC-005, UC-008 | - | Hoạt động |
| AC-E-SeatHold | entity | SeatHold | // createSeatHold: tạo lần giữ ghế cho người giữ, đặt thời điểm hết hạn theo BR-10 (UC-005)<br>// provideHoldSummary: cung cấp các ghế đã giữ, giá vé từng ghế, tổng tiền (UC-005)<br>// calculateTotalAmount: tính tổng tiền bằng tổng giá vé đã chốt của các ghế đã giữ (UC-005)<br>// recordPaymentTransaction: tạo giao dịch thanh toán gắn với lần giữ ghế, ghi số tiền (REQ-111); dùng cho cả giao dịch thứ hai của UC-006 (UC-005, UC-006)<br>// settlePaymentReport: trách nhiệm duy nhất xử lý báo kết quả giao dịch của cổng, thao tác không chia cắt theo lần giữ ghế, trả về một trong bốn kết quả: bán ghế (kiểm chưa xử lý, còn hiệu lực, đánh dấu đã xử lý, bán ghế, hoàn tất, tạo lần đặt cùng vé), thanh toán trễ chờ hoàn, báo trùng, thất bại ghi nhận; lần giữ ghế Đang giữ mà quá hạn được chuyển sang Hết hạn trước (BR-14, BR-15, BR-37, BR-85, BR-86) (UC-005, UC-006)<br>// checkHoldStillActive: kiểm tra lần giữ ghế còn Đang giữ và chưa quá thời điểm hết hạn tại thời điểm xử lý; dùng chung cho UC-005, UC-006 và UC-014 (BR-04, BR-53, BR-85, BR-86) (UC-005, UC-006, UC-014)<br>// endHold: chuyển lần giữ ghế sang một trạng thái cuối (Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại); chỉ đổi khi chưa ở trạng thái cuối (UC-005)<br>// issueBooking: tạo lần đặt cho lần giữ ghế đã hoàn tất, trong cùng thao tác bán ghế (UC-005)<br>// expire: kết thúc lần giữ ghế ở trạng thái Hết hạn khi tới thời điểm hết hạn hoặc khi báo thanh toán đến sau thời điểm đó; không đổi nếu đã ở trạng thái cuối (UC-005)<br>// releaseHeldSeats: giải phóng từng ghế đang giữ về trống (chậm nhất 1 phút sau thời điểm hết hạn, REQ-76); chạy lại không hại và chạy được cả khi lần giữ ghế đã ở trạng thái cuối mà ghế còn đang giữ (UC-005)<br>// cancel: kết thúc lần giữ ghế ở trạng thái Đã huỷ khi tác nhân huỷ (UC-005)<br>// completeSaleOnCashConfirmation: thao tác không chia cắt theo lần giữ ghế khi nhân viên quầy xác nhận đã thu tiền: so thời điểm, bán ghế, hoàn tất, tạo lần đặt cùng vé (BR-44, BR-85) (UC-005)<br>// provideRefundNoticeRecipient: cung cấp email của khách giữ ghế, tên phim và giờ bắt đầu suất chiếu cho email hoàn tiền (UC-006)<br>// checkHeldBy: kiểm tra người giữ ghế của lần giữ ghế là tác nhân huỷ vé và cho biết kênh mua (BR-17) (UC-008)<br>// providePaymentTransaction: cung cấp giao dịch thanh toán đã xử lý thành công của lần giữ ghế (UC-008) | holdRef (Văn bản)<br>status (Đang giữ, Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại)<br>holdTime (Ngày giờ)<br>expiryTime (Ngày giờ) | UC-005, UC-006, UC-008, UC-014 | - | Hoạt động |
| AC-E-PaymentTransaction | entity | PaymentTransaction | // createPaymentTransaction: tạo giao dịch thanh toán với mã giao dịch và số tiền (UC-005, UC-006)<br>// checkNotProcessed: kiểm tra giao dịch chưa dùng để tạo vé và chưa ghi nhận thanh toán trễ, nên chỉ báo đầu tiên được xử lý (BR-37) (UC-005, UC-006)<br>// markProcessed: đánh dấu giao dịch đã xử lý để tạo vé (UC-005)<br>// recordFailedResult: ghi nhận kết quả thất bại của giao dịch (UC-005, UC-006)<br>// markLatePayment: ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền, kèm lý do hoàn, đã xử lý (BR-14, BR-15, BR-40) (UC-006)<br>// recordDuplicateReport: ghi nhận lần báo trùng, không hoàn thêm (BR-37) (UC-006)<br>// prepareRefundRequest: kiểm khoản hoàn không vượt số tiền đã thanh toán rồi tạo yêu cầu hoàn gắn giao dịch (BR-26, BR-43) (UC-006, UC-008)<br>// checkRefundWithinPaidAmount: kiểm tổng đã hoàn cộng khoản hoàn không vượt số tiền đã thanh toán (BR-26) (UC-006, UC-008)<br>// recordRefundedAmount: cộng số tiền hoàn vào tổng đã hoàn của giao dịch (BR-26) (UC-006, UC-008)<br>// provideRefundSummary: cung cấp mã giao dịch, số tiền hoàn và lý do hoàn cho email (UC-006) | transactionCode (Văn bản)<br>amount (Số tiền)<br>processed (Chưa xử lý, Đã tạo vé, Đã ghi nhận thanh toán trễ)<br>result (Thành công, Thất bại)<br>lateReason (Văn bản)<br>refundedTotal (Số tiền)<br>duplicateReportCount (Số lượng) | UC-005, UC-006, UC-008 | - | Hoạt động |
| AC-E-RefundRequest | entity | RefundRequest | // createRefundRequest: tạo yêu cầu hoàn gắn giao dịch, loại yêu cầu và số tiền hoàn (BR-43) (UC-006, UC-008)<br>// generateIdempotencyKey: sinh khoá chống hoàn trùng từ mã giao dịch và loại yêu cầu, không đổi qua các lần thử lại (BR-43) (UC-006, UC-008)<br>// recordAttempt: ghi nhận một lần gửi yêu cầu hoàn tới cổng (UC-006, UC-008)<br>// recordResult: ghi nhận kết quả của lần gửi: thành công, thất bại, không phản hồi (UC-006, UC-008)<br>// checkRetryRemaining: kiểm còn lượt thử lại (BR-41) (UC-006, UC-008)<br>// provideRefundInfo: cung cấp số tiền hoàn và tình trạng hoàn tiền (đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi) để hiển thị (UC-008) | idempotencyKey (Văn bản)<br>requestType (Hoàn toàn bộ, Hoàn một vé qua cổng, Hoàn một vé bằng tiền mặt)<br>refundAmount (Số tiền)<br>attemptCount (Số lượng)<br>result (Văn bản) | UC-006, UC-008 | - | Hoạt động |
| AC-E-Booking | entity | Booking | // createBooking: tạo lần đặt cho các ghế đã bán (UC-005)<br>// generateBookingCode: sinh mã đặt vé duy nhất toàn hệ thống (BR-80) (UC-005)<br>// provideBookingInfo: cung cấp mã đặt vé và nội dung các vé của lần đặt (UC-005, UC-008)<br>// checkCancellationChannel: kiểm tra kênh mua vé của lần đặt khớp tác nhân huỷ vé (BR-17) (UC-008)<br>// providePaymentTransaction: cung cấp giao dịch thanh toán của lần đặt để hoàn tiền (UC-008)<br>// provideBookingCode: cung cấp mã đặt vé in trên vé (BR-80) (UC-009) | bookingCode (Văn bản) | UC-005, UC-008, UC-009 | - | Hoạt động |
| AC-E-Ticket | entity | Ticket | // createTicket: tạo vé cho một ghế, ghi giá vé đã chốt (BR-67) (UC-005)<br>// generateQrCode: sinh mã QR riêng của vé từ mã vé (UC-005)<br>// provideTicketContent: cung cấp nội dung vé để hiển thị hoặc gửi: mã đặt vé, thông tin suất chiếu, vị trí ghế và loại ghế (hỏi SeatStatus, Seat), giá vé, trạng thái; kèm số tiền hoàn và tình trạng hoàn tiền lấy từ yêu cầu hoàn của vé khi có (REQ-105) (UC-005, UC-008, UC-009)<br>// cancelTicket: thao tác không chia cắt: kiểm tra vé chưa huỷ và chưa sử dụng rồi ghi nhận vé đã huỷ (BR-21, BR-30) (UC-008)<br>// checkNotCancelledNotUsed: kiểm tra vé chưa huỷ (trước) rồi chưa sử dụng (BR-21, BR-30) (UC-008)<br>// markCancelled: chuyển trạng thái vé sang đã huỷ (UC-008)<br>// calculateRefundAmount: tính số tiền hoàn bằng 70% giá vé, làm tròn xuống đồng (BR-19, BR-31) (UC-008)<br>// recordCashRefund: ghi nhận khoản hoàn tiền mặt của vé bằng cách tạo yêu cầu hoàn tiền mặt có kết quả đã hoàn (BR-20) (UC-008)<br>// releaseTicketSeat: trả ghế của vé về trống sau khi vé đã huỷ, bằng cách gọi SeatStatus.releaseSeat (BR-42) (UC-008)<br>// admitTicket: thao tác không chia cắt: kiểm tra cụm rạp, suất chiếu, đã sử dụng, đã huỷ theo thứ tự BR-33 và khi hợp lệ đánh dấu đã sử dụng; trả về hợp lệ hoặc một lý do duy nhất (BR-22 đến BR-25, BR-30, BR-33) (UC-009)<br>// markUsed: chuyển trạng thái vé từ chưa sử dụng sang đã sử dụng (REQ-52) (UC-009)<br>// checkNotCancelled: kiểm tra vé chưa bị huỷ (BR-53) (UC-014) | ticketCode (Văn bản)<br>qrCode (Hình ảnh)<br>price (Số tiền)<br>status (Chưa sử dụng, Đã sử dụng, Đã huỷ) | UC-005, UC-008, UC-009, UC-014 | - | Hoạt động |

Tổng cộng 32 lớp: 9 boundary, 6 control, 17 entity (24 lớp Hoạt động, 8 lớp Tạm), 207 trách nhiệm. Không lớp nào có trạng thái Gộp vào: không mã AC nào bị xoá hoặc tái sử dụng (C3). Entity cốt lõi của chủ đề race condition, giữ ghế và giải phóng ghế: AC-E-SeatHold, AC-E-SeatStatus, AC-E-Showtime, AC-E-Ticket, AC-E-PriceList, AC-E-Auditorium, AC-E-PaymentTransaction.

## F4. Bảng quan hệ

Số ở phía A là số đối tượng A ứng với một đối tượng B, vẽ ở đầu A. Tám lớp Tạm làm các quan hệ R-38, R-39, R-45, R-57, R-58, R-59 chờ P07 của UC-011, UC-012, UC-017.

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn UC | Bằng chứng | Ghi chú |
|---|---|---|---|---|---|---|---|---|
| R-01 | AC-B-BookTicketsForm | AC-C-BookTicketsController | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-01 |
| R-02 | AC-B-CounterBookTicketsForm | AC-C-BookTicketsController | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-02 |
| R-03 | AC-B-PaymentGateway | AC-C-BookTicketsController | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-03 |
| R-04 | AC-B-EmailService | AC-C-PaymentReportController | Association | - | - | UC-005, UC-006 | VOPC UC-005, UC-006 (link giao tiếp) | Tạm thời; R-UC005-04, R-UC006-02 |
| R-05 | AC-B-PaymentGateway | AC-C-PaymentReportController | Association | - | - | UC-005, UC-006 | VOPC UC-005, UC-006 (link giao tiếp) | Tạm thời; R-UC005-20, R-UC006-01 |
| R-06 | AC-B-BookTicketsForm | AC-C-PaymentReportController | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-23 |
| R-07 | AC-C-BookTicketsController | AC-E-Customer | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-05 |
| R-08 | AC-C-BookTicketsController | AC-E-BoxOfficeClerk | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-06 |
| R-09 | AC-C-BookTicketsController | AC-E-Showtime | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-07 |
| R-10 | AC-C-BookTicketsController | AC-E-SeatHold | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-08 |
| R-11 | AC-C-BookTicketsController | AC-E-Booking | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-09 |
| R-12 | AC-C-PaymentReportController | AC-E-SeatHold | Association | - | - | UC-005, UC-006 | VOPC UC-005, UC-006 (link giao tiếp) | Tạm thời; R-UC005-21, R-UC006-03 |
| R-13 | AC-C-PaymentReportController | AC-E-Booking | Association | - | - | UC-005 | VOPC UC-005 (link giao tiếp) | Tạm thời; R-UC005-22 |
| R-14 | AC-C-PaymentReportController | AC-E-PaymentTransaction | Association | - | - | UC-006 | VOPC UC-006 (link giao tiếp) | Tạm thời; R-UC006-04 |
| R-15 | AC-C-PaymentReportController | AC-E-RefundRequest | Association | - | - | UC-006 | VOPC UC-006 (link giao tiếp) | Tạm thời; R-UC006-05 |
| R-16 | AC-B-CancelTicketForm | AC-C-CancelTicketController | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-01 |
| R-17 | AC-B-CounterCancelTicketForm | AC-C-CancelTicketController | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-02 |
| R-18 | AC-B-PaymentGateway | AC-C-CancelTicketController | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-03 |
| R-19 | AC-B-BookTicketsForm | AC-C-CancelTicketController | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-04; ngoại lệ boundary người dùng dùng chung, xem F2a STT 20 |
| R-20 | AC-C-CancelTicketController | AC-E-Ticket | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-05 |
| R-21 | AC-C-CancelTicketController | AC-E-Booking | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-06 |
| R-22 | AC-C-CancelTicketController | AC-E-Showtime | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-07 |
| R-23 | AC-C-CancelTicketController | AC-E-PaymentTransaction | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-08 |
| R-24 | AC-C-CancelTicketController | AC-E-RefundRequest | Association | - | - | UC-008 | VOPC UC-008 (link giao tiếp) | Tạm thời; R-UC008-15 |
| R-25 | AC-B-CheckTicketForm | AC-C-CheckTicketController | Association | - | - | UC-009 | VOPC UC-009 (link giao tiếp) | Tạm thời; R-UC009-01 |
| R-26 | AC-C-CheckTicketController | AC-E-TicketChecker | Association | - | - | UC-009 | VOPC UC-009 (link giao tiếp) | Tạm thời; R-UC009-02 |
| R-27 | AC-C-CheckTicketController | AC-E-Showtime | Association | - | - | UC-009 | VOPC UC-009 (link giao tiếp) | Tạm thời; R-UC009-03 |
| R-28 | AC-C-CheckTicketController | AC-E-Ticket | Association | - | - | UC-009 | VOPC UC-009 (link giao tiếp) | Tạm thời; R-UC009-04 |
| R-29 | AC-B-ManagePriceListForm | AC-C-ManagePriceListController | Association | - | - | UC-013 | VOPC UC-013 (link giao tiếp) | Tạm thời; R-UC013-01 |
| R-30 | AC-C-ManagePriceListController | AC-E-CinemaManager | Association | - | - | UC-013 | VOPC UC-013 (link giao tiếp) | Tạm thời; R-UC013-02 |
| R-31 | AC-C-ManagePriceListController | AC-E-PriceList | Association | - | - | UC-013 | VOPC UC-013 (link giao tiếp) | Tạm thời; R-UC013-03 |
| R-32 | AC-B-ScheduleShowtimesForm | AC-C-ScheduleShowtimesController | Association | - | - | UC-014 | VOPC UC-014 (link giao tiếp) | Tạm thời; R-UC014-01 |
| R-33 | AC-C-ScheduleShowtimesController | AC-E-CinemaManager | Association | - | - | UC-014 | VOPC UC-014 (link giao tiếp) | Tạm thời; R-UC014-02 |
| R-34 | AC-C-ScheduleShowtimesController | AC-E-Auditorium | Association | - | - | UC-014 | VOPC UC-014 (link giao tiếp) | Tạm thời; R-UC014-03 |
| R-35 | AC-C-ScheduleShowtimesController | AC-E-Movie | Association | - | - | UC-014 | VOPC UC-014 (link giao tiếp) | Tạm thời; R-UC014-04 |
| R-36 | AC-C-ScheduleShowtimesController | AC-E-Showtime | Association | - | - | UC-014 | VOPC UC-014 (link giao tiếp) | Tạm thời; R-UC014-05 |
| R-37 | AC-C-ScheduleShowtimesController | AC-E-PriceList | Association | - | - | UC-014 | VOPC UC-014 (link giao tiếp) | Tạm thời; R-UC014-06 |
| R-38 | AC-E-Cinema | AC-E-Auditorium | Aggregation | A 1 - B 4..12 | - | Mới ở P08 | GL-03 "gồm nhiều Phòng chiếu"; REQ-01 qua ghi chú GL-03 "mỗi cụm có 4 đến 12 phòng chiếu"; GL-40 "Phòng trong một Cụm rạp" | Mới ở P08; tách theo Q-81; aggregation vì nguồn không có câu về vòng đời phụ thuộc, Q-107 |
| R-39 | AC-E-Auditorium | AC-E-Seat | Aggregation | A 1 - B 50..400 | - | Mới ở P08 | GL-07 "Vị trí ngồi trong một Phòng chiếu"; GL-50 và REQ-03 sức chứa từ 50 đến 400 ghế (ghế đôi tính là một ghế, BR-06) | Mới ở P08; tách theo Q-81, Q-103; Q-107 |
| R-40 | AC-E-Cinema | AC-E-PriceList | Association | A 1 - B 1 | - | Mới ở P08 | GL-01 "Mỗi Cụm rạp một bảng giá riêng"; GL-03 "có Bảng giá riêng" | Mới ở P08; thay đường Cụm rạp rút gọn của R-UC005-12, R-UC013-05, R-UC014-08 |
| R-41 | AC-E-PriceList | AC-E-PriceEntry | Composition | A 1 - B 0..72 | - | UC-013 | BR-62 (mỗi tổ hợp tối đa một mục giá); GL-01, GL-33; tối đa 3 x 2 x 3 x 4 = 72 mục giá (UC-013 Mục 8); bỏ mục giá là bỏ khỏi bảng giá (UC-013 luồng 1a) | R-UC013-04 |
| R-42 | AC-E-Auditorium | AC-E-Showtime | Association | A 1 - B 0..* | - | UC-014 | GL-47 "trong một Phòng chiếu"; BR-51, BR-52 | R-UC014-07; phía 0..* không bị giới hạn bởi quy tắc nào |
| R-43 | AC-E-Showtime | AC-E-Movie | Association | A 0..* - B 1 | - | UC-014 | GL-47 "một lượt trình chiếu một Phim"; BR-50 | R-UC014-09; thay thuộc tính movie, movieName, movieTitle của Showtime |
| R-44 | AC-E-Showtime | AC-E-SeatStatus | Association | A 1 - B 50..400 | - | UC-005 | GL-58; UC-005 Dữ liệu ra 1 "mỗi ghế của sơ đồ ghế có một trạng thái ghế"; GL-50, REQ-03 | R-UC005-11; đổi phía B từ 1..* thành 50..400 theo sức chứa (đóng ghi chú Q-81); Q-109 |
| R-45 | AC-E-SeatStatus | AC-E-Seat | Association | A 0..* - B 1 | - | Mới ở P08 | GL-58 "Tình trạng của một Ghế trong một Suất chiếu"; GL-07 (Q-70) | Mới ở P08; tách theo Q-81; một ghế có một trạng thái ghế trong mỗi suất chiếu của phòng |
| R-46 | AC-E-Showtime | AC-E-SeatHold | Association | A 1 - B 0..* | - | UC-005, UC-006, UC-014 | GL-25; BR-07 (cả nhóm ghế thuộc một suất chiếu) | R-UC005-10, R-UC006-09, R-UC014-10 |
| R-47 | AC-E-SeatHold | AC-E-SeatStatus | Association | A 0..* - B 1..8 | - | UC-005 | BR-05, BR-07, BR-08, BR-09; tại một thời điểm một ghế chỉ thuộc một lần giữ ghế đang giữ, theo thời gian thuộc nhiều lần giữ ghế | R-UC005-13 |
| R-48 | AC-E-SeatHold | AC-E-Customer | Association | A 0..* - B 0..1 | holder | UC-005, UC-006 | GL-25 "một Khách hoặc Nhân viên quầy"; BR-04; Q-86 | R-UC005-14, R-UC006-08; {xor} với R-49 |
| R-49 | AC-E-SeatHold | AC-E-BoxOfficeClerk | Association | A 0..* - B 0..1 | holder | UC-005 | GL-25, GL-35; BR-04; Q-86 | R-UC005-15; {xor} với R-48 |
| R-50 | AC-E-SeatHold | AC-E-PaymentTransaction | Association | A 1 - B 0..* | - | UC-005, UC-006, UC-008 | GL-12 "cho Tổng tiền của một Lần giữ ghế"; UC-005 Mục 8 đoạn 10a (thử lại tạo giao dịch mới); BR-40 (giao dịch thứ hai gắn qua mã tham chiếu lần giữ ghế) | R-UC005-16, R-UC006-06, R-UC008-12 |
| R-51 | AC-E-SeatHold | AC-E-Booking | Association | A 1 - B 0..1 | - | UC-005, UC-008 | GL-24 "một Lần giữ ghế dẫn tới tối đa một Lần đặt" | R-UC005-17, R-UC008-09 |
| R-52 | AC-E-Booking | AC-E-Ticket | Aggregation | A 1 - B 1..8 | - | UC-005, UC-008, UC-009 | GL-24 "gồm mỗi ghế một Vé"; BR-05 | R-UC005-18, R-UC008-10, R-UC009-06; giữ aggregation vì vé đã huỷ vẫn tồn tại trong lần đặt, không có câu về xoá cùng lần đặt |
| R-53 | AC-E-Ticket | AC-E-Showtime | Association | A 0..* - B 1 | - | UC-005, UC-009, UC-014 | GL-59 "đúng một Ghế của một Suất chiếu"; BR-23, BR-53 | R-UC005-19, R-UC009-05, R-UC014-11; suy ra được qua R-54 và R-44 nhưng giữ vì UC-009, UC-014 gọi trực tiếp; hai đường phải nhất quán |
| R-54 | AC-E-Ticket | AC-E-SeatStatus | Association | A 0..* - B 1 | - | UC-008 | GL-59; BR-42 (ghế đã trống bán lại được nên một trạng thái ghế ứng với nhiều vé theo thời gian) | R-UC008-11 |
| R-55 | AC-E-PaymentTransaction | AC-E-RefundRequest | Association | A 0..1 - B 0..* | - | UC-006, UC-008 | BR-26, BR-43 (một giao dịch nhiều yêu cầu hoàn khác khoá); BR-20 và GL-63 (vé mua tại quầy hoàn bằng tiền mặt nên yêu cầu hoàn tiền mặt không có giao dịch) | R-UC006-07, R-UC008-14; đổi phía A từ 1 thành 0..1 vì UC-008 Ticket.recordCashRefund tạo yêu cầu hoàn tiền mặt không gắn giao dịch |
| R-56 | AC-E-Ticket | AC-E-RefundRequest | Association | A 0..1 - B 0..1 | - | UC-008 | BR-21 (mỗi vé hoàn một lần); yêu cầu hoàn toàn bộ của UC-006 không gắn vé | R-UC008-13; Q-87, Q-93 |
| R-57 | AC-E-BoxOfficeClerk | AC-E-Cinema | Association | A 0..* - B 1 | - | Mới ở P08 | BR-78 "thuộc đúng một cụm rạp"; GL-35 | Mới ở P08; thay thuộc tính cinema; phía 0..* không có quy tắc giới hạn, Q-108 |
| R-58 | AC-E-TicketChecker | AC-E-Cinema | Association | A 0..* - B 1 | - | Mới ở P08 | BR-78; GL-36 | Mới ở P08; thay thuộc tính cinema; Q-108 |
| R-59 | AC-E-CinemaManager | AC-E-Cinema | Association | A 0..* - B 1 | - | Mới ở P08 | BR-78; GL-42 | Mới ở P08; thay thuộc tính cinema; Q-108 |
| R-60 | AC-E-Showtime | AC-E-PriceList | Dependency | - | - | UC-005 | UC-005 SD bước 7e: Showtime.holdSeats gọi PriceList.determineSeatPrice (BR-71, BR-72) | Gọi chéo giữ từ R-UC005-12; đường cấu trúc là R-42, R-38, R-40; xem F4b |
| R-61 | AC-E-PriceList | AC-E-Showtime | Dependency | - | - | UC-013 | UC-013 SD2 bước 1a3: PriceList.removePriceEntry gọi Showtime.checkUsesPriceEntry (BR-64, BR-68) | Gọi chéo giữ từ R-UC013-05; xem F4b |
| R-62 | AC-E-Auditorium | AC-E-PriceList | Dependency | - | - | UC-014 | UC-014 SD bước 5, 8: Auditorium.saveShowtime gọi PriceList.checkCoversShowtime (BR-68, BR-69) | Gọi chéo giữ từ R-UC014-08; đường cấu trúc là R-38, R-40; xem F4b |

Ràng buộc {xor} giữa R-48 và R-49: mỗi lần giữ ghế gắn đúng một trong Customer hoặc BoxOfficeClerk (Q-86). Quan hệ boundary - control và control - entity giữ ở dạng association tạm thời, không gán aggregation, composition (A5). Không có generalization: xem F2a STT 41 và Q-108. Multiplicity "0..*" ở các phía không có quy tắc giới hạn trong nguồn là cách ghi "không giới hạn", không phải suy đoán số lượng.

### F4a. Ánh xạ quan hệ P07 --> P08

Mọi quan hệ VOPC của sáu file P07 (69 quan hệ) có mặt trong F4: hợp vào một R-nn, giữ nguyên, hoặc thay bằng đường mới.

| Quan hệ P07 | Cặp lớp | R-nn ở P08 | Cách xử lý |
|---|---|---|---|
| R-UC005-01 | BookTicketsForm - BookTicketsController | R-01 | Giữ nguyên |
| R-UC005-02 | CounterBookTicketsForm - BookTicketsController | R-02 | Giữ nguyên |
| R-UC005-03 | PaymentGateway - BookTicketsController | R-03 | Giữ nguyên |
| R-UC005-04 | EmailService - PaymentReportController | R-04 | Hợp với R-UC006-02 |
| R-UC005-05 | BookTicketsController - Customer | R-07 | Giữ nguyên |
| R-UC005-06 | BookTicketsController - BoxOfficeClerk | R-08 | Giữ nguyên |
| R-UC005-07 | BookTicketsController - Showtime | R-09 | Giữ nguyên |
| R-UC005-08 | BookTicketsController - SeatHold | R-10 | Giữ nguyên |
| R-UC005-09 | BookTicketsController - Booking | R-11 | Giữ nguyên |
| R-UC005-10 | Showtime - SeatHold | R-46 | Hợp với R-UC006-09, R-UC014-10 |
| R-UC005-11 | Showtime - SeatStatus | R-44 | Giữ, đổi multiplicity phía SeatStatus từ 1..* thành 50..400 |
| R-UC005-12 | Showtime - PriceList | R-60 | Thay bằng đường R-42, R-38, R-40 (cấu trúc) và R-60 (phụ thuộc gọi) |
| R-UC005-13 | SeatHold - SeatStatus | R-47 | Giữ nguyên |
| R-UC005-14 | SeatHold - Customer | R-48 | Hợp với R-UC006-08 |
| R-UC005-15 | SeatHold - BoxOfficeClerk | R-49 | Giữ nguyên |
| R-UC005-16 | SeatHold - PaymentTransaction | R-50 | Hợp với R-UC006-06, R-UC008-12 |
| R-UC005-17 | SeatHold - Booking | R-51 | Hợp với R-UC008-09 |
| R-UC005-18 | Booking - Ticket | R-52 | Hợp với R-UC008-10, R-UC009-06 |
| R-UC005-19 | Ticket - Showtime | R-53 | Hợp với R-UC009-05, R-UC014-11 |
| R-UC005-20 | PaymentGateway - PaymentReportController | R-05 | Hợp với R-UC006-01 |
| R-UC005-21 | PaymentReportController - SeatHold | R-12 | Hợp với R-UC006-03 |
| R-UC005-22 | PaymentReportController - Booking | R-13 | Giữ nguyên |
| R-UC005-23 | BookTicketsForm - PaymentReportController | R-06 | Giữ nguyên |
| R-UC006-01 | PaymentGateway - PaymentReportController | R-05 | Hợp với R-UC005-20 |
| R-UC006-02 | EmailService - PaymentReportController | R-04 | Hợp với R-UC005-04 |
| R-UC006-03 | PaymentReportController - SeatHold | R-12 | Hợp với R-UC005-21 |
| R-UC006-04 | PaymentReportController - PaymentTransaction | R-14 | Giữ nguyên |
| R-UC006-05 | PaymentReportController - RefundRequest | R-15 | Giữ nguyên |
| R-UC006-06 | SeatHold - PaymentTransaction | R-50 | Hợp với R-UC005-16 |
| R-UC006-07 | PaymentTransaction - RefundRequest | R-55 | Giữ, đổi multiplicity phía PaymentTransaction từ 1 thành 0..1; hợp với R-UC008-14 |
| R-UC006-08 | SeatHold - Customer | R-48 | Hợp với R-UC005-14 |
| R-UC006-09 | Showtime - SeatHold | R-46 | Hợp với R-UC005-10 |
| R-UC008-01 | CancelTicketForm - CancelTicketController | R-16 | Giữ nguyên |
| R-UC008-02 | CounterCancelTicketForm - CancelTicketController | R-17 | Giữ nguyên |
| R-UC008-03 | PaymentGateway - CancelTicketController | R-18 | Giữ nguyên |
| R-UC008-04 | BookTicketsForm - CancelTicketController | R-19 | Giữ nguyên, ghi ngoại lệ |
| R-UC008-05 | CancelTicketController - Ticket | R-20 | Giữ nguyên |
| R-UC008-06 | CancelTicketController - Booking | R-21 | Giữ nguyên |
| R-UC008-07 | CancelTicketController - Showtime | R-22 | Giữ nguyên |
| R-UC008-08 | CancelTicketController - PaymentTransaction | R-23 | Giữ nguyên |
| R-UC008-09 | SeatHold - Booking | R-51 | Hợp với R-UC005-17 |
| R-UC008-10 | Booking - Ticket | R-52 | Hợp với R-UC005-18 |
| R-UC008-11 | Ticket - SeatStatus | R-54 | Giữ nguyên |
| R-UC008-12 | SeatHold - PaymentTransaction | R-50 | Hợp với R-UC005-16 |
| R-UC008-13 | Ticket - RefundRequest | R-56 | Giữ nguyên |
| R-UC008-14 | PaymentTransaction - RefundRequest | R-55 | Hợp với R-UC006-07 (đổi multiplicity) |
| R-UC008-15 | CancelTicketController - RefundRequest | R-24 | Giữ nguyên |
| R-UC009-01 | CheckTicketForm - CheckTicketController | R-25 | Giữ nguyên |
| R-UC009-02 | CheckTicketController - TicketChecker | R-26 | Giữ nguyên |
| R-UC009-03 | CheckTicketController - Showtime | R-27 | Giữ nguyên |
| R-UC009-04 | CheckTicketController - Ticket | R-28 | Giữ nguyên |
| R-UC009-05 | Ticket - Showtime | R-53 | Hợp với R-UC005-19 |
| R-UC009-06 | Booking - Ticket | R-52 | Hợp với R-UC005-18 |
| R-UC013-01 | ManagePriceListForm - ManagePriceListController | R-29 | Giữ nguyên |
| R-UC013-02 | ManagePriceListController - CinemaManager | R-30 | Giữ nguyên |
| R-UC013-03 | ManagePriceListController - PriceList | R-31 | Giữ nguyên |
| R-UC013-04 | PriceList - PriceEntry | R-41 | Giữ nguyên |
| R-UC013-05 | Showtime - PriceList | R-61 | Thay bằng đường R-42, R-38, R-40 (cấu trúc) và R-61 (phụ thuộc gọi theo chiều PriceList sang Showtime) |
| R-UC014-01 | ScheduleShowtimesForm - ScheduleShowtimesController | R-32 | Giữ nguyên |
| R-UC014-02 | ScheduleShowtimesController - CinemaManager | R-33 | Giữ nguyên |
| R-UC014-03 | ScheduleShowtimesController - Auditorium | R-34 | Giữ nguyên |
| R-UC014-04 | ScheduleShowtimesController - Movie | R-35 | Giữ nguyên |
| R-UC014-05 | ScheduleShowtimesController - Showtime | R-36 | Giữ nguyên |
| R-UC014-06 | ScheduleShowtimesController - PriceList | R-37 | Giữ nguyên |
| R-UC014-07 | Auditorium - Showtime | R-42 | Giữ nguyên |
| R-UC014-08 | Auditorium - PriceList | R-62 | Thay bằng đường R-38, R-40 (cấu trúc) và R-62 (phụ thuộc gọi) |
| R-UC014-09 | Showtime - Movie | R-43 | Giữ nguyên |
| R-UC014-10 | Showtime - SeatHold | R-46 | Hợp với R-UC005-10 |
| R-UC014-11 | Ticket - Showtime | R-53 | Hợp với R-UC005-19 |

### F4b. Bảng đơn vị loại trừ và thứ tự khoá (mức phân tích, cơ chế do P09)

Thay cho bảng đề xuất ở UC-005 mục 4 (R7-05). Mỗi thao tác không chia cắt có lớp chủ và bộ khoá cần lấy; chế độ S là đọc chung, X là ghi riêng. Mức phân tích chỉ nêu đối tượng cần loại trừ và thứ tự khoá, không chọn cơ chế khoá.

| ID | Thao tác không chia cắt | Lớp chủ | UC | Khoá cần lấy (hạng, lớp, chế độ) | Phải nằm trong cùng thao tác | BR |
|---|---|---|---|---|---|---|
| EX-01 | holdSeats: kiểm-và-giữ cả nhóm ghế và chốt giá (UC-005 bước 7) | Showtime | UC-005 | Hạng 1 PriceList (S); hạng 3 Showtime (X); hạng 4 Customer hoặc BoxOfficeClerk của người giữ ghế (X); hạng 6 SeatStatus của các ghế đã chọn (X, theo vị trí ghế); SeatHold mới tạo trong thao tác | Kiểm đã mở bán và suất chiếu chưa đổi kể từ lúc hiển thị, kiểm người giữ ghế không có lần giữ ghế chưa kết thúc, kiểm và giữ cả nhóm ghế (cả nhóm hoặc không ghế nào), xác định và ghi giá từng ghế, tạo lần giữ ghế; thất bại ở điều kiện nào cũng không để lại lần giữ ghế hay ghế đang giữ | BR-04, BR-07, BR-08, BR-09, BR-54, BR-65, BR-71, BR-72 |
| EX-02 | settlePaymentReport: xử lý báo kết quả giao dịch (UC-005 bước 11 đến 13, 11a; UC-006 bước 2, 3) | SeatHold | UC-005, UC-006 | Hạng 5 SeatHold (X); hạng 6 SeatStatus của các ghế đã giữ (X); hạng 7 PaymentTransaction (X); Booking và Ticket mới tạo trong thao tác | Kiểm giao dịch chưa xử lý, kiểm còn Đang giữ và chưa quá thời điểm hết hạn (quá hạn thì chuyển Hết hạn trước), đánh dấu giao dịch đã xử lý, chuyển ghế sang đã bán, chuyển sang Đã hoàn tất, tạo lần đặt và vé; hoặc ghi nhận thanh toán trễ chờ hoàn, báo trùng, thất bại. Thao tác không hoàn tất thì xử lý như thanh toán trễ (Q-84) | BR-14, BR-15, BR-37, BR-39, BR-40, BR-85, BR-86 |
| EX-03 | completeSaleOnCashConfirmation: xác nhận đã thu tiền mặt (UC-005 bước 9a1a đến 9a3) | SeatHold | UC-005 | Hạng 5 SeatHold (X); hạng 6 SeatStatus của các ghế đã giữ (X); Booking và Ticket mới tạo trong thao tác | So thời điểm xác nhận với thời điểm hết hạn, chuyển ghế sang đã bán, chuyển sang Đã hoàn tất, tạo lần đặt và vé; xác nhận tới sau thời điểm hết hạn thì bị từ chối | BR-44, BR-85, BR-86 |
| EX-04 | expire, cancel: kết thúc lần giữ ghế (UC-005 luồng 7b, *a) | SeatHold | UC-005 | Hạng 5 SeatHold (X) | Kiểm còn Đang giữ rồi chuyển sang đúng một trạng thái cuối; đã ở trạng thái cuối thì không đổi | BR-85, BR-86 |
| EX-05 | releaseHeldSeats: giải phóng ghế sau khi lần giữ ghế kết thúc (UC-005 luồng 7b, 11a, *a) | SeatHold | UC-005 | Hạng 5 SeatHold (S); hạng 6 SeatStatus của các ghế (X, theo vị trí ghế) | Chuyển từng ghế còn thuộc đúng lần giữ ghế về trống, chậm nhất 1 phút sau thời điểm hết hạn; chạy lại không hại, chạy được cả khi lần giữ ghế đã ở trạng thái cuối mà ghế còn đang giữ; tách khỏi EX-04 | BR-10, BR-85, REQ-76, NFR-07 |
| EX-06 | releaseTicketSeat: trả ghế của vé đã huỷ về trống (UC-008 bước 7) | Ticket | UC-008 | Hạng 6 SeatStatus (X); hạng 8 Ticket (S) | Chuyển ghế đã bán của vé đã huỷ về trống; thao tác độc lập với EX-07 và EX-09, không lồng nhau; chạy được trên suất chiếu Đã xoá | BR-42, BR-58 |
| EX-07 | cancelTicket: ghi nhận vé đã huỷ (UC-008 bước 4) | Ticket | UC-008 | Hạng 8 Ticket (X) | Kiểm vé chưa huỷ rồi chưa sử dụng, ghi nhận đã huỷ | BR-21, BR-30 |
| EX-08 | admitTicket: cho vé vào và đánh dấu đã sử dụng (UC-009 bước 4, 5) | Ticket | UC-009 | Hạng 8 Ticket (X) | Kiểm cụm rạp, suất chiếu, đã sử dụng, đã huỷ theo thứ tự BR-33; khi hợp lệ đánh dấu đã sử dụng; trả về hợp lệ hoặc đúng một lý do | BR-22, BR-23, BR-24, BR-25, BR-30, BR-33 |
| EX-09 | prepareRefundRequest và recordRefundedAmount: giữ hạn mức hoàn của giao dịch (UC-006 bước 4, 6; UC-008 bước 5, 7) | PaymentTransaction | UC-006, UC-008 | Hạng 7 PaymentTransaction (X); RefundRequest mới tạo trong thao tác | Kiểm tổng đã hoàn cộng khoản hoàn không vượt số tiền đã thanh toán, tạo yêu cầu hoàn, ghi nhận khoản hoàn vào tổng đã hoàn. Hai vé của cùng một giao dịch có thể được huỷ đồng thời nên cộng vào tổng đã hoàn không được mất cập nhật; kiểm và cộng cùng thao tác hoặc giữ chỗ hạn mức ngay lúc tạo yêu cầu hoàn (cơ chế do P09). P07 của UC-006, UC-008 chưa nêu thao tác này là không chia cắt | BR-26, BR-43 |
| EX-10 | recordAttempt, recordResult, recordCashRefund: ghi nhận lần gửi, kết quả hoàn và khoản hoàn tiền mặt (UC-006 bước 4 đến 6; UC-008 bước 5, 5a1, 6) | RefundRequest | UC-006, UC-008 | Hạng 8 Ticket (S, chỉ recordCashRefund); hạng 9 RefundRequest (X) | Ghi nhận mỗi lần gửi và kết quả của lần gửi trên cùng yêu cầu hoàn; mọi lần thử lại dùng lại cùng yêu cầu hoàn và cùng khoá chống hoàn trùng | BR-41, BR-43 |
| EX-11 | savePriceEntry: đặt giá hoặc đổi giá (UC-013 bước 5) | PriceList | UC-013 | Hạng 1 PriceList (X) | Kiểm mục giá của tổ hợp chưa bị đổi, tạo hoặc bỏ kể từ lúc hiển thị, tạo mục giá hoặc đổi giá, ghi mốc thay đổi của tổ hợp; có hiệu lực ngay | BR-62, BR-63, BR-66, BR-71 |
| EX-12 | removePriceEntry: bỏ mục giá (UC-013 luồng 1a3) | PriceList | UC-013 | Hạng 1 PriceList (X); hạng 3 Showtime của cụm rạp (S, chỉ đọc) | Kiểm mục giá chưa bị đổi, kiểm cụm rạp không còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá, bỏ mục giá, ghi mốc thay đổi. PriceList (X) đã loại trừ mọi saveShowtime và holdSeats nên các suất chiếu đọc được ổn định | BR-63, BR-64, BR-68, BR-71 |
| EX-13 | saveShowtime: lập hoặc sửa suất chiếu (UC-014 bước 8) | Auditorium | UC-014 | Hạng 1 PriceList (S); hạng 2 Auditorium (X; hai phòng khi sửa sang phòng khác, theo mã tăng dần); hạng 3 Showtime đang sửa (X); hạng 5 SeatHold (S) và hạng 8 Ticket (S) của suất chiếu đang sửa | Kiểm bảng giá phủ mọi loại ghế, khoảng cách dọn phòng với các suất chiếu khác trong phòng, suất chiếu chưa đổi kể từ lúc hiển thị, chưa tới giờ bắt đầu, không có ghế giữ còn hiệu lực và vé chưa huỷ (khi sửa); rồi ghi suất chiếu vào lịch phòng và đặt lại mốc thay đổi | BR-51, BR-52, BR-53, BR-54, BR-57, BR-60, BR-68, BR-69 |
| EX-14 | removeFromSchedule: xoá suất chiếu khỏi lịch chiếu (UC-014 luồng 1b3) | Showtime | UC-014 | Hạng 3 Showtime (X); hạng 5 SeatHold (S); hạng 8 Ticket (S) | Kiểm suất chiếu chưa đổi kể từ lúc hiển thị, chưa tới giờ bắt đầu, không có ghế giữ còn hiệu lực và vé chưa huỷ; rồi đánh dấu Đã xoá và giữ lại dữ liệu | BR-53, BR-54, BR-57, BR-58, BR-60 |

Cặp loại trừ (thao tác nào không được xen vào thao tác nào, và khoá chung nào thực hiện loại trừ):

| ID | Thao tác 1 | Thao tác 2 | BR | Khoá chung | Kết quả khi hai thao tác đụng nhau |
|---|---|---|---|---|---|
| X-01 | EX-01 | EX-01 (cùng suất chiếu) | BR-07, BR-09 | Showtime (X) | Một yêu cầu giữ được ghế; yêu cầu còn lại thấy ghế đang giữ và bị từ chối (luồng 7a) |
| X-02 | EX-01 | EX-01 (cùng người giữ ghế, khác suất chiếu) | BR-04 | Customer hoặc BoxOfficeClerk (X) | Yêu cầu sau thấy lần giữ ghế chưa kết thúc và bị từ chối (luồng 7c) |
| X-03 | EX-01 | EX-13, EX-14 (cùng suất chiếu) | BR-54, BR-53 | Showtime (X) | Giữ ghế ghi nhận trước thì sửa hoặc xoá bị từ chối theo BR-53; sửa hoặc xoá ghi nhận trước thì giữ ghế bị từ chối vì suất chiếu đã đổi (luồng 7d) |
| X-04 | EX-01 | EX-11 | BR-71 | PriceList (S với X) | Giá chốt lấy từ bảng giá trước hoặc sau thay đổi, không lẫn |
| X-05 | EX-11 | EX-11, EX-12 | BR-63 | PriceList (X) | Yêu cầu ghi nhận sau bị từ chối và không ghi đè thay đổi trước (luồng 5a, 1a3a) |
| X-06 | EX-12 | EX-13 | BR-68 | PriceList (X với S) | Bên ghi nhận sau bị từ chối theo BR-64 hoặc BR-69 |
| X-07 | EX-13 | EX-13 (cùng phòng chiếu hoặc cùng suất chiếu) | BR-52, BR-60 | Auditorium (X), Showtime (X) | Chỉ một yêu cầu được lưu |
| X-08 | EX-13 | EX-14; EX-14 với EX-14 (cùng suất chiếu) | BR-60 | Showtime (X) | Yêu cầu ghi nhận sau bị từ chối vì suất chiếu đã đổi hoặc không còn |
| X-09 | EX-02 | EX-02 (cùng lần giữ ghế hoặc cùng giao dịch) | BR-37, BR-85 | SeatHold (X), PaymentTransaction (X) | Báo đầu tiên được xử lý, báo đến sau thấy trạng thái cuối và là báo trùng hoặc thanh toán trễ |
| X-10 | EX-02, EX-03 | EX-04 (cùng lần giữ ghế) | BR-44, BR-85, BR-86 | SeatHold (X) | Chỉ một trạng thái cuối; thao tác sau không đổi trạng thái |
| X-11 | EX-02, EX-03 | EX-13, EX-14 | BR-53 | SeatHold (X với S), Ticket | Sửa hoặc xoá thấy lần giữ ghế còn Đang giữ, hoặc thấy lần giữ ghế đã Đã hoàn tất cùng vé đã tạo, không thấy trạng thái dở dang |
| X-12 | EX-05 | EX-02, EX-03 | BR-85, BR-86 | SeatHold, SeatStatus (X) | Không thể vừa bán vừa giải phóng cùng một ghế |
| X-13 | EX-05, EX-06 | EX-01 | BR-08, BR-09 | SeatStatus (X) | Ghế chỉ giữ được lại sau khi đã về trống |
| X-14 | EX-07 | EX-08 (cùng vé) | BR-30 | Ticket (X) | Bên ghi nhận trước thành công, bên sau bị từ chối |
| X-15 | EX-07 | EX-07; EX-08 với EX-08 (cùng vé) | BR-21, BR-25 | Ticket (X) | Một lần huỷ hoặc một lần soát thành công; lần sau thấy vé đã huỷ hoặc đã sử dụng |
| X-16 | EX-09 | EX-09; EX-09 với EX-02 (cùng giao dịch) | BR-26, BR-37 | PaymentTransaction (X) | Tổng đã hoàn không mất cập nhật và không vượt số tiền đã thanh toán; báo trùng hoặc thanh toán trễ thấy đúng số đã hoàn |
| X-17 | EX-10 | EX-10 (cùng yêu cầu hoàn) | BR-43 | RefundRequest (X) | Số lần gửi và kết quả của một yêu cầu hoàn đếm đúng; mọi lần thử lại dùng chung một khoá |

Thứ tự khoá cố định (hạng nhỏ lấy trước):

| Hạng | Lớp | Chế độ | Thao tác lấy | Ghi chú |
|---|---|---|---|---|
| 1 | PriceList (một bảng giá mỗi cụm rạp) | S, X | EX-01, EX-13 lấy S; EX-11, EX-12 lấy X | S đủ để chặn EX-11, EX-12 (BR-71, BR-68) mà không chặn các holdSeats khác |
| 2 | Auditorium | X | EX-13 | Theo mã tăng dần khi cần hai phòng (sửa sang phòng khác) |
| 3 | Showtime | X, S | EX-01, EX-13, EX-14 lấy X; EX-12 lấy S | Có thể thu hẹp xuống từng SeatStatus cho EX-01 nếu NFR-05, NFR-06 đòi, miễn giữ loại trừ với EX-13, EX-14 |
| 4 | Người giữ ghế: Customer hoặc BoxOfficeClerk | X | EX-01 | Chỉ để thi hành BR-04 xuyên mọi suất chiếu |
| 5 | SeatHold | X, S | EX-02, EX-03, EX-04 lấy X; EX-05, EX-13, EX-14 lấy S | EX-01 chỉ tạo SeatHold mới |
| 6 | SeatStatus | X | EX-01, EX-02, EX-03, EX-05, EX-06 | Nhiều ghế thì theo vị trí ghế (hàng, số ghế) tăng dần |
| 7 | PaymentTransaction | X | EX-02, EX-09 | - |
| 8 | Ticket | X, S | EX-07, EX-08 lấy X; EX-06, EX-10, EX-13, EX-14 lấy S | EX-02, EX-03 chỉ tạo Ticket mới |
| 9 | RefundRequest | X | EX-10 | EX-09 chỉ tạo RefundRequest mới |

Quy tắc áp dụng:

1. Mọi thao tác lấy trọn bộ khoá cần ngay từ đầu, theo hạng tăng dần ở bảng trên, kể cả khi lớp được đọc đứng trước lớp chủ: holdSeats lấy khoá bảng giá (hạng 1) trước khoá suất chiếu (hạng 3); saveShowtime lấy khoá bảng giá trước khoá phòng chiếu (hạng 2).
2. Trong cùng hạng, lấy khoá theo thứ tự tăng dần của mã định danh; riêng SeatStatus theo vị trí ghế (hàng rồi số ghế).
3. Không nâng khoá S thành X giữa thao tác: thao tác cần X lấy X từ đầu.
4. Không có thao tác nào giữ khoá của thao tác trước khi lấy khoá của thao tác sau: các bước 4 (EX-07), 5 (EX-09, EX-10) và 7 (EX-06) của UC-008 là ba thao tác độc lập, không lồng nhau, để vé đã huỷ ghi nhận trước và ghế trả về trống kể cả khi hoàn tiền lỗi (BR-42).
5. Chu trình gọi chéo giữa Showtime và PriceList (R-60, R-61) và từ Auditorium sang PriceList (R-62) không gây chu trình khoá vì PriceList luôn có hạng nhỏ nhất. Lời gọi lồng PriceList.removePriceEntry --> Showtime.checkUsesPriceEntry --> PriceList.determineTimeBand dùng khoá thao tác đang giữ; determineTimeBand là hàm thuần theo BR-12 và không lấy khoá.
6. Đối tượng không là đơn vị khoá: Cinema, Seat, Movie, PriceEntry (do khoá PriceList bao), Booking (chỉ được tạo trong EX-02, EX-03 và đọc bất biến), CinemaManager, TicketChecker. Dữ liệu danh mục thuộc UC chưa phân tích (UC-010, UC-011, UC-012, UC-017) có thể thêm đơn vị khi các UC đó có P07 (xem BR-87 cho sơ đồ ghế).
7. Không có chu trình khoá vì mọi thao tác lấy khoá theo cùng một thứ tự toàn phần. Độ mịn (khoá cả suất chiếu hay từng ghế), chế độ S, X cụ thể và cách hẹn giờ hết hạn thuộc P09.

### F4c. Vòng đời trạng thái (đầu vào cho state machine ở P12)

SeatHold (Lần giữ ghế). Đang giữ là trạng thái đầu; bốn trạng thái cuối loại trừ nhau, đã ở trạng thái cuối thì không đổi (BR-86).

| Từ | Trách nhiệm kích hoạt | Điều kiện | Đến | BR | UC |
|---|---|---|---|---|---|
| (tạo) | createSeatHold trong holdSeats | giữ cả nhóm ghế thành công; đặt expiryTime = holdTime + 10 phút | Đang giữ | BR-07, BR-10 | UC-005 |
| Đang giữ | settlePaymentReport (báo thành công) hoặc completeSaleOnCashConfirmation | giao dịch chưa xử lý (kênh trực tuyến), chưa quá expiryTime; bán ghế và tạo lần đặt cùng vé hoàn tất | Đã hoàn tất | BR-37, BR-44, BR-85 | UC-005 |
| Đang giữ | expire (sự kiện hết hạn), hoặc settlePaymentReport nhận báo thành công khi đã quá expiryTime | tới hoặc quá expiryTime | Hết hạn | BR-10, BR-14, BR-85 | UC-005, UC-006 |
| Đang giữ | cancel (tác nhân huỷ giữ ghế) | còn Đang giữ | Đã huỷ | BR-85 | UC-005 |
| Đang giữ | settlePaymentReport (báo thất bại) | còn Đang giữ, chưa quá expiryTime | Thanh toán thất bại | BR-39, BR-85 | UC-005 |
| Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại | mọi thao tác đổi trạng thái | - | không đổi; báo đến sau được xử lý theo trạng thái cuối (báo thành công của giao dịch chưa xử lý: thanh toán trễ; giao dịch đã xử lý: báo trùng; báo thất bại: chỉ ghi nhận) | BR-86, BR-37, BR-39 | UC-006 |

SeatStatus (Trạng thái ghế của một suất chiếu). Chọn ghế trên sơ đồ chưa đổi trạng thái (BR-03).

| Từ | Trách nhiệm kích hoạt | Điều kiện | Đến | BR | UC |
|---|---|---|---|---|---|
| Trống | holdSeatFor trong holdSeats | ghế còn trống, cả nhóm ghế giữ được | Đang được giữ | BR-07, BR-08, BR-09 | UC-005 |
| Đang được giữ | markSold trong settlePaymentReport, completeSaleOnCashConfirmation | lần giữ ghế còn Đang giữ, chưa quá hạn | Đã bán | BR-85 | UC-005 |
| Đang được giữ | releaseSeat (sau expire, cancel, thanh toán thất bại) | ghế còn thuộc đúng lần giữ ghế; chậm nhất 1 phút sau expiryTime | Trống | BR-10, REQ-76, NFR-07 | UC-005 |
| Đã bán | releaseSeat (sau cancelTicket) | vé của ghế đã huỷ, kể cả hoàn tiền lỗi | Trống | BR-42 | UC-008 |

Ticket (Vé). Tạo cùng lần đặt khi ghế chuyển sang đã bán; Đã sử dụng và Đã huỷ là hai trạng thái cuối loại trừ nhau.

| Từ | Trách nhiệm kích hoạt | Điều kiện | Đến | BR | UC |
|---|---|---|---|---|---|
| (tạo) | createTicket trong settlePaymentReport, completeSaleOnCashConfirmation | trong cùng thao tác bán ghế | Chưa sử dụng | BR-67, BR-85 | UC-005 |
| Chưa sử dụng | admitTicket (markUsed) | đúng cụm rạp, đúng suất chiếu đang soát, chưa sử dụng, chưa huỷ | Đã sử dụng | BR-22 đến BR-25, BR-30, BR-33 | UC-009 |
| Chưa sử dụng | cancelTicket (markCancelled) | chưa huỷ, chưa sử dụng, còn trước hạn huỷ vé, đúng kênh mua | Đã huỷ | BR-18, BR-21, BR-30 | UC-008 |
| Đã sử dụng, Đã huỷ | cancelTicket, admitTicket | - | không đổi; bên sau bị từ chối | BR-21, BR-25, BR-30 | UC-008, UC-009 |

PaymentTransaction (Giao dịch thanh toán), thuộc tính processed. Kết quả thất bại ghi ở thuộc tính result, không đổi processed.

| Từ | Trách nhiệm kích hoạt | Điều kiện | Đến | BR | UC |
|---|---|---|---|---|---|
| (tạo) | createPaymentTransaction qua SeatHold.recordPaymentTransaction | số tiền ghi lúc tạo (bước 10); giao dịch thứ hai tạo ở UC-006 bước 3 | Chưa xử lý | REQ-111, BR-40 | UC-005, UC-006 |
| Chưa xử lý | markProcessed | báo thành công đầu tiên, lần giữ ghế còn hiệu lực | Đã tạo vé | BR-37 | UC-005 |
| Chưa xử lý | markLatePayment | báo thành công, lần giữ ghế ở trạng thái cuối khác Đã hoàn tất hoặc quá hạn, hoặc giao dịch thứ hai | Đã ghi nhận thanh toán trễ | BR-14, BR-15, BR-40 | UC-006 |
| Đã tạo vé, Đã ghi nhận thanh toán trễ | recordDuplicateReport | báo thành công đến lại | không đổi, tăng duplicateReportCount | BR-37 | UC-006 |

RefundRequest (Yêu cầu hoàn). Chỉ một yêu cầu hoàn mỗi vé (BR-21) và mỗi giao dịch có yêu cầu hoàn toàn bộ tối đa một lần.

| Từ | Trách nhiệm kích hoạt | Điều kiện | Đến | BR | UC |
|---|---|---|---|---|---|
| (tạo) | createRefundRequest (prepareRefundRequest) | khoản hoàn không vượt số đã thanh toán (BR-26); sinh khoá chống hoàn trùng một lần | Mới | BR-26, BR-43 | UC-006, UC-008 |
| Mới, Chờ gửi lại | recordAttempt | gửi tới cổng thanh toán | Đang chờ kết quả (tối đa 30 giây) | BR-43 | UC-006, UC-008 |
| Đang chờ kết quả | recordResult (thành công) | cổng trả kết quả hoàn thành công | Đã hoàn | BR-43, GL-56 | UC-006, UC-008 |
| Đang chờ kết quả | recordResult (thất bại hoặc không phản hồi) | checkRetryRemaining còn lượt | Chờ gửi lại (cùng khoá) | BR-41, BR-43 | UC-006, UC-008 |
| Đang chờ kết quả, Chờ gửi lại | logRefundFailure | hết lượt thử lại | Chưa hoàn được (đã ghi log lỗi) | BR-41, GL-56 | UC-006, UC-008 |
| (tạo) | recordCashRefund | vé mua tại quầy hoàn bằng tiền mặt | Đã hoàn | BR-20 | UC-008 |

Showtime (Suất chiếu), thuộc tính status. Đã xoá là trạng thái cuối; dữ liệu giữ lại cho vé đã huỷ, hoàn tiền và báo cáo (BR-58).

| Từ | Trách nhiệm kích hoạt | Điều kiện | Đến | BR | UC |
|---|---|---|---|---|---|
| (tạo) | addToSchedule trong saveShowtime | bảng giá phủ, khoảng cách dọn phòng, các điều kiện lập | Trong lịch chiếu | BR-51, BR-52, BR-55, BR-56, BR-69 | UC-014 |
| Trong lịch chiếu | removeFromSchedule (markDeleted) | chưa tới giờ bắt đầu, không có ghế giữ còn hiệu lực, không có vé chưa huỷ | Đã xoá | BR-53, BR-54, BR-57, BR-58, BR-60 | UC-014 |

## F5. Analysis class diagram tổng thể

File diagrams/P08-class-analysis.drawio gồm 7 trang. Trang Entity là trang tổng thể (mô hình miền, không có boundary, control); sáu trang còn lại theo nhóm chức năng Bán vé (P02) và Vận hành rạp, mỗi trang gồm boundary, control, entity chúng dùng và quan hệ giữa các lớp trên trang. Trang Entity có 17 lớp, 25 cạnh (đúng ngưỡng); trang nhiều nhất của nhóm chức năng có 12 lớp và 18 cạnh. ID mxCell của lớp: mã AC ở trang Entity, mã AC thêm hậu tố trang (V2 đến V7) ở các trang khác. ID mxCell của cạnh: R-nn ở trang Entity, R-nn thêm hậu tố trang ở trang khác.

Ngăn trách nhiệm trên trang nhóm chức năng chỉ liệt kê trách nhiệm của các use case của trang (theo F3); trang Entity liệt kê đủ.

a) Bảng Node

| ID (mã AC) | ID mxCell | Loại (Class) | Nhãn | Stereotype | Thuộc về (view) | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|---|
| AC-E-Customer | AC-E-Customer | Class | Customer | «entity» | Entity | email, phoneNumber, password | checkNoActiveSeatHold, authenticateCustomer, provideEmail |
| AC-E-BoxOfficeClerk | AC-E-BoxOfficeClerk | Class | BoxOfficeClerk | «entity» | Entity | - | checkNoActiveSeatHold, provideCinema |
| AC-E-TicketChecker | AC-E-TicketChecker | Class | TicketChecker | «entity» | Entity | - | provideCinema |
| AC-E-CinemaManager | AC-E-CinemaManager | Class | CinemaManager | «entity» | Entity | - | provideCinema |
| AC-E-Cinema | AC-E-Cinema | Class | Cinema | «entity» | Entity | - | provideAuditoriums, provideShowtimes |
| AC-E-Movie | AC-E-Movie | Class | Movie | «entity» | Entity | title, releaseFormats, duration, releaseDate, endOfRunDate | provideMovieInfo, checkReleasedInFormat, checkWithinRunPeriod, provideDuration |
| AC-E-Auditorium | AC-E-Auditorium | Class | Auditorium | «entity» | Entity | name, auditoriumType, supportedFormats | provideAuditoriumInfo, checkBelongsToCinema, checkSupportsFormat, provideSeatTypes, draftShowtime, saveShowtime, checkRoomGap, addToSchedule |
| AC-E-Seat | AC-E-Seat | Class | Seat | «entity» | Entity | seatPosition, seatType | provideSeatInfo |
| AC-E-Showtime | AC-E-Showtime | Class | Showtime | «entity» | Entity | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | checkSaleOpen, provideSeatMap, checkSeatSelectionLimit, holdSeats, checkUnchangedSinceDisplayed, checkBelongsToCinema, checkCancellationDeadline, checkUsesPriceEntry, createShowtime, checkSaleOpenBeforeStart, calculateEndTime, checkNotStarted, checkNoActiveHoldOrSoldTicket, applyChanges, removeFromSchedule, markDeleted, provideShowtimeInfo |
| AC-E-PriceList | AC-E-PriceList | Class | PriceList | «entity» | Entity | entryChangeTimes | determineSeatPrice, providePriceEntries, checkTicketPriceValid, savePriceEntry, checkEntryUnchangedSinceDisplayed, findOrCreatePriceEntry, removePriceEntry, deletePriceEntry, determineTimeBand, checkCoversShowtime |
| AC-E-PriceEntry | AC-E-PriceEntry | Class | PriceEntry | «entity» | Entity | auditoriumType, movieFormat, seatType, timeBand, ticketPrice, lastChangedAt | provideEntryInfo, setTicketPrice |
| AC-E-SeatStatus | AC-E-SeatStatus | Class | SeatStatus | «entity» | Entity | status, heldPrice | provideSeatStatus, holdSeatFor, recordHeldPrice, provideHeldSeatInfo, markSold, releaseSeat |
| AC-E-SeatHold | AC-E-SeatHold | Class | SeatHold | «entity» | Entity | holdRef, status, holdTime, expiryTime | createSeatHold, provideHoldSummary, calculateTotalAmount, recordPaymentTransaction, settlePaymentReport, checkHoldStillActive, endHold, issueBooking, expire, releaseHeldSeats, cancel, completeSaleOnCashConfirmation, provideRefundNoticeRecipient, checkHeldBy, providePaymentTransaction |
| AC-E-PaymentTransaction | AC-E-PaymentTransaction | Class | PaymentTransaction | «entity» | Entity | transactionCode, amount, processed, result, lateReason, refundedTotal, duplicateReportCount | createPaymentTransaction, checkNotProcessed, markProcessed, recordFailedResult, markLatePayment, recordDuplicateReport, prepareRefundRequest, checkRefundWithinPaidAmount, recordRefundedAmount, provideRefundSummary |
| AC-E-RefundRequest | AC-E-RefundRequest | Class | RefundRequest | «entity» | Entity | idempotencyKey, requestType, refundAmount, attemptCount, result | createRefundRequest, generateIdempotencyKey, recordAttempt, recordResult, checkRetryRemaining, provideRefundInfo |
| AC-E-Booking | AC-E-Booking | Class | Booking | «entity» | Entity | bookingCode | createBooking, generateBookingCode, provideBookingInfo, checkCancellationChannel, providePaymentTransaction, provideBookingCode |
| AC-E-Ticket | AC-E-Ticket | Class | Ticket | «entity» | Entity | ticketCode, qrCode, price, status | createTicket, generateQrCode, provideTicketContent, cancelTicket, checkNotCancelledNotUsed, markCancelled, calculateRefundAmount, recordCashRefund, releaseTicketSeat, admitTicket, markUsed, checkNotCancelled |
| AC-B-BookTicketsForm | AC-B-BookTicketsForm__V2 | Class | BookTicketsForm | «boundary» | Đặt vé (UC-005) | selectedSeats, credentials | selectShowtime, showSeatMap, confirmSeatSelection, showHeldSeats, requestOnlinePayment, showBookingSuccess, notifyRefusal, requestLogin, provideCredentials, cancelSeatHold, updateSeatMap |
| AC-B-CounterBookTicketsForm | AC-B-CounterBookTicketsForm__V2 | Class | CounterBookTicketsForm | «boundary» | Đặt vé (UC-005) | selectedSeats | selectShowtime, notifyRefusal, showSeatMap, confirmSeatSelection, showHeldSeats, confirmCashReceived, showTicketsForPrint, printTickets, updateSeatMap |
| AC-B-PaymentGateway | AC-B-PaymentGateway__V2 | Class | PaymentGateway | «boundary» | Đặt vé (UC-005) | - | createPaymentTransaction, reportTransactionResult |
| AC-C-BookTicketsController | AC-C-BookTicketsController__V2 | Class | BookTicketsController | «control» | Đặt vé (UC-005) | - | startBooking, requestSeatHold, checkCustomerLoggedIn, startWaitingForHoldExpiry, startOnlinePayment, stopWaitingForHoldExpiry, handleHoldExpired, cancelSeatHold, confirmCashReceived |
| AC-E-Customer | AC-E-Customer__V2 | Class | Customer | «entity» | Đặt vé (UC-005) | email, phoneNumber, password | checkNoActiveSeatHold, authenticateCustomer |
| AC-E-BoxOfficeClerk | AC-E-BoxOfficeClerk__V2 | Class | BoxOfficeClerk | «entity» | Đặt vé (UC-005) | - | checkNoActiveSeatHold, provideCinema |
| AC-E-Showtime | AC-E-Showtime__V2 | Class | Showtime | «entity» | Đặt vé (UC-005) | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | checkSaleOpen, provideSeatMap, checkSeatSelectionLimit, holdSeats, checkUnchangedSinceDisplayed, checkBelongsToCinema |
| AC-E-SeatHold | AC-E-SeatHold__V2 | Class | SeatHold | «entity» | Đặt vé (UC-005) | holdRef, status, holdTime, expiryTime | createSeatHold, provideHoldSummary, calculateTotalAmount, recordPaymentTransaction, settlePaymentReport, checkHoldStillActive, endHold, issueBooking, expire, releaseHeldSeats, cancel, completeSaleOnCashConfirmation |
| AC-E-Booking | AC-E-Booking__V2 | Class | Booking | «entity» | Đặt vé (UC-005) | bookingCode | createBooking, generateBookingCode, provideBookingInfo |
| AC-B-PaymentGateway | AC-B-PaymentGateway__V3 | Class | PaymentGateway | «boundary» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | - | reportTransactionResult, requestRefund |
| AC-B-EmailService | AC-B-EmailService__V3 | Class | EmailService | «boundary» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | - | sendTicketsEmail, sendRefundNotificationEmail |
| AC-B-BookTicketsForm | AC-B-BookTicketsForm__V3 | Class | BookTicketsForm | «boundary» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | selectedSeats, credentials | showBookingSuccess, notifyRefusal |
| AC-C-PaymentReportController | AC-C-PaymentReportController__V3 | Class | PaymentReportController | «control» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | - | handlePaymentReport, logUnrecognizedTransaction, startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure |
| AC-E-SeatHold | AC-E-SeatHold__V3 | Class | SeatHold | «entity» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | holdRef, status, holdTime, expiryTime | recordPaymentTransaction, settlePaymentReport, checkHoldStillActive, endHold, issueBooking, expire, provideRefundNoticeRecipient |
| AC-E-PaymentTransaction | AC-E-PaymentTransaction__V3 | Class | PaymentTransaction | «entity» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | transactionCode, amount, processed, result, lateReason, refundedTotal, duplicateReportCount | createPaymentTransaction, checkNotProcessed, markProcessed, recordFailedResult, markLatePayment, recordDuplicateReport, prepareRefundRequest, checkRefundWithinPaidAmount, recordRefundedAmount, provideRefundSummary |
| AC-E-RefundRequest | AC-E-RefundRequest__V3 | Class | RefundRequest | «entity» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | idempotencyKey, requestType, refundAmount, attemptCount, result | createRefundRequest, generateIdempotencyKey, recordAttempt, recordResult, checkRetryRemaining |
| AC-E-Booking | AC-E-Booking__V3 | Class | Booking | «entity» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | bookingCode | createBooking, generateBookingCode, provideBookingInfo |
| AC-E-Customer | AC-E-Customer__V3 | Class | Customer | «entity» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | email, phoneNumber, password | provideEmail |
| AC-E-Showtime | AC-E-Showtime__V3 | Class | Showtime | «entity» | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | provideShowtimeInfo |
| AC-B-CancelTicketForm | AC-B-CancelTicketForm__V4 | Class | CancelTicketForm | «boundary» | Huỷ vé (UC-008) | - | selectTicketToCancel, notifyRefusal, showCancellationResult |
| AC-B-CounterCancelTicketForm | AC-B-CounterCancelTicketForm__V4 | Class | CounterCancelTicketForm | «boundary» | Huỷ vé (UC-008) | - | enterBookingCode, showBookingTickets, selectTicketToCancel, notifyRefusal, showCashRefund, confirmCashRefunded, showCancellationResult |
| AC-B-PaymentGateway | AC-B-PaymentGateway__V4 | Class | PaymentGateway | «boundary» | Huỷ vé (UC-008) | - | requestRefund |
| AC-B-BookTicketsForm | AC-B-BookTicketsForm__V4 | Class | BookTicketsForm | «boundary» | Huỷ vé (UC-008) | selectedSeats, credentials | updateSeatMap |
| AC-C-CancelTicketController | AC-C-CancelTicketController__V4 | Class | CancelTicketController | «control» | Huỷ vé (UC-008) | - | requestCancellation, findBookingTickets, confirmCashRefund, startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure |
| AC-E-Ticket | AC-E-Ticket__V4 | Class | Ticket | «entity» | Huỷ vé (UC-008) | ticketCode, qrCode, price, status | provideTicketContent, cancelTicket, checkNotCancelledNotUsed, markCancelled, calculateRefundAmount, recordCashRefund, releaseTicketSeat |
| AC-E-Booking | AC-E-Booking__V4 | Class | Booking | «entity» | Huỷ vé (UC-008) | bookingCode | provideBookingInfo, checkCancellationChannel, providePaymentTransaction |
| AC-E-Showtime | AC-E-Showtime__V4 | Class | Showtime | «entity» | Huỷ vé (UC-008) | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | checkBelongsToCinema, checkCancellationDeadline |
| AC-E-PaymentTransaction | AC-E-PaymentTransaction__V4 | Class | PaymentTransaction | «entity» | Huỷ vé (UC-008) | transactionCode, amount, processed, result, lateReason, refundedTotal, duplicateReportCount | prepareRefundRequest, checkRefundWithinPaidAmount, recordRefundedAmount |
| AC-E-RefundRequest | AC-E-RefundRequest__V4 | Class | RefundRequest | «entity» | Huỷ vé (UC-008) | idempotencyKey, requestType, refundAmount, attemptCount, result | createRefundRequest, generateIdempotencyKey, recordAttempt, recordResult, checkRetryRemaining, provideRefundInfo |
| AC-E-SeatHold | AC-E-SeatHold__V4 | Class | SeatHold | «entity» | Huỷ vé (UC-008) | holdRef, status, holdTime, expiryTime | checkHeldBy, providePaymentTransaction |
| AC-E-SeatStatus | AC-E-SeatStatus__V4 | Class | SeatStatus | «entity» | Huỷ vé (UC-008) | status, heldPrice | releaseSeat |
| AC-B-CheckTicketForm | AC-B-CheckTicketForm__V5 | Class | CheckTicketForm | «boundary» | Soát vé (UC-009) | scannedQr, checkingShowtime | selectCheckingShowtime, showCheckingShowtime, scanTicketQr, showValidTicket, rejectTicket |
| AC-C-CheckTicketController | AC-C-CheckTicketController__V5 | Class | CheckTicketController | «control» | Soát vé (UC-009) | - | startChecking, checkTicket |
| AC-E-TicketChecker | AC-E-TicketChecker__V5 | Class | TicketChecker | «entity» | Soát vé (UC-009) | - | provideCinema |
| AC-E-Showtime | AC-E-Showtime__V5 | Class | Showtime | «entity» | Soát vé (UC-009) | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | checkBelongsToCinema, provideShowtimeInfo |
| AC-E-Ticket | AC-E-Ticket__V5 | Class | Ticket | «entity» | Soát vé (UC-009) | ticketCode, qrCode, price, status | provideTicketContent, admitTicket, markUsed |
| AC-E-Booking | AC-E-Booking__V5 | Class | Booking | «entity» | Soát vé (UC-009) | bookingCode | provideBookingCode |
| AC-E-Cinema | AC-E-Cinema__V5 | Class | Cinema | «entity» | Soát vé (UC-009) | - | - |
| AC-B-ManagePriceListForm | AC-B-ManagePriceListForm__V6 | Class | ManagePriceListForm | «boundary» | Bảng giá (UC-013) | displayedPriceList, enteredPriceEntry, selectedPriceEntry | requestPriceListSetup, showPriceList, enterPriceEntry, notifyRefusal, showSavedPriceEntry, requestPriceRemoval, selectPriceEntryToRemove, showRemovalSuccess, cancelRequest |
| AC-C-ManagePriceListController | AC-C-ManagePriceListController__V6 | Class | ManagePriceListController | «control» | Bảng giá (UC-013) | - | startPriceListSetup, submitPriceEntry, startPriceRemoval, submitPriceEntryRemoval, cancelRequest, discardRequest |
| AC-E-CinemaManager | AC-E-CinemaManager__V6 | Class | CinemaManager | «entity» | Bảng giá (UC-013) | - | provideCinema |
| AC-E-PriceList | AC-E-PriceList__V6 | Class | PriceList | «entity» | Bảng giá (UC-013) | entryChangeTimes | providePriceEntries, checkTicketPriceValid, savePriceEntry, checkEntryUnchangedSinceDisplayed, findOrCreatePriceEntry, removePriceEntry, deletePriceEntry, determineTimeBand |
| AC-E-PriceEntry | AC-E-PriceEntry__V6 | Class | PriceEntry | «entity» | Bảng giá (UC-013) | auditoriumType, movieFormat, seatType, timeBand, ticketPrice, lastChangedAt | provideEntryInfo, setTicketPrice |
| AC-E-Showtime | AC-E-Showtime__V6 | Class | Showtime | «entity» | Bảng giá (UC-013) | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | checkUsesPriceEntry |
| AC-E-Cinema | AC-E-Cinema__V6 | Class | Cinema | «entity» | Bảng giá (UC-013) | - | - |
| AC-B-ScheduleShowtimesForm | AC-B-ScheduleShowtimesForm__V7 | Class | ScheduleShowtimesForm | «boundary» | Lịch chiếu (UC-014) | showtimeInput, selectedShowtime | requestNewShowtime, requestEditShowtime, requestDeleteShowtime, showAuditoriumsAndMovies, submitShowtimeInfo, showShowtimes, selectShowtimeToEdit, selectShowtimeToDelete, showShowtimeForEdit, showSavedShowtime, notifyDeleted, notifyRefusal, cancelRequest, showRequestCancelled |
| AC-C-ScheduleShowtimesController | AC-C-ScheduleShowtimesController__V7 | Class | ScheduleShowtimesController | «control» | Lịch chiếu (UC-014) | - | startScheduling, requestSaveShowtime, startEditingShowtime, prepareShowtimeEdit, startDeletingShowtime, deleteShowtime, cancelRequest, discardRequest |
| AC-E-CinemaManager | AC-E-CinemaManager__V7 | Class | CinemaManager | «entity» | Lịch chiếu (UC-014) | - | provideCinema |
| AC-E-Cinema | AC-E-Cinema__V7 | Class | Cinema | «entity» | Lịch chiếu (UC-014) | - | provideAuditoriums, provideShowtimes |
| AC-E-Auditorium | AC-E-Auditorium__V7 | Class | Auditorium | «entity» | Lịch chiếu (UC-014) | name, auditoriumType, supportedFormats | provideAuditoriumInfo, checkBelongsToCinema, checkSupportsFormat, provideSeatTypes, draftShowtime, saveShowtime, checkRoomGap, addToSchedule |
| AC-E-Movie | AC-E-Movie__V7 | Class | Movie | «entity» | Lịch chiếu (UC-014) | title, releaseFormats, duration, releaseDate, endOfRunDate | provideMovieInfo, checkReleasedInFormat, checkWithinRunPeriod, provideDuration |
| AC-E-Showtime | AC-E-Showtime__V7 | Class | Showtime | «entity» | Lịch chiếu (UC-014) | startTime, saleOpenTime, endTime, lastChangedAt, movieFormat, auditoriumType, status | checkUnchangedSinceDisplayed, createShowtime, checkSaleOpenBeforeStart, calculateEndTime, checkNotStarted, checkNoActiveHoldOrSoldTicket, applyChanges, removeFromSchedule, markDeleted, provideShowtimeInfo |
| AC-E-PriceList | AC-E-PriceList__V7 | Class | PriceList | «entity» | Lịch chiếu (UC-014) | entryChangeTimes | checkCoversShowtime |
| AC-E-SeatHold | AC-E-SeatHold__V7 | Class | SeatHold | «entity» | Lịch chiếu (UC-014) | holdRef, status, holdTime, expiryTime | checkHoldStillActive |
| AC-E-Ticket | AC-E-Ticket__V7 | Class | Ticket | «entity» | Lịch chiếu (UC-014) | ticketCode, qrCode, price, status | checkNotCancelled |

b) Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Thuộc về (view) |
|---|---|---|---|---|---|
| R-38 | AC-E-Cinema | AC-E-Auditorium | Aggregation | đầu nguồn 1; đầu đích 4..12 | Entity |
| R-39 | AC-E-Auditorium | AC-E-Seat | Aggregation | đầu nguồn 1; đầu đích 50..400 | Entity |
| R-40 | AC-E-Cinema | AC-E-PriceList | Association | đầu nguồn 1; đầu đích 1 | Entity |
| R-41 | AC-E-PriceList | AC-E-PriceEntry | Composition | đầu nguồn 1; đầu đích 0..72 | Entity |
| R-42 | AC-E-Auditorium | AC-E-Showtime | Association | đầu nguồn 1; đầu đích 0..* | Entity |
| R-43 | AC-E-Showtime | AC-E-Movie | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-44 | AC-E-Showtime | AC-E-SeatStatus | Association | đầu nguồn 1; đầu đích 50..400 | Entity |
| R-45 | AC-E-SeatStatus | AC-E-Seat | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-46 | AC-E-Showtime | AC-E-SeatHold | Association | đầu nguồn 1; đầu đích 0..* | Entity |
| R-47 | AC-E-SeatHold | AC-E-SeatStatus | Association | đầu nguồn 0..*; đầu đích 1..8 | Entity |
| R-48 | AC-E-SeatHold | AC-E-Customer | Association | đầu nguồn 0..*; đầu đích 0..1; {xor} | Entity |
| R-49 | AC-E-SeatHold | AC-E-BoxOfficeClerk | Association | đầu nguồn 0..*; đầu đích 0..1; {xor} | Entity |
| R-50 | AC-E-SeatHold | AC-E-PaymentTransaction | Association | đầu nguồn 1; đầu đích 0..* | Entity |
| R-51 | AC-E-SeatHold | AC-E-Booking | Association | đầu nguồn 1; đầu đích 0..1 | Entity |
| R-52 | AC-E-Booking | AC-E-Ticket | Aggregation | đầu nguồn 1; đầu đích 1..8 | Entity |
| R-53 | AC-E-Ticket | AC-E-Showtime | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-54 | AC-E-Ticket | AC-E-SeatStatus | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-55 | AC-E-PaymentTransaction | AC-E-RefundRequest | Association | đầu nguồn 0..1; đầu đích 0..* | Entity |
| R-56 | AC-E-Ticket | AC-E-RefundRequest | Association | đầu nguồn 0..1; đầu đích 0..1 | Entity |
| R-57 | AC-E-BoxOfficeClerk | AC-E-Cinema | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-58 | AC-E-TicketChecker | AC-E-Cinema | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-59 | AC-E-CinemaManager | AC-E-Cinema | Association | đầu nguồn 0..*; đầu đích 1 | Entity |
| R-60 | AC-E-Showtime | AC-E-PriceList | Dependency | phụ thuộc gọi (đầu mũi tên mở, nét đứt) | Entity |
| R-61 | AC-E-PriceList | AC-E-Showtime | Dependency | phụ thuộc gọi (đầu mũi tên mở, nét đứt) | Entity |
| R-62 | AC-E-Auditorium | AC-E-PriceList | Dependency | phụ thuộc gọi (đầu mũi tên mở, nét đứt) | Entity |
| R-01__V2 | AC-B-BookTicketsForm__V2 | AC-C-BookTicketsController__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-02__V2 | AC-B-CounterBookTicketsForm__V2 | AC-C-BookTicketsController__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-03__V2 | AC-B-PaymentGateway__V2 | AC-C-BookTicketsController__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-07__V2 | AC-C-BookTicketsController__V2 | AC-E-Customer__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-08__V2 | AC-C-BookTicketsController__V2 | AC-E-BoxOfficeClerk__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-09__V2 | AC-C-BookTicketsController__V2 | AC-E-Showtime__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-10__V2 | AC-C-BookTicketsController__V2 | AC-E-SeatHold__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-11__V2 | AC-C-BookTicketsController__V2 | AC-E-Booking__V2 | Association | tạm thời | Đặt vé (UC-005) |
| R-46__V2 | AC-E-Showtime__V2 | AC-E-SeatHold__V2 | Association | đầu nguồn 1; đầu đích 0..* | Đặt vé (UC-005) |
| R-48__V2 | AC-E-SeatHold__V2 | AC-E-Customer__V2 | Association | đầu nguồn 0..*; đầu đích 0..1; {xor} | Đặt vé (UC-005) |
| R-49__V2 | AC-E-SeatHold__V2 | AC-E-BoxOfficeClerk__V2 | Association | đầu nguồn 0..*; đầu đích 0..1; {xor} | Đặt vé (UC-005) |
| R-51__V2 | AC-E-SeatHold__V2 | AC-E-Booking__V2 | Association | đầu nguồn 1; đầu đích 0..1 | Đặt vé (UC-005) |
| R-04__V3 | AC-B-EmailService__V3 | AC-C-PaymentReportController__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-05__V3 | AC-B-PaymentGateway__V3 | AC-C-PaymentReportController__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-06__V3 | AC-B-BookTicketsForm__V3 | AC-C-PaymentReportController__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-12__V3 | AC-C-PaymentReportController__V3 | AC-E-SeatHold__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-13__V3 | AC-C-PaymentReportController__V3 | AC-E-Booking__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-14__V3 | AC-C-PaymentReportController__V3 | AC-E-PaymentTransaction__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-15__V3 | AC-C-PaymentReportController__V3 | AC-E-RefundRequest__V3 | Association | tạm thời | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-46__V3 | AC-E-Showtime__V3 | AC-E-SeatHold__V3 | Association | đầu nguồn 1; đầu đích 0..* | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-48__V3 | AC-E-SeatHold__V3 | AC-E-Customer__V3 | Association | đầu nguồn 0..*; đầu đích 0..1; {xor} | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-50__V3 | AC-E-SeatHold__V3 | AC-E-PaymentTransaction__V3 | Association | đầu nguồn 1; đầu đích 0..* | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-51__V3 | AC-E-SeatHold__V3 | AC-E-Booking__V3 | Association | đầu nguồn 1; đầu đích 0..1 | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-55__V3 | AC-E-PaymentTransaction__V3 | AC-E-RefundRequest__V3 | Association | đầu nguồn 0..1; đầu đích 0..* | Báo thanh toán và hoàn tiền trễ (UC-005, UC-006) |
| R-16__V4 | AC-B-CancelTicketForm__V4 | AC-C-CancelTicketController__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-17__V4 | AC-B-CounterCancelTicketForm__V4 | AC-C-CancelTicketController__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-18__V4 | AC-B-PaymentGateway__V4 | AC-C-CancelTicketController__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-19__V4 | AC-B-BookTicketsForm__V4 | AC-C-CancelTicketController__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-20__V4 | AC-C-CancelTicketController__V4 | AC-E-Ticket__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-21__V4 | AC-C-CancelTicketController__V4 | AC-E-Booking__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-22__V4 | AC-C-CancelTicketController__V4 | AC-E-Showtime__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-23__V4 | AC-C-CancelTicketController__V4 | AC-E-PaymentTransaction__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-24__V4 | AC-C-CancelTicketController__V4 | AC-E-RefundRequest__V4 | Association | tạm thời | Huỷ vé (UC-008) |
| R-46__V4 | AC-E-Showtime__V4 | AC-E-SeatHold__V4 | Association | đầu nguồn 1; đầu đích 0..* | Huỷ vé (UC-008) |
| R-47__V4 | AC-E-SeatHold__V4 | AC-E-SeatStatus__V4 | Association | đầu nguồn 0..*; đầu đích 1..8 | Huỷ vé (UC-008) |
| R-50__V4 | AC-E-SeatHold__V4 | AC-E-PaymentTransaction__V4 | Association | đầu nguồn 1; đầu đích 0..* | Huỷ vé (UC-008) |
| R-51__V4 | AC-E-SeatHold__V4 | AC-E-Booking__V4 | Association | đầu nguồn 1; đầu đích 0..1 | Huỷ vé (UC-008) |
| R-52__V4 | AC-E-Booking__V4 | AC-E-Ticket__V4 | Aggregation | đầu nguồn 1; đầu đích 1..8 | Huỷ vé (UC-008) |
| R-53__V4 | AC-E-Ticket__V4 | AC-E-Showtime__V4 | Association | đầu nguồn 0..*; đầu đích 1 | Huỷ vé (UC-008) |
| R-54__V4 | AC-E-Ticket__V4 | AC-E-SeatStatus__V4 | Association | đầu nguồn 0..*; đầu đích 1 | Huỷ vé (UC-008) |
| R-55__V4 | AC-E-PaymentTransaction__V4 | AC-E-RefundRequest__V4 | Association | đầu nguồn 0..1; đầu đích 0..* | Huỷ vé (UC-008) |
| R-56__V4 | AC-E-Ticket__V4 | AC-E-RefundRequest__V4 | Association | đầu nguồn 0..1; đầu đích 0..1 | Huỷ vé (UC-008) |
| R-25__V5 | AC-B-CheckTicketForm__V5 | AC-C-CheckTicketController__V5 | Association | tạm thời | Soát vé (UC-009) |
| R-26__V5 | AC-C-CheckTicketController__V5 | AC-E-TicketChecker__V5 | Association | tạm thời | Soát vé (UC-009) |
| R-27__V5 | AC-C-CheckTicketController__V5 | AC-E-Showtime__V5 | Association | tạm thời | Soát vé (UC-009) |
| R-28__V5 | AC-C-CheckTicketController__V5 | AC-E-Ticket__V5 | Association | tạm thời | Soát vé (UC-009) |
| R-52__V5 | AC-E-Booking__V5 | AC-E-Ticket__V5 | Aggregation | đầu nguồn 1; đầu đích 1..8 | Soát vé (UC-009) |
| R-53__V5 | AC-E-Ticket__V5 | AC-E-Showtime__V5 | Association | đầu nguồn 0..*; đầu đích 1 | Soát vé (UC-009) |
| R-58__V5 | AC-E-TicketChecker__V5 | AC-E-Cinema__V5 | Association | đầu nguồn 0..*; đầu đích 1 | Soát vé (UC-009) |
| R-29__V6 | AC-B-ManagePriceListForm__V6 | AC-C-ManagePriceListController__V6 | Association | tạm thời | Bảng giá (UC-013) |
| R-30__V6 | AC-C-ManagePriceListController__V6 | AC-E-CinemaManager__V6 | Association | tạm thời | Bảng giá (UC-013) |
| R-31__V6 | AC-C-ManagePriceListController__V6 | AC-E-PriceList__V6 | Association | tạm thời | Bảng giá (UC-013) |
| R-40__V6 | AC-E-Cinema__V6 | AC-E-PriceList__V6 | Association | đầu nguồn 1; đầu đích 1 | Bảng giá (UC-013) |
| R-41__V6 | AC-E-PriceList__V6 | AC-E-PriceEntry__V6 | Composition | đầu nguồn 1; đầu đích 0..72 | Bảng giá (UC-013) |
| R-59__V6 | AC-E-CinemaManager__V6 | AC-E-Cinema__V6 | Association | đầu nguồn 0..*; đầu đích 1 | Bảng giá (UC-013) |
| R-61__V6 | AC-E-PriceList__V6 | AC-E-Showtime__V6 | Dependency | phụ thuộc gọi (đầu mũi tên mở, nét đứt) | Bảng giá (UC-013) |
| R-32__V7 | AC-B-ScheduleShowtimesForm__V7 | AC-C-ScheduleShowtimesController__V7 | Association | tạm thời | Lịch chiếu (UC-014) |
| R-33__V7 | AC-C-ScheduleShowtimesController__V7 | AC-E-CinemaManager__V7 | Association | tạm thời | Lịch chiếu (UC-014) |
| R-34__V7 | AC-C-ScheduleShowtimesController__V7 | AC-E-Auditorium__V7 | Association | tạm thời | Lịch chiếu (UC-014) |
| R-35__V7 | AC-C-ScheduleShowtimesController__V7 | AC-E-Movie__V7 | Association | tạm thời | Lịch chiếu (UC-014) |
| R-36__V7 | AC-C-ScheduleShowtimesController__V7 | AC-E-Showtime__V7 | Association | tạm thời | Lịch chiếu (UC-014) |
| R-37__V7 | AC-C-ScheduleShowtimesController__V7 | AC-E-PriceList__V7 | Association | tạm thời | Lịch chiếu (UC-014) |
| R-38__V7 | AC-E-Cinema__V7 | AC-E-Auditorium__V7 | Aggregation | đầu nguồn 1; đầu đích 4..12 | Lịch chiếu (UC-014) |
| R-40__V7 | AC-E-Cinema__V7 | AC-E-PriceList__V7 | Association | đầu nguồn 1; đầu đích 1 | Lịch chiếu (UC-014) |
| R-42__V7 | AC-E-Auditorium__V7 | AC-E-Showtime__V7 | Association | đầu nguồn 1; đầu đích 0..* | Lịch chiếu (UC-014) |
| R-43__V7 | AC-E-Showtime__V7 | AC-E-Movie__V7 | Association | đầu nguồn 0..*; đầu đích 1 | Lịch chiếu (UC-014) |
| R-46__V7 | AC-E-Showtime__V7 | AC-E-SeatHold__V7 | Association | đầu nguồn 1; đầu đích 0..* | Lịch chiếu (UC-014) |
| R-53__V7 | AC-E-Ticket__V7 | AC-E-Showtime__V7 | Association | đầu nguồn 0..*; đầu đích 1 | Lịch chiếu (UC-014) |
| R-59__V7 | AC-E-CinemaManager__V7 | AC-E-Cinema__V7 | Association | đầu nguồn 0..*; đầu đích 1 | Lịch chiếu (UC-014) |
| R-62__V7 | AC-E-Auditorium__V7 | AC-E-PriceList__V7 | Dependency | phụ thuộc gọi (đầu mũi tên mở, nét đứt) | Lịch chiếu (UC-014) |

## F6. Rà soát lớp phân tích

| AC | Tên phản ánh đúng vai trò | Một khái niệm duy nhất | Trách nhiệm gắn kết | Cung cấp đủ hành vi cần | Yêu cầu đặc thù (BR, NFR) đã gắn | Ghi chú |
|---|---|---|---|---|---|---|
| AC-B-BookTicketsForm | Đạt | Đạt | Đạt | Đạt | Đạt: REQ-119 (updateSeatMap), NFR-06 | Là điểm nhận updateSeatMap của UC-008 và PaymentReportController (ngoại lệ A3, F2a STT 20) |
| AC-B-CounterBookTicketsForm | Đạt | Đạt | Đạt | Đạt | Đạt: BR-44, REQ-119 | - |
| AC-B-PaymentGateway | Đạt | Đạt | Đạt | Đạt | Đạt: BR-43 (kết quả hoàn trả về trong 30 giây), GL-17, NFR-16 | Một boundary cho cả hai vai trò của ACT-07 |
| AC-B-EmailService | Đạt | Đạt | Đạt | Đạt | Đạt: BR-41 (không gửi email khi hoàn lỗi), BR-89 | - |
| AC-B-CancelTicketForm | Đạt | Đạt | Đạt | Đạt | Đạt: BR-17 | - |
| AC-B-CounterCancelTicketForm | Đạt | Đạt | Đạt | Đạt | Đạt: BR-17, BR-20 | - |
| AC-B-CheckTicketForm | Đạt | Đạt | Đạt | Đạt | Đạt: BR-34, BR-33; giữ suất chiếu đang soát trong phiên làm việc (Q-97) | - |
| AC-B-ManagePriceListForm | Đạt | Đạt | Đạt | Đạt | Đạt: BR-61, BR-63 | - |
| AC-B-ScheduleShowtimesForm | Đạt | Đạt | Đạt | Đạt | Đạt: BR-46, BR-60 | 14 trách nhiệm giao tiếp tác nhân |
| AC-C-BookTicketsController | Đạt | Đạt | Đạt | Đạt | Đạt: BR-10 và REQ-76 (hẹn hết hạn), BR-44 | Ba trách nhiệm là message tự gọi theo A2 |
| AC-C-PaymentReportController | Đạt | Đạt | Không đạt: bốn trách nhiệm chờ, thử lại, log hoàn tiền trùng với CancelTicketController | Đạt | Đạt: BR-85, BR-41, BR-43 | Hành động: Q-106, P02R (Đề xuất sửa artifact trước) |
| AC-C-CancelTicketController | Đạt | Đạt | Không đạt: bốn trách nhiệm trùng với PaymentReportController | Đạt | Đạt: BR-41, BR-42, BR-43 | Hành động: Q-106, P02R |
| AC-C-CheckTicketController | Đạt | Đạt | Đạt | Đạt | Đạt: BR-33, BR-34 | 2 trách nhiệm, đủ ngưỡng tối thiểu |
| AC-C-ManagePriceListController | Đạt | Đạt | Đạt | Đạt | Đạt: BR-61 | - |
| AC-C-ScheduleShowtimesController | Đạt | Đạt | Đạt | Đạt | Đạt: BR-46 | Vòng lặp qua phòng chiếu và suất chiếu chuyển cho Cinema khi có P07 của UC-011 |
| AC-E-Customer | Đạt | Đạt | Đạt | - | Đạt: BR-04, BR-81, BR-82 | Tạm; UC-001 và UC-007 bổ sung hành vi |
| AC-E-BoxOfficeClerk | Đạt | Đạt | Đạt | - | Đạt: BR-02, BR-04, BR-78 | Tạm; chỉ có hai trách nhiệm, xem Vấn đề còn mở 4 |
| AC-E-TicketChecker | Đạt | Đạt | Đạt | - | Đạt: BR-22, BR-34, BR-78 | Tạm; một trách nhiệm cung cấp dữ liệu, xem Vấn đề còn mở 4 |
| AC-E-CinemaManager | Đạt | Đạt | Đạt | - | Đạt: BR-46, BR-61, BR-78 | Tạm; một trách nhiệm cung cấp dữ liệu, xem Vấn đề còn mở 4 |
| AC-E-Cinema | Đạt | Đạt | Đạt | - | Đạt: BR-78 (nhân viên thuộc đúng một cụm rạp), GL-03 | Tạm; lớp mới tách theo Q-81 |
| AC-E-Auditorium | Đạt | Đạt | Đạt | - | Đạt: BR-51, BR-52, BR-68, BR-69 | Tạm; chủ sở hữu UC-012; 8 trách nhiệm |
| AC-E-Seat | Đạt | Đạt | Đạt | - | Đạt: BR-06, BR-87 | Tạm; lớp mới tách theo Q-81 |
| AC-E-Movie | Đạt | Đạt | Đạt | - | Đạt: BR-47, BR-49, BR-50 | Tạm; chủ sở hữu UC-010 |
| AC-E-Showtime | Đạt | Đạt | Không đạt: 17 trách nhiệm gồm cả phần bán vé và phần lập lịch | Đạt | Đạt: BR-54, BR-09, BR-12 (qua PriceList), BR-58 | Hành động: Vấn đề còn mở 2 (cân nhắc tách suất chiếu dự kiến ở P10, Q-102) |
| AC-E-PriceList | Đạt | Đạt | Đạt | Đạt | Đạt: BR-62, BR-63, BR-64, BR-68, BR-71, BR-12 | 10 trách nhiệm |
| AC-E-PriceEntry | Đạt | Đạt | Đạt | Đạt | Đạt: BR-62, BR-65, BR-67 | - |
| AC-E-SeatStatus | Đạt | Đạt | Đạt | Đạt | Đạt: BR-07, BR-08, BR-09, BR-42, REQ-76 | Mỗi ghế một trạng thái trong mỗi suất chiếu, Q-109 |
| AC-E-SeatHold | Đạt | Đạt | Đạt: 15 trách nhiệm cùng quanh vòng đời một lần giữ ghế | Đạt | Đạt: BR-04, BR-10, BR-85, BR-86, NFR-07 | Lớp lớn nhất của chủ đề race condition; theo dõi độ lớn ở P10 |
| AC-E-PaymentTransaction | Đạt | Đạt | Đạt | Đạt | Đạt: BR-26, BR-37, BR-40 | 10 trách nhiệm |
| AC-E-RefundRequest | Đạt | Đạt | Đạt | Đạt | Đạt: BR-41, BR-43 | - |
| AC-E-Booking | Đạt | Đạt | Đạt | Đạt | Đạt: BR-80, BR-05 | - |
| AC-E-Ticket | Đạt | Đạt | Đạt | Đạt | Đạt: BR-21, BR-30, BR-33, BR-67 | 12 trách nhiệm |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-106 | Cơ chế hoàn tiền qua cổng (chờ 30 giây, thử lại, ghi log lỗi, khoá chống hoàn trùng) lặp ở hai control: PaymentReportController (UC-006) và CancelTicketController (UC-008), vì hai use case không include nhau và control không gọi control của use case khác. Có tách use case được include "Hoàn tiền qua cổng thanh toán" cho UC-006 và UC-008 (một control mới nhận bốn trách nhiệm trùng) hay giữ hai bộ trách nhiệm trùng tên? (Tách use case được include / Giữ như hiện tại). Đề xuất: tách, vì hai bên cùng chịu BR-26, BR-41, BR-43 nên đổi quy tắc hoàn chỉ sửa một nơi | AC-C-PaymentReportController, AC-C-CancelTicketController; P02, P03; F2a STT 19 | P07 UC-006 và UC-008 (R7-06) chỉ ghi nhận đề xuất P02R; A3 và F6 cấm gộp control hai use case |
| Q-107 | Cụm rạp gồm phòng chiếu và phòng chiếu gồm ghế (R-38, R-39) đang là aggregation với số lượng 4 đến 12 phòng mỗi cụm rạp và 50 đến 400 ghế mỗi phòng (REQ-01, REQ-03 qua GL-03, GL-50). Khi một phòng chiếu hoặc cụm rạp ngừng dùng thì ghế và phòng có bị bỏ cùng (composition) không, và hai khoảng số lượng có là ràng buộc của hệ thống không? (Composition / Aggregation giữ khoảng số lượng / Aggregation, không ràng buộc số lượng). Đề xuất: quyết khi có P07 của UC-011, UC-012 | R-38, R-39; AC-E-Cinema, AC-E-Auditorium, AC-E-Seat | GL-03 "gồm nhiều Phòng chiếu", GL-07, GL-50; UC-011, UC-012 chưa có P04 và P07 |
| Q-108 | BoxOfficeClerk, TicketChecker, CinemaManager đều thuộc đúng một cụm rạp (BR-78) và chỉ có cụm rạp cùng trách nhiệm cung cấp cụm rạp; Quản lý chuỗi (GL-41) cũng là nhân viên nhưng không thuộc cụm rạp nào. Có lớp cha Staff (GL-34) cho bốn vai trò không, và mỗi cụm rạp có tối đa bao nhiêu nhân viên mỗi vai trò (R-57, R-58, R-59 đang ghi 0..* phía nhân viên vì nguồn không giới hạn)? (Tạo lớp cha Staff có cụm rạp không bắt buộc / Giữ ba entity riêng / Giới hạn số quản lý cụm rạp mỗi cụm). Đề xuất: giữ ba entity riêng, quyết khi có P07 của UC-017 | AC-E-BoxOfficeClerk, AC-E-TicketChecker, AC-E-CinemaManager; R-57, R-58, R-59; F2a STT 41 | GL-34, GL-35, GL-36, GL-41, GL-42; BR-78, BR-79; UC-017 chưa có P07 |
| Q-109 | Mỗi ghế của phòng chiếu có một trạng thái ghế trong mỗi suất chiếu (R-44: 50..400) nhưng không use case nào đã phân tích tạo chúng: UC-014 bước 8 chỉ ghi suất chiếu vào lịch phòng. Ai tạo trạng thái ghế cho từng ghế, và khi sửa suất chiếu sang phòng khác (chỉ khi chưa có ghế giữ hoặc vé, BR-53) thì tạo lại? (Showtime tạo trạng thái ghế cho từng Seat của phòng trong addToSchedule, tạo lại khi sửa phòng / Tạo khi lần đầu có người giữ ghế, khi đó R-44 là 0..*). Đề xuất: Showtime tạo trong thao tác lưu suất chiếu (EX-13) | AC-E-Showtime, AC-E-SeatStatus, AC-E-Auditorium; R-44; EX-13; P07 UC-014 | GL-58, BR-53; P04 UC-014 Mục 8 không nêu việc tạo trạng thái ghế |
| Q-110 | BR-84 nói phim hoặc phòng chiếu thay đổi sau khi lập suất chiếu không làm suất chiếu đã lập tự đổi. Nếu loại phòng của một phòng chiếu đổi (UC-012) sau khi suất chiếu đã lập thì việc tính giá, BR-64 và BR-69 theo loại phòng lúc lập (Showtime giữ auditoriumType) hay theo loại phòng hiện tại (Showtime suy ra từ Auditorium)? (Chụp lại lúc lập, giữ Showtime.auditoriumType / Theo phòng hiện tại, hạ thuộc tính). Đề xuất: chụp lại lúc lập (đúng chữ BR-84) và UC-012 xác nhận có cho đổi loại phòng của phòng đang có suất chiếu hay không | AC-E-Showtime (auditoriumType), AC-E-PriceList; EX-01, EX-12, EX-13; F2b STT 4 | BR-84, BR-64, BR-69, BR-87; UC-012 chưa có P04 |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P07 | UC-005, AC-E-BoxOfficeClerk | Thuộc tính cinema được control truyền làm tham số cho Showtime.checkBelongsToCinema (SD11a message 1.1.1b) nhưng không có trách nhiệm hay message lấy cụm rạp của nhân viên quầy, khác CinemaManager và TicketChecker | Thêm trách nhiệm provideCinema vào BoxOfficeClerk và message từ BookTicketsController |
| P07 | UC-005, AC-E-SeatStatus, AC-E-Showtime, AC-E-PriceList; R-UC005-11, R-UC005-12 | P08 tách Cinema, Seat theo Q-81: seatPosition, seatType chuyển sang Seat; thuộc tính cinema thành quan hệ; R-UC005-11 đổi phía SeatStatus từ 1..* thành 50..400; R-UC005-12 thay bằng đường Showtime - Auditorium - Cinema - PriceList và phụ thuộc gọi chéo R-60 | Khi chạy lại, dùng F3, F4 của P08 làm sổ đăng ký AC; sequence của holdSeats gọi Auditorium, Cinema khi cần cụm rạp |
| P07 | UC-005 mục 4 (bảng đơn vị loại trừ) | Bảng cục bộ thiếu thao tác trên PaymentTransaction (prepareRefundRequest, recordRefundedAmount), RefundRequest, Ticket.releaseTicketSeat và hạng khoá của Ticket, RefundRequest | Dẫn tới F4b của P08 làm bảng chính thức |
| P07 | UC-006, AC-E-Showtime (movieName, provideMovieAndStartTime); R-UC006-07 | movieName suy ra từ Movie; provideMovieAndStartTime trùng nghĩa với provideShowtimeInfo; yêu cầu hoàn tiền mặt của UC-008 không có giao dịch nên phía PaymentTransaction của R-UC006-07 là 0..1 | Bỏ movieName, đổi tên trách nhiệm thành provideShowtimeInfo; sửa R-UC006-07 thành A 0..1 - B 0..* |
| P07 | UC-008, AC-E-SeatStatus.releaseSoldSeat; AC-E-Ticket (seatPosition, seatType); R-UC008-14 | Hai trách nhiệm giải phóng ghế khác tên cùng nghĩa; vị trí, loại ghế của vé suy ra qua SeatStatus và Seat; multiplicity R-UC008-14 | Đổi releaseSoldSeat thành releaseSeat có tiền điều kiện; hạ seatPosition, seatType khỏi Ticket; sửa R-UC008-14 thành A 0..1 - B 0..* |
| P07 | UC-006 và UC-008, AC-E-PaymentTransaction.prepareRefundRequest, recordRefundedAmount | Hai vé của cùng một giao dịch có thể được huỷ đồng thời nhưng cộng vào tổng đã hoàn (BR-26) không được ghi là thao tác không chia cắt | Thêm vào bảng thao tác không chia cắt của hai file (EX-09) |
| P07 | UC-009, AC-E-Showtime (provideShowtimeForChecking, movieTitle, auditoriumName); AC-E-TicketChecker.cinema | Trùng nghĩa với provideShowtimeInfo, quan hệ tới Movie, Auditorium; cinema thành quan hệ | Đổi tên trách nhiệm thành provideShowtimeInfo, bỏ hai thuộc tính, bỏ cinema |
| P07 | UC-013, AC-E-Showtime.scheduleStatus; AC-E-PriceList.cinema; AC-E-CinemaManager.cinema; R-UC013-05 | scheduleStatus trùng status của UC-014; cinema thành quan hệ; Showtime - PriceList thay bằng đường qua Cinema và phụ thuộc gọi PriceList sang Showtime | Đổi scheduleStatus thành status, bỏ cinema, thay R-UC013-05 bằng phụ thuộc (R-61) |
| P07 | UC-014, AC-E-Showtime.checkStartAfter; AC-E-Auditorium (seatTypes, cinema); vòng lặp phòng chiếu và suất chiếu của ScheduleShowtimesController; R-UC014-08 | checkStartAfter trùng nghĩa checkNotStarted; seatTypes suy ra từ Seat; vòng lặp thuộc Cinema; chưa có message tạo trạng thái ghế khi lưu suất chiếu (Q-109) | Gộp checkStartAfter vào checkNotStarted; bỏ seatTypes; chuyển vòng lặp sang Cinema.provideAuditoriums, provideShowtimes; thay R-UC014-08 bằng phụ thuộc R-62; thêm bước tạo trạng thái ghế theo Q-109 |
| P02R | UC-006, UC-008 | Cơ chế hoàn tiền qua cổng lặp ở hai control (Q-106) | Cân nhắc tách use case được include "Hoàn tiền qua cổng thanh toán" |
| P03 | Quan hệ UC-005 và UC-006 | Đề xuất của P07 UC-005, UC-006 về điểm tiếp nhận báo kết quả giao dịch dùng chung (PaymentReportController) | Giữ nguyên đề xuất, chưa lặp lại nội dung |
| P04 | UC-006 Mục 8, UC-008 Mục 8 | BR-26 áp dụng cho hai vé của một giao dịch huỷ đồng thời nhưng đặc tả chỉ nêu thao tác không chia cắt cho giữ ghế, báo thanh toán, huỷ và soát vé | Nêu rõ kiểm và cộng khoản hoàn vào tổng đã hoàn của một giao dịch là một thao tác không chia cắt theo giao dịch |

## Vấn đề còn mở

1. Độ phủ: mười use case chưa có P07 (UC-001, UC-003, UC-004, UC-007, UC-010, UC-011, UC-012, UC-015, UC-016, UC-017). Tám lớp Tạm (Customer, BoxOfficeClerk, TicketChecker, CinemaManager, Cinema, Auditorium, Seat, Movie) và các quan hệ R-38, R-39, R-45, R-57, R-58, R-59 chỉ gồm phần các use case đã phân tích cần; chạy lại P08 với phiên bản tăng lên khi có P07 của UC-001, UC-010, UC-011, UC-012, UC-017. UC-003, UC-004, UC-007, UC-015, UC-016 chủ yếu đọc Showtime, Ticket, Booking, Movie và có thể thêm trách nhiệm đọc.
2. Độ lớn lớp: Showtime 17 trách nhiệm, SeatHold 15, Ticket 12, PriceList 10, PaymentTransaction 10. Showtime gộp phần bán vé (UC-005, UC-008, UC-009) và phần lập lịch (UC-014); không tách ở P08 vì mọi trách nhiệm gắn với cùng dữ liệu suất chiếu. Đề xuất P10 cân nhắc tách suất chiếu dự kiến (Q-102) và giữ SeatHold một lớp vì mọi trách nhiệm quanh vòng đời một lần giữ ghế (BR-85, BR-86).
3. Bốn trách nhiệm hoàn tiền (startWaitingForRefundResult, stopWaitingForRefundResult, handleRefundNoResponse, logRefundFailure) còn trùng ở PaymentReportController và CancelTicketController cho tới khi có quyết định Q-106; hai control còn lại không vượt ngưỡng (6 và 7 trách nhiệm).
4. Entity nhân viên thiếu hành vi: BoxOfficeClerk (2 trách nhiệm), TicketChecker (1), CinemaManager (1) chỉ cung cấp cụm rạp hoặc kiểm BR-04; hành vi tạo, gán cụm rạp, phân vai trò thuộc UC-017. Giữ vì BR-02, BR-22, BR-34, BR-46, BR-61 cần cụm rạp của nhân viên; không lập lớp cha Staff khi chưa có P07 của UC-017 (Q-108).
5. Cơ chế loại trừ chuyển cho P09, các điểm cần lưu ý: (a) EX-01 lấy khoá Showtime (X) nên mọi holdSeats của một suất chiếu tuần tự; với NFR-05 (1.000 khách một suất chiếu) và NFR-06 (giữ ghế không quá 2 giây) P09 cân nhắc thu hẹp xuống từng SeatStatus theo thứ tự vị trí ghế, miễn giữ loại trừ với EX-13, EX-14; (b) EX-13, EX-14 cần đọc chung nhiều SeatHold, Ticket của một suất chiếu; (c) EX-09 cần chống mất cập nhật tổng đã hoàn; (d) sự kiện hết hạn (BR-10, REQ-76, NFR-07) phải xảy ra kể cả khi tác nhân đã rời phiên hoặc tiến trình khởi động lại, và chạy được trên suất chiếu Đã xoá (BR-58).
6. Phụ thuộc gọi chéo Showtime - PriceList theo cả hai chiều (R-60, R-61) và Auditorium sang PriceList (R-62) chỉ an toàn nhờ thứ tự khoá (PriceList hạng 1). P12 xem xét truyền giá trị hoặc dùng interface thay vì giữ đối tượng gọi lẫn nhau.
7. Ngoại lệ boundary người dùng dùng chung: BookTicketsForm là điểm nhận updateSeatMap của UC-008 và PaymentReportController (R-06, R-19). CounterBookTicketsForm cũng cần nhận cập nhật nhưng P07 không vẽ quan hệ từ PaymentReportController và CancelTicketController tới nó nên P08 không thêm. Cách phát cập nhật (REQ-119) chọn ở P09, P12.
8. R-53 (Ticket - Showtime) suy ra được qua R-54 và R-44 nhưng giữ vì UC-009, UC-014 gọi trực tiếp; hai đường phải nhất quán. Showtime.auditoriumType giữ chờ Q-110.
9. Q-97 đã áp theo đề xuất (suất chiếu đang soát chỉ trong phiên làm việc, CheckTicketForm giữ). Nếu người dùng chọn gắn với nhân viên thì TicketChecker giữ checkingShowtime và có trách nhiệm ghi nhận suất chiếu đang soát.
10. Trang Entity có 25 cạnh, đúng ngưỡng 25; thêm quan hệ ở lần chạy sau thì tách trang Entity theo cụm (bán vé, vận hành rạp).
