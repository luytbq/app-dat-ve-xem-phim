# P04 - Đặc tả use case UC-009 Soát vé - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.5 |
| Thay đổi 1.5 | Đồng bộ số phiên bản và nhãn BR của dòng Đầu vào đã dùng với bản hiện hành; nội dung đã đối chiếu lại ở lượt review cuối (design/_review-final.md, RF-06) |
| Đầu vào đã dùng | 00-Conventions.md; project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.8; P03-usecase-model.md 1.1; sổ BR (_BR-register.md, đã gộp BR-01 đến BR-93); P05-glossary.md 1.1; UC-005-book-tickets.md 1.11 (mẫu văn phong; vé do UC-005 tạo); UC-008-cancel-ticket.md 1.8 (điểm nối huỷ và soát) |
| Phạm vi | UC-009 |
| Mã Q, ASM cuối đã cấp | Q-51 (Q-47 gộp vào Q-35); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-009 |
| Tên use case | Soát vé (Check Ticket) |
| Tác nhân chính | ACT-03 Nhân viên soát vé |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa nhân viên soát vé và hệ thống khi nhân viên soát vé kiểm tra vé của khách trước cửa phòng chiếu bằng cách quét mã QR trên vé. Kết quả là khách có vé hợp lệ được vào phòng chiếu và vé được đánh dấu đã sử dụng, hoặc nhân viên soát vé nhận được lý do vé không hợp lệ. |
| Sự kiện kích hoạt | Khách mang vé tới cửa phòng chiếu (EV-11) |
| Tiền điều kiện | Nhân viên soát vé đã đăng nhập và đang có phiên làm việc (REQ-102).<br>Nhân viên soát vé thuộc đúng một cụm rạp (REQ-100). |
| Hậu điều kiện (thành công) | Mỗi vé hợp lệ đã được quét trong lần thực hiện use case ở trạng thái đã sử dụng. |
| Hậu điều kiện tối thiểu | Không có luồng kết thúc thất bại: vé bị từ chối ở các luồng 4a đến 4e không thay đổi trạng thái và use case tiếp tục ở bước 7. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-50, REQ-51, REQ-52, REQ-93, REQ-94, REQ-118, REQ-123 đến REQ-128 (theo P02); REQ-102 (tiền điều kiện; P02 ghi "-"); REQ-100 (tham chiếu, UC-017); REQ-61 (tham chiếu, UC-014); REQ-30, REQ-105 (tham chiếu, UC-005); REQ-40, REQ-83 (tham chiếu, UC-008) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Nhân viên soát vé | Chọn suất chiếu đang soát trong các suất chiếu của cụm rạp mình (xem Dữ liệu vào 1; BR-34). |
| 2 | Hệ thống | Ghi nhận suất chiếu đã chọn là suất chiếu đang soát và hiển thị thông tin suất chiếu (xem Dữ liệu ra 1). |
| 3 | Nhân viên soát vé | Quét mã QR trên vé của khách bằng camera của thiết bị (xem Dữ liệu vào 2). |
| 4 | Hệ thống | Kiểm tra mã QR tương ứng với một vé, vé thuộc cụm rạp của nhân viên soát vé, vé thuộc suất chiếu đang soát, vé chưa sử dụng và vé chưa huỷ (BR-22, BR-23, BR-24, BR-25, BR-30); khi vé vi phạm nhiều điều kiện thì chỉ xét điều kiện đầu tiên vi phạm theo thứ tự này (BR-33). |
| 5 | Hệ thống | Đánh dấu vé đã sử dụng (REQ-52). |
| 6 | Hệ thống | Thông báo vé hợp lệ cho nhân viên soát vé và hiển thị thông tin vé (xem Dữ liệu ra 2). |
| 7 | Nhân viên soát vé | Lặp lại bước 3-6 cho đến khi không còn vé cần soát của suất chiếu đang soát. |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 4a | Mã QR không tương ứng với vé nào của hệ thống | Hệ thống | Từ chối cho vào và báo nhân viên soát vé lý do: mã QR không tương ứng vé (xem Dữ liệu ra 3). | Tiếp tục bước 7 |
| 4b | Mã QR tương ứng một vé và vé thuộc cụm rạp khác cụm rạp của nhân viên soát vé (BR-22) | Hệ thống | Từ chối cho vào và báo nhân viên soát vé lý do: vé thuộc cụm rạp khác (BR-22; xem Dữ liệu ra 3). | Tiếp tục bước 7 |
| 4c | Vé thuộc cụm rạp của nhân viên soát vé và vé thuộc suất chiếu khác suất chiếu đang soát (BR-23) | Hệ thống | Từ chối cho vào và báo nhân viên soát vé lý do: vé thuộc suất chiếu khác (BR-23; xem Dữ liệu ra 3). | Tiếp tục bước 7 |
| 4d | Vé thuộc cụm rạp của nhân viên soát vé, thuộc suất chiếu đang soát và đã sử dụng, kể cả khi nhân viên soát vé khác vừa soát chính vé đó (BR-24, BR-30) | Hệ thống | Từ chối cho vào và báo nhân viên soát vé lý do: vé đã sử dụng (BR-24; xem Dữ liệu ra 3). | Tiếp tục bước 7 |
| 4e | Vé thuộc cụm rạp của nhân viên soát vé, thuộc suất chiếu đang soát, chưa sử dụng và đã huỷ, kể cả khi vé vừa được huỷ ngay trước đó ở UC-008 (BR-25, BR-30) | Hệ thống | Từ chối cho vào và báo nhân viên soát vé lý do: vé đã huỷ (BR-25; xem Dữ liệu ra 3). | Tiếp tục bước 7 |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 1)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Suất chiếu đang soát | Suất chiếu mà nhân viên soát vé soát vé tại cửa phòng chiếu (REQ-93) | Có | Một suất chiếu của cụm rạp của nhân viên soát vé (BR-34, REQ-123); chọn một lần, áp dụng cho các vé quét liên tiếp tới khi chọn lại | Phim A, 2D, Phòng 3, 15/11/2026 19:30 |

