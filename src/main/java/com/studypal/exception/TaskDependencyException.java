package com.studypal.exception;

public class TaskDependencyException extends RuntimeException {
    public TaskDependencyException(String message) {
        super(message);
    }
}
