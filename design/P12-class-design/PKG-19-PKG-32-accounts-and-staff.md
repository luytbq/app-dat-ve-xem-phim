# P12 - Thiết kế lớp - PKG-19 AccountManagement và PKG-32 StaffAccounts - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P12 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C5, C7, C10); 00-Concurrency.md (M7); project-profile.md (mục 2, 3, 4); P10-design-elements.md 2.0 (F2, F3, F3a EX-20 đến EX-22, F4, F5, F6, Đề xuất sửa artifact trước, Vấn đề còn mở 9, 11); P09-architecture.md 2.0 (F4, F7.3, F7.10, F7.11, Q-267, Q-270); P08-analysis-model.md 2.0 (F2a STT 41, F3, R-66 đến R-69); P07-uc-analysis UC-001 và UC-017 (3.4, 4, 5); P11b-system-interfaces SS-05 2.0 (F3, F5); P11a-gui SCR-01, SCR-21, SCR-22, SCR-37 đến SCR-40; P13-data-model.md hiện hành (TBL-08, TBL-11, TBL-12); P12-class-design.md 1.6 (lõi, chỉ tham chiếu, không sửa); design/_sync-log.md (đầu lô, mục Đầu vào cho lần chạy lại P08-P13, các dòng P12); dải mã được cấp: R-270 đến R-299, ST-12 đến ST-14, IF-35 đến IF-37, Q-312 đến Q-321 |
| Phạm vi | PKG-19 AccountManagement (đăng ký khách, quản lý tài khoản nhân viên, đăng nhập, kiểm phiên theo mốc) và PKG-32 StaffAccounts (lớp cha Staff, quản lý cụm rạp, nhân viên soát vé, kho nhân viên). Use case UC-001, UC-017; đăng nhập hai điểm (Q-267); kiểm phiên BR-101 (Q-270); quản trị viên theo Q-271. Nhân viên quầy (DC-BoxOfficeClerk), khách (DC-Customer) và IF-07 đã ở file lõi P12-class-design.md, chỉ dẫn lại |
| Mã Q, ASM cuối đã cấp | Q-313 (dải Q-312 đến Q-321, dùng Q-312 và Q-313); không có ASM (NGHIEM_NGAT). Mã R dùng R-270 đến R-287; ST-12; không cấp IF mới |

Trọng tâm: biến sáu thao tác của hai package thành lớp Go lập trình được. (1) Hai thao tác tạo tài khoản (EX-20 khách, EX-21 nhân viên) băm mật khẩu xong rồi mới mở giao dịch, lấy khoá giá trị theo thứ tự hạng 11, 12, 13, kiểm trùng dưới khoá rồi ghi. (2) Năm thao tác sửa tài khoản nhân viên (EX-22) khoá dòng Staff hạng 4, so mốc lastChangedAt với mốc lúc hiển thị rồi mới ghi (BR-102). (3) Kiểm phiên của nhân viên mỗi yêu cầu (BR-101) chỉ là một lần đọc dòng Staff theo khoá chính, so trạng thái và accessChangedAt với mốc trong mã phiên. (4) Đăng nhập là hai điểm riêng, chỉ đọc, và cấp phiên mang đúng mốc accessChangedAt vừa đọc.

Kết quả: 9 phần tử có hành vi chi tiết hoá (4 lớp dịch vụ và 1 lớp tiện ích ở PKG-19; 3 lớp miền và 1 interface kho ở PKG-32), 19 kiểu phụ trợ, 18 quan hệ mới (R-270 đến R-287) cùng 3 quan hệ giữ mã P08 (R-66, R-68, R-69), 1 state machine (ST-12), 2 class diagram, 1 sơ đồ trạng thái.

## 0. Phạm vi và quy ước

0.1. Phạm vi. Lần chạy theo package gồm hai package liền kề (cùng dữ liệu tài khoản, cùng khoá giá trị email), 9 phần tử có hành vi, dưới ngưỡng 15 đến 20. Các lớp ngoài phạm vi mà file này tham chiếu: DC-Customer, DC-BoxOfficeClerk, IF-16 (PKG-28); IF-07, DC-Role, DC-SubjectKind, DC-SessionClaims, DC-IssuedSession (PKG-26); IF-08, IF-13, DC-Cinema, DC-CinemaIds, DC-TxOptions, DC-ValueLockKind, DC-NotFoundError, DC-SystemBusyError (PKG-27). Giao diện React (DC-LoginView, DC-RegisterAccountView, DC-ManageStaffAccountsView, DC-AccountController) thuộc lượt PKG-05 đến PKG-11 và PKG-31, không thuộc file này; mục 0.4 đối chiếu màn hình với lỗi của các operation.

0.2. Kiểu dữ liệu. Dùng bảng ánh xạ ở mục 0.2 của P12 lõi (Go, time.Time, Ctx, Tx, định danh số int64 đặt tên riêng). Thêm: StaffId là int64 (DC-StaffIds, PKG-32); mã khách CustomerId của DC-TicketingIds (PKG-28). Mã chủ thể trong mã phiên là chuỗi (P11b IF-07), service đổi bằng strconv.

0.3. Quy ước hiện thực theo P12 lõi mục 0.3 (lớp dịch vụ mở giao dịch qua IF-08.Do, entity nhận now qua tham số, lỗi nghiệp vụ là kiểu lỗi có tên). Thêm bốn quy ước riêng của hai package:

- Domain không phụ thuộc Services. Staff giữ vai trò bằng DC-StaffRole (PKG-32, bốn giá trị của BR-79), không dùng DC-Role của PKG-26 (layer Services); DC-RoleMapper (PKG-19, Application) đổi qua lại (R-282 trở đi, F9).
- Mốc thay đổi dùng so bằng (Equal) giữa mốc lúc hiển thị và lastChangedAt của dòng đã khoá (BR-102). Cả hai là time.Time lấy từ timestamptz, độ chính xác micro giây, giữ nguyên khi đi qua trình duyệt (chuỗi RFC 3339 đủ micro giây). Cùng cách cho accessChangedAt trong mã phiên (P11b IF-07).
- Thao tác tạo tài khoản và sửa mật khẩu băm mật khẩu bằng IF-07.HashPassword trước khi mở giao dịch (băm chậm, không giữ khoá lúc băm, P10 F3a EX-20, EX-21). Quy tắc kiểm dữ liệu chạy trước băm để yêu cầu sai không tốn chi phí băm.
- Lớp nhân viên là một dòng dữ liệu có vai trò. DC-Staff không trừu tượng (quản lý chuỗi không có lớp con, P08 F2a STT 41); DC-CinemaManager, DC-TicketChecker, DC-BoxOfficeClerk là kiểu nhúng DC-Staff, tạo từ một DC-Staff có đúng vai trò (R-67 đến R-69).

0.4. Đối chiếu màn hình (P11a) với lỗi của operation. SCR-01 (khách đăng nhập): DC-LoginService.LoginCustomer, LoginFailedError là thông điệp chung (Q-131, MSG-86). SCR-21 (nhân viên và quản trị viên đăng nhập): LoginStaff, LoginFailedError (MSG-86), StaffLockedError chỉ sau khi mật khẩu đúng (MSG-87, Q-276); MSG-85 hiện khi PKG-11 trả 401 vì DC-AccessCheckService báo StaffAccessRevokedError (BR-101). SCR-22: RegisterAccount, CustomerDataError (BR-81, BR-82, BR-99, MSG-04, MSG-05, MSG-89), DuplicateCustomerError (BR-98, MSG-90). SCR-37 đến SCR-40: các operation của DC-ManageStaffAccountsService; StaleStaffError là MSG-120 (BR-102); StaffStatusUnchangedError là thông báo trạng thái không đổi (1b3a, 1c3a); StaffDataError là các lỗi trường (Q-163, BR-78, BR-79).

## F1. Bảng lớp thiết kế

| DC | Tên | Stereotype | PKG | Trách nhiệm | Nguồn AC | Loại | Persistent | Ghi chú thiết kế |
|---|---|---|---|---|---|---|---|---|
| DC-RegisterAccountService | RegisterAccountService | «service» | PKG-19 | Điều phối đăng ký tài khoản khách và là ranh giới giao dịch của thao tác kiểm trùng email, số điện thoại rồi tạo khách (EX-20) | AC-C-RegisterAccountController | class | Không | Control đổi tên Service (P10 F3). Mọi quy tắc BR-81, BR-82, BR-99 nằm ở DC-Customer; lớp này chỉ điều phối, băm và giữ giao dịch |
| DC-ManageStaffAccountsService | ManageStaffAccountsService | «service» | PKG-19 | Điều phối việc quản trị viên tạo, đổi vai trò và cụm rạp, khoá, mở khoá, sửa họ tên và đặt lại mật khẩu tài khoản nhân viên, mỗi thao tác là một giao dịch (EX-21, EX-22) | AC-C-ManageStaffAccountsController | class | Không | Control đổi tên Service (P10 F3). Chín operation public cùng một lý do thay đổi là UC-017; giữ một lớp (Vấn đề còn mở 4) |
| DC-LoginService | LoginService | «service» | PKG-19 | Xác thực khách và nhân viên ở hai điểm đăng nhập riêng rồi cấp mã phiên qua IF-07 | Thiết kế: cơ chế Bảo mật P10 F3; không có AC (hồ sơ dự án mục 4) | class | Không | Chỉ đọc, không khoá. Nhận một mã băm giả qua constructor để so mật khẩu khi không tìm thấy tài khoản, tránh lộ tài khoản có tồn tại qua thời gian trả lời |
| DC-AccessCheckService | AccessCheckService | «service» | PKG-19 | Đối chiếu trạng thái và accessChangedAt của dòng Staff hiện hành với mốc trong mã phiên và trả vai trò, cụm rạp hiện hành của nhân viên | Thiết kế: cơ chế Bảo mật P10 F3 (BR-101, Q-270) | class | Không | Một nơi duy nhất kiểm phiên cho mọi use case của nhân viên; PKG-11 gọi mỗi yêu cầu |
| DC-RoleMapper | RoleMapper | «utility» | PKG-19 | Đổi vai trò nhân viên của Domain (DC-StaffRole) sang vai trò của mã phiên (DC-Role) và ngược lại | Thiết kế: Domain không được thấy PKG-26 (F9) | class | Không | Hàm thuần, không trạng thái; package-private |
| DC-Staff | Staff | «entity» | PKG-32 | Giữ tài khoản nhân viên (vai trò, trạng thái, cụm rạp, mốc thay đổi, mốc truy cập) và kiểm soát vòng đời Đang hoạt động hoặc Bị khoá | AC-E-Staff | class | Có | Có state machine ST-12. Lớp cha của DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager (Q-228); quản lý chuỗi là giá trị vai trò, không có lớp con. Mã nhân viên và tài khoản quản trị viên là hai tập khác nhau (Q-271) |
| DC-CinemaManager | CinemaManager | «entity» | PKG-32 | Biểu diễn nhân viên có vai trò quản lý cụm rạp, kiểu nhúng DC-Staff | AC-E-CinemaManager | class | Có | Không có trách nhiệm riêng ngoài // provideCinema kế thừa; giữ vì GL-42 là thuật ngữ riêng (P10 Vấn đề còn mở 9). Cùng dòng dữ liệu với DC-Staff |
| DC-TicketChecker | TicketChecker | «entity» | PKG-32 | Biểu diễn nhân viên có vai trò soát vé, kiểu nhúng DC-Staff | AC-E-TicketChecker | class | Có | Như DC-CinemaManager, GL-36 |
| IF-15 | IStaffRepository | «interface» | PKG-32 | Khoá, đọc và ghi dòng nhân viên và đọc tài khoản quản trị viên | P10 cơ chế Persistence | interface | Không | Hạng 4 cho LockStaff. Hiện thực bởi DC-PgCinemaOperationsStore (PKG-21, lượt khác) |

Lớp đã có ở lõi, chỉ dẫn lại (không chi tiết hoá ở đây): DC-Customer (PKG-28, AC-E-Customer), DC-BoxOfficeClerk (PKG-28, AC-E-BoxOfficeClerk, kế thừa DC-Staff theo R-67), IF-16 (PKG-28), IF-07 (PKG-26). Các operation file này cần thêm ở các lớp đó ghi ở Chữ ký interface tạm và Đề xuất sửa artifact trước.

Kiểm tra mục đích mỗi lớp (Bước 1.6): RegisterAccountService, LoginService, AccessCheckService mỗi lớp một lý do thay đổi (đăng ký; thông tin xác thực; cơ chế kiểm phiên). ManageStaffAccountsService gom chín operation cùng một use case (UC-017) và cùng tập phụ thuộc (IF-08, IF-15, IF-13, IF-07); tách theo từng thao tác sẽ lặp bốn phụ thuộc mà không đổi lý do thay đổi. Control không là bộ chuyển tiếp rỗng: mỗi operation tự mở giao dịch, băm mật khẩu và đối chiếu mốc.

### F1b. Kiểu phụ trợ

