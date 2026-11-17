# P11b - SS-05 Security - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 2.1 |
| Thay đổi 2.1 | Ghi kiểu của accessChangedAt khi rỗng được (con trỏ time.Time ở Go) |
| Thay đổi 2.0 | Chạy lại theo P09 2.0 (F7.11) và P10 2.0: mã phiên mang loại chủ thể (SubjectKind) và, với nhân viên, mốc truy cập accessChangedAt; issueSession và SessionClaims đổi chữ ký; kiểm phiên theo mốc BR-101 do DC-AccessCheckService (PKG-19) làm, thêm trang hộp đen S05B3; hai điểm đăng nhập (Q-267) cùng gọi IF-07 qua DC-LoginService; hashPassword có chữ ký (UC-001, UC-017 đã có P07); Q-282 |
| Thay đổi 1.1 | Đồng bộ chữ ký với review P11 (Q-129, Q-131) |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M6); project-profile.md (mục 3, 4); P01-actors.md 1.2 (ACT-01 đến ACT-06); P04-uc-specs UC-001 1.2 (BR-98, BR-99), UC-005 1.15 (tiền điều kiện, bước 5, 5a2, 5a2a), UC-008 1.10, UC-009 1.7, UC-013 1.5, UC-014 1.7 (tiền điều kiện đã đăng nhập), UC-017 1.2 (BR-95, BR-97, BR-100, BR-101); P06-supplementary-spec.md 1.4 (NFR-01, NFR-02, NFR-03, NFR-10, NFR-12); P07-uc-analysis UC-001 1.1, UC-005 1.3 (checkCustomerLoggedIn, authenticateCustomer), UC-017 1.1; P08-analysis-model.md 2.0 (AC-E-Customer, AC-E-Staff); P09-architecture.md 2.0 (F4, F6, F7.2, F7.8, F7.11, Q-267, Q-270); P10-design-elements.md 2.0 (F2, F3, F4, F5, F3a EX-20 đến EX-22); design/_sync-log.md (đầu lô); TAI_LIEU_GIAO_TIEP: Không có |
| Phạm vi | SS-05 Security (IF-07) |
| Mã Q, ASM cuối đã cấp | Ghi ở file chung (Q-126 đến Q-132; Q-282, mã đầu của dải cấp cho lô) |

SS-05 là subsystem cắt ngang (A1): không message P07 nào của use case khác ngoài UC-005 gửi tới nó; chữ ký lấy từ P10 F2, cột UC ghi các use case có tiền điều kiện hoặc bước dựa vào nó. Đăng nhập không là use case (project-profile.md mục 4), nên việc đăng nhập chỉ xuất hiện như tiền điều kiện. Có hai điểm đăng nhập riêng, khách và nhân viên (Q-267); cả hai do DC-LoginService (PKG-19) điều phối và cùng gọi IF-07. Quyền hiện hành của nhân viên không nằm trong SS-05: token chỉ chứng thực danh tính và mang mốc truy cập đã đọc lúc đăng nhập, còn việc so mốc với dòng Staff do DC-AccessCheckService (PKG-19) làm (P09 F7.11, P10 F2).

## F1. Bối cảnh sử dụng

| UC | Control gọi (AC hoặc DC) | Message trong P07 (STT, tên) | Dữ liệu truyền | Luồng lỗi trong P04 |
|---|---|---|---|---|
| UC-005 Đặt vé (khách) | DC-AuthFilter (PKG-11) cho phiên; DC-LoginService (PKG-19, điểm đăng nhập khách) cho mật khẩu và cấp phiên | 2.1.1 // checkCustomerLoggedIn (bước 5); 2.1.1a.4 // authenticateCustomer (luồng 5a2, P07 gửi tới AC-E-Customer; P10 chuyển kiểm mật khẩu sang IF-07) | Mã phiên của yêu cầu; email hoặc số điện thoại và mật khẩu | Luồng 5a, 5a2, 5a2a (thông tin đăng nhập không đúng, một thông báo chung, Q-131) |
| Đăng nhập nhân viên (không là use case; tiền điều kiện của UC-005 nhân viên quầy, UC-008, UC-009 đến UC-017) | DC-LoginService (PKG-19, điểm đăng nhập nhân viên) | (không có message P07; P10 F3 cơ chế Bảo mật) | Email và mật khẩu; mã nhân viên, vai trò, cụm rạp và accessChangedAt đã đọc từ dòng Staff | BR-97 (tài khoản Bị khoá không đăng nhập được); không có luồng P04 cho đăng nhập nhân viên (Q-282) |
| UC-001 Đăng ký tài khoản, UC-017 Quản lý tài khoản nhân viên (tạo, đặt lại mật khẩu) | DC-RegisterAccountService, DC-ManageStaffAccountsService (PKG-19) | (không có message P07 tới SS-05; P10 F3a EX-20, EX-21 ghi băm mật khẩu qua IF-07 trước khi mở giao dịch) | Mật khẩu người dùng nhập | Mật khẩu ngắn hơn 8 ký tự của khách (BR-99) do DC-Customer kiểm, không thuộc IF-07 |
| UC-005 Đặt vé (nhân viên quầy), UC-008 Huỷ vé, UC-009 Soát vé, UC-010 đến UC-017 (tiền điều kiện đã đăng nhập) | DC-AuthFilter (PKG-11), rồi DC-AccessCheckService (PKG-19) với nhân viên | (tiền điều kiện) | Mã phiên; vai trò được phép của chức năng | Tiền điều kiện đã đăng nhập; phiên không còn hiệu lực theo BR-101 (UC-017); không có luồng P04 cho phiên hết hạn (Q-129) |

