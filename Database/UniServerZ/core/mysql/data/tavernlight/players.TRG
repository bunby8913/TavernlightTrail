TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`127.0.0.1` TRIGGER `ondelete_players` BEFORE DELETE ON `players`\n FOR EACH ROW BEGIN\n    UPDATE `houses` SET `owner` = 0 WHERE `owner` = OLD.`id`;\nEND'
sql_modes=524288
definers='root@127.0.0.1'
client_cs_names='utf8mb4'
connection_cl_names='utf8mb4_general_ci'
db_cl_names='utf8_general_ci'
