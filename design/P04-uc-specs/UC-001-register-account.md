# P04 - Đặc tả use case UC-001 Đăng ký tài khoản - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.0 |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M1); project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; _BR-register.md (đầu lô, đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; P06-supplementary-spec.md 1.3; UC-009-check-ticket.md 1.6 (mẫu định dạng); dải mã được cấp Q-155 đến 174, BR-94 đến 113 |
| Phạm vi | UC-001 |
| Mã Q, ASM cuối đã cấp | Q-158 (dải Q-155 đến 174 của lô, Q-155 đến Q-158 cấp ở use case này); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-001 |
| Tên use case | Đăng ký tài khoản (Register Account) |
| Tác nhân chính | ACT-01 Khách |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa khách và hệ thống khi khách chưa có tài khoản muốn tạo tài khoản bằng email, số điện thoại và mật khẩu. Kết quả là khách có tài khoản để đăng nhập và đặt vé. |
| Sự kiện kích hoạt | Khách muốn có tài khoản (EV-01) |
| Tiền điều kiện | Không có |
| Hậu điều kiện (thành công) | Một tài khoản khách mới tồn tại với email, số điện thoại và mật khẩu khách đã cung cấp; email đúng định dạng email chuẩn (BR-81) và số điện thoại đúng định dạng số điện thoại Việt Nam (BR-82).<br>Tài khoản dùng được để đăng nhập bằng email hoặc số điện thoại cùng mật khẩu đó (REQ-12; xác minh trước khi dùng: Q-157). |
| Hậu điều kiện tối thiểu | Khi use case kết thúc không thành công ở luồng *a, không có tài khoản nào được tạo hoặc thay đổi; các luồng 4a, 5a quay lại bước 3 cũng không tạo tài khoản.<br>Khi kết thúc ở luồng 6a: kết cục chờ Q-155. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-11 (theo P02); REQ-107, REQ-108 (P02 Mục 5 đã gắn UC-001); REQ-12 (đăng nhập; P02 ghi "-"); REQ-13 (tham chiếu, UC-005); REQ-31, REQ-80, REQ-90 (tham chiếu, UC-005, UC-006); REQ-77 (ràng buộc; P02 ghi "-") |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Khách | Yêu cầu đăng ký tài khoản. |
| 2 | Hệ thống | Yêu cầu khách cung cấp email, số điện thoại và mật khẩu. |
| 3 | Khách | Cung cấp email, số điện thoại và mật khẩu rồi gửi (xem Dữ liệu vào 1). |
| 4 | Hệ thống | Kiểm tra email theo định dạng email chuẩn (BR-81). |
| 5 | Hệ thống | Kiểm tra số điện thoại là số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0 (BR-82). |
| 6 | Hệ thống | Tạo tài khoản khách gắn với email, số điện thoại và mật khẩu đã cung cấp (email, số điện thoại đã thuộc tài khoản khác: Q-155; điều kiện hợp lệ của mật khẩu: Q-156; xác minh email hoặc số điện thoại: Q-157). |
| 7 | Hệ thống | Thông báo đăng ký thành công cho khách (cách khách bắt đầu phiên làm việc sau khi đăng ký: Q-158). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 4a | Email không đúng định dạng email chuẩn, kể cả khi để trống (BR-81) | Hệ thống | Từ chối đăng ký và thông báo quy tắc bị vi phạm (BR-81). | Quay lại bước 3 |
| 5a | Email đúng định dạng và số điện thoại không đúng định dạng số điện thoại Việt Nam, kể cả khi để trống (BR-82) | Hệ thống | Từ chối đăng ký và thông báo quy tắc bị vi phạm (BR-82). | Quay lại bước 3 |
| 6a | Email hoặc số điện thoại đã thuộc một tài khoản khách khác (Q-155), không thuộc 4a, 5a | - | - | Chờ Q-155 |
| *a | Tại bất kỳ bước nào trước bước 6, khách huỷ yêu cầu đăng ký | Hệ thống | Huỷ yêu cầu đăng ký, không tạo tài khoản. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Email | Địa chỉ email của khách, dùng để đăng ký và đăng nhập (REQ-11, REQ-12) | Có | Theo định dạng email chuẩn (BR-81); tính duy nhất giữa các tài khoản khách: Chưa quy định (Q-155) | khach.nguyen@example.com |
| 2 | Số điện thoại | Số điện thoại của khách, dùng để đăng ký và đăng nhập (REQ-11, REQ-12) | Có | Số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0 (BR-82); tính duy nhất giữa các tài khoản khách: Chưa quy định (Q-155) | 0912345678 |
| 3 | Mật khẩu | Mật khẩu của tài khoản khách, dùng cùng email hoặc số điện thoại để đăng nhập (REQ-11, REQ-12) | Có | Chưa quy định (Q-156) | CineBook@2026 |

