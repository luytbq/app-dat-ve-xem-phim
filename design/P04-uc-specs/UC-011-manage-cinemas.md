# P04 - Đặc tả use case UC-011 Quản lý cụm rạp - Hệ thống đặt vé xem phim CineBook

| Thuộc tính | Giá trị |
|---|---|
| Bước | P04 |
| Phiên bản | 1.1 |
| Thay đổi 1.1 | Chốt Q-204 đến Q-207: tỉnh, thành phố bắt buộc, tên cụm rạp duy nhất (luồng 5b, BR-141), luồng 5a và BR-142 khi lưu đồng thời, không có thao tác xoá cụm rạp |
| Đầu vào đã dùng | 00-Conventions.md; 00-Concurrency.md (M1); project-profile.md; yeu-cau-dat-ve.md; P00-problem-brief.md 1.11; P01-actors.md 1.2; P02-usecases.md 1.9; P03-usecase-model.md 1.2; _BR-register.md (đã gộp BR-01 đến BR-147); P05-glossary.md 1.2; P06-supplementary-spec.md 1.4; P08-analysis-model.md 1.5 (EX-13, EX-15); P13-data-model.md 1.5 (Q-136 đến Q-138); UC-010-manage-movies.md 1.1 (mẫu và Q-203); UC-013-manage-price-list.md 1.4; UC-014-schedule-showtimes.md 1.6 (điểm nối BR-46) |
| Phạm vi | UC-011 |
| Mã Q, ASM cuối đã cấp | Q-207 (Q-204 đến Q-207 cấp ở use case này, đã trả lời); không có ASM (NGHIEM_NGAT) |

## 1. Thông tin chung

| Thuộc tính | Giá trị |
|---|---|
| Mã use case | UC-011 |
| Tên use case | Quản lý cụm rạp (Manage Cinemas) |
| Tác nhân chính | ACT-05 Quản lý chuỗi |
| Tác nhân phụ | Không có |
| Mô tả ngắn | Use case này mô tả tương tác giữa quản lý chuỗi và hệ thống khi quản lý chuỗi muốn thêm cụm rạp mới hoặc sửa thông tin của một cụm rạp trong danh sách cụm rạp của chuỗi. Kết quả là danh sách cụm rạp của chuỗi đúng và đủ. |
| Sự kiện kích hoạt | Chuỗi có cụm rạp mới hoặc thông tin cụm rạp thay đổi (EV-13) |
| Tiền điều kiện | Quản lý chuỗi đã đăng nhập và đang có phiên làm việc (REQ-102). |
| Hậu điều kiện (thành công) | Khi thêm cụm rạp (luồng chính): danh sách cụm rạp của chuỗi có thêm một cụm rạp với thông tin mà quản lý chuỗi đã nhập; cụm rạp mới chưa có phòng chiếu, bảng giá và nhân viên.<br>Khi sửa cụm rạp (luồng 1a): cụm rạp đã chọn có các giá trị mà quản lý chuỗi đã nhập thay cho giá trị cũ; các phòng chiếu, suất chiếu và nhân viên thuộc cụm rạp vẫn thuộc cụm rạp đó. |
| Hậu điều kiện tối thiểu | Khi use case kết thúc thất bại, danh sách cụm rạp và thông tin của mọi cụm rạp không thay đổi. |
| Quan hệ | Không có |
| Điểm mở rộng | Không có |
| REQ | REQ-54 (theo P02); REQ-102 (tiền điều kiện; P02 ghi "-"); REQ-10 (tham chiếu, UC-004: lọc lịch chiếu theo tỉnh, thành phố); REQ-100 (tham chiếu, UC-017); REQ-105 (tham chiếu, UC-005); REQ-09 (tham chiếu, UC-004); REQ-01 (liên quan Mục 8; P02 Mục 5 ghi chuyển P06); REQ-149 (căn cứ phụ của BR dẫn ở Mục 6) |

## 2. Luồng sự kiện chính

