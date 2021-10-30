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
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnit,
  {$ELSE}
  DUnitTestRunner,
  {$ENDIF}
  radRTL.Base32Encoding in '..\..\..\radRTL.Base32Encoding.pas',
  radRTL.Base32Encoding.Tests in '..\radRTL.Base32Encoding.Tests.pas',
  radRTL.BitUtils in '..\..\..\radRTL.BitUtils.pas',
  radRTL.BitUtils.Tests in '..\radRTL.BitUtils.Tests.pas',
  radRTL.ByteArrayUtils in '..\..\..\radRTL.ByteArrayUtils.pas',
  radRTL.ByteArrayUtils.Tests in '..\radRTL.ByteArrayUtils.Tests.pas',
  radRTL.TOTP in '..\..\..\radRTL.TOTP.pas',
  radRTL.TOTP.Tests in '..\radRTL.TOTP.Tests.pas',
  radRTL.HOTP in '..\..\..\radRTL.HOTP.pas',
  radRTL.HOTP.Tests in '..\radRTL.HOTP.Tests.pas';

{$R *.RES}

begin

  {$IFDEF TESTINSIGHT}  //TestInsight IDE Plugin enabled

    TestInsight.DUnit.RunRegisteredTests;

  {$ELSE}  //Standard DUnit tests (typically from an automated build process)

    DUnitTestRunner.RunRegisteredTests;

    if IsConsole then
    begin
      {$WARN SYMBOL_PLATFORM OFF}
      if DebugHook <> 0 then //Running within the IDE
      begin
        // Allow developer to view console results (F9)
        Writeln('Hit any key to exit');
        Readln;
      end;
      {$WARN SYMBOL_PLATFORM ON}
    end;

  {$ENDIF}

end.

