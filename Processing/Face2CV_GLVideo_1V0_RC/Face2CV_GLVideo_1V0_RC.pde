/*********** 카메라 관련 변수 ***********/
import gohai.glvideo.*;
GLCapture cam;
int camW = 320, camH = 240;

/*********** 작동 관련 ***********/
boolean getValue  = false;
boolean blink = false;

/*********** 이미지 관련 변수 ***********/
PImage sample;
String fileName;  //이피지 파일의 이름
String fileDir;   //이미지 파일의 경로
String file;      //이미지의 경로 + 이름

/*********** 서버의 응답 관련 변수 ***********/
String postResult;  //서버의 응답을 저장할 변수

/*********** 이미지 시각화 관련 변수 ***********/
PFont font;

void setup() {
  size(320, 240, P2D);
  println("AZURE Face::Detect");

  //서버에 전송할 파일을 특정하여 불러옴
  fileName = "sample.jpg";
  fileDir = sketchPath()+"/data/"; 
  file = fileDir+fileName; 
  sample = loadImage(file);

  //화면에 표시할 글꼴 설정
  font = createFont("Gulim", 15);
  textFont(font);

  //카메라 설정 
  String[] cameras = GLCapture.list();
  println("cameras:");
  printArray(cameras);
  if (0 < cameras.length) {
    String[] configs = GLCapture.configs(cameras[0]);
    println("Configs:");
    printArray(configs);
  }
  cam = new GLCapture(this);
  cam.start();
}
void draw() {
  //카메라 이미지를 화면에 표시함
  if (cam.available() == true) {
    cam.read();
  }
  image(cam, 0, 0, camW, camH);
  if (getValue ) {                //작동 시작하면
    saveCamImage(cam);           //카메라 이미지를 저장
    thread("postImage");         //서버의 주소(url)로 이미지를 전송하고 서버의 응답을 회수하는 작업을 Thread로 처리함
    getValue  = false;            //작동 정지
  }
  //서버가 응답을 했을 경우, 응답을 분석하여 화면에 시각화함
  if (postResult != null && postResult != "") {
    /*
    JSONArray JSONvalues = parseJSONArray(postResult);
     displayFaceDetectResults(JSONvalues);
     */

    //Vision API 는 JSON 객체를 반환하므로
    //좌변에 JSONObject 자료형 변수를 만들어 할당함 
    JSONObject JSONValue = parseJSONObject(postResult); 
    //한편, displayFaceDetectResults() 함수는 JSONArray를 매개변수로 받으므로 추가적인 수정이 필요함
    println(JSONValue);
    displayCVAnalyzeReqults(JSONValue);

    //postResult = ""; //if 조건문이 반복되지 않도록 변수의 값을 변경함
    blink = false;
  } 
  if (blink) {
    if (frameCount % 10 < 5) {
      fill(255, 0, 0);
    } else {
      fill(255);
    }
    noStroke();
    ellipse(10, 10, 10, 10);
  }
}

void mousePressed() {          //마우스를 누르면,
  getValue  = true;             //작동 시작
  blink = true;                //깜빡임 시작
  postResult = "";             //이전의 인식 결과 제거
}

void saveCamImage(PImage camImage) {
  PImage sample = camImage.get(); 
  sample.save(file);
}

void postImage() {
  // Azure가 정의한 규약에 따라 POST Request 구조화
  PostRequest post = new PostRequest(url);
  post.addHeader("Content-Type", "application/octet-stream");  //Request Header
  post.addHeader("Ocp-Apim-Subscription-Key", apiKey);         //Request Header
  post.addDataFromFile(file);                                  //Request Body
  post.send();                                                 //서버에 POST 방식으로 전송

  postResult = post.getContent();                       //서버의 응답 회수
  println(postResult);                                         //회수한 응답 출력
  //return postResult;                                           //응답 반환
}

//JSON 객체를 분석하여 데이터를 추출하고 시각화
void displayFaceRectangle(JSONObject jsonObject) {
  int y = jsonObject.getJSONObject("faceRectangle").getInt("top");
  int x = jsonObject.getJSONObject("faceRectangle").getInt("left");
  int w = jsonObject.getJSONObject("faceRectangle").getInt("width");
  int h = jsonObject.getJSONObject("faceRectangle").getInt("height");
  String gender = jsonObject.getJSONObject("faceAttributes").getString("gender");
  int age = jsonObject.getJSONObject("faceAttributes").getInt("age");

  stroke(0, 255, 0);
  strokeWeight(3);
  noFill();
  rect(x, y, w, h);
  fill(0, 255, 0);
  textSize(20);
  text(gender+"("+age+")", x, y-h/10);
}

//서버로 부터 회수한 JSON 배열의 각 객체를 displayFaceRectangle() 함수로 처리
void displayFaceDetectResults(JSONArray jsonArray) {
  for (int i=0; i<jsonArray.size(); i++) {
    JSONObject jsonObject = jsonArray.getJSONObject(i);
    displayFaceRectangle(jsonObject);
  }
}

void displayCVAnalyzeReqults(JSONObject jsonObject) {
  JSONObject description = jsonObject.getJSONObject("description");
  JSONArray tagsArray = description.getJSONArray("tags");
  //println(tagsArray); 
  /**** tagsArray를 tags로 변환 ****/
  String tags = "";
  for (int i = 0; i< tagsArray.size(); i++) {
    tags+=tagsArray.get(i);
    if (i < tagsArray.size() -1) {
      tags+=",";
    }
  }
  println(tags);
  JSONObject captions = description.getJSONArray("captions").getJSONObject(0);
  float confidence = captions.getFloat("confidence");
  String text = captions.getString("text");
  String caption = text + "[comfidence=" + confidence + "]";
  println(caption);
  fill(255);
  textSize(12);
  text(tags + "\n" + caption, 0, 20, width, height);
}
