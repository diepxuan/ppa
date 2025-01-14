if test "$PHP_VERSION_ID" -ge 80400 -a "$PHP_VERSION_ID" -lt 80500; then
  AC_MSG_ERROR([PHP 8.4 is not supported for Runkit7.])
fi
