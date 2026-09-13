# Ươm Mầm — Gameplay Loop

## 0. Tóm tắt một câu
B (người chơi) không làm việc. B **quyết định** A làm gì, bằng gì, và với giá nào.
A là tài nguyên sống — biết mệt, biết cáu, biết bỏ đi.

---

## 1. Ba đồng hồ đếm ngược (3 điều kiện thua)

| Đồng hồ | Ngưỡng | Cảm giác |
|---|---|---|
| **Deadline 30 ngày** | Không đủ $XXX → thua | Nỗi sợ dài hạn, âm ỉ |
| **Nợ cá nhân A** | Quá 3 ngày không trả → thua | Nỗi sợ ngắn hạn, cấp bách |
| **Uất ức của A** | Đầy → A nghỉ việc → thua | Nỗi sợ ẩn, không thấy thanh số |

Ba đồng hồ **đối kháng nhau**. Trả tiền A đúng hạn thì thiếu tiền nâng cấp.
Ép OT để kịp deadline thì Uất ức tăng. Đó là toàn bộ chiều sâu của game.

---

## 2. Vòng lặp 1 ngày — hệ SLOT (không timer thực)

Mỗi ngày = **3 slot làm việc** + các nhịp cố định. Bấm "Kết thúc slot" để trôi.
Không có thanh tiến độ chạy theo giây → người chơi lên kế hoạch, không ngồi chờ.

```
┌─ 8:00 SÁNG ────────────────────────────────┐
│ Trừ bill tự động (ngày/tuần/tháng)         │
│ Mở Điện thoại May Mắn → roll 2-3 task      │
│ Chọn nhận / từ chối (từ chối = giữ Pin)    │
└────────────────────────────────────────────┘
		 ↓
┌─ SLOT 1 / 2 / 3 ───────────────────────────┐
│ Gán task vào slot. Mỗi task ăn 1-2 slot.   │
│ Trước mỗi slot, B can thiệp:               │
│   • Mua cafe / nước tăng lực (+Pin, -$)    │
│   • Bật OT (thêm 1 slot thứ 4, Pin ×1.5,   │
│     +Uất ức, roll biến số)                 │
│   • Nhảy vào làm thay A → MINI-QUIZ        │
│ Sau mỗi slot: roll sự cố (30%)             │
└────────────────────────────────────────────┘
		 ↓
┌─ 22:00 ĐÊM ────────────────────────────────┐
│ Nghiệm thu task xong → $ + Danh tiếng      │
│ Task trễ → màn XIN LỖI (chọn đáp án)       │
│ Chốt sổ. Mua sắm / nâng cấp.               │
│ Ghi SỔ CHIẾN LƯỢC (mở từ ngày 5)           │
│ Ngủ → hồi Pin theo chất lượng đồ đạc       │
└────────────────────────────────────────────┘
```

Thời lượng mục tiêu: **3–4 phút/ngày**. Pause bất kỳ lúc nào (hệ slot pause tự nhiên).

---

## 3. Tài nguyên

### 3.1 Tiền — 3 tầng chi
| Tầng | Gồm | Cảm giác |
|---|---|---|
| Ngày | Ăn uống, điện | Nhỏ, rỉ máu |
| Tuần | Internet, subscription AI | Vừa, đoán trước được |
| Tháng | **Tiền thuê phòng** | Cục nợ treo, gây hoảng |

Tiền vào: tạm ứng khi nhận task (30%) + thanh toán khi nghiệm thu (70%).
→ Tạm ứng tạo bẫy: nhận nhiều task để có tiền mặt, rồi không đủ Pin làm.

### 3.2 Pin A — 100 điểm, 3 vùng
| Vùng | Hành vi |
|---|---|
| 100–60 🟢 | Làm chuẩn, đúng hạn |
| 59–25 🟡 | Kết quả lỗi → khách trừ tiền, trừ Danh tiếng |
| 24–0 🔴 | A từ chối task. Nếu ép OT → roll "cháy sạch", mất trắng 1 ngày |

Hồi Pin: ngủ (base 50) + nệm/đồ gia dụng/máy xịn (tối đa ~85).
→ Lý do thật để mua đồ, không phải trang trí.

### 3.3 Uất ức A — ẩn, KHÔNG hiện thanh số
Chỉ lộ qua **thoại của A ngày càng cộc** và animation (gục bàn, không chào B).

Tăng: OT, ép task lúc Pin đỏ, trả lương trễ, B hứa rồi nuốt lời.
Giảm: trả đúng hạn, cho nghỉ 1 slot, mua quà, chọn đúng thoại an ủi.

Đầy → event "A nghỉ việc" → **GAME OVER**. Có cảnh báo 2 ngày trước qua thoại.

### 3.4 Danh tiếng công ty
Làm 2 việc:
1. Gate chất lượng task roll ra buổi sáng
2. Giảm giá xin gia hạn — khách tin thì dễ tha

