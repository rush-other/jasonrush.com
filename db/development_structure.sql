CREATE TABLE `articles` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `link` varchar(255) default NULL,
  `description` text,
  `guid` varchar(255) default NULL,
  `pub_date` datetime default NULL,
  `content` text,
  `full_text` longtext,
  `feed_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_articles_on_feed_id` (`feed_id`),
  KEY `index_articles_on_link` (`link`),
  KEY `index_articles_on_guid` (`guid`),
  CONSTRAINT `fk_articles_feeds` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `feeds` (
  `id` int(11) NOT NULL auto_increment,
  `xml_url` varchar(255) NOT NULL,
  `html_url` varchar(255) NOT NULL,
  `feed_type` int(11) default NULL,
  `title` varchar(100) default NULL,
  `description` text,
  `last_updated` datetime default NULL,
  `last_queried` datetime default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_feeds_on_xml_url` (`xml_url`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `folders` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(50) NOT NULL,
  `active` tinyint(1) NOT NULL default '1',
  `user_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `index_folders_on_user_id` (`user_id`),
  CONSTRAINT `fk_folders_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `schema_info` (
  `version` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL auto_increment,
  `session_id` varchar(255) default NULL,
  `data` text,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tags` (
  `id` int(11) NOT NULL auto_increment,
  `tag` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_tags_on_tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_articles` (
  `id` int(11) NOT NULL auto_increment,
  `article_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `unread` tinyint(1) NOT NULL default '0',
  `rating` int(11) NOT NULL default '3',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_user_articles_on_article_id_and_user_id` (`article_id`,`user_id`),
  KEY `fk_user_articles_users` (`user_id`),
  CONSTRAINT `fk_user_articles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_user_articles_articles` FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_feeds` (
  `id` int(11) NOT NULL auto_increment,
  `feed_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text,
  `folder_id` int(11) default NULL,
  `user_id` int(11) NOT NULL,
  `active` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  KEY `index_user_feeds_on_folder_id` (`folder_id`),
  KEY `index_user_feeds_on_user_id` (`user_id`),
  KEY `index_user_feeds_on_feed_id` (`feed_id`),
  CONSTRAINT `fk_user_feeds_feeds` FOREIGN KEY (`feed_id`) REFERENCES `feeds` (`id`),
  CONSTRAINT `fk_user_feeds_folders` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`),
  CONSTRAINT `fk_user_feeds_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_tags` (
  `id` int(11) NOT NULL auto_increment,
  `tag_id` int(11) NOT NULL,
  `article_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_user_tags_on_tag_id_and_article_id_and_user_id` (`tag_id`,`article_id`,`user_id`),
  KEY `fk_user_tags_articles` (`article_id`),
  KEY `fk_user_tags_users` (`user_id`),
  CONSTRAINT `fk_user_tags_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_user_tags_articles` FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`),
  CONSTRAINT `fk_user_tags_tags` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `username` varchar(20) NOT NULL,
  `password` varchar(50) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `paging_preference` int(11) NOT NULL default '25',
  `article_view_preference` int(11) NOT NULL default '0',
  `non_junk_only_preference` tinyint(1) NOT NULL default '1',
  `active` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `schema_info` (version) VALUES (10)