CREATE DATABASE  IF NOT EXISTS `rest-api` /*!40100 DEFAULT CHARACTER SET utf8mb4  */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `rest-api`;
-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: localhost    Database: rest-api
-- ------------------------------------------------------
-- Server version	8.0.26

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
-- Table structure for table `app_version`
--

DROP TABLE IF EXISTS `app_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `app_version` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `version` float NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `app_version`
--

LOCK TABLES `app_version` WRITE;
/*!40000 ALTER TABLE `app_version` DISABLE KEYS */;
INSERT INTO `app_version` VALUES (1,0.1,'2021-09-04 13:35:47');
/*!40000 ALTER TABLE `app_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device`
--

DROP TABLE IF EXISTS `device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `uuid` varchar(300) CHARACTER SET utf8 NOT NULL,
  `user_id` bigint NOT NULL,
  `token` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `app_version_id` bigint DEFAULT '1',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_device_user_id_idx` (`user_id`),
  KEY `fk_device_app_version_id_idx` (`app_version_id`),
  CONSTRAINT `fk_device_app_version_id` FOREIGN KEY (`app_version_id`) REFERENCES `app_version` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_device_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device`
--

LOCK TABLES `device` WRITE;
/*!40000 ALTER TABLE `device` DISABLE KEYS */;
INSERT INTO `device` VALUES (2,'12345-6789-09876-54321',1,NULL,1,'2022-01-15 15:40:17','2022-01-15 15:40:17',1);
/*!40000 ALTER TABLE `device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_pool`
--

DROP TABLE IF EXISTS `email_pool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_pool` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `template_id` bigint NOT NULL,
  `status_id` bigint NOT NULL,
  `subject` varchar(100) CHARACTER SET utf8 NOT NULL,
  `content` text CHARACTER SET utf8 NOT NULL,
  `send_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `send_attemps` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `emailpool_idTemplate_idx` (`template_id`),
  KEY `emailpool_idStatus_idx` (`status_id`),
  KEY `fk_email_pool_user_idx` (`user_id`),
  CONSTRAINT `fk_email_pool_email_template_id` FOREIGN KEY (`template_id`) REFERENCES `email_template` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_email_pool_status_id` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_email_pool_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_pool`
--

LOCK TABLES `email_pool` WRITE;
/*!40000 ALTER TABLE `email_pool` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_pool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_sent`
--

DROP TABLE IF EXISTS `email_sent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_sent` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `template_id` bigint NOT NULL,
  `content` text CHARACTER SET utf8 NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_email_sent_email_template_id_idx` (`template_id`),
  KEY `fk_email_sent_user_idx` (`user_id`),
  CONSTRAINT `fk_email_sent_email_template_id` FOREIGN KEY (`template_id`) REFERENCES `email_template` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_email_sent_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_sent`
--

LOCK TABLES `email_sent` WRITE;
/*!40000 ALTER TABLE `email_sent` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_sent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_template`
--

DROP TABLE IF EXISTS `email_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8 NOT NULL,
  `subject` varchar(100) CHARACTER SET utf8 NOT NULL,
  `description` varchar(500) CHARACTER SET utf8 NOT NULL,
  `html` text CHARACTER SET utf8 NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_template`
--

LOCK TABLES `email_template` WRITE;
/*!40000 ALTER TABLE `email_template` DISABLE KEYS */;
INSERT INTO `email_template` VALUES (1,'password recovery','Recupera tu contraseña','Correo que envía la otp para recuperar la contraseña','<!DOCTYPE html\n    PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional //EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\"\n    xmlns:v=\"urn:schemas-microsoft-com:vml\">\n\n<head>\n    <!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->\n    <meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\" />\n    <meta content=\"width=device-width\" name=\"viewport\" />\n    <!--[if !mso]><!-->\n    <meta content=\"IE=edge\" http-equiv=\"X-UA-Compatible\" />\n    <!--<![endif]-->\n    <title></title>\n    <!--[if !mso]><!-->\n    <link href=\"https://fonts.googleapis.com/css?family=Open+Sans\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"https://fonts.googleapis.com/css?family=Cabin\" rel=\"stylesheet\" type=\"text/css\" />\n    <!--<![endif]-->\n    <style type=\"text/css\">\n        body {\n            margin: 0;\n            padding: 0;\n        }\n\n        table,\n        td,\n        tr {\n            vertical-align: top;\n            border-collapse: collapse;\n        }\n\n        * {\n            line-height: inherit;\n        }\n\n        a[x-apple-data-detectors=true] {\n            color: inherit !important;\n            text-decoration: none !important;\n        }\n\n        .store-buttons {\n            display: flex;\n            justify-content: space-around;\n        }\n\n        .buttons-small {\n            width: 80%;\n        }\n    </style>\n    <style id=\"media-query\" type=\"text/css\">\n        @media (max-width: 620px) {\n\n            .block-grid,\n            .col {\n                min-width: 320px;\n                max-width: 50%;\n                display: block;\n            }\n\n            .block-grid {\n                width: 50% !important;\n            }\n\n            .col {\n                width: 100% !important;\n            }\n\n            .col_cont {\n                margin: 0 auto;\n            }\n\n            img.fullwidth,\n            img.fullwidthOnMobile {\n                width: 100% !important;\n            }\n\n            .no-stack .col {\n                min-width: 0 !important;\n                display: table-cell !important;\n            }\n\n            .no-stack.two-up .col {\n                width: 50% !important;\n            }\n\n            .no-stack .col.num2 {\n                width: 16.6% !important;\n            }\n\n            .no-stack .col.num3 {\n                width: 25% !important;\n            }\n\n            .no-stack .col.num4 {\n                width: 33% !important;\n            }\n\n            .no-stack .col.num5 {\n                width: 41.6% !important;\n            }\n\n            .no-stack .col.num6 {\n                width: 50% !important;\n            }\n\n            .no-stack .col.num7 {\n                width: 58.3% !important;\n            }\n\n            .no-stack .col.num8 {\n                width: 66.6% !important;\n            }\n\n            .no-stack .col.num9 {\n                width: 75% !important;\n            }\n\n            .no-stack .col.num10 {\n                width: 83.3% !important;\n            }\n\n            .video-block {\n                max-width: none !important;\n            }\n\n            .mobile_hide {\n                min-height: 0px;\n                max-height: 0px;\n                max-width: 0px;\n                display: none;\n                overflow: hidden;\n                font-size: 0px;\n            }\n\n            .desktop_hide {\n                display: block !important;\n                max-height: none !important;\n            }\n        }\n    </style>\n</head>\n\n<body class=\"clean-body\" style=\"margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #00263d;\">\n    <div class=\"preheader\"\n        style=\"display:none;font-size:1px;color:#333333;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;\">\n        Aquí tienes tu código</div>\n    <!--[if IE]><div class=\"ie-browser\"><![endif]-->\n    <table bgcolor=\"#00263d\" cellpadding=\"0\" cellspacing=\"0\" class=\"nl-container\" role=\"presentation\"\n        style=\"table-layout: fixed; vertical-align: top; min-width: 320px; border-spacing: 0; border-collapse: collapse; background-color: #00263d; width: 100%;\"\n        valign=\"top\" width=\"100%\">\n        <tbody>\n            <tr style=\"vertical-align: top;\" valign=\"top\">\n                <td style=\"word-break: break-word; vertical-align: top;\" valign=\"top\">\n                    <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" style=\"background-color:#00263d\"><![endif]-->\n                    <div style=\"background-color:#00263d;\">\n                        <div class=\"block-grid\"\n                            style=\"min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;\">\n                            <div\n                                style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:#00263d;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top:20px; padding-bottom:0px;\"><![endif]-->\n                                <div class=\"col num12\"\n                                    style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                    <div class=\"col_cont\" style=\"width:100% !important;\">\n                                        <!--[if (!mso)&(!IE)]><!-->\n                                        <div\n                                            style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:20px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\">\n                                            <!--<![endif]-->\n                                            <div align=\"center\" class=\"img-container center fixedwidth\"\n                                                style=\"padding-right: 0px;margin-top: 50px;\">\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr style=\"line-height:0px\"><td style=\"padding-right: 0px;padding-left: 0px;\" align=\"center\"><![endif]--><img\n                                                    align=\"center\" border=\"0\" class=\"center fixedwidth\"\n                                                    src=\"\"\n                                                    style=\"text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 240px; max-width: 100%; display: block;\"\n                                                    width=\"240\" />\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                            </div>\n                                            <!--[if (!mso)&(!IE)]><!-->\n                                        </div>\n                                        <!--<![endif]-->\n                                    </div>\n                                </div>\n                                <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                            </div>\n                        </div>\n                    </div>\n                    <div style=\"margin-top: 100px; margin-bottom: 100px;\">\n                        <div\n                            style=\"padding-top: 50px; padding-bottom: 50px;background-color:#ffffff; border-radius: 9px;min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto;\">\n                            <div\n                                style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-image:url(\'https://api.duelazo.com/api/files/s3/357\');background-position:top center;background-repeat:repeat;background-color:#00263d;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 50px; padding-left: 50px; padding-top:15px; padding-bottom:15px;\"><![endif]-->\n                                <div class=\"col num12\"\n                                    style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                    <div class=\"col_cont\" style=\"width:100% !important;\">\n                                        <!--[if (!mso)&(!IE)]><!-->\n                                        <div\n                                            style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 50px; padding-left: 50px;\">\n                                            <!--<![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#506bec;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #506bec;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 26px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 26px;\"><strong><span\n                                                                    >Recibimos una solicitud para cambiar tu\n                                                                    contraseña</span></strong></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #40507a;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 16px;\">Usa el código de\n                                                            seguridad para\n                                                            completar el proceso\n                                                        </span><br /><br /><br /><span\n                                                            style=\"color: #000000; font-size: 16px;\">Tu código\n                                                            provisional es:</span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#506bec;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #506bec;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 38px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span\n                                                            style=\"color: #000000; font-size: 38px;\"><strong><span>{{otp}}</span></strong></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <div align=\"center\" class=\"button-container\"\n                                                style=\"padding-top:20px;padding-right:10px;padding-bottom:20px;padding-left:10px;\">\n\n                                                <!--<div class=\"store-buttons\" style=\"margin-bottom: 25px;\">\n                                                    <a\n                                                        href=\'https://play.google.com/store/apps/details?id=com.dinkbit.duelazo\'><img\n                                                            class=\"buttons-small\" alt=\'Disponible en Google Play\'\n                                                            src=\'https://play.google.com/intl/en_us/badges/static/images/badges/es-419_badge_web_generic.png\' /></a>\n                                                    <a href=\'https://apps.apple.com/us/app/duelazo/id1488972274\'><img\n                                                            style=\"width: 55%; margin-top: 3%;\"\n                                                            alt=\'Disponible en Google Play\'\n                                                            src=\'https://api.duelazo.com/api/files/s3/1021\' /></a>\n\n                                                </div>-->\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                                <div\n                                                    style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                    <div class=\"txtTinyMce-wrapper\"\n                                                        style=\"font-size: 14px; line-height: 1.2; color: #40507a; font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\">\n                                                        <p\n                                                            style=\"margin: 0; font-size: 14px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                            <span style=\"color: #000000;\">¿Necesitas ayuda? Escríbenos a\n                                                            </span><u><span style=\"color: #173c6f;\"><a\n                                                                        href=\"mailto:contacto@duelazo.com?subject = Ganador Quiniela\"\n                                                                        style=\"text-decoration: underline; color:#173c6f;\"\n                                                                        target=\"_blank\">contacto@email.com</a></span></u>\n                                                        </p>\n                                                    </div>\n                                                </div>\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                                <div\n                                                    style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                    <div class=\"txtTinyMce-wrapper\"\n                                                        style=\"font-size: 14px; line-height: 1.2; color: #40507a; font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\">\n                                                        <span style=\"font-size: 12px;\"><span\n                                                                style=\"color: #828282;\">Consulta Términos y Condiciones,\n                                                                Reglamento y Políticas de uso en</span> <span\n                                                                style=\"color: #173c6f;\"><u><a\n                                                                        href=\"http://www.google.com\" rel=\"noopener\"\n                                                                        style=\"text-decoration: underline;\"\n                                                                        target=\"_blank\"><u>\n                                                                        </u>www.tupagina.com</a></span></p>\n                                                            </u></span></span>\n                                                        </p>\n                                                    </div>\n                                                    <div\n                                                        style=\"color:#97a2da;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                        <div class=\"txtTinyMce-wrapper\"\n                                                            style=\"font-size: 14px; line-height: 1.2; color: #97a2da; font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\">\n                                                            <p\n                                                                style=\"margin: 0; text-align: center; font-size: 12px; line-height: 1.2; word-break: break-word; margin-top: 0; margin-bottom: 0;\">\n                                                                <span\n                                                                    style=\"font-size: 12px; color: #828282;\">Copyright©\n                                                                    2022\n                                                                </span>\n                                                            </p>\n                                                        </div>\n                                                    </div>\n                                                </div>\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                                <!--[if (!mso)&(!IE)]><!-->\n                                            </div>\n                                            <!--<![endif]-->\n                                        </div>\n                                    </div>\n                                    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                                </div>\n                            </div>\n                        </div>\n                        <div style=\"background-color:transparent;\">\n                            <div class=\"block-grid\"\n                                style=\"min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;\">\n                                <div\n                                    style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                    <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:transparent;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                    <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:5px;\"><![endif]-->\n                                    <div class=\"col num12\"\n                                        style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                        <div class=\"col_cont\" style=\"width:100% !important;\">\n                                            <!--[if (!mso)&(!IE)]><!-->\n                                            <div\n                                                style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;\">\n                                                <!--<![endif]-->\n                                                <!--[if (!mso)&(!IE)]><!-->\n                                            </div>\n                                            <!--<![endif]-->\n                                        </div>\n                                    </div>\n                                    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                                </div>\n                            </div>\n                        </div>\n\n                        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                </td>\n            </tr>\n        </tbody>\n    </table>\n    <!--[if (IE)]></div><![endif]-->\n</body>\n\n</html>','2021-04-22 19:35:36','2021-04-22 19:35:36',1),(2,'email confirmation','Confirma tu correo','Correo con el código para verificar una dirección email','<!DOCTYPE html\n    PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional //EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\"\n    xmlns:v=\"urn:schemas-microsoft-com:vml\">\n\n<head>\n    <!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->\n    <meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\" />\n    <meta content=\"width=device-width\" name=\"viewport\" />\n    <!--[if !mso]><!-->\n    <meta content=\"IE=edge\" http-equiv=\"X-UA-Compatible\" />\n    <!--<![endif]-->\n    <title></title>\n    <!--[if !mso]><!-->\n    <link href=\"https://fonts.googleapis.com/css?family=Open+Sans\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"https://fonts.googleapis.com/css?family=Cabin\" rel=\"stylesheet\" type=\"text/css\" />\n    <!--<![endif]-->\n    <style type=\"text/css\">\n        body {\n            margin: 0;\n            padding: 0;\n        }\n\n        table,\n        td,\n        tr {\n            vertical-align: top;\n            border-collapse: collapse;\n        }\n\n        * {\n            line-height: inherit;\n        }\n\n        a[x-apple-data-detectors=true] {\n            color: inherit !important;\n            text-decoration: none !important;\n        }\n\n        .store-buttons {\n            display: flex;\n            justify-content: space-around;\n        }\n\n        .buttons-small {\n            width: 80%;\n        }\n    </style>\n    <style id=\"media-query\" type=\"text/css\">\n        @media (max-width: 620px) {\n\n            .block-grid,\n            .col {\n                min-width: 320px;\n                max-width: 50%;\n                display: block;\n            }\n\n            .block-grid {\n                width: 50% !important;\n            }\n\n            .col {\n                width: 100% !important;\n            }\n\n            .col_cont {\n                margin: 0 auto;\n            }\n\n            img.fullwidth,\n            img.fullwidthOnMobile {\n                width: 100% !important;\n            }\n\n            .no-stack .col {\n                min-width: 0 !important;\n                display: table-cell !important;\n            }\n\n            .no-stack.two-up .col {\n                width: 50% !important;\n            }\n\n            .no-stack .col.num2 {\n                width: 16.6% !important;\n            }\n\n            .no-stack .col.num3 {\n                width: 25% !important;\n            }\n\n            .no-stack .col.num4 {\n                width: 33% !important;\n            }\n\n            .no-stack .col.num5 {\n                width: 41.6% !important;\n            }\n\n            .no-stack .col.num6 {\n                width: 50% !important;\n            }\n\n            .no-stack .col.num7 {\n                width: 58.3% !important;\n            }\n\n            .no-stack .col.num8 {\n                width: 66.6% !important;\n            }\n\n            .no-stack .col.num9 {\n                width: 75% !important;\n            }\n\n            .no-stack .col.num10 {\n                width: 83.3% !important;\n            }\n\n            .video-block {\n                max-width: none !important;\n            }\n\n            .mobile_hide {\n                min-height: 0px;\n                max-height: 0px;\n                max-width: 0px;\n                display: none;\n                overflow: hidden;\n                font-size: 0px;\n            }\n\n            .desktop_hide {\n                display: block !important;\n                max-height: none !important;\n            }\n        }\n    </style>\n</head>\n\n<body class=\"clean-body\" style=\"margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #00263d;\">\n    <div class=\"preheader\"\n        style=\"display:none;font-size:1px;color:#333333;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;\">\n        Verifica tu correo</div>\n    <!--[if IE]><div class=\"ie-browser\"><![endif]-->\n    <table bgcolor=\"#00263d\" cellpadding=\"0\" cellspacing=\"0\" class=\"nl-container\" role=\"presentation\"\n        style=\"table-layout: fixed; vertical-align: top; min-width: 320px; border-spacing: 0; border-collapse: collapse; background-color: #00263d; width: 100%;\"\n        valign=\"top\" width=\"100%\">\n        <tbody>\n            <tr style=\"vertical-align: top;\" valign=\"top\">\n                <td style=\"word-break: break-word; vertical-align: top;\" valign=\"top\">\n                    <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" style=\"background-color:#00263d\"><![endif]-->\n                    <div style=\"background-color:#00263d;\">\n                        <div class=\"block-grid\"\n                            style=\"min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;\">\n                            <div\n                                style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:#00263d;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top:20px; padding-bottom:0px;\"><![endif]-->\n                                <div class=\"col num12\"\n                                    style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                    <div class=\"col_cont\" style=\"width:100% !important;\">\n                                        <!--[if (!mso)&(!IE)]><!-->\n                                        <div\n                                            style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:20px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\">\n                                            <!--<![endif]-->\n                                            <div align=\"center\" class=\"img-container center fixedwidth\"\n                                                style=\"padding-right: 0px;margin-top: 50px;\">\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr style=\"line-height:0px\"><td style=\"padding-right: 0px;padding-left: 0px;\" align=\"center\"><![endif]--><img\n                                                    align=\"center\" border=\"0\" class=\"center fixedwidth\"\n                                                    src=\"\"\n                                                    style=\"text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 240px; max-width: 100%; display: block;\"\n                                                    width=\"240\" />\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                            </div>\n                                            <!--[if (!mso)&(!IE)]><!-->\n                                        </div>\n                                        <!--<![endif]-->\n                                    </div>\n                                </div>\n                                <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                            </div>\n                        </div>\n                    </div>\n                    <div style=\"margin-top: 100px; margin-bottom: 100px;\">\n                        <div\n                            style=\"padding-top: 50px; padding-bottom: 50px;background-color:#ffffff; border-radius: 9px;min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto;\">\n                            <div\n                                style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-image:url(\'https://api.duelazo.com/api/files/s3/357\');background-position:top center;background-repeat:repeat;background-color:#00263d;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 50px; padding-left: 50px; padding-top:15px; padding-bottom:15px;\"><![endif]-->\n                                <div class=\"col num12\"\n                                    style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                    <div class=\"col_cont\" style=\"width:100% !important;\">\n                                        <!--[if (!mso)&(!IE)]><!-->\n                                        <div\n                                            style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 50px; padding-left: 50px;\">\n                                            <!--<![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#506bec;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #506bec;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 26px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 26px;\"><strong><span\n                                                                    >Verifica tu correo\n                                                                    electrónico</span></strong></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #40507a;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 16px;\">Da click en el\n                                                            siguiente enlace:\n                                                        </span><br /><br /><span\n                                                            style=\"color: #000000; font-size: 16px;\"></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                                <div\n                                                style=\"color:#506bec;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #506bec;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 25px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #173c6f;\"><a\n                                                                href=\"https://tupagina.com/confirm-email?token={{token}}\"\n                                                                style=\"text-decoration: underline; color:#173c6f;\"\n                                                                target=\"_blank\">Tu link</a>\n                                                        </span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <div align=\"center\" class=\"button-container\"\n                                                style=\"padding-top:20px;padding-right:10px;padding-bottom:20px;padding-left:10px;\">\n\n                                                <!--<div class=\"store-buttons\" style=\"margin-bottom: 25px;\">\n                                                    <a\n                                                        href=\'https://play.google.com/store/apps/details?id=com.dinkbit.duelazo\'><img\n                                                            class=\"buttons-small\" alt=\'Disponible en Google Play\'\n                                                            src=\'https://play.google.com/intl/en_us/badges/static/images/badges/es-419_badge_web_generic.png\' /></a>\n                                                    <a href=\'https://apps.apple.com/us/app/duelazo/id1488972274\'><img\n                                                            style=\"width: 55%; margin-top: 3%;\"\n                                                            alt=\'Disponible en Google Play\'\n                                                            src=\'https://api.duelazo.com/api/files/s3/1021\' /></a>\n\n                                                </div>-->\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                                <div\n                                                    style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                    <div class=\"txtTinyMce-wrapper\"\n                                                        style=\"font-size: 14px; line-height: 1.2; color: #40507a; font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\">\n                                                        <p\n                                                            style=\"margin: 0; font-size: 14px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                            <span style=\"color: #000000;\">¿Necesitas ayuda? Escríbenos a\n                                                            </span><u><span style=\"color: #173c6f;\"><a\n                                                                        href=\"mailto:contacto@duelazo.com?subject = Ganador Quiniela\"\n                                                                        style=\"text-decoration: underline; color:#173c6f;\"\n                                                                        target=\"_blank\">contacto@email.com</a></span></u>\n                                                        </p>\n                                                    </div>\n                                                </div>\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                                <div\n                                                    style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                    <div class=\"txtTinyMce-wrapper\"\n                                                        style=\"font-size: 14px; line-height: 1.2; color: #40507a; font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\">\n                                                        <span style=\"font-size: 12px;\"><span\n                                                                style=\"color: #828282;\">Consulta Términos y Condiciones,\n                                                                Reglamento y Políticas de uso en</span> <span\n                                                                style=\"color: #173c6f;\"><u><a\n                                                                        href=\"http://www.google.com\" rel=\"noopener\"\n                                                                        style=\"text-decoration: underline;\"\n                                                                        target=\"_blank\"><u>\n                                                                        </u>www.tupagina.com</a></span></p>\n                                                            </u></span></span>\n                                                        </p>\n                                                    </div>\n                                                    <div\n                                                        style=\"color:#97a2da;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                        <div class=\"txtTinyMce-wrapper\"\n                                                            style=\"font-size: 14px; line-height: 1.2; color: #97a2da; font-family: Helvetica Neue, Helvetica, Arial, sans-serif;\">\n                                                            <p\n                                                                style=\"margin: 0; text-align: center; font-size: 12px; line-height: 1.2; word-break: break-word; margin-top: 0; margin-bottom: 0;\">\n                                                                <span\n                                                                    style=\"font-size: 12px; color: #828282;\">Copyright©\n                                                                    2022\n                                                                </span>\n                                                            </p>\n                                                        </div>\n                                                    </div>\n                                                </div>\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                                <!--[if (!mso)&(!IE)]><!-->\n                                            </div>\n                                            <!--<![endif]-->\n                                        </div>\n                                    </div>\n                                    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                                </div>\n                            </div>\n                        </div>\n                        <div style=\"background-color:transparent;\">\n                            <div class=\"block-grid\"\n                                style=\"min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;\">\n                                <div\n                                    style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                    <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:transparent;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                    <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:5px;\"><![endif]-->\n                                    <div class=\"col num12\"\n                                        style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                        <div class=\"col_cont\" style=\"width:100% !important;\">\n                                            <!--[if (!mso)&(!IE)]><!-->\n                                            <div\n                                                style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;\">\n                                                <!--<![endif]-->\n                                                <!--[if (!mso)&(!IE)]><!-->\n                                            </div>\n                                            <!--<![endif]-->\n                                        </div>\n                                    </div>\n                                    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                                </div>\n                            </div>\n                        </div>\n\n                        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                </td>\n            </tr>\n        </tbody>\n    </table>\n    <!--[if (IE)]></div><![endif]-->\n</body>\n\n</html>','2021-05-03 12:06:18','2021-05-03 12:06:18',1),(3,'error','¡Hubo un error en la aplicación!','Informar de un error critico en los datos','<!DOCTYPE html\n    PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional //EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\"\n    xmlns:v=\"urn:schemas-microsoft-com:vml\">\n\n<head>\n    <!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->\n    <meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\" />\n    <meta content=\"width=device-width\" name=\"viewport\" />\n    <!--[if !mso]><!-->\n    <meta content=\"IE=edge\" http-equiv=\"X-UA-Compatible\" />\n    <!--<![endif]-->\n    <title></title>\n    <!--[if !mso]><!-->\n    <link href=\"https://fonts.googleapis.com/css?family=Open+Sans\" rel=\"stylesheet\" type=\"text/css\" />\n    <link href=\"https://fonts.googleapis.com/css?family=Cabin\" rel=\"stylesheet\" type=\"text/css\" />\n    <!--<![endif]-->\n    <style type=\"text/css\">\n        body {\n            margin: 0;\n            padding: 0;\n        }\n\n        table,\n        td,\n        tr {\n            vertical-align: top;\n            border-collapse: collapse;\n        }\n\n        * {\n            line-height: inherit;\n        }\n\n        a[x-apple-data-detectors=true] {\n            color: inherit !important;\n            text-decoration: none !important;\n        }\n\n        .store-buttons {\n            display: flex;\n            justify-content: space-around;\n        }\n\n        .buttons-small {\n            width: 80%;\n        }\n    </style>\n    <style id=\"media-query\" type=\"text/css\">\n        @media (max-width: 620px) {\n\n            .block-grid,\n            .col {\n                min-width: 320px;\n                max-width: 50%;\n                display: block;\n            }\n\n            .block-grid {\n                width: 50% !important;\n            }\n\n            .col {\n                width: 100% !important;\n            }\n\n            .col_cont {\n                margin: 0 auto;\n            }\n\n            img.fullwidth,\n            img.fullwidthOnMobile {\n                width: 100% !important;\n            }\n\n            .no-stack .col {\n                min-width: 0 !important;\n                display: table-cell !important;\n            }\n\n            .no-stack.two-up .col {\n                width: 50% !important;\n            }\n\n            .no-stack .col.num2 {\n                width: 16.6% !important;\n            }\n\n            .no-stack .col.num3 {\n                width: 25% !important;\n            }\n\n            .no-stack .col.num4 {\n                width: 33% !important;\n            }\n\n            .no-stack .col.num5 {\n                width: 41.6% !important;\n            }\n\n            .no-stack .col.num6 {\n                width: 50% !important;\n            }\n\n            .no-stack .col.num7 {\n                width: 58.3% !important;\n            }\n\n            .no-stack .col.num8 {\n                width: 66.6% !important;\n            }\n\n            .no-stack .col.num9 {\n                width: 75% !important;\n            }\n\n            .no-stack .col.num10 {\n                width: 83.3% !important;\n            }\n\n            .video-block {\n                max-width: none !important;\n            }\n\n            .mobile_hide {\n                min-height: 0px;\n                max-height: 0px;\n                max-width: 0px;\n                display: none;\n                overflow: hidden;\n                font-size: 0px;\n            }\n\n            .desktop_hide {\n                display: block !important;\n                max-height: none !important;\n            }\n        }\n    </style>\n</head>\n\n<body class=\"clean-body\" style=\"margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #00263d;\">\n    <div class=\"preheader\"\n        style=\"display:none;font-size:1px;color:#333333;line-height:1px;max-height:0px;max-width:0px;opacity:0;overflow:hidden;\">\n        Hubo un error</div>\n    <!--[if IE]><div class=\"ie-browser\"><![endif]-->\n    <table bgcolor=\"#00263d\" cellpadding=\"0\" cellspacing=\"0\" class=\"nl-container\" role=\"presentation\"\n        style=\"table-layout: fixed; vertical-align: top; min-width: 320px; border-spacing: 0; border-collapse: collapse; background-color: #00263d; width: 100%;\"\n        valign=\"top\" width=\"100%\">\n        <tbody>\n            <tr style=\"vertical-align: top;\" valign=\"top\">\n                <td style=\"word-break: break-word; vertical-align: top;\" valign=\"top\">\n                    <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td align=\"center\" style=\"background-color:#00263d\"><![endif]-->\n                    <div style=\"background-color:#00263d;\">\n                        <div class=\"block-grid\"\n                            style=\"min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;\">\n                            <div\n                                style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:#00263d;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top:20px; padding-bottom:0px;\"><![endif]-->\n                                <div class=\"col num12\"\n                                    style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                    <div class=\"col_cont\" style=\"width:100% !important;\">\n                                        <!--[if (!mso)&(!IE)]><!-->\n                                        <div\n                                            style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:20px; padding-bottom:0px; padding-right: 0px; padding-left: 0px;\">\n                                            <!--<![endif]-->\n                                            <div align=\"center\" class=\"img-container center fixedwidth\"\n                                                style=\"padding-right: 0px;margin-top: 50px;\">\n                                                <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr style=\"line-height:0px\"><td style=\"padding-right: 0px;padding-left: 0px;\" align=\"center\"><![endif]--><img\n                                                    align=\"center\" border=\"0\" class=\"center fixedwidth\"\n                                                    src=\"\"\n                                                    style=\"text-decoration: none; -ms-interpolation-mode: bicubic; height: auto; border: 0; width: 240px; max-width: 100%; display: block;\"\n                                                    width=\"240\" />\n                                                <!--[if mso]></td></tr></table><![endif]-->\n                                            </div>\n                                            <!--[if (!mso)&(!IE)]><!-->\n                                        </div>\n                                        <!--<![endif]-->\n                                    </div>\n                                </div>\n                                <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                            </div>\n                        </div>\n                    </div>\n                    <div style=\"margin-top: 100px; margin-bottom: 100px;\">\n                        <div\n                            style=\"padding-top: 50px; padding-bottom: 50px;background-color:#ffffff; border-radius: 9px;min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto;\">\n                            <div\n                                style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-image:url(\'https://api.duelazo.com/api/files/s3/357\');background-position:top center;background-repeat:repeat;background-color:#00263d;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 50px; padding-left: 50px; padding-top:15px; padding-bottom:15px;\"><![endif]-->\n                                <div class=\"col num12\"\n                                    style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                    <div class=\"col_cont\" style=\"width:100% !important;\">\n                                        <!--[if (!mso)&(!IE)]><!-->\n                                        <div\n                                            style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:15px; padding-bottom:15px; padding-right: 50px; padding-left: 50px;\">\n                                            <!--<![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#506bec;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #506bec;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 26px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 26px;\"><strong><span\n                                                                    >Hubo un error</span></strong></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#40507a;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #40507a;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 16px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 16px;\">Hubo algun error\n                                                            en el flujo de la aplicación\n                                                        </span><br /><br /><span\n                                                            style=\"color: #000000; font-size: 16px;\"></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--[if mso]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif\"><![endif]-->\n                                            <div\n                                                style=\"color:#506bec;font-family:Helvetica Neue, Helvetica, Arial, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;\">\n                                                <div class=\"txtTinyMce-wrapper\"\n                                                    style=\"font-size: 14px; line-height: 1.2; font-family: Helvetica Neue, Helvetica, Arial, sans-serif; color: #506bec;\">\n                                                    <p\n                                                        style=\"margin: 0; font-size: 38px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 25px;\"><strong><span>Flujo:</strong>\n                                                                    <span\n                                                                        style=\"font-size: 16px;\">{{flow}}</span></span></span>\n                                                    </p>\n                                                    <p\n                                                        style=\"margin: 0; font-size: 38px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 25px;\"><strong><span>Titulo:</strong>\n                                                                    <span\n                                                                        style=\"font-size: 16px;\">{{title}}</span></span></span>\n                                                    </p>\n                                                    <p\n                                                        style=\"margin: 0; font-size: 38px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 25px;\"><strong><span>Descripción:</strong>\n                                                                    <span\n                                                                        style=\"font-size: 16px;\">{{description}}</span></span></span>\n                                                    </p>\n                                                    <p\n                                                        style=\"margin: 0; font-size: 38px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 25px;\"><strong><span>Fecha:</strong>\n                                                                    <span\n                                                                        style=\"font-size: 16px;\">{{date}}</span></span></span>\n                                                    </p>\n                                                    <p\n                                                        style=\"margin: 0; font-size: 38px; line-height: 1.2; word-break: break-word; text-align: center; margin-top: 0; margin-bottom: 0;\">\n                                                        <span style=\"color: #000000; font-size: 25px;\"><strong><span>Procedimiento:</strong>\n                                                                    <span\n                                                                        style=\"font-size: 16px;\">{{procedure}}</span></span></span></span>\n                                                    </p>\n                                                </div>\n                                            </div>\n                                            <!--[if mso]></td></tr></table><![endif]-->\n                                            <!--<![endif]-->\n                                        </div>\n                                    </div>\n                                    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                                </div>\n                            </div>\n                        </div>\n                        <div style=\"background-color:transparent;\">\n                            <div class=\"block-grid\"\n                                style=\"min-width: 320px; max-width: 600px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; Margin: 0 auto; background-color: transparent;\">\n                                <div\n                                    style=\"border-collapse: collapse;display: table;width: 100%;background-color:transparent;\">\n                                    <!--[if (mso)|(IE)]><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"background-color:transparent;\"><tr><td align=\"center\"><table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:600px\"><tr class=\"layout-full-width\" style=\"background-color:transparent\"><![endif]-->\n                                    <!--[if (mso)|(IE)]><td align=\"center\" width=\"600\" style=\"background-color:transparent;width:600px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;\" valign=\"top\"><table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td style=\"padding-right: 0px; padding-left: 0px; padding-top:0px; padding-bottom:5px;\"><![endif]-->\n                                    <div class=\"col num12\"\n                                        style=\"min-width: 320px; max-width: 600px; display: table-cell; vertical-align: top; width: 600px;\">\n                                        <div class=\"col_cont\" style=\"width:100% !important;\">\n                                            <!--[if (!mso)&(!IE)]><!-->\n                                            <div\n                                                style=\"border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:0px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;\">\n                                                <!--<![endif]-->\n                                                <!--[if (!mso)&(!IE)]><!-->\n                                            </div>\n                                            <!--<![endif]-->\n                                        </div>\n                                    </div>\n                                    <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                                    <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->\n                                </div>\n                            </div>\n                        </div>\n\n                        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->\n                </td>\n            </tr>\n        </tbody>\n    </table>\n    <!--[if (IE)]></div><![endif]-->\n</body>\n\n</html>','2022-01-07 13:14:13','2022-01-07 13:14:13',1);
/*!40000 ALTER TABLE `email_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file`
--

DROP TABLE IF EXISTS `file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `object` varchar(255) CHARACTER SET utf8 NOT NULL,
  `size` int NOT NULL,
  `type` varchar(100) CHARACTER SET utf8 NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 NOT NULL,
  `hash` varchar(255) CHARACTER SET utf8 NOT NULL,
  `is_thumbnail` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file`
--

LOCK TABLES `file` WRITE;
/*!40000 ALTER TABLE `file` DISABLE KEYS */;
/*!40000 ALTER TABLE `file` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `person`
--

DROP TABLE IF EXISTS `person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `person` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `last_name` varchar(50) CHARACTER SET utf8 NOT NULL,
  `birthday` datetime DEFAULT NULL,
  `sex` varchar(45) CHARACTER SET utf8 DEFAULT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `person`
--

LOCK TABLES `person` WRITE;
/*!40000 ALTER TABLE `person` DISABLE KEYS */;
INSERT INTO `person` VALUES (1,'Daniel','Trejo','1998-01-10 00:00:00',NULL,'2022-01-15 15:37:34','2022-01-15 15:37:34',1);
/*!40000 ALTER TABLE `person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_notification_catalogue`
--

DROP TABLE IF EXISTS `push_notification_catalogue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_notification_catalogue` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `action` varchar(45) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_notification_catalogue`
--

LOCK TABLES `push_notification_catalogue` WRITE;
/*!40000 ALTER TABLE `push_notification_catalogue` DISABLE KEYS */;
INSERT INTO `push_notification_catalogue` VALUES (1,'GOTO_USER_PROFILE');
/*!40000 ALTER TABLE `push_notification_catalogue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_notification_pool`
--

DROP TABLE IF EXISTS `push_notification_pool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_notification_pool` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `template_id` bigint NOT NULL,
  `status_id` bigint NOT NULL,
  `send_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message` varchar(200) CHARACTER SET utf8 NOT NULL,
  `data` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `send_attemps` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_push_notification_pool_user_id_idx` (`user_id`),
  KEY `fk_push_notification_pool_push_notification_template_id_idx` (`template_id`),
  KEY `fk_push_notification_pool_status_id_idx` (`status_id`),
  CONSTRAINT `fk_push_notification_pool_push_notification_template_id` FOREIGN KEY (`template_id`) REFERENCES `push_notification_template` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_push_notification_pool_status_id` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_push_notification_pool_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_notification_pool`
--

LOCK TABLES `push_notification_pool` WRITE;
/*!40000 ALTER TABLE `push_notification_pool` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_notification_pool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_notification_sent`
--

DROP TABLE IF EXISTS `push_notification_sent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_notification_sent` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `device_id` bigint NOT NULL,
  `template_id` bigint NOT NULL,
  `message` varchar(200) CHARACTER SET utf8 NOT NULL,
  `readed` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_push_notification_sent_user_id_idx` (`user_id`),
  KEY `fk_push_notification_sent_devie_id_idx` (`device_id`),
  KEY `fk_push_notification_sent_push_notification_template_id_idx` (`template_id`),
  CONSTRAINT `fk_push_notification_sent_device_id` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_push_notification_sent_push_notification_template_id` FOREIGN KEY (`template_id`) REFERENCES `push_notification_template` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_push_notification_sent_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_notification_sent`
--

LOCK TABLES `push_notification_sent` WRITE;
/*!40000 ALTER TABLE `push_notification_sent` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_notification_sent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_notification_template`
--

DROP TABLE IF EXISTS `push_notification_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_notification_template` (
  `id` bigint NOT NULL,
  `name` varchar(100) CHARACTER SET utf8 NOT NULL,
  `description` varchar(500) CHARACTER SET utf8 NOT NULL,
  `title` varchar(200) CHARACTER SET utf8 NOT NULL,
  `message` varchar(200) CHARACTER SET utf8 NOT NULL,
  `private` tinyint(1) NOT NULL,
  `catalogue_id` bigint NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_push_notification_template_catalogue_id_idx` (`catalogue_id`),
  CONSTRAINT `fk_push_notification_template_catalogue_id` FOREIGN KEY (`catalogue_id`) REFERENCES `push_notification_catalogue` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_notification_template`
--

LOCK TABLES `push_notification_template` WRITE;
/*!40000 ALTER TABLE `push_notification_template` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_notification_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8 NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'root','2021-04-22 19:26:51','2021-04-22 19:26:51',1),(2,'user','2021-05-03 16:18:19','2021-05-03 16:18:19',1);
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `session` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '		',
  `device_id` bigint NOT NULL,
  `token` varchar(120) CHARACTER SET utf8 NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_session_user_id_idx` (`user_id`),
  KEY `fk_session_device_id_idx` (`device_id`),
  CONSTRAINT `fk_session_device_id` FOREIGN KEY (`device_id`) REFERENCES `device` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_session_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES (2,1,2,'MMp7cLVLM_5uhffYQuktg2R5g0VhdGMHRJCFzrTjj7Y','2022-01-15 15:40:17','2022-02-01 00:13:14',1);
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_pool`
--

DROP TABLE IF EXISTS `sms_pool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_pool` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `template_id` bigint NOT NULL,
  `status_id` bigint NOT NULL,
  `message` varchar(160) NOT NULL,
  `send_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `send_attemps` tinyint(1) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_sms_pool_template_idx` (`template_id`),
  KEY `fk_sms_pool_status_idx` (`status_id`),
  KEY `fk_sms_pool_user_idx` (`user_id`),
  CONSTRAINT `fk_sms_pool_status` FOREIGN KEY (`status_id`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sms_pool_template` FOREIGN KEY (`template_id`) REFERENCES `sms_template` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sms_pool_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_pool`
--

LOCK TABLES `sms_pool` WRITE;
/*!40000 ALTER TABLE `sms_pool` DISABLE KEYS */;
INSERT INTO `sms_pool` VALUES (1,1,1,3,'Hola, te compartimos tu código de seguridad: FFPSQ  Recuerda no compartirlo con nadie','2022-02-01 00:23:05',1,'2022-02-01 00:23:16','2022-02-01 00:23:18');
/*!40000 ALTER TABLE `sms_pool` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_sent`
--

DROP TABLE IF EXISTS `sms_sent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_sent` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `template_id` bigint NOT NULL,
  `message` varchar(160) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_sms_sent_user_idx` (`user_id`),
  KEY `fk_sms_sent_template_idx` (`template_id`),
  CONSTRAINT `fk_sms_sent_template` FOREIGN KEY (`template_id`) REFERENCES `sms_template` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sms_sent_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_sent`
--

LOCK TABLES `sms_sent` WRITE;
/*!40000 ALTER TABLE `sms_sent` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_sent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_template`
--

DROP TABLE IF EXISTS `sms_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sms_template` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` varchar(200) NOT NULL,
  `message` varchar(160) NOT NULL,
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_template`
--

LOCK TABLES `sms_template` WRITE;
/*!40000 ALTER TABLE `sms_template` DISABLE KEYS */;
INSERT INTO `sms_template` VALUES (1,'password recovery','SMS with a otp that the user can use to recover their password or another otp thing that is needed','Hola, te compartimos tu código de seguridad: {{otp}}  Recuerda no compartirlo con nadie','2022-01-27 12:35:53','2022-01-27 12:47:26',1);
/*!40000 ALTER TABLE `sms_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `status`
--

DROP TABLE IF EXISTS `status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `status` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `description` varchar(100) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `status`
--

LOCK TABLES `status` WRITE;
/*!40000 ALTER TABLE `status` DISABLE KEYS */;
INSERT INTO `status` VALUES (1,'pending'),(2,'processing'),(3,'error'),(4,'send'),(5,'missing'),(6,'in verification'),(7,'acepted'),(8,'rejected'),(9,'verified');
/*!40000 ALTER TABLE `status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(100) CHARACTER SET utf8 NOT NULL,
  `password` varchar(300) CHARACTER SET utf8 NOT NULL,
  `salt` varchar(6) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8 NOT NULL,
  `phone` varchar(15) CHARACTER SET utf8 DEFAULT NULL,
  `role_id` bigint NOT NULL,
  `person_id` bigint DEFAULT NULL,
  `verified` tinyint NOT NULL DEFAULT '0',
  `email_confirmed` tinyint NOT NULL DEFAULT '0',
  `phone_confirmed` tinyint NOT NULL DEFAULT '0',
  `created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `fk_user_role_id_idx` (`role_id`),
  KEY `fk_user_person_idx` (`person_id`),
  CONSTRAINT `fk_user_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Pachada','bb8f5c18a512335cf826409c03076654474919a3ae982e8d494e92fd7bf0d372','_<fHUM','dtrejog98@gmail.com','5528461145',2,1,0,0,0,'2022-01-15 15:37:34','2022-01-15 15:37:34',1);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_verification`
--

DROP TABLE IF EXISTS `user_verification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_verification` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `curp` varchar(45) DEFAULT NULL,
  `status_id_curp` bigint NOT NULL DEFAULT '5',
  `file_id_ine` bigint DEFAULT NULL,
  `status_id_ine` bigint NOT NULL DEFAULT '5',
  `comments` varchar(450) DEFAULT NULL,
  `updated` datetime NOT NULL,
  `otp` varchar(6) DEFAULT NULL,
  `otp_time` datetime DEFAULT NULL,
  `email_otp` varchar(6) DEFAULT NULL,
  `email_otp_time` datetime DEFAULT NULL,
  `sms_otp` varchar(6) DEFAULT NULL,
  `sms_otp_time` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  KEY `fk_user_verification_status_curp_idx` (`status_id_curp`),
  KEY `fk_user_verification_status_ine_idx` (`status_id_ine`),
  KEY `fk_user_verification_file_ine_idx` (`file_id_ine`),
  CONSTRAINT `fk_user_verification_file_ine` FOREIGN KEY (`file_id_ine`) REFERENCES `file` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_verification_status_curp` FOREIGN KEY (`status_id_curp`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_verification_status_ine` FOREIGN KEY (`status_id_ine`) REFERENCES `status` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_verification_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_verification`
--

LOCK TABLES `user_verification` WRITE;
/*!40000 ALTER TABLE `user_verification` DISABLE KEYS */;
INSERT INTO `user_verification` VALUES (1,NULL,5,NULL,5,NULL,'2022-02-01 00:23:16','FFPSQ','2022-02-01 00:23:16',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `user_verification` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-02-04 10:04:59
