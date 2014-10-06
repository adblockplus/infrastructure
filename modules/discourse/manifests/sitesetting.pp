define discourse::sitesetting(
  $setting = $title,
  $value = undef,
  $type = 1,
  $ensure = 'present'
) {

  $escaped_value = postgresql_escape($value)
  $escaped_setting = postgresql_escape($setting)
  $escaped_type = postgresql_escape($type)

  case $ensure {
    default: {
      err("unknown ensure value ${ensure}")
    }
    present: {
      # This is apparently how you do a conditional INSERT in PostgreSQL - sorry
      $update_sql = "UPDATE site_settings SET value = '$escaped_value', data_type = $escaped_type WHERE name = '$escaped_setting' RETURNING 1"
      $columns = "name, data_type, value, created_at, updated_at"
      $values = "SELECT '$escaped_setting', $escaped_type, '$escaped_value', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP"

      postgresql_psql {"WITH upd AS ($update_sql) INSERT INTO site_settings ($columns) $values WHERE NOT EXISTS (SELECT * FROM upd)":
        db => 'discourse',
        psql_user => 'discourse',
        notify => Service['discourse'],
        unless => "SELECT 1 FROM site_settings WHERE name = '$escaped_setting' AND value = '$escaped_value' AND data_type = $escaped_type",
      }
    }
    absent: {
      postgresql_psql {"DELETE FROM site_settings WHERE name = '$escaped_setting'":
        db => 'discourse',
        psql_user => 'discourse',
        notify => Service['discourse'],
        unless => "SELECT 1 WHERE NOT EXISTS (SELECT 1 FROM site_settings WHERE name = '$escaped_setting')",
      }
    }
  }
}
