USE capston;
#회원 테이블 생성
CREATE TABLE MemberInfo (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키
    ID VARCHAR(15) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    MemberName VARCHAR(15) NOT NULL,
    Birthdate DATE NOT NULL,
    Age INT,
    Gender ENUM('남성', '여성'), 
    Nickname VARCHAR(15)
);

-- 닉네임이 Null이면 실명(MemberName)을 저장하도록 하는 트리거
DELIMITER $$
CREATE TRIGGER before_insert_memberinfo
BEFORE INSERT ON MemberInfo
FOR EACH ROW
BEGIN
    IF NEW.Nickname IS NULL THEN
        SET NEW.Nickname = NEW.MemberName;
    END IF;
END;
$$
DELIMITER ;

#회원의 운동 목적, 수준, 부위 및 MBTI 저장 테이블 생성
CREATE TABLE Members (
    MemberID INT PRIMARY KEY,
    ExercisePurpose ENUM('다이어트', '체력 증진', '근력 운동') NOT NULL,
    ExerciseLevel ENUM('초급', '중급', '고급') NOT NULL,
    ExerciseArea ENUM('상체', '하체', '유산소', '스트레칭') NOT NULL,
    MBTI_I_E ENUM('I', 'E'),
    MBTI_J_P ENUM('J', 'P'),
    FOREIGN KEY (MemberID) REFERENCES MemberInfo(MemberID)  -- 외래키 : MemberInfo의 MemberID
);

#친구 추가 테이블 생성
CREATE TABLE Friendship (
    FriendshipID INT AUTO_INCREMENT PRIMARY KEY,
    Member1ID INT NOT NULL,
    Member2ID INT NOT NULL,
    Status ENUM('Pending', 'Accepted', 'Rejected') NOT NULL, -- 친구 관계 상태(대기 중, 수락됨, 거부됨)
    FOREIGN KEY (Member1ID) REFERENCES MemberInfo(MemberID),
    FOREIGN KEY (Member2ID) REFERENCES MemberInfo(MemberID)
);

#홈트레이닝 영상 테이블 생성
CREATE TABLE HomeTrainings (
    VideoID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키
    ExercisePurpose ENUM('다이어트', '체력 증진', '근력 운동') NOT NULL,
    ExerciseLevel ENUM('초급', '중급', '고급') NOT NULL,
    ExerciseArea ENUM('상체', '하체', '유산소', '스트레칭') NOT NULL,
    Title VARCHAR(100) NOT NULL,
    Description TEXT,
    URL VARCHAR(255) NOT NULL
);

#스포츠 정보 테이블 생성
CREATE TABLE Sports (
    SportID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키
    SportName VARCHAR(50) NOT NULL,
    Description TEXT,
    SuitableFor ENUM('I', 'E') NOT NULL
);

#사용자 활동 로그 테이블 생성
CREATE TABLE UserLogs (
    LogID INT AUTO_INCREMENT PRIMARY KEY,  -- 기본키
    MemberID INT NOT NULL,
    ActivityType ENUM('운동', '영상 시청', '사이트 이용'),
    StartTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    EndTime TIMESTAMP,
    VideoID INT, -- 영상 시청 시 해당 영상의 ID
    DurationSeconds INT, -- 운동 또는 영상 시청 시간(초 단위)
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),  -- 외래키 : Members의 MemberID
    FOREIGN KEY (VideoID) REFERENCES HomeTrainings(VideoID)  -- 외래키 : HomeTrainings의 VideoID
);

