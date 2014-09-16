class private::discourse {
  # Database password for the discourse user
  $database_password = 'vagrant'

  # Email addresses of accounts that will get admin privileges (have to be confirmed)
  $admins = ['test1@example.com', 'test2@example.com']

  # AirBrake API key
  $airbrake_key = '0123456789abcdef0123456789abcdef'
}
