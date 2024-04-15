USE capston;
#회원 테이블 생성
CREATE TABLE MemberInfo (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
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
    MemberID INT NOT NULL,
    ExercisePurpose ENUM('다이어트', '체력 증진', '근력 운동') NOT NULL,
    ExerciseLevel ENUM('초급', '중급', '고급') NOT NULL,
    ExerciseArea ENUM('상체', '하체', '유산소') NOT NULL,
    MBTI_I_E ENUM('I', 'E'),
    MBTI_J_P ENUM('J', 'P'),
    FOREIGN KEY (MemberID) REFERENCES MemberInfo(MemberID)
);

#홈트레이닝 영상 테이블 생성
CREATE TABLE HomeTrainings (
    VideoID INT PRIMARY KEY AUTO_INCREMENT,
    ExercisePurpose ENUM('다이어트', '체력 증진', '근력 운동') NOT NULL,
    ExerciseLevel ENUM('초급', '중급', '고급') NOT NULL,
    ExerciseArea ENUM('상체', '하체', '유산소') NOT NULL,
    Title VARCHAR(100) NOT NULL,
    Description TEXT,
    URL VARCHAR(255) NOT NULL
);

#스포츠 정보 테이블 생성
CREATE TABLE Sports (
    SportID INT PRIMARY KEY AUTO_INCREMENT,
    SportName VARCHAR(50) NOT NULL,
    Description TEXT,
    SuitableFor ENUM('I', 'E') NOT NULL
);

#사용자 활동 로그 테이블 생성
CREATE TABLE UserLogs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    MemberID INT NOT NULL,
    ActivityType ENUM('운동', '영상 시청', '사이트 이용'),
    StartTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    EndTime TIMESTAMP,
    VideoID INT, -- 영상 시청 시 해당 영상의 ID
    DurationSeconds INT, -- 운동 또는 영상 시청 시간(초 단위)
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (VideoID) REFERENCES HomeTrainings(VideoID)
);

# DurationSeconds 자동 계산 TRIGGER 생성
DELIMITER $$
CREATE TRIGGER calculate_duration
BEFORE INSERT ON UserLogs
FOR EACH ROW
BEGIN
    SET NEW.DurationSeconds = TIMESTAMPDIFF(SECOND, NEW.StartTime, NEW.EndTime);
END$$
DELIMITER ;

-- 트리거를 트리거 생성 후 설정으로 변경


#본인의 MBTI를 모를 경우 질문을 통해 할당
-- MBTI 질문 답변 테이블
CREATE TABLE MBTIQuestion (
    QAID INT AUTO_INCREMENT PRIMARY KEY,
    question VARCHAR(100) NOT NULL,
    selectOne VARCHAR(100) NOT NULL,
    selectTwo VARCHAR(100) NOT NULL
);

INSERT INTO MBTIQuestion (question, selectOne, selectTwo)
VALUES
('질문 1', '답변 A', '답변 B'), -- answerOne에 관한 답변들
('질문 2', '답변 C', '답변 D'), -- answerTwo에 관한 답변들
('질문 3', '답변 E', '답변 F'), -- answerThree에 관한 답변들
('질문 4', '답변 G', '답변 H'), -- answerFour에 관한 답변들
('질문 5', '답변 I', '답변 J'), -- answerFive에 관한 답변들 
('질문 6', '답변 K', '답변 L'), -- answerSix에 관한 답변들
('질문 7', '답변 M', '답변 N'), -- answerSeven에 관한 답변들
('질문 8', '답변 O', '답변 P'), -- answerEight에 관한 답변들
('질문 9', '답변 Q', '답변 R'), -- answerNine에 관한 답변들
('질문 10', '답변 S', '답변 T'); -- answerTen에 관한 답변들

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

