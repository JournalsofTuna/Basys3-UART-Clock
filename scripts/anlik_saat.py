import serial
import time
import datetime

# Basys3'ün portunu buraya yaz (Aygıt yöneticisinden bak: COM3, COM5 vs.)
ser = serial.Serial('COM3', 9600) 
time.sleep(2) # Bağlantı oturması için bekle

now = datetime.datetime.now()
saat_str = now.strftime("%H%M") # Örn: "1543"

print(f"FPGA'ya gönderiliyor: {saat_str}")
ser.write(saat_str.encode()) # Veriyi gönder
ser.close()