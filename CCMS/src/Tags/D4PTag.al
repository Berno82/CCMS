namespace D4P.CCMS.Tags;

table 62008 "D4P Tag"
{
    Caption = 'D4P Tag';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Name; Text[50])
        {
            Caption = 'Name';
            NotBlank = true;
            ToolTip = 'Specifies the name of the tag. This is a required field and must be unique.';
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description for the tag. ';
        }
    }
    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }
}
