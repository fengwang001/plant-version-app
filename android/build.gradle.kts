allprojects {
    repositories {
        // 镜像优先，最后兜底到官方仓库
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
        // Flutter Engine Maven（国内镜像与官方）
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        google()
        mavenCentral()
    }
}

subprojects {
    repositories {
        // 强制注入到所有子模块，确保能解析 io.flutter 依赖
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        // 本地 Flutter Engine 仓库兜底
        val flutterRoot = File(rootProject.projectDir, "../..../driver/flutter/flutter")
        val engineDir1 = File("C:/driver/flutter/flutter/bin/cache/artifacts/engine/android")
        if (engineDir1.exists()) { maven { url = uri(engineDir1) } }
        google()
        mavenCentral()
    }

    // 在项目完成自身 build.gradle 评估后追加（避免被其自定义 repositories 覆盖）
    afterEvaluate {
        repositories {
            maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }
            maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
            val engineDir = File("C:/driver/flutter/flutter/bin/cache/artifacts/engine/android")
            if (engineDir.exists()) { maven { url = uri(engineDir) } }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
