-- AgriConnect MySQL import
-- Import this file from phpMyAdmin.
CREATE DATABASE IF NOT EXISTS `agriconnect` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `agriconnect`;
SET FOREIGN_KEY_CHECKS=0;
SET SQL_MODE='NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `order_items`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `failed_jobs`;
DROP TABLE IF EXISTS `job_batches`;
DROP TABLE IF EXISTS `jobs`;
DROP TABLE IF EXISTS `cache_locks`;
DROP TABLE IF EXISTS `cache`;
DROP TABLE IF EXISTS `sessions`;
DROP TABLE IF EXISTS `password_reset_tokens`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `migrations`;

CREATE TABLE `migrations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` VARCHAR(255) NOT NULL,
  `batch` INT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
  `password` VARCHAR(255) NOT NULL,
  `remember_token` VARCHAR(100) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  `phone` VARCHAR(255) NULL DEFAULT NULL,
  `address` TEXT NULL,
  `role` ENUM('Admin','Petani','Pembeli') NOT NULL DEFAULT 'Pembeli',
  `avatar` VARCHAR(255) NULL DEFAULT NULL,
  `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  `shop_name` VARCHAR(255) NULL DEFAULT NULL,
  `shop_description` TEXT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `password_reset_tokens` (
  `email` VARCHAR(255) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sessions` (
  `id` VARCHAR(255) NOT NULL,
  `user_id` BIGINT UNSIGNED NULL DEFAULT NULL,
  `ip_address` VARCHAR(45) NULL DEFAULT NULL,
  `user_agent` TEXT NULL,
  `payload` LONGTEXT NOT NULL,
  `last_activity` INT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache` (
  `key` VARCHAR(255) NOT NULL,
  `value` MEDIUMTEXT NOT NULL,
  `expiration` INT NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cache_locks` (
  `key` VARCHAR(255) NOT NULL,
  `owner` VARCHAR(255) NOT NULL,
  `expiration` INT NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `queue` VARCHAR(255) NOT NULL,
  `payload` LONGTEXT NOT NULL,
  `attempts` TINYINT UNSIGNED NOT NULL,
  `reserved_at` INT UNSIGNED NULL DEFAULT NULL,
  `available_at` INT UNSIGNED NOT NULL,
  `created_at` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `job_batches` (
  `id` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `total_jobs` INT NOT NULL,
  `pending_jobs` INT NOT NULL,
  `failed_jobs` INT NOT NULL,
  `failed_job_ids` LONGTEXT NOT NULL,
  `options` MEDIUMTEXT NULL,
  `cancelled_at` INT NULL DEFAULT NULL,
  `created_at` INT NOT NULL,
  `finished_at` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `failed_jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` VARCHAR(255) NOT NULL,
  `connection` TEXT NOT NULL,
  `queue` TEXT NOT NULL,
  `payload` LONGTEXT NOT NULL,
  `exception` LONGTEXT NOT NULL,
  `failed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `categories` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `image` VARCHAR(255) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `products` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `seller_id` BIGINT UNSIGNED NOT NULL,
  `category_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `image` VARCHAR(255) NULL DEFAULT NULL,
  `unit` VARCHAR(255) NOT NULL DEFAULT 'kg',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `products_seller_id_index` (`seller_id`),
  KEY `products_category_id_index` (`category_id`),
  CONSTRAINT `products_seller_id_foreign` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `buyer_id` BIGINT UNSIGNED NOT NULL,
  `order_number` VARCHAR(255) NOT NULL,
  `total_price` DECIMAL(12,2) NOT NULL,
  `status` ENUM('pending','confirmed','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `shipping_address` TEXT NOT NULL,
  `notes` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_order_number_unique` (`order_number`),
  KEY `orders_buyer_id_index` (`buyer_id`),
  KEY `orders_status_index` (`status`),
  CONSTRAINT `orders_buyer_id_foreign` FOREIGN KEY (`buyer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `order_items` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `total_price` DECIMAL(12,2) NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_index` (`order_id`),
  KEY `order_items_product_id_index` (`product_id`),
  CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `reviews` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED NOT NULL,
  `reviewer_id` BIGINT UNSIGNED NOT NULL,
  `order_id` BIGINT UNSIGNED NOT NULL,
  `rating` INT NOT NULL,
  `comment` TEXT NULL,
  `created_at` TIMESTAMP NULL DEFAULT NULL,
  `updated_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reviews_product_id_index` (`product_id`),
  KEY `reviews_reviewer_id_index` (`reviewer_id`),
  KEY `reviews_order_id_index` (`order_id`),
  CONSTRAINT `reviews_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_reviewer_id_foreign` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Data for `migrations`
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
('1', '0001_01_01_000000_create_users_table', '1'),
('2', '0001_01_01_000001_create_cache_table', '1'),
('3', '0001_01_01_000002_create_jobs_table', '1'),
('4', '2024_01_01_000002_update_users_table', '1'),
('5', '2024_01_01_000003_create_categories_table', '1'),
('6', '2024_01_01_000004_create_products_table', '1'),
('7', '2024_01_01_000005_create_orders_table', '1'),
('8', '2024_01_01_000006_create_order_items_table', '1'),
('9', '2024_01_01_000007_create_reviews_table', '1');

-- Data for `users`
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`, `phone`, `address`, `role`, `avatar`, `is_verified`, `shop_name`, `shop_description`) VALUES
('1', 'Admin User', 'admin@agriconnect.com', NULL, '$2y$12$GbKIjRlLoP0GN1TQtbeVwuQCJsorDSepk64svJjpNZc7auQuy/Eky', NULL, '2026-06-11 08:06:12', '2026-06-11 08:06:12', '081234567890', 'Jakarta Pusat', 'Admin', NULL, '1', NULL, NULL),
('2', 'Budi Santoso', 'budi@agriconnect.com', NULL, '$2y$12$Lk8C12AMRy.n95n.jzUMRewBF1GS6vr6NkjhCk0J9Aidjnb.AmLM.', NULL, '2026-06-11 08:06:13', '2026-06-11 08:06:13', '082123456789', 'Karawang, Jawa Barat', 'Petani', NULL, '1', 'Tani Makmur', 'Menjual padi organik berkualitas tinggi'),
('3', 'Siti Nurhaliza', 'siti@agriconnect.com', NULL, '$2y$12$bUDSu1z1TgiCC/svZKA5aOEy8mKof6Q7RcQX22lu/kMZbDe9751PK', NULL, '2026-06-11 08:06:13', '2026-06-11 08:06:13', '083234567890', 'Bandung, Jawa Barat', 'Petani', NULL, '1', 'Sayur Segar Siti', 'Sayuran segar langsung dari kebun'),
('4', 'Rahmat Hidayat', 'rahmat@agriconnect.com', NULL, '$2y$12$0CWKD/bBlaiGQJPWnWnDxOLJarEm0uckC64c8jmUosTgSOFN7/GHW', NULL, '2026-06-11 08:06:13', '2026-06-11 08:06:13', '084345678901', 'Yogyakarta', 'Petani', NULL, '1', 'Buah Organik Rahmat', 'Buah-buahan organik tanpa pestisida'),
('5', 'Dewi Lestari', 'dewi@agriconnect.com', NULL, '$2y$12$NskC.9RPnqlynbz/Q/Tluep9Pjvx63AuEAE19SbLf5tBznvGC68q.', NULL, '2026-06-11 08:06:14', '2026-06-11 08:06:14', '085456789012', 'Surabaya, Jawa Timur', 'Petani', NULL, '1', 'Seafood Segar Dewi', 'Ikan dan seafood segar setiap hari'),
('6', 'Hendra Wijaya', 'hendra@agriconnect.com', NULL, '$2y$12$lNyoW8wjHyFDo2s8yadl.eE8LCkmSY3KOi5PtJqn4jXWQQ/foHfIK', NULL, '2026-06-11 08:06:14', '2026-06-11 08:06:14', '089567890234', 'Medan, Sumatera Utara', 'Petani', NULL, '1', 'Daging Berkualitas Hendra', 'Daging sapi dan ayam premium'),
('7', 'Linda Kusuma', 'linda@agriconnect.com', NULL, '$2y$12$DtZSi7..Wxg8yJ2UUX6RreQgG2hS91JfsU.sG0dn1OWeSTkaOz4NC', NULL, '2026-06-11 08:06:14', '2026-06-11 08:06:14', '081234567901', 'Bogor, Jawa Barat', 'Petani', NULL, '1', 'Bunga & Tanaman Hias Linda', 'Bunga segar dan tanaman hias berkualitas'),
('8', 'Bambang Suryanto', 'bambang@agriconnect.com', NULL, '$2y$12$fIYga4aFUIEUbaFFFEJzW.eLL057tDzzLDsgsyJmZ2yzBTOn1nPmm', NULL, '2026-06-11 08:06:14', '2026-06-11 08:06:14', '082345678901', 'Semarang, Jawa Tengah', 'Petani', NULL, '1', 'Telur Ayam Segar Bambang', 'Telur ayam segar setiap hari'),
('9', 'Nur Hidayati', 'nur@agriconnect.com', NULL, '$2y$12$66eZ7PTPpvFkxfyYVrR8Uu41vWXjIEXKpQbiEoHVlA4/VSZ1KrQlO', NULL, '2026-06-11 08:06:15', '2026-06-11 08:06:15', '083456789012', 'Malang, Jawa Timur', 'Petani', NULL, '1', 'Apel & Jeruk Nur', 'Buah apel dan jeruk impor berkualitas'),
('10', 'Gunawan Pratama', 'gunawan@agriconnect.com', NULL, '$2y$12$6l54IB5wexttLKiCwOamveflZoipoB3sV2X1BLVQEur5DUJdl91ka', NULL, '2026-06-11 08:06:15', '2026-06-11 08:06:15', '084567890123', 'Lampung', 'Petani', NULL, '1', 'Kopi Organik Gunawan', 'Kopi organik premium dari Lampung'),
('11', 'Ratih Handayani', 'ratih@agriconnect.com', NULL, '$2y$12$e7LqSmvsFM3sTWO1AoSXxu4ZvaPGiwHbnEajHav1KPTttRACYovVq', NULL, '2026-06-11 08:06:15', '2026-06-11 08:06:15', '085678901234', 'Bali', 'Petani', NULL, '1', 'Vanilla & Rempah Ratih', 'Vanilla dan rempah-rempah pilihan dari Bali'),
('12', 'Rianto Setiawan', 'rianto@agriconnect.com', NULL, '$2y$12$9AkW2qExiI5aIz19AB/QC.YG4EFzaT84U9stsmaCEtvLr1o42Q5jq', NULL, '2026-06-11 08:06:15', '2026-06-11 08:06:15', '086789012345', 'Cirebon, Jawa Barat', 'Petani', NULL, '1', 'Udang & Ikan Rianto', 'Udang dan ikan air tawar segar'),
('13', 'Susi Mulyani', 'susi@agriconnect.com', NULL, '$2y$12$Ywiwx6PazVourwbmdgwliuPxsrJFGhu3YL6cQquBovN9o/cCoK3nC', NULL, '2026-06-11 08:06:16', '2026-06-11 08:06:16', '087890123456', 'Tasikmalaya, Jawa Barat', 'Petani', NULL, '1', 'Susu & Keju Susi', 'Susu segar dan produk keju homemade'),
('14', 'Widi Santoso', 'widi@agriconnect.com', NULL, '$2y$12$ksYypE5/fLgfws626jWrzueV7RZcqKe2SBpUM/54M4VyEFfJ64BR2', NULL, '2026-06-11 08:06:16', '2026-06-11 08:06:16', '088901234567', 'Banyuwangi, Jawa Timur', 'Petani', NULL, '1', 'Madu Murni Widi', 'Madu murni alami tanpa bahan kimia'),
('15', 'Yuni Wijayanti', 'yuni@agriconnect.com', NULL, '$2y$12$2AJXTrHLcZFaXgXAhFqKFudNpSQ81D8Q2XL0BW7Vd75LZpxUm4B1a', NULL, '2026-06-11 08:06:16', '2026-06-11 08:06:16', '089012345678', 'Klaten, Jawa Tengah', 'Petani', NULL, '1', 'Tahu & Tempe Yuni', 'Tahu dan tempe segar dibuat setiap hari'),
('16', 'Aryo Wicaksono', 'aryo@email.com', NULL, '$2y$12$4IaWppVMPOVVxZJ7O2qsrOkf/JSApKTyCa5jeaWlWAv1xyxH8zd9W', NULL, '2026-06-11 08:06:17', '2026-06-11 08:06:17', '086567890123', 'Jakarta Selatan', 'Pembeli', NULL, '1', NULL, NULL),
('17', 'Lina Wijaya', 'lina@email.com', NULL, '$2y$12$GZuAu9yDZpBeosNVXkJbGei/UkhNZf6ndSSxnxtyqbNa4oc0TCefO', NULL, '2026-06-11 08:06:17', '2026-06-11 08:06:17', '087678901234', 'Tangerang', 'Pembeli', NULL, '1', NULL, NULL),
('18', 'Riko Pratama', 'riko@email.com', NULL, '$2y$12$8SNh7w3vwS5qTHxDsxpKsuCEKqxGJ212Ge7mVgWteledM1kaGp9wK', NULL, '2026-06-11 08:06:17', '2026-06-11 08:06:17', '088789012345', 'Bekasi', 'Pembeli', NULL, '1', NULL, NULL),
('19', 'Eka Putri', 'eka@email.com', NULL, '$2y$12$Qy7BxQ60nse6qlqwbS45U.TzL.anebnrIFjowRfaSE5oICx6Fw2pC', NULL, '2026-06-11 08:06:17', '2026-06-11 08:06:17', '081122334455', 'Jakarta Barat', 'Pembeli', NULL, '1', NULL, NULL),
('20', 'Fajar Hidayat', 'fajar@email.com', NULL, '$2y$12$QqMnrolIdmJKscPXZ9Sw2eqrqmSyseiOG0PxjygOvxh5OWAwaL72C', NULL, '2026-06-11 08:06:18', '2026-06-11 08:06:18', '082233445566', 'Jakarta Timur', 'Pembeli', NULL, '1', NULL, NULL),
('21', 'Gita Murni', 'gita@email.com', NULL, '$2y$12$VV9JCaOg8pCVoEL6QIZM8eoXzq48yeVWTlFr1jWOGgvzc.jwyZnjC', NULL, '2026-06-11 08:06:18', '2026-06-11 08:06:18', '083344556677', 'Depok', 'Pembeli', NULL, '1', NULL, NULL),
('22', 'Haris Dwianto', 'haris@email.com', NULL, '$2y$12$.uDXefdmM/cdRNbej2Gjrupvgg.dHssI4FaYivkO.arnLsP6QJ6j6', NULL, '2026-06-11 08:06:18', '2026-06-11 08:06:18', '084455667788', 'Bogor', 'Pembeli', NULL, '1', NULL, NULL),
('23', 'Irma Sinta', 'irma@email.com', NULL, '$2y$12$C8IYzUMPOwI1GjFQ2Uc.l.vujHzLvDpmIyEG9IDfE1RmjwP51y6gi', NULL, '2026-06-11 08:06:18', '2026-06-11 08:06:18', '085566778899', 'Bandung', 'Pembeli', NULL, '1', NULL, NULL),
('24', 'Joko Hermawan', 'joko@email.com', NULL, '$2y$12$YxUyMgqEgLf06EjFSM6cmOxoqJ9n3lQKByBlKtDRTrZH6EDZXOMkG', NULL, '2026-06-11 08:06:19', '2026-06-11 08:06:19', '086677889900', 'Cirebon', 'Pembeli', NULL, '1', NULL, NULL),
('25', 'Kirana Dewi', 'kirana@email.com', NULL, '$2y$12$8o.MGzJ79DMmcoeKq1bH1OthBxJ67FeChJnzJZJf3poizxjZ0f9oq', NULL, '2026-06-11 08:06:19', '2026-06-11 08:06:19', '087788990011', 'Semarang', 'Pembeli', NULL, '1', NULL, NULL),
('26', 'Lukman Hakim', 'lukman@email.com', NULL, '$2y$12$tuCKZM.LRTsUDGJJVa2qGO2C7FSQ.eUDqDh2EzxYmAKXBtO8tFk2m', NULL, '2026-06-11 08:06:19', '2026-06-11 08:06:19', '088899001122', 'Yogyakarta', 'Pembeli', NULL, '1', NULL, NULL),
('27', 'Mira Ananda', 'mira@email.com', NULL, '$2y$12$93hHnyb/QGeRiIKv.f5Zzebp/c3bpjTryZQgoI6krSpTNmo75e34G', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20', '089900112233', 'Surabaya', 'Pembeli', NULL, '1', NULL, NULL),
('28', 'Nanda Permata', 'nanda@email.com', NULL, '$2y$12$uCgVPDIYZnatNs1Vy40TcuQQzkb6B3eBddRkPMZg5rrG6RF2InIGq', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20', '081011223344', 'Malang', 'Pembeli', NULL, '1', NULL, NULL),
('29', 'Oscar Wijaya', 'oscar@email.com', NULL, '$2y$12$ySDu.AtljDnlKmh4vg6NAuP2IrR1Eiy9tyuiNFNU8.2GtusGTNdOa', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20', '082122334455', 'Medan', 'Pembeli', NULL, '1', NULL, NULL),
('30', 'Puspita Sari', 'puspita@email.com', NULL, '$2y$12$zXski3DmFSFgLlCLuqsjxuIpC1euHqZvj9we6noKsIRlxBWuN/5vi', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20', '083233445566', 'Bali', 'Pembeli', NULL, '1', NULL, NULL);

-- Data for `cache`
INSERT INTO `cache` (`key`, `value`, `expiration`) VALUES
('agriconnect-cache-EiX2dcXv6jaWWouJ', 's:7:"forever";', '2096525255'),
('agriconnect-cache-JPG7J5GitBlNdrGQ', 's:7:"forever";', '2096525374'),
('agriconnect-cache-n8yK83lqpYhEnbVS', 's:7:"forever";', '2096525582'),
('agriconnect-cache-5oO1flGrjZVZ10LS', 's:7:"forever";', '2096525601'),
('agriconnect-cache-dIY3jeVJGNuF0kiX', 's:7:"forever";', '2096526342'),
('agriconnect-cache-tRDljSwlt0OSCfDQ', 's:7:"forever";', '2096526436');

-- Data for `categories`
INSERT INTO `categories` (`id`, `name`, `description`, `image`, `created_at`, `updated_at`) VALUES
('1', 'Padi & Gabah', 'Padi, gabah, dan produk padi-padian', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('2', 'Sayuran', 'Berbagai macam sayuran segar', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('3', 'Buah-Buahan', 'Buah-buahan segar berkualitas', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('4', 'Daging & Unggas', 'Daging sapi, ayam, dan unggas lainnya', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('5', 'Ikan & Seafood', 'Ikan segar dan produk seafood', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('6', 'Susu & Produk Olahan', 'Susu dan produk olahan susu', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('7', 'Bumbu & Rempah', 'Berbagai bumbu dan rempah-rempah', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('8', 'Biji-Bijian', 'Kacang, biji-bijian, dan sejenisnya', NULL, '2026-06-11 08:06:20', '2026-06-11 08:06:20');

-- Data for `products`
INSERT INTO `products` (`id`, `seller_id`, `category_id`, `name`, `description`, `price`, `stock`, `image`, `unit`, `is_active`, `created_at`, `updated_at`) VALUES
('1', '2', '1', 'Padi Organik Premium', 'Padi organik berkualitas tinggi tanpa pestisida', '75000', '500', NULL, 'kg', '1', '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('2', '2', '1', 'Beras Putih Pilihan', 'Beras putih pilihan grade A', '65000', '300', NULL, 'kg', '1', '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('3', '2', '1', 'Beras Merah Organik', 'Beras merah organik kaya nutrisi', '55000', '200', NULL, 'kg', '1', '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('4', '2', '1', 'Gabah Premium', 'Gabah premium siap giling', '45000', '400', NULL, 'kg', '1', '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('5', '3', '2', 'Cabai Merah Segar', 'Cabai merah segar langsung dari kebun', '45000', '200', NULL, 'kg', '1', '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('6', '3', '2', 'Tomat Masak', 'Tomat masak berkualitas', '25000', '150', NULL, 'kg', '1', '2026-06-11 08:06:20', '2026-06-11 08:06:20'),
('7', '3', '2', 'Bayam Segar', 'Bayam hijau segar tanpa pestisida', '15000', '300', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('8', '3', '2', 'Wortel Organik', 'Wortel organik segar', '18000', '250', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('9', '3', '2', 'Kacang Panjang', 'Kacang panjang segar', '30000', '180', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('10', '3', '2', 'Brokoli Segar', 'Brokoli hijau segar berkualitas', '35000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('11', '3', '2', 'Kubis Hijau', 'Kubis hijau segar tanpa pestisida', '12000', '280', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('12', '4', '3', 'Mangga Harum Manis', 'Mangga harum manis premium dari Jawa Timur', '55000', '300', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('13', '4', '3', 'Pisang Cavendish', 'Pisang cavendish segar dan lezat', '20000', '400', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('14', '4', '3', 'Apel Merah Impor', 'Apel merah segar dari Amerika', '75000', '150', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('15', '4', '3', 'Jeruk Mandarin', 'Jeruk mandarin manis', '35000', '200', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('16', '4', '3', 'Pepaya Manis', 'Pepaya manis lokal berkualitas', '22000', '180', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('17', '4', '3', 'Pir Hijau Segar', 'Pir hijau segar manis', '65000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('18', '4', '3', 'Nanas Segar', 'Nanas segar manis', '18000', '250', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('19', '5', '5', 'Ikan Lele Segar', 'Ikan lele segar konsumsi', '85000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('20', '5', '5', 'Udang Segar', 'Udang air tawar segar', '120000', '60', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('21', '5', '5', 'Ikan Patin', 'Ikan patin segar berkualitas', '50000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('22', '5', '5', 'Ikan Gabus', 'Ikan gabus segar air tawar', '95000', '80', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('23', '5', '5', 'Ikan Gurame', 'Ikan gurame segar konsumsi', '70000', '90', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('24', '5', '5', 'Udang Besar Segar', 'Udang besar segar premium', '130000', '50', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('25', '6', '4', 'Daging Sapi Premium', 'Daging sapi pilihan grade A', '150000', '80', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('26', '6', '4', 'Ayam Kampung Segar', 'Ayam kampung segar hidup', '65000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('27', '6', '4', 'Telur Ayam Kampung', 'Telur ayam kampung segar', '28000', '300', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('28', '6', '4', 'Daging Sapi Tanpa Lemak', 'Daging sapi pilihan tanpa lemak', '165000', '60', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('29', '6', '4', 'Ayam Potong Premium', 'Ayam potong premium berkualitas', '55000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('30', '6', '4', 'Telur Puyuh Segar', 'Telur puyuh segar berkualitas', '45000', '150', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('31', '7', '2', 'Bunga Mawar Segar', 'Bunga mawar segar untuk rangkaian', '35000', '100', NULL, 'ikat', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('32', '7', '2', 'Tanaman Hias Bunga', 'Tanaman hias bunga berkualitas', '50000', '50', NULL, 'pot', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('33', '7', '2', 'Bunga Melati Segar', 'Bunga melati segar harum', '25000', '80', NULL, 'ikat', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('34', '7', '2', 'Bunga Anggrek Potong', 'Bunga anggrek potong berkualitas', '60000', '40', NULL, 'tangkai', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('35', '7', '2', 'Tanaman Obat Herbal', 'Tanaman obat herbal segar', '15000', '120', NULL, 'pot', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('36', '7', '2', 'Bunga Matahari Segar', 'Bunga matahari segar cerah', '30000', '70', NULL, 'tangkai', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('37', '8', '4', 'Telur Ayam Segar', 'Telur ayam segar setiap hari', '26000', '400', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('38', '8', '4', 'Telur Puyuh', 'Telur puyuh segar berkualitas', '45000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('39', '8', '4', 'Telur Bebek Segar', 'Telur bebek segar premium', '32000', '150', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('40', '8', '4', 'Telur Omega 3', 'Telur ayam omega 3 berkualitas', '35000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('41', '8', '4', 'Telur Organik Alami', 'Telur organik alami tanpa hormone', '38000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('42', '9', '3', 'Strawberry Premium', 'Strawberry segar premium', '85000', '80', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('43', '9', '3', 'Blueberry Segar', 'Blueberry import segar', '95000', '50', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('44', '9', '3', 'Anggur Merah', 'Anggur merah segar', '60000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('45', '9', '3', 'Alpukat Segar', 'Alpukat segar berkualitas', '45000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('46', '9', '3', 'Kiwi Hijau Segar', 'Kiwi hijau segar manis', '55000', '90', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('47', '9', '3', 'Lemon Segar', 'Lemon segar asam berkualitas', '38000', '110', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('48', '9', '3', 'Persik Segar', 'Persik segar manis import', '70000', '70', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('49', '10', '7', 'Kopi Organik Lampung', 'Kopi organik premium dari Lampung', '120000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('50', '10', '7', 'Kopi Arabika Pilihan', 'Kopi arabika pilihan berkualitas', '150000', '60', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('51', '10', '7', 'Kopi Robusta Premium', 'Kopi robusta premium kuat', '90000', '80', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('52', '10', '7', 'Kopi Specialty Grade', 'Kopi specialty grade terbaik', '180000', '40', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('53', '10', '7', 'Biji Kakao Pilihan', 'Biji kakao pilihan organik', '140000', '50', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('54', '11', '7', 'Vanilla Asli Bali', 'Vanilla asli dari Bali berkualitas', '200000', '30', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('55', '11', '7', 'Lada Hitam Murni', 'Lada hitam premium tanpa campuran', '85000', '50', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('56', '11', '7', 'Kunyit Segar', 'Kunyit segar berkualitas', '35000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('57', '11', '7', 'Jahe Merah Organik', 'Jahe merah organik berkualitas', '45000', '80', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('58', '11', '7', 'Kayu Manis Pilihan', 'Kayu manis pilihan premium', '95000', '40', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('59', '11', '7', 'Pala Biji Asli', 'Pala biji asli dari Banda', '150000', '25', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('60', '11', '7', 'Bawang Putih Pilihan', 'Bawang putih pilihan berkualitas', '50000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('61', '12', '5', 'Udang Besar Segar', 'Udang besar air tawar segar', '130000', '80', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('62', '12', '5', 'Gurame Segar', 'Ikan gurame segar konsumsi', '70000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('63', '12', '5', 'Ikan Mas Segar', 'Ikan mas segar berkualitas', '55000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('64', '12', '5', 'Nila Segar', 'Ikan nila segar konsumsi', '40000', '150', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('65', '12', '5', 'Lele Dumbo Segar', 'Ikan lele dumbo segar premium', '75000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('66', '12', '5', 'Mujair Segar', 'Ikan mujair segar konsumsi', '45000', '110', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('67', '13', '6', 'Susu Segar Murni', 'Susu segar dari peternak lokal', '22000', '200', NULL, 'liter', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('68', '13', '6', 'Keju Cheddar Lokal', 'Keju cheddar buatan sendiri', '90000', '40', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('69', '13', '6', 'Yogurt Segar', 'Yogurt segar homemade', '28000', '150', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('70', '13', '6', 'Mentega Tawar Lokal', 'Mentega tawar buatan sendiri', '85000', '50', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('71', '13', '6', 'Keju Mozarella Segar', 'Keju mozarella segar berkualitas', '75000', '35', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('72', '13', '6', 'Susu Kental Manis Homemade', 'Susu kental manis buatan sendiri', '32000', '100', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('73', '13', '6', 'Krim Asam Segar', 'Krim asam segar premium', '40000', '60', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('74', '14', '7', 'Madu Murni Alami', 'Madu murni dari lebah liar', '180000', '30', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('75', '14', '7', 'Madu dengan Propolis', 'Madu dengan propolis murni', '200000', '25', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('76', '14', '7', 'Madu Pinus Premium', 'Madu pinus premium berkualitas', '220000', '20', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('77', '14', '7', 'Propolis Murni', 'Propolis murni anti inflamasi', '250000', '15', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('78', '14', '7', 'Royal Jelly Segar', 'Royal jelly segar premium', '300000', '10', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('79', '15', '8', 'Tahu Putih Segar', 'Tahu putih segar dibuat harian', '12000', '500', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('80', '15', '8', 'Tempe Organik', 'Tempe organik dibuat setiap hari', '15000', '300', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('81', '15', '8', 'Tahu Goreng', 'Tahu goreng siap saji', '18000', '200', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('82', '15', '8', 'Tahu Kuning', 'Tahu kuning berkualitas', '14000', '250', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('83', '15', '8', 'Tempe Goreng', 'Tempe goreng siap saji', '18000', '180', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21'),
('84', '15', '8', 'Tahu Sutra Premium', 'Tahu sutra premium lembut', '22000', '120', NULL, 'kg', '1', '2026-06-11 08:06:21', '2026-06-11 08:06:21');

SET FOREIGN_KEY_CHECKS=1;
