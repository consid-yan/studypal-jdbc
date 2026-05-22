package com.studypal.util;

import com.studypal.exception.ScheduleConflictException;
import com.studypal.exception.TaskDependencyException;
import com.studypal.exception.ValidationException;

import jakarta.servlet.ServletContext;

public final class ServletLogUtil {
    private ServletLogUtil() {
    }

    public static void logSystemException(ServletContext context, String message, Exception exception) {
        if (context == null || exception == null || isBusinessException(exception)) {
            return;
        }

        context.log(message, exception);
    }

    private static boolean isBusinessException(Exception exception) {
        return exception instanceof ValidationException
                || exception instanceof ScheduleConflictException
                || exception instanceof TaskDependencyException;
    }
}