| DC | Loại | PKG | Thành phần hoặc giá trị | Dùng trong chữ ký |
|---|---|---|---|---|
| DC-StaffIds | value object | PKG-32 | StaffId (int64, gán khi lưu). Cùng kiểu với BoxOfficeClerkId của DC-TicketingIds (Đề xuất sửa lõi) | IF-15, DC-Staff, DC-ManageStaffAccountsService |
| DC-StaffRole | enumeration | PKG-32 | BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER (BR-79) | DC-Staff, DC-StaffInfo, DC-RoleMapper |
| DC-StaffStatus | enumeration | PKG-32 | ACTIVE (Đang hoạt động), LOCKED (Bị khoá) (BR-96, BR-97) | DC-Staff, DC-StaffInfo, ST-12 |
| DC-StaffInfo | value object | PKG-32 | id (StaffId), email (string), fullName (string), role (StaffRole), cinemaId (CinemaId, 0 khi quản lý chuỗi), status (StaffStatus), lastChangedAt (time.Time). Trả bởi ProvideStaffInfo | DC-Staff.ProvideStaffInfo, DC-StaffAccountView |
| DC-StaffRecord | value object | PKG-32 | Mọi cột của dòng nhân viên: id, email, fullName, passwordHash, role, cinemaId, status, lastChangedAt, accessChangedAt. Cầu nối với bộ ánh xạ của PKG-21 (entity do bộ ánh xạ tạo lại, Bước 2.4) | DC-Staff.RestoreStaff, DC-Staff.Snapshot |
| DC-AdministratorAccount | value object | PKG-32 | id (int64), email (string), passwordHash (string). Một dòng do cài đặt tạo, ngoài Staff (Q-271, NFR-12) | IF-15.FindAdministratorByEmail |
| DC-StaffDataError | exception | PKG-32 | field (EMAIL, FULL_NAME, ROLE, CINEMA, PASSWORD), rule (BR-78, BR-79, Q-163, Q-274). Dữ liệu tài khoản nhân viên không hợp lệ | DC-Staff.CheckStaffData, CheckRoleAndCinema, RenameStaff, DC-ManageStaffAccountsService |
| DC-StaleStaffError | exception | PKG-32 | Tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (BR-102) | DC-Staff.SaveStaffChanges, LockStaff, UnlockStaff, RenameStaff, ResetStaffPassword |
| DC-StaffStatusUnchangedError | exception | PKG-32 | current (StaffStatus). Khoá khi đã bị khoá, mở khoá khi đang hoạt động (luồng 1b3a, 1c3a) | DC-Staff.LockStaff, UnlockStaff |
| DC-StaffAccessRevokedError | exception | PKG-32 | Phiên không còn hiệu lực: tài khoản Bị khoá, hoặc accessChangedAt khác mốc trong mã phiên, hoặc dòng không còn (BR-101) | DC-Staff.CheckAccessUnchanged, DC-AccessCheckService |
| DC-DuplicateStaffEmailError | exception | PKG-32 | Email đã thuộc tài khoản nhân viên khác (BR-95) | DC-ManageStaffAccountsService.CreateStaffAccount, IF-15.InsertStaff (lưới an toàn của chỉ mục unique) |
| DC-NewStaffRequest | value object | PKG-19 | email, fullName, plainPassword (string), role (Role), cinemaId (CinemaId, 0 với quản lý chuỗi). Gom năm tham số (Bước 2.3) | DC-ManageStaffAccountsService.CreateStaffAccount |
| DC-StaffAccountView | value object | PKG-19 | info (StaffInfo), role (Role của mã phiên), cinemaName (string, rỗng với quản lý chuỗi). Dữ liệu hiển thị một tài khoản | DC-ManageStaffAccountsService |
| DC-StaffChoices | value object | PKG-19 | roles ([]Role, bốn vai trò BR-79), cinemas ([]CinemaChoice) | DC-ManageStaffAccountsService.OpenStaffCreation, OpenStaffForUpdate |
| DC-CinemaChoice | value object | PKG-19 | id (CinemaId), name (string) | DC-StaffChoices |
| DC-StaffAccess | value object | PKG-19 | staffId (StaffId), role (Role), cinemaId (CinemaId). Danh tính hiện hành do PKG-11 chuyển cho Application (F7.11) | DC-AccessCheckService.CheckStaffAccess |
| DC-DuplicateCustomerError | exception | PKG-19 | emailTaken, phoneTaken (bool). Email hoặc số điện thoại đã thuộc tài khoản khách khác (BR-98) | DC-RegisterAccountService.RegisterAccount, IF-16.InsertCustomer |
| DC-LoginFailedError | exception | PKG-19 | Thông tin đăng nhập không đúng, một thông điệp chung không cho biết trường nào sai (Q-131) | DC-LoginService |
| DC-StaffLockedError | exception | PKG-19 | Tài khoản nhân viên Bị khoá, chỉ báo sau khi mật khẩu đúng (BR-97, Q-276) | DC-LoginService.LoginStaff |

Các kiểu dùng chung đã có ở lõi, không cấp lại: DC-Role, DC-SubjectKind, DC-SessionClaims, DC-IssuedSession (PKG-26); DC-CinemaIds, DC-NotFoundError, DC-SystemBusyError, DC-TxOptions, DC-ValueLockKind (PKG-27); DC-CustomerDataError cần có ở PKG-28 (Chữ ký interface tạm).

### Chữ ký interface tạm

Các operation sau thuộc lớp ngoài phạm vi (lượt khác của P12 hoặc phiên cập nhật lõi). File này dùng chữ ký sau để F2, F4 khớp; khi lõi có chữ ký chính thức thì đối chiếu lại.

| IF hoặc lớp | Operation | Lý do | Message P07 hoặc nguồn |
|---|---|---|---|
| IF-07 (PKG-26) | HashPassword(plainPassword string) (string, error); IssueSession(subjectId string, subjectKind SubjectKind, role Role, cinemaId string, accessChangedAt time.Time) (IssuedSession, error); VerifySession(token string) (SessionClaims, error) với SessionClaims có subjectKind và accessChangedAt | Chữ ký theo P11b SS-05 2.0; lõi 1.6 còn chữ ký IssueSession cũ và chưa có HashPassword | P11b IF-07.hashPassword, issueSession, verifySession; P09 F7.11 |
| IF-08 (PKG-27) | LockValue(ctx Ctx, tx Tx, kind ValueLockKind, value string) error | Khoá tư vấn mức giao dịch theo giá trị, hạng 11, 12 (khách), 13 (nhân viên); Go chỉ truyền giá trị thô, chuẩn hoá nằm ở SQL (P09 F7.3) | P10 F3a EX-20, EX-21 |
| DC-TxOptions (PKG-27) | ReadOnlyTx(name string) TxOptions | Giao dịch chỉ đọc, pool người dùng, để đọc Staff không khoá (P10 F3) | P09 F7.11 |
| IF-16 (PKG-28) | FindCustomerByLogin(ctx Ctx, login string) (*Customer, error); FindTakenContact(ctx Ctx, tx Tx, email string, phoneNumber string) (emailTaken bool, phoneTaken bool, err error); InsertCustomer(ctx Ctx, tx Tx, c *Customer) (CustomerId, error) | Đọc theo email hoặc số điện thoại chuẩn hoá, kiểm trùng dưới khoá giá trị, ghi khách mới; 23505 dịch thành DuplicateCustomerError | P07 UC-001 msg 2.1.6; UC-005 luồng 5a2 |
| DC-Customer (PKG-28) | CheckRegistrationData(email string, phoneNumber string, plainPassword string) error (Classifier); DraftCustomer(email string, phoneNumber string, passwordHash string) *Customer (Classifier); ID() CustomerId; PasswordHash() string | Quy tắc BR-81, BR-82, BR-99 (và độ dài tối đa Q-124, Q-273) theo đúng thứ tự P04; trả CustomerDataError | P07 UC-001 msg 2.1.1, 2.1.2 |
| IF-13 (PKG-27) | ListCinemas(ctx Ctx) ([]*Cinema, error); FindCinema(ctx Ctx, id CinemaId) (*Cinema, error) | Tên cụm rạp để hiển thị và gán cho nhân viên; DC-Cinema.ProvideCinemaInfo() string trả tên | P07 UC-017 msg 1.1.2, 2.1.9.1 |

## F2. Bảng operation

Kiểu trả về lỗi: error là giá trị trả về cuối (P12 lõi mục 0.2). Ngoại lệ ghi tên kiểu lỗi. Operation Instance, trừ khi ghi Classifier.

