# P07 - Phân tích use case UC-017 Quản lý tài khoản nhân viên - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P07 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md (C10); 00-Concurrency.md (M3); project-profile.md; P04-uc-specs/UC-017-manage-staff-accounts.md 1.1; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P04-uc-specs/_BR-register.md (đầu lô); P07-uc-analysis/UC-005-book-tickets-analysis.md (sổ đăng ký AC: F1, F3.4, F8 b, Câu hỏi mở, Vấn đề còn mở; đầu lô) và UC-006, UC-008, UC-009, UC-013, UC-014 (F3.4); P08-analysis-model.md (tên AC-E-Cinema, Q-108); _sync-log.md (mục Đầu vào cho lần chạy lại P07-P13, dòng UC-017); dải mã được cấp Q-225 đến Q-234 |
| Phạm vi | UC-017 |
| Mã Q, ASM cuối đã cấp | Q-230 (Q-228, Q-229, Q-230 cấp ở use case này, Q-225 ở UC-001, Q-226 ở UC-007; trong dải Q-225 đến Q-234); không có ASM (NGHIEM_NGAT) |

## 1. Bối cảnh use case

| Thuộc tính | Giá trị |
|---|---|
| Mã và tên UC | UC-017 Quản lý tài khoản nhân viên (Manage Staff Accounts) |
| Tác nhân chính | ACT-06 Quản trị viên (Người) |
| Tác nhân phụ | Không có. Dịch vụ email (ACT-08) không tham gia vì quản trị viên giao mật khẩu cho nhân viên ngoài hệ thống (Q-161) |
| Include (UC) | Không có |
| Được include bởi (UC) | Không có |
| Extend (UC, điểm mở rộng, điều kiện) | Không có |
| Được extend bởi (UC, điểm mở rộng, điều kiện) | Không có |
| Use case liên quan không qua include, extend | UC-005 (nhân viên quầy giữ ghế, xác nhận thu tiền; BR-02, BR-04, BR-100), UC-009 (nhân viên soát vé; BR-22, BR-34), UC-013 và UC-014 (quản lý cụm rạp; BR-46, BR-61) dùng cụm rạp, vai trò và trạng thái của tài khoản do use case này tạo. UC-011 sở hữu khái niệm Cụm rạp. UC-001 có bài toán tương tự cho tài khoản khách (BR-98) |
| Tác nhân thời gian | Không có. P02 không có use case do tác nhân thời gian kích hoạt trên tài khoản nhân viên (P04 Mục 8), nên không có message hẹn mốc |
| File P07 đã có được dùng làm sổ đăng ký AC | UC-005-book-tickets-analysis.md. Các file UC-009, UC-013, UC-014 dùng để tra AC-E-TicketChecker, AC-E-CinemaManager; AC-E-BoxOfficeClerk ở UC-005. AC-E-Cinema lấy tên từ P08 (trạng thái Tạm, chủ sở hữu UC-011) |

## 2. Đặc tả bổ sung

| Bước UC | Thực hiện bởi | Mô tả trong đặc tả | Mô tả bổ sung (hệ thống làm gì bên trong) | Nguồn (BR, GL, REQ) |
|---|---|---|---|---|
| 1 | Quản trị viên | Yêu cầu tạo tài khoản cho một nhân viên mới | Không đổi | EV-19 |
| 2 | Hệ thống | Hiển thị các cụm rạp của chuỗi và bốn vai trò nhân viên để gán và phân quyền | Control lấy tên từng cụm rạp của chuỗi từ Cinema và bốn vai trò từ Staff rồi báo boundary hiển thị. | REQ-71, REQ-72, BR-79, Dữ liệu ra 1 |
| 3 | Quản trị viên | Nhập email, họ tên, chọn vai trò, cụm rạp rồi gửi | Không đổi | Dữ liệu vào 1 |
| 4 | Hệ thống | Kiểm tra email theo định dạng email chuẩn, họ tên không rỗng, đúng một vai trò, cụm rạp phù hợp vai trò | Control tạo tài khoản nhân viên dự kiến, chưa lưu, từ dữ liệu nhập. Tài khoản dự kiến kiểm tra theo thứ tự email, họ tên, đúng một vai trò, cụm rạp (không có cụm rạp với quản lý chuỗi, đúng một cụm rạp với ba vai trò còn lại) và dừng ở điều kiện đầu tiên vi phạm. | BR-78, BR-79, Q-163, Q-230 |
| 5 | Hệ thống | Kiểm tra email chưa thuộc tài khoản nhân viên nào khác và lưu tài khoản, trạng thái đang hoạt động, là một thao tác không chia cắt | Tài khoản dự kiến so email với mọi tài khoản nhân viên đã có, kể cả tài khoản vừa lưu cùng lúc, rồi tự lưu cùng mật khẩu ban đầu ở trạng thái đang hoạt động trong cùng thao tác. Thao tác ghi mốc thay đổi của tài khoản. | BR-95, BR-102, Q-161 |
| 6 | Hệ thống | Thông báo lưu thành công và hiển thị tài khoản đã lưu | Control lấy email, họ tên, vai trò, tên cụm rạp (hỏi Cinema), trạng thái của tài khoản vừa lưu rồi báo boundary hiển thị. | Dữ liệu ra 2 |
| 1a1 | Hệ thống | Hiển thị danh sách tài khoản nhân viên | Control duyệt từng tài khoản nhân viên, không gồm tài khoản quản trị viên, lấy email, họ tên, vai trò, cụm rạp, trạng thái rồi báo boundary hiển thị. Chọn tập tài khoản coi là có sẵn; không có đối tượng toàn thể nên control lặp. | REQ-70, REQ-103, Dữ liệu ra 3 |
| 1a2 | Quản trị viên | Chọn tài khoản nhân viên cần cập nhật | Không đổi | Dữ liệu vào 2 |
| 1a3 | Hệ thống | Hiển thị thông tin hiện tại của tài khoản cùng các cụm rạp và vai trò | Control lấy thông tin tài khoản đã chọn, bốn vai trò và tên từng cụm rạp rồi báo boundary hiển thị; tiếp tục bước 3 với vai trò và cụm rạp. | Dữ liệu ra 1, 2 |
| 1b1 | Hệ thống | Hiển thị danh sách tài khoản nhân viên | Như bước 1a1. | Dữ liệu ra 3 |
| 1b2 | Quản trị viên | Chọn tài khoản nhân viên cần khoá | Không đổi | Dữ liệu vào 2 |
| 1b3 | Hệ thống | Kiểm tra tài khoản đang hoạt động rồi đặt khoá, không xoá, giữ nguyên dữ liệu liên quan; một thao tác không chia cắt | Staff kiểm tài khoản đang hoạt động và chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị, đặt trạng thái bị khoá và ghi mốc thay đổi quyền truy cập để phiên đang mở của nhân viên không dùng tiếp được. Lần giữ ghế chưa kết thúc và dữ liệu liên quan tới nhân viên không bị chạm tới. | BR-96, BR-97, BR-100, BR-101, BR-102, Q-229 |
| 1b3a | Hệ thống | Thông báo tài khoản đã bị khoá; kết thúc use case (thất bại) | Kết quả khoá là tài khoản đã ở trạng thái bị khoá (kiểm trước 1b3b) thì control báo boundary thông báo; không đổi gì. | BR-102 |
| 1b3b | Hệ thống | Từ chối khoá, không ghi đè, thông báo BR-102; quay lại bước 1b1 | Kết quả khoá là tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị thì control báo boundary từ chối kèm quy tắc BR-102. | BR-102 |
| 1b4 | Hệ thống | Thông báo khoá tài khoản thành công; kết thúc use case (thành công) | Control báo boundary thông báo đã khoá. | - |
| 1c1 | Hệ thống | Hiển thị danh sách tài khoản nhân viên | Như bước 1a1. | Dữ liệu ra 3 |
| 1c2 | Quản trị viên | Chọn tài khoản nhân viên cần mở khoá | Không đổi | Dữ liệu vào 2 |
| 1c3 | Hệ thống | Kiểm tra tài khoản đang bị khoá rồi đặt đang hoạt động; một thao tác không chia cắt | Staff kiểm tài khoản đang bị khoá và chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị, đặt trạng thái đang hoạt động và ghi mốc thay đổi. | BR-102, Q-162 |
| 1c3a | Hệ thống | Thông báo tài khoản đang hoạt động; kết thúc use case (thất bại) | Kết quả mở khoá là tài khoản đang hoạt động (kiểm trước 1c3b) thì control báo boundary thông báo; không đổi gì. | BR-102 |
| 1c3b | Hệ thống | Từ chối mở khoá, thông báo BR-102; quay lại bước 1c1 | Như 1b3b với thao tác mở khoá. | BR-102 |
| 1c4 | Hệ thống | Thông báo mở khoá thành công; kết thúc use case (thành công) | Control báo boundary thông báo đã mở khoá. | - |
| 1d1 | Hệ thống | Hiển thị danh sách tài khoản nhân viên | Như bước 1a1. | Dữ liệu ra 3 |
| 1d2 | Quản trị viên | Chọn tài khoản nhân viên cần sửa họ tên | Không đổi | Dữ liệu vào 2 |
| 1d3 | Quản trị viên | Nhập họ tên mới và gửi | Không đổi | Dữ liệu vào 3 |
| 1d4 | Hệ thống | Kiểm tra họ tên không rỗng rồi lưu họ tên mới; một thao tác không chia cắt | Staff kiểm họ tên mới không rỗng (kiểm trước) và tài khoản chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị rồi lưu họ tên mới, ghi mốc thay đổi. | BR-102, Q-163 |
| 1d4a | Hệ thống | Từ chối lưu họ tên rỗng; quay lại bước 1d3 | Kết quả kiểm là họ tên rỗng thì control báo boundary từ chối kèm điều kiện bị vi phạm. | Q-163 |
| 1d4b | Hệ thống | Từ chối lưu, thông báo BR-102; quay lại bước 1d1 | Kết quả kiểm là tài khoản đã bị thay đổi thì control báo boundary từ chối kèm quy tắc BR-102. | BR-102 |
| 1d5 | Hệ thống | Thông báo sửa họ tên thành công; kết thúc use case (thành công) | Control báo boundary thông báo đã sửa họ tên. | - |
| 1e1 | Hệ thống | Hiển thị danh sách tài khoản nhân viên | Như bước 1a1. | Dữ liệu ra 3 |
| 1e2 | Quản trị viên | Chọn tài khoản nhân viên cần đặt lại mật khẩu | Không đổi | Dữ liệu vào 2 |
| 1e3 | Quản trị viên | Nhập mật khẩu mới và gửi; giao mật khẩu cho nhân viên ngoài hệ thống | Không đổi | Dữ liệu vào 4, Q-161 |
| 1e4 | Hệ thống | Lưu mật khẩu mới; một thao tác không chia cắt | Staff kiểm tài khoản chưa bị yêu cầu khác thay đổi kể từ lúc hiển thị rồi lưu mật khẩu mới, ghi mốc thay đổi. | BR-102, Q-162 |
| 1e4a | Hệ thống | Từ chối lưu, thông báo BR-102; quay lại bước 1e1 | Như 1b3b với thao tác đặt lại mật khẩu. | BR-102 |
| 1e5 | Hệ thống | Thông báo đặt lại mật khẩu thành công; kết thúc use case (thành công) | Control báo boundary thông báo đã đặt lại mật khẩu. | - |
| 4a | Hệ thống | Nhân viên không có đúng một vai trò: từ chối, thông báo BR-79; quay lại bước 3 | Kết quả kiểm là vai trò không hợp lệ thì control báo boundary từ chối kèm quy tắc BR-79; tài khoản dự kiến bị bỏ. | BR-79 |
| 4b | Hệ thống | Cụm rạp không phù hợp vai trò: từ chối, thông báo BR-78; quay lại bước 3 | Kết quả kiểm là cụm rạp không phù hợp vai trò thì control báo boundary từ chối kèm quy tắc BR-78. | BR-78 |
| 4c | Hệ thống | Email không theo định dạng email chuẩn: từ chối; quay lại bước 3 | Kết quả kiểm là email sai thì control báo boundary từ chối kèm điều kiện bị vi phạm. | Q-163 |
| 4d | Hệ thống | Họ tên rỗng: từ chối; quay lại bước 3 | Kết quả kiểm là họ tên rỗng thì control báo boundary từ chối kèm điều kiện bị vi phạm. | Q-163 |
| 5a | Hệ thống | Email đã thuộc tài khoản nhân viên khác: từ chối, thông báo BR-95; quay lại bước 3 | Kết quả lưu là email đã trùng thì không tạo tài khoản; control báo boundary từ chối kèm quy tắc BR-95. | BR-95 |
| 5b | Hệ thống | Chỉ khi theo luồng 1a: tài khoản đã bị yêu cầu khác thay đổi: từ chối, thông báo BR-102; quay lại bước 1a1 | Ở luồng 1a, Staff của tài khoản đã chọn kiểm chưa bị thay đổi kể từ lúc hiển thị và lưu vai trò, cụm rạp mới, ghi mốc thay đổi quyền truy cập khi vai trò hoặc cụm rạp đổi (BR-100, BR-101); email của chính tài khoản không bị coi là trùng. Kết quả đã bị thay đổi thì control báo boundary từ chối. | BR-102, BR-100, BR-101 |
| *a | Hệ thống | Huỷ yêu cầu, không thay đổi tài khoản nào; kết thúc use case (thất bại) | Control bỏ tài khoản dự kiến nếu đã tạo rồi báo boundary yêu cầu đã huỷ. Chưa có dữ liệu nào được ghi. | Mục 3 |

