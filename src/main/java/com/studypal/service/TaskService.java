package com.studypal.service;

import com.studypal.dao.MainTaskDao;
import com.studypal.dao.SubTaskDao;
import com.studypal.dao.TaskDependencyDao;
import com.studypal.exception.TaskDependencyException;
import com.studypal.model.MainTask;
import com.studypal.model.SubTask;
import com.studypal.model.TaskDependency;

import java.util.List;
import java.util.Optional;

public class TaskService {
    private final MainTaskDao mainTaskDao;
    private final SubTaskDao subTaskDao;
    private final TaskDependencyDao taskDependencyDao;

    public TaskService() {
        this(new MainTaskDao(), new SubTaskDao(), new TaskDependencyDao());
    }

    public TaskService(MainTaskDao mainTaskDao, SubTaskDao subTaskDao,
                       TaskDependencyDao taskDependencyDao) {
        this.mainTaskDao = mainTaskDao;
        this.subTaskDao = subTaskDao;
        this.taskDependencyDao = taskDependencyDao;
    }

    public Optional<MainTask> findMainTask(Integer mainTaskId) {
        return mainTaskDao.findById(mainTaskId);
    }

    public List<MainTask> listMainTasksForStudent(Integer studentId) {
        return mainTaskDao.findByStudentId(studentId);
    }

    public List<SubTask> listSubTasks(Integer mainTaskId) {
        return subTaskDao.findByMainTaskId(mainTaskId);
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

    public void addDependency(TaskDependency dependency) {
        if (dependency != null && dependency.isSelfDependency()) {
            throw new TaskDependencyException("A sub-task cannot depend on itself.");
        }
        taskDependencyDao.insert(dependency);
    }

    public boolean canStartSubTask(Integer subTaskId) {
        return taskDependencyDao.findBySubTaskId(subTaskId).stream()
                .map(TaskDependency::getDependsOnSubTaskId)
                .map(subTaskDao::findById)
                .allMatch(dependency -> dependency.isPresent() && dependency.get().isCompleted());
    }
}
