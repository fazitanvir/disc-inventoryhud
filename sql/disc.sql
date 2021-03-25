
-- tablo yapısı dökülüyor regulartests.disc_ammo
CREATE TABLE IF NOT EXISTS `disc_ammo` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `owner` text COLLATE utf8_turkish_ci NOT NULL,
  `hash` text COLLATE utf8_turkish_ci NOT NULL,
  `count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

-- regulartests.disc_ammo: ~1 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `disc_ammo` DISABLE KEYS */;
INSERT INTO `disc_ammo` (`id`, `owner`, `hash`, `count`) VALUES
	(1, 'steam:11000011194f1cc', '-1121678507', 225);
/*!40000 ALTER TABLE `disc_ammo` ENABLE KEYS */;

-- tablo yapısı dökülüyor regulartests.disc_inventory
CREATE TABLE IF NOT EXISTS `disc_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` text COLLATE utf8_turkish_ci NOT NULL,
  `type` text COLLATE utf8_turkish_ci DEFAULT NULL,
  `data` longtext COLLATE utf8_turkish_ci NOT NULL,
  `slot` int(11) NOT NULL DEFAULT 1,
  `drop` text COLLATE utf8_turkish_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

-- regulartests.disc_inventory: ~1 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `disc_inventory` DISABLE KEYS */;
INSERT INTO `disc_inventory` (`id`, `owner`, `type`, `data`, `slot`, `drop`) VALUES
	(1, 'steam:11000011194f1cc', 'player', '{"2":{"serialnumber":"nil","name":"disc_ammo_smg","count":5,"quality":100,"uniq":"nil"},"1":{"serialnumber":"nil","name":"WEAPON_MINISMG","count":1,"quality":100,"uniq":"nil"}}', 1, NULL);
/*!40000 ALTER TABLE `disc_inventory` ENABLE KEYS */;

-- tablo yapısı dökülüyor regulartests.disc_inventory_itemdata
CREATE TABLE IF NOT EXISTS `disc_inventory_itemdata` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` text COLLATE utf8_turkish_ci NOT NULL,
  `description` text COLLATE utf8_turkish_ci DEFAULT NULL,
  `weight` int(11) NOT NULL DEFAULT 0,
  `closeonuse` tinyint(1) NOT NULL DEFAULT 0,
  `max` int(11) NOT NULL DEFAULT 100,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_turkish_ci;

-- regulartests.disc_inventory_itemdata: ~8 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `disc_inventory_itemdata` DISABLE KEYS */;
INSERT INTO `disc_inventory_itemdata` (`id`, `name`, `description`, `weight`, `closeonuse`, `max`) VALUES
	(1, 'WEAPON_PISTOL', 'Silah Tipi Pistol', 1, 0, 1),
	(2, 'WEAPON_MACHINEPISTOL', 'Tec9', 1, 0, 1),
	(3, 'WEAPON_SWITCHBLADE', 'Kelebek Bıçak', 1, 0, 1),
	(4, 'WEAPON_BAT', 'Normal Sopa', 1, 0, 1),
	(5, 'WEAPON_MICROSMG', 'Uzi', 1, 0, 1),
	(6, 'WEAPON_SMG', 'SMG', 1, 0, 1),
	(7, 'WEAPON_SNSPISTOL', 'Ateşli Silah', 1, 0, 1),
	(8, 'bag', 'Canta', 1, 0, 1);
/*!40000 ALTER TABLE `disc_inventory_itemdata` ENABLE KEYS */;

-- tablo yapısı dökülüyor regulartests.disc_serial_number
CREATE TABLE IF NOT EXISTS `disc_serial_number` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) DEFAULT NULL,
  `item` tinytext NOT NULL,
  `number` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `number` (`number`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- regulartests.disc_serial_number: ~0 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `disc_serial_number` DISABLE KEYS */;
/*!40000 ALTER TABLE `disc_serial_number` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
