# P06 - Đặc tả bổ sung - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P06 |
| Phiên bản | 1.3 |
| Thay đổi 1.3 | Thêm BR-92, BR-93 và cập nhật ma trận truy vết; đồng bộ BR-41, BR-45 với P04 (RF-14, RF-16); ghi công nghệ đã chốt ở P09 F11 (RF-15); đồng bộ đầu vào đã dùng (RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8 (Mục 4, Mục 5); P04-uc-specs/UC-005 1.11, UC-006 1.7, UC-008 1.7, UC-009 1.5, UC-013 1.2, UC-014 1.4; P04-uc-specs/_BR-register.md (đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; _review-P05-P06.md |
| Phạm vi | Toàn hệ thống |
| Mã Q, ASM cuối đã cấp | Q-80 (Q-74 đến Q-80 đều đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Giới thiệu

Tài liệu này gom yêu cầu chức năng dùng chung, yêu cầu phi chức năng đo được, ràng buộc thiết kế, giao tiếp ngoài và danh sách quy tắc nghiệp vụ hợp nhất của hệ thống đặt vé xem phim CineBook. Yêu cầu riêng của một use case nằm ở đặc tả use case đó; tài liệu này chứa yêu cầu chung và bảng BR chính thức, các đặc tả use case chỉ dẫn mã BR. Trọng tâm chất lượng của hệ thống là chống tranh chấp ghế khi đặt vé, giữ ghế tạm có thời hạn và giải phóng ghế đúng hạn, nên các ngưỡng thời gian và tải của Mục 3 lấy đúng từ nguồn. Hồ sơ dự án giới hạn phạm vi: đăng nhập không được mô hình hoá thành use case (việc đã đăng nhập chỉ là tiền điều kiện của các use case cần xác thực); phần việc làm ngoài phần mềm (xử lý thủ công khoản hoàn tiền không hoàn được và giao dịch thành công không nhận ra) và hai hệ thống ngoài (cổng thanh toán, dịch vụ email) theo mục Ngoài phạm vi của P00 (Mục 2).

## 2. Yêu cầu chức năng dùng chung

| NFR | Nhóm (FURPS+ / ISO 25010) | Phát biểu đo được | Tiêu chí đo | Áp dụng cho (UC / toàn hệ thống) | REQ |
|---|---|---|---|---|---|
| NFR-01 | F - Functionality / Functional suitability | Khách đăng nhập được vào hệ thống bằng email hoặc số điện thoại cùng mật khẩu. | Kiểm thử chức năng: đăng nhập bằng email cùng mật khẩu của một tài khoản khách đã đăng ký, rồi bằng số điện thoại cùng mật khẩu của chính tài khoản đó; mức đạt: cả hai cách đều đăng nhập được. Định dạng email và số điện thoại theo BR-81, BR-82 | UC-005, UC-007, UC-008 | REQ-12 |
| NFR-02 | F - Functionality / Functional suitability | Nhân viên (nhân viên quầy, nhân viên soát vé, quản lý cụm rạp, quản lý chuỗi) đăng nhập được vào hệ thống bằng tài khoản do quản trị viên tạo. | Kiểm thử chức năng: tạo tài khoản nhân viên bằng UC-017 rồi đăng nhập bằng tài khoản đó; mức đạt: đăng nhập được | UC-005, UC-008, UC-009, UC-010, UC-011, UC-012, UC-013, UC-014, UC-015, UC-016 | REQ-102 |
| NFR-03 | F - Functionality / Functional suitability | Quản trị viên đăng nhập được vào hệ thống bằng tài khoản quản trị viên có sẵn. | Kiểm thử chức năng: đăng nhập bằng tài khoản quản trị viên có sẵn sau khi cài đặt (NFR-12); mức đạt: đăng nhập được | UC-017 | REQ-104 |

## 3. Yêu cầu phi chức năng

| NFR | Nhóm (FURPS+ / ISO 25010) | Phát biểu đo được | Tiêu chí đo | Áp dụng cho (UC / toàn hệ thống) | REQ |
|---|---|---|---|---|---|
| NFR-04 | P - Performance / Performance efficiency | Hệ thống phục vụ được 4.000 khách truy cập đồng thời trên toàn chuỗi vào giờ mở bán phim bom tấn. | Kiểm thử tải 4.000 phiên khách đồng thời trên toàn chuỗi vào thời điểm mở bán của suất chiếu; dữ liệu mẫu theo quy mô nguồn: 15 cụm rạp, mỗi cụm 4 đến 12 phòng chiếu, mỗi phòng 50 đến 400 ghế, khoảng 500 suất chiếu mỗi ngày; mỗi phiên làm ba thao tác xem sơ đồ ghế, giữ ghế và thanh toán; mức đạt của "phục vụ được" (Q-74): ít nhất 99% thao tác thành công không do lỗi hệ thống, thao tác giữ ghế thoả NFR-06, và không ghế nào bị giữ hoặc bán cho hai người (BR-04, BR-07, BR-08, BR-09) | Toàn hệ thống | REQ-73, REQ-155; REQ-01, REQ-03, REQ-04 (điều kiện đo) |
| NFR-05 | P - Performance / Performance efficiency | Use case Đặt vé phục vụ được tới 1.000 khách cùng thao tác trên một suất chiếu vào giờ mở bán phim bom tấn. | Kiểm thử tải 1.000 phiên khách đồng thời cùng thao tác trên một suất chiếu, nằm trong 4.000 khách của NFR-04 (nguồn: "trong đó có thể tới 1.000 khách"); dữ liệu mẫu: phòng chiếu có sức chứa từ 50 đến 400 ghế; mỗi phiên làm ba thao tác như NFR-04; mức đạt (Q-74): ít nhất 99% thao tác thành công không do lỗi hệ thống và thao tác giữ ghế thoả NFR-06. Tiêu chí đúng đắn khi 1.000 phiên cùng chọn ghế của một suất chiếu: mỗi ghế chỉ được giữ cho đúng một người, việc giữ là tất cả hoặc không ghế nào, và số ghế được giữ cộng số ghế đã bán không vượt sức chứa phòng chiếu (BR-04, BR-07, BR-08, BR-09) | UC-005 | REQ-74, REQ-155; REQ-03 (điều kiện đo) |
| NFR-06 | P - Performance / Performance efficiency | Thao tác giữ ghế (UC-005 bước 7) trả kết quả trong không quá 2 giây. | Đo tự động thời gian từ khi gửi yêu cầu xác nhận chọn ghế tới khi nhận kết quả giữ ghế; mức đạt: không quá 2 giây. Cách tính (Q-75): ở tải thường mọi lần phải đạt; ở tải đỉnh của NFR-04, NFR-05 tính cho 95% lần; đo từ lúc hệ thống nhận yêu cầu tới lúc trả kết quả; kết quả từ chối vì ghế đã có người giữ cũng được tính | UC-005 | REQ-75, REQ-156 |
| NFR-07 | P - Performance / Performance efficiency | Ghế hết thời gian giữ được giải phóng trong không quá 1 phút sau thời điểm hết hạn giữ ghế. | Đo tự động với mỗi lần giữ ghế hết hạn mà chưa có thanh toán thành công (UC-005 luồng 7b và luồng 9a1a, nơi nhân viên quầy xác nhận đã thu tiền sau thời điểm hết hạn và ghế được giải phóng theo luồng 7b): khoảng thời gian từ thời điểm hết hạn tới khi ghế ở trạng thái trống; mức đạt: không quá 1 phút cho mọi lần ở cả tải thường và tải đỉnh (Q-75) | UC-005 | REQ-76, REQ-156 |
| NFR-08 | P - Performance / Performance efficiency | Sơ đồ ghế phản ánh việc người khác giữ hoặc mua ghế chậm nhất 3 giây sau khi thay đổi xảy ra. | Đo tự động khoảng thời gian từ khi ghế đổi sang trạng thái đang được giữ hoặc đã bán tới khi sơ đồ ghế của người đang xem hiển thị trạng thái mới; mức đạt: không quá 3 giây, đo trên mọi người đang xem sơ đồ ghế của suất chiếu có ghế đổi trạng thái. Cách tính (Q-75): ở tải thường mọi lần phải đạt; ở tải đỉnh tính cho 95% lần | UC-005 | REQ-19, REQ-156 |
| NFR-09 | P - Performance / Performance efficiency | Mỗi lần ghế trở về trạng thái trống (huỷ vé, hết thời gian giữ, khách huỷ giữ ghế, thanh toán thất bại) hiện trên sơ đồ ghế chậm nhất 3 giây sau khi ghế ở trạng thái trống. | Đo tự động khoảng thời gian từ khi ghế ở trạng thái trống tới khi sơ đồ ghế của người đang xem hiển thị trạng thái trống, cho từng nguyên nhân (UC-005 luồng 7b, *a, 11a; UC-008 bước 7); mức đạt: không quá 3 giây; cách tính như NFR-08 (Q-75). Mốc đo bắt đầu từ lúc ghế trống, không phải từ thời điểm hết hạn: với hết thời gian giữ, từ thời điểm hết hạn tới khi sơ đồ hiển thị trống tối đa 63 giây (1 phút của NFR-07 cộng 3 giây); trong khoảng đó lần giữ ghế đã kết thúc (BR-04) nhưng sơ đồ vẫn hiện ghế đang được giữ và người khác chưa chọn được ghế vì ghế chưa trống (BR-07, BR-53) | UC-005, UC-008 | REQ-119, REQ-156 |
| NFR-10 | F - Functionality / Security | Hệ thống không lưu thông tin thẻ thanh toán của khách. | Kiểm tra mã nguồn, dữ liệu lưu trữ và log của hệ thống: không có dữ liệu thông tin thẻ thanh toán; mức đạt: không lưu (có hoặc không) | Toàn hệ thống | REQ-77; REQ-78 (phụ) |

## 4. Ràng buộc thiết kế

| NFR | Nhóm (FURPS+ / ISO 25010) | Phát biểu đo được | Tiêu chí đo | Áp dụng cho (UC / toàn hệ thống) | REQ |
|---|---|---|---|---|---|
| NFR-11 | + Ràng buộc thiết kế / Không tương ứng trực tiếp | Hệ thống chạy dưới dạng ứng dụng web có giao diện thích ứng (responsive) với kích thước màn hình. | Kiểm tra triển khai: các chức năng của khách và nhân viên dùng được từ trình duyệt web; mức đạt: chạy đúng trên Chrome, Edge, Firefox, Safari bản ổn định mới nhất, ở màn hình từ 360 pixel (điện thoại) đến máy tính để bàn; chức năng soát vé (UC-009) chạy trên điện thoại hoặc máy tính bảng có camera, dùng Chrome hoặc Safari bản mới, truy cập qua HTTPS vì trình duyệt chỉ cho dùng camera trên HTTPS (Q-78) | Toàn hệ thống | project-profile.md, NEN_TANG; REQ-159 |
| NFR-12 | + Ràng buộc thiết kế / Không tương ứng trực tiếp | Tài khoản quản trị viên có sẵn khi cài đặt hệ thống và không do ai tạo qua hệ thống. | Kiểm tra triển khai: sau khi cài đặt có một tài khoản quản trị viên đăng nhập được, và hệ thống không có chức năng tạo tài khoản quản trị viên; mức đạt: có tài khoản và không có chức năng tạo | UC-017 | REQ-103 |
| NFR-13 | + Ràng buộc thiết kế / Không tương ứng trực tiếp | Chức năng soát vé không có cách nhập tay để soát vé khi camera không đọc được mã QR. | Kiểm tra chức năng soát vé: không tồn tại cách nhập tay để soát vé; mức đạt: không có | UC-009 | REQ-126 |
| NFR-14 | + Ràng buộc thiết kế / Không tương ứng trực tiếp | Mã QR của vé không có định dạng quy định; hệ thống tự xác định vé từ mã QR. | Kiểm thử tích hợp: quét mã QR của một vé do UC-005 tạo, hệ thống xác định đúng vé từ mã; mức đạt: xác định đúng vé | UC-005, UC-009 | REQ-128 |

Lúc phân tích hồ sơ dự án ghi CONG_NGHE là "Chưa chốt" nên không có ràng buộc công nghệ nào được tạo từ trường đó (công nghệ được chốt sau ở P09 F11).

## 5. Giao tiếp ngoài

| NFR | Nhóm (FURPS+ / ISO 25010) | Phát biểu đo được | Tiêu chí đo | Áp dụng cho (UC / toàn hệ thống) | REQ |
|---|---|---|---|---|---|
| NFR-15 | + Giao tiếp / Compatibility (Interoperability) | Hệ thống tạo giao dịch thanh toán qua cổng thanh toán (ACT-07) (cổng nhận địa chỉ thanh toán do hệ thống ký thì không có lời gọi mạng riêng cho việc tạo giao dịch), truyền kèm mã tham chiếu của lần giữ ghế; chiều trao đổi: hệ thống --> cổng thanh toán. | Kiểm thử tích hợp với môi trường sandbox của cổng thanh toán: giao dịch được tạo và cổng nhận mã tham chiếu lần giữ ghế; mức đạt: tạo được giao dịch. Khi cổng từ chối hoặc không trả lời trong 30 giây yêu cầu tạo giao dịch (với cổng chỉ nhận địa chỉ đã ký: khi hệ thống lỗi trước lúc chuyển khách sang cổng): hệ thống giữ nguyên lần giữ ghế, báo khách và cho khách thử lại (BR-90, UC-005 luồng 10a) | UC-005 | REQ-79, REQ-158; REQ-136 (phụ) |
| NFR-16 | + Giao tiếp / Compatibility (Interoperability) | Hệ thống nhận kết quả giao dịch (callback) từ cổng thanh toán (ACT-07) kèm mã giao dịch, mã tham chiếu của lần giữ ghế và số tiền đã thanh toán; chiều trao đổi: cổng thanh toán --> hệ thống. | Kiểm thử tích hợp với môi trường sandbox: cổng gửi kết quả thành công và kết quả thất bại, hệ thống nhận được đủ ba thông tin; mức đạt: nhận đủ. Khi cổng không báo kết quả tới thời điểm hết hạn giữ ghế, ghế được giải phóng theo UC-005 luồng 7b (BR-10); kết quả báo sau đó xử lý theo UC-006 | UC-005, UC-006 | REQ-79; REQ-111, REQ-136 (phụ) |
| NFR-17 | + Giao tiếp / Compatibility (Interoperability) | Hệ thống gửi yêu cầu hoàn tiền qua API hoàn tiền của cổng thanh toán (ACT-07) cho thanh toán đến trễ và cho vé mua trực tuyến bị huỷ; chiều trao đổi: hệ thống --> cổng thanh toán. | Kiểm thử tích hợp với môi trường sandbox: cổng chấp nhận yêu cầu hoàn tiền và trả kết quả hoàn tiền; mức đạt: hoàn tiền thành công. Hành vi khi cổng từ chối hoặc không trả lời trong 30 giây theo BR-41, BR-43 | UC-006, UC-008 | REQ-79 |
| NFR-18 | + Giao tiếp / Compatibility (Interoperability) | Hệ thống gửi email cho khách (email chứa vé, email thông báo hoàn tiền) qua dịch vụ email bên ngoài (ACT-08, SMTP); chiều trao đổi: hệ thống --> dịch vụ email. | Kiểm thử tích hợp với dịch vụ email: email chứa vé (nội dung vé theo REQ-105) và email thông báo hoàn tiền (nội dung theo REQ-116) được dịch vụ chấp nhận; mức đạt: được chấp nhận. Khi dịch vụ email từ chối hoặc không phản hồi: vé và khoản hoàn giữ nguyên hiệu lực, hệ thống thử gửi lại vài lần rồi ghi log lỗi (BR-89) | UC-005, UC-006 | REQ-80, REQ-157; REQ-31, REQ-90 (phụ) |

## 6. Quy tắc nghiệp vụ

Danh sách chính thức gồm 93 BR (BR-01 đến BR-93): 85 Hiệu lực, 3 Gộp (BR-16, BR-59, BR-75), 5 Loại. BR-74 đến BR-84 cấp mới ở P06 1.0; BR-85 đến BR-90 cấp ở P06 1.1 sau review P05, P06; BR-91 cấp ở UC-006 1.6; BR-92 cấp ở UC-014 1.4; BR-93 cấp ở UC-005 1.11.

| BR | Quy tắc | Loại | Áp dụng cho UC | REQ | Trạng thái | Ghi chú |
|---|---|---|---|---|---|---|
| BR-01 | Trước thời điểm mở bán của suất chiếu, không ai được đặt hoặc mua vé của suất chiếu đó. | Ràng buộc | UC-005, UC-014 | REQ-86; REQ-61 (phụ) | Hiệu lực | - |
| BR-02 | Nhân viên quầy chỉ bán vé các suất chiếu tại cụm rạp của mình. | Ràng buộc | UC-005 | REQ-45; REQ-100 (phụ) | Hiệu lực | - |
| BR-03 | Ghế tác nhân đang chọn trên sơ đồ vẫn ở trạng thái trống cho tới khi tác nhân xác nhận chọn ghế. | Sự kiện | UC-005 | REQ-88 | Hiệu lực | - |
| BR-04 | Tại một thời điểm, mỗi khách và mỗi nhân viên quầy có tối đa một lần giữ ghế chưa kết thúc. | Ràng buộc | UC-005 | REQ-89, REQ-92 | Hiệu lực | Lần giữ ghế kết thúc tại thời điểm hết hạn, khi khách hoặc nhân viên quầy huỷ giữ ghế, khi cổng báo thất bại hoặc khi ghế chuyển sang đã bán, không đợi ghế thực sự được giải phóng (REQ-76). Việc kiểm tra và tạo lần giữ ghế mới là một thao tác không chia cắt |
| BR-05 | Nhóm ghế của một lần giữ ghế (các ghế tác nhân chọn cho một lần đặt vé) gồm tối đa 8 ghế; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | UC-005 | REQ-20, REQ-46 | Hiệu lực | - |
| BR-06 | Ghế đôi được tính là một ghế khi đếm số ghế của một lần giữ ghế, sức chứa phòng và tỉ lệ lấp đầy. | Suy luận | UC-005, UC-012, UC-015, UC-016 | REQ-87; REQ-17 (phụ) | Hiệu lực | Dự kiến dùng lại ở UC-012, UC-015, UC-016. UC-012, UC-015, UC-016 theo P02 Mục 5 (REQ-87) |
| BR-07 | Việc giữ ghế chỉ thành công khi tất cả các ghế được chọn đều còn trống; nếu có ghế không còn trống thì không ghế nào được giữ. | Ràng buộc | UC-005 | REQ-24, REQ-46 | Hiệu lực | - |
| BR-08 | Ghế đang được giữ cho một người thì không người nào khác được chọn ghế đó. | Ràng buộc | UC-005 | REQ-23 | Hiệu lực | - |
| BR-09 | Một ghế của một suất chiếu chỉ được bán cho đúng một người; khi nhiều người cùng lúc xác nhận chọn cùng một ghế, chỉ một người giữ được ghế đó. | Ràng buộc | UC-005 | REQ-26, REQ-27 | Hiệu lực | - |
| BR-10 | Ghế được giữ tạm trong 10 phút kể từ khi giữ thành công; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | UC-005 | REQ-22, REQ-46 | Hiệu lực | - |
| BR-11 | Giá vé lấy theo bảng giá của cụm rạp có suất chiếu, phụ thuộc loại phòng, định dạng phim, loại ghế và khung giờ chiếu (trước 17 giờ hoặc từ 17 giờ trở đi; ngày thường hoặc cuối tuần). | Tính toán | UC-005, UC-008, UC-013 | REQ-37, REQ-38 | Hiệu lực | Dùng ở UC-013 (bảng giá); giá của lần giữ ghế được chốt khi giữ ghế (BR-65) |
| BR-12 | Khung giờ chiếu xác định theo giờ bắt đầu của suất chiếu; cuối tuần gồm Thứ Bảy và Chủ nhật. | Suy luận | UC-005, UC-014, UC-013 | REQ-91 | Hiệu lực | - |
| BR-13 | Khách mua vé tại quầy trả bằng tiền mặt. | Ràng buộc | UC-005 | REQ-47 | Hiệu lực | - |
| BR-14 | Thanh toán thành công được báo về sau thời điểm hết hạn giữ ghế thì không tạo vé, kể cả khi ghế chưa được giải phóng; khách được hoàn toàn bộ số tiền. | Kích hoạt hành động | UC-005, UC-006 | REQ-36, REQ-35 | Hiệu lực | Áp dụng chính ở UC-006. Việc so thời điểm nhận báo với thời điểm hết hạn giữ ghế và việc chuyển ghế sang đã bán hoặc ghi nhận thanh toán đến trễ là một thao tác không chia cắt (BR-85); lần giữ ghế đã Hết hạn không đổi trạng thái nữa (BR-86) |
| BR-15 | Thanh toán thành công được báo về sau khi khách đã huỷ việc giữ ghế hoặc sau khi cổng thanh toán đã báo thất bại, kể cả trước thời điểm hết hạn giữ ghế, thì không tạo vé; khách được hoàn toàn bộ số tiền và được báo qua email. | Kích hoạt hành động | UC-005, UC-006 | REQ-109 | Hiệu lực | Áp dụng chính ở UC-006. Việc so với trạng thái Đã huỷ hoặc Thanh toán thất bại của lần giữ ghế và việc ghi nhận thanh toán đến trễ là một thao tác không chia cắt (BR-85, BR-86) |
| BR-16 | Mỗi giao dịch thanh toán trễ chỉ được hoàn toàn bộ số tiền một lần; kết quả báo trùng cho cùng một giao dịch không làm hoàn thêm. | Ràng buộc | UC-006 | REQ-35, REQ-109, REQ-110 | Gộp vào BR-37 | suy ra từ "hoàn toàn bộ số tiền", đã xác nhận ở Q-27 (REQ-110); không giới hạn các lần hoàn 70% từng vé của UC-008 (xem BR-26); mỗi giao dịch thành công chỉ xử lý một lần theo BR-37. Gộp theo P06: BR-37 bao hàm BR-16 (cùng REQ-35, REQ-109, REQ-110; BR-37 nêu thêm vế tạo vé ở UC-005) |
| BR-17 | Vé mua trực tuyến chỉ do khách đã mua huỷ trực tuyến; vé mua tại quầy chỉ do nhân viên quầy của cụm rạp đã bán vé huỷ tại quầy. | Ràng buộc | UC-008 | REQ-40, REQ-83; REQ-47, REQ-100 (phụ) | Hiệu lực | - |
| BR-18 | Vé chỉ được huỷ khi thời điểm huỷ cách giờ bắt đầu suất chiếu ít nhất 2 tiếng; quy tắc áp dụng cả khi huỷ vé mua tại quầy. | Ràng buộc | UC-008 | REQ-41, REQ-84 | Hiệu lực | "giờ chiếu" của nguồn hiểu là giờ bắt đầu suất chiếu (REQ-91); mốc thời điểm huỷ là lúc hệ thống kiểm tra (BR-32) |
| BR-19 | Số tiền hoàn của một vé bị huỷ bằng 70% giá vé của vé đó; quy tắc áp dụng cả khi huỷ vé mua tại quầy. | Tính toán | UC-008 | REQ-42, REQ-85 | Hiệu lực | làm tròn xuống đồng gần nhất (BR-31) |
| BR-20 | Vé mua trực tuyến được hoàn tiền qua cổng thanh toán; vé mua tại quầy được nhân viên quầy hoàn bằng tiền mặt. | Ràng buộc | UC-008 | REQ-43, REQ-85 | Hiệu lực | - |
| BR-21 | Mỗi vé chỉ được huỷ và hoàn tiền một lần; vé đã huỷ không huỷ lại được. | Ràng buộc | UC-008 | REQ-40, REQ-42, REQ-85; REQ-51 (phụ) | Hiệu lực | UC-009 dùng BR-25 cho vé đã huỷ; vé đã sử dụng không huỷ được theo BR-30 |
| BR-22 | Nhân viên soát vé chỉ soát vé thuộc cụm rạp của mình. | Ràng buộc | UC-009 | REQ-51; REQ-100 (phụ) | Hiệu lực | - |
| BR-23 | Vé chỉ được soát khi vé thuộc suất chiếu mà nhân viên soát vé đã chọn. | Ràng buộc | UC-009 | REQ-51, REQ-93 | Hiệu lực | - |
| BR-24 | Mỗi vé chỉ được soát một lần; vé đã sử dụng không được soát lại, và khi nhiều nhân viên soát vé cùng lúc soát một vé thì chỉ một lần soát thành công. | Ràng buộc | UC-009 | REQ-51 | Hiệu lực | - |
| BR-25 | Vé đã huỷ không được soát. | Ràng buộc | UC-009 | REQ-51; REQ-40, REQ-83 (phụ) | Hiệu lực | - |
| BR-26 | Tổng số tiền đã hoàn qua cổng thanh toán của các lần hoàn cho một giao dịch không vượt số tiền đã thanh toán của giao dịch. | Ràng buộc | UC-006, UC-008 | REQ-35, REQ-42, REQ-109 | Hiệu lực | Áp dụng cho hoàn toàn bộ của UC-006 và các lần hoàn 70% từng vé của UC-008 trên cùng một giao dịch |
| BR-27 | Khi cổng thanh toán từ chối hoàn tiền hoặc không trả lời, hệ thống tự thử lại yêu cầu hoàn tiền vài lần, chỉ sau khi tra cứu cho thấy khoản hoàn chưa được thực hiện; không tra cứu được thì không gửi lại tự động; nếu vẫn không hoàn được thì đánh dấu khoản hoàn để quản trị xử lý thủ công và không gửi email cho khách. | Kích hoạt hành động | UC-006, UC-008 | REQ-112 | Loại | Thay bởi br-41. Số lần thử lại và khoảng cách giữa hai lần là quyết định thiết kế (P09). Đáp án Q-29 bị thay: bỏ phần đánh dấu cho quản trị, thay bằng ghi log lỗi và xử lý ngoài hệ thống |
| BR-28 | Cổng thanh toán không trả lời yêu cầu hoàn tiền trong 30 giây thì coi là không phản hồi; mỗi lần thử lại dùng mã giao dịch để cổng thanh toán không hoàn hai lần. | Ràng buộc | UC-006, UC-008 | REQ-113; REQ-78 (phụ) | Loại | Thay bởi br-43. Khoá chống hoàn trùng theo từng yêu cầu hoàn thay vì mã giao dịch (một giao dịch có nhiều lần hoàn 70% của nhiều vé) |
| BR-29 | Khi hoàn tiền huỷ vé chưa hoàn tất, vé vẫn ở trạng thái đã huỷ và ghế vẫn ở trạng thái đã bán; ghế chỉ trả về trống sau khi hoàn tiền xong. | Ràng buộc | UC-008 | REQ-117; REQ-44 (phụ) | Loại | Thay bởi br-42. Đáp án Q-34 bị thay: ghế trả về trống bất kể kết quả hoàn tiền |
| BR-30 | Vé đã sử dụng không được huỷ; khi việc huỷ và việc soát cùng một vé xảy ra cùng lúc thì bên ghi nhận trước thành công, bên sau bị từ chối. | Ràng buộc | UC-008, UC-009 | REQ-118; REQ-51 (phụ) | Hiệu lực | Vé đã huỷ không soát được theo BR-25 |
| BR-31 | Khi 70% giá vé không tròn đồng, số tiền hoàn của vé bị huỷ được làm tròn xuống đồng gần nhất. | Tính toán | UC-008 | REQ-122; REQ-42, REQ-85 (phụ) | Hiệu lực | Bổ sung cho BR-19 |
| BR-32 | Thời điểm huỷ để so với hạn 2 tiếng là thời điểm hệ thống kiểm tra yêu cầu huỷ. | Ràng buộc | UC-008 | REQ-121; REQ-41, REQ-84 (phụ) | Hiệu lực | Bổ sung cho BR-18 |
| BR-33 | Khi một vé vi phạm nhiều điều kiện soát, hệ thống chỉ báo một lý do theo thứ tự: cụm rạp, suất chiếu, đã sử dụng, đã huỷ. | Ràng buộc | UC-009 | REQ-124; REQ-94 (phụ) | Hiệu lực | - |
| BR-34 | Nhân viên soát vé chỉ chọn suất chiếu của cụm rạp mình; suất chiếu đã chọn áp dụng cho các vé quét liên tiếp tới khi chọn lại. | Ràng buộc | UC-009 | REQ-123; REQ-93 (phụ) | Hiệu lực | - |
| BR-35 | Thanh toán thành công của một giao dịch hệ thống không nhận ra, hoặc của giao dịch thứ hai cho lần giữ ghế đã có vé, được xử lý như thanh toán trễ: không tạo vé và hoàn toàn bộ số tiền. | Kích hoạt hành động | UC-006 | REQ-115 | Loại | Thay bởi br-38 và br-40. Tách: giao dịch không nhận ra sang BR-38 (Q-48), giao dịch thứ hai cho lần giữ ghế đã có vé sang BR-40 |
| BR-36 | Kết quả thất bại mà cổng thanh toán báo vào lúc lần giữ ghế đã hết hạn hoặc đã bị khách huỷ chỉ được ghi nhận, không hoàn tiền. | Kích hoạt hành động | UC-006 | REQ-114 | Loại | Thay bởi br-39. Mở rộng sang thất bại báo cho giao dịch đã có vé hoặc không nhận ra |
| BR-37 | Mỗi giao dịch thanh toán thành công chỉ được xử lý một lần, hoặc tạo vé ở UC-005 hoặc hoàn toàn bộ ở UC-006; kết quả báo trùng của giao dịch đã được xử lý không tạo thêm vé và không hoàn thêm; khi hai báo của cùng một giao dịch đến đồng thời thì xử lý tuần tự theo BR-85 và chỉ báo đầu tiên được xử lý. | Ràng buộc | UC-005, UC-006 | REQ-110, REQ-35, REQ-109 | Hiệu lực | Giao dịch đã dùng để tạo vé mà bị báo trùng sau thời điểm hết hạn giữ ghế vẫn là giao dịch đã xử lý, không phải thanh toán trễ. Đã gộp BR-16 (P06) |
| BR-38 | Thanh toán thành công của một giao dịch hệ thống không nhận ra được ghi log lỗi và để lại cho xử lý thủ công ngoài hệ thống; hệ thống không tạo vé, không tự hoàn tiền và không gửi email. | Kích hoạt hành động | UC-006 | REQ-129 | Hiệu lực | Trả lời Q-48; thu hẹp đáp án Q-32 |
| BR-39 | Kết quả thất bại mà cổng thanh toán báo vào lúc lần giữ ghế đã hết hạn hoặc đã bị khách huỷ, hoặc báo cho giao dịch đã có vé, hoặc báo cho giao dịch hệ thống không nhận ra, chỉ được ghi nhận, không hoàn tiền. | Kích hoạt hành động | UC-006 | REQ-133 | Hiệu lực | Khách chưa mất tiền nên không có gì để hoàn |
| BR-40 | Thanh toán thành công của giao dịch thứ hai (mã giao dịch khác) gắn được với lần giữ ghế đã có vé qua mã tham chiếu lần giữ ghế kèm trong báo của cổng được xử lý như thanh toán trễ: không tạo vé và hoàn toàn bộ số tiền cổng báo cho giao dịch đó. | Kích hoạt hành động | UC-006 | REQ-130, REQ-136 | Hiệu lực | Phần còn lại của đáp án Q-32. Giao dịch thứ hai có mã giao dịch khác giao dịch đầu nên chỉ gắn được với lần giữ ghế qua mã tham chiếu lần giữ ghế kèm trong báo của cổng cùng số tiền đã thanh toán (trả lời Q-51); không có mã tham chiếu nhận ra được thì áp dụng BR-38 |
| BR-41 | Khi cổng thanh toán từ chối hoàn tiền hoặc không trả lời, hệ thống tự thử lại yêu cầu hoàn tiền vài lần, chỉ sau khi tra cứu cho thấy khoản hoàn chưa được thực hiện; không tra cứu được thì không gửi lại tự động; nếu vẫn không hoàn được thì ghi log lỗi khoản hoàn để xử lý thủ công ngoài hệ thống và không gửi email cho khách. | Kích hoạt hành động | UC-006, UC-008 | REQ-131 | Hiệu lực | Trả lời Q-127. Số lần thử lại và khoảng cách giữa hai lần là quyết định thiết kế (P09). Việc xử lý thủ công nằm ngoài hệ thống, không có use case |
| BR-42 | Ghế của vé bị huỷ được trả về trạng thái trống sau khi vé được ghi nhận đã huỷ, kể cả khi hoàn tiền qua cổng thanh toán không thành công và khoản hoàn đã được ghi log lỗi. | Ràng buộc | UC-008, UC-006 | REQ-131; REQ-44 (phụ) | Hiệu lực | Hoàn tiền mặt tại quầy luôn hoàn được nên không có đường hoàn tiền mặt không thành công; không còn trạng thái vé đã huỷ mà ghế chưa trống. UC-006 theo P02 Mục 5 (REQ-131) |
| BR-43 | Cổng thanh toán không trả lời yêu cầu hoàn tiền trong 30 giây thì coi là không phản hồi; mọi lần thử lại của cùng một yêu cầu hoàn dùng lại khoá chống hoàn trùng của yêu cầu hoàn đó; khoá gắn với từng yêu cầu hoàn và phân biệt được với khoá của yêu cầu hoàn khác trên cùng giao dịch (mã giao dịch kèm mã vé với hoàn tiền huỷ vé; mã giao dịch kèm loại yêu cầu hoàn toàn bộ với hoàn toàn bộ thanh toán trễ); việc tra cứu kết quả hoàn cũng dùng khoá này. | Ràng buộc | UC-006, UC-008 | REQ-132; REQ-78 (phụ) | Hiệu lực | Cùng BR-41 |
| BR-44 | Xác nhận đã thu tiền mặt của nhân viên quầy tới sau thời điểm hết hạn giữ ghế bị từ chối và nhân viên quầy được thông báo trả lại tiền mặt cho khách; việc so thời điểm hết hạn với việc xác nhận đã thu tiền và chuyển ghế sang đã bán là một thao tác không chia cắt. | Kích hoạt hành động | UC-005 | REQ-134; REQ-22, REQ-32, REQ-47, REQ-48 (phụ) | Hiệu lực | Trả lời Q-49. Giống thao tác không chia cắt của kênh trực tuyến (UC-005 bước 11, 12) |
| BR-45 | Từ giờ bắt đầu của suất chiếu, không ai được bắt đầu đặt hoặc mua vé của suất chiếu đó; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | UC-005, UC-014 | REQ-135; REQ-61, REQ-86 (phụ) | Hiệu lực | Trả lời Q-50. Kiểm ở bước 2; ngừng bán là ngừng nhận lần giữ ghế mới, còn lần giữ ghế đã tạo trước giờ bắt đầu vẫn được hoàn tất theo BR-10 (tối đa 10 phút) nên vé vẫn có thể được tạo sau giờ bắt đầu, không trái đề bài Mục 16. Ghế trả về trống sau giờ bắt đầu (UC-008 bước 7) không được bán lại |
| BR-46 | Quản lý cụm rạp chỉ lập, sửa, xoá suất chiếu của các phòng chiếu thuộc cụm rạp của mình. | Ràng buộc | UC-014 | REQ-60; REQ-100 (phụ) | Hiệu lực | - |
| BR-47 | Định dạng của suất chiếu phải là một định dạng phát hành của phim. | Ràng buộc | UC-014 | REQ-62; REQ-55 (phụ) | Hiệu lực | - |
| BR-48 | Phòng chiếu của suất chiếu phải chiếu được định dạng của suất chiếu. | Ràng buộc | UC-014 | REQ-63; REQ-57 (phụ) | Hiệu lực | - |
| BR-49 | Ngày chiếu của suất chiếu phải nằm trong khoảng từ ngày khởi chiếu tới ngày kết thúc chiếu của phim. | Ràng buộc | UC-014 | REQ-97; REQ-95 (phụ) | Hiệu lực | Ngày chiếu hiểu là ngày của ngày giờ bắt đầu; hai ngày đầu và cuối thuộc khoảng chiếu (REQ-96) |
| BR-50 | Khi lập hoặc sửa suất chiếu, giờ kết thúc được tính bằng giờ bắt đầu cộng thời lượng phim tại thời điểm đó. | Tính toán | UC-014 | REQ-98; REQ-07 (phụ) | Hiệu lực | - |
| BR-51 | Hai suất chiếu trong cùng một phòng chiếu phải cách nhau ít nhất 15 phút dọn phòng, tính từ giờ kết thúc của suất trước. | Ràng buộc | UC-014 | REQ-64 | Hiệu lực | Bằng đúng 15 phút là hợp lệ |
| BR-52 | Việc kiểm tra khoảng cách giữa các suất chiếu trong phòng chiếu và việc lưu suất chiếu lập hoặc sửa là một thao tác không chia cắt trên các suất chiếu của phòng chiếu; khi hai yêu cầu lập hoặc sửa đồng thời (của hai quản lý cụm rạp hoặc hai phiên làm việc) cùng làm hai suất chiếu trong một phòng vi phạm khoảng cách dọn phòng, chỉ một yêu cầu được lưu. | Ràng buộc | UC-014 | REQ-64 | Hiệu lực | Hệ quả của REQ-64 khi yêu cầu đồng thời, nguồn không quy định riêng; khi sửa sang phòng khác, kiểm áp dụng cho phòng mới. Cơ chế bảo đảm thuộc P07, P09 |
| BR-53 | Không được sửa hoặc xoá suất chiếu đang có ghế được giữ hoặc có vé đã bán chưa bị huỷ; ghế đã quá thời điểm hết hạn giữ ghế không còn là ghế được giữ, kể cả khi chưa được giải phóng. | Ràng buộc | UC-014 | REQ-65, REQ-141 | Hiệu lực | Trả lời Q-55: mốc là thời điểm hết hạn, như BR-10, BR-14, BR-44 |
| BR-54 | Việc giữ ghế của một suất chiếu và việc kiểm tra BR-53 rồi sửa hoặc xoá suất chiếu đó không xen vào nhau: nếu giữ ghế được ghi nhận trước thì sửa hoặc xoá bị từ chối theo BR-53; nếu sửa hoặc xoá được ghi nhận trước thì việc giữ ghế trên suất chiếu như tác nhân đã xem lúc chọn ghế bị từ chối vì suất chiếu đã thay đổi hoặc không còn. | Ràng buộc | UC-005, UC-014 | REQ-65, REQ-142 | Hiệu lực | Trả lời Q-56; UC-005 bước 7, luồng 7d; UC-014 bước 8, 1b3 |
| BR-55 | Thời điểm mở bán của suất chiếu phải trước giờ bắt đầu của suất chiếu. | Ràng buộc | UC-014 | REQ-137; REQ-61, REQ-86, REQ-135 (phụ) | Hiệu lực | Trả lời Q-52; bổ sung cho BR-01, BR-45 |
| BR-56 | Khi lập suất chiếu mới hoặc sửa suất chiếu, giờ bắt đầu phải sau thời điểm hệ thống kiểm tra. | Ràng buộc | UC-014 | REQ-138 | Hiệu lực | Trả lời Q-53; giờ bắt đầu bằng đúng thời điểm kiểm tra là đã qua |
| BR-57 | Suất chiếu đã tới giờ bắt đầu, kể cả đã kết thúc, không được sửa hoặc xoá. | Ràng buộc | UC-014 | REQ-139 | Hiệu lực | Trả lời Q-60 |
| BR-58 | Xoá suất chiếu là bỏ suất chiếu khỏi lịch chiếu và ngừng bán vé của suất chiếu đó; thông tin của suất chiếu vẫn được giữ cho vé đã huỷ, hoàn tiền (kể cả thanh toán trễ) và báo cáo. | Ràng buộc | UC-014 | REQ-140 | Hiệu lực | Trả lời Q-54 |
| BR-59 | Không được lập suất chiếu, hoặc sửa suất chiếu thành suất chiếu, khi bảng giá của cụm rạp chưa có giá cho đúng loại phòng và định dạng phim của suất chiếu đó. | Ràng buộc | UC-014 | REQ-145; REQ-37, REQ-38 (phụ) | Gộp vào BR-69 | Trả lời Q-59; là trường hợp riêng của BR-69 (kiểm đủ loại ghế và khung giờ, trả lời Q-61), P06 xét gộp. Gộp theo P06: BR-69 mở rộng BR-59 sang loại ghế và khung giờ (trả lời Q-61); UC và REQ của BR-59 đã nằm trong BR-69 |
| BR-60 | Khi suất chiếu đã bị người khác sửa hoặc xoá kể từ lúc quản lý cụm rạp được hiển thị, yêu cầu sửa hoặc xoá của quản lý cụm rạp sau bị từ chối và không ghi đè thay đổi trước. | Ràng buộc | UC-014 | REQ-143 | Hiệu lực | Trả lời Q-57 |
| BR-61 | Quản lý cụm rạp chỉ xem và thiết lập bảng giá của cụm rạp mình. | Ràng buộc | UC-013, UC-005 | REQ-37, REQ-59; REQ-100 (phụ) | Hiệu lực | UC-005 theo P02 Mục 5 (REQ-37) |
| BR-62 | Mỗi mục giá của bảng giá gồm một loại phòng, một định dạng phim, một loại ghế, một khung giờ chiếu và đúng một giá vé; mỗi tổ hợp bốn yếu tố có tối đa một mục giá trong bảng giá của cụm rạp. | Ràng buộc | UC-013, UC-005 | REQ-37, REQ-38 | Hiệu lực | Phần giá trị của giá vé tách thành BR-70. UC-005 theo P02 Mục 5 (REQ-37) |
| BR-63 | Khi mục giá đã bị một yêu cầu khác đổi, tạo hoặc bỏ kể từ lúc quản lý cụm rạp được hiển thị, yêu cầu đặt giá hoặc bỏ giá của quản lý cụm rạp sau bị từ chối và không ghi đè thay đổi trước. | Ràng buộc | UC-013 | REQ-148; REQ-59 (phụ) | Hiệu lực | Trả lời Q-64; cùng cách xử lý BR-60 của suất chiếu |
| BR-64 | Không được bỏ mục giá khi cụm rạp còn suất chiếu chưa tới giờ bắt đầu và còn trong lịch chiếu mà loại phòng của phòng chiếu và định dạng bằng của mục giá, phòng chiếu có ít nhất một ghế thuộc loại ghế của mục giá, và khung giờ xác định theo giờ bắt đầu (BR-12) bằng khung giờ của mục giá. | Ràng buộc | UC-013, UC-014 | REQ-146; REQ-59, REQ-145 (phụ) | Hiệu lực | Trả lời Q-61 (phương án A), Q-62; giữ cho BR-69 đúng sau khi suất chiếu đã lập. UC-014 theo P04 UC-014 Mục 6 |
| BR-65 | Giá vé của một lần giữ ghế được chốt cùng lúc với việc giữ ghế (UC-005 bước 7) và giữ nguyên tới hết lần giữ ghế; việc đặt giá, bỏ giá sau đó không đổi giá của lần giữ ghế đó; quy tắc áp dụng cả khi bán tại quầy. | Ràng buộc | UC-013, UC-005 | REQ-149; REQ-37, REQ-38 (phụ) | Hiệu lực | Trả lời Q-65; số tiền giao dịch bằng tổng tiền hiển thị do UC-005 bước 10 và REQ-111 quy định |
| BR-66 | Thay đổi bảng giá có hiệu lực ngay khi lưu, áp dụng cho mọi lần chốt giá sau đó, kể cả các suất chiếu đã lập; không hẹn ngày hiệu lực. | Ràng buộc | UC-013, UC-005 | REQ-150; REQ-59 (phụ) | Hiệu lực | Trả lời Q-66 |
| BR-67 | Thay đổi bảng giá không đổi giá của vé đã bán; vé giữ giá đã ghi trên vé. | Suy luận | UC-013, UC-005 | REQ-149; REQ-105 (phụ) | Hiệu lực | Suy ra từ giá vé ghi trên vé (REQ-105); hệ quả với tiền hoàn ở BR-19, BR-31 (UC-008) |
| BR-68 | Việc kiểm tra BR-64 rồi bỏ mục giá và việc kiểm tra BR-69 rồi lưu suất chiếu lập hoặc sửa (UC-014 bước 8) không xen vào nhau: nếu suất chiếu được ghi nhận trước thì bỏ giá bị từ chối theo BR-64; nếu bỏ giá được ghi nhận trước thì lập hoặc sửa suất chiếu bị từ chối theo BR-69. | Ràng buộc | UC-013, UC-014 | REQ-151; REQ-145 (phụ) | Hiệu lực | Trả lời Q-67; tương tự BR-54 |
| BR-69 | Không được lập suất chiếu, hoặc sửa suất chiếu thành suất chiếu, khi bảng giá của cụm rạp chưa có giá cho mọi loại ghế có trong phòng chiếu (loại ghế mà phòng chiếu có ít nhất một ghế), ứng với khung giờ xác định theo giờ bắt đầu của suất chiếu (BR-12), theo loại phòng của phòng chiếu và định dạng phim của suất chiếu. | Ràng buộc | UC-014, UC-013 | REQ-145; REQ-37, REQ-38 (phụ) | Hiệu lực | Trả lời Q-61 (phương án A); mở rộng BR-59 sang loại ghế và khung giờ. Đã gộp BR-59 (P06) |
| BR-70 | Giá vé của mục giá là số nguyên đồng lớn hơn 0, không có giá trị tối đa; mọi tổ hợp loại phòng, định dạng phim, loại ghế và khung giờ chiếu đều đặt được giá, kể cả loại phòng mà cụm rạp chưa có. | Ràng buộc | UC-013 | REQ-147; REQ-37, REQ-38 (phụ) | Hiệu lực | Trả lời Q-63 |
| BR-71 | Việc chốt giá của một lần giữ ghế và việc lưu thay đổi bảng giá không xen vào nhau: thay đổi bảng giá được ghi nhận trước thì lần giữ ghế dùng giá mới; thay đổi bảng giá được ghi nhận sau thì không ảnh hưởng lần giữ ghế đó. | Ràng buộc | UC-013, UC-005 | REQ-149; REQ-150 (phụ) | Hiệu lực | Trả lời Q-65 |
| BR-72 | Không được giữ ghế khi bảng giá của cụm rạp không có giá cho một ghế đã chọn, ứng với loại phòng, định dạng phim, loại ghế và khung giờ chiếu của suất chiếu. | Ràng buộc | UC-005, UC-013 | REQ-152; REQ-37, REQ-38 (phụ) | Hiệu lực | Trả lời Q-61; lưới an toàn khi bất biến của BR-69, BR-64 bị vỡ ở nơi khác |
| BR-73 | Việc sửa phòng chiếu không được làm suất chiếu chưa tới giờ bắt đầu của phòng chiếu đó thiếu giá theo BR-69. | Ràng buộc | UC-012, UC-013, UC-014 | REQ-145; REQ-57, REQ-58 (phụ) | Hiệu lực | UC-012 chưa đặc tả; UC-012 phải dẫn BR này khi đặc tả. UC-014 theo P02 Mục 5 (REQ-145) |
| BR-74 | Một ghế đôi là một vị trí dành cho hai người và được bán như một ghế. | Sự kiện | UC-005 | REQ-17 | Hiệu lực | Cấp ở P06 vì REQ-17 chưa có BR; UC-005 theo P02 Mục 5. Khác BR-06: BR-74 nêu ghế đôi được bán như một ghế (một vé), BR-06 nêu cách đếm ghế đôi trong số ghế mỗi lần giữ ghế, sức chứa và tỉ lệ lấp đầy |
| BR-75 | Không được sửa sơ đồ ghế của phòng chiếu đang có suất chiếu chưa diễn ra đã bán vé hoặc có ghế đang được giữ. | Ràng buộc | UC-012 | REQ-58 | Gộp vào BR-87 | Cấp ở P06 vì REQ-58 chưa có BR; UC-012 theo P02 Mục 5 (chưa đặc tả P04). Đã trả lời Q-12 (P00). BR-73 là quy tắc liên quan về giá khi sửa phòng chiếu. Gộp theo review P05, P06 (Q-80): BR-87 chặt hơn, mọi suất chiếu chưa diễn ra đã bán vé hoặc có ghế đang được giữ đều đã tới thời điểm mở bán và chưa kết thúc, nên thoả BR-87 thì thoả BR-75 |
| BR-76 | Phim sắp chiếu là phim chưa tới ngày khởi chiếu; phim đang chiếu là phim đã tới ngày khởi chiếu và chưa qua ngày kết thúc chiếu. | Suy luận | UC-003 | REQ-96 | Hiệu lực | Cấp ở P06 vì REQ-96 chưa có BR; UC-003 theo P02 Mục 5 (chưa đặc tả P04). BR-49 dùng cách hiểu này cho khoảng chiếu của suất chiếu |
| BR-77 | Doanh thu gồm tiền vé đã bán trừ phần tiền đã hoàn cho khách. | Tính toán | UC-015, UC-016 | REQ-99 | Hiệu lực | Cấp ở P06 vì REQ-99 chưa có BR; UC-015, UC-016 theo P02 Mục 5 (chưa đặc tả P04). UC-008 Mục 8: khoản hoàn chưa hoàn được và đã ghi log lỗi chưa được trừ khi chưa xử lý xong |
| BR-78 | Mỗi nhân viên quầy, nhân viên soát vé và quản lý cụm rạp thuộc đúng một cụm rạp; quản lý chuỗi không thuộc cụm rạp nào. | Sự kiện | UC-017 | REQ-100 | Hiệu lực | Cấp ở P06 vì REQ-100 chưa có BR chính; UC-017 theo P02 Mục 5. BR-02, BR-17, BR-22, BR-46, BR-61 dùng REQ-100 làm căn cứ phụ cho phạm vi cụm rạp của từng use case |
| BR-79 | Mỗi nhân viên có đúng một vai trò. | Sự kiện | UC-017 | REQ-101 | Hiệu lực | Cấp ở P06 vì REQ-101 chưa có BR; UC-017 theo P02 Mục 5 |
| BR-80 | Mã đặt vé là duy nhất trên toàn hệ thống. | Ràng buộc | UC-005 | REQ-106 | Hiệu lực | Cấp ở P06 vì REQ-106 chưa có BR; UC-005 theo P02 Mục 5. Nguồn không quy định định dạng của mã |
| BR-81 | Email dùng để đăng ký và đăng nhập tài khoản khách theo định dạng email chuẩn. | Ràng buộc | UC-001 | REQ-107 | Hiệu lực | Cấp ở P06 vì REQ-107 chưa có BR; UC-001 theo P02 Mục 5 (chưa đặc tả P04). Đã trả lời Q-26 |
| BR-82 | Số điện thoại dùng để đăng ký và đăng nhập tài khoản khách là số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0. | Ràng buộc | UC-001 | REQ-108 | Hiệu lực | Cấp ở P06 vì REQ-108 chưa có BR; UC-001 theo P02 Mục 5 (chưa đặc tả P04). Đã trả lời Q-26 |
| BR-83 | Vé được soát vào bất kỳ thời điểm nào so với giờ bắt đầu của suất chiếu; hệ thống không giới hạn thời điểm soát vé. | Ràng buộc | UC-009 | REQ-125 | Hiệu lực | "Giờ chiếu" của REQ-125 hiểu là giờ bắt đầu của suất chiếu (REQ-91). Cấp ở P06 vì REQ-125 chưa có BR; UC-009 theo P02 Mục 5. Đã trả lời Q-43 (P04 UC-009) |
| BR-84 | Phim hoặc phòng chiếu thay đổi sau khi lập suất chiếu không làm suất chiếu đã lập tự đổi. | Ràng buộc | UC-014 | REQ-144 | Hiệu lực | Cấp ở P06 vì REQ-144 chưa có BR; UC-014 theo P02 Mục 5. Đã trả lời Q-58 (P04 UC-014). Giờ kết thúc giữ nguyên khi phim đổi thời lượng (BR-50) |
| BR-85 | Các báo kết quả thanh toán của cổng thanh toán và mọi thao tác làm đổi trạng thái của cùng một lần giữ ghế (hết hạn, khách huỷ giữ ghế, báo thành công, báo thất bại, xác nhận đã thu tiền của nhân viên quầy) được xử lý tuần tự, khoá theo lần giữ ghế; mỗi thao tác thấy trạng thái do thao tác trước để lại. | Ràng buộc | UC-005, UC-006 | REQ-160; REQ-35, REQ-36, REQ-109, REQ-110, REQ-134 (phụ) | Hiệu lực | Trả lời Q-79. Gồm việc so thời điểm hết hạn với kết quả thanh toán rồi chuyển ghế sang đã bán hoặc ghi nhận thanh toán đến trễ là một thao tác không chia cắt (BR-14, BR-15, BR-44); hai báo thành công của cùng một giao dịch đến đồng thời thì chỉ báo đầu được xử lý (BR-37). Cơ chế bảo đảm thuộc P07, P09 |
| BR-86 | Lần giữ ghế đã ở trạng thái cuối (Đã hoàn tất, Hết hạn, Đã huỷ, Thanh toán thất bại) thì trạng thái không thể thay đổi nữa; báo kết quả thanh toán đến sau được xử lý theo trạng thái cuối đó: báo thành công của giao dịch chưa xử lý được hoàn toàn bộ như thanh toán đến trễ (UC-006), báo của giao dịch đã xử lý là báo trùng, báo thất bại chỉ được ghi nhận. | Ràng buộc | UC-005, UC-006 | REQ-161; REQ-35, REQ-109, REQ-110, REQ-133 (phụ) | Hiệu lực | Trả lời Q-79. Tên bốn trạng thái cuối do nhóm đặt (Q-69, P05 GL-25). Báo thành công từ giao dịch khác cho lần giữ ghế Đã hoàn tất: BR-40; cho lần giữ ghế Hết hạn: BR-14; Đã huỷ hoặc Thanh toán thất bại: BR-15; báo trùng: BR-37; báo thất bại: BR-39 |
| BR-87 | Không được sửa sơ đồ ghế của phòng chiếu khi phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc, kể cả khi suất chiếu chưa có vé đã bán và chưa có ghế được giữ. | Ràng buộc | UC-012 | REQ-162; REQ-58 (phụ) | Hiệu lực | Trả lời Q-80. Thời điểm so là lúc hệ thống kiểm tra yêu cầu sửa; chưa kết thúc tính theo giờ kết thúc của suất chiếu (BR-50). Việc sửa chỉ xảy ra khi phòng chưa có suất chiếu nào tới thời điểm mở bán nên không có lần giữ ghế nào để xen vào (giữ ghế cần suất chiếu đã mở bán, BR-01). Đã gộp BR-75. UC-012 chưa đặc tả; UC-012 phải dẫn BR này khi đặc tả. BR-73 áp dụng thêm cho suất chiếu chưa mở bán (về giá) |
| BR-88 | Tỉ lệ lấp đầy của một suất chiếu bằng số ghế của vé đã bán chưa huỷ chia cho sức chứa của phòng chiếu; tỉ lệ lấp đầy theo ngày hoặc theo phim bằng tổng số ghế của vé đã bán chưa huỷ chia cho tổng sức chứa của các suất chiếu trong ngày hoặc của phim trong kỳ báo cáo; ghế đang được giữ không được tính. | Tính toán | UC-015, UC-016 | REQ-153; REQ-67, REQ-68, REQ-87 (phụ) | Hiệu lực | Trả lời Q-71. Ghế đôi tính một ghế (BR-06). Vé đã sử dụng vẫn là vé đã bán chưa huỷ. Ghế đang được giữ chưa tính vì có thể hết hạn; cùng tinh thần BR-77. UC-015, UC-016 chưa đặc tả |
| BR-89 | Khi dịch vụ email từ chối hoặc không phản hồi lúc gửi email chứa vé hoặc email thông báo hoàn tiền, vé và khoản hoàn giữ nguyên hiệu lực; hệ thống thử gửi lại vài lần, nếu vẫn lỗi thì ghi log lỗi; không huỷ vé và không hoàn tiền thêm. | Kích hoạt hành động | UC-005, UC-006 | REQ-157; REQ-31, REQ-90 (phụ) | Hiệu lực | Trả lời Q-76. Số lần thử lại và khoảng cách giữa hai lần là quyết định thiết kế (P09); cùng cách xử lý BR-41. Khách vẫn thấy vé trên màn hình và trong lịch sử đặt vé (UC-007) |
| BR-90 | Khi cổng thanh toán từ chối hoặc không trả lời trong 30 giây yêu cầu tạo giao dịch, hệ thống giữ nguyên lần giữ ghế và báo khách chưa tạo được thanh toán; khách thử lại được tới thời điểm hết hạn giữ ghế, tới lúc đó ghế được giải phóng theo UC-005 luồng 7b. Với cổng chỉ nhận địa chỉ thanh toán đã ký, quy tắc này chỉ áp dụng khi hệ thống lỗi trước lúc chuyển khách sang cổng. | Kích hoạt hành động | UC-005 | REQ-158; REQ-136 (phụ) | Hiệu lực | Trả lời Q-77. Mức 30 giây mượn từ BR-43. Thời điểm hết hạn giữ ghế không đổi khi khách thử lại. Nếu cổng đã tạo giao dịch ở lần trước thì giao dịch báo thành công thứ hai được nhận ra qua mã tham chiếu lần giữ ghế (BR-40) |
| BR-91 | Thanh toán thành công mà số tiền cổng báo khác số tiền hệ thống đã ghi nhận cho giao dịch được ghi log lỗi và để lại cho xử lý thủ công ngoài hệ thống; hệ thống không tạo vé, không tự hoàn tiền và không gửi email. | Kích hoạt hành động | UC-006 | REQ-129 | Hiệu lực | Cùng cách xử lý BR-38; cấp ở UC-006 1.6 |
| BR-92 | Không được đổi phòng chiếu của suất chiếu đã từng có vé, kể cả khi mọi vé của suất chiếu đó đã huỷ; muốn đổi phòng thì xoá suất chiếu đó theo các quy tắc xoá suất chiếu (BR-53, BR-57, BR-58) rồi lập suất chiếu mới. | Ràng buộc | UC-014 | REQ-65, REQ-141 | Hiệu lực | Chặt hơn BR-53, chủ dự án đã chốt (R13D-01, phương án A); cấp ở UC-014 1.4 |
| BR-93 | Báo thanh toán thất bại của một giao dịch chỉ làm lần giữ ghế chuyển sang Thanh toán thất bại và giải phóng ghế khi giao dịch đó là giao dịch tạo sau cùng của lần giữ ghế; báo thất bại của giao dịch cũ khi khách đã có giao dịch thanh toán mới hơn chỉ được ghi nhận, lần giữ ghế và ghế giữ nguyên. | Ràng buộc | UC-005 | REQ-133; REQ-136 (phụ) | Hiệu lực | Làm rõ BR-39 và BR-86; cấp ở UC-005 1.11 |

## 7. Ma trận truy vết

Bảng REQ --> NFR / BR:

| REQ | Loại REQ | NFR / BR | Ghi chú |
|---|---|---|---|
| REQ-01 | Dữ liệu | NFR-04 | Dữ liệu quy mô, chuyển P06 theo P02 Mục 5: dùng làm dữ liệu mẫu của NFR-04 |
| REQ-03 | Dữ liệu | NFR-04, NFR-05 | Dữ liệu quy mô, chuyển P06 theo P02 Mục 5: dùng làm điều kiện đo của NFR-04, NFR-05 |
| REQ-04 | Dữ liệu | NFR-04 | Dữ liệu quy mô, chuyển P06 theo P02 Mục 5: dùng làm dữ liệu mẫu của NFR-04 |
| REQ-17 | Quy tắc nghiệp vụ | BR-74 | Căn cứ phụ của BR-06 |
| REQ-19 | Phi chức năng | NFR-08 | Yêu cầu đặc biệt UC-005 dòng 2 |
| REQ-20 | Quy tắc nghiệp vụ | BR-05 | Không có |
| REQ-22 | Quy tắc nghiệp vụ | BR-10 | Căn cứ phụ của BR-44 |
| REQ-23 | Quy tắc nghiệp vụ | BR-08 | Không có |
| REQ-24 | Quy tắc nghiệp vụ | BR-07 | Không có |
| REQ-26 | Quy tắc nghiệp vụ | BR-09 | Không có |
| REQ-27 | Quy tắc nghiệp vụ | BR-09 | Không có |
| REQ-36 | Quy tắc nghiệp vụ | BR-14 | Không có |
| REQ-37 | Quy tắc nghiệp vụ | BR-11, BR-61, BR-62 | Căn cứ phụ của BR-65, BR-69, BR-70, BR-72 |
| REQ-38 | Quy tắc nghiệp vụ | BR-11, BR-62 | Căn cứ phụ của BR-65, BR-69, BR-70, BR-72 |
| REQ-41 | Quy tắc nghiệp vụ | BR-18 | Căn cứ phụ của BR-32 |
| REQ-42 | Quy tắc nghiệp vụ | BR-19, BR-21, BR-26 | Căn cứ phụ của BR-31 |
| REQ-46 | Quy tắc nghiệp vụ | BR-05, BR-07, BR-10 | Không có |
| REQ-47 | Quy tắc nghiệp vụ | BR-13 | Căn cứ phụ của BR-17, BR-44 |
| REQ-51 | Quy tắc nghiệp vụ | BR-22, BR-23, BR-24, BR-25 | Căn cứ phụ của BR-21, BR-30 |
| REQ-58 | Quy tắc nghiệp vụ | BR-75, BR-87 | BR-75 đã gộp vào BR-87; căn cứ phụ của BR-73, BR-87 |
| REQ-62 | Quy tắc nghiệp vụ | BR-47 | Không có |
| REQ-63 | Quy tắc nghiệp vụ | BR-48 | Không có |
| REQ-64 | Quy tắc nghiệp vụ | BR-51, BR-52 | Không có |
| REQ-65 | Quy tắc nghiệp vụ | BR-53, BR-54, BR-92 | Không có |
| REQ-73 | Phi chức năng | NFR-04 | Chuyển P06 theo P02 Mục 5 |
| REQ-74 | Phi chức năng | NFR-05 | Yêu cầu đặc biệt UC-005 dòng 3 |
| REQ-75 | Phi chức năng | NFR-06 | Yêu cầu đặc biệt UC-005 dòng 1 |
| REQ-76 | Phi chức năng | NFR-07 | Yêu cầu đặc biệt UC-005 dòng 4. Thanh toán báo về trong khoảng trễ này xử lý theo BR-14, BR-15 |
| REQ-77 | Ràng buộc | NFR-10 | Chuyển P06 theo P02 Mục 5 |
| REQ-79 | Giao tiếp ngoài | NFR-15, NFR-16, NFR-17 | Giao tiếp ACT-07; hành vi khi cổng không phản hồi hoàn tiền ở BR-41, BR-43 |
| REQ-80 | Giao tiếp ngoài | NFR-18 | Giao tiếp ACT-08 |
| REQ-84 | Quy tắc nghiệp vụ | BR-18 | Căn cứ phụ của BR-32 |
| REQ-85 | Quy tắc nghiệp vụ | BR-19, BR-20, BR-21 | Căn cứ phụ của BR-31 |
| REQ-86 | Quy tắc nghiệp vụ | BR-01 | Căn cứ phụ của BR-45, BR-55 |
| REQ-87 | Quy tắc nghiệp vụ | BR-06 | Căn cứ phụ của BR-88 |
| REQ-88 | Quy tắc nghiệp vụ | BR-03 | Không có |
| REQ-89 | Quy tắc nghiệp vụ | BR-04 | Không có |
| REQ-91 | Quy tắc nghiệp vụ | BR-12 | Không có |
| REQ-92 | Quy tắc nghiệp vụ | BR-04 | Không có |
| REQ-96 | Quy tắc nghiệp vụ | BR-76 | Không có |
| REQ-97 | Quy tắc nghiệp vụ | BR-49 | Không có |
| REQ-98 | Quy tắc nghiệp vụ | BR-50 | Không có |
| REQ-99 | Quy tắc nghiệp vụ | BR-77 | Không có |
| REQ-100 | Quy tắc nghiệp vụ | BR-78 | Căn cứ phụ của BR-02, BR-17, BR-22, BR-46, BR-61 |
| REQ-101 | Quy tắc nghiệp vụ | BR-79 | Không có |
| REQ-103 | Ràng buộc | NFR-12 | Chuyển P06 theo P02 Mục 5 |
| REQ-106 | Quy tắc nghiệp vụ | BR-80 | Không có |
| REQ-107 | Quy tắc nghiệp vụ | BR-81 | Không có |
| REQ-108 | Quy tắc nghiệp vụ | BR-82 | Không có |
| REQ-109 | Quy tắc nghiệp vụ | BR-15, BR-16, BR-26, BR-37 | BR-16 đã gộp vào BR-37; căn cứ phụ của BR-85, BR-86 |
| REQ-110 | Quy tắc nghiệp vụ | BR-16, BR-37 | BR-16 đã gộp vào BR-37; căn cứ phụ của BR-85, BR-86 |
| REQ-112 | Quy tắc nghiệp vụ | BR-27 | Mọi BR của REQ này ở trạng thái Loại; BR thay thế ở mục 6 |
| REQ-113 | Quy tắc nghiệp vụ | BR-28 | Mọi BR của REQ này ở trạng thái Loại; BR thay thế ở mục 6 |
| REQ-114 | Quy tắc nghiệp vụ | BR-36 | Mọi BR của REQ này ở trạng thái Loại; BR thay thế ở mục 6 |
| REQ-115 | Quy tắc nghiệp vụ | BR-35 | Mọi BR của REQ này ở trạng thái Loại; BR thay thế ở mục 6 |
| REQ-117 | Quy tắc nghiệp vụ | BR-29 | Mọi BR của REQ này ở trạng thái Loại; BR thay thế ở mục 6 |
| REQ-118 | Quy tắc nghiệp vụ | BR-30 | Không có |
| REQ-119 | Phi chức năng | NFR-09 | Yêu cầu đặc biệt UC-005 dòng 5 và UC-008 dòng 1 |
| REQ-121 | Quy tắc nghiệp vụ | BR-32 | Không có |
| REQ-122 | Quy tắc nghiệp vụ | BR-31 | Không có |
| REQ-123 | Quy tắc nghiệp vụ | BR-34 | Không có |
| REQ-124 | Quy tắc nghiệp vụ | BR-33 | Không có |
| REQ-125 | Quy tắc nghiệp vụ | BR-83 | Không có |
| REQ-126 | Ràng buộc | NFR-13 | Đồng thời phủ bằng UC-009 (không có luồng nhập tay) |
| REQ-128 | Ràng buộc | NFR-14 | Đồng thời phủ bằng UC-009 (bước 3, 4) và UC-005 (bước 13) |
| REQ-129 | Quy tắc nghiệp vụ | BR-38, BR-91 | Không có |
| REQ-130 | Quy tắc nghiệp vụ | BR-40 | Không có |
| REQ-131 | Quy tắc nghiệp vụ | BR-41, BR-42 | Không có |
| REQ-132 | Quy tắc nghiệp vụ | BR-43 | Không có |
| REQ-133 | Quy tắc nghiệp vụ | BR-39, BR-93 | Không có |
| REQ-134 | Quy tắc nghiệp vụ | BR-44 | Không có |
| REQ-135 | Quy tắc nghiệp vụ | BR-45 | Căn cứ phụ của BR-55 |
| REQ-136 | Quy tắc nghiệp vụ | BR-40, BR-93 | Không có |
| REQ-137 | Quy tắc nghiệp vụ | BR-55 | Không có |
| REQ-138 | Quy tắc nghiệp vụ | BR-56 | Không có |
| REQ-139 | Quy tắc nghiệp vụ | BR-57 | Không có |
| REQ-140 | Quy tắc nghiệp vụ | BR-58 | Không có |
| REQ-141 | Quy tắc nghiệp vụ | BR-53, BR-92 | Không có |
| REQ-142 | Quy tắc nghiệp vụ | BR-54 | Không có |
| REQ-143 | Quy tắc nghiệp vụ | BR-60 | Không có |
| REQ-144 | Quy tắc nghiệp vụ | BR-84 | Không có |
| REQ-145 | Quy tắc nghiệp vụ | BR-59, BR-69, BR-73 | BR-59 đã gộp vào BR-69; Căn cứ phụ của BR-64, BR-68 |
| REQ-147 | Quy tắc nghiệp vụ | BR-70 | Không có |
| REQ-148 | Quy tắc nghiệp vụ | BR-63 | Không có |
| REQ-149 | Quy tắc nghiệp vụ | BR-65, BR-67, BR-71 | Không có |
| REQ-150 | Quy tắc nghiệp vụ | BR-66 | Căn cứ phụ của BR-71 |
| REQ-151 | Quy tắc nghiệp vụ | BR-68 | Không có |
| REQ-152 | Quy tắc nghiệp vụ | BR-72 | Không có |
| REQ-153 | Quy tắc nghiệp vụ | BR-88 | Căn cứ phụ: REQ-67, REQ-68, REQ-87 |
| REQ-155 | Phi chức năng | NFR-04, NFR-05 | Mức đạt của phục vụ được (Q-74) |
| REQ-156 | Phi chức năng | NFR-06, NFR-07, NFR-08, NFR-09 | Cách tính ngưỡng thời gian (Q-75) |
| REQ-157 | Quy tắc nghiệp vụ | BR-89 | Áp dụng NFR-18 |
| REQ-158 | Quy tắc nghiệp vụ | BR-90 | Áp dụng NFR-15 |
| REQ-159 | Ràng buộc | NFR-11 | Trình duyệt và thiết bị (Q-78) |
| REQ-160 | Quy tắc nghiệp vụ | BR-85 | Không có |
| REQ-161 | Quy tắc nghiệp vụ | BR-86 | Không có |
| REQ-162 | Quy tắc nghiệp vụ | BR-87 | Gộp BR-75 |

Bảng UC --> NFR / BR (BR chỉ tính trạng thái Hiệu lực; NFR toàn hệ thống NFR-04, NFR-10, NFR-11 áp dụng cho mọi UC và không lặp lại ở từng hàng):

| UC | NFR | BR |
|---|---|---|
| UC-001 Đăng ký tài khoản | - | BR-81, BR-82 |
| UC-002 Đăng nhập (Loại) | - | - |
| UC-003 Tra cứu phim | - | BR-76 |
| UC-004 Tra cứu lịch chiếu | - | - |
| UC-005 Đặt vé | NFR-01, NFR-02, NFR-05, NFR-06, NFR-07, NFR-08, NFR-09, NFR-14, NFR-15, NFR-16, NFR-18 | BR-01, BR-02, BR-03, BR-04, BR-05, BR-06, BR-07, BR-08, BR-09, BR-10, BR-11, BR-12, BR-13, BR-14, BR-15, BR-37, BR-44, BR-45, BR-54, BR-61, BR-62, BR-65, BR-66, BR-67, BR-71, BR-72, BR-74, BR-80, BR-85, BR-86, BR-89, BR-90, BR-93 |
| UC-006 Hoàn tiền thanh toán trễ | NFR-16, NFR-17, NFR-18 | BR-14, BR-15, BR-26, BR-37, BR-38, BR-39, BR-40, BR-41, BR-42, BR-43, BR-85, BR-86, BR-89, BR-91 |
| UC-007 Xem lịch sử đặt vé | NFR-01 | - |
| UC-008 Huỷ vé | NFR-01, NFR-02, NFR-09, NFR-17 | BR-11, BR-17, BR-18, BR-19, BR-20, BR-21, BR-26, BR-30, BR-31, BR-32, BR-41, BR-42, BR-43 |
| UC-009 Soát vé | NFR-02, NFR-13, NFR-14 | BR-22, BR-23, BR-24, BR-25, BR-30, BR-33, BR-34, BR-83 |
| UC-010 Quản lý phim | NFR-02 | - |
| UC-011 Quản lý cụm rạp | NFR-02 | - |
| UC-012 Quản lý phòng chiếu | NFR-02 | BR-06, BR-73, BR-87 |
| UC-013 Quản lý bảng giá | NFR-02 | BR-11, BR-12, BR-61, BR-62, BR-63, BR-64, BR-65, BR-66, BR-67, BR-68, BR-69, BR-70, BR-71, BR-72, BR-73 |
| UC-014 Lập lịch suất chiếu | NFR-02 | BR-01, BR-12, BR-45, BR-46, BR-47, BR-48, BR-49, BR-50, BR-51, BR-52, BR-53, BR-54, BR-55, BR-56, BR-57, BR-58, BR-60, BR-64, BR-68, BR-69, BR-73, BR-84, BR-92 |
| UC-015 Xem báo cáo cụm rạp | NFR-02 | BR-06, BR-77, BR-88 |
| UC-016 Xem báo cáo toàn chuỗi | NFR-02 | BR-06, BR-77, BR-88 |
| UC-017 Quản lý tài khoản nhân viên | NFR-03, NFR-12 | BR-78, BR-79 |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-74 | Đã trả lời (Theo đề xuất: mỗi phiên làm ba việc xem sơ đồ ghế, giữ ghế, thanh toán; đạt khi ít nhất 99% thao tác thành công không do lỗi hệ thống, giữ ghế vẫn trong 2 giây và không ghế nào bị giữ hoặc bán cho hai người), đề bài bổ sung Mục 19 (REQ-155). Tiêu chí đạt của "phục vụ được" 4.000 khách truy cập đồng thời trên toàn chuỗi và tới 1.000 khách cùng thao tác trên một suất chiếu là gì? | NFR-04, NFR-05; kiến trúc, kiểm thử tải; X2 | REQ-73, REQ-74 chỉ nêu "phải phục vụ được", không nêu mức đạt |
| Q-75 | Đã trả lời (Theo đề xuất: tải thường mọi lần thao tác; tải đỉnh 95% lần thao tác cho ngưỡng 2 giây và 3 giây, đo từ lúc hệ thống nhận yêu cầu tới lúc trả kết quả, kể cả kết quả ghế đã có người giữ; ngưỡng 1 phút mọi lần; mốc 3 giây của ghế trở về trống tính từ lúc ghế trống, cửa sổ tối đa 63 giây kể từ thời điểm hết hạn), đề bài bổ sung Mục 19 (REQ-156). Các ngưỡng thời gian 2 giây, 1 phút và 3 giây tính cho mọi lần thao tác hay theo phân vị, ở mức tải nào, tính từ lúc nào tới lúc nào? | NFR-06, NFR-07, NFR-08, NFR-09; kiến trúc, kiểm thử tải | REQ-75, REQ-76, REQ-19, REQ-119 chỉ nêu ngưỡng, không nêu cách tính và điều kiện đo |
| Q-76 | Đã trả lời (Theo đề xuất: vé và khoản hoàn giữ nguyên hiệu lực; thử gửi lại vài lần, vẫn lỗi thì ghi log lỗi; không huỷ vé, không hoàn tiền thêm), đề bài bổ sung Mục 21 (REQ-157). Khi dịch vụ email từ chối hoặc không phản hồi lúc gửi email chứa vé (UC-005 bước 14) hoặc email thông báo hoàn tiền (UC-006 bước 7), hệ thống xử lý thế nào? | NFR-18; BR-89; UC-005 bước 14; UC-006 bước 7 | Mục 7, Mục 9, Mục 21 nêu gửi email nhưng không nêu trường hợp gửi không thành công |
| Q-77 | Đã trả lời (Theo đề xuất: giữ nguyên lần giữ ghế, báo khách chưa tạo được thanh toán và cho thử lại tới hết thời gian giữ ghế; mỗi lần chờ cổng tối đa 30 giây), đề bài bổ sung Mục 21 (REQ-158). Khi cổng thanh toán từ chối hoặc không trả lời yêu cầu tạo giao dịch (UC-005 bước 10), hệ thống xử lý thế nào? | NFR-15; BR-90; UC-005 bước 10, luồng 10a | Mục 21 chỉ nêu cách xử lý khi cổng từ chối hoặc không trả lời yêu cầu hoàn tiền, không nêu yêu cầu tạo giao dịch |
| Q-78 | Đã trả lời (Theo đề xuất: Chrome, Edge, Firefox, Safari bản ổn định mới nhất; màn hình từ 360 pixel; soát vé bằng điện thoại hoặc máy tính bảng có camera, Chrome hoặc Safari bản mới, HTTPS), đề bài bổ sung Mục 19 (REQ-159). "Web app responsive" cần hỗ trợ những trình duyệt và kích thước màn hình tối thiểu nào, và thiết bị soát vé bằng camera (UC-009) là loại nào? | NFR-11; UC-009 | project-profile.md ghi NEN_TANG là "Web app responsive", Mục 13 nêu "camera của thiết bị", cả hai không nêu trình duyệt, kích thước, thiết bị |
| Q-79 | Đã trả lời (Các báo kết quả thanh toán và mọi thao tác làm đổi trạng thái của cùng một lần giữ ghế được xử lý tuần tự, khoá theo lần giữ ghế; lần giữ ghế đã ở trạng thái cuối thì trạng thái không đổi nữa, báo đến sau xử lý theo trạng thái cuối đó), đề bài bổ sung Mục 9 (REQ-160, REQ-161). Hai báo thanh toán thành công cho cùng một giao dịch đến đồng thời, hoặc kết quả thanh toán đến đúng lúc hết hạn, xử lý thế nào? | BR-85, BR-86, BR-14, BR-15, BR-37; UC-005 bước 11, 12; UC-006 bước 2, 3 | Mục 9 không nêu xử lý đồng thời và tập trạng thái cuối của lần giữ ghế |
| Q-80 | Đã trả lời (Không được sửa sơ đồ ghế của phòng khi phòng có suất chiếu đã tới thời điểm mở bán mà chưa kết thúc), đề bài bổ sung Mục 15 (REQ-162). Sửa sơ đồ ghế của phòng: ghế quá thời điểm hết hạn mà chưa giải phóng có chặn không, và giữ ghế cùng lúc sửa sơ đồ xử lý thế nào? | BR-87; UC-012 (chưa đặc tả) | REQ-58 không nêu mốc hết hạn và xử lý đồng thời với giữ ghế |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 UC-001, UC-003, UC-012, UC-015, UC-016, UC-017 (chưa đặc tả) | BR-74 đến BR-84, BR-87, BR-88, BR-06, BR-73 | Khi đặc tả cần dẫn các BR sổ đã gắn theo P02 Mục 5 | UC-001: BR-81, BR-82; UC-003: BR-76; UC-012: BR-87, BR-73, BR-06, BR-74; UC-015, UC-016: BR-77, BR-88, BR-06; UC-017: BR-78, BR-79 |
| P02 | REQ-12, REQ-102, REQ-104, REQ-103 | P06 mục 2 và mục 4 nhận các REQ đăng nhập (chức năng dùng chung) và REQ-103 thành NFR-01 đến NFR-03, NFR-12; Mục 5 của P02 ghi "-" ở cột UC phủ | Bổ sung vào Ghi chú của bốn REQ này: "Phủ bằng P06 NFR-01", "NFR-02", "NFR-03", "NFR-12" |

## Vấn đề còn mở

- P05-glossary.md 1.1 đã được đối chiếu với sổ BR và NFR; mã Q đã là mã chính thức (Q-74 đến Q-80, sau Q-73 của P05).
- Gộp BR-59 vào BR-69 theo chỉ đạo của người dùng (BR-69 mở rộng BR-59, trả lời Q-61). Quy tắc mặc định giữ mã nhỏ hơn ở trạng thái Hiệu lực không áp dụng vì hai BR không cùng nghĩa: BR-59 là trường hợp riêng (chỉ loại phòng và định dạng) của BR-69.
- Gộp BR-16 vào BR-37 là đánh giá của P06 (BR-37 bao hàm BR-16, hai BR có cùng bộ REQ chính), cùng ngoại lệ với quy tắc giữ mã nhỏ hơn như BR-59. Nếu người dùng muốn giữ BR-16 riêng, đặt lại BR-16 thành Hiệu lực và khôi phục BR-16 trong UC-006.
- Gộp BR-75 vào BR-87 theo trả lời Q-80 (BR-87 chặt hơn, thoả BR-87 thì thoả BR-75), cùng ngoại lệ với quy tắc giữ mã nhỏ hơn như BR-59. Nếu người dùng muốn giữ BR-75 riêng để bám REQ-58, đặt lại BR-75 thành Hiệu lực.
- BR-41 và BR-43 (thử lại hoàn tiền, thời hạn chờ 30 giây, khoá chống hoàn trùng) nằm sát ranh giới với giao tiếp ngoài. P06 giữ chúng là BR vì P00 phân loại REQ-131, REQ-132 là Quy tắc nghiệp vụ và chúng có hệ quả nghiệp vụ (không gửi email cho khách, vé vẫn huỷ, ghế vẫn trống); NFR-17 chỉ dẫn chiếu, không lặp nội dung.
- Các con số 99% (Q-74), 95% (Q-75) và 30 giây chờ cổng tạo giao dịch (Q-77) là quyết định của nhóm theo phương án đề xuất của review, không phải số của đề bài gốc; đã ghi vào đề bài ở Mục 19, Mục 21.
- Số lần thử gửi lại email (BR-89), thử lại hoàn tiền (BR-41) và khoảng cách giữa các lần là quyết định thiết kế (P09), không cố định ở đặc tả.
- Không có dòng "Chức năng dùng chung" hay việc "Ghi nhận <việc> chờ <sự kiện>" nào trong Mục 8 của các đặc tả P04; cụm "ghi nhận giao dịch là thanh toán trễ chờ hoàn tiền" (UC-006 bước 3) là bước ghi trạng thái, không phải việc tự xử lý lại chờ sự kiện, nên không tạo NFR nhóm R.
- Cột Áp dụng cho UC của BR-42, BR-61, BR-62 được cộng thêm UC theo P02 Mục 5 (hợp ba nguồn của F6) dù quy tắc dùng chính ở UC khác; đã ghi nguồn ở Ghi chú.
- Các thuật ngữ, định dạng API chi tiết của cổng thanh toán và dịch vụ email không có trong nguồn; để bước thiết kế giao tiếp hệ thống (P11b) quyết định.
