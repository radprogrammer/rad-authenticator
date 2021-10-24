program radRTL.DUnitTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  radRTL.Base32Encoding in '..\..\..\radRTL.Base32Encoding.pas',
  radRTL.Base32Encoding.Tests in '..\radRTL.Base32Encoding.Tests.pas',
  radRTL.BitUtils in '..\..\..\radRTL.BitUtils.pas',
  radRTL.BitUtils.Tests in '..\radRTL.BitUtils.Tests.pas',
  radRTL.ByteArrayUtils in '..\..\..\radRTL.ByteArrayUtils.pas',
  radRTL.ByteArrayUtils.Tests in '..\radRTL.ByteArrayUtils.Tests.pas',
  radRTL.OTP in '..\..\..\radRTL.OTP.pas',
  radRTL.OTP.Tests in '..\radRTL.OTP.Tests.pas';

{$R *.RES}

begin

  DUnitTestRunner.RunRegisteredTests;

end.