#사용자 리뷰 테이블
CREATE TABLE Review (
	MemberID INT PRIMARY KEY,
    Score INT NOT NULL,
    CONSTRAINT chk_Score CHECK (Score BETWEEN 1 AND 5),
    reveiw VARCHAR(250),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

# DurationSeconds 자동 계산(EndTime - StartTime 초) 트리거
DELIMITER $$
CREATE TRIGGER calculate_duration
BEFORE INSERT ON UserLogs
FOR EACH ROW
BEGIN
    SET NEW.DurationSeconds = TIMESTAMPDIFF(SECOND, NEW.StartTime, NEW.EndTime);
END$$
DELIMITER ;

#본인의 MBTI를 모를 경우 질문을 통해 할당
-- MBTI 질문 답변 테이블
CREATE TABLE MBTIQuestion (
    QAID INT AUTO_INCREMENT PRIMARY KEY,
    question VARCHAR(100) NOT NULL,
    selectOne VARCHAR(100) NOT NULL,
    selectTwo VARCHAR(100) NOT NULL
);

INSERT INTO MBTIQuestion (question, selectOne, selectTwo)  -- selectOne : I / J, selectTwo : E / P
VALUES
('휴식을 취할 때 다른 사람과 시간을 보내기보다는 혼자 있는 것을 선호한다.', 'Yes', 'No'), -- answerOne에 관한 답변들
('새로운 환경에서 사람들과 대화하기 전에 관찰하는 것을 선호한다.', 'Yes', 'No'), -- answerTwo에 관한 답변들
('집중이 필요할 떄 혼자 있는 것이 더 효과적이라고 생각한다.', 'Yes', 'No'), -- answerThree에 관한 답변들
('새로운 사람들과 친해지는 것보다 익숙한 사람들과 시간을 보내는 편이다.', 'Yes', 'No'), -- answerFour에 관한 답변들
('자신의 생각이나 감정을 표현하기 전에 깊게 생각하는 편이다.', 'Yes', 'No'), -- answerFive에 관한 답변들 
('일정한 규칙과 체계를 선호한다.', 'Yes', 'No'), -- answerSix에 관한 답변들
('목표나 일정에 따라 체계적인 계획을 세우고, 이는 반드시 지켜져야 한다.', 'Yes', 'No'), -- answerSeven에 관한 답변들
('새로운 것들 보다는 익숙한 것이 더 좋다.', 'Yes', 'No'), -- answerEight에 관한 답변들
('무언가를 결정할 때 가능한 빠르게 결정하는 편이다.', 'Yes', 'No'), -- answerNine에 관한 답변들
('무언가를 시작하면 한 가지 일에 몰두하는 편이다.', 'Yes', 'No'); -- answerTen에 관한 답변들

-- MemberQA 테이블 생성
CREATE TABLE MemberQA (
    MemberID INT NOT NULL,
    answerOne VARCHAR(100) NOT NULL,
    answerTwo VARCHAR(100) NOT NULL,
    answerThree VARCHAR(100) NOT NULL,
    answerFour VARCHAR(100) NOT NULL,
    answerFive VARCHAR(100) NOT NULL,
    answerSix VARCHAR(100) NOT NULL,
    answerSeven VARCHAR(100) NOT NULL,
    answerEight VARCHAR(100) NOT NULL,
    answerNine VARCHAR(100) NOT NULL,
    answerTen VARCHAR(100) NOT NULL,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
);

DELIMITER $$
CREATE TRIGGER before_insert_memberqa
BEFORE INSERT ON MemberQA
FOR EACH ROW
BEGIN
    DECLARE ICount INT DEFAULT 0;
    DECLARE JCount INT DEFAULT 0;
    DECLARE MBTI_I_E VARCHAR(1);
    DECLARE MBTI_J_P VARCHAR(1);
    
    -- MemberQA 테이블에서 답변을 기반으로 I/E와 J/P 개수 계산
    SELECT
        SUM(CASE WHEN NEW.answerOne IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 1) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerTwo IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 2) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerThree IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 3) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerFour IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 4) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerFive IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 5) THEN 1 ELSE 0 END) 
    INTO ICount;
    
    SELECT
        SUM(CASE WHEN NEW.answerSix IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 6) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerSeven IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 7) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerEight IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 8) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerNine IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 9) THEN 1 ELSE 0 END) +
        SUM(CASE WHEN NEW.answerTen IN (SELECT selectOne FROM MBTIQuestion WHERE QAID = 10) THEN 1 ELSE 0 END) 
    INTO JCount;

    -- 개수에 따라 MBTI_I_E와 MBTI_J_P 결정
    IF ICount >= 3 THEN
        SET MBTI_I_E = 'I';
    ELSE
        SET MBTI_I_E = 'E';
    END IF;

    IF JCount >= 3 THEN
        SET MBTI_J_P = 'J';
    ELSE
        SET MBTI_J_P = 'P';
    END IF;

    -- 계산된 MBTI 값을 Members 테이블에 업데이트
    UPDATE Members
    SET
        MBTI_I_E = MBTI_I_E,
        MBTI_J_P = MBTI_J_P
    WHERE
        MemberID = NEW.MemberID;
END$$
DELIMITER ;

SET GLOBAL log_bin_trust_function_creators = 1;

# 예시 데이터 -- 추후 홈트 영상 및 스포츠 테이블 데이터 INSERT 할 예정
INSERT INTO MemberInfo (ID, Password, Phone, MemberName, Birthdate, Age, Gender, Nickname)
VALUES 
('userIdCHeck', 'cHeckPW', '01012341233', '홍길동', '1990-01-01', 31, '남성', 'roadDong'),
('sn2kw123', 'kqln!32s', '01099991234', '김철수', '1995-05-15', 26, '남성', 'IronWater'),
('31nkal', 'password@', '01026738923', '유저이름', '1985-09-20', 36, '여성', NULL),
('user4', 'Password4', '01032352123', '닉네임확인', '2000-03-10', 24, '남성', NULL),
('IDyoung', 'youngPW', '01089273182', '이영희', '1988-07-08', 33, '여성', 'zeroHee');

