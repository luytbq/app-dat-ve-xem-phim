# P04 - Đặc tả use case UC-006 Hoàn tiền thanh toán trễ - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.4 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.8; P01-actors.md 1.1; P02-usecases.md 1.6; P03-usecase-model.md 1.0 (Mục 1, Mục 2); _BR-register.md (đã gộp BR-01 đến BR-45); UC-005-book-tickets.md 1.5; _review-final-batch1.md; _review-final-batch1-recheck.md |
| Phạm vi | UC-006 |
| Mã Q, ASM cuối đã cấp | Q-51 (Q-48 và Q-51 đều đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-006 |
| Tên use case | Hoàn tiền thanh toán trễ (Refund Late Payment) |
| Tác nhân chính | ACT-07 Cổng thanh toán |
| Tác nhân phụ | ACT-08 Dịch vụ email (ACT-07 cũng thực hiện hoàn tiền, xem Mục 8) |
| Mô tả ngắn | Use case này mô tả tương tác giữa cổng thanh toán và hệ thống khi cổng báo một giao dịch thanh toán thành công vào lúc lần giữ ghế tương ứng đã hết hạn, đã bị khách huỷ hoặc đã được cổng báo thất bại, hoặc khi giao dịch là giao dịch thứ hai cho lần giữ ghế đã có vé từ một giao dịch khác. Kết quả là hệ thống không tạo vé, khách được hoàn toàn bộ số tiền qua cổng thanh toán và được báo qua email. Khi giao dịch không ứng với lần giữ ghế nào của hệ thống, use case chỉ ghi log lỗi để xử lý thủ công ngoài hệ thống, không hoàn tiền và không gửi email. Use case cũng nhận kết quả báo trùng của giao dịch đã xử lý và kết quả thất bại báo vào lúc muộn; các trường hợp này chỉ được ghi nhận, không hoàn tiền. |
| Sự kiện kích hoạt | Cổng thanh toán báo thanh toán thành công sau thời điểm hết hạn giữ ghế, hoặc sau khi khách đã huỷ giữ ghế hoặc cổng đã báo thất bại, hoặc báo thành công cho giao dịch hệ thống không nhận ra hoặc cho lần giữ ghế đã có vé, hoặc báo trùng một giao dịch thành công đã xử lý, hoặc báo kết quả thất bại vào lúc lần giữ ghế đã hết hạn hoặc đã bị huỷ, hoặc cho giao dịch đã có vé hoặc không nhận ra; ba trường hợp sau chỉ ghi nhận, không hoàn tiền (EV-08) |
| Tiền điều kiện | Với giao dịch do hệ thống tạo: hệ thống đã tạo giao dịch thanh toán qua cổng thanh toán cho một lần giữ ghế và ghi nhận số tiền của giao dịch (UC-005 bước 10). Giao dịch hệ thống không nhận ra (BR-38) không có điều kiện này. |
| Hậu điều kiện (thành công) | Không có vé nào được tạo từ giao dịch này.<br>Giao dịch được ghi nhận là thanh toán trễ và đã được hoàn toàn bộ số tiền qua cổng thanh toán.<br>Email thông báo hoàn tiền đã được gửi cho khách qua dịch vụ email. |
| Hậu điều kiện tối thiểu | Use case này không tạo vé ở bất kỳ luồng nào; giao dịch không bị hoàn toàn bộ quá một lần (BR-16, BR-37) và tổng các lần hoàn của giao dịch không vượt số tiền đã thanh toán (BR-26).<br>Khi kết thúc ở luồng 2a: lần báo trùng được ghi nhận, không có khoản hoàn mới; vé của giao dịch (nếu đã tạo ở UC-005) giữ nguyên.<br>Khi kết thúc ở luồng 2c hoặc 2d: kết quả thất bại được ghi nhận, không có khoản hoàn và không có vé nào được tạo từ giao dịch này.<br>Khi kết thúc ở luồng 2e: không có vé nào được tạo từ giao dịch này; giao dịch được ghi log lỗi để xử lý thủ công ngoài hệ thống, không có khoản hoàn và không có email (BR-38).<br>Khi kết thúc ở luồng 4b hoặc 5b: giao dịch đã được ghi nhận là thanh toán trễ (từ bước 3), chưa được hoàn tiền, khoản hoàn được ghi log lỗi để xử lý thủ công ngoài hệ thống; không có email cho khách (BR-41). |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-35, REQ-36, REQ-90, REQ-109 đến REQ-111, REQ-116, REQ-129 đến REQ-133, REQ-136 (theo P02 và P00 1.8); REQ-79, REQ-80 (P02 Mục 5 đã gắn UC-006); REQ-78 (tham chiếu, UC-005; lưu mã giao dịch), REQ-76 (tham chiếu, UC-005; mốc hết hạn so với thời điểm giải phóng ghế), REQ-11 (tham chiếu, UC-001; email của tài khoản khách), REQ-107 (tham chiếu, UC-001; Dữ liệu ra 1), REQ-105 (tham chiếu, UC-005; tên phim ở Dữ liệu ra 2) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Cổng thanh toán | Báo kết quả của một giao dịch thanh toán (xem Dữ liệu vào 1). |
| 2 | Hệ thống | Tra giao dịch theo mã giao dịch; với mã không phải của giao dịch hệ thống đã tạo thì tra lần giữ ghế theo mã tham chiếu lần giữ ghế kèm trong báo của cổng (REQ-136). Kiểm tra: kết quả là thành công, hệ thống nhận ra giao dịch (là giao dịch hệ thống đã tạo hoặc gắn được với một lần giữ ghế), giao dịch chưa được xử lý trước đó (chưa dùng để tạo vé ở UC-005 và chưa ghi nhận thanh toán trễ ở use case này, BR-37), và lần giữ ghế ứng với giao dịch đã hết hạn (BR-14), đã bị khách huỷ hoặc đã có báo thất bại của cổng thanh toán (BR-15), hoặc đã có vé từ một giao dịch khác (BR-40). |
| 3 | Hệ thống | Ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền và không tạo vé (BR-14, BR-15, BR-40). |
| 4 | Hệ thống | Yêu cầu cổng thanh toán hoàn toàn bộ số tiền đã thanh toán của giao dịch, kèm khoá chống hoàn trùng của yêu cầu hoàn này (mã giao dịch và loại yêu cầu hoàn toàn bộ); số tiền lấy từ giao dịch hệ thống đã tạo lúc thanh toán, hoặc từ báo của cổng với giao dịch thứ hai (REQ-136) (BR-14, BR-15, BR-16, BR-26, BR-40, BR-43). |
| 5 | Cổng thanh toán | Trả về kết quả hoàn tiền thành công. |
| 6 | Hệ thống | Ghi nhận giao dịch đã được hoàn toàn bộ số tiền. |
| 7 | Hệ thống | Gửi email thông báo hoàn tiền cho khách qua dịch vụ email (xem Dữ liệu ra 1, Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 2a | Kết quả là thành công và giao dịch đã được xử lý trước đó: đã dùng để tạo vé ở UC-005 hoặc đã ghi nhận thanh toán trễ ở use case này (cổng báo trùng, BR-37) | Hệ thống | Ghi nhận lần báo trùng, không tạo vé và không yêu cầu hoàn tiền thêm (BR-16, BR-37). | Kết thúc use case (thất bại) |
| 2b | Hệ thống nhận ra giao dịch, giao dịch chưa được xử lý trước đó, lần giữ ghế ứng với giao dịch còn hiệu lực (chưa hết hạn, chưa bị huỷ, chưa có báo thất bại) và chưa có vé; kết quả thành công hay thất bại đều do UC-005 xử lý | - | - | Kết thúc use case (thất bại) |
| 2c | Kết quả là thất bại và lần giữ ghế ứng với giao dịch đã hết hạn hoặc đã bị khách huỷ (BR-39) | Hệ thống | Ghi nhận kết quả thất bại và không hoàn tiền (BR-39). | Kết thúc use case (thất bại) |
| 2d | Kết quả là thất bại và không thuộc 2b, 2c: giao dịch đã có vé, giao dịch hệ thống không nhận ra, hoặc lần giữ ghế đã có báo thất bại trước đó (BR-39) | Hệ thống | Ghi nhận kết quả thất bại và không hoàn tiền (BR-39). | Kết thúc use case (thất bại) |
| 2e | Kết quả là thành công và hệ thống không nhận ra giao dịch (mã giao dịch không phải của giao dịch hệ thống đã tạo và báo của cổng không kèm mã tham chiếu lần giữ ghế nhận ra được, BR-38) | Hệ thống | Ghi log lỗi giao dịch để xử lý thủ công ngoài hệ thống; không tạo vé, không hoàn tiền, không gửi email (BR-38). | Kết thúc use case (thất bại) |
| 4a | Cổng thanh toán không phản hồi yêu cầu hoàn tiền trong 30 giây (BR-43) và còn lượt thử lại (BR-41) | - | - | Quay lại bước 4 |
| 4b | Cổng thanh toán không phản hồi trong 30 giây (BR-43) và đã hết lượt thử lại (BR-41) | Hệ thống | Ghi log lỗi khoản hoàn toàn bộ để xử lý thủ công ngoài hệ thống; không gửi email cho khách (BR-41). | Kết thúc use case (thất bại) |
| 5a | Cổng thanh toán trả về kết quả hoàn tiền thất bại và còn lượt thử lại (BR-41) | - | - | Quay lại bước 4 |
| 5b | Cổng thanh toán trả về kết quả hoàn tiền thất bại và đã hết lượt thử lại (BR-41) | Hệ thống | Ghi log lỗi khoản hoàn toàn bộ để xử lý thủ công ngoài hệ thống; không gửi email cho khách (BR-41). | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 1)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Mã giao dịch | Mã do cổng thanh toán cấp cho giao dịch; hệ thống nhận ra giao dịch do mình tạo và lần giữ ghế ứng với giao dịch qua mã này (REQ-78, REQ-111) | Có | Văn bản do cổng thanh toán cấp, hệ thống không quy định định dạng | GD-0001234 |
| 2 | Kết quả giao dịch | Kết quả cổng báo cho giao dịch | Có | Thành công hoặc thất bại; kết quả thành công được xử lý ở luồng chính, 2a, 2b hoặc 2e; kết quả thất bại ở 2b, 2c hoặc 2d | Thành công |
| 3 | Mã tham chiếu lần giữ ghế | Mã lần giữ ghế do hệ thống truyền cho cổng khi tạo giao dịch (UC-005 bước 10) và cổng trả lại trong báo; dùng để gắn giao dịch thứ hai (mã giao dịch khác mã đã lưu) với lần giữ ghế (BR-40, REQ-136) | Có với giao dịch thứ hai; giao dịch không kèm mã nhận ra được thì đi luồng 2e (BR-38) | Trùng mã của một lần giữ ghế của hệ thống | LG-0005678 |
| 4 | Số tiền đã thanh toán | Số tiền cổng báo cho giao dịch thứ hai, dùng làm số tiền hoàn của giao dịch đó (BR-40, REQ-136) | Có với giao dịch thứ hai | Số nguyên dương, không lớn hơn tổng tiền của lần giữ ghế | 240.000 đ |

Với giao dịch do hệ thống tạo ở UC-005 bước 10, số tiền đã thanh toán không nằm trong báo của cổng: hệ thống lấy từ giao dịch đã tạo (REQ-111). Giao dịch hệ thống không nhận ra không có giao dịch do hệ thống tạo nên không có số tiền; use case chỉ ghi log lỗi (luồng 2e, BR-38).

Dữ liệu ra 1 (bước 7)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Email nhận thông báo | Email của tài khoản khách đã giữ ghế (REQ-11, REQ-90) | Email theo định dạng chuẩn (REQ-107) | an.nguyen@example.com |
| 2 | Nội dung thông báo hoàn tiền | Nội dung email báo khách được hoàn tiền (REQ-90, REQ-116) | Gồm các trường ở Dữ liệu ra 2 | Xem Dữ liệu ra 2 |

Dữ liệu ra 2 (bước 7, nội dung email)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Mã giao dịch | Mã do cổng thanh toán cấp của giao dịch được hoàn (REQ-78) | Văn bản | GD-0001234 |
| 2 | Số tiền hoàn | Toàn bộ số tiền đã thanh toán của giao dịch (BR-26) | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 240.000 đ |
| 3 | Tên phim | Phim của suất chiếu mà khách đã giữ ghế (REQ-105) | Văn bản | Phim A |
| 4 | Suất chiếu | Ngày và giờ bắt đầu của suất chiếu | dd/mm/yyyy hh:mm | 15/11/2026 19:30 |
| 5 | Lý do hoàn | Một trong: lần giữ ghế đã hết hạn; khách đã huỷ giữ ghế; cổng đã báo thất bại; lần giữ ghế đã có vé từ giao dịch khác (BR-14, BR-15, BR-40) | Văn bản | Lần giữ ghế đã hết hạn |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-14 | Thanh toán thành công được báo về sau thời điểm hết hạn giữ ghế thì không tạo vé, kể cả khi ghế chưa được giải phóng; khách được hoàn toàn bộ số tiền. | Kích hoạt hành động | 2, 3, 4 | REQ-36, REQ-35 | Đã có |
| BR-15 | Thanh toán thành công được báo về sau khi khách đã huỷ việc giữ ghế hoặc sau khi cổng thanh toán đã báo thất bại, kể cả trước thời điểm hết hạn giữ ghế, thì không tạo vé; khách được hoàn toàn bộ số tiền và được báo qua email. | Kích hoạt hành động | 2, 3, 4, 7 | REQ-109 | Đã có |
| BR-16 | Mỗi giao dịch thanh toán trễ chỉ được hoàn toàn bộ số tiền một lần; kết quả báo trùng cho cùng một giao dịch không làm hoàn thêm. | Ràng buộc | 2a, 4 | REQ-35, REQ-109, REQ-110 | Mới |
| BR-26 | Tổng số tiền đã hoàn qua cổng thanh toán của các lần hoàn cho một giao dịch không vượt số tiền đã thanh toán của giao dịch. | Ràng buộc | 4 | REQ-35, REQ-42, REQ-109 | Mới |
| BR-37 | Mỗi giao dịch thanh toán thành công chỉ được xử lý một lần, hoặc tạo vé ở UC-005 hoặc hoàn toàn bộ ở UC-006; kết quả báo trùng của giao dịch đã được xử lý không tạo thêm vé và không hoàn thêm. | Ràng buộc | 2, 2a | REQ-110, REQ-35, REQ-109 | Mới |
| BR-38 | Thanh toán thành công của một giao dịch hệ thống không nhận ra được ghi log lỗi và để lại cho xử lý thủ công ngoài hệ thống; hệ thống không tạo vé, không tự hoàn tiền và không gửi email. | Kích hoạt hành động | 2e | REQ-129 | Mới |
| BR-39 | Kết quả thất bại mà cổng thanh toán báo vào lúc lần giữ ghế đã hết hạn hoặc đã bị khách huỷ, hoặc báo cho giao dịch đã có vé, hoặc báo cho giao dịch hệ thống không nhận ra, chỉ được ghi nhận, không hoàn tiền. | Kích hoạt hành động | 2c, 2d | REQ-133 | Mới |
| BR-40 | Thanh toán thành công của giao dịch thứ hai (mã giao dịch khác) gắn được với lần giữ ghế đã có vé qua mã tham chiếu lần giữ ghế kèm trong báo của cổng được xử lý như thanh toán trễ: không tạo vé và hoàn toàn bộ số tiền cổng báo cho giao dịch đó. | Kích hoạt hành động | 2, 3, 4 | REQ-130, REQ-136 | Mới |
| BR-41 | Khi cổng thanh toán từ chối hoàn tiền hoặc không trả lời, hệ thống tự thử lại yêu cầu hoàn tiền vài lần; nếu vẫn không hoàn được thì ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống và không gửi email cho khách. | Kích hoạt hành động | 4a, 4b, 5a, 5b | REQ-131 | Mới |
| BR-43 | Cổng thanh toán không trả lời yêu cầu hoàn tiền trong 30 giây thì coi là không phản hồi; mọi lần thử lại của cùng một yêu cầu hoàn dùng lại khoá chống hoàn trùng của yêu cầu hoàn đó; khoá gắn với từng yêu cầu hoàn và phân biệt được với khoá của yêu cầu hoàn khác trên cùng giao dịch (mã giao dịch kèm mã vé với hoàn tiền huỷ vé; mã giao dịch kèm loại yêu cầu hoàn toàn bộ với hoàn toàn bộ thanh toán trễ). | Ràng buộc | 4, 4a, 4b, 5a | REQ-132; REQ-78 (phụ) | Mới |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-07 Cổng thanh toán báo giao dịch thành công. Các tình huống (hết hạn giữ ghế theo BR-14; khách đã huỷ giữ ghế hoặc cổng đã báo thất bại trước đó theo BR-15; giao dịch thứ hai cho lần giữ ghế đã có vé theo BR-40) chỉ khác nhau ở điều kiện nhận biết tại bước 2; các bước sau như nhau. Giao dịch hệ thống không nhận ra không đi theo luồng chính mà kết thúc ở luồng 2e (BR-38).
- Mốc quyết định "đến trễ" theo đề bài (Mục 9) là thời điểm hệ thống nhận báo so với thời điểm hết hạn giữ ghế, không phải thời điểm ghế thực sự được giải phóng (có thể trễ tới 1 phút, REQ-76).
- ACT-07 vừa là tác nhân chính (bước 1: cổng tự báo kết quả vào thời điểm do cổng quyết định) vừa là tác nhân phụ (bước 4, 5: hệ thống gọi hoàn tiền và nhận kết quả), nên activity diagram chỉ có một partition cho ACT-07.
- Bước 2 và bước 3 phải là một thao tác không chia cắt trên cùng giao dịch. Lý do: BR-16 và BR-37 đòi hỏi mỗi giao dịch hoàn thành công không quá một lần; nếu hai lần báo trùng đến cùng lúc và cùng qua bước kiểm tra "chưa được xử lý" trước khi bước ghi nhận xảy ra, giao dịch bị yêu cầu hoàn hai lần. Cơ chế bảo đảm thuộc bước thiết kế (P07, P09).
- Bước 2 và bước 3 cũng là một thao tác không chia cắt với việc UC-005 chuyển ghế sang đã bán và tạo vé (UC-005 bước 11, 12) trên cùng lần giữ ghế: việc so thời điểm nhận báo với thời điểm hết hạn giữ ghế, và việc đánh dấu giao dịch là thanh toán trễ (bước 3) hoặc đánh dấu lần giữ ghế đã được dùng (UC-005 bước 12), phải xảy ra trong cùng một thao tác. Lý do: nếu tách rời, một ghế có thể vừa được bán cho giao dịch này vừa được giải phóng cho người khác, hoặc giao dịch vừa có vé vừa được hoàn toàn bộ tiền. Mỗi giao dịch thanh toán thành công đi theo đúng một trong UC-005 hoặc UC-006. Cơ chế bảo đảm thuộc bước thiết kế (P07, P09).
- Luồng 2b: kết quả (thành công hoặc thất bại) báo về khi lần giữ ghế còn hiệu lực và chưa có vé là kết quả trong phiên đặt vé, do UC-005 xử lý ở bước 11, 12 và luồng 11a (EV-07), không thuộc use case này. Giao dịch đã dùng để tạo vé ở UC-005 mà cổng báo trùng, kể cả sau thời điểm hết hạn giữ ghế, thuộc luồng 2a, không thuộc luồng chính (BR-37).
- Use case này không đổi trạng thái ghế: ghế được giải phóng bởi UC-005 (luồng 7b, 11a, *a).
- Bước 7 chỉ gửi đi, không chờ kết quả; việc gửi email không thành công do P06 đặc tả cơ chế.
- Tác nhân người không tham gia use case; khách chỉ nhận thông báo ở bước 7 (báo kết quả cho khách theo BR-15). Luồng 2a đến 2e, 4a, 4b, 5a, 5b không có tác nhân người tương tác và không có bước báo riêng cho khách; khi hoàn tiền không thành công, hệ thống không gửi email cho khách (BR-41).
- Mọi lần thử lại của cùng một yêu cầu hoàn dùng lại cùng khoá chống hoàn trùng. Khoá của use case này gồm mã giao dịch và loại yêu cầu hoàn toàn bộ; mỗi giao dịch thanh toán trễ chỉ có một yêu cầu hoàn toàn bộ (BR-16) nên khoá không trùng với khoá hoàn 70% từng vé của UC-008, gồm mã giao dịch và mã vé, vì một giao dịch có thể có nhiều lần hoàn 70% của nhiều vé (BR-43, BR-26).
- Thao tác "ghi nhận giao dịch chờ hoàn tiền" ở bước 3 bảo đảm log lỗi ở luồng 4b, 5b có đủ mã giao dịch và số tiền cần hoàn. Việc xử lý thủ công khoản hoàn đã ghi log lỗi (luồng 4b, 5b) và giao dịch không nhận ra (luồng 2e) diễn ra ngoài hệ thống, nằm ngoài phạm vi, không có use case. Số lần thử lại và khoảng cách giữa hai lần thử là quyết định thiết kế (P09); đặc tả chỉ cố định thời hạn chờ 30 giây (BR-43).
- Kết quả thất bại của cổng báo vào lúc lần giữ ghế còn hiệu lực thuộc UC-005 (EV-07). Kết quả thất bại báo vào lúc đã hết hạn hoặc đã bị khách huỷ chỉ được ghi nhận ở luồng 2c vì khách chưa mất tiền (BR-39). Kết quả thất bại báo cho giao dịch đã có vé, giao dịch hệ thống không nhận ra hoặc lần giữ ghế đã có báo thất bại trước đó cũng chỉ được ghi nhận, ở luồng 2d (BR-39).
- Giao dịch thứ hai (BR-40) có mã giao dịch khác mã của giao dịch đầu nên hệ thống chỉ gắn được nó với lần giữ ghế đã có vé qua mã tham chiếu lần giữ ghế kèm trong báo của cổng, và lấy số tiền hoàn từ báo của cổng; hệ thống truyền mã tham chiếu này cho cổng khi tạo giao dịch (UC-005 bước 10, trả lời Q-51). Nếu báo của cổng không kèm mã tham chiếu nhận ra được thì giao dịch không phân biệt được với giao dịch hệ thống không nhận ra và kết thúc ở luồng 2e.
- Với giao dịch hệ thống không nhận ra (BR-38), hệ thống không có giao dịch do mình tạo để lấy số tiền và không xác định được khách để gửi email, nên không tự hoàn tiền và không gửi email; hệ thống chỉ ghi log lỗi để xử lý thủ công ngoài hệ thống (luồng 2e, trả lời Q-48).

## 8a. Kịch bản chính

- KB1: Luồng chính (lần giữ ghế đã hết hạn, BR-14) --> không tạo vé, hoàn toàn bộ tiền, gửi email.
- KB2: Luồng chính (khách đã huỷ giữ ghế hoặc cổng đã báo thất bại trước đó, BR-15) --> không tạo vé, hoàn toàn bộ tiền, gửi email.
- KB3: Luồng chính tới bước 1 + 2a (cổng báo trùng, kể cả giao dịch đã dùng để tạo vé) --> ghi nhận lần báo trùng, không hoàn lần nữa.
- KB4: Luồng chính tới bước 1 + 2b (lần giữ ghế còn hiệu lực) --> không thuộc use case này, UC-005 xử lý.
- KB5: Luồng chính tới bước 4 + 4a hoặc 5a (cổng không phản hồi hoặc từ chối hoàn tiền) --> hệ thống thử lại; nếu hết lượt (4b hoặc 5b) thì ghi log lỗi để xử lý thủ công ngoài hệ thống, không email khách.
- KB6: Luồng chính tới bước 1 + 2c (cổng báo thất bại muộn) --> chỉ ghi nhận, không hoàn tiền.
- KB7: Luồng chính (giao dịch thứ hai cho lần giữ ghế đã có vé, BR-40) --> không tạo vé, hoàn toàn bộ tiền.
- KB8: Luồng chính tới bước 1 + 2d (thất bại không thuộc 2b, 2c) --> chỉ ghi nhận, không hoàn tiền.
- KB9: Luồng chính tới bước 1 + 2e (giao dịch thành công hệ thống không nhận ra) --> ghi log lỗi để xử lý thủ công ngoài hệ thống, không hoàn tiền, không email.

## 9. Activity diagram

File: diagrams/P04-activity-UC-006.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2, D-2 |
| 2a | A-2a, FINAL-1 |
| 2b | FINAL-2 |
| 2c, 2d | A-2c, A-2d, FINAL-4 |
| 2e | A-2e, FINAL-6 |
| 3 | A-3 |
| 4 | M-4, A-4, D-4 |
| 4a, 5a | M-R, D-R (nhánh [còn lượt thử lại] trở về M-4) |
| 4b, 5b | M-R, D-R, A-RX, FINAL-3 |
| 5 | A-5, D-5 |
| 6 | A-6 |
| 7 | A-7, FINAL-5 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-07 | Partition | Cổng thanh toán | - | - | - | x=0, w=300 |
| P-SYS | Partition | Hệ thống | - | - | - | x=300, w=700 |
| INIT | Initial | - | - | P-ACT-07 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Báo kết quả giao dịch thanh toán | - | P-ACT-07 | 1 | x=60, y=130 (tương đối partition) |
| A-2 | Action | Kiểm tra giao dịch và lần giữ ghế | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| D-2 | Decision | - | - | P-SYS | 2a, 2b, 2c, 2d, 2e | x=130, y=320 (tương đối partition) |
| A-2a | Action | Ghi nhận lần báo trùng, không hoàn tiền lần nữa (BR-16, BR-37) | - | P-SYS | 2a | x=320, y=230 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | - | x=560, y=240 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | - | x=320, y=320 (tương đối partition) |
| A-2c | Action | Ghi nhận thất bại báo muộn, không hoàn tiền (BR-39) | - | P-SYS | 2c | x=320, y=380 (tương đối partition) |
| FINAL-4 | ActivityFinal | - | - | P-SYS | - | x=560, y=420 (tương đối partition) |
| A-2d | Action | Ghi nhận thất bại khác, không hoàn tiền (BR-39) | - | P-SYS | 2d | x=320, y=460 (tương đối partition) |
| A-2e | Action | Ghi log lỗi giao dịch không nhận ra, xử lý thủ công ngoài hệ thống (BR-38) | - | P-SYS | 2e | x=320, y=560 (tương đối partition) |
| FINAL-6 | ActivityFinal | - | - | P-SYS | - | x=560, y=570 (tương đối partition) |
| A-3 | Action | Ghi nhận thanh toán trễ, không tạo vé | - | P-SYS | 3 | x=60, y=420 (tương đối partition) |
| M-4 | Merge | - | - | P-SYS | 4, 4a, 5a | x=130, y=520 (tương đối partition) |
| A-4 | Action | Yêu cầu cổng hoàn toàn bộ tiền kèm khoá yêu cầu hoàn | - | P-SYS | 4 | x=60, y=590 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a, 4b | x=130, y=680 (tương đối partition) |
| A-5 | Action | Trả kết quả hoàn tiền | - | P-ACT-07 | 5 | x=60, y=740 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5a, 5b | x=130, y=900 (tương đối partition) |
| M-R | Merge | - | - | P-SYS | 4a, 4b, 5a, 5b | x=320, y=900 (tương đối partition) |
| D-R | Decision | - | - | P-SYS | 4a, 4b, 5a, 5b | x=320, y=980 (tương đối partition) |
| A-RX | Action | Ghi log lỗi khoản hoàn, xử lý thủ công ngoài hệ thống, không email khách (BR-41) | - | P-SYS | 4b, 5b | x=250, y=1060 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | - | x=320, y=1170 (tương đối partition) |
| A-6 | Action | Ghi nhận giao dịch đã hoàn tiền | - | P-SYS | 6 | x=60, y=990 (tương đối partition) |
| A-7 | Action | Gửi email thông báo hoàn tiền | - | P-SYS | 7 | x=60, y=1090 (tương đối partition) |
| FINAL-5 | ActivityFinal | - | - | P-SYS | - | x=130, y=1190 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | D-2 | ControlFlow | - | - | - |
| E-04 | D-2 | A-2a | ControlFlow | [thành công, đã xử lý trước đó] | - | (415,340); (415,300); (605,300); (605,260) |
| E-05 | D-2 | FINAL-2 | ControlFlow | [giữ ghế còn hiệu lực, chưa có vé] | - | - |
| E-06 | D-2 | A-2c | ControlFlow | [thất bại, giữ ghế hết hạn hoặc bị huỷ] | - | (550,340); (550,410) |
| E-07 | D-2 | A-2d | ControlFlow | [thất bại khác] | - | (550,340); (550,490) |
| E-08 | D-2 | A-2e | ControlFlow | [thành công, không nhận ra, không gắn được lần giữ ghế] | - | (520,340); (520,590) |
| E-09 | D-2 | A-3 | ControlFlow | [thành công, cần hoàn toàn bộ] | - | - |
| E-10 | A-2a | FINAL-1 | ControlFlow | - | - | - |
| E-11 | A-2c | FINAL-4 | ControlFlow | - | - | - |
| E-12 | A-2d | FINAL-4 | ControlFlow | - | - | - |
| E-13 | A-2e | FINAL-6 | ControlFlow | - | - | - |
| E-14 | A-3 | M-4 | ControlFlow | - | - | - |
| E-15 | M-4 | A-4 | ControlFlow | - | - | - |
| E-16 | A-4 | D-4 | ControlFlow | - | - | - |
| E-17 | D-4 | M-R | ControlFlow | [không phản hồi trong 30 giây] | - | (640,700) |
| E-18 | D-4 | A-5 | ControlFlow | [có kết quả trong 30 giây] | - | (450,770) |
| E-19 | A-5 | D-5 | ControlFlow | - | - | (150,920) |
| E-20 | D-5 | M-R | ControlFlow | [hoàn tiền thất bại] | - | - |
| E-21 | D-5 | A-6 | ControlFlow | [thành công] | - | - |
| E-22 | M-R | D-R | ControlFlow | - | - | - |
| E-23 | D-R | M-4 | ControlFlow | [còn lượt thử lại] | - | (810,1000); (810,540) |
| E-24 | D-R | A-RX | ControlFlow | [hết lượt thử lại] | - | - |
| E-25 | A-RX | FINAL-3 | ControlFlow | - | - | - |
| E-26 | A-6 | A-7 | ControlFlow | - | - | - |
| E-27 | A-7 | FINAL-5 | ControlFlow | - | - | - |

Partition P-ACT-07 dùng cho ACT-07 Cổng thanh toán ở cả hai vai trò (bước 1 là tác nhân chính, bước 5 là tác nhân phụ). ACT-08 Dịch vụ email không có partition vì chỉ nhận thông tin (nằm trong nhãn A-7). Luồng 2b không có hành động nên không có action; cạnh mang guard đi thẳng từ decision tới final node. Luồng 2c và 2d dùng chung FINAL-4. Luồng 4a, 5a dùng chung M-R, D-R (hợp hai nhánh lỗi rồi quyết định thử lại) và không có action riêng; cạnh E-23 đi từ D-R về M-4, merge đặt ngay trước A-4 nên A-4 chỉ có một cạnh vào. Luồng 4b, 5b dùng chung A-RX, FINAL-3.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-27 | Đã trả lời (Chỉ không hoàn lại và ghi nhận lần báo trùng), đề bài bổ sung Mục 9. Khi cổng thanh toán báo trùng nhiều lần kết quả thành công cho cùng một giao dịch (đã hoàn xong hoặc đang hoàn), ngoài việc không hoàn lần nữa (BR-16), hệ thống còn làm gì: bỏ qua im lặng, ghi nhận lần báo trùng, phản hồi cho cổng thanh toán, hay gửi lại email? (Chỉ không hoàn lần nữa, không làm gì thêm / Ghi nhận và phản hồi cho cổng / Phương án khác). Có xác nhận BR-16 là quy tắc của dự án không? | Luồng 2a; BR-16; bước 7 | Mục 9 chỉ nêu "hoàn toàn bộ số tiền", không nói về báo trùng |
| Q-28 | Đã trả lời (Cổng báo kèm mã giao dịch; số tiền hoàn lấy từ giao dịch hệ thống đã tạo), đề bài bổ sung Mục 9. Báo kết quả giao dịch của cổng thanh toán gồm những thông tin gì (mã giao dịch, số tiền đã thanh toán, mã lần giữ ghế hoặc thông tin để hệ thống nhận ra lần giữ ghế), mã giao dịch có định dạng quy định không, và nếu báo không kèm số tiền thì lấy số tiền hoàn từ đâu? (Báo kèm đủ mã giao dịch và số tiền / Số tiền lấy từ giao dịch hệ thống đã tạo ở UC-005 bước 10 / Phương án khác) | Dữ liệu vào 1; bước 2, 4 | Mục 21 chỉ nêu cổng "thông báo kết quả giao dịch về hệ thống (callback)" |
| Q-29 | Đã trả lời (Tự thử lại vài lần, vẫn lỗi thì ghi log lỗi để xử lý thủ công ngoài hệ thống, không email khách; phần đánh dấu cho quản trị của đáp án cũ đã bị thay), đề bài bổ sung Mục 21. Khi cổng thanh toán trả về hoàn tiền thất bại (từ chối; áp dụng chung cho UC-006 và UC-008 luồng 6a), hệ thống xử lý thế nào: thử lại tự động (bao nhiêu lần, cách nhau bao lâu), báo cho ai (khách, quản trị), có gửi email cho khách không, giao dịch giữ trạng thái gì? (Thử lại tự động / Báo để xử lý thủ công / Phương án khác) | Luồng 5a; hậu điều kiện tối thiểu; P06; UC-008 luồng 6a | Mục 9 chỉ nêu hoàn tiền thành công, không nêu hoàn tiền thất bại |
| Q-30 | Đã trả lời (Chờ 30 giây rồi thử lại theo Q-29, dùng khoá chống hoàn trùng gắn theo từng yêu cầu hoàn để cổng không hoàn hai lần; phần dùng mã giao dịch của đáp án cũ đã bị thay), đề bài bổ sung Mục 21. Khi cổng thanh toán không phản hồi yêu cầu hoàn tiền (áp dụng chung cho UC-006 và UC-008 luồng 6b), hệ thống chờ tối đa bao lâu, có thử lại không và việc thử lại có gây hoàn hai lần không (cổng đã hoàn nhưng báo kết quả không tới)? (Chờ trong thời hạn rồi thử lại / Chuyển xử lý thủ công / Phương án khác) | Luồng 4a; BR-16; P06; UC-008 luồng 6b | Mục 9, Mục 21 không nêu thời hạn chờ hay cách xử lý khi cổng không phản hồi |
| Q-31 | Đã trả lời (Bỏ qua, chỉ ghi nhận; áp dụng cả thất bại báo sau thành công, luồng 2d), đề bài bổ sung Mục 9. Khi cổng thanh toán báo giao dịch thất bại vào lúc đã muộn (sau thời điểm hết hạn giữ ghế hoặc sau khi khách huỷ giữ ghế), hoặc báo thất bại sau khi đã báo thành công, hệ thống xử lý thế nào: bỏ qua, ghi nhận, hay hoàn tiền? (Bỏ qua vì không có tiền cần hoàn / Ghi nhận / Phương án khác) | Phạm vi UC-006; UC-005 luồng 11a; Dữ liệu vào 1 | Mục 8, Mục 9 chỉ nêu kết quả thất bại báo trong thời gian giữ ghế và kết quả thành công báo trễ |
| Q-32 | Đã trả lời (Giao dịch thứ hai cho lần giữ ghế đã có vé: hoàn toàn bộ như thanh toán trễ; giao dịch không nhận ra: ghi log lỗi, xử lý thủ công ngoài hệ thống, theo Q-48), đề bài bổ sung Mục 9. Khi cổng thanh toán báo thành công cho một giao dịch mà hệ thống không nhận ra (không do hệ thống tạo, hoặc không khớp lần giữ ghế nào), hệ thống xử lý thế nào? Và khi một lần giữ ghế đã tạo vé thành công mà cổng báo thành công thêm một giao dịch khác (khác mã giao dịch) thì xử lý thế nào? (Hoàn toàn bộ như thanh toán trễ / Báo để xử lý thủ công / Phương án khác) | Tiền điều kiện; bước 2 | Mục 9 chỉ nêu giao dịch thuộc lần giữ ghế đã hết hạn, đã huỷ hoặc đã báo thất bại |
| Q-33 | Đã trả lời (Mã giao dịch, số tiền hoàn, tên phim, suất chiếu và lý do hoàn), đề bài bổ sung Mục 9. Email thông báo hoàn tiền gồm những thông tin gì (mã giao dịch, số tiền hoàn, tên phim và suất chiếu, lý do)? (Liệt kê thông tin cụ thể / Chỉ nêu đã hoàn tiền) | Dữ liệu ra 1; bước 7 | Mục 9 chỉ nêu "gửi email thông báo hoàn tiền cho khách" |
| Q-48 | Đã trả lời (Ghi log lỗi và để lại cho xử lý thủ công ngoài hệ thống; không tự hoàn tiền, không gửi email), theo quyết định của người dùng sau review cuối, thu hẹp đáp án Q-32. Với giao dịch cổng báo thành công mà hệ thống không nhận ra, hệ thống xử lý thế nào khi không có giao dịch do mình tạo (Q-28) và không xác định được khách? | Luồng 2e; Dữ liệu vào 1; BR-38 | Q-28 chỉ nêu số tiền lấy từ giao dịch hệ thống đã tạo; Q-32 chỉ nêu hoàn toàn bộ |
| Q-51 | Đã trả lời (Theo đề xuất: mã tham chiếu lần giữ ghế do hệ thống truyền khi tạo giao dịch và số tiền đã thanh toán; không kèm mã nhận ra được thì luồng 2e), đề bài bổ sung Mục 9, Mục 21. Khi cổng thanh toán báo thành công cho một giao dịch thứ hai (mã giao dịch khác) của lần giữ ghế đã có vé, báo của cổng kèm những thông tin gì để hệ thống gắn giao dịch với lần giữ ghế và lấy số tiền hoàn? (Mã tham chiếu lần giữ ghế do hệ thống truyền khi tạo giao dịch và số tiền đã thanh toán / Chỉ mã giao dịch, giao dịch thứ hai đi theo luồng 2e / Phương án khác) | Dữ liệu vào 1; bước 2, 4; luồng 2e; BR-40, REQ-130, REQ-136 | Mục 9 chỉ nêu cổng "báo thêm một giao dịch thứ hai" và số tiền hoàn lấy từ giao dịch hệ thống đã tạo (Q-28) |

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Luồng 2b chỉ phân định ranh giới với UC-005 (EV-07), nằm trong use case vì cùng một sự kiện báo thành công của cổng có thể rơi vào một trong hai use case; cách phân loại cụ thể thuộc bước thiết kế.
- BR-16 là quy tắc suy ra từ cụm "hoàn toàn bộ số tiền" (REQ-35, REQ-109) cho tình huống báo trùng; đề bài đã bổ sung ở REQ-110 theo trả lời Q-27.
- Ngoài phạm vi: xử lý thủ công khoản hoàn đã ghi log lỗi (luồng 4b, 5b) và giao dịch không nhận ra (luồng 2e) diễn ra ngoài hệ thống, không có use case (REQ-129, REQ-131).
- Các cạnh E-04 đến E-09 cùng xuất phát từ D-2 và dùng chung đoạn ngang đầu; E-17 và E-20 hợp ở M-R; E-14 và E-23 hợp ở M-4; không cạnh nào cắt qua node.