## F2. Interface

| IF | Tên | Vai trò (một câu) | Bên hiện thực (SS; DC khi là interface gọi ngược) | Client (DC, PKG) | Package chứa |
|---|---|---|---|---|---|
| IF-07 | IAuthenticator | Băm và kiểm mật khẩu, cấp và kiểm mã phiên tự kiểm chứng được mang loại chủ thể và mốc truy cập, kiểm vai trò được phép | SS-05 | DC-AuthFilter (PKG-11); DC-LoginService, DC-RegisterAccountService, DC-ManageStaffAccountsService (PKG-19) | PKG-26 |

IF-07 có 5 operation theo P10 F2, cả 5 có chữ ký. Giữ một interface vì hai nhóm client dùng chung tập kiểu (Role, SubjectKind, SessionClaims): nhóm kiểm phiên (verifySession, checkRole; client PKG-11) và nhóm đăng nhập, băm mật khẩu (hashPassword, verifyPassword, issueSession; client PKG-19) rời nhau về operation, nên nếu P12 muốn tách theo nguyên tắc phân tách interface thì cắt theo hai nhóm này và P10 cấp mã IF mới. IF-15 (đọc dòng Staff) và IF-28 không thuộc P11b vì là interface kho dữ liệu; DC-AccessCheckService dùng IF-15, không dùng IF-07.

## F3. Operation

| IF | Tên | Hệ thống/thiết bị | Operation | Tham số vào | Kết quả | Lỗi / ngoại lệ | UC | Tiền điều kiện | Hậu điều kiện | Đồng bộ | Idempotent | Timeout |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| IF-07 | IAuthenticator | Không có (nội bộ máy chủ) | hashPassword(plainPassword: String): String | plainPassword: String - mật khẩu người dùng nhập, không rỗng, không ghi log; độ dài tối thiểu do Application kiểm (BR-99), không kiểm ở đây | String: mã băm một chiều, kèm tham số và muối để verifyPassword đọc lại | InvalidAuthRequestError (Nghiệp vụ nội bộ: mật khẩu rỗng) | UC-001 (lưu tài khoản khách, EX-20); UC-017 (tạo tài khoản, đặt lại mật khẩu, EX-21, EX-22) | Application chưa mở giao dịch (băm chậm, không giữ khoá lúc băm, P10 F3a) | Không đổi dữ liệu; mỗi lần gọi cho mã băm khác nhau vì muối ngẫu nhiên | Đồng bộ | Không (gọi lại là băm lại, không có tác dụng phụ) | Không áp dụng: tính toán cục bộ (Thiết kế: cùng mức vài trăm mili giây của verifyPassword) |
| IF-07 | IAuthenticator | Không có | verifyPassword(plainPassword: String, storedHash: String): Boolean | plainPassword: String - mật khẩu khách nhập, không rỗng, không ghi log<br>storedHash: String - mã băm một chiều lưu cùng tài khoản | Boolean: đúng khi mật khẩu khớp mã băm | MalformedHashError (Kỹ thuật: dữ liệu lưu sai định dạng) | UC-005 (luồng 5a2, NFR-01, NFR-02, NFR-03); đăng nhập nhân viên (tiền điều kiện của UC-008, UC-009 đến UC-017) | DC-LoginService đã tìm tài khoản (khách theo email hoặc số điện thoại, nhân viên theo email) và có mã băm | Không đổi dữ liệu | Đồng bộ | Có | Không áp dụng: tính toán cục bộ (Thiết kế: chi phí băm chọn khi viết mã cho vài trăm mili giây mỗi lần kiểm; thuật toán không thiết kế ở đây vì NFR không yêu cầu) |
| IF-07 | IAuthenticator | Không có | issueSession(subjectId: String, subjectKind: SubjectKind, role: Role, cinemaId: String, accessChangedAt: DateTime): IssuedSession | subjectId: String - mã khách hoặc mã nhân viên, không rỗng; hai tập mã độc lập nên luôn đi cùng subjectKind<br>subjectKind: SubjectKind - Customer (điểm đăng nhập khách) hoặc Staff (điểm đăng nhập nhân viên, gồm quản trị viên)<br>role: Role - phải khớp subjectKind: Customer chỉ với Customer; Staff với BoxOfficeClerk, TicketChecker, CinemaManager, ChainManager, Administrator<br>cinemaId: String - mã cụm rạp, rỗng với khách, quản lý chuỗi, quản trị viên (nhân viên thuộc đúng một cụm rạp, REQ-100)<br>accessChangedAt: DateTime - mốc access_changed_at của dòng Staff, đúng giá trị vừa đọc cùng câu đọc đăng nhập (không phải thời điểm đăng nhập), giữ nguyên độ chính xác; bắt buộc với bốn vai trò nhân viên của BR-79, rỗng với khách và quản trị viên | IssuedSession: token (String, tự kiểm chứng được), expiresAt (DateTime) | InvalidAuthRequestError (Nghiệp vụ nội bộ: subjectId rỗng, subjectKind và role không khớp, accessChangedAt thiếu hoặc thừa) | UC-005 (luồng 5a2: quay lại bước 5 với phiên); đăng nhập nhân viên (tiền điều kiện của UC-008, UC-009 đến UC-017) | verifyPassword đã trả đúng; với nhân viên, DC-LoginService đã đọc dòng Staff Đang hoạt động (BR-97) | Không đổi dữ liệu; phiên không lưu ở máy chủ (P09 F7.8); token mang subjectKind và accessChangedAt | Đồng bộ | Không (mỗi lần cấp token mới, mọi token đều hợp lệ tới khi hết hạn) | Không áp dụng: tính toán cục bộ |
| IF-07 | IAuthenticator | Không có | verifySession(token: String): SessionClaims | token: String - mã phiên lấy từ yêu cầu, không rỗng | SessionClaims: subjectId, subjectKind, role, cinemaId, accessChangedAt (rỗng với khách và quản trị viên), expiresAt | SessionInvalidError (Nghiệp vụ: sai chữ ký hoặc hỏng); SessionExpiredError (Nghiệp vụ: quá hạn) | UC-005 (bước 5; tiền điều kiện nhân viên quầy); UC-008, UC-009 đến UC-017 (tiền điều kiện) | Không | Không đổi dữ liệu; không gọi mạng, không đọc cơ sở dữ liệu; chỉ chứng thực danh tính, role và cinemaId của nhân viên trong claims có thể đã cũ nên bên gọi đối chiếu mốc qua DC-AccessCheckService (BR-101) | Đồng bộ | Có | Không áp dụng: tính toán cục bộ |
| IF-07 | IAuthenticator | Không có | checkRole(role: Role, allowedRoles: List(Role)): Boolean | role: Role - vai trò hiện hành: với nhân viên là vai trò của dòng Staff do DC-AccessCheckService trả (P09 F7.11), không phải của token; với khách và quản trị viên là vai trò trong claims<br>allowedRoles: List(Role) - vai trò được phép của chức năng, không rỗng | Boolean: đúng khi role thuộc allowedRoles | Không | UC-005, UC-008, UC-009 đến UC-017 (tiền điều kiện) | verifySession đã trả SessionClaims; với nhân viên, DC-AccessCheckService đã xác nhận mốc | Không đổi dữ liệu | Đồng bộ | Có | Không áp dụng |

