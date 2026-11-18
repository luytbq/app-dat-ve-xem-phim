-- CineBook: bộ ca thử lược đồ P13-schema.sql (PostgreSQL 16, bản 2.0).
--
-- Cách chạy (CSDL trống, UTF-8, locale en_US.utf8):
--   docker run --rm -d --name p13check -e POSTGRES_PASSWORD=x postgres:16
--   docker exec -i p13check psql -U postgres -v ON_ERROR_STOP=1 -q -f - < design/P13-schema.sql
--   docker exec -i p13check psql -U postgres -v ON_ERROR_STOP=1 -qAt -f - < design/P13-schema-tests.sql
--
-- Phần A (file này): các ca một phiên, mỗi ca ghi mong đợi (mã SQLSTATE hoặc 00000 là thành công) và tự báo ĐẠT hoặc TRƯỢT.
-- Toàn bộ chạy trong một giao dịch và ROLLBACK ở cuối nên CSDL sạch cho phần B.
-- Phần B (cuối file, trong chú thích): các kịch bản hai phiên psql đồng thời.

\set ON_ERROR_STOP 1
\pset pager off
BEGIN;

CREATE TEMP TABLE t_result (n SERIAL, grp TEXT, name TEXT, expected TEXT, actual TEXT, ok BOOLEAN, msg TEXT);
CREATE TEMP TABLE t_group (grp TEXT);
INSERT INTO t_group VALUES ('A');

CREATE FUNCTION pg_temp.grp(p TEXT) RETURNS void LANGUAGE sql AS $f$ UPDATE t_group SET grp = p $f$;

-- Chạy một câu lệnh trong khối con; actual là SQLSTATE bắt được hoặc 00000 nếu câu lệnh chạy xong.
CREATE FUNCTION pg_temp.expect(p_name TEXT, p_expected TEXT, p_stmt TEXT) RETURNS void LANGUAGE plpgsql AS $f$
DECLARE got TEXT := '00000'; m TEXT := '';
BEGIN
  BEGIN
    EXECUTE p_stmt;
  EXCEPTION WHEN OTHERS THEN
    got := SQLSTATE; m := SQLERRM;
  END;
  INSERT INTO t_result (grp, name, expected, actual, ok, msg) SELECT g.grp, p_name, p_expected, got, got = p_expected, m FROM t_group g;
END
$f$;

-- Kiểm một truy vấn trả một giá trị boolean (mong đợi true).
CREATE FUNCTION pg_temp.expect_true(p_name TEXT, p_query TEXT) RETURNS void LANGUAGE plpgsql AS $f$
DECLARE got BOOLEAN; err TEXT := 'true';
BEGIN
  BEGIN
    EXECUTE p_query INTO got;
  EXCEPTION WHEN OTHERS THEN
    got := FALSE; err := SQLSTATE;
  END;
  INSERT INTO t_result (grp, name, expected, actual, ok) SELECT g.grp, p_name, 'true', COALESCE(got::text, 'null') || CASE WHEN err = 'true' THEN '' ELSE ' (' || err || ')' END, COALESCE(got, FALSE) FROM t_group g;
END
$f$;

--------------------------------------------------------------------------------
-- Dữ liệu nền (mã cố định; sau đó đặt sequence cao để INSERT không chỉ định mã không đụng)
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Dựng dữ liệu nền', '00000', $q$
DO $d$
BEGIN
  INSERT INTO cinema (id, name, province, address, last_changed_at) VALUES
    (1, 'CineBook Bà Triệu', 'Hà Nội', '191 Bà Triệu', '2030-01-01 00:00:00+07'),
    (2, 'CineBook Quận 1', 'TP. Hồ Chí Minh', NULL, '2030-01-01 00:00:00+07');
  INSERT INTO price_list (cinema_id) VALUES (1), (2);
  INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, trailer, last_changed_at) VALUES
    (1, 'Mai', 120, '2029-12-15', '2030-12-31', 'Tâm lý', 'T18', 'https://video.example/mai', '2030-01-01 00:00:00+07'),
    (2, 'Mai', 100, '2029-12-15', '2030-12-31', 'Hài', 'P', NULL, '2030-01-01 00:00:00+07');
  INSERT INTO movie_format VALUES (1, '2D'), (1, '3D'), (2, '2D');
  INSERT INTO auditorium (id, cinema_id, name, auditorium_type, last_changed_at) VALUES
    (1, 1, 'Phòng 01', 'STANDARD', '2030-01-01 00:00:00+07'),
    (2, 1, 'Phòng 02', 'IMAX', '2030-01-01 00:00:00+07'),
    (3, 2, 'Phòng 01', 'STANDARD', '2030-01-01 00:00:00+07');
  INSERT INTO auditorium_format VALUES (1, '2D'), (1, '3D'), (2, '2D'), (3, '2D');
  INSERT INTO seat (id, auditorium_id, row_code, seat_number, seat_type) VALUES
    (1, 1, 'A', 1, 'STANDARD'), (2, 1, 'A', 2, 'STANDARD'), (3, 1, 'A', 3, 'VIP'),
    (4, 1, 'B', 1, 'STANDARD'), (5, 1, 'B', 2, 'COUPLE'), (6, 1, 'B', 3, 'STANDARD'),
    (11, 3, 'A', 1, 'STANDARD');
  INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES
    (1, 1, 1, '2030-01-01 10:00+07', '2029-12-31 10:00+07', '2030-01-01 12:00+07', '2029-12-30 00:00+07', '2D'),
    (2, 1, 1, '2030-01-01 14:00+07', '2029-12-31 10:00+07', '2030-01-01 16:00+07', '2029-12-30 00:00+07', '2D'),
    (3, 3, 1, '2030-01-01 10:00+07', '2029-12-31 10:00+07', '2030-01-01 12:00+07', '2029-12-30 00:00+07', '2D');
  INSERT INTO seat_status (showtime_id, seat_id) SELECT s.id, t.id FROM showtime s JOIN seat t ON t.auditorium_id = (SELECT auditorium_id FROM showtime WHERE id = s.id);
  INSERT INTO customer (id, email, phone_number, password_hash) VALUES
    (1, 'khach1@example.com', '0901000001', 'h'),
    (2, 'khach2@example.com', '0901000002', 'h'),
    (3, 'khach3@example.com', '0901000003', 'h');
  INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES
    (1, 'quay1@cinebook.vn', 'Nhân viên quầy 1', 'h', 'BOX_OFFICE_CLERK', 1, '2030-01-01 00:00:00+07', '2030-01-01 00:00:00+07'),
    (2, 'quay2@cinebook.vn', 'Nhân viên quầy 2', 'h', 'BOX_OFFICE_CLERK', 1, '2030-01-01 00:00:00+07', '2030-01-01 00:00:00+07'),
    (3, 'soat1@cinebook.vn', 'Nhân viên soát vé', 'h', 'TICKET_CHECKER', 1, '2030-01-01 00:00:00+07', '2030-01-01 00:00:00+07'),
    (4, 'quanly1@cinebook.vn', 'Quản lý cụm rạp', 'h', 'CINEMA_MANAGER', 1, '2030-01-01 00:00:00+07', '2030-01-01 00:00:00+07'),
    (5, 'chuoi@cinebook.vn', 'Quản lý chuỗi', 'h', 'CHAIN_MANAGER', NULL, '2030-01-01 00:00:00+07', '2030-01-01 00:00:00+07');
  INSERT INTO administrator (email, password_hash) VALUES ('admin@cinebook.vn', 'h');
  PERFORM setval(pg_get_serial_sequence(t, 'id'), 1000) FROM unnest(ARRAY['cinema','movie','auditorium','seat','showtime','customer','staff','seat_hold','payment_transaction','booking','ticket','refund_request','seat_event','outbox']) AS t;
