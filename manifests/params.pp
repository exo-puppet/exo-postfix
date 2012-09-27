# Class: postfix::params
#
# This class manage the postfix parameters for different OS
class postfix::params {

	$ensure_mode = $postfix::lastversion ? {
		true => latest,
		default => present
	}
	info ("postfix ensure mode = $ensure_mode")


	case $::operatingsystem {
		/(Ubuntu|Debian)/: {
            $package_name       = ["postfix", "bsd-mailx"]
            $service_name       = "postfix"
            $configuration_dir  = "/etc/postfix"
		}
		default: {
			fail ("The ${module_name} module is not supported on $::operatingsystem")
		}
	}
}