| DC | Visibility | Chữ ký | Mô tả | Tiền/hậu điều kiện | Nguồn (message P07 / UC bước) | Phạm vi | Ngoại lệ / lỗi |
|---|---|---|---|---|---|---|---|
| DC-RegisterAccountService | + | NewRegisterAccountService(uow IUnitOfWork, customers IHolderRepository, auth IAuthenticator) *RegisterAccountService | Tạo dịch vụ với ba phụ thuộc tiêm | Hậu: không I/O | Bổ sung: khởi tạo, tiêm phụ thuộc | Classifier | - |
| DC-RegisterAccountService | + | RegisterAccount(ctx Ctx, email string, phoneNumber string, plainPassword string) (CustomerId, error) | Đăng ký tài khoản khách: kiểm dữ liệu, băm mật khẩu, rồi trong một giao dịch kiểm email và số điện thoại chưa thuộc khách nào và tạo khách; trả mã khách | Tiền: không cần phiên. BR-81, BR-82, BR-99, BR-98. Hậu: một Customer dùng được ngay, không phiên (Q-157, Q-158); hoặc không ghi gì | P07 UC-001 msg 2.1 // registerAccount; 2.1.1, 2.1.2, 2.1.6; P10 F3a EX-20 | Instance | CustomerDataError, DuplicateCustomerError, SystemBusyError |
| DC-ManageStaffAccountsService | + | NewManageStaffAccountsService(uow IUnitOfWork, staffs IStaffRepository, cinemas ICinemaRepository, auth IAuthenticator) *ManageStaffAccountsService | Tạo dịch vụ với bốn phụ thuộc tiêm | Hậu: không I/O | Bổ sung: khởi tạo, tiêm phụ thuộc | Classifier | - |
| DC-ManageStaffAccountsService | + | OpenStaffCreation(ctx Ctx) (StaffChoices, error) | Trả bốn vai trò nhân viên và các cụm rạp của chuỗi để quản trị viên chọn khi tạo | Hậu: không đổi dữ liệu, không khoá | P07 UC-017 msg 1.1 // startStaffCreation; 1.1.1, 1.1.2 | Instance | SystemBusyError |
| DC-ManageStaffAccountsService | + | ListStaffAccounts(ctx Ctx) ([]StaffAccountView, error) | Liệt kê mọi tài khoản nhân viên (không gồm quản trị viên) kèm tên cụm rạp, theo mã tăng dần | Hậu: không đổi dữ liệu, không khoá; mốc lastChangedAt từng dòng là mốc lúc hiển thị (BR-102) | P07 UC-017 msg 1a.1, 1b.1, 1c.1, 1d.1, 1e.1 // startStaffAction; 1a.1.1 // provideStaffInfo | Instance | SystemBusyError |
| DC-ManageStaffAccountsService | + | OpenStaffForUpdate(ctx Ctx, staffId StaffId) (StaffAccountView, StaffChoices, error) | Đọc một tài khoản kèm bốn vai trò và các cụm rạp để cập nhật vai trò, cụm rạp | Hậu: không đổi dữ liệu, không khoá | P07 UC-017 msg 1a.2.1 // openStaffForUpdate; 1a.2.1.1, 1a.2.1.2, 1a.2.1.3 | Instance | NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | + | CreateStaffAccount(ctx Ctx, req NewStaffRequest) (StaffAccountView, error) | Tạo tài khoản nhân viên Đang hoạt động: kiểm dữ liệu, băm mật khẩu ban đầu, rồi một giao dịch khoá email, kiểm chưa trùng và lưu | BR-78, BR-79, BR-95, Q-163, Q-274. Hậu: một Staff ACTIVE với accessChangedAt và lastChangedAt bằng now của CSDL; hoặc không ghi gì | P07 UC-017 msg 2.1 // saveStaffAccount; 2.1.1, 2.1.2, 2.1.7, 2.1.9; P10 F3a EX-21 | Instance | StaffDataError, DuplicateStaffEmailError, NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | + | UpdateStaffAccess(ctx Ctx, staffId StaffId, expectedChangedAt time.Time, role Role, cinemaId CinemaId) (StaffAccountView, error) | Đổi vai trò và cụm rạp của tài khoản đã hiển thị với mốc expectedChangedAt | BR-78, BR-79, BR-100, BR-101, BR-102. Hậu: ghi vai trò, cụm rạp, lastChangedAt; accessChangedAt chỉ đổi khi vai trò hoặc cụm rạp đổi; lần giữ ghế chưa kết thúc không bị chạm | P07 UC-017 msg 1a.3.1 // updateStaffAccount; 1a.3.1.1, 1a.3.1.4, 1a.3.1.6; EX-22 | Instance | StaffDataError, StaleStaffError, NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | + | LockStaffAccount(ctx Ctx, staffId StaffId, expectedChangedAt time.Time) error | Khoá tài khoản (không xoá, giữ dữ liệu liên quan) | BR-96, BR-97, BR-100, BR-101, BR-102. Hậu: Staff LOCKED, accessChangedAt và lastChangedAt bằng now; phiên đang mở bị từ chối ở yêu cầu kế tiếp | P07 UC-017 msg 1b.2.1 // changeStaffStatus (khoá); 1b.2.1.1; EX-22 | Instance | StaffStatusUnchangedError, StaleStaffError, NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | + | UnlockStaffAccount(ctx Ctx, staffId StaffId, expectedChangedAt time.Time) error | Mở khoá tài khoản | BR-102. Hậu: Staff ACTIVE, lastChangedAt bằng now, accessChangedAt giữ nguyên (mã phiên cấp trước lúc khoá vẫn bị từ chối) | P07 UC-017 msg 1c.2.1 // changeStaffStatus (mở khoá); 1c.2.1.1; EX-22 | Instance | StaffStatusUnchangedError, StaleStaffError, NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | + | RenameStaffAccount(ctx Ctx, staffId StaffId, expectedChangedAt time.Time, newFullName string) error | Sửa họ tên tài khoản | Q-163, BR-102. Hậu: fullName mới, lastChangedAt bằng now; accessChangedAt giữ nguyên | P07 UC-017 msg 1d.3.1 // renameStaffAccount; 1d.3.1.1; EX-22 | Instance | StaffDataError, StaleStaffError, NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | + | ResetStaffAccountPassword(ctx Ctx, staffId StaffId, expectedChangedAt time.Time, newPlainPassword string) error | Đặt lại mật khẩu do quản trị viên giao ngoài hệ thống | Q-161, Q-274, BR-102. Hậu: passwordHash mới, lastChangedAt bằng now; accessChangedAt giữ nguyên nên phiên đang mở không bị thu hồi (Q-313) | P07 UC-017 msg 1e.3.1 // resetStaffAccountPassword; 1e.3.1.1; EX-22 | Instance | StaffDataError, StaleStaffError, NotFoundError, SystemBusyError |
| DC-ManageStaffAccountsService | - | toView(ctx Ctx, s *Staff) (StaffAccountView, error) | Dựng dữ liệu hiển thị: ProvideStaffInfo kèm tên cụm rạp lấy qua IF-13 | Hậu: không đổi dữ liệu | P07 UC-017 msg 2.1.9, 1a.3.1.6 // provideStaffInfo, // provideCinemaInfo | Instance | NotFoundError |
| DC-LoginService | + | NewLoginService(customers IHolderRepository, staffs IStaffRepository, auth IAuthenticator, dummyPasswordHash string) *LoginService | Tạo dịch vụ; dummyPasswordHash là mã băm của một mật khẩu ngẫu nhiên tính một lần lúc khởi động | Hậu: không I/O | Bổ sung: khởi tạo, tiêm phụ thuộc | Classifier | - |
| DC-LoginService | + | LoginCustomer(ctx Ctx, login string, plainPassword string) (IssuedSession, error) | Đăng nhập khách bằng email hoặc số điện thoại cùng mật khẩu, cấp phiên khách | NFR-01, NFR-02, NFR-03, Q-131, Q-267. Hậu: không đổi dữ liệu, không lưu phiên (P09 F7.8); phiên mang subjectKind CUSTOMER, accessChangedAt rỗng | P07 UC-005 msg 2.1.1a.4 // authenticateCustomer (luồng 5a2); P10 F3 cơ chế Bảo mật | Instance | LoginFailedError, SystemBusyError |
| DC-LoginService | + | LoginStaff(ctx Ctx, email string, plainPassword string) (IssuedSession, error) | Đăng nhập nhân viên hoặc quản trị viên bằng email cùng mật khẩu, cấp phiên mang accessChangedAt vừa đọc | NFR-02, NFR-03, BR-97, Q-267, Q-271, Q-276. Hậu: không đổi dữ liệu; nhân viên Bị khoá thì không cấp phiên | P10 F3 cơ chế Bảo mật; P09 F7.11 (không có message P07) | Instance | LoginFailedError, StaffLockedError, SystemBusyError |
| DC-AccessCheckService | + | NewAccessCheckService(uow IUnitOfWork, staffs IStaffRepository) *AccessCheckService | Tạo dịch vụ với hai phụ thuộc tiêm | Hậu: không I/O | Bổ sung: khởi tạo, tiêm phụ thuộc | Classifier | - |
| DC-AccessCheckService | + | CheckStaffAccess(ctx Ctx, claims SessionClaims) (StaffAccess, error) | Kiểm phiên của nhân viên bốn vai trò BR-79: đọc dòng Staff theo khoá chính không khoá, so trạng thái và accessChangedAt với claims, trả vai trò và cụm rạp hiện hành | Tiền: claims do IF-07.VerifySession trả, subjectKind STAFF, role khác ADMINISTRATOR (quản trị viên không có mốc, P09 F7.11). BR-101. Hậu: không đổi dữ liệu, không khoá, không hạng | P10 F3 cơ chế Bảo mật; P09 F7.11 (không có message P07) | Instance | StaffAccessRevokedError, SystemBusyError |
| DC-RoleMapper | ~ | ToStaffRole(role Role) (StaffRole, bool) | Đổi vai trò của mã phiên sang vai trò nhân viên; false với CUSTOMER và ADMINISTRATOR | Hậu: không đổi trạng thái | Bổ sung: Domain không thấy PKG-26 | Classifier | - |
| DC-RoleMapper | ~ | ToRole(role StaffRole) Role | Đổi vai trò nhân viên sang vai trò của mã phiên | Hậu: không đổi trạng thái | Bổ sung: Domain không thấy PKG-26 | Classifier | - |
| DC-Staff | + | DraftStaff(email string, fullName string, passwordHash string, role StaffRole, cinemaId CinemaId, now time.Time) *Staff | Tạo tài khoản nhân viên dự kiến ở trạng thái ACTIVE, chưa lưu; id gán khi lưu | Tiền: CheckStaffData đã đạt, now lấy từ tx.Now sau khi có khoá email. Hậu: status ACTIVE, lastChangedAt và accessChangedAt bằng now | P07 UC-017 msg 2.1.1 // draftStaff; ST-12 (initial) | Classifier | - |
| DC-Staff | + | CheckStaffData(email string, fullName string, role StaffRole, cinemaId CinemaId) error | Kiểm theo thứ tự email theo định dạng email chuẩn và tối đa 254 ký tự, họ tên không rỗng và tối đa 100 ký tự, rồi CheckRoleAndCinema; dừng ở điều kiện đầu tiên vi phạm | Q-163, Q-273, BR-78, BR-79. Hậu: không đổi trạng thái | P07 UC-017 msg 2.1.2 // checkStaffData | Classifier | StaffDataError |
| DC-Staff | + | CheckRoleAndCinema(role StaffRole, cinemaId CinemaId) error | Kiểm vai trò là một trong bốn giá trị và cụm rạp phù hợp: quản lý chuỗi cinemaId bằng 0, ba vai trò còn lại cinemaId khác 0 | BR-78, BR-79. Hậu: không đổi trạng thái | P07 UC-017 msg 1a.3.1.1 // checkStaffData (vai trò, cụm rạp) | Classifier | StaffDataError |
| DC-Staff | + | ProvideRoleChoices() []StaffRole | Trả bốn vai trò nhân viên theo thứ tự cố định BOX_OFFICE_CLERK, TICKET_CHECKER, CINEMA_MANAGER, CHAIN_MANAGER | BR-79 | P07 UC-017 msg 1.1.1, 1a.2.1.2 // provideRoleChoices | Classifier | - |
| DC-Staff | + | ProvideStaffInfo() StaffInfo | Trả email, họ tên, vai trò, cụm rạp, trạng thái và mốc thay đổi để hiển thị | Hậu: không đổi dữ liệu; tên cụm rạp do bên gọi hỏi Cinema | P07 UC-017 msg 2.1.9, 1a.1.1, 1a.2.1.1, 1a.3.1.6 // provideStaffInfo | Instance | - |
| DC-Staff | + | SaveStaffChanges(expectedChangedAt time.Time, role StaffRole, cinemaId CinemaId, now time.Time) error | Ghi vai trò, cụm rạp mới khi tài khoản chưa đổi kể từ lúc hiển thị | Tiền: dòng đã khoá hạng 4, CheckRoleAndCinema đã đạt. BR-100, BR-101, BR-102. Hậu: lastChangedAt bằng now; accessChangedAt bằng now khi role hoặc cinemaId đổi; status giữ nguyên | P07 UC-017 msg 1a.3.1.4 // saveStaffChanges; ST-12 | Instance | StaleStaffError |
| DC-Staff | + | LockStaff(expectedChangedAt time.Time, now time.Time) error | Đặt Bị khoá khi đang hoạt động và chưa đổi kể từ lúc hiển thị | Tiền: dòng đã khoá hạng 4. BR-96, BR-97, BR-101, BR-102. Hậu: status LOCKED, accessChangedAt và lastChangedAt bằng now | P07 UC-017 msg 1b.2.1.1 // lockStaff; ST-12 | Instance | StaffStatusUnchangedError, StaleStaffError |
| DC-Staff | + | UnlockStaff(expectedChangedAt time.Time, now time.Time) error | Đặt Đang hoạt động khi đang bị khoá và chưa đổi kể từ lúc hiển thị | Tiền: dòng đã khoá hạng 4. BR-102. Hậu: status ACTIVE, lastChangedAt bằng now, accessChangedAt giữ nguyên | P07 UC-017 msg 1c.2.1.1 // unlockStaff; ST-12 | Instance | StaffStatusUnchangedError, StaleStaffError |
| DC-Staff | + | RenameStaff(expectedChangedAt time.Time, newFullName string, now time.Time) error | Lưu họ tên mới không rỗng khi chưa đổi kể từ lúc hiển thị | Tiền: dòng đã khoá hạng 4. Q-163, Q-273, BR-102. Hậu: fullName mới, lastChangedAt bằng now | P07 UC-017 msg 1d.3.1.1 // renameStaff; ST-12 | Instance | StaffDataError, StaleStaffError |
| DC-Staff | + | ResetStaffPassword(expectedChangedAt time.Time, newPasswordHash string, now time.Time) error | Lưu mã băm mật khẩu mới khi chưa đổi kể từ lúc hiển thị | Tiền: dòng đã khoá hạng 4, mật khẩu đã băm. BR-102. Hậu: passwordHash mới, lastChangedAt bằng now | P07 UC-017 msg 1e.3.1.1 // resetStaffPassword; ST-12 | Instance | StaleStaffError |
| DC-Staff | + | CheckAccessUnchanged(sessionAccessChangedAt time.Time) error | Từ chối khi Bị khoá hoặc accessChangedAt khác mốc trong mã phiên (so Equal) | BR-101, BR-97. Hậu: không đổi trạng thái. Dùng cho DC-AccessCheckService và cho EX-01 của nhân viên quầy dưới khoá hạng 4 (P09 F7.11, X-33) | P09 F7.11; P10 F3 cơ chế Bảo mật; ST-12 | Instance | StaffAccessRevokedError |
| DC-Staff | + | ID() StaffId | Mã nhân viên | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Staff | + | Role() StaffRole | Vai trò hiện hành | - | P08 AC-E-Staff// provideStaffInfo; quan sát hậu điều kiện | Instance | - |
| DC-Staff | + | CinemaId() CinemaId | Cụm rạp của nhân viên, 0 khi quản lý chuỗi (R-66) | BR-02, BR-78 | P08 AC-E-Staff// provideCinema (kế thừa bởi ba lớp con) | Instance | - |
| DC-Staff | + | Status() StaffStatus | Trạng thái tài khoản | - | Bổ sung: quan sát hậu điều kiện | Instance | - |
| DC-Staff | + | PasswordHash() string | Mã băm để IF-07.VerifyPassword so | NFR-02 | Bổ sung: DC-LoginService cần để xác thực | Instance | - |
| DC-Staff | + | AccessChangedAt() time.Time | Mốc truy cập, đưa vào mã phiên | BR-101 | Bổ sung: DC-LoginService cần để cấp phiên | Instance | - |
| DC-Staff | + | Snapshot() StaffRecord | Trả mọi cột để bộ ánh xạ ghi | Hậu: không đổi dữ liệu | Bổ sung: bộ ánh xạ PKG-21 ghi dòng | Instance | - |
| DC-Staff | + | RestoreStaff(rec StaffRecord) *Staff | Tạo lại đối tượng từ dòng đã lưu, không kiểm quy tắc | Tiền: rec do kho đọc từ CSDL | Bổ sung: bộ ánh xạ PKG-21 đọc dòng | Classifier | - |
| DC-CinemaManager | + | NewCinemaManager(staff *Staff) (*CinemaManager, error) | Bọc một Staff có vai trò CINEMA_MANAGER; vai trò khác thì từ chối | BR-79. Hậu: dùng chung dữ liệu với staff | P08 AC-E-CinemaManager// provideCinema (kế thừa CinemaId() của DC-Staff) | Classifier | StaffDataError |
| DC-TicketChecker | + | NewTicketChecker(staff *Staff) (*TicketChecker, error) | Bọc một Staff có vai trò TICKET_CHECKER; vai trò khác thì từ chối | BR-79. Hậu: dùng chung dữ liệu với staff | P08 AC-E-TicketChecker// provideCinema (kế thừa CinemaId() của DC-Staff) | Classifier | StaffDataError |
| IF-15 | + | LockStaff(ctx Ctx, tx Tx, id StaffId) (*Staff, error) | SELECT FOR NO KEY UPDATE dòng nhân viên theo khoá chính (hạng 4) | Hạng 4. Hậu: giữ khoá đến hết giao dịch | P10 F3a EX-22 | Instance | NotFoundError, SystemBusyError |
| IF-15 | + | FindByID(ctx Ctx, tx Tx, id StaffId) (*Staff, error) | Đọc dòng nhân viên theo khoá chính, không khoá | Hậu: không khoá, không hạng | P09 F7.11 | Instance | NotFoundError |
| IF-15 | + | FindByEmail(ctx Ctx, email string) (*Staff, error) | Đọc dòng nhân viên theo email chuẩn hoá, không khoá, ngoài giao dịch | Hậu: không khoá; chuẩn hoá norm_email ở SQL (Q-265) | P09 F7.11 (đăng nhập) | Instance | NotFoundError |
| IF-15 | + | ExistsByEmail(ctx Ctx, tx Tx, email string) (bool, error) | Kiểm email đã thuộc tài khoản nhân viên nào chưa | Tiền: đã giữ khoá giá trị STAFF_EMAIL (hạng 13). Hậu: không khoá thêm | P10 F3a EX-21 | Instance | SystemBusyError |
| IF-15 | + | InsertStaff(ctx Ctx, tx Tx, s *Staff) (StaffId, error) | Thêm dòng nhân viên, mã do cột IDENTITY cấp | Tiền: đã giữ khoá STAFF_EMAIL. Hậu: một dòng mới; 23505 của chỉ mục unique dịch thành DuplicateStaffEmailError | P10 F3a EX-21 | Instance | DuplicateStaffEmailError, SystemBusyError |
| IF-15 | + | SaveChanges(ctx Ctx, tx Tx, s *Staff) error | UPDATE các cột đã đổi của dòng đã khoá | Tiền: dòng đã khoá bằng LockStaff trong cùng giao dịch. Hậu: không UPDATE cột khoá (email, mã) | P10 F3a EX-22 | Instance | SystemBusyError |
| IF-15 | + | ListAccounts(ctx Ctx) ([]*Staff, error) | Đọc mọi dòng nhân viên theo mã tăng dần, không khoá, ngoài giao dịch | Hậu: không khoá; không gồm quản trị viên | P07 UC-017 msg 1a.1.1 // provideStaffInfo (lặp) | Instance | SystemBusyError |
| IF-15 | + | FindAdministratorByEmail(ctx Ctx, email string) (AdministratorAccount, error) | Đọc tài khoản quản trị viên theo email chuẩn hoá để đăng nhập | Hậu: không khoá; chưa có thao tác đổi mật khẩu quản trị (Q-271) | P09 F7.11; Q-271 | Instance | NotFoundError |

