define discourse::admin(
  $email = $title,
  $ensure = 'present'
) {
  # Attempt some escaping
  $escaped_email = regsubst($email, '[\'\\]', '\\\1', 'G')

  case $ensure {
    default: {
      err("unknown ensure value ${ensure}")
    }
    present: {
      # Only confirmed accounts should be made admins
      postgresql_psql {"UPDATE users SET admin = true WHERE email = '$escaped_email'":
        db => 'discourse',
        psql_user => 'discourse'
      }
    }
    absent: {
      postgresql_psql {"UPDATE users SET admin = false WHERE email = '$escaped_email'":
        db => 'discourse',
        psql_user => 'discourse'
      }
    }
  }
}
