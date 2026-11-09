# P04 - Đặc tả use case UC-005 Đặt vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.12 |
| Thay đổi 1.12 | Cấp Q-139 (đã trả lời) làm nguồn gốc của BR-93 và dẫn mã Q ở luồng 11a |
| Thay đổi 1.11 | Thêm điều kiện giao dịch tạo sau cùng vào luồng 11a và BR-93 (review cuối RF-04); ghi rõ ngừng bán là ngừng nhận lần giữ ghế mới (RF-16); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P02R-review.md 1.0; P03-usecase-model.md 1.1; _BR-register.md (đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; P06-supplementary-spec.md 1.3; UC-006-refund-late-payment.md 1.7, UC-008-cancel-ticket.md 1.7, UC-014-schedule-showtimes.md 1.4, UC-013-manage-price-list.md 1.2 (điểm nối); _review-final-batch1.md; _review-final-batch1-recheck.md; _review-UC-013.md (R13-03, R13-04) |
| Phạm vi | UC-005 |
| Mã Q, ASM cuối đã cấp | Q-139 (cấp cho BR-93, đã trả lời); Q-80 (Q-76, Q-77, Q-79 cấp ở P06, review P05 và P06, đã trả lời); Q-67 (cấp ở UC-013); Q-61 và Q-56 đã trả lời (cấp ở UC-014); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-005 |
| Tên use case | Đặt vé (Book Tickets) |
| Tác nhân chính | ACT-01 Khách, ACT-02 Nhân viên quầy |
| Tác nhân phụ | ACT-07 Cổng thanh toán, ACT-08 Dịch vụ email |
| Mô tả ngắn | Use case này mô tả tương tác giữa khách (hoặc nhân viên quầy bán vé tại quầy) và hệ thống khi muốn mua vé cho một số ghế của một suất chiếu. Kết quả là các ghế đã chọn chuyển sang trạng thái đã bán và mỗi ghế có một vé mang mã QR, cùng một mã đặt vé. |
| Sự kiện kích hoạt | Khách muốn mua vé một suất chiếu (EV-05) |
| Tiền điều kiện | Khi tác nhân là nhân viên quầy: nhân viên quầy đã đăng nhập và đang có phiên làm việc (REQ-102).<br>Khi tác nhân là khách: không có (khách chưa đăng nhập vẫn bắt đầu được use case, việc đăng nhập kiểm tra ở bước 5, REQ-13, REQ-14). |
| Hậu điều kiện (thành công) | Các ghế đã chọn của suất chiếu ở trạng thái đã bán.<br>Có một mã đặt vé cho lần đặt và mỗi ghế một vé có mã QR riêng.<br>Mã giao dịch do cổng thanh toán cấp được lưu.<br>Email chứa các vé đã được gửi cho khách qua dịch vụ email.<br>Khi kết thúc ở luồng 9a: các ghế đã chọn ở trạng thái đã bán; có mã đặt vé và vé có mã QR; không có giao dịch qua cổng thanh toán và không gửi email; vé đã được in. |
| Hậu điều kiện tối thiểu | Khi use case kết thúc thất bại, không vé nào được tạo và không ghế nào còn ở trạng thái đang được giữ cho lần đặt này: ghế đã giữ được giải phóng về trạng thái trống (với luồng 7b và 9a1a, chậm nhất 1 phút sau thời điểm hết hạn, REQ-76). Khi kết thúc ở luồng 9a1a, nhân viên quầy được thông báo trả lại tiền mặt đã thu cho khách (BR-44). |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-13 đến REQ-34, REQ-45 đến REQ-49, REQ-81, REQ-82, REQ-86, REQ-88, REQ-89, REQ-92, REQ-119, REQ-134, REQ-135 (theo P02); REQ-37, REQ-38, REQ-74, REQ-75, REQ-76, REQ-78, REQ-79, REQ-80, REQ-87, REQ-91 (P02 Mục 5 đã gắn UC-005); REQ-12 (tham chiếu, tiền điều kiện của UC-007, UC-008), REQ-35, REQ-36, REQ-109, REQ-110, REQ-130 (tham chiếu, UC-006; REQ-110 cũng cho BR-37), REQ-111, REQ-136 (bước 10), REQ-100 (tham chiếu, UC-017); REQ-105, REQ-106 (Dữ liệu ra 3); REQ-107, REQ-108 (tham chiếu, UC-001; Dữ liệu vào 2); REQ-142 (bước 7, luồng 7d); REQ-149 (bước 7, 8); REQ-152 (bước 7, luồng 7e); REQ-65 (tham chiếu, UC-014); REQ-157 (bước 14); REQ-158 (luồng 10a); REQ-160, REQ-161 (Mục 8) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Khách / Nhân viên quầy | Chọn một suất chiếu cần mua vé. |
| 2 | Hệ thống | Kiểm tra suất chiếu đã tới thời điểm mở bán (BR-01) và chưa tới giờ bắt đầu (BR-45) và, khi tác nhân là nhân viên quầy, suất chiếu thuộc cụm rạp của nhân viên quầy (BR-02). |
| 3 | Hệ thống | Hiển thị sơ đồ ghế của suất chiếu (xem Dữ liệu ra 1) và cập nhật trạng thái ghế khi người khác giữ hoặc mua ghế trong lúc tác nhân chọn ghế. |
| 4 | Khách / Nhân viên quầy | Chọn các ghế muốn mua và xác nhận chọn ghế (xem Dữ liệu vào 1); ghế đang chọn vẫn ở trạng thái trống cho tới khi xác nhận (BR-03). |
| 5 | Hệ thống | Kiểm tra khách đã đăng nhập và tác nhân không có lần giữ ghế nào chưa kết thúc (BR-04). |
| 6 | Hệ thống | Kiểm tra số ghế đã chọn không vượt quá số ghế tối đa của một lần giữ ghế (BR-05, BR-06). |
| 7 | Hệ thống | Kiểm tra suất chiếu còn tồn tại và chưa bị sửa kể từ lúc hiển thị sơ đồ ghế ở bước 3, tác nhân không có lần giữ ghế nào chưa kết thúc và mọi ghế đã chọn còn trống, xác định giá vé từng ghế theo bảng giá của cụm rạp, rồi giữ tạm cả nhóm ghế cùng giá đã xác định cho tác nhân trong thời gian giữ ghế, tất cả là một thao tác không chia cắt (BR-04, BR-07, BR-08, BR-09, BR-10, BR-11, BR-12, BR-54, BR-65, BR-66, BR-71, BR-85). |
| 8 | Hệ thống | Hiển thị các ghế đã giữ, giá vé từng ghế đã xác định ở bước 7 và tổng tiền (xem Dữ liệu ra 2; BR-65). |
| 9 | Khách | Yêu cầu thanh toán trực tuyến. |
| 10 | Hệ thống | Tạo giao dịch thanh toán cho tổng tiền đã hiển thị ở bước 8 qua cổng thanh toán để khách thanh toán, truyền kèm mã tham chiếu của lần giữ ghế cho cổng (REQ-136) và ghi nhận số tiền của giao dịch (REQ-111). |
| 11 | Cổng thanh toán | Báo giao dịch thanh toán thành công. |
| 12 | Hệ thống | Chuyển các ghế đang giữ sang trạng thái đã bán, lưu mã giao dịch do cổng thanh toán cấp và đánh dấu giao dịch đã xử lý (BR-37). |
| 13 | Hệ thống | Tạo một mã đặt vé cho lần đặt và cho mỗi ghế một vé có mã QR riêng. |
| 14 | Hệ thống | Gửi các vé cho khách qua dịch vụ email. |
| 15 | Hệ thống | Thông báo đặt vé thành công và hiển thị mã đặt vé cùng các vé (xem Dữ liệu ra 3). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Tác nhân đang có một lần giữ ghế ở trạng thái Đang giữ (BR-04), do đã tải lại trang, đóng tab hoặc không quay lại từ cổng thanh toán | Hệ thống | Hiển thị lối Tiếp tục thanh toán kèm thời gian giữ ghế còn lại. Khi tác nhân chọn tiếp tục, nạp lại các ghế đã giữ, giá vé từng ghế đã chốt, tổng tiền và thời điểm hết hạn giữ ghế (không đổi); không giữ ghế mới (Q-119). | Quay lại bước 8 |
| 2a | Suất chiếu chưa tới thời điểm mở bán (BR-01) | Hệ thống | Từ chối bán vé và thông báo suất chiếu chưa mở bán (BR-01). | Kết thúc use case (thất bại) |
| 2b | Suất chiếu đã mở bán, tác nhân là nhân viên quầy và suất chiếu không thuộc cụm rạp của nhân viên quầy (BR-02) | Hệ thống | Từ chối bán vé và thông báo quy tắc bị vi phạm (BR-02). | Kết thúc use case (thất bại) |
| 2c | Suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc (BR-45), và không thuộc 2b | Hệ thống | Từ chối bán vé và thông báo suất chiếu đã bắt đầu (BR-45). | Kết thúc use case (thất bại) |
| 5a | Tác nhân là khách và khách chưa đăng nhập | - | Khách đăng nhập | - |
| 5a1 | | Hệ thống | Yêu cầu khách đăng nhập, giữ nguyên các ghế khách đã chọn (các ghế vẫn ở trạng thái trống, BR-03). | |
| 5a2 | | Khách | Cung cấp email hoặc số điện thoại cùng mật khẩu (xem Dữ liệu vào 2). | Quay lại bước 5 |
| 5a2a | Email, số điện thoại hoặc mật khẩu không đúng | Hệ thống | Thông báo thông tin đăng nhập không đúng, không nêu trường nào sai; giữ nguyên các ghế đã chọn; không giới hạn số lần thử và không khoá tạm (Q-131). | Quay lại bước 5a2 |
| 5b | Khách đã đăng nhập (hoặc tác nhân là nhân viên quầy) và tác nhân đang có một lần giữ ghế chưa kết thúc (BR-04) | Hệ thống | Từ chối giữ ghế và thông báo quy tắc bị vi phạm (BR-04). | Kết thúc use case (thất bại) |
| 6a | Số ghế đã chọn vượt quá số ghế tối đa của một lần giữ ghế (BR-05, BR-06) | Hệ thống | Từ chối giữ ghế và thông báo số ghế tối đa (BR-05). | Quay lại bước 4 |
| 7a | Tác nhân không có lần giữ ghế chưa kết thúc (không thuộc 7c), suất chiếu còn tồn tại và chưa bị sửa (không thuộc 7d) và có ít nhất một ghế đã chọn không còn trống (đã bị người khác giữ hoặc mua trước, kể cả khi người khác xác nhận chọn cùng ghế ngay trước đó, BR-09); kiểm trước 7e | Hệ thống | Thông báo các ghế không còn trống và không giữ ghế nào (BR-07). | Quay lại bước 3 |
| 7b | Tới thời điểm hết hạn giữ ghế (BR-10) tại bất kỳ bước nào từ bước 8 đến bước 11 mà cổng thanh toán chưa báo thanh toán thành công (hoặc, ở luồng 9a, nhân viên quầy chưa xác nhận đã thu tiền) | Hệ thống | Giải phóng các ghế đang giữ về trạng thái trống và thông báo hết thời gian giữ ghế. | Kết thúc use case (thất bại) |
| 7c | Tác nhân đang có một lần giữ ghế chưa kết thúc (BR-04); kiểm điều kiện này trước 7a | Hệ thống | Từ chối giữ ghế và thông báo quy tắc bị vi phạm (BR-04). | Kết thúc use case (thất bại) |
| 7d | Suất chiếu đã bị xoá hoặc đã bị sửa bất kỳ thông tin nào kể từ lúc hệ thống hiển thị sơ đồ ghế ở bước 3, tại thời điểm tác nhân xác nhận chọn ghế (BR-54), không thuộc 7c; kiểm điều kiện này trước 7a | Hệ thống | Từ chối giữ ghế, không giữ ghế nào, và thông báo suất chiếu đã thay đổi hoặc không còn; tác nhân bắt đầu lại để chọn suất chiếu. | Kết thúc use case (thất bại) |
| 7e | Tác nhân không có lần giữ ghế chưa kết thúc (không thuộc 7c), suất chiếu còn tồn tại và chưa bị sửa (không thuộc 7d), mọi ghế đã chọn còn trống (không thuộc 7a) và bảng giá của cụm rạp không có giá cho ít nhất một ghế đã chọn, ứng với loại phòng, định dạng phim, loại ghế và khung giờ chiếu của suất chiếu (BR-11, BR-12, BR-72) | Hệ thống | Từ chối giữ ghế, không giữ ghế nào, và thông báo không xác định được giá vé. | Kết thúc use case (thất bại) |
| 9a | Tác nhân là nhân viên quầy bán vé cho khách mua vé tại quầy | - | Bán vé tại quầy | - |
| 9a1 | | Nhân viên quầy | Thu tiền mặt của khách mua tại quầy (BR-13) và xác nhận đã thu tiền. | |
| 9a1a | Xác nhận đã thu tiền tới hệ thống sau thời điểm hết hạn giữ ghế, kể cả khi ghế chưa được giải phóng (BR-10, BR-44) | Hệ thống | Từ chối xác nhận, không chuyển ghế sang đã bán và thông báo nhân viên quầy trả lại tiền mặt đã thu cho khách (BR-44). Ghế được giải phóng theo luồng 7b. | Kết thúc use case (thất bại) |
| 9a2 | | Hệ thống | Chuyển các ghế đang giữ sang trạng thái đã bán (khi xác nhận tới trước thời điểm hết hạn, BR-44). | |
| 9a3 | | Hệ thống | Tạo một mã đặt vé cho lần đặt và cho mỗi ghế một vé có mã QR riêng. | |
| 9a4 | | Hệ thống | Hiển thị mã đặt vé và các vé để in (xem Dữ liệu ra 3). | |
| 9a5 | | Nhân viên quầy | In vé cho khách mua tại quầy. | Kết thúc use case (thành công) |
| 10a | Cổng thanh toán từ chối hoặc không trả lời trong 30 giây yêu cầu tạo giao dịch (BR-90); với cổng chỉ nhận địa chỉ thanh toán đã ký, không có lời gọi mạng khi tạo giao dịch nên luồng này xảy ra khi hệ thống lỗi trước lúc chuyển khách sang cổng | Hệ thống | Giữ nguyên lần giữ ghế và thông báo chưa tạo được thanh toán; thời điểm hết hạn giữ ghế không đổi, tới thời điểm đó mà chưa có thanh toán thành công thì kết thúc ở luồng 7b. | Quay lại bước 9 |
| 10b | Khách quay về từ cổng thanh toán khi hệ thống chưa nhận kết quả giao dịch và lần giữ ghế còn Đang giữ | Hệ thống | Hiển thị đang xác nhận thanh toán và hỏi lại trạng thái giao dịch mỗi 2 giây, tối đa 60 giây. Nhận được kết quả trong thời gian đó thì xử lý như bước 11 (thành công --> bước 12, thất bại --> luồng 11a). Quá 60 giây chưa có kết quả thì báo chưa xác nhận được thanh toán, kiểm tra lại sau, và cho khách quay lại thanh toán; thời điểm hết hạn giữ ghế không đổi, tới đó mà chưa có thanh toán thành công thì kết thúc ở luồng 7b (Q-126). | Quay lại bước 9 |
| 11a | Cổng thanh toán báo giao dịch thanh toán thất bại, và giao dịch đó là giao dịch tạo sau cùng của lần giữ ghế (BR-93, Q-139) | Hệ thống | Giải phóng các ghế đang giữ về trạng thái trống và thông báo thanh toán không thành công. Nếu khách đã tạo giao dịch thanh toán mới hơn cho lần giữ ghế thì báo thất bại của giao dịch cũ chỉ được ghi nhận, lần giữ ghế và ghế giữ nguyên (BR-93, Q-139). Giao dịch thành công mà cổng thanh toán báo về sau đó không tạo vé và được xử lý ở UC-006 (BR-15). | Kết thúc use case (thất bại) |
| *a | Tại bất kỳ bước nào từ bước 8 đến trước bước 11, khách hoặc nhân viên quầy huỷ việc giữ ghế | Hệ thống | Giải phóng các ghế đang giữ về trạng thái trống. Giao dịch thành công mà cổng thanh toán báo về sau đó không tạo vé và được xử lý ở UC-006 (BR-15). | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 4)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Các ghế đã chọn | Vị trí các ghế muốn mua trên sơ đồ ghế của suất chiếu | Có | Mỗi ghế thuộc sơ đồ ghế của phòng chiếu của suất chiếu; ít nhất 1 ghế, không vượt quá số ghế tối đa (BR-05), ghế đôi tính là một ghế (BR-06) | F7, F8 (ghế VIP); M1 (ghế đôi): tính 3 ghế |

