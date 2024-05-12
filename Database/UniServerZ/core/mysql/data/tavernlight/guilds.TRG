TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`127.0.0.1` TRIGGER `oncreate_guilds` AFTER INSERT ON `guilds`\n FOR EACH ROW BEGIN\n    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES (\'the Leader\', 3, NEW.`id`);\n    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES (\'a Vice-Leader\', 2, NEW.`id`);\n    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES (\'a Member\', 1, NEW.`id`);\nEND'
sql_modes=524288
definers='root@127.0.0.1'
client_cs_names='utf8mb4'
connection_cl_names='utf8mb4_general_ci'
db_cl_names='utf8_general_ci'
