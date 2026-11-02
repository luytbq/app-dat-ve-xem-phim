# P00 - Chuẩn hoá yêu cầu - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P00 |
| Phiên bản | 1.3 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md (đã bổ sung trả lời Q-01 đến Q-23); P00-problem-brief.md 1.2 |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-23 (cấp ở P01); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh và mục tiêu nghiệp vụ

Công ty CineBook vận hành chuỗi 15 cụm rạp chiếu phim tại 5 tỉnh, thành phố, mỗi cụm có từ 4 đến 12 phòng chiếu thuộc ba loại phòng (thường, 4DX, IMAX). Hiện khách chỉ mua vé tại quầy của từng cụm rạp. Vào các dịp phim bom tấn ra mắt, hàng chờ tại quầy rất dài và nhân viên thường bán trùng ghế vì hai quầy cùng bán một suất chiếu trên sơ đồ ghế giấy. Hệ thống phục vụ khách đặt vé trực tuyến và các nhóm nhân viên của chuỗi (quầy, soát vé, quản lý cụm rạp, quản lý chuỗi, quản trị).

Mục tiêu nghiệp vụ:
- Cho phép khách đặt vé trực tuyến tại mọi cụm rạp (nguồn: "cho phép khách đặt vé trực tuyến tại mọi cụm rạp", đoạn mở đầu).
- Giúp nhân viên bán vé tại quầy trên cùng một sơ đồ ghế với khách đặt trực tuyến (nguồn: "giúp nhân viên bán vé tại quầy trên cùng một sơ đồ ghế", đoạn mở đầu).
- Khắc phục tình trạng bán trùng ghế và hàng chờ dài tại quầy (nguồn: "hàng chờ tại quầy rất dài và nhân viên thường bán trùng ghế", đoạn mở đầu).

## 2. Phạm vi

Trong phạm vi:
- Xem phim, thông tin phim và lịch chiếu không cần đăng nhập (REQ-05 đến REQ-10, REQ-95, REQ-96).
- Đăng ký, đăng nhập tài khoản khách (REQ-11, REQ-12).
- Đặt vé trực tuyến: xem sơ đồ ghế, giữ ghế tạm, chống tranh chấp ghế (REQ-13 đến REQ-27, REQ-87 đến REQ-89).
- Thanh toán trực tuyến, tạo vé, gửi vé qua email (REQ-28 đến REQ-31).
- Giải phóng ghế khi hết thời gian giữ, khi khách huỷ, khi thanh toán thất bại; xử lý thanh toán đến trễ (REQ-32 đến REQ-36, REQ-90).
- Giá vé theo bảng giá riêng của từng cụm rạp (REQ-37, REQ-38, REQ-91).
- Xem lịch sử đặt vé, huỷ vé và hoàn tiền (REQ-39 đến REQ-44).
- Bán vé tại quầy, huỷ vé mua tại quầy (REQ-45 đến REQ-49, REQ-81 đến REQ-85, REQ-92).
- Soát vé bằng mã QR (REQ-50 đến REQ-52, REQ-93, REQ-94).
- Quản lý phim, cụm rạp (REQ-53 đến REQ-55, REQ-95, REQ-96).
- Quản lý phòng chiếu, sơ đồ ghế, bảng giá của cụm rạp (REQ-56 đến REQ-59).
- Lập lịch suất chiếu, thời điểm mở bán (REQ-60 đến REQ-65, REQ-86, REQ-97, REQ-98).
- Báo cáo doanh thu và tỉ lệ lấp đầy (REQ-66 đến REQ-69, REQ-99).
- Quản trị tài khoản nhân viên, phân quyền, đăng nhập nhân viên và quản trị viên (REQ-70 đến REQ-72, REQ-100 đến REQ-104).

Ngoài phạm vi:
- Cổng thanh toán của đối tác: hệ thống khác, hệ thống này chỉ gọi API tạo giao dịch, hoàn tiền và nhận thông báo kết quả (REQ-79, "Cổng thanh toán của đối tác cung cấp API...", Mục 21).
- Dịch vụ email bên ngoài: hệ thống khác, hệ thống này chỉ gửi email qua dịch vụ đó (REQ-80, "Hệ thống gửi email qua dịch vụ email bên ngoài", Mục 21).

Chờ Q-nn: Không có.

## 3. Các bên liên quan và người dùng

| SH | Bên liên quan | Loại | Quan tâm chính, lợi ích | Tương tác trực tiếp với hệ thống (Có / Không / Chưa rõ) | REQ |
|---|---|---|---|---|---|
| SH-01 | Công ty CineBook | Chủ sở hữu, người đặt hàng | Bán vé trực tuyến tại mọi cụm rạp, chấm dứt bán trùng ghế | Không | Đoạn mở đầu |
| SH-02 | Khách (xem phim, đặt vé trực tuyến) | Người dùng trực tiếp | Xem lịch chiếu, chọn ghế, thanh toán nhanh, không bị mất ghế đã chọn | Có | REQ-05 đến REQ-44, REQ-87 đến REQ-90 |
| SH-03 | Nhân viên quầy | Người dùng trực tiếp | Bán vé tại quầy không trùng ghế với khách đặt trực tuyến | Có | REQ-45 đến REQ-49, REQ-81 đến REQ-85, REQ-92 |
| SH-04 | Cổng thanh toán của đối tác | Hệ thống hoặc thiết bị ngoài | Tạo giao dịch, báo kết quả, hoàn tiền | Có | REQ-28, REQ-29, REQ-34, REQ-35, REQ-43, REQ-79 |
| SH-05 | Dịch vụ email bên ngoài | Hệ thống hoặc thiết bị ngoài | Chuyển email chứa vé, email thông báo hoàn tiền tới khách | Có | REQ-31, REQ-80, REQ-90 |
| SH-06 | Khách mua vé tại quầy | Người hưởng lợi gián tiếp | Mua vé trực tiếp, trả tiền mặt, nhận vé in, huỷ vé tại quầy | Không | REQ-45, REQ-47, REQ-83 đến REQ-85 |
| SH-07 | Máy in thông thường của máy tính tại quầy | Hệ thống hoặc thiết bị ngoài | In vé cho khách mua tại quầy | Không (máy in của máy tính, không có giao tiếp riêng với phần mềm) | REQ-49 |
| SH-08 | Nhân viên soát vé | Người dùng trực tiếp | Soát vé đúng suất, mỗi vé chỉ vào một lần | Có | REQ-50 đến REQ-52, REQ-93, REQ-94 |
| SH-09 | Camera của thiết bị soát vé | Hệ thống hoặc thiết bị ngoài | Đọc mã QR trên vé khi soát vé | Không (camera của thiết bị nhân viên dùng, không có giao tiếp riêng với phần mềm) | REQ-50 |
| SH-10 | Quản lý chuỗi | Người vận hành, quản trị | Quản lý phim, cụm rạp; xem báo cáo toàn chuỗi | Có | REQ-53 đến REQ-55, REQ-68, REQ-69, REQ-95 |
| SH-11 | Quản lý cụm rạp | Người vận hành, quản trị | Quản lý phòng chiếu, bảng giá, suất chiếu; xem báo cáo của cụm | Có | REQ-56 đến REQ-67, REQ-86, REQ-97, REQ-98 |
| SH-12 | Quản trị viên | Người vận hành, quản trị | Quản lý tài khoản nhân viên, gán cụm rạp, phân quyền | Có | REQ-70 đến REQ-72, REQ-100 đến REQ-104 |

## 4. Danh sách yêu cầu

