# Review P13 - Mô hình dữ liệu (CineBook)

Đối tượng: design/P13-data-model.md (1.0 nháp), design/P13-schema.sql, diagrams/P13-erd-logical.drawio (chỉ soát khớp bảng và khoá ngoại).
Đối chiếu: P13-data-modeling.md (Target 1 đến 15), P12 F1 và F6 (ST-01 đến ST-05), P08 F4b (EX-01 đến EX-15, chín hạng, X-01 đến X-22), P09 F7.3 đến F7.7, _BR-register.md.
Môi trường chạy thật: PostgreSQL 16 trong container tạm (image postgres:16), cơ sở dữ liệu mới, mức cô lập mặc định READ COMMITTED. Docker daemon chưa chạy lúc bắt đầu nên đã khởi động colima; đã dừng container và colima sau khi xong. File P13-schema.sql không bị sửa.

## 1. Kết quả chạy DDL

Áp toàn bộ P13-schema.sql bằng psql với ON_ERROR_STOP=1: chạy hết, 0 lỗi, 0 cảnh báo. Tạo đủ extension btree_gist, 1 hàm showtime_busy_range, 21 bảng, 21 chỉ mục ngoài khoá, 2 hàm trigger và 7 trigger. Áp lại lần hai vào cơ sở dữ liệu trống khác cũng 0 lỗi.

Đối chiếu ERD: 21 bảng TBL-01 đến TBL-21 trong drawio trùng 21 bảng trong DDL; 24 id cạnh fk_ trong drawio trùng đúng 24 tên khoá ngoại trong DDL (chỉ khác thứ tự sắp xếp khi so sánh).

## 2. Kết quả các ca thử

Script: /private/tmp/claude-502/-Users-luytbq-projects-l-dat-ve-xem-phim/d18c8a36-de2f-4801-89d9-c764d1607214/scratchpad/p13-tests.sql. Mỗi ca ghi mã SQLSTATE mong đợi và thực tế. Lần chạy đầu có vài ca sai do script thử (mã tăng tự động bị tiêu hao bởi lệnh INSERT thất bại nên tham chiếu theo id sai; hai khách cùng giữ ghế trong một kịch bản); đã sửa script sang tham chiếu theo mã tự nhiên và chạy lại trên cơ sở dữ liệu sạch. Kết quả cuối: 43 trên 43 ca đạt.

| Nhóm | Ca | Kết quả |
|---|---|---|
| T1 Hai lần giữ ACTIVE cùng người | khách thứ hai lần giữ ACTIVE khác suất chiếu --> 23505; nhân viên quầy tương tự --> 23505; trùng request_id --> 23505; vừa khách vừa nhân viên --> 23514; hết hạn không đúng 10 phút --> 23514; chuyển lần cũ sang EXPIRED rồi giữ mới --> được. 9 ca | Chặn đúng, 9/9 |
| T2 Hai vé chưa huỷ cùng ghế cùng suất | vé thứ hai --> 23505 (uq_ticket_active_seat); huỷ vé thứ nhất rồi bán lại --> được; vé cho ghế chưa có dòng seat_status --> 23503. 4 ca | Chặn đúng, 4/4 |
| T3 Chồng giờ cùng phòng (EXCLUDE) | chồng giờ --> 23P01; cách 14 phút --> 23P01; cách đúng 15 phút --> được (khớp BR-51 "bằng đúng 15 phút là hợp lệ"); suất mới kết thúc cách suất sau 14 phút --> 23P01; suất đã DELETED không tính; hai phòng khác nhau cùng giờ --> được. 6 ca | Chặn đúng, 6/6 |
| T4 Rời trạng thái cuối seat_hold, ticket | COMPLETED, EXPIRED, CANCELLED của seat_hold không đổi được; vé CANCELLED --> UNUSED hoặc USED, vé USED --> CANCELLED hoặc UNUSED đều --> 23514; UNUSED --> USED hợp lệ. 8 ca | Chặn đúng, 8/8 |
| T5 seat_status ghi đè current_hold_id | AVAILABLE --> HELD hợp lệ; ghi đè current_hold_id sang lần giữ khác --> 23514 (trg_seat_status_link); HELD trỏ lần giữ của suất khác --> 23503; HELD không có liên kết --> 23514; AVAILABLE --> SOLD trực tiếp --> 23514; trả ghế --> được. 6 ca | Chặn đúng, 6/6 |
| T6 Trùng mã giao dịch IPN | trùng code --> 23505; hai giao dịch TICKETED cùng lần giữ --> 23505; trùng gateway_transaction_no --> 23505; TICKETED --> PENDING --> 23514; hoàn vượt amount --> 23514. 6 ca | Chặn đúng, 6/6 |
| T7 Trùng idempotency_key của outbox | trùng khoá --> 23505; SUCCEEDED --> PENDING --> 23514; claim_token không có claimed_until --> 23514. 4 ca | Chặn đúng, 4/4 |
| Thăm dò thêm (X1 đến X5) | X2 refund_request NEW --> REFUNDED bị chặn; X4 xoá seat_status còn vé (đã huỷ) tham chiếu bị 23503; X1 ghế của phòng khác vẫn nhận vào seat_status, X3 seat_event cho suất chiếu không tồn tại vẫn nhận (chủ ý, F1), X5 showtime DELETED --> IN_SCHEDULE vẫn được | X2, X4 chặn đúng; X1, X3, X5 xác nhận khoảng trống (xem R13D-01 đến R13D-03) |

