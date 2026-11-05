# P11b - SS-05 Security - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P11b |
| Phiên bản | 1.1 |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md (mục 3, 4); P01-actors.md 1.1 (ACT-01 đến ACT-06); P04-uc-specs UC-005 1.9 (tiền điều kiện, bước 5, 5a2), UC-008 1.5, UC-009, UC-013, UC-014 (tiền điều kiện đã đăng nhập); P06-supplementary-spec.md 1.2 (NFR-01, NFR-02, NFR-03, NFR-10); P07-uc-analysis UC-005 1.1 (checkCustomerLoggedIn, authenticateCustomer); P09-architecture.md 1.3 (F4, F6, F7.8); P10-design-elements.md 1.1 (F2, F4, F5); TAI_LIEU_GIAO_TIEP: Không có |
| Phạm vi | SS-05 Security (IF-07) |
| Mã Q, ASM cuối đã cấp | Ghi ở file chung (Q-126 đến Q-132) |

SS-05 là subsystem cắt ngang (A1): không message P07 nào của use case khác ngoài UC-005 gửi tới nó; chữ ký lấy từ P10 F2, cột UC ghi các use case có tiền điều kiện hoặc bước dựa vào nó. Đăng nhập không là use case (project-profile.md mục 4), nên việc đăng nhập chỉ xuất hiện như tiền điều kiện.

## F1. Bối cảnh sử dụng

| UC | Control gọi (AC hoặc DC) | Message trong P07 (STT, tên) | Dữ liệu truyền | Luồng lỗi trong P04 |
|---|---|---|---|---|
| UC-005 Đặt vé | DC-AuthFilter (PKG-11) cho phiên; lớp đăng nhập của PKG-19 (chưa có DC) cho mật khẩu | 2.1.1 // checkCustomerLoggedIn (bước 5); 2.1.1a.4 // authenticateCustomer (luồng 5a2, P07 gửi tới AC-E-Customer; P10 chuyển kiểm mật khẩu sang IF-07) | Mã phiên của yêu cầu; email hoặc số điện thoại và mật khẩu | Luồng 5a, 5a2 (khách chưa đăng nhập); không có luồng cho thông tin đăng nhập sai (Q-131) |
| UC-005 Đặt vé (nhân viên quầy), UC-008 Huỷ vé, UC-009 Soát vé, UC-013 Quản lý bảng giá, UC-014 Lập lịch suất chiếu | DC-AuthFilter (PKG-11) | (tiền điều kiện) | Mã phiên; vai trò được phép của chức năng | Tiền điều kiện đã đăng nhập; không có luồng P04 cho phiên hết hạn (Q-129) |

## F2. Interface

| IF | Tên | Vai trò (một câu) | Bên hiện thực (SS; DC khi là interface gọi ngược) | Client (DC, PKG) | Package chứa |
|---|---|---|---|---|---|
| IF-07 | IAuthenticator | Kiểm mật khẩu, cấp và kiểm mã phiên tự kiểm chứng được, kiểm vai trò được phép | SS-05 | DC-AuthFilter (PKG-11); lớp đăng nhập chưa có DC (PKG-19, giữ chỗ) | PKG-26 |

IF-07 có 5 operation theo P10 F2, trong đó 4 có chữ ký; hashPassword chờ P07 UC-001, UC-017 (không use case nào đã có P04, P07 dùng việc tạo mật khẩu). Một interface vì mọi client cần cả nhóm kiểm phiên lẫn nhóm đăng nhập qua cùng tập kiểu (Role, SessionClaims); nếu P12 thấy nhóm kiểm phiên (client PKG-11) và nhóm đăng nhập (client PKG-19) tách rõ thì có thể tách theo nguyên tắc phân tách interface.

## F3. Operation

