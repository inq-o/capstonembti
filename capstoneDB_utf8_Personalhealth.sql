use capstone; 

-- 테이블 생성

CREATE TABLE User ( 
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    ID VARCHAR(50) UNIQUE NOT NULL,
    PW VARCHAR(6) NOT NULL CHECK (PW REGEXP '^[0-9]{6}$'),
    UserMBTI ENUM('ESFP', 'ESFJ', 'ESTP', 'ESTJ', 'ENFP', 'ENFJ', 'ENTP', 'ENTJ', 
        'ISFP', 'ISFJ', 'ISTP', 'ISTJ', 'INFP', 'INFJ', 'INTP', 'INTJ'),  
    Name VARCHAR(20) NOT NULL, 
    BirthDate VARCHAR(10) NOT NULL,
    Sex ENUM('남성', '여성') NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Height VARCHAR(5),
    Weight VARCHAR(5)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE Video (
    VideoID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
    Category ENUM('다이어트', '근력운동') NOT NULL,
    URL VARCHAR(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, 
    Duration TIME NOT NULL,
    Slides VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    Publishers VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE ViewHistory (
    ViewID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL, 
    VideoID INT NOT NULL,
    ViewDate DATE NOT NULL, 
    StartTime TIMESTAMP NOT NULL, 
    EndTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    DurationSeconds INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (VideoID) REFERENCES Video(VideoID)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

DELIMITER $$
CREATE TRIGGER calculate_duration
BEFORE INSERT ON ViewHistory
FOR EACH ROW
BEGIN
    SET NEW.DurationSeconds = TIMESTAMPDIFF(SECOND, NEW.StartTime, NEW.EndTime);
END$$
DELIMITER ;

CREATE TABLE ViewScore (
    UserID INT NOT NULL,
    VideoID INT NOT NULL,
    WatchScore FLOAT NOT NULL,
    PRIMARY KEY (UserID, VideoID), 
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (VideoID) REFERENCES Video(VideoID)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE INDEX idx_UserMBTI ON User(UserMBTI);

CREATE TABLE ViewStats (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    MBTI ENUM('ESFP', 'ESFJ', 'ESTP', 'ESTJ', 'ENFP', 'ENFJ', 'ENTP', 'ENTJ', 
        'ISFP', 'ISFJ', 'ISTP', 'ISTJ', 'INFP', 'INFJ', 'INTP', 'INTJ'),
    VideoID INT NOT NULL,
    ClusterWatchScore FLOAT NOT NULL,
    FOREIGN KEY (MBTI) REFERENCES User(UserMBTI),
    FOREIGN KEY (VideoID) REFERENCES Video(VideoID),
    UNIQUE (MBTI, VideoID)
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

DELIMITER $$
CREATE PROCEDURE CalculateUserWatchScore(IN newUserID INT, IN newVideoID INT)
BEGIN
    INSERT INTO ViewScore (UserID, VideoID, WatchScore)
    SELECT newUserID, newVideoID, 
        DurationSeconds / TIME_TO_SEC((SELECT Duration FROM Video WHERE VideoID = newVideoID)) AS WatchScore
    FROM ViewHistory
    WHERE UserID = newUserID AND VideoID = newVideoID;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE CalculateClusterWatchScore(IN newVideoID INT)
BEGIN
    INSERT INTO ViewStats (MBTI, VideoID, ClusterWatchScore)
    SELECT U.UserMBTI, VH.VideoID,
        SUM(VS.WatchScore) AS ClusterWatchScore
    FROM User U
    JOIN ViewHistory VH ON U.UserID = VH.UserID
    JOIN ViewScore VS ON VH.UserID = VS.UserID AND VH.VideoID = VS.VideoID
    WHERE VH.VideoID = newVideoID
    GROUP BY U.UserMBTI, VH.VideoID
    ON DUPLICATE KEY UPDATE ClusterWatchScore = VALUES(ClusterWatchScore);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER TriggerCalculateWatchScores
AFTER INSERT ON ViewHistory
FOR EACH ROW
BEGIN
    CALL CalculateUserWatchScore(NEW.UserID, NEW.VideoID);
    CALL CalculateClusterWatchScore(NEW.VideoID);
END$$
DELIMITER ;

CREATE TABLE Diet(
    Diet_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Diet_type ENUM('근력운동', '다이어트') NOT NULL,
    img VARCHAR(255) NOT NULL,
    comment TEXT
    
) DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;


-- 데이터 삽입

INSERT INTO Video (Title, Category, URL, Duration, Slides, Publishers) VALUES
('딱 10분입니다 보세요! 당신의 어깨가 바뀝니다! [데스런조성준]', '근력운동', 'https://www.youtube.com/watch?v=RxoBiAvR214', '00:09:45', 'https://img.youtube.com/vi/RxoBiAvR214/0.jpg', '데스런조성준'),
('등근육 쫙쫙 갈라주는 등운동 방법 [데스런 조성준]', '근력운동', 'https://www.youtube.com/watch?v=Us-51fIYC2U', '00:07:36', 'https://img.youtube.com/vi/Us-51fIYC2U/0.jpg', '데스런조성준'),
('가슴운동 가자! [데스런 조성준]', '근력운동', 'https://www.youtube.com/watch?v=xSe8EJIgsUM', '00:02:12', 'https://img.youtube.com/vi/xSe8EJIgsUM/0.jpg', '데스런조성준'),
('매일 해야하는 20분 기초 코어운동 - 속근육 강화, 균형감각 향상, 허리통증 완화 (Core workout)', '근력운동', 'https://www.youtube.com/watch?v=C7gPeAgeBAk', '00:22:50', 'https://img.youtube.com/vi/C7gPeAgeBAk/0.jpg', '빵느'),
('등, 가슴, 팔, 어깨 탄탄하게 만들기 - 덤벨 상체 운동 홈트 루틴', '근력운동', 'https://www.youtube.com/watch?v=xoWKLNwNva0', '00:20:45', 'https://img.youtube.com/vi/xoWKLNwNva0/0.jpg', '빅씨스'),
('[ENG] (근육통주의!!!!) 🔥올인원🔥 전신 근력운동 50분 홈트레이닝', '근력운동', 'https://www.youtube.com/watch?v=A5MzlPgNcJM', '00:50:25', 'https://img.youtube.com/vi/A5MzlPgNcJM/0.jpg', '힙으뜸'),
('하루 한 번! 꼭 해야하는 10분 기본 전신근력 운동 홈트 (층간소음🙅🏻‍♀️)', '근력운동', 'https://www.youtube.com/watch?v=aKzE3NNFEi4', '00:13:35', 'https://img.youtube.com/vi/aKzE3NNFEi4/0.jpg', '빵느'),
('[200만뷰] 허리근육을 튼튼하게 만들고 싶다면? /우리들병원TV', '근력운동', 'https://www.youtube.com/watch?v=FJ2DWFN5IsA', '00:15:02', 'https://img.youtube.com/vi/FJ2DWFN5IsA/0.jpg', '우리들병원TV'),
('맨몸 전신운동 홈트레이닝 7가지! 초보자분들, 딱 4주만 따라해보세요! (설명+따라하기 영상)', '근력운동', 'https://www.youtube.com/watch?v=zSJYAyoojdw', '00:15:54', 'https://img.youtube.com/vi/zSJYAyoojdw/0.jpg', '바벨라토르 홈트레이닝'),
('[ENG] (층간소음X, 설명O) 복근운동과 유산소를 한번에❗️서서하는 복근운동 1탄🔥', '근력운동', 'https://www.youtube.com/watch?v=kETh8T3it4k', '00:18:37', 'https://img.youtube.com/vi/kETh8T3it4k/0.jpg', '힙으뜸'),
('하체 날, 딱 10분 밖에 없다면 - 스쿼트 10가지 동작 - 하체운동 홈트 루틴', '근력운동', 'https://www.youtube.com/watch?v=DWYDL-WxF1U', '00:11:13', 'https://img.youtube.com/vi/DWYDL-WxF1U/0.jpg', '빅씨스'),
('아랫배, 옆구리, 허리라인을 매끈하고 탄탄하게 - 코어 힘도 길러주는 복근운동 10분 홈트 루틴', '근력운동', 'https://www.youtube.com/watch?v=vckr1GJ0JMs', '00:11:15', 'https://img.youtube.com/vi/vckr1GJ0JMs/0.jpg', '빅씨스'),
('기초체력 기르는 20분 전신 유산소 운동 (No 런지, No 스쿼트)', '다이어트', 'https://www.youtube.com/watch?v=OoytN1a8Klc', '00:20:42', 'https://img.youtube.com/vi/OoytN1a8Klc/0.jpg', '빵느'),
('역대급 땀폭발 HIIT - 고강도 인터벌 트레이닝 35분 전신 올인원', '다이어트', 'https://www.youtube.com/watch?v=LG6CNzlj_6o', '00:35:37', 'https://img.youtube.com/vi/LG6CNzlj_6o/0.jpg', '빅씨스'),
('집에서 칼로리 불태우는 최고의 유산소운동 [칼소폭 매운맛]', '다이어트', 'https://www.youtube.com/watch?v=lKwZ2DU4P-A', '00:29:12', 'https://img.youtube.com/vi/lKwZ2DU4P-A/0.jpg', 'Thankyou BUBU'),
('스트레스 해소 운동 🥊 유산소운동 - 킥복싱 스타일 홈트', '다이어트', 'https://www.youtube.com/watch?v=BYDcbiHwlXU', '00:18:53', 'https://img.youtube.com/vi/BYDcbiHwlXU/0.jpg', '빅씨스'),
('홈트 처음할 때 이것부터하세요! 하루 15분 근력 유산소 전신운동 체지방 박살💣 층간소음NO 기구NO 식단&일지YES', '다이어트', 'https://www.youtube.com/watch?v=VbTlIVn8BX8', '00:18:40', 'https://img.youtube.com/vi/VbTlIVn8BX8/0.jpg', '바벨라토르 홈트레이닝'),
('탄력있게 살빼기 30분 - 덤벨 전신 유산소 홈트', '다이어트', 'https://www.youtube.com/watch?v=vMiNEdUPvak', '00:30:38', 'https://img.youtube.com/vi/vMiNEdUPvak/0.jpg', '빅씨스'),
('서서하는 초보 홈트 - 손목 무릎 부담없는 운동 - 유산소운동 홈트 - No 층간소음', '다이어트', 'https://www.youtube.com/watch?v=IXhppj6pwu4', '00:13:15', 'https://img.youtube.com/vi/IXhppj6pwu4/0.jpg', '빅씨스'),
('※30분 걷기운동※ 집에서 3km 걸으면서 전신칼로리 불태우기!! (Walking workout)', '다이어트', 'https://www.youtube.com/watch?v=aGOvDH3UY2A', '00:30:49', 'https://img.youtube.com/vi/aGOvDH3UY2A/0.jpg', '빵느'),
('🔥 일주일에 -3kg가 그냥 빠지는🥵💦전신유산소의 시조새 줄넘기 운동을 이렇게 신나게 집에서 할 수 있다니!!!', '다이어트', 'https://www.youtube.com/watch?v=MUMRltg5n6Y', '00:16:35', 'https://img.youtube.com/vi/MUMRltg5n6Y/0.jpg', '에이핏 afit'),
('🚨급찐늦빠🚨들을 위한 전신유산소 운동 | 쉬운 다이어트댄스를 찾는다면 바로 클릭! 👉', '다이어트', 'https://www.youtube.com/watch?v=75IWhFihA6c', '00:10:42', 'https://img.youtube.com/vi/75IWhFihA6c/0.jpg', '텐미닛X');


INSERT INTO Diet (Name, Diet_type, img, comment) VALUES
('두부 샐러드', '다이어트', 'https://59.18.172.95/www/foodimg/두부샐러드.png', '두부에는 레시틴이라는 성분을 풍부하게 함유되어 있습니다. 이 레시틴이라는 성분은 체내에 쌓여있는 체지방을 녹여 밖으로 배출해주는 효과를 줍니다. 또한 두부의 올리고당은 다이어트에 최악인 변비를 해소시켜주고! 이소플라본이라는 성분은 식물성 여성호르몬과 같은작용을 하여 피부와 몸매를 아름답게 가꿔줍니다.'),
('장어덮밥', '근력운동', 'https://59.18.172.95/www/foodimg/장어덮밥.png', '여름 보양식으로는 장어가 제격이다. 장어 올린 한 그릇 요리로 여름 건강을 든든하게 챙기시는 건 어떠신가요?? 비린맛은 잡고, 감칠맛나는 간장 양념옷을 입은 장어를 푸짐하게 올려 완성한 장어덮밥이에요!!'),
('닭가슴살 스테이크', '근력운동', 'https://59.18.172.95/www/foodimg/닭가슴살스테이크.png', '단백질과 불포화 지방산이 풍부한 닭고기를 더욱 맛있고 색다르게 먹을 수 있답니다'),
('불고기 달걀 덮밥', '근력운동', 'https://59.18.172.95/www/foodimg/불고기달걀덮밥.png', '집에 있는 소불고기로 쉽고 빠르게 먹을 수 있는 건강 식단 입니다. 특히 소고기와 달걀에는 단백질이 많이 들어 있어서 근력 운동 하시는 분께 도움이 될 것 같습니다.'),
('참치 아보카도 샐러드', '다이어트', 'https://59.18.172.95/www/foodimg/참치아보카도샐러드.png', '아보카도는 각종 비타민과 미네랄이 풍부한 식품으로 일반 과일과는 다르게 단백질과 불포화지방산을 함유하고 있으며, 식이섬유도 풍부해 다이어트에 효과적이랍니다. 참치를 넣어 색다른 맛을 내는 오늘의 특별한 샐러드를 드셔보길 추천드립니다.'),
('고구마 단호박 샐러드', '다이어트', 'https://59.18.172.95/www/foodimg/고구마단호박샐러드.png', '고구마와 단호박은 식이섬유가 풍부하고 저칼로리 식품이라 다이어트는 물론 피부 미용에도 좋은데요. 찜통에 찌거나 구워서 그대로 먹어도 좋지만 맛을 더욱 풍부하게 해주는 드레싱을 곁들이면 훨씬 달콤하게 즐길 수 있습니다. 오늘은 고소한 견과류를 곁들인 특별한 샐러드 어떠세요??'),
('오버나이트 오트밀', '근력운동', 'https://59.18.172.95/www/foodimg/오버나이트오트밀.png', '바쁜 아침, 든든한 한 끼로 먹기 좋은 오버나이트 오트밀을 소개할게요. 오버나이트 오트밀은 압착 귀리(오트밀)에 우유 또는 요거트를 부어 냉장고에서 하룻밤 동안 넣어둔 후, 다음날 아침식사로 부드럽게 즐기는 방법을 말해요. 세계 10대 슈퍼 푸드로 선정되기도 한 귀리는 식이섬유와 단백질이 풍부한 건강한 재료입니다. 치아씨드와 견과류, 과일 등을 곁들여 맛잇게 즐겨보시길 바랍니다.'),
('두부면 샐러드', '다이어트', 'https://59.18.172.95/www/foodimg/두부면샐러드.png', '탄수화물과 글루텐 걱정이 없는 식물성 고단백 두부면! 두부 면으로 샐러드를 만들었어요. 두부 면을 활용하여 파스타, 비빔면도 만들 수 있고 다른 재료와 함께 김밥처럼 돌돌 말아먹어도 좋습니다. 건강하게 한 끼를 챙기고 싶다면 두부면 샐러드를 추천해요. 씹을수록 고소하고 부드러운 식감이 매력적이어서 밀가루 면을 대체할 수 있을 것 같아요. 그동안 맛없는 건강식에 지치셨다면 건강하고 정말 맛있는 두부면 샐러드를 맛있게 즐겨보세요!'),
('토마토 팍시', '근력운동', 'https://59.18.172.95/www/foodimg/토마토팍시.png', '보기에도 예쁘고 따듯한 맛이 느껴지는 토마토 팍시(Tomates farcie) 팍시는 프랑스어로 ‘다진 고기나 채소로 속을 채운’ 이란 뜻이에요. 토마토 팍시는 토마토 속을 파내어 쇠고기와 양파 등을 볶아 채워 넣고, 치즈를 올려 오븐에 구워 만드는 프랑스 가정식입니다. 에피타이저로도 좋고 맛있는 다이어트로 즐길 수 있는 토마토 팍시, 꼭 한 번 만들어 보시길 추천 드립니다.'),
('레드키위 요거트 바크', '다이어트', 'https://59.18.172.95/www/foodimg/레드키위요거트바크.png', '그릭요거트에 각종 재료를 더해 얼린 요거트 바크! 아이스크림처럼 시원하고 달콤하면서도 칼로리는 훨씬 낮아 수많은 다이어터들이 사랑하는 디저트이기도 하죠. 과정이 아주 간단해 각자의 방식대로 재료를 조합해 먹기도 하는데요. 붉은 과육을 가진 레드키위는 일반 키위보다 훨씬 달콤한 맛이 나는 게 특징인데요. 그릭요거트에 레드키위와 블루베리, 피스타치오를 더한 후 얼려만 주면 시원하고 달콤한 요거트 바크가 완성된답니다!'),
('키토 김밥', '다이어트', 'https://59.18.172.95/www/foodimg/키토김밥.png', '탄수화물을 낮추고 좋은 지방과 단백질을 섭취하는 ‘저탄고지’ 식단이 많은 인기예요! 오늘 소개해 드리는 키토 김밥은 소고기와 달걀에 신선한 채소를 곁들여 만든 저탄고지 김밥이랍니다. 제한적이고 단조로운 식단의 다이어트에 고통받으셨다면 키토 김밥과 함께 맛있고 건강한 다이어트 시작해 보세요. 소 등심, 닭가슴살, 크래미, 참치, 두부 등 재료에 따라 여러 가지 조합이 탄생할 수 있어 질리지 않고 자주 만들어 먹을 수 있어요.');

SELECT * FROM Video;
SELECT * FROM Diet;

SELECT * FROM User;
SELECT * FROM ViewHistory;
SELECT * FROM ViewScore;
SELECT * FROM ViewStats;

