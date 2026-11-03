# P04 - Đặc tả use case UC-013 Quản lý bảng giá - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md (đã bổ sung trả lời Q-61 đến Q-67); P00-problem-brief.md 1.10; P01-actors.md 1.1; P02-usecases.md 1.8; P03-usecase-model.md 1.0; _BR-register.md (đã gộp BR-01 đến BR-73); UC-005-book-tickets.md 1.7, UC-014-schedule-showtimes.md 1.2 (điểm nối); _review-UC-013.md (R13-01 đến R13-15) |
| Phạm vi | UC-013 |
| Mã Q, ASM cuối đã cấp | Q-67 (Q-61 đến Q-67 đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-013 |
| Tên use case | Quản lý bảng giá (Manage Price List) |
| Tác nhân chính | ACT-04 Quản lý cụm rạp |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý cụm rạp và hệ thống khi quản lý cụm rạp muốn đặt giá vé hoặc bỏ giá vé trong bảng giá của cụm rạp mình. Kết quả là bảng giá của cụm rạp có giá vé cho từng tổ hợp loại phòng, định dạng phim, loại ghế và khung giờ chiếu mà quản lý cụm rạp đã thiết lập, dùng để tính giá vé khi đặt và bán vé. |
| Sự kiện kích hoạt | Cụm rạp thay đổi giá vé (EV-15) |
| Tiền điều kiện | Quản lý cụm rạp đã đăng nhập và đang có phiên làm việc (REQ-102).<br>Quản lý cụm rạp thuộc đúng một cụm rạp (REQ-100). |
| Hậu điều kiện (thành công) | Khi kết thúc ở luồng chính: bảng giá của cụm rạp có đúng một mục giá cho tổ hợp đã chọn, với giá vé quản lý cụm rạp đã nhập; mục giá có hiệu lực ngay (BR-66).<br>Khi kết thúc ở luồng 1a: bảng giá của cụm rạp không còn mục giá đã chọn.<br>Trong cả hai trường hợp, giá của các lần giữ ghế đang có và giá của các vé đã bán không đổi (BR-65, BR-67). |
| Hậu điều kiện tối thiểu | Khi use case kết thúc thất bại, bảng giá của cụm rạp không thay đổi. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-37, REQ-38, REQ-59, REQ-91 (theo P02); REQ-146 đến REQ-151 (P02 Mục 5 đã gắn UC-013); REQ-102 (tiền điều kiện; P02 ghi "-"); REQ-100 (tham chiếu, UC-017); REQ-02, REQ-57 (tham chiếu, UC-012: loại phòng); REQ-55 (tham chiếu, UC-010: định dạng); REQ-16, REQ-17, REQ-87 (tham chiếu, UC-005: loại ghế, ghế đôi); REQ-105, REQ-111 (tham chiếu, UC-005); REQ-42, REQ-85 (tham chiếu, UC-008); REQ-145 (tham chiếu, UC-014); REQ-152 (tham chiếu, UC-005) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý cụm rạp | Yêu cầu thiết lập bảng giá của cụm rạp. |
| 2 | Hệ thống | Hiển thị bảng giá hiện tại của cụm rạp mà quản lý cụm rạp thuộc về (BR-61; xem Dữ liệu ra 1). |
| 3 | Quản lý cụm rạp | Chọn tổ hợp loại phòng, định dạng phim, loại ghế và khung giờ chiếu, nhập giá vé của tổ hợp đó rồi gửi (xem Dữ liệu vào 1; BR-11, BR-12). |
| 4 | Hệ thống | Kiểm tra giá vé đã nhập hợp lệ (BR-70). |
| 5 | Hệ thống | Kiểm tra mục giá của tổ hợp chưa bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị ở bước 2, rồi lưu giá vé cho tổ hợp với hiệu lực ngay, tất cả là một thao tác không chia cắt (BR-62, BR-63, BR-66, BR-71). |
| 6 | Hệ thống | Thông báo lưu giá thành công và hiển thị mục giá đã lưu (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Quản lý cụm rạp chọn bỏ giá của một tổ hợp thay vì đặt giá | - | Bỏ giá | - |
| 1a1 | | Hệ thống | Hiển thị bảng giá hiện tại của cụm rạp mà quản lý cụm rạp thuộc về (BR-61; xem Dữ liệu ra 1). | |
| 1a2 | | Quản lý cụm rạp | Chọn mục giá cần bỏ (xem Dữ liệu vào 2). | |
| 1a3 | | Hệ thống | Kiểm tra mục giá đã chọn chưa bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị ở bước 1a1 và cụm rạp không còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá đó (cùng loại phòng, định dạng, loại ghế có trong phòng chiếu và khung giờ), rồi bỏ mục giá khỏi bảng giá, tất cả là một thao tác không chia cắt với việc lưu suất chiếu của UC-014 và với việc chốt giá của UC-005 (BR-63, BR-64, BR-68, BR-71). | |
| 1a3a | Mục giá đã chọn đã bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị ở bước 1a1 (BR-63); kiểm trước 1a3b | Hệ thống | Từ chối bỏ giá, không ghi đè, và thông báo mục giá đã thay đổi hoặc không còn; quản lý cụm rạp mở lại bảng giá từ đầu (BR-63). | Kết thúc use case (thất bại) |
| 1a3b | Cụm rạp còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá đã chọn: loại phòng của phòng chiếu, định dạng và khung giờ của giờ bắt đầu bằng của mục giá, và phòng chiếu có ít nhất một ghế thuộc loại ghế của mục giá (BR-64), không thuộc 1a3a | Hệ thống | Từ chối bỏ giá và thông báo quy tắc bị vi phạm (BR-64). | Kết thúc use case (thất bại) |
| 1a4 | | Hệ thống | Thông báo bỏ giá thành công. | Kết thúc use case (thành công) |
| 4a | Giá vé đã nhập không hợp lệ (BR-70) | Hệ thống | Từ chối lưu giá và thông báo quy tắc bị vi phạm (BR-70). | Quay lại bước 3 |
| 5a | Mục giá của tổ hợp đã bị yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc hiển thị ở bước 2 (BR-63) | Hệ thống | Từ chối lưu giá, không ghi đè, và thông báo mục giá đã thay đổi; quản lý cụm rạp mở lại bảng giá từ đầu (BR-63). | Kết thúc use case (thất bại) |
| *a | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a trước bước 1a3, quản lý cụm rạp huỷ yêu cầu | Hệ thống | Huỷ yêu cầu, không thay đổi bảng giá. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Loại phòng | Loại phòng của tổ hợp giá | Có | Một trong ba loại phòng: phòng thường, 4DX, IMAX (REQ-02, BR-62) | IMAX |
| 2 | Định dạng phim | Định dạng chiếu của tổ hợp giá | Có | Một trong hai định dạng: 2D, 3D (REQ-55, BR-62) | 3D |
| 3 | Loại ghế | Loại ghế của tổ hợp giá | Có | Một trong ba loại ghế: ghế thường, ghế VIP, ghế đôi (REQ-16); giá của ghế đôi là giá một vé cho cả vị trí đôi (REQ-17, REQ-30) | Ghế VIP |
| 4 | Khung giờ chiếu | Khung giờ chiếu của tổ hợp giá, xác định theo giờ bắt đầu của suất chiếu (BR-12) | Có | Một trong bốn khung giờ: ngày thường trước 17 giờ, ngày thường từ 17 giờ trở đi, cuối tuần trước 17 giờ, cuối tuần từ 17 giờ trở đi; cuối tuần gồm Thứ Bảy và Chủ nhật (BR-11, BR-12) | Cuối tuần từ 17 giờ trở đi |
| 5 | Giá vé | Giá của một vé (một ghế) cho tổ hợp | Có | Số nguyên đồng lớn hơn 0, không có giá trị tối đa (BR-70) | 120000 |

Dữ liệu vào 2 (bước 1a2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Mục giá cần bỏ | Một mục giá trong bảng giá ở Dữ liệu ra 1 | Có | Mục giá của bảng giá cụm rạp của quản lý cụm rạp (BR-61); chưa bị yêu cầu khác đổi hoặc bỏ kể từ lúc hiển thị (BR-63); cụm rạp không còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá (BR-64) | IMAX, 3D, Ghế VIP, cuối tuần từ 17 giờ trở đi |

Dữ liệu ra 1 (bước 2, bước 1a1)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Bảng giá của cụm rạp | Với mỗi mục giá: loại phòng, định dạng phim, loại ghế, khung giờ chiếu và giá vé (REQ-37, REQ-38) | Giá là số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải; các trường còn lại là văn bản | IMAX, 3D, Ghế VIP, cuối tuần từ 17 giờ trở đi, 150.000 đ |

Dữ liệu ra 2 (bước 6)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Mục giá đã lưu | Loại phòng, định dạng phim, loại ghế, khung giờ chiếu và giá vé của mục giá vừa lưu | Như Dữ liệu ra 1 | IMAX, 3D, Ghế VIP, cuối tuần từ 17 giờ trở đi, 150.000 đ |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-11 | Giá vé lấy theo bảng giá của cụm rạp có suất chiếu, phụ thuộc loại phòng, định dạng phim, loại ghế và khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi; ngày thường hoặc cuối tuần). | Tính toán | 3, Dữ liệu vào 1 | REQ-37, REQ-38 | Đã có |
| BR-12 | Khung giờ chiếu xác định theo giờ bắt đầu của suất chiếu; cuối tuần gồm Thứ Bảy và Chủ nhật. | Suy luận | 3, Dữ liệu vào 1 (trường 4) | REQ-91 | Đã có |
| BR-61 | Quản lý cụm rạp chỉ xem và thiết lập bảng giá của cụm rạp mình. | Ràng buộc | 2, 1a1, Dữ liệu vào 2 | REQ-37, REQ-59; REQ-100 (phụ) | Mới |
| BR-62 | Mỗi mục giá của bảng giá gồm một loại phòng, một định dạng phim, một loại ghế, một khung giờ chiếu và đúng một giá vé; mỗi tổ hợp bốn yếu tố có tối đa một mục giá trong bảng giá của cụm rạp. | Ràng buộc | 5, Dữ liệu vào 1 | REQ-37, REQ-38 | Mới |
| BR-63 | Khi mục giá đã bị một yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc quản lý cụm rạp được hiển thị, yêu cầu đặt giá hoặc bỏ giá của quản lý cụm rạp sau bị từ chối và không ghi đè thay đổi trước. | Ràng buộc | 5, 5a, 1a3, 1a3a, Dữ liệu vào 2 | REQ-148; REQ-59 (phụ) | Mới |
| BR-64 | Không được bỏ mục giá khi cụm rạp còn suất chiếu chưa tới giờ bắt đầu và còn trong lịch suất chiếu mà loại phòng của phòng chiếu và định dạng bằng của mục giá, phòng chiếu có ít nhất một ghế thuộc loại ghế của mục giá, và khung giờ xác định theo giờ bắt đầu (BR-12) bằng khung giờ của mục giá. | Ràng buộc | 1a3, 1a3b, Dữ liệu vào 2 | REQ-146; REQ-59, REQ-145 (phụ) | Mới |
| BR-65 | Giá vé của một lần giữ ghế được chốt cùng lúc với việc giữ ghế (UC-005 bước 7) và giữ nguyên tới hết lần giữ ghế; việc đặt giá, bỏ giá sau đó không đổi giá của lần giữ ghế đó; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | Hậu điều kiện, Mục 8 (kiểm ở UC-005 bước 7) | REQ-149; REQ-37, REQ-38 (phụ) | Mới |
| BR-66 | Thay đổi bảng giá có hiệu lực ngay khi lưu, áp dụng cho mọi lần chốt giá sau đó, kể cả các suất chiếu đã lập; không hẹn ngày hiệu lực. | Ràng buộc | 5, 6, 1a4, Hậu điều kiện | REQ-150; REQ-59 (phụ) | Mới |
| BR-67 | Thay đổi bảng giá không đổi giá của vé đã bán; vé giữ giá đã ghi trên vé. | Suy luận | Hậu điều kiện | REQ-149; REQ-105 (phụ) | Mới |
| BR-68 | Việc kiểm tra BR-64 rồi bỏ mục giá và việc kiểm tra BR-69 rồi lưu suất chiếu lập hoặc sửa (UC-014 bước 8) không xen vào nhau: nếu suất chiếu được ghi nhận trước thì bỏ giá bị từ chối theo BR-64; nếu bỏ giá được ghi nhận trước thì lập hoặc sửa suất chiếu bị từ chối theo BR-69. | Ràng buộc | 1a3 | REQ-151; REQ-145 (phụ) | Mới |
| BR-69 | Không được lập suất chiếu, hoặc sửa suất chiếu thành suất chiếu, khi bảng giá của cụm rạp chưa có giá cho mọi loại ghế có trong phòng chiếu (loại ghế mà phòng chiếu có ít nhất một ghế), ứng với khung giờ xác định theo giờ bắt đầu của suất chiếu (BR-12), theo loại phòng của phòng chiếu và định dạng phim của suất chiếu. | Ràng buộc | Mục 8 (kiểm ở UC-014 bước 5, 8) | REQ-145; REQ-37, REQ-38 (phụ) | Mới |
| BR-70 | Giá vé của mục giá là số nguyên đồng lớn hơn 0, không có giá trị tối đa; mọi tổ hợp loại phòng, định dạng phim, loại ghế và khung giờ chiếu đều đặt được giá, kể cả loại phòng mà cụm rạp chưa có. | Ràng buộc | 4, 4a, Dữ liệu vào 1 (trường 5) | REQ-147; REQ-37, REQ-38 (phụ) | Mới |
| BR-71 | Việc chốt giá của một lần giữ ghế và việc lưu thay đổi bảng giá không xen vào nhau: thay đổi bảng giá được ghi nhận trước thì lần giữ ghế dùng giá mới; thay đổi bảng giá được ghi nhận sau thì không ảnh hưởng lần giữ ghế đó. | Ràng buộc | 5, 1a3 | REQ-149; REQ-150 (phụ) | Mới |
| BR-72 | Không được giữ ghế khi bảng giá của cụm rạp không có giá cho một ghế đã chọn, ứng với loại phòng, định dạng phim, loại ghế và khung giờ chiếu của suất chiếu. | Ràng buộc | Mục 8 (kiểm ở UC-005 bước 7) | REQ-152; REQ-37, REQ-38 (phụ) | Mới |
| BR-73 | Việc sửa phòng chiếu không được làm suất chiếu chưa tới giờ bắt đầu của phòng chiếu đó thiếu giá theo BR-69. | Ràng buộc | Mục 8 (ràng buộc cho UC-012) | REQ-145; REQ-57, REQ-58 (phụ) | Mới |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính là kịch bản đặt giá của một tổ hợp (REQ-59): một mục giá gồm loại phòng, định dạng phim, loại ghế, khung giờ chiếu và giá vé (BR-11, BR-62). Tổ hợp chưa có mục giá thì tạo mục giá, đã có thì đổi giá, cùng một thao tác ở bước 5. Bỏ giá (luồng 1a) là thao tác thứ hai; quản lý cụm rạp chọn đặt hoặc bỏ giá thay cho bước 1, nên trên activity diagram decision D-1 đặt ngay sau INIT, trước A-1. Nguồn chỉ nêu "thiết lập bảng giá" (REQ-59), không nêu bỏ giá; luồng 1a theo trả lời Q-62 (REQ-146).
- Bảng giá có tối đa 3 loại phòng x 2 định dạng x 3 loại ghế x 4 khung giờ = 72 mục giá mỗi cụm rạp. Nguồn không bắt buộc bảng giá đủ mọi tổ hợp, nhưng UC-014 chặn từ gốc (trả lời Q-61, phương án A): khi lập hoặc sửa suất chiếu, bảng giá phải có giá cho mọi loại ghế có trong phòng chiếu, ứng với khung giờ của giờ bắt đầu, theo loại phòng và định dạng của suất chiếu (BR-69; BR-59 là trường hợp riêng chỉ xét loại phòng và định dạng). Vì vậy quản lý cụm rạp đặt giá trước, lập suất chiếu sau: lập một suất chiếu ngày thường buộc bảng giá có đủ giá cho mọi loại ghế của phòng ở khung giờ đó.
- Bước 5 và bước 1a3 gộp kiểm tra và ghi thành một thao tác không chia cắt. Lý do: nếu tách rời, hai quản lý cùng thấy mục giá chưa đổi rồi cùng lưu, người sau ghi đè người trước (BR-63); và UC-005 bước 7 có thể chốt giá giữa lúc kiểm tra và lúc lưu (BR-71). Cơ chế bảo đảm thuộc bước thiết kế (P07, P09). BR-63 là hệ quả khi nhiều yêu cầu cùng sửa, gồm hai quản lý cụm rạp hoặc hai phiên làm việc của cùng một người (trả lời Q-64, REQ-148).
- Điểm nối với UC-005 (đua giữ ghế, thanh toán với đổi giá). Giá vé từng ghế được chốt ở UC-005 bước 7, trong cùng thao tác không chia cắt với việc giữ ghế (BR-65, BR-71); bước 8 chỉ hiển thị giá đã chốt, và số tiền giao dịch ở bước 10 do UC-005 quy định (REQ-111). Quản lý cụm rạp đổi giá sau bước 7: khách vẫn trả đúng giá đã chốt tới hết lần giữ ghế, kể cả khi cổng thanh toán báo thành công sau đó; giá mới chỉ áp dụng cho lần giữ ghế chốt giá sau thời điểm lưu (BR-65, BR-66). Trước khi khách xác nhận chọn ghế (UC-005 bước 4 đến 6) khách chưa thấy giá nên không có giá nào bị đổi (trả lời Q-65, Q-66). Nếu lúc chốt giá bảng giá không có giá cho một ghế đã chọn, UC-005 luồng 7e từ chối giữ ghế (BR-72); luồng này là lưới an toàn vì bất biến "mọi suất chiếu chưa diễn ra đều đủ giá" có thể vỡ qua UC-012 (xem BR-73), nên phương án A giảm xác suất thiếu giá, không loại bỏ khả năng đó.
- Vé đã bán không đổi giá (BR-67): mỗi vé ghi giá vé (REQ-105) và số tiền hoàn 70% ở UC-008 là 70% giá vé của vé đó (BR-19, BR-31), nên đổi hoặc bỏ giá không làm thay đổi số tiền hoàn của vé đã bán trước đó. Doanh thu theo REQ-99 tính theo tiền vé đã bán, không bị đổi giá ảnh hưởng.
- Điểm nối với UC-014 (bỏ giá của tổ hợp đang được suất chiếu dùng). UC-014 không cho lập, sửa suất chiếu khi bảng giá chưa đủ giá cho suất chiếu (BR-69). Để bảng giá không mất giá của suất chiếu đã lập, luồng 1a không cho bỏ mục giá đang được suất chiếu chưa tới giờ bắt đầu dùng (BR-64), so đủ bốn yếu tố: loại phòng của phòng chiếu, định dạng, loại ghế có trong phòng chiếu và khung giờ của giờ bắt đầu (trả lời Q-62). Do đó mục giá cuối tuần vẫn bỏ được khi chỉ còn suất chiếu ngày thường cùng loại phòng và định dạng. Mục giá bị chặn bỏ kể cả khi suất chiếu chưa có ghế giữ hay vé; đổi giá của mục đó vẫn được (luồng chính). Việc đổi giá không chạm tới BR-69 vì tổ hợp vẫn có giá. Khoảng giữa lúc UC-014 kiểm BR-69 sớm (bước 5) và lúc lưu suất chiếu (bước 8): bỏ giá có thể xen vào; BR-68 yêu cầu UC-014 bước 8 kiểm lại BR-69 trong cùng thao tác không chia cắt với việc lưu, thất bại thì UC-014 luồng 8e quay lại bước 3 (trả lời Q-67).
- Ràng buộc cho UC-012 (chưa đặc tả, không thuộc phạm vi UC-013): sửa phòng chiếu có suất chiếu chưa tới giờ bắt đầu không được làm suất chiếu đó thiếu giá, như đổi loại phòng hoặc thêm loại ghế vào phòng khi bảng giá chưa có giá tương ứng với khung giờ của suất chiếu (BR-73). Việc UC-012 sửa sơ đồ ghế và UC-014 lưu suất chiếu cùng đọc sơ đồ ghế của phòng chiếu; UC-012 khi đặc tả cần cặp quy tắc loại trừ giống BR-68.
- Suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc, hoặc đã bị xoá khỏi lịch (BR-57, BR-58) không còn chặn bỏ giá ở BR-64, vì không còn cần tính giá vé mới cho suất chiếu đó; vé đã bán và lần giữ ghế đang có vẫn giữ giá đã chốt (BR-65, BR-67).
- Thứ tự kiểm ở bước 1a3: 1a3a (mục giá đã bị đổi) trước 1a3b (suất chiếu đang dùng). Khi thông tin quản lý cụm rạp đang xem đã cũ thì kiểm tra còn lại không còn ý nghĩa, như thứ tự 8c đứng đầu ở UC-014; nguồn không nêu thứ tự báo khi nhiều điều kiện cùng vi phạm.
- Khung giờ ở BR-12: giờ bắt đầu từ 17 giờ 00 trở đi thuộc khung "từ 17 giờ trở đi"; trước 17 giờ 00 thuộc khung "trước 17 giờ" (REQ-38). Cuối tuần là Thứ Bảy và Chủ nhật, các ngày còn lại là ngày thường (REQ-91).
- Giá của ghế đôi là giá của một vé: ghế đôi được bán như một ghế (REQ-17) và mỗi ghế là một vé (REQ-30). Giá không nhân đôi theo số người.
- Danh sách loại phòng lấy từ REQ-02 (UC-012), định dạng từ REQ-55 (UC-010); bảng giá không phụ thuộc cụm rạp có phòng thuộc loại đó hay không (trả lời Q-63, BR-70).
- Bước sinh theo quy tắc của prompt: bước 6 và bước 1a4 (báo kết quả cho quản lý cụm rạp); hành động "Từ chối ... và thông báo" ở luồng 1a3a, 1a3b, 4a, 5a; điểm quay lại bước 3 ở luồng 4a vì quản lý cụm rạp sửa được giá vé vi phạm. Luồng 5a, 1a3a kết thúc thất bại vì quản lý cụm rạp phải mở lại bảng giá hiện hành mới biết thông tin mới; luồng 1a3b kết thúc thất bại vì quản lý cụm rạp không sửa được điều kiện ngay trong use case.
- Không có bước hẹn hoặc huỷ mốc (F4.2 mục 17): thay đổi bảng giá có hiệu lực ngay (BR-66, trả lời Q-66), không có ngày hiệu lực hẹn trước.

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý cụm rạp đặt giá cho tổ hợp chưa có giá thành công (tạo mục giá).
- KB2: Luồng chính --> quản lý cụm rạp đổi giá của tổ hợp đã có giá thành công; lần giữ ghế đang có và vé đã bán giữ giá cũ.
- KB3: Luồng chính + 4a --> giá vé không hợp lệ, quay lại bước 3, nhập lại rồi lưu thành công.
- KB4: Luồng chính + 5a --> hai quản lý cùng thao tác trên một mục giá, người lưu sau bị từ chối, không ghi đè.
- KB5: Luồng 1a --> bỏ mục giá của tổ hợp không còn suất chiếu chưa diễn ra dùng thành công.
- KB6: Luồng 1a + 1a3b --> bỏ giá bị từ chối vì cụm rạp còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá (đủ loại phòng, định dạng, loại ghế, khung giờ); với 1a3a --> bỏ giá bị từ chối vì mục giá đã bị yêu cầu khác đổi.
- KB7: Luồng chính trong lúc khách đang giữ ghế hoặc đang thanh toán (UC-005) --> khách trả đúng giá đã chốt khi giữ ghế, giá mới áp dụng cho lần giữ ghế chốt giá sau.

## 9. Activity diagram

File: diagrams/P04-activity-UC-013.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4, 4a | A-4, D-4, A-4a |
| 5, 5a | A-5, D-5, A-5a, FINAL-1 |
| 6 | A-6, FINAL-2 |
| 1a1, 1a2, 1a3, 1a3a, 1a3b, 1a4 | A-1a1, A-1a2, A-1a3, D-1a3, A-1a3a, A-1a3b, FINAL-3, FINAL-4, A-1a4, FINAL-5 |
| *a | N-*a |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-04 | Partition | Quản lý cụm rạp | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=601 |
| INIT | Initial | - | - | P-ACT-04 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-04 | 1a | x=130, y=130 (tương đối partition) |
| A-1 | Action | Yêu cầu thiết lập bảng giá | - | P-ACT-04 | 1 | x=60, y=210 (tương đối partition) |
| A-2 | Action | Hiển thị bảng giá của cụm rạp | - | P-SYS | 2 | x=60, y=210 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-04 | 4a | x=130, y=330 (tương đối partition) |
| A-3 | Action | Chọn tổ hợp và nhập giá vé | - | P-ACT-04 | 3 | x=60, y=400 (tương đối partition) |
| A-4 | Action | Kiểm tra giá vé hợp lệ | - | P-SYS | 4 | x=60, y=400 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a | x=130, y=500 (tương đối partition) |
| A-4a | Action | Từ chối: giá vé không hợp lệ (BR-70) | - | P-SYS | 4a | x=320, y=490 (tương đối partition) |
| A-5 | Action | Kiểm tra mục giá chưa bị đổi rồi lưu giá | - | P-SYS | 5 | x=60, y=600 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5a | x=130, y=700 (tương đối partition) |
| A-5a | Action | Từ chối: mục giá đã bị yêu cầu khác đổi (BR-63) | - | P-SYS | 5a | x=320, y=690 (tương đối partition) |
| A-6 | Action | Thông báo lưu giá thành công | - | P-SYS | 6 | x=60, y=800 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 5a | x=520, y=700 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | 6 | x=130, y=900 (tương đối partition) |
| A-1a1 | Action | Hiển thị bảng giá của cụm rạp | - | P-SYS | 1a1 | x=60, y=1000 (tương đối partition) |
| A-1a2 | Action | Chọn mục giá cần bỏ | - | P-ACT-04 | 1a2 | x=300, y=1000 (tương đối partition) |
| A-1a3 | Action | Kiểm tra mục giá rồi bỏ khỏi bảng giá | - | P-SYS | 1a3 | x=60, y=1100 (tương đối partition) |
| D-1a3 | Decision | - | - | P-SYS | 1a3a, 1a3b | x=130, y=1200 (tương đối partition) |
| A-1a3a | Action | Từ chối bỏ: mục giá đã bị yêu cầu khác đổi (BR-63) | - | P-SYS | 1a3a | x=320, y=1190 (tương đối partition) |
| A-1a3b | Action | Từ chối bỏ: suất chiếu đang dùng (BR-64) | - | P-SYS | 1a3b | x=320, y=1290 (tương đối partition) |
| A-1a4 | Action | Thông báo bỏ giá thành công | - | P-SYS | 1a4 | x=60, y=1300 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | 1a3a | x=520, y=1200 (tương đối partition) |
| FINAL-4 | ActivityFinal | - | - | P-SYS | 1a3b | x=520, y=1300 (tương đối partition) |
| FINAL-5 | ActivityFinal | - | - | P-SYS | 1a4 | x=130, y=1400 (tương đối partition) |
| N-*a | Note | *a: Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a trước bước 1a3, quản lý huỷ yêu cầu: hệ thống không đổi bảng giá, kết thúc (thất bại) | - | P-ACT-04 | *a | x=300, y=44 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [đặt giá] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [bỏ giá] | - | (610,150); (610,985); (710,985) |
| E-04 | A-1 | A-2 | ControlFlow | - | - | - |
| E-05 | A-2 | M-3 | ControlFlow | - | - | - |
| E-06 | M-3 | A-3 | ControlFlow | - | - | - |
| E-07 | A-3 | A-4 | ControlFlow | - | - | - |
| E-08 | A-4 | D-4 | ControlFlow | - | - | - |
| E-09 | D-4 | A-4a | ControlFlow | [giá vé không hợp lệ] | - | - |
| E-10 | D-4 | A-5 | ControlFlow | [khác] | - | - |
| E-11 | A-4a | M-3 | ControlFlow | - | - | (970,475); (250,475); (250,315); (150,315) |
| E-12 | A-5 | D-5 | ControlFlow | - | - | - |
| E-13 | D-5 | A-5a | ControlFlow | [mục giá đã bị yêu cầu khác đổi] | - | - |
| E-14 | D-5 | A-6 | ControlFlow | [khác] | - | - |
| E-15 | A-5a | FINAL-1 | ControlFlow | - | - | - |
| E-16 | A-6 | FINAL-2 | ControlFlow | - | - | - |
| E-17 | A-1a1 | A-1a2 | ControlFlow | - | - | - |
| E-18 | A-1a2 | A-1a3 | ControlFlow | - | - | - |
| E-19 | A-1a3 | D-1a3 | ControlFlow | - | - | - |
| E-20 | D-1a3 | A-1a3a | ControlFlow | [mục giá đã bị yêu cầu khác đổi] | - | - |
| E-21 | D-1a3 | A-1a3b | ControlFlow | [suất chiếu đang dùng, không thuộc đã bị đổi] | - | - |
| E-22 | D-1a3 | A-1a4 | ControlFlow | [khác] | - | - |
| E-23 | A-1a3a | FINAL-3 | ControlFlow | - | - | - |
| E-24 | A-1a3b | FINAL-4 | ControlFlow | - | - | - |
| E-25 | A-1a4 | FINAL-5 | ControlFlow | - | - | - |

Ghi chú sơ đồ: D-1 đặt trong partition của quản lý cụm rạp, ngay sau INIT, vì quản lý cụm rạp chọn đặt giá hoặc bỏ giá thay cho bước 1 (F5.2). Luồng 4a quay lại merge node M-3 đặt ngay trước A-3, cùng điểm vào với cạnh từ A-2. Guard của D-1a3 xét theo thứ tự từ trên xuống (1a3a, 1a3b), guard của 1a3b nêu loại trừ 1a3a; [khác] đi tới A-1a4. Luồng *a chỉ thể hiện bằng note N-*a (F10.2). Luồng 5a, 1a3a, 1a3b kết thúc ở các activity final riêng. Cạnh nào không ghi điểm uốn thì công cụ sắp xếp tự động đặt đường đi.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-62 | Đã trả lời (Theo đề xuất: được bỏ; từ chối bỏ khi cụm rạp còn suất chiếu chưa tới giờ bắt đầu đang dùng mục giá, so đủ bốn yếu tố loại phòng, định dạng, loại ghế, khung giờ, theo phương án A của Q-61), đề bài bổ sung Mục 15. Quản lý cụm rạp có được bỏ một mục giá khỏi bảng giá không, và có được bỏ mục giá của tổ hợp đang được suất chiếu dùng không? Nội dung phụ thuộc Q-61: nếu Q-61 không theo phương án A thì BR-64 chỉ so loại phòng và định dạng, và chỉ chặn bỏ mục giá cuối cùng của cặp đó. | Luồng 1a, 1a3b; BR-64, BR-69; UC-014 | REQ-59 chỉ nêu "thiết lập bảng giá", không nêu bỏ mục giá; REQ-145 chỉ nêu điều kiện khi lập, sửa suất chiếu |
| Q-63 | Đã trả lời (Theo đề xuất: giá là số nguyên đồng lớn hơn 0, không có trần; mọi tổ hợp đều đặt được giá), đề bài bổ sung Mục 15. Điều kiện hợp lệ của giá vé và của tổ hợp: giá có phải số nguyên đồng lớn hơn 0 không (có cho giá 0 hoặc giá lẻ, có trần không)? Mọi tổ hợp 3 loại phòng x 2 định dạng x 3 loại ghế x 4 khung giờ có được đặt giá không, kể cả loại phòng cụm rạp chưa có? | Bước 4, luồng 4a; Dữ liệu vào 1; BR-70 | Mục 10 và Mục 15 không nêu điều kiện giá trị của giá vé và phạm vi tổ hợp |
| Q-64 | Đã trả lời (Theo đề xuất: người lưu sau bị từ chối, không ghi đè), đề bài bổ sung Mục 15. Hai yêu cầu (của hai quản lý cụm rạp hoặc hai phiên làm việc của cùng một người) cùng đặt giá hoặc bỏ giá một mục giá của một cụm rạp, hoặc một yêu cầu lưu khi mục giá đã bị yêu cầu kia đổi: xử lý thế nào? | Bước 5, luồng 5a, 1a3a; BR-63 | Mục 15 không nêu trường hợp nhiều yêu cầu cùng sửa bảng giá |
| Q-65 | Đã trả lời (Theo đề xuất: giá chốt khi giữ ghế và giữ nguyên tới hết lần giữ ghế, vé đã bán giữ giá; giá mới chỉ áp dụng cho lần giữ ghế chốt giá sau khi thay đổi được lưu; chốt giá và lưu thay đổi không xen vào nhau), đề bài bổ sung Mục 15. Quản lý cụm rạp đổi giá đúng lúc khách hoặc nhân viên quầy đang giữ ghế hoặc đang thanh toán: khách trả theo giá nào? | UC-005 bước 7, 8; BR-65, BR-67, BR-71; Mục 8 | Mục 10 nêu giá theo bảng giá, Mục 4 và Mục 7 không nêu giá đổi trong lúc giữ ghế hoặc thanh toán |
| Q-66 | Đã trả lời (Theo đề xuất: có hiệu lực ngay khi lưu, không hẹn ngày hiệu lực), đề bài bổ sung Mục 15. Thay đổi bảng giá áp dụng từ lúc nào? Nguồn không nêu chức năng hẹn ngày hiệu lực nên đặc tả không sinh bước hẹn (F4.2 mục 17); câu hỏi nhằm loại trừ cách hiểu bảng giá có lịch hiệu lực. | Bước 5, 6; BR-66 | Mục 15 chỉ nêu "thiết lập bảng giá", không nêu thời điểm hiệu lực |
| Q-67 | Đã trả lời (Theo đề xuất: UC-014 bước 8 kiểm lại bảng giá trong cùng thao tác không chia cắt với việc lưu suất chiếu, ghi nhận trước thì thắng; thất bại quay lại bước 3 ở luồng 8e), đề bài bổ sung Mục 16. Bỏ giá xen vào giữa lúc UC-014 kiểm bảng giá (bước 5) và lúc lưu suất chiếu (bước 8): xử lý thế nào? Chỉ cần trả lời khi Q-61 theo phương án A hoặc Q-62 theo đề xuất. | Luồng 1a3; BR-68; UC-014 bước 8, luồng 8e; phụ thuộc Q-61, Q-62 | REQ-145 không nêu yêu cầu đồng thời giữa bỏ giá và lưu suất chiếu |

## Đề xuất sửa artifact trước

- UC-012 (chưa đặc tả): khi đặc tả cần dẫn BR-73 (sửa phòng chiếu không làm suất chiếu chưa tới giờ bắt đầu thiếu giá) và cặp quy tắc loại trừ giữa sửa sơ đồ ghế với việc lưu suất chiếu của UC-014, giống BR-68.
- P06: xét gộp BR-59 vào BR-69 (BR-59 là trường hợp riêng của BR-69).

## Vấn đề còn mở

- Phương án A của Q-61 giảm xác suất thiếu giá, không loại bỏ khả năng đó, vì UC-012 chưa đặc tả và có thể làm suất chiếu chưa diễn ra thiếu giá; UC-005 luồng 7e giữ vai trò lưới an toàn (BR-72).
- Luồng chính có 6 bước, trong khoảng 3-15; use case chỉ có một thao tác dữ liệu đơn giản nên không tách thêm bước.
- Thứ tự kiểm 1a3a, 1a3b là lựa chọn của đặc tả này (Mục 8).
- BR-63, BR-68 và BR-71 mô tả cơ chế đồng thời; nguồn không có câu riêng về xử lý đồng thời khi sửa bảng giá ngoài trả lời Q-64, Q-67. BR-67 là suy luận từ REQ-105, không phải câu nguồn riêng.
- Bố cục activity diagram do công cụ sắp xếp tự động (diakempt); đã kiểm không đường nối nào cắt qua node, không node nào chồng nhau.
