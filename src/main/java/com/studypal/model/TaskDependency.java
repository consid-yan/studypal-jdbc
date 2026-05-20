package com.studypal.model;

public class TaskDependency {
    private Integer dependencyId;
    private Integer subTaskId;
    private Integer dependsOnSubTaskId;

    public TaskDependency() {
    }

    public TaskDependency(Integer dependencyId, Integer subTaskId, Integer dependsOnSubTaskId) {
        this.dependencyId = dependencyId;
        this.subTaskId = subTaskId;
        this.dependsOnSubTaskId = dependsOnSubTaskId;
    }

    public Integer getDependencyId() {
        return dependencyId;
    }

    public void setDependencyId(Integer dependencyId) {
        this.dependencyId = dependencyId;
    }

    public Integer getSubTaskId() {
        return subTaskId;
    }

    public void setSubTaskId(Integer subTaskId) {
        this.subTaskId = subTaskId;
    }

    public Integer getDependsOnSubTaskId() {
        return dependsOnSubTaskId;
    }

    public void setDependsOnSubTaskId(Integer dependsOnSubTaskId) {
        this.dependsOnSubTaskId = dependsOnSubTaskId;
    }

    public boolean isSelfDependency() {
        return subTaskId != null && subTaskId.equals(dependsOnSubTaskId);
    }
}
