class private::discourse {
  # Database password for the discourse user
  $database_password = 'vagrant'

  # Email addresses of accounts that will get admin privileges (have to be confirmed)
  $admins = ['test1@example.com', 'test2@example.com']

  # Google OAuth2 credentials (only valid for intraforum.test.example.com)
  $google_client_id = '999843142701-ob74a7iua4vc6850stl29fdd8bhrt68j.apps.googleusercontent.com'
  $google_client_secret = 'jVpuVO2T1T4T9WQxAfGHWgeY'
}