## 3. Tìm lớp phân tích

### 3.1 Bảng boundary

| Tác nhân (ACT) | Loại tác nhân | Boundary | Loại boundary | Mới hoặc tái dùng (AC, UC nguồn) | Lý do |
|---|---|---|---|---|---|
| ACT-06 Quản trị viên | Người | ManageStaffAccountsForm | Giao diện người dùng | Mới (AC-B-ManageStaffAccountsForm) | Quản trị viên chọn thao tác (tạo, cập nhật, khoá, mở khoá, sửa họ tên, đặt lại mật khẩu), nhập dữ liệu và nhận kết quả; một boundary cho tác nhân trong use case, không tách theo màn hình (P11a). |

Số boundary là 1, bằng số tác nhân tham gia (không có tác nhân phụ, không có tác nhân thời gian).

### 3.2 Bảng lọc danh từ

| STT | Danh từ hoặc cụm danh từ | Vị trí (bước UC, mục dữ liệu, BR) | Kết luận | Lý do |
|---|---|---|---|---|
| 1 | quản trị viên | 1, Tiền điều kiện; REQ-103 | Loại - là tác nhân hoặc ngoài phạm vi | ACT-06. Tài khoản quản trị viên có sẵn khi cài đặt, use case không tạo, sửa hay khoá (REQ-103). |
| 2 | nhân viên, tài khoản nhân viên | 1, 4, 5, 1a đến 1e; BR-95 | Entity AC-E-Staff | Hồ sơ tài khoản của người làm việc cho chuỗi, thông tin về nhân viên không phải bản thân người; hệ thống lưu vượt một lần thực hiện và có hành vi kiểm tra, lưu, khoá (GL-34). Mã mới, xem Q-228. |
| 3 | email | 3, 4, 5; BR-95; Dữ liệu vào 1 | Loại - thuộc tính của Staff | Định danh đăng nhập, duy nhất giữa tài khoản nhân viên (BR-95). |
| 4 | họ tên, họ tên mới | 3, 4, 1d3; Dữ liệu vào 1, 3 | Loại - thuộc tính của Staff | Không có hành vi riêng. |
| 5 | mật khẩu ban đầu, mật khẩu mới | 3, 1e3; Dữ liệu vào 1, 4 | Loại - thuộc tính của Staff | Q-161, Q-162. |
| 6 | vai trò, bốn vai trò, nhân viên quầy, nhân viên soát vé, quản lý cụm rạp, quản lý chuỗi | 2, 3, 4; BR-79 | Loại - thuộc tính của Staff | Giá trị của thuộc tính role; các entity theo vai trò đã có (BoxOfficeClerk, TicketChecker, CinemaManager) là lớp con theo đề xuất ở Q-228. |
| 7 | cụm rạp, các cụm rạp của chuỗi | 2, 4, 1a3; BR-78; Dữ liệu ra 1, 2 | Entity AC-E-Cinema | Hệ thống phải cung cấp tên từng cụm rạp để gán; khái niệm do UC-011 quản lý (GL-03). Mới - chủ sở hữu UC-011; tên theo P08. |
| 8 | trạng thái tài khoản, đang hoạt động, bị khoá | 5, 1b3, 1c3; BR-96, BR-97 | Loại - thuộc tính của Staff | Giá trị của thuộc tính status. |
| 9 | danh sách tài khoản nhân viên | 1a1, 1b1, 1c1, 1d1, 1e1; Dữ liệu ra 3 | Loại - cấu trúc cài đặt | Kết quả duyệt các Staff, không là khái niệm lưu riêng. |
| 10 | thời điểm hiển thị, tài khoản đã bị yêu cầu khác thay đổi | 1b3b, 1c3b, 1d4b, 1e4a, 5b; BR-102 | Loại - thuộc tính của Staff | Mốc thay đổi lastChangedAt của Staff; boundary giữ mốc đã hiển thị cùng tài khoản đã chọn và gửi kèm. |
| 11 | phiên làm việc, đăng nhập | Hậu điều kiện; BR-97, BR-101 | Loại - cấu trúc cài đặt | Đăng nhập không là use case (hồ sơ dự án Mục 4). Hiệu lực với phiên đang mở thể hiện bằng mốc accessChangedAt của Staff (Q-229). |
| 12 | lần giữ ghế | Hậu điều kiện; BR-100 | Loại - không tham gia hành vi của use case này | Khái niệm của UC-005; lần giữ ghế giữ nguyên, use case không đọc hay ghi. |
| 13 | vé đã bán, dữ liệu liên quan tới nhân viên | 1b3; BR-96 | Loại - không tham gia hành vi của use case này | Giữ nguyên, không bị chạm tới (khái niệm của UC-005). |
| 14 | tài khoản khách | BR-95 (phạm vi) | Loại - không tham gia hành vi của use case này | Khái niệm của UC-001; BR-95 chỉ xét tài khoản nhân viên. |
| 15 | yêu cầu khác, thao tác khoá, mở khoá, sửa, đặt lại | 1b3b, 1c3b, 1d4b, 1e4a | Loại - thao tác hoặc sự kiện | Sự kiện hoặc hành động của use case. |
| 16 | thông báo, quy tắc bị vi phạm, điều kiện bị vi phạm | 4a đến 4d, 5a, 5b, 1b3a, 1b4 | Loại - dữ liệu trao đổi qua boundary ManageStaffAccountsForm | Hiển thị, không lưu. |
| 17 | email thông báo mật khẩu, dịch vụ email | Q-161 | Loại - là tác nhân hoặc ngoài phạm vi | Quản trị viên giao mật khẩu ngoài hệ thống; ACT-08 không tham gia. |
| 18 | hệ thống, thông tin, dữ liệu | Nhiều bước | Loại - mơ hồ | Không là khái niệm nghiệp vụ cụ thể. |

### 3.3 Bảng control

| Control | Use case điều phối | Mới hoặc tái dùng | Lý do (hoặc lý do không có control) |
|---|---|---|---|
| ManageStaffAccountsController | UC-017 | Mới (AC-C-ManageStaffAccountsController) | Một control cho use case: điều phối tạo, cập nhật, khoá, mở khoá, sửa họ tên, đặt lại mật khẩu. Mọi quy tắc BR-78, BR-79, BR-95, BR-102 nằm ở Staff. Có 9 trách nhiệm, trong ngưỡng 2-10 vì use case gộp sáu thao tác; sáu thao tác dùng chung // startStaffAction và // changeStaffStatus để không vượt ngưỡng. |

