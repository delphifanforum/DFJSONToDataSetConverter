# Delphi JSON to DataSet Converter

A simple Delphi utility to convert JSON data to a TDataSet (e.g., TClientDataSet) and perform CRUD operations.

## Usage

1. **Clone or Download the Project**

   Clone or download this repository to get the `DFJSONToDataSetConverter` unit and example Delphi project.

2. **Integration**

   Copy the `DFJSONToDataSetConverter.pas` unit into your Delphi project.

3. **Usage Examples**

   ### Loading JSON Data

  ```pascal
   procedure LoadJSONData(const jsonString: string);
   begin
     // Load JSON data into a TClientDataSet
     JSONToDataSet(jsonString, ClientDataSet1);
   end; 
   ```
   ### Deleting a Record

  ```pascal
  procedure DeleteRecord(primaryKeyValue: Variant);
begin
  // Delete a record based on the primary key value
  DeleteRecord(ClientDataSet1, 'ID', primaryKeyValue);
end;
```

  ### Inserting a Record

  ```pascal
procedure InsertRecord(const jsonData: string);
begin
  // Insert a new record using JSON data
  InsertRecord(ClientDataSet1, jsonData);
end;

```

  ### Editing a Record

  ```pascal
procedure EditRecord(primaryKeyValue: Variant; const jsonData: string);
begin
  // Edit an existing record based on the primary key value and update using JSON data
  EditRecord(ClientDataSet1, 'ID', primaryKeyValue, jsonData);
end;


```

  ### Application Example

  ```pascal
procedure TForm1.LoadJSONButtonClick(Sender: TObject);
var
  jsonString: string;
begin
  // Replace jsonString with your actual JSON data
  jsonString := '{"items": [{"ID": 1, "Name": "John"}, {"ID": 2, "Name": "Alice"}]}';

  // Load JSON data into the dataset
  JSONToDataSet(jsonString, ClientDataSet1);
end;

procedure TForm1.DeleteRecordButtonClick(Sender: TObject);
var
  primaryKeyValue: Variant;
begin
  // Replace 'ID' with your primary key field name
  primaryKeyValue := 1; // Replace with the actual value to delete

  // Delete the record based on the primary key field
  DeleteRecord(ClientDataSet1, 'ID', primaryKeyValue);
end;

procedure TForm1.InsertRecordButtonClick(Sender: TObject);
var
  jsonData: string;
begin
  // Replace jsonData with your new record data
  jsonData := '{"ID": 3, "Name": "Bob"}';

  // Insert a new record using JSON data
  InsertRecord(ClientDataSet1, jsonData);
end;

procedure TForm1.EditRecordButtonClick(Sender: TObject);
var
  primaryKeyValue: Variant;
  jsonData: string;
begin
  // Replace 'ID' with your primary key field name
  primaryKeyValue := 2; // Replace with the actual primary key value to edit

  // Replace jsonData with your updated record data
  jsonData := '{"ID": 2, "Name": "Updated Name"}';

  // Edit an existing record based on the primary key field and update it using JSON data
  EditRecord(ClientDataSet1, 'ID', primaryKeyValue, jsonData);
end;

```