## F3. Bảng thiết kế method

Mọi thao tác của hai package là đúng một giao dịch hoặc không giao dịch, nên không có trạng thái dở giữa hai giao dịch. Dòng "Nếu dừng tại đây" ghi hệ quả khi tiến trình dừng giữa chừng, khớp Bảng hỏng của P09 F7.10 (dòng "Tiến trình dừng giữa một thao tác ghi nhiều bản ghi" và dòng "Giao dịch đã ghi nhưng phản hồi mất").

| DC.operation | Thuật toán / các bước chính | Đối tượng và operation khác được dùng | Cách dùng thuộc tính, tham số, quan hệ | Hành vi theo trạng thái (nếu có ST) |
|---|---|---|---|---|
| DC-RegisterAccountService.RegisterAccount | 1. Customer.CheckRegistrationData(email, phoneNumber, plainPassword): email, số điện thoại, mật khẩu theo thứ tự BR-81, BR-82, BR-99; sai thì trả CustomerDataError, chưa băm, chưa mở giao dịch.<br>2. hash = auth.HashPassword(plainPassword), ngoài giao dịch.<br>3. draft = Customer.DraftCustomer(email, phoneNumber, hash).<br>4. uow.Do(UserTx("RegisterAccount"), fn). Trong fn đặt lại id và lỗi ở đầu fn (fn có thể chạy lại): (a) IF-08.LockValue(CUSTOMER_EMAIL, email) hạng 11; (b) IF-08.LockValue(CUSTOMER_PHONE, phoneNumber) hạng 12 (luôn email trước số điện thoại); (c) IF-16.FindTakenContact(tx, email, phoneNumber): trùng thì trả DuplicateCustomerError (chưa ghi gì nên rollback); (d) IF-16.InsertCustomer(tx, draft) lấy mã.<br>5. Trả mã khách; không cấp phiên (Q-158).<br>Nếu dừng tại đây: trước commit giao dịch 4 thì không có khách nào, bấm lại đăng ký; sau commit mà phản hồi mất thì bấm lại nhận DuplicateCustomerError từ chính lần trước (khách đăng nhập được). | Customer.CheckRegistrationData, DraftCustomer; IF-07.HashPassword; IF-08.Do, LockValue; IF-16.FindTakenContact, InsertCustomer | email, phoneNumber chuyển nguyên giá trị thô cho khoá và SQL, chuẩn hoá nằm ở norm_email (Q-265); plainPassword không ghi log, không ra khỏi bước 2 | Không áp dụng |
| DC-ManageStaffAccountsService.OpenStaffCreation | 1. roles = Staff.ProvideRoleChoices() đổi sang Role bằng RoleMapper.ToRole.<br>2. cinemas = IF-13.ListCinemas(ctx), mỗi cụm rạp thành CinemaChoice(id, Cinema.ProvideCinemaInfo()).<br>3. Trả StaffChoices. Không giao dịch, không khoá. | Staff.ProvideRoleChoices; RoleMapper.ToRole; IF-13.ListCinemas | - | Không áp dụng |
| DC-ManageStaffAccountsService.ListStaffAccounts | 1. ss = IF-15.ListAccounts(ctx).<br>2. Với mỗi Staff: toView(ctx, s).<br>3. Trả danh sách theo mã tăng dần. Không khoá, ngoài giao dịch: mốc lastChangedAt của từng dòng là mốc hiển thị mà các thao tác sau so lại dưới khoá. | IF-15.ListAccounts; Staff.ProvideStaffInfo; toView | Tên cụm rạp tra một lần cho mỗi mã khác nhau trong lô (bộ nhớ đệm cục bộ của lần gọi) | Không áp dụng |
| DC-ManageStaffAccountsService.OpenStaffForUpdate | 1. s = IF-15.FindByID trong ReadOnlyTx (không khoá); không có thì NotFoundError.<br>2. view = toView(s); choices như OpenStaffCreation.<br>3. Trả view, choices. | IF-08.Do, IF-15.FindByID, toView, OpenStaffCreation (phần chọn) | - | Không áp dụng |
| DC-ManageStaffAccountsService.CreateStaffAccount | 1. Đổi req.role bằng RoleMapper.ToStaffRole; false (CUSTOMER, ADMINISTRATOR) thì StaffDataError{ROLE, BR-79}.<br>2. Staff.CheckStaffData(email, fullName, role, cinemaId): email, họ tên, vai trò, cụm rạp (4c, 4d, 4a, 4b).<br>3. Mật khẩu rỗng thì StaffDataError{PASSWORD, Q-274} (UC-017 chỉ bắt buộc nhập).<br>4. cinemaId khác 0 thì IF-13.FindCinema để chắc cụm rạp còn tồn tại (NotFoundError nếu không).<br>5. hash = auth.HashPassword(req.plainPassword) ngoài giao dịch.<br>6. uow.Do(UserTx("CreateStaff"), fn): (a) IF-08.LockValue(STAFF_EMAIL, email) hạng 13; (b) IF-15.ExistsByEmail: có thì DuplicateStaffEmailError (5a, rollback); (c) now = tx.Now; (d) s = Staff.DraftStaff(email, fullName, hash, role, cinemaId, now); (e) id = IF-15.InsertStaff.<br>7. Nạp lại s theo id trong ReadOnlyTx hoặc dùng s đã có id, toView, trả.<br>Nếu dừng tại đây: trước commit bước 6 không có tài khoản; sau commit phản hồi mất thì bấm lại nhận DuplicateStaffEmailError từ chính lần trước, tài khoản đã đủ dòng (một COMMIT, khớp Bảng hỏng). | RoleMapper; Staff.CheckStaffData, DraftStaff; IF-13.FindCinema; IF-07.HashPassword; IF-08.Do, LockValue; IF-15.ExistsByEmail, InsertStaff | Một khoá giá trị chung cho mọi vai trò (BR-95, hạng 13); email khách là tập khác (hạng 11) nên không tranh nhau | Tài khoản mới vào ST-12 ở Đang hoạt động |
| DC-ManageStaffAccountsService.UpdateStaffAccess | 1. RoleMapper.ToStaffRole; false thì StaffDataError{ROLE, BR-79}; Staff.CheckRoleAndCinema (4a trước 4b).<br>2. cinemaId khác 0 thì IF-13.FindCinema.<br>3. uow.Do(UserTx("UpdateStaffAccess"), fn): (a) s = IF-15.LockStaff(tx, staffId) hạng 4; (b) now = tx.Now; (c) s.SaveStaffChanges(expectedChangedAt, role, cinemaId, now): lệch mốc thì StaleStaffError (5b, chưa ghi nên rollback); (d) IF-15.SaveChanges(tx, s).<br>4. toView(s), trả. Không đụng SeatHold (BR-100).<br>Nếu dừng tại đây: một COMMIT nên hoặc đủ vai trò, cụm rạp, mốc, hoặc chưa đổi gì. | RoleMapper; Staff.CheckRoleAndCinema, SaveStaffChanges; IF-08.Do; IF-15.LockStaff, SaveChanges; toView | Khoá Staff hạng 4 loại trừ EX-01 của nhân viên quầy (X-33): EX-01 trước thì lần giữ ghế được tạo và giữ nguyên, EX-22 trước thì EX-01 thấy mốc đổi và từ chối | Gọi ở cả hai trạng thái, trạng thái giữ nguyên (ST-12 chuyển 4, 5) |
| DC-ManageStaffAccountsService.LockStaffAccount | 1. uow.Do(UserTx("LockStaff"), fn): (a) s = IF-15.LockStaff hạng 4; (b) now = tx.Now; (c) s.LockStaff(expectedChangedAt, now): đã Bị khoá thì StaffStatusUnchangedError (1b3a), rồi lệch mốc thì StaleStaffError (1b3b), cả hai chưa ghi nên rollback; (d) IF-15.SaveChanges.<br>2. Trả nil.<br>Thứ tự kiểm trạng thái trước mốc theo P07 và P04 (Q-312). | IF-08.Do; IF-15.LockStaff, SaveChanges; Staff.LockStaff | accessChangedAt đặt bằng now cùng câu UPDATE nên mọi mã phiên đã cấp bị lệch mốc | Chuyển Đang hoạt động sang Bị khoá (ST-12 chuyển 2) |
| DC-ManageStaffAccountsService.UnlockStaffAccount | Như LockStaffAccount với Staff.UnlockStaff: đang hoạt động thì StaffStatusUnchangedError (1c3a), rồi lệch mốc thì StaleStaffError (1c3b). | IF-08.Do; IF-15.LockStaff, SaveChanges; Staff.UnlockStaff | accessChangedAt không đổi, nên mã phiên cấp trước lúc khoá vẫn lệch và bị từ chối; chỉ đăng nhập mới có phiên dùng được | Chuyển Bị khoá sang Đang hoạt động (ST-12 chuyển 3) |
| DC-ManageStaffAccountsService.RenameStaffAccount | 1. uow.Do(UserTx("RenameStaff"), fn): LockStaff hạng 4; now = tx.Now; s.RenameStaff(expectedChangedAt, newFullName, now): họ tên rỗng thì StaffDataError{FULL_NAME, Q-163} (kiểm trước), rồi lệch mốc thì StaleStaffError; SaveChanges.<br>2. Trả nil. | IF-08.Do; IF-15.LockStaff, SaveChanges; Staff.RenameStaff | accessChangedAt giữ nguyên | Tự chuyển ở cả hai trạng thái (ST-12 chuyển 6, 7) |
| DC-ManageStaffAccountsService.ResetStaffAccountPassword | 1. Mật khẩu rỗng thì StaffDataError{PASSWORD, Q-274}.<br>2. hash = auth.HashPassword(newPlainPassword) ngoài giao dịch.<br>3. uow.Do(UserTx("ResetStaffPassword"), fn): LockStaff hạng 4; now = tx.Now; s.ResetStaffPassword(expectedChangedAt, hash, now): lệch mốc thì StaleStaffError; SaveChanges.<br>4. Trả nil. Nhân viên được giao mật khẩu ngoài hệ thống (Q-161). | IF-07.HashPassword; IF-08.Do; IF-15.LockStaff, SaveChanges; Staff.ResetStaffPassword | Không đổi accessChangedAt nên phiên đang mở không bị thu hồi (Q-313) | Tự chuyển ở cả hai trạng thái (ST-12 chuyển 8, 9) |
| DC-ManageStaffAccountsService.toView | 1. info = s.ProvideStaffInfo().<br>2. info.cinemaId khác 0 thì cinema = IF-13.FindCinema, name = cinema.ProvideCinemaInfo(); bằng 0 thì name rỗng.<br>3. Trả StaffAccountView{info, role: RoleMapper.ToRole(info.role), name}. | Staff.ProvideStaffInfo; IF-13.FindCinema; RoleMapper.ToRole | - | Không áp dụng |
| DC-LoginService.LoginCustomer | 1. c, err = IF-16.FindCustomerByLogin(ctx, login) (một câu SELECT không khoá, store so norm_email hoặc số điện thoại).<br>2. Không tìm thấy thì auth.VerifyPassword(plainPassword, dummyPasswordHash) bỏ kết quả rồi trả LoginFailedError.<br>3. ok = auth.VerifyPassword(plainPassword, c.PasswordHash()); sai thì LoginFailedError.<br>4. auth.IssueSession(subjectId = strconv(c.ID()), SubjectKind CUSTOMER, Role CUSTOMER, cinemaId "", accessChangedAt rỗng).<br>Không giao dịch, không khoá. | IF-16.FindCustomerByLogin; IF-07.VerifyPassword, IssueSession; Customer.ID, PasswordHash | Khách không có thao tác thu hồi quyền trong phạm vi nên không có mốc (P09 F7.11) | Không áp dụng |
| DC-LoginService.LoginStaff | 1. s, err = IF-15.FindByEmail(ctx, email) (một câu SELECT không khoá đọc trạng thái, vai trò, cụm rạp, accessChangedAt).<br>2. Không có dòng nhân viên: a = IF-15.FindAdministratorByEmail; có a thì auth.VerifyPassword(plain, a.passwordHash): đúng thì IssueSession(subjectId = strconv(a.id), STAFF, ADMINISTRATOR, "", accessChangedAt rỗng), sai thì LoginFailedError; không có a thì VerifyPassword với dummyPasswordHash bỏ kết quả rồi LoginFailedError.<br>3. Có nhân viên: VerifyPassword(plain, s.PasswordHash()) sai thì LoginFailedError.<br>4. s.Status() là LOCKED thì StaffLockedError (chỉ sau khi mật khẩu đúng, Q-276).<br>5. IssueSession(strconv(s.ID()), STAFF, RoleMapper.ToRole(s.Role()), cinemaId chuỗi của s.CinemaId() (rỗng khi 0), s.AccessChangedAt()). Mốc đưa vào phiên là giá trị của đúng câu đọc ở bước 1, không phải thời điểm đăng nhập: mọi EX-22 commit sau bước 1 đều làm mốc lệch. | IF-15.FindByEmail, FindAdministratorByEmail; IF-07.VerifyPassword, IssueSession; Staff.Status, PasswordHash, AccessChangedAt, ID, Role, CinemaId; RoleMapper.ToRole | Hai điểm đăng nhập riêng nên một email vừa là khách vừa là nhân viên không nhầm (Q-267) | Đọc status của ST-12: LOCKED bị từ chối |
| DC-AccessCheckService.CheckStaffAccess | 1. id = strconv.ParseInt(claims.subjectId); lỗi thì StaffAccessRevokedError.<br>2. uow.Do(ReadOnlyTx("CheckStaffAccess"), fn): s = IF-15.FindByID(tx, id) không khoá; không có dòng thì StaffAccessRevokedError.<br>3. s.CheckAccessUnchanged(claims.accessChangedAt): Bị khoá hoặc mốc khác thì StaffAccessRevokedError (PKG-11 trả 401).<br>4. Trả StaffAccess{id, RoleMapper.ToRole(s.Role()), s.CinemaId()}: vai trò, cụm rạp của dòng vừa đọc, không lấy từ mã phiên.<br>Không khoá, không hạng. Thao tác đã qua kiểm phiên trước lúc EX-22 commit vẫn hoàn tất (Q-270). | IF-08.Do; IF-15.FindByID; Staff.CheckAccessUnchanged, Role, CinemaId; RoleMapper.ToRole | Một lần đọc khoá chính mỗi yêu cầu, pool người dùng | Đọc status và accessChangedAt (ST-12) |
| DC-Staff.CheckStaffData | 1. Email rỗng, quá 254 ký tự hoặc sai định dạng email chuẩn thì StaffDataError{EMAIL, Q-163}.<br>2. Họ tên rỗng (sau cắt khoảng trắng đầu, cuối) hoặc quá 100 ký tự thì StaffDataError{FULL_NAME, Q-163}.<br>3. CheckRoleAndCinema(role, cinemaId). | CheckRoleAndCinema | Thứ tự cố định để 4c, 4d, 4a, 4b loại trừ nhau (Q-230) | Không áp dụng |
| DC-Staff.CheckRoleAndCinema | 1. role ngoài bốn giá trị thì StaffDataError{ROLE, BR-79}.<br>2. CHAIN_MANAGER mà cinemaId khác 0, hoặc ba vai trò còn lại mà cinemaId bằng 0 thì StaffDataError{CINEMA, BR-78}. | - | - | Không áp dụng |
| DC-Staff.SaveStaffChanges | 1. lastChangedAt không Equal expectedChangedAt thì StaleStaffError.<br>2. changed = role khác s.role hoặc cinemaId khác s.cinemaId.<br>3. Ghi role, cinemaId; lastChangedAt = now; nếu changed thì accessChangedAt = now. | - | Chỉ ghi accessChangedAt khi quyền đổi: lưu lại đúng vai trò, cụm rạp cũ không thu hồi phiên | Cả hai trạng thái, trạng thái giữ nguyên |
| DC-Staff.LockStaff | 1. status là LOCKED thì StaffStatusUnchangedError{LOCKED}.<br>2. lastChangedAt không Equal expectedChangedAt thì StaleStaffError.<br>3. status = LOCKED; accessChangedAt = now; lastChangedAt = now. | - | Kiểm trạng thái trước mốc (Q-312) | Chỉ từ Đang hoạt động; từ Bị khoá bị từ chối |
| DC-Staff.UnlockStaff | 1. status là ACTIVE thì StaffStatusUnchangedError{ACTIVE}.<br>2. Lệch mốc thì StaleStaffError.<br>3. status = ACTIVE; lastChangedAt = now. | - | accessChangedAt giữ nguyên | Chỉ từ Bị khoá |
| DC-Staff.RenameStaff | 1. newFullName rỗng sau cắt khoảng trắng hoặc quá 100 ký tự thì StaffDataError{FULL_NAME, Q-163}.<br>2. Lệch mốc thì StaleStaffError.<br>3. fullName = newFullName cắt khoảng trắng đầu, cuối; lastChangedAt = now. | - | Kiểm họ tên trước mốc theo P07 (Q-312) | Cả hai trạng thái |
| DC-Staff.ResetStaffPassword | 1. Lệch mốc thì StaleStaffError.<br>2. passwordHash = newPasswordHash; lastChangedAt = now. | - | - | Cả hai trạng thái |
| DC-Staff.CheckAccessUnchanged | 1. status là LOCKED thì StaffAccessRevokedError.<br>2. accessChangedAt không Equal sessionAccessChangedAt thì StaffAccessRevokedError. | - | Mã phiên cấp cho quản trị viên không đi qua đây | LOCKED bị từ chối |

