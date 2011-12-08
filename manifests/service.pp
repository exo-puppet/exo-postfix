# Class: postfix::service
#
# This class manage the postfix service
class postfix::service {
	service { "postfix":
		ensure     => running,
		name       => $postfix::params::service_name,
		hasstatus  => true,
		hasrestart => true,
		require => Class["postfix::config"],
	}
}