Dữ liệu vào 2 (bước 5a2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Email hoặc số điện thoại | Định danh tài khoản khách đã đăng ký | Có | Trùng email hoặc số điện thoại của một tài khoản khách đã đăng ký (REQ-11, REQ-12); email theo định dạng email chuẩn (REQ-107); số điện thoại là số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0 (REQ-108) | an.nguyen@example.com |
| 2 | Mật khẩu | Mật khẩu của tài khoản | Có | Khớp mật khẩu của tài khoản đó (REQ-12) | (không hiển thị) |

Dữ liệu ra 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Suất chiếu | Phim, định dạng, phòng chiếu, ngày giờ bắt đầu (REQ-61) | Ngày giờ dạng dd/mm/yyyy hh:mm | Phim A, 2D, Phòng 3, 15/11/2026 19:30 |
| 2 | Vị trí ghế | Vị trí từng ghế trên sơ đồ ghế của phòng chiếu | Mã hàng và số ghế | F7 |
| 3 | Loại ghế | Ghế thường, ghế VIP hoặc ghế đôi (REQ-16) | Văn bản | Ghế VIP |
| 4 | Trạng thái ghế | Trống, đang được giữ hoặc đã bán (REQ-15) | Văn bản | Trống |

Dữ liệu ra 2 (bước 8)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Các ghế đã giữ | Vị trí và loại của từng ghế đã giữ | Mã hàng và số ghế, kèm loại ghế | F7 (VIP), F8 (VIP) |
| 2 | Giá vé từng ghế | Giá theo bảng giá của cụm rạp, xác định ở bước 7 (BR-11, BR-12, BR-65) | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 120.000 đ |
| 3 | Tổng tiền | Tổng giá vé của các ghế đã giữ (mỗi ghế một vé, REQ-30) | Như giá vé | 240.000 đ (120.000 x 2) |

Dữ liệu ra 3 (bước 15, bước 9a4)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Mã đặt vé | Mã của lần đặt, duy nhất trên toàn hệ thống (REQ-30, REQ-106) | Văn bản; nguồn không quy định định dạng cụ thể của mã | CB0001234 |
| 2 | Vé | Với mỗi ghế: mã đặt vé, tên phim, định dạng phim, tên cụm rạp, tên phòng chiếu và loại phòng, ngày và giờ bắt đầu suất chiếu, vị trí ghế, loại ghế, giá vé, mã QR riêng của vé (REQ-105) | Ngày giờ dạng dd/mm/yyyy hh:mm; giá vé như Dữ liệu ra 2; mã QR dạng ảnh; các trường còn lại là văn bản | CB0001234, Phim A, 2D, Cụm rạp X, Phòng 3 (IMAX), 15/11/2026 19:30, F7, Ghế VIP, 120.000 đ, [mã QR] |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-01 | Trước thời điểm mở bán của suất chiếu, không ai được đặt hoặc mua vé của suất chiếu đó. | Ràng buộc | 2, 2a | REQ-86; REQ-61 (phụ) | Mới |
| BR-02 | Nhân viên quầy chỉ bán vé các suất chiếu tại cụm rạp của mình. | Ràng buộc | 2, 2b | REQ-45; REQ-100 (phụ) | Mới |
| BR-03 | Ghế tác nhân đang chọn trên sơ đồ vẫn ở trạng thái trống cho tới khi tác nhân xác nhận chọn ghế. | Sự kiện | 4, 5a1 | REQ-88 | Mới |
| BR-04 | Tại một thời điểm, mỗi khách và mỗi nhân viên quầy có tối đa một lần giữ ghế chưa kết thúc. | Ràng buộc | 5, 5b, 7, 7c | REQ-89, REQ-92 | Mới |
| BR-05 | Nhóm ghế của một lần giữ ghế (các ghế tác nhân chọn cho một lần đặt vé) gồm tối đa 8 ghế; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | 6, 6a, Dữ liệu vào 1 | REQ-20, REQ-46 | Mới |
| BR-06 | Ghế đôi được tính là một ghế khi đếm số ghế của một lần giữ ghế, sức chứa phòng và tỉ lệ lấp đầy. | Suy luận | 6, Dữ liệu vào 1 | REQ-87; REQ-17 (phụ) | Mới |
| BR-07 | Việc giữ ghế chỉ thành công khi tất cả các ghế được chọn đều còn trống; nếu có ghế không còn trống thì không ghế nào được giữ. | Ràng buộc | 7, 7a | REQ-24, REQ-46 | Mới |
| BR-08 | Ghế đang được giữ cho một người thì không người nào khác được chọn ghế đó. | Ràng buộc | 7 | REQ-23 | Mới |
| BR-09 | Một ghế của một suất chiếu chỉ được bán cho đúng một người; khi nhiều người cùng lúc xác nhận chọn cùng một ghế, chỉ một người giữ được ghế đó. | Ràng buộc | 7, 7a | REQ-26, REQ-27 | Mới |
| BR-10 | Ghế được giữ tạm trong 10 phút kể từ khi giữ thành công; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | 7, 7b | REQ-22, REQ-46 | Mới |
| BR-11 | Giá vé lấy theo bảng giá của cụm rạp có suất chiếu, phụ thuộc loại phòng, định dạng phim, loại ghế và khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi; ngày thường hoặc cuối tuần). | Tính toán | 7, Dữ liệu ra 2 | REQ-37, REQ-38 | Mới |
| BR-12 | Khung giờ chiếu xác định theo giờ bắt đầu của suất chiếu; cuối tuần gồm Thứ Bảy và Chủ nhật. | Suy luận | 7, Dữ liệu ra 2 | REQ-91 | Mới |
| BR-13 | Khách mua vé tại quầy trả bằng tiền mặt. | Ràng buộc | 9a1 | REQ-47 | Mới |
| BR-14 | Thanh toán thành công được báo về sau thời điểm hết hạn giữ ghế thì không tạo vé, kể cả khi ghế chưa được giải phóng; khách được hoàn toàn bộ số tiền. | Kích hoạt hành động | 7b (mục 8) | REQ-36, REQ-35 | Mới |
| BR-15 | Thanh toán thành công được báo về sau khi khách đã huỷ việc giữ ghế hoặc sau khi cổng thanh toán đã báo thất bại, kể cả trước thời điểm hết hạn giữ ghế, thì không tạo vé; khách được hoàn toàn bộ số tiền và được báo qua email. | Kích hoạt hành động | *a, 11a (mục 8) | REQ-109 | Mới |
| BR-37 | Mỗi giao dịch thanh toán thành công chỉ được xử lý một lần, hoặc tạo vé ở UC-005 hoặc hoàn toàn bộ ở UC-006; kết quả báo trùng của giao dịch đã được xử lý không tạo thêm vé và không hoàn thêm; khi hai báo của cùng một giao dịch đến đồng thời thì xử lý tuần tự theo BR-85 và chỉ báo đầu tiên được xử lý. | Ràng buộc | 11, 12 | REQ-110, REQ-35, REQ-109 | Đã có |
| BR-44 | Xác nhận đã thu tiền mặt của nhân viên quầy tới sau thời điểm hết hạn giữ ghế bị từ chối và nhân viên quầy được thông báo trả lại tiền mặt cho khách; việc so thời điểm hết hạn với việc xác nhận đã thu tiền và chuyển ghế sang đã bán là một thao tác không chia cắt. | Kích hoạt hành động | 9a1a, 9a2 | REQ-134; REQ-22, REQ-32, REQ-47, REQ-48 (phụ) | Mới |
| BR-45 | Từ giờ bắt đầu của suất chiếu, không ai được bắt đầu đặt hoặc mua vé của suất chiếu đó; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | 2, 2c | REQ-135; REQ-61, REQ-86 (phụ) | Mới |
| BR-54 | Việc giữ ghế của một suất chiếu và việc kiểm tra BR-53 rồi sửa hoặc xoá suất chiếu đó không xen vào nhau: nếu giữ ghế được ghi nhận trước thì sửa hoặc xoá bị từ chối theo BR-53; nếu sửa hoặc xoá được ghi nhận trước thì việc giữ ghế trên suất chiếu như tác nhân đã xem lúc chọn ghế bị từ chối vì suất chiếu đã thay đổi hoặc không còn. | Ràng buộc | 7, 7d | REQ-65, REQ-142 | Đã có |
| BR-65 | Giá vé của một lần giữ ghế được chốt cùng lúc với việc giữ ghế (UC-005 bước 7) và giữ nguyên tới hết lần giữ ghế; việc đặt giá, bỏ giá sau đó không đổi giá của lần giữ ghế đó; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | 7, 8, Dữ liệu ra 2 | REQ-149; REQ-37, REQ-38 (phụ) | Đã có |
| BR-66 | Thay đổi bảng giá có hiệu lực ngay khi lưu, áp dụng cho mọi lần chốt giá sau đó, kể cả các suất chiếu đã lập; không hẹn ngày hiệu lực. | Ràng buộc | 7 | REQ-150; REQ-59 (phụ) | Đã có |
| BR-67 | Thay đổi bảng giá không đổi giá của vé đã bán; vé giữ giá đã ghi trên vé. | Suy luận | Dữ liệu ra 3 | REQ-149; REQ-105 (phụ) | Đã có |
| BR-71 | Việc chốt giá của một lần giữ ghế và việc lưu thay đổi bảng giá không xen vào nhau: thay đổi bảng giá được ghi nhận trước thì lần giữ ghế dùng giá mới; thay đổi bảng giá được ghi nhận sau thì không ảnh hưởng lần giữ ghế đó. | Ràng buộc | 7 | REQ-149; REQ-150 (phụ) | Đã có |
| BR-72 | Không được giữ ghế khi bảng giá của cụm rạp không có giá cho một ghế đã chọn, ứng với loại phòng, định dạng phim, loại ghế và khung giờ chiếu của suất chiếu. | Ràng buộc | 7, 7e | REQ-152; REQ-37, REQ-38 (phụ) | Đã có |
| BR-74 | Một ghế đôi là một vị trí dành cho hai người và được bán như một ghế. | Sự kiện | 6, Dữ liệu vào 1 | REQ-17 | Đã có |
| BR-80 | Mã đặt vé là duy nhất trên toàn hệ thống. | Ràng buộc | 13, 9a3, Dữ liệu ra 3 | REQ-106 | Đã có |
| BR-85 | Các báo kết quả thanh toán của cổng thanh toán và mọi thao tác làm đổi trạng thái của cùng một lần giữ ghế (hết hạn, khách huỷ giữ ghế, báo thành công, báo thất bại, xác nhận đã thu tiền của nhân viên quầy) được xử lý tuần tự, khoá theo lần giữ ghế; mỗi thao tác thấy trạng thái do thao tác trước để lại. | Ràng buộc | 7, 7b, 9a1a, 11, 11a, 12, *a | REQ-160; REQ-35, REQ-36, REQ-109, REQ-110, REQ-134 (phụ) | Đã có |
| BR-86 | Lần giữ ghế đã ở trạng thái cuối (Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại) thì trạng thái không thể thay đổi nữa; báo kết quả thanh toán đến sau được xử lý theo trạng thái cuối đó: báo thành công của giao dịch chưa xử lý được hoàn toàn bộ như thanh toán đến trễ (UC-006), báo của giao dịch đã xử lý là báo trùng, báo thất bại chỉ được ghi nhận. | Ràng buộc | 7b, 11a, *a, 12 | REQ-161; REQ-35, REQ-109, REQ-110, REQ-133 (phụ) | Đã có |
| BR-89 | Khi dịch vụ email từ chối hoặc không phản hồi lúc gửi email chứa vé hoặc email thông báo hoàn tiền, vé và khoản hoàn giữ nguyên hiệu lực; hệ thống thử gửi lại vài lần, nếu vẫn lỗi thì ghi log lỗi; không huỷ vé và không hoàn tiền thêm. | Kích hoạt hành động | 14 | REQ-157; REQ-31, REQ-90 (phụ) | Đã có |
| BR-90 | Khi cổng thanh toán từ chối hoặc không trả lời trong 30 giây yêu cầu tạo giao dịch, hệ thống giữ nguyên lần giữ ghế và báo khách chưa tạo được thanh toán; khách thử lại được tới thời điểm hết hạn giữ ghế, tới lúc đó ghế được giải phóng theo UC-005 luồng 7b. Với cổng chỉ nhận địa chỉ thanh toán đã ký, quy tắc này chỉ áp dụng khi hệ thống lỗi trước lúc chuyển khách sang cổng. | Kích hoạt hành động | 10, 10a | REQ-158; REQ-136 (phụ) | Đã có |
| BR-93 | Báo thanh toán thất bại của một giao dịch chỉ làm lần giữ ghế chuyển sang Thanh toán thất bại và giải phóng ghế khi giao dịch đó là giao dịch tạo sau cùng của lần giữ ghế; báo thất bại của giao dịch cũ khi khách đã có giao dịch thanh toán mới hơn chỉ được ghi nhận, lần giữ ghế và ghế giữ nguyên. | Ràng buộc | 11a | REQ-133; REQ-136 (phụ) | Mới |