Ghi chú theo Bước 2.6: không method nào gọi đồng hồ hệ thống. Entity nhận now qua tham số, lấy từ IF-25.Now của giao dịch sau khi có khoá (P09 F7.2); lớp dịch vụ chỉ đọc giao dịch, không giữ đồng hồ. Mã băm giả của DC-LoginService do bên tạo dịch vụ tính một lần.

## F4. Bảng ánh xạ message --> operation

Message actor --> boundary giao diện (requestRegistration, selectStaff, submit...) thuộc lượt giao diện React, không có dòng ở đây. Message trả về có dữ liệu là kiểu trả về của dòng gọi. Message trùng ở nhiều sơ đồ (STT khác nhau) gộp một dòng, ghi các STT.

| UC | STT message (P07) | Từ (AC/DC) | Đến (AC/DC) | Message phân tích | Operation thiết kế |
|---|---|---|---|---|---|
| UC-001 | 1.1 | AC-B-RegisterAccountForm | AC-C-RegisterAccountController | // startRegistration | Không có operation phía máy chủ: SCR-22 hiển thị biểu mẫu tại trình duyệt, chưa ghi gì |
| UC-001 | 1.1.1 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // showRegistrationRequest | Không có (hiển thị biểu mẫu ở trình duyệt) |
| UC-001 | 2.1 | AC-B-RegisterAccountForm | AC-C-RegisterAccountController | // registerAccount | DC-RegisterAccountService.RegisterAccount(ctx Ctx, email string, phoneNumber string, plainPassword string) (CustomerId, error) |
| UC-001 | 2.1.1 | AC-C-RegisterAccountController | AC-E-Customer | // draftCustomer | Khác lớp nhận: DC-Customer.DraftCustomer (PKG-28, Chữ ký interface tạm). Gọi sau bước kiểm, vì mật khẩu chỉ tồn tại dạng băm trong đối tượng (NFR-02) |
| UC-001 | 2.1.2 | AC-C-RegisterAccountController | AC-E-Customer | // checkRegistrationData | Khác lớp nhận: DC-Customer.CheckRegistrationData (Classifier, PKG-28, Chữ ký interface tạm) chạy trước băm và trước draft |
| UC-001 | 2.1.3, 2.1.4, 2.1.5 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // rejectRegistration (BR-81, BR-82, BR-99) | Ngoại lệ: DC-RegisterAccountService.RegisterAccount ném CustomerDataError |
| UC-001 | 2.1.6 | AC-C-RegisterAccountController | AC-E-Customer | // saveCustomer | Khác lớp nhận: IF-08.LockValue(CUSTOMER_EMAIL), IF-08.LockValue(CUSTOMER_PHONE), IF-16.FindTakenContact, IF-16.InsertCustomer (P10 F3a EX-20; entity không gọi kho, P12 lõi mục 0.3) |
| UC-001 | 2.1.7 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // rejectRegistration (BR-98) | Ngoại lệ: DC-RegisterAccountService.RegisterAccount ném DuplicateCustomerError |
| UC-001 | 2.1.8 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // showRegistrationSuccess | Trả về: DC-RegisterAccountService.RegisterAccount trả CustomerId |
| UC-001 | 1*a.1 | AC-B-RegisterAccountForm | AC-C-RegisterAccountController | // cancelRegistration | Không có operation: chưa ghi dữ liệu nên trình duyệt chỉ bỏ biểu mẫu |
| UC-001 | 1*a.1.1 | AC-C-RegisterAccountController | AC-B-RegisterAccountForm | // showRegistrationCancelled | Không có (hiển thị ở trình duyệt) |
| UC-005 | 2.1.1a.4 | AC-B-BookTicketsForm (qua control) | AC-E-Customer | // authenticateCustomer | Khác lớp nhận: P10 F3 cơ chế Bảo mật: DC-LoginService.LoginCustomer(ctx Ctx, login string, plainPassword string) (IssuedSession, error), kiểm mật khẩu bằng IF-07.VerifyPassword |
| UC-017 | 1.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffCreation | DC-ManageStaffAccountsService.OpenStaffCreation(ctx Ctx) (StaffChoices, error) |
| UC-017 | 1.1.1, 1a.2.1.2 | AC-C-ManageStaffAccountsController | AC-E-Staff | // provideRoleChoices | DC-Staff.ProvideRoleChoices() []StaffRole (Classifier) |
| UC-017 | 1.1.2, 1a.2.1.3 | AC-C-ManageStaffAccountsController | AC-E-Cinema | // provideCinemaInfo | Khác lớp nhận: IF-13.ListCinemas rồi DC-Cinema.ProvideCinemaInfo() string (PKG-27, Chữ ký interface tạm) |
| UC-017 | 1.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffAccountChoices | Trả về: OpenStaffCreation trả StaffChoices |
| UC-017 | 2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // saveStaffAccount | DC-ManageStaffAccountsService.CreateStaffAccount(ctx Ctx, req NewStaffRequest) (StaffAccountView, error) |
| UC-017 | 2.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // draftStaff | DC-Staff.DraftStaff(email string, fullName string, passwordHash string, role StaffRole, cinemaId CinemaId, now time.Time) *Staff (gọi sau kiểm dữ liệu và băm, trong giao dịch) |
| UC-017 | 2.1.2 | AC-C-ManageStaffAccountsController | AC-E-Staff | // checkStaffData | DC-Staff.CheckStaffData(email string, fullName string, role StaffRole, cinemaId CinemaId) error (Classifier, chạy trước băm) |
| UC-017 | 2.1.3, 2.1.4, 2.1.5, 2.1.6, 1a.3.1.2, 1a.3.1.3, 1d.3.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount (Q-163, BR-79, BR-78) | Ngoại lệ: CreateStaffAccount, UpdateStaffAccess, RenameStaffAccount ném StaffDataError |
| UC-017 | 2.1.7 | AC-C-ManageStaffAccountsController | AC-E-Staff | // saveStaff | Khác lớp nhận: IF-08.LockValue(STAFF_EMAIL), IF-15.ExistsByEmail, IF-15.InsertStaff (P10 F3a EX-21) |
| UC-017 | 2.1.8 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount (BR-95) | Ngoại lệ: CreateStaffAccount ném DuplicateStaffEmailError |
| UC-017 | 2.1.9, 1a.1.1, 1a.2.1.1, 1a.3.1.6, 1b.1.1, 1c.1.1, 1d.1.1, 1e.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // provideStaffInfo | DC-Staff.ProvideStaffInfo() StaffInfo (qua DC-ManageStaffAccountsService.toView; danh sách qua IF-15.ListAccounts) |
| UC-017 | 2.1.9.1, 1a.1.1.1, 1a.2.1.1.1, 1a.3.1.6.1, 1b.1.1.1, 1c.1.1.1, 1d.1.1.1, 1e.1.1.1 | AC-E-Staff | AC-E-Cinema | // provideCinemaInfo | Khác lớp nhận: Staff không gọi Cinema (entity không gọi entity khác qua kho); DC-ManageStaffAccountsService.toView gọi IF-13.FindCinema rồi DC-Cinema.ProvideCinemaInfo() |
| UC-017 | 2.1.10, 1a.3.1.7 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showSavedStaffAccount | Trả về: CreateStaffAccount, UpdateStaffAccess trả StaffAccountView |
| UC-017 | 1a.1, 1b.1, 1c.1, 1d.1, 1e.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // startStaffAction | DC-ManageStaffAccountsService.ListStaffAccounts(ctx Ctx) ([]StaffAccountView, error) |
| UC-017 | 1a.1.2, 1b.1.2, 1c.1.2, 1d.1.2, 1e.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffList | Trả về: ListStaffAccounts trả []StaffAccountView |
| UC-017 | 1a.2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // openStaffForUpdate | DC-ManageStaffAccountsService.OpenStaffForUpdate(ctx Ctx, staffId StaffId) (StaffAccountView, StaffChoices, error) |
| UC-017 | 1a.2.1.4 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffForUpdate | Trả về: OpenStaffForUpdate trả StaffAccountView, StaffChoices |
| UC-017 | 1a.3.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // updateStaffAccount | DC-ManageStaffAccountsService.UpdateStaffAccess(ctx Ctx, staffId StaffId, expectedChangedAt time.Time, role Role, cinemaId CinemaId) (StaffAccountView, error) |
| UC-017 | 1a.3.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // checkStaffData (vai trò, cụm rạp) | DC-Staff.CheckRoleAndCinema(role StaffRole, cinemaId CinemaId) error (Classifier) |
| UC-017 | 1a.3.1.4 | AC-C-ManageStaffAccountsController | AC-E-Staff | // saveStaffChanges | DC-Staff.SaveStaffChanges(expectedChangedAt time.Time, role StaffRole, cinemaId CinemaId, now time.Time) error (sau IF-15.LockStaff, trước IF-15.SaveChanges) |
| UC-017 | 1a.3.1.5, 1b.2.1.3, 1c.2.1.3, 1d.3.1.3, 1e.3.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // rejectStaffAccount (BR-102) | Ngoại lệ: các operation ghi của DC-ManageStaffAccountsService ném StaleStaffError |
| UC-017 | 1b.2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // changeStaffStatus (khoá) | DC-ManageStaffAccountsService.LockStaffAccount(ctx Ctx, staffId StaffId, expectedChangedAt time.Time) error (tách theo kết quả, không tham số cờ) |
| UC-017 | 1c.2.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // changeStaffStatus (mở khoá) | DC-ManageStaffAccountsService.UnlockStaffAccount(ctx Ctx, staffId StaffId, expectedChangedAt time.Time) error |
| UC-017 | 1b.2.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // lockStaff | DC-Staff.LockStaff(expectedChangedAt time.Time, now time.Time) error |
| UC-017 | 1c.2.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // unlockStaff | DC-Staff.UnlockStaff(expectedChangedAt time.Time, now time.Time) error |
| UC-017 | 1b.2.1.2, 1c.2.1.2 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffStatusUnchanged | Ngoại lệ: LockStaffAccount, UnlockStaffAccount ném StaffStatusUnchangedError |
| UC-017 | 1b.2.1.4, 1c.2.1.4, 1d.3.1.4, 1e.3.1.3 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // notifyStaffChanged | Trả về: operation ghi trả error rỗng |
| UC-017 | 1d.3.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // renameStaffAccount | DC-ManageStaffAccountsService.RenameStaffAccount(ctx Ctx, staffId StaffId, expectedChangedAt time.Time, newFullName string) error |
| UC-017 | 1d.3.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // renameStaff | DC-Staff.RenameStaff(expectedChangedAt time.Time, newFullName string, now time.Time) error |
| UC-017 | 1e.3.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // resetStaffAccountPassword | DC-ManageStaffAccountsService.ResetStaffAccountPassword(ctx Ctx, staffId StaffId, expectedChangedAt time.Time, newPlainPassword string) error |
| UC-017 | 1e.3.1.1 | AC-C-ManageStaffAccountsController | AC-E-Staff | // resetStaffPassword | DC-Staff.ResetStaffPassword(expectedChangedAt time.Time, newPasswordHash string, now time.Time) error |
| UC-017 | 1*a.1 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | // cancelStaffRequest | Không có operation: chưa ghi dữ liệu nên trình duyệt chỉ bỏ biểu mẫu |
| UC-017 | 1*a.1.1 | AC-C-ManageStaffAccountsController | AC-B-ManageStaffAccountsForm | // showStaffRequestCancelled | Không có (hiển thị ở trình duyệt) |
| UC-005, UC-008, UC-009, UC-013, UC-014 | (tiền điều kiện) | AC-C-BookTicketsController và các control nhân viên | AC-E-Staff | // provideCinema (BoxOfficeClerk, TicketChecker, CinemaManager) | DC-Staff.CinemaId() CinemaId, kế thừa bởi DC-BoxOfficeClerk, DC-TicketChecker, DC-CinemaManager; cụm rạp hiện hành của yêu cầu lấy từ DC-AccessCheckService.CheckStaffAccess (StaffAccess.cinemaId) |