Kịch bản đồng thời hai phiên psql theo mẫu SQL EX-01 (SELECT ... FOR NO KEY UPDATE NOWAIT trên cùng ghế, giữ giao dịch bên A 3 giây):
- Bên A lấy khoá, INSERT seat_hold, UPDATE seat_status ... WHERE state = 'AVAILABLE', COMMIT: thành công.
- Bên B bắt đầu sau 1,2 giây: lỗi "could not obtain lock on row in relation seat_status" (55P03) ngay, ROLLBACK. Kết quả: seat_status ở HELD với đúng một lần giữ, số seat_hold tạo trong kịch bản là 1. Chỉ một phiên thành công.
- Bên C đến sau khi A đã commit: lấy khoá được, thấy HELD, UPDATE ... AND state = 'AVAILABLE' trả 0 dòng (đúng thiết kế "55P03 hoặc UPDATE 0 dòng").
- Khoá ngầm: trong lúc một giao dịch đang UPDATE seat_hold SET status, phiên khác lấy FOR KEY SHARE trên cùng dòng không bị chờ (xác nhận chỉ mục unique từng phần không nâng khoá thành FOR UPDATE; đúng giả định F4.5).

Chạy thử các câu mẫu của F4.5: EX-04 (quét hết hạn), EX-05 (quét giải phóng), claim outbox đều chạy được, không lỗi cú pháp. EXPLAIN (đã tắt seq scan để thấy chỉ mục có dùng được): EX-04 dùng ix_seat_hold_expiry; claim outbox dùng ix_outbox_due; phát lại seat_event dùng ix_seat_event_showtime_event; dọn seat_event dùng ix_seat_event_created_at; khoá ghế theo lần giữ dùng ix_seat_status_current_hold.

## 3. Soát nội dung

Ánh xạ EX-01 đến EX-15 (F4.5) so với P08 F4b và P09 F7.3: đúng bảng, đúng thứ tự chín hạng (price_list 1, auditorium 2, showtime 3, customer hoặc box_office_clerk 4, seat_hold 5, seat_status 6, payment_transaction 7, ticket 8, refund_request 9) cho cả 15 EX. Khác với P08 ở ba chỗ đều có căn cứ P09 nhưng F4.5 chưa nói rõ (xem R13D-04, R13D-05): EX-01 hạng 3 là S (P09 thu hẹp từ X), EX-05 hạng 5 là X trên đường quét thay vì S, EX-06 và EX-10 bỏ khoá S ticket vì đã nằm trong giao dịch huỷ vé gộp có khoá X ticket. Quy ước FOR NO KEY UPDATE, không lọc theo trạng thái nghiệp vụ trong câu khoá, NOWAIT chỉ ở EX-01: đúng P09.

Ràng buộc so với state machine P12: đồ thị trigger khớp ST-01 đến ST-05. ST-01 chỉ ACTIVE đi ra. ST-02 AVAILABLE --> HELD --> SOLD hoặc AVAILABLE, SOLD --> AVAILABLE. ST-03 UNUSED --> USED hoặc CANCELLED. ST-04 NEW --> IN_FLIGHT --> WAITING_RETRY, REFUNDED, MANUAL_REQUIRED; WAITING_RETRY --> IN_FLIGHT; IN_FLIGHT --> IN_FLIGHT khi nhận lại claim không đổi status nên trigger (WHEN status đổi) bỏ qua và CHECK attempt_count cho đi qua. Yêu cầu hoàn tiền mặt tạo thẳng ở REFUNDED nên không cần cung NEW --> REFUNDED (X2 xác nhận bị chặn, đúng). ST-05 PENDING --> FAILED, TICKETED, LATE_PAYMENT; FAILED --> LATE_PAYMENT. Hoàn tiền: CHECK ck_payment_transaction_refund_paid buộc LATE_PAYMENT đặt trước hoặc cùng câu với refunded_total, F4.4 đã nói.