INSERT INTO Members (MemberID, ExercisePurpose, ExerciseLevel, ExerciseArea, MBTI_I_E, MBTI_J_P)
VALUES
(1, '다이어트', '초급', '상체', NULL, NULL),
(2, '체력 증진', '중급', '하체', 'E', NULL),
(3, '근력 운동', '고급', '유산소', NULL, 'J'),
(4, '다이어트', '초급', '상체', 'E', 'P'),
(5, '체력 증진', '중급', '하체', 'I', 'J');

INSERT INTO Friendship (Member1ID, Member2ID,status)
VALUES
(1, 2, 'Pending'),
(2, 5, 'Accepted'),
(4, 1, 'Rejected'),
(3, 2, 'Rejected');

INSERT INTO MemberQA (MemberID, answerOne, answerTwo, answerThree, answerFour, answerFive, answerSix, answerSeven, answerEight, answerNine, answerTen)
VALUES
(1, 'Yes', 'Yes', 'Yes', 'No', 'No', 'Yes', 'Yes', 'Yes', 'Yes', 'No'),  -- I/J
(2, 'No', 'Yes', 'No', 'Yes', 'No', 'No', 'Yes', 'Yes', 'No', 'Yes'),  -- E/J
(3, 'Yes', 'No', 'Yes', 'No', 'No', 'No', 'No', 'No', 'No', 'No');  -- E/P

INSERT INTO HomeTrainings (ExercisePurpose, ExerciseLevel, ExerciseArea, Title, Description, URL)
VALUES
('근력 운동', '초급', '하체', '[초급] 하체 근력 운동', '헬린이 추천! 하체 운동 입문', 'https://www.example.com/video1'),
('다이어트', '중급', '상체', '[중급] 다이어트 너도 할 수 있어!', '오늘부터 뱃살과 이별하기로 했습니다.', 'https://www.example.com/video2'),
('체력 증진', '초급', '유산소', '유산소 체력 증진', '하루 1시간 가볍게 유산소 운동', 'https://www.example.com/video3'),
('체력 증진', '초급', '스트레칭', '거북목 이제 그만!', '이 영상이 뜬 당신, 스트레칭 시~작!', 'https://www.example.com/video4'),
('근력 운동', '고급', '스트레칭', '[고급] 상체 운동 전 스트레칭', '근력 운동 전에 스트레칭은 필수', 'http://www.example.com/video5');

INSERT INTO Sports (SportName, Description, SuitableFor)
VALUES
('축구', '친구와 함께 해요 :)', 'E'),
('수영', '혼자 할 수 있어요!', 'I'),
('농구', '친구와 함께 해요 :)', 'E'),
('자전거', '혼자 할 수 있어요!', 'I'),
('야구', '친구와 함께 해요 :)', 'E');

INSERT INTO UserLogs (MemberID, ActivityType, StartTime, EndTime, VideoID, DurationSeconds)
VALUES
(1, '운동', '2024-04-12 10:00:00', '2024-04-12 11:00:00', 1, NULL),
(2, '영상 시청', '2024-04-12 12:00:00', '2024-04-12 12:30:00', 2, NULL),
(3, '운동', '2024-04-12 14:00:00', '2024-04-12 15:00:00', NULL, NULL),
(4, '사이트 이용', '2024-04-12 16:00:00', '2024-04-12 17:00:00', NULL, NULL),
(5, '운동', '2024-04-12 18:00:00', '2024-04-12 19:00:00', 3, NULL);

INSERT INTO Review (MemberID, Score, reveiw)
VALUES
(1, 3, '더 다양한 홈트레이닝 영상이 있으면 좋겠어요.'),
(2, 5, NULL),
(4, 4, '친구랑 같이 사용할 수 있어서 좋아요');

SELECT * FROM MemberInfo;
SELECT * FROM Members;  -- MemberID : 3인 경우 보면, 사용자는 J라고 입력했는데 응답 결과 P라고 나옴 => 응답 결과에 맞춰서 저장
SELECT * FROM Friendship;
SELECT * FROM MBTIQuestion;
SELECT * FROM memberQA;
SELECT * FROM HomeTrainings;
SELECT * FROM Sports;
SELECT * FROM UserLogs;
SELECT * FROM Review;
