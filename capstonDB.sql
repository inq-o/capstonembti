use capston;

# User 테이블 : 사용자 고유 ID, MBTI, 이름, 생년월일, 성별, 전화번호, 키, 몸무게 -- 키 몸무게 NULL 허용함
CREATE TABLE User ( 
	UserID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키 : 회원 추가될 때마다 자동 할당 됨
    UserMBTI ENUM('ESFP', 'ESFJ', 'ESTP', 'ESTJ', 'ENFP', 'ENFJ', 'ENTP', 'ENTJ', 
		'ISFP', 'ISFJ', 'ISTP', 'ISTJ', 'INFP', 'INFJ', 'INTP', 'INTJ'),  -- 16가지 중 하나
    Name VARCHAR(20) NOT NULL, 
    BirthDate DATE NOT NULL,
    Sex ENUM('남성', '여성') NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Height FLOAT,
    Weight FLOAT
);

# Video 테이블 : 영상 고유 ID, 영상 제목, 운동 카테고리, 영상 URL, 영상 길이
CREATE TABLE Video (
	VideoID INT AUTO_INCREMENT PRIMARY KEY, -- 기본키 : 영상 추가될 때마다 자동 할당 됨
    Title VARCHAR(200) NOT NULL, 
    Category ENUM('다이어트', '근력 운동', '스트레칭') NOT NULL,
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
CREATE TABLE ViewStatus (
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
    INSERT INTO ViewStatus (MBTI, VideoID, ClusterWatchScore)
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


#테스트 데이터 >> 추후 삭제하고 실제 데이터 INSERT
-- 사용자(User) 테이블에 예시 데이터 삽입
INSERT INTO User (UserMBTI, Name, BirthDate, Sex, PhoneNumber, Height, Weight) 
VALUES 
('ENFP', 'Alice', '1990-05-15', '여성', '010-1234-5678', 165, 55),
('ISTJ', 'Bob', '1985-10-20', '남성', '010-9876-5432', 175, 70),
('ENFP', 'Charlie', '1992-03-25', '남성', '010-1111-2222', 170, 60),
('ISFP', 'ABC', '2001-03-05', '여성', '010-2222-1111', 159, 47),
('ENTP', 'Joe', '2004-12-21', '남성', '010-9999-8888', 190, 90) ;

-- 영상(Video) 테이블에 예시 데이터 삽입
INSERT INTO Video (Title, Category, URL, Duration) 
VALUES 
('다이어트영상1', '다이어트', 'https://example.com/dietone', '01:30:00'),
('근력 운동 영상 1', '근력 운동', 'https://example.com/strengthone', '00:45:00'),
('스트레칭 영상 1', '스트레칭', 'https://example.com/stretchingone', '00:20:00'),
('다이어트영상2', '다이어트', 'https://example.com/diettwo', '00:59:32'),
('근력 운동 영상 2', '근력 운동', 'https://example.com/strengthtwo', '00:55:45'),
('스트레칭 영상 2', '스트레칭', 'https://example.com/stretchingtwo', '02:01:09');

-- 시청 기록(ViewHistory) 테이블에 예시 데이터 삽입
INSERT INTO ViewHistory (UserID, VideoID, ViewDate, StartTime, EndTime) 
VALUES 
(1, 1, '2024-05-21', '2024-05-21 08:00:00', '2024-05-21 09:30:00'),
(1, 2, '2024-05-21', '2024-05-21 09:45:00', '2024-05-21 10:30:00'),
(1, 3, '2024-05-21', '2024-05-21 11:00:00', '2024-05-21 12:15:00'),
(2, 2, '2024-05-21', '2024-05-21 10:00:00', '2024-05-21 10:45:00'),
(2, 4, '2024-05-21', '2024-05-21 11:50:00', '2024-05-21 12:45:00'),
(2, 6, '2024-05-21', '2024-05-21 13:00:00', '2024-05-21 14:30:00'),
(3, 1, '2024-05-21', '2024-05-21 12:30:00', '2024-05-21 14:00:00'),
(3, 3, '2024-05-21', '2024-05-21 14:30:00', '2024-05-21 15:20:00'),
(4, 4, '2024-05-21', '2024-05-21 15:00:00', '2024-05-21 16:00:00'),
(4, 5, '2024-05-21', '2024-05-21 16:30:00', '2024-05-21 17:45:00'),
(5, 2, '2024-05-21', '2024-05-21 18:00:00', '2024-05-21 19:00:00'),
(1, 6, '2024-05-21', '2024-05-21 19:30:00', '2024-05-21 20:15:00'),
(5, 4, '2024-05-21', '2024-05-21 20:30:00', '2024-05-21 21:30:00'),
(5, 5, '2024-05-21', '2024-05-21 22:00:00', '2024-05-21 23:15:00');

SELECT * FROM User;
SELECT * FROM Video;
SELECT * FROM ViewHistory;
SELECT * FROM ViewScore;
SELECT * FROM ViewStatus;