# 캐치야, 물어와! : 특가정보 모음집 '캐치딜'
<div align="center"><img src="/public/img/app_example.png?raw=true" width="500px"></div>

## 팀원
#### 서현석, 김철민, 이인하

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

## 4. 해당 프로젝트의 역할
1. 해당 프로젝트의 웹사이트 상에는 모든 데이터 결과를 json으로 처리한다.
2. 앱과의 통신 때 있어 json 방식으로 데이터 통신이 이루어지게 한다.
    * 결국 모든 데이터 자료는 앱이 아닌 해당 프로젝트로 구축된 사이트가 관리하게 된다.


## 5. 핵심 코드파일
1. ```lib/tasks/hit_news_clien.rake``` [[hitNewsClienRake]]  클리앙 사이트 크롤링 트리거 (Background Job + CronJob)
2.  ```lib/tasks/hit_news_ruliweb.rake``` [[hitNewsRuliwebRake]]  루리웹 사이트 크롤링 트리거 (Background Job + CronJob)
3. ```lib/tasks/hit_news_ppom.rake``` [[hitNewsPpomRake]] 뿜뿌 사이트 크롤링 트리거 (Background Job + CronJob)
4. ```lib/tasks/hit_news_deal_bada.rake``` [[hitNewsDealBadaRake]] 딜바다 사이트 크롤링 트리거 (Background Job + CronJob)
5. ```lib/tasks/auto_delete.rake``` [[autoDelete]] 게시글 삭제 트리거 (Background Job + CronJob)
6. ```lib/tasks/alive_check.rake``` [[aliveCheck]] 원본 게시글이 삭제되었는지 체크 (Background Job + Enque Background)


## 6. M : 모델 설명
* HitProduct : 특가 정보에 대한 데이터를 담아놓는다.
* Notice : 공지사항에 대한 데이터를 담아놓는다.


[hitNewsClienRake]: /lib/tasks/hit_news_clien.rake
[hitNewsRuliwebRake]: /lib/tasks/hit_news_ruliweb.rake
[hitNewsPpomRake]: /lib/tasks/hit_news_ppom.rake
[hitNewsDealBadaRake]: /lib/tasks/hit_news_deal_bada.rake
[autoDelete]: /lib/tasks/auto_delete.rake
[aliveCheck]: /lib/tasks/alive_check.rake
[hitProductController]: /app/controllers/hit_products_controller.rb
[crawlClienJob]: /app/jobs/crawl_clien_job.rb
[crawlautoDeleteJob]: /app/jobs/crawl_auto_delete_job.rb