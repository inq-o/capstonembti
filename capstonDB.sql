use capston;

# User 테이블 : 사용자 고유 ID, MBTI, 이름, 생년월일, 성별, 전화번호, 키, 몸무게 -- 키 몸무게 NULL 허용함
CREATE TABLE User ( 
	UserID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키 : 회원 추가될 때마다 자동 할당 됨
    ID VARCHAR(50) UNIQUE NOT NULL,
    PW VARCHAR(6) NOT NULL CHECK (PW REGEXP '^[0-9]{6}$'),
    UserMBTI ENUM('ESFP', 'ESFJ', 'ESTP', 'ESTJ', 'ENFP', 'ENFJ', 'ENTP', 'ENTJ', 
		'ISFP', 'ISFJ', 'ISTP', 'ISTJ', 'INFP', 'INFJ', 'INTP', 'INTJ'),  -- 16가지 중 하나
    Name VARCHAR(20) NOT NULL, 
    BirthDate DATE NOT NULL,
    Sex ENUM('남성', '여성') NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Height FLOAT NOT NULL,
    Weight FLOAT NOT NULL
);

# Video 테이블 : 영상 고유 ID, 영상 제목, 운동 카테고리, 영상 URL, 영상 길이
CREATE TABLE Video (
	VideoID INT AUTO_INCREMENT PRIMARY KEY, -- 기본키 : 영상 추가될 때마다 자동 할당 됨
    Title VARCHAR(200) NOT NULL, 
    Category ENUM('다이어트', '근력운동') NOT NULL,
    URL VARCHAR(300) NOT NULL, 
    Duration TIME NOT NULL -- 영상 길이(소요 시간)
);

# ViewHistory 테이블 : 시청 고유 ID, 사용자 ID, 영상 ID, 시청 날짜, 시청 시작 시간, 시청 종료 시간, 총 시청 시간
CREATE TABLE ViewHistory (
    ViewID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키 : 시청 기록 추가될 때마다 자동 할당 됨
    UserID INT NOT NULL, 
    VideoID INT NOT NULL,
    ViewDate DATE NOT NULL, -- 영상 시청 날짜
	StartTime TIMESTAMP NOT NULL, -- 영상 시청 시작 시간
    EndTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, -- 영상 시청 종료 시간 : 시청 기록 추가될 때마다 현재 시간 자동 저장
    DurationSeconds INT NOT NULL, -- 영상 시청 총 시간(초 단위)
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (VideoID) REFERENCES Video(VideoID)
);

# DurationSeconds 자동 계산(EndTime - StartTime 초) 트리거
DELIMITER $$
CREATE TRIGGER calculate_duration
BEFORE INSERT ON ViewHistory
FOR EACH ROW
BEGIN
    SET NEW.DurationSeconds = TIMESTAMPDIFF(SECOND, NEW.StartTime, NEW.EndTime);
END$$
DELIMITER ;

# ViewScore : User 고유 ID, 영상 고유 ID, User별 시청 점수
CREATE TABLE ViewScore (
    UserID INT NOT NULL,
    VideoID INT NOT NULL,
    WatchScore FLOAT NOT NULL,
    PRIMARY KEY (UserID, VideoID), -- 기본키 : UserID, VideoID
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (VideoID) REFERENCES Video(VideoID)
);

# ViewStatus 테이블 : MBTI, 영상 고유 ID, 군집별 시청 점수
CREATE INDEX idx_UserMBTI ON User(UserMBTI);
CREATE TABLE ViewStats (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    MBTI ENUM('ESFP', 'ESFJ', 'ESTP', 'ESTJ', 'ENFP', 'ENFJ', 'ENTP', 'ENTJ', 
        'ISFP', 'ISFJ', 'ISTP', 'ISTJ', 'INFP', 'INFJ', 'INTP', 'INTJ'),
    VideoID INT NOT NULL,
    ClusterWatchScore FLOAT NOT NULL,
    FOREIGN KEY (MBTI) REFERENCES User(UserMBTI),
    FOREIGN KEY (VideoID) REFERENCES Video(VideoID),
    UNIQUE (MBTI, VideoID) -- MBTI와 VideoID의 조합이 중복되지 않도록 UNIQUE 제약 조건 추가
);

