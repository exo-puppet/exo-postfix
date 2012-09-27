# Class: postfix::install
#
# This class manage the installation of the postfix package
class postfix::install {
    package { "mail" :
        name    => $postfix::params::package_name,
        ensure  => $postfix::params::ensure_mode,
        require => [ Exec ["repo-update"],],
    }
}