| IF | Tên | Hệ thống/thiết bị | Operation | Tham số vào | Kết quả | Lỗi / ngoại lệ | UC | Tiền điều kiện | Hậu điều kiện | Đồng bộ | Idempotent | Timeout |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| IF-07 | IAuthenticator | Không có (nội bộ máy chủ) | // hashPassword: băm mật khẩu (P10 F2) | Chờ P07 | Chờ P07 | Chờ P07 | Chờ P07 UC-001, UC-017 | Chờ P07 | Chờ P07 | Chờ P07 | Chờ P07 | Chờ P07 |
| IF-07 | IAuthenticator | Không có | verifyPassword(plainPassword: String, storedHash: String): Boolean | plainPassword: String - mật khẩu khách nhập, không rỗng, không ghi log<br>storedHash: String - mã băm một chiều lưu cùng tài khoản | Boolean: đúng khi mật khẩu khớp mã băm | MalformedHashError (Kỹ thuật: dữ liệu lưu sai định dạng) | UC-005 (luồng 5a2, NFR-01, NFR-02, NFR-03; tiền điều kiện của UC-008, UC-009, UC-013, UC-014) | Application đã tìm tài khoản theo email hoặc số điện thoại và có mã băm | Không đổi dữ liệu | Đồng bộ | Có | Không áp dụng: tính toán cục bộ (Thiết kế: chi phí băm chọn khi viết mã cho vài trăm mili giây mỗi lần kiểm; thuật toán không thiết kế ở đây vì NFR không yêu cầu) |
| IF-07 | IAuthenticator | Không có | issueSession(subjectId: String, role: Role, cinemaId: String): IssuedSession | subjectId: String - mã tài khoản, không rỗng<br>role: Role - vai trò của tài khoản<br>cinemaId: String - mã cụm rạp, rỗng với khách, quản lý chuỗi, quản trị viên (nhân viên thuộc đúng một cụm rạp, REQ-100) | IssuedSession: token (String, tự kiểm chứng được), expiresAt (DateTime) | InvalidAuthRequestError (Nghiệp vụ nội bộ) | UC-005 (luồng 5a2: quay lại bước 5 với phiên); tiền điều kiện của UC-008, UC-009, UC-013, UC-014 | verifyPassword đã trả đúng | Không đổi dữ liệu; phiên không lưu ở máy chủ (P09 F7.8) | Đồng bộ | Không (mỗi lần cấp token mới, mọi token đều hợp lệ tới khi hết hạn) | Không áp dụng: tính toán cục bộ |
| IF-07 | IAuthenticator | Không có | verifySession(token: String): SessionClaims | token: String - mã phiên lấy từ yêu cầu, không rỗng | SessionClaims: subjectId, role, cinemaId, expiresAt | SessionInvalidError (Nghiệp vụ: sai chữ ký hoặc hỏng); SessionExpiredError (Nghiệp vụ: quá hạn) | UC-005 (bước 5; tiền điều kiện nhân viên quầy); UC-008, UC-009, UC-013, UC-014 (tiền điều kiện) | Không | Không đổi dữ liệu; không gọi mạng, không đọc cơ sở dữ liệu | Đồng bộ | Có | Không áp dụng: tính toán cục bộ |
| IF-07 | IAuthenticator | Không có | checkRole(role: Role, allowedRoles: List(Role)): Boolean | role: Role - vai trò trong phiên<br>allowedRoles: List(Role) - vai trò được phép của chức năng, không rỗng | Boolean: đúng khi role thuộc allowedRoles | Không | UC-005, UC-008, UC-009, UC-013, UC-014 (tiền điều kiện) | verifySession đã trả SessionClaims | Không đổi dữ liệu | Đồng bộ | Có | Không áp dụng |

Phủ trách nhiệm (P10 F2): verifyPassword, issueSession, verifySession, checkRole có chữ ký; hashPassword chờ P07. Phạm vi cụm rạp của nhân viên (REQ-100, BR-02) do Application kiểm bằng cinemaId trong SessionClaims, không thuộc IF-07.

## F4. Sequence diagram

File diagrams/P11b-subsystem-SS-05.drawio, 6 trang: S05B1, S05B2 (hộp đen), S05W1, S05W2 (hộp trắng), Phần tử, Phụ thuộc. Operation verifyPassword được hiện thực một-một bởi DC-PasswordHasher và checkRole bởi DC-RoleAuthorizer (DC-AuthenticatorManager chỉ uỷ quyền) nên không có sơ đồ hộp trắng riêng.

