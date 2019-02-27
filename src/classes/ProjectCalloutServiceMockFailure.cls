public class ProjectCalloutServiceMockFailure {
   
   public ProjectCalloutServiceMockFailure() { }

   public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setStatusCode(500);
      
      return response;
   }
}