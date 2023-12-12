import ballerina/http;
import ballerinax/mongodb;

type PoliceRecord record {|
    string _id;
    string nic?;
    int numberOfCrimes;
    int severity;
|};

# Configurations for the MongoDB endpoint
configurable string username = ?;
configurable string password = ?;
configurable string database = ?;
configurable string collection = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service /police\-record on new http:Listener(9090) {
    final mongodb:Client databaseClient;

    public function init() returns error? {
        self.databaseClient = check new ({connection: {url: string `mongodb+srv://${username}:${password}@digigrama.pgauwpq.mongodb.net/`}});
    }

    # A resource for getting the PoliceRecord of a given nic
    # + nic - NIC of the person
    # + return - PoliceRecord or error
    resource function get getPoliceRecordFromNIC(string nic) returns json|error {
        stream<PoliceRecord, error?>|mongodb:Error PoliceRecordStream = check self.databaseClient->find(collection, database);
        PoliceRecord[]|error policeRecords = from PoliceRecord PoliceRecord in check PoliceRecordStream
            select PoliceRecord;

        return (check policeRecords).toJson();
    }
    resource function get liveness() returns http:Ok {
        return http:OK;
    }

    resource function get readiness() returns http:Ok|error {
        int _ = check self.databaseClient->countDocuments(collection, database);
        return http:OK;
    }
}