### 3.4 Bảng lớp phân tích

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính chính | Bước UC nguồn | Loại boundary | Mới hoặc tái dùng | GL |
|---|---|---|---|---|---|---|---|---|
| AC-B-ManageStaffAccountsForm | boundary | ManageStaffAccountsForm | // requestCreateStaff: quản trị viên yêu cầu tạo tài khoản nhân viên<br>// requestUpdateStaff: quản trị viên chọn cập nhật cụm rạp hoặc vai trò<br>// requestLockStaff: quản trị viên chọn khoá tài khoản<br>// requestUnlockStaff: quản trị viên chọn mở khoá tài khoản<br>// requestRenameStaff: quản trị viên chọn sửa họ tên<br>// requestResetStaffPassword: quản trị viên chọn đặt lại mật khẩu<br>// showStaffAccountChoices: hiển thị các cụm rạp của chuỗi và bốn vai trò<br>// submitStaffData: quản trị viên nhập email, họ tên, mật khẩu ban đầu, chọn vai trò, cụm rạp rồi gửi<br>// submitRoleAndCinema: quản trị viên gửi vai trò và cụm rạp mới<br>// selectStaff: quản trị viên chọn tài khoản nhân viên, boundary giữ tài khoản và mốc thay đổi đã hiển thị<br>// showStaffList: hiển thị danh sách tài khoản nhân viên<br>// showStaffForUpdate: hiển thị thông tin hiện tại của tài khoản cùng các cụm rạp và vai trò<br>// submitNewFullName: quản trị viên nhập họ tên mới rồi gửi<br>// submitNewPassword: quản trị viên nhập mật khẩu mới rồi gửi<br>// rejectStaffAccount: thông báo từ chối kèm quy tắc hoặc điều kiện bị vi phạm<br>// showSavedStaffAccount: thông báo lưu thành công và hiển thị tài khoản đã lưu<br>// notifyStaffStatusUnchanged: thông báo tài khoản đã bị khoá hoặc đang hoạt động<br>// notifyStaffChanged: thông báo khoá, mở khoá, sửa họ tên hoặc đặt lại mật khẩu thành công<br>// cancelStaffRequest: quản trị viên huỷ yêu cầu<br>// showStaffRequestCancelled: thông báo yêu cầu đã huỷ | staffAccountData (Email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp), selectedStaff (Tài khoản nhân viên đã chọn kèm mốc thay đổi lúc hiển thị), newFullName (Văn bản), newPassword (Văn bản) | 1, 2, 3, 6, 1a, 1a1, 1a2, 1a3, 1b, 1b1, 1b2, 1b3a, 1b3b, 1b4, 1c, 1c1, 1c2, 1c3a, 1c3b, 1c4, 1d, 1d1, 1d2, 1d3, 1d4a, 1d4b, 1d5, 1e, 1e1, 1e2, 1e3, 1e4a, 1e5, 4a, 4b, 4c, 4d, 5a, 5b, *a | Giao diện người dùng | Mới | GL-43 |
| AC-C-ManageStaffAccountsController | control | ManageStaffAccountsController | // startStaffCreation: điều phối bước 2: lấy các cụm rạp của chuỗi và bốn vai trò để hiển thị<br>// startStaffAction: điều phối bước 1a1, 1b1, 1c1, 1d1, 1e1: duyệt các tài khoản nhân viên để hiển thị danh sách<br>// saveStaffAccount: điều phối bước 4 đến 6 và 4a đến 4d, 5a: tạo tài khoản dự kiến, kiểm tra, lưu, hiển thị tài khoản hoặc từ chối<br>// openStaffForUpdate: điều phối bước 1a3: lấy thông tin tài khoản đã chọn, vai trò, cụm rạp để cập nhật<br>// updateStaffAccount: điều phối bước 4 đến 6 trong luồng 1a: kiểm tra, lưu vai trò và cụm rạp mới hoặc từ chối (4a, 4b, 5b)<br>// changeStaffStatus: điều phối bước 1b3, 1c3 và các luồng 1b3a, 1b3b, 1b4, 1c3a, 1c3b, 1c4: khoá hoặc mở khoá rồi thông báo<br>// renameStaffAccount: điều phối bước 1d4 và các luồng 1d4a, 1d4b, 1d5<br>// resetStaffAccountPassword: điều phối bước 1e4 và các luồng 1e4a, 1e5<br>// cancelStaffRequest: điều phối luồng *a: bỏ tài khoản dự kiến, báo yêu cầu đã huỷ | - | 2, 4, 5, 6, 1a1, 1a3, 1b3, 1b3a, 1b3b, 1b4, 1c1, 1c3, 1c3a, 1c3b, 1c4, 1d1, 1d4, 1d4a, 1d4b, 1d5, 1e1, 1e4, 1e4a, 1e5, 4a, 4b, 4c, 4d, 5a, 5b, *a | - | Mới | - |
| AC-E-Staff | entity | Staff | // provideRoleChoices: cung cấp bốn vai trò nhân viên (BR-79)<br>// draftStaff: tạo tài khoản nhân viên dự kiến, chưa lưu, từ email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp<br>// checkStaffData: kiểm tra theo thứ tự email theo định dạng email chuẩn, họ tên không rỗng, đúng một vai trò, cụm rạp phù hợp vai trò (BR-78, BR-79, Q-163); trả về hợp lệ hoặc điều kiện đầu tiên vi phạm<br>// saveStaff: thao tác không chia cắt: kiểm tra email chưa thuộc tài khoản nhân viên nào khác (BR-95) rồi lưu tài khoản ở trạng thái đang hoạt động<br>// provideStaffInfo: cung cấp email, họ tên, vai trò, cụm rạp (hỏi Cinema), trạng thái để hiển thị<br>// saveStaffChanges: thao tác không chia cắt: kiểm tra tài khoản chưa bị thay đổi kể từ lúc hiển thị (BR-102), lưu vai trò và cụm rạp mới, ghi mốc thay đổi quyền truy cập (BR-100, BR-101)<br>// lockStaff: thao tác không chia cắt: kiểm tra tài khoản đang hoạt động rồi chưa bị thay đổi kể từ lúc hiển thị, đặt bị khoá, ghi mốc thay đổi quyền truy cập (BR-96, BR-97, BR-101, BR-102)<br>// unlockStaff: thao tác không chia cắt: kiểm tra tài khoản đang bị khoá rồi chưa bị thay đổi kể từ lúc hiển thị, đặt đang hoạt động (BR-102)<br>// renameStaff: thao tác không chia cắt: kiểm tra họ tên mới không rỗng rồi chưa bị thay đổi kể từ lúc hiển thị, lưu họ tên mới (Q-163, BR-102)<br>// resetStaffPassword: thao tác không chia cắt: kiểm tra chưa bị thay đổi kể từ lúc hiển thị, lưu mật khẩu mới (BR-102) | email (Văn bản), fullName (Văn bản), password (Văn bản), role (Vai trò), status (Trạng thái: đang hoạt động, bị khoá), cinema (Cụm rạp; không có khi vai trò là quản lý chuỗi), lastChangedAt (Ngày giờ), accessChangedAt (Ngày giờ) | 2, 4, 5, 6, 1a1, 1a3, 1b1, 1b3, 1c1, 1c3, 1d1, 1d4, 1e1, 1e4, 4a, 4b, 4c, 4d, 5a, 5b | - | Mới; hợp nhất BoxOfficeClerk, TicketChecker, CinemaManager theo đề xuất Q-228 | GL-34, GL-35, GL-36, GL-41, GL-42 |
| AC-E-Cinema | entity | Cinema | // provideCinemaName: cung cấp tên cụm rạp để hiển thị và gán cho nhân viên (BR-78) | name (Văn bản) | 2, 1a3, 6, 1a1 | - | Mới - chủ sở hữu UC-011; tên theo P08 | GL-03 |

