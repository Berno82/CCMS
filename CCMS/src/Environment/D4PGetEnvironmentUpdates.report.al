namespace D4P.CCMS.Environment;

using System.Threading;

report 62033 "D4P Get Environment Updates"
{
    ApplicationArea = All;
    Caption = 'Get D365BC Environment Updates';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ToolTip = 'Get available version update information for selected environments.';

    dataset
    {
        dataitem("D4P BC Environment"; "D4P BC Environment")
        {
            RequestFilterFields = "Customer No.", "Tenant ID", Type, Name;
            DataItemTableView = where(State = const('Active'));

            trigger OnAfterGetRecord()
            begin
                ProcessEnvironment("D4P BC Environment");
            end;
        }
    }

    trigger OnPostReport()
    begin
        LogSummary();
    end;

    var
        EnvironmentManagement: Codeunit "D4P BC Environment Mgt";
        SucceededCount: Integer;
        SkippedCount: Integer;
        SkippedNames: Text;
        JobQueueSummaryMsg: Label 'Environment updates completed. Succeeded: %1. Skipped: %2. Skipped environments: %3.', Comment = '%1 = Succeeded count, %2 = Skipped count, %3 = Skipped environments';
        NoEnvironmentNamesTxt: Label '<none>';

    local procedure ProcessEnvironment(var BCEnvironment: Record "D4P BC Environment")
    begin
        if TryGetEnvironmentUpdates(BCEnvironment) then
            SucceededCount += 1
        else begin
            SkippedCount += 1;
            AddName(SkippedNames, BCEnvironment.Name);
        end;
    end;

    [TryFunction]
    local procedure TryGetEnvironmentUpdates(var BCEnvironment: Record "D4P BC Environment")
    begin
        EnvironmentManagement.GetEnvironmentUpdates(BCEnvironment, false);
    end;

    local procedure AddName(var NameList: Text; EnvironmentName: Text[100])
    begin
        if NameList <> '' then
            NameList += ', ';

        NameList += EnvironmentName;

        if StrLen(NameList) > 1500 then
            NameList := CopyStr(NameList, 1, 1500) + '...';
    end;

    local procedure LogSummary()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        SummaryText: Text;
    begin
        SummaryText := StrSubstNo(
          JobQueueSummaryMsg,
          SucceededCount,
          SkippedCount,
          GetNameListOrNone(SkippedNames));

        if TryGetCurrentJobQueueEntry(JobQueueEntry) then begin
            JobQueueEntry.InsertLogEntry(JobQueueLogEntry);
            JobQueueLogEntry.Description := CopyStr(SummaryText, 1, MaxStrLen(JobQueueLogEntry.Description));
            if StrLen(SummaryText) > MaxStrLen(JobQueueLogEntry.Description) then
                JobQueueLogEntry."Error Message" := CopyStr(SummaryText, 1, MaxStrLen(JobQueueLogEntry."Error Message"));
            JobQueueLogEntry.Modify();
        end;

        if GuiAllowed then
            Message(SummaryText);
    end;

    local procedure TryGetCurrentJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        JobQueueEntry.SetRange("User Session ID", SessionId());
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
        JobQueueEntry.SetRange("Object ID to Run", Report::"D4P Get Environment Updates");
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
        exit(JobQueueEntry.FindFirst());
    end;

    local procedure GetNameListOrNone(NameList: Text): Text
    begin
        if NameList = '' then
            exit(NoEnvironmentNamesTxt);

        exit(NameList);
    end;
}
