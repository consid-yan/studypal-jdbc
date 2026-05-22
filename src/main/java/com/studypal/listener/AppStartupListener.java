package com.studypal.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppStartupListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent event) {
        event.getServletContext().log("StudyPal started");
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        event.getServletContext().log("StudyPal stopped");
    }
}