Dữ liệu ra: Không có

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-81 | Email dùng để đăng ký và đăng nhập tài khoản khách theo định dạng email chuẩn. | Ràng buộc | 4, 4a, Dữ liệu vào 1 | REQ-107; REQ-11 (phụ) | Đã có |
| BR-82 | Số điện thoại dùng để đăng ký và đăng nhập tài khoản khách là số Việt Nam gồm 10 chữ số, bắt đầu bằng chữ số 0. | Ràng buộc | 5, 5a, Dữ liệu vào 1 | REQ-108; REQ-11 (phụ) | Đã có |

Use case này không cấp BR mới. Tính duy nhất của email, số điện thoại và chính sách mật khẩu chưa được nguồn quy định, nên chưa thành BR (Q-155, Q-156).

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-01 Khách, tác nhân chính duy nhất; use case không có tác nhân phụ. Dịch vụ email (ACT-08) không tham gia vì nguồn chỉ cho dịch vụ email gửi email chứa vé và email thông báo hoàn tiền (REQ-80, REQ-31, REQ-90). Nếu Q-157 được trả lời là có xác minh email thì P02, P03 phải thêm ACT-08 vào use case này và luồng chính thêm bước gửi và bước nhận kết quả xác minh.
- Đăng nhập không là use case (project-profile.md Mục 4; P02 UC-002 ở trạng thái Loại). Use case này chỉ tạo tài khoản; khách đăng nhập bằng email hoặc số điện thoại cùng mật khẩu theo REQ-12, và phải đăng nhập mới đặt vé (REQ-13, UC-005).
- Dữ liệu đăng ký chỉ gồm email, số điện thoại và mật khẩu (REQ-11). Nguồn không nêu họ tên hay thông tin khác của khách nên use case không thu thập thêm.
- Bước 4 và bước 5 là hai bước kiểm tra tách nhau để điều kiện của luồng 4a và 5a loại trừ lẫn nhau khi cả hai trường cùng sai (F5.3). Thứ tự email trước, số điện thoại sau theo thứ tự xuất hiện trong nguồn ("bằng email, số điện thoại và mật khẩu", Mục 3). Giá trị để trống được tính là không đúng định dạng.
- Luồng 4a và 5a: nguồn nêu định dạng (REQ-107, REQ-108) nhưng không nêu phản hồi khi vi phạm, nên theo F5.7 hệ thống từ chối và thông báo quy tắc bị vi phạm; quay lại bước 3 vì khách sửa được dữ liệu.
- Luồng 6a có điều kiện suy ra trực tiếp từ REQ-12: khách đăng nhập bằng email hoặc số điện thoại thì hai giá trị này phải xác định đúng một tài khoản. Nguồn không nêu cách xử lý khi trùng và không nêu việc trùng có bị cấm hay không, nên luồng chờ Q-155 và không viết hành động. Trên activity diagram luồng này là nhánh từ D-6 tới FINAL-2 kèm note N-6a. Khi Q-155 được trả lời theo đề xuất thì cấp BR mới, luồng 6a trở thành: hệ thống từ chối đăng ký và thông báo quy tắc bị vi phạm, quay lại bước 3.
- Mật khẩu (Q-156) chưa có điều kiện hợp lệ nên use case chưa có bước kiểm tra mật khẩu. Khi Q-156 được trả lời theo đề xuất thì thêm một bước kiểm tra sau bước 5, một luồng thay thế quay lại bước 3 và một BR mới.
- Bước 6 tạo tài khoản và bước 7 thông báo. Nếu Q-158 được trả lời là khách tự đăng nhập thì hậu điều kiện thêm phiên làm việc của khách và bước 7 nêu việc này.
- Luồng *a suy ra từ việc khách bỏ yêu cầu trước khi hệ thống tạo tài khoản; không có dữ liệu nào thay đổi.
- Không có use case do tác nhân thời gian kích hoạt dùng tài khoản khách làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Hệ thống không lưu thông tin thẻ thanh toán (REQ-77) và use case này không thu thập thông tin thanh toán.

Thao tác nguyên tử:

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Kiểm tra email, số điện thoại chưa thuộc tài khoản khác rồi tạo tài khoản khách | 6 | Email và số điện thoại của các tài khoản khách | Mỗi email và mỗi số điện thoại thuộc tối đa một tài khoản khách (chỉ thành bất biến khi Q-155 được trả lời có); kiểm tra trùng và tạo tài khoản là một thao tác | Chính nó (hai yêu cầu đăng ký cùng email hoặc cùng số điện thoại, kể cả từ hai thiết bị) | Chờ Q-155; theo đề xuất của Q-155, bên ghi nhận sau thấy email hoặc số điện thoại đã thuộc tài khoản khác và bị từ chối ở luồng 6a | REQ-12, REQ-11 |