| STT | Thực hiện bởi | Hành động |
|---|---|---|
| 1 | Quản lý chuỗi | Yêu cầu thêm cụm rạp mới vào danh sách cụm rạp của chuỗi. |
| 2 | Hệ thống | Hiển thị danh sách cụm rạp hiện có của chuỗi (xem Dữ liệu ra 1). |
| 3 | Quản lý chuỗi | Nhập thông tin cụm rạp rồi gửi (xem Dữ liệu vào 1). |
| 4 | Hệ thống | Kiểm tra thông tin cụm rạp hợp lệ theo điều kiện của Dữ liệu vào 1 (Q-204). |
| 5 | Hệ thống | Kiểm tra tên cụm rạp chưa thuộc cụm rạp nào khác (BR-141) và, với cụm rạp đã chọn ở luồng 1a, cụm rạp chưa bị yêu cầu khác sửa kể từ lúc hiển thị (BR-142), rồi lưu thông tin cụm rạp, thêm cụm rạp mới vào danh sách cụm rạp hoặc cập nhật cụm rạp đã chọn, tất cả là một thao tác không chia cắt. |
| 6 | Hệ thống | Thông báo lưu cụm rạp thành công và hiển thị cụm rạp đã lưu (xem Dữ liệu ra 2). |

## 3. Luồng sự kiện thay thế và ngoại lệ

| STT | Điều kiện | Thực hiện bởi | Hành động | Quay lại / Kết thúc |
|---|---|---|---|---|
| 1a | Quản lý chuỗi chọn sửa một cụm rạp đã có thay vì thêm cụm rạp mới | - | Sửa cụm rạp | - |
| 1a1 | | Hệ thống | Hiển thị danh sách cụm rạp của chuỗi (xem Dữ liệu ra 1). | |
| 1a2 | | Quản lý chuỗi | Chọn cụm rạp cần sửa (xem Dữ liệu vào 2). | |
| 1a3 | | Hệ thống | Hiển thị thông tin hiện tại của cụm rạp đã chọn để sửa (xem Dữ liệu ra 3). | Tiếp tục bước 3 |
| 4a | Thông tin cụm rạp không đạt điều kiện hợp lệ của Dữ liệu vào 1 | Hệ thống | Từ chối lưu và thông báo điều kiện bị vi phạm của từng trường. | Quay lại bước 3 |
| 5a | Chỉ khi theo luồng 1a: cụm rạp đã bị yêu cầu khác sửa kể từ lúc hiển thị (BR-142) | Hệ thống | Từ chối lưu, không ghi đè thay đổi trước và thông báo quy tắc bị vi phạm (BR-142). | Quay lại bước 1a1 |
| 5b | Tên cụm rạp đã thuộc một cụm rạp khác, kể cả khi cụm rạp đó vừa được lưu cùng lúc bởi một yêu cầu khác (BR-141) | Hệ thống | Từ chối lưu và thông báo quy tắc bị vi phạm (BR-141). | Quay lại bước 3 |
| *a | Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý chuỗi huỷ yêu cầu | Hệ thống | Huỷ yêu cầu, không thay đổi danh sách cụm rạp. | Kết thúc use case (thất bại) |

## 4. Luồng con

Không có

## 5. Dữ liệu vào và dữ liệu ra

Dữ liệu vào 1 (bước 3)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Tên cụm rạp | Tên của cụm rạp, vé và email ghi tên cụm rạp (REQ-105) | Có | Không để trống; không trùng tên cụm rạp khác trong chuỗi (BR-141, Q-206) | CineBook Vincom Bà Triệu |
| 2 | Tỉnh, thành phố | Tỉnh, thành phố nơi cụm rạp đặt, căn cứ để khách lọc lịch chiếu (REQ-10) | Có (Q-204) | Văn bản không để trống; lọc theo tỉnh, thành phố dùng giá trị đã nhập (Q-204) | Hà Nội |
| 3 | Địa chỉ | Địa chỉ của cụm rạp | Không (trả lời Q-137) | Văn bản | 191 Bà Triệu, Hai Bà Trưng |

Dữ liệu vào 2 (bước 1a2)

| STT | Trường dữ liệu | Mô tả | Bắt buộc | Điều kiện hợp lệ | Ví dụ |
|---|---|---|---|---|---|
| 1 | Cụm rạp cần sửa | Một cụm rạp trong danh sách ở Dữ liệu ra 1 | Có | Cụm rạp có trong danh sách cụm rạp của chuỗi | CineBook Vincom Bà Triệu |

Dữ liệu ra 1 (bước 2, bước 1a1)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Danh sách cụm rạp | Với mỗi cụm rạp: tên, tỉnh hoặc thành phố, địa chỉ (REQ-54) | Văn bản | CineBook Vincom Bà Triệu, Hà Nội, 191 Bà Triệu, Hai Bà Trưng |