## 7. Yêu cầu đặc biệt

| STT | Yêu cầu | Nhóm (FURPS+) | REQ |
|---|---|---|---|
| 1 | Thao tác giữ ghế (bước 7) trả kết quả trong không quá 2 giây. | Performance | REQ-75 |
| 2 | Sơ đồ ghế (bước 3) phản ánh việc người khác giữ hoặc mua ghế chậm nhất 3 giây sau khi thay đổi xảy ra. | Performance | REQ-19 |
| 3 | Vào giờ mở bán phim bom tấn, use case phục vụ được tới 1.000 khách cùng thao tác trên một suất chiếu. | Performance | REQ-74 |
| 4 | Ghế hết thời gian giữ (luồng 7b) được giải phóng trong không quá 1 phút sau thời điểm hết hạn. | Performance | REQ-76 |
| 5 | Ghế trở về trống ở luồng 7b, *a, 11a hiện trên sơ đồ ghế của người đang xem chậm nhất 3 giây sau khi ghế trở về trống. | Performance | REQ-119 |

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-01 Khách (tác nhân ghi đầu tiên ở P02). Bước 5 phần kiểm tra đăng nhập và luồng 5a chỉ áp dụng cho khách; nhân viên quầy đã đăng nhập theo tiền điều kiện. Bước 9 đến 15 chỉ áp dụng cho khách; luồng 9a là kịch bản bán vé tại quầy của ACT-02 Nhân viên quầy (P02 U-R10 b).
- Bước 7 gộp việc kiểm tra ghế còn trống và việc giữ ghế thành một thao tác không chia cắt. Lý do: BR-07 và BR-09 đòi hỏi khi nhiều người cùng xác nhận một ghế thì chỉ một người giữ được; nếu kiểm tra và giữ là hai bước tách rời, hai người có thể cùng thấy ghế trống rồi cùng giữ. Cơ chế bảo đảm điều này thuộc bước thiết kế (P07, P09).
- Bước 7 cũng kiểm tra tác nhân không có lần giữ ghế nào chưa kết thúc (BR-04) trong cùng thao tác không chia cắt. Lý do: kiểm tra ở bước 5 và tạo lần giữ ghế ở bước 7 là hai thao tác tách rời; hai yêu cầu đồng thời của cùng một khách (hai tab, hai thiết bị) hoặc cùng một nhân viên quầy đều qua bước 5 rồi cùng giữ ghế, khiến một người có hai lần giữ ghế (REQ-89, REQ-92). Luồng 7c được kiểm trước 7a.
- Lần giữ ghế kết thúc tại thời điểm hết hạn, khi khách hoặc nhân viên quầy huỷ giữ ghế, khi cổng báo thất bại hoặc khi ghế chuyển sang đã bán, không đợi ghế thực sự được giải phóng (REQ-76); mốc này dùng cho BR-04 ở bước 5 và bước 7.
- Lần giữ ghế ở trạng thái Đang giữ từ bước 7 cho tới khi kết thúc ở đúng một trong bốn trạng thái cuối: Đã hoàn tất (bước 12 hoặc 9a2, có vé), Hết hạn (luồng 7b, 9a1a), Đã huỷ (luồng *a), Thanh toán thất bại (luồng 11a) (P05 GL-25, Q-69).
- Các báo kết quả thanh toán, việc hết hạn, việc huỷ giữ ghế và việc xác nhận đã thu tiền của cùng một lần giữ ghế được xử lý tuần tự theo lần giữ ghế (BR-85, trả lời Q-79); lần giữ ghế đã ở trạng thái cuối thì không đổi nữa (BR-86). Báo thành công của cổng tới sau khi lần giữ ghế đã Hết hạn, Đã huỷ hoặc Thanh toán thất bại không thuộc use case này mà được UC-006 hoàn toàn bộ (BR-14, BR-15); báo thành công của giao dịch khác tới sau khi lần giữ ghế Đã hoàn tất cũng vậy (BR-40); báo thất bại tới sau trạng thái cuối chỉ được ghi nhận (BR-39); báo trùng của giao dịch đã tạo vé là báo trùng (BR-37).
- Luồng 10a (trả lời Q-77) nằm trong vùng ngắt IR-7 nên thời điểm hết hạn giữ ghế không đổi khi khách thử lại. Mức chờ 30 giây mượn từ BR-43. Trên activity diagram luồng 10a là ghi chú N-10a không có cạnh, giống N-*a. Nếu cổng đã tạo giao dịch ở lần trước mà hệ thống không nhận được trả lời, lần thử lại tạo giao dịch mới cho cùng lần giữ ghế; giao dịch báo thành công trước được xử lý ở bước 11, 12, giao dịch báo thành công sau được nhận ra qua mã tham chiếu lần giữ ghế và hoàn toàn bộ ở UC-006 (BR-40, BR-85).
- Luồng 1a (trả lời Q-119): lần giữ ghế đang chạy vẫn tồn tại khi tác nhân tải lại trang, đóng tab hoặc không quay lại từ cổng, và BR-04 chặn giữ ghế mới trong lúc đó. Tác nhân mở lại lần giữ ghế để thanh toán hoặc huỷ (luồng *a) bằng lối Tiếp tục thanh toán, không cần giữ ghế lại; thời điểm hết hạn giữ ghế không đổi. Kết quả đặt vé sau khi đóng tab xem qua email; lịch sử đặt vé thuộc UC-007. Trên activity diagram luồng 1a là ghi chú N-1a không có cạnh.
- Luồng 5a2a (trả lời Q-131) dùng một thông báo chung cho mọi trường hợp sai thông tin đăng nhập để không lộ tài khoản nào tồn tại; khoá tài khoản thuộc UC-017. Trên activity diagram là ghi chú N-5a2a không có cạnh.
- Luồng 10b (trả lời Q-126) nằm trong vùng ngắt IR-7 nên thời điểm hết hạn giữ ghế không đổi. Trang quay về chỉ đọc trạng thái giao dịch, không tự tạo vé; vé chỉ tạo ở bước 12 khi cổng báo thành công. Mức 2 giây và 60 giây là giá trị nghiệp vụ của Q-126. Trên activity diagram là ghi chú N-10b không có cạnh.
- Việc xác nhận đã thu tiền ở 9a1 và chuyển ghế sang đã bán ở 9a2 là một thao tác không chia cắt với việc hết hạn giữ ghế; xác nhận tới sau thời điểm hết hạn bị từ chối theo luồng 9a1a: ghế không được chuyển sang đã bán, nhân viên quầy được thông báo trả lại tiền mặt đã thu cho khách (BR-44, trả lời Q-49). Trên activity diagram, thao tác so thời điểm này là decision D-9a1 đặt ngay sau A-9a1.
- Bước 7 kiểm suất chiếu còn tồn tại và chưa bị sửa trong cùng thao tác không chia cắt với việc kiểm ghế và giữ ghế (BR-54, trả lời Q-56). Lý do: ghế khách đang chọn chưa giữ (BR-03) nên REQ-65 của UC-014 (không sửa, xoá suất chiếu đang có ghế được giữ hoặc có vé đã bán chưa bị huỷ) không chặn việc quản lý cụm rạp sửa hoặc xoá suất chiếu trong lúc khách xem sơ đồ ghế; nếu kiểm suất chiếu và giữ ghế tách rời, ghế có thể được giữ cho một suất chiếu vừa bị xoá, hoặc sau khi UC-014 đã kiểm BR-53 và sửa suất chiếu. Bước 7 và việc kiểm BR-53 rồi sửa hoặc xoá ở UC-014 (bước 8, 1b3) loại trừ nhau trên cùng suất chiếu: bên ghi nhận trước thành công, bên sau bị từ chối. "Đã bị sửa" hiểu là mọi thay đổi suất chiếu kể từ lúc bước 3 hiển thị sơ đồ ghế, vì sơ đồ đã hiển thị có thể không còn khớp phòng, giờ mới; luồng 7a quay lại bước 3 nên sơ đồ được hiển thị lại. Luồng 7c kiểm trước 7d, 7d trước 7a.
- Bước 2 kiểm tra thời điểm mở bán, giờ bắt đầu suất chiếu (BR-45) và cụm rạp. Hệ thống ngừng bán từ giờ bắt đầu suất chiếu, kể cả khi bán tại quầy (trả lời Q-50). Việc kiểm tra chỉ ở bước 2, khi bắt đầu một lần đặt: ngừng bán là ngừng nhận lần giữ ghế mới, còn lần giữ ghế đã tạo trước giờ bắt đầu vẫn được hoàn tất theo luồng chính, 9a, 7b hoặc 11a trong tối đa 10 phút của nó (BR-10), nên vé vẫn có thể được tạo sau giờ bắt đầu và điều đó không trái đề bài Mục 16. Ghế trở về trống sau giờ bắt đầu (kể cả từ UC-008 bước 7) không bán lại được vì bước 2 từ chối.
- Thời gian giữ ghế (BR-10) tính từ bước 7. Tới thời điểm hết hạn giữ ghế mà chưa có kết quả thanh toán thành công thì kết thúc ở luồng 7b; trên activity diagram thể hiện bằng vùng ngắt IR-7 và sự kiện thời gian T-7.
- Kết quả thanh toán thành công mà cổng thanh toán báo về sau thời điểm hết hạn giữ ghế không thuộc use case này: UC-006 Hoàn tiền thanh toán trễ xử lý theo BR-14. Mốc quyết định là thời điểm hết hạn, không phải thời điểm ghế thực sự được giải phóng (giải phóng có thể trễ tới 1 phút, REQ-76).
- Bước 11 và bước 12 là một thao tác không chia cắt trên cùng lần giữ ghế: việc so thời điểm nhận báo thanh toán thành công với thời điểm hết hạn giữ ghế (và với việc lần giữ ghế đã bị huỷ hoặc đã có báo thất bại), cùng việc chuyển ghế sang đã bán và tạo vé hoặc đánh dấu giao dịch là thanh toán trễ (UC-006 bước 2, 3), phải xảy ra trong cùng một thao tác theo lần giữ ghế (BR-85). Lý do: nếu hai việc tách rời, hệ thống có thể vừa bán ghế cho giao dịch này vừa giải phóng ghế cho người khác (một ghế hai chủ), hoặc vừa tạo vé vừa hoàn toàn bộ tiền. Mỗi giao dịch thanh toán thành công đi theo đúng một trong hai use case. Cơ chế bảo đảm thuộc bước thiết kế (P07, P09).
- Ghế trở về trống ở luồng 7b, *a, 11a hiện trên sơ đồ ghế trong 3 giây như REQ-19 (REQ-119, Mục 7 dòng 5).
- Kết quả thanh toán thành công mà cổng thanh toán báo về sau khi khách đã huỷ việc giữ ghế (luồng *a) hoặc sau khi đã báo thất bại (luồng 11a), dù trước thời điểm hết hạn, cũng không thuộc use case này: UC-006 xử lý theo BR-15, giống thanh toán đến trễ.
- Giao dịch thứ hai mà cổng báo thành công cho lần giữ ghế đã có vé không tạo thêm vé và được hoàn toàn bộ ở UC-006 (BR-40). Giao dịch đã dùng để tạo vé ở bước 12 mà cổng báo trùng, trong thời gian giữ ghế hay sau thời điểm hết hạn giữ ghế, không tạo vé lần hai và được UC-006 luồng 2a ghi nhận (BR-37). Giao dịch hệ thống không nhận ra được UC-006 luồng 2e ghi log lỗi (BR-38).
- Giá vé lấy theo BR-11 và được xác định ở bước 7, trong cùng thao tác không chia cắt với việc giữ ghế (BR-65, trả lời Q-65): lần giữ ghế luôn đi kèm giá, bước 8 chỉ hiển thị giá đã chốt và bước 10 tạo giao dịch cho tổng tiền đó. Lý do: nếu chốt giá tách khỏi giữ ghế, giá hoặc mục giá có thể đổi giữa hai bước, khiến giá hiển thị khác giá khi giữ ghế. Quản lý cụm rạp đổi giá sau bước 7 không đổi giá của lần giữ ghế đó, kể cả khi cổng thanh toán báo thành công sau đó; việc chốt giá và việc lưu thay đổi bảng giá của UC-013 loại trừ nhau (BR-71). Cơ chế bảo đảm thuộc bước thiết kế (P07, P09).
- UC-014 chặn từ gốc việc lập, sửa suất chiếu khi bảng giá chưa đủ giá (BR-69) và UC-013 không cho bỏ mục giá đang được suất chiếu chưa tới giờ bắt đầu dùng (BR-64), nên thường mọi ghế đều có giá (trả lời Q-61, phương án A). Luồng 7e là lưới an toàn khi bất biến đó vỡ ở nơi khác, chẳng hạn UC-012 sửa phòng chiếu (BR-73): hệ thống không giữ ghế và báo không xác định được giá vé (BR-72). Luồng 7e kiểm sau 7a vì ghế không còn trống thì không cần xét giá.
- Bước 14 chỉ gửi đi, không chờ kết quả. Khi dịch vụ email từ chối hoặc không phản hồi, vé giữ nguyên hiệu lực, hệ thống thử gửi lại vài lần rồi ghi log lỗi, khách vẫn thấy vé trên màn hình (bước 15) và trong lịch sử đặt vé; không huỷ vé, không hoàn tiền thêm (BR-89, trả lời Q-76). Số lần thử lại và khoảng cách giữa hai lần là quyết định thiết kế (P09).
- Bước sinh theo quy tắc của prompt: bước 15 và phần thông báo ở luồng 7b, 11a theo Target 5a (báo kết quả cho tác nhân người); hành động "Từ chối ... và thông báo quy tắc bị vi phạm" ở luồng 2b, 5b, 6a theo F5.7 (luồng 7d từ chối vì suất chiếu đã thay đổi, không nêu quy tắc người dùng sửa được); điểm quay lại bước 4 (6a) và bước 3 (7a) theo F5.7 vì tác nhân sửa được lựa chọn ghế; luồng 7e từ chối vì thiếu giá, tác nhân không sửa được tại chỗ nên kết thúc thất bại.
- Tổng tiền ở bước 8 là tổng giá vé đã chốt của các ghế đã giữ, suy ra trực tiếp từ việc mỗi ghế là một vé có giá theo BR-11 (REQ-30, REQ-38).

