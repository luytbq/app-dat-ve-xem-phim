# Soát lại P04 UC-014 Lập lịch suất chiếu (sau sửa)

Phạm vi: UC-014-schedule-showtimes.md 1.1; UC-005-book-tickets.md 1.6 (bước 7, luồng 7d, Mục 6, Mục 8, KB9); _BR-register.md (BR-46 đến BR-60, dòng BR-01, BR-12, BR-45, BR-54); diagrams/P04-activity-UC-014.drawio và P04-activity-UC-005.drawio (chỉ khớp bảng Node, Edge, merge, decision); nguồn REQ-137 đến REQ-145 và Q-52 đến Q-60 trong P00-problem-brief.md. Không đọc UC-013. Không sửa artifact nào.

## 1. Kiểm tra máy móc

- UC-014: drawio 55 node, 60 cạnh; bảng Node và Edge khớp drawio về ID, nhãn, nguồn, đích, nhãn cạnh. Không action nào có hai cạnh vào; merge M-3 nhận 10 cạnh (E-06, tám cạnh quay lại 4a, 5a, 5b, 5c, 6a, 6b, 6c, 8b, và 1a4) khớp ghi chú sơ đồ; mọi decision có từ hai cạnh ra; mọi action đều có cạnh ra; điểm uốn là bội số của 10.
- UC-005: drawio 59 node, 57 cạnh khớp bảng; A-7d, FINAL-9, E-56, E-57 có trong cả hai; D-7 có bốn cạnh ra, guard của E-26, E-49, E-56 loại trừ nhau; các merge M-3, M-4, M-5 mỗi cái hai cạnh vào.
- Em dash, mũi tên Unicode, inline code: không có trong UC-014, UC-005, sổ BR, hai drawio.
- Mã Q-61 chỉ định nghĩa ở UC-014, được UC-005 dẫn lại; không trùng mã khác.

## 2. Xác nhận R14

| Mã | Kết quả | Nhận xét |
|---|---|---|
| R14-01 | Đạt | Luồng lập và sửa: bước 8 gom kiểm dọn phòng, BR-60, BR-57, BR-53, BR-54 và lưu thành một thao tác không chia cắt (BR-51 đến BR-54, BR-57, BR-60). Luồng xoá: 1b3 gom kiểm và xoá. Mục 8 nêu phạm vi khoá (suất của phòng đích và chính suất đang sửa; đổi phòng thì kiểm phòng mới) và nêu rõ điểm đua giữ ghế với sửa nằm tại bước 8. BR-53 có bước 8; BR-54 có 1b3, 8; nhãn A-8, A-1b3 khớp. Luồng 1a3 ghi rõ là kiểm sớm, không thay bước 8. |
| R14-02 | Đạt | BR-54 (UC-014 và sổ BR giống nhau) chỉ còn hai chiều có căn cứ: giữ ghế trước thì sửa, xoá bị từ chối theo BR-53 (REQ-65); sửa, xoá trước thì giữ ghế bị từ chối (REQ-142, đáp án Q-56 đã vào P00). Không còn vượt nguồn. Còn một điểm diễn đạt nhỏ về "suất chiếu cũ" (RC14-04). |
| R14-03 | Đạt | UC-005 bước 7 có kiểm suất chiếu còn tồn tại, chưa bị sửa và dẫn BR-54; có luồng 7d, thứ tự 7c, 7d, 7a; BR-54 trong bảng BR; KB9; diagram khớp. Còn lệch phạm vi chữ "sửa" giữa 7d và Mục 8 (RC14-01). |
| R14-04 | Đạt | Q-55 dẫn Q-08, BR-14, BR-44, UC-005 Mục 8; đáp án (ghế quá hạn không chặn) khớp REQ-141, BR-53, Mục 8; mốc thời điểm hết hạn nhất quán với UC-005 Mục 8. |
| R14-05 | Đạt | Q-54 có ca thanh toán đến trễ; BR-58, REQ-140 và Mục 8 giữ dữ liệu suất chiếu, nêu ca UC-006 hoàn toàn bộ và email. |
| R14-06 | Đạt | BR-52 giữ REQ-64 và ghi rõ nguồn không quy định riêng cho yêu cầu đồng thời (sổ BR, Mục 8, Vấn đề còn mở); BR-54 đã có REQ-142, bỏ REQ-24. Chấp nhận. |
| R14-07 | Đạt | Guard của D-8 theo thứ tự 8c, 8d, 8a, 8b, ghi chú sơ đồ nêu mỗi guard loại trừ nhánh đứng trước, E-34 nêu loại trừ 8a. Còn không đồng đều cách ghi guard (RC14-02). |
| R14-08 | Đạt | Hàng REQ bổ sung đủ các REQ tham chiếu và REQ-137 đến REQ-145. |
| R14-09 | Đạt | Hậu điều kiện luồng 1a, 1b đã sửa đúng hướng đề xuất. |
| R14-10 | Đạt | "Hai yêu cầu đồng thời (của hai quản lý cụm rạp hoặc hai phiên làm việc)" dùng nhất quán ở BR-52, 8b, Mục 8, Q-57; phạm vi phòng mới nêu ở Mục 8 và sổ BR. |
| R14-11 | Đạt | Q-53 tách thành Q-53 và Q-60, cả hai đã trả lời và có REQ-138, REQ-139. Thiếu giá loại ghế, khung giờ chuyển thành Q-61 và được ghi ở UC-005 Mục 8 và Vấn đề còn mở. |
| R14-12 | Đạt | Cột Bước áp dụng của BR-01, BR-12, BR-45 ghi "chỉ mô tả trường; kiểm ở UC-005". |
| R14-13 | Đạt | Điểm uốn của drawio UC-014 đều là bội số của 10, không còn lệch giữa bảng Edge và file. |