Phủ trách nhiệm (P10 F2): hashPassword, verifyPassword, issueSession, verifySession, checkRole đều có chữ ký. accessChangedAt là DateTime có thể rỗng (khách, quản trị viên); kiểu Go tương ứng là con trỏ time.Time (P12 mục 0.2). So accessChangedAt và trạng thái Bị khoá với dòng Staff không thuộc IF-07 (P10 F2): DC-AccessCheckService (PKG-19) làm và trả vai trò, cụm rạp hiện hành cho Application. Phạm vi cụm rạp của nhân viên (REQ-100, BR-02) do Application kiểm bằng cinemaId hiện hành đó. Quản trị viên (ACT-06) không nằm trong Staff nên không có mốc và không bị DC-AccessCheckService thu hồi phiên (P09 F7.11, Q-271).

## F4. Sequence diagram

File diagrams/P11b-subsystem-SS-05.drawio, 7 trang: S05B1, S05B2, S05B3 (hộp đen), S05W1, S05W2 (hộp trắng), Phần tử, Phụ thuộc. Operation hashPassword và verifyPassword được hiện thực một-một bởi DC-PasswordHasher và checkRole bởi DC-RoleAuthorizer (DC-AuthenticatorManager chỉ uỷ quyền) nên không có sơ đồ hộp trắng riêng.

### Trang "Hộp đen - kiểm tra phiên và vai trò (tiền điều kiện UC-005, UC-008, UC-009, UC-013, UC-014)"

