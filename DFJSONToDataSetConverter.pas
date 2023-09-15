unit DFJSONToDataSetConverter;

interface

uses
  System.SysUtils, System.JSON, Data.DB, Datasnap.DBClient;

type
  TJSONToDataSetOptions = (jdoAssumeNestedArray, jdoIgnoreUnknownFields);
  TJSONToDataSetOptionsSet = set of TJSONToDataSetOptions;

procedure JSONToDataSet(const jsonString: string; dataSet: TClientDataSet); overload;
procedure JSONToDataSet(const jsonString: string; dataSet: TClientDataSet; const options: TJSONToDataSetOptionsSet); overload;
procedure DeleteRecord(dataSet: TClientDataSet; const primaryKeyField: string; const primaryKeyValue: Variant);
procedure InsertRecord(dataSet: TClientDataSet; const jsonData: string);
procedure EditRecord(dataSet: TClientDataSet; const primaryKeyField: string; const primaryKeyValue: Variant; const jsonData: string);

implementation

procedure JSONToDataSet(const jsonString: string; dataSet: TClientDataSet); overload;
begin
  JSONToDataSet(jsonString, dataSet, [jdoAssumeNestedArray]);
end;

procedure JSONToDataSet(const jsonString: string; dataSet: TClientDataSet; const options: TJSONToDataSetOptionsSet); overload;
var
  jsonObject: TJSONValue;
  jsonArray: TJSONArray;
  i: Integer;
  field: TField;
begin
  jsonObject := TJSONObject.ParseJSONValue(jsonString);
  try
    if Assigned(jsonObject) and (jsonObject is TJSONObject) then
    begin
      jsonArray := nil;
      if jdoAssumeNestedArray in options then
        jsonArray := (jsonObject as TJSONObject).GetValue('items') as TJSONArray
      else
      begin
        // If not assuming nested array, check if the root is an array
        if jsonObject is TJSONArray then
          jsonArray := jsonObject as TJSONArray;
      end;

      if Assigned(jsonArray) then
      begin
        // Clear existing fields and data
        dataSet.Fields.Clear;
        dataSet.CreateDataSet;

        for i := 0 to jsonArray.Count - 1 do
        begin
          dataSet.Append;

          for field in dataSet.Fields do
          begin
            // Assume JSON keys match field names
            if jsonArray.Items[i].GetValue(field.FieldName) <> nil then
              MapJSONToField(jsonArray.Items[i].GetValue(field.FieldName), field, options);
          end;

          dataSet.Post;
        end;
      end;
    end;
  finally
    jsonObject.Free;
  end;
end;

procedure MapJSONToField(jsonValue: TJSONValue; field: TField; const options: TJSONToDataSetOptionsSet);
begin
  if jsonValue is TJSONNull then
    field.Clear
  else if jsonValue is TJSONNumber then
  begin
    if (field is TIntegerField) then
      TIntegerField(field).Value := (jsonValue as TJSONNumber).AsInt
    else if (field is TFloatField) then
      TFloatField(field).Value := (jsonValue as TJSONNumber).AsDouble
    else if (field is TCurrencyField) then
      TCurrencyField(field).Value := StrToCurrDef((jsonValue as TJSONNumber).Value, 0.0)
    else if (field is TBCDField) then
      TBCDField(field).Value := StrToBcd((jsonValue as TJSONNumber).Value)
  end
  else if jsonValue is TJSONString then
    field.Value := (jsonValue as TJSONString).Value
  else if jsonValue is TJSONTrue then
    field.AsBoolean := True
  else if jsonValue is TJSONFalse then
    field.AsBoolean := False
  else if jsonValue is TJSONArray then
  begin
    if field is TMemoField then
      TMemoField(field).AsString := (jsonValue as TJSONArray).ToJSON
    else
      raise EConvertError.Create('Cannot map JSON array to field: ' + field.FieldName);
  end
  else
  begin
    if not (jdoIgnoreUnknownFields in options) then
      raise EConvertError.Create('Unknown JSON value type for field: ' + field.FieldName);
  end;
end;

procedure DeleteRecord(dataSet: TClientDataSet; const primaryKeyField: string; const primaryKeyValue: Variant);
begin
  if dataSet.Locate(primaryKeyField, primaryKeyValue, []) then
    dataSet.Delete;
end;

procedure InsertRecord(dataSet: TClientDataSet; const jsonData: string);
begin
  dataSet.Append;
  JSONToDataSet(jsonData, dataSet);
  dataSet.Post;
end;

procedure EditRecord(dataSet: TClientDataSet; const primaryKeyField: string; const primaryKeyValue: Variant; const jsonData: string);
begin
  if dataSet.Locate(primaryKeyField, primaryKeyValue, []) then
  begin
    dataSet.Edit;
    JSONToDataSet(jsonData, dataSet);
    dataSet.Post;
  end;
end;

end.