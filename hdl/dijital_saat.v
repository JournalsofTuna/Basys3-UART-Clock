`timescale 1ns / 1ps

module dijital_saat(
    input clk,              
    input RsRx,             // USB'den gelen veri
    output [3:0] an,        
    output [7:0] seg        
    );

    // --- DEĞİŞKENLER ---
    reg [26:0] saniye_sayaci = 0;
    reg [5:0] saniye = 0;
    reg [5:0] dakika = 30; 
    reg [4:0] saat = 12;

    // UART ile ilgili değişkenler
    wire [7:0] gelen_veri;
    wire veri_hazir;
    reg [1:0] veri_sirasi = 0; 
    reg [3:0] temp_saat_onlar;
    reg [3:0] temp_saat_birler;
    reg [3:0] temp_dakika_onlar;

    // UART Modülünü çağırıyoruz
    uart_rx receiver (
        .clk(clk),
        .rx(RsRx),
        .data_out(gelen_veri),
        .new_data(veri_hazir)
    );

    // --- TEK MERKEZLİ KONTROL BLOĞU (SORUN ÇÖZÜCÜ) ---
    // Hem saat sayma işlemini hem de UART güncellemesini BURADA yapıyoruz.
    always @(posedge clk) begin
        
        // 1. ÖNCELİK: UART GÜNCELLEMESİ VAR MI?
        if (veri_hazir) begin
            // Sadece rakam geldiyse (ASCII 0-9 arası)
            if (gelen_veri >= 48 && gelen_veri <= 57) begin
                case (veri_sirasi)
                    0: begin 
                        temp_saat_onlar <= gelen_veri - 48;
                        veri_sirasi <= 1;
                    end
                    1: begin 
                        temp_saat_birler <= gelen_veri - 48;
                        veri_sirasi <= 2;
                    end
                    2: begin 
                        temp_dakika_onlar <= gelen_veri - 48;
                        veri_sirasi <= 3;
                    end
                    3: begin 
                        // Son rakam geldi, SAATİ VE DAKİKAYI GÜNCELLE!
                        saat <= (temp_saat_onlar * 10) + temp_saat_birler;
                        dakika <= (temp_dakika_onlar * 10) + (gelen_veri - 48);
                        saniye <= 0;      // Saniyeyi sıfırla
                        saniye_sayaci <= 0; // Sayacı sıfırla ki hemen artmasın
                        veri_sirasi <= 0; // Başa dön
                    end
                endcase
            end
        end
        
        // 2. ÖNCELİK: NORMAL ZAMAN SAYACI
        // Eğer UART güncellemesi o an yapılmıyorsa zamanı saymaya devam et
        else if (saniye_sayaci >= 99999999) begin 
            saniye_sayaci <= 0;
            saniye <= saniye + 1;
            if (saniye == 59) begin
                saniye <= 0;
                dakika <= dakika + 1;
                if (dakika == 59) begin
                    dakika <= 0;
                    saat <= saat + 1;
                    if (saat == 23) saat <= 0;
                end
            end
        end 
        else begin
            // Hiçbir şey olmuyorsa sadece sayacı artır
            saniye_sayaci <= saniye_sayaci + 1;
        end
    end

    // --- EKRAN TARAMA VE BRAM ---
    reg [19:0] tarama_sayaci = 0;
    wire [1:0] aktif_hane_secimi;
    always @(posedge clk) tarama_sayaci <= tarama_sayaci + 1;
    assign aktif_hane_secimi = tarama_sayaci[19:18];

    reg [3:0] gosterilecek_rakam;
    reg [3:0] anot_aktif;

    always @(*) begin
        case(aktif_hane_secimi)
            2'b00: begin // Saat Onlar
                anot_aktif = 4'b0111;
                gosterilecek_rakam = saat / 10;
            end
            2'b01: begin // Saat Birler
                anot_aktif = 4'b1011;
                gosterilecek_rakam = saat % 10;
            end
            2'b10: begin // Dakika Onlar
                anot_aktif = 4'b1101;
                gosterilecek_rakam = dakika / 10;
            end
            2'b11: begin // Dakika Birler
                anot_aktif = 4'b1110;
                gosterilecek_rakam = dakika % 10;
            end
        endcase
    end
    assign an = anot_aktif;

    // BRAM Bağlantısı
    wire [7:0] bram_cikisi;
    blk_mem_gen_0 bram_inst (
      .clka(clk),    
      .addra(gosterilecek_rakam), 
      .douta(bram_cikisi)         
    );
    assign seg = bram_cikisi;

endmodule