#각 영상에 대해서 각 회원 개별 시청 점수 계산하는 프로시저
DELIMITER $$
CREATE PROCEDURE CalculateUserWatchScore(IN newUserID INT, IN newVideoID INT)
BEGIN
    -- 새로운 사용자의 시청 점수 계산
    INSERT INTO ViewScore (UserID, VideoID, WatchScore)
    SELECT newUserID, newVideoID, 
        DurationSeconds / TIME_TO_SEC((SELECT Duration FROM Video WHERE VideoID = newVideoID)) AS WatchScore
    FROM ViewHistory
    WHERE UserID = newUserID AND VideoID = newVideoID;
END$$
DELIMITER ;

#각 영상에 대해 같은 MBTI를 가진 회원의 개별 시청 점수를 합하고, ViewStatus 테이블의 ClusterWatchScore 값으로 저장하는 프로시저
DELIMITER $$
CREATE PROCEDURE CalculateClusterWatchScore(IN newVideoID INT)
BEGIN
    -- 해당 영상에 대한 MBTI별 시청 점수를 계산합니다.
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


#ViewHistory 테이블에 새로운 행이 삽입될 떄 프로시저 CalculateUserWatchScore, CalculateClusterWatchScore 자동 호출 트리거
DELIMITER $$
CREATE TRIGGER TriggerCalculateWatchScores
AFTER INSERT ON ViewHistory
FOR EACH ROW
BEGIN
    CALL CalculateUserWatchScore(NEW.UserID, NEW.VideoID);
    CALL CalculateClusterWatchScore(NEW.VideoID);
END$$
DELIMITER ;

# 식단 테이블 : 식단 고유 ID, 음식 이름, 타입(
CREATE TABLE Diet(
    Diet_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Diet_type ENUM('근력운동', '다이어트') NOT NULL
);

