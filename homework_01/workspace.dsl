workspace "Task Planning System" "Architecture documentation for homework variant 10: task planning" {

    model {
        manager = person "Руководитель / автор цели" "Создает цели, добавляет задачи, назначает исполнителей и контролирует выполнение."
        executor = person "Исполнитель" "Просматривает назначенные задачи и изменяет их статус."
        administrator = person "Администратор" "Создает пользователей и выполняет поиск пользователей."

        emailSmsSystem = softwareSystem "Email/SMS Notification Provider" "Внешний сервис для отправки уведомлений исполнителям." "External System"

        taskPlanningSystem = softwareSystem "Система планирования задач" "Сервис для управления целями, задачами и исполнителями." {
            webApp = container "Web Application" "Пользовательский интерфейс для работы с целями, задачами и пользователями." "React / TypeScript" "Web Application"
            apiGateway = container "API Gateway" "Единая точка входа для клиентского приложения. Принимает REST-запросы и направляет их в доменные сервисы." "C++17 / userver, REST API" "API"
            userService = container "User Service" "Создание пользователей и поиск пользователей по логину, имени и фамилии." "C++17 / userver, REST API" "Service"
            goalService = container "Goal Service" "Создание целей и получение списка всех целей." "C++17 / userver, REST API" "Service"
            taskService = container "Task Service" "Создание задач в рамках цели, получение задач цели и изменение статуса задачи." "C++17 / userver, REST API" "Service"
            notificationService = container "Notification Service" "Формирует и отправляет уведомления о назначении задач и изменении статусов." "C++17 / userver, REST API" "Service"
            database = container "PostgreSQL Database" "Хранит пользователей, цели, задачи, исполнителей и историю изменения статусов." "PostgreSQL" "Database"
        }

        manager -> taskPlanningSystem "Создает цели, задачи и контролирует их выполнение"
        executor -> taskPlanningSystem "Просматривает задачи и меняет статус выполнения"
        administrator -> taskPlanningSystem "Управляет пользователями"
        taskPlanningSystem -> emailSmsSystem "Отправляет уведомления исполнителям" "HTTPS/API"

        manager -> webApp "Работает с целями и задачами" "HTTPS"
        executor -> webApp "Просматривает назначенные задачи и меняет статус" "HTTPS"
        administrator -> webApp "Создает и ищет пользователей" "HTTPS"

        webApp -> apiGateway "Вызывает API системы" "HTTPS/REST/JSON"

        apiGateway -> userService "Маршрутизирует запросы создания и поиска пользователей" "HTTP/REST"
        apiGateway -> goalService "Маршрутизирует запросы по целям" "HTTP/REST"
        apiGateway -> taskService "Маршрутизирует запросы по задачам" "HTTP/REST"

        taskService -> goalService "Проверяет существование цели перед созданием задачи" "HTTP/REST"
        taskService -> userService "Проверяет существование исполнителя перед назначением задачи" "HTTP/REST"
        taskService -> notificationService "Передает событие о создании задачи или изменении статуса" "HTTP/REST"

        userService -> database "Читает и записывает данные пользователей" "PostgreSQL protocol / SQL"
        goalService -> database "Читает и записывает данные целей" "PostgreSQL protocol / SQL"
        taskService -> database "Читает и записывает данные задач и статусов" "PostgreSQL protocol / SQL"
        notificationService -> emailSmsSystem "Отправляет уведомления" "HTTPS/API"
    }

    views {
        systemContext taskPlanningSystem "SystemContext" {
            title "C1 — System Context: Система планирования задач"
            description "Показывает пользователей, внешнюю систему уведомлений и границы системы планирования задач."
            include *
            autolayout lr
        }

        container taskPlanningSystem "Containers" {
            title "C2 — Container: Контейнеры системы планирования задач"
            description "Показывает веб-приложение, API Gateway, доменные сервисы, базу данных и сервис уведомлений."
            include *
            autolayout lr
        }

        dynamic taskPlanningSystem "CreateTaskForGoal" {
            title "Dynamic — создание новой задачи на пути к цели"
            description "Архитектурно значимый сценарий: руководитель создает задачу, система проверяет цель и исполнителя, сохраняет задачу и отправляет уведомление."

            manager -> webApp "1. Заполняет форму создания задачи"
            webApp -> apiGateway "2. POST /goals/{goalId}/tasks"
            apiGateway -> taskService "3. Передает команду создания задачи"
            taskService -> goalService "4. Проверяет, что цель существует"
            goalService -> database "5. Читает данные цели"
            taskService -> userService "6. Проверяет, что исполнитель существует"
            userService -> database "7. Читает данные пользователя"
            taskService -> database "8. Сохраняет новую задачу со статусом TODO"
            taskService -> notificationService "9. Передает событие TaskCreated"
            notificationService -> emailSmsSystem "10. Отправляет уведомление исполнителю"

            autolayout lr
        }

        styles {
            element "Person" {
                shape Person
                background #08427B
                color #FFFFFF
            }

            element "Software System" {
                background #1168BD
                color #FFFFFF
            }

            element "External System" {
                background #999999
                color #FFFFFF
            }

            element "Container" {
                background #438DD5
                color #FFFFFF
            }

            element "Database" {
                shape Cylinder
                background #F5DA81
                color #000000
            }

            relationship "Relationship" {
                color #707070
            }
        }
    }
}
