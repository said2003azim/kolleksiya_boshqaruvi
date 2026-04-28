# Kolleksiya Boshqaruvi — Flutter Loyihasi

Hobi kolleksiyangizni boshqarish uchun mobil ilova.
Kitob, Marka, Tanga va Figura kolleksiyalari uchun universal model.

---

## Funksiyalar

- **CRUD**: Element qo'shish, ko'rish, tahrirlash, o'chirish
- **Rasm**: Kamera yoki galereya orqali rasm yuklash
- **Kategoriyalar**: Kitob, Marka, Tanga, Figura
- **Qidiruv**: Nom va tavsif bo'yicha qidirish
- **Filtrlash**: Kategoriya bo'yicha filtrlash
- **Saralash**: Nom, qiymat, sana bo'yicha saralash
- **Statistika**: Kategoriya bo'yicha soni, qiymati, grafigi
- **PDF eksport**: Barcha kolleksiyani PDF ga chiqarish
- **SQLite**: Ma'lumotlar qurilmada saqlanadi (offline)

---

## O'rnatish

### 1. Flutter o'rnatish

```bash
# Flutter SDK ni yuklab oling: https://flutter.dev/docs/get-started/install
flutter --version  # 3.x.x bo'lishi kerak
```

### 2. Loyihani klonlash

```bash
git clone <your-repo>
cd kolleksiya_boshqaruvi
```

### 3. Paketlarni o'rnatish

```bash
flutter pub get
```

### 4. Qurilmada ishga tushirish

```bash
# Android qurilma yoki emulator ulangan bo'lishi kerak
flutter run

# Release APK yaratish
flutter build apk --release
```

APK fayli: `build/app/outputs/flutter-apk/app-release.apk`

---

## Loyiha strukturasi

```
lib/
├── main.dart                    # Ilova kirish nuqtasi
├── models/
│   ├── item.dart               # CollectionItem modeli
│   └── category.dart           # Kategoriyalar va ranglar
├── database/
│   └── db_helper.dart          # SQLite CRUD operatsiyalari
├── providers/
│   └── collection_provider.dart # State boshqaruvi (Provider)
├── screens/
│   ├── home_screen.dart        # Asosiy ekran (BottomNav)
│   ├── stats_screen.dart       # Statistika ekrani
│   ├── items_screen.dart       # Kolleksiya ro'yxati
│   └── add_edit_screen.dart    # Qo'shish/Tahrirlash
├── widgets/
│   ├── item_card.dart          # Element kartasi
│   └── stat_card.dart          # Statistika kartasi
└── services/
    └── pdf_service.dart        # PDF yaratish va chop etish
```

---

## Paketlar

| Paket | Maqsad |
|-------|--------|
| `sqflite` | SQLite ma'lumotlar bazasi |
| `path` | Fayl yo'llarini boshqarish |
| `image_picker` | Kamera/galereya dan rasm olish |
| `pdf` | PDF hujjat yaratish |
| `printing` | PDF ko'rish va chop etish |
| `provider` | State management |
| `path_provider` | Qurilma papkalariga kirish |
| `intl` | Sana formatlash |

---

## Android ruxsatlar

`AndroidManifest.xml` da quyidagi ruxsatlar qo'shilgan:
- `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` — galereya uchun
- `CAMERA` — kamera uchun
- `WRITE_EXTERNAL_STORAGE` — eski Android uchun

---

## Keyingi bosqichlar (kengaytirish)

- [ ] Qora tema qo'shish (Dark mode)
- [ ] Ma'lumotlarni eksport/import (JSON, CSV)
- [ ] Barcode/QR scanner qo'shish
- [ ] Bulut sinxronizatsiya (Firebase)
- [ ] Widget (ana ekran vidjet)
- [ ] Kolleksiyani boshqalarga ulashish

---

**Muallif**: Individual loyiha  
**Texnologiya**: Flutter + SQLite  
**Platform**: Android & iOS
