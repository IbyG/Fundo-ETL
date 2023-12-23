-- Fundo.Main definition

CREATE TABLE `Main` (
  `M_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Time` varchar(255) DEFAULT NULL,
  `Record_Type` varchar(255) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `Value` double DEFAULT NULL,
  PRIMARY KEY (`M_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10958 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- Fundo.Sport definition

CREATE TABLE `Sport` (
  `Sport_ID` int(11) NOT NULL AUTO_INCREMENT,
  `KM_Mile` int(11) DEFAULT NULL,
  `Step` int(11) DEFAULT NULL,
  `minHeartRate` int(11) DEFAULT NULL,
  `maxHeartRate` int(11) DEFAULT NULL,
  `sportTime` time DEFAULT NULL,
  `Date` date DEFAULT NULL,
  PRIMARY KEY (`Sport_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=274 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- Fundo.HeartRate definition

CREATE TABLE `HeartRate` (
  `HR_ID` int(11) NOT NULL AUTO_INCREMENT,
  `Heart_Rate` int(11) DEFAULT NULL,
  `Sport_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`HR_ID`),
  KEY `HeartRate_FK` (`Sport_ID`),
  CONSTRAINT `HeartRate_FK` FOREIGN KEY (`Sport_ID`) REFERENCES `Sport` (`Sport_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3444 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