-- 데이터 삽입
INSERT INTO Video (Title, Category, URL, Duration) VALUES
('딱 10분입니다 보세요! 당신의 어깨가 바뀝니다! [데스런조성준]', '근력운동', 'https://www.youtube.com/watch?v=RxoBiAvR214', '00:09:45'),
('등근육 쫙쫙 갈라주는 등운동 방법 [데스런 조성준]', '근력운동', 'https://www.youtube.com/watch?v=Us-51fIYC2U', '00:07:36'),
('가슴운동 가자! [데스런 조성준]', '근력운동', 'https://www.youtube.com/watch?v=xSe8EJIgsUM', '00:02:12'),
('매일 해야하는 20분 기초 코어운동 - 속근육 강화, 균형감각 향상, 허리통증 완화 (Core workout)', '근력운동', 'https://www.youtube.com/watch?v=C7gPeAgeBAk', '00:22:50'),
('등, 가슴, 팔, 어깨 탄탄하게 만들기 - 덤벨 상체 운동 홈트 루틴', '근력운동', 'https://www.youtube.com/watch?v=xoWKLNwNva0', '00:20:45'),
('[ENG] (근육통주의!!!!) 🔥올인원🔥 전신 근력운동 50분 홈트레이닝', '근력운동', 'https://www.youtube.com/watch?v=A5MzlPgNcJM', '00:50:25'),
('하루 한 번! 꼭 해야하는 10분 기본 전신근력 운동 홈트 (층간소음🙅🏻‍♀️)', '근력운동', 'https://www.youtube.com/watch?v=aKzE3NNFEi4', '00:13:35'),
('[200만뷰] 허리근육을 튼튼하게 만들고 싶다면? /우리들병원TV', '근력운동', 'https://www.youtube.com/watch?v=FJ2DWFN5IsA', '00:15:02'),
('맨몸 전신운동 홈트레이닝 7가지! 초보자분들, 딱 4주만 따라해보세요! (설명+따라하기 영상)', '근력운동', 'https://www.youtube.com/watch?v=zSJYAyoojdw', '00:15:54'),
('[ENG] (층간소음X, 설명O) 복근운동과 유산소를 한번에❗️서서하는 복근운동 1탄🔥', '근력운동', 'https://www.youtube.com/watch?v=kETh8T3it4k', '00:18:37'),
('하체 날, 딱 10분 밖에 없다면 - 스쿼트 10가지 동작 - 하체운동 홈트 루틴', '근력운동', 'https://www.youtube.com/watch?v=DWYDL-WxF1U', '00:11:13'),
('아랫배, 옆구리, 허리라인을 매끈하고 탄탄하게 - 코어 힘도 길러주는 복근운동 10분 홈트 루틴', '근력운동', 'https://www.youtube.com/watch?v=vckr1GJ0JMs', '00:11:15'),
('기초체력 기르는 20분 전신 유산소 운동 (No 런지, No 스쿼트)', '다이어트', 'https://www.youtube.com/watch?v=OoytN1a8Klc', '00:20:42'),
('역대급 땀폭발 HIIT - 고강도 인터벌 트레이닝 35분 전신 올인원', '다이어트', 'https://www.youtube.com/watch?v=LG6CNzlj_6o', '00:35:37'),
('집에서 칼로리 불태우는 최고의 유산소운동 [칼소폭 매운맛]', '다이어트', 'https://www.youtube.com/watch?v=lKwZ2DU4P-A', '00:29:12'),
('스트레스 해소 운동 🥊 유산소운동 - 킥복싱 스타일 홈트', '다이어트', 'https://www.youtube.com/watch?v=BYDcbiHwlXU', '00:18:53'),
('홈트 처음할 때 이것부터하세요! 하루 15분 근력 유산소 전신운동 체지방 박살💣 층간소음NO 기구NO 식단&일지YES', '다이어트', 'https://www.youtube.com/watch?v=VbTlIVn8BX8', '00:18:40'),
('탄력있게 살빼기 30분 - 덤벨 전신 유산소 홈트', '다이어트', 'https://www.youtube.com/watch?v=vMiNEdUPvak', '00:30:38'),
('서서하는 초보 홈트 - 손목 무릎 부담없는 운동 - 유산소운동 홈트 - No 층간소음', '다이어트', 'https://www.youtube.com/watch?v=IXhppj6pwu4', '00:13:15'),
('※30분 걷기운동※ 집에서 3km 걸으면서 전신칼로리 불태우기!! (Walking workout)', '다이어트', 'https://www.youtube.com/watch?v=aGOvDH3UY2A', '00:30:49'),
('🔥 일주일에 -3kg가 그냥 빠지는🥵💦전신유산소의 시조새 줄넘기 운동을 이렇게 신나게 집에서 할 수 있다니!!!', '다이어트', 'https://www.youtube.com/watch?v=MUMRltg5n6Y', '00:16:35'),
('🚨급찐늦빠🚨들을 위한 전신유산소 운동 | 쉬운 다이어트댄스를 찾는다면 바로 클릭! 👉', '다이어트', 'https://www.youtube.com/watch?v=75IWhFihA6c', '00:10:42');

INSERT INTO Diet (Name, Diet_type) VALUES
('장어구이', '근력운동'),
('장어덮밥','근력운동'),
('닭가슴살 스테이크', '근력운동'),
('소고기구이', '근력운동'),
('브로콜리 참치 무침', '근력운동'),
('연어 그라브락스','근력운동'),
('연어 빠삐요뜨','근력운동'),
('치미추리 스테이크','근력운동'),
('닭가슴살 또띠아롤','근력운동'),
('오리 스테이크','근력운동'),
('사과샐러드', '다이어트'),
('고구마 칩', '다이어트'),
('고등어구이', '다이어트'),
('그릭요거트', '다이어트'),
('바나나 크림 수프','다이어트'),
('슈퍼 곡물 스무디볼','다이어트'),
('에그누들 볶음','다이어트'),
('달걀 양배추 부침개','다이어트'),
('단호박 달걀찜','다이어트'),
('아보카도 쉬림프 라이스','다이어트');

SELECT * FROM Video;
SELECT * FROM Diet;

SELECT * FROM User;
SELECT * FROM ViewHistory;
SELECT * FROM ViewScore;
SELECT * FROM ViewStats;