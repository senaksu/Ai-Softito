
PRAGMA foreign_keys = ON;

-- üyeler tablosu
CREATE TABLE uyeler (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ad TEXT NOT NULL,
    yas INTEGER NOT NULL CHECK (yas > 13),
    sehir TEXT DEFAULT 'Erzincan',
    kayit DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- kitaplar tablosu
CREATE TABLE kitaplar (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    kitap_adi TEXT NOT NULL UNIQUE
);

-- odunc tablosu
CREATE TABLE odunc (
    uye_id INTEGER,
    kitap_id INTEGER,
    gun INTEGER NOT NULL CHECK (gun > 0),
    PRIMARY KEY (uye_id, kitap_id),
    FOREIGN KEY (uye_id) REFERENCES uyeler(id) ON DELETE CASCADE,
    FOREIGN KEY (kitap_id) REFERENCES kitaplar(id)
);

-- 5 kitap ekleme
INSERT INTO kitaplar (kitap_adi) VALUES 
('Dönüşüm'),
('Çavdar Tarlasında Çocuklar'),
('İnsan Neyle Yaşar'),
('Olasılıksız'),
('Aylak Adam');

-- sehir yazdiklarim
INSERT INTO uyeler (ad, yas, sehir) VALUES 
('Baran Çetinkaya', 20, 'İstanbul'),
('Nehir Saygın', 23, 'Ankara'),
('Sarp Danışman', 19, 'İzmir'),
('Bahar Tuncer', 26, 'Bursa'),
('Görkem Karadağ', 21, 'Antalya'),
('Asya Aksoy', 22, 'Trabzon'),
('Kutay Bozkurt', 25, 'Adana');

-- sehir yazmadiklarim (erzincan gelmesi)
INSERT INTO uyeler (ad, yas) VALUES 
('Sima Gürman', 17),
('Oğuz Alpkan', 18),
('Hazal Sezgin', 16);

-- ödünc kayitlari (herkese en az 2 kitap)
INSERT INTO odunc (uye_id, kitap_id, gun) VALUES 
(1, 1, 10), (1, 2, 35),
(2, 2, 7),  (2, 3, 20),
(3, 1, 42), (3, 4, 18),
(4, 3, 12), (4, 5, 31),
(5, 4, 25), (5, 5, 8),
(6, 1, 14), (6, 3, 40),
(7, 2, 19), (7, 4, 22),
(8, 3, 5),  (8, 5, 33),
(9, 1, 28), (9, 2, 11),
(10, 4, 38), (10, 5, 44);

-- üye kitap gün listesi
SELECT u.ad AS uye_adi, k.kitap_adi, o.gun
FROM odunc o
JOIN uyeler u ON o.uye_id = u.id
JOIN kitaplar k ON o.kitap_id = k.id;

-- 30 günden fazla olanlar
SELECT u.ad AS uye_adi, k.kitap_adi, o.gun
FROM odunc o
JOIN uyeler u ON o.uye_id = u.id
JOIN kitaplar k ON o.kitap_id = k.id
WHERE o.gun > 30;

-- sadece erzincan üyeleri
SELECT DISTINCT k.kitap_adi
FROM odunc o
JOIN uyeler u ON o.uye_id = u.id
JOIN kitaplar k ON o.kitap_id = k.id
WHERE u.sehir = 'Erzincan';

-- hiç kitap almayanlar
SELECT u.ad AS uye_adi, k.kitap_adi, o.gun
FROM uyeler u
LEFT JOIN odunc o ON u.id = o.uye_id
LEFT JOIN kitaplar k ON o.kitap_id = k.id;

-- ortalama süre, toplam kitap, max süre
SELECT 
    u.ad,
    COUNT(o.kitap_id) AS kitap_sayisi,
    ROUND(AVG(o.gun), 2) AS ortalama_sure,
    MAX(o.gun) AS en_uzun_sure
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
GROUP BY u.id, u.ad;

-- ortalamasi 20den büyükler
SELECT 
    u.ad,
    ROUND(AVG(o.gun), 2) AS ortalama_sure
FROM uyeler u
JOIN odunc o ON u.id = o.uye_id
GROUP BY u.id, u.ad
HAVING AVG(o.gun) > 20;

-- hangi kitaptan kaç tane alindi
SELECT 
    k.kitap_adi,
    COUNT(o.kitap_id) AS odunc_sayisi
FROM kitaplar k
LEFT JOIN odunc o ON k.id = o.kitap_id
GROUP BY k.id, k.kitap_adi;

-- sehirlerdeki üye sayisi
SELECT 
    sehir,
    COUNT(*) AS uye_sayisi
FROM uyeler
GROUP BY sehir
ORDER BY uye_sayisi DESC;

-- 30 günden fazla tutan uyeler 
SELECT ad 
FROM uyeler 
WHERE id IN (
    SELECT uye_id 
    FROM odunc 
    WHERE gun > 30
);

-- hiç alinmayan kitaplar
SELECT kitap_adi 
FROM kitaplar 
WHERE id NOT IN (
    SELECT DISTINCT kitap_id 
    FROM odunc
);

-- ortalama süreden fazla kalanlar
SELECT * 
FROM odunc 
WHERE gun > (SELECT AVG(gun) FROM odunc);

-- gün durum kontrolü
SELECT 
    uye_id,
    kitap_id,
    gun,
    CASE 
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum
FROM odunc;

-- yas grubu etiketi
SELECT 
    ad,
    yas,
    CASE 
        WHEN yas <= 18 THEN 'Genç'
        ELSE 'Yetişkin'
    END AS yas_grubu
FROM uyeler;

-- durumlara gore toplam sayi
SELECT 
    CASE 
        WHEN gun > 30 THEN 'Gecikmiş'
        WHEN gun BETWEEN 15 AND 30 THEN 'Uyarı'
        ELSE 'Normal'
    END AS durum,
    COUNT(*) AS toplam
FROM odunc
GROUP BY durum;

-- ad sutunu icin index
CREATE INDEX idx_uyeler_ad ON uyeler(ad);

-- eposta ekleme ve unique index
ALTER TABLE uyeler ADD COLUMN eposta TEXT;
CREATE UNIQUE INDEX idx_uyeler_eposta ON uyeler(eposta);