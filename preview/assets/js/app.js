document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll("form[data-auth-login]").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            var usernameField = form.querySelector("[name='username']");
            var username = usernameField ? usernameField.value.toLowerCase() : "";
            var target = form.dataset.studentUrl;
            if (username.includes("admin")) {
                target = form.dataset.adminUrl;
            } else if (username.includes("lecturer") || username.includes("teacher") || username.includes("wang")) {
                target = form.dataset.lecturerUrl;
            }
            if (target) {
                event.preventDefault();
                window.location.href = target;
            }
        });
    });

    document.querySelectorAll("form[data-auth-register]").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            if (form.dataset.studentUrl) {
                event.preventDefault();
                window.alert("学生账号创建成功，角色为 STUDENT。");
                window.location.href = form.dataset.studentUrl;
            }
        });
    });

    document.querySelectorAll("[data-confirm]").forEach(function (element) {
        element.addEventListener("click", function (event) {
            var message = element.getAttribute("data-confirm");
            if (message && !window.confirm(message)) {
                event.preventDefault();
            }
        });
    });

    document.querySelectorAll("form[data-validate='time-range']").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            var start = form.querySelector("[data-start-time]");
            var end = form.querySelector("[data-end-time]");
            if (start && end && start.value && end.value && start.value >= end.value) {
                event.preventDefault();
                window.alert("结束时间必须晚于开始时间。");
            }
        });
    });

    document.querySelectorAll("form[data-ui-message]").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            event.preventDefault();
            window.alert(form.dataset.uiMessage);
        });
    });

    document.querySelectorAll("[data-fill-form]").forEach(function (button) {
        button.addEventListener("click", function () {
            var target = document.querySelector(button.getAttribute("data-fill-form"));
            if (!target) {
                return;
            }
            Object.keys(button.dataset).forEach(function (key) {
                if (!key.startsWith("field")) {
                    return;
                }
                var fieldName = key.slice(5);
                fieldName = fieldName.charAt(0).toLowerCase() + fieldName.slice(1);
                var field = target.querySelector("[name='" + fieldName + "']");
                if (field) {
                    var value = button.dataset[key] || "";
                    if (field.type === "datetime-local" && value.length >= 16) {
                        value = value.slice(0, 16);
                    }
                    field.value = value;
                }
            });
            target.scrollIntoView({ behavior: "smooth", block: "start" });
        });
    });
});