Trigger và khoá: cả hai hàm trigger chỉ đọc OLD và NEW, không SELECT, không lấy khoá nào thêm, nên không thêm cung chờ ngoài thứ tự hạng. Khoá ngầm của FK ghép lên seat_hold và ticket là FOR KEY SHARE, không xung đột với FOR NO KEY UPDATE (đã chạy thử). Quét hết hạn dùng SKIP LOCKED nên không bao giờ chờ ở hạng 5; hai bộ quét hoặc quét với EX-13, EX-14 không tạo chu trình.

Chỉ mục: job hết hạn (ix_seat_hold_expiry), giải phóng (ix_seat_status_current_hold), seat_event (phát lại và dọn), outbox (ix_outbox_due) đều có chỉ mục dùng được, không thừa. Mọi chỉ mục khác có truy vấn phục vụ ở F6.3; các khoá ngoại không có chỉ mục đều có lý do ghi ở F6.3. Mức phức tạp: 7 trigger dùng chung một hàm tham số hoá, 1 EXCLUDE, vài chỉ mục unique từng phần: vừa tầm đồ án, mỗi thứ gắn với một BR hoặc EX.

## 4. Bảng phát hiện

Không có phát hiện mức Nghiêm trọng hoặc Cao. DDL chạy sạch và mọi ràng buộc then chốt chặn đúng.