## F5. Bảng quan hệ

Quan hệ giữ mã P08: R-66, R-67, R-68, R-69. R-67 (DC-BoxOfficeClerk --> DC-Staff) có Lớp A ở PKG-28 nên do file lõi thiết kế; ở đây chỉ vẽ làm tham chiếu. Mã mới R-270 đến R-287.

| ID | Lớp A | Lớp B | Loại | Multiplicity | Điều hướng | Lý do | Vai trò | Căn cứ hiển thị |
|---|---|---|---|---|---|---|---|---|
| R-66 | DC-Staff | DC-Cinema | Association | A 0..* - B 0..1 | A --> B | Một nhân viên thuộc đúng một cụm rạp với ba vai trò, quản lý chuỗi không thuộc cụm rạp nào (BR-78, GL-41); cụm rạp không cần biết danh sách nhân viên vì tìm bằng truy vấn. Hiện thực bằng thuộc tính cinemaId (CinemaId, 0 là không có), không nạp đồ thị đối tượng (P12 lõi mục 0.3) | staff / cinema | field |
| R-68 | DC-TicketChecker | DC-Staff | Generalization | - | A --> B | Mọi nhân viên soát vé là một nhân viên (GL-36); lớp con chỉ khoá vai trò, thay thế được lớp cha | - | - |
| R-69 | DC-CinemaManager | DC-Staff | Generalization | - | A --> B | Mọi quản lý cụm rạp là một nhân viên (GL-42) | - | - |
| R-270 | DC-RegisterAccountService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-271 | DC-RegisterAccountService | IF-16 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-272 | DC-RegisterAccountService | IF-07 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-273 | DC-ManageStaffAccountsService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-274 | DC-ManageStaffAccountsService | IF-15 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-275 | DC-ManageStaffAccountsService | IF-13 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-276 | DC-ManageStaffAccountsService | IF-07 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-277 | DC-LoginService | IF-16 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-278 | DC-LoginService | IF-15 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-279 | DC-LoginService | IF-07 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-280 | DC-AccessCheckService | IF-08 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-281 | DC-AccessCheckService | IF-15 | Association | A 0..* - B 1 | A --> B | Thiết kế: tiêm phụ thuộc | - | field |
| R-282 | DC-RegisterAccountService | DC-Customer | Dependency | - | A --> B | Gọi CheckRegistrationData và DraftCustomer (Classifier), không giữ khách qua nhiều lời gọi | - | local |
| R-283 | DC-ManageStaffAccountsService | DC-Staff | Dependency | - | A --> B | Gọi CheckStaffData, DraftStaff, ProvideRoleChoices (Classifier) và các operation ghi trên Staff do IF-15.LockStaff trả | - | local |
| R-284 | DC-ManageStaffAccountsService | DC-RoleMapper | Dependency | - | A --> B | Đổi Role và StaffRole | - | local |
| R-285 | DC-LoginService | DC-Customer | Dependency | - | A --> B | Đọc ID và PasswordHash của khách do IF-16 trả | - | local |
| R-286 | DC-LoginService | DC-Staff | Dependency | - | A --> B | Đọc trạng thái, vai trò, cụm rạp, mốc và mã băm của nhân viên do IF-15 trả | - | local |
| R-287 | DC-AccessCheckService | DC-Staff | Dependency | - | A --> B | Gọi CheckAccessUnchanged trên Staff do IF-15 trả | - | local |

Quan hệ phụ khác chỉ qua chữ ký, không lập dòng riêng: DC-LoginService và DC-AccessCheckService dùng DC-RoleMapper và DC-AdministratorAccount, DC-SessionClaims, DC-IssuedSession (local, cùng cách R-284); IF-15 trả DC-Staff (cùng package, không tính, P12 lõi mục dưới F5). Realization IF-15 do DC-PgCinemaOperationsStore (PKG-21) hiện thực và DC-BoxOfficeClerk kế thừa DC-Staff (R-67) do lượt chứa Lớp A thiết kế (Vấn đề còn mở 2).

## F6. State machine

### ST-12. Tài khoản nhân viên (DC-Staff)

Lớp có hai trạng thái nhưng có BR dạng "chỉ được khoá khi đang hoạt động" và "chỉ mở khoá khi đang bị khoá" (BR-96, BR-97, luồng 1b3a, 1c3a), nên làm state machine gọn (Target 18). Sáu chuyển tự chuyển (STT 4 đến 9) là chuyển nội bộ (internal transition) của từng trạng thái, vẽ trong ngăn của trạng thái; ba chuyển giữa trạng thái (STT 1 đến 3) vẽ thành cạnh.

F6.1. Bảng trạng thái

| ST | Lớp | Trạng thái | Mô tả / điều kiện nhận biết | entry | do | exit |
|---|---|---|---|---|---|---|
| ST-12 | DC-Staff | Đang hoạt động | status = ACTIVE; đăng nhập được, phiên có mốc khớp accessChangedAt dùng được | - | - | - |
| ST-12 | DC-Staff | Bị khoá | status = LOCKED; không đăng nhập được (BR-97), mọi phiên đã cấp bị từ chối vì accessChangedAt lệch mốc (BR-101); dữ liệu liên quan và lần giữ ghế chưa kết thúc giữ nguyên (BR-96, BR-100) | - | - | - |

F6.2. Bảng chuyển trạng thái

| ST | Lớp | Trạng thái | Sự kiện | Guard | Hành động | Trạng thái đích | STT | Operation tương ứng | Nguồn |
|---|---|---|---|---|---|---|---|---|---|
| ST-12 | DC-Staff | (initial) | DraftStaff(email, fullName, passwordHash, role, cinemaId, now) | CheckStaffData đã đạt | status = ACTIVE; lastChangedAt = accessChangedAt = now | Đang hoạt động | 1 | DC-Staff.DraftStaff | UC-017 bước 4, 5; BR-95; EX-21 |
| ST-12 | DC-Staff | Đang hoạt động | LockStaff(expectedChangedAt, now) | lastChangedAt bằng expectedChangedAt | status = LOCKED; accessChangedAt = lastChangedAt = now | Bị khoá | 2 | DC-Staff.LockStaff | UC-017 1b3; BR-96, BR-97, BR-101, BR-102 |
| ST-12 | DC-Staff | Bị khoá | UnlockStaff(expectedChangedAt, now) | lastChangedAt bằng expectedChangedAt | status = ACTIVE; lastChangedAt = now | Đang hoạt động | 3 | DC-Staff.UnlockStaff | UC-017 1c3; BR-102 |
| ST-12 | DC-Staff | Đang hoạt động | SaveStaffChanges(expectedChangedAt, role, cinemaId, now) | lastChangedAt bằng expectedChangedAt | Ghi role, cinemaId; lastChangedAt = now; accessChangedAt = now nếu role hoặc cinemaId đổi | Đang hoạt động | 4 | DC-Staff.SaveStaffChanges | UC-017 luồng 1a, 5b; BR-100, BR-101, BR-102 |
| ST-12 | DC-Staff | Bị khoá | SaveStaffChanges(expectedChangedAt, role, cinemaId, now) | lastChangedAt bằng expectedChangedAt | Như chuyển 4 | Bị khoá | 5 | DC-Staff.SaveStaffChanges | UC-017 luồng 1a; BR-102 |
| ST-12 | DC-Staff | Đang hoạt động | RenameStaff(expectedChangedAt, newFullName, now) | newFullName không rỗng và lastChangedAt bằng expectedChangedAt | fullName = newFullName; lastChangedAt = now | Đang hoạt động | 6 | DC-Staff.RenameStaff | UC-017 1d4; Q-163, BR-102 |
| ST-12 | DC-Staff | Bị khoá | RenameStaff(expectedChangedAt, newFullName, now) | newFullName không rỗng và lastChangedAt bằng expectedChangedAt | Như chuyển 6 | Bị khoá | 7 | DC-Staff.RenameStaff | UC-017 1d4; BR-102 |
| ST-12 | DC-Staff | Đang hoạt động | ResetStaffPassword(expectedChangedAt, newPasswordHash, now) | lastChangedAt bằng expectedChangedAt | passwordHash = newPasswordHash; lastChangedAt = now | Đang hoạt động | 8 | DC-Staff.ResetStaffPassword | UC-017 1e4; BR-102 |
| ST-12 | DC-Staff | Bị khoá | ResetStaffPassword(expectedChangedAt, newPasswordHash, now) | lastChangedAt bằng expectedChangedAt | Như chuyển 8 | Bị khoá | 9 | DC-Staff.ResetStaffPassword | UC-017 1e4; BR-102 |

