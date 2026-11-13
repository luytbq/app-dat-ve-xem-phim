# P04 - Đặc tả use case UC-017 Quản lý tài khoản nhân viên - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M1); project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; _BR-register.md (đầu lô, đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; P06-supplementary-spec.md 1.3; UC-001-register-account.md 1.0, UC-007-view-booking-history.md 1.0 (đặc tả cùng lô, mẫu định dạng); UC-005-book-tickets.md 1.13, UC-009-check-ticket.md 1.6 (use case dùng tài khoản nhân viên); _review-P13.md (trả lời Q-136); dải mã được cấp Q-155 đến 174, BR-94 đến 113 |
| Phạm vi | UC-017 |
| Mã Q, ASM cuối đã cấp | Q-166 (dải Q-155 đến 174 của lô, Q-161 đến Q-166 cấp ở use case này; Q-136 đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-017 |
| Tên use case | Quản lý tài khoản nhân viên (Manage Staff Accounts) |
| Tác nhân chính | ACT-06 Quản trị viên |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản trị viên và hệ thống khi quản trị viên muốn tạo tài khoản nhân viên, gán nhân viên vào cụm rạp, phân vai trò hoặc khoá tài khoản của nhân viên nghỉ việc. Kết quả là nhân viên có tài khoản đúng cụm rạp và đúng vai trò. |
| Sự kiện kích hoạt | Có nhân viên mới hoặc nhân viên đổi cụm rạp, vai trò (EV-19) |
| Tiền điều kiện | Quản trị viên đã đăng nhập bằng tài khoản quản trị viên có sẵn và đang có phiên làm việc (REQ-103, REQ-104). |
| Hậu điều kiện (thành công) | Tài khoản nhân viên mới tồn tại với email duy nhất, họ tên, đúng một vai trò và cụm rạp phù hợp vai trò, ở trạng thái đang hoạt động (BR-78, BR-79, BR-95).<br>Khi kết thúc ở luồng 1a: tài khoản nhân viên đã chọn mang vai trò và cụm rạp mới, vẫn đúng một vai trò và cụm rạp phù hợp vai trò (BR-78, BR-79); email của tài khoản không đổi.<br>Khi kết thúc ở luồng 1b: tài khoản nhân viên đã chọn ở trạng thái bị khoá, không bị xoá, dữ liệu liên quan tới nhân viên được giữ nguyên (BR-96); nhân viên không đăng nhập được (BR-97). |
| Hậu điều kiện tối thiểu | Khi use case kết thúc không thành công, không có tài khoản nhân viên nào được tạo hoặc thay đổi. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-70, REQ-71, REQ-72, REQ-100, REQ-101 (theo P02); REQ-102, REQ-103, REQ-104 (P02 ghi "-"); REQ-54 (tham chiếu, UC-011); REQ-89, REQ-92 (tham chiếu, UC-005) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản trị viên | Yêu cầu tạo tài khoản cho một nhân viên mới. |
| 2 | Hệ thống | Hiển thị các cụm rạp của chuỗi và bốn vai trò nhân viên để gán và phân quyền (xem Dữ liệu ra 1). |
| 3 | Quản trị viên | Nhập email và họ tên của nhân viên, chọn vai trò và cụm rạp, rồi gửi (mật khẩu ban đầu: Q-161; xem Dữ liệu vào 1). |
| 4 | Hệ thống | Kiểm tra nhân viên có đúng một vai trò trong bốn vai trò và cụm rạp được gán phù hợp vai trò (BR-78, BR-79). |
| 5 | Hệ thống | Kiểm tra email chưa thuộc tài khoản nhân viên nào khác và lưu tài khoản nhân viên, tài khoản mới ở trạng thái đang hoạt động, tất cả là một thao tác không chia cắt (BR-95). |
| 6 | Hệ thống | Thông báo lưu tài khoản nhân viên thành công và hiển thị tài khoản đã lưu (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Quản trị viên chọn cập nhật cụm rạp hoặc vai trò của một tài khoản nhân viên đã có thay vì tạo tài khoản mới | - | Cập nhật tài khoản nhân viên | - |
| 1a1 | | Hệ thống | Hiển thị danh sách tài khoản nhân viên (xem Dữ liệu ra 3). | |
| 1a2 | | Quản trị viên | Chọn tài khoản nhân viên cần cập nhật (xem Dữ liệu vào 2). | |
| 1a3 | | Hệ thống | Hiển thị thông tin hiện tại của tài khoản cùng các cụm rạp và vai trò để cập nhật (xem Dữ liệu ra 1, Dữ liệu ra 2). | Tiếp tục bước 3 |
| 1b | Quản trị viên chọn khoá tài khoản của một nhân viên nghỉ việc thay vì tạo tài khoản mới | - | Khoá tài khoản nhân viên | - |
| 1b1 | | Hệ thống | Hiển thị danh sách tài khoản nhân viên (xem Dữ liệu ra 3). | |
| 1b2 | | Quản trị viên | Chọn tài khoản nhân viên cần khoá (xem Dữ liệu vào 2). | |
| 1b3 | | Hệ thống | Kiểm tra tài khoản đã chọn đang hoạt động rồi đặt tài khoản ở trạng thái bị khoá, không xoá tài khoản và giữ nguyên dữ liệu liên quan tới nhân viên, tất cả là một thao tác không chia cắt (BR-96, BR-97; xử lý lần giữ ghế đang chạy và phiên đang mở: Q-164, Q-165). | |
| 1b3a | Tài khoản đã chọn đã ở trạng thái bị khoá | Hệ thống | Thông báo tài khoản đã bị khoá. | Kết thúc use case (thất bại) |
| 1b4 | | Hệ thống | Thông báo khoá tài khoản thành công. | Kết thúc use case (thành công) |
| 4a | Nhân viên không có đúng một vai trò trong bốn vai trò (BR-79) | Hệ thống | Từ chối lưu tài khoản và thông báo quy tắc bị vi phạm (BR-79). | Quay lại bước 3 |
| 4b | Nhân viên có đúng một vai trò và cụm rạp được gán không phù hợp vai trò: vai trò nhân viên quầy, nhân viên soát vé hoặc quản lý cụm rạp mà không gán đúng một cụm rạp, hoặc vai trò quản lý chuỗi mà có gán cụm rạp (BR-78) | Hệ thống | Từ chối lưu tài khoản và thông báo quy tắc bị vi phạm (BR-78). | Quay lại bước 3 |
| 5a | Email đã thuộc một tài khoản nhân viên khác, kể cả khi tài khoản đó vừa được lưu cùng lúc bởi một yêu cầu khác (BR-95) | Hệ thống | Từ chối lưu tài khoản và thông báo quy tắc bị vi phạm (BR-95). | Quay lại bước 3 |
| *a | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a và 1b trước bước 1b3, quản trị viên huỷ yêu cầu | Hệ thống | Huỷ yêu cầu, không thay đổi tài khoản nhân viên nào. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

Khi cập nhật (luồng 1a), quản trị viên chỉ đổi vai trò và cụm rạp (trường 4, 5); các trường 1, 2, 3 không nhập lại.

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Email | Địa chỉ email để nhân viên đăng nhập (REQ-102; Q-136) | Có khi tạo tài khoản mới | Duy nhất giữa mọi tài khoản nhân viên (BR-95); định dạng: Chưa quy định (Q-163) | quan.tran@cinebook.example |
| 2 | Họ tên | Họ tên của nhân viên (Q-136) | Chưa quy định (Q-163) | Chưa quy định (Q-163) | Trần Văn Quân |
| 3 | Mật khẩu ban đầu | Mật khẩu để nhân viên đăng nhập lần đầu (REQ-102) | Chưa quy định (Q-161) | Chưa quy định (Q-161) | - |
| 4 | Vai trò | Vai trò của nhân viên: nhân viên quầy, nhân viên soát vé, quản lý cụm rạp hoặc quản lý chuỗi (REQ-72) | Có | Đúng một trong bốn vai trò (BR-79) | Nhân viên soát vé |
| 5 | Cụm rạp | Cụm rạp mà nhân viên thuộc về (REQ-71) | Có khi vai trò là nhân viên quầy, nhân viên soát vé hoặc quản lý cụm rạp; Không khi vai trò là quản lý chuỗi | Đúng một cụm rạp trong Dữ liệu ra 1 khi bắt buộc; không có cụm rạp khi vai trò là quản lý chuỗi (BR-78) | CineBook Cầu Giấy |

Dữ liệu vào 2 (bước 1a2, 1b2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Tài khoản nhân viên được chọn | Tài khoản nhân viên cần cập nhật hoặc cần khoá (REQ-70) | Có | Một tài khoản trong Dữ liệu ra 3 | quan.tran@cinebook.example |

Dữ liệu ra 1 (bước 2, 1a3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Cụm rạp của chuỗi | Các cụm rạp để gán nhân viên (REQ-71, REQ-54) | Tên cụm rạp, văn bản | CineBook Cầu Giấy |
| 2 | Vai trò nhân viên | Bốn vai trò để phân quyền (REQ-72) | Văn bản | Quản lý chuỗi |

Dữ liệu ra 2 (bước 6, 1a3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Email | Email đăng nhập của nhân viên | Văn bản | quan.tran@cinebook.example |
| 2 | Họ tên | Họ tên của nhân viên | Văn bản | Trần Văn Quân |
| 3 | Vai trò | Vai trò của nhân viên (REQ-101) | Văn bản | Nhân viên soát vé |
| 4 | Cụm rạp | Cụm rạp của nhân viên; quản lý chuỗi không có cụm rạp (REQ-100) | Tên cụm rạp, hoặc "Không có" | CineBook Cầu Giấy |
| 5 | Trạng thái tài khoản | Đang hoạt động hoặc bị khoá (Q-136) | Văn bản | Đang hoạt động |

Dữ liệu ra 3 (bước 1a1, 1b1)

Mỗi dòng là một tài khoản nhân viên; danh sách không gồm tài khoản quản trị viên (REQ-72, REQ-103).

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Email | Email đăng nhập của nhân viên | Văn bản | quan.tran@cinebook.example |
| 2 | Họ tên | Họ tên của nhân viên | Văn bản | Trần Văn Quân |
| 3 | Vai trò | Vai trò của nhân viên | Văn bản | Nhân viên soát vé |
| 4 | Cụm rạp | Cụm rạp của nhân viên, hoặc "Không có" với quản lý chuỗi | Tên cụm rạp | CineBook Cầu Giấy |
| 5 | Trạng thái tài khoản | Đang hoạt động hoặc bị khoá | Văn bản | Đang hoạt động |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-78 | Mỗi nhân viên quầy, nhân viên soát vé và quản lý cụm rạp thuộc đúng một cụm rạp; quản lý chuỗi không thuộc cụm rạp nào. | Sự kiện | 4, 4b, Dữ liệu vào 1 trường 5 | REQ-100; REQ-71 (phụ) | Đã có |
| BR-79 | Mỗi nhân viên có đúng một vai trò. | Sự kiện | 4, 4a, Dữ liệu vào 1 trường 4 | REQ-101; REQ-72 (phụ) | Đã có |
| BR-95 | Email của mỗi tài khoản nhân viên là duy nhất giữa mọi tài khoản nhân viên. | Ràng buộc | 5, 5a, Dữ liệu vào 1 trường 1 | REQ-102 (phụ); Q-136 | Mới |
| BR-96 | Khi nhân viên nghỉ việc, tài khoản nhân viên bị khoá chứ không bị xoá; dữ liệu liên quan tới nhân viên (lần giữ ghế, vé đã bán) được giữ nguyên. | Kích hoạt hành động | 1b3 | REQ-70 (phụ); Q-136 | Mới |
| BR-97 | Nhân viên có tài khoản bị khoá không đăng nhập được vào hệ thống. | Ràng buộc | 1b3, Hậu điều kiện | REQ-102 (phụ); Q-136 | Mới |

BR-78, BR-79 cấp ở P06 cho REQ-100, REQ-101 và gắn UC-017 theo P02 Mục 5. BR-02, BR-17, BR-22, BR-46, BR-61 dùng REQ-100 làm căn cứ phụ cho phạm vi cụm rạp của từng use case nên không trùng nghĩa với BR-78. BR-81 chỉ áp dụng cho tài khoản khách nên không dùng cho email nhân viên.

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-06 Quản trị viên, tác nhân chính duy nhất; use case không có tác nhân phụ. Luồng chính là tạo tài khoản vì REQ-102 nêu tài khoản do quản trị viên tạo và EV-19 mở đầu bằng nhân viên mới. Luồng 1a (nhân viên đổi cụm rạp, vai trò: EV-19, REQ-71, REQ-72) và luồng 1b (khoá tài khoản khi nhân viên nghỉ việc, trả lời Q-136) là hai thao tác khác của cùng mục tiêu "nhân viên có tài khoản đúng cụm rạp và đúng vai trò".
- Trả lời Q-136: tài khoản nhân viên gồm email duy nhất, mật khẩu, họ tên và trạng thái hoạt động; nhân viên nghỉ việc thì tài khoản bị khoá, không bị xoá, vì lần giữ ghế và vé cũ còn trỏ tới nhân viên. Do đó use case không có thao tác xoá tài khoản (BR-96).
- Tài khoản quản trị viên có sẵn khi cài đặt hệ thống, không do ai tạo qua hệ thống (REQ-103, trả lời Q-23), và quản trị viên không nằm trong bốn vai trò nhân viên (REQ-72, GL-34). Use case không tạo, sửa hay khoá tài khoản quản trị viên; danh sách ở Dữ liệu ra 3 không gồm tài khoản này.
- Luồng 1a chỉ đổi vai trò và cụm rạp, vì REQ-71, REQ-72 và EV-19 chỉ nêu hai thuộc tính này. Các thao tác khác trên tài khoản (mở khoá, sửa họ tên hoặc email, đặt lại mật khẩu) chưa được nguồn nêu nên chờ Q-162; use case chưa có luồng cho các thao tác đó. Khi đổi vai trò sang quản lý chuỗi thì bỏ cụm rạp, khi đổi từ quản lý chuỗi sang vai trò khác thì phải gán cụm rạp (BR-78, luồng 4b). Ở luồng 1a, email của chính tài khoản đang cập nhật không được coi là trùng ở bước 5.
- Bước 4 gộp hai điều kiện về cùng một đối tượng tại cùng thời điểm (F4.2 mục 11). Điều kiện luồng 4b chỉ xét khi nhân viên đã có đúng một vai trò, nên 4a và 4b loại trừ lẫn nhau. Luồng 4a, 4b, 5a theo F5.7: nguồn nêu quy tắc (REQ-100, REQ-101, Q-136) nhưng không nêu phản hồi khi vi phạm, nên hệ thống từ chối và thông báo quy tắc bị vi phạm; quay lại bước 3 vì quản trị viên sửa được dữ liệu.
- Bước 5 gộp việc kiểm tra email chưa trùng và việc lưu thành một thao tác không chia cắt. Lý do: BR-95 đòi hai yêu cầu cùng email thì chỉ một yêu cầu được lưu; nếu kiểm tra và lưu là hai thao tác tách rời thì cả hai cùng thấy email chưa trùng rồi cùng lưu. Cơ chế bảo đảm điều này thuộc bước thiết kế (P07, P09).
- BR-95 chỉ xét tài khoản nhân viên. Nguồn không nêu việc một email vừa là tài khoản khách vừa là tài khoản nhân viên; việc đăng nhập không là use case nên cách phân biệt hai loại tài khoản khi đăng nhập thuộc bước thiết kế.
- Hệ quả của việc khoá, đổi cụm rạp hoặc đổi vai trò (thao tác dở dang khi đưa đối tượng sang trạng thái cuối): nhân viên quầy có thể đang có lần giữ ghế chưa kết thúc ở UC-005 (BR-04, REQ-89, REQ-92) và nhân viên có thể đang có phiên làm việc mở. Nguồn không nêu cách xử lý hai tình huống này nên use case chưa viết bước xử lý; chờ Q-164 (lần giữ ghế đang chạy) và Q-165 (phiên đang mở).
- Hai yêu cầu cùng lưu một tài khoản nhân viên (hai quản trị viên, hoặc cập nhật và khoá cùng lúc): nguồn không nêu; chờ Q-166. Tài khoản quản trị viên có sẵn (REQ-103) nên tình huống này ít xảy ra nhưng nguồn không cấm có nhiều tài khoản quản trị viên.
- Luồng *a suy ra từ việc quản trị viên bỏ yêu cầu trước khi hệ thống lưu; không có dữ liệu nào thay đổi.
- Không có use case do tác nhân thời gian kích hoạt dùng tài khoản nhân viên làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Các use case của ACT-02 đến ACT-05 dùng tài khoản do use case này tạo làm tiền điều kiện đăng nhập (REQ-102, NFR-02); phạm vi cụm rạp của từng use case lấy từ cụm rạp được gán ở đây (BR-78).

Thao tác nguyên tử:

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Kiểm tra email chưa trùng rồi lưu tài khoản nhân viên (tạo mới hoặc cập nhật) | 5 | Tài khoản nhân viên (email, vai trò, cụm rạp, trạng thái) | Email duy nhất giữa mọi tài khoản nhân viên (BR-95); mỗi nhân viên đúng một vai trò và cụm rạp theo vai trò (BR-78, BR-79); kiểm tra và lưu là một thao tác | Chính nó (hai yêu cầu cùng email, kể cả của hai quản trị viên); luồng 1b3 trên cùng tài khoản; UC-005 bước 7 và 9a1 (nhân viên quầy giữ ghế hoặc xác nhận thu tiền, theo BR-02, BR-04); UC-009 bước 1 và 4 (cụm rạp của nhân viên soát vé, theo BR-22, BR-34); UC-013, UC-014 (cụm rạp của quản lý cụm rạp, theo BR-61, BR-46) | Cùng email: bên ghi nhận sau bị từ chối ở luồng 5a. Cùng tài khoản: chờ Q-166. Với UC-005, UC-009, UC-013, UC-014: chờ Q-164, Q-165 | BR-78, BR-79, BR-95, REQ-102 |
| Kiểm tra tài khoản đang hoạt động rồi đặt khoá | 1b3 | Tài khoản nhân viên (trạng thái); lần giữ ghế chưa kết thúc của nhân viên quầy | Tài khoản bị khoá không đăng nhập được (BR-97); dữ liệu liên quan giữ nguyên (BR-96); kiểm tra trạng thái và đặt khoá là một thao tác | Chính nó (hai yêu cầu khoá cùng tài khoản); bước 5 trên cùng tài khoản; UC-005 bước 7 | Hai yêu cầu khoá: bên ghi nhận sau thấy tài khoản đã bị khoá ở luồng 1b3a. Với bước 5: chờ Q-166. Với UC-005: chờ Q-164 | BR-96, BR-97, Q-136 |

Trạng thái dở dang: use case không để tài khoản ở trạng thái dở dang vì mỗi thao tác lưu trọn vẹn hoặc không lưu. Lối ra cho lần giữ ghế và phiên đang mở của nhân viên bị khoá hoặc bị đổi cụm rạp, vai trò chưa được nguồn nêu, ghi ở Q-164, Q-165.

## 8a. Kịch bản chính

- KB1: Luồng chính --> tài khoản nhân viên mới được lưu đúng vai trò và cụm rạp, ở trạng thái đang hoạt động.
- KB2: Luồng chính + 4a hoặc 4b --> vai trò hoặc cụm rạp không hợp lệ bị từ chối, quản trị viên nhập lại từ bước 3.
- KB3: Luồng chính + 5a --> email đã thuộc tài khoản nhân viên khác bị từ chối, quản trị viên nhập lại từ bước 3.
- KB4: Luồng 1a --> quản trị viên đổi cụm rạp hoặc vai trò của tài khoản đã có, đi qua bước 3 đến bước 6.
- KB5: Luồng 1b --> tài khoản của nhân viên nghỉ việc bị khoá, không bị xoá.
- KB6: Luồng 1b + 1b3a --> tài khoản đã bị khoá từ trước, hệ thống thông báo và use case kết thúc.

## 9. Activity diagram

File: diagrams/P04-activity-UC-017.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 1a | D-1 |
| 1a1 | A-1a1 |
| 1a2 | A-1a2 |
| 1a3 | A-1a3 |
| 1b | D-1 |
| 1b1 | A-1b1 |
| 1b2 | A-1b2 |
| 1b3 | A-1b3, D-1b3 |
| 1b3a | D-1b3, A-1b3a |
| 1b4 | A-1b4 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4 | A-4, D-4 |
| 4a | D-4, A-4a |
| 4b | D-4, A-4b |
| 5 | A-5, D-5 |
| 5a | D-5, A-5a |
| 6 | A-6 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-06 | Partition | Quản trị viên | - | - | - | x=0, w=520 |
| P-SYS | Partition | Hệ thống | - | - | - | x=520, w=660 |
| INIT | Initial | - | - | P-ACT-06 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-06 | 1, 1a, 1b | x=130, y=130 (tương đối partition) |
| A-1 | Action | Yêu cầu tạo tài khoản nhân viên mới | - | P-ACT-06 | 1 | x=60, y=200 (tương đối partition) |
| A-2 | Action | Hiển thị cụm rạp và các vai trò | - | P-SYS | 2 | x=60, y=300 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-06 | 3 | x=130, y=410 (tương đối partition) |
| A-3 | Action | Nhập thông tin, chọn vai trò và cụm rạp | - | P-ACT-06 | 3 | x=60, y=480 (tương đối partition) |
| N-*a | Note | Luồng *a: tại bất kỳ bước nào trước bước 5, quản trị viên huỷ yêu cầu; hệ thống không thay đổi tài khoản nhân viên nào; kết thúc use case (thất bại) | - | P-ACT-06 | *a | x=280, y=470 (tương đối partition), w=220, h=120 |
| A-4 | Action | Kiểm tra vai trò và cụm rạp theo vai trò | - | P-SYS | 4 | x=60, y=580 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4, 4a, 4b | x=130, y=690 (tương đối partition) |
| A-4a | Action | Từ chối: không đúng một vai trò (BR-79) | - | P-SYS | 4a | x=340, y=680 (tương đối partition) |
| A-4b | Action | Từ chối: cụm rạp không phù hợp vai trò (BR-78) | - | P-SYS | 4b | x=340, y=780 (tương đối partition) |
| A-5 | Action | Kiểm tra email chưa trùng và lưu tài khoản | - | P-SYS | 5 | x=60, y=860 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5, 5a | x=130, y=970 (tương đối partition) |
| A-5a | Action | Từ chối: email đã thuộc tài khoản khác (BR-95) | - | P-SYS | 5a | x=340, y=960 (tương đối partition) |
| A-6 | Action | Thông báo lưu tài khoản thành công | - | P-SYS | 6 | x=60, y=1060 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 6 | x=130, y=1170 (tương đối partition) |
| A-1a1 | Action | Hiển thị danh sách tài khoản nhân viên | - | P-SYS | 1a1 | x=60, y=1250 (tương đối partition) |
| A-1a2 | Action | Chọn tài khoản cần cập nhật | - | P-ACT-06 | 1a2 | x=60, y=1350 (tương đối partition) |
| A-1a3 | Action | Hiển thị thông tin hiện tại của tài khoản | - | P-SYS | 1a3 | x=60, y=1450 (tương đối partition) |
| A-1b1 | Action | Hiển thị danh sách tài khoản nhân viên | - | P-SYS | 1b1 | x=60, y=1550 (tương đối partition) |
| A-1b2 | Action | Chọn tài khoản cần khoá | - | P-ACT-06 | 1b2 | x=60, y=1650 (tương đối partition) |
| A-1b3 | Action | Kiểm tra tài khoản đang hoạt động, đặt khoá | - | P-SYS | 1b3 | x=60, y=1750 (tương đối partition) |
| D-1b3 | Decision | - | - | P-SYS | 1b3, 1b3a | x=130, y=1860 (tương đối partition) |
| A-1b3a | Action | Thông báo tài khoản đã bị khoá | - | P-SYS | 1b3a | x=340, y=1850 (tương đối partition) |
| FINAL-3 | ActivityFinal | - | - | P-SYS | 1b3a | x=410, y=1960 (tương đối partition) |
| A-1b4 | Action | Thông báo khoá tài khoản thành công | - | P-SYS | 1b4 | x=60, y=1950 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | 1b4 | x=130, y=2060 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [tạo tài khoản mới] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [cập nhật tài khoản đã có] | - | (40,150); (40,1280) |
| E-04 | D-1 | A-1b1 | ControlFlow | [khoá tài khoản] | - | (20,150); (20,1580) |
| E-05 | A-1 | A-2 | ControlFlow | - | - | (150,330) |
| E-06 | A-2 | M-3 | ControlFlow | - | - | (670,430) |
| E-07 | M-3 | A-3 | ControlFlow | - | - | - |
| E-08 | A-3 | A-4 | ControlFlow | - | - | (150,610) |
| E-09 | A-4 | D-4 | ControlFlow | - | - | - |
| E-10 | D-4 | A-4a | ControlFlow | [không đúng một vai trò] | - | - |
| E-11 | D-4 | A-4b | ControlFlow | [cụm rạp không phù hợp vai trò] | - | (720,710); (720,810) |
| E-12 | D-4 | A-5 | ControlFlow | [vai trò và cụm rạp hợp lệ] | - | - |
| E-13 | A-4a | M-3 | ControlFlow | - | - | (1080,710); (1080,430) |
| E-14 | A-4b | M-3 | ControlFlow | - | - | (1100,810); (1100,430) |
| E-15 | A-5 | D-5 | ControlFlow | - | - | - |
| E-16 | D-5 | A-5a | ControlFlow | [email đã thuộc tài khoản khác] | - | - |
| E-17 | D-5 | A-6 | ControlFlow | [email chưa trùng] | - | - |
| E-18 | A-5a | M-3 | ControlFlow | - | - | (1120,990); (1120,430) |
| E-19 | A-6 | FINAL-1 | ControlFlow | - | - | - |
| E-20 | A-1a1 | A-1a2 | ControlFlow | - | - | (670,1380) |
| E-21 | A-1a2 | A-1a3 | ControlFlow | - | - | (150,1480) |
| E-22 | A-1a3 | M-3 | ControlFlow | - | - | (1140,1480); (1140,430) |
| E-23 | A-1b1 | A-1b2 | ControlFlow | - | - | (670,1680) |
| E-24 | A-1b2 | A-1b3 | ControlFlow | - | - | (150,1780) |
| E-25 | A-1b3 | D-1b3 | ControlFlow | - | - | - |
| E-26 | D-1b3 | A-1b3a | ControlFlow | [tài khoản đã bị khoá] | - | - |
| E-27 | D-1b3 | A-1b4 | ControlFlow | [tài khoản đang hoạt động] | - | - |
| E-28 | A-1b3a | FINAL-3 | ControlFlow | - | - | - |
| E-29 | A-1b4 | FINAL-2 | ControlFlow | - | - | - |

Partition P-ACT-06 là partition của ACT-06 Quản trị viên, rộng 520 vì luồng 1a, 1b có action của quản trị viên đặt lệch sang phải trục chính. D-1 đặt trong partition của quản trị viên ngay sau INIT vì quản trị viên chọn tạo, cập nhật hay khoá thay cho bước 1 (F5.2). Các luồng 4a, 4b, 5a và 1a3 quay lại merge node M-3 đặt ngay trước A-3. Luồng 1a và 1b nằm bên dưới luồng chính; E-03 và E-04 đi dọc mép trái của partition quản trị viên để không cắt qua action nào. Luồng *a chỉ thể hiện bằng note N-*a, không có cạnh.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-161 | Mật khẩu ban đầu của tài khoản nhân viên do ai đặt và nhân viên nhận bằng cách nào? | Bước 3, 5; Dữ liệu vào 1 trường 3; tác nhân phụ ACT-08 ở P02, P03 nếu gửi qua email | Mục 18 nêu nhân viên đăng nhập bằng tài khoản do quản trị viên tạo nhưng không nêu mật khẩu; Q-136 chỉ chốt tài khoản có mật khẩu | Bên nghiệp vụ | Quản trị viên nhập mật khẩu ban đầu ở bước 3 và giao cho nhân viên ngoài hệ thống; hệ thống không gửi email |
| Q-162 | Ngoài tạo tài khoản, cập nhật cụm rạp và vai trò, khoá tài khoản, quản trị viên còn thao tác nào trên tài khoản nhân viên (mở khoá, sửa email hoặc họ tên, đặt lại mật khẩu)? | Luồng thay thế mới; Dữ liệu vào; BR mới | Mục 18 chỉ nêu "quản lý tài khoản nhân viên" (REQ-70 chưa tách thao tác); Q-136 chỉ nêu khoá khi nghỉ việc | Bên nghiệp vụ | Thêm mở khoá, sửa họ tên và đặt lại mật khẩu (quản trị viên nhập mật khẩu mới); không sửa email; không xoá tài khoản |
| Q-163 | Email và họ tên của tài khoản nhân viên có điều kiện hợp lệ nào (định dạng email, họ tên có bắt buộc không)? | Dữ liệu vào 1 trường 1, 2; luồng thay thế mới tại bước 4 | Mục 18 và Q-136 không nêu điều kiện của hai trường; BR-81 chỉ nêu định dạng email của tài khoản khách | Nhóm dự án | Email theo định dạng email chuẩn như BR-81; họ tên bắt buộc và không rỗng |
| Q-164 | Khi khoá tài khoản, đổi cụm rạp hoặc đổi vai trò của nhân viên quầy đang có lần giữ ghế chưa kết thúc ở UC-005, lần giữ ghế đó được xử lý thế nào? | Luồng 1b3, bước 5; UC-005 (BR-02, BR-04); BR mới | Mục 5 và Mục 12 nêu lần giữ ghế của nhân viên quầy nhưng không nêu trường hợp tài khoản đổi trong lúc đó; Mục 18 không nêu | Bên nghiệp vụ | Lần giữ ghế giữ nguyên và kết thúc theo UC-005 (hết hạn sau 10 phút hoặc xác nhận thu tiền); khoá hoặc đổi chỉ chặn các lần giữ ghế bắt đầu sau đó |
| Q-165 | Khi khoá tài khoản, đổi cụm rạp hoặc đổi vai trò của nhân viên đang đăng nhập, phiên làm việc đang mở tiếp tục tới khi nhân viên đăng xuất hay bị kết thúc ngay? | Luồng 1b3, bước 5; BR mới | Mục 18 không nêu hiệu lực của thay đổi tài khoản với phiên đang mở | Bên nghiệp vụ | Có hiệu lực ngay: thao tác kế tiếp của nhân viên trong phiên cũ bị từ chối và nhân viên phải đăng nhập lại |
| Q-166 | Hai yêu cầu cùng lưu một tài khoản nhân viên (cập nhật hoặc khoá) thì xử lý thế nào? | Bước 5, 1b3; BR mới; bảng Thao tác nguyên tử | Mục 15 và Mục 16 nêu người lưu sau bị từ chối cho bảng giá và suất chiếu nhưng Mục 18 không nêu cho tài khoản nhân viên | Bên nghiệp vụ | Người lưu sau bị từ chối, không ghi đè, và phải mở lại tài khoản từ đầu (như trả lời Q-64) |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P13 | TBL-08, TBL-11, TBL-12 (cột email) | BR-95 đòi email duy nhất giữa mọi tài khoản nhân viên, còn P13 chỉ đặt duy nhất trong từng bảng nên một email dùng được ở hai bảng nhân viên khác nhau | Thêm ràng buộc duy nhất xuyên ba bảng nhân viên (hoặc bảng định danh đăng nhập chung) khi X3 áp BR-95 |
| P08, P13 | Thực thể quản lý chuỗi (chưa có) | Quản lý chuỗi (ACT-05, GL-41) không thuộc cụm rạp (BR-78) nhưng P13 chưa có bảng cho vai trò này, và luồng 1a đổi vai trò cần chuyển tài khoản giữa các bảng vai trò | Thêm thực thể và bảng cho quản lý chuỗi; chốt cách đổi vai trò khi chạy P07 cho UC-017 |
| P05 | GL-34, GL-43 (cột Ghi chú) | Ghi chú còn nêu UC-017 "chưa có đặc tả P04" | Bỏ cụm này khi chạy lại P05 |
| P06 | Mục truy vết UC-017 (cột BR) | Cột BR của UC-017 chỉ có BR-78, BR-79 | Thêm BR-95, BR-96, BR-97 cho UC-017 khi X3 gộp sổ BR |

## Vấn đề còn mở

- Q-161 đến Q-166 chưa được trả lời; use case không viết bước, luồng hay quy tắc dựa trên các đề xuất. Dữ liệu vào 1 trường 2, 3 ghi "Chưa quy định" theo NGHIEM_NGAT.
- BR-95, BR-96, BR-97 dựa trên trả lời Q-136 (nhóm dự án chốt theo review P13), không có câu trích trực tiếp trong tài liệu nguồn; nếu bên nghiệp vụ phản đối thì các BR này và luồng 1b cần xem lại.
- Luồng chính có 6 bước, nằm trong khoảng 3-15.
- Dải mã được cấp cho lô là Q-155 đến 174 và BR-94 đến 113; use case này dùng Q-161 đến Q-166 và BR-95 đến BR-97.
- Trên activity diagram, các cạnh E-06, E-13, E-14, E-18, E-22 hợp ở đoạn ngang trước M-3; không cạnh nào cắt qua node.