Trang này là phần kiểm chữ ký, hạn và vai trò dùng chung cho khách và nhân viên; phần đối chiếu mốc của nhân viên ở trang S05B3.

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05B1-L1 | Lifeline | :AuthFilter | - | DC-AuthFilter, PKG-11 | Bộ lọc mọi yêu cầu cần đăng nhập |
| S05B1-L2 | Lifeline | :IF-07 IAuthenticator | «interface» | SS-05 | Interface bảo mật |
| S05B1-F1 | Fragment | alt [phiên hợp lệ] | - | - | Operand tiếp: [chữ ký sai hoặc hỏng]; [quá hạn] |
| S05B1-F2 | Fragment | opt [phiên hợp lệ] | - | - | Một operand |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :AuthFilter | :IF-07 IAuthenticator | verifySession(token) | Đồng bộ | - | Tiền điều kiện đã đăng nhập: UC-005 (khách, nhân viên quầy), UC-008, UC-009, UC-013, UC-014 |
| 2 | :IF-07 IAuthenticator | :AuthFilter | SessionClaims(subjectId, subjectKind, role, cinemaId, accessChangedAt, expiresAt) | Trả về | S05B1-F1 [phiên hợp lệ] | Nhân viên: tiếp trang S05B3 (BR-101) |
| 3 | :IF-07 IAuthenticator | :AuthFilter | SessionInvalidError | Trả về | S05B1-F1 [chữ ký sai hoặc hỏng] | Yêu cầu bị từ chối như chưa đăng nhập; UC-005 bước 5a cho khách |
| 4 | :IF-07 IAuthenticator | :AuthFilter | SessionExpiredError | Trả về | S05B1-F1 [quá hạn] | Như chưa đăng nhập (Q-129) |
| 5 | :AuthFilter | :IF-07 IAuthenticator | checkRole(role hiện hành, allowedRoles) | Đồng bộ | S05B1-F2 [phiên hợp lệ] | Vai trò theo tác nhân (P09 F4); với nhân viên là vai trò hiện hành sau S05B3 |
| 6 | :IF-07 IAuthenticator | :AuthFilter | Boolean | Trả về | S05B1-F2 [phiên hợp lệ] | Sai thì từ chối; phạm vi cụm rạp (REQ-100) do Application kiểm |

### Trang "Hộp đen - đăng nhập của khách và của nhân viên (UC-005 luồng 5a2)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05B2-L1 | Lifeline | :LoginService | - | DC-LoginService, PKG-19 | Một lớp phục vụ hai điểm đăng nhập riêng (Q-267) |
| S05B2-L2 | Lifeline | :IF-07 IAuthenticator | «interface» | SS-05 | Interface bảo mật |
| S05B2-F1 | Fragment | alt [mật khẩu đúng] | - | - | Operand tiếp: [mật khẩu sai]; [mã băm lưu trữ hỏng] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :LoginService | :IF-07 IAuthenticator | verifyPassword(plainPassword, storedHash) | Đồng bộ | - | UC-005 luồng 5a2 (khách); đăng nhập nhân viên; NFR-01, NFR-02, NFR-03 |
| 2 | :IF-07 IAuthenticator | :LoginService | true | Trả về | S05B2-F1 [mật khẩu đúng] | - |
| 3 | :LoginService | :IF-07 IAuthenticator | issueSession(subjectId, subjectKind, role, cinemaId, accessChangedAt) | Đồng bộ | S05B2-F1 [mật khẩu đúng] | UC-005 quay lại bước 5. Khách: subjectKind Customer, accessChangedAt rỗng. Nhân viên: Staff, accessChangedAt là giá trị của dòng Staff vừa đọc (P09 F7.11); tài khoản Bị khoá không tới bước này (BR-97, Q-282) |
| 4 | :IF-07 IAuthenticator | :LoginService | IssuedSession(token, expiresAt) | Trả về | S05B2-F1 [mật khẩu đúng] | Phiên tự kiểm chứng được (P09 F7.8) |
| 5 | :IF-07 IAuthenticator | :LoginService | false | Trả về | S05B2-F1 [mật khẩu sai] | UC-005 luồng 5a2a (khách, Q-131); đăng nhập nhân viên dùng cùng thông báo chung (Q-282) |
| 6 | :IF-07 IAuthenticator | :LoginService | MalformedHashError | Trả về | S05B2-F1 [mã băm lưu trữ hỏng] | Lỗi dữ liệu, ghi log, coi như đăng nhập thất bại |

### Trang "Hộp đen - kiểm phiên của nhân viên theo mốc truy cập (BR-101)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05B3-L1 | Lifeline | :AuthFilter | - | DC-AuthFilter, PKG-11 | Bộ lọc mọi yêu cầu cần đăng nhập |
| S05B3-L2 | Lifeline | :IF-07 IAuthenticator | «interface» | SS-05 | Chỉ chứng thực danh tính, không đọc cơ sở dữ liệu |
| S05B3-L3 | Lifeline | :AccessCheckService | - | DC-AccessCheckService, PKG-19 | Không thuộc SS-05; đọc dòng Staff qua IF-15 (P10 F3) |
| S05B3-F1 | Fragment | opt [subjectKind là Staff và role khác Administrator] | - | - | Khách và quản trị viên bỏ qua (không có mốc) |
| S05B3-F2 | Fragment | alt [mốc bằng và tài khoản Đang hoạt động] | - | S05B3-F1 | Operand tiếp: [Bị khoá hoặc mốc khác] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :AuthFilter | :IF-07 IAuthenticator | verifySession(token) | Đồng bộ | - | Tiền điều kiện của UC-005 (nhân viên quầy), UC-008, UC-009 đến UC-017; lỗi chữ ký, hạn xem S05B1 |
| 2 | :IF-07 IAuthenticator | :AuthFilter | SessionClaims(subjectId, subjectKind, role, cinemaId, accessChangedAt, expiresAt) | Trả về | - | - |
| 3 | :AuthFilter | :AccessCheckService | checkStaffAccess(subjectId, accessChangedAt) | Đồng bộ | S05B3-F1 | Tên và chữ ký do P12 đặt; một lần đọc theo khoá chính, không khoá (P09 F7.11) |
| 4 | :AccessCheckService | :AuthFilter | CurrentAccess(role, cinemaId) | Trả về | S05B3-F2 [mốc bằng và tài khoản Đang hoạt động] | Vai trò và cụm rạp của dòng Staff vừa đọc là danh tính hiện hành |
| 5 | :AccessCheckService | :AuthFilter | SessionRevoked | Trả về | S05B3-F2 [Bị khoá hoặc mốc khác] | Bộ lọc trả 401 "phiên không còn hiệu lực"; nhân viên đăng nhập lại (BR-101, BR-97) |
| 6 | :AuthFilter | :IF-07 IAuthenticator | checkRole(role hiện hành, allowedRoles) | Đồng bộ | - | Vai trò hiện hành từ message 4 với nhân viên, từ message 2 với khách và quản trị viên |
| 7 | :IF-07 IAuthenticator | :AuthFilter | Boolean | Trả về | - | Sai thì từ chối truy cập |