Không có trạng thái cuối: tài khoản chỉ bị khoá, không xoá (BR-96). Không có trạng thái trung gian nên không cần chuyển hồi phục (M7 mục 2): hai trạng thái đạt được từ nhau bằng LockStaff và UnlockStaff.

Sự kiện bị từ chối

| ST | Trạng thái | Sự kiện | Xử lý (bỏ qua / ngoại lệ) |
|---|---|---|---|
| ST-12 | Bị khoá | LockStaff | Ngoại lệ StaffStatusUnchangedError{LOCKED} (kiểm trước mốc, Q-312) |
| ST-12 | Đang hoạt động | UnlockStaff | Ngoại lệ StaffStatusUnchangedError{ACTIVE} |
| ST-12 | Đang hoạt động, Bị khoá | LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword khi lastChangedAt khác expectedChangedAt | Ngoại lệ StaleStaffError, không ghi gì (BR-102) |
| ST-12 | Đang hoạt động, Bị khoá | RenameStaff với họ tên rỗng | Ngoại lệ StaffDataError{FULL_NAME, Q-163}, kiểm trước mốc |
| ST-12 | Bị khoá | CheckAccessUnchanged | Ngoại lệ StaffAccessRevokedError (không đổi trạng thái; Đang hoạt động thì trả nil khi accessChangedAt khớp, khác thì cùng ngoại lệ) |

F6.3. Ánh xạ về mô hình lớp

| ST | Thuộc tính biểu diễn trạng thái | Kiểu (enumeration) | Operation được thêm/sửa |
|---|---|---|---|
| ST-12 | status | DC-StaffStatus (ACTIVE, LOCKED) | LockStaff, UnlockStaff, SaveStaffChanges, RenameStaff, ResetStaffPassword, CheckAccessUnchanged, Status() |

F6.4. Sơ đồ state machine ST-12 (file diagrams/P12-state-Staff.drawio)

| ID | Loại | Nhãn (tên + entry/do/exit) | Stereotype | Thuộc về | Ghi chú | x | y | w | h |
|---|---|---|---|---|---|---|---|---|---|
| ST-12-I | Initial | - | - | - | - | 410 | 60 | 40 | 40 |
| ST-12-S1 | State | Đang hoạt động; chuyển nội bộ: SaveStaffChanges [mốc khớp] / ghi role, cinemaId, lastChangedAt; RenameStaff [họ tên không rỗng, mốc khớp] / ghi fullName; ResetStaffPassword [mốc khớp] / ghi passwordHash | - | - | Chuyển nội bộ vẽ trong ngăn trạng thái (F6.2 STT 4, 6, 8) | 240 | 200 | 380 | 130 |
| ST-12-S2 | State | Bị khoá; chuyển nội bộ: SaveStaffChanges [mốc khớp] / ghi role, cinemaId, lastChangedAt; RenameStaff [họ tên không rỗng, mốc khớp] / ghi fullName; ResetStaffPassword [mốc khớp] / ghi passwordHash | - | - | Chuyển nội bộ vẽ trong ngăn trạng thái (F6.2 STT 5, 7, 9) | 900 | 200 | 380 | 130 |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| ST-12-T1 | ST-12-I | ST-12-S1 | Transition | DraftStaff / status = ACTIVE | F6.2 STT 1 | - |
| ST-12-T2 | ST-12-S1 | ST-12-S2 | Transition | LockStaff [mốc khớp] / status = LOCKED | F6.2 STT 2 | - |
| ST-12-T3 | ST-12-S2 | ST-12-S1 | Transition | UnlockStaff [mốc khớp] / status = ACTIVE | F6.2 STT 3 | - |

## F7. Bảng thuộc tính

| DC | Visibility | Tên | Kiểu | Multiplicity | Mặc định | Ràng buộc | Phạm vi | Derived | Nguồn | Mô tả |
|---|---|---|---|---|---|---|---|---|---|---|
| DC-Staff | - | id | StaffId | 1 | - | {id} | Instance | Không | P12 | Định danh, gán khi lưu |
| DC-Staff | - | email | string | 1 | - | {unique, readOnly, <= 254} | Instance | Không | AC-E-Staff; BR-95; Q-162, Q-273 | Email đăng nhập, duy nhất trên mọi vai trò (chỉ mục theo norm_email), không đổi sau khi tạo |
| DC-Staff | - | fullName | string | 1 | - | {không rỗng, <= 100} | Instance | Không | AC-E-Staff; Q-163, Q-273 | Họ tên |
| DC-Staff | - | passwordHash | string | 1 | - | - | Instance | Không | AC-E-Staff (password); NFR-02 | Mã băm một chiều; không lưu mật khẩu rõ |
| DC-Staff | - | role | StaffRole | 1 | - | {một trong bốn, BR-79} | Instance | Không | AC-E-Staff | Vai trò; quản lý chuỗi là giá trị của thuộc tính này |
| DC-Staff | - | status | StaffStatus | 1 | ACTIVE | - | Instance | Không | AC-E-Staff; ST-12 | Trạng thái tài khoản |
| DC-Staff | - | lastChangedAt | time.Time | 1 | - | - | Instance | Không | AC-E-Staff; BR-102 | Mốc thay đổi, so bằng ở mọi thao tác ghi (micro giây) |
| DC-Staff | - | accessChangedAt | time.Time | 1 | - | - | Instance | Không | AC-E-Staff; BR-101 | Mốc thay đổi quyền truy cập (khoá, đổi vai trò, đổi cụm rạp); so với mốc trong mã phiên |
| DC-LoginService | - | dummyPasswordHash | string | 1 | - | {readOnly} | Instance | Không | Thiết kế: cân bằng thời gian trả lời | Mã băm của mật khẩu ngẫu nhiên, tính một lần lúc khởi động; so khi không tìm thấy tài khoản |

Cụm rạp của nhân viên là association R-66 (thuộc tính cinemaId hiện thực R-66, không lặp ở bảng này). DC-CinemaManager, DC-TicketChecker không có thuộc tính riêng.

## F8. Class diagram

| Sơ đồ | Phạm vi (PKG / UC) | File .drawio | Số lớp |
|---|---|---|---|
| Lớp PKG-19 | PKG-19 AccountManagement (UC-001, UC-017, đăng nhập, kiểm phiên) | diagrams/P12-class-PKG-19.drawio | 9 (4 lớp của package, 5 interface tham chiếu) |
| Lớp PKG-32 | PKG-32 StaffAccounts | diagrams/P12-class-PKG-32.drawio | 6 (4 lớp của package, 2 tham chiếu) |

Dependency tới entity của package khác (R-282, R-283, R-285, R-286, R-287) và tới DC-RoleMapper (R-284) liệt kê ở F5, không vẽ ở sơ đồ PKG-19 theo Bước 6.1. DC-RoleMapper và kiểu phụ trợ không vẽ. IF-15 và DC-Staff không có cạnh vì quan hệ giữa interface kho và entity cùng package không tính là quan hệ riêng.

### Sơ đồ PKG-19

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú | x | y | w | h |
|---|---|---|---|---|---|---|---|---|---|
| DC-RegisterAccountService | Class | RegisterAccountService | «service» | PKG-19 | - | 40 | 45 | 840 | 110 |
| DC-ManageStaffAccountsService | Class | ManageStaffAccountsService | «service» | PKG-19 | - | 940 | 45 | 840 | 270 |
| DC-LoginService | Class | LoginService | «service» | PKG-19 | - | 1840 | 45 | 840 | 130 |
| DC-AccessCheckService | Class | AccessCheckService | «service» | PKG-19 | - | 2740 | 45 | 840 | 110 |
| IF-08 | Interface | IUnitOfWork | «interface» | PKG-27 | tham chiếu | 3640 | 40 | 320 | 60 |
| IF-16 | Interface | IHolderRepository | «interface» | PKG-28 | tham chiếu | 4020 | 40 | 320 | 60 |
| IF-07 | Interface | IAuthenticator | «interface» | PKG-26 | tham chiếu | 4400 | 40 | 320 | 60 |
| IF-15 | Interface | IStaffRepository | «interface» | PKG-32 | tham chiếu | 4780 | 40 | 320 | 60 |
| IF-13 | Interface | ICinemaRepository | «interface» | PKG-27 | tham chiếu | 5160 | 40 | 320 | 60 |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| R-270 | DC-RegisterAccountService | IF-08 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-271 | DC-RegisterAccountService | IF-16 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-272 | DC-RegisterAccountService | IF-07 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-273 | DC-ManageStaffAccountsService | IF-08 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-274 | DC-ManageStaffAccountsService | IF-15 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-275 | DC-ManageStaffAccountsService | IF-13 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-276 | DC-ManageStaffAccountsService | IF-07 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-277 | DC-LoginService | IF-16 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-278 | DC-LoginService | IF-15 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-279 | DC-LoginService | IF-07 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-280 | DC-AccessCheckService | IF-08 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |
| R-281 | DC-AccessCheckService | IF-15 | Association | A 0..* - B 1 | Thiết kế: tiêm phụ thuộc | - |

### Sơ đồ PKG-32

| ID | Loại | Nhãn | Stereotype | Thuộc về | Ghi chú | x | y | w | h |
|---|---|---|---|---|---|---|---|---|---|
| DC-Staff | Class | Staff | «entity» | PKG-32 | - | 40 | 40 | 1000 | 500 |
| DC-BoxOfficeClerk | Class | BoxOfficeClerk | «entity» | PKG-28 | tham chiếu | 40 | 640 | 240 | 60 |
| DC-CinemaManager | Class | CinemaManager | «entity» | PKG-32 | - | 360 | 645 | 380 | 90 |
| DC-TicketChecker | Class | TicketChecker | «entity» | PKG-32 | - | 800 | 645 | 380 | 90 |
| IF-15 | Interface | IStaffRepository | «interface» | PKG-32 | - | 40 | 790 | 1000 | 210 |
| DC-Cinema | Class | Cinema | «entity» | PKG-27 | tham chiếu | 1100 | 60 | 260 | 60 |

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| R-66 | DC-Staff | DC-Cinema | Association | A 0..* - B 0..1 (staff / cinema) | Cụm rạp của nhân viên | - |
| R-67 | DC-BoxOfficeClerk | DC-Staff | Generalization | - | Lớp con kế thừa lớp cha (thiết kế ở lõi) | - |
| R-69 | DC-CinemaManager | DC-Staff | Generalization | - | Lớp con kế thừa lớp cha | - |
| R-68 | DC-TicketChecker | DC-Staff | Generalization | - | Lớp con kế thừa lớp cha | - |

## F9. Gán package và kiểm tra phụ thuộc package

| PKG | Lớp (DC) | Phụ thuộc vào PKG (suy từ F5) | Hợp lệ theo P09 (Có / Không: lý do) |
|---|---|---|---|
| PKG-19 | DC-RegisterAccountService, DC-ManageStaffAccountsService, DC-LoginService, DC-AccessCheckService, DC-RoleMapper | PKG-26 (IF-07, DC-Role, DC-SessionClaims, DC-IssuedSession, DC-SubjectKind), PKG-27 (IF-08, IF-13, DC-Cinema, DC-TxOptions, DC-ValueLockKind, DC-NotFoundError, DC-SystemBusyError), PKG-28 (IF-16, DC-Customer), PKG-32 (DC-Staff, IF-15, kiểu của PKG-32) | Có: Application phụ thuộc Services (interface IF-07) và Domain, đều xuống dưới; đúng P10 F6 trừ PKG-19 --> PKG-21, xem dưới |
| PKG-32 | DC-Staff, DC-CinemaManager, DC-TicketChecker, IF-15 | PKG-27 (DC-CinemaIds, DC-Cinema qua R-66, DC-NotFoundError, DC-SystemBusyError, IF-25, Ctx) | Có: cùng layer Domain, một chiều (P10 F6 PKG-32 --> PKG-27); không phụ thuộc PKG-26 vì vai trò dùng DC-StaffRole |

