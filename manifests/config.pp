# Class: postfix::config
#
# This class manage the postfix configuration
class postfix::config {
    file { $postfix::params::configuration_dir:
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 0755,
        require => Class["postfix::install"],
        notify => Class["postfix::service"],
    }
}
