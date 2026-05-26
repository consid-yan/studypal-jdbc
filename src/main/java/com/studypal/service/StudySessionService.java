package com.studypal.service;

import com.studypal.dao.StudySessionDao;
import com.studypal.model.StudySession;

import java.util.List;
import java.util.Optional;

public class StudySessionService {
    private final StudySessionDao studySessionDao;

    public StudySessionService() {
        this(new StudySessionDao());
    }

    public StudySessionService(StudySessionDao studySessionDao) {
        this.studySessionDao = studySessionDao;
    }

    public Optional<StudySession> findStudySession(Integer sessionId) {
        return studySessionDao.findById(sessionId);
    }

    public List<StudySession> listStudySessionsForStudent(Integer studentId) {
        return studySessionDao.findByStudentId(studentId);
    }

    public void recordStudySession(StudySession studySession) {
        studySessionDao.insert(studySession);
    }

    public void updateStudySession(StudySession studySession) {
        studySessionDao.update(studySession);
    }

    public void deleteStudySession(Integer sessionId) {
        studySessionDao.delete(sessionId);
    }
}