Dữ liệu vào 2 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Mã QR của vé | Mã QR riêng của vé, được camera của thiết bị đọc (REQ-50, REQ-30) | Có | Tương ứng với một vé của hệ thống (bước 4, luồng 4a); nội dung và định dạng mã QR không quy định, hệ thống tự xác định vé từ mã (REQ-128); camera không đọc được mã thì không có cách nhập tay (REQ-126) | Mã QR trên vé ghế F7 của mã đặt vé CB0001234 |

Dữ liệu ra 1 (bước 2)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Suất chiếu đang soát | Phim, định dạng, phòng chiếu, ngày giờ bắt đầu (REQ-61) | Ngày giờ dạng dd/mm/yyyy hh:mm | Phim A, 2D, Phòng 3, 15/11/2026 19:30 |

Dữ liệu ra 2 (bước 6)

Vé hợp lệ hiển thị toàn bộ nội dung vé theo REQ-105, trừ mã QR (REQ-127). Bảng liệt kê các trường nội dung vé; mã QR đã là Dữ liệu vào 2.

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Mã đặt vé | Mã của lần đặt chứa vé, duy nhất trên toàn hệ thống (REQ-106) | Văn bản; nguồn không quy định định dạng cụ thể của mã | CB0001234 |
| 2 | Tên phim | Phim của suất chiếu | Văn bản | Phim A |
| 3 | Định dạng phim | Định dạng của suất chiếu | Văn bản | 2D |
| 4 | Tên cụm rạp | Cụm rạp có suất chiếu | Văn bản | CineBook Cầu Giấy |
| 5 | Tên phòng chiếu và loại phòng | Phòng chiếu và loại phòng (thường, 4DX, IMAX) | Văn bản | Phòng 3 (IMAX) |
| 6 | Ngày và giờ bắt đầu suất chiếu | Thời điểm bắt đầu của suất chiếu | dd/mm/yyyy hh:mm | 15/11/2026 19:30 |
| 7 | Vị trí ghế | Ghế ứng với vé | Mã hàng và số ghế | F7 |
| 8 | Loại ghế | Ghế thường, ghế VIP hoặc ghế đôi | Văn bản | Ghế VIP |
| 9 | Giá vé | Giá của vé | Số nguyên, phân cách hàng nghìn bằng dấu chấm, kèm "đ", căn phải | 120.000 đ |

