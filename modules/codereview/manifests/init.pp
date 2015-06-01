# == Class: codereview
#
# A codereview server setup based on Rietveld.
#
# === Parameters:
#
# [*domain*]
#   The auhority part of the URL the Rietveld instance is associated with.
#
# [*is_default*]
#   Whether the $domain shall become set up as default (or fallback)
#   within the HTTP daemon.
#
# [*certificate*]
#   The name of the SSL certificate file within modules/private/files, if
#   any. Requires a private_key as well.
#
# [*private_key*]
#   The name of the private key file within modules/private/files, if any.
#   Requires a certificate as well.
#
# === Examples:
#
#   class {'codereview':
#     domain => 'localhost',
#   }
#
class codereview(
  $domain,
  $is_default = false,
  $certificate = undef,
  $private_key = undef,
) {

  class {'rietveld':
    domain => $domain,
    certificate => $certificate,
    private_key => $private_key,
    is_default => $is_default,
  }

}