### Trang "Hộp đen - kiểm tra phiên và vai trò (tiền điều kiện UC-005, UC-008, UC-009, UC-013, UC-014)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05B1-L1 | Lifeline | :AuthFilter | - | DC-AuthFilter, PKG-11 | Bộ lọc mọi yêu cầu cần đăng nhập |
| S05B1-L2 | Lifeline | :IF-07 IAuthenticator | «interface» | SS-05 | Interface bảo mật |
| S05B1-F1 | Fragment | alt [phiên hợp lệ] | - | - | Operand tiếp: [chữ ký sai hoặc hỏng]; [quá hạn] |
| S05B1-F2 | Fragment | opt [phiên hợp lệ] | - | - | Một operand |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :AuthFilter | :IF-07 IAuthenticator | verifySession(token) | Đồng bộ | - | Tiền điều kiện đã đăng nhập: UC-005 (khách, nhân viên quầy), UC-008, UC-009, UC-013, UC-014 |
| 2 | :IF-07 IAuthenticator | :AuthFilter | SessionClaims(subjectId, role, cinemaId, expiresAt) | Trả về | S05B1-F1 [phiên hợp lệ] | - |
| 3 | :IF-07 IAuthenticator | :AuthFilter | SessionInvalidError | Trả về | S05B1-F1 [chữ ký sai hoặc hỏng] | Yêu cầu bị từ chối như chưa đăng nhập; UC-005 bước 5a cho khách |
| 4 | :IF-07 IAuthenticator | :AuthFilter | SessionExpiredError | Trả về | S05B1-F1 [quá hạn] | Như chưa đăng nhập (Q-129) |
| 5 | :AuthFilter | :IF-07 IAuthenticator | checkRole(role, allowedRoles) | Đồng bộ | S05B1-F2 [phiên hợp lệ] | Vai trò theo tác nhân (P09 F4) |
| 6 | :IF-07 IAuthenticator | :AuthFilter | Boolean | Trả về | S05B1-F2 [phiên hợp lệ] | Sai thì từ chối; phạm vi cụm rạp (REQ-100) do Application kiểm |

### Trang "Hộp đen - đăng nhập (UC-005 bước 5, luồng 5a2)"

| ID | Loại (Lifeline / Actor / Gate / Fragment) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| S05B2-L1 | Lifeline | :AccountService | - | DC chưa cấp, PKG-19 | Lớp đăng nhập của PKG-19 chưa có trong P10 (Đề xuất sửa P10) |
| S05B2-L2 | Lifeline | :IF-07 IAuthenticator | «interface» | SS-05 | Interface bảo mật |
| S05B2-F1 | Fragment | alt [mật khẩu đúng] | - | - | Operand tiếp: [mật khẩu sai]; [mã băm lưu trữ hỏng] |

| STT | Từ | Đến | Message | Loại | Fragment | Operation hoặc UC bước |
|---|---|---|---|---|---|---|
| 1 | :AccountService | :IF-07 IAuthenticator | verifyPassword(plainPassword, storedHash) | Đồng bộ | - | UC-005 luồng 5a2; NFR-01, NFR-02, NFR-03 |
| 2 | :IF-07 IAuthenticator | :AccountService | true | Trả về | S05B2-F1 [mật khẩu đúng] | - |
| 3 | :AccountService | :IF-07 IAuthenticator | issueSession(subjectId, role, cinemaId) | Đồng bộ | S05B2-F1 [mật khẩu đúng] | UC-005 quay lại bước 5 |
| 4 | :IF-07 IAuthenticator | :AccountService | IssuedSession(token, expiresAt) | Trả về | S05B2-F1 [mật khẩu đúng] | Phiên tự kiểm chứng được (P09 F7.8) |
| 5 | :IF-07 IAuthenticator | :AccountService | false | Trả về | S05B2-F1 [mật khẩu sai] | Không có luồng P04 cho thông tin đăng nhập sai (Q-131) |
| 6 | :IF-07 IAuthenticator | :AccountService | MalformedHashError | Trả về | S05B2-F1 [mã băm lưu trữ hỏng] | Lỗi dữ liệu, ghi log, coi như đăng nhập thất bại |

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
| 1 | Gate | :AuthenticatorManager | issueSession(subjectId, role, cinemaId) | Đồng bộ | - | IF-07; UC-005 luồng 5a2 |
| 2 | :AuthenticatorManager | :AuthenticatorManager | validate(subjectId, role) | Tự gọi | - | subjectId không rỗng, role hợp lệ; vi phạm ném InvalidAuthRequestError |
| 3 | :AuthenticatorManager | :SecurityConfig | sessionSettings() | Đồng bộ | - | - |
| 4 | :SecurityConfig | :AuthenticatorManager | signingKey, lifetime | Trả về | - | Thời hạn phiên: khách 24 giờ, nhân viên 8 giờ, không tự gia hạn (Q-129) |
| 5 | :AuthenticatorManager | :SessionTokenCodec | encode(claims, signingKey) | Đồng bộ | - | - |
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
| 6 | :SessionTokenCodec | :AuthenticatorManager | SessionClaims | Trả về | S05W2-F1 [chữ ký đúng] | - |
| 7 | :AuthenticatorManager | :AuthenticatorManager | checkExpiry(expiresAt, now) | Tự gọi | S05W2-F1 [chữ ký đúng] | Đồng hồ hệ điều hành của bản backend; các bản đồng bộ NTP |
| 8 | :AuthenticatorManager | Gate | SessionExpiredError | Trả về | S05W2-F2 [quá hạn] | - |
| 9 | :AuthenticatorManager | Gate | SessionClaims | Trả về | S05W2-F2 [còn hạn] | - |