Dữ liệu ra 2 (bước 6)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Cụm rạp đã lưu | Toàn bộ thông tin của cụm rạp vừa lưu: các trường của Dữ liệu vào 1 | Như Dữ liệu ra 1 | CineBook Vincom Bà Triệu, Hà Nội, 191 Bà Triệu, Hai Bà Trưng |

Dữ liệu ra 3 (bước 1a3)

| STT | Trường dữ liệu | Mô tả | Định dạng hiển thị | Ví dụ |
|---|---|---|---|---|
| 1 | Thông tin hiện tại của cụm rạp | Toàn bộ thông tin hiện tại của cụm rạp đã chọn: các trường của Dữ liệu vào 1 | Như Dữ liệu ra 1 | CineBook Vincom Bà Triệu, Hà Nội, 191 Bà Triệu, Hai Bà Trưng |

## 6. Quy tắc nghiệp vụ

| BR | Quy tắc | Loại | Bước áp dụng | REQ | Trong sổ BR |
|---|---|---|---|---|---|
| BR-141 | Không có hai cụm rạp trùng tên trong chuỗi. | Ràng buộc | 5, 5b, Dữ liệu vào 1 (trường 1) | REQ-54, REQ-09 (phụ); Q-206 | Mới |
| BR-142 | Hai yêu cầu cùng sửa một cụm rạp không xen vào nhau: yêu cầu ghi nhận trước thành công; yêu cầu ghi nhận sau bị từ chối, không ghi đè thay đổi trước, và quản lý chuỗi phải mở lại cụm rạp từ đầu. | Ràng buộc | 5, 5a | REQ-54; Q-207 | Mới |
| BR-140 | Vé đã bán giữ tên phim, tên cụm rạp, tên phòng chiếu và loại phòng của lúc bán; sửa các thông tin này sau đó không đổi nội dung vé, lịch sử đặt vé và email đã gửi. | Ràng buộc | Mục 8 | REQ-105; REQ-149 (phụ); Q-203 | Đã có |

## 7. Yêu cầu đặc biệt

Không có

## 8. Thông tin bổ sung

- Luồng chính là kịch bản thêm cụm rạp mới và luồng 1a là sửa cụm rạp, theo hai vế của sự kiện kích hoạt EV-13 "cụm rạp mới hoặc thông tin cụm rạp thay đổi". Nguồn chỉ nêu "quản lý danh sách cụm rạp" (REQ-54) và P00 ghi không tách thao tác. Quản lý chuỗi chọn thêm hoặc sửa thay cho bước 1, nên trên activity diagram decision D-1 đặt ngay sau INIT, trước A-1. Luồng 1a quay về bước 3 để nhập giá trị mới.
- Không có thao tác xoá cụm rạp (Q-205): danh sách cụm rạp chỉ có thêm và sửa.
- Thông tin cụm rạp: nguồn không liệt kê thành phần của cụm rạp. Tên cụm rạp là thông tin ghi trên vé (REQ-105) và địa chỉ là cột bổ sung theo trả lời Q-137 (P13). Tỉnh, thành phố là căn cứ lọc lịch chiếu của khách (REQ-10) và là trường bắt buộc nhập dạng văn bản (Q-204). Số cụm rạp 15 và 5 tỉnh, thành phố (REQ-01) là số liệu quy mô, không đặt giới hạn cho use case này (P02 chuyển P06).
- Phân quyền theo cụm rạp: BR-46 (UC-014) giới hạn quản lý cụm rạp trong phòng chiếu của cụm rạp mình, BR-78 gán mỗi quản lý cụm rạp vào đúng một cụm rạp, quản lý chuỗi không thuộc cụm rạp nào. Use case này chỉ có quản lý chuỗi (RL-16), nên không có kiểm tra phân quyền theo cụm rạp trong luồng. Sửa tên, tỉnh hoặc thành phố, địa chỉ không đổi cụm rạp mà nhân viên, phòng chiếu và bảng giá thuộc về, nên BR-46 và các kiểm tra "cụm rạp của mình" ở UC-005, UC-009, UC-013, UC-014 vẫn đúng sau khi lưu.
- Tên cụm rạp được ghi trên vé (REQ-105). Vé đã bán hiển thị tên lúc bán, không đổi khi cụm rạp đổi tên (BR-140, Q-203).
- Tranh chấp: sửa cụm rạp chỉ tranh chấp với một yêu cầu lưu khác cùng cụm rạp hoặc cùng tên cụm rạp (BR-141, BR-142). Các use case khác chỉ đọc thông tin cụm rạp (UC-004 lọc lịch chiếu, UC-017 gán nhân viên vào cụm rạp, UC-015 báo cáo; chưa đặc tả), đọc trước hoặc sau khi lưu đều hợp lệ nên không cần loại trừ. Cụm rạp không bị xoá (Q-205) nên không có use case nào đang dùng cụm rạp bị mất.
- Bước sinh theo quy tắc của prompt: bước 6 (báo kết quả cho quản lý chuỗi); hành động "Từ chối ... và thông báo" ở luồng 4a; điểm quay lại bước 3 ở luồng 4a vì quản lý chuỗi sửa được dữ liệu vi phạm.
- Không có bước hẹn hoặc huỷ mốc (F4.2 mục 17): P01 không có tác nhân thời gian và không use case nào khởi động theo thời gian dùng dữ liệu cụm rạp làm mốc.

