package com.studypal.service;

import com.studypal.dao.CourseDao;
import com.studypal.model.Course;

import java.util.List;
import java.util.Optional;

public class CourseService {
    private final CourseDao courseDao;

    public CourseService() {
        this(new CourseDao());
    }

    public CourseService(CourseDao courseDao) {
        this.courseDao = courseDao;
    }

    public Optional<Course> findCourse(Integer courseId) {
        return courseDao.findById(courseId);
    }

    public List<Course> listCourses() {
        return courseDao.findAll();
    }

    public List<Course> listCoursesForStudent(Integer studentId) {
        return courseDao.findByStudentId(studentId);
    }

    public void createCourse(Course course) {
        courseDao.insert(course);
    }
}