Ghi chú kiểm tra: (1) Cạnh PKG-19 --> PKG-21 ở P10 F6 không có lớp nào trong PKG-19 dùng: mọi giao dịch đi qua IF-08 (PKG-27), và DC-LockOrderViolationError chỉ đi qua mà không được tham chiếu (Đề xuất sửa P10). (2) Nếu DC-Staff giữ vai trò bằng DC-Role của PKG-26 thì Domain phụ thuộc lên Services, vi phạm P09 F6; thiết kế dùng DC-StaffRole và DC-RoleMapper ở Application để tránh. (3) Visibility: kiểu public ở PKG-32 mà PKG-19, PKG-21, PKG-28 dùng: DC-Staff, DC-StaffRecord, DC-StaffInfo, DC-StaffRole, DC-StaffStatus, DC-StaffIds, DC-AdministratorAccount, IF-15, năm ngoại lệ; DC-CinemaManager, DC-TicketChecker public (P10 F5 đã có). Kiểu public ở PKG-19 mà PKG-11 dùng: bốn lớp dịch vụ và DC-NewStaffRequest, DC-StaffAccountView, DC-StaffChoices, DC-CinemaChoice, DC-StaffAccess, bốn ngoại lệ; DC-RoleMapper package-private. (4) Không có phụ thuộc vòng: PKG-28 --> PKG-32 --> PKG-27, PKG-19 --> PKG-32, PKG-19 --> PKG-28.

## F10. Design pattern đã áp dụng

| Pattern | Vấn đề trong thiết kế này | Lớp tham gia (vai trò trong pattern) | Lý do chọn | Phương án đơn giản hơn đã xét |
|---|---|---|---|---|
| Repository (Data Mapper) | Tách SQL khoá dòng theo hạng và đọc theo email chuẩn hoá khỏi quy tắc tài khoản | IF-15 (repository), DC-PgCinemaOperationsStore (hiện thực, PKG-21), DC-Staff (entity), DC-StaffRecord (bản ghi trung gian) | P09 F5 buộc entity phần lưu trữ là interface kho ở Domain; mỗi operation khoá đúng một hạng cố định để DC-LockOrderGuard kiểm được | Entity tự gọi SQL: vi phạm layer và không kiểm thứ tự khoá |
| Optimistic Offline Lock kết hợp khoá dòng | Hai quản trị viên cùng sửa một tài khoản từ màn hình đã hiển thị (BR-102): bên sau không được ghi đè | DC-Staff (so mốc lastChangedAt), IF-15.LockStaff (khoá hạng 4), DC-ManageStaffAccountsService (đặt thứ tự: khoá rồi so) | Mốc so dưới khoá nên kết quả thuộc một trạng thái duy nhất (P09 F7.3 EX-22); không cần cột phiên bản riêng vì lastChangedAt đã có | Chỉ khoá dòng (không so mốc): cho phép ghi đè dữ liệu cũ; chỉ so mốc khi không khoá: hai yêu cầu cùng thấy mốc khớp |

Không áp dụng State pattern cho ST-12: hai trạng thái và năm operation chỉ khác nhau ở hai guard, cài bằng if trên status đơn giản hơn.

## Xử lý mục chuyển từ bước trước

| Nguồn | Phần tử | Nội dung | Xử lý |
|---|---|---|---|
| _sync-log.md, mục Đầu vào cho lần chạy lại P08-P13, dòng P10, P12 | Dịch vụ tài khoản nhân viên, đăng ký | Lưu có kiểm phiên bản, email duy nhất, mật khẩu từ 8 ký tự, mở khoá, sửa họ tên, đặt lại mật khẩu (UC-001, UC-017; BR-98, BR-102) | Đã xử lý ở file này: DC-RegisterAccountService, DC-ManageStaffAccountsService (F2, F3) |
| _sync-log.md, dòng P10, P12 | Staff và lớp con | Lớp cha Staff, ba lớp con | Đã xử lý ở file này: DC-Staff, DC-CinemaManager, DC-TicketChecker (F1, F2, F6); DC-BoxOfficeClerk và createTicket, createBooking do lõi và lượt khác |
| P10 2.0 Đề xuất sửa artifact trước (dòng P12) | DC-LoginService, DC-AccessCheckService, IF-15 đọc mốc và đọc theo email | Thêm lớp, thao tác đọc mốc, đọc theo email, kiểm phiên theo mốc | Đã xử lý ở file này (F1, F2, F3) |
| P11b SS-05 2.0 | IF-07 | Chữ ký IssueSession, SessionClaims, HashPassword | File này dùng chữ ký P11b 2.0; lõi cập nhật bởi phiên khác (Chữ ký interface tạm) |

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-312 | Khi khoá hoặc mở khoá một tài khoản đã ở trạng thái đích và đồng thời bị yêu cầu khác đổi mốc, hoặc khi sửa họ tên rỗng và mốc đã lệch, báo lỗi nào trước: trạng thái không đổi (1b3a, 1c3a) và họ tên rỗng (1d4a), hay mốc đã đổi (BR-102)? | DC-Staff.LockStaff, UnlockStaff, RenameStaff; ST-12; P09 F7.3 EX-22; SCR-37, SCR-39 | P07 UC-017 (bước 1b3, 1c3, 1d4) và P04 kiểm trạng thái, họ tên trước rồi mới mốc; P09 F7.3 EX-22 ghi kiểm mốc trước rồi điều kiện riêng | Nhóm dự án | Theo P07 và P04: trạng thái hoặc họ tên trước, mốc sau. Cả hai kiểm dưới cùng khoá hạng 4 nên chỉ khác thông điệp, không khác tính đúng đắn; sửa câu EX-22 của P09 F7.3 cho khớp |
| Q-313 | Đặt lại mật khẩu của nhân viên có thu hồi phiên đang mở của nhân viên đó không? | DC-Staff.ResetStaffPassword; DC-ManageStaffAccountsService.ResetStaffAccountPassword; BR-101; P09 F7.3 EX-22 | BR-101 chỉ nêu khoá, đổi cụm rạp, đổi vai trò; P09 EX-22 không ghi accessChangedAt khi đặt lại mật khẩu; nghiệp vụ đặt lại thường nhằm chặn người đang dùng mật khẩu cũ | Bên nghiệp vụ | Không thu hồi (theo BR-101 và P09 EX-22); nếu muốn thu hồi chỉ cần ResetStaffPassword đặt accessChangedAt = now, không đổi chữ ký nào khác |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P12 lõi (P12-class-design.md) | DC-Customer, IF-16, IF-07 | Customer chưa có thao tác UC-001; IF-16 chưa có đọc theo đăng nhập, kiểm trùng, ghi khách; IF-07 còn chữ ký IssueSession cũ và chưa có HashPassword | Thêm theo bảng Chữ ký interface tạm của file này: DC-Customer.CheckRegistrationData, DraftCustomer, ID, PasswordHash và DC-CustomerDataError; IF-16.FindCustomerByLogin, FindTakenContact, InsertCustomer (23505 thành DuplicateCustomerError); IF-07 theo P11b SS-05 2.0 (HashPassword, IssueSession năm tham số, VerifySession trả SessionClaims có subjectKind, accessChangedAt); đối chiếu lại F4 khi có chữ ký chính thức |
| P12 lõi | DC-BoxOfficeClerk, DC-TicketingIds, EX-01 | BoxOfficeClerk còn tự giữ CinemaId() theo R-57 (đã thay bằng R-66, R-67); BoxOfficeClerkId tách khỏi StaffId; EX-01 của nhân viên quầy cần kiểm mốc dưới khoá hạng 4 | DC-BoxOfficeClerk nhúng DC-Staff (R-67) và bỏ CinemaId(); BoxOfficeClerkId là bí danh của StaffId (DC-StaffIds, PKG-32); sau IF-16.LockHolder với nhân viên quầy gọi DC-Staff.CheckAccessUnchanged(sessionAccessChangedAt) trước khi tạo lần giữ ghế (X-33); DC-ActorContext thêm accessChangedAt hoặc truyền riêng |
| P12 lõi | IF-08, DC-TxOptions, DC-ValueLockKind, IF-13, DC-Cinema | Chưa có LockValue, ReadOnlyTx, ValueLockKind (CUSTOMER_EMAIL, CUSTOMER_PHONE, STAFF_EMAIL, CINEMA_NAME), ListCinemas, FindCinema, ProvideCinemaInfo | Thêm theo Chữ ký interface tạm; DC-LockOrderGuard tính khoá giá trị hạng 11, 12, 13 theo P10 |
| P10 | F3, F5, F6 | Domain không được thấy PKG-26: DC-Staff dùng DC-StaffRole; cần phần tử mới và visibility; cạnh PKG-19 --> PKG-21 không có lớp dùng | Thêm DC-RoleMapper, DC-StaffRole, DC-StaffStatus, DC-StaffIds, DC-StaffInfo, DC-StaffRecord, DC-AdministratorAccount, các ngoại lệ PKG-32, DC-NewStaffRequest, DC-StaffAccountView, DC-StaffChoices, DC-CinemaChoice, DC-StaffAccess, DC-DuplicateCustomerError, DC-LoginFailedError, DC-StaffLockedError (F3, F4, F5 visibility theo F9 mục 3); xét bỏ cạnh PKG-19 --> PKG-21 (F6) |
| P09 | F7.3 (EX-22) | Thứ tự kiểm mốc rồi điều kiện riêng lệch P07 và P04 (Q-312) | Sửa câu EX-22 thành điều kiện riêng (trạng thái, họ tên) trước, mốc sau, hoặc ghi rõ hai thứ tự cho cùng kết quả đúng đắn |
| P13 | TBL-08, TBL-11, TBL-12, bảng quản trị viên | Ba bảng nhân viên theo vai trò không khớp một dòng Staff có vai trò; thiếu cột status, role, last_changed_at, access_changed_at, bảng quản trị viên (Q-271), chỉ mục unique theo norm_email trên mọi vai trò | Gộp thành một bảng staff (id, email, full_name, password_hash, role, cinema_id NULL, status, last_changed_at, access_changed_at) với chỉ mục unique theo norm_email(email); bảng administrator một dòng; DC-Staff, DC-CinemaManager, DC-TicketChecker, DC-BoxOfficeClerk ánh xạ cùng bảng staff; khoá ngoại seat_hold.box_office_clerk_id tới staff |
| X2 | DC-Staff, DC-ManageStaffAccountsService, DC-LoginService, DC-AccessCheckService | Chưa có ca thử | Thiết kế ca thử cho X-30 (hai đăng ký cùng email), X-31, X-32, X-33, thứ tự kiểm Q-312, mốc Equal ở micro giây, StaffLockedError chỉ sau mật khẩu đúng |

## Vấn đề còn mở

1. Phạm vi: 9 phần tử có hành vi, dưới ngưỡng 15 đến 20 nên chạy một lượt cho hai package liền kề; không chia hai lượt.
2. Quan hệ ngoài phạm vi thuộc lượt khác: R-67 (DC-BoxOfficeClerk --> DC-Staff, lớp A ở PKG-28) và realization IF-15 của DC-PgCinemaOperationsStore (PKG-21) do lượt chứa Lớp A thiết kế; mã R-67 đã giữ, realization cấp mã ở lượt PKG-21.
3. Thứ tự message P07 lệch: UC-001 msg 2.1.1 (draftCustomer) đứng trước 2.1.2 (checkRegistrationData) và UC-017 msg 2.1.1, 2.1.2 cùng thứ tự, trong khi thiết kế kiểm dữ liệu trước rồi băm rồi tạo đối tượng dự kiến (không tốn băm cho yêu cầu sai, không giữ mật khẩu rõ trong đối tượng). Hệ quả quan sát được không đổi (cùng lỗi, cùng thứ tự BR); không sửa P07.
4. DC-ManageStaffAccountsService có chín operation public và bốn phụ thuộc tiêm, trong ngưỡng 15 đến 20 operation; giữ một lớp vì cùng use case và cùng lý do thay đổi. Nếu X1 thấy quá lớn thì tách đọc (OpenStaffCreation, ListStaffAccounts, OpenStaffForUpdate) khỏi ghi (sáu operation còn lại).
5. Thiếu ở lớp ngoài phạm vi (Chữ ký interface tạm): operation của DC-Customer, IF-16, IF-07, IF-08, IF-13, DC-Cinema; F2, F4 dùng chữ ký tạm cho tới khi lõi và lượt PKG-27 có chữ ký chính thức.
6. Q-312, Q-313 chưa được trả lời: thiết kế theo đề xuất (kiểm trạng thái trước mốc; không thu hồi phiên khi đặt lại mật khẩu).
7. Q-271 theo đề xuất: tài khoản quản trị viên ở bảng riêng đọc qua IF-15.FindAdministratorByEmail; chưa có thao tác đổi mật khẩu quản trị vì UC-017 không áp dụng.
8. Mã không dùng: R-288 đến R-299, ST-13, ST-14, IF-35 đến IF-37, Q-314 đến Q-321.
9. Giao diện React (DC-LoginView, DC-RegisterAccountView, DC-ManageStaffAccountsView, DC-AccountController, DC-AuthFilter) chưa thiết kế ở file này; DC-AuthFilter gọi IF-07.VerifySession rồi DC-AccessCheckService.CheckStaffAccess và đổi StaffAccessRevokedError thành 401 (lượt PKG-11).
