# Sổ trách nhiệm AC - phần mới của UC-001

Sổ dùng chung ở trạng thái đầu lô không bị sửa; file này chỉ gồm dòng mới hoặc dòng được bổ sung trách nhiệm, thuộc tính (Conventions C10 mục 3). Phiên bản P07 của use case: 1.0.

## Bảng 1 - Trách nhiệm và thuộc tính

| AC | Stereotype | Tên | Trách nhiệm | Thuộc tính | UC dùng |
|---|---|---|---|---|---|
| AC-B-RegisterAccountForm | boundary | RegisterAccountForm | // requestRegistration: khách yêu cầu đăng ký tài khoản<br>// showRegistrationRequest: yêu cầu khách cung cấp email, số điện thoại, mật khẩu<br>// submitRegistrationData: khách cung cấp email, số điện thoại, mật khẩu rồi gửi<br>// rejectRegistration: thông báo từ chối đăng ký kèm quy tắc bị vi phạm<br>// showRegistrationSuccess: thông báo đăng ký thành công, khách đăng nhập riêng<br>// cancelRegistration: khách huỷ yêu cầu đăng ký<br>// showRegistrationCancelled: thông báo yêu cầu đã huỷ | registrationData (Email, số điện thoại, mật khẩu) | UC-001 |
| AC-C-RegisterAccountController | control | RegisterAccountController | // startRegistration: điều phối bước 2: tiếp nhận yêu cầu đăng ký rồi yêu cầu khách cung cấp thông tin<br>// registerAccount: điều phối bước 4 đến 8: tạo tài khoản khách dự kiến, kiểm tra dữ liệu, ghi nhận, báo thành công hoặc từ chối<br>// cancelRegistration: điều phối luồng *a: bỏ tài khoản dự kiến, báo yêu cầu đã huỷ | - | UC-001 |
| AC-E-Customer | entity | Customer | // draftCustomer: tạo tài khoản khách dự kiến, chưa ghi nhận, từ email, số điện thoại, mật khẩu khách gửi<br>// checkRegistrationData: kiểm tra theo thứ tự email theo định dạng email chuẩn (BR-81), số điện thoại 10 chữ số bắt đầu bằng 0 (BR-82), mật khẩu ít nhất 8 ký tự (BR-99); trả về hợp lệ hoặc điều kiện đầu tiên vi phạm<br>// saveCustomer: thao tác không chia cắt: kiểm tra email và số điện thoại chưa thuộc tài khoản khách nào khác (BR-98) rồi ghi nhận tài khoản dùng được ngay; trả về đã ghi nhận hoặc đã trùng | email (Văn bản), phoneNumber (Văn bản), password (Văn bản) | UC-001 |

## Bảng 2 - Điều kiện và sự kiện dùng chung

| Điều kiện hoặc sự kiện | Lớp chịu trách nhiệm (AC) | Trách nhiệm | Định nghĩa | UC dùng |
|---|---|---|---|---|
| Không có | - | - | Phiên không có điều kiện hoặc sự kiện nào mà từ hai use case trở lên cùng dựa vào | - |
