# This installs a MongoDB server. See README.md for more details.
class mongodb::server (
  $ensure           = $mongodb::params::ensure,

  $user             = $mongodb::params::user,
  $group            = $mongodb::params::group,

  $config           = $mongodb::params::config,
  $dbpath           = $mongodb::params::dbpath,
  $pidfilepath      = $mongodb::params::pidfilepath,

  $service_provider = $mongodb::params::service_provider,
  $service_name     = $mongodb::params::service_name,
  $service_enable   = $mongodb::params::service_enable,
  $service_ensure   = $mongodb::params::service_ensure,
  $service_status   = $mongodb::params::service_status,
  $restart          = $mongodb::params::restart,

  $package_ensure  = $mongodb::params::package_ensure,
  $package_name    = $mongodb::params::server_package_name,

  $auth            = false,
  $bind_ip         = $mongodb::params::bind_ip,
  $cpu             = undef,
  $diaglog         = undef,
  $directoryperdb  = undef,
  $fork            = $mongodb::params::fork,
  $journal         = $mongodb::params::journal,
  $keyfile         = undef,
  $logappend       = true,
  $logpath         = $mongodb::params::logpath,
  $maxconns        = undef,
  $mms_interval    = undef,
  $mms_name        = undef,
  $mms_token       = undef,
  $noauth          = undef,
  $nohints         = undef,
  $nohttpinterface = undef,
  $nojournal       = undef,
  $noprealloc      = undef,
  $noscripting     = undef,
  $notablescan     = undef,
  $nssize          = undef,
  $objcheck        = undef,
  $oplog_size      = undef,
  $port            = 27017,
  $profile         = undef,
  $quotafiles      = undef,
  $quota           = undef,
  $replset         = undef,
  $rest            = undef,
  $root_password   = undef,
  $root_user       = 'root',
  $set_parameter   = undef,
  $slowms          = undef,
  $smallfiles      = undef,
  $syslog          = undef,
  $verbose         = undef,
  $verbositylevel  = undef,

  $config_content  = undef,

  # Deprecated parameters
  $master          = undef,
  $slave           = undef,
  $only            = undef,
  $source          = undef,
) inherits mongodb::params {

  if ($mongodb::server::root_password) {
    $privileged = true
  } else {
    $privileged = false
  }

  Class['mongodb::server::root_password'] -> Mongodb::Db <| name != 'admin' |>

  include '::mongodb::server::install'
  include '::mongodb::server::config'
  include '::mongodb::server::service'
  include '::mongodb::server::root_password'

  anchor { 'mongodb::server::start': }
  anchor { 'mongodb::server::end': }

  if $restart {
    Anchor['mongodb::server::start'] ->
    Class['mongodb::server::install'] ->
    # Only difference between the blocks is that we use ~> to restart if
    # restart is set to true.
    Class['mongodb::server::config'] ~>
    Class['mongodb::server::service'] ->
    Class['mongodb::server::root_password'] ->
    Anchor['mongodb::server::end']
  } else {
    Anchor['mongodb::server::start'] ->
    Class['mongodb::server::install'] ->
    Class['mongodb::server::config'] ->
    Class['mongodb::server::service'] ->
    Class['mongodb::server::root_password'] ->
    Anchor['mongodb::server::end']
  }
}