Dữ liệu ra 3 (luồng 4a đến 4e)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Lý do vé không hợp lệ | Vé bị từ chối chỉ hiển thị lý do (REQ-127), là một lý do duy nhất trong: mã QR không tương ứng vé; vé thuộc cụm rạp khác; vé thuộc suất chiếu khác; vé đã sử dụng; vé đã huỷ, chọn theo thứ tự này (REQ-94, BR-33) | Văn bản | Vé đã sử dụng |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-22 | Nhân viên soát vé chỉ soát vé thuộc cụm rạp của mình. | Ràng buộc | 4, 4b | REQ-51; REQ-100 (phụ) | Mới |
| BR-23 | Vé chỉ được soát khi vé thuộc suất chiếu mà nhân viên soát vé đã chọn. | Ràng buộc | 4, 4c | REQ-51, REQ-93 | Mới |
| BR-24 | Mỗi vé chỉ được soát một lần; vé đã sử dụng không được soát lại, và khi nhiều nhân viên soát vé cùng lúc soát một vé thì chỉ một lần soát thành công. | Ràng buộc | 4, 4d | REQ-51 | Mới |
| BR-25 | Vé đã huỷ không được soát. | Ràng buộc | 4, 4e | REQ-51; REQ-40, REQ-83 (phụ) | Mới |
| BR-30 | Vé đã sử dụng không được huỷ; khi việc huỷ và việc soát cùng một vé xảy ra cùng lúc thì bên ghi nhận trước thành công, bên sau bị từ chối. | Ràng buộc | 4, 4d, 4e | REQ-118; REQ-51 (phụ) | Đã có |
| BR-33 | Khi một vé vi phạm nhiều điều kiện soát, hệ thống chỉ báo một lý do theo thứ tự: cụm rạp, suất chiếu, đã sử dụng, đã huỷ. | Ràng buộc | 4, 4a đến 4e, Dữ liệu ra 3 | REQ-124; REQ-94 (phụ) | Mới |
| BR-34 | Nhân viên soát vé chỉ chọn suất chiếu của cụm rạp mình; suất chiếu đã chọn áp dụng cho các vé quét liên tiếp tới khi chọn lại. | Ràng buộc | 1, 2, 7, Dữ liệu vào 1 | REQ-123; REQ-93 (phụ) | Mới |
| BR-83 | Vé được soát vào bất kỳ thời điểm nào so với giờ bắt đầu của suất chiếu; hệ thống không giới hạn thời điểm soát vé. | Ràng buộc | 4, Mục 8 | REQ-125 | Đã có |

BR-83 (REQ-125) cấp ở P06 cho điều kiện không giới hạn thời điểm soát. Không có BR nào khác của sổ trùng nghĩa: BR-02 chỉ áp dụng cho nhân viên quầy bán vé, không áp dụng cho nhân viên soát vé.

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính theo kịch bản của ACT-03 Nhân viên soát vé, tác nhân chính duy nhất. Camera của thiết bị chỉ là kênh nhập, không phải tác nhân và không có giao tiếp riêng với phần mềm (P01 A-T2, Q-22, REQ-50).
- Bước 4 và bước 5 là một thao tác không chia cắt về mặt nghiệp vụ. Lý do: BR-24 đòi hỏi khi hai nhân viên soát vé cùng quét một vé thì chỉ một người được kết quả hợp lệ; nếu kiểm tra "chưa sử dụng" và đánh dấu "đã sử dụng" là hai thao tác tách rời, cả hai có thể cùng thấy vé chưa sử dụng. Người quét sau nhận lý do ở luồng 4d. Cơ chế bảo đảm điều này thuộc bước thiết kế (P07, P09).
- Kiểm tra và ghi trạng thái vé ở bước 4, 5 của use case này và ở UC-008 bước 4 phải loại trừ lẫn nhau trên cùng một vé; một vé không thể đồng thời ở trạng thái đã huỷ và đã sử dụng. Khi hai việc xảy ra cùng lúc, bên ghi nhận trước thắng và bên sau bị từ chối (BR-30): nếu việc huỷ được ghi nhận trước thì việc soát kết thúc ở luồng 4e; nếu việc soát được ghi nhận trước thì UC-008 từ chối huỷ ở luồng 4b.
- Bước 4 gộp các điều kiện về cùng một vé tại cùng thời điểm (F4.2 mục 11). Khi một vé vi phạm nhiều điều kiện, lý do báo theo thứ tự xuất hiện trong REQ-51: cụm rạp, suất chiếu, đã sử dụng, đã huỷ, và chỉ báo một lý do (BR-33, REQ-124). Điều kiện "mã QR tương ứng một vé" được kiểm trước các điều kiện còn lại vì không xác định được vé thì không kiểm tiếp được.
- Luồng 4a suy ra trực tiếp từ REQ-51 và REQ-94: mã QR không tương ứng vé nào của hệ thống thì không phải vé hợp lệ, nên hệ thống báo lý do; nguồn không nêu riêng trường hợp này.
- Vòng lặp ở bước 7 xuất phát từ P02 Mục 4b ("quét mã QR trên từng vé") và REQ-93 (chọn suất chiếu một lần trước khi quét, REQ-123). Mọi luồng 4a đến 4e và bước 6 đều trở về bước 7 để nhân viên soát vé quét vé kế tiếp.
- Bước sinh theo quy tắc của prompt: bước 6 và phần báo lý do ở luồng 4a đến 4e theo Target 5a và REQ-94; hành động "Từ chối cho vào" ở luồng 4a đến 4e theo F5.7. Các luồng này tiếp tục bước 7 vì nhân viên soát vé không sửa được vé của khách nhưng vẫn soát được vé kế tiếp.
- Nội dung vé hiển thị ở bước 6 là nội dung do UC-005 tạo (REQ-30, REQ-105).
- Vé có thể ở trạng thái đã huỷ do UC-008 Huỷ vé đặt; bước 4 kiểm tra điều kiện này (luồng 4e). Vé đã sử dụng không huỷ được ở UC-008 và việc huỷ và soát cùng lúc xử lý theo BR-30.
- Không có use case nào do tác nhân thời gian kích hoạt dùng dữ liệu của use case này làm mốc, nên không có bước hẹn hoặc huỷ mốc (F4.2 mục 17).
- Nguồn không giới hạn thời điểm soát so với giờ bắt đầu của suất chiếu (REQ-125, BR-83), nên bước 4 không có điều kiện về thời điểm quét. Khi camera không đọc được mã QR thì không có cách nhập tay (REQ-126), nên không có luồng thay thế tại bước 3; có thể bổ sung nếu nguồn nêu sau này.
- Mã QR không quy định nội dung và định dạng; hệ thống tự xác định vé từ mã (REQ-128), chi tiết mã hoá để bước thiết kế quyết định.

