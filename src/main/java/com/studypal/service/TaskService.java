package com.studypal.service;

import com.studypal.dao.MainTaskDAO;
import com.studypal.dao.SubTaskDAO;
import com.studypal.dao.TaskDependencyDAO;
import com.studypal.exception.TaskDependencyException;
import com.studypal.model.MainTask;
import com.studypal.model.SubTask;
import com.studypal.model.TaskDependency;

import java.util.List;
import java.util.Optional;

public class TaskService {
    private final MainTaskDAO mainTaskDAO;
    private final SubTaskDAO subTaskDAO;
    private final TaskDependencyDAO taskDependencyDAO;

    public TaskService() {
        this(new MainTaskDAO(), new SubTaskDAO(), new TaskDependencyDAO());
    }

    public TaskService(MainTaskDAO mainTaskDAO, SubTaskDAO subTaskDAO,
                       TaskDependencyDAO taskDependencyDAO) {
        this.mainTaskDAO = mainTaskDAO;
        this.subTaskDAO = subTaskDAO;
        this.taskDependencyDAO = taskDependencyDAO;
    }

    public Optional<MainTask> findMainTask(Integer mainTaskId) {
        return mainTaskDAO.findById(mainTaskId);
    }

    public List<MainTask> listMainTasksForStudent(Integer studentId) {
        return mainTaskDAO.findByStudentId(studentId);
    }

    public List<SubTask> listSubTasks(Integer mainTaskId) {
        return subTaskDAO.findByMainTaskId(mainTaskId);
    }

    public void createMainTask(MainTask mainTask) {
        mainTaskDAO.insert(mainTask);
    }

    public void createSubTask(SubTask subTask) {
        subTaskDAO.insert(subTask);
    }

    public void addDependency(TaskDependency dependency) {
        if (dependency != null && dependency.isSelfDependency()) {
            throw new TaskDependencyException("A sub-task cannot depend on itself.");
        }
        taskDependencyDAO.insert(dependency);
    }

    public boolean canStartSubTask(Integer subTaskId) {
        // TODO: query dependencies and verify prerequisite sub-tasks are completed.
        return true;
    }
}
