CREATE DATABASE  IF NOT EXISTS `capstone` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `capstone`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: capstone
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `allergytbl`
--

DROP TABLE IF EXISTS `allergytbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `allergytbl` (
  `allergy_ID` int NOT NULL,
  `Name` varchar(100) NOT NULL,
  PRIMARY KEY (`allergy_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `allergytbl`
--

LOCK TABLES `allergytbl` WRITE;
/*!40000 ALTER TABLE `allergytbl` DISABLE KEYS */;
INSERT INTO `allergytbl` VALUES (1,'견과류'),(2,'연어'),(3,'계란'),(4,'밀가루'),(5,'새우'),(6,'오징어'),(7,'조개');
/*!40000 ALTER TABLE `allergytbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diettbl`
--

DROP TABLE IF EXISTS `diettbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diettbl` (
  `Diet` int NOT NULL,
  `Diet_Name` varchar(255) NOT NULL,
  `Diet_type` varchar(255) DEFAULT NULL,
  `Breakfast` varchar(45) DEFAULT NULL,
  `Lunch` varchar(45) DEFAULT NULL,
  `Dinner` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Diet`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diettbl`
--

LOCK TABLES `diettbl` WRITE;
/*!40000 ALTER TABLE `diettbl` DISABLE KEYS */;
INSERT INTO `diettbl` VALUES (1,'쟝어','체력향상','장어덮밥','장어튀김강정','장어구이'),(2,'닭가슴살','근력 향상','닭가슴 샐러드','닭가슴살 스테이크','닭가슴살 조림'),(3,'사과','체력향상','사과샐러드','사과주스','사과카레'),(4,'소고기','고단백','소불고기 덮밥','소고기 샌드위치','소고기 스테이크');
/*!40000 ALTER TABLE `diettbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ingredienttbl`
--

DROP TABLE IF EXISTS `ingredienttbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredienttbl` (
  `Ingredient` char(8) NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Calorie` int NOT NULL,
  PRIMARY KEY (`Ingredient`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredienttbl`
--

LOCK TABLES `ingredienttbl` WRITE;
/*!40000 ALTER TABLE `ingredienttbl` DISABLE KEYS */;
INSERT INTO `ingredienttbl` VALUES ('1','당근',41),('2','닭가슴살',165),('3','연어',42),('4','시금치',23),('5','현미밥',111);
/*!40000 ALTER TABLE `ingredienttbl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'capstone'
--

--
-- Dumping routines for database 'capstone'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-04-15 15:42:45
