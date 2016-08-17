################################################################################
#
#   This module manages the postfix service.
#
#   Tested platforms:
#    - Ubuntu 11.10 Oneiric
#    - Ubuntu 11.04 Natty
#    - Ubuntu 10.04 Lucid
#
#
# == Parameters
#   [+lastversion+]
#       (OPTIONAL) (default: false)
#
#       this variable allow to chose if the package should always be updated to the last available version (true) or not (false)
#       (default: false)
#
# == Modules Dependencies
#
# [+repo+]
#   the +repo+ puppet module is needed to :
#
#   - refresh the repository before installing package (in postfix::install)
#
# == Examples
#
#   class { "postfix":
#       lastversion => true,
#   }
#
################################################################################
class postfix ($lastversion = false) {
  # parameters validation
  if ($lastversion != true) and ($lastversion != false) {
    fail('lastversion must be true or false')
  }

  include stdlib
  include postfix::params
  # include postfix::params, postfix::install, postfix::config, postfix::service

  # Install packages
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

  # Configuration
  file { $postfix::params::configuration_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => 0755,
    require => Package['mail-pkg'],
    notify  => Service['postfix'],
  }

  # Service
  service { 'postfix':
    ensure     => running,
    name       => $postfix::params::service_name,
    hasstatus  => true,
    hasrestart => true,
    require    => File[$postfix::params::configuration_dir],
  }
}