END
$d$
$q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('B: hàm chuẩn hoá và danh mục');
--------------------------------------------------------------------------------
SELECT pg_temp.expect_true('norm_name gộp khoảng trắng, bỏ khoảng trắng đầu cuối, hạ chữ có dấu', $q$ SELECT norm_name('  CỤM   Á ') = 'cụm á' $q$);
SELECT pg_temp.expect_true('norm_name coi tab và xuống dòng là khoảng trắng', $q$ SELECT norm_name(E'Phòng\t\n 01') = 'phòng 01' $q$);
SELECT pg_temp.expect_true('norm_email hạ chữ có dấu và bỏ khoảng trắng đầu cuối', $q$ SELECT norm_email('  ĐẠT@Example.COM ') = 'đạt@example.com' $q$);
SELECT pg_temp.expect_true('norm_email, norm_name khai báo IMMUTABLE', $q$ SELECT count(*) = 2 FROM pg_proc WHERE proname IN ('norm_email', 'norm_name') AND provolatile = 'i' $q$);
SELECT pg_temp.expect_true('Khoá tư vấn giá trị: hai cách viết cùng tên cho cùng khoá, tên khác cho khoá khác', $q$ SELECT hashtext(norm_name('Cụm Á')) = hashtext(norm_name(' CỤM  á ')) AND hashtext(norm_name('Cụm Á')) <> hashtext(norm_name('Cụm B')) $q$);
SELECT pg_temp.expect_true('CSDL dùng UTF-8', $q$ SELECT pg_encoding_to_char(encoding) = 'UTF8' FROM pg_database WHERE datname = current_database() $q$);
SELECT pg_temp.expect_true('Lược đồ có 20 bảng', $q$ SELECT count(*) = 20 FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' $q$);
SELECT pg_temp.expect_true('showtime không có cột sức chứa', $q$ SELECT count(*) = 0 FROM information_schema.columns WHERE table_name = 'showtime' AND (column_name ILIKE '%capacity%' OR column_name ILIKE '%seat_count%') $q$);
SELECT pg_temp.expect_true('Không còn ba bảng nhân viên theo vai trò', $q$ SELECT count(*) = 0 FROM information_schema.tables WHERE table_name IN ('box_office_clerk', 'ticket_checker', 'cinema_manager') $q$);
SELECT pg_temp.expect_true('Có đủ chỉ mục unique theo biểu thức và từng phần', $q$ SELECT count(*) = 13 FROM pg_indexes WHERE indexname IN ('uq_cinema_name_norm','uq_auditorium_cinema_name_norm','uq_customer_email_norm','uq_staff_email_norm','uq_seat_position','uq_seat_hold_active_customer','uq_seat_hold_active_clerk','uq_ticket_active_seat','uq_payment_transaction_ticketed_hold','uq_payment_transaction_gateway_no','uq_refund_request_full_per_payment','uq_seat_status_current_ticket','ix_booking_customer_booked') $q$);
SELECT pg_temp.expect_true('uq_seat_position là chỉ mục từng phần WHERE in_seat_map', $q$ SELECT indexdef LIKE '%WHERE in_seat_map%' FROM pg_indexes WHERE indexname = 'uq_seat_position' $q$);
SELECT pg_temp.expect_true('Có đủ 14 trigger do người dùng định nghĩa (11 thường và 1 hoãn, cộng trg_booking_customer và trg_seat_hold_clerk_role)', $q$ SELECT count(*) = 14 FROM pg_trigger WHERE NOT tgisinternal $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('C: tên cụm rạp, tên phòng, ghế');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Tên cụm rạp trùng sau chuẩn hoá (hoa thường, dấu, khoảng trắng) bị chặn', '23505', $q$ INSERT INTO cinema (id, name, province, last_changed_at) VALUES (50, '  CINEBOOK   BÀ  TRIỆU ', 'Hà Nội', now()) $q$);
SELECT pg_temp.expect('Tên cụm rạp khác dấu là tên khác', '00000', $q$ INSERT INTO cinema (id, name, province, last_changed_at) VALUES (51, 'CineBook Ba Trieu', 'Hà Nội', now()); INSERT INTO price_list VALUES (51) $q$);
SELECT pg_temp.expect('Tên cụm rạp chỉ có khoảng trắng bị chặn', '23514', $q$ INSERT INTO cinema (id, name, province, last_changed_at) VALUES (52, '   ', 'Hà Nội', now()) $q$);
SELECT pg_temp.expect('Tỉnh, thành phố trống bị chặn', '23514', $q$ INSERT INTO cinema (id, name, province, last_changed_at) VALUES (53, 'Cụm mới', ' ', now()) $q$);
SELECT pg_temp.expect('Tên cụm rạp NULL bị chặn', '23502', $q$ INSERT INTO cinema (id, name, province, last_changed_at) VALUES (54, NULL, 'Hà Nội', now()) $q$);
SELECT pg_temp.expect('Mốc thay đổi cụm rạp NULL bị chặn', '23502', $q$ INSERT INTO cinema (id, name, province, last_changed_at) VALUES (55, 'Cụm mốc', 'Hà Nội', NULL) $q$);
SELECT pg_temp.expect('Đổi tên cụm rạp thành tên của cụm khác (khác hoa thường) bị chặn', '23505', $q$ UPDATE cinema SET name = 'CINEBOOK QUẬN 1' WHERE id = 1 $q$);
SELECT pg_temp.expect('Đổi tên cụm rạp thành chính tên cũ viết khác hoa thường được phép', '00000', $q$ UPDATE cinema SET name = 'CINEBOOK BÀ TRIỆU' WHERE id = 1 $q$);
SELECT pg_temp.expect('Tên phòng trùng trong cùng cụm rạp sau chuẩn hoá bị chặn', '23505', $q$ INSERT INTO auditorium (id, cinema_id, name, auditorium_type, last_changed_at) VALUES (50, 1, 'PHÒNG   01 ', 'STANDARD', now()) $q$);
SELECT pg_temp.expect('Cùng tên phòng ở cụm rạp khác được phép', '00000', $q$ INSERT INTO auditorium (id, cinema_id, name, auditorium_type, last_changed_at) VALUES (51, 2, 'Phòng 02', 'STANDARD', now()) $q$);
SELECT pg_temp.expect('Tên phòng có dấu trùng khác hoa thường bị chặn', '23505', $q$ INSERT INTO auditorium (id, cinema_id, name, auditorium_type, last_changed_at) VALUES (52, 2, 'PHÒNG 02', 'IMAX', now()); $q$);
SELECT pg_temp.expect('Loại phòng sai bị chặn', '23514', $q$ INSERT INTO auditorium (id, cinema_id, name, auditorium_type, last_changed_at) VALUES (53, 2, 'Phòng 9', 'VIP', now()) $q$);
SELECT pg_temp.expect('Hai ghế cùng vị trí cùng trong sơ đồ bị chặn', '23505', $q$ INSERT INTO seat (id, auditorium_id, row_code, seat_number, seat_type) VALUES (50, 1, 'A', 1, 'VIP') $q$);
SELECT pg_temp.expect('Bỏ ghế khỏi sơ đồ (in_seat_map đúng sang sai) được phép', '00000', $q$ UPDATE seat SET in_seat_map = FALSE WHERE id = 6 $q$);
SELECT pg_temp.expect('Vị trí của ghế đã bỏ nhập lại thành ghế mới được phép', '00000', $q$ INSERT INTO seat (id, auditorium_id, row_code, seat_number, seat_type) VALUES (51, 1, 'B', 3, 'VIP') $q$);
SELECT pg_temp.expect('Đưa ghế đã bỏ trở lại sơ đồ bị chặn (ST-07)', '23514', $q$ UPDATE seat SET in_seat_map = TRUE WHERE id = 6 $q$);
SELECT pg_temp.expect_true('seat.in_seat_map mặc định đúng', $q$ SELECT in_seat_map FROM seat WHERE id = 1 $q$);
SELECT pg_temp.expect('Loại ghế sai bị chặn', '23514', $q$ INSERT INTO seat (id, auditorium_id, row_code, seat_number, seat_type) VALUES (52, 1, 'C', 1, 'LUXURY') $q$);
SELECT pg_temp.expect('Xoá cụm rạp còn phòng chiếu bị chặn (RESTRICT)', '23503', $q$ DELETE FROM cinema WHERE id = 2 $q$);
SELECT pg_temp.expect('Xoá phòng chiếu còn suất chiếu bị chặn (lưới an toàn EX-19, BR-147)', '23503', $q$ DELETE FROM auditorium WHERE id = 1 $q$);
SELECT pg_temp.expect('Xoá ghế đã có trạng thái ghế bị chặn', '23503', $q$ DELETE FROM seat WHERE id = 1 $q$);
SELECT pg_temp.expect('Xoá phim đã có suất chiếu bị chặn', '23503', $q$ DELETE FROM movie WHERE id = 1 $q$);
SELECT pg_temp.expect('EX-19: xoá phòng chưa từng có suất chiếu cùng ghế và định dạng được phép', '00000', $q$
DO $d$
BEGIN
  INSERT INTO auditorium (id, cinema_id, name, auditorium_type, last_changed_at) VALUES (60, 1, 'Phòng tạm', 'STANDARD', now());
  INSERT INTO auditorium_format VALUES (60, '2D');
  INSERT INTO seat (id, auditorium_id, row_code, seat_number, seat_type) VALUES (60, 60, 'A', 1, 'STANDARD'), (61, 60, 'A', 2, 'STANDARD');
  DELETE FROM seat WHERE auditorium_id = 60;
  DELETE FROM auditorium WHERE id = 60;
  IF EXISTS (SELECT 1 FROM auditorium_format WHERE auditorium_id = 60) THEN RAISE EXCEPTION 'định dạng còn'; END IF;
END
$d$ $q$);
SELECT pg_temp.expect('Cụm rạp thiếu bảng giá bị chặn lúc COMMIT (kiểm tại SET CONSTRAINTS)', '23514', $q$
DO $d$
BEGIN
  INSERT INTO cinema (id, name, province, last_changed_at) VALUES (70, 'Cụm không bảng giá', 'Đà Nẵng', now());
  SET CONSTRAINTS trg_cinema_has_price_list IMMEDIATE;
END
$d$ $q$);
SELECT pg_temp.expect('Cụm rạp và bảng giá cùng giao dịch, bảng giá chèn sau, được phép', '00000', $q$
DO $d$
BEGIN
  INSERT INTO cinema (id, name, province, last_changed_at) VALUES (71, 'Cụm có bảng giá', 'Đà Nẵng', now());
  INSERT INTO price_list (cinema_id) VALUES (71);
  SET CONSTRAINTS trg_cinema_has_price_list IMMEDIATE;
  SET CONSTRAINTS trg_cinema_has_price_list DEFERRED;
END
$d$ $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('D: phim, mục giá, định dạng');
--------------------------------------------------------------------------------
SELECT pg_temp.expect_true('Hai phim cùng tên được phép (Q-200)', $q$ SELECT count(*) = 2 FROM movie WHERE title = 'Mai' $q$);
SELECT pg_temp.expect('Thời lượng không dương bị chặn', '23514', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (50, 'X', 0, '2030-01-01', '2030-01-02', 'Hài', 'P', now()) $q$);
SELECT pg_temp.expect('Ngày kết thúc chiếu trước ngày khởi chiếu bị chặn', '23514', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (50, 'X', 90, '2030-01-02', '2030-01-01', 'Hài', 'P', now()) $q$);
SELECT pg_temp.expect('Hai ngày bằng nhau là hợp lệ', '00000', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (51, 'Một ngày', 90, '2030-01-02', '2030-01-02', 'Hài', 'K', now()) $q$);
SELECT pg_temp.expect('Nhãn độ tuổi ngoài tập P, K, T13, T16, T18, C bị chặn', '23514', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (52, 'X', 90, '2030-01-01', '2030-01-02', 'Hài', 'T21', now()) $q$);
SELECT pg_temp.expect('Tên phim trống bị chặn', '23514', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (53, '  ', 90, '2030-01-01', '2030-01-02', 'Hài', 'P', now()) $q$);
SELECT pg_temp.expect('Thể loại trống bị chặn', '23514', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (54, 'X', 90, '2030-01-01', '2030-01-02', '', 'P', now()) $q$);
SELECT pg_temp.expect('Trailer chỉ có khoảng trắng bị chặn, NULL được phép', '23514', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, trailer, last_changed_at) VALUES (55, 'X', 90, '2030-01-01', '2030-01-02', 'Hài', 'P', '  ', now()) $q$);
SELECT pg_temp.expect_true('Phim 2 có trailer NULL và mô tả mặc định rỗng', $q$ SELECT trailer IS NULL AND description = '' FROM movie WHERE id = 2 $q$);
SELECT pg_temp.expect('Mốc thay đổi phim NULL bị chặn', '23502', $q$ INSERT INTO movie (id, title, duration_minutes, release_date, end_of_run_date, genre, age_rating, last_changed_at) VALUES (56, 'X', 90, '2030-01-01', '2030-01-02', 'Hài', 'P', NULL) $q$);
SELECT pg_temp.expect('Định dạng phát hành sai bị chặn', '23514', $q$ INSERT INTO movie_format VALUES (2, '4D') $q$);
SELECT pg_temp.expect('Mục giá trùng khoá tổ hợp (BR-62) bị chặn', '23505', $q$
DO $d$
BEGIN
  INSERT INTO price_entry (cinema_id, auditorium_type, movie_format, seat_type, time_band, ticket_price, last_changed_at) VALUES (1, 'STANDARD', '2D', 'STANDARD', 'WEEKDAY_BEFORE_17', 80000, now());
  INSERT INTO price_entry (cinema_id, auditorium_type, movie_format, seat_type, time_band, ticket_price, last_changed_at) VALUES (1, 'STANDARD', '2D', 'STANDARD', 'WEEKDAY_BEFORE_17', 90000, now());
END
$d$ $q$);
SELECT pg_temp.expect('Giá vé không dương bị chặn', '23514', $q$ INSERT INTO price_entry (cinema_id, auditorium_type, movie_format, seat_type, time_band, ticket_price, last_changed_at) VALUES (1, 'IMAX', '2D', 'VIP', 'WEEKEND_FROM_17', 0, now()) $q$);
SELECT pg_temp.expect('Khung giờ sai bị chặn', '23514', $q$ INSERT INTO price_entry (cinema_id, auditorium_type, movie_format, seat_type, time_band, ticket_price, last_changed_at) VALUES (1, 'IMAX', '2D', 'VIP', 'NIGHT', 10, now()) $q$);
SELECT pg_temp.expect('Xoá bảng giá kéo theo xoá mục giá (composition CASCADE)', '00000', $q$
DO $d$
BEGIN
  INSERT INTO cinema (id, name, province, last_changed_at) VALUES (72, 'Cụm xoá bảng giá', 'Huế', now());
  INSERT INTO price_list (cinema_id) VALUES (72);
  INSERT INTO price_entry (cinema_id, auditorium_type, movie_format, seat_type, time_band, ticket_price, last_changed_at) VALUES (72, 'IMAX', '2D', 'VIP', 'WEEKEND_FROM_17', 150000, now());
  DELETE FROM price_list WHERE cinema_id = 72;
  IF EXISTS (SELECT 1 FROM price_entry WHERE cinema_id = 72) THEN RAISE EXCEPTION 'mục giá còn'; END IF;
END
$d$ $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('E: tài khoản khách, nhân viên, quản trị viên');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Email khách trùng khác hoa thường và khoảng trắng bị chặn', '23505', $q$ INSERT INTO customer (id, email, phone_number, password_hash) VALUES (50, '  KHACH1@Example.COM ', '0902000001', 'h') $q$);
SELECT pg_temp.expect('Email khách có dấu trùng khác hoa thường bị chặn', '23505', $q$
DO $d$
BEGIN
  INSERT INTO customer (id, email, phone_number, password_hash) VALUES (51, 'đạt@example.com', '0902000002', 'h');
  INSERT INTO customer (id, email, phone_number, password_hash) VALUES (52, 'ĐẠT@EXAMPLE.COM', '0902000003', 'h');
END
$d$ $q$);
SELECT pg_temp.expect('Số điện thoại khách trùng bị chặn', '23505', $q$ INSERT INTO customer (id, email, phone_number, password_hash) VALUES (53, 'khac@example.com', '0901000001', 'h') $q$);
SELECT pg_temp.expect('Số điện thoại có khoảng trắng (khác định dạng BR-82) bị chặn', '23514', $q$ INSERT INTO customer (id, email, phone_number, password_hash) VALUES (54, 'khac2@example.com', ' 901000009', 'h') $q$);
SELECT pg_temp.expect('Số điện thoại không bắt đầu bằng 0 bị chặn', '23514', $q$ INSERT INTO customer (id, email, phone_number, password_hash) VALUES (55, 'khac3@example.com', '1901000009', 'h') $q$);
SELECT pg_temp.expect('Email khách sai định dạng bị chặn', '23514', $q$ INSERT INTO customer (id, email, phone_number, password_hash) VALUES (56, 'khong-co-a-cong', '0902000009', 'h') $q$);
SELECT pg_temp.expect('Email khách và email nhân viên là hai tập khác nhau (Q-267)', '00000', $q$ INSERT INTO customer (id, email, phone_number, password_hash) VALUES (57, 'quay1@cinebook.vn', '0902000010', 'h') $q$);
SELECT pg_temp.expect('Email nhân viên trùng sau chuẩn hoá bị chặn', '23505', $q$ INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (50, ' QUAY1@CineBook.vn ', 'Trùng', 'h', 'BOX_OFFICE_CLERK', 1, now(), now()) $q$);
SELECT pg_temp.expect('Email nhân viên trùng xuyên vai trò (BR-95) bị chặn', '23505', $q$ INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (51, 'quanly1@cinebook.vn', 'Trùng vai trò', 'h', 'TICKET_CHECKER', 2, now(), now()) $q$);
SELECT pg_temp.expect('Email nhân viên có dấu trùng khác hoa thường bị chặn', '23505', $q$
DO $d$
BEGIN
  INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (52, 'Lê.Văn@cinebook.vn', 'Lê Văn', 'h', 'TICKET_CHECKER', 2, now(), now());
  INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (53, 'LÊ.VĂN@CINEBOOK.VN', 'Lê Văn 2', 'h', 'TICKET_CHECKER', 2, now(), now());
END
$d$ $q$);
SELECT pg_temp.expect('Quản lý chuỗi có cụm rạp bị chặn (BR-78)', '23514', $q$ INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (54, 'c2@cinebook.vn', 'Chuỗi 2', 'h', 'CHAIN_MANAGER', 1, now(), now()) $q$);
SELECT pg_temp.expect('Vai trò ba loại còn lại không có cụm rạp bị chặn (BR-78)', '23514', $q$ INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (55, 'q3@cinebook.vn', 'Quầy 3', 'h', 'BOX_OFFICE_CLERK', NULL, now(), now()) $q$);
SELECT pg_temp.expect('Vai trò ngoài bốn giá trị (BR-79) bị chặn', '23514', $q$ INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at) VALUES (56, 'q4@cinebook.vn', 'Q4', 'h', 'ADMINISTRATOR', NULL, now(), now()) $q$);
SELECT pg_temp.expect('Trạng thái tài khoản ngoài ACTIVE, LOCKED bị chặn', '23514', $q$ UPDATE staff SET status = 'DELETED' WHERE id = 1 $q$);
SELECT pg_temp.expect('Họ tên nhân viên trống bị chặn', '23514', $q$ UPDATE staff SET full_name = ' ' WHERE id = 1 $q$);
SELECT pg_temp.expect('Mốc truy cập NULL bị chặn', '23502', $q$ UPDATE staff SET access_changed_at = NULL WHERE id = 1 $q$);
SELECT pg_temp.expect('Email nhân viên không đổi sau khi tạo (Q-162)', '23514', $q$ UPDATE staff SET email = 'moi@cinebook.vn' WHERE id = 1 $q$);
SELECT pg_temp.expect('Khoá tài khoản (ACTIVE sang LOCKED) và mở khoá được phép đi lại', '00000', $q$
DO $d$
BEGIN
  UPDATE staff SET status = 'LOCKED', access_changed_at = '2030-01-02 00:00:00.123456+07', last_changed_at = '2030-01-02 00:00:00.123456+07' WHERE id = 2;
  UPDATE staff SET status = 'ACTIVE' WHERE id = 2;
  IF NOT EXISTS (SELECT 1 FROM staff WHERE id = 2 AND access_changed_at = '2030-01-02 00:00:00.123456+07') THEN RAISE EXCEPTION 'mốc micro giây mất'; END IF;
END
$d$ $q$);
SELECT pg_temp.expect('Đổi vai trò kèm đổi cụm rạp trên cùng một dòng được phép (BR-100)', '00000', $q$
DO $d$
BEGIN
  INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at)
    VALUES (62, 'quay62@cinebook.vn', 'Nhân viên quầy 62', 'h', 'BOX_OFFICE_CLERK', 1, now(), now());
  UPDATE staff SET role = 'CHAIN_MANAGER', cinema_id = NULL WHERE id = 62;
END
$d$ $q$);
SELECT pg_temp.expect('Xoá nhân viên đã giữ ghế bị chặn (RESTRICT)', '23503', $q$
DO $d$
BEGIN
  INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at)
    VALUES (60, 'quay60@cinebook.vn', 'Nhân viên quầy 60', 'h', 'BOX_OFFICE_CLERK', 1, now(), now());
  INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, hold_time, expiry_time)
    VALUES (90, 1, 60, 'ref-90', 'req-90', '2030-01-01 09:00+07', '2030-01-01 09:10+07');
  DELETE FROM staff WHERE id = 60;
