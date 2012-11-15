<?php
/**
 * Anwiki is a multilingual content management system <http://www.anwiki.com>
 * Copyright (C) 2007-2009 Antoine Walter <http://www.anw.fr>
 * 
 * Anwiki is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 * 
 * Anwiki is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Anwiki.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Override file for ./anwiki.inc.php.
 * Read INSTALL-ADVANCED instructions to learn more about this file.
 * 
 * @package Anwiki
 * @version $Id: _anwiki-override-DISABLED.inc.php 120 2009-02-08 14:06:11Z anw $
 * @copyright 2007-2009 Antoine Walter
 * @license http://www.gnu.org/copyleft/gpl.html GNU Public License 3
 */

/**
 * Full path to this Anwiki instance.
 */
define('ANWPATH_ROOT_SETUP', '/var/www/adblockplus.org/anwiki/');

/**
 * Full path to Anwiki shared code repository.
 */
define('ANWPATH_ROOT_SHARED', ANWPATH_ROOT_SETUP);

/**
 * Allow PHP eval() function usage?
 * Uncomment this line ONLY if you know exactly what you are doing.
 */
//define('ANWIKI_PHPEVAL_ENABLED', true);

/**
 * Enable devel mode?
 * Uncomment this line to enable strict PHP errors reporting.
 */
//define('ANWIKI_DEVEL', true);

/**
 * Require default file.
 */
require_once(ANWPATH_ROOT_SHARED.ANWFILE_INC);

?>