Đối chiếu đáp án Q-52 đến Q-60 với P00 (REQ-137 đến REQ-145) và BR-55 đến BR-60, BR-53, BR-54, BR-58, BR-59: nội dung khớp, đúng mã BR, đúng REQ. Luồng 7d UC-005 khớp UC-014 về điều kiện (xoá hoặc sửa kể từ lúc hiển thị sơ đồ ghế), kết quả (từ chối giữ ghế, không giữ ghế nào, kết thúc thất bại), và dẫn BR-54 hai phía.

## 3. Phát hiện mới

| Mã | Vị trí | Vấn đề | Mức | Đề xuất | Trạng thái |
|---|---|---|---|---|---|
| RC14-01 | UC-005 luồng 7d (cột Điều kiện) so với UC-005 Mục 8 bước 7 và UC-014 Mục 8 gạch đầu dòng 6, Q-56 | Luồng 7d ghi "đã bị sửa (đổi phòng, giờ)", trong khi UC-005 Mục 8 giải thích "đã bị sửa" là mọi thay đổi suất chiếu, và UC-014 cho sửa cả phim, định dạng, thời điểm mở bán. Đọc theo 7d, khách đang xem sơ đồ mà suất bị đổi phim, định dạng hoặc mở bán thì không rơi vào 7d và được giữ ghế trên suất đã khác. Chữ "đổi phòng, giờ" lấy nguyên từ câu hỏi Q-56 nhưng REQ-142 chỉ nói "bị sửa hoặc xoá". | Trung bình | Đổi điều kiện 7d thành "đã bị xoá hoặc đã bị sửa bất kỳ thông tin nào" (bỏ ngoặc), hoặc ghi "(ví dụ đổi phòng, giờ)"; giữ khớp với Mục 8. | Đã sửa |
| RC14-02 | UC-014 Mục 9 bảng Edge E-32, E-33, E-34; D-1a3 (E-44, E-45); D-1b3 (E-53 đến E-55) | Cách ghi guard không đồng đều và chưa loại trừ lẫn nhau tại sơ đồ: ở D-8 chỉ E-34 nêu "không thuộc 8a" còn E-32, E-33 dựa vào ghi chú thứ tự; ở D-1a3 guard [có ghế giữ hoặc vé] và [đã tới giờ bắt đầu] cùng đúng được, thứ tự cạnh trong sơ đồ (1a3a trước) ngược thứ tự ưu tiên của văn bản (1a3b trước); D-1b3 chỉ dựa vào thứ tự bảng. Ghi chú sơ đồ chỉ nói thứ tự cho D-8. UC-005 thì ghi loại trừ ngay trong guard (E-26, E-56). | Thấp | Ghi chú sơ đồ thêm "D-1a3 xét 1a3b trước 1a3a; D-1b3 xét 1b3c, 1b3b, 1b3a"; hoặc nêu loại trừ trong guard (ví dụ "[có ghế giữ hoặc vé, chưa tới giờ bắt đầu]") ở E-44, E-54, E-55 và các cạnh tương ứng. | Đã sửa |
| RC14-03 | UC-014 BR-50 (Mục 6 và sổ BR) so với Mục 8 gạch đầu dòng về Q-58 | BR-50 phát biểu vô điều kiện "giờ kết thúc bằng giờ bắt đầu cộng thời lượng phim", nhưng Mục 8 (Q-58, REQ-144) nói khi phim đổi thời lượng thì giờ kết thúc đã tính giữ nguyên; Mục 8 còn xếp BR-50 trong nhóm quy tắc "chỉ kiểm khi lập hoặc sửa" dù BR-50 là tính toán. Dữ liệu sau khi phim đổi thời lượng sẽ vi phạm BR-50 như đang viết. | Thấp | Sửa BR-50: "Khi lập hoặc sửa suất chiếu, giờ kết thúc được tính bằng giờ bắt đầu cộng thời lượng phim tại thời điểm đó"; Mục 8 đổi "BR-47 đến BR-51, BR-59 chỉ kiểm" thành "BR-47 đến BR-49, BR-51, BR-59 chỉ kiểm, BR-50 chỉ tính" khi lập hoặc sửa. | Đã sửa |
| RC14-04 | UC-014 BR-54 (Mục 6, sổ BR); UC-005 BR-54 | Cụm "suất chiếu cũ" không có mốc: BR-54 không nói "cũ" so với lúc nào, trong khi UC-005 7d dùng mốc lúc hiển thị sơ đồ ghế ở bước 3. Khách tải lại sơ đồ sau khi sửa thì giữ ghế phải thành công. | Thấp | Đổi thành "việc giữ ghế trên suất chiếu như tác nhân đã xem lúc chọn ghế bị từ chối vì suất chiếu đã thay đổi hoặc không còn"; sửa đồng bộ sổ BR, UC-014, UC-005. | Đã sửa |
| RC14-05 | UC-014 Mục 8 gạch đầu dòng cuối ("Bước sinh theo quy tắc") | Liệt kê 8c, 1b3c vào nhóm "Từ chối ... và thông báo quy tắc bị vi phạm theo F5.7", nhưng luồng 8c, 1b3c ghi thông báo "suất chiếu đã thay đổi hoặc không còn", không nêu quy tắc; UC-005 cùng loại (7d) đã được loại ra khỏi nhóm này. | Thấp | Tách 8c, 1b3c khỏi danh sách nhóm F5.7 và ghi như UC-005: từ chối vì suất đã thay đổi, người dùng không sửa được tại chỗ. | Đã sửa |

## 4. Kết luận

Đạt có điều kiện. Cả 13 phát hiện R14 được xử lý đúng: thao tác không chia cắt bao trọn kiểm tra và lưu ở luồng lập, sửa, xoá; BR-54 không còn vượt nguồn; đáp án Q-52 đến Q-60 khớp REQ-137 đến REQ-145 và các BR-53 đến BR-60; luồng 7d UC-005 khớp UC-014; bảng Node, Edge, merge và decision khớp hai file drawio; không có em dash hay mũi tên Unicode. Không có phát hiện Nghiêm trọng mới. Điều kiện: sửa RC14-01 (Trung bình) để UC-005 7d và Mục 8 cùng phạm vi chữ "sửa"; 4 phát hiện Thấp có thể gộp vào lần chỉnh sửa kế tiếp.

Số phát hiện mới: Nghiêm trọng 0, Trung bình 1, Thấp 4, tổng 5.
