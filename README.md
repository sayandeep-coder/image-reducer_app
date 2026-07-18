📸 Photo Size Reducer (Flutter MVP)

A Flutter-based photo compressor and resizer app inspired by Photo Size Reducer
.
The app helps users compress, resize, crop, and convert images with a simple and clean UI — reducing storage usage while maintaining image quality.

🚀 Tech Stack

Framework: Flutter

Image Selection: image_picker
, photo_manager

Image Compression: flutter_image_compress

Image Cropping: image_cropper

State Management: flutter_riverpod

Others: Dart standard libraries

🎯 Core Goal

Enable users to compress, resize, crop, and convert photos easily — focusing on fast performance, clean UX, and reduced storage usage.

🛠 MVP Features

✅ Pick single/multiple photos
✅ Compress images (Small, Medium, Large, Custom)
✅ Resize manually (with aspect ratio option)
✅ Crop with aspect ratios (1:1, 4:3, 16:9, Free)
✅ Convert formats (JPG, PNG, WEBP)
✅ Bulk processing
✅ Save & Share (replace original optional)

lib/
│── app/
│   ├── constants/
│   │   ├── app_assets.dart
│   │   ├── app_strings.dart
│   ├── routes/
│   │   ├── app_router.dart
│   ├── themes/
│       ├── app_theme.dart
│       ├── app_data.dart
│
│── features/
│   ├── auth/
│   │   ├── model/
│   │   ├── repo/
│   │   └── view/
│   │       ├── login_screen.dart
│   │       ├── splash_screen.dart
│   │       └── view_model/
│   │
│   ├── home/
│   │   ├── repo/
│   │   ├── view/
│   │   │   ├── widgets/
│   │   │   │   ├── bottom_nav_bar.dart
│   │   │   │   ├── feature_card.dart
│   │   │   │   ├── advanced_compress_screen.dart
│   │   │   │   ├── compress_photo_screen.dart
│   │   │   │   ├── convert_format_screen.dart
│   │   │   │   ├── crop_compress_screen.dart
│   │   │   │   ├── gallery_screen.dart
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── resize_compress_screen.dart
│   │   │   │   ├── settings_screen.dart
│   │   └── view_model/
│   │       ├── image_processing_view_model.dart
│
│── global/
│   └── widgets/
│
│── main.dart

⚙️ Setup & Installation

Clone the repository

git clone https://github.com/your-username/photo-size-reducer.git
cd photo-size-reducer


Install dependencies

flutter pub get


Run the app

flutter run

📌 Roadmap

 Dark mode support

 Desktop/Web drag-and-drop image selection

 Cloud backup (Google Drive, Dropbox)

 AI-based auto-compression presets

🤝 Contributing

Pull requests are welcome, For major changes, please open an issue first to discuss what you’d like to change.

📜 License

This project is licensed under the MIT License.
