import ballerina/io;
import ballerinax/googleapis.sheets as sheets;

configurable string csvFilePath = ?;
configurable string spreadsheetName = ?;
configurable string bearerToken = ?;

public function main() returns error? {
    // Read CSV file
    string[][]|io:Error csvContent = io:fileReadCsv(csvFilePath);
    if csvContent is io:Error {
        return error("Error reading CSV file", csvContent);
    }

    // Initialize Google Sheets client
    sheets:ConnectionConfig sheetsConfig = {
        auth: {
            token: bearerToken
        }
    };
    sheets:Client sheetsClient = check new (sheetsConfig);

    // Create a new spreadsheet
    sheets:Spreadsheet spreadsheet = check sheetsClient->createSpreadsheet(spreadsheetName);
    string spreadsheetId = spreadsheet.spreadsheetId;

    // Get the first sheet name
    string sheetName = spreadsheet.sheets[0].properties.title;

    // Append each row to the spreadsheet
    foreach string[] row in csvContent {
        check sheetsClient->appendRowToSheet(spreadsheetId, sheetName, row);
    }

    io:println("CSV data successfully pushed to Google Spreadsheet: " + spreadsheet.spreadsheetUrl);
}