## F5. Phần tử của subsystem

a) Bảng phần tử

| DC | Tên | Vai trò (Điều phối / Giao tiếp ngoài / Chuyển đổi dữ liệu / Lưu trữ trong subsystem / Kiểu dữ liệu / Ngoại lệ) | Trách nhiệm | Visibility | Hiện thực IF |
|---|---|---|---|---|---|
| DC-AuthenticatorManager | AuthenticatorManager | Điều phối | Nhận lời gọi IF-07; kiểm tham số; uỷ verifyPassword cho DC-PasswordHasher và checkRole cho DC-RoleAuthorizer (ánh xạ 1-1); tự điều phối issueSession, verifySession | package-private | IF-07 |
| DC-PasswordHasher | PasswordHasher | Chuyển đổi dữ liệu | Kiểm mật khẩu với mã băm một chiều đã lưu, so sánh thời gian hằng; không ghi mật khẩu vào log (NFR-10) | package-private | - |
| DC-SessionTokenCodec | SessionTokenCodec | Chuyển đổi dữ liệu | Đổi SessionClaims thành token có chữ ký của máy chủ và ngược lại; kiểm chữ ký bằng so sánh thời gian hằng | package-private | - |
| DC-RoleAuthorizer | RoleAuthorizer | Lưu trữ trong subsystem | Giữ bảng vai trò theo tác nhân ACT-01 đến ACT-06 (P09 F4) và trả lời vai trò có nằm trong tập được phép | package-private | - |
| DC-SecurityConfig | SecurityConfig | Lưu trữ trong subsystem | Giữ khoá ký phiên, tham số băm, thời hạn phiên; đọc từ môi trường, không ghi log | package-private | - |
| DC-Role | Role | Kiểu dữ liệu | Customer, BoxOfficeClerk, TicketChecker, CinemaManager, ChainManager, Administrator; dùng trong chữ ký if-07 | public | - |
| DC-SessionClaims | SessionClaims | Kiểu dữ liệu | subjectId (String), role (Role), cinemaId (String, rỗng với khách, quản lý chuỗi, quản trị viên), expiresAt (DateTime); dùng trong chữ ký if-07 | public | - |
| DC-IssuedSession | IssuedSession | Kiểu dữ liệu | token (String), expiresAt (DateTime); dùng trong chữ ký if-07 | public | - |
| DC-SessionInvalidError | SessionInvalidError | Ngoại lệ | Token sai chữ ký hoặc sai định dạng; dùng trong chữ ký if-07 | public | - |
| DC-SessionExpiredError | SessionExpiredError | Ngoại lệ | Token đúng chữ ký nhưng quá hạn; dùng trong chữ ký if-07 | public | - |
| DC-MalformedHashError | MalformedHashError | Ngoại lệ | Mã băm lưu trữ sai định dạng; dùng trong chữ ký if-07 | public | - |
| DC-InvalidAuthRequestError | InvalidAuthRequestError | Ngoại lệ | subjectId rỗng hoặc role không hợp lệ khi cấp phiên; dùng trong chữ ký if-07 | public | - |

Cơ chế bảo mật dữ liệu theo P09 F7.2: mật khẩu chỉ lưu dạng băm một chiều, mã phiên ký bằng khoá bí mật của máy chủ, không lưu thông tin thẻ (NFR-10). Khoá ký và tham số băm đọc từ biến môi trường khi khởi động, không nằm trong mã nguồn hay log (Thiết kế: thông tin bí mật không được lộ qua mã nguồn và log). Ghi nhật ký (Thiết kế: ghi sự kiện cấp phiên thất bại và token sai ký, không ghi mật khẩu, không ghi token).

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
| DC-SessionClaims | Class | SessionClaims | «value» | SS-05 | Kiểu dữ liệu (public) |
| DC-IssuedSession | Class | IssuedSession | «value» | SS-05 | Kiểu dữ liệu (public) |
| DC-SessionInvalidError | Class | SessionInvalidError | «exception» | SS-05 | Ngoại lệ (public) |
| DC-SessionExpiredError | Class | SessionExpiredError | «exception» | SS-05 | Ngoại lệ (public) |
| DC-MalformedHashError | Class | MalformedHashError | «exception» | SS-05 | Ngoại lệ (public) |
| DC-InvalidAuthRequestError | Class | InvalidAuthRequestError | «exception» | SS-05 | Ngoại lệ (public) |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú |
|---|---|---|---|---|---|
| C05-01 | DC-AuthenticatorManager | IF-07 | Realization | - | - |
| C05-02 | DC-AuthenticatorManager | DC-PasswordHasher | Dependency | - | verifyPassword |
| C05-03 | DC-AuthenticatorManager | DC-SessionTokenCodec | Dependency | - | issueSession, verifySession |
| C05-04 | DC-AuthenticatorManager | DC-RoleAuthorizer | Dependency | - | checkRole |
| C05-05 | DC-AuthenticatorManager | DC-SecurityConfig | Dependency | - | đọc cấu hình |
| C05-06 | DC-SessionTokenCodec | DC-SecurityConfig | Dependency | - | khoá ký |
| C05-07 | DC-SessionClaims | DC-Role | Association | 1 ở đầu nguồn; 1 ở đầu đích | - |

