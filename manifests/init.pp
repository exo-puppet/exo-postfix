# Class: postfix
#
#   This module manages the postfix service.
#
#   Tested platforms:
#    - Ubuntu 11.04 Natty
#
# Parameters:
#   $lastversion:
#       this variable allow to chose if the package should always be updated to the last available version (true) or not (false) (default: false)
#
# Actions:
#
#  Installs, configures, and manages the postfix service.
#
# Requires:
#
# Sample Usage:
#
#   class { "postfix":
#     lastversion => false,
#   }
#
# [Remember: No empty lines between comments and class definition]
class postfix ($lastversion=false) {
    # parameters validation
    if ($lastversion != true) and ($lastversion != false) {
        fail("lastversion must be true or false")
    }

    # submodules 
    include postfix::params, postfix::install, postfix::config, postfix::service
}