## 8a. Kịch bản chính

- KB1: Luồng chính --> vé hợp lệ, được đánh dấu đã sử dụng, khách vào phòng chiếu.
- KB2: Luồng chính lặp bước 3-6 --> nhân viên soát vé soát liên tiếp nhiều vé của cùng một suất chiếu.
- KB3: Luồng chính + 4d --> hai nhân viên soát vé cùng quét một vé, người quét sau nhận lý do vé đã sử dụng.
- KB4: Luồng chính + 4b hoặc 4c --> vé của cụm rạp khác hoặc của suất chiếu khác bị từ chối, nhân viên soát vé quét vé kế tiếp.
- KB5: Luồng chính + 4a hoặc 4e --> mã QR không tương ứng vé hoặc vé đã huỷ bị từ chối.
- KB6: Luồng chính + 4e (vé vừa được huỷ ngay trước đó ở UC-008) --> việc soát bị từ chối, bên ghi nhận trước thắng.

## 9. Activity diagram

File: diagrams/P04-activity-UC-009.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | A-1 |
| 2 | A-2 |
| 3 | A-3 |
| 4 | A-4, D-4 |
| 4a | A-4a |
| 4b | A-4b |
| 4c | A-4c |
| 4d | A-4d |
| 4e | A-4e |
| 5 | A-5 |
| 6 | A-6 |
| 7 | D-7, M-7, M-3 |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-03 | Partition | Nhân viên soát vé | - | - | - | x=0, w=400 |
| P-SYS | Partition | Hệ thống | - | - | - | x=400, w=700 |
| INIT | Initial | - | - | P-ACT-03 | - | x=130, y=60 (tương đối partition) |
| A-1 | Action | Chọn suất chiếu đang soát | - | P-ACT-03 | 1 | x=60, y=130 (tương đối partition) |
| A-2 | Action | Ghi nhận suất chiếu đang soát | - | P-SYS | 2 | x=60, y=230 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-03 | 7 | x=130, y=330 (tương đối partition) |
| A-3 | Action | Quét mã QR trên vé của khách | - | P-ACT-03 | 3 | x=60, y=400 (tương đối partition) |
| A-4 | Action | Kiểm tra mã QR và vé | - | P-SYS | 4 | x=60, y=500 (tương đối partition) |
| A-4a | Action | Từ chối: mã QR không tương ứng vé | - | P-SYS | 4a | x=340, y=510 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a đến 4e | x=130, y=620 (tương đối partition) |
| A-4b | Action | Từ chối: vé thuộc cụm rạp khác (BR-22) | - | P-SYS | 4b | x=340, y=610 (tương đối partition) |
| A-5 | Action | Đánh dấu vé đã sử dụng | - | P-SYS | 5 | x=60, y=700 (tương đối partition) |
| A-4c | Action | Từ chối: vé thuộc suất chiếu khác (BR-23) | - | P-SYS | 4c | x=340, y=710 (tương đối partition) |
| A-6 | Action | Thông báo vé hợp lệ, hiển thị thông tin vé | - | P-SYS | 6 | x=60, y=800 (tương đối partition) |
| A-4d | Action | Từ chối: vé đã sử dụng (BR-24) | - | P-SYS | 4d | x=340, y=810 (tương đối partition) |
| A-4e | Action | Từ chối: vé đã huỷ (BR-25) | - | P-SYS | 4e | x=340, y=910 (tương đối partition) |
| M-7 | Merge | - | - | P-ACT-03 | 7 | x=130, y=1060 (tương đối partition) |
| D-7 | Decision | - | - | P-ACT-03 | 7 | x=130, y=1150 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-ACT-03 | - | x=130, y=1240 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | A-1 | ControlFlow | - | - | - |
| E-02 | A-1 | A-2 | ControlFlow | - | - | (150,260) |
| E-03 | A-2 | M-3 | ControlFlow | - | - | (550,350) |
| E-04 | M-3 | A-3 | ControlFlow | - | - | - |
| E-05 | A-3 | A-4 | ControlFlow | - | - | (150,530) |
| E-06 | A-4 | D-4 | ControlFlow | - | - | - |
| E-07 | D-4 | A-4a | ControlFlow | [không tương ứng vé] | - | (680,540) |
| E-08 | D-4 | A-4b | ControlFlow | [khác cụm rạp] | - | (680,640) |
| E-09 | D-4 | A-4c | ControlFlow | [khác suất chiếu] | - | (680,740) |
| E-10 | D-4 | A-4d | ControlFlow | [đã sử dụng] | - | (680,840) |
| E-11 | D-4 | A-4e | ControlFlow | [đã huỷ] | - | (680,940) |
| E-12 | D-4 | A-5 | ControlFlow | [hợp lệ] | - | - |
| E-13 | A-5 | A-6 | ControlFlow | - | - | - |
| E-14 | A-6 | M-7 | ControlFlow | - | - | (550,1080) |
| E-15 | A-4a | M-7 | ControlFlow | - | - | (980,540); (980,1080) |
| E-16 | A-4b | M-7 | ControlFlow | - | - | (980,640); (980,1080) |
| E-17 | A-4c | M-7 | ControlFlow | - | - | (980,740); (980,1080) |
| E-18 | A-4d | M-7 | ControlFlow | - | - | (980,840); (980,1080) |
| E-19 | A-4e | M-7 | ControlFlow | - | - | (980,940); (980,1080) |
| E-20 | M-7 | D-7 | ControlFlow | - | - | - |
| E-21 | D-7 | M-3 | ControlFlow | [còn vé cần soát] | - | (30,1170); (30,350) |
| E-22 | D-7 | FINAL-1 | ControlFlow | [hết vé cần soát] | - | - |

