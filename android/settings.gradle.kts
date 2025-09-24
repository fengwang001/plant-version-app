// 提升 flutterSdkPath 到顶层，供后续所有块使用
val flutterSdkPath: String = run {
    val properties = java.util.Properties()
    file("local.properties").inputStream().use { properties.load(it) }
    val path = properties.getProperty("flutter.sdk")
    require(path != null) { "flutter.sdk not set in local.properties" }
    path
}

pluginManagement {
    includeBuild(
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val path = properties.getProperty("flutter.sdk")
            require(path != null) { "flutter.sdk not set in local.properties" }
            "$path/packages/flutter_tools/gradle"
        }
    )

    repositories {
        // 国内镜像优先，加速插件解析
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
        // 官方仓库兜底
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // 国内镜像优先
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://mirrors.cloud.tencent.com/nexus/repository/maven-public/") }
        maven { url = uri("https://repo.huaweicloud.com/repository/maven/") }
        // Flutter Engine Maven（国内镜像与官方）
        maven { url = uri("https://storage.flutter-io.cn") }
        maven { url = uri("https://storage.flutter-io.cn/download.flutter.io") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        // 本地 Flutter Engine 目录（作为最后兜底）
        val flutterEngineLocal = File("$flutterSdkPath/bin/cache/artifacts/engine/android")
        if (flutterEngineLocal.exists()) {
            maven { url = uri(flutterEngineLocal) }
        }
        // 官方仓库兜底
        google()
        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
