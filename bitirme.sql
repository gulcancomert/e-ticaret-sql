DROP DATABASE IF EXISTS bitirme_projesi;
CREATE DATABASE bitirme_projesi
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bitirme_projesi;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Musteri (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(50) NOT NULL,
  soyad VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  sehir VARCHAR(50),
  kayit_tarihi DATE NOT NULL,
  INDEX idx_musteri_sehir (sehir)
) ENGINE=InnoDB;

CREATE TABLE Kategori (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(100) NOT NULL,
  UNIQUE KEY uq_kategori_ad (ad)
) ENGINE=InnoDB;

CREATE TABLE Satici (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(100) NOT NULL,
  adres VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE Urun (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ad VARCHAR(100) NOT NULL,
  fiyat DECIMAL(10,2) NOT NULL,
  maliyet DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  stok INT NOT NULL DEFAULT 0,
  kategori_id INT NOT NULL,
  satici_id INT NOT NULL,
  CONSTRAINT fk_urun_kategori FOREIGN KEY (kategori_id) REFERENCES Kategori(id),
  CONSTRAINT fk_urun_satici FOREIGN KEY (satici_id) REFERENCES Satici(id),
  INDEX idx_urun_kategori (kategori_id),
  INDEX idx_urun_satici (satici_id)
) ENGINE=InnoDB;

CREATE TABLE Siparis (
  id INT AUTO_INCREMENT PRIMARY KEY,
  musteri_id INT NOT NULL,
  tarih DATE NOT NULL,
  toplam_tutar DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  odeme_turu ENUM('Kredi Kartı','Havale','Kapıda Ödeme') NOT NULL,
  CONSTRAINT fk_siparis_musteri FOREIGN KEY (musteri_id) REFERENCES Musteri(id),
  INDEX idx_siparis_musteri (musteri_id),
  INDEX idx_siparis_tarih (tarih)
) ENGINE=InnoDB;

CREATE TABLE Siparis_Detay (
  id INT AUTO_INCREMENT PRIMARY KEY,
  siparis_id INT NOT NULL,
  urun_id INT NOT NULL,
  adet INT NOT NULL CHECK (adet > 0),
  fiyat DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_sd_siparis FOREIGN KEY (siparis_id) REFERENCES Siparis(id),
  CONSTRAINT fk_sd_urun FOREIGN KEY (urun_id) REFERENCES Urun(id),
  INDEX idx_sd_siparis (siparis_id),
  INDEX idx_sd_urun (urun_id)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER trg_sd_after_insert
AFTER INSERT ON Siparis_Detay
FOR EACH ROW
BEGIN
  UPDATE Urun
     SET stok = stok - NEW.adet
   WHERE id = NEW.urun_id;

  UPDATE Siparis s
     JOIN (
       SELECT siparis_id, SUM(adet * fiyat) AS yeni_toplam
         FROM Siparis_Detay
        WHERE siparis_id = NEW.siparis_id
        GROUP BY siparis_id
     ) t ON t.siparis_id = s.id
     SET s.toplam_tutar = t.yeni_toplam;
END$$

CREATE TRIGGER trg_sd_after_delete
AFTER DELETE ON Siparis_Detay
FOR EACH ROW
BEGIN
  UPDATE Urun
     SET stok = stok + OLD.adet
   WHERE id = OLD.urun_id;

  UPDATE Siparis s
     JOIN (
       SELECT sd.siparis_id, IFNULL(SUM(sd.adet * sd.fiyat),0) AS yeni_toplam
         FROM Siparis_Detay sd
        WHERE sd.siparis_id = OLD.siparis_id
        GROUP BY sd.siparis_id
     ) t ON t.siparis_id = s.id
     SET s.toplam_tutar = t.yeni_toplam;
END$$

DELIMITER ;

INSERT INTO Kategori (ad) VALUES
('Elektronik'), ('Giyim'), ('Kitap');

INSERT INTO Satici (ad, adres) VALUES
('TeknoZirve', 'İstanbul'),
('ModaEv', 'İzmir'),
('KitapYurdu', 'Ankara');

INSERT INTO Musteri (ad, soyad, email, sehir, kayit_tarihi) VALUES
('Ali', 'Yılmaz', 'ali@example.com', 'İstanbul', '2024-12-01'),
('Ayşe', 'Demir', 'ayse@example.com', 'Ankara', '2025-01-15'),
('Mehmet', 'Kaya', 'mehmet@example.com', 'İzmir', '2025-02-20'),
('Fatma', 'Çelik', 'fatma@example.com', 'Bursa', '2025-03-05'),
('Zeynep', 'Arslan', 'zeynep@example.com', 'Antalya', '2025-03-18');

INSERT INTO Urun (ad, fiyat, maliyet, stok, kategori_id, satici_id) VALUES
('Kulaklık Pro', 1500.00, 1000.00, 50, (SELECT id FROM Kategori WHERE ad='Elektronik'), (SELECT id FROM Satici WHERE ad='TeknoZirve')),
('Bluetooth Hoparlör', 1200.00, 800.00, 40, (SELECT id FROM Kategori WHERE ad='Elektronik'), (SELECT id FROM Satici WHERE ad='TeknoZirve')),
('Erkek T-Shirt', 250.00, 120.00, 150, (SELECT id FROM Kategori WHERE ad='Giyim'), (SELECT id FROM Satici WHERE ad='ModaEv')),
('Kadın Ceket', 900.00, 500.00, 60, (SELECT id FROM Kategori WHERE ad='Giyim'), (SELECT id FROM Satici WHERE ad='ModaEv')),
('Roman - Başlangıç', 120.00, 60.00, 200, (SELECT id FROM Kategori WHERE ad='Kitap'), (SELECT id FROM Satici WHERE ad='KitapYurdu')),
('Algoritmalar 101', 220.00, 120.00, 80, (SELECT id FROM Kategori WHERE ad='Kitap'), (SELECT id FROM Satici WHERE ad='KitapYurdu')),
('Satılmayan Ürün', 333.00, 200.00, 25, (SELECT id FROM Kategori WHERE ad='Elektronik'), (SELECT id FROM Satici WHERE ad='TeknoZirve'));

INSERT INTO Siparis (musteri_id, tarih, toplam_tutar, odeme_turu) VALUES
((SELECT id FROM Musteri WHERE email='ali@example.com'), '2025-05-10', 0, 'Kredi Kartı'),
((SELECT id FROM Musteri WHERE email='ayse@example.com'), '2025-06-12', 0, 'Havale'),
((SELECT id FROM Musteri WHERE email='mehmet@example.com'), '2025-07-03', 0, 'Kapıda Ödeme'),
((SELECT id FROM Musteri WHERE email='ayse@example.com'), '2025-08-21', 0, 'Kredi Kartı'),
((SELECT id FROM Musteri WHERE email='fatma@example.com'), '2025-09-15', 0, 'Havale');

SET @id_kulaklik = (SELECT id FROM Urun WHERE ad='Kulaklık Pro');
SET @id_roman = (SELECT id FROM Urun WHERE ad='Roman - Başlangıç');
SET @id_ceket = (SELECT id FROM Urun WHERE ad='Kadın Ceket');
SET @id_hoparlor = (SELECT id FROM Urun WHERE ad='Bluetooth Hoparlör');
SET @id_tshirt = (SELECT id FROM Urun WHERE ad='Erkek T-Shirt');
SET @id_algoritma = (SELECT id FROM Urun WHERE ad='Algoritmalar 101');

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(1, @id_kulaklik, 1, 1500.00),
(1, @id_roman, 2, 120.00);

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(2, @id_ceket, 1, 900.00);

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(3, @id_hoparlor, 1, 1200.00),
(3, @id_tshirt, 3, 250.00);

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(4, @id_algoritma, 2, 220.00);

INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat) VALUES
(5, @id_tshirt, 2, 250.00);

UPDATE Urun SET fiyat = 1600.00 WHERE ad = 'Kulaklık Pro';

UPDATE Musteri SET sehir = 'İstanbul' WHERE email = 'mehmet@example.com';

DELETE FROM Siparis_Detay
WHERE siparis_id = 4
  AND urun_id = @id_algoritma
LIMIT 1;

TRUNCATE TABLE Siparis_Detay;

SELECT m.id, m.ad, m.soyad, COUNT(s.id) AS siparis_sayisi
FROM Musteri m
LEFT JOIN Siparis s ON s.musteri_id = m.id
GROUP BY m.id, m.ad, m.soyad
ORDER BY siparis_sayisi DESC, m.id
LIMIT 5;

SELECT u.id, u.ad AS urun_ad, SUM(sd.adet) AS toplam_adet
FROM Urun u
JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY u.id, u.ad
ORDER BY toplam_adet DESC;

SELECT sa.id, sa.ad AS satici_ad,
       SUM(sd.adet * sd.fiyat) AS ciro
FROM Satici sa
JOIN Urun u ON u.satici_id = sa.id
JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY sa.id, sa.ad
ORDER BY ciro DESC;

SELECT sehir, COUNT(*) AS musteri_sayisi
FROM Musteri
GROUP BY sehir
ORDER BY musteri_sayisi DESC;

SELECT k.ad AS kategori,
       SUM(sd.adet * sd.fiyat) AS toplam_satis
FROM Kategori k
JOIN Urun u ON u.kategori_id = k.id
JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY k.id, k.ad
ORDER BY toplam_satis DESC;

SELECT DATE_FORMAT(tarih, '%Y-%m') AS ay,
       COUNT(*) AS siparis_sayisi
FROM Siparis
GROUP BY DATE_FORMAT(tarih, '%Y-%m')
ORDER BY ay;

SELECT s.id AS siparis_id, s.tarih, m.ad AS musteri_ad, m.soyad AS musteri_soyad,
       u.ad AS urun_ad, sd.adet, sd.fiyat,
       sa.ad AS satici_ad, k.ad AS kategori_ad
FROM Siparis s
JOIN Musteri m ON m.id = s.musteri_id
JOIN Siparis_Detay sd ON sd.siparis_id = s.id
JOIN Urun u ON u.id = sd.urun_id
JOIN Satici sa ON sa.id = u.satici_id
JOIN Kategori k ON k.id = u.kategori_id
ORDER BY s.id;

SELECT u.id, u.ad, u.stok
FROM Urun u
LEFT JOIN Siparis_Detay sd ON sd.urun_id = u.id
WHERE sd.id IS NULL;

SELECT m.id, m.ad, m.soyad, m.email
FROM Musteri m
LEFT JOIN Siparis s ON s.musteri_id = m.id
WHERE s.id IS NULL;

SELECT k.ad AS kategori,
       SUM((sd.fiyat - u.maliyet) * sd.adet) AS kazanc
FROM Kategori k
JOIN Urun u ON u.kategori_id = k.id
JOIN Siparis_Detay sd ON sd.urun_id = u.id
GROUP BY k.id, k.ad
ORDER BY kazanc DESC
LIMIT 3;

SELECT s.id, s.tarih, s.toplam_tutar, m.ad, m.soyad
FROM Siparis s
JOIN Musteri m ON m.id = s.musteri_id
WHERE s.toplam_tutar > (SELECT AVG(toplam_tutar) FROM Siparis)
ORDER BY s.toplam_tutar DESC;

SELECT DISTINCT m.id, m.ad, m.soyad, m.email
FROM Musteri m
JOIN Siparis s ON s.musteri_id = m.id
JOIN Siparis_Detay sd ON sd.siparis_id = s.id
JOIN Urun u ON u.id = sd.urun_id
JOIN Kategori k ON k.id = u.kategori_id
WHERE k.ad = 'Elektronik'
ORDER BY m.id;

DELIMITER $$

CREATE PROCEDURE SiparisOlustur(
    IN p_musteri_id INT,
    IN p_urun_id INT,
    IN p_adet INT,
    IN p_odeme_turu ENUM('Kredi Kartı','Havale','Kapıda Ödeme')
)
BEGIN
    DECLARE v_fiyat DECIMAL(10,2);
    DECLARE v_siparis_id INT;

    SELECT fiyat INTO v_fiyat
    FROM Urun
    WHERE id = p_urun_id;

    INSERT INTO Siparis (musteri_id, tarih, toplam_tutar, odeme_turu)
    VALUES (p_musteri_id, CURDATE(), 0, p_odeme_turu);

    SET v_siparis_id = LAST_INSERT_ID();

    INSERT INTO Siparis_Detay (siparis_id, urun_id, adet, fiyat)
    VALUES (v_siparis_id, p_urun_id, p_adet, v_fiyat);
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE EnCokSatanSatici()
BEGIN
    SELECT sa.id, sa.ad AS satici_ad,
           SUM(sd.adet * sd.fiyat) AS toplam_ciro
    FROM Satici sa
    JOIN Urun u ON u.satici_id = sa.id
    JOIN Siparis_Detay sd ON sd.urun_id = u.id
    GROUP BY sa.id, sa.ad
    ORDER BY toplam_ciro DESC
    LIMIT 1;
END$$

DELIMITER ;
