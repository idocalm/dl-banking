CREATE TABLE `banking-payments` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`player` varchar(255) DEFAULT NULL,
	`time` varchar(255) DEFAULT NULL,
	`money` varchar(255) DEFAULT NULL,
	`title` varchar(255) DEFAULT NULL,
	PRIMARY KEY (`id`)
);


-- money can be - 500 / + 500 
-- player can be the one who pays / recives 