Use case không chạm tài nguyên giữ ghế, giao dịch thanh toán hay yêu cầu hoàn tiền. Không có trạng thái dở dang: tài khoản được tạo trọn vẹn ở bước 6 hoặc không được tạo.

## 8a. Kịch bản chính

- KB1: Luồng chính --> tài khoản khách được tạo, khách nhận thông báo đăng ký thành công.
- KB2: Luồng chính + 4a --> email sai định dạng bị từ chối, khách nhập lại từ bước 3.
- KB3: Luồng chính + 5a --> số điện thoại sai định dạng bị từ chối, khách nhập lại từ bước 3.
- KB4: Luồng chính + 6a --> email hoặc số điện thoại đã thuộc tài khoản khác, kết cục chờ Q-155.
- KB5: Luồng chính + *a --> khách huỷ yêu cầu, không có tài khoản nào được tạo.

## 9. Activity diagram

File: diagrams/P04-activity-UC-001.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4 | A-4, D-4 |
| 4a | D-4, A-4a |
| 5 | A-5, D-5 |
| 5a | D-5, A-5a |
| 6 | A-6, D-6 |
| 6a | D-6 |
| 7 | A-7 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-01 | Partition | Khách | - | - | - | x=0, w=440 |
| P-SYS | Partition | Hệ thống | - | - | - | x=440, w=650 |
| INIT | Initial | - | - | P-ACT-01 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Yêu cầu đăng ký tài khoản | - | P-ACT-01 | 1 | x=60, y=130 (tương đối partition) |
| A-2 | Action | Yêu cầu cung cấp thông tin đăng ký | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| N-*a | Note | Luồng *a: tại bất kỳ bước nào trước bước 6, khách huỷ yêu cầu; hệ thống không tạo tài khoản; kết thúc use case (thất bại) | - | P-ACT-01 | *a | x=260, y=410 (tương đối partition), w=170, h=120 |
| M-3 | Merge | - | - | P-ACT-01 | 3 | x=130, y=340 (tương đối partition) |
| A-3 | Action | Cung cấp email, số điện thoại, mật khẩu | - | P-ACT-01 | 3 | x=60, y=410 (tương đối partition) |
| A-4 | Action | Kiểm tra định dạng email | - | P-SYS | 4 | x=60, y=510 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4, 4a | x=130, y=620 (tương đối partition) |
| A-4a | Action | Từ chối: email sai định dạng (BR-81) | - | P-SYS | 4a | x=250, y=610 (tương đối partition) |
| A-5 | Action | Kiểm tra định dạng số điện thoại | - | P-SYS | 5 | x=60, y=700 (tương đối partition) |
| D-5 | Decision | - | - | P-SYS | 5, 5a | x=130, y=810 (tương đối partition) |
| A-5a | Action | Từ chối: số điện thoại sai định dạng (BR-82) | - | P-SYS | 5a | x=250, y=800 (tương đối partition) |
| A-6 | Action | Tạo tài khoản khách | - | P-SYS | 6 | x=60, y=900 (tương đối partition) |
| D-6 | Decision | - | - | P-SYS | 6, 6a | x=130, y=1010 (tương đối partition) |
| FINAL-2 | ActivityFinal | - | - | P-SYS | 6a | x=250, y=1010 (tương đối partition) |
| N-6a | Note | Chờ Q-155: email hoặc số điện thoại đã thuộc tài khoản khách khác | - | P-SYS | 6a | x=370, y=1000 (tương đối partition), w=240, h=60 |
| A-7 | Action | Thông báo đăng ký thành công | - | P-SYS | 7 | x=60, y=1100 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 7 | x=130, y=1210 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | M-3 | ControlFlow | - | - | (590,360) |
| E-04 | M-3 | A-3 | ControlFlow | - | - | - |
| E-05 | A-3 | A-4 | ControlFlow | - | - | (150,540) |
| E-06 | A-4 | D-4 | ControlFlow | - | - | - |
| E-07 | D-4 | A-4a | ControlFlow | [email sai định dạng] | - | - |
| E-08 | D-4 | A-5 | ControlFlow | [email đúng định dạng] | - | - |
| E-09 | A-4a | M-3 | ControlFlow | - | - | (780,360) |
| E-10 | A-5 | D-5 | ControlFlow | - | - | - |
| E-11 | D-5 | A-5a | ControlFlow | [số điện thoại sai định dạng] | - | - |
| E-12 | D-5 | A-6 | ControlFlow | [số điện thoại đúng định dạng] | - | - |
| E-13 | A-5a | M-3 | ControlFlow | - | - | (950,830); (950,360) |
| E-14 | A-6 | D-6 | ControlFlow | - | - | - |
| E-15 | D-6 | A-7 | ControlFlow | [chưa trùng email, số điện thoại] | - | - |
| E-16 | D-6 | FINAL-2 | ControlFlow | [đã trùng email hoặc số điện thoại] | - | - |
| E-17 | A-7 | FINAL-1 | ControlFlow | - | - | - |
| E-18 | FINAL-2 | N-6a | NoteLink | - | - | - |