Tổng cộng 4 lớp: 1 boundary, 1 control, 2 entity. Entity cốt lõi của chủ đề race condition: AC-E-Staff (// saveStaff theo email; // lockStaff và các thao tác lưu theo tài khoản, BR-95, BR-102).

## 4. Phân bổ hành vi

| Bước UC | Trách nhiệm | Lớp nhận (AC) | Nguyên tắc | Lý do khi có lựa chọn khác |
|---|---|---|---|---|
| 1 | // requestCreateStaff | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | - |
| 1a, 1b, 1c, 1d, 1e | // requestUpdateStaff, // requestLockStaff, // requestUnlockStaff, // requestRenameStaff, // requestResetStaffPassword | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | Mỗi luồng mở đầu bằng một lựa chọn riêng của quản trị viên (P04 D-1) nên mỗi lựa chọn một trách nhiệm của boundary. |
| 2 | // startStaffCreation | AC-C-ManageStaffAccountsController | Controller | - |
| 2, 1a3 | // provideCinemaName | AC-E-Cinema | Information Expert | Tên cụm rạp là dữ liệu của cụm rạp. Không có đối tượng toàn thể nắm tập cụm rạp của chuỗi nên control lặp [mỗi cụm rạp của chuỗi]. |
| 2, 1a3 | // provideRoleChoices | AC-E-Staff | Information Expert | Bốn vai trò là tập giá trị của thuộc tính role của nhân viên (BR-79). |
| 2, 1a3 | // showStaffAccountChoices, // showStaffForUpdate | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | - |
| 3 | // submitStaffData | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | Boundary chỉ nhận dữ liệu; kiểm tra điều kiện nghiệp vụ thuộc Staff (F3.4). |
| 3, 4, 5 | // saveStaffAccount | AC-C-ManageStaffAccountsController | Controller | - |
| 4 | // draftStaff | AC-E-Staff | Creator | Chưa có đối tượng toàn thể nắm các tài khoản nhân viên (Q-225); Staff tự tạo như Customer ở UC-001. |
| 4 | // checkStaffData | AC-E-Staff | Information Expert | Email, họ tên, vai trò, cụm rạp là dữ liệu của Staff. Đặt ở control thì control giữ quy tắc BR-78, BR-79 (god control). Một trách nhiệm theo thứ tự cố định để 4a đến 4d loại trừ nhau (Q-230). |
| 5 | // saveStaff | AC-E-Staff | Information Expert; thao tác không chia cắt | Dữ liệu cần so là email của mọi tài khoản nhân viên (Q-225). Kiểm rồi lưu trong một thao tác; chia thành hai message cho hai yêu cầu cùng email cùng thấy chưa trùng. |
| 6, 1a1, 1a3 | // provideStaffInfo | AC-E-Staff | Information Expert | Một trách nhiệm cho Dữ liệu ra 2 và 3; cụm rạp lấy qua Cinema (R-UC017-04). Danh sách tài khoản liệt kê trong loop của control vì không có đối tượng toàn thể. |
| 6 | // showSavedStaffAccount | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | - |
| 1a1, 1b1, 1c1, 1d1, 1e1 | // startStaffAction | AC-C-ManageStaffAccountsController | Controller | Một trách nhiệm cho năm luồng cùng hiển thị danh sách; kiểu thao tác truyền như dữ liệu. |
| 1a1, 1b1, 1c1, 1d1, 1e1 | // showStaffList | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | - |
| 1a2, 1b2, 1c2, 1d2, 1e2 | // selectStaff | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | Boundary giữ tài khoản đã chọn kèm mốc thay đổi lúc hiển thị và gửi kèm khi lưu (BR-102). |
| 1a3 | // openStaffForUpdate | AC-C-ManageStaffAccountsController | Controller | - |
| 3, 4, 5, 6 (luồng 1a) | // submitRoleAndCinema, // updateStaffAccount | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController | Giao tiếp tác nhân, Controller | Luồng 1a không nhập lại email, họ tên (Dữ liệu vào 1) nên có điều phối riêng thay vì dùng // saveStaffAccount. |
| 5, 5b (luồng 1a) | // saveStaffChanges | AC-E-Staff | Information Expert; thao tác không chia cắt | Kiểm mốc thay đổi và lưu trên cùng tài khoản trong một thao tác (BR-102). Mốc thay đổi quyền truy cập được ghi trong cùng thao tác khi vai trò hoặc cụm rạp đổi (BR-100, BR-101; Q-229). |
| 1b3 | // changeStaffStatus | AC-C-ManageStaffAccountsController | Controller | Dùng chung cho khoá (1b3) và mở khoá (1c3) vì cùng một dạng điều phối. |
| 1b3 | // lockStaff | AC-E-Staff | Information Expert; thao tác không chia cắt | Trạng thái tài khoản nằm ở Staff; kiểm rồi ghi trong một thao tác. Lần giữ ghế chưa kết thúc không bị gửi message (BR-100). |
| 1c3 | // unlockStaff | AC-E-Staff | Information Expert; thao tác không chia cắt | Đặt tên khác // lockStaff vì điều kiện (đang bị khoá) và kết quả khác. |
| 1b3a, 1c3a | // notifyStaffStatusUnchanged | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | Một trách nhiệm cho hai luồng, trạng thái truyền như dữ liệu. |
| 1b3b, 1c3b, 1d4b, 1e4a, 4a, 4b, 4c, 4d, 5a, 5b, 1d4a | // rejectStaffAccount | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | Một trách nhiệm cho mọi từ chối; quy tắc hoặc điều kiện truyền như dữ liệu. Quyết định rẽ nhánh dựa trên kết quả trả về của Staff. |
| 1b4, 1c4, 1d5, 1e5 | // notifyStaffChanged | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | Một trách nhiệm cho bốn thông báo thành công, loại thay đổi truyền như dữ liệu. |
| 1d3 | // submitNewFullName | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | - |
| 1d4 | // renameStaffAccount | AC-C-ManageStaffAccountsController | Controller | - |
| 1d4 | // renameStaff | AC-E-Staff | Information Expert; thao tác không chia cắt | Họ tên và mốc thay đổi là dữ liệu của Staff; kiểm họ tên trước rồi mốc thay đổi theo thứ tự P04. |
| 1e3 | // submitNewPassword | AC-B-ManageStaffAccountsForm | Giao tiếp tác nhân | - |
| 1e4 | // resetStaffAccountPassword | AC-C-ManageStaffAccountsController | Controller | - |
| 1e4 | // resetStaffPassword | AC-E-Staff | Information Expert; thao tác không chia cắt | Mật khẩu là dữ liệu của Staff; kiểm mốc thay đổi rồi lưu. |
| *a | // cancelStaffRequest, // showStaffRequestCancelled | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController | Giao tiếp tác nhân, Controller | Không có dữ liệu đã ghi nên không message tới entity; tài khoản dự kiến chỉ tồn tại trong lần thực hiện. |

Thao tác nguyên tử của P04 (00-Concurrency.md M3 mục 1):

| Thao tác (P04 Mục 8) | Bước | Lớp điều phối | Lớp tham gia | Điểm tuần tự |
|---|---|---|---|---|
| Kiểm tra email chưa trùng rồi lưu tài khoản nhân viên (tạo mới hoặc cập nhật) | 5 | AC-C-ManageStaffAccountsController | AC-E-Staff (// saveStaff, // saveStaffChanges) | Theo email trên toàn bộ tài khoản nhân viên (BR-95) và theo từng tài khoản (BR-102); cơ chế ở P09, P12 |
| Kiểm tra tài khoản đang hoạt động rồi đặt khoá | 1b3 | AC-C-ManageStaffAccountsController | AC-E-Staff (// lockStaff) | Theo từng tài khoản (BR-102); xen với bước 5 trên cùng tài khoản và với UC-005 bước 7 theo P04 Mục 8 |
| Mở khoá, sửa họ tên, đặt lại mật khẩu (P04 gắn BR-102 vào 1c3, 1d4, 1e4, không có dòng riêng) | 1c3, 1d4, 1e4 | AC-C-ManageStaffAccountsController | AC-E-Staff (// unlockStaff, // renameStaff, // resetStaffPassword) | Theo từng tài khoản (BR-102) |

## 5. Sequence diagram phân tích

File diagrams/P07-sequence-UC-017.drawio, 9 trang. Số message không kể trả về: SD1a 5, SD1b 13, SD2a 12, SD2b 10, SD3 11, SD4 11, SD5 12, SD6 11, SD7 3. Luồng chính tách SD1a (bước 1 đến 2), SD1b (bước 3 đến 6) theo đoạn bước để mỗi trang không quá 3 fragment ở mức ngoài cùng; luồng 1a tách SD2a, SD2b; luồng 1b, 1c, 1d, 1e mỗi luồng một trang; luồng *a vẽ ở SD7 theo F5 c. Luồng 1b3a, 1c3a kết thúc use case nên dùng break ở mức ngoài cùng.

### SD1a - Luồng chính bước 1 đến 2

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1a-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD1a-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD1a-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD1a-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD1a-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD1a-F1 | Fragment | loop [mỗi cụm rạp của chuỗi] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1 | :Quản trị viên | :ManageStaffAccountsForm | // requestCreateStaff | Đồng bộ | - | 1 |
| 1.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // startStaffCreation | Đồng bộ | - | 2 |
| 1.1.1 | :ManageStaffAccountsController | :Staff | // provideRoleChoices | Đồng bộ | - | 2 |
| 1.1.1 (trả về) | :Staff | :ManageStaffAccountsController | bốn vai trò nhân viên | Trả về | - | 2 |
| 1.1.2 | :ManageStaffAccountsController | :Cinema | // provideCinemaName | Đồng bộ | SD1a-F1 | 2 |
| 1.1.2 (trả về) | :Cinema | :ManageStaffAccountsController | tên cụm rạp | Trả về | SD1a-F1 | 2 |
| 1.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffAccountChoices (các cụm rạp của chuỗi, bốn vai trò) | Đồng bộ | - | 2 |

### SD1b - Luồng chính bước 3 đến 6 và luồng 4a, 4b, 4c, 4d, 5a

Luồng 4a, 4b, 4c, 4d, 5a quay lại bước 3 nên vẽ bằng alt. Thứ tự guard của F1 là thứ tự các điều kiện trong bước 4 của P04 (email, họ tên, vai trò, cụm rạp, Q-230). Tài khoản nhân viên dự kiến được tạo ở message 2.1.1 (loại Tạo).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD1b-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD1b-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD1b-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD1b-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff; tạo bởi message loại Tạo |
| SD1b-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD1b-F0 | Fragment | ref SD1a - Luồng chính bước 1 đến 2 | - | - | ref tới trang trước, mức ngoài cùng |
| SD1b-F1 | Fragment | alt [email không theo định dạng email chuẩn (4c)] | - | - | mức ngoài cùng |
| SD1b-F1-O2 | Fragment | [email đúng, họ tên rỗng (4d)] | - | SD1b-F1 | toán hạng 2 |
| SD1b-F1-O3 | Fragment | [email và họ tên đúng, nhân viên không có đúng một vai trò trong bốn vai trò (4a)] | - | SD1b-F1 | toán hạng 3 |
| SD1b-F1-O4 | Fragment | [nhân viên có đúng một vai trò, cụm rạp được gán không phù hợp vai trò (4b)] | - | SD1b-F1 | toán hạng 4 |
| SD1b-F1-O5 | Fragment | [dữ liệu tài khoản hợp lệ] | - | SD1b-F1 | toán hạng 5 |
| SD1b-F2 | Fragment | alt [email đã thuộc tài khoản nhân viên khác, kể cả khi tài khoản đó vừa được lưu cùng lúc bởi yêu cầu khác (5a)] | - | - | mức ngoài cùng |
| SD1b-F2-O2 | Fragment | [email chưa thuộc tài khoản nhân viên nào khác, tài khoản đã được lưu ở trạng thái đang hoạt động] | - | SD1b-F2 | toán hạng 2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 2 | :Quản trị viên | :ManageStaffAccountsForm | // submitStaffData (email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp) | Đồng bộ | - | 3 |
| 2.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // saveStaffAccount (email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp) | Đồng bộ | - | 3, 4, 5 |
| 2.1.1 | :ManageStaffAccountsController | :Staff | // draftStaff (email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp) | Tạo | - | 4 |
| 2.1.2 | :ManageStaffAccountsController | :Staff | // checkStaffData | Đồng bộ | - | 4 |
| 2.1.2 (trả về) | :Staff | :ManageStaffAccountsController | hợp lệ, hoặc điều kiện đầu tiên bị vi phạm (BR-78, BR-79, Q-163) | Trả về | - | 4 |
| 2.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (điều kiện email, Q-163) | Đồng bộ | SD1b-F1 | 4c |
| 2.1.4 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (điều kiện họ tên, Q-163) | Đồng bộ | SD1b-F1-O2 | 4d |
| 2.1.5 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-79) | Đồng bộ | SD1b-F1-O3 | 4a |
| 2.1.6 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-78) | Đồng bộ | SD1b-F1-O4 | 4b |
| 2.1.7 | :ManageStaffAccountsController | :Staff | // saveStaff | Đồng bộ | - | 5 |
| 2.1.7 (trả về) | :Staff | :ManageStaffAccountsController | đã lưu tài khoản, hoặc email đã thuộc tài khoản nhân viên khác | Trả về | - | 5 |
| 2.1.8 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-95) | Đồng bộ | SD1b-F2 | 5a |
| 2.1.9 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD1b-F2-O2 | 6 |
| 2.1.9.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD1b-F2-O2 | 6 |
| 2.1.9.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD1b-F2-O2 | 6 |
| 2.1.9 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD1b-F2-O2 | 6 |
| 2.1.10 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showSavedStaffAccount (tài khoản đã lưu) | Đồng bộ | SD1b-F2-O2 | 6 |

### SD2a - Luồng 1a bước 1a1 đến 1a3

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2a-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD2a-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD2a-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD2a-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD2a-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD2a-F1 | Fragment | loop [mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên] | - | - | mức ngoài cùng |
| SD2a-F2 | Fragment | loop [mỗi cụm rạp của chuỗi] | - | - | mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a | :Quản trị viên | :ManageStaffAccountsForm | // requestUpdateStaff | Đồng bộ | - | 1a |
| 1a.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // startStaffAction (cập nhật cụm rạp hoặc vai trò) | Đồng bộ | - | 1a1 |
| 1a.1.1 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD2a-F1 | 1a1 |
| 1a.1.1.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD2a-F1 | 1a1 |
| 1a.1.1.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD2a-F1 | 1a1 |
| 1a.1.1 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD2a-F1 | 1a1 |
| 1a.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffList (danh sách tài khoản nhân viên) | Đồng bộ | - | 1a1 |
| 1a.2 | :Quản trị viên | :ManageStaffAccountsForm | // selectStaff (tài khoản nhân viên cần cập nhật) | Đồng bộ | - | 1a2 |
| 1a.2.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // openStaffForUpdate (tài khoản đã chọn) | Đồng bộ | - | 1a3 |
| 1a.2.1.1 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | - | 1a3 |
| 1a.2.1.1.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | - | 1a3 |
| 1a.2.1.1.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | - | 1a3 |
| 1a.2.1.1 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái hiện tại | Trả về | - | 1a3 |
| 1a.2.1.2 | :ManageStaffAccountsController | :Staff | // provideRoleChoices | Đồng bộ | - | 1a3 |
| 1a.2.1.2 (trả về) | :Staff | :ManageStaffAccountsController | bốn vai trò nhân viên | Trả về | - | 1a3 |
| 1a.2.1.3 | :ManageStaffAccountsController | :Cinema | // provideCinemaName | Đồng bộ | SD2a-F2 | 1a3 |
| 1a.2.1.3 (trả về) | :Cinema | :ManageStaffAccountsController | tên cụm rạp | Trả về | SD2a-F2 | 1a3 |
| 1a.2.1.4 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffForUpdate (thông tin hiện tại, các cụm rạp, bốn vai trò) | Đồng bộ | - | 1a3 |

### SD2b - Luồng 1a bước 3 đến 6 và luồng 4a, 4b, 5b

Luồng 1a đi tiếp từ bước 3 đến 6 của luồng chính với dữ liệu chỉ gồm vai trò và cụm rạp (Dữ liệu vào 1 trường 4, 5), nên không có kiểm tra email và họ tên (4c, 4d); email của chính tài khoản không bị coi là trùng. Luồng 5b quay lại bước 1a1; 4a, 4b quay lại bước 3.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD2b-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD2b-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD2b-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD2b-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD2b-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD2b-F0 | Fragment | ref SD2a - Luồng 1a bước 1a1 đến 1a3 | - | - | ref tới trang trước, mức ngoài cùng |
| SD2b-F1 | Fragment | alt [nhân viên không có đúng một vai trò trong bốn vai trò (4a)] | - | - | mức ngoài cùng |
| SD2b-F1-O2 | Fragment | [nhân viên có đúng một vai trò, cụm rạp được gán không phù hợp vai trò (4b)] | - | SD2b-F1 | toán hạng 2 |
| SD2b-F1-O3 | Fragment | [dữ liệu hợp lệ] | - | SD2b-F1 | toán hạng 3 |
| SD2b-F2 | Fragment | alt [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (5b)] | - | - | mức ngoài cùng |
| SD2b-F2-O2 | Fragment | [tài khoản chưa bị thay đổi, vai trò và cụm rạp mới đã được lưu] | - | SD2b-F2 | toán hạng 2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1a.3 | :Quản trị viên | :ManageStaffAccountsForm | // submitRoleAndCinema (vai trò, cụm rạp) | Đồng bộ | - | 3 |
| 1a.3.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // updateStaffAccount (tài khoản đã chọn, vai trò, cụm rạp) | Đồng bộ | - | 3, 4, 5 |
| 1a.3.1.1 | :ManageStaffAccountsController | :Staff | // checkStaffData (vai trò, cụm rạp) | Đồng bộ | - | 4 |
| 1a.3.1.1 (trả về) | :Staff | :ManageStaffAccountsController | hợp lệ, hoặc điều kiện đầu tiên bị vi phạm (BR-78, BR-79) | Trả về | - | 4 |
| 1a.3.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-79) | Đồng bộ | SD2b-F1 | 4a |
| 1a.3.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-78) | Đồng bộ | SD2b-F1-O2 | 4b |
| 1a.3.1.4 | :ManageStaffAccountsController | :Staff | // saveStaffChanges (vai trò, cụm rạp) | Đồng bộ | - | 5 |
| 1a.3.1.4 (trả về) | :Staff | :ManageStaffAccountsController | đã lưu, hoặc tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị | Trả về | - | 5 |
| 1a.3.1.5 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-102) | Đồng bộ | SD2b-F2 | 5b |
| 1a.3.1.6 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD2b-F2-O2 | 6 |
| 1a.3.1.6.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD2b-F2-O2 | 6 |
| 1a.3.1.6.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD2b-F2-O2 | 6 |
| 1a.3.1.6 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD2b-F2-O2 | 6 |
| 1a.3.1.7 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showSavedStaffAccount (tài khoản đã lưu) | Đồng bộ | SD2b-F2-O2 | 6 |

