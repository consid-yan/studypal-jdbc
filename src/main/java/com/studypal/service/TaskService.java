package com.studypal.service;

import com.studypal.model.*;
import com.studypal.util.DBUtils;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskService {

    // ==================== Instructor: Creating Tasks and Templates ====================

    public String createMainTask(Long courseId, Long creatorId, String title,
                                 String description, Timestamp deadline,
                                 int importanceLevel, String roleEnum) {
        String sql = "INSERT INTO MAIN_TASK (course_id, creator_id, title, description, deadline, importance_level, role_enum) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (courseId != null) ps.setLong(1, courseId);
            else ps.setNull(1, Types.BIGINT);
            ps.setLong(2, creatorId);
            ps.setString(3, title);
            ps.setString(4, description);
            ps.setTimestamp(5, deadline);
            ps.setInt(6, importanceLevel);
            ps.setString(7, roleEnum);
            ps.executeUpdate();
            return null;
        } catch (SQLException e) {
            return "Failed to create task: " + e.getMessage();
        }
    }

    public void createSubTaskTemplate(Long mainTaskId, String title, String description,
                                      BigDecimal estimatedHours, int sequenceOrder) {
        String sql = "INSERT INTO SUB_TASK_TEMPLATE (main_task_id, title, description, estimated_hours, sequence_order) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            ps.setString(2, title);
            ps.setString(3, description);
            ps.setBigDecimal(4, estimatedHours);
            ps.setInt(5, sequenceOrder);
            ps.executeUpdate();
        } catch (SQLException ignored) {
        }
    }

    // ==================== Instructor: List of Published Assignments ====================

    public List<MainTask> getTasksByCreatorId(Long creatorId) throws SQLException {
        String sql = "SELECT m.*, c.course_code, c.course_name, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM SUB_TASK_TEMPLATE t WHERE t.main_task_id = m.main_task_id) AS template_count " +
                     "FROM MAIN_TASK m LEFT JOIN COURSE c ON m.course_id = c.course_id " +
                     "JOIN USER_ACCOUNT u ON m.creator_id = u.user_id " +
                     "WHERE m.creator_id = ? ORDER BY m.created_at DESC";
        List<MainTask> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, creatorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapMainTask(rs));
                }
            }
        }
        return list;
    }

    // ==================== Instructor: Single Task Details ====================

    public MainTask getTaskById(Long mainTaskId) throws SQLException {
        String sql = "SELECT m.*, c.course_code, c.course_name, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM SUB_TASK_TEMPLATE t WHERE t.main_task_id = m.main_task_id) AS template_count " +
                     "FROM MAIN_TASK m LEFT JOIN COURSE c ON m.course_id = c.course_id " +
                     "JOIN USER_ACCOUNT u ON m.creator_id = u.user_id WHERE m.main_task_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMainTask(rs);
                }
            }
        }
        return null;
    }

    // ==================== Instructor: Task Statistics ====================

    public int getTaskEnrollmentCount(Long mainTaskId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ENROLLMENT e JOIN MAIN_TASK m ON m.course_id = e.course_id WHERE m.main_task_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        }
        return 0;
    }

    public int getTaskCompletedStudentCount(Long mainTaskId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM (" +
                     "SELECT sst.student_id FROM STUDENT_SUB_TASK sst " +
                     "JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
                     "WHERE t.main_task_id = ? GROUP BY sst.student_id " +
                     "HAVING SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) = COUNT(*)) AS completed";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        }
        return 0;
    }

    public double getTaskAvgCompletion(Long mainTaskId) throws SQLException {
        String sql = "SELECT COALESCE(AVG(completion_pct), 0) FROM (" +
                     "SELECT sst.student_id, SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS completion_pct " +
                     "FROM STUDENT_SUB_TASK sst JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
                     "WHERE t.main_task_id = ? GROUP BY sst.student_id) AS sub";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getDouble(1); }
        }
        return 0;
    }

    public int getTaskAtRiskStudentCount(Long mainTaskId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM (" +
                     "SELECT sst.student_id, SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS completion_pct " +
                     "FROM STUDENT_SUB_TASK sst JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
                     "WHERE t.main_task_id = ? GROUP BY sst.student_id HAVING completion_pct < 40.0) AS at_risk";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        }
        return 0;
    }

    // ==================== Lecturer: Student Progress and Step Aggregation ====================

    public List<StudentSubTask> getStudentProgressByTask(Long mainTaskId) throws SQLException {
        String sql = "SELECT sst.student_id, u.full_name AS student_name, u.email AS student_email, " +
                     "COUNT(*) AS total_steps, SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_steps, " +
                     "(SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS progress_pct " +
                     "FROM STUDENT_SUB_TASK sst JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
                     "JOIN USER_ACCOUNT u ON sst.student_id = u.user_id " +
                     "WHERE t.main_task_id = ? GROUP BY sst.student_id, u.full_name, u.email ORDER BY u.full_name";
        List<StudentSubTask> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentSubTask sp = new StudentSubTask();
                    sp.setStudentId(rs.getLong("student_id"));
                    sp.setStudentName(rs.getString("student_name"));
                    sp.setStudentEmail(rs.getString("student_email"));
                    sp.setProgressPercentage((int) rs.getDouble("progress_pct"));
                    list.add(sp);
                }
            }
        }
        return list;
    }

    public List<SubTaskTemplate> getStepAggregateProgress(Long mainTaskId) throws SQLException {
        String sql = "SELECT t.template_id, t.title, t.sequence_order, " +
                     "COUNT(sst.student_sub_task_id) AS total_assigned, " +
                     "SUM(CASE WHEN sst.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_count " +
                     "FROM SUB_TASK_TEMPLATE t LEFT JOIN STUDENT_SUB_TASK sst ON t.template_id = sst.template_id " +
                     "WHERE t.main_task_id = ? GROUP BY t.template_id, t.title, t.sequence_order ORDER BY t.sequence_order";
        List<SubTaskTemplate> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubTaskTemplate st = new SubTaskTemplate();
                    st.setTemplateId(rs.getLong("template_id"));
                    st.setTitle(rs.getString("title"));
                    st.setSequenceOrder((Integer) rs.getObject("sequence_order"));
                    st.setCompletedCount(rs.getInt("completed_count"));
                    st.setTotalStudentCount(rs.getInt("total_assigned"));
                    list.add(st);
                }
            }
        }
        return list;
    }

    // ==================== Student: Task Filter List ====================

    public List<StudentSubTask> getTasksByStudentId(Long studentId, String keyword,
                                                     Long courseIdFilter, String statusFilter) throws SQLException {
        var sql = new StringBuilder(
            "SELECT sst.*, t.title AS template_title, t.description AS template_description, " +
            "m.main_task_id AS mt_id, m.title AS main_task_title, m.deadline, c.course_name " +
            "FROM STUDENT_SUB_TASK sst JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
            "JOIN MAIN_TASK m ON t.main_task_id = m.main_task_id " +
            "LEFT JOIN COURSE c ON m.course_id = c.course_id " +
            "WHERE sst.student_id = ?");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (m.title LIKE ? OR c.course_name LIKE ?)");
        }
        if (courseIdFilter != null) {
            sql.append(" AND m.course_id = ?");
        }
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND sst.status = ?");
        }
        sql.append(" ORDER BY m.deadline ASC");

        List<StudentSubTask> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setLong(idx++, studentId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            if (courseIdFilter != null) {
                ps.setLong(idx++, courseIdFilter);
            }
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(idx++, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentSubTask sst = mapStudentSubTask(rs);
                    sst.setMainTaskId(rs.getLong("mt_id"));
                    sst.setDeadline(rs.getTimestamp("deadline"));
                    list.add(sst);
                }
            }
        }
        return list;
    }

    // ==================== Student: Task Details ====================

    public MainTask getMainTaskById(Long mainTaskId) throws SQLException {
        String sql = "SELECT m.*, c.course_code, c.course_name, u.full_name AS creator_name, " +
                     "(SELECT COUNT(*) FROM SUB_TASK_TEMPLATE t WHERE t.main_task_id = m.main_task_id) AS template_count " +
                     "FROM MAIN_TASK m LEFT JOIN COURSE c ON m.course_id = c.course_id " +
                     "JOIN USER_ACCOUNT u ON m.creator_id = u.user_id WHERE m.main_task_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapMainTask(rs);
                }
            }
        }
        return null;
    }

    public List<SubTaskTemplate> getTemplatesByMainTaskId(Long mainTaskId) throws SQLException {
        String sql = "SELECT * FROM SUB_TASK_TEMPLATE WHERE main_task_id = ? ORDER BY sequence_order";
        List<SubTaskTemplate> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SubTaskTemplate t = new SubTaskTemplate();
                    t.setTemplateId(rs.getLong("template_id"));
                    t.setMainTaskId(rs.getLong("main_task_id"));
                    t.setTitle(rs.getString("title"));
                    t.setDescription(rs.getString("description"));
                    t.setEstimatedHours(rs.getBigDecimal("estimated_hours"));
                    t.setSequenceOrder((Integer) rs.getObject("sequence_order"));
                    t.setPlannedStart(rs.getTimestamp("planned_start"));
                    t.setPlannedEnd(rs.getTimestamp("planned_end"));
                    list.add(t);
                }
            }
        }
        return list;
    }

    public List<StudentSubTask> getStudentSubTasksByMainTask(Long studentId, Long mainTaskId) throws SQLException {
        String sql = "SELECT sst.*, t.title AS template_title, t.description AS template_description, " +
                     "m.main_task_id AS mt_id, m.title AS main_task_title, m.deadline, c.course_name " +
                     "FROM STUDENT_SUB_TASK sst JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
                     "JOIN MAIN_TASK m ON t.main_task_id = m.main_task_id " +
                     "LEFT JOIN COURSE c ON m.course_id = c.course_id " +
                     "WHERE sst.student_id = ? AND t.main_task_id = ? ORDER BY t.sequence_order";
        List<StudentSubTask> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            ps.setLong(2, mainTaskId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentSubTask sst = mapStudentSubTask(rs);
                    sst.setMainTaskId(rs.getLong("mt_id"));
                    sst.setDeadline(rs.getTimestamp("deadline"));
                    list.add(sst);
                }
            }
        }
        return list;
    }

    // ==================== Student: Automatic Instantiation ====================

    public String ensureStudentSubTasksExist(Long studentId, Long mainTaskId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBUtils.getConnection();
            conn.setAutoCommit(false);

            if (!studentCanAccessTask(conn, studentId, mainTaskId)) {
                conn.rollback();
                return "You are not enrolled in this task's course.";
            }

            String checkSql = "SELECT COUNT(*) FROM STUDENT_SUB_TASK WHERE student_id = ? " +
                             "AND template_id IN (SELECT template_id FROM SUB_TASK_TEMPLATE WHERE main_task_id = ?)";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, mainTaskId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        conn.commit();
                        return null;
                    }
                }
            }

            String insertSql = "INSERT INTO STUDENT_SUB_TASK (student_id, template_id, status) " +
                              "SELECT ?, template_id, 'NOT_STARTED' FROM SUB_TASK_TEMPLATE WHERE main_task_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setLong(1, studentId);
                ps.setLong(2, mainTaskId);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    return "No templates found for this task.";
                }
            }

            conn.commit();
            return null;
        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            return "Failed to generate sub-tasks: " + e.getMessage();
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    // ==================== Student: Update Progress ====================

    public String updateStudentSubTaskStatus(Long studentId, Long studentSubTaskId, String status,
                                              String notes, Timestamp completedTime) throws SQLException {
        if (!"NOT_STARTED".equals(status) && !"IN_PROGRESS".equals(status) && !"COMPLETED".equals(status)) {
            return "Invalid task status.";
        }
        String sql = "UPDATE STUDENT_SUB_TASK SET status = ?, notes = ?, completed_time = ? " +
                     "WHERE student_sub_task_id = ? AND student_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, notes);
            if (completedTime != null) ps.setTimestamp(3, completedTime);
            else ps.setNull(3, Types.TIMESTAMP);
            ps.setLong(4, studentSubTaskId);
            ps.setLong(5, studentId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                return "Task not found for current student.";
            }
            return null;
        } catch (SQLException e) {
            return "Failed to update task: " + e.getMessage();
        }
    }

    // ==================== Student: Dashboard Statistics ====================

    public int getPendingTaskCount(Long studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM STUDENT_SUB_TASK WHERE student_id = ? AND status != 'COMPLETED'";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        }
        return 0;
    }

    public double getCompletionRate(Long studentId) throws SQLException {
        String sql = "SELECT SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) FROM STUDENT_SUB_TASK WHERE student_id = ?";
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getDouble(1); }
        }
        return 0;
    }

    public List<StudentSubTask> getUpcomingDeadlines(Long studentId, int limit) throws SQLException {
        String sql = "SELECT sst.*, t.title AS template_title, m.main_task_id AS mt_id, " +
                     "m.title AS main_task_title, m.deadline, c.course_name " +
                     "FROM STUDENT_SUB_TASK sst JOIN SUB_TASK_TEMPLATE t ON sst.template_id = t.template_id " +
                     "JOIN MAIN_TASK m ON t.main_task_id = m.main_task_id " +
                     "LEFT JOIN COURSE c ON m.course_id = c.course_id " +
                     "WHERE sst.student_id = ? AND sst.status != 'COMPLETED' ORDER BY m.deadline ASC LIMIT ?";
        List<StudentSubTask> list = new ArrayList<>();
        try (Connection conn = DBUtils.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentSubTask sst = mapStudentSubTask(rs);
                    sst.setMainTaskId(rs.getLong("mt_id"));
                    sst.setMainTaskTitle(rs.getString("main_task_title"));
                    sst.setDeadline(rs.getTimestamp("deadline"));
                    sst.setCourseName(rs.getString("course_name"));
                    list.add(sst);
                }
            }
        }
        return list;
    }

    // ==================== Utility Methods ====================

    // ==================== AI Sub-Step Template Generation ====================

    public void generateSubTaskTemplates(Long mainTaskId, String courseName,
                                         String taskTitle, String description) {
        String apiUrl = chatCompletionUrl(DBUtils.AI_API_URL);
        String apiKey = DBUtils.AI_API_KEY;
        String model = DBUtils.AI_MODEL;

        if (apiUrl == null || apiUrl.isEmpty() || apiKey == null || apiKey.isEmpty()) {
            insertDefaultTemplate(mainTaskId);
            return;
        }

        String prompt = String.format(
            "You are a course planner. Break down the following academic task into 3 to 5 sub-task steps. " +
            "Course: %s. Task title: %s. Description: %s. " +
            "Return ONLY a JSON array, no markdown. Each element: {\"title\":\"...\",\"description\":\"...\",\"estimatedHours\":number}. " +
            "estimatedHours should be between 0.5 and 8.0.",
            courseName != null ? courseName : "General",
            taskTitle,
            description != null ? description : "No description");

        try {
            String jsonBody = String.format(
                "{\"model\":\"%s\",\"messages\":[{\"role\":\"user\",\"content\":\"%s\"}]," +
                "\"temperature\":0.7,\"max_tokens\":2000}",
                model, escapeJson(prompt));

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(apiUrl))
                .header("Content-Type", "application/json")
                .header("Authorization", "Bearer " + apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            String body = response.body();

            // Extract content: {“choices”:[{“message”:{‘content’:“[...]”}}]}
            int contentStart = body.indexOf("\"content\":\"");
            if (contentStart < 0) { insertDefaultTemplate(mainTaskId); return; }
            int jsonStart = body.indexOf("[", contentStart);
            int jsonEnd = body.lastIndexOf("]");
            if (jsonStart < 0 || jsonEnd < 0 || jsonEnd <= jsonStart) {
                insertDefaultTemplate(mainTaskId); return;
            }
            String arrStr = body.substring(jsonStart, jsonEnd + 1);

            parseAndInsertTemplates(mainTaskId, arrStr);
        } catch (Exception e) {
            insertDefaultTemplate(mainTaskId);
        }
    }

    private void parseAndInsertTemplates(Long mainTaskId, String jsonArr) throws SQLException {
        int seq = 1;
        int idx = 0;
        while ((idx = jsonArr.indexOf("{\"title\":\"", idx)) >= 0) {
            int end = jsonArr.indexOf("}", idx);
            if (end < 0) break;
            String obj = jsonArr.substring(idx, end + 1);
            String title = extractJsonValue(obj, "title");
            String desc = extractJsonValue(obj, "description");
            String hoursStr = extractJsonValue(obj, "estimatedHours");
            BigDecimal hours = new BigDecimal("1.0");
            try { hours = new BigDecimal(hoursStr); } catch (Exception ignored) {}
            createSubTaskTemplate(mainTaskId, title, desc, hours, seq);
            seq++;
            idx = end + 1;
        }
        if (seq == 1) insertDefaultTemplate(mainTaskId);
    }

    private void insertDefaultTemplate(Long mainTaskId) {
        try {
            createSubTaskTemplate(mainTaskId, "Complete this task",
                "Review requirements and submit all deliverables.",
                new BigDecimal("2.0"), 1);
        } catch (Exception ignored) {}
    }

    private String extractJsonValue(String json, String key) {
        int keyIdx = json.indexOf("\"" + key + "\":\"");
        if (keyIdx < 0) {
            keyIdx = json.indexOf("\"" + key + "\":");
            if (keyIdx < 0) return "N/A";
            int valStart = keyIdx + key.length() + 3;
            int valEnd = json.indexOf(",", valStart);
            if (valEnd < 0) valEnd = json.indexOf("}", valStart);
            return valEnd > valStart ? json.substring(valStart, valEnd).trim() : "N/A";
        }
        int valStart = keyIdx + key.length() + 4;
        int valEnd = json.indexOf("\"", valStart);
        return valEnd > valStart ? json.substring(valStart, valEnd) : "N/A";
    }

    private String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    private String chatCompletionUrl(String apiUrl) {
        if (apiUrl == null || apiUrl.isBlank() || apiUrl.endsWith("/chat/completions")) {
            return apiUrl;
        }
        return apiUrl.replaceAll("/+$", "") + "/chat/completions";
    }

    private boolean studentCanAccessTask(Connection conn, Long studentId, Long mainTaskId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM MAIN_TASK m " +
                     "LEFT JOIN ENROLLMENT e ON m.course_id = e.course_id AND e.student_id = ? " +
                     "WHERE m.main_task_id = ? AND " +
                     "((m.course_id IS NULL AND m.creator_id = ?) OR e.enrollment_id IS NOT NULL)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, studentId);
            ps.setLong(2, mainTaskId);
            ps.setLong(3, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private MainTask mapMainTask(ResultSet rs) throws SQLException {
        return new MainTask(rs.getLong("main_task_id"),
                getNullableLong(rs, "course_id"),
                rs.getLong("creator_id"),
                rs.getString("title"),
                rs.getString("description"),
                rs.getTimestamp("deadline"),
                getNullableInteger(rs, "importance_level"),
                rs.getString("role_enum"),
                rs.getTimestamp("created_at"),
                rs.getString("course_code"),
                rs.getString("course_name"),
                rs.getString("creator_name"),
                rs.getInt("template_count"));
    }

    private Long getNullableLong(ResultSet rs, String columnLabel) throws SQLException {
        long value = rs.getLong(columnLabel);
        return rs.wasNull() ? null : value;
    }

    private Integer getNullableInteger(ResultSet rs, String columnLabel) throws SQLException {
        int value = rs.getInt(columnLabel);
        return rs.wasNull() ? null : value;
    }

    private StudentSubTask mapStudentSubTask(ResultSet rs) throws SQLException {
        StudentSubTask sst = new StudentSubTask();
        sst.setStudentSubTaskId(rs.getLong("student_sub_task_id"));
        sst.setStudentId(rs.getLong("student_id"));
        sst.setTemplateId(rs.getLong("template_id"));
        sst.setCustomTitle(rs.getString("custom_title"));
        sst.setCustomDescription(rs.getString("custom_description"));
        sst.setCustomPlannedStartTime(rs.getTimestamp("custom_planned_start_time"));
        sst.setCustomPlannedEndTime(rs.getTimestamp("custom_planned_end_time"));
        sst.setCompletedTime(rs.getTimestamp("completed_time"));
        sst.setStatus(rs.getString("status"));
        sst.setNotes(rs.getString("notes"));
        sst.setTemplateTitle(rs.getString("template_title"));
        sst.setTemplateDescription(rs.getString("template_description"));
        sst.setMainTaskTitle(rs.getString("main_task_title"));
        sst.setCourseName(rs.getString("course_name"));
        return sst;
    }
}