Partition P-ACT-01 là partition của ACT-01 Khách, P-SYS là partition của chủ ngữ hệ thống. Bước 4 và bước 5 mỗi bước có decision riêng (D-4, D-5) vì hai luồng 4a, 5a gắn với hai bước kiểm tra khác nhau. Luồng 6a không có hành động nên không có action; cạnh từ D-6 đi thẳng tới FINAL-2 và note N-6a ghi "Chờ Q-155". Luồng *a chỉ thể hiện bằng note N-*a, không có cạnh. Các cạnh E-09 và E-13 quay lại merge node M-3 đặt ngay trước A-3; chúng hợp với E-03 ở đoạn ngang trước M-3.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ | Người quyết | Đề xuất |
|---|---|---|---|---|---|
| Q-155 | Email và số điện thoại của tài khoản khách có phải duy nhất giữa các tài khoản khách không (một email, một số điện thoại thuộc tối đa một tài khoản)? | Bước 6; luồng 6a; Dữ liệu vào 1 trường 1, 2; BR mới; bảng Thao tác nguyên tử | Mục 3 cho khách đăng nhập bằng email hoặc số điện thoại nhưng không nêu hai giá trị này có thể trùng giữa các tài khoản hay không | Bên nghiệp vụ | Có: mỗi email và mỗi số điện thoại thuộc tối đa một tài khoản khách; đăng ký trùng bị từ chối và khách quay lại bước 3 |
| Q-156 | Mật khẩu của tài khoản khách có quy định độ dài tối thiểu hoặc độ phức tạp nào không? | Dữ liệu vào 1 trường 3; thêm bước kiểm tra và luồng thay thế; BR mới | Mục 3 nêu đăng ký bằng mật khẩu nhưng không nêu điều kiện hợp lệ của mật khẩu | Bên nghiệp vụ | Độ dài tối thiểu 8 ký tự, không quy định thêm; mật khẩu ngắn hơn bị từ chối và khách quay lại bước 3 |
| Q-157 | Sau khi đăng ký, hệ thống có xác minh email hoặc số điện thoại của khách (gửi thư hoặc mã xác nhận) trước khi tài khoản dùng được không? | Bước 6, 7; hậu điều kiện; tác nhân phụ ACT-08 ở P02, P03 | Mục 3 chỉ nêu đăng ký bằng email, số điện thoại và mật khẩu; Mục 21 chỉ cho dịch vụ email gửi email chứa vé và email thông báo hoàn tiền | Bên nghiệp vụ | Không xác minh: tài khoản dùng được ngay sau khi tạo; dịch vụ email không tham gia use case |
| Q-158 | Sau khi đăng ký thành công, khách được tự động đăng nhập hay phải đăng nhập riêng bằng email hoặc số điện thoại cùng mật khẩu? | Bước 7; hậu điều kiện | Mục 3 nêu đăng ký và đăng nhập là hai việc riêng, không nêu đăng ký có đăng nhập luôn hay không | Bên nghiệp vụ | Không tự đăng nhập: khách đăng nhập riêng theo REQ-12 |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P05, P06 | GL-18 (cột Ghi chú); BR-81, BR-82 (cột Ghi chú trong sổ BR và P06) | Các ghi chú còn nêu UC-001 "chưa đặc tả P04" | Khi X3 gộp, bỏ cụm "chưa đặc tả P04" ở ghi chú của BR-81, BR-82 và ở GL-18 (phần UC-001) |

## Vấn đề còn mở

- Q-155 đến Q-158 chưa được trả lời; use case giữ chỗ trống theo NGHIEM_NGAT và không dựa vào các đề xuất.
- Luồng chính có 7 bước, nằm trong khoảng 3-15.
- Dải mã được cấp cho lô là Q-155 đến 174 và BR-94 đến 113; use case này dùng Q-155 đến Q-158 và không dùng mã BR nào.
- Trên activity diagram, mọi cạnh quay lại M-3 hợp ở đoạn ngang trước M-3; không cạnh nào cắt qua node.
