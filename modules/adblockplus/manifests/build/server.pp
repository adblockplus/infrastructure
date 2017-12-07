# A prototype for importing the legacy resources associated with Adblock Plus
# builds (esp. browser extensions), see http://hub.eyeo.com/issues/3553 --
class adblockplus::build::server {

  # Order is important here! One can customize the abpssembly repository via
  # Hiera when including adblockplus::sitescripts, which would conflict with
  # the implicit defaults when including class adblockplus::abpssembly.
  include adblockplus::sitescripts
  include adblockplus::abpssembly
}
