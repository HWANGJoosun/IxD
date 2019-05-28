/****************************************************************
 [API 데모]
 https://azure.microsoft.com/ko-kr/services/cognitive-services/face/
 https://azure.microsoft.com/ko-kr/services/cognitive-services/computer-vision/
 
 [API 사용설명서]
 https://westus.dev.cognitive.microsoft.com/docs/services/563879b61984550e40cbbe8d/operations/563879b61984550f30395236
 https://westus.dev.cognitive.microsoft.com/docs/services/5adf991815e1060e6355ad44/operations/56f91f2e778daf14a499e1fa
 
 [HTTP Request] 라이브러리를 설치해야 함
 https://github.com/runemadsen/HTTP-Requests-for-Processing
 
 [PostRequest.java] 파일을 작업 폴더에 추가
 https://github.com/acdean/HTTP-Requests-for-Processing/blob/master/src/http/requests/PostRequest.java
 ****************************************************************/

/*** 자신의 MS API 키 입력***/
String apiKey = ""; //Face API 의 키 대신 Vision API  키력입

/*** 자신이 등록한 API 리소스의 위치 기입***/
//String api = "https://westus.api.cognitive.microsoft.com/face/v1.0/detect";  //Face API 리소스의 주소 
String api = "https://westus.api.cognitive.microsoft.com/vision/v2.0/analyze"; //CV API 리소스의 주소
                                                                               //필요하다면 리소스의 위치 수정

/*** API를 통해 요청할 정보 기입 (Face API)***/
/*
String returnFaceId = "?returnFaceId=true";
String returnFaceLandmarks = "&returnFaceLandmarks=false";
String returnFaceAttributes = "&returnFaceAttributes=age,gender,headPose,smile,facialHair,glasses,emotion,hair,makeup,accessories,blur,exposure,noise";
String url = api+returnFaceId+returnFaceLandmarks+returnFaceAttributes;
*/
/*** API를 통해 요청할 정보 기입 (CV API)***/
String visualFeatures = "?visualFeatures=Adult,Brands,Categories,Color,Description,Faces,ImageType,Objects,Tags";
String details = "&details=Celebrities,Landmarks";
String language = "&language=en";
String url = api + visualFeatures + details + language;

import http.requests.*;