Thao tác đã qua bước này trước lúc EX-22 commit vẫn hoàn tất (Q-270); riêng giữ ghế của nhân viên quầy kiểm lại mốc dưới khoá Staff ở EX-01 (P09 F7.11), không đi qua trang này.

### Trang "Hộp trắng - issueSession"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05W1 | Fragment | sd issueSession | - | - | Khung sd; mọi lifeline nằm trong khung |
| S05W1-L1 | Lifeline | :AuthenticatorManager | - | DC-AuthenticatorManager | Điều phối, hiện thực IF-07 |
| S05W1-L2 | Lifeline | :SessionTokenCodec | - | DC-SessionTokenCodec | Chuyển đổi dữ liệu |
| S05W1-L3 | Lifeline | :SecurityConfig | - | DC-SecurityConfig | Cấu hình |
| S05W1-G1 | Gate | issueSession | - | S05W1 | Gate của message 1 |
| S05W1-G8 | Gate | trả về IssuedSession | - | S05W1 | Gate của message 8 |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :AuthenticatorManager | issueSession(subjectId, subjectKind, role, cinemaId, accessChangedAt) | Đồng bộ | - | IF-07; UC-005 luồng 5a2; đăng nhập nhân viên |
| 2 | :AuthenticatorManager | :AuthenticatorManager | validate(subjectId, subjectKind, role, accessChangedAt) | Tự gọi | - | subjectId không rỗng; subjectKind khớp role; accessChangedAt có với bốn vai trò nhân viên của BR-79, rỗng với khách và quản trị viên; vi phạm ném InvalidAuthRequestError |
| 3 | :AuthenticatorManager | :SecurityConfig | sessionSettings(subjectKind, role) | Đồng bộ | - | - |
| 4 | :SecurityConfig | :AuthenticatorManager | signingKey, lifetime | Trả về | - | Thời hạn phiên: khách 24 giờ, nhân viên và quản trị viên 8 giờ, không tự gia hạn (Q-129) |
| 5 | :AuthenticatorManager | :SessionTokenCodec | encode(claims, signingKey) | Đồng bộ | - | claims gồm subjectId, subjectKind, role, cinemaId, accessChangedAt, expiresAt; mốc mã hoá không mất độ chính xác để verifySession và phía so mốc so bằng nhau |
| 6 | :SessionTokenCodec | :SessionTokenCodec | sign(claims) | Tự gọi | - | Ký bằng khoá bí mật của máy chủ; thuật toán chọn khi viết mã |
| 7 | :SessionTokenCodec | :AuthenticatorManager | token | Trả về | - | - |
| 8 | :AuthenticatorManager | Gate | IssuedSession(token, expiresAt) | Trả về | - | - |