Thao tác nguyên tử

| Thao tác | Bước | Tài nguyên | Bất biến giữ được | Loại trừ với | Kết cục bên thua | Căn cứ |
|---|---|---|---|---|---|---|
| Lưu cụm rạp (thêm hoặc sửa) | 5 | Bản ghi của một cụm rạp, gồm các trường của Dữ liệu vào 1 | Cụm rạp được ghi trọn vẹn: mọi trường cùng lúc, không có cụm rạp nửa cũ nửa mới | Chính nó (hai yêu cầu sửa cùng một cụm rạp); UC-004, UC-015, UC-017 (chưa đặc tả; chỉ đọc, không cần loại trừ) | Chính nó: yêu cầu ghi nhận sau bị từ chối ở luồng 5a, không ghi đè (BR-142); cùng tên: bên ghi nhận sau bị từ chối ở luồng 5b (BR-141). Use case chỉ đọc: thấy cụm rạp trước hoặc sau khi lưu, cả hai đều hợp lệ | BR-141, BR-142, Q-207 |
| Thêm cụm rạp | 5 | Danh sách cụm rạp | Không có hai cụm rạp trùng tên (BR-141); kiểm tra tên và lưu là một thao tác | Chính nó (hai yêu cầu thêm hoặc sửa cùng tên cụm rạp cùng lúc) | Bên ghi nhận sau bị từ chối ở luồng 5b | BR-141, Q-206 |

## 8a. Kịch bản chính

- KB1: Luồng chính --> quản lý chuỗi thêm cụm rạp mới thành công.
- KB2: Luồng 1a --> quản lý chuỗi sửa thông tin cụm rạp đã có thành công; phòng chiếu, suất chiếu, nhân viên của cụm rạp không đổi.
- KB3: Luồng chính + 4a --> thông tin cụm rạp không hợp lệ, quay lại bước 3, nhập lại rồi lưu thành công.
- KB4: Luồng chính + 5b --> tên cụm rạp trùng, quay lại bước 3, nhập lại rồi lưu thành công.
- KB5: Luồng 1a + 5a --> cụm rạp đã bị yêu cầu khác sửa, yêu cầu lưu sau bị từ chối, quản lý chuỗi mở lại cụm rạp từ đầu.
- KB6: Luồng chính + *a --> quản lý chuỗi huỷ yêu cầu, danh sách cụm rạp không đổi.

## 9. Activity diagram

File: diagrams/P04-activity-UC-011.drawio

Bảng đối chiếu

| Bước UC | Node |
|---|---|
| 1 | D-1, A-1 |
| 2 | A-2 |
| 3 | M-3, A-3 |
| 4, 4a | A-4, D-4, A-4a |
| 5 | A-5 |
| 6 | A-6, FINAL-1 |
| 1a1, 1a2, 1a3 | A-1a1, A-1a2, A-1a3 |
| 5a | N-5a |
| 5b | N-5b |
| *a | N-*a |

Bảng Node

