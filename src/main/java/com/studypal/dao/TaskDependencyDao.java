package com.studypal.dao;

import com.studypal.model.TaskDependency;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

public class TaskDependencyDao {
    public Optional<TaskDependency> findById(Integer dependencyId) {
        return Optional.empty();
    }

    public List<TaskDependency> findAll() {
        return Collections.emptyList();
    }

    public List<TaskDependency> findBySubTaskId(Integer subTaskId) {
        return Collections.emptyList();
    }

    public void insert(TaskDependency taskDependency) {
        throw new UnsupportedOperationException("Task dependencies are disabled in the refactored schema.");
    }

    public boolean update(TaskDependency taskDependency) {
        throw new UnsupportedOperationException("Task dependencies are disabled in the refactored schema.");
    }

    public boolean delete(Integer dependencyId) {
        throw new UnsupportedOperationException("Task dependencies are disabled in the refactored schema.");
    }
}
