# TimKerja

## Overview & Architecture
- **Flutter application** using a single‑page architecture.
- Core data is managed by **`AppDataController`**, a singleton that holds the hierarchy:
  - **Board** → **List** (custom name, e.g., To Do, Review, …) → **Task** → **Sub‑task**.
- UI screens are placed under `lib/screens/`.  The **Board screen** (`board_screen.dart`) displays the board and now contains the PDF‑export button.
- **PDF generation** is encapsulated in `lib/services/pdf_report_service.dart`.  It constructs a `pw.Document` using the `pdf` package and previews/saves it via the `printing` package.
- Assets for the PDF (logo, branding) are stored in `assets/images/report/`.

## PDF Report Generation Flow
1. **User action** – In the board header’s three‑dot menu the user selects **“Unduh Laporan PDF”**.
2. The UI calls `PdfReportService.generateReport(board)`.
3. The service builds a multi‑page PDF:
   - **Cover page** with the TIMKERJA logo (`assets/images/report/logo_timkerja.png`), project title, board name, and generation date.
   - **Summary table** automatically calculated from the board → list → task → sub‑task hierarchy (total tasks, completed tasks, sub‑task progress).
   - **Detail sections** listing each list, its tasks and sub‑tasks.
   - Charts are omitted for now (future enhancement).
4. The PDF is sent to `Printing.layoutPdf`, which shows a preview and allows the user to save or share the file.

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  pdf: ^3.13.1        # PDF document creation
  printing: ^5.15.1   # Preview and export of PDFs on device
```
Run `flutter pub get` after adding these packages.

## Assets
- **Folder:** `assets/images/report/`
- **Logo file:** `logo_timkerja.png`
  - The PDF service loads the logo with `rootBundle.load('assets/images/report/logo_timkerja.png')`.
  - Replace this file with a different PNG to change the branding without touching code.

## Running the Feature
1. `flutter pub get`
2. Start the app on an emulator or device.
3. Open any board, tap the three‑dot menu on the header, and choose **Unduh Laporan PDF**.
4. A preview appears; you can save or share the generated PDF.

## Future Enhancements (Roadmap)
- Add bar / pie charts to the report (using `charts_flutter` or similar).
- Persist user‑selected export location.
- Include a loading indicator while the PDF is being built for large boards.
- Extend the PDF to include a voting/polling summary from the Project Room.

---
*All code changes are local and have **not** been committed to the remote GitHub repository, per the user’s request.*