| Mã | Vị trí | Vấn đề | Mức | Đề xuất | Trạng thái |
|---|---|---|---|---|---|
| R13D-01 | F4.4 C-19; fk_ticket_seat_status; EX-13 | Đổi phòng của suất chiếu cần thay seat_status (mã ghế khác theo phòng), nhưng fk_ticket_seat_status RESTRICT chặn xoá dòng seat_status còn vé tham chiếu, kể cả vé đã huỷ (thử X4: 23503). C-19 và BR-53 chỉ cấm sửa khi còn lần giữ ghế đang giữ hoặc vé chưa huỷ, nên suất chiếu từng có vé đã huỷ sửa được theo BR nhưng bị CSDL chặn khi đổi phòng | Trung bình | Ghi rõ hệ quả vào C-19 và đề nghị ở "Đề xuất sửa artifact trước" cho P04/P12: đổi phòng chỉ cho phép khi suất chiếu chưa từng có vé (kể cả đã huỷ), nếu không thì xoá suất cũ và lập suất mới (BR-58 vẫn giữ dữ liệu). Không đổi DDL | Đã sửa: C-19, EX-13 và Đề xuất sửa artifact trước (P04 UC-014, BR-53) ghi đổi phòng chỉ khi chưa từng có vé; DDL giữ nguyên vì fk_ticket_seat_status là lưới an toàn (X4 vẫn 23503, X6 xoá seat_status suất chiếu chưa từng có vé được) |
| R13D-02 | F4.4 (thiếu ràng buộc); seat_status | Không có ràng buộc nào bảo đảm ghế thuộc đúng phòng của suất chiếu (thử X1: seat_status nhận ghế của phòng khác). Không có dòng C-nn cho quy tắc này | Thấp | Thêm dòng C-22 "ghế của seat_status thuộc phòng của suất chiếu", cách giữ "Ứng dụng": EX-13 và EX-15 tạo seat_status bằng INSERT ... SELECT từ seat của phòng. Không thêm cột auditorium_id vào bảng lớn nhất hệ thống | Đã sửa: thêm C-22 (cách giữ: ứng dụng, INSERT ... SELECT từ seat của phòng) |
| R13D-03 | showtime.status; hàm fn_enforce_status_transition | Trigger chuyển trạng thái không phủ showtime: DELETED --> IN_SCHEDULE vẫn được (thử X5), trái BR-58 (xoá là ngừng bán, dữ liệu giữ lại). EXCLUDE chỉ chặn nếu khôi phục gây chồng giờ | Thấp | Thêm cung 'showtime:IN_SCHEDULE' --> DELETED vào hàm và trigger cho showtime khi P12 chốt state machine Showtime (Vấn đề còn mở 9 của P12); hiện ghi chú là khoảng trống đã biết | Đã sửa (ghi nhận): Vấn đề còn mở 9 và Đề xuất sửa P12; chưa thêm cung vào trigger vì state machine Showtime chưa chốt |
| R13D-04 | F4.5 EX-01, EX-05, EX-06, EX-10 | Khác P08 mà không giải thích trong F4.5: EX-01 hạng 3 là S (P08 ghi X), EX-05 hạng 5 là X (P08 ghi S), EX-06 và EX-10 không ghi khoá S ticket hạng 8. Mỗi chỗ đều có căn cứ P09 F7.3, F7.4 nhưng người đọc F4.5 độc lập sẽ thấy lệch | Thấp | Thêm một câu dưới bảng F4.5 liệt kê ba chỗ khác và tham chiếu P09 F7.3, F7.4; hoặc ghi chú ngay trong ô của từng EX | Đã sửa: thêm đoạn giải thích ba chỗ khác P08 dưới bảng F4.5 |
| R13D-05 | F4.5 EX-04, EX-05 | F4.5 đặt quy ước nhiều dòng cùng hạng phải ORDER BY khoá chính, nhưng quét EX-04 sắp theo expiry_time để dùng ix_seat_hold_expiry | Thấp | Ghi lý do ngoại lệ: SKIP LOCKED không chờ khoá nên thứ tự lấy khoá không tạo chu trình chờ (đã chạy thử, không deadlock); khi phát sinh thao tác tiếp theo ở hạng 6 thì dùng ORDER BY showtime_id, seat_id như đã ghi | Đã sửa: ghi ngoại lệ ORDER BY của EX-04 và lý do SKIP LOCKED trong quy ước F4.5 |
| R13D-06 | F6.3 outbox, seat_hold, seat_status; Q-138 | Không có chỉ mục hay mô tả công việc dọn dòng outbox đã SUCCEEDED hoặc EXHAUSTED; ix_outbox_due chỉ phủ PENDING nên bảng phình dần nhưng không ảnh hưởng truy vấn nóng. Phụ thuộc Q-138 | Thấp | Chốt theo Q-138; nếu chọn dọn outbox thì thêm chỉ mục từng phần theo created_at với điều kiện status khác PENDING và ghi job dọn vào F6.3 | Đã sửa theo Q-138: giữ toàn bộ, không dọn; ghi vào F6.3 và Vấn đề còn mở 4, không thêm chỉ mục |
| R13D-07 | F6.3 ix_seat_status_current_hold | Chỉ mục từng phần phủ mọi ghế HELD (có liên kết hiện tại), nên quét EX-05 mỗi phút duyệt toàn bộ ghế đang giữ, không chỉ ghế của lần giữ đã kết thúc. Tập này nhỏ (tối đa vài nghìn dòng ở giờ cao điểm) nên chấp nhận được | Thấp | Giữ nguyên; ghi nhận trong F6.3 là chi phí biết trước, chỉ xem lại nếu kiểm thử tải (P09 F7.9) cho thấy quét chậm | Đã sửa: ghi chi phí biết trước vào F6.3 |

## 5. Câu hỏi Q-136 đến Q-138