### 3.5 Bảng deadline task
UI riêng: task đang nhận, còn mấy ngày, ăn mấy slot, thù lao.

---

## 4. Task — viết như meme, không như hợp đồng

Mỗi task = **1 câu tình huống buồn cười** + 3 số (thù lao / Pin / deadline).
Không bảng điều khoản. Không chữ nhỏ.

```
[DỄ]  Tiệm trà sữa: AI vẽ quảng cáo ra ổ bánh mì mọc 6 ngón tay.
	  $300 · 20 Pin · 2 ngày

[KHÓ] Đại học: bot chấm thi đánh trượt cả khoa vì "luận văn thiếu cảm xúc".
	  $1,500 · 60 Pin · 1 ngày
```

### Mini-quiz "B làm thay A"
Xác suất xuất hiện ~25%/task. 1 câu hỏi kiến thức AI/công nghệ, 4 đáp án.
- Đúng → task xong sớm 1 slot, A đỡ tốn 15 Pin
- Sai → task lỗi, -Danh tiếng, A phải làm lại (+10 Pin)

Rủi ro có thật → người chơi phải cân nhắc, không spam.

---

## 5. Màn XIN LỖI (task trễ)

Không gõ tự do. **3 đáp án có sẵn** — nhưng đáp án đúng **phụ thuộc tính cách khách hàng**,
không cố định. Khách đã gặp thì hiện tag tính cách; khách mới thì phải đoán.

| Tính cách khách | Đáp án ăn |
|---|---|
| Khó tính / doanh nghiệp | Nhận lỗi thẳng + đưa mốc mới cụ thể |
| Xuề xòa / tiệm nhỏ | Thân mật, kể lý do đời thường |
| Sĩ diện / KOL | Tâng bốc, đổ cho "muốn làm kỹ cho xứng" |

Đúng → gia hạn, giữ nguyên tiền. Sai → trừ 40% hợp đồng + Danh tiếng.
→ Thưởng cho người chơi **nhớ khách hàng**, không thưởng cho người chơi viết văn hay.

---

## 6. Sổ Chiến Lược (ẩn, mở từ ngày 5)

Ô nhập từ khóa. Gõ trúng → mở nhánh. Mỗi nhánh có **giá phải trả riêng**, không phải nút thắng.

| Từ khóa | Mở ra | Giá |
|---|---|---|
| `gọi vốn` | Tiền cục từ nhà đầu tư | Mất quyền quyết. VC ép KPI mỗi 5 ngày, trượt là cắt vốn |
| `chạy quảng cáo` | Task roll gấp đôi | Đốt tiền trước. Task rác lẫn vào. Pin A cháy nhanh |
| `tìm nhân tài` | Nhân viên thứ 2 | Lương cố định hàng ngày. 3 ngày đào tạo mới ra việc |
| `làm sản phẩm riêng` | Thu nhập thụ động | 7 ngày không ra $. Gõ sớm gần như chắc thua |
| `ép giá` / `nhận bừa` | Tiền nhanh, task nhiều | Danh tiếng rơi, khóa vĩnh viễn task thơm |
| `nghỉ ngơi` | Reset Uất ức về 0 | Mất trắng 1 ngày |

Gõ trật → A trả lời đùa 1 câu, không phạt. Khuyến khích thử.

---

## 7. Chuyển Phase 2 — 3 CỬA KHÁC NHAU

Đây là chỗ chống tuyến tính. **Không phải cùng một Phase 2 đến sớm hay muộn.**

| Cửa vào | Điều kiện | Phase 2 là game gì |
|---|---|---|
| **Gọi vốn** | Gõ từ khóa + đạt mốc $ | Game đối phó nhà đầu tư: KPI, họp board, nguy cơ bị hất |
| **Sản phẩm riêng** | Sản phẩm sống qua 7 ngày | Game scale: server sập, user chửi, đối thủ copy |
| **Ngày 45 (mặc định)** | Không làm gì đặc biệt | Game trả nợ: bắt đầu với nợ + A đã kiệt sức, ít lựa chọn nhất |

Luật chung Phase 2: chỉ số Pin của A **chuyển sang nhân viên được thuê**.
A lên làm quản lý — và bắt đầu có vấn đề của quản lý.

---

## 8. Thứ tự làm (prototype)

1. Vòng lặp ngày + 3 slot + Pin + tiền 3 tầng  ← chơi được, thấy vui hay không
2. Task pool + roll theo Danh tiếng
3. Uất ức + thoại A biến đổi
4. Màn xin lỗi + tính cách khách
5. Sổ chiến lược + 1 nhánh (gọi vốn)
6. Phase 2

Bước 1 phải vui khi chưa có gì khác. Nếu không, mấy bước sau không cứu được.
