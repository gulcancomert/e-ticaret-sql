# E-Ticaret SQL Veritabanı (Bitirme Projesi)

Bu proje, MySQL üzerinde örnek bir e-ticaret platformu veritabanı tasarlamak ve raporlamalar yapmak amacıyla hazırlanmıştır.  
Müşteri, ürün, satıcı, kategori, sipariş ve siparis_detay tabloları modellenmiş; veri bütünlüğü için birincil/benzersiz anahtarlar, dış anahtarlar, tetikleyiciler (trigger) ve prosedürler kullanılmıştır.  

## İçerik
- bitirme.sql → Veritabanı oluşturma, tablo tanımları, tetikleyiciler, prosedürler ve örnek veriler  
- eer.pdf → ER Diyagramı (veritabanı ilişkilerini gösterir)  
- Bitirme Projesi Raporu.pdf → Projenin akademik raporu  

## Özellikler
- Müşteri, ürün, sipariş, satıcı ve kategori yönetimi  
- Sipariş detayları üzerinden stok takibi  
- Sipariş toplam tutarını otomatik hesaplayan tetikleyici  
- Farklı ödeme türleri (Kredi Kartı, Havale, Kapıda Ödeme) desteği  
- Raporlama için çeşitli sorgular:
  - En çok sipariş veren müşteriler  
  - Kategori bazlı toplam satışlar  
  - Satıcı bazlı ciro  
  - Hiç sipariş vermemiş müşteriler  
  - Hiç satılmamış ürünler  

## Kullanım
Projeyi kendi bilgisayarınızda çalıştırmak için:  

1. Veritabanını oluşturun  
   - MySQL Workbench, phpMyAdmin veya terminal üzerinden:  
     ```bash
     mysql -u root -p < bitirme.sql
     ```  

2. Örnek verileri ekleyin  
   - Script içinde gerekli INSERT INTO komutları yer almaktadır.  

3. Raporlama sorgularını çalıştırın  
   - Örneğin, en çok sipariş veren 5 müşteri:  
     ```sql
     SELECT m.ad, COUNT(s.id) AS siparis_sayisi
     FROM Musteri m
     JOIN Siparis s ON m.id = s.musteri_id
     GROUP BY m.id
     ORDER BY siparis_sayisi DESC
     LIMIT 5;
     ```  

4. ER Diyagramını inceleyin  
   - eer.pdf dosyasını açarak tablolar arasındaki ilişkileri görebilirsiniz.  