Partition P-ACT-03 là partition của ACT-03 Nhân viên soát vé. Decision D-7 là lựa chọn của nhân viên soát vé (còn vé cần soát hay không) nên đặt trong partition của nhân viên; bước 7 ánh xạ sang D-7 và không có action (F10.2). Cạnh E-21 là cạnh lặp về M-3. Các cạnh E-14 và E-15 đến E-19 hợp lại ở M-7 trước D-7.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-41 | Đã trả lời (Chỉ suất của cụm rạp mình, chọn một lần rồi quét liên tiếp), đề bài bổ sung Mục 13. Nhân viên soát vé được chọn những suất chiếu nào (chỉ suất của cụm rạp mình hay mọi cụm rạp; chỉ suất trong ngày hay bất kỳ), và suất chiếu đã chọn áp dụng cho các vé quét liên tiếp tới khi chọn lại hay phải chọn cho từng vé? (Chỉ suất của cụm rạp mình, chọn một lần cho nhiều vé / Phương án khác) | Bước 1, 2, 7; Dữ liệu vào 1; BR-22, BR-23 | Mục 13 chỉ nêu "chọn suất chiếu đang soát, rồi quét mã QR trên vé", không nêu phạm vi suất chiếu được chọn và thời điểm chọn lại |
| Q-42 | Đã trả lời (Báo một lý do theo thứ tự cụm rạp, suất chiếu, đã sử dụng, đã huỷ), đề bài bổ sung Mục 13. Khi một vé vi phạm nhiều điều kiện cùng lúc (ví dụ vé của cụm rạp khác thì cũng khác suất chiếu), hệ thống báo một lý do hay báo mọi lý do? Nếu báo một lý do thì theo thứ tự ưu tiên nào? (Báo một lý do theo thứ tự cụm rạp, suất chiếu, đã sử dụng, đã huỷ / Báo mọi lý do) | Bước 4; luồng 4a đến 4e; Dữ liệu ra 3 | Mục 13 liệt kê bốn điều kiện hợp lệ và nêu "báo lý do" nhưng không nêu thứ tự ưu tiên hay số lý do |
| Q-43 | Đã trả lời (Không giới hạn), đề bài bổ sung Mục 13. Có giới hạn thời điểm soát vé so với giờ bắt đầu của suất chiếu không (vé quét quá sớm trước giờ bắt đầu, hoặc quá muộn sau giờ bắt đầu hay sau giờ kết thúc suất chiếu)? Nếu có thì khoảng thời gian là bao nhiêu và hệ thống phản hồi thế nào? (Không giới hạn / Có giới hạn, nêu khoảng thời gian) | Bước 4; luồng thay thế mới; BR mới | Mục 13 liệt kê bốn điều kiện hợp lệ và không nêu điều kiện về thời điểm quét |
| Q-44 | Đã trả lời (Không có nhập tay trong phạm vi này), đề bài bổ sung Mục 13. Khi camera của thiết bị không đọc được mã QR (mã mờ, rách), nhân viên soát vé có được nhập mã tay không? Nếu có thì nhập thông tin gì để xác định vé (mã đặt vé không đủ vì một mã đặt vé có nhiều vé) và có cùng các kiểm tra ở bước 4 không? (Không có cách nhập tay / Có nhập tay, nêu thông tin nhập) | Bước 3; Dữ liệu vào 2; luồng thay thế mới tại bước 3 | Mục 13 chỉ nêu quét mã QR bằng camera; Q-22 xác nhận camera là kênh nhập duy nhất được nêu |
| Q-45 | Đã trả lời (Vé hợp lệ hiển thị toàn bộ nội dung vé trừ mã QR; vé bị từ chối chỉ hiển thị lý do), đề bài bổ sung Mục 13. Khi vé hợp lệ, hệ thống hiển thị cho nhân viên soát vé những thông tin nào trên vé (toàn bộ nội dung vé theo REQ-105 hay một phần)? Khi vé bị từ chối, có hiển thị thêm thông tin vé (ví dụ vé đã được soát lúc nào) không? (Toàn bộ nội dung vé khi hợp lệ, chỉ lý do khi từ chối / Phương án khác) | Bước 6; Dữ liệu ra 2, 3 | Mục 13 chỉ nêu "báo lý do cho nhân viên soát vé"; Mục 7 liệt kê nội dung vé nhưng không nêu phần nào hiển thị khi soát |
| Q-46 | Đã trả lời (Không quy định định dạng; hệ thống tự xác định vé từ mã), đề bài bổ sung Mục 13. Mã QR của vé mã hoá thông tin gì và có định dạng quy định không (ví dụ mã vé duy nhất, hay các thông tin của vé)? (Không quy định định dạng, hệ thống tự xác định vé từ mã / Quy định định dạng cụ thể) | Bước 3, 4; Dữ liệu vào 2; luồng 4a | Mục 7 chỉ nêu "mã QR riêng" của mỗi vé, không nêu nội dung hay định dạng |
| Q-47 | Gộp vào Q-35 | - | - |

## Đề xuất sửa artifact trước

Không có

## Vấn đề còn mở

- Vòng lặp bước 7 và việc ghi nhận suất chiếu đang soát ở bước 2 dựa trên cách đọc P02 "quét mã QR trên từng vé" và REQ-93, đã xác nhận ở REQ-123 (chọn một lần rồi quét liên tiếp).
- Q-44 trả lời không có nhập tay nên use case không có luồng 3a; nếu nguồn bổ sung nhập tay sau này thì thêm luồng thay thế tại bước 3.
- Luồng chính có 7 bước, nằm trong khoảng 3-15.
- Trên activity diagram, các cạnh E-14 và E-15 đến E-19 chạy chung một đoạn ngang trước M-7 (hợp ở node merge); không cạnh nào cắt qua node.
