package com.studypal.service;

import com.studypal.dao.CourseDAO;
import com.studypal.model.Course;

import java.util.List;
import java.util.Optional;

public class CourseService {
    private final CourseDAO courseDAO;

    public CourseService() {
        this(new CourseDAO());
    }

    public CourseService(CourseDAO courseDAO) {
        this.courseDAO = courseDAO;
    }

    public Optional<Course> findCourse(Integer courseId) {
        return courseDAO.findById(courseId);
    }

    public List<Course> listCourses() {
        return courseDAO.findAll();
    }

    public List<Course> listCoursesForStudent(Integer studentId) {
        return courseDAO.findByStudentId(studentId);
    }

    public void createCourse(Course course) {
        courseDAO.insert(course);
    }
}
