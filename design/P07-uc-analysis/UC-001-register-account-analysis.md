# P07 - Phân tích use case UC-001 Đăng ký tài khoản - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-001-register-account.md 1.1; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P07-uc-analysis/UC-005-book-tickets-analysis.md (sổ đăng ký AC: F1, F3.4, F8 b, Câu hỏi mở, Vấn đề còn mở; đầu lô) và UC-006, UC-008, UC-009, UC-013, UC-014 (F3.4); _sync-log.md (mục Đầu vào cho lần chạy lại P07-P13, dòng UC-001, UC-007); dải mã được cấp Q-225 đến Q-234 |
| Phạm vi | UC-001 |
| Mã Q, ASM cuối đã cấp | Q-225 (trong dải Q-225 đến Q-234); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-001 Đăng ký tài khoản (Register Account) |
| Tác nhân chính | ACT-01 Khách (Người) |
| Tác nhân phụ | Không có. Dịch vụ email (ACT-08) không tham gia vì tài khoản dùng được ngay, không xác minh email hay số điện thoại (Q-157) |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 Đặt vé: khách phải đăng nhập bằng tài khoản do use case này tạo mới đặt vé (REQ-13), dùng AC-E-Customer.authenticateCustomer. UC-007 Xem lịch sử đặt vé, UC-006, UC-008 dùng cùng AC-E-Customer. UC-017 có bài toán tương tự cho tài khoản nhân viên (BR-95) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên tài khoản khách (P04 Mục 8), nên không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md (AC-E-Customer, owner UC-001, đã cấp ở đó). Các file UC-006, UC-008, UC-009, UC-013, UC-014 dùng để tra tên lớp, trách nhiệm |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Khách | Yêu cầu đăng ký tài khoản | Không đổi | EV-01 |
| 2 | Hệ thống | Yêu cầu khách cung cấp email, số điện thoại và mật khẩu | Control nhận yêu cầu rồi báo boundary yêu cầu khách cung cấp ba thông tin. Chưa ghi nhận gì. | REQ-11 |
| 3 | Khách | Cung cấp email, số điện thoại và mật khẩu rồi gửi | Không đổi | REQ-11, Dữ liệu vào 1 |
| 4 | Hệ thống | Kiểm tra email theo định dạng email chuẩn (BR-81) | Control tạo tài khoản khách dự kiến, chưa ghi nhận, từ ba thông tin khách gửi. Tài khoản dự kiến kiểm tra email theo định dạng email chuẩn, email để trống tính là sai. | BR-81, GL-18 |
| 5 | Hệ thống | Kiểm tra số điện thoại là số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0 (BR-82) | Chỉ khi email đúng, tài khoản dự kiến kiểm tra số điện thoại gồm 10 chữ số và bắt đầu bằng chữ số 0, để trống tính là sai. | BR-82 |
| 6 | Hệ thống | Kiểm tra mật khẩu có ít nhất 8 ký tự (BR-99, Q-156) | Chỉ khi email và số điện thoại đúng, tài khoản dự kiến kiểm tra mật khẩu có ít nhất 8 ký tự, để trống tính là sai. Ba kiểm tra ở bước 4, 5, 6 là một trách nhiệm của tài khoản dự kiến, dừng ở điều kiện đầu tiên vi phạm. | BR-99 |
| 7 | Hệ thống | Kiểm tra email và số điện thoại chưa thuộc tài khoản khách nào khác (BR-98, Q-155) rồi tạo tài khoản khách, tất cả là một thao tác không chia cắt; tài khoản dùng được ngay, không xác minh (Q-157) | Tài khoản dự kiến so email và số điện thoại với mọi tài khoản khách đã có, kể cả tài khoản vừa được tạo cùng lúc bởi yêu cầu khác, rồi ghi nhận chính nó trong cùng thao tác. Tài khoản ghi nhận ở trạng thái dùng được ngay, không có phiên đăng nhập kèm theo. | BR-98, Q-155, Q-157 |
| 8 | Hệ thống | Thông báo đăng ký thành công cho khách; khách không được tự đăng nhập và phải đăng nhập riêng (Q-158) | Control báo boundary thông báo đăng ký thành công. Không tạo phiên làm việc. | Q-158 |
| 4a | Hệ thống | Từ chối đăng ký và thông báo quy tắc bị vi phạm (BR-81); quay lại bước 3 | Kết quả kiểm tra là email sai thì control báo boundary từ chối kèm quy tắc BR-81. Tài khoản dự kiến bị bỏ, không ghi gì. | BR-81 |
| 5a | Hệ thống | Từ chối đăng ký và thông báo quy tắc bị vi phạm (BR-82); quay lại bước 3 | Kết quả là email đúng, số điện thoại sai thì control báo boundary từ chối kèm quy tắc BR-82. Tài khoản dự kiến bị bỏ. | BR-82 |
| 6a | Hệ thống | Từ chối đăng ký và thông báo quy tắc bị vi phạm (BR-99); quay lại bước 3 | Kết quả là email và số điện thoại đúng, mật khẩu ngắn thì control báo boundary từ chối kèm quy tắc BR-99. Tài khoản dự kiến bị bỏ. | BR-99 |
| 7a | Hệ thống | Từ chối đăng ký, không tạo tài khoản và thông báo quy tắc bị vi phạm (BR-98); quay lại bước 3 | Kết quả ghi nhận là email hoặc số điện thoại đã thuộc tài khoản khác thì không tạo tài khoản; control báo boundary từ chối kèm quy tắc BR-98. | BR-98 |
| *a | Hệ thống | Huỷ yêu cầu đăng ký, không tạo tài khoản; kết thúc use case (thất bại) | Control bỏ tài khoản dự kiến nếu đã tạo rồi báo boundary yêu cầu đã huỷ. Chưa có dữ liệu nào được ghi nên không có message hoàn tác. | Mục 8 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-01 Khách | Người | RegisterAccountForm | Giao diện người dùng | Mới (AC-B-RegisterAccountForm) | Khách yêu cầu đăng ký, nhập ba thông tin và nhận kết quả; boundary giao diện người dùng đặt tên theo tương tác của use case, không dùng chung với use case khác. |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | khách | 1, 3, 8; Mô tả ngắn | Loại - là tác nhân hoặc ngoài phạm vi | ACT-01; thông tin về khách do entity Customer giữ (dòng 2). |
| 2 | tài khoản, tài khoản khách | 4, 7, 7a; BR-98 | Entity AC-E-Customer | Hồ sơ tài khoản của tác nhân Khách, không phải bản thân tác nhân; hệ thống lưu vượt một lần thực hiện và có hành vi kiểm tra dữ liệu đăng ký, ghi nhận (GL-18). Dùng lại mã đã cấp ở UC-005. |
| 3 | email | 3, 4, 7; BR-81, BR-98; Dữ liệu vào 1 | Loại - thuộc tính của Customer | Định danh đăng nhập, không có hành vi riêng (GL-18). |
| 4 | số điện thoại | 3, 5, 7; BR-82, BR-98 | Loại - thuộc tính của Customer | Như email. |
| 5 | mật khẩu | 3, 6; BR-99 | Loại - thuộc tính của Customer | Không có hành vi riêng ở mức phân tích. |
| 6 | định dạng email chuẩn, 10 chữ số, chữ số 0, 8 ký tự | 4, 5, 6; BR-81, BR-82, BR-99 | Loại - tham số của quy tắc BR-81, BR-82, BR-99 | Ngưỡng và định dạng nằm trong quy tắc. |
| 7 | yêu cầu đăng ký, yêu cầu đăng ký khác | 1, 7a, *a | Loại - thao tác hoặc sự kiện | EV-01; yêu cầu khác là sự kiện cạnh tranh của cùng use case, không là khái niệm lưu. |
| 8 | thông báo đăng ký thành công, quy tắc bị vi phạm | 4a, 5a, 6a, 7a, 8 | Loại - dữ liệu trao đổi qua boundary RegisterAccountForm | Hiển thị cho khách, không lưu. |
| 9 | thông tin đăng ký, dữ liệu | 2, 3; Dữ liệu vào 1 | Loại - mơ hồ | Tập hợp của email, số điện thoại, mật khẩu đã xét ở dòng 3 đến 5. |
| 10 | phiên làm việc, đăng nhập | Hậu điều kiện; Q-158 | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4); use case không tạo phiên (Q-158). |
| 11 | xác minh email, xác minh số điện thoại | Hậu điều kiện; Q-157 | Loại - không tham gia hành vi của use case này | Không có xác minh (Q-157). |
| 12 | dịch vụ email | Mục 8; Q-157 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-08 không tham gia use case này. |
| 13 | họ tên, thông tin thẻ thanh toán | Mục 8; REQ-77 | Loại - không tham gia hành vi của use case này | Use case không thu thập họ tên và thông tin thanh toán. |
| 14 | vé, lần đặt | Tiền đề (REQ-13) | Loại - không tham gia hành vi của use case này | Khái niệm của UC-005; tài khoản chỉ là tiền điều kiện đặt vé. |
| 15 | hệ thống, thao tác | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| RegisterAccountController | UC-001 | Mới (AC-C-RegisterAccountController) | Một control cho use case: nhận sự kiện từ boundary, tạo tài khoản khách dự kiến, điều phối kiểm tra rồi ghi nhận hoặc từ chối. Mọi quy tắc BR-81, BR-82, BR-99, BR-98 nằm ở entity Customer. Có 3 trách nhiệm. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-RegisterAccountForm | boundary | RegisterAccountForm | // requestRegistration: khách yêu cầu đăng ký tài khoản<br>// showRegistrationRequest: yêu cầu khách cung cấp email, số điện thoại, mật khẩu<br>// submitRegistrationData: khách cung cấp email, số điện thoại, mật khẩu rồi gửi<br>// rejectRegistration: thông báo từ chối đăng ký kèm quy tắc bị vi phạm<br>// showRegistrationSuccess: thông báo đăng ký thành công, khách đăng nhập riêng<br>// cancelRegistration: khách huỷ yêu cầu đăng ký<br>// showRegistrationCancelled: thông báo yêu cầu đã huỷ | registrationData (Email, số điện thoại, mật khẩu) | 1, 2, 3, 8, 4a, 5a, 6a, 7a, *a | Giao diện người dùng | Mới | GL-18 |
| AC-C-RegisterAccountController | control | RegisterAccountController | // startRegistration: điều phối bước 2: tiếp nhận yêu cầu đăng ký rồi yêu cầu khách cung cấp thông tin<br>// registerAccount: điều phối bước 4 đến 8: tạo tài khoản khách dự kiến, kiểm tra dữ liệu, ghi nhận, báo thành công hoặc từ chối<br>// cancelRegistration: điều phối luồng *a: bỏ tài khoản dự kiến, báo yêu cầu đã huỷ | - | 2, 3 đến 8, 4a, 5a, 6a, 7a, *a | - | Mới | - |
| AC-E-Customer | entity | Customer | // draftCustomer: tạo tài khoản khách dự kiến, chưa ghi nhận, từ email, số điện thoại, mật khẩu khách gửi<br>// checkRegistrationData: kiểm tra theo thứ tự email theo định dạng email chuẩn (BR-81), số điện thoại 10 chữ số bắt đầu bằng 0 (BR-82), mật khẩu ít nhất 8 ký tự (BR-99); trả về hợp lệ hoặc điều kiện đầu tiên vi phạm<br>// saveCustomer: thao tác không chia cắt: kiểm tra email và số điện thoại chưa thuộc tài khoản khách nào khác (BR-98) rồi ghi nhận tài khoản dùng được ngay; trả về đã ghi nhận hoặc đã trùng | email (Văn bản), phoneNumber (Văn bản), password (Văn bản) | 4, 5, 6, 7, 4a, 5a, 6a, 7a | - | Tái dùng từ UC-005, UC-006, bổ sung trách nhiệm; chủ sở hữu UC-001 | GL-18 |

