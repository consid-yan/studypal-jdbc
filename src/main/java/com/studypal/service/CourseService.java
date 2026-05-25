package com.studypal.service;

import com.studypal.dao.CourseDao;
import com.studypal.dao.UserDao;
import com.studypal.model.Course;
import com.studypal.model.User;
import com.studypal.model.UserRole;

import java.util.List;
import java.util.Optional;

public class CourseService {
    private final CourseDao courseDao;
    private final UserDao userDao;

    public CourseService() {
        this(new CourseDao(), new UserDao());
    }

    public CourseService(CourseDao courseDao, UserDao userDao) {
        this.courseDao = courseDao;
        this.userDao = userDao;
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

    public List<User> listLecturers() {
        return userDao.findByRole(UserRole.LECTURER);
    }

    public void createCourse(Course course) {
        courseDao.insert(course);
    }

    public void updateCourse(Course course) {
        courseDao.update(course);
    }

    public void deleteCourse(Integer courseId) {
        courseDao.delete(courseId);
    }
}
