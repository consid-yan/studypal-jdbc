package com.studypal.model;

public enum ImportanceLevel {
    VERY_LOW(1),
    LOW(2),
    MEDIUM(3),
    HIGH(4),
    VERY_HIGH(5);

    private final int score;

    ImportanceLevel(int score) {
        this.score = score;
    }

    public int getScore() {
        return score;
    }

    public static ImportanceLevel fromScore(int score) {
        for (ImportanceLevel level : values()) {
            if (level.score == score) {
                return level;
            }
        }
        throw new IllegalArgumentException("Invalid importance level score: " + score);
    }
}
