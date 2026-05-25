package com.studypal.service;

import com.studypal.dao.MainTaskDao;
import com.studypal.dao.SubTaskDao;
import com.studypal.model.MainTask;
import com.studypal.model.SubTask;

import java.util.List;
import java.util.Optional;

public class TaskService {
    private final MainTaskDao mainTaskDao;
    private final SubTaskDao subTaskDao;

    public TaskService() {
        this(new MainTaskDao(), new SubTaskDao());
    }

    public TaskService(MainTaskDao mainTaskDao, SubTaskDao subTaskDao) {
        this.mainTaskDao = mainTaskDao;
        this.subTaskDao = subTaskDao;
    }

    public Optional<MainTask> findMainTask(Integer mainTaskId) {
        return mainTaskDao.findById(mainTaskId);
    }

    public List<MainTask> listMainTasksForStudent(Integer studentId) {
        return mainTaskDao.findByStudentId(studentId);
    }

    public List<SubTask> listSubTasksForStudent(Integer studentId) {
        return subTaskDao.findByStudentId(studentId);
    }

    public List<SubTask> listSubTasks(Integer studentId, Integer mainTaskId) {
        return subTaskDao.findByStudentIdAndMainTaskId(studentId, mainTaskId);
    }

    public int countPlannedSubTasksForDate(Integer studentId, java.time.LocalDate date) {
        return subTaskDao.countPlannedForDate(studentId, date);
    }

    public Optional<SubTask> findSubTask(Integer subTaskId) {
        return subTaskDao.findById(subTaskId);
    }

    public void createMainTask(MainTask mainTask) {
        mainTaskDao.insert(mainTask);
    }

    public void updateMainTask(MainTask mainTask) {
        mainTaskDao.update(mainTask);
    }

    public void deleteMainTask(Integer mainTaskId) {
        mainTaskDao.delete(mainTaskId);
    }

    public void createSubTask(SubTask subTask) {
        subTaskDao.insert(subTask);
    }

    public void updateSubTask(SubTask subTask) {
        subTaskDao.update(subTask);
    }

    public void deleteSubTask(Integer subTaskId) {
        subTaskDao.delete(subTaskId);
    }

    public boolean canStartSubTask(Integer subTaskId) {
        return true;
    }
}