### SD3 - Luồng 1b

Luồng 1b3a kết thúc use case nên vẽ bằng break ở mức ngoài cùng, đặt trước alt của luồng 1b3b (guard 1b3a kiểm trước, theo thứ tự của P04). Lần giữ ghế chưa kết thúc của nhân viên giữ nguyên (BR-100) nên không có message tới SeatHold; hiệu lực với phiên đang mở (BR-101) nằm trong // lockStaff.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD3-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD3-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD3-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD3-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD3-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD3-F1 | Fragment | loop [mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên] | - | - | mức ngoài cùng |
| SD3-F2 | Fragment | break [tài khoản đã chọn đã ở trạng thái bị khoá (1b3a)] | - | - | mức ngoài cùng |
| SD3-F3 | Fragment | alt [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1b3b)] | - | - | mức ngoài cùng |
| SD3-F3-O2 | Fragment | [tài khoản chưa bị thay đổi, đã được khoá] | - | SD3-F3 | toán hạng 2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1b | :Quản trị viên | :ManageStaffAccountsForm | // requestLockStaff | Đồng bộ | - | 1b |
| 1b.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // startStaffAction (khoá tài khoản) | Đồng bộ | - | 1b1 |
| 1b.1.1 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD3-F1 | 1b1 |
| 1b.1.1.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD3-F1 | 1b1 |
| 1b.1.1.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD3-F1 | 1b1 |
| 1b.1.1 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD3-F1 | 1b1 |
| 1b.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffList (danh sách tài khoản nhân viên) | Đồng bộ | - | 1b1 |
| 1b.2 | :Quản trị viên | :ManageStaffAccountsForm | // selectStaff (tài khoản nhân viên cần khoá) | Đồng bộ | - | 1b2 |
| 1b.2.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // changeStaffStatus (tài khoản đã chọn, khoá) | Đồng bộ | - | 1b3 |
| 1b.2.1.1 | :ManageStaffAccountsController | :Staff | // lockStaff | Đồng bộ | - | 1b3 |
| 1b.2.1.1 (trả về) | :Staff | :ManageStaffAccountsController | đã khoá; hoặc đã bị khoá từ trước; hoặc đã bị yêu cầu khác thay đổi kể từ lúc hiển thị | Trả về | - | 1b3 |
| 1b.2.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // notifyStaffStatusUnchanged (tài khoản đã bị khoá) | Đồng bộ | SD3-F2 | 1b3a |
| 1b.2.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-102) | Đồng bộ | SD3-F3 | 1b3b |
| 1b.2.1.4 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // notifyStaffChanged (đã khoá tài khoản) | Đồng bộ | SD3-F3-O2 | 1b4 |

### SD4 - Luồng 1c

Luồng 1c3a kết thúc use case nên vẽ bằng break ở mức ngoài cùng, trước alt của luồng 1c3b.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD4-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD4-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD4-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD4-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD4-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD4-F1 | Fragment | loop [mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên] | - | - | mức ngoài cùng |
| SD4-F2 | Fragment | break [tài khoản đã chọn đang hoạt động (1c3a)] | - | - | mức ngoài cùng |
| SD4-F3 | Fragment | alt [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1c3b)] | - | - | mức ngoài cùng |
| SD4-F3-O2 | Fragment | [tài khoản chưa bị thay đổi, đã được mở khoá] | - | SD4-F3 | toán hạng 2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1c | :Quản trị viên | :ManageStaffAccountsForm | // requestUnlockStaff | Đồng bộ | - | 1c |
| 1c.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // startStaffAction (mở khoá tài khoản) | Đồng bộ | - | 1c1 |
| 1c.1.1 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD4-F1 | 1c1 |
| 1c.1.1.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD4-F1 | 1c1 |
| 1c.1.1.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD4-F1 | 1c1 |
| 1c.1.1 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD4-F1 | 1c1 |
| 1c.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffList (danh sách tài khoản nhân viên) | Đồng bộ | - | 1c1 |
| 1c.2 | :Quản trị viên | :ManageStaffAccountsForm | // selectStaff (tài khoản nhân viên cần mở khoá) | Đồng bộ | - | 1c2 |
| 1c.2.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // changeStaffStatus (tài khoản đã chọn, mở khoá) | Đồng bộ | - | 1c3 |
| 1c.2.1.1 | :ManageStaffAccountsController | :Staff | // unlockStaff | Đồng bộ | - | 1c3 |
| 1c.2.1.1 (trả về) | :Staff | :ManageStaffAccountsController | đã mở khoá; hoặc đang hoạt động; hoặc đã bị yêu cầu khác thay đổi kể từ lúc hiển thị | Trả về | - | 1c3 |
| 1c.2.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // notifyStaffStatusUnchanged (tài khoản đang hoạt động) | Đồng bộ | SD4-F2 | 1c3a |
| 1c.2.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-102) | Đồng bộ | SD4-F3 | 1c3b |
| 1c.2.1.4 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // notifyStaffChanged (đã mở khoá tài khoản) | Đồng bộ | SD4-F3-O2 | 1c4 |

### SD5 - Luồng 1d

Luồng 1d4a quay lại bước 1d3 và 1d4b quay lại bước 1d1 nên gộp vào một alt theo kết quả của // renameStaff (họ tên được kiểm trước, theo thứ tự P04).

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD5-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD5-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD5-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD5-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD5-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD5-F1 | Fragment | loop [mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên] | - | - | mức ngoài cùng |
| SD5-F2 | Fragment | alt [họ tên mới rỗng (1d4a)] | - | - | mức ngoài cùng |
| SD5-F2-O2 | Fragment | [họ tên mới không rỗng, tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1d4b)] | - | SD5-F2 | toán hạng 2 |
| SD5-F2-O3 | Fragment | [họ tên mới đã được lưu] | - | SD5-F2 | toán hạng 3 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1d | :Quản trị viên | :ManageStaffAccountsForm | // requestRenameStaff | Đồng bộ | - | 1d |
| 1d.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // startStaffAction (sửa họ tên) | Đồng bộ | - | 1d1 |
| 1d.1.1 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD5-F1 | 1d1 |
| 1d.1.1.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD5-F1 | 1d1 |
| 1d.1.1.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD5-F1 | 1d1 |
| 1d.1.1 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD5-F1 | 1d1 |
| 1d.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffList (danh sách tài khoản nhân viên) | Đồng bộ | - | 1d1 |
| 1d.2 | :Quản trị viên | :ManageStaffAccountsForm | // selectStaff (tài khoản nhân viên cần sửa họ tên) | Đồng bộ | - | 1d2 |
| 1d.3 | :Quản trị viên | :ManageStaffAccountsForm | // submitNewFullName (họ tên mới) | Đồng bộ | - | 1d3 |
| 1d.3.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // renameStaffAccount (tài khoản đã chọn, họ tên mới) | Đồng bộ | - | 1d4 |
| 1d.3.1.1 | :ManageStaffAccountsController | :Staff | // renameStaff (họ tên mới) | Đồng bộ | - | 1d4 |
| 1d.3.1.1 (trả về) | :Staff | :ManageStaffAccountsController | đã lưu; hoặc họ tên rỗng; hoặc tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị | Trả về | - | 1d4 |
| 1d.3.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (điều kiện họ tên, Q-163) | Đồng bộ | SD5-F2 | 1d4a |
| 1d.3.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-102) | Đồng bộ | SD5-F2-O2 | 1d4b |
| 1d.3.1.4 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // notifyStaffChanged (đã sửa họ tên) | Đồng bộ | SD5-F2-O3 | 1d5 |

### SD6 - Luồng 1e