| ID | Loại | Nhãn | Stereotype | Thuộc về (container) | Bước UC | Ghi chú |
|---|---|---|---|---|---|---|
| P-ACT-05 | Partition | Quản lý chuỗi | - | - | - | x=0, w=560 |
| P-SYS | Partition | Hệ thống | - | - | - | x=560, w=541 |
| INIT | Initial | - | - | P-ACT-05 | - | x=130, y=60 (tương đối partition) |
| D-1 | Decision | - | - | P-ACT-05 | 1a | x=130, y=130 (tương đối partition) |
| A-1 | Action | Yêu cầu thêm cụm rạp mới | - | P-ACT-05 | 1 | x=60, y=210 (tương đối partition) |
| A-2 | Action | Hiển thị danh sách cụm rạp | - | P-SYS | 2 | x=60, y=210 (tương đối partition) |
| M-3 | Merge | - | - | P-ACT-05 | 4a | x=130, y=330 (tương đối partition) |
| A-3 | Action | Nhập thông tin cụm rạp và gửi | - | P-ACT-05 | 3 | x=60, y=400 (tương đối partition) |
| A-4 | Action | Kiểm tra thông tin cụm rạp hợp lệ | - | P-SYS | 4 | x=60, y=400 (tương đối partition) |
| D-4 | Decision | - | - | P-SYS | 4a | x=130, y=500 (tương đối partition) |
| A-4a | Action | Từ chối: thông tin cụm rạp không hợp lệ | - | P-SYS | 4a | x=320, y=490 (tương đối partition) |
| A-5 | Action | Lưu thông tin cụm rạp | - | P-SYS | 5 | x=60, y=600 (tương đối partition) |
| A-6 | Action | Thông báo lưu cụm rạp thành công | - | P-SYS | 6 | x=60, y=700 (tương đối partition) |
| FINAL-1 | ActivityFinal | - | - | P-SYS | 6 | x=130, y=800 (tương đối partition) |
| A-1a1 | Action | Hiển thị danh sách cụm rạp | - | P-SYS | 1a1 | x=60, y=900 (tương đối partition) |
| A-1a2 | Action | Chọn cụm rạp cần sửa | - | P-ACT-05 | 1a2 | x=300, y=900 (tương đối partition) |
| A-1a3 | Action | Hiển thị thông tin hiện tại của cụm rạp | - | P-SYS | 1a3 | x=60, y=1000 (tương đối partition) |
| N-5a | Note | 5a: Chỉ khi theo luồng 1a: cụm rạp đã bị yêu cầu khác sửa: từ chối lưu, không ghi đè, quay lại 1a1 (BR-142) | - | P-SYS | 5a | x=300, y=660, w=220, h=100 (tương đối partition) |
| N-5b | Note | 5b: Tên cụm rạp đã thuộc cụm rạp khác: từ chối lưu, quay lại bước 3 (BR-141) | - | P-SYS | 5b | x=300, y=780, w=220, h=90 (tương đối partition) |
| N-*a | Note | *a: Tại bất kỳ bước nào trước bước 5, kể cả trong luồng 1a, quản lý chuỗi huỷ yêu cầu: hệ thống không đổi danh sách cụm rạp, kết thúc (thất bại) | - | P-ACT-05 | *a | x=300, y=60 (tương đối partition) |

Bảng Edge

| ID | Nguồn | Đích | Loại quan hệ | Nhãn / multiplicity | Ghi chú | Điểm uốn |
|---|---|---|---|---|---|---|
| E-01 | INIT | D-1 | ControlFlow | - | - | - |
| E-02 | D-1 | A-1 | ControlFlow | [thêm cụm rạp] | - | - |
| E-03 | D-1 | A-1a1 | ControlFlow | [sửa cụm rạp] | - | (290,150); (290,880); (710,880) |
| E-04 | A-1 | A-2 | ControlFlow | - | - | - |
| E-05 | A-2 | M-3 | ControlFlow | - | - | - |
| E-06 | M-3 | A-3 | ControlFlow | - | - | - |
| E-07 | A-3 | A-4 | ControlFlow | - | - | - |
| E-08 | A-4 | D-4 | ControlFlow | - | - | - |
| E-09 | D-4 | A-4a | ControlFlow | [thông tin cụm rạp không hợp lệ] | - | - |
| E-10 | D-4 | A-5 | ControlFlow | [khác] | - | - |
| E-11 | A-4a | M-3 | ControlFlow | - | - | (970,470); (250,470); (250,310); (150,310) |
| E-12 | A-5 | A-6 | ControlFlow | - | - | - |
| E-13 | A-6 | FINAL-1 | ControlFlow | - | - | - |
| E-14 | A-1a1 | A-1a2 | ControlFlow | - | - | - |
| E-15 | A-1a2 | A-1a3 | ControlFlow | - | - | - |
| E-16 | A-1a3 | M-3 | ControlFlow | - | - | (850,1030); (850,300); (150,300) |

