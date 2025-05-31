@isTest
global class MissingAnimalMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');

        if (request.getMethod() == 'PUT') {
            response.setStatusCode(204);
        } else {
            response.setStatusCode(400);
            response.setBody('{"error":"Invalid request"}');
        }

        return response;
    }
}