Mật khẩu mới không có điều kiện riêng ngoài bắt buộc nhập (Dữ liệu vào 4) nên chỉ có luồng 1e4a. Quản trị viên giao mật khẩu mới cho nhân viên ngoài hệ thống (Q-161) nên không có message gửi mật khẩu.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD6-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD6-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD6-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD6-L-SF | Lifeline | :Staff | «entity» | - | AC-E-Staff |
| SD6-L-CI | Lifeline | :Cinema | «entity» | - | AC-E-Cinema; chủ sở hữu UC-011 |
| SD6-F1 | Fragment | loop [mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên] | - | - | mức ngoài cùng |
| SD6-F2 | Fragment | alt [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1e4a)] | - | - | mức ngoài cùng |
| SD6-F2-O2 | Fragment | [mật khẩu mới đã được lưu] | - | SD6-F2 | toán hạng 2 |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1e | :Quản trị viên | :ManageStaffAccountsForm | // requestResetStaffPassword | Đồng bộ | - | 1e |
| 1e.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // startStaffAction (đặt lại mật khẩu) | Đồng bộ | - | 1e1 |
| 1e.1.1 | :ManageStaffAccountsController | :Staff | // provideStaffInfo | Đồng bộ | SD6-F1 | 1e1 |
| 1e.1.1.1 | :Staff | :Cinema | // provideCinemaName | Đồng bộ | SD6-F1 | 1e1 |
| 1e.1.1.1 (trả về) | :Cinema | :Staff | tên cụm rạp | Trả về | SD6-F1 | 1e1 |
| 1e.1.1 (trả về) | :Staff | :ManageStaffAccountsController | email, họ tên, vai trò, cụm rạp, trạng thái | Trả về | SD6-F1 | 1e1 |
| 1e.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffList (danh sách tài khoản nhân viên) | Đồng bộ | - | 1e1 |
| 1e.2 | :Quản trị viên | :ManageStaffAccountsForm | // selectStaff (tài khoản nhân viên cần đặt lại mật khẩu) | Đồng bộ | - | 1e2 |
| 1e.3 | :Quản trị viên | :ManageStaffAccountsForm | // submitNewPassword (mật khẩu mới) | Đồng bộ | - | 1e3 |
| 1e.3.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // resetStaffAccountPassword (tài khoản đã chọn, mật khẩu mới) | Đồng bộ | - | 1e4 |
| 1e.3.1.1 | :ManageStaffAccountsController | :Staff | // resetStaffPassword (mật khẩu mới) | Đồng bộ | - | 1e4 |
| 1e.3.1.1 (trả về) | :Staff | :ManageStaffAccountsController | đã lưu, hoặc tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị | Trả về | - | 1e4 |
| 1e.3.1.2 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // rejectStaffAccount (quy tắc BR-102) | Đồng bộ | SD6-F2 | 1e4a |
| 1e.3.1.3 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // notifyStaffChanged (đã đặt lại mật khẩu) | Đồng bộ | SD6-F2-O2 | 1e5 |

### SD7 - Luồng *a

Quản trị viên huỷ yêu cầu trước khi hệ thống lưu. Chưa có dữ liệu nào được ghi nên không có message hoàn tác; tài khoản nhân viên dự kiến nếu đã tạo thì bị bỏ.

b) Bảng lifeline

| ID | Loại (Actor / Lifeline / Fragment) | Nhãn | Stereotype | Thuộc về (container) | Ghi chú |
|---|---|---|---|---|---|
| SD7-L-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| SD7-L-FM | Lifeline | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| SD7-L-CT | Lifeline | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| SD7-F0 | Fragment | ref SD1b - Luồng chính bước 3 đến 6 | - | - | ref tới trang trước, mức ngoài cùng |

c) Bảng message

| STT | Từ | Đến | Message | Loại (Đồng bộ / Trả về / Tự gọi / Tạo) | Fragment | Bước UC |
|---|---|---|---|---|---|---|
| 1*a | :Quản trị viên | :ManageStaffAccountsForm | // cancelStaffRequest | Đồng bộ | - | *a |
| 1*a.1 | :ManageStaffAccountsForm | :ManageStaffAccountsController | // cancelStaffRequest | Đồng bộ | - | *a |
| 1*a.1.1 | :ManageStaffAccountsController | :ManageStaffAccountsForm | // showStaffRequestCancelled | Đồng bộ | - | *a |

## 6. Quy tắc tương tác giữa các lớp phân tích

| Vi phạm | Message hoặc link | Cách sửa đã áp dụng |
|---|---|---|
| Không có | - | - |

Ghi chú kiểm tra: Staff --> Cinema (CM1-L5, CM2-L4) là entity gọi entity có quan hệ cấu trúc (R-UC017-04). Control gọi trực tiếp Staff và Cinema (CM1-L3, CM1-L4, CM2-L3, CM2-L5). Boundary chỉ gọi control; quản trị viên chỉ gửi message tới boundary. Không có message tự gọi.

## 7. Communication diagram

File diagrams/P07-communication-UC-017.drawio, 2 trang: CM1 gồm luồng chính (SD1a, SD1b), CM2 gồm các luồng thay thế (SD2a đến SD7), MUC_CHI_TIET là DAY_DU, giữ STT của từng trang sequence.

### Trang CM1 - Luồng chính (SD1a, SD1b)

Luồng chính bước 1 đến 6 và luồng 4a, 4b, 4c, 4d, 5a, giữ STT của SD1a, SD1b. Message trả về không vẽ.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM1-O-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| CM1-O-FM | Object | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| CM1-O-CT | Object | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| CM1-O-SF | Object | :Staff | «entity» | - | AC-E-Staff |
| CM1-O-CI | Object | :Cinema | «entity» | - | AC-E-Cinema |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM1-L1 | CM1-O-QT | CM1-O-FM | Link | 1: // requestCreateStaff (-->)<br>2: // submitStaffData (email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp) (-->) | Nguồn-->Đích: 1, 2 |
| CM1-L2 | CM1-O-FM | CM1-O-CT | Link | 1.1: // startStaffCreation (-->)<br>1.1.3: // showStaffAccountChoices (các cụm rạp của chuỗi, bốn vai trò) (<--)<br>2.1: // saveStaffAccount (email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp) (-->)<br>2.1.3: // rejectStaffAccount (điều kiện email, Q-163) (<--) [email không theo định dạng email chuẩn (4c)]<br>2.1.4: // rejectStaffAccount (điều kiện họ tên, Q-163) (<--) [email đúng, họ tên rỗng (4d)]<br>2.1.5: // rejectStaffAccount (quy tắc BR-79) (<--) [email và họ tên đúng, nhân viên không có đúng một vai trò trong bốn vai trò (4a)]<br>2.1.6: // rejectStaffAccount (quy tắc BR-78) (<--) [nhân viên có đúng một vai trò, cụm rạp được gán không phù hợp vai trò (4b)]<br>2.1.8: // rejectStaffAccount (quy tắc BR-95) (<--) [email đã thuộc tài khoản nhân viên khác, kể cả khi tài khoản đó vừa được lưu cùng lúc bởi yêu cầu khác (5a)]<br>2.1.10: // showSavedStaffAccount (tài khoản đã lưu) (<--) [email chưa thuộc tài khoản nhân viên nào khác, tài khoản đã được lưu ở trạng thái đang hoạt động] | Nguồn-->Đích: 1.1, 2.1; Đích-->Nguồn: 1.1.3, 2.1.3, 2.1.4, 2.1.5, 2.1.6, 2.1.8, 2.1.10 |
| CM1-L3 | CM1-O-CT | CM1-O-SF | Link | 1.1.1: // provideRoleChoices (-->)<br>2.1.1: «create» // draftStaff (email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp) (-->)<br>2.1.2: // checkStaffData (-->)<br>2.1.7: // saveStaff (-->)<br>2.1.9: // provideStaffInfo (-->) [email chưa thuộc tài khoản nhân viên nào khác, tài khoản đã được lưu ở trạng thái đang hoạt động] | Nguồn-->Đích: 1.1.1, 2.1.1, 2.1.2, 2.1.7, 2.1.9 |
| CM1-L4 | CM1-O-CT | CM1-O-CI | Link | 1.1.2: // provideCinemaName (-->) [lặp: mỗi cụm rạp của chuỗi] | Nguồn-->Đích: 1.1.2 |
| CM1-L5 | CM1-O-SF | CM1-O-CI | Link | 2.1.9.1: // provideCinemaName (-->) [email chưa thuộc tài khoản nhân viên nào khác, tài khoản đã được lưu ở trạng thái đang hoạt động] | Nguồn-->Đích: 2.1.9.1 |

### Trang CM2 - Luồng 1a đến 1e và *a (SD2a đến SD7)

Mọi luồng thay thế còn lại (MUC_CHI_TIET là DAY_DU), giữ STT của SD2a đến SD7. Message trả về không vẽ.

a) Bảng Node

| ID | Loại (Actor / Object) | Nhãn | Stereotype | Thuộc về | Ghi chú |
|---|---|---|---|---|---|
| CM2-O-QT | Actor | :Quản trị viên | - | - | Tác nhân (ACT-06) |
| CM2-O-FM | Object | :ManageStaffAccountsForm | «boundary» | - | AC-B-ManageStaffAccountsForm |
| CM2-O-CT | Object | :ManageStaffAccountsController | «control» | - | AC-C-ManageStaffAccountsController |
| CM2-O-SF | Object | :Staff | «entity» | - | AC-E-Staff |
| CM2-O-CI | Object | :Cinema | «entity» | - | AC-E-Cinema |

b) Bảng Edge