| REQ | Nội dung chuẩn hoá | Loại | Trích nguồn | Ghi chú |
|---|---|---|---|---|
| REQ-01 | Chuỗi CineBook gồm 15 cụm rạp tại 5 tỉnh, thành phố; mỗi cụm rạp có từ 4 đến 12 phòng chiếu. | Dữ liệu | "chuỗi 15 cụm rạp chiếu phim tại 5 tỉnh, thành phố. Mỗi cụm rạp có từ 4 đến 12 phòng chiếu" (đoạn mở đầu) | Số liệu quy mô |
| REQ-02 | Mỗi phòng chiếu thuộc một loại phòng trong ba loại: phòng thường, 4DX, IMAX. | Dữ liệu | "Mỗi phòng chiếu thuộc một loại phòng: phòng thường, 4DX hoặc IMAX" (đoạn mở đầu) | Không có |
| REQ-03 | Mỗi phòng chiếu có sức chứa từ 50 đến 400 ghế. | Dữ liệu | "có sức chứa từ 50 đến 400 ghế tuỳ phòng" (đoạn mở đầu) | Số liệu quy mô. Cách đếm ghế đôi ở REQ-87 |
| REQ-04 | Toàn chuỗi chiếu khoảng 500 suất chiếu mỗi ngày. | Dữ liệu | "Toàn chuỗi chiếu khoảng 500 suất mỗi ngày" (đoạn mở đầu) | Số liệu quy mô |
| REQ-05 | Khách có thể xem danh sách phim đang chiếu và phim sắp chiếu mà không cần đăng nhập. | Chức năng | "Khách có thể xem danh sách phim đang chiếu và sắp chiếu ... mà không cần đăng nhập" (Mục 1) | Cách xác định đang chiếu, sắp chiếu ở REQ-96. Đã trả lời Q-04 |
| REQ-06 | Khách có thể xem thông tin của một phim mà không cần đăng nhập. | Chức năng | "thông tin phim ... mà không cần đăng nhập" (Mục 1) | Thành phần thông tin ở REQ-07 |
| REQ-07 | Thông tin phim gồm tên, thể loại, thời lượng, độ tuổi được xem, mô tả và trailer. | Dữ liệu | "thông tin phim (tên, thể loại, thời lượng, độ tuổi được xem, mô tả, trailer)" (Mục 1) | Tách từ cùng câu với REQ-06 |
| REQ-08 | Khách có thể chọn một phim để xem các suất chiếu của phim đó ở các cụm rạp mà không cần đăng nhập. | Chức năng | "chọn phim rồi xem các suất chiếu của phim đó ở các cụm rạp" (Mục 2) | Không có |
| REQ-09 | Khách có thể chọn một cụm rạp để xem các suất chiếu tại cụm rạp đó mà không cần đăng nhập. | Chức năng | "chọn cụm rạp rồi xem các suất chiếu tại cụm rạp đó" (Mục 2) | Tách từ cùng câu với REQ-08 |
| REQ-10 | Khách có thể lọc lịch chiếu theo tỉnh, thành phố, theo ngày, theo loại phòng và theo định dạng phim. | Chức năng | "Khách có thể lọc lịch chiếu theo tỉnh, thành phố, theo ngày, theo loại phòng và theo định dạng phim" (Mục 2) | Chưa tách theo tiêu chí lọc vì nguồn không phân biệt |
| REQ-11 | Khách có thể đăng ký tài khoản bằng email, số điện thoại và mật khẩu. | Chức năng | "Khách đăng ký tài khoản bằng email, số điện thoại và mật khẩu" (Mục 3) | Không có |
| REQ-12 | Khách có thể đăng nhập bằng email hoặc số điện thoại cùng mật khẩu. | Chức năng | "Khách đăng nhập bằng email hoặc số điện thoại cùng mật khẩu" (Mục 3) | Đã trả lời Q-21 |
| REQ-13 | Khách đã đăng nhập có thể đặt vé cho một suất chiếu. | Chức năng | "Khách phải đăng nhập mới được đặt vé" (Mục 3)<br>"phải đăng nhập trước khi xác nhận chọn ghế" (Mục 4) | Không có |
| REQ-14 | Khách có thể xem sơ đồ ghế của phòng chiếu cho suất chiếu đã chọn mà không cần đăng nhập. | Chức năng | "khách chọn một suất chiếu và xem sơ đồ ghế của phòng chiếu" (Mục 4)<br>"Khách xem sơ đồ ghế không cần đăng nhập" (Mục 4) | Đã trả lời Q-18 |
| REQ-15 | Mỗi ghế của một suất chiếu có một trong ba trạng thái: trống, đang được giữ, đã bán. | Dữ liệu | "mỗi ghế hiển thị một trong ba trạng thái: trống, đang được giữ, đã bán" (Mục 4) | Không có |
| REQ-16 | Ghế có ba loại: ghế thường, ghế VIP và ghế đôi. | Dữ liệu | "Ghế có ba loại: ghế thường, ghế VIP và ghế đôi" (Mục 4) | Không có |
| REQ-17 | Một ghế đôi là một vị trí dành cho hai người và được bán như một ghế. | Quy tắc nghiệp vụ | "Một ghế đôi là một vị trí dành cho hai người và được bán như một ghế" (Mục 4) | Cách đếm ở REQ-87 |
| REQ-18 | Hệ thống cập nhật sơ đồ ghế đang hiển thị cho khách khi người khác giữ hoặc mua ghế của cùng suất chiếu. | Chức năng | "Sơ đồ ghế tự cập nhật khi người khác giữ hoặc mua ghế" (Mục 4) | Ngưỡng ở REQ-19 |
| REQ-19 | Sơ đồ ghế phản ánh việc người khác giữ hoặc mua ghế chậm nhất 3 giây sau khi thay đổi xảy ra. | Phi chức năng | "chậm nhất 3 giây sau khi thay đổi xảy ra" (Mục 4) | Tách từ cùng câu với REQ-18. Đã trả lời Q-15 |
| REQ-20 | Mỗi lần đặt vé, khách chọn tối đa 8 ghế. | Quy tắc nghiệp vụ | "Khách chọn tối đa 8 ghế cho một lần đặt" (Mục 5) | Cách đếm ghế đôi ở REQ-87 |
| REQ-21 | Hệ thống giữ tạm cả nhóm ghế khách đã chọn khi khách xác nhận chọn ghế. | Chức năng | "chỉ khi khách xác nhận chọn ghế, hệ thống mới giữ tạm cả nhóm ghế đó cho khách" (Mục 5) | Thời hạn ở REQ-22. Thời điểm giữ ở REQ-88 |
| REQ-22 | Thời gian giữ ghế tạm cho khách là 10 phút. | Quy tắc nghiệp vụ | "giữ tạm cả nhóm ghế đó cho khách trong 10 phút" (Mục 5) | Tách từ cùng câu với REQ-21 |
| REQ-23 | Ghế đang được giữ cho một khách thì không người nào khác được chọn ghế đó. | Quy tắc nghiệp vụ | "Trong thời gian giữ, không ai khác được chọn các ghế này" (Mục 5) | Không có |
| REQ-24 | Việc giữ ghế chỉ thành công khi tất cả các ghế khách chọn đều còn trống; nếu có ghế không còn trống thì không ghế nào được giữ. | Quy tắc nghiệp vụ | "Việc giữ ghế chỉ thành công khi tất cả các ghế khách chọn đều còn trống; nếu có ghế đã bị người khác giữ hoặc mua trước, ... không giữ ghế nào" (Mục 5) | Không có |
| REQ-25 | Hệ thống báo cho khách khi việc giữ ghế không thành công vì có ghế đã bị người khác giữ hoặc mua trước. | Chức năng | "nếu có ghế đã bị người khác giữ hoặc mua trước, hệ thống báo cho khách" (Mục 5)<br>"những khách còn lại nhận thông báo ghế không còn trống" (Mục 6) | Tách từ cùng câu với REQ-24. Gộp ý trùng ở Mục 6 |
| REQ-26 | Một ghế của một suất chiếu chỉ được bán cho đúng một người. | Quy tắc nghiệp vụ | "Một ghế của một suất chiếu chỉ được bán cho đúng một người" (Mục 6) | Không có |
| REQ-27 | Khi nhiều khách cùng lúc xác nhận chọn cùng một ghế, chỉ một khách giữ được ghế đó. | Quy tắc nghiệp vụ | "Khi nhiều khách cùng lúc xác nhận chọn cùng một ghế, chỉ một khách giữ được ghế đó" (Mục 6) | Thông báo cho khách còn lại ở REQ-25. Đã trả lời Q-06 |
| REQ-28 | Khách có thể thanh toán trực tuyến qua cổng thanh toán cho các ghế đang giữ trong thời gian giữ ghế. | Chức năng | "Trong thời gian giữ ghế, khách thanh toán trực tuyến qua cổng thanh toán" (Mục 7) | Kênh: cổng thanh toán (REQ-79) |
| REQ-29 | Hệ thống chuyển các ghế đang giữ sang trạng thái đã bán khi cổng thanh toán báo thanh toán thành công trong thời gian giữ ghế. | Chức năng | "Khi cổng thanh toán báo thành công, hệ thống chuyển các ghế sang trạng thái đã bán" (Mục 7) | Kênh: cổng thanh toán (REQ-79). Trường hợp báo sau thời điểm hết hạn ở REQ-35, REQ-36 |
| REQ-30 | Hệ thống tạo một mã đặt vé cho lần đặt và cho mỗi ghế một vé có mã QR riêng khi cổng thanh toán báo thanh toán thành công. | Chức năng | "tạo một mã đặt vé cho lần đặt và cho mỗi ghế một vé có mã QR riêng" (Mục 7) | Tách từ cùng câu với REQ-29. Đã trả lời Q-05 |
| REQ-31 | Hệ thống gửi các vé qua email cho khách sau khi tạo vé. | Chức năng | "và gửi các vé qua email cho khách" (Mục 7) | Kênh: dịch vụ email (REQ-80) |
| REQ-32 | Hệ thống giải phóng các ghế đang giữ về trạng thái trống khi hết thời gian giữ ghế ở REQ-22 mà khách chưa thanh toán thành công. | Chức năng | "Nếu hết 10 phút mà khách chưa thanh toán thành công ... hệ thống giải phóng các ghế đang giữ về trạng thái trống" (Mục 8) | Độ trễ ở REQ-76 |
| REQ-33 | Khách có thể huỷ việc giữ ghế để giải phóng các ghế đang giữ về trạng thái trống. | Chức năng | "hoặc khách chủ động huỷ ... hệ thống giải phóng các ghế đang giữ" (Mục 8) | Không có |
| REQ-34 | Hệ thống giải phóng các ghế đang giữ về trạng thái trống khi cổng thanh toán báo thanh toán thất bại. | Chức năng | "hoặc cổng thanh toán báo thất bại, hệ thống giải phóng các ghế đang giữ" (Mục 8) | Kênh: cổng thanh toán (REQ-79) |
| REQ-35 | Hệ thống hoàn toàn bộ số tiền đã thanh toán cho khách qua cổng thanh toán khi nhận được báo thanh toán thành công sau thời điểm hết hạn giữ ghế, kể cả khi ghế chưa được giải phóng. | Chức năng | "Nếu hệ thống nhận được báo thanh toán thành công sau thời điểm hết hạn giữ ghế, kể cả khi ghế chưa được giải phóng, hệ thống ... hoàn toàn bộ số tiền cho khách qua cổng thanh toán" (Mục 9) | Kênh: cổng thanh toán (REQ-79). Đã trả lời Q-08, Q-09 |
| REQ-36 | Thanh toán thành công được báo sau thời điểm hết hạn giữ ghế thì không tạo vé, kể cả khi ghế chưa được giải phóng. | Quy tắc nghiệp vụ | "hệ thống không tạo vé" (Mục 9) | Tách từ cùng câu với REQ-35. Đã trả lời Q-08 |
| REQ-37 | Mỗi cụm rạp có bảng giá riêng. | Quy tắc nghiệp vụ | "Mỗi cụm rạp có bảng giá riêng" (Mục 10) | Không có |
| REQ-38 | Giá vé phụ thuộc loại phòng, định dạng phim, loại ghế và khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi; ngày thường hoặc cuối tuần). | Quy tắc nghiệp vụ | "Giá vé phụ thuộc loại phòng, định dạng phim, loại ghế và khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi, ngày thường hoặc cuối tuần)" (Mục 10) | Cách xác định khung giờ ở REQ-91 |
| REQ-39 | Khách có thể xem lịch sử đặt vé và các vé của mình. | Chức năng | "Khách có thể xem lịch sử đặt vé và vé của mình" (Mục 11) | Chưa tách vì nguồn không phân biệt |
| REQ-40 | Khách có thể huỷ từng vé đã mua trực tuyến. | Chức năng | "Khách có thể huỷ từng vé đã mua" (Mục 11) | Vé mua tại quầy huỷ theo REQ-83 |
| REQ-41 | Khách chỉ được huỷ vé trước giờ chiếu ít nhất 2 tiếng. | Quy tắc nghiệp vụ | "trước giờ chiếu ít nhất 2 tiếng" (Mục 11) | Tách từ cùng câu với REQ-40 |
| REQ-42 | Vé bị khách huỷ được hoàn 70% giá vé. | Quy tắc nghiệp vụ | "hệ thống hoàn 70% giá vé" (Mục 11) | Ảnh hưởng doanh thu theo REQ-99 |
| REQ-43 | Hệ thống hoàn tiền của vé bị khách huỷ qua cổng thanh toán. | Chức năng | "hoàn 70% giá vé qua cổng thanh toán" (Mục 11) | Mức hoàn ở REQ-42. Kênh: cổng thanh toán (REQ-79) |
| REQ-44 | Hệ thống trả ghế của vé bị huỷ về trạng thái trống. | Chức năng | "và trả ghế về trạng thái trống" (Mục 11)<br>"và hệ thống trả ghế về trạng thái trống" (Mục 12) | Tách từ cùng câu với REQ-43. Áp dụng cả vé mua tại quầy (REQ-83) |
| REQ-45 | Nhân viên quầy của một cụm rạp có thể bán vé các suất chiếu tại cụm rạp đó cho khách mua trực tiếp. | Chức năng | "Nhân viên quầy của một cụm rạp bán vé cho khách mua trực tiếp các suất chiếu tại cụm rạp đó" (Mục 12) | Không có |
| REQ-46 | Việc bán vé tại quầy dùng chung sơ đồ ghế với đặt vé trực tuyến và áp dụng cùng quy tắc giữ ghế: tối đa 8 ghế mỗi lần, giữ trong 10 phút, giữ tất cả hoặc không ghế nào. | Quy tắc nghiệp vụ | "trên cùng sơ đồ ghế với khách đặt trực tuyến, áp dụng cùng quy tắc giữ ghế (tối đa 8 ghế mỗi lần, giữ trong 10 phút, giữ tất cả hoặc không ghế nào)" (Mục 12) | Quy tắc gốc ở REQ-20, REQ-22, REQ-24. Đã trả lời Q-10 |
| REQ-47 | Khách mua vé tại quầy trả bằng tiền mặt. | Quy tắc nghiệp vụ | "Khách tại quầy trả tiền mặt" (Mục 12) | Không có |
| REQ-48 | Nhân viên quầy có thể xác nhận đã thu tiền của khách mua tại quầy. | Chức năng | "Khi nhân viên xác nhận đã thu tiền" (Mục 12) | Kết quả ở REQ-81, REQ-82 |
| REQ-49 | Nhân viên quầy có thể in vé cho khách mua tại quầy. | Chức năng | "rồi nhân viên in vé bằng máy in thông thường của máy tính tại quầy" (Mục 12) | Thiết bị không kết nối riêng: máy in thông thường của máy tính tại quầy. Đã trả lời Q-22 |
| REQ-50 | Nhân viên soát vé của một cụm rạp có thể quét mã QR trên vé trước cửa phòng chiếu để soát vé. | Chức năng | "rồi quét mã QR trên vé bằng camera của thiết bị trước cửa phòng chiếu" (Mục 13) | Thiết bị không kết nối riêng: camera của thiết bị soát vé. Đã trả lời Q-22 |
| REQ-51 | Vé được soát là hợp lệ khi vé thuộc cụm rạp của nhân viên soát vé, thuộc suất chiếu nhân viên đã chọn, chưa được sử dụng và chưa bị huỷ; mỗi vé chỉ được soát một lần. | Quy tắc nghiệp vụ | "Hệ thống kiểm tra vé thuộc cụm rạp đó, thuộc suất chiếu nhân viên đã chọn, chưa được sử dụng và chưa bị huỷ" (Mục 13)<br>"Mỗi vé chỉ được soát một lần" (Mục 13) | Gộp câu trùng ý "Mỗi vé chỉ được soát một lần". Đã trả lời Q-13 |
| REQ-52 | Hệ thống đánh dấu vé đã sử dụng khi vé được soát là hợp lệ. | Chức năng | "rồi đánh dấu vé đã sử dụng" (Mục 13) | Không có |
| REQ-53 | Quản lý chuỗi có thể quản lý danh sách phim. | Chức năng | "Quản lý chuỗi quản lý danh sách phim" (Mục 14) | Chưa tách thao tác vì nguồn không phân biệt |
| REQ-54 | Quản lý chuỗi có thể quản lý danh sách cụm rạp. | Chức năng | "và danh sách cụm rạp" (Mục 14) | Chưa tách thao tác vì nguồn không phân biệt |
| REQ-55 | Mỗi phim được phát hành ở một hoặc nhiều định dạng trong hai định dạng 2D, 3D. | Dữ liệu | "Mỗi phim được phát hành ở một hoặc nhiều định dạng: 2D, 3D" (Mục 14) | Không có |
| REQ-56 | Quản lý cụm rạp có thể quản lý các phòng chiếu của cụm rạp mình. | Chức năng | "Quản lý cụm rạp quản lý các phòng chiếu của cụm mình" (Mục 15) | Chưa tách thao tác vì nguồn không phân biệt |
| REQ-57 | Phòng chiếu gồm loại phòng, sức chứa, các định dạng phim mà phòng chiếu được và sơ đồ ghế. | Dữ liệu | "loại phòng, sức chứa, các định dạng phim mà phòng chiếu được và sơ đồ ghế của từng phòng" (Mục 15) | Tách từ cùng câu với REQ-56. Cách đếm ghế đôi ở REQ-87 |
| REQ-58 | Không được sửa sơ đồ ghế của phòng chiếu đang có suất chiếu chưa diễn ra đã bán vé hoặc có ghế đang được giữ. | Quy tắc nghiệp vụ | "Không được sửa sơ đồ ghế của phòng đang có suất chiếu chưa diễn ra đã bán vé hoặc có ghế đang được giữ" (Mục 15) | Đã trả lời Q-12 |
| REQ-59 | Quản lý cụm rạp có thể thiết lập bảng giá của cụm rạp mình. | Chức năng | "Quản lý cụm rạp thiết lập bảng giá của cụm mình" (Mục 15) | Quy tắc giá ở REQ-37, REQ-38, REQ-91 |
| REQ-60 | Quản lý cụm rạp có thể lập lịch suất chiếu cho các phòng chiếu của cụm rạp mình. | Chức năng | "Quản lý cụm rạp lập lịch suất chiếu cho các phòng của cụm mình" (Mục 16) | Thao tác sửa, xoá suất chiếu suy từ REQ-65. Thời điểm mở bán là một thành phần của suất chiếu (REQ-61) |
| REQ-61 | Suất chiếu gồm phim, định dạng, phòng chiếu, ngày giờ bắt đầu và thời điểm mở bán. | Dữ liệu | "Mỗi suất chiếu gồm phim, định dạng, phòng, ngày giờ bắt đầu và thời điểm mở bán" (Mục 16) | Đã trả lời Q-03 |
| REQ-62 | Định dạng của suất chiếu phải là một định dạng phát hành của phim. | Quy tắc nghiệp vụ | "Định dạng của suất chiếu phải là một định dạng phát hành của phim" (Mục 16) | Không có |
| REQ-63 | Phòng chiếu của suất chiếu phải chiếu được định dạng của suất chiếu. | Quy tắc nghiệp vụ | "và phòng phải chiếu được định dạng đó" (Mục 16) | Tách từ cùng câu với REQ-62 |
| REQ-64 | Hai suất chiếu trong cùng một phòng chiếu phải cách nhau ít nhất 15 phút dọn phòng, tính từ giờ kết thúc của suất trước. | Quy tắc nghiệp vụ | "Hai suất chiếu trong cùng một phòng phải cách nhau ít nhất 15 phút dọn phòng, tính từ giờ kết thúc của suất trước" (Mục 16) | Giờ kết thúc ở REQ-98. Đã trả lời Q-17 |
| REQ-65 | Không được sửa hoặc xoá suất chiếu đang có ghế được giữ hoặc có vé đã bán chưa bị huỷ. | Quy tắc nghiệp vụ | "Không được sửa hoặc xoá suất chiếu đang có ghế được giữ hoặc có vé đã bán chưa bị huỷ" (Mục 16) | Đã trả lời Q-11 |
| REQ-66 | Quản lý cụm rạp có thể xem báo cáo doanh thu của cụm rạp mình theo ngày, theo phim và theo suất chiếu. | Chức năng | "Quản lý cụm rạp xem báo cáo doanh thu và tỉ lệ lấp đầy ghế của cụm mình theo ngày, theo phim và theo suất chiếu" (Mục 17) | Cách tính doanh thu ở REQ-99 |
| REQ-67 | Quản lý cụm rạp có thể xem báo cáo tỉ lệ lấp đầy ghế của cụm rạp mình theo ngày, theo phim và theo suất chiếu. | Chức năng | "báo cáo ... tỉ lệ lấp đầy ghế của cụm mình theo ngày, theo phim và theo suất chiếu" (Mục 17) | Tách từ cùng câu với REQ-66. Cách đếm ghế đôi ở REQ-87 |
| REQ-68 | Quản lý chuỗi có thể xem báo cáo doanh thu và báo cáo tỉ lệ lấp đầy ghế cho toàn chuỗi. | Chức năng | "Quản lý chuỗi xem các báo cáo này cho toàn chuỗi" (Mục 17) | Chưa tách vì nguồn gọi chung "các báo cáo này" |
| REQ-69 | Quản lý chuỗi có thể so sánh báo cáo doanh thu và tỉ lệ lấp đầy ghế giữa các cụm rạp. | Chức năng | "và so sánh giữa các cụm rạp" (Mục 17) | Tách từ cùng câu với REQ-68 |
| REQ-70 | Quản trị viên có thể quản lý tài khoản nhân viên. | Chức năng | "Quản trị viên quản lý tài khoản nhân viên" (Mục 18) | Chưa tách thao tác vì nguồn không phân biệt |
| REQ-71 | Quản trị viên có thể gán nhân viên vào cụm rạp. | Chức năng | "gán nhân viên vào cụm rạp" (Mục 18) | Quy tắc gán ở REQ-100 |
| REQ-72 | Quản trị viên có thể phân quyền nhân viên theo vai trò: nhân viên quầy, nhân viên soát vé, quản lý cụm rạp, quản lý chuỗi. | Chức năng | "phân quyền theo vai trò (nhân viên quầy, nhân viên soát vé, quản lý cụm rạp, quản lý chuỗi)" (Mục 18) | Quy tắc vai trò ở REQ-101 |
| REQ-73 | Vào giờ mở bán phim bom tấn, hệ thống phục vụ được 4.000 khách truy cập đồng thời trên toàn chuỗi. | Phi chức năng | "Vào giờ mở bán phim bom tấn, hệ thống phải phục vụ được 4.000 khách truy cập đồng thời trên toàn chuỗi" (Mục 19) | "Giờ mở bán" là thời điểm mở bán của suất chiếu (REQ-61, REQ-86) |
| REQ-74 | Vào giờ mở bán phim bom tấn, hệ thống phục vụ được tới 1.000 khách cùng thao tác trên một suất chiếu. | Phi chức năng | "trong đó có thể tới 1.000 khách cùng thao tác trên một suất chiếu" (Mục 19) | Tách từ cùng câu với REQ-73 |
| REQ-75 | Thao tác giữ ghế trả kết quả trong không quá 2 giây. | Phi chức năng | "Thao tác giữ ghế phải trả kết quả trong không quá 2 giây" (Mục 19) | Không có |
| REQ-76 | Ghế hết thời gian giữ được giải phóng trong không quá 1 phút sau thời điểm hết hạn. | Phi chức năng | "Ghế hết thời gian giữ phải được giải phóng trong không quá 1 phút sau thời điểm hết hạn" (Mục 19) | Thanh toán báo về trong khoảng trễ này xử lý theo REQ-35, REQ-36 |
| REQ-77 | Hệ thống không được lưu thông tin thẻ thanh toán của khách. | Ràng buộc | "Hệ thống không lưu thông tin thẻ thanh toán của khách" (Mục 20) | Không có |
| REQ-78 | Hệ thống lưu mã giao dịch do cổng thanh toán cấp. | Dữ liệu | "chỉ lưu mã giao dịch do cổng thanh toán cấp" (Mục 20) | Tách từ cùng câu với REQ-77 |
| REQ-79 | Hệ thống trao đổi yêu cầu tạo giao dịch, kết quả giao dịch (callback) và yêu cầu hoàn tiền với cổng thanh toán của đối tác để thu và hoàn tiền vé. | Giao tiếp ngoài | "Cổng thanh toán của đối tác cung cấp API tạo giao dịch, thông báo kết quả giao dịch về hệ thống (callback) và hoàn tiền" (Mục 21)<br>"Cổng thanh toán trực tuyến (môi trường sandbox, API tạo giao dịch, callback kết quả, hoàn tiền)" (project-profile.md, HE_THONG_NGOAI) | Hồ sơ dự án ghi môi trường sandbox |
| REQ-80 | Hệ thống gửi email cho khách qua dịch vụ email bên ngoài. | Giao tiếp ngoài | "Hệ thống gửi email qua dịch vụ email bên ngoài" (Mục 21)<br>"Dịch vụ gửi email (SMTP)" (project-profile.md, HE_THONG_NGOAI) | Hồ sơ dự án ghi giao thức SMTP |
| REQ-81 | Hệ thống chuyển các ghế đang giữ sang trạng thái đã bán khi nhân viên quầy xác nhận đã thu tiền. | Chức năng | "Khi nhân viên xác nhận đã thu tiền, hệ thống chuyển các ghế sang trạng thái đã bán" (Mục 12) | Bổ sung ở phiên bản 1.1 theo trả lời Q-01 |
| REQ-82 | Hệ thống tạo vé cho các ghế bán tại quầy như với đặt vé trực tuyến: một mã đặt vé cho lần bán và cho mỗi ghế một vé có mã QR riêng. | Chức năng | "và tạo vé như với đặt vé trực tuyến" (Mục 12) | Bổ sung ở phiên bản 1.1 theo trả lời Q-01. Cách tạo vé ở REQ-30 |
| REQ-83 | Nhân viên quầy của cụm rạp đã bán vé có thể huỷ vé mua tại quầy. | Chức năng | "Vé mua tại quầy được huỷ tại quầy của cụm rạp đã bán vé" (Mục 12) | Bổ sung ở phiên bản 1.1 theo trả lời Q-02. Trả ghế về trống theo REQ-44 |
| REQ-84 | Vé mua tại quầy chỉ được huỷ trước giờ chiếu ít nhất 2 tiếng. | Quy tắc nghiệp vụ | "trước giờ chiếu ít nhất 2 tiếng" (Mục 12) | Bổ sung ở phiên bản 1.1 theo trả lời Q-02. Tách từ cùng câu với REQ-83 |
| REQ-85 | Vé mua tại quầy bị huỷ được nhân viên quầy hoàn 70% giá vé bằng tiền mặt. | Quy tắc nghiệp vụ | "nhân viên quầy hoàn 70% giá vé bằng tiền mặt" (Mục 12) | Bổ sung ở phiên bản 1.1 theo trả lời Q-02. Tách từ cùng câu với REQ-83 |
| REQ-86 | Trước thời điểm mở bán của suất chiếu, không ai được đặt hoặc mua vé của suất chiếu đó. | Quy tắc nghiệp vụ | "Trước thời điểm mở bán, không ai đặt hoặc mua được vé của suất chiếu đó" (Mục 16) | Bổ sung ở phiên bản 1.1 theo trả lời Q-03. Áp dụng cho cả khách đặt trực tuyến và nhân viên quầy |
| REQ-87 | Ghế đôi được tính là một ghế khi đếm giới hạn số ghế mỗi lần đặt, sức chứa phòng và tỉ lệ lấp đầy. | Quy tắc nghiệp vụ | "ghế đôi được tính là một ghế trong mọi phép đếm (giới hạn số ghế mỗi lần đặt, sức chứa phòng, tỉ lệ lấp đầy)" (Mục 4) | Bổ sung ở phiên bản 1.2 theo trả lời Q-14 |
| REQ-88 | Ghế khách đang chọn trên sơ đồ vẫn ở trạng thái trống cho tới khi khách xác nhận chọn ghế. | Quy tắc nghiệp vụ | "Ghế khách đang chọn trên sơ đồ vẫn ở trạng thái trống; chỉ khi khách xác nhận chọn ghế, hệ thống mới giữ tạm" (Mục 5) | Bổ sung ở phiên bản 1.2 theo trả lời Q-06 |
| REQ-89 | Tại một thời điểm, mỗi khách có tối đa một lần giữ ghế chưa kết thúc. | Quy tắc nghiệp vụ | "Tại một thời điểm, mỗi khách chỉ có tối đa một lần giữ ghế chưa kết thúc" (Mục 5) | Bổ sung ở phiên bản 1.2 theo trả lời Q-07 |
| REQ-90 | Hệ thống gửi email thông báo hoàn tiền cho khách khi hoàn tiền theo REQ-35. | Chức năng | "và gửi email thông báo hoàn tiền cho khách" (Mục 9) | Bổ sung ở phiên bản 1.2 theo trả lời Q-09. Kênh: dịch vụ email (REQ-80) |
| REQ-91 | Khung giờ chiếu tính theo giờ bắt đầu của suất chiếu; cuối tuần gồm Thứ Bảy và Chủ nhật. | Quy tắc nghiệp vụ | "Khung giờ chiếu tính theo giờ bắt đầu của suất chiếu; cuối tuần gồm Thứ Bảy và Chủ nhật" (Mục 10) | Bổ sung ở phiên bản 1.2 theo trả lời Q-16 |
| REQ-92 | Tại một thời điểm, mỗi nhân viên quầy có tối đa một lần giữ ghế chưa kết thúc. | Quy tắc nghiệp vụ | "Tại một thời điểm, mỗi nhân viên quầy chỉ có tối đa một lần giữ ghế chưa kết thúc" (Mục 12) | Bổ sung ở phiên bản 1.2 theo trả lời Q-07, Q-10 |
| REQ-93 | Nhân viên soát vé có thể chọn suất chiếu đang soát trước khi quét vé. | Chức năng | "Nhân viên soát vé của một cụm rạp chọn suất chiếu đang soát" (Mục 13) | Bổ sung ở phiên bản 1.2 theo trả lời Q-13 |
| REQ-94 | Hệ thống báo lý do cho nhân viên soát vé khi vé được soát không hợp lệ. | Chức năng | "Nếu vé không hợp lệ, hệ thống báo lý do cho nhân viên soát vé" (Mục 13) | Bổ sung ở phiên bản 1.2 theo trả lời Q-13 |
| REQ-95 | Mỗi phim có ngày khởi chiếu và ngày kết thúc chiếu. | Dữ liệu | "Mỗi phim có ngày khởi chiếu và ngày kết thúc chiếu" (Mục 14) | Bổ sung ở phiên bản 1.2 theo trả lời Q-04. Do quản lý chuỗi nhập khi quản lý phim (REQ-53) |
| REQ-96 | Phim sắp chiếu là phim chưa tới ngày khởi chiếu; phim đang chiếu là phim đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu. | Quy tắc nghiệp vụ | "Phim sắp chiếu là phim chưa tới ngày khởi chiếu; phim đang chiếu là phim đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu" (Mục 14) | Bổ sung ở phiên bản 1.2 theo trả lời Q-04 |
| REQ-97 | Ngày chiếu của suất chiếu phải nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của phim. | Quy tắc nghiệp vụ | "Ngày chiếu của suất chiếu phải nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của phim" (Mục 16) | Bổ sung ở phiên bản 1.2, đi kèm trả lời Q-04 |
| REQ-98 | Giờ kết thúc của suất chiếu bằng giờ bắt đầu cộng thời lượng phim. | Quy tắc nghiệp vụ | "Giờ kết thúc của suất chiếu bằng giờ bắt đầu cộng thời lượng phim" (Mục 16) | Bổ sung ở phiên bản 1.2 theo trả lời Q-17 |
| REQ-99 | Doanh thu gồm tiền vé đã bán trừ phần tiền đã hoàn cho khách. | Quy tắc nghiệp vụ | "Doanh thu gồm tiền vé đã bán trừ phần tiền đã hoàn cho khách" (Mục 17) | Bổ sung ở phiên bản 1.2 theo trả lời Q-19 |
| REQ-100 | Mỗi nhân viên quầy, nhân viên soát vé và quản lý cụm rạp thuộc đúng một cụm rạp; quản lý chuỗi không thuộc cụm rạp nào. | Quy tắc nghiệp vụ | "Mỗi nhân viên quầy, nhân viên soát vé và quản lý cụm rạp thuộc đúng một cụm rạp; quản lý chuỗi không thuộc cụm rạp nào" (Mục 18) | Bổ sung ở phiên bản 1.2 theo trả lời Q-20 |
| REQ-101 | Mỗi nhân viên có đúng một vai trò. | Quy tắc nghiệp vụ | "Mỗi nhân viên có đúng một vai trò" (Mục 18) | Bổ sung ở phiên bản 1.2 theo trả lời Q-20 |
| REQ-102 | Nhân viên có thể đăng nhập bằng tài khoản do quản trị viên tạo. | Chức năng | "Nhân viên đăng nhập bằng tài khoản do quản trị viên tạo" (Mục 18) | Bổ sung ở phiên bản 1.2 theo trả lời Q-21 |
| REQ-103 | Tài khoản quản trị viên có sẵn khi cài đặt hệ thống, không do ai tạo qua hệ thống. | Ràng buộc | "Tài khoản quản trị viên có sẵn khi cài đặt hệ thống, không do ai tạo qua hệ thống" (Mục 18) | Bổ sung ở phiên bản 1.3 theo trả lời Q-23 (P01) |
| REQ-104 | Quản trị viên có thể đăng nhập bằng tài khoản quản trị viên có sẵn. | Chức năng | "quản trị viên đăng nhập bằng tài khoản đó" (Mục 18) | Bổ sung ở phiên bản 1.3 theo trả lời Q-23 (P01) |