Tổng cộng 3 lớp: 1 boundary, 1 control, 1 entity. Entity cốt lõi của chủ đề race condition: AC-E-Customer (// saveCustomer, hai yêu cầu cùng email hoặc cùng số điện thoại).

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestRegistration | AC-B-RegisterAccountForm | Giao tiếp tác nhân | - |
| 2 | // startRegistration | AC-C-RegisterAccountController | Controller | - |
| 2 | // showRegistrationRequest | AC-B-RegisterAccountForm | Giao tiếp tác nhân | - |
| 3 | // submitRegistrationData | AC-B-RegisterAccountForm | Giao tiếp tác nhân | Boundary chỉ nhận ba thông tin; BR-81, BR-82, BR-99 là quy tắc nghiệp vụ nên không kiểm ở boundary (F3.4). |
| 3, 4 | // registerAccount | AC-C-RegisterAccountController | Controller | - |
| 4 | // draftCustomer | AC-E-Customer | Creator | Chưa có đối tượng toàn thể nắm các tài khoản khách (GL-18) để làm Creator. Control có dữ liệu khởi tạo nhưng không giữ dữ liệu nghiệp vụ, nên Customer tự tạo như Booking với // createBooking ở UC-005. |
| 4, 5, 6 | // checkRegistrationData | AC-E-Customer | Information Expert | Email, số điện thoại, mật khẩu là dữ liệu của Customer. Đặt ở control làm control giữ quy tắc thuộc dữ liệu entity (god control); đặt ở boundary làm boundary chứa quy tắc nghiệp vụ. Một trách nhiệm dừng ở điều kiện đầu tiên vi phạm để 4a, 5a, 6a loại trừ nhau theo thứ tự P04. |
| 7 | // saveCustomer | AC-E-Customer | Information Expert; thao tác không chia cắt | Dữ liệu cần so là email, số điện thoại của mọi tài khoản khách, không có đối tượng toàn thể nên giao cho Customer kiểm rồi ghi trong một thao tác, như // holdSeats của Showtime. Chia thành hai message (kiểm, rồi ghi) làm hai yêu cầu cùng email cùng thấy chưa trùng (Q-225). |
| 8 | // showRegistrationSuccess | AC-B-RegisterAccountForm | Giao tiếp tác nhân | - |
| 4a, 5a, 6a, 7a | // rejectRegistration | AC-B-RegisterAccountForm | Giao tiếp tác nhân | Một trách nhiệm cho bốn luồng, quy tắc truyền như dữ liệu. Quyết định rẽ nhánh dựa trên kết quả trả về của Customer, control không tự đánh giá quy tắc. |
| *a | // cancelRegistration | AC-B-RegisterAccountForm | Giao tiếp tác nhân | - |
| *a | // cancelRegistration | AC-C-RegisterAccountController | Controller | Không có dữ liệu đã ghi nên không message tới entity; tài khoản dự kiến chỉ tồn tại trong lần thực hiện. |
| *a | // showRegistrationCancelled | AC-B-RegisterAccountForm | Giao tiếp tác nhân | - |

Thao tác nguyên tử của P04 (00-Concurrency.md M3 mục 1):

| Thao tác (P04 Mục 8) | Bước | Lớp điều phối | Lớp tham gia | Điểm tuần tự |
|---|---|---|---|---|
| Kiểm tra email, số điện thoại chưa thuộc tài khoản khác rồi tạo tài khoản khách | 7 | AC-C-RegisterAccountController | AC-E-Customer (// saveCustomer) | Theo email và theo số điện thoại trên toàn bộ tài khoản khách (BR-98); chọn cơ chế ở P09, P12 |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-001.drawio, 2 trang. Số message không kể trả về: SD1 13, SD2 3. Luồng 4a, 5a, 6a, 7a quay lại bước 3 nên vẽ bằng alt trong SD1. Luồng *a vẽ ở trang riêng SD2 theo F5 c.

### SD1 - Luồng chính và luồng 4a, 5a, 6a, 7a

Luồng 4a, 5a, 6a, 7a đều quay lại bước 3 nên vẽ bằng alt; toán hạng luồng chính chỉ ghi guard và note tiếp tục. Tài khoản khách dự kiến được tạo ở message 2.1.1 (loại Tạo); các lần quay lại bước 3 tạo lại tài khoản dự kiến mới từ dữ liệu khách nhập lại.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1-L-KH | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD1-L-FM | Lifeline | :RegisterAccountForm | «boundary» | - | AC-B-RegisterAccountForm |
| SD1-L-CT | Lifeline | :RegisterAccountController | «control» | - | AC-C-RegisterAccountController |
| SD1-L-CU | Lifeline | :Customer | «entity» | - | AC-E-Customer; tạo bởi message loại Tạo |
| SD1-F1 | Fragment | alt [email không đúng định dạng email chuẩn, kể cả để trống (4a)] | - | - | mức ngoài cùng |
| SD1-F1-O2 | Fragment | [email đúng, số điện thoại không đúng định dạng số điện thoại Việt Nam, kể cả để trống (5a)] | - | SD1-F1 | toán hạng 2 |
| SD1-F1-O3 | Fragment | [email và số điện thoại đúng, mật khẩu ngắn hơn 8 ký tự, kể cả để trống (6a)] | - | SD1-F1 | toán hạng 3 |
| SD1-F1-O4 | Fragment | [dữ liệu đăng ký hợp lệ] | - | SD1-F1 | toán hạng 4 |
| SD1-F2 | Fragment | alt [email hoặc số điện thoại đã thuộc tài khoản khách khác, kể cả khi tài khoản đó vừa được tạo cùng lúc bởi yêu cầu khác (7a)] | - | - | mức ngoài cùng |
| SD1-F2-O2 | Fragment | [email và số điện thoại chưa thuộc tài khoản khách nào khác, tài khoản đã được ghi nhận] | - | SD1-F2 | toán hạng 2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Khách | :RegisterAccountForm | // requestRegistration | Đồng bộ | - | 1 |
| 1.1 | :RegisterAccountForm | :RegisterAccountController | // startRegistration | Đồng bộ | - | 2 |
| 1.1.1 | :RegisterAccountController | :RegisterAccountForm | // showRegistrationRequest (yêu cầu cung cấp email, số điện thoại, mật khẩu) | Đồng bộ | - | 2 |
| 2 | :Khách | :RegisterAccountForm | // submitRegistrationData (email, số điện thoại, mật khẩu) | Đồng bộ | - | 3 |
| 2.1 | :RegisterAccountForm | :RegisterAccountController | // registerAccount (email, số điện thoại, mật khẩu) | Đồng bộ | - | 3, 4 |
| 2.1.1 | :RegisterAccountController | :Customer | // draftCustomer (email, số điện thoại, mật khẩu) | Tạo | - | 4 |
| 2.1.2 | :RegisterAccountController | :Customer | // checkRegistrationData | Đồng bộ | - | 4, 5, 6 |
| 2.1.2 (trả về) | :Customer | :RegisterAccountController | hợp lệ, hoặc điều kiện đầu tiên bị vi phạm (BR-81, BR-82, BR-99) | Trả về | - | 4, 5, 6 |
| 2.1.3 | :RegisterAccountController | :RegisterAccountForm | // rejectRegistration (quy tắc BR-81) | Đồng bộ | SD1-F1 | 4a |
| 2.1.4 | :RegisterAccountController | :RegisterAccountForm | // rejectRegistration (quy tắc BR-82) | Đồng bộ | SD1-F1-O2 | 5a |
| 2.1.5 | :RegisterAccountController | :RegisterAccountForm | // rejectRegistration (quy tắc BR-99) | Đồng bộ | SD1-F1-O3 | 6a |
| 2.1.6 | :RegisterAccountController | :Customer | // saveCustomer | Đồng bộ | - | 7 |
| 2.1.6 (trả về) | :Customer | :RegisterAccountController | đã ghi nhận tài khoản, hoặc email hay số điện thoại đã thuộc tài khoản khách khác | Trả về | - | 7 |
| 2.1.7 | :RegisterAccountController | :RegisterAccountForm | // rejectRegistration (quy tắc BR-98) | Đồng bộ | SD1-F2 | 7a |
| 2.1.8 | :RegisterAccountController | :RegisterAccountForm | // showRegistrationSuccess | Đồng bộ | SD1-F2-O2 | 8 |

### SD2 - Luồng *a

Khách huỷ yêu cầu tại bất kỳ bước nào trước bước 7. Chưa có dữ liệu nào được ghi (tài khoản chỉ được ghi ở message 2.1.6) nên không có message hoàn tác; tài khoản dự kiến nếu đã tạo thì bị bỏ.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2-L-KH | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| SD2-L-FM | Lifeline | :RegisterAccountForm | «boundary» | - | AC-B-RegisterAccountForm |
| SD2-L-CT | Lifeline | :RegisterAccountController | «control» | - | AC-C-RegisterAccountController |
| SD2-F0 | Fragment | ref SD1 - Luồng chính và luồng 4a, 5a, 6a, 7a | - | - | ref tới trang trước, mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Khách | :RegisterAccountForm | // cancelRegistration | Đồng bộ | - | *a |
| 1*a.1 | :RegisterAccountForm | :RegisterAccountController | // cancelRegistration | Đồng bộ | - | *a |
| 1*a.1.1 | :RegisterAccountController | :RegisterAccountForm | // showRegistrationCancelled | Đồng bộ | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: khách chỉ gửi message tới RegisterAccountForm; boundary chỉ gửi tới control; control gửi tới boundary và Customer; Customer không gọi lớp nào khác (không có message tự gọi, không có link tự nối).

## 7. Communication diagram

File diagrams/P07-communication-UC-001.drawio, 1 trang CM1 gồm luồng chính và mọi luồng thay thế (MUC_CHI_TIET là DAY_DU), giữ STT của SD1, SD2.

### Trang CM1 - Luồng chính và các luồng thay thế (SD1, SD2)

Một trang cho mọi luồng (MUC_CHI_TIET là DAY_DU), giữ STT của SD1 và SD2. Message trả về không vẽ.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-KH | Actor | :Khách | - | - | Tác nhân (ACT-01) |
| CM1-O-FM | Object | :RegisterAccountForm | «boundary» | - | AC-B-RegisterAccountForm |
| CM1-O-CT | Object | :RegisterAccountController | «control» | - | AC-C-RegisterAccountController |
| CM1-O-CU | Object | :Customer | «entity» | - | AC-E-Customer |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-KH | CM1-O-FM | Link | 1: // requestRegistration (-->)<br>2: // submitRegistrationData (email, số điện thoại, mật khẩu) (-->)<br>1*a: // cancelRegistration (-->) | Nguồn-->Đích: 1, 2, 1*a |
| CM1-L2 | CM1-O-FM | CM1-O-CT | Link | 1.1: // startRegistration (-->)<br>1.1.1: // showRegistrationRequest (yêu cầu cung cấp email, số điện thoại, mật khẩu) (<--)<br>2.1: // registerAccount (email, số điện thoại, mật khẩu) (-->)<br>2.1.3: // rejectRegistration (quy tắc BR-81) (<--) [email không đúng định dạng email chuẩn, kể cả để trống (4a)]<br>2.1.4: // rejectRegistration (quy tắc BR-82) (<--) [email đúng, số điện thoại không đúng định dạng số điện thoại Việt Nam, kể cả để trống (5a)]<br>2.1.5: // rejectRegistration (quy tắc BR-99) (<--) [email và số điện thoại đúng, mật khẩu ngắn hơn 8 ký tự, kể cả để trống (6a)]<br>2.1.7: // rejectRegistration (quy tắc BR-98) (<--) [email hoặc số điện thoại đã thuộc tài khoản khách khác, kể cả khi tài khoản đó vừa được tạo cùng lúc bởi yêu cầu khác (7a)]<br>2.1.8: // showRegistrationSuccess (<--) [email và số điện thoại chưa thuộc tài khoản khách nào khác, tài khoản đã được ghi nhận]<br>1*a.1: // cancelRegistration (-->)<br>1*a.1.1: // showRegistrationCancelled (<--) | Nguồn-->Đích: 1.1, 2.1, 1*a.1; Đích-->Nguồn: 1.1.1, 2.1.3, 2.1.4, 2.1.5, 2.1.7, 2.1.8, 1*a.1.1 |
| CM1-L3 | CM1-O-CT | CM1-O-CU | Link | 2.1.1: «create» // draftCustomer (email, số điện thoại, mật khẩu) (-->)<br>2.1.2: // checkRegistrationData (-->)<br>2.1.6: // saveCustomer (-->) | Nguồn-->Đích: 2.1.1, 2.1.2, 2.1.6 |

## 8. VOPC

File diagrams/P07-class-UC-001.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-RegisterAccountForm | Class | RegisterAccountForm | «boundary» | - | registrationData (Email, số điện thoại, mật khẩu) | // requestRegistration<br>// showRegistrationRequest<br>// submitRegistrationData<br>// rejectRegistration<br>// showRegistrationSuccess<br>// cancelRegistration<br>// showRegistrationCancelled |
| AC-C-RegisterAccountController | Class | RegisterAccountController | «control» | - | - | // startRegistration<br>// registerAccount<br>// cancelRegistration |
| AC-E-Customer | Class | Customer | «entity» | - | email (Văn bản)<br>phoneNumber (Văn bản)<br>password (Văn bản) | // draftCustomer<br>// checkRegistrationData<br>// saveCustomer |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC001-01 | AC-B-RegisterAccountForm | AC-C-RegisterAccountController | Association | - | - | tạm thời; link F7: CM1-L2 |
| R-UC001-02 | AC-C-RegisterAccountController | AC-E-Customer | Association | - | - | tạm thời; link F7: CM1-L3 |

Link CM1-L1 là actor - boundary nên không vào VOPC.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1 | Khách, AC-B-RegisterAccountForm |
| 2 | 1.1, 1.1.1 | AC-B-RegisterAccountForm, AC-C-RegisterAccountController |
| 3 | 2, 2.1 | Khách, AC-B-RegisterAccountForm, AC-C-RegisterAccountController |
| 4 | 2.1, 2.1.1, 2.1.2, 2.1.2 (trả về) | AC-C-RegisterAccountController, AC-E-Customer |
| 5 | 2.1.2, 2.1.2 (trả về) | AC-E-Customer |
| 6 | 2.1.2, 2.1.2 (trả về) | AC-E-Customer |
| 7 | 2.1.6, 2.1.6 (trả về) | AC-C-RegisterAccountController, AC-E-Customer |
| 8 | 2.1.8 | AC-C-RegisterAccountController, AC-B-RegisterAccountForm |
| 4a | 2.1.3 | AC-C-RegisterAccountController, AC-B-RegisterAccountForm |
| 5a | 2.1.4 | AC-C-RegisterAccountController, AC-B-RegisterAccountForm |
| 6a | 2.1.5 | AC-C-RegisterAccountController, AC-B-RegisterAccountForm |
| 7a | 2.1.7 | AC-C-RegisterAccountController, AC-B-RegisterAccountForm |
| *a | 1*a, 1*a.1, 1*a.1.1 | Khách, AC-B-RegisterAccountForm, AC-C-RegisterAccountController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-001.drawio (2 trang), P07-communication-UC-001.drawio (1 trang), P07-class-UC-001.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-225 | Việc kiểm tra email và số điện thoại chưa thuộc tài khoản khách nào khác ở bước 7 (BR-98) cần dữ liệu của mọi tài khoản khách, trong khi không có đối tượng toàn thể nắm tập tài khoản khách. Giao thao tác này cho entity Customer (như Booking với mã đặt vé duy nhất, BR-80), hay thêm một lớp nắm tập tài khoản? | AC-E-Customer, // saveCustomer; SD1 message 2.1.6; UC-017 (BR-95, AC-E-Staff // saveStaff) | P04 Mục 8 nêu thao tác không chia cắt trên email và số điện thoại của các tài khoản khách, P05 không có thuật ngữ cho tập tài khoản | Nhóm dự án | Giữ trong Customer (// saveCustomer), không thêm lớp tập hợp ở mức phân tích; P08 xét đơn vị loại trừ theo email và theo số điện thoại, P12 chọn cơ chế |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-E-Customer (F2a, bảng lớp) | Customer đang ở trạng thái Tạm (chờ P07 của UC-001) và chỉ có trách nhiệm của UC-005, UC-006 | Thêm // draftCustomer, // checkRegistrationData, // saveCustomer của UC-001; đổi trạng thái chủ sở hữu thành UC-001 |
| P08 | F4a, F4b (đơn vị loại trừ) | Thao tác ghi nhận tài khoản khách (UC-001 bước 7) chưa có đơn vị loại trừ | Thêm đơn vị loại trừ chế độ Độc quyền trên email và số điện thoại của mọi tài khoản khách (BR-98), cặp loại trừ với chính nó; kết cục bên ghi nhận sau bị từ chối ở luồng 7a |

## Vấn đề còn mở

- Số lớp là 3, dưới ngưỡng 4. Use case chỉ tạo một entity và đặc tả không nêu entity nào khác: không thu thập họ tên, không xác minh (Q-157), không có phiên (Q-158). Không có entity bị bỏ sót.
- Thao tác không chia cắt // saveCustomer (M3 mục 1) có dòng ở F4. Bất biến BR-98 trải qua mọi tài khoản khách, trong khi tài khoản chưa tồn tại tại lúc kiểm: điểm tuần tự theo từng đối tượng Customer là chưa đủ (M3 mục 2), đơn vị loại trừ phải theo email và theo số điện thoại. P08 xử lý (xem Đề xuất sửa artifact trước và Q-225).
- Tài khoản khách dự kiến (// draftCustomer) chỉ tồn tại trong một lần thực hiện, chưa ghi nhận, nên không là trạng thái dở dang (P04 Mục 8). Nếu khách quay lại bước 3, tài khoản dự kiến mới được tạo từ dữ liệu nhập lại.
- Thứ tự kiểm tra email, số điện thoại, mật khẩu là một trách nhiệm của Customer và khớp thứ tự loại trừ nhau của luồng 4a, 5a, 6a (P04 Mục 8). Mật khẩu chỉ được ghi nhận như thuộc tính; cách bảo vệ mật khẩu thuộc thiết kế.
- BR-98 (khách) và BR-95 (nhân viên) độc lập: nguồn không nêu một email vừa là tài khoản khách vừa là tài khoản nhân viên (P04 UC-017 Mục 8). P08 và P12 quyết cách phân biệt khi đăng nhập.
- Customer chưa có quan hệ nào trong VOPC của use case này ngoài control; quan hệ với SeatHold đã có ở R-UC005-14 và không thuộc hành vi của UC-001.