### Trang "Hộp trắng - verifySession"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05W2 | Fragment | sd verifySession | - | - | Khung sd; mọi lifeline nằm trong khung |
| S05W2-L1 | Lifeline | :AuthenticatorManager | - | DC-AuthenticatorManager | Điều phối, hiện thực IF-07 |
| S05W2-L2 | Lifeline | :SessionTokenCodec | - | DC-SessionTokenCodec | Chuyển đổi dữ liệu |
| S05W2-G1 | Gate | verifySession | - | S05W2 | Gate của message 1 |
| S05W2-G5 | Gate | trả về SessionInvalidError | - | S05W2 | Gate của message 5 |
| S05W2-G8 | Gate | trả về SessionExpiredError | - | S05W2 | Gate của message 8 |
| S05W2-G9 | Gate | trả về SessionClaims | - | S05W2 | Gate của message 9 |
| S05W2-F1 | Fragment | alt [chữ ký sai hoặc hỏng] | - | S05W2 | Operand tiếp: [chữ ký đúng] |
| S05W2-F2 | Fragment | alt [quá hạn] | - | S05W2 | Operand tiếp: [còn hạn] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | Gate | :AuthenticatorManager | verifySession(token) | Đồng bộ | - | IF-07; tiền điều kiện của UC-005, UC-008, UC-009, UC-013, UC-014 |
| 2 | :AuthenticatorManager | :SessionTokenCodec | decode(token) | Đồng bộ | - | - |
| 3 | :SessionTokenCodec | :SessionTokenCodec | verifySignature(token) | Tự gọi | - | So sánh thời gian hằng |
| 4 | :SessionTokenCodec | :AuthenticatorManager | SessionInvalidError | Trả về | S05W2-F1 [chữ ký sai hoặc hỏng] | - |
| 5 | :AuthenticatorManager | Gate | SessionInvalidError | Trả về | S05W2-F1 [chữ ký sai hoặc hỏng] | - |
| 6 | :SessionTokenCodec | :AuthenticatorManager | SessionClaims | Trả về | S05W2-F1 [chữ ký đúng] | Giải mã đủ subjectKind và accessChangedAt cùng các trường cũ |
| 7 | :AuthenticatorManager | :AuthenticatorManager | checkExpiry(expiresAt, now) | Tự gọi | S05W2-F1 [chữ ký đúng] | Đồng hồ hệ điều hành của bản backend; các bản đồng bộ NTP |
| 8 | :AuthenticatorManager | Gate | SessionExpiredError | Trả về | S05W2-F2 [quá hạn] | - |
| 9 | :AuthenticatorManager | Gate | SessionClaims | Trả về | S05W2-F2 [còn hạn] | - |

## F5. Phần tử của subsystem

a) Bảng phần tử

| DC | Tên | Vai trò (Điều phối / Giao tiếp ngoài / Chuyển đổi dữ liệu / Lưu trữ trong subsystem / Kiểu dữ liệu / Ngoại lệ) | Trách nhiệm | Visibility | Hiện thực IF |
|---|---|---|---|---|---|
| DC-AuthenticatorManager | AuthenticatorManager | Điều phối | Nhận lời gọi IF-07; kiểm tham số; uỷ hashPassword, verifyPassword cho DC-PasswordHasher và checkRole cho DC-RoleAuthorizer (ánh xạ 1-1); tự điều phối issueSession, verifySession | package-private | IF-07 |
| DC-PasswordHasher | PasswordHasher | Chuyển đổi dữ liệu | Băm mật khẩu thành mã băm một chiều kèm muối; kiểm mật khẩu với mã băm đã lưu, so sánh thời gian hằng; không ghi mật khẩu vào log (NFR-10) | package-private | - |
| DC-SessionTokenCodec | SessionTokenCodec | Chuyển đổi dữ liệu | Đổi SessionClaims thành token có chữ ký của máy chủ và ngược lại; kiểm chữ ký bằng so sánh thời gian hằng | package-private | - |
| DC-RoleAuthorizer | RoleAuthorizer | Lưu trữ trong subsystem | Giữ bảng vai trò theo tác nhân ACT-01 đến ACT-06 (P09 F4) và trả lời vai trò có nằm trong tập được phép | package-private | - |
| DC-SecurityConfig | SecurityConfig | Lưu trữ trong subsystem | Giữ khoá ký phiên, tham số băm, thời hạn phiên theo loại chủ thể và vai trò; đọc từ môi trường, không ghi log | package-private | - |
| DC-Role | Role | Kiểu dữ liệu | Customer, BoxOfficeClerk, TicketChecker, CinemaManager, ChainManager, Administrator; dùng trong chữ ký if-07 | public | - |
| DC-SubjectKind | SubjectKind | Kiểu dữ liệu | Customer, Staff (gồm quản trị viên); phân biệt hai tập mã tài khoản độc lập (BR-95, BR-98) và chọn điểm đăng nhập đã cấp phiên (Q-267); dùng trong chữ ký IF-07 | public | - |
| DC-SessionClaims | SessionClaims | Kiểu dữ liệu | subjectId (String), subjectKind (SubjectKind), role (Role), cinemaId (String, rỗng với khách, quản lý chuỗi, quản trị viên), accessChangedAt (DateTime, rỗng với khách và quản trị viên), expiresAt (DateTime); dùng trong chữ ký IF-07 | public | - |
| DC-IssuedSession | IssuedSession | Kiểu dữ liệu | token (String), expiresAt (DateTime); dùng trong chữ ký if-07 | public | - |
| DC-SessionInvalidError | SessionInvalidError | Ngoại lệ | Token sai chữ ký hoặc sai định dạng; dùng trong chữ ký if-07 | public | - |
| DC-SessionExpiredError | SessionExpiredError | Ngoại lệ | Token đúng chữ ký nhưng quá hạn; dùng trong chữ ký if-07 | public | - |
| DC-MalformedHashError | MalformedHashError | Ngoại lệ | Mã băm lưu trữ sai định dạng; dùng trong chữ ký if-07 | public | - |
| DC-InvalidAuthRequestError | InvalidAuthRequestError | Ngoại lệ | Mật khẩu rỗng khi băm; subjectId rỗng, subjectKind và role không khớp, accessChangedAt thiếu hoặc thừa khi cấp phiên; dùng trong chữ ký IF-07 | public | - |

