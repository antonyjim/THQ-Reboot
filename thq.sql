-- MySQL dump 10.16  Distrib 10.3.8-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: thq
-- ------------------------------------------------------
-- Server version	10.3.8-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `addrbook`
--

DROP TABLE IF EXISTS `addrbook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `addrbook` (
  `abNonsig` int(11) NOT NULL AUTO_INCREMENT,
  `abOwner` int(9) NOT NULL,
  `abName` varchar(60) NOT NULL,
  `abAcct` int(4) DEFAULT NULL,
  `abAddr1` varchar(90) DEFAULT NULL,
  `abAddr2` varchar(90) DEFAULT NULL,
  `abCity` varchar(90) DEFAULT NULL,
  `abState` char(2) DEFAULT NULL,
  `abPostalCode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`abNonsig`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addrbook`
--

LOCK TABLES `addrbook` WRITE;
/*!40000 ALTER TABLE `addrbook` DISABLE KEYS */;
/*!40000 ALTER TABLE `addrbook` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `disallowedmerchandise`
--

DROP TABLE IF EXISTS `disallowedmerchandise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `disallowedmerchandise` (
  `dmId` int(11) NOT NULL AUTO_INCREMENT,
  `dmAcct` char(36) DEFAULT NULL,
  `dmShipToNonsig` char(36) DEFAULT NULL,
  `dmDept` int(3) DEFAULT NULL,
  `dmCode` int(9) DEFAULT NULL,
  `dmRangeFrom` int(9) DEFAULT NULL,
  `dmRangeTo` int(9) DEFAULT NULL,
  PRIMARY KEY (`dmId`),
  KEY `dmAcct` (`dmAcct`),
  KEY `dmShipToNonsig` (`dmShipToNonsig`),
  CONSTRAINT `disallowedmerchandise_ibfk_1` FOREIGN KEY (`dmAcct`) REFERENCES `nationalaccount` (`naId`) ON UPDATE CASCADE,
  CONSTRAINT `disallowedmerchandise_ibfk_2` FOREIGN KEY (`dmShipToNonsig`) REFERENCES `shiptononsig` (`stnId`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `disallowedmerchandise`
--

LOCK TABLES `disallowedmerchandise` WRITE;
/*!40000 ALTER TABLE `disallowedmerchandise` DISABLE KEYS */;
/*!40000 ALTER TABLE `disallowedmerchandise` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `docproducts`
--

DROP TABLE IF EXISTS `docproducts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `docproducts` (
  `dpKey` int(11) NOT NULL AUTO_INCREMENT,
  `dpDocId` char(36) NOT NULL,
  `dpCode` int(9) NOT NULL,
  `dpDescription` varchar(80) DEFAULT NULL,
  `dpPartsPrice` decimal(7,2) DEFAULT NULL,
  `dpQuantity` int(4) DEFAULT NULL,
  `dpIsRetread` tinyint(1) DEFAULT NULL,
  `dpCustomerOwned` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`dpKey`),
  KEY `dpDocId` (`dpDocId`),
  CONSTRAINT `docproducts_ibfk_1` FOREIGN KEY (`dpDocId`) REFERENCES `documentsonhold` (`dohId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `docproducts`
--

LOCK TABLES `docproducts` WRITE;
/*!40000 ALTER TABLE `docproducts` DISABLE KEYS */;
/*!40000 ALTER TABLE `docproducts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documentsonhold`
--

DROP TABLE IF EXISTS `documentsonhold`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documentsonhold` (
  `dohId` char(36) NOT NULL,
  `dohLastScreen` int(1) DEFAULT NULL,
  `dohLastOpened` date DEFAULT NULL,
  `dohSourceNumber` int(9) NOT NULL,
  `dohDealer` int(9) NOT NULL,
  `dohShipDate` date NOT NULL,
  `dohType` char(1) NOT NULL,
  `dohAcct` int(4) DEFAULT NULL,
  `dohBillToNonsig` int(9) DEFAULT NULL,
  `dohShipToNonsig` int(9) DEFAULT NULL,
  `dohPRAcct` int(2) DEFAULT NULL,
  `dohPRDlrNbr` int(16) DEFAULT NULL,
  `dohVehType` char(2) DEFAULT NULL,
  `dohModifier` int(1) DEFAULT NULL,
  `dohGovModifier` char(1) DEFAULT NULL,
  `dohAdjustment` tinyint(1) DEFAULT NULL,
  `dohFleetHQ` tinyint(1) DEFAULT NULL,
  `dohMassMerchant` tinyint(1) DEFAULT NULL,
  `dohMassMerchantNumber` int(11) DEFAULT NULL,
  `dohShipToId` char(36) DEFAULT NULL,
  `dohBillToId` char(36) DEFAULT NULL,
  `dohFleetHQCall` int(10) DEFAULT NULL,
  `dohCorrectionIndicator` tinyint(1) DEFAULT NULL,
  `dohCorrectionReference` char(36) DEFAULT NULL,
  `dohCorrectionReason` varchar(120) DEFAULT NULL,
  `dohGeoCode` int(9) DEFAULT NULL,
  `dohIsOutOfState` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`dohId`),
  KEY `dohDealer` (`dohDealer`),
  KEY `dohCorrectionReference` (`dohCorrectionReference`),
  CONSTRAINT `documentsonhold_ibfk_1` FOREIGN KEY (`dohCorrectionReference`) REFERENCES `finaldocumentsmast` (`docId`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documentsonhold`
--

LOCK TABLES `documentsonhold` WRITE;
/*!40000 ALTER TABLE `documentsonhold` DISABLE KEYS */;
/*!40000 ALTER TABLE `documentsonhold` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `endpointvalidation`
--

DROP TABLE IF EXISTS `endpointvalidation`;
/*!50001 DROP VIEW IF EXISTS `endpointvalidation`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `endpointvalidation` (
  `navPathName` tinyint NOT NULL,
  `navMethod` tinyint NOT NULL,
  `navActive` tinyint NOT NULL,
  `navPriv` tinyint NOT NULL,
  `rpId` tinyint NOT NULL,
  `rpPriv` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `finaldocumentsmast`
--

DROP TABLE IF EXISTS `finaldocumentsmast`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `finaldocumentsmast` (
  `docId` char(36) NOT NULL,
  `docSubmitted` date DEFAULT NULL,
  `docSourceNumber` int(9) NOT NULL,
  `docB50` int(3) DEFAULT NULL,
  `docDealer` char(36) NOT NULL,
  `docShipDate` date NOT NULL,
  `docType` int(2) NOT NULL,
  `docAcct` int(4) DEFAULT NULL,
  `docBillToNonsig` int(9) DEFAULT NULL,
  `docShipToNonsig` int(9) DEFAULT NULL,
  `docPRAcct` int(2) DEFAULT NULL,
  `docPRDlrNbr` int(16) DEFAULT NULL,
  `docVehType` char(2) DEFAULT NULL,
  `docModifier` int(1) DEFAULT NULL,
  `docAdjustment` tinyint(1) DEFAULT NULL,
  `docIsFleetHQ` tinyint(1) DEFAULT NULL,
  `docIsMassMerchant` tinyint(1) DEFAULT NULL,
  `dohMassMerchantNumber` int(11) DEFAULT NULL,
  `docShipToId` char(36) DEFAULT NULL,
  `docShipToName` varchar(60) NOT NULL,
  `docShipToAddr1` varchar(90) DEFAULT NULL,
  `docShipToAddr2` varchar(90) DEFAULT NULL,
  `docShipToCity` varchar(90) DEFAULT NULL,
  `docShipToState` char(2) DEFAULT NULL,
  `docShipToPostalCode` varchar(10) DEFAULT NULL,
  `docBillToId` char(26) DEFAULT NULL,
  `docBillToName` varchar(60) NOT NULL,
  `docBillToAddr1` varchar(90) DEFAULT NULL,
  `docBillToAddr2` varchar(90) DEFAULT NULL,
  `docBillToCity` varchar(90) DEFAULT NULL,
  `docBillToState` char(2) DEFAULT NULL,
  `docBillToPostalCode` varchar(10) DEFAULT NULL,
  `docFleetHQCall` int(10) DEFAULT NULL,
  `docCorrectionIndicator` tinyint(1) DEFAULT NULL,
  `docCorrectionReference` char(36) DEFAULT NULL,
  `docCorrectionReason` varchar(120) DEFAULT NULL,
  `docGeoCode` int(9) DEFAULT NULL,
  `docIsOutOfState` tinyint(1) DEFAULT NULL,
  `docInvoiceNumber` int(10) DEFAULT NULL,
  `docInvoiceMicroNumber` int(6) DEFAULT NULL,
  `docInvoiceDate` date DEFAULT NULL,
  `docInvoiceLastPrinted` date DEFAULT NULL,
  `docInvoiceIsCreditDebit` tinyint(1) DEFAULT NULL,
  `docInvoiceAmount` int(11) DEFAULT NULL,
  PRIMARY KEY (`docId`),
  KEY `docDealer` (`docDealer`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finaldocumentsmast`
--

LOCK TABLES `finaldocumentsmast` WRITE;
/*!40000 ALTER TABLE `finaldocumentsmast` DISABLE KEYS */;
/*!40000 ALTER TABLE `finaldocumentsmast` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finaldocumentsreqs`
--

DROP TABLE IF EXISTS `finaldocumentsreqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `finaldocumentsreqs` (
  `docReq` int(11) NOT NULL AUTO_INCREMENT,
  `docId` char(36) NOT NULL,
  `docReqKeyWord` char(3) DEFAULT NULL,
  `docReqShortDesc` varchar(40) DEFAULT NULL,
  `docReqValue` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`docReq`),
  KEY `docId` (`docId`),
  CONSTRAINT `finaldocumentsreqs_ibfk_1` FOREIGN KEY (`docId`) REFERENCES `finaldocumentsmast` (`docId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finaldocumentsreqs`
--

LOCK TABLES `finaldocumentsreqs` WRITE;
/*!40000 ALTER TABLE `finaldocumentsreqs` DISABLE KEYS */;
/*!40000 ALTER TABLE `finaldocumentsreqs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nationalaccount`
--

DROP TABLE IF EXISTS `nationalaccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nationalaccount` (
  `naId` char(36) NOT NULL,
  `naNbr` varchar(7) DEFAULT NULL,
  `naNonsig` varchar(7) DEFAULT NULL,
  `naName` varchar(40) DEFAULT NULL,
  `naAddr1` varchar(40) DEFAULT NULL,
  `naAddr2` varchar(40) DEFAULT NULL,
  `naPostalCode` varchar(10) DEFAULT NULL,
  `naCity` varchar(40) DEFAULT NULL,
  `naState` char(2) DEFAULT NULL,
  `naCountry` char(2) DEFAULT NULL,
  `naIsOnCreditHold` tinyint(1) DEFAULT NULL,
  `naIsActive` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`naId`),
  KEY `naNbr` (`naNbr`,`naNonsig`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nationalaccount`
--

LOCK TABLES `nationalaccount` WRITE;
/*!40000 ALTER TABLE `nationalaccount` DISABLE KEYS */;
/*!40000 ALTER TABLE `nationalaccount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `navigation`
--

DROP TABLE IF EXISTS `navigation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `navigation` (
  `navInnerText` varchar(40) NOT NULL,
  `navMethod` varchar(6) NOT NULL DEFAULT 'GET',
  `navPathName` varchar(120) NOT NULL,
  `navQueryString` varchar(120) DEFAULT NULL,
  `navHeader` varchar(40) DEFAULT NULL,
  `navMenu` varchar(40) DEFAULT NULL,
  `navActive` tinyint(1) NOT NULL DEFAULT 1,
  `navPriv` varchar(36) DEFAULT NULL,
  `navIsNotApi` tinyint(1) NOT NULL,
  `navId` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`navId`),
  KEY `navPriv` (`navPriv`),
  CONSTRAINT `navigation_ibfk_1` FOREIGN KEY (`navPriv`) REFERENCES `rolepermissions` (`rpPriv`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `navigation`
--

LOCK TABLES `navigation` WRITE;
/*!40000 ALTER TABLE `navigation` DISABLE KEYS */;
INSERT INTO `navigation` VALUES ('All Routes','GET','/api/admin/getAllRoutes',NULL,NULL,NULL,1,'Site-Admin',0,1),('Privs','GET','/api/admin/getPrivs',NULL,NULL,NULL,1,'Site-Admin',0,2),('Get roles','GET','/api/admin/getRoles',NULL,NULL,NULL,1,'Site-Admin',0,3),('Find existing routes','GET','/api/admin/getRoute',NULL,NULL,NULL,1,'Site-Admin',0,4),('A - National Account','GET','/transactions/deliveries/a',NULL,'Deliveries','Transactions',1,'Create-US-Delivery',1,5),('B - Government Local','GET','/transactions/deliveries/b',NULL,'Deliveries','Transactions',1,'Create-US-Delivery',1,6),('C - Local Price Support','GET','/transactions/deliveries/c',NULL,'Deliveries','Transactions',1,'Create-Delivery',1,7),('D - State Government','GET','/transactions/deliveries/d',NULL,'Deliveries','Transactions',1,'Create-US-Delivery',1,8),('Navigation & Roles','POST','/admin/navroles/navigation',NULL,'Site Administration','Admin',1,'Site-Admin',1,9),('Invoices','GET','/financial/invoices',NULL,'Customer Accounting','Financial',1,'Create-Delivery',1,10),('Claim Form','GET','/financial/claims',NULL,'Customer Accounting','Financial',1,'View-Invoice',1,11),('Manual & Information','GET','/programs/national/manual',NULL,'National Accounts','Dealer Programs',1,'Create-Delivery',1,12),('Find Authorized Navigation','GET','/api/accounts/navigation',NULL,NULL,NULL,1,'un-authed',0,13),('Address Book','GET','/transactions/management/address',NULL,'Delivery Management','Transactions',1,'Create-Delivery',1,17),('Login','POST','/login',NULL,NULL,NULL,1,'un-authed',0,18),('Add Route','POST','/api/admin/addRoute',NULL,NULL,NULL,1,'Site-Admin',0,19),('E - Federal Government','GET','/transactions/deliveries/e',NULL,'Deliveries','Transactions',1,'Create-US-Delivery',1,21),('Modify existing route','POST','/api/admin/updateRoute',NULL,NULL,NULL,1,'Site-Admin',0,22),('Refresh Token','GET','/api/refresh',NULL,NULL,NULL,1,'un-authed',0,23),('Add a new role / privilege','POST','/api/admin/roles/add',NULL,NULL,NULL,1,'Site-Admin',0,24),('Update existing role','POST','/api/admin/roles/update',NULL,NULL,NULL,1,'Site-Admin',0,25),('Remove a privilege from a role','POST','/api/admin/roles/remove',NULL,NULL,NULL,1,'Site-Admin',0,26),('N - US National Account','GET','/transactions/deliveries/n',NULL,'Deliveries','Transactions',1,'Create-CA-Delivery',1,27),('Customers','GET','/admin/customers/',NULL,'Customer Maintenance','Admin',1,'Maint-Customer',1,28),('Users','GET','/admin/users',NULL,'Site Administration','Admin',1,'Site-Admin',1,29);
/*!40000 ALTER TABLE `navigation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nsaccess`
--

DROP TABLE IF EXISTS `nsaccess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nsaccess` (
  `nsaUserId` char(36) NOT NULL,
  `nsaNonsig` binary(9) NOT NULL,
  `nsaRole` char(7) NOT NULL,
  `nsaIsAdmin` tinyint(1) NOT NULL DEFAULT 0,
  KEY `nsaNonsig` (`nsaNonsig`),
  KEY `nsaUserId` (`nsaUserId`),
  KEY `nsaRole` (`nsaRole`),
  CONSTRAINT `nsaccess_ibfk_1` FOREIGN KEY (`nsaNonsig`) REFERENCES `nsinfo` (`nsNonsig`) ON UPDATE CASCADE,
  CONSTRAINT `nsaccess_ibfk_3` FOREIGN KEY (`nsaUserId`) REFERENCES `userregistration` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nsaccess_ibfk_4` FOREIGN KEY (`nsaRole`) REFERENCES `rolepermissions` (`rpId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nsaccess`
--

LOCK TABLES `nsaccess` WRITE;
/*!40000 ALTER TABLE `nsaccess` DISABLE KEYS */;
INSERT INTO `nsaccess` VALUES ('b42a1170-096a-11e9-b568-0800200c9a66','466393271','SiteAdm',1);
/*!40000 ALTER TABLE `nsaccess` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nsinfo`
--

DROP TABLE IF EXISTS `nsinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nsinfo` (
  `nsNonsig` binary(9) NOT NULL,
  `nsTradeStyle` varchar(100) NOT NULL,
  `nsAddr1` varchar(40) DEFAULT NULL,
  `nsAddr2` varchar(40) DEFAULT NULL,
  `nsCity` varchar(40) DEFAULT NULL,
  `nsState` char(2) DEFAULT NULL,
  `nsPostalCode` varchar(10) DEFAULT NULL,
  `nsCountry` char(2) DEFAULT 'US',
  `nsBrandKey` varchar(4) DEFAULT NULL,
  `nsIsActive` tinyint(1) DEFAULT 1,
  `nsIsActiveTHQ` tinyint(1) DEFAULT 1,
  `nsType` char(3) DEFAULT NULL,
  PRIMARY KEY (`nsNonsig`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nsinfo`
--

LOCK TABLES `nsinfo` WRITE;
/*!40000 ALTER TABLE `nsinfo` DISABLE KEYS */;
INSERT INTO `nsinfo` VALUES ('466393271','Goodyear Tire and Rubber Company','200 Innovation Way',NULL,'Akron','OH','44302','US',NULL,1,1,NULL);
/*!40000 ALTER TABLE `nsinfo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requirementacceptablevalues`
--

DROP TABLE IF EXISTS `requirementacceptablevalues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `requirementacceptablevalues` (
  `ravId` char(36) NOT NULL,
  `ravMask` varchar(40) DEFAULT NULL,
  `ravValue` varchar(40) NOT NULL,
  `ravKeyWord` char(3) NOT NULL,
  `ravAcct` char(36) NOT NULL,
  `ravNonsig` char(36) DEFAULT NULL,
  PRIMARY KEY (`ravId`),
  KEY `ravKeyWord` (`ravKeyWord`),
  KEY `ravAcct` (`ravAcct`),
  KEY `ravNonsig` (`ravNonsig`),
  CONSTRAINT `requirementacceptablevalues_ibfk_1` FOREIGN KEY (`ravKeyWord`) REFERENCES `requirementelements` (`reKeyWord`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `requirementacceptablevalues_ibfk_2` FOREIGN KEY (`ravAcct`) REFERENCES `nationalaccount` (`naId`) ON UPDATE CASCADE,
  CONSTRAINT `requirementacceptablevalues_ibfk_3` FOREIGN KEY (`ravNonsig`) REFERENCES `shiptononsig` (`stnId`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requirementacceptablevalues`
--

LOCK TABLES `requirementacceptablevalues` WRITE;
/*!40000 ALTER TABLE `requirementacceptablevalues` DISABLE KEYS */;
/*!40000 ALTER TABLE `requirementacceptablevalues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requirementattributes`
--

DROP TABLE IF EXISTS `requirementattributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `requirementattributes` (
  `raKey` int(7) NOT NULL AUTO_INCREMENT,
  `raKeyWord` char(3) DEFAULT NULL,
  `raAttributeName` varchar(20) DEFAULT NULL,
  `raAttributeValue` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`raKey`),
  KEY `raKeyWord` (`raKeyWord`),
  CONSTRAINT `requirementattributes_ibfk_1` FOREIGN KEY (`raKeyWord`) REFERENCES `requirementelements` (`reKeyWord`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requirementattributes`
--

LOCK TABLES `requirementattributes` WRITE;
/*!40000 ALTER TABLE `requirementattributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `requirementattributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `requirementelements`
--

DROP TABLE IF EXISTS `requirementelements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `requirementelements` (
  `reKeyWord` char(3) NOT NULL,
  `reShortDesc` varchar(40) DEFAULT NULL,
  `reId` varchar(20) DEFAULT NULL,
  `reHasHelp` tinyint(1) DEFAULT NULL,
  `reHelpURL` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`reKeyWord`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `requirementelements`
--

LOCK TABLES `requirementelements` WRITE;
/*!40000 ALTER TABLE `requirementelements` DISABLE KEYS */;
/*!40000 ALTER TABLE `requirementelements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rolepermissions`
--

DROP TABLE IF EXISTS `rolepermissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rolepermissions` (
  `rpId` char(9) NOT NULL,
  `rpPriv` varchar(36) NOT NULL,
  PRIMARY KEY (`rpId`,`rpPriv`),
  KEY `rpPriv` (`rpPriv`),
  KEY `rpId` (`rpId`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rolepermissions`
--

LOCK TABLES `rolepermissions` WRITE;
/*!40000 ALTER TABLE `rolepermissions` DISABLE KEYS */;
INSERT INTO `rolepermissions` VALUES ('CAStore','Create-CA-Delivery'),('CAStore','Create-Delivery'),('CAStore','un-authed'),('CAStore','View-Invoice'),('GYRepre','Maint-Customer'),('GYRepre','un-authed'),('SiteAdm','Create-CA-Delivery'),('SiteAdm','Create-Delivery'),('SiteAdm','Create-US-Delivery'),('SiteAdm','Maint-Customer'),('SiteAdm','Site-Admin'),('SiteAdm','un-authed'),('SiteAdm','View-Invoice'),('USStore','Create-Delivery'),('USStore','Create-US-Delivery'),('USStore','un-authed'),('USStore','View-Invoice');
/*!40000 ALTER TABLE `rolepermissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shiptononsig`
--

DROP TABLE IF EXISTS `shiptononsig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shiptononsig` (
  `stnId` char(36) NOT NULL,
  `stnAcct` char(36) DEFAULT NULL,
  `stnNonsig` varchar(7) DEFAULT NULL,
  `stnName` varchar(40) DEFAULT NULL,
  `stnAddr1` varchar(40) DEFAULT NULL,
  `stnAddr2` varchar(40) DEFAULT NULL,
  `stnPostalCode` varchar(10) DEFAULT NULL,
  `stnCity` varchar(40) DEFAULT NULL,
  `stnState` char(2) DEFAULT NULL,
  `stnCountry` char(2) DEFAULT NULL,
  PRIMARY KEY (`stnId`),
  KEY `stnAcct` (`stnAcct`),
  CONSTRAINT `shiptononsig_ibfk_1` FOREIGN KEY (`stnAcct`) REFERENCES `nationalaccount` (`naId`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shiptononsig`
--

LOCK TABLES `shiptononsig` WRITE;
/*!40000 ALTER TABLE `shiptononsig` DISABLE KEYS */;
/*!40000 ALTER TABLE `shiptononsig` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `uinavigation`
--

DROP TABLE IF EXISTS `uinavigation`;
/*!50001 DROP VIEW IF EXISTS `uinavigation`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `uinavigation` (
  `navHref` tinyint NOT NULL,
  `navInnerText` tinyint NOT NULL,
  `navHeader` tinyint NOT NULL,
  `navMenu` tinyint NOT NULL,
  `navIsNotApi` tinyint NOT NULL,
  `rpid` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `useraccess`
--

DROP TABLE IF EXISTS `useraccess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `useraccess` (
  `accessKey` int(11) NOT NULL AUTO_INCREMENT,
  `userId` char(36) NOT NULL,
  `accessId` int(6) NOT NULL,
  `accessHref` varchar(100) DEFAULT NULL,
  `accessInnerText` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`accessKey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `useraccess`
--

LOCK TABLES `useraccess` WRITE;
/*!40000 ALTER TABLE `useraccess` DISABLE KEYS */;
/*!40000 ALTER TABLE `useraccess` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userinformation`
--

DROP TABLE IF EXISTS `userinformation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userinformation` (
  `userId` char(36) NOT NULL,
  `userLastLogin` date DEFAULT NULL,
  `userLastPasswordChange` date DEFAULT NULL,
  `userFirstName` varchar(30) DEFAULT NULL,
  `userLastName` varchar(30) DEFAULT NULL,
  `userPhone` varchar(13) DEFAULT NULL,
  PRIMARY KEY (`userId`),
  CONSTRAINT `userinformation_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `userregistration` (`userId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userinformation`
--

LOCK TABLES `userinformation` WRITE;
/*!40000 ALTER TABLE `userinformation` DISABLE KEYS */;
INSERT INTO `userinformation` VALUES ('4c92aff5-4225-4b8d-9c73-947866d6ea24',NULL,NULL,'Goodyear','Rep','2164527492'),('d50b36a8-6258-4f6c-a9ed-f843f0dd8654',NULL,NULL,'Anthony','Jund','315746132');
/*!40000 ALTER TABLE `userinformation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `userlogin`
--

DROP TABLE IF EXISTS `userlogin`;
/*!50001 DROP VIEW IF EXISTS `userlogin`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `userlogin` (
  `userId` tinyint NOT NULL,
  `userName` tinyint NOT NULL,
  `userPass` tinyint NOT NULL,
  `userEmail` tinyint NOT NULL,
  `userIsConfirmed` tinyint NOT NULL,
  `userIsLocked` tinyint NOT NULL,
  `userInvalidLoginAttempts` tinyint NOT NULL,
  `userNonsig` tinyint NOT NULL,
  `nsIsActive` tinyint NOT NULL,
  `userRole` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `userregistration`
--

DROP TABLE IF EXISTS `userregistration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userregistration` (
  `userId` char(36) NOT NULL,
  `userName` varchar(36) NOT NULL,
  `userPass` binary(60) DEFAULT NULL,
  `userEmail` varchar(90) NOT NULL,
  `userIsLocked` tinyint(1) NOT NULL,
  `userAdministrator` char(36) DEFAULT NULL,
  `userIsConfirmed` tinyint(1) NOT NULL DEFAULT 0,
  `userConfirmationToken` varchar(120) DEFAULT NULL,
  `userInvalidLoginAttempts` int(1) DEFAULT NULL,
  `userDefaultNonsig` binary(9) NOT NULL,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `userName` (`userName`),
  KEY `userName_2` (`userName`),
  KEY `userDefaultNonsig` (`userDefaultNonsig`),
  KEY `userAdministrator` (`userAdministrator`),
  CONSTRAINT `userregistration_ibfk_1` FOREIGN KEY (`userDefaultNonsig`) REFERENCES `nsinfo` (`nsNonsig`) ON UPDATE CASCADE,
  CONSTRAINT `userregistration_ibfk_2` FOREIGN KEY (`userAdministrator`) REFERENCES `userregistration` (`userId`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userregistration`
--

LOCK TABLES `userregistration` WRITE;
/*!40000 ALTER TABLE `userregistration` DISABLE KEYS */;
INSERT INTO `userregistration` VALUES ('4c92aff5-4225-4b8d-9c73-947866d6ea24','gyrep',NULL,'anthonyjund2@hotmail.com',0,NULL,0,NULL,NULL,'466393271'),('b42a1170-096a-11e9-b568-0800200c9a66','administrator','$2a$10$r.Nlitz0cVeWeuVa4Lf/Sugw/LZlwBPEZGSqYU52KRz1Be73Dgwsi','antonyjund@gmail.com',0,NULL,1,NULL,NULL,'466393271'),('d50b36a8-6258-4f6c-a9ed-f843f0dd8654','gyhelps',NULL,'antonyjund@goodyear.com',0,NULL,1,NULL,NULL,'466393271');
/*!40000 ALTER TABLE `userregistration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `endpointvalidation`
--

/*!50001 DROP TABLE IF EXISTS `endpointvalidation`*/;
/*!50001 DROP VIEW IF EXISTS `endpointvalidation`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aj`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `endpointvalidation` AS select `navigation`.`navPathName` AS `navPathName`,`navigation`.`navMethod` AS `navMethod`,`navigation`.`navActive` AS `navActive`,`navigation`.`navPriv` AS `navPriv`,`rolepermissions`.`rpId` AS `rpId`,`rolepermissions`.`rpPriv` AS `rpPriv` from (`navigation` join `rolepermissions` on(`navigation`.`navPriv` = `rolepermissions`.`rpPriv`)) where `navigation`.`navActive` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `uinavigation`
--

/*!50001 DROP TABLE IF EXISTS `uinavigation`*/;
/*!50001 DROP VIEW IF EXISTS `uinavigation`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aj`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `uinavigation` AS select concat(`navigation`.`navPathName`,'?',ifnull(`navigation`.`navQueryString`,'')) AS `navHref`,`navigation`.`navInnerText` AS `navInnerText`,`navigation`.`navHeader` AS `navHeader`,`navigation`.`navMenu` AS `navMenu`,`navigation`.`navIsNotApi` AS `navIsNotApi`,`rolepermissions`.`rpId` AS `rpid` from (`rolepermissions` join `navigation` on(`navigation`.`navPriv` = `rolepermissions`.`rpPriv`)) where `navigation`.`navIsNotApi` = 1 and `navigation`.`navActive` = 1 order by `navigation`.`navMenu`,`navigation`.`navInnerText` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `userlogin`
--

/*!50001 DROP TABLE IF EXISTS `userlogin`*/;
/*!50001 DROP VIEW IF EXISTS `userlogin`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`aj`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `userlogin` AS select `userregistration`.`userId` AS `userId`,`userregistration`.`userName` AS `userName`,`userregistration`.`userPass` AS `userPass`,`userregistration`.`userEmail` AS `userEmail`,`userregistration`.`userIsConfirmed` AS `userIsConfirmed`,`userregistration`.`userIsLocked` AS `userIsLocked`,`userregistration`.`userInvalidLoginAttempts` AS `userInvalidLoginAttempts`,`userregistration`.`userDefaultNonsig` AS `userNonsig`,`nsinfo`.`nsIsActive` AS `nsIsActive`,`nsaccess`.`nsaRole` AS `userRole` from ((`userregistration` join `nsinfo` on(`nsinfo`.`nsNonsig` = `userregistration`.`userDefaultNonsig`)) join `nsaccess` on(`nsaccess`.`nsaNonsig` = `userregistration`.`userDefaultNonsig`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-01 23:23:32
