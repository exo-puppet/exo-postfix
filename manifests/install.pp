# Class: postfix::install
#
# This class manage the installation of the postfix package
class postfix::install {
  case $::operatingsystem {
    /(Ubuntu)/ : {
      case $::lsbdistrelease {
        /(10.04)/ : {
          # exim was the default MTA with Ubuntu 10.04
          package { [
            'exim4',
            'exim4-config',
            'exim4-daemon-light']:
            ensure => purged,
          }
        }
      }
    }
    default    : {
      fail("The ${module_name} module is not supported on ${::operatingsystem}")
    }
  }

  ensure_packages ( 'mail-pkg', {
    'ensure'  => $postfix::params::ensure_mode,
    'name'    => $postfix::params::package_name,
    'require' => Class['apt::update'],
  } )
  ensure_packages ( 'bsd-mailx', {
    'ensure'  => $postfix::params::ensure_mode,
    'require' => [Package['mail-pkg'],Class['apt::update']],
  } )
  # Tool to compute postfix statistics
  ensure_packages ( 'pflogsumm', {
    'ensure'  => $postfix::params::ensure_mode,
    'require' => [Package['mail-pkg','bsd-mailx'],Class['apt::update']],
  } )
}