END
$d$ $q$);
SELECT pg_temp.expect('Người giữ ghế là nhân viên soát vé bị chặn (BR-79)', '23514', $q$ INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (91, 1, 3, 'ref-91', 'req-91', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Người giữ ghế là quản lý cụm rạp bị chặn (BR-79)', '23514', $q$ INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (92, 1, 4, 'ref-92', 'req-92', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Người giữ ghế là nhân viên quầy được phép', '00000', $q$ INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (93, 1, 1, 'ref-93', 'req-93', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Đổi người giữ ghế của lần giữ ghế sang nhân viên không phải quầy bị chặn', '23514', $q$ UPDATE seat_hold SET box_office_clerk_id = 3 WHERE id = 93 $q$);
SELECT pg_temp.expect('Đổi vai trò của nhân viên quầy đã từng giữ ghế vẫn được phép, lịch sử giữ nguyên', '00000', $q$
DO $d$
BEGIN
  INSERT INTO staff (id, email, full_name, password_hash, role, cinema_id, last_changed_at, access_changed_at)
    VALUES (61, 'quay61@cinebook.vn', 'Nhân viên quầy 61', 'h', 'BOX_OFFICE_CLERK', 1, now(), now());
  INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, status, hold_time, expiry_time)
    VALUES (94, 1, 61, 'ref-94', 'req-94', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07');
  UPDATE staff SET role = 'TICKET_CHECKER' WHERE id = 61;
  IF NOT EXISTS (SELECT 1 FROM seat_hold WHERE id = 94 AND box_office_clerk_id = 61) THEN RAISE EXCEPTION 'lịch sử giữ ghế mất'; END IF;
END
$d$ $q$);
SELECT pg_temp.expect('Bảng administrator chỉ có một dòng: dòng thứ hai (id mặc định) bị chặn', '23505', $q$ INSERT INTO administrator (email, password_hash) VALUES ('admin2@cinebook.vn', 'h') $q$);
SELECT pg_temp.expect('Bảng administrator không nhận id khác 1', '23514', $q$ INSERT INTO administrator (id, email, password_hash) VALUES (2, 'admin2@cinebook.vn', 'h') $q$);
SELECT pg_temp.expect('Email quản trị viên sai định dạng bị chặn', '23514', $q$ UPDATE administrator SET email = 'khong-hop-le' $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('F: suất chiếu và EXCLUDE chồng giờ');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Suất chiếu chồng giờ cùng phòng bị chặn (EXCLUDE)', '23P01', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (50, 1, 1, '2030-01-01 11:00+07', '2029-12-31 10:00+07', '2030-01-01 13:00+07', now(), '2D') $q$);
SELECT pg_temp.expect('Cách suất trước 10 phút (dưới 15 phút dọn phòng, BR-51) bị chặn', '23P01', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (51, 1, 1, '2030-01-01 12:10+07', '2029-12-31 10:00+07', '2030-01-01 13:00+07', now(), '2D') $q$);
SELECT pg_temp.expect('Cách suất trước đúng 15 phút được phép', '00000', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (52, 1, 1, '2030-01-01 12:15+07', '2029-12-31 10:00+07', '2030-01-01 13:00+07', now(), '2D') $q$);
SELECT pg_temp.expect('Suất kết thúc 13:50 (trong 15 phút dọn phòng trước suất 2 lúc 14:00) bị chặn', '23P01', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (53, 1, 1, '2030-01-01 13:30+07', '2029-12-31 10:00+07', '2030-01-01 13:50+07', now(), '2D') $q$);
SELECT pg_temp.expect('Cùng khung giờ ở phòng khác được phép', '00000', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (54, 2, 1, '2030-01-01 10:00+07', '2029-12-31 10:00+07', '2030-01-01 12:00+07', now(), '2D') $q$);
SELECT pg_temp.expect('Suất đã xoá không còn tính chồng giờ', '00000', $q$
DO $d$
BEGIN
  UPDATE showtime SET status = 'DELETED' WHERE id = 52;
  INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (55, 1, 1, '2030-01-01 12:30+07', '2029-12-31 10:00+07', '2030-01-01 13:30+07', now(), '2D');
END
$d$ $q$);
SELECT pg_temp.expect('Khôi phục suất đã xoá (DELETED sang IN_SCHEDULE) bị chặn (ST-06)', '23514', $q$ UPDATE showtime SET status = 'IN_SCHEDULE' WHERE id = 52 $q$);
SELECT pg_temp.expect('Giờ mở bán không trước giờ bắt đầu bị chặn', '23514', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (56, 2, 1, '2030-02-01 10:00+07', '2030-02-01 10:00+07', '2030-02-01 12:00+07', now(), '2D') $q$);
SELECT pg_temp.expect('Giờ kết thúc không sau giờ bắt đầu bị chặn', '23514', $q$ INSERT INTO showtime (id, auditorium_id, movie_id, start_time, sale_open_time, end_time, last_changed_at, movie_format) VALUES (57, 2, 1, '2030-02-01 10:00+07', '2030-01-31 10:00+07', '2030-02-01 10:00+07', now(), '2D') $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('G: lần giữ ghế và trạng thái ghế');

--------------------------------------------------------------------------------
SELECT pg_temp.expect('Dựng lần giữ ghế 1 (khách 1), 2 (khách 2), 3 (khách 3), 5 (nhân viên quầy 1)', '00000', $q$
DO $d$
BEGIN
  INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, hold_time, expiry_time) VALUES
    (1, 1, 1, 'ref-1', 'req-1', '2030-01-01 09:00+07', '2030-01-01 09:10+07'),
    (2, 1, 2, 'ref-2', 'req-2', '2030-01-01 09:00+07', '2030-01-01 09:10+07'),
    (3, 2, 3, 'ref-3', 'req-3', '2030-01-01 09:00+07', '2030-01-01 09:10+07');
  INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, hold_time, expiry_time) VALUES
    (5, 2, 1, 'ref-5', 'req-5', '2030-01-01 09:00+07', '2030-01-01 09:10+07');
  UPDATE seat_status SET state = 'HELD', current_hold_id = 1, held_price = 90000 WHERE showtime_id = 1 AND seat_id = 1;
  UPDATE seat_status SET state = 'HELD', current_hold_id = 3, held_price = 100000 WHERE showtime_id = 2 AND seat_id = 1;
  UPDATE seat_status SET state = 'HELD', current_hold_id = 3, held_price = 120000 WHERE showtime_id = 2 AND seat_id = 2;
END
$d$ $q$);
SELECT pg_temp.expect('BR-04: khách có hai lần giữ ghế đang giữ ở hai suất chiếu bị chặn', '23505', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, hold_time, expiry_time) VALUES (6, 2, 1, 'ref-6', 'req-6', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('BR-04: nhân viên quầy có hai lần giữ ghế đang giữ bị chặn', '23505', $q$ INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, hold_time, expiry_time) VALUES (6, 1, 1, 'ref-6', 'req-6', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Hai nhân viên quầy khác nhau mỗi người một lần giữ ghế được phép', '00000', $q$ INSERT INTO seat_hold (id, showtime_id, box_office_clerk_id, hold_ref, request_id, hold_time, expiry_time) VALUES (7, 1, 2, 'ref-7', 'req-7', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Lần giữ ghế không có người giữ bị chặn', '23514', $q$ INSERT INTO seat_hold (id, showtime_id, hold_ref, request_id, hold_time, expiry_time) VALUES (8, 1, 'ref-8', 'req-8', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Lần giữ ghế có cả khách và nhân viên bị chặn', '23514', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, box_office_clerk_id, hold_ref, request_id, hold_time, expiry_time) VALUES (8, 1, 2, 2, 'ref-8', 'req-8', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Mã yêu cầu trùng (xác nhận lặp) bị chặn', '23505', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (8, 1, 1, 'ref-8', 'req-1', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Mã tham chiếu lần giữ ghế trùng bị chặn', '23505', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (8, 1, 1, 'ref-1', 'req-8', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Hạn giữ ghế khác đúng 10 phút (BR-10) bị chặn', '23514', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (8, 1, 1, 'ref-8', 'req-8', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:11+07') $q$);
SELECT pg_temp.expect('Trạng thái lần giữ ghế ngoài tập bị chặn', '23514', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (8, 1, 1, 'ref-8', 'req-8', 'DONE', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Lần giữ ghế của suất chiếu không tồn tại bị chặn', '23503', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (8, 999, 1, 'ref-8', 'req-8', 'EXPIRED', '2030-01-01 09:00+07', '2030-01-01 09:10+07') $q$);
SELECT pg_temp.expect('Rời trạng thái cuối: EXPIRED sang ACTIVE bị chặn', '23514', $q$
DO $d$
BEGIN
  INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (9, 2, 1, 'ref-9', 'req-9', 'EXPIRED', '2030-01-01 08:00+07', '2030-01-01 08:10+07');
  UPDATE seat_hold SET status = 'ACTIVE' WHERE id = 9;
END
$d$ $q$);
SELECT pg_temp.expect('Rời trạng thái cuối: COMPLETED sang CANCELLED bị chặn', '23514', $q$
DO $d$
BEGIN
  INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (10, 2, 1, 'ref-10', 'req-10', 'COMPLETED', '2030-01-01 08:00+07', '2030-01-01 08:10+07');
  UPDATE seat_hold SET status = 'CANCELLED' WHERE id = 10;
END
$d$ $q$);
SELECT pg_temp.expect('EX-04: ACTIVE sang EXPIRED được phép', '00000', $q$ UPDATE seat_hold SET status = 'EXPIRED' WHERE id = 1 AND status = 'ACTIVE' $q$);
SELECT pg_temp.expect('EX-04 chạy lặp: UPDATE có điều kiện trạng thái trả 0 dòng, không lỗi', '00000', $q$ UPDATE seat_hold SET status = 'EXPIRED' WHERE id = 1 AND status = 'ACTIVE' $q$);
SELECT pg_temp.expect('EX-05: trả ghế của lần giữ ghế đã hết hạn về Trống', '00000', $q$
DO $d$
DECLARE n INT;
BEGIN
  UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL, event_seq = 1 WHERE showtime_id = 1 AND current_hold_id = 1;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 1 THEN RAISE EXCEPTION 'số ghế trả %', n; END IF;
  UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL, event_seq = 2 WHERE showtime_id = 1 AND current_hold_id = 1;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n <> 0 THEN RAISE EXCEPTION 'chạy lặp phải 0 dòng, được %', n; END IF;
END
$d$ $q$);
SELECT pg_temp.expect('Khách 1 có lần giữ ghế mới sau khi lần cũ đã kết thúc được phép', '00000', $q$ INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, hold_time, expiry_time) VALUES (11, 1, 1, 'ref-11', 'req-11', '2030-01-01 09:20+07', '2030-01-01 09:30+07') $q$);
-- trg_seat_status_link và đường hai lượt
SELECT pg_temp.expect('Ghế Trống sang Đang được giữ bởi lần giữ ghế 11 được phép', '00000', $q$ UPDATE seat_status SET state = 'HELD', current_hold_id = 11, held_price = 90000 WHERE showtime_id = 1 AND seat_id = 1 $q$);
SELECT pg_temp.expect('trg_seat_status_link: đổi thẳng liên kết lần giữ ghế 11 sang 2 bị chặn', '23514', $q$ UPDATE seat_status SET current_hold_id = 2 WHERE showtime_id = 1 AND seat_id = 1 $q$);
SELECT pg_temp.expect('Đường hai lượt, lượt 1: trả ghế về Trống', '00000', $q$ UPDATE seat_status SET state = 'AVAILABLE', current_hold_id = NULL, held_price = NULL WHERE showtime_id = 1 AND seat_id = 1 $q$);
SELECT pg_temp.expect('Đường hai lượt, lượt 2: gán lần giữ ghế mới', '00000', $q$ UPDATE seat_status SET state = 'HELD', current_hold_id = 2, held_price = 95000 WHERE showtime_id = 1 AND seat_id = 1 $q$);
SELECT pg_temp.expect_true('Sau đường hai lượt ghế thuộc lần giữ ghế 2', $q$ SELECT current_hold_id = 2 AND state = 'HELD' FROM seat_status WHERE showtime_id = 1 AND seat_id = 1 $q$);
SELECT pg_temp.expect('Gán lần giữ ghế của suất chiếu khác cho ghế (FK ghép) bị chặn', '23503', $q$ UPDATE seat_status SET state = 'HELD', current_hold_id = 3, held_price = 1000 WHERE showtime_id = 1 AND seat_id = 2 $q$);
SELECT pg_temp.expect('ck_seat_status_state_link: HELD không có lần giữ ghế bị chặn', '23514', $q$ UPDATE seat_status SET state = 'HELD', held_price = 1000 WHERE showtime_id = 1 AND seat_id = 3 $q$);
SELECT pg_temp.expect('ck_seat_status_state_link: Trống mà có giá bị chặn', '23514', $q$ UPDATE seat_status SET held_price = 1000 WHERE showtime_id = 1 AND seat_id = 3 $q$);
SELECT pg_temp.expect('ck_seat_status_state_link: có cả lần giữ ghế lẫn vé bị chặn', '23514', $q$ UPDATE seat_status SET state = 'HELD', current_hold_id = 2, current_ticket_id = 1, held_price = 1000 WHERE showtime_id = 1 AND seat_id = 3 $q$);
SELECT pg_temp.expect('Trống sang Đã bán trực tiếp (bỏ qua Đang được giữ) bị chặn', '23514', $q$ UPDATE seat_status SET state = 'SOLD' WHERE showtime_id = 1 AND seat_id = 3 $q$);
SELECT pg_temp.expect('Giá chốt không dương bị chặn', '23514', $q$ UPDATE seat_status SET state = 'HELD', current_hold_id = 2, held_price = 0 WHERE showtime_id = 1 AND seat_id = 3 $q$);
SELECT pg_temp.expect('event_seq âm bị chặn', '23514', $q$ UPDATE seat_status SET event_seq = -1 WHERE showtime_id = 1 AND seat_id = 3 $q$);
SELECT pg_temp.expect('Ghế không thuộc phòng khác: seat_status của ghế không tồn tại bị chặn', '23503', $q$ INSERT INTO seat_status (showtime_id, seat_id) VALUES (3, 999) $q$);
SELECT pg_temp.expect('Hai dòng seat_status cùng (suất chiếu, ghế) bị chặn', '23505', $q$ INSERT INTO seat_status (showtime_id, seat_id) VALUES (1, 1) $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('H: thanh toán, đặt vé, vé (IPN idempotent)');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Giao dịch thanh toán chờ cho lần giữ ghế 3', '00000', $q$ INSERT INTO payment_transaction (id, seat_hold_id, code, amount) VALUES (1, 3, '20300101090000000001', 220000) $q$);
SELECT pg_temp.expect('Mã giao dịch trùng (IPN gửi lại) bị chặn', '23505', $q$ INSERT INTO payment_transaction (id, seat_hold_id, code, amount) VALUES (2, 3, '20300101090000000001', 220000) $q$);
SELECT pg_temp.expect('Lần bấm thanh toán thứ hai của cùng lần giữ ghế là giao dịch mới (BR-90)', '00000', $q$ INSERT INTO payment_transaction (id, seat_hold_id, code, amount) VALUES (2, 3, '20300101090000000002', 220000) $q$);
SELECT pg_temp.expect('Số tiền không dương bị chặn', '23514', $q$ INSERT INTO payment_transaction (id, seat_hold_id, code, amount) VALUES (3, 3, '20300101090000000003', 0) $q$);
SELECT pg_temp.expect('TICKETED thiếu mã cổng hoặc thời điểm thanh toán bị chặn', '23514', $q$ UPDATE payment_transaction SET status = 'TICKETED' WHERE id = 1 $q$);
SELECT pg_temp.expect('EX-02: giao dịch 1 PENDING sang TICKETED', '00000', $q$ UPDATE payment_transaction SET status = 'TICKETED', gateway_transaction_no = 'GW0001', paid_at = '2030-01-01 09:05+07' WHERE id = 1 $q$);
SELECT pg_temp.expect('IPN gửi trùng qua bản backend khác: giao dịch thứ hai cũng TICKETED cho cùng lần giữ ghế bị chặn', '23505', $q$ UPDATE payment_transaction SET status = 'TICKETED', gateway_transaction_no = 'GW0002', paid_at = '2030-01-01 09:06+07' WHERE id = 2 $q$);
SELECT pg_temp.expect('Hai giao dịch cùng mã giao dịch của cổng bị chặn', '23505', $q$ UPDATE payment_transaction SET status = 'FAILED', gateway_transaction_no = 'GW0001' WHERE id = 2 $q$);
SELECT pg_temp.expect('FAILED không ghi mã cổng nên báo thất bại lặp không vi phạm unique', '00000', $q$ INSERT INTO payment_transaction (id, seat_hold_id, code, amount, status) VALUES (4, 3, '20300101090000000004', 1000, 'FAILED'), (5, 3, '20300101090000000005', 1000, 'FAILED') $q$);
SELECT pg_temp.expect('Rời trạng thái cuối: TICKETED sang FAILED bị chặn', '23514', $q$ UPDATE payment_transaction SET status = 'FAILED' WHERE id = 1 $q$);
SELECT pg_temp.expect('FAILED sang LATE_PAYMENT (thanh toán trễ) thiếu lý do bị chặn', '23514', $q$ UPDATE payment_transaction SET status = 'LATE_PAYMENT', gateway_transaction_no = 'GW0004', paid_at = now() WHERE id = 4 $q$);
SELECT pg_temp.expect('FAILED sang LATE_PAYMENT đủ lý do, mã cổng, thời điểm được phép', '00000', $q$ UPDATE payment_transaction SET status = 'LATE_PAYMENT', gateway_transaction_no = 'GW0004', paid_at = now(), late_reason = 'Lần giữ ghế đã hết hạn' WHERE id = 4 $q$);
SELECT pg_temp.expect('FAILED sang TICKETED bị chặn', '23514', $q$ UPDATE payment_transaction SET status = 'TICKETED', gateway_transaction_no = 'GW0005', paid_at = now() WHERE id = 5 $q$);
SELECT pg_temp.expect('Tổng đã hoàn vượt số đã thanh toán bị chặn', '23514', $q$ UPDATE payment_transaction SET refunded_total = refunded_total + 220001 WHERE id = 1 $q$);
SELECT pg_temp.expect('Giao dịch chưa thanh toán thành công có khoản hoàn bị chặn', '23514', $q$ UPDATE payment_transaction SET refunded_total = 1 WHERE id = 5 $q$);
SELECT pg_temp.expect('Hoàn một phần trong hạn mức được phép (cộng ngay trong câu UPDATE)', '00000', $q$ UPDATE payment_transaction SET refunded_total = refunded_total + 70000 WHERE id = 1 $q$);
SELECT pg_temp.expect('EX-02: lần giữ ghế 3 sang COMPLETED', '00000', $q$ UPDATE seat_hold SET status = 'COMPLETED' WHERE id = 3 AND status = 'ACTIVE' $q$);
SELECT pg_temp.expect('booking.customer_id khác khách của lần giữ ghế bị chặn', '23514', $q$ INSERT INTO booking (id, booking_code, seat_hold_id, customer_id, booked_at) VALUES (1, 'BK0000000000001', 3, 1, now()) $q$);
SELECT pg_temp.expect('booking.customer_id rỗng khi người giữ là khách bị chặn', '23514', $q$ INSERT INTO booking (id, booking_code, seat_hold_id, customer_id, booked_at) VALUES (1, 'BK0000000000001', 3, NULL, now()) $q$);
SELECT pg_temp.expect('Lần đặt có khách đúng với lần giữ ghế được phép', '00000', $q$ INSERT INTO booking (id, booking_code, seat_hold_id, customer_id, booked_at) VALUES (1, 'BK0000000000001', 3, 3, '2030-01-01 09:05+07') $q$);
SELECT pg_temp.expect('Hai lần đặt cho một lần giữ ghế bị chặn', '23505', $q$ INSERT INTO booking (id, booking_code, seat_hold_id, customer_id, booked_at) VALUES (2, 'BK0000000000002', 3, 3, now()) $q$);
SELECT pg_temp.expect('Mã đặt vé trùng bị chặn', '23505', $q$
DO $d$
BEGIN
  UPDATE seat_hold SET status = 'COMPLETED' WHERE id = 5;
  INSERT INTO booking (id, booking_code, seat_hold_id, customer_id, booked_at) VALUES (2, 'BK0000000000001', 5, NULL, now());
END
$d$ $q$);
SELECT pg_temp.expect('Lần đặt tại quầy có customer_id rỗng được phép (R-65)', '00000', $q$
DO $d$
BEGIN
  UPDATE seat_hold SET status = 'COMPLETED' WHERE id = 5;
  INSERT INTO booking (id, booking_code, seat_hold_id, customer_id, booked_at) VALUES (2, 'BK0000000000002', 5, NULL, '2030-01-01 09:07+07');
END
$d$ $q$);
SELECT pg_temp.expect('Lần giữ ghế của khách không tồn tại bị chặn', '23503', $q$
DO $d$
BEGIN
  INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, status, hold_time, expiry_time) VALUES (12, 1, 999, 'ref-12', 'req-12', 'COMPLETED', '2030-01-01 08:00+07', '2030-01-01 08:10+07');
END
$d$ $q$);
SELECT pg_temp.expect('INSERT vé thiếu giá trị lúc bán (cinema_name NULL) bị chặn (BR-140)', '23502', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (1, 1, 2, 1, 'TK00000000000001', 100000, 'Mai', NULL, 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('Loại phòng lúc bán sai bị chặn', '23514', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (1, 1, 2, 1, 'TK00000000000001', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'VIP') $q$);
SELECT pg_temp.expect('Giá vé không dương bị chặn', '23514', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (1, 1, 2, 1, 'TK00000000000001', 0, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('Vé 1 và 2 của lần đặt 1 (ghế 1 và 2 của suất 2) được phép', '00000', $q$
INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES
  (1, 1, 2, 1, 'TK00000000000001', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD'),
  (2, 1, 2, 2, 'TK00000000000002', 120000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('Hai vé chưa huỷ cho cùng một ghế của một suất chiếu bị chặn (BR-09)', '23505', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (3, 1, 2, 1, 'TK00000000000003', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('Mã vé trùng bị chặn', '23505', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (3, 1, 2, 3, 'TK00000000000001', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('Vé của ghế không có seat_status bị chặn (FK ghép)', '23503', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (3, 1, 1, 11, 'TK00000000000003', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('EX-02: ghế Đang được giữ sang Đã bán gắn vé 1 và 2', '00000', $q$
DO $d$
BEGIN
  UPDATE seat_status SET state = 'SOLD', current_hold_id = NULL, current_ticket_id = 1 WHERE showtime_id = 2 AND seat_id = 1;
  UPDATE seat_status SET state = 'SOLD', current_hold_id = NULL, current_ticket_id = 2 WHERE showtime_id = 2 AND seat_id = 2;
END
$d$ $q$);
SELECT pg_temp.expect('Một vé chiếm hai ghế bị chặn (uq_seat_status_current_ticket)', '23505', $q$ UPDATE seat_status SET state = 'HELD', current_hold_id = 5, held_price = 1 WHERE showtime_id = 2 AND seat_id = 3; UPDATE seat_status SET state = 'SOLD', current_hold_id = NULL, current_ticket_id = 1 WHERE showtime_id = 2 AND seat_id = 3 $q$);
SELECT pg_temp.expect('trg_seat_status_link: đổi thẳng vé hiện tại sang vé khác của cùng ghế bị chặn', '23514', $q$
DO $d$
BEGIN
  INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type, status) VALUES (9, 1, 2, 1, 'TK00000000000009', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD', 'CANCELLED');
  UPDATE seat_status SET current_ticket_id = 9 WHERE showtime_id = 2 AND seat_id = 1;
END
$d$ $q$);
SELECT pg_temp.expect('Giá trị lúc bán của vé (tên phim) không sửa được (BR-140)', '23514', $q$ UPDATE ticket SET movie_title = 'Tên khác' WHERE id = 1 $q$);
SELECT pg_temp.expect('Giá vé không sửa được sau khi bán (BR-67)', '23514', $q$ UPDATE ticket SET price = 1 WHERE id = 1 $q$);
SELECT pg_temp.expect('EX-08: soát vé 2 (UNUSED sang USED)', '00000', $q$ UPDATE ticket SET status = 'USED' WHERE id = 2 AND status = 'UNUSED' $q$);
SELECT pg_temp.expect('Vé đã soát bị huỷ (USED sang CANCELLED) bị chặn', '23514', $q$ UPDATE ticket SET status = 'CANCELLED' WHERE id = 2 $q$);
SELECT pg_temp.expect('EX-06, EX-07: huỷ vé 1, ghế về Trống cùng giao dịch', '00000', $q$
DO $d$
BEGIN
  UPDATE seat_status SET state = 'AVAILABLE', current_ticket_id = NULL, held_price = NULL WHERE showtime_id = 2 AND seat_id = 1 AND current_ticket_id = 1;
  UPDATE ticket SET status = 'CANCELLED' WHERE id = 1 AND status = 'UNUSED';
END
$d$ $q$);
SELECT pg_temp.expect('Vé đã huỷ sang UNUSED hoặc USED bị chặn', '23514', $q$ UPDATE ticket SET status = 'USED' WHERE id = 1 $q$);
SELECT pg_temp.expect('Ghế đã huỷ vé bán lại được: vé mới cho cùng ghế được phép', '00000', $q$ INSERT INTO ticket (id, booking_id, showtime_id, seat_id, ticket_code, price, movie_title, cinema_name, auditorium_name, auditorium_type) VALUES (4, 2, 2, 1, 'TK00000000000004', 100000, 'Mai', 'CineBook Bà Triệu', 'Phòng 01', 'STANDARD') $q$);
SELECT pg_temp.expect('BR-92: xoá seat_status của suất chiếu đã từng có vé (kể cả vé đã huỷ) bị chặn', '23503', $q$ DELETE FROM seat_status WHERE showtime_id = 2 $q$);
SELECT pg_temp.expect('BR-92: xoá riêng ghế có vé đã huỷ bị chặn', '23503', $q$ DELETE FROM seat_status WHERE showtime_id = 2 AND seat_id = 1 $q$);
SELECT pg_temp.expect('Đổi phòng của suất chiếu chưa từng có vé: xoá rồi tạo lại seat_status được phép', '00000', $q$
DO $d$
BEGIN
  DELETE FROM seat_status WHERE showtime_id = 3;
  INSERT INTO seat_status (showtime_id, seat_id) SELECT 3, id FROM seat WHERE auditorium_id = 3 AND in_seat_map;
END
$d$ $q$);
SELECT pg_temp.expect('Xoá vé đang được lần đặt tham chiếu: xoá lần đặt còn vé bị chặn', '23503', $q$ DELETE FROM booking WHERE id = 1 $q$);
SELECT pg_temp.expect('Xoá lần giữ ghế đã có lần đặt bị chặn', '23503', $q$ DELETE FROM seat_hold WHERE id = 3 $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('I: yêu cầu hoàn tiền');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Hoàn một vé qua cổng (TICKET_GATEWAY) cho vé 1 hợp lệ', '00000', $q$ INSERT INTO refund_request (id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount) VALUES (1, 1, 1, '20300101090000000001-T1', 'TICKET_GATEWAY', 70000) $q$);
SELECT pg_temp.expect('Mỗi vé tối đa một yêu cầu hoàn (BR-21)', '23505', $q$ INSERT INTO refund_request (id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount) VALUES (2, 1, 1, 'khoa-khac', 'TICKET_GATEWAY', 70000) $q$);
SELECT pg_temp.expect('Khoá chống hoàn trùng trùng bị chặn (BR-43)', '23505', $q$ INSERT INTO refund_request (id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount) VALUES (2, 1, 2, '20300101090000000001-T1', 'TICKET_GATEWAY', 70000) $q$);
SELECT pg_temp.expect('Hoàn toàn bộ: mỗi giao dịch một lần (BR-16)', '23505', $q$
DO $d$
BEGIN
  INSERT INTO refund_request (id, payment_transaction_id, idempotency_key, request_type, refund_amount) VALUES (2, 4, '20300101090000000004-FULL', 'FULL', 1000);
  INSERT INTO refund_request (id, payment_transaction_id, idempotency_key, request_type, refund_amount) VALUES (3, 4, 'khoa-full-2', 'FULL', 1000);
END
$d$ $q$);
SELECT pg_temp.expect('Hoàn toàn bộ mà có vé bị chặn (ck_refund_request_link)', '23514', $q$ INSERT INTO refund_request (id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount) VALUES (3, 4, 2, 'k3', 'FULL', 1) $q$);
SELECT pg_temp.expect('Hoàn tiền mặt mà có giao dịch bị chặn', '23514', $q$ INSERT INTO refund_request (id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount, status) VALUES (3, 1, 4, 'k3', 'TICKET_CASH', 70000, 'REFUNDED') $q$);
SELECT pg_temp.expect('Hoàn tiền mặt không giao dịch, đã REFUNDED, attempt_count 0 được phép', '00000', $q$ INSERT INTO refund_request (id, ticket_id, idempotency_key, request_type, refund_amount, status) VALUES (3, 4, 'TK00000000000004-CASH', 'TICKET_CASH', 70000, 'REFUNDED') $q$);
SELECT pg_temp.expect('Số lần gửi quá 4 bị chặn (BR-41)', '23514', $q$ UPDATE refund_request SET attempt_count = 5 WHERE id = 1 $q$);
SELECT pg_temp.expect('IN_FLIGHT với attempt_count 0 bị chặn', '23514', $q$ UPDATE refund_request SET status = 'IN_FLIGHT' WHERE id = 1 $q$);
SELECT pg_temp.expect('NEW sang IN_FLIGHT kèm đếm lần gửi trong cùng câu được phép', '00000', $q$ UPDATE refund_request SET status = 'IN_FLIGHT', attempt_count = attempt_count + 1 WHERE id = 1 $q$);
SELECT pg_temp.expect('IN_FLIGHT sang REFUNDED được phép', '00000', $q$ UPDATE refund_request SET status = 'REFUNDED', refund_result = '00' WHERE id = 1 $q$);
SELECT pg_temp.expect('Rời trạng thái cuối: REFUNDED sang IN_FLIGHT bị chặn', '23514', $q$ UPDATE refund_request SET status = 'IN_FLIGHT' WHERE id = 1 $q$);
SELECT pg_temp.expect('NEW sang REFUNDED trực tiếp (bỏ qua gửi) bị chặn', '23514', $q$
DO $d$
BEGIN
  INSERT INTO refund_request (id, payment_transaction_id, ticket_id, idempotency_key, request_type, refund_amount) VALUES (4, 1, 2, 'k4', 'TICKET_GATEWAY', 1);
  UPDATE refund_request SET status = 'REFUNDED', attempt_count = 1 WHERE id = 4;
END
$d$ $q$);
SELECT pg_temp.expect('Số tiền hoàn không dương bị chặn', '23514', $q$ INSERT INTO refund_request (id, payment_transaction_id, idempotency_key, request_type, refund_amount) VALUES (5, 5, 'k5', 'FULL', 0) $q$);
SELECT pg_temp.expect('Loại yêu cầu hoàn ngoài tập bị chặn', '23514', $q$ INSERT INTO refund_request (id, payment_transaction_id, idempotency_key, request_type, refund_amount) VALUES (5, 5, 'k5', 'PARTIAL', 1) $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('J: hàng đợi gửi ngoài (outbox) và seat_event');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('Dựng ba dòng outbox', '00000', $q$
INSERT INTO outbox (id, kind, source_id, idempotency_key, next_attempt_at) VALUES
  (1, 'REFUND_GATEWAY', 1, 'refund-1', '2020-01-01 00:00+07'),
  (2, 'REFUND_GATEWAY', 2, 'refund-2', '2020-01-01 00:01+07'),
  (3, 'EMAIL_TICKET', 1, 'email-ticket-1', '2020-01-01 00:02+07') $q$);
SELECT pg_temp.expect('Khoá idempotency của outbox trùng bị chặn', '23505', $q$ INSERT INTO outbox (id, kind, source_id, idempotency_key) VALUES (4, 'EMAIL_REFUND', 1, 'refund-1') $q$);
SELECT pg_temp.expect('Loại outbox ngoài tập bị chặn', '23514', $q$ INSERT INTO outbox (id, kind, source_id, idempotency_key) VALUES (4, 'SMS', 1, 'sms-1') $q$);
SELECT pg_temp.expect('claim_token mà không có claimed_until bị chặn', '23514', $q$ UPDATE outbox SET claim_token = gen_random_uuid() WHERE id = 3 $q$);
SELECT pg_temp.expect_true('Claim từng dòng: lần claim đầu nhận đúng một dòng đến hạn sớm nhất', $q$
WITH c AS (
  UPDATE outbox SET claim_token = gen_random_uuid(), claimed_until = clock_timestamp() + interval '120 seconds', attempt_count = attempt_count + 1
   WHERE id IN (SELECT id FROM outbox WHERE kind = 'REFUND_GATEWAY' AND status = 'PENDING' AND next_attempt_at <= clock_timestamp()
                  AND (claimed_until IS NULL OR claimed_until < clock_timestamp())
                ORDER BY next_attempt_at LIMIT 1 FOR NO KEY UPDATE SKIP LOCKED)
  RETURNING id)
SELECT count(*) = 1 AND min(id) = 1 FROM c $q$);
SELECT pg_temp.expect_true('Claim từng dòng: lần claim thứ hai nhận dòng kế tiếp, không nhận lại dòng đang claim', $q$
WITH c AS (
  UPDATE outbox SET claim_token = gen_random_uuid(), claimed_until = clock_timestamp() + interval '120 seconds', attempt_count = attempt_count + 1
   WHERE id IN (SELECT id FROM outbox WHERE kind = 'REFUND_GATEWAY' AND status = 'PENDING' AND next_attempt_at <= clock_timestamp()
                  AND (claimed_until IS NULL OR claimed_until < clock_timestamp())
                ORDER BY next_attempt_at LIMIT 1 FOR NO KEY UPDATE SKIP LOCKED)
  RETURNING id)
SELECT count(*) = 1 AND min(id) = 2 FROM c $q$);
SELECT pg_temp.expect_true('Claim từng dòng: lần thứ ba không còn dòng REFUND_GATEWAY nào để nhận', $q$
WITH c AS (
  UPDATE outbox SET claim_token = gen_random_uuid(), claimed_until = clock_timestamp() + interval '120 seconds'
   WHERE id IN (SELECT id FROM outbox WHERE kind = 'REFUND_GATEWAY' AND status = 'PENDING' AND next_attempt_at <= clock_timestamp()
                  AND (claimed_until IS NULL OR claimed_until < clock_timestamp())
                ORDER BY next_attempt_at LIMIT 1 FOR NO KEY UPDATE SKIP LOCKED)
  RETURNING id)
SELECT count(*) = 0 FROM c $q$);
SELECT pg_temp.expect_true('Hàng rào claim_token: ghi bằng token sai trả 0 dòng, bằng token đúng trả 1 dòng', $q$
WITH w AS (UPDATE outbox SET claimed_until = clock_timestamp() + interval '120 seconds' WHERE id = 1 AND claim_token = gen_random_uuid() RETURNING id),
     r AS (UPDATE outbox SET claimed_until = clock_timestamp() + interval '120 seconds' WHERE id = 1 AND claim_token = (SELECT claim_token FROM outbox WHERE id = 1) RETURNING id)
SELECT (SELECT count(*) FROM w) = 0 AND (SELECT count(*) FROM r) = 1 $q$);
SELECT pg_temp.expect('Dòng hết hạn claim được nhận lại', '00000', $q$
DO $d$
DECLARE n INT;
BEGIN
  UPDATE outbox SET claimed_until = clock_timestamp() - interval '1 second' WHERE id = 1;
  WITH c AS (UPDATE outbox SET claim_token = gen_random_uuid(), claimed_until = clock_timestamp() + interval '120 seconds'
     WHERE id IN (SELECT id FROM outbox WHERE kind = 'REFUND_GATEWAY' AND status = 'PENDING' AND next_attempt_at <= clock_timestamp()
                    AND (claimed_until IS NULL OR claimed_until < clock_timestamp())
                  ORDER BY next_attempt_at LIMIT 1 FOR NO KEY UPDATE SKIP LOCKED) RETURNING id)
  SELECT count(*) INTO n FROM c;
  IF n <> 1 THEN RAISE EXCEPTION 'nhận lại %', n; END IF;
END
$d$ $q$);
SELECT pg_temp.expect('outbox PENDING sang SUCCEEDED được phép', '00000', $q$ UPDATE outbox SET status = 'SUCCEEDED' WHERE id = 1 $q$);
SELECT pg_temp.expect('Rời trạng thái cuối: SUCCEEDED sang PENDING bị chặn', '23514', $q$ UPDATE outbox SET status = 'PENDING' WHERE id = 1 $q$);
SELECT pg_temp.expect('Rời trạng thái cuối: EXHAUSTED sang SUCCEEDED bị chặn', '23514', $q$ UPDATE outbox SET status = 'EXHAUSTED' WHERE id = 2; UPDATE outbox SET status = 'SUCCEEDED' WHERE id = 2 $q$);
SELECT pg_temp.expect('outbox không có khoá ngoại tới bản ghi nguồn (nguồn không tồn tại vẫn ghi được)', '00000', $q$ INSERT INTO outbox (id, kind, source_id, idempotency_key) VALUES (9, 'EMAIL_REFUND', 99999, 'email-refund-x') $q$);
SELECT pg_temp.expect('seat_event với items rỗng bị chặn', '23514', $q$ INSERT INTO seat_event (showtime_id, items) VALUES (1, '[]'::jsonb) $q$);
SELECT pg_temp.expect('seat_event với items không phải mảng bị chặn', '23514', $q$ INSERT INTO seat_event (showtime_id, items) VALUES (1, '{"seat_id": 1}'::jsonb) $q$);
SELECT pg_temp.expect('seat_event lấy mã bằng nextval rồi INSERT như câu cuối, không khoá ngoại', '00000', $q$
DO $d$
DECLARE eid BIGINT;
BEGIN
  eid := nextval(pg_get_serial_sequence('seat_event', 'id'));
  INSERT INTO seat_event (id, showtime_id, items) VALUES (eid, 999999, '[{"seat_id": 1, "state": "HELD"}]'::jsonb);
END
$d$ $q$);

--------------------------------------------------------------------------------
SELECT pg_temp.grp('K: mẫu câu khoá của F4.5 chạy được (đúng cú pháp, đúng tên bảng và cột)');
--------------------------------------------------------------------------------
SELECT pg_temp.expect('EX-01: chuỗi khoá hạng 1 đến 6 (nhân viên quầy), NOWAIT', '00000', $q$
DO $d$
BEGIN
  SET LOCAL lock_timeout = '1s';
  PERFORM cinema_id FROM price_list WHERE cinema_id = 1 FOR SHARE;
  PERFORM id FROM auditorium WHERE id = 1 FOR SHARE;
  PERFORM id FROM showtime WHERE id = 2 FOR SHARE;
  PERFORM id, status, access_changed_at FROM staff WHERE id = 2 FOR NO KEY UPDATE;
  PERFORM id FROM seat_hold WHERE box_office_clerk_id = 2 AND status = 'ACTIVE' FOR NO KEY UPDATE;
  PERFORM showtime_id, seat_id, state FROM seat_status WHERE showtime_id = 2 AND seat_id = ANY (ARRAY[3, 4]) ORDER BY showtime_id, seat_id FOR NO KEY UPDATE NOWAIT;
END
$d$ $q$);
SELECT pg_temp.expect('EX-02, EX-03: SeatHold X, SeatStatus của lần giữ ghế X, PaymentTransaction X', '00000', $q$
DO $d$
BEGIN
  PERFORM id FROM seat_hold WHERE id = 3 FOR NO KEY UPDATE;
  PERFORM showtime_id, seat_id FROM seat_status WHERE current_hold_id = 3 ORDER BY showtime_id, seat_id FOR NO KEY UPDATE;
  PERFORM id FROM payment_transaction WHERE code = '20300101090000000001' FOR NO KEY UPDATE;
END
$d$ $q$);
SELECT pg_temp.expect('EX-04, EX-05: câu quét hết hạn và quét giải phóng theo lô', '00000', $q$
DO $d$
BEGIN
  PERFORM id FROM seat_hold WHERE status = 'ACTIVE' AND expiry_time <= clock_timestamp() ORDER BY expiry_time LIMIT 200 FOR NO KEY UPDATE SKIP LOCKED;
  PERFORM h.id FROM seat_hold h WHERE h.status IN ('EXPIRED', 'CANCELLED', 'PAYMENT_FAILED')
    AND h.id IN (SELECT current_hold_id FROM seat_status WHERE current_hold_id IS NOT NULL) ORDER BY h.id LIMIT 200 FOR NO KEY UPDATE OF h SKIP LOCKED;
END
$d$ $q$);
SELECT pg_temp.expect('EX-06 đến EX-09: khoá ghế, giao dịch, vé theo hạng 6, 7, 8 rồi cộng khoản hoàn', '00000', $q$
DO $d$
BEGIN
  PERFORM 1 FROM seat_status WHERE showtime_id = 2 AND seat_id = 1 FOR NO KEY UPDATE;
  PERFORM 1 FROM payment_transaction WHERE id = 1 FOR NO KEY UPDATE;
  PERFORM 1 FROM ticket WHERE id = 4 FOR NO KEY UPDATE;
END
$d$ $q$);
SELECT pg_temp.expect('EX-11, EX-12: PriceList X, Auditorium S theo mã, Showtime S của cụm', '00000', $q$
DO $d$
BEGIN
  PERFORM 1 FROM price_list WHERE cinema_id = 1 FOR NO KEY UPDATE;
  PERFORM id FROM auditorium WHERE cinema_id = 1 ORDER BY id FOR SHARE;
  PERFORM id FROM showtime WHERE auditorium_id IN (SELECT id FROM auditorium WHERE cinema_id = 1) AND status = 'IN_SCHEDULE' ORDER BY id FOR SHARE;
END
$d$ $q$);
SELECT pg_temp.expect('EX-13: PriceList S, Auditorium X, Showtime X, SeatHold S, SeatStatus FOR UPDATE, Ticket S, Movie S', '00000', $q$
DO $d$
BEGIN
  PERFORM 1 FROM price_list WHERE cinema_id = 1 FOR SHARE;
  PERFORM id FROM auditorium WHERE id IN (1, 2) ORDER BY id FOR NO KEY UPDATE;
  PERFORM id FROM showtime WHERE id = 2 FOR NO KEY UPDATE;
  PERFORM id FROM seat_hold WHERE showtime_id = 2 AND status = 'ACTIVE' ORDER BY id FOR SHARE;
  PERFORM showtime_id, seat_id FROM seat_status WHERE showtime_id = 3 ORDER BY showtime_id, seat_id FOR UPDATE;
  PERFORM id FROM ticket WHERE showtime_id = 2 ORDER BY id FOR SHARE;
  PERFORM id FROM movie WHERE id = 1 FOR SHARE;
END
$d$ $q$);
SELECT pg_temp.expect('EX-15: Cinema X, PriceList S, Auditorium X, Showtime S, SeatStatus FOR UPDATE; kiểm tên phòng theo norm_name', '00000', $q$
DO $d$
BEGIN
  PERFORM 1 FROM cinema WHERE id = 1 FOR NO KEY UPDATE;
  PERFORM 1 FROM price_list WHERE cinema_id = 1 FOR SHARE;
  PERFORM 1 FROM auditorium WHERE id = 1 FOR NO KEY UPDATE;
  PERFORM id FROM showtime WHERE auditorium_id = 1 ORDER BY id FOR SHARE;
  PERFORM showtime_id, seat_id FROM seat_status WHERE showtime_id IN (SELECT id FROM showtime WHERE auditorium_id = 1) ORDER BY showtime_id, seat_id FOR UPDATE;
  PERFORM 1 FROM auditorium WHERE cinema_id = 1 AND norm_name(name) = norm_name(' phòng   02') AND id <> 1;
END
$d$ $q$);
SELECT pg_temp.expect('EX-16: sửa phim FOR NO KEY UPDATE rồi so mốc', '00000', $q$ DO $d$ BEGIN PERFORM 1 FROM movie WHERE id = 1 AND last_changed_at = '2030-01-01 00:00:00+07' FOR NO KEY UPDATE; END $d$ $q$);
SELECT pg_temp.expect('EX-17, EX-20, EX-21: khoá tư vấn hai số nguyên theo giá trị chuẩn hoá', '00000', $q$
DO $d$
BEGIN
  PERFORM pg_advisory_xact_lock(1000, hashtext(norm_name('  Cụm   Á ')));
  PERFORM pg_advisory_xact_lock(1011, hashtext(norm_email(' A@X.com ')));
  PERFORM pg_advisory_xact_lock(1012, hashtext('0901000001'));
  PERFORM pg_advisory_xact_lock(1013, hashtext(norm_email('quay1@cinebook.vn')));
END
$d$ $q$);
SELECT pg_temp.expect('EX-22: Staff X rồi so mốc bằng nhau ở micro giây', '00000', $q$ DO $d$ BEGIN PERFORM 1 FROM staff WHERE id = 2 AND last_changed_at = '2030-01-02 00:00:00.123456+07' FOR NO KEY UPDATE; IF NOT FOUND THEN RAISE EXCEPTION 'mốc lệch'; END IF; END $d$ $q$);
SELECT pg_temp.expect('Báo cáo: gộp doanh thu theo ngày chiếu của suất chiếu, múi giờ nêu tường minh', '00000', $q$
SELECT (s.start_time AT TIME ZONE 'Asia/Ho_Chi_Minh')::date AS show_date, sum(t.price) AS gross
  FROM ticket t JOIN showtime s ON s.id = t.showtime_id JOIN auditorium a ON a.id = s.auditorium_id
 WHERE a.cinema_id = 1 AND s.start_time >= '2030-01-01 00:00+07' AND s.start_time < '2030-01-02 00:00+07'
 GROUP BY 1 $q$);
SELECT pg_temp.expect('Báo cáo: sức chứa bằng số dòng seat_status của suất chiếu chưa xoá', '00000', $q$
SELECT s.id, count(*) FROM showtime s JOIN seat_status ss ON ss.showtime_id = s.id WHERE s.status = 'IN_SCHEDULE' GROUP BY s.id $q$);
SELECT pg_temp.expect('Lịch sử đặt vé: các lần đặt của khách từ gần nhất, kèm vé', '00000', $q$
SELECT b.id, b.booked_at, t.status FROM booking b JOIN ticket t ON t.booking_id = b.id WHERE b.customer_id = 3 ORDER BY b.booked_at DESC $q$);
SELECT pg_temp.expect_true('Lịch sử đặt vé dùng chỉ mục (customer_id, booked_at DESC)', $q$
SELECT indexdef LIKE '%(customer_id, booked_at DESC)%' FROM pg_indexes WHERE indexname = 'ix_booking_customer_booked' $q$);

--------------------------------------------------------------------------------
-- Kết quả
--------------------------------------------------------------------------------
SELECT format('%s | %s | %s | mong đợi %s, thực tế %s%s | %s', lpad(n::text, 3, '0'), grp, name, expected, actual, CASE WHEN COALESCE(msg, '') = '' THEN '' ELSE ' [' || left(replace(msg, E'\n', ' '), 110) || ']' END, CASE WHEN ok THEN 'ĐẠT' ELSE 'TRƯỢT' END)
  FROM t_result ORDER BY n;
SELECT format('TỔNG: %s/%s ca đạt, %s ca trượt', count(*) FILTER (WHERE ok), count(*), count(*) FILTER (WHERE NOT ok)) FROM t_result;
ROLLBACK;

--------------------------------------------------------------------------------
-- PHẦN B: kịch bản hai phiên psql đồng thời (chạy sau Phần A trên cùng CSDL; mỗi kịch bản tự dựng dữ liệu và dọn)
--
-- Dựng dữ liệu nền dùng chung (một lần):
--   docker exec -i p13check psql -U postgres -v ON_ERROR_STOP=1 -q <<'SQL'
--   INSERT INTO cinema (id,name,province,last_changed_at) VALUES (1,'Cụm A','Hà Nội',now());
--   INSERT INTO price_list VALUES (1);
--   INSERT INTO movie (id,title,duration_minutes,release_date,end_of_run_date,genre,age_rating,last_changed_at) VALUES (1,'Mai',120,'2030-01-01','2030-12-31','Tâm lý','T18',now());
--   INSERT INTO auditorium (id,cinema_id,name,auditorium_type,last_changed_at) VALUES (1,1,'Phòng 01','STANDARD',now());
--   INSERT INTO seat (id,auditorium_id,row_code,seat_number,seat_type) VALUES (1,1,'A',1,'STANDARD'),(2,1,'A',2,'STANDARD');
--   INSERT INTO showtime (id,auditorium_id,movie_id,start_time,sale_open_time,end_time,last_changed_at,movie_format) VALUES (1,1,1,now()+interval '1 day',now()-interval '1 day',now()+interval '1 day 2 hours',now(),'2D');
--   INSERT INTO seat_status (showtime_id,seat_id) VALUES (1,1),(1,2);
--   INSERT INTO customer (id,email,phone_number,password_hash) VALUES (1,'k1@x.vn','0901000001','h'),(2,'k2@x.vn','0901000002','h');
--   SQL
--
-- B1. Hai phiên cùng giữ ghế 1 theo câu khoá EX-01: phiên A giữ được, phiên B nhận 55P03 (NOWAIT).
--   Phiên A (khởi động trước, giữ giao dịch mở 3 giây rồi COMMIT):
--     BEGIN; SET LOCAL lock_timeout = '1s';
--     SELECT 1 FROM price_list WHERE cinema_id = 1 FOR SHARE;
--     SELECT 1 FROM auditorium WHERE id = 1 FOR SHARE;
--     SELECT 1 FROM showtime WHERE id = 1 FOR SHARE;
--     SELECT 1 FROM customer WHERE id = 1 FOR NO KEY UPDATE;
--     SELECT showtime_id, seat_id, state FROM seat_status WHERE showtime_id = 1 AND seat_id = ANY (ARRAY[1]) ORDER BY showtime_id, seat_id FOR NO KEY UPDATE NOWAIT;
--     INSERT INTO seat_hold (id, showtime_id, customer_id, hold_ref, request_id, hold_time, expiry_time) VALUES (101, 1, 1, 'ref-a', 'req-a', clock_timestamp(), clock_timestamp() + interval '10 minutes');
--     SELECT pg_sleep(3);
--     UPDATE seat_status SET state = 'HELD', current_hold_id = 101, held_price = 90000 WHERE showtime_id = 1 AND seat_id = 1;
--     COMMIT;
--   Phiên B (khởi động 1 giây sau A, cùng câu khoá, người giữ là khách 2): dòng SELECT ... NOWAIT báo
--     ERROR: could not obtain lock on row in relation "seat_status" (SQLSTATE 55P03)
--   Sau khi cả hai kết thúc: seat_status (1,1) ở HELD bởi lần giữ ghế 101, không có lần giữ ghế của khách 2.
--
-- B2. Khoá giá trị (hạng 0): hai phiên cùng tên cụm rạp chuẩn hoá xếp hàng ở pg_advisory_xact_lock(1000, hashtext(norm_name(...)));
--     phiên B với tên viết khác hoa thường chờ rồi hết lock_timeout (55P03); tên khác hẳn không chờ.
-- B3. Claim từng dòng outbox: hai phiên cùng chạy câu claim LIMIT 1 ... SKIP LOCKED trong giao dịch mở nhận hai dòng khác nhau.
-- B4. Khoá ngầm của khoá ngoại: phiên A UPDATE tên cụm rạp (FOR NO KEY UPDATE) chưa COMMIT; phiên B INSERT phòng chiếu của cụm rạp đó
--     không phải chờ (chỉ mục unique theo biểu thức không phải khoá mà khoá ngoại có thể tham chiếu).
-- B5. Báo cáo REPEATABLE READ READ ONLY: phiên R đếm vé, phiên W bán thêm vé và COMMIT không phải chờ R, phiên R đếm lại vẫn thấy số cũ;
--     phiên READ COMMITTED đếm lại thấy số mới.
-- Lệnh và kết quả chạy thật của B1 đến B5 ghi ở design/P13-data-model.md mục F9.1.
--------------------------------------------------------------------------------
