import ballerina/http;
import ballerina/log;
import ballerina/stringutils;
import ballerina/io;
http:ClientConfiguration mtlsClientEPConfig = {
    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
};

http:ClientConfiguration clientEPConfig = {
    secureSocket: {
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
};

public function main() {
    http:Client mtlsClientEP = new("https://localhost:9095", mtlsClientEPConfig);
    http:Client clientEp = new("https://localhost:9095", clientEPConfig);
    
    string mtlsResult = checkAuthHandler(mtlsClientEP);
    io:println("Mtls status : " + mtlsResult);
    
    //string normalResult = checkAuthHandler(clientEp);
    //io:println("Without Mtls status : " + normalResult);
    
}

public function makeClientCall(http:Client clientEP, string headerValue = "") returns boolean{
    http:Response | error resp;
    if (headerValue.length() != 0) {
        http:Request req = new;
        req.setHeader("Authorization", headerValue);
        resp = clientEP->get("/Hello/sayHello", req);
    } else {
        resp = clientEP->get("/Hello/sayHello");
    }
    
    if (resp is http:Response) {

        var payload = resp.getTextPayload();
        if (payload is string) {
            //if payload is correct message should go here.
            return stringutils:contains( payload, "Hello" );
            
        } else {

            log:printError(<string>payload.detail()["message"]);
        }
    } else {

        log:printError(<string>resp.detail()["message"]);
    }
    return false;
}

public function checkWithoutAuth(http:Client clientEp) returns boolean{
    boolean result = makeClientCall(clientEp);
    return result;
}

public function checkAuthHandler(http:Client clientEp) returns string{
    boolean woAuthResult = checkWithoutAuth(clientEp);
    string resultString = "";
    if(woAuthResult) {
        //log:printInfo("No auth\n");
        resultString = "No auth";
        return resultString;
    }
    boolean basicAuthResult = checkBasicAuth(clientEp);
    boolean jwtResult = checkJwt(clientEp);
    if (basicAuthResult && jwtResult) {
        //log:printInfo("BasicAuth and Jwt\n");
        resultString = "BasicAuth and Jwt";
    } else if (basicAuthResult) {
        //log:printInfo("BasicAuth \n");
        resultString = "BasicAuth";
    } else if (jwtResult) {
        //log:printInfo("JWT \n");
        resultString = "Jwt";
    } else  {
        //log:printInfo("Failure\n");
        resultString = "Failure";
    }
    return resultString;
}

public function checkBasicAuth(http:Client clientEp) returns boolean{
    string headerValue = "Basic YWRtaW46YWRtaW4=";
    boolean result = makeClientCall(clientEp, headerValue);
    return result;
}

public function checkJwt(http:Client clientEp) returns boolean{
    string headerValue = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5UZG1aak00WkRrM05qWTBZemM1TW1abU9EZ3dNVEUzTVdZd05ERTVNV1JsWkRnNE56YzRaQT09In0.eyJhdWQiOiJodHRwOlwvXC9vcmcud3NvMi5hcGltZ3RcL2dhdGV3YXkiLCJzdWIiOiJhZG1pbkBjYXJib24uc3VwZXIiLCJhcHBsaWNhdGlvbiI6eyJvd25lciI6ImFkbWluIiwidGllciI6IlVubGltaXRlZCIsIm5hbWUiOiJhYWEiLCJpZCI6MiwidXVpZCI6bnVsbH0sInNjb3BlIjoiYW1fYXBwbGljYXRpb25fc2NvcGUgZGVmYXVsdCIsImlzcyI6Imh0dHBzOlwvXC9sb2NhbGhvc3Q6OTQ0M1wvb2F1dGgyXC90b2tlbiIsInRpZXJJbmZvIjp7fSwia2V5dHlwZSI6IlBST0RVQ1RJT04iLCJzdWJzY3JpYmVkQVBJcyI6W10sImNvbnN1bWVyS2V5IjoicU9QdDRfSVZ4NzJGSUNjT19WV0FJTVpiZlhrYSIsImV4cCI6MzczMDI4MzUyMCwiaWF0IjoxNTgyNzk5ODczLCJqdGkiOiIwNGUwNTI0My1lYTMwLTQ5YTYtYjAzNS0wMGEwOTYzNDEyZmYifQ.fGgNtyVf9Q3xzEr0Fqk9LrCjCUURDLcNpoPl2743MbE_0l7tqmLAoaWYxbPo7xYHTYcOCEZtnED_rTJWbrNsEJ4aOiFLhKzC3WI2n2EhfGre80-HqR9znSVPdllKrMp7h8phz60CwnYIL9QIKFGPVbUdv8SPH0LrIshbQzUZd2ZayfZ89s9MqXWJvtXpn4ip6JNYw_cs0rvCcclZyI5w2GqAwRrNQJagzvH7zRsQJajk8b56Ssi6gCBldadXucoI0E0xQhp0aCYUi1k0VdYVK-EBgROl16s9WUnkYkPPSo4byQBEbAgmksDoJW2nek6dA6MpbXX3XOUOmBw37tMZ9A";
    boolean result = makeClientCall(clientEp, headerValue);
    return result;
}