Ghi chú sơ đồ: D-1 đặt trong partition của quản lý chuỗi, ngay sau INIT, vì quản lý chuỗi chọn thêm hoặc sửa thay cho bước 1 (F5.2). Luồng 1a3 và luồng 4a quay lại merge node M-3 đặt ngay trước A-3, cùng điểm vào với cạnh từ A-2. Luồng *a chỉ thể hiện bằng note N-*a (F10.2). Cạnh nào không ghi điểm uốn thì đường đi do trình vẽ đặt.

## Câu hỏi mở

| Mã | Câu hỏi | Ảnh hưởng tới | Nguồn gây mơ hồ |
|---|---|---|---|
| Q-204 | Đã trả lời (Theo đề xuất: Trường riêng bắt buộc, quản lý chuỗi nhập dạng văn bản; lọc theo tỉnh, thành phố dùng giá trị đã nhập). Tỉnh, thành phố của cụm rạp (căn cứ khách lọc lịch chiếu theo tỉnh, thành phố, REQ-10) được ghi thế nào: một trường riêng bắt buộc nhập, hay không ghi riêng? | Dữ liệu vào 1 (trường 2), luồng 4a; UC-004; P13 bảng cinema | REQ-10 yêu cầu lọc theo tỉnh, thành phố nhưng REQ-54 và Q-137 không nêu tỉnh, thành phố là thông tin của cụm rạp |
| Q-205 | Đã trả lời (Theo đề xuất: Không có thao tác xoá cụm rạp; danh sách cụm rạp chỉ có thêm và sửa). Quản lý chuỗi có được xoá cụm rạp khỏi danh sách cụm rạp không? Cụm rạp đã có phòng chiếu, suất chiếu, vé hoặc nhân viên được gán thì xử lý thế nào? | Luồng thay thế xoá cụm rạp (chưa viết); hậu điều kiện; Mục 8; UC-012, UC-014, UC-017 | REQ-54 chỉ nêu "quản lý danh sách cụm rạp", P00 ghi chưa tách thao tác vì nguồn không phân biệt |
| Q-206 | Đã trả lời (Theo đề xuất: Không cho trùng tên cụm rạp trong chuỗi (hai cụm cùng tên gây nhầm khi khách chọn cụm rạp, REQ-09); báo vi phạm khi lưu). Hai cụm rạp có được trùng tên không? | Dữ liệu vào 1 (trường 1), bước 4, luồng 4a (hoặc luồng 4b mới) | REQ-54 và REQ-105 không nêu điều kiện duy nhất của tên cụm rạp |
| Q-207 | Đã trả lời (Theo đề xuất: Yêu cầu lưu sau bị từ chối, không ghi đè thay đổi trước, quản lý chuỗi mở lại cụm rạp từ đầu (như BR-60, BR-63)). Hai yêu cầu cùng sửa một cụm rạp (của hai quản lý chuỗi hoặc hai phiên làm việc của cùng một người), hoặc một yêu cầu lưu khi cụm rạp đã bị yêu cầu kia sửa kể từ lúc hiển thị: xử lý thế nào? | Bước 5, luồng 1a (thêm luồng 5a); thao tác nguyên tử Lưu cụm rạp | Nguồn chỉ nêu xử lý đồng thời cho suất chiếu (Mục 16) và bảng giá (Mục 15), không nêu cho cụm rạp |

## Đề xuất sửa artifact trước

| Bước | Mã phần tử | Vấn đề | Đề nghị |
|---|---|---|---|
| P08 | AC-E-Cinema | Lớp chưa có thuộc tính tỉnh, thành phố | Bổ sung thuộc tính tỉnh, thành phố (Q-204) |
| P13 | TBL cinema | Bảng cinema chỉ có tên và địa chỉ, không có tỉnh, thành phố; tên cụm rạp chưa duy nhất | Thêm cột tỉnh, thành phố (bắt buộc, văn bản) và ràng buộc duy nhất của tên cụm rạp (Q-204, Q-206, BR-141) |

## Vấn đề còn mở

- Q-203 (UC-010) áp dụng cho tên cụm rạp trên vé (BR-140).
- Luồng chính có 6 bước, trong khoảng 3-15; use case chỉ có thao tác dữ liệu đơn giản nên không tách thêm bước.
- Bố cục activity diagram đã kiểm: không đường nối nào cắt qua node, không node nào chồng nhau.