| ID | Nguồn | Đích | Loại (Link) | Nhãn | Chiều message |
|---|---|---|---|---|---|
| CM2-L1 | CM2-O-QT | CM2-O-FM | Link | 1a: // requestUpdateStaff (-->)<br>1a.2: // selectStaff (tài khoản nhân viên cần cập nhật) (-->)<br>1a.3: // submitRoleAndCinema (vai trò, cụm rạp) (-->)<br>1b: // requestLockStaff (-->)<br>1b.2: // selectStaff (tài khoản nhân viên cần khoá) (-->)<br>1c: // requestUnlockStaff (-->)<br>1c.2: // selectStaff (tài khoản nhân viên cần mở khoá) (-->)<br>1d: // requestRenameStaff (-->)<br>1d.2: // selectStaff (tài khoản nhân viên cần sửa họ tên) (-->)<br>1d.3: // submitNewFullName (họ tên mới) (-->)<br>1e: // requestResetStaffPassword (-->)<br>1e.2: // selectStaff (tài khoản nhân viên cần đặt lại mật khẩu) (-->)<br>1e.3: // submitNewPassword (mật khẩu mới) (-->)<br>1*a: // cancelStaffRequest (-->) | Nguồn-->Đích: 1a, 1a.2, 1a.3, 1b, 1b.2, 1c, 1c.2, 1d, 1d.2, 1d.3, 1e, 1e.2, 1e.3, 1*a |
| CM2-L2 | CM2-O-FM | CM2-O-CT | Link | 1a.1: // startStaffAction (cập nhật cụm rạp hoặc vai trò) (-->)<br>1a.1.2: // showStaffList (danh sách tài khoản nhân viên) (<--)<br>1a.2.1: // openStaffForUpdate (tài khoản đã chọn) (-->)<br>1a.2.1.4: // showStaffForUpdate (thông tin hiện tại, các cụm rạp, bốn vai trò) (<--)<br>1a.3.1: // updateStaffAccount (tài khoản đã chọn, vai trò, cụm rạp) (-->)<br>1a.3.1.2: // rejectStaffAccount (quy tắc BR-79) (<--) [nhân viên không có đúng một vai trò trong bốn vai trò (4a)]<br>1a.3.1.3: // rejectStaffAccount (quy tắc BR-78) (<--) [nhân viên có đúng một vai trò, cụm rạp được gán không phù hợp vai trò (4b)]<br>1a.3.1.5: // rejectStaffAccount (quy tắc BR-102) (<--) [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (5b)]<br>1a.3.1.7: // showSavedStaffAccount (tài khoản đã lưu) (<--) [tài khoản chưa bị thay đổi, vai trò và cụm rạp mới đã được lưu]<br>1b.1: // startStaffAction (khoá tài khoản) (-->)<br>1b.1.2: // showStaffList (danh sách tài khoản nhân viên) (<--)<br>1b.2.1: // changeStaffStatus (tài khoản đã chọn, khoá) (-->)<br>1b.2.1.2: // notifyStaffStatusUnchanged (tài khoản đã bị khoá) (<--) [tài khoản đã chọn đã ở trạng thái bị khoá (1b3a)]<br>1b.2.1.3: // rejectStaffAccount (quy tắc BR-102) (<--) [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1b3b)]<br>1b.2.1.4: // notifyStaffChanged (đã khoá tài khoản) (<--) [tài khoản chưa bị thay đổi, đã được khoá]<br>1c.1: // startStaffAction (mở khoá tài khoản) (-->)<br>1c.1.2: // showStaffList (danh sách tài khoản nhân viên) (<--)<br>1c.2.1: // changeStaffStatus (tài khoản đã chọn, mở khoá) (-->)<br>1c.2.1.2: // notifyStaffStatusUnchanged (tài khoản đang hoạt động) (<--) [tài khoản đã chọn đang hoạt động (1c3a)]<br>1c.2.1.3: // rejectStaffAccount (quy tắc BR-102) (<--) [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1c3b)]<br>1c.2.1.4: // notifyStaffChanged (đã mở khoá tài khoản) (<--) [tài khoản chưa bị thay đổi, đã được mở khoá]<br>1d.1: // startStaffAction (sửa họ tên) (-->)<br>1d.1.2: // showStaffList (danh sách tài khoản nhân viên) (<--)<br>1d.3.1: // renameStaffAccount (tài khoản đã chọn, họ tên mới) (-->)<br>1d.3.1.2: // rejectStaffAccount (điều kiện họ tên, Q-163) (<--) [họ tên mới rỗng (1d4a)]<br>1d.3.1.3: // rejectStaffAccount (quy tắc BR-102) (<--) [họ tên mới không rỗng, tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1d4b)]<br>1d.3.1.4: // notifyStaffChanged (đã sửa họ tên) (<--) [họ tên mới đã được lưu]<br>1e.1: // startStaffAction (đặt lại mật khẩu) (-->)<br>1e.1.2: // showStaffList (danh sách tài khoản nhân viên) (<--)<br>1e.3.1: // resetStaffAccountPassword (tài khoản đã chọn, mật khẩu mới) (-->)<br>1e.3.1.2: // rejectStaffAccount (quy tắc BR-102) (<--) [tài khoản đã bị yêu cầu khác thay đổi kể từ lúc hiển thị (1e4a)]<br>1e.3.1.3: // notifyStaffChanged (đã đặt lại mật khẩu) (<--) [mật khẩu mới đã được lưu]<br>1*a.1: // cancelStaffRequest (-->)<br>1*a.1.1: // showStaffRequestCancelled (<--) | Nguồn-->Đích: 1a.1, 1a.2.1, 1a.3.1, 1b.1, 1b.2.1, 1c.1, 1c.2.1, 1d.1, 1d.3.1, 1e.1, 1e.3.1, 1*a.1; Đích-->Nguồn: 1a.1.2, 1a.2.1.4, 1a.3.1.2, 1a.3.1.3, 1a.3.1.5, 1a.3.1.7, 1b.1.2, 1b.2.1.2, 1b.2.1.3, 1b.2.1.4, 1c.1.2, 1c.2.1.2, 1c.2.1.3, 1c.2.1.4, 1d.1.2, 1d.3.1.2, 1d.3.1.3, 1d.3.1.4, 1e.1.2, 1e.3.1.2, 1e.3.1.3, 1*a.1.1 |
| CM2-L3 | CM2-O-CT | CM2-O-SF | Link | 1a.1.1: // provideStaffInfo (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1a.2.1.1: // provideStaffInfo (-->)<br>1a.2.1.2: // provideRoleChoices (-->)<br>1a.3.1.1: // checkStaffData (vai trò, cụm rạp) (-->)<br>1a.3.1.4: // saveStaffChanges (vai trò, cụm rạp) (-->)<br>1a.3.1.6: // provideStaffInfo (-->) [tài khoản chưa bị thay đổi, vai trò và cụm rạp mới đã được lưu]<br>1b.1.1: // provideStaffInfo (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1b.2.1.1: // lockStaff (-->)<br>1c.1.1: // provideStaffInfo (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1c.2.1.1: // unlockStaff (-->)<br>1d.1.1: // provideStaffInfo (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1d.3.1.1: // renameStaff (họ tên mới) (-->)<br>1e.1.1: // provideStaffInfo (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1e.3.1.1: // resetStaffPassword (mật khẩu mới) (-->) | Nguồn-->Đích: 1a.1.1, 1a.2.1.1, 1a.2.1.2, 1a.3.1.1, 1a.3.1.4, 1a.3.1.6, 1b.1.1, 1b.2.1.1, 1c.1.1, 1c.2.1.1, 1d.1.1, 1d.3.1.1, 1e.1.1, 1e.3.1.1 |
| CM2-L4 | CM2-O-SF | CM2-O-CI | Link | 1a.1.1.1: // provideCinemaName (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1a.2.1.1.1: // provideCinemaName (-->)<br>1a.3.1.6.1: // provideCinemaName (-->) [tài khoản chưa bị thay đổi, vai trò và cụm rạp mới đã được lưu]<br>1b.1.1.1: // provideCinemaName (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1c.1.1.1: // provideCinemaName (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1d.1.1.1: // provideCinemaName (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên]<br>1e.1.1.1: // provideCinemaName (-->) [lặp: mỗi tài khoản nhân viên, không gồm tài khoản quản trị viên] | Nguồn-->Đích: 1a.1.1.1, 1a.2.1.1.1, 1a.3.1.6.1, 1b.1.1.1, 1c.1.1.1, 1d.1.1.1, 1e.1.1.1 |
| CM2-L5 | CM2-O-CT | CM2-O-CI | Link | 1a.2.1.3: // provideCinemaName (-->) [lặp: mỗi cụm rạp của chuỗi] | Nguồn-->Đích: 1a.2.1.3 |

## 8. VOPC

File diagrams/P07-class-UC-017.drawio. ID cell của lớp là mã AC; ngăn thuộc tính và ngăn trách nhiệm có ID "<mã AC>-ATTR" và "<mã AC>-RESP".

a) Bảng Node (lớp)

| ID (mã AC) | Loại (Class) | Nhãn (tên lớp) | Stereotype | Thuộc về | Ngăn thuộc tính | Ngăn trách nhiệm |
|---|---|---|---|---|---|---|
| AC-B-ManageStaffAccountsForm | Class | ManageStaffAccountsForm | «boundary» | - | staffAccountData (Email, họ tên, mật khẩu ban đầu, vai trò, cụm rạp)<br>selectedStaff (Tài khoản nhân viên đã chọn kèm mốc thay đổi lúc hiển thị)<br>newFullName (Văn bản)<br>newPassword (Văn bản) | // requestCreateStaff<br>// requestUpdateStaff<br>// requestLockStaff<br>// requestUnlockStaff<br>// requestRenameStaff<br>// requestResetStaffPassword<br>// showStaffAccountChoices<br>// submitStaffData<br>// submitRoleAndCinema<br>// selectStaff<br>// showStaffList<br>// showStaffForUpdate<br>// submitNewFullName<br>// submitNewPassword<br>// rejectStaffAccount<br>// showSavedStaffAccount<br>// notifyStaffStatusUnchanged<br>// notifyStaffChanged<br>// cancelStaffRequest<br>// showStaffRequestCancelled |
| AC-C-ManageStaffAccountsController | Class | ManageStaffAccountsController | «control» | - | - | // startStaffCreation<br>// startStaffAction<br>// saveStaffAccount<br>// openStaffForUpdate<br>// updateStaffAccount<br>// changeStaffStatus<br>// renameStaffAccount<br>// resetStaffAccountPassword<br>// cancelStaffRequest |
| AC-E-Staff | Class | Staff | «entity» | - | email (Văn bản)<br>fullName (Văn bản)<br>password (Văn bản)<br>role (Vai trò: nhân viên quầy, nhân viên soát vé, quản lý cụm rạp, quản lý chuỗi)<br>status (Trạng thái: đang hoạt động, bị khoá)<br>cinema (Cụm rạp; không có khi vai trò là quản lý chuỗi)<br>lastChangedAt (Ngày giờ)<br>accessChangedAt (Ngày giờ) | // provideRoleChoices<br>// draftStaff<br>// checkStaffData<br>// saveStaff<br>// provideStaffInfo<br>// saveStaffChanges<br>// lockStaff<br>// unlockStaff<br>// renameStaff<br>// resetStaffPassword |
| AC-E-Cinema | Class | Cinema | «entity» | - | name (Văn bản) | // provideCinemaName |

b) Bảng quan hệ

| ID | Lớp A | Lớp B | Loại | Multiplicity | Vai trò | Nguồn |
|---|---|---|---|---|---|---|
| R-UC017-01 | AC-B-ManageStaffAccountsForm | AC-C-ManageStaffAccountsController | Association | - | - | tạm thời; link F7: CM1-L2, CM2-L2 |
| R-UC017-02 | AC-C-ManageStaffAccountsController | AC-E-Staff | Association | - | - | tạm thời; link F7: CM1-L3, CM2-L3 |
| R-UC017-03 | AC-C-ManageStaffAccountsController | AC-E-Cinema | Association | - | - | tạm thời; link F7: CM1-L4, CM2-L5 |
| R-UC017-04 | AC-E-Staff | AC-E-Cinema | Association | A 0..* - B 0..1 | - | Nhân viên quầy, nhân viên soát vé, quản lý cụm rạp thuộc đúng một cụm rạp, quản lý chuỗi không thuộc cụm rạp nào (BR-78, GL-34); phía A 0..* vì không có quy tắc giới hạn số nhân viên của một cụm rạp (Q-108 của P08); link F7: CM1-L5, CM2-L4 |

Link CM1-L1, CM2-L1 là actor - boundary nên không vào VOPC.

## 9. Ma trận truy vết

