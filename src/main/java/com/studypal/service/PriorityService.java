package com.studypal.service;

import com.studypal.model.ImportanceLevel;
import com.studypal.model.MainTask;
import com.studypal.model.SubTask;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public class PriorityService {
    public double calculatePriorityScore(ImportanceLevel importanceLevel, LocalDateTime targetTime) {
        if (importanceLevel == null) {
            return 0.0;
        }

        double importanceScore = importanceLevel.getScore() * 20.0;
        double urgencyScore = calculateUrgencyScore(targetTime);
        return importanceScore * 0.6 + urgencyScore * 0.4;
    }

    public double calculateForMainTask(MainTask mainTask) {
        if (mainTask == null) {
            return 0.0;
        }
        return calculatePriorityScore(mainTask.getImportanceLevel(), mainTask.getDeadline());
    }

    public double calculateForSubTask(SubTask subTask, ImportanceLevel parentImportance) {
        if (subTask == null) {
            return 0.0;
        }
        return calculatePriorityScore(parentImportance, subTask.getPlannedEndTime());
    }

    private double calculateUrgencyScore(LocalDateTime targetTime) {
        if (targetTime == null) {
            return 0.0;
        }

        long hoursRemaining = ChronoUnit.HOURS.between(LocalDateTime.now(), targetTime);
        if (hoursRemaining <= 0) {
            return 100.0;
        }
        if (hoursRemaining <= 24) {
            return 90.0;
        }
        if (hoursRemaining <= 72) {
            return 75.0;
        }
        if (hoursRemaining <= 168) {
            return 55.0;
        }
        if (hoursRemaining <= 336) {
            return 35.0;
        }
        return 15.0;
    }
}
