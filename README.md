<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)"  srcset="assets/brand/radauthenticator-logo-reversed.svg">
    <source media="(prefers-color-scheme: light)" srcset="radauthenticator-logo.svg">
    <img alt="radAuthenticator logo" src="assets/brand/radauthenticator-logo.svg" width="420">
  </picture>
</p>

---

### rad-Authenticator

Time-Based One-Time Password (TOTP) projects in Delphi with Google Authenticator compatible PIN number generation

Quick Start
-----------
Generating a one-time PIN from a Base32-encoded secret key is a single call (as used in the included demo):

```delphi
uses
  radRTL.TOTP;

OTPResult.Text := TTOTP.GeneratePassword(SecretKey.Text);
```

That returns the current 6-digit PIN for the given secret. Pass a `TOTPLength` to change the digit count:

```delphi
OTPResult.Text := TTOTP.GeneratePassword(SecretKey.Text, TOTPLength.EightDigits);
```

How It Works
------------
- **HOTP: HMAC-Based One-Time Password Algorithm** ([RFC 4226](https://datatracker.ietf.org/doc/html/rfc4226)) is the
  basis. `THOTP` (unit `radRTL.HOTP`) decodes the Base32 secret, computes an HMAC-SHA1 over the counter value, and
  truncates the digest to a 6-9 digit PIN.
- **`TTOTP`** (unit `radRTL.TOTP`) extends `THOTP` with the [RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238)
  time-step counter: `T = (UnixTime - T0) div TimeStep` (default `T0 = 0`, `TimeStep = 30` seconds). In other words,
  TOTP is just HOTP with the current time-step used as the moving counter.
- Verification (`TTOTP.ValidatePassword`) accepts +/- a window of time steps for clock skew (RFC 6238 section 5.2) and
  uses a constant-time comparison over the full window.

Validated Against the RFCs
--------------------------
The DUnit test suite validates the implementation against the official specification test vectors:
- **HOTP** values are checked against the [RFC 4226](https://datatracker.ietf.org/doc/html/rfc4226) Appendix D vectors.
- **TOTP** values are checked against the [RFC 6238](https://datatracker.ietf.org/doc/html/rfc6238) Appendix B vectors.

Blog Series
-----------
A five-part blog post series walks through the design and implementation of this project:
[RAD Authenticator series on ideasawakened.com](https://ideasawakened.com/tags/rad-authenticator/)