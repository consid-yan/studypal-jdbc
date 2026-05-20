package com.studypal.service;

import com.studypal.dao.StudySessionDAO;
import com.studypal.model.StudySession;

import java.util.List;
import java.util.Optional;

public class StudySessionService {
    private final StudySessionDAO studySessionDAO;

    public StudySessionService() {
        this(new StudySessionDAO());
    }

    public StudySessionService(StudySessionDAO studySessionDAO) {
        this.studySessionDAO = studySessionDAO;
    }

    public Optional<StudySession> findStudySession(Integer studySessionId) {
        return studySessionDAO.findById(studySessionId);
    }

    public List<StudySession> listStudySessionsForStudent(Integer studentId) {
        return studySessionDAO.findByStudentId(studentId);
    }

    public void recordStudySession(StudySession studySession) {
        if (studySession.getDurationHours() == null) {
            studySession.setDurationHours(studySession.calculateDurationHours());
        }
        studySessionDAO.insert(studySession);
    }
}
