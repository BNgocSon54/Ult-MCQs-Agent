-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 21, 2026 at 11:03 AM
-- Server version: 11.4.9-MariaDB-cll-lve-log
-- PHP Version: 8.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `spdhlmjn_mcqs`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveFile` (IN `p_uploader_id` INT, IN `p_filename` VARCHAR(500) CHARACTER SET utf8mb4, IN `p_file_type` VARCHAR(50) CHARACTER SET utf8mb4, IN `p_storage_path` VARCHAR(500) CHARACTER SET utf8mb4, IN `p_raw_text` LONGTEXT CHARACTER SET utf8mb4, IN `p_summary` LONGTEXT CHARACTER SET utf8mb4, OUT `out_file_id` INT)   BEGIN
    INSERT INTO Files (uploader_id, filename, file_type, storage_path, raw_text, summary, uploaded_at)
    VALUES (p_uploader_id, p_filename, p_file_type, p_storage_path, p_raw_text, p_summary, NOW());
    
    SET out_file_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveQuestionWithEval` (IN `p_source_file_id` INT, IN `p_creator_id` INT, IN `p_question_text` LONGTEXT CHARACTER SET utf8mb4, IN `p_options_json` LONGTEXT CHARACTER SET utf8mb4, IN `p_answer_letter` CHAR(1) CHARACTER SET utf8mb4, IN `p_status` VARCHAR(20) CHARACTER SET utf8mb4, IN `p_model_version` VARCHAR(100) CHARACTER SET utf8mb4, IN `p_total_score` INT, IN `p_accuracy_score` INT, IN `p_alignment_score` INT, IN `p_distractors_score` INT, IN `p_clarity_score` INT, IN `p_status_by_agent` VARCHAR(20) CHARACTER SET utf8mb4, IN `p_raw_response_json` LONGTEXT CHARACTER SET utf8mb4)   BEGIN
    INSERT INTO Questions (
        source_file_id, creator_id, question_text, options, 
        answer_letter, status, created_at
    )
    VALUES (
        p_source_file_id, p_creator_id, p_question_text, p_options_json, 
        p_answer_letter, p_status, NOW()
    );
    
    SET @new_question_id = LAST_INSERT_ID();

    INSERT INTO QuestionEvaluations (
        question_id, model_version, evaluated_at, total_score, 
        accuracy_score, alignment_score, distractors_score, clarity_score, 
        status_by_agent, raw_response_json
    )
    VALUES (
        @new_question_id, p_model_version, NOW(), p_total_score,
        p_accuracy_score, p_alignment_score, p_distractors_score, p_clarity_score,
        p_status_by_agent, p_raw_response_json
    );
    
    SET @new_evaluation_id = LAST_INSERT_ID();

    UPDATE Questions SET latest_evaluation_id = @new_evaluation_id
    WHERE question_id = @new_question_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ExamQuestions`
--

CREATE TABLE `ExamQuestions` (
  `exam_question_id` int(11) NOT NULL,
  `exam_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `order_index` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `ExamQuestions`
--

INSERT INTO `ExamQuestions` (`exam_question_id`, `exam_id`, `question_id`, `order_index`) VALUES
(1, 1, 1, 0),
(2, 1, 2, 0),
(3, 1, 3, 0),
(4, 1, 4, 0),
(5, 1, 5, 0),
(6, 1, 6, 0),
(7, 1, 7, 0),
(8, 1, 8, 0),
(9, 1, 9, 0),
(10, 1, 10, 0),
(11, 2, 9, 0),
(12, 2, 10, 0),
(13, 3, 11, 0),
(14, 3, 12, 0),
(15, 3, 13, 0),
(16, 3, 14, 0),
(17, 3, 15, 0);

-- --------------------------------------------------------

--
-- Table structure for table `Exams`
--

