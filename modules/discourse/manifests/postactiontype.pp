define discourse::postactiontype(
  $id,
  $key = $title,
  $is_flag = false,
  $icon = undef,
  $position = 0,
  $ensure = 'present'
) {
  # Attempt some escaping
  $escaped_id = regsubst($id, '\D', '', 'G')
  $escaped_key = regsubst($key, '[\'\\]', '\\\1', 'G')
  if $is_flag {
    $escaped_flag = 'true'
  }
  else {
    $escaped_flag = 'false'
  }
  if $icon {
    $dummy = regsubst($icon, '[\'\\]', '\\\1', 'G')
    $escaped_icon = "'${dummy}'"
  }
  else {
    $escaped_icon = "null"
  }
  $escaped_position = regsubst($position, '\D', '', 'G')

  case $ensure {
    default: {
      err("unknown ensure value ${ensure}")
    }
    present: {
      # This is apparently how you do a conditional INSERT in PostgreSQL - sorry
      $update_sql = "UPDATE post_action_types SET name_key = '$escaped_key', is_flag = $escaped_flag, icon = $escaped_icon, position = $escaped_position WHERE id = $escaped_id RETURNING 1"
      $columns = "id, name_key, is_flag, icon, position, created_at, updated_at"
      $values = "SELECT $escaped_id, '$escaped_key', $escaped_flag, $escaped_icon, $escaped_position, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP"

      postgresql_psql {"WITH upd AS ($update_sql) INSERT INTO post_action_types ($columns) $values WHERE NOT EXISTS (SELECT * FROM upd)":
        db => 'discourse',
        psql_user => 'discourse',
        unless => 'SELECT false'
      }
    }
    absent: {
      postgresql_psql {"DELETE FROM post_action_types WHERE id = $escaped_id":
        db => 'discourse',
        psql_user => 'discourse',
        unless => 'SELECT false'
      }
    }
  }
}