## 8a. Kịch bản chính

- KB1: Luồng chính --> khách đặt vé trực tuyến thành công, nhận vé qua email.
- KB2: Luồng chính tới bước 8 + 9a --> nhân viên quầy bán vé tại quầy thành công, in vé.
- KB3: Luồng chính + 7a (có ghế bị người khác giữ trước) --> quay lại bước 3, chọn ghế khác, đặt vé thành công.
- KB4: Luồng chính + 5a (khách chưa đăng nhập) --> đăng nhập rồi đặt vé thành công.
- KB5: Luồng chính + 7b (hết 10 phút chưa thanh toán) --> ghế được giải phóng, không có vé.
- KB6: Luồng chính + 7c (tác nhân đã có lần giữ ghế chưa kết thúc, yêu cầu đồng thời) --> từ chối giữ ghế, không có lần giữ ghế thứ hai.
- KB7: Luồng chính + 2c --> chọn suất chiếu đã bắt đầu, bị từ chối bán vé.
- KB8: Luồng chính tới bước 8 + 9a + 9a1a --> nhân viên quầy xác nhận đã thu tiền sau thời điểm hết hạn, hệ thống từ chối xác nhận và nhân viên quầy trả lại tiền mặt cho khách.
- KB9: Luồng chính + 7d --> quản lý cụm rạp sửa hoặc xoá suất chiếu trong lúc tác nhân xem sơ đồ ghế, tác nhân xác nhận chọn ghế bị từ chối giữ ghế, không có ghế được giữ.
- KB10: Luồng chính + 7e --> bảng giá không có giá cho một ghế đã chọn, tác nhân bị từ chối giữ ghế, không có ghế được giữ.

