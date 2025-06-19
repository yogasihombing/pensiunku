package com.pensiunku // Pastikan ini sesuai dengan applicationId di build.gradle Anda

import android.app.Application
import android.content.Context
import androidx.multidex.MultiDex // Penting: import ini untuk Multidex

/**
 * Kelas Application kustom untuk aplikasi Flutter Anda.
 * Digunakan untuk melakukan inisialisasi di awal siklus hidup aplikasi native Android.
 */
class Application : Application() { // Nama kelas ini harus sama dengan 'android:name' di AndroidManifest.xml

    /**
     * Metode ini dipanggil sebelum onCreate() Activity atau Service pertama.
     * Ini adalah tempat yang tepat untuk menginisialisasi Multidex.
     */
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this) // Ini adalah baris kunci untuk menginisialisasi Multidex
        // Tambahkan inisialisasi lain yang diperlukan di sini,
        // seperti Firebase atau library native lainnya, jika tidak dilakukan di MainActivity atau Flutter.
    }

    /**
     * Metode ini dipanggil saat Application dibuat.
     * Anda bisa menambahkan inisialisasi lain di sini juga jika diperlukan.
     */
    override fun onCreate() {
        super.onCreate()
        // Contoh: Log.d("Application", "Aplikasi Pensiunku dimulai!")
    }
}
