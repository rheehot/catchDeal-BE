# 특가만 모았다, 팝스타 모미! (popStarMomi-BE-V2)
<div align="center"><img src="/public/img/app_example.png?raw=true" width="200px"></div>

## 팀원
#### 서현석, 김철민

## 1. 루비/루비온 레일즈 정보
* Ruby : 2.6.3
* Rails : 5.2.3
 

## 2. 해당 Repository와의 연결고리
안드로이드 Repository : https://github.com/samslow/popStarMomi-FE-V2


## 3. 프로젝트 개요
1. 커뮤니티에는 매일 갖가지 할인행사에 대한 정보를 사람들이 올리면서 공유한다.
2. 그런데 커뮤니티 한 곳이 아닌 여러곳에 정보가 퍼져있다.
3. 그렇다보니 똑같은 정보에 대해 A, C 커뮤니티에는 정보가 있지만, 정작 B 커뮤니티에는 없는 경우가 있다.
4. 해당 프로젝트의 역할은 각 커뮤니티에서 특가 정보를 크롤링 후, 앱(apk)과의 통신을 위해 JSON 형식으로 웹페이지에 결과물을 띄우는 것을 담당한다.
5. 크롤링에 대해선 매 시간 단위로 CronJob을 활용하여 Background Job을 통해 크롤링이 진행된다.


## 4. 핵심 코드파일
1. ```lib/tasks/hit_news_clien.rake``` [[hitNewsClienRake]]  클리앙 사이트 크롤링 트리거 (Background Job + CronJob)
2. ```lib/tasks/hit_news_ppom.rake``` [[hitNewsPpomRake]] 뿜뿌 사이트 크롤링 트리거 (Background Job + CronJob)
3. ```lib/tasks/auto_delete.rake``` [[autoDelete]] 게시글 삭제 트리거 (Background Job + CronJob)
4. ```app/controllers/hit_products_controller.rb``` [[hitProductController]] hit_products Controller (모델을 조작 및 Output에 대해 Json 형식으로 Convert)
5. ```app/jobs/crawl_clien_job.rb``` [[crawlClienJob]] 클리앙 사이트 내 특가 소식에 대해 크롤링 (Background Job + Enque Background)
6. ```app/jobs/crawl_auto_delete_job.rb``` [[crawlautoDeleteJob]] 크롤링이 이루어진지 2일이 넘은 글에 대해선 자동으로 삭제 처리 (Background Job + Enque Background)


## 5. M : 모델 설명
* HitProduct : 특가 정보에 대한 데이터를 담아놓는다.


[hitNewsClienRake]: /lib/tasks/hit_news_clien.rake
[hitNewsPpomRake]: /lib/tasks/hit_news_ppom.rake
[autoDelete]: /lib/tasks/auto_delete.rake
[hitProductController]: /app/controllers/hit_products_controller.rb
[crawlClienJob]: /app/jobs/crawl_clien_job.rb
[crawlautoDeleteJob]: /app/jobs/crawl_auto_delete_job.rb