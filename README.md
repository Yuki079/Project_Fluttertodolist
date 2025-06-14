 ToDoList App
 
 Deskripsi Aplikasi
ToDoList App adalah aplikasi manajemen tugas sederhana yang memungkinkan pengguna untuk:
-Menambahkan tugas harian
-Menandai tugas sebagai selesai
-Menghapus tugas
-Melihat daftar semua tugas
-Menentukan prioritas dan tanggal jatuh tempo
Semua data tersimpan langsung ke database tanpa perlu login atau autentikasi pengguna.

 Halaman
Home Page: Menampilkan daftar semua tugas
Add Task: Form untuk menambahkan tugas baru
Edit Task: Form untuk mengubah detail tugas yang sudah ada

 Database yang Digunakan:
MySQL

Struktur tabel:
tasks: menyimpan data tugas dengan kolom id, title, priority, due_date, dan is_done

 API
API dibuat menggunakan Laravel dengan endpoint berikut:
GET /tasks – Mengambil seluruh tugas
POST /tasks – Menambahkan tugas baru
PUT /tasks/{id} – Mengubah tugas
DELETE /tasks/{id} – Menghapus tugas


 Software yang saya gunakan:
Flutter (Frontend)
Laravel (Backend API)
MySQL (Database)
Laragon (Localhost Server)

 Cara Instalasi
Clone repository ini:
1. [link github](https://github.com/Yuki079/Project_Fluttertodolist)
2. Import file database.sql ke MySQL
3. Jalankan XAMPP / Laragon, aktifkan Apache dan MySQL
4. Letakkan folder backend di dalam htdocs (XAMPP) atau www (Laragon)
5. Ubah konfigurasi koneksi DB di file config.php

Jalankan Flutter dengan:
flutter pub get
flutter run

 Cara Menjalankan:
-Pastikan backend dan database aktif
-Jalankan aplikasi Flutter dari VSCode atau terminal
-Tambahkan, edit, dan kelola tugas melalui UI yang disediakan

 Demo
Video demo aplikasi:
[Demo ToDoList App](https://drive.google.com/file/d/1zwcTb84SZQAbD0kRmMterzS39yPaFFIS/view?usp=sharing)

 Identitas Pembuat
Nama: Muhammad Yuki Al Falah
Kelas: XI RPL 1
Email: yukial074@gmail.com
GitHub:[GitHub saya](https://github.com/Yuki079)
