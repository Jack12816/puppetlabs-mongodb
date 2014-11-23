# == Class: mongodb::db
#
# Class for creating mongodb databases and users.
#
# == Parameters
#
#  user - Database username.
#  password_hash - Hashed password. Hex encoded md5 hash of "$username:mongo:$password".
#  password - Plain text user password. This is UNSAFE, use 'password_hash' unstead.
#  roles (default: ['dbAdmin']) - array with user roles.
#  tries (default: 10) - The maximum amount of two second tries to wait MongoDB startup.
#
define mongodb::db (
  $user,
  $password_hash = false,
  $password      = false,
  $roles         = ['dbOwner'],
  $tries         = 10,
  $privileged    = $mongodb::server::privileged
) {

  if ($password_hash) {
    $real_password = $password_hash
  }
  elsif ($password) {
    $real_password = $password
  }
  else {
    fail("Parameter 'password_hash' or 'password' should be provided to mongodb::db.")
  }

  mongodb_database { $name:
    ensure        => present,
    tries         => $tries,
    require       => Class['mongodb::server'],
    privileged    => $privileged,
    root_user     => $mongodb::server::root_user,
    root_password => $mongodb::server::root_password
  } ->
  mongodb_user { $user:
    ensure        => present,
    password      => $real_password,
    database      => $name,
    roles         => $roles,
    privileged    => $privileged,
    root_user     => $mongodb::server::root_user,
    root_password => $mongodb::server::root_password
  }
}