## F6. Phụ thuộc subsystem

| Subsystem | Phụ thuộc vào (IF, SS, PKG) | Loại (Qua interface / Vào package) | Lý do | Đánh giá (Ưu tiên / Dùng thận trọng) |
|---|---|---|---|---|
| SS-05 Security | Không phụ thuộc subsystem hoặc package nào khác | - | P09 F6: PKG-26 không có cạnh phụ thuộc ra ngoài; không đọc cơ sở dữ liệu (mã băm do Application truyền vào, phiên tự kiểm chứng) | Ưu tiên |

Phía client: PKG-11 phụ thuộc IF-07 (ngoại lệ cho phép của P09 F6: Presentation kiểm mã phiên); PKG-19 phụ thuộc IF-07 (giữ chỗ).

Trang "Phụ thuộc"

| ID | Loại (Class / Interface / Subsystem / Package) | Nhãn | Stereotype | Thuộc về (SS) | Ghi chú |
|---|---|---|---|---|---|
| PKG-11 | Package | PKG-11 HttpApi | - | - | Client IF-07: DC-AuthFilter (ngoại lệ P09 F6) |
| PKG-19 | Package | PKG-19 AccountManagement | - | - | Client IF-07 (giữ chỗ, lớp đăng nhập chưa cấp DC) |
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
| issueSession | subjectId rỗng hoặc role không hợp lệ | Nghiệp vụ nội bộ | validate | Không cấp | InvalidAuthRequestError | Không có (lỗi lập trình) | - |
| verifySession | Token sai chữ ký hoặc hỏng | Nghiệp vụ | Kiểm chữ ký so sánh thời gian hằng | Ghi log sự kiện, không ghi token | SessionInvalidError; bộ lọc xử lý như chưa đăng nhập | UC-005 luồng 5a (khách); tiền điều kiện của các UC còn lại | - |
| verifySession | Token quá hạn | Nghiệp vụ | So expiresAt với đồng hồ hệ điều hành (các bản backend đồng bộ NTP) | Không | SessionExpiredError; xử lý như chưa đăng nhập | Như trên | Q-129 |
| checkRole | Vai trò không được phép | Nghiệp vụ | Bảng vai trò | Không | Boolean sai; bộ lọc từ chối truy cập | Không có luồng P04 | Vấn đề còn mở 8 |
| verifySession | Tài khoản bị khoá hoặc đổi vai trò khi token còn hạn | Nghiệp vụ | Không phát hiện được vì không đọc cơ sở dữ liệu | Chấp nhận tới hết hạn token (P09 F7.8: phiên tự kiểm chứng, không dính phiên) | SessionClaims cũ | Chờ P07 UC-017 | Vấn đề còn mở 7 |

b) Điểm kiểm tra

| Điểm kiểm tra | Kết quả | Ghi chú |
|---|---|---|
| Mỗi interface subsystem cung cấp có realization | Đạt | IF-07 do DC-AuthenticatorManager |
| Mỗi interface subsystem dùng có phụ thuộc | Không áp dụng | SS-05 không dùng interface nào |
| Không phần tử bên trong nào public, trừ kiểu dữ liệu và ngoại lệ thuộc chữ ký interface | Đạt | Public: Role, SessionClaims, IssuedSession, bốn ngoại lệ; còn lại package-private |
| Mỗi operation có sơ đồ hộp trắng hoặc ánh xạ 1-1 | Đạt | issueSession (S05W1), verifySession (S05W2); verifyPassword và checkRole ánh xạ 1-1; hashPassword chờ P07 |

## Câu hỏi mở

Ghi ở file chung.

## Giả định

Ghi ở file chung.

## Đề xuất sửa artifact trước

Ghi ở file chung.

## Vấn đề còn mở

Ghi ở file chung.