| Mã | Câu hỏi ngắn | Đề xuất và lý do | Cần hỏi người dùng? | Trạng thái |
|---|---|---|---|---|
| Q-136 | Tài khoản nhân viên (UC-017) có thuộc tính nào, lưu ba bảng hay một bảng có cột vai trò; nghỉ việc thì xoá hay khoá? | Giữ ba bảng như P08/P12 (đã có FK từ seat_hold tới box_office_clerk, BR-79 mỗi nhân viên đúng một vai trò nên không cần bảng chung). Mỗi bảng thêm đúng bốn cột: email duy nhất, password_hash, full_name, active. Nghỉ việc thì đặt active = false, không xoá, vì lần giữ ghế và vé cũ vẫn trỏ tới nhân viên (ON DELETE RESTRICT). Lý do: ít cột nhất đủ cho đăng nhập và khoá tài khoản, không đổi mã TBL | Không | Đã trả lời theo đề xuất |
| Q-137 | UC-010, UC-011, UC-012 thêm thuộc tính nào cho phim, cụm rạp, phòng chiếu, sơ đồ ghế? | Thêm cột thường gặp, tất cả có thể NULL hoặc có mặc định để không ảnh hưởng lõi giữ ghế: movie (genre, age_rating, description), cinema (address), seat_map: không thêm ghế vật lý không dùng, lối đi biểu diễn bằng khoảng trống số ghế. Sức chứa đếm từ bảng seat, không lưu cột riêng (tránh dữ liệu dẫn xuất lệch). Lý do: các UC này ngoài trọng tâm race condition của đồ án, chọn phương án đơn giản nhất chịu được thay đổi sau | Không | Đã trả lời theo đề xuất |
| Q-138 | Dữ liệu lịch sử của suất chiếu đã chiếu lưu bao lâu? | Đồ án: giữ toàn bộ, không phân vùng, không dọn seat_status (khoảng 73 triệu dòng mỗi năm chỉ là số lý thuyết ở tải tối đa, vượt xa dữ liệu thử). Ghi vào báo cáo hướng mở rộng: sản phẩm thật lưu trữ seat_status, seat_hold của suất chiếu cũ hơn 90 ngày sang bảng lưu trữ, giữ ticket, payment_transaction, refund_request lâu hơn (theo yêu cầu kế toán), và dọn outbox đã xong sau 30 ngày. Phân vùng chỉ cần khi có số liệu thật; nó đổi khoá chính nên không làm sớm. Lý do: đủ cho phạm vi đồ án, tránh tăng độ phức tạp DDL | Không (nhóm tự chốt; chỉ hỏi nếu giảng viên yêu cầu thời hạn lưu cụ thể) | Đã trả lời theo đề xuất |

## 6. Kết luận

P13-schema.sql chạy sạch trên PostgreSQL 16 (0 lỗi) và khớp ERD (21 bảng, 24 khoá ngoại). Bảy nhóm ràng buộc then chốt chặn đúng 43 trên 43 ca thử, kể cả kịch bản hai phiên cùng giữ một ghế (chỉ một phiên thành công, phiên kia nhận 55P03). Ánh xạ EX-01 đến EX-15 đúng bảng và đúng thứ tự chín hạng; trigger khớp ST-01 đến ST-05 và không thêm khoá. Còn một phát hiện Trung bình (R13D-01, đổi phòng bị chặn bởi vé đã huỷ, cần chốt quy tắc ở P04/P12) và sáu phát hiện Thấp chủ yếu là bổ sung ghi chú. Đề xuất chấp nhận P13 sau khi xử lý R13D-01 đến R13D-04 trong tài liệu; ba câu Q-136 đến Q-138 nhóm tự chốt được, không cần hỏi người dùng.

## 7. Xử lý review và chạy lại (P13 1.1)

Cả bảy phát hiện R13D-01 đến R13D-07 đã xử lý, không bỏ qua phát hiện nào; R13D-03 chỉ ghi nhận vì state machine Showtime chưa chốt. Q-136 đến Q-138 chốt theo đề xuất: ba bảng nhân viên thêm email, password_hash, full_name, active; cinema thêm address; movie thêm genre, age_rating, description; giữ toàn bộ dữ liệu lịch sử. Không cấp Q mới. Sơ đồ ERD logic và khái niệm đã cập nhật theo bảng (TBL-08, TBL-11, TBL-12, TBL-13, TBL-16).

Chạy lại trên PostgreSQL 16 (container tạm p13check, colima đã khởi động rồi dừng sau khi xong): áp P13-schema.sql với ON_ERROR_STOP=1 vào cơ sở dữ liệu mới, 0 lỗi; 21 bảng, 124 cột, 51 CHECK, 24 khoá ngoại, 7 trigger khớp số liệu trong tài liệu. Bộ ca thử (p13-tests.sql) chạy trên cơ sở dữ liệu sạch: 59 trên 59 ca đạt, gồm 43 ca cũ, X1 đến X5, X6 (xoá seat_status của suất chiếu chưa từng có vé, đường đổi phòng, được) và U1 đến U10 cho cột mới (email trùng 23505, email hoa hoặc sai dạng 23514, thiếu full_name 23502, active mặc định TRUE, cột tuỳ chọn của movie và cinema, không xoá được nhân viên còn được seat_hold tham chiếu 23503). Kịch bản đồng thời hai phiên không chạy lại vì lược đồ lõi không đổi.
