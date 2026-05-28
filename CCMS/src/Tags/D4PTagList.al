namespace D4P.CCMS.Tags;

page 62037 "D4P Tag List"
{
    ApplicationArea = All;
    Caption = 'D4P Tag List';
    PageType = List;
    SourceTable = "D4P Tag";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                }
                field(Description; Rec.Description)
                {
                }
            }
        }
    }
}
