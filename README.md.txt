# FPGA Real-Time Clock (UART Controlled & BRAM Based)

Bu proje, Basys 3 (Artix-7) FPGA kartı üzerinde çalışan, bilgisayar kontrollü gerçek zamanlı bir dijital saattir.

Projenin amacı, FPGA üzerindeki **BRAM (Block RAM)** kaynaklarını bir ROM (Look-Up Table) gibi kullanarak 7-segment display sürmek ve **UART** protokolü üzerinden zaman senkronizasyonu sağlamaktır.

## 🎯 Özellikler

* **BRAM Tabanlı Görüntüleme:** 7-segment karakter kodları (0-9) lojik kapılar yerine BRAM hafızasından okunur.
* **UART Senkronizasyonu:** Saat ayarı butonlarla değil, USB üzerinden gönderilen seri veri ile anlık yapılır.
* **Python Desteği:** PC tarafındaki Python scripti, sistem saatini otomatik olarak FPGA'ya aktarır.
* **Optimizasyon:** Veri alımı (RX) ve Saat sayacı tek bir kontrol bloğu (Always block) üzerinde çakışmadan yönetilir.

## 🛠 Kullanılan Donanım ve Yazılım
* **Kart:** Digilent Basys 3 (Xilinx Artix-7 XC7A35T)
* **IDE:** Xilinx Vivado 202x
* **Dil:** Verilog HDL, Python 3
* **Arayüz:** USB-UART (9600 Baud Rate)

## 📂 Dosya Yapısı
* `/hdl`: Verilog kaynak kodları (`dijital_saat.v`, `uart_rx.v`)
* `/constraints`: Pin atamaları (XDC)
* `/scripts`: Saati ayarlayan Python aracı
* `/ip`: BRAM ilklendirme dosyası (.coe)

## 🚀 Nasıl Çalıştırılır?

1.  **Vivado Projesi:**
    * Yeni bir proje oluşturun ve `/hdl` klasöründeki dosyaları ekleyin.
    * IP Catalog'dan "Block Memory Generator" ekleyin.
    * `Single Port ROM` seçin ve `/ip/rakamlar.coe` dosyasını "Load Init File" kısmından yükleyin.
2.  **Bitstream:**
    * Bitstream'i oluşturun ve Basys 3 kartına yükleyin.
    * Ekranda varsayılan olarak `12:30` göreceksiniz.
3.  **Senkronizasyon:**
    * `/scripts/saat_ayarla.py` dosyasını açın ve COM portunu düzenleyin.
    * Scripti çalıştırın:
        ```bash
        python saat_ayarla.py
        ```
    * FPGA ekranı anlık olarak güncellenecektir.

## 🤝 Teşekkür & Notlar
Bu projenin geliştirilmesinde, özellikle UART veri yakalama mantığı ve BRAM adresleme mimarisi üzerine Google Gemini ile pair-programming yapılmıştır.

---
*Geliştirici: Muhammed Tunahan Aydemir*