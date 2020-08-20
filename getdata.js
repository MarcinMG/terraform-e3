'use strict'
const AWS = require('aws-sdk');
const documentClient = new AWS.DynamoDB.DocumentClient({ region: "eu-central-1"});

AWS.config.update({ region: "eu-central-1"});

exports.handler = (event, context, callback) => {
    
    var response = " ***** ";
    
    var params = {
        TableName: "LogTest",
        KeyConditionExpression: "#yr = :yyyy",
        ExpressionAttributeNames:{
         "#yr": "timestamp"
        },
        ExpressionAttributeValues: {
            ":yyyy": 1
        },
        ScanIndexForward: "false",
        Limit: 10
    };
    
    documentClient.query(params, function(err, data) {
    if (err) {
        console.error("Unable to query. Error:", JSON.stringify(err, null, 2));
    } else {
        console.log("Query succeeded.");
        data.Items.forEach(function(item) {
            console.log(" -", item.timestamp + ": " + item.id);
            response += item.date + " " + item.ip_address + " ***** ";
        });
        callback(null, response);
    }
});
    
}