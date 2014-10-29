# PRIVATE CLASS: do not call directly
class mongodb::server::root_password {

  # Manage root password if it is set
  if ($mongodb::server::root_password) {

    $database = 'admin'

    mongodb_database { $database:
      ensure        => present,
      privileged    => false,
      root_user     => $mongodb::server::root_user,
      root_password => $mongodb::server::root_password
    } ->
    mongodb_user { $mongodb::server::root_user:
      ensure        => present,
      password      => $mongodb::server::root_password,
      database      => $database,
      roles         => ['root'],
      privileged    => false,
      root_user     => $mongodb::server::root_user,
      root_password => $mongodb::server::root_password
    }
  }
}
