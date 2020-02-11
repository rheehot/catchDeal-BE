# 캐치야, 물어와! : 특가정보 모음집 '캐치딜'
<div align="center"><img src="/public/img/app_example.png?raw=true" width="500px"></div>

## 팀원
#### 서현석, 김철민, 이인하

## 1. 루비/루비온 레일즈 정보
* Ruby : 2.6.3
* Rails : 5.2.3
 

## 2. 해당 Repository와의 연결고리
* 안드로이드 Repository : https://github.com/samslow/popStarMomi-FE-V2
* 크롤링 - AWS Lamabda(Ruby on Jets) : https://github.com/kbs4674/lambda-catchDeal


## 3. 캐치딜 개발 이야기
1. [(Intro) 싼 것만 물어드려요 : 캐치딜 서비스!]
2. [캐치딜 백엔드 개발이야기 : 좌충우돌 서버운영 이야기]
3. [캐치딜 백엔드 개발이야기 : 문서화]
4. [캐치딜 백엔드 개발이야기 : 디자이너와의 협업]
5. [캐치딜 백엔드 개발이야기 : 크롤링]
6. [캐치딜 백엔드 개발이야기 : Restful API 설계의 다양한 고민]

[(Intro) 싼 것만 물어드려요 : 캐치딜 서비스!]: https://kbs4674.tistory.com/113
[캐치딜 백엔드 개발이야기 : 좌충우돌 서버운영 이야기]: https://kbs4674.tistory.com/114
[캐치딜 백엔드 개발이야기 : 문서화]: https://kbs4674.tistory.com/115
[캐치딜 백엔드 개발이야기 : 디자이너와의 협업]: https://kbs4674.tistory.com/116
[캐치딜 백엔드 개발이야기 : 크롤링]: https://kbs4674.tistory.com/117
[캐치딜 백엔드 개발이야기 : Restful API 설계의 다양한 고민]: https://kbs4674.tistory.com/118


## 4. 캐치딜 : 전체적인 프로젝트 개요
1. 커뮤니티에는 매일 갖가지 할인행사에 대한 정보를 사람들이 올리면서 공유한다.
2. 그런데 커뮤니티 한 곳이 아닌 여러곳에 정보가 퍼져있다.
3. 그렇다보니 똑같은 정보에 대해 A, C 커뮤니티에는 정보가 있지만, 정작 B 커뮤니티에는 없는 경우가 있다.
4. 해당 프로젝트의 역할은 각 커뮤니티에서 특가 정보를 크롤링 후, 앱(apk)과의 통신을 위해 JSON 형식으로 웹페이지에 결과물을 띄우는 것을 담당한다.
5. 크롤링에 대해선 매 시간 단위로 CronJob을 활용하여 Background Job을 통해 크롤링이 진행된다.


## 5. 해당 Repository 내 Rails 프로젝트의 역할
1. 해당 프로젝트의 웹사이트 상에는 모든 데이터 결과를 json으로 처리한다.
2. 앱과의 통신 때 있어 json 방식으로 데이터 통신이 이루어지게 한다.
    * 결국 모든 데이터 자료는 앱이 아닌 해당 프로젝트로 구축된 사이트가 관리하게 된다.


## 6. 프로젝트 작동 Process
1. 앱 ↔ 웹 기본 통신
<img src="/public/img/process_connect.png" width="100%">
<br/><br/>

2. 새로운 JWT 토큰 생성
<img src="/public/img/process_new_token.png" width="100%">
<br/><br/>

3. JWT 토큰 검증 및 작업
<img src="/public/img/process_validate_jwt.png" width="100%">


## 7. 핵심 코드파일
1. ```app/controllers/application_controller.rb``` [[applicationController]] Header를 통해 요청받은 JWT 토큰에 대해 유효 검증을 합니다.
2. ```lib/json_web_token.rb``` [[jwtDecode]] JWT 토큰을 Decode화 합니다.
3. ```app/controllers/authentication_controller.rb``` [[jwtEncode]] Body Params로 넘어온 데이터를 참조하여 JWT 토큰을 생성합니다.
4. ```app/controllers/apis_controller.rb``` [[apiController]] API 통신에 있어 JWT 토큰을 기반으로 유저 구분 및 유저에 따라 데이터를 처리 및 Response를 합니다.
5. ```app/controllers/hit_products_controller.rb``` [[hitProductController]] API 통신에 있어 핫딜 상품 조회, 검색, 1주간 Top 100 순위 상품 조회를 합니다. 
 
[applicationController]: /app/controllers/application_controller.rb
[jwtDecode]: /lib/json_web_token.rb
[jwtEncode]: /app/controllers/authentication_controller.rb
[apiController]: /app/controllers/apis_controller.rb
[hitProductController]: /app/controllers/hit_products_controller.rb


## 8. M : 모델 설명
* HitProduct : 특가 정보에 대한 데이터를 담아놓는다.
* Notice : 공지사항에 대한 데이터를 담아놓는다.

https://kbs4674.tistory.com/114
캐치딜 백엔드 개발이야기 : 좌충우돌 서버운영 이야기
