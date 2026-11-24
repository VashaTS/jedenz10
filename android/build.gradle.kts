allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// image_picker_android's lintVital task crashes on this JDK/AGP combination
// (CommentDetector / List.removeLast). That check is not required to produce a bundle.
subprojects {
    tasks.configureEach {
        if (name.contains("lintVital", ignoreCase = true)) {
            enabled = false
        }
    }
}