CREATE TABLE `Exams` (
  `exam_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `title` varchar(500) NOT NULL,
  `description` longtext DEFAULT NULL,
  `share_token` varchar(50) NOT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `Exams`
--

INSERT INTO `Exams` (`exam_id`, `owner_id`, `title`, `description`, `share_token`, `is_public`, `created_at`) VALUES
(1, 1, 'thuyettrinh1', '', '0e1cd9d1db0d9cd5', 0, '2025-11-13 10:13:44'),
(2, 1, 'asd', '', '33acfaefed88668a', 0, '2025-11-27 18:10:40'),
(3, 1, 'abc', '', 'a547f34e7630bfd2', 0, '2025-12-21 21:06:39');

-- --------------------------------------------------------

--
-- Table structure for table `ExamSessions`
--

CREATE TABLE `ExamSessions` (
  `session_id` int(11) NOT NULL,
  `exam_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `guest_name` varchar(255) DEFAULT NULL,
  `start_time` datetime DEFAULT current_timestamp(),
  `end_time` datetime DEFAULT NULL,
  `total_score` int(11) DEFAULT NULL,
  `lti_lineitem_url` text DEFAULT NULL,
  `lti_user_sub` varchar(255) DEFAULT NULL,
  `lti_iss` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `ExamSessions`
--

INSERT INTO `ExamSessions` (`session_id`, `exam_id`, `user_id`, `guest_name`, `start_time`, `end_time`, `total_score`, `lti_lineitem_url`, `lti_user_sub`, `lti_iss`) VALUES
(1, 1, 1, NULL, '2025-11-13 10:14:30', '2025-11-13 10:16:50', 7, NULL, NULL, NULL),
(2, 1, NULL, 'asd', '2025-11-27 18:12:21', '2025-11-27 18:13:24', 0, NULL, NULL, NULL),
(3, 1, 1, NULL, '2025-11-27 18:13:45', '2025-11-27 18:13:49', 1, NULL, NULL, NULL),
(4, 1, NULL, 'haha', '2025-12-03 14:27:24', '2025-12-03 14:27:27', 0, NULL, NULL, NULL),
(5, 1, NULL, 'hihi', '2025-12-03 14:29:40', NULL, NULL, NULL, NULL, NULL),
(6, 1, 1, NULL, '2025-12-10 13:33:41', '2025-12-10 13:33:45', 0, NULL, NULL, NULL),
(7, 1, 1, NULL, '2025-12-10 13:33:56', '2025-12-10 13:34:09', 1, NULL, NULL, NULL),
(8, 2, 15, NULL, '2025-12-10 17:13:01', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(9, 2, 15, NULL, '2025-12-10 17:13:45', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(10, 2, 15, NULL, '2025-12-10 17:14:28', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(11, 2, 15, NULL, '2025-12-10 17:23:13', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(12, 2, 15, NULL, '2025-12-10 17:28:30', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(13, 2, 15, NULL, '2025-12-10 17:29:17', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(14, 2, 15, NULL, '2025-12-10 17:30:14', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(15, 2, 15, NULL, '2025-12-10 17:37:48', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(16, 2, 15, NULL, '2025-12-10 17:49:04', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(17, 2, 15, NULL, '2025-12-11 13:28:23', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(18, 2, 15, NULL, '2025-12-11 13:28:35', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(19, 2, 15, NULL, '2025-12-11 13:28:51', '2025-12-11 13:29:08', 0, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(20, 2, 16, NULL, '2025-12-11 14:20:50', '2025-12-11 14:21:28', 0, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '4', 'https://ultmcqs.moodlecloud.com'),
(21, 3, 1, NULL, '2025-12-21 21:07:16', '2025-12-21 21:07:28', 0, NULL, NULL, NULL),
(22, 2, 15, NULL, '2025-12-21 21:08:15', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(23, 2, 15, NULL, '2025-12-21 21:08:48', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/14/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(24, 3, 15, NULL, '2025-12-21 21:09:47', '2025-12-21 21:09:58', 0, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/15/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(25, 3, 15, NULL, '2025-12-22 14:21:21', NULL, NULL, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/15/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(26, 3, 15, NULL, '2025-12-22 14:21:38', '2025-12-22 14:21:59', 0, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/15/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com'),
(27, 3, 15, NULL, '2025-12-22 14:22:39', '2025-12-22 14:22:51', 1, 'https://ultmcqs.moodlecloud.com/mod/lti/services.php/9/lineitems/15/lineitem?type_id=1', '2', 'https://ultmcqs.moodlecloud.com');

-- --------------------------------------------------------

--
-- Table structure for table `Files`
--

CREATE TABLE `Files` (
  `file_id` int(11) NOT NULL,
  `uploader_id` int(11) NOT NULL,
  `filename` varchar(500) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp(),
  `storage_path` varchar(500) DEFAULT NULL,
  `raw_text` longtext DEFAULT NULL,
  `summary` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `Files`
--

INSERT INTO `Files` (`file_id`, `uploader_id`, `filename`, `file_type`, `uploaded_at`, `storage_path`, `raw_text`, `summary`) VALUES
(1, 1, '\"DungNhat13_11_25_1.m4a\"', 'M4A', '2025-11-13 10:12:31', NULL, 'Người 2: Rồi lên đây nè, lên đây vô.\nNgười 2: Rồi các bạn bắt đầu nhận xét đi.\nNgười 1: Dạ nhận xét có. Khó.\nNgười 2: Cái gì cần phải cải thiện, nhanh gọn vậy thôi.\nNgười 1: Rồi cái chỗ này trong.\nNgười 2: Rồi mời các bạn. Thầy cô nghĩ là lên lên dồn lên cho ngồi xa chi vậy? Nghe sao được? Em, lên đây ngồi.\nNgười 2: Rồi lên đi.\nNgười 1: lên chơi đó.\nNgười 2: Chứ không không thấy. Nhanh nhẹn lên, nhanh nhẹn lên để thầy làm việc khác nữa.\nNgười 1: Thịnh.\nNgười 2: Lên!\nNgười 1: Nãy.\nNgười 2: Thầy ơi cứ phải gọi đúng tên mới lên đó trời. Lẹ lên giùm cô đi, trời ơi.\nNgười 2: Không có ai làm việc riêng nha, làm việc chung nhóm. Rồi trả lời.\nNgười 1: Để mà hỏi.\nNgười 2: Để mà hỏi. Hỏi hoặc là cải thiện hoặc cải tiến gì đó. hỏi.\nNgười 1: Hỏi có ý.\nNgười 2: Cải tiến. Em mời em trình bày mà, thầy chưa coi.\nNgười 1: À. Về tiếp theo thì mình sẽ demo thử cho các bạn xem. Đầu tiên thì mình sẽ đăng ký. Và đăng ký bằng email.\nNgười 1: Okay, tạo.\nNgười 1: Sau khi đăng ký thành công thì tiếp theo là mình sẽ tạo một thẻ. Thì ở đây thì ứng dụng mình sẽ có bốn kiểu mẫu thẻ. Thì bạn sẽ tùy theo cái cách mà bạn muốn thẻ thì bạn sẽ chọn theo như thế này. Mình sẽ chọn thử là kinh nghiệm. Thì ở đây sẽ có hai cách mẫu thẻ là mẫu thẻ từ ảnh và từ văn bản. Thì tùy theo cái bạn thì ở đây ở từ ảnh thì các bạn chọn ảnh có hoặc là mở camera hiện tại. Ở đây mình sẽ chọn cái ảnh nào đó.\nNgười 1: Đây ở đây sẽ không có thẻ cho cái hình ảnh mà mình đã chọn. Và ở dưới đây sẽ có khi mình đăng nhập thì nó sẽ lưu lại cái lịch sử mua thẻ của mình. Còn nếu mà không đăng nhập á thì nó sẽ không không có lưu được lịch sử mua thẻ và mình chỉ sử dụng được cái này thôi. Còn từ văn bản thì cũng vậy.\nNgười 1: Rồi, sẽ có lịch sử mua thẻ của mình. Lịch sử mua thẻ vậy đó.\nNgười 2: Trước giờ là thẻ ra một cái mới phải không, đúng không?\nNgười 1: Ý, ví dụ mình bây giờ mình.\nNgười 1: thấy cái đó nó hay rồi nhưng mà tự nhiên có một vài chữ mình ghét thì sao. Không có muốn kiểu đó mình cũng để cho nó mình thay chữ khác thì sao.\nNgười 1: Thì như còn này vẫn hồi nãy copy ra mà đúng không? Thì còn ở đây thì sao chép thì vẫn load vào cái gì đó. Vẫn có thể load vào một cái nốt mình copy ra thôi xong rồi mình sửa mình hoặc là mình xóa cái chữ đó thì.\nNgười 2: Tiếp đi các bạn ơi. Ai nữa đây hỏi cái nào? Phát.\nNgười 2: Nhanh nhanh nhanh không còn giờ nữa đâu nha. Xếp.\nNgười 1: hỏi ai nữa.\nNgười 2: Thịnh.\nNgười 1: Dạ.\nNgười 2: Làm sao để làm cái gì ạ?\nNgười 1: Thì mô tả sản phẩm trên tay.\nNgười 2: Làm sao để làm gì?\nNgười 1: Thì thấy cũng nghe thấy là liên quan tới người. Cũng có kiểu như liên quan tới AI cũng vậy.\nNgười 2: Nhưng mà để làm gì?\nNgười 1: Thấy cũng nghe thấy là liên quan tới TikTok.\nNgười 2: Hả?\nNgười 1: Nghe thấy là liên quan tới TikTok.\nNgười 1: Thì có thể là tùy tùy.\nNgười 2: Liên quan đến TikTok hả? Viết bài để làm gì á? Để đăng lên TikTok đúng không?\nNgười 1: Dạ.\nNgười 2: Ờ.\nNgười 1: Rồi nãy em nghe.\nNgười 2: Hả?\nNgười 1: Chứ nãy em nghe có liên quan tới TikTok.\nNgười 2: Ờ. Đăng TikTok rồi cái hết chưa?\nNgười 1: Ở trong đó tôi ghi rồi, tôi nghe thấy gì đâu.\nNgười 2: Đó.\nNgười 1: Dạ.\nNgười 1: Ờ thì bạn có thể bạn viết thêm content về cái hình ảnh mà bạn đã sử dụng. Với cái hashtag mà bạn muốn viết hashtag bạn viết.\nNgười 2: Thế có ai ở đây biết là cái nhóm này làm cái đề tài này để làm gì không? Dạ sếp ơi.\nNgười 2: Với cả bà con nữa.\nNgười 1: Không có gì hết.\nNgười 2: À liên quan hôm bữa em đứng nghe bà hay là bạn báo cáo nghe.\nNgười 2: Em đoán.\nNgười 1: Chỉ có mô tả sản phẩm trên cái gì phải.\nNgười 1: Là về. Mô tả cái cây thì.\nNgười 2: Các bạn đã có góp ý gì không?\nNgười 1: Từ văn bản thì nó có thể chuyển sang cái hình ảnh liên quan từ cái thông tin mình đưa vào từ. Ờ hiện tại mà nếu mà từ văn bản mà chuyển sang hình ảnh liên quan thì nhóm mình hiện tại thì chưa làm cái đó. Nhưng mà nếu nếu vậy thì có thể là trong tương lai thì mình cũng sẽ phát triển thêm cái đó.\nNgười 1: Đưa ra.\nNgười 1: Giờ ví dụ nếu mà thầy thầy cái cảm giác của hai cái nội dung nó hơi giống nhau thì có nhầm mình tạo nhiều quá thì cái nội dung nó bị lặp lại. Thì đọc nó cứ xem xem nhau.\nNgười 1: Ví dụ như cái nó có cách nào để nó mướt hơn không?\nNgười 2: Sao em biết là xe xe? Em có mới để demo có tạo rồi em cái xe xe.\nNgười 1: Cảm giác cái hai cái kia cái hứng của cái đó là ý là nó sẽ giống giống nhau. Nghĩa là nó vẫn sẽ khác thôi. Cảm giác cái kiếng vẫn giống nhau nhưng mà nếu mà đã nhiều thì mình có thể tạm kiểu như đăng cách nhau là đưa cho khách hàng.\nNgười 1: Đây mình có bốn cái đây là mình có thể.\nNgười 1: Đúng rồi.\nNgười 2: Rồi hết 15 phút rồi nhóm này thì à thầy rồi ha, cơ hội cũng hết rồi đó.\nNgười 1: cũng cần có.\nNgười 2: Thầy cô còn góp ý nhất là cái tên đề tài á thì phải làm sao đó để người ta biết được mục đích để làm gì. Còn nếu muốn che giấu đến phút cuối mình mới nói á thì đặt cái tên.\nNgười 1: Dạ.\nNgười 2: Fruit gì đó Smart hay cái gì gì đấy hoặc là Farmer friend gì gì đó, nhẹ nhẹ như thế. Có nghĩa là nếu mà để đến phút cuối cùng người ta mới biết cái của mình là làm cái gì á nói cái tên thôi. Nhiều khi mấy cái sản phẩm người ta cũng có cái tên. Tuy nhiên khi mô tả sản phẩm mình mô tả cho kỹ để người ta hiểu là cái này làm gì, mô tả sản phẩm cái cây để làm gì nữa để người ta dễ hiểu.\nNgười 2: Ờ các bạn nha, các bạn nhóm khác nha, tí nữa lên á Phần sau chứ nếu mà dính phải là cô cô với Thạnh trừ điểm nha. Thứ nhất là Slide number không có.\nNgười 1: Đi vô.\nNgười 2: Tức là không có. Cuối buổi ngày hôm nay là Thịnh ghi lại các yêu cầu cho thầy để đưa lên nhóm nha.\nNgười 1: Thư ký hả?\nNgười 2: À. Thịnh là thư ký còn cái nhóm đó thì cứ ghi cái lỗi của mình vô để bữa sau không mắc phải. Còn Thịnh thì ghi cái quy định này lên trên nhóm cho thầy. Ai vướng quy định này là lượm lúa.\nNgười 2: Rồi các bạn học Epic rồi đúng không? Học môn nhập môn phát triển dự án kỹ thuật rồi đúng không?\nNgười 2: Lắc đầu là sai rồi đấy. Cô Phương dạy đúng không?\nNgười 1: Không, đâu không.\nNgười 2: Thế ai dạy? Cô Hường dạy?\nNgười 1: Cô môn nó đâu.\nNgười 2: Muốn cái môn Epic đó. Nhập môn dự án khuyên phát triển dự án kỹ thuật Epic.\nNgười 1: À.\nNgười 2: Em không quên không? Phát triển dự án kỹ thuật. Cụ thể. Nhập. Cô dạy đúng không? Rồi lớp về đó dạy còn lớp mấy lớp này quên hết luôn rồi.\nNgười 1: Dạ.\nNgười 2: Ai dạy? Cô Phương hoặc thầy Phúc hoặc cô Hường. Đợt các em là có ba người cô đó thôi. Có mới cô không dạy. Thế thì các cái cái bước, sáu cái phase của Epic đó mình đã đi hết chưa?\nNgười 1: Cái phase đó là gì? mở ra xem luôn.\nNgười 2: Quy trình phát triển dự án á. Được chưa? Đầu tiên là các em khảo sát, các em khảo sát chưa? Được chưa? Khảo sát xong về bắt đầu phân tích. Có nghĩa là em phải đưa ra được các cái đầu tiên là ngồi brainstorm xong rồi ví dụ như mặc dù là thầy giao đi, thầy giao đi thì các em cũng phải là à xem xem là mình nên làm các chức năng gì. Đúng chưa? Sau khi có chức năng đó mình phải đem ra đi qua cái stakeholder, tức là những cái bên liên quan. Ai sẽ dùng sản phẩm này? Đúng không? Ví dụ nông dân là người dùng chính nhưng mà giả sử như là tôi là một cái bên thứ ba, tôi muốn chạy marketing cho một cái farmer nào đó, một cái farm nào đó, đúng không? Thì tôi cũng cần dùng.\nNgười 1: Nông dân dùng.\nNgười 2: Đúng không? Hoặc là cái người mà thường thường đọc bài của các nhà nông á thì họ cũng cần. Đó là những cái bên liên quan. Vậy thì các em đã khảo sát họ chưa? Liệu sản phẩm của mình làm ra người ta có dùng hay không? Hay người ta nói ôi giời ơi cái này tôi lên AI cứ prom tôi sai hoài, sai cái tên là xong. Vậy thì các em trả lời làm sao? Cái cái của các em khác gì cái đó, cái cái đã có trên thị trường. Đó vậy thôi. Khảo sát thì có hai cái khảo sát, thứ nhất là khảo sát cái bên liên quan, hai là khảo sát những sản phẩm đã có trên thị trường. Được chưa? Để biết được rằng là của mình khác người ta cái gì mà mình mới phải làm. Còn nếu mà giống rồi làm chi nữa?\nNgười 2: Được chưa? Rồi tiếp nữa cô cũng thấy là còn thiếu là không thấy flowchart của nhóm. Có nghĩa là cái cái ví dụ như là trong ờ cái trong quá trình cái cái phần mềm á thì nó sẽ có cái gì nữa? Use case là khác rồi, còn cái flowchart tức là bước một bắt đầu là làm cái gì, bước hai làm cái gì, bước ba làm cái gì á, nó sẽ có một cái flowchart đó. Đô xử lý á, đúng rồi, đó, vậy vậy hoài á. Có chưa chưa cô đã chưa thấy. Lưu đồ hệ thống cơ sở dữ liệu như thế nào không thấy. Hay là không lưu cơ sở dữ liệu gì rồi có các em không không có cá chai luôn. Có cả kéo ai cay lên thôi.\nNgười 1: Luôn đi.\nNgười 1: Nộp sổ.\nNgười 2: Ờ em phải mô tả cái đó nếu không đi chấm bài là Ờ rubric của môn này các em thấy chưa?\nNgười 2: Chưa là sai, mở lên lên tôi coi.\nNgười 2: Mình làm gì á mình phải có tiêu chí của của ban giám khảo. Tiêu chí ban giám khảo là gì? Thầy cô mong muốn là cái cái cái cái cái cái cái các bạn mà làm phát triển ứng dụng này nè. Ha về với tôi đi mấy cái đề tài này năm nay. Để chi? Mình có sẵn rồi mình ra mình bọ sát. Hỗ trợ với các đội khác để chi? Để cải thiện kỹ năng báo cáo đi. Rubric đâu. Công cụ đánh giá kìa.\nNgười 2: Đấy, xuống dưới. Đấy. À, người ta sẽ đánh giá cái gì? Giáo viên sẽ đánh giá rất rất. Văn phong trình bày như bên dưới dưới nó thì cái này là giáo viên chấm hả? Nội dung đồ án, đó, có đầy đủ cái này, chi tiết công việc xác định gì đó. Chi tiết đánh giá này. Đó, ai xem xem là nếu có gì, có cái gì. Rồi là cái biểu mẫu của báo cáo Word là như thế nào, biểu mẫu của slide Power Point là như thế nào. Phân tích bài toán, thiết kế hệ thống thấy không thấy không? Phân tích bài toán này, thiết kế hệ thống này. Nếu đạt tiêu điểm thì là phân tích đầy đủ các yêu cầu chức năng dựa trên mục tiêu đề ra. Đúng không? Thiết kế hệ thống, thiết kế hệ thống đáp ứng đầy đủ các phân tích yêu cầu chức năng. Đánh giá phân tích bài toán, tức là phân tích xong rồi đánh giá như thế nào đó. Cái môn này á thì nó chưa yêu cầu ra cái sản phẩm. Học. Được không? Tuy nhiên mình làm được như vậy thì tốt quá sau này mình vô công việc luôn.\nNgười 2: Cho nên là mình chỉ đến cái bước gọi là phân tích và đánh giá cái phân tích đó là phải đầy đủ. Mà môn nãy giờ cô cũng thấy các bạn làm cái phần thế này. Là coi như bỏ qua phần này, nó nhảy cóc. Nó nhảy cóc là chấm điểm là mất điểm rồi. Nha, để ý nha. Đó rồi là chất lượng thông tin thu thập ở phía trên này. Các em mình nói rõ là à phương pháp thu thập thông tin là em thu thập như thế nào, em có đến tận nơi em thu thập hay không? Nhiều khi cũng chẳng cần phải đến tận nơi nhưng mà giả sử như trên mạng nó đã có sẵn cái thu thập nghiên cứu thì lấy. Đúng không? Hoặc là lấy từ yêu cầu người khác mình cũng phải lấy. Ờ chất lượng thông tin thu thập có tốt không? Có nghĩa là một số người lấy trên nền tảng. Ví dụ như người ta khảo sát a Ví dụ em làm cái hệ thống về tuyển dụng chẳng hạn. Thì trên đó họ cũng sẽ có nó là à khu vực nào hoặc là cái ngành nào tuyển lương cao nhất. Ví dụ về nó sẽ có cái thống kê đó. Thì mình cũng có quyền lấy cái thống kê đó để mình gọi là làm làm cái đầu vào cho mình hay là làm cái lý do cho mình. Ha. Ờ rồi hồi nãy các bạn có một cái slide, các bạn có cái là khó khăn, khó khăn trên rich trên Facebook đó là gì?\nNgười 1: Để đăng bài lên nếu mà cần đăng bài lên thì phải có những cái đó thì mới đăng bài.\nNgười 2: Cái đó là cái gì em chưa đẹp em mở lên cho cô coi em. Cái khó khăn đó.\nNgười 2: Rồi. Khó khăn của Facebook á rồi. À nếu caption giống nhau hoặc share nhiều lần Facebook Facebook có thể giảm rich hoặc chặn share. Vậy rich ở đây là cái gì?\nNgười 1: Giảm từ xem.\nNgười 2: À giảm từ xem. Lượt đề xuất. Ờ lượt đề xuất đúng rồi. Được tiếp cận đó đúng không? Hoặc là đó đó.\nNgười 2: Rồi, cái thứ hai nữa là nếu mà mình demo thì mình phải làm nhanh nhanh á. Chứ đừng có đến lúc đó bắt đầu ngồi gõ gõ.\nNgười 1: Demo.\nNgười 2: Chuẩn bị sẵn sàng ừ chuẩn bị sẵn sàng nội dung copy dán vô. Hoặc là chuẩn bị một cái clip, mình báo cáo bằng cái clip đó. Để sao? Để cho nó mướt. Rồi sau đó thầy cô mà hỏi thì bắt đầu mình mới mở lên cái cái nghiệp vụ này nọ lên. Không?\nNgười 1: Tính này đây nè.\nNgười 2: Và cái mà đắt nhất của hệ thống á thì mình lại chưa nêu. Có nghĩa là đầu tiên là mình phải nói lý do mình làm cái này. Nỗi đau của người người làm gì?\nNgười 1: Khách hàng nỗi đau.\nNgười 2: Đau khách hàng là gì? Do nên là mình đi khai thác khách hàng. Đau họ là gì?\nNgười 1: Đau. Không có nỗi đau.\nNgười 2: Thực sự là nông dân bây giờ hiện nay mà không biết chữ. Nông dân mà không biết chữ đó nhiều. Vậy thì bây giờ giả sử như nói là ôi bây giờ tôi có hàng đó tôi muốn bán đó nhưng mà tôi không biết chữ. Thực ra thì cũng nhiều nhưng mà cũng không quá nhiều nha.\nNgười 1: Làm biết gì cho nên.\nNgười 2: Thế thì bây giờ giả sử như tôi tôi đọc cái chợ đó. Giờ tôi muốn hỏi bây giờ có bấm cái nút bấm rồi tôi nói lại bài không?\nNgười 1: Nhóm nhóm em.\nNgười 2: Hiểu ý không? Đó, vậy vậy chứ mình lỡ không may nông dân người ta yêu cầu đó thì sao? Có nghĩa là các em chưa khảo sát kỹ cho nên là xem lại Epic. Các bước khảo sát như thế nào thế nào. Đó, phải đầy đủ. Đó, khi đó mấy cái điểm của rubric nó mới ăn được hết. Mà em khảo sát nó kỹ ở đây nè, có bảy, tám, chín chục người này nọ này nọ. Rồi mình kiếm là à tôi có đi khảo sát và tôi có phân tích thì ra như thế này, nó ra được 100 cái chức năng lận nhưng mà sau khi tụi em ngồi phân tích thảo luận brainstorm xong em chọn năm cái thôi, em chọn năm cái đắt nhất ra làm.\nNgười 2: Rồi cô cũng góp ý như vậy thôi. Thì các bạn xem cái slide của thầy Sơn gửi vô trong nhóm mà speech shot á không trình bày á thì cái slide này thì các em về phải sửa. Ít chữ thôi. Thầy nhiều.\nNgười 1: Nhưng mà mình có. Nhưng mà mình có khảo sát vườn đúng không? Mình khảo sát vườn.\nNgười 1: Chỉ là mình có đi khảo sát nhưng mà khảo sát môn thôi chứ không ghi lại thầy.\nNgười 2: Chụp hình. Nói to lên. Chụp hình. Cái em đi khảo sát bạn này nông dân, khảo sát mà khảo sát mùn ơi thì làm sao mà chứng minh? Chụp hình thôi. Đúng không? Ví dụ như tên ông này nông dân, em mà đi khảo sát chẳng hạn. Thì em đến ông nói nói thì lại đứng cho mình đi, em khảo sát.\nNgười 1: Dạ.\nNgười 2: Được chưa? Và trick cái câu nói nào đó của ông cư dân nông dân á. Trời ơi, các bạn chả biết tăng học, quay được cái clip càng tốt, đấy bấm lên lên thầy cô thầy Ờ đúng rồi trời ơi đúng là nỗi đau thiệt á. Đúng không? Giống như là dự báo đủ luôn đi chẳng hạn họ dự báo động đất, dự báo lở lở núi, lở đất ấy. Đó thì người ta mới đưa làm rộ rồi vô à đây nỗi đau, thực sự là nỗi đau thật của tất cả dân sách tỉnh thần. Thì đưa ra đâu bây giờ nếu mà dự báo được sớm báo cho họ để họ đi thì đó đó đó là giải quyết nỗi đau của mình. Cái gì mình cũng phải nói được cái vấn đề nỗi đau là cái gì. Thì đó giống như ngứa chỗ nào gãi đã vậy đó. Còn slide nha, slide làm vậy là được rồi đó. Biết sao không? Hình.\nNgười 1: Cái ảnh liên quan với nội dung.\nNgười 2: Cái này là AI làm đúng không?\nNgười 1: Nhóm em làm cho cái AI thẳng.\nNgười 2: Em tự làm hả?\nNgười 1: Chứ ra nhà đâu có hình.\nNgười 2: Hình nha là minh họa liên quan nha, hình không liên quan đừng để vô. Thầy này để nguyên để từ xưa đó. Rồi chữ ít thôi. Số đưa số lên ví dụ em nói là spam, em ghi là nội dung vậy đó nha, spam em ghi chữ spam thôi, anh em ghi từ khóa nha. Rồi nói chung là nếu mà mình ghi như vậy thì mình phải nhớ để chi mình lên nhìn từ khóa cái là mình biết nói cái gì. Nha.\nNgười 2: Ờ coi lại cái của thầy thầy Sơn thầy Sơn đâu rồi. Thầy có ý gì không?\nNgười 1: Có, nhiều.\nNgười 2: Này làm đi. Anh chấm này là hơi.\nNgười 2: Rồi. Bây giờ á là thầy chốt lại các ý như sau. Thứ nhất là phải bám vào Epic, cái quy trình Epic. Trả lời các câu hỏi của trong cái quy trình Epic, bước nào mình đã làm dưới dạng là thảo luận và trao đổi rồi thì cũng phải có cái cái phần tóm tắt ngắn ở trên cái slide dưới dạng hình ảnh.\nNgười 2: Thứ hai, thứ hai. Thầy không muốn mình lên đây mà báo cáo thuyết trình mà cứ rung rẩy cập nhật. Nhìn cái điện thoại đọc nói nhưng mà nó rung. Vậy thì cái team nhà này á là trong tuần này trước thứ bảy gửi cho thầy một video mấy đứa tự quay, tự quay mình. Ví dụ như thầy trình bày này, mình lấy điện thoại quay ở phòng này chứ không được chỗ khác. Rồi ha, rồi lựa sao đó là lựa. Quay làm sao đó mà thầy nghe được tiếng là được và thấy nó tự tin hơn. Rồi. Quay lại cái slide số sau số hai đi, số hai là slide gì nha? Bấm slide số hai. Rồi không phải. Rồi slide số ba đúng không? Rồi thay vì tiến độ hiện tại thì tụi em cho thầy một cái một cái cái cái gọi là timeline. Một cái timeline. Cái timeline của mình nó tới bao nhiêu phần trăm rồi? Nó tới giai đoạn nào rồi? Mình tự đánh giá coi. Đánh giá cái timeline này phụ thuộc vào rubric. Hôm nay lên đây thuyết trình thầy ơi em được ba điểm trong hai cái đó của rubric rồi.\nNgười 1: Được ý không?\nNgười 2: Được chưa? Tất cả các nhóm này không đâu nha các bạn. Được chưa? Thầy ơi hôm nay em lên đây em đứng em trình bày em đã hơn hôm trước cái này, không trình bày lại cái cũ. Nghe không? Rồi. Và cải thiện về việc bất kỳ buổi nào trình bày tiến độ đều phải là calavat. Ít nhất là áo ba lá, mặc áo trắng. Chuẩn bị ngay từ đầu đi. Chỉ có cái khác là cái ngày đi báo cáo tiến độ, báo cáo chính thức là phải calavat nữa. Người ta không hát, kệ người ta. Còn cái team nhà này phải hát. Ok không? Quy định nha. Quy định ha. Đi ăn cưới á. Áo vest lộn đi.\nNgười 1: Đi hỏi cưới.\nNgười 2: Đi hỏi bơi. Rồi.\nNgười 1: Chuẩn bị ngay từ đầu.\nNgười 2: Rồi. Ai chưa có calavat á thì tự sắm, không sắm được thầy sắm, thầy sắm thì ngày nào cũng có mang.\nNgười 1: Ngon lành.\nNgười 2: Rồi, thầy sắm luôn.\nNgười 1: Ngon lành luôn. Ngon lành.\nNgười 2: Rồi, nhớ ha. Phải đeo calavat vô cho thầy. Đó thể hiện tính chuyên nghiệp ai nói mình cái gì đó kệ nó, thầy không sống vì người khác. Thầy sống vì các bạn là ra là chuyên nghiệp lên. Được chưa? Nắm được cái slide của thầy thay hành cái đó chưa? Rồi. Quay về cái tấm hình thầy gửi trên Zalo. Thuyết trình là phải có điểm nhấn. Bây giờ điểm nhấn bài bỏ cái này. Thầy không biết các bạn khác có thấy hay không. Mấy bạn. Mấy ai?\nNgười 1: Mấy bạn.\nNgười 2: Ủa sao nãy em kêu mấy bạn?\nNgười 1: Mấy bạn nhưng mà Zalo của thầy.\nNgười 2: Không phải, không phải. Trong cái nhóm có chuyện ứng dụng á. Tắt đi.\nNgười 2: Rồi các bạn có thấy cái này thầy gửi trên lớp không? Có bao nhiêu bạn không có trong lớp? Cái này thầy gửi lâu rồi. Rồi chưa có thì vô, vô xong rồi tới hết môn học đi ra cũng được không sao hết nếu không thích. À.\nNgười 1: Cô chưa vô lớp hả?\nNgười 2: Không sao hết. Vậy thì giúp thầy Sơn ha. Rồi tự vô, tự vô nói rồi. Thì ở trong cái group này á thầy sẽ làm một cái thứ là thầy sẽ nhắc đi nhắc lại các cái kỹ năng mình. Nhắc đi nhắc lại các kỹ năng, nhắc đi nhắc lại các cái chuyện mà để các bạn sẽ phải phải thay đổi. Rồi. Riêng cái team nhà này á, cái team mà mô phát triển ứng dụng này nè. Phải tương tác cho thầy ít nhất là phải like hoặc là tim để thầy biết các bạn đã đọc. Về những cái vấn đề liên quan tới công nghệ, chắc chắn thầy sẽ push vào đây. Được chưa? Thứ hai về kỹ năng của mình. Kỹ năng trả lời, kỹ năng thuyết trình, kỹ năng trình bày sắp tới sẽ là những kỹ năng liên quan tới việc là thích ứng với cái câu hỏi. Thích ứng câu hỏi là sao? Bạn này bạn sẽ hỏi một câu chả liên quan gì tới đề tài của mình hết. Mình có chưng ngưng chưng gộ lên mình trả lời mình mình giải thích không? Đó, thì giờ mình sẽ thích ứng làm sao cho nó hợp lý, cho nó hợp lệ. Được chưa? Trong một môi trường học thuật, được không? Trong một môi trường để mình cùng nhau tiến bộ. Được chưa? Rồi. Vậy thầy nhắc lại đó là quy định của thầy trong cái group lát để thầy biết được rằng là các bạn có tương tác. Rồi. Có nắm qua nội dung. Rồi bây giờ giả sử như mình triển khai nội dung này trong cái bài của mình, các bạn biết cách chưa? Các bạn nhìn qua giúp thầy. Nhìn qua giúp thầy, hai hai bài này mới chưa biết. Để trình bày một cái nội dung á thì mình có thể bắt đầu bằng một ý tưởng lớn, kể một câu chuyện. Đó. Thì hôm trước thầy đã áp dụng cái số hai á, cái kể một câu chuyện mà thầy gặp với bà con nông dân cho mấy đứa nghe. Đúng không? Cái lúc mà mấy đứa bị bí cái cái cái cái ý tưởng. Đúng không? Sau khi thầy kể cái câu chuyện đó nó có lý do để chúng ta chúng ta làm và chúng ta bắt đầu. Rồi. Vậy nhớ ha, nhớ cái cách thầy áp dụng ha. Tất cả các bạn khác còn lại thì đảm bảo thầy sử dụng hết cái này. Thầy đảm bảo thầy sẽ đừng sử dụng hết cái này. Rồi. À thầy không nhận xét gì về chương trình của mình và định hướng phát triển của chương trình nữa bởi vì thầy sẽ làm tiếp bao nhiêu buổi khác. Em cho thầy cái kết quả của cái tờ giấy nãy giờ em nốt được á. Lên trên group, lên trên group của thầy với em á, chụp hình rồi thầy hết nhận xét. Rồi mời nhóm kế tiếp.', 'Ngôn ngữ của văn bản: Tiếng Việt.\n\n**Tóm tắt:**\nĐây là một buổi nhận xét về tiến độ và định hướng phát triển một dự án ứng dụng. Nhóm sinh viên đã trình bày demo về một ứng dụng cho phép đăng ký, tạo các mẫu thẻ (ví dụ: thẻ kinh nghiệm) từ ảnh hoặc văn bản, với tính năng lưu lịch sử mua thẻ cho người dùng đăng nhập.\n\nGiảng viên đã đưa ra nhiều góp ý quan trọng, tập trung vào các điểm chính sau:\n1.  **Mục đích dự án:** Cần làm rõ \"nỗi đau của khách hàng\" mà dự án giải quyết và sự khác biệt của sản phẩm so với các công cụ AI đã có trên thị trường. Giảng viên nhấn mạnh tầm quan trọng của việc khảo sát kỹ lưỡng các bên liên quan (nông dân, nhà marketing) và sản phẩm cạnh tranh để định vị giá trị của ứng dụng.\n2.  **Quy trình phát triển dự án:** Nhóm chưa tuân thủ đầy đủ các giai đoạn của quy trình EPIC (Nhập môn phát triển dự án kỹ thuật), đặc biệt là thiếu bước khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart (lưu đồ xử lý), và lược đồ cơ sở dữ liệu.\n3.  **Chất lượng trình bày & demo:** Yêu cầu cải thiện tên đề tài để rõ ràng hơn về mục đích, slide thuyết trình cần ít chữ và sử dụng hình ảnh minh họa liên quan; demo phải mượt mà, chuẩn bị sẵn sàng dữ liệu.\n4.  **Kỹ năng thuyết trình:** Nhóm cần luyện tập để tự tin, không đọc từ điện thoại; phải nộp video tự quay buổi trình bày và cập nhật timeline tiến độ dự án dựa trên rubric đánh giá.\n5.  **Chuẩn mực & Tương tác:** Yêu cầu chuẩn bị trang phục chuyên nghiệp (áo trắng, cà vạt) cho các buổi báo cáo. Giảng viên cũng yêu cầu các thành viên tích cực tương tác trên nhóm Zalo chung về các vấn đề công nghệ, kỹ năng thuyết trình, và cách thích ứng với câu hỏi để nâng cao trình độ chuyên môn và kỹ năng mềm. Giảng viên nhấn mạnh việc hiểu rõ các tiêu chí đánh giá (rubric) của môn học.'),
(2, 1, '\"122001281_BuiNgocSon_NguyenMinhSon.pdf\"', 'PDF', '2025-12-21 21:05:29', NULL, 'Đăng ký thuyết minh đề tài Học phần phát triển ứng dụng — O0O — 1.​ Thông tin sinh viên MSSV (Đại diện): 122001281 Họ và tên (Đại diện): Bùi Ngọc Sơn Danh sách sinh viên trong nhóm: STT MSSV Họ và tên Ký tên 01 122000860 Trần Trọng Thuận 02 122001281 Bùi Ngọc Sơn 2.​ Thông tin giáo viên hướng dẫn Họ và tên GV: Nguyễn Minh Sơn Điện thoại: 0946 734 111 Email: nmson@lhu.edu.vn 3.​ Tên dự án/ đề tài (dự kiến) thực hiện trong học phần Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu (giáo trình, ghi âm, bài báo) 4.​ Tóm tắt đề tài Đề tài “Hệ thống sinh câu hỏi trắc nghiệm” nhằm xây dựng một công cụ tự động có khả năng tóm tắt nội dung từ tài liệu, bài giảng hoặc ghi âm, sau đó sinh ra các câu hỏi trắc nghiệm gồm câu hỏi, đáp án đúng và các đáp án nhiễu. Hệ thống được ứng dụng trong giáo dục và doanh nghiệp, giúp giảng viên, quản lý hoặc người đào tạo nhanh chóng kiểm tra mức độ hiểu của người học hoặc nhân viên, đồng thời tiết kiệm thời gian soạn đề, nâng cao hiệu quả đánh giá và đào tạo. 5.​ Mục tiêu và kết quả mong đợi Mục tiêu của đề tài: ●​ Xây dựng AI agent có khả năng đọc – hiểu nội dung từ file PDF, DOCX hoặc file âm thanh. ●​ Sinh câu hỏi trắc nghiệm gồm câu hỏi, đáp án đúng và đáp án nhiễu. ●​ Ứng dụng được cho nhiều lĩnh vực: giáo dục, doanh nghiệp, đào tạo nội bộ, và nghiên cứu. ●​ Ứng dụng xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning để đảm bảo chất lượng câu hỏi. Tóm tắt và trích xuất ý chính của tài liệu một cách tự nhiên. Kết quả của đề tài: ●​ Hệ thống AI có khả năng xử lý nhanh, chính xác và sinh câu hỏi chất lượng cao. ●​ Web app thân thiện cho phép người dùng upload tài liệu hoặc ghi âm để sinh câu hỏi tự động. ●​ Lưu trữ và quản lý ngân hàng câu hỏi để tái sử dụng trong giảng dạy và đào tạo. ●​ Nâng cao hiệu quả học tập và đào tạo, giúp đánh giá nhanh, khách quan và chính xác. Hệ thống cho phép người dùng, ●​ Giảng viên: tạo đề nhanh, tiết kiệm thời gian, đánh giá mức độ tiếp thu của học sinh. ●​ Học sinh, sinh viên: ôn tập, luyện tập và tự kiểm tra kiến thức. ●​ Doanh nghiệp: kiểm tra mức độ hiểu của nhân viên sau các buổi họp hoặc đào tạo. ●​ Quản lý đào tạo: theo dõi, tổng hợp kết quả và cải thiện nội dung giảng dạy. 6.​ Kế hoạch thực hiện STT Nội dung thực hiện Thời gian Người thực hiện 01 Khảo sát & phân tích yêu cầu: Tìm hiểu các hệ thống AI tương tự (DeepSeek, ChatGPT, AutoQuiz AI); xác định yêu cầu đầu vào (file PDF, DOCX, audio) và đầu ra (summary + MCQ JSON). 1 tuần Từ ngày 30/09 đến ngày 7/10 Trần Trọng Thuận - Bùi Ngọc Sơn 02 Thiết kế kiến trúc tổng thể: Luồng xử lý giữa Web – Backend – DeepSeek API – DataBase; thiết kế ERD, DFD và luồng dữ liệu. 1 tuần Từ ngày 7/10 đến ngày 14/10 Trần Trọng Thuận - Bùi Ngọc Sơn 03 Xây dựng AI Agent tóm tắt nội dung: Tích hợp DeepSeek API để tóm tắt văn bản hoặc file âm thanh (qua Whisper / DeepSeek-Audio). Chuẩn hóa dữ liệu đầu vào. 1 tuần Từ ngày 14/10 đến ngày 21/10 Trần Trọng Thuận - Bùi Ngọc Sơn 04 Xây dựng AI Agent sinh câu hỏi: Sử dụng tóm tắt từ bước trước để sinh câu hỏi trắc nghiệm. Đảm bảo có 1 đáp đúng và 3 đáp nhiễu; định dạng JSON chuẩn. 1 tuần Từ ngày 21/10 đến ngày 28/10 Trần Trọng Thuận - Bùi Ngọc Sơn 05 Xây dựng hệ thống quản lý câu hỏi: Thêm, sửa, xóa, phân loại, export câu hỏi; hỗ trợ đa người dùng. 1 tuần Từ ngày 28/10 đến ngày 4/11 Trần Trọng Thuận - Bùi Ngọc Sơn 06 Phát triển giao diện web & API: Xây dựng giao diện upload tài liệu, hiển thị tóm tắt và câu hỏi; kết nối FastAPI backend với DeepSeek; hoàn thiện trải nghiệm người dùng. 1 tuần Từ ngày 4/11 đến ngày 11/11 Trần Trọng Thuận - Bùi Ngọc Sơn 07 Kiểm thử, tối ưu & bảo mật: Đánh giá chất lượng câu hỏi, tốc độ phản hồi API, xử lý tệp lớn, giới hạn request, ẩn API key, bảo mật dữ liệu người dùng. 1 tuần Từ ngày 11/11 đến ngày 18/11 Trần Trọng Thuận - Bùi Ngọc Sơn 08 Hoàn thiện và báo cáo: Viết báo cáo, làm slide thuyết trình, demo hệ thống AI quiz agent hoàn chỉnh. 1 tuần Từ ngày 18/11 đến ngày 25/11 Trần Trọng Thuận - Bùi Ngọc Sơn ​ ​ Đồng Nai, Ngày 09 tháng 10 năm 2025 GVHD​ Sinh viên đại diện​ ​ (Ký tên và ghi rõ họ tên)​ (Ký tên và ghi rõ họ tên) ​ ​ Bùi Ngọc Sơn', 'Ngôn ngữ của văn bản là **Tiếng Việt**.\n\n**Tóm tắt:**\n\nVăn bản này là đề xuất thuyết minh đề tài \"Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\" của nhóm sinh viên Bùi Ngọc Sơn và Trần Trọng Thuận, dưới sự hướng dẫn của GV Nguyễn Minh Sơn.\n\nĐề tài nhằm xây dựng một hệ thống AI có khả năng tóm tắt nội dung từ các loại tài liệu khác nhau (PDF, DOCX, âm thanh) và tự động sinh ra các câu hỏi trắc nghiệm chất lượng cao, bao gồm câu hỏi, đáp án đúng và các đáp án nhiễu. Hệ thống sẽ ứng dụng xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning, tích hợp các API như DeepSeek, Whisper/DeepSeek-Audio.\n\nMục tiêu chính là tạo ra một web app thân thiện, đa năng, có thể áp dụng rộng rãi trong giáo dục (hỗ trợ giảng viên tạo đề, học sinh ôn tập) và doanh nghiệp (đánh giá mức độ hiểu của nhân viên, quản lý đào tạo). Kết quả mong đợi là một công cụ giúp tiết kiệm thời gian soạn đề, nâng cao hiệu quả đánh giá và đào tạo, đồng thời cho phép lưu trữ và quản lý ngân hàng câu hỏi.\n\nKế hoạch thực hiện đề tài dự kiến kéo dài 8 tuần, bao gồm các giai đoạn từ khảo sát, thiết kế kiến trúc, xây dựng các AI Agent (tóm tắt nội dung, sinh câu hỏi), phát triển hệ thống quản lý và giao diện web, đến kiểm thử, tối ưu và báo cáo hoàn chỉnh.'),
(3, 1, '\"122001281_BuiNgocSon_NguyenMinhSon.pdf\"', 'PDF', '2025-12-22 14:20:19', NULL, 'Đăng ký thuyết minh đề tài Học phần phát triển ứng dụng — O0O — 1.​ Thông tin sinh viên MSSV (Đại diện): 122001281 Họ và tên (Đại diện): Bùi Ngọc Sơn Danh sách sinh viên trong nhóm: STT MSSV Họ và tên Ký tên 01 122000860 Trần Trọng Thuận 02 122001281 Bùi Ngọc Sơn 2.​ Thông tin giáo viên hướng dẫn Họ và tên GV: Nguyễn Minh Sơn Điện thoại: 0946 734 111 Email: nmson@lhu.edu.vn 3.​ Tên dự án/ đề tài (dự kiến) thực hiện trong học phần Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu (giáo trình, ghi âm, bài báo) 4.​ Tóm tắt đề tài Đề tài “Hệ thống sinh câu hỏi trắc nghiệm” nhằm xây dựng một công cụ tự động có khả năng tóm tắt nội dung từ tài liệu, bài giảng hoặc ghi âm, sau đó sinh ra các câu hỏi trắc nghiệm gồm câu hỏi, đáp án đúng và các đáp án nhiễu. Hệ thống được ứng dụng trong giáo dục và doanh nghiệp, giúp giảng viên, quản lý hoặc người đào tạo nhanh chóng kiểm tra mức độ hiểu của người học hoặc nhân viên, đồng thời tiết kiệm thời gian soạn đề, nâng cao hiệu quả đánh giá và đào tạo. 5.​ Mục tiêu và kết quả mong đợi Mục tiêu của đề tài: ●​ Xây dựng AI agent có khả năng đọc – hiểu nội dung từ file PDF, DOCX hoặc file âm thanh. ●​ Sinh câu hỏi trắc nghiệm gồm câu hỏi, đáp án đúng và đáp án nhiễu. ●​ Ứng dụng được cho nhiều lĩnh vực: giáo dục, doanh nghiệp, đào tạo nội bộ, và nghiên cứu. ●​ Ứng dụng xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning để đảm bảo chất lượng câu hỏi. Tóm tắt và trích xuất ý chính của tài liệu một cách tự nhiên. Kết quả của đề tài: ●​ Hệ thống AI có khả năng xử lý nhanh, chính xác và sinh câu hỏi chất lượng cao. ●​ Web app thân thiện cho phép người dùng upload tài liệu hoặc ghi âm để sinh câu hỏi tự động. ●​ Lưu trữ và quản lý ngân hàng câu hỏi để tái sử dụng trong giảng dạy và đào tạo. ●​ Nâng cao hiệu quả học tập và đào tạo, giúp đánh giá nhanh, khách quan và chính xác. Hệ thống cho phép người dùng, ●​ Giảng viên: tạo đề nhanh, tiết kiệm thời gian, đánh giá mức độ tiếp thu của học sinh. ●​ Học sinh, sinh viên: ôn tập, luyện tập và tự kiểm tra kiến thức. ●​ Doanh nghiệp: kiểm tra mức độ hiểu của nhân viên sau các buổi họp hoặc đào tạo. ●​ Quản lý đào tạo: theo dõi, tổng hợp kết quả và cải thiện nội dung giảng dạy. 6.​ Kế hoạch thực hiện STT Nội dung thực hiện Thời gian Người thực hiện 01 Khảo sát & phân tích yêu cầu: Tìm hiểu các hệ thống AI tương tự (DeepSeek, ChatGPT, AutoQuiz AI); xác định yêu cầu đầu vào (file PDF, DOCX, audio) và đầu ra (summary + MCQ JSON). 1 tuần Từ ngày 30/09 đến ngày 7/10 Trần Trọng Thuận - Bùi Ngọc Sơn 02 Thiết kế kiến trúc tổng thể: Luồng xử lý giữa Web – Backend – DeepSeek API – DataBase; thiết kế ERD, DFD và luồng dữ liệu. 1 tuần Từ ngày 7/10 đến ngày 14/10 Trần Trọng Thuận - Bùi Ngọc Sơn 03 Xây dựng AI Agent tóm tắt nội dung: Tích hợp DeepSeek API để tóm tắt văn bản hoặc file âm thanh (qua Whisper / DeepSeek-Audio). Chuẩn hóa dữ liệu đầu vào. 1 tuần Từ ngày 14/10 đến ngày 21/10 Trần Trọng Thuận - Bùi Ngọc Sơn 04 Xây dựng AI Agent sinh câu hỏi: Sử dụng tóm tắt từ bước trước để sinh câu hỏi trắc nghiệm. Đảm bảo có 1 đáp đúng và 3 đáp nhiễu; định dạng JSON chuẩn. 1 tuần Từ ngày 21/10 đến ngày 28/10 Trần Trọng Thuận - Bùi Ngọc Sơn 05 Xây dựng hệ thống quản lý câu hỏi: Thêm, sửa, xóa, phân loại, export câu hỏi; hỗ trợ đa người dùng. 1 tuần Từ ngày 28/10 đến ngày 4/11 Trần Trọng Thuận - Bùi Ngọc Sơn 06 Phát triển giao diện web & API: Xây dựng giao diện upload tài liệu, hiển thị tóm tắt và câu hỏi; kết nối FastAPI backend với DeepSeek; hoàn thiện trải nghiệm người dùng. 1 tuần Từ ngày 4/11 đến ngày 11/11 Trần Trọng Thuận - Bùi Ngọc Sơn 07 Kiểm thử, tối ưu & bảo mật: Đánh giá chất lượng câu hỏi, tốc độ phản hồi API, xử lý tệp lớn, giới hạn request, ẩn API key, bảo mật dữ liệu người dùng. 1 tuần Từ ngày 11/11 đến ngày 18/11 Trần Trọng Thuận - Bùi Ngọc Sơn 08 Hoàn thiện và báo cáo: Viết báo cáo, làm slide thuyết trình, demo hệ thống AI quiz agent hoàn chỉnh. 1 tuần Từ ngày 18/11 đến ngày 25/11 Trần Trọng Thuận - Bùi Ngọc Sơn ​ ​ Đồng Nai, Ngày 09 tháng 10 năm 2025 GVHD​ Sinh viên đại diện​ ​ (Ký tên và ghi rõ họ tên)​ (Ký tên và ghi rõ họ tên) ​ ​ Bùi Ngọc Sơn', 'Ngôn ngữ của văn bản là **Tiếng Việt**.\n\n**Bản tóm tắt:**\n\nVăn bản là một bản đăng ký thuyết minh đề tài học phần \"Phát triển ứng dụng\" của nhóm sinh viên Bùi Ngọc Sơn (đại diện) và Trần Trọng Thuận, dưới sự hướng dẫn của GV Nguyễn Minh Sơn. Đề tài có tên \"Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\".\n\nMục tiêu chính của đề tài là xây dựng một hệ thống AI (AI agent) có khả năng đọc – hiểu và tóm tắt nội dung từ các loại tài liệu khác nhau (PDF, DOCX, file âm thanh), sau đó tự động sinh ra các câu hỏi trắc nghiệm hoàn chỉnh, bao gồm câu hỏi, đáp án đúng và các đáp án nhiễu. Hệ thống sẽ ứng dụng các công nghệ xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning để đảm bảo chất lượng câu hỏi.\n\nKết quả mong đợi là một ứng dụng web thân thiện, cho phép người dùng tải lên tài liệu để sinh câu hỏi tự động, đồng thời lưu trữ và quản lý ngân hàng câu hỏi. Ứng dụng này được kỳ vọng sẽ nâng cao hiệu quả học tập và đào tạo, mang lại lợi ích cho nhiều đối tượng như giảng viên (tạo đề nhanh), học sinh/sinh viên (ôn tập), doanh nghiệp (kiểm tra nhân viên) và quản lý đào tạo (theo dõi, cải thiện nội dung). Kế hoạch thực hiện chi tiết trong 8 tuần, bao gồm các giai đoạn từ khảo sát yêu cầu, thiết kế kiến trúc, xây dựng AI agent tóm tắt và sinh câu hỏi, phát triển giao diện web, đến kiểm thử và hoàn thiện báo cáo.');

-- --------------------------------------------------------

--
-- Table structure for table `QuestionEvaluations`
--

CREATE TABLE `QuestionEvaluations` (
  `evaluation_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `model_version` varchar(100) NOT NULL,
  `evaluated_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `total_score` int(11) NOT NULL,
  `accuracy_score` int(11) DEFAULT 0,
  `alignment_score` int(11) DEFAULT 0,
  `distractors_score` int(11) DEFAULT 0,
  `clarity_score` int(11) DEFAULT 0,
  `status_by_agent` varchar(20) DEFAULT 'need_review',
  `raw_response_json` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `QuestionEvaluations`
--

INSERT INTO `QuestionEvaluations` (`evaluation_id`, `question_id`, `model_version`, `evaluated_at`, `updated_at`, `total_score`, `accuracy_score`, `alignment_score`, `distractors_score`, `clarity_score`, `status_by_agent`, `raw_response_json`) VALUES
(1, 1, 'gemini-2.5-flash', '2025-11-13 10:12:32', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Giảng viên đã đưa ra nhiều góp ý quan trọng, tập trung vào các điểm chính sau: 1. Mục đích dự án: Cần làm rõ \\\"nỗi đau của khách hàng\\\" mà dự án giải quyết và sự khác biệt của sản phẩm so với các công cụ AI đã có trên thị trường.\", \"question\": \"Theo góp ý của giảng viên về mục đích dự án, điều đầu tiên nhóm sinh viên cần làm rõ là gì?\", \"options\": [\"A. Tính năng độc đáo của ứng dụng.\", \"B. \\\"Nỗi đau của khách hàng\\\" mà dự án giải quyết.\", \"C. Khả năng tương thích với các hệ điều hành khác.\", \"D. Chi phí phát triển sản phẩm.\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(2, 2, 'gemini-2.5-flash', '2025-11-13 10:12:32', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Giảng viên nhấn mạnh tầm quan trọng của việc khảo sát kỹ lưỡng các bên liên quan (nông dân, nhà marketing) và sản phẩm cạnh tranh để định vị giá trị của ứng dụng.\", \"question\": \"Để định vị giá trị của ứng dụng, giảng viên yêu cầu nhóm sinh viên khảo sát kỹ lưỡng những đối tượng nào?\", \"options\": [\"A. Các nhà đầu tư tiềm năng và đối tác công nghệ.\", \"B. Các chuyên gia AI và kỹ sư phần mềm.\", \"C. Các bên liên quan như nông dân, nhà marketing và sản phẩm cạnh tranh.\", \"D. Người dùng cuối cùng và các nhà phân phối sản phẩm.\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(3, 3, 'gemini-2.5-flash', '2025-11-13 10:12:32', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Quy trình phát triển dự án: Nhóm chưa tuân thủ đầy đủ các giai đoạn của quy trình EPIC (Nhập môn phát triển dự án kỹ thuật), đặc biệt là thiếu bước khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart (lưu đồ xử lý), và lược đồ cơ sở dữ liệu.\", \"question\": \"Theo giảng viên, nhóm sinh viên chưa tuân thủ đầy đủ các giai đoạn nào trong quy trình EPIC?\", \"options\": [\"A. Giai đoạn triển khai và kiểm thử hệ thống.\", \"B. Giai đoạn bảo trì và nâng cấp sản phẩm.\", \"C. Giai đoạn khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart, và lược đồ cơ sở dữ liệu.\", \"D. Giai đoạn trình bày demo và thu thập phản hồi người dùng.\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(4, 4, 'gemini-2.5-flash', '2025-11-13 10:12:33', NULL, 98, 50, 25, 18, 5, 'accepted', '{\"context\": \"Chất lượng trình bày & demo: Yêu cầu cải thiện tên đề tài để rõ ràng hơn về mục đích, slide thuyết trình cần ít chữ và sử dụng hình ảnh minh họa liên quan; demo phải mượt mà, chuẩn bị sẵn sàng dữ liệu.\", \"question\": \"Về chất lượng trình bày, giảng viên yêu cầu nhóm sinh viên cải thiện những điểm nào đối với slide thuyết trình?\", \"options\": [\"A. Tăng cường số lượng chữ trên slide và sử dụng nhiều hiệu ứng động.\", \"B. Giảm bớt số lượng hình ảnh và tập trung vào văn bản chi tiết.\", \"C. Slide cần ít chữ và sử dụng hình ảnh minh họa liên quan.\", \"D. Slide phải có nhiều biểu đồ và bảng số liệu phức tạp.\"], \"answer_letter\": \"C\", \"score\": 98, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 18, \"clarity\": 5}}'),
(5, 5, 'gemini-2.5-flash', '2025-11-13 10:12:33', NULL, 95, 49, 25, 17, 4, 'accepted', '{\"context\": \"Chất lượng trình bày & demo: Yêu cầu cải thiện tên đề tài để rõ ràng hơn về mục đích, slide thuyết trình cần ít chữ và sử dụng hình ảnh minh họa liên quan; demo phải mượt mà, chuẩn bị sẵn sàng dữ liệu.\", \"question\": \"Để đảm bảo chất lượng buổi demo, giảng viên yêu cầu những gì?\", \"options\": [\"A. Demo cần nhanh chóng và có nhiều tính năng mới.\", \"B. Demo phải mượt mà và chuẩn bị sẵn sàng dữ liệu.\", \"C. Demo chỉ cần thể hiện ý tưởng, không cần chạy thật.\", \"D. Demo phải được thực hiện bởi thành viên giỏi nhất nhóm.\"], \"answer_letter\": \"B\", \"score\": 95, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 49, \"alignment\": 25, \"distractors\": 17, \"clarity\": 4}}'),
(6, 6, 'gemini-2.5-flash', '2025-11-13 10:12:34', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Giảng viên đã đưa ra nhiều góp ý quan trọng, tập trung vào các điểm chính sau: 1. Mục đích dự án: Cần làm rõ \\\"nỗi đau của khách hàng\\\" mà dự án giải quyết và sự khác biệt của sản phẩm so với các công cụ AI đã có trên thị trường.\", \"question\": \"Theo góp ý của giảng viên về mục đích dự án, điều đầu tiên nhóm sinh viên cần làm rõ là gì?\", \"options\": [\"A. Tính năng độc đáo của ứng dụng.\", \"B. \\\"Nỗi đau của khách hàng\\\" mà dự án giải quyết.\", \"C. Khả năng tương thích với các hệ điều hành khác.\", \"D. Chi phí phát triển sản phẩm.\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(7, 7, 'gemini-2.5-flash', '2025-11-13 10:12:34', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Giảng viên nhấn mạnh tầm quan trọng của việc khảo sát kỹ lưỡng các bên liên quan (nông dân, nhà marketing) và sản phẩm cạnh tranh để định vị giá trị của ứng dụng.\", \"question\": \"Để định vị giá trị của ứng dụng, giảng viên yêu cầu nhóm sinh viên khảo sát kỹ lưỡng những đối tượng nào?\", \"options\": [\"A. Các nhà đầu tư tiềm năng và đối tác công nghệ.\", \"B. Các chuyên gia AI và kỹ sư phần mềm.\", \"C. Các bên liên quan như nông dân, nhà marketing và sản phẩm cạnh tranh.\", \"D. Người dùng cuối cùng và các nhà phân phối sản phẩm.\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(8, 8, 'gemini-2.5-flash', '2025-11-13 10:12:34', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Quy trình phát triển dự án: Nhóm chưa tuân thủ đầy đủ các giai đoạn của quy trình EPIC (Nhập môn phát triển dự án kỹ thuật), đặc biệt là thiếu bước khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart (lưu đồ xử lý), và lược đồ cơ sở dữ liệu.\", \"question\": \"Theo giảng viên, nhóm sinh viên chưa tuân thủ đầy đủ các giai đoạn nào trong quy trình EPIC?\", \"options\": [\"A. Giai đoạn triển khai và kiểm thử hệ thống.\", \"B. Giai đoạn bảo trì và nâng cấp sản phẩm.\", \"C. Giai đoạn khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart, và lược đồ cơ sở dữ liệu.\", \"D. Giai đoạn trình bày demo và thu thập phản hồi người dùng.\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(9, 9, 'gemini-2.5-flash', '2025-11-13 10:12:35', NULL, 98, 50, 25, 18, 5, 'accepted', '{\"context\": \"Chất lượng trình bày & demo: Yêu cầu cải thiện tên đề tài để rõ ràng hơn về mục đích, slide thuyết trình cần ít chữ và sử dụng hình ảnh minh họa liên quan; demo phải mượt mà, chuẩn bị sẵn sàng dữ liệu.\", \"question\": \"Về chất lượng trình bày, giảng viên yêu cầu nhóm sinh viên cải thiện những điểm nào đối với slide thuyết trình?\", \"options\": [\"A. Tăng cường số lượng chữ trên slide và sử dụng nhiều hiệu ứng động.\", \"B. Giảm bớt số lượng hình ảnh và tập trung vào văn bản chi tiết.\", \"C. Slide cần ít chữ và sử dụng hình ảnh minh họa liên quan.\", \"D. Slide phải có nhiều biểu đồ và bảng số liệu phức tạp.\"], \"answer_letter\": \"C\", \"score\": 98, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 18, \"clarity\": 5}}'),
(10, 10, 'gemini-2.5-flash', '2025-11-13 10:12:35', NULL, 95, 49, 25, 17, 4, 'accepted', '{\"context\": \"Chất lượng trình bày & demo: Yêu cầu cải thiện tên đề tài để rõ ràng hơn về mục đích, slide thuyết trình cần ít chữ và sử dụng hình ảnh minh họa liên quan; demo phải mượt mà, chuẩn bị sẵn sàng dữ liệu.\", \"question\": \"Để đảm bảo chất lượng buổi demo, giảng viên yêu cầu những gì?\", \"options\": [\"A. Demo cần nhanh chóng và có nhiều tính năng mới.\", \"B. Demo phải mượt mà và chuẩn bị sẵn sàng dữ liệu.\", \"C. Demo chỉ cần thể hiện ý tưởng, không cần chạy thật.\", \"D. Demo phải được thực hiện bởi thành viên giỏi nhất nhóm.\"], \"answer_letter\": \"B\", \"score\": 95, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 49, \"alignment\": 25, \"distractors\": 17, \"clarity\": 4}}'),
(11, 11, 'gemini-2.5-flash', '2025-12-21 21:05:30', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Văn bản này là đề xuất thuyết minh đề tài \\\"Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\\\" của nhóm sinh viên Bùi Ngọc Sơn và Trần Trọng Thuận, dưới sự hướng dẫn của GV Nguyễn Minh Sơn.\", \"question\": \"Đề tài \\\"Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\\\" được đề xuất bởi những sinh viên nào?\", \"options\": [\"A. Bùi Minh Sơn và Nguyễn Trọng Thuận\", \"B. Bùi Ngọc Sơn và Trần Trọng Thuận\", \"C. Nguyễn Minh Sơn và Bùi Ngọc Sơn\", \"D. qjbriqbưiebq\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(12, 12, 'gemini-2.5-flash', '2025-12-21 21:05:30', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Đề tài nhằm xây dựng một hệ thống AI có khả năng tóm tắt nội dung từ các loại tài liệu khác nhau (PDF, DOCX, âm thanh) và tự động sinh ra các câu hỏi trắc nghiệm chất lượng cao, bao gồm câu hỏi, đáp án đúng và các đáp án nhiễu.\", \"question\": \"Chức năng cốt lõi của hệ thống AI được đề xuất là gì?\", \"options\": [\"A. Quản lý tài liệu và lưu trữ dữ liệu người dùng.\", \"B. Tóm tắt nội dung và tự động sinh câu hỏi trắc nghiệm.\", \"C. Phát triển giao diện người dùng và tích hợp API.\", \"D. Phân tích hiệu suất học tập của học sinh.\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(13, 13, 'gemini-2.5-flash', '2025-12-21 21:05:30', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Hệ thống sẽ ứng dụng xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning, tích hợp các API như DeepSeek, Whisper/DeepSeek-Audio.\", \"question\": \"Các công nghệ và API chính được dự kiến sử dụng trong hệ thống này là gì?\", \"options\": [\"A. Blockchain và Cryptography, API ChatGPT.\", \"B. Xử lý ngôn ngữ tự nhiên (NLP), Machine Learning, API DeepSeek và Whisper/DeepSeek-Audio.\", \"C. Phân tích dữ liệu lớn và Điện toán đám mây, API Google Maps.\", \"D. Lập trình nhúng và Thị giác máy tính, API AWS.\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(14, 14, 'gemini-2.5-flash', '2025-12-21 21:05:31', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Mục tiêu chính là tạo ra một web app thân thiện, đa năng, có thể áp dụng rộng rãi trong giáo dục (hỗ trợ giảng viên tạo đề, học sinh ôn tập) và doanh nghiệp (đánh giá mức độ hiểu của nhân viên, quản lý đào tạo).\", \"question\": \"Hệ thống web app được đề xuất có thể áp dụng rộng rãi trong những lĩnh vực nào?\", \"options\": [\"A. Y tế và Du lịch.\", \"B. Tài chính và Ngân hàng.\", \"C. Giáo dục và Doanh nghiệp.\", \"D. Sản xuất và Logistics.\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(15, 15, 'gemini-2.5-flash', '2025-12-21 21:05:31', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Kế hoạch thực hiện đề tài dự kiến kéo dài 8 tuần, bao gồm các giai đoạn từ khảo sát, thiết kế kiến trúc, xây dựng các AI Agent (tóm tắt nội dung, sinh câu hỏi), phát triển hệ thống quản lý và giao diện web, đến kiểm thử, tối ưu và báo cáo hoàn chỉnh.\", \"question\": \"Thời gian dự kiến để thực hiện đề tài này là bao lâu?\", \"options\": [\"A. 4 tuần\", \"B. 6 tuần\", \"C. 8 tuần\", \"D. 12 tuần\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(16, 16, 'gemini-2.5-flash', '2025-12-22 14:20:19', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Đề tài có tên \\\"Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\\\".\", \"question\": \"Tên đề tài học phần của ndandưqd\", \"options\": [\"A. Ứng dụng AI tóm tắt tài liệu\", \"B. Hệ thống quản lý ngân hàng câu hỏi\", \"C. Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\", \"D. Phát triển ứng dụng Web học tập\", \"E. Giải pháp số hóa tài liệu\"], \"answer_letter\": \"A\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(17, 17, 'gemini-2.5-flash', '2025-12-22 14:20:19', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Mục tiêu chính của đề tài là xây dựng một hệ thống AI (AI agent) có khả năng đọc – hiểu và tóm tắt nội dung từ các loại tài liệu khác nhau (PDF, DOCX, file âm thanh), sau đó tự động sinh ra các câu hỏi trắc nghiệm hoàn chỉnh, bao gồm câu hỏi, đáp án đúng và các đáp án nhiễu.\", \"question\": \"Chức năng chính của hệ thống AI (AI agent) mà đề tài hướng tới là gì?\", \"options\": [\"A. Quản lý và lưu trữ tài liệu học tập\", \"B. Đọc – hiểu, tóm tắt nội dung và tự động sinh câu hỏi trắc nghiệm\", \"C. Dịch tự động tài liệu sang nhiều ngôn ngữ\", \"D. Tạo slide thuyết trình từ tài liệu\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(18, 18, 'gemini-2.5-flash', '2025-12-22 14:20:20', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Mục tiêu chính của đề tài là xây dựng một hệ thống AI (AI agent) có khả năng đọc – hiểu và tóm tắt nội dung từ các loại tài liệu khác nhau (PDF, DOCX, file âm thanh), sau đó tự động sinh ra các câu hỏi trắc nghiệm hoàn chỉnh, bao gồm câu hỏi, đáp án đúng và các đáp án nhiễu.\", \"question\": \"Hệ thống AI của đề tài được thiết kế để xử lý những loại tài liệu nào?\", \"options\": [\"A. PDF, DOCX và video\", \"B. PDF, DOCX và file âm thanh\", \"C. TXT, CSV và file hình ảnh\", \"D. HTML, XML và file bảng tính\"], \"answer_letter\": \"B\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(19, 19, 'gemini-2.5-flash', '2025-12-22 14:20:20', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Hệ thống sẽ ứng dụng các công nghệ xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning để đảm bảo chất lượng câu hỏi.\", \"question\": \"Những công nghệ chính nào được ứng dụng để đảm bảo chất lượng câu hỏi trong hệ thống?\", \"options\": [\"A. Xử lý ảnh và Big Data\", \"B. Blockchain và Điện toán đám mây\", \"C. Xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning\", \"D. Khoa học dữ liệu và Phát triển web front-end\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}'),
(20, 20, 'gemini-2.5-flash', '2025-12-22 14:20:20', NULL, 100, 50, 25, 20, 5, 'accepted', '{\"context\": \"Ứng dụng này được kỳ vọng sẽ nâng cao hiệu quả học tập và đào tạo, mang lại lợi ích cho nhiều đối tượng như giảng viên (tạo đề nhanh), học sinh/sinh viên (ôn tập), doanh nghiệp (kiểm tra nhân viên) và quản lý đào tạo (theo dõi, cải thiện nội dung).\", \"question\": \"Đối tượng nào KHÔNG được đề cập là sẽ hưởng lợi từ ứng dụng web này?\", \"options\": [\"A. Giảng viên\", \"B. Học sinh/sinh viên\", \"C. Nhà phát triển phần mềm\", \"D. Doanh nghiệp\"], \"answer_letter\": \"C\", \"score\": 100, \"status\": \"accepted\", \"_eval_breakdown\": {\"accuracy\": 50, \"alignment\": 25, \"distractors\": 20, \"clarity\": 5}}');

-- --------------------------------------------------------

--
-- Table structure for table `Questions`
--

CREATE TABLE `Questions` (
  `question_id` int(11) NOT NULL,
  `source_file_id` int(11) DEFAULT NULL,
  `creator_id` int(11) DEFAULT NULL,
  `latest_evaluation_id` int(11) DEFAULT NULL,
  `question_text` longtext NOT NULL,
  `options` longtext NOT NULL,
  `answer_letter` char(1) NOT NULL,
  `status` varchar(20) DEFAULT 'TEMP',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `Questions`
--

INSERT INTO `Questions` (`question_id`, `source_file_id`, `creator_id`, `latest_evaluation_id`, `question_text`, `options`, `answer_letter`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '\"Theo góp ý của giảng viên về mục đích dự án, điều đầu tiên nhóm sinh viên cần làm rõ là gì?\"', '[\"A. Tính năng độc đáo của ứng dụng.\", \"B. \\\"Nỗi đau của khách hàng\\\" mà dự án giải quyết.\", \"C. Khả năng tương thích với các hệ điều hành khác.\", \"D. Chi phí phát triển sản phẩm.\"]', 'B', 'accepted', '2025-11-13 10:12:32', NULL),
(2, 1, 1, 2, '\"Để định vị giá trị của ứng dụng, giảng viên yêu cầu nhóm sinh viên khảo sát kỹ lưỡng những đối tượng nào?\"', '[\"A. Các nhà đầu tư tiềm năng và đối tác công nghệ.\", \"B. Các chuyên gia AI và kỹ sư phần mềm.\", \"C. Các bên liên quan như nông dân, nhà marketing và sản phẩm cạnh tranh.\", \"D. Người dùng cuối cùng và các nhà phân phối sản phẩm.\"]', 'C', 'accepted', '2025-11-13 10:12:32', NULL),
(3, 1, 1, 3, '\"Theo giảng viên, nhóm sinh viên chưa tuân thủ đầy đủ các giai đoạn nào trong quy trình EPIC?\"', '[\"A. Giai đoạn triển khai và kiểm thử hệ thống.\", \"B. Giai đoạn bảo trì và nâng cấp sản phẩm.\", \"C. Giai đoạn khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart, và lược đồ cơ sở dữ liệu.\", \"D. Giai đoạn trình bày demo và thu thập phản hồi người dùng.\"]', 'C', 'accepted', '2025-11-13 10:12:32', NULL),
(4, 1, 1, 4, '\"Về chất lượng trình bày, giảng viên yêu cầu nhóm sinh viên cải thiện những điểm nào đối với slide thuyết trình?\"', '[\"A. Tăng cường số lượng chữ trên slide và sử dụng nhiều hiệu ứng động.\", \"B. Giảm bớt số lượng hình ảnh và tập trung vào văn bản chi tiết.\", \"C. Slide cần ít chữ và sử dụng hình ảnh minh họa liên quan.\", \"D. Slide phải có nhiều biểu đồ và bảng số liệu phức tạp.\"]', 'C', 'accepted', '2025-11-13 10:12:33', NULL),
(5, 1, 1, 5, '\"Để đảm bảo chất lượng buổi demo, giảng viên yêu cầu những gì?\"', '[\"A. Demo cần nhanh chóng và có nhiều tính năng mới.\", \"B. Demo phải mượt mà và chuẩn bị sẵn sàng dữ liệu.\", \"C. Demo chỉ cần thể hiện ý tưởng, không cần chạy thật.\", \"D. Demo phải được thực hiện bởi thành viên giỏi nhất nhóm.\"]', 'B', 'accepted', '2025-11-13 10:12:33', NULL),
(6, 1, 1, 6, '\"Theo góp ý của giảng viên về mục đích dự án, điều đầu tiên nhóm sinh viên cần làm rõ là gì?\"', '[\"A. Tính năng độc đáo của ứng dụng.\", \"B. \\\"Nỗi đau của khách hàng\\\" mà dự án giải quyết.\", \"C. Khả năng tương thích với các hệ điều hành khác.\", \"D. Chi phí phát triển sản phẩm.\"]', 'B', 'accepted', '2025-11-13 10:12:34', NULL),
(7, 1, 1, 7, '\"Để định vị giá trị của ứng dụng, giảng viên yêu cầu nhóm sinh viên khảo sát kỹ lưỡng những đối tượng nào?\"', '[\"A. Các nhà đầu tư tiềm năng và đối tác công nghệ.\", \"B. Các chuyên gia AI và kỹ sư phần mềm.\", \"C. Các bên liên quan như nông dân, nhà marketing và sản phẩm cạnh tranh.\", \"D. Người dùng cuối cùng và các nhà phân phối sản phẩm.\"]', 'C', 'accepted', '2025-11-13 10:12:34', NULL),
(8, 1, 1, 8, '\"Theo giảng viên, nhóm sinh viên chưa tuân thủ đầy đủ các giai đoạn nào trong quy trình EPIC?\"', '[\"A. Giai đoạn triển khai và kiểm thử hệ thống.\", \"B. Giai đoạn bảo trì và nâng cấp sản phẩm.\", \"C. Giai đoạn khảo sát, phân tích bài toán, thiết kế hệ thống, flowchart, và lược đồ cơ sở dữ liệu.\", \"D. Giai đoạn trình bày demo và thu thập phản hồi người dùng.\"]', 'C', 'accepted', '2025-11-13 10:12:34', NULL),
(9, 1, 1, 9, '\"Về chất lượng trình bày, giảng viên yêu cầu nhóm sinh viên cải thiện những điểm nào đối với slide thuyết trình?\"', '[\"A. Tăng cường số lượng chữ trên slide và sử dụng nhiều hiệu ứng động.\", \"B. Giảm bớt số lượng hình ảnh và tập trung vào văn bản chi tiết.\", \"C. Slide cần ít chữ và sử dụng hình ảnh minh họa liên quan.\", \"D. Slide phải có nhiều biểu đồ và bảng số liệu phức tạp.\"]', 'C', 'accepted', '2025-11-13 10:12:35', NULL),
(10, 1, 1, 10, '\"Để đảm bảo chất lượng buổi demo, giảng viên yêu cầu những gì?\"', '[\"A. Demo cần nhanh chóng và có nhiều tính năng mới.\", \"B. Demo phải mượt mà và chuẩn bị sẵn sàng dữ liệu.\", \"C. Demo chỉ cần thể hiện ý tưởng, không cần chạy thật.\", \"D. Demo phải được thực hiện bởi thành viên giỏi nhất nhóm.\"]', 'B', 'accepted', '2025-11-13 10:12:35', NULL),
(11, 2, 1, 11, '\"Đề tài \\\"Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\\\" được đề xuất bởi những sinh viên nào?\"', '[\"A. Bùi Minh Sơn và Nguyễn Trọng Thuận\", \"B. Bùi Ngọc Sơn và Trần Trọng Thuận\", \"C. Nguyễn Minh Sơn và Bùi Ngọc Sơn\", \"D. qjbriqbưiebq\"]', 'B', 'accepted', '2025-12-21 21:05:30', NULL),
(12, 2, 1, 12, '\"Chức năng cốt lõi của hệ thống AI được đề xuất là gì?\"', '[\"A. Quản lý tài liệu và lưu trữ dữ liệu người dùng.\", \"B. Tóm tắt nội dung và tự động sinh câu hỏi trắc nghiệm.\", \"C. Phát triển giao diện người dùng và tích hợp API.\", \"D. Phân tích hiệu suất học tập của học sinh.\"]', 'B', 'accepted', '2025-12-21 21:05:30', NULL),
(13, 2, 1, 13, '\"Các công nghệ và API chính được dự kiến sử dụng trong hệ thống này là gì?\"', '[\"A. Blockchain và Cryptography, API ChatGPT.\", \"B. Xử lý ngôn ngữ tự nhiên (NLP), Machine Learning, API DeepSeek và Whisper/DeepSeek-Audio.\", \"C. Phân tích dữ liệu lớn và Điện toán đám mây, API Google Maps.\", \"D. Lập trình nhúng và Thị giác máy tính, API AWS.\"]', 'B', 'accepted', '2025-12-21 21:05:30', NULL),
(14, 2, 1, 14, '\"Hệ thống web app được đề xuất có thể áp dụng rộng rãi trong những lĩnh vực nào?\"', '[\"A. Y tế và Du lịch.\", \"B. Tài chính và Ngân hàng.\", \"C. Giáo dục và Doanh nghiệp.\", \"D. Sản xuất và Logistics.\"]', 'C', 'accepted', '2025-12-21 21:05:31', NULL),
(15, 2, 1, 15, '\"Thời gian dự kiến để thực hiện đề tài này là bao lâu?\"', '[\"A. 4 tuần\", \"B. 6 tuần\", \"C. 8 tuần\", \"D. 12 tuần\"]', 'C', 'accepted', '2025-12-21 21:05:31', NULL),
(16, 3, 1, 16, '\"Tên đề tài học phần của ndandưqd\"', '[\"A. Ứng dụng AI tóm tắt tài liệu\", \"B. Hệ thống quản lý ngân hàng câu hỏi\", \"C. Ứng dụng Web tự động tạo câu hỏi trắc nghiệm từ tài liệu\", \"D. Phát triển ứng dụng Web học tập\", \"E. Giải pháp số hóa tài liệu\"]', 'A', 'accepted', '2025-12-22 14:20:19', NULL),
(17, 3, 1, 17, '\"Chức năng chính của hệ thống AI (AI agent) mà đề tài hướng tới là gì?\"', '[\"A. Quản lý và lưu trữ tài liệu học tập\", \"B. Đọc – hiểu, tóm tắt nội dung và tự động sinh câu hỏi trắc nghiệm\", \"C. Dịch tự động tài liệu sang nhiều ngôn ngữ\", \"D. Tạo slide thuyết trình từ tài liệu\"]', 'B', 'accepted', '2025-12-22 14:20:19', NULL),
(18, 3, 1, 18, '\"Hệ thống AI của đề tài được thiết kế để xử lý những loại tài liệu nào?\"', '[\"A. PDF, DOCX và video\", \"B. PDF, DOCX và file âm thanh\", \"C. TXT, CSV và file hình ảnh\", \"D. HTML, XML và file bảng tính\"]', 'B', 'accepted', '2025-12-22 14:20:20', NULL),
(19, 3, 1, 19, '\"Những công nghệ chính nào được ứng dụng để đảm bảo chất lượng câu hỏi trong hệ thống?\"', '[\"A. Xử lý ảnh và Big Data\", \"B. Blockchain và Điện toán đám mây\", \"C. Xử lý ngôn ngữ tự nhiên (NLP) và Machine Learning\", \"D. Khoa học dữ liệu và Phát triển web front-end\"]', 'C', 'accepted', '2025-12-22 14:20:20', NULL),
(20, 3, 1, 20, '\"Đối tượng nào KHÔNG được đề cập là sẽ hưởng lợi từ ứng dụng web này?\"', '[\"A. Giảng viên\", \"B. Học sinh/sinh viên\", \"C. Nhà phát triển phần mềm\", \"D. Doanh nghiệp\"]', 'C', 'accepted', '2025-12-22 14:20:20', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `SessionResults`
--

CREATE TABLE `SessionResults` (
  `result_id` int(11) NOT NULL,
  `session_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `selected_option` char(1) DEFAULT NULL,
  `is_correct` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `SessionResults`
--

INSERT INTO `SessionResults` (`result_id`, `session_id`, `question_id`, `selected_option`, `is_correct`) VALUES
(1, 1, 1, 'B', 1),
(2, 1, 2, 'C', 1),
(3, 1, 3, 'C', 1),
(4, 1, 4, 'C', 1),
(5, 1, 5, 'C', 0),
(6, 1, 6, 'B', 1),
(7, 1, 7, 'C', 1),
(8, 1, 8, 'C', 1),
(9, 1, 9, 'B', 0),
(10, 1, 10, 'C', 0),
(11, 2, 5, 'C', 0),
(12, 3, 1, 'B', 1),
(13, 7, 1, 'A', 0),
(14, 7, 2, 'D', 0),
(15, 7, 3, 'C', 1),
(16, 7, 4, 'A', 0),
(17, 7, 5, 'C', 0),
(18, 7, 6, 'C', 0),
(19, 7, 7, 'A', 0),
(20, 7, 8, 'B', 0),
(21, 7, 9, 'A', 0),
(22, 7, 10, 'A', 0),
(23, 19, 9, 'A', 0),
(24, 19, 10, 'A', 0),
(26, 20, 9, 'A', 0),
(27, 20, 10, 'A', 0),
(29, 21, 11, 'A', 0),
(30, 21, 12, 'A', 0),
(31, 21, 13, 'A', 0),
(32, 21, 14, 'A', 0),
(33, 21, 15, 'A', 0),
(36, 24, 11, 'A', 0),
(37, 24, 12, 'A', 0),
(38, 24, 13, 'A', 0),
(39, 24, 14, 'A', 0),
(40, 24, 15, 'A', 0),
(43, 26, 11, 'A', 0),
(44, 26, 12, 'A', 0),
(45, 26, 13, 'A', 0),
(46, 27, 11, 'B', 1),
(47, 27, 12, 'A', 0);

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `birth` date DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `lti_user_id` varchar(255) DEFAULT NULL,
  `lti_sub` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_vietnamese_ci;

--
-- Dumping data for table `Users`
--

INSERT INTO `Users` (`user_id`, `username`, `email`, `full_name`, `phone_number`, `birth`, `password_hash`, `created_at`, `is_active`, `is_admin`, `lti_user_id`, `lti_sub`) VALUES
(1, 'admin', 'admin@gmail.com', 'Admin The Best', '0123456789', '2025-11-06', '$2b$12$yxrwLBMe3EsGJ/ToAfucS.5W.GHenb4FXmpQd47q4SiAMExIE6FZa', '2025-11-04 15:58:02', 1, 1, NULL, NULL),
(2, 'thuan', 'thuan@gmail.com', 'Trần Trọng Thuận', '0123456789', '2004-11-15', '$2b$12$WvXyyM078hzZMOfa1xHoEuTuDhtqcn9.8./8DiB1G5Pp0miRWwgkG', '2025-11-06 08:45:34', 1, 0, NULL, NULL),
(3, 'Hữu f', 'buihuuf@gamil.com', NULL, NULL, NULL, '$2b$12$DDMlT5Fviv9KGGeVHiZtWOeubkOKNM.LsmzNyuZc4jrXfhXD08opO', '2025-11-07 16:04:29', 1, 0, NULL, NULL),
(4, 'A', 'nmson@lhu.edu.vn', NULL, NULL, NULL, '$2b$12$YLtjW.2MQi.IQNrRcQQlG.n01529akCIN6avuRdWPRVtt3FH5xLrK', '2025-11-08 06:42:13', 1, 0, NULL, NULL),
(9, 'Cogiaotienganh', 'intailieu84@gmail.com', NULL, NULL, NULL, '$2b$12$VVtC70czAOAg3MRJgePrL.PStnCENGaf6rhX4yTtsH6HzXnSZ6re.', '2025-11-08 20:24:58', 1, 0, NULL, NULL),
(11, 'tliet6sao', 'tliet6sao@gmail.com', NULL, NULL, NULL, '$2b$12$Ut3KJ9z13.0a9PT9EWtLneAX2irVvgPzxKZsi21yzVk3fLaQKL1LW', '2025-11-11 16:36:24', 1, 0, NULL, NULL),
(12, 'abcd', 'abcd@gmail.com', NULL, NULL, NULL, '$2b$12$JRIuhFjSBeX9J6uGeg4fg.TNMkP7WR5MY3/41U/JpjU2aaCojOxN2', '2025-11-13 10:02:01', 1, 0, NULL, NULL),
(14, 'HuuNhat', 'nguyenhuunhat369@gmail.com', NULL, NULL, NULL, '$2b$12$KXrCMR8tqt.2QIlEaB8x0umBO8jSpBL65P2FuaOpKTkdgpqtf6.Vi', '2025-12-10 11:00:40', 1, 0, NULL, NULL),
(15, 'bns050404_212c', 'bns050404@gmail.com', 'Sơn Bùi', NULL, NULL, '$2b$12$cusLyQ3j8HPfH3ES9g6TRux1cQb2pHLAN80QOffKx.MZK80xQsU9a', '2025-12-10 17:13:01', 1, 0, NULL, '2'),
(16, 'trantthuan1511_b099', 'trantthuan1511@gmail.com', 'Thuan Tran', NULL, NULL, '$2b$12$seVZNG.v4QsQFqi6fxbhD.x3wLqXVS8ebI7QPkVi6zXd3UAYlWgk.', '2025-12-11 14:20:49', 1, 0, NULL, '4');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ExamQuestions`
--
ALTER TABLE `ExamQuestions`
  ADD PRIMARY KEY (`exam_question_id`),
  ADD UNIQUE KEY `exam_id` (`exam_id`,`question_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `Exams`
--
ALTER TABLE `Exams`
  ADD PRIMARY KEY (`exam_id`),
  ADD UNIQUE KEY `share_token` (`share_token`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indexes for table `ExamSessions`
--
ALTER TABLE `ExamSessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `exam_id` (`exam_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `Files`
--
ALTER TABLE `Files`
  ADD PRIMARY KEY (`file_id`),
  ADD KEY `uploader_id` (`uploader_id`);

--
-- Indexes for table `QuestionEvaluations`
--
ALTER TABLE `QuestionEvaluations`
  ADD PRIMARY KEY (`evaluation_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `Questions`
--
ALTER TABLE `Questions`
  ADD PRIMARY KEY (`question_id`),
  ADD KEY `source_file_id` (`source_file_id`),
  ADD KEY `creator_id` (`creator_id`),
  ADD KEY `FK_LatestEvaluation` (`latest_evaluation_id`);

--
-- Indexes for table `SessionResults`
--
ALTER TABLE `SessionResults`
  ADD PRIMARY KEY (`result_id`),
  ADD UNIQUE KEY `session_id` (`session_id`,`question_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `lti_user_id` (`lti_user_id`),
  ADD UNIQUE KEY `lti_sub` (`lti_sub`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ExamQuestions`
--
ALTER TABLE `ExamQuestions`
  MODIFY `exam_question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `Exams`
--
ALTER TABLE `Exams`
  MODIFY `exam_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ExamSessions`
--
ALTER TABLE `ExamSessions`
  MODIFY `session_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `Files`
--
ALTER TABLE `Files`
  MODIFY `file_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `QuestionEvaluations`
--
ALTER TABLE `QuestionEvaluations`
  MODIFY `evaluation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `Questions`
--
ALTER TABLE `Questions`
  MODIFY `question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `SessionResults`
--
ALTER TABLE `SessionResults`
  MODIFY `result_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `Users`
--
ALTER TABLE `Users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `ExamQuestions`
--
ALTER TABLE `ExamQuestions`
  ADD CONSTRAINT `ExamQuestions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `Exams` (`exam_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ExamQuestions_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `Questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `Exams`
--
ALTER TABLE `Exams`
  ADD CONSTRAINT `Exams_ibfk_1` FOREIGN KEY (`owner_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `ExamSessions`
--
ALTER TABLE `ExamSessions`
  ADD CONSTRAINT `ExamSessions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `Exams` (`exam_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ExamSessions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `Files`
--
ALTER TABLE `Files`
  ADD CONSTRAINT `Files_ibfk_1` FOREIGN KEY (`uploader_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `QuestionEvaluations`
--
ALTER TABLE `QuestionEvaluations`
  ADD CONSTRAINT `QuestionEvaluations_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `Questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `Questions`
--
ALTER TABLE `Questions`
  ADD CONSTRAINT `FK_LatestEvaluation` FOREIGN KEY (`latest_evaluation_id`) REFERENCES `QuestionEvaluations` (`evaluation_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `Questions_ibfk_1` FOREIGN KEY (`source_file_id`) REFERENCES `Files` (`file_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `Questions_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `Users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `SessionResults`
--
ALTER TABLE `SessionResults`
  ADD CONSTRAINT `SessionResults_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `ExamSessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `SessionResults_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `Questions` (`question_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