| Bước UC | Message (STT) | Lớp tham gia (AC) |
|---|---|---|
| 1 | 1 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 2 | 1.1, 1.1.1, 1.1.1 (trả về), 1.1.2, 1.1.2 (trả về), 1.1.3 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 3 | 2, 2.1 | Quản trị viên, AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController |
| 4 | 2.1, 2.1.1, 2.1.2, 2.1.2 (trả về) | AC-C-ManageStaffAccountsController, AC-E-Staff |
| 5 | 2.1.7, 2.1.7 (trả về) | AC-C-ManageStaffAccountsController, AC-E-Staff |
| 6 | 2.1.9, 2.1.9.1, 2.1.9.1 (trả về), 2.1.9 (trả về), 2.1.10 | AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema, AC-B-ManageStaffAccountsForm |
| 4a | 2.1.5 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 4b | 2.1.6 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 4c | 2.1.3 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 4d | 2.1.4 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 5a | 2.1.8 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1a | 1a | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1a1 | 1a.1, 1a.1.1, 1a.1.1.1, 1a.1.1.1 (trả về), 1a.1.1 (trả về), 1a.1.2 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 1a2 | 1a.2 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1a3 | 1a.2.1, 1a.2.1.1, 1a.2.1.1.1, 1a.2.1.1.1 (trả về), 1a.2.1.1 (trả về), 1a.2.1.2, 1a.2.1.2 (trả về), 1a.2.1.3, 1a.2.1.3 (trả về), 1a.2.1.4 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 3, 4, 5, 6 (luồng 1a) | 1a.3, 1a.3.1, 1a.3.1.1, 1a.3.1.1 (trả về), 1a.3.1.4, 1a.3.1.4 (trả về), 1a.3.1.6, 1a.3.1.6.1, 1a.3.1.6.1 (trả về), 1a.3.1.6 (trả về), 1a.3.1.7 | Quản trị viên, AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 4a, 4b (luồng 1a) | 1a.3.1.2, 1a.3.1.3 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 5b | 1a.3.1.5 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1b | 1b | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1b1 | 1b.1, 1b.1.1, 1b.1.1.1, 1b.1.1.1 (trả về), 1b.1.1 (trả về), 1b.1.2 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 1b2 | 1b.2 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1b3 | 1b.2.1, 1b.2.1.1, 1b.2.1.1 (trả về) | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff |
| 1b3a | 1b.2.1.2 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1b3b | 1b.2.1.3 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1b4 | 1b.2.1.4 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1c | 1c | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1c1 | 1c.1, 1c.1.1, 1c.1.1.1, 1c.1.1.1 (trả về), 1c.1.1 (trả về), 1c.1.2 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 1c2 | 1c.2 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1c3 | 1c.2.1, 1c.2.1.1, 1c.2.1.1 (trả về) | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff |
| 1c3a | 1c.2.1.2 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1c3b | 1c.2.1.3 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1c4 | 1c.2.1.4 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1d | 1d | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1d1 | 1d.1, 1d.1.1, 1d.1.1.1, 1d.1.1.1 (trả về), 1d.1.1 (trả về), 1d.1.2 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 1d2 | 1d.2 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1d3 | 1d.3 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1d4 | 1d.3.1, 1d.3.1.1, 1d.3.1.1 (trả về) | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff |
| 1d4a | 1d.3.1.2 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1d4b | 1d.3.1.3 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1d5 | 1d.3.1.4 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1e | 1e | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1e1 | 1e.1, 1e.1.1, 1e.1.1.1, 1e.1.1.1 (trả về), 1e.1.1 (trả về), 1e.1.2 | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff, AC-E-Cinema |
| 1e2 | 1e.2 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1e3 | 1e.3 | Quản trị viên, AC-B-ManageStaffAccountsForm |
| 1e4 | 1e.3.1, 1e.3.1.1, 1e.3.1.1 (trả về) | AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController, AC-E-Staff |
| 1e4a | 1e.3.1.2 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| 1e5 | 1e.3.1.3 | AC-C-ManageStaffAccountsController, AC-B-ManageStaffAccountsForm |
| *a | 1*a, 1*a.1, 1*a.1.1 | Quản trị viên, AC-B-ManageStaffAccountsForm, AC-C-ManageStaffAccountsController |

## 10. File .drawio

Ba file nằm trong diagrams/: P07-sequence-UC-017.drawio (9 trang), P07-communication-UC-017.drawio (2 trang), P07-class-UC-017.drawio (1 trang). XML không nén, ID cell trùng ID trong bảng mô hình.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-228 | Nhân viên có đúng một vvai trò trong bốn vai trò và đổi vai trò được ở luồng 1a (BR-79), nhưng sổ AC đã có ba entity riêng BoxOfficeClerk, TicketChecker, CinemaManager (mỗi lớp chỉ có cụm rạp) và chưa có lớp cho quản lý chuỗi (không thuộc cụm rạp, BR-78). Mô hình hoá thế nào: (A) một entity Staff chứa email, họ tên, mật khẩu, vai trò, trạng thái và cụm rạp không bắt buộc, ba entity hiện có thành lớp con theo vai trò, quản lý chuỗi là một giá trị của vai trò; hay (B) giữ bốn entity riêng và đổi vai trò là chuyển dữ liệu giữa hai entity? | AC-E-Staff; R-UC017-04; AC-E-BoxOfficeClerk, AC-E-TicketChecker, AC-E-CinemaManager; P08 F2 STT 41 (Q-108) | P05 GL-34, GL-35, GL-36, GL-41, GL-42 là các thuật ngữ riêng, P04 UC-017 luồng 1a đổi vai trò nhưng không nêu cách biểu diễn | Nhóm dự án | A: lớp cha Staff có cụm rạp 0..1, đổi vai trò là đổi giá trị thuộc tính role của cùng tài khoản; trả lời Q-108 của P08 là tạo lớp cha. Phân tích UC-017 dùng phương án này |
| Q-229 | Khoá tài khoản, đổi cụm rạp hoặc đổi vai trò có hiệu lực ngay với phiên đang mở (BR-101), nhưng mức phân tích không có entity phiên (đăng nhập không là use case). Staff ghi một mốc thay đổi quyền truy cập (accessChangedAt) để mọi use case của nhân viên đối chiếu với thời điểm đăng nhập của phiên, hay có entity phiên làm việc? | AC-E-Staff (accessChangedAt, // saveStaffChanges, // lockStaff); P09 (phiên đăng nhập); các use case của nhân viên UC-005, UC-009, UC-013, UC-014 | BR-101 nêu hiệu lực với phiên đang mở nhưng P05 không có thuật ngữ phiên | Nhóm dự án | Mốc accessChangedAt trong Staff; P09 chọn cơ chế kiểm phiên theo mốc; không thêm entity phiên ở P07 |
| Q-230 | Bước 4 nêu bốn điều kiện (email, họ tên, vai trò, cụm rạp) nhưng luồng 4a, 4b, 4c, 4d không nêu điều kiện loại trừ nhau khi nhiều điều kiện cùng vi phạm. Từ chối theo thứ tự nào? | SD1b F1; AC-E-Staff // checkStaffData; P04 luồng 4a đến 4d | Điều kiện của 4c và 4d không loại trừ với 4a, 4b | Nhóm dự án | Theo thứ tự trong bước 4: email (4c), họ tên (4d), vai trò (4a), cụm rạp (4b); mỗi điều kiện chỉ xét khi các điều kiện trước đã đúng |

## Giả định

Không có (chế độ NGHIEM_NGAT).

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P04 | UC-017 luồng 4a, 4b, 4c, 4d | Điều kiện bốn luồng không loại trừ nhau (Q-230) | Ghi điều kiện của từng luồng chỉ xét khi các điều kiện trước đã đúng, theo thứ tự 4c, 4d, 4a, 4b |
| P08 | AC-E-Staff (mới), AC-E-BoxOfficeClerk, AC-E-TicketChecker, AC-E-CinemaManager, AC-E-Cinema; R-57, R-58, R-59; F2 STT 41 | UC-017 cần lớp cha Staff (Q-228) và Cinema có tên cụm rạp | Thêm AC-E-Staff làm lớp cha ba entity theo vai trò, chuyển thuộc tính cinema lên Staff, thay R-57, R-58, R-59 bằng quan hệ Staff 0..* - Cinema 0..1; thêm // provideCinemaName vào AC-E-Cinema; trả lời Q-108; không tạo lớp riêng cho quản lý chuỗi (là giá trị của role) |
| P08 | F4a, F4b (đơn vị loại trừ) | Thao tác lưu tài khoản nhân viên (bước 5, luồng 1a), khoá (1b3), mở khoá, sửa họ tên, đặt lại mật khẩu (1c3, 1d4, 1e4) chưa có đơn vị loại trừ | Thêm đơn vị loại trừ lưu tài khoản nhân viên theo email trên toàn tập (BR-95) và theo từng tài khoản (BR-102); cặp loại trừ với chính nó và với UC-005 bước 7, UC-009, UC-013, UC-014 (hiệu lực BR-100, BR-101, Q-229) |
| P09 | Phiên đăng nhập, khoá tài khoản | Hiệu lực ngay với phiên đang mở (BR-101, Q-229) | Chọn cơ chế kiểm phiên theo mốc thay đổi quyền truy cập của Staff trước mỗi thao tác của nhân viên |
| P07 | UC-005, UC-009, UC-013, UC-014 (AC-E-BoxOfficeClerk, AC-E-TicketChecker, AC-E-CinemaManager // provideCinema) | Ba entity theo vai trò trở thành lớp con của Staff (Q-228); các use case của nhân viên chưa có message kiểm phiên còn hiệu lực (Q-229) | Khi chạy lại P07 của bốn use case, ghi lớp con của Staff và thêm kiểm phiên theo mốc thay đổi quyền truy cập trước thao tác đầu tiên của nhân viên |

## Vấn đề còn mở

- Số lớp là 4, trong khoảng 4-12. Control có 9 trách nhiệm, trong ngưỡng 2-10, không giữ quy tắc thuộc dữ liệu entity. Staff có 10 trách nhiệm hành vi (kiểm tra, lưu, khoá).
- Thao tác nguyên tử (M3 mục 1) có dòng ở F4. Bất biến BR-95 trải qua mọi tài khoản nhân viên (theo email), BR-102 theo từng tài khoản: điểm tuần tự theo từng đối tượng Staff là chưa đủ cho BR-95 (M3 mục 2). P08 xử lý bằng đơn vị loại trừ theo email và theo tài khoản (xem Đề xuất sửa artifact trước và Q-225).
- Control lặp [mỗi tài khoản nhân viên] và [mỗi cụm rạp của chuỗi] vì không có đối tượng toàn thể nắm hai tập này (A6). Nếu P08 thêm Chain hoặc thực thể quản lý chuỗi nắm tập cụm rạp thì chuyển trách nhiệm liệt kê cho thực thể đó.
- AC-E-Cinema thuộc UC-011 (chưa có P07 của UC-011 ở đầu lô), tên theo P08 F2a. Nếu phiên P07 của UC-011 cũng cấp AC-E-Cinema thì gộp ở bước sau theo C10; UC-017 chỉ dùng // provideCinemaName.
- Tài khoản nhân viên dự kiến (// draftStaff) chỉ tồn tại trong một lần thực hiện, chưa lưu, nên không là trạng thái dở dang (P04 Mục 8). Tài khoản quản trị viên không là entity ở P07 vì đăng nhập không là use case.
- Lần giữ ghế chưa kết thúc của nhân viên quầy giữ nguyên khi khoá, đổi cụm rạp hoặc đổi vai trò (BR-100): use case không gửi message tới SeatHold, việc kết thúc theo UC-005 (hết hạn hoặc xác nhận thu tiền). Việc chặn lần giữ ghế bắt đầu sau đó dựa vào kiểm tra vai trò, cụm rạp, trạng thái của nhân viên ở UC-005 và mốc thay đổi quyền truy cập (Q-229).
- Email của nhân viên không đổi sau khi tạo (Q-162) nên luồng 1a không có kiểm tra trùng email thực chất; // saveStaffChanges chỉ loại email của chính tài khoản khỏi phép so để giữ đúng P04 Mục 8.
- Khoá và cập nhật cùng lúc, hoặc hai quản trị viên cùng lưu một tài khoản: bên ghi nhận sau nhận kết quả đã bị thay đổi (BR-102) từ Staff, control chỉ rẽ nhánh theo kết quả.
