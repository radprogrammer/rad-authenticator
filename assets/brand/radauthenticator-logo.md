# radAuthenticator - Logo

Demonstrates building a Google-Authenticator-type (TOTP 2FA) app in Delphi. Drawn in the
family style: dark tile, red "rad" + dark product word, Montserrat outlined, shared palette.

## Glyph

A padlock whose body shows the rotating one-time code as three colored dots. The padlock reads
as authentication/secured access; the code dots hint at the rotating OTP. It is the only
padlock in the family, so it stays distinct from the key (radSoftwareLicense) and the shield
(radCodeScanner). Kept generic on purpose - no Google marks or IP.

## Two icon cuts

- Detailed (radauthenticator-icon.svg): padlock + three code dots. Use at 32 px and up.
- Small (radauthenticator-icon-small.svg): bolder padlock + two dots, for crisp 16-24 px.

## Files (SVG)

- radauthenticator-icon.svg            Icon tile (detailed) - 32 px and up
- radauthenticator-icon-small.svg      Simplified icon for 16-24 px
- radauthenticator-logo.svg            Primary lockup (light backgrounds)
- radauthenticator-logo-reversed.svg   Reversed lockup (dark backgrounds)
- radauthenticator-logo-preview.png    Preview

SVG only; a PNG ladder or ICO is a one-pass export if you want it.

## README (saved family pattern)

<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)"  srcset="assets/radauthenticator-logo-reversed.svg">
    <source media="(prefers-color-scheme: light)" srcset="assets/radauthenticator-logo.svg">
    <img alt="radAuthenticator" src="assets/radauthenticator-logo.svg" width="420">
  </picture>
</p>

Wordmark is outlined, so the SVGs are font-independent.