## 9. Activity diagram

File: diagrams/P04-activity-UC-005.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2, D-2 |
| 1a | N-1a |
| 2a, 2b, 2c | A-2a, A-2b, A-2c, FINAL-1 |
| 3 | M-3, A-3 |
| 4 | M-4, A-4 |
| 5 | M-5, A-5, D-5 |
| 5a1, 5a2 | A-5a1, A-5a2 |
| 5a2a | N-5a2a |
| 5b | A-5b, FINAL-2 |
| 6 | A-6, D-6 |
| 6a | A-6a |
| 7 | A-7, D-7 |
| 7a | A-7a |
| 7c | A-7c, FINAL-7 |
| 7d | A-7d, FINAL-9 |
| 7e | A-7e, FINAL-10 |
| 7b | IR-7, T-7, A-7b, FINAL-3 |
| 8 | A-8 |
| 9 | D-9, A-9 |
| 9a1 đến 9a5 | A-9a1, A-9a2, A-9a3, A-9a4, A-9a5, FINAL-6 |
| 9a1a | D-9a1, A-9a1a, FINAL-8 |
| 10 | A-10 |
| 10a | N-10a |
| 10b | N-10b |
| 11 | A-11, D-11 |
| 11a | A-11a, FINAL-4 |
| 12 | A-12 |
| 13 | A-13 |
| 14 | A-14 |
| 15 | A-15, FINAL-5 |
| *a | N-*a |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-01-02 | Partition | Khách / Nhân viên quầy | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=760 |
| P-ACT-07 | Partition | Cổng thanh toán | - | - | - | x=1320, w=300 |
| N-1a | Note | 1a: Tác nhân đang có lần giữ ghế chạy (tải lại trang, đóng tab hoặc không quay lại từ cổng): hệ thống hiện lối Tiếp tục thanh toán, nạp lại ghế đã giữ, giá và hạn giữ ghế, tiếp tục từ bước 8 | - | P-ACT-01-02 | 1a | x=300, y=45, w=240, h=100 (tương đối partition) |
| INIT | Initial | - | - | P-ACT-01-02 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Chọn suất chiếu cần mua vé | - | P-ACT-01-02 | 1 | x=60, y=130 (tương đối partition) |
| A-2 | Action | Kiểm tra mở bán, giờ bắt đầu và cụm rạp | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2a, 2b, 2c | x=130, y=320 (tương đối partition) |
| A-2b | Action | Từ chối: suất chiếu khác cụm rạp (BR-02) | - | P-SYS | 2b | x=320, y=210 (tương đối partition) |
| A-2a | Action | Từ chối: chưa tới thời điểm mở bán (BR-01) | - | P-SYS | 2a | x=320, y=310 (tương đối partition) |
| A-2c | Action | Từ chối: suất chiếu đã bắt đầu (BR-45) | - | P-SYS | 2c | x=320, y=110 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=610, y=270 (tương đối partition) |
| M-3 | Merge | - | - | P-SYS | 7a | x=130, y=420 (tương đối partition) |
| A-3 | Action | Hiển thị sơ đồ ghế, cập nhật trạng thái | - | P-SYS | 3 | x=60, y=490 (tương đối partition) |
| M-4 | Merge | - | - | P-ACT-01-02 | 6a | x=130, y=590 (tương đối partition) |
| A-4 | Action | Chọn ghế và xác nhận chọn ghế | - | P-ACT-01-02 | 4 | x=60, y=660 (tương đối partition) |
| A-5a2 | Action | Cung cấp thông tin đăng nhập | - | P-ACT-01-02 | 5a2 | x=300, y=760 (tương đối partition) |
| M-5 | Merge | - | - | P-SYS | 5a2 | x=130, y=760 (tương đối partition) |
| N-5a2a | Note | 5a2a: Thông tin đăng nhập sai: thông báo chung, không nêu trường sai, không giới hạn số lần thử, không khoá tạm; khách nhập lại (Q-131) | - | P-ACT-01-02 | 5a2a | x=300, y=840, w=240, h=80 (tương đối partition) |
| A-5 | Action | Kiểm tra đăng nhập và lần giữ ghế | - | P-SYS | 5 | x=60, y=830 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5a, 5b | x=130, y=920 (tương đối partition) |
| A-5a1 | Action | Yêu cầu khách đăng nhập | - | P-SYS | 5a1 | x=320, y=910 (tương đối partition) |
| A-5b | Action | Từ chối: đang có lần giữ ghế (BR-04) | - | P-SYS | 5b | x=320, y=1010 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=610, y=1020 (tương đối partition) |
| A-6 | Action | Kiểm tra số ghế đã chọn | - | P-SYS | 6 | x=60, y=1040 (tương đối partition) |
| D-6 | Decision | - | - | P-SYS | 6a | x=130, y=1130 (tương đối partition) |
| A-6a | Action | Từ chối: vượt số ghế tối đa (BR-05) | - | P-SYS | 6a | x=320, y=1120 (tương đối partition) |
| N-*a | Note | *a: Từ bước 8 tới trước bước 11, tác nhân huỷ việc giữ ghế: hệ thống giải phóng ghế đang giữ, kết thúc (thất bại) | - | P-ACT-01-02 | *a | x=300, y=1140 (tương đối partition) |
| A-7 | Action | Kiểm tra lần giữ ghế, ghế trống, giá và giữ cả nhóm | - | P-SYS | 7 | x=60, y=1210 (tương đối partition) |
| D-7 | Decision | - | - | P-SYS | 7a, 7c, 7d, 7e | x=130, y=1300 (tương đối partition) |
| A-7a | Action | Thông báo ghế không còn trống | - | P-SYS | 7a | x=320, y=1290 (tương đối partition) |
| A-7c | Action | Từ chối: đang có lần giữ ghế (BR-04) | - | P-SYS | 7c | x=320, y=1210 (tương đối partition) |
| FINAL-7 | ActivityFinal | - | - | P-SYS | - | x=560, y=1220 (tương đối partition) |
| A-7d | Action | Từ chối: suất chiếu đã sửa hoặc xoá (BR-54) | - | P-SYS | 7d | x=320, y=1380 (tương đối partition) |
| FINAL-9 | ActivityFinal | - | - | P-SYS | - | x=560, y=1390 (tương đối partition) |
| A-7e | Action | Từ chối: không xác định được giá vé (BR-72) | - | P-SYS | 7e | x=320, y=1470 (tương đối partition) |
| FINAL-10 | ActivityFinal | - | - | P-SYS | - | x=560, y=1480 (tương đối partition) |
| A-8 | Action | Hiển thị ghế đã giữ, giá đã chốt và tổng tiền | - | P-SYS | 8 | x=60, y=1480 (tương đối partition) |
| D-9 | Decision | - | - | P-ACT-01-02 | 9a | x=130, y=1580 (tương đối partition) |
| A-9 | Action | Yêu cầu thanh toán trực tuyến | - | P-ACT-01-02 | 9 | x=60, y=1660 (tương đối partition) |
| A-9a1 | Action | Thu tiền mặt, xác nhận đã thu (BR-13) | - | P-ACT-01-02 | 9a1 | x=300, y=1660 (tương đối partition) |
| A-10 | Action | Tạo giao dịch thanh toán | - | P-SYS | 10 | x=60, y=1760 (tương đối partition) |
| N-10a | Note | 10a: Cổng từ chối hoặc không trả lời yêu cầu tạo giao dịch trong 30 giây: giữ nguyên lần giữ ghế, báo chưa tạo được thanh toán, khách thử lại từ bước 9 | - | P-SYS | 10a | x=60, y=1835, w=240, h=90 (tương đối partition) |
| N-10b | Note | 10b: Khách quay về từ cổng khi chưa có kết quả: hiện đang xác nhận, hỏi lại mỗi 2 giây tối đa 60 giây; quá 60 giây báo chưa xác nhận được, khách quay lại thanh toán từ bước 9; hạn giữ ghế không đổi (Q-126) | - | P-SYS | 10b | x=320, y=1600, w=240, h=100 (tương đối partition) |
| T-7 | AcceptTimeEvent | Sau 10 phút kể từ bước 7 (BR-10) | - | P-SYS | 7b | x=540, y=1840 (tương đối partition) |
| A-11 | Action | Báo kết quả giao dịch | - | P-ACT-07 | 11 | x=60, y=1860 (tương đối partition) |
| D-11 | Decision | - | - | P-SYS | 11a | x=130, y=1980 (tương đối partition) |
| A-11a | Action | Giải phóng ghế, báo thanh toán thất bại | - | P-SYS | 11a | x=320, y=1970 (tương đối partition) |
| A-7b | Action | Giải phóng ghế, báo hết thời gian giữ ghế | - | P-SYS | 7b | x=540, y=1980 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | - | x=610, y=2080 (tương đối partition) |
| FINAL-4 | ActivityFinal | - | - | P-SYS | - | x=390, y=2080 (tương đối partition) |
| A-12 | Action | Chuyển ghế sang đã bán, lưu mã giao dịch, đánh dấu đã xử lý | - | P-SYS | 12 | x=60, y=2060 (tương đối partition) |
| A-13 | Action | Tạo mã đặt vé và vé có mã QR | - | P-SYS | 13 | x=60, y=2160 (tương đối partition) |
| D-9a1 | Decision | - | - | P-SYS | 9a1a | x=540, y=2140 (tương đối partition) |
| A-9a1a | Action | Từ chối xác nhận, báo nhân viên trả lại tiền mặt (BR-44) | - | P-SYS | 9a1a | x=600, y=2122 (tương đối partition) |
| FINAL-8 | ActivityFinal | - | - | P-SYS | - | x=655, y=2230 (tương đối partition) |
| A-9a2 | Action | Chuyển ghế sang đã bán | - | P-SYS | 9a2 | x=320, y=2170 (tương đối partition) |
| A-14 | Action | Gửi vé qua dịch vụ email | - | P-SYS | 14 | x=60, y=2260 (tương đối partition) |
| A-9a3 | Action | Tạo mã đặt vé và vé có mã QR | - | P-SYS | 9a3 | x=320, y=2270 (tương đối partition) |
| A-15 | Action | Thông báo thành công, hiển thị vé | - | P-SYS | 15 | x=60, y=2360 (tương đối partition) |
| A-9a4 | Action | Hiển thị vé để in | - | P-SYS | 9a4 | x=320, y=2370 (tương đối partition) |
| FINAL-5 | ActivityFinal | - | - | P-SYS | - | x=130, y=2470 (tương đối partition) |
| A-9a5 | Action | In vé | - | P-ACT-01-02 | 9a5 | x=300, y=2470 (tương đối partition) |
| FINAL-6 | ActivityFinal | - | - | P-ACT-01-02 | - | x=370, y=2570 (tương đối partition) |
| IR-7 | InterruptibleRegion | - | - | - | 7b | Gồm A-8, D-9, A-9, A-9a1, A-10, A-11, T-7, N-10a, N-10b; x=40, y=1460, w=1560, h=480 (tuyệt đối) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | D-2 | ControlFlow | - | - | - |
| E-04 | D-2 | A-2a | ControlFlow | [chưa mở bán] | - | - |
| E-05 | D-2 | A-2b | ControlFlow | [khác cụm rạp] | - | (840,340); (840,240) |
| E-06 | D-2 | M-3 | ControlFlow | [khác] | - | - |
| E-07 | A-2a | FINAL-1 | ControlFlow | - | - | - |
| E-08 | A-2b | FINAL-1 | ControlFlow | - | - | - |
| E-09 | M-3 | A-3 | ControlFlow | - | - | - |
| E-10 | A-3 | M-4 | ControlFlow | - | - | (150,520) |
| E-11 | M-4 | A-4 | ControlFlow | - | - | - |
| E-12 | A-4 | M-5 | ControlFlow | - | - | (710,690) |
| E-13 | M-5 | A-5 | ControlFlow | - | - | - |
| E-14 | A-5 | D-5 | ControlFlow | - | - | - |
| E-15 | D-5 | A-5a1 | ControlFlow | [chưa đăng nhập] | - | - |
| E-16 | D-5 | A-5b | ControlFlow | [đang giữ ghế khác] | - | (840,940); (840,1040) |
| E-17 | D-5 | A-6 | ControlFlow | [khác] | - | - |
| E-18 | A-5a1 | A-5a2 | ControlFlow | - | - | (970,740); (390,740) |
| E-19 | A-5a2 | M-5 | ControlFlow | - | - | - |
| E-20 | A-5b | FINAL-2 | ControlFlow | - | - | - |
| E-21 | A-6 | D-6 | ControlFlow | - | - | - |
| E-22 | D-6 | A-6a | ControlFlow | [vượt tối đa] | - | - |
| E-23 | D-6 | A-7 | ControlFlow | [khác] | - | - |
| E-24 | A-6a | M-4 | ControlFlow | - | - | (1080,1150); (1080,610) |
| E-25 | A-7 | D-7 | ControlFlow | - | - | - |
| E-26 | D-7 | A-7a | ControlFlow | [không giữ ghế khác, suất không đổi, có ghế không trống] | - | - |
| E-27 | D-7 | A-8 | ControlFlow | [giữ được] | - | - |
| E-28 | A-7a | M-3 | ControlFlow | - | - | (1300,1320); (1300,440) |
| E-29 | A-8 | D-9 | ControlFlow | - | - | (710,1560); (150,1560) |
| E-30 | D-9 | A-9 | ControlFlow | [khách] | - | - |
| E-31 | D-9 | A-9a1 | ControlFlow | [nhân viên quầy] | - | (390,1600) |
| E-32 | A-9 | A-10 | ControlFlow | - | - | (150,1790) |
| E-33 | A-10 | A-11 | ControlFlow | - | - | (1470,1790) |
| E-34 | A-11 | D-11 | ControlFlow | - | Ra khỏi IR-7 | (1470,1950); (710,1950) |
| E-35 | T-7 | A-7b | InterruptingEdge | ngắt | Cạnh ngắt ra khỏi IR-7 | - |
| E-36 | D-11 | A-11a | ControlFlow | [thất bại] | - | - |
| E-37 | D-11 | A-12 | ControlFlow | [thành công] | - | - |
| E-38 | A-7b | FINAL-3 | ControlFlow | - | - | - |
| E-39 | A-11a | FINAL-4 | ControlFlow | - | - | - |
| E-40 | A-12 | A-13 | ControlFlow | - | - | - |
| E-41 | A-9a1 | D-9a1 | ControlFlow | - | Ra khỏi IR-7 | (390,2140); (1120,2140) |
| E-42 | A-13 | A-14 | ControlFlow | - | - | - |
| E-43 | A-9a2 | A-9a3 | ControlFlow | - | - | - |
| E-44 | A-14 | A-15 | ControlFlow | - | - | - |
| E-45 | A-9a3 | A-9a4 | ControlFlow | - | - | - |
| E-46 | A-15 | FINAL-5 | ControlFlow | - | - | - |
| E-47 | A-9a4 | A-9a5 | ControlFlow | - | - | (970,2450); (390,2450) |
| E-48 | A-9a5 | FINAL-6 | ControlFlow | - | - | - |
| E-49 | D-7 | A-7c | ControlFlow | [đang giữ ghế khác] | - | (800,1320); (800,1240) |
| E-50 | A-7c | FINAL-7 | ControlFlow | - | - | - |
| E-51 | D-2 | A-2c | ControlFlow | [đã bắt đầu, không khác cụm rạp] | - | (840,340); (840,140) |
| E-52 | A-2c | FINAL-1 | ControlFlow | - | - | (1190,140) |
| E-53 | D-9a1 | A-9a2 | ControlFlow | [xác nhận trước hết hạn] | - | (1080,2160); (1080,2200) |
| E-54 | D-9a1 | A-9a1a | ControlFlow | [xác nhận sau hết hạn] | - | - |
| E-55 | A-9a1a | FINAL-8 | ControlFlow | - | - | - |
| E-56 | D-7 | A-7d | ControlFlow | [không giữ ghế khác, suất chiếu đã sửa hoặc xoá] | - | (840,1320); (840,1410) |
| E-57 | A-7d | FINAL-9 | ControlFlow | - | - | - |
| E-58 | D-7 | A-7e | ControlFlow | [ghế đều trống, thiếu giá] | - | (840,1320); (840,1500) |
| E-59 | A-7e | FINAL-10 | ControlFlow | - | - | - |

