class private::discourse {
  # Database password for the discourse user
  $database_password = 'vagrant'

  # Secret token for session generation (initializers/secret_token.rb), generated via rake secret
  $secret = '12f125a3f0bf338f6dc1382786537d36f279e011cc91390ed57691725924c31ddf778e30eb7cc686361c0815202ec5ec40f8b6627ca960732eb1c0e6769db5fa'

  # Email addresses of accounts that will get admin privileges (have to be confirmed)
  $admins = ['test1@example.com', 'test2@example.com']

  # AirBrake API key
  $airbrake_key = '0123456789abcdef0123456789abcdef'
}
