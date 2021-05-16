CREATE DATABASE `wheel_api` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;


CREATE TABLE `wheels` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ticker` varchar(45) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `subtotal` float NOT NULL DEFAULT '0',
  `positions_closed` tinyint NOT NULL DEFAULT '1',
  `assigned_shares` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `options` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(45) NOT NULL,
  `strike` float NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `premium` float NOT NULL,
  `open` tinyint NOT NULL DEFAULT '1',
  `sale_date` date NOT NULL,
  `exp_date` date NOT NULL,
  `action` varchar(45) NOT NULL DEFAULT 'SELL',
  `wheel_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `fk_options_wheel_idx` (`wheel_id`),
  CONSTRAINT `fk_options_wheel` FOREIGN KEY (`wheel_id`) REFERENCES `wheels` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `shares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `quantity` int NOT NULL DEFAULT '0',
  `cost` float NOT NULL DEFAULT '0',
  `sale_date` date NOT NULL,
  `action` varchar(25) NOT NULL,
  `wheel_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_shares_wheel_idx` (`wheel_id`),
  CONSTRAINT `fk_shares_wheel` FOREIGN KEY (`wheel_id`) REFERENCES `wheels` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