## 5. Vấn đề chất lượng của tài liệu nguồn

| STT | Loại vấn đề | REQ liên quan | Bằng chứng (câu trích) | Hướng xử lý | Q / ASM |
|---|---|---|---|---|---|
| 1 | Thiếu | REQ-45, REQ-48, REQ-49 | "nhân viên xác nhận đã thu tiền và in vé" (Mục 12, bản đề trước phiên bản 1.1) | Đã xử lý: đề bài bổ sung Mục 12, tạo REQ-81, REQ-82 | Q-01 |
| 2 | Thiếu | REQ-40 đến REQ-44, REQ-47 | "hệ thống hoàn 70% giá vé qua cổng thanh toán" (Mục 11); "Khách tại quầy trả tiền mặt" (Mục 12) | Đã xử lý: đề bài bổ sung Mục 12, tạo REQ-83 đến REQ-85 | Q-02 |
| 3 | Mơ hồ | REQ-61, REQ-73 | "Vào giờ mở bán phim bom tấn" (Mục 19) | Đã xử lý: đề bài bổ sung Mục 16, sửa REQ-61, tạo REQ-86 | Q-03 |
| 4 | Mơ hồ | REQ-05, REQ-53 | "danh sách phim đang chiếu và sắp chiếu" (Mục 1) | Đã xử lý: đề bài bổ sung Mục 14, Mục 16, tạo REQ-95 đến REQ-97 | Q-04 |
| 5 | Mơ hồ | REQ-30, REQ-40, REQ-50 | "tạo vé có mã đặt vé và mã QR" (Mục 7, bản đề trước phiên bản 1.1) | Đã xử lý: đề bài sửa Mục 7, Mục 11, sửa REQ-30, REQ-40 | Q-05 |
| 6 | Mơ hồ | REQ-21, REQ-27 | "Khi khách xác nhận chọn ghế, hệ thống giữ tạm" (Mục 5); "Khi nhiều khách cùng lúc chọn cùng một ghế" (Mục 6, bản đề trước phiên bản 1.2) | Đã xử lý: đề bài sửa Mục 5, Mục 6, tạo REQ-88 | Q-06 |
| 7 | Thiếu | REQ-20, REQ-21 | "Khách chọn tối đa 8 ghế cho một lần đặt" (Mục 5) | Đã xử lý: đề bài bổ sung Mục 5, Mục 12, tạo REQ-89, REQ-92 | Q-07 |
| 8 | Thiếu | REQ-29, REQ-32, REQ-35, REQ-36, REQ-76 | "sau khi thời gian giữ ghế đã hết và ghế đã được giải phóng" (Mục 9, bản đề trước phiên bản 1.2) | Đã xử lý: đề bài sửa Mục 9, mốc quyết định là thời điểm hết hạn; sửa REQ-35, REQ-36 | Q-08 |
| 9 | Thiếu | REQ-35 | "hệ thống không tạo vé và hoàn tiền cho khách" (Mục 9, bản đề trước phiên bản 1.2) | Đã xử lý: hoàn toàn bộ, tạo REQ-90 gửi email thông báo | Q-09 |
| 10 | Mơ hồ | REQ-46 | "áp dụng cùng quy tắc giữ ghế" (Mục 12) | Đã xử lý: đề bài liệt kê rõ các quy tắc áp dụng, sửa REQ-46 | Q-10 |
| 11 | Thiếu | REQ-65 | "Không được sửa hoặc xoá suất chiếu đã có vé bán ra" (Mục 16, bản đề trước phiên bản 1.2) | Đã xử lý: đề bài sửa Mục 16, sửa REQ-65 | Q-11 |
| 12 | Mơ hồ | REQ-58 | "phòng đang có suất chiếu đã bán vé" (Mục 15, bản đề trước phiên bản 1.2) | Đã xử lý: đề bài sửa Mục 15, sửa REQ-58 | Q-12 |
| 13 | Mơ hồ | REQ-50, REQ-51 | "Hệ thống kiểm tra vé thuộc cụm rạp đó, đúng suất chiếu" (Mục 13, bản đề trước phiên bản 1.2) | Đã xử lý: đề bài sửa Mục 13, sửa REQ-51, tạo REQ-93, REQ-94 | Q-13 |
| 14 | Mơ hồ | REQ-03, REQ-17, REQ-20, REQ-57, REQ-67 | "Một ghế đôi là một vị trí dành cho hai người và được bán như một ghế" (Mục 4) | Đã xử lý: đề bài bổ sung Mục 4, tạo REQ-87 | Q-14 |
| 15 | Không kiểm chứng được | REQ-19 | "cập nhật theo thời gian thực" (Mục 4, bản đề trước phiên bản 1.2) | Đã xử lý: đề bài nêu ngưỡng 3 giây, sửa REQ-19 | Q-15 |
| 16 | Mơ hồ | REQ-38 | "khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi, ngày thường hoặc cuối tuần)" (Mục 10) | Đã xử lý: đề bài bổ sung Mục 10, tạo REQ-91 | Q-16 |
| 17 | Mơ hồ | REQ-64 | "cách nhau ít nhất 15 phút dọn phòng" (Mục 16) | Đã xử lý: đề bài bổ sung Mục 16, sửa REQ-64, tạo REQ-98 | Q-17 |
| 18 | Mơ hồ | REQ-14 | "Để đặt vé, khách chọn một suất chiếu và xem sơ đồ ghế" (Mục 4) | Đã xử lý: đề bài bổ sung Mục 4, sửa REQ-14 | Q-18 |
| 19 | Mơ hồ | REQ-42, REQ-66 | "báo cáo doanh thu" (Mục 17) | Đã xử lý: đề bài bổ sung Mục 17, tạo REQ-99 | Q-19 |
| 20 | Thiếu | REQ-71, REQ-72 | "gán nhân viên vào cụm rạp và phân quyền theo vai trò" (Mục 18) | Đã xử lý: đề bài bổ sung Mục 18, tạo REQ-100, REQ-101 | Q-20 |
| 21 | Thiếu | REQ-12, REQ-70 | "Khách phải đăng nhập mới được đặt vé" (Mục 3); "Quản trị viên quản lý tài khoản nhân viên" (Mục 18) | Đã xử lý: đề bài bổ sung Mục 3, Mục 18, sửa REQ-12, tạo REQ-102 | Q-21 |
| 22 | Thiếu | REQ-49, REQ-50 | "in vé" (Mục 12); "quét mã QR trên vé" (Mục 13) | Đã xử lý: đề bài nêu máy in thông thường và camera thiết bị, không có giao tiếp riêng | Q-22 |
| 23 | Trùng lặp | REQ-25 | "hệ thống báo cho khách" (Mục 5); "những khách còn lại nhận thông báo ghế không còn trống" (Mục 6) | Gộp vào REQ-25, không cần hỏi | Không có |
| 24 | Trùng lặp | REQ-51 | "chưa được sử dụng" (Mục 13); "Mỗi vé chỉ được soát một lần" (Mục 13) | Gộp vào REQ-51, không cần hỏi | Không có |

