unit radRTL.UnitTestRunner;

interface

uses
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnit,
  TestInsight.Client,
  //workaround units
  System.IniFiles,
  System.NetConsts,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.SysUtils,
  {$ENDIF }
  DUnitTestRunner;


procedure RunRegisteredTests;


implementation

{$IFDEF TESTINSIGHT}
{
  IsTestInsightRunning is from the TestInsight wiki: https://bitbucket.org/sglienke/testinsight/wiki/FAQ
  and answer from Stefan: https://bitbucket.org/sglienke/testinsight/issues/36/run-unit-tests-without-testinsight
  Be aware of possible contradiction in comment: https://bitbucket.org/sglienke/testinsight/issues/116/clicking-run-selected-test-causes-running

  The goal is to allow TESTINSIGHT to be defined in the code but TestInisght not utilized if
  one or more members of a team doesn't have the plugin installed.  (No code changes or custom flags needed for any team member.)


  Reason this wiki answer doesn't fully work:

  Per Stefan: "there is a little hack in the IDE plugin that it sets ExecuteTests to false when you hit the FF button
  and no test is selected but resets after GetOptions was called once. This effectively stops the FastForward button
  from working as expected if GetOptions was called which occurs if you use IsTestInsightRunning..."

}
// wiki FAQ code
// function IsTestInsightRunning: Boolean;
// var
//   client: ITestInsightClient;
// begin
//   client := TTestInsightRestClient.Create;
//   client.StartedTesting(0);
//   Result := not client.HasError;
// end;


// Workaround until Stefan adds a supported method to solve the problem described above
// To test if TestInsight is installed simply look for TestInsightSettingis.ini by default for speed,
// or can make a test web call to the TestInsight IDE plugin if pPerformHTTPCheck=True (which is a little slower, but more precise)
function IsTestInsightInstalled(const pHTTPCheck:Boolean=False):Boolean;
var
  vIniFileName:string;
  vIniFile:TCustomIniFile;
  vHTTP:THTTPClient;
  vBaseURL:string;
  iResponse:IHTTPResponse;
begin

  Result := False;
  vBaseURL := TestInsight.Client.DefaultUrl;

  vIniFileName := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'TestInsightSettings.ini';
  if FileExists(vIniFileName) then
  begin

    Result := True;  //This particular machine has the TestInsightSettings.ini in the same folder as the test application which should be a good enough check for most

    if pHTTPCheck then
    begin
      vIniFile := TMemIniFile.Create(vIniFileName);
      try
        vBaseURL := vIniFile.ReadString('Config', 'BaseUrl', vBaseURL);
      finally
        vIniFile.Free;
      end;
    end;
  end;


  if pHTTPCheck then
  begin

    if (vBaseURL.Length > 0) and (not vBaseURL.EndsWith('/')) then
    begin
      vBaseURL := vBaseURL + '/';
    end;

    vHTTP := THTTPClient.Create();
    try
      vHTTP.ContentType := 'application/json';
      try
        iResponse := vHTTP.Get(vBaseURL + 'options', nil);
        Result := (iResponse.StatusCode >= 200) and (iResponse.StatusCode < 300);
      except
        Result := False;
      end;
    finally
      vHTTP.Free();
    end;

  end;
end;
{$ENDIF}


procedure RunRegisteredTests;
var
  vTestsExecuted:Boolean;
begin

  vTestsExecuted := False;

  {$IFDEF TESTINSIGHT}
  if IsTestInsightInstalled(true) then
  begin
    TestInsight.DUnit.RunRegisteredTests;
    vTestsExecuted := True;
  end;
  {$ENDIF}

  if not vTestsExecuted then
  begin
    DUnitTestRunner.RunRegisteredTests;

    if IsConsole then
    begin
      {$WARN SYMBOL_PLATFORM OFF}
      if DebugHook <> 0 then // Running within the IDE
      begin
        // Allow developer to view console results (F9)
        Writeln('Hit any key to exit');
        Readln;
      end;
      {$WARN SYMBOL_PLATFORM ON}
    end;
  end;

end;


end.
