# Get-TestResultsForMCTF

This module returns a list of test results for a Motor Carrier Tax Filing where required by a state. It requires a collection of Freight Items to be passed in and a collection of Tests. The tests will have fields defined and regex patterns defined to test those fields for. Tests will also have a collection of Tests for the various companies required for a filing. A companytypes collection must be passed in with a defined unique fields that make up the unique companies for testing. Only one test result will be marked for the freight item per bad company test, but the Company test results will show all errors with companies for seperated processing.