Cơ chế bảo mật dữ liệu theo P09 F7.2, F7.8, F7.11: mật khẩu chỉ lưu dạng băm một chiều, mã phiên ký bằng khoá bí mật của máy chủ và chỉ chứng thực danh tính (quyền nhân viên hiện hành lấy từ dòng Staff, không lấy từ token), không lưu thông tin thẻ (NFR-10). Khoá ký và tham số băm đọc từ biến môi trường khi khởi động, không nằm trong mã nguồn hay log (Thiết kế: thông tin bí mật không được lộ qua mã nguồn và log). Ghi nhật ký (Thiết kế: ghi sự kiện cấp phiên thất bại và token sai ký, không ghi mật khẩu, không ghi token).

b) Class diagram phần tử (trang "Phần tử")

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| IF-07 | Interface | IAuthenticator | «interface» | - | PKG-26 |
| SS-05 | Subsystem | Security | - | - | Chỉ interface là public |
| DC-AuthenticatorManager | Class | AuthenticatorManager | - | SS-05 | Hiện thực IF-07 |
| DC-PasswordHasher | Class | PasswordHasher | - | SS-05 | Chuyển đổi dữ liệu |
| DC-SessionTokenCodec | Class | SessionTokenCodec | - | SS-05 | Chuyển đổi dữ liệu |
| DC-RoleAuthorizer | Class | RoleAuthorizer | - | SS-05 | Lưu trữ trong subsystem |
| DC-SecurityConfig | Class | SecurityConfig | - | SS-05 | Cấu hình |
| DC-Role | Class | Role | «enumeration» | SS-05 | Kiểu dữ liệu (public) |
| DC-SubjectKind | Class | SubjectKind | «enumeration» | SS-05 | Kiểu dữ liệu (public) |
| DC-SessionClaims | Class | SessionClaims | «value» | SS-05 | Kiểu dữ liệu (public) |
| DC-IssuedSession | Class | IssuedSession | «value» | SS-05 | Kiểu dữ liệu (public) |
| DC-SessionInvalidError | Class | SessionInvalidError | «exception» | SS-05 | Ngoại lệ (public) |
| DC-SessionExpiredError | Class | SessionExpiredError | «exception» | SS-05 | Ngoại lệ (public) |
| DC-MalformedHashError | Class | MalformedHashError | «exception» | SS-05 | Ngoại lệ (public) |
| DC-InvalidAuthRequestError | Class | InvalidAuthRequestError | «exception» | SS-05 | Ngoại lệ (public) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| C05-01 | DC-AuthenticatorManager | IF-07 | Realization | - | - |
| C05-02 | DC-AuthenticatorManager | DC-PasswordHasher | Dependency | - | hashPassword, verifyPassword |
| C05-03 | DC-AuthenticatorManager | DC-SessionTokenCodec | Dependency | - | issueSession, verifySession |
| C05-04 | DC-AuthenticatorManager | DC-RoleAuthorizer | Dependency | - | checkRole |
| C05-05 | DC-AuthenticatorManager | DC-SecurityConfig | Dependency | - | đọc cấu hình |
| C05-06 | DC-SessionTokenCodec | DC-SecurityConfig | Dependency | - | khoá ký |
| C05-07 | DC-SessionClaims | DC-Role | Association | 1 ở đầu nguồn; 1 ở đầu đích | - |
| C05-08 | DC-SessionClaims | DC-SubjectKind | Association | 1 ở đầu nguồn; 1 ở đầu đích | - |

## F6. Phụ thuộc subsystem

| Subsystem | Phụ thuộc vào (IF, SS, PKG) | Loại (Qua interface / Vào package) | Lý do | Đánh giá (Ưu tiên / Dùng thận trọng) |
|---|---|---|---|---|
| SS-05 Security | Không phụ thuộc subsystem hoặc package nào khác | - | P09 F6: PKG-26 không có cạnh phụ thuộc ra ngoài; không đọc cơ sở dữ liệu (mã băm do Application truyền vào, phiên tự kiểm chứng) | Ưu tiên |

Phía client: PKG-11 phụ thuộc IF-07 (ngoại lệ cho phép của P09 F6: Presentation kiểm mã phiên); PKG-19 phụ thuộc IF-07 (DC-LoginService, DC-RegisterAccountService, DC-ManageStaffAccountsService). DC-AuthFilter (PKG-11) còn gọi DC-AccessCheckService (PKG-19) cho nhân viên, quan hệ giữa hai package Application và Presentation nằm ngoài SS-05.

Trang "Phụ thuộc"

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| PKG-11 | Package | PKG-11 HttpApi | - | - | Client IF-07: DC-AuthFilter (ngoại lệ P09 F6) |
| PKG-19 | Package | PKG-19 AccountManagement | - | - | Client IF-07: DC-LoginService, DC-RegisterAccountService, DC-ManageStaffAccountsService |
| IF-07 | Interface | IF-07 IAuthenticator | «interface» | - | PKG-26 |
| SS-05 | Subsystem | Security | - | - | PKG-26; không phụ thuộc package nào khác |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| D05-01 | PKG-11 | IF-07 | Dependency | - | Qua interface |
| D05-02 | PKG-19 | IF-07 | Dependency | - | Qua interface |
| D05-03 | SS-05 | IF-07 | Realization | - | - |

## F7. Thiết kế xử lý lỗi và điểm kiểm tra

a) Bảng lỗi

| Operation | Tình huống lỗi | Loại | Phát hiện bằng | Xử lý trong subsystem (thử lại, tra cứu trạng thái, chuyển đổi ngoại lệ) | Kết quả trả cho client | Luồng P04 tương ứng | Q, ASM |
|---|---|---|---|---|---|---|---|
| verifyPassword | Mật khẩu sai | Nghiệp vụ | So khớp thất bại | Không ghi mật khẩu vào log | Boolean sai | UC-005 luồng 5a2 (P04 không có luồng cho thông tin đăng nhập sai) | Q-131 |
| verifyPassword | Mã băm lưu sai định dạng | Kỹ thuật (dữ liệu) | Phân tích mã băm | Ghi log không kèm mật khẩu | MalformedHashError; bên gọi coi như đăng nhập thất bại | Như trên | Q-131 |
| hashPassword | Mật khẩu rỗng | Nghiệp vụ nội bộ | validate | Không băm | InvalidAuthRequestError | Không có (độ dài tối thiểu do Application kiểm, BR-99) | - |
| issueSession | subjectId rỗng, subjectKind và role không khớp, accessChangedAt thiếu hoặc thừa | Nghiệp vụ nội bộ | validate | Không cấp | InvalidAuthRequestError | Không có (lỗi lập trình) | - |
| verifyPassword (đăng nhập nhân viên) | Tài khoản Bị khoá, mật khẩu đúng | Nghiệp vụ | DC-LoginService đọc trạng thái dòng Staff, ngoài SS-05 | Không gọi issueSession | Không cấp phiên; DC-LoginService báo từ chối | Không có luồng P04 (đăng nhập nhân viên không là use case); BR-97 | Q-282 |
| verifySession | Token sai chữ ký hoặc hỏng | Nghiệp vụ | Kiểm chữ ký so sánh thời gian hằng | Ghi log sự kiện, không ghi token | SessionInvalidError; bộ lọc xử lý như chưa đăng nhập | UC-005 luồng 5a (khách); tiền điều kiện của các UC còn lại | - |
| verifySession | Token quá hạn | Nghiệp vụ | So expiresAt với đồng hồ hệ điều hành (các bản backend đồng bộ NTP) | Không | SessionExpiredError; xử lý như chưa đăng nhập | Như trên | Q-129 |
| checkRole | Vai trò không được phép | Nghiệp vụ | Bảng vai trò | Không | Boolean sai; bộ lọc từ chối truy cập | Không có luồng P04 | Vấn đề còn mở 8 |
| verifySession | Nhân viên bị khoá, đổi vai trò hoặc đổi cụm rạp khi token còn hạn | Nghiệp vụ | SS-05 không phát hiện (không đọc cơ sở dữ liệu); DC-AccessCheckService so accessChangedAt trong claims với dòng Staff | SS-05 trả SessionClaims như thường; phía DC-AccessCheckService mốc lệch hoặc Bị khoá thì từ chối (S05B3) | SessionClaims; bộ lọc trả 401 "phiên không còn hiệu lực" theo kết quả của DC-AccessCheckService | UC-017 (BR-101, BR-97) | Vấn đề còn mở 7 |
| verifySession | Khách hoặc quản trị viên: thu hồi quyền khi token còn hạn | Nghiệp vụ | Không có mốc trong token | Không thu hồi, hết hạn theo thời hạn phiên (khách không có thao tác thu hồi trong phạm vi; quản trị viên không thuộc UC-017, P09 F7.11) | SessionClaims | Không có | Vấn đề còn mở 7 |

b) Điểm kiểm tra

| Điểm kiểm tra | Kết quả | Ghi chú |
|---|---|---|
| Mỗi interface subsystem cung cấp có realization | Đạt | IF-07 do DC-AuthenticatorManager |
| Mỗi interface subsystem dùng có phụ thuộc | Không áp dụng | SS-05 không dùng interface nào |
| Không phần tử bên trong nào public, trừ kiểu dữ liệu và ngoại lệ thuộc chữ ký interface | Đạt | Public: Role, SubjectKind, SessionClaims, IssuedSession, bốn ngoại lệ; còn lại package-private |
| Mỗi operation có sơ đồ hộp trắng hoặc ánh xạ 1-1 | Đạt | issueSession (S05W1), verifySession (S05W2); hashPassword, verifyPassword và checkRole ánh xạ 1-1 |

## Câu hỏi mở

Ghi ở file chung.

## Giả định

Ghi ở file chung.

## Đề xuất sửa artifact trước

Ghi ở file chung.

## Vấn đề còn mở

Ghi ở file chung.
