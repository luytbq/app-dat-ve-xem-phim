# P04 - Đặc tả use case UC-008 Huỷ vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.8 |
| Thay đổi 1.8 | Activity diagram: thêm Merge M-6c trước A-6c để A-6c chỉ có một cạnh vào (E-57); không đổi luồng |
| Thay đổi 1.7 | Đồng bộ số phiên bản và nhãn BR của dòng Đầu vào đã dùng với bản hiện hành; nội dung đã đối chiếu lại ở lượt review cuối (design/_review-final.md, RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; _BR-register.md (đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; UC-005-book-tickets.md 1.11 (mẫu và điểm nối); _review-final-batch1.md; _review-final-batch1-recheck.md |
| Phạm vi | UC-008 |
| Mã Q, ASM cuối đã cấp | Q-51 (Q-36 gộp vào Q-30); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-008 |
| Tên use case | Huỷ vé (Cancel Ticket) |
| Tác nhân chính | ACT-01 Khách, ACT-02 Nhân viên quầy |
| Tác nhân phụ | ACT-07 Cổng thanh toán |
| Mô tả ngắn | Use case này mô tả tương tác giữa khách (hoặc nhân viên quầy khi vé được mua tại quầy) và hệ thống khi muốn huỷ một vé đã mua trước giờ bắt đầu của suất chiếu. Kết quả là vé bị huỷ, khách được hoàn 70% giá vé và ghế của vé trở về trạng thái trống để người khác chọn; khi hoàn tiền không thành công sau khi thử lại, ghế vẫn trở về trống và khoản hoàn được ghi log lỗi để xử lý thủ công ngoài hệ thống. |
| Sự kiện kích hoạt | Khách muốn huỷ vé đã mua (EV-10) |
| Tiền điều kiện | Khi tác nhân là khách: khách đã đăng nhập và đang có phiên làm việc (REQ-12).<br>Khi tác nhân là nhân viên quầy: nhân viên quầy đã đăng nhập và đang có phiên làm việc (REQ-102). |
| Hậu điều kiện (thành công) | Vé ở trạng thái đã huỷ.<br>Ghế của vé ở trạng thái trống trên sơ đồ ghế của suất chiếu và được chọn, giữ, mua như mọi ghế trống khác.<br>Số tiền hoàn bằng 70% giá vé, làm tròn xuống đồng (BR-31), được ghi nhận cho vé kèm tình trạng hoàn tiền: đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi (REQ-99).<br>Với vé mua trực tuyến: cổng thanh toán đã báo hoàn tiền thành công, hoặc (luồng 5c, 6b) khoản hoàn đã được ghi log lỗi để xử lý thủ công ngoài hệ thống và không có email cho khách (BR-41).<br>Với vé mua tại quầy (luồng 5a): nhân viên quầy đã xác nhận hoàn tiền mặt (tình trạng đã hoàn); không có giao dịch hoàn tiền qua cổng thanh toán. |
| Hậu điều kiện tối thiểu | Khi use case kết thúc ở luồng 2a, 2b, 2c, 3a, 4a hoặc 4b: vé, ghế không thay đổi và không có khoản hoàn tiền nào.<br>Một vé không bao giờ được hoàn tiền quá một lần (BR-21).<br>Khi use case đi qua luồng 5c hoặc 6b: vé ở trạng thái đã huỷ (từ bước 4), ghế đã trở về trạng thái trống ở bước 7 (BR-42), khoản hoàn được ghi log lỗi để xử lý thủ công ngoài hệ thống và không có email cho khách (BR-41). Không có trạng thái vé đã huỷ mà ghế chưa trống. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-40 đến REQ-44, REQ-83, REQ-84, REQ-85, REQ-118 đến REQ-122, REQ-131, REQ-132 (theo P02); REQ-12, REQ-102, REQ-79 (P02 Mục 5 đã gắn UC-008); REQ-19 (tham chiếu, UC-005), REQ-78 (tham chiếu, UC-005; phụ của BR-43), REQ-35, REQ-109 (tham chiếu, UC-006; BR-26), REQ-135 (tham chiếu, UC-005; Mục 8), REQ-30 (tham chiếu, UC-005), REQ-47 (tham chiếu, UC-005), REQ-51 (tham chiếu, UC-009), REQ-99 (tham chiếu, UC-015, UC-016), REQ-100 (tham chiếu, UC-017), REQ-105, REQ-106 (tham chiếu, UC-005; Dữ liệu vào 1, Dữ liệu ra 1) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Khách | Chọn vé cần huỷ trong các vé mua trực tuyến của mình và yêu cầu huỷ vé (xem Dữ liệu vào 1). |
| 2 | Hệ thống | Kiểm tra tác nhân được huỷ vé theo kênh mua vé: khách với vé mua trực tuyến của mình, nhân viên quầy với vé mua tại quầy của cụm rạp mình (BR-17). |
| 3 | Hệ thống | Kiểm tra thời điểm hệ thống thực hiện bước kiểm tra này cách giờ bắt đầu suất chiếu của vé ít nhất 2 tiếng (BR-18, BR-32). |
| 4 | Hệ thống | Kiểm tra vé chưa huỷ và chưa sử dụng, rồi ghi nhận vé đã huỷ, thành một thao tác không chia cắt (BR-21, BR-30). Với vé mua tại quầy, việc ghi nhận vé đã huỷ này, xác nhận hoàn tiền mặt ở bước 5a2 và trả ghế ở bước 7 là một thao tác không chia cắt (Q-125). |
| 5 | Hệ thống | Yêu cầu cổng thanh toán hoàn 70% giá vé của vé đã huỷ, làm tròn xuống đồng, kèm mã giao dịch và mã vé làm khoá chống hoàn trùng của yêu cầu hoàn (BR-19, BR-20, BR-26, BR-31, BR-43). |
| 6 | Cổng thanh toán | Báo hoàn tiền thành công. |
| 7 | Hệ thống | Ghi nhận khoản hoàn của vé kèm tình trạng hoàn tiền (đã hoàn, hoặc chưa hoàn được và đã ghi log lỗi) và trả ghế của vé về trạng thái trống để người khác chọn được (BR-42). |
| 8 | Hệ thống | Thông báo huỷ vé thành công, hiển thị số tiền hoàn và tình trạng hoàn tiền (xem Dữ liệu ra 1). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Tác nhân là nhân viên quầy | - | Huỷ vé mua tại quầy theo mã đặt vé | - |
| 1a1 | | Nhân viên quầy | Nhập mã đặt vé của lần đặt chứa vé cần huỷ (xem Dữ liệu vào 1). | |
| 1a1a | Mã đặt vé không trùng mã của lần đặt nào | Hệ thống | Thông báo mã đặt vé không tồn tại. | Quay lại bước 1a1 |
| 1a2 | | Hệ thống | Hiển thị các vé của lần đặt (xem Dữ liệu ra 2). | |
| 1a3 | | Nhân viên quầy | Chọn vé cần huỷ và yêu cầu huỷ vé. | Tiếp tục bước 2 |
| 2a | Tác nhân là khách và vé không phải vé khách đã mua trực tuyến (vé mua tại quầy hoặc vé của người khác) (BR-17) | Hệ thống | Từ chối huỷ vé và thông báo quy tắc bị vi phạm (BR-17). | Kết thúc use case (thất bại) |
| 2b | Tác nhân là nhân viên quầy và vé là vé mua trực tuyến (BR-17) | Hệ thống | Từ chối huỷ vé và thông báo quy tắc bị vi phạm (BR-17). | Kết thúc use case (thất bại) |
| 2c | Tác nhân là nhân viên quầy và vé mua tại quầy của cụm rạp khác cụm rạp của nhân viên quầy (BR-17) | Hệ thống | Từ chối huỷ vé và thông báo quy tắc bị vi phạm (BR-17). | Kết thúc use case (thất bại) |
| 3a | Thời điểm hệ thống kiểm tra cách giờ bắt đầu suất chiếu chưa tới 2 tiếng, kể cả suất chiếu đã bắt đầu hoặc đã kết thúc (BR-18, BR-32) | Hệ thống | Từ chối huỷ vé và thông báo hạn huỷ vé (BR-18). | Kết thúc use case (thất bại) |
| 4a | Vé đã huỷ, kể cả khi vừa bị huỷ bởi một yêu cầu huỷ khác xử lý ngay trước đó (BR-21); kiểm điều kiện này trước 4b | Hệ thống | Thông báo vé đã huỷ và không hoàn tiền thêm (BR-21). | Kết thúc use case (thất bại) |
| 4b | Vé chưa huỷ (không thuộc 4a) và đã sử dụng (đã soát, kể cả khi vừa được soát ngay trước đó, BR-30) | Hệ thống | Từ chối huỷ vé và thông báo vé đã sử dụng không huỷ được (BR-30). | Kết thúc use case (thất bại) |
| 5a | Tác nhân là nhân viên quầy (vé mua tại quầy hoàn bằng tiền mặt, BR-20) | - | Hoàn tiền mặt tại quầy | - |
| 5a1 | | Hệ thống | Hiển thị số tiền mặt cần hoàn cho khách mua tại quầy (xem Dữ liệu ra 1; BR-19, BR-31). | |
| 5a2 | | Nhân viên quầy | Hoàn tiền mặt cho khách mua tại quầy và xác nhận đã hoàn. | Tiếp tục bước 7 |
| 5b | Cổng thanh toán không phản hồi yêu cầu hoàn tiền trong 30 giây (BR-43) | Hệ thống | Không gửi lại ngay; chuyển sang tra cứu kết quả hoàn (BR-41, BR-43). | Thực hiện bước 5t |
| 6a | Cổng thanh toán báo hoàn tiền thất bại | Hệ thống | Không gửi lại ngay; chuyển sang tra cứu kết quả hoàn (BR-41, BR-43). | Thực hiện bước 5t |
| 5t | Sau 5b hoặc 6a | Hệ thống | Tra cứu cổng xem yêu cầu hoàn mang khoá chống hoàn trùng này đã được thực hiện chưa (BR-43). Kết quả: (i) đã hoàn; (ii) chưa hoàn và còn lượt thử lại (BR-41), hệ thống chờ khoảng cách giữa hai lần thử rồi gửi lại; (iii) chưa hoàn và đã hết lượt thử lại; (iv) không tra cứu được kết quả (cổng không có tra cứu hoặc tra cứu không trả lời) thì không gửi lại tự động (BR-41). | (i) tiếp tục bước 7 với tình trạng đã hoàn; (ii) quay lại bước 5; (iii), (iv) như 5c |
| 5c | Sau 5t từ 5b: chưa hoàn và đã hết lượt thử lại, hoặc không tra cứu được kết quả | Hệ thống | Ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống, không gửi email cho khách (BR-41). | Tiếp tục bước 7 |
| 6b | Sau 5t từ 6a: chưa hoàn và đã hết lượt thử lại, hoặc không tra cứu được kết quả | Hệ thống | Ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống, không gửi email cho khách (BR-41). | Tiếp tục bước 7 |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 1, 1a1, 1a3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Mã đặt vé (bước 1a1) | Mã của lần đặt chứa vé cần huỷ; có sẵn trên vé in (REQ-120) | Có với nhân viên quầy; không áp dụng với khách (khách chọn vé trong danh sách vé của mình) | Trùng mã đặt vé của một lần đặt; mã duy nhất trên toàn hệ thống (REQ-106); không trùng thì luồng 1a1a | CB0001234 |
| 2 | Vé cần huỷ (bước 1, 1a3) | Một vé (một ghế) mà tác nhân muốn huỷ | Có | Khách: một vé trong các vé khách đã mua trực tuyến (BR-17). Nhân viên quầy: một vé trong lần đặt của mã đặt vé, mua tại quầy của cụm rạp mình (BR-17) | Vé ghế F7 của mã đặt vé CB0001234 |

Dữ liệu ra 1 (bước 8, bước 5a1)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Vé đã huỷ | Mã đặt vé, tên phim, tên cụm rạp, tên phòng chiếu, ngày giờ bắt đầu suất chiếu, vị trí ghế của vé (REQ-105) | Ngày giờ dạng dd/mm/yyyy hh:mm; các trường còn lại là văn bản | CB0001234, Phim A, Cụm rạp X, Phòng 3, 15/11/2026 19:30, F7 |
| 2 | Giá vé | Giá vé ghi trên vé, đã tính theo bảng giá khi bán (BR-11, REQ-105) | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 120.000 đ |
| 3 | Số tiền hoàn | 70% giá vé (BR-19), làm tròn xuống đồng gần nhất khi không là số nguyên đồng (BR-31) | Như giá vé | 84.000 đ (70% x 120.000) |
| 4 | Hình thức hoàn tiền | Qua cổng thanh toán với vé mua trực tuyến; bằng tiền mặt tại quầy với vé mua tại quầy (BR-20) | Văn bản | Qua cổng thanh toán |
| 5 | Tình trạng hoàn tiền (bước 8) | Đã hoàn, hoặc chưa hoàn được và khoản hoàn được xử lý thủ công ngoài hệ thống (BR-41) | Văn bản | Đã hoàn |

Dữ liệu ra 2 (bước 1a2)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Các vé của lần đặt | Với mỗi vé: vị trí ghế, giá vé và trạng thái vé (chưa sử dụng, đã huỷ, đã sử dụng) | Mã hàng và số ghế; giá vé như Dữ liệu ra 1; trạng thái là văn bản | F7, 120.000 đ, chưa sử dụng |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-17 | Vé mua trực tuyến chỉ do khách đã mua huỷ trực tuyến; vé mua tại quầy chỉ do nhân viên quầy của cụm rạp đã bán vé huỷ tại quầy. | Ràng buộc | 2, 2a, 2b, 2c, Dữ liệu vào 1 | REQ-40, REQ-83; REQ-47, REQ-100 (phụ) | Mới |
| BR-18 | Vé chỉ được huỷ khi thời điểm huỷ cách giờ bắt đầu suất chiếu ít nhất 2 tiếng; quy tắc áp dụng cả khi huỷ vé mua tại quầy. | Ràng buộc | 3, 3a | REQ-41, REQ-84 | Mới |
| BR-19 | Số tiền hoàn của một vé bị huỷ bằng 70% giá vé của vé đó; quy tắc áp dụng cả khi huỷ vé mua tại quầy. | Tính toán | 5, 5a1, Dữ liệu ra 1 | REQ-42, REQ-85 | Mới |
| BR-20 | Vé mua trực tuyến được hoàn tiền qua cổng thanh toán; vé mua tại quầy được nhân viên quầy hoàn bằng tiền mặt. | Ràng buộc | 5, 5a, 5a2, Dữ liệu ra 1 | REQ-43, REQ-85 | Mới |
| BR-21 | Mỗi vé chỉ được huỷ và hoàn tiền một lần; vé đã huỷ không huỷ lại được. | Ràng buộc | 4, 4a | REQ-40, REQ-42, REQ-85; REQ-51 (phụ) | Mới |
| BR-26 | Tổng số tiền đã hoàn qua cổng thanh toán của các lần hoàn cho một giao dịch không vượt số tiền đã thanh toán của giao dịch. | Ràng buộc | 5 | REQ-35, REQ-42, REQ-109 | Mới |
| BR-41 | Khi cổng thanh toán từ chối hoàn tiền hoặc không trả lời, hệ thống tự thử lại yêu cầu hoàn tiền vài lần, chỉ sau khi tra cứu cho thấy khoản hoàn chưa được thực hiện; không tra cứu được thì không gửi lại tự động; nếu vẫn không hoàn được thì ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống và không gửi email cho khách. | Kích hoạt hành động | 5b, 5t, 5c, 6a, 6b | REQ-131 | Mới |
| BR-42 | Ghế của vé bị huỷ được trả về trạng thái trống sau khi vé được ghi nhận đã huỷ, kể cả khi hoàn tiền qua cổng thanh toán không thành công và khoản hoàn đã được ghi log lỗi. | Ràng buộc | 5c, 6b, 7 | REQ-131; REQ-44 (phụ) | Mới |
| BR-43 | Cổng thanh toán không trả lời yêu cầu hoàn tiền trong 30 giây thì coi là không phản hồi; mọi lần thử lại của cùng một yêu cầu hoàn dùng lại khoá chống hoàn trùng của yêu cầu hoàn đó; khoá gắn với từng yêu cầu hoàn và phân biệt được với khoá của yêu cầu hoàn khác trên cùng giao dịch (mã giao dịch kèm mã vé với hoàn tiền huỷ vé; mã giao dịch kèm loại yêu cầu hoàn toàn bộ với hoàn toàn bộ thanh toán trễ); việc tra cứu kết quả hoàn cũng dùng khoá này. | Ràng buộc | 5, 5b, 5c, 6a, 6b | REQ-132; REQ-78 (phụ) | Mới |
| BR-30 | Vé đã sử dụng không được huỷ; khi việc huỷ và việc soát cùng một vé xảy ra cùng lúc thì bên ghi nhận trước thành công, bên sau bị từ chối. | Ràng buộc | 4, 4b | REQ-118; REQ-51 (phụ) | Mới |
| BR-31 | Khi 70% giá vé không tròn đồng, số tiền hoàn của vé bị huỷ được làm tròn xuống đồng gần nhất. | Tính toán | 5, 5a1, Dữ liệu ra 1 | REQ-122; REQ-42, REQ-85 (phụ) | Mới |
| BR-32 | Thời điểm huỷ để so với hạn 2 tiếng là thời điểm hệ thống kiểm tra yêu cầu huỷ. | Ràng buộc | 3, 3a | REQ-121; REQ-41, REQ-84 (phụ) | Mới |
| BR-11 | Giá vé lấy theo bảng giá của cụm rạp có suất chiếu, phụ thuộc loại phòng, định dạng phim, loại ghế và khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi; ngày thường hoặc cuối tuần). | Tính toán | Dữ liệu ra 1 (giá vé là giá đã tính khi bán) | REQ-37, REQ-38 | Đã có |

## 7. Yêu cầu đặc biệt

| STT | Yêu cầu | Nhóm (FURPS+) | REQ |
|---|---|---|---|
| 1 | Ghế trả về trống ở bước 7 hiện trên sơ đồ ghế của người đang xem chậm nhất 3 giây sau khi ghế trở về trống. | Performance | REQ-119 |

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-01 Khách (tác nhân ghi đầu tiên ở P02). Bước 5 và bước 6 chỉ áp dụng cho khách; luồng 1a là kịch bản nhân viên quầy chọn vé bằng mã đặt vé rồi nhập lại luồng chính ở bước 2; luồng 5a là kịch bản huỷ vé mua tại quầy của ACT-02 Nhân viên quầy (P02 U-R10 b), hoàn tiền mặt thay cho hoàn qua cổng thanh toán, rồi nhập lại luồng chính ở bước 7. ACT-07 Cổng thanh toán không tham gia luồng 5a.
- Bước 4 gộp việc kiểm tra vé chưa huỷ, chưa sử dụng và việc ghi nhận vé đã huỷ thành một thao tác không chia cắt. Lý do: BR-21 đòi hỏi mỗi vé chỉ được hoàn tiền một lần; nếu kiểm tra và ghi nhận là hai bước tách rời, hai yêu cầu huỷ cùng một vé (hai tab của cùng một khách, hoặc hai nhân viên quầy) có thể cùng thấy vé chưa huỷ rồi cùng hoàn tiền. Yêu cầu tới sau gặp vé đã huỷ và kết thúc ở luồng 4a. Cơ chế bảo đảm điều này thuộc bước thiết kế (P07, P09).
- Kiểm tra và ghi trạng thái vé ở bước 4 của use case này và ở UC-009 bước 4, 5 phải loại trừ lẫn nhau trên cùng một vé; một vé không thể đồng thời ở trạng thái đã huỷ và đã sử dụng. Khi hai việc xảy ra cùng lúc, bên ghi nhận trước thắng và bên sau bị từ chối (BR-30): nếu việc soát được ghi nhận trước thì huỷ kết thúc ở luồng 4b; nếu việc huỷ được ghi nhận trước thì UC-009 báo lý do vé đã huỷ ở luồng 4e.
- Điều kiện chưa huỷ (luồng 4a) được kiểm trước điều kiện chưa sử dụng (luồng 4b). Vé đã huỷ không bao giờ đồng thời đã sử dụng.
- Với vé mua tại quầy, việc ghi nhận huỷ (bước 4), xác nhận hoàn tiền mặt (bước 5a2) và trả ghế (bước 7) là một thao tác không chia cắt (trả lời Q-125): nhân viên quầy luôn hoàn được tiền mặt nên không có trạng thái vé đã huỷ mà chưa hoàn tiền mặt, và ghế trả về trống khi huỷ. Trên activity diagram thể hiện bằng ghi chú N-4q không có cạnh. Việc hoàn tiền mặt tại quầy luôn thực hiện được, nên use case không có luồng hoàn tiền mặt không thành công; chỉ hoàn qua cổng thanh toán mới có thể không thành công (luồng 5c, 6b).
- Tình trạng hoàn tiền ghi ở bước 7 phân biệt khoản đã hoàn với khoản chưa hoàn được và đã ghi log lỗi. Doanh thu (REQ-99) chỉ trừ khoản có tình trạng đã hoàn, theo đề bài Mục 17 ("phần tiền đã hoàn cho khách"); khoản chưa hoàn được không trừ cho tới khi được xử lý thủ công ngoài hệ thống.
- Ghế trả về trống ở bước 7 có thể rơi sau giờ bắt đầu suất chiếu khi việc thử lại hoàn tiền kéo dài qua giờ đó (bước 3 chỉ bảo đảm lúc kiểm tra còn cách giờ bắt đầu ít nhất 2 tiếng). Ghế đó không bán lại được vì UC-005 bước 2 từ chối bán từ giờ bắt đầu suất chiếu (BR-45); use case này không kiểm thêm điều kiện nào ở bước 7.
- Do BR-17, một vé chỉ có đúng một kênh huỷ (khách trực tuyến hoặc nhân viên quầy), nên tình huống khách và nhân viên quầy cùng huỷ một vé không xảy ra trọn vẹn: yêu cầu của tác nhân sai kênh bị từ chối ở luồng 2a hoặc 2b. Tình huống huỷ đồng thời có thể xảy ra giữa hai yêu cầu cùng kênh.
- Với vé mua trực tuyến, vé được ghi nhận huỷ ở bước 4, trước khi hoàn tiền (bước 5, 6). Ghế vẫn ở trạng thái đã bán cho tới bước 7. Khi hoàn tiền không hoàn tất, hệ thống tự thử lại theo BR-41 rồi ghi log lỗi khoản hoàn (luồng 5c, 6b) và vẫn trả ghế về trống ở bước 7 (BR-42); khoản hoàn được xử lý thủ công ngoài hệ thống, nằm ngoài phạm vi, không có use case. Vì mọi đường đi đều qua bước 7 nên không có trạng thái vé đã huỷ mà ghế không bao giờ trống. Mỗi yêu cầu hoàn dùng khoá chống hoàn trùng gồm mã giao dịch và mã vé vì một giao dịch có thể có nhiều lần hoàn 70% của nhiều vé (BR-43, BR-26). Số lần thử lại và khoảng cách giữa hai lần thử là quyết định thiết kế (P09); đặc tả chỉ cố định thời hạn chờ 30 giây (BR-43).
- Bước 7 là bước duy nhất làm ghế trở về trống; sau bước 7 ghế được xử lý như mọi ghế trống (chọn, giữ, mua theo UC-005) và hiện trên sơ đồ ghế của người đang xem chậm nhất 3 giây (REQ-119, Mục 7).
- Mỗi lần huỷ một vé (huỷ từng vé, REQ-40). Ghế đôi là một ghế (REQ-87) nên một vé ghế đôi trả đúng một ghế về trống.
- Hạn huỷ vé: giờ bắt đầu suất chiếu trừ 2 tiếng (BR-18). Ví dụ: suất chiếu 19:30 ngày 15/11/2026 --> hạn huỷ vé 17:30 cùng ngày (19:30 - 2:00); huỷ lúc 17:30 còn được (đúng 2 tiếng là "ít nhất 2 tiếng"), huỷ lúc 17:31 bị từ chối ở luồng 3a. Mốc thời điểm huỷ là thời điểm hệ thống kiểm tra ở bước 3 (BR-32), không phải lúc tác nhân gửi yêu cầu.
- Ví dụ làm tròn (BR-31): giá vé 85.555 đ --> 70% là 59.888,5 đ --> số tiền hoàn 59.888 đ.
- Nếu nhân viên quầy nhập mã đặt vé không tồn tại thì không có vé nào để chọn: luồng 1a1a thông báo mã không tồn tại và cho nhập lại (cách thông báo cụ thể do bước thiết kế quyết định).
- Nguồn không nêu việc gửi email khi huỷ vé (REQ-90 chỉ áp dụng cho hoàn tiền thanh toán đến trễ ở UC-006), nên use case không gọi dịch vụ email và P02 không gán ACT-08 cho UC-008. Khi hoàn tiền không thành công, hệ thống cũng không gửi email cho khách (BR-41).
- Nguồn không nêu bước xác nhận của tác nhân trước khi huỷ; đặc tả không thêm bước này.
- UC-008 không tạo, đổi hay làm mất hiệu lực mốc nào của use case do tác nhân thời gian kích hoạt (EV-06 chỉ gắn với giữ ghế của UC-005).
- Bước thông báo kết quả cho tác nhân ở luồng 1a1a, 2a, 2b, 2c, 3a, 4a, 4b và hành động "Từ chối ... và thông báo quy tắc bị vi phạm" ở luồng 2a, 2b, 2c, 3a, 4b sinh theo Target 5a và F5.7. Luồng 5b, 5t, 6a thử lại hoặc tra cứu nên không thông báo cho tác nhân; luồng 5c, 6b nhập lại luồng chính và tình trạng hoàn tiền được báo ở bước 8.

## 8a. Kịch bản chính

- KB1: Luồng chính --> khách huỷ vé mua trực tuyến, nhận hoàn 70% qua cổng thanh toán, ghế trở về trống.
- KB2: Luồng chính + 1a tới bước 4 + 5a --> nhân viên quầy huỷ vé mua tại quầy, hoàn 70% tiền mặt, ghế trở về trống (bước 7, 8).
- KB3: Luồng chính + 3a --> huỷ khi còn chưa tới 2 tiếng trước giờ bắt đầu của suất chiếu, bị từ chối, vé và ghế không đổi.
- KB4: Luồng chính + 4a --> hai yêu cầu huỷ cùng một vé: yêu cầu đầu hoàn tiền một lần, yêu cầu sau nhận thông báo vé đã huỷ.
- KB5: Luồng chính + 5b hoặc 6a --> cổng không phản hồi hoặc báo hoàn tiền thất bại, hệ thống tra cứu (5t): đã hoàn thì tiếp tục bước 7, chưa hoàn và còn lượt thì thử lại; chưa hoàn mà hết lượt hoặc không tra cứu được (5c hoặc 6b) thì ghi log lỗi để xử lý thủ công ngoài hệ thống, vé đã huỷ, ghế vẫn trả về trống.
- KB6: Luồng chính + 4b --> vé đã được soát vào rạp, bị từ chối huỷ.
- KB7: Luồng chính + 1a --> nhân viên quầy nhập mã đặt vé, chọn vé rồi huỷ; mã không tồn tại thì nhập lại (1a1a).

## 9. Activity diagram

File: diagrams/P04-activity-UC-008.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 1a, 1a1, 1a1a, 1a2, 1a3 | M-1a, A-1a1, D-1a, A-1a1a, A-1a2, A-1a3 |
| 2 | M-2, A-2, D-2 |
| 2a, 2b, 2c | A-2a, A-2b, A-2c, FINAL-1 |
| 3 | A-3, D-3 |
| 3a | A-3a, FINAL-2 |
| 4 | A-4, D-4, N-4q |
| 4a | A-4a, FINAL-3 |
| 4b | A-4b, FINAL-4 |
| 5 | D-5, M-5, A-5 |
| 5a, 5a1, 5a2 | A-5a1, A-5a2 |
| 5b, 6a | M-R |
| 5b | D-5w |
| 5t | A-5t, D-5t, D-R (nhánh [còn lượt thử lại] trở về M-5) |
| 5c, 6b | D-5t, D-R, M-6c, A-6c |
| 6 | A-6, D-6 |
| 7 | M-7, A-7 |
| 8 | A-8, FINAL-7 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-01-02 | Partition | Khách / Nhân viên quầy | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=780 |
| P-ACT-07 | Partition | Cổng thanh toán | - | - | - | x=1340, w=300 |
| INIT | Initial | - | - | P-ACT-01-02 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-01-02 | 1, 1a | x=130, y=120 (tương đối partition) |
| A-1 | Action | Chọn vé trực tuyến cần huỷ và yêu cầu huỷ | - | P-ACT-01-02 | 1 | x=60, y=180 (tương đối partition) |
| M-1a | Merge | - | - | P-ACT-01-02 | 1a1, 1a1a | x=380, y=120 (tương đối partition) |
| A-1a1 | Action | Nhập mã đặt vé | - | P-ACT-01-02 | 1a1 | x=310, y=180 (tương đối partition) |
| D-1a | Decision | - | - | P-SYS | 1a1a | x=130, y=200 (tương đối partition) |
| A-1a1a | Action | Thông báo mã đặt vé không tồn tại | - | P-SYS | 1a1a | x=300, y=190 (tương đối partition) |
| A-1a2 | Action | Hiển thị các vé của lần đặt | - | P-SYS | 1a2 | x=60, y=280 (tương đối partition) |
| A-1a3 | Action | Chọn vé cần huỷ và yêu cầu huỷ | - | P-ACT-01-02 | 1a3 | x=310, y=370 (tương đối partition) |
| M-2 | Merge | - | - | P-SYS | 2 | x=130, y=500 (tương đối partition) |
| A-2 | Action | Kiểm tra kênh mua vé và cụm rạp | - | P-SYS | 2 | x=60, y=570 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2a, 2b, 2c | x=130, y=660 (tương đối partition) |
| A-2a | Action | Từ chối: khách huỷ vé không phải vé trực tuyến của mình (BR-17) | - | P-SYS | 2a | x=300, y=540 (tương đối partition) |
| A-2b | Action | Từ chối: nhân viên quầy huỷ vé trực tuyến (BR-17) | - | P-SYS | 2b | x=300, y=640 (tương đối partition) |
| A-2c | Action | Từ chối: vé quầy của cụm rạp khác (BR-17) | - | P-SYS | 2c | x=300, y=740 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=520, y=660 (tương đối partition) |
| A-3 | Action | Kiểm tra hạn huỷ vé 2 tiếng | - | P-SYS | 3 | x=60, y=810 (tương đối partition) |
| D-3 | Decision | - | - | P-SYS | 3a | x=130, y=900 (tương đối partition) |
| A-3a | Action | Từ chối: quá hạn huỷ vé (BR-18) | - | P-SYS | 3a | x=300, y=890 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=520, y=900 (tương đối partition) |
| A-4 | Action | Kiểm tra vé chưa huỷ, chưa dùng; ghi nhận huỷ | - | P-SYS | 4 | x=60, y=980 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a, 4b | x=130, y=1070 (tương đối partition) |
| N-4q | Note | 4: Vé quầy: ghi nhận huỷ, hoàn tiền mặt (5a2) và trả ghế (7) là một thao tác không chia cắt, không có trạng thái đã huỷ chờ hoàn tiền mặt (Q-125) | - | P-ACT-01-02 | 4, 5a2 | x=300, y=1000, w=240, h=90 (tương đối partition) |
| A-4a | Action | Thông báo vé đã huỷ (BR-21) | - | P-SYS | 4a | x=300, y=1020 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | - | x=520, y=1030 (tương đối partition) |
| A-4b | Action | Từ chối: vé đã sử dụng (BR-30) | - | P-SYS | 4b | x=300, y=1110 (tương đối partition) |
| FINAL-4 | ActivityFinal | - | - | P-SYS | - | x=520, y=1120 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5, 5a | x=130, y=1170 (tương đối partition) |
| A-5a1 | Action | Hiển thị số tiền mặt cần hoàn | - | P-SYS | 5a1 | x=300, y=1200 (tương đối partition) |
| A-5a2 | Action | Hoàn tiền mặt, xác nhận đã hoàn | - | P-ACT-01-02 | 5a2 | x=120, y=1350 (tương đối partition) |
| M-5 | Merge | - | - | P-SYS | 5, 5b, 6a | x=130, y=1240 (tương đối partition) |
| A-5 | Action | Yêu cầu cổng hoàn 70% giá vé kèm mã giao dịch và mã vé | - | P-SYS | 5 | x=60, y=1310 (tương đối partition) |
| D-5w | Decision | - | - | P-SYS | 5b | x=130, y=1400 (tương đối partition) |
| A-6 | Action | Báo kết quả hoàn tiền | - | P-ACT-07 | 6 | x=60, y=1470 (tương đối partition) |
| D-6 | Decision | - | - | P-SYS | 6a, 6b | x=130, y=1580 (tương đối partition) |
| M-R | Merge | - | - | P-SYS | 5b, 6a | x=320, y=1580 (tương đối partition) |
| A-5t | Action | Tra cứu cổng xem khoản hoàn đã thực hiện chưa, kèm khoá yêu cầu hoàn (BR-43) | - | P-SYS | 5t | x=340, y=1560 (tương đối partition) |
| D-5t | Decision | - | - | P-SYS | 5t, 5c, 6b | x=520, y=1580 (tương đối partition) |
| D-R | Decision | - | - | P-SYS | 5t, 5c, 6b | x=520, y=1480 (tương đối partition) |
| M-6c | Merge | - | - | P-SYS | 5c, 6b | x=570, y=1590 (tương đối partition) |
| A-6c | Action | Ghi log lỗi khoản hoàn, xử lý thủ công ngoài hệ thống, không email khách (BR-41, BR-42) | - | P-SYS | 5c, 6b | x=500, y=1660 (tương đối partition) |
| M-7 | Merge | - | - | P-SYS | 7 | x=130, y=1760 (tương đối partition) |
| A-7 | Action | Ghi nhận khoản hoàn kèm tình trạng, trả ghế của vé về trạng thái trống (BR-42) | - | P-SYS | 7 | x=60, y=1830 (tương đối partition) |
| A-8 | Action | Thông báo huỷ thành công, hiển thị số tiền hoàn và tình trạng hoàn tiền | - | P-SYS | 8 | x=60, y=1930 (tương đối partition) |
| FINAL-7 | ActivityFinal | - | - | P-SYS | - | x=130, y=2030 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [khách] | - | - |
| E-03 | D-1 | M-1a | ControlFlow | [nhân viên quầy] | - | - |
| E-04 | M-1a | A-1a1 | ControlFlow | - | - | - |
| E-05 | A-1a1 | D-1a | ControlFlow | - | - | - |
| E-06 | D-1a | A-1a1a | ControlFlow | [mã đặt vé không trùng lần đặt nào] | - | - |
| E-07 | A-1a1a | M-1a | ControlFlow | - | - | (950,100); (400,100) |
| E-08 | D-1a | A-1a2 | ControlFlow | [khác] | - | - |
| E-09 | A-1a2 | A-1a3 | ControlFlow | - | - | - |
| E-10 | A-1 | M-2 | ControlFlow | - | - | (150,520) |
| E-11 | A-1a3 | M-2 | ControlFlow | - | - | (400,520) |
| E-12 | M-2 | A-2 | ControlFlow | - | - | - |
| E-13 | A-2 | D-2 | ControlFlow | - | - | - |
| E-14 | D-2 | A-2a | ControlFlow | [khách, không phải vé trực tuyến của mình] | - | (840,680); (840,580) |
| E-15 | D-2 | A-2b | ControlFlow | [nhân viên quầy, vé trực tuyến] | - | - |
| E-16 | D-2 | A-2c | ControlFlow | [nhân viên quầy, vé quầy cụm khác] | - | (840,680); (840,780) |
| E-17 | D-2 | A-3 | ControlFlow | [khác] | - | - |
| E-18 | A-2a | FINAL-1 | ControlFlow | - | - | (1100,580) |
| E-19 | A-2b | FINAL-1 | ControlFlow | - | - | - |
| E-20 | A-2c | FINAL-1 | ControlFlow | - | - | (1100,780) |
| E-21 | A-3 | D-3 | ControlFlow | - | - | - |
| E-22 | D-3 | A-3a | ControlFlow | [còn chưa tới 2 tiếng] | - | - |
| E-23 | D-3 | A-4 | ControlFlow | [khác] | - | - |
| E-24 | A-3a | FINAL-2 | ControlFlow | - | - | - |
| E-25 | A-4 | D-4 | ControlFlow | - | - | - |
| E-26 | D-4 | A-4a | ControlFlow | [vé đã huỷ] | - | (840,1090); (840,1050) |
| E-27 | D-4 | A-4b | ControlFlow | [vé đã sử dụng] | - | (840,1090); (840,1140) |
| E-28 | D-4 | D-5 | ControlFlow | [khác] | - | - |
| E-29 | A-4a | FINAL-3 | ControlFlow | - | - | - |
| E-30 | A-4b | FINAL-4 | ControlFlow | - | - | - |
| E-31 | D-5 | A-5a1 | ControlFlow | [nhân viên quầy] | - | - |
| E-32 | D-5 | M-5 | ControlFlow | [khách] | - | - |
| E-33 | A-5a1 | A-5a2 | ControlFlow | - | - | (1010,1300); (210,1300) |
| E-36 | A-5a2 | M-7 | ControlFlow | - | - | (210,1790) |
| E-39 | M-5 | A-5 | ControlFlow | - | - | - |
| E-40 | A-5 | D-5w | ControlFlow | - | - | - |
| E-41 | D-5w | A-6 | ControlFlow | [có kết quả trong 30 giây] | - | (1490,1420) |
| E-42 | D-5w | M-R | ControlFlow | [không phản hồi trong 30 giây] | - | (900,1420) |
| E-43 | A-6 | D-6 | ControlFlow | - | - | (1490,1550); (710,1550) |
| E-44 | D-6 | M-R | ControlFlow | [hoàn tiền thất bại] | - | - |
| E-45 | D-6 | M-7 | ControlFlow | [thành công] | - | - |
| E-46 | M-R | A-5t | ControlFlow | - | - | - |
| E-47 | D-R | M-5 | ControlFlow | [còn lượt thử lại] | - | (1100,1280) |
| E-48 | D-R | M-6c | ControlFlow | [hết lượt thử lại] | - | (1150,1500) |
| E-49 | A-6c | M-7 | ControlFlow | - | - | (1060,1790) |
| E-50 | M-7 | A-7 | ControlFlow | - | - | - |
| E-51 | A-7 | A-8 | ControlFlow | - | - | - |
| E-52 | A-8 | FINAL-7 | ControlFlow | - | - | - |
| E-53 | A-5t | D-5t | ControlFlow | - | - | - |
| E-54 | D-5t | D-R | ControlFlow | [chưa hoàn] | - | - |
| E-55 | D-5t | M-7 | ControlFlow | [đã hoàn] | - | (1260,1600); (1260,1780) |
| E-56 | D-5t | M-6c | ControlFlow | [không tra cứu được] | - | - |
| E-57 | M-6c | A-6c | ControlFlow | - | - | - |

Partition P-ACT-01-02 dùng chung cho ACT-01 Khách và ACT-02 Nhân viên quầy (F10.4); A-1 chỉ khách thực hiện, A-1a1, A-1a3, A-5a2 chỉ nhân viên quầy thực hiện. D-1 đặt trong partition của tác nhân vì tác nhân chọn kịch bản chọn vé. D-5 đặt trong partition hệ thống vì hệ thống phân biệt tác nhân theo kênh mua vé (BR-20), không phải tác nhân tự chọn. D-5w đặt sau A-5 vì thời hạn chờ 30 giây bắt đầu từ bước 5. Merge M-2 đứng trước A-2, M-5 đứng trước A-5 và M-6c đứng trước A-6c để mỗi action chỉ có một cạnh vào; cạnh E-47 quay lại M-5. Luồng 5b, 6a dùng chung M-R, D-R với 5c, 6b và không có action riêng; luồng 5c, 6b và 5a nhập lại luồng chính ở M-7. Mã cạnh E-34, E-35, E-37, E-38 không dùng. ACT-08 không tham gia use case này nên không có partition.


## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-125 | Đã trả lời (quyết định của người dùng: nhân viên quầy luôn hoàn được tiền mặt nên hoàn tiền mặt và xác nhận nằm cùng thao tác huỷ tại quầy; không có trạng thái đã huỷ chờ hoàn tiền mặt; ghế trả về trống khi huỷ). Với vé mua tại quầy, nếu vé đã được ghi nhận huỷ ở bước 4 trước khi nhân viên xác nhận hoàn tiền mặt thì ghế trả về trống và khoản hoàn được ghi nhận khi nào? | Bước 4, 5a2, 7 | Luồng 5a và bước 7 không nêu trường hợp nhân viên không xác nhận |
| Q-34 | Đã trả lời (Vé vẫn tính là đã huỷ, ghế vẫn trả về trống, khoản hoàn ghi log lỗi và xử lý thủ công ngoài hệ thống; đáp án cũ "ghế chưa trả về trống cho tới khi hoàn tiền xong" đã bị thay theo quyết định sau review cuối; trường hợp nhân viên quầy không hoàn được tiền mặt bị bỏ vì không xảy ra), đề bài bổ sung Mục 11, Mục 12. Khi hoàn tiền của UC-008 không hoàn tất (cổng thanh toán báo thất bại hoặc không phản hồi ở bước 6; vé đã được ghi nhận huỷ ở bước 4, ghế vẫn đã bán), vé và ghế ở trạng thái nào: vé trở lại hiệu lực và ghế giữ nguyên, hay vé vẫn huỷ và ghế trả về trống? Chính sách thử lại và báo cho ai theo Q-29, thời hạn chờ theo Q-30. | Luồng 5c, 6b; Hậu điều kiện tối thiểu; thứ tự bước 4 đến 7 | Mục 11 chỉ nêu "hoàn 70% giá vé qua cổng thanh toán và trả ghế về trạng thái trống", không nêu hoàn tiền không hoàn tất |
| Q-35 | Đã trả lời (Vé đã sử dụng không được huỷ; cùng lúc thì bên ghi nhận trước thắng), đề bài bổ sung Mục 11. Vé đã sử dụng (đã soát) mà vẫn còn trước hạn huỷ 2 tiếng có được huỷ không, và khi một vé vừa được huỷ vừa được soát cùng lúc (UC-009) thì bên nào được ưu tiên? (Vé đã sử dụng không được huỷ, bên ghi nhận trước thắng / Được huỷ như vé chưa dùng / Phương án khác) | Luồng 4a, 4b; bước 4; UC-009 luồng 4d, 4e; BR-21, BR-24, BR-25 | Mục 11 chỉ nêu hạn 2 tiếng; Mục 13 nêu vé có trạng thái "đã sử dụng" và "bị huỷ" nhưng không nêu mối quan hệ với việc huỷ vé |
| Q-36 | Gộp vào Q-30 | - | - |
| Q-37 | Đã trả lời (Có, cùng ngưỡng 3 giây), đề bài bổ sung Mục 4. Mọi lần ghế trở về trống (huỷ vé ở UC-008 bước 7; hết hạn giữ ghế luồng 7b, huỷ giữ ghế luồng *a, thanh toán thất bại luồng 11a của UC-005) có phải hiện lên sơ đồ ghế của người đang xem chậm nhất 3 giây như REQ-19 không? | Bước 7; UC-005 luồng 7b, *a, 11a; Mục 7 Yêu cầu đặc biệt; P06 | Mục 4 chỉ nêu sơ đồ ghế tự cập nhật khi người khác giữ hoặc mua ghế; Mục 11 chỉ nêu "trả ghế về trạng thái trống" |
| Q-38 | Đã trả lời (Mã đặt vé rồi chọn vé trong đó), đề bài bổ sung Mục 12. Nhân viên quầy xác định vé cần huỷ bằng thông tin nào (mã đặt vé, mã QR của vé, thông tin khác)? | Bước 1; Dữ liệu vào 1 | Mục 12 chỉ nêu "Vé mua tại quầy được huỷ tại quầy của cụm rạp đã bán vé" |
| Q-39 | Đã trả lời (Lúc hệ thống kiểm tra), đề bài bổ sung Mục 11. Mốc thời điểm huỷ để so với hạn 2 tiếng là lúc tác nhân gửi yêu cầu huỷ hay lúc hệ thống kiểm tra (bước 3)? | Bước 3; luồng 3a | Mục 11, Mục 12 chỉ nêu "trước giờ chiếu ít nhất 2 tiếng" |
| Q-40 | Đã trả lời (Làm tròn xuống đồng gần nhất), đề bài bổ sung Mục 11. Khi 70% giá vé không là số nguyên đồng thì làm tròn thế nào? | Dữ liệu ra 1 (Số tiền hoàn); bước 5, 5a1 | Mục 11, Mục 12 chỉ nêu "hoàn 70% giá vé" |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Thứ tự bước 4 (ghi nhận huỷ) trước bước 5 và 6 (hoàn tiền) khác thứ tự câu nguồn (hoàn tiền rồi trả ghế, Mục 11). Thứ tự được chọn để BR-21 (hoàn một lần) giữ được khi có hai yêu cầu đồng thời; hệ quả khi hoàn tiền không hoàn tất đã chốt ở BR-41, BR-42.
- Thời hạn chờ 30 giây ở luồng 5b theo BR-43 là ngưỡng thời gian chờ của hệ thống, không phải vùng ngắt trên sơ đồ.
- Luồng 5t: tra cứu trước khi gửi lại bảo đảm khoản hoàn không bị thực hiện hai lần khi cổng đã hoàn nhưng kết quả không về (BR-21, BR-26). Không có kết cục nghiệp vụ mới: nơi kết thúc vẫn là ghi log lỗi khoản hoàn để xử lý thủ công (5c, 6b) rồi tiếp tục bước 7.
- Ngoài phạm vi: xử lý thủ công khoản hoàn đã ghi log lỗi (luồng 5c, 6b) diễn ra ngoài hệ thống, không có use case (REQ-131).
- Sơ đồ có các cạnh nhập về M-7, cạnh quay về M-5 và cạnh vượt partition, điểm uốn ghi trong bảng Edge; một số cạnh giao nhau nhưng không cạnh nào cắt qua node.
- Guard của nhánh luồng chính tại D-2, D-3, D-4, D-1a ghi "[khác]" (F10.3 cho phép); điều kiện đầy đủ ở bảng luồng thay thế.