Partition P-ACT-01-02 dùng chung cho ACT-01 Khách và ACT-02 Nhân viên quầy (F10.4); action A-5a2, A-9 chỉ khách thực hiện, A-9a1, A-9a5 chỉ nhân viên quầy thực hiện. ACT-08 Dịch vụ email không có partition vì chỉ nhận thông tin (nằm trong nhãn A-14). D-9a1 đặt trong partition hệ thống, ngoài IR-7, ngay sau A-9a1: hệ thống so thời điểm xác nhận với thời điểm hết hạn (BR-44); A-9a2 chỉ có một cạnh vào từ D-9a1. A-2c đặt phía trên A-2b để cạnh E-28 vào M-3 không cắt qua node.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-24 | Đã trả lời (Liệt kê thông tin cụ thể trên vé; mã đặt vé duy nhất toàn hệ thống, không quy định định dạng), đề bài bổ sung Mục 7. Ngoài mã QR, vé gồm những thông tin nào (phim, suất chiếu, phòng, ghế, giá vé...), và mã đặt vé có định dạng quy định không? (Chỉ mã QR và vị trí ghế / Liệt kê thông tin cụ thể) | Dữ liệu ra 3 của UC-005; UC-009 Soát vé; mô hình dữ liệu P13 | Mục 7 chỉ nêu "mã đặt vé" và "mã QR riêng" |
| Q-25 | Đã trả lời (Không tạo vé, hoàn toàn bộ tiền và báo qua email, xử lý ở UC-006 như thanh toán đến trễ), đề bài bổ sung Mục 9. Nếu cổng thanh toán báo giao dịch thành công sau khi khách đã huỷ việc giữ ghế (luồng *a) hoặc sau khi cổng đã báo thất bại (luồng 11a), nhưng trước thời điểm hết hạn giữ ghế, hệ thống xử lý thế nào? (Hoàn toàn bộ tiền như REQ-35, xử lý ở UC-006 / Phương án khác) | Luồng *a, 11a của UC-005; phạm vi UC-006; BR-14 | Mục 9 chỉ nêu trường hợp thanh toán báo về sau thời điểm hết hạn giữ ghế |
| Q-26 | Đã trả lời (Email theo định dạng chuẩn; số điện thoại Việt Nam 10 chữ số bắt đầu bằng 0), đề bài bổ sung Mục 3. Email và số điện thoại dùng để đăng nhập có quy định định dạng không? (Theo định dạng email chuẩn và số điện thoại Việt Nam 10 chữ số / Chưa quy định) | Dữ liệu vào 2 của UC-005; UC-001 Đăng ký tài khoản | Mục 3 chỉ nêu "đăng ký tài khoản bằng email, số điện thoại và mật khẩu" |
| Q-37 | Đã trả lời (Có, cùng ngưỡng 3 giây), đề bài bổ sung Mục 4. Mọi lần ghế trở về trống (hết hạn giữ ghế luồng 7b, huỷ giữ ghế luồng *a, thanh toán thất bại luồng 11a; huỷ vé ở UC-008 bước 7) có phải hiện lên sơ đồ ghế của người đang xem chậm nhất 3 giây như REQ-19 không? (Có / Không) | Mục 7 Yêu cầu đặc biệt dòng 5; UC-008 Mục 7 | Mục 4 chỉ nêu sơ đồ ghế tự cập nhật khi người khác giữ hoặc mua ghế |
| Q-49 | Đã trả lời (Từ chối xác nhận và thông báo nhân viên trả lại tiền mặt cho khách; so thời điểm hết hạn và chuyển ghế sang đã bán là một thao tác không chia cắt), đề bài bổ sung Mục 12. Nhân viên quầy đã thu tiền mặt của khách nhưng lần giữ ghế đã hết hạn trước khi xác nhận tới hệ thống thì xử lý thế nào? (Từ chối xác nhận và thông báo nhân viên trả lại tiền mặt cho khách / Phương án khác) | Luồng 9a1a, 9a2; Mục 8 | Mục 12 chỉ nêu khách tại quầy trả tiền mặt và xác nhận đã thu tiền, không nêu trường hợp hết hạn |
| Q-50 | Đã trả lời (Ngừng bán từ giờ bắt đầu suất chiếu, áp dụng cả bán tại quầy), đề bài bổ sung Mục 16. Có ngừng bán vé khi suất chiếu đã bắt đầu (hoặc trước giờ bắt đầu một khoảng) không? (Ngừng bán từ giờ bắt đầu suất chiếu / Không giới hạn / Phương án khác) | Bước 2, luồng 2c; UC-008 bước 7 | Mục 16 chỉ nêu thời điểm mở bán, không nêu thời điểm ngừng bán |
| Q-61 | Đã trả lời (Phương án A: UC-014 chặn từ gốc việc lập, sửa suất chiếu khi bảng giá chưa đủ giá, UC-013 không cho bỏ mục giá đang được dùng; UC-005 giữ luồng từ chối làm lưới an toàn), đề bài bổ sung Mục 15, Mục 16. Khi bảng giá thiếu giá cho loại ghế hoặc khung giờ của một ghế đã chọn, hoặc giá bị bỏ sau khi suất chiếu đã lập, UC-005 xử lý thế nào? (Từ chối giữ ghế và thông báo không xác định được giá vé / Phương án khác) | Bước 7, luồng 7e; BR-72; UC-013, UC-014 | Mục 10 nêu giá phụ thuộc bốn yếu tố, Mục 15 không nêu bảng giá phải đủ mọi tổ hợp |
| Q-76 | Đã trả lời (Theo đề xuất: vé giữ nguyên hiệu lực, thử gửi lại vài lần, vẫn lỗi thì ghi log lỗi, không huỷ vé, không hoàn tiền thêm), đề bài bổ sung Mục 21. Khi dịch vụ email từ chối hoặc không phản hồi lúc gửi email chứa vé thì hệ thống xử lý thế nào? | Bước 14; BR-89; P06 NFR-18 | Mục 7, Mục 21 nêu gửi email nhưng không nêu trường hợp gửi không thành công |
| Q-77 | Đã trả lời (Theo đề xuất: giữ nguyên lần giữ ghế, báo khách chưa tạo được thanh toán, khách thử lại tới hết thời gian giữ ghế, mỗi lần chờ cổng tối đa 30 giây), đề bài bổ sung Mục 21. Khi cổng thanh toán từ chối hoặc không trả lời yêu cầu tạo giao dịch thì hệ thống xử lý thế nào? | Bước 10, luồng 10a; BR-90; P06 NFR-15 | Mục 21 chỉ nêu cách xử lý khi cổng từ chối hoặc không trả lời yêu cầu hoàn tiền |
| Q-79 | Đã trả lời (Báo kết quả thanh toán và mọi thao tác đổi trạng thái của cùng một lần giữ ghế xử lý tuần tự theo lần giữ ghế; lần giữ ghế đã ở trạng thái cuối thì không đổi, báo đến sau xử lý theo trạng thái cuối), đề bài bổ sung Mục 9. Hai báo thành công của cùng một giao dịch đến đồng thời, hoặc kết quả đến đúng lúc hết hạn, xử lý thế nào? | Bước 11, 12; BR-85, BR-86; UC-006 bước 2, 3 | Mục 9 không nêu xử lý đồng thời và trạng thái cuối của lần giữ ghế |
| Q-119 | Đã trả lời (khách mở lại lần giữ ghế đang chạy bằng lối Tiếp tục thanh toán; không thêm màn hình; kết quả sau khi đóng tab xem qua email, lịch sử đặt vé chờ UC-007). Khi khách hoặc nhân viên quầy tải lại trang, đóng tab hoặc không quay lại từ cổng trong lúc còn lần giữ ghế (BR-04), mở lại lần giữ ghế đang chạy để thanh toán hoặc huỷ bằng cách nào? | Luồng 1a; BR-04 | UC-005 chỉ mô tả luồng liền mạch, không nêu quay lại lần giữ ghế đang chạy |
| Q-126 | Đã trả lời (trang hiện đang xác nhận thanh toán, hỏi lại mỗi 2 giây, tối đa 60 giây; quá 60 giây báo chưa xác nhận được và cho quay lại thanh toán nếu lần giữ ghế còn Đang giữ; lần giữ ghế chạy tới hết hạn). Khi khách quay về từ cổng mà hệ thống chưa nhận kết quả, trang hiện gì và khách chờ tối đa bao lâu? | Luồng 10b | UC-005 không có luồng cho khách đã quay về mà chưa có kết quả |
| Q-131 | Đã trả lời (một thông báo chung, không giới hạn số lần thử, không khoá tạm trong phạm vi đồ án; khoá tài khoản thuộc UC-017 chưa đặc tả). Khi email, số điện thoại hoặc mật khẩu sai ở luồng 5a2, hệ thống báo gì, cho nhập lại bao nhiêu lần, có khoá tạm không? | Luồng 5a2a | Luồng 5a2 chỉ nêu khách cung cấp thông tin rồi quay lại bước 5, không nêu trường hợp sai |
| Q-139 | Đã trả lời (Theo BR-93: chỉ giao dịch tạo sau cùng của lần giữ ghế mới làm lần giữ ghế chuyển sang Thanh toán thất bại và giải phóng ghế; báo thất bại của giao dịch cũ khi khách đã có giao dịch mới hơn chỉ được ghi nhận, lần giữ ghế và ghế giữ nguyên), nguồn review P12 R12-05 và review cuối RF-04. Khi cổng báo thanh toán thất bại của một giao dịch cũ mà khách đã có giao dịch thanh toán mới hơn cho cùng lần giữ ghế thì hệ thống xử lý thế nào? | Luồng 11a; BR-93; BR-39, BR-86, BR-90 | Đề bài Mục 8 nói chung "cổng thanh toán báo thất bại thì giải phóng ghế", Mục 21 cho thử lại thanh toán nhưng không nêu báo thất bại của giao dịch cũ |

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Phương án A của Q-61 giảm xác suất thiếu giá, không loại bỏ khả năng đó vì UC-012 chưa đặc tả; luồng 7e là lưới an toàn (BR-72).
- Luồng chính có 15 bước, ở mức trên của khoảng 3-15. Không tách được bước nào mà không gộp các kết quả khác bản chất (F4.4).
- Cột hai của bố cục và các cạnh quay lại có điểm uốn ghi trong bảng Edge; còn một số chỗ hai cạnh giao nhau (E-12 với E-18, E-24 với E-20, E-34 với E-35). Không cạnh nào cắt qua node (đã kiểm bằng script theo hình chữ nhật bao của từng node).
- Luồng 7c kiểm trước 7d và 7d trước 7a nên guard của E-56 và E-26 nêu loại trừ [không giữ ghế khác] để không trùng guard [đang giữ ghế khác] của E-49, và guard của E-26 nêu thêm [suất không đổi] để không trùng guard của E-56. Luồng 7e kiểm sau 7a nên guard của E-58 nêu [ghế đều trống]; E-27 [giữ được] là nhánh còn lại.
- Guard của nhánh luồng chính tại D-2, D-5, D-6 ghi "[khác]" (F10.3 cho phép) để nhãn không chồng lên nhau; điều kiện đầy đủ ở bảng luồng thay thế.
