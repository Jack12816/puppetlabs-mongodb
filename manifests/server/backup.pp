# See README.me for usage.
class mongodb::server::backup (
  $backupuser,
  $backuppassword,
  $backupdir,
  $backupdirmode = '0700',
  $backupdirowner = 'root',
  $backupdirgroup = 'root',
  $backupcompress = true,
  $backuprotate = 30,
  $delete_before_dump = false,
  $backupdatabases = [],
  $file_per_database = false,
  $ensure = 'present',
  $time = ['23', '5'],
  $postscript = false,
  $execpath   = '/usr/bin:/usr/sbin:/bin:/sbin',
) {

  mongodb_user { "${backupuser}":
    ensure        => present,
    password      => $backuppassword,
    database      => 'admin',
    roles         => ['backup'],
    privileged    => $privileged,
    root_user     => $mongodb::server::root_user,
    root_password => $mongodb::server::root_password
  } ->

  file { 'mongodbbackup.sh':
    ensure  => $ensure,
    path    => '/usr/local/sbin/mongodbbackup.sh',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => template('mongodb/mongodbbackup.sh.erb'),
  } ->

  file { 'mongodbbackupdir':
    ensure => 'directory',
    path   => $backupdir,
    mode   => $backupdirmode,
    owner  => $backupdirowner,
    group  => $backupdirgroup,
  } ->

  cron { 'mongodb-backup':
    ensure  => $ensure,
    command => '/usr/local/sbin/mongodbbackup.sh',
    user    => 'root',
    hour    => $time[0],
    minute  => $time[1],
    require => File['mongodbbackup.sh'],
  }
}
