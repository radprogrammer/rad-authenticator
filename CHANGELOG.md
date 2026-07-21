# Changelog

All notable changes to this project are documented in this file.

## v1.0.42
- Add `TTOTP.ValidatePassword` to verify a candidate TOTP within a configurable +/- N time-step clock-skew window (default 1, RFC 6238 section 5.2), plus a deterministic `ValidatePasswordAtTime` overload. Comparison is constant-time (`ConstantTimeEquals`, evaluating the full window with no early-out). `ByteArraysMatch` is now marked non-constant-time (not for secret comparison). Matched-step-delta / drift detection is tracked in [#20](https://github.com/radprogrammer/rad-authenticator/issues/20).
[#14](https://github.com/radprogrammer/rad-authenticator/issues/14)

## v1.0.41
- Replace the process-wide `THOTP.EnforceMinimumKeyLength` class var with a per-call parameter (and a `TTOTPOptions.EnforceMinimumKeyLength` field), removing the global mutable state so enforcement is thread-safe and cannot be toggled for other callers. Default remains off.
[#16](https://github.com/radprogrammer/rad-authenticator/issues/16)

## v1.0.40
- Add a `TTOTPOptions` record (output length, time step, T0) with safe defaults and a `TTOTP.GeneratePassword(secret, options)` overload, plus a deterministic `TTOTP.TimeStepCounter` helper. Support 9-digit output (`TOTPLength.NineDigits`); 10 digits is intentionally unsupported. A zero or negative time step raises `EOTPException`.
[#17](https://github.com/radprogrammer/rad-authenticator/issues/17)

## v1.0.39
- Extend `TBase32.Decode` strict mode (`pStrict`) to reject non-canonical input: non-zero trailing bits (RFC 4648 section 3.5) and data characters appearing after padding now raise `EBase32DecodeError`. Lenient (default) behavior is unchanged. Padding count/length validation is tracked in [#19](https://github.com/radprogrammer/rad-authenticator/issues/19).
[#13](https://github.com/radprogrammer/rad-authenticator/issues/13)

## v1.0.38
- Add an opt-in strict decode mode to `TBase32.Decode` (new `pStrict` parameter, default off / lenient). When enabled, decoding raises `EBase32DecodeError` on any character outside the Base32 alphabet (the `=` pad is still tolerated), and the string overload fails loud on a non-text payload instead of silently mangling it.
[#12](https://github.com/radprogrammer/rad-authenticator/issues/12)

## v1.0.37
- Zeroize intermediate key material (Base32-decoded secret, UTF-8 encoded secret, counter bytes, and HMAC digest) after each OTP computation, wiping the buffers `THOTP` allocates even on the exception path. Caller-owned secrets are left untouched.
[#15](https://github.com/radprogrammer/rad-authenticator/issues/15)
