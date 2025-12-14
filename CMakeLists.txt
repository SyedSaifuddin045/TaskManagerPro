cmake_minimum_required(VERSION 3.19)
project(MyFirstApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Quick
    Qml
)

qt_standard_project_setup()

qt_add_executable(MyFirstApp
    main.cpp
    Task.h Task.cpp
    TaskManager.h TaskManager.cpp
    TaskStore.h TaskStore.cpp
    TaskListModel.h TaskListModel.cpp
)

# Add a QML module
qt_add_qml_module(MyFirstApp
    URI MyApp
    VERSION 1.0
    QML_FILES
        Main.qml
)

target_link_libraries(MyFirstApp PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
)

set_target_properties(MyFirstApp PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

include(GNUInstallDirs)

install(TARGETS MyFirstApp
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
