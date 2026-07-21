# Changelog

All notable changes to this project are documented in this file.

## v1.0.37
- Zeroize intermediate key material (Base32-decoded secret, UTF-8 encoded secret, counter bytes, and HMAC digest) after each OTP computation, wiping the buffers `THOTP` allocates even on the exception path. Caller-owned secrets are left untouched.
[#15](https://github.com/radprogrammer/rad-authenticator/issues/15)