# 예시 데이터
INSERT INTO MemberInfo (ID, Password, Phone, MemberName, Birthdate, Age, Gender, Nickname)
VALUES 
('user1', 'password1', '123456789', 'John Doe', '1990-01-01', 31, '남성', 'johndoe'),
('user2', 'password2', '987654321', 'Jane Smith', '1995-05-15', 26, '여성', 'janesmith'),
('user3', 'password3', '111222333', 'Mike Johnson', '1985-09-20', 36, '남성', 'mikej'),
('user4', 'password4', '444555666', 'Emily Brown', '2000-03-10', 24, '여성', NULL),
('user5', 'password5', '777888999', 'Chris Lee', '1988-07-08', 33, '남성', 'chrislee');

INSERT INTO Members (MemberID, ExercisePurpose, ExerciseLevel, ExerciseArea, MBTI_I_E, MBTI_J_P)
VALUES
(1, '다이어트', '초급', '상체', NULL, NULL),
(2, '체력 증진', '중급', '하체', 'E', NULL),
(3, '근력 운동', '고급', '유산소', NULL, 'J'),
(4, '다이어트', '초급', '상체', 'E', 'P'),
(5, '체력 증진', '중급', '하체', 'I', 'J');

INSERT INTO MemberQA (MemberID, answerOne, answerTwo, answerThree, answerFour, answerFive, answerSix, answerSeven, answerEight, answerNine, answerTen)
VALUES
(1, '답변 A', '답변 C', '답변 E', '답변 H', '답변 I', '답변 K', '답변 M', '답변 O', '답변 R', '답변 T'),  -- I/J
(2, '답변 B', '답변 C', '답변 E', '답변 H', '답변 J', '답변 K', '답변 M', '답변 P', '답변 Q', '답변 T'),  -- E/J
(3, '답변 B', '답변 C', '답변 E', '답변 H', '답변 J', '답변 L', '답변 M', '답변 O', '답변 R', '답변 T');  -- E/P

INSERT INTO HomeTrainings (ExercisePurpose, ExerciseLevel, ExerciseArea, Title, Description, URL)
VALUES
('다이어트', '초급', '상체', '상체 다이어트 운동', '상체 다이어트를 위한 운동 영상입니다.', 'https://www.example.com/video1'),
('체력 증진', '중급', '하체', '하체 강화 운동', '하체 근력을 키우기 위한 운동 영상입니다.', 'https://www.example.com/video2'),
('근력 운동', '고급', '유산소', '고급 유산소 운동', '고급 근력 운동을 위한 유산소 운동 영상입니다.', 'https://www.example.com/video3');

INSERT INTO Sports (SportName, Description, SuitableFor)
VALUES
('축구', '축구에 대한 설명입니다.', 'E'),
('수영', '수영에 대한 설명입니다.', 'I'),
('농구', '농구에 대한 설명입니다.', 'E'),
('테니스', '테니스에 대한 설명입니다.', 'I'),
('야구', '야구에 대한 설명입니다.', 'E');

INSERT INTO UserLogs (MemberID, ActivityType, StartTime, EndTime, VideoID, DurationSeconds)
VALUES
(1, '운동', '2024-04-12 10:00:00', '2024-04-12 11:00:00', 1, NULL),
(2, '영상 시청', '2024-04-12 12:00:00', '2024-04-12 12:30:00', 2, NULL),
(3, '운동', '2024-04-12 14:00:00', '2024-04-12 15:00:00', NULL, NULL),
(4, '사이트 이용', '2024-04-12 16:00:00', '2024-04-12 17:00:00', NULL, NULL),
(5, '운동', '2024-04-12 18:00:00', '2024-04-12 19:00:00', 3, NULL);

SELECT * FROM MemberInfo;
SELECT * FROM Members;  -- MemberID : 3인 경우 보면, 사용자는 J라고 입력했는데 응답 결과 P라고 나옴 => 응답 결과에 맞춰서 저장하는 걸로 결정 : 팀 회의 때 말해주기
SELECT * FROM MBTIQuestion;
SELECT * FROM memberQA;
SELECT * FROM HomeTrainings;
SELECT * FROM Sports;
SELECT * FROM UserLogs;