## 6. Ma trận phủ nguồn

| Vị trí trong nguồn | Tóm tắt nội dung | Kết luận |
|---|---|---|
| Đoạn mở đầu, câu 1-2 | 15 cụm rạp, 5 tỉnh, 4-12 phòng mỗi cụm | REQ-01 |
| Đoạn mở đầu, câu 3 | Loại phòng, sức chứa 50-400 ghế | REQ-02, REQ-03 |
| Đoạn mở đầu, câu 4 | Khoảng 500 suất mỗi ngày | REQ-04 |
| Đoạn mở đầu, câu 5-6 | Hiện bán tại quầy, hàng chờ dài, bán trùng ghế | Bối cảnh |
| Đoạn mở đầu, câu 7 | Cần đặt vé trực tuyến và bán tại quầy trên cùng sơ đồ ghế | Bối cảnh (mục tiêu); chức năng ở REQ-13, REQ-45, REQ-46 |
| Mục 1 | Xem danh sách phim, thông tin phim không cần đăng nhập | REQ-05, REQ-06, REQ-07 |
| Mục 2 | Xem lịch chiếu theo phim, theo cụm rạp; lọc | REQ-08, REQ-09, REQ-10 |
| Mục 3 | Đăng ký; đăng nhập bằng email hoặc số điện thoại; phải đăng nhập để đặt vé | REQ-11, REQ-12, REQ-13 |
| Mục 4, câu 1 | Chọn suất chiếu, xem sơ đồ ghế, ba trạng thái ghế | REQ-13, REQ-14, REQ-15 |
| Mục 4, câu 2 | Xem sơ đồ ghế không cần đăng nhập, đăng nhập trước khi xác nhận | REQ-14, REQ-13 |
| Mục 4, câu 3-4 | Ba loại ghế; ghế đôi; cách đếm ghế đôi | REQ-16, REQ-17, REQ-87 |
| Mục 4, câu 5 | Sơ đồ ghế tự cập nhật trong 3 giây | REQ-18, REQ-19 |
| Mục 5, câu 1 | Tối đa 8 ghế mỗi lần đặt | REQ-20 |
| Mục 5, câu 2 | Ghế đang chọn vẫn trống; giữ cả nhóm 10 phút khi xác nhận | REQ-88, REQ-21, REQ-22 |
| Mục 5, câu 3 | Ghế đang giữ không ai khác chọn được | REQ-23 |
| Mục 5, câu 4 | Giữ tất cả hoặc không; báo cho khách | REQ-24, REQ-25 |
| Mục 5, câu 5 | Mỗi khách tối đa một lần giữ ghế chưa kết thúc | REQ-89 |
| Mục 6, câu 1 | Một ghế chỉ bán cho một người | REQ-26 |
| Mục 6, câu 2 | Nhiều khách cùng xác nhận một ghế, chỉ một người giữ được | REQ-27, REQ-25 |
| Mục 7 | Thanh toán trực tuyến, chuyển đã bán, tạo mã đặt vé và mỗi ghế một vé, gửi email | REQ-28, REQ-29, REQ-30, REQ-31 |
| Mục 8 | Giải phóng ghế khi hết hạn, khi khách huỷ, khi thanh toán thất bại | REQ-32, REQ-33, REQ-34 |
| Mục 9 | Thanh toán báo về sau thời điểm hết hạn: không tạo vé, hoàn toàn bộ, gửi email | REQ-35, REQ-36, REQ-90 |
| Mục 10 | Bảng giá riêng từng cụm; các yếu tố quyết định giá; cách xác định khung giờ | REQ-37, REQ-38, REQ-91 |
| Mục 11, câu 1 | Xem lịch sử đặt vé và vé | REQ-39 |
| Mục 11, câu 2 | Huỷ từng vé trước 2 tiếng, hoàn 70%, trả ghế | REQ-40, REQ-41, REQ-42, REQ-43, REQ-44 |
| Mục 12, câu 1 | Bán vé tại quầy, cùng sơ đồ ghế, cùng quy tắc giữ ghế | REQ-45, REQ-46 |
| Mục 12, câu 2 | Mỗi nhân viên quầy tối đa một lần giữ ghế chưa kết thúc | REQ-92 |
| Mục 12, câu 3 | Khách tại quầy trả tiền mặt | REQ-47 |
| Mục 12, câu 4 | Xác nhận thu tiền, chuyển đã bán, tạo vé, in vé bằng máy in thông thường | REQ-48, REQ-81, REQ-82, REQ-49 |
| Mục 12, câu 5 | Huỷ vé mua tại quầy trước 2 tiếng, hoàn 70% tiền mặt, trả ghế | REQ-83, REQ-84, REQ-85, REQ-44 |
| Mục 13, câu 1 | Chọn suất chiếu đang soát, quét mã QR bằng camera | REQ-93, REQ-50 |
| Mục 13, câu 2-3 | Điều kiện hợp lệ, đánh dấu đã sử dụng, soát một lần | REQ-51, REQ-52 |
| Mục 13, câu 4 | Báo lý do khi vé không hợp lệ | REQ-94 |
| Mục 14 | Quản lý phim, cụm rạp; định dạng phát hành; ngày khởi chiếu, ngày kết thúc chiếu; đang chiếu, sắp chiếu | REQ-53, REQ-54, REQ-55, REQ-95, REQ-96 |
| Mục 15 | Quản lý phòng chiếu, sơ đồ ghế, ràng buộc sửa sơ đồ, bảng giá cụm | REQ-56, REQ-57, REQ-58, REQ-59 |
| Mục 16 | Lập lịch suất chiếu, thời điểm mở bán, khoảng ngày chiếu, định dạng, giờ kết thúc, dọn phòng, ràng buộc sửa xoá | REQ-60 đến REQ-65, REQ-86, REQ-97, REQ-98 |
| Mục 17 | Báo cáo của cụm rạp; báo cáo toàn chuỗi, so sánh cụm; cách tính doanh thu | REQ-66, REQ-67, REQ-68, REQ-69, REQ-99 |
| Mục 18 | Quản lý tài khoản nhân viên, gán cụm, phân quyền; quy tắc gán, vai trò; đăng nhập nhân viên; tài khoản và đăng nhập quản trị viên | REQ-70, REQ-71, REQ-72, REQ-100 đến REQ-104 |
| Mục 19 | Tải đồng thời, thời gian giữ ghế, độ trễ giải phóng | REQ-73, REQ-74, REQ-75, REQ-76 |
| Mục 20 | Không lưu thẻ, chỉ lưu mã giao dịch | REQ-77, REQ-78 |
| Mục 21 | API cổng thanh toán; dịch vụ email | REQ-79, REQ-80; Ngoài phạm vi (cổng thanh toán, dịch vụ email là hệ thống khác) |
| project-profile.md, HE_THONG_NGOAI: cổng thanh toán | Sandbox, API tạo giao dịch, callback, hoàn tiền | REQ-79 |
| project-profile.md, HE_THONG_NGOAI: dịch vụ email | SMTP | REQ-80 |
| project-profile.md, mục 4 | Không có ràng buộc đặc thù | Không có |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-01 | Đã trả lời (Có), đề bài bổ sung Mục 12. Khi nhân viên quầy xác nhận đã thu tiền, hệ thống có chuyển ghế sang đã bán và tạo vé có mã đặt vé, mã QR như đặt trực tuyến không? | REQ-81, REQ-82 | Mục 12 |
| Q-02 | Đã trả lời (Huỷ tại quầy, hoàn 70% bằng tiền mặt, trước giờ chiếu ít nhất 2 tiếng), đề bài bổ sung Mục 12. Vé mua tại quầy bằng tiền mặt có được huỷ không? | REQ-83 đến REQ-85 | Mục 11, Mục 12 |
| Q-03 | Đã trả lời (Có), đề bài bổ sung Mục 16. Suất chiếu có thời điểm mở bán, trước thời điểm đó không đặt được vé không? | REQ-61, REQ-86 | Mục 16, Mục 19 |
| Q-04 | Đã trả lời (Theo ngày khởi chiếu và ngày kết thúc chiếu do quản lý chuỗi nhập), đề bài bổ sung Mục 14, Mục 16. Phim đang chiếu và sắp chiếu được xác định thế nào? | REQ-95, REQ-96, REQ-97 | Mục 1 |
| Q-05 | Đã trả lời (Một vé mỗi ghế, huỷ được từng vé), đề bài sửa Mục 7, Mục 11. Một vé ứng với một ghế hay một lần đặt? | REQ-30, REQ-40 | Mục 7, Mục 11 |
| Q-06 | Đã trả lời (Cả nhóm khi xác nhận), đề bài sửa Mục 5, Mục 6. Ghế chuyển sang đang được giữ khi bấm từng ghế hay khi xác nhận cả nhóm? | REQ-21, REQ-27, REQ-88 | Mục 5, Mục 6 |
| Q-07 | Đã trả lời (Mỗi khách, mỗi nhân viên quầy tối đa một lần giữ ghế chưa kết thúc), đề bài bổ sung Mục 5, Mục 12. Một khách có được giữ ghế ở nhiều lần đặt cùng lúc không? | REQ-89, REQ-92 | Mục 5 |
| Q-08 | Đã trả lời (Hoàn tiền; mốc là thời điểm hết hạn, kể cả khi ghế chưa được giải phóng), đề bài sửa Mục 9. Thanh toán báo về trong khoảng trễ giải phóng thì tạo vé hay hoàn tiền? | REQ-35, REQ-36 | Mục 9, Mục 19 |
| Q-09 | Đã trả lời (Hoàn toàn bộ, có email thông báo), đề bài sửa Mục 9. Số tiền hoàn và thông báo cho khách ở trường hợp thanh toán đến trễ? | REQ-35, REQ-90 | Mục 9 |
| Q-10 | Đã trả lời (Có cả thời hạn 10 phút và giới hạn 8 ghế), đề bài sửa Mục 12. "Cùng quy tắc giữ ghế" tại quầy gồm những quy tắc nào? | REQ-46 | Mục 12 |
| Q-11 | Đã trả lời (Không được sửa, xoá khi có ghế đang giữ hoặc vé đã bán chưa huỷ), đề bài sửa Mục 16. Suất chiếu có ghế đang giữ hoặc vé đã huỷ hết có được sửa, xoá không? | REQ-65 | Mục 16 |
| Q-12 | Đã trả lời (Chỉ suất chưa diễn ra, tính cả ghế đang giữ), đề bài sửa Mục 15. Phạm vi "phòng đang có suất chiếu đã bán vé"? | REQ-58 | Mục 15 |
| Q-13 | Đã trả lời (Nhân viên chọn suất trước khi quét; hệ thống báo lý do khi vé không hợp lệ), đề bài sửa Mục 13. Hệ thống xác định suất chiếu đang soát thế nào? | REQ-51, REQ-93, REQ-94 | Mục 13 |
| Q-14 | Đã trả lời (Tính là một ghế trong mọi phép đếm), đề bài bổ sung Mục 4. Ghế đôi tính 1 hay 2? | REQ-87 | Mục 4 |
| Q-15 | Đã trả lời (Không quá 3 giây), đề bài sửa Mục 4. Ngưỡng "thời gian thực" của sơ đồ ghế? | REQ-19 | Mục 4 |
| Q-16 | Đã trả lời (Theo giờ bắt đầu; cuối tuần là Thứ Bảy, Chủ nhật), đề bài bổ sung Mục 10. Cách xác định khung giờ chiếu? | REQ-91 | Mục 10 |
| Q-17 | Đã trả lời (Giờ kết thúc bằng giờ bắt đầu cộng thời lượng phim), đề bài bổ sung Mục 16. Mốc tính 15 phút dọn phòng? | REQ-64, REQ-98 | Mục 16 |
| Q-18 | Đã trả lời (Không cần đăng nhập để xem; đăng nhập trước khi xác nhận chọn ghế), đề bài bổ sung Mục 4. Xem sơ đồ ghế có cần đăng nhập? | REQ-13, REQ-14 | Mục 3, Mục 4 |
| Q-19 | Đã trả lời (Doanh thu bằng tiền bán trừ tiền đã hoàn), đề bài bổ sung Mục 17. Cách tính doanh thu khi có vé huỷ? | REQ-99 | Mục 17 |
| Q-20 | Đã trả lời (Nhân viên cụm thuộc đúng một cụm, quản lý chuỗi không thuộc cụm, mỗi nhân viên một vai trò), đề bài bổ sung Mục 18. Quy tắc gán cụm rạp và vai trò? | REQ-100, REQ-101 | Mục 18 |
| Q-21 | Đã trả lời (Khách đăng nhập bằng email hoặc số điện thoại; nhân viên dùng tài khoản do quản trị viên tạo), đề bài bổ sung Mục 3, Mục 18. Cách đăng nhập? | REQ-12, REQ-102 | Mục 3, Mục 18 |
| Q-22 | Đã trả lời (Máy in thông thường, camera thiết bị; không có giao tiếp riêng), đề bài sửa Mục 12, Mục 13. Máy in vé và thiết bị quét QR có kết nối với phần mềm không? | REQ-49, REQ-50 | Mục 12, Mục 13 |

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- REQ-81 đến REQ-104 được cấp mã tiếp nối mã lớn nhất của phiên bản trước theo quy tắc giữ mã khi chạy lại, nên thứ tự mã không còn trùng thứ tự xuất hiện trong nguồn. Ma trận phủ nguồn ghi đúng vị trí của từng REQ.
- Đề bài sau phiên bản 1.3 có 104 REQ, vượt mức tham khảo 80 REQ của bước. Phần lớn là REQ Quy tắc nghiệp vụ tách từ các ngưỡng định lượng (quy tắc tách 5 của F2), không phải do tách quá nhỏ.
