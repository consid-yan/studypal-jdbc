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
                window.alert("The student account has been successfully created with the role STUDENT.");
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
                window.alert("The end time must be later than the start time.");
            }
        });
    });

    document.querySelectorAll("form[data-ui-message]").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            event.preventDefault();
            window.alert(form.dataset.uiMessage);
        });
    });

    document.querySelectorAll("[data-toggle-target]").forEach(function (button) {
        var target = document.getElementById(button.getAttribute("data-toggle-target"));
        if (!target) {
            return;
        }
        var expandedLabel = button.getAttribute("data-toggle-label-expanded");
        var collapsedLabel = button.textContent;
        button.addEventListener("click", function () {
            var isHidden = target.style.display === "none" || target.style.display === "";
            if (isHidden) {
                target.style.display = "";
                if (expandedLabel) {
                    button.textContent = expandedLabel;
                }
                target.scrollIntoView({ behavior: "smooth", block: "start" });
                var firstField = target.querySelector("input, select, textarea");
                if (firstField) {
                    firstField.focus();
                }
            } else {
                target.style.display = "none";
                button.textContent = collapsedLabel;
